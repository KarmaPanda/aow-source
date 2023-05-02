require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  InitXueChou(form)
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
function ok_btn_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local player_name = nx_widestr(form.combobox.Text)
  local name = nx_widestr(form.name)
  local type = form.type
  local money_type = form.money_type
  local money = form.money
  if player_name == nil or player_name == "" then
    return
  end
  custom_search_xuechou(player_name, name, type, money_type, money)
  form:Close()
end
function cancel_btn_click(self)
  local form = self.ParentForm
  form:Close()
end
function custom_search_xuechou(player_name, name, type, money_type, money)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(872), nx_int(0), nx_widestr(player_name), nx_widestr(name), nx_int(type), nx_int(money_type), nx_int(money))
end
function InitXueChou(form)
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
      local name = client_player:QueryRecord("rec_blood", i, 1)
      form.combobox.DropListBox:AddString(nx_widestr(name))
    end
  end
  local gui = nx_value("gui")
  form.combobox.Text = gui.TextManager:GetText("textinskin00228")
end
