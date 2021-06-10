if Rails.env.test?
  roles = YAML.load_file(Rails.root.join('test/cas_applicant_roles.yml'))

  CANCER_ANALYST_DATASETS = roles['ndrs_analyst']['datasets']
  NDRS_DEVELOPER_DATASETS = roles['ndrs_developer']['datasets']
  NDRS_QA_DATASETS = roles['ndrs_qa']['datasets']
else
  roles = YAML.load_file(Rails.root.join('config/cas_applicant_roles.yml'))

  CANCER_ANALYST_DATASETS = roles['ndrs_analyst']['datasets']
  NDRS_DEVELOPER_DATASETS = roles['ndrs_developer']['datasets']
  NDRS_QA_DATASETS = roles['ndrs_qa']['datasets']
end
