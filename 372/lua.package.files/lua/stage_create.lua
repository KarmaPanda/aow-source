require("util_gui")
require("login_scene")
require("util_functions")
local FormSelectBook = "form_stage_create\\form_select_book"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function entry_stage_create(old_stage)
  local gui = nx_value("gui")
  gui.Desktop:Close()
  gui.Desktop:DeleteAll()
  gui.Desktop.BackImage = ""
  nx_bind_script(gui.Desktop, "")
  local world = nx_value("world")
  world:CollectResource()
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and nx_find_custom(game_config, "login_type") and game_config.login_type == "1" then
    gui.Loader:LoadDesktop(nx_resource_path(), gui.skin_path .. FormSelectBook .. ".xml")
    nx_set_value(FormSelectBook, gui.Desktop)
    gui.Desktop.Left = 0
    gui.Desktop.Top = 0
    gui.Desktop.Width = gui.Width
    gui.Desktop.Height = gui.Height
    gui.Desktop.Transparent = true
    if old_stage ~= "login" then
      gui.Desktop.stop_time = 5
    else
      gui.Desktop.stop_time = 3
    end
    gui.Desktop:ShowModal()
    local main_scene = nx_value("game_scene")
    if old_stage == "login" then
      gui.Desktop.b_show_alpha_lbl = true
    else
      gui.Desktop.b_show_alpha_lbl = false
      load_login_scene(main_scene, "map\\ter\\login05\\")
    end
    nx_execute("login_scene", "clear_login_weather")
    nx_execute("form_stage_create\\create_control", "add_create_private_to_scene", main_scene)
    nx_execute("login_scene", "apply_login01_effect", main_scene, "ini\\create\\weather_login\\login_2\\")
    nx_execute("login_scene", "apply_login01_camera", main_scene, "ini\\create\\weather_login\\login_2\\")
  else
    gui.Loader:LoadDesktop(nx_resource_path(), gui.skin_path .. "form_stage_create\\form_create_select_menpai.xml")
    nx_set_value("form_stage_create\\form_create_select_menpai", gui.Desktop)
    gui.Desktop.Left = 0
    gui.Desktop.Top = 0
    gui.Desktop.Width = gui.Width
    gui.Desktop.Height = gui.Height
    gui.Desktop.Transparent = true
    gui.Desktop:ShowModal()
    local main_scene = nx_value("game_scene")
    nx_execute("util_gui", "util_get_form", "form_stage_create\\form_creat_model", true, true)
    nx_execute("form_stage_create\\create_control", "add_create_private_to_scene", main_scene)
  end
  return 1
end
function exit_stage_create(new_stage)
  local gui = nx_value("gui")
  gui.Desktop:Close()
  gui.Desktop:DeleteAll()
  gui.Desktop.BackImage = ""
  nx_bind_script(gui.Desktop, "")
  local world = nx_value("world")
  world:CollectResource()
  nx_set_value(FormSelectBook, nil)
  nx_set_value("form_stage_create\\form_create", nil)
  nx_set_value("exit_success", true)
  local main_scene = nx_value("game_scene")
  nx_execute("form_common\\form_confirm", "clear")
  nx_execute("form_common\\form_connect", "clear")
  nx_execute("create_scene", "clear_game_control", main_scene)
  nx_execute("form_stage_create\\create_control", "clear_create_scene_private", main_scene)
  return 1
end
