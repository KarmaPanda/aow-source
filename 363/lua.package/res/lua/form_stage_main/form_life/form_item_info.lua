require("share\\itemtype_define")
require("util_functions")
local file_name = "share\\life\\ItemInfo.ini"
local page_text_table = {}
local page_num = 1
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.lbl_back.Visible = false
  self.lbl_photo.Visible = false
  self.mltbox_text.Visible = false
  self.btn_prev.Visible = false
  self.btn_next.Visible = false
  refresh_form_pos(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function refresh_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_btn_close_click(btn)
  local form = nx_value("form_stage_main\\form_life\\form_item_info")
  if nx_is_valid(form) then
    form:Close()
  end
end
function refresh_form(form, item)
  if not item:FindProp("ItemType") then
    return
  end
  local item_type = item:QueryProp("ItemType")
  if item_type == ITEMTYPE_COMPOSE_CANJUAN then
    show_info_pic(form, item)
  elseif item_type == ITEMTYPE_COMPOSE_HUA then
    show_info_pic(form, item)
  end
  local gui = nx_value("gui")
  form.btn_close.Parent:ToFront(form.btn_close)
end
function show_info_pic(form, item)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", file_name)
  if not nx_is_valid(ini) then
    return
  end
  form.lbl_back.Visible = true
  form.lbl_photo.Visible = true
  local item_configID = item:QueryProp("ConfigID")
  local sec_index = ini:FindSectionIndex(nx_string(item_configID))
  if sec_index < 0 then
    return
  end
  local photo_back = ini:ReadString(sec_index, "PhotoBack", "")
  local photo = ini:ReadString(sec_index, "Photo", "")
  local close_btn_pos = ini:ReadString(sec_index, "CloseBtnPos", "")
  local close_outimage = ini:ReadString(sec_index, "CloseOutImage", "")
  local close_onimage = ini:ReadString(sec_index, "CloseOnImage", "")
  local close_downimage = ini:ReadString(sec_index, "CloseDownImage", "")
  form.lbl_back.BackImage = photo_back
  form.lbl_photo.BackImage = photo
  form.Width = form.lbl_back.Width
  form.Height = form.lbl_back.Height
  form.lbl_back.Left = 0
  form.lbl_back.Top = 0
  form.lbl_photo.Left = (form.lbl_back.Width - form.lbl_photo.Width) / 2
  form.lbl_photo.Top = (form.lbl_back.Height - form.lbl_photo.Height) / 2
  form.btn_close.NormalImage = close_outimage
  form.btn_close.FocusImage = close_onimage
  form.btn_close.PushImage = close_downimage
  set_btn_pos(form.btn_close, close_btn_pos)
  refresh_form_pos(form)
end
function show_info_text(form, item)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", file_name)
  if not nx_is_valid(ini) then
    return
  end
  local gui = nx_value("gui")
  local item_configID = item:QueryProp("ConfigID")
  local sec_index = ini:FindSectionIndex(nx_string(item_configID))
  if sec_index < 0 then
    return
  end
  local photo_back = ini:ReadString(sec_index, "PhotoBack", "")
  local text_size = ini:ReadString(sec_index, "TextSize", "")
  local close_btn_pos = ini:ReadString(sec_index, "CloseBtnPos", "")
  local prev_btn_pos = ini:ReadString(sec_index, "PrevBtnPos", "")
  local next_btn_pos = ini:ReadString(sec_index, "NextBtnPos", "")
  local close_outimage = ini:ReadString(sec_index, "CloseOutImage", "")
  local close_onimage = ini:ReadString(sec_index, "CloseOnImage", "")
  local close_downimage = ini:ReadString(sec_index, "CloseDownImage", "")
  local prev_outimage = ini:ReadString(sec_index, "PrevOutImage", "")
  local prev_onimage = ini:ReadString(sec_index, "PrevOnImage", "")
  local prev_downimage = ini:ReadString(sec_index, "PrevDownImage", "")
  local next_outimage = ini:ReadString(sec_index, "NextOutImage", "")
  local next_onimage = ini:ReadString(sec_index, "NextOnImage", "")
  local next_downimage = ini:ReadString(sec_index, "NextDownImage", "")
  if nx_string(text_size) == "" or nx_string(photo_back) == "" then
    return
  end
  form.lbl_back.Visible = true
  local table_text_size = util_split_string(text_size, ",")
  if table.getn(table_text_size) == 2 then
    form.mltbox_text.Width = nx_number(table_text_size[1])
    form.mltbox_text.Height = nx_number(table_text_size[2])
    form.mltbox_text.ViewRect = "0,0" .. "," .. nx_string(form.mltbox_text.Width) .. "," .. nx_string(form.mltbox_text.Height)
  else
    return
  end
  form.lbl_back.BackImage = photo_back
  form.Width = form.lbl_back.Width
  form.Height = form.lbl_back.Height
  form.lbl_back.Left = 0
  form.lbl_back.Top = 0
  form.mltbox_text.Left = (form.lbl_back.Width - form.mltbox_text.Width) / 2
  form.mltbox_text.Top = (form.lbl_back.Height - form.mltbox_text.Height) / 2
  page_text_table = {}
  page_num = 1
  form.mltbox_text:Clear()
  local i = 0
  while true do
    i = i + 1
    local text = ini:ReadString(item_configID, "Text_" .. nx_string(i), "")
    if nx_string(text) == "" then
      break
    end
    table.insert(page_text_table, text)
  end
  if table.getn(page_text_table) == 0 then
    return
  end
  form.mltbox_text:AddHtmlText(gui.TextManager:GetText(page_text_table[page_num]), nx_int(-1))
  form.btn_close.NormalImage = close_outimage
  form.btn_close.FocusImage = close_onimage
  form.btn_close.PushImage = close_downimage
  form.btn_prev.NormalImage = prev_outimage
  form.btn_prev.FocusImage = prev_onimage
  form.btn_prev.PushImage = prev_downimage
  form.btn_next.NormalImage = next_outimage
  form.btn_next.FocusImage = next_onimage
  form.btn_next.PushImage = next_downimage
  set_btn_pos(form.btn_close, close_btn_pos)
  set_btn_pos(form.btn_prev, prev_btn_pos)
  set_btn_pos(form.btn_next, next_btn_pos)
  form.mltbox_text.Visible = true
  form.btn_prev.Visible = true
  form.btn_next.Visible = true
  refresh_form_pos(form)
end
function set_btn_pos(btn, btn_pos)
  local table_pos = util_split_string(btn_pos, ",")
  if table.getn(table_pos) == 2 then
    btn.Left = nx_number(table_pos[1])
    btn.Top = nx_number(table_pos[2])
  end
end
function on_btn_prev_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if page_num <= 1 then
    return
  end
  local gui = nx_value("gui")
  page_num = page_num - 1
  form.mltbox_text:Clear()
  form.mltbox_text:AddHtmlText(gui.TextManager:GetText(page_text_table[page_num]), nx_int(-1))
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if page_num >= table.getn(page_text_table) then
    return
  end
  local gui = nx_value("gui")
  page_num = page_num + 1
  form.mltbox_text:Clear()
  form.mltbox_text:AddHtmlText(gui.TextManager:GetText(page_text_table[page_num]), nx_int(-1))
end
