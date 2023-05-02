require("util_static_data")
require("define\\object_type_define")
require("define\\sysinfo_define")
require("share\\server_custom_define")
require("util_gui")
require("util_role_prop")
require("form_stage_main\\form_tvt\\define")
local FORM_MAIN_SYSINFO = "form_stage_main\\form_main\\form_main_sysinfo"
local MAX_INFO_CNT = 500
local DAMAGE_TYPE = {
  [1] = "fight_waigong_info_1",
  [2] = "fight_gang_info_1",
  [3] = "fight_rou_info_1",
  [4] = "fight_yin_info_1",
  [5] = "fight_yang_info_1",
  [6] = "fight_neilisunhao_info_1",
  [7] = "fight_xiuwei_info_1",
  [8] = "fight_parryvalue_loss_info_1"
}
local RESUME_TYPE = {
  [1] = "fight_shengming_info_1",
  [2] = "fight_neili_info_1",
  [3] = "fight_qinggong_info_1",
  [4] = "fight_parryvalue_info_1"
}
local PINZHAO_RESULT = {
  [1] = "fight_sheng_info_1",
  [2] = "fight_fu_info_1"
}
local last_time = 0
local last_idname = ""
local last_qg_id = ""
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  self.Fixed = true
  self.no_need_motion_alpha = true
  return 1
end
function main_form_open(self)
  local form_main_sysinfo_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_main_sysinfo_logic) then
    nx_destroy(form_main_sysinfo_logic)
  end
  local form_main_sysinfo_logic = nx_create("form_main_sysinfo")
  if nx_is_valid(form_main_sysinfo_logic) then
    nx_set_value("form_main_sysinfo", form_main_sysinfo_logic)
    self.form_main_sysinfo_logic = form_main_sysinfo_logic
  end
  self.image_change_size.Visible = false
  self.drag_info_size_change.Visible = false
  self.adjuster_1.Visible = false
  self.adjuster_1.Cursor = "WIN_SIZENWSE"
  self.groupbox_transparence.Visible = false
  self.tbar_transparence.Value = 0
  self.VerticalValue = self.info_list.VerticalValue
  self.info_group.BackColor = "0,0,0,0"
  self.info_group.Visible = true
  init_multitext_box(self.info_list)
  init_multitext_box(self.fight_list)
  init_multitext_box(self.tvt_list)
  init_multitext_box(self.emotion_list)
  self.btn_sys.Checked = true
  self.btn_fight.Checked = false
  self.info_list.Visible = true
  self.fight_list.Visible = false
  self.curr_info_list = self.info_list
  self.btn_sys.InfoList = self.info_list
  self.btn_fight.InfoList = self.fight_list
  self.info_list.Button = self.btn_sys
  self.fight_list.Button = self.btn_fight
  self.btn_fix.Visible = true
  self.btn_unfix.Visible = false
  self.groupbox_btn.Visible = false
  change_open_photo(self)
  load_sys_fight_info(self)
  self.buffer_info = ""
  self.buffer_time = 0
  local btn_tvt = self.btn_tvt
  local prop_name = ""
  self.tvt_list:ShowKeyItems(-1)
  for i = TIPSTYPE_TVT_JINDI, TIPSTYPE_TVT_YUNBIAO do
    prop_name = "tvt_type_" .. nx_string(i)
    nx_set_custom(btn_tvt, prop_name, true)
    self.tvt_list:ShowKeyItems(i)
  end
  local btn_emotion = self.btn_emotion
  self.emotion_list:ShowKeyItems(-1)
  for i = TIPSTYPE_EMOTIONINFO_NPC, TIPSTYPE_EMOTIONINFO_REWARD do
    prop_name = "emotion_type_" .. nx_string(i)
    nx_set_custom(btn_emotion, prop_name, true)
    self.emotion_list:ShowKeyItems(i)
  end
  show_tvt_info(self, false)
  self.groupbox_tvt_info_set.Visible = false
  show_emotion_info(self, false)
  local cur_time = os.time()
  self.btn_open.Visible = false
  self.groupbox_ctrl.Visible = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", self, FORM_MAIN_SYSINFO, "change_show")
  end
  nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "set_to_front")
end
function change_show(form)
  if not nx_is_valid(form) then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  form.btn_open.Visible = bIsNewJHModule
  form.info_group.Visible = not bIsNewJHModule
  change_open_photo(form)
