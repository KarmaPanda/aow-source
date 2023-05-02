require("util_functions")
require("define\\gamehand_type")
require("util_gui")
require("share\\itemtype_define")
local temp_record_head, temp_record_tail
local job_compose_table = {
  "sh_tj",
  "sh_ds",
  "sh_ys",
  "sh_cf",
  "sh_cs",
  "sh_jq"
}
function main_form_init(self)
  self.Fixed = false
  self.LimitInScreen = true
  nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  fresh_info(self)
end
function on_main_form_close(form)
  form.groupbox_base:DeleteAll()
  nx_destroy(form)
end
function get_compose_display_info(jobid, id)
  if nx_string(jobid) == "sh_gs" then
    return get_fortune_info_by_jobid(id)
  else
    return get_info_by_formula(id)
  end
end
function get_skill_display_info(jobid, skillid)
  local gui = nx_value("gui")
  local job_skill_ini = nx_execute("util_functions", "get_ini", "share\\Life\\job_skill.ini")
  if not nx_is_valid(job_skill_ini) then
    return "", "", ""
  end
  local sec_index = job_skill_ini:FindSectionIndex(skillid)
  if sec_index < 0 then
    nx_log("share\\Life\\job_skill.ini sec_index = " .. nx_string(sub_str[i]))
    return "", "", ""
  end
  local photo = job_skill_ini:ReadString(sec_index, "photo", "")
  local name = gui.TextManager:GetFormatText("ui_" .. nx_string(skillid))
  return skillid, photo, name
end
function is_in_job_compose_table(job_id)
  if job_id == "" or job_id == nil then
    return false
  end
  local recname = job_id
  for i = 1, table.getn(job_compose_table) do
    if recname == job_compose_table[i] then
      return true
    end
  end
  return false
end
function fresh_info(form)
  if form.job_id == nil or nx_string(form.job_id) == "" then
    return
  end
  local gui = nx_value("gui")
  form.lbl_job_name.Text = nx_widestr(gui.TextManager:GetText(form.job_id))
  form.mltbox_desc:Clear()
  local desc_info = "desc_job_share_set_" .. nx_string(form.job_id)
  form.mltbox_desc.HtmlText = gui.TextManager:GetText(desc_info)
  local groupbox_base = form.groupbox_base
  groupbox_base:DeleteAll()
  local control_top = 30
  control_top = add_skill_share_info(form, groupbox_base, control_top)
  if is_in_job_compose_table(form.job_id) then
    control_top = add_compose_share_info(form, groupbox_base, control_top)
  else
    add_save_button(form, groupbox_base, control_top)
  end
