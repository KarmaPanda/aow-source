require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
local QIFU_REC = "rec_qifu"
local yinzi_photo = "gui\\common\\money\\suiyin.png"
local huangjin_photo = "gui\\common\\money\\jyb.png"
local table_ps = {
  "ui_relation_send_qifu01",
  "ui_relation_send_qifu02",
  "ui_relation_send_qifu03"
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
  local ini_data = nx_value("QiFuIni")
  if nx_is_valid(ini_data) then
    for i = 1, ini_data:GetChildCount() do
      local item = ini_data:GetChildByIndex(i - 1)
      nx_destroy(item)
    end
    ini_data:ClearChild()
    nx_destroy(ini_data)
  end
  nx_set_value("QiFuIni", nil)
  self.Visible = false
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
  databinder:AddTableBind(QIFU_REC, form, "form_stage_main\\form_relation\\form_acpect_qifu", "refresh_qifu")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_ACCPECT_QIFU))
end
function on_btn_delete_click(btn)
  local form = btn.ParentForm
  local RowNumList = get_checked_present(form)
  if RowNumList == "" then
    return 0
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetText("ui_sns_qifu_shanchu_quren")
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
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_LINGQU_QIFU), -1, RowNumList)
  end
  return 1
end
function on_btn_accpect_click(btn)
  local form = btn.ParentForm
  local RowNumList = get_checked_present(form)
  if RowNumList == "" then
    return 0
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info = gui.TextManager:GetText("ui_sns_qifu_lingqu_quren")
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
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_LINGQU_QIFU), 0, RowNumList)
  end
  return 1
end
function refresh_qifu(form, recordname, optype, row, clomn)
  form.gsb_present_list:DeleteAll()
  form.gsb_remark:DeleteAll()
  show_qifu(form)
  form.gsb_present_list.IsEditMode = false
  form.gsb_remark.IsEditMode = false
  form.gsb_remark:ResetChildrenYPos()
end
function show_qifu(form)
  local player = get_client_player()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord(QIFU_REC) then
    form.lbl_bg_main.BackImage = "gui\\language\\ChineseS\\sns\\bg_nothing_2.png"
    return
  end
  local rows = player:GetRecordRows(QIFU_REC)
  if rows == 0 then
    form.lbl_bg_main.BackImage = "gui\\language\\ChineseS\\sns\\bg_nothing_2.png"
    return
  end
  form.lbl_bg_main.BackImage = "gui\\common\\form_back\\bg_main.png"
  local j = 0
  for i = rows - 1, 0, -1 do
    local sect = nx_int(player:QueryRecord(QIFU_REC, i, 0))
    local buff_id = nx_string(player:QueryRecord(QIFU_REC, i, 1))
    local src_name = nx_widestr(player:QueryRecord(QIFU_REC, i, 2))
    local gongtongname = nx_widestr(player:QueryRecord(QIFU_REC, i, 3))
    local fuyan = nx_widestr(player:QueryRecord(QIFU_REC, i, 4))
    local stime = nx_string(player:QueryRecord(QIFU_REC, i, 5))
    add_qifu(form, sect, buff_id, src_name, gongtongname, fuyan, stime, j, i)
    j = j + 1
  end
