require("utils")
require("util_gui")
require("util_functions")
require("form_stage_main\\form_chat_system\\chat_util_define")
require("form_stage_main\\switch\\switch_define")
local FORM_NAME = "form_stage_main\\form_tarot\\form_tarot_share"
local fold_normalimage = "gui\\common\\button\\btn_maximum_out.png"
local fold_focusimage = "gui\\common\\button\\btn_maximum_on.png"
local fold_pushimage = "gui\\common\\button\\btn_maximum_down.png"
local unfold_normalimage = "gui\\common\\button\\btn_minimum_out.png"
local unfold_focusimage = "gui\\common\\button\\btn_minimum_on.png"
local unfold_pushimage = "gui\\common\\button\\btn_minimum_down.png"
local color_online = "255,255,255,255"
local color_offline = "255,128,128,128"
local TreeNodeList = {
  {mark_type = "partner", ui_tag = "ui_fuqi_01"},
  {
    mark_type = "sworn",
    ui_tag = "ui_sworn_01"
  },
  {
    mark_type = "friend",
    ui_tag = "ui_haoyou_01"
  },
  {
    mark_type = "buddy",
    ui_tag = "ui_zhiyou_01"
  }
}
function main_form_init(form)
  form.Fixed = false
  form.is_minimize = false
end
function on_main_form_open(form)
  change_form_size()
  InitForm_Relation(form)
  InitForm_Select(form)
  add_relation_binder(form)
  form.is_minimize = false
  init_btn_chat(form)
end
function on_main_form_close(form)
  del_relation_binder(form)
  nx_destroy(form)
end
function open_form(player_name, id)
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
  end
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
    form.player_name = player_name
    form.id = id
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function change_form_size()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function InitForm_Relation(form)
  local gui = nx_value("gui")
  form.groupbox_mark.Visible = false
  form.groupbox_item.Visible = false
  form.treenode_list = nx_call("util_gui", "get_arraylist", "groupchat:treenode_list")
  local treenode_list = form.treenode_list
  if not nx_is_valid(treenode_list) then
    return
  end
  ClearAllChild(form.groupbox_playerlist)
  init_treenode_list(form)
  local list_count = treenode_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_list:GetChildByIndex(i)
    local mark = GetNewMark()
    if nx_is_valid(mark) then
      mark.mark_type = node.mark_type
      mark.lbl_title.Text = nx_widestr(gui.TextManager:GetText(node.ui_tag))
      mark.lbl_num.Text = nx_widestr("[0/0]")
      SetExtButtonStyle(mark, false)
      mark.Top = i * mark.Height
      node.mark_node = mark
    end
  end
  AdjustTreeLayout(form.groupbox_playerlist)
end
function InitForm_Select(form)
  local gui = nx_value("gui")
  form.groupbox_select_item.Visible = false
  form.sel_treenode_list = nx_call("util_gui", "get_arraylist", "groupchat:sel_treenode_list")
  local sel_treenode_list = form.sel_treenode_list
  if not nx_is_valid(sel_treenode_list) then
    return
  end
  ClearSelectAllChild(form.groupbox_select_playerlist)
end
function SetExtButtonStyle(mark, isUnfold)
  if nx_is_valid(mark) and nx_is_valid(mark.btn_ext) then
    mark.btn_ext.NormalImage = isUnfold and unfold_normalimage or fold_normalimage
    mark.btn_ext.FocusImage = isUnfold and unfold_focusimage or fold_focusimage
    mark.btn_ext.PushImage = isUnfold and unfold_pushimage or fold_pushimage
    mark.isUnfold = isUnfold
  end
