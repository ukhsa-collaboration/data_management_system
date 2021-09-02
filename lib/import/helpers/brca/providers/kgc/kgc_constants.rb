module Import
  module Helpers
    module Brca
      module Providers
        module Kgc
          # Constants used by LondonKgcHandlerColorectal
          module KgcConstants
            PASS_THROUGH_FIELDS_COLO = %w[age sex consultantcode collecteddate receiveddate
                                          authoriseddate servicereportidentifier providercode].freeze

            BRCA = /Breast\sCancer|
                    Trusight Cancer panel\:\sBreast cancer|
                    BreastGene\spanel|
                    Ovarian\sCancer|
                    OVARIAN\sCANCER\sPANEL|
                    OVARIAN\sCANCER\sPANEL\sNOT\sPMS2|
                    BreastGene|
                    OvarianGene\spanel/ix .freeze

            BRCA_TP53 = /Li\sFraumeni\sSyndrome|
                         LiFraumeni\ssyndrome|
                         TP53/i .freeze
            EXON_REGEX = /ex(?:on) (?<exno>[0-9]{1,2}(-[0-9]{1,2})?).+(?<deldupins>(del|dup|ins))|(?<deldupins>(del|dup|ins)).+ex(?:on(s)?) (?<exno>[0-9]{1,2}(-[0-9]{1,2})?)/i .freeze
            # CDNA_REGEX = /c\.(?<dna>[0-9]+([a-z]+|[^[:alnum:]])([0-9]+[a-z]+>[a-z]|[0-9]+[a-z]+|[^[:alnum:]][a-z]+)))/i .freeze
            CDNA_REGEX = /(?<dna>c\.[0-9]+_[0-9]+[a-z]+|
                         [0-9]+\+[0-9]+[a-z]+>[a-z]+|
                         [0-9]+[a-z]+>[a-z]+|
                         [0-9]+[a-z]+|1100delC)/ix
            PROTEIN_REGEX = /p\.(\(|\[)?(?<impact>[a-z]+[0-9]+([a-z]+[^[:alnum:]]|[a-z]+|[^[:alnum:]]))/i .freeze
            BRCA_GENES_REGEX = /(?<brca>BRCA1|
                                      BRCA2|
                                      TP53|
                                      CHEK2)/xi .freeze

            TP53_GENES = %w[BRCA1 BRCA2 TP53].freeze

            BRCAGENES = %w[BRCA1 BRCA2].freeze

            NEGATIVE_TEST_LOG = 'SUCCESSFUL gene parse for negative test for'.freeze

          end
        end
      end
    end
  end
end
