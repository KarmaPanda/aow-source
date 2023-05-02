require("util_functions")
require("util_gui")
require("tips_data")
require("util_role_prop")
local FILE_SNS_STYLE = "ini\\sns\\sns_new_style.ini"
function on_main_form_init(form)
  form.Fixed = false
  form.refresh_time = 0
end
function on_main_form_open(form)
  reset_friend_info()
  reset_enemy_info()
  change_form_size()
  form.groupbox_all.Visible = false
  form.groupbox_find.Visible = false
  form.btn_show_tips.Visible = false
  init_show_form(form)
  nx_execute("custom_sender", "custom_query_enemy_info", 3)
end
function on_main_form_close(form)
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    IniManager:UnloadIniFromManager(FILE_SNS_STYLE)
  end
  local form_menu = nx_value("form_stage_main\\form_chat_system\\form_new_friend_menu")
  if nx_is_valid(form_menu) then
    form_menu:Close()
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_textgrid_friend_right_select_grid(grid, row, col)
  if row < 0 then
    local form_new_friend_menu = nx_value("form_stage_main\\form_chat_system\\form_new_friend_menu")
    if nx_is_valid(form_new_friend_menu) then
      form_new_friend_menu:Close()
    end
    return
  end
  local name = grid:GetGridText(row, 0)
  grid:SelectRow(row)
  nx_execute("form_stage_main\\form_chat_system\\form_new_friend_menu", "open_form", nx_widestr(name), true)
end
function on_textgrid_enemy_right_select_grid(grid, row, col)
  if row < 0 then
    local form_new_friend_menu = nx_value("form_stage_main\\form_chat_system\\form_new_friend_menu")
    if nx_is_valid(form_new_friend_menu) then
      form_new_friend_menu:Close()
    end
    return
  end
  local name = grid:GetGridText(row, 0)
  grid:SelectRow(row)
  nx_execute("form_stage_main\\form_chat_system\\form_new_friend_menu", "open_form", nx_widestr(name), false)
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_chat_system\\form_new_friend_list")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function reset_friend_info()
  local form = nx_value("form_stage_main\\form_chat_system\\form_new_friend_list")
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local grid = form.textgrid_friend
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  grid.ColCount = 6
  grid.ColWidths = "130, 130, 130, 140, 130, 0"
  local rec_name = "rec_friend"
  local row_count = client_player:GetRecordRows(rec_name)
  for row_index = 0, row_count - 1 do
    local name = client_player:QueryRecord(rec_name, row_index, 1)
    local power_level = client_player:QueryRecord(rec_name, row_index, 4)
    local guild = client_player:QueryRecord(rec_name, row_index, 6)
    local num1 = nx_number(client_player:QueryRecord(rec_name, row_index, 11))
    local num2 = nx_number(client_player:QueryRecord(rec_name, row_index, 12))
    local scene_id = client_player:QueryRecord(rec_name, row_index, 9)
    local online = client_player:QueryRecord(rec_name, row_index, 8)
    add_info_to_grid(grid, name, power_level, guild, num1 + num2, scene_id, online, rec_name)
  end
  rec_name = "rec_buddy"
  row_count = client_player:GetRecordRows(rec_name)
  for row_index = 0, row_count - 1 do
    local name = client_player:QueryRecord(rec_name, row_index, 1)
    local power_level = client_player:QueryRecord(rec_name, row_index, 4)
    local guild = client_player:QueryRecord(rec_name, row_index, 6)
    local num1 = nx_number(client_player:QueryRecord(rec_name, row_index, 11))
    local num2 = nx_number(client_player:QueryRecord(rec_name, row_index, 12))
    local scene_id = client_player:QueryRecord(rec_name, row_index, 9)
    local online = client_player:QueryRecord(rec_name, row_index, 8)
    add_info_to_grid(grid, name, power_level, guild, num1 + num2, scene_id, online, rec_name)
  end
  grid:SortRowsByInt(3, true)
  local count = grid.RowCount
  local max_num = nx_number(get_ini_prop(FILE_SNS_STYLE, "max_num", "num", "30"))
  if count > max_num then
    count = max_num
  end
  if count <= 0 then
    form.groupbox_yinxiang1.BackImage = "gui\\special\\sns_new\\new_shijiesil\\hmyhy.png"
    return
  else
    form.groupbox_yinxiang1.BackImage = "gui\\special\\sns_new\\sns_newworld\\back_friend.png"
  end
  form.groupbox_yinxiang1:DeleteAll()
  for row_index = 0, count - 1 do
    local name = grid:GetGridText(row_index, 0)
    local num = grid:GetGridText(row_index, 3)
    add_info_yingxiang(form.groupbox_yinxiang1, 0, row_index, name, nx_number(num))
  end
  grid:SortRowsByInt(5, false)
  grid:EndUpdate()
