function main_form_init(self)
end
function on_main_form_open(self)
  local form_main_marry = nx_value("form_stage_main\\form_main\\form_main_marry")
  if nx_is_valid(form_main_marry) then
    local game_speaker = nx_value("Speaker")
    game_speaker:InitSpeaker()
  end
  change_form_size()
  self.groupbox_1.Visible = false
end
function on_main_form_close(self)
end
function change_form_size()
  local form_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
  if not nx_is_valid(form_chat) then
    return
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_trumpet")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form_chat)
  local form_load = nx_value("form_common\\form_loading")
  if nx_is_valid(form_load) then
    gui.Desktop:ToBack(form_chat)
  else
    gui.Desktop:ToFront(form_chat)
  end
  form.AbsLeft = form_chat.btn_get_trumpet_form.AbsLeft + form_chat.btn_get_trumpet_form.Width
  form.AbsTop = form_chat.btn_get_trumpet_form.AbsTop
  nx_execute("form_stage_main\\form_main\\form_main_marry", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_trumpet_cross", "change_form_size")
end
function on_get_capture(self)
  local form = self.ParentForm
  form.lbl_back.Visible = true
end
function on_lost_capture(self)
  local form = self.ParentForm
  form.lbl_back.Visible = false
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
    form.sender_name = nx_widestr(linkdata)
  end
end