end
function main_form_close(self)
  local form_main_sysinfo_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_main_sysinfo_logic) then
    nx_destroy(form_main_sysinfo_logic)
  end
  nx_kill(nx_current(), "show_form")
  nx_kill(nx_current(), "hide_form")
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("CurJHSceneConfigID", self)
  end
  nx_destroy(self)
end
function init_multitext_box(info_list)
  info_list.BackColor = "0,0,0,0"
  info_list.cur_back_alpha = 0
  info_list.NoFrame = true
  for i = 1, 20 do
    info_list:AddHtmlText(nx_widestr("    "), -1)
  end
  info_list.ViewRect = "10,10," .. info_list.Width - 10 .. "," .. info_list.Height - 10
  info_list:Reset()
end
function on_info_size_change(button, newX, newY)
  button.mouse_moved = true
  local form = button.ParentForm
  local gui = nx_value("gui")
  local image_change = form.image_change_size
  image_change.Visible = true
  image_change.AbsLeft = newX
  local bottom = form.info_list.AbsTop + form.info_list.Height
  local right = form.info_list.AbsLeft + form.info_list.Width
  image_change.Width = right - newX
  local min = 222
  local max = 280
  if min > image_change.Width then
    image_change.Width = min
  end
  if max < image_change.Width then
    image_change.Width = max
  end
  image_change.Height = bottom - newY
  min = 150 + form.btn_sys.Height
  max = 230 - form.btn_sys.Height
  if min > image_change.Height then
    image_change.Height = min
  end
  if max < image_change.Height then
    image_change.Height = max
  end
  image_change.AbsTop = bottom - image_change.Height
  image_change.AbsLeft = right - image_change.Width
end
function on_info_size_change_over(button, newX, newY)
  if not nx_find_custom(button, "mouse_moved") or not button.mouse_moved then
    return
  end
  local form = button.Parent.Parent
  local image_change = form.image_change_size
  image_change.Visible = false
  local both_list = {
    form.info_list,
    form.fight_list,
    form.tvt_list,
    form.emotion_list
  }
  for _, info_list in ipairs(both_list) do
    local drag = form.drag_info_size_change
    local drag2 = form.adjuster_1
    local group = button.Parent
    local bottom = group.AbsTop + group.Height
    info_list.Width = image_change.Width
    info_list.Height = image_change.Height
    form.drag_info_size_change.Height = info_list.Height
    drag.AbsLeft = info_list.AbsLeft
    drag.AbsTop = info_list.AbsTop
    info_list.AbsLeft = image_change.AbsLeft
    info_list.AbsTop = image_change.AbsTop
    drag2.AbsLeft = info_list.AbsLeft
    drag2.AbsTop = info_list.AbsTop
    local button = form.groupbox_btn
    button.AbsTop = info_list.AbsTop - button.Height + 3
    button.AbsLeft = info_list.AbsLeft + 6
    info_list.ViewRect = "10,10," .. info_list.Width - 10 .. "," .. info_list.Height - 10
    info_list:Reset()
    form.scrollbar_list.Maximum = form.info_list.VerticalMaxValue
    form.scrollbar_list.Value = form.info_list.VerticalValue
  end
  button.mouse_moved = false
end
function on_info_lock_btn_checked_changed(btn_lock)
  local form = btn_lock.ParentForm
  local both_list = {
    form.info_list,
    form.fight_list
  }
  for _, info_list in ipairs(both_list) do
    info_list.AutoScroll = not info_list.AutoScroll
  end
end
function on_btn_unfix_click(btn)
  local form = btn.ParentForm
  local both_list = {
    form.info_list,
    form.fight_list
  }
  for _, info_list in ipairs(both_list) do
    info_list.AutoScroll = not info_list.AutoScroll
  end
  btn.Visible = false
  form.btn_fix.Visible = true
end
function on_btn_fix_click(btn)
  local form = btn.ParentForm
  local both_list = {
    form.info_list,
    form.fight_list
  }
  for _, info_list in ipairs(both_list) do
    info_list.AutoScroll = not info_list.AutoScroll
  end
  btn.Visible = false
  form.btn_unfix.Visible = true
end
function on_scrollbar_list_value_changed(scrollbar)
  local form = scrollbar.ParentForm
  form.curr_info_list.VerticalValue = scrollbar.Value
  if math.abs(scrollbar.Maximum - scrollbar.Value) < 1 then
    form.curr_info_list.AutoScroll = true
    copy_tmp_info_list_to_normal()
  else
    form.curr_info_list.AutoScroll = false
  end
