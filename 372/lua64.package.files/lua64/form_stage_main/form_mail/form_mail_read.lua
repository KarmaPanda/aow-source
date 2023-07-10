require("share\\view_define")
require("util_functions")
require("share\\capital_define")
require("share\\itemtype_define")
local form_name = "form_stage_main\\form_mail\\form_mail_read"
local Recv_rec_name = "RecvLetterRec"
local LETTER_SYSTEM_TYPE_MIN = 100
local LETTER_SYSTEM_POST_USER = 101
local LETTER_SYSTEM_TEACH_NOTIFY = 102
local LETTER_SYSTEM_SINGLE_DIVORCE_NOTIFY = 103
local LETTER_SYSTEM_LOVER_RELATION_FREE = 104
local LETTER_SYSTEM_FRIEND = 105
local LETTER_USER_POST_TASK = 106
local LETTER_USER_OWNER_CROP_RECORD = 108
local LETTER_SYSTEM_TYPE_MAX = 199
local LETTER_USER_TYPE_MIN = 0
local LETTER_USER_POST_USER = 1
local LETTER_USER_POST_BACK_USER_OUT_TIME = 2
local LETTER_USER_POST_BACK_USER_REFUSE = 3
local LETTER_USER_POST_BACK_USER_FULL = 4
local LETTER_USER_POST_TRADE = 5
local LETTER_USER_POST_TRADE_PAY = 6
local LETTER_USER_WHISPER_USER = 10
local LETTER_USER_TYPE_MAX = 99
local POST_TABLE_SENDNAME = 0
local POST_TABLE_SENDUID = 1
local POST_TABLE_TYPE = 2
local POST_TABLE_LETTERNAME = 3
local POST_TABLE_VALUE = 4
local POST_TABLE_GOLD = 5
local POST_TABLE_SILVER = 6
local POST_TABLE_APPEDIXVALUE = 7
local POST_TABLE_DATE = 8
local POST_TABLE_READFLAG = 9
local POST_TABLE_SERIALNO = 10
local POST_TABLE_TRADE_MONEY = 11
local POST_TABLE_SELECT = 12
local POST_TABLE_LEFT_TIME = 13
local POST_TABLE_TRADE_DONE = 14
local mail_appendix_backimage = "gui\\common\\form_back\\bg_text.png"
local mail_trade_appendix_backimage = "gui\\common\\form_back\\bg_text_red.png"
function main_form_init(self)
  self.Fixed = false
  self.serial_no = ""
  return 1
end
function main_form_open(form)
  local gui = nx_value("gui")
  local databinder = nx_value("data_binder")
  if databinder then
    databinder:AddRolePropertyBind("CapitalType2", "int", form, form_name, "disp_money")
    databinder:AddTableBind(Recv_rec_name, form, form_name, "on_recv_box_refresh")
  end
  nx_execute("tips_game", "move_tip_to_front")
  read_mail(form)
  disp_money(form)
  form.Visible = true
  return 1
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
  ding, liang, wen = nx_execute("form_stage_main\\form_mail\\form_mail_send", "trans_price", money)
  self.lbl_money.Text = nx_widestr(nx_widestr(ding) .. nx_widestr(util_text("ui_Ding")) .. nx_widestr(liang) .. nx_widestr(util_text("ui_Liang")) .. nx_widestr(wen) .. nx_widestr(util_text("ui_Wen")))
end
function pop_on_click(self)
  local gui = nx_value("gui")
  form_mail_pop = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_mail\\form_mail_pop", true, false)
  form_mail_pop:ShowModal()
  return 1
end
function main_form_close(self)
  nx_execute("custom_sender", "custom_close_mail_readbox")
  nx_destroy(self)
end
function on_close_click(self)
  local form = self.Parent
  form.Visible = false
  form:Close()
  return 1
