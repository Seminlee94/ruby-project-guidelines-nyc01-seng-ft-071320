require_relative 'config/environment'
require 'sinatra/activerecord/rake'
require 'pry'
require_all "app"

desc 'starts a console'
task :console do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  ActiveRecord::Base.logger.level = 0
  Pry.start
end
