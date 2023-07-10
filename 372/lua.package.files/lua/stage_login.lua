require("const_define")
require("login_scene")
require("role_composite")
local FORM_LOGIN = "form_stage_login\\form_login"
function entry_stage_login(old_stage)
  local gui = nx_value("gui")
  gui.ScaleEnable = false
  nx_set_value("login_ready", false)
  nx_set_value("loading", true)
  gui.Desktop:Close()
  gui.Loader:LoadDesktop(nx_resource_path(), gui.skin_path .. "form_stage_login\\form_login_back.xml")
  gui.Desktop.Left = 0
  gui.Desktop.Top = 0
  gui.Desktop.Width = gui.Width
  gui.Desktop.Height = gui.Height
  gui.Desktop.Transparent = true
  gui.Desktop:ShowModal()
  local mgr = nx_value("UnenthrallModule")
  if not nx_is_valid(mgr) then
    mgr = nx_create("UnenthrallModule")
    nx_set_value("UnenthrallModule", mgr)
  end
  if nx_is_valid(mgr) then
    mgr:Reset()
    mgr.OnlineTime = 0
    mgr.Enthrall = false
    mgr:SetTip(0, false)
    mgr:SetTip(1, false)
    mgr:SetTip(2, false)
    mgr:SetTip(3, false)
  end
  local main_scene = nx_value("game_scene")
  if not (nx_find_custom(main_scene, "terrain") and nx_is_valid(main_scene.terrain)) or old_stage == "main" then
    local loading_form = nx_execute("util_gui", "util_get_form", "form_common\\form_loading", true, false)
    loading_form.Left = 0
    loading_form.Top = 0
    loading_form.Width = gui.Width
    loading_form.Height = gui.Height
    loading_form:Show()
    main_scene = nx_value("game_scene")
    add_login_private_to_scene(main_scene)
    local world = nx_value("world")
    world.MainScene = main_scene
    nx_execute("util_functions", "play_music", main_scene, "login", "login")
    local world = nx_value("world")
    world:CollectResource()
    local game_config = nx_value("game_config")
    if not nx_find_custom(game_config, "login_type") then
      game_config.login_type = "2"
    end
    if game_config.login_type == "2" then
    else
      load_login_scene(main_scene, "map\\ter\\login05\\")
    end
    local client_npc_manager = nx_value("client_npc_manager")
    if nx_is_valid(client_npc_manager) then
      local camera = main_scene.camera
      client_npc_manager.Role = camera
    end
    if nx_is_valid(loading_form) then
      loading_form:Close()
    end
  else
    local loading_form = nx_execute("util_gui", "util_get_form", "form_common\\form_loading", true, false)
    loading_form.Left = 0
    loading_form.Top = 0
    loading_form.Width = gui.Width
    loading_form.Height = gui.Height
    loading_form:Show()
    main_scene.terrain.WaterVisible = true
    main_scene.terrain.GroundVisible = true
    main_scene.terrain.VisualVisible = true
    main_scene.terrain.HelperVisible = true
    add_login_private_to_scene(main_scene)
    nx_execute("util_functions", "play_music", main_scene, "login", "login")
    local game_config = nx_value("game_config")
    if not nx_find_custom(game_config, "login_type") then
      game_config.login_type = "2"
    end
    if game_config.login_type ~= "2" then
      apply_login01_camera(main_scene, "map\\ter\\login05\\")
      apply_login01_effect(main_scene, "map\\ter\\login05\\")
    end
    nx_pause(0.1)
    while not main_scene.terrain.LoadFinish do
      nx_pause(0.1)
    end
    if nx_is_valid(loading_form) then
      loading_form:Close()
    end
  end
  nx_set_value("loading", false)
  show_login_form()
  local bnExist = nx_file_exists(nx_work_path() .. "Lua\\Main.lua")
  if bnExist == true then
    local suc = 1
    local plugsys = nx_value("PlugSys")
    if not nx_is_valid(plugsys) then
      plugsys = nx_create("PlugSys")
      if nx_is_valid(plugsys) then
        if nx_find_property(plugsys, "Version") then
          if plugsys.Version == 2 then
            if nx_is_valid(plugsys) then
              nx_set_value("PlugSys", plugsys)
            end
          else
            suc = 0
          end
        else
          suc = 0
        end
      end
    end
    if suc == 0 then
      nx_destroy(plugsys)
    elseif nx_is_valid(plugsys) then
      plugsys:OnEntryLoginStage()
    end
  end
end
function exit_stage_login(new_stage)
  local gui = nx_value("gui")
  local scene = nx_value("game_scene")
  if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
    scene.terrain.Visible = false
  end
  local login_form = nx_value(FORM_LOGIN)
  if nx_is_valid(login_form) then
    login_form:Close()
  end
  gui.Desktop:Close()
  gui.Desktop:DeleteAll()
  gui.Desktop.BackImage = ""
  nx_bind_script(gui.Desktop, "")
  local world = nx_value("world")
  world:CollectResource()
  nx_set_value("exit_success", true)
  nx_execute("form_common\\form_confirm", "clear")
  nx_execute("form_common\\form_connect", "clear")
  nx_execute("login_scene", "clear_login_weather")
  return 1
end
function show_login_form()
  local from_create = nx_value("form_stage_create\\form_create_select_menpai")
  if nx_is_valid(from_create) then
    from_create:Close()
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_LOGIN, true, false)
  if not nx_is_valid(form) then
    return 0
  end
  form:ShowModal()
  nx_wait_event(100000000, form, "login_return")
  nx_execute("form_stage_main\\form_sys_notice", "clear_SysEventList")
  return 1
end
