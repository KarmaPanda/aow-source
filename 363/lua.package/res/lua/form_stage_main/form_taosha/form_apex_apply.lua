require("util_gui")
require("util_functions")
require("define\\sysinfo_define")
require("custom_sender")
require("form_stage_main\\switch\\switch_define")
require("form_stage_main\\form_taosha\\apex_util")
local FORM = "form_stage_main\\form_taosha\\form_apex_apply"
local acm_rec = "ApexAchievementRec"
local CLIENT_CUSTOMMSG_LUAN_DOU = 902
local ST_FUNCTION_APEX = 890
local ApexClientMsg_Apply = 2
local ApexClientMsg_WeekData = 9
local ApexClientMsg_GetWeekPrize = 10
local ApexClientMsg_GET_AMC_PRIZE = 12
function open_form()
  local form = nx_value(FORM)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM, true)
  end
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  self.day_max_join = 0
  self.week_1_count = 0
  self.week_2_count = 0
  self.week_3_count = 0
  self.week_4_count = 0
  self.week_1_1 = 0
  self.week_1_2 = 0
  self.week_1_3 = 0
  self.week_1_4 = 0
  self.week_2_1 = 0
  self.week_2_2 = 0
  self.week_2_3 = 0
  self.week_2_4 = 0
  self.week_3_1 = 0
  self.week_3_2 = 0
  self.week_3_3 = 0
  self.week_3_4 = 0
  self.week_4_1 = 0
  self.week_4_2 = 0
  self.week_4_3 = 0
  self.week_4_4 = 0
  self.prize_1 = ""
  self.prize_2 = ""
  self.prize_3 = ""
  self.prize_4 = ""
  self.box_apply.Visible = true
  self.box_prize.Visible = false
  self.box_achievement.Visible = false
  self.rbtn_apply.Checked = true
  nx_execute("custom_sender", "custom_apex", nx_int(ApexClientMsg_WeekData))
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_apply_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if IsInTeam() then
    local gui = nx_value("gui")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, gui.TextManager:GetText("ui_apex_010"))
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "cancel" then
      return
    end
    nx_execute("custom_sender", "custom_apex", nx_int(ApexClientMsg_Apply))
  else
    nx_execute("custom_sender", "custom_apex", nx_int(ApexClientMsg_Apply))
  end
end
function IsInTeam()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local teamid = client_player:QueryProp("TeamID")
  if teamid == 0 then
    return false
  end
  local selfname = client_player:QueryProp("Name")
  local LeaderName = client_player:QueryProp("TeamCaptain")
  if nx_widestr(selfname) ~= nx_widestr(LeaderName) then
    return false
  end
  return true
