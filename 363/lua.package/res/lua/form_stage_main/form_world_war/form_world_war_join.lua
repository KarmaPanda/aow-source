require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
local form_name = "form_stage_main\\form_world_war\\form_world_war_join"
function open_form()
  util_show_form("form_stage_main\\form_world_war\\form_world_war_join", true)
end
function main_form_init(form)
  form.Fixed = false
  form.selected_scene = 1
  form.sign_list = 0
  form.sign_self = 0
  form.sign_list_pre = 0
  form.sign_self_pre = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.mltbox_ming_desc:Clear()
  form.mltbox_ming_desc:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("ui_worldwar_ming_desc")), -1)
  form.mltbox_meng_desc:Clear()
  form.mltbox_meng_desc:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("ui_worldwar_meng_desc")), -1)
  form.mltbox_8:Clear()
  form.mltbox_8:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("ui_worldwar_wanfa_desc")), -1)
  on_rbtn_scene_checked_changed(form.rbtn_scene_1)
  form.rbtn_ming.Checked = true
  send_world_war_custom_msg(CLIENT_WORLDWAR_REQUEST_SIGNUP_INFO, nx_int(world_war_table[form.selected_scene]))
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_rbtn_scene_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.selected_scene = nx_int(rbtn.DataSource)
  if form.selected_scene == 1 then
    form.groupbox_youyun.Visible = true
    form.groupbox_lingxiao.Visible = false
    form.cbtn_traitor.Visible = false
    form.lbl_35.Visible = false
  elseif form.selected_scene == 2 then
    form.groupbox_youyun.Visible = false
    form.groupbox_lingxiao.Visible = true
    form.cbtn_traitor.Visible = true
    form.lbl_35.Visible = true
  end
  send_world_war_custom_msg(CLIENT_WORLDWAR_REQUEST_SIGNUP_INFO, nx_int(world_war_table[form.selected_scene]))
end
function on_cbtn_pre_checked_changed(rbtn)
  update_sign_list_info()
end
function on_rbtn_ming_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_ming.Visible = rbtn.Checked
    form.groupbox_meng.Visible = not rbtn.Checked
    form.groupbox_desc.Visible = not rbtn.Checked
    form.groupbox_bubuweiying.Visible = not rbtn.Checked
    form.groupbox_yingxiongjijie.Visible = not rbtn.Checked
  end
end
function on_rbtn_meng_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_ming.Visible = not rbtn.Checked
    form.groupbox_meng.Visible = rbtn.Checked
    form.groupbox_desc.Visible = not rbtn.Checked
    form.groupbox_bubuweiying.Visible = not rbtn.Checked
    form.groupbox_yingxiongjijie.Visible = not rbtn.Checked
  end
end
function on_rbtn_desc_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_ming.Visible = not rbtn.Checked
    form.groupbox_meng.Visible = not rbtn.Checked
    form.groupbox_desc.Visible = rbtn.Checked
    form.groupbox_bubuweiying.Visible = not rbtn.Checked
    form.groupbox_yingxiongjijie.Visible = not rbtn.Checked
  end
end
function on_rbtn_bubuweiying_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_ming.Visible = not rbtn.Checked
    form.groupbox_meng.Visible = not rbtn.Checked
    form.groupbox_desc.Visible = not rbtn.Checked
    form.groupbox_bubuweiying.Visible = rbtn.Checked
    form.groupbox_yingxiongjijie.Visible = not rbtn.Checked
  end
end
function on_rbtn_yingxiongjijie_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_ming.Visible = not rbtn.Checked
    form.groupbox_meng.Visible = not rbtn.Checked
    form.groupbox_desc.Visible = not rbtn.Checked
    form.groupbox_bubuweiying.Visible = not rbtn.Checked
    form.groupbox_yingxiongjijie.Visible = rbtn.Checked
  end
end
function on_rbtn_lingxiao_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_lingxiao_desc.Visible = not rbtn.Checked
    form.groupbox_yingxiongjijie_lxc.Visible = not rbtn.Checked
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.mltbox_lingxiao_desc_1:Clear()
      form.mltbox_lingxiao_desc_1:AddHtmlText(gui.TextManager:GetFormatText("ui_lxcjj"), -1)
    end
    form.lbl_lx_icon_2.BackImage = "gui\\special\\WorldWar\\menu\\xiashi01.png"
    form.lbl_lx_icon_4.BackImage = "gui\\special\\WorldWar\\menu\\fang.png"
    form.groupbox_lingxiao_all.Visible = rbtn.Checked
  end
