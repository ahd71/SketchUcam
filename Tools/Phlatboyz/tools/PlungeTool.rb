
require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'
require 'Phlatboyz/Tools/PlungeCut.rb'

module PhlatScript

  class PlungeTool < PhlatTool
    @depth = 100
    
    def reset(view)
      Sketchup.vcb_label = "Plunge Depth %"
      Sketchup.vcb_value = "100"
      super
    end
    
    def onMouseMove(flags, x, y, view)
      if @ip.pick(view, x, y)
        view.invalidate
      end
    end
    
    def onLButtonDown(flags, x, y, view)
      PlungeCut.cut(@ip.position)
      reset(view)
    end

    def draw(view)
      PlungeCut.preview(view, @ip.position)
    end

    def cut_class
      return PlungeCut
    end

    def statusText
      return "Select plunge point"
    end

  end

end