require("util_gui")
local r = 70
local jiaodu = 0
local last_row = -1
local last_col = -1
function main_form_init(self)
end
function on_main_form_open(self)
  resize()
  init_grid(self.textgrid_1)
  init_number(self, true)
  self.index = -1
  self.stop = false
  nx_execute(nx_current(), "chcek_stop", self)
  create_num_button(self)
  self.grid_1 = false
  self.grid_2 = false
  self.grid_3 = false
  self.btn_ok.Enabled = false
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "rotation_button", self)
  end
  nx_destroy(self)
  nx_set_value("form_stage_login\\form_login_mibao", nil)
end
function resize()
  local form = nx_value("form_stage_login\\form_login_mibao")
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    form.Width = gui.Width
    form.Height = gui.Height
    form.Top = 0
    form.Left = 0
    form.groupbox_1.Left = (gui.Width - form.groupbox_1.Width) / 2
    form.groupbox_1.Top = (gui.Height - form.groupbox_1.Height) / 2
  end
end
function init(width, height, code)
  if nx_string(code) == "" then
    return
  end
  local cells = nx_function("ext_split_string", nx_string(code), ",")
  if table.getn(cells) ~= 3 then
    return
  end
  local form = nx_value("form_stage_login\\form_login_mibao")
  if not nx_is_valid(form) then
    return
  end
  form.cell_1, form.cell_1_row, form.cell_1_col = explain_code(cells[1])
  form.cell_2, form.cell_2_row, form.cell_2_col = explain_code(cells[2])
  form.cell_3, form.cell_3_row, form.cell_3_col = explain_code(cells[3])
  form.index = 1
  set_row_and_col_color(form, form.cell_1_row, form.cell_1_col, "255,255,102,0")
  last_row = form.cell_1_row
  last_col = form.cell_1_col
  form.ipt_num_1.Top = form.textgrid_1.Top + form.ipt_num_1.Height * (form.cell_1_row + 1) + 2
  form.ipt_num_1.Left = form.textgrid_1.Left + 34 * (form.cell_1_col + 1) + 2
  form.ipt_num_1.is_input = false
  form.ipt_num_1.row = form.cell_1_row
  form.ipt_num_1.col = form.cell_1_col
  form.ipt_num_2.Top = form.textgrid_1.Top + form.ipt_num_2.Height * (form.cell_2_row + 1) + 2
  form.ipt_num_2.Left = form.textgrid_1.Left + 34 * (form.cell_2_col + 1) + 2
  form.ipt_num_2.is_input = false
  form.ipt_num_2.row = form.cell_2_row
  form.ipt_num_2.col = form.cell_2_col
  form.ipt_num_3.Top = form.textgrid_1.Top + form.ipt_num_3.Height * (form.cell_3_row + 1) + 2
  form.ipt_num_3.Left = form.textgrid_1.Left + 34 * (form.cell_3_col + 1) + 2
  form.ipt_num_3.is_input = false
  form.ipt_num_3.row = form.cell_3_row
  form.ipt_num_3.col = form.cell_3_col
  local gui = nx_value("gui")
  gui.Focused = form.ipt_num_1
  local gui = nx_value("gui")
  form.mltbox_desc.HtmlText = gui.TextManager:GetFormatText("ui_mibao", nx_widestr(form.cell_1))
end
function explain_code(info)
  local bcol = string.byte(info, 1)
  local brow = string.sub(info, 2, string.len(info))
  local icol = nx_int(bcol) - 65
  local irow = nx_int(brow) - 1
  return info, irow, icol
end
function init_grid(grid)
  if not nx_is_valid(grid) or grid.ColCount ~= 0 then
    return
  end
  local grid_columns = {
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G"
  }
  local grid_rows = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10
  }
  grid.ColCount = table.getn(grid_columns)
  grid.RowCount = table.getn(grid_rows)
end
function get_active_info(form)
  local info = ""
  local icol = -1
  local irow = -1
  if form.index == 1 then
    info = form.cell_1
    icol = form.cell_1_col
    irow = form.cell_1_row
  elseif form.index == 2 then
    info = form.cell_2
    icol = form.cell_2_col
    irow = form.cell_2_row
  elseif form.index == 3 then
    info = form.cell_3
    icol = form.cell_3_col
    irow = form.cell_3_row
  end
  return info, icol, irow
