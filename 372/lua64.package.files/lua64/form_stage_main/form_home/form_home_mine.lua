require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("share\\view_define")
require("custom_handler")
col_cur_stage = 1
col_max_stage = 2
col_prize = 3
col_count = 3
server_custom_msg_open = 0
server_custom_msg_close = 1
server_custom_msg_refresh = 2
server_custom_msg_iscontinue = 3
sea_home = 109
local FORM = "form_stage_main\\form_home\\form_home_mine"
client_submsg_doing_work = 0
client_submsg_get_prize = 1
client_submsg_lock_item = 2
client_submsg_unlock_item = 3
client_submsg_clear_minebox = 4
client_submsg_exdoing_work = 5
local CLIENT_CUSTOMMSG_HOME_MINE = 264
tier_info = {}
local extra_prize_tips = {
  [1] = "home_mine_001",
  [2] = "home_mine_002",
  [3] = "home_mine_003",
  [4] = "home_mine_004",
  [5] = "home_mine_005"
}
local tier_info_tips = {
  [1] = "home_mine_006",
  [2] = "home_mine_007",
  [3] = "home_mine_008",
  [4] = "home_mine_009",
  [5] = "home_mine_010"
}
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2 + (gui.Height - form.Height) / 4
  form.sel_view = -1
  form.sel_index = -1
  form.home_id = 0
  form.level = 0
  form.iswork = 0
  form.work_tier = 0
  form.time = 0
  form.exprize_index = 1
  form.item_count = 0
  form.select_tier = 0
  local info = gui.TextManager:GetText("home_mine_011")
  form.mltbox_info.HtmlText = nx_widestr(info)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_HOME_MINE_BOX, form.imagegrid_extra_prize, FORM, "on_view_operat")
