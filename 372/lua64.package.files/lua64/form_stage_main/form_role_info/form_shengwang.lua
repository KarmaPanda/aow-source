require("util_gui")
require("tips_data")
local reputelist = {
  [1] = {
    str = "shaolin",
    name = "repute_shaolin"
  },
  [2] = {
    str = "wudang",
    name = "repute_wudang"
  },
  [3] = {
    str = "tangmen",
    name = "repute_tangmen"
  },
  [4] = {
    str = "junzitang",
    name = "repute_junzitang"
  },
  [5] = {
    str = "emei",
    name = "repute_emei"
  },
  [6] = {
    str = "jinyiwei",
    name = "repute_jinyiwei"
  },
  [7] = {
    str = "gaibang",
    name = "repute_gaibang"
  },
  [8] = {
    str = "jilegu",
    name = "repute_jilegu"
  },
  [9] = {
    str = "mingjiao",
    name = "repute_mingjiao"
  },
  [10] = {
    str = "tianshan",
    name = "repute_tianshan"
  },
  [11] = {
    str = "jianghu",
    name = "repute_jianghu"
  }
}
local school_plag = {
  school_shaolin = "gui\\language\\ChineseS\\shengwang\\sl.png",
  school_wudang = "gui\\language\\ChineseS\\shengwang\\wd.png",
  school_tangmen = "gui\\language\\ChineseS\\shengwang\\tm.png",
  school_junzitang = "gui\\language\\ChineseS\\shengwang\\jz.png",
  school_emei = "gui\\language\\ChineseS\\shengwang\\em.png",
  school_jinyiwei = "gui\\language\\ChineseS\\shengwang\\jy.png",
  school_gaibang = "gui\\language\\ChineseS\\shengwang\\gb.png",
  school_jilegu = "gui\\language\\ChineseS\\shengwang\\jl.png",
  school_mingjiao = "gui\\language\\ChineseS\\shengwang\\mj.png",
  school_tianshan = "gui\\language\\ChineseS\\shengwang\\ts.png"
}
INI_FORCE_INFO = "share\\War\\force_config.ini"
FORM_FORCE_INFO = "form_stage_main\\form_school_war\\form_new_school_msg_info"
FORM_NEW_SCHOOL_INFO = "form_stage_main\\form_school_war\\form_newschool_school_msg_info"
function refresh_form(form)
  if not nx_is_valid(form) or form.Visible then
  end
end
function data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddTableBind("Repute_Record", self, nx_current(), "set_jianghu_shengwang")
  databinder:AddRolePropertyBind("SchoolRuleValue", "int", self, nx_current(), "on_school_rule_value_changed")
  databinder:AddRolePropertyBind("School", "string", self, nx_current(), "set_school_role_value")
  databinder:AddTableBind("KarmaExpRec", self, nx_current(), "set_jianghu_yueli")
  databinder:AddRolePropertyBind("Force", "string", self, nx_current(), "on_force_changed")
  databinder:AddRolePropertyBind("NewSchool", "string", self, nx_current(), "on_force_changed")
end
function del_data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:DelTableBind("Repute_Record", self)
  databinder:DelRolePropertyBind("SchoolRuleValue", self)
  databinder:DelRolePropertyBind("School", self)
  databinder:DelRolePropertyBind("KarmaExp", self)
end
function form_shengwang_init(form)
  form.Fixed = true
  return 1
end
function on_form_shengwang_open(self)
  data_bind_prop(self)
end
function on_form_shengwang_close(form)
  if not nx_is_valid(form) then
    return
  end
  del_data_bind_prop(form)
  nx_destroy(form)
  nx_set_value("form_shengwang", nx_null())
end
function set_reputeinformation(self)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local repute_module = nx_value("ReputeModule")
  if not nx_is_valid(repute_module) then
    return
  end
  local lbl_name, text_id, pbar_name, scenebox_name, sbox_name, value, maxValue
  local level = 0
  local rows = 0
  for i, info in pairs(reputelist) do
    rows = client_player:FindRecordRow("Repute_Record", 0, nx_string(info.name), 0)
    if 0 <= rows then
      value = client_player:QueryRecord("Repute_Record", rows, 1)
      level = client_player:QueryRecord("Repute_Record", rows, 2)
    else
      value = nx_string("0")
      level = 1
    end
    local maxValue = repute_module:GetMaxReputeByLevel(nx_int(level) + 1)
    if i ~= 11 then
      pbar_name = self.groupbox_1:Find("pbar_" .. info.str)
      lbl_name = self.groupbox_1:Find("lbl_" .. info.str)
    else
      pbar_name = self.groupbox_2:Find("pbar_" .. info.str)
      lbl_name = self.groupbox_2:Find("lbl_" .. info.str)
    end
    pbar_name.Maximum = maxValue
    pbar_name.Value = value
    text_id = "ui_repute_" .. info.str .. "_" .. nx_string(level)
    lbl_name.Text = nx_widestr(util_text(text_id))
  end
