require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
local PRESENT_REC = "rec_present"
local yinzi_photo = "gui\\common\\money\\yb.png"
local suiyinzi_photo = "gui\\common\\money\\suiyin.png"
local huangjin_photo = "gui\\common\\money\\jyb.png"
local table_ps = {
  "ui_relation_send_present01",
  "ui_relation_send_present02",
  "ui_relation_send_present03"
}
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  show_loading(self, true)
  on_init(self)
  return 1
end
function on_main_form_close(self)
  self.Visible = false
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
function show_loading(form, bshow)
  form.lbl_bj.Visible = bshow
  form.ani_loading.Visible = bshow
  if bshow then
    form.ani_loading.PlayMode = 0
  end
end
function on_init(form)
  read_ini()
  local databinder = nx_value("data_binder")
  databinder:AddTableBind(PRESENT_REC, form, "form_stage_main\\form_relation\\form_acpect_present", "refresh_present")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_ACCPECT_PRESENT))
end
function on_btn_accpect_click(btn)
  local form = btn.ParentForm
  local RowNumList = get_checked_present(form)
  if RowNumList == "" then
    return 0
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetText("ui_sns_present_lingqu_quren")
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
      return 0
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_LINGQU_PRESENT), 0, RowNumList)
  end
  return 1
end
function on_btn_delete_click(btn)
  local form = btn.ParentForm
  local RowNumList = get_checked_present(form)
  if RowNumList == "" then
    return 0
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetText("ui_sns_present_shanchu_quren")
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
      return 0
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_LINGQU_PRESENT), -1, RowNumList)
  end
  return 1
end
function refresh_present(form, recordname, optype, row, clomn)
  form.gsb_present_list:DeleteAll()
  form.gsb_remark:DeleteAll()
  show_present(form)
  form.gsb_present_list.IsEditMode = false
  form.gsb_remark.IsEditMode = false
  form.gsb_remark:ResetChildrenYPos()
end
function show_present(form)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord(PRESENT_REC) then
    form.lbl_bg_main.BackImage = "gui\\language\\ChineseS\\sns\\bg_nothing.png"
    return
  end
  local rows = player:GetRecordRows(PRESENT_REC)
  if rows == 0 then
    form.lbl_bg_main.BackImage = "gui\\language\\ChineseS\\sns\\bg_nothing.png"
    return
  end
  form.lbl_bg_main.BackImage = "gui\\common\\form_back\\bg_main.png"
  local j = 0
  for i = rows - 1, 0, -1 do
    local pid = nx_string(player:QueryRecord(PRESENT_REC, i, 0))
    local player_name = nx_widestr(player:QueryRecord(PRESENT_REC, i, 1))
    local fuyan = nx_widestr(player:QueryRecord(PRESENT_REC, i, 2))
    local carrymoney = nx_string(player:QueryRecord(PRESENT_REC, i, 3))
    local carrywords = nx_string(player:QueryRecord(PRESENT_REC, i, 4))
    if carrymoney == nil then
      carrymoney = 0
    end
    if carrywords == nil then
      carrywords = ""
    end
    local ptime = nx_string(player:QueryRecord(PRESENT_REC, i, 5))
    add_present(form, pid, player_name, fuyan, ptime, j, i)
    j = j + 1
  end
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
    local data = nx_call("util_gui", "get_arraylist", "acpect_PresentIni_Arr_" .. sect)
    data.ConfigId = ConfigId
    data.ItemType = ItemType
    data.PriceType = PriceType
    data.Price = Price
    PresentList:AddChild(data)
  end
  nx_set_value("PresentIni", PresentList)
  return PresentList
end
function get_present_info(pid)
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
    if ConfigId == pid then
      return true, ItemType, PriceType, Price
    end
  end
  return false
