require("utils")
require("util_functions")
require("util_gui")
require("util_static_data")
require("role_composite")
require("share\\view_define")
require("share\\itemtype_define")
require("define\\gamehand_type")
require("define\\camera_mode")
require("share\\item_static_data_define")
local BLEND_BOX_CAPACITY = 8
local DEF_CAMERA_DISTANCE = 4
local DEF_CAMERA_MAX_DISTANCE = 6
local DEF_CAMERA_MIN_DISTANCE = 0.5
local DEF_CAMERA_LOOKAT_SCALE = 0.75
local CAMERA_ANGLE_X, CAMERA_ANGLE_Y, CAMERA_DISTANCE
local BAG_LEFT = -475
local BAG_TOP = -237
local blendtype_table = {
  ITEMTYPE_EQUIP_HAT,
  ITEMTYPE_HUANPIHEAD,
  ITEMTYPE_EQUIP_CLOTH,
  ITEMTYPE_HUANPICLOTH,
  ITEMTYPE_EQUIP_PANTS,
  ITEMTYPE_HUANPIPANTS,
  ITEMTYPE_EQUIP_SHOES,
  ITEMTYPE_HUANPISHOES
}
function on_main_form_init(form)
  form.Fixed = true
  form.actor2 = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  set_equipblend_status(true)
  on_gui_size_change()
  create_role_model(form)
  set_camera_movie(form)
  nx_execute("form_stage_main\\form_talk_movie", "cancel_ppdof_effect")
  init_blend_grid(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_EQUIP_BLEND_BOX, form.grid_blend, nx_current(), "on_blend_viewport_changed")
  end
  set_money_text(form, 0)
  form.Visible = true
  form.btn_rehat.Visible = false
  form.btn_recloth.Visible = false
  form.btn_repants.Visible = false
  form.btn_reshoes.Visible = false
  form.grid_head.Visible = false
  form.grid_cloth.Visible = false
  form.grid_pants.Visible = false
  form.grid_shoes.Visible = false
  form.grid_head.configid = nx_string("")
  form.grid_cloth.configid = nx_string("")
  form.grid_pants.configid = nx_string("")
  form.grid_shoes.configid = nx_string("")
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk.Visible = false
  end
  local form_main_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
  if nx_is_valid(form_main_chat) then
    form_main_chat.Visible = true
    gui.Desktop:ToFront(form_main_chat)
  end
  local form_chat_light = nx_value("form_stage_main\\form_chat_system\\form_chat_light")
  if nx_is_valid(form_chat_light) then
    form_chat_light.Visible = true
    gui.Desktop:ToFront(form_chat_light)
  end
  local form_blendcollect = nx_value("form_stage_main\\form_blendcollect")
  if nx_is_valid(form_blendcollect) then
    form_blendcollect:Close()
  end
  util_show_form("form_stage_main\\form_blendcollect", true)
end
function on_main_form_close(form)
  set_equipblend_status(false)
  clear_role_model(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form.grid_blend)
  end
  nx_execute("custom_sender", "custom_close_equip_blend")
  nx_destroy(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  local form_setting = nx_value("form_stage_main\\form_system\\form_system_setting")
  if nx_is_valid(form_setting) then
    form_setting:Close()
  end
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", false)
  local form_blendcollect = nx_value("form_stage_main\\form_blendcollect")
  if nx_is_valid(form_blendcollect) then
    form_blendcollect:Close()
  end
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_equipblend")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    local model = form.actor2
    if nx_is_valid(model) then
      local angle_x = model.AngleX
      local angle_y = model.AngleY
      local angle_z = model.AngleZ
      angle_y = angle_y + dist
      model:SetAngle(angle_x, angle_y, angle_z)
    end
  end
end
function on_btn_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    local model = form.actor2
    if nx_is_valid(model) then
      local angle_x = model.AngleX
      local angle_y = model.AngleY
      local angle_z = model.AngleZ
      angle_y = angle_y + dist
      model:SetAngle(angle_x, angle_y, angle_z)
    end
  end
end
function on_btn_rehat_click(btn)
  local form = btn.ParentForm
  recover_item(form.grid_blend, 0)
end
function on_btn_recloth_click(btn)
  local form = btn.ParentForm
  recover_item(form.grid_blend, 2)
end
function on_btn_repants_click(btn)
  local form = btn.ParentForm
  recover_item(form.grid_blend, 4)
end
function on_btn_reshoes_click(btn)
  local form = btn.ParentForm
  recover_item(form.grid_blend, 6)
end
function on_btn_videosetting_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_system\\form_system_setting")
end
function on_btn_blend_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local grid = form.grid_blend
  if can_blend(grid) then
    local info = gui.TextManager:GetText("ui_huanpi_tishi_6")
    local res = util_form_confirm("", info)
    if res == "ok" then
      nx_execute("custom_sender", "custom_begin_blend_equip")
    end
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("86302"))
  end
