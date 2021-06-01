# Model for the ProjectDatasetLevel class
class ProjectDatasetLevel < ApplicationRecord
  belongs_to :project_dataset
  belongs_to :access_level, class_name: 'Lookups::AccessLevel'

  after_update :notify_cas_approved_change

  def notify_cas_approved_change
    return unless project_dataset.project.cas?
    # Should only be approving after DRAFT
    return if project_dataset.project.current_state&.id == 'DRAFT'
    return if approved.nil?

    User.cas_manager_and_access_approvers.each do |user|
      CasNotifier.dataset_level_approved_status_updated(project_dataset.project, self, user.id)
    end
    CasMailer.with(project: project_dataset.project, project_dataset_level: self).send(
      :dataset_level_approved_status_updated
    ).deliver_later
    CasNotifier.dataset_level_approved_status_updated_to_user(project_dataset.project, self)
    CasMailer.with(project: project_dataset.project, project_dataset_level: self).send(
      :dataset_level_approved_status_updated_to_user
    ).deliver_later
  end

  def readable_approved_status
    return 'Undecided' if approved.nil?

    approved ? 'Approved' : 'Rejected'
  end
end
