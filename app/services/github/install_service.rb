class Github::InstallService
  def initialize(install)
    @install = install
    @app_id = install.app_id
    @install_id = install.install_id
    @account_id = install.account_id
  end

  def marketplace_plan
    github_app_service_client.plan_for_account(@account_id)
  rescue Octokit::NotFound
    {}
  end

  def list_repositories
    options = {
      accept: Octokit::Preview::PREVIEW_TYPES[:integrations]
    }

    client.list_app_installation_repositories(options)&.repositories || []
  end

  def list_open_pull_requests(repo)
    options = {
      status: :open,
      accept: Octokit::Preview::PREVIEW_TYPES[:integrations]
    }
    client.pull_requests(repo, options)
  end

  def client
    @client ||= Octokit::Client.new(bearer_token: installation_token, auto_paginate: false)
  end

  def create_status(full_name, head_sha, status, options)
    options.merge!(
      accept: Octokit::Preview::PREVIEW_TYPES[:checks]
    )

    client.create_status(full_name, head_sha, status, options)
  end

  def create_check_run(repo, context, head_sha, options = {})
    options.merge!(
      accept: Octokit::Preview::PREVIEW_TYPES[:checks]
    )

    client.create_check_run(repo, context, head_sha, options)
  end

  def update_check_run(repo, id, options = {})
    options.merge!(
      accept: Octokit::Preview::PREVIEW_TYPES[:checks]
    )

    client.update_check_run(repo, id, options)
  end

  def get_pull_request(repo, pull_request_number)
    options = {
      accept: Octokit::Preview::PREVIEW_TYPES[:integrations]
    }
    client.pull(repo, pull_request_number, options)
  end

  def get_pull_request_commits(repo, pull_request_number)
    options = {
      per_page: 100,
      accept: Octokit::Preview::PREVIEW_TYPES[:integrations]
    }

    client.pull_request_commits(repo, pull_request_number, options)
  end

  def get_pull_request_files(repo, pull_request_number)
    options = {
      per_page: 100,
      accept: Octokit::Preview::PREVIEW_TYPES[:integrations]
    }

    client.pull_request_files(repo, pull_request_number, options)
  end

  delegate :commit, to: :client

  delegate :compare, to: :client

  def get_file_contents(repo, filename, head_sha)
    contents = client.contents(repo, path: filename, ref: head_sha)
    Base64.decode64(contents[:content])
  end

  def installation
    options = {
      accept: Octokit::Preview::PREVIEW_TYPES[:integrations]
    }

    github_app_service_client.installation(@install_id, options)
  end

  private

  def installation_token
    options = {
      accept: Octokit::Preview::PREVIEW_TYPES[:integrations]
    }
    @installation_token = github_app_service_client.create_app_installation_access_token(@install_id, options)[:token]
  end

  def github_app_service_client
    @github_app_service_client ||= Github::AppService.new.client
  end
end
