require("util_functions")
require("util_gui")
require("share\\view_define")
require("form_stage_main\\form_task\\task_define")
require("util_role_prop")
local TRACE_MAX_HEIGHT = 250
local TRACE_MIN_HEIGHT = 100
local WIDTH_BASE = 220
local WIDTH_EX = 330
local WIDTH_EXPAND = 40
local HEIGHT_EXPAND = 24
local RBTN_WIDTH = 130
local RBTN_LEFT = 400
local RBTN_SHOW_NUM = 1
local g_table_task_trace = {}
local g_task_type_info = {
  [1] = "ui_task_zx",
  [2] = "ui_task_shimen",
  [3] = "ui_task_life",
  [4] = "ui_task_mp",
  [5] = "ui_task_zhix",
  [6] = "ui_task_fb",
  [7] = "ui_task_enyuan",
  [8] = "ui_task_qiyu",
  [9] = "ui_task_guide",
  [10] = "ui_task_bagua",
  [11] = "ui_task_war",
  [12] = "ui_task_force",
  [13] = "ui_task_newschool",
  [14] = "ui_task_newterritory",
  [15] = "ui_task_shijia",
  [16] = "ui_task_waiyu",
  [17] = "ui_task_mzyy",
  [18] = "ui_task_jhjs",
  [19] = "ui_task_xbqzj"
}
local g_rbtn_index = 1
local g_rbtn_table = {}
local g_show_rbtn_table = {}
local g_rbtn_count = 0
local g_current_alpha = 0
local g_current_form_state = true
local g_show_ScrollBar = true
local g_show_flag = true
function main_form_init(form)
  form.Fixed = false
  form.no_need_motion_alpha = true
  return 1
end
function on_main_form_open(form)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  form.Visible = true
  form.groupbox_alpha.Visible = false
  form.groupbox_sift.Visible = false
  form.groupbox_control.Visible = false
  form.mltbox_trace_info.VScrollBar.Visible = false
  form.Fixed = false
  form.btn_fix.Visible = true
  form.btn_unfix.Visible = false
  form.mltbox_trace_info.OnHyperlink = 0
  set_form_size(form, nx_number(form.Width))
  local form_notice = nx_value("form_stage_main\\form_main\\form_notice_shortcut")
  if nx_is_valid(form_notice) then
    form.Left = form_notice.Left
    form.Top = form_notice.Top + form_notice.Height
  end
  form.mltbox_trace_info.Width = form.Width - 6
  form.lbl_back.Width = form.mltbox_trace_info.Width - 20
  nx_execute("form_stage_main\\form_task\\form_task_main", "bind_record_call_back", form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("Gossip_Record", form, "form_stage_main\\form_task\\form_task_trace", "on_gossip_record_change")
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", form, nx_current(), "update_newjh_task_trace_ui")
  end
  form.BlendValue = 0
  form.BlendColor = "0,255,255,255"
  form.mltbox_trace_info.BlendColor = "0,255,255,255"
  form.lbl_back.BlendColor = "0,255,255,255"
  if not nx_find_custom(form, "is_help") then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "change_form_size")
  elseif false == form.is_help then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "change_form_size")
  end
  return 1
end
function on_main_form_close(form)
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("FormBlendColorIn", form)
  common_execute:RemoveExecute("FormBlendColorOut", form)
  common_execute:RemoveExecute("FormBlendColorIn", form.mltbox_trace_info)
  common_execute:RemoveExecute("FormBlendColorOut", form.mltbox_trace_info)
  common_execute:RemoveExecute("FormBlendColorIn", form.lbl_back)
  common_execute:RemoveExecute("FormBlendColorOut", form.lbl_back)
end
function on_btn_minimize_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  local form_notice_shortcut = nx_value("form_stage_main\\form_main\\form_notice_shortcut")
  if nx_is_valid(form_notice_shortcut) then
    form_notice_shortcut.cbtn_base.Checked = false
  end
end
function on_mltbox_trace_info_select_item_change(mltbox, index)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  if nx_number(mltbox.OnHyperlink) == 1 then
    return
  end
  local form = mltbox.ParentForm
  local task_id = mltbox:GetItemKeyByIndex(index)
  if task_id == 0 then
    return
  end
  util_auto_show_hide_form("form_stage_main\\form_task\\form_task_main")
  nx_execute("form_stage_main\\form_task\\form_task_main", "show_task", task_id)