end
function on_view_operat(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "updateview" then
  elseif optype == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif optype == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
end
function on_recv_box_refresh(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
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
  local serial_no = form.serial_no
  if serial_no == nil or nx_string(serial_no) == "" then
    return
  end
  form.pick_up.Enabled = is_have_appendix(form)
  form.delete.Visible = is_have_trade(serial_no)
  local row = client_player:FindRecordRow(Recv_rec_name, POST_TABLE_SERIALNO, serial_no, 0)
  if row < 0 then
    return
  end
  local appedix = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_APPEDIXVALUE)
  if nx_string(appedix) == "" then
    form.recvbox:Clear()
  end
end
function on_get_appendix_click(self)
  local form = self.ParentForm
  local serial_no = form.serial_no
  if serial_no == nil or nx_string(serial_no) == "" then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:FindRecordRow(Recv_rec_name, POST_TABLE_SERIALNO, serial_no, 0)
  if row < 0 then
    return
  end
  local ntype = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TYPE)
  if nx_int(ntype) == nx_int(LETTER_USER_POST_TRADE) then
    local trade = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TRADE_MONEY)
    local tip_text = util_format_string("ui_tips_4", nx_int64(trade))
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    dialog.mltbox_info.HtmlText = nx_widestr(tip_text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_get_appendix", serial_no)
    end
  else
    nx_execute("custom_sender", "custom_get_appendix", serial_no)
  end
end
function is_have_appendix(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local serial_no = form.serial_no
  if serial_no == nil or nx_string(serial_no) == "" then
    return false
  end
  local row = client_player:FindRecordRow(Recv_rec_name, POST_TABLE_SERIALNO, serial_no, 0)
  if row < 0 then
    return false
  end
  local ntype = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TYPE)
  if nx_int(ntype) == nx_int(LETTER_USER_POST_TRADE) then
    local left_time = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_LEFT_TIME)
    local trade_done = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TRADE_DONE)
    if left_time <= 0 or trade_done == 1 then
      return false
    end
  else
    local silver = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_SILVER)
    local appedix = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_APPEDIXVALUE)
    local trade = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TRADE_MONEY)
    if nx_string(trade) == nx_string("0") and nx_string(silver) == nx_string("0") and not string.find(appedix, "Object") then
      return false
    end
  end
  return true
end
function on_get_money_success(ntype)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_ding.Text = nx_widestr(0)
  form.lbl_liang.Text = nx_widestr(0)
  form.lbl_wen.Text = nx_widestr(0)
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  form:Close()
  local form_mail = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_mail\\form_mail", true, true)
  if not nx_is_valid(form_mail) then
    return
  end
  if not form_mail.Visible then
    form_mail:Show()
  end
  if not form_mail.acceptpage.Visible then
    form_mail.accept.Checked = true
    nx_execute("form_stage_main\\form_mail\\form_mail", "accept_on_click", form_mail.accept)
  end
end
function on_delete_click(self)
  local form = self.Parent
  local serial_no = form.serial_no
  if serial_no == nil or nx_string(serial_no) == "" then
    return
  end
  nx_execute("custom_sender", "custom_del_letter", 1, serial_no)
  nx_execute("custom_sender", "custom_close_mail_readbox")
  form.Visible = false
  form:Close()
  return 1
end
function on_answer_click(self)
  local form = self.Parent
  local serial_no = form.serial_no
  if serial_no == nil or nx_string(serial_no) == "" then
    return
  end
  form.Visible = false
  form:Close()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_mail\\form_mail", true, true)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    form:Show()
  end
  form.send.Checked = true
  nx_execute("form_stage_main\\form_mail\\form_mail", "send_on_click", form.send)
  local row = client_player:FindRecordRow(Recv_rec_name, 10, serial_no, 0)
  local sender = client_player:QueryRecord(Recv_rec_name, row, 0)
  form.sendpage.targetname.Text = nx_widestr(sender)
end
function on_mousein_grid(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
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
  local serial_no = form.serial_no
  if serial_no == nil or nx_string(serial_no) == "" then
    return
  end
  local row = client_player:FindRecordRow(Recv_rec_name, 10, serial_no, 0)
  if row < 0 then
    return
  end
  local appedix = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_APPEDIXVALUE)
  show_post_iteminfo(appedix, self:GetMouseInItemLeft(), self:GetMouseInItemTop())
