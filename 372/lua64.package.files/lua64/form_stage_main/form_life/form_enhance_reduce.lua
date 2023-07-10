require("util_functions")
require("share\\view_define")
require("util_gui")
require("define\\gamehand_type")
require("share\\itemtype_define")
require("share\\chat_define")
require("const_define")
require("define\\object_type_define")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\npc_type_define")
require("util_vip")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("define\\gamehand_type")
require("game_object")
require("define\\request_type")
local form_name = "form_stage_main\\form_life\\form_enhance_reduce"
local equip_sale_cost_info = {}
local equip_sale_info = {}
local name_to_id = {}
function main_form_init(self)
  self.Fixed = false
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return 0
  end
  nx_execute("util_functions", "get_ini", "share\\Life\\equip_sale_cost.ini")
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.selectItemId = ""
  self.view_id = 0
  self.BagPoint = -1
  self.JobId = ""
  self.type = 0
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_EQUIP_TOOL, self, "form_stage_main\\form_life\\form_enhance_reduce", "on_equip_viewport_change")
  databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, self, "form_stage_main\\form_life\\form_enhance_reduce", "on_material_viewport_change")
end
function on_main_form_close(self)
  if self.view_id == 0 then
    nx_gen_event(self, "form_enhance_reduce_input_return", nx_string(self.selectItemId))
  end
  self.selectItemId = ""
  self.view_id = 0
  self.BagPoint = -1
  self.JobId = ""
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(self)
    databinder:DelViewBind(self)
  end
  nx_destroy(self)
end
function on_open_form(view_id, index, jobid)
  local dialog1 = nx_value("form_stage_main\\form_life\\form_enhance_reduce")
  if nx_is_valid(dialog1) then
    dialog1:Close()
    if nx_is_valid(dialog1) then
      nx_destroy(dialog1)
    end
  end
  local form = util_get_form(form_name, true, true)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local toolbox_view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(toolbox_view) then
    return
  end
  local viewobj = toolbox_view:GetViewObj(nx_string(index))
  if not nx_is_valid(viewobj) then
    return
  end
  if nx_int(viewobj:QueryProp("ColorLevel")) > nx_int(4) then
    nx_execute("custom_sender", "custom_send_qianghua", view_id, index, nx_string(jobid))
    form:Close()
    return
  end
  local PropGetPack = viewobj:QueryProp("PropGetPack")
  local equip_sale1 = nx_execute("util_functions", "get_ini", "share\\Rule\\equip_prop_rand.ini")
  if not nx_is_valid(equip_sale1) then
    return
  end
  local sec_index1 = equip_sale1:FindSectionIndex(nx_string(PropGetPack))
  if sec_index1 == -1 then
    return
  end
  local need_jobid = equip_sale1:ReadString(sec_index1, "JobName", "")
  if need_jobid ~= jobid then
    return
  end
  local money1 = equip_sale1:ReadInteger(sec_index1, "Cost", 0)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.combobox_1.Text = nx_widestr(gui.TextManager:GetFormatText("ui_wxz"))
  form.combobox_1.DropListBox:ClearString()
  if fresh_combox(form, viewobj, money1) then
    form.Visible = true
    form:Show()
    form.view_id = view_id
    form.BagPoint = index
    form.JobId = jobid
  else
    nx_execute("custom_sender", "custom_send_qianghua", view_id, index, nx_string(jobid))
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_gen_event(form, "form_enhance_reduce_input_return", nx_string("close_ui"))
  form.Visible = false
  form:Close()
end
function get_treeview_bg(bglvl, bgtype)
  local path = "gui\\common\\treeview\\tree_" .. nx_string(bglvl) .. "_" .. nx_string(bgtype) .. ".png"
  return nx_string(path)
