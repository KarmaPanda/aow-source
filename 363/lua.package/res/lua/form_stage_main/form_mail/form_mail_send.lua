require("share\\view_define")
require("util_functions")
require("share\\capital_define")
require("form_stage_main\\form_relation\\relation_define")
require("goods_grid")
local form_name = "form_stage_main\\form_mail\\form_mail_send"
local xinge_photo = "icon\\prop\\prop_xinge.png"
local table_send_name = {
  [1] = "",
  [2] = "",
  [3] = "",
  [4] = "",
  [5] = "",
  [6] = "",
  [7] = "",
  [8] = "",
  [9] = "",
  [10] = ""
}
function get_mail_ini_file()
  local file_name = "mail.ini"
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and nx_find_property(game_config, "login_account") then
    local account = game_config.login_account
    file_name = account .. "\\" .. "mail.ini"
  end
  return file_name
end
function main_form_init(self)
  get_sendname_from_ini()
  return 1
end
function main_form_open(self)
  add_pigeon(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_POST_BOX, self.postbox, form_name, "on_view_operat")
    databinder:AddViewBind(VIEWPORT_TOOL, self, form_name, "disp_pigeon_number")
    databinder:AddRolePropertyBind("CapitalType2", "int", self, form_name, "disp_money")
  end
  self.targetname.is_select_change = false
  self.mltbox_trade_desc.Visible = false
  set_view_info(self)
  disp_money(self)
  refresh_targetname()
  self.rbtn_nothing.Checked = true
  self.rbtn_nothing.Visible = false
  on_sendsilver_changed(self)
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:ViewRefreshGrid(self.postbox)
  end
  return 1
end
function main_form_close(self)
  save_sendname_to_ini()
  nx_destroy(self)
end
function set_view_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.postbox.typeid = VIEWPORT_POST_BOX
  form.postbox.canselect = true
  form.postbox.candestroy = false
  form.postbox.cansplit = false
  form.postbox.canlock = false
  form.postbox:SetBindIndex(0, 1)
end
function disp_money(self)
  if not nx_is_valid(self) then
    return
  end
  local capital_module = nx_value("CapitalModule")
  if not nx_is_valid(capital_module) then
    return
  end
  local money = capital_module:GetCapital(CAPITAL_TYPE_SILVER_CARD)
  local ding, liang, wen = 0, 0, 0
  ding, liang, wen = trans_price(money)
  self.lbl_money.Text = nx_widestr(ding) .. nx_widestr(util_text("ui_Ding")) .. nx_widestr(liang) .. nx_widestr(util_text("ui_Liang")) .. nx_widestr(wen) .. nx_widestr(util_text("ui_Wen"))
end
function add_pigeon(form)
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_xinge:AddItem(0, xinge_photo, "", 1, -1)
end
function disp_pigeon_number(self)
  if not nx_is_valid(self) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\post.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(nx_string("Post"))
  if index < 0 then
    return
  end
  local pigeon_number = 0
  local strPlaceItem = ini:ReadString(index, "ReplaceItem", "")
  local str_lst = util_split_string(nx_string(strPlaceItem), ",")
  local arg_count = table.getn(str_lst)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  pigeon_number = get_item_num_by_configid("mail_xinge")
  if client_player:FindRecord("sable_rec") then
    local row_num = client_player:GetRecordRows("sable_rec")
    for i = 0, row_num - 1 do
      local config = client_player:QueryRecord("sable_rec", i, 3)
      for j = 1, arg_count do
        if str_lst[j] == config then
          pigeon_number = 999
          break
        end
      end
    end
  end
  self.lbl_xinge_num.Text = nx_widestr(pigeon_number)
  if nx_number(pigeon_number) == nx_number(0) then
    self.imagegrid_xinge:ChangeItemImageToBW(0, true)
    self.lbl_xingge.Visible = true
  else
    self.imagegrid_xinge:ChangeItemImageToBW(0, false)
    self.lbl_xingge.Visible = false
  end