end
function on_mltbox_trace_info_mousein_hyperlink(mltbox, linkitem, linkdata)
  mltbox.OnHyperlink = 1
end
function on_mltbox_trace_info_mouseout_hyperlink(mltbox, linkitem, linkdata)
  mltbox.OnHyperlink = 0
end
function on_mltbox_trace_info_click_hyperlink(mltbox, linkitem, linkdata)
  linkdata = nx_string(linkdata)
  local str_lst = nx_function("ext_split_string", linkdata, ",")
  if "TASK_ITEM" == str_lst[1] then
    if "" ~= str_lst[2] and nil ~= str_lst[2] then
      click_task_item(str_lst[2])
    end
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_rbtn_click(rbtn)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  if rbtn.Checked then
    local form = rbtn.ParentForm
    local index = rbtn.TabIndex
    if index == 10 then
      show_bagua_info(form)
      return
    end
    load_trace_by_server(0, index)
    if index == 0 then
      move_up_zhuxian_task()
    end
    save_trace_to_server()
    refresh_trace_info(form)
    nx_execute("form_stage_main\\form_task\\form_task_main", "refresh_form_trace")
  end
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if g_rbtn_index <= g_rbtn_count - RBTN_SHOW_NUM then
    g_rbtn_index = g_rbtn_index + 1
  end
  set_sift_size(form)
  local rbtn_table = {
    form.rbtn_all,
    form.rbtn_main,
    form.rbtn_menpai,
    form.rbtn_life,
    form.rbtn_side,
    form.rbtn_clone,
    form.rbtn_adventure,
    form.rbtn_enyuan,
    form.rbtn_guide,
    form.rbtn_bagua,
    form.rbtn_shimen,
    form.rbtn_war,
    form.rbtn_force,
    form.rbtn_newschool,
    form.rbtn_newterritory,
    form.rbtn_shijia,
    form.rbtn_waiyu,
    form.rbtn_mzyy,
    form.rbtn_wljs,
    form.rbtn_xbqzj
  }
  local length = table.getn(rbtn_table)
  for i = 1, length do
    local control = rbtn_table[i]
    if nx_is_valid(control) and control.Visible == true then
      control.Checked = true
      on_rbtn_click(control)
    end
  end
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if 1 < g_rbtn_index then
    g_rbtn_index = g_rbtn_index - 1
  end
  set_sift_size(form)
  local rbtn_table = {
    form.rbtn_all,
    form.rbtn_main,
    form.rbtn_menpai,
    form.rbtn_life,
    form.rbtn_side,
    form.rbtn_clone,
    form.rbtn_adventure,
    form.rbtn_enyuan,
    form.rbtn_guide,
    form.rbtn_bagua,
    form.rbtn_shimen,
    form.rbtn_war,
    form.rbtn_force,
    form.rbtn_newschool,
    form.rbtn_newterritory,
    form.rbtn_shijia,
    form.rbtn_waiyu,
    form.rbtn_mzyy,
    form.rbtn_wljs,
    form.rbtn_xbqzj
  }
  local length = table.getn(rbtn_table)
  for i = 1, length do
    local control = rbtn_table[i]
    if nx_is_valid(control) and control.Visible == true then
      control.Checked = true
      on_rbtn_click(control)
    end
  end
end
function on_btn_alpha_click(btn)
  local form = btn.ParentForm
  if form.groupbox_alpha.Visible == false then
    form.groupbox_alpha.Visible = true
  else
    form.groupbox_alpha.Visible = false
  end
end
function on_tbar_alpha_drag_leave(self)
  local group_box = self.Parent
  group_box.Visible = false
end
function on_tbar_alpha_value_changed(self)
  local form = self.ParentForm
  if self.Value >= 0 and self.Value <= 255 then
    set_BlendColor(form, self.Value)
    g_current_alpha = nx_int(self.Value)
  end
end
function on_alpha_changed(delta)
  local form = nx_value("form_stage_main\\form_small_game\\form_qingame")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_backImage.BlendAlpha = form.groupbox_backImage.BlendAlpha - delta
end
function on_btn_unfix_click(btn)
  local form = btn.ParentForm
  form.Fixed = false
  btn.Visible = false
  form.btn_fix.Visible = true
end
function on_btn_fix_click(btn)
  local form = btn.ParentForm
  form.Fixed = true
  btn.Visible = false
  form.btn_unfix.Visible = true
