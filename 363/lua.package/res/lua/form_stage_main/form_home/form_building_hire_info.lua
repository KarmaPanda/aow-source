require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("share\\view_define")
local ARRAY_NAME_BUILDING = "COMMON_ARRAY_HOME_BUILDING_HIRE_INFO_BUILDING"
local ARRAY_NAME = "COMMON_ARRAY_HOME_BUILDING_HIRE_INFO_"
local FORM_BUILDING_HIRE_INFO = "form_stage_main\\form_home\\form_building_hire_info"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE_INFO, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form(building_id)
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE_INFO, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.building_id = building_id
  load_ini(form)
  client_to_server_msg(CLIENT_SUB_GET_HIRE_MORE_INFO, nx_string(form.building_id))
end
function update_info(...)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE_INFO, false, false)
  if not nx_is_valid(form) then
    return
  end
  local building_id = arg[1]
  local hire_count = arg[2]
  local arg_index = 2
  local tab_hire = {}
  local tab_friend = {}
  form.gsb_1.IsEditMode = true
  form.gsb_1:DeleteAll()
  for i = 1, nx_number(hire_count) do
    local npc_id = nx_string(arg[arg_index + 1])
    local value_cur = nx_int(arg[arg_index + 2])
    local left_time = nx_int(arg[arg_index + 3])
    arg_index = arg_index + 3
    table.insert(tab_hire, {
      npc_id,
      value_cur,
      left_time
    })
  end
  table.sort(tab_hire, function(a, b)
    return a[2] > b[2]
  end)
  for i = 1, table.getn(tab_hire) do
    local npc_id = tab_hire[i][1]
    local value_cur = tab_hire[i][2]
    local left_time = tab_hire[i][3]
    create_sub(form, npc_id, value_cur, left_time)
  end
  local friend_count = arg[arg_index + 1]
  arg_index = arg_index + 1
  for i = 1, nx_number(friend_count) do
    local npc_id = nx_string(arg[arg_index + 1])
    local value_cur = nx_int(arg[arg_index + 2])
    arg_index = arg_index + 2
    table.insert(tab_friend, {npc_id, value_cur})
  end
  table.sort(tab_friend, function(a, b)
    return a[2] > b[2]
  end)
  for i = 1, table.getn(tab_friend) do
    local npc_id = tab_friend[i][1]
    local value_cur = tab_friend[i][2]
    create_sub(form, npc_id, value_cur, 0)
  end
  local friend_npc = common_array:FindChild(ARRAY_NAME_BUILDING, "friend_npc")
  local friend_npc_list = util_split_string(friend_npc, ",")
  for i = 1, table.getn(friend_npc_list) do
    local npc_id = friend_npc_list[i]
    if not is_in_tab(tab_hire, npc_id) and not is_in_tab(tab_friend, npc_id) then
      local hire_type = common_array:FindChild(nx_string(get_array_name(npc_id)), "hire_type")
      if hire_type == 2 then
        create_sub(form, npc_id, 0, 0)
      end
    end
  end
  form.gsb_1.IsEditMode = false
  form.gsb_1:ResetChildrenYPos()
