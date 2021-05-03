namespace :github do
  namespace :repositories do
    desc "Analyse popular projects & return their results"
    task analyse_popular_projects: :environment do
      [
        # Ruby
        # 'teamcapybara/capybara',
        # 'thepracticaldev/dev.to',
        # 'mperham/sidekiq',
        # 'Homebrew/homebrew-cask',
        # 'tootsuite/mastodon',
        # 'ruby/ruby',
        # 'rails/rails',
        # 'bundler/bundler',
        # 'octokit/octokit.rb',
        # 'heartcombo/devise',
        # 'kaminari/kaminari',
        # 'jhawthorn/discard',
        # 'aasm/aasm',
        # 'rspec/rspec-rails',
        # 'thoughtbot/factory_bot',
        # 'rubocop-hq/rubocop',
        # 'whitesmith/rubycritic',
        # 'activeadmin/activeadmin',
        # 'heartcombo/simple_form',
        # 'drapergem/draper',
        # 'hanami/hanami',
        # 'alphagov/e-petitions',
        # 'alphagov/search-admin',
        "mikerogers0/mikerogersio"

        # JavaScript
        # 'alyssaxuu/flowy',
        # 'sveltejs/svelte',
        # 'globalizejs/globalize',
        # 'angular/angular.js',
        # 'alphagov/govuk-design-system',

        # CSS
        # 'mmistakes/minimal-mistakes',
        # 'twbs/bootstrap',
        # 'tailwindcss/tailwindcss',

        # PHP
        # 'monicahq/monica',
        # 'laravel/framework',
        # 'gothinkster/cakephp-realworld-example-app'

        # Vue
        # 'tuandm/laravue',
        # 'vuejs/vue',

        # V
        # 'v-community/v_by_example',

        # Elixir
        # 'elixirschool/elixirschool',

        # TypeScript
        # 'gatsbyjs/gatsby'
        # 'react-navigation/react-navigation',
        # 'microsoft/azure-pipelines-tasks',
        # 'highcharts/highcharts',
        # 'aws/aws-cdk',
        # 'desktop/desktop',
        # 'electron-userland/electron-builder',
        # 'streamich/react-use',
        # 'OfficeDev/office-ui-fabric-react',
        # 'dotansimha/graphql-code-generator',
        # 'ReactiveX/rxjs',
        # 'swimlane/ngx-charts',
        # 'callstack/react-native-paper'

        # Misc
        # 'tensorflow/tensorflow',
        # 'github/gitignore'
        # 'torvalds/linux',
        # 'freeCodeCamp/freeCodeCamp',
        # 'facebook/react',
        # 'ohmyzsh/ohmyzsh',
        # 'flutter/flutter',
        # 'Azure/azure-quickstart-templates', # This one is massive.
        # 'cli/cli',
        # 'bitcoin/bitcoin',
        # 'localstack/localstack',
        # 'JedWatson/react-select'

        #  Python
        # 'PyTorchLightning/pytorch-lightning'

        # Java
        # 'retroheim/Minecraft-JTLoader'

        # Brazilian
        # 'educodar/web'

        # C
        # 'videolan/vlc'
      ].each do |repository|
        started_at = Time.zone.now
        analysis = Github::Repositories::AnalysisService.new(repository)
        analysis.perform!
        puts "Analysis took: (#{(Time.zone.now - started_at).to_i})"
      end
    end
  end
end