end
function on_btn_clear_click(btn)
  local form = btn.ParentForm
  local grid = form.grid_blend
  for i = 0, BLEND_BOX_CAPACITY - 1 do
    local view_index = grid:GetBindIndex(i)
    nx_execute("custom_sender", "custom_remove_equip_blend_item", view_index)
  end
end
function on_btn_bag_click(btn)
  local form_bag = nx_value("form_stage_main\\form_bag")
  if not nx_is_valid(form_bag) or form_bag.Visible == false then
    nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  else
    nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", false)
  end
end
function on_btn_prop_click(btn)
  nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
end
function on_btn_collect_click(btn)
  nx_execute("form_stage_main\\form_blendcollect", "open_form")
end
function on_grid_blend_select_changed(grid, index)
  local gui = nx_value("gui")
  local form = grid.ParentForm
  local dst_pos = grid:GetBindIndex(index)
  local gamehand_type = gui.GameHand.Type
  if not gui.GameHand:IsEmpty() and gamehand_type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    gui.GameHand:ClearHand()
    if nx_int(src_viewid) ~= nx_int(VIEWPORT_EQUIP_TOOL) and nx_int(src_viewid) ~= nx_int(VIEWPORT_TOOL) and nx_int(src_viewid) ~= nx_int(VIEWPORT_MATERIAL_TOOL) and nx_int(src_viewid) ~= nx_int(VIEWPORT_TASK_TOOL) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("86300"))
      return
    end
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    local item_type = viewobj:QueryProp("ItemType")
    local pos_type = blendtype_table[nx_number(dst_pos)]
    if nx_int(pos_type) ~= nx_int(item_type) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("86301"))
      return
    end
    if IsFashionOrSuit(viewobj) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("86301"))
      return
    end
    local lock_status = viewobj:QueryProp("LockStatus")
    if nx_int(lock_status) > nx_int(0) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7054"))
      return
    end
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) then
      local sex = client_player:QueryProp("Sex")
      local needsex = GetItemSex(viewobj)
      if nx_int(needsex) <= nx_int(1) and nx_int(needsex) ~= nx_int(sex) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("86304"))
        return
      end
    end
    if nx_int(item_type) >= nx_int(ITEMTYPE_HUANPIMIN) and nx_int(item_type) <= nx_int(ITEMTYPE_HUANPIMAX) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("37108"))
      return
    end
    nx_execute("custom_sender", "custom_add_equip_blend_item", src_viewid, src_pos, dst_pos)
  end
end
function on_grid_blend_rightclick_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local view_index = grid:GetBindIndex(index)
  nx_execute("custom_sender", "custom_remove_equip_blend_item", view_index)
