require("custom_sender")
require("util_functions")
require("util_gui")
require("define\\sysinfo_define")
SERVER_MSG_CHALLENGE_ENTER = 0
SERVER_MSG_CHALLENGE_NOTE = 1
SERVER_MSG_CHALLENGE_FIGHT = 2
SERVER_MSG_CHALLENGE_CLOSE = 3
CLIENT_MSG_CHALLENGE_FIGHT = 0
CLIENT_MSG_CHALLENGE_LEAVE = 1
CLIENT_MSG_CHALLENGE_GAVEUP = 2
function main_form_init(self)
  self.Fixed = false
  self.cur_select = nil
  self.npc_num = 0
  self.fial_num = 0
  self.in_fighting = 0
end
function on_main_form_open(self)
  self.gbox_challenge.Visible = false
  self.gsbox_all_info.IsEditMode = false
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_challenge_begin_click(btn)
  local form = btn.ParentForm
  if form.cur_select == nil then
    system_info("30387")
    return
  end
  custom_tiguanchallenge(CLIENT_MSG_CHALLENGE_FIGHT, form.cur_select.npc_index)
end
function on_btn_challenge_gaveup_click(btn)
  local form = btn.ParentForm
  if form.in_fighting == 1 then
    custom_tiguanchallenge(CLIENT_MSG_CHALLENGE_GAVEUP)
  end
end
function init_challenge_data(form, guan_id)
  form.fial_num = 0
  form.in_fighting = 0
  for i = 0, form.npc_num do
    local gbox = form.gsbox_all_info:Find(get_control_name(form.gbox_challenge, i))
    if nx_is_valid(gbox) then
      gbox.challenge_state = 0
      local lbl_name = gbox:Find(get_control_name(form.lbl_player_name, npc_index))
      if nx_is_valid(lbl_name) then
        lbl_name.Text = nx_widestr("")
      end
    end
  end
