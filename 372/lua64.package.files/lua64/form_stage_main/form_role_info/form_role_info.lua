require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("custom_sender")
require("share\\view_define")
require("role_composite")
local ELITE_PLAYER_LEVEL = 86
local CONTENT_STATE_ALL = 1
local CONTENT_STATE_WAIGONG = 2
local CONTENT_STATE_ANQI = 3
local CONTENT_STATE_NEIGONG = 4
local CONTENT_STATE_FANGYU = 5
local form_table = {
  [1] = "form_stage_main\\form_role_info\\form_rp_arm",
  [2] = "form_stage_main\\form_role_info\\form_shengwang",
  [3] = "form_stage_main\\form_role_info\\form_others",
  [4] = "form_stage_main\\form_role_info\\form_title",
  [5] = "form_stage_main\\form_role_info\\form_allmount",
  [6] = "form_stage_main\\form_role_info\\form_onestep_equip",
  [7] = "form_stage_main\\form_role_info\\form_huwei_attributes",
  [8] = "form_stage_main\\form_role_info\\form_binglu",
  [9] = "form_stage_main\\form_role_info\\form_train_pat",
  [10] = "form_stage_main\\form_role_info\\form_sable",
  [11] = "form_stage_main\\form_role_info\\form_onestep_jingmai"
}
local FORM_ROLE_INFO = "form_stage_main\\form_role_info\\form_role_info"
function auto_show_hide_role_info()
  nx_execute("custom_sender", "custom_query_jiuyinzhi_current_step")
  local gui = nx_value("gui")
  local form = nx_value(FORM_ROLE_INFO)
  if nx_is_valid(form) then
    form.Visible = not form.Visible
    if form.Visible then
      gui.Desktop:ToFront(form)
      if not form.rbtn_1.Checked then
        on_rbtn_info_click(form.rbtn_1)
        form.rbtn_1.Checked = true
      end
      do
        local form_logic = nx_value("form_rp_arm_logic")
        if nx_is_valid(form_logic) then
          form_logic:ChangeActionByWeapon()
        else
        end
      end
    end
  else
    nx_execute("util_gui", "util_auto_show_hide_form", FORM_ROLE_INFO)
    local form_logic = nx_value("form_rp_arm_logic")
    if nx_is_valid(form_logic) then
      form_logic:ChangeActionByWeapon()
    end
  end
  local form = nx_value(FORM_ROLE_INFO)
  ui_show_attached_form(form)
end
function reset_scene()
  local bVisible = false
  local form = nx_value(FORM_ROLE_INFO)
  if nx_is_valid(form) then
    bVisible = form.Visible
    form:Close()
  else
    bVisible = false
  end
  nx_execute("util_gui", "util_auto_show_hide_form", FORM_ROLE_INFO)
  form = nx_value(FORM_ROLE_INFO)
  if nx_is_valid(form) then
    form.Visible = bVisible
    if bVisible and not form.rbtn_1.Checked then
      on_rbtn_info_click(form.rbtn_1)
      form.rbtn_1.Checked = true
    else
    end
  end
  local form_rp_arm = nx_value("form_stage_main\\form_role_info\\form_rp_arm")
  if not nx_is_valid(form_rp_arm) then
    return
  end
  if form_rp_arm.groupbox_right.Visible then
    form.Width = form.groupbox_1.Width + form_rp_arm.groupbox_right.Width - form_rp_arm.btn_2.Width
  else
    form.Width = form.groupbox_1.Width
  end
end
function refresh_form(form)
  if nx_is_valid(form) then
    on_pk_step(form)
    refresh_LevelTitle(form)
  end
