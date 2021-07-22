require 'test_helper'

module Workflow
  # Test the Workflow::Mail concern.
  class MailTest < ActionMailer::TestCase
    tests :projects_mailer

    test 'default transitioned email' do
      project = projects(:dummy_project)

      email = ProjectsMailer.with(
        project:      project,
        user:         project.owner,
        current_user: project.owner
      ).transitioned

      assert_emails(1) { email.deliver_now }

      assert_equal [project.owner.email], email.to
      assert_equal 'Dummy Status Update', email.subject
      assert_match 'Dummy Status Update', email.encoded
      assert_match(<<~STR.squish, email.encoded)
        The status for the project entitled "#{project.name}" has changed
        to "#{project.current_state_name}"
      STR
      assert_match 'Project Details', email.encoded
      assert_match %r{http://[^/]+/projects/#{project.id}}, email.encoded
    end

    test 'default transition email, with comment' do
      project = projects(:dummy_project)

      email = ProjectsMailer.with(
        project:      project,
        user:         project.owner,
        current_user: project.owner,
        comments:     'RAWR!'
      ).transitioned

      assert_emails(1) { email.deliver_now }

      assert_match 'RAWR!', email.encoded
    end

    test 'state changed email with no specific handler' do
      project = projects(:dummy_project)

      # ... because currently disabled
      ProjectsMailer.any_instance.expects(:transitioned).never

      ProjectsMailer.with(
        project:      project,
        user:         project.owner,
        current_user: project.owner
      ).state_changed.deliver_now
    end

    test 'state changed email with project type specific handler' do
      project = projects(:dummy_project)

      ProjectsMailer.any_instance.expects(:transitioned).never
      ProjectsMailer.any_instance.expects(:dummy_transitioned)

      ProjectsMailer.with(
        project:      project,
        user:         project.owner,
        current_user: project.owner
      ).state_changed.deliver_now
    end

    test 'state changed email with state specific shandler' do
      project = projects(:dummy_project)
      state   = project.current_state.to_lookup_key

      ProjectsMailer.any_instance.expects(:transitioned).never
      ProjectsMailer.any_instance.expects(:dummy_transitioned).never
      ProjectsMailer.any_instance.expects(:"transitioned_to_#{state}")

      ProjectsMailer.with(
        project:      project,
        user:         project.owner,
        current_user: project.owner
      ).state_changed.deliver_now
    end

    test 'state changed email with project type and state specific shandler' do
      project = projects(:dummy_project)
      state   = project.current_state.to_lookup_key
      type    = project.project_type.to_lookup_key

      ProjectsMailer.any_instance.expects(:transitioned).never
      ProjectsMailer.any_instance.expects(:dummy_transitioned).never
      ProjectsMailer.any_instance.expects(:"transitioned_to_#{state}").never
      ProjectsMailer.any_instance.expects(:"#{type}_transitioned_to_#{state}")

      ProjectsMailer.with(
        project:      project,
        user:         project.owner,
        current_user: project.owner
      ).state_changed.deliver_now
    end
  end
end
