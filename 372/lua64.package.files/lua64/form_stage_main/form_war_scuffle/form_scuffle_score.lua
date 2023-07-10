require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\sysinfo_define")
require("custom_sender")
require("form_stage_main\\form_war_scuffle\\luandou_util")
local FORM_NAME = "form_stage_main\\form_war_scuffle\\form_scuffle_score"
local array_player = {}
local is_quit_fail = false
local luandou_result_col_list = {
  "ui_war_scuffle_001",
  "ui_war_scuffle_002",
  "ui_war_scuffle_003",
  "ui_war_scuffle_004",
  "ui_war_scuffle_005",
  "ui_choswar_interface_004"
}
local luandou_win = 1
local luandou_lose = 2
function open_form()
  local form = get_form()
  if nx_is_valid(form) then
    form:Close()
  else
    util_show_form(FORM_NAME, true)
  end
end
function force_open_form(...)
  local n = #arg
  if n <= 0 then
    return
  end
  if is_quit_fail then
    return
  end
  is_quit_fail = nx_int(arg[1]) > nx_int(0)
  local form = get_form()
  if not nx_is_valid(form) then
    open_form()
    form = get_form()
  else
    request_result_ui()
    form.rbtn_att.Checked = true
    form.rbtn_def.Checked = false
    form.is_receive_server_msg = false
  end
  form.rbtn_def.Visible = not is_quit_fail
end
function close_form()
  local form = get_form()
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.AbsLeft = (gui.Width - form.Width) / 2
    form.AbsTop = (gui.Height - form.Height) / 2
  end
  request_result_ui()
  for i = 1, table.getn(luandou_result_col_list) do
    local head_name = util_text(luandou_result_col_list[i])
    form.textgrid_info:SetColTitle(i - 1, nx_widestr(head_name))
  end
  show_win_or_lose(0)
  form.self_side = 1
  form.side1_result = 0
  form.side2_result = 0
  form.is_receive_server_msg = false
  array_player = {}
  form.rbtn_att.Checked = true
  form.rbtn_def.Checked = false
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_best", "reset_form_position")
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  is_quit_fail = false
  nx_destroy(form)
end
function on_rbtn_att_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  show_ui_by_side(form.self_side)
end
function on_rbtn_def_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  show_ui_by_side(get_enemy_side())
end
function on_btn_exit_click(btn)
  nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "confirm_quit")
end
function on_btn_close_click(btn)
  close_form()
end
function request_result_ui()
  if is_quit_fail then
    return
  end
  custom_luandou(nx_int(105))
end
function request_quit()
  custom_luandou(nx_int(102))
end
function receive_result_ui(...)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local n = #arg
  if n <= 1 then
    return
  end
  if is_quit_fail and form.is_receive_server_msg then
    return
  end
  form.is_receive_server_msg = true
  form.self_side = tonumber(nx_string(arg[1]))
  form.side1_result = nx_int(arg[2])
  form.side2_result = nx_int(arg[3])
  array_player = {}
  for i = 4, #arg do
    local player_text = nx_widestr(arg[i])
    table.insert(array_player, player_text)
  end
  local cur_open_side = get_cur_open_side()
  show_ui_by_side(cur_open_side)
end
function show_ui_by_side(target_side)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local self_name = get_player_name()
  local grid = form.textgrid_info
  local array_side = {}
  for i = 1, #array_player do
    local player_text = nx_widestr(array_player[i])
    local one_player = util_split_wstring(player_text, nx_widestr(","))
    local side = tonumber(nx_string(one_player[1]))
    if side == target_side then
      local player_name = nx_widestr(one_player[2])
      local kill = nx_int(one_player[3])
      local help_kill = nx_int(one_player[4])
      local damage = get_damage(nx_int64(one_player[5]))
      local player_score = nx_int(one_player[6])
      local is_self = player_name == self_name
      local is_show = not is_quit_fail or is_quit_fail and is_self
      if is_show then
        table.insert(array_side, {
          player_name,
          kill,
          help_kill,
          damage,
          player_score
        })
      end
    end
  end
  table.sort(array_side, function(a, b)
    if a[2] ~= b[2] then
      return a[2] > b[2]
    elseif a[5] ~= b[5] then
      return a[5] > b[5]
    else
      return a[4] > b[4]
    end
  end)
  grid:BeginUpdate()
  grid:ClearRow()
  for rank = 1, #array_side do
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(rank))
    for col = 1, 5 do
      grid:SetGridText(row, col, nx_widestr(array_side[rank][col]))
    end
    local player_name = nx_widestr(array_side[rank][1])
    local is_self = player_name == self_name
    if is_self then
      for col = 0, 5 do
        grid:SetGridForeColor(row, col, "255,230,93,70")
      end
    end
  end
  grid:EndUpdate()
  local result = nx_int(0)
  if is_quit_fail then
    result = nx_int(luandou_lose)
  elseif target_side == 1 then
    result = form.side1_result
  elseif target_side == 2 then
    result = form.side2_result
  end
  show_win_or_lose(result)
end
function get_cur_open_side(form)
  local form = get_form()
  if not nx_is_valid(form) then
    return 0
  end
  if form.rbtn_att.Checked then
    return form.self_side
  elseif form.rbtn_def.Checked then
    return get_enemy_side()
  end
  return form.self_side
end
function l(info)
  nx_msgbox(nx_string(info))
end
function get_form()
  local form = nx_value(FORM_NAME)
  return form
end
function get_damage(num)
  local damage = nx_int(num)
  if damage >= nx_int(0) and damage < nx_int(10000) then
    return nx_widestr(damage)
  elseif damage == nx_int(10000) then
    local temp_text = util_text("ui_wan")
    return nx_widestr("1") .. temp_text
  elseif damage > nx_int(10000) then
    local wan_num = nx_int(damage / 10000)
    local temp_num = nx_int(math.mod(nx_number(damage), 10000))
    local temp_num2 = nx_int((temp_num + 50) / 100)
    local temp_text = util_text("ui_wan")
    return nx_widestr(wan_num) .. nx_widestr(".") .. nx_widestr(temp_num2) .. temp_text
  else
    return nx_widestr("")
  end
end
function show_win_or_lose(result)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  form.lbl_win_text.Visible = false
  form.lbl_lose_text.Visible = false
  if nx_int(result) == nx_int(luandou_win) then
    form.lbl_win_text.Visible = true
  elseif nx_int(result) == nx_int(luandou_lose) then
    form.lbl_lose_text.Visible = true
  end
end
function get_enemy_side()
  local form = get_form()
  if not nx_is_valid(form) then
    return 1
  end
  local enemy_side = 1
  if form.self_side == 1 then
    enemy_side = 2
  end
  return enemy_side
end
function refresh_ui()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  request_result_ui()
end