end
function reset_enemy_info()
  local form = nx_value("form_stage_main\\form_chat_system\\form_new_friend_list")
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local grid = form.textgrid_enemy
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  grid.ColCount = 6
  grid.ColWidths = "130, 130, 130, 140, 130, 0"
  local rec_name = "rec_enemy"
  local row_count = client_player:GetRecordRows(rec_name)
  for row_index = 0, row_count - 1 do
    local name = client_player:QueryRecord(rec_name, row_index, 1)
    local power_level = client_player:QueryRecord(rec_name, row_index, 4)
    local guild = client_player:QueryRecord(rec_name, row_index, 6)
    local num1 = nx_number(client_player:QueryRecord(rec_name, row_index, 11))
    local scene_id = client_player:QueryRecord(rec_name, row_index, 9)
    local online = client_player:QueryRecord(rec_name, row_index, 8)
    add_info_to_grid(grid, name, power_level, guild, num1, scene_id, online, rec_name)
  end
  rec_name = "rec_blood"
  row_count = client_player:GetRecordRows(rec_name)
  for row_index = 0, row_count - 1 do
    local name = client_player:QueryRecord(rec_name, row_index, 1)
    local power_level = client_player:QueryRecord(rec_name, row_index, 4)
    local guild = client_player:QueryRecord(rec_name, row_index, 6)
    local num1 = nx_number(client_player:QueryRecord(rec_name, row_index, 11))
    local num2 = nx_number(client_player:QueryRecord(rec_name, row_index, 12))
    local scene_id = client_player:QueryRecord(rec_name, row_index, 9)
    local online = client_player:QueryRecord(rec_name, row_index, 8)
    add_info_to_grid(grid, name, power_level, guild, num1 + num2, scene_id, online, rec_name)
  end
  local count = grid.RowCount
  local max_num = nx_number(get_ini_prop(FILE_SNS_STYLE, "max_num", "num", "30"))
  if count > max_num then
    count = max_num
  end
  if count <= 0 then
    form.groupbox_yinxiang2.BackImage = "gui\\special\\sns_new\\new_shijiesil\\hmydr.png"
    return
  else
    form.groupbox_yinxiang2.BackImage = "gui\\special\\sns_new\\sns_newworld\\back_enemy.png"
  end
  form.groupbox_yinxiang2:DeleteAll()
  for row_index = 0, count - 1 do
    local name = grid:GetGridText(row_index, 0)
    local num = grid:GetGridText(row_index, 3)
    add_info_yingxiang(form.groupbox_yinxiang2, 1, row_index, name, nx_number(num))
  end
  grid:SortRowsByInt(5, false)
  grid:EndUpdate()
end
function get_client_player()
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    return game_client:GetPlayer()
  end
  return nx_null()
end
function add_info_to_grid(grid, name, power_level, guild, nums, scene_id, online, rec_name)
  local form_main_chat = nx_value("form_main_chat")
  if not nx_is_valid(form_main_chat) then
    return
  end
  local row = grid:InsertRow(grid.RowCount)
  scene_id = nx_string(scene_id)
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  power_level = karmamgr:ParseColValue(4, nx_string(power_level))
  grid:SetGridText(row, 0, nx_widestr(name))
  grid:SetGridText(row, 1, util_text("desc_" .. power_level))
  grid:SetGridText(row, 2, guild)
  grid:SetGridText(row, 3, nx_widestr(nx_int(nums)))
  if form_main_chat:IsNewScene(nx_int(scene_id)) then
    grid:SetGridText(row, 4, util_text("ui_scene_" .. scene_id))
  else
    grid:SetGridText(row, 4, util_text("sns_newCJ_001"))
  end
  local index = 0
  if "90" == scene_id then
    index = 1
  elseif "91" == scene_id then
    index = 2
  elseif "354" == scene_id then
    index = 3
  elseif "355" == scene_id then
    index = 4
  elseif "365" == scene_id then
    index = 5
  elseif "366" == scene_id then
    index = 6
  elseif "367" == scene_id then
    index = 7
  elseif "368" == scene_id then
    index = 8
  else
    index = 1000 + nx_int(scene_id)
  end
  grid:SetGridText(row, 5, nx_widestr(nx_int(index)))
  if nx_string(online) ~= "0" then
    grid:SetGridForeColor(row, 0, "255,190,190,190")
    grid:SetGridForeColor(row, 1, "255,190,190,190")
    grid:SetGridForeColor(row, 2, "255,190,190,190")
    grid:SetGridForeColor(row, 3, "255,190,190,190")
    grid:SetGridForeColor(row, 4, "255,190,190,190")
  elseif rec_name == "rec_blood" then
    grid:SetGridForeColor(row, 0, "255,255,0,0")
    grid:SetGridForeColor(row, 1, "255,255,0,0")
    grid:SetGridForeColor(row, 2, "255,255,0,0")
    grid:SetGridForeColor(row, 3, "255,255,0,0")
    grid:SetGridForeColor(row, 4, "255,255,0,0")
  end
