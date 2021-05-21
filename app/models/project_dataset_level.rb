class ProjectDatasetLevel < ApplicationRecord
  belongs_to :project_dataset
  belongs_to :zdataset_level, class_name: 'Lookups::ZdatasetLevel'
end