end
function init_number(form, first)
  local btns = {
    [1] = form.btn_1,
    [2] = form.btn_2,
    [3] = form.btn_3,
    [4] = form.btn_4,
    [5] = form.btn_5,
    [6] = form.btn_6,
    [7] = form.btn_7,
    [8] = form.btn_8,
    [9] = form.btn_9,
    [10] = form.btn_10
  }
  math.randomseed(os.clock())
  local n = 0
  local count = #btns
  for i = 1, count do
    n = math.random(1, count + 1 - i)
    btns[n].Text = nx_widestr(i - 1)
    btns[n].show_num = i - 1
    table.remove(btns, n)
  end
end
function on_btn_cancel_click(self)
  self.ParentForm:Close()
  local sock = nx_execute("client", "get_game_sock")
  if not nx_is_valid(sock) then
    return
  end
  local sender = sock.Sender
  if not nx_is_valid(sender) then
    return
  end
  local receiver = sock.Receiver
  if not nx_is_valid(receiver) then
    return
  end
  receiver:ClearAll()
  if sock.Connected then
    sock:Disconnect()
    console_log("Disconnect...")
  end
end
function fillcell(form, num)
  local info, icol, irow = get_active_info(form)
  if info == "" then
    return
  end
  local show_button = form.groupbox_1:Find("ipt_num_" .. nx_string(form.index))
  if nx_is_valid(show_button) and show_button.is_input == false then
    show_button.Text = nx_widestr(num)
    show_button.is_input = true
  else
    local context = show_button.Text
    show_button.Text = nx_widestr(context) .. nx_widestr(num)
  end
end
function on_btn_num_click(self)
  fillcell(self.ParentForm, nx_int(self.show_num))
  local form = nx_value("form_stage_login\\form_login_mibao")
  local show_button = form.groupbox_1:Find("ipt_num_" .. nx_string(form.index))
  if nx_is_valid(show_button) then
    local gui = nx_value("gui")
    gui.Focused = show_button
  end
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  local info, icol, irow = get_active_info(form)
  if info == "" then
    return
  end
  local game_config = nx_value("game_config")
  game_config.login_verify = info_tostring(form)
  game_config.login_password = form.pswd
  local flogin = nx_value("form_stage_login\\form_login")
  flogin.ipt_1.Text = nx_widestr(game_config.login_account)
  nx_execute("form_stage_login\\form_login", "on_btn_enter_click", flogin.btn_enter)
  form:Close()
end
function info_tostring(form)
  local info = ""
  local a, b, c
  for i = 1, 3 do
    local ipt_control = form.groupbox_1:Find("ipt_num_" .. i)
    if nx_is_valid(ipt_control) then
      info = info .. nx_string(ipt_control.Text)
    end
    if i ~= 3 then
      info = info .. ","
    end
  end
  return info
end
function on_btn_clear_click(self)
  local form = self.ParentForm
  local info, icol, irow = get_active_info(form)
  if info == "" then
    return
  end
  local show_button = form.groupbox_1:Find("ipt_num_" .. nx_string(form.index))
  if nx_is_valid(show_button) then
    show_button.is_input = false
    show_button.Text = ""
    local gui = nx_value("gui")
    gui.Focused = show_button
  end
  nx_set_custom(form, "grid_" .. nx_string(form.index), false)
  local form = nx_value("form_stage_login\\form_login_mibao")
  form.btn_ok.Enabled = false
