Github::Plan = Struct.new(:id, :listing_id, :title, :private_repositories, keyword_init: true) do
  def self.find(id)
    all.find { |plan| plan.id == id } || all.first
  end

  def self.organization
    all.find { |plan| plan.id == 6131 }
  end

  def self.user
    all.find { |plan| plan.id == 6132 }
  end

  def self.all
    @all ||= [
      # These plans are retired
      Github::Plan.new(id: 0, listing_id: nil, title: 'Trial', private_repositories: true),
      Github::Plan.new(id: 4756, listing_id: nil, title: 'Free', private_repositories: false),
      Github::Plan.new(id: 5736, listing_id: 5, title: 'Early Bird Special', private_repositories: true),
      Github::Plan.new(id: 4978, listing_id: 2, title: 'Individual', private_repositories: true),
      Github::Plan.new(id: 4979, listing_id: 3, title: 'Organization', private_repositories: true),

      # These are the active plans
      Github::Plan.new(id: 4980, listing_id: 4, title: 'Open Source', private_repositories: false),
      Github::Plan.new(id: 6131, listing_id: 6, title: 'Professional', private_repositories: true),
      Github::Plan.new(id: 6132, listing_id: 7, title: 'Individual', private_repositories: true)
    ]
  end

  def private_repositories?
    private_repositories.present? && private_repositories
  end
end
