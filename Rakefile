# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

require 'byebug'

RuboCop::RakeTask.new do |task|
  task.requires << 'rubocop-performance'
end

Rake::TestTask.new do |t|
  t.pattern = 'test/**/*.rb'
  t.verbose = true
  t.warning = true
end

namespace :test do
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['test'].invoke
  end
end

task(:doc_stats) { ruby '-S yard stats' }
task default: %i[test doc_stats rubocop]

Dir.glob(File.join('tasks', '**', '*.rake')).each { |r| import(r) }
