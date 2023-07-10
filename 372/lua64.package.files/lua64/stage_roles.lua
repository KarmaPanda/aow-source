require("login_scene")
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function entry_stage_roles(old_stage)
  local gui = nx_value("gui")
  local scene = nx_value("game_scene")
  nx_set_value("loading", true)
  gui.Desktop:Close()
  gui.Desktop:DeleteAll()
  gui.Desktop.BackImage = ""
  nx_bind_script(gui.Desktop, "")
  local world = nx_value("world")
  world:CollectResource()
  local bookid = ""
  if "create" == old_stage then
    bookid = gui.Desktop.bookid
  end
  gui.Loader:LoadDesktop(nx_resource_path(), gui.skin_path .. "form_stage_roles\\form_roles.xml")
  gui.Desktop.Left = 0
  gui.Desktop.Top = 0
  gui.Desktop.Width = gui.Width
  gui.Desktop.Height = gui.Height
  gui.Desktop.Transparent = true
  gui.Desktop.bookid = bookid
  gui.Desktop:ShowModal()
  nx_set_value("form_stage_roles\\form_roles", gui.Desktop)
  local login_control = scene.login_control
  if nx_is_valid(login_control) then
    login_control:ClearMouseState()
  end
  if old_stage == "main" and nx_is_valid(scene.terrain) then
    nx_call("terrain\\terrain", "unload_terrain", scene)
  end
  nx_set_value("loading", false)
  return 1
end
function exit_stage_roles(new_stage)
  nx_log("flow exit_stage_roles")
  local form_vip_info = nx_value("form_stage_main\\form_vip_info")
  if nx_is_valid(form_vip_info) then
    form_vip_info:Close()
  end
  local gui = nx_value("gui")
  local form_roles = nx_value("form_stage_roles\\form_roles")
  if nx_is_valid(form_roles) then
    local role_model = form_roles.role_actor2
    local scene = nx_null()
    if nx_is_valid(role_model) then
      scene = role_model.scene
    else
      scene = nx_value("game_scene")
    end
    if nx_is_valid(login_terrain) then
      login_terrain:RemoveVisual(role_model)
    end
    if nx_is_valid(scene) then
      scene:Delete(role_model)
    end
  end
  gui.Desktop:Close()
  gui.Desktop:DeleteAll()
  gui.Desktop.BackImage = ""
  nx_bind_script(gui.Desktop, "")
  local world = nx_value("world")
  world:CollectResource()
  nx_set_value("exit_success", true)
  nx_set_value("form_stage_roles\\form_roles", nil)
  nx_execute("form_common\\form_confirm", "clear")
  nx_execute("form_common\\form_connect", "clear")
  return 1
end