end
function AdjustTreeLayout(groupbox)
  local form = groupbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local treenode_list = form.treenode_list
  if not nx_is_valid(treenode_list) then
    return
  end
  ClearAllNeedRemoveChild(groupbox)
  local list_count = treenode_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_list:GetChildByIndex(i)
    local mark = node.mark_node
    if nx_is_valid(mark) then
      if not groupbox:IsChild(mark) then
        groupbox:Add(mark)
      end
      local node_child_count = node:GetChildCount()
      if 0 < node_child_count then
        for j = node_child_count - 1, 0, -1 do
          local sub_node = node:GetChildByIndex(j)
          local item = sub_node.item
          if nx_is_valid(item) then
            if not groupbox:IsChild(item) then
              groupbox:InsertAfter(item, mark)
            end
            if mark.isUnfold and item.isneedremove == false then
              item.Visible = true
            else
              item.Visible = false
            end
          end
        end
      end
    end
  end
  groupbox.IsEditMode = false
  groupbox:ResetChildrenYPos()
end
function ClearAllNeedRemoveChild(groupbox)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  local treenode_list = form.treenode_list
  if not nx_is_valid(treenode_list) then
    return
  end
  local list_count = treenode_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_list:GetChildByIndex(i)
    local node_child_count = node:GetChildCount()
    if 0 < node_child_count then
      for j = node_child_count - 1, 0, -1 do
        local sub_node = node:GetChildByIndex(j)
        local item = sub_node.item
        if nx_is_valid(item) then
          if nx_name(item) == "GroupBox" and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == nx_string("item") and item.isneedremove == true then
            groupbox:Remove(item)
            gui:Delete(item)
            node:RemoveChildByIndex(j)
          end
        else
          node:RemoveChildByIndex(j)
        end
      end
    end
  end
end
function AdjustSelectTreeLayout(groupbox)
  local form = groupbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local sel_treenode_list = form.sel_treenode_list
  if not nx_is_valid(sel_treenode_list) then
    return
  end
  local list_count = sel_treenode_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = sel_treenode_list:GetChildByIndex(i)
    local item = node.item_node
    item.rbtn_item.index = i
    if nx_is_valid(item) and not groupbox:IsChild(item) then
      groupbox:Add(item)
    end
  end
  groupbox.IsEditMode = false
  groupbox:ResetChildrenYPos()
end
function init_treenode_list(form)
  for i = 1, table.getn(TreeNodeList) do
    local node = TreeNodeList[i]
    local child = form.treenode_list:CreateChild(nx_string(node.mark_type))
    child.mark_type = node.mark_type
    child.ui_tag = node.ui_tag
    child.mark_node = nil
  end
