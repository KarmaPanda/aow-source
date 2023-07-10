require("custom_sender")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local money_ding_wen = 1000000
local money_siliver_wen = 1000
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  gui.Focused = self.ipt_price_ding
  self.lbl_contribution.Text = nx_widestr("0")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  self.cur_capital = client_player:QueryProp("CapitalType2")
  local remain_money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int(self.cur_capital)))
  if nx_number(remain_money) < nx_number(0) then
    self.lbl_capital.Text = nx_widestr(0)
  else
    self.lbl_capital.Text = nx_widestr(remain_money)
  end
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
  return 1
end
function on_btn_confirm_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ding = nx_int(form.ipt_price_ding.Text)
  local liang = nx_int(form.ipt_price_liang.Text)
  local wen = nx_int(form.ipt_price_wen.Text)
  local capital = ding * money_ding_wen + liang * money_siliver_wen + wen
  if nx_int64(capital) <= nx_int64(0) then
    return
  end
  if 0 < string.len(capital) and nx_int(capital) > nx_int(0) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_donate_confirm", "on_donate", nx_int(capital))
  end
  form:Close()
  return 1
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function refresh_contribution(form, capital)
  if not nx_is_valid(form) then
    return
  end
  local num_contri = nx_int(capital * 1.5)
  form.lbl_contribution.Text = nx_widestr(num_contri)
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
  local left_capital = form.cur_capital - silver
  local gui = nx_value("gui")
  local remain_money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int(left_capital)))
  if nx_number(remain_money) < nx_number(0) then
    form.lbl_capital.Text = nx_widestr(0)
  else
    form.lbl_capital.Text = nx_widestr(remain_money)
  end
  refresh_contribution(form, silver)
end