end
function get_item_num_by_configid(configid)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local view_id = goods_grid:GetToolBoxViewport(nx_string(configid))
  local toolbox_view = game_client:GetView(nx_string(view_id))
  local pigeon_number = 0
  if nx_is_valid(toolbox_view) then
    local obj_lst = toolbox_view:GetViewObjList()
    for j, obj in pairs(obj_lst) do
      local obj_id = obj:QueryProp("ConfigID")
      if nx_string(obj_id) == nx_string(configid) then
        local num = obj:QueryProp("Amount")
        pigeon_number = pigeon_number + num
      end
    end
  end
  return pigeon_number
end
function send_on_click(self)
  local form = self.Parent
  form.send.BackImage = "gui\\mail\\send_mail\\xz02.png"
  form.accept.BackImage = "gui\\mail\\send_mail\\xz01.png"
  return 1
end
function accept_on_click(self)
  local form = self.Parent
  form.send.BackImage = "gui\\mail\\send_mail\\xz01.png"
  form.accept.BackImage = "gui\\mail\\send_mail\\xz02.png"
  return 1
end
function form_error(form, text)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
  dialog.mltbox_info:Clear()
  local info = gui.TextManager:GetFormatText(text)
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog.Left = form.Left + (form.Width - dialog.Width) / 2
  dialog.Top = form.Top + (form.Height - dialog.Height) / 2
  dialog:ShowModal()
  nx_wait_event(100000000, dialog, "error_return")
