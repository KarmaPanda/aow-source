require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
require("form_stage_main\\switch\\switch_define")
local GetWarInfo = 0
local JoinWarOper = 1
local SeeRankOper = 2
local MoreInfo = 3
local FIGHT_RESULT_PATH = "form_stage_main\\form_cross_school_fight\\form_cross_school_fight_result"
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  self.rbtn_info.Checked = true
  init_fight_result_form(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_main_form_shut(form)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
end
function init_fight_result_form(form)
  if not nx_is_valid(form) then
    return
  end
  local fight_result_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_cross_school_fight\\form_cross_school_fight_result", true, false)
  local is_load = form.groupbox_crossinfo:Add(fight_result_form)
  if is_load == true then
    form.fight_result_form = fight_result_form
    form.fight_result_form.Left = 4
    form.fight_result_form.Top = 3
    form.fight_result_form.Visible = false
  end
end
function on_btn_join_match1_click(btn)
  local row = btn.DataSource
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(JoinWarOper), nx_int(row))
  btn.ParentForm:Close()
end
function on_btn_join_match2_click(btn)
  local row = btn.DataSource
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(JoinWarOper), nx_int(row))
  btn.ParentForm:Close()
end
function on_rbtn_join_checked_changed(btn)
  if btn.Checked == false then
    return
  end
  local form = btn.ParentForm
  form.groupbox_join.Visible = true
  form.groupbox_rank.Visible = false
  form.groupbox_info.Visible = false
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(GetWarInfo))
end
function on_rbtn_rank_server_checked_changed(btn)
  if btn.Checked == false then
    return
  end
  local form = btn.ParentForm
  form.groupbox_join.Visible = false
  form.groupbox_rank.Visible = true
  form.groupbox_info.Visible = false
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(0))
end
function on_rbtn_info_main_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_join.Visible = false
  form.groupbox_rank.Visible = false
  form.groupbox_info.Visible = true
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(MoreInfo))
  form.rbtn_info_1.Checked = true
end
function on_btn_equip_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_advanced_weapon_and_origin")
  local form = util_get_form("form_stage_main\\form_advanced_weapon_and_origin", true)
  if nx_is_valid(form) then
    form.rbtn_weapon.Checked = true
  end
end
function on_btn_join_click(btn)
  local form = btn.ParentForm
  form.rbtn_join.Checked = true
end
function on_btn_leave_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(998), nx_int(29))
end
function on_rbtn_server_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(0))
end
function on_rbtn_school_jinyiwei_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(5))
end
function on_rbtn_school_gaibang_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(6))
end
function on_rbtn_school_junzitang_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(7))
end
function on_rbtn_school_jilegu_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(8))
end
function on_rbtn_school_tangmen_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(9))
end
function on_rbtn_school_emei_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(10))
end
function on_rbtn_school_wudang_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(11))
end
function on_rbtn_school_shaolin_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(12))
end
function on_rbtn_school_mingjiao_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(769))
end
function on_rbtn_school_tianshan_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(SeeRankOper), nx_int(832))
end
function on_cross_school_fight_msg(...)
  local sub_msg = arg[1]
  if sub_msg == 0 then
    ShowFightInfo(unpack(arg))
  elseif sub_msg == 1 then
    ShowIntegral(unpack(arg))
  elseif sub_msg == 2 then
    ShowMatchInfo(unpack(arg))
  elseif nx_int(sub_msg) == nx_int(MoreInfo) then
    ShowMoreInfo(unpack(arg))
  elseif sub_msg == 4 then
    nx_execute(FIGHT_RESULT_PATH, "show_cross_school_fight_list", unpack(arg))
  elseif sub_msg == 5 then
    nx_execute(FIGHT_RESULT_PATH, "show_cross_school_fight_result", unpack(arg))
  end
end
function open_form()
  local switchmgr = nx_value("SwitchManager")
  if nx_is_valid(switchmgr) then
    local enable = switchmgr:CheckSwitchEnable(ST_FUNCTION_NEW_SCHOOLFIGHT)
    if not enable then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("100059"))
      return
    end
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local form = util_get_form("form_stage_main\\form_cross_school_fight\\form_cross_school_fight", true, false)
  if not nx_is_valid(form) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_FIGHT), nx_int(GetWarInfo))
  form.lbl_school_attack1.ForeColor = "255,255,255,255"
  form.lbl_school_defend1.ForeColor = "255,255,255,255"
  form.lbl_school_attack2.ForeColor = "255,255,255,255"
  form.lbl_school_defend2.ForeColor = "255,255,255,255"
  form:Show()
  form.Visible = true