end
function on_mltbox_trace_info_get_capture(mltbox_trace_info)
  if not nx_is_valid(mltbox_trace_info) then
    return
  end
  local form = mltbox_trace_info.ParentForm
  get_capture(form)
end
function on_groupbox_form_get_capture(groupbox)
  if not nx_is_valid(groupbox) then
    return
  end
  local form = groupbox.ParentForm
  get_capture(form)
end
function on_mltbox_trace_info_lost_capture(mltbox_trace_info)
  local form = mltbox_trace_info.ParentForm
  lost_capture(form)
end
function on_groupbox_form_lost_capture(mltbox_trace_info)
  local form = mltbox_trace_info.ParentForm
  lost_capture(form)
end
function on_mltbox_trace_info_mousein_image(mltbox, item_index, image_index)
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  mltbox.OnHyperlink = 1
  local data = mltbox:GetImageData(item_index, image_index)
  if data ~= "index" then
    return
  end
  local form = mltbox.ParentForm
  local task_id = mltbox:GetItemKeyByIndex(item_index)
  local picture = mgr:GetTaskIndexPicture(nx_int(task_id), 2)
  mltbox:ChangeImage(item_index, image_index, nx_string(picture))
end
function on_mltbox_trace_info_mouseout_image(mltbox, item_index, image_index)
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  mltbox.OnHyperlink = 1
  local data = mltbox:GetImageData(item_index, image_index)
  if data ~= "index" then
    return
  end
  local form = mltbox.ParentForm
  local task_id = mltbox:GetItemKeyByIndex(item_index)
  local picture = mgr:GetTaskIndexPicture(nx_int(task_id), 1)
  mltbox:ChangeImage(item_index, image_index, nx_string(picture))
end
function on_mltbox_trace_info_click_image(mltbox, item_index, image_index)
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local data = mltbox:GetImageData(item_index, image_index)
  if data == "limit" then
    return
  end
  if data == "index" then
    local form = mltbox.ParentForm
    local task_id = mltbox:GetItemKeyByIndex(item_index)
    local picture = mgr:GetTaskIndexPicture(nx_int(task_id), 3)
    mltbox:ChangeImage(item_index, image_index, nx_string(picture))
    local npc_list = mgr:GetSceneTaskNpcList(nx_int(task_id))
    nx_execute("form_stage_main\\form_map\\form_map_scene", "creat_task_polygonbox", npc_list, "", picture, task_id)
    return
  end
end
function on_ready(flag, server_time)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  while loading_flag or nx_string(stage_main_flag) ~= nx_string("success") or bMovie do
    nx_pause(0.1)
    stage_main_flag = nx_value("stage_main")
    loading_flag = nx_value("loading")
    bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_task_trace", true, false)
  load_trace_by_server(1, 0)
  save_trace_to_server()
  if 0 < nx_number(flag) then
    g_show_flag = true
  end
  form:Show()
  move_up_zhuxian_task()
  refresh_trace_info(form)
  form.mltbox_trace_info.VScrollBar.Visible = false
  if g_show_flag == false then
    form.Visible = false
  elseif g_current_form_state == false then
    set_show_or_hide(form, false)
  end
  if 0 < nx_number(flag) then
    form_time_limit = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_task_time_limit", true, false)
    nx_execute("form_stage_main\\form_task\\form_task_time_limit", "refresh_time_info", form_time_limit, server_time)
  end
end
function update_trace_info(task_id, cmd)
  local form = nx_value("form_stage_main\\form_task\\form_task_trace")
  if not nx_is_valid(form) then
    return
  end
  local index = 0
  for i, taskid in pairs(g_table_task_trace) do
    if nx_number(taskid) == nx_number(task_id) then
      index = i
      break
    end
  end
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  if nx_number(cmd) == nx_number(1) then
    if 0 < nx_number(index) then
      table.remove(g_table_task_trace, nx_number(index))
    end
    table.insert(g_table_task_trace, nx_number(task_id))
    mgr.TraceInfo = int_table2string(g_table_task_trace)
    move_up_zhuxian_task()
    refresh_trace_info(form)
    save_trace_to_server()
  elseif nx_number(cmd) == nx_number(0) then
    if 0 < nx_number(index) then
      table.remove(g_table_task_trace, nx_number(index))
      mgr.TraceInfo = int_table2string(g_table_task_trace)
      move_up_zhuxian_task()
      refresh_trace_info(form)
      save_trace_to_server()
    end
  elseif nx_number(cmd) == nx_number(2) then
    refresh_trace_info(form)
  end