end
function login_game(account, password, verify, login_validate)
  local sock = nx_execute("client", "get_game_sock")
  local sender = sock.Sender
  local receiver = sock.Receiver
  local gui = nx_value("gui")
  receiver:ClearAll()
  nx_pause(0)
  local dialog = util_get_form("form_common\\form_connect", true, false)
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.btn_return.Visible = false
  dialog.btn_cancel.Visible = true
  dialog.lbl_4.Height = dialog.lbl_4.Height + dialog.lbl_6.Height
  dialog.lbl_6.Visible = false
  dialog.lbl_xian.Visible = false
  local bfailed = false
  local log = ""
  local info_stringid = ""
  if nil == login_validate or "" == login_validate then
    sender:LoginVerify(nx_string(account), nx_string(password), nx_string(verify))
  else
    sender:LoginVerifyAppend(nx_string(account), nx_string(password), nx_string(verify), nx_string(login_validate))
  end
  sock.account = nx_string(account)
  console_log("login...")
  dialog.lbl_connect.Text = nx_string("")
  dialog.info_mltbox.HtmlText = gui.TextManager:GetFormatText("ui_login")
  dialog.event_name = "event_login"
  dialog:ShowModal()
  local res, code = nx_wait_event(30, receiver, "event_login")
  if res == "queue" then
    if nx_is_valid(dialog) then
      dialog:Close()
    end
    local form_queue = util_get_form("form_common\\form_queue", false)
    if nx_is_valid(form_queue) and form_queue.on_queue then
      res = nx_wait_event(100000000, form_queue, "form_common\\form_queue")
      if res == nil or res ~= "succeed" then
        gui:Delete(dialog)
        sock:Disconnect()
        nx_gen_event(nx_null(), "login_game", "failed")
        return false
      end
    else
      dialog:ShowModal()
      res = "cancel"
    end
  end
  if res == nil then
    bfailed = true
    log = "login time out"
    info_stringid = "ui_login_timeout"
    if nx_is_valid(dialog) then
      dialog:Close()
      gui:Delete(dialog)
    end
    nx_gen_event(nx_null(), "login_game", "failed")
    return false
  elseif res == "failed" then
    bfailed = true
    log = "login failed"
    if code ~= nil then
      info_stringid = "login_errcode_" .. nx_string(code)
    else
      info_stringid = "ui_login_failed"
    end
  elseif res == "cancel" then
    bfailed = true
    log = "login cancel"
    info_stringid = "ui_login_cancel"
  end
  if bfailed then
    console_log(log)
    sock:Disconnect()
    if code ~= nil and code == 51002 then
      local form_login = nx_value("form_stage_login\\form_login")
      if nx_is_valid(form_login) then
        form_login.login_num = form_login.login_num + 1
        if form_login.login_num >= 10 then
          local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "breakconnect")
          if nx_is_valid(dialog) then
            local gui = nx_value("gui")
            dialog.cancel_btn.Visible = false
            dialog.mltbox_info.HtmlText = gui.TextManager:GetText("ui_mima_tips")
            dialog.ok_btn.Text = gui.TextManager:GetText("ui_exitgame")
            dialog:ShowModal()
            local res = nx_wait_event(100000000, dialog, "breakconnect_confirm_return")
            nx_execute("main", "direct_exit_game")
            return false
          end
        end
      end
    end
    gui.TextManager:Format_SetIDName(info_stringid)
    if code ~= nil then
      gui.TextManager:Format_AddParam(nx_int(code))
    end
    dialog.info_mltbox.HtmlText = gui.TextManager:Format_GetText()
    dialog.btn_return.Visible = true
    dialog.btn_cancel.Visible = false
    dialog.lbl_4.Height = dialog.lbl_4.Height - dialog.lbl_6.Height
    dialog.lbl_xian.Visible = true
    dialog.lbl_6.Visible = true
    dialog.event_name = "login_failed"
    nx_wait_event(100000000, dialog, dialog.event_name)
    dialog:Close()
    gui:Delete(dialog)
    nx_gen_event(nx_null(), "login_game", "failed")
    return false
  end
  nx_gen_event(nx_null(), "login_game", "succeed")
  if nx_is_valid(dialog) then
    dialog:Close()
    gui:Delete(dialog)
  end
  return true
end
function create_num_button(form)
  local gui = nx_value("gui")
  local x = form.lbl_yuanquan.Left + form.lbl_yuanquan.Width / 2
  local y = form.lbl_yuanquan.Top + form.lbl_yuanquan.Height / 2
  for i = 1, 10 do
    local button = form.groupbox_1:Find("btn_" .. nx_string(i))
    button.Name = "button_" .. nx_string(i)
    button.num = i
    local j = i * 36 / 180 * 3.14
    local center_x = x + math.floor(math.sin(j) * r)
    local center_y = y + math.floor(math.cos(j) * r)
    button.Left = center_x - button.Width / 2
    button.Top = center_y - button.Height / 2
    nx_bind_script(button, nx_current())
    nx_callback(button, "on_get_capture", "on_get_capture_button")
    nx_callback(button, "on_lost_capture", "on_lost_capture_button")
    nx_callback(button, "on_click", "on_btn_num_click")
    form:Add(button)
  end
  local timer = nx_value("timer_game")
  timer:Register(100, -1, nx_current(), "rotation_button", form, -1, -1)
