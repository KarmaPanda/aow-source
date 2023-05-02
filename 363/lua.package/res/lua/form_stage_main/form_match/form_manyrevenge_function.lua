require("util_functions")
require("util_gui")
function fresh_group_info(...)
  local form = nx_value("form_stage_main\\form_match\\form_match")
  if not nx_is_valid(form) then
    return
  end
  local argnum = table.getn(arg)
  if argnum ~= 3 then
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local is_vip = client_player:QueryProp("VipStatus")
  local sworn_intergral = nx_number(arg[1])
  local fight_times = nx_number(arg[2])
  local join_times = nx_number(arg[3])
  form.lbl_integral_2.Text = nx_widestr(sworn_intergral)
  form.lbl_26_2.Text = nx_widestr(fight_times)
  if is_vip < 1 then
    form.lbl_jointimes_2.Text = nx_widestr(join_times .. "/" .. nx_string(35))
  else
    form.lbl_jointimes_2.Text = nx_widestr(join_times .. "/" .. nx_string(70))
  end
  local grid = form.textgrid_room_2
  if grid.RowCount <= 0 then
    return
  end
  local value = nx_int(sworn_intergral)
  for i = grid.RowCount - 1, 0, -1 do
    local integral = nx_int(grid:GetGridText(i, 2))
    if value >= integral then
      grid:SelectRow(i)
      grid:SetGridText(i, 6, util_text("ui_revenge_player_in"))
      local lbl_back = grid.Parent:Find("lbl_bg_" .. nx_string(i + 11))
      if nx_is_valid(lbl_back) then
        lbl_back.Visible = true
      end
      break
    end
  end
end
function init_form_textgrid(form)
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
  form.lbl_integral_2.Text = nx_widestr("-")
  form.lbl_26_2.Text = nx_widestr("-")
  form.lbl_jointimes_2.Text = nx_widestr("-" .. "/" .. "-")
  local grid = form.textgrid_room_2
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
  local ini = get_ini("share\\War\\Match\\Match_ManyRevenge.ini")
  if not nx_is_valid(ini) then
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
      grid:SetGridText(row, 6, nx_widestr(""))
      local lbl_back = grid.Parent:Find("lbl_bg_" .. nx_string(row + 11))
      if nx_is_valid(lbl_back) then
        lbl_back.Visible = false
      end
      if 0 > grid.RowSelectIndex and integral <= nx_int(form.lbl_integral_2.Text) and maxintegral > nx_int(form.lbl_integral_2.Text) then
        grid:SelectRow(row)
      end
    end
  end
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nx_null()
  end
  return client_player
end
