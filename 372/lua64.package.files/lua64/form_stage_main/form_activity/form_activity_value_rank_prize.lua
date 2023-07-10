require("util_functions")
require("util_gui")
function get_text(msg)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText(msg)
  return text
end
function get_format_text(msg, value)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(msg, value)
  return text
end
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_get_activity_value_rank_prize_rec")
  form.textgrid_prize_list:SetColTitle(0, get_text("ui_activity_rank_prize_num"))
  form.textgrid_prize_list:SetColTitle(1, get_text("ui_activity_rank_prize_player"))
  form.textgrid_prize_list:SetColTitle(2, get_text("ui_activity_rank_prize_item"))
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_show_desc_click(btn)
  local form = btn.ParentForm
  form.groupbox_list.Visible = false
  form.groupbox_introduce.Visible = true
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  form.groupbox_list.Visible = true
  form.groupbox_introduce.Visible = false
end
function on_server_msg(rows, ...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_prize_list:ClearRow()
  form.textgrid_prize_list.RowCount = rows
  local index = 1
  local str_capital = ""
  local ding = 0
  local liang = 0
  for i = 0, rows - 1 do
    str_capital = ""
    ding = nx_int(arg[index + 2] / 1000000)
    liang = nx_int(arg[index + 2] % 1000000 / 1000)
    wen = nx_int(arg[index + 2] % 1000000 % 1000)
    if ding > nx_int(0) then
      str_capital = nx_string(get_format_text("ui_capital_ding", nx_int(ding)))
    end
    if liang > nx_int(0) then
      str_capital = str_capital .. nx_string(get_format_text("ui_capital_liang", nx_int(liang)))
    end
    if wen > nx_int(0) then
      str_capital = str_capital .. nx_string(get_format_text("ui_capital_wen", nx_int(wen)))
    end
    form.textgrid_prize_list:SetGridText(i, 0, nx_widestr(nx_int(arg[index]) + 1))
    form.textgrid_prize_list:SetGridText(i, 1, nx_widestr(arg[index + 1]))
    form.textgrid_prize_list:SetGridText(i, 2, nx_widestr(str_capital))
    index = index + 3
  end
end
function on_textgrid_prize_list_right_select_grid(self, row, col)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  local name = self:GetGridText(row, 1)
  if name == nil or nx_string(name) == "" then
    return
  end
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "activity_prize_rank", "activity_prize_rank")
  nx_execute("menu_game", "menu_recompose", menu_game, name)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
