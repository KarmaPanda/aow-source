require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\client_custom_define")
local IN_COLOR = "255,255,0,0"
local OUT_COLOR = "255,0,255,0"
local SELECT_COLOR = "255,0,0,255"
local COLOR_RED = "255, 255, 0, 0"
local COLOR_DARKGREEN = "255, 0, 150, 0"
local GRID_COLOR = "255,255,0,0"
local MAX_ROW = 60
local MAX_COL = 70
local TOPDEFLECT = 20
local LEFTDEFLECT = 20
local x_point_tbl = {}
local y_point_tbl = {}
local move_tbl = {}
local all_move_tbl = {}
function main_form_init(form)
  form.Fixed = false
  form.cell_width = 0
  form.cell_height = 0
  form.o_x = 0
  form.o_y = 0
  form.target = nx_widestr("")
end
function on_main_form_open(form)
  form.Fixed = false
  init_drawline(form)
  form.DrawLines1:Clear()
  form.DrawLines2:Clear()
  move_tbl = {}
  all_move_tbl = {}
end
function on_main_form_close(form)
  move_tbl = {}
  all_move_tbl = {}
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  move_tbl = {}
  all_move_tbl = {}
  local form = btn.ParentForm
  form:Close()
end
function init_drawline(form)
  if not nx_is_valid(form) then
    return
  end
  local GridDrawLines = form.GridDrawLines
  if nx_is_valid(GridDrawLines) then
    GridDrawLines.LineWidth = 10
  end
  local W = tonumber(GridDrawLines.Width - 10)
  local H = tonumber(GridDrawLines.Height - 10)
  local rows = tonumber(MAX_ROW)
  local cols = tonumber(MAX_COL)
  form.cell_width = nx_int(W / cols)
  form.cell_height = nx_int(H / rows)
  x_point_tbl = {}
  y_point_tbl = {}
  GridDrawLines:Clear()
  local xy = ""
  local cur_row = rows + 1
  local row_end_x_1 = 0
  local row_end_y_1 = 0
  local row_end_x_2 = 0
  local row_end_y_2 = 0
  form.o_x = 20
  form.o_y = rows * (H / rows) + TOPDEFLECT
  for i = 1, rows do
    cur_row = cur_row - 1
    local start_x = LEFTDEFLECT
    local start_y = (cur_row - 1) * (H / rows) + TOPDEFLECT
    local end_x = W + LEFTDEFLECT
    local end_y = (cur_row - 1) * (H / rows) + TOPDEFLECT
    local index = GridDrawLines:AddLine(start_x, start_y, end_x, end_y)
    GridDrawLines:SetLineColor(index, SELECT_COLOR)
    table.insert(y_point_tbl, start_y)
    if cur_row == rows then
      row_end_x_1 = end_x
      row_end_y_1 = end_y
    end
    if cur_row == 1 then
      row_end_x_2 = end_x
      row_end_y_2 = end_y
    end
  end
  local index = GridDrawLines:AddLine(row_end_x_1, row_end_y_1, row_end_x_2, row_end_y_2)
  GridDrawLines:SetLineColor(index, SELECT_COLOR)
  local col_end_x_1 = 0
  local col_end_y_1 = 0
  local col_end_x_2 = 0
  local col_end_y_2 = 0
  for i = 1, cols do
    local start_x = (i - 1) * (W / cols) + LEFTDEFLECT
    local start_y = TOPDEFLECT
    local end_x = (i - 1) * (W / cols) + LEFTDEFLECT
    local end_y = H + TOPDEFLECT
    local index = GridDrawLines:AddLine(start_x, start_y, end_x, end_y)
    GridDrawLines:SetLineColor(index, SELECT_COLOR)
    if i == 1 then
      col_end_x_1 = end_x
      col_end_y_1 = end_y
    end
    if i == cols then
      col_end_x_2 = end_x
      col_end_y_2 = end_y
    end
  end
  local index = GridDrawLines:AddLine(col_end_x_1, col_end_y_1, col_end_x_2, col_end_y_2)
  GridDrawLines:SetLineColor(index, SELECT_COLOR)
