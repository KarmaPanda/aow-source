require("util_functions")
require("share\\view_define")
require("util_gui")
require("share\\capital_define")
require("custom_sender")
require("form_stage_main\\form_die_util")
require("util_gui")
BUFF_KUANG = "gui\\special\\relive\\buff_high_light.png"
MAX_DIS = 999999999
MOV_FPS = 30
TOP_X = 0
TOP_Y = 0
MID_X = 0
MID_Y = 128
BOTTOM_X = 0
BOTTOM_Y = 184
function form_die_Init(form)
end
function form_die_Open(form)
  form.Fixed = false
  form.no_need_motion_alpha = true
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.revert = os.time() + 600
  form.LuaScript = nx_current()
  local asynor = nx_value("common_execute")
  asynor:AddExecute("relive_fresh_timer", form, nx_float(0.5))
  form.select_type = RELIVE_TYPE_RETURNCITY
  form.btn_return_city.Enabled = true
  fresh_relive_form(form)
end
function on_main_form_close(form)
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("relive_fresh_timer", form)
  local ok_dialog = nx_value("form_stage_main\\form_relive_ok")
  if nx_is_valid(ok_dialog) then
    ok_dialog:Close()
  end
  nx_destroy(form)
end
function on_btn_return_city_click(btn)
  nx_execute(nx_current(), "show_ok_dialog", btn.ParentForm, RELIVE_TYPE_RETURNCITY)
end
function on_btn_relive_near_click(btn)
  nx_execute(nx_current(), "show_ok_dialog", btn.ParentForm, RELIVE_TYPE_NEAR)
end
function on_btn_return_local_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local scene = game_client:GetScene()
  local is_clone = false
  if nx_is_valid(scene) then
    is_clone = scene:FindProp("SourceID")
  end
  if nx_boolean(is_clone) then
    nx_execute(nx_current(), "show_ok_dialog", form, RELIVE_TYPE_FB_LOCAL)
  else
    nx_execute(nx_current(), "show_ok_dialog", form, RELIVE_TYPE_LOCAL)
  end
end
function on_btn_return_city_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.select_type = RELIVE_TYPE_RETURNCITY
  fresh_relive_form(form)
end
function on_btn_return_city_lost_capture(btn)
  local ok_dialog = nx_value("form_stage_main\\form_relive_ok")
  if nx_is_valid(ok_dialog) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.select_type = RELIVE_TYPE_RETURNCITY
  fresh_relive_form(form)
end
function fresh_relive_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form_load = nx_value("form_common\\form_loading")
  if nx_is_valid(form_load) then
    gui.Desktop:ToBack(form)
  else
    gui.Desktop:ToFront(form)
  end
  form.btn_relive_near.Enabled = true
  local near_pos = getNearRelivePosInfo()
  local pos_str = ""
  if near_pos == nil or near_pos == "" then
    form.btn_relive_near.Enabled = false
    pos_str = gui.TextManager:GetFormatText("ui_fuhuo0004", "ui_fuhuo_nonearby")
  else
    pos_str = gui.TextManager:GetFormatText("ui_fuhuo0004", near_pos)
  end
  form.lbl_count.Text = nx_widestr(pos_str)
end
function GetReliveProp(relivetype, prop)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(RELIVE_INFO) then
    IniManager:LoadIniToManager(RELIVE_INFO)
  end
  local ini = IniManager:GetIniDocument(RELIVE_INFO)
  if not nx_is_valid(ini) then
    return ""
  end
  if relivetype == "" or relivetype == nil then
    return ""
  end
  if prop == "" or prop == nil then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(relivetype))
  if sec_index < 0 then
    return ""
  end
  local str_info = ini:ReadString(sec_index, nx_string(prop), "")
  return nx_string(str_info)
end
function player_relive_end(relive_type)
end
function getSenceSourceID()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return ""
  end
  local scene_res = client_scene:QueryProp("SourceID")
  return scene_res
end
function getReturnCityPosInfo()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp("RelivePositon") then
    return ""
  end
  local rl_pos_info = client_player:QueryProp("RelivePositon")
  return rl_pos_info