end
function on_blend_viewport_changed(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "updateview" then
  elseif optype == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
    clear_huapi_grid(form, index)
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
    update_blend_panel(form)
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
    update_blend_panel(form)
  end
  return 1
end
function on_grid_blend_mousein_grid(grid, index)
  local form = grid.ParentForm
  local bindindex = grid:GetBindIndex(index)
  local item_data
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(grid, index)
  end
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
  else
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("tips_blendequip_pos_" .. bindindex)
    nx_execute("tips_game", "show_text_tip", text, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 0, form)
  end
end
function on_grid_blend_mouseout_grid(grid, index)
  local form = grid.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_grid_huanpi_mousein_grid(grid, index)
  local form = grid.ParentForm
  local configid = grid.configid
  if nx_string(configid) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", configid, x, y, form)
end
function on_grid_huanpi_mouseout_grid(grid, index)
  local form = grid.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_grid_huanpi_select_changed(grid, index)
  local form = grid.ParentForm
  form.grid_blend:SetSelectItemIndex(-1)
  local view_index = 0
  local control_name = grid.Name
  if nx_string(control_name) == nx_string("grid_head") then
    view_index = 2
    form.grid_cloth:SetSelectItemIndex(-1)
    form.grid_pants:SetSelectItemIndex(-1)
    form.grid_shoes:SetSelectItemIndex(-1)
  elseif nx_string(control_name) == nx_string("grid_cloth") then
    view_index = 4
    form.grid_head:SetSelectItemIndex(-1)
    form.grid_pants:SetSelectItemIndex(-1)
    form.grid_shoes:SetSelectItemIndex(-1)
  elseif nx_string(control_name) == nx_string("grid_pants") then
    view_index = 6
    form.grid_head:SetSelectItemIndex(-1)
    form.grid_cloth:SetSelectItemIndex(-1)
    form.grid_shoes:SetSelectItemIndex(-1)
  elseif nx_string(control_name) == nx_string("grid_shoes") then
    view_index = 8
    form.grid_head:SetSelectItemIndex(-1)
    form.grid_cloth:SetSelectItemIndex(-1)
    form.grid_pants:SetSelectItemIndex(-1)
  else
    return
  end
  on_grid_blend_select_changed(form.grid_blend, view_index - 1)
end
function on_grid_huanpi_rightclick_grid(grid, index)
  local form = grid.ParentForm
  local view_index = 0
  local control_name = grid.Name
  if nx_string(control_name) == nx_string("grid_head") then
    view_index = 2
  elseif nx_string(control_name) == nx_string("grid_cloth") then
    view_index = 4
  elseif nx_string(control_name) == nx_string("grid_pants") then
    view_index = 6
  elseif nx_string(control_name) == nx_string("grid_shoes") then
    view_index = 8
  else
    return
  end
  nx_execute("custom_sender", "custom_remove_equip_blend_item", view_index)
end
function show_huanpi_grid(form, cell_name, configid)
  local grid
  if nx_string(cell_name) == nx_string("CellHead") then
    grid = form.grid_head
  elseif nx_string(cell_name) == nx_string("CellCloth") then
    grid = form.grid_cloth
  elseif nx_string(cell_name) == nx_string("CellPants") then
    grid = form.grid_pants
  elseif nx_string(cell_name) == nx_string("CellShoes") then
    grid = form.grid_shoes
  else
    return
  end
  local photo = get_photo(configid)
  grid:AddItem(0, photo, "", 1, -1)
  grid:SetSelectItemIndex(-1)
  grid.Visible = true
  grid.configid = nx_string(configid)
  update_blend_panel(form)
end
function clear_huapi_grid(form, index)
  local grid
  if nx_int(index) == nx_int(2) then
    grid = form.grid_head
  elseif nx_int(index) == nx_int(4) then
    grid = form.grid_cloth
  elseif nx_int(index) == nx_int(6) then
    grid = form.grid_pants
  elseif nx_int(index) == nx_int(8) then
    grid = form.grid_shoes
  else
    update_blend_panel(form)
    return
  end
  grid:Clear()
  grid:SetSelectItemIndex(-1)
  grid.Visible = false
  grid.configid = nx_string("")
  update_blend_panel(form)
end
function equip_blend_success(form, blend_num)
  if not nx_is_valid(form) then
    return
  end
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  if nx_int(blend_num) > nx_int(0) then
    nx_execute("game_config", "create_effect", "tab_huanzhuang", actor2, actor2, "", "", "", "", "", true)
  end
end
function init_blend_grid(form)
  local grid = form.grid_blend
  grid.typeid = VIEWPORT_EQUIP_BLEND_BOX
  grid.beginindex = 1
  grid.endindex = BLEND_BOX_CAPACITY
  local grid_index = 0
  for view_index = grid.beginindex, grid.endindex do
    grid:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  grid.canselect = false
  grid.candestroy = false
  grid.cansplit = false
  grid.canlock = false
  grid.canarrange = false
end
function set_money_text(form, money)
  if not nx_is_valid(form) then
    return
  end
  local text = nx_string(money)
  local CapitalModule = nx_value("CapitalModule")
  if nx_is_valid(CapitalModule) then
    text = CapitalModule:GetFormatCapitalHtml(nx_int(2), nx_int64(money))
  end
  form.mltbox_money.HtmlText = nx_widestr(text)
end
function update_blend_panel(form)
  if not nx_is_valid(form) then
    return
  end
  refresh_blend_role_model(form)
  refresh_recover_btns(form)
  local gui = nx_value("gui")
  local need_money = get_blend_money(form)
  set_money_text(form, need_money)
end
function refresh_recover_btns(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_blend
  if not nx_is_valid(grid) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_BLEND_BOX))
  if not nx_is_valid(view) then
    return
  end
  local player = game_client:GetPlayer()
  form.btn_rehat.Visible = false
  local viewobj_hat = view:GetViewObj("1")
  if nx_is_valid(viewobj_hat) then
    local replace_pack = viewobj_hat:QueryProp("ReplacePack")
    form.btn_rehat.Visible = nx_int(replace_pack) > nx_int(0)
  end
  form.btn_recloth.Visible = false
  local viewobj_cloth = view:GetViewObj("3")
  if nx_is_valid(viewobj_cloth) then
    local replace_pack = viewobj_cloth:QueryProp("ReplacePack")
    form.btn_recloth.Visible = nx_int(replace_pack) > nx_int(0)
  end
  form.btn_repants.Visible = false
  local viewobj_pants = view:GetViewObj("5")
  if nx_is_valid(viewobj_pants) then
    local replace_pack = viewobj_pants:QueryProp("ReplacePack")
    form.btn_repants.Visible = nx_int(replace_pack) > nx_int(0)
  end
  form.btn_reshoes.Visible = false
  local viewobj_shoes = view:GetViewObj("7")
  if nx_is_valid(viewobj_shoes) then
    local replace_pack = viewobj_shoes:QueryProp("ReplacePack")
    form.btn_reshoes.Visible = nx_int(replace_pack) > nx_int(0)
  end
