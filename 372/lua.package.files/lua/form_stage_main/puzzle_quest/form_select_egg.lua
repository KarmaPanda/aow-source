g_item_type = {
  "red",
  "gold",
  "green"
}
g_item_configid = {
  red = "ydhd_lidan_001",
  gold = "ydhd_lidan_002",
  green = "ydhd_lidan_003"
}
g_item_image = {
  red = "gui\\special\\life\\puzzle_quest\\selectegg\\xd_fuqi.png",
  gold = "gui\\special\\life\\puzzle_quest\\selectegg\\xd_jinlong.png",
  green = "gui\\special\\life\\puzzle_quest\\selectegg\\xd_feicui.png"
}
g_max_egg = 5
g_need_egg_items = {
  "ydhd_lidan_001",
  "ydhd_lidan_002",
  "ydhd_lidan_003",
  "item_zd_yinchui",
  "item_zd_jinchui",
  "item_zd_yuchui"
}
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = gui.Desktop.Width / 2 - form.Width / 2
  form.Top = gui.Desktop.Height / 2 - form.Height / 2
  form.btn_green.color = "green"
  form.btn_red.color = "red"
  form.btn_gold.color = "gold"
  form.self_red = 0
  form.self_green = 0
  form.self_gold = 0
  form.select_red = 0
  form.select_green = 0
  form.select_gold = 0
  form.groupbox_help.Visible = false
  set_egg_times(form)
  set_init_info(form)
  refresh_btn_enable(form)
  set_need_egg_items(form)
end
function set_egg_times(form)
  local game_client = nx_value("game_client")
  local client_scene_obj = game_client:GetPlayer()
  local egg_times = client_scene_obj:QueryProp("MaxEggTime")
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\GemEggConfig.ini")
  local max_egg_times = 0
  if nx_is_valid(ini) then
    max_egg_times = ini:ReadInteger(0, "MaxNumber", 0)
  end
  local remnant_time = max_egg_times - egg_times
  if remnant_time < 0 then
    remnant_time = 0
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_ydhd_zdcs")
  gui.TextManager:Format_AddParam(nx_int(remnant_time))
  local text = gui.TextManager:Format_GetText()
  form.lbl_zdcs.Text = text
end
function set_init_info(form)
  local type_items = {
    [1] = form.btn_green,
    [2] = form.btn_gold,
    [3] = form.btn_red
  }
  for index, item in pairs(type_items) do
    if nx_find_custom(item, "color") then
      local lbl = form:Find("lbl_" .. item.color)
      if nx_is_valid(lbl) then
        local count = get_item_in_bag_count(g_item_configid[item.color])
        if 0 < count then
          nx_set_custom(form, "self_" .. item.color, count)
          lbl.Text = nx_widestr(count)
        end
      end
    end
  end
end
function get_item_in_bag_count(configid)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return 0
  end
  local count = goods_grid:GetItemCount(configid)
  return count
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_exit_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_info_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form.groupbox_help.Visible = not form.groupbox_help.Visible
  end
end
function on_btn_help_click(btn)
  local help_form = nx_value("form_stage_main\\puzzle_quest\\form_puzzle_egg_help")
  if nx_is_valid(help_form) then
    help_form.Visible = not help_form.Visible
  else
    help_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\puzzle_quest\\form_puzzle_egg_help", true, false)
    if nx_is_valid(help_form) then
      local gui = nx_value("gui")
      gui.Desktop:ToFront(help_form)
      help_form:Show()
    end
  end
  help_form.no_need_motion_alpha = false
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not (nx_find_custom(form, "select_green") and nx_find_custom(form, "select_gold")) or not nx_find_custom(form, "select_red") then
    return
  end
  if form.select_red ~= 0 or form.select_green ~= 0 or form.select_gold ~= 0 then
    nx_execute("custom_sender", "custom_gem_smahing_egg_game", form.select_green, form.select_gold, form.select_red)
  end
  local parent_ctrl = form.Parent
  if nx_is_valid(parent_ctrl) then
    local parent_form = parent_ctrl.ParentForm
    if nx_is_valid(parent_form) and nx_script_name(parent_form) == "form_stage_main\\form_dbomall\\form_dbomall" then
      parent_form:Close()
    else
      form:Close()
    end
  else
    form:Close()
  end