end
function create_sub(form, npc_id, value_cur, left_time)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local gb_npc = create_ctrl("GroupBox", "gb_item_" .. nx_string(npc_id), form.gb_model, form.gsb_1)
  if nx_is_valid(gb_npc) then
    local lbl_name = create_ctrl("Label", "lbl_name_" .. nx_string(npc_id), form.lbl_name, gb_npc)
    local lbl_pos = create_ctrl("Label", "lbl_pos_" .. nx_string(npc_id), form.lbl_pos, gb_npc)
    local lbl_friend = create_ctrl("Label", "lbl_friend_" .. nx_string(npc_id), form.lbl_friend, gb_npc)
    local lbl_left_time = create_ctrl("Label", "lbl_left_time_" .. nx_string(npc_id), form.lbl_left_time, gb_npc)
    local lbl_effect = create_ctrl("Label", "lbl_effect_" .. nx_string(npc_id), form.lbl_effect, gb_npc)
    local lbl_hiring = create_ctrl("Label", "lbl_hiring_" .. nx_string(npc_id), form.lbl_hiring, gb_npc)
    local lbl_head = create_ctrl("Label", "lbl_head_" .. nx_string(npc_id), form.lbl_head, gb_npc)
    local btn_hire = create_ctrl("Button", "btn_hire_" .. nx_string(npc_id), form.btn_hire, gb_npc)
    btn_hire.npc_id = npc_id
    nx_bind_script(btn_hire, nx_current())
    nx_callback(btn_hire, "on_click", "on_btn_hire_click")
    lbl_name.Text = nx_widestr(util_text(npc_id))
    lbl_pos.Text = nx_widestr(util_text(common_array:FindChild(nx_string(get_array_name(npc_id)), "pos_ui")))
    lbl_friend.Text = nx_widestr(value_cur)
    lbl_left_time.Text = get_time_text(left_time)
    local gain_type = common_array:FindChild(nx_string(get_array_name(npc_id)), "gain_type")
    local gain_para = common_array:FindChild(nx_string(get_array_name(npc_id)), "gain_para")
    lbl_effect.Text = nx_widestr(util_format_string("ui_type_" .. nx_string(gain_type), nx_int(gain_para)))
    if nx_int(left_time) > nx_int(0) then
      lbl_hiring.Visible = true
      btn_hire.Visible = false
    else
      lbl_hiring.Visible = false
      btn_hire.Visible = true
      local hire_item = nx_string(common_array:FindChild(nx_string(get_array_name(npc_id)), "hire_item"))
      local item_count = Get_Material_Num(hire_item, VIEWPORT_TASK_TOOL)
      if nx_int(item_count) > nx_int(0) then
        btn_hire.Enabled = true
      else
        btn_hire.Enabled = false
      end
    end
    lbl_head.BackImage = nx_string(common_array:FindChild(nx_string(get_array_name(npc_id)), "image"))
    gb_npc.Left = 0
  end
end
function is_in_tab(tab, child)
  for i = 1, table.getn(tab) do
    if nx_string(child) == nx_string(tab[i][1]) then
      return true
    end
  end
  return false
end
function on_btn_hire_click(btn)
  local form = btn.ParentForm
  client_to_server_msg(CLIENT_SUB_BUILDING_HIRE, nx_string(form.building_id), nx_string(btn.npc_id), nx_int(0))
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
  local sec_index = ini:FindSectionIndex(nx_string(form.building_id))
  if sec_index < 0 then
    return
  end
  common_array:RemoveArray(ARRAY_NAME_BUILDING)
  common_array:AddArray(ARRAY_NAME_BUILDING, form, 600, true)
  local friend_npc = ini:ReadString(sec_index, "friend_npc", "")
  common_array:AddChild(ARRAY_NAME_BUILDING, "friend_npc", nx_string(friend_npc))
  ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeBuilding\\Friends.ini")
  if not nx_is_valid(ini) then
    return
  end
  local friend_npc_list = util_split_string(friend_npc, ",")
  for i = 1, table.getn(friend_npc_list) do
    local sec_index = ini:FindSectionIndex(nx_string(friend_npc_list[i]))
    if 0 <= sec_index then
      local array_name = get_array_name(friend_npc_list[i])
      common_array:RemoveArray(array_name)
      common_array:AddArray(array_name, form, 600, true)
      local hire_type = ini:ReadInteger(i, "hire_type", 0)
      local max = ini:ReadInteger(i, "max", 0)
      local gain_type = ini:ReadInteger(i, "gain_type", 0)
      local gain_para = ini:ReadInteger(i, "gain_para", 0)
      local pos_ui = ini:ReadString(i, "pos_ui", "")
      local hire_item = ini:ReadString(i, "hire_item", "")
      local image = ini:ReadString(i, "image", "")
      common_array:AddChild(array_name, "hire_type", nx_int(hire_type))
      common_array:AddChild(array_name, "max", nx_int(max))
      common_array:AddChild(array_name, "gain_type", nx_int(gain_type))
      common_array:AddChild(array_name, "gain_para", nx_int(gain_para))
      common_array:AddChild(array_name, "pos_ui", nx_string(pos_ui))
      common_array:AddChild(array_name, "hire_item", nx_string(hire_item))
      common_array:AddChild(array_name, "image", nx_string(image))
    end
  end
end
function get_time_text(seconds)
  local time_hour = nx_int(seconds / 3600)
  local time_text = nx_widestr(util_text("ui_home_left_time_1"))
  if nx_number(time_hour) > 0 then
    time_text = nx_widestr(util_format_string("ui_home_left_time_2", nx_int(time_hour)))
  end
  return time_text
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
function get_array_name(npc_id)
  return ARRAY_NAME .. nx_string(npc_id)
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
