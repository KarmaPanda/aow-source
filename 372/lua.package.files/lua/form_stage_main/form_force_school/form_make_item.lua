require("share\\view_define")
require("share\\capital_define")
require("utils")
require("util_gui")
MAKEITEM_CTS_LOCK = 1
MAKEITEM_CTS_MAKE = 2
MAKEITEM_CTS_SEL_ITEM = 3
MAKEITEM_CTS_CANCEL = 4
MAKEITEM_CTS_SET_MONEY = 5
STATE_MAKING = 1
STATE_BUY_ITEM = 2
local g_ex_capital_type = 2
local rbtn_item_list = {
  [1] = {1, "rbtn_1"},
  [2] = {2, "rbtn_2"},
  [3] = {3, "rbtn_3"},
  [4] = {4, "rbtn_4"}
}
function main_form_init(form)
  form.Fixed = false
  form.info_id = 0
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_MAKEITEM_SELF_EXCHANGE, form, nx_current(), "on_self_exchange_view_operat")
  databinder:AddViewBind(VIEWPORT_MAKEITEM_OTHER_EXCHANGE, form, nx_current(), "on_other_exchange_view_operat")
  form.rbtn_1.Checked = true
  initwindow(form)
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(form)
  nx_execute("custom_sender", "custom_make_item", MAKEITEM_CTS_CANCEL)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_ImageControlGrid_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(2))
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
function on_ImageControlGrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_lock_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  info_id = form.info_id
  nx_execute("custom_sender", "custom_make_item", MAKEITEM_CTS_LOCK, nx_int(info_id))
end
function on_btn_make_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  info_id = form.info_id
  nx_execute("custom_sender", "custom_make_item", MAKEITEM_CTS_MAKE, nx_int(info_id))
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_make_item(form, rbtn.Name)
end
function on_self_exchange_view_operat(grid, optype, view_ident, index)
  local gui = nx_value("gui")
  if not nx_is_valid(grid) then
    return 1
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  if optype == "updateview" then
    local make_state = nx_int(client_player:QueryProp("MakeState"))
    local islock = view:QueryProp("ExchangeIsLock")
    local price = view:QueryProp("MakeItemPrice")
    if nx_int(1) == nx_int(make_state) then
      lockstate(form, STATE_MAKING, islock)
    else
      lockstate(form, STATE_BUY_ITEM, islock)
    end
  end
  return 1
end
function on_other_exchange_view_operat(grid, optype, view_ident, index)
  local gui = nx_value("gui")
  if not nx_is_valid(grid) then
    return 1
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  if optype == "updateview" then
    local make_state = nx_int(client_player:QueryProp("MakeState"))
    local islock = view:QueryProp("ExchangeIsLock")
    local price = view:QueryProp("MakeItemPrice")
    if nx_int(1) == nx_int(make_state) then
      local id = view:QueryProp("ExchangeItemID")
      refresh_item(form, id)
      lockstate(form, STATE_BUY_ITEM, islock)
    else
      setprice(form, price)
      lockstate(form, STATE_MAKING, islock)
    end
  end
  return 1
end
function on_ipt_changed(ipt)
  local form = ipt.ParentForm
  local text = nx_string(ipt.Text)
  if string.find(text, "%D") then
    text = string.gsub(text, "%D", "")
    ipt.Text = nx_widestr(text)
    return
  end
  if not is_maker() then
    return
  end
  local capital_manager = nx_value("CapitalModule")
  local max_silver = capital_manager:GetCapital(g_ex_capital_type)
  local silver0 = nx_number(form.ipt_1.Text)
  local silver1 = nx_number(form.ipt_2.Text)
  local silver2 = nx_number(form.ipt_3.Text)
  local silver = silver0 * 1000000 + silver1 * 1000 + silver2
  if is_lock() then
    silver = get_cur_price()
    local ding, liang, wen = trans_price(silver)
    form.ipt_1.Text = nx_widestr(ding)
    form.ipt_2.Text = nx_widestr(liang)
    form.ipt_3.Text = nx_widestr(wen)
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7212"))
    return
  end
  nx_execute("custom_sender", "custom_make_item", MAKEITEM_CTS_SET_MONEY, silver)
