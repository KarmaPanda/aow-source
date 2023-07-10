require("custom_sender")
require("util_gui")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_ok_click(btn)
  nx_execute("custom_sender", "custom_form_ttf_template", 3)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function show_cur_layer_info(current_layer_num, total_tips)
  local form = util_get_form("form_stage_main\\form_skyhill\\form_ttf_dialog", true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_layer_num.Text = nx_widestr(current_layer_num)
  form.lbl_tips_num.Text = nx_widestr(total_tips)
end
