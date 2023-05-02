require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_tongguanjiangli_five"
local FORM_NAME_BELOW = "form_stage_main\\form_match\\form_match_below"
function open_form(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  change_form_size_change()
  form.star = arg[1]
  form.index = 1
  star_count()
  local delay = arg[4]
  form.total_time = arg[2]
  level_time()
  form.total_score = arg[3]
  level_score()
  form.Visible = true
  form:Show()
end
function close_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
  end
end
function change_form_size_change()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Width = gui.Width
    form.Height = gui.Height
    form.groupbox_1.Width = gui.Width
    form.groupbox_1.Height = gui.Height
    form.Left = 0
    form.Top = 0
  end
  if not nx_is_valid(form) then
    return
  end
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Width = gui.Width
    form.Height = gui.Height
    form.groupbox_1.Width = gui.Width
    form.groupbox_1.Height = gui.Height
    form.Left = 0
    form.Top = 0
    form.lbl_score_1.Visible = false
    form.lbl_score_2.Visible = false
    form.lbl_score_3.Visible = false
    form.lbl_score_4.Visible = false
  else
    return
  end
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_count_down", form)
  end
  nx_destroy(form)
end
function on_btn_next_click()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  cunstom_skyhill_next(1)
end
function star_count()
  local form = nx_value(FORM_NAME)
  local star = form.star
  local idx = form.index
  if star < idx then
    return
  end
  local ani_get = "ani_" .. nx_string(idx)
  local ani_gain = form.groupbox_1:Find(ani_get)
  if nx_is_valid(ani_gain) then
    ani_gain.AnimationImage = "clone_1"
    ani_gain.Loop = false
    ani_gain.PlayMode = 2
    ani_gain.independent = true
    ani_gain.Visible = true
    ani_gain:Play()
    nx_callback(ani_gain, "on_animation_end", "star_steady")
  end
end
function star_steady(ani_gain)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  ani_gain.Visible = false
  local idx = nx_int(form.index)
  local star = nx_int(form.star)
  if idx > star then
    return
  end
  local lbl_get = "lbl_2" .. nx_string(idx)
  local lbl_gain = form.groupbox_1:Find(lbl_get)
  if nx_is_valid(lbl_gain) then
    lbl_gain.BackImage = "gui\\clone_new\\form_clone_award\\dao7.png"
    lbl_gain.Visible = true
  end
  form.index = form.index + 1
  star_count()
end
function level_time()
  local form = util_get_form(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(timer) then
    return
  end
  form.time_total = nx_int(0)
  timer:Register(36, 50, nx_current(), "level_time_count", form, -1, -1)
end
function level_time_count(form)
  local add_time = math.ceil(form.total_time / 50)
  if add_time < 0 then
    add_time = 0
  end
  if nx_int(nx_int(form.time_total) + nx_int(add_time)) < nx_int(form.total_time) then
    form.time_total = nx_widestr(nx_int(form.time_total) + nx_int(add_time))
    local total = nx_int(form.time_total)
    time_label(total)
  else
    form.time_total = nx_widestr(nx_int(form.total_time))
    local total = nx_int(form.time_total)
    time_label(total)
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "level_time_count", form)
  end
end
function time_label(total)
  local form = util_get_form(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.minute = total / 60
  form.time_1 = nx_int(form.minute) / 10
  form.time_2 = math.fmod(nx_number(form.minute), 10)
  form.second = nx_number(total) % 60
  form.time_3 = nx_int(form.second) / 10
  form.time_4 = math.fmod(nx_number(form.second), 10)
  local time_value = 0
  for i = 1, 4 do
    if i == 1 then
      time_value = nx_int(form.time_1)
    elseif i == 2 then
      time_value = nx_int(form.time_2)
    elseif i == 3 then
      time_value = nx_int(form.time_3)
    elseif i == 4 then
      time_value = nx_int(form.time_4)
    end
    time_get = "lbl_time_" .. nx_string(i)
    local time_gain = form.groupbox_1:Find(time_get)
    if not nx_is_valid(time_gain) then
      return
    end
    for j = 0, 9 do
      if time_value == nx_int(j) then
        time_gain.BackImage = "gui\\clone_new\\form_clone_award\\" .. nx_string(nx_int(j)) .. ".png"
      end
    end
  end
end
function level_score()
  local form = util_get_form(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(timer) then
    return
  end
  form.score_total = nx_int(0)
  timer:Register(36, 50, nx_current(), "level_score_count", form, -1, -1)
end
function level_score_count(form)
  local add_score = math.ceil(form.total_score / 50)
  if add_score < 0 then
    add_score = 0
  end
  if nx_int(nx_int(form.score_total) + nx_int(add_score)) < nx_int(form.total_score) then
    form.score_total = nx_widestr(nx_int(form.score_total) + nx_int(add_score))
    local total = nx_int(form.score_total)
    score_label(total)
  else
    form.score_total = nx_widestr(nx_int(form.total_score))
    local total = nx_int(form.score_total)
    score_label(total)
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "level_score_count", form)
  end
end
function score_label(total)
  local form = util_get_form(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local place_value = 0
  local total_score = total
  for index = 1, 4 do
    place_value = nx_number(total_score) % 10
    total_score = (total_score - place_value) / 10
    score_get = "lbl_score_" .. nx_string(nx_int(index))
    local score_gain = form.groupbox_1:Find(score_get)
    if not nx_is_valid(score_gain) then
      return
    end
    for j = 0, 9 do
      if nx_int(place_value) == nx_int(j) then
        score_gain.BackImage = "gui\\clone_new\\form_clone_award\\" .. nx_string(nx_int(j)) .. ".png"
        if nx_int(j) ~= nx_int(0) then
          score_gain.Visible = true
        end
      end
    end
  end
end
