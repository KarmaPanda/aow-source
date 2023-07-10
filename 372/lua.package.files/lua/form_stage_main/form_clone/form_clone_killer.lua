require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\form_clone\\define")
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  local kills = client_player:QueryProp("KillPlayerCount")
  local killer_score = client_player:QueryProp("KillerScore")
  form.lbl_name.Text = nx_widestr(player_name)
  form.lbl_killers.Text = nx_widestr(kills)
  form.lbl_score.Text = nx_widestr(killer_score)
  form.rbtn_1.Checked = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_killer_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_APPLY_BOSS_HELPER))
end
function cancel_apply_killer()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CANCEL_BOSS_HELPER))
end
function on_btn_killer_score_click(btn)
  local form = util_get_form("form_stage_main\\form_rank\\form_rank_main", true, true)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible then
    form.Visible = false
    form:Close()
    return
  else
    form.Visible = true
    form:Show()
  end
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", form, "rank_6_killer")
end
function on_desc_checked_changed(rbtn)
  if not rbtn.Checked then
    return 0
  end
  local form = rbtn.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.mltbox_desc:Clear()
  if rbtn.DataSource == "1" then
    form.mltbox_desc:AddHtmlText(gui.TextManager:GetText("jdss04_1"), -1)
  elseif rbtn.DataSource == "2" then
    form.mltbox_desc:AddHtmlText(gui.TextManager:GetText("jdss04_2"), -1)
  end
end
