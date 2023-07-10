function on_main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_open(self)
  show_actor2(self)
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
  return 1
end
function show_actor2(form)
  nx_execute("util_gui", "ui_ClearModel", form.scenebox)
  if not nx_is_valid(form.scenebox.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox)
  end
  local scene = form.scenebox.Scene
  local actor_root = scene:Create("Actor2")
  if not nx_is_valid(actor_root) then
    return nx_null()
  end
  local async_load = false
  actor_root.AsyncLoad = async_load
  local action_file = "obj\\mount\\ride_haigui_0101\\action.ini"
  if not actor_root:SetActionEx(action_file, "gui_swim_walk", "", async_load) then
    scene:Delete(actor_root)
    return nx_null()
  end
  local mount_xmod = "obj\\mount\\horse_action\\mount.xmod"
  local horse_xmod = "obj\\mount\\ride_horse_0402\\ride_horse_0402.xmod"
  local bridge_xmod = "obj\\mount\\ride_horse_0402\\ride_horse_0402_02.xmod"
  local mount_xmod = "obj\\mount\\haigui_action\\gui.xmod"
  local horse_xmod = "obj\\mount\\ride_haigui_0101\\Tpose.xmod"
  local bridge_xmod = "obj\\mount\\ride_haigui_0101\\Tpose_02.xmod"
  local role_composite = nx_value("role_composite")
  role_composite:LinkSkin(actor_root, "mount", mount_xmod, true)
  role_composite:LinkSkin(actor_root, "horse", horse_xmod, true)
  role_composite:LinkSkin(actor_root, "bridge", bridge_xmod, true)
  while not actor_root.LoadFinish do
    nx_pause(0)
  end
  local actor_role = scene:Create("Actor2")
  if not nx_is_valid(actor_role) then
    return nx_null()
  end
  actor_role.AsyncLoad = async_load
  local sex = 0
  local action_file = ""
  if sex == 0 then
    action_file = "obj\\char\\b_action\\action_simple.ini"
  else
    action_file = "obj\\char\\g_action\\action_simple.ini"
  end
  if not actor_role:SetActionEx(action_file, "gui_swim_walk", "", async_load) then
    scene:Delete(actor_role)
    scene:Delete(actor_root)
    return nx_null()
  end
  actor_role.Callee = nx_create("ActionEventHandler")
  local main_model = ""
  if sex == 0 then
    main_model = "obj\\char\\b_model_simple\\tpose.xmod"
  else
    main_model = "obj\\char\\g_model_simple\\tpose.xmod"
  end
  if not actor_role:AddSkin("main_model", main_model) then
    scene:Delete(actor_root)
    scene:Delete(actor_role)
    return nx_null()
  end
  while not actor_role.LoadFinish do
    nx_pause(0)
  end
  actor_root:LinkToPoint("actor_role", "mount::Point01", actor_role)
  local game_visual = nx_value("game_visual")
  game_visual:CreateRoleUserData(actor_root)
  game_visual:SetActRole(actor_root, actor_role)
  local actor_face = scene:Create("Actor2")
  if not nx_is_valid(actor_face) then
    return nx_null()
  end
  local file_name = ""
  if sex == 0 then
    file_name = "obj\\char\\b_face\\face_5\\composite.ini"
  else
    file_name = "obj\\char\\g_face\\face_5\\composite.ini"
  end
  if not actor_face:CreateFromIni(file_name) then
    scene:Delete(actor_face)
    return nx_null()
  end
  if nx_is_valid(actor_face) then
    actor_role:LinkToPoint("actor_face", "mount::Point01", actor_face)
    actor_role:AddChildAction(actor_face)
    actor_face:AddParentAction(actor_role)
  end
  if not nx_is_valid(actor_root) then
    scene:Delete(actor_role)
    scene:Delete(actor_face)
    return nx_null()
  end
  if nx_is_valid(role_composite) then
    local cloth_xmod = "obj\\char\\b_jianghu010\\b_cloth010.xmod"
    local hat_xmod = "obj\\char\\b_jianghu010\\b_helmet010.xmod"
    local pants_xmod = "obj\\char\\b_jianghu010\\b_pants010.xmod"
    local shoes_xmod = "obj\\char\\b_jianghu010\\b_shoes010.xmod"
    role_composite:LinkSkin(actor_role, "cloth", cloth_xmod, true)
    role_composite:LinkSkin(actor_role, "hat", hat_xmod, true)
    role_composite:LinkSkin(actor_role, "pants", pants_xmod, true)
    role_composite:LinkSkin(actor_role, "shoes", shoes_xmod, true)
    actor_root:SetScale(0.65, 0.65, 0.65)
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox, actor_root)
end
