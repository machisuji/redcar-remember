module Redcar
  class Remember

    def self.storage(path=nil)
      if path
        @storage ||= Plugin::BaseStorage.new "#{path}/.redcar", 'remember'
      end
      @storage
    end

    def self.save_settings(bounds)
      self.last_bounds = bounds
      storage.save
    end

    def self.last_bounds=(rect)
      b = storage["bounds"] = {}
      b["x"] = rect.x
      b["y"] = rect.y
      b["width"] = rect.width
      b["height"] = rect.height
      b
    end

    def self.last_bounds
      return unless storage["bounds"]
      rect = storage["bounds"]
      Java::OrgEclipseSwtGraphics::Rectangle.new(
        rect["x"], rect["y"], rect["width"], rect["height"])
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
      # puts "LOADED REMEMBER"
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
      last_bounds.tap do |bounds|
        restore_bounds(project.window, bounds) if bounds
      end
    end

    def self.project_closed(project, window)
      shell = window.controller.shell
      save_settings(shell.getBounds())
    end

    def self.restore_bounds(window, bounds)
      shell = window.controller.shell
      shell.setBounds(bounds)
    end

    class ApplicationEventHandler
      def window_focus(win)
        # if Remember.first_call
          # For everything to look smooth I'd have to set the window bounds
          # here, however at this point I cannot get the current path,
          # which I need to save settings on a per-project basis.
          #
          # I don't want to mess with other plugins (redcar.rb) for now
          # to change this.
          #
          # shell = Redcar.app.focussed_window.controller.shell
          # shell.setLocation(0, 0)
        # end
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
