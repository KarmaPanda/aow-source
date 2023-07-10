require("util_gui")
require("game_object")
require("share\\client_custom_define")
local SUB_CUSTOMMSG_REQUEST_GUILD_CAPITAL = 68
local FORM_NAME = "form_stage_main\\form_guildbuilding\\form_guild_contribute_guild_money"
local money_ding_wen = 1000000
local money_siliver_wen = 1000
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  gui.Focused = self.ipt_price_ding
  self.guild_capital = 0
  custom_guild_capital()
  return 1
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    nx_destroy(self)
    nx_set_value(nx_string(FORM_NAME), nx_null())
  end
  return 1
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_gen_event(form, "contribute_return", "cancel")
  form:Close()
end
function on_btn_confirm_click(self)
  local gui = nx_value("gui")
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ding = nx_int(form.ipt_price_ding.Text)
  local liang = nx_int(form.ipt_price_liang.Text)
  local wen = nx_int(form.ipt_price_wen.Text)
  local silver = ding * money_ding_wen + liang * money_siliver_wen + wen
  local capital = nx_int64(silver)
  if nx_int64(capital) <= nx_int64(0) then
    return
  end
  if nx_int64(form.guild_capital) < nx_int64(capital) then
    local text = gui.TextManager:GetText("19560")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  if nx_int64(form.max_value) < nx_int64(capital) then
    local text = gui.TextManager:GetText("19240")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  nx_gen_event(form, "contribute_return", "ok", capital)
  form:Close()
end
function on_btn_max_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local show_value = form.guild_capital
  if nx_number(show_value) > nx_number(form.max_value) then
    show_value = form.max_value
  end
  local d = nx_int(show_value / money_ding_wen)
  local l = nx_int((show_value - d * money_ding_wen) / money_siliver_wen)
  local w = show_value - d * money_ding_wen - l * money_siliver_wen
  form.ipt_price_ding.Text = nx_widestr(d)
  form.ipt_price_liang.Text = nx_widestr(l)
  form.ipt_price_wen.Text = nx_widestr(w)
end
function custom_guild_capital()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_CAPITAL))
end
function on_rec_guild_capital(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local rec_guild_capital = arg[1]
  if nx_number(rec_guild_capital) < nx_number(0) then
    rec_guild_capital = 0
  end
  form.guild_capital = rec_guild_capital
  local gui = nx_value("gui")
  local remain_money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int(rec_guild_capital)))
  if nx_number(left_capital) < nx_number(0) then
    form.lbl_guild_capital.Text = nx_widestr(0)
  else
    form.lbl_guild_capital.Text = nx_widestr(remain_money)
  end
end
function on_ipt_changed(ipt)
  local form = ipt.ParentForm
  local ding = nx_int(form.ipt_price_ding.Text)
  local liang = nx_int(form.ipt_price_liang.Text)
  local wen = nx_int(form.ipt_price_wen.Text)
  local silver = 0
  if nx_int(ding) > nx_int(0) then
    silver = ding * nx_int(money_ding_wen)
  end
  if nx_int(liang) > nx_int(0) then
    silver = silver + nx_int(liang) * nx_int(money_siliver_wen)
  end
  if nx_int(wen) > nx_int(0) then
    silver = silver + nx_int(wen)
  end
  local left_capital = form.guild_capital - silver
  local gui = nx_value("gui")
  local remain_money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int(left_capital)))
  if nx_number(left_capital) < nx_number(0) then
    form.lbl_guild_capital.Text = nx_widestr(0)
  else
    form.lbl_guild_capital.Text = nx_widestr(remain_money)
  end
end
