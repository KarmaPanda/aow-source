require("share\\chat_define")
require("util_gui")
local INFO_MAX_NUM = 300
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  self.redit_info.ReturnFontFormat = false
end
function on_main_form_close(self)
  local gui = nx_value("gui")
  gui.Focused = nx_null()
  gui.hyperfocused = nx_null()
end
function init(form)
  change_form_size()
  form.lbl_has_money.Text = nx_widestr("0")
  form.btn_send.Enabled = false
  form.redit_info.Text = nx_widestr("")
  update_gold()
end
function change_form_size()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value("form_stage_main\\form_main\\form_laba_info_marry")
  if not nx_is_valid(form) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form.Visible = false
  local gui = nx_value("gui")
  gui.Focused = nx_null()
  gui.hyperfocused = nx_null()
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form.Visible = false
end
function on_btn_send_click(self)
  local form = self.ParentForm
  local chat_str = form.redit_info.Text
  if nx_string(chat_str) == "" then
    return
  end
  nx_execute("custom_sender", "custom_speaker", CHATTYPE_MARRY, chat_str, 1)
end
function on_btn_buy_click(self)
  util_auto_show_hide_form("form_stage_main\\form_charge_shop\\form_online_charge")
end
function on_redit_info_changed(self)
  local form = self.ParentForm
  local info = nx_string(self.Text)
  if info == "" then
    form.btn_send.Enabled = false
  else
    form.btn_send.Enabled = true
  end
end
function update_gold()
  local form = nx_value("form_stage_main\\form_main\\form_laba_info_marry")
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gold = client_player:QueryProp("CapitalType2")
  gold = nx_int(gold / 1000)
  if gold > nx_int(999999) then
    form.lbl_has_money.Text = nx_widestr("999999...")
  else
    form.lbl_has_money.Text = nx_widestr(gold)
  end
end
function on_redit_info_get_focus(self)
  local gui = nx_value("gui")
  local form = self.ParentForm
  gui.Focused = form.redit_info
  gui.hyperfocused = form.redit_info
end
function on_rbtn_history_checked_changed(self)
  local form = self.ParentForm
  if self.Checked then
    form.groupbox_1.Visible = false
    form.groupbox_2.Visible = true
  end
end
function on_rbtn_speaker_checked_changed(self)
  local form = self.ParentForm
  if self.Checked then
    form.groupbox_1.Visible = true
    form.groupbox_2.Visible = false
  end
end
function on_mltbox_info_click_hyperlink(self, itemindex, linkdata)
  if linkdata == nil or nx_string(linkdata) == "" then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local player_name = player:QueryProp("Name")
  if nx_string(player_name) ~= nx_string(linkdata) then
    nx_execute("custom_sender", "custom_request_chat", nx_widestr(linkdata))
  end
end
function on_mltbox_info_right_click_hyperlink(self, itemindex, linkdata)
  if linkdata == nil or nx_string(linkdata) == "" then
    return
  end
  if string.find(nx_string(linkdata), "item") ~= nil then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local player_name = player:QueryProp("Name")
  local gui = nx_value("gui")
  if nx_string(player_name) ~= nx_string(linkdata) then
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_player_menu", true)
    local form = nx_value("form_stage_main\\form_main\\form_player_menu")
    if not nx_is_valid(form) then
      return
    end
    local x, y = gui:GetCursorPosition()
    form.AbsLeft = x
    form.AbsTop = y
    if nx_is_valid(form) then
      form.sender_name = nx_widestr(linkdata)
    end
  end
end
function on_btn_clear_click(self)
  local form = self.ParentForm
  form.mltbox_info:Clear()
end
function right_down()
  local form = nx_value("form_stage_main\\form_main\\form_player_menu")
  if nx_is_valid(form) then
    form:Close()
  end
end
function left_down()
  local form = nx_value("form_stage_main\\form_main\\form_player_menu")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_mltbox_info_vscroll_changed(self)
  if math.abs(self.VerticalMaxValue - self.VerticalValue) < 2 then
    self.AutoScroll = true
  else
    self.AutoScroll = false
  end
end