end
function rotation_button(form)
  local gui = nx_value("gui")
  local mouse_x, mouse_y = gui:GetCursorPosition()
  if mouse_y == nil or mouse_x == nil then
    return
  end
  local abs_x = form.lbl_yuanquan.AbsLeft + form.lbl_yuanquan.Width / 2
  local abs_y = form.lbl_yuanquan.AbsTop + form.lbl_yuanquan.Height / 2
  local x = form.lbl_yuanquan.Left + form.lbl_yuanquan.Width / 2
  local y = form.lbl_yuanquan.Top + form.lbl_yuanquan.Height / 2
  local len = math.pow(math.pow(math.abs(mouse_y - abs_y), 2) + math.pow(math.abs(mouse_x - abs_x), 2), 0.5)
  len = len / 50
  if 20 <= len then
    len = 20
  end
  jiaodu = jiaodu + len
  if 360 <= jiaodu then
    jiaodu = 0
  end
  for i = 1, 10 do
    local button = form.groupbox_1:Find("button_" .. nx_string(i))
    if nx_is_valid(button) then
      local j = (i * 36 + jiaodu) / 180 * math.pi
      local center_x = x + math.floor(math.sin(j) * r)
      local center_y = y + math.floor(math.cos(j) * r)
      button.Left = center_x - button.Width / 2
      button.Top = center_y - button.Height / 2
    end
  end
end
function chcek_stop(form)
  while true do
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local mouse_x, mouse_y = gui:GetCursorPosition()
    if not nx_is_valid(form) then
      return
    end
    local x = form.lbl_yuanquan.AbsLeft + form.lbl_yuanquan.Width / 2
    local y = form.lbl_yuanquan.AbsTop + form.lbl_yuanquan.Height / 2
    len = math.pow(math.pow(math.abs(mouse_y - y), 2) + math.pow(math.abs(mouse_x - x), 2), 0.5)
    if len ~= nil and nx_number(len) < 90 then
      local btns = {
        [1] = form.btn_1,
        [2] = form.btn_2,
        [3] = form.btn_3,
        [4] = form.btn_4,
        [5] = form.btn_5,
        [6] = form.btn_6,
        [7] = form.btn_7,
        [8] = form.btn_8,
        [9] = form.btn_9,
        [10] = form.btn_10
      }
      for i = 1, 10 do
        btns[i].Text = nx_widestr("")
      end
      form.stop = true
      local timer = nx_value("timer_game")
      if nx_is_valid(timer) then
        timer:UnRegister(nx_current(), "rotation_button", form)
      end
    end
    if len > 90 then
      local btns = {
        [1] = form.btn_1,
        [2] = form.btn_2,
        [3] = form.btn_3,
        [4] = form.btn_4,
        [5] = form.btn_5,
        [6] = form.btn_6,
        [7] = form.btn_7,
        [8] = form.btn_8,
        [9] = form.btn_9,
        [10] = form.btn_10
      }
      for i = 1, 10 do
        btns[i].Text = nx_widestr(btns[i].show_num)
      end
      if form.stop == true then
        local timer = nx_value("timer_game")
        if nx_is_valid(timer) then
          timer:Register(100, -1, nx_current(), "rotation_button", form, -1, -1)
        end
        form.stop = false
      end
    end
    nx_pause(0.1)
  end