end
function ClearAllChild(groupbox)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  form.treenode_list:ClearChild()
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
function ClearSelectAllChild(groupbox)
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  if not nx_is_valid(form) or not nx_is_valid(groupbox) then
    return
  end
  form.sel_treenode_list:ClearChild()
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
function GetNewMark()
  local gui = nx_value("gui")
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return nil
  end
  local mark = gui:Create("GroupBox")
  local tpl_mark = form.groupbox_mark
  if not nx_is_valid(mark) or not nx_is_valid(tpl_mark) then
    return nil
  end
  mark.ctrltype = "mark"
  mark.isUnfold = true
  mark.isneedremove = false
  mark.Left = tpl_mark.Left
  mark.Top = tpl_mark.Top
  mark.Width = tpl_mark.Width
  mark.Height = tpl_mark.Height
  mark.BackColor = tpl_mark.BackColor
  mark.NoFrame = tpl_mark.NoFrame
  local tpl_bg = tpl_mark:Find("mark_bg")
  if nx_is_valid(tpl_bg) then
    local btn_mark = gui:Create("Button")
    btn_mark.Left = tpl_bg.Left
    btn_mark.Top = tpl_bg.Top
    btn_mark.Width = tpl_bg.Width
    btn_mark.Height = tpl_bg.Height
    btn_mark.NormalImage = tpl_bg.NormalImage
    btn_mark.FocusImage = tpl_bg.FocusImage
    btn_mark.PushImage = tpl_bg.PushImage
    btn_mark.DrawMode = tpl_bg.DrawMode
    btn_mark.AutoSize = tpl_bg.AutoSize
    nx_bind_script(btn_mark, nx_current())
    nx_callback(btn_mark, "on_click", "on_btn_mark_click")
    mark:Add(btn_mark)
    mark.btn_mark = btn_mark
  end
  local tpl_ext = tpl_mark:Find("mark_ext")
  if nx_is_valid(tpl_ext) then
    local btn_ext = gui:Create("Button")
    btn_ext.Left = tpl_ext.Left
    btn_ext.Top = tpl_ext.Top
    btn_ext.Width = tpl_ext.Width
    btn_ext.Height = tpl_ext.Height
    btn_ext.NormalImage = tpl_ext.NormalImage
    btn_ext.FocusImage = tpl_ext.FocusImage
    btn_ext.PushImage = tpl_ext.PushImage
    btn_ext.DrawMode = tpl_ext.DrawMode
    btn_ext.AutoSize = tpl_ext.AutoSize
    nx_bind_script(btn_ext, nx_current())
    nx_callback(btn_ext, "on_click", "on_btn_ext_click")
    mark:Add(btn_ext)
    mark.btn_ext = btn_ext
  end
  local tpl_title = tpl_mark:Find("mark_title")
  if nx_is_valid(tpl_title) then
    local lbl_title = gui:Create("Label")
    lbl_title.Left = tpl_title.Left
    lbl_title.Top = tpl_title.Top
    lbl_title.Width = tpl_title.Width
    lbl_title.Height = tpl_title.Height
    lbl_title.ForeColor = tpl_title.ForeColor
    lbl_title.Font = tpl_title.Font
    mark:Add(lbl_title)
    mark.lbl_title = lbl_title
  end
  local tpl_num = tpl_mark:Find("mark_num")
  if nx_is_valid(tpl_num) then
    local lbl_num = gui:Create("Label")
    lbl_num.Left = tpl_num.Left
    lbl_num.Top = tpl_num.Top
    lbl_num.Width = tpl_num.Width
    lbl_num.Height = tpl_num.Height
    lbl_num.ForeColor = tpl_num.ForeColor
    lbl_num.Font = tpl_num.Font
    mark:Add(lbl_num)
    mark.lbl_num = lbl_num
  end
  return mark
end
function GetNewItem()
  local gui = nx_value("gui")
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.ctrltype = "item"
  item.isneedremove = false
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.NoFrame = tpl_item.NoFrame
  local tpl_bg = tpl_item:Find("item_bg")
  if nx_is_valid(tpl_bg) then
    local rbtn_item = gui:Create("RadioButton")
    rbtn_item.Left = tpl_bg.Left
    rbtn_item.Top = tpl_bg.Top
    rbtn_item.Width = tpl_bg.Width
    rbtn_item.Height = tpl_bg.Height
    rbtn_item.NormalImage = tpl_bg.NormalImage
    rbtn_item.FocusImage = tpl_bg.FocusImage
    rbtn_item.CheckedImage = tpl_bg.CheckedImage
    rbtn_item.DrawMode = tpl_bg.DrawMode
    rbtn_item.AutoSize = tpl_bg.AutoSize
    rbtn_item.ClickEvent = true
    nx_bind_script(rbtn_item, nx_current())
    nx_callback(rbtn_item, "on_checked_changed", "on_item_select_changed")
    nx_callback(rbtn_item, "on_click", "on_item_click")
    item:Add(rbtn_item)
    item.rbtn_item = rbtn_item
  end
  local tpl_name = tpl_item:Find("item_name")
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
  local tpl_hide = tpl_item:Find("item_hide")
  if nx_is_valid(tpl_hide) then
    local rbtn_hide = gui:Create("RadioButton")
    rbtn_hide.Left = tpl_hide.Left
    rbtn_hide.Top = tpl_hide.Top
    rbtn_hide.Width = tpl_hide.Width
    rbtn_hide.Height = tpl_hide.Height
    rbtn_hide.NormalImage = tpl_hide.NormalImage
    rbtn_hide.FocusImage = tpl_hide.FocusImage
    rbtn_hide.CheckedImage = tpl_hide.CheckedImage
    rbtn_hide.DrawMode = tpl_hide.DrawMode
    rbtn_hide.AutoSize = tpl_hide.AutoSize
    rbtn_hide.Visible = false
    item:Add(rbtn_hide)
    item.rbtn_hide = rbtn_hide
  end
  return item
