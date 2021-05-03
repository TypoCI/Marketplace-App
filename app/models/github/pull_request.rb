# Takes the hash from GitHub, coverts it into an object we can work with consistently.
class Github::PullRequest
  def initialize(raw_data)
    @raw_data = raw_data.with_indifferent_access
  end

  def to_h
    {
      url: @raw_data[:url],
      number: @raw_data[:number],
      head: head,
      base: base
    }
  end

  def url
    @raw_data[:url]
  end

  def number
    @raw_data[:number]
  end

  def analysable?(repository_full_name)
    base_repo_full_name == repository_full_name
  end

  def base_repo_full_name
    base[:repo][:url].sub('https://api.github.com/repos/', '')
  end

  private

  def head
    {
      ref: @raw_data[:head][:ref],
      sha: @raw_data[:head][:sha],
      repo: {
        id: @raw_data[:head][:repo][:id],
        url: @raw_data[:head][:repo][:url]
      }
    }
  end

  def base
    {
      ref: @raw_data[:base][:ref],
      sha: @raw_data[:base][:sha],
      repo: {
        id: @raw_data[:base][:repo][:id],
        url: @raw_data[:base][:repo][:url]
      }
    }
  end
end
