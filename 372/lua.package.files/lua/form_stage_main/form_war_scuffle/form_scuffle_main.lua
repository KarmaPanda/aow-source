require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\sysinfo_define")
require("custom_sender")
require("form_stage_main\\switch\\switch_define")
local CLIENT_CUSTOMMSG_LUAN_DOU = 784
local ST_FUNCTION_LUAN_DOU = 790
local FORM_SCUFFLE_MAIN = "form_stage_main\\form_war_scuffle\\form_scuffle_main"
local luandou_file = "share\\War\\LuanDou\\luandou.ini"
local LuanDouClientMsg_OpenForm = 1
local LuanDouClientMsg_LuanDouData = 9
local LuanDouClientMsg_PlayerIsInCross = 10
local LuanDouClientMsg_WarRecord = 11
local LuanDouClientMsg_Apply = 101
local LuanDouClientMsg_RequestMainUI = 103
local laundou_zhaunbei = "luandou_zhaungbei_"
local luandou_record_head_info = {
  "ui_luandou_time",
  "ui_luandou_player_name",
  "ui_luandou_server_name",
  "ui_luandou_skill_one",
  "ui_luandou_skill_two",
  "ui_luandou_skill_three",
  "ui_luandou_neigong",
  "ui_luandou_kill",
  "ui_luandou_assist",
  "ui_luandou_damage",
  "ui_luandou_score"
}
local luandou_self_record_head_info = {
  "ui_luandou_time",
  "ui_luandou_skill_one",
  "ui_luandou_skill_two",
  "ui_luandou_skill_three",
  "ui_luandou_neigong",
  "ui_luandou_kill",
  "ui_luandou_assist",
  "ui_luandou_damage",
  "ui_luandou_score"
}
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_LUAN_DOU) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_01")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  custom_open_form()
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
  local groupbox = self.groupbox_sub
  if not nx_is_valid(groupbox) then
    return
  end
  local form_choose = util_get_form("form_stage_main\\form_war_scuffle\\form_scuffle_skill_choose", true, false)
  if nx_is_valid(form_choose) then
    form_choose.Visible = true
    form_choose.Fixed = true
    form_choose.Left = 4
    form_choose.Top = 0
    groupbox:Add(form_choose)
    self.form_choose = form_choose
  end
  local form_single = util_get_form("form_stage_main\\form_war_scuffle\\form_scuffle_single", true, false)
  if nx_is_valid(form_single) then
    form_single.Visible = true
    form_single.Fixed = true
    form_single.Left = 4
    form_single.Top = 0
    groupbox:Add(form_single)
    self.form_single = form_single
  end
  custom_luandou_data()
  custom_main_form_data()
  self.rbtn_main.Checked = true
  updata_player_ng_data()
  updata_player_equip_data()
  updata_player_jm_data()
  init_prize_imagegrid(self)
  self.btn_left.Visible = false
  self.rbtn_1.Checked = true
  init_record_grid(self.textgrid_1)
  init_self_record_grid(self.textgrid_2)
  custom_luandou_war_record()
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  close_all_sub_page(self)
  nx_destroy(self)
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return false
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  hide_all_sub_page(form)
  if "rbtn_main" == rbtn.Name then
    form.groupbox_2.Visible = true
    form.groupbox_sub.Visible = false
    form.groupbox_5.Visible = false
    form.groupbox_7.Visible = false
  end
  if "rbtn_energy" == rbtn.Name then
    if not nx_find_custom(form, "form_choose") or not nx_is_valid(form.form_choose) then
      local form_choose = util_get_form("form_stage_main\\form_war_scuffle\\form_scuffle_skill_choose", true, false)
      if nx_is_valid(form_choose) then
        form_choose.Visible = true
        form_choose.Fixed = true
        form_choose.Left = 4
        form_choose.Top = 0
        form.groupbox_sub:Add(form_choose)
        form.form_choose = form_choose
      end
    end
    form.groupbox_2.Visible = false
    form.groupbox_sub.Visible = true
    form.groupbox_5.Visible = false
    form.groupbox_7.Visible = false
    form.form_choose.Visible = true
    form:ToFront(form.form_choose)
  end
  if "rbtn_achieve" == rbtn.Name then
    if not nx_find_custom(form, "form_single") or not nx_is_valid(form.form_single) then
      local form_single = util_get_form("form_stage_main\\form_war_scuffle\\form_scuffle_single", true, false)
      if nx_is_valid(form_single) then
        form_single.Visible = true
        form_single.Fixed = true
        form_single.Left = 4
        form_single.Top = 0
        form.groupbox_sub:Add(form_single)
        form.form_single = form_single
      end
    end
    form.groupbox_2.Visible = false
    form.groupbox_sub.Visible = true
    form.groupbox_5.Visible = false
    form.groupbox_7.Visible = false
    form.form_single.Visible = true
    form:ToFront(form.form_single)
  end
  if "rbtn_award" == rbtn.Name then
    form.groupbox_2.Visible = false
    form.groupbox_sub.Visible = false
    form.groupbox_5.Visible = true
    form.groupbox_7.Visible = false
  end
  if "rbtn_record" == rbtn.Name then
    form.groupbox_2.Visible = false
    form.groupbox_sub.Visible = false
    form.groupbox_5.Visible = false
    form.groupbox_7.Visible = true
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_team_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_request_attend(nx_int(2))
end
function on_btn_single_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_request_attend(nx_int(1))
end
function on_imagegrid_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  if not nx_find_custom(grid, "config_id") then
    return
  end
  local strConfidId = grid.config_id
  local config_id_list = util_split_string(strConfidId)
  local strConfig = config_id_list[index + 1]
  if strConfig == "" or strConfig == nil then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorClientPos()
  nx_execute("tips_game", "show_tips_by_config", strConfig, x, y)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_6.Visible = false
  form.btn_left.Visible = true
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_6.Visible = true
  form.btn_left.Visible = false
