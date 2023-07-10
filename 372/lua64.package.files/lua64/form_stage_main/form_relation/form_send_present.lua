require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
require("form_stage_main\\switch\\switch_define")
local yinzi_photo = "gui\\common\\money\\yb.png"
local suiyinzi_photo = "gui\\common\\money\\suiyin.png"
local huangjin_photo = "gui\\common\\money\\jyb.png"
local ipt_player_default_msg = "ui_sns_input"
local table_ps = {
  "ui_relation_send_present01",
  "ui_relation_send_present02",
  "ui_relation_send_present03"
}
function main_form_init(self)
  self.Fixed = false
  self.allow_empty = true
  return 1
end
function on_main_form_open(self)
  on_init(self)
  show_loading(self, false)
  init_add_friend_form(self)
  init_ps_drop_list(self)
  self.ps = ""
  self.ps_id = 1
  return 1
end
function show_loading(form, bshow)
  form.lbl_bj.Visible = bshow
  form.ani_loading.Visible = bshow
  if bshow then
    form.ani_loading.PlayMode = 0
  end
end
function on_main_form_close(self)
  if nx_find_custom(self, "select_form") and nx_is_valid(self.select_form) then
    self.select_form.Visible = false
    self.select_form:Close()
  end
  local ini_data = nx_value("PresentIni")
  if nx_is_valid(ini_data) then
    for i = 1, ini_data:GetChildCount() do
      local item = ini_data:GetChildByIndex(i - 1)
      nx_destroy(item)
    end
    ini_data:ClearChild()
    nx_destroy(ini_data)
  end
  nx_set_value("PresentIni", nil)
  nx_destroy(self)
  return 1
end
function read_ini()
  local ini_data = nx_value("PresentIni")
  if nx_is_valid(ini_data) then
    return ini_data
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\present.ini")
  if not nx_is_valid(ini) then
    return nil
  end
  local sect_count = ini:GetSectionCount()
  local PresentList = nx_call("util_gui", "get_arraylist", "PresentIni")
  for sect = 0, nx_number(sect_count - 1) do
    local ConfigId = ini:ReadString(sect, "ConfigId", "")
    local ItemType = ini:ReadString(sect, "ItemType", "")
    local PriceType = ini:ReadString(sect, "PriceType", "")
    local Price = ini:ReadString(sect, "Price", "")
    local data = nx_call("util_gui", "get_arraylist", "send_present_ini_arr_" .. sect)
    data.ConfigId = ConfigId
    data.ItemType = ItemType
    data.PriceType = PriceType
    data.Price = Price
    PresentList:AddChild(data)
  end
  nx_set_value("PresentIni", PresentList)
  return PresentList
end
function on_init(form)
  local gui = nx_value("gui")
  form.gsb_present_list_1.Visible = false
  form.gsb_present_list_2.Visible = false
  form.gsb_present_list_3.Visible = false
  form.gsb_present_list_4.Visible = false
  form.gsb_present_list_5.Visible = false
  local PresentItemList = read_ini()
  if not nx_is_valid(PresentItemList) then
    return
  end
  local ItemTypeList = {}
  for i = 1, PresentItemList:GetChildCount() do
    local item = PresentItemList:GetChildByIndex(i - 1)
    local ConfigId = item.ConfigId
    local ItemType = item.ItemType
    local PriceType = item.PriceType
    local Price = item.Price
    local bExist = false
    for j = 1, table.getn(ItemTypeList) do
      if ItemTypeList[j] == ItemType then
        bExist = true
      end
    end
    if not bExist then
      table.insert(ItemTypeList, ItemType)
    end
  end
  for i = 1, table.getn(ItemTypeList) do
    local itemtype = ItemTypeList[i]
    local rb_itemtype = gui:Create("RadioButton")
    rb_itemtype.ForeColor = "255,255,255,255"
    rb_itemtype.Width = 88
    rb_itemtype.Height = 24
    rb_itemtype.Left = (i - 1) * 88
    rb_itemtype.Top = 0
    rb_itemtype.tag = itemtype
    rb_itemtype.DrawMode = "FitWindow"
    rb_itemtype.NormalImage = "gui\\common\\checkbutton\\rbtn_bg_out.png"
    rb_itemtype.FocusImage = "gui\\common\\checkbutton\\rbtn_bg_on.png"
    rb_itemtype.CheckedImage = "gui\\common\\checkbutton\\rbtn_bg_down.png"
    rb_itemtype.Font = "font_sns_event"
    rb_itemtype.ForeColor = "255,157,127,44"
    rb_itemtype.Name = "rb_" .. nx_string(itemtype)
    rb_itemtype.Text = nx_widestr(gui.TextManager:GetText(itemtype))
    if i == 1 then
      rb_itemtype.GroupScrollBox = form.gsb_present_list_1
    elseif i == 2 then
      rb_itemtype.GroupScrollBox = form.gsb_present_list_2
    elseif i == 3 then
      rb_itemtype.GroupScrollBox = form.gsb_present_list_3
    elseif i == 4 then
      rb_itemtype.GroupScrollBox = form.gsb_present_list_4
    elseif i == 5 then
      rb_itemtype.GroupScrollBox = form.gsb_present_list_5
    end
    nx_bind_script(rb_itemtype, nx_current())
    nx_callback(rb_itemtype, "on_checked_changed", "on_rb_itemtype_checked_changed")
    if nx_number(i) == nx_number(4) then
      if is_open_switch_marry() then
        form.gb_ItemTypeList:Add(rb_itemtype)
      end
    else
      form.gb_ItemTypeList:Add(rb_itemtype)
    end
    init_present_item_list(form, itemtype, rb_itemtype.GroupScrollBox)
    if i == 1 then
      rb_itemtype.Checked = true
    end
  end
  form.ipt_players.Text = nx_widestr(gui.TextManager:GetText(ipt_player_default_msg))
  form.ipt_players.default_color = form.ipt_players.ForeColor
  form.ipt_players.ForeColor = "255,156,156,156"
