require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_small_game\\form_stage_main_1024"
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:ShowModal()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form.Visible = false
    form:Close()
  end
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
  local game1024 = nx_value("Game1024")
  if nx_is_valid(game1024) then
    game1024:UpdateGameData(self.imagegrid)
  end
end
function on_main_form_close(self)
  local game1024 = nx_value("Game1024")
  if nx_is_valid(game1024) then
    game1024:SetGameState(false)
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game1024 = nx_value("Game1024")
  if nx_is_valid(game1024) then
    game1024:SendError()
  end
  form.Visible = false
  form:Close()
end
function on_imagegrid_rightclick_grid(grid, index)
  local pic = grid:GetItemCoverImage(index)
end
function on_end_game(res)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form.Visible = false
    form:Close()
  end
end
