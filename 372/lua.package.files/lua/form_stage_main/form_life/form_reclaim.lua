require("utils")
require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\view_define")
require("define\\gamehand_type")
require("share\\item_static_data_define")
local FORM_RECLAIM = "form_stage_main\\form_life\\form_reclaim"
local INI_PATH = "ini\\ui\\SwapGoods\\SwapGoods.ini"
local OT_SWAPGOODS_REQUEST = 1
local OT_SWAPGOODS_HANDLE = 2
local BAG_LEFT = -475
local BAG_TOP = -237
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  change_form_size()
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    BAG_LEFT = form_bag.Left
    BAG_TOP = form_bag.Top
    form_bag.Left = -gui.Width / 2 + form_bag.Width / 2
    form_bag.Top = -form_bag.Height / 2
    if form_bag.Left < -gui.Width then
      form_bag.Left = -gui.Width
    end
  end
end
function on_main_form_close(form)
  nx_destroy(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", false)
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    form_bag.Left = BAG_LEFT
    form_bag.Top = BAG_TOP
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local grid_src = form.imagegrid_src
  if not (nx_find_custom(form, "uid") and nx_find_custom(grid_src, "config_id")) or not nx_find_custom(grid_src, "amount") then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("8971"))
    return
  end
  local uid = nx_string(form.uid)
  local config_id = nx_string(grid_src.config_id)
  local amount = nx_int(grid_src.amount)
  if uid == "" or config_id == "" or amount <= nx_int(0) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("8971"))
    return
  end
  local grid_dst = form.imagegrid_dest
  if not nx_find_custom(grid_dst, "config_id") or not nx_find_custom(grid_dst, "amount") then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("8975"))
    return
  end
  if nx_string(grid_dst.config_id) == nx_string("") or nx_int(grid_dst.amount) <= nx_int(0) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("8975"))
    return
  end
  local gui = nx_value("gui")
  local info = gui.TextManager:GetText("ui_swapgoods_tishi_1")
  local res = util_form_confirm("", info)
  if res ~= "ok" then
    return
  end
  nx_execute("custom_sender", "custom_request_swap_goods", OT_SWAPGOODS_HANDLE, uid, config_id, amount)
end
function on_btn_cancel_click(btn)
  on_btn_close_click(btn)
end
function on_imagegrid_src_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_find_custom(grid, "config_id") then
    return
  end
  local config_id = grid.config_id
  if nx_string(config_id) == nx_string("") then
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
  nx_execute("tips_game", "show_goods_tip", item, x, y, 0, 0, form)
end
function on_imagegrid_src_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_src_select_changed(grid, index)
  local gui = nx_value("gui")
  local form = grid.ParentForm
  local gamehand_type = gui.GameHand.Type
  if not gui.GameHand:IsEmpty() and gamehand_type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    gui.GameHand:ClearHand()
    if nx_int(src_viewid) ~= nx_int(VIEWPORT_EQUIP_TOOL) and nx_int(src_viewid) ~= nx_int(VIEWPORT_TOOL) and nx_int(src_viewid) ~= nx_int(VIEWPORT_MATERIAL_TOOL) and nx_int(src_viewid) ~= nx_int(VIEWPORT_TASK_TOOL) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("8970"))
      return
    end
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    local config_id = viewobj:QueryProp("ConfigID")
    local amount = viewobj:QueryProp("Amount")
    local uid = nx_string(viewobj:QueryProp("UniqueID"))
    nx_execute("custom_sender", "custom_request_swap_goods", OT_SWAPGOODS_REQUEST, uid, config_id, amount)
  end
end
function on_imagegrid_src_rightclick_grid(grid, index)
  clear_image_grid()
end
function on_imagegrid_dest_mousein_grid(grid)
  local form = grid.ParentForm
  if not nx_find_custom(grid, "config_id") then
    return
  end
  local config_id = grid.config_id
  if nx_string(config_id) == nx_string("") then
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
  nx_execute("tips_game", "show_goods_tip", item, x, y, 0, 0, form)
end
function on_imagegrid_dest_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_receive_swap_goods(...)
  if table.getn(arg) < 3 then
    return
  end
  local form = nx_value(FORM_RECLAIM)
  if not nx_is_valid(form) then
    return
  end
  local config_id = nx_string(arg[1])
  local amount = nx_int(arg[2])
  local uid = nx_string(arg[3])
  local dtype = nx_int(arg[4])
  local DTYPE_INVALID = 0
  local DTYPE_SWAPGOODS = 1
  local DTYPE_SWAPNONE = -1
  if nx_int(dtype) == nx_int(DTYPE_SWAPGOODS) then
    form.uid = uid
    form.imagegrid_src.config_id = config_id
    form.imagegrid_src.amount = amount
    local photo = get_photo(config_id)
    form.imagegrid_src:AddItem(0, photo, "", amount, -1)
    local dst_config = nx_string(arg[5])
    local dst_amount = nx_int(arg[6])
    form.imagegrid_dest.config_id = dst_config
    form.imagegrid_dest.amount = dst_amount
    local photo = get_photo(dst_config)
    form.imagegrid_dest:AddItem(0, photo, "", dst_amount, -1)
  elseif nx_int(dtype) == nx_int(DTYPE_SWAPNONE) then
    form.uid = uid
    form.imagegrid_src.config_id = config_id
    form.imagegrid_src.amount = amount
    local photo = get_photo(config_id)
    form.imagegrid_src:AddItem(0, photo, "", amount, -1)
    form.imagegrid_dest:Clear()
    form.imagegrid_dest:SetSelectItemIndex(-1)
    form.imagegrid_dest.config_id = nx_string("")
    form.imagegrid_dest.amount = 0
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("8972"))
  end
end
function clear_image_grid()
  local form = nx_value(FORM_RECLAIM)
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_src:Clear()
  form.imagegrid_src:SetSelectItemIndex(-1)
  form.imagegrid_src.config_id = nx_string("")
  form.imagegrid_src.amount = 0
  form.imagegrid_dest:Clear()
  form.imagegrid_dest:SetSelectItemIndex(-1)
  form.imagegrid_dest.config_id = nx_string("")
  form.imagegrid_dest.amount = 0
  form.uid = ""
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
function open_form(npc_id)
  local gui = nx_value("gui")
  local form = nx_value(FORM_RECLAIM)
  if nx_is_valid(form) then
    form:Close()
  end
  form = util_show_form(FORM_RECLAIM, true)
  if nx_is_valid(form) then
    local ini = get_ini(INI_PATH)
    if not nx_is_valid(ini) then
      return
    end
    if not ini:FindSection(npc_id) then
      return
    end
    local index = ini:FindSectionIndex(npc_id)
    if -1 == index then
      return
    end
    local title_id = ini:ReadString(index, "title_id", "")
    local left_id = ini:ReadString(index, "left_id", "")
    local right_id = ini:ReadString(index, "right_id", "")
    local prompt_id = ini:ReadString(index, "prompt_id", "")
    local content_id = ini:ReadString(index, "content_id", "")
    form.lbl_title_desc.Text = gui.TextManager:GetText(title_id)
    form.lbl_2.Text = gui.TextManager:GetText(left_id)
    form.lbl_3.Text = gui.TextManager:GetText(right_id)
    form.mltbox_inform.HtmlText = gui.TextManager:GetText(prompt_id)
    form.mltbox_list.HtmlText = gui.TextManager:GetText(content_id)
  end
end
function change_form_size()
  local form = nx_value(FORM_RECLAIM)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2 - 150
  form.Top = (gui.Height - form.Height) / 2
end
