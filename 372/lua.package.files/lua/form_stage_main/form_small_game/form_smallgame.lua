require("util_gui")
function form_init(self)
  self.Fixed = false
  return 1
end
function on_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
end
function on_form_close(self)
  nx_destroy(self)
end
function on_click_btn_close(btn)
  local form = btn.Parent
  form:Close()
  local gui = nx_value("gui")
  gui:Delete(form)
end
function on_btn_sudoku_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_small_game\\form_sudoku")
  on_click_btn_close(btn)
end
function on_btn_findpic_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_small_game\\form_find_pic")
  on_click_btn_close(btn)
end
function on_btn_24_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_small_game\\form_memory_train")
  on_click_btn_close(btn)
end
function on_btn_guess_cup_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_small_game\\form_game_guesscup")
  on_click_btn_close(btn)
end
