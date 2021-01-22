require 'test_helper'

# Tests behaviour of ProjectsMailer
class ProjectsMailerTest < ActionMailer::TestCase
  test 'project assignment' do
    assigned_user = users(:application_manager_one)
    project       = build_project(project_type: project_types(:eoi), assigned_user: assigned_user)

    project.save(validate: false)

    email = ProjectsMailer.with(project: project).project_assignment

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [assigned_user.email], email.to
    assert_equal 'Project Assignment', email.subject
    assert_match %r{a href="http://[^/]+/projects/#{project.id}"}, email.html_part.body.to_s
    assert_match %r{http://[^/]+/projects/#{project.id}}, email.text_part.body.to_s
  end

  test 'project awaiting assignment' do
    project = build_project(project_type: project_types(:eoi))
    project.save(validate: false)

    email = ProjectsMailer.with(project: project).project_awaiting_assignment

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal User.odr_users.map(&:email), email.to
    assert_equal 'Project Awaiting Assignment', email.subject
    assert_match %r{a href="http://[^/]+/projects/#{project.id}"}, email.html_part.body.to_s
    assert_match %r{http://[^/]+/projects/#{project.id}}, email.text_part.body.to_s
  end

  test 'should not send project assignment email when not odr or mbis' do
    assigned_user = users(:application_manager_one)
    project       = build_project(project_type: project_types(:cas), assigned_user: assigned_user)

    project.save(validate: false)

    email = ProjectsMailer.with(project: project).project_assignment

    assert_emails 0 do
      email.deliver_now
    end
  end

  test 'should not send project awaiting assignment email when not odr or mbis' do
    assigned_user = users(:application_manager_one)
    project       = build_project(project_type: project_types(:cas), assigned_user: assigned_user)

    project.save(validate: false)

    email = ProjectsMailer.with(project: project).project_awaiting_assignment

    assert_emails 0 do
      email.deliver_now
    end
  end
end
