require("share\\view_define")
require("share\\itemtype_define")
require("define\\gamehand_type")
require("util_gui")
require("util_functions")
require("custom_sender")
require("role_composite")
require("util_static_data")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
function refresh_form(form)
  if is_jh_scene() or is_in_home() then
    form.Visible = false
  end
end
function main_form_init(form)
  form.Fixed = true
  form.select_page = 1
  form.select_grid = ""
  form.curPageNum = 1
  form.nMaxRecordNum = 0
  form.nPageRecordNum = 6
  form.nMaxPageNum = 10
  form.select_sable_config = ""
  form.select_sable_id = -1
  form.sable_cur_actor2 = nil
end
function main_form_open(form)
  if is_jh_scene() or is_in_home() then
    form.Visible = false
  end
  form.btn_call.Visible = true
  refresh_pageinfo(form, form.curPageNum)
  local ImageGird = form.groupbox_sable:Find("ImageMountGrid1")
  if nx_is_valid(ImageGird) then
    on_ImageMountGrid_rightclick_grid(ImageGird, nx_int(0))
    ImageGird:SetSelectItemIndex(nx_int(0))
    ImageGird.DrawMouseSelect = "xuanzekuang"
  end
  data_bind_prop(form)
end
function main_form_close(form)
  del_data_bind_prop(form)
  nx_destroy(form)
end
function on_btn_left_click(btn)
  btn.MouseDown = false
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_left_push(btn)
  local form = btn.ParentForm
  btn.MouseDown = true
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.scenebox_sablemodel, dist)
    end
  end
end
function on_btn_right_click(btn)
  btn.MouseDown = false
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_right_push(btn)
  local form = btn.ParentForm
  btn.MouseDown = true
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.scenebox_sablemodel, dist)
    end
  end
end
function on_btn_pagedown_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  ClearGrid_select(form)
  if nx_int(form.curPageNum) >= nx_int(form.nMaxPageNum) then
    form.curPageNum = form.nMaxPageNum
  else
    form.curPageNum = form.curPageNum + 1
  end
  refresh_pageinfo(form, form.curPageNum)
end
function on_btn_pageup_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  ClearGrid_select(form)
  if nx_int(form.curPageNum) <= nx_int(1) then
    form.curPageNum = 1
  else
    form.curPageNum = form.curPageNum - 1
  end
  refresh_pageinfo(form, form.curPageNum)
end
function send_call_sable(item_id)
  if nx_number(item_id) < 0 then
    return
  end
  if 0 < check_is_exist_sable() then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 1, nx_string("11602"))
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SABLE_HANDLE), 2, nx_number(item_id))
end
function on_btn_call_click(btn)
  local form = btn.ParentForm
  if form.select_sable_config == "" then
    return
  end
  if is_jh_scene() or is_in_home() then
    return
  end
  send_call_sable(form.select_sable_id)
end
function on_ImageMountGrid_select_changed(grid, index)
  on_ImageMountGrid_rightclick_grid(grid, index)
end
function on_ImageMountGrid_rightclick_grid(grid, index)
  local form = grid.ParentForm
  form.select_page = form.curPageNum
  form.select_grid = grid.Name
  local item_config = nx_string(grid:GetItemAddText(index, nx_int(0)))
  local item_id = nx_number(grid:GetItemAddText(index, nx_int(1)))
  if item_config == "" then
    return
  end
  ClearGrid_select(form)
  grid.DrawMouseSelect = "xuanzekuang"
  local old_config = form.select_sable_config
  form.select_sable_config = item_config
  form.select_sable_id = nx_number(item_id)
  if form.select_sable_config ~= old_config then
    nx_execute(nx_current(), "refresh_showinfo", form, item_config)
  end
