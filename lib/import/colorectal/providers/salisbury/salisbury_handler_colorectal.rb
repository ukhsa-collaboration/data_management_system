require 'possibly'
#W1706560
module Import
  module Colorectal
    module Providers
      module Salisbury
        # Process Salisbury-specific record details into generalized internal genotype format
        class SalisburyHandlerColorectal < Import::Brca::Core::ProviderHandler
          TEST_SCOPE_MAPPING_COLO = {
            'hnpcc mlpa' => :targeted_mutation,
            'hnpcc predictives' => :targeted_mutation,
            'lynch syndrome 3 gene panel' => :full_screen,
            'lynch syndrome 3 gene panel - re-analysis' => :full_screen
          } .freeze

          TEST_TYPE_MAPPING_COLO = { 'lynch syndrome 3 gene panel' => :diagnostic,
                                     'lynch syndrome 3 gene panel - re-analysis' => :diagnostic,
                                     'hnpcc mlpa' => :predictive,
                                     'hnpcc predictives' => :predictive } .freeze

          PASS_THROUGH_FIELDS_COLO = %w[age consultantcode
                                        servicereportidentifier
                                        providercode
                                        authoriseddate
                                        requesteddate] .freeze

          POSITIVE_TEST = /variant|pathogenic|deletion/i .freeze
          FAILED_TEST = /Fail*+|gaps/i .freeze
          GENE_LOCATION_REGEX = /.*c\.(?<cdna>[^ ]+)(?: p\.\((?<impact>.*)\))?.*/i .freeze
          EXON_LOCATION_REGEX = /exons? (\d+[a-z]*(?: ?- ?\d+[a-z]*)?)/i .freeze
          DEL_DUP_REGEX = /(?:\W*(del)(?:etion|[^\W])?)|(?:\W*(dup)(?:lication|[^\W])?)/i .freeze
          COLORECTAL_GENES_REGEX = /(?<colorectal>APC|
                                                BMPR1A|
                                                EPCAM|
                                                MLH1|
                                                MSH2|
                                                MSH6|
                                                MUTYH|
                                                PMS2|
                                                POLD1|
                                                POLE|
                                                PTEN|
                                                SMAD4|
                                                STK11)/xi .freeze # Added by

          def initialize(batch)
            super
          end

          def process_fields(record)
            genocolorectal = Import::Colorectal::Core::Genocolorectal.new(record)
            genocolorectal.add_passthrough_fields(record.mapped_fields,
                                                  record.raw_fields,
                                                  PASS_THROUGH_FIELDS_COLO)
            Maybe(record.raw_fields['moleculartestingtype']).each do |ttype|
              genocolorectal.add_molecular_testing_type_strict(TEST_TYPE_MAPPING_COLO[ttype.downcase.strip])
              scope = TEST_SCOPE_MAPPING_COLO[ttype.downcase.strip]
              genocolorectal.add_test_scope(scope) if scope
            end
            genocolorectal.add_specimen_type(record.mapped_fields['specimentype'])
            genocolorectal.add_received_date(record.raw_fields['date of receipt'])
            add_organisationcode_testresult(genocolorectal)
            res = add_colorectal_from_raw_test(genocolorectal, record)
            res.map { |cur_genotype| @persister.integrate_and_store(cur_genotype) }
          end

          def add_organisationcode_testresult(genocolorectal)
            genocolorectal.attribute_map['organisationcode_testresult'] = '699H0'
          end

          def normal_test?(record)
            return if record.raw_fields['status'].nil?

            record.raw_fields['status'].scan(/No mutation detected|benign|normal/i).size.positive?
          end

          def failed_test?(record)
            return if record.raw_fields['status'].nil?

            record.raw_fields['status'].scan(FAILED_TEST).size.positive?
          end

          def exon_variant?(geno_string)
            return if geno_string.nil?
            
            geno_string.scan(DEL_DUP_REGEX).size.positive? &&
            geno_string.scan(EXON_LOCATION_REGEX).size.positive?
          end

          def cdna_variant?(geno_string)
            return if geno_string.nil?
            
            geno_string.scan(GENE_LOCATION_REGEX).size.positive?
          end

          def process_single_exon_variant(geno_string, genocolorectal, genotypes)
            genocolorectal.add_gene_colorectal(geno_string.match(
                                               COLORECTAL_GENES_REGEX)[:colorectal]
                                               )
            genocolorectal.add_status(:positive)
            genocolorectal.add_exon_location(geno_string.scan(EXON_LOCATION_REGEX).join)
            genocolorectal.add_variant_type(geno_string.scan(DEL_DUP_REGEX).join)
            genotypes.append(genocolorectal)
          end

          def process_single_cdna_variant(colo_string, geno_string, genocolorectal, genotypes)
            genocolorectal.add_gene_colorectal(colo_string.match(
                                               COLORECTAL_GENES_REGEX)[:colorectal]
                                               )
            genocolorectal.add_status(:positive)
            genocolorectal.add_gene_location(geno_string.match(GENE_LOCATION_REGEX)[:cdna])
            genocolorectal.add_protein_impact(geno_string.match(GENE_LOCATION_REGEX)[:impact])
            genotypes.append(genocolorectal)
          end


          def process_false_positive(colo_string, genocolorectal, genotypes)
            genocolorectal.set_negative
            genocolorectal.add_gene_colorectal(colo_string.match(
                                                COLORECTAL_GENES_REGEX)[:colorectal]
                                                )
            genotypes.append(genocolorectal)
          end

          def positive_test?(record)
            return if record.raw_fields['status'].nil?

            record.raw_fields['status'].scan(POSITIVE_TEST).size.positive?
          end
          
          def multiple_tested_genes?(colo_string)
            return if colo_string.scan(COLORECTAL_GENES_REGEX).empty?

            colo_string.scan(COLORECTAL_GENES_REGEX).size > 1
          end

          def one_cnv_multiple_genes_multiple_exons?(geno_string)
            return if geno_string.nil?

            geno_string.scan(DEL_DUP_REGEX).flatten.compact.size == 1 &&
             geno_string.scan(COLORECTAL_GENES_REGEX).flatten.compact.size > 1
          end

          def one_cnv_one_gene?(geno_string)
            return if geno_string.nil?

            geno_string.scan(DEL_DUP_REGEX).flatten.compact.size == 1 &&
             geno_string.scan(COLORECTAL_GENES_REGEX).flatten.compact.size == 1
          end

          def process_one_cnv_multiple_genes_multiple_exons(genotypes, positive_genes,
                                                             genocolorectal, geno_string)
            mutation_type = geno_string.scan(DEL_DUP_REGEX).flatten.compact.join
            mutated_exons = geno_string.scan(EXON_LOCATION_REGEX).flatten
            positive_variants = positive_genes.zip(mutated_exons)
            positive_variants.each do |gene,exon|
              dup_genocolorectal = genocolorectal.dup_colo
              dup_genocolorectal.add_gene_colorectal(gene)
              dup_genocolorectal.add_status(:positive)
              dup_genocolorectal.add_exon_location(exon)
              dup_genocolorectal.add_variant_type(mutation_type)
              genotypes.append(dup_genocolorectal)
            end
            genotypes
          end

          def process_one_cnv_one_gene(genotypes, positive_genes,
                                      genocolorectal, geno_string)
            mutation_type = geno_string.scan(DEL_DUP_REGEX).flatten.compact.join
            mutated_exons = geno_string.scan(EXON_LOCATION_REGEX).flatten
            genocolorectal.add_gene_colorectal(positive_genes.flatten.join)
            genocolorectal.add_status(:positive)
            genocolorectal.add_exon_location(mutated_exons.join)
            genocolorectal.add_variant_type(mutation_type)
            genotypes.append(genocolorectal)
          end


          def process_negative_genes(genotypes, genocolorectal, negative_genes)
            return if negative_genes.empty?

            negative_genes.each do |gene|
              dup_genocolorectal = genocolorectal.dup_colo
              dup_genocolorectal.add_gene_colorectal(gene)
              dup_genocolorectal.add_status(:negative)
              genotypes << dup_genocolorectal
            end
            genotypes
          end
          
          def process_normal_record(colo_string, genocolorectal, genotypes)
            colo_string.scan(COLORECTAL_GENES_REGEX).flatten.each do |gene|
              dup_genocolorectal = genocolorectal.dup_colo
              dup_genocolorectal.add_gene_colorectal(gene)
              dup_genocolorectal.add_status(:negative)
              genotypes << dup_genocolorectal
            end
          end

          def process_failed_record(colo_string, genocolorectal, genotypes)
            colo_string.scan(COLORECTAL_GENES_REGEX).flatten.each do |gene|
              dup_genocolorectal = genocolorectal.dup_colo
              dup_genocolorectal.add_gene_colorectal(gene)
              dup_genocolorectal.add_status(:failed)
              genotypes << dup_genocolorectal
            end
          end

          def process_multiple_tested_genes(genotypes, record, genocolorectal, 
                                            colo_string, geno_string)
            return if geno_string.nil?

            tested_genes = colo_string.scan(COLORECTAL_GENES_REGEX).flatten.compact
            positive_genes = geno_string.scan(COLORECTAL_GENES_REGEX).flatten.compact
            negative_genes = tested_genes - positive_genes
            if normal_test?(record)
              process_normal_records(colo_string, genocolorectal, genotypes)
            elsif failed_test?(record)
              process_failed_records(colo_string, genocolorectal, genotypes)
            elsif positive_test?(record)
              process_negative_genes(genotypes, genocolorectal, negative_genes)
              if one_cnv_multiple_genes_multiple_exons?(geno_string)
                process_one_cnv_multiple_genes_multiple_exons(genotypes, positive_genes,
                                                             genocolorectal, geno_string)
              elsif one_cnv_one_gene?(geno_string)
                process_one_cnv_one_gene(genotypes, positive_genes,
                                         genocolorectal, geno_string)
              else positive_genes.each do |gene|
                  dup_genocolorectal = genocolorectal.dup_colo
                  dup_genocolorectal.add_gene_colorectal(gene)
                  dup_genocolorectal.add_status(:positive)
                  genotypes << dup_genocolorectal
                end
              end
            end
            genotypes
          end

          def add_colorectal_from_raw_test(genocolorectal, record)
            colo_string = record.raw_fields['test']
            geno_string = record.raw_fields['genotype']
            genotypes = []
            if multiple_tested_genes?(colo_string)
              process_multiple_tested_genes(genotypes, record, genocolorectal,
                                            colo_string, geno_string)
            elsif normal_test?(record)
              process_normal_record(colo_string, genocolorectal, genotypes)
            elsif failed_test?(record)
              process_failed_record(colo_string, genocolorectal, genotypes)
            elsif positive_test?(record)
              if geno_string.blank?
                process_false_positive(colo_string, genocolorectal, genotypes)
                # genocolorectal.set_negative
                # genocolorectal.add_gene_colorectal(colo_string.match(
                #                                     COLORECTAL_GENES_REGEX)[:colorectal]
                #                                     )
                # genotypes.append(genocolorectal)
              elsif exon_variant?(geno_string)
                process_single_exon_variant(geno_string, genocolorectal, genotypes)
              elsif cdna_variant?(geno_string)
                process_single_cdna_variant(colo_string, geno_string, genocolorectal, genotypes)
              else binding.pry 
              end
            end
            genotypes
          end


              # @logger.error "Multiple genes detected in input string: #{colo_string};"
              # colo_string.scan(COLORECTAL_GENES_REGEX).each do |gene|
              #   genocolorectal1 = genocolorectal.dup_colo
              #   genocolorectal1.add_gene_colorectal(gene[0])
              #   genotypes << genocolorectal1
              # end
            # elsif COLORECTAL_GENES_REGEX.match(colo_string) && colo_string.scan(COLORECTAL_GENES_REGEX).size == 1
            #   genocolorectal.add_gene_colorectal($LAST_MATCH_INFO[:colorectal])
            #   genotypes << genocolorectal
            #   @logger.debug "SUCCESSFUL gene change parse for: #{$LAST_MATCH_INFO[:colorectal]}"
            # else
            #   @logger.debug "FAILED cdna channge parse for  #{colo_string}"
            # end
            # genotypes
          # end

          # def extract_teststatus(genocolorectal, record)
          #   case record.raw_fields['status']
          #   when POSITIVE_TEST
          #     genocolorectal.add_status(:positive)
          #     @logger.debug "POSITIVE status for : #{record.raw_fields['status']}"
          #   when /Normal/
          #     genocolorectal.add_status(:negative)
          #     @logger.debug "NEGATIVE status for : #{record.raw_fields['status']}"
          #   when /No mutation detected/
          #     genocolorectal.add_status(:negative)
          #     @logger.debug "NEGATIVE status for : #{record.raw_fields['status']}"
          #   when /benign/i
          #     genocolorectal.add_status(:negative)
          #     @logger.debug "NEGATIVE status for : #{record.raw_fields['status']}"
          #   when FAILED_TEST
          #     genocolorectal.add_status(:failed)
          #     @logger.debug "FAILED status for : #{record.raw_fields['status']}"
          #   end
          # end

          # def extract_variant(geno_string, genocolorectal)
          #   return if geno_string.nil?
          #
          #   matches = GENE_LOCATION_REGEX.match(genotype_string)
          #   exon_matches = EXON_LOCATION_REGEX.match(genotype_string)
          #   if genotype_string.blank?
          #     # TODO: what is the desired value to put in here? Negative?
          #     genocolorectal.set_negative
          #     return
          #   end
          #   if matches
          #     genocolorectal.add_gene_location(matches[:gene]) if matches[1]
          #     genocolorectal.add_protein_impact(matches[:protein]) if matches[2]
          #   elsif exon_matches
          #     genocolorectal.add_exon_location(exon_matches[1].delete(' '))
          #     genocolorectal.add_variant_type(genotype_string)
          #   else
          #     @logger.warn "Cannot extract gene location from raw test: #{genotype_string}"
          #   end
          # end
        end
      end
    end
  end
end
