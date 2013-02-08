

require ('Phlatboyz/Phlatscript.rb')
require 'Win32API'

module PhlatScript

  class ProgressDialog

    def initialize(caption, steps)
      #Win32API.new( dllname, procname, importArray, export )
      @dlg = Win32API.new("C:/Program Files/Google/Google SketchUp 7/Tools/Phlatboyz/PhlatDLL.dll","ProgressDlg",['P', 'L'],"V")
      @step = Win32API.new("C:/Program Files/Google/Google SketchUp 7/Tools/Phlatboyz/PhlatDLL.dll","ProgressStep",['L'],"V")
      @close = Win32API.new("C:/Program Files/Google/Google SketchUp 7/Tools/Phlatboyz//PhlatDLL.dll","ProgressClose",[],"V")
      @dlg.call(caption, steps)
    end
 
    def step
      @step.call(0)
    end

    def position=(position)
      @step.call(position)
    end

    def close
      @close.call
    end

  end

end