end
function copy_tmp_info_list_to_normal()
  local form = nx_value(FORM_MAIN_SYSINFO)
  if not nx_is_valid(form) then
    return
  end
  local form_logic = nx_value("form_main_sysinfo")
  if not nx_is_valid(form_logic) then
    return
  end
  local tmp_info_list = form:Find("tmp_info_list")
  if not nx_is_valid(tmp_info_list) then
    return
  end
  local cur_info_list = form.curr_info_list
  local tmp_len = tmp_info_list.ItemCount
  if nx_int(tmp_len) <= nx_int(0) then
    return
  end
  form.scrollbar_list.Enabled = false
  for i = 1, tmp_len do
    local info = tmp_info_list:GetHtmlItemText(0)
    local info_type = tmp_info_list:GetItemKeyByIndex(0)
    tmp_info_list:DelHtmlItem(0)
    form_logic:AddSystemInfo(info, info_type, 0)
  end
  form.scrollbar_list.Enabled = true
  form.scrollbar_list.Maximum = cur_info_list.VerticalMaxValue
  form.scrollbar_list.Value = cur_info_list.VerticalMaxValue
end
function inc_page()
  local form = nx_value(FORM_MAIN_SYSINFO)
  if not nx_is_valid(form) then
    return
  end
  if not form.btn_fight.Checked then
    return
  end
  local scrollbar = form.scrollbar_list
  if scrollbar.Value + 5 < scrollbar.Maximum then
    scrollbar.Value = scrollbar.Value + 5
  else
    scrollbar.Value = scrollbar.Maximum
  end
  form.curr_info_list.VerticalValue = scrollbar.Value
end
function dec_page()
  local form = nx_value(FORM_MAIN_SYSINFO)
  if not nx_is_valid(form) then
    return
  end
  if not form.btn_fight.Checked then
    return
  end
  local scrollbar = form.scrollbar_list
  if scrollbar.Value - 5 > scrollbar.Minimum then
    scrollbar.Value = scrollbar.Value - 5
  else
    scrollbar.Value = scrollbar.Minimum
  end
  form.curr_info_list.VerticalValue = scrollbar.Value
end
function on_btn_bottom_click(btn_bottom)
  local form = btn_bottom.ParentForm
  form.curr_info_list:GotoEnd()
  form.scrollbar_list.Value = form.scrollbar_list.Maximum
end
function on_info_list_get_capture(list)
  local form = list.ParentForm
  nx_kill(nx_current(), "show_form")
  nx_execute(nx_current(), "show_form", form, list)
end
function on_info_list_lost_capture(list)
  local form = list.Parent.Parent
  nx_kill(nx_current(), "hide_form")
  nx_execute(nx_current(), "hide_form", form, list)
end
function hide_form(form, list)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(list) then
    return
  end
  if not mouse_in_form(form) then
    form.groupbox_ctrl.Visible = false
    form.btn_open.Visible = false
  end
  list.NoFrame = true
  local gui = nx_value("gui")
  form.drag_info_size_change.Visible = false
  form.adjuster_1.Visible = false
  list.is_addalpha = false
  list.is_delalpha = true
  form.form_main_sysinfo_logic:FadeForm()
end
function mouse_in_form(mltbox)
  local form = nx_value(FORM_MAIN_SYSINFO)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  local mouse_x, mouse_y = gui:GetCursorPosition()
  if nx_float(mouse_x) > nx_float(form.groupbox_ctrl.AbsLeft - 5) and nx_float(mouse_x) < nx_float(form.groupbox_ctrl.AbsLeft + form.groupbox_ctrl.Width) and nx_float(mouse_y) > nx_float(form.groupbox_ctrl.AbsTop) and nx_float(mouse_y) < nx_float(form.groupbox_ctrl.AbsTop + form.groupbox_ctrl.Height) then
    return true
  else
    return false
  end
end
function show_form(form, list)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(list) then
    return
  end
  form.groupbox_ctrl.Visible = true
  form.btn_open.Visible = true
  list.NoFrame = false
  form.adjuster_1.Visible = true
  form.drag_info_size_change.Visible = true
  list.is_addalpha = true
  list.is_delalpha = false
  form.form_main_sysinfo_logic:FadeForm()
