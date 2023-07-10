require("share\\view_define")
require("util_gui")
require("util_functions")
require("game_object")
require("util_static_data")
require("define\\tip_define")
require("define\\team_rec_define")
require("share\\capital_define")
require("share\\client_custom_define")
local FORM_TEAM_ASSIGN = "form_stage_main\\form_team\\form_team_assign"
local FORM_ITEMBIND_PICKUP = "form_stage_main\\form_itembind\\form_itembind_pickup"
local FORM_ITEMBIND_MANAGER = "form_stage_main\\form_itembind\\form_itembind_manager"
local FORM_COMPETE_BASEPRICE = "form_stage_main\\form_compete\\form_baseprice"
local MAX_DROP_BOX_CAPACITY = 16
local JH_MAX_DROP_BOX_CAPACITY = 100
local MAX_TEAM_COUNT = 8
local color_lst = global_color_list
function main_form_init(self)
  self.Fixed = false
  self.nCurrentPage = 0
  self.nMaxPage = 0
  self.nDropBoxCapacity = get_max_dropbox_capacity()
  self.nItemTypeShowPerPage = 4
  self.nMaxIndexCount = 0
  self.nCurrentIndex = 0
  self.nTaskDropItem = ""
  self.nTaskDropCount = 0
  return 1
end
function on_main_form_open(self)
  self.btn_pageup.Visible = false
  self.btn_pagedown.Visible = false
  self.lbl_page_show.Visible = false
  set_window_position(self)
  self.icg_items.typeid = VIEWPORT_DROP_BOX
  self.icg_items.beginindex = 1
  self.icg_items.endindex = get_max_dropbox_capacity()
  self.icg_items.Data = nx_create("ArrayList", nx_current())
  local grid_index = 0
  for view_index = self.icg_items.beginindex, self.icg_items.endindex do
    self.icg_items:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_DROP_BOX, self, nx_current(), "on_dropbox_viewport_change")
  end
  on_dropbox_viewport_change(self, 0, VIEWPORT_DROP_BOX, 0)
  nx_execute(nx_current(), "auto_pick_all", self)
end
function on_main_form_close(self)
  if nx_is_valid(self.icg_items.Data) then
    nx_destroy(self.icg_items.Data)
  end
  if self.icg_items.Capture == true then
    nx_execute("tips_game", "hide_tip", self)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(self)
  end
  nx_destroy(self)
  nx_set_value("form_pickdrop", nx_null())
  local form_itembind_pickup = nx_value(FORM_ITEMBIND_PICKUP)
  if nx_is_valid(form_itembind_pickup) then
    form_itembind_pickup:Close()
  end
  local form_team_assign = nx_value(FORM_TEAM_ASSIGN)
  if nx_is_valid(form_team_assign) then
    form_team_assign:Close()
  end
end
function on_btn_close_click(btn)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
  if not nx_is_valid(view) then
    return 1
  end
  local drop_type = view:QueryProp("DropType")
  if 1 == drop_type then
    local gui = nx_value("gui")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr("@ui_diuqi"))
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if "ok" ~= res then
      return 1
    end
  end
  nx_execute("custom_sender", "custom_close_drop_box")
  return 1
end
function on_dropbox_viewport_change(self, optype, view_ident, index)
  if nx_running(nx_current(), "wait_for_change", self) then
    nx_kill(nx_current(), "wait_for_change", self)
  end
  nx_execute(nx_current(), "wait_for_change", self, optype, view_ident, index)
end
function auto_pick_all(self)
  local game_config_info = nx_value("game_config_info")
  local game_visual = nx_value("game_visual")
  local vis_player = game_visual:GetPlayer()
  if not nx_is_valid(vis_player) then
    return
  end
  if not nx_find_custom(vis_player, "last_mouse_op") then
    return
  end
  local key = util_get_property_key(game_config_info, "pick_autopick", 1)
  if vis_player.last_mouse_op ~= "right" or nx_string(key) == nx_string("0") then
    return
  end
  nx_pause(1)
  if nx_is_valid(self) and self.Visible then
    on_btn_pick_click(self.btn_pick)
  end
end
function wait_for_change(self, optype, view_ident, index)
  nx_pause(0.1)
  if not nx_is_valid(self) then
    return
  end
  on_dropbox_viewport_change2(self, optype, view_ident, index)
