# Dataset Model
class Dataset < ApplicationRecord
  CANCER_ANALYST_DATASETIDS = [[29, 1], [24, 2], [30, 1], [45, 2], [22, 1], [35, 2], [6, 2],
                               [38, 1], [36, 2], [16, 1]].freeze
  DEVELOPER_DATASET_IDS = [[35, 1], [18, 2], [43, 1], [45, 2], [23, 1], [29, 2], [22, 1], [33, 2],
                           [6, 3], [25, 1]].freeze
  QA_DATASET_IDS = [[45, 2], [29, 1], [16, 2], [27, 1], [18, 2], [38, 1], [28, 2], [25, 1], [58, 2],
                    [30, 1]].freeze

  belongs_to :team
  belongs_to :dataset_type, inverse_of: :datasets
  has_many :dataset_versions, dependent: :destroy
  has_many :project_datasets
  has_many :grants, foreign_key: :dataset_id, dependent: :destroy
  has_many :users, -> { extending(GrantedBy).distinct }, through: :grants

  has_many :approver_grants, lambda {
    where grants: { roleable_type: 'DatasetRole', roleable_id: DatasetRole.fetch(:approver).id }
  }, class_name: 'Grant'
  has_many :approvers, through: :approver_grants, class_name: 'User', source: :user

  delegate :name, to: :dataset_type, prefix: true, allow_nil: true

  enum cas_type: { cas_defaults: 1, cas_extras: 2 }

  DATASET_BROWSER_TYPES = %w[xml non_xml].freeze

  scope :for_browsing, lambda {
    joins(:dataset_type).merge(DatasetType.where(name: DATASET_BROWSER_TYPES))
  }

  scope :table_spec, lambda {
    joins(:dataset_type).merge(DatasetType.where(name: 'table_specification'))
  }

  scope :odr, lambda {
    joins(:dataset_type).merge(DatasetType.where(name: 'odr'))
  }

  scope :cas, lambda {
    joins(:dataset_type).merge(DatasetType.where(name: 'cas'))
  }

  def to_xsd(version)
    dataset_versions.find_by(semver_version: version).to_xsd
  end

  validates :name, uniqueness: { scope: :dataset_type }

  before_destroy do
    throw(:abort) if in_use?
  end

  def in_use?
    dataset_versions.any?(&:in_use?)
  end

  class << self
    def search(params)
      filters = []
      %i[name full_name].each do |field|
        filters << field_filter(field, params[:name])
      end

      filters.compact!
      where(filters.first).or(where(filters.last))
    end

    private

    def field_filter(field, text)
      arel_table[field].matches("%#{text.strip}%") if text.present?
    end
  end
end