end
function read_ini()
  local ini_data = nx_value("QiFuIni")
  if nx_is_valid(ini_data) then
    return ini_data
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\qifu.ini")
  if not nx_is_valid(ini) then
    return nil
  end
  local sect_count = ini:GetSectionCount()
  local QiFuList = nx_call("util_gui", "get_arraylist", "QiFuIni")
  for sect = 0, nx_number(sect_count - 1) do
    local ItemType = ini:ReadString(sect, "ItemType", "")
    local Title = ini:ReadString(sect, "Title", "")
    local Remark = ini:ReadString(sect, "Remark", "")
    local Photo = ini:ReadString(sect, "Photo", "")
    local SuiYinZi = ini:ReadString(sect, "SuiYinZi", "")
    local SuiYinZiBuff = ini:ReadString(sect, "SuiYinZiBuff", "")
    local TiLi = ini:ReadString(sect, "TiLi", "")
    local TiLiBuff = ini:ReadString(sect, "TiLiBuff", "")
    local YinZi = ini:ReadString(sect, "YinZi", "")
    local YinZiBuff = ini:ReadString(sect, "YinZiBuff", "")
    local Gold = ini:ReadString(sect, "Gold", "")
    local GoldBuff = ini:ReadString(sect, "GoldBuff", "")
    local sectId = ini:ReadString(sect, "Sect", "")
    local data = nx_call("util_gui", "get_arraylist", "acpect_qifu_ini_arr_" .. sect)
    data.ItemType = ItemType
    data.Title = Title
    data.Remark = Remark
    data.Photo = Photo
    data.SuiYinZi = SuiYinZi
    data.SuiYinZiBuff = SuiYinZiBuff
    data.TiLi = TiLi
    data.TiLiBuff = TiLiBuff
    data.YinZi = YinZi
    data.YinZiBuff = YinZiBuff
    data.Gold = Gold
    data.GoldBuff = GoldBuff
    data.Sect = sectId
    QiFuList:AddChild(data)
  end
  nx_set_value("QiFuIni", QiFuList)
  return QiFuList
end
function get_qifu_info(sect)
  local QifuItemList = read_ini()
  if not nx_is_valid(QifuItemList) then
    return
  end
  for i = 1, QifuItemList:GetChildCount() do
    local item = QifuItemList:GetChildByIndex(i - 1)
    local sect_id = item.Sect
    local Title = item.Title
    local Remark = item.Remark
    local Photo = item.Photo
    if nx_number(sect_id) == nx_number(sect) then
      return true, Title, Remark, Photo
    end
  end
  return false