end
function on_main_form_close(form)
  nx_execute("custom_sender", "custom_send_home_mine", nx_int(CLIENT_CUSTOMMSG_HOME_MINE), nx_int(client_submsg_clear_minebox))
  nx_destroy(form)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_server(sub_msg, ...)
  if nx_int(sub_msg) == nx_int(server_custom_msg_open) then
    local home_mine = nx_execute("util_gui", "util_get_form", FORM, true, false)
    home_mine:Show()
    local form = nx_value(FORM)
    if not nx_is_valid(form) then
      return
    end
    form.home_id = nx_int(arg[1])
    form.exprize_index = nx_int(arg[2])
    form.iswork = nx_int(arg[3])
    form.level = nx_int(arg[4])
    form.work_tier = nx_int(arg[5])
    form.time = nx_int(arg[6])
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    clear_form_date(form)
    refresh_form(form, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(server_custom_msg_close) then
    local form = nx_value(FORM)
    if not nx_is_valid(form) then
      return
    end
    form:Close()
  elseif nx_int(sub_msg) == nx_int(server_custom_msg_refresh) then
    local form = nx_value(FORM)
    if not nx_is_valid(form) then
      return
    end
    form.home_id = nx_int(arg[1])
    form.exprize_index = nx_int(arg[2])
    form.iswork = nx_int(arg[3])
    form.level = nx_int(arg[4])
    form.work_tier = nx_int(arg[5])
    form.time = nx_int(arg[6])
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    clear_form_date(form)
    refresh_form(form, unpack(arg))
  elseif nx_int(sub_msg) == nx_int(server_custom_msg_iscontinue) then
    local form = nx_value(FORM)
    if not nx_is_valid(form) then
      return
    end
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("sys_homemine_003")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    dialog.relogin_btn.Visible = false
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_send_home_mine", nx_int(CLIENT_CUSTOMMSG_HOME_MINE), nx_int(client_submsg_doing_work), nx_int(form.select_tier))
    end
  end
end
function clear_form_date(form)
  local gui = nx_value("gui")
  form.imagegrid_prize:Clear()
  form.lbl_work_num.Text = nx_widestr("1/1")
  form.lbl_sur_num.Text = nx_widestr("")
  form.lbl_sur_time.Text = nx_widestr("")
  form.lbl_rate.Text = nx_widestr("")
  for i = 1, 5 do
    local child_name = string.format("%s_%s", nx_string("hill"), nx_string(i))
    local child = form.groupbox_hill:Find(child_name)
    child.Visible = false
  end
  form.groupbox_hill.Visible = false
  for i = 1, 5 do
    local child_name = string.format("%s_%s", nx_string("sea"), nx_string(i))
    local child = form.groupbox_sea:Find(child_name)
    child.Visible = false
  end
  form.groupbox_sea.Visible = false
end
function get_mine_count(form)
  local count = 0
  if nx_int(form.level) == nx_int(1) then
    count = 2
  elseif nx_int(form.level) == nx_int(2) then
    count = 4
  else
    count = 5
  end
  return count
end
function show_groupbox_hill(form)
  local count = get_mine_count(form)
  form.groupbox_hill.Visible = true
  for i = 1, count do
    local child_name = string.format("%s_%s", nx_string("hill"), nx_string(i))
    local child = form.groupbox_hill:Find(child_name)
    if nx_int(form.exprize_index) == nx_int(i) then
      form.btn_exprize.Left = child.Left + form.groupbox_hill.Left + child.Width / 2
      form.btn_exprize.Top = child.Top + form.groupbox_hill.Top + child.Height / 2
    end
    child.Visible = true
  end
  if form.exprize_index == 1 then
    form.btn_exprize.Left = form.btn_exprize.Left + 20
  elseif form.exprize_index == 2 then
    form.btn_exprize.Left = form.btn_exprize.Left - 50
    form.btn_exprize.Top = form.btn_exprize.Top - 40
  elseif form.exprize_index == 3 then
    form.btn_exprize.Left = form.btn_exprize.Left - 40
    form.btn_exprize.Top = form.btn_exprize.Top - 30
  elseif form.exprize_index == 4 then
    form.btn_exprize.Left = form.btn_exprize.Left - 20
  elseif form.exprize_index == 5 then
    form.btn_exprize.Left = form.btn_exprize.Left - 20
    form.btn_exprize.Top = form.btn_exprize.Top + 10
  end
end
function show_groupbox_sea(form)
  local count = get_mine_count(form)
  form.groupbox_sea.Visible = true
  for i = 1, count do
    local child_name = string.format("%s_%s", nx_string("sea"), nx_string(i))
    local child = form.groupbox_sea:Find(child_name)
    if nx_int(form.exprize_index) == nx_int(i) then
      form.btn_exprize.Left = child.Left + form.groupbox_sea.Left + child.Width / 2
      form.btn_exprize.Top = child.Top + form.groupbox_sea.Top + child.Height / 2
    end
    child.Visible = true
  end
  if form.exprize_index == 1 then
    form.btn_exprize.Left = form.btn_exprize.Left + 20
  elseif form.exprize_index == 2 then
    form.btn_exprize.Left = form.btn_exprize.Left - 30
    form.btn_exprize.Top = form.btn_exprize.Top - 70
  elseif form.exprize_index == 3 then
    form.btn_exprize.Left = form.btn_exprize.Left - 20
    form.btn_exprize.Top = form.btn_exprize.Top - 10
  elseif form.exprize_index == 4 then
    form.btn_exprize.Left = form.btn_exprize.Left - 20
  elseif form.exprize_index == 5 then
    form.btn_exprize.Left = form.btn_exprize.Left - 40
    form.btn_exprize.Top = form.btn_exprize.Top + 10
  end
end
function refresh_form(form, ...)
  local gui = nx_value("gui")
  tier_info = arg
  if nx_int(form.iswork) == nx_int(1) then
    form.lbl_work_num.Text = nx_widestr("0/0")
    if nx_int(form.time) > nx_int(0) then
      form.lbl_sur_time.Text = nx_widestr(gui.TextManager:GetFormatText("ui_homemine_surtime", nx_int(form.time)))
    else
      form.lbl_sur_time.Text = nx_widestr(gui.TextManager:GetText("ui_homemine_finish"))
    end
  end
  if nx_int(form.work_tier) > nx_int(0) then
    form.lbl_sur_num.Text = nx_widestr(form.work_tier)
  end
  if nx_int(form.home_id) == nx_int(sea_home) then
    show_groupbox_sea(form)
  else
    show_groupbox_hill(form)
  end
  refresh_tier_info(form)
end
function on_imagegrid_prize_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_prize_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
  if 0 >= table.getn(table_prop_name) then
    return
  end
  table_prop_value.ConfigID = nx_string(prize_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", "task_grid_data")
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_set_custom(grid.Data, "is_static", true)
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
  grid.Data:ClearChild()
end
function on_btn_doing_work_click(btn)
  local form = btn.ParentForm
  if form.btn_exprize.Checked == true then
    nx_execute("custom_sender", "custom_send_home_mine", nx_int(CLIENT_CUSTOMMSG_HOME_MINE), nx_int(client_submsg_exdoing_work), nx_int(form.select_tier), nx_int(form.item_count))
  else
    nx_execute("custom_sender", "custom_send_home_mine", nx_int(CLIENT_CUSTOMMSG_HOME_MINE), nx_int(client_submsg_doing_work), nx_int(form.select_tier))
  end
end
function on_btn_getprize_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_send_home_mine", nx_int(CLIENT_CUSTOMMSG_HOME_MINE), nx_int(client_submsg_get_prize))
end
function on_hill_1_click(btn)
  local form = btn.ParentForm
  form.select_tier = 1
  refresh_tier_info(form)
  refresh_info(form)
  unlock_item(form)
end
function on_hill_2_click(btn)
  local form = btn.ParentForm
  form.select_tier = 2
  refresh_tier_info(form)
  refresh_info(form)
  unlock_item(form)
end
function on_hill_3_click(btn)
  local form = btn.ParentForm
  form.select_tier = 3
  refresh_tier_info(form)
  refresh_info(form)
  unlock_item(form)
end
function on_hill_4_click(btn)
  local form = btn.ParentForm
  form.select_tier = 4
  refresh_tier_info(form)
  refresh_info(form)
  unlock_item(form)
end
function on_hill_5_click(btn)
  local form = btn.ParentForm
  form.select_tier = 5
  refresh_tier_info(form)
  refresh_info(form)
  unlock_item(form)
end
function on_sea_1_click(btn)
  local form = btn.ParentForm
  form.select_tier = 1
  refresh_tier_info(form)
  refresh_info(form)
  unlock_item(form)
end
function on_sea_2_click(btn)
  local form = btn.ParentForm
  form.select_tier = 2
  refresh_tier_info(form)
  refresh_info(form)
  unlock_item(form)
end
function on_sea_3_click(btn)
  local form = btn.ParentForm
  form.select_tier = 3
  refresh_tier_info(form)
  refresh_info(form)
  unlock_item(form)
end
function on_sea_4_click(btn)
  local form = btn.ParentForm
  form.select_tier = 4
  refresh_tier_info(form)
  refresh_info(form)
  unlock_item(form)
end
function on_sea_5_click(btn)
  local form = btn.ParentForm
  form.select_tier = 5
  refresh_tier_info(form)
  refresh_info(form)
  unlock_item(form)
end
function refresh_tier_info(form)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local size = nx_number(table.getn(tier_info)) / nx_number(col_count)
  for i = 1, size do
    if nx_int(i) == nx_int(form.select_tier) then
      local cur_stage = nx_widestr(tier_info[(i - 1) * col_count + col_cur_stage])
      local max_stage = nx_widestr(tier_info[(i - 1) * col_count + col_max_stage])
      local config = nx_string(tier_info[(i - 1) * col_count + col_prize])
      form.lbl_rate.Text = nx_widestr(nx_string(cur_stage) .. "/" .. nx_string(max_stage))
      local photo = ItemQuery:GetItemPropByConfigID(config, "Photo")
      form.imagegrid_prize:AddItem(0, photo, nx_widestr(config), 1, 0)
    end
  end
end
function on_imagegrid_extra_prize_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_extra_prize_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function get_photo_amont(item)
  local photo = ""
  local amount = 0
  if nx_is_valid(item) then
    photo = nx_execute("util_static_data", "query_equip_photo_by_sex", item)
    amount = 1
  end
  return photo, amount
end
function on_imagegrid_extra_prize_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local gui = nx_value("gui")
  local gameHand = gui.GameHand
  if gameHand:IsEmpty() then
    return
  end
  if form.btn_exprize.Checked == false then
    gameHand:ClearHand()
    return
  end
  local src_viewid = nx_int(gui.GameHand.Para1)
  local src_pos = nx_int(gui.GameHand.Para2)
  if form.sel_view == src_viewid and form.sel_index == src_pos then
    gameHand:ClearHand()
    return
  end
  if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid)) then
    gameHand:ClearHand()
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
  if not nx_is_valid(item) then
    gameHand:ClearHand()
    return
  end
  local lock_status = item:QueryProp("LockStatus")
  if 0 < lock_status then
    gameHand:ClearHand()
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_inputbox", true, false)
  dialog:ShowModal()
  dialog.info_label.Text = gui.TextManager:GetText("sys_bonfire_008")
  local res, text = nx_wait_event(100000000, dialog, "input_box_return")
  local amount = 1
  if res == "ok" then
    amount = nx_number(text)
    local item_count = item:QueryProp("Amount")
    if nx_number(amount) > nx_number(item_count) then
      custom_sysinfo(1, 1, 1, 2, "sys_bonfire_009")
      gameHand:ClearHand()
      return
    end
    form.item_count = amount
    form.sel_view = src_viewid
    form.sel_index = src_pos
    gameHand:ClearHand()
    nx_execute("custom_sender", "custom_send_home_mine", nx_int(CLIENT_CUSTOMMSG_HOME_MINE), nx_int(client_submsg_lock_item), nx_int(src_viewid), nx_int(src_pos), nx_int(index))
  end