end
function on_btn_click_click(btn)
  local form = btn.ParentForm
  if form.type == 0 and form.view_id ~= 0 then
    nx_execute("custom_sender", "custom_send_qianghua", form.view_id, form.BagPoint, nx_string(form.JobId), nx_string(form.selectItemId))
  end
  form:Close()
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
function on_Img_replace_equip_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  grid:Clear()
  form.selectItemId = ""
  refurbish_money(form, form.money)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.btn_click.Enabled = true
  form.combobox_1.Text = nx_widestr(gui.TextManager:GetFormatText("ui_wxz"))
end
function on_tree_item_mouse_in_node(treeView)
  local node = treeView.SelectNode
  treeView:BeginUpdate()
  node.NodeFocusImage = get_treeview_bg(2, "on")
  node.NodeSelectImage = get_treeview_bg(2, "on")
  treeView:EndUpdate()
end
function on_Img_mousein_by_ConfigID_grid(grid, index)
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
function on_Img_equip_upgrade_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function fresh_combox(form, viewobj, money)
  form.money = money
  local equip_sale2 = nx_execute("util_functions", "get_ini", "share\\life\\equip_sale.ini")
  local nCount2 = equip_sale2:GetSectionCount()
  if nCount2 < 1 then
    return false
  end
  for i = 0, nCount2 - 1 do
    local nLevel = equip_sale2:ReadString(i, "level", "")
    local str_ColorLevel = equip_sale2:ReadString(i, "ColorLevel", "")
    local str_Reduce = equip_sale2:ReadString(i, "Reduce", "")
    local colorlevel_list = util_split_string(str_ColorLevel, ",")
    local Reduce_list = util_split_string(str_Reduce, ",")
    local num = table.getn(colorlevel_list)
    if num > table.getn(Reduce_list) then
      num = table.getn(Reduce_list)
    end
    local name_itmeid = equip_sale2:GetSectionByIndex(i)
    local op = {}
    for j = 1, num do
      local key = nx_number(colorlevel_list[j])
      local nValue = nx_int(Reduce_list[j])
      op[key] = Reduce_list[j]
    end
    equip_sale_info[nx_string(name_itmeid)] = op
    equip_sale_info[nx_string(name_itmeid)].level = nLevel
  end
  local equip_type = viewobj:QueryProp("EquipType")
  form.colorLevel = viewobj:QueryProp("ColorLevel")
  form.uid = viewobj:QueryProp("UniqueID")
  form.level = viewobj:QueryProp("Level")
  local equip_sale_cost = nx_execute("util_functions", "get_ini", "share\\life\\equip_sale_cost.ini")
  if not nx_is_valid(equip_sale_cost) then
    return false
  end
  if equip_type == "" or equip_type == "nil" then
    return false
  end
  local sec_index = equip_sale_cost:FindSectionIndex(nx_string(equip_type))
  if sec_index < 0 then
    return false
  end
  local NeedMet = equip_sale_cost:ReadString(sec_index, "NeedMet", "")
  if NeedMet == "" then
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local str_lst = util_split_string(NeedMet, ",")
  local key = nx_number(form.colorLevel)
  local nBool = false
  for i = 1, table.getn(str_lst) do
    local str = str_lst[i]
    if is_in_level(form.level, equip_sale_info[str].level) and equip_sale_info[str][key] ~= nil then
      local str_quanbu = gui.TextManager:GetFormatText(str)
      form.combobox_1.DropListBox:AddString(nx_widestr(str_quanbu))
      name_to_id[nx_string(str_quanbu)] = str
      nBool = true
    end
  end
  refurbish_money(form, form.money)
  return nBool
