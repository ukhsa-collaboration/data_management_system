# plan.io 25873 - Make all cas scoped datasets into cas_type of 'cas_extra'
class UpdateCasTypeCasDatasets < ActiveRecord::Migration[6.0]
  include MigrationHelper
  def change
    (59..68).each do |id|
      change_lookup Dataset, id, { cas_type: nil }, { cas_type: 2 }
    end
    %w[13 17 18 16 6 15 20 19 22 23 24 25 26 27 28 29 43 44 45 33 35 34 36 30 58 38 31].
    map{|i| i.to_i}.each do |id|
      change_lookup Dataset, id, { cas_type: nil }, { cas_type: 1 }
    end
  end
end