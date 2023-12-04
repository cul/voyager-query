# frozen_string_literal: true

namespace :voyager_query do
  namespace :setup do
    desc 'Set up application config files (from template files)'
    task :config_files do # rubocop:disable Rails/RakeEnvironment
      config_template_dir = Rails.root.join('config/templates')
      config_dir = Rails.root.join('config')
      Dir.foreach(config_template_dir) do |entry|
        next unless entry.end_with?('.yml')

        src_path = File.join(config_template_dir, entry)
        dst_path = File.join(config_dir, entry.gsub('.template', ''))
        if File.exist?(dst_path)
          puts "#{Rainbow("File already exists (skipping): #{dst_path}").blue.bright}\n"
        else
          FileUtils.cp(src_path, dst_path)
          puts Rainbow("Created file at: #{dst_path}").green
        end
      end
    end
  end
end