end
function init(form)
  form.Fixed = false
  form.content_state = 1
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 10
  self.AbsTop = (gui.Height - self.Height) / 2
  self.content_state = 1
  local rbtn_1 = self.groupbox_3:Find("rbtn_1")
  local rbtn_2 = self.groupbox_3:Find("rbtn_2")
  local rbtn_3 = self.groupbox_3:Find("rbtn_3")
  local rbtn_4 = self.groupbox_3:Find("rbtn_4")
  local rbtn_5 = self.groupbox_3:Find("rbtn_5")
  local rbtn_6 = self.groupbox_3:Find("rbtn_6")
  local rbtn_7 = self.groupbox_3:Find("rbtn_7")
  local rbtn_8 = self.groupbox_3:Find("rbtn_8")
  local rbtn_9 = self.groupbox_3:Find("rbtn_9")
  local rbtn_10 = self.groupbox_3:Find("rbtn_10")
  local rbtn_11 = self.groupbox_3:Find("rbtn_11")
  rbtn_1.ClickEvent = true
  rbtn_2.ClickEvent = true
  rbtn_3.ClickEvent = true
  rbtn_4.ClickEvent = true
  rbtn_5.ClickEvent = true
  rbtn_6.ClickEvent = true
  rbtn_7.ClickEvent = true
  rbtn_8.ClickEvent = true
  rbtn_9.ClickEvent = true
  rbtn_10.ClickEvent = true
  rbtn_11.ClickEvent = true
  self.item_index = 0
  data_bind_prop(self)
  self.rbtn_1.Checked = true
  load_form_rp_arm(self)
  load_form_shengwang(self)
  load_form_others(self)
  load_form_title(self)
  load_form_mount(self)
  load_form_onestep_equip(self)
  load_form_huwei(self)
  load_form_binglu(self)
  load_form_train_pat(self)
  load_form_sable(self)
  load_form_onestep_jingmai(self)
  local is_vip = check_vip_player()
  if nx_int(is_vip) == nx_int(1) then
    self.rbtn_6.Enabled = true
  else
    self.rbtn_6.Enabled = false
  end
  local is_body = check_body_player()
  if is_body == true then
    self.rbtn_11.Enabled = true
  else
    self.rbtn_11.Enabled = false
  end
  return 1
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  ui_destroy_attached_form(self)
  nx_execute("tips_game", "hide_tip")
  del_data_bind_prop(self)
  for _, sub_form_name in ipairs(form_table) do
    local sub_form = nx_value(sub_form_name)
    if nx_is_valid(sub_form) then
      sub_form:Close()
    end
  end
  nx_destroy(self)
  util_show_form("form_stage_main\\form_role_info\\form_tips_pk_step", false)
  nx_set_value("form_stage_main\\form_role_info\\form_role_info", nx_null())
end
function data_bind_prop(self)
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddRolePropertyBind("PKStep", "int", self, nx_current(), "on_pk_step")
  databinder:AddRolePropertyBind("LevelTitle", "string", self, nx_current(), "refresh_LevelTitle")
  databinder:AddRolePropertyBind("VipStatus", "int", self, nx_current(), "on_vip_change")
  databinder:AddRolePropertyBind("BodyScale", "int", self, nx_current(), "on_body_type_change")
end
function del_data_bind_prop(self)
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:DelRolePropertyBind("PKStep", self)
  databinder:DelRolePropertyBind("LevelTitle", self)
  databinder:DelRolePropertyBind("VipStatus", self)
  databinder:DelRolePropertyBind("BodyScale", self)
end
function check_vip_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  return client_player:QueryProp("VipStatus")
end
function check_body_player()
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not body_manager:IsNewBodyType(player) then
    return false
  end
  return true
end
function on_vip_change(form)
  if not nx_is_valid(form) then
    return
  end
  local is_vip = check_vip_player()
  if nx_int(is_vip) == nx_int(1) then
    form.rbtn_6.Enabled = true
  else
    form.rbtn_6.Enabled = false
    local form_onestep = nx_value("form_stage_main\\form_role_info\\form_onestep_equip")
    if nx_is_valid(form_onestep) and form_onestep.Visible then
      form.rbtn_1.Checked = true
      on_rbtn_info_click(form.rbtn_1)
    end
  end
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function load_form_rp_arm(self)
  local form_rp_arm = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_role_info\\form_rp_arm", true, false)
  local is_load = self:Add(form_rp_arm)
  if is_load == true then
    form_rp_arm.Left = 15
    form_rp_arm.Top = 112
  end
  form_rp_arm.Visible = true
  return form_rp_arm
end
function load_form_mount(self)
  local form_mount = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_role_info\\form_allmount", true, false)
  local is_load = self:Add(form_mount)
  if is_load == true then
    form_mount.Left = 19
    form_mount.Top = 71
  end
  form_mount.Visible = false
  return form_mount
end
function load_form_onestep_equip(self)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_role_info\\form_onestep_equip", true, false)
  local is_load = self:Add(form)
  if is_load == true then
    form.Left = 19
    form.Top = 71
  end
  form.Visible = false
  return form