end
function add_qifu(form, sect, buff_id, src_name, gongtongname, fuyan, stime, j, row_num)
  local gui = nx_value("gui")
  local item_query = nx_value("ItemQuery")
  local bExist, Title, Remark, Photo = get_qifu_info(sect)
  if not bExist then
    return
  end
  local gb_item = gui:Create("GroupBox")
  gb_item.Left = 10
  gb_item.Top = nx_int(j) * 70 + 10
  gb_item.Width = 300
  gb_item.Height = 70
  gb_item.NoFrame = true
  gb_item.BackColor = "0,255,255,255"
  gb_item.BackImage = "gui\\special\\sns\\bg_event.png"
  gb_item.Title = nx_string(Title)
  gb_item.GongTongNames = nx_widestr(light_src_name(gongtongname, src_name))
  local ps_id = nx_number(fuyan)
  if ps_id <= 0 or ps_id > table.getn(table_ps) then
    ps_id = 1
  end
  local ps = util_text(table_ps[ps_id])
  gb_item.FuYan = nx_widestr(ps)
  gb_item.Time = stime
  gb_item.RowNum = row_num
  gb_item.DrawMode = "Expand"
  local lb_photo_kuang = gui:Create("Label")
  lb_photo_kuang.Width = 53
  lb_photo_kuang.Height = 53
  lb_photo_kuang.Left = 20
  lb_photo_kuang.Top = 7
  lb_photo_kuang.BackImage = "gui\\common\\form_back\\bg_sub.png"
  lb_photo_kuang.DrawMode = "Expand"
  gb_item:Add(lb_photo_kuang)
  local lb_photo = gui:Create("Label")
  lb_photo.Width = 47
  lb_photo.Height = 47
  lb_photo.Left = 23
  lb_photo.Top = 10
  lb_photo.BackImage = buff_static_query(nx_string(buff_id), "Photo")
  lb_photo.DrawMode = "FitWindow"
  gb_item:Add(lb_photo)
  local lb_remark = gui:Create("MultiTextBox")
  lb_remark.Left = 80
  lb_remark.Top = 10
  lb_remark.Font = "font_text_title1"
  lb_remark.TextColor = "255,81,66,49"
  lb_remark.MouseInBarColor = "0,0,0,0"
  lb_remark.SelectBarColor = "0,0,0,0"
  lb_remark.NoFrame = true
  lb_remark.ViewRect = "0,0,210,40"
  local text_id = "desc_" .. buff_id .. "_" .. nx_string(0)
  local buffdesc = gui.TextManager:GetText(text_id)
  lb_remark:AddHtmlText(nx_widestr(buffdesc), -1)
  gb_item:Add(lb_remark)
  local lb_time = gui:Create("Label")
  lb_time.Top = 40
  lb_time.Font = "font_sns_event"
  lb_time.ForeColor = "255,128,101,74"
  local lifetime = get_buff_lifetime(nx_string(buff_id), "LifeTime")
  if nx_number(lifetime) >= 3600000 then
    lifetime = lifetime / 3600000
    lb_time.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_qifu_buff_limit_hour", nx_int(lifetime)))
  elseif nx_number(lifetime) >= 60000 then
    lifetime = lifetime / 60000
    lb_time.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_qifu_buff_limit_min", nx_int(lifetime)))
  elseif nx_number(lifetime) >= 1000 then
    lifetime = lifetime / 1000
    lb_time.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_qifu_buff_limit_sec", nx_int(lifetime)))
  end
  lb_time.Left = gb_item.Width - lb_time.Width - 30
  gb_item:Add(lb_time)
  local lb_mark = gui:Create("Button")
  lb_mark.Left = 0
  lb_mark.Top = 0
  lb_mark.Width = gb_item.Width
  lb_mark.Height = gb_item.Height
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
  local cb_item = gui:Create("CheckButton")
  cb_item.Left = 3
  cb_item.Top = 26
  cb_item.Width = 16
  cb_item.Height = 16
  cb_item.tag = sect
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
      local title = nx_string(gb_item.Title)
      local GongTongNames = nx_widestr(gb_item.GongTongNames)
      local fuyan = nx_widestr(gb_item.FuYan)
      local stime = nx_string(gb_item.Time)
      if fuyan == nil or nx_string(fuyan) == "" then
        top = add_none_fuyan(form, title, GongTongNames, stime, index, top)
      else
        top = add_fuyan(form, title, GongTongNames, fuyan, stime, index, top)
      end
      index = index + 1
    end
  end
end
function add_none_fuyan(form, title, GongTongNames, stime, j, top)
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
  local lb_title = gui:Create("Label")
  lb_title.Left = 10
  lb_title.Top = 10
  lb_title.Font = "font_main"
  lb_title.ForeColor = "255,255,255,255"
  lb_title.Text = nx_widestr(gui.TextManager:GetText(title))
  gb_item:Add(lb_title)
  local lb_time = gui:Create("Label")
  lb_time.Top = 10
  lb_time.Font = "font_main"
  lb_time.ForeColor = "255,255,255,255"
  lb_time.Text = nx_widestr(gui.TextManager:GetText(stime))
  lb_time.Left = gb_item.Width - lb_time.Width
  gb_item:Add(lb_time)
  local lb_gongtong = gui:Create("MultiTextBox")
  lb_gongtong.Left = 10
  lb_gongtong.Top = 25
  lb_gongtong.Font = "font_main"
  lb_gongtong.TextColor = "255,255,255,255"
  lb_gongtong.MouseInBarColor = "0,0,0,0"
  lb_gongtong.SelectBarColor = "0,0,0,0"
  lb_gongtong.NoFrame = true
  lb_gongtong.ViewRect = "0,0,205,40"
  local table_player = util_split_wstring(nx_widestr(GongTongNames), ",")
  local players = nx_widestr("")
  if table.getn(table_player) > 6 then
    for i = 1, 6 do
      if nx_widestr(players) ~= nx_widestr("") then
        players = players .. nx_widestr("\163\172")
      end
      players = players .. nx_widestr(table_player[i])
    end
    GongTongNames = players .. nx_widestr("\163\172...")
    lb_title.Top = 5
    lb_time.Top = 5
    lb_gongtong.Top = 20
  end
  if table.getn(table_player) < 4 then
    lb_title.Top = 10
    lb_time.Top = 10
    lb_gongtong.Top = 25
  end
  lb_gongtong:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("ui_sns_qifu_info", GongTongNames)), -1)
  gb_item:Add(lb_gongtong)
  form.gsb_remark:Add(gb_item)
  gb_item_top = gb_item_top + 65
  return gb_item_top
