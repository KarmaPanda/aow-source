require("util_functions")
local client_sub_msg_search_player = 1
local client_sub_msg_scene_search = 8
local client_sub_msg_cancel_avenge = 9
function main_form_init(form)
  form.Fixed = true
  form.avenge_serve_type = 0
  return 1
end
function change_form_size(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.combobox_1.InputEdit.Text = nx_widestr(util_text("ui_avenge_search_input"))
  nx_bind_script(form.combobox_1.InputEdit, nx_current())
  nx_callback(form.combobox_1.InputEdit, "on_get_focus", "on_input_get_focus")
  droplist(form)
  form.lbl_result_search.Visible = false
  form.ani_loading.Visible = false
  form.ani_loading.Left = 0
  form.ani_loading.Top = 0
  form.Visible = true
  return 1
end
function main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  nx_execute("custom_sender", "custom_avenge", nx_int(client_sub_msg_cancel_avenge))
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if nx_widestr(form.combobox_1.InputEdit.Text) == nx_widestr("") then
    return
  end
  if nx_widestr(form.combobox_1.InputEdit.Text) == nx_widestr(player:QueryProp("Name")) then
    form.lbl_result_search.Text = nx_widestr(util_text("29230"))
    form.lbl_result_search.Visible = true
    return
  end
  form.ani_loading.Visible = true
  if not nx_find_custom(form, "avenge_serve_type") then
    return
  end
  if nx_number(form.avenge_serve_type) == nx_number(0) then
    nx_execute("custom_sender", "custom_avenge", nx_int(client_sub_msg_search_player), nx_widestr(form.combobox_1.InputEdit.Text))
  elseif nx_number(form.avenge_serve_type) == nx_number(1) then
    if not nx_find_custom(form, "npc_id") or not nx_find_custom(form, "npc_scene_id") then
      return
    end
    nx_execute("custom_sender", "custom_avenge", nx_int(client_sub_msg_scene_search), nx_string(form.npc_id), nx_int(form.npc_scene_id), nx_widestr(form.combobox_1.InputEdit.Text))
  end
end
function player_not_exist(form)
  form.ani_loading.Visible = false
  form.lbl_result_search.Text = nx_widestr(util_text("ui_avenge_search_not_exist"))
  form.lbl_result_search.Visible = true
end
function player_deleted(form)
  form.ani_loading.Visible = false
  form.lbl_result_search.Text = nx_widestr(util_text("ui_avenge_search_delete"))
  form.lbl_result_search.Visible = true
end
function player_karma_beyond(form)
  form.ani_loading.Visible = false
  form.lbl_result_search.Text = nx_widestr(util_text("ui_avenge_search_karma_beyond"))
  form.lbl_result_search.Visible = true
end
function self_karma_none(form)
  form.ani_loading.Visible = false
  form.lbl_result_search.Text = nx_widestr(util_text("ui_avenge_search_karma_none"))
  form.lbl_result_search.Visible = true
end
function show_avenge_form(form, ...)
  local name = arg[2]
  local arg_count = table.getn(arg)
  local table_level = {
    0,
    0,
    0,
    0,
    0,
    0
  }
  local table_event = {
    0,
    0,
    0,
    0,
    0
  }
  local AvengeLevel = arg[3]
  local AvengeEvent = arg[4]
  local item_avenge = false
  if nx_number(AvengeLevel) >= nx_number(100) then
    AvengeLevel = nx_number(AvengeLevel) - nx_number(100)
    item_avenge = true
  end
  for i = 6, AvengeLevel + 1, -1 do
    table_level[i] = -1
  end
  local EventList = nx_function("ext_int_to_byte", AvengeEvent)
  for j = 1, 5 do
    table_event[6 - j] = EventList[j]
  end
  for k = 5, arg_count do
    if nx_number(table_level[k - 4]) ~= nx_number(-1) then
      table_level[k - 4] = 1
    end
  end
  local form_avenge = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_avenge", true, false)
  if not nx_is_valid(form_avenge) then
    return
  end
  if not nx_find_custom(form, "avenge_serve_type") then
    return
  end
  if nx_number(form.avenge_serve_type) == nx_number(1) then
    form_avenge.npc_id = form.npc_id
    form_avenge.npc_scene_id = form.npc_scene_id
  end
  form_avenge.item_avenge = item_avenge
  form_avenge.avenge_serve_type = form.avenge_serve_type
  form_avenge.TargetName = nx_widestr(name)
  for i = 1, table.getn(table_level) do
    local Level_str = nx_string("Level" .. nx_string(i))
    nx_set_custom(form_avenge, Level_str, table_level[i])
  end
  for j = 1, table.getn(table_event) do
    local Event_str = nx_string("Event" .. nx_string(j))
    nx_set_custom(form_avenge, Event_str, table_event[j])
  end
  form:Close()
  form_avenge:Show()
end
function on_input_get_focus(ipt)
  ipt.Text = nx_widestr("")
end
function droplist(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  form.combobox_1.DropListBox:ClearString()
  local table_name = {"rec_enemy", "rec_blood"}
  for i = 1, table.getn(table_name) do
    if player:FindRecord(table_name[i]) then
      local rows = player:GetRecordRows(table_name[i])
      for j = 0, rows - 1 do
        local player_name = nx_widestr(player:QueryRecord(table_name[i], j, 1))
        form.combobox_1.DropListBox:AddString(player_name)
      end
    end
  end
end
function is_avenge_npc(npc_id)
  local ini = nx_execute("util_functions", "get_ini", "share\\Karma\\AvengeEvent\\avenge_npc.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local section_count = ini:GetSectionCount()
  for i = 0, section_count do
    local item_count = ini:GetSectionItemCount(i)
    for j = 0, item_count do
      local value = ini:GetSectionItemValue(i, j)
      local npc_info = util_split_string(nx_string(value), " ")
      if nx_string(npc_id) == nx_string(npc_info[1]) then
        return true
      end
    end
  end
  return false
end