end
function on_rbtn_xueshan_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_lingxiao_desc.Visible = not rbtn.Checked
    form.groupbox_yingxiongjijie_lxc.Visible = not rbtn.Checked
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.mltbox_lingxiao_desc_1:Clear()
      form.mltbox_lingxiao_desc_1:AddHtmlText(gui.TextManager:GetFormatText("ui_xssyjj"), -1)
    end
    form.lbl_lx_icon_2.BackImage = "gui\\special\\WorldWar\\menu\\xiashi02.png"
    form.lbl_lx_icon_4.BackImage = "gui\\special\\WorldWar\\menu\\gongfang.png"
    form.groupbox_lingxiao_all.Visible = rbtn.Checked
  end
end
function on_rbtn_bingling_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_lingxiao_desc.Visible = not rbtn.Checked
    form.groupbox_yingxiongjijie_lxc.Visible = not rbtn.Checked
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.mltbox_lingxiao_desc_1:Clear()
      form.mltbox_lingxiao_desc_1:AddHtmlText(gui.TextManager:GetFormatText("ui_blgjj"), -1)
    end
    form.lbl_lx_icon_2.BackImage = "gui\\special\\WorldWar\\menu\\lx_xiashi03.png"
    form.lbl_lx_icon_4.BackImage = "gui\\special\\WorldWar\\menu\\gongfang.png"
    form.groupbox_lingxiao_all.Visible = rbtn.Checked
  end
end
function on_rbtn_xuedao_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_lingxiao_desc.Visible = not rbtn.Checked
    form.groupbox_yingxiongjijie_lxc.Visible = not rbtn.Checked
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.mltbox_lingxiao_desc_1:Clear()
      form.mltbox_lingxiao_desc_1:AddHtmlText(gui.TextManager:GetFormatText("ui_xdmjj"), -1)
    end
    form.lbl_lx_icon_2.BackImage = "gui\\special\\WorldWar\\menu\\xiashi04.png"
    form.lbl_lx_icon_4.BackImage = "gui\\special\\WorldWar\\menu\\gongfang.png"
    form.groupbox_lingxiao_all.Visible = rbtn.Checked
  end
end
function on_rbtn_rule_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_lingxiao_all.Visible = not rbtn.Checked
    form.groupbox_lingxiao_desc.Visible = rbtn.Checked
    form.groupbox_yingxiongjijie_lxc.Visible = not rbtn.Checked
  end
end
function on_rbtn_yingxiongjijie_lxc_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.groupbox_lingxiao_all.Visible = not rbtn.Checked
    form.groupbox_lingxiao_desc.Visible = not rbtn.Checked
    form.groupbox_yingxiongjijie_lxc.Visible = rbtn.Checked
  end
end
function on_btn_single_click(btn)
  local form = btn.ParentForm
  local scene_id = world_war_table[form.selected_scene]
  if IsInTeam() then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "90375")
    return
  end
  local wantTraitor = 0
  if form.cbtn_traitor.Checked then
    wantTraitor = 1
  end
  if form.cbtn_pre.Checked == true then
    send_world_war_custom_msg(CLIENT_WORLDWAR_SIGNUP, nx_int(scene_id), 0, nx_int(wantTraitor))
  else
    send_world_war_custom_msg(CLIENT_WORLDWAR_ADVANCE_SIGNUP, nx_int(scene_id), 0, nx_int(wantTraitor))
  end
end
function on_btn_team_click(btn)
  local form = btn.ParentForm
  local scene_id = world_war_table[form.selected_scene]
  if not IsTeamLeader() then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "90381")
    return
  end
  local wantTraitor = 0
  if form.cbtn_traitor.Checked then
    wantTraitor = 1
  end
  if form.cbtn_pre.Checked == true then
    send_world_war_custom_msg(CLIENT_WORLDWAR_SIGNUP, nx_int(scene_id), 1, nx_int(wantTraitor))
  else
    send_world_war_custom_msg(CLIENT_WORLDWAR_ADVANCE_SIGNUP, nx_int(scene_id), 1, nx_int(wantTraitor))
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  local scene_id = world_war_table[form.selected_scene]
  if form.cbtn_pre.Checked == true then
    send_world_war_custom_msg(CLIENT_WORLDWAR_SIGNUP_QUIT, nx_int(scene_id))
  else
    send_world_war_custom_msg(CLIENT_WORLDWAR_ADVANCE_SIGNUP_QUIT, nx_int(scene_id))
  end
