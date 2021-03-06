require 'sketchup.rb'

# Ruby essentials
# http://www.techotopia.com/index.php/Ruby_Essentials
# http://www.zenspider.com/Languages/Ruby/QuickRef.html
# http://www.regular-expressions.info/ruby.html

# SketchUp
# http://sketchup.google.com
# http://www.suwiki.org
# http://www.sketchucation.com/forums/scf/viewforum.php?f=15

# SketchUp Ruby API
# http://download.sketchup.com/OnlineDoc/gsu6_ruby/Docs/index.html
# http://code.google.com/apis/sketchup/docs/developers_guide/index.html
# http://www.crai.archi.fr/rubylibrarydepot/ruby/offset.rb
# http://www.smustard.com/script/Offset
# http://www.sketchucation.com/forums/scf/

# G-Code
# http://en.wikipedia.org/wiki/G-code

# Groups & Forums
# http://www.phlatforum.com/
# http://thecrashcast.com/
# http://crash-hancock.blogspot.com/
# http://www.vimeo.com/user945475/videos   Michael Hancock's videos
# http://www.rcgroups.com/forums/showthread.php?t=888387   Introducing The Phlatprinter * Available for Purchase *
# http://www.rcflightcast.com/
# http://allthingsthatfly.com/

# Name Begins With Variable Scope 
# $  A global variable  
# @  An instance variable  
# [a-z] or _  A local variable  
# [A-Z]  A constant 
# @@ A class variable 

module PhlatScript

# - - - - - - - - - - - - - - - - -
#           Default Values
# - - - - - - - - - - - - - - - - -
Default_file_name = "gcode_out.gcode"
Default_file_ext = "gcode"
Default_directory_name = Dir.pwd + "/"

Default_spindle_speed = 15000
Default_feed_rate = 100.0.inch
Default_plunge_rate = 100.0.inch
Default_safe_travel = 0.125.inch
Default_material_thickness = 0.25.inch
Default_cut_depth_factor = 140
Default_bit_diameter = 0.125.inch
Default_tab_width = 0.25.inch
Default_tab_depth_factor = 50
Default_vtabs = false
Default_fold_depth_factor = 50

Default_safe_origin_x = 0.0.inch
Default_safe_origin_y = 0.0.inch
Default_safe_width = 42.0.inch
Default_safe_height = 22.0.inch
Default_comment_remark = ""

Default_overhead_gantry = false
Default_multipass = false
Default_multipass_depth = 0.03125.inch
Default_gen3d = false
Default_stepover = 30

# - - - - - - - - - - - - - - - - -
#           Cursor image files
# - - - - - - - - - - - - - - - - -
Cursor_directory = "Tools/Phlatboyz/images"
Cursor_tab_tool = "cursor_tabtool.png"
Cursor_vtab_tool = "cursor_vtabtool.png"
Cursor_inside_cuttool_filename = "cursor_cuttool_inside.png"
Cursor_outside_cuttool_filename = "cursor_cuttool_outside.png"
Cursor_fold_tool = "cursor_foldtool.png"
Cursor_safe_tool = "cursor_safetool.png"
Cursor_centerline_tool = "cursor_centerlinetool.png"
Cursor_plunge_tool = "cursor_plungetool.png"

# - - - - - - - - - - - - - - - - -
#           Dictionary Keys
# - - - - - - - - - - - - - - - - -
Dict_name = "phlatboyzdictionary"
Dict_spindle_speed = "spindle_speed"
Dict_feed_rate = "feed_rate"
Dict_plunge_rate = "plunge_rate"
Dict_safe_travel = "safe_travel"
Dict_material_thickness = "material_thickness"
Dict_cut_depth_factor = "cut_depth_factor"
Dict_output_file_name = "output_file_name"
Dict_output_directory_name = "output_directory_name"
Dict_cut_depth_factor = "cut_depth_factor"
Dict_edge_type = "edge_type"
Dict_object_mark = "object_mark"
Dict_tab_width = "tab_width"
Dict_bit_diameter = "bit_diameter"
Dict_fold_depth_factor = "fold_depth_factor"
Dict_cut_depth_factor = "cut_depth_factor"
Dict_edge_count = "edge_count"
Dict_tab_depth_factor = "tab_depth_factor"
Dict_vtabs = "vtabs"
Dict_tab_edge_type = "tab_edge_type"
Dict_comment_text = "Comment_Remark"
Dict_safe_origin_x = "safe_origin_x"
Dict_safe_origin_y = "safe_origin_y"
Dict_safe_width = "safe_width"
Dict_safe_height = "safe_height"
Dict_phlatarc_center = "arc_center"
Dict_phlatarc_radius = "arc_radius"
Dict_phlatarc_angle = "arc_angle"
Dict_phlatarc_g3 = "arc_g3"
Dict_vtab = "vtab"
Dict_multipass = "multipass"
Dict_multipass_depth = "multipass_depth"
Dict_overhead_gantry = "overhead_gantry"
Dict_gen3d = "gen3D"
Dict_stepover = "stepover"
Dict_construction_mark = "construction_mark"

