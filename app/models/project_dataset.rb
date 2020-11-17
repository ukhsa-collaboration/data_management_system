# TeamDataSource associations and validations
# If ODR EOI's and Applications are a choice of every single dataset, do we even need this anymore?
# It will only exist to limit an MBIS team to 1 of the 4 MBIS dataset. Any point?
class ProjectDataset < ApplicationRecord
  belongs_to :project
  belongs_to :dataset

  # Allow for auditing/version tracking of TeamDataSource
  has_paper_trail

  # data_source_name
  delegate :name, to: :dataset, prefix: true
  delegate :terms, to: :dataset, prefix: true

  # team_name
  delegate :name, to: :project, prefix: true

  validates :dataset_id, uniqueness: { scope: [:project_id],
                                       message: 'Project already has access ' \
                                                'to this dataset' }

  validate :terms_accepted_for_dataset

  # TODO: TEST
  def terms_accepted_for_dataset
    return if dataset.nil?
    return if dataset.dataset_type_name == 'cas'
    return if terms_accepted

    errors.add(:project_dataset, "Terms accepted can't be blank")
  end
end
