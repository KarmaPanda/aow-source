require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
local FORM_KICK = "form_stage_main\\form_battlefield\\form_battlefield_kick"
function open_kick_form(...)
  local form = nx_value(FORM_KICK)
  if not nx_is_valid(form) then
    form = util_auto_show_hide_form(FORM_KICK)
  else
    form:Close()
    return
  end
  form.lbl_2.Text = nx_widestr(nx_int(60))
end
function close_form()
  local form = nx_value(FORM_ROOM)
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(self)
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:Register(1000, -1, nx_current(), "update_left_time", self, -1, -1)
  end
  self.Fixed = false
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
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(64))
  form:Close()
end
function on_btn_sure_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(64))
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
