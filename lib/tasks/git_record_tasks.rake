namespace :git_record do
  desc 'Build static routes for deployment'
  task build: :environment do
    # TODO: collect all routes annotated as static
  end
end