end
function add_compose_share_info(form, groupbox_base, control_top)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local recname = nx_string(form.job_id) .. "_share_rec"
  local share_type = "compose"
  local groupbox_compose = gui:Create("GroupBox")
  groupbox_base:Add(groupbox_compose)
  groupbox_compose.Name = "groupbox_" .. share_type
  groupbox_compose.BackColor = "0,0,0,0"
  groupbox_compose.DrawMode = "ExpandV"
  groupbox_compose.Left = 20
  groupbox_compose.Top = control_top
  groupbox_compose.Width = 400
  groupbox_compose.job_id = form.job_id
  groupbox_compose.curindex = nil
  groupbox_compose.selected = nil
  if control_top == 195 then
    groupbox_compose.Height = 265
  else
    groupbox_compose.Height = 430
  end
  groupbox_compose.BackImage = "gui\\common\\list\\bg_line.png"
  local groupbox_compose_list = gui:Create("GroupScrollableBox")
  groupbox_compose:Add(groupbox_compose_list)
  groupbox_compose_list.Name = "groupbox_" .. share_type .. "_list"
  groupbox_compose_list.BackColor = "0,0,0,0"
  groupbox_compose_list.DrawMode = "FitWindow"
  groupbox_compose_list.NoFrame = true
  groupbox_compose_list.Left = 4
  groupbox_compose_list.Top = 5
  groupbox_compose_list.Width = 395
  groupbox_compose_list:DeleteAll()
  if control_top == 195 then
    groupbox_compose_list.Height = 220
  else
    groupbox_compose_list.Height = 385
  end
  local group_top = 0
  local cursor = temp_record_head
  while cursor do
    local formula_id = cursor.formula
    local Prize = cursor.prize
    local ding = math.floor(Prize / 1000000)
    local liang = math.floor(Prize % 1000000 / 1000)
    local wen = math.floor(Prize % 1000000 % 1000)
    local configid, photo, name = get_compose_display_info(form.job_id, formula_id)
    local text_ding = nx_widestr("0")
    if 0 < ding then
      text_ding = nx_widestr(nx_int(ding))
    end
    local text_liang = nx_widestr("0")
    if 0 < liang then
      text_liang = nx_widestr(nx_int(liang))
    end
    local text_wen = nx_widestr("0")
    if 0 < wen then
      text_wen = nx_widestr(nx_int(wen))
    end
    local groupbox = gui:Create("GroupBox")
    groupbox_compose_list:Add(groupbox)
    groupbox.AutoSize = false
    groupbox.Name = "groupbox_info_" .. share_type .. formula_id
    groupbox.BackColor = "0,0,0,0"
    groupbox.DrawMode = "FitWindow"
    groupbox.BackImage = "gui\\common\\form_line\\form_sub.png"
    groupbox.NoFrame = true
    groupbox.Left = 0
    groupbox.Top = group_top
    groupbox.Width = 380
    groupbox.Height = 55
    groupbox.index = formula_id
    local btn = gui:Create("Button")
    groupbox:Add(btn)
    btn.Name = "btn_info_" .. share_type .. nx_string(row)
    btn.Left = 0
    btn.Top = 0
    btn.Width = groupbox.Width
    btn.Height = groupbox.Height
    btn.DrawMode = "FitWindow"
    btn.LineColor = "0,0,0,0"
    btn.BackColor = "0,0,0,0"
    btn.FocusImage = "gui\\common\\combobox\\bg_select3.png"
    btn.PushImage = "gui\\common\\combobox\\bg_select3.png"
    btn.index = formula_id
    btn.groupbox = groupbox_compose
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_select_click")
    local imagegrid = gui:Create("ImageControlGrid")
    groupbox:Add(imagegrid)
    imagegrid.AutoSize = true
    imagegrid.Width = 44
    imagegrid.Height = 44
    imagegrid.Name = "ImageControlGrid_info_" .. share_type .. nx_string(row)
    imagegrid.DrawGridBack = "gui\\common\\imagegrid\\icon_item2.png"
    imagegrid.DrawMode = "Expand"
    imagegrid.NoFrame = true
    imagegrid.HasVScroll = false
    imagegrid.Left = 25
    imagegrid.Top = 8
    imagegrid.RowNum = 1
    imagegrid.ClomnNum = 1
    imagegrid.GridWidth = 36
    imagegrid.GridHeight = 36
    imagegrid.RoundGrid = false
    imagegrid.GridBackOffsetX = -4
    imagegrid.GridBackOffsetY = -3
    imagegrid.DrawMouseIn = "xuanzekuang"
    imagegrid.BackColor = "0,0,0,0"
    imagegrid.SelectColor = "0,0,0,0"
    imagegrid.MouseInColor = "0,0,0,0"
    imagegrid.CoverColor = "0,0,0,0"
    nx_bind_script(imagegrid, nx_current())
    nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_mousein_grid")
    nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
    imagegrid.HasMultiTextBox = true
    imagegrid.MultiTextBoxCount = 2
    imagegrid.MultiTextBox1.NoFrame = true
    imagegrid.MultiTextBox1.Width = 200
    imagegrid.MultiTextBox1.Height = 58
    imagegrid.MultiTextBox1.LineHeight = 20
    imagegrid.MultiTextBox1.ViewRect = "0,0,200,58"
    imagegrid.MultiTextBox1.Font = "font_main"
    imagegrid.MultiTextBox1.ForeColor = "255,95,67,37"
    imagegrid.Font = "font_main"
    imagegrid.MultiTextBoxPos = "60,-4"
    imagegrid.ViewRect = "0,0,67,67"
    imagegrid:AddItem(0, photo, "", 1, -1)
    imagegrid:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(configid))
    local compose_lbl = gui:Create("Label")
    groupbox:Add(compose_lbl)
    compose_lbl.Left = 80
    compose_lbl.Top = 20
    if nx_is_valid(compose_lbl) then
      local show_name = nx_widestr(name)
      if nx_ws_length(show_name) > 10 then
        compose_lbl.HintText = nx_widestr(name)
        compose_lbl.Transparent = false
        compose_lbl.ClickEvent = false
        show_name = nx_function("ext_ws_substr", show_name, 0, 10) .. nx_widestr("...")
      else
        compose_lbl.HintText = nx_widestr("")
      end
      compose_lbl.Text = show_name
    end
    compose_lbl.ForeColor = "255,95,67,37"
    compose_lbl.Font = "font_treeview"
    compose_lbl.ShadowColor = "255,255,255,255"
    local groupbox_prize = gui:Create("GroupBox")
    groupbox:Add(groupbox_prize)
    groupbox_prize.Name = "groupbox_prize"
    groupbox_prize.Left = 160
    groupbox_prize.Top = 15
    groupbox_prize.Width = 250
    groupbox_prize.Height = 30
    groupbox_prize.BackColor = "0,0,0,0"
    groupbox_prize.LineColor = "0,0,0,0"
    local edt_ding = gui:Create("Edit")
    groupbox_prize:Add(edt_ding)
    edt_ding.Name = "edt_ding"
    edt_ding.Text = text_ding
    edt_ding.Left = 10
    edt_ding.Top = 0
    edt_ding.Width = 30
    edt_ding.Height = 28
    edt_ding.ForeColor = "255,147,123,99"
    edt_ding.BackColor = "0,0,0,0"
    edt_ding.LineColor = "0,0,0,0"
    edt_ding.TextOffsetX = 8
    edt_ding.Align = "Center"
    edt_ding.OnlyDigit = true
    edt_ding.MaxDigit = 0
    edt_ding.MaxLength = 6
    edt_ding.DrawMode = "Expand"
    edt_ding.ReadOnly = true
    edt_ding.Font = "font_text_figure"
    edt_ding.groupbox = groupbox
    edt_ding.parentform = groupbox_prize
    local lbl_ding = gui:Create("Label")
    groupbox_prize:Add(lbl_ding)
    lbl_ding.Name = "lbl_ding"
    lbl_ding.Left = 40
    lbl_ding.Top = 6
    lbl_ding.ForeColor = "255,95,67,37"
    lbl_ding.Font = "font_treeview"
    lbl_ding.ShadowColor = "255,255,255,255"
    lbl_ding.Width = 35
    lbl_ding.Align = "Center"
    lbl_ding.Text = nx_widestr(gui.TextManager:GetText("ui_ding"))
    local edt_liang = gui:Create("Edit")
    groupbox_prize:Add(edt_liang)
    edt_liang.Name = "edt_liang"
    edt_liang.Text = text_liang
    edt_liang.Left = 75
    edt_liang.Top = 0
    edt_liang.Width = 40
    edt_liang.Height = 28
    edt_liang.ForeColor = "255,147,123,99"
    edt_liang.BackColor = "0,0,0,0"
    edt_liang.LineColor = "0,0,0,0"
    edt_liang.TextOffsetX = 8
    edt_liang.Align = "Center"
    edt_liang.OnlyDigit = true
    edt_liang.MaxDigit = 0
    edt_liang.MaxLength = 3
    edt_liang.DrawMode = "Expand"
    edt_liang.ReadOnly = true
    edt_liang.Font = "font_text_figure"
    edt_liang.groupbox = groupbox
    edt_liang.parentform = groupbox_prize
    local lbl_liang = gui:Create("Label")
    groupbox_prize:Add(lbl_liang)
    lbl_liang.Name = "lbl_liang"
    lbl_liang.Left = 115
    lbl_liang.Top = 6
    lbl_liang.ForeColor = "255,95,67,37"
    lbl_liang.Font = "font_treeview"
    lbl_liang.ShadowColor = "255,255,255,255"
    lbl_liang.Width = 35
    lbl_liang.Align = "Center"
    lbl_liang.Text = nx_widestr(gui.TextManager:GetText("ui_liang"))
    local edt_wen = gui:Create("Edit")
    groupbox_prize:Add(edt_wen)
    edt_wen.Name = "edt_wen"
    edt_wen.Text = text_wen
    edt_wen.Left = 150
    edt_wen.Top = 0
    edt_wen.Width = 30
    edt_wen.Height = 28
    edt_wen.ForeColor = "255,147,123,99"
    edt_wen.BackColor = "0,0,0,0"
    edt_wen.LineColor = "0,0,0,0"
    edt_wen.TextOffsetX = 8
    edt_wen.Align = "Center"
    edt_wen.OnlyDigit = true
    edt_wen.MaxDigit = 0
    edt_wen.MaxLength = 3
    edt_wen.DrawMode = "Expand"
    edt_wen.ReadOnly = true
    edt_wen.Font = "font_text_figure"
    edt_wen.groupbox = groupbox
    edt_wen.parentform = groupbox_prize
    local lbl_wen = gui:Create("Label")
    groupbox_prize:Add(lbl_wen)
    lbl_wen.Name = "lbl_wen"
    lbl_wen.Left = 180
    lbl_wen.Top = 6
    lbl_wen.ForeColor = "255,95,67,37"
    lbl_wen.Font = "font_treeview"
    lbl_wen.ShadowColor = "255,255,255,255"
    lbl_wen.Width = 35
    lbl_wen.Align = "Center"
    lbl_wen.Text = nx_widestr(gui.TextManager:GetText("ui_wen"))
    nx_bind_script(edt_ding, nx_current())
    nx_callback(edt_ding, "on_get_capture", "on_mousein_edit")
    nx_callback(edt_ding, "on_lost_capture", "on_mouseout_edit")
    nx_bind_script(edt_liang, nx_current())
    nx_callback(edt_liang, "on_get_capture", "on_mousein_edit")
    nx_callback(edt_liang, "on_lost_capture", "on_mouseout_edit")
    nx_bind_script(edt_wen, nx_current())
    nx_callback(edt_wen, "on_get_capture", "on_mousein_edit")
    nx_callback(edt_wen, "on_lost_capture", "on_mouseout_edit")
    group_top = group_top + 55
    cursor = cursor.next
  end
  if group_top < groupbox_compose_list.Height then
    while group_top < groupbox_compose_list.Height do
      local groupbox = gui:Create("GroupBox")
      groupbox_compose_list:Add(groupbox)
      groupbox.AutoSize = false
      groupbox.Name = "groupbox_info_blank"
      groupbox.BackColor = "0,0,0,0"
      groupbox.DrawMode = "FitWindow"
      groupbox.BackImage = "gui\\common\\form_line\\form_sub.png"
      groupbox.NoFrame = true
      groupbox.Left = 0
      groupbox.Top = group_top
      groupbox.Width = 380
      groupbox.Height = 55
      group_top = group_top + 55
    end
  end
  local groupbox_del = gui:Create("GroupBox")
  groupbox_compose:Add(groupbox_del)
  groupbox_del.Name = "groupbox_" .. share_type .. "_del"
  groupbox_del.BackColor = "0,0,0,0"
  groupbox_del.DrawMode = "FitWindow"
  groupbox_del.NoFrame = true
  groupbox_del.Left = 4
  groupbox_del.BackImage = "gui\\common\\form_line\\form_sub.png"
  if control_top == 195 then
    groupbox_del.Top = 225
  else
    groupbox_del.Top = 390
  end
  groupbox_del.Width = 392
  groupbox_del.Height = 35
  local btn_del_all = gui:Create("Button")
  groupbox_del:Add(btn_del_all)
  btn_del_all.Left = 92
  btn_del_all.Top = 5
  btn_del_all.Width = 85
  btn_del_all.Height = 25
  btn_del_all.NormalImage = "gui\\common\\button\\btn_normal2_out.png"
  btn_del_all.FocusImage = "gui\\common\\button\\btn_normal2_on.png"
  btn_del_all.PushImage = "gui\\common\\button\\btn_normal2_down.png"
  btn_del_all.Text = nx_widestr(gui.TextManager:GetText("ui_mail_qbsc"))
  btn_del_all.Font = "font_main"
  btn_del_all.ForeColor = "255,76,61,44"
  btn_del_all.ShadowColor = "0,255,255,255"
  btn_del_all.DrawMode = "ExpandH"
  nx_bind_script(btn_del_all, nx_current())
  nx_callback(btn_del_all, "on_click", "on_btn_del_all_click")
  local btn_del = gui:Create("Button")
  groupbox_del:Add(btn_del)
  btn_del.Left = 8
  btn_del.Top = 5
  btn_del.Width = 85
  btn_del.Height = 25
  btn_del.Text = nx_widestr(gui.TextManager:GetText("ui_delete"))
  btn_del.DrawMode = "ExpandH"
  btn_del.groupbox = groupbox_compose
  btn_del.NormalImage = "gui\\common\\button\\btn_normal2_out.png"
  btn_del.FocusImage = "gui\\common\\button\\btn_normal2_on.png"
  btn_del.PushImage = "gui\\common\\button\\btn_normal2_down.png"
  btn_del.Font = "font_main"
  btn_del.ForeColor = "255,76,61,44"
  btn_del.ShadowColor = "0,255,255,255"
  nx_bind_script(btn_del, nx_current())
  nx_callback(btn_del, "on_click", "on_btn_del_click")
  btn_del.DrawMode = "ExpandH"
  local btn_save_all = gui:Create("Button")
  groupbox_del:Add(btn_save_all)
  btn_save_all.Left = 300
  btn_save_all.Top = 5
  btn_save_all.Width = 85
  btn_save_all.Height = 25
  btn_save_all.NormalImage = "gui\\common\\button\\btn_normal2_out.png"
  btn_save_all.FocusImage = "gui\\common\\button\\btn_normal2_on.png"
  btn_save_all.PushImage = "gui\\common\\button\\btn_normal2_down.png"
  btn_save_all.Text = nx_widestr(gui.TextManager:GetText("ui_save"))
  btn_save_all.Font = "font_main"
  btn_save_all.ForeColor = "255,76,61,44"
  btn_save_all.ShadowColor = "0,255,255,255"
  btn_save_all.DrawMode = "ExpandH"
  nx_bind_script(btn_save_all, nx_current())
  nx_callback(btn_save_all, "on_click", "on_btn_save_all_click")
  local groupbox_lbl_compose = gui:Create("GroupBox")
  groupbox_base:Add(groupbox_lbl_compose)
  groupbox_lbl_compose.Left = 130
  groupbox_lbl_compose.Top = control_top - 13
  groupbox_lbl_compose.Width = 180
  groupbox_lbl_compose.Height = 25
  groupbox_lbl_compose.DrawMode = "Expand"
  groupbox_lbl_compose.BackImage = "gui\\common\\form_back\\bg_title.png"
  local lbl_compose = gui:Create("Label")
  groupbox_lbl_compose:Add(lbl_compose)
  lbl_compose.Left = 50
  lbl_compose.Top = 5
  lbl_compose.Font = "font_text_title1"
  lbl_compose.Align = "Center"
  lbl_compose.Text = nx_widestr(gui.TextManager:GetText("ui_server3"))
  lbl_compose.ForeColor = "255,75,61,44"
  lbl_compose.LineColor = "255,0,0,0"
  lbl_compose.BackColor = "0,0,0,0"
  groupbox_compose_list.IsEditMode = false
  groupbox_compose_list.HasVScroll = true
  groupbox_compose_list.ScrollSize = 15
  groupbox_compose_list.AlwaysVScroll = true
  groupbox_compose_list.VScrollBar.Value = groupbox_compose_list.VScrollBar.Maximum
  groupbox_compose_list.VScrollBar.BackImage = "gui\\common\\scrollbar\\bg_scrollbar2.png"
  groupbox_compose_list.VScrollBar.DrawMode = "Expand"
  groupbox_compose_list.VScrollBar.DecButton.NormalImage = "gui\\common\\scrollbar\\button_2\\btn_up_out.png"
  groupbox_compose_list.VScrollBar.DecButton.FocusImage = "gui\\common\\scrollbar\\button_2\\btn_up_on.png"
  groupbox_compose_list.VScrollBar.DecButton.PushImage = "gui\\common\\scrollbar\\button_2\\btn_up_down.png"
  groupbox_compose_list.VScrollBar.IncButton.NormalImage = "gui\\common\\scrollbar\\button_2\\btn_down_out.png"
  groupbox_compose_list.VScrollBar.IncButton.FocusImage = "gui\\common\\scrollbar\\button_2\\btn_down_on.png"
  groupbox_compose_list.VScrollBar.IncButton.PushImage = "gui\\common\\scrollbar\\button_2\\btn_down_down.png"
  groupbox_compose_list.VScrollBar.TrackButton.NormalImage = "gui\\common\\scrollbar\\button_2\\btn_trace_out.png"
  groupbox_compose_list.VScrollBar.TrackButton.FocusImage = "gui\\common\\scrollbar\\button_2\\btn_trace_on.png"
  groupbox_compose_list.VScrollBar.TrackButton.PushImage = "gui\\common\\scrollbar\\button_2\\btn_trace_on.png"
  groupbox_compose_list.VScrollBar.TrackButton.DrawMode = "ExpandV"
  groupbox_compose_list.VScrollBar.TrackButton.Width = 15
  control_top = control_top + groupbox_compose.Height
  return control_top
