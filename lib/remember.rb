module Redcar
  class Remember

    class Memory

      attr_reader :project, :storage

      def initialize(project)
        @project = project
        @storage = Plugin::BaseStorage.new "#{project.path}/.redcar/storage", 'remember'
      end

      def shell(window=self.project.window)
        window.controller.shell
      end

      def last_bounds
        return unless storage["bounds"]
        rect = storage["bounds"]
        Java::OrgEclipseSwtGraphics::Rectangle.new(
          rect["x"], rect["y"], rect["width"], rect["height"])
      end

      def save(window)
        self.last_bounds = shell(window).getBounds()
        storage.save
      end

      def recall
        last_bounds.tap do |bounds|
          shell.setBounds(bounds) if bounds
        end
        self
      end

      private

      def last_bounds=(rect)
        storage["bounds"] = {
          "x"      => rect.x,
          "y"      => rect.y,
          "width"  => rect.width,
          "height" => rect.height
        }
      end
    end

    def self.memories
      @memories ||= []
    end

    def self.loaded
      # puts "LOADED REMEMBER"
    end

    def self.project_loaded(project)
      memories << Memory.new(project).recall
    end

    def self.project_closed(project, window)
      memories.find_all { |m| m.project == project }.each { |m| m.save window }
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

  end
end
