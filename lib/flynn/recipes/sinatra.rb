require 'fileutils'

module Flynn
  module Recipes
    class Sinatra < RvmBase
      def create(app_name, options=[])
        @app_name = app_name
        RVM.gemset_create app_name
        RVM.gemset_use! app_name
        puts "Creating #{app_name}"
        FileUtils.mkdir(app_name)
        create_gemfile
        create_config_ru
        create_app_rb
        create_standard_directories
        create_project_rvmrc(app_name)
        system("rvm rvmrc trust")
        inside(@app_name) do
          system("bundle install")
        end
      end

      private
        def inside(app_name)
          current_dir = Dir.pwd
          Dir.chdir(app_name)
          yield
          Dir.chdir(current_dir)
        end

        def create_gemfile
          inside(@app_name) do
            File.open("Gemfile", 'w') {|f| f.write(gemfile) }
          end
        end

        def create_config_ru
          inside(@app_name) do
            File.open("config.ru", 'w') {|f| f.write(config_ru) }
          end
        end

        def create_app_rb
          inside(@app_name) do
            File.open("app.rb", 'w') {|f| f.write(app_rb) }
          end
        end

        def create_standard_directories
          inside(@app_name) do
            FileUtils.mkdir_p('views')
            FileUtils.mkdir_p('public')
          end
        end

        def config_ru
          @config_ru ||= <<-EOS
          require "app"

          run Sinatra::Application
          EOS
        end

        def app_rb
          @config_ru ||= <<-EOS
          get '/' do
            "Hello from Flynn"
          end
          EOS
        end

        def gemfile
          @gemfile ||= <<-EOS
            # A sinatra gemfile
            source "http://rubygems.org"

            gem 'sinatra'
            gem 'haml'
            gem 'sass'
          EOS
        end
    end
  end
end