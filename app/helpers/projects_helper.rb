# Project helper methods
module ProjectsHelper
  STATE_TRANSITION_BUTTON_CLASSES = {
    'DELETED'   => 'btn-danger',
    'SUBMITTED' => 'btn-success',
    'APPROVED'  => 'btn-success',
    'REJECTED'  => 'btn-danger',
    'COMPLETED' => 'btn-success',
    'AMEND'     => 'btn-warning',
    'DPIA_START'         => 'btn-success',
    'DPIA_REVIEW'        => 'btn-success',
    'DPIA_MODERATION'    => 'btn-success',
    'DPIA_REJECTED'      => 'btn-danger',
    'CONTRACT_DRAFT'     => 'btn-success',
    'CONTRACT_REJECTED'  => 'btn-danger',
    'CONTRACT_COMPLETED' => 'btn-success',
    'DATA_RELEASED' => 'btn-success',
    'DATA_DESTROYED' => 'btn-danger',
  }.freeze

  STATE_TRANSITION_BUTTON_ICONS = {
    'DELETED'   => 'trash',
    'SUBMITTED' => 'thumbs-up',
    'APPROVED'  => 'thumbs-up',
    'REJECTED'  => 'thumbs-down',
    'COMPLETED' => 'thumbs-up',
    'DPIA_REJECTED'      => 'thumbs-down',
    'CONTRACT_REJECTED'  => 'thumbs-down',
    'CONTRACT_COMPLETED' => 'thumbs-up'
  }.freeze

  STATE_LABEL_CLASSES = {
    'DRAFT'     => 'label-warning',
    'APPROVED'  => 'label-success',
    'REJECTED'  => 'label-danger',
    'EXPIRED'   => 'label-danger',
    'COMPLETED' => 'label-success',
    'AMEND'     => 'label-warning',
    'DPIA_REJECTED'      => 'label-danger',
    'CONTRACT_REJECTED'  => 'label-danger',
    'CONTRACT_COMPLETED' => 'label-success',
    'DATA_RELEASED'  => 'label-success',
    'DATA_DESTROYED' => 'label-danger'
  }.freeze

  def new_project_dropdown_button(team, **html_options)
    return unless can?(:create, team.projects.build)

    options = { class: 'btn btn-primary dropdown-toggle', data: { toggle: :dropdown } }
    options.merge!(html_options)

    menu = capture do
      content_tag(:ul, class: 'dropdown-menu') do
        ProjectType.by_team_and_user_role(team, current_user).find_each do |project_type|
          link = link_to(
            project_type.name,
            new_team_project_path(team, project: { project_type_id: project_type.id })
          )
          concat content_tag(:li, link)
        end
      end
    end

    button = button_tag(bootstrap_icon_tag('plus') + ' New', options)

    button_group { safe_join([button, menu]) }
  end

  def project_type_label(project)
    content_tag(:span, friendly_type_name(project.project_type_name), class: 'label label-primary')
  end

  def project_status_label(project, state = nil, **html_options)
    state ||= project.current_state

    default_options = {
      class: ['label', STATE_LABEL_CLASSES.fetch(state.id, 'label-default')]
    }

    content_tag(:span, state.name, html_options.merge(default_options))
  end

  def odr_reference(project)
    return unless project&.project_type&.name&.in? %w[Application EOI]

    content_tag(:small, "ODR Reference: #{project.id}")
  end

  def transition_button(project, state, **options)
    i18n_scope   = %i[helpers submit workflow/project_state]
    i18n_key     = state.id.downcase.to_sym
    i18n_default = state.id

    button_options = {
      class: ['btn', STATE_TRANSITION_BUTTON_CLASSES.fetch(state.id, 'btn-default')]
    }.merge(options)

    unless project.can_transition_to?(state)
      title = project.textual_reasons_not_to_transition_to(state)
      button_options.merge!(disabled: 'disabled', title: title)
    end

    icon = STATE_TRANSITION_BUTTON_ICONS[state.id]
    text = t(i18n_key, scope: i18n_scope, default: i18n_default)
    text = bootstrap_icon_tag(icon) + " #{text}" if icon

    button_tag(text, button_options)
  end

  def approval_button_message(status)
    if status.nil?
      'INCOMPLETE'
    else
      status ? 'APPROVED' : 'DECLINED'
    end
  end

  def approval_button_style(status)
    if status.nil?
      'warning'
    else
      status ? 'success' : 'danger'
    end
  end

  def complete_approval_button_style(status)
    case status
    when 'Approved'
      'success'
    when 'Rejected'
      'danger'
    when 'Pending'
      'warning'
    when 'Delegate Approval'
      'warning'
    when 'Expired'
      'black'
    else
      'white'
    end
  end

  def approval_status_msg(project, status, user, options = {})
    return unless !status.nil? || (user.odr? && project.current_state.id == 'SUBMITTED')

    style = approval_button_style(status)
    text  = approval_button_message(status)

    content_tag(:span, text, options.merge(class: "label label-#{style}"))
  end

  def mortality_fields?
    # new project condition
    @project.nil? && (params[:controller] == 'projects' &&
      params[:action] == 'edit' && params[:section] == 'legal') ||
      # existing project condition
      mortality_data_sources? && (params[:controller] == 'projects' &&
        params[:action] == 'edit' && params[:section] == 'legal')
  end

  def mortality_data_sources?
    (['Deaths Gold Standard', 'Death Transaction'] & @project.datasets.map(&:name)).present?
  end

  def team_delegate_user?(project)
    project.team.delegate_users.include? current_user
  end

  def project_type_text
    @project.clone_of.presence ? 'New Project (Cloned)' : 'New Project'
  end

  def show_legal?
    controller_actions(%w[new create]) && @full_form ||
      (controller_actions(%w[edit]) && params[:section] == 'legal') && @full_form
  end

  def show_all?
    controller_actions(%w[new create]) && @full_form ||
      (controller_actions(%w[edit]) && params[:section] == 'all') && @full_form
  end

  def show_legal_gateway?
    (controller_actions(%w[new create]) && @full_form) || (mortality_fields? && @full_form)
  end

  def controller_actions(actions)
    params[:controller] == 'projects' && actions.include?(params[:action])
  end

  def senior_users_for_project
    @project.team&.users&.active&.applicants&.map { |member| [member.full_name, member.id] }
  end

  def available_owners
    @project.team&.users&.applicants&.map do |member|
      [member.full_name, member.id]
    end
  end

  def project_attachment_header
    params[:name] == 'Data End Users' ? 'Upload file' : 'Add an attachment to '
  end

  def project_owner_text
    owner = @project.owner
    text = " (Applicant)"
    return text if current_user != owner

    text << ' (You)'
    text
  end

  # TODO: tidy up
  def project_team_users
    @project.team.users.reject do |user|
      user == @project.owner || (@project.team.delegate_users.include? user)
    end
  end

  def projects_for_user
    return delegate_user_projects if @user.role?(TeamRole.find_by(name: 'MBIS Delegate'))

    @user.projects
  end

  def delegate_user_projects
    return unless
      @user.grants.any? { |grant| grant.roleable == TeamRole.find_by(name: 'MBIS Delegate') }

    projects = []
    @user.grants.where(roleable: TeamRole.find_by(name: 'MBIS Delegate')).each do |grant|
      projects += grant.team.projects
    end

    projects
  end

  def project_dataset_selection
    @project.project_type.available_datasets.map do |dataset|
      [dataset.name, dataset.id, { 'data-terms' => dataset.terms }]
    end
  end

  def dataset_filter_options(name)
    dataset_values = @project.datasets.map { |d| [d.name, d.name.gsub(' ', '')] }
    dataset_values.unshift(['All Datasets', 'ALL'])
    select_tag(name, options_for_select(dataset_values),
               class: 'form-control', name: 'select-project-dataset')
  end

  def table_filter_options(name)
    return unless @project.datasets.any? { |d| d.dataset_type.name ==  'table_specification' }

    tables = @project.datasets.flat_map do |dataset|
      dataset.dataset_versions.last.table_nodes
    end
    table_values = tables.map(&:name).unshift(['All Tables', 'ALL'])
    content_tag(:div, class: 'row') do
      content_tag(:div, class: 'col-md-12') do
        select_tag(name, options_for_select(table_values),
                   class: 'form-control', name: 'select-project-table')
      end
    end
  end

  def requires_modal_comments_for_transition_to?(state)
    %w[REJECTED DPIA_REVIEW DPIA_MODERATION DPIA_REJECTED CONTRACT_REJECTED].include?(state.id)
  end

  def application_manager_project_type?(project)
    ProjectType.odr.include? project.project_type
  end

  def friendly_type_name(type)
    I18n.t(:project_types)[type.downcase.to_sym].presence || type
  end
end