end
function on_info_group_lost_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local x, y = gui:GetCursorPosition()
    if x < form.groupbox_btn.AbsLeft and x > form.groupbox_btn.AbsLeft + form.groupbox_btn.Width and y < form.groupbox_btn.AbsTop and y > form.groupbox_btn.AbsTop + form.groupbox_btn.Height or x < form.info_group.AbsLeft or y < form.info_group.AbsTop or y > form.info_group.AbsTop + form.info_group.Height then
      form.groupbox_btn.Visible = false
    end
  end
end
function on_info_group_get_capture(self)
  local form = self.ParentForm
  form.groupbox_btn.Visible = true
end
function on_btn_move_lost_capture(self)
  self.Visible = false
end
function on_btn_sys_checked_changed(self)
  local form = self.ParentForm
  form.info_list.Visible = self.Checked
  if self.Checked then
    form.curr_info_list = form.info_list
    form.curr_info_list:GotoEnd()
    form.scrollbar_list.Maximum = form.curr_info_list.VerticalMaxValue
    form.scrollbar_list.Value = form.curr_info_list.VerticalMaxValue
    form.curr_info_list.AutoScroll = true
  end
end
function on_btn_fight_checked_changed(self)
  local form = self.ParentForm
  form.fight_list.Visible = self.Checked
  if self.Checked then
    form.curr_info_list = form.fight_list
    form.curr_info_list:GotoEnd()
    form.scrollbar_list.Maximum = form.curr_info_list.VerticalMaxValue
    form.scrollbar_list.Value = form.curr_info_list.VerticalMaxValue
    form.curr_info_list.AutoScroll = true
  end
end
function on_tbar_transparence_drag_leave(self)
  local group_box = self.Parent
  group_box.Visible = false
end
function on_tbar_transparence_value_changed(self)
  local form = self.ParentForm
  local lbl = form.lbl_p
  lbl.Top = self.Top
  lbl.Left = self.Left
  local length = self.TrackButton.Left
  if 5 < length then
    length = length + 3
  end
  lbl.Width = length
  local num = nx_int(self.Value / 160 * 100)
  if num == nx_int(0) then
    lbl.Visible = false
  else
    lbl.Visible = true
  end
  self.ParentForm.lbl_num.Text = nx_widestr(nx_string(num) .. nx_string("%"))
  if self.Value >= 0 and self.Value <= 160 then
    local both_list = {
      form.info_list,
      form.fight_list
    }
    for _, chat_list in ipairs(both_list) do
      chat_list.cur_back_alpha = self.Value
      chat_list.BlendColor = nx_string(nx_int(chat_list.cur_back_alpha)) .. ",255,255,255"
    end
  end
end
function on_btn_transparence_click(btn)
  local form = btn.ParentForm
  form.groupbox_transparence.Visible = not form.groupbox_transparence.Visible
end
function on_btn_open_click(self)
  local form = self.ParentForm
  form.info_group.Visible = not form.info_group.Visible
  change_open_photo(form)
end
function change_open_photo(form)
  if not form.info_group.Visible then
    form.btn_open.NormalImage = "gui\\common\\button\\btn_left\\btn_left3_out.png"
    form.btn_open.FocusImage = "gui\\common\\button\\btn_left\\btn_left3_on.png"
    form.btn_open.PushImage = "gui\\common\\button\\btn_left\\btn_left3_down.png"
    form.btn_open.HintText = nx_widestr(util_text("ui_tips_xianshi"))
  else
    form.btn_open.NormalImage = "gui\\common\\button\\btn_right\\btn_right3_out.png"
    form.btn_open.FocusImage = "gui\\common\\button\\btn_right\\btn_right3_on.png"
    form.btn_open.PushImage = "gui\\common\\button\\btn_right\\btn_right3_down.png"
    form.btn_open.HintText = nx_widestr(util_text("ui_tips_yincang"))
  end
end
function save_fight_info_tofile()
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return false
  end
  if game_config_info.save_fight_info ~= 1 then
    return true
  end
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) and nx_find_method(form_logic, "SaveFightInfoToFile") then
    form_logic:SaveFightInfoToFile()
  end
  return true
end
function get_format_text(stringid, param1, param2, param3, param4, param5, param6)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_widestr("")
  end
  gui.TextManager:Format_SetIDName(nx_string(stringid))
  if nil ~= param1 then
    gui.TextManager:Format_AddParam(param1)
  end
  if nil ~= param2 then
    gui.TextManager:Format_AddParam(param2)
  end
  if nil ~= param3 then
    gui.TextManager:Format_AddParam(param3)
  end
  if nil ~= param4 then
    gui.TextManager:Format_AddParam(param4)
  end
  if nil ~= param5 then
    gui.TextManager:Format_AddParam(param5)
  end
  if nil ~= param6 then
    gui.TextManager:Format_AddParam(param6)
  end
  return gui.TextManager:Format_GetText()
