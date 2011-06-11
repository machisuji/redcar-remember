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
      puts "opened #{project.inspect}"
      puts "project path: #{project.path}"
      shell = project.window.controller.shell
      shell.setLocation(0, 0)
    end

    def self.project_closed(project, window)
      pos = window.controller.shell.getLocation()
      puts "closed #{project.inspect}"
      puts "last position: #{pos.x}x#{pos.y}"
    end

    class ApplicationEventHandler
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