end
function on_rb_itemtype_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    local itemtype = btn.tag
    btn.ForeColor = "255,255,255,255"
    btn.GroupScrollBox.Visible = true
  else
    btn.ForeColor = "255,157,127,44"
    btn.GroupScrollBox.Visible = false
  end
end
function init_present_item_list(form, item_type, gsb_present_list)
  local gui = nx_value("gui")
  gsb_present_list:DeleteAll()
  local PresentItemList = read_ini()
  if not nx_is_valid(PresentItemList) then
    return
  end
  local item_query = nx_value("ItemQuery")
  local j = 0
  for i = 1, PresentItemList:GetChildCount() do
    local item = PresentItemList:GetChildByIndex(i - 1)
    local ConfigId = item.ConfigId
    local ItemType = item.ItemType
    local PriceType = item.PriceType
    local Price = item.Price
    if ItemType == item_type then
      local gb_item = gui:Create("GroupBox")
      gb_item.Name = "gb_" .. nx_string(ConfigId)
      gb_item.Left = j % 3 * 170 + 5
      gb_item.Top = nx_int(j / 3) * 80 + 5
      gb_item.Width = 150
      gb_item.Height = 72
      gb_item.NoFrame = true
      gb_item.BackImage = "gui\\special\\sns\\bg_event.png"
      gb_item.DrawMode = "Expand"
      local lb_name = gui:Create("Label")
      lb_name.Left = 70
      lb_name.Top = 15
      lb_name.Font = "font_sns_list"
      lb_name.ForeColor = "255,128,101,74"
      lb_name.Text = nx_widestr(gui.TextManager:GetText(ConfigId))
      gb_item:Add(lb_name)
      local lb_moneytype = gui:Create("Label")
      lb_moneytype.Left = 70
      lb_moneytype.Top = 40
      lb_moneytype.Width = 20
      lb_moneytype.Height = 20
      lb_moneytype.DrawMode = "FitWindow"
      lb_moneytype.AutoSize = true
      if nx_number(PriceType) == 0 then
        lb_moneytype.BackImage = huangjin_photo
      elseif nx_number(PriceType) == 1 then
        lb_moneytype.BackImage = suiyinzi_photo
      else
        lb_moneytype.BackImage = yinzi_photo
      end
      gb_item:Add(lb_moneytype)
      local lb_money = gui:Create("Label")
      lb_money.Left = 95
      lb_money.Top = 38
      lb_money.Font = "font_sns_list"
      lb_money.ForeColor = "255,128,101,74"
      lb_money.Text = nx_execute("form_stage_main\\form_relation\\capital_funs", "get_captial_text", nx_int64(Price))
      gb_item:Add(lb_money)
      local lb_mark = gui:Create("Button")
      lb_mark.Left = 0
      lb_mark.Top = 24
      lb_mark.Width = gb_item.Width
      lb_mark.Height = gb_item.Height - 24
      lb_mark.BackColor = "0,0,0,0"
      lb_mark.NormalColor = "0,0,0,0"
      lb_mark.FocusColor = "0,0,0,0"
      lb_mark.PushColor = "0,0,0,0"
      lb_mark.DisableColor = "0,0,0,0"
      lb_mark.ShadowColor = "0,0,0,0"
      lb_mark.ForeColor = "0,0,0,0"
      lb_mark.BackColor = "0,0,0,0"
      lb_mark.LineColor = "0,0,0,0"
      lb_mark.target = gb_item
      nx_bind_script(lb_mark, nx_current())
      nx_callback(lb_mark, "on_click", "on_lb_mark_click")
      gb_item:Add(lb_mark)
      local lb_photo_kuang = gui:Create("Label")
      lb_photo_kuang.Width = 55
      lb_photo_kuang.Height = 55
      lb_photo_kuang.Left = 7
      lb_photo_kuang.Top = 7
      lb_photo_kuang.BackImage = "gui\\common\\form_back\\bg_sub.png"
      lb_photo_kuang.DrawMode = "Expand"
      gb_item:Add(lb_photo_kuang)
      local lb_photo = gui:Create("Label")
      lb_photo.Width = 45
      lb_photo.Height = 45
      lb_photo.Left = 12
      lb_photo.Top = 11
      lb_photo.BackImage = item_query:GetItemPropByConfigID(ConfigId, "Photo")
      lb_photo.ConfigId = ConfigId
      lb_photo.Transparent = false
      lb_photo.DrawMode = "FitWindow"
      nx_bind_script(lb_photo, nx_current())
      nx_callback(lb_photo, "on_get_capture", "on_lb_photo_get_capture")
      nx_callback(lb_photo, "on_lost_capture", "on_lb_photo_lost_capture")
      gb_item:Add(lb_photo)
      local cb_item = gui:Create("CheckButton")
      cb_item.Left = gb_item.Width - 21
      cb_item.Top = gb_item.Height - 21
      cb_item.Width = 16
      cb_item.Height = 16
      cb_item.tag = ConfigId
      cb_item.PriceType = PriceType
      cb_item.Price = Price
      cb_item.takemoney = 0
      cb_item.takewords = ""
      cb_item.DrawMode = "FitWindow"
      cb_item.NormalImage = "gui\\common\\checkbutton\\cbtn_2_out.png"
      cb_item.FocusImage = "gui\\common\\checkbutton\\cbtn_2_on.png"
      cb_item.CheckedImage = "gui\\special\\sns_new\\cbtn_gift_down.png"
      cb_item.Name = "cb_" .. nx_string(i)
      if ConfigId == "sns_marry_002" then
        nx_bind_script(cb_item, nx_current())
        nx_callback(cb_item, "on_checked_changed", "on_openredbag")
      end
      gb_item.cb_item_name = "cb_" .. nx_string(i)
      gb_item:Add(cb_item)
      gsb_present_list:Add(gb_item)
      j = j + 1
    end
  end
  gsb_present_list.IsEditMode = false