end
function send_world_war_custom_msg(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(sub_msg), unpack(arg))
end
function update_signup_info(...)
  if #arg < 6 then
    return
  end
  local form = nx_value("form_stage_main\\form_world_war\\form_world_war_join")
  if not nx_is_valid(form) then
    return
  end
  local scene_id = arg[1]
  local war_stage = arg[2]
  form.sign_list = arg[3]
  form.sign_self = arg[4]
  form.sign_list_pre = arg[5]
  form.sign_self_pre = arg[6]
  if scene_id ~= world_war_table[form.selected_scene] then
    return
  end
  if 0 < war_stage and war_stage <= 4 then
    form.lbl_stage_pic.BackImage = "gui\\special\\worldwar\\stage_icon\\worldwar_stage_" .. nx_string(war_stage) .. ".png"
    form.lbl_stage_text.Text = nx_widestr(util_text("ui_worldwar_yy_stage_" .. nx_string(war_stage)))
    form.lbl_stage_pic.Visible = true
  else
    form.lbl_stage_pic.Visible = false
  end
  update_sign_list_info()
  local gui = nx_value("gui")
  form.lbl_prestige.Text = nx_widestr(gui.TextManager:GetFormatText("ui_worldwar_shengwei", nx_int(GetPlayerPerstige(world_war_table[form.selected_scene]))))
  form.lbl_honor.Text = nx_widestr(gui.TextManager:GetFormatText("ui_worldwar_zhangong", nx_int(GetPlayerHonor(world_war_table[form.selected_scene]))))
end
function update_sign_list_info()
  local form = nx_value("form_stage_main\\form_world_war\\form_world_war_join")
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_pre.Checked == true then
    if form.sign_self <= 0 then
      form.lbl_cur_pos.Visible = false
    else
      form.lbl_cur_pos.Visible = true
      form.lbl_cur_pos.Text = nx_widestr(util_format_string("ui_worldwar_array", nx_int(form.sign_self)))
    end
    form.lbl_player_count.Text = nx_widestr(util_format_string("ui_worldwar_team", nx_int(form.sign_list)))
  else
    if 0 >= form.sign_self_pre then
      form.lbl_cur_pos.Visible = false
    else
      form.lbl_cur_pos.Visible = true
      form.lbl_cur_pos.Text = nx_widestr(util_format_string("ui_worldwar_array", nx_int(form.sign_self_pre)))
    end
    form.lbl_player_count.Text = nx_widestr(util_format_string("ui_worldwar_team", nx_int(form.sign_list_pre)))
  end
end
function GetPlayerPerstige(nSceneID)
  local client_player = nx_value("game_client")
  local client_player = client_player:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("prestige_rec") then
    return 0
  end
  local nRow = client_player:FindRecordRow("prestige_rec", 0, nSceneID)
  local nPerstige = client_player:QueryRecord("prestige_rec", nRow, 1)
  return nPerstige
end
function GetPlayerHonor(nSceneID)
  local client_player = nx_value("game_client")
  local client_player = client_player:GetPlayer()
  if not client_player:FindRecord("worldwar_honor_rec") then
    return 0
  end
  local nRow = client_player:FindRecordRow("worldwar_honor_rec", 0, nSceneID)
  local nHonor = client_player:QueryRecord("worldwar_honor_rec", nRow, 1)
  return nHonor
end
function IsInTeam()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:FindProp("TeamID") and client_player:QueryProp("TeamID") > 0 then
    return true
  end
  return false
end
function IsTeamLeader()
  if IsInTeam() then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if client_player:FindProp("TeamCaptain") and client_player:QueryProp("TeamType") == 0 and nx_string(client_player:QueryProp("TeamCaptain")) == nx_string(client_player:QueryProp("Name")) then
      return true
    end
  end
  return false
end
function on_mltbox_lingxiao_8_click_hyperlink(mltbox, index, data)
  local form = util_get_form("form_stage_main\\form_helper\\form_theme_helper", true)
  util_show_form("form_stage_main\\form_helper\\form_theme_helper", true)
  if nx_is_valid(form) then
    local rbtn = form.groupbox_main:Find("rbtn_main_3")
    if nx_is_valid(rbtn) then
      rbtn.Checked = true
    end
    local root = form.tree_ex_info.RootNode
    local parent_node = root:FindNode(nx_widestr(util_text("ui_jianghuzd02")))
    if nx_is_valid(parent_node) then
      local child_node = parent_node:FindNode(nx_widestr(util_text("ui_lingxiaocheng03")))
      if nx_is_valid(child_node) then
        form.tree_ex_info.SelectNode = child_node
      end
    end
  end
end