end
function refresh_blend_role_model(form)
  if not nx_is_valid(form) then
    return
  end
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_BLEND_BOX))
  if not nx_is_valid(view) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sex = nx_number(client_player:QueryProp("Sex"))
  local viewobj_hat1 = view:GetViewObj("1")
  local viewobj_hat2 = view:GetViewObj("2")
  if nx_is_valid(viewobj_hat2) then
    refresh_part_model(actor2, viewobj_hat2, "Hat", sex)
  elseif not form.grid_head:IsEmpty(0) then
    refresh_part_model2(actor2, form.grid_head.configid, "Hat", sex)
  else
    refresh_part_model(actor2, viewobj_hat1, "Hat", sex)
  end
  local viewobj_cloth1 = view:GetViewObj("3")
  local viewobj_cloth2 = view:GetViewObj("4")
  if nx_is_valid(viewobj_cloth2) then
    refresh_part_model(actor2, viewobj_cloth2, "Cloth", sex)
  elseif not form.grid_cloth:IsEmpty(0) then
    refresh_part_model2(actor2, form.grid_cloth.configid, "Cloth", sex)
  else
    refresh_part_model(actor2, viewobj_cloth1, "Cloth", sex)
  end
  local viewobj_pants1 = view:GetViewObj("5")
  local viewobj_pants2 = view:GetViewObj("6")
  if nx_is_valid(viewobj_pants2) then
    refresh_part_model(actor2, viewobj_pants2, "Pants", sex)
  elseif not form.grid_pants:IsEmpty(0) then
    refresh_part_model2(actor2, form.grid_pants.configid, "Pants", sex)
  else
    refresh_part_model(actor2, viewobj_pants1, "Pants", sex)
  end
  local viewobj_shoes1 = view:GetViewObj("7")
  local viewobj_shoes2 = view:GetViewObj("8")
  if nx_is_valid(viewobj_shoes2) then
    refresh_part_model(actor2, viewobj_shoes2, "Shoes", sex)
  elseif not form.grid_shoes:IsEmpty(0) then
    refresh_part_model2(actor2, form.grid_shoes.configid, "Shoes", sex)
  else
    refresh_part_model(actor2, viewobj_shoes1, "Shoes", sex)
  end
end
function refresh_part_model(actor2, viewobj, part_name, sex)
  if not nx_is_valid(actor2) then
    return
  end
  local staticdatamgr = nx_value("data_query_manager")
  if not nx_is_valid(staticdatamgr) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local g_sex_prop = {
    [0] = "MaleModel",
    [1] = "FemaleModel"
  }
  local col_name = g_sex_prop[nx_number(sex)]
  local model = ""
  if nx_is_valid(viewobj) then
    local artpack = 0
    local item_type = viewobj:QueryProp("ItemType")
    if nx_int(item_type) >= nx_int(ITEMTYPE_EQUIP_MIN) and nx_int(item_type) <= nx_int(ITEMTYPE_EQUIP_MAX) then
      artpack = viewobj:QueryProp("ReplacePack")
      if nx_int(artpack) <= nx_int(0) then
        artpack = viewobj:QueryProp("ArtPack")
      else
        local replace_id = viewobj:QueryProp("ReplaceID")
        local static_data = ItemQuery:GetItemPropByConfigID(nx_string(replace_id), nx_string("LogicPack"))
        local usesex = item_static_query(nx_int(static_data), "UseSex", STATIC_DATA_ITEM_LOGIC)
        if nx_int(usesex) > nx_int(0) then
          usesex = usesex - 1
        else
          usesex = 2
        end
        if nx_int(usesex) <= nx_int(1) and nx_int(usesex) ~= nx_int(sex) then
          artpack = viewobj:QueryProp("ArtPack")
        end
      end
    elseif nx_int(item_type) >= nx_int(ITEMTYPE_HUANPIMIN) and nx_int(item_type) <= nx_int(ITEMTYPE_HUANPIMAX) then
      artpack = viewobj:QueryProp("ArtPack")
    else
      return
    end
    model = staticdatamgr:Query(nx_int(STATIC_DATA_ITEM_ART), nx_int(artpack), nx_string(col_name))
  else
    model = get_default_model(actor2, part_name)
  end
  link_model(actor2, part_name, model)
