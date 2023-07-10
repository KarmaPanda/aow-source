require("util_gui")
require("util_functions")
require("form_stage_main\\form_task\\task_define")
local g_form_name = "form_stage_main\\form_task\\form_tiaozhan"
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  form.npc = nil
  form.taskid = nil
  form.tiaozhan = nil
  form.isreset = false
  form.btn_tiaozhan.Visible = false
  local mgr = nx_value("TimeRevert")
  if not nx_is_valid(mgr) then
    mgr = nx_create("TimeRevert")
    nx_set_value("TimeRevert", mgr)
  end
  local grid1 = form.textgrid_1
  grid1:SetColTitle(0, util_format_string("task_tiaozhan_name"))
  grid1:SetColTitle(1, util_format_string("task_tiaozhan_school"))
  grid1:SetColTitle(2, util_format_string("task_tiaozhan_qgname"))
  grid1:SetColTitle(3, util_format_string("task_tiaozhan_time"))
  grid1:SetColTitle(4, util_format_string("task_tiaozhan_dis"))
  form.rbtn_lv1.Checked = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  local mgr = nx_value("PlayerTrackModule")
  if not nx_is_valid(mgr) then
    mgr = nx_create("PlayerTrackModule")
    nx_set_value("PlayerTrackModule", mgr)
  end
  mgr:EndShowTrack()
  util_show_form(g_form_name, false)
end
function show_tiaozhan(form, isreset)
  nx_execute("custom_sender", "send_task_msg", nx_int(tiaozhan_query), form.taskid, 1)
  form.isreset = isreset
end
function on_cancel_click(btn)
  local form = btn.ParentForm
  local taskid = form.taskid
  if taskid == nil then
    return
  end
  if form.isreset then
    nx_execute("custom_sender", "send_task_msg", nx_int(reset_task), taskid)
  else
    nx_execute("custom_sender", "send_task_msg", nx_int(accept_task), taskid)
  end
  util_show_form(g_form_name, false)
end
function on_ok_click(btn)
  local form = btn.ParentForm
  local taskid = form.taskid
  local npc = form.npc
  local tiaozhan = form.tiaozhan
  if taskid == nil or npc == nil or tiaozhan == nil then
    return
  end
  if nx_int(tiaozhan) <= nx_int(0) then
    return
  end
  if form.isreset then
    nx_execute("custom_sender", "send_task_msg", nx_int(reset_tiaozhan_task), taskid, npc, tiaozhan)
  else
    nx_execute("custom_sender", "send_task_msg", nx_int(accept_tiaozhan_task), taskid, npc, tiaozhan)
  end
  util_show_form(g_form_name, false)
end
function on_rbtn_1_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    nx_execute("custom_sender", "send_task_msg", nx_int(tiaozhan_query), form.taskid, 1)
    form.lbl_show1.Text = nx_widestr("@ui_tiaozhan_01")
  end
end
function on_rbtn_2_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    nx_execute("custom_sender", "send_task_msg", nx_int(tiaozhan_query), form.taskid, 2)
    form.lbl_show1.Text = nx_widestr("@ui_tiaozhan_02")
  end
end
function on_rbtn_3_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    nx_execute("custom_sender", "send_task_msg", nx_int(tiaozhan_query), form.taskid, 3)
    form.lbl_show1.Text = nx_widestr("@ui_tiaozhan_03")
  end
end
function on_find_1_click(btn)
  local form = btn.ParentForm
  local lv
  if form.rbtn_lv1.Checked then
    lv = 1
  elseif form.rbtn_lv2.Checked then
    lv = 2
  elseif form.rbtn_lv3.Checked then
    lv = 3
  else
    return
  end
  local grid = form.textgrid_1
  local row = grid.RowSelectIndex
  if row < 0 then
    return
  end
  local line = row
  local len = grid:GetGridText(nx_int(line), 3)
  if nx_number(len) == 0 or len == nil then
    local path = "form_stage_main\\form_main\\form_main_centerinfo"
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_format_string("ui_tiaozhan_05"), 2)
    end
    local mgr = nx_value("PlayerTrackModule")
    if not nx_is_valid(mgr) then
      mgr = nx_create("PlayerTrackModule")
      nx_set_value("PlayerTrackModule", mgr)
    end
    mgr:EndShowTrack()
    return
  end
  nx_execute("custom_sender", "send_task_msg", nx_int(tiaozhan_querypath), form.taskid, lv, line)
