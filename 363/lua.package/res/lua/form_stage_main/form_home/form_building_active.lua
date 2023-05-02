require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("share\\view_define")
local FORM_BUILDING_ACTIVE = "form_stage_main\\form_home\\form_building_active"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  resize_form(form)
  form.building_id = nil
end
function resize_form(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.groupbox_1.Height = form.Height
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  client_to_server_msg(CLIENT_SUB_BUILDING_ACTIVE, nx_string(form.building_id))
end
function on_ig_item_mousein_grid(ig, index)
  nx_execute("tips_game", "show_tips_by_config", ig.config, ig:GetMouseInItemLeft(), ig:GetMouseInItemTop(), ig)
end
function on_ig_item_mouseout_grid(ig)
  nx_execute("tips_game", "hide_tip")
end
function open_form_active(building_id, is_no_item)
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_ACTIVE, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  form.building_id = building_id
  form.is_no_item = is_no_item
  local building_id_end = string.sub(nx_string(form.building_id), string.len(nx_string(form.building_id)), string.len(nx_string(form.building_id)))
  local suffix = nx_string(form.building_id)
  if nx_number(building_id_end) >= 1 and nx_number(building_id_end) <= 9 then
    suffix = string.sub(nx_string(form.building_id), 1, string.len(nx_string(form.building_id)) - 1)
  end
  form.lbl_title.Text = nx_widestr(util_text("ui_home_building_active_title_" .. suffix))
  form.mltbox_tips:Clear()
  form.mltbox_tips:AddHtmlText(nx_widestr(util_text("ui_home_building_active_tips_" .. suffix)), -1)
  form.lbl_jh_bg_picture.BackImage = nx_string("gui\\special\\home\\home_jianzhu\\" .. suffix .. ".png")
  if nx_int(form.is_no_item) == nx_int(1) then
    return
  end
  form.gsb_item.IsEditMode = true
  form.gsb_item:DeleteAll()
  local ini = get_ini("share\\Home\\HomeBuilding.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(form.building_id))
  if sec_index < 0 then
    return
  end
  local str_item = ini:ReadString(sec_index, "item", "")
  local item_list = util_split_string(nx_string(str_item), ";")
  for i = 1, table.getn(item_list) do
    local item = util_split_string(nx_string(item_list[i]), ",")
    local config = nx_string(item[1])
    local count = nx_string(item[2])
    if nx_string(config) ~= nx_string(nil) then
      local gb_item = create_ctrl("GroupBox", "groupbox_item_" .. nx_string(i), form.gb_model, form.gsb_item)
      if nx_is_valid(gb_item) then
        gb_item.config = config
        gb_item.count = count
        local ig_item = create_ctrl("ImageGrid", "ig_item_" .. nx_string(i), form.ig_item, gb_item)
        nx_bind_script(ig_item, nx_current())
        nx_callback(ig_item, "on_mousein_grid", "on_ig_item_mousein_grid")
        nx_callback(ig_item, "on_mouseout_grid", "on_ig_item_mouseout_grid")
        ig_item.config = config
        ig_item:Clear()
        photo = nx_string(ItemQuery:GetItemPropByConfigID(gb_item.config, "Photo"))
        ig_item:AddItem(0, photo, nx_widestr(gb_item.config), 1, -1)
        local lbl_name = create_ctrl("Label", "lbl_name_" .. nx_string(i), form.lbl_name, gb_item)
        local multibox_count = create_ctrl("MultiTextBox", "multibox_count_" .. nx_string(i), form.mltbox_count, gb_item)
        lbl_name.Text = nx_widestr(util_text(gb_item.config))
        local cur_count = Get_Material_Num(gb_item.config, VIEWPORT_MATERIAL_TOOL) + Get_Material_Num(gb_item.config, VIEWPORT_TOOL)
        multibox_count:Clear()
        if nx_int(cur_count) >= nx_int(gb_item.count) then
          multibox_count:AddHtmlText(nx_widestr("<font color=\"#00ff00\">" .. nx_string(cur_count) .. "/" .. nx_string(gb_item.count) .. "</font>"), -1)
        else
          multibox_count:AddHtmlText(nx_widestr("<font color=\"#ff0000\">" .. nx_string(cur_count) .. "/" .. nx_string(gb_item.count) .. "</font>"), -1)
        end
        gb_item.Left = 0 + gb_item.Width * math.fmod(i - 1, 4)
        gb_item.Top = 0 + gb_item.Height * math.floor((i - 1) / 4)
      end
    end
  end
  local old_height = form.gsb_item.Height
  if 0 < table.getn(item_list) then
    form.gsb_item.Height = 0 + form.gb_model.Height * (math.floor((table.getn(item_list) - 1) / 4) + 1)
  else
    form.gsb_item.Height = 0
  end
  form.Height = form.Height - old_height + form.gsb_item.Height
  form.gsb_item.IsEditMode = false
  resize_form(form)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_ACTIVE, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
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
function Get_Material_Num(item, viewID)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(viewID))
  if not nx_is_valid(view) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  local count = view:GetViewObjCount()
  for j = 1, count do
    local obj = view:GetViewObjByIndex(j - 1)
    local tempid = obj:QueryProp("ConfigID")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item)) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
    end
  end
  return nx_int(cur_amount)
end