end
function on_btn_egg_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(btn, "color") then
    return
  end
  local index = find_first_pos(form)
  if index < 0 or index > g_max_egg - 1 then
    return
  end
  form.imagegrid_1:AddItem(nx_int(index), g_item_image[btn.color], nx_widestr(btn.color), nx_int(1), nx_int(-1))
  if not nx_find_custom(form, "self_" .. btn.color) then
    return
  end
  local self_egg_num = nx_custom(form, "self_" .. btn.color)
  nx_set_custom(form, "self_" .. btn.color, self_egg_num - 1)
  local select_egg_num = nx_custom(form, "select_" .. btn.color)
  nx_set_custom(form, "select_" .. btn.color, select_egg_num + 1)
  local lbl = form:Find("lbl_" .. btn.color)
  if nx_is_valid(lbl) then
    lbl.Text = nx_widestr(self_egg_num - 1)
  end
  refresh_btn_enable(form)
end
function refresh_btn_enable(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, table.getn(g_item_type) do
    if nx_find_custom(form, "self_" .. g_item_type[i]) then
      local self_egg_num = nx_custom(form, "self_" .. g_item_type[i])
      local btn = form:Find("btn_" .. g_item_type[i])
      if nx_is_valid(btn) then
        if self_egg_num <= 0 then
          btn.Enabled = false
        else
          btn.Enabled = true
        end
      end
    end
  end
  if not (nx_find_custom(form, "select_green") and nx_find_custom(form, "select_gold")) or not nx_find_custom(form, "select_red") then
    return
  end
  if form.select_green ~= 0 or form.select_gold ~= 0 or form.select_red ~= 0 then
    form.btn_start.Enabled = true
  else
    form.btn_start.Enabled = false
  end
end
function find_first_pos(form)
  if nx_is_valid(form) then
    for i = 1, g_max_egg do
      if form.imagegrid_1:IsEmpty(i - 1) then
        return i - 1
      end
    end
  end
  return -1
end
function on_imagegrid_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if grid:IsEmpty(index) then
    return
  end
  local item_name = nx_string(grid:GetItemName(index))
  grid:DelItem(index)
  local self_egg_num = nx_custom(form, "self_" .. item_name)
  nx_set_custom(form, "self_" .. item_name, self_egg_num + 1)
  local select_egg_num = nx_custom(form, "select_" .. item_name)
  nx_set_custom(form, "select_" .. item_name, select_egg_num - 1)
  local lbl = form:Find("lbl_" .. item_name)
  if nx_is_valid(lbl) then
    lbl.Text = nx_widestr(self_egg_num + 1)
  end
  refresh_btn_enable(form)
end
function on_imagegrid_egg_need_mousein_grid(grid, index)
  local table_count = table.getn(g_need_egg_items)
  if nx_int(index + 1) > nx_int(table_count) then
    return
  end
  local config_id = g_need_egg_items[index + 1]
  if config_id == nil or nx_string(config_id) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = config_id
  item.ItemType = ItemQuery:GetItemPropByConfigID(nx_string(configid), "ItemType")
  item.BindStatus = ItemQuery:GetItemPropByConfigID(nx_string(configid), "BindStatus")
  nx_execute("tips_game", "show_goods_tip", item, x, y, 0, 0, grid.ParentForm)
end
function on_imagegrid_egg_need_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function set_need_egg_items(form)
  local row_num = form.imagegrid_egg_need.RowNum
  local col_num = form.imagegrid_egg_need.ClomnNum
  local nCount = row_num * col_num
  local table_count = table.getn(g_need_egg_items)
  for i = 1, nx_number(nCount) do
    if i <= table_count then
      local config_id = g_need_egg_items[i]
      local photo = get_photo(config_id)
      form.imagegrid_egg_need:AddItem(nx_int(i - 1), photo, "", 1, -1)
    end
  end
end
function get_photo(config_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  local photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo"))
  local sex = client_player:QueryProp("Sex")
  if 0 ~= sex then
    local tmp_photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "FemalePhoto"))
    if nil ~= tmp_photo and "" ~= tmp_photo then
      photo = tmp_photo
    end
  end
  return photo
end
