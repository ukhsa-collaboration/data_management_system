module Lookups
  class AccessLevel < ApplicationLookup
    has_many :project_dataset_levels
  end
end
