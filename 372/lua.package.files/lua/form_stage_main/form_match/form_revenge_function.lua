require("util_functions")
require("util_gui")
require("util_vip")
function init_form_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.lbl_integral.Text = nx_widestr(nx_string(client_player:QueryProp("RevengeIntegral")))
  auto_locate_grid(form)
  local grid = form.textgrid_room
  if grid.RowCount > 0 then
    return
  end
  grid:SetColTitle(0, nx_widestr(util_text("ui_revenge_roomid")))
  grid:SetColTitle(1, nx_widestr(util_text("ui_revenge_roomname")))
  grid:SetColTitle(2, nx_widestr(util_text("ui_revenge_integral")))
  grid:SetColTitle(3, nx_widestr(util_text("ui_revenge_nownumber")))
  grid:SetColTitle(4, nx_widestr(util_text("ui_revenge_maxnumber")))
  grid:SetColTitle(5, nx_widestr(util_text("ui_revenge_roomstate")))
  grid:SetColTitle(6, nx_widestr(util_text("ui_revenge_playerstate")))
  local ini = get_ini("share\\War\\Match\\Match_Revenge.ini")
  if nx_is_null(ini) then
    return
  end
  local index = ini:FindSectionIndex("Room")
  if index < 0 then
    return
  end
  local rooms = ini:GetItemValueList(index, "r")
  for i = 1, table.getn(rooms) do
    local strs = util_split_string(rooms[i], "/")
    if table.getn(strs) >= 8 then
      local room_name = nx_string(strs[1])
      local integral = nx_int(strs[2])
      local maxintegral = nx_int(strs[3])
      local maxnum = nx_int(strs[6])
      local room_name_text = "ui_revenge_roomname_" .. room_name
      local row = grid:InsertRow(-1)
      grid:SetGridText(row, 0, nx_widestr(room_name))
      grid:SetGridText(row, 1, util_text(room_name_text))
      grid:SetGridText(row, 2, nx_widestr(nx_string(integral)))
      grid:SetGridText(row, 3, nx_widestr("0"))
      grid:SetGridText(row, 4, nx_widestr(nx_string(maxnum)))
      grid:SetGridText(row, 5, util_text(get_room_state(0, maxnum)))
      grid:SetGridText(row, 6, nx_widestr(""))
      local lbl_back = grid.Parent:Find("lbl_bg_" .. nx_string(row + 1))
      if nx_is_valid(lbl_back) then
        lbl_back.Visible = false
      end
      if 0 > grid.RowSelectIndex and integral <= nx_int(form.lbl_integral.Text) and maxintegral > nx_int(form.lbl_integral.Text) then
        grid:SelectRow(row)
      end
    end
  end
  auto_locate_grid(form)
  form.lbl_jointimes.Text = nx_widestr(nx_string(0) .. "/" .. nx_string(0))
end
function auto_locate_grid(form)
  local grid = form.textgrid_room
  if grid.RowCount <= 0 then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = nx_int(client_player:QueryProp("RevengeIntegral"))
  for i = grid.RowCount - 1, 0, -1 do
    local integral = nx_int(grid:GetGridText(i, 2))
    if value >= integral then
      grid:SelectRow(i)
      break
    end
  end