end
function on_sable_list_change(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return
  end
  if nx_string("add") == nx_string(optype) then
    return
  end
  if nx_string("update") == nx_string(optype) and nx_string(clomn) ~= nx_string("3") and nx_string(clomn) ~= nx_string("5") and nx_string(clomn) ~= nx_string("6") then
    return
  end
  refresh_pageinfo(form, form.curPageNum)
end
function data_bind_prop(form)
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddTableBind("sable_rec", form, nx_current(), "on_sable_list_change")
end
function del_data_bind_prop(form)
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:DelViewBind(form)
end
function ClearGrid_select(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, form.nPageRecordNum do
    local ImageGird = form.groupbox_sable:Find("ImageMountGrid" .. i)
    if nx_is_valid(ImageGird) then
      ImageGird.DrawMouseSelect = "RECT"
    end
  end
end
function get_item_info(configid, prop)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
function refresh_pageinfo(form, pagenum)
  local gui = nx_value("gui")
  if nx_int(pagenum) < nx_int(1) or nx_int(pagenum) > nx_int(form.nMaxPageNum) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(gui) or not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("sable_rec") then
    return
  end
  local row_max = client_player:GetRecordRows("sable_rec")
  local row_num = get_old_pet_num()
  form.nMaxRecordNum = nx_int(row_num)
  form.nMaxPageNum = nx_int((row_num + form.nPageRecordNum - 1) / form.nPageRecordNum)
  if form.nMaxPageNum <= 0 then
    form.nMaxPageNum = 1
  end
  form.curPageNum = pagenum
  form.lbl_page.Text = nx_widestr(pagenum .. "/" .. form.nMaxPageNum)
  local index = get_index(form)
  for i = 1, form.nPageRecordNum do
    local ImageGrid = form.groupbox_sable:Find("ImageMountGrid" .. i)
    ImageGrid:Clear()
    index = get_sable(form, index)
    if row_max > index and 0 <= index then
      local config_id = client_player:QueryRecord("sable_rec", index, 3)
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(config_id), "Photo")
      if photo ~= "" then
        local name = gui.TextManager:GetFormatText(nx_string(config_id))
        ImageGrid:AddItem(0, photo, nx_widestr("<font color=\"#ffffff\">" .. nx_string(name) .. "</font>"), 1, -1)
        ImageGrid:SetItemAddInfo(nx_int(0), nx_int(0), nx_widestr(config_id))
        ImageGrid:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(index))
      end
      ImageGrid:ChangeItemImageToBW(nx_int(0), false)
      index = index + 1
    end
  end
  if form.select_page == pagenum then
    local Grid_name = nx_string(form.select_grid)
    if Grid_name == "" then
      return
    end
    local cur_grid = form.groupbox_sable:Find(Grid_name)
    if not nx_is_valid(cur_grid) then
      return
    end
    cur_grid.DrawMouseSelect = "xuanzekuang"
    local item_config = nx_string(cur_grid:GetItemAddText(0, nx_int(0)))
    local item_id = nx_number(cur_grid:GetItemAddText(0, nx_int(1)))
    form.select_sable_config = item_config
    form.select_sable_id = item_id
    nx_execute(nx_current(), "refresh_showinfo", form, item_config)
  end