end
function on_dropbox_viewport_change2(self, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  local task_count, task_drop_item = check_task_drop(view_ident)
  self.nTaskDropCount = task_count
  self.nTaskDropItem = task_drop_item
  local nCurrentValidItemTyps = 0
  if nx_int(self.nMaxPage) <= nx_int(0) then
    self.nCurrentPage = 1
  end
  self.nMaxIndexCount = get_viewport_valid_item_type_cout(view) + self.nTaskDropCount
  local tmp1, tmp2 = math.modf(self.nMaxIndexCount / self.nItemTypeShowPerPage)
  if tmp2 ~= 0 then
    self.nMaxPage = nx_int(tmp1 + 1)
  else
    self.nMaxPage = nx_int(tmp1)
  end
  if 1 >= self.nMaxPage then
    self.btn_pageup.Visible = false
    self.btn_pagedown.Visible = false
    self.lbl_page_show.Visible = false
  else
    self.btn_pageup.Visible = true
    self.btn_pagedown.Visible = true
    self.lbl_page_show.Visible = true
  end
  if nx_int(self.nMaxPage) < nx_int(self.nCurrentPage) then
    self.nCurrentPage = self.nMaxPage
  end
  local startpos = (self.nCurrentPage - 1) * self.nItemTypeShowPerPage + 1
  if startpos < 1 then
    startpos = 1
  end
  nCurrentValidItemTyps = self.nMaxIndexCount
  local endpos = startpos + self.nItemTypeShowPerPage
  if nx_int(endpos) > nx_int(nCurrentValidItemTyps) then
    endpos = nx_int(nCurrentValidItemTyps)
  end
  fresh_viewport_item_to_list(self, view, startpos, endpos)
  refresh_all_btn(self)
end
function get_viewport_valid_item_type_cout(view)
  local max_index = 0
  local max_dropbox_capacity = get_max_dropbox_capacity()
  for count = max_dropbox_capacity, 1, -1 do
    local obj = view:GetViewObj(nx_string(count))
    if nx_is_valid(obj) then
      max_index = count
      break
    end
  end
  return max_index
end
function set_task_item(root, pos, nRealPos, view)
  local gui = nx_value("gui")
  root.icg_items:DelItem(nx_int(pos))
  local task_drop_list = util_split_string(nx_string(root.nTaskDropItem), ";")
  local index = root.nTaskDropCount - (root.nMaxIndexCount - nRealPos)
  if task_drop_list[index] == nil or task_drop_list[index] == "" then
    return
  end
  local item_config = task_drop_list[index]
  local item_count = 1
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_name = gui.TextManager:GetText(item_config)
  local viewobj = view:GetViewObj(nx_string(nRealPos))
  local item_photo = nx_execute("util_static_data", "query_equip_photo_by_sex", viewobj)
  if nil == item_photo or "" == item_photo then
    item_photo = item_query_ArtPack_by_id(nx_string(item_config), nx_string("Photo"))
  end
  local item_color = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ColorLevel"))
  if 1 > nx_number(item_color) or nx_number(item_color) > 6 then
    item_color = 1
  end
  root.icg_items:AddItem(nx_int(pos), nx_string(item_photo), nx_widestr(item_config), nx_int(item_count), nx_int(0))
  local tee = nx_widestr("<font color=\"") .. nx_widestr(color_lst[nx_number(item_color)]) .. nx_widestr("\">") .. nx_widestr(item_name) .. nx_widestr("</font>")
  root.icg_items:SetItemInfo(nx_int(pos), tee)
end
function fresh_viewport_item_to_list(root, view, startpos, endpos)
  local tracker = 0
  for index = 0, root.nItemTypeShowPerPage - 1 do
    local nRealPos = nx_int(index) + nx_int(startpos)
    if 0 < root.nTaskDropCount and nRealPos > root.nMaxIndexCount - root.nTaskDropCount and nRealPos <= root.nMaxIndexCount then
      set_task_item(root, index, nRealPos, view)
    else
      local viewobj = view:GetViewObj(nx_string(nRealPos))
      if nx_is_valid(viewobj) then
        reset_list_item(root, index, true, viewobj)
      else
        reset_list_item(root, index, false, viewobj)
      end
    end
  end
end
function reset_list_item(root, pos, bshow, viewobj)
  local gui = nx_value("gui")
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  root.icg_items:DelItem(nx_int(pos))
  if bshow then
    local item_config = viewobj:QueryProp("ConfigID")
    local item_count = viewobj:QueryProp("Amount")
    local item_equip_type = viewobj:QueryProp("EquipType")
    local item_color_level = viewobj:QueryProp("ColorLevel")
    local ItemQuery = nx_value("ItemQuery")
    if not nx_is_valid(ItemQuery) then
      return
    end
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
    if bExist == false then
      return
    end
    if string.find(item_config, "add_money_item") ~= nil then
      local show_text = nx_widestr("")
      local CapitalModule = nx_value("CapitalModule")
      if not nx_is_valid(CapitalModule) then
        return
      end
      local rst = {}
      rst = CapitalModule:SplitCapital(nx_int(item_count), CAPITAL_TYPE_SILVER)
      local num_ding = rst[1]
      local num_liang = rst[2]
      local num_wen = rst[3]
      local string_ding = gui.TextManager:GetText("1291")
      local string_liang = gui.TextManager:GetText("1305")
      local string_wen = gui.TextManager:GetText("1306")
      if nx_int(num_ding) > nx_int(0) then
        show_text = nx_widestr(num_ding) .. nx_widestr(string_ding) .. nx_widestr(num_liang) .. nx_widestr(string_liang) .. nx_widestr(num_wen) .. nx_widestr(string_wen)
      elseif nx_int(num_liang) > nx_int(0) then
        show_text = nx_widestr(num_liang) .. nx_widestr(string_liang) .. nx_widestr(num_wen) .. nx_widestr(string_wen)
      else
        show_text = nx_widestr(num_wen) .. nx_widestr(string_wen)
      end
      local item_photo = nx_execute("util_static_data", "query_equip_photo_by_sex", viewobj)
      if nil == item_photo or "" == item_photo then
        item_photo = item_query_ArtPack_by_id(nx_string(item_config), nx_string("Photo"))
      end
      local item_back_image = get_grid_treasure_back_image(item_equip_type, item_color_level)
      root.icg_items:AddItemEx(nx_int(pos), nx_string(item_photo), nx_widestr(item_name), nx_int(1), nx_int(0), nx_string(item_back_image))
      root.icg_items:SetItemInfo(nx_int(pos), nx_widestr(show_text))
    else
      local item_name = nx_widestr("")
      local equip_type = viewobj:QueryProp("EquipType")
      if nx_string(equip_type) == nx_string("NewTreasure") then
        local suit_id = viewobj:QueryProp("TersureSuitID")
        if 0 < suit_id and suit_id <= 10 then
          item_name_1 = gui.TextManager:GetText("desc_newtreasure_combination_" .. suit_id)
          item_name_2 = gui.TextManager:GetText(item_config)
          item_name = nx_widestr(item_name_1) .. nx_widestr(item_name_2)
        else
          item_name = gui.TextManager:GetText(item_config)
        end
      else
        local base_name = nx_widestr(tips_manager:GetItemBaseName(viewobj))
        item_name = gui.TextManager:GetText(item_config)
        if not nx_ws_equal(base_name, nx_widestr("")) then
          item_name = base_name
        end
      end
      local item_photo = nx_execute("util_static_data", "query_equip_photo_by_sex", viewobj)
      if nil == item_photo or "" == item_photo then
        item_photo = item_query_ArtPack_by_id(nx_string(item_config), nx_string("Photo"))
      end
      if 1 > nx_number(item_color_level) or nx_number(item_color_level) > 6 then
        item_color_level = 1
      end
      local item_back_image = get_grid_treasure_back_image(item_equip_type, item_color_level)
      root.icg_items:AddItemEx(nx_int(pos), nx_string(item_photo), nx_widestr(item_name), nx_int(item_count), nx_int(0), nx_string(item_back_image))
      local tee = nx_widestr("<font color=\"") .. nx_widestr(color_lst[nx_number(item_color_level)]) .. nx_widestr("\">") .. nx_widestr(item_name) .. nx_widestr("</font>")
      root.icg_items:SetItemInfo(nx_int(pos), nx_widestr(tee))
    end
  end
end
function on_btn_pageup_click(btn)
  local form = btn.ParentForm
  form.nCurrentPage = form.nCurrentPage - 1
  on_dropbox_viewport_change(form, "updateitem", VIEWPORT_DROP_BOX, 0)
end
function on_btn_pagedown_click(btn)
  local form = btn.ParentForm
  form.nCurrentPage = form.nCurrentPage + 1
  on_dropbox_viewport_change(form, "updateitem", VIEWPORT_DROP_BOX, 0)
end
function on_btn_pick_click(btn)
  local gui = nx_value("gui")
  local form_droppick = btn.ParentForm
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return
  end
  nx_execute(FORM_ITEMBIND_MANAGER, "clear_pickup_index_table")
  nx_execute("form_stage_main\\form_bag", "clear_select_items")
  local num = form_droppick.nMaxIndexCount
  local b_first = true
  for count = num, 1, -1 do
    if nx_is_valid(form_droppick) and form_droppick.nTaskDropCount > 0 and count > form_droppick.nMaxIndexCount - form_droppick.nTaskDropCount and count <= form_droppick.nMaxIndexCount then
      local nTaskDropItem = form_droppick.nTaskDropItem
      local task_drop_list = util_split_string(nTaskDropItem, ";")
      local i = form_droppick.nTaskDropCount - (form_droppick.nMaxIndexCount - count)
      try_task_drop_item(task_drop_list[i])
    else
      local b_need_bind = nx_execute(FORM_ITEMBIND_MANAGER, "drop_itemobj_need_bind", nx_int(count))
      if b_need_bind then
        local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
        if nx_is_valid(view) then
          local viewobj = view:GetViewObj(nx_string(count))
          if nx_is_valid(viewobj) then
            gui.TextManager:Format_SetIDName("1313")
            local configid = viewobj:QueryProp("ConfigID")
            gui.TextManager:Format_AddParam(nx_string(configid))
            local content = gui.TextManager:Format_GetText()
            local res, dialog = util_form_confirm(title, content, MB_OKCANCEL, true)
            if res == "ok" then
              nx_execute("custom_sender", "custom_pickup_single_item", count)
              if nx_is_valid(dialog) then
                dialog:Close()
              end
            end
          end
        end
      else
        nx_execute("custom_sender", "custom_pickup_single_item", count)
      end
    end
  end
  if nx_int(num) == nx_int(0) then
    nx_execute("custom_sender", "custom_close_drop_box")
  end
end
function refresh_all_btn(self)
  self.btn_pageup.Enabled = true
  self.btn_pagedown.Enabled = true
  if nx_int(self.nCurrentPage) == nx_int(1) then
    self.btn_pageup.Enabled = false
  end
  if nx_int(self.nCurrentPage) == nx_int(self.nMaxPage) then
    self.btn_pagedown.Enabled = false
  end
  local page_show = nx_string(nx_int(self.nCurrentPage)) .. "/" .. nx_string(nx_int(self.nMaxPage))
  self.lbl_page_show.Text = nx_widestr(page_show)
end
function on_icg_items_select_changed(self, index)
  local form_droppick = self.ParentForm
  local root = self.Parent
  root.nCurrentIndex = index
  local nrealindex = index + (root.nCurrentPage - 1) * root.nItemTypeShowPerPage + 1
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return
  end
  nx_execute("form_stage_main\\form_bag", "clear_select_items")
  local nTaskDropItem = root.nTaskDropItem
  if nTaskDropItem ~= nil and nTaskDropItem ~= "" and nrealindex > root.nMaxIndexCount - root.nTaskDropCount and nrealindex <= root.nMaxIndexCount then
    local task_drop_list = util_split_string(nTaskDropItem, ";")
    local i = root.nTaskDropCount - (root.nMaxIndexCount - nrealindex)
    try_task_drop_item(task_drop_list[i])
    return
  end
  local b_need_bind = nx_execute(FORM_ITEMBIND_MANAGER, "drop_itemobj_need_bind", nx_int(nrealindex))
  if b_need_bind then
    local form = nx_execute("util_gui", "util_get_form", FORM_ITEMBIND_PICKUP, true)
    if nx_is_valid(form) then
      form.view_id = VIEWPORT_DROP_BOX
      form.item_index = tonumber(nrealindex)
      form.AbsLeft = (gui.Width - form.Width) / 2
      form.AbsTop = (gui.Height - form.Height) / 4
      nx_execute(FORM_ITEMBIND_PICKUP, "set_form_showinfo")
      nx_execute("util_gui", "util_show_form", FORM_ITEMBIND_PICKUP, true)
      gui.Desktop:ToFront(form)
    end
  else
    nx_execute("custom_sender", "custom_pickup_single_item", nrealindex)
  end
end
function on_icg_items_mousein_grid(self, index)
  local root = self.Parent
  local nrealindex = index + (root.nCurrentPage - 1) * root.nItemTypeShowPerPage + 1
  if nrealindex > root.nMaxIndexCount - root.nTaskDropCount and nrealindex <= root.nMaxIndexCount then
    show_prize_tips(self, index)
  else
    show_normal_tips(self, index)
  end
end
function on_icg_items_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function try_task_drop_item(drop_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PICKUP_TASK_DROPITEM), nx_string(drop_id))
end
function is_team_captain()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local TeamCaptain = client_player:QueryProp("TeamCaptain")
  local Name = client_player:QueryProp("Name")
  if nx_ws_equal(nx_widestr(TeamCaptain), nx_widestr(Name)) then
    return true
  else
    return nil
  end
