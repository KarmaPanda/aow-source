require("const_define")
require("util_functions")
local FILE_NAME = ""
local qizi_bai = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_bai.png"
local qizi_hei = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_hei.png"
local cover_image = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_quan1.png"
local buju_bai_table = {}
local buju_hei_table = {}
local qizi_player_table = {}
local qizi_robot_table = {}
local text_info_table = {}
local del_player_qizi_table = {}
local del_robot_qizi_table = {}
local mouse_state = 0
local game_state = 0
local player_qizi_type = 0
local game_yanshi = 1
local game_qipan_type = 0
local old_mouse_state = 0
local first_turn = 1
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  refresh_form_pos(self)
  refresh_form(self)
  init_state()
end
function table_clear(t)
  for i = 1, table.getn(t) do
    table.remove(t)
  end
  t = {}
end
function init_state()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi_edit")
  if not nx_is_valid(form) then
    return
  end
  game_state = 0
  mouse_state = 0
  old_mouse_state = 0
  form.btn_buju.Enabled = true
  form.btn_yanshi.Enabled = true
  form.combobox_qipantype.Enabled = true
  form.combobox_qizitype.Enabled = true
  form.combobox_firstturn.Enabled = true
  form.ipt_num.Enabled = false
  form.btn_add_bai.Enabled = true
  form.btn_add_hei.Enabled = true
  form.btn_continue.Visible = false
  form.btn_delete.Visible = true
  form.btn_goback.Enabled = false
  form.ipt_num.Text = nx_widestr("0")
  clear_data()
  for i = 1, 30 do
    table.insert(del_player_qizi_table, "")
    table.insert(del_robot_qizi_table, "")
  end
end
function clear_data()
  table_clear(buju_bai_table)
  table_clear(buju_hei_table)
  table_clear(qizi_player_table)
  table_clear(qizi_robot_table)
  table_clear(text_info_table)
  table_clear(del_player_qizi_table)
  table_clear(del_robot_qizi_table)
end
function refresh_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(self)
  init_state()
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi_edit")
  if nx_is_valid(form) then
    form:Close()
  end
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.combobox_qipantype.DropListBox:AddString(nx_widestr("9*9"))
  form.combobox_qipantype.DropListBox:AddString(nx_widestr("13*13"))
  form.combobox_qipantype.DropListBox:AddString(nx_widestr("19*19"))
  form.combobox_qipantype.Text = nx_widestr("9*9")
  game_qipan_type = 0
  form.combobox_gametype.DropListBox:AddString(nx_widestr("\206\222\209\221\202\190"))
  form.combobox_gametype.DropListBox:AddString(nx_widestr("\211\208\209\221\202\190"))
  form.combobox_gametype.Text = nx_widestr("\211\208\209\221\202\190")
  game_yanshi = 1
  form.combobox_qizitype.DropListBox:AddString(nx_widestr("\176\215\215\211"))
  form.combobox_qizitype.DropListBox:AddString(nx_widestr("\186\218\215\211"))
  form.combobox_qizitype.Text = nx_widestr("\176\215\215\211")
  player_qizi_type = 0
  form.combobox_firstturn.DropListBox:AddString(nx_widestr("\205\230\188\210"))
  form.combobox_firstturn.DropListBox:AddString(nx_widestr("\187\250\198\247\200\203"))
  form.combobox_firstturn.Text = nx_widestr("\205\230\188\210")
  first_turn = 1
