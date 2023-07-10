require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
local rect_x = 0
local rect_y = 0
local rect_width = 0
local rect_height = 0
local rect_right = 0
local rect_bottom = 0
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.btn_rect.Left = 0
  form.btn_rect.Top = 0
  form.btn_rect.Width = gui.Width
  form.btn_rect.Height = gui.Height
  rect_width = gui.Width
  rect_height = gui.Height
  form.Default = form.btn_close
  gui.Focused = form.btn_close
  form.rect.Visible = false
  form.btn_close = false
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_form_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  local form_movie = nx_value("form_stage_main\\form_camera\\form_movie_save")
  if not nx_is_valid(form_movie) then
    return
  end
  form_movie.begin_x.Text = nx_widestr(rect_x)
  form_movie.begin_y.Text = nx_widestr(rect_y)
  form_movie.end_x.Text = nx_widestr(rect_right)
  form_movie.end_y.Text = nx_widestr(rect_bottom)
  form_movie.w.Text = nx_widestr(rect_width)
  form_movie.h.Text = nx_widestr(rect_height)
  form.Visible = false
  form:Close()
end
function on_screen_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  form.Default = form.btn_close
  gui.Focused = form.btn_close
  return 1
end
function cancel_btn_click(self)
  local form = self.ParentForm
  return 1
end
function on_screen_push(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  form.pos.Text = nx_widestr("11x = " .. x .. "  " .. "y = " .. y)
  rect_x = x - form.Left
  rect_y = y - form.Top
  form.rect.Left = rect_x
  form.rect.Top = rect_y
  form.rect.Width = 1
  form.rect.Height = 1
  form.rect.Visible = true
  return 1
end
function on_screen_drag_move(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  form.pos.Text = nx_widestr("x = " .. x .. "  " .. "y = " .. y)
  rect_width = math.abs(x - rect_x - form.Left)
  rect_height = math.abs(y - rect_y - form.Top)
  rect_right = x
  rect_bottom = y
  form.rect.Width = rect_width
  form.rect.Height = rect_height
end
