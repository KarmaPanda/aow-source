require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
local SPLIT_BACK_IMAGE = "gui\\special\\fenjie\\guangxiao2.png"
local MATERIAL_BACK_IMAGE = "gui\\special\\fenjie\\guangxiao1.png"
local equip_photo
local equip_list = {}
local equip_bool1 = false
local equip_bool2 = false
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Top = (gui.Height - form.Height) / 2 - 40
  form.costindex = -1
  form.ImgCtl_SplitItem:Clear()
  form.Img_material.Visible = false
  form.Img_replace_equip.Visible = false
  form.lbl_bg.Visible = false
  form.lbl_3.Visible = false
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_BOX_UPGRADE, form.ImgCtl_SplitItem, "form_stage_main\\form_life\\form_upgrade_equip", "on_upgrade_viewport_changed")
  databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, form, "form_stage_main\\form_life\\form_upgrade_equip", "on_toolbox_viewport_change")
end
function on_main_form_close(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) and form_talk.Visible then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_talk")
  if nx_is_valid(form_talk) and form_talk.Visible then
    form_talk:Close()
  end
  nx_execute("custom_sender", "custom_upgrade_equip", 1)
  nx_destroy(form)
end
function on_upgrade_equip_msg(...)
  local msgtype = arg[1]
  if msgtype == 0 then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_upgrade_equip", true, false)
    if not nx_is_valid(form) then
      return false
    end
    local jobId = arg[2]
    if nx_string(jobId) == "sh_cf" then
      form.lbl_title.Text = nx_widestr("@ui_EquipUpgrade_cf_title")
    elseif nx_string(jobId) == "sh_tj" then
      form.lbl_title.Text = nx_widestr("@ui_EquipUpgrade_tj_title")
    elseif nx_string(jobId) == "sh_jq" then
      form.lbl_title.Text = nx_widestr("@ui_EquipUpgrade_qj_title")
    end
    util_show_form("form_stage_main\\form_life\\form_upgrade_equip", true)
    nx_execute("util_gui", "ui_show_attached_form", form)
  elseif msgtype == 1 then
    local form = nx_value("form_stage_main\\form_life\\form_upgrade_equip")
    if not nx_is_valid(form) then
      return
    end
    local costindex = arg[2]
    form.costindex = costindex
    fresh_from(form.costindex)
  elseif msgtype == 2 then
  end
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_toolbox_viewport_change(form, optype)
  if optype == "updateitem" or optype == "additem" or optype == "delitem" then
    fresh_from(form.costindex)
  end