end
function Find_key_info(pos_info)
  local ini = nx_execute("util_functions", "get_ini", "share\\relive\\sencerelive.ini")
  if not nx_is_valid(ini) then
    return
  end
  local SectionCount = ini:GetSectionCount()
  for i = 0, SectionCount - 1 do
    if ini:ReadString(i, pos_info, "") ~= "" then
      return ini:ReadString(i, pos_info, "")
    end
  end
  return ""
end
function Find_ReliveKey_ForIni(key_front)
  if key_front == "" then
    return
  end
  local key = nx_string(key_front) .. "_01"
  local ini = nx_execute("util_functions", "get_ini", "share\\relive\\sencerelive.ini")
  if not nx_is_valid(ini) then
    return
  end
  local SectionCount = ini:GetSectionCount()
  for i = 0, SectionCount - 1 do
    if ini:ReadString(i, key, "") ~= "" then
      return i
    end
  end
  return ""
end
function on_time_over()
  nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_RETURNCITY, nx_int(0))
end
function show_ok_dialog(form, relive_type)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return ""
  end
  local gui = nx_value("gui")
  local dialog = util_get_form("form_stage_main\\form_relive_ok", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local str = get_confirm_info(relive_type, nx_int(0))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(nx_widestr(str), -1)
  if relive_type == RELIVE_TYPE_FB_LOCAL then
    local relive_count = player:QueryProp("DailyCloneReliveCount")
    local left_relive_count = 10 - relive_count
    dialog.lbl_remain_count.Text = nx_widestr(gui.TextManager:GetFormatText("ui_revive_clonecount", nx_int(left_relive_count)))
  else
    dialog.lbl_remain_count.Visible = false
  end
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    local attack_mode = 0
    nx_execute("custom_sender", "custom_relive", relive_type, attack_mode)
  end
end
function image_moving(obj, end_Left, end_Top)
  if not nx_is_valid(obj) then
    return
  end
  if false == obj.Visible then
    return
  end
  if nx_number(obj.Left) == nx_number(end_Left) and nx_number(obj.Top) == nx_number(end_Top) then
    return
  end
  local obj_x = obj.Left
  local obj_y = obj.Top
  local dis_x = end_Left - obj.Left
  local dis_y = end_Top - obj.Top
  for i = 1, MOV_FPS do
    nx_pause(0.01)
    if not nx_is_valid(obj) then
      return
    end
    local move_x = nx_int(nx_float(dis_x / MOV_FPS) * i)
    local move_y = nx_int(nx_float(dis_y / MOV_FPS) * i)
    obj.Left = obj_x + move_x
    obj.Top = obj_y + move_y
  end
  obj.Left = nx_number(end_Left)
  obj.Top = nx_number(end_Top)
end
function syn_image_moving(obj, end_Left, end_Top)
  nx_execute(nx_current(), "image_moving", obj, end_Left, end_Top)
end
function getNearRelivePosInfo()
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local x = visual_player.PositionX
  local y = visual_player.PositionY
  local z = visual_player.PositionZ
  local sourceid = GetSceneSourceID()
  local dis = 100000000
  local postion_des = ""
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument("share\\relive\\sencerelive.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(sourceid))
  if sec_index < 0 then
    return
  end
  local item_count = ini:GetSectionItemCount(sec_index)
  if item_count == 1 then
    local str = ini:GetSectionItemValue(sec_index, 0)
    local str_lst = util_split_string(str, ",")
    if table.getn(str_lst) == 6 then
      return str_lst[6]
    end
  else
    for i = 0, item_count - 1 do
      local str = ini:GetSectionItemValue(sec_index, i)
      local str_lst = util_split_string(str, ",")
      if table.getn(str_lst) >= 6 then
        local pos_x = str_lst[2]
        local pos_y = str_lst[3]
        local pos_z = str_lst[4]
        local orint = str_lst[5]
        local pos_des = str_lst[6]
        local tmp_dis = (pos_x - x) * (pos_x - x) + (pos_z - z) * (pos_z - z)
        if nx_int(tmp_dis) < nx_int(dis) then
          dis = tmp_dis
          postion_des = pos_des
        end
      end
    end
  end
  return postion_des
end