end
function add_present(form, pid, player_name, fuyan, ptime, j, row_num)
  local gui = nx_value("gui")
  local item_query = nx_value("ItemQuery")
  local bExist, ItemType, PriceType, Price = get_present_info(pid)
  if not bExist then
    return
  end
  local gb_item = gui:Create("GroupBox")
  gb_item.Left = 10
  gb_item.Top = nx_int(j) * 80 + 10
  gb_item.Width = 300
  gb_item.Height = 72
  gb_item.NoFrame = true
  gb_item.BackImage = "gui\\special\\sns\\bg_event.png"
  gb_item.DrawMode = "Expand"
  local ps_id = nx_number(fuyan)
  if ps_id <= 0 or ps_id > table.getn(table_ps) then
    ps_id = 1
  end
  local ps = util_text(table_ps[ps_id])
  gb_item.FuYan = nx_widestr(ps)
  gb_item.playerName = nx_widestr(player_name)
  gb_item.Time = nx_string(ptime)
  gb_item.ItemName = nx_widestr(gui.TextManager:GetText(pid))
  gb_item.RowNum = row_num
  local lb_name = gui:Create("Label")
  lb_name.Left = 70
  lb_name.Top = 10
  lb_name.Width = 240
  lb_name.Font = "font_sns_list"
  lb_name.ForeColor = "255,128,101,74"
  lb_name.Text = nx_widestr(gui.TextManager:GetText(pid))
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
  lb_photo.Width = 46
  lb_photo.Height = 45
  lb_photo.Left = 11
  lb_photo.Top = 11
  lb_photo.BackImage = item_query:GetItemPropByConfigID(pid, "Photo")
  lb_photo.ConfigId = pid
  lb_photo.Transparent = false
  lb_photo.DrawMode = "FitWindow"
  nx_bind_script(lb_photo, nx_current())
  nx_callback(lb_photo, "on_get_capture", "on_lb_photo_get_capture")
  nx_callback(lb_photo, "on_lost_capture", "on_lb_photo_lost_capture")
  gb_item:Add(lb_photo)
  local cb_item = gui:Create("CheckButton")
  cb_item.Left = gb_item.Width - 22
  cb_item.Top = gb_item.Height - 22
  cb_item.Width = 16
  cb_item.Height = 16
  cb_item.tag = pid
  cb_item.DrawMode = "FitWindow"
  cb_item.NormalImage = "gui\\common\\checkbutton\\cbtn_2_out.png"
  cb_item.FocusImage = "gui\\common\\checkbutton\\cbtn_2_on.png"
  cb_item.CheckedImage = "gui\\special\\sns_new\\cbtn_gift_down.png"
  cb_item.Name = "cb_" .. nx_string(i)
  cb_item.GroupBox = gb_item
  nx_bind_script(cb_item, nx_current())
  nx_callback(cb_item, "on_checked_changed", "on_cb_item_checked_changed")
  gb_item.cb_item_name = "cb_" .. nx_string(i)
  gb_item:Add(cb_item)
  form.gsb_present_list:Add(gb_item)
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
function on_btn_all_accpect_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetText("ui_sns_present_lingqu_quren_all")
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
      return 0
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_LINGQU_PRESENT), 1)
  end
  return 1
end
function on_btn_exit_click(self)
  local form = self.ParentForm.Parent
  form:Close()
  return 1
end
function on_cb_item_checked_changed(btn)
  local form = btn.ParentForm
  refresh_fuyan(form)
end
function get_checked_present(form)
  local itemlist = form.gsb_present_list:GetChildControlList()
  local RowNumList = ""
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local cb_item_name = gb_item.cb_item_name
    local cb_item = gb_item:Find(cb_item_name)
    if cb_item.Checked then
      if RowNumList ~= "" then
        RowNumList = RowNumList .. "#"
      end
      RowNumList = RowNumList .. nx_string(gb_item.RowNum)
    end
  end
  return RowNumList
end
function refresh_fuyan(form)
  local itemlist = form.gsb_present_list:GetChildControlList()
  form.gsb_remark:DeleteAll()
  local index = 0
  local top = 5
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local cb_item_name = gb_item.cb_item_name
    local cb_item = gb_item:Find(cb_item_name)
    if cb_item.Checked then
      local fuyan = nx_widestr(gb_item.FuYan)
      local player_name = nx_widestr(gb_item.playerName)
      local ptime = nx_string(gb_item.Time)
      local itemname = nx_widestr(gb_item.ItemName)
      if fuyan == nil or nx_widestr(fuyan) == nx_widestr("") then
        top = add_none_fuyan(form, itemname, player_name, ptime, index, top)
      else
        top = add_fuyan(form, itemname, player_name, fuyan, ptime, index, top)
      end
      index = index + 1
    end
  end
end
function add_none_fuyan(form, itemname, player_name, ptime, j, top)
  local gui = nx_value("gui")
  local gb_item = gui:Create("GroupBox")
  local gb_item_top = top
  gb_item.Left = 5
  gb_item.Top = gb_item_top
  gb_item.Width = 220
  gb_item.NoFrame = true
  gb_item.BackColor = "0,255,255,255"
  gb_item.DrawMode = "FitWindow"
  gb_item.Height = 59
  gb_item.BackImage = "gui\\special\\sns\\bg_time.png"
  local lb_itemname = gui:Create("Label")
  lb_itemname.Left = 10
  lb_itemname.Top = 10
  lb_itemname.Height = 20
  lb_itemname.Width = 220
  lb_itemname.Font = "font_main"
  lb_itemname.ForeColor = "255,255,255,255"
  lb_itemname.Text = nx_widestr(itemname) .. nx_widestr(":")
  gb_item:Add(lb_itemname)
  local lb_iteminfo = gui:Create("Label")
  lb_iteminfo.Left = 10
  lb_iteminfo.Top = 30
  lb_iteminfo.Width = 220
  lb_iteminfo.Font = "font_main"
  lb_iteminfo.ForeColor = "255,255,255,255"
  lb_iteminfo.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_liwu_info", player_name, ptime))
  gb_item:Add(lb_iteminfo)
  form.gsb_remark:Add(gb_item)
  gb_item_top = gb_item_top + 65
  return gb_item_top