end
function refresh_showinfo(form, item_config)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) or not nx_is_valid(form) then
    return
  end
  form.scenebox_sablemodel.Visible = false
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("sable_rec") then
    return
  end
  local szMountName = ""
  local end_time = 0
  local row_num = client_player:GetRecordRows("sable_rec")
  for i = 0, row_num - 1 do
    local sec = client_player:QueryRecord("sable_rec", i, 3)
    if nx_string(sec) == nx_string(item_config) then
      szMountName = gui.TextManager:GetFormatText(item_config)
      end_time = client_player:QueryRecord("sable_rec", i, 5)
    end
  end
  form.lbl_sablename.Text = nx_widestr(szMountName)
  form.mltbox_info:Clear()
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_sablemodel)
  if nx_is_valid(form.sable_cur_actor2) and nx_is_valid(form.scenebox_sablemodel.Scene) then
    form.scenebox_sablemodel.Scene:Delete(form.sable_cur_actor2)
  end
  form.lbl_endtime.Text = nx_widestr("")
  if item_config == "" then
    return
  end
  if 0 < end_time then
    show_endtime(form, end_time)
  else
    form.lbl_endtime.Visible = false
  end
  local words_id = "ui_" .. item_config
  form.mltbox_info:AddHtmlText(nx_widestr(gui.TextManager:GetText(words_id)), nx_int(-1))
  if not nx_is_valid(form.scenebox_sablemodel.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_sablemodel)
  end
  local actor2 = form.scenebox_sablemodel.Scene:Create("Actor2")
  if not nx_is_valid(actor2) then
    return
  end
  form.sable_cur_actor2 = actor2
  actor2.AsyncLoad = true
  actor2.mount = ""
  if nx_string(item_config) == nx_string("fengzheng_gensui") then
    load_from_ini(actor2, "ini\\npc\\part_back_1_16_2.ini")
    actor2:SetScale(0.3, 0.3, 0.3)
  else
    local itemArtPack = nx_int(get_item_info(item_config, "ArtPack"))
    if itemArtPack ~= "" then
      actor2.mount = item_static_query(itemArtPack, 0, STATIC_DATA_ITEM_ART)
      if 0 < string.len(actor2.mount) then
        load_from_ini(actor2, "ini\\" .. actor2.mount .. ".ini")
      end
    end
  end
  if nx_string(item_config) == nx_string("pet_peacock_gensui") then
    actor2:SetScale(0.3, 0.3, 0.3)
  end
  if nx_string(item_config) == nx_string("pet_kuilei_gensui") then
    actor2:SetScale(0.22, 0.22, 0.22)
  end
  if nx_string(item_config) == nx_string("pet_pig_gensui") then
    actor2:SetScale(0.5, 0.5, 0.5)
  end
  if not nx_is_valid(form) then
    form.scenebox_sablemodel.Scene:Delete(actor2)
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_sablemodel, actor2)
  form.scenebox_sablemodel.Visible = true
  local scene = form.scenebox_sablemodel.Scene
  local radius = 0.29
  local pos_y = 0.12
  if string.find(item_config, "hou") ~= nil then
    radius = 0.5
    pos_y = 0.3
  end
  actor2:SetPosition(0, pos_y, 0)
  if string.find(item_config, "_line") then
    radius = 1
  end
  if string.find(item_config, "mianyang") then
    radius = 0.6
  end
  if string.find(item_config, "xuelang") then
    radius = 1.2
  end
  if string.find(item_config, "xiaolu") then
    radius = 1.1
  end
  if string.find(item_config, "keji") then
    radius = 0.7
  end
  if nx_is_valid(scene) then
    scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
  end
  local dist = -0.785
  nx_execute("util_gui", "ui_RotateModel", form.scenebox_sablemodel, dist)
end
function check_is_exist_sable()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 1
  end
  if client_player:FindProp("Sable") and string.len(client_player:QueryProp("Sable")) > 0 then
    return 1
  end
  return 0
