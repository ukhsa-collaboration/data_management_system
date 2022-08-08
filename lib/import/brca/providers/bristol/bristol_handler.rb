require 'possibly'
require 'pry'
module Import
  module Brca
    module Providers
      module Bristol
        # Process Bristol-specific record details into generalized internal genotype format
        class BristolHandler < Import::Brca::Core::ProviderHandler
          PASS_THROUGH_FIELDS = %w[age consultantcode
                                   servicereportidentifier
                                   providercode
                                   authoriseddate
                                   requesteddate
                                   practitionercode
                                   geneticaberrationtype].freeze
          CDNA_REGEX = /c\.(?<cdna>[0-9]+[^\s|^, ]+)/ .freeze
          PROTEIN_REGEX = /p.(?:\((?<impact>.*)\))/ .freeze

          TESTSTATUS_MAP = { 'Benign'=>             :negative,
                             'Likely Benign'=>      :negative,
                             'Deleterious'=>        :positive,
                             'Likely Deleterious'=> :positive,
                             'Likely Pathogenic'=>  :positive,
                             'Pathogenic'=>         :positive,
                             'Unknown'=>            :positive }
                             
          def process_fields(record)
            genotype = Import::Brca::Core::GenotypeBrca.new(record)
            genotype.add_passthrough_fields(record.mapped_fields,
                                            record.raw_fields,
                                            PASS_THROUGH_FIELDS)
            process_cdna_change(genotype, record)
            add_protein_impact(genotype, record)
            add_organisationcode_testresult(genotype)
            genotype.add_gene_location(record.mapped_fields['codingdnasequencechange'])
            genotype.add_protein_impact(record.mapped_fields['proteinimpact'])
            genotype.add_variant_class(record.mapped_fields['variantpathclass'])
            genotype.add_received_date(record.raw_fields['received date'])
            process_genomic_change(genotype, record)
            genotype.add_test_scope(:full_screen)
            process_test_status(genotype, record)
            genotype.add_method('ngs')
            res = process_gene(genotype, record)
            res.each { |cur_genotype| @persister.integrate_and_store(cur_genotype) }
          end

          def add_organisationcode_testresult(genotype)
            genotype.attribute_map['organisationcode_testresult'] = '698V0'
          end

          def process_negative_record(record, negative_gene, genotypes)
            duplicated_genotype = Import::Brca::Core::GenotypeBrca.new(record)
            duplicated_genotype.add_gene(negative_gene.join())
            duplicated_genotype.add_status(1)
            duplicated_genotype.add_test_scope(:full_screen)
            duplicated_genotype.add_passthrough_fields(record.mapped_fields,
                                            record.raw_fields,
                                            PASS_THROUGH_FIELDS)
            genotypes.append(duplicated_genotype)
          end

          def process_gene(genotype, record)
            retur if record.raw_fields['gene'].nil?

            genotypes = []
            negative_gene = %w[BRCA1 BRCA2] - [record.raw_fields['gene']]
            process_negative_record(record, negative_gene, genotypes)
            genotype.add_gene(record.raw_fields['gene'])
            genotypes.append(genotype)
          end

          def process_test_status(genotype, record)
            return if record.raw_fields['variantpathclass'].nil?
            
            varpathclass_field = record.raw_fields['variantpathclass']
            if TESTSTATUS_MAP[varpathclass_field].present?
              genotype.add_status(TESTSTATUS_MAP[varpathclass_field])
            end
          end

          def process_cdna_change(genotype, record)
            case record.mapped_fields['codingdnasequencechange']
            when CDNA_REGEX
              genotype.add_gene_location($LAST_MATCH_INFO[:cdna])
              @logger.debug "SUCCESSFUL cdna change parse for: #{$LAST_MATCH_INFO[:cdna]}"
            else
              @logger.debug 'UNSUCCESSFUL cdna change parse'
            end
          end

          def add_protein_impact(genotype, record)
            case record.mapped_fields['proteinimpact']
            when PROTEIN_REGEX
              genotype.add_protein_impact($LAST_MATCH_INFO[:impact])
              @logger.debug 'SUCCESSFUL protein change parse for: ' \
              "#{$LAST_MATCH_INFO[:impact]}"
            end
          end

          def process_genomic_change(genotype, record)
            gchange = record.raw_fields['genomicchange']
            return if gchange.nil?

            case gchange
            when /(?<chr_num>\d+):(?<g_num>\d+)/
              genotype.add_parsed_genomic_change($LAST_MATCH_INFO[:chr_num],
                                                 $LAST_MATCH_INFO[:g_num])
            else
              @logger.warn "Could not process genomic change, adding raw: #{gchange}"
              genotype.add_raw_genomic_change(gchange)
            end
          end
        end
      end
    end
  end
end
