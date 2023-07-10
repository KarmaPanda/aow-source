require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_small_game\\form_game_tg_roll_chip"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
  self.chip_index = 0
  self.rbtn_chip_1.Checked = true
end
function on_main_form_close(self)
  nx_destroy(self)
end
function open_form(diff, sys_chip)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_chip_checked_changed(rbtn)
  if rbtn.Checked then
    rbtn.ParentForm.chip_index = nx_int(rbtn.DataSource)
  end
end
function on_btn_chip_ok_click(btn)
  nx_execute("form_stage_main\\form_small_game\\form_game_tg_roll", "on_chip_ok", nx_int(btn.ParentForm.chip_index))
  close_form()
end