end
function on_imagegrid_extra_prize_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  unlock_item(form)
end
function unlock_item(form)
  nx_execute("custom_sender", "custom_send_home_mine", nx_int(CLIENT_CUSTOMMSG_HOME_MINE), nx_int(client_submsg_unlock_item), nx_int(0))
  form.sel_view = -1
  form.sel_index = -1
  form.item_count = 0
end
function on_view_operat(grid, optype, view_ident, index, prop_name)
  if nx_string(optype) == "updateitem" then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  local form = nx_value(FORM)
  if not nx_is_valid(form) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  if optype == "createview" then
    GoodsGrid:ViewRefreshGrid(grid)
  elseif optype == "deleteview" then
    GoodsGrid:ViewRefreshGrid(grid)
  elseif optype == "additem" then
    local item = view:GetViewObj(nx_string(index))
    if not nx_is_valid(item) then
      return
    end
    local photo, amount = get_photo_amont(item)
    if "" == photo then
      return
    end
    local configid = item:QueryProp("ConfigID")
    local item_count = item:QueryProp("Amount")
    index = index - 1
    grid:AddItem(index, photo, nx_widestr(configid), form.item_count, 0)
  elseif optype == "delitem" then
    index = index - 1
    grid:DelItem(index)
  elseif optype == "updateitemprop" then
  end
  return 1
end
function on_btn_exprize_get_capture(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local info = gui.TextManager:GetText(nx_string(extra_prize_tips[form.exprize_index]))
  btn.HintText = nx_widestr(info)
end
function on_btn_exprize_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function refresh_info(form)
  form.mltbox_info.HtmlText = nx_widestr("")
  local gui = nx_value("gui")
  local info = gui.TextManager:GetText(nx_string(tier_info_tips[form.select_tier]))
  form.mltbox_info.HtmlText = nx_widestr(info)
end