end
function week_data(...)
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local temp_table = arg
  form.day_max_join = temp_table[1]
  form.prize_1 = nx_string(temp_table[2])
  form.prize_2 = nx_string(temp_table[3])
  form.prize_3 = nx_string(temp_table[4])
  form.prize_4 = nx_string(temp_table[5])
  form.week_1_count = temp_table[6]
  form.week_2_count = temp_table[7]
  form.week_3_count = temp_table[8]
  form.week_4_count = temp_table[9]
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  local index = 1
  local count = table.getn(temp_table)
  for i = 1, form.week_1_count do
    local prop_name = string.format("%s_%s", nx_string("week_1"), nx_string(i))
    if prop_name == "week_1_1" then
      form.week_1_1 = temp_table[index]
    elseif prop_name == "week_1_2" then
      form.week_1_2 = temp_table[index]
    elseif prop_name == "week_1_3" then
      form.week_1_3 = temp_table[index]
    elseif prop_name == "week_1_4" then
      form.week_1_4 = temp_table[index]
    end
    index = index + 1
  end
  for i = 1, form.week_2_count do
    local prop_name = string.format("%s_%s", nx_string("week_2"), nx_string(i))
    if prop_name == "week_2_1" then
      form.week_2_1 = temp_table[index]
    elseif prop_name == "week_2_2" then
      form.week_2_2 = temp_table[index]
    elseif prop_name == "week_2_3" then
      form.week_2_3 = temp_table[index]
    elseif prop_name == "week_2_4" then
      form.week_2_4 = temp_table[index]
    end
    index = index + 1
  end
  for i = 1, form.week_3_count do
    local prop_name = string.format("%s_%s", nx_string("week_3"), nx_string(i))
    if prop_name == "week_3_1" then
      form.week_3_1 = temp_table[index]
    elseif prop_name == "week_3_2" then
      form.week_3_2 = temp_table[index]
    elseif prop_name == "week_3_3" then
      form.week_3_3 = temp_table[index]
    elseif prop_name == "week_3_4" then
      form.week_3_4 = temp_table[index]
    end
    index = index + 1
  end
  for i = 1, form.week_4_count do
    local prop_name = string.format("%s_%s", nx_string("week_4"), nx_string(i))
    if prop_name == "week_4_1" then
      form.week_4_1 = temp_table[index]
    elseif prop_name == "week_4_2" then
      form.week_4_2 = temp_table[index]
    elseif prop_name == "week_4_3" then
      form.week_4_3 = temp_table[index]
    elseif prop_name == "week_4_4" then
      form.week_4_4 = temp_table[index]
    end
    index = index + 1
  end
  for i = 1, 4 do
    local prop_name = string.format("%s_%s", nx_string("week_1"), nx_string(i))
    local prop = nx_custom(form, prop_name)
    if nx_int(prop) == nx_int(0) then
      local control_name = string.format("%s_%s", nx_string("lbl_name_1"), nx_string(i))
      local control = nx_custom(form, nx_string(control_name))
      control.Visible = false
    end
  end
  for i = 1, 4 do
    local prop_name = string.format("%s_%s", nx_string("week_2"), nx_string(i))
    local prop = nx_find_custom(form, prop_name)
    if nx_int(prop) == nx_int(0) then
      local control_name = string.format("%s_%s", nx_string("lbl_name_2"), nx_string(i))
      local control = nx_custom(form, nx_string(control_name))
      control.Visible = false
    end
  end
  for i = 1, 4 do
    local prop_name = string.format("%s_%s", nx_string("week_3"), nx_string(i))
    local prop = nx_find_custom(form, prop_name)
    if nx_int(prop) == nx_int(0) then
      local control_name = string.format("%s_%s", nx_string("lbl_name_3"), nx_string(i))
      local control = nx_custom(form, nx_string(control_name))
      control.Visible = false
    end
  end
  for i = 1, 4 do
    local prop_name = string.format("%s_%s", nx_string("week_4"), nx_string(i))
    local prop = nx_find_custom(form, prop_name)
    if nx_int(prop) == nx_int(0) then
      local control_name = string.format("%s_%s", nx_string("lbl_name_4"), nx_string(i))
      local control = nx_custom(form, nx_string(control_name))
      control.Visible = false
    end
  end
  refresh_form(form)
