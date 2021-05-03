class Github::InstallsController < AuthenticatedController
  def index
    @installs = current_user.installs
  end

  def show
    @install = current_user.installs.find_by!(install_id: params[:id])

    @current_page = params[:page]&.to_i || 1
    @total_pages = @install.repositories_count

    @list_repositories = current_user.list_repositories(@install.install_id, page: @current_page)
    @repositories = (@list_repositories.repositories || []).collect { |repo| Github::Repository.new(repo) }
  end
end
