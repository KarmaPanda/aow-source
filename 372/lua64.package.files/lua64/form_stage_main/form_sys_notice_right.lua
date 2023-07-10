require("share\\view_define")
require("util_functions")
require("util_gui")
PHOTO_DEF = "gui\\common\\imagegrid_new\\suo.png"
PHOTO_OUT = "gui\\special\\xxditu-outon.png"
PHOTO_IN = "gui\\special\\xxditu-down.png"
local RightSysEventList = {}
function clear()
  local form = nx_value("form_stage_main\\form_sys_notice_right")
  if not nx_is_valid(form) then
    return
  end
  change_form_size(form)
  RightSysEventList = {}
  form:Close()
end
function init_form_sys_notice(self)
  self.Fixed = true
end
function on_main_form_open(form)
  change_form_size(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function change_form_size(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) * 19 / 20
  form.AbsTop = (gui.Height - form.Height) * 6 / 20
end
function add_sys_notice(EventID)
  table.insert(RightSysEventList, nx_string(EventID))
  refresh_form_notice()
end
function remove_sys_notice_by_pos(NoticeID)
  local notice_num = table.getn(RightSysEventList)
  if nx_int(NoticeID) >= nx_int(1) and nx_int(NoticeID) <= nx_int(notice_num) then
    table.remove(RightSysEventList, NoticeID)
  end
  refresh_form_notice()
end
function refresh_form_notice()
  local form_sys_notice_right = util_get_form("form_stage_main\\form_sys_notice_right", true)
  if not nx_is_valid(form_sys_notice_right) then
    return
  end
  form_sys_notice_right.grid_sys_notice_right:Clear()
  local event_num = table.getn(RightSysEventList)
  if nx_int(event_num) >= nx_int(1) then
    form_sys_notice_right:Show()
    local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
    if bMovie then
      form_sys_notice_right.Visible = false
      nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form_sys_notice_right)
    else
      form_sys_notice_right.Visible = true
    end
  else
    form_sys_notice_right.Visible = false
    form_sys_notice_right:Close()
    return
  end
  for count = 1, event_num do
    form_sys_notice_right.grid_sys_notice_right:AddItem(nx_int(count - 1), nx_string(PHOTO_OUT), nx_widestr(""), nx_int(1), tonumber(count))
  end
end
function on_grid_sys_notice_select_changed(grid, index)
  local NoticeID = tonumber(grid:GetItemMark(index))
  local table_num = table.getn(RightSysEventList)
  if tonumber(NoticeID) > tonumber(table_num) or tonumber(NoticeID) < tonumber(1) then
    return
  end
  local EventID = RightSysEventList[NoticeID]
  remove_sys_notice_by_pos(NoticeID)
  local dialog = nx_execute("form_common\\form_sns_dialog", "get_new_confirm_form", "notice_bottom")
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local dialog = nx_execute("form_common\\form_sns_dialog", "show_common_text", dialog, EventID)
end
function on_grid_sys_notice_mousein_grid(grid, index)
  local mark = tonumber(grid:GetItemMark(index))
  grid:SetItemImage(nx_int(index), nx_string(PHOTO_IN))
end
function on_grid_sys_notice_mouseout_grid(grid, index)
  local mark = tonumber(grid:GetItemMark(index))
  grid:SetItemImage(nx_int(index), nx_string(PHOTO_OUT))
end