end
function load_form_onestep_jingmai(self)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_role_info\\form_onestep_jingmai", true, false)
  local is_load = self:Add(form)
  if is_load == true then
    form.Left = 335
    form.Top = 41
  end
  form.Visible = false
  return form
end
function load_form_huwei(self)
  local form_huwei = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_role_info\\form_huwei_attributes", true, false)
  local is_load = self:Add(form_huwei)
  if true == is_load then
    form_huwei.Left = 19
    form_huwei.Top = 68
  end
  form_huwei.Visible = false
  return form_huwei
end
function load_form_train_pat(self)
  local form_trainpat = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_role_info\\form_train_pat", true, false)
  local is_load = self:Add(form_trainpat)
  if true == is_load then
    form_trainpat.Left = 19
    form_trainpat.Top = 71
  end
  form_trainpat.Visible = false
  return form_trainpat
end
function load_form_binglu(self)
  local form_binglu = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_role_info\\form_binglu", true, false)
  local is_load = self:Add(form_binglu)
  if true == is_load then
    form_binglu.Left = 19
    form_binglu.Top = 71
  end
  form_binglu.Visible = false
  return form_binglu
end
function load_form_shengwang(self)
  local form_shengwang = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_role_info\\form_shengwang", true, false)
  local is_load = self:Add(form_shengwang)
  if is_load == true then
    form_shengwang.Left = 19
    form_shengwang.Top = 71
  end
  form_shengwang.Visible = false
  return form_shengwang
end
function load_form_others(self)
  local form_others = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_role_info\\form_others", true, false)
  local is_load = self:Add(form_others)
  if is_load == true then
    form_others.Left = 16
    form_others.Top = 154
  end
  form_others.Visible = false
  return form_others
end
function load_form_title(self)
  local form_title = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_role_info\\form_title", true, false)
  local is_load = self:Add(form_title)
  if is_load == true then
    form_title.Left = 15
    form_title.Top = 69
  end
  form_title.Visible = false
  return form_title