end
function add_info_yingxiang(groupbox, type, index, name, num)
  local form_main_chat = nx_value("form_main_chat")
  if not nx_is_valid(form_main_chat) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local rank_no = form_main_chat:IsInRank(name)
  local back = ""
  if nx_int(rank_no) == nx_int(1) then
    back = get_ini_prop(FILE_SNS_STYLE, "back_image", "2", "")
  elseif nx_int(rank_no) >= nx_int(2) and nx_int(rank_no) <= nx_int(3) then
    back = get_ini_prop(FILE_SNS_STYLE, "back_image", "3", "")
  elseif nx_int(rank_no) >= nx_int(4) and nx_int(rank_no) <= nx_int(10) then
    back = get_ini_prop(FILE_SNS_STYLE, "back_image", "4", "")
  elseif nx_int(rank_no) == nx_int(0) then
    back = get_ini_prop(FILE_SNS_STYLE, "back_image", "1", "")
  else
    back = "gui\\special\\sns_new\\cbtn_sub2_out.png"
  end
  local font, colour, key_font, key_colour
  if type == 0 then
    key_font = "font"
    key_colour = "colour_friend"
  else
    key_font = "font"
    key_colour = "colour_enemy"
  end
  if 0 <= num and num < 50 then
    font = get_ini_prop(FILE_SNS_STYLE, key_font, "1", "")
    colour = get_ini_prop(FILE_SNS_STYLE, key_colour, "1", "")
  elseif 50 <= num and num < 300 then
    font = get_ini_prop(FILE_SNS_STYLE, key_font, "2", "")
    colour = get_ini_prop(FILE_SNS_STYLE, key_colour, "2", "")
  elseif 300 <= num and num < 1000 then
    font = get_ini_prop(FILE_SNS_STYLE, key_font, "3", "")
    colour = get_ini_prop(FILE_SNS_STYLE, key_colour, "3", "")
  elseif 1000 <= num and num < 2000 then
    font = get_ini_prop(FILE_SNS_STYLE, key_font, "4", "")
    colour = get_ini_prop(FILE_SNS_STYLE, key_colour, "4", "")
  elseif 2000 <= num and num < 100000 then
    font = get_ini_prop(FILE_SNS_STYLE, key_font, "5", "")
    colour = get_ini_prop(FILE_SNS_STYLE, key_colour, "5", "")
  end
  local left = get_ini_prop(FILE_SNS_STYLE, nx_string(index), "left", "")
  local top = get_ini_prop(FILE_SNS_STYLE, nx_string(index), "top", "")
  local lab = gui:Create("Label")
  groupbox:Add(lab)
  lab.Text = name
  lab.HintText = name
  lab.Font = font
  lab.ForeColor = colour
  lab.BackImage = back
  lab.Transparent = false
  lab.ClickEvent = true
  lab.DrawMode = "FitWindow"
  lab.Left = nx_number(left)
  lab.Top = nx_number(top)
  lab.Width = lab.TextWidth
  lab.Height = 25
  nx_bind_script(lab, nx_current())
  nx_callback(lab, "on_click", "on_lab_name_click")
end
function on_lab_name_click(lab)
  nx_execute("custom_sender", "custom_send_get_player_game_info", lab.Text)
end
function open_form()
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
    return
  end
  local form = nx_value("form_stage_main\\form_chat_system\\form_new_friend_list")
  if nx_is_valid(form) then
    form:Close()
  else
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_chat_system\\form_new_friend_list", true, false)
    if not nx_is_valid(form) then
      return false
    end
    form:Show()
  end
  return true
end
function find_player_in_list(grid, name)
  local count = grid.RowCount
  for index = 0, count - 1 do
    if name == grid:GetGridText(index, 0) then
      grid:SelectRow(index)
      return index
    end
  end
  return -1
