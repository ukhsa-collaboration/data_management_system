# plan.io 25873 - Add levels column to datasets
class AddLevelsColumnToDatasets < ActiveRecord::Migration[6.0]
  def change
    add_column :datasets, :levels, :jsonb, null: false, default: {}
    add_column :datasets, :cas_type, :integer, limit: 1
  end
end
