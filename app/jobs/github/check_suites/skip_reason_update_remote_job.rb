class Github::CheckSuites::SkipReasonUpdateRemoteJob < ApplicationJob
  queue_as :github__check_suites__skip_reason_update_remote

  def perform(github_check_suite)
    @github_check_suite = github_check_suite

    @created_check_run = install_service.create_check_run(
      @github_check_suite.repository_full_name,
      check_run_name,
      @github_check_suite.head_sha,
      {
        conclusion: @github_check_suite.conclusion,
        status: @github_check_suite.status,
        external_id: @github_check_suite.to_gid_param,
        details_url: github_change_plan_url,
        output: {
          title: output_title,
          summary: output_summary
        }
      }
    )
    @github_check_suite.update!(check_run_id: @created_check_run.id)
  end

  private

  def github_change_plan_url
    Rails.application.routes.url_helpers.github_change_plan_url(upgrade_plan_id: install.upgrade_plan.listing_id,
                                                                account_id: install.account_id)
  end

  def output_title
    I18n.t("output_title", scope: ["jobs", self.class.name.underscore])
  end

  def output_summary
    I18n.t("output_summary", scope: ["jobs", self.class.name.underscore],
                             github_change_plan_url: github_change_plan_url)
  end

  def check_run_name
    I18n.t("check_run_name.#{Rails.env}", scope: ["jobs", self.class.name.underscore])
  end

  def install
    @install ||= @github_check_suite.install
  end

  def install_service
    @install_service ||= Github::InstallService.new(install)
  end
end