end
function refresh_trace_info(form)
  if form.rbtn_bagua.Checked == true then
    return
  end
  local SchoolExtinct = nx_value("SchoolExtinct")
  if not nx_is_valid(SchoolExtinct) then
    return nx_null()
  end
  local ExtinctedSchoolID = SchoolExtinct:GetExtinctSchoolSceneId()
  local ExtinctedSchoolName = SchoolExtinct:GetExtinctSchool()
  form.mltbox_trace_info:Clear()
  if nx_int(ExtinctedSchoolID) ~= nx_int(0) then
    form.mltbox_trace_info.HtmlText = util_format_string("sys_wywl_mmwy_003", nx_string(ExtinctedSchoolName))
  end
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local str = mgr.TraceInfo
  str_tab = util_split_string(str, ",")
  local len = table.getn(str_tab)
  for i = 1, len do
    local id = nx_int(str_tab[i])
    if id > nx_int(0) then
      local text_format = mgr:GetFormatTraceInfo(nx_int(id))
      if nx_string(text_format) ~= "" then
        form.mltbox_trace_info:AddHtmlText(nx_widestr(text_format), nx_int(id))
      end
    end
  end
  set_form_size(form, nx_number(form.Width))
end
function operate_task_info(bShow)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local form = nx_value("form_stage_main\\form_task\\form_task_trace")
  if not nx_is_valid(form) then
    return
  end
  if bShow == true then
    form.Visible = true
    resetFormPos()
    g_show_flag = true
    local form_notice_shortcut = nx_value("form_stage_main\\form_main\\form_notice_shortcut")
    if nx_is_valid(form_notice_shortcut) then
      form_notice_shortcut.cbtn_base.Checked = true
    end
  else
    form.Visible = false
    g_show_flag = false
    local form_notice_shortcut = nx_value("form_stage_main\\form_main\\form_notice_shortcut")
    if nx_is_valid(form_notice_shortcut) then
      form_notice_shortcut.cbtn_base.Checked = false
    end
  end
end
function load_trace_by_server(isShowTrace, line)
  g_table_task_trace = {}
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local str = ""
  local rows = client_player:GetRecordRows("Task_Accepted")
  for row = 0, rows - 1 do
    local trace_flag = client_player:QueryRecord("Task_Accepted", row, accept_rec_track_flag)
    local task_type = client_player:QueryRecord("Task_Accepted", row, accept_rec_line)
    if nx_number(task_type) == nx_number(task_line_shimen_new) then
      task_type = task_line_wuxue
    end
    if (isShowTrace == 1 and nx_number(trace_flag) == nx_number(1) or isShowTrace == 0) and (line == 0 or line == task_type) then
      local task_id = client_player:QueryRecord("Task_Accepted", row, accept_rec_id)
      table.insert(g_table_task_trace, nx_number(task_id))
      str = str .. "," .. nx_string(task_id)
    end
  end
  local mgr = nx_value("TaskManager")
  if nx_is_valid(mgr) then
    mgr.TraceInfo = str
  end
end
function save_trace_to_server()
  local task_list = get_trace_list_str()
  nx_execute("custom_sender", "update_task_trace_state", nx_string(task_list))
end
function move_up_zhuxian_task()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local str = mgr.TraceInfo
  local trace = util_split_string(mgr.TraceInfo, ",")
  str = ""
  for i = 1, table.getn(trace) do
    local task_id = nx_int(trace[i])
    if task_id > nx_int(0) then
      local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, task_id)
      if 0 <= task_row then
        local task_line = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_line)
        if task_line == task_line_main then
          str = nx_string(task_id) .. "," .. str
        else
          str = str .. "," .. nx_string(task_id)
        end
      end
    end
  end
  mgr.TraceInfo = str
  local task_trace = util_split_string(str, ",")
  g_table_task_trace = {}
  for i, id in pairs(task_trace) do
    table.insert(g_table_task_trace, nx_number(id))
  end
end
function int_table2string(tab)
  str = ""
  for i, s_int in pairs(tab) do
    str = str .. "," .. nx_string(s_int)
  end
  return str
