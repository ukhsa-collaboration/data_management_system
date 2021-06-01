require 'test_helper'

module Workflow
  class AssignmentsControllerTest < ActionDispatch::IntegrationTest
    def setup
      @project  = projects(:dummy_project)
      @user_one = users(:application_manager_one)
      @user_two = users(:application_manager_two)

      @project.current_project_state.assign_to!(user: @user_one)

      sign_in(@user_one)
    end

    test 'should create a new assignment' do
      project_state = @project.current_project_state

      assert_difference -> { Assignment.count } do
        post workflow_project_state_assignments_path(project_state), params: {
          assignment: {
            assigned_user_id: @user_two.id
          }
        }
      end

      assert_redirected_to project_path(@project)
      assert_equal 'Project assigned successfully', flash[:notice]
    end

    test 'should prevent unauthorized access' do
      project_state = @project.current_project_state
      project_state.assign_to!(user: @user_two)

      assert_no_difference -> { Assignment.count } do
        post workflow_project_state_assignments_path(project_state), params: {
          assignment: {
            assigned_user_id: @user_two.id
          }
        }
      end

      assert_redirected_to root_path
      assert_equal 'You are not authorized to access this page.', flash[:error]
    end

    test 'should prevent assignment of a previous state' do
      previous_state = @project.current_project_state
      @project.transition_to!(workflow_states(:step_one)) do |_, project_state|
        project_state.assignments.build(assigned_user: @user_one)
      end

      assert_no_difference -> { Assignment.count } do
        post workflow_project_state_assignments_path(previous_state), params: {
          assignment: {
            assigned_user_id: @user_two.id
          }
        }
      end

      assert_redirected_to project_path(@project)
    end

    test 'should prevent assignment to an inappropriate user' do
      project_state = @project.current_project_state

      assert_no_difference -> { Assignment.count } do
        post workflow_project_state_assignments_path(project_state), params: {
          assignment: {
            assigned_user_id: users(:standard_user1).id
          }
        }
      end

      assert_redirected_to project_path(@project)
      assert_equal 'Could not assign project!', flash[:alert]
    end
  end
end
