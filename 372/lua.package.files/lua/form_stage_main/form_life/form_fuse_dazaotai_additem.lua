require("utils")
require("util_gui")
require("util_functions")
require("util_static_data")
require("tips_data")
require("custom_sender")
require("share\\view_define")
require("define\\gamehand_type")
require("define\\tip_define")
require("share\\client_custom_define")
require("share\\itemtype_define")
require("share\\static_data_type")
require("share\\item_static_data_define")
require("share\\chat_define")
local SUBMSG_CLIENT_ADDITEM_MATERIAL = 1
local SUBMSG_CLIENT_REMOVE_MATERIAL = 2
local SUBMSG_CLIENT_CANCEL_FUSE = 3
local SUBMSG_CLIENT_FUSE_DAZAOTAI = 4
local TYPE_MAIN_MATERIAL = 0
local TYPE_SUB_MATERIAL = 1
function main_form_init(form)
  form.Fixed = false
  form.amount = 0
  form.item_config_id = ""
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.grid_put.typeid = VIEWPORT_DAZAOTAI_FUSE_MAIN_BOX
  form.grid_put.canselect = true
  form.grid_put.candestroy = false
  form.grid_put.cansplit = false
  form.grid_put.canlock = false
  form.grid_put.canarrange = false
  form.grid_put:SetBindIndex(0, 1)
  form.grid_put_sub.typeid = VIEWPORT_DAZAOTAI_FUSE_SUB_BOX
  form.grid_put_sub.canselect = true
  form.grid_put_sub.candestroy = false
  form.grid_put_sub.cansplit = false
  form.grid_put_sub.canlock = false
  form.grid_put_sub.canarrange = false
  for i = 1, 4 do
    form.grid_put_sub:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_DAZAOTAI_FUSE_MAIN_BOX, form.grid_put, "form_stage_main\\form_life\\form_fuse_dazaotai_additem", "on_additem_view_oper")
  databinder:AddViewBind(VIEWPORT_DAZAOTAI_FUSE_SUB_BOX, form.grid_put_sub, "form_stage_main\\form_life\\form_fuse_dazaotai_additem", "on_additem_view_oper")
  form.amount = 0
  return 1
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FUSE_DAZAOTAI), nx_int(SUBMSG_CLIENT_CANCEL_FUSE))
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FUSE_DAZAOTAI), nx_int(SUBMSG_CLIENT_CANCEL_FUSE))
  end
  nx_destroy(form)
