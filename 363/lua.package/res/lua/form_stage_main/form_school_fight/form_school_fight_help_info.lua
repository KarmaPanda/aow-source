require("util_functions")
require("util_gui")
local form_name = "form_stage_main\\form_school_fight\\form_school_fight_help_info"
local school_name = {
  [5] = "school_jinyiwei",
  [6] = "school_gaibang",
  [7] = "school_junzitang",
  [8] = "school_jilegu",
  [9] = "school_tangmen",
  [10] = "school_emei",
  [11] = "school_wudang",
  [12] = "school_shaolin",
  [769] = "school_mingjiao",
  [832] = "school_tianshan"
}
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.select_index = 1
  self.lbl_back.Visible = false
  self.lbl_waiting.Visible = false
  self.mltbox_help.HtmlText = gui.TextManager:GetText("desc_schoolwar_yuanzhushuoming")
end
function on_main_form_close(self)
  if nx_find_custom(self, "data_rec") and nx_is_valid(self.data_rec) then
    self.data_rec:ClearChild()
    nx_destroy(self.data_rec)
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", self)
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function create_select_radio_button(form, rbtn_num)
  if not nx_is_valid(form) then
    return
  end
  if nx_number(rbtn_num) == 0 then
    return
  end
  local gui = nx_value("gui")
  for i = 1, rbtn_num do
    local rbtn = gui:Create("RadioButton")
    rbtn.name = "number" .. nx_string(i)
    rbtn.Left = 106 * (i - 1) + 4
    rbtn.Top = 1
    rbtn.Width = 105
    rbtn.Height = 33
    rbtn.CheckedImage = nx_string("gui\\common\\checkbutton\\rbtn_top_down.png")
    rbtn.NormalImage = nx_string("gui\\common\\checkbutton\\rbtn_top_out.png")
    rbtn.FocusImage = nx_string("gui\\common\\checkbutton\\rbtn_top_on.png")
    rbtn.DrawMode = "Expand"
    rbtn.AutoSize = "True"
    rbtn.Font = "font_tip"
    rbtn.ForeColor = "255,255,255,255"
    rbtn.Text = nx_widestr(gui.TextManager:GetText("ui_match_" .. nx_string(i)))
    rbtn.DataSource = nx_string(i)
    nx_bind_script(rbtn, nx_current())
    nx_callback(rbtn, "on_checked_changed", "on_rbtn_checked_changed")
    form.groupbox_1:Add(rbtn)
    if nx_number(form.select_index) == nx_number(i) then
      rbtn.Checked = true
    end
  end
end
function save_date(form, ...)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local arg_num = table.getn(arg)
  if nx_number(arg_num) == 0 then
    return
  end
  local arg_index = 1
  local total_num = nx_number(arg[arg_index])
  if total_num == 0 then
    return
  end
  for i = 1, total_num * 2 do
    local school_id = nx_number(arg[arg_index + 1])
    local custom_name = "index_school_" .. nx_string(i)
    nx_set_custom(form, nx_string(custom_name), nx_number(school_id))
    arg_index = arg_index + 1
  end
  arg_index = arg_index + 1
  local col = nx_number(arg[arg_index])
  local item_num = math.floor((arg_num - arg_index) / col)
  if nx_number(item_num) > 0 and (not nx_find_custom(form, "data_rec") or not nx_is_valid(form.data_rec)) then
    form.data_rec = nx_call("util_gui", "get_arraylist", "schoolhelplist")
  end
  for j = 1, nx_number(item_num) do
    local name = nx_widestr(arg[arg_index + 1])
    local schoolid = nx_number(arg[arg_index + 2])
    local fightindex = nx_number(arg[arg_index + 3])
    local side = nx_number(arg[arg_index + 4])
    local state = nx_number(arg[arg_index + 5])
    local child = form.data_rec:GetChild(nx_string(j))
    if not nx_is_valid(child) then
      child = form.data_rec:CreateChild(nx_string(j))
    end
    child.fightindex = fightindex
    child.playername = name
    child.schoolid = schoolid
    child.side = side
    child.state = state
    arg_index = arg_index + col
  end
  create_select_radio_button(form, total_num)
