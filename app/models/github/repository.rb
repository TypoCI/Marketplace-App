class Github::Repository
  include ActiveModel::Conversion

  attr_accessor :github_data

  delegate :full_name, :name, :fork, :archived, :language, :private, to: :github_data

  def initialize(github_data)
    @github_data = github_data
  end
end
