namespace :dictionaries do
  desc 'Combines all the custom dictionaries into a single big one'
  task combine_custom: :environment do
    puts 'Building combined dictionary'
    Dictionaries::CombineService.new.run!
  end
end

Rake::Task['assets:precompile'].enhance ['dictionaries:combine_custom']