end
function refresh_form(form, index)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gui = nx_value("gui")
  if not nx_is_valid(client_player) then
    return
  end
  local playerschool = nx_string(client_player:QueryProp("School"))
  local main_attack = false
  local main_defend = false
  form.btn_help_att.Enabled = true
  form.btn_help_def.Enabled = true
  form.lbl_attack_name.Text = nx_widestr("")
  form.lbl_defend_name.Text = nx_widestr("")
  form.lbl_back.Visible = false
  form.lbl_waiting.Visible = false
  local temp = 2 * (index - 1) + 1
  local custom_name = "index_school_" .. nx_string(temp)
  local attschoolid = 0
  local defschoolid = 0
  if nx_find_custom(form, nx_string(custom_name)) then
    attschoolid = nx_number(nx_custom(form, nx_string(custom_name)))
    local text = gui.TextManager:GetText(nx_string(school_name[attschoolid]))
    if nx_string(school_name[attschoolid]) == playerschool then
      main_attack = true
    end
    form.lbl_attack_name.Text = nx_widestr(text)
  end
  temp = temp + 1
  custom_name = "index_school_" .. nx_string(temp)
  if nx_find_custom(form, nx_string(custom_name)) then
    defschoolid = nx_number(nx_custom(form, nx_string(custom_name)))
    local text = gui.TextManager:GetText(nx_string(school_name[defschoolid]))
    if nx_string(school_name[defschoolid]) == playerschool then
      main_defend = true
    end
    form.lbl_defend_name.Text = nx_widestr(text)
  end
  if attschoolid == 0 or defschoolid == 0 or nx_string(school_name[attschoolid]) == playerschool or nx_string(school_name[defschoolid]) == playerschool then
    form.btn_help_att.Enabled = false
    form.btn_help_def.Enabled = false
  end
  form.groupbox_3:DeleteAll()
  if not nx_find_custom(form, "data_rec") or not nx_is_valid(form.data_rec) then
    return
  end
  local base_top = 6
  local base_left = {
    [1] = {
      272,
      336,
      424,
      480,
      416
    },
    [2] = {
      0,
      64,
      152,
      208,
      146
    }
  }
  local lab_width = 60
  local lab_height = 16
  local btn_width = 54
  local btn_height = 30
  local inc_top = 40
  local att_num = 0
  local def_num = 0
  for i = 1, form.data_rec:GetChildCount() do
    local child = form.data_rec:GetChildByIndex(i - 1)
    if nx_number(child.fightindex) == nx_number(index) then
      local side = nx_number(child.side)
      local tmptop = base_top
      if side == 1 then
        tmptop = tmptop + inc_top * def_num
      else
        tmptop = tmptop + inc_top * att_num
      end
      local tmpleft = base_left[side]
      local schoolid = nx_number(child.schoolid)
      local lab = gui:Create("Label")
      form.groupbox_3:Add(lab)
      lab.Left = nx_number(tmpleft[1])
      lab.Top = tmptop + 8
      lab.Width = lab_width
      lab.Height = lab_height
      lab.ForeColor = "255,128,101,74"
      lab.Font = "font_text"
      lab.Align = "Center"
      lab.Text = nx_widestr(gui.TextManager:GetText(nx_string(school_name[schoolid])))
      lab = gui:Create("Label")
      form.groupbox_3:Add(lab)
      lab.Left = nx_number(tmpleft[2])
      lab.Top = tmptop + 8
      lab.Width = lab_width
      lab.Height = lab_height
      lab.ForeColor = "255,128,101,74"
      lab.Font = "font_text"
      lab.Align = "Center"
      lab.Text = nx_widestr(child.playername)
      local state = nx_number(child.state)
      if state == 0 then
        local btn_accept = gui:Create("Button")
        form.groupbox_3:Add(btn_accept)
        btn_accept.Name = "btn_accept" .. nx_string(i)
        btn_accept.Left = nx_number(tmpleft[3])
        btn_accept.Top = tmptop
        btn_accept.Width = btn_width
        btn_accept.Height = btn_height
        btn_accept.NormalImage = "gui\\common\\button\\btn_normal2_out.png"
        btn_accept.FocusImage = "gui\\common\\button\\btn_normal2_on.png"
        btn_accept.PushImage = "gui\\common\\button\\btn_normal2_down.png"
        btn_accept.DrawMode = "Expand"
        btn_accept.Font = "font_tip"
        btn_accept.ForeColor = "255,255,255,255"
        btn_accept.Text = nx_widestr(gui.TextManager:GetText("ui_accept"))
        btn_accept.DisableEnter = true
        nx_bind_script(btn_accept, nx_current())
        nx_callback(btn_accept, "on_click", "on_btn_accept_click")
        btn_accept.Enabled = false
        btn_accept.schoolid = schoolid
        btn_accept.fightindex = index
        btn_accept.side = side
        btn_accept.order = i - 1
        local btn_refuse = gui:Create("Button")
        form.groupbox_3:Add(btn_refuse)
        btn_refuse.Name = "btn_refuse" .. nx_string(i)
        btn_refuse.Left = nx_number(tmpleft[4])
        btn_refuse.Top = tmptop
        btn_refuse.Width = btn_width
        btn_refuse.Height = btn_height
        btn_refuse.NormalImage = "gui\\common\\button\\btn_normal2_out.png"
        btn_refuse.FocusImage = "gui\\common\\button\\btn_normal2_on.png"
        btn_refuse.PushImage = "gui\\common\\button\\btn_normal2_down.png"
        btn_refuse.DrawMode = "Expand"
        btn_refuse.Font = "font_tip"
        btn_refuse.ForeColor = "255,255,255,255"
        btn_refuse.Text = nx_widestr(gui.TextManager:GetText("ui_refuse"))
        btn_refuse.DisableEnter = true
        nx_bind_script(btn_refuse, nx_current())
        nx_callback(btn_refuse, "on_click", "on_btn_refuse_click")
        btn_refuse.Enabled = false
        btn_refuse.schoolid = schoolid
        btn_refuse.fightindex = index
        btn_refuse.side = side
        btn_refuse.order = i - 1
        if side == 1 and main_defend or side == 2 and main_attack then
          btn_accept.Enabled = true
          btn_refuse.Enabled = true
        end
      else
        local state_desc = {"ui_accept", "ui_refuse"}
        lab = gui:Create("Label")
        form.groupbox_3:Add(lab)
        lab.Left = nx_number(tmpleft[5])
        lab.Top = tmptop + 8
        lab.Width = lab_width
        lab.Height = lab_height
        lab.ForeColor = "255,128,101,74"
        lab.Font = "font_text"
        lab.Align = "Center"
        lab.Text = nx_widestr(gui.TextManager:GetText(nx_string(state_desc[state])))
      end
      if side == 1 then
        def_num = def_num + 1
      else
        att_num = att_num + 1
      end
      if nx_string(school_name[schoolid]) == playerschool then
        form.btn_help_att.Enabled = false
        form.btn_help_def.Enabled = false
      end
    end
  end