end
function is_team_allocater()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local name = client_player:QueryProp("Name")
  local teamtype = client_player:QueryProp("TeamType")
  if teamtype == TYPE_NORAML_TEAM then
    return is_team_captain()
  elseif teamtype == TYPE_LARGE_TEAM then
    local row = client_player:FindRecordRow("team_rec", TEAM_REC_COL_NAME, nx_widestr(name))
    local work = client_player:QueryRecord("team_rec", row, TEAM_REC_COL_TEAMWORK)
    if work == TYPE_NORAML_LEADER then
      return true
    end
    return nil
  end
end
function check_task_drop(view_ident)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return ""
  end
  local name = client_player:QueryProp("Name")
  local rec = view:QueryProp("TaskDropItem")
  if rec == "" or rec == nil then
    return 0, ""
  end
  rec = nx_string(rec)
  local count = 0
  local task_drop_item = ""
  local drop_list = util_split_string(rec, ";")
  for i = 1, table.getn(drop_list) do
    if drop_list[i] ~= "" then
      local drop_temp = nx_string(drop_list[i])
      local player_drop_list = util_split_string(drop_temp, ",")
      if player_drop_list[1] ~= "" and player_drop_list[2] ~= "" and player_drop_list[1] ~= nil and player_drop_list[2] ~= nil and nx_string(player_drop_list[2]) == nx_string(name) then
        count = count + 1
        task_drop_item = nx_string(task_drop_item) .. nx_string(player_drop_list[1]) .. ";"
      end
    end
  end
  return count, task_drop_item