end
function on_tiaozhan_msg(msgid, ...)
  if msgid == 17 then
    local form = nx_value(g_form_name)
    if not nx_is_valid(form) then
      return
    end
    local count = table.getn(arg)
    if count < 2 then
      return
    end
    local taskid = arg[1]
    if taskid ~= form.taskid then
      return
    end
    local tasktitle = nx_string(arg[2])
    form.lbl_task_title.Text = util_format_string(tasktitle)
    local tiaozhan = nx_int(arg[3])
    local bacpt = nx_number(arg[4])
    if bacpt == 1 then
      form.btn_putong.Enabled = true
    else
      form.btn_putong.Enabled = false
    end
    local grid1 = form.textgrid_1
    local row = 0
    if count == 2 then
    else
      local info = {}
      for i = 5, 26, 6 do
        local index = table.getn(info) + 1
        info[index] = {}
        info[index].name = nx_widestr(arg[i])
        info[index].school = nx_string(arg[i + 1])
        info[index].qg = nx_string(arg[i + 2])
        info[index].qglv = nx_string(arg[i + 3])
        info[index].value = nx_int(arg[i + 4])
        info[index].dis = nx_int(arg[i + 5])
        if info[index].school == "" then
          info[index].school = "task_tiaozhan_no_school"
        end
        if info[index].qg == "" then
          info[index].qg = "task_tiaozhan_no_qg"
        end
      end
      grid1.RowCount = 3
      for i = 1, 3 do
        if nx_string(info[i].name) ~= "" then
          if info[i].name == nx_widestr("task_tiaozhan_maxtm") then
            grid1:SetGridText(i - 1, 0, util_format_string("task_tiaozhan_maxtm"))
          else
            grid1:SetGridText(i - 1, 0, info[i].name)
          end
          grid1:SetGridText(i - 1, 1, util_format_string(info[i].school))
          grid1:SetGridText(i - 1, 2, util_format_string(info[i].qg))
          grid1:SetGridText(i - 1, 3, util_format_string("{@0:num}", info[i].value))
          grid1:SetGridText(i - 1, 4, util_format_string("{@0:num}", info[i].dis))
        end
      end
    end
    form.btn_tiaozhan.Visible = true
    form.tiaozhan = tiaozhan
  elseif msgid == 18 then
    local mgr = nx_value("PlayerTrackModule")
    if not nx_is_valid(mgr) then
      mgr = nx_create("PlayerTrackModule")
      nx_set_value("PlayerTrackModule", mgr)
    end
    local taskid = nx_int(arg[1])
    while nx_number(taskid) > nx_number(1000000) do
      taskid = taskid - 1000000
    end
    local path = mgr:GetPlayerTrackInfo()
    local dis = mgr:GetTrackDistance(path)
    nx_execute("custom_sender", "send_task_msg", nx_int(record_tiaozhan_path), taskid, path, dis)
    mgr:EndShowTrack()
  elseif msgid == 19 then
    local mgr = nx_value("PlayerTrackModule")
    if not nx_is_valid(mgr) then
      mgr = nx_create("PlayerTrackModule")
      nx_set_value("PlayerTrackModule", mgr)
    end
    mgr:StartStoreTrack()
    local revert = arg[2]
    local task_title = arg[3]
    local mgr = nx_value("TimeRevert")
    if not nx_is_valid(mgr) then
      mgr = nx_create("TimeRevert")
      nx_set_value("TimeRevert", mgr)
    end
    mgr:SetRevertEvent(task_title, nx_int(revert), "task_tiaozhan_tm")
  elseif msgid == 22 then
    util_show_form(g_form_name, true)
    local form = nx_value(g_form_name)
    if not nx_is_valid(form) then
      return
    end
    form.btn_find.Visible = false
    form.rbtn_lv1.Visible = false
    form.rbtn_lv2.Visible = false
    form.rbtn_lv3.Visible = false
    form.btn_tiaozhan.Visible = false
    form.btn_putong.Visible = false
    form.lbl_show1.Text = nx_widestr("")
    local tasktitle = nx_string(arg[1])
    form.lbl_task_title.Text = util_format_string(tasktitle)
    local grid1 = form.textgrid_1
    local row = 0
    local lv = nx_number(arg[2])
    if lv == 1 then
      form.lbl_show1.Text = nx_widestr("@ui_tiaozhan_01")
      form.lbl_lv.Text = nx_widestr("@ui_primary")
    elseif lv == 2 then
      form.lbl_show1.Text = nx_widestr("@ui_tiaozhan_02")
      form.lbl_lv.Text = nx_widestr("@ui_junior")
    elseif lv == 3 then
      form.lbl_show1.Text = nx_widestr("@ui_tiaozhan_03")
      form.lbl_lv.Text = nx_widestr("@ui_senior")
    end
    grid1.RowCount = 3
    local line = nx_number(arg[3])
    if line ~= 0 then
      grid1:SelectRow(nx_int(line - 1))
    end
    local info = {}
    for i = 4, 25, 6 do
      local index = table.getn(info) + 1
      info[index] = {}
      info[index].name = nx_widestr(arg[i])
      info[index].school = nx_string(arg[i + 1])
      info[index].qg = nx_string(arg[i + 2])
      info[index].qglv = nx_string(arg[i + 3])
      info[index].value = nx_int(arg[i + 4])
      info[index].dis = nx_int(arg[i + 5])
      if info[index].school == "" then
        info[index].school = "task_tiaozhan_no_school"
      end
      if info[index].qg == "" then
        info[index].qg = "task_tiaozhan_no_qg"
      end
    end
    for i = 1, 3 do
      if info[i].name ~= nx_widestr("") then
        if info[i].name == nx_widestr("task_tiaozhan_maxtm") then
          grid1:SetGridText(i - 1, 0, util_format_string("task_tiaozhan_maxtm"))
        else
          grid1:SetGridText(i - 1, 0, info[i].name)
        end
        grid1:SetGridText(i - 1, 1, util_format_string(info[i].school))
        grid1:SetGridText(i - 1, 2, util_format_string(info[i].qg))
        grid1:SetGridText(i - 1, 3, util_format_string("{@0:num}", info[i].value))
        grid1:SetGridText(i - 1, 4, util_format_string("{@0:num}", info[i].dis))
      end
    end
  elseif msgid == 20 then
    local mgr = nx_value("PlayerTrackModule")
    if not nx_is_valid(mgr) then
      mgr = nx_create("PlayerTrackModule")
      nx_set_value("PlayerTrackModule", mgr)
    end
    mgr:EndStoreTrack()
    local task_title = arg[1]
    local mgr = nx_value("TimeRevert")
    if not nx_is_valid(mgr) then
      mgr = nx_create("TimeRevert")
      nx_set_value("TimeRevert", mgr)
    end
    mgr:RemoveRevertEvent(task_title)
  elseif msgid == 23 then
    local path = arg[1]
    local mgr = nx_value("PlayerTrackModule")
    if not nx_is_valid(mgr) then
      mgr = nx_create("PlayerTrackModule")
      nx_set_value("PlayerTrackModule", mgr)
    end
    mgr:StartShowTrack(nx_string(path))
  elseif msgid == 24 then
    local path = "form_stage_main\\form_main\\form_main_centerinfo"
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_format_string("task_tiaozhan_distance_far"), 2)
    end
    local mgr = nx_value("PlayerTrackModule")
    if not nx_is_valid(mgr) then
      mgr = nx_create("PlayerTrackModule")
      nx_set_value("PlayerTrackModule", mgr)
    end
    mgr:EndShowTrack()
  end
end
