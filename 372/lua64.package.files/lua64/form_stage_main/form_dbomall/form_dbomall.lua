require("utils")
require("util_gui")
require("util_functions")
require("game_object")
require("share\\capital_define")
require("form_stage_main\\switch\\switch_define")
local FORM_DBOMALL = "form_stage_main\\form_dbomall\\form_dbomall"
function open_form(form_path)
  local form = nx_value(FORM_DBOMALL)
  if not nx_is_valid(form) then
    form = util_auto_show_hide_form(FORM_DBOMALL)
  end
  form.Visible = false
  local child_table = form.groupbox_form:GetChildControlList()
  local child_count = table.getn(child_table)
  local item
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and nx_find_custom(child, "ctrltype") then
      if nx_string(child.ctrltype) == "item" then
        if nx_find_custom(child, "form_path") then
          local str_lst = util_split_string(child.form_path, ",")
          if table.getn(str_lst) == 1 then
            if nx_string(child.form_path) == nx_string(form_path) then
              item = child
            end
          elseif table.getn(str_lst) == 2 and (nx_string(str_lst[1]) == "open_form" or nx_string(str_lst[1]) == "show_form") and nx_string(form_path) == nx_string(str_lst[2]) then
            item = child
          end
        end
      elseif nx_string(child.ctrltype) == "mark" then
        child.expand = 0
        ExpandMark(child, 0)
      end
    end
  end
  if nx_is_valid(item) then
    local enable = true
    local switch_manager = nx_value("SwitchManager")
    if nx_is_valid(switch_manager) and nx_find_custom(item, "conditionid") then
      local conditionid = nx_int(item.conditionid)
      if nx_int(conditionid) > nx_int(0) then
        enable = switch_manager:CheckSwitchEnable(conditionid)
      end
    end
    if enable then
      local mark = GetMark(item)
      if nx_is_valid(mark) then
        mark.expand = 1
        ExpandMark(mark, 1)
        item.rbtn_check.Checked = true
      end
    end
  end
  form.Visible = true
end
function main_form_init(form)
  form.Fixed = false
  form.sub_form = nil
  form.actid = 0
