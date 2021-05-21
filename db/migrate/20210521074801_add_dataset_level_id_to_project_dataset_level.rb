class AddDatasetLevelIdToProjectDatasetLevel < ActiveRecord::Migration[6.0]
  def change
    add_column :project_dataset_levels, :zdataset_level_id, :integer
  end
end
