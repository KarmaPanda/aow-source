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
local nEquipList = {}
local main_Equip_name = ""
local Sex_man = 0
local Sex_woman = 1
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Top = (gui.Height - form.Height) / 2 - 40
  form.costindex = -1
  form.nEquipIndex = 0
  form.showtips = false
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_EQUIP_CONVERT_BOX, form.ImgCtl_SplitItem, "form_stage_main\\form_life\\form_convert_equip", "on_convert_equip_viewport_changed")
  databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, form, "form_stage_main\\form_life\\form_convert_equip", "on_toolbox_viewport_change")
  clear_form(form)
  show_money(0)
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
  nx_execute("custom_sender", "custom_chang_equip_wx", 1)
  nx_destroy(form)
end
function on_convert_equip_msg(...)
  local msgtype = arg[1]
  if msgtype == 0 then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_convert_equip", true, false)
    if not nx_is_valid(form) then
      return false
    end
    local jobId = arg[2]
    if nx_string(jobId) == "sh_cf" then
      form.lbl_5.Text = nx_widestr("@ui_EquipChange_cf_title")
    elseif nx_string(jobId) == "sh_tj" then
      form.lbl_5.Text = nx_widestr("@ui_EquipChange_tj_title")
    elseif nx_string(jobId) == "sh_jq" then
      form.lbl_5.Text = nx_widestr("@ui_EquipChange_qj_title")
    end
    util_show_form("form_stage_main\\form_life\\form_convert_equip", true)
    nx_execute("util_gui", "ui_show_attached_form", form)
  elseif msgtype == 1 then
    local form = nx_value("form_stage_main\\form_life\\form_convert_equip")
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
  local form = nx_value("form_stage_main\\form_life\\form_convert_equip")
  if not nx_is_valid(form) then
    return
  end
  if costindex < 0 then
    return
  end
  if form.Visible == false then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_CONVERT_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  if table.getn(viewobj_list) < 1 then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local main_item_id = viewobj_list[1]:QueryProp("ConfigID")
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\EquipChangeList.ini")
  if not nx_is_valid(ini) then
    return
  end
  local Player = game_client:GetPlayer()
  local play_sex = Player:QueryProp("Sex")
  local item_list = ini:ReadString(costindex, "ConfigID", "")
  local str_lst = util_split_string(item_list, ",")
  local moneys = ini:ReadString(costindex, "Cost", "")
  local money_lst = util_split_string(moneys, ",")
  local nCounts = table.getn(str_lst)
  local photo_ini = nx_execute("util_functions", "get_ini", "share\\Item\\ItemArtStatic.ini")
  for i = 1, nCounts do
    local item_id = str_lst[i]
    local nAPK = ItemQuery:GetItemPropByConfigID(item_id, "ArtPack")
    local nIndex_PT = photo_ini:FindSectionIndex(nx_string(nAPK))
    local photo = ""
    if play_sex == Sex_woman then
      photo = photo_ini:ReadString(nIndex_PT, "FemalePhoto", "")
    end
    if photo == "" then
      photo = photo_ini:ReadString(nIndex_PT, "Photo", "")
    end
    form.Img_Convert:AddItem(i - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
    form.Img_Convert:ChangeItemImageToBW(i - 1, false)
    local equip_name = gui.TextManager:GetFormatText(item_id)
    nEquipList[i] = {
      name = equip_name,
      money = money_lst[i],
      id = item_id
    }
    local nBtn = form:Find(nx_string("rbtn_Type") .. nx_string(i))
    if not nx_is_valid(nBtn) then
      return
    end
    nBtn.Enabled = true
    nBtn.Checked = false
    if item_id == main_item_id then
      form.Img_Convert:ChangeItemImageToBW(i - 1, true)
      nBtn.Enabled = false
    end
    main_Equip_name = gui.TextManager:GetFormatText(main_item_id)
  end
  form.btn_convert.Enabled = true
  hide_btn(form, nCounts)
end
function show_money(money)
  local form = nx_value("form_stage_main\\form_life\\form_convert_equip")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.mltbox_cost) then
    return
  end
  form.mltbox_cost.HtmlText = nx_widestr("")
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_recast_cost")
  gui.TextManager:Format_AddParam(nx_int(money))
  local text = gui.TextManager:Format_GetText()
  form.mltbox_cost:AddHtmlText(text, -1)