end
function on_main_form_open(form)
  change_form_size()
  Init_Form_List(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddRolePropertyBind("CapitalType0", "int", form, nx_current(), "on_gold_changed")
  end
end
function on_main_form_close(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelRolePropertyBind("CapitalType0", form)
  end
  close_all_sub_form()
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_exchange_click(btn)
  nx_execute("form_stage_main\\form_consign\\form_buy_capital", "show_hide_buy_capital_form")
end
function on_btn_chargeshop_click(btn)
  nx_execute("form_stage_main\\form_main\\form_main_func_btns", "on_open_form", "btn_charge_shop")
end
function on_btn_recharge_click(btn)
  nx_execute("form_stage_main\\switch\\util_url_function", "open_charge_url")
end
function on_btn_mark_click(btn)
  local gbx = btn.Parent
  local expand = gbx.expand
  expand = nx_int(expand) == nx_int(0) and 1 or 0
  gbx.expand = expand
  ExpandMark(gbx, expand)
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked then
    hide_loading()
    local gbx = rbtn.Parent
    if not nx_is_valid(gbx) then
      return
    end
    ClearItemSelected(gbx)
    local form_path = gbx.form_path
    local actid = gbx.actid
    if nx_int(actid) > nx_int(0) then
      create_activity_form(actid)
    elseif nx_string(form_path) ~= nx_string("") then
      if nx_string(form_path) == nx_string("form_stage_main\\form_dbomall\\form_sign_and_draw") then
        local game_client = nx_value("game_client")
        if not nx_is_valid(game_client) then
          return
        end
        local player = game_client:GetPlayer()
        if not nx_is_valid(player) then
          return
        end
        local is_jyf_faculty = player:QueryProp("IsJYFaucltyAttacker")
        if nx_int(is_jyf_faculty) == nx_int(1) then
          local SystemCenterInfo = nx_value("SystemCenterInfo")
          if nx_is_valid(SystemCenterInfo) then
            SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_activity_sign_n_draw_08"), 2)
          end
          return
        end
        create_sub_form(form_path)
        local form = util_get_form(form_path, false, false)
        if not nx_is_valid(form) then
          return
        end
        form.Visible = false
        nx_execute("custom_sender", "custom_form_sign_and_draw", CLIENT_SUBMSG_SIGN_N_DRAW_REFRESH_FORM)
      else
        create_sub_form(form_path)
      end
    else
      close_cur_sub_form()
    end
  end
end
function on_gold_changed(form)
  local manager = nx_value("CapitalModule")
  if not nx_is_valid(manager) then
    return
  end
  local point = manager:GetCapital(CAPITAL_TYPE_GOLDEN)
  local txt = manager:GetFormatCapitalHtml(CAPITAL_TYPE_GOLDEN, point)
  form.mltbox_silver.HtmlText = txt
end
function on_switch_changed(type, is_open)
  local form = nx_value(FORM_DBOMALL)
  if not nx_is_valid(form) then
    return
  end
  local groupbox = form.groupbox_form
  if not nx_is_valid(groupbox) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == "item" and nx_find_custom(child, "conditionid") then
      local conditionid = nx_int(child.conditionid)
      if conditionid > nx_int(0) then
        local enable = switch_manager:CheckSwitchEnable(conditionid)
        local mark = GetMark(child)
        if child.Visible and not enable then
          child.Visible = false
        elseif not child.Visible and enable and nx_is_valid(mark) and nx_find_custom(mark, "expand") and nx_int(mark.expand) ~= nx_int(0) then
          child.Visible = true
        end
      end
    end
  end
  local cur_form_path = ""
  if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
    cur_form_path = nx_string(form.sub_form.Name)
  end
  local item = GetItem(groupbox, cur_form_path)
  if nx_is_valid(item) and not item.Visible then
    for i = 1, child_count do
      local child = child_table[i]
      if nx_is_valid(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == "item" and not nx_id_equal(item, child) then
        local conditionid = nx_int(child.conditionid)
        if nx_int(conditionid) <= nx_int(0) then
          open_form(child.form_path)
          break
        end
        local enable = switch_manager:CheckSwitchEnable(conditionid)
        if enable then
          open_form(child.form_path)
          break
        end
      end
    end
  end
  AdjustLayout(form.groupbox_form)
end
function Init_Form_List(form)
  local gui = nx_value("gui")
  local dbomall_manager = nx_value("dbomall_manager")
  if not nx_is_valid(dbomall_manager) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  form.gbx_mark.Visible = false
  form.gbx_item.Visible = false
  clear_all_child(form.groupbox_form)
  local mark_count = dbomall_manager:GetMarkCount()
  for i = 1, mark_count do
    local lbl = dbomall_manager:GetMarkLabel(i - 1)
    local mouse_out = dbomall_manager:GetMarkMouseOut(i - 1)
    local mouse_on = dbomall_manager:GetMarkMouseOn(i - 1)
    local mouse_down = dbomall_manager:GetMarkMouseDown(i - 1)
    local expand = dbomall_manager:GetMarkExpand(i - 1)
    local mark = GenNewMark()
    mark.self_index = i
    mark.expand = expand
    if nx_string(lbl) ~= nx_string("") then
      mark.btn_mark.Text = nx_widestr("@" .. lbl)
    end
    mark.btn_mark.NormalImage = mouse_out
    mark.btn_mark.FocusImage = mouse_on
    mark.btn_mark.PushImage = mouse_down
    form.groupbox_form:Add(mark)
    local part_table = dbomall_manager:GetPartItemList(i - 1)
    local part_count = dbomall_manager:GetPartCount(i - 1)
    local num = table.getn(part_table) / part_count
    for j = 1, part_count do
      local base = num * (j - 1)
      local lbl = part_table[base + 1]
      local open = part_table[base + 2]
      local conditionid = part_table[base + 3]
      local actid = part_table[base + 4]
      local part = GenNewItem()
      part.parent_index = i
      part.form_path = nx_string(open)
      part.conditionid = nx_int(conditionid)
      part.actid = nx_int(actid)
      if nx_string(lbl) ~= nx_string("") then
        part.rbtn_check.Text = nx_widestr("@" .. lbl)
      else
        local dbomall_manager = nx_value("dbomall_manager")
        if nx_int(actid) > nx_int(0) and nx_is_valid(dbomall_manager) then
          local uitable = dbomall_manager:GetPushActItemList(actid)
          if 1 <= table.getn(uitable) then
            part.rbtn_check.Text = nx_widestr(uitable[1])
          end
        end
      end
      part.Visible = nx_int(expand) ~= nx_int(0)
      if nx_int(conditionid) > nx_int(0) and not switch_manager:CheckSwitchEnable(conditionid) then
        part.Visible = false
      end
      if nx_int(actid) <= nx_int(0) and nx_string(open) == nx_string("") then
        part.Visible = false
      end
      form.groupbox_form:Add(part)
      if part.Visible and not nx_find_custom(form, "default_part") then
        form.default_part = part
      end
    end
  end
  local bNoCheckItem = false
  if nx_find_custom(form, "default_part") and nx_is_valid(form.default_part) then
    form.default_part.rbtn_check.Checked = true
    util_remove_custom(form, "default_part")
  else
    bNoCheckItem = true
  end
  AdjustLayout(form.groupbox_form)
  if bNoCheckItem then
    local item = GetFirstEnableItem(form.groupbox_form)
    if nx_is_valid(item) then
      open_form(item.form_path)
    end
  end
end
function ExpandMark(gbx, expand)
  if not nx_is_valid(gbx) then
    return
  end
  local form = gbx.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local flag = gbx.self_index
  local child_table = form.groupbox_form:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and nx_find_custom(child, "ctrltype") and nx_find_custom(child, "parent_index") and nx_int(child.parent_index) == nx_int(flag) then
      child.Visible = nx_int(expand) ~= nx_int(0)
      if nx_find_custom(child, "conditionid") then
        local conditionid = nx_int(child.conditionid)
        if conditionid > nx_int(0) and not switch_manager:CheckSwitchEnable(conditionid) then
          child.Visible = false
        end
      end
    end
  end
  AdjustLayout(form.groupbox_form)
end
function HandleSpecialShow(groupbox)
  if not nx_is_valid(groupbox) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local first_pay = client_player:QueryProp("DboMallFirstPay")
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == "item" and nx_find_custom(child, "form_path") and nx_string(child.form_path) == "form_stage_main\\form_dbomall\\form_dbofirst" and child.Visible and nx_int(first_pay) ~= nx_int(0) then
      child.Visible = false
    end
  end
end
function AdjustLayout(groupbox)
  if not nx_is_valid(groupbox) then
    return
  end
  local dbomall_manager = nx_value("dbomall_manager")
  if nx_is_valid(dbomall_manager) and dbomall_manager:IsAllConditionClosed() then
    local form = groupbox.ParentForm
    if nx_is_valid(form) then
      form:Close()
    end
    return
  end
  HandleSpecialShow(groupbox)
  HideMarkNoItem(groupbox)
  groupbox.IsEditMode = false
  groupbox:ResetChildrenYPos()
end
function create_sub_form(form_name)
  local form = nx_value(FORM_DBOMALL)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
    if nx_string(form.sub_form.Name) == nx_string(form_name) then
      return
    end
    form.sub_form:Close()
    form.sub_form = nil
    form.actid = 0
  end
  local info = util_split_string(form_name, ",")
  if table.getn(info) == 2 then
    if nx_string(info[1]) == "custom_sender" then
      nx_execute("custom_sender", nx_string(info[2]))
    elseif nx_string(info[1]) == "open_form" then
      nx_execute(nx_string(info[2]), "open_form")
    elseif nx_string(info[1]) == "show_form" then
      nx_execute(nx_string(info[2]), "show_form")
    end
  else
    local subface = nx_execute("util_gui", "util_get_form", form_name, true, false)
    if not nx_is_valid(subface) then
      return
    end
    form.groupbox_main:Add(subface)
    form.sub_form = subface
    form.actid = 0
    subface.Top = 0
    subface.Left = 0
    subface.Visible = true
  end
end
function add_sub_form(subface)
  local form = nx_execute("util_gui", "util_get_form", FORM_DBOMALL, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
    form.sub_form:Close()
    form.sub_form = nil
    form.actid = 0
  end
  if not nx_is_valid(subface) then
    return
  end
  form.groupbox_main:Add(subface)
  form.sub_form = subface
  form.actid = 0
  subface.Top = 0
  subface.Left = 0
  subface.Visible = true
end
function create_activity_form(actid)
  if nx_int(actid) <= nx_int(0) then
    return
  end
  local FORM_PROTOTYPE = "form_stage_main\\form_dbomall\\form_dboprototype"
  local form = nx_value(FORM_DBOMALL)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
    if nx_int(actid) > nx_int(0) and nx_int(form.actid) == nx_int(actid) then
      return
    end
    form.sub_form:Close()
    form.sub_form = nil
    form.actid = 0
  end
  local flag = "_act" .. nx_string(actid)
  local subface = nx_execute("util_gui", "util_get_form", FORM_PROTOTYPE, true, false, flag)
  if not nx_is_valid(subface) then
    return
  end
  local dbomall_manager = nx_value("dbomall_manager")
  if nx_is_valid(dbomall_manager) then
    local uitable = dbomall_manager:GetPushActItemList(actid)
    local count = table.getn(uitable)
    if 1 <= count then
      subface.lbl_title.Text = nx_widestr(uitable[1])
    end
    if 2 <= count then
      subface.mltbox_time.HtmlText = nx_widestr(uitable[2])
    end
    if 3 <= count then
      subface.lbl_back.BackImage = nx_string(uitable[3])
    end
    if 4 <= count then
      subface.mltbox_content.HtmlText = nx_widestr(uitable[4])
    end
    if 5 <= count then
      subface.mltbox_help.HtmlText = nx_widestr(uitable[5])
    end
    if 6 <= count then
      local location = nx_string(uitable[6])
      if nx_string(location) ~= nx_string("") then
        local pos = util_split_string(location, ",")
        local left = nx_int(pos[1])
        local top = nx_int(pos[2])
        local width = nx_int(pos[3])
        local height = nx_int(pos[4])
        subface.lbl_content_back.Left = left
        subface.lbl_content_back.Top = top
        subface.lbl_content_back.Width = width
        subface.lbl_content_back.Height = height
        subface.mltbox_content.Left = left + 7
        subface.mltbox_content.Top = top + 4
        subface.mltbox_content.Width = width - 10
        subface.mltbox_content.Height = height - 7
      end
    end
  end
  form.groupbox_main:Add(subface)
  form.sub_form = subface
  form.actid = actid
  subface.Top = 0
  subface.Left = 0
  subface.Visible = true
end
function close_cur_sub_form()
  local form = nx_value(FORM_DBOMALL)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
    form.sub_form:Close()
    util_remove_custom(form, "sub_form")
  end
end
function close_all_sub_form()
  local dbomall_manager = nx_value("dbomall_manager")
  if not nx_is_valid(dbomall_manager) then
    return
  end
  local sub_form_tables = dbomall_manager:GetSubFormList()
  for i = 1, table.getn(sub_form_tables) do
    local subface = nx_value(sub_form_tables[i])
    if nx_is_valid(subface) then
      subface:Close()
    end
  end
end
function clear_all_child(groupbox)
  local gui = nx_value("gui")
  if not nx_is_valid(groupbox) then
    return
  end
  local form = groupbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  if 0 < child_count then
    for i = child_count, 1, -1 do
      local child = child_table[i]
      if nx_is_valid(child) and nx_find_custom(child, "ctrltype") then
        groupbox:Remove(child)
        gui:Delete(child)
      end
    end
  end
end
function GenNewMark()
  local gui = nx_value("gui")
  local form = nx_value(FORM_DBOMALL)
  if not nx_is_valid(form) then
    return nil
  end
  local mark = gui:Create("GroupBox")
  local tpl_mark = form.gbx_mark
  if not nx_is_valid(mark) or not nx_is_valid(tpl_mark) then
    return nil
  end
  CopyControlProps(mark, tpl_mark)
  mark.ctrltype = "mark"
  mark.Visible = true
  local btn_mark = gui:Create("Button")
  local tpl_btn = form.select_mark
  if nx_is_valid(btn_mark) then
    CopyControlProps(btn_mark, tpl_btn)
    nx_bind_script(btn_mark, nx_current())
    nx_callback(btn_mark, "on_click", "on_btn_mark_click")
    mark:Add(btn_mark)
    mark.btn_mark = btn_mark
  end
  return mark
end
function GenNewItem()
  local form = nx_value(FORM_DBOMALL)
  if not nx_is_valid(form) then
    return nil
  end
  local gui = nx_value("gui")
  local item = gui:Create("GroupBox")
  local tpl_item = form.gbx_item
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  CopyControlProps(item, tpl_item)
  item.ctrltype = "item"
  item.Visible = true
  local rbtn_check = gui:Create("RadioButton")
  local tpl_check = form.select_item
  if nx_is_valid(rbtn_check) then
    CopyControlProps(rbtn_check, tpl_check)
    nx_bind_script(rbtn_check, nx_current())
    nx_callback(rbtn_check, "on_checked_changed", "on_rbtn_checked_changed")
    item:Add(rbtn_check)
    item.rbtn_check = rbtn_check
  end
  local rbtn_hide = gui:Create("RadioButton")
  local tpl_hide = form.hide_item
  if nx_is_valid(rbtn_hide) then
    CopyControlProps(rbtn_hide, tpl_hide)
    item:Add(rbtn_hide)
    item.rbtn_hide = rbtn_hide
  end
  local lbl_update = gui:Create("Label")
  local tpl_update = form.select_update
  if nx_is_valid(lbl_update) then
    CopyControlProps(lbl_update, tpl_update)
    lbl_update.Visible = false
    item:Add(lbl_update)
    item.lbl_update = lbl_update
  end
  return item
end
function CopyControlProps(dest, src)
  if not nx_is_valid(dest) then
    return
  end
  if not nx_is_valid(src) then
    return
  end
  local prop_table = nx_property_list(src)
  for i = 1, table.getn(prop_table) do
    local prop_name = prop_table[i]
    local prop_value = nx_property(src, prop_name)
    nx_set_property(dest, prop_name, prop_value)
  end
end
function ClearItemSelected(item)
  if not nx_is_valid(item) then
    return
  end
  local form = item.ParentForm
  local child_table = form.groupbox_form:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and "GroupBox" == nx_name(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == nx_string("item") then
      if nx_is_valid(item) then
        if not nx_id_equal(child, item) then
          child.rbtn_hide.Checked = true
        end
      else
        child.cbtn_hide.Checked = true
      end
    end
  end
end
function GetMark(item)
  if not nx_is_valid(item) then
    return nil
  end
  if not nx_find_custom(item, "parent_index") then
    return nil
  end
  local parent_index = item.parent_index
  local groupbox = item.Parent
  if not nx_is_valid(groupbox) then
    return nil
  end
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == "mark" and nx_find_custom(child, "self_index") and nx_int(child.self_index) == nx_int(parent_index) then
      return child
    end
  end
  return nil
end
function GetItem(groupbox, file_path)
  if not nx_is_valid(groupbox) then
    return nil
  end
  if nx_string(file_path) == nx_string("") then
    return nil
  end
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == "item" and nx_string(file_path) == nx_string(child.form_path) then
      return child
    end
  end
  return nil
end
function GetFirstEnableItem(groupbox)
  if not nx_is_valid(groupbox) then
    return nil
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and nx_find_custom(child, "ctrltype") and nx_string(child.ctrltype) == "item" and nx_find_custom(child, "conditionid") then
      local conditionid = nx_int(child.conditionid)
      if nx_int(conditionid) <= nx_int(0) then
        return child
      end
      local enable = switch_manager:CheckSwitchEnable(conditionid)
      if enable then
        return child
      end
    end
  end
  return nil
end
function HideMarkNoItem(groupbox)
  if not nx_is_valid(groupbox) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local mark = child_table[i]
    if nx_is_valid(mark) and nx_find_custom(mark, "ctrltype") and nx_string(mark.ctrltype) == "mark" and nx_find_custom(mark, "self_index") then
      local self_index = nx_int(mark.self_index)
      local bVisile = false
      for j = 1, child_count do
        local item = child_table[j]
        if nx_is_valid(item) and nx_find_custom(item, "ctrltype") and nx_string(item.ctrltype) == "item" and nx_find_custom(item, "parent_index") and nx_int(item.parent_index) == nx_int(self_index) and nx_find_custom(item, "conditionid") then
          local conditionid = nx_int(item.conditionid)
          if nx_int(conditionid) <= nx_int(0) then
            bVisile = true
            break
          end
          local enable = switch_manager:CheckSwitchEnable(conditionid)
          if enable then
            bVisile = true
            break
          end
        end
      end
      mark.Visible = bVisile
    end
  end
end
function show_loading()
  local form = nx_value(FORM_DBOMALL)
  if not nx_is_valid(form) then
    return
  end
  local groupbox = form.groupbox_main
  if not nx_is_valid(form) then
    return
  end
  form.lbl_connect.Visible = true
  form.lbl_wait.Visible = true
  groupbox:ToFront(form.lbl_connect)
  groupbox:ToFront(form.lbl_wait)
end
function hide_loading()
  local form = nx_value(FORM_DBOMALL)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_connect.Visible = false
  form.lbl_wait.Visible = false
end
function change_form_size()
  local form = nx_value(FORM_DBOMALL)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
