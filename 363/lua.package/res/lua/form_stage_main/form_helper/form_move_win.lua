require("util_gui")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function util_open_move_win(x, y, w, h, image, typename_list)
  if nil == typename_list or "" == typename_list then
    return false
  end
  local str_lst = util_split_string(typename_list, ",")
  for i, typename in ipairs(str_lst) do
    local res, t_x, t_y, t_w, t_h = find_func_btn_pos("func", typename)
    if true == res then
      set_win_info(x, y, w, h, image, t_x + t_w / 2, t_y + t_h / 2)
      return true
    end
  end
  local t_x, t_y, t_w, t_h = get_btn_func()
  set_win_info(x, y, w, h, image, t_x + t_w / 2, t_y + t_h / 2)
  return true
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function set_win_info(x, y, w, h, image, t_x, t_y)
  local form = util_get_form(nx_current(), true, false)
  if not nx_is_valid(form) then
    return false
  end
  if nil == image then
    image = ""
  end
  if "" ~= image then
    form.BackImage = image
  end
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("move_form", form)
  asynor:AddExecute("move_form", form, nx_float(0), nx_float(t_x), nx_float(t_y), nx_float(0.7), "")
  form.Visible = false
  form:Show()
  form.Top = y
  form.Left = x
  form.Width = w
  form.Height = h
  form.Visible = true
end
function find_func_btn_pos(typeid, typename)
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_left")
  if not nx_is_valid(form) then
    return false, 0, 0, 0, 0
  end
  local grid = form.grid_shortcut_main
  local index_table = find_grid_index(grid, typeid, typename)
  if table.getn(index_table) == 0 then
    return false, 0, 0, 0, 0
  end
  local x = grid:GetItemLeft(index_table[1])
  local y = grid:GetItemTop(index_table[1])
  return true, grid.AbsLeft + x, grid.AbsTop + y, grid.GridWidth, grid.GridHeight
end
function find_grid_index(grid, typeid, typename)
  local beginindex = grid.beginindex + grid.page * (grid.RowNum * grid.ClomnNum)
  local index_table = {}
  for count = 0, 11 do
    local row = nx_execute("shortcut_game", "get_shortcut_row_by_index", count + beginindex)
    if 0 <= row then
      local index, para1, para2 = nx_execute("shortcut_game", "get_shortcut_info_by_row", row)
      if nx_string(para2) == nx_string(typename) then
        table.insert(index_table, count)
      end
    end
  end
  return index_table
end
function get_btn_func()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_right")
  if not nx_is_valid(form) then
    local gui = nx_value("gui")
    return gui.Width, gui.Height, 0, 0
  end
  return form.btn_func2.AbsLeft, form.btn_func2.AbsTop, form.btn_func2.Width, form.btn_func2.Height
end
