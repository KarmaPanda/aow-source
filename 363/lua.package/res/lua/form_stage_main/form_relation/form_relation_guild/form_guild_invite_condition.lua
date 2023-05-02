require("custom_sender")
require("util_gui")
local FORBID_JION_GUILD_WITHOUT_SCHOOL = 0
local ALLOW_JION_GUILD_WITHOUT_SCHOOL = 1
local FORBID_JION_GUILD_NEW_SCHOOL = 0
local ALLOW_JION_GUILD_NEW_SCHOOL = 1
function main_form_init(self)
  self.Fixed = true
  self.can_jinyiwei = false
  self.can_gaibang = false
  self.can_junzitang = false
  self.can_jilegu = false
  self.can_tangmen = false
  self.can_emei = false
  self.can_wudang = false
  self.can_shaolin = false
  self.can_mingjiao = false
  self.can_tianshan = false
  self.invite_ability = 0
  self.is_captain = false
end
function on_main_form_open(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_name = client_player:QueryProp("GuildName")
  nx_execute("custom_sender", "custom_request_join_suggest", guild_name)
end
function on_main_form_close(self)
end
function on_rbtn_checked_changed(self)
  local form = self.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  if self.Checked then
    form.invite_ability = self.DataSource
    form.btn_cancel.Enabled = true
    form.btn_ok.Enabled = true
  end
end
function on_cbtn_school_checked_changed(self)
  local form = self.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  if nx_int(self.DataSource) == nx_int(1) then
    form.can_jinyiwei = self.Checked
  elseif nx_int(self.DataSource) == nx_int(2) then
    form.can_gaibang = self.Checked
  elseif nx_int(self.DataSource) == nx_int(3) then
    form.can_junzitang = self.Checked
  elseif nx_int(self.DataSource) == nx_int(4) then
    form.can_jilegu = self.Checked
  elseif nx_int(self.DataSource) == nx_int(5) then
    form.can_tangmen = self.Checked
  elseif nx_int(self.DataSource) == nx_int(6) then
    form.can_emei = self.Checked
  elseif nx_int(self.DataSource) == nx_int(7) then
    form.can_wudang = self.Checked
  elseif nx_int(self.DataSource) == nx_int(8) then
    form.can_shaolin = self.Checked
  elseif nx_int(self.DataSource) == nx_int(10) then
    form.can_mingjiao = self.Checked
  elseif nx_int(self.DataSource) == nx_int(11) then
    form.can_tianshan = self.Checked
  end
  form.btn_cancel.Enabled = true
  form.btn_ok.Enabled = true
end
function on_btn_ok_click(self)
  local form = self.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  if condition_changed == false then
    return
  end
  local gui = nx_value("gui")
  local school_condition = ""
  local without_school = nx_int(FORBID_JION_GUILD_WITHOUT_SCHOOL)
  local without_newschool = nx_int(FORBID_JION_GUILD_WITHOUT_SCHOOL)
  if form.can_jinyiwei == true then
    school_condition = nx_string(school_condition) .. "jinyiwei,"
  end
  if form.can_gaibang == true then
    school_condition = nx_string(school_condition) .. "gaibang,"
  end
  if form.can_junzitang == true then
    school_condition = nx_string(school_condition) .. "junzitang,"
  end
  if form.can_jilegu == true then
    school_condition = nx_string(school_condition) .. "jilegu,"
  end
  if form.can_tangmen == true then
    school_condition = nx_string(school_condition) .. "tangmen,"
  end
  if form.can_emei == true then
    school_condition = nx_string(school_condition) .. "emei,"
  end
  if form.can_wudang == true then
    school_condition = nx_string(school_condition) .. "wudang,"
  end
  if form.can_shaolin == true then
    school_condition = nx_string(school_condition) .. "shaolin,"
  end
  if form.can_mingjiao == true then
    school_condition = nx_string(school_condition) .. "mingjiao,"
  end
  if form.can_tianshan == true then
    school_condition = nx_string(school_condition) .. "tianshan,"
  end
  if form.cbtn_wumenpai.Checked == true then
    without_school = nx_int(ALLOW_JION_GUILD_WITHOUT_SCHOOL)
  end
  if form.cbtn_yinshi.Checked == true then
    without_newschool = nx_int(ALLOW_JION_GUILD_NEW_SCHOOL)
  end
  custom_request_guild_set_suggest(nx_string(school_condition), nx_int(form.invite_ability), nx_int(without_school), nx_int(without_newschool))
end
function on_msg(...)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_invite_condition", false, false)
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 2 then
    return
  end
  local cam_jyw = string.find(nx_string(arg[1]), "jinyiwei")
  local can_gb = string.find(nx_string(arg[1]), "gaibang")
  local can_jzt = string.find(nx_string(arg[1]), "junzitang")
  local can_jlg = string.find(nx_string(arg[1]), "jilegu")
  local can_tm = string.find(nx_string(arg[1]), "tangmen")
  local can_em = string.find(nx_string(arg[1]), "emei")
  local can_wd = string.find(nx_string(arg[1]), "wudang")
  local can_sl = string.find(nx_string(arg[1]), "shaolin")
  local can_mj = string.find(nx_string(arg[1]), "mingjiao")
  local can_ts = string.find(nx_string(arg[1]), "tianshan")
  if cam_jyw ~= nil then
    form.can_jinyiwei = true
  else
    form.can_jinyiwei = false
  end
  if can_gb ~= nil then
    form.can_gaibang = true
  else
    form.can_gaibang = false
  end
  if can_jzt ~= nil then
    form.can_junzitang = true
  else
    form.can_junzitang = false
  end
  if can_jlg ~= nil then
    form.can_jilegu = true
  else
    form.can_jilegu = false
  end
  if can_tm ~= nil then
    form.can_tangmen = true
  else
    form.can_tangmen = false
  end
  if can_em ~= nil then
    form.can_emei = true
  else
    form.can_emei = false
  end
  if can_wd ~= nil then
    form.can_wudang = true
  else
    form.can_wudang = false
  end
  if can_sl ~= nil then
    form.can_shaolin = true
  else
    form.can_shaolin = false
  end
  if can_mj ~= nil then
    form.can_mingjiao = true
  else
    form.can_mingjiao = false
  end
  if can_ts ~= nil then
    form.can_tianshan = true
  else
    form.can_tianshan = false
  end
  form.invite_ability = nx_int(arg[2])
  form.wo_school = nx_int(arg[3])
  form.wu_newschool = nx_int(arg[4])
  refresh_condition(form)
end
function refresh_condition(form)
  if not nx_is_valid(form) then
    return 0
  end
  form.cbtn_jinyiwei.Checked = form.can_jinyiwei
  form.cbtn_gaibang.Checked = form.can_gaibang
  form.cbtn_junzitang.Checked = form.can_junzitang
  form.cbtn_jilegu.Checked = form.can_jilegu
  form.cbtn_tangmen.Checked = form.can_tangmen
  form.cbtn_emei.Checked = form.can_emei
  form.cbtn_wudang.Checked = form.can_wudang
  form.cbtn_shaolin.Checked = form.can_shaolin
  form.cbtn_mingjiao.Checked = form.can_mingjiao
  form.cbtn_tianshan.Checked = form.can_tianshan
  form.cbtn_wumenpai.Checked = nx_int(form.wo_school) == nx_int(ALLOW_JION_GUILD_WITHOUT_SCHOOL)
  form.cbtn_yinshi.Checked = nx_int(form.wu_newschool) == nx_int(ALLOW_JION_GUILD_WITHOUT_SCHOOL)
  if nx_int(form.invite_ability) < nx_int(1) then
    form.invite_ability = 1
  end
  local rbtn = form.groupbox_lv:Find("rbtn_abil_" .. nx_string(form.invite_ability))
  if not nx_is_valid(rbtn) then
    return
  end
  rbtn.Checked = true
end
function on_btn_cancel_click(self)
  local form = self.Parent.Parent
  if not nx_is_valid(form) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_name = client_player:QueryProp("GuildName")
  nx_execute("custom_sender", "custom_request_join_suggest", guild_name)
end