end
function on_recv_data(...)
  local form = nx_value("form_test\\form_skill_check")
  if not nx_is_valid(form) then
    return
  end
  local dif = arg[1]
  local total = arg[2]
  local sum_time = arg[3]
  local check_total = arg[4]
  local check_sum_time = arg[5]
  local player = arg[6]
  local scene = arg[7]
  local x = arg[8]
  local z = arg[9]
  form.target = player
  form.lbl_player.Text = nx_widestr(player)
  form.lbl_scene.Text = nx_widestr(util_text(get_scene_id_by_name(scene)))
  form.lbl_pos.Text = nx_widestr(nx_int(x)) .. nx_widestr(":") .. nx_widestr(nx_int(z))
  form.fipt_total.Text = nx_widestr(total)
  form.fipt_time.Text = nx_widestr(sum_time)
  if 0 < total then
    form.fipt_average.Text = nx_widestr(sum_time / total)
  end
  form.fipt_check_total.Text = nx_widestr(check_total)
  form.fipt_check_total_time.Text = nx_widestr(check_sum_time)
  if 0 < check_total then
    form.fipt_check_total_average.Text = nx_widestr(check_sum_time / check_total)
  end
  local temp = form.lbl_value.HtmlText
  form.lbl_value.HtmlText = temp .. nx_widestr(";") .. nx_widestr(dif)
  local length = table.getn(move_tbl)
  local new_value = 0
  local cur = form.fipt_cur_minute.Text
  if cur == "" or cur == nil then
    new_value = nx_int(0)
  end
  local new_value = nx_number(cur) + nx_number(dif)
  form.fipt_cur_minute.Text = nx_widestr(new_value)
  dif = form.o_y - dif
  if nx_int(dif) < nx_int(TOPDEFLECT) then
    dif = TOPDEFLECT
  end
  if nx_int(length) < nx_int(MAX_ROW) then
    table.insert(move_tbl, dif)
  else
    sum_minute_dif(form)
    move_tbl = {}
    length = 0
    form.DrawLines1:Clear()
    form.fipt_cur_minute.Text = nx_widestr("")
  end
  length = table.getn(move_tbl)
  if length <= 1 then
    return
  end
  local DrawLines1 = form.DrawLines1
  for j = 1, length - 1 do
    local start_x = form.o_x + j * form.cell_width
    local start_y = move_tbl[j]
    local end_x = form.o_x + (j + 1) * form.cell_width
    local end_y = move_tbl[j + 1]
    local index = DrawLines1:AddLine(start_x, start_y, end_x, end_y)
    DrawLines1:SetLineColor(index, GRID_COLOR)
  end
end
function sum_minute_dif(form)
  local sum_minute_dif = 0
  local length = table.getn(move_tbl)
  for i = 1, length do
    local dif = form.o_y - move_tbl[i]
    sum_minute_dif = sum_minute_dif + dif
  end
  form.fipt_last_minute.Text = nx_widestr(sum_minute_dif)
  sum_minute_dif = form.o_y - sum_minute_dif
  if table.getn(all_move_tbl) > MAX_ROW then
    all_move_tbl = {}
    form.DrawLines2:Clear()
  end
  table.insert(all_move_tbl, sum_minute_dif)
  local length = table.getn(all_move_tbl)
  if length <= 1 then
    return
  end
  for j = 1, length - 1 do
    local start_x = form.o_x + j * form.cell_width
    local start_y = all_move_tbl[j]
    local end_x = form.o_x + (j + 1) * form.cell_width
    local end_y = all_move_tbl[j + 1]
    local index = form.DrawLines2:AddLine(start_x, start_y, end_x, end_y)
    form.DrawLines2:SetLineColor(index, OUT_COLOR)
  end
end
function on_btn_Inmage_click(btn)
  local form = btn.ParentForm
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local cur_time = os.time()
  local file_name = nx_string(account) .. "\\" .. nx_string(form.target) .. nx_string(cur_time) .. nx_string(".jpg")
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return
  end
  if world:ScreenShot(file_name) then
  else
  end
end
function get_scene_id_by_name(scene_id)
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\maplist.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local item_count = ini:GetSectionItemCount(0)
  local index = 0
  local scene_name = ""
  for i = 1, item_count do
    index = index + 1
    local scene_name = nx_string(ini:GetSectionItemValue(0, i - 1))
    if index == scene_id then
      return scene_name
    end
  end
  return ""
end