end
function GetNewSelectItem()
  local gui = nx_value("gui")
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_select_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.ctrltype = "item"
  item.isneedremove = false
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.NoFrame = tpl_item.NoFrame
  local tpl_bg = tpl_item:Find("item_select_bg")
  if nx_is_valid(tpl_bg) then
    local rbtn_item = gui:Create("RadioButton")
    rbtn_item.Left = tpl_bg.Left
    rbtn_item.Top = tpl_bg.Top
    rbtn_item.Width = tpl_bg.Width
    rbtn_item.Height = tpl_bg.Height
    rbtn_item.NormalImage = tpl_bg.NormalImage
    rbtn_item.FocusImage = tpl_bg.FocusImage
    rbtn_item.CheckedImage = tpl_bg.CheckedImage
    rbtn_item.DrawMode = tpl_bg.DrawMode
    rbtn_item.AutoSize = tpl_bg.AutoSize
    nx_bind_script(rbtn_item, nx_current())
    nx_callback(rbtn_item, "on_checked_changed", "on_item_select_changed_1")
    nx_callback(rbtn_item, "on_left_double_click", "on_item_double_click_1")
    item:Add(rbtn_item)
    item.rbtn_item = rbtn_item
  end
  local tpl_name = tpl_item:Find("item_select_name")
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
  local tpl_hide = tpl_item:Find("item_select_hide")
  if nx_is_valid(tpl_hide) then
    local rbtn_hide = gui:Create("RadioButton")
    rbtn_hide.Left = tpl_hide.Left
    rbtn_hide.Top = tpl_hide.Top
    rbtn_hide.Width = tpl_hide.Width
    rbtn_hide.Height = tpl_hide.Height
    rbtn_hide.NormalImage = tpl_hide.NormalImage
    rbtn_hide.FocusImage = tpl_hide.FocusImage
    rbtn_hide.CheckedImage = tpl_hide.CheckedImage
    rbtn_hide.DrawMode = tpl_hide.DrawMode
    rbtn_hide.AutoSize = tpl_hide.AutoSize
    rbtn_hide.Visible = false
    item:Add(rbtn_hide)
    item.rbtn_hide = rbtn_hide
  end
  return item
end
function on_btn_ext_click(btn)
  on_btn_mark_click(btn)
end
function on_item_select_changed(rbtn)
  local item = rbtn.Parent
  if not nx_is_valid(item) then
    return
  end
  local form = item.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    ClearItemSelected(rbtn)
  end
end
function on_item_select_changed_1(rbtn)
  local item = rbtn.Parent
  if not nx_is_valid(item) then
    return
  end
  local form = item.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    ClearItemSelected_1(rbtn)
  end
end
function on_btn_mark_click(btn)
  local form = btn.ParentForm
  local mark = btn.Parent
  if not nx_is_valid(form) or not nx_is_valid(mark) then
    return
  end
  SetExtButtonStyle(mark, not mark.isUnfold)
  if mark.isUnfold then
    if nx_string(mark.mark_type) == "friend" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_FRIEND)
    elseif nx_string(mark.mark_type) == "buddy" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_BUDDY)
    elseif nx_string(mark.mark_type) == "attention" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_ATTENTION)
    elseif nx_string(mark.mark_type) == "acquaint" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_ACQUAINT)
    elseif nx_string(mark.mark_type) == "blood" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_BLOOD)
    elseif nx_string(mark.mark_type) == "enemy" then
      nx_execute("custom_sender", "custom_query_enemy_info", 0, RELATION_TYPE_ENEMY)
    end
  end
  AdjustTreeLayout(form.groupbox_playerlist)
