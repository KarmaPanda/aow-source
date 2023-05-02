require("util_functions")
require("util_gui")
local FORM_GREAT_NEWS = "form_stage_main\\form_relation\\form_great_events"
local SUB_MSG_NEWS_GREAT_EVENT = 1
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local VScrollBar = form.gsb_events.VScrollBar
  VScrollBar.SmallChange = 10
  VScrollBar.LargeChange = 20
  form.gb_event.Visible = false
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function open_form(flag)
  if flag then
    local form = util_show_form(FORM_GREAT_NEWS, true)
    if not nx_is_valid(form) then
      return
    end
    nx_execute("form_stage_main\\form_relation\\form_world_news", "custom_send_news", SUB_MSG_NEWS_GREAT_EVENT)
    return form
  else
    local form = util_get_form(FORM_GREAT_NEWS, true, false)
    if nx_is_valid(form) then
      form:Close()
      return
    end
  end
end
function show_form(...)
  local form = util_get_form(FORM_GREAT_NEWS, true, false)
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(arg) / 4
  if count == 0 then
    return
  end
  form.lbl_back.BackImage = "gui\\common\\form_back\\bg_main.png"
  form.gsb_events.IsEditMode = true
  form.gsb_events:DeleteAll()
  for i = 0, count - 1 do
    add_event(form.gsb_events, i, arg[i * 4 + 1], arg[i * 4 + 2], arg[i * 4 + 3], arg[i * 4 + 4])
  end
  form.gsb_events.IsEditMode = false
  nx_execute("form_stage_main\\form_relation\\form_relation_news", "change_ctrls_size", "form_great_events")
end
function add_event(groupscrollbox, index, string_id, event_time, para_type, para_str)
  local form = nx_value(FORM_GREAT_NEWS)
  if not nx_is_valid(form) then
    return
  end
  local sns_manager = nx_value("sns_manager")
  if not nx_is_valid(sns_manager) then
    return
  end
  local event_text = sns_manager:GetEventText(string_id, para_type, para_str)
  local time_text, b_right_time = get_time_format(event_time)
  if not nx_boolean(b_right_time) or b_right_time == nil then
    nx_log("[form_great_events.lua][1] time error event_text:" .. nx_string(event_text))
    return
  end
  local refer_gbox = form.gb_event
  local clone_gbox = clone_control("GroupBox", refer_gbox.Name .. nx_string(index), refer_gbox, groupscrollbox, nil)
  if not nx_is_valid(clone_gbox) then
    return
  end
  local control_list = refer_gbox:GetChildControlList()
  for _, child in ipairs(control_list) do
    local ctrl = clone_control(nx_name(child), child.Name .. nx_string(index), child, clone_gbox, clone_gbox)
    if not nx_is_valid(ctrl) then
      return
    end
    if nx_name(ctrl) == "MultiTextBox" then
      nx_bind_script(ctrl, nx_current())
      nx_callback(ctrl, "on_get_capture", "on_get_capture")
      nx_callback(ctrl, "on_lost_capture", "on_lost_capture")
    end
  end
  clone_gbox.mltbox_1:AddHtmlText(event_text, -1)
  clone_gbox.lbl_3.Text = time_text
  clone_gbox.lbl_pic.BackImage = sns_manager:GetEventPic(string_id)
  clone_gbox.Left = 5
  clone_gbox.Top = index * (clone_gbox.Height + 10) + 25
  clone_gbox.Width = groupscrollbox.Width - groupscrollbox.VScrollBar.Width - clone_gbox.Left
  clone_gbox.Visible = true
  groupscrollbox:Add(clone_gbox)
end
function get_time_format(event_time)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local msgdelay = nx_value("MessageDelay")
  if not nx_is_valid(msgdelay) then
    return
  end
  local curServerTime = msgdelay:GetServerNowTime()
  local time = (curServerTime - event_time) / 1000
  if nx_int(time) < nx_int(0) then
    nx_log("[form_great_events.lua][0] time error curServerTime:" .. nx_string(curServerTime) .. " event_time " .. nx_string(event_time))
    return time, false
  end
  local time_text = ""
  if 3600 < time then
    local hour = nx_int(time / 3600)
    time_text = nx_widestr(hour) .. gui.TextManager:GetFormatText("ui_sns_hour")
  else
    local min = nx_int(time / 60)
    if min <= nx_int(0) then
      min = nx_int(1)
    end
    time_text = nx_widestr(min) .. gui.TextManager:GetFormatText("ui_sns_minute")
  end
  return time_text, true
end
function on_get_capture(self)
  local str = self:GetHtmlItemText(0)
  self.HintText = nx_widestr(str)
end
function on_lost_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local mlt_box_desc = form:Find("mltbox_desc")
  if nx_is_valid(mlt_box_desc) then
    gui:Delete(mlt_box_desc)
  end
end
function clone_control(ctrl_type, name, refer_ctrl, parent_ctrl, pretend_ctrl)
  if not (nx_is_valid(refer_ctrl) and nx_is_valid(parent_ctrl)) or ctrl_type == "" or name == "" then
    return nx_null()
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local cloned_ctrl = gui:Create(ctrl_type)
  if not nx_is_valid(cloned_ctrl) then
    return nx_null()
  end
  local prop_list = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_list) do
    nx_set_property(cloned_ctrl, prop_list[i], nx_property(refer_ctrl, prop_list[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, cloned_ctrl)
  cloned_ctrl.Name = name
  parent_ctrl:Add(cloned_ctrl)
  if nx_is_valid(pretend_ctrl) then
    nx_set_custom(pretend_ctrl, refer_ctrl.Name, cloned_ctrl)
  end
  return cloned_ctrl
end