end
function ShowFightInfo(...)
  local argnum = table.getn(arg)
  if nx_number(argnum) < nx_number(11) then
    return
  end
  local form = nx_value("form_stage_main\\form_cross_school_fight\\form_cross_school_fight")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local num = (argnum - 1) / 5
  for i = 0, num - 1 do
    local row = arg[i * 5 + 2]
    local warFlag = arg[i * 5 + 3]
    local attack_school = arg[i * 5 + 4]
    local defend_school = arg[i * 5 + 5]
    local warResult = arg[i * 5 + 6]
    if i == 0 then
      form.lbl_school_attack1.Text = nx_widestr(gui.TextManager:GetText(nx_string(attack_school)))
      form.lbl_school_defend1.Text = nx_widestr(gui.TextManager:GetText(nx_string(defend_school)))
      form.lbl_result_match1.Text = nx_widestr(gui.TextManager:GetText("ui_cross_school_fight_" .. nx_string(warResult)))
      form.btn_join_match1.DataSource = nx_string(row)
      if warFlag == 2 then
        form.lbl_school_attack1.ForeColor = "255,255,0,0"
      elseif warFlag == 1 then
        form.lbl_school_defend1.ForeColor = "255,255,0,0"
      end
    elseif i == 1 then
      form.lbl_school_attack2.Text = nx_widestr(gui.TextManager:GetText(nx_string(attack_school)))
      form.lbl_school_defend2.Text = nx_widestr(gui.TextManager:GetText(nx_string(defend_school)))
      form.lbl_result_match2.Text = nx_widestr(gui.TextManager:GetText("ui_cross_school_fight_" .. nx_string(warResult)))
      form.btn_join_match2.DataSource = nx_string(row)
      if warFlag == 2 then
        form.lbl_school_attack2.ForeColor = "255,255,0,0"
      elseif warFlag == 1 then
        form.lbl_school_defend2.ForeColor = "255,255,0,0"
      end
    end
  end
end
function ShowIntegral(...)
  local argnum = table.getn(arg)
  if nx_number(argnum) < nx_number(2) then
    return
  end
  local form = nx_value("form_stage_main\\form_cross_school_fight\\form_cross_school_fight")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.textgrid_rec:ClearRow()
  local nSchool = arg[2]
  if nSchool == 0 then
    form.textgrid_rec:SetColTitle(0, util_format_string("ui_cross_schoolfight_22"))
    form.textgrid_rec:SetColTitle(1, util_format_string("ui_cross_schoolfight_23"))
    form.textgrid_rec:SetColTitle(2, util_format_string("ui_cross_schoolfight_24"))
    form.textgrid_rec:SetColTitle(3, util_format_string("ui_cross_schoolfight_25"))
    form.textgrid_rec:SetColTitle(4, util_format_string("ui_cross_schoolfight_26"))
    form.textgrid_rec:SetColTitle(5, util_format_string("ui_cross_schoolfight_27"))
  else
    form.textgrid_rec:SetColTitle(0, util_format_string("ui_cross_schoolfight_23"))
    form.textgrid_rec:SetColTitle(1, util_format_string("ui_cross_schoolfight_24"))
    form.textgrid_rec:SetColTitle(2, util_format_string("ui_cross_schoolfight_25"))
    form.textgrid_rec:SetColTitle(3, util_format_string("ui_cross_schoolfight_26"))
    form.textgrid_rec:SetColTitle(4, util_format_string("ui_cross_schoolfight_27"))
    form.textgrid_rec:SetColTitle(5, util_format_string("ui_cross_schoolfight_28"))
  end
  local num = (argnum - 2) / 6
  form.textgrid_rec.RowCount = num
  for i = 0, num - 1 do
    if nSchool == 0 then
      form.textgrid_rec:SetGridText(i, 0, nx_widestr(i + 1))
      form.textgrid_rec:SetGridText(i, 1, nx_widestr(arg[3 + i * 6]))
      form.textgrid_rec:SetGridText(i, 2, nx_widestr(arg[4 + i * 6]))
      form.textgrid_rec:SetGridText(i, 3, nx_widestr(arg[5 + i * 6]))
      form.textgrid_rec:SetGridText(i, 4, nx_widestr(arg[6 + i * 6]))
      form.textgrid_rec:SetGridText(i, 5, nx_widestr(arg[7 + i * 6]))
    else
      form.textgrid_rec:SetGridText(i, 0, nx_widestr(arg[3 + i * 6]))
      form.textgrid_rec:SetGridText(i, 1, nx_widestr(arg[4 + i * 6]))
      form.textgrid_rec:SetGridText(i, 2, nx_widestr(arg[5 + i * 6]))
      form.textgrid_rec:SetGridText(i, 3, nx_widestr(arg[6 + i * 6]))
      form.textgrid_rec:SetGridText(i, 4, nx_widestr(arg[7 + i * 6]))
      form.textgrid_rec:SetGridText(i, 5, nx_widestr(nx_string(arg[8 + i * 6] / 10) .. "%"))
    end
  end
