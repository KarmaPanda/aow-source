require("share\\client_custom_define")
require("util_gui")
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  form.lbl_back.BlendColor = "100,255,255,255"
  nx_execute(nx_current(), "down_black_movie", form)
  change_form_size()
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_cancel_click(btn)
  nx_execute("custom_sender", "custom_avenge", nx_int(6))
  local form = btn.ParentForm
  form:Close()
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_relation\\form_avenge_watch")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.lbl_back.Width = form.Width
  form.lbl_back.Height = form.Height
  form.mltbox_up.Width = form.Width
  form.mltbox_down.Width = form.Width
end
function down_black_movie(form)
  if not nx_is_valid(form) then
    return
  end
  set_control_before_black(form)
  form.btn_cancel.Visible = false
  while true do
    local sec = nx_pause(0.01)
    if not nx_is_valid(form) then
      return
    end
    form.mltbox_up.Top = nx_int(form.mltbox_up.Top + sec * 100)
    form.mltbox_down.Top = nx_int(form.mltbox_down.Top - sec * 100)
    if form.mltbox_up.Top >= 0 or form.mltbox_down.Top <= -form.mltbox_down.Height then
      form.mltbox_up.Top = 0
      form.mltbox_down.Top = -form.mltbox_down.Height
      break
    end
  end
  form.btn_cancel.Visible = true
end
function set_control_before_black(form)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_up.VAnchor = "Top"
  form.mltbox_down.VAnchor = "Bottom"
  form.mltbox_up.Top = -form.mltbox_up.Height
  form.mltbox_down.Top = 0
end
