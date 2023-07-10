require("utils")
require("util_gui")
require("util_functions")
local FORM_CHAT_AD_SETTING = "form_stage_main\\form_chat_system\\form_chat_ad_setting"
local FORM_CHAT_AD_EDIT = "form_stage_main\\form_chat_system\\form_chat_ad_edit"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  change_form_size()
  InitForm(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local groupbox = form.gsb_keys_list
  local keygroup_table = {}
  if nx_is_valid(groupbox) then
    local child_table = groupbox:GetChildControlList()
    local child_count = table.getn(child_table)
    for i = 1, child_count do
      local child = child_table[i]
      if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") and nx_find_custom(child, "key_index") and nx_find_custom(child, "have_keys") and child.have_keys then
        table.insert(keygroup_table, nx_int(child.key_index))
        table.insert(keygroup_table, nx_widestr(child.ipt_keys.Text))
      end
    end
  end
  local nCount = table.getn(keygroup_table)
  if nCount % 2 == 0 then
    local checkads = nx_value("checkads")
    if nx_is_valid(checkads) then
      checkads:UpdateAllKeyGroup(unpack(keygroup_table))
      local filepath = util_get_account_path() .. "adfilters.ini"
      checkads:SaveToFile(filepath)
    end
  end
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_deal_click(btn)
  local form = btn.ParentForm
  local groupbox = btn.Parent
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  if not nx_find_custom(groupbox, "key_index") then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", FORM_CHAT_AD_EDIT, true, false)
  if nx_is_valid(dialog) then
    dialog:ShowModal()
    local szKeys = nx_widestr("")
    if nx_find_custom(groupbox, "have_keys") and groupbox.have_keys then
      szKeys = nx_widestr(groupbox.ipt_keys.Text)
    end
    nx_execute(FORM_CHAT_AD_EDIT, "load_ad_keys", groupbox.key_index, szKeys)
    local res, szKeys = nx_wait_event(100000000, dialog, "chat_ad_edit_return")
    if res == "ok" and nx_is_valid(dialog) and not nx_ws_equal(nx_widestr(szKeys), nx_widestr("")) then
      if nx_is_valid(groupbox.ipt_keys) then
        groupbox.ipt_keys.Text = nx_widestr(szKeys)
      end
      if nx_is_valid(groupbox.btn_deal) then
        groupbox.btn_deal.Text = nx_widestr("@ui_bianji")
      end
      groupbox.have_keys = true
    end
  end
end
function on_btn_del_click(btn)
  local form = btn.ParentForm
  local groupbox = btn.Parent
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  if not nx_find_custom(groupbox, "key_index") then
    return
  end
  if not nx_find_custom(groupbox, "have_keys") or not groupbox.have_keys then
    return
  end
  groupbox.have_keys = false
  local gui = nx_value("gui")
  groupbox.ipt_keys.Text = gui.TextManager:GetText("ui_chat_nokeysgroup")
  groupbox.btn_deal.Text = nx_widestr("@ui_add")
end
function InitForm(form)
  form.groupbox_item.Visible = false
  UpdateForm(form)
end
function UpdateForm(form)
  local gui = nx_value("gui")
  local checkads = nx_value("checkads")
  if not nx_is_valid(checkads) then
    return
  end
  ClearAllChild(form.gsb_keys_list)
  for i = 1, checkads.MaxKeysGroupCount do
    local key_table = checkads:GetKeyList(i)
    local item = GetNewItem()
    item.key_index = nx_int(i)
    item.have_keys = table.getn(key_table) ~= 0
    item.lbl_name.Text = gui.TextManager:GetFormatText("ui_chat_keyname", nx_int(i))
    if table.getn(key_table) == 0 then
      item.ipt_keys.Text = gui.TextManager:GetText("ui_chat_nokeysgroup")
      item.btn_deal.Text = nx_widestr("@ui_add")
    else
      local content = nx_widestr("")
      for j = 1, table.getn(key_table) do
        content = content .. nx_widestr(key_table[j])
        if j < table.getn(key_table) then
          content = content .. nx_widestr(",")
        end
      end
      item.ipt_keys.Text = content
      item.btn_deal.Text = nx_widestr("@ui_bianji")
    end
    item.btn_del.Text = nx_widestr("@ui_delete")
    item.Top = (i - 1) * item.Height
    form.gsb_keys_list:Add(item)
  end
end
function ClearAllChild(groupbox)
  local gui = nx_value("gui")
  if not nx_is_valid(groupbox) then
    return
  end
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  if 0 < child_count then
    for i = child_count, 1, -1 do
      local child = child_table[i]
      if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
        groupbox:Remove(child)
        gui:Delete(child)
      end
    end
  end
end
function GetNewItem()
  local gui = nx_value("gui")
  local form = nx_value(FORM_CHAT_AD_SETTING)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.ctrltype = "item"
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.NoFrame = tpl_item.NoFrame
  item.DrawMode = tpl_item.DrawMode
  item.BackImage = tpl_item.BackImage
  local tpl_name = tpl_item:Find("item_lblname")
  if nx_is_valid(tpl_name) then
    local lbl_name = gui:Create("Label")
    lbl_name.Left = tpl_name.Left
    lbl_name.Top = tpl_name.Top
    lbl_name.Width = tpl_name.Width
    lbl_name.Height = tpl_name.Height
    lbl_name.ForeColor = tpl_name.ForeColor
    lbl_name.Font = tpl_name.Font
    lbl_name.Align = tpl_name.Align
    item:Add(lbl_name)
    item.lbl_name = lbl_name
  end
  local tpl_keys = tpl_item:Find("item_iptkeys")
  if nx_is_valid(tpl_keys) then
    local ipt_keys = gui:Create("Edit")
    ipt_keys.Left = tpl_keys.Left
    ipt_keys.Top = tpl_keys.Top
    ipt_keys.Width = tpl_keys.Width
    ipt_keys.Height = tpl_keys.Height
    ipt_keys.ForeColor = tpl_keys.ForeColor
    ipt_keys.Font = tpl_keys.Font
    ipt_keys.NoFrame = tpl_keys.NoFrame
    ipt_keys.AutoSize = tpl_keys.AutoSize
    ipt_keys.DrawMode = tpl_keys.DrawMode
    ipt_keys.BackImage = tpl_keys.BackImage
    ipt_keys.ReadOnly = tpl_keys.ReadOnly
    ipt_keys.Align = tpl_keys.Align
    item:Add(ipt_keys)
    item.ipt_keys = ipt_keys
  end
  local tpl_add = tpl_item:Find("item_btndeal")
  if nx_is_valid(tpl_add) then
    local btn_deal = gui:Create("Button")
    btn_deal.Left = tpl_add.Left
    btn_deal.Top = tpl_add.Top
    btn_deal.Width = tpl_add.Width
    btn_deal.Height = tpl_add.Height
    btn_deal.NormalImage = tpl_add.NormalImage
    btn_deal.FocusImage = tpl_add.FocusImage
    btn_deal.PushImage = tpl_add.PushImage
    btn_deal.DrawMode = tpl_add.DrawMode
    btn_deal.AutoSize = tpl_add.AutoSize
    btn_deal.ForeColor = tpl_add.ForeColor
    btn_deal.Font = tpl_add.Font
    nx_bind_script(btn_deal, nx_current())
    nx_callback(btn_deal, "on_click", "on_btn_deal_click")
    item:Add(btn_deal)
    item.btn_deal = btn_deal
  end
  local tpl_del = tpl_item:Find("item_btndel")
  if nx_is_valid(tpl_del) then
    local btn_del = gui:Create("Button")
    btn_del.Left = tpl_del.Left
    btn_del.Top = tpl_del.Top
    btn_del.Width = tpl_del.Width
    btn_del.Height = tpl_del.Height
    btn_del.NormalImage = tpl_del.NormalImage
    btn_del.FocusImage = tpl_del.FocusImage
    btn_del.PushImage = tpl_del.PushImage
    btn_del.DrawMode = tpl_del.DrawMode
    btn_del.AutoSize = tpl_del.AutoSize
    btn_del.ForeColor = tpl_del.ForeColor
    btn_del.Font = tpl_del.Font
    nx_bind_script(btn_del, nx_current())
    nx_callback(btn_del, "on_click", "on_btn_del_click")
    item:Add(btn_del)
    item.btn_del = btn_del
  end
  return item
end
function change_form_size()
  local form = nx_value(FORM_CHAT_AD_SETTING)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