end
function on_ImageMountGrid_mousein_grid(grid, index)
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  local item_config = nx_string(grid:GetItemAddText(index, nx_int(0)))
  if item_config == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_ImageMountGrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_ImageMountGrid_drag_enter(grid, index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local game_hand = gui.GameHand
    game_hand.IsDragged = false
    game_hand.IsDropped = false
  end
end
function on_ImageMountGrid_drag_move(grid, index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local game_hand = gui.GameHand
    if not game_hand.IsDragged then
      game_hand.IsDragged = true
      gui.GameHand:ClearHand()
      local photo = grid:GetItemImage(index)
      local item_config = nx_string(grid:GetItemAddText(index, nx_int(0)))
      local item_id = nx_string(grid:GetItemAddText(index, nx_int(1)))
      gui.GameHand:SetHand("sable", photo, "sable", item_config, item_id, "")
    end
  end
end
function show_endtime(form, end_time)
  if not nx_is_valid(form) then
    return
  end
  local str_dt = nx_function("format_date_time", nx_double(end_time))
  local table_dt = util_split_string(str_dt, ";")
  if table.getn(table_dt) ~= 2 then
    return
  end
  local year, month, day = format_date_text(table_dt[1])
  local day_time = format_time_text(table_dt[2])
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_sable_del_timeout")
  gui.TextManager:Format_AddParam(nx_int(year))
  gui.TextManager:Format_AddParam(nx_int(month))
  gui.TextManager:Format_AddParam(nx_int(day))
  gui.TextManager:Format_AddParam(nx_int(day_time[1]))
  gui.TextManager:Format_AddParam(nx_int(day_time[2]))
  gui.TextManager:Format_AddParam(nx_int(day_time[3]))
  form.lbl_endtime.Visible = true
  form.lbl_endtime.Text = nx_widestr(gui.TextManager:Format_GetText())
end
function format_date_text(text)
  local len = string.len(text)
  if nx_number(len) ~= 11 then
    return text
  end
  local hasYear = string.sub(nx_string(text), 1, 4)
  local hasMonth = string.sub(nx_string(text), 6, 7)
  local hasDay = string.sub(nx_string(text), 9, 10)
  return hasYear, hasMonth, hasDay
end
function format_time_text(text)
  local len = string.len(text)
  if nx_number(len) ~= 8 then
    return text
  end
  local table_dt = util_split_string(text, ":")
  if table.getn(table_dt) ~= 3 then
    return ""
  end
  return table_dt
end
function get_format_text(stringid, param1, param2, param3, param4, param5, param6)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(nx_string(stringid))
  if nil ~= param1 then
    gui.TextManager:Format_AddParam(param1)
  end
  if nil ~= param2 then
    gui.TextManager:Format_AddParam(param2)
  end
  if nil ~= param3 then
    gui.TextManager:Format_AddParam(param3)
  end
  if nil ~= param4 then
    gui.TextManager:Format_AddParam(param4)
  end
  if nil ~= param5 then
    gui.TextManager:Format_AddParam(param5)
  end
  if nil ~= param6 then
    gui.TextManager:Format_AddParam(param6)
  end
  return nx_widestr(gui.TextManager:Format_GetText())
end
function is_jh_scene()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("CurJHSceneConfigID") then
    return false
  end
  local jh_scene = player:QueryProp("CurJHSceneConfigID")
  if jh_scene == nil or jh_scene == "" then
    return false
  end
  return true
end
function is_in_home()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindProp("CurHomeUID") then
    return false
  end
  local homeid = client_player:QueryProp("CurHomeUID")
  if homeid == nil or homeid == "" then
    return false
  end
  return true
end
function get_old_pet_num()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("sable_rec") then
    return 0
  end
  local ole_sable_num = 0
  local row_num = client_player:GetRecordRows("sable_rec")
  for i = 0, row_num - 1 do
    local pet_type = client_player:QueryRecord("sable_rec", i, 6)
    if pet_type == 0 then
      ole_sable_num = ole_sable_num + 1
    end
  end
  return ole_sable_num
end
function get_index(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return -1
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  if not client_player:FindRecord("sable_rec") then
    return -1
  end
  local discount_num = (form.curPageNum - 1) * form.nPageRecordNum + 1
  local ole_sable_num = 0
  local row_num = client_player:GetRecordRows("sable_rec")
  for i = 0, row_num - 1 do
    local pet_type = client_player:QueryRecord("sable_rec", i, 6)
    if pet_type == 0 then
      ole_sable_num = ole_sable_num + 1
      if discount_num <= ole_sable_num then
        return i
      end
    end
  end
  return -1
end
function get_sable(form, index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return -1
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  if not client_player:FindRecord("sable_rec") then
    return -1
  end
  local before_num = (form.curPageNum - 1) * form.nPageRecordNum
  local row_num = client_player:GetRecordRows("sable_rec")
  if index >= row_num then
    return -1
  end
  for i = index, row_num - 1 do
    local pet_type = client_player:QueryRecord("sable_rec", i, 6)
    if pet_type == 0 then
      return i
    end
  end
  return -1
end
