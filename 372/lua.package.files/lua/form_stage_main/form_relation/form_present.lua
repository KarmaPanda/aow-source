require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
function main_form_init(self)
  self.Fixed = false
  self.IsInitSendPresentForm = false
  self.IsInitAcpectPresentForm = false
  self.SendPlayerName = ""
  self.SendPlayerUid = ""
  self.TypeMode = 0
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  nx_execute("form_stage_main\\form_main\\form_main_request_right", "del_request_item", 4)
  local relationForm = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(relationForm) then
  end
  on_init(self)
  return 1
end
function on_main_form_close(self)
  if self.IsInitSendPresentForm and nx_is_valid(self.page_send) then
    self.page_send:Close()
  end
  if self.IsInitAcpectPresentForm and nx_is_valid(self.page_acpect) then
    self.page_acpect:Close()
  end
  nx_destroy(self)
  return 1
end
function hide_other_control(form)
  if form.IsInitSendPresentForm then
    form.page_send.Visible = false
  end
  if form.IsInitAcpectPresentForm then
    form.page_acpect.Visible = false
  end
end
function on_init(form)
  if form.TypeMode == 0 then
    show_send_page(form)
  else
    form.rbtn_accpect.Checked = true
  end
end
function show_send_page(form)
  hide_other_control(form)
  if not form.IsInitSendPresentForm then
    local page_send = util_get_form("form_stage_main\\form_relation\\form_send_present", true, false)
    if form:Add(page_send) then
      form.page_send = page_send
      form.page_send.Visible = false
      form.page_send.Fixed = true
      form.page_send.Left = 3
      form.page_send.Top = 61
      if form.SendPlayerName ~= "" then
        form.page_send.ipt_players.Text = nx_widestr(form.SendPlayerName)
      end
      form.IsInitSendPresentForm = true
    end
  end
  form.page_send.Visible = true
  form:ToFront(form.page_send)
end
function show_acpect_page(form)
  hide_other_control(form)
  if not form.IsInitAcpectPresentForm then
    local page_acpect = util_get_form("form_stage_main\\form_relation\\form_acpect_present", true, false)
    if form:Add(page_acpect) then
      form.page_acpect = page_acpect
      form.page_acpect.Visible = false
      form.page_acpect.Fixed = true
      form.page_acpect.Left = 3
      form.page_acpect.Top = 61
      form.IsInitAcpectPresentForm = true
    end
  end
  form.page_acpect.Visible = true
  form:ToFront(form.page_acpect)
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function on_rbtn_accpect_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    show_acpect_page(form)
  end
end
function on_rbtn_send_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    show_send_page(form)
  end
end
function on_show_xitie(player, carrywords)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local mainplayer = game_client:GetPlayer()
  if not nx_is_valid(mainplayer) then
    return 0
  end
  if nx_string(player) ~= nx_string(game_client.PlayerIdent) then
    return 0
  end
end
