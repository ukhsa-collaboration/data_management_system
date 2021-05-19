# plan.io 25873 - Add project_dataset_levels table
class AddProjectDatasetLevelsTable < ActiveRecord::Migration[6.0]
  def change
    create_table :project_dataset_levels do |t|
      t.integer :project_dataset_id
      t.integer :level
      t.date :expiry_date
      t.boolean :approved
    end

    add_foreign_key :project_dataset_levels, :project_datasets, column: :project_dataset_id
  end
end
