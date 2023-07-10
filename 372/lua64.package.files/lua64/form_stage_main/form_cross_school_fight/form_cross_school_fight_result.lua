require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
local STC_AllWarInfo = 4
local CTS_WarDetailedInfo = 5
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function open_form()
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  request_school_msg()
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function request_school_msg()
  client_to_server_msg(STC_AllWarInfo, nx_int(-1))
end
function client_to_server_msg(sub_cmd, ...)
  nx_execute("custom_sender", "custom_cross_school", nx_int(sub_cmd), unpack(arg))
end
function show_cross_school_fight_result(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_widestr(arg[2]) == nx_widestr("") or nx_widestr(arg[3]) == nx_widestr("") then
    local server_info = nx_widestr(gui.TextManager:GetText("ui_cross_schoolfight_74"))
    form.lbl_server_1.Text = server_info
    form.lbl_server_2.Text = server_info
  else
    form.lbl_server_1.Text = arg[2]
    form.lbl_server_2.Text = arg[3]
  end
  form.lbl_fight_school.Text = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(arg[4])))
  form.lbl_defend_school.Text = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(arg[5])))
  form.lbl_fight_rank.Text = nx_widestr(arg[6])
  form.lbl_defend_rank.Text = nx_widestr(arg[7])
  form.lbl_fight_players.Text = nx_widestr(nx_int(arg[8]))
  form.lbl_defend_players.Text = nx_widestr(arg[9])
  local hour, minite = parse_time(nx_int(arg[10]))
  form.lbl_fight_time.Text = gui.TextManager:GetFormatText("ui_cross_schoolfight_61", nx_int(hour), nx_int(minite))
  local result_index = arg[11]
  if nx_int(result_index) == nx_int(1) then
    form.lbl_fight_result.Text = gui.TextManager:GetFormatText("ui_cross_schoolfight_50", form.lbl_fight_school.Text)
  elseif nx_int(result_index) == nx_int(2) then
    form.lbl_fight_result.Text = gui.TextManager:GetFormatText("ui_cross_schoolfight_51")
  elseif nx_int(result_index) == nx_int(3) then
    form.lbl_fight_result.Text = gui.TextManager:GetFormatText("ui_cross_schoolfight_62", form.lbl_defend_school.Text)
  else
    form.lbl_fight_result.Text = nx_widestr("")
  end
  form.lbl_fight_address.Text = form.lbl_defend_school.Text
end
function show_cross_school_fight_list(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local argnum = table.getn(arg)
  if nx_number(argnum) < nx_number(2) then
    return
  end
  form.groupscrollbox_list:DeleteAll()
  form.groupscrollbox_list.IsEditMode = true
  local server_max = (argnum - 1) / 8
  for index = 1, server_max do
    local groupbox = create_groupbox(form, index, unpack(arg))
    if nx_is_valid(groupbox) then
      groupbox.Left = 20
      groupbox.Top = 20
      form.groupscrollbox_list:Add(groupbox)
    end
  end
  form.groupscrollbox_list.IsEditMode = false
  form.groupscrollbox_list:ResetChildrenYPos()
end
function set_copy_ent_info(form, source, target_ent)
  local source_ent = nx_custom(form, source)
  if not nx_is_valid(source_ent) then
    return
  end
  local prop_list = nx_property_list(source_ent)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(target_ent, prop, nx_property(source_ent, prop))
    end
  end
end
function update_groupbox_state(form, btn)
  local child_ctrls = form.groupscrollbox_list:GetChildControlList()
  for i, ctrl in ipairs(child_ctrls) do
    local sub_child_ctrls = ctrl:GetChildControlList()
    for i, sub_ctrl in ipairs(sub_child_ctrls) do
      local ctrl_name = sub_ctrl.Name
      if btn.Name ~= ctrl_name then
        local split_pos = string.find(ctrl_name, "rbtn_school_war")
        if split_pos ~= nil then
          sub_ctrl.Checked = false
        end
      end
    end
  end
end
function create_groupbox(form, index, ...)
  local begin_index = (index - 1) * 8 + 1
  local server1 = arg[begin_index + 1]
  local server2 = arg[begin_index + 2]
  local school_fight_1 = arg[begin_index + 3]
  local school_defend_1 = arg[begin_index + 4]
  local school_index_1 = arg[begin_index + 5]
  local school_fight_2 = arg[begin_index + 6]
  local school_defend_2 = arg[begin_index + 7]
  local school_index_2 = arg[begin_index + 8]
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  set_copy_ent_info(form, "groupbox_item", groupbox)
  groupbox.Name = form.groupbox_item.Name .. nx_string(index)
  local child_ctrls = form.groupbox_item:GetChildControlList()
  for i, ctrl in ipairs(child_ctrls) do
    local ctrl_obj = gui:Create(nx_name(ctrl))
    set_copy_ent_info(form, ctrl.Name, ctrl_obj)
    ctrl_obj.Name = ctrl.Name .. nx_string(index)
    groupbox:Add(ctrl_obj)
  end
  local server_name_lab = groupbox:Find("lbl_name" .. nx_string(index))
  if nx_is_valid(server_name_lab) then
    if nx_widestr(server1) == nx_widestr("") or nx_widestr(server1) == nx_widestr("") then
      local server_info = nx_widestr(gui.TextManager:GetText("ui_cross_schoolfight_74"))
      server1 = server_info
      server2 = server_info
    end
    server_name_lab.Text = nx_widestr(server1) .. nx_widestr("-") .. nx_widestr(server2)
  end
  local fight_school = ""
  local defend_school = ""
  local check_btn_1 = groupbox:Find("rbtn_school_war_1" .. nx_string(index))
  if nx_is_valid(check_btn_1) then
    fight_school = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(school_fight_1)))
    defend_school = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(school_defend_1)))
    check_btn_1.Text = fight_school .. nx_widestr("-") .. defend_school
    check_btn_1.find_index = school_index_1
    nx_bind_script(check_btn_1, nx_current())
    nx_callback(check_btn_1, "on_checked_changed", "on_rbtn_school_war_checked_changed")
  end
  local check_btn_2 = groupbox:Find("rbtn_school_war_2" .. nx_string(index))
  if nx_is_valid(check_btn_2) then
    fight_school = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(school_fight_2)))
    defend_school = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(school_defend_2)))
    check_btn_2.Text = fight_school .. nx_widestr("-") .. defend_school
    check_btn_2.find_index = school_index_2
    nx_bind_script(check_btn_2, nx_current())
    nx_callback(check_btn_2, "on_checked_changed", "on_rbtn_school_war_checked_changed")
  end
  if nx_int(index) == nx_int(1) then
    check_btn_1.Checked = true
  end
  return groupbox
end
function on_rbtn_school_war_checked_changed(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked then
    client_to_server_msg(STC_AllWarInfo, nx_int(btn.find_index))
    update_groupbox_state(form, btn)
  end
end
function parse_time(second)
  local hour = nx_int(second / 3600)
  local minite = nx_int((second - hour * 3600) / 60)
  return hour, minite
end
