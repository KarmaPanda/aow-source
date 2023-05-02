require("const_define")
function init_form_movie_notice(self)
  self.Fixed = true
end
function set_form_pos(form)
  local gui = nx_value("gui")
  if nx_is_valid(form) then
    form.AbsLeft = gui.Width * 0.6
    form.AbsTop = gui.Height * 0.4
  end
end
function on_main_form_open(form)
  set_form_pos(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_size_change()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_movie_notice", false)
  if nx_is_valid(form) then
    set_form_pos(form)
  end
end
function on_btn_play_click(btn)
  local form = btn.ParentForm
  if nx_running(nx_current(), "begin_count") then
    nx_kill(nx_current(), "begin_count")
  end
  nx_execute("custom_sender", "custom_agree_movie")
  form:Close()
end
function on_custom_movie_request(npc_id, movie_id)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_movie_notice", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  if nx_running(nx_current(), "begin_count") then
    nx_kill(nx_current(), "begin_count")
  end
  nx_execute(nx_current(), "begin_count", form)
end
function begin_count(form)
  if not nx_is_valid(form) then
    return
  end
  local left_time = 6
  form.lbl_count.Text = nx_widestr(nx_int(left_time))
  while true do
    local sep = nx_pause(1)
    if not nx_is_valid(form) then
      return
    end
    left_time = left_time - sep
    if left_time < 0 then
      form:Close()
      return
    else
      form.lbl_count.Text = nx_widestr(math.floor(left_time))
    end
  end
end
