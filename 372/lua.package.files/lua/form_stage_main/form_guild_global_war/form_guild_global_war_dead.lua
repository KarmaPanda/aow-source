require("util_gui")
require("define\\team_rec_define")
require("define\\map_lable_define")
require("form_stage_main\\form_die_util")
local FORM_NAME = "form_stage_main\\form_guild_global_war\\form_guild_global_war_dead"
local origin_x = 0
local origin_z = 0
local orient_o = 0
local flag_map_x = 240
local flag_map_y = 135
local zoom = math.sqrt(268324) / math.sqrt(489100) * 1.6
function open_or_hide()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  else
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
  end
end
function main_form_init(self)
  self.Fixed = false
  self.refresh_time = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local game_timer = nx_value("timer_game")
  game_timer:Register(3000, -1, nx_current(), "on_update_info", self, -1, -1)
  self.lbl_timer.Text = nx_widestr(180)
  game_timer:Register(1000, -1, nx_current(), "on_update_timer", self, -1, -1)
  nx_execute("custom_sender", "custom_guildglobalwar", nx_int(102))
  fresh_relive_form(self)
  if is_in_cross_station_war() then
    self.btn_relive_returncity.Text = nx_widestr(util_text("ui_guild_kuafu_station_shp_30"))
    self.btn_relive_returncity.HintText = nx_widestr(util_text("ui_guild_kuafu_station_shp_31"))
    self.btn_relive_local_strong.Enabled = false
  end
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_info", self)
    timer:UnRegister(nx_current(), "on_relive", self)
    timer:UnRegister(nx_current(), "on_update_timer", self)
  end
  if nx_execute("custom_effect", "is_cursing", "curse_ggw") then
    nx_execute("custom_effect", "custom_end_curse")
  end
  nx_destroy(self)
end
function on_update_info()
  nx_execute("custom_sender", "custom_guildglobalwar", nx_int(102))
end
function on_update_timer(form)
  local now = nx_number(form.lbl_timer.Text)
  if 0 < now then
    now = now - 1
    form.lbl_timer.Text = nx_widestr(now)
    if now == 0 then
      local timer = nx_value("timer_game")
      if nx_is_valid(timer) then
        timer:UnRegister(nx_current(), "on_relive", form)
      end
      if nx_execute("custom_effect", "is_cursing", "curse_ggw") then
        nx_execute("custom_effect", "custom_end_curse")
      end
      nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_NEAR, nx_int(0))
    end
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function GetRotateAngle(x1, y1, x2, y2)
  local epsilon = 1.0E-6
  local angle
  local dist1 = math.sqrt(x1 * x1 + y1 * y1)
  local dist2 = math.sqrt(x2 * x2 + y2 * y2)
  if dist1 == 0 then
    dist1 = 1.0E-6
  end
  if dist2 == 0 then
    dist2 = 1.0E-6
  end
  x1 = x1 / dist1
  y1 = y1 / dist1
  x2 = x2 / dist2
  y2 = y2 / dist2
  local dot = x1 * x2 + y1 * y2
  if epsilon >= math.abs(dot - 1) then
    angle = 0
  elseif epsilon >= math.abs(dot + 1) then
    angle = math.pi
  else
    angle = math.acos(dot)
    local cross = x1 * y2 - x2 * y1
    if 0 < cross then
      angle = 2 * math.pi - angle
    end
  end
  return angle
end
function TransPosToMap(world_x, world_z)
  local x1 = world_x - origin_x
  local y1 = world_z - origin_z
  local x2 = math.sin(orient_o)
  local y2 = math.cos(orient_o)
  local dist = math.sqrt(x1 * x1 + y1 * y1)
  local dest_o = GetRotateAngle(x1, y1, x2, y2)
  local map_x = flag_map_x + math.sin(dest_o) * dist * zoom
  local map_y = flag_map_y + math.cos(dest_o) * dist * zoom
  return map_x, map_y