end
function get_trace_list_str()
  local task_list = ""
  for i, taskid in pairs(g_table_task_trace) do
    task_list = nx_string(task_list) .. nx_string(taskid) .. ","
  end
  task_list = string.sub(task_list, 0, string.len(task_list) - 1)
  return task_list
end
function click_task_item(item_id)
  if nx_execute("form_stage_main\\form_bag_func", "open_bag_by_configid", item_id) then
    nx_execute("form_stage_main\\form_bag_func", "show_Cover_by_configid", item_id, true, "xuanzekuang_on")
    nx_pause(1)
    nx_execute("form_stage_main\\form_bag_func", "show_Cover_by_configid", item_id, false, "xuanzekuang_on")
  end
end
function get_sift_control(form)
  g_rbtn_table = {
    [1] = {
      control = form.rbtn_main,
      index = 1
    },
    [2] = {
      control = form.rbtn_menpai,
      index = 4
    },
    [3] = {
      control = form.rbtn_life,
      index = 3
    },
    [4] = {
      control = form.rbtn_side,
      index = 5
    },
    [5] = {
      control = form.rbtn_clone,
      index = 6
    },
    [6] = {
      control = form.rbtn_adventure,
      index = 8
    },
    [7] = {
      control = form.rbtn_enyuan,
      index = 7
    },
    [8] = {
      control = form.rbtn_guide,
      index = 9
    },
    [9] = {
      control = form.rbtn_bagua,
      index = 10
    },
    [10] = {
      control = form.rbtn_shimen,
      index = 2
    },
    [11] = {
      control = form.rbtn_war,
      index = 11
    },
    [12] = {
      control = form.rbtn_force,
      index = 12
    },
    [13] = {
      control = form.rbtn_newschool,
      index = 13
    },
    [14] = {
      control = form.rbtn_newterritory,
      index = 14
    },
    [15] = {
      control = form.rbtn_shijia,
      index = 15
    },
    [16] = {
      control = form.rbtn_waiyu,
      index = 16
    },
    [17] = {
      control = form.rbtn_mzyy,
      index = 17
    },
    [18] = {
      control = form.rbtn_wljs,
      index = 18
    },
    [19] = {
      control = form.rbtn_xbqzj,
      index = 19
    }
  }
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = client_player:GetRecordRows("Task_Accepted")
  if rows == 0 then
    g_show_rbtn_table = {}
    return
  end
  g_show_rbtn_table = {
    form.rbtn_all
  }
  local length = table.getn(g_rbtn_table)
  for j = 1, length do
    local control = g_rbtn_table[j].control
    local index = g_rbtn_table[j].index
    for row = 0, rows - 1 do
      local task_type = client_player:QueryRecord("Task_Accepted", row, accept_rec_line)
      if nx_number(task_type) == nx_number(task_line_shimen_new) then
        task_type = task_line_wuxue
      end
      if index == task_type then
        table.insert(g_show_rbtn_table, control)
      end
    end
  end
end
function set_BlendColor(control, alpha)
  control.BlendColor = nx_string(nx_int(alpha)) .. ",255,255,255"
  control.lbl_back.BlendColor = nx_string(nx_int(alpha)) .. ",255,255,255"
  control.groupbox_form.BlendColor = nx_string(nx_int(alpha)) .. ",255,255,255"
end
function get_capture(form)
  if form.mltbox_trace_info.Visible == false then
    return
  end
  set_form_size(form, nx_number(form.Width))
  if g_show_ScrollBar == true then
    form.mltbox_trace_info.VScrollBar.Visible = true
  end
  form.groupbox_control.Visible = true
  form.groupbox_sift.Visible = true
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("FormBlendColorOut", form)
  common_execute:RemoveExecute("FormBlendColorOut", form.mltbox_trace_info)
  local blend = form.BlendColor
  local temp = util_split_string(blend, ",")
  common_execute:RemoveExecute("FormBlendColorIn", form)
  common_execute:RemoveExecute("FormBlendColorIn", form.mltbox_trace_info)
  common_execute:RemoveExecute("FormBlendColorIn", form.lbl_back)
  common_execute:AddExecute("FormBlendColorIn", form, nx_float(0.01), nx_float(255))
  common_execute:AddExecute("FormBlendColorIn", form.mltbox_trace_info, nx_float(0.01), nx_float(255))
  common_execute:AddExecute("FormBlendColorIn", form.lbl_back, nx_float(0.01), nx_float(255))
