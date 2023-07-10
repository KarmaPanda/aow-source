require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
local yinzi_photo = "gui\\common\\money\\yb.png"
local suiyinzi_photo = "gui\\common\\money\\suiyin.png"
local huangjin_photo = "gui\\common\\money\\jyb.png"
local ipt_player_default_msg = "ui_sns_input"
local table_ps = {
  "ui_relation_send_qifu01",
  "ui_relation_send_qifu02",
  "ui_relation_send_qifu03"
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
  nx_destroy(self)
  return 1
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
    local data = nx_call("util_gui", "get_arraylist", "send_qifu_ini_arr_" .. sect)
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
function on_init(form)
  local gui = nx_value("gui")
  form.gsb_present_list_1.Visible = false
  form.gsb_present_list_2.Visible = false
  form.gsb_present_list_3.Visible = false
  form.gsb_present_list_4.Visible = false
  form.gsb_present_list_5.Visible = false
  local QiFuItemList = read_ini()
  if not nx_is_valid(QiFuItemList) then
    return
  end
  local ItemTypeList = {}
  for i = 1, QiFuItemList:GetChildCount() do
    local item = QiFuItemList:GetChildByIndex(i - 1)
    local ItemType = item.ItemType
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
    rb_itemtype.Width = 106
    rb_itemtype.Height = 24
    rb_itemtype.Left = (i - 1) * 106
    rb_itemtype.Top = 0
    rb_itemtype.tag = itemtype
    rb_itemtype.DrawMode = "FitWindow"
    rb_itemtype.NormalImage = "gui\\common\\checkbutton\\rbtn_bg_out.png"
    rb_itemtype.FocusImage = "gui\\common\\checkbutton\\rbtn_bg_on.png"
    rb_itemtype.CheckedImage = "gui\\common\\checkbutton\\rbtn_bg_down.png"
    rb_itemtype.Font = "font_sns_event"
    rb_itemtype.ForeColor = "255,157,127,44"
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
    form.gb_ItemTypeList:Add(rb_itemtype)
    init_qifu_item_list(form, itemtype, rb_itemtype.GroupScrollBox)
    if i == 1 then
      rb_itemtype.Checked = true
    end
  end
  form.ipt_players.Text = nx_widestr(gui.TextManager:GetText(ipt_player_default_msg))
  form.ipt_players.default_color = form.ipt_players.ForeColor
  form.ipt_players.ForeColor = "255,156,156,156"
end
function on_rb_itemtype_checked_changed(btn)
  if btn.Checked then
    local itemtype = btn.tag
    btn.ForeColor = "255,255,255,255"
    btn.GroupScrollBox.Visible = true
  else
    btn.ForeColor = "255,157,127,44"
    btn.GroupScrollBox.Visible = false
  end
end
function trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end
function init_qifu_item_list(form, item_type, gsb_present_list)
  local gui = nx_value("gui")
  gsb_present_list:DeleteAll()
  local QiFuItemList = read_ini()
  if not nx_is_valid(QiFuItemList) then
    return
  end
  local item_query = nx_value("ItemQuery")
  local j = 0
  for i = 1, QiFuItemList:GetChildCount() do
    local item = QiFuItemList:GetChildByIndex(i - 1)
    local Photo = item.Photo
    local ItemType = item.ItemType
    local Title = item.Title
    local Remark = item.Remark
    local SuiYinZi = item.SuiYinZi
    local TiLi = item.TiLi
    local YinZi = item.YinZi
    local Gold = item.Gold
    local Sect = item.Sect
    if ItemType == item_type then
      local gb_item = gui:Create("GroupBox")
      gb_item.Left = 5
      gb_item.Top = nx_int(j) * 95
      gb_item.Width = 510
      gb_item.Height = 110
      gb_item.NoFrame = true
      gb_item.BackColor = "0,255,255,255"
      gb_item.Sect = Sect
      local lb_photo_kuang = gui:Create("Label")
      lb_photo_kuang.Width = 62
      lb_photo_kuang.Height = 62
      lb_photo_kuang.Left = 0
      lb_photo_kuang.Top = 4
      lb_photo_kuang.BackImage = "gui\\common\\form_back\\bg_sub.png"
      lb_photo_kuang.DrawMode = "Expand"
      gb_item:Add(lb_photo_kuang)
      local lb_photo = gui:Create("Label")
      lb_photo.Width = 55
      lb_photo.Height = 55
      lb_photo.Left = 4
      lb_photo.Top = 7
      lb_photo.BackImage = Photo
      lb_photo.DrawMode = "FitWindow"
      gb_item:Add(lb_photo)
      local lb_name = gui:Create("Label")
      lb_name.Left = 70
      lb_name.Top = 2
      lb_name.Font = "font_text_title1"
      lb_name.ForeColor = "255,81,66,49"
      lb_name.Text = nx_widestr(gui.TextManager:GetText(Title))
      gb_item:Add(lb_name)
      local lb_remark_bg = gui:Create("Label")
      lb_remark_bg.Left = 65
      lb_remark_bg.Top = 20
      lb_remark_bg.Width = 410
      lb_remark_bg.Height = 46
      lb_remark_bg.DrawMode = "FitWindow"
      lb_remark_bg.BackImage = "gui\\special\\task\\bg_target.png"
      gb_item:Add(lb_remark_bg)
      local lb_remark = gui:Create("MultiTextBox")
      lb_remark.Left = 75
      lb_remark.Top = 25
      lb_remark.Width = 400
      lb_remark.Height = 40
      lb_remark.Font = "font_sns_event"
      lb_remark.TextColor = "255,128,101,74"
      lb_remark.MouseInBarColor = "0,0,0,0"
      lb_remark.SelectBarColor = "0,0,0,0"
      lb_remark.NoFrame = true
      lb_remark.ViewRect = "0,0,386,40"
      lb_remark:AddHtmlText(nx_widestr(gui.TextManager:GetText(Remark)), -1)
      lb_remark.HasVScroll = true
      gb_item:Add(lb_remark)
      lb_remark.VScrollBar.Width = 14
      lb_remark.VScrollBar.DrawMode = "ExpandV"
      lb_remark.VScrollBar.BackImage = "gui\\common\\scrollbar\\bg_scrollbar2.png"
      lb_remark.VScrollBar.DecButton.DrawMode = "Tile"
      lb_remark.VScrollBar.DecButton.NormalImage = "gui\\common\\scrollbar\\button_2\\btn_up_out.png"
      lb_remark.VScrollBar.DecButton.FocusImage = "gui\\common\\scrollbar\\button_2\\btn_up_on.png"
      lb_remark.VScrollBar.DecButton.PushImage = "gui\\common\\scrollbar\\button_2\\btn_up_down.png"
      lb_remark.VScrollBar.IncButton.DrawMode = "Tile"
      lb_remark.VScrollBar.IncButton.NormalImage = "gui\\common\\scrollbar\\button_2\\btn_down_out.png"
      lb_remark.VScrollBar.IncButton.FocusImage = "gui\\common\\scrollbar\\button_2\\btn_down_on.png"
      lb_remark.VScrollBar.IncButton.PushImage = "gui\\common\\scrollbar\\button_2\\btn_down_down.png"
      lb_remark.VScrollBar.TrackButton.Width = 14
      lb_remark.VScrollBar.TrackButton.DrawMode = "ExpandV"
      lb_remark.VScrollBar.TrackButton.NormalImage = "gui\\common\\scrollbar\\button_2\\btn_trace_out.png"
      lb_remark.VScrollBar.TrackButton.FocusImage = "gui\\common\\scrollbar\\button_2\\btn_trace_on.png"
      lb_remark.VScrollBar.TrackButton.PushImage = "gui\\common\\scrollbar\\button_2\\btn_trace_down.png"
      local lb_xianghuoqian = gui:Create("Label")
      lb_xianghuoqian.Left = 0
      lb_xianghuoqian.Top = gb_item.Height - 40
      lb_xianghuoqian.Font = "font_sns_list"
      lb_xianghuoqian.ForeColor = "255,128,101,74"
      lb_xianghuoqian.Text = nx_widestr(gui.TextManager:GetText("ui_sns_qifu_xianghuoqian"))
      gb_item:Add(lb_xianghuoqian)
      local rb_item = gui:Create("CheckButton")
      rb_item.Left = 82
      rb_item.Top = gb_item.Height - 40
      rb_item.Width = 16
      rb_item.Height = 16
      rb_item.tag = "suiyinzi"
      rb_item.Price = SuiYinZi
      rb_item.DrawMode = "FitWindow"
      rb_item.NormalImage = "gui\\common\\checkbutton\\cbtn_2_out.png"
      rb_item.FocusImage = "gui\\common\\checkbutton\\cbtn_2_on.png"
      rb_item.CheckedImage = "gui\\special\\sns_new\\cbtn_gift_down.png"
      rb_item.Name = "rb_suiyinzi_" .. nx_string(i)
      rb_item.Index = i
      rb_item.GroupScrollBox = gsb_present_list
      nx_bind_script(rb_item, nx_current())
      nx_callback(rb_item, "on_checked_changed", "on_rb_item_checked_changed")
      gb_item:Add(rb_item)
      local lb_suiyinzi = gui:Create("Label")
      lb_suiyinzi.Left = 100
      lb_suiyinzi.Top = gb_item.Height - 40
      lb_suiyinzi.Width = 65
      lb_suiyinzi.Font = "font_sns_event"
      lb_suiyinzi.ForeColor = "255,128,101,74"
      local cap = nx_execute("form_stage_main\\form_relation\\capital_funs", "get_captial_text", nx_int64(SuiYinZi))
      lb_suiyinzi.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_qifu_suiyinzi", cap))
      lb_suiyinzi.Name = "lb_suiyinzi_" .. nx_string(i)
      lb_suiyinzi.Index = i
      lb_suiyinzi.Transparent = false
      lb_suiyinzi.ClickEvent = true
      lb_suiyinzi.DrawMode = "Center"
      lb_suiyinzi.BackImage = "gui\\common\\form_back\\bg_main.png"
      nx_bind_script(lb_suiyinzi, nx_current())
      nx_callback(lb_suiyinzi, "on_click", "on_lb_item_click")
      lb_suiyinzi.GroupScrollBox = gsb_present_list
      gb_item:Add(lb_suiyinzi)
      rb_item = gui:Create("CheckButton")
      rb_item.Left = 200
      rb_item.Top = gb_item.Height - 40
      rb_item.Width = 16
      rb_item.Height = 16
      rb_item.tag = "tili"
      rb_item.Price = TiLi
      rb_item.DrawMode = "FitWindow"
      rb_item.NormalImage = "gui\\common\\checkbutton\\cbtn_2_out.png"
      rb_item.FocusImage = "gui\\common\\checkbutton\\cbtn_2_on.png"
      rb_item.CheckedImage = "gui\\special\\sns_new\\cbtn_gift_down.png"
      rb_item.Name = "rb_tili_" .. nx_string(i)
      rb_item.Index = i
      rb_item.GroupScrollBox = gsb_present_list
      nx_bind_script(rb_item, nx_current())
      nx_callback(rb_item, "on_checked_changed", "on_rb_item_checked_changed")
      gb_item:Add(rb_item)
      local lb_tili = gui:Create("Label")
      lb_tili.Left = 220
      lb_tili.Top = gb_item.Height - 40
      lb_tili.Width = 30
      lb_tili.Font = "font_sns_event"
      lb_tili.ForeColor = "255,128,101,74"
      lb_tili.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_qifu_tili", nx_int(TiLi)))
      lb_tili.Name = "lb_tili_" .. nx_string(i)
      lb_tili.Index = i
      lb_tili.Transparent = false
      lb_tili.ClickEvent = true
      lb_tili.DrawMode = "Center"
      lb_tili.BackImage = "gui\\common\\form_back\\bg_main.png"
      nx_bind_script(lb_tili, nx_current())
      nx_callback(lb_tili, "on_click", "on_lb_item_click")
      lb_tili.GroupScrollBox = gsb_present_list
      gb_item:Add(lb_tili)
      rb_item = gui:Create("CheckButton")
      rb_item.Left = 310
      rb_item.Top = gb_item.Height - 40
      rb_item.Width = 16
      rb_item.Height = 16
      rb_item.tag = "yinzi"
      rb_item.Price = YinZi
      rb_item.DrawMode = "FitWindow"
      rb_item.NormalImage = "gui\\common\\checkbutton\\cbtn_2_out.png"
      rb_item.FocusImage = "gui\\common\\checkbutton\\cbtn_2_on.png"
      rb_item.CheckedImage = "gui\\special\\sns_new\\cbtn_gift_down.png"
      rb_item.Name = "rb_yinzi_" .. nx_string(i)
      rb_item.Index = i
      rb_item.GroupScrollBox = gsb_present_list
      nx_bind_script(rb_item, nx_current())
      nx_callback(rb_item, "on_checked_changed", "on_rb_item_checked_changed")
      gb_item:Add(rb_item)
      local lb_yinzi = gui:Create("Label")
      lb_yinzi.Left = 330
      lb_yinzi.Top = gb_item.Height - 40
      lb_yinzi.Width = 50
      lb_yinzi.Font = "font_sns_event"
      lb_yinzi.ForeColor = "255,128,101,74"
      local cap1 = nx_execute("form_stage_main\\form_relation\\capital_funs", "get_captial_text", nx_int64(YinZi))
      lb_yinzi.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_qifu_yinzi", cap1))
      lb_yinzi.Name = "lb_yinzi_" .. nx_string(i)
      lb_yinzi.Index = i
      lb_yinzi.Transparent = false
      lb_yinzi.ClickEvent = true
      lb_yinzi.DrawMode = "Center"
      lb_yinzi.BackImage = "gui\\common\\form_back\\bg_main.png"
      nx_bind_script(lb_yinzi, nx_current())
      nx_callback(lb_yinzi, "on_click", "on_lb_item_click")
      lb_yinzi.GroupScrollBox = gsb_present_list
      gb_item:Add(lb_yinzi)
      local lb_line = gui:Create("Label")
      lb_line.Left = 5
      lb_line.Top = gb_item.Height - 38
      lb_line.Width = gb_item.Width - 40
      lb_line.Height = 20
      lb_line.DrawMode = "Expand"
      lb_line.BackImage = "gui\\common\\form_line\\line_bg3.png"
      gb_item:Add(lb_line)
      gb_item.rb_item_index = nx_string(i)
      gsb_present_list:Add(gb_item)
      j = j + 1
    end
  end
  gsb_present_list.IsEditMode = false
end
function on_rb_item_checked_changed(btn)
  local form = btn.ParentForm
  local index = btn.Index
  local name = btn.Name
  if btn.Checked then
    check_button(form, index, name, false, btn.GroupScrollBox)
  end
end
function on_lb_item_click(lbl)
  local form = lbl.ParentForm
  local index = lbl.Index
  local gsb_present_list = lbl.GroupScrollBox
  local name = lbl.Name
  local itemlist = gsb_present_list:GetChildControlList()
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local rb_item_index = gb_item.rb_item_index
    if nx_number(index) == nx_number(rb_item_index) then
      if nx_string(name) == "lb_suiyinzi_" .. index then
        local rb_suiyinzi = gb_item:Find("rb_suiyinzi_" .. index)
        rb_suiyinzi.Checked = not rb_suiyinzi.Checked
      end
      if nx_string(name) == "lb_tili_" .. index then
        local rb_tili = gb_item:Find("rb_tili_" .. index)
        rb_tili.Checked = not rb_tili.Checked
      end
      if nx_string(name) == "lb_yinzi_" .. index then
        local rb_yinzi = gb_item:Find("rb_yinzi_" .. index)
        rb_yinzi.Checked = not rb_yinzi.Checked
      end
      break
    end
  end
end
function check_button(form, index, checkName, value, gsb_present_list)
  local itemlist = gsb_present_list:GetChildControlList()
  local qifuList = ""
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local rb_item_index = gb_item.rb_item_index
    if nx_number(index) == nx_number(rb_item_index) then
      if nx_string(checkName) ~= "rb_suiyinzi_" .. rb_item_index then
        local rb_suiyinzi = gb_item:Find("rb_suiyinzi_" .. rb_item_index)
        rb_suiyinzi.Checked = value
      end
      if nx_string(checkName) ~= "rb_tili_" .. rb_item_index then
        local rb_tili = gb_item:Find("rb_tili_" .. rb_item_index)
        rb_tili.Checked = value
      end
      if nx_string(checkName) ~= "rb_yinzi_" .. rb_item_index then
        local rb_yinzi = gb_item:Find("rb_yinzi_" .. rb_item_index)
        rb_yinzi.Checked = value
      end
      break
    end
  end
end
function get_check_itemlist(gsb_present_list)
  local itemlist = gsb_present_list:GetChildControlList()
  local qifuList = ""
  local total_tili_price = 0
  local total_yinzi_price = 0
  local total_suiyinzi_price = 0
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local rb_item_index = gb_item.rb_item_index
    local Sect = gb_item.Sect
    local rb_suiyinzi = gb_item:Find("rb_suiyinzi_" .. rb_item_index)
    local rb_tili = gb_item:Find("rb_tili_" .. rb_item_index)
    local rb_yinzi = gb_item:Find("rb_yinzi_" .. rb_item_index)
    local tag = ""
    if rb_suiyinzi.Checked then
      tag = rb_suiyinzi.tag
      total_suiyinzi_price = total_suiyinzi_price + nx_number(rb_suiyinzi.Price)
    elseif rb_tili.Checked then
      tag = rb_tili.tag
      total_tili_price = total_tili_price + nx_number(rb_tili.Price)
    elseif rb_yinzi.Checked then
      tag = rb_yinzi.tag
      total_yinzi_price = total_yinzi_price + nx_number(rb_yinzi.Price)
    end
    if tag ~= "" then
      if qifuList ~= "" then
        qifuList = qifuList .. "#"
      end
      qifuList = qifuList .. nx_string(Sect) .. "," .. nx_string(tag)
    end
  end
  return qifuList, total_tili_price, total_yinzi_price, total_suiyinzi_price
end
function on_btn_send_click(btn)
  local form = btn.ParentForm
  local qifuList = ""
  local total_tili_price = 0
  local total_yinzi_price = 0
  local total_suiyinzi_price = 0
  local pl, tili_price, yinzi_price, suiyinzi_price = get_check_itemlist(form.gsb_present_list_1)
  if trim(pl) ~= "" then
    if qifuList ~= "" then
      qifuList = qifuList .. "#" .. pl
    else
      qifuList = pl
    end
    total_tili_price = total_tili_price + tili_price
    total_yinzi_price = total_yinzi_price + yinzi_price
    total_suiyinzi_price = total_suiyinzi_price + suiyinzi_price
  end
  pl, tili_price, yinzi_price, suiyinzi_price = get_check_itemlist(form.gsb_present_list_2)
  if trim(pl) ~= "" then
    if qifuList ~= "" then
      qifuList = qifuList .. "#" .. pl
    else
      qifuList = pl
    end
    total_tili_price = total_tili_price + tili_price
    total_yinzi_price = total_yinzi_price + yinzi_price
    total_suiyinzi_price = total_suiyinzi_price + suiyinzi_price
  end
  pl, tili_price, yinzi_price, suiyinzi_price = get_check_itemlist(form.gsb_present_list_3)
  if trim(pl) ~= "" then
    if qifuList ~= "" then
      qifuList = qifuList .. "#" .. pl
    else
      qifuList = pl
    end
    total_tili_price = total_tili_price + tili_price
    total_yinzi_price = total_yinzi_price + yinzi_price
    total_suiyinzi_price = total_suiyinzi_price + suiyinzi_price
  end
  pl, tili_price, yinzi_price, suiyinzi_price = get_check_itemlist(form.gsb_present_list_4)
  if trim(pl) ~= "" then
    if qifuList ~= "" then
      qifuList = qifuList .. "#" .. pl
    else
      qifuList = pl
    end
    total_tili_price = total_tili_price + tili_price
    total_yinzi_price = total_yinzi_price + yinzi_price
    total_suiyinzi_price = total_suiyinzi_price + suiyinzi_price
  end
  pl, tili_price, yinzi_price, suiyinzi_price = get_check_itemlist(form.gsb_present_list_5)
  if trim(pl) ~= "" then
    if qifuList ~= "" then
      qifuList = qifuList .. "#" .. pl
    else
      qifuList = pl
    end
    total_tili_price = total_tili_price + tili_price
    total_yinzi_price = total_yinzi_price + yinzi_price
    total_suiyinzi_price = total_suiyinzi_price + suiyinzi_price
  end
  if qifuList == "" then
    form_error(form, "ui_sns_qifu_xuanze_qifu_object")
    return
  end
  if nx_string(form.ipt_players.Text) == "" or nx_string(form.ipt_players.Text) == "0" or nx_string(form.ipt_players.Text) == "0-0" then
    form_error(form, "ui_sns_qifu_xuanze_object")
    return
  end
  local table_exists_player = util_split_wstring(nx_widestr(form.ipt_players.Text), nx_widestr(","))
  local playerCount = nx_number(table.getn(table_exists_player))
  total_tili_price = total_tili_price * playerCount
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
  local info = gui.TextManager:GetText("ui_sns_qifu_xiaohao") .. nx_widestr(" ")
  if nx_int(total_tili_price) > nx_int(0) then
    info = info .. gui.TextManager:GetFormatText("ui_sns_qifu_xiaohao_tili", nx_int(total_tili_price)) .. nx_widestr(" ")
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
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_QIFU), nx_widestr(form.ipt_players.Text), nx_string(qifuList), nx_widestr(text))
  end
end
function init_add_friend_form(form)
  local select_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_select_friend", true, false, "qifu")
  form:Add(select_form)
  form.select_form = select_form
  form.select_form.Left = form.Width - form.select_form.Width - 20
  form.select_form.Top = 70
  form.select_form.Fixed = true
  form.select_form.Visible = false
  form.select_form.SelectPlayerNames = form.ipt_players.Text
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
  local form = btn.ParentForm.Parent
  form:Close()
end
function on_lb_photo_get_capture(self)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", self.ConfigId, x, y, self.ParentForm)
end
function on_lb_photo_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_ipt_players_get_focus(self)
  local gui = nx_value("gui")
  if self.Text == nx_widestr(gui.TextManager:GetText(ipt_player_default_msg)) then
    self.Text = nx_widestr("")
    self.ForeColor = self.default_color
  end
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
