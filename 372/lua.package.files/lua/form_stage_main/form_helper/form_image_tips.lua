require("util_gui")
local FORM_NAME = "form_stage_main\\form_helper\\form_image_tips"
local image = {
  "answer_right",
  "answer_wrong"
}
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) * 3 / 4
  form.AbsTop = (gui.Height - form.Height) * 3 / 4
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", form)
  end
end
function on_timer(form)
  form:Close()
end
function open_form(index)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_image.BackImage = nx_string(image[index])
  form.Visible = true
  form:Show()
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", form)
    timer:Register(1000, -1, nx_current(), "on_timer", form, -1, -1)
  end
end