end
function show_normal_tips(grid, index)
  local form = grid.ParentForm
  local nrealindex = index + (form.nCurrentPage - 1) * form.nItemTypeShowPerPage + 1
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(nrealindex))
  if not nx_is_valid(viewobj) then
    return
  end
  grid.view_obj = viewobj
  if nx_is_valid(grid.Data) then
    nx_execute("tips_game", "show_goods_tip", grid.view_obj, grid:GetMouseInItemLeft() + grid.GridOffsetX, grid:GetMouseInItemTop() + grid.GridOffsetY, 32, 32, grid.ParentForm)
  end
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
  table_prop_value.Amount = 1
  if nx_is_valid(grid.Data) then
    nx_function("ext_clear_custom_list", grid.Data)
    for prop, value in pairs(table_prop_value) do
      nx_set_custom(grid.Data, prop, value)
    end
    nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32, grid.ParentForm)
  end
end
function can_player_pickup()
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
  if not nx_is_valid(view) then
    return 1
  end
  local normal_count = get_viewport_valid_item_type_cout(view)
  local task_count = check_task_drop(VIEWPORT_DROP_BOX)
  local sum = normal_count + task_count
  return sum
end
function set_window_position(form)
  local gui = nx_value("gui")
  local game_config_info = nx_value("game_config_info")
  local key = util_get_property_key(game_config_info, "pick_position", 1)
  if nx_int(key) == nx_int(0) then
    local x, y = gui:GetCursorPosition()
    x = x + 32
    y = y + 32
    if x + form.Width > gui.Width then
      x = x - 32
      x = x - form.Width
    end
    if y + form.Height > gui.Height then
      if y > form.Height then
        y = y - 32
        y = y - form.Height
      else
        y = gui.Height - form.Height
      end
    end
    form.AbsLeft = x
    form.AbsTop = y
  else
    form.AbsLeft = (gui.Width - form.Width) * 7 / 10
    form.AbsTop = (gui.Height - form.Height) / 2
  end
end
function get_max_dropbox_capacity()
  if IsInJHScene() then
    return JH_MAX_DROP_BOX_CAPACITY
  end
  return MAX_DROP_BOX_CAPACITY
end
function IsInJHScene()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local cur_jhscene_id = nx_string(client_player:QueryProp("CurJHSceneConfigID"))
  if cur_jhscene_id == "" or cur_jhscene_id == "0" then
    return false
  end
  return true
end
