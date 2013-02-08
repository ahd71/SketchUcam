require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

require 'Phlatboyz/PhlatboyzMethods.rb'
require 'Phlatboyz/PhlatOffset.rb'

require 'Phlatboyz/PhlatMill.rb'
require 'Phlatboyz/PhlatTool.rb'
require 'Phlatboyz/PhlatCut.rb'
require 'Phlatboyz/PSUpgrade.rb'
require 'Phlatboyz/Phlat3D.rb'

module PhlatScript

  class GcodeUtil < PhlatTool

    @@x_save = nil
    @@y_save = nil
    @@cut_depth_save = nil
  
    def initialize
      @tooltype = 3
      @tooltip = PhlatScript.getString("Phlatboyz GCode")
      @largeIcon = "images/gcode_large.png"
      @smallIcon = "images/gcode_small.png"
      @statusText = PhlatScript.getString("Phlatboyz GCode")
      @menuItem = PhlatScript.getString("GCode")
      @menuText = PhlatScript.getString("GCode")
    end

    def select
			if PhlatScript.gen3D
				result = UI.messagebox 'Generate 3D GCode?', MB_OKCANCEL
				if result == 1  # OK
					GCodeGen3D.new.generate
				else return end				
			else
				GcodeUtil.generate_gcode		
			end
    end

    def GcodeUtil.generate_gcode
      if PSUpgrader.upgrade
        UI.messagebox("GCode generation has been aborted due to the upgrade")
        return
      end
      model = Sketchup.active_model
      if(enter_file_dialog(model))
        # first get the material thickness from the model dictionary
        material_thickness = Sketchup.active_model.get_attribute Dict_name, Dict_material_thickness, Default_material_thickness 
        if(material_thickness)

          begin
            output_directory_name = model.get_attribute Dict_name, Dict_output_directory_name, Default_directory_name
            output_file_name = model.get_attribute Dict_name, Dict_output_file_name, Default_file_name
            current_bit_diameter = model.get_attribute Dict_name, Dict_bit_diameter, Default_bit_diameter

            # TODO check for existing / on the end of output_directory_name
            absolute_File_name = output_directory_name + output_file_name
            
            safe_array = P.get_safe_array()
            min_x = 0.0
            min_y = 0.0
            max_x = safe_array[2]
            max_y = safe_array[3]
            safe_area_points = P.get_safe_area_point3d_array()

            min_max_array = [min_x, max_x, min_y, max_y, Min_z, Max_z]
            #aMill = CNCMill.new(nil, nil, absolute_File_name, min_max_array)
            aMill = PhlatMill.new(absolute_File_name, min_max_array)
            
            aMill.set_bit_diam(current_bit_diameter)
            
            #puts("starting aMill absolute_File_name="+absolute_File_name)
            aMill.job_start()

            loop_root = LoopNodeFromEntities(Sketchup.active_model.active_entities, aMill, material_thickness)
            loop_root.sort
            millLoopNode(aMill, loop_root, material_thickness)

            #puts("done milling")
            
            aMill.home()
            # retracts the milling head and
            # and then moves it home.  This
            # prevents accidental milling 
            # through your work piece when 
            # moving home.

            #puts("finishing up")
            aMill.job_finish() # output housekeeping code
          rescue
            UI.messagebox "GcodeUtil.generate_gcode failed; Error:"+$!
          end
        else
          UI.messagebox(PhlatScript.getString("You must define the material thickness."))
        end
      end
    end
    
    private

    def GcodeUtil.LoopNodeFromEntities(entities, aMill, material_thickness)
      model = Sketchup.active_model
      safe_area_points = P.get_safe_area_point3d_array()
      # find all outside loops
      loops = []
      groups = []
      phlatcuts = []
      dele_edges = [] # store edges that are part of loops to remove from phlatcuts
      entities.each { |e|
        if e.kind_of?(Sketchup::Face)
          has_edges = false
          # only keep loops that contain phlatcuts
          e.outer_loop.edges.each { |edge|
            pc = PhlatCut.from_edge(edge)
            has_edges = ((!pc.nil?) && (pc.in_polygon?(safe_area_points)))
            dele_edges.push(edge)
          }
          loops.push(e.outer_loop) if has_edges
        elsif e.kind_of?(Sketchup::Edge)
            # make sure that all edges are marked as not processed
            pc = PhlatCut.from_edge(e)
            if (pc) 
              pc.processed = (false) 
              phlatcuts.push(pc) if ((pc.in_polygon?(safe_area_points)) && ((pc.kind_of? PhlatScript::PlungeCut) || (pc.kind_of? PhlatScript::CenterLineCut)))
            end
        elsif e.kind_of?(Sketchup::Group)
          groups.push(e)
        end
      }

      # make sure any edges part of a curve or loop aren't in the free standing phlatcuts array
      phlatcuts.collect! { |pc| dele_edges.include?(pc.edge) ? nil : pc }
      phlatcuts.compact!

      groups.each { |e|  
        # this is a bit hacky and we should try to use a transformation based on 
        # the group.local_bounds.corner(0) in the future
        group_name = e.name
        aMill.cncPrint("(Group: #{group_name})\n") if !group_name.empty?
        model.start_operation "Exploding Group", true
        es = e.explode
        gnode = LoopNodeFromEntities(es, aMill, material_thickness)
        gnode.sort
        millLoopNode(aMill, gnode, material_thickness)
        # abort the group explode
        model.abort_operation
        aMill.cncPrint("(Group complete: #{group_name})\n") if !group_name.empty?
      }
      loops.flatten!
      loops.uniq!
      puts("Located #{loops.length.to_s} loops containing PhlatCuts")

      loop_root = LoopNode.new(nil)
      loops.each { |loop| loop_root.find_container(loop) }

      # push all the plunge, centerline and fold cuts into the proper loop node
      phlatcuts.each { |pc| 
        loop_root.find_container(pc)
        pc.processed = true
      }
      return loop_root
    end

    def GcodeUtil.millLoopNode(aMill, loopNode, material_thickness)
      # always mill the child loops first
      loopNode.children.each{ |childloop|
        millLoopNode(aMill, childloop, material_thickness)
      }
      if (PhlatScript.useMultipass?) and (Use_old_multipass == false)
        loopNode.sorted_cuts.each { |sc| millEdges(aMill, [sc], material_thickness) }
      else
        millEdges(aMill, loopNode.sorted_cuts, material_thickness)
      end

      # finally we can walk the loop and make it's cuts
      edges = []
      reverse = false
      pe = nil
      if !loopNode.loop.nil?
        loopNode.loop.edgeuses.each{ |eu|
          pe = PhlatCut.from_edge(eu.edge)
          if (pe) && (!pe.processed)
            if (!Sketchup.active_model.get_attribute(Dict_name, Dict_overhead_gantry, Default_overhead_gantry))
                reverse = reverse || (pe.kind_of?(PhlatScript::InsideCut)) || eu.reversed?
            else    
                reverse = reverse || (pe.kind_of?(PhlatScript::OutsideCut)) || eu.reversed?
            end
            edges.push(pe)
            pe.processed = true
          end
        }
        loopNode.loop_start.downto(0) { |x|
          edges.push(edges.shift) if x > 0
        }
        edges.reverse! if reverse
      end 
      edges.compact!
      millEdges(aMill, edges, material_thickness, reverse)
    end

    def GcodeUtil.millEdges(aMill, edges, material_thickness, reverse=false)
      if (edges) && (!edges.empty?)
        begin
          mirror = P.get_safe_reflection_translation()
          trans = P.get_safe_origin_translation()
          trans = trans * mirror if Reflection_output
        
          aMill.retract()

          save_point = nil
          cut_depth = 0
          max_depth = 0
          pass = 0
          pass_depth = 0
          begin # multipass
            pass += 1
            aMill.cncPrint("(Pass: #{pass.to_s})\n") if PhlatScript.useMultipass?
            edges.each do | phlatcut |
              cut_started = false
              point = nil
              cut_depth = 0

              phlatcut.cut_points(reverse) { |cp, cut_factor|
                cut_depth = -1.0 * material_thickness * (cut_factor.to_f/100).to_f
                # store the max depth encountered to determine if another pass is needed
                max_depth = [max_depth, cut_depth].min

                if PhlatScript.useMultipass?
                  cut_depth = [cut_depth, (-1.0 * PhlatScript.multipassDepth * pass)].max
                  pass_depth = [pass_depth, cut_depth].min
                end

                # transform the point if a transformation is provided
                point = (trans ? (cp.transform(trans)) : cp)
                # retract if this cut does not start where the last one ended
                if ((save_point.nil?) || (save_point.x != point.x) || (save_point.y != point.y) || (save_point.z != cut_depth))
                  if (!cut_started)
                    aMill.retract()
                    aMill.move(point.x, point.y)
                    aMill.plung(cut_depth)
                  else
                    if ((phlatcut.kind_of? PhlatArc) && (phlatcut.is_arc?) && ((save_point.nil?) || (save_point.x != point.x) || (save_point.y != point.y)))
                      g3 = reverse ? !phlatcut.g3? : phlatcut.g3?
                      # if speed limit is enabled for vtabs set the feed rate to the plunge rate here
                      if (phlatcut.kind_of? PhlatScript::TabCut) && (phlatcut.vtab?) && (Use_vtab_speed_limit)
                        aMill.arcmove(point.x, point.y, phlatcut.radius, g3, cut_depth, PhlatScript.PlungeRate)
                      else
                        aMill.arcmove(point.x, point.y, phlatcut.radius, g3, cut_depth)
                      end
                    else
                      aMill.move(point.x, point.y, cut_depth)
                    end
                  end
                end
                cut_started = true
                save_point = (point.nil?) ? nil : Geom::Point3d.new(point.x, point.y, cut_depth)
              }
            end
          end until ((!PhlatScript.useMultipass?) || (pass_depth == max_depth))
        rescue Exception => e
          UI.messagebox "Exception in millEdges "+$! + e.backtrace.to_s
        end
      end
    end

    def GcodeUtil.enter_file_dialog(model=Sketchup.active_model)
      output_directory_name = PhlatScript.cncFileDir
      output_filename = PhlatScript.cncFileName
      status = false
      result = UI.savepanel(PhlatScript.getString("Save CNC File"), output_directory_name, output_filename)
      if(result != nil)
        # if there isn't a file extension set it to the default
        result += '.' + Default_file_ext if (File.extname(result).empty?)
        PhlatScript.cncFile = result
        PhlatScript.checkParens(result, "Output File")
        status = true
      end
      status
    end

    def GcodeUtil.points_in_points(test_pts, bounding_pts)
      fits = true
      test_pts.each { |pt| 
        next if !fits
        fits = Geom.point_in_polygon_2D(pt, bounding_pts, false)
      }
      return fits
    end

  end

end