end
function add_save_button(form, groupbox_base, control_top)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  groupbox_base.Height = 222
  form.Height = 320
  local btn_save_all = gui:Create("Button")
  groupbox_base:Add(btn_save_all)
  btn_save_all.Left = 300
  btn_save_all.Top = 180
  btn_save_all.Width = 85
  btn_save_all.Height = 25
  btn_save_all.NormalImage = "gui\\common\\button\\btn_normal2_out.png"
  btn_save_all.FocusImage = "gui\\common\\button\\btn_normal2_on.png"
  btn_save_all.PushImage = "gui\\common\\button\\btn_normal2_down.png"
  btn_save_all.Text = nx_widestr(gui.TextManager:GetText("ui_save"))
  btn_save_all.Font = "font_main"
  btn_save_all.ForeColor = "255,76,61,44"
  btn_save_all.ShadowColor = "0,255,255,255"
  btn_save_all.DrawMode = "ExpandH"
  nx_bind_script(btn_save_all, nx_current())
  nx_callback(btn_save_all, "on_click", "on_btn_save_all_click")
end
function on_btn_save_all_click(btn)
  local form = btn.ParentForm
  save_config(form, "save")
end
function save_config(form, result)
  if result == "save" then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local job_id = nx_string(form.job_id)
    local prize_string = ""
    local share_type = "compose"
    nx_execute("custom_sender", "custom_clear_life_share", form.job_id)
    local cursor = temp_record_head
    while cursor do
      nx_execute("custom_sender", "custom_add_life_share", cursor.formula, job_id)
      local temp_prize = cursor.prize
      if prize_string == "" then
        prize_string = temp_prize
      else
        prize_string = prize_string .. "," .. temp_prize
      end
      cursor = cursor.next
    end
    nx_execute("custom_sender", "custom_set_life_compose_share", job_id, prize_string)
    recname = "job_skill_share_rec"
    rownum = client_player:GetRecordRows(recname)
    prize_string = ""
    share_type = "skill"
    local groupbox_skill = form.groupbox_base:Find("groupbox_" .. share_type)
    if nx_is_valid(groupbox_skill) then
      local groupbox_skill_list = groupbox_skill:Find("groupbox_" .. share_type .. "_list")
      for row = 1, rownum do
        local jobid = client_player:QueryRecord(recname, row - 1, 0)
        if nx_string(form.job_id) == nx_string(jobid) then
          local skillname = client_player:QueryRecord(recname, row - 1, 1)
          local groupbox = groupbox_skill_list:Find("groupbox_info_" .. share_type .. nx_string(row))
          if not nx_is_valid(groupbox) then
            break
          end
          local groupbox_prize = groupbox:Find("groupbox_prize")
          local edt_ding = groupbox_prize:Find("edt_ding")
          local edt_liang = groupbox_prize:Find("edt_liang")
          local edt_wen = groupbox_prize:Find("edt_wen")
          if not (nx_is_valid(edt_ding) and nx_is_valid(edt_liang)) or not nx_is_valid(edt_wen) then
            break
          end
          local cbtn = groupbox:Find("btn_share_" .. share_type .. nx_string(row))
          if not nx_is_valid(cbtn) then
            break
          end
          local isShare = 0
          if cbtn.Checked then
            isShare = 1
          end
          local ding = nx_int(edt_ding.Text)
          local liang = nx_int(edt_liang.Text)
          local wen = nx_int(edt_wen.Text)
          if ding < nx_int(0) then
            ding = 0
          end
          if liang < nx_int(0) then
            liang = 0
          end
          if wen < nx_int(0) then
            wen = 0
          end
          local prize = ding * 1000000 + liang * 1000 + wen
          local tempprize = nx_string(skillname) .. "," .. nx_string(prize) .. "," .. nx_string(isShare)
          if prize_string == "" then
            prize_string = tempprize
          else
            prize_string = prize_string .. ";" .. tempprize
          end
        end
      end
      if rownum > 0 then
        nx_execute("custom_sender", "custom_set_life_skill_share", job_id, prize_string)
      end
    end
  elseif result == "nosave" then
    local temp_record_del
    while temp_record_head ~= temp_record_tail do
      temp_record_del = temp_record_head
      temp_record_head = temp_record_head.next
      temp_record_del = nil
    end
    temp_record_head = nil
    temp_record_tail = nil
    nx_execute("form_stage_main\\form_life\\form_job_composite", "change_share_set_open", job_id)
    form.Visible = false
    form:Close()
  end