end
function refresh_form(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local joincount = nx_int(client_player:QueryProp("ApexTodayJoin"))
  if joincount > nx_int(form.day_max_join) then
    joincount = nx_int(form.day_max_join)
  end
  form.lbl_week_apply_num.Text = nx_widestr(nx_string(joincount) .. "/" .. nx_string(form.day_max_join))
  if nx_int(form.week_1_1) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekGame")
    if nx_int(prop) > nx_int(form.week_1_1) then
      prop = form.week_1_1
    end
    if nx_int(prop) == nx_int(form.week_1_1) then
      form.lbl_week_1_1.ForeColor = "255,0,255,0"
      form.lbl_name_1_1.ForeColor = "255,0,255,0"
    else
      form.lbl_week_1_1.ForeColor = "255,255,255,255"
      form.lbl_name_1_1.ForeColor = "255,255,255,255"
    end
    form.lbl_week_1_1.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_1_1))
  end
  if nx_int(form.week_1_2) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekKill")
    if nx_int(prop) > nx_int(form.week_1_2) then
      prop = form.week_1_2
    end
    if nx_int(prop) == nx_int(form.week_1_2) then
      form.lbl_week_1_2.ForeColor = "255,0,255,0"
      form.lbl_name_1_2.ForeColor = "255,0,255,0"
    else
      form.lbl_week_1_2.ForeColor = "255,255,255,255"
      form.lbl_name_1_2.ForeColor = "255,255,255,255"
    end
    form.lbl_week_1_2.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_1_2))
  end
  if nx_int(form.week_1_3) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekHelpKill")
    if nx_int(prop) > nx_int(form.week_1_3) then
      prop = form.week_1_3
    end
    if nx_int(prop) == nx_int(form.week_1_3) then
      form.lbl_week_1_3.ForeColor = "255,0,255,0"
      form.lbl_name_1_3.ForeColor = "255,0,255,0"
    else
      form.lbl_week_1_3.ForeColor = "255,255,255,255"
      form.lbl_name_1_3.ForeColor = "255,255,255,255"
    end
    form.lbl_week_1_3.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_1_3))
  end
  if nx_int(form.week_1_4) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekRescue")
    if nx_int(prop) > nx_int(form.week_1_4) then
      prop = form.week_1_4
    end
    if nx_int(prop) == nx_int(form.week_1_4) then
      form.lbl_week_1_4.ForeColor = "255,0,255,0"
      form.lbl_name_1_4.ForeColor = "255,0,255,0"
    else
      form.lbl_week_1_4.ForeColor = "255,255,255,255"
      form.lbl_name_1_4.ForeColor = "255,255,255,255"
    end
    form.lbl_week_1_4.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_1_4))
  end
  if nx_int(form.week_2_1) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekGame")
    if nx_int(prop) > nx_int(form.week_2_1) then
      prop = form.week_2_1
    end
    if nx_int(prop) == nx_int(form.week_2_1) then
      form.lbl_week_2_1.ForeColor = "255,0,255,0"
      form.lbl_name_2_1.ForeColor = "255,0,255,0"
    else
      form.lbl_week_2_1.ForeColor = "255,255,255,255"
      form.lbl_name_2_1.ForeColor = "255,255,255,255"
    end
    form.lbl_week_2_1.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_2_1))
  end
  if nx_int(form.week_2_2) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekRelife")
    if nx_int(prop) > nx_int(form.week_2_2) then
      prop = form.week_2_2
    end
    if nx_int(prop) == nx_int(form.week_2_2) then
      form.lbl_week_2_2.ForeColor = "255,0,255,0"
      form.lbl_name_2_2.ForeColor = "255,0,255,0"
    else
      form.lbl_week_2_2.ForeColor = "255,255,255,255"
      form.lbl_name_2_2.ForeColor = "255,255,255,255"
    end
    form.lbl_week_2_2.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_2_2))
  end
  if nx_int(form.week_2_3) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekKill")
    if nx_int(prop) > nx_int(form.week_2_3) then
      prop = form.week_2_3
    end
    if nx_int(prop) == nx_int(form.week_2_3) then
      form.lbl_week_2_3.ForeColor = "255,0,255,0"
      form.lbl_name_2_3.ForeColor = "255,0,255,0"
    else
      form.lbl_week_2_3.ForeColor = "255,255,255,255"
      form.lbl_name_2_3.ForeColor = "255,255,255,255"
    end
    form.lbl_week_2_3.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_2_3))
  end
  if nx_int(form.week_2_4) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekRank1_3")
    if nx_int(prop) > nx_int(form.week_2_4) then
      prop = form.week_2_4
    end
    if nx_int(prop) == nx_int(form.week_2_4) then
      form.lbl_week_2_4.ForeColor = "255,0,255,0"
      form.lbl_name_2_4.ForeColor = "255,0,255,0"
    else
      form.lbl_week_2_4.ForeColor = "255,255,255,255"
      form.lbl_name_2_4.ForeColor = "255,255,255,255"
    end
    form.lbl_week_2_4.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_2_4))
  end
  if nx_int(form.week_3_1) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekGame")
    if nx_int(prop) > nx_int(form.week_3_1) then
      prop = form.week_3_1
    end
    if nx_int(prop) == nx_int(form.week_3_1) then
      form.lbl_week_3_1.ForeColor = "255,0,255,0"
      form.lbl_name_3_1.ForeColor = "255,0,255,0"
    else
      form.lbl_week_3_1.ForeColor = "255,255,255,255"
      form.lbl_name_3_1.ForeColor = "255,255,255,255"
    end
    form.lbl_week_3_1.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_3_1))
  end
  if nx_int(form.week_3_2) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekKill")
    if nx_int(prop) > nx_int(form.week_3_2) then
      prop = form.week_3_2
    end
    if nx_int(prop) == nx_int(form.week_3_2) then
      form.lbl_week_3_2.ForeColor = "255,0,255,0"
      form.lbl_name_3_2.ForeColor = "255,0,255,0"
    else
      form.lbl_week_3_2.ForeColor = "255,255,255,255"
      form.lbl_name_3_2.ForeColor = "255,255,255,255"
    end
    form.lbl_week_3_2.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_3_2))
  end
  if nx_int(form.week_3_3) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekHelpKill")
    if nx_int(prop) > nx_int(form.week_3_3) then
      prop = form.week_3_3
    end
    if nx_int(prop) == nx_int(form.week_3_3) then
      form.lbl_week_3_3.ForeColor = "255,0,255,0"
      form.lbl_name_3_3.ForeColor = "255,0,255,0"
    else
      form.lbl_week_3_3.ForeColor = "255,255,255,255"
      form.lbl_name_3_3.ForeColor = "255,255,255,255"
    end
    form.lbl_week_3_3.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_3_3))
  end
  if nx_int(form.week_3_4) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekRescue")
    if nx_int(prop) > nx_int(form.week_3_4) then
      prop = form.week_3_4
    end
    if nx_int(prop) == nx_int(form.week_3_4) then
      form.lbl_week_3_4.ForeColor = "255,0,255,0"
      form.lbl_name_3_4.ForeColor = "255,0,255,0"
    else
      form.lbl_week_3_4.ForeColor = "255,255,255,255"
      form.lbl_name_3_4.ForeColor = "255,255,255,255"
    end
    form.lbl_week_3_4.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_3_4))
  end
  if nx_int(form.week_4_1) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekGame")
    if nx_int(prop) > nx_int(form.week_4_1) then
      prop = form.week_4_1
    end
    if nx_int(prop) == nx_int(form.week_4_1) then
      form.lbl_week_4_1.ForeColor = "255,0,255,0"
      form.lbl_name_4_1.ForeColor = "255,0,255,0"
    else
      form.lbl_week_4_1.ForeColor = "255,255,255,255"
      form.lbl_name_4_1.ForeColor = "255,255,255,255"
    end
    form.lbl_week_4_1.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_4_1))
  end
  if nx_int(form.week_4_2) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekRelife")
    if nx_int(prop) > nx_int(form.week_4_2) then
      prop = form.week_4_2
    end
    if nx_int(prop) == nx_int(form.week_4_2) then
      form.lbl_week_4_2.ForeColor = "255,0,255,0"
      form.lbl_name_4_2.ForeColor = "255,0,255,0"
    else
      form.lbl_week_4_2.ForeColor = "255,255,255,255"
      form.lbl_name_4_2.ForeColor = "255,255,255,255"
    end
    form.lbl_week_4_2.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_4_2))
  end
  if nx_int(form.week_4_3) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekKill")
    if nx_int(prop) > nx_int(form.week_4_3) then
      prop = form.week_4_3
    end
    if nx_int(prop) == nx_int(form.week_4_3) then
      form.lbl_week_4_3.ForeColor = "255,0,255,0"
      form.lbl_name_4_3.ForeColor = "255,0,255,0"
    else
      form.lbl_week_4_3.ForeColor = "255,255,255,255"
      form.lbl_name_4_3.ForeColor = "255,255,255,255"
    end
    form.lbl_week_4_3.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_4_3))
  end
  if nx_int(form.week_4_4) ~= nx_int(0) then
    local prop = client_player:QueryProp("ApexWeekWin")
    if nx_int(prop) > nx_int(form.week_4_4) then
      prop = form.week_4_4
    end
    if nx_int(prop) == nx_int(form.week_4_4) then
      form.lbl_week_4_4.ForeColor = "255,0,255,0"
      form.lbl_name_4_4.ForeColor = "255,0,255,0"
    else
      form.lbl_week_4_4.ForeColor = "255,255,255,255"
      form.lbl_name_4_4.ForeColor = "255,255,255,255"
    end
    form.lbl_week_4_4.Text = nx_widestr(nx_string(prop) .. "/" .. nx_string(form.week_4_4))
  end
  form.btn_1.Enabled = can_get_prize_1(form)
  form.btn_2.Enabled = can_get_prize_2(form)
  form.btn_3.Enabled = can_get_prize_3(form)
  form.btn_4.Enabled = can_get_prize_4(form)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local photo_1 = ItemQuery:GetItemPropByConfigID(form.prize_1, "Photo")
  form.imagegrid_1:AddItem(0, photo_1, nx_widestr(form.prize_1), 1, 0)
  local photo_2 = ItemQuery:GetItemPropByConfigID(form.prize_2, "Photo")
  form.imagegrid_2:AddItem(0, photo_2, nx_widestr(form.prize_2), 1, 0)
  local photo_3 = ItemQuery:GetItemPropByConfigID(form.prize_3, "Photo")
  form.imagegrid_3:AddItem(0, photo_3, nx_widestr(form.prize_3), 1, 0)
  local photo_4 = ItemQuery:GetItemPropByConfigID(form.prize_4, "Photo")
  form.imagegrid_4:AddItem(0, photo_4, nx_widestr(form.prize_4), 1, 0)
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if form.rbtn_apply.Checked == true then
    form.box_apply.Visible = true
    form.box_prize.Visible = false
    form.box_achievement.Visible = false
  end
  if form.rbtn_prize.Checked == true then
    form.box_apply.Visible = false
    form.box_prize.Visible = true
    form.box_achievement.Visible = false
  end
  if form.rbtn_achievement.Checked == true then
    form.box_apply.Visible = false
    form.box_prize.Visible = false
    form.box_achievement.Visible = true
    form.rbtn_acm_1.Checked = true
  end
