require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\form_die_util")
local INTERVALTIME = 5000
function on_main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  gui.Desktop:ToFront(self)
  self.ok_btn.Enabled = false
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("MP", "int", self, nx_current(), "refresh_mp")
  databinder:AddRolePropertyBind("MaxMP", "int", self, nx_current(), "refresh_mp")
  databinder:AddRolePropertyBind("MaxMPAdd", "int", self, nx_current(), "refresh_mp")
  refresh_mp(self)
  self.send_help_time = 0
  self.cure_limit_time = nx_function("ext_get_tickcount")
  local cure_timer = nx_value("timer_game")
  cure_timer:UnRegister(nx_current(), "update_time", self)
  cure_timer:Register(1000, -1, nx_current(), "update_time", self, -1, -1)
  local relive_count = 0
  local relive_max_num = MAX_RELIVE_COUNT_DAILY
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) then
      if IsInJHScene() then
        relive_count = client_player:QueryProp("DailyJHSceneReliveCount")
        relive_max_num = JHSCENE_MAX_RELIVE_COUNT_DAILY
      else
        relive_count = client_player:QueryProp("DailyReliveCount")
        relive_max_num = MAX_RELIVE_COUNT_DAILY
      end
      local pkmode = client_player:QueryProp("PKMode")
      if pkmode == 3 then
        self.btn_local.Enabled = false
        self.btn_local_strong.Enabled = false
      end
      local find_buffer = nx_function("find_buffer", client_player, "buf_assist_2")
      if find_buffer then
        self.help_btn.Enabled = false
      end
      if client_player:QueryProp("IsInSchoolFight") == 1 then
        self.ok_btn.Visible = false
      end
      if 0 < client_player:QueryProp("GuildWarSide") then
        self.ok_btn.Visible = false
      end
      if IsInJHScene() and not IsInLoulan() then
        self.ok_btn.Visible = false
      end
      if 0 < client_player:QueryProp("IsInWorldWar") then
        self.ok_btn.Visible = false
      end
      if IsInErgWar() then
        self.ok_btn.Visible = false
      end
      if IsInSanMeng() then
        self.ok_btn.Visible = false
      end
    end
  end
  if nx_int(relive_count) >= nx_int(relive_max_num) then
    self.btn_local.Enabled = false
    self.btn_local_strong.Enabled = false
    local count_str = gui.TextManager:GetFormatText("ui_revive_max", nx_int(relive_count))
    self.lbl_count.Text = nx_widestr(count_str)
  else
    local left_count = nx_int(relive_max_num) - nx_int(relive_count)
    local count_str = gui.TextManager:GetFormatText("ui_revive_count", nx_int(left_count))
    self.lbl_count.Text = nx_widestr(count_str)
  end
  reset_control_pos(self)
  return
end
function on_main_form_close(self)
  local cure_timer = nx_value("timer_game")
  cure_timer:UnRegister(nx_current(), "update_time", self)
  local confirm_dialog = nx_value("form_stage_main\\form_relive_ok")
  if nx_is_valid(confirm_dialog) then
    confirm_dialog:Close()
  end
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function update_time(form)
  local curtime = nx_function("ext_get_tickcount")
  local leavetime = math.ceil((60000 - curtime + form.cure_limit_time) / 1000)
  if nx_int(leavetime) == nx_int(40) then
    form.ok_btn.Enabled = true
  end
  if nx_int(leavetime) <= nx_int(0) then
    form.lbl_time.Text = nx_widestr(nx_widestr("0"))
    form.help_btn.Visible = false
    local cure_timer = nx_value("timer_game")
    cure_timer:UnRegister(nx_current(), "update_time", form)
    return
  end
  form.lbl_time.Text = nx_widestr(nx_int(leavetime))
end
function refresh_mp(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local curmp = nx_int(client_player:QueryProp("MP"))
  local maxmp = nx_int(client_player:QueryProp("MaxMP"))
  local maxmpadd = nx_int(client_player:QueryProp("MaxMPAdd"))
  local maxvalue = maxmp + maxmpadd
  if nx_int(maxvalue) <= nx_int(0) then
    form.pbar_1.Value = 0
    return
  end
  form.pbar_1.Value = nx_int(curmp / maxvalue * 100)
end
function on_help_btn_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local find_buffer = nx_function("find_buffer", client_player, "buf_assist_2")
  if find_buffer then
    return
  end
  local cur_time = nx_function("ext_get_tickcount")
  local delta = cur_time - form.send_help_time
  if nx_int(delta) < nx_int(INTERVALTIME) then
    return
  end
  form.send_help_time = cur_time
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RELIVE), RELIVE_TYPE_CURE, CURE_TYPE_HELP)
  return
