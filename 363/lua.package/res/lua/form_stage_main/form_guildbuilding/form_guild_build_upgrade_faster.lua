require("util_gui")
require("game_object")
require("form_stage_main\\form_guildbuilding\\guildbuilding_getinfo")
function log(info)
  local form_main_chat_logic = nx_value("form_main_chat")
  if nx_is_valid(form_main_chat_logic) then
    form_main_chat_logic:AddChatInfoEx(nx_widestr(info), 11, false)
  end
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  gui.Focused = self.ipt_capital
  self.lbl_contribution.Text = nx_widestr("")
  return 1
end
function on_main_form_close(self)
  return 1
end
function on_btn_cancel_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  nx_gen_event(form, "form_guild_build_upgrade_faster", "cancel")
  nx_destroy(form)
end
function on_btn_confirm_click(self)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_upgrade_faster")
  if not nx_is_valid(form) then
    return
  end
  local capital = nx_int(form.ipt_capital.Text)
  form:Close()
  nx_gen_event(form, "form_guild_build_upgrade_faster", "ok", capital)
  nx_destroy(form)
end
function on_ipt_capital_changed(self)
  if nx_string(self.Text) == "-" then
    self.Text = nx_widestr("")
    return
  end
  local value = nx_string(self.Text)
  value = nx_number(value)
  if value < 0 then
    self.Text = nx_widestr("")
    return
  end
  refresh_contribution(self.Parent, value)
end
function refresh_contribution(form, capital)
  if not nx_is_valid(form) then
    return
  end
  if capital < 0 then
    form.lbl_contribution.Text = nx_widestr("")
    return
  end
  local contribution = transform_time(math.floor(nx_number(capital)) * 1000 * 100)
  form.lbl_contribution.Text = nx_widestr(contribution)
end
