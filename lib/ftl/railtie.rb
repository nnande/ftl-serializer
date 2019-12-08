# frozen_string_literal: true

require "rails/railtie"

module FTL
  class Railtie < Rails::Railtie
    # Watch serializer files for changes in dev, so we can reload them with any new code.
    initializer "ftl.add_watchable_files" do |app|
      reload_paths = FTL::Configuration.serializer_paths.reduce({}) do |memo, dir|
        app_dir = File.join(app.root, dir)
        memo[app_dir] = ['rb']
        memo
      end

      ftl_reloader = app.config.file_watcher.new([], reload_paths) do
        FTL::Configuration.serializer_paths.map do |path|
          Dir.glob("#{path}/**/*.rb").each do |file|
            begin
              if Rails.env.development? || Rails.env.test?
                load file
              else
                require file
              end
            rescue => e
              warn "can't load '#{file}' file (#{e.message})!"
            end
          end
        end

        FTL::Serializer.bootstrap!
      end

      app.reloaders << ftl_reloader

      # Reloads serializers on boot / when they change
      config.to_prepare do
        ftl_reloader.execute
      end

      config.after_initialize do
        if defined?(Spring)
          Spring.after_fork do
            ftl_reloader.execute
          end
        end
      end
    end
  end
end
