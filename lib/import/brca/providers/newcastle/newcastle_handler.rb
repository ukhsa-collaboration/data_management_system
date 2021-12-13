require 'possibly'
# require 'import/brca/providers/newcastle/newcastle_storage_manager'

module Import
  module Brca
    module Providers
      module Newcastle
        # Process Newcastle-specific record details into generalized internal genotype format
        class NewcastleHandler < Import::Brca::Core::ProviderHandler
          include Import::Helpers::Brca::Providers::Rtd::RtdConstants

          def initialize(batch)
            @failed_variant_counter = 0
            @variants_processed_counter = 0
            @ex = Import::ExtractionUtilities::LocationExtractor.new
            super
          end

          def process_fields(record)
            genotype = Import::Brca::Core::GenotypeBrca.new(record)
            genotype.add_passthrough_fields(record.mapped_fields,
                                            record.raw_fields,
                                            PASS_THROUGH_FIELDS,
                                            FIELD_NAME_MAPPINGS)
            add_organisationcode_testresult(genotype)
            add_variantpathclass(genotype, record)
            # add_serviceport_identifier(genotype, record)
            process_test_type(genotype, record)
            process_test_scope(genotype, record)
            # process_test_status(genotype, record)
            final_results = process_variant_records(genotype, record)
            final_results.map do |x|
              # binding.pry if x.attribute_map['teststatus'] == 4
              @persister.integrate_and_store(x)
            end
          end

          def add_organisationcode_testresult(genotype)
            genotype.attribute_map['organisationcode_testresult'] = '699A0'
          end

          def add_variantpathclass(genotype, record)
            genotype.add_variant_class(record.raw_fields['variantpathclass'])
          end

          # def add_gene_info(genotype, record)
          #   investigation_code = record.raw_fields['investigation code']
          #   genotype.add_gene(investigation_code) if investigation_code.present?
          #   gene = record.raw_fields['gene']
          #   genotype.add_gene(gene) if gene.present?
          # end

          def process_test_type(genotype, record)
            # cludge to handle their change in field mapping...
            reason = record.raw_fields['referral reason']
            unless reason.nil?
              genotype.add_molecular_testing_type_strict(
                TEST_TYPE_MAP[reason.downcase.strip]
              )
            end
            mtype = record.raw_fields['moleculartestingtype']
            return if mtype.nil?

            genotype.add_molecular_testing_type_strict(
              TEST_TYPE_MAP[mtype.downcase.strip]
            )
          end

          def process_test_scope(genotype, record)
            moleculartestingtype = record.raw_fields['moleculartestingtype']&.downcase&.strip
            investigationcode = record.raw_fields['investigation code']&.downcase&.strip
            servicecategory = record.raw_fields['service category']&.downcase&.strip

            if servicecategory.present? && %w[o c a2].include?(servicecategory)
              add_scope_from_service_category(servicecategory, genotype)

            elsif TEST_SCOPE_MAP.key?(investigationcode)

              genotype.add_test_scope(TEST_SCOPE_MAP[investigationcode])
              @logger.info 'ADDED SCOPE FROM INVESTIGATION CODE'

            elsif TEST_SCOPE_FROM_TYPE_MAP.key?(moleculartestingtype)

              genotype.add_test_scope(TEST_SCOPE_FROM_TYPE_MAP[moleculartestingtype])
              @logger.info 'ADDED SCOPE FROM MOLECULAR TESTING TYPE'

            else
              @logger.info 'NOTHING TO BE DONE'
            end
          end

          def process_test_status(genotype, record)
            geno = record.raw_fields['teststatus']
            variant = get_variant(record)
            case geno
            when /nmd/
              genotype.add_status(1) if normal?(variant)
            when /variant/, /abnormal/, /pathogenic/
              genotype.add_status(2)
            when /het/
              genotype.add_status(4)
              genotype.add_zygosity(geno)
            when /hemi/
              genotype.add_status(2)
              genotype.add_zygosity(geno)
            when /fail/
              genotype.add_status(9)
            when /completed/, /no-result/, /other/, /verify/, /low/ # No appropriate status
              @logger.info 'Encountered teststatus No appropriate status'
            when nil
              @logger.info 'Encountered teststatus nil'
            else
              @logger.info "Encountered unfamiliar teststatus string: #{geno}"
            end
            genotype
          end

          def process_variant_records(genotype, record)
            genotypes = []
            if full_screen?(genotype)
              process_fullscreen_records(genotype, record, genotypes)
            elsif targeted?(genotype)
              process_targeted_screen(genotype, record, genotypes)
            else
              process_no_testscope_records(genotype, record, genotypes)
            end
            genotypes
          end

          def add_scope_from_service_category(service_category, genotype)
            if %w[o c].include? service_category
              @logger.debug 'Found O/C'
              genotype.add_test_scope(:full_screen)
            elsif service_category == 'a2'
              @logger.debug 'Found A2'
              genotype.add_test_scope(:targeted_mutation)
            else
              @logger.info 'Test scope not determined via service category'
            end
          end

          def process_fullscreen_records(genotype, record, genotypes)
            gene = record.raw_fields['gene']
            genotype.add_gene(gene) if gene.present?

            variant = get_variant(record)
            if variant.nil?
              process_normal_full_screen(genotype, record, genotypes)
            elsif positive_cdna?(variant) || positive_exonvariant?(variant)
              if [7, 8].include? genotype.other_gene
                genotype_dup = genotype.dup
                genotype_dup.add_gene(genotype.other_gene)
                genotype_dup.add_status(1)
                genotypes.append(genotype_dup)
              end
              process_variants(genotype, variant)
              genotypes.append(genotype)
            end
            genotypes
          end

          def process_normal_full_screen(genotype, record, genotypes)
            teststatus = record.raw_fields['teststatus']
            %w[BRCA1 BRCA2].each do |gene|
              if genotype.get('gene').nil? && (pathogenic?(record) ||
                %w[het variant pathogenic abnormal hemi other].include?(teststatus))
                genotype.add_status(4)
              elsif teststatus.blank? || teststatus&.scan(/nmd/i)&.size&.positive?
                genotype.add_status(1)
              elsif teststatus&.scan(/fail/i)&.size&.positive?
                genotype.add_status(9)
              end
              genotype_dup = genotype.dup
              genotype_dup.add_gene(gene)
              genotypes.append(genotype_dup)
            end
            genotypes
          end

          def process_targeted_screen(genotype, record, genotypes)
            investigation_code = record.raw_fields['investigation code']
            gene = record.raw_fields['gene']
            if investigation_code == 'BRCA1+2' && gene.nil?
              genotype.add_gene(nil)
            else
              genotype.add_gene(investigation_code) if investigation_code.present?
              genotype.add_gene(gene) if gene.present?
            end

            variant = get_variant(record)
            if variant.nil?
              process_normal_targeted(genotype, record)
            elsif positive_cdna?(variant) || positive_exonvariant?(variant)
              process_variants(genotype, variant)
            end
            genotypes.append(genotype)
            genotypes
          end

          def process_normal_targeted(genotype, record)
            teststatus = record.raw_fields['teststatus']&.strip
            if (genotype.get('gene').present? && teststatus.blank?) ||
               (genotype.get('gene').blank? && pathogenic?(record)) ||
               teststatus.blank? ||
               %w[het variant pathogenic abnormal hemi other].include?(teststatus)
              genotype.add_status(4)
            elsif teststatus.scan(/fail/i).size.positive?
              genotype.add_status(9)
            elsif teststatus.scan(/nmd/i).size.positive?
              genotype.add_status(1)
            end
          end

          def process_no_testscope_records(genotype, record, genotypes)
            gene = record.raw_fields['gene']
            genotype.add_gene(gene) if gene.present?

            variant = get_variant(record)
            teststatus = record.raw_fields['teststatus']
            if variant.nil?
              if genotype.get('gene').nil? &&
                 (pathogenic?(record) || teststatus.blank?)
                genotype.add_status(4)
              end
            elsif positive_cdna?(variant) || positive_exonvariant?(variant)
              process_variants(genotype, variant)
            end
            genotypes.append(genotype)
            genotypes
          end

          def process_variants(genotype, variant)
            process_cdna_variant(genotype, variant)
            process_exonic_variant(genotype, variant)
            process_protein_impact(genotype, variant)
          end

          def get_variant(record)
            record.raw_fields['genotype'].presence || record.raw_fields['variant name']
          end

          def full_screen?(genotype)
            return if genotype.attribute_map['genetictestscope'].nil?

            genotype.attribute_map['genetictestscope'].scan(/Full screen/i).size.positive?
          end

          def targeted?(genotype)
            return if genotype.attribute_map['genetictestscope'].nil?

            genotype.attribute_map['genetictestscope'].scan(/Targeted/i).size.positive?
          end

          def positive_cdna?(variant)
            variant.scan(CDNA_REGEX).size.positive?
          end

          def positive_exonvariant?(variant)
            variant.scan(EXON_VARIANT_REGEX).size.positive?
          end

          def pathogenic?(record)
            varpathclass = record.raw_fields['variantpathclass']
            true if !varpathclass.nil? && varpathclass.scan(PATHOGENICITY_REGEX).size.positive?
          end

          def normal?(variant)
            true if variant.nil? || (!positive_exonvariant?(variant) && !positive_cdna?(variant))
          end

          def process_exonic_variant(genotype, variant)
            return unless variant.scan(EXON_VARIANT_REGEX).size.positive?

            genotype.add_exon_location($LAST_MATCH_INFO[:exons])
            genotype.add_variant_type($LAST_MATCH_INFO[:variant])
            genotype.add_status(2)
            @logger.debug "SUCCESSFUL exon variant parse for: #{variant}"
          end

          def process_cdna_variant(genotype, variant)
            return unless variant.scan(CDNA_REGEX).size.positive?

            genotype.add_gene_location($LAST_MATCH_INFO[:cdna])
            genotype.add_status(2)
            @logger.debug "SUCCESSFUL cdna change parse for: #{$LAST_MATCH_INFO[:cdna]}"
          end

          def process_protein_impact(genotype, variant)
            if variant.scan(PROTEIN_REGEX).size.positive?
              genotype.add_protein_impact($LAST_MATCH_INFO[:impact])
              @logger.debug "SUCCESSFUL protein parse for: #{$LAST_MATCH_INFO[:impact]}"
            else
              @logger.debug "FAILED protein parse for: #{variant}"
            end
          end

          def summarize
            @logger.info ' ************** Handler Summary **************** '
            @logger.info "Num bad variants: #{@failed_variant_counter} of "\
                         "#{@variants_processed_counter} processed"
          end
        end
      end
    end
  end
end
