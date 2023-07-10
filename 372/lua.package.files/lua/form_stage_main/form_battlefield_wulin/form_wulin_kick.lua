require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
local FORM_KICK = "form_stage_main\\form_battlefield_wulin\\form_wulin_kick"
function open_kick_form(...)
  local form = get_form()
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_KICK, true)
  end
end
function close_form()
  local form = get_form()
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(self)
  self.lbl_2.Text = nx_widestr(nx_int(60))
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:Register(1000, -1, nx_current(), "update_left_time", self, -1, -1)
  end
  self.Fixed = false
end
function set_left_time(left_time)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  if nx_int(left_time) < nx_int(1) then
    left_time = nx_int(1)
  end
  form.lbl_2.Text = nx_widestr(nx_int(left_time))
end
function on_main_form_open(self)
  main_form_init(self)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", self)
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  on_btn_sure_click(btn)
end
function on_btn_sure_click(btn)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  custom_wudao(nx_int(102))
  form:Close()
end
function update_left_time(form)
  form.lbl_2.Text = nx_widestr(nx_int(form.lbl_2.Text) - nx_int(1))
  if nx_int(form.lbl_2.Text) <= nx_int(0) then
    local game_timer = nx_value("timer_game")
    if nx_is_valid(game_timer) then
      game_timer:UnRegister(nx_current(), "update_left_time", form)
    end
    form:Close()
  end
end
function get_form()
  local form = nx_value(FORM_KICK)
  return form
end