end
function can_get_prize_1(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local prop_1 = client_player:QueryProp("ApexWeekGame")
  local prop_2 = client_player:QueryProp("ApexWeekKill")
  local prop_3 = client_player:QueryProp("ApexWeekHelpKill")
  local prop_4 = client_player:QueryProp("ApexWeekRescue")
  if nx_int(prop_1) >= nx_int(form.week_1_1) and nx_int(prop_2) >= nx_int(form.week_1_2) and nx_int(prop_3) >= nx_int(form.week_1_3) and nx_int(prop_4) >= nx_int(form.week_1_4) then
    return true
  end
  return false
end
function can_get_prize_2(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local prop_1 = client_player:QueryProp("ApexWeekGame")
  local prop_2 = client_player:QueryProp("ApexWeekRelife")
  local prop_3 = client_player:QueryProp("ApexWeekKill")
  local prop_4 = client_player:QueryProp("ApexWeekRank1_3")
  if nx_int(prop_1) >= nx_int(form.week_2_1) and nx_int(prop_2) >= nx_int(form.week_2_2) and nx_int(prop_3) >= nx_int(form.week_2_3) and nx_int(prop_4) >= nx_int(form.week_2_4) then
    return true
  end
  return false
end
function can_get_prize_3(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local prop_1 = client_player:QueryProp("ApexWeekGame")
  local prop_2 = client_player:QueryProp("ApexWeekKill")
  local prop_3 = client_player:QueryProp("ApexWeekHelpKill")
  local prop_4 = client_player:QueryProp("ApexWeekRescue")
  if nx_int(prop_1) >= nx_int(form.week_3_1) and nx_int(prop_2) >= nx_int(form.week_3_2) and nx_int(prop_3) >= nx_int(form.week_3_3) and nx_int(prop_4) >= nx_int(form.week_3_4) then
    return true
  end
  return false
end
function can_get_prize_4(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local prop_1 = client_player:QueryProp("ApexWeekGame")
  local prop_2 = client_player:QueryProp("ApexWeekRelife")
  local prop_3 = client_player:QueryProp("ApexWeekKill")
  local prop_4 = client_player:QueryProp("ApexWeekWin")
  if nx_int(prop_1) >= nx_int(form.week_4_1) and nx_int(prop_2) >= nx_int(form.week_4_2) and nx_int(prop_3) >= nx_int(form.week_4_3) and nx_int(prop_4) >= nx_int(form.week_4_4) then
    return true
  end
  return false
end
function on_btn_1_click(btn)
  nx_execute("custom_sender", "custom_apex", nx_int(ApexClientMsg_GetWeekPrize), 1)
end
function on_btn_2_click(btn)
  nx_execute("custom_sender", "custom_apex", nx_int(ApexClientMsg_GetWeekPrize), 2)
end
function on_btn_3_click(btn)
  nx_execute("custom_sender", "custom_apex", nx_int(ApexClientMsg_GetWeekPrize), 3)
end
function on_btn_4_click(btn)
  nx_execute("custom_sender", "custom_apex", nx_int(ApexClientMsg_GetWeekPrize), 4)
end
function on_imagegrid_prize_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_prize_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
  if 0 >= table.getn(table_prop_name) then
    return
  end
  table_prop_value.ConfigID = nx_string(prize_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", "task_grid_data")
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_set_custom(grid.Data, "is_static", true)
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
  grid.Data:ClearChild()
end
function close_form()
  local form = nx_value(FORM)
  if nx_is_valid(form) then
    form:Close()
  end
end
function clone_control(form, control_name, aid)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local control = nx_custom(form, nx_string(control_name))
  local new_control = gui.Designer:Clone(control)
  if not nx_is_valid(new_control) then
    return nx_null()
  end
  nx_bind_script(new_control, nx_current())
  new_control.DesignMode = false
  new_control.Name = string.format("%s_%s", nx_string(control_name), nx_string(aid))
  new_control.Visible = true
  new_control.aid = aid
  local child_list = control:GetChildControlList()
  for _, child_control in pairs(child_list) do
    if nx_is_valid(child_control) then
      local new_child = gui.Designer:Clone(child_control)
      new_child.fatherctl = new_control
      new_child.DesignMode = false
      new_child.Name = string.format("%s_%s", nx_string(child_control.Name), nx_string(aid))
      new_child.aid = aid
      new_control:Add(new_child)
    end
  end
  return new_control
end
function refresh_box_achievement()
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local TaoShaManager = nx_value("TaoShaManager")
  if not nx_is_valid(TaoShaManager) then
    return
  end
  local framebox = form.achievement_frame
  local scroll_value = framebox.VScrollBar.Value
  framebox:DeleteAll()
  local temp_table = TaoShaManager:GetAllAchievementConfig()
  local count = table.getn(temp_table)
  if nx_int(count) <= nx_int(0) then
    return
  end
  local gui = nx_value("gui")
  framebox.IsEditMode = true
  local index = 1
  local finish_count = 0
  local max_count = 0
  for i = 1, count do
    local count = 0
    local get_prize = 0
    local config = temp_table[i]
    local row = client_player:FindRecordRow(acm_rec, 0, nx_string(config))
    if nx_int(row) >= nx_int(0) then
      count = client_player:QueryRecord(acm_rec, row, 1)
      get_prize = client_player:QueryRecord(acm_rec, row, 2)
    end
    local sub_count = TaoShaManager:GetApexItemSubCount(config)
    for j = 1, sub_count do
      local item_config = TaoShaManager:GetItemByPropConfig(config, j - 1)
      local title = TaoShaManager:GetApexTitle(config, j - 1)
      local content = TaoShaManager:GetApexContent(config, j - 1)
      local finish = TaoShaManager:GetApexItemFinish(j - 1, get_prize)
      local maxcount = TaoShaManager:GetApexMaxCount(config, j - 1)
      local subcount = count
      if nx_number(subcount) > nx_number(maxcount) then
        subcount = maxcount
      end
      if nx_int(finish) == nx_int(1) then
        finish_count = finish_count + 1
      end
      if form.rbtn_acm_2.Checked == true then
        if nx_int(finish) == nx_int(1) then
          add_frame_child(form, framebox, max_count, j, item_config, config, title, content, subcount, finish, maxcount)
        end
      elseif form.rbtn_acm_3.Checked == true then
        if nx_int(finish) == nx_int(0) then
          add_frame_child(form, framebox, max_count, j, item_config, config, title, content, subcount, finish, maxcount)
        end
      else
        add_frame_child(form, framebox, max_count, j, item_config, config, title, content, subcount, finish, maxcount)
      end
      max_count = max_count + 1
    end
  end
  form.pbar_acm.Value = finish_count
  form.pbar_acm.Maximum = max_count
  framebox.IsEditMode = false
  framebox:ResetChildrenYPos()
  framebox.VScrollBar.Value = scroll_value
end
function add_frame_child(form, framebox, i, sub_index, item_config, config, title, content, count, finish, maxcount)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_box = clone_control(form, "achievement_item", nx_string(i))
  framebox:Add(item_box)
  item_box.Left = 5
  local child_name = string.format("%s_%s", nx_string("item_title"), nx_string(i))
  local item_title_control = item_box:Find(child_name)
  item_title_control.Text = nx_widestr(gui.TextManager:GetText(nx_string(title)))
  gui.TextManager:Format_SetIDName(content)
  gui.TextManager:Format_AddParam(nx_int(count))
  child_name = string.format("%s_%s", nx_string("item_content"), nx_string(i))
  local item_content_control = item_box:Find(child_name)
  item_content_control.Text = nx_widestr(gui.TextManager:Format_GetText())
  child_name = string.format("%s_%s", nx_string("item_imagegrid"), nx_string(i))
  local item_imagegrid_control = item_box:Find(child_name)
  nx_bind_script(item_imagegrid_control, nx_current())
  nx_callback(item_imagegrid_control, "on_mousein_grid", "on_imagegrid_prize_mousein_grid")
  nx_callback(item_imagegrid_control, "on_mouseout_grid", "on_imagegrid_prize_mouseout_grid")
  local photo = ItemQuery:GetItemPropByConfigID(item_config, "Photo")
  item_imagegrid_control:AddItem(0, photo, nx_widestr(item_config), 1, 0)
  child_name = string.format("%s_%s", nx_string("item_getprize"), nx_string(i))
  local item_getprize_control = item_box:Find(child_name)
  nx_bind_script(item_getprize_control, nx_current())
  nx_callback(item_getprize_control, "on_click", "on_item_getprize_click")
  item_getprize_control.index = sub_index
  item_getprize_control.prop_config = config
  if nx_number(count) < nx_number(maxcount) then
    item_getprize_control.Enabled = false
  else
    item_getprize_control.Enabled = true
  end
  child_name = string.format("%s_%s", nx_string("lbl_finish"), nx_string(i))
  local lbl_finish_control = item_box:Find(child_name)
  if nx_int(finish) == nx_int(1) then
    item_getprize_control.Visible = false
    lbl_finish_control.Visible = true
  else
    item_getprize_control.Visible = true
    lbl_finish_control.Visible = false
  end
end
function on_item_getprize_click(btn)
  nx_execute("custom_sender", "custom_apex", nx_int(ApexClientMsg_GET_AMC_PRIZE), nx_string(btn.prop_config), nx_int(btn.index - 1))
end
function on_rbtn_acm_checked_changed(rbtn)
  refresh_box_achievement()
end
