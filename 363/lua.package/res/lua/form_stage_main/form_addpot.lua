require("util_gui")
local DSD_ASK_ACPICTY = 4
local DSD_BUY_ACPICTY = 5
local DSD_BUY_ACPICTY_ITEM = 6
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  local form_subpot = nx_value("form_stage_main\\form_addsubpot")
  if nx_is_valid(form_subpot) then
    form_subpot:Close()
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_letsgo_click(btn)
  util_show_form("form_stage_main\\form_vip_info", true)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_unlock_click(btn)
  local form = btn.ParentForm
  local form_subpot = nx_value("form_stage_main\\form_addsubpot")
  if nx_is_valid(form_subpot) then
    form_subpot:Close()
  end
  form_subpot = util_show_form("form_stage_main\\form_addsubpot", true)
end