end
function bind_grid(form, grid, index, item_id)
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  goods_grid:GridDelItem(grid, index - 1)
  local item_count = 1
  local item_type = nx_number(get_prop_in_ItemQuery(item_id, nx_string("ItemType")))
  local item_data = nx_create("ArrayList", nx_current())
  if not nx_is_valid(item_data) then
    return
  end
  item_data.ConfigID = item_id
  item_data.Count = item_count
  item_data.item_type = item_type
  goods_grid:GridAddItem(grid, index - 1, item_data)
  grid:SetBindIndex(index - 1, index)
  local photo = ""
  if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    photo = item_query_ArtPack_by_id(item_id, "Photo")
  else
    photo = get_prop_in_ItemQuery(item_id, nx_string("Photo"))
  end
  grid:AddItem(index - 1, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
end
function on_additem_view_oper(grid, op_type, view_ident, index)
  if not nx_is_valid(grid) then
    return false
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return false
  end
  if op_type == "createview" then
    GoodsGrid:GridClear(grid)
  elseif op_type == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif op_type == "additem" then
    local item = game_client:GetViewObj(nx_string(view_ident), nx_string(index))
    if nx_is_valid(item) then
      local item_id = item:QueryProp("ConfigID")
      bind_grid(form, grid, index, item_id)
    end
  elseif op_type == "delitem" then
    GoodsGrid:GridDelItem(grid, index - 1)
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif op_type == "updateitem" then
  end
  if view_ident == VIEWPORT_DAZAOTAI_FUSE_MAIN_BOX then
    bind_grid_make(form)
  else
    set_probability(form)
  end
  return true
end
function on_grid_put_select_changed(grid, index)
  local gui = nx_value("gui")
  local selected_index = grid:GetSelectItemIndex()
  local dest_pos = selected_index + 1
  local dest_viewid = grid.typeid
  local form = grid.ParentForm
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return
  end
  if gui.GameHand:IsEmpty() then
    return false
  end
  if not grid:IsEmpty(selected_index) then
    return false
  end
  if gui.GameHand.Type == GHT_VIEWITEM and grid.typeid > 0 then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local amount = nx_int(gui.GameHand.Para3)
    form.amount = 1
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    local cant_exchange = 0
    if viewobj:FindProp("CantExchange") then
      cant_exchange = viewobj:QueryProp("CantExchange")
      if nx_int(cant_exchange) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
        return
      end
    end
    local lock_status = 0
    if viewobj:FindProp("LockStatus") then
      lock_status = viewobj:QueryProp("LockStatus")
      if nx_int(lock_status) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7054"))
        return
      end
    end
    if nx_number(src_viewid) ~= VIEWPORT_EQUIP_TOOL and nx_number(src_viewid) ~= VIEWPORT_TOOL and nx_number(src_viewid) ~= VIEWPORT_MATERIAL_TOOL and nx_number(src_viewid) ~= VIEWPORT_TASK_TOOL then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
      return
    end
    if viewobj:FindProp("ConfigID") then
      form.item_config_id = viewobj:QueryProp("ConfigID")
    else
      form.item_config_id = ""
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return false
    end
    local put_type = TYPE_MAIN_MATERIAL
    local grid_name = grid.Name
    if grid_name == "grid_put_sub" then
      put_type = TYPE_SUB_MATERIAL
    end
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if not nx_is_valid(SystemCenterInfo) then
      return
    end
    local item_config_id = viewobj:QueryProp("ConfigID")
    if put_type == TYPE_MAIN_MATERIAL then
      if not fuse_formula_query:CheckMainItemID(item_config_id) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_jzinfo_1"), 2)
        return
      end
    elseif put_type == TYPE_SUB_MATERIAL then
      if not fuse_formula_query:CheckSubItemID(item_config_id) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_jzinfo_1"), 2)
        return
      end
    else
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FUSE_DAZAOTAI), nx_int(SUBMSG_CLIENT_ADDITEM_MATERIAL), nx_int(src_viewid), nx_int(src_pos), nx_int(dest_viewid), nx_int(dest_pos), nx_int(put_type))
    gui.GameHand:ClearHand()
  end
