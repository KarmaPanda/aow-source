require("util_gui")
require("custom_sender")
require("form_stage_main\\form_world_war\\form_world_war_define")
local FORM_NAME = "form_stage_main\\form_world_war\\form_world_war_lingxiao_stat"
local PAGE_COUNT = 12
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local form_lingxiao_stage = util_get_form("form_stage_main\\form_world_war\\form_world_war_lingxiao_stage", true, false)
  if form.groupbox_main:Add(form_lingxiao_stage) then
    form.form_lingxiao_stage = form_lingxiao_stage
    form_lingxiao_stage.Visible = false
  end
  local form_treasure = util_get_form("form_stage_main\\form_world_war\\form_world_war_treasure", true, false)
  if form.groupbox_main:Add(form_treasure) then
    form.form_treasure = form_treasure
    form_treasure.Visible = false
  end
  local form_lingxiao_ranking = util_get_form("form_stage_main\\form_world_war\\form_world_war_lingxiao_ranking", true, false)
  if form.groupbox_main:Add(form_lingxiao_ranking) then
    form.form_lingxiao_ranking = form_lingxiao_ranking
    form_lingxiao_ranking.Visible = false
  end
  local form_hero = util_get_form("form_stage_main\\form_world_war\\form_world_war_hero", true, false)
  if form.groupbox_main:Add(form_hero) then
    form.form_hero = form_hero
    form_hero.Visible = false
  end
  local form_neiying_ranking = util_get_form("form_stage_main\\form_world_war\\form_world_war_neiying_ranking", true, false)
  if form.groupbox_main:Add(form_neiying_ranking) then
    form.form_neiying_ranking = form_neiying_ranking
    form_neiying_ranking.Visible = false
  end
  local client_player = nx_value("game_client")
  local player = client_player:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  form.rbtn_tab_5.Checked = true
  form.rbtn_tab_4.Visible = false
  if player:FindProp("IsTraitor") and player:QueryProp("IsTraitor") == 1 then
    form.rbtn_tab_4.Visible = true
  end
  local world_war_force = player:QueryProp("WorldWarForce")
  if world_war_force == 1 then
    form.rbtn_1.Text = nx_widestr(gui.TextManager:GetText("ui_worldwar_lxc"))
  elseif world_war_force == 2 then
    form.rbtn_1.Text = nx_widestr(gui.TextManager:GetText("ui_worldwar_xssy"))
  elseif world_war_force == 3 then
    form.rbtn_1.Text = nx_widestr(gui.TextManager:GetText("ui_worldwar_blg"))
  elseif world_war_force == 4 then
    form.rbtn_1.Text = nx_widestr(gui.TextManager:GetText("ui_worldwar_xdm"))
  end
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_rbtn_tab_1_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  hide_all_sub_form(form)
  if nx_find_custom(form, "form_treasure") and nx_is_valid(form.form_treasure) then
    form.form_treasure.Visible = true
  end
  custom_world_war_sender(CLIENT_WORLDWAR_TREASURE_TALLY)
end
function on_rbtn_tab_2_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  hide_all_sub_form(form)
  if nx_find_custom(form, "form_hero") and nx_is_valid(form.form_hero) then
    form.form_hero.Visible = true
  end
  custom_world_war_sender(CLINET_WORLDWAR_HERO_INFO)
end
function on_rbtn_tab_3_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "WorldWarEnd") and form.WorldWarEnd then
    form.WorldWarEnd = false
    return
  end
  local page_index = form.form_lingxiao_ranking.page_index
  local from = (page_index - 1) * PAGE_COUNT + 1
  send_world_war_custom_msg(CLIENT_WORLDWAR_STAT_INFO2, nx_int(from), nx_int(from + PAGE_COUNT - 1))
end
function on_rbtn_tab_4_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "WorldWarEnd") and form.WorldWarEnd then
    form.WorldWarEnd = false
    return
  end
  local page_index = form.form_neiying_ranking.page_index
  local from = (page_index - 1) * PAGE_COUNT + 1
  send_world_war_custom_msg(CLIENT_WORLDWAR_TRAITOR_INFO, nx_int(from), nx_int(from + PAGE_COUNT - 1))
end
function on_rbtn_tab_5_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  hide_all_sub_form(form)
  if nx_find_custom(form, "form_lingxiao_stage") and nx_is_valid(form.form_lingxiao_stage) then
    form.form_lingxiao_stage.Visible = true
  end
  send_world_war_custom_msg(CLIENT_WORLDWAR_GENERAL_INFO)
end
function on_btn_open_map_click(rbtn)
  local form = util_get_form("form_stage_main\\form_world_war\\form_world_war_map", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function on_btn_exit_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_main_leaveinfo", name)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(CLIENT_WORLDWAR_LEAVE))
  end
end
function send_world_war_custom_msg(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(sub_msg), unpack(arg))
end
function hide_all_sub_form(form)
  if nx_find_custom(form, "form_lingxiao_stage") and nx_is_valid(form.form_lingxiao_stage) then
    form.form_lingxiao_stage.Visible = false
  end
  if nx_find_custom(form, "form_treasure") and nx_is_valid(form.form_treasure) then
    form.form_treasure.Visible = false
  end
  if nx_find_custom(form, "form_lingxiao_ranking") and nx_is_valid(form.form_lingxiao_ranking) then
    form.form_lingxiao_ranking.Visible = false
  end
  if nx_find_custom(form, "form_hero") and nx_is_valid(form.form_hero) then
    form.form_hero.Visible = false
  end
  if nx_find_custom(form, "form_neiying_ranking") and nx_is_valid(form.form_neiying_ranking) then
    form.form_neiying_ranking.Visible = false
  end
  form.Width = form.groupbox_form.Width
end
function req_army_info()
end
function rev_army_info(...)
  local form = util_get_form(FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_soldier_number_1.Text = nx_widestr(arg[1])
  form.lbl_soldier_number_2.Text = nx_widestr(arg[2])
  form.Visible = true
  form:Show()
end
function update_force_info(score1, score2, score3, score4, nums1, nums2, nums3, nums4)
  local form = util_get_form(FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_soldier_number_1.Text = nx_widestr(score1 .. "/" .. nums1)
  form.lbl_soldier_number_2.Text = nx_widestr(score2 .. "/" .. nums2)
  form.lbl_soldier_number_3.Text = nx_widestr(score3 .. "/" .. nums3)
  form.lbl_soldier_number_4.Text = nx_widestr(score4 .. "/" .. nums4)
end
function hide_traitor(isTraitor)
  local form = util_get_form(FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(isTraitor) ~= nx_int(1) then
    form.rbtn_tab_4.Visible = false
  elseif nx_int(isTraitor) == nx_int(1) then
    form.rbtn_tab_4.Visible = true
  end
end
