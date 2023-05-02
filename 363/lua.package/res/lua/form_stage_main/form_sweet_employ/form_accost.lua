require("util_gui")
require("util_functions")
require("define\\object_type_define")
require("control_set")
local FORM_ACCOST = "form_stage_main\\form_sweet_employ\\form_accost"
local FORM_EMPLOY_CONFIRM = "form_stage_main\\form_sweet_employ\\form_employ_confirm"
local ACCOST_SHOW_PHOTO = "gui\\special\\accost_show\\"
local GAME_CAMERA_NORMAL = 0
local GAME_CAMERA_STORY = 2
local CAMERA_ANGLE_X, CAMERA_ANGLE_Y, CAMERA_DISTANCE
local CHARACTER_NORMAL = 0
local CHARACTER_XIA = 1
local CHARACTER_E = 2
local CHARACTER_KUANG = 3
local CHARACTER_XIE = 4
local CHARACTER_SPECIAL = 10
function main_form_init(form)
  form.Fixed = true
  form.action_unlock = true
  form.count_tick = 20
  form.last_favor = 0
  form.role_face = nx_null()
  return 1
end
function on_main_form_open(form)
  change_form_size()
  form.rbtn_0.Checked = true
  form.groupbox_ani_favor.Visible = false
  form.groupbox_accost_skill.Visible = false
  form.groupbox_image.Visible = false
  form.groupbox_4.Visible = false
  form.groupbox_role.Visible = false
  form.groupbox_role_right.Visible = false
  form.groupbox_1.Visible = false
  form.groupbox_2.Visible = false
  return 1
end
function on_main_form_close(form)
  nx_execute("gui", "gui_open_closedsystem_form")
  if nx_running(nx_current(), "form_count_tick") then
    nx_kill(nx_current(), "form_count_tick")
  end
  nx_destroy(form)
end
function on_btn_exit_click(btn)
  nx_execute("custom_sender", "custom_offline_accost", nx_int(3), nx_string(action_id))
end
function change_form_size()
  local form = nx_value(FORM_ACCOST)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
end
function on_imgrid_Act_select_changed(self, index)
  local form = self.ParentForm
  if not form.action_unlock then
    return
  end
  local action_id = self:GetItemName(self:GetSelectItemIndex())
  nx_execute("custom_sender", "custom_offline_accost", nx_int(2), nx_string(action_id))
  form.action_unlock = false
  if nx_running(nx_current(), "form_count_tick") then
    nx_kill(nx_current(), "form_count_tick")
  end
end
function on_imgrid_Act_mousein_grid(self, index)
  if self:IsEmpty(index) then
    nx_execute("tips_game", "hide_tip", self.ParentForm)
    return
  end
  local name = self:GetItemName(index)
  name = nx_string("ui_") .. nx_string(name)
  local text = util_text(name)
  local x = self:GetMouseInItemLeft()
  local y = self:GetMouseInItemTop()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y, 0, self.ParentForm)
end
function on_imgrid_Act_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function show_imgrid_act(form, chara_type)
  local imagegrid = form.imgrid_Act
  imagegrid:Clear()
  local count = imagegrid.RowNum * imagegrid.ClomnNum
  local base_pack = base_action_pack(chara_type)
  for i = 1, math.min(table.getn(base_pack), count) do
    local config_id = base_pack[i]
    local res = util_split_string(nx_string(config_id), nx_string("_"))
    local str = ""
    for j = 2, table.getn(res) do
      str = str .. nx_string(res[j])
    end
    local photo = ACCOST_SHOW_PHOTO .. str .. ".png"
    imagegrid:AddItem(i - 1, photo, nx_widestr(config_id), 1, -1)
  end
end
function base_action_pack(chara_type)
  local pack = {}
  local ini = nx_execute("util_functions", "get_ini", "ini\\AccostShow.ini")
  if not nx_is_valid(ini) then
    return {}
  end
  local index = ini:FindSectionIndex(nx_string(chara_type))
  if index < 0 then
    return {}
  end
  local item_count = ini:GetSectionItemCount(index)
  for i = 0, item_count do
    local item = ini:GetSectionItemValue(index, i)
    table.insert(pack, item)
  end
  return pack