end
function on_lb_mark_click(self)
  local gb_item = self.target
  if not nx_is_valid(gb_item) then
    return 0
  end
  local cb_item_name = gb_item.cb_item_name
  local cb_item = gb_item:Find(cb_item_name)
  cb_item.Checked = not cb_item.Checked
end
function get_check_itemlist(gsb_present_list)
  local itemlist = gsb_present_list:GetChildControlList()
  local presentList = ""
  local takemoneylist = ""
  local takewordslist = ""
  local total_huangjin_price = 0
  local total_yinzi_price = 0
  local total_suiyinzi_price = 0
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local cb_item_name = gb_item.cb_item_name
    local cb_item = gb_item:Find(cb_item_name)
    if cb_item.Checked then
      if presentList ~= "" then
        presentList = presentList .. "#"
        takemoneylist = takemoneylist .. "#"
        takewordslist = takewordslist .. "#"
      end
      presentList = presentList .. nx_string(cb_item.tag)
      takemoneylist = takemoneylist .. nx_string(cb_item.takemoney)
      takewordslist = takewordslist .. nx_string(cb_item.takewords)
      local priceType = cb_item.PriceType
      local price = cb_item.Price
      if nx_int(priceType) == nx_int(0) then
        total_huangjin_price = total_huangjin_price + nx_number(price)
      elseif nx_int(priceType) == nx_int(1) then
        total_suiyinzi_price = total_suiyinzi_price + nx_number(price)
      elseif nx_int(priceType) == nx_int(2) then
        total_yinzi_price = total_yinzi_price + nx_number(price)
      end
    end
  end
  return presentList, takemoneylist, takewordslist, total_huangjin_price, total_yinzi_price, total_suiyinzi_price
