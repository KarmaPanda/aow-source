require("util_functions")
require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_universal_school_fight\\form_universal_school_fight_progress"
function main_form_init(self)
  self.Fixed = false
  self.refresh_time = -1
  self.refresh_reward = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 20
  self.pbar_boss_pos.ProgressMode = "LeftToRight"
  self.pbar_boss_pos.Value = 30
end
function on_main_form_close(self)
  nx_destroy(self)
end
function open_form()
  util_auto_show_hide_form(FORM_NAME)
end
function close_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Close()
  end
end
function Update_Boss_Pos(boss_pos)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.pbar_boss_pos.Value = boss_pos
end
function Update_Show_Player_num(defend_num, attack_num)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_1.Text = nx_widestr(defend_num)
  form.lbl_3.Text = nx_widestr(attack_num)
end
