# frozen_string_literal: true

namespace :voyager_query do
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:rspec) do |spec|
    spec.rspec_opts ||= []
    spec.rspec_opts << '--backtrace' if ENV['CI']
  end

  require 'rubocop/rake_task'
  desc 'Run style checker'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.requires << 'rubocop-rspec'
    task.fail_on_error = true
  end

  desc 'CI build without rubocop'
  task ci_nocop: ['voyager_query:setup:config_files', :environment, 'voyager_query:ci_specs']

  desc 'CI build with Rubocop validation'
  task ci: ['voyager_query:setup:config_files', :environment, 'voyager_query:rubocop', 'voyager_query:ci_specs']

  desc 'CI build just running specs'
  task ci_specs: :environment do
    rspec_system_exit_failure_exception = nil

    duration = Benchmark.realtime do
      ENV['RAILS_ENV'] = 'test'
      Rails.env = ENV['RAILS_ENV']

      begin
        Rake::Task['voyager_query:rspec'].invoke
      rescue SystemExit => e
        rspec_system_exit_failure_exception = e
      end
    end
    puts "\nCI run finished in #{duration} seconds."
    # If present, re-raise any caught exit exception after CI duration display,
    # so we can still display the run time even when a system exception comes up.
    # This exception triggers an exit call with the original error code sent out by rspec failure.
    raise rspec_system_exit_failure_exception unless rspec_system_exit_failure_exception.nil?
  end
rescue LoadError => e
  # Be prepared to rescue so that this rake file can exist in environments
  # where RSpec is unavailable (i.e. production environments).
  puts '[Warning] Exception creating ci/rspec rake tasks. '\
       'This message can be ignored in environments that intentionally do not pull '\
       'in certain development/test environment gems (i.e. production environments).'
  puts e
end