# - - - - - - - - - - - - - - - - -
#           Cut Keys
# - - - - - - - - - - - - - - - - -

Key_inside_cut = "inside_cut"
Key_outside_cut = "outside_cut"
Key_fold_cut = "fold_cut"
Key_centerline_cut = "centerline_cut"
Key_tab_cut = "tab_cut"
Key_plunge_cut = "plunge_cut"

Key_reg_cut_arr = [Key_inside_cut, Key_outside_cut, Key_tab_cut]

# - - - - - - - - - - - - - - - - -
#         misc  parameters
# - - - - - - - - - - - - - - - - -
Construction_font_height = 0.6.inch
Min_z = -1.4
Max_z = 1.4

Fold_shorten_width = 0.0625.inch
Fold_depth_factor_array = [25, 50, 75, 100]
Max_fold_depth_factor = 140

Reverse_loop_direction = false
Reflection_output = false

# http://download.sketchup.com/OnlineDoc/gsu6_ruby/Docs/ruby-color.html
Color_inside_cut = "DeepSkyBlue"
Color_outside_cut = "Orange"
Color_cut_drawing = "red"
Color_fold_cut = "Fuchsia"
Color_fold_wide_cut = "MediumVioletRed"

Color_tab_drawing = "Green"
Color_tab_cut = "Green"
Color_vtab_drawing = "DarkOrchid"
Color_vtab_cut = "DarkOrchid"

Color_safe_drawing = "blue"
Color_centerline_cut = "DarkSeaGreen"
Color_plunge_cut = "Brown"

ver_ar = Sketchup.version.split(".")
if (ver_ar) && (ver_ar.length > 0) && (ver_ar[0].to_i == 7) && (ver_ar[1].to_i < 1)
  Rendering_edge_color_mode = 3
elsif (ver_ar) && (ver_ar.length > 0) && (ver_ar[0].to_i < 7)
  Rendering_edge_color_mode = 3  
else
  Rendering_edge_color_mode = 0
end

# -------------------------
# PhlatScript Features
# -------------------------

# Set this to true if you have problems with the parameter dialog being blank or crashing SU
Use_compatible_dialogs = false

# Set this to true to enable multipass fields in the parameters dialog. When it is false
# you will not be prompted to use multipass. When true you will be able to turn it off and
# on in the parameters dialog
Use_multipass = true

# Set this to true if you have an older version of Mach that does not slow down
# to the Z maximum speed during helical linear interpolation (G2/3 with Z 
# movement A.K.A vtabs on an arc). vtabs on arcs will cut at the plunge rate 
# defined in this file or overriden in the parameters dialog
Use_vtab_speed_limit = false

# Set this to true to use G61. This will make the machine come to a complete
# stop when changing directions instead of rounding out square corners. When 
# set to false the default for your CNC software will be used. Without G61
# the machine will maintain the best possible speed for the cut even if the 
# tool isn't true to the cut path. Rounded corners at low feedrates aren't 
# very noticeable but anything over 200 starts to generate large radii so 
# that the momentum of the machine can be maintained.
Use_exact_path = false

# Set this to true, if you want the safe area to always show, when parameters are saved.
# Otherwise the safe area will only show, if it's size has been changed.
Always_show_safearea = true

# Set this to true, if you want to use the old multipass method, where each pass is combined
# for all internal non-loop cuts.  Otherwise, each internal non-loop edge will complete, before moving to the next.
Use_old_multipass = false


  P = PhlatScript
  PB_MENU_TOOLBAR = 1
  PB_MENU_MENU = 2
  PB_MENU_CONTEXT = 4
  
end # module PhlatScript
