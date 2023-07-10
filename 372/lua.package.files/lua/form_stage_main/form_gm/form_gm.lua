require("util_functions")
local changed_table = {}
local search_table = {}
function main_form_init(self)
  self.Fixed = false
  return 1
end
function btn_close_click(self)
  self.Parent.Visible = false
end
function main_form_open(self)
  self.cbx_hyperlink_type.DropListBox:AddString(nx_widestr("HLStype1"))
  self.cbx_hyperlink_type.DropListBox:AddString(nx_widestr("HLStype2"))
  self.cbx_hyperlink_type.DropListBox:AddString(nx_widestr("HLTaskFindPathType"))
  self.cbx_hyperlink_type.DropListBox:AddString(nx_widestr("HLChatItem"))
  self.cbx_hyperlink_type.DropListBox:AddString(nx_widestr("HLStypeShenfen"))
  self.cbx_hyperlink_type.DropListBox:AddString(nx_widestr("HLStype3"))
  self.cbx_hyperlink_type.DropListBox:AddString(nx_widestr("HLStype4"))
  self.cbx_hyperlink_type.DropListBox:AddString(nx_widestr("HLStype5"))
  Init_cbx_idresname(self.cbx_idresname)
  self.redit_tips.SupportHtml = false
  self.redit_tips.ReturnAllFormat = false
  self.richedit_gmchat.EnterEnabled = false
end
function sendmessage(form, txt)
  form.txtbox_chat:Clear()
  form.txtbox_chat:AddHtmlText(txt, -1)
end
function btn_facepannel_click(self)
  local form = self.Parent
  local face_form = nx_value("form_stage_main\\form_main\\form_main_face_gmchat")
  if nx_is_valid(face_form) then
    nx_gen_event(face_form, "selectface_return", "cancel", "")
  else
    local groupbox = self.Parent
    local gui = nx_value("gui")
    local form_main_face = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_face", true, false)
    nx_set_value("form_stage_main\\form_main\\form_main_face_gmchat", form_main_face)
    form_main_face.AbsLeft = self.AbsLeft + self.Width
    form_main_face.AbsTop = self.AbsTop + self.Height - form_main_face.Height
    form_main_face:Show()
    local res, html = nx_wait_event(100000000, form_main_face, "selectface_return")
    if res == "ok" then
      form.richedit_gmchat:Append(html, -1)
      gui.Focused = form.richedit_gmchat
    end
    form_main_face:Close()
  end
  nx_set_value("form_stage_main\\form_main\\form_main_face_gmchat", nil)
end
function btn_font_click(self)
  local form = self.Parent
  local gui = nx_value("gui")
  local form_font = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_gm\\form_select_font", true, false)
  form_font.color = form.richedit_gmchat.ForeColor
  form_font.font = form.richedit_gmchat.Font
  form_font:ShowModal()
  local res, fontname, color = nx_wait_event(100000000, form_font, "select_font_return")
  if res == "cancel" then
    return 0
  end
  if fontname ~= "" then
    form.richedit_gmchat:ChangeSelectFont(fontname)
  end
  if color ~= "" then
    form.richedit_gmchat:ChangeSelectColor(color)
  end
  on_richedit_gmchat_changed(form.richedit_gmchat)
end
function on_richedit_gmchat_changed(self)
  local form = self.Parent
  self.ReturnNoDefaultFormat = true
  form.redit_tips.Text = self.Text
  self.ReturnNoDefaultFormat = false
  sendmessage(form, self.Text)
end
function on_btn_add_hyperlink_click(self)
  local form = self.Parent
  if nx_string(form.edit_hyperlink_href.Text) ~= "" then
    form.richedit_gmchat:ChangeSelectHyperLink(nx_string(form.edit_hyperlink_href.Text), nx_string(form.cbx_hyperlink_type.InputEdit.Text))
  end
  on_richedit_gmchat_changed(form.richedit_gmchat)