end
function on_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function read_mail(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return
  end
  local serial_no = form.serial_no
  if serial_no == nil or nx_string(serial_no) == "" then
    return
  end
  local row = client_player:FindRecordRow(Recv_rec_name, 10, serial_no, 0)
  if row < 0 then
    return
  end
  local sender = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_SENDNAME)
  local ntype = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TYPE)
  local title = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_LETTERNAME)
  local content = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_VALUE)
  local silver = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_SILVER)
  local appedix = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_APPEDIXVALUE)
  local trade = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TRADE_MONEY)
  local real_title = nx_widestr(title)
  local real_content = nx_widestr(content)
  local real_sender = nx_widestr(sender)
  if nx_int(ntype) > nx_int(LETTER_SYSTEM_TYPE_MIN) and nx_int(ntype) < nx_int(LETTER_SYSTEM_TYPE_MAX) then
    if gui.TextManager:IsIDName(nx_string(title)) then
      real_title = gui.TextManager:GetText(nx_string(title))
    end
    if gui.TextManager:IsIDName(nx_string(content)) then
      real_content = gui.TextManager:GetText(nx_string(content))
    end
    if nx_string(sender) == "" then
      real_sender = gui.TextManager:GetText("ui_SysMail")
    else
      real_sender = gui.TextManager:GetText(nx_string(sender))
    end
    local str_lst = util_split_wstring(nx_widestr(title), ",")
    local arg_lst = util_split_wstring(nx_widestr(str_lst[2]), "|")
    local arg_count = table.getn(arg_lst)
    gui.TextManager:Format_SetIDName(nx_string(str_lst[1]))
    for i = 1, arg_count do
      local para = util_split_wstring(nx_widestr(arg_lst[i]), ":")
      local type = nx_int(para[1])
      if nx_int(type) == nx_int(1) then
        local str_para = gui.TextManager:GetText(nx_string(para[2]))
        gui.TextManager:Format_AddParam(str_para)
      elseif nx_int(type) == nx_int(2) then
        gui.TextManager:Format_AddParam(nx_int(para[2]))
      elseif nx_int(type) == nx_int(3) then
        gui.TextManager:Format_AddParam(nx_string(para[2]))
      elseif nx_int(type) == nx_int(4) then
        gui.TextManager:Format_AddParam(nx_widestr(para[2]))
      else
        gui.TextManager:Format_AddParam(para)
      end
    end
    real_title = nx_widestr(gui.TextManager:Format_GetText())
    str_lst = util_split_wstring(nx_widestr(content), ",")
    arg_lst = util_split_wstring(nx_widestr(str_lst[2]), "|")
    arg_count = table.getn(arg_lst)
    gui.TextManager:Format_SetIDName(nx_string(str_lst[1]))
    for i = 1, arg_count do
      local para = util_split_wstring(nx_widestr(arg_lst[i]), ":")
      local type = nx_int(para[1])
      if nx_int(type) == nx_int(1) then
        local str_para = gui.TextManager:GetText(nx_string(para[2]))
        gui.TextManager:Format_AddParam(str_para)
      elseif nx_int(type) == nx_int(2) then
        gui.TextManager:Format_AddParam(nx_int(para[2]))
      elseif nx_int(type) == nx_int(3) then
        gui.TextManager:Format_AddParam(nx_string(para[2]))
      elseif nx_int(type) == nx_int(4) then
        gui.TextManager:Format_AddParam(nx_widestr(para[2]))
      else
        gui.TextManager:Format_AddParam(para)
      end
    end
    real_content = nx_widestr(gui.TextManager:Format_GetText())
    if nx_string(title) == "offlinejobprize" then
      local str_lst = util_split_string(nx_string(content), ",")
      local date_lst = util_split_string(nx_string(str_lst[1]), "//")
      gui.TextManager:Format_SetIDName("str_lx_mail_title")
      gui.TextManager:Format_AddParam(nx_string(date_lst[2]))
      gui.TextManager:Format_AddParam(nx_string(date_lst[3]))
      form.title.Text = nx_widestr(gui.TextManager:Format_GetText())
      gui.TextManager:Format_SetIDName("str_lx_mail_date")
      gui.TextManager:Format_AddParam(nx_string(date_lst[1]))
      gui.TextManager:Format_AddParam(nx_string(date_lst[2]))
      gui.TextManager:Format_AddParam(nx_string(date_lst[3]))
      form.content.Text = nx_widestr(gui.TextManager:Format_GetText()) .. nx_widestr("<br>") .. nx_widestr(gui.TextManager:GetText("str_lx_mail_name")) .. nx_widestr(gui.TextManager:GetText(nx_string(str_lst[2]))) .. nx_widestr("<br>")
      local OffLineJobManager = nx_value("OffLineJobManager")
      local workplace_id = OffLineJobManager:GetOffLineJobProp(nx_string(str_lst[2]), "WorkPlace")
      form.content.Text = form.content.Text .. nx_widestr(gui.TextManager:GetText("str_lx_mail_place")) .. nx_widestr(gui.TextManager:GetText(workplace_id)) .. nx_widestr("<br>\t\t ") .. nx_widestr(gui.TextManager:GetText("str_lx_mail_text"))
    end
    form.btn_friend.Visible = false
    form.btn_hei.Visible = false
    form.lbl_mail_sign.BackImage = "gui\\language\\ChineseS\\mail_system.png"
  else
    local CleanWord = CheckWords:CleanWords(nx_widestr(real_title))
    real_title = nx_widestr(CleanWord)
    CleanWord = CheckWords:CleanWords(nx_widestr(real_content))
    real_content = nx_widestr(CleanWord)
    form.btn_friend.Visible = true
    form.btn_hei.Visible = true
    form.lbl_mail_sign.BackImage = "gui\\language\\ChineseS\\main_wanjia.png"
  end
  if nx_int(ntype) == nx_int(LETTER_USER_POST_TRADE_PAY) then
    real_title = gui.TextManager:GetText(nx_string(title))
    real_content = gui.TextManager:GetText(nx_string(content))
  end
  form.sender.Text = nx_widestr(real_sender)
  form.title.Text = nx_widestr(real_title)
  form.content.Text = nx_widestr(real_content)
  local ding, liang, wen = 0, 0, 0
  if nx_int(ntype) == nx_int(LETTER_USER_POST_TRADE) then
    ding, liang, wen = nx_execute("form_stage_main\\form_mail\\form_mail_send", "trans_price", trade)
    form.pick_up.Text = nx_widestr("@ui_TiQuCost")
    form.lbl_is_pay.Visible = true
    form.groupbox_appendix.BackImage = mail_trade_appendix_backimage
    form.lbl_mail_note.Text = gui.TextManager:GetText("ui_mail_pay")
  else
    ding, liang, wen = nx_execute("form_stage_main\\form_mail\\form_mail_send", "trans_price", silver)
    form.pick_up.Text = nx_widestr("@ui_TiQu")
    form.lbl_is_pay.Visible = false
    form.groupbox_appendix.BackImage = mail_appendix_backimage
    form.lbl_mail_note.Text = gui.TextManager:GetText("ui_mail_get")
  end
  form.delete.Visible = is_have_trade(serial_no)
  form.lbl_ding.Text = nx_widestr(ding)
  form.lbl_liang.Text = nx_widestr(liang)
  form.lbl_wen.Text = nx_widestr(wen)
  if nx_string(trade) == nx_string(0) and nx_string(silver) == nx_string(0) and not string.find(appedix, "Object") then
    form.pick_up.Enabled = false
  end
  if nx_int(ntype) > nx_int(LETTER_SYSTEM_TYPE_MIN) and nx_int(ntype) < nx_int(LETTER_SYSTEM_TYPE_MAX) then
    form.answer.Enabled = false
  end
  if string.find(appedix, "Object") then
    show_post_item(appedix)
  else
    form.recvbox:Clear()
  end
