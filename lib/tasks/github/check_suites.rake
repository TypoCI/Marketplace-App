namespace :github do
  namespace :check_suites do
    desc 'Reprocesses all the Check Suites with spelling mistakes from the last 24h'
    task reprocess_typos_from_last_24h: :environment do
      Github::CheckSuite.where(created_at: [24.hours.ago..Time.zone.now],
                               spelling_mistakes_count: [1..Float::INFINITY]).find_each do |github_check_suite|
        Github::CheckSuites::RequestedJob.perform_later(github_check_suite)
      end
    end
  end
end