end
function on_grid_put_right_click(grid, index)
  if grid:IsEmpty(index) then
    return false
  end
  local view_index = grid:GetBindIndex(index)
  local form = grid.ParentForm
  form.amount = 0
  local remove_type = TYPE_MAIN_MATERIAL
  local grid_name = grid.Name
  if grid_name == "grid_put_sub" then
    remove_type = TYPE_SUB_MATERIAL
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FUSE_DAZAOTAI), nx_int(SUBMSG_CLIENT_REMOVE_MATERIAL), nx_int(view_index), nx_int(remove_type))
end
function on_grid_put_mousein_grid(grid, index)
  local form = grid.ParentForm
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  else
    nx_execute("tips_game", "hide_tip", grid.ParentForm)
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_DAZAOTAI_FUSE_MAIN_BOX))
  if nx_is_valid(view) then
    local bind_index = grid:GetBindIndex(index)
    local viewobj = view:GetViewObj(nx_string(bind_index))
    nx_execute("form_stage_main\\form_life\\form_job_main_new", "chang_life_skill_photo", viewobj)
  end
  if grid:IsEmpty(index) then
    return false
  end
  local item_data = grid.Data:GetChild(nx_string(index))
  if not nx_is_valid(item_data) then
    return false
  end
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft() + 32, grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_grid_put_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_ok_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local grid = form.grid_put
  if grid:IsEmpty(0) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_jzinfo_9"), 2)
    end
    return false
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local baoben_flag = 0
  if form.cbtn_baoben.Checked then
    baoben_flag = 1
    local text = nx_widestr(util_text("ui_jz_sure_02"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  else
    local text = nx_widestr(util_text("ui_jz_sure_01"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  end
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  if not nx_is_valid(form) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FUSE_DAZAOTAI), nx_int(SUBMSG_CLIENT_FUSE_DAZAOTAI), nx_int(baoben_flag))
end
function on_cbtn_baoben_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return
  end
  if cbtn.Checked then
    local cur_nobind_money = nx_int64(client_player:QueryProp("CapitalType2"))
    local need_nobind_money = fuse_formula_query:GetBaoBenNeedSliver()
    if cur_nobind_money < nx_int64(need_nobind_money) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_jzinfo_12"), 2)
      end
      cbtn.Checked = false
    else
      form.lbl_silver.Text = nx_widestr(need_nobind_money / 1000)
    end
  else
    form.lbl_silver.Text = nx_widestr(0)
  end
end
function bind_grid_make(form)
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local grid = form.grid_make
  goods_grid:GridClear(grid)
  local make_id = fuse_formula_query:GetMakeItemID()
  if make_id == "" then
    return
  end
  local item_id = make_id
  local item_count = 1
  local item_type = nx_number(get_prop_in_ItemQuery(item_id, nx_string("ItemType")))
  local item_data = nx_create("ArrayList", nx_current())
  if not nx_is_valid(item_data) then
    return
  end
  item_data.ConfigID = item_id
  item_data.Count = item_count
  item_data.item_type = item_type
  goods_grid:GridAddItem(grid, 0, item_data)
  grid:SetBindIndex(0, 1)
  local photo = ""
  if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    photo = item_query_ArtPack_by_id(item_id, "Photo")
  else
    photo = get_prop_in_ItemQuery(item_id, nx_string("Photo"))
  end
  grid:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
end
function on_grid_make_get_capture(grid, index)
  local form = grid.ParentForm
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  else
    nx_execute("tips_game", "hide_tip", grid.ParentForm)
  end
end
function on_grid_make_lost_capture(grid, index)
  local form = grid.ParentForm
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function set_probability(form)
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return
  end
  local flag = fuse_formula_query:CheckProbabilityFlag()
  if fuse_formula_query:CheckProbabilityFlag() then
    form.lbl_rand.Text = nx_widestr("@ui_jz_high")
  else
    form.lbl_rand.Text = nx_widestr("@ui_jz_low")
  end
end
function do_equipblend(grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return true
  end
  local form = nx_value("form_stage_main\\form_life\\form_fuse_dazaotai_additem")
  if not nx_is_valid(form) then
    return true
  end
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return
  end
  local view_id = 0
  local pos = 0
  local put_type = 0
  local main_grid = form.grid_put
  if main_grid:IsEmpty(0) then
    view_id = VIEWPORT_DAZAOTAI_FUSE_MAIN_BOX
    pos = 1
    put_type = nx_int(TYPE_MAIN_MATERIAL)
  else
    local sub_grid = form.grid_put_sub
    for i = 0, 4 do
      if sub_grid:IsEmpty(i) then
        view_id = VIEWPORT_DAZAOTAI_FUSE_SUB_BOX
        pos = i + 1
        put_type = nx_int(TYPE_SUB_MATERIAL)
        break
      end
    end
  end
  if view_id == 0 then
    return
  end
  local blend_view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(blend_view) then
    return true
  end
  local VIEW_MAIN = grid.main_typeid
  local tool_view = game_client:GetView(nx_string(VIEW_MAIN))
  if not nx_is_valid(tool_view) then
    return true
  end
  local bind_index = grid:GetBindIndex(index)
  local viewobj = tool_view:GetViewObj(nx_string(bind_index))
  if not nx_is_valid(viewobj) then
    return true
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local item_id = viewobj:QueryProp("ConfigID")
  if put_type == nx_int(TYPE_MAIN_MATERIAL) then
    if not fuse_formula_query:CheckMainItemID(item_id) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_jzinfo_1"), 2)
      return
    end
  elseif put_type == nx_int(TYPE_SUB_MATERIAL) then
    if not fuse_formula_query:CheckSubItemID(item_id) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_jzinfo_1"), 2)
      return
    end
  else
    return
  end
  local lock_status = viewobj:QueryProp("LockStatus")
  if nx_int(lock_status) > nx_int(0) then
    return true
  end
  local item_type = viewobj:QueryProp("ItemType")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FUSE_DAZAOTAI), nx_int(SUBMSG_CLIENT_ADDITEM_MATERIAL), nx_int(VIEWPORT_MATERIAL_TOOL), nx_int(bind_index), nx_int(view_id), nx_int(pos), nx_int(put_type))
  return true
end
