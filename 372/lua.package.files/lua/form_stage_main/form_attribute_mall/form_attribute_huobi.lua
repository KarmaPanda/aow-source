require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_attribute_mall\\form_attribute_huobi"
local ARRAY_NAME_SEC = "array_attr_huobi_sec"
local ARRAY_NAME_PROP = "array_attr_huobi_prop"
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.sec_count = 0
  load_ini(form)
  init_form(form)
end
function on_main_form_close(form)
  del_bind(form)
  nx_destroy(form)
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form.Visible = true
    form:Show()
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  close_form()
end
function load_ini(form)
  local common_array = nx_value("common_array")
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\attr_huobi\\attr_huobi.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = nx_number(ini:GetSectionCount())
  if sec_count <= 0 then
    return
  end
  form.sec_count = sec_count
  for i = 0, sec_count - 1 do
    local array_sec = get_array_name_sec(i)
    common_array:RemoveArray(array_sec)
    common_array:AddArray(array_sec, form, 600, true)
    local sec = ini:GetSectionByIndex(i)
    local item_count = ini:GetSectionItemCount(i)
    common_array:AddChild(array_sec, "sec", nx_string(sec))
    common_array:AddChild(array_sec, "item_count", nx_string(item_count))
    for j = 0, item_count - 1 do
      local array_prop = get_array_name_prop(i, j)
      common_array:RemoveArray(array_prop)
      common_array:AddArray(array_prop, form, 600, true)
      local prop_value = ini:GetSectionItemValue(i, j)
      local tab_prop = util_split_string(prop_value, ",")
      local prop = tab_prop[1]
      local ui = tab_prop[2]
      local max = tab_prop[3]
      local image = tab_prop[4]
      common_array:AddChild(array_prop, "prop", prop)
      common_array:AddChild(array_prop, "ui", ui)
      common_array:AddChild(array_prop, "max", max)
      common_array:AddChild(array_prop, "image", image)
    end
  end
end
function init_form(form)
  local common_array = nx_value("common_array")
  form.gsb_1.IsEditMode = true
  form.gsb_1:DeleteAll()
  for i = 0, form.sec_count - 1 do
    local array_sec = get_array_name_sec(i)
    local sec = common_array:FindChild(array_sec, "sec")
    local item_count = nx_number(common_array:FindChild(array_sec, "item_count"))
    local gb_group = create_ctrl("GroupBox", "gb_group_" .. nx_string(i), form.gb_group_mod, form.gsb_1)
    gb_group.Left = 5
    local gb_group_1 = create_ctrl("GroupBox", "gb_group_1_" .. nx_string(i), form.gb_group_mod_1, gb_group)
    local gb_group_2 = create_ctrl("GroupBox", "gb_group_2_" .. nx_string(i), form.gb_group_mod_2, gb_group)
    gb_group_1.Left = 0
    gb_group_2.Left = 0
    local cbtn_group = create_ctrl("CheckButton", "cbtn_group_" .. nx_string(i), form.cbtn_group_mod, gb_group_1)
    local lbl_group = create_ctrl("Label", "lbl_group_" .. nx_string(i), form.lbl_group_mod, gb_group_1)
    cbtn_group.Checked = true
    cbtn_group.gb_parent = gb_group
    cbtn_group.gb_1 = gb_group_1
    cbtn_group.gb_2 = gb_group_2
    nx_bind_script(cbtn_group, nx_current())
    nx_callback(cbtn_group, "on_checked_changed", "on_cbtn_group_checked_changed")
    lbl_group.Text = nx_widestr(util_text(sec))
    gb_group_2.Height = form.gb_item_mod.Height * item_count
    gb_group.Height = gb_group_1.Height + gb_group_2.Height
    for j = 0, item_count - 1 do
      local gb_mod = form.gb_item_mod
      local lbl_mod_ui = form.lbl_item_mod_ui
      local lbl_mod_value = form.lbl_item_mod_value
      local lbl_mod_image = form.lbl_item_mod_image
      local lbl_mod_bg = form.lbl_item_mod_bg
      if math.mod(j, 2) == 1 then
        gb_mod = form.gb_item_mod2
        lbl_mod_ui = form.lbl_item_mod_ui2
        lbl_mod_value = form.lbl_item_mod_value2
        lbl_mod_image = form.lbl_item_mod_image2
        lbl_mod_bg = form.lbl_item_mod_bg2
      end
      local array_prop = get_array_name_prop(i, j)
      local prop = common_array:FindChild(array_prop, "prop")
      local ui = common_array:FindChild(array_prop, "ui")
      local max = nx_number(common_array:FindChild(array_prop, "max"))
      local image = common_array:FindChild(array_prop, "image")
      local gb_item = create_ctrl("GroupBox", "gb_item_" .. nx_string(i) .. "_" .. nx_string(j), gb_mod, gb_group_2)
      gb_item.Left = 0
      gb_item.Top = j * gb_item.Height
      gb_item.prop = prop
      gb_item.max = max
      local lbl_ui = create_ctrl("Label", "lbl_ui_" .. nx_string(i) .. "_" .. nx_string(j), lbl_mod_ui, gb_item)
      local lbl_value = create_ctrl("Label", "lbl_value_" .. nx_string(i) .. "_" .. nx_string(j), lbl_mod_value, gb_item)
      local lbl_image = create_ctrl("Label", "lbl_image_" .. nx_string(i) .. "_" .. nx_string(j), lbl_mod_image, gb_item)
      local lbl_bg = create_ctrl("Label", "lbl_bg_" .. nx_string(i) .. "_" .. nx_string(j), lbl_mod_bg, gb_item)
      lbl_ui.Text = nx_widestr(util_text(ui))
      lbl_image.BackImage = image
    end
  end
  form.gsb_1.IsEditMode = false
  form.gsb_1:ResetChildrenYPos()
  add_bind(form)
