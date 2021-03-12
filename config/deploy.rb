# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'cgthornt.com'
set :repo_url, 'git@github.com:cgthornt/cgthornt.com.git'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/christopher/cgthornt.com'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}
set :linked_dirs, %w{ node_modules content/data content/images content/apps static }

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

  desc 'Restart application'
  task :restart do
    on roles(:app) do
      invoke 'deploy:stop'
      invoke 'deploy:start'
    end
  end

  task :stop do
    on roles(:app) do
      execute "cd #{release_path} && ./app.sh stop"
    end
  end

  task :start do
    on roles(:app) do
      execute "cd #{release_path} && ./app.sh start"
    end
  end


  task :install_npm do
    on roles(:app)do
      execute "cd #{release_path} && npm install --production"
    end
  end

  after :publishing, :install_npm
  after :publishing, :restart
  after :finished, :cleanup

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

namespace :db do
  task :backup do
    on roles(:db) do
      invoke 'deploy:stop'
      backup_dir  = "#{shared_path}/content/data/backups"
      backup_file = "#{backup_dir}/#{release_timestamp}.db"
      execute "mkdir -p #{backup_dir}"
      execute "cp #{shared_path}/content/data/ghost.db #{backup_file}"
      invoke 'deploy:start'
    end
  end


end
