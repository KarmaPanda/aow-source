require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
local ARRAY_NAME = "COMMON_ARRAY_HOME_BUILDING_HIRE_ALL_INFO_"
local FORM_BUILDING_HIRE_ALL_INFO = "form_stage_main\\form_home\\form_building_hire_all_info"
local hire_head_old = {
  HomeComNpc001 = "gui\\special\\home\\guyong\\btn_gy1_on.png",
  HomeComNpc002 = "gui\\special\\home\\guyong\\btn_gy1_on.png",
  HomeComNpc003 = "gui\\special\\home\\guyong\\btn_gy1_on.png",
  HomecleanNpc001 = "gui\\special\\home\\guyong\\btn_gy3_on.png",
  HomecleanNpc002 = "gui\\special\\home\\guyong\\btn_gy3_on.png",
  HomecleanNpc003 = "gui\\special\\home\\guyong\\btn_gy3_on.png",
  HomeShowNpc001 = "gui\\special\\home\\guyong\\btn_gy2_on.png",
  HomeShowNpc002 = "gui\\special\\home\\guyong\\btn_gy2_on.png",
  HomeShowNpc003 = "gui\\special\\home\\guyong\\btn_gy2_on.png"
}
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  load_ini(form)
  client_to_server_msg(CLIENT_SUB_GET_HIRE_ALL_INFO)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE_ALL_INFO, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE_ALL_INFO, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
end
function test()
  update_info(4, "HomeComNpc001", 1, 1000, "HomecleanNpc003", 1, 1000, "HomeShowNpc003", 1, 1000, "npc_homeemploy_001", 1, 1000)
end
function update_info(...)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE_ALL_INFO, false, false)
  if not nx_is_valid(form) then
    return
  end
  local info_count = arg[1]
  local tab_npc = {}
  form.gsb_1.IsEditMode = true
  form.gsb_1:DeleteAll()
  for i = 1, nx_number(info_count) do
    local npc_id = arg[2 + (i - 1) * 3]
    local value_cur = arg[2 + (i - 1) * 3 + 1]
    local left_time = arg[2 + (i - 1) * 3 + 2]
    local hire_type = common_array:FindChild(nx_string(get_array_name(npc_id)), "hire_type")
    if hire_type == nil then
      create_sub(form, npc_id, value_cur, left_time)
    else
      table.insert(tab_npc, {
        npc_id,
        value_cur,
        left_time
      })
    end
  end
  table.sort(tab_npc, function(a, b)
    return a[3] > b[3] or a[3] == b[3] and a[2] > b[2]
  end)
  for i = 1, table.getn(tab_npc) do
    local npc_id = tab_npc[i][1]
    local value_cur = tab_npc[i][2]
    local left_time = tab_npc[i][3]
    create_sub(form, npc_id, value_cur, left_time)
  end
  form.gsb_1.IsEditMode = false
  form.gsb_1:ResetChildrenYPos()
end
function create_sub(form, npc_id, value_cur, left_time)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local gb_npc = create_ctrl("GroupBox", "gb_npc_" .. nx_string(npc_id), form.gb_model, form.gsb_1)
  if nx_is_valid(gb_npc) then
    local lbl_name = create_ctrl("Label", "lbl_name_" .. nx_string(npc_id), form.lbl_name, gb_npc)
    local lbl_pos = create_ctrl("Label", "lbl_pos_" .. nx_string(npc_id), form.lbl_pos, gb_npc)
    local lbl_friend = create_ctrl("Label", "lbl_friend_" .. nx_string(npc_id), form.lbl_friend, gb_npc)
    local lbl_left_time = create_ctrl("Label", "lbl_left_time_" .. nx_string(npc_id), form.lbl_left_time, gb_npc)
    local lbl_effect = create_ctrl("Label", "lbl_effect_" .. nx_string(npc_id), form.lbl_effect, gb_npc)
    local lbl_hiring = create_ctrl("Label", "lbl_hiring_" .. nx_string(npc_id), form.lbl_hiring, gb_npc)
    local lbl_head = create_ctrl("Label", "lbl_head_" .. nx_string(npc_id), form.lbl_head, gb_npc)
    local pos_ui = common_array:FindChild(nx_string(get_array_name(npc_id)), "pos_ui")
    if pos_ui == nil then
      lbl_pos.Text = nx_widestr(util_text("ui_old_hire_pos_" .. nx_string(npc_id)))
      lbl_effect.Text = nx_widestr(util_text("ui_old_hire_effect_" .. nx_string(npc_id)))
      lbl_head.BackImage = nx_string(hire_head_old[nx_string(npc_id)])
    else
      lbl_pos.Text = nx_widestr(util_text(pos_ui))
      local gain_type = common_array:FindChild(nx_string(get_array_name(npc_id)), "gain_type")
      local gain_para = common_array:FindChild(nx_string(get_array_name(npc_id)), "gain_para")
      lbl_effect.Text = nx_widestr(util_format_string("ui_type_" .. nx_string(gain_type), nx_int(gain_para)))
      lbl_head.BackImage = nx_string(common_array:FindChild(nx_string(get_array_name(npc_id)), "image"))
    end
    lbl_name.Text = nx_widestr(util_text(npc_id))
    lbl_friend.Text = nx_widestr(value_cur)
    lbl_left_time.Text = get_time_text(left_time)
    if nx_int(left_time) > nx_int(0) then
      lbl_hiring.Visible = true
    else
      lbl_hiring.Visible = false
    end
    gb_npc.Left = 0
  end
end
function load_ini(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeBuilding\\Friends.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:GetSectionCount()
  for i = 0, sec_count - 1 do
    local sec = ini:GetSectionByIndex(i)
    local array_name = get_array_name(sec)
    common_array:RemoveArray(array_name)
    common_array:AddArray(array_name, form, 600, true)
    local hire_type = ini:ReadInteger(i, "hire_type", 0)
    local gain_type = ini:ReadInteger(i, "gain_type", 0)
    local gain_para = ini:ReadInteger(i, "gain_para", 0)
    local max = ini:ReadInteger(i, "max", 0)
    local pos_ui = ini:ReadString(i, "pos_ui", "")
    local image = ini:ReadString(i, "image", "")
    common_array:AddChild(array_name, "hire_type", nx_int(hire_type))
    common_array:AddChild(array_name, "gain_type", nx_int(gain_type))
    common_array:AddChild(array_name, "gain_para", nx_int(gain_para))
    common_array:AddChild(array_name, "max", nx_int(max))
    common_array:AddChild(array_name, "pos_ui", nx_string(pos_ui))
    common_array:AddChild(array_name, "image", nx_string(image))
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
function get_array_name(npc_id)
  return ARRAY_NAME .. nx_string(npc_id)
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
function a(str)
  nx_msgbox(nx_string(str))
end