end
function fresh_from(costindex)
  local form = nx_value("form_stage_main\\form_life\\form_upgrade_equip")
  if not nx_is_valid(form) then
    return
  end
  if costindex < 0 then
    form.Img_material.Visible = false
    form.Img_replace_equip.Visible = false
    form.lbl_bg.Visible = false
    form.lbl_3.Visible = false
    form.btn_upgrade.Enabled = false
    return
  end
  if form.Visible == false then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_BOX_UPGRADE))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\UpgradeEquipCost.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\Life\\UpgradeEquipCost.ini" .. get_msg_str("msg_120"))
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(costindex + 1))
  if sec_index < 0 then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  if 1 > table.getn(viewobj_list) then
    return
  end
  form.Img_material.Visible = true
  form.Img_replace_equip.Visible = true
  form.lbl_bg.Visible = true
  form.lbl_3.Visible = true
  form.Img_material:Clear()
  form.Img_replace_equip:Clear()
  local item_list = ini:ReadString(sec_index, "NeedMet", "")
  local str_lst = util_split_string(item_list, ";")
  local flag = false
  local min_num = 999
  local gui = nx_value("gui")
  if 0 < table.getn(str_lst) then
    for i = 1, table.getn(str_lst) do
      local str_temp = util_split_string(str_lst[i], ",")
      local item_id = str_temp[1]
      local need_num = nx_int(str_temp[2])
      if need_num <= nx_int(0) then
        need_num = 1
      end
      local have_num = get_item_num(item_id)
      local bExist = ItemQuery:FindItemByConfigID(item_id)
      local node_name = gui.TextManager:GetFormatText(item_id)
      equip_list[i] = {name = node_name, count = need_num}
      if bExist then
        local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
        if nx_number(have_num) >= nx_number(need_num) then
          form.Img_material:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
          form.Img_material:ChangeItemImageToBW(0, false)
          equip_bool1 = true
        else
          form.Img_material:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
          form.Img_material:ChangeItemImageToBW(0, true)
          equip_bool1 = false
        end
      end
      form.Img_material:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(item_id))
    end
  end
  if table.getn(viewobj_list) == 1 then
    local lv = viewobj_list[1]:QueryProp("ColorLevel")
    if lv == 4 then
      form.cbtn_1.Enabled = false
      form.cbtn_1.Checked = false
    else
      form.cbtn_1.Enabled = true
      form.cbtn_1.Checked = true
    end
  end
  if 1 < table.getn(viewobj_list) then
    local id = viewobj_list[2]:QueryProp("ConfigID")
    local name = gui.TextManager:GetFormatText(id)
    local num = table.getn(equip_list)
    equip_list[num + 1] = {name = name, count = 1}
    equip_bool2 = true
    if equip_bool1 == true and equip_bool2 == true then
      form.btn_upgrade.Enabled = true
    else
      form.btn_upgrade.Enabled = false
    end
    return
  else
    equip_bool2 = false
  end
  form.Img_replace_equip.Visible = true
  item_list = ini:ReadString(sec_index, "NeedCompensate", "")
  str_lst = util_split_string(item_list, ";")
  if 0 < table.getn(str_lst) then
    for i = 1, table.getn(str_lst) do
      local str_temp = util_split_string(str_lst[i], ",")
      local item_id = str_temp[1]
      local need_num = nx_int(str_temp[2])
      if need_num <= nx_int(0) then
        need_num = 1
      end
      local have_num = get_item_num(item_id)
      local bExist = ItemQuery:FindItemByConfigID(item_id)
      local node_name = gui.TextManager:GetFormatText(item_id)
      local num = table.getn(equip_list)
      equip_list[num + i] = {name = node_name, count = need_num}
      if bExist then
        local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
        if nx_number(have_num) >= nx_number(need_num) then
          form.Img_replace_equip:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
          form.Img_replace_equip:ChangeItemImageToBW(0, false)
          equip_bool2 = true
        else
          form.Img_replace_equip:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
          form.Img_replace_equip:ChangeItemImageToBW(0, true)
          equip_bool2 = false
        end
      end
      form.Img_replace_equip:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(item_id))
    end
  end
  if equip_bool1 == true and equip_bool2 == true then
    form.btn_upgrade.Enabled = true
  else
    form.btn_upgrade.Enabled = false
  end
end
function get_item_num(item_id)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  local viewobj_list = view:GetViewObjList()
  for j, obj in pairs(viewobj_list) do
    local tempid = obj:QueryProp("ConfigID")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
    end
  end
  if nx_int(cur_amount) == nx_int(0) then
    viewobj_list = tool:GetViewObjList()
    for j, obj in pairs(viewobj_list) do
      local tempid = obj:QueryProp("ConfigID")
      if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
        cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
      end
    end
  end
  return nx_int(cur_amount)