end
function add_fuyan(form, title, GongTongNames, fuyan, stime, j, top)
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
  gb_item.NoFrame = true
  gb_item.BackColor = "0,255,255,255"
  gb_item.DrawMode = "FitWindow"
  gb_item.Height = hang_count * 20 + 51
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
  local lb_title = gui:Create("Label")
  lb_title.Left = 10
  lb_title.Top = 0
  lb_title.Font = "font_main"
  lb_title.ForeColor = "255,255,255,255"
  lb_title.Text = nx_widestr(gui.TextManager:GetText(title))
  gb_down:Add(lb_title)
  local lb_time = gui:Create("Label")
  lb_time.Top = 0
  lb_time.Font = "font_main"
  lb_time.ForeColor = "255,255,255,255"
  lb_time.Text = nx_widestr(gui.TextManager:GetText(stime))
  lb_time.Left = gb_down.Width - lb_time.Width
  gb_down:Add(lb_time)
  local lb_gongtong = gui:Create("MultiTextBox")
  lb_gongtong.Left = 10
  lb_gongtong.Top = 15
  lb_gongtong.Font = "font_main"
  lb_gongtong.TextColor = "255,255,255,255"
  lb_gongtong.MouseInBarColor = "0,0,0,0"
  lb_gongtong.SelectBarColor = "0,0,0,0"
  lb_gongtong.NoFrame = true
  lb_gongtong.ViewRect = "0,0,205,40"
  local table_player = util_split_wstring(nx_widestr(GongTongNames), ",")
  local players = nx_widestr("")
  if table.getn(table_player) > 6 then
    for i = 1, 6 do
      if nx_widestr(players) ~= nx_widestr("") then
        players = players .. nx_widestr("\163\172")
      end
      players = players .. nx_widestr(table_player[i])
    end
    GongTongNames = players .. nx_widestr("\163\172...")
  end
  if table.getn(table_player) < 4 then
    lb_title.Top = 10
    lb_time.Top = 10
    lb_gongtong.Top = 25
  end
  lb_gongtong:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("ui_sns_qifu_info", GongTongNames)), -1)
  gb_down:Add(lb_gongtong)
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
function get_buff_lifetime(buff_id, prop_name)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:LoadIniToManager("share\\Skill\\buff_new.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(buff_id))
  if nx_number(index) < 0 then
    return ""
  end
  local value = ini:ReadString(index, nx_string(prop_name), "")
  return value
end
function light_src_name(gongtong_name_str, src_name)
  local list = util_split_wstring(nx_widestr(gongtong_name_str), nx_widestr(","))
  local res = nx_widestr("")
  for i, val in pairs(list) do
    if nx_widestr(src_name) == nx_widestr(val) then
      res = nx_widestr("<font color=\"#ffd22e\">") .. nx_widestr(val) .. nx_widestr("</font>") .. nx_widestr(",") .. res
    elseif nx_int(i) ~= nx_int(1) then
      res = res .. nx_widestr(",") .. nx_widestr(val)
    else
      res = nx_widestr(val)
    end
  end
  return res
end
