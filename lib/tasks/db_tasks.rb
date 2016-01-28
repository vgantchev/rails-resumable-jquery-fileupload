namespace :db do
  desc "Create, migrate and seed db" 
  task :create_and_seed do
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke
  end

end