end
function on_ok_btn_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) and client_player:QueryProp("BattlefieldState") == 3 then
      nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_BATTLEFIELD)
      return
    end
  end
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return
  end
  if interactmgr:GetInteractStatus(ITT_SSG_PROBATION) == PIS_IN_GAME then
    nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_NEAR, nx_int(0))
    return
  elseif interactmgr:GetInteractStatus(ITT_AGREE_WAR) == PIS_IN_GAME then
    nx_execute("custom_sender", "custom_agree_war", nx_int(4), nx_int(0))
    return
  elseif IsInBalanceWar() then
    nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_NEAR, nx_int(0))
    return
  elseif IsInWuDaoFighting() then
    nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_NEAR, nx_int(0))
    return
  elseif IsInLuanDouFightScene() then
    nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_NEAR, nx_int(0))
    return
  end
  nx_execute("custom_sender", "custom_relive_check")
end
function on_btn_local_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not show_ok_dialog(form, RELIVE_TYPE_LOCAL) then
    return
  end
  nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_LOCAL, 0)
end
function on_btn_local_strong_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not show_ok_dialog(form, RELIVE_TYPE_LOCAL_STRONG) then
    return
  end
  nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_LOCAL_STRONG, 0)
end
function on_relive_check(ret)
  local form = util_get_form("form_stage_main\\form_hurt_danger", false)
  if nx_int(ret) == nx_int(1) then
    nx_execute(nx_current(), "show_ok_dialog", form, RELIVE_TYPE_SPECIAL)
  else
    nx_execute(nx_current(), "show_ok_dialog", form, RELIVE_TYPE_NEAR)
  end
end
function show_ok_dialog(form, relive_type)
  if not nx_is_valid(form) then
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
  local gui = nx_value("gui")
  local dialog = util_get_form("form_stage_main\\form_relive_ok", true, false)
  if not nx_is_valid(dialog) then
    return false
  end
  local str = get_confirm_info(relive_type, false, "")
  if nx_int(relive_type) == nx_int(RELIVE_TYPE_SPECIAL) then
    relive_type = RELIVE_TYPE_NEAR
  end
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(nx_widestr(str), -1)
  local capital_type, capital_num = get_confirm_menoy(relive_type)
  if capital_type == nil or capital_num == nil then
    dialog.mltbox_money_info.Text = ""
  elseif nx_int(capital_type) == nx_int(1) then
    local money = convert_money(nx_number(capital_num))
    local money_info = gui.TextManager:GetFormatText("ui_fuhuo_suiyin", money)
    dialog.mltbox_money_info:AddHtmlText(nx_widestr(money_info), -1)
  elseif nx_int(capital_type) == nx_int(2) then
    local money = convert_money(nx_number(capital_num))
    local money_info = gui.TextManager:GetFormatText("ui_fuhuo_yb", money)
    dialog.mltbox_money_info:AddHtmlText(nx_widestr(money_info), -1)
  end
  if relive_type == RELIVE_TYPE_LOCAL or relive_type == RELIVE_TYPE_LOCAL_STRONG then
    local relive_count = player:QueryProp("ReliveCount")
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
      return false
    end
    local safe_mode = 0
    nx_execute("custom_sender", "custom_relive", relive_type, safe_mode)
    return true
  end
  return false
end
function show_relive_form()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if client_player:FindProp("InteractStatus") then
    local nSta = client_player:QueryProp("InteractStatus")
    if nSta == ITT_EGWAR or nSta == ITT_HUASHANSCHOOL_MEET or nSta == ITT_SAN_HILL then
      local hurt = nx_value("form_stage_main\\form_hurt_danger")
      if nx_is_valid(hurt) and hurt.Visible then
        hurt.Visible = false
      end
      return ""
    end
  end
  local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if flag_apex then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_hurt_danger", true, false)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_relive_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_hurt_danger", false, false)
  if nx_is_valid(form) then
    form:Close()
  end
  local gui = nx_value("gui")
  local childlist = gui.Desktop:GetChildControlList()
  for i = 1, table.getn(childlist) do
    local control = childlist[i]
    if nx_is_valid(control) and nx_script_name(control) == "form_stage_main\\form_public_msgbox" then
      control:Close()
    end
  end
end
function reset_control_pos(form)
  local cur_height = form.mltbox_info:GetContentHeight()
  if cur_height < 90 then
    cur_height = 90
  end
  form.mltbox_info.Height = cur_height + 20
  form.mltbox_info.ViewRect = "10,10,294," .. nx_string(cur_height + 20)
  form.Height = cur_height + 170
  form.lbl_bj.Height = form.Height - 70
end