end
function refresh_part_model2(actor2, configid, part_name, sex)
  if not nx_is_valid(actor2) then
    return
  end
  local staticdatamgr = nx_value("data_query_manager")
  if not nx_is_valid(staticdatamgr) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local g_sex_prop = {
    [0] = "MaleModel",
    [1] = "FemaleModel"
  }
  local col_name = g_sex_prop[nx_number(sex)]
  local model = ""
  if nx_string(configid) ~= nx_string("") then
    local artpack = 0
    local item_type = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("ItemType"))
    if nx_int(item_type) >= nx_int(ITEMTYPE_EQUIP_MIN) and nx_int(item_type) <= nx_int(ITEMTYPE_EQUIP_MAX) then
      artpack = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("ArtPack"))
    elseif nx_int(item_type) >= nx_int(ITEMTYPE_HUANPIMIN) and nx_int(item_type) <= nx_int(ITEMTYPE_HUANPIMAX) then
      artpack = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("ArtPack"))
    else
      return
    end
    model = staticdatamgr:Query(nx_int(STATIC_DATA_ITEM_ART), nx_int(artpack), nx_string(col_name))
  else
    model = get_default_model(actor2, part_name)
  end
  link_model(actor2, part_name, model)
end
function link_model(actor2, part_name, model)
  if not nx_is_valid(actor2) then
    return
  end
  local cur_model = get_current_model(actor2, part_name)
  if nx_string(cur_model) == nx_string(model) then
    return
  end
  nx_execute("role_composite", "unlink_skin", actor2, nx_string(part_name))
  nx_execute("role_composite", "link_skin", actor2, nx_string(part_name), nx_string(model) .. ".xmod")
  local prop = get_custom_prop("cur", part_name)
  if nx_string(prop) ~= nx_string("") then
    nx_set_custom(actor2, prop, nx_string(model))
  end
end
function get_custom_prop(prefix, part_name)
  local valid_table = {
    "Hat",
    "Cloth",
    "Pants",
    "Shoes"
  }
  for i = 1, table.getn(valid_table) do
    if nx_string(part_name) == nx_string(valid_table[i]) then
      return nx_string(prefix) .. nx_string(part_name)
    end
  end
  return ""
end
function get_default_model(actor2, part_name)
  local model = ""
  if not nx_is_valid(actor2) then
    return model
  end
  local prop = get_custom_prop("def", part_name)
  if nx_string(prop) ~= nx_string("") and nx_find_custom(actor2, nx_string(prop)) then
    model = nx_custom(actor2, nx_string(prop))
  end
  return model
end
function get_current_model(actor2, part_name)
  local model = ""
  if not nx_is_valid(actor2) then
    return model
  end
  local prop = get_custom_prop("cur", part_name)
  if nx_string(prop) ~= nx_string("") and nx_find_custom(actor2, nx_string(prop)) then
    model = nx_custom(actor2, nx_string(prop))
  end
  return model
end
function refresh_place_pos(form, obj)
  if not nx_is_valid(form) or not nx_is_valid(obj) then
    return
  end
  form.grid_blend:SetSelectItemIndex(-1)
  form.grid_head:SetSelectItemIndex(-1)
  form.grid_cloth:SetSelectItemIndex(-1)
  form.grid_pants:SetSelectItemIndex(-1)
  form.grid_shoes:SetSelectItemIndex(-1)
  local lock_status = obj:QueryProp("LockStatus")
  if nx_int(lock_status) > nx_int(0) then
    return
  end
  local item_type = obj:QueryProp("ItemType")
  if nx_int(item_type) >= nx_int(ITEMTYPE_EQUIP_MIN) and nx_int(item_type) <= nx_int(ITEMTYPE_EQUIP_MAX) and not IsFashionOrSuit(obj) then
    form.grid_blend:SetSelectItemIndex(get_place_index(item_type))
  end
end
function get_place_index(item_type)
  for i = 1, table.getn(blendtype_table) do
    if nx_int(item_type) == nx_int(blendtype_table[i]) then
      return i - 1
    end
  end
  return -1
end
function get_huanpi_grid(item_type)
  local form = nx_value("form_stage_main\\form_equipblend")
  if not nx_is_valid(form) then
    return nil
  end
  if nx_int(item_type) == nx_int(ITEMTYPE_HUANPIHEAD) then
    return form.grid_head
  elseif nx_int(item_type) == nx_int(ITEMTYPE_HUANPICLOTH) then
    return form.grid_cloth
  elseif nx_int(item_type) == nx_int(ITEMTYPE_HUANPIPANTS) then
    return form.grid_pants
  elseif nx_int(item_type) == nx_int(ITEMTYPE_HUANPISHOES) then
    return form.grid_shoes
  else
    return nil
  end
end
function have_recover_item(index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_BLEND_BOX))
  if not nx_is_valid(view) then
    return false
  end
  local viewobj = view:GetViewObj(nx_string(index))
  if nx_is_valid(viewobj) then
    if not viewobj:FindProp("ReplacePack") then
      return false
    end
    local replace_pack = viewobj:QueryProp("ReplacePack")
    if nx_int(replace_pack) > nx_int(0) then
      return true
    end
  end
  return false
