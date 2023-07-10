require("util_gui")
require("util_functions")
local food = {
  [1] = {
    0,
    0,
    "wgm_age_01"
  },
  [2] = {
    6000,
    7,
    "wgm_age_02"
  },
  [3] = {
    15000,
    15,
    "wgm_age_03"
  },
  [4] = {
    25000,
    25,
    "wgm_age_04"
  }
}
function main_form_init(self)
  self.Fixed = false
  self.Visible = true
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 3
  self.type = 0
  self.seq = 0
  return 1
end
function on_main_form_open(self)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(919), nx_int(0))
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  nx_destroy(self)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function refresh_info(...)
  form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_school_war\\form_new_school_msg_info")
  if not nx_is_valid(form) then
    return
  end
  local sat = arg[1]
  local age = arg[2]
  form.lbl_day.Text = nx_widestr(nx_int(age))
  form.lbl_food.Text = nx_widestr(nx_int(sat))
  local gui = nx_value("gui")
  if nx_is_valid(gui) == false then
    return
  end
  for i = 2, 4 do
    if nx_int(sat) < nx_int(food[i][1]) or nx_int(age) < nx_int(food[i][2]) then
      form.lbl_stage.Text = nx_widestr(gui.TextManager:GetText(food[i - 1][3]))
      return
    end
  end
  form.lbl_stage.Text = nx_widestr(gui.TextManager:GetText(food[4][3]))
end