end
function lost_capture(form)
  if form.mltbox_trace_info.Visible == false then
    return
  end
  if is_mouse_in_mltbox(form.groupbox_control) then
    return
  end
  if is_mouse_in_mltbox(form.groupbox_sift) then
    return
  end
  if form.mltbox_trace_info.VScrollBar.Visible == true then
    if is_mouse_in_mltbox(form.mltbox_trace_info.VScrollBar) then
      return
    end
    form.mltbox_trace_info.VScrollBar.Visible = false
  end
  form.groupbox_control.Visible = false
  form.groupbox_alpha.Visible = false
  form.groupbox_sift.Visible = false
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("FormBlendColorIn", form)
  common_execute:RemoveExecute("FormBlendColorIn", form.mltbox_trace_info)
  common_execute:RemoveExecute("FormBlendColorIn", form.lbl_back)
  local blend = form.BlendColor
  local temp = util_split_string(blend, ",")
  common_execute:AddExecute("FormBlendColorOut", form, nx_float(0.01), nx_float(g_current_alpha))
  common_execute:AddExecute("FormBlendColorOut", form.mltbox_trace_info, nx_float(0.01), nx_float(g_current_alpha))
  common_execute:AddExecute("FormBlendColorOut", form.lbl_back, nx_float(0.01), nx_float(g_current_alpha))
end
function is_mouse_in_mltbox(mltbox)
  local form = nx_value("form_stage_main\\form_task\\form_task_trace")
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  local mouse_x, mouse_y = gui:GetCursorPosition()
  if nx_float(mouse_x) > nx_float(form.AbsLeft) and nx_float(mouse_x) < nx_float(form.AbsLeft + form.Width) and nx_float(mouse_y) > nx_float(mltbox.AbsTop) and nx_float(mouse_y) < nx_float(mltbox.AbsTop + mltbox.Height) then
    return true
  else
    return false
  end
end
function set_show_or_hide(form, flag)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if flag == true and form.mltbox_trace_info.Visible == false then
    form.mltbox_trace_info.Visible = true
    form.groupbox_alpha.Visible = false
    form.groupbox_sift.Visible = true
    g_current_form_state = true
    set_form_size(form, nx_number(form.Width))
    form.btn_alpha.Visible = true
    form.btn_minimize.Visible = true
    if form.Fixed then
      form.btn_fix.Visible = false
      form.btn_unfix.Visible = true
    else
      form.btn_fix.Visible = true
      form.btn_unfix.Visible = false
    end
    local Right = gui.Width - form.AbsLeft - form.Width
    form.Width = 275
    form.groupbox_form.Width = form.Width
    form.mltbox_trace_info.Width = form.Width - 6
    form.lbl_back.Width = form.mltbox_trace_info.Width - 20
    form.groupbox_control.Left = 185
    form.groupbox_alpha.Left = 165
    form.groupbox_control.Height = 25
    form.btn_minimize.Left = 45
    form.btn_minimize.Top = 5
    form.btn_minimize.NormalImage = "gui\\common\\button\\btn_minimum_out.png"
    form.btn_minimize.FocusImage = "gui\\common\\button\\btn_minimum_on.png"
    form.btn_minimize.PushImage = "gui\\common\\button\\btn_minimum_down.png"
    form.btn_minimize.AutoSize = true
    form.AbsLeft = gui.Width - form.Width - Right + 23
    form.groupbox_form.BackImage = ""
    form.TestTrans = true
    form.groupbox_sift.TestTrans = false
    form.groupbox_sift.Visible = true
    form.lbl_back.Visible = true
  elseif flag == false and form.mltbox_trace_info.Visible == true then
    form.mltbox_trace_info.Visible = false
    form.groupbox_sift.Visible = false
    form.groupbox_alpha.Visible = false
    form.btn_minimize.NormalImage = "gui\\mainform\\task_trace\\btn_tasktrace_out.png"
    form.btn_minimize.FocusImage = "gui\\mainform\\task_trace\\btn_tasktrace_on.png"
    form.btn_minimize.PushImage = "gui\\mainform\\task_trace\\btn_tasktrace_down.png"
    form.btn_minimize.AutoSize = true
    local Right = gui.Width - form.AbsLeft - form.Width
    form.Width = 42
    form.Height = 42
    form.btn_minimize.Left = 0
    form.btn_minimize.Top = 0
    form.btn_minimize.Width = 36
    form.btn_minimize.Height = 36
    form.groupbox_control.Visible = true
    form.groupbox_control.Height = form.btn_minimize.Height + 10
    form.groupbox_control.Left = 0
    form.groupbox_alpha.Left = 30
    form.AbsLeft = gui.Width - form.Width - Right - 23
    form.groupbox_sift.Visible = false
    form.btn_alpha.Visible = false
    form.btn_fix.Visible = false
    form.btn_unfix.Visible = false
    form.groupbox_alpha.Visible = false
    form.TestTrans = false
    form.lbl_back.Visible = false
    g_current_form_state = false
  end
