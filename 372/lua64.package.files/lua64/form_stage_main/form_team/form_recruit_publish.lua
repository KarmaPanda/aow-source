require("share\\chat_define")
local zhaomuini
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  zhaomuini = nx_execute("util_functions", "get_ini", "ini\\ui\\zhaomu\\zhaomulist.ini")
  if not nx_is_valid(zhaomuini) then
    nx_msgbox("ini\\ui\\zhaomu\\zhaomulist.ini " .. get_msg_str("msg_120"))
    return
  end
  nx_set_value("zhaomuini", zhaomuini)
  init_combox_control(form)
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value(nx_current(), nx_null())
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local info_type = form.cmb_place.InputEdit.Text
  local info_mission = form.cmb_task.InputEdit.Text
  local info_content = form.txt_content.Text
  local checkwords = nx_value("CheckWords")
  if nx_is_valid(checkwords) then
    info_content = checkwords:CleanWords(nx_widestr(info_content))
  end
  nx_execute("custom_sender", "custom_team_add_info", info_type, info_mission, info_content)
  form:Close()
  prompt_send_to_chat_channel(CHATTYPE_WORLD, info_type, info_mission, info_content)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_cmb_place_selected(cmb)
  local form = cmb.ParentForm
  local index = cmb.DropListBox.SelectIndex
  refresh_mission(form, index)
end
function init_combox_control(form)
  local gui = nx_value("gui")
  form.cmb_place.DropListBox:ClearString()
  form.cmb_task.DropListBox:ClearString()
  local sec_count = zhaomuini:GetSectionCount()
  for i = 1, sec_count do
    local bookname = zhaomuini:GetSectionByIndex(i - 1)
    form.cmb_place.DropListBox:AddString(gui.TextManager:GetFormatText(nx_string(bookname)))
  end
  form.cmb_place.DropListBox.SelectIndex = 0
  form.cmb_place.InputEdit.Text = form.cmb_place.DropListBox:GetString(0)
  local index = form.cmb_place.DropListBox.SelectIndex
  refresh_mission(form, index)
end
function refresh_mission(form, index)
  local gui = nx_value("gui")
  form.cmb_task.DropListBox:ClearString()
  local sec_index = index
  local key_count = zhaomuini:GetSectionItemCount(sec_index)
  for i = 0, key_count - 1 do
    local missionname = zhaomuini:GetSectionItemValue(sec_index, i)
    form.cmb_task.DropListBox:AddString(gui.TextManager:GetFormatText(nx_string(missionname)))
  end
  form.cmb_task.DropListBox.SelectIndex = 0
  form.cmb_task.InputEdit.Text = form.cmb_task.DropListBox:GetString(0)
end
function prompt_send_to_chat_channel(channel, info_type, info_mission, info_content)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local is_captain = "1"
  local txtZhaomu = gui.TextManager:GetText("ui_Recruit")
  local txtXunzu = gui.TextManager:GetText("ui_SearchTeam")
  gui.TextManager:Format_SetIDName("7355")
  local self_name = client_player:QueryProp("Name")
  local captainname = client_player:QueryProp("TeamCaptain")
  if nx_ws_equal(nx_widestr(self_name), nx_widestr(captainname)) then
    is_captain = "1"
    gui.TextManager:Format_AddParam(txtZhaomu)
  else
    is_captain = "0"
    gui.TextManager:Format_AddParam(txtXunzu)
  end
  gui.TextManager:Format_AddParam(info_type)
  gui.TextManager:Format_AddParam(info_mission)
  local data = nx_widestr("team,") .. nx_widestr(self_name) .. nx_widestr(",") .. nx_widestr(is_captain) .. nx_widestr(",") .. nx_widestr(info_type) .. nx_widestr(",") .. nx_widestr(info_mission)
  gui.TextManager:Format_AddParam(data)
  local shensi_lei = client_player:QueryProp("LeiTaiCurPlayerState")
  local itera_status = client_player:QueryProp("InteractStatus")
  if 0 < shensi_lei or itera_status == 19 or itera_status == 20 then
    return
  end
  open_prompt_dialog(channel, gui.TextManager:Format_GetText())
end
function open_prompt_dialog(channel, info)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_zudui_zm")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog.lbl_1.Text = nx_widestr("@ui_zudui")
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if result == "ok" then
    nx_execute("custom_sender", "custom_chat", channel, info)
  end
end