end
function fresh_join_times(form, ...)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_jointimes.Text = nx_widestr(nx_string(arg[1]) .. "/" .. nx_string(arg[2]))
end
function fresh_form_grid(form, ...)
  local grid = form.textgrid_room
  local roomnum = nx_number(arg[1])
  for i = 2, roomnum * 2 + 1, 2 do
    local roomname = nx_string(arg[i])
    local nomnumber = nx_int(arg[i + 1])
    local row = get_grid_row_by_roomname(form, roomname)
    if row ~= -1 then
      grid:SetGridText(row, 3, nx_widestr(nx_string(nomnumber)))
      local maxnum = grid:GetGridText(row, 4)
      grid:SetGridText(row, 5, util_text(get_room_state(nomnumber, maxnum)))
      grid:SetGridText(row, 6, nx_widestr(""))
      local lbl_back = grid.Parent:Find("lbl_bg_" .. nx_string(row + 1))
      if nx_is_valid(lbl_back) then
        lbl_back.Visible = false
      end
    end
  end
  roomnum = 2 * roomnum + 1
  local my_roomname = nx_string(arg[roomnum + 1])
  local my_uid = nx_string(arg[roomnum + 2])
  local my_integral = nx_int(arg[roomnum + 3])
  local my_state = nx_number(arg[roomnum + 4])
  form.lbl_integral.Text = nx_widestr(nx_string(my_integral))
  local row = get_grid_row_by_roomname(form, my_roomname)
  form.revenge_join_row = row
  if 0 <= row then
    grid:SetGridText(row, 6, util_text("ui_revenge_player_in"))
    local lbl_back = grid.Parent:Find("lbl_bg_" .. nx_string(row + 1))
    if nx_is_valid(lbl_back) then
      lbl_back.Visible = true
    end
  else
    local game_client = nx_value("game_client")
    if nx_is_valid(game_client) then
      local client_player = game_client:GetPlayer()
      if nx_is_valid(client_player) then
        form.lbl_integral.Text = nx_widestr(nx_string(client_player:QueryProp("RevengeIntegral")))
      end
    end
  end
  form.revenge_join_state = my_state
  form.lbl_state.Text = nx_widestr("@ui_revenge_state_" .. nx_string(my_state))
  if row < 0 then
    form.btn_room.Enabled = true
    form.btn_room.msgid = 0
    form.btn_match.msgid = 2
    form.btn_room.Text = nx_widestr("@ui_revenge_join_room")
    form.btn_match.Text = nx_widestr("@ui_revenge_join")
  else
    form.btn_room.Enabled = true
    form.btn_match.Enabled = true
    form.btn_room.msgid = 1
    form.btn_match.msgid = 2
    form.btn_room.Text = nx_widestr("@ui_revenge_quit_room")
    form.btn_match.Text = nx_widestr("@ui_revenge_join")
  end
  if my_state == 0 or my_state == 1 or my_state == 2 then
    form.btn_room.Enabled = true
  else
    form.btn_room.Enabled = false
  end
  if my_state == 0 then
    form.btn_match.msgid = 2
    form.btn_match.Text = nx_widestr("@ui_revenge_join")
  elseif my_state == 1 then
    form.btn_match.Enabled = true
    form.btn_match.msgid = 2
    form.btn_match.Text = nx_widestr("@ui_revenge_join")
  elseif my_state == 2 then
    form.btn_match.Enabled = true
    form.btn_match.msgid = 3
    form.btn_match.Text = nx_widestr("@ui_revenge_quit")
  elseif my_state == 3 then
    form.btn_match.Enabled = false
    form.btn_match.msgid = 2
    form.btn_match.Text = nx_widestr("@ui_revenge_join")
  elseif my_state == 4 then
    form.btn_match.Enabled = false
    form.btn_match.msgid = 2
    form.btn_match.Text = nx_widestr("@ui_revenge_join")
  end
end
function get_grid_row_by_roomname(form, roomname)
  if nx_string(roomname) == "" then
    return -1
  end
  local grid = form.textgrid_room
  for i = 0, grid.RowCount do
    if nx_string(roomname) == nx_string(grid:GetGridText(i, 0)) then
      return i
    end
  end
  return -1
end
function get_room_state(nownum, maxnum)
  local _now = nx_float(nownum)
  local _max = nx_float(maxnum)
  local tipsid = ""
  if nx_int(_max) <= nx_int(0) then
    tipsid = "1"
  elseif 0.9 <= _now / _max then
    tipsid = "4"
  elseif 0.75 <= _now / _max then
    tipsid = "3"
  elseif 0.5 <= _now / _max then
    tipsid = "2"
  else
    tipsid = "1"
  end
  return "ui_revenge_roomstate_" .. tipsid
end
function get_join_match_times(player)
  if not nx_is_valid(player) then
    return 0
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local servertime = nx_int(msg_delay:GetServerDateTime())
  local recordname = "MatchSelf"
  local times = 0
  local nRows = player:GetRecordRows(recordname)
  for i = 0, nRows - 1 do
    local jointime = nx_int(player:QueryRecord(recordname, i, 0))
    if servertime <= jointime then
      times = times + 1
    end
  end
  return times
end