end
function on_rbtn_best_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local nIndex = rbtn.DataSource
  if nx_int(nIndex) == nx_int(1) then
    form.groupbox_9.Visible = true
    form.groupbox_8.Visible = false
  elseif nx_int(nIndex) == nx_int(2) then
    form.groupbox_9.Visible = false
    form.groupbox_8.Visible = true
  end
end
function custom_open_form()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_OpenForm))
end
function custom_request_attend(attend_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_Apply), nx_int(attend_index))
end
function custom_luandou_data()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_LuanDouData))
end
function custom_main_form_data()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_RequestMainUI))
end
function custom_luandou_war_record()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_WarRecord))
end
function rec_can_open_form(...)
  local flag = nx_int(arg[1])
  if nx_int(flag) == nx_int(1) then
    local form = util_get_form(FORM_SCUFFLE_MAIN, true, false)
    if nx_is_valid(form) then
      form:Show()
      form.Visible = true
    end
  end
end
function rec_luan_dou_data(...)
  local form = nx_value(FORM_SCUFFLE_MAIN)
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(arg)
  if nx_int(count) == nx_int(0) then
    return
  end
  form.lbl_luandou_name.Text = util_text(nx_string(arg[1]))
  form.mltbox_luandou_state.HtmlText = util_text(nx_string(arg[2]))
  local gbox = form.groupbox_3
  if not nx_is_valid(gbox) then
    return
  end
  for i = 3, count do
    local lbl_name = "lbl_luandou_factor_" .. nx_string(i - 2)
    local lbl = gbox:Find(nx_string(lbl_name))
    if nx_is_valid(lbl) then
      lbl.Text = util_text(nx_string(arg[i]))
      local tips = "tips_" .. nx_string(arg[i])
      lbl.HintText = util_text(nx_string(tips))
    end
  end
