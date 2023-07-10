require("share\\view_define")
require("util_functions")
require("util_gui")
NOTICE_INI = "ini\\ui\\sysnotice\\sysnotice.ini"
PHOTO_DEF = "gui\\common\\imagegrid_new\\suo.png"
local SysEventList = {}
function clear_SysEventList()
  SysEventList = {}
end
function init_form_sys_notice(self)
  self.Fixed = true
  local ini = get_ini(NOTICE_INI)
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) * 19 / 20
  form.AbsTop = (gui.Height - form.Height) * 5 / 20
end
function on_main_form_open(form)
  set_form_pos(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function add_sys_notice(EventID)
end
function remove_sys_notice_by_pos(NoticeID)
  local notice_num = table.getn(SysEventList)
  if nx_int(NoticeID) >= nx_int(1) and nx_int(NoticeID) <= nx_int(notice_num) then
    table.remove(SysEventList, NoticeID)
  end
  refresh_form_notice()
end
function remove_sys_notice_by_eventID(EventID)
  nx_execute("freshman_help", "sys_notice_click_callback")
  for count = 1, table.getn(SysEventList) do
    local tempID = SysEventList[count]
    if tostring(EventID) == tostring(tempID) then
      table.remove(SysEventList, count)
    end
  end
  refresh_form_notice()
end
function refresh_form_notice()
  local form_sys_notice = util_get_form("form_stage_main\\form_sys_notice", true)
  if not nx_is_valid(form_sys_notice) then
    return
  end
  form_sys_notice.grid_sys_notice:Clear()
  local event_num = table.getn(SysEventList)
  if nx_int(event_num) >= nx_int(1) then
    form_sys_notice:Show()
    local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
    if bMovie then
      form_sys_notice.Visible = false
      nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form_sys_notice)
    else
      form_sys_notice.Visible = true
    end
  else
    form_sys_notice.Visible = false
    form_sys_notice:Close()
    nx_execute("freshman_help", "form_on_close_callback", "form_stage_main\\form_sys_notice")
    return
  end
  local ini = get_ini(NOTICE_INI)
  for count = 1, event_num do
    local sec_index = ini:FindSectionIndex(nx_string(SysEventList[count]))
    if 0 <= sec_index then
      local photo = ini:ReadString(sec_index, "photo", PHOTO_DEF)
      form_sys_notice.grid_sys_notice:AddItem(nx_int(count - 1), nx_string(photo), nx_widestr(""), nx_int(1), tonumber(count))
    end
  end
end
function on_grid_sys_notice_select_changed(grid, index)
  nx_execute("freshman_help", "sys_notice_click_callback")
  local NoticeID = tonumber(grid:GetItemMark(index))
  local table_num = table.getn(SysEventList)
  if tonumber(NoticeID) > tonumber(table_num) or tonumber(NoticeID) < tonumber(1) then
    return
  end
  local EventID = SysEventList[NoticeID]
  if not is_eventID_exist(tostring(EventID)) then
    return
  end
  remove_sys_notice_by_pos(NoticeID)
end
function on_grid_sys_notice_mousein_grid(grid, index)
  local ini = get_ini(NOTICE_INI)
  local mark = tonumber(grid:GetItemMark(index))
  local sec_index = ini:FindSectionIndex(nx_string(SysEventList[mark]))
  if 0 <= sec_index then
    local photo = ini:ReadString(sec_index, "photo_in", PHOTO_DEF)
    grid:SetItemImage(nx_int(index), nx_string(photo))
  end
end
function on_grid_sys_notice_mouseout_grid(grid, index)
  local ini = get_ini(NOTICE_INI)
  local mark = tonumber(grid:GetItemMark(index))
  local sec_index = ini:FindSectionIndex(nx_string(SysEventList[mark]))
  if sec_index < 0 then
    return
  end
  local photo = ini:ReadString(sec_index, "photo", PHOTO_DEF)
  grid:SetItemImage(nx_int(index), nx_string(photo))
end
function show_notice(ConfigID)
end
function notify_a_new_origin(origin_id)
end
function is_event_repeat(EventID)
  for count = 1, table.getn(SysEventList) do
    if nx_string(EventID) == nx_string(SysEventList[count]) then
      return true
    end
  end
  return false
end
function is_eventID_exist(EventID)
  local ini = get_ini(NOTICE_INI)
  if not nx_is_valid(ini) then
    return false
  end
  if ini:FindSection(nx_string(EventID)) then
    return true
  end
  return false
end
function event_type(EventID)
  local return_type = ""
  local ini = get_ini(NOTICE_INI)
  if not nx_is_valid(ini) then
    return return_type
  end
  local sec_index = ini:FindSectionIndex(nx_string(EventID))
  if sec_index < 0 then
    return return_type
  end
  return_type = ini:ReadString(sec_index, "type", "")
  return return_type
end
function get_map_sys_notice_pos()
  local pos = -1
  for count = 1, table.getn(SysEventList) do
    local type = event_type(SysEventList[count])
    if tostring(type) == "TYPE_MAP" then
      pos = count - 1
      break
    end
  end
  return pos
end
