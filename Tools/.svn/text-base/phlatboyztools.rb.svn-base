#-----------------------------------------------------------------------------
# Name        :   PhlatBoyzTools
# Description :   A set of tools for marking up Phlatland Sketchup drawings and generating Phlatprinter g-code.
# Menu Item   :   
# Context Menu:   
# Usage       :   
# Date        :   30 Mar 2009
# Type        :   
# Version     :   0.918
#-----------------------------------------------------------------------------

require('sketchup.rb')

class PhlatScriptExtention < SketchupExtension 
  def initialize
    super 'Phlatboyz Tools', 'Phlatboyz/Phlatscript.rb' 
    self.description = 'A set of tools for marking up Phlatland Sketchup drawings and generating Phlatprinter g-code.' 
    self.version = 'trunk' 
    self.creator = 'Phlatboyz' 
    self.copyright = '03/30/2009, Phlatboyz' 
  end

  def load
    require 'Phlatboyz/Phlatscript.rb'
    PhlatScript.load
  end 

end
$PhlatScriptExtension = PhlatScriptExtention.new
Sketchup.register_extension($PhlatScriptExtension, true)