end
function load_form_sable(self)
  local form_sable = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_role_info\\form_sable", true, false)
  local is_load = self:Add(form_sable)
  if is_load == true then
    form_sable.Left = 19
    form_sable.Top = 71
  end
  form_sable.Visible = false
  return form_sable
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  return 0
end
function refresh_LevelTitle(self, prop_name, prop_type, prop_value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local title = client_player:QueryProp("LevelTitle")
  local gui = nx_value("gui")
  local name = gui.TextManager:GetText("desc_" .. title)
  local lbl_step = self.groupbox_1:Find("lbl_level_step")
  lbl_step.Text = nx_widestr(name)
  return 1
end
function load_form(self, index)
  local curform = nx_value(form_table[index])
  if nx_is_valid(curform) then
    return
  end
  if nx_int(index) == nx_int(1) then
    load_form_rp_arm(self)
  elseif nx_int(index) == nx_int(2) then
    load_form_shengwang(self)
  elseif nx_int(index) == nx_int(3) then
    load_form_others(self)
  elseif nx_int(index) == nx_int(4) then
    load_form_title(self)
  elseif nx_int(index) == nx_int(5) then
    load_form_mount(self)
  elseif nx_int(index) == nx_int(7) then
    load_form_huwei(self)
  elseif nx_int(index) == nx_int(9) then
    load_form_huwei(self)
  elseif nx_int(index) == nx_int(10) then
    load_form_sable(self)
  end
end
function on_rbtn_info_click(rbtn)
  local form_role_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  local form_rp_arm = nx_value("form_stage_main\\form_role_info\\form_rp_arm")
  local form_huwei_attributes = nx_value("form_stage_main\\form_role_info\\form_huwei_attributes")
  if not nx_is_valid(form_role_info) or not nx_is_valid(form_rp_arm) then
    return
  end
  if rbtn.TabIndex == 6 then
    local is_vip = check_vip_player()
    if nx_int(is_vip) == nx_int(0) then
      return
    end
  end
  local count = table.getn(form_table)
  for i = 1, count do
    local temp_form = nx_value(form_table[i])
    if nx_is_valid(temp_form) then
      temp_form.Visible = false
    end
  end
  local mainform = rbtn.ParentForm
  if rbtn.TabIndex == 1 then
    mainform.lbl_2.Text = nx_widestr("@ui_role_rwsx")
    mainform.groupbox_2.Visible = true
    if form_rp_arm.groupbox_right.Visible then
      form_role_info.Width = form_role_info.groupbox_1.Width + form_rp_arm.groupbox_right.Width - 5
    else
      form_role_info.Width = form_role_info.groupbox_1.Width
    end
  elseif rbtn.TabIndex == 2 then
    mainform.lbl_2.Text = nx_widestr("@ui_task_prize_repute")
    mainform.groupbox_2.Visible = true
    form_role_info.Width = form_role_info.groupbox_1.Width
  elseif rbtn.TabIndex == 4 then
    mainform.lbl_2.Text = nx_widestr("@ui_form_monster_call")
    mainform.groupbox_2.Visible = true
    form_role_info.Width = form_role_info.groupbox_1.Width
  elseif rbtn.TabIndex == 5 then
    mainform.lbl_2.Text = nx_widestr("@ui_role_mount")
    mainform.groupbox_2.Visible = false
    form_role_info.Width = form_role_info.groupbox_1.Width
  elseif rbtn.TabIndex == 6 then
    mainform.lbl_2.Text = nx_widestr("@ui_role_onestep_equip")
    mainform.groupbox_2.Visible = false
    form_role_info.Width = form_role_info.groupbox_1.Width
  elseif rbtn.TabIndex == 7 then
    mainform.lbl_2.Text = nx_widestr("@ui_huwei_title")
    mainform.groupbox_2.Visible = false
    if form_huwei_attributes.groupbox_right.Visible then
      form_role_info.Width = form_role_info.groupbox_1.Width + form_huwei_attributes.groupbox_right.Width
    else
      form_role_info.Width = form_role_info.groupbox_1.Width
    end
  elseif rbtn.TabIndex == 8 then
    mainform.lbl_2.Text = nx_widestr("@ui_binglu_title")
    mainform.groupbox_2.Visible = false
    form_role_info.Width = form_role_info.groupbox_1.Width
  elseif rbtn.TabIndex == 9 then
    mainform.lbl_2.Text = nx_widestr("@ui_role_nushou")
    mainform.groupbox_2.Visible = false
    form_role_info.Width = form_role_info.groupbox_1.Width
  elseif rbtn.TabIndex == 10 then
    mainform.lbl_2.Text = nx_widestr("@ui_role_sable")
    mainform.groupbox_2.Visible = false
    form_role_info.Width = form_role_info.groupbox_1.Width
  elseif rbtn.TabIndex == 11 then
    if not check_body_player() then
      return
    end
    mainform.lbl_2.Text = nx_widestr("@ui_role_rwsx")
    mainform.groupbox_2.Visible = true
    if form_rp_arm.groupbox_right.Visible then
      form_role_info.Width = form_role_info.groupbox_1.Width + form_rp_arm.groupbox_right.Width - form_rp_arm.btn_2.Width
    else
      form_role_info.Width = form_role_info.groupbox_1.Width
    end
    form_rp_arm.Visible = true
    form_rp_arm.show_body = true
    nx_execute("form_stage_main\\form_role_info\\form_rp_arm", "on_refresh_form_info", form_rp_arm)
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    return
  end
  local form = nx_value(form_table[rbtn.TabIndex])
  if nx_is_valid(form) then
    form.Visible = true
    nx_execute(form_table[rbtn.TabIndex], "refresh_form", form)
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_pk_step(self)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local game_player = game_client:GetPlayer()
  if not nx_is_valid(game_player) then
    return
  end
  local CharacterFlag = nx_number(game_player:QueryProp("CharacterFlag"))
  local CharacterValue = nx_number(game_player:QueryProp("CharacterValue"))
  local text = get_xiae_text(CharacterFlag, CharacterValue)
  self.lbl_pk_step.Text = nx_widestr(text)
end
function get_xiae_text(CharacterFlag, CharacterValue)
  local text = util_text("ui_sns_churujianghu")
  local character_level = nx_execute("form_stage_main\\form_redeem\\form_character_zonglan", "get_character_level", CharacterValue)
  if nx_number(CharacterFlag) == nx_number(0) then
    text = util_text("ui_sns_churujianghu")
  else
    text = util_text("ui_character_" .. nx_string(CharacterFlag) .. "_" .. nx_string(character_level))
  end
  return text
end
function on_get_capture_levelstep(self, index)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = get_titlelevel_tips_text()
  nx_execute("tips_game", "show_text_tip", text, x, y, -1)
end
function on_lose_capture_levelstep(self, index)
  nx_execute("tips_game", "hide_tip")
end
function on_get_capture_pkstep(self, index)
  local form_rp_arm = nx_value(form_table[1])
  if not nx_is_valid(form_rp_arm) then
    return
  end
  form_rp_arm.gb_self_shan_e.Visible = true
end
function on_lost_capture_pkstep(self, index)
  local form_rp_arm = nx_value(form_table[1])
  if not nx_is_valid(form_rp_arm) then
    return
  end
  form_rp_arm.gb_self_shan_e.Visible = false
end
function get_titlelevel_tips_text()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local power = nx_int(client_player:QueryProp("PowerLevel"))
  local title = client_player:QueryProp("LevelTitle")
  local name = gui.TextManager:GetText("desc_" .. title)
  local next_power, next_title = get_next_power_title(power, title)
  local famous = client_player:QueryProp("FamousNeiGongName")
  if next_title == nil then
    if famous == nil or famous == 0 or nx_widestr(famous) == nx_widestr("") then
      gui.TextManager:Format_SetIDName("tips_titlelevel_0_0")
      gui.TextManager:Format_AddParam(name)
      gui.TextManager:Format_AddParam(power)
    else
      local tbl_famous = util_split_wstring(famous, ",")
      local famous_ng_id = nx_string(tbl_famous[1])
      local famous_ng_name = gui.TextManager:GetText(famous_ng_id)
      local famous_ng_level = nx_int(tbl_famous[2])
      gui.TextManager:Format_SetIDName("tips_titlelevel_1_0")
      gui.TextManager:Format_AddParam(name)
      gui.TextManager:Format_AddParam(famous_ng_name)
      gui.TextManager:Format_AddParam(famous_ng_level)
      gui.TextManager:Format_AddParam(power)
    end
  else
    local next_name = gui.TextManager:GetText("desc_" .. next_title)
    local need_power = nx_int(next_power - power)
    if famous == nil or famous == 0 or nx_widestr(famous) == nx_widestr("") then
      gui.TextManager:Format_SetIDName("tips_titlelevel_0_1")
      gui.TextManager:Format_AddParam(name)
      gui.TextManager:Format_AddParam(power)
      gui.TextManager:Format_AddParam(next_name)
      gui.TextManager:Format_AddParam(need_power)
    else
      local tbl_famous = util_split_wstring(famous, ",")
      local famous_ng_id = nx_string(tbl_famous[1])
      local famous_ng_name = gui.TextManager:GetText(famous_ng_id)
      local famous_ng_level = nx_int(tbl_famous[2])
      gui.TextManager:Format_SetIDName("tips_titlelevel_1_1")
      gui.TextManager:Format_AddParam(name)
      gui.TextManager:Format_AddParam(famous_ng_name)
      gui.TextManager:Format_AddParam(famous_ng_level)
      gui.TextManager:Format_AddParam(power)
      gui.TextManager:Format_AddParam(next_name)
      gui.TextManager:Format_AddParam(need_power)
    end
  end
  local text = gui.TextManager:Format_GetText()
  if power >= nx_int(ELITE_PLAYER_LEVEL) then
    text = text .. nx_widestr("<br>") .. gui.TextManager:GetText("tips_levelpunish_s")
  end
  local neigong_var = client_player:QueryProp("NeigongUseValue")
  if nx_int(neigong_var) >= nx_int(1) then
    text = text .. nx_widestr("<br>")
    text = text .. gui.TextManager:GetFormatText("tips_neigongyanxiu_title")
    text = text .. format_yanxiu_var(gui, neigong_var)
  end
  local wuxue_var = client_player:QueryProp("SkillUseValue")
  if nx_int(wuxue_var) >= nx_int(1) then
    text = text .. nx_widestr("<br>")
    text = text .. gui.TextManager:GetFormatText("tips_wuxueyanxiu_title")
    text = text .. format_yanxiu_var(gui, wuxue_var)
  end
  local jingmai_var = client_player:QueryProp("JingMaiTotalLevel")
  if nx_int(jingmai_var) >= nx_int(1) then
    text = text .. nx_widestr("<br>")
    text = text .. gui.TextManager:GetFormatText("tips_jingmaiyanxiu_title")
    text = text .. format_jingmai_level_var(gui, jingmai_var)
  end
  return text
end
function format_yanxiu_var(gui, var)
  local yi = math.floor(nx_int(var) / nx_int(10000))
  local wan = nx_int(var) - nx_int(yi * 10000)
  local text = nx_widestr("<font color=\"#ffff00\">")
  if nx_int(yi) > nx_int(0) then
    text = text .. nx_widestr(yi)
    text = text .. gui.TextManager:GetFormatText("ui_rank_yi")
  end
  if nx_int(wan) > nx_int(0) then
    text = text .. nx_widestr(wan)
    text = text .. gui.TextManager:GetFormatText("ui_rank_wan")
  end
  text = text .. nx_widestr("</font>")
  return text
end
function format_jingmai_level_var(gui, var)
  local yi = math.floor(nx_int(var) / nx_int(100000000))
  local wan = math.floor((nx_int(var) - nx_int(yi * 100000000)) / nx_int(10000))
  local ge = nx_int(var) - nx_int(yi * 100000000) - nx_int(wan * 10000)
  local text = nx_widestr("<font color=\"#ffff00\">")
  if nx_int(yi) > nx_int(0) then
    text = text .. nx_widestr(yi)
    text = text .. gui.TextManager:GetFormatText("ui_rank_yi")
  end
  if nx_int(wan) > nx_int(0) then
    text = text .. nx_widestr(wan)
    text = text .. gui.TextManager:GetFormatText("ui_rank_wan")
  end
  if nx_int(yi) <= nx_int(0) and nx_int(wan) <= nx_int(0) then
    text = text .. nx_widestr(ge)
  end
  text = text .. nx_widestr("</font>")
  return text
end
function get_next_power_title(power, title)
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\FacultyLevel.ini")
  if not nx_is_valid(ini) then
    return 0, nil
  end
  if not ini:FindSection(nx_string("config")) then
    return 0, nil
  end
  local sec_index = ini:FindSectionIndex(nx_string("config"))
  if sec_index < 0 then
    return 0, nil
  end
  local power_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
  local next_power = power
  local next_title
  for i = 1, table.getn(power_table) do
    local info_lst = util_split_string(power_table[i], ",")
    if nx_int(power) < nx_int(info_lst[1]) and nx_string(title) ~= nx_string(info_lst[3]) then
      next_power = nx_int(info_lst[1])
      next_title = nx_string(info_lst[3])
      break
    end
  end
  return next_power, next_title
end
function on_lbl_flower_get_capture(self)
  local x = self.AbsLeft + self.Width
  local y = self.AbsTop - self.Height
  local tip_text = nx_widestr(util_text("ui_flower_tips"))
  nx_execute("tips_game", "show_text_tip", tip_text, x, y)
end
function on_lbl_flower_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_lbl_egg_get_capture(self)
  local x = self.AbsLeft + self.Width
  local y = self.AbsTop - self.Height
  local tip_text = nx_widestr(util_text("ui_egg_tips"))
  nx_execute("tips_game", "show_text_tip", tip_text, x, y)
end
function on_lbl_egg_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_rbtn_6_get_capture(self)
  local is_vip = check_vip_player()
  if nx_int(is_vip) == nx_int(1) then
    return
  end
  local x = self.AbsLeft
  local y = self.AbsTop
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_onestep_tip")
  nx_execute("tips_game", "show_text_tip", text, x, y)
end
function on_rbtn_6_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function open_form()
  nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
  local form = nx_value("form_stage_main\\form_role_info\\form_rp_arm")
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_treasure.Checked = true
end
function on_body_type_change(form)
  if not nx_is_valid(form) then
    return
  end
  if check_body_player() then
    form.rbtn_11.Enabled = true
  else
    form.rbtn_11.Enabled = false
    form.rbtn_1.Checked = true
    on_rbtn_info_click(form.rbtn_1)
  end
end
function on_rbtn_11_get_capture(self)
  local is_vip = check_body_player()
  if is_vip == true then
    return
  end
  local x = self.AbsLeft
  local y = self.AbsTop
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_body_1")
  nx_execute("tips_game", "show_text_tip", text, x, y)
end
function on_rbtn_11_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
