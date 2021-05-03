class Github::CheckSuites::UpdateRemoteJob < ApplicationJob
  queue_as :github__check_suites__update_remote
  attr_accessor :github_check_suite

  def perform(github_check_suite)
    @github_check_suite = github_check_suite

    create_check_run_on_github!
    add_remaining_annotations_to_check_run_on_github!
  end

  def create_check_run_on_github!
    @created_check_run = install_service.create_check_run(
      @github_check_suite.repository_full_name,
      check_run_name,
      @github_check_suite.head_sha,
      {
        conclusion: @github_check_suite.conclusion,
        status: @github_check_suite.status,
        external_id: @github_check_suite.to_gid_param,
        started_at: @github_check_suite.started_at.iso8601,
        completed_at: @github_check_suite.completed_at.iso8601,
        details_url: Rails.application.routes.url_helpers.documentation_url,
        output: {
          annotations: annotations[0..49],
          title: output_title,
          summary: output_summary
        }
      }
    )
    @github_check_suite.update!(check_run_id: @created_check_run.id)
  end

  def add_remaining_annotations_to_check_run_on_github!
    (annotations[50..] || []).in_groups_of(50, false).each_with_index do |annotations_group, _index|
      install_service.update_check_run(
        @github_check_suite.repository_full_name,
        @github_check_suite.check_run_id,
        {
          output: {
            annotations: annotations_group,
            title: output_title,
            summary: output_summary
          }
        }
      )
    end
  end

  def check_run_name
    I18n.t("check_run_name.#{Rails.env}", scope: ["jobs", self.class.name.underscore])
  end

  def output_title
    if @github_check_suite.custom_configuration_present_and_invalid?
      I18n.t("output_title.invalid_custom_configuration", scope: ["jobs", self.class.name.underscore])
    else
      I18n.t("output_title", count: @github_check_suite.spelling_mistakes_count,
                             scope: ["jobs", self.class.name.underscore])
    end
  end

  def output_summary
    [output_summary_header, output_summary_actions, output_summary_body].join("\n\n")
  end

  private

  def output_summary_header
    I18n.t(
      "output_summary_header",
      scope: ["jobs", self.class.name.underscore]
    )
  end

  def output_summary_body
    I18n.t(
      "output_summary_body",
      count: @github_check_suite.spelling_mistakes_count,
      output_files_count: output_files_count,
      scope: ["jobs", self.class.name.underscore]
    )
  end

  def output_files_count
    I18n.t("output_files_count", count: @github_check_suite.files_analysed_count,
                                 scope: ["jobs", self.class.name.underscore])
  end

  def output_summary_actions
    actions = []

    if @github_check_suite.custom_configuration_present_and_invalid?
      actions << I18n.t(
        "output_summary_actions.invalid_custom_configuration",
        documentation_url: Rails.application.routes.url_helpers.documentation_url,
        scope: ["jobs", self.class.name.underscore]
      )
    end

    actions << I18n.t(
      "output_summary_actions.feedback",
      contact_url: Rails.application.routes.url_helpers.contact_url,
      scope: ["jobs", self.class.name.underscore]
    )

    actions.join("\n")
  end

  def annotations
    @github_check_suite.annotations
  end

  def install
    @install ||= @github_check_suite.install
  end

  def install_service
    @install_service ||= Github::InstallService.new(install)
  end
end
