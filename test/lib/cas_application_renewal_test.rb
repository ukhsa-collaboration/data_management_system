require 'test_helper'

class CasApplicationRenewalTest < ActiveSupport::TestCase
  test 'CAS application moves to renewal after 1 year' do
    project = Project.create(project_type: project_types(:cas), owner: users(:standard_user2))

    project.transition_to!(workflow_states(:submitted))
    # Auto-transitions to ACCESS_GRANTED
    project.transition_to!(workflow_states(:access_approver_approved))

    assert_equal 'ACCESS_GRANTED', project.current_state.id

    travel_to 1.month.from_now

    klass = CasApplicationRenewal.new
    klass.renewals

    project.reload.current_state
    assert_equal 'ACCESS_GRANTED', project.current_state.id

    travel_to 1.year.from_now

    klass = CasApplicationRenewal.new
    klass.renewals

    project.reload.current_state
    assert_equal 'RENEWAL', project.current_state.id
  end
end