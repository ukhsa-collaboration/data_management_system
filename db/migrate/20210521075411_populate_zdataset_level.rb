class PopulateZdatasetLevel < ActiveRecord::Migration[6.0]
  include MigrationHelper

  class ZdatasetLevel < ApplicationRecord
    attribute :value, :string
    attribute :description, :string
  end

  # this looks very similar to existing LevelOfIdentifiability lookup!
  def change
    add_lookup ZdatasetLevel, 1, value: '1', description: 'Everything'
    add_lookup ZdatasetLevel, 2, value: '2', description: 'Sensitive'
    add_lookup ZdatasetLevel, 3, value: '3', description: 'Anonymised'
  end
end