end
function on_upgrade_viewport_changed(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "additem" or optype == "updateitem" or optype == "delitem" then
    if index == 1 then
      grid.RowNum = 2
      if optype == "delitem" then
        grid.RowNum = 1
        form.costindex = -1
      end
    end
    local viewobj = view:GetViewObj(nx_string(index))
    ShowItem(form, view, viewobj, index)
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    nx_execute("form_stage_main\\form_bag", "refresh_lock_item", form_bag)
  end
  local form = nx_value("form_stage_main\\form_life\\form_upgrade_equip")
  if not nx_is_valid(form) then
    return
  end
  fresh_from(form.costindex)
end
function ShowItem(form, view, viewobj, index)
  if not nx_is_valid(view) then
    return
  end
  if not nx_is_valid(viewobj) then
    form.ImgCtl_SplitItem:DelItem(index - 1)
    return
  end
  local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
  equip_photo = photo
  form.ImgCtl_SplitItem:AddItem(index - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
  form.ImgCtl_SplitItem:ChangeItemImageToBW(index - 1, false)
  local viewobj_list = view:GetViewObjList()
  if 1 > table.getn(viewobj_list) then
    form.Img_material.Visible = false
    form.Img_replace_equip.Visible = false
    form.lbl_bg.Visible = false
    form.lbl_3.Visible = false
  end
end
function on_btn_upgrade_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_BOX_UPGRADE))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  if table.getn(viewobj_list) < 1 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_upgrade_equip_confirm", true, false)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_EquipUpgrade_queding")
  gui.TextManager:Format_AddParam(nx_string(equip_list[1].name))
  gui.TextManager:Format_AddParam(nx_string(equip_list[1].count))
  gui.TextManager:Format_AddParam(nx_string(equip_list[2].name))
  gui.TextManager:Format_AddParam(nx_string(equip_list[2].count))
  dialog.mltbox_1:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "sell_stall_price_input_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    if form.cbtn_1.Checked == true then
      nx_execute("custom_sender", "custom_upgrade_equip", 0, 1)
    else
      nx_execute("custom_sender", "custom_upgrade_equip", 0)
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_upgrade_equip", 1)
end
function on_ImgCtl_SplitItem_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local selected_index = grid:GetSelectItemIndex()
  local gui = nx_value("gui")
  if not gui.GameHand:IsEmpty() and gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local src_amount = nx_int(gui.GameHand.Para3)
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    if not nx_is_valid(view) then
      return
    end
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    nx_execute("custom_sender", "custom_upgrade_equip", 2, nx_int(src_viewid), nx_int(src_pos), nx_int(selected_index) + 1)
    gui.GameHand:ClearHand()
  end
end
function on_ImgCtl_SplitItem_rightclick_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_BOX_UPGRADE))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    nx_execute("custom_sender", "custom_upgrade_equip", 3, index + 1)
  end
  if index == 0 and grid.RowNum == 2 then
    local viewobj = view:GetViewObj(nx_string(index + 2))
    if nx_is_valid(viewobj) then
      nx_execute("custom_sender", "custom_upgrade_equip", 3, index + 2)
    end
  end
end
function on_imagegrid_select_changed(grid)
  local gui = nx_value("gui")
  local selected_index = grid:GetSelectItemIndex()
  if gui.GameHand:IsEmpty() then
    return
  end
  if not grid:IsEmpty(selected_index) then
    return
  end
  if gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local amount = nx_int(gui.GameHand.Para3)
    nx_execute("custom_sender", "custom_upgrade_equip", 2, src_viewid, src_pos, selected_index + 1)
    gui.GameHand:ClearHand()
  end
end
function on_ImgCtl_SplitItem_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_BOX_UPGRADE))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    viewobj.view_obj = viewobj
    nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_ImgCtl_SplitItem_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_Img_result_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "binditemid") then
    return
  end
  local itemid = grid.binditemid
  if itemid ~= nil and itemid ~= "" then
    nx_execute("tips_game", "show_tips_by_config", nx_string(itemid), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), form)
  else
    nx_execute("tips_game", "hide_tip", form)
  end
end
function on_Img_result_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_Img_replace_equip_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(2))
  showitemtips(grid, item_config)
end
function showitemtips(grid, item_config)
  if nx_string(item_config) == nx_string("") or nx_string(item_config) == nx_string("nil") then
    return
  end
  local item_name, item_type
  local ItemQuery = nx_value("ItemQuery")
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(ItemQuery) or not nx_is_valid(IniManager) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if nx_string(bExist) == nx_string("true") then
    item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
    item_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Level"))
    local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
    local prop_array = {}
    prop_array.ConfigID = nx_string(item_config)
    prop_array.ItemType = nx_int(item_type)
    prop_array.Level = nx_int(item_level)
    prop_array.SellPrice1 = nx_int(item_sellPrice1)
    prop_array.Photo = nx_string(photo)
    prop_array.is_static = true
    if not nx_is_valid(grid.Data) then
      grid.Data = nx_create("ArrayList")
    end
    grid.Data:ClearChild()
    for prop, value in pairs(prop_array) do
      nx_set_custom(grid.Data, prop, value)
    end
    nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_Img_replace_equip_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_Img_material_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(2))
  showitemtips(grid, item_config)
end
function on_Img_material_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function spare_equip_photo_to_BW(form)
  form.ImgCtl_SplitItem:AddItem(1, nx_string(equip_photo), nx_widestr(""), nx_int(0), nx_int(0))
  form.ImgCtl_SplitItem:ChangeItemImageToBW(1, true)
end