end
function on_mousein_edit(edit)
  local form = edit.parentform
  local edt_ding = form:Find("edt_ding")
  local edt_liang = form:Find("edt_liang")
  local edt_wen = form:Find("edt_wen")
  edt_ding.LineColor = "255,0,0,0"
  edt_liang.LineColor = "255,0,0,0"
  edt_wen.LineColor = "255,0,0,0"
  edt_ding.Enabled = true
  edt_liang.Enabled = true
  edt_wen.Enabled = true
  edt_ding.ReadOnly = false
  edt_liang.ReadOnly = false
  edt_wen.ReadOnly = false
  edt_ding.BackImage = "gui\\common\\form_line\\ibox_2.png"
  edt_liang.BackImage = "gui\\common\\form_line\\ibox_2.png"
  edt_wen.BackImage = "gui\\common\\form_line\\ibox_2.png"
end
function on_mouseout_edit(edit)
  local groupbox = edit.groupbox
  local form = edit.parentform
  local edt_ding = form:Find("edt_ding")
  local edt_liang = form:Find("edt_liang")
  local edt_wen = form:Find("edt_wen")
  local ding = nx_int(edt_ding.Text)
  local liang = nx_int(edt_liang.Text)
  local wen = nx_int(edt_wen.Text)
  if ding < nx_int(0) then
    ding = 0
  end
  if liang < nx_int(0) then
    liang = 0
  end
  if wen < nx_int(0) then
    wen = 0
  end
  local Prize = ding * 1000000 + liang * 1000 + wen
  local cursor = temp_record_head
  while cursor do
    if cursor.formula == groupbox.index then
      cursor.prize = Prize
      break
    end
    cursor = cursor.next
  end
  edt_ding.LineColor = "0,0,0,0"
  edt_liang.LineColor = "0,0,0,0"
  edt_wen.LineColor = "0,0,0,0"
  edt_ding.Enabled = false
  edt_liang.Enabled = false
  edt_wen.Enabled = false
  edt_ding.ReadOnly = true
  edt_liang.ReadOnly = true
  edt_wen.ReadOnly = true
  edt_ding.BackImage = ""
  edt_liang.BackImage = ""
  edt_wen.BackImage = ""
end
function on_skill_mousein_edit(edit)
  local form = edit.parentform
  local edt_ding = form:Find("edt_ding")
  local edt_liang = form:Find("edt_liang")
  local edt_wen = form:Find("edt_wen")
  edt_ding.LineColor = "255,0,0,0"
  edt_liang.LineColor = "255,0,0,0"
  edt_wen.LineColor = "255,0,0,0"
  edt_ding.Enabled = true
  edt_liang.Enabled = true
  edt_wen.Enabled = true
  edt_ding.ReadOnly = false
  edt_liang.ReadOnly = false
  edt_wen.ReadOnly = false
  edt_ding.BackImage = "gui\\common\\form_line\\ibox_2.png"
  edt_liang.BackImage = "gui\\common\\form_line\\ibox_2.png"
  edt_wen.BackImage = "gui\\common\\form_line\\ibox_2.png"
end
function on_skill_mouseout_edit(edit)
  local form = edit.parentform
  local edt_ding = form:Find("edt_ding")
  local edt_liang = form:Find("edt_liang")
  local edt_wen = form:Find("edt_wen")
  edt_ding.LineColor = "0,0,0,0"
  edt_liang.LineColor = "0,0,0,0"
  edt_wen.LineColor = "0,0,0,0"
  edt_ding.Enabled = false
  edt_liang.Enabled = false
  edt_wen.Enabled = false
  edt_ding.ReadOnly = true
  edt_liang.ReadOnly = true
  edt_wen.ReadOnly = true
  edt_ding.BackImage = ""
  edt_liang.BackImage = ""
  edt_wen.BackImage = ""
