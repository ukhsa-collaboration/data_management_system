class RemoveApprovedFromProjectDataset < ActiveRecord::Migration[6.0]
  def change
    remove_column :project_datasets, :approved, :boolean
  end
end