end
function form_count_tick(form)
  while nx_is_valid(form) do
    nx_pause(1)
    if not nx_is_valid(form) then
      return
    end
    if not nx_find_custom(form, "count_tick") then
      return
    end
    local temp = nx_number(form.count_tick)
    temp = temp - 1
    if nx_number(temp) < nx_number(0) then
      return
    end
    form.count_tick = temp
    form.pbar_left_time.Value = temp
  end
end
function on_server_accost_msg(...)
  local sub_msg = arg[1]
  if nx_number(1) == nx_number(sub_msg) then
    local form = nx_execute("util_gui", "util_get_form", FORM_ACCOST, true, false)
    if nx_is_valid(form) then
      form:Show()
    end
  elseif nx_number(2) == nx_number(sub_msg) then
    set_camra_normal()
    local form = nx_value(FORM_ACCOST)
    if nx_is_valid(form) then
      form:Close()
    end
  elseif nx_number(3) == nx_number(sub_msg) then
    set_camra_movie()
  elseif nx_number(5) == nx_number(sub_msg) then
    local form = nx_execute("util_gui", "util_get_form", FORM_EMPLOY_CONFIRM, true, false)
    if nx_is_valid(form) then
      nx_execute(FORM_EMPLOY_CONFIRM, "init_info", form, false, unpack(arg))
      form:ShowModal()
    end
  elseif nx_number(6) == nx_number(sub_msg) then
    local form = nx_value(FORM_EMPLOY_CONFIRM)
    if nx_is_valid(form) then
      form:Close()
    end
  elseif nx_number(7) == nx_number(sub_msg) then
    local accost_name = arg[2]
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_accost_useitem01")
    gui.TextManager:Format_AddParam(nx_widestr(accost_name))
    local text = gui.TextManager:Format_GetText()
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "accsot_requst_tips")
    if nx_is_valid(dialog) then
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
    end
    if nx_is_valid(dialog) then
      local res = nx_wait_event(100000000, dialog, "accsot_requst_tips_confirm_return")
      local player = get_player()
      if not nx_is_valid(player) then
        return
      end
      local name = nx_widestr(player:QueryProp("Name"))
      if res == "ok" then
        nx_execute("custom_sender", "custom_offline_accost", nx_int(5), nx_widestr(accost_name), 1)
      else
        nx_execute("custom_sender", "custom_offline_accost", nx_int(5), nx_widestr(accost_name), 2)
      end
    end
  end
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function hide_around_obj()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  around_obj_table = get_around_obj()
  local select_obj = nx_value("game_select_obj")
  for i, client_obj in pairs(around_obj_table) do
    if nx_is_valid(client_obj) then
      local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
      if nx_is_valid(visual_obj) then
        if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_NPC) then
          visual_obj.Visible = false
          head_game:ShowHead(visual_obj, false)
        end
        if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_PLAYER) and not nx_id_equal(select_obj, client_obj) then
          visual_obj.Visible = false
          head_game:ShowHead(visual_obj, false)
        end
      end
    end
  end
  local main_player = game_visual:GetPlayer()
  if not nx_is_valid(main_player) then
    return
  end
  head_game:ShowHead(main_player, true)
end
function show_around_obj()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  around_obj_table = get_around_obj()
  local main_player = game_visual:GetPlayer()
  if not nx_is_valid(main_player) then
    return
  end
  local b_show_player = not game_visual.HidePlayer
  for i, client_obj in pairs(around_obj_table) do
    if nx_is_valid(client_obj) then
      local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
      if nx_is_valid(visual_obj) then
        if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_NPC) then
          visual_obj.Visible = true
        end
        if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_PLAYER) and (b_show_player or nx_id_equal(visual_obj, main_player)) then
          visual_obj.Visible = true
        end
        head_game:ShowHead(visual_obj, true)
      end
    end
  end
end
function get_around_obj()
  local visual_obj_lst = {}
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return visual_obj_lst
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return visual_obj_lst
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return visual_obj_lst
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  for i, client_obj in pairs(client_obj_lst) do
    if nx_is_valid(client_obj) and (tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_PLAYER) or tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_NPC)) then
      table.insert(visual_obj_lst, client_obj)
    end
  end
  return visual_obj_lst
