require("util_functions")
require("util_static_data")
require("utils")
require("util_gui")
local FIGHT_STATE_IMAGE = {
  [0] = "gui\\language\\ChineseS\\fight\\out_fight.png",
  [1] = "gui\\language\\ChineseS\\fight\\in_fight.png"
}
local FORM_LIFE_TIME = 2
function main_form_init(self)
  self.Fixed = true
  self.form_life_time = FORM_LIFE_TIME
  self.state = 0
  return 1
end
function on_main_form_open(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", self)
    timer:Register(1000, -1, nx_current(), "on_timer", self, -1, -1)
  end
  self.lbl_backimage.BackImage = nx_string(self.back_image)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_timer(self)
  local form = self.ParentForm
  form.form_life_time = nx_number(form.form_life_time) - 1
  if form.form_life_time < 1 then
    form:Close()
    return
  end
end
function show_fight_state_form(...)
  local game_config_info = nx_value("game_config_info")
  local key = util_get_property_key(game_config_info, "fight_self_inout", 1)
  if nx_string(key) ~= nx_string("1") then
    return
  end
  local old_form = nx_value("form_stage_main\\form_main\\form_main_fight_state")
  show_new_fight_state_dlg(old_form, arg[1])
end
function show_new_fight_state_dlg(old_form, state)
  if nx_is_valid(old_form) then
    nx_destroy(old_form)
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_fight_state", true, false)
  if nx_is_valid(form) then
    form.back_image = FIGHT_STATE_IMAGE[state]
    form:Show()
    form.Visible = true
  end
end