end
function add_skill_share_info(form, groupbox_base, control_top)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return control_top
  end
  local recname = "job_skill_share_rec"
  local share_type = "skill"
  local rownum = client_player:GetRecordRows(recname)
  local rownum_display = 0
  for row = 1, rownum do
    local jobid = client_player:QueryRecord(recname, row - 1, 0)
    if nx_string(form.job_id) == nx_string(jobid) then
      rownum_display = rownum_display + 1
    end
  end
  if rownum_display == 0 or 2 < rownum_display then
    return control_top
  end
  local groupbox_skill = gui:Create("GroupBox")
  groupbox_base:Add(groupbox_skill)
  groupbox_skill.BackColor = "0,0,0,0"
  groupbox_skill.Left = 20
  groupbox_skill.Top = control_top
  groupbox_skill.Width = 400
  groupbox_skill.Height = 130
  groupbox_skill.DrawMode = "FitWindow"
  groupbox_skill.NoFrame = true
  groupbox_skill.Name = "groupbox_" .. share_type
  local groupbox_skill_list = gui:Create("GroupBox")
  groupbox_skill:Add(groupbox_skill_list)
  groupbox_skill_list.Name = "groupbox_" .. share_type .. "_list"
  groupbox_skill_list.BackColor = "0,0,0,0"
  groupbox_skill_list.Left = 0
  groupbox_skill_list.Top = 0
  groupbox_skill_list.Width = 400
  groupbox_skill_list.Height = 130
  groupbox_skill_list.BackImage = "gui\\common\\list\\bg_line.png"
  groupbox_skill_list.DrawMode = "Expand"
  local group_top = 4
  for row = 1, rownum do
    local jobid = client_player:QueryRecord(recname, row - 1, 0)
    if nx_string(form.job_id) == nx_string(jobid) then
      local skillname = client_player:QueryRecord(recname, row - 1, 1)
      local Prize = client_player:QueryRecord(recname, row - 1, 3)
      local isShare = client_player:QueryRecord(recname, row - 1, 4)
      local ding = math.floor(Prize / 1000000)
      local liang = math.floor(Prize % 1000000 / 1000)
      local wen = math.floor(Prize % 1000)
      local configid, photo, name = get_skill_display_info(form.job_id, skillname)
      local text_ding = nx_widestr("0")
      if 0 < ding then
        text_ding = nx_widestr(nx_int(ding))
      end
      local text_liang = nx_widestr("0")
      if 0 < liang then
        text_liang = nx_widestr(nx_int(liang))
      end
      local text_wen = nx_widestr("0")
      if 0 < wen then
        text_wen = nx_widestr(nx_int(wen))
      end
      local groupbox = gui:Create("GroupBox")
      groupbox_skill_list:Add(groupbox)
      groupbox.AutoSize = false
      groupbox.Name = "groupbox_info_" .. share_type .. nx_string(row)
      groupbox.BackColor = "0,0,0,0"
      groupbox.LineColor = "255,0,0,0"
      groupbox.DrawMode = "FitWindow"
      groupbox.BackImage = "gui\\common\\form_line\\form_sub.png"
      groupbox.DrawMode = "Expand"
      groupbox.NoFrame = true
      groupbox.Left = group_top
      groupbox.Top = 4
      groupbox.Width = 196
      groupbox.Height = 122
      groupbox.ding = text_ding
      groupbox.liang = text_liang
      groupbox.wen = text_wen
      local groupbox_prize = gui:Create("GroupBox")
      groupbox:Add(groupbox_prize)
      groupbox_prize.Name = "groupbox_prize"
      groupbox_prize.Left = 0
      groupbox_prize.Top = 90
      groupbox_prize.Width = 250
      groupbox_prize.Height = 30
      groupbox_prize.BackColor = "0,0,0,0"
      groupbox_prize.LineColor = "0,0,0,0"
      local edt_ding = gui:Create("Edit")
      groupbox_prize:Add(edt_ding)
      edt_ding.Name = "edt_ding"
      edt_ding.Text = text_ding
      edt_ding.Left = 0
      edt_ding.Top = 0
      edt_ding.Width = 70
      edt_ding.Height = 28
      edt_ding.ForeColor = "255,147,123,99"
      edt_ding.BackColor = "0,0,0,0"
      edt_ding.LineColor = "0,0,0,0"
      edt_ding.TextOffsetX = 8
      edt_ding.Align = "Center"
      edt_ding.OnlyDigit = true
      edt_ding.MaxDigit = 0
      edt_ding.MaxLength = 6
      edt_ding.DrawMode = "Expand"
      edt_ding.ReadOnly = true
      edt_ding.Font = "font_text_figure"
      edt_ding.parentform = groupbox_prize
      local lbl_ding = gui:Create("Label")
      groupbox_prize:Add(lbl_ding)
      lbl_ding.Name = "lbl_ding"
      lbl_ding.Left = 30
      lbl_ding.Top = 6
      lbl_ding.ForeColor = "255,95,67,37"
      lbl_ding.Font = "font_treeview"
      lbl_ding.ShadowColor = "255,255,255,255"
      lbl_ding.Width = 30
      lbl_ding.Text = nx_widestr(gui.TextManager:GetText("ui_ding"))
      local edt_liang = gui:Create("Edit")
      groupbox_prize:Add(edt_liang)
      edt_liang.Name = "edt_liang"
      edt_liang.Text = groupbox.liang
      edt_liang.Left = 60
      edt_liang.Top = 0
      edt_liang.Width = 40
      edt_liang.Height = 28
      edt_liang.ForeColor = "255,147,123,99"
      edt_liang.TextOffsetX = 8
      edt_liang.Align = "Center"
      edt_liang.OnlyDigit = true
      edt_liang.MaxDigit = 0
      edt_liang.MaxLength = 3
      edt_liang.DrawMode = "Expand"
      edt_liang.BackColor = "0,0,0,0"
      edt_liang.LineColor = "0,0,0,0"
      edt_liang.ReadOnly = true
      edt_liang.Font = "font_text_figure"
      edt_liang.parentform = groupbox_prize
      local lbl_liang = gui:Create("Label")
      groupbox_prize:Add(lbl_liang)
      lbl_liang.Name = "lbl_liang"
      lbl_liang.Left = 100
      lbl_liang.Top = 6
      lbl_liang.ForeColor = "255,95,67,37"
      lbl_liang.Font = "font_treeview"
      lbl_liang.ShadowColor = "255,255,255,255"
      lbl_liang.Width = 35
      lbl_liang.Text = nx_widestr(gui.TextManager:GetText("ui_liang"))
      local edt_wen = gui:Create("Edit")
      groupbox_prize:Add(edt_wen)
      edt_wen.Name = "edt_wen"
      edt_wen.Text = groupbox.wen
      edt_wen.Left = 135
      edt_wen.Top = 0
      edt_wen.Width = 30
      edt_wen.Height = 28
      edt_wen.ForeColor = "255,147,123,99"
      edt_wen.BackColor = "0,0,0,0"
      edt_wen.LineColor = "0,0,0,0"
      edt_wen.TextOffsetX = 8
      edt_wen.Align = "Center"
      edt_wen.OnlyDigit = true
      edt_wen.MaxDigit = 0
      edt_wen.MaxLength = 3
      edt_wen.DrawMode = "Expand"
      edt_wen.ReadOnly = true
      edt_wen.parentform = groupbox_prize
      edt_wen.Font = "font_text_figure"
      local lbl_wen = gui:Create("Label")
      groupbox_prize:Add(lbl_wen)
      lbl_wen.Name = "lbl_wen"
      lbl_wen.Left = 165
      lbl_wen.Top = 6
      lbl_wen.ForeColor = "255,95,67,37"
      lbl_wen.Font = "font_treeview"
      lbl_wen.ShadowColor = "255,255,255,255"
      lbl_wen.Width = 30
      lbl_wen.Text = nx_widestr(gui.TextManager:GetText("ui_wen"))
      nx_bind_script(edt_ding, nx_current())
      nx_callback(edt_ding, "on_get_capture", "on_skill_mousein_edit")
      nx_callback(edt_ding, "on_lost_capture", "on_skill_mouseout_edit")
      nx_bind_script(edt_liang, nx_current())
      nx_callback(edt_liang, "on_get_capture", "on_skill_mousein_edit")
      nx_callback(edt_liang, "on_lost_capture", "on_skill_mouseout_edit")
      nx_bind_script(edt_wen, nx_current())
      nx_callback(edt_wen, "on_get_capture", "on_skill_mousein_edit")
      nx_callback(edt_wen, "on_lost_capture", "on_skill_mouseout_edit")
      local imagegrid = gui:Create("ImageControlGrid")
      groupbox:Add(imagegrid)
      imagegrid.AutoSize = false
      imagegrid.Name = "ImageControlGrid_info_" .. share_type .. nx_string(row)
      imagegrid.DrawGridBack = "gui\\common\\imagegrid\\icon_item2.png"
      imagegrid.DrawMode = "Expand"
      imagegrid.NoFrame = true
      imagegrid.HasVScroll = false
      imagegrid.Width = 39
      imagegrid.Height = 39
      imagegrid.Left = 30
      imagegrid.Top = 20
      imagegrid.RowNum = 1
      imagegrid.ClomnNum = 1
      imagegrid.GridWidth = 36
      imagegrid.GridHeight = 36
      imagegrid.RoundGrid = false
      imagegrid.GridBackOffsetX = -4
      imagegrid.GridBackOffsetY = -3
      imagegrid.DrawMouseIn = "xuanzekuang"
      imagegrid.BackColor = "0,0,0,0"
      imagegrid.SelectColor = "0,0,0,0"
      imagegrid.MouseInColor = "0,0,0,0"
      imagegrid.CoverColor = "0,0,0,0"
      nx_bind_script(imagegrid, nx_current())
      nx_callback(imagegrid, "on_mousein_grid", "on_skill_imagegrid_mousein_grid")
      nx_callback(imagegrid, "on_mouseout_grid", "on_skill_imagegrid_mouseout_grid")
      imagegrid.HasMultiTextBox = true
      imagegrid.MultiTextBoxCount = 2
      imagegrid.MultiTextBox1.NoFrame = true
      imagegrid.MultiTextBox1.Width = 200
      imagegrid.MultiTextBox1.Height = 58
      imagegrid.MultiTextBox1.LineHeight = 20
      imagegrid.MultiTextBox1.ViewRect = "0,0,200,58"
      imagegrid.MultiTextBox1.TextColor = "255,255,255,255"
      imagegrid.Font = "FZHKJT20"
      imagegrid.MultiTextBoxPos = "60,-4"
      imagegrid.ViewRect = "0,0,67,67"
      imagegrid:AddItem(0, photo, "", 1, -1)
      imagegrid:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(configid))
      local skill_lbl = gui:Create("Label")
      groupbox:Add(skill_lbl)
      skill_lbl.Left = 80
      skill_lbl.Top = 30
      skill_lbl.Text = nx_widestr(name)
      skill_lbl.Font = "font_treeview"
      skill_lbl.ForeColor = "255,95,67,37"
      skill_lbl.ShadowColor = "255,255,255,255"
      local btn_share = gui:Create("CheckButton")
      groupbox:Add(btn_share)
      btn_share.Name = "btn_share_" .. share_type .. nx_string(row)
      btn_share.Left = 80
      btn_share.Top = 65
      btn_share.AutoSize = true
      btn_share.NormalImage = "gui\\common\\checkbutton\\cbtn_2_out.png"
      btn_share.FocusImage = "gui\\common\\checkbutton\\cbtn_2_on.png"
      btn_share.CheckedImage = "gui\\common\\checkbutton\\cbtn_2_down.png"
      if nx_string(isShare) == "0" then
        btn_share.Checked = false
      elseif nx_string(isShare) == "1" then
        btn_share.Checked = true
      end
      btn_share.NoFrame = true
      local lbl_btn_share = gui:Create("Label")
      groupbox:Add(lbl_btn_share)
      lbl_btn_share.Left = 100
      lbl_btn_share.Top = 63
      lbl_btn_share.Text = nx_widestr(gui.TextManager:GetText("ui_server4"))
      lbl_btn_share.Font = "font_main"
      lbl_btn_share.ForeColor = "255,95,67,37"
      lbl_btn_share.BackColor = "0,0,0,0"
      lbl_btn_share.LineColor = "255,0,0,0"
      lbl_btn_share.ShadowColor = "255,255,255,255"
      nx_bind_script(btn_share, nx_current())
      nx_callback(btn_share, "on_click", "on_check_click")
      group_top = group_top + 196
    end
  end
  if group_top == 200 then
    local groupbox = gui:Create("GroupBox")
    groupbox_skill_list:Add(groupbox)
    groupbox.AutoSize = false
    groupbox.Name = "groupbox_info_empty"
    groupbox.BackColor = "0,0,0,0"
    groupbox.LineColor = "255,0,0,0"
    groupbox.DrawMode = "FitWindow"
    groupbox.BackImage = "gui\\common\\form_line\\form_sub.png"
    groupbox.DrawMode = "Expand"
    groupbox.NoFrame = true
    groupbox.Left = group_top
    groupbox.Top = 4
    groupbox.Width = 196
    groupbox.Height = 122
    local groupbox_prize = gui:Create("GroupBox")
    groupbox:Add(groupbox_prize)
    groupbox_prize.Name = "groupbox_prize"
    groupbox_prize.Left = 0
    groupbox_prize.Top = 90
    groupbox_prize.Width = 250
    groupbox_prize.Height = 30
    groupbox_prize.BackColor = "0,0,0,0"
    groupbox_prize.LineColor = "0,0,0,0"
    local num_ding = gui:Create("Label")
    groupbox_prize:Add(num_ding)
    num_ding.Name = "num_ding"
    num_ding.Text = nx_widestr("0")
    num_ding.Left = 0
    num_ding.Top = 0
    num_ding.Width = 30
    num_ding.Height = 30
    num_ding.ForeColor = "255,147,123,99"
    num_ding.BackColor = "0,0,0,0"
    num_ding.LineColor = "0,0,0,0"
    num_ding.TextOffsetX = 8
    num_ding.Align = "Center"
    num_ding.OnlyDigit = true
    num_ding.MaxDigit = 0
    num_ding.MaxLength = 6
    num_ding.DrawMode = "Expand"
    num_ding.ReadOnly = true
    num_ding.Font = "font_text_figure"
    num_ding.parentform = groupbox_prize
    local lbl_ding = gui:Create("Label")
    groupbox_prize:Add(lbl_ding)
    lbl_ding.Name = "lbl_ding"
    lbl_ding.Left = 30
    lbl_ding.Top = 6
    lbl_ding.ForeColor = "255,95,67,37"
    lbl_ding.Font = "font_treeview"
    lbl_ding.ShadowColor = "255,255,255,255"
    lbl_ding.Width = 30
    lbl_ding.Text = nx_widestr(gui.TextManager:GetText("ui_ding"))
    local num_liang = gui:Create("Label")
    groupbox_prize:Add(num_liang)
    num_liang.Name = "num_liang"
    num_liang.Text = nx_widestr("0")
    num_liang.Left = 60
    num_liang.Top = 0
    num_liang.Width = 40
    num_liang.Height = 30
    num_liang.TextOffsetX = 8
    num_liang.Align = "Center"
    num_liang.OnlyDigit = true
    num_liang.MaxDigit = 0
    num_liang.MaxLength = 3
    num_liang.DrawMode = "Expand"
    num_liang.ForeColor = "255,147,123,99"
    num_liang.BackColor = "0,0,0,0"
    num_liang.LineColor = "0,0,0,0"
    num_liang.ReadOnly = true
    num_liang.Font = "font_text_figure"
    num_liang.parentform = groupbox_prize
    local lbl_liang = gui:Create("Label")
    groupbox_prize:Add(lbl_liang)
    lbl_liang.Name = "lbl_liang"
    lbl_liang.Left = 100
    lbl_liang.Top = 6
    lbl_liang.ForeColor = "255,95,67,37"
    lbl_liang.Font = "font_treeview"
    lbl_liang.ShadowColor = "255,255,255,255"
    lbl_liang.Width = 35
    lbl_liang.Text = nx_widestr(gui.TextManager:GetText("ui_liang"))
    local num_wen = gui:Create("Label")
    groupbox_prize:Add(num_wen)
    num_wen.Name = "num_wen"
    num_wen.Text = nx_widestr("0")
    num_wen.Left = 135
    num_wen.Top = 0
    num_wen.Width = 30
    num_wen.Height = 30
    num_wen.ForeColor = "255,147,123,99"
    num_wen.BackColor = "0,0,0,0"
    num_wen.LineColor = "0,0,0,0"
    num_wen.TextOffsetX = 8
    num_wen.Align = "Center"
    num_wen.OnlyDigit = true
    num_wen.MaxDigit = 0
    num_wen.MaxLength = 3
    num_wen.DrawMode = "Expand"
    num_wen.ReadOnly = true
    num_wen.Font = "font_text_figure"
    num_wen.parentform = groupbox_prize
    local lbl_wen = gui:Create("Label")
    groupbox_prize:Add(lbl_wen)
    lbl_wen.Name = "lbl_wen"
    lbl_wen.Left = 165
    lbl_wen.Top = 6
    lbl_wen.ForeColor = "255,95,67,37"
    lbl_wen.Font = "font_treeview"
    lbl_wen.ShadowColor = "255,255,255,255"
    lbl_wen.Width = 30
    lbl_wen.Text = nx_widestr(gui.TextManager:GetText("ui_wen"))
    local imagegrid = gui:Create("ImageControlGrid")
    groupbox:Add(imagegrid)
    imagegrid.AutoSize = false
    imagegrid.Name = "ImageControlGrid_info_" .. share_type .. nx_string(row)
    imagegrid.DrawGridBack = "gui\\common\\imagegrid\\icon_item2.png"
    imagegrid.DrawMode = "Expand"
    imagegrid.NoFrame = true
    imagegrid.HasVScroll = false
    imagegrid.Width = 39
    imagegrid.Height = 39
    imagegrid.Left = 30
    imagegrid.Top = 20
    imagegrid.RowNum = 1
    imagegrid.ClomnNum = 1
    imagegrid.GridWidth = 36
    imagegrid.GridHeight = 36
    imagegrid.RoundGrid = false
    imagegrid.GridBackOffsetX = -4
    imagegrid.GridBackOffsetY = -3
    imagegrid.DrawMouseIn = "xuanzekuang"
    imagegrid.BackColor = "0,0,0,0"
    imagegrid.SelectColor = "0,0,0,0"
    imagegrid.MouseInColor = "0,0,0,0"
    imagegrid.CoverColor = "0,0,0,0"
    imagegrid.HasMultiTextBox = true
    imagegrid.MultiTextBoxCount = 2
    imagegrid.MultiTextBox1.NoFrame = true
    imagegrid.MultiTextBox1.Width = 200
    imagegrid.MultiTextBox1.Height = 58
    imagegrid.MultiTextBox1.LineHeight = 20
    imagegrid.MultiTextBox1.ViewRect = "0,0,200,58"
    imagegrid.MultiTextBox1.TextColor = "255,255,255,255"
    imagegrid.Font = "FZHKJT20"
    imagegrid.MultiTextBoxPos = "60,-4"
    imagegrid.ViewRect = "0,0,67,67"
    local btn_share = gui:Create("CheckButton")
    groupbox:Add(btn_share)
    btn_share.Name = "btn_share_" .. share_type .. nx_string(row)
    btn_share.Left = 80
    btn_share.Top = 65
    btn_share.AutoSize = true
    btn_share.NormalImage = "gui\\common\\checkbutton\\cbtn_2_forbid.png"
    btn_share.FocusImage = "gui\\common\\checkbutton\\cbtn_2_forbid.png"
    btn_share.CheckedImage = "gui\\common\\checkbutton\\cbtn_2_forbid.png"
    if nx_string(isShare) == "0" then
      btn_share.Checked = false
    elseif nx_string(isShare) == "1" then
      btn_share.Checked = true
    end
    btn_share.NoFrame = true
    local lbl_btn_share = gui:Create("Label")
    groupbox:Add(lbl_btn_share)
    lbl_btn_share.Left = 100
    lbl_btn_share.Top = 63
    lbl_btn_share.Text = nx_widestr(gui.TextManager:GetText("ui_server4"))
    lbl_btn_share.Font = "font_main"
    lbl_btn_share.ForeColor = "255,95,67,37"
    lbl_btn_share.BackColor = "0,0,0,0"
    lbl_btn_share.LineColor = "255,0,0,0"
    lbl_btn_share.ShadowColor = "255,255,255,255"
  end
  local groupbox_lbl_skill = gui:Create("GroupBox")
  groupbox_base:Add(groupbox_lbl_skill)
  groupbox_lbl_skill.Left = 130
  groupbox_lbl_skill.Top = 18
  groupbox_lbl_skill.Width = 180
  groupbox_lbl_skill.Height = 25
  groupbox_lbl_skill.BackImage = "gui\\common\\form_back\\bg_title.png"
  groupbox_lbl_skill.DrawMode = "Expand"
  local lbl_skill = gui:Create("Label")
  groupbox_lbl_skill:Add(lbl_skill)
  lbl_skill.Left = 55
  lbl_skill.Top = 5
  lbl_skill.Font = "font_text_title1"
  lbl_skill.ForeColor = "255,76,61,44"
  lbl_skill.Align = "Center"
  lbl_skill.Text = nx_widestr(gui.TextManager:GetText("ui_server2"))
  control_top = control_top + groupbox_skill.Height + 35
  return control_top
