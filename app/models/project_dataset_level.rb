class ProjectDatasetLevel < ApplicationRecord
  belongs_to :project_dataset
  belongs_to :access_level, class_name: 'Lookups::AccessLevel'
end
