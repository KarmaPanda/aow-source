function init(form)
  form.Fixed = true
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function set_subtitle(subtitle)
  local form = nx_value("form_stage_main\\form_camera\\form_save_camera_playing_up")
  if nx_is_valid(form) then
    form.lbl_subtitle.Text = nx_widestr(subtitle)
    local width = form.lbl_subtitle.TextWidth
    form.lbl_subtitle.Left = (form.Width - width) / 2
  else
  end
end
