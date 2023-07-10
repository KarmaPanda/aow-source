require("define\\object_type_define")
function main_form_init(self)
  self.Fixed = false
end
function main_form_open(self)
  load_stall_note(self)
  self.sender_menu.Visible = false
  self.target_name = ""
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("LastObject", "object", self, "form_stage_main\\form_stall\\form_stall_note", "on_selectobj_changed")
end
function main_form_close(form)
  nx_destroy(form)
end
function on_mltbox_note_click_hyperlink(self)
end
function on_mltbox_note_right_click_hyperlink(self, itemindex, linkdata)
  linkdata = nx_string(linkdata)
  local form = self.ParentForm
  local param_table = nx_function("ext_split_string", linkdata, ",")
  local count = table.getn(param_table)
  if count <= 0 then
    return
  end
  if param_table[1] == "stall" then
    if count < 2 then
      return
    end
    local playername = nx_widestr(param_table[2])
    local gui = nx_value("gui")
    local x, y = gui:GetCursorPosition()
    form.sender_menu.AbsLeft = x + 10
    form.sender_menu.AbsTop = y
    form.sender_menu.Visible = true
    form.sender_name = playername
    form.target_name = playername
  end
end
function on_mltbox_note_mousein_hyperlink(self)
end
function on_mltbox_note_get_capture(self)
end
function on_mltbox_note_lost_capture(self)
end
function on_mltbox_note_mouseout_hyperlink(self)
end
function on_btn_secret_chat_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  if nx_find_custom(form, "sender_name") then
    nx_execute("form_stage_main\\form_main\\form_main_chat", "private_chat_with_player", nx_widestr(form.sender_name))
  end
end
function on_btn_chakan_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  form.sender_menu.Visible = false
  nx_execute("form_stage_main\\form_role_chakan", "get_player_info", nx_widestr(form.sender_name))
end
function on_edit_input_enter(self)
  local text = nx_string(self.Text)
  if nx_execute("util_functions", "is_space", text) then
    return
  end
  self.Text = nx_widestr("")
  local form = self.ParentForm
  nx_execute("custom_sender", "custom_stall_note", form.target_name, text)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  add_player_note(client_player:QueryProp("Name"), text)
  local gui = nx_value("gui")
  gui.Focused = self
end
function on_btn_send_click(self)
  on_edit_input_enter(self.ParentForm.edit_input)
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_selectobj_changed(form)
  if not nx_is_valid(form) then
    return
  end
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return
  end
  local type = target:QueryProp("Type")
  if TYPE_PLAYER ~= tonumber(type) then
    return
  end
  local state = target:QueryProp("StallState")
  if 2 ~= state then
    return
  end
  local gui = nx_value("gui")
  form.target_name = target:QueryProp("Name")
end
function load_stall_note(form)
  local ini = get_stall_ini()
  if nil == ini or not nx_is_valid(ini) then
    return
  end
  local sec_name = "notes"
  local count = ini:GetItemCount(sec_name)
  for index = 1, count do
    local note = ini:ReadString(sec_name, nx_string(index), "")
    if nx_string(note) ~= "" then
      local pos = string.find(note, ",")
      if pos ~= nil then
        local player_name = string.sub(note, 1, pos - 1)
        local content = string.sub(note, pos + 1)
        local text = nx_widestr("")
        if player_name ~= "trade" then
          form.target_name = player_name
          text = nx_widestr(player_name) .. nx_widestr(nx_execute("util_functions", "util_text", "ui_g_stall_say")) .. nx_widestr(content)
        else
          text = nx_widestr(content)
        end
        form.mltbox_note:AddHtmlText(nx_widestr(text), -1)
      end
    end
  end
end
function add_player_note(player_name, note)
  local ini = get_stall_ini()
  if ini ~= nil and nx_is_valid(ini) then
    local sec_name = ini:GetItemCount("notes") + 1
    ini:AddString("notes", nx_string(sec_name), nx_string(player_name) .. "," .. nx_string(note))
    ini:SaveToFile()
  end
  local form_stall_note = nx_value("form_stage_main\\form_stall\\form_stall_note")
  if not nx_is_valid(form_stall_note) then
    return
  end
  form_stall_note.target_name = player_name
  note = nx_widestr(player_name) .. nx_widestr(nx_execute("util_functions", "util_text", "ui_g_stall_say")) .. nx_widestr(note)
  form_stall_note.mltbox_note:AddHtmlText(nx_widestr(note), -1)
end
function add_trade_note(note)
end
function get_stall_ini()
  local ini = nx_value("stall_ini")
  if ini == nil or not nx_is_valid(ini) then
    local ini = nx_execute("util_functions", "get_ini", "stall.ini")
    if not nx_is_valid(ini) then
      return nil
    end
    nx_set_value("stall_ini", ini)
  end
  return nx_value("stall_ini")
end
