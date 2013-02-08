
require 'Phlatboyz/PhlatTool.rb'

module PhlatScript

  class HelpTool < PhlatTool
    def select
      help_file = Sketchup.find_support_file "help.html", "Tools/Phlatboyz/html"
      if (help_file)
        # Open the help_file in a web browser
        UI.openURL "file://" + help_file
      else
        UI.messagebox "Failed to open help file"
      end
    end

  end
end