end
function recover_item(grid, index)
  local gui = nx_value("gui")
  local bindindex = grid:GetBindIndex(index)
  if not grid:IsEmpty(index) and have_recover_item(bindindex) then
    local info = gui.TextManager:GetText("ui_huanpi_tishi_7")
    local res = util_form_confirm("", info)
    if res == "ok" then
      nx_execute("custom_sender", "custom_begin_recover_equip", bindindex)
    end
    return
  end
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("86309"))
end
function GetItemSex(item)
  if not nx_is_valid(item) then
    return 2
  end
  local item_type = item:QueryProp("ItemType")
  if nx_int(item_type) >= nx_int(ITEMTYPE_HUANPIMIN) and nx_int(item_type) <= nx_int(ITEMTYPE_HUANPIMAX) then
    local needsex = item_query_LogicPack(item, Item_UseSex)
    if nx_int(needsex) > nx_int(0) then
      needsex = needsex - 1
    else
      needsex = 2
    end
    return nx_number(needsex)
  elseif nx_int(item_type) >= nx_int(ITEMTYPE_EQUIP_MIN) and nx_int(item_type) <= nx_int(ITEMTYPE_EQUIP_MAX) then
    return nx_number(item:QueryProp("NeedSex"))
  end
  return 2
end
function IsFashionOrSuit(item)
  if not nx_is_valid(item) then
    return false
  end
  if not item:FindProp("EquipType") then
    return false
  end
  local equip_type = item:QueryProp("EquipType")
  if nx_string(equip_type) == nx_string("Suit") or nx_string(equip_type) == nx_string("FashionHat") or nx_string(equip_type) == nx_string("FashionCoat") or nx_string(equip_type) == nx_string("FashionShoes") then
    return true
  end
  return false
end
function get_blend_money(form)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_BLEND_BOX))
  if not nx_is_valid(view) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local money = 0
  local obj = view:GetViewObj("2")
  if nx_is_valid(obj) then
    local configid = obj:QueryProp("ConfigID")
    money = money + get_money(configid)
  end
  obj = view:GetViewObj("4")
  if nx_is_valid(obj) then
    local configid = obj:QueryProp("ConfigID")
    money = money + get_money(configid)
  end
  obj = view:GetViewObj("6")
  if nx_is_valid(obj) then
    local configid = obj:QueryProp("ConfigID")
    money = money + get_money(configid)
  end
  obj = view:GetViewObj("8")
  if nx_is_valid(obj) then
    local configid = obj:QueryProp("ConfigID")
    money = money + get_money(configid)
  end
  money = money + get_money(form.grid_head.configid)
  money = money + get_money(form.grid_cloth.configid)
  money = money + get_money(form.grid_pants.configid)
  money = money + get_money(form.grid_shoes.configid)
  return money
end
function get_money(configid)
  if nx_string(configid) == nx_string("") then
    return 0
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return 0
  end
  local color_level = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("ColorLevel"))
  return 5000
end
function on_gui_size_change()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_equipblend")
  if not nx_is_valid(form) then
    return
  end
  form.Left = 0
  form.Top = 0
  form.Width = gui.Width
  form.Height = gui.Height
end
function get_config_data(scene_id)
  local ini = nx_execute("util_functions", "get_ini", "ini\\equipblend_camera.ini")
  if not nx_is_valid(ini) then
    return 0, 0, 0, 0, 0, 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(scene_id))
  if sec_index < 0 then
    return 0, 0, 0, 0, 0, 0
  end
  local posx = nx_number(ini:ReadString(sec_index, "role_posx", "0"))
  local posy = nx_number(ini:ReadString(sec_index, "role_posy", "0"))
  local posz = nx_number(ini:ReadString(sec_index, "role_posz", "0"))
  local anglex = nx_number(ini:ReadString(sec_index, "role_anglex", "0"))
  local angley = nx_number(ini:ReadString(sec_index, "role_angley", "0"))
  local anglez = nx_number(ini:ReadString(sec_index, "role_anglez", "0"))
  return posx, posy, posz, anglex, angley, anglez