end
function on_check_click(self)
  if self.Checked == true then
    self.Checked = false
  else
    self.Checked = true
  end
end
function on_btn_close_click(self)
  local gui = nx_value("gui")
  local form = self.ParentForm
  save_config(form, "nosave")
end
function on_btn_select_click(btn)
  local form_compose = btn.groupbox
  form_compose.curindex = btn.index
  if form_compose.selected ~= nil then
    form_compose.selected.BackImage = ""
  end
  form_compose.selected = btn
  btn.BackImage = "gui\\common\\combobox\\bg_select3.png"
end
function on_btn_del_click(btn)
  local form = btn.groupbox
  if form.job_id == nil or nx_string(form.job_id) == "" then
    return
  end
  if form.curindex == nil then
    return
  end
  local cursor = temp_record_head
  if cursor.formula == form.curindex then
    temp_record_head = cursor.next
    if cursor == temp_record_tail then
      temp_record_tail = nil
    end
    cursor = nil
  else
    while cursor.next do
      if cursor.next.formula == form.curindex then
        cursor_del = cursor.next
        cursor.next = cursor_del.next
        if cursor_del == temp_record_tail then
          temp_record_tail = cursor
        end
        cursor_del = nil
        break
      end
      cursor = cursor.next
    end
  end
  form_refresh(form.job_id)