end
function on_server_msg(msgid, ...)
  if nx_int(msgid) == nx_int(1) then
    util_show_form("form_stage_main\\form_force_school\\form_make_item", true)
  elseif nx_int(msgid) == nx_int(2) then
    util_show_form("form_stage_main\\form_force_school\\form_make_item", false)
  elseif nx_int(msgid) == nx_int(3) then
  elseif nx_int(msgid) == nx_int(4) then
  end
end
function select_make_item(form, rbtn_name)
  if is_lock() then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7212"))
    return
  end
  if is_maker() then
    return
  end
  for i = 1, table.getn(rbtn_item_list) do
    if nx_string(rbtn_name) == nx_string(rbtn_item_list[i][2]) then
      form_materia_fresh(form, nx_int(rbtn_item_list[i][1]))
      nx_execute("custom_sender", "custom_make_item", MAKEITEM_CTS_SEL_ITEM, nx_int(rbtn_item_list[i][1]))
      return
    end
  end
end
function refresh_item(form, id)
  form_materia_fresh(form, id)
end
function lockstate(form, make_state, lock)
  if nx_int(STATE_BUY_ITEM) == nx_int(make_state) then
    local count = table.getn(rbtn_item_list)
    if nx_int(1) == nx_int(lock) then
      form.lbl_lock.Visible = true
    else
      form.lbl_lock.Visible = false
    end
  elseif nx_int(1) == nx_int(lock) then
    form.lbl_price_lock.Visible = true
  else
    form.lbl_price_lock.Visible = false
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
function form_materia_fresh(form, id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\taohua_mask_interaction.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(nx_string(id))
  if nx_int(0) > nx_int(index) then
    return
  end
  local sys_price = ini:ReadInteger(index, "SystenPrice", 0)
  setsysprice(form, nx_int(sys_price))
  local intimate = ini:ReadInteger(index, "IntimateCost", 0)
  form.lbl_cost_intimate.Text = nx_widestr(intimate)
  form.info_id = id
  local make_state = nx_int(client_player:QueryProp("MakeState"))
  if nx_int(1) == nx_int(make_state) then
    local item_id = ini:ReadString(index, "Item", "")
    set_item_info(form, item_id)
    local materia_info = ini:ReadString(index, "MakerMaterial", "")
    set_materia_info(form, materia_info)
  else
    local materia_info = ini:ReadString(index, "RequestMaterial", "")
    set_materia_info(form, materia_info)
  end
end
function initwindow(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local make_state = nx_int(client_player:QueryProp("MakeState"))
  if nx_int(STATE_MAKING) == nx_int(make_state) then
    form.btn_make.Visible = true
    form.btn_lock.Visible = true
    form.groupbox_1.Visible = false
    form.groupbox_2.Visible = true
  else
    form.btn_make.Visible = false
    form.btn_lock.Visible = true
    form.groupbox_1.Visible = true
    form.groupbox_2.Visible = false
    form.ipt_1.Enabled = false
    form.ipt_2.Enabled = false
    form.ipt_3.Enabled = false
  end
  form.lbl_lock.Visible = false
  form.lbl_price_lock.Visible = false
end
function is_maker()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local make_state = nx_int(client_player:QueryProp("MakeState"))
  if nx_int(1) == nx_int(make_state) then
    return true
  end
  return false
end
function is_lock()
  local game_client = nx_value("game_client")
  local box = game_client:GetView(nx_string(VIEWPORT_MAKEITEM_SELF_EXCHANGE))
  if not nx_is_valid(box) then
    return false
  end
  local islock = box:QueryProp("ExchangeIsLock")
  return nx_int(0) < nx_int(islock)
end
function get_cur_price()
  if not is_maker then
    return
  end
  local game_client = nx_value("game_client")
  local box = game_client:GetView(nx_string(VIEWPORT_MAKEITEM_SELF_EXCHANGE))
  if not nx_is_valid(box) then
    return false
  end
  local price = box:QueryProp("MakeItemPrice")
  return price
end
function get_cur_sel_item()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local make_state = nx_int(client_player:QueryProp("MakeState"))
  if nx_int(STATE_MAKING) == nx_int(make_state) then
    return 0
  end
  local box = game_client:GetView(nx_string(VIEWPORT_MAKEITEM_SELF_EXCHANGE))
  if not nx_is_valid(box) then
    return 0
  end
  local id = box:QueryProp("ExchangeItemID")
  return id
end
function setprice(form, price)
  local capital_manager = nx_value("CapitalModule")
  if not nx_is_valid(capital_manager) then
    return
  end
  local res = {}
  res = capital_manager:SplitCapital(nx_int(price), CAPITAL_TYPE_SILVER)
  local ding = res[1]
  local liang = res[2]
  local wen = res[3]
  form.ipt_1.Text = nx_widestr(ding)
  form.ipt_2.Text = nx_widestr(liang)
  form.ipt_3.Text = nx_widestr(wen)
end
function setsysprice(form, price)
  local capital_manager = nx_value("CapitalModule")
  if not nx_is_valid(capital_manager) then
    return
  end
  local res = {}
  res = capital_manager:SplitCapital(nx_int(price), CAPITAL_TYPE_SILVER)
  local ding = res[1]
  local liang = res[2]
  local wen = res[3]
  form.lbl_sys_ding.Text = nx_widestr(ding)
  form.lbl_sys_liang.Text = nx_widestr(liang)
  form.lbl_sys_wen.Text = nx_widestr(wen)
end
function set_materia_info(form, materia_info)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local str_lst = util_split_string(materia_info, ";")
  form.ImageControlGrid:Clear()
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    local item_id = nx_string(str_temp[1])
    local need_num = nx_int(str_temp[2])
    local have_num = get_item_num(item_id)
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item_id))
    if bExist then
      local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
      if nx_number(have_num) < nx_number(need_num) then
        form.ImageControlGrid:AddItem(nx_int(i - 1), photo, nx_widestr("<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
        form.ImageControlGrid:ChangeItemImageToBW(nx_int(i - 1), true)
      else
        form.ImageControlGrid:AddItem(nx_int(i - 1), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
        form.ImageControlGrid:ChangeItemImageToBW(nx_int(i - 1), false)
      end
      form.ImageControlGrid:SetItemAddInfo(nx_int(i - 1), nx_int(2), nx_widestr(item_id))
    end
  end
end
function set_item_info(form, item_id)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_id))
  form.ImageControlGrid_Make:Clear()
  if bExist then
    local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    gui.TextManager:Format_SetIDName("ui_mask_choice_01")
    gui.TextManager:Format_AddParam(util_text(item_id))
    local text = gui.TextManager:Format_GetText()
    form.ImageControlGrid_Make:AddItem(nx_int(0), photo, text, 0, -1)
    form.ImageControlGrid_Make:ChangeItemImageToBW(0, false)
    form.ImageControlGrid_Make:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(item_id))
  end
end
function get_main_materia_info()
  local ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\taohua_basicmask_interaction.ini")
  local index = ini:FindSectionIndex("Config")
  if nx_int(0) > nx_int(index) then
    return ""
  end
  local materia_info = ini:ReadString(index, "MakerMaterial", "")
  return materia_info
end
function trans_price(price)
  local price_ding = nx_int64(price / 1000000)
  local temp = nx_int64(price - price_ding * 1000000)
  local price_liang = nx_int64(temp / 1000)
  local price_wen = nx_int64(temp - price_liang * 1000)
  return price_ding, price_liang, price_wen
end
