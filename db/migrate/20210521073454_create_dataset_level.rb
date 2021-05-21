class CreateDatasetLevel < ActiveRecord::Migration[6.0]
  def change
    create_table :dataset_levels do |t|
      t.string :value
      t.string :description

      t.timestamps
    end
  end
end