end
function add_relation_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddTableBind(FRIEND_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(BUDDY_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddTableBind(SWORN_REC, form, nx_current(), "on_table_rec_changed")
    data_binder:AddRolePropertyBind("PartnerNamePrivate", "widestr", form, nx_current(), "on_player_prop_changed")
  end
end
function del_relation_binder(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelTableBind(FRIEND_REC, form)
    data_binder:DelTableBind(BUDDY_REC, form)
    data_binder:DelTableBind(SWORN_REC, form)
    data_binder:DelRolePropertyBind("PartnerNamePrivate", form)
  end
end
function on_table_rec_changed(form, rec_name, opt_type, row, col)
  local typename = get_typename_by_tablename(rec_name)
  if nx_string(typename) ~= "" then
    UpdateFormTree(form, typename)
    if nx_string(typename) == nx_string("friend") or nx_string(typename) == nx_string("buddy") then
      UpdateFormTree(form, "partner")
    end
  end
end
function on_player_prop_changed(form, prop_name, prop_type, prop_value)
  local typename = get_typename_by_propname(prop_name)
  if nx_string(typename) ~= "" then
    UpdateFormTree(form, typename)
  end
end
function get_typename_by_tablename(rec_name)
  if nx_string(rec_name) == SWORN_REC then
    return "sworn"
  end
  if nx_string(rec_name) == NEW_TEACHER_REC then
    return "newteacher"
  end
  if string.find(nx_string(rec_name), "rec_") == nil then
    return ""
  end
  if nx_string(rec_name) == PUPIL_JINGMAI_REC then
    return "teacherpupil"
  end
  local typename = string.sub(nx_string(rec_name), string.len("rec_") + 1)
  return typename
end
function get_typename_by_propname(prop_name)
  if nx_string(prop_name) == "PartnerNamePrivate" then
    return "partner"
  else
    return ""
  end
end
function UpdateFormTree(form, typename)
  local treenode_list = form.treenode_list
  if not nx_is_valid(treenode_list) then
    return
  end
  local index = GetNodeIndex(typename)
  if index < 0 then
    return
  end
  local node = treenode_list:GetChildByIndex(index)
  local node_count = node:GetChildCount()
  for i = 0, node_count - 1 do
    local sub_node = node:GetChildByIndex(i)
    local item = sub_node.item
    if nx_is_valid(item) then
      item.Visible = false
      item.isneedremove = true
    end
  end
  local member_table = do_sort_byonline(get_member_list(typename))
  local member_count = table.getn(member_table)
  local online_count = 0
  for i = 1, table.getn(member_table) do
    local record = member_table[i]
    if nx_widestr(record.player_name) ~= nx_widestr("") then
      local is_online = nx_int(record.online) == nx_int(0)
      local hot_num = record.self_relation + record.target_relation
      local new_item = GetNewItem()
      new_item.Visible = false
      new_item.mark_type = typename
      new_item.is_online = is_online
      new_item.rbtn_item.is_online = is_online
      new_item.revenge_point = nx_int(record.revenge_point)
      new_item.lbl_name.Text = nx_widestr(record.player_name)
      new_item.lbl_name.ForeColor = is_online and color_online or color_offline
      local sub_node = node:CreateChild("")
      sub_node.item = new_item
      if is_online then
        online_count = online_count + 1
      end
    end
  end
  local mark = node.mark_node
  mark.lbl_num.Text = nx_widestr(string.format("[%s/%s]", online_count, member_count))
  mark.online_count = online_count
  mark.member_count = member_count
  AdjustTreeLayout(form.groupbox_playerlist)
end
function on_item_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_TAROT) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "sys_tarot_005")
    return
  end
  local form = btn.ParentForm
  local groupbox = btn.Parent
  if btn.is_online == false then
  end
  local player_name = groupbox.lbl_name.Text
  if player_name == nx_widestr("") then
    return
  end
  local info = get_share_chat(form)
  nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "auto_send", nx_widestr(player_name), nx_widestr(info))
  close_form()
