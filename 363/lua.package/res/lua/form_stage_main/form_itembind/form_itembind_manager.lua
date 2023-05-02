require("share\\view_define")
require("util_static_data")
local BS_UnBind = 0
local BS_Bind = 1
local BT_NotNeedBind = 0
local BT_EntryToolBind = 1
local BT_EntryEquipBind = 2
local BT_UseBind = 3
local forms_table_pickup = {}
local forms_table_equip = {}
local forms_table_use = {}
local show_pickup_index = 1
local pickup_index_table = {}
function init_form_itembind_manager()
  delete_all_form_itembind_pickup()
  delete_all_form_itembind_equip()
  delete_all_form_itembind_use()
end
function get_form_itembind_pickup(index)
  index = tonumber(index)
  local form = nx_null()
  local table_index = find_form_itembind_index(VIEWPORT_DROP_BOX, index)
  if table_index ~= 0 then
    form = forms_table_pickup[table_index]
    if not nx_is_valid(form) or 0 >= form.left_time then
    end
    return form
  else
    form = create_form_itembind(VIEWPORT_DROP_BOX, index)
    if nx_is_valid(form) then
    end
    return form
  end
end
function get_form_itembind_equip(index, equip_grid, src_viewid)
  index = tonumber(index)
  local form = nx_null()
  local table_index = find_form_itembind_index(VIEWPORT_EQUIP, index)
  if table_index ~= 0 then
    form = forms_table_equip[table_index]
    if nx_is_valid(form) then
      form.equip_grid = equip_grid
      form.src_viewid = src_viewid
      if 0 >= form.left_time then
        form:Show()
      end
    end
    return form
  else
    form = create_form_itembind(VIEWPORT_EQUIP, index)
    if nx_is_valid(form) then
      form.equip_grid = equip_grid
      form.src_viewid = src_viewid
      form:Show()
    end
    return form
  end
end
function get_form_itembind_use(index)
  index = tonumber(index)
  local form = nx_null()
  local table_index = find_form_itembind_index(VIEWPORT_TOOL, index)
  if table_index ~= 0 then
    form = forms_table_use[table_index]
    if nx_is_valid(form) and 0 >= form.left_time then
      form:Show()
    end
    return form
  else
    form = create_form_itembind(VIEWPORT_TOOL, index)
    if nx_is_valid(form) then
      form:Show()
    end
    return form
  end
end
function find_form_itembind_index(viewid, index)
  local forms_table = {}
  if nx_int(viewid) == nx_int(VIEWPORT_DROP_BOX) then
    forms_table = forms_table_pickup
  elseif nx_int(viewid) == nx_int(VIEWPORT_EQUIP) then
    forms_table = forms_table_equip
  elseif nx_int(viewid) == nx_int(VIEWPORT_TOOL) then
    forms_table = forms_table_use
  else
    return 0
  end
  local ret_index = 0
  for count = 1, table.getn(forms_table) do
    if nx_is_valid(forms_table[count]) and nx_int(forms_table[count].item_index) == nx_int(index) then
      ret_index = count
      break
    end
  end
  return ret_index
end
function create_form_itembind(viewid, index)
  if nx_int(index) < nx_int(0) then
    return nx_null()
  end
  local form = nx_null()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) or not nx_is_valid(gui.Loader) then
    return nx_null()
  end
  local file_path = ""
  if nx_int(viewid) == nx_int(VIEWPORT_DROP_BOX) then
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
    local item_obj = view:GetViewObj(nx_string(index))
    file_path = "form_stage_main\\form_itembind\\form_itembind_pickup.xml"
    form = nx_call("util_gui", "util_get_form", "form_stage_main\\form_itembind\\form_itembind_pickup", true, true)
    if nx_is_valid(form) then
      form.lbl_info.Text = nx_widestr(item_obj:QueryProp("ConfigID"))
      form.view_id = VIEWPORT_DROP_BOX
      form.item_index = index
      table.insert(forms_table_pickup, form)
    end
  elseif nx_int(viewid) == nx_int(VIEWPORT_EQUIP) then
    file_path = "form_stage_main\\form_itembind\\form_itembind_equip.xml"
    form = nx_call("util_gui", "util_get_form", "form_stage_main\\form_itembind\\form_itembind_equip", true, true)
    if nx_is_valid(form) then
      form.view_id = VIEWPORT_EQUIP
      form.item_index = index
      table.insert(forms_table_equip, form)
    end
  elseif nx_int(viewid) == nx_int(VIEWPORT_TOOL) then
    file_path = "form_stage_main\\form_itembind\\form_itembind_use.xml"
    form = nx_call("util_gui", "util_get_form", "form_stage_main\\form_itembind\\form_itembind_use", true, true)
    if nx_is_valid(form) then
      form.view_id = VIEWPORT_TOOL
      form.item_index = index
      table.insert(forms_table_use, form)
    end
  else
    return nx_null()
  end
  return form
end
function delete_form_itembind_pickup(index)
  local table_index = find_form_itembind_index(VIEWPORT_DROP_BOX, index)
  if table_index == 0 then
    return
  end
  local form = forms_table_pickup[table_index]
  table.remove(forms_table_pickup, table_index)
  if nx_is_valid(form) then
    form:Close()
    nx_destroy(form)
  end