end
function on_btn_remove_hyperlink_click(self)
  local form = self.Parent
  form.richedit_gmchat:RemoveSelectHyperLink()
  on_richedit_gmchat_changed(form.richedit_gmchat)
end
function on_btn_DefaultFont_click(self)
  local form = self.Parent
  local gui = nx_value("gui")
  local form_font = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_gm\\form_select_font", true, false)
  form_font.color = form.richedit_gmchat.ForeColor
  form_font.font = form.richedit_gmchat.Font
  form_font:ShowModal()
  local res, fontname, color = nx_wait_event(100000000, form_font, "select_font_return")
  if res == "cancel" then
    return 0
  end
  form.richedit_gmchat.ForeColor = color
  form.richedit_gmchat.Font = fontname
  form.txtbox_chat.Font = fontname
  form.txtbox_chat.ForeColor = color
  on_richedit_gmchat_changed(form.richedit_gmchat)
end
function on_richedit_gmchat_left_double_click(self, x, y)
  local hyperlink_href = self:GetHyperlinkInfo()
  local hyperlink_type = self:GetHyperlinkType()
  if nx_string(hyperlink_href) == "" then
    return
  end
  self.Parent.edit_hyperlink_href.Text = nx_widestr(hyperlink_href)
  self.Parent.cbx_hyperlink_type.InputEdit.Text = nx_widestr(hyperlink_type)
end
function on_btn_hyperlink_change_click(self)
  local form = self.Parent
  local hyperlink_href = form.edit_hyperlink_href.Text
  local hyperlink_type = form.cbx_hyperlink_type.InputEdit.Text
  form.richedit_gmchat:SetHyperlink(nx_string(hyperlink_href), nx_string(hyperlink_type))
  on_richedit_gmchat_changed(form.richedit_gmchat)
end
function on_redit_tips_changed(self)
  local form = self.Parent
  form.richedit_gmchat.Text = self.Text
  sendmessage(form, self.Text)
end
function on_btn_Edit_click(self)
  local form = self.Parent
  local gui = nx_value("gui")
  local form_edit_findpath = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_gm\\form_edit_findpath", true, false)
  form_edit_findpath.input_href = nx_string(form.edit_hyperlink_href.Text)
  form_edit_findpath:ShowModal()
  local res, href = nx_wait_event(100000000, form_edit_findpath, "form_edit_findpath_return")
  if res == "cancel" then
    return 0
  end
  form.edit_hyperlink_href.Text = nx_widestr(href)
end
function on_btn_SaveText_click(self)
  local idresname = nx_string(self.Parent.cbx_idresname.Text)
  if idresname == "" then
    nx_msgbox(get_msg_str("msg_415"))
    return
  end
  if self.Parent.lbx_changed.ItemCount == 0 then
    return
  end
  local idres = nx_create("IdresDocument")
  idres.FileName = nx_resource_path() .. "ini\\text\\ChineseS\\" .. idresname
  if not idres:LoadFromFile() then
    nx_msgbox(get_msg_str("msg_416"))
    nx_destroy(idres)
    return
  end
  for n = 0, self.Parent.lbx_changed.ItemCount - 1 do
    local textid = nx_string(self.Parent.lbx_changed:GetString(n))
    local info = nx_string(changed_table[textid])
    if info ~= nil then
      idres:WriteString(textid, info)
    end
  end
  if not idres:SaveToFile() then
    nx_msgbox(get_msg_str("msg_416"))
  end
  nx_destroy(idres)
  self.Parent.lbx_changed:ClearString()
end
function on_btn_changed_click(self)
  local form = self.Parent
  local changed_text = nx_string(form.redit_tips.Text)
  changed_text = string.gsub(changed_text, "<br/>", "")
  local gui = nx_value("gui")
  local textid = nx_string(form.ipt_TextID.Text)
  if changed_text == "" or textid == "" then
    return
  end
  if nx_string(gui.TextManager:GetFormatText(textid)) == changed_text then
    changed_table[textid] = nil
  else
    changed_table[textid] = nx_string(changed_text)
  end
  RefreshList(form.lbx_changed)