end
function set_jianghu_shengwang(form)
  local repute_module = nx_value("ReputeModule")
  if not nx_is_valid(form) and not nx_is_valid(repute_module) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local value = nx_string("0")
  local level = 1
  local rows = client_player:FindRecordRow("Repute_Record", 0, nx_string("repute_jianghu"), 0)
  if 0 <= rows then
    value = client_player:QueryRecord("Repute_Record", rows, 1)
    level = client_player:QueryRecord("Repute_Record", rows, 2)
  end
  value = nx_number(value)
  local maxValue = repute_module:GetMaxReputeByLevel(nx_int(level) + 1)
  local ctrl_pbar = form.pbar_jianghu
  local ctrl_name = form.lbl_jianghu
  local lbl_wan = form.lbl_wan
  ctrl_pbar.Maximum = maxValue
  ctrl_pbar.Value = value
  local text_id = "ui_repute_jianghu_" .. nx_string(level)
  ctrl_name.Text = nx_widestr(util_text(text_id))
  if value < 10000 then
    if not ctrl_pbar.TextVisible then
      ctrl_pbar.TextVisible = true
    end
    if lbl_wan.Visible then
      lbl_wan.Visible = false
    end
  else
    local val_wan = nx_int(value / 10000)
    lbl_wan.Text = nx_widestr(val_wan) .. nx_widestr(util_text("ui_wan"))
    if ctrl_pbar.TextVisible then
      ctrl_pbar.TextVisible = false
    end
    if not lbl_wan.Visible then
      lbl_wan.Visible = true
    end
  end
