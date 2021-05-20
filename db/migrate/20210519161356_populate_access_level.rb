class PopulateAccessLevel < ActiveRecord::Migration[6.0]
  include MigrationHelper

  class AccessLevel < ApplicationRecord
    attribute :value, :string
  end

  def change
    add_lookup AccessLevel, 1, value: 'Level 1'
    add_lookup AccessLevel, 2, value: 'Level 2'
    add_lookup AccessLevel, 3, value: 'Level 3'
  end
end