end
function RefreshList(list)
  list:ClearString()
  for n, v in pairs(changed_table) do
    list:AddString(nx_widestr(n))
  end
end
function on_btn_LoadText_click(self)
  local form = self.Parent
  local textid = nx_string(form.ipt_TextID.Text)
  if textid == "" or nx_string(form.cbx_idresname.Text) == "" or not nx_is_valid(form.cbx_idresname.idres_reader) then
    return
  end
  local text = form.cbx_idresname.idres_reader:ReadString(textid)
  form.richedit_gmchat.Text = nx_widestr(text)
  on_richedit_gmchat_changed(form.richedit_gmchat)
end
function on_lbx_changed_select_double_click(self)
  local textid = nx_string(self.SelectString)
  if textid == "" then
    return
  end
  local info = changed_table[textid]
  if info == nil then
    return
  end
  self.Parent.ipt_TextID.Text = nx_widestr(textid)
  self.Parent.richedit_gmchat.Text = nx_widestr(info)
  on_richedit_gmchat_changed(self.Parent.richedit_gmchat)
end
function Init_cbx_idresname(self)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\text\\ChineseS\\textfiles.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return
  end
  self.InputEdit.Text = nx_widestr("")
  self.DropListBox:ClearString()
  local items = ini:GetItemList("textfile")
  for n = 1, table.getn(items) do
    local filename = ini:ReadString("textfile", items[n], "")
    self.DropListBox:AddString(nx_widestr(filename))
  end
  nx_destroy(ini)
end
function on_ipt_Search_changed(self)
  local form = self.Parent
  search_table = {}
  form.lbx_Search:ClearString()
  local search_txt = nx_string(form.ipt_Search.Text)
  if search_txt == "[\202\228\200\235\178\233\209\175\196\218\200\221]" then
    return
  end
  if not nx_is_valid(form.cbx_idresname.idres_reader) then
    return
  end
  local result_table = form.cbx_idresname.idres_reader:Like(search_txt)
  local count = table.getn(result_table) / 2
  for n = 1, count do
    form.lbx_Search:AddString(nx_widestr(result_table[n * 2]))
    search_table[n] = {}
    search_table[n].key = result_table[n * 2 - 1]
    search_table[n].value = result_table[n * 2]
  end
end
function on_cbx_idresname_selected(self)
  if self.Parent.lbx_changed.ItemCount ~= 0 then
    nx_msgbox(get_msg_str("msg_417"))
    if nx_find_custom(self, "oldselected") then
      self.Text = self.oldselected
    end
    return
  end
  local idres = nx_string(self.Text)
  if idres == "" then
    return
  end
  if not nx_find_custom(self, "idres_reader") or not nx_is_valid(self.idres_reader) then
    self.idres_reader = nx_create("IdresDocument")
  end
  self.idres_reader.FileName = nx_resource_path() .. "ini\\text\\ChineseS\\" .. idres
  if not self.idres_reader:LoadFromFile() then
    return
  end
  self.oldselected = self.Text
  self.Parent.lbx_Search:ClearString()
  self.Parent.ipt_TextID.Text = nx_widestr("")
  self.Parent.richedit_gmchat.Text = nx_widestr("")
  on_richedit_gmchat_changed(self.Parent.richedit_gmchat)
end
function on_lbx_Search_select_double_click(self)
  local form = self.Parent
  local index = self.SelectIndex + 1
  if search_table[index] == nil then
    return
  end
  local key = search_table[index].key
  local value = search_table[index].value
  form.ipt_TextID.Text = nx_widestr(key)
  form.richedit_gmchat.Text = nx_widestr(value)
  on_richedit_gmchat_changed(form.richedit_gmchat)
end