end
function open_form(...)
  local form = nx_execute("util_gui", "util_get_form", form_name, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  save_date(form, unpack(arg))
  refresh_form(form, nx_number(form.select_index))
end
function on_update_time(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", form)
  end
  request_schoolhelp_info()
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.select_index = nx_number(rbtn.DataSource)
    refresh_form(form, nx_number(rbtn.DataSource))
  end
end
function on_btn_accept_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "data_rec") or not nx_is_valid(form.data_rec) then
    return
  end
  local index = nx_number(btn.order)
  if index < 0 or index >= form.data_rec:GetChildCount() then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", form)
    timer:Register(3000, -1, nx_current(), "on_update_time", form, -1, -1)
    form.lbl_back.Visible = true
    form.lbl_waiting.Visible = true
  end
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 4, nx_number(btn.fightindex), nx_number(btn.side), nx_number(btn.schoolid), 1)
end
function on_btn_refuse_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "data_rec") or not nx_is_valid(form.data_rec) then
    return
  end
  local index = nx_number(btn.order)
  if index < 0 or index >= form.data_rec:GetChildCount() then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", form)
    timer:Register(3000, -1, nx_current(), "on_update_time", form, -1, -1)
    form.lbl_back.Visible = true
    form.lbl_waiting.Visible = true
  end
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 4, nx_number(btn.fightindex), nx_number(btn.side), nx_number(btn.schoolid), 2)
end
function on_btn_help_att_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("ui_askfor_1"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" and nx_is_valid(form) and nx_find_custom(form, "select_index") then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 3, nx_number(form.select_index), 2)
  end
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_help_def_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("ui_askfor_2"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" and nx_is_valid(form) and nx_find_custom(form, "select_index") then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 3, nx_number(form.select_index), 1)
  end
  if nx_is_valid(form) then
    form:Close()
  end
end
function isschoolleader()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local row = client_player:GetRecordRows("SchoolPoseRec")
  if nx_int(row) < nx_int(0) then
    return false
  end
  local player_name = client_player:QueryProp("Name")
  for i = 0, row - 1 do
    local posindex = client_player:QueryRecord("SchoolPoseRec", i, 0)
    local poseuser = client_player:QueryRecord("SchoolPoseRec", i, 1)
    local tmpindex = math.floor(math.fmod(posindex, 100) / 10)
    if nx_number(tmpindex) == 1 and nx_ws_equal(nx_widestr(player_name), nx_widestr(poseuser)) then
      return true
    end
  end
  return false
end
function request_schoolhelp_info()
  if not isschoolleader() then
    return
  end
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 5)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_cbtn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.groupbox_help) then
    return
  end
  if form.groupbox_help.Visible then
    form.groupbox_help.Visible = false
    form.Width = form.Width - form.groupbox_help.Width
  else
    form.groupbox_help.Visible = true
    form.Width = form.Width + form.groupbox_help.Width
  end
end
function on_btn_help_quit_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_help.Visible = false
  form.Width = form.Width - form.groupbox_help.Width
end
