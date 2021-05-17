module Workflow
  # Acts as a ledger of who is, or has been, responsible for actioning a given `ProjectState`
  class Assignment < ApplicationRecord
    self.table_name_prefix = 'workflow_'

    belongs_to :project_state

    with_options class_name: 'User' do
      belongs_to :assigned_user
      belongs_to :assigning_user, optional: true
    end

    delegate :project, to: :project_state, allow_nil: true
  end
end
