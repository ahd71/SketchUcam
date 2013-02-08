

require 'Phlatboyz/PhlatCut.rb'

module PhlatScript

  class PlungeCut < PhlatCut

    attr_accessor :edge

    def PlungeCut.radius
      return (Sketchup.active_model.get_attribute Dict_name, Dict_bit_diameter, Default_bit_diameter) / 2.0
    end

    def PlungeCut.cut_key
      return Key_plunge_cut
    end

    def PlungeCut.load(edge)
      return self.new(edge)
    end

    def PlungeCut.cut(pt)
      plungecut = PlungeCut.new
      plungecut.cut(pt)
      return plungecut
    end

    def PlungeCut.preview(view, pt)
      view.drawing_color = Color_plunge_cut
      view.line_width = 3.0
      begin
        n_angles = 16
        delta = 360.0 / n_angles
        dr = Math::PI/180.0
        angle = 0.0
        pt_arr = Array.new
        for i in 0..n_angles
          radians = angle * dr
          pt_arr << Geom::Point3d.new(pt.x + radius*Math.sin(radians), pt.y + radius*Math.cos(radians), 0)
          angle += delta
        end
        status = view.draw_polyline(pt_arr)
      rescue
        UI.messagebox "Exception in PlungeTool.draw_geometry "+$!
      end
    end

    def initialize(edge=nil)
      super()
      @edge = edge
    end

    def cut(pt)
      Sketchup.active_model.start_operation "Cutting Plunge", true
      entities = Sketchup.active_model.entities
      end_pt = Geom::Point3d.new(pt.x + PlungeCut.radius, pt.y, 0)
      newedges = entities.add_edges(pt, end_pt)
      vectz = Geom::Vector3d.new(0,0,-1)
      circleInner = entities.add_circle(pt, vectz, PlungeCut.radius, 12)
      entities.add_face(circleInner)
      newedges[0].material = Color_plunge_cut
      newedges[0].set_attribute Dict_name, Dict_edge_type, Key_plunge_cut
      @edge = newedges[0]
      Sketchup.active_model.commit_operation
    end

    def x
      return self.position.x
    end

    def y
      return self.position.y
    end

    def erase
      dele = [@edge]
      @edge.vertices.each { |v|
        v.loops.each { |l|
          l.edges.each { |e| 
            # make sure the connected edge is part of an arc where the center
            # is the same as the plunge
            c = e.curve
            if ((c) && (c.kind_of? Sketchup::ArcCurve) && (c.center == self.position))
              dele.push(e)
            end
          }
        }
      }
      Sketchup.active_model.entities.erase_entities dele
    end
  
    def cut_points(reverse=false)
      yield (self.position, self.cut_factor)
    end

    def cut_factor
      return PhlatScript.cutFactor
    end

    # marks all entities as having been milled in gcodeutil
    def processed=(val)
      @edge.set_attribute(Dict_name, Dict_object_mark, val)
    end

    def processed
      return @edge.get_attribute(Dict_name, Dict_object_mark, false)
    end

    def position
      return @edge.vertices.first.position
    end

  end

end