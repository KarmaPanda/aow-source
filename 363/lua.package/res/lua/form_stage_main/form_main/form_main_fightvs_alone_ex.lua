require("form_stage_main\\form_main\\form_main_fightvs_util")
function main_form_init(form)
  form.Fixed = true
  form.fCountTime = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = gui.Desktop.Height - form.Height - 120
  gui.Desktop:ToBack(form)
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_effect")
  if bMovie then
    form.Visible = false
    nx_execute("form_stage_main\\form_movie_effect", "add_hide_control", form)
  else
    form.Visible = true
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function change_form_size()
  local form = util_get_form(FORM_FIGHT_VS_ALONE_EX, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = gui.Desktop.Height - form.Height - 120
end
function star_fight_progress(ticks)
  local photo = nx_execute("form_stage_main\\form_main\\form_main_fightvs_alone", "get_skill_photo")
  if nx_string(photo) == "" then
    return 0
  end
  local form = util_get_form(FORM_FIGHT_VS_ALONE_EX, true, false)
  if not nx_is_valid(form) then
    return 0
  end
  form.lbl_photo.BackImage = nx_string(photo)
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    form.is_end = false
    form.lbl_photo.Width = 36
    form.lbl_photo.Height = 36
    form.lbl_photo.Left = 0
    form.lbl_photo.Top = -24
    form.BlendAlpha = 255
    form.fCountTime = 0
    form.slow_width = (form.groupbox_1.Width - 36) * 0.5
    form.total_time = 30
    common_execute:RemoveExecute("FightVsProgressBar", form)
    common_execute:AddExecute("FightVsProgressBar", form, 0.05)
  end
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_effect")
  if bMovie then
    form.Visible = false
    nx_execute("form_stage_main\\form_movie_effect", "add_hide_control", form)
  else
    util_show_form(FORM_FIGHT_VS_ALONE_EX, true)
    form.Visible = true
  end
end
function stop_fight_progress(msg)
  local form = util_get_form(FORM_FIGHT_VS_ALONE_EX, false)
  if nx_is_valid(form) then
    form.total_time = form.fCountTime + 1
    form.slow_width = form.lbl_photo.Left
  end
end