end
function is_have_trade(serial_no)
  if serial_no == nil or nx_string(serial_no) == "" then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local row = client_player:FindRecordRow(Recv_rec_name, POST_TABLE_SERIALNO, serial_no, 0)
  if row < 0 then
    return false
  end
  local ntype = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TYPE)
  if nx_int(ntype) ~= nx_int(LETTER_USER_POST_TRADE) then
    return false
  end
  local left_time = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_LEFT_TIME)
  local trade_done = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TRADE_DONE)
  if left_time <= 0 or trade_done == 1 then
    return false
  end
  return true
end
function show_post_item(item_info)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local xmldoc = nx_create("XmlDocument")
  if not nx_is_valid(xmldoc) then
    return
  end
  if not xmldoc:ParseXmlData(item_info, 1) then
    nx_destroy(xmldoc)
    return
  end
  local item_config = ""
  local item_num = 1
  local item_color_level = 0
  local xmlroot = xmldoc.RootElement
  local xmlelement = xmlroot:GetChildByIndex(0)
  if not nx_is_valid(xmlelement) then
    nx_destroy(xmldoc)
    return
  end
  local item_config = xmlelement:QueryAttr("Config")
  if nx_string(item_config) == "" then
    nx_destroy(xmldoc)
    return
  end
  xmlroot = xmlelement
  xmlelement = xmlroot:GetChildByIndex(0)
  if not nx_is_valid(xmlelement) then
    nx_destroy(xmldoc)
    return
  end
  for i = 0, xmlelement:GetAttrCount() - 1 do
    local name = xmlelement:GetAttrName(i)
    local value = xmlelement:GetAttrValue(i)
    if nx_string(name) == "Amount" then
      item_num = nx_number(value)
    end
    if nx_string(name) == "ColorLevel" then
      item_color_level = nx_number(value)
    end
  end
  nx_destroy(xmldoc)
  if nx_string(item_config) == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_type = nx_number(ItemQuery:GetItemPropByConfigID(nx_string(item_config), "ItemType"))
  local item_equip_type = nx_string(ItemQuery:GetItemPropByConfigID(nx_string(item_config), "EquipType"))
  local photo = ""
  if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(item_config), "Photo")
  else
    photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), "Photo")
  end
  form.recvbox:Clear()
  local item_back_image = get_grid_treasure_back_image(item_equip_type, item_color_level)
  form.recvbox:AddItemEx(0, photo, nx_widestr(item_config), item_num, -1, item_back_image)