end
function rec_every_week_goal(...)
  local form = nx_value(FORM_SCUFFLE_MAIN)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(#arg) < nx_int(4) then
    return
  end
  form.lbl_left_time.Text = nx_widestr(nx_string(arg[2]) .. nx_string("/") .. nx_string(arg[3]))
  local strGoal = nx_string(arg[4])
  local goal_list = util_split_string(strGoal, "|")
  for i = 1, #goal_list do
    local strOneGoal = goal_list[i]
    local one_goal_list = util_split_string(strOneGoal, ",")
    if nx_int(#one_goal_list) == nx_int(3) then
      local nGoalNum = one_goal_list[1]
      local nMaxNum = one_goal_list[2]
      if nx_int64(nGoalNum) > nx_int64(nMaxNum) then
        nGoalNum = nMaxNum
      end
      if nx_int(i) == nx_int(2) then
        nGoalNum = math.floor(nx_int(nGoalNum) / 10000)
        nGoalNum = nx_widestr(nGoalNum) .. nx_widestr(util_text("ui_wan"))
        nMaxNum = math.floor(nx_int(nMaxNum) / 10000)
        nMaxNum = nx_widestr(nMaxNum) .. nx_widestr(util_text("ui_wan"))
      end
      local flag = nx_int(one_goal_list[3])
      local lbl_get_name = "lbl_goal_get_" .. nx_string(i)
      local lbl_get = form.groupbox_4:Find(nx_string(lbl_get_name))
      if nx_is_valid(lbl_get) then
        if nx_int(flag) == nx_int(1) then
          lbl_get.BackImage = "gui/special/war_scuffle/1_btn.png"
        else
          lbl_get.Text = nx_widestr(nGoalNum) .. nx_widestr("/") .. nx_widestr(nMaxNum)
          lbl_get.BackImage = ""
        end
      end
    end
  end
end
function close_all_sub_page(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "form_choose") and nx_is_valid(form.form_choose) then
    form.form_choose:Close()
  end
  if nx_find_custom(form, "form_single") and nx_is_valid(form.form_single) then
    form.form_single:Close()
  end
  return
end
function hide_all_sub_page(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_2.Visible = false
  form.groupbox_sub.Visible = false
  form.groupbox_5.Visible = false
  form.groupbox_7.Visible = false
  if nx_find_custom(form, "form_choose") and nx_is_valid(form.form_choose) then
    form.form_choose.Visible = false
  end
  if nx_find_custom(form, "form_single") and nx_is_valid(form.form_single) then
    form.form_single.Visible = false
  end
  return
end
function close_form()
  local form = nx_value(FORM_SCUFFLE_MAIN)
  if nx_is_valid(form) then
    form:Close()
  end
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
function updata_player_equip_data()
  local form = nx_value(FORM_SCUFFLE_MAIN)
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  clear_equip_lbl(form)
  local strEquip = player:QueryProp("LuanDouEquipPlane")
  local equip_list = util_split_string(strEquip, ",")
  if nx_int(#equip_list) ~= nx_int(3) then
    return
  end
  form.lbl_equip.Text = nx_widestr(util_text(laundou_zhaunbei .. equip_list[1]))
  form.lbl_equip.ForeColor = nx_string("255,197,184,159")
  form.lbl_wuqi.Text = nx_widestr(util_text(laundou_zhaunbei .. equip_list[2]))
  form.lbl_wuqi.ForeColor = nx_string("255,197,184,159")
  form.lbl_shangyi.Text = nx_widestr(util_text(laundou_zhaunbei .. equip_list[3]))
  form.lbl_shangyi.ForeColor = nx_string("255,197,184,159")
end
function updata_player_jm_data()
  local form = nx_value(FORM_SCUFFLE_MAIN)
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  clear_jm_lbl(form)
  local strChannels = player:QueryProp("LuanDouChannelsPlane")
  local channels_list = util_split_string(strChannels, ",")
  if nx_int(#channels_list) ~= nx_int(8) then
    return
  end
  for i = 1, #channels_list do
    local jm_id = get_jm_id(channels_list[i])
    local lbl_name = "lbl_jm_" .. nx_string(i)
    local lbl = form.groupbox_jm:Find(lbl_name)
    if nx_is_valid(lbl) then
      lbl.Text = nx_widestr(util_text(jm_id))
      lbl.ForeColor = nx_string("255,197,184,159")
    end
  end
end
function updata_player_ng_data()
  local form = nx_value(FORM_SCUFFLE_MAIN)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_ng.Text = nx_widestr("")
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local nNeiGongIndex = player:QueryProp("LuanDouNeiGongIndex")
  local strConfig = get_ng_config_id(nNeiGongIndex)
  if strConfig == nil or nx_string(strConfig) == nx_string("") then
    form.lbl_ng.Text = util_text("ui_choswar_interface_005")
    form.lbl_ng.ForeColor = nx_string("255,255,0,0")
    return
  end
  form.lbl_ng.Text = nx_widestr(util_text(nx_string(strConfig)))
  form.lbl_ng.ForeColor = nx_string("255,197,184,159")
end
function updata_player_own_skill_data(...)
  local form = nx_value(FORM_SCUFFLE_MAIN)
  if not nx_is_valid(form) then
    return
  end
  clear_taolu_lbl(form)
  local index = 1
  for i = 1, #arg, 2 do
    local strSkill = nx_string(arg[i])
    if strSkill ~= "" and strSkill ~= nil then
      local lbl_name = "lbl_own_skill_" .. nx_string(index)
      local lbl = form.groupbox_skill:Find(nx_string(lbl_name))
      if nx_is_valid(lbl) then
        lbl.Text = util_text(strSkill)
        lbl.ForeColor = nx_string("255,197,184,159")
      end
    end
    index = index + 1
  end
end
function get_ng_config_id(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\LuanDou\\luandou_ui_neigong.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_neigong")
  if sec_count < 0 then
    return ""
  end
  local neigong = ini:ReadString(sec_count, nx_string(index), "")
  local neigong_list = util_split_string(neigong, ";")
  local neigong_id = neigong_list[1]
  return neigong_id
end
function clear_taolu_lbl(form)
  if not nx_is_valid(form) then
    return
  end
  local gbox = form.groupbox_skill
  if not nx_is_valid(gbox) then
    return
  end
  for i = 1, 3 do
    local lbl_name = "lbl_own_skill_" .. nx_string(i)
    local lbl = gbox:Find(nx_string(lbl_name))
    if nx_is_valid(lbl) then
      lbl.Text = util_text("ui_choswar_interface_005")
      lbl.ForeColor = nx_string("255,255,0,0")
    end
  end
end
function clear_equip_lbl(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_equip.Text = util_text("ui_choswar_interface_005")
  form.lbl_equip.ForeColor = nx_string("255,255,0,0")
  form.lbl_wuqi.Text = util_text("ui_choswar_interface_005")
  form.lbl_wuqi.ForeColor = nx_string("255,255,0,0")
  form.lbl_shangyi.Text = util_text("ui_choswar_interface_005")
  form.lbl_shangyi.ForeColor = nx_string("255,255,0,0")
end
function clear_jm_lbl(form)
  if not nx_is_valid(form) then
    return
  end
  local gbox = form.groupbox_jm
  if not nx_is_valid(gbox) then
    return
  end
  for i = 1, 16 do
    local lbl_name = "lbl_jm_" .. nx_string(i)
    local lbl = gbox:Find(nx_string(lbl_name))
    if nx_is_valid(lbl) then
      lbl.Text = util_text("ui_choswar_interface_005")
      lbl.ForeColor = nx_string("255,255,0,0")
    end
  end
end
function get_jm_id(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\LuanDou\\luandou_ui_jingmai.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_jingmai")
  if sec_count < 0 then
    return ""
  end
  local jingmai_id = ini:ReadString(sec_count, nx_string(index), "")
  return jingmai_id
end
function init_prize_imagegrid(form)
  if not nx_is_valid(form) then
    return
  end
  local gbox = form.groupbox_5
  if not nx_is_valid(gbox) then
    return
  end
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return
  end
  for i = 1, 4 do
    local grid_name = "imagegrid_" .. nx_string(i)
    local grid = gbox:Find(nx_string(grid_name))
    if nx_is_valid(grid) then
      local strPrize = get_prize_list(i)
      local prize_list = util_split_string(strPrize, ",")
      for j = 1, #prize_list do
        local photo = ItemsQuery:GetItemPropByConfigID(prize_list[j], "Photo")
        if photo == "" or photo == nil then
          photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", prize_list[j], "Photo")
        end
        grid:AddItem(j - 1, photo, prize_list[j], 1, -1)
      end
      grid.config_id = strPrize
    end
  end
end
function get_prize_list(index)
  local ini = nx_execute("util_functions", "get_ini", luandou_file)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("chaoswar_prize")
  if sec_count < 0 then
    return ""
  end
  local strPrize = ini:ReadString(sec_count, nx_string(index), "")
  return strPrize
end
function open_limite_form(...)
  if nx_int(#arg) < nx_int(1) then
    return
  end
  if nx_int(arg[1]) == nx_int(1) then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_tiguan", "open_tvt_tiguan_form")
  elseif nx_int(arg[1]) == nx_int(2) then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_one", "util_auto_show_hide_form", "form_stage_main\\form_tiguan\\form_tiguan_one")
  elseif nx_int(arg[1]) == nx_int(3) then
    if nx_int(#arg) == nx_int(2) then
      nx_execute("form_stage_main\\form_origin\\form_origin", "open_origin_form_by_id", nx_int(arg[2]))
      return
    end
    nx_execute("form_stage_main\\form_origin\\form_origin", "open_origin_form")
  elseif nx_int(arg[1]) == nx_int(4) then
    nx_execute("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_msg_new", "open_teacher_pupil_form")
  end
end
function custom_open_limite_form(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_PlayerIsInCross), nx_int(index))
end
function custom_open_limite_form_origin(index, origin_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_PlayerIsInCross), nx_int(index), nx_int(origin_id))
end
function init_record_grid(grid)
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  grid.ColCount = 11
  grid:ClearRow()
  for i = 1, grid.ColCount do
    grid:SetColTitle(i - 1, util_text(luandou_record_head_info[i]))
    grid:SetColAlign(i - 1, "center")
  end
  grid:SetColWidth(0, 70)
  grid:SetColWidth(1, 80)
  grid:SetColWidth(2, 70)
  grid:SetColWidth(3, 80)
  grid:SetColWidth(4, 80)
  grid:SetColWidth(5, 80)
  grid:SetColWidth(6, 80)
  grid:SetColWidth(7, 50)
  grid:SetColWidth(8, 50)
  grid:SetColWidth(9, 50)
  grid:SetColWidth(10, 50)
  grid:SetColAlign(0, "left")
  grid:EndUpdate()
end
function rec_luandou_record(...)
  local form = nx_value(FORM_SCUFFLE_MAIN)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_1
  if not nx_is_valid(grid) then
    return
  end
  grid:ClearRow()
  for i = 1, #arg do
    local strRecordInfo = nx_widestr(arg[i])
    if strRecordInfo ~= "" then
      local row = grid:InsertRow(-1)
      local strInfoList = util_split_wstring(strRecordInfo, ",")
      if nx_int(#strInfoList) == nx_int(8) then
        local strNameList = util_split_wstring(strInfoList[1], "@")
        if nx_int(#strNameList) == nx_int(2) then
          grid:SetGridText(row, 1, strNameList[1])
          grid:SetGridText(row, 2, strNameList[2])
        end
        local strSkillList = util_split_wstring(strInfoList[2], ";")
        grid:SetGridText(row, 3, util_text(nx_string(strSkillList[1])))
        grid:SetGridText(row, 4, util_text(nx_string(strSkillList[2])))
        grid:SetGridText(row, 5, util_text(nx_string(strSkillList[3])))
        grid:SetGridText(row, 6, util_text(nx_string(strInfoList[3])))
        grid:SetGridText(row, 7, strInfoList[4])
        grid:SetGridText(row, 8, strInfoList[5])
        local nDamage = math.floor(nx_int64(strInfoList[6]) / 10000)
        nDamage = nDamage .. nx_string(util_text("ui_wan"))
        grid:SetGridText(row, 9, nx_widestr(nDamage))
        grid:SetGridText(row, 10, strInfoList[7])
        local strTime = decode_time(nx_double(strInfoList[8]))
        grid:SetGridText(row, 0, nx_widestr(strTime))
      end
    end
  end
end
function decode_time(d_time)
  local year, month, day, hour, miniute, second = nx_function("ext_decode_date", d_time)
  local time_str = ""
  if nx_int(month) < nx_int(10) then
    time_str = "0" .. nx_string(month)
  else
    time_str = nx_string(month)
  end
  time_str = time_str .. "/"
  if nx_int(day) < nx_int(10) then
    time_str = time_str .. "0" .. nx_string(day)
  else
    time_str = time_str .. nx_string(day)
  end
  time_str = time_str .. " "
  if nx_int(hour) < nx_int(10) then
    time_str = time_str .. "0" .. nx_string(hour)
  else
    time_str = time_str .. nx_string(hour)
  end
  time_str = time_str .. ":"
  if nx_int(miniute) < nx_int(10) then
    time_str = time_str .. "0" .. nx_string(miniute)
  else
    time_str = time_str .. nx_string(miniute)
  end
  return time_str
end
function init_self_record_grid(grid)
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  grid.ColCount = 9
  grid:ClearRow()
  for i = 1, grid.ColCount do
    grid:SetColTitle(i - 1, util_text(luandou_self_record_head_info[i]))
    grid:SetColAlign(i - 1, "center")
  end
  grid:SetColWidth(0, 100)
  grid:SetColWidth(1, 90)
  grid:SetColWidth(2, 90)
  grid:SetColWidth(3, 90)
  grid:SetColWidth(4, 90)
  grid:SetColWidth(5, 70)
  grid:SetColWidth(6, 70)
  grid:SetColWidth(7, 80)
  grid:SetColWidth(8, 70)
  grid:SetColAlign(0, "left")
  grid:EndUpdate()
end
function rec_self_luandou_record(...)
  local form = nx_value(FORM_SCUFFLE_MAIN)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_2
  if not nx_is_valid(grid) then
    return
  end
  grid:ClearRow()
  for i = 1, #arg do
    local strRecordInfo = nx_widestr(arg[i])
    if strRecordInfo ~= "" then
      local row = grid:InsertRow(-1)
      local strSelfInfoList = util_split_wstring(strRecordInfo, ",")
      if nx_int(#strSelfInfoList) == nx_int(7) then
        local strSkillList = util_split_wstring(strSelfInfoList[1], ";")
        grid:SetGridText(row, 1, util_text(nx_string(strSkillList[1])))
        grid:SetGridText(row, 2, util_text(nx_string(strSkillList[2])))
        grid:SetGridText(row, 3, util_text(nx_string(strSkillList[3])))
        grid:SetGridText(row, 4, util_text(nx_string(strSelfInfoList[2])))
        grid:SetGridText(row, 5, strSelfInfoList[3])
        grid:SetGridText(row, 6, strSelfInfoList[4])
        local nDamage = math.floor(nx_int64(strSelfInfoList[5]) / 10000)
        nDamage = nDamage .. nx_string(util_text("ui_wan"))
        grid:SetGridText(row, 7, nx_widestr(nDamage))
        grid:SetGridText(row, 8, strSelfInfoList[6])
        local strTime = decode_time(nx_double(strSelfInfoList[7]))
        grid:SetGridText(row, 0, nx_widestr(strTime))
      end
    end
  end
end
