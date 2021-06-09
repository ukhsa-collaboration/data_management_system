if Rails.env.test?
  # TODO:
else
  roles = YAML.load_file(Rails.root.join('config/cas_applicant_roles.yml'))

  CANCER_ANALYST_DATASETS = Dataset.db_ids(roles['ndrs_analyst']['datasets'])
  NDRS_DEVELOPER_DATASETS = Dataset.db_ids(roles['ndrs_developer']['datasets'])
  NDRS_QA_DATASETS = Dataset.db_ids(roles['ndrs_qa']['datasets'])
end