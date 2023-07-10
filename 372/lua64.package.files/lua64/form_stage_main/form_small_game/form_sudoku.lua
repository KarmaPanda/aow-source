require("util_functions")
local edit_lst = {}
local hint_edit_lst = {}
local sudoku_data_lst = {}
local used_pos_lst = {}
function main_form_init(form)
  local gui = nx_value("gui")
  form.Fixed = false
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  return 1
end
function init_game(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local init_left = form.lbl_grid.Left
  local init_top = form.lbl_grid.Top
  for i = 1, 9 do
    edit_lst[i] = {}
    local top = init_top + (i - 1) * 56 + math.floor((i - 1) / 3) * 6
    for j = 1, 9 do
      local left = init_left + (j - 1) * 56 + math.floor((j - 1) / 3) * 6
      local edit = gui:Create("Edit")
      edit.Left = left
      edit.Top = top
      edit.Width = 56
      edit.Height = 56
      edit.Font = "font_sns_xiayi_title1"
      edit.DrawMode = "Expand"
      edit.BackImage = "gui\\mainform\\smallgame\\sudoku\\1.png"
      edit.Align = "Center"
      edit.OnlyDigit = true
      edit.MaxDigit = 9
      edit.MaxLength = 1
      edit.ChangedEvent = true
      edit.Name = "edit" .. i .. j
      edit.row = i
      edit.col = j
      nx_bind_script(edit, nx_current(), "")
      nx_callback(edit, "on_changed", "on_edit_changed")
      nx_callback(edit, "on_right_click", "on_edit_right_click")
      form:Add(edit)
      edit_lst[i][j] = edit
    end
  end
end
function on_main_form_open(form)
  form.btn_reset.Enabled = false
  form.btn_change.Enabled = false
  form.lbl_tips.Visible = false
  form.Level = 1
  form.btn_change.Visible = false
  form.btn_reset.Visible = false
  form.btn_start.Visible = false
  init_game(form)
  on_btn_change_click(form.btn_change)
end
function on_main_form_close(form)
  if nx_running(nx_current(), "game_timer") then
    nx_kill(nx_current(), "game_timer")
  end
  nx_destroy(form)
end
function on_btn_start_click(btn)
end
function set_level(level)
  local form = nx_value("form_stage_main\\form_small_game\\form_sudoku")
  if not nx_is_valid(form) then
    return
  end
  if level < 0 then
    level = 0
  elseif 3 < level then
    level = 3
  end
  if level == 0 then
    form.rbtn_level1.Checked = true
  elseif level == 1 then
    form.rbtn_level2.Checked = true
  elseif level == 2 then
    form.rbtn_level3.Checked = true
  elseif level == 3 then
    form.rbtn_level4.Checked = true
  end
  form.Level = level + 1
end
function on_end_game(res)
  local form = nx_value("form_stage_main\\form_small_game\\form_sudoku")
  if not nx_is_valid(form) then
    return
  end
  if res == 1 then
    form.lbl_tips.Visible = true
    form.lbl_tips.Text = nx_widestr(util_text("ui_FinishSubjectOk"))
  elseif res == 2 then
    form.lbl_tips.Visible = true
    form.lbl_tips.Text = nx_widestr(util_text("ui_MakeSubjectFailed"))
  end
  form:Close()
end
function on_edit_changed(edit)
  if nx_string(edit.Text) == "" or nx_string(edit.Text) == "0" or nx_string(edit.Text) == "." then
    sudoku_data_lst[edit.row][edit.col] = 0
    edit.Text = nx_widestr("")
    return 0
  end
  local value = nx_number(edit.Text)
  if not check_same_value(value, edit.row, edit.col) then
    local value = sudoku_data_lst[edit.row][edit.col]
    if 0 < value then
      edit.Text = nx_widestr(nx_int(value))
    else
      edit.Text = nx_widestr("")
    end
    return 0
  end
  sudoku_data_lst[edit.row][edit.col] = value
  local form = edit.Parent
  local succeed = check_result()
  if succeed then
    form.btn_reset.Enabled = false
    form.succeed = true
    stop_timer(form)
    local sudokugame = nx_value("SudokuGame")
    sudokugame:SendResult()
  else
    form.btn_reset.Enabled = true
    begin_timer(form)
  end
end
function on_edit_right_click(edit)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  if nx_is_valid(form) then
    form:Close()
  end
  local sudokugame = nx_value("SudokuGame")
  sudokugame:SendError()
end
function on_btn_reset_click(btn)
  for i = 1, 9 do
    for j = 1, 9 do
      local pos = (i - 1) * 9 + j
      if used_pos_lst[pos] == nil then
        sudoku_data_lst[i][j] = 0
        edit_lst[i][j].Text = nx_widestr("")
      end
    end
  end
  local form = btn.Parent
  form.btn_reset.Enabled = false
end
function on_btn_change_click(btn)
  local form = btn.Parent
  local level = form.Level
  if level < 1 then
    level = 1
  elseif 4 < level then
    level = 4
  end
  for i = 1, 9 do
    sudoku_data_lst[i] = {}
    for j = 1, 9 do
      sudoku_data_lst[i][j] = 0
    end
  end
  for i = 1, 9 do
    sudoku_data_lst[1][i] = i
  end
  for i = 1, 9 do
    local random_num = math.random(1, 9)
    local temp = sudoku_data_lst[1][i]
    sudoku_data_lst[1][i] = sudoku_data_lst[1][random_num]
    sudoku_data_lst[1][random_num] = temp
  end
  init_sudoku_data(2, 1)
  local min = 24
  local max = 28
  if level == 1 then
    min = 48
    max = 52
  elseif level == 2 then
    min = 36
    max = 40
  elseif level == 3 then
    min = 30
    max = 32
  end
  used_pos_lst = {}
  local vis_count = math.random(min, max)
  local used_count = 0
  while vis_count > used_count do
    local pos = math.random(1, 81)
    if used_pos_lst[pos] == nil then
      used_pos_lst[pos] = 1
      used_count = used_count + 1
    end
  end
  for i = 1, 9 do
    for j = 1, 9 do
      local pos = (i - 1) * 9 + j
      local edit = edit_lst[i][j]
      if used_pos_lst[pos] == nil then
        sudoku_data_lst[i][j] = 0
      end
    end
  end
  for i = 1, 9 do
    for j = 1, 9 do
      local pos = (i - 1) * 9 + j
      local edit = edit_lst[i][j]
      if used_pos_lst[pos] == nil then
        edit.ReadOnly = false
        edit.ForeColor = "255,226,214,175"
        edit.SelectBackColor = "60,255,255,255"
        edit.SelectForeColor = "255,38,31,17"
        edit.Text = nx_widestr("")
      else
        edit.ReadOnly = true
        edit.ForeColor = "255,38,31,17"
        edit.SelectBackColor = "0,0,0,0"
        edit.SelectForeColor = "255,38,31,17"
        edit.Text = nx_widestr(nx_int(sudoku_data_lst[i][j]))
      end
    end
  end
  form.btn_reset.Enabled = false
  form.lbl_tips.Visible = false
  form.succeed = false
  clear_timer(form)
end
function begin_timer(form)
  if nx_running(nx_current(), "game_timer") then
    return
  end
  form.lbl_timer.Visible = true
  form.begin_time = os.time()
  nx_execute(nx_current(), "game_timer", form)
end
function clear_timer(form)
  if nx_running(nx_current(), "game_timer") then
    nx_kill(nx_current(), "game_timer")
  end
  form.lbl_timer.Text = nx_widestr("00:00:00")
end
function stop_timer(form)
  if nx_running(nx_current(), "game_timer") then
    nx_kill(nx_current(), "game_timer")
  end
end
function game_timer(form)
  while true do
    nx_pause(0)
    local last_time = os.time() - form.begin_time
    local sec = last_time % 60
    local min = math.floor(last_time / 60) % 60
    local hour = math.floor(last_time / 3600)
    local text = string.format("%02d:%02d:%02d", hour, min, sec)
    form.lbl_timer.Text = nx_widestr(text)
  end
end
function init_sudoku_data(i, j)
  if 9 < i or 9 < j then
    return true
  end
  for k = 1, 9 do
    local can = true
    for m = 1, i - 1 do
      if sudoku_data_lst[m][j] == k then
        can = false
        break
      end
    end
    if can then
      for n = 1, j - 1 do
        if sudoku_data_lst[i][n] == k then
          can = false
          break
        end
      end
    end
    if can then
      local up_i = math.floor(i / 3) * 3 + 3
      local up_j = math.floor(j / 3) * 3 + 3
      if i % 3 == 0 then
        up_i = i
      end
      if j % 3 == 0 then
        up_j = j
      end
      for p = up_i - 2, up_i do
        for q = up_j - 2, up_j do
          if sudoku_data_lst[p][q] == k then
            can = false
            break
          end
        end
        if not can then
          break
        end
      end
    end
    if can then
      sudoku_data_lst[i][j] = k
      if j < 9 then
        if init_sudoku_data(i, j + 1) then
          return true
        end
      elseif i < 9 then
        if init_sudoku_data(i + 1, 1) then
          return true
        end
      else
        return true
      end
      sudoku_data_lst[i][j] = 0
    end
  end
  return false
end
function check_same_value(value, row, col)
  for r = 1, 9 do
    if r ~= row then
      local other_value = sudoku_data_lst[r][col]
      if other_value == value then
        return false
      end
    end
  end
  for c = 1, 9 do
    if c ~= col then
      local other_value = sudoku_data_lst[row][c]
      if other_value == value then
        return false
      end
    end
  end
  local chunk_begin_row = math.floor((row - 1) / 3) * 3 + 1
  local chunk_begin_col = math.floor((col - 1) / 3) * 3 + 1
  for i = chunk_begin_row, chunk_begin_row + 2 do
    for j = chunk_begin_col, chunk_begin_col + 2 do
      if i ~= row and j ~= col then
        local other_value = sudoku_data_lst[i][j]
        if other_value == value then
          return false
        end
      end
    end
  end
  return true
end
function check_other_chunk(value, row, col)
  local chunk_row = math.floor((row - 1) / 3)
  local chunk_col = math.floor((col - 1) / 3)
  for i = 1, 3 do
    for j = 1, 3 do
      if i ~= row and j ~= col then
        local bfound = false
        for r = 1, 3 do
          for c = 1, 3 do
            local pos_i = (i - 1) * 3 + r
            local pos_j = (j - 1) * 3 + c
            local other_value = sudoku_data_lst[pos_i][pos_j]
            if other_value == value then
              bfound = true
            elseif other_value == 0 and not check_same_value(value, pos_i, pos_j) then
              bfound = true
            end
          end
        end
        if not bfound then
          return false
        end
      end
    end
  end
  return true
end
function check_result()
  for i = 1, 9 do
    for j = 1, 9 do
      local value = sudoku_data_lst[i][j]
      if value == 0 then
        return false
      end
    end
  end
  return true
end