end
function on_item_double_click_1(btn)
  local form = btn.ParentForm
  local groupbox = btn.Parent
  local sel_treenode_list = form.sel_treenode_list
  if not nx_is_valid(sel_treenode_list) then
    return
  end
  local index = btn.index
  local node = sel_treenode_list:GetChildByIndex(index)
  local player_name = nx_string(groupbox.lbl_name.Text)
  if not nx_is_valid(node) then
    return
  end
  local item = node.item_node
  form.sel_treenode_list:RemoveChild(player_name)
  form.groupbox_select_playerlist:Remove(item)
  local list_count = form.sel_treenode_list:GetChildCount()
  form.lbl_num.Text = nx_widestr("[") .. nx_widestr(list_count) .. nx_widestr("]")
  AdjustSelectTreeLayout(form.groupbox_select_playerlist)
end
function GetNodeIndex(typename)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return -1
  end
  local treenode_list = form.treenode_list
  if not nx_is_valid(treenode_list) then
    return -1
  end
  local list_count = treenode_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = treenode_list:GetChildByIndex(i)
    if nx_string(node.mark_type) == nx_string(typename) then
      return i
    end
  end
  return -1
end
function ClearItemSelected(rbtn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local child_table = form.groupbox_playerlist:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and "GroupBox" == nx_name(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == nx_string("item") then
      if nx_is_valid(rbtn) then
        if not nx_id_equal(child.rbtn_item, rbtn) then
          child.rbtn_hide.Checked = true
        end
      else
        child.rbtn_hide.Checked = true
      end
    end
  end
end
function ClearItemSelected_1(rbtn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local child_table = form.groupbox_select_playerlist:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and "GroupBox" == nx_name(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == nx_string("item") then
      if nx_is_valid(rbtn) then
        if not nx_id_equal(child.rbtn_item, rbtn) then
          child.rbtn_hide.Checked = true
        end
      else
        child.rbtn_hide.Checked = true
      end
    end
  end
end
function get_member_list(typename)
  if nx_string(typename) == "partner" then
    return get_partner_table()
  elseif nx_string(typename) == "sworn" then
    return get_sworn_table()
  elseif nx_string(typename) == "friend" then
    return get_friend_table()
  elseif nx_string(typename) == "buddy" then
    return get_buddy_table()
  else
    return {}
  end
end
function do_sort_byonline(record_table)
  local online_table = {}
  local offline_table = {}
  local count = table.getn(record_table)
  for i = 1, count do
    local record = record_table[i]
    if nx_int(record.online) == nx_int(0) then
      table.insert(online_table, record)
    else
      table.insert(offline_table, record)
    end
  end
  local new_table = {}
  count = table.getn(online_table)
  for i = 1, count do
    table.insert(new_table, online_table[i])
  end
  count = table.getn(offline_table)
  for i = 1, count do
    table.insert(new_table, offline_table[i])
  end
  return new_table
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local sel_treenode_list = form.sel_treenode_list
  if not nx_is_valid(sel_treenode_list) then
    return
  end
  local player_list = nx_widestr("")
  local list_count = sel_treenode_list:GetChildCount()
  for i = 0, list_count - 1 do
    local node = sel_treenode_list:GetChildByIndex(i)
    local item = node.item_node
    local player_name = nx_widestr(item.lbl_name.Text)
    player_list = player_list .. player_name .. nx_widestr(",")
  end
end
function init_btn_chat(form)
  if not can_chat_guild() then
    form.btn_banghui.Enabled = false
  end
  if not can_chat_league() then
    form.btn_lianmeng.Enabled = false
  end
  if not can_chat_team() then
    form.btn_duiwu.Enabled = false
    form.btn_tuandui.Enabled = false
  end
  if not can_chat_tuandui() then
    form.btn_tuandui.Enabled = false
  end
  form.btn_menpai.Visible = false
  form.btn_shili.Visible = false
  form.btn_yinshi.Visible = false
  form.btn_menyin.Enabled = false
  if can_chat_menpai() then
    form.btn_menpai.Visible = true
    form.btn_menyin.Enabled = true
  elseif can_chat_shili() then
    form.btn_shili.Visible = true
  elseif can_chat_yinshi() then
    form.btn_yinshi.Visible = true
    form.btn_menyin.Enabled = true
  else
    form.btn_menpai.Visible = true
    form.btn_menpai.Enabled = false
  end
end
function on_btn_chat_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_TAROT) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "sys_tarot_005")
    return
  end
  local form = btn.ParentForm
  local info = get_share_chat(form)
  local btn_name = btn.Name
  if btn_name == "btn_shijie" then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat")
    if not nx_is_valid(dialog) then
      return
    end
    local text = util_text("ui_congirm_channel_" .. nx_string(9))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_chat", nx_int(9), nx_widestr(info))
    else
      return
    end
  elseif btn_name == "btn_fujin" then
    nx_execute("custom_sender", "custom_chat", nx_int(1), nx_widestr(info))
  elseif btn_name == "btn_changjing" then
    nx_execute("custom_sender", "custom_chat", nx_int(2), nx_widestr(info))
  elseif btn_name == "btn_liuyan" then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat")
    if not nx_is_valid(dialog) then
      return
    end
    local text = util_text("ui_congirm_channel_" .. nx_string(10))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_chat", nx_int(10), nx_widestr(info))
    else
      return
    end
  elseif btn_name == "btn_banghui" then
    nx_execute("custom_sender", "custom_chat", nx_int(6), nx_widestr(info))
  elseif btn_name == "btn_lianmeng" then
    nx_execute("custom_sender", "custom_chat", nx_int(40), nx_widestr(info))
  elseif btn_name == "btn_duiwu" then
    nx_execute("custom_sender", "custom_chat", nx_int(19), nx_widestr(info))
  elseif btn_name == "btn_tuandui" then
    nx_execute("custom_sender", "custom_chat", nx_int(4), nx_widestr(info))
  elseif btn_name == "btn_menyin" then
    nx_execute("custom_sender", "custom_chat", nx_int(39), nx_widestr(info))
  elseif btn_name == "btn_menpai" then
    nx_execute("custom_sender", "custom_chat", nx_int(8), nx_widestr(info))
  elseif btn_name == "btn_shili" then
    nx_execute("custom_sender", "custom_chat", nx_int(30), nx_widestr(info))
  elseif btn_name == "btn_yinshi" then
    nx_execute("custom_sender", "custom_chat", nx_int(32), nx_widestr(info))
  end
  close_form()
end
function get_share_chat(form)
  local player_name = form.player_name
  local id = form.id
  local data = nx_widestr("tarot,") .. nx_widestr(player_name) .. nx_widestr(",") .. nx_widestr(id)
  local info = util_format_string("ui_tarot_chat", nx_string(data), "ui_tarot_" .. nx_string(id))
  return info
end
function can_chat_team()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindProp("TeamID") then
    local team_id = client_player:QueryProp("TeamID")
    if 0 < team_id then
      return true
    end
  end
  return false
end
function can_chat_tuandui()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindProp("TeamType") then
    local team_id = client_player:QueryProp("TeamType")
    if team_id == 1 then
      return true
    end
  end
  return false
end
function can_chat_guild()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindProp("GuildName") then
    local guild_name = client_player:QueryProp("GuildName")
    if guild_name ~= nx_widestr("") then
      return true
    end
  end
  return false
end
function can_chat_league()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindProp("GuildLeagueName") then
    local guild_league = client_player:QueryProp("GuildLeagueName")
    if guild_league ~= nx_widestr("") then
      return true
    end
  end
  return false
end
function can_chat_menpai()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindProp("School") then
    local school = client_player:QueryProp("School")
    if school ~= nx_widestr("") then
      return true
    end
  end
  return false
end
function can_chat_shili()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindProp("Force") then
    local force = client_player:QueryProp("Force")
    if force ~= nx_widestr("") then
      return true
    end
  end
  return false
end
function can_chat_yinshi()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindProp("NewSchool") then
    local new_school = client_player:QueryProp("NewSchool")
    if new_school ~= nx_widestr("") then
      return true
    end
  end
  return false
end
function a(info)
  nx_msgbox(nx_string(info))
end