end
function get_obj_name(player_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return player_name
  end
  local info_pet = ""
  local obj_pet = game_client:GetSceneObj(nx_string(player_name))
  if nx_is_valid(obj_pet) and obj_pet:FindProp("NpcType") and obj_pet:QueryProp("NpcType") == 370 then
    local name_pet = obj_pet:QueryProp("NameFake")
    local name_master = obj_pet:QueryProp("Master")
    info_pet = nx_widestr(name_pet)
    info_pet = info_pet .. nx_widestr(get_format_text("ui_subname_sweet_pet", name_master))
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return info_pet
    end
    local scene = game_client:GetScene()
    if not nx_is_valid(scene) then
      return info_pet
    end
    local is_clone = 0
    if scene:FindProp("SourceID") then
      is_clone = scene:QueryProp("SourceID")
    end
    if nx_int(is_clone) > nx_int(0) then
      if nx_int(is_clone) == nx_int(100) then
        return info_pet
      else
        local arena_side1 = client_player:QueryProp("ArenaSide")
        local arena_side2 = obj_pet:QueryProp("ArenaSide")
        if nx_int(arena_side1) ~= nx_int(arena_side2) then
          if nx_int(arena_side1) == nx_int(1) then
            info_pet = get_format_text("ui_cloneKiller_name")
            info_pet = nx_widestr(get_format_text("ui_sweetemploy_jindi01", info_pet))
          elseif nx_int(arena_side1) == nx_int(2) then
            info_pet = get_format_text("ui_clonePlayer_name")
            info_pet = nx_widestr(get_format_text("ui_sweetemploy_jindi01", info_pet))
          end
        end
      end
    end
    return info_pet
  end
  local client_obj = nx_execute("util_functions", "util_find_client_player_by_name", player_name)
  if not nx_is_valid(client_obj) then
    return player_name
  end
  if not nx_is_valid(client_obj) then
    client_obj = game_client:GetSceneObj(nx_string(client_obj))
    if not nx_is_valid(client_obj) then
      return player_name
    end
  end
  if not game_client:IsPlayer(client_obj.Ident) then
    local sceneobj = game_client:GetScene()
    local client_player = game_client:GetPlayer()
    if is_in_outlandwar() then
      local arenaside_self = client_player:QueryProp("ArenaSide")
      local arenaside_obj = client_obj:QueryProp("ArenaSide")
      if arenaside_self ~= arenaside_obj then
        if nx_int(1) == nx_int(arenaside_obj) then
          return "outland_war_name_a"
        elseif nx_int(2) == nx_int(arenaside_obj) then
          return "outland_war_name_b"
        end
      end
    end
    if sceneobj:FindProp("SourceID") and nx_is_valid(client_player) and nx_is_valid(client_obj) then
      local arenaside_self = client_player:QueryProp("ArenaSide")
      local arenaside_obj = client_obj:QueryProp("ArenaSide")
      if nx_int(arenaside_self) ~= nx_int(arenaside_obj) then
        return "clone_fight"
      end
    end
    local in_battle = client_player:QueryProp("BattlefieldState")
    local STATE_ALREADY_ENTER = 3
    if STATE_ALREADY_ENTER == in_battle then
      local selfArenaSide = client_player:QueryProp("ArenaSide")
      local ARENA_MODE_SINGLE = 0
      if ARENA_MODE_SINGLE == selfArenaSide then
        return "ui_battle_name"
      else
        local arenaSide = client_obj:QueryProp("ArenaSide")
        if selfArenaSide ~= arenaSide then
          return "ui_battle_name"
        end
      end
    end
    if 0 < client_obj:QueryProp("InSBKillBuff") then
      return "ui_jhzb_killer_name"
    end
    local hide_name_type = nx_int(client_obj:QueryProp("IsHideName"))
    if hide_name_type > nx_int(0) then
      if hide_name_type == nx_int(1) then
        return "ui_shimendahui_player"
      elseif hide_name_type == nx_int(2) then
        return "ui_wugenmen_shilian_player"
      end
    end
    if 0 < client_obj:QueryProp("IsHideFace") then
      return "ui_mengmianren"
    end
  end
  return player_name
end
function addhpmp_info(target_name, attack_name, source, script, damage_type, value, over_value, value_type)
  local string_id = ""
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  if nx_string(script) ~= "Buffer" then
    if nx_number(over_value) > 0 then
      string_id = "fight_glhuifu_info_1"
    else
      string_id = "fight_huifu_info_1"
    end
  elseif nx_number(over_value) > 0 then
    string_id = "fight_chixu_glhuifu_info_1"
  else
    string_id = "fight_chixu_huifu_info_1"
  end
  local info = get_format_text(string_id, attack_name, source, target_name, nx_int(value), RESUME_TYPE[nx_number(value_type)], nx_int(over_value))
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function dechpmp_info(target_name, attack_name, source, script, damage_type, value, over_value, value_type, bva)
  local string_id = ""
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  if nx_string(source) == "" then
    string_id = "fight_other_info_1"
  elseif nx_string(script) ~= "Buffer" then
    if nx_number(bva) > 0 then
      if nx_number(over_value) > 0 then
        string_id = "fight_baoji_glshanghai_info_1"
      else
        string_id = "fight_baoji_shanghai_info_1"
      end
    elseif nx_number(over_value) > 0 then
      string_id = "fight_glshanghai_info_1"
    else
      string_id = "fight_shanghai_info_1"
    end
  elseif nx_number(over_value) > 0 then
    string_id = "fight_guoliang_cxdebuff_info_1"
  else
    string_id = "fight_cxdebuff_info_1"
  end
  local info = get_format_text(string_id, attack_name, source, target_name, nx_int(value), DAMAGE_TYPE[nx_number(damage_type) + 1], nx_int(over_value))
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function suckhpmp_info(target_name, attack_name, source, script, damage_type, value, over_value, value_type)
  local string_id = ""
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  if nx_string(script) ~= "Buffer" then
    if nx_number(over_value) > 0 then
      string_id = "fight_glxiqu_info_1"
    else
      string_id = "fight_xiqu_info_1"
    end
    local temp_name = attack_name
    attack_name = target_name
    target_name = temp_name
  elseif nx_number(over_value) > 0 then
    string_id = "fight_chixu_glxiqu_info_1"
  else
    string_id = "fight_chixu_xiqu_info_1"
  end
  local info = get_format_text(string_id, attack_name, source, target_name, nx_int(value), RESUME_TYPE[nx_number(value_type)], nx_int(over_value))
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function suckfaculty_info(target_name, attack_name, source, script, damage_type, value, over_value, value_type)
  local string_id = "fight_xiqu_info_1"
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  local info = get_format_text(string_id, attack_name, source, target_name, nx_int(value), DAMAGE_TYPE[nx_number(damage_type) + 1], nx_int(over_value))
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function shieldhp_info(target_name, attack_name, source, script, damage_type, value, over_value, value_type)
  local string_id = "fight_xishou_info_1"
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  local info = get_format_text(string_id, attack_name, source, target_name, nx_int(value), DAMAGE_TYPE[nx_number(damage_type) + 1], nx_int(over_value))
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function miss_info(target_name, attack_name, source)
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  local info = get_format_text("fight_shanbi_info_1", attack_name, source, target_name)
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function parry_info(target_name, attack_name, source)
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  local info = get_format_text("fight_zhaojia_info_1", attack_name, source, target_name)
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function breakparry_info(target_name, attack_name, skill_name, is_main_player)
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  local info = nx_widestr("")
  if is_main_player == 1 then
    info = get_format_text("fight_pofang_info_2", attack_name, target_name, skill_name)
  else
    info = get_format_text("fight_pofang_info_1", attack_name, skill_name, target_name)
  end
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function dead_info(target_name, attack_name)
  local string_id = "fight_jisha_info_1"
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  local info = get_format_text(string_id, attack_name, "", target_name)
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function pinzhao_info(target_name, attack_name, target_skill_id, attack_skill_id, result)
  if nx_number(result) ~= 0 and nx_number(result) ~= 2 then
    return 0
  end
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  if nx_string(target_skill_id) == "" then
    target_skill_id = "fight_wu_info_1"
  end
  if nx_string(attack_skill_id) == "" then
    attack_skill_id = "fight_wu_info_1"
  end
  local string_id = "fight_bipin_info_1"
  local target_result = ""
  local attack_result = ""
  if nx_number(result) == 2 then
    target_result = PINZHAO_RESULT[1]
    attack_result = PINZHAO_RESULT[2]
  elseif nx_number(result) == 0 then
    target_result = PINZHAO_RESULT[2]
    attack_result = PINZHAO_RESULT[1]
  end
  local info = get_format_text(string_id, target_name, target_skill_id, attack_name, attack_skill_id, target_result, attack_result)
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function buff_info(target_name, attack_name, buff_id, opttype)
  if buff_id == nil or buff_id == "" then
    return 0
  end
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  local visible = buff_static_query(nx_string(buff_id), "Visible")
  if nx_string(visible) ~= "1" then
    return 0
  end
  local is_damage = buff_static_query(nx_string(buff_id), "IsDamage")
  if nx_string(opttype) == "add" then
    if nx_number(is_damage) == 1 then
      string_id = "fight_debuff_info_1"
    else
      string_id = "fight_buff_info_1"
    end
  elseif nx_string(opttype) == "remove" then
    if nx_number(is_damage) == 1 then
      string_id = "fight_xiaosan_info_1"
    else
      string_id = "fight_xiaoshi_info_1"
    end
  elseif nx_string(opttype) == "update" then
    string_id = "fight_shuaxin_info_1"
  end
  local info = get_format_text(string_id, attack_name, buff_id, target_name)
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function addqg_info(target_name, attack_name, source, script, damage_type, value, over_value, value_type)
  local string_id = "fight_huifu_info_1"
  target_name = get_obj_name(target_name)
  attack_name = get_obj_name(attack_name)
  local info = get_format_text(string_id, attack_name, source, target_name, nx_int(value), RESUME_TYPE[nx_number(value_type)], nx_int(over_value))
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function decqg_info(target_name, attack_name, source, script, damage_type, value, over_value, value_type, bva)
end
function show_qg_info(idname, qg_id)
  if last_idname == idname and last_qg_id == qg_id then
    local new_time = nx_function("ext_get_tickcount")
    if new_time - last_time < 2000 then
      return 0
    end
  end
  last_time = nx_function("ext_get_tickcount")
  last_idname = idname
  last_qg_id = qg_id
  local info = get_format_text(idname, qg_id)
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, SYSTYPE_FIGHT, 0)
  end
