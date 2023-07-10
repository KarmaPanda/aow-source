require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
local ARRAY_NAME = "COMMON_ARRAY_HOME_BUILDING_HIRE_"
local FORM_BUILDING_HIRE = "form_stage_main\\form_home\\form_building_hire"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  load_ini(form)
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_execute("form_stage_main\\form_home\\form_building_hire_money", "close_form")
  nx_execute("form_stage_main\\form_home\\form_building_hire_info", "close_form")
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_hire_money_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_home\\form_building_hire_money", "open_form", form.building_id)
end
function on_btn_hire_friend_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_home\\form_building_hire_info", "open_form", form.building_id)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form(building_id)
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.building_id = building_id
  client_to_server_msg(CLIENT_SUB_GET_HIRE_SINGLE_INFO, nx_string(form.building_id))
end
function update_info(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE, false, false)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_building_hire_money", "close_form")
  nx_execute("form_stage_main\\form_home\\form_building_hire_info", "close_form")
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local arg_index = 1
  local building_id = arg[arg_index]
  local count = arg[arg_index + 1]
  arg_index = arg_index + 2
  local tab_gain = {}
  table.insert(tab_gain, "1", 0)
  table.insert(tab_gain, "2", 0)
  table.insert(tab_gain, "3", 0)
  local index_money = 0
  local index_friend = 0
  for i = 1, nx_number(count) do
    local npc_id = arg[arg_index]
    local value_cur = arg[arg_index + 1]
    local left_time = arg[arg_index + 2]
    arg_index = arg_index + 3
    local hire_type = common_array:FindChild(get_array_name(npc_id), "hire_type")
    local gain_type = common_array:FindChild(get_array_name(npc_id), "gain_type")
    local gain_para = common_array:FindChild(get_array_name(npc_id), "gain_para")
    local image = common_array:FindChild(get_array_name(npc_id), "image")
    local lbl, lbl_t
    if nx_int(hire_type) == nx_int(1) then
      index_money = index_money + 1
      lbl = form.gb_1:Find("lbl_hire_money_" .. nx_string(index_money))
      lbl_t = form.gb_1:Find("lbl_hire_money_t" .. nx_string(index_money))
    elseif nx_int(hire_type) == nx_int(2) then
      index_friend = index_friend + 1
      lbl = form.gb_1:Find("lbl_hire_friend_" .. nx_string(index_friend))
      lbl_t = form.gb_1:Find("lbl_hire_friend_t" .. nx_string(index_friend))
    end
    if lbl == nil or lbl_t == nil then
      return
    end
    lbl.BackImage = nx_string(image)
    lbl.HintText = nx_widestr(util_format_string("ui_hint_type_" .. nx_string(gain_type), nx_string(npc_id), nx_int(gain_para)))
    lbl.npc_id = npc_id
    lbl_t.Text = get_time_text(left_time)
    tab_gain[gain_type] = tab_gain[gain_type] + nx_number(gain_para)
  end
  for i = 1, table.getn(tab_gain) do
    local lbl = form.gb_2:Find("lbl_info_" .. nx_string(i))
    if nx_is_valid(lbl) then
      lbl.Text = nx_widestr(util_format_string("ui_type_" .. nx_string(i), tab_gain[i]))
    end
  end
  form.btn_hire_money.Enabled = true
  form.btn_hire_friend.Enabled = true
  if 3 <= index_money then
    form.btn_hire_money.Enabled = false
  end
  if 3 <= index_friend then
    form.btn_hire_friend.Enabled = false
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
    local image = ini:ReadString(i, "image", "")
    common_array:AddChild(array_name, "hire_type", nx_int(hire_type))
    common_array:AddChild(array_name, "gain_type", nx_int(gain_type))
    common_array:AddChild(array_name, "gain_para", nx_int(gain_para))
    common_array:AddChild(array_name, "image", nx_string(image))
  end
end
function is_be_hired(npc_id)
  local form = nx_execute("util_gui", "util_get_form", FORM_BUILDING_HIRE, false, false)
  if not nx_is_valid(form) then
    return false
  end
  for i = 1, 3 do
    lbl = form.gb_1:Find("lbl_hire_money_" .. nx_string(i))
    if nx_is_valid(lbl) and nx_find_custom(lbl, "npc_id") and nx_string(npc_id) == nx_string(lbl.npc_id) then
      return true
    end
  end
  return false
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
function a(str)
  nx_msgbox(nx_string(str))
end