end
function fresh_form_by_itemId(form)
  if form.selectItemId == "" then
    return
  end
  local item_id = form.selectItemId
  local have_num = get_item_num(item_id)
  local need_num = 1
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(item_id)
  if bExist then
    local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
    if nx_number(have_num) >= nx_number(need_num) then
      form.Img_replace_equip:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
      form.Img_replace_equip:ChangeItemImageToBW(0, false)
      form.btn_click.Enabled = true
    else
      form.Img_replace_equip:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
      form.Img_replace_equip:ChangeItemImageToBW(0, true)
      form.btn_click.Enabled = false
    end
  end
  form.Img_replace_equip:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(item_id))
  local equip_sale = nx_execute("util_functions", "get_ini", "share\\life\\equip_sale.ini")
  if not nx_is_valid(equip_sale) then
  end
  local sec_index = equip_sale:FindSectionIndex(nx_string(item_id))
  if sec_index < 0 then
    return false
  end
  local reduce = equip_sale:ReadString(sec_index, "Reduce", "")
  local str_ColorLevel = equip_sale:ReadString(sec_index, "ColorLevel", "")
  local str_lst = util_split_string(reduce, ",")
  local str_ColorLt = util_split_string(str_ColorLevel, ",")
  local size = table.getn(str_lst)
  for i = 1, size do
    if nx_string(form.colorLevel) == nx_string(str_ColorLt[i]) then
      local money = form.money - nx_int(str_lst[i])
      refurbish_money(form, money)
    end
  end
end
function refurbish_money(form, money)
  local yd = math.floor(money / 1000000)
  local yl = math.floor(money % 1000000 / 1000)
  local wen = money % 1000
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local yd_text = nx_widestr("")
  local yl_text = nx_widestr("")
  local wen_text = nx_widestr("")
  if yd == 0 and yl == 0 and wen == 0 then
    yl_text = nx_widestr(yl) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText("ui_change_equip_yl"))
  else
    if yd ~= 0 then
      yd_text = nx_widestr(yd) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText("ui_change_equip_yd")) .. nx_widestr("  ")
    end
    if yl ~= 0 then
      yl_text = nx_widestr(yl) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText("ui_change_equip_yl")) .. nx_widestr("  ")
    end
    if wen ~= 0 then
      wen_text = nx_widestr(wen) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText("ui_change_equip_wen"))
    end
  end
  form.mltbox_1.HtmlText = nx_widestr(yd_text) .. nx_widestr(yl_text) .. nx_widestr(wen_text)
end
function on_combobox_1_selected(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local id = name_to_id[nx_string(self.Text)]
  form.selectItemId = id
  fresh_form_by_itemId(form)
end
function is_in_level(level, strLevel)
  local level_list = util_split_string(strLevel, ",")
  for i = 1, table.getn(level_list) do
    if level_list[i] == nx_string(level) then
      return true
    end
  end
  return false
end
function on_equip_viewport_change(form, optype)
  if optype == "updateitem" or optype == "additem" or optype == "delitem" then
    if not nx_is_valid(form) then
      return
    end
    if not fresh_upgrade_from(form) then
      form.selectItemId = "close_ui"
      form:Close()
    end
  end
end
function on_material_viewport_change(form, optype, view_ident, index)
  if optype == "updateitem" or optype == "additem" or optype == "delitem" then
    local curr_form = nx_value(nx_current())
    if not nx_is_valid(curr_form) then
      return
    end
    local ItemQuery = nx_value("ItemQuery")
    if not nx_is_valid(ItemQuery) then
      return
    end
    local item_id = curr_form.selectItemId
    local bExist = ItemQuery:FindItemByConfigID(item_id)
    if not bExist then
      return
    end
    local have_num = get_item_num(item_id)
    local need_num = 1
    local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
    if nx_number(have_num) >= nx_number(need_num) then
      curr_form.Img_replace_equip:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
      curr_form.Img_replace_equip:ChangeItemImageToBW(0, false)
      curr_form.btn_click.Enabled = true
    else
      curr_form.Img_replace_equip:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
      curr_form.Img_replace_equip:ChangeItemImageToBW(0, true)
      curr_form.btn_click.Enabled = false
    end
  end
end
function fresh_upgrade_from(form)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_TOOL))
  if not nx_is_valid(view) then
    return false
  end
  local viewobj_list = view:GetViewObjList()
  local viewobj = view:GetViewObj(nx_string(form.BagPoint))
  if not nx_is_valid(viewobj) then
    return false
  end
  if nx_string(form.uid) == nx_string(viewobj:QueryProp("UniqueID")) then
    return true
  end
  return false
end
