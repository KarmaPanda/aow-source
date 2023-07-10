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
  form.no_need_motion_alpha = true
  form.Fixed = false
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.revert = os.time() + 180
  local asynor = nx_value("common_execute")
  asynor:AddExecute("relive_fresh_timer", form, nx_float(0.5))
  form.select_type = RELIVE_TYPE_RETURNCITY
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
function on_btn_loulan_click(btn)
  nx_execute(nx_current(), "show_ok_dialog", btn.ParentForm, RELIVE_TYPE_LOULAN)
end
function on_btn_relive_strong_click(btn)
  nx_execute(nx_current(), "show_ok_dialog", btn.ParentForm, RELIVE_TYPE_LOCAL_STRONG)
end
function on_btn_relive_near_click(btn)
  local client = nx_value("game_client")
  if nx_is_valid(client) then
    local player = client:GetPlayer()
    if nx_is_valid(player) then
      local guan_id = player:QueryProp("CurGuanID")
      if 0 < guan_id then
        nx_execute(nx_current(), "show_ok_dialog", btn.ParentForm, RELIVE_TYPE_TIGUAN)
        return
      elseif twelve_dock_relive_near(player) then
        return
      elseif IsInLoulan() then
        nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_NEAR, nx_int(0))
        return
      end
    end
  end
  nx_execute(nx_current(), "show_ok_dialog", btn.ParentForm, RELIVE_TYPE_NEAR)
end
function twelve_dock_relive_near(player)
  if not nx_is_valid(player) then
    return false
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  if condition_manager:CanSatisfyCondition(player, player, nx_int(102405)) then
    nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_NEAR, nx_int(0))
    return true
  end
  return false
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
function on_cbtn_attack_get_capture(cbtn)
  local form = cbtn.ParentForm
  local str = util_text("ui_fuhuo_immediately_tips")
  nx_execute("tips_game", "show_text_tip", nx_widestr(str), cbtn.AbsLeft, cbtn.AbsTop, 0, cbtn.ParentForm)
end
function on_cbtn_attack_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_health_get_capture(cbtn)
  local form = cbtn.ParentForm
  local str = util_text("ui_fuhuo_health_tips")
  nx_execute("tips_game", "show_text_tip", nx_widestr(str), cbtn.AbsLeft, cbtn.AbsTop, 0, cbtn.ParentForm)
end
function on_cbtn_health_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
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
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local capital_type = 0
  local money = 0
  capital_type, money = nx_execute("form_stage_main\\form_die_util", "get_confirm_menoy", RELIVE_TYPE_LOCAL_STRONG)
  if nx_int(capital_type) ~= nx_int(0) and nx_int(money) > nx_int(0) then
    if check_is_enough_money(capital_type, money) then
      form.btn_relive_strong.Enabled = true
    else
      form.btn_relive_strong.Enabled = false
    end
  end
  local relive_count = player:QueryProp("DailyJHSceneReliveCount")
  if nx_int(relive_count) >= nx_int(JHSCENE_MAX_RELIVE_COUNT_DAILY) then
    form.btn_relive_strong.Enabled = false
    local count_str = gui.TextManager:GetFormatText("ui_revive_max", nx_int(relive_count))
    form.lbl_count.Text = nx_widestr(count_str)
    form.btn_relive_strong.HintText = nx_widestr(gui.TextManager:GetFormatText("tips_heal_myself_1"))
  else
    local left_count = nx_int(JHSCENE_MAX_RELIVE_COUNT_DAILY) - nx_int(relive_count)
    local count_str = gui.TextManager:GetFormatText("ui_revive_count", nx_int(left_count))
    form.lbl_count.Text = nx_widestr(count_str)
    form.btn_relive_strong.HintText = nx_widestr(gui.TextManager:GetFormatText("tips_heal_myself_health"))
  end
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
    return
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
  local scene_res = client_scene:QueryProp("Resource")
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\maplist.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section_index = ini:FindSectionIndex("MapList")
  if 0 <= section_index then
    local item_count = ini:GetSectionItemCount(section_index)
    for i = 0, item_count - 1 do
      local item_key = ini:GetSectionItemKey(section_index, i)
      local item_val = ini:GetSectionItemValue(section_index, i)
      if nx_string(item_val) == nx_string(scene_res) then
        return nx_string(item_key)
      end
    end
  end
  return ""
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
    nx_msgbox("share\\relive\\sencerelive.ini " .. get_msg_str("msg_120"))
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
  nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_NEAR, nx_int(0))
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
  local capital_type, capital_num = get_confirm_menoy(relive_type)
  if capital_type == nil or capital_num == nil then
    dialog.mltbox_money_info.Text = ""
  elseif nx_int(capital_type) == nx_int(CAPITAL_TYPE_SILVER) then
    local money = convert_money(nx_number(capital_num))
    local money_info = gui.TextManager:GetFormatText("ui_fuhuo_suiyin", money)
    dialog.mltbox_money_info:AddHtmlText(nx_widestr(money_info), -1)
  elseif nx_int(capital_type) == nx_int(CAPITAL_TYPE_SILVER_CARD) then
    local money = convert_money(nx_number(capital_num))
    local money_info = gui.TextManager:GetFormatText("ui_fuhuo_yb", money)
    dialog.mltbox_money_info:AddHtmlText(nx_widestr(money_info), -1)
  end
  if relive_type == RELIVE_TYPE_LOCAL or relive_type == RELIVE_TYPE_LOCAL_STRONG then
    local relive_count = player:QueryProp("DailyJHSceneReliveCount")
    dialog.lbl_remain_count.Text = nx_widestr(gui.TextManager:GetFormatText("ui_fuhuo_already", nx_int(relive_count)))
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
    local safe_mode = 0
    nx_execute("custom_sender", "custom_relive", relive_type, safe_mode)
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
function get_buff_photo(buff_id)
  if buff_id == "" or buff_id == nil then
    return ""
  end
  local buff_data_ini = nx_execute("util_functions", "get_ini", "share\\Skill\\buff_new.ini")
  if not nx_is_valid(buff_data_ini) then
    return ""
  end
  local sec_index = buff_data_ini:FindSectionIndex(buff_id)
  if sec_index < 0 then
    return
  end
  local buffer_num = buff_data_ini:ReadString(sec_index, "StaticData", "")
  if buffer_num == "" then
    return
  end
  local buff_static_ini = nx_execute("util_functions", "get_ini", "share\\Skill\\buff_static.ini")
  if not nx_is_valid(buff_static_ini) then
    return ""
  end
  local sec_index_num = buff_static_ini:FindSectionIndex(buffer_num)
  if sec_index_num < 0 then
    return ""
  end
  local buff_photo = buff_static_ini:ReadString(sec_index_num, "Photo", "")
  return buff_photo
end
function a(str)
  nx_msgbox(nx_string(str))
end
