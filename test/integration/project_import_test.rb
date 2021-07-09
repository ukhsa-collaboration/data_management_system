require 'test_helper'

class ProjectImportTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:application_manager_one)

    sign_in @user

    visit terms_and_conditions_path
    click_on 'Accept'
  end

  test 'projects can be updated via PDF import' do
    file    = Pathname.new(fixture_path).join('files', 'odr_data_request_form_v5-alpha.6.pdf')
    project = create_project(
      project_type:    project_types(:application),
      name:            'Provisional Title',
      project_purpose: 'Tests importing PDF files'
    )

    visit edit_project_path(project)

    assert has_text?('Drag and drop PDF here')

    assert_changes -> { project.reload.updated_at } do
      assert_difference -> { project.project_attachments.count } do
        attach_file(file) do
          find('.glyphicon-inbox').click
        end

        assert has_no_text?('Provisional Title')
        assert has_text?('My Test Import Project')
        assert_equal project_path(project), current_path
      end
    end
  end

  test 'projects cannot be updated via PDF import by unpriveledged user' do
    project = create_project(
      project_type: project_types(:application),
      project_purpose: 'Import testing'
    )

    sign_out :user
    sign_in users(:standard_user2)

    visit edit_project_path(project)

    assert has_no_text?('Drag and drop PDF here')
  end

  test 'not all project types support update via PDF import' do
    project = create_project(
      project_type: project_types(:eoi),
      project_purpose: 'Import testing'
    )

    visit edit_project_path(project)

    assert has_no_text?('Drag and drop PDF here')
  end
end