end
function show_post_iteminfo(item_info, x, y)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local xmldoc = nx_create("XmlDocument")
  if not nx_is_valid(xmldoc) then
    return
  end
  if not xmldoc:ParseXmlData(item_info, 1) then
    nx_destroy(xmldoc)
    return
  end
  local xmlroot = xmldoc.RootElement
  local array_data = nx_call("util_gui", "get_arraylist", "form_mail_read:show_post_iteminfo")
  array_data:ClearChild()
  local xmlelement = xmlroot:GetChildByIndex(0)
  if not nx_is_valid(xmlelement) then
    nx_destroy(array_data)
    nx_destroy(xmldoc)
    return
  end
  local configid = xmlelement:QueryAttr("Config")
  if nx_string(configid) == "" then
    nx_destroy(array_data)
    nx_destroy(xmldoc)
    return
  end
  xmlroot = xmlelement
  nx_set_custom(array_data, "ConfigID", configid)
  xmlelement = xmlroot:GetChildByIndex(0)
  if not nx_is_valid(xmlelement) then
    nx_destroy(array_data)
    nx_destroy(xmldoc)
    return
  end
  for i = 0, xmlelement:GetAttrCount() - 1 do
    local name = xmlelement:GetAttrName(i)
    local value = xmlelement:GetAttrValue(i)
    nx_set_custom(array_data, name, value)
  end
  local xml_element_record = xmlroot:GetChildByIndex(1)
  if not nx_is_valid(xml_element_record) then
    nx_destroy(array_data)
    nx_destroy(xmldoc)
    return
  end
  local record_num = xml_element_record:GetChildCount()
  local str_record_group = ""
  for i = 0, record_num - 1 do
    local child = xml_element_record:GetChildByIndex(i)
    if nx_is_valid(child) then
      local record_name = child:QueryAttr("name")
      local record_rows = child:QueryAttr("rows")
      local sz_child_info = nx_string(record_name) .. "," .. nx_string(record_rows)
      local record_prop_num = 0
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        if nx_is_valid(child_child) then
          record_prop_num = nx_int(record_prop_num) + (nx_int(child_child:GetAttrCount()) - 1)
        end
      end
      sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(record_prop_num / record_rows)
      for index = 0, record_rows - 1 do
        local child_child = child:GetChildByIndex(index)
        if nx_is_valid(child_child) then
          local record_prop_num = child_child:GetAttrCount()
          for record_index = 1, record_prop_num - 1 do
            local prop_name = child_child:GetAttrName(record_index)
            local prop_value = child_child:GetAttrValue(record_index)
            sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(prop_value)
          end
        end
      end
      if str_record_group == "" then
        str_record_group = nx_string(sz_child_info)
      else
        str_record_group = nx_string(str_record_group) .. "," .. nx_string(sz_child_info)
      end
    end
  end
  if nx_int(record_num) > nx_int(0) then
    array_data.item_rec_data_info = str_record_group
  end
  array_data.is_chat_link = true
  nx_execute("tips_game", "show_goods_tip", array_data, x, y, 32, 32, form)
  nx_destroy(array_data)
  nx_destroy(xmldoc)
end
function on_btn_friend_click(btn)
  local form = btn.ParentForm
  local serial_no = form.serial_no
  if serial_no == nil or nx_string(serial_no) == "" then
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
  local row = client_player:FindRecordRow(Recv_rec_name, 10, serial_no, 0)
  if row < 0 then
    return
  end
  local name = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_SENDNAME)
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_friend", name)
end
function on_btn_hei_click(btn)
  local form = btn.ParentForm
  local serial_no = form.serial_no
  if serial_no == nil or nx_string(serial_no) == "" then
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
  local row = client_player:FindRecordRow(Recv_rec_name, 10, serial_no, 0)
  if row < 0 then
    return
  end
  local name = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_SENDNAME)
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_filter", name)
end
