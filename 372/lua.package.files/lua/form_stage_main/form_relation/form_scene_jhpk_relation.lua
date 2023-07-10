require("utils")
require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_relation\\form_scene_jhpk_relation"
local CLIENT_MSG_JHPK_BUND = 3
function main_form_init(form)
  form.Fixed = false
  form.PlayerName = ""
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  InitListBox(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_form_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function ok_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local text_name = nx_widestr(form.combobox.Text)
  if nx_ws_length(text_name) <= 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "sns_new_10")
  end
  nx_execute("custom_sender", "custom_send_scene_jhpk", CLIENT_MSG_JHPK_BUND, nx_widestr(form.PlayerName), nx_widestr(text_name))
  form:Close()
end
function cancel_btn_click(self)
  local form = self.ParentForm
  form:Close()
end
function custom_jhpk_bund(name)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog.PlayerName = name
  dialog:Show()
end
function InitListBox(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:FindRecord("rec_blood") and client_player:GetRecordRows("rec_blood") > 0 then
    rows_blood = client_player:GetRecordRows("rec_blood")
    for i = 0, rows_blood - 1 do
      local blood_name = client_player:QueryRecord("rec_blood", i, 1)
      form.combobox.DropListBox:AddString(nx_widestr(blood_name))
    end
  end
  if client_player:FindRecord("rec_enemy") and 0 < client_player:GetRecordRows("rec_enemy") then
    rows_enemy = client_player:GetRecordRows("rec_enemy")
    for i = 0, rows_enemy - 1 do
      local enemy_name = client_player:QueryRecord("rec_enemy", i, 1)
      form.combobox.DropListBox:AddString(nx_widestr(enemy_name))
    end
  end
  local gui = nx_value("gui")
  form.combobox.Text = gui.TextManager:GetText("")
  form.lbl_1.Text = gui.TextManager:GetFormatText("ui_sns_systemfriends_02", nx_widestr(form.PlayerName))
end
