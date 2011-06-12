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

    def self.project_loaded(project)
      memories << Memory.new(project).recall
    end

    def self.project_closed(project, window)
      memories.find_all { |m| m.project == project }.each { |m| m.save window }
    end

  end
end