end
function on_sendletter_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local targetname = nx_widestr(form.targetname.Text)
  local lettername = nx_widestr(form.lettername.Text)
  local content = nx_widestr(form.lettercontent.Text)
  local gold = 0
  if targetname == nx_widestr("") or lettername == nx_widestr("") then
    form_error(form, "ui_mail_suggestive_1")
    return
  end
  local trademoney = "0"
  local silver = "0"
  local total = nx_int64(form.sendsilver.Text) * 1000000 + nx_int64(form.sendsilver1.Text) * 1000 + nx_int64(form.sendsilver2.Text)
  if form.rbtn_send.Checked then
    trademoney = nx_string(0)
    silver = nx_string(total)
  elseif form.rbtn_trade.Checked then
    trademoney = nx_string(total)
    silver = nx_string(0)
    if form.postbox:IsEmpty(0) then
      form_error(form, "mail_tips")
      return
    end
  else
    return
  end
  local have_tip = false
  local tip_text = ""
  local item_data = GoodsGrid:GetItemData(form.postbox, 0)
  local item_id = nx_execute("tips_data", "get_prop_in_item", item_data, "ConfigID")
  local item_name = gui.TextManager:GetText(item_id)
  local BaseName = nx_execute("tips_data", "get_prop_in_item", item_data, "BaseName")
  if BaseName ~= 0 then
    local tips_manager = nx_value("tips_manager")
    if nx_is_valid(tips_manager) then
      item_name = tips_manager:GetItemBaseNameByValue(nx_int(BaseName))
    end
  end
  if trademoney ~= nx_string(0) then
    tip_text = util_format_string("ui_mail_chushou", item_name, targetname, total)
    have_tip = true
  elseif not form.postbox:IsEmpty(0) and silver ~= nx_string(0) then
    tip_text = util_format_string("ui_mail_jisong3", item_name, nx_int64(silver), targetname)
    have_tip = true
  elseif form.postbox:IsEmpty(0) and silver ~= nx_string(0) then
    tip_text = util_format_string("ui_mail_jisong1", nx_int64(silver), targetname)
    have_tip = true
  elseif not form.postbox:IsEmpty(0) and silver == nx_string(0) then
    tip_text = util_format_string("ui_mail_jisong2", item_name, targetname)
    have_tip = true
  end
  if not have_tip then
    nx_execute("custom_sender", "custom_send_letter", targetname, lettername, content, gold, silver, trademoney)
  else
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    dialog.mltbox_info.HtmlText = nx_widestr(tip_text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_send_letter", targetname, lettername, content, gold, silver, trademoney)
    end
  end
end
function on_targetname_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not nx_find_custom(form.targetname, "is_select_change") then
    return
  end
  if form.targetname.is_select_change then
    form.targetname.is_select_change = false
    return
  end
  local text = nx_string(self.Text)
  while string.find(text, "%(") == 1 do
    text = string.sub(text, 2)
  end
  if string.len(text) == 0 then
    refresh_targetname()
    return
  end
  form.combobox_targetname.DropListBox:ClearString()
  local table_temp = {}
  for i = 1, table.getn(table_send_name) do
    if 0 <= nx_function("ext_ws_find", nx_widestr(table_send_name[i]), nx_widestr(text)) then
      table.insert(table_temp, nx_string(table_send_name[i]))
    end
  end
  local rows = player:GetRecordRows(FRIEND_REC)
  for i = 0, rows - 1 do
    local name = player:QueryRecord(FRIEND_REC, i, 1)
    if 0 <= nx_function("ext_ws_find", nx_widestr(name), nx_widestr(text)) and not table_is_have_value(table_temp, name) then
      table.insert(table_temp, nx_string(name))
    end
  end
  rows = player:GetRecordRows(BUDDY_REC)
  for i = 0, rows - 1 do
    local name = player:QueryRecord(BUDDY_REC, i, 1)
    if 0 <= nx_function("ext_ws_find", nx_widestr(name), nx_widestr(text)) and not table_is_have_value(table_temp, name) then
      table.insert(table_temp, nx_string(name))
    end
  end
  rows = player:GetRecordRows(ATTENTION_REC)
  for i = 0, rows - 1 do
    local name = player:QueryRecord(ATTENTION_REC, i, 1)
    if 0 <= nx_function("ext_ws_find", nx_widestr(name), nx_widestr(text)) and not table_is_have_value(table_temp, name) then
      table.insert(table_temp, nx_string(name))
    end
  end
  rows = player:GetRecordRows(JIESHI_REC)
  for i = 0, rows - 1 do
    local name = player:QueryRecord(JIESHI_REC, i, 1)
    if 0 <= nx_function("ext_ws_find", nx_widestr(name), nx_widestr(text)) and not table_is_have_value(table_temp, name) then
      table.insert(table_temp, nx_string(name))
    end
  end
  for i = 1, table.getn(table_temp) do
    form.combobox_targetname.DropListBox:AddString(nx_widestr(table_temp[i]))
  end
  if not form.combobox_targetname.DroppedDown then
    form.combobox_targetname.DroppedDown = true
  end
end
function on_targetname_lost_focus()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  if form.combobox_targetname.DroppedDown then
    form.combobox_targetname.DroppedDown = false
  end
end
function table_is_have_value(_table, value)
  for i = 1, table.getn(_table) do
    if nx_string(_table[i]) == nx_string(value) then
      return true
    end
  end
  return false
end
function on_combobox_targetname_selected()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.targetname.is_select_change = true
  form.targetname.Text = form.combobox_targetname.Text
  form.combobox_targetname.Text = nx_widestr("")
end
function on_send_letter_result(result)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  save_sendname(form.targetname.Text)
  refresh_targetname()
  form.lettername.Text = ""
  form.lettercontent.Text = ""
  form.sendsilver.Text = nx_widestr("")
  form.sendsilver1.Text = nx_widestr("")
  form.sendsilver2.Text = nx_widestr("")
end
function save_sendname(name)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local table_temp = {}
  table.insert(table_temp, nx_string(name))
  for i = 1, table.getn(table_send_name) do
    if nx_string(table_send_name[i]) ~= nx_string(name) then
      table.insert(table_temp, nx_string(table_send_name[i]))
    end
  end
  for j = 1, table.getn(table_send_name) do
    table_send_name[j] = table_temp[j]
  end
end
function refresh_targetname()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.combobox_targetname.DropListBox:ClearString()
  for i = 1, table.getn(table_send_name) do
    if nx_string(table_send_name[i]) ~= nx_string("") then
      form.combobox_targetname.DropListBox:AddString(nx_widestr(table_send_name[i]))
    end
  end
end
function get_sendname_from_ini()
  local ini = load_ini(get_mail_ini_file())
  if not nx_is_valid(ini) then
    return
  end
  local sendnames = ini_get_value(ini, "sendname", "name")
  local table_temp = util_split_string(sendnames, ",")
  for i = 1, table.getn(table_temp) do
    table_send_name[i] = nx_string(table_temp[i])
  end
  nx_destroy(ini)
end
function save_sendname_to_ini()
  local ini = load_ini(get_mail_ini_file())
  if not nx_is_valid(ini) then
    return
  end
  local sendnames = ""
  for i = 1, table.getn(table_send_name) do
    if nx_string(table_send_name[i]) ~= "" then
      if sendnames == "" then
        sendnames = nx_string(table_send_name[i])
      else
        sendnames = sendnames .. "," .. nx_string(table_send_name[i])
      end
    end
  end
  ini_set_value(ini, "sendname", "name", nx_string(sendnames))
  ini:SaveToFile()
  nx_destroy(ini)
end
function on_cancelsend_click(self)
  local form = self.Parent
  form.targetname.Text = ""
  form.lettername.Text = ""
  form.lettercontent.Text = ""
  form.sendsilver.Text = nx_widestr("")
  form.sendsilver1.Text = nx_widestr("")
  form.sendsilver2.Text = nx_widestr("")
  nx_execute("custom_sender", "custom_cancel_send_letter")
end
function on_postbox_rightclick_grid(self, index)
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    local view_index = self:GetBindIndex(index)
    local view_obj = get_view_item(self.typeid, view_index)
    if nx_is_valid(view_obj) then
      local view_id = ""
      local goods_grid = nx_value("GoodsGrid")
      if nx_is_valid(goods_grid) then
        view_id = goods_grid:GetToolBoxViewport(view_obj)
        goods_grid:ViewGridPutToAnotherView(self, view_id)
      end
    end
  end
end
function on_postbox_select_changed(self)
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(self, -1)
end
function on_view_operat(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  if optype == "createview" then
    GoodsGrid:ViewRefreshGrid(grid)
  elseif optype == "deleteview" then
    GoodsGrid:ViewRefreshGrid(grid)
  elseif optype == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
  if form.rbtn_trade.Checked then
    local obj_list = view:GetViewObjList()
    if table.getn(obj_list) == 0 then
      form.sendletter.Enabled = false
    else
      form.sendletter.Enabled = true
    end
  end
end
function on_mousein_grid(self, index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(self, index)
  nx_execute("tips_game", "show_goods_tip", item_data, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 32, 32, self.ParentForm)
end
function on_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function refresh_goods_grid_index(self)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local grid_index = 0
  for view_index = 1, 3 do
    self.postbox:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
end
function trans_price(price)
  price = nx_int64(price)
  local price_ding = nx_int64(price / 1000000)
  local temp = nx_int64(price - price_ding * 1000000)
  local price_liang = nx_int64(temp / 1000)
  local price_wen = nx_int64(temp - price_liang * 1000)
  return price_ding, price_liang, price_wen
end
function on_rbtn_send_click(btn)
  local self = btn.ParentForm
  on_sendsilver_changed(self)
end
function on_rbtn_trade_click(btn)
  local self = btn.ParentForm
  on_sendsilver_changed(self)
end
function get_toolitem_info(item_id)
  if nx_string(item_id) == "" then
    return ""
  end
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return ""
  end
  if not IniManager:IsIniLoadedToManager("share\\Item\\tool_item.ini") then
    IniManager:LoadIniToManager("share\\Item\\tool_item.ini")
  end
  local ItemIni = IniManager:GetIniDocument("share\\Item\\tool_item.ini")
  if not nx_is_valid(ItemIni) then
    return ""
  end
  local sec_index = ItemIni:FindSectionIndex(nx_string(item_id))
  if sec_index < 0 then
    nx_log("share\\Item\\tool_item.ini sec_index= " .. nx_string(item_id))
    return ""
  end
  local itemtype = ItemIni:ReadString(sec_index, "ItemType", "")
  local itemMaxAmoun = ItemIni:ReadInteger(sec_index, "MaxAmount", 1)
  local itemname = ItemIni:ReadString(sec_index, "Name", "")
  local itemPhoto = ItemIni:ReadString(sec_index, "Photo", "")
  local itemSellPrice1 = ItemIni:ReadInteger(sec_index, "SellPrice1", 1)
  local prop_table = {}
  prop_table.ConfigID = nx_string("mail_xinge")
  prop_table.ItemType = nx_int(itemtype)
  prop_table.MaxAmount = nx_int(itemMaxAmoun)
  prop_table.Name = nx_string(itemname)
  prop_table.Photo = nx_string(itemPhoto)
  prop_table.SellPrice1 = nx_string(itemSellPrice1)
  local pigeon_number = get_item_num_by_configid("pet_niao_1")
  if pigeon_number <= 0 then
    pigeon_number = get_item_num_by_configid("mail_xinge")
  else
    pigeon_number = "999"
  end
  prop_table.Amount = pigeon_number
  return prop_table
end
function on_imagegrid_xinge_mousein_grid(self)
  if not nx_is_valid(self.Data) then
    self.Data = nx_create("ArrayList", nx_current())
  end
  local prop_table = {}
  prop_table = get_toolitem_info(nx_string("mail_xinge"))
  for prop, value in pairs(prop_table) do
    nx_set_custom(self.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", self.Data, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 32, 32, self.ParentForm)
end
function on_imagegrid_xinge_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function sliver_lost_capture()
end
function on_sendsilver_changed(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local boxview = game_client:GetView(nx_string(VIEWPORT_POST_BOX))
  if not nx_is_valid(boxview) then
    return
  end
  if form.rbtn_send.Checked then
    form.lbl_post_type.Text = gui.TextManager:GetText("ui_PostCapital")
    form.sendletter.HintText = nx_widestr("")
    form.sendletter.Enabled = true
    form.mltbox_trade_desc.Visible = false
  elseif form.rbtn_trade.Checked then
    form.lbl_post_type.Text = gui.TextManager:GetText("ui_GetCapital")
    form.sendletter.HintText = nx_widestr("")
    local obj_list = boxview:GetViewObjList()
    if table.getn(obj_list) == 0 then
      form.sendletter.Enabled = false
    else
      form.sendletter.Enabled = true
    end
    form.mltbox_trade_desc.Visible = true
  else
    form.lbl_post_type.Text = nx_widestr("")
    form.sendletter.Enabled = false
    form.sendletter.HintText = gui.TextManager:GetText("ui_mail_select_type")
    form.mltbox_trade_desc.Visible = false
  end
end
function load_ini(path)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(path)
  ini:LoadFromFile()
  return ini
end
function ini_set_value(ini, section, item, value)
  if not nx_is_valid(ini) then
    return
  end
  if nx_string(value) == "" then
    ini:DeleteItem(nx_string(section), nx_string(item))
  else
    ini:WriteString(nx_string(section), nx_string(item), nx_string(value))
  end
end
function ini_get_value(ini, section, item)
  if not nx_is_valid(ini) then
    return ""
  end
  return ini:ReadString(nx_string(section), nx_string(item), "")
end
