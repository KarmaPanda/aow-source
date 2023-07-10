require("util_gui")
require("util_functions")
require("form_stage_main\\form_tiguan\\form_tiguan_dual_play")
local FORM_TIGUAN_DUAL_PLAY = "form_stage_main\\form_tiguan\\form_tiguan_dual_play"
local FORM_DUAL_PLAY_INVITE = "form_stage_main\\form_tiguan\\form_tiguan_dual_play_invite"
local DUAL_PLAYER_RELATION_TYPE_0 = 0
local DUAL_PLAYER_RELATION_TYPE_1 = 1
local DUAL_PLAYER_RELATION_TYPE_2 = 2
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  local form_dualplay = nx_value(FORM_TIGUAN_DUAL_PLAY)
  if not nx_is_valid(form_dualplay) then
    form:Close()
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.lbl_1P.Text = nx_widestr("")
  form.lbl_2P.Text = nx_widestr("")
  if nx_find_custom(form_dualplay, "partner_name_type") then
    local index = nx_int(form_dualplay.partner_name_type)
    if index == nx_int(DUAL_PLAYER_RELATION_TYPE_0) then
      form.lbl_1P.Text = client_player:QueryProp("Name")
      form.lbl_2P.Text = nx_widestr("")
      form.btn_del.Visible = false
    elseif index == nx_int(DUAL_PLAYER_RELATION_TYPE_2) then
      if nx_find_custom(form_dualplay, "partner_name") then
        form.lbl_1P.Text = form_dualplay.partner_name
      end
      form.lbl_2P.Text = client_player:QueryProp("Name")
      form.btn_del.Visible = true
    elseif index == nx_int(DUAL_PLAYER_RELATION_TYPE_1) then
      form.lbl_1P.Text = client_player:QueryProp("Name")
      if nx_find_custom(form_dualplay, "partner_name") then
        form.lbl_2P.Text = form_dualplay.partner_name
        form.btn_del.Visible = true
      else
        form.btn_del.Visible = false
      end
    else
      form.btn_del.Visible = false
    end
  end
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_del_click(btn)
  local CLIENT_MSG_DP_REMOVE_PARTNER = 1
  nx_execute("custom_sender", "custom_tiguan_dual_play", CLIENT_MSG_DP_REMOVE_PARTNER)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_invite_click(btn)
  local form = btn.ParentForm
  local partner_name = nx_widestr(form.ipt_name.Text)
  if not nx_ws_equal(partner_name, nx_widestr("")) then
    local CLIENT_MSG_DP_ADD_PARTNER = 0
    nx_execute("custom_sender", "custom_tiguan_dual_play", CLIENT_MSG_DP_ADD_PARTNER, nx_widestr(partner_name))
  end
  if nx_is_valid(form) then
    form:Close()
  end
end
