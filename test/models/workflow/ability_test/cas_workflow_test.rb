require 'test_helper'

module Workflow
  # Tests grants relating to the CAS workflow.
  class CasWorkflowTest < ActiveSupport::TestCase
    def setup
      @project = create_cas_project(project_purpose: 'test')
    end

    test 'project workflow as basic user on project they do not own' do
      user = users(:no_roles)

      @project.stubs current_state: workflow_states(:draft)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:submitted)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_approver_approved)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_approver_rejected)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:rejection_reviewed)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_granted)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:account_closed)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
    end

    test 'project workflow as basic user on project they own' do
      user = users(:no_roles)
      @project.update(owner: user)

      @project.stubs current_state: workflow_states(:draft)
      assert user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:submitted)
      assert user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_approver_approved)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_approver_rejected)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:rejection_reviewed)
      assert user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_granted)
      assert user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      assert user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:account_closed)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
    end

    test 'project workflow as access approver on projects they do not own' do
      user = users(:cas_access_approver)

      @project.stubs current_state: workflow_states(:draft)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:submitted)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      assert user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      assert user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_approver_approved)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_approver_rejected)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:rejection_reviewed)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_granted)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:account_closed)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
    end

    test 'project workflow as access approver on projects they are owner' do
      user = users(:cas_access_approver)
      @project.update(owner: user)

      @project.stubs current_state: workflow_states(:draft)
      assert user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      # Shouldn't be allowed to approve/reject project they own
      @project.stubs current_state: workflow_states(:submitted)
      assert user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_approver_approved)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_approver_rejected)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:rejection_reviewed)
      assert user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_granted)
      assert user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      assert user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:account_closed)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
    end

    test 'project workflow as cas manager' do
      user = users(:cas_manager)

      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:submitted)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_approver_approved)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_approver_rejected)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      assert user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      assert user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:rejection_reviewed)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:access_granted)
      refute user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      assert user.can? :create, @project.project_states.build(state: workflow_states(:account_closed))

      @project.stubs current_state: workflow_states(:account_closed)
      assert user.can? :create, @project.project_states.build(state: workflow_states(:draft))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:submitted))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_approved))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_approver_rejected))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:rejection_reviewed))
      refute user.can? :create, @project.project_states.build(state: workflow_states(:access_granted))
    end
  end
end