end
function init_challenge_trace(form, guan_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ini = get_ini("ini\\ui\\tiguan\\tiguan_challenge.ini")
  if not nx_is_valid(ini) then
    return
  end
  local challenge_school = ini:ReadString(nx_string(guan_id), "ChallegeSchool", "")
  local npc_list = ini:ReadString(nx_string(guan_id), "BossList", "")
  local school_list = ini:ReadString(nx_string(guan_id), "SchoolList", "")
  if npc_list == "" or school_list == "" then
    return
  end
  local tab_npc = util_split_string(npc_list, ";")
  local tab_school = util_split_string(school_list, ";")
  local npc_count = table.getn(tab_npc)
  local school_count = table.getn(tab_school)
  form.npc_num = nx_number(npc_count)
  for i = 0, nx_number(npc_count) - 1 do
    local npc_id = nx_string(tab_npc[i + 1])
    local school_id = ""
    if i < school_count then
      school_id = nx_string(tab_school[i + 1])
    end
    local gbox_challenge = copy_gbox(gui, i, form.gbox_challenge)
    if nx_is_valid(gbox_challenge) then
      local lbl_back_ground = copy_lbl(gui, i, form.lbl_back_ground)
      if nx_is_valid(lbl_back_ground) then
        gbox_challenge:Add(lbl_back_ground)
      end
      local cbtn_select = copy_cbtn(gui, i, form.cbtn_select)
      if nx_is_valid(cbtn_select) then
        gbox_challenge:Add(cbtn_select)
        cbtn_select.npc_index = i
        nx_bind_script(cbtn_select, nx_current())
        nx_callback(cbtn_select, "on_checked_changed", "on_cbtn_select_checked_changed")
      end
      local lbl_npc_school = copy_lbl(gui, i, form.lbl_npc_school)
      if nx_is_valid(lbl_npc_school) then
        gbox_challenge:Add(lbl_npc_school)
        lbl_npc_school.Text = gui.TextManager:GetText(school_id)
      end
      local lbl_npc_name = copy_lbl(gui, i, form.lbl_npc_name)
      if nx_is_valid(lbl_npc_name) then
        gbox_challenge:Add(lbl_npc_name)
        lbl_npc_name.Text = gui.TextManager:GetText(npc_id)
      end
      local lbl_player_school = copy_lbl(gui, i, form.lbl_player_school)
      if nx_is_valid(lbl_player_school) then
        gbox_challenge:Add(lbl_player_school)
        lbl_player_school.Text = gui.TextManager:GetText(challenge_school)
      end
      local lbl_player_name = copy_lbl(gui, i, form.lbl_player_name)
      if nx_is_valid(lbl_player_name) then
        gbox_challenge:Add(lbl_player_name)
      end
      local lbl_state = copy_lbl(gui, i, form.lbl_state)
      if nx_is_valid(lbl_state) then
        gbox_challenge:Add(lbl_state)
      end
      form.gsbox_all_info:Add(gbox_challenge)
    end
  end
end
function on_cbtn_select_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    if form.cur_select ~= nil and nx_is_valid(form.cur_select) then
      form.cur_select.Checked = false
    end
    form.cur_select = cbtn
  else
    form.cur_select = nil
  end
end
function copy_gbox(gui, index, gbox)
  local new_gbox = gui:Create("GroupBox")
  if not nx_is_valid(new_gbox) then
    return nil
  end
  local form = gbox.ParentForm
  new_gbox.Name = get_control_name(gbox, index)
  new_gbox.Left = 8
  new_gbox.Top = 8 + gbox.Height * index + 4 * index
  new_gbox.Width = gbox.Width
  new_gbox.Height = gbox.Height
  new_gbox.ForeColor = gbox.ForeColor
  new_gbox.BackColor = gbox.BackColor
  new_gbox.LineColor = gbox.LineColor
  new_gbox.NoFrame = gbox.NoFrame
  new_gbox.AutoSize = gbox.AutoSize
  new_gbox.DrawMode = gbox.DrawMode
  new_gbox.BackImage = gbox.BackImage
  return new_gbox
end
function copy_cbtn(gui, index, cbtn)
  local new_cbtn = gui:Create("CheckButton")
  if not nx_is_valid(new_cbtn) then
    return nil
  end
  new_cbtn.Name = get_control_name(cbtn, index)
  new_cbtn.Left = cbtn.Left
  new_cbtn.Top = cbtn.Top
  new_cbtn.Width = cbtn.Width
  new_cbtn.Height = cbtn.Height
  new_cbtn.ForeColor = cbtn.ForeColor
  new_cbtn.BackColor = cbtn.BackColor
  new_cbtn.LineColor = cbtn.LineColor
  new_cbtn.NoFrame = cbtn.NoFrame
  new_cbtn.AutoSize = cbtn.AutoSize
  new_cbtn.DrawMode = cbtn.DrawMode
  new_cbtn.NormalImage = cbtn.NormalImage
  new_cbtn.FocusImage = cbtn.FocusImage
  new_cbtn.CheckedImage = cbtn.CheckedImage
  new_cbtn.DisableImage = cbtn.DisableImage
  return new_cbtn
end
function copy_lbl(gui, index, lbl)
  local new_lbl = gui:Create("Label")
  if not nx_is_valid(new_lbl) then
    return nil
  end
  new_lbl.Name = get_control_name(lbl, index)
  new_lbl.Left = lbl.Left
  new_lbl.Top = lbl.Top
  new_lbl.Width = lbl.Width
  new_lbl.Height = lbl.Height
  new_lbl.ForeColor = lbl.ForeColor
  new_lbl.BackColor = lbl.BackColor
  new_lbl.LineColor = lbl.LineColor
  new_lbl.NoFrame = lbl.NoFrame
  new_lbl.AutoSize = lbl.AutoSize
  new_lbl.DrawMode = lbl.DrawMode
  new_lbl.BackImage = lbl.BackImage
  new_lbl.Font = lbl.Font
  new_lbl.Align = lbl.Align
  return new_lbl
end
function get_control_name(control, index)
  local name = control.Name .. "_" .. nx_string(index)
  return name
end
function tiguan_challenge_msg(sub_type, guan_id, ...)
  local form = util_get_form(nx_current(), false)
  if nx_number(sub_type) == nx_number(SERVER_MSG_CHALLENGE_CLOSE) then
    if nx_is_valid(form) then
      form:Close()
    end
    return
  end
  if not nx_is_valid(form) then
    form = util_get_form(nx_current(), true)
    init_challenge_trace(form, nx_number(guan_id))
    util_show_form(nx_current(), true)
  end
  if nx_number(sub_type) == nx_number(SERVER_MSG_CHALLENGE_NOTE) then
    init_challenge_data(form, nx_number(guan_id))
    update_challenge_note(form, unpack(arg))
  elseif nx_number(sub_type) == SERVER_MSG_CHALLENGE_FIGHT then
    update_cur_challenge(form, unpack(arg))
  end
  update_show_info(form)
end
function update_challenge_note(form, ...)
  local count = nx_number(table.getn(arg))
  for i = 1, count do
    local npc_index = nx_number(arg[i])
    if -1 < npc_index then
      local gbox = form.gsbox_all_info:Find(get_control_name(form.gbox_challenge, npc_index))
      if nx_is_valid(gbox) then
        gbox.challenge_state = 2
      end
    end
  end
end
function update_cur_challenge(form, ...)
  local count = nx_number(table.getn(arg) / 3)
  local player_name = get_player_name()
  for i = 1, nx_number(count) do
    local name = nx_widestr(arg[i * 3 - 2])
    local npc_index = nx_number(arg[i * 3 - 1])
    local fail_num = nx_number(arg[i * 3])
    if player_name == name then
      form.fial_num = fail_num
      if -1 < npc_index then
        form.in_fighting = 1
      end
    end
    if -1 < npc_index then
      local gbox = form.gsbox_all_info:Find(get_control_name(form.gbox_challenge, npc_index))
      if nx_is_valid(gbox) then
        gbox.challenge_state = 1
        local lbl_name = gbox:Find(get_control_name(form.lbl_player_name, npc_index))
        if nx_is_valid(lbl_name) then
          lbl_name.Text = name
        end
      end
    end
  end
end
function update_show_info(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  for i = 0, form.npc_num do
    local gbox = form.gsbox_all_info:Find(get_control_name(form.gbox_challenge, i))
    if nx_is_valid(gbox) then
      if gbox.challenge_state == 0 then
        local cbtn_select = gbox:Find(get_control_name(form.cbtn_select, i))
        if nx_is_valid(cbtn_select) then
          cbtn_select.Visible = true
          cbtn_select.Enabled = true
        end
        local lbl_background = gbox:Find(get_control_name(form.lbl_back_ground, i))
        if nx_is_valid(lbl_background) then
          lbl_background.Visible = false
        end
        local lbl_player_school = gbox:Find(get_control_name(form.lbl_player_school, i))
        if nx_is_valid(lbl_player_school) then
          lbl_player_school.Visible = false
        end
        local lbl_player_name = gbox:Find(get_control_name(form.lbl_player_name, i))
        if nx_is_valid(lbl_player_name) then
          lbl_player_name.Text = nx_widestr("")
          lbl_player_name.Visible = false
        end
        local lbl_state = gbox:Find(get_control_name(form.lbl_state, i))
        if nx_is_valid(lbl_state) then
          lbl_state.Visible = true
          lbl_state.Text = gui.TextManager:GetText("ui_yingzhan_xjz10")
          lbl_state.ForeColor = "255,255,255,71"
        end
      end
      if gbox.challenge_state == 1 then
        local cbtn_select = gbox:Find(get_control_name(form.cbtn_select, i))
        if nx_is_valid(cbtn_select) then
          cbtn_select.Visible = false
          if form.cur_select == cbtn_select.npc_index then
            form.cur_select = -1
          end
        end
        local lbl_background = gbox:Find(get_control_name(form.lbl_back_ground, i))
        if nx_is_valid(lbl_background) then
          lbl_background.Visible = true
        end
        local lbl_player_school = gbox:Find(get_control_name(form.lbl_player_school, i))
        if nx_is_valid(lbl_player_school) then
          lbl_player_school.Visible = true
        end
        local lbl_player_name = gbox:Find(get_control_name(form.lbl_player_name, i))
        if nx_is_valid(lbl_player_name) then
          lbl_player_name.Visible = true
        end
        local lbl_state = gbox:Find(get_control_name(form.lbl_state, i))
        if nx_is_valid(lbl_state) then
          lbl_state.Text = nx_widestr("")
          lbl_state.Visible = false
        end
      end
      if gbox.challenge_state == 2 then
        local cbtn_select = gbox:Find(get_control_name(form.cbtn_select, i))
        if nx_is_valid(cbtn_select) then
          cbtn_select.Visible = true
          cbtn_select.Enabled = false
          if form.cur_select == cbtn_select.npc_index then
            form.cur_select = -1
          end
        end
        local lbl_background = gbox:Find(get_control_name(form.lbl_back_ground, i))
        if nx_is_valid(lbl_background) then
          lbl_background.Visible = false
        end
        local lbl_player_school = gbox:Find(get_control_name(form.lbl_player_school, i))
        if nx_is_valid(lbl_player_school) then
          lbl_player_school.Visible = false
        end
        local lbl_player_name = gbox:Find(get_control_name(form.lbl_player_name, i))
        if nx_is_valid(lbl_player_name) then
          lbl_player_name.Text = nx_widestr("")
          lbl_player_name.Visible = false
        end
        local lbl_state = gbox:Find(get_control_name(form.lbl_state, i))
        if nx_is_valid(lbl_state) then
          lbl_state.Visible = true
          lbl_state.Text = gui.TextManager:GetText("ui_yingzhan_xjz11")
          lbl_state.ForeColor = "255,114,23,5"
        end
      end
    end
  end
end
function system_info(sys_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = gui.TextManager:GetText(sys_id)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(text, CENTERINFO_PERSONAL_NO)
  end
end
function get_player_name()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local player_name = client_player:QueryProp("Name")
  return player_name
end