end
function get_task_use_item_picure(task_id)
  local itemlist = ""
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindRecord("Task_Record") then
    return ""
  end
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id), 0)
  if task_row < 0 then
    return ""
  end
  local task_state = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_status)
  if task_state ~= 0 then
    return ""
  end
  local cur_step = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_step)
  local rows = client_player:GetRecordRows("Task_Record")
  for row = 0, rows - 1 do
    local id = client_player:QueryRecord("Task_Record", row, task_rec_id)
    local numNow = client_player:QueryRecord("Task_Record", row, task_rec_curnum)
    local numNeed = client_player:QueryRecord("Task_Record", row, task_rec_maxnum)
    local step = client_player:QueryRecord("Task_Record", row, task_rec_order)
    local sub_type = client_player:QueryRecord("Task_Record", row, task_rec_subtype)
    local item_config = client_player:QueryRecord("Task_Record", row, task_rec_key)
    if nx_int(id) == nx_int(task_id) and numNow < numNeed and (step == cur_step or step == 0) and sub_type == subtype_useitem then
      if itemlist ~= "" then
        itemlist = ""
        break
      else
        itemlist = item_config
      end
    end
  end
  if itemlist == "" then
    return ""
  end
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", itemlist, "Photo")
  return photo, itemlist
end
function chk_table_empty(table_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return true
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return true
  end
  if not client_player:FindRecord(table_name) then
    return true
  end
  local count = client_player:GetRecordRows(table_name)
  if count <= 0 then
    return true
  end
  return false
end
function show_bagua_info(form)
  form.mltbox_trace_info:Clear()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("Gossip_Record") then
    return
  end
  local count = client_player:GetRecordRows("Gossip_Record")
  if count <= 0 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  for i = 0, count - 1 do
    local id = client_player:QueryRecord("Gossip_Record", i, 0)
    local npc = client_player:QueryRecord("Gossip_Record", i, 1)
    local info_bagua = nx_widestr("<font face=\"font_title_tasktrace\" color=\"#cbb99a\">") .. nx_widestr("[") .. nx_widestr(gui.TextManager:GetText("ui_task_bagua")) .. nx_widestr("]") .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText(npc)) .. nx_widestr("</font>") .. nx_widestr("<br>") .. nx_widestr("  ") .. nx_widestr(gui.TextManager:GetText(id))
    form.mltbox_trace_info:AddHtmlText(nx_widestr(info_bagua), nx_int(0))
  end
  set_form_size(form, nx_number(form.Width))
