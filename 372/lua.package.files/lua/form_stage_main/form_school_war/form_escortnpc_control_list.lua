require("util_functions")
require("util_gui")
require("define\\gamehand_type")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_stop_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_request_escort_control", form.obj, 2)
  form.Visible = false
  form:Close()
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_request_escort_control", form.obj, 1)
  form.Visible = false
  form:Close()
end
function on_btn_repair_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  text_button = nx_string(btn.Text)
  text_tinzhi = nx_string(util_text("ui_escort_caroperate_tingzhi"))
  if text_button == text_tinzhi then
    nx_execute("custom_sender", "custom_request_escort_control", form.obj, 0)
  else
    nx_execute("custom_sender", "custom_request_escort_control", form.obj, 4)
  end
  form.Visible = false
  form:Close()
end
function on_btn_steal_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_request_escort_control", form.obj, 3)
  form.Visible = false
  form:Close()
end
function show_form(obj, ntype)
  local form = util_get_form("form_stage_main\\form_school_war\\form_escortnpc_control_list", true)
  form.Visible = true
  form.obj = obj
  init_button(form, ntype)
  form:Show()
  return 1
end
function init_button(form, btntype)
  if btntype == 1 then
    form.btn_stop.Visible = true
    form.btn_steal.Visible = false
    form.btn_repair.Visible = false
    form.btn_start.Visible = true
    form.btn_stop.Text = nx_widestr(util_text("ui_escort_caroperate_follow"))
    form.btn_start.Text = nx_widestr(util_text("ui_escort_caroperate_qidong"))
    return
  end
  if btntype == 2 then
    form.btn_stop.Visible = false
    form.btn_steal.Visible = false
    form.btn_repair.Visible = true
    form.btn_start.Visible = false
    return
  end
  if btntype == 3 then
    form.btn_stop.Visible = false
    form.btn_steal.Visible = true
    form.btn_repair.Visible = false
    form.btn_start.Visible = false
    form.btn_steal.Text = nx_widestr(util_text("ui_escort_caroperate_jiebiao"))
    return
  end
  if btntype == 4 then
    form.btn_stop.Visible = false
    form.btn_steal.Visible = false
    form.btn_repair.Visible = true
    form.btn_start.Visible = false
    form.btn_repair.Text = nx_widestr(util_text("ui_escort_caroperate_tingzhi"))
    return
  end
end