end
function delete_form_itembind_equip(index)
  local table_index = find_form_itembind_index(VIEWPORT_EQUIP, index)
  if table_index == 0 then
    return
  end
  local form = forms_table_equip[table_index]
  table.remove(forms_table_equip, table_index)
  if nx_is_valid(form) then
    form:Close()
    nx_destroy(form)
  end
end
function delete_form_itembind_use(index)
  local table_index = find_form_itembind_index(VIEWPORT_TOOL, index)
  if table_index == 0 then
    return
  end
  local form = forms_table_use[table_index]
  table.remove(forms_table_use, table_index)
  if nx_is_valid(form) then
    form:Close()
    nx_destroy(form)
  end
end
function delete_all_form_itembind_pickup()
  for count = 1, table.getn(forms_table_pickup) do
    local form = forms_table_pickup[count]
    if nx_is_valid(form) then
      form:Close()
      nx_destroy(form)
    end
  end
  forms_table_pickup = {}
end
function delete_all_form_itembind_equip()
  for count = 1, table.getn(forms_table_equip) do
    local form = forms_table_equip[count]
    if nx_is_valid(form) then
      form:Close()
      nx_destroy(form)
    end
  end
  forms_table_equip = {}
end
function delete_all_form_itembind_use()
  for count = 1, table.getn(forms_table_use) do
    local form = forms_table_use[count]
    if nx_is_valid(form) then
      form:Close()
      nx_destroy(form)
    end
  end
  forms_table_use = {}
end
function manager_tick()
  local form = nx_null()
  while true do
    local step_time = nx_pause(0.5)
    for count = 1, table.getn(forms_table_pickup) do
      form = forms_table_pickup[count]
      if nx_is_valid(form) then
        form.left_time = form.left_time - step_time
        if form.left_time <= 0 then
          form:Close()
        end
      end
    end
    for count = 1, table.getn(forms_table_equip) do
      form = forms_table_equip[count]
      if nx_is_valid(form) then
        form.left_time = form.left_time - step_time
        if form.left_time <= 0 then
          form:Close()
        end
      end
    end
    for count = 1, table.getn(forms_table_use) do
      form = forms_table_use[count]
      if nx_is_valid(form) then
        form.left_time = form.left_time - step_time
        if form.left_time <= 0 then
          form:Close()
        end
      end
    end
  end
end
function drop_itemobj_need_bind(index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_DROP_BOX))
  if not nx_is_valid(view) then
    return false
  end
  local item_obj = view:GetViewObj(nx_string(index))
  return item_need_bind(item_obj, BT_EntryToolBind)
end
function equip_itemobj_need_bind(view_id, view_index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return false
  end
  local item_obj = view:GetViewObj(nx_string(view_index))
  return item_need_bind(item_obj, BT_EntryEquipBind)
end
function use_itemobj_need_bind(view_id, view_index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return false
  end
  local item_obj = view:GetViewObj(nx_string(view_index))
  return item_need_bind(item_obj, BT_UseBind)
end
function item_need_bind(item_obj, bind)
  if not nx_is_valid(item_obj) then
    return false
  end
  local static_data = item_obj:QueryProp("LogicPack")
  local bind_type = item_static_query(static_data, "BindType", STATIC_DATA_ITEM_LOGIC)
  local bind_status = item_obj:QueryProp("BindStatus")
  if nx_int(bind_status) == nx_int(BS_Bind) then
    return false
  end
  if nx_int(bind_type) == nx_int(bind) then
    return true
  end
  return false
end
function equip_form_nocapture_close()
  for count = 1, table.getn(forms_table_equip) do
    local form = forms_table_equip[count]
    if nx_is_valid(form) and not form.Capture then
      form:Close()
    end
  end
end
function clear_pickup_index_table()
  pickup_index_table = {}
end
function add_pickup_index_table(index)
  index = tonumber(index)
  table.insert(pickup_index_table, index)
end
function remove_pickup_index_table(index)
  index = tonumber(index)
  local remove_id = 0
  for count = 1, table.getn(pickup_index_table) do
    if pickup_index_table[count] == index then
      remove_id = count
      break
    end
  end
  if remove_id ~= 0 then
    table.remove(pickup_index_table, remove_id)
  end
end
function show_pickup_form_first()
  show_pickup_index = 1
  local gui = nx_value("gui")
  local index = pickup_index_table[show_pickup_index]
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_itembind\\form_itembind_pickup", true)
  if nx_is_valid(form) then
    form.view_id = VIEWPORT_DROP_BOX
    form.item_index = index
    form.AbsLeft = (gui.Width - form.Width) / 2
    form.AbsTop = (gui.Height - form.Height) / 2
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_itembind\\form_itembind_pickup", true)
    gui.Desktop:ToFront(form)
  end
  if nx_is_valid(form) then
    form:Show()
  end
end
function pickup_index_goto_next()
  show_pickup_index = show_pickup_index + 1
end
function show_pickup_form_next()
  if show_pickup_index > table.getn(pickup_index_table) then
    return
  end
  local gui = nx_value("gui")
  local index = pickup_index_table[show_pickup_index]
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_itembind\\form_itembind_pickup", true)
  if nx_is_valid(form) then
    form.view_id = VIEWPORT_DROP_BOX
    form.item_index = index
    form.AbsLeft = (gui.Width - form.Width) / 2
    form.AbsTop = (gui.Height - form.Height) / 2
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_itembind\\form_itembind_pickup", true)
    gui.Desktop:ToFront(form)
  end
  if nx_is_valid(form) then
    form:Show()
  end
end
