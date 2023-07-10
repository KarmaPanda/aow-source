require("util_gui")
require("util_functions")
require("form_stage_main\\form_kof\\kof_util")
local FORM_NAME = "form_stage_main\\form_kof\\form_kof_fighter"
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = 0
  local form_buff = util_get_form("form_stage_main\\form_main\\form_main_buff", false)
  if nx_is_valid(form_buff) then
    form.AbsLeft = form_buff.AbsLeft - form.Width
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", form)
    game_timer:Register(1000, -1, nx_current(), "update_left_time", form, -1, -1)
  end
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", self)
    game_timer:UnRegister(nx_current(), "delay_ani", self)
  end
  nx_destroy(self)
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function open_form_and_hide()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = false
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function update_left_time(form)
  if not nx_is_valid(form) then
    return
  end
  if form.left_time > 0 then
    form.left_time = form.left_time - 1
  end
  if form.Visible == true and form.stage == KOF_ROUND_STAGE_READY and form.left_time == 4 then
    local game_timer = nx_value("timer_game")
    game_timer:Register(800, 1, nx_current(), "delay_ani", form, -1, -1)
  end
  form.lbl_left_time.Text = nx_widestr(form.left_time)
end
function delay_ani(form)
  nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "show_battle_begin_animation", "huashan_battle_begin")
end
function update_stage_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local stage = nx_number(arg[1])
  local left_time = nx_number(arg[2])
  form.lbl_stage.Text = nx_widestr(get_round_stage_text(stage))
  form.lbl_left_time.Text = nx_widestr(left_time)
  form.stage = stage
  form.left_time = left_time
end
