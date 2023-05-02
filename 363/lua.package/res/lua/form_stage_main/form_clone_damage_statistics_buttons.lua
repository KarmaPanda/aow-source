require("share\\chat_define")
require("form_stage_main\\form_clone_damage_statistics_channels")
require("form_stage_main\\form_clone_damage_statistics_set")
require("custom_sender")
CHAT_CHANNELS = {
  CHATTYPE_VISUALRANGE,
  CHATTYPE_SCENE,
  CHATTYPE_TEAM,
  CHATTYPE_GUILD,
  CHATTYPE_SCHOOL,
  CHATTYPE_WORLD,
  CHATTYPE_GOSSIP,
  CHATTYPE_ROW,
  CHATTYPE_SCHOOL_FIGHT
}
function chat_check_channel(array)
  local num = table.getn(array)
  if num == 0 then
    return true
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat")
  if not nx_is_valid(dialog) then
    return false
  end
  local gui = nx_value("gui")
  local text
  if num == 1 then
    if array[1] == CHATTYPE_WORLD then
      text = gui.TextManager:GetText("ui_congirm_channel_9")
    end
    if array[1] == CHATTYPE_GOSSIP then
      text = gui.TextManager:GetText("ui_congirm_channel_10")
    end
  elseif num == 2 then
    text = gui.TextManager:GetText("ui_congirm_channel_11")
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  return res == "cancel"
end
function statistics_buttons_init(self)
  return
end
function on_main_form_open(self)
  local form_statistics = nx_value("form_stage_main\\form_clone_damage_statistics")
  if not nx_is_valid(form_statistics) then
    return
  end
  self.Left = form_statistics.Left + form_statistics.Width
  self.Top = form_statistics.Top
  self.Fixed = false
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.btn_1.Text = gui.TextManager:GetText("ui_info_left_01")
  self.btn_2.Text = gui.TextManager:GetText("ui_info_left_02")
  self.btn_3.Text = gui.TextManager:GetText("ui_info_left_03")
end
function on_main_form_close(self)
  local form_channel = nx_value("form_stage_main\\form_clone_damage_statistics_channels")
  if nx_is_valid(form_channel) then
    form_channel:Close()
  end
  local form_set = nx_value("form_stage_main\\form_clone_damage_statistics_set")
  if nx_is_valid(form_set) then
    form_set:Close()
  end
end
function on_btn_1_click(btn)
  local form_statistics = nx_value("form_clone_damage_statistics")
  if not nx_is_valid(form_statistics) then
    nx_msgbox("get error")
    return
  end
  local form_channel = nx_value("form_stage_main\\form_clone_damage_statistics_channels")
  if not nx_is_valid(form_channel) then
    return
  end
  local chat_text1 = form_statistics.lbl_7.DataSource
  local chat_text2 = form_statistics.lbl_8.DataSource
  local information = nx_widestr("")
  if string.len(chat_text1) ~= 0 then
    information = nx_widestr(util_text(chat_text1)) .. nx_widestr(":") .. nx_widestr(form_statistics.lbl_7_7.Text)
  end
  if string.len(chat_text2) ~= 0 then
    information = information .. nx_widestr(" ") .. nx_widestr(util_text(chat_text2)) .. nx_widestr(":") .. nx_widestr(form_statistics.lbl_8_8.Text)
  end
  if nx_ws_length(information) == 0 then
    return
  end
  local array = {}
  local index = 1
  for var = 1, 9 do
    local control_name = "cbtn_" .. nx_string(var)
    local check_button = form_channel.groupbox_1:Find(control_name)
    if nx_is_valid(check_button) and check_button.Checked == true then
      if CHAT_CHANNELS[var] == CHATTYPE_WORLD or CHAT_CHANNELS[var] == CHATTYPE_GOSSIP then
        array[index] = CHAT_CHANNELS[var]
        index = index + 1
      else
        nx_execute("custom_sender", "custom_chat", CHAT_CHANNELS[var], nx_widestr(information))
      end
    end
  end
  if not chat_check_channel(array) then
    local num = table.getn(array)
    for i = 1, num do
      nx_execute("custom_sender", "custom_chat", array[i], nx_widestr(information))
    end
  end
end
function on_btn_2_click(btn)
  local form_set = nx_value("form_stage_main\\form_clone_damage_statistics_set")
  if nx_is_valid(form_set) then
    form_set.Visible = false
  end
  local form_channel = nx_value("form_stage_main\\form_clone_damage_statistics_channels")
  if nx_is_valid(form_channel) then
    form_channel:Show()
    form_channel.Visible = true
  end
end
function on_btn_3_click(btn)
  local form_channel = nx_value("form_stage_main\\form_clone_damage_statistics_channels")
  if nx_is_valid(form_channel) then
    form_channel.Visible = false
  end
  local form_set = nx_value("form_stage_main\\form_clone_damage_statistics_set")
  if nx_is_valid(form_set) then
    form_set:Show()
    form_set.Visible = true
  end
end
