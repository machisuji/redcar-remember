module Redcar
  class Remember

    def self.storage(path=nil)
      if path
        @storage ||= Plugin::BaseStorage.new path, 'remember'
      end
      @storage
    end

    def self.menus
      Menu::Builder.build do
        sub_menu "Plugins" do
          sub_menu "Settings", :priority => 139 do
            item "Settings", Settings
          end
        end
      end
    end

    def self.loaded
      puts "LOADED REMEMBER"
      puts "Dir: #{File.expand_path(File.dirname(__FILE__))}"
      puts "userdir: #{Redcar.user_dir}"
      # Redcar::Plugin::BaseStorage.new ".redcar/settings.yml", "remember"
    end

    def self.first_call
      unless @not_first
        @not_first = true
      else
        false
      end
    end

    def self.project_loaded(project)
      storage(project.path)
      puts "Remember.self.project_loaded"
      puts "project path: #{project.path}"
      puts "project: #{project.inspect}"
      shell = project.window.controller.shell
      shell.setLocation(0, 0)
    end

    class ApplicationEventHandler

      def tab_focus(tab)
        puts "tab_focus: #{tab.inspect}"
      end

      def tab_close(tab)
        puts "tab_close: #{tab.inspect}"
      end

      def window_close(win)
        puts "window_close: #{win.inspect}"
      end

      def application_focus(app)
        puts "!!! app_focus: #{app.to_s}"
      end

      def application_open(app)
        puts "!!! app_open: #{app.to_s}"
      end

      def application_close(app)
        puts "app_close: #{app.to_s}"
        shell = Redcar.app.focussed_window.controller.shell
        pos = shell.getLocation()
        puts "remember location: #{pos.x}x#{pos.y}"
      end

      def window_focus(win)
        puts "window_focus: #{win.inspect}"
        if Remember.first_call
          # for everything to look smooth I'd have to set the window bounds
          # here, however at this point I cannot get the current path,
          # which I need to save settings on a per-project basis.
          #
          # I don't want to mess with other plugins (redcar.rb) for now
          # to change this.
          #
          # shell = Redcar.app.focussed_window.controller.shell
          # shell.setLocation(0, 0)
        end
      end

      def window_open(win)
        puts "!!! window_open: #{win.inspect}"
      end

      def project_loaded(project)
        puts "Handler#project_loaded"
      end
    end

    def project_loaded(project)
      puts "Remember#project_loaded"
    end

    def self.application_event_handler
      ApplicationEventHandler.new
    end

    class Settings < Redcar::Command
      def execute
        Application::Dialog.message_box("Settings")
      end
    end

  end
end
