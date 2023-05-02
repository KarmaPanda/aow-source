require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
function on_main_form_init(self)
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Fixed = false
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  return 1
end
function on_main_form_close(form)
  nx_execute("tips_game", "hide_tip")
  nx_destroy(form)
end
function on_btn_give_flower_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_charge_shop\\form_interact_item", "show_interact_item", 1, form.ipt_name.Text)
  form:Close()
end
function on_btn_give_egg_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_charge_shop\\form_interact_item", "show_interact_item", 2, form.ipt_name.Text)
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function show_interact_appraise(name)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_charge_shop\\form_interact_appraise", true, false)
  if nx_is_valid(form) then
    form:Show()
    form.ipt_name.Text = nx_widestr(name)
  end
end
function on_btn_give_flower_get_capture(btn)
  local x = btn.AbsLeft + btn.Width
  local y = btn.AbsTop + btn.Height
  local tip_text = nx_widestr(util_text("ui_give_flower_info"))
  nx_execute("tips_game", "show_text_tip", tip_text, x, y)
end
function on_btn_give_flower_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_give_egg_get_capture(btn)
  local x = btn.AbsLeft + btn.Width
  local y = btn.AbsTop + btn.Height
  local tip_text = nx_widestr(util_text("ui_give_egg_info"))
  nx_execute("tips_game", "show_text_tip", tip_text, x, y)
end
function on_btn_give_egg_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