end
function on_btn_relive_click(btn)
  if nx_execute("custom_effect", "is_cursing") then
    return
  end
  local form = btn.ParentForm
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_relive", form)
  end
  for i = 1, 2 do
    local rbtn = form.gb:Find("rbtn_d_" .. nx_string(i))
    if nx_is_valid(rbtn) and rbtn.Checked and rbtn.Enabled then
      if nx_running("custom_effect", "custom_begin_curse") then
        nx_kill("custom_effect", "custom_begin_curse")
      end
      nx_execute("custom_effect", "custom_begin_curse", 3000, "curse_ggw")
      local game_timer = nx_value("timer_game")
      game_timer:Register(3000, -1, nx_current(), "on_relive", form, -1, -1)
      return
    end
  end
  for i = 1, 10 do
    local rbtn = form.gb:Find("rbtn_a_" .. nx_string(i))
    if nx_is_valid(rbtn) and rbtn.Checked and rbtn.Enabled then
      nx_execute("custom_effect", "custom_end_curse")
      nx_execute("custom_effect", "custom_begin_curse", 3000, "curse_ggw")
      local game_timer = nx_value("timer_game")
      game_timer:Register(3000, -1, nx_current(), "on_relive", form, -1, -1)
      return
    end
  end
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_gsp_009"))
end
function on_relive(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_relive", form)
  end
  for i = 1, 2 do
    local rbtn = form.gb:Find("rbtn_d_" .. nx_string(i))
    if nx_is_valid(rbtn) and rbtn.Checked and rbtn.Enabled then
      nx_execute("custom_sender", "custom_guildglobalwar", nx_int(103), nx_int(i - 1))
      return
    end
  end
  for i = 1, 10 do
    local rbtn = form.gb:Find("rbtn_a_" .. nx_string(i))
    if nx_is_valid(rbtn) and rbtn.Checked and rbtn.Enabled then
      nx_execute("custom_sender", "custom_guildglobalwar", nx_int(104), nx_int(i - 1))
      return
    end
  end
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_gsp_009"))
end
function on_btn_relive_near_click(btn)
  local form = btn.ParentForm
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_relive", form)
  end
  if nx_execute("custom_effect", "is_cursing", "curse_ggw") then
    nx_execute("custom_effect", "custom_end_curse")
  end
  nx_execute("form_stage_main\\form_die", "on_btn_relive_near_click", btn)
end
function on_btn_relive_returncity_click(btn)
  local form = btn.ParentForm
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_relive", form)
  end
  if nx_execute("custom_effect", "is_cursing", "curse_ggw") then
    nx_execute("custom_effect", "custom_end_curse")
  end
  nx_execute("form_stage_main\\form_die", "on_btn_return_city_click", btn)
end
function on_btn_relive_local_click(btn)
  local form = btn.ParentForm
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_relive", form)
  end
  if nx_execute("custom_effect", "is_cursing", "curse_ggw") then
    nx_execute("custom_effect", "custom_end_curse")
  end
  nx_execute("form_stage_main\\form_die", "on_btn_relive_local_click", btn)
end
function on_btn_relive_local_strong_click(btn)
  local form = btn.ParentForm
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_relive", form)
  end
  if nx_execute("custom_effect", "is_cursing", "curse_ggw") then
    nx_execute("custom_effect", "custom_end_curse")
  end
  nx_execute("form_stage_main\\form_die", "on_btn_relive_strong_click", btn)
end
function update_info(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local domain_id = nx_int(arg[1])
  local info = nx_widestr(arg[2])
  local info_wstr = util_split_wstring(info, nx_widestr(","))
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_name = client_player:QueryProp("GuildName")
  local flag_owner = nx_widestr(info_wstr[1])
  origin_x = nx_number(info_wstr[2])
  origin_y = nx_number(info_wstr[3])
  origin_z = nx_number(info_wstr[4])
  orient_o = nx_number(info_wstr[5])
  local enable = 0
  if nx_widestr(guild_name) ~= nx_widestr("") and nx_widestr(guild_name) == nx_widestr(flag_owner) then
    enable = 1
  end
  for i = 1, 2 do
    local rbtn = form.gb:Find("rbtn_d_" .. nx_string(i))
    if nx_is_valid(rbtn) then
      if enable == 0 then
        rbtn.Enabled = false
        rbtn.Checked = false
      else
        rbtn.Enabled = true
      end
    end
  end
  local relive_nums = nx_number(info_wstr[6])
  local arg_index = 6
  for i = 1, relive_nums do
    local relive_owner = nx_widestr(info_wstr[arg_index + 1])
    local relive_x = nx_float(info_wstr[arg_index + 2])
    local relive_y = nx_float(info_wstr[arg_index + 3])
    local relive_z = nx_float(info_wstr[arg_index + 4])
    local relive_o = nx_float(info_wstr[arg_index + 5])
    arg_index = arg_index + 5
    create_rbtn(form, i, "rbtn_a_" .. nx_string(i), relive_owner, relive_x, relive_y, relive_z, relive_o)
  end
end
function create_rbtn(form, index, name, owner, x, y, z, o)
  local rbtn = form.gb:Find(name)
  if rbtn == nil or not nx_is_valid(rbtn) then
    rbtn = create_ctrl("RadioButton", name, form.rbtn_mod, form.gb)
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_name = client_player:QueryProp("GuildName")
  local enable = 0
  if nx_widestr(guild_name) ~= nx_widestr("") and nx_widestr(guild_name) == nx_widestr(owner) then
    enable = 1
  end
  if nx_widestr(owner) == nx_widestr("") then
    rbtn.HintText = nx_widestr(util_format_string("ui_camp_text_2", name))
  else
    rbtn.HintText = nx_widestr(util_format_string("ui_camp_text", name, owner))
  end
  if enable == 0 then
    if rbtn.Checked == true then
      rbtn.Checked = false
    end
    rbtn.Enabled = false
  else
    rbtn.Enabled = true
  end
  local map_x, map_y = TransPosToMap(x, z)
  rbtn.Left = map_x - rbtn.Width / 2
  rbtn.Top = map_y - rbtn.Height / 2
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function fresh_relive_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  capital_type, money = nx_execute("form_stage_main\\form_die_util", "get_confirm_menoy", RELIVE_TYPE_LOCAL)
  if nx_int(capital_type) ~= nx_int(0) and nx_int(money) > nx_int(0) then
    if check_is_enough_money(capital_type, money) or check_is_enough_money(CAPITAL_TYPE_SILVER_CARD, money) then
      form.btn_relive_local.Enabled = true
    else
      form.btn_relive_local.Enabled = false
    end
  end
  capital_type, money = nx_execute("form_stage_main\\form_die_util", "get_confirm_menoy", RELIVE_TYPE_LOCAL_STRONG)
  if nx_int(capital_type) ~= nx_int(0) and nx_int(money) > nx_int(0) then
    if check_is_enough_money(capital_type, money) then
      form.btn_relive_local_strong.Enabled = true
    else
      form.btn_relive_local_strong.Enabled = false
    end
  end
  local relive_count = player:QueryProp("DailyReliveCount")
  if nx_int(relive_count) >= nx_int(MAX_RELIVE_COUNT_DAILY) then
    form.btn_relive_local_strong.Enabled = false
    form.btn_relive_local.Enabled = false
    form.btn_relive_local_strong.HintText = nx_widestr(gui.TextManager:GetFormatText("tips_heal_myself_1"))
    form.btn_relive_local.HintText = nx_widestr(gui.TextManager:GetFormatText("tips_heal_myself_1"))
  else
    form.btn_relive_local_strong.HintText = nx_widestr(gui.TextManager:GetFormatText("tips_heal_myself_health"))
    form.btn_relive_local.HintText = nx_widestr(gui.TextManager:GetFormatText("tips_heal_myself_weakness"))
  end
end
function is_in_cross_station_war()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindProp("CrossType") then
    return false
  end
  local prop_value = client_player:QueryProp("CrossType")
  return nx_int(prop_value) == nx_int(28)
end
function a(info)
  nx_msgbox(nx_string(info))
end
