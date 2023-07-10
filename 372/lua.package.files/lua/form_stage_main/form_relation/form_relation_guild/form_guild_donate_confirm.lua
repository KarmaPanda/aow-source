require("custom_sender")
require("util_gui")
local money_ding_wen = 1000000
local money_siliver_wen = 1000
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(self)
  return 1
end
function on_donate(wen)
  local gui = nx_value("gui")
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_donate_confirm", true)
  if nx_is_valid(form) then
    form.wen = nx_int(wen)
    local money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int(wen)))
    form.lbl_quantity.Text = nx_widestr(money)
    form.Visible = true
    form:Show()
  end
end
function on_btn_confirm_click(btn)
  local form = btn.ParentForm
  if nx_int(form.wen) > nx_int(0) then
    custom_request_guild_donate(nx_int(form.wen))
  end
  form:Close()
  return 1
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