end
function add_fuyan(form, itemname, player_name, fuyan, ptime, j, top)
  local gui = nx_value("gui")
  local gb_item = gui:Create("GroupBox")
  local len_fuyan = nx_ws_length(fuyan)
  local hang_count = nx_int(nx_int(len_fuyan) / 11)
  local hang_count_1 = nx_number(len_fuyan) % nx_number(11)
  if nx_number(hang_count_1) >= nx_number(1) then
    hang_count = hang_count + 1
  end
  local gb_item_top = top
  gb_item.Left = 5
  gb_item.Top = gb_item_top
  gb_item.Width = 220
  gb_item.Height = hang_count * 20 + 51
  gb_item.NoFrame = true
  gb_item.BackColor = "0,255,255,255"
  gb_item.DrawMode = "FitWindow"
  local gb_up = gui:Create("GroupBox")
  gb_up.Left = 0
  gb_up.Top = 0
  gb_up.Width = 220
  gb_up.NoFrame = true
  gb_up.BackColor = "0,255,255,255"
  gb_up.DrawMode = "FitWindow"
  gb_up.Height = hang_count * 20
  gb_up.BackImage = "gui\\special\\sns\\fuyan_up_2.png"
  gb_item:Add(gb_up)
  local lb_photo = gui:Create("Label")
  lb_photo.AutoSize = true
  lb_photo.Left = 1
  lb_photo.Top = 1
  lb_photo.BackImage = "gui\\special\\sns\\icon_invertedcomma1.png"
  gb_up:Add(lb_photo)
  local lb_fuyan = gui:Create("MultiTextBox")
  lb_fuyan.Left = 19
  lb_fuyan.Top = 5
  lb_fuyan.Width = 180
  lb_fuyan.Height = gb_up.Height
  lb_fuyan.Font = "font_text"
  lb_fuyan.TextColor = "255,255,255,255"
  lb_fuyan.MouseInBarColor = "0,0,0,0"
  lb_fuyan.SelectBarColor = "0,0,0,0"
  lb_fuyan.NoFrame = true
  lb_fuyan.ViewRect = "0,0,180," .. nx_string(gb_up.Height)
  lb_fuyan:AddHtmlText(nx_widestr(fuyan), -1)
  gb_up:Add(lb_fuyan)
  local lb_photo1 = gui:Create("Label")
  lb_photo1.AutoSize = true
  lb_photo1.Left = gb_item.Width - 15
  lb_photo1.Top = gb_up.Height - 20
  lb_photo1.BackImage = "gui\\special\\sns\\icon_invertedcomma2.png"
  gb_up:Add(lb_photo1)
  local gb_down = gui:Create("GroupBox")
  gb_down.Left = 0
  gb_down.Top = gb_up.Height
  gb_down.Width = 220
  gb_down.NoFrame = true
  gb_down.BackColor = "0,255,255,255"
  gb_down.DrawMode = "FitWindow"
  gb_down.Height = 51
  gb_down.BackImage = "gui\\special\\sns\\fuyan_down_2.png"
  gb_item:Add(gb_down)
  local lb_itemname = gui:Create("Label")
  lb_itemname.Left = 10
  lb_itemname.Top = 10
  lb_itemname.Font = "font_main"
  lb_itemname.ForeColor = "255,255,255,255"
  lb_itemname.Text = nx_widestr(itemname) .. nx_widestr(":")
  gb_down:Add(lb_itemname)
  local lb_iteminfo = gui:Create("Label")
  lb_iteminfo.Left = 10
  lb_iteminfo.Top = 30
  lb_iteminfo.Font = "font_main"
  lb_iteminfo.ForeColor = "255,255,255,255"
  lb_iteminfo.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_liwu_info", player_name, ptime))
  gb_down:Add(lb_iteminfo)
  form.gsb_remark:Add(gb_item)
  gb_item_top = gb_item_top + gb_item.Height + 5
  return gb_item_top
end
function on_lb_photo_get_capture(self)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", self.ConfigId, x, y, self.ParentForm)
end
function on_lb_photo_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
