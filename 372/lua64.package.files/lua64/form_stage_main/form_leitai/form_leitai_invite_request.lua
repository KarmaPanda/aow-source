require("util_gui")
require("share\\client_custom_define")
CLIENT_SUBMSG_REQUIRE_AGREE_NOTICE = 1
CLIENT_SUBMSG_REQUIRE_NO_AGREE_NOTICE = 2
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function on_btn_accept_click(self)
  form = self.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(CLIENT_SUBMSG_REQUIRE_AGREE_NOTICE), nx_int(form.leitai_type), nx_float(form.pos_x), nx_float(form.pos_y), nx_float(form.pos_z), nx_float(form.pos_o), nx_int(form.sence))
  form:Close()
end
function on_btn_no_accept_click(btn)
  local form = btn.ParentForm
  refuse_join_leitai(form.register_npc)
  form:Close()
end
function refuse_join_leitai(register_npc)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local player_name = nx_string(client_player:QueryProp("Name"))
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if player_name ~= nil or player_name ~= "" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(CLIENT_SUBMSG_REQUIRE_NO_AGREE_NOTICE), nx_widestr(player_name), register_npc)
    local text = gui.TextManager:GetText("82098")
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(text, 1, 0)
    end
  end
end
function on_btn_close_click(btn)
  on_btn_no_accept_click(btn)
end