end
function ShowMatchInfo(...)
  local argnum = table.getn(arg)
  if nx_number(argnum) < nx_number(3) then
    return
  end
  local form = nx_value("form_stage_main\\form_cross_school_fight\\form_cross_school_fight")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local match_start = arg[2]
  local match_end = arg[3]
  form.lbl_start.Text = nx_widestr(match_start)
  form.lbl_finish.Text = nx_widestr(match_end)
end
function on_rbtn_info_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  for i = 1, 100 do
    local group = form.groupbox_info:Find("groupbox_info_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(rbtn.DataSource) == nx_int(i) then
        group.Visible = true
        local group_rbtns = group:Find("groupbox_info_cbtns_" .. nx_string(rbtn.DataSource))
        if nx_is_valid(group_rbtns) then
          local rbtn_first = group_rbtns:Find("rbtn_info_" .. nx_string(rbtn.DataSource) .. "_1")
          if nx_is_valid(rbtn_first) then
            rbtn_first.Checked = true
          end
        end
      else
        group.Visible = false
      end
    else
      return
    end
  end
end
function on_rbtn_info_1_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  for i = 1, 100 do
    local group = form.groupbox_info_1:Find("groupbox_info_1_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(rbtn.DataSource) == nx_int(i) then
        group.Visible = true
      else
        group.Visible = false
      end
    else
      return
    end
  end
end
function on_rbtn_info_2_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  for i = 1, 100 do
    local group = form.groupbox_info_2:Find("groupbox_info_2_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(rbtn.DataSource) == nx_int(i) then
        group.Visible = true
      else
        group.Visible = false
      end
    else
      return
    end
  end
end
function on_rbtn_info_3_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  for i = 1, 100 do
    local group = form.groupbox_info_3:Find("groupbox_info_3_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(rbtn.DataSource) == nx_int(i) then
        group.Visible = true
      else
        group.Visible = false
      end
    else
      return
    end
  end
end
function on_rbtn_info_4_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  for i = 1, 100 do
    local group = form.groupbox_info_4:Find("groupbox_info_4_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(rbtn.DataSource) == nx_int(i) then
        group.Visible = true
      else
        group.Visible = false
      end
    else
      return
    end
  end
end
function on_rbtn_info_5_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  for i = 1, 100 do
    local group = form.groupbox_info_5:Find("groupbox_info_5_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(rbtn.DataSource) == nx_int(i) then
        group.Visible = true
      else
        group.Visible = false
      end
    else
      return
    end
  end
end
function on_rbtn_info_6_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  for i = 1, 100 do
    local group = form.groupbox_info_6:Find("groupbox_info_6_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(rbtn.DataSource) == nx_int(i) then
        group.Visible = true
      else
        group.Visible = false
      end
    else
      return
    end
  end
end
function on_rbtn_info_7_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  for i = 1, 100 do
    local group = form.groupbox_info_7:Find("groupbox_info_7_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(rbtn.DataSource) == nx_int(i) then
        group.Visible = true
      else
        group.Visible = false
      end
    else
      return
    end
  end
end
function on_rbtn_info_8_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  for i = 1, 100 do
    local group = form.groupbox_info_8:Find("groupbox_info_8_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(rbtn.DataSource) == nx_int(i) then
        group.Visible = true
      else
        group.Visible = false
      end
    else
      return
    end
  end
end
function on_rbtn_info_9_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  for i = 1, 100 do
    local group = form.groupbox_info_9:Find("groupbox_info_9_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(rbtn.DataSource) == nx_int(i) then
        group.Visible = true
      else
        group.Visible = false
      end
    else
      return
    end
  end
end
function on_rbtn_info_10_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  for i = 1, 100 do
    local group = form.groupbox_info_10:Find("groupbox_info_10_" .. nx_string(i))
    if nx_is_valid(group) then
      if nx_int(rbtn.DataSource) == nx_int(i) then
        group.Visible = true
      else
        group.Visible = false
      end
    else
      return
    end
  end
end
function ShowMoreInfo(...)
  local form = nx_value("form_stage_main\\form_cross_school_fight\\form_cross_school_fight")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_info_1.Text = nx_widestr(arg[2])
  form.lbl_info_2.Text = nx_widestr(arg[3])
  form.lbl_info_3.Text = nx_widestr(arg[4])
  form.lbl_info_4.Text = nx_widestr(arg[5])
end
function on_rbtn_result_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_cross_school_fight\\form_cross_school_fight_result", "open_form")
  local is_show = btn.Checked
  if is_show then
    form.groupbox_join.Visible = false
    form.groupbox_rank.Visible = false
    form.groupbox_info.Visible = false
  end
  form.fight_result_form.Visible = is_show
end
