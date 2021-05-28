# plan.io 25873 - Add levels column to datasets
class AddSelectedColumnToProjectDatasetLevel < ActiveRecord::Migration[6.0]
  def change
    add_column :project_dataset_levels, :selected, :boolean
  end
end