end
function on_btn_del_all_click(btn)
  local form = btn.ParentForm
  if form.job_id == nil or nx_string(form.job_id) == "" then
    return
  end
  temp_record_head = nil
  temp_record_tail = nil
  form_refresh(form.job_id)
end
function on_imagegrid_mousein_grid(grid, index)
  local item_config = nx_string(grid:GetItemAddText(index, nx_int(1)))
  if item_config == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if bExist == false then
    return
  end
  local item_name = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Name"))
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
  local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
  local hardiness = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Hardiness"))
  local prop_array = {}
  prop_array.ConfigID = nx_string(item_config)
  prop_array.ItemType = nx_int(item_type)
  prop_array.SellPrice1 = nx_int(item_sellPrice1)
  prop_array.Photo = nx_string(photo)
  prop_array.Hardiness = nx_int(hardiness)
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList", nx_current())
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_skill_imagegrid_mousein_grid(grid, index)
  local skill_configID = nx_string(grid:GetItemAddText(index, nx_int(1)))
  local gui = nx_value("gui")
  if skill_configID == nil or nx_string(skill_configID) == "" then
    return
  end
  local skill_name = gui.TextManager:GetText("ui_" .. nx_string(skill_configID))
  local des_info = gui.TextManager:GetText("desc_" .. nx_string(skill_configID))
  local info_val = nx_widestr(skill_name) .. nx_widestr("<br>") .. nx_widestr(des_info)
  nx_execute("tips_game", "show_text_tip", info_val, grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
end
function on_skill_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_job_tj_share_set_refresh(form, recordname, optype, row, clomn)
  if form.job_id == nil or nx_string(form.job_id) == "" then
    return
  end
  if nx_string(form.job_id) ~= "sh_tj" then
    return
  end
  fresh_info(form)
end
function on_job_ds_share_set_refresh(form, recordname, optype, row, clomn)
  if form.job_id == nil or nx_string(form.job_id) == "" then
    return
  end
  if nx_string(form.job_id) ~= "sh_ds" then
    return
  end
  fresh_info(form)
end
function on_job_ys_share_set_refresh(form, recordname, optype, row, clomn)
  if form.job_id == nil or nx_string(form.job_id) == "" then
    return
  end
  if nx_string(form.job_id) ~= "sh_ys" then
    return
  end
  fresh_info(form)
end
function on_job_cf_share_set_refresh(form, recordname, optype, row, clomn)
  if form.job_id == nil or nx_string(form.job_id) == "" then
    return
  end
  if nx_string(form.job_id) ~= "sh_cf" then
    return
  end
  fresh_info(form)
end
function on_job_cs_share_set_refresh(form, recordname, optype, row, clomn)
  if form.job_id == nil or nx_string(form.job_id) == "" then
    return
  end
  if nx_string(form.job_id) ~= "sh_cs" then
    return
  end
  fresh_info(form)
end
function on_job_jq_share_set_refresh(form, recordname, optype, row, clomn)
  if form.job_id == nil or nx_string(form.job_id) == "" then
    return
  end
  if nx_string(form.job_id) ~= "sh_jq" then
    return
  end
  fresh_info(form)
end
function on_job_gs_share_set_refresh(form, recordname, optype, row, clomn)
  if form.job_id == nil or nx_string(form.job_id) == "" then
    return
  end
  if nx_string(form.job_id) ~= "sh_gs" then
    return
  end
  fresh_info(form)
end
function on_job_skill_share_set_refresh(form, recordname, optype, row, clomn)
  fresh_info(form)
end
function get_info_by_formula(formula_id)
  local gui = nx_value("gui")
  local iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  local sec_item_index = iniformula:FindSectionIndex(formula_id)
  if sec_item_index < 0 then
    nx_log("share\\Item\\life_formula.ini sec_index= " .. nx_string(formula_id))
    return "", "", ""
  end
  local porduct_item = iniformula:ReadString(sec_item_index, "ComposeResult", "")
  local ItemQuery = nx_value("ItemQuery")
  local item_type = nx_number(ItemQuery:GetItemPropByConfigID(nx_string(porduct_item), "ItemType"))
  local photo = ""
  if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(porduct_item), "Photo")
  else
    photo = ItemQuery:GetItemPropByConfigID(nx_string(porduct_item), "Photo")
  end
  local name = gui.TextManager:GetFormatText(nx_string(porduct_item))
  return porduct_item, photo, name