end
function set_school_role_value(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  local school_name = client_player:QueryProp("School")
  local force = client_player:QueryProp("Force")
  local new_school = client_player:QueryProp("NewSchool")
  if nx_int(string.len(new_school)) > nx_int(1) then
    force = new_school
  end
  if nx_int(string.len(force)) > nx_int(1) then
    return
  end
  if string.len(school_name) > 1 then
    local school_role_value = client_player:QueryProp("SchoolRuleValue")
    form.groupbox_1.Visible = true
    form.lbl_2.BackImage = school_plag[school_name]
    form.lbl_rule_value.Text = nx_widestr(school_role_value)
    if 100 <= school_role_value then
      form.lbl_rule_value.ForeColor = "255,241,15,0"
      form.pbar_school_rule.ProgressImage = "gui\\common\\progressbar\\pbr_1.png"
      form.pbar_school_rule.Maximum = school_role_value
      form.pbar_school_rule.Value = school_role_value
    else
      form.lbl_rule_value.ForeColor = form.lbl_school_rule.ForeColor
      form.pbar_school_rule.ProgressImage = "gui\\common\\progressbar\\pbr_2.png"
      form.pbar_school_rule.Maximum = 100
      form.pbar_school_rule.Value = school_role_value
    end
    form.lbl_12.Text = nx_widestr(util_text("ui_SchoolRule_repent_tips"))
  else
    form.groupbox_1.Visible = false
  end
  if true == form.groupbox_3.Visible then
    form.groupbox_3.Left = -8
    form.groupbox_3.Top = 264
  end
end
function on_btn_school_role_click(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local new_school = client_player:QueryProp("NewSchool")
  if nx_int(string.len(new_school)) > nx_int(1) then
    local form_new_school = util_get_form(FORM_NEW_SCHOOL_INFO, true)
    if nx_is_valid(form_new_school) then
      util_show_form(FORM_NEW_SCHOOL_INFO, true)
      form_new_school.rbtn_m3.Checked = true
      nx_execute(FORM_NEW_SCHOOL_INFO, "on_m_checked_changed", form_new_school.rbtn_m3)
      return
    end
  end
  local force = ""
  if client_player:FindProp("Force") then
    force = client_player:QueryProp("Force")
  end
  if nx_string(force) ~= nx_string("") then
    local form_force = util_get_form(FORM_FORCE_INFO, true)
    if nx_is_valid(form_force) then
      util_show_form(FORM_FORCE_INFO, true)
      form_force.rbtn_m3.Checked = true
      nx_execute(FORM_FORCE_INFO, "on_m_checked_changed", form_force.rbtn_m3)
      return
    end
  end
  local playerschool = client_player:QueryProp("School")
  local SchoolID = 5
  if playerschool == "school_jinyiwei" then
    SchoolID = 5
  elseif playerschool == "school_gaibang" then
    SchoolID = 6
  elseif playerschool == "school_junzitang" then
    SchoolID = 7
  elseif playerschool == "school_jilegu" then
    SchoolID = 8
  elseif playerschool == "school_tangmen" then
    SchoolID = 9
  elseif playerschool == "school_emei" then
    SchoolID = 10
  elseif playerschool == "school_wudang" then
    SchoolID = 11
  elseif playerschool == "school_shaolin" then
    SchoolID = 12
  elseif playerschool == "school_mingjiao" then
    SchoolID = 769
  elseif playerschool == "school_tianshan" then
    SchoolID = 832
  end
  local form_school_msg = util_get_form("form_stage_main\\form_school_war\\form_school_msg_info", true)
  if nx_is_valid(form_school_msg) then
    nx_execute("form_stage_main\\form_school_war\\form_school_msg_info", "show_rule_info", SchoolID)
  end
end
function on_lbl_wan_get_capture(self)
  local x = self.AbsLeft + self.Width / 2
  local y = self.AbsTop - self.Height
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local value = nx_string("0")
  local level = 1
  local rows = client_player:FindRecordRow("Repute_Record", 0, nx_string("repute_jianghu"), 0)
  if 0 <= rows then
    value = client_player:QueryRecord("Repute_Record", rows, 1)
    level = client_player:QueryRecord("Repute_Record", rows, 2)
  end
  local repute_module = nx_value("ReputeModule")
  if not nx_is_valid(form) and not nx_is_valid(repute_module) then
    return
  end
  local maxValue = repute_module:GetMaxReputeByLevel(nx_int(level) + 1)
  local tip_text = nx_widestr(nx_string(value) .. "/" .. nx_string(maxValue))
  nx_execute("tips_game", "show_text_tip", tip_text, x, y)
end
function on_lbl_wan_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function set_jianghu_yueli(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  local karma_exp = client_player:QueryRecord("KarmaExpRec", 0, 0)
  if nx_number(karma_exp) <= nx_number(0) then
    form.groupbox_3.Visible = false
    return
  end
  form.groupbox_3.Visible = true
  if false == form.groupbox_1.Visible then
    form.groupbox_3.Left = -8
    form.groupbox_3.Top = 136
  else
    form.groupbox_3.Left = -8
    form.groupbox_3.Top = 264
  end
  local gui = nx_value("gui")
  if nx_number(karma_exp) >= nx_number(0) and nx_number(karma_exp) <= nx_number(1799) then
    form.lbl_yueli.Text = gui.TextManager:GetText("KarmaExp_1")
    form.pbar_yueli.Maximum = 1800
  elseif nx_number(karma_exp) >= nx_number(1800) and nx_number(karma_exp) <= nx_number(10799) then
    form.lbl_yueli.Text = gui.TextManager:GetText("KarmaExp_2")
    form.pbar_yueli.Maximum = 10800
  elseif nx_number(karma_exp) >= nx_number(10800) and nx_number(karma_exp) <= nx_number(36719) then
    form.lbl_yueli.Text = gui.TextManager:GetText("KarmaExp_3")
    form.pbar_yueli.Maximum = 36720
  elseif nx_number(karma_exp) >= nx_number(36720) and nx_number(karma_exp) <= nx_number(88559) then
    form.lbl_yueli.Text = gui.TextManager:GetText("KarmaExp_4")
    form.pbar_yueli.Maximum = 88560
  elseif nx_number(karma_exp) >= nx_number(88560) and nx_number(karma_exp) <= nx_number(174959) then
    form.lbl_yueli.Text = gui.TextManager:GetText("KarmaExp_5")
    form.pbar_yueli.Maximum = 174960
  elseif nx_number(karma_exp) >= nx_number(174960) and nx_number(karma_exp) <= nx_number(329399) then
    form.lbl_yueli.Text = gui.TextManager:GetText("KarmaExp_6")
    form.pbar_yueli.Maximum = 329400
  elseif nx_number(karma_exp) >= nx_number(329400) and nx_number(karma_exp) <= nx_number(588599) then
    form.lbl_yueli.Text = gui.TextManager:GetText("KarmaExp_7")
    form.pbar_yueli.Maximum = 588600
  elseif nx_number(karma_exp) >= nx_number(588600) and nx_number(karma_exp) <= nx_number(1020599) then
    form.lbl_yueli.Text = gui.TextManager:GetText("KarmaExp_8")
    form.pbar_yueli.Maximum = 1020600
  elseif nx_number(karma_exp) >= nx_number(1020600) then
    form.lbl_yueli.Text = gui.TextManager:GetText("KarmaExp_9")
    form.pbar_yueli.Maximum = 1695600
  end
  if nx_number(karma_exp) > nx_number(1695600) then
    form.pbar_yueli.Value = form.pbar_yueli.Maximum
  else
    form.pbar_yueli.Value = nx_int(karma_exp)
  end
end
function on_lbl_3_wan_get_capture(self)
  local x = self.AbsLeft + self.Width / 2
  local y = self.AbsTop - self.Height
  local form = self.ParentForm
  local value = form.pbar_yueli.Value
  local maxValue = form.pbar_yueli.Maximum
  local tip_text = nx_widestr(nx_string(value) .. "/" .. nx_string(maxValue))
  nx_execute("tips_game", "show_text_tip", tip_text, x, y)
end
function on_lbl_3_wan_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_lbl_3_19_get_capture(self)
  local x = self.AbsLeft + self.Width / 2
  local y = self.AbsTop - self.Height
  local gui = nx_value("gui")
  local tip_text = nx_widestr(gui.TextManager:GetText("tips_karmaexp"))
  nx_execute("tips_game", "show_text_tip", tip_text, x, y)
end
function on_show_yueli_info_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_prestige_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_origin\\form_kapai")
end
function on_school_rule_value_changed(form)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local force = player:QueryProp("Force")
  local new_school = player:QueryProp("NewSchool")
  if nx_int(string.len(new_school)) > nx_int(1) then
    force = new_school
  end
  if nx_int(string.len(force)) > nx_int(1) then
    on_force_changed(form)
  else
    local school = player:QueryProp("School")
    if nx_int(string.len(school)) > nx_int(1) then
      set_school_role_value(form)
    end
  end
end
function on_force_changed(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local force = player:QueryProp("Force")
  local new_school = player:QueryProp("NewSchool")
  if nx_int(string.len(new_school)) > nx_int(1) then
    force = new_school
  end
  if nx_int(string.len(force)) > nx_int(1) then
    form.groupbox_1.Visible = true
    local force_ini = get_ini(INI_FORCE_INFO)
    if not nx_is_valid(force_ini) then
      return
    end
    local index = force_ini:FindSectionIndex(force)
    form.lbl_2.BackImage = force_ini:ReadString(index, "IconPath", "")
    local school_role_value = player:QueryProp("SchoolRuleValue")
    form.lbl_rule_value.Text = nx_widestr(school_role_value)
    if nx_int(school_role_value) >= nx_int(400) then
      form.lbl_rule_value.ForeColor = "255,241,15,0"
      form.pbar_school_rule.ProgressImage = "gui\\common\\progressbar\\pbr_1.png"
      form.pbar_school_rule.Maximum = 500
      form.pbar_school_rule.Value = school_role_value
    else
      form.lbl_rule_value.ForeColor = form.lbl_school_rule.ForeColor
      form.pbar_school_rule.ProgressImage = "gui\\common\\progressbar\\pbr_2.png"
      form.pbar_school_rule.Maximum = 500
      form.pbar_school_rule.Value = school_role_value
    end
    form.lbl_12.Text = nx_widestr(util_text("ui_schoolrule_repent_forcetips"))
    local new_school = player:QueryProp("NewSchool")
    if nx_int(string.len(new_school)) > nx_int(1) then
      form.lbl_12.Text = nx_widestr(util_text("ui_schoollaw_punishment_newmprule"))
    end
  else
    form.groupbox_1.Visible = false
  end
  if true == form.groupbox_3.Visible then
    form.groupbox_3.Left = -8
    form.groupbox_3.Top = 264
  end
end