end
function on_gossip_record_change(self, recordname, optype, row, clomn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("Gossip_Record") then
    return 0
  end
  local task_rows = 0
  if client_player:FindRecord("Task_Accepted") then
    task_rows = client_player:GetRecordRows("Task_Accepted")
  end
  if self.rbtn_bagua.Checked == false then
    if task_rows == 0 then
      self.rbtn_bagua.Checked = true
      on_rbtn_click(self.rbtn_bagua)
    end
    return 0
  end
  local rows = client_player:GetRecordRows("Gossip_Record")
  if rows == 0 then
    self.rbtn_all.Checked = true
    on_rbtn_click(self.rbtn_all)
  else
    show_bagua_info(self)
  end
  return 1
end
function set_sift_size(form)
  get_sift_control(form)
  g_rbtn_count = 0
  form.rbtn_all.Visible = false
  form.rbtn_main.Visible = false
  form.rbtn_menpai.Visible = false
  form.rbtn_life.Visible = false
  form.rbtn_side.Visible = false
  form.rbtn_clone.Visible = false
  form.rbtn_adventure.Visible = false
  form.rbtn_enyuan.Visible = false
  form.btn_left.Visible = false
  form.btn_right.Visible = false
  form.rbtn_guide.Visible = false
  form.rbtn_bagua.Visible = false
  form.rbtn_shimen.Visible = false
  form.rbtn_war.Visible = false
  form.rbtn_force.Visible = false
  form.rbtn_newschool.Visible = false
  form.rbtn_newterritory.Visible = false
  form.rbtn_shijia.Visible = false
  form.rbtn_waiyu.Visible = false
  form.rbtn_mzyy.Visible = false
  form.rbtn_wljs.Visible = false
  form.rbtn_xbqzj.Visible = false
  local temp_table = {}
  local length = table.getn(g_show_rbtn_table)
  local btn_bugua_pos = 2
  for i = 1, length do
    if nx_string(g_show_rbtn_table[i]) == nx_string(form.rbtn_main) then
      btn_bugua_pos = 3
    end
  end
  for i = 1, length do
    if i == btn_bugua_pos and form.rbtn_bagua.Visible == false and not chk_table_empty("Gossip_Record") then
      form.rbtn_bagua.Visible = true
      table.insert(temp_table, form.rbtn_bagua)
      g_rbtn_count = g_rbtn_count + 1
    end
    local control = g_show_rbtn_table[i]
    if nx_is_valid(control) and control.Visible == false then
      control.Visible = true
      g_rbtn_count = g_rbtn_count + 1
      table.insert(temp_table, control)
    end
  end
  if g_rbtn_count < RBTN_SHOW_NUM and form.rbtn_bagua.Visible == false and not chk_table_empty("Gossip_Record") then
    form.rbtn_bagua.Visible = true
    table.insert(temp_table, form.rbtn_bagua)
    g_rbtn_count = g_rbtn_count + 1
  end
  if g_rbtn_count > RBTN_SHOW_NUM then
    form.btn_left.Visible = true
    form.btn_right.Visible = true
    form.btn_left.Left = 5
    form.btn_right.Left = 145
    length = table.getn(temp_table)
    if g_rbtn_index < 1 or length < g_rbtn_index then
      return
    end
    for i = 1, length do
      local control = temp_table[i]
      if i == g_rbtn_index then
        control.Visible = true
        control.Left = 16
      else
        control.Visible = false
      end
    end
  else
    length = table.getn(temp_table)
    if g_rbtn_index < 1 or length < g_rbtn_index then
      return
    end
    for i = 1, length do
      local control = temp_table[i]
      if i == g_rbtn_index then
        control.Visible = true
        control.Left = 16
      else
        control.Visible = false
      end
    end
  end
end
function set_form_size(form, width)
  local gui = nx_value("gui")
  set_sift_size(form)
  if g_current_form_state == false then
    return
  end
  local height_text = form.mltbox_trace_info:GetContentHeight() + 50
  local control_height = height_text + 10
  if nx_number(control_height) > TRACE_MAX_HEIGHT then
    g_show_ScrollBar = true
  else
    g_show_ScrollBar = false
  end
  if nx_number(control_height) > TRACE_MAX_HEIGHT then
    control_height = TRACE_MAX_HEIGHT
  elseif nx_number(control_height) < TRACE_MIN_HEIGHT then
    control_height = TRACE_MIN_HEIGHT
  end
  form.mltbox_trace_info.ViewRect = "15,10,238," .. nx_string(control_height)
  form.mltbox_trace_info.Height = control_height
  form.lbl_back.Height = control_height
  form.groupbox_form.Height = control_height + HEIGHT_EXPAND
  form.mltbox_trace_info.VScrollBar.Height = control_height
  form.Height = form.groupbox_form.Height + 30
end
function resetFormPos()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_task\\form_task_trace")
  if not nx_is_valid(form) or not nx_is_valid(gui) then
    return false
  end
  form.Left = gui.Width * 2 / 3 - gui.Width
  form.Top = gui.Height * 4 / 5 - gui.Height
end
function open_task_info()
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local form = util_get_form("form_stage_main\\form_task\\form_task_trace", true, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  set_show_or_hide(form, true)
end
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function find_text_item(form, multi_text, find_text)
  if form.mltbox_trace_info.Visible == false then
    nx_execute("form_stage_main\\form_task\\form_task_trace", "set_show_or_hide", form, true)
  end
end
function update_newjh_task_trace_ui(form)
  if not nx_is_valid(form) then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form.Visible = false
  else
    form.Visible = true
  end
  return
end