end
function add_bind(form)
  local common_array = nx_value("common_array")
  local databinder = nx_value("data_binder")
  for i = 0, form.sec_count - 1 do
    local array_sec = get_array_name_sec(i)
    local sec = common_array:FindChild(array_sec, "sec")
    local item_count = nx_number(common_array:FindChild(array_sec, "item_count"))
    for j = 0, item_count - 1 do
      local array_prop = get_array_name_prop(i, j)
      local prop = common_array:FindChild(array_prop, "prop")
      databinder:AddRolePropertyBind(prop, "int", form, FORM_NAME, "on_prop_changed")
    end
  end
end
function del_bind(form)
  local common_array = nx_value("common_array")
  local databinder = nx_value("data_binder")
  for i = 0, form.sec_count - 1 do
    local array_sec = get_array_name_sec(i)
    local sec = common_array:FindChild(array_sec, "sec")
    local item_count = nx_number(common_array:FindChild(array_sec, "item_count"))
    for j = 0, item_count - 1 do
      local array_prop = get_array_name_prop(i, j)
      local prop = common_array:FindChild(array_prop, "prop")
      databinder:DelRolePropertyBind(prop, form)
    end
  end
end
function on_cbtn_group_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    cbtn.gb_parent.Height = cbtn.gb_1.Height + cbtn.gb_2.Height
    form.gsb_1:ResetChildrenYPos()
  else
    cbtn.gb_parent.Height = cbtn.gb_1.Height
    form.gsb_1:ResetChildrenYPos()
  end
end
function on_prop_changed(form, ...)
  local prop = arg[1]
  local value = nx_number(arg[3])
  local common_array = nx_value("common_array")
  for i = 0, form.sec_count - 1 do
    local array_sec = get_array_name_sec(i)
    local sec = common_array:FindChild(array_sec, "sec")
    local item_count = nx_number(common_array:FindChild(array_sec, "item_count"))
    local gb_group = form.gsb_1:Find("gb_group_" .. nx_string(i))
    local gb_group_2 = gb_group:Find("gb_group_2_" .. nx_string(i))
    for j = 0, item_count - 1 do
      local gb_item = gb_group_2:Find("gb_item_" .. nx_string(i) .. "_" .. nx_string(j))
      if gb_item.prop == prop then
        local lbl_value = gb_item:Find("lbl_value_" .. nx_string(i) .. "_" .. nx_string(j))
        local max = gb_item.max
        lbl_value.Text = nx_widestr(get_prop_value_text(prop, value, max))
        return
      end
    end
  end
end
function get_prop_value_text(prop, cur, max)
  if 0 < max then
    return nx_string(cur) .. nx_string("/") .. nx_string(max)
  end
  local prop_max = get_ini_prop_maxvalue(prop)
  if prop_max ~= nil and 0 < prop_max then
    return nx_string(cur) .. nx_string("/") .. nx_string(prop_max)
  end
  return nx_string(cur)
end
function get_array_name_sec(sec_index)
  return ARRAY_NAME_SEC .. nx_string(sec_index)
end
function get_array_name_prop(sec_index, item_index)
  return ARRAY_NAME_PROP .. nx_string(sec_index) .. "_" .. nx_string(item_index)
end
function get_ini_prop_maxvalue(prop)
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\common_inc_prop_value\\PropIncEffect.ini")
  if not nx_is_valid(ini) then
    return
  end
  if not ini:FindSection(nx_string(prop)) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(prop))
  if sec_index < 0 then
    return
  end
  return ini:ReadInteger(sec_index, "max_value", 0)
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function a(b)
  nx_msgbox(nx_string(b))
end
