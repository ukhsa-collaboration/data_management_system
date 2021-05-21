# Parses the params submitted by the checkbox matrix of grants
class CasDatasetLevel
  def initialize(params)
    @params = params
  end
  def call
    clean_params = @params.to_h
    binding.pry
    clean_params['project_datasets_attributes'].reject! { |k, v| v['access_level_ids'].all?(&:blank?) }
    clean_params
  end
end