require("util_gui")
require("util_functions")
local FORM_TRANSFER_SERVER = "form_stage_main\\form_transfer_server"
local TRANSSERVER_SUBMSG_REQUEST_SERVERLIST = 1
local TRANSSERVER_SUBMSG_REQUEST_TRANSFER = 2
local TRANSSERVER_SUBMSG_REQUEST_GIVEUP = 3
local TRANSSERVER_SUBMSG_REQUEST_CLOSEFORM = 4
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  change_form_size()
end
function on_main_form_close(form)
  form.cmb_serverlist.DroppedDown = false
  local prompt = form.cbtn_tips.Checked and 1 or 0
  nx_execute("custom_sender", "custom_reply_trans_server_list", TRANSSERVER_SUBMSG_REQUEST_CLOSEFORM, nx_int(prompt))
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local area_name = game_config.cur_area_name
  local server_name = game_config.cur_server_name
  local dest_server = form.cmb_serverlist.Text
  if nx_widestr(area_name) == nx_widestr("") or nx_widestr(server_name) == nx_widestr("") or nx_widestr(dest_server) == nx_widestr("") then
    return
  end
  local title = gui.TextManager:GetText("str_tishi")
  local content = gui.TextManager:GetFormatText("ui_request_transserver", nx_widestr(dest_server))
  local res = util_form_confirm(title, content, MB_OKCANCEL, true)
  if res == "ok" then
    nx_execute("custom_sender", "custom_reply_trans_server_list", TRANSSERVER_SUBMSG_REQUEST_TRANSFER, nx_widestr(area_name), nx_widestr(server_name), nx_widestr(dest_server))
    if nx_is_valid(form) then
      form:Close()
    end
  end
end
function on_btn_cancel_click(btn)
  on_btn_close_click(btn)
end
function on_btn_delreply_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local area_name = game_config.cur_area_name
  local server_name = game_config.cur_server_name
  if nx_widestr(area_name) == nx_widestr("") or nx_widestr(server_name) == nx_widestr("") then
    return
  end
  local title = gui.TextManager:GetText("str_tishi")
  local content = gui.TextManager:GetText("ui_giveup_transserver")
  local res = util_form_confirm(title, content, MB_OKCANCEL, true)
  if res == "ok" then
    nx_execute("custom_sender", "custom_reply_trans_server_list", TRANSSERVER_SUBMSG_REQUEST_GIVEUP, nx_widestr(area_name), nx_widestr(server_name))
    if nx_is_valid(form) then
      form:Close()
    end
  end
end
function on_receive_server_list(...)
  local form = nx_value(FORM_TRANSFER_SERVER)
  if not nx_is_valid(form) then
    form = util_show_form(FORM_TRANSFER_SERVER, true)
  end
  form.cmb_serverlist.Enabled = true
  form.btn_delreply.Enabled = true
  form.btn_ok.Enabled = true
  form.cmb_serverlist.DropListBox:ClearString()
  local is_no_prompt = nx_int(arg[1]) == nx_int(1)
  form.cbtn_tips.Checked = is_no_prompt
  local data = {}
  for i = 2, table.getn(arg) do
    table.insert(data, arg[i])
  end
  local nCount = nx_int(table.getn(data) / 2)
  for i = 1, nx_number(nCount) do
    local nIndex = nx_int(data[2 * i - 1])
    local szServerName = nx_widestr(data[2 * i])
    form.cmb_serverlist.DropListBox:AddString(szServerName)
  end
  if nx_int(nCount) > nx_int(0) then
    form.cmb_serverlist.DropListBox.SelectIndex = 0
    form.cmb_serverlist.Text = nx_widestr(data[2])
  end
end
function open_form(self)
  local form = nx_value(FORM_TRANSFER_SERVER)
  if nx_is_valid(form) then
    form:Close()
  else
    local switch_manager = nx_value("SwitchManager")
    if nx_is_valid(switch_manager) then
      local ST_FUNCTION_TRANS_SERVER = 144
      local enable = switch_manager:CheckSwitchEnable(ST_FUNCTION_TRANS_SERVER)
      if not enable then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("30060"))
        return
      end
    end
    nx_execute("custom_sender", "custom_reply_trans_server_list", TRANSSERVER_SUBMSG_REQUEST_SERVERLIST)
  end
end
function change_form_size()
  local form = nx_value(FORM_TRANSFER_SERVER)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