end
function get_config_item(scene_id, item_name)
  local ini = nx_execute("util_functions", "get_ini", "ini\\equipblend_camera.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(scene_id))
  if sec_index < 0 then
    return 0
  end
  local value = nx_number(ini:ReadString(sec_index, nx_string(item_name), "0"))
  return value
end
function get_scene_id()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return nx_int(-1)
  end
  local config_id = client_scene:QueryProp("ConfigID")
  local ini = nx_execute("util_functions", "get_ini", "ini\\scenes.ini")
  if not nx_is_valid(ini) then
    return nx_int(-1)
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local id = ini:GetSectionByIndex(i)
    local config = ini:ReadString(i, "Config", "")
    if nx_string(config) == nx_string(config_id) then
      return nx_int(id)
    end
  end
  return nx_int(-1)
end
function create_role_model(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return nx_null()
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nx_null()
  end
  local client_obj = game_client:GetSceneObj(nx_string(client_player.Ident))
  if not nx_is_valid(client_obj) then
    return nx_null()
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return nx_null()
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return nx_null()
  end
  local actor2 = role_composite:CreateSceneObject(scene, client_obj, false, false)
  if not nx_is_valid(actor2) then
    return nx_null()
  end
  actor2.Visible = false
  while not actor2.LoadFinish do
    nx_pause(0.1)
  end
  nx_execute("game_config", "create_effect", "player_shadow", actor2, actor2, "", "", "", "", "", true)
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  local posx, posy, posz, anglex, angley, anglez = get_config_data(get_scene_id())
  local terrain = scene.terrain
  terrain:AddVisualRole("", actor2)
  terrain:RelocateVisual(actor2, posx, posy, posz)
  terrain:RefreshVisual()
  actor2:SetAngle(anglex, angley, anglez)
  form.actor2 = actor2
  set_default_equip(actor2)
  nx_execute(nx_current(), "puton_default_equip", actor2)
  return actor2
end
function puton_default_equip(actor2)
  if not nx_is_valid(actor2) then
    return
  end
  local face_actor2 = get_role_face(actor2)
  while not nx_is_valid(face_actor2) do
    nx_pause(0.1)
    face_actor2 = get_role_face(actor2)
  end
  if not nx_is_valid(face_actor2) then
    return false
  end
  while not face_actor2.LoadFinish do
    nx_pause(0.1)
  end
  link_model(actor2, "Cloth", actor2.defCloth)
  link_model(actor2, "Hat", actor2.defHat)
  link_model(actor2, "Pants", actor2.defPants)
  link_model(actor2, "Shoes", actor2.defShoes)
  actor2.Visible = true
end
function set_default_equip(actor2)
  local nudemodel_table = {
    [0] = {
      hat = "obj\\char\\b_hair\\b_hair1",
      cloth = "obj\\char\\b_jianghu000\\b_cloth000",
      pants = "obj\\char\\b_jianghu000\\b_pants000",
      shoes = "obj\\char\\b_jianghu000\\b_shoes000"
    },
    [1] = {
      hat = "obj\\char\\g_hair\\g_hair1",
      cloth = "obj\\char\\g_jianghu000\\g_cloth000",
      pants = "obj\\char\\g_jianghu000\\g_pants000",
      shoes = "obj\\char\\g_jianghu000\\g_shoes000"
    }
  }
  if not nx_is_valid(actor2) then
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
  local sex = nx_number(client_player:QueryProp("Sex"))
  actor2.defHat = nudemodel_table[sex].hat
  actor2.defCloth = nudemodel_table[sex].cloth
  actor2.defPants = nudemodel_table[sex].pants
  actor2.defShoes = nudemodel_table[sex].shoes
  local equipbox_view = game_client:GetView(nx_string(VIEWPORT_EQUIP))
  if not nx_is_valid(equipbox_view) then
    return
  end
  local viewobj_hat = equipbox_view:GetViewObj("1")
  local model_hat = get_equip_model(viewobj_hat, sex)
  if model_hat ~= "" then
    actor2.defHat = model_hat
  end
  local viewobj_cloth = equipbox_view:GetViewObj("3")
  local model_cloth = get_equip_model(viewobj_cloth, sex)
  if model_cloth ~= "" then
    actor2.defCloth = model_cloth
  end
  local viewobj_pants = equipbox_view:GetViewObj("4")
  local model_pants = get_equip_model(viewobj_pants, sex)
  if model_pants ~= "" then
    actor2.defPants = model_pants
  end
  local viewobj_shoes = equipbox_view:GetViewObj("8")
  local model_shoes = get_equip_model(viewobj_shoes, sex)
  if model_shoes ~= "" then
    actor2.defShoes = model_shoes
  end
  actor2.curHat = nx_string("")
  actor2.curCloth = nx_string("")
  actor2.curPants = nx_string("")
  actor2.curShoes = nx_string("")
end
function get_equip_model(viewobj, sex)
  if not nx_is_valid(viewobj) then
    return ""
  end
  local staticdatamgr = nx_value("data_query_manager")
  if not nx_is_valid(staticdatamgr) then
    return ""
  end
  local artpack = viewobj:QueryProp("ReplacePack")
  if nx_int(artpack) <= nx_int(0) then
    artpack = viewobj:QueryProp("ArtPack")
  end
  local g_sex_prop = {
    [0] = "MaleModel",
    [1] = "FemaleModel"
  }
  local col_name = g_sex_prop[nx_number(sex)]
  local model = staticdatamgr:Query(nx_int(STATIC_DATA_ITEM_ART), nx_int(artpack), nx_string(col_name))
  return model
end
function get_role_face(role_actor2)
  local actor_role = role_actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  return actor2_face
end
function clear_role_model(form)
  if not nx_is_valid(form.actor2) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return
  end
  terrain:RemoveVisual(form.actor2)
  terrain:RefreshVisual()
end
function set_camera_movie(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  local scene_id = get_scene_id()
  local camera_min_dis = get_config_item(scene_id, "camera_min_dis")
  local camera_max_dis = get_config_item(scene_id, "camera_max_dis")
  local camera_dis = get_config_item(scene_id, "camera_dis")
  local camera_offset_y = get_config_item(scene_id, "camera_offset_y")
  local camera_lookat_scale = get_config_item(scene_id, "camera_lookat_scale")
  camera_min_dis = camera_min_dis == 0 and DEF_CAMERA_MIN_DISTANCE or camera_min_dis
  camera_max_dis = camera_max_dis == 0 and DEF_CAMERA_MAX_DISTANCE or camera_max_dis
  camera_dis = camera_dis == 0 and DEF_CAMERA_DISTANCE or camera_dis
  camera_lookat_scale = camera_lookat_scale == 0 and DEF_CAMERA_LOOKAT_SCALE or camera_lookat_scale
  game_control.CameraMode = GAME_CAMERA_FIXTARGET
  game_control.CameraCollide = false
  local camera_fix = game_control:GetCameraController(GAME_CAMERA_FIXTARGET)
  if not nx_is_valid(camera_fix) then
    return
  end
  camera_fix.CanWheel = true
  camera_fix.CanSlide = true
  camera_fix.ShortDisMode = true
  visual_player.Visible = false
  camera_fix.MinDistance = camera_min_dis
  camera_fix.MaxDistance = camera_max_dis
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local actor_head_height = actor2.BoxSizeY * camera_lookat_scale
  local actor_pos_y = actor2.PositionY + actor_head_height
  local actor_pos_x = actor2.PositionX
  local actor_pos_z = actor2.PositionZ
  local actor_angle_y = actor2.AngleY
  local camera_pos_x = actor_pos_x + camera_dis * math.sin(actor_angle_y)
  local camera_pos_z = actor_pos_z + camera_dis * math.cos(actor_angle_y)
  local camera_pos_y = actor_pos_y + camera_offset_y
  local camera_angle_x = 0
  local camera_angle_y = actor_angle_y + math.pi
  local camera_angle_z = 0
  if camera_pos_y - actor2.PositionY < 0.5 then
    camera_pos_y = actor_pos_y + actor_head_height
    camera_angle_x = math.atan(actor_head_height / camera_dis)
  end
  camera_pos_y = camera_pos_y - actor_head_height / 12
  camera_fix:SetFixTarget(camera_pos_x, camera_pos_y, camera_pos_z, actor_pos_x, actor_pos_y, actor_pos_z)
end
function set_camra_normal(form)
  if not nx_is_valid(form) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local visual_npc = form.actor2
  if not nx_is_valid(visual_npc) then
    return
  end
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.CameraMode = GAME_CAMERA_NORMAL
  game_control.CameraCollide = true
  if CAMERA_ANGLE_X == nil or CAMERA_ANGLE_Y == nil or CAMERA_DISTANCE == nil then
    return
  end
  game_control.PitchAngle = CAMERA_ANGLE_X
  game_control.YawAngle = CAMERA_ANGLE_Y
  game_control.Distance = CAMERA_DISTANCE
end
function set_equipblend_status(value)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local vis_player = game_visual:GetPlayer()
  if not nx_is_valid(vis_player) then
    return
  end
  vis_player.b_equipblend = value
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
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("ItemType"))
  local photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo"))
  local sex = client_player:QueryProp("Sex")
  if nx_number(item_type) >= ITEMTYPE_EQUIP_MIN and nx_number(item_type) <= ITEMTYPE_EQUIP_MAX and 0 ~= sex then
    local tmp_photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "FemalePhoto"))
    if nil ~= tmp_photo and "" ~= tmp_photo then
      photo = tmp_photo
    end
  end
  return photo
end
function can_blend(grid)
  if not nx_is_valid(grid) then
    return false
  end
  local form = grid.ParentForm
  if not ((grid:IsEmpty(0) or grid:IsEmpty(1)) and (grid:IsEmpty(0) or form.grid_head:IsEmpty(0)) and (grid:IsEmpty(2) or grid:IsEmpty(3)) and (grid:IsEmpty(2) or form.grid_cloth:IsEmpty(0)) and (grid:IsEmpty(4) or grid:IsEmpty(5)) and (grid:IsEmpty(4) or form.grid_pants:IsEmpty(0)) and (grid:IsEmpty(6) or grid:IsEmpty(7))) or not grid:IsEmpty(6) and not form.grid_shoes:IsEmpty(0) then
    return true
  end
  return false
end
