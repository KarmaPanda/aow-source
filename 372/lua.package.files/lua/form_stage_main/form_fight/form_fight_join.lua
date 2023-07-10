require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
local FORM_FIGHT_JOIN = "form_stage_main\\form_fight\\form_fight_join"
function main_form_init(form)
  form.Fixed = false
  form.target_scene_id = 0
  form.life_time = 30
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "update_time", form, -1, -1)
  end
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_time", form)
  end
  nx_destroy(form)
end
function on_main_form_shut(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) or form.target_scene_id == 0 then
    return
  end
  custom_arena_join(form.target_scene_id)
  form:Close()
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function open_form_by_custom(...)
  if #arg < 6 then
    return
  end
  local form = nx_value(FORM_FIGHT_JOIN)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_auto_show_hide_form", FORM_FIGHT_JOIN)
  form.target_scene_id = arg[1]
  form.lbl_player_1.Text = nx_widestr(arg[2])
  form.lbl_player_2.Text = nx_widestr(arg[3])
  form.lbl_referee.Text = nx_widestr(arg[4])
  form.lbl_wins.Text = nx_widestr(arg[5])
  form.lbl_scene_name.Text = nx_widestr(util_text("arena_scene_name_" .. nx_string(arg[6])))
  form.lbl_scene_image.BackImage = "gui\\special\\leitai\\fight_" .. nx_string(arg[6]) .. ".png"
end
function update_time(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.life_time) < nx_int(0) then
    form:Close()
  else
    form.life_time = form.life_time - 1
    local gui = nx_value("gui")
    form.lbl_life_time.Text = nx_widestr(gui.TextManager:GetFormatText("ui_arena_life_time", nx_int(form.life_time)))
  end
end
