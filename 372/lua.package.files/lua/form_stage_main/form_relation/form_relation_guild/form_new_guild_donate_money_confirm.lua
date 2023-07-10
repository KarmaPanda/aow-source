require("custom_sender")
require("util_gui")
local money_ding_wen = 1000000
local money_siliver_wen = 1000
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  return true
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  return true
end
function on_donate(wen)
  local gui = nx_value("gui")
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_donate_money_confirm", true)
  if nx_is_valid(form) then
    form.wen = nx_int(wen)
    local money = nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int(wen)))
    form.lbl_quantity.Text = nx_widestr(money)
    form.Visible = true
    form:Show()
    return true
  end
  return false
end
function on_btn_confirm_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if nx_int(form.wen) > nx_int(0) then
  end
  form:Close()
  return true
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  form:Close()
  return true
end
