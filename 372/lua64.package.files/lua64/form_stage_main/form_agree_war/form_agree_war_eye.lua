require("util_gui")
require("util_functions")
require("custom_sender")
require("define\\team_rec_define")
local FORM_NAME = "form_stage_main\\form_agree_war\\form_agree_war_eye"
local TEAM_REC = "team_rec"
local area_fight = "area_guildbattle01"
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_open(self)
  self.player_see = ""
  local timer = nx_value(GAME_TIMER)
  timer:Register(500, -1, nx_current(), "on_check_area_time", self, -1, -1)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_lbl_time", self)
  end
  self.player_see = ""
  nx_execute("form_test\\form_camera", "reset_camera_target")
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_086"))
  nx_destroy(self)
end
function on_main_form_shut(self)
end
function on_check_area_time(form)
  local obj = get_obj_by_name(form.player_see)
  if obj == nil then
    on_btn_switch_click(form.btn_switch)
    return
  end
  if not nx_is_valid(obj) then
    on_btn_switch_click(form.btn_switch)
    return
  end
  local area = get_obj_area(obj)
  if nx_string(area) ~= nx_string(area_fight) then
    on_btn_switch_click(form.btn_switch)
  end
end
function on_btn_switch_click(btn)
  local form = btn.ParentForm
  local player_see = form.player_see
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  local row_count = client_player:GetRecordRows(TEAM_REC)
  local row_index = client_player:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(player_see))
  local row_see = -1
  for i = 1, nx_number(row_count) do
    local index = math.fmod(nx_number(row_index) + i, nx_number(row_count))
    local name = client_player:QueryRecord(TEAM_REC, index, TEAM_REC_COL_NAME)
    local obj = get_obj_by_name(name)
    if obj ~= nil and nx_is_valid(obj) then
      local obj_area = get_obj_area(obj)
      if not nx_ws_equal(player_name, name) and nx_string(obj_area) == nx_string(area_fight) then
        see(obj, name)
        return
      end
    end
  end
  close_form()
end
function see(obj, name)
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form.player_see = name
  nx_execute("form_test\\form_camera", "set_camera_target", obj)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  close_form()
end
function open_form()
  local role = nx_value("role")
  local area_role = get_obj_area(role)
  if nx_string(area_role) == nx_string(area_fight) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_087"))
    return
  end
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_085"))
  on_btn_switch_click(form.btn_switch)
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function get_obj_by_name(name)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return nil
  end
  local game_control = scene.game_control
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local scene_obj = game_client:GetScene()
  local scene_obj_table = scene_obj:GetSceneObjList()
  for i, val in ipairs(scene_obj_table) do
    if not nx_is_valid(val) then
      return nil
    end
    if nx_ws_equal(nx_widestr(name), nx_widestr(val:QueryProp("Name"))) then
      local target_obj = game_visual:GetSceneObj(val.Ident)
      if nx_is_valid(target_obj) then
        return target_obj
      end
    end
  end
  return nil
end
function get_obj_area(obj)
  if obj == nil then
    return
  end
  local scene = nx_value("game_scene")
  local terrain = scene.terrain
  return terrain:GetAreaName(obj.PositionX, obj.PositionZ)
end
function test_area()
  local role = nx_value("role")
  local scene = nx_value("game_scene")
  local terrain = scene.terrain
  local area_name = terrain:GetAreaName(role.PositionX, role.PositionZ)
  nx_msgbox(nx_string(area_name))
end
