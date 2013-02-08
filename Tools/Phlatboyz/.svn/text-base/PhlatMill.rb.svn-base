require 'sketchup.rb'
require 'Phlatboyz/Constants.rb'

module PhlatScript

  class PhlatMill

    def initialize(output_file_name=nil, min_max_array=nil)
      #current_Feed_Rate = model.get_attribute Dict_name, $dict_Feed_Rate , nil 
      #current_Plunge_Feed = model.get_attribute Dict_name, $dict_Plunge_Feed , nil 
      @cz = 0.0
      @cx = 0.0
      @cy = 0.0
      @cs = 0.0
      @cc = ""

      @max_x = 48.0
      @min_x = -48.0
      @max_y = 22.0
      @min_y = -22.0
      @max_z = 1.0
      @min_z = -1.0
      if(min_max_array != nil)
        @min_x = min_max_array[0]
        @max_x = min_max_array[1]
        @min_y = min_max_array[2]
        @max_y = min_max_array[3]
        @min_z = min_max_array[4]
        @max_z = min_max_array[5]
      end
      @no_move_count = 0
      @spindle_speed = PhlatScript.spindleSpeed
      @retract_depth = PhlatScript.safeTravel.to_f
      @mill_depth  = -0.35
      @speed_curr  = PhlatScript.feedRate
      @speed_plung = PhlatScript.plungeRate
      @material_w = PhlatScript.safeWidth
      @material_h = PhlatScript.safeHeight
      @comment = PhlatScript.commentText
      @cmd_linear = "G1" # Linear interpolation
      @cmd_rapid = "G0" # Rapid positioning
      @cmd_arc = "G17 G2" # coordinated helical motion about Z axis
      @cmd_arc_rev = "G17 G3" # countercclockwise helical motion about Z axis
      @output_file_name = output_file_name
      @mill_out_file = nil
    end
    
    def set_bit_diam(diameter)
      #@curr_bit.diam = diameter
    end
      
    def cncPrint(*args)
      if(@mill_out_file)
        args.each {|string| @mill_out_file.print(string)}
      else
        args.each {|string| print string}
        #print arg
      end
    end
    
    def format_measure(axis, measure)
  #UI.messagebox("in #{measure}")
      m2 = @is_metric ? measure.to_mm : measure.to_inch
  #UI.messagebox(sprintf("  #{axis}%-10.*f", @precision, m2))
  #UI.messagebox("out mm: #{measure.to_mm} inch: #{measure.to_inch}")
      sprintf("  #{axis}%-10.*f", @precision, m2)
    end
    
    def format_feed(f)
      feed = @is_metric ? f.to_mm : f.to_inch
      sprintf(" F%-4i", feed)
    end

    def job_start
      if(@output_file_name)
        done = false
        while !done do
          begin
            @mill_out_file = File.new(@output_file_name, "w")
            done = true
          rescue
            button_pressed = UI.messagebox "Exception in PhlatMill.job_start "+$!, 5 #, RETRYCANCEL , "title"
            done = (button_pressed != 4) # 4 = RETRY ; 2 = CANCEL
            # TODO still need to handle the CANCEL case ie. return success or failure
          end
        end
      end
      bit_diameter = Sketchup.active_model.get_attribute Dict_name, Dict_bit_diameter, Default_bit_diameter
      material_thickness = Sketchup.active_model.get_attribute Dict_name, Dict_material_thickness, Default_material_thickness 

      cncPrint("%\n")
      cncPrint("(#{PhlatScript.getString("PhlatboyzGcodeTrailer")%$PhlatScriptExtension.version})\n")
      cncPrint("(File: #{PhlatScript.sketchup_file})\n") if PhlatScript.sketchup_file
      cncPrint("(Bit diameter: #{Sketchup.format_length(bit_diameter)})\n")
      cncPrint("(Feed rate: #{Sketchup.format_length(@speed_curr)})\n")
      cncPrint("(Material Thickness: #{Sketchup.format_length(material_thickness)})\n")
      cncPrint("(Material length: #{Sketchup.format_length(@material_h)} X width: #{Sketchup.format_length(@material_w)})\n")
      cncPrint("(Overhead Gantry: #{PhlatScript.useOverheadGantry?})\n")    
      cncPrint("(www.PhlatBoyz.com)\n")
      PhlatScript.checkParens(@comment, "Comment")
      @comment.split("$/").each{|line| cncPrint("(",line,")\n")} if !@comment.empty?

      #adapted from swarfer's metric code
      #metric by DAF - this does the basic setting up from the drawing units
      unit_cmd, @precision, @is_metric = case Sketchup.active_model.options['UnitsOptions']['LengthUnit']
        when 0,1 then 
          ["G20", 4, false]
        when 2..4 then
          ["G21", 3, true]
        else 
          ["", 0, false]
        end
        
      stop_code = Use_exact_path ? "G61" : "" # G61 - Exact Path Mode
      cncPrint("G90 #{unit_cmd} G49 #{stop_code}\n") # G90 - Absolute programming (type B and C systems)
      #cncPrint("G20\n") # G20 - Programming in inches
      #cncPrint("G49\n") # G49 - Tool offset compensation cancel
      cncPrint("M3 S", @spindle_speed, "\n") # M3 - Spindle on (CW rotation)   S spindle speed
    end 

    def job_finish
      cncPrint("M05\n") # M05 - Spindle off
      cncPrint("G0 Z0\n") 
      cncPrint("M30\n") # M30 - End of program/rewind tape
      cncPrint("%\n")
      if(@mill_out_file)
        begin
          @mill_out_file.close()
          @mill_out_file = nil
          UI.messagebox("Output file stored: "+@output_file_name)
        rescue
          UI.messagebox "Exception in PhlatMill.job_finish "+$!
        end
      else
        UI.messagebox("Failed to store output file. (File may be opened by another application.)")
      end
    end 
    
    def move(xo, yo=@cy, zo=@cz, so=@speed_curr, cmd=@cmd_linear) 
      #cncPrint("(move ", sprintf("%10.6f",xo), ", ", sprintf("%10.6f",yo), ", ", sprintf("%10.6f",zo), ", cmd=", cmd,")\n")
      if @retract_depth == zo
        cmd=@cmd_rapid
        so=0
        @cs=0
      else
        cmd=@cmd_linear
      end
        #print "( move xo=", xo, " yo=",yo,  " zo=", zo,  " so=", so,")\n"
        if (xo == @cx) && (yo == @cy) && (zo == @cz)
           #print "(move - already positioned)\n"
           @no_move_count += 1
        else
        if (xo > @max_x)
          cncPrint("(move x=", sprintf("%10.6f",xo), " GT max of ", @max_x, ")\n")
          xo = @max_x
        elsif (xo < @min_x)
          cncPrint("(move x=", sprintf("%10.6f",xo), " LT min of ", @min_x, ")\n")
          xo = @min_x
        end

        if (yo > @max_y)
          cncPrint "(move y=", sprintf("%10.6f",yo), " GT max of ", @max_y, ")\n"
          yo = @max_y
        elsif (yo < @min_y)
          cncPrint("(move y=", sprintf("%10.6f",yo), " LT min of ", @min_y, ")\n")
          yo = @min_y
        end

        if (zo > @max_z)
          cncPrint("(move z=", sprintf("%10.6f",zo), " GT max of ", @max_z, ")\n")
          zo = @max_z
        elsif (zo < @min_z)
          #cncPrint "(move x=", sprintf("%8.3f",zo), " LT min of ", @min_z, ")\n"
          #zo = @min_z
        end
        command_out = ""
        command_out += cmd if (cmd != @cc)
        command_out += (format_measure('X', xo)) if (xo != @cx)
        command_out += (format_measure('Y', yo)) if (yo != @cx)
        command_out += (format_measure('Z', zo)) if (zo != @cx)
        command_out += (format_feed(so)) if (so != @cs)
        command_out += "\n"
        cncPrint(command_out)
        @cx = xo
        @cy = yo
        @cz = zo
        @cs = so
        @cc = cmd
      end
    end
       
    def retract(zo=@retract_depth, cmd=@cmd_rapid)
      #cncPrint("(retract ", sprintf("%10.6f",zo), ", cmd=", cmd,")\n")
      if (zo == nil)
        zo = @retract_depth
      end
      if (@cz == zo)
        @no_move_count += 1
      else
        if (zo > @max_z)
          zo = @max_z
        elsif (zo < @min_z)
          zo = @min_z
        end
        command_out = ""
        command_out += cmd if (cmd != @cc)
        command_out += (format_measure('Z', zo)) if (zo != @cz)
        command_out += "\n"
        cncPrint(command_out)
        @cz = zo
        @cc = cmd
      end
    end

    def plung(zo=@mill_depth, so=@speed_plung, cmd=@cmd_linear)
      #cncPrint("(plung ", sprintf("%10.6f",zo), ", so=", so, " cmd=", cmd,")\n")
      if (zo == @cz)
        @no_move_count += 1
      else
        if (zo > @max_z)
          zo = @max_z
        elsif (zo < @min_z)
          zo = @min_z
        end
        command_out = ""
        command_out += cmd if (cmd != @cc)
        command_out += (format_measure('Z', zo)) if (zo != @cz)
        command_out += (format_feed(so)) if (so != @cs)
        command_out += "\n"
        cncPrint(command_out)
        @cz = zo
        @cs = so
        @cc = cmd
      end
    end

    def arcmove(xo, yo=@cy, radius=0, g3=false, zo=@cz, so=@speed_curr, cmd=@cmd_arc)
      cmd = @cmd_arc_rev if g3
  #puts "g3: #{g3} cmd #{cmd}"
      #G17 G2 x 10 y 16 i 3 j 4 z 9
      #G17 G2 x 10 y 15 r 20 z 5
      command_out = ""
      command_out += cmd if (cmd != @cc)
      command_out += (format_measure("X", xo)) #if (xo != @cx) x and y must be specified in G2/3 codes
      command_out += (format_measure("Y", yo)) #if (yo != @cy)
      command_out += (format_measure("Z", zo)) #if (zo != @cz)
      command_out += (format_measure("R", radius)) 
      command_out += (format_feed(so)) if (so != @cs)
      command_out += "\n"
      cncPrint(command_out)
      @cx = xo
      @cy = yo
      @cz = zo
      @cs = so
      @cc = cmd
    end

    def home
      if (@cx == @retract_depth) && (@cy == 0) && (@cz == 0)
        @no_move_count += 1
      else
        retract
        cncPrint("G0 X0 Y0\n")
        @cx = 0
        @cy = 0
        @cz = 0
        @cs = 0
        @cc = ""
      end
    end
    
  end # class PhlatMill

end # module PhlatScript