end
function open_form_job(job_id, add_formula_id)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local form = util_get_form("form_stage_main\\form_life\\form_job_share_set", true)
  if not nx_is_valid(form) then
    return
  end
  form.job_id = job_id
  temp_record_head = nil
  temp_record_tail = nil
  local recname = nx_string(form.job_id) .. "_share_rec"
  local rownum = client_player:GetRecordRows(recname)
  for row = 1, rownum do
    local formula_id = client_player:QueryRecord(recname, row - 1, 0)
    local Prize = client_player:QueryRecord(recname, row - 1, 1)
    if temp_record_head == nil then
      temp_record_head = {
        next = nil,
        formula = formula_id,
        prize = Prize
      }
      temp_record_tail = temp_record_head
    else
      temp_record_tail.next = {
        next = nil,
        formula = formula_id,
        prize = Prize
      }
      temp_record_tail = temp_record_tail.next
    end
  end
  local isallowadd = true
  if add_formula_id ~= nil then
    local formula_found = false
    local cursor = temp_record_head
    local formula_num = 0
    while cursor do
      if cursor.formula == add_formula_id then
        formula_found = true
        break
      end
      formula_num = formula_num + 1
      cursor = cursor.next
    end
    local job_lvl = nx_execute("form_stage_main\\form_life\\form_job_main_new", "get_job_level", job_id)
    local nLimite
    if job_id == "sh_cs" then
      nLimite = job_lvl * 3
    else
      nLimite = job_lvl
    end
    if formula_num < nLimite then
      if formula_found == true then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "12804")
        isallowadd = false
      else
        if temp_record_tail == nil then
          temp_record_head = {
            next = nil,
            formula = add_formula_id,
            prize = 0
          }
          temp_record_tail = temp_record_head
        else
          temp_record_tail.next = {
            next = nil,
            formula = add_formula_id,
            prize = 0
          }
          temp_record_tail = temp_record_tail.next
        end
        isallowadd = true
      end
    else
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "12820", nLimite)
      isallowadd = false
    end
  end
  if not isallowadd then
    save_config(form, "nosave")
    return
  end
  util_auto_show_hide_form("form_stage_main\\form_life\\form_job_share_set")
end
function close_form_job(job_id)
  local form = util_get_form("form_stage_main\\form_life\\form_job_share_set", true)
  if not nx_is_valid(form) then
    return
  end
  form.job_id = job_id
  on_btn_close_click(form)
end
function add_temp_formula_id(job_id, formula_id)
  local form = util_get_form("form_stage_main\\form_life\\form_job_share_set", true)
  local formula_found = false
  local formula_num = 0
  local cursor = temp_record_head
  while cursor do
    if cursor.formula == formula_id then
      formula_found = true
      break
    end
    formula_num = formula_num + 1
    cursor = cursor.next
  end
  local job_lvl = nx_execute("form_stage_main\\form_life\\form_job_main_new", "get_job_level", job_id)
  local nLimite
  if job_id == "sh_cs" then
    nLimite = job_lvl * 3
  else
    nLimite = job_lvl
  end
  if formula_num < nLimite then
    if formula_found == true then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "12804")
    elseif temp_record_tail == nil then
      temp_record_head = {
        next = nil,
        formula = formula_id,
        prize = 0
      }
      temp_record_tail = temp_record_head
    else
      temp_record_tail.next = {
        next = nil,
        formula = formula_id,
        prize = 0
      }
      temp_record_tail = temp_record_tail.next
    end
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "12820", nLimite)
  end
end
function form_refresh(job_id)
  local form = util_get_form("form_stage_main\\form_life\\form_job_share_set", true)
  if not nx_is_valid(form) then
    return
  end
  form.job_id = job_id
  fresh_info(form)
end
function get_item_info(configid, prop)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
function get_fortune_info_by_jobid(index)
  local job_info_ini = nx_execute("util_functions", "get_ini", "share\\Life\\job_info.ini")
  local gather_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\job_gather_prop.ini")
  if not nx_is_valid(gather_ini) then
    return
  end
  if not nx_is_valid(job_info_ini) then
    return
  end
  local sec_index = job_info_ini:FindSectionIndex("sh_gs")
  if sec_index < 0 then
    nx_log("share\\Life\\job_info.ini sec_index= " .. nx_string("sh_gs"))
    return
  end
  local gather_info = job_info_ini:ReadString(sec_index, "gather", "")
  if nx_string(gather_info) == "" then
    return
  end
  local gather_sec_index = gather_ini:FindSectionIndex(nx_string(gather_info))
  if gather_sec_index < 0 then
    nx_log("ini\\ui\\life\\job_gather_prop.ini sec_index= " .. nx_string(gather_info))
    return
  end
  local item_str = gather_ini:ReadString(gather_sec_index, nx_string(index), "")
  local node_info = util_split_string(item_str, "/")
  if table.getn(node_info) ~= 3 then
    return
  end
  local node_name = nx_string(node_info[1])
  local node_item_str = nx_string(node_info[3])
  local node_itme_table = util_split_string(node_item_str, ",")
  local photo = get_item_info(node_itme_table[1], "photo")
  local gui = nx_value("gui")
  local name = gui.TextManager:GetFormatText(nx_string(node_name))
  return node_name, photo, name
end
