# Parses the params submitted by the checkbox matrix of grants
class CasDatasetLevel
  def initialize(params)
    @params = params
  end

  def call
    clean_params = @params.to_h
    clean_params['project_datasets_attributes'].reject! { |k, v| v['zdataset_level_ids'].all?(&:blank?) }

    clean_params
  end
end
