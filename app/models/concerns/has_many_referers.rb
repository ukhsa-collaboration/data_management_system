# Counterpart to `BelongsToReferent`; shared logic for `Project`s and `Amendment`s that may be
# referenced by `Contract`s, `DPIA`s or `Release`s.
module HasManyReferers
  extend ActiveSupport::Concern

  included do
    with_options as: :referent, dependent: :destroy do
      has_many :referent_dpias,     class_name: 'DataPrivacyImpactAssessment'
      has_many :referent_contracts, class_name: 'Contract'
      has_many :referent_releases,  class_name: 'Release'
    end
  end
end
