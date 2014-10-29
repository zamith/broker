lock '3.2.1'

set :repo_url, 'git@github.com:zamith/broker.git'

server '162.243.69.77', user: 'deploy', roles: %w{web app db}, primary: true

set :format, :pretty
set :log_level, :info
set :pty, false
set :default_shell, 'bash -l'
set :keep_releases, 3
set :bundle_flags, '--deployment'
set :bundle_without, %w{development test deploy}.join(' ')

set :linked_files, %w{config/database.yml .env}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system public/uploads public/dists}

set :whenever_identifier, ->{ "#{fetch(:application)}_#{fetch(:stage)}" }

namespace :deploy do
  after :publishing, :restart
end