end
function on_btn_find_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = form.ipt_input.Text
  if name == nx_widestr("") then
    return
  end
  if form.groupbox_all.Visible then
    local grid = form.textgrid_friend
    if not form.textgrid_friend.Visible then
      grid = form.textgrid_enemy
    end
    local row = find_player_in_list(grid, name)
    if row ~= -1 then
      nx_execute("custom_sender", "custom_send_get_player_game_info", name)
    else
      nx_execute("custom_sender", "custom_sns_search_friend", name)
    end
  else
    local row = find_player_in_list(form.textgrid_friend, name)
    if row ~= -1 then
      nx_execute("custom_sender", "custom_send_get_player_game_info", name)
    else
      row = find_player_in_list(form.textgrid_enemy, name)
      if row ~= -1 then
        nx_execute("custom_sender", "custom_send_get_player_game_info", name)
      else
        nx_execute("custom_sender", "custom_sns_search_friend", name)
      end
    end
  end
end
function on_btn_friend_click(btn)
  local form = btn.ParentForm
  local new_time = os.time()
  if nx_find_custom(form, "refresh_time") and new_time - form.refresh_time <= 0.1 then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sns_new_05"), 2)
    end
    return
  end
  form.refresh_time = new_time
  reset_friend_info()
  form.lbl_shuzhi.BackImage = "gui\\special\\sns_new\\sns_newworld\\qmd.png"
  form.groupbox_all.Visible = true
  form.textgrid_friend.Visible = true
  form.textgrid_enemy.Visible = false
  save_show_form_to_file(form, "2")
end
function on_btn_enemy_click(btn)
  local form = btn.ParentForm
  local new_time = os.time()
  if nx_find_custom(form, "refresh_time") and new_time - form.refresh_time <= 0.1 then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sns_new_05"), 2)
    end
    return
  end
  form.refresh_time = new_time
  reset_enemy_info()
  form.lbl_shuzhi.BackImage = "gui\\special\\sns_new\\sns_newworld\\chd.png"
  form.groupbox_all.Visible = true
  form.textgrid_friend.Visible = false
  form.textgrid_enemy.Visible = true
  save_show_form_to_file(form, "1")
end
function on_btn_yinxiang_click(btn)
  local form = btn.ParentForm
  form.groupbox_yinxiang1.Visible = true
  form.groupbox_yinxiang2.Visible = true
  form.groupbox_all.Visible = false
  form.groupbox_find.Visible = false
  save_show_form_to_file(form, "0")
end
function on_btn_all_click(btn)
  local form = btn.ParentForm
  form.groupbox_yinxiang1.Visible = false
  form.groupbox_yinxiang2.Visible = false
  form.groupbox_all.Visible = true
  form.textgrid_friend.Visible = true
  form.textgrid_enemy.Visible = false
  form.groupbox_find.Visible = true
  save_show_form_to_file(form, "2")
end
function on_textgrid_double_click_grid(grid, row, col)
  if row < 0 then
    local form_new_friend_menu = nx_value("form_stage_main\\form_chat_system\\form_new_friend_menu")
    if nx_is_valid(form_new_friend_menu) then
      form_new_friend_menu:Close()
    end
    return
  end
  local name = grid:GetGridText(row, 0)
  nx_execute("form_stage_main\\form_relation\\form_new_world_player_info", "scene_jhpk_chat", name)
end
function rest_friend(form)
  local form_friend_list = nx_value("form_stage_main\\form_chat_system\\form_new_friend_list")
  if nx_is_valid(form_friend_list) then
    nx_execute("custom_sender", "custom_query_enemy_info", 0, 0)
    nx_execute("custom_sender", "custom_query_enemy_info", 0, 1)
    reset_friend_info()
  end
end
function on_btn_show_tips_click(btn)
  local form = btn.ParentForm
  form.groupbox_tips.Visible = true
  btn.Visible = false
  form.btn_hide_tips.Visible = true
end
function on_btn_hide_tips_click(btn)
  local form = btn.ParentForm
  form.groupbox_tips.Visible = false
  btn.Visible = false
  form.btn_show_tips.Visible = true
end
function save_show_form_to_file(form, flag)
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\form_main.ini"
  ini:LoadFromFile()
  ini:WriteString("form_new_friend_list", "show_form", nx_string(flag))
  ini:SaveToFile()
  nx_destroy(ini)
end
function init_show_form(form)
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\form_main.ini"
  ini:LoadFromFile()
  local flag = ini:ReadString("form_new_friend_list", "show_form", "0")
  if flag == "0" then
    on_btn_yinxiang_click(form.btn_yinxiang)
  elseif flag == "1" then
    on_btn_all_click(form.btn_all)
    on_btn_enemy_click(form.btn_enemy)
  elseif flag == "2" then
    on_btn_all_click(form.btn_all)
    on_btn_friend_click(form.btn_friend)
  end
  nx_destroy(ini)
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_chat_system\\form_new_friend_list")
  if nx_is_valid(form) then
    form:Close()
  end
end
