
require 'Phlatboyz/PhlatTool.rb'

module PhlatScript

  module WebDialogX
		# Module used to extend UI::WebDialog base class to a local instance only.
		# Use:  webdialog_instance.extend(WebDialogX)    
		def setCaption(id, caption)
			self.execute_script("setFormCaption('#{id}','#{caption}')")  
		end
		
		def setValue(id, value)
			self.execute_script("setFormValue('#{id}','#{value}')")
		end
  end

  class ParametersTool < PhlatTool
    # taken from ActionScript
    JS_ESCAPE_MAP  	=  	{ '\\' => '\\\\', '</' => '<\/', "\r\n" => '\n', "\n" => '\n', "\r" => '\n', '"' => '\\"', "'" => "\\'" }
    
    def escape_javascript(s)
      if s
        s.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
      else
        ''
      end
    end
    
    def format_length(s)
      escape_javascript(Sketchup.format_length(s))
    end
    
    def select
      model = Sketchup.active_model

      if Use_compatible_dialogs 
        # prompts
        prompts = [PhlatScript.getString("Spindle Speed"), 
          PhlatScript.getString("Feed Rate"),
          PhlatScript.getString("Plunge Rate"),
          PhlatScript.getString("Material Thickness"),
          PhlatScript.getString("In/Outside Overcut Percentage") + " ",
          PhlatScript.getString("Bit Diameter"), 
          PhlatScript.getString("Tab Width"),
          PhlatScript.getString("Tab Depth Factor"),
          PhlatScript.getString("Safe Travel"),
          PhlatScript.getString("Safe Length"),
          PhlatScript.getString("Safe Width"),
          PhlatScript.getString("Overhead Gantry")]

        if PhlatScript.multipassEnabled?
          prompts.push(PhlatScript.getString("Generate Multipass"))
          prompts.push(PhlatScript.getString("Multipass Depth"))
        end
        prompts.push(PhlatScript.getString("Generate 3D GCode"))
        prompts.push(PhlatScript.getString("StepOver Percentage"))
        prompts.push("Comment Remarks")

        # default values
        encoded_comment_text = PhlatScript.commentText.to_s

        defaults = [PhlatScript.spindleSpeed.to_s,
          Sketchup.format_length(PhlatScript.feedRate),
          Sketchup.format_length(PhlatScript.plungeRate),
          Sketchup.format_length(PhlatScript.materialThickness),
          PhlatScript.cutFactor.to_s,
          Sketchup.format_length(PhlatScript.bitDiameter),
          Sketchup.format_length(PhlatScript.tabWidth),
          PhlatScript.tabDepth.to_s,
          Sketchup.format_length(PhlatScript.safeTravel),
          Sketchup.format_length(PhlatScript.safeWidth),
          Sketchup.format_length(PhlatScript.safeHeight),
          PhlatScript.useOverheadGantry?.inspect()]

        if PhlatScript.multipassEnabled?
          defaults.push(PhlatScript.useMultipass?.inspect())
          defaults.push(Sketchup.format_length(PhlatScript.multipassDepth))
        end
        defaults.push(PhlatScript.gen3D.inspect())
        defaults.push(PhlatScript.stepover)
        defaults.push(encoded_comment_text)

        # dropdown options can be added here 
        if PhlatScript.multipassEnabled?
          list = ["","","","","","","","","","","","false|true","false|true","","false|true","",""]
        else
          list = ["","","","","","","","","","","","false|true","false|true","",""]
        end

        input = UI.inputbox(prompts, defaults, list, PhlatScript.getString("Parameters"))
        # input is nil if user cancelled
        if (input)
            PhlatScript.spindleSpeed = input[0].to_i
            PhlatScript.feedRate = Sketchup.parse_length(input[1]).to_f
            PhlatScript.plungeRate = Sketchup.parse_length(input[2]).to_f
            PhlatScript.materialThickness = Sketchup.parse_length(input[3]).to_f
            PhlatScript.cutFactor = input[4].to_i
            PhlatScript.bitDiameter = Sketchup.parse_length(input[5]).to_f
            PhlatScript.tabWidth = Sketchup.parse_length(input[6]).to_f
            PhlatScript.tabDepth = input[7].to_i
            PhlatScript.safeTravel = Sketchup.parse_length(input[8]).to_f
            PhlatScript.safeWidth = Sketchup.parse_length(input[9])
            PhlatScript.safeHeight = Sketchup.parse_length(input[10])
            PhlatScript.useOverheadGantry = (input[11] == 'true')

            if PhlatScript.multipassEnabled?
              PhlatScript.useMultipass = (input[12] == 'true')
              PhlatScript.multipassDepth = Sketchup.parse_length(input[13]).to_f
              PhlatScript.gen3D = (input[14] == 'true')
              PhlatScript.stepover = input[15].to_f
              PhlatScript.commentText = input[16].to_s
            else
              PhlatScript.gen3D = (input[12] == 'true')
              PhlatScript.stepover = input[13].to_f
              PhlatScript.commentText = input[14].to_s
            end
			
			
        end
      else
        view = model.active_view
        width = 427
        height = 780
        x = (view.vpwidth - width)/2
        y = (view.vpheight - height)/2
        x = 0 if x < 0
        y = 0 if y < 0
        params_dialog = UI::WebDialog.new(PhlatScript.getString("Parameters"), false, "Parameters", width, height, x, y, false)
        params_dialog.extend(WebDialogX)
        params_dialog.set_position(x, y)
        params_dialog.set_size(width, height)
        params_dialog.add_action_callback("phlatboyz_action_callback") do | web_dialog, action_name |
          model = Sketchup.active_model
          if(action_name == 'load_params')
            web_dialog.setCaption('spindlespeed_id', PhlatScript.getString("Spindle Speed"))
            web_dialog.setValue('spindlespeed', PhlatScript.spindleSpeed)
            
            web_dialog.setCaption('feedrate_id', PhlatScript.getString("Feed Rate"))
            web_dialog.setValue('feedrate', format_length(PhlatScript.feedRate))

            web_dialog.setCaption('plungerate_id', PhlatScript.getString("Plunge Rate"))
            web_dialog.setValue('plungerate', format_length(PhlatScript.plungeRate))           
            
            web_dialog.setCaption('materialthickness_id', PhlatScript.getString("Material Thickness"))
            web_dialog.setValue('materialthickness', format_length(PhlatScript.materialThickness))

            web_dialog.setCaption('cutfactor_id', PhlatScript.getString("In/Outside Overcut Percentage"))
            web_dialog.setValue('cutfactor', PhlatScript.cutFactor)

            web_dialog.setCaption('bitdiameter_id', PhlatScript.getString("Bit Diameter"))
            web_dialog.setValue('bitdiameter', format_length(PhlatScript.bitDiameter))

            web_dialog.setCaption('tabwidth_id', PhlatScript.getString("Tab Width"))
            web_dialog.setValue('tabwidth', format_length(PhlatScript.tabWidth))

            web_dialog.setCaption('tabdepthfactor_id', PhlatScript.getString("Tab Depth Factor"))
            web_dialog.setValue('tabdepthfactor', PhlatScript.tabDepth)

            web_dialog.setCaption('safetravel_id', PhlatScript.getString("Safe Travel"))
            web_dialog.setValue('safetravel', format_length(PhlatScript.safeTravel)) 
            
            web_dialog.setCaption('safewidth_id', PhlatScript.getString("Safe Length"))
            web_dialog.setValue('safewidth', format_length(PhlatScript.safeWidth))

            web_dialog.setCaption('safeheight_id', PhlatScript.getString("Safe Width"))
            web_dialog.setValue('safeheight', format_length(PhlatScript.safeHeight))
            
            web_dialog.setCaption('overheadgantry_id', PhlatScript.getString("Overhead Gantry"))
            web_dialog.execute_script("setCheckbox('overheadgantry','"+PhlatScript.useOverheadGantry?.inspect()+"')")            
            
            web_dialog.setCaption('multipass_id', PhlatScript.getString("Generate Multipass"))
            web_dialog.execute_script("setCheckbox('multipass','"+PhlatScript.useMultipass?.inspect()+"')")
                      
            web_dialog.setCaption('multipassdepth_id', PhlatScript.getString("Multipass Depth"))
            web_dialog.setValue('multipassdepth', format_length(PhlatScript.multipassDepth))
            if !PhlatScript.multipassEnabled?
              web_dialog.execute_script("hideMultipass()")
            end
           
            web_dialog.setCaption('gen3D_id', PhlatScript.getString("Generate 3D GCode"))
            web_dialog.execute_script("setCheckbox('gen3D','"+PhlatScript.gen3D.inspect()+"')")   
			
            web_dialog.setCaption('stepover_id', PhlatScript.getString("StepOver Percentage"))
            web_dialog.setValue('stepover', PhlatScript.stepover)
		   
            web_dialog.setCaption('commenttext_id', PhlatScript.getString("Comment Remarks"))
            web_dialog.execute_script("setEncodedFormValue('commenttext','"+PhlatScript.commentText+"','$/')")
           
          elsif(action_name == 'save')
            PhlatScript.spindleSpeed = params_dialog.get_element_value("spindlespeed") # don't use parse_length for rpm
            PhlatScript.feedRate = Sketchup.parse_length(params_dialog.get_element_value("feedrate"))
            PhlatScript.plungeRate = Sketchup.parse_length(params_dialog.get_element_value("plungerate"))           
            PhlatScript.materialThickness = Sketchup.parse_length(params_dialog.get_element_value("materialthickness"))
            PhlatScript.cutFactor = params_dialog.get_element_value("cutfactor") # don't use parse_length for percentages
            PhlatScript.bitDiameter = Sketchup.parse_length(params_dialog.get_element_value("bitdiameter"))
            PhlatScript.tabWidth = Sketchup.parse_length(params_dialog.get_element_value("tabwidth"))
            PhlatScript.tabDepth = params_dialog.get_element_value("tabdepthfactor")
            PhlatScript.safeTravel = Sketchup.parse_length(params_dialog.get_element_value("safetravel"))            
            PhlatScript.safeWidth = Sketchup.parse_length(params_dialog.get_element_value("safewidth"))
            PhlatScript.safeHeight = Sketchup.parse_length(params_dialog.get_element_value("safeheight"))
            web_dialog.execute_script("isChecked('overheadgantry')")
            PhlatScript.useOverheadGantry = (params_dialog.get_element_value('checkbox_hidden') == "true") ? true : false            

            if PhlatScript.multipassEnabled?
              web_dialog.execute_script("isChecked('multipass')")
              PhlatScript.useMultipass = (params_dialog.get_element_value('checkbox_hidden') == "true") ? true : false
              PhlatScript.multipassDepth = Sketchup.parse_length(params_dialog.get_element_value("multipassdepth"))
            end
            web_dialog.execute_script("isChecked('gen3D')")
            PhlatScript.gen3D = (params_dialog.get_element_value('checkbox_hidden') == "true") ? true : false  
            PhlatScript.stepover = params_dialog.get_element_value("stepover")
			
            comment_text = params_dialog.get_element_value("commenttext").delete("'\"")
            encoded_comment_text = ""
            comment_text.each{|line| encoded_comment_text += line.chomp()+"$/"}
            PhlatScript.commentText = encoded_comment_text.chop().chop()
            
            params_dialog.close()
          elsif(action_name == 'cancel')
            params_dialog.close()
          elsif(action_name =='restore_defaults')
            web_dialog.setValue('spindlespeed', Default_spindle_speed)
            web_dialog.setValue('feedrate', Default_feed_rate)
            web_dialog.setValue('plungerate', Default_plunge_rate)            
            web_dialog.setValue('materialthickness', Default_material_thickness)
            web_dialog.setValue('cutfactor', Default_cut_depth_factor)
            web_dialog.setValue('bitdiameter', Default_bit_diameter)
            web_dialog.setValue('tabwidth', Default_tab_width)
            web_dialog.setValue('tabdepthfactor', Default_tab_depth_factor)
            web_dialog.setValue('safetravel', Default_safe_travel)
            web_dialog.setValue('safewidth', Default_safe_width)
            web_dialog.setValue('safeheight', Default_safe_height)
            web_dialog.setValue('commenttext', Default_comment_remark)
            web_dialog.setValue('multipassdepth', Default_multipass_depth)
            web_dialog.setValue('gen3D',Default_gen3d)
            web_dialog.setValue('stepover',Default_stepover)
          end
        end
        
        params_dialog.set_on_close { 
          #UI.messagebox("set on close method")
        }
        
        set_param_web_dialog_file = Sketchup.find_support_file "setParamsWebDialog.html", "Tools/Phlatboyz/html"
        if (set_param_web_dialog_file)
          params_dialog.set_file(set_param_web_dialog_file)
          params_dialog.show()
        end
      end
    end
    
  end
  
end