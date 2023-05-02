require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("share\\view_define")
local ARRAY_NAME = "COMMON_ARRAY_HOME_BUILDING_LEVELUP_"
local FORM_BUILDING_LEVELUP = "form_stage_main\\form_home\\form_building_levelup"
local NUMS_PER_LINE = 3
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  resize_form(form)
  form.building_id = nil
  load_ini(form)
end
function resize_form(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.groupbox_2.Height = form.Height
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_levelup_click(btn)
  local form = btn.ParentForm
  client_to_server_msg(CLIENT_SUB_BUILDING_LEVELUP, nx_string(form.building_id))
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_LEVELUP, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form(building_id)
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_LEVELUP, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.building_id = building_id
  client_to_server_msg(CLIENT_SUB_GET_LEVEL_INFO, nx_string(form.building_id))
end
function update_info(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_LEVELUP, false, false)
  if not nx_is_valid(form) then
    return
  end
  local level_cur = nx_int(arg[1])
  local level_max = nx_int(arg[2])
  form.mltbox_cur:Clear()
  form.mltbox_cur:AddHtmlText(nx_widestr(util_text("level_info_" .. nx_string(form.building_id) .. "_" .. nx_string(level_cur))), -1)
  form.mltbox_next:Clear()
  if level_cur == level_max then
    form.btn_levelup.Enabled = false
    form.btn_levelup.Text = nx_widestr(util_text("home_building_level_max"))
    return
  end
  form.mltbox_next:AddHtmlText(nx_widestr(util_text("level_info_" .. nx_string(form.building_id) .. "_" .. nx_string(level_cur + 1))), -1)
  show_level_info(form, level_cur)
end
function show_level_info(form, level_cur)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local levelup_item = common_array:FindChild(get_array_name(form.building_id), "levelup_item")
  local levelup_point = common_array:FindChild(get_array_name(form.building_id), "levelup_point")
  local levelup_point_list = util_split_string(levelup_point, ",")
  if nx_number(level_cur) <= table.getn(levelup_point_list) then
    form.lbl_res.Text = nx_widestr(levelup_point_list[nx_number(level_cur)])
  end
  local item_count = 0
  form.gsb_item.IsEditMode = true
  form.gsb_item:DeleteAll()
  local item_list = util_split_string(levelup_item, ";")
  if table.getn(item_list) >= nx_number(level_cur) and nx_number(level_cur) > 0 then
    local item_str = item_list[nx_number(level_cur)]
    local var_item = util_split_string(item_str, ",")
    for i = 1, table.getn(var_item), 2 do
      local config = nx_string(var_item[i])
      local count = nx_int(var_item[i + 1])
      item_count = item_count + 1
      if nx_string(config) ~= nx_string(nil) then
        local gb_item = create_ctrl("GroupBox", "gb_item_" .. nx_string(config), form.gb_model, form.gsb_item)
        if nx_is_valid(gb_item) then
          gb_item.config = config
          gb_item.count = count
          local ig_item = create_ctrl("ImageGrid", "ig_item_" .. nx_string(config), form.ig_item, gb_item)
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
          gb_item.Left = 0 + gb_item.Width * math.fmod((i + 1) / 2 - 1, NUMS_PER_LINE)
          gb_item.Top = 0 + gb_item.Height * math.floor(((i + 1) / 2 - 1) / NUMS_PER_LINE)
        end
      end
    end
  end
  local old_height = form.gsb_item.Height
  if table.getn(item_list) > 0 then
    form.gsb_item.Height = 0 + form.gb_model.Height * (math.floor((table.getn(item_list) - 1) / NUMS_PER_LINE) + 1)
  else
    form.gsb_item.Height = 0
  end
  form.Height = form.Height - old_height + form.gsb_item.Height
  form.gsb_item.IsEditMode = false
  resize_form(form)
end
function load_ini(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeBuilding.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:GetSectionCount()
  for i = 0, sec_count - 1 do
    local sec = ini:GetSectionByIndex(i)
    local array_name = get_array_name(sec)
    common_array:RemoveArray(array_name)
    common_array:AddArray(array_name, form, 600, true)
    local levelup_item = ini:ReadString(i, "levelup_item", "")
    local levelup_point = ini:ReadString(i, "levelup_point", "")
    common_array:AddChild(array_name, "levelup_item", nx_string(levelup_item))
    common_array:AddChild(array_name, "levelup_point", nx_string(levelup_point))
  end
end
function get_array_name(npc_id)
  return ARRAY_NAME .. nx_string(npc_id)
end
function on_ig_item_mousein_grid(ig, index)
  nx_execute("tips_game", "show_tips_by_config", ig.config, ig:GetMouseInItemLeft(), ig:GetMouseInItemTop(), ig)
end
function on_ig_item_mouseout_grid(ig)
  nx_execute("tips_game", "hide_tip")
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
function a(str)
  nx_msgbox(nx_string(str))
end
