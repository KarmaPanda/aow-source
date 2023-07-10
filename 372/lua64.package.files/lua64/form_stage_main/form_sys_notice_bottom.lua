require("share\\view_define")
require("util_functions")
require("util_gui")
PHOTO_DEF = "gui\\common\\imagegrid_new\\suo.png"
PHOTO_OUT = "gui\\special\\xxditu-outon.png"
PHOTO_IN = "gui\\special\\xxditu-down.png"
local BottomSysEventList = {}
function clear()
  local form = nx_value("form_stage_main\\form_sys_notice_bottom")
  if not nx_is_valid(form) then
    return
  end
  change_form_size(form)
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
  form.AbsLeft = (gui.Width - form.Width) * 9 / 20
  form.AbsTop = (gui.Height - form.Height) * 16 / 20
end
function add_sys_notice(EventID)
  table.insert(BottomSysEventList, nx_string(EventID))
  refresh_form_notice()
end
function remove_sys_notice_by_pos(NoticeID)
  local notice_num = table.getn(BottomSysEventList)
  if nx_int(NoticeID) >= nx_int(1) and nx_int(NoticeID) <= nx_int(notice_num) then
    table.remove(BottomSysEventList, NoticeID)
  end
  refresh_form_notice()
end
function refresh_form_notice()
  local form_sys_notice_bottom = util_get_form("form_stage_main\\form_sys_notice_bottom", true)
  if not nx_is_valid(form_sys_notice_bottom) then
    return
  end
  form_sys_notice_bottom.grid_sys_notice_bottom:Clear()
  local event_num = table.getn(BottomSysEventList)
  if nx_int(event_num) >= nx_int(1) then
    form_sys_notice_bottom:Show()
    local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
    local bSNS = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_relationship")
    if bMovie or bSNS then
      form_sys_notice_bottom.Visible = false
      nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form_sys_notice_bottom)
    else
      form_sys_notice_bottom.Visible = true
    end
  else
    form_sys_notice_bottom.Visible = false
    form_sys_notice_bottom:Close()
    return
  end
  for count = 1, event_num do
    form_sys_notice_bottom.grid_sys_notice_bottom:AddItem(nx_int(count - 1), nx_string(PHOTO_OUT), nx_widestr(""), nx_int(1), tonumber(count))
  end
end
function on_grid_sys_notice_select_changed(grid, index)
  local NoticeID = tonumber(grid:GetItemMark(index))
  local table_num = table.getn(BottomSysEventList)
  if tonumber(NoticeID) > tonumber(table_num) or tonumber(NoticeID) < tonumber(1) then
    return
  end
  local EventID = BottomSysEventList[NoticeID]
  remove_sys_notice_by_pos(NoticeID)
  local info = nx_string(EventID)
  local table_para = util_split_string(nx_string(info), "&")
  if table.getn(table_para) ~= 4 then
    return
  end
  if nx_string(table_para[1]) == "" then
    return
  end
  if nx_string(table_para[2]) == "" then
    return
  end
  if nx_string(table_para[3]) == "" then
    return
  end
  local form = nx_execute("form_common\\form_sns_dialog", "get_new_confirm_form", "notice_bottom")
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_common\\form_sns_dialog", "show_common_text", form, nx_string(table_para[2]))
  form.btn_reply.Visible = false
  form.btn_goto.Visible = false
  form.btn_broadcast.Visible = false
  local table_btn_visible = util_split_string(nx_string(table_para[4]), ",")
  if table.getn(table_btn_visible) ~= 3 then
    return
  end
  local table_btn = {
    form.btn_reply,
    form.btn_goto,
    form.btn_broadcast
  }
  local left_total = 6
  for i = 1, 3 do
    if nx_number(table_btn_visible[i]) == 1 then
      table_btn[i].Visible = true
      table_btn[i].Left = left_total
      left_total = left_total + table_btn[i].Width
    end
  end
  if form.btn_reply.Visible then
    form.btn_reply.FeedId = nx_string(table_para[3])
    form.btn_reply.Owner = nx_widestr(table_para[1])
  end
  if form.btn_goto.Visible then
    form.btn_goto.GotoName = nx_widestr(table_para[1])
  end
  form:ShowModal()
end
function on_grid_sys_notice_mousein_grid(grid, index)
  local mark = tonumber(grid:GetItemMark(index))
  grid:SetItemImage(nx_int(index), nx_string(PHOTO_IN))
end
function on_grid_sys_notice_mouseout_grid(grid, index)
  local mark = tonumber(grid:GetItemMark(index))
  grid:SetItemImage(nx_int(index), nx_string(PHOTO_OUT))
end