end
function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
function on_btn_send_click(btn)
  local form = btn.ParentForm
  local presentList = ""
  local carryMoney = ""
  local carrWords = ""
  local total_huangjin_price = 0
  local total_yinzi_price = 0
  local total_suiyinzi_price = 0
  local pl, takeMoney, takeWords, huangjin_price, yinzi_price, suiyinzi_price = get_check_itemlist(form.gsb_present_list_1)
  if trim(pl) ~= "" then
    if presentList ~= "" then
      presentList = presentList .. "#" .. pl
      carryMoney = carryMoney .. "#" .. takeMoney
      carryWords = carryWords .. "#" .. takeWords
    else
      presentList = pl
      carryMoney = takeMoney
      carryWords = takeWords
    end
    total_huangjin_price = total_huangjin_price + huangjin_price
    total_yinzi_price = total_yinzi_price + yinzi_price
    total_suiyinzi_price = total_suiyinzi_price + suiyinzi_price
  end
  pl, takeMoney, takeWords, huangjin_price, yinzi_price, suiyinzi_price = get_check_itemlist(form.gsb_present_list_2)
  if trim(pl) ~= "" then
    if presentList ~= "" then
      presentList = presentList .. "#" .. pl
      carryMoney = carryMoney .. "#" .. takeMoney
      carryWords = carryWords .. "#" .. takeWords
    else
      presentList = pl
      carryMoney = takeMoney
      carryWords = takeWords
    end
    total_huangjin_price = total_huangjin_price + huangjin_price
    total_yinzi_price = total_yinzi_price + yinzi_price
    total_suiyinzi_price = total_suiyinzi_price + suiyinzi_price
  end
  pl, takeMoney, takeWords, huangjin_price, yinzi_price, suiyinzi_price = get_check_itemlist(form.gsb_present_list_3)
  if trim(pl) ~= "" then
    if presentList ~= "" then
      presentList = presentList .. "#" .. pl
      carryMoney = carryMoney .. "#" .. takeMoney
      carryWords = carryWords .. "#" .. takeWords
    else
      presentList = pl
      carryMoney = takeMoney
      carryWords = takeWords
    end
    total_huangjin_price = total_huangjin_price + huangjin_price
    total_yinzi_price = total_yinzi_price + yinzi_price
    total_suiyinzi_price = total_suiyinzi_price + suiyinzi_price
  end
  pl, takeMoney, takeWords, huangjin_price, yinzi_price, suiyinzi_price = get_check_itemlist(form.gsb_present_list_4)
  if trim(pl) ~= "" then
    if presentList ~= "" then
      presentList = presentList .. "#" .. pl
      carryMoney = carryMoney .. "#" .. takeMoney
      carryWords = carryWords .. "#" .. takeWords
    else
      presentList = pl
      carryMoney = takeMoney
      carryWords = takeWords
    end
    total_huangjin_price = total_huangjin_price + huangjin_price
    total_yinzi_price = total_yinzi_price + yinzi_price
    total_suiyinzi_price = total_suiyinzi_price + suiyinzi_price
  end
  pl, takeMoney, takeWords, huangjin_price, yinzi_price, suiyinzi_price = get_check_itemlist(form.gsb_present_list_5)
  if trim(pl) ~= "" then
    if presentList ~= "" then
      presentList = presentList .. "#" .. pl
      carryMoney = carryMoney .. "#" .. takeMoney
      carryWords = carryWords .. "#" .. takeWords
    else
      presentList = pl
      carryMoney = takeMoney
      carryWords = takeWords
    end
    total_huangjin_price = total_huangjin_price + huangjin_price
    total_yinzi_price = total_yinzi_price + yinzi_price
    total_suiyinzi_price = total_suiyinzi_price + suiyinzi_price
  end
  if presentList == "" then
    form_error(form, "ui_sns_present_zengsong_liwu")
    return
  end
  if nx_string(form.ipt_players.Text) == "" or nx_string(form.ipt_players.Text) == "0" or nx_string(form.ipt_players.Text) == "0-0" then
    form_error(form, "ui_sns_present_zengsong_object")
    return
  end
  local table_exists_player = util_split_wstring(nx_widestr(form.ipt_players.Text), nx_widestr(","))
  local playerCount = nx_number(table.getn(table_exists_player))
  total_huangjin_price = total_huangjin_price * playerCount
  total_suiyinzi_price = total_suiyinzi_price * playerCount
  total_yinzi_price = total_yinzi_price * playerCount
  local text = nx_widestr(form.ps_id)
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return
  end
  local new_word = CheckWords:CleanWords(nx_widestr(text))
  local gui = nx_value("gui")
  if not nx_ws_equal(nx_widestr(text), nx_widestr(new_word)) then
    local info = gui.TextManager:GetFormatText("9721")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetText("ui_sns_present_xiaohao") .. nx_widestr(" ")
  if nx_int64(total_huangjin_price) > nx_int64(0) then
    local cap = nx_execute("form_stage_main\\form_relation\\capital_funs", "get_captial_text", nx_int64(total_huangjin_price))
    info = info .. gui.TextManager:GetFormatText("ui_sns_present_xiaohao_huangjin", cap) .. nx_widestr(" ")
  end
  if nx_int64(total_suiyinzi_price) > nx_int64(0) then
    local cap = nx_execute("form_stage_main\\form_relation\\capital_funs", "get_captial_text", nx_int64(total_suiyinzi_price))
    info = info .. gui.TextManager:GetFormatText("ui_sns_present_xiaohao_suiyinzi", cap) .. nx_widestr(" ")
  end
  if nx_int64(total_yinzi_price) > nx_int64(0) then
    local cap = nx_execute("form_stage_main\\form_relation\\capital_funs", "get_captial_text", nx_int64(total_yinzi_price))
    info = info .. gui.TextManager:GetFormatText("ui_sns_present_xiaohao_yinzi", cap) .. nx_widestr(" ")
  end
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_GIFT), nx_widestr(form.ipt_players.Text), nx_string(presentList), nx_widestr(text), nx_string(carryMoney), nx_string(carryWords))
  end