end
function set_camra_movie()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local select_obj = nx_value("game_select_obj")
  local visual_select = game_visual:GetSceneObj(select_obj.Ident)
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_select) or not nx_is_valid(visual_player) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  CAMERA_ANGLE_X = camera.AngleX
  CAMERA_ANGLE_Y = camera.AngleY
  local distance_x = camera.PositionX - visual_player.PositionX
  local distance_y = camera.PositionY - (visual_player.PositionY + game_control.BindHeight)
  local distance_z = camera.PositionZ - visual_player.PositionZ
  CAMERA_DISTANCE = math.sqrt(distance_x * distance_x + distance_y * distance_y + distance_z * distance_z)
  local mid_pos_x = math.min(visual_player.PositionX, visual_select.PositionX) + math.abs(visual_player.PositionX - visual_select.PositionX) / 2
  local mid_pos_y = math.min(visual_player.PositionY, visual_select.PositionY) + math.abs(visual_player.PositionY - visual_select.PositionY) / 2
  local mid_pos_z = math.min(visual_player.PositionZ, visual_select.PositionZ) + math.abs(visual_player.PositionZ - visual_select.PositionZ) / 2
  local mid_angle_y = visual_player.AngleY + math.pi / 2
  game_control.CameraMode = GAME_CAMERA_STORY
  game_control.CameraCollide = false
  local camera_story = game_control:GetCameraController(GAME_CAMERA_STORY)
  local camera_pos_x = mid_pos_x + 4 * math.sin(mid_angle_y)
  local camera_pos_z = mid_pos_z + 4 * math.cos(mid_angle_y)
  local camera_pos_y = mid_pos_y + 2.5
  local camera_angle_x = math.pi / 10
  local camera_angle_y = mid_angle_y - math.pi
  local camera_angle_z = 0
  camera_story:SetCameraDirect(camera_pos_x, camera_pos_y, camera_pos_z, camera_angle_x, camera_angle_y, camera_angle_z)
  camera_story.StartPlayerMove = false
  visual_player.Visible = true
end
function set_camra_normal()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_control = scene.game_control
  local camera = scene.camera
  if not nx_is_valid(game_control) then
    return
  end
  if not nx_is_valid(camera) then
    return
  end
  local camera_mode = GetIniInfo("camera_value")
  game_control.CameraMode = nx_int(camera_mode)
  game_control.CameraCollide = true
  if CAMERA_ANGLE_X == nil or CAMERA_ANGLE_Y == nil or CAMERA_DISTANCE == nil then
    return
  end
  game_control.PitchAngle = CAMERA_ANGLE_X
  game_control.YawAngle = CAMERA_ANGLE_Y
  game_control.Distance = CAMERA_DISTANCE
end
function favor_animation(form, favor)
  if nx_number(favor) == nx_number(0) then
    return
  end
  form.lbl_sign.Text = nx_widestr("+")
  form.lbl_sign.ForeColor = "255,0,255,0"
  if nx_number(favor) < nx_number(0) then
    form.lbl_sign.ForeColor = "255,255,0,0"
    form.lbl_sign.Text = nx_widestr("-")
    favor = 0 - favor
  end
  local shi = 0
  local ge = 0
  if nx_number(favor) >= nx_number(10) then
    shi = nx_int(math.mod(nx_number(favor) / 10, 10))
    ge = nx_int(math.mod(nx_number(favor), 10))
  else
    ge = nx_int(favor)
  end
  form.lbl_shi.BackImage = "gui\\special\\clone\\" .. nx_string(shi) .. ".png"
  form.lbl_ge.BackImage = "gui\\special\\clone\\" .. nx_string(ge) .. ".png"
  nx_execute(nx_current(), "groupbox_move", form)
end
function groupbox_move(form)
  if not nx_is_valid(form) then
    return
  end
  local groupbox = form.groupbox_ani_favor
  groupbox.Visible = true
  groupbox.Left = (form.Width - groupbox.Width) / 2
  groupbox.Top = (form.Height - groupbox.Height) / 2
  local sec = 0
  while true do
    sec = sec + nx_pause(0.05)
    if not nx_is_valid(form) then
      return
    end
    local left = groupbox.Left
    local top = groupbox.Top
    left = left + 1
    top = top + 2
    groupbox.Left = groupbox.Left + 1
    groupbox.Top = groupbox.Top - 2
    if 3 <= sec then
      groupbox.Visible = false
      break
    end
  end
end
function add_player_photo_3d(form)
  nx_execute("form_stage_main\\form_main\\form_main_player", "exe_refresh_role_face", form)
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = rbtn.Name
  local res = util_split_string(nx_string(name), nx_string("_"))
  local chara_type = nx_int(res[2])
  show_imgrid_act(form, chara_type)
end