end
function on_rbtn_Type_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.nEquipIndex ~= 0 then
    local lbl_bk1 = form:Find(nx_string("lbl_lk_") .. nx_string(form.nEquipIndex))
    if not nx_is_valid(lbl_bk1) then
      return
    end
    lbl_bk1.Visible = false
  end
  if btn.Name == "rbtn_Type1" then
    form.nEquipIndex = 1
  elseif btn.Name == "rbtn_Type2" then
    form.nEquipIndex = 2
  elseif btn.Name == "rbtn_Type3" then
    form.nEquipIndex = 3
  elseif btn.Name == "rbtn_Type4" then
    form.nEquipIndex = 4
  elseif btn.Name == "rbtn_Type5" then
    form.nEquipIndex = 5
  end
  local lbl_bk = form:Find(nx_string("lbl_lk_") .. nx_string(form.nEquipIndex))
  if not nx_is_valid(lbl_bk) then
    return
  end
  lbl_bk.Visible = true
  show_money(nEquipList[form.nEquipIndex].money)
end
function on_convert_equip_viewport_changed(grid, optype, view_ident, index)
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
    local viewobj = view:GetViewObj(nx_string(index))
    ShowItem(form, view, viewobj, index)
    if optype == "delitem" then
      show_money(0)
      clear_form(form)
    else
      form.showtips = true
    end
  end
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
  local main_item_id = viewobj:QueryProp("ConfigID")
  form.ImgCtl_SplitItem:AddItem(index - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
  form.ImgCtl_SplitItem:ChangeItemImageToBW(index - 1, false)
  local viewobj_list = view:GetViewObjList()
  if 1 > table.getn(viewobj_list) then
    clear_form(form)
  end
end
function on_btn_convert_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_CONVERT_BOX))
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
  if form.nEquipIndex <= 0 then
    return
  end
  gui.TextManager:Format_SetIDName("ui_EquipChange_queding")
  gui.TextManager:Format_AddParam(nx_int(nEquipList[form.nEquipIndex].money))
  dialog.mltbox_1:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "sell_stall_price_input_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    nx_execute("custom_sender", "custom_chang_equip_wx", 0, form.nEquipIndex)
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
    nx_execute("custom_sender", "custom_chang_equip_wx", 2, nx_int(src_viewid), nx_int(src_pos), nx_int(selected_index) + 1)
    gui.GameHand:ClearHand()
  end
end
function on_ImgCtl_SplitItem_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_CONVERT_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    nx_execute("custom_sender", "custom_chang_equip_wx", 3, index + 1)
    clear_form(form)
    show_money(0)
  end
end
function on_ImgCtl_SplitItem_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_CONVERT_BOX))
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
function on_Img_Convert_mousein_grid(grid, index)
  local form = grid.ParentForm
  if form.showtips == false then
    return
  end
  if nEquipList[index + 1] == nil then
    return
  end
  local item_config = nx_string(nEquipList[index + 1].id)
  showitemtips(grid, item_config)
end
function on_Img_Convert_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
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
function hide_btn(form, counts)
  if not nx_is_valid(form) then
    return
  end
  form.Img_Convert.ClomnNum = counts
  for j = counts + 1, 5 do
    local nBtn = form:Find(nx_string("rbtn_Type") .. nx_string(j))
    if nx_is_valid(nBtn) then
      nBtn.Visible = false
    end
  end
end
function clear_form(form)
  form.ImgCtl_SplitItem:Clear()
  form.Img_Convert:Clear()
  form.costindex = -1
  form.btn_convert.Enabled = false
  form.nEquipIndex = 0
  form.rbtn_Type1.Enabled = false
  form.rbtn_Type2.Enabled = false
  form.rbtn_Type3.Enabled = false
  form.rbtn_Type4.Enabled = false
  form.rbtn_Type5.Enabled = false
  form.rbtn_Type6.Visible = false
  form.rbtn_Type6.Checked = true
  form.lbl_lk_1.Visible = false
  form.lbl_lk_2.Visible = false
  form.lbl_lk_3.Visible = false
  form.lbl_lk_4.Visible = false
  form.lbl_lk_5.Visible = false
  form.Img_Convert.ClomnNum = 5
  form.rbtn_Type1.Visible = true
  form.rbtn_Type2.Visible = true
  form.rbtn_Type3.Visible = true
  form.rbtn_Type4.Visible = true
  form.rbtn_Type5.Visible = true
  form.showtips = false
  local tablenum = table.getn(nEquipList)
  for i = 1, tablenum do
    nEquipList[i] = nil
  end
end