end
function on_ipt_num_get_focus(self)
  local row = self.row
  local col = self.col
  local form = nx_value("form_stage_login\\form_login_mibao")
  local gui = nx_value("gui")
  if not nx_find_custom(form, "cell_1_row") then
    return
  end
  if row == form.cell_1_row and col == form.cell_1_col then
    form.index = 1
    nx_execute(nx_current(), "move_select_row", last_row, row)
    nx_execute(nx_current(), "move_select_col", last_col, col)
    last_col = col
    last_row = row
    form.mltbox_desc.HtmlText = gui.TextManager:GetFormatText("ui_mibao", nx_widestr(form.cell_1))
  elseif row == form.cell_2_row and col == form.cell_2_col then
    form.index = 2
    nx_execute(nx_current(), "move_select_row", last_row, row)
    nx_execute(nx_current(), "move_select_col", last_col, col)
    last_col = col
    last_row = row
    form.mltbox_desc.HtmlText = gui.TextManager:GetFormatText("ui_mibao", nx_widestr(form.cell_2))
  elseif row == form.cell_3_row and col == form.cell_3_col then
    form.index = 3
    nx_execute(nx_current(), "move_select_row", last_row, row)
    nx_execute(nx_current(), "move_select_col", last_col, col)
    last_col = col
    last_row = row
    form.mltbox_desc.HtmlText = gui.TextManager:GetFormatText("ui_mibao", nx_widestr(form.cell_3))
  else
    form.index = -1
  end
end
function on_ipt_num_changed(self)
  local form = nx_value("form_stage_login\\form_login_mibao")
  if self.Text == nx_widestr("") then
    nx_set_custom(form, "grid_" .. nx_string(form.index), false)
  else
    nx_set_custom(form, "grid_" .. nx_string(form.index), true)
  end
  if form.grid_1 and form.grid_2 and form.grid_3 then
    form.btn_ok.Enabled = true
  else
    form.btn_ok.Enabled = false
  end
end
function move_select_row(old_row, row)
  local form = nx_value("form_stage_login\\form_login_mibao")
  while true do
    for i = 1, math.abs(row - old_row) do
      if 0 < row - old_row then
        set_row(form, old_row + i, "255,255,102,0")
      end
      if row - old_row < 0 then
        set_row(form, old_row - i, "255,255,102,0")
      end
      nx_pause(0)
    end
    break
  end
end
function move_select_col(old_col, col)
  local form = nx_value("form_stage_login\\form_login_mibao")
  while true do
    for i = 1, math.abs(col - old_col) do
      if 0 < col - old_col then
        set_col(form, old_col + i, "255,255,102,0")
      end
      if col - old_col < 0 then
        set_col(form, old_col - i, "255,255,102,0")
      end
      nx_pause(0)
    end
    break
  end
end
function set_row(form, row, color)
  form.lbl_row.Left = form.lbl_bg.Left + 5
  form.lbl_row.Top = form.lbl_bg.Top + 33 * nx_number(row + 1) + 1
  for i = 1, 10 do
    local row_button = form.groupbox_1:Find("lbl_row_" .. nx_string(i))
    if nx_is_valid(row_button) then
      row_button.ForeColor = "255,255,255,255"
    end
  end
  local row_button = form.groupbox_1:Find("lbl_row_" .. nx_string(row + 1))
  if nx_is_valid(row_button) then
    row_button.ForeColor = color
  end
end
function set_col(form, col, color)
  form.lbl_col.Top = form.lbl_bg.Top + 4
  form.lbl_col.Left = form.lbl_bg.Left + 34 * nx_number(col + 1) + 1
  for i = 1, 7 do
    local col_button = form.groupbox_1:Find("lbl_col_" .. nx_string(i))
    if nx_is_valid(col_button) then
      col_button.ForeColor = "255,255,255,255"
    end
  end
  local col_button = form.groupbox_1:Find("lbl_col_" .. nx_string(col + 1))
  if nx_is_valid(col_button) then
    col_button.ForeColor = color
  end
end
function set_row_and_col_color(form, row, col, color)
  form.lbl_row.Left = form.lbl_bg.Left + 5
  form.lbl_row.Top = form.lbl_bg.Top + 33 * nx_number(row + 1) + 1
  form.lbl_col.Top = form.lbl_bg.Top + 4
  form.lbl_col.Left = form.lbl_bg.Left + 34 * nx_number(col + 1) + 1
  local row_button = form.groupbox_1:Find("lbl_row_" .. nx_string(row + 1))
  local col_button = form.groupbox_1:Find("lbl_col_" .. nx_string(col + 1))
  if nx_is_valid(row_button) then
    row_button.ForeColor = color
  end
  if nx_is_valid(col_button) then
    col_button.ForeColor = color
  end
end