end
function load_sys_fight_info(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  load_control_info(form.info_list, "info_list")
  load_control_info(form.fight_list, "fight_list")
end
function load_control_info(multitext_box, arrayname)
  if not nx_is_valid(multitext_box) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not common_array:FindArray(nx_string(arrayname)) then
    return
  end
  for index = 0, 200 do
    local chat_type = common_array:FindChild(nx_string(arrayname), "type" .. nx_string(index))
    local chat_info = common_array:FindChild(nx_string(arrayname), "info" .. nx_string(index))
    if chat_type ~= nil and chat_info ~= nil then
      multitext_box.TextColor = chat_channel_clolor_table[chat_type]
      multitext_box:AddHtmlText(nx_widestr(nx_string(chat_info)), nx_int(chat_type))
    else
      break
    end
  end
end
function move_info(org_list, dest_info, key)
  dest_info:ShowKeyItems(key)
  local info_cnt = org_list.ItemCount
  for i = 0, info_cnt do
    if key == org_list:GetItemKeyByIndex(i) then
      dest_info:AddHtmlText(org_list:GetHtmlItemText(i), key)
      org_list:DelHtmlItem(i)
    end
  end
end
function on_btn_tvt_checked_changed(self)
  local form = self.ParentForm
  form.tvt_list.Visible = self.Checked
  if self.Checked then
    form.curr_info_list = form.tvt_list
    form.curr_info_list:GotoEnd()
    form.scrollbar_list.Maximum = form.curr_info_list.VerticalMaxValue
    form.scrollbar_list.Value = form.curr_info_list.VerticalMaxValue
    form.curr_info_list.AutoScroll = true
  end
end
function show_tvt_info(form, b_show)
  form.tvt_list.Visible = b_show
  form.btn_tvt.Visible = b_show
  form.btn_tvt_arrow.Visible = b_show
  refresh_emotion_and_tvt_btn_pos()
end
function init_tvt_info_list()
  local form = nx_value(FORM_MAIN_SYSINFO)
  if nx_is_valid(form) then
    if form.btn_tvt.Visible then
      return
    end
    show_tvt_info(form, true)
    form.tvt_list.Visible = false
    move_info(form.info_list, form.tvt_list, SYSTYPE_TVT)
  end
end
function on_btn_tvt_arrow_click(btn)
  local form = btn.ParentForm
  local groupbox_tvt_info_set = form.groupbox_tvt_info_set
  groupbox_tvt_info_set.AbsLeft = btn.AbsLeft - 5
  groupbox_tvt_info_set.AbsTop = btn.AbsTop - groupbox_tvt_info_set.Height
  groupbox_tvt_info_set.Visible = not groupbox_tvt_info_set.Visible
  groupbox_tvt_info_set.check_type = SYSTYPE_TVT
end
function on_btn_tvt_info_set_click(btn)
  local form = btn.ParentForm
  form.groupbox_tvt_info_set.Visible = false
  if form.groupbox_tvt_info_set.check_type == SYSTYPE_TVT then
    nx_execute("form_stage_main\\form_main\\form_main_page_tvt", "form_open", form.btn_tvt)
  else
    nx_execute("form_stage_main\\form_main\\form_main_page_emotion", "form_open", form.btn_emotion)
  end
end
function on_btn_tvt_info_del_click(btn)
  local form = btn.ParentForm
  form.groupbox_tvt_info_set.Visible = false
  if form.groupbox_tvt_info_set.check_type == SYSTYPE_TVT then
    form.tvt_list:Clear()
    show_tvt_info(form, false)
  else
    form.emotion_list:Clear()
    show_emotion_info(form, false)
  end
  refresh_emotion_and_tvt_btn_pos()
end
function init_emotion_info_list()
  local form = nx_value(FORM_MAIN_SYSINFO)
  if nx_is_valid(form) then
    if form.btn_emotion.Visible then
      return
    end
    show_emotion_info(form, true)
    form.emotion_list.Visible = false
    move_info(form.info_list, form.emotion_list, SYSTYPE_EMOTION)
  end
end
function on_btn_emotion_checked_changed(self)
  local form = self.ParentForm
  form.emotion_list.Visible = self.Checked
  if self.Checked then
    form.curr_info_list = form.emotion_list
    form.curr_info_list:GotoEnd()
    form.scrollbar_list.Maximum = form.curr_info_list.VerticalMaxValue
    form.scrollbar_list.Value = form.curr_info_list.VerticalMaxValue
  end
end
function show_emotion_info(form, b_show)
  form.emotion_list.Visible = b_show
  form.btn_emotion.Visible = b_show
  form.btn_emotion_arrow.Visible = b_show
  refresh_emotion_and_tvt_btn_pos()
end
function on_btn_emotion_arrow_click(btn)
  local form = btn.ParentForm
  local groupbox_tvt_info_set = form.groupbox_tvt_info_set
  groupbox_tvt_info_set.AbsLeft = btn.AbsLeft - 5
  groupbox_tvt_info_set.AbsTop = btn.AbsTop - groupbox_tvt_info_set.Height
  groupbox_tvt_info_set.Visible = not groupbox_tvt_info_set.Visible
  groupbox_tvt_info_set.check_type = SYSTYPE_EMOTION
end
function refresh_emotion_and_tvt_btn_pos()
  local form = nx_value(FORM_MAIN_SYSINFO)
  if not nx_is_valid(form) then
    return
  end
  if not form.btn_emotion.Visible and not form.btn_tvt.Visible then
    return
  elseif form.btn_emotion.Visible and not form.btn_tvt.Visible then
    if form.btn_emotion.Left > form.btn_tvt.Left then
      local left = form.btn_emotion.Left
      form.btn_emotion.Left = form.btn_tvt.Left
      form.btn_tvt.Left = left
      local left = form.btn_emotion_arrow.Left
      form.btn_emotion_arrow.Left = form.btn_tvt_arrow.Left
      form.btn_tvt_arrow.Left = left
    end
  elseif not form.btn_emotion.Visible and form.btn_tvt.Visible and form.btn_emotion.Left < form.btn_tvt.Left then
    local left = form.btn_emotion.Left
    form.btn_emotion.Left = form.btn_tvt.Left
    form.btn_tvt.Left = left
    local left = form.btn_emotion_arrow.Left
    form.btn_emotion_arrow.Left = form.btn_tvt_arrow.Left
    form.btn_tvt_arrow.Left = left
  end
end
function is_in_outlandwar()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_OUTLAND_WAR) == PIS_IN_GAME then
    return true
  end
  return false
end
