# Parses the params submitted by the checkbox matrix of grants
class CasDatasetLevel
  def initialize(params)
    @params = params
  end
  def call
    clean_params = @params.to_h
    clean_params['project_datasets_attributes'].reject! do |k, v|
      v['project_dataset_levels_attributes'].all? do |kk, vv|
        vv['access_level_id'].to_i.zero?
      end
    end
    clean_params
  end
end