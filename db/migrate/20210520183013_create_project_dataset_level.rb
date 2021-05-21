class CreateProjectDatasetLevel < ActiveRecord::Migration[6.0]
  def change
    create_table :project_dataset_levels do |t|
      t.references :project_dataset, foreign_key: true
      t.integer :level

      t.timestamps
    end
  end
end