end
function init_add_friend_form(form)
  local select_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_select_friend", true, false, "present")
  select_form.IsExistGuanZhu = true
  select_form.SelectPlayerNames = form.ipt_players.Text
  form:Add(select_form)
  form.select_form = select_form
  form.select_form.Left = form.Width - form.select_form.Width - 20
  form.select_form.Top = 70
  form.select_form.Fixed = true
  form.select_form.Visible = false
end
function on_btn_add_friend_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  if not nx_find_custom(form, "select_form") then
    return
  end
  if not nx_is_valid(form.select_form) then
    return
  end
  local select_form = form.select_form
  select_form.SelectPlayerNames = form.ipt_players.Text
  nx_execute("form_stage_main\\form_relation\\form_select_friend", "check_players", select_form, form.ipt_players.Text)
  if select_form.Visible then
    select_form.Visible = false
    return
  else
    select_form.Visible = true
    form:ToFront(select_form)
  end
  local res, playerList = nx_wait_event(100000000, select_form, "input_name_return")
  if res == "ok" then
    form.ipt_players.Text = nx_widestr(playerList)
  end
end
function form_error(form, text)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
  local info = gui.TextManager:GetFormatText(text)
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog.Left = form.Left + (form.Width - dialog.Width) / 2
  dialog.Top = form.Top + (form.Height - dialog.Height) / 2
  dialog:ShowModal()
  nx_wait_event(100000000, dialog, "error_return")
end
function on_btn_exit_click(btn)
  local Parentform = btn.ParentForm.Parent
  Parentform:Close()
end
function on_lb_photo_get_capture(self)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", self.ConfigId, x, y, self.ParentForm)
end
function on_lb_photo_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_openredbag(self)
  if self.Checked then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_inputbox", true, false)
    dialog.info_label.Text = nx_widestr(util_text("ui_moneydisp"))
    dialog:ShowModal()
    local res, text = nx_wait_event(100000000, dialog, "input_box_return")
    if res == "ok" then
      local amount = nx_number(text)
      self.takemoney = amount
    else
      return
    end
  end
end
function on_ipt_players_get_focus(self)
  local gui = nx_value("gui")
  if self.Text == nx_widestr(gui.TextManager:GetText(ipt_player_default_msg)) then
    self.Text = nx_widestr("")
    self.ForeColor = self.default_color
  end
end
function is_open_switch_marry()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  return switch_manager:CheckSwitchEnable(ST_FUNCTION_MARRY)
end
function init_ps_drop_list(form)
  local cb = form.ipt_fuyan
  if not nx_is_valid(cb) then
    return
  end
  cb.OnlySelect = true
  cb.DropListBox:ClearString()
  local count = table.getn(table_ps)
  for i = 1, count do
    local text = util_text(table_ps[i])
    cb.DropListBox:AddString(nx_widestr(text))
  end
  cb.Text = nx_widestr("")
end
function on_ipt_fuyan_selected(cb)
  local form = cb.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.ps = cb.Text
  form.ps_id = cb.DropListBox.SelectIndex + 1
end
