require("form_stage_main\\form_tiguan\\form_tiguan_util")
local WIDTH_BASE = 0.5
local HEIGHT_BASE = 0.15
local WIDTH_DIST_IN = 0.2
local HEIGHT_DIST_IN = 0.05
local WIDTH_DIST_OUT = 0.3
local HEIGHT_DIST_OUT = 0.075
local MOVE_DOWN = 0.15
local MOVE_UP = 0.13
local IN_TIME = 200
local OUT_TIME = 400
local MOVE_TIME = 680
local PAUSE_TIME = 30
local CHANGE_TYPE_IN = 1
local CHANGE_TYPE_MOVE = 2
local CHANGE_TYPE_OUT = 3
function main_form_init(self)
  self.Fixed = true
  self.inout = 0
  self.times = 0
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function main_form_close(self)
  local timer = nx_value("timer_game")
  timer:UnRegister(FORM_TIGUAN_RESULT, "tiguan_result_show", self)
  nx_execute("util_gui", "util_show_form", FORM_TIGUAN_RESULT, false)
  nx_destroy(self)
end
function tiguan_result_show(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_find_custom(form, "inout") then
    return 0
  end
  if not nx_find_custom(form, "times") then
    return 0
  end
  form.times = nx_int(form.times) + 1
  if form.inout == CHANGE_TYPE_IN then
    local width_step = gui.Width * WIDTH_DIST_IN * PAUSE_TIME / IN_TIME
    local height_step = gui.Height * HEIGHT_DIST_IN * PAUSE_TIME / IN_TIME
    local alpha_step = 255 * PAUSE_TIME / IN_TIME
    if form.Width > gui.Width * WIDTH_BASE then
      form.Width = gui.Width * (WIDTH_BASE + WIDTH_DIST_IN) - width_step * form.times
      form.Height = gui.Height * (HEIGHT_BASE + HEIGHT_DIST_IN) - height_step * form.times
      form.lbl_result.Width = form.Width
      form.lbl_result.Height = form.Height
      form.BlendAlpha = alpha_step * form.times
      form.Left = (gui.Width - form.Width) / 2
      form.Top = gui.Height * MOVE_DOWN + height_step * form.times / 2
    else
      form.inout = CHANGE_TYPE_MOVE
      form.times = 0
    end
  elseif form.inout == CHANGE_TYPE_MOVE then
    local move_step = gui.Height * (MOVE_DOWN - MOVE_UP) * PAUSE_TIME / MOVE_TIME
    if form.Top > gui.Height * MOVE_UP then
      form.Top = gui.Height * MOVE_DOWN + gui.Height * HEIGHT_DIST_IN / 2 - move_step * form.times
    else
      form.inout = CHANGE_TYPE_OUT
      form.times = 0
    end
  elseif form.inout == CHANGE_TYPE_OUT then
    local width_step = gui.Width * WIDTH_DIST_OUT * PAUSE_TIME / OUT_TIME
    local height_step = gui.Height * HEIGHT_DIST_OUT * PAUSE_TIME / OUT_TIME
    local alpha_step = 255 * PAUSE_TIME / OUT_TIME
    if form.Width < gui.Width * (WIDTH_BASE + WIDTH_DIST_OUT) then
      form.Width = gui.Width * WIDTH_BASE + width_step * form.times
      form.Height = gui.Height * HEIGHT_BASE + height_step * form.times
      form.lbl_result.Width = form.Width
      form.lbl_result.Height = form.Height
      form.BlendAlpha = 255 - alpha_step * form.times
      form.Left = (gui.Width - form.Width) / 2
      form.Top = gui.Height * MOVE_UP - height_step * form.times / 2
    else
      local timer = nx_value("timer_game")
      timer:UnRegister(FORM_TIGUAN_RESULT, "tiguan_result_show", form)
      form:Close()
    end
  end
  return 1
end
function show_tiguan_result(result)
  local gui = nx_value("gui")
  local timer = nx_value("timer_game")
  local form = util_get_form(FORM_TIGUAN_RESULT, true)
  if not nx_is_valid(form) then
    return 0
  end
  if nx_number(result) ~= TG_RESULT_SUCCEED and nx_number(result) ~= TG_RESULT_FAILED and nx_number(result) ~= TG_RESULT_TIMEOUT then
    return 0
  end
  timer:UnRegister(FORM_TIGUAN_RESULT, "tiguan_result_show", form)
  form.Width = gui.Width * (WIDTH_BASE + WIDTH_DIST_IN)
  form.Height = gui.Height * (HEIGHT_BASE + HEIGHT_DIST_IN)
  form.lbl_result.Width = form.Width
  form.lbl_result.Height = form.Height
  form.BlendAlpha = 0
  form.Left = (gui.Width - form.Width) / 2
  form.Top = gui.Height * MOVE_DOWN
  form.lbl_result.BackImage = nx_string(RESULT_BACKIMAGE[nx_number(result) + 1])
  form.inout = CHANGE_TYPE_IN
  form.times = 0
  timer:Register(PAUSE_TIME, -1, FORM_TIGUAN_RESULT, "tiguan_result_show", form, -1, -1)
  nx_execute("util_gui", "util_show_form", FORM_TIGUAN_RESULT, true)
  play_sound(TIGUAN_SOUND[2])
end