end
function on_combobox_qipantype_selected(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local qipan_type = self.Text
  local imagegrid = form.groupbox_main:Find("imagegrid_weiqi")
  if nx_is_valid(imagegrid) then
    form.groupbox_main:Remove(imagegrid)
    gui:Delete(imagegrid)
  end
  local grid = gui:Create("ImageGrid")
  grid.Name = "imagegrid_weiqi"
  grid.BackColor = "0,0,0,0"
  grid.NoFrame = true
  grid.HasVScroll = false
  grid.SelectColor = "0,0,0,0"
  grid.MouseInColor = "0,0,0,0"
  grid.DrawMouseIn = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_mouse.png"
  nx_bind_script(grid, nx_current(), "")
  nx_callback(grid, "on_select_changed", "on_imagegrid_weiqi_select_changed")
  form.groupbox_main:Add(grid)
  if nx_string(qipan_type) == nx_string("9*9") then
    grid.Left = 134
    grid.Top = 14
    grid.RowNum = 9
    grid.ClomnNum = 9
    grid.Width = 513
    grid.Height = 513
    grid.GridWidth = 57
    grid.GridHeight = 57
    grid.ViewRect = "0,0" .. "," .. nx_string(grid.Width) .. "," .. nx_string(grid.Height)
    form.lbl_grid_back.BackImage = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_grid1.png"
    cover_image = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_quan1.png"
    game_qipan_type = 0
  elseif nx_string(qipan_type) == nx_string("13*13") then
    grid.Left = 145
    grid.Top = 25
    grid.Width = 500
    grid.Height = 500
    grid.RowNum = 13
    grid.ClomnNum = 13
    grid.GridWidth = 37
    grid.GridHeight = 37
    grid.ViewRect = "0,0" .. "," .. nx_string(grid.Width) .. "," .. nx_string(grid.Height)
    form.lbl_grid_back.BackImage = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_grid2.png"
    cover_image = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_quan2.png"
    game_qipan_type = 1
  elseif nx_string(qipan_type) == nx_string("19*19") then
    grid.Left = 152
    grid.Top = 32
    grid.Width = 477
    grid.Height = 477
    grid.RowNum = 19
    grid.ClomnNum = 19
    grid.GridWidth = 25
    grid.GridHeight = 25
    grid.ViewRect = "0,0" .. "," .. nx_string(grid.Width) .. "," .. nx_string(grid.Height)
    form.lbl_grid_back.BackImage = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_grid.png"
    cover_image = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_quan.png"
    game_qipan_type = 2
  end
end
function on_combobox_gametype_selected(self)
  local gametype = self.Text
  if nx_string(gametype) == nx_string("\211\208\209\221\202\190") then
    game_yanshi = 1
  else
    game_yanshi = 0
  end
end
function on_combobox_qizitype_selected(self)
  local qizitype = self.Text
  if nx_string(qizitype) == nx_string("\176\215\215\211") then
    player_qizi_type = 0
  else
    player_qizi_type = 1
  end
end
function on_combobox_firstturn_selected(self)
  local firstturn = self.Text
  if nx_string(firstturn) == nx_string("\187\250\198\247\200\203") then
    first_turn = 2
  else
    first_turn = 1
  end
end
function on_imagegrid_weiqi_select_changed(grid, index)
  local form = grid.ParentForm
  if game_state == 0 then
    return
  end
  if mouse_state == 1 then
    if add_qizi(0, index) then
      if game_state == 1 then
        table.insert(buju_bai_table, index)
      elseif game_state == 2 then
        if player_qizi_type == 0 then
          table.insert(qizi_player_table, index)
        else
          table.insert(qizi_robot_table, index)
        end
        table.insert(text_info_table, nx_string(form.ipt_textinfo_ex.Text))
        form.ipt_num.Text = nx_widestr(nx_number(form.ipt_num.Text) + 1)
        mouse_state = 2
        old_mouse_state = 1
      end
    end
  elseif mouse_state == 2 then
    if add_qizi(1, index) then
      if game_state == 1 then
        table.insert(buju_hei_table, index)
      elseif game_state == 2 then
        if player_qizi_type == 1 then
          table.insert(qizi_player_table, index)
        else
          table.insert(qizi_robot_table, index)
        end
        table.insert(text_info_table, nx_string(form.ipt_textinfo_ex.Text))
        form.ipt_num.Text = nx_widestr(nx_number(form.ipt_num.Text) + 1)
        mouse_state = 1
        old_mouse_state = 2
      end
    end
  elseif mouse_state == 3 then
    if game_state == 1 then
      if del_qizi(index) then
        for i = 1, table.getn(buju_bai_table) do
          if buju_bai_table[i] == index then
            table.remove(buju_bai_table, i)
          end
        end
        for i = 1, table.getn(buju_hei_table) do
          if buju_hei_table[i] == index then
            table.remove(buju_hei_table, i)
          end
        end
      end
    elseif game_state == 2 and del_qizi(index) then
      if old_mouse_state - 1 == player_qizi_type then
        local temp_index = table.getn(qizi_player_table)
        if nx_string(del_player_qizi_table[temp_index]) == "" then
          del_player_qizi_table[temp_index] = nx_string(index)
        else
          del_player_qizi_table[temp_index] = nx_string(del_player_qizi_table[temp_index]) .. "|" .. nx_string(index)
        end
      else
        local temp_index = table.getn(qizi_robot_table)
        if nx_string(del_robot_qizi_table[temp_index]) == "" then
          del_robot_qizi_table[temp_index] = nx_string(index)
        else
          del_robot_qizi_table[temp_index] = nx_string(del_robot_qizi_table[temp_index]) .. "|" .. nx_string(index)
        end
      end
    end
  end
end
function add_qizi(turn, index)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi_edit")
  if not nx_is_valid(form) then
    return false
  end
  if index < 0 or 361 < index then
    return false
  end
  local grid = form.groupbox_main:Find("imagegrid_weiqi")
  if not nx_is_valid(grid) then
    return false
  end
  if not grid:IsEmpty(index) then
    return false
  end
  if turn == 0 then
    grid:AddItem(index, qizi_bai, "", 1, -1)
  elseif turn == 1 then
    grid:AddItem(index, qizi_hei, "", 1, -1)
  end
  return true
end
function del_qizi(index)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi_edit")
  if not nx_is_valid(form) then
    return false
  end
  if index < 0 or 361 < index then
    return false
  end
  local grid = form.groupbox_main:Find("imagegrid_weiqi")
  if not nx_is_valid(grid) then
    return false
  end
  if grid:IsEmpty(index) then
    return false
  end
  grid:DelItem(index)
  return true
end
function on_btn_buju_click(btn)
  local form = btn.ParentForm
  game_state = 1
  mouse_state = 1
  btn.Enabled = false
  form.combobox_qipantype.Enabled = false
end
function on_btn_yanshi_click(btn)
  local form = btn.ParentForm
  game_state = 2
  if player_qizi_type + 1 == first_turn then
    mouse_state = 1
  else
    mouse_state = 2
  end
  form.btn_buju.Enabled = false
  form.btn_goback.Enabled = true
  form.combobox_qipantype.Enabled = false
  form.combobox_qizitype.Enabled = false
  form.btn_add_bai.Enabled = false
  form.btn_add_hei.Enabled = false
  form.combobox_firstturn.Enabled = false
  btn.Enabled = false
end
function on_btn_clear_click(btn)
  local form = btn.ParentForm
  local grid = form.groupbox_main:Find("imagegrid_weiqi")
  if not nx_is_valid(grid) then
    return
  end
  grid:Clear()
  init_state()
end
function on_btn_goback_click(btn)
  local form = btn.ParentForm
  local grid = form.groupbox_main:Find("imagegrid_weiqi")
  if not nx_is_valid(grid) then
    return
  end
  btn.Enabled = false
  grid:Clear()
  game_state = 1
  mouse_state = 1
  old_mouse_state = 0
  form.btn_buju.Enabled = false
  form.btn_yanshi.Enabled = true
  form.combobox_qipantype.Enabled = false
  form.combobox_qizitype.Enabled = true
  form.combobox_firstturn.Enabled = true
  form.ipt_num.Enabled = false
  form.btn_add_bai.Enabled = true
  form.btn_add_hei.Enabled = true
  form.btn_continue.Visible = false
  form.btn_delete.Visible = true
  form.ipt_num.Text = nx_widestr("0")
  table_clear(qizi_player_table)
  table_clear(qizi_robot_table)
  table_clear(text_info_table)
  table_clear(del_player_qizi_table)
  table_clear(del_robot_qizi_table)
  for i = 1, 30 do
    table.insert(del_player_qizi_table, "")
    table.insert(del_robot_qizi_table, "")
  end
  for i = 1, table.getn(buju_bai_table) do
    add_qizi(0, buju_bai_table[i])
  end
  for i = 1, table.getn(buju_hei_table) do
    add_qizi(1, buju_hei_table[i])
  end
end
function on_btn_save_click(btn)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi_edit")
  if not nx_is_valid(form) then
    return
  end
  local ini = load_ini(nx_resource_path() .. "share\\Life\\WeiqiGame.ini")
  if not nx_is_valid(ini) then
    return
  end
  local game_id = nx_string(form.ipt_name.Text)
  local time = nx_string(form.ipt_time.Text)
  local playerType = nx_string(player_qizi_type)
  local gameYanshi = nx_string(game_yanshi)
  local qipanType = nx_string(game_qipan_type)
  local errorTimes = nx_string(form.ipt_errortimes.Text)
  local TextInfo = nx_string(form.ipt_textinfo.Text)
  local spacingTime = nx_string(form.ipt_spacing_time.Text)
  local firstTurn = nx_string(first_turn)
  local markType = nx_string(form.ipt_mark_type.Text)
  local helptext = nx_string(form.ipt_help_text.Text)
  local whitePos = table_to_string(buju_bai_table)
  local blackPos = table_to_string(buju_hei_table)
  local playerPos = ""
  for i = 1, table.getn(qizi_player_table) do
    if nx_string(playerPos) == "" then
      playerPos = nx_string(playerPos) .. nx_string(qizi_player_table[i])
    else
      playerPos = nx_string(playerPos) .. "," .. nx_string(qizi_player_table[i])
    end
    local del_qizi_str = del_player_qizi_table[i]
    if del_qizi_str ~= nil and nx_string(del_qizi_str) ~= "" then
      playerPos = nx_string(playerPos) .. "|" .. nx_string(del_qizi_str)
    end
  end
  local robotPos = ""
  for i = 1, table.getn(qizi_robot_table) do
    if nx_string(robotPos) == "" then
      robotPos = nx_string(robotPos) .. nx_string(qizi_robot_table[i])
    else
      robotPos = nx_string(robotPos) .. "," .. nx_string(qizi_robot_table[i])
    end
    local del_qizi_str = del_robot_qizi_table[i]
    if del_qizi_str ~= nil and nx_string(del_qizi_str) ~= "" then
      robotPos = nx_string(robotPos) .. "|" .. nx_string(del_qizi_str)
    end
  end
  ini:DeleteSection(game_id)
  ini_set_value(ini, game_id, "time", time)
  ini_set_value(ini, game_id, "playerType", playerType)
  ini_set_value(ini, game_id, "gameType", gameYanshi)
  ini_set_value(ini, game_id, "qipanType", qipanType)
  ini_set_value(ini, game_id, "errorTime", errorTimes)
  ini_set_value(ini, game_id, "whitePos", whitePos)
  ini_set_value(ini, game_id, "blackPos", blackPos)
  ini_set_value(ini, game_id, "playerPos", playerPos)
  ini_set_value(ini, game_id, "robotPos", robotPos)
  ini_set_value(ini, game_id, "TextInfo", TextInfo)
  ini_set_value(ini, game_id, "spacingTime", spacingTime)
  ini_set_value(ini, game_id, "firstTurn", firstTurn)
  ini_set_value(ini, game_id, "markType", markType)
  ini_set_value(ini, game_id, "helptext", helptext)
  for i = 1, table.getn(text_info_table) do
    local temp_str = "TextInfo_" .. nx_string(i)
    ini_set_value(ini, game_id, temp_str, text_info_table[i])
  end
  ini:SaveToFile()
  nx_destroy(ini)
  nx_msgbox(get_msg_str("msg_102") .. nx_string(game_id))
end
function on_btn_add_bai_click(btn)
  mouse_state = 1
end
function on_btn_add_hei_click(btn)
  mouse_state = 2
end
function on_btn_delete_click(btn)
  local form = btn.ParentForm
  mouse_state = 3
  if game_state == 2 then
    btn.Visible = false
    form.btn_continue.Visible = true
  end
end
function on_btn_continue_click(btn)
  local form = btn.ParentForm
  if game_state ~= 2 then
    return
  end
  mouse_state = 3 - old_mouse_state
  form.btn_delete.Visible = true
  btn.Visible = false
end
function on_btn_read_click(btn)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi_edit")
  if not nx_is_valid(form) then
    return
  end
  local ini = load_ini(nx_resource_path() .. "share\\Life\\WeiqiGame.ini")
  if not nx_is_valid(ini) then
    return
  end
  local game_id = nx_string(form.ipt_name.Text)
  if not ini:FindSection(nx_string(game_id)) then
    nx_msgbox(get_msg_str("msg_419") .. nx_string(game_id))
    return
  end
  local grid = form.groupbox_main:Find("imagegrid_weiqi")
  if not nx_is_valid(grid) then
    nx_msgbox(get_msg_str("msg_149"))
    return
  end
  grid:Clear()
  local time = ini_get_value(ini, game_id, "time")
  local playerType = ini_get_value(ini, game_id, "playerType")
  local gameYanshi = ini_get_value(ini, game_id, "gameType")
  local qipanType = ini_get_value(ini, game_id, "qipanType")
  local errorTimes = ini_get_value(ini, game_id, "errorTime")
  local spacingTime = ini_get_value(ini, game_id, "spacingTime")
  local TextInfo = ini_get_value(ini, game_id, "TextInfo")
  local firstTurn = ini_get_value(ini, game_id, "firstTurn")
  local markType = ini_get_value(ini, game_id, "markType")
  local helptext = ini_get_value(ini, game_id, "helptext")
  local whitePos = ini_get_value(ini, game_id, "whitePos")
  local blackPos = ini_get_value(ini, game_id, "blackPos")
  form.ipt_time.Text = nx_widestr(time)
  if nx_string(playerType) == "1" then
    form.combobox_qizitype.Text = nx_widestr("\186\218\215\211")
    player_qizi_type = 1
  else
    form.combobox_qizitype.Text = nx_widestr("\176\215\215\211")
    player_qizi_type = 0
  end
  if nx_string(gameYanshi) == "0" then
    form.combobox_gametype.Text = nx_widestr("\206\222\209\221\202\190")
    game_yanshi = 0
  else
    form.combobox_gametype.Text = nx_widestr("\211\208\209\221\202\190")
    game_yanshi = 1
  end
  if nx_string(qipanType) == "1" then
    form.combobox_qipantype.Text = nx_widestr("13*13")
    game_qipan_type = 1
  elseif nx_string(qipanType) == "2" then
    form.combobox_qipantype.Text = nx_widestr("19*19")
    game_qipan_type = 2
  else
    form.combobox_qipantype.Text = nx_widestr("9*9")
    game_qipan_type = 0
  end
  if firstTurn == 1 then
    form.combobox_firstturn.Text = nx_widestr("\205\230\188\210")
  elseif firstTurn == 2 then
    form.combobox_firstturn.Text = nx_widestr("\187\250\198\247\200\203")
  end
  form.ipt_errortimes.Text = nx_widestr(errorTimes)
  form.ipt_spacing_time.Text = nx_widestr(spacingTime)
  form.ipt_mark_type.Text = nx_widestr(markType)
  form.ipt_help_text.Text = nx_widestr(helptext)
  form.ipt_textinfo.Text = nx_widestr(TextInfo)
  form.ipt_textinfo_ex.Text = nx_widestr("")
  game_state = 1
  mouse_state = 1
  old_mouse_state = 0
  form.btn_buju.Enabled = false
  form.btn_yanshi.Enabled = true
  form.combobox_qipantype.Enabled = false
  form.combobox_qizitype.Enabled = true
  form.combobox_firstturn.Enabled = true
  form.ipt_num.Enabled = false
  form.btn_add_bai.Enabled = true
  form.btn_add_hei.Enabled = true
  form.btn_continue.Visible = false
  form.btn_delete.Visible = true
  form.btn_goback.Enabled = false
  form.ipt_num.Text = nx_widestr("0")
  clear_data()
  for i = 1, 30 do
    table.insert(del_player_qizi_table, "")
    table.insert(del_robot_qizi_table, "")
  end
  local white_table = util_split_string(whitePos, ",")
  for i = 1, table.getn(white_table) do
    table.insert(buju_bai_table, nx_number(white_table[i]))
  end
  local black_table = util_split_string(blackPos, ",")
  for i = 1, table.getn(black_table) do
    table.insert(buju_hei_table, nx_number(black_table[i]))
  end
  for i = 1, table.getn(buju_bai_table) do
    add_qizi(0, buju_bai_table[i])
  end
  for i = 1, table.getn(buju_hei_table) do
    add_qizi(1, buju_hei_table[i])
  end
  nx_destroy(ini)
  nx_msgbox(get_msg_str("msg_420") .. nx_string(game_id))
end
function load_ini(path)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(path)
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    nx_msgbox(get_msg_str("msg_088", nx_string(path)))
    return nx_null()
  end
  return ini
end
function ini_set_value(ini, section, item, value)
  if nx_is_valid(ini) then
    if nx_string(value) == "" then
      ini:DeleteItem(nx_string(section), nx_string(item))
    else
      ini:WriteString(nx_string(section), nx_string(item), nx_string(value))
    end
  end
end
function ini_get_value(ini, section, item)
  if nx_is_valid(ini) then
    return ini:ReadString(nx_string(section), nx_string(item), "")
  end
  return ""
end
function table_to_string(t)
  local ret = ""
  for i = 1, table.getn(t) do
    if nx_string(ret) == "" then
      ret = nx_string(ret) .. nx_string(t[i])
    else
      ret = nx_string(ret) .. "," .. nx_string(t[i])
    end
  end
  return ret
end
