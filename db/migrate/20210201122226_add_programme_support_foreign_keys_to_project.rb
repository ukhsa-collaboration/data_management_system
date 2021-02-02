class AddProgrammeSupportForeignKeysToProject < ActiveRecord::Migration[6.0]
  def change
    add_column :projects, :programme_support_id, :integer, index: true
    add_foreign_key :projects, :programme_supports, column: :programme_support_id
  end
end
