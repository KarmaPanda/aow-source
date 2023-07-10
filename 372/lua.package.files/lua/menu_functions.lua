require("share\\logicstate_define")
require("share\\view_define")
require("define\\team_rec_define")
require("form_stage_main\\switch\\switch_define")
require("form_stage_main\\form_tvt\\define")
local TEAM_REC = "team_rec"
local WORLD_WAR_HERO_HURT_BUFF = "buf_zc_lxc009"
function is_visible_role_create_team(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  if nx_string(LeaderName) == nx_string("") or nx_string(LeaderName) == nx_string("0") then
    return 1
  else
    return 0
  end
end
function is_visible_role_team_allocate(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  if nx_string(LeaderName) ~= nx_string("") and nx_string(LeaderName) ~= nx_string("0") then
    return 1
  else
    return 0
  end
end
function is_visible_role_team_quality(role, target)
  local captain_name = role:QueryProp("TeamCaptain")
  local role_name = role:QueryProp("Name")
  if nx_string(captain_name) ~= nx_string("") and nx_string(captain_name) ~= nx_string("0") and nx_string(role_name) == nx_string(captain_name) then
    return 1
  else
    return 0
  end
end
function is_visible_role_team_leave(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  if nx_string(LeaderName) ~= nx_string("") and nx_string(LeaderName) ~= nx_string("0") then
    return 1
  else
    return 0
  end
end
function is_visible_role_team_disband(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  if nx_string(LeaderName) == nx_string("") or nx_string(LeaderName) == nx_string("0") then
    return 0
  end
  local RoleName = role:QueryProp("Name")
  if nx_string(RoleName) ~= nx_string(LeaderName) then
    return 0
  end
  return 1
end
function is_visible_create_leitai(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  if nx_string(LeaderName) ~= nx_string("") and nx_string(LeaderName) ~= nx_string("0") then
    return 0
  end
  return 1
end
function is_visible_create_wudou(role, target)
  local newschool_name = nx_string(role:QueryProp("NewSchool"))
  if newschool_name ~= "newschool_nianluo" then
    return 0
  end
  return 1
end
function is_enable_friend_request(role, target)
  if not nx_is_valid(target) then
    targetName = nx_widestr(target)
  else
    targetName = target:QueryProp("Name")
  end
  local row = role:FindRecordRow("rec_buddy", 1, nx_widestr(targetName))
  if row < 0 then
    return 2
  else
    return 1
  end
end
function is_enable_team_team_kick(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  local RoleName = role:QueryProp("Name")
  if not nx_is_valid(target) then
    targetName = nx_widestr(target)
  else
    targetName = target:QueryProp("Name")
  end
  local row = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(targetName))
  if row < 0 then
    return 1
  end
  if nx_string(RoleName) ~= nx_string(LeaderName) then
    return 1
  else
    return 2
  end
end
function is_visible_team_team_kick(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  local RoleName = role:QueryProp("Name")
  if not nx_is_valid(target) then
    targetName = nx_widestr(target)
  else
    targetName = target:QueryProp("Name")
  end
  if nx_string(RoleName) ~= nx_string(LeaderName) then
    return 0
  else
    return 1
  end
end
function is_visible_team_battlefield_kick(role, target)
  local battle_state = role:QueryProp("BattlefieldState")
  if nx_number(battle_state) ~= 3 then
    return 0
  end
  local self_arenaside = role:QueryProp("ArenaSide")
  if self_arenaside ~= 0 then
    return 1
  end
  return 0
end
function is_visible_team_team_change_leader(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  local RoleName = role:QueryProp("Name")
  if nx_is_valid(target) then
    local targetTeamCaptain = target:QueryProp("TeamCaptain")
    if nx_widestr(LeaderName) == nx_widestr(targetTeamCaptain) then
      return 1
    else
      return 0
    end
  end
  if nx_string(RoleName) ~= nx_string(LeaderName) then
    return 0
  else
    return 1
  end
end
function is_visible_team_realse_work(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  local RoleName = role:QueryProp("Name")
  if nx_string(RoleName) ~= nx_string(LeaderName) then
    return 0
  else
    local rowcount = role:GetRecordRows(TEAM_REC)
    for i = 0, rowcount - 1 do
      local name = role:QueryRecord(TEAM_REC, i, TEAM_REC_COL_NAME)
      local playerwork = role:QueryRecord(TEAM_REC, i, TEAM_REC_COL_TEAMWORK)
      if nx_string(name) == nx_string(target) then
        if nx_int(playerwork) == nx_int(0) then
          return 0
        else
          return 1
        end
      end
    end
  end
  return 0
end
function is_enable_team_realse_work(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  local RoleName = role:QueryProp("Name")
  if not nx_is_valid(target) then
    targetName = nx_widestr(target)
  else
    targetName = target:QueryProp("Name")
  end
  local row = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(targetName))
  if row < 0 then
    return 1
  end
  if nx_string(RoleName) ~= nx_string(LeaderName) then
    return 1
  else
    return 2
  end
  local TeamType = role:QueryProp("TeamType")
  if nx_int(TeamType) ~= nx_int(1) then
    return 1
  else
    return 2
  end
end
function is_visible_team_set_sign(role, target)
  local team_id = role:QueryProp("TeamID")
  if team_id < 0 then
    return 0
  end
  local LeaderName = role:QueryProp("TeamCaptain")
  local RoleName = role:QueryProp("Name")
  if nx_string(RoleName) == nx_string(LeaderName) then
    return 1
  end
  local row = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(RoleName))
  local playerwork = role:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMWORK)
  if nx_int(playerwork) > nx_int(0) then
    return 1
  end
  return 0
end
function is_enable_team_set_sign(role, target)
  local team_id = role:QueryProp("TeamID")
  if team_id < 0 then
    return 0
  end
  local LeaderName = role:QueryProp("TeamCaptain")
  local RoleName = role:QueryProp("Name")
  if nx_string(RoleName) == nx_string(LeaderName) then
    return 2
  end
  local row = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(RoleName))
  local playerwork = role:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMWORK)
  if nx_int(playerwork) > nx_int(0) then
    return 2
  end
  return 1
end
function is_visible_team_set_sign_1(role, target)
  local team_id = role:QueryProp("TeamID")
  if team_id < 0 then
    return 0
  end
  local LeaderName = role:QueryProp("TeamCaptain")
  local RoleName = role:QueryProp("Name")
  local targetName
  if not nx_is_valid(target) then
    targetName = nx_widestr(target)
  else
    targetName = target:QueryProp("Name")
  end
  local target_row = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(targetName))
  if target_row < 0 then
    return 0
  end
  if nx_string(RoleName) == nx_string(LeaderName) then
    return 1
  end
  local row = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(RoleName))
  local playerwork = role:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMWORK)
  if nx_int(playerwork) > nx_int(0) then
    return 1
  end
  return 0
end
function is_enable_team_set_sign_1(role, target)
  local team_id = role:QueryProp("TeamID")
  if team_id < 0 then
    return 0
  end
  local LeaderName = role:QueryProp("TeamCaptain")
  local RoleName = role:QueryProp("Name")
  local targetName
  if not nx_is_valid(target) then
    targetName = nx_widestr(target)
  else
    targetName = target:QueryProp("Name")
  end
  local target_row = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(targetName))
  if target_row < 0 then
    return 1
  end
  if nx_string(RoleName) == nx_string(LeaderName) then
    return 2
  end
  local row = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(RoleName))
  local playerwork = role:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMWORK)
  if nx_int(playerwork) > nx_int(0) then
    return 2
  end
  return 1
end
function is_enable_team_team_change_leader(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  local RoleName = role:QueryProp("Name")
  local targetName = nx_widestr("")
  if not nx_is_valid(target) then
    targetName = nx_widestr(target)
  else
    targetName = target:QueryProp("Name")
  end
  local row = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(targetName))
  if row < 0 then
    return 1
  end
  if nx_string(RoleName) ~= nx_string(LeaderName) then
    return 1
  else
    return 2
  end
end
function is_visible_select_team_request(role, target)
  local TargetLeader = target:QueryProp("TeamCaptain")
  if nx_string(TargetLeader) ~= nx_string("") and nx_string(TargetLeader) ~= nx_string("0") then
    return 0
  end
  local LeaderName = role:QueryProp("TeamCaptain")
  if nx_string(LeaderName) == nx_string("") or nx_string(LeaderName) == nx_string("0") then
    return 1
  end
  local RoleName = role:QueryProp("Name")
  if nx_string(RoleName) ~= nx_string(LeaderName) then
    local rownum = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(RoleName))
    local playerwork = role:QueryRecord(TEAM_REC, rownum, TEAM_REC_COL_TEAMWORK)
    if nx_int(playerwork) == nx_int(2) then
      return 1
    else
      return 0
    end
  end
  return 1
end
function is_enable_select_team_request(role, target)
  local TargetLeader = target:QueryProp("TeamCaptain")
  if nx_string(TargetLeader) ~= nx_string("") and nx_string(TargetLeader) ~= nx_string("0") then
    return 1
  end
  local LeaderName = role:QueryProp("TeamCaptain")
  if nx_string(LeaderName) == nx_string("") or nx_string(LeaderName) == nx_string("0") then
    return 2
  end
  local RoleName = role:QueryProp("Name")
  if nx_string(RoleName) ~= nx_string(LeaderName) then
    local rownum = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(RoleName))
    local playerwork = role:QueryRecord(TEAM_REC, rownum, TEAM_REC_COL_TEAMWORK)
    if nx_int(playerwork) == nx_int(2) then
      return 2
    else
      return 1
    end
  end
  return 2
end
function is_visible_is_me(role, target)
  local RoleName = role:QueryProp("Name")
  local targetName
  if not nx_is_valid(target) then
    targetName = nx_widestr(target)
  else
    targetName = target:QueryProp("Name")
  end
  if nx_string(RoleName) == nx_string(targetName) then
    return 0
  else
    return 1
  end
end
function is_enable_is_me(role, target)
  local RoleName = role:QueryProp("Name")
  local targetName
  if not nx_is_valid(target) then
    targetName = nx_widestr(target)
  else
    targetName = target:QueryProp("Name")
  end
  if nx_string(RoleName) == nx_string(targetName) then
    return 1
  else
    return 2
  end
end
function is_visible_select_team_jion(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  if nx_string(LeaderName) ~= nx_string("") and nx_string(LeaderName) ~= nx_string("0") then
    return 0
  end
  local TargetLeaderName = target:QueryProp("TeamCaptain")
  if nx_string(TargetLeaderName) == nx_string("") or nx_string(TargetLeaderName) == nx_string("0") then
    return 0
  end
  return 1
end
function is_enable_select_team_jion(role, target)
  local LeaderName = role:QueryProp("TeamCaptain")
  if nx_string(LeaderName) ~= nx_string("") and nx_string(LeaderName) ~= nx_string("0") then
    return 1
  end
  local TargetLeaderName = target:QueryProp("TeamCaptain")
  if nx_string(TargetLeaderName) == nx_string("") or nx_string(TargetLeaderName) == nx_string("0") then
    return 1
  end
  return 2
end
function is_visible_chat_can_add_newpage(role, target)
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  if form.new_page_count > 2 then
    return false
  end
  return true
end
function is_visible_chat_can_change_name(role, target)
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  local index = nx_number(form.cur_right_click_cbtn.DataSource)
  if index == 0 then
    return false
  end
  return true
end
function is_visible_chat_can_close_page(role, target)
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  local index = nx_number(form.cur_right_click_cbtn.DataSource)
  if index == 0 then
    return false
  end
  return true
end
function is_enable_func_npc_copy_name(role, target)
  return 0
end
function is_enable_team_alloc_free(role, target)
  local mode = role:QueryProp("TeamPickMode")
  if nx_int(mode) == nx_int(TEAM_PICK_MODE_FREE) then
    return 2
  else
    return 0
  end
end
function is_enable_team_alloc_turn(role, target)
  local mode = role:QueryProp("TeamPickMode")
  if nx_int(mode) == nx_int(TEAM_PICK_MODE_TURN) then
    return 2
  else
    return 0
  end
end
function is_enable_team_alloc_team(role, target)
  local mode = role:QueryProp("TeamPickMode")
  if nx_int(mode) == nx_int(TEAM_PICK_MODE_TEAM) then
    return 2
  else
    return 0
  end
end
function is_enable_team_alloc_leader(role, target)
  local mode = role:QueryProp("TeamPickMode")
  if nx_int(mode) == nx_int(TEAM_PICK_MODE_CAPTAIN) then
    return 2
  else
    return 0
  end
end
function is_enable_team_alloc_need(role, target)
  local mode = role:QueryProp("TeamPickMode")
  if nx_int(mode) == nx_int(TEAM_PICK_MODE_NEED) then
    return 2
  else
    return 0
  end
end
function is_enable_team_alloc_compete(role, target)
  local mode = role:QueryProp("TeamPickMode")
  if nx_int(mode) == nx_int(TEAM_PICK_MODE_COMPETE) then
    return 2
  else
    return 0
  end
end
function is_enable_team_quality_1(role, target)
  local mode = role:QueryProp("TeamPickQuality")
  if nx_int(mode) == nx_int(1) then
    return 2
  else
    return 0
  end
end
function is_enable_team_quality_2(role, target)
  local mode = role:QueryProp("TeamPickQuality")
  if nx_int(mode) == nx_int(2) then
    return 2
  else
    return 0
  end
end
function is_enable_team_quality_3(role, target)
  local mode = role:QueryProp("TeamPickQuality")
  if nx_int(mode) == nx_int(3) then
    return 2
  else
    return 0
  end
end
function is_enable_team_quality_4(role, target)
  local mode = role:QueryProp("TeamPickQuality")
  if nx_int(mode) == nx_int(4) then
    return 2
  else
    return 0
  end
end
function is_enable_team_quality_5(role, target)
  local mode = role:QueryProp("TeamPickQuality")
  if nx_int(mode) == nx_int(5) then
    return 2
  else
    return 0
  end
end
function is_enable_team_quality_6(role, target)
  local mode = role:QueryProp("TeamPickQuality")
  if nx_int(mode) == nx_int(6) then
    return 2
  else
    return 0
  end
end
function is_visible_sh_tj_share_menu(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SHARE_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  if not view:FindRecord("share_job_rec") then
    return 0
  end
  local rownum = view:FindRecordRow("share_job_rec", 0, "sh_tj")
  if 0 <= rownum then
    return 1
  end
  return 0
end
function is_visible_sh_jq_share_menu(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SHARE_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  if not view:FindRecord("share_job_rec") then
    return 0
  end
  local rownum = view:FindRecordRow("share_job_rec", 0, "sh_jq")
  if 0 <= rownum then
    return 1
  end
  return 0
end
function is_visible_sh_cf_share_menu(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SHARE_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  if not view:FindRecord("share_job_rec") then
    return 0
  end
  local rownum = view:FindRecordRow("share_job_rec", 0, "sh_cf")
  if 0 <= rownum then
    return 1
  end
  return 0
end
function is_visible_sh_cs_share_menu(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SHARE_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  if not view:FindRecord("share_job_rec") then
    return 0
  end
  local rownum = view:FindRecordRow("share_job_rec", 0, "sh_cs")
  if 0 <= rownum then
    return 1
  end
  return 0
end
function is_visible_sh_ys_share_menu(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SHARE_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  if not view:FindRecord("share_job_rec") then
    return 0
  end
  local rownum = view:FindRecordRow("share_job_rec", 0, "sh_ys")
  if 0 <= rownum then
    return 1
  end
  return 0
end
function is_visible_sh_ds_share_menu(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SHARE_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  if not view:FindRecord("share_job_rec") then
    return 0
  end
  local rownum = view:FindRecordRow("share_job_rec", 0, "sh_ds")
  if 0 <= rownum then
    return 1
  end
  return 0
end
function is_visible_sh_gs_share_menu(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SHARE_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  if not view:FindRecord("share_job_rec") then
    return 0
  end
  local rownum = view:FindRecordRow("share_job_rec", 0, "sh_gs")
  if 0 <= rownum then
    return 1
  end
  return 0
end
function is_visible_sh_ss_share_menu(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SHARE_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  if not view:FindRecord("share_job_rec") then
    return 0
  end
  local rownum = view:FindRecordRow("share_job_rec", 0, "sh_ss")
  if 0 <= rownum then
    return 1
  end
  return 0
end
function is_visible_sh_hs_share_menu(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SHARE_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  if not view:FindRecord("share_job_rec") then
    return 0
  end
  local rownum = view:FindRecordRow("share_job_rec", 0, "sh_hs")
  if 0 <= rownum then
    return 1
  end
  return 0
end
function is_visible_life_job_share_menu(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SHARE_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  if not view:FindRecord("share_job_rec") then
    return 0
  end
  local rows = view:GetRecordRows("share_job_rec")
  if 0 < rows then
    return 1
  end
  return 0
end
function is_visible_life_wqgame(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if 0 <= client_player:FindRecordRow("job_rec", 0, "sh_qis", 0) then
    return 1
  end
  return 0
end
function is_visible_player_rank_challenge(role, target)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord("TempChallengeListRec") then
    return 0
  end
  local name = target:QueryProp("Name")
  local rownum = role:FindRecordRow("TempChallengeListRec", 1, name)
  if rownum < 0 then
    return 0
  end
  return 1
end
function is_enable_player_challenge(role, target)
  local state = role:QueryProp("LogicState")
  if LS_STALLED == state or LS_OFFLINE_STALL == state then
    return 1
  end
  state = target:QueryProp("LogicState")
  if LS_STALLED == state or LS_OFFLINE_STALL == state then
    return 1
  end
  return 2
end
function is_visible_player_challenge(role, target)
  local state = role:QueryProp("LogicState")
  if LS_STALLED == state or LS_OFFLINE_STALL == state then
    return 0
  end
  state = target:QueryProp("LogicState")
  if LS_STALLED == state or LS_OFFLINE_STALL == state then
    return 0
  end
  return 1
end
function is_visible_show_player_tiguan(role, target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local game_role = game_client:GetPlayer()
  local select_obj = nx_value("game_select_obj")
  if not nx_is_valid(game_role) then
    return 0
  end
  if not nx_is_valid(select_obj) then
    return 0
  end
  if nx_id_equal(game_role, select_obj) then
    return 0
  end
  return 1
end
function is_visible_set_zhenyan(role, target)
  if not role:FindProp("CurZhenFaID") then
    return 0
  end
  local zhenfa_id = role:QueryProp("CurZhenFaID")
  if zhenfa_id == 0 or zhenfa_id == "" then
    return 0
  end
  local row = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(target:QueryProp("Name")))
  if row < 0 then
    return 0
  end
  local target_zhenfa = target:QueryProp("CurZhenFaID")
  if target_zhenfa ~= 0 and target_zhenfa ~= "" then
    return 0
  end
  local target_belong_zhenfa = target:QueryProp("BelongZhenFa")
  if target_belong_zhenfa ~= 0 and target_belong_zhenfa ~= "" then
    return 0
  end
  return 1
end
function is_visible_offline_setfree_menu(role, target)
  if target:FindProp("IsAbducted") and nx_number(target:QueryProp("IsAbducted")) > nx_number(0) then
    return 1
  end
  return 0
end
function is_visible_offline_togather_menu(role, target)
  if nx_execute("form_stage_main\\form_offline\\offline_util", "is_doing_offline_trustee", target) then
    return 1
  end
  return 0
end
function is_visible_offline_life_job_share_menu(role, target)
  if nx_execute("form_stage_main\\form_offline\\offline_util", "is_doing_offline_stall", target) and nx_execute("form_stage_main\\form_offline\\offline_util", "is_life_job_server", target) then
    return is_visible_life_job_share_menu(role, target)
  end
  return 0
end
local max_powerLevel = -1
function is_visible_interact_menu_type_1(role, target)
  if nx_number(nx_execute("form_stage_main\\form_offline\\offline_util", "get_fee_type", target)) == nx_number(1) then
    return 1
  end
  return 0
end
function is_visible_fee_sub_level_1_menu(role, target)
  return is_player_PowerLevel_inRange(role, 0, 10)
end
function is_visible_fee_sub_level_2_menu(role, target)
  return is_player_PowerLevel_inRange(role, 0, 20)
end
function is_visible_fee_sub_level_3_menu(role, target)
  return is_player_PowerLevel_inRange(role, 0, 30)
end
function is_visible_fee_sub_level_4_menu(role, target)
  return is_player_PowerLevel_inRange(role, 11, 40)
end
function is_visible_fee_sub_level_5_menu(role, target)
  return is_player_PowerLevel_inRange(role, 21, 50)
end
function is_visible_fee_sub_level_6_menu(role, target)
  return is_player_PowerLevel_inRange(role, 31, 60)
end
function is_visible_fee_sub_level_7_menu(role, target)
  return is_player_PowerLevel_inRange(role, 41, max_powerLevel)
end
function is_visible_fee_sub_level_8_menu(role, target)
  return is_player_PowerLevel_inRange(role, 51, max_powerLevel)
end
function is_visible_fee_sub_level_9_menu(role, target)
  return is_player_PowerLevel_inRange(role, 61, max_powerLevel)
end
function is_player_PowerLevel_inRange(role, beginLevel, endLevel)
  local type = role:QueryProp("Type")
  if nx_number(type) ~= 2 then
    return 0
  end
  local powerLevel = role:QueryProp("PowerLevel")
  if nx_number(endLevel) == nx_number(max_powerLevel) and nx_number(powerLevel) >= nx_number(beginLevel) then
    return 1
  end
  if nx_number(powerLevel) >= nx_number(beginLevel) and nx_number(powerLevel) <= nx_number(endLevel) then
    return 1
  end
  return 0
end
function is_visible_interact_menu_type_2(role, target)
  if nx_number(nx_execute("form_stage_main\\form_offline\\offline_util", "get_fee_type", target)) == nx_number(2) then
    return 1
  end
  return 0
end
function is_visible_interact_menu_type_3(role, target)
  if nx_number(nx_execute("form_stage_main\\form_offline\\offline_util", "get_fee_type", target)) == nx_number(3) then
    return 1
  end
  return 0
end
function is_visible_interact_menu_type_4(role, target)
  if nx_number(nx_execute("form_stage_main\\form_offline\\offline_util", "get_fee_type", target)) == nx_number(4) then
    return 1
  end
  return 0
end
function is_visible_interact_menu_type_5(role, target)
  if nx_number(nx_execute("form_stage_main\\form_offline\\offline_util", "get_fee_type", target)) == nx_number(5) then
    return 1
  end
  return 0
end
function is_visible_offline_abduct_menu(role, target)
  if nx_execute("form_stage_main\\form_offline\\offline_util", "is_book_keeper", target) then
    return 0
  end
  if nx_execute("form_stage_main\\form_offline\\offline_util", "is_doing_poke", target) then
    return 0
  end
  if nx_execute("form_stage_main\\form_offline\\offline_util", "is_abducted", target) then
    return 0
  end
  if nx_execute("form_stage_main\\form_offline\\offline_util", "is_doing_offline_job", target) then
    return 1
  end
  return 0
end
function is_visible_offline_accost_menu(role, target)
  if nx_execute("form_stage_main\\form_offline\\offline_util", "is_doing_offline_job", target) then
    return 1
  end
  return 0
end
function is_visible_sweet_pet_js_menu(role, target)
  if nx_execute("form_stage_main\\form_sweet_employ\\sweet_employ_common", "is_have_sweet_pet") then
    return 1
  end
  return 0
end
function is_visible_sweet_pet_cz_menu(role, target)
  local switchmgr = nx_value("SwitchManager")
  if nx_is_valid(switchmgr) then
    local enable = switchmgr:CheckSwitchEnable(ST_FUNCTION_SWEET_EMPLOY)
    if not enable then
      return 0
    end
  end
  local p1 = nx_execute("form_stage_main\\form_sweet_employ\\form_offline_employee_utils", "IsBuildEmployRelation")
  local p2 = nx_execute("form_stage_main\\form_sweet_employ\\form_offline_employee_utils", "IsOpenFormOfflineEmp")
  if p1 == true and p2 == true then
    return 1
  end
  return 0
end
function is_visible_off_tvt_stun_menu(role, target)
  if nx_execute("form_stage_main\\form_offline\\offline_util", "is_book_keeper", target) then
    return 1
  end
  return 0
end
function is_visible_invite_respond_menu(role, target)
  local is_captain = nx_int(role:QueryProp("IsGuildCaptain"))
  local is_respond = nx_int(role:QueryProp("IsGuildRespond"))
  if is_captain ~= nx_int(2) then
    return 0
  end
  if is_respond == nx_int(0) then
    return 0
  end
  if target:FindProp("GuildName") then
    local target_guild = target:QueryProp("GuildName")
    if nx_ws_equal(nx_widestr(target_guild), nx_widestr("")) == false and nx_ws_equal(nx_widestr(target_guild), nx_widestr("0")) == false then
      return 0
    end
  end
  return 1
end
function is_visible_join_guild_menu(role, target)
  local target_guild = target:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(target_guild), nx_widestr("")) or nx_ws_equal(nx_widestr(target_guild), nx_widestr("0")) then
    return 0
  end
  local is_respond = nx_int(target:QueryProp("IsGuildRespond"))
  if is_respond == nx_int(1) then
    return 0
  end
  local self_guild = role:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(self_guild), nx_widestr("")) == false and nx_ws_equal(nx_widestr(self_guild), nx_widestr("0")) == false then
    return 0
  end
  return 1
end
function is_visible_respond_guild_menu(role, target)
  local target_guild = target:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(target_guild), nx_widestr("")) or nx_ws_equal(nx_widestr(target_guild), nx_widestr("0")) then
    return 0
  end
  local is_captain = nx_int(target:QueryProp("IsGuildCaptain"))
  if is_captain == nx_int(2) then
    return 0
  end
  local is_respond = nx_int(target:QueryProp("IsGuildRespond"))
  if is_respond == nx_int(0) then
    return 0
  end
  local self_guild = role:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(self_guild), nx_widestr("")) == false and nx_ws_equal(nx_widestr(self_guild), nx_widestr("0")) == false then
    return 0
  end
  return 1
end
function is_visible_invite_member_menu(role, target)
  local target_guild = target:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(target_guild), nx_widestr("")) == false and nx_ws_equal(nx_widestr(target_guild), nx_widestr("0")) == false then
    return 0
  end
  local self_guild = role:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(self_guild), nx_widestr("")) or nx_ws_equal(nx_widestr(self_guild), nx_widestr("0")) then
    return 0
  end
  local is_respond = nx_int(role:QueryProp("IsGuildRespond"))
  if is_respond == nx_int(1) then
    return 0
  end
  return 1
end
function is_visible_cure_relive(role, target)
  local result = nx_execute("form_stage_main\\form_die_util", "cancure", role, target)
  if not result then
    return 0
  end
  return 1
end
function is_visible_arrest_accuse_menu(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local target_type = target:QueryProp("Type")
  if target_type ~= 2 then
    return 0
  end
  if not target:FindProp("ArrestFlag") then
    return 0
  end
  local state = target:QueryProp("ArrestFlag")
  if state ~= 2 then
    return 0
  end
  return 1
end
function is_visible_join_faculty_menu(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local target_state = target:QueryProp("TeamFacultyState")
  if nx_int(target_state) ~= nx_int(1) then
    return 0
  end
  local self_state = role:QueryProp("TeamFacultyState")
  if nx_int(self_state) ~= nx_int(0) then
    return 0
  end
  return 1
end
function is_human_type(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local game_client = nx_value("game_client")
  if nx_id_equal(role, target) then
    return 0
  end
  local config_id = target:QueryProp("ConfigID")
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return 0
  end
  local exist = item_query:FindItemByConfigID(nx_string(config_id))
  if not exist then
    return 0
  end
  local text = item_query:GetItemPropByConfigID(nx_string(config_id), nx_string("script"))
  if text ~= "CommonNpc" then
    return 0
  end
  local karma = target:QueryProp("HasKarma")
  if 0 >= tonumber(karma) then
    return 0
  end
  return 1
end
function is_visible_npc_friend_add_menu(role, target)
  if is_human_type(role, target) == 0 then
    return 0
  end
  local config_id = target:QueryProp("ConfigID")
  local index = role:FindRecordRow("rec_npc_relation", 0, config_id)
  if index < 0 then
    return 0
  else
    if role:QueryRecord("rec_npc_relation", index, 3) == 0 then
      return 0
    end
    local ini = nx_create("IniDocument")
    ini.FileName = nx_resource_path() .. "share\\Karma\\karma_config.ini"
    if not ini:LoadFromFile() then
      return 0
    end
    local friend_value = ini:ReadInteger("NPC_RELATION_FRIEND", "Value", 0)
    local relation_karma = role:QueryRecord("rec_npc_relation", index, 2)
    if friend_value >= relation_karma then
      return 0
    end
  end
  return 1
end
function is_visible_npc_buddy_add_menu(role, target)
  if is_human_type(role, target) == 0 then
    return 0
  end
  local config_id = target:QueryProp("ConfigID")
  local index = role:FindRecordRow("rec_npc_relation", 0, config_id)
  if index < 0 then
    return 0
  else
    if role:QueryRecord("rec_npc_relation", index, 3) == 1 then
      return 0
    end
    local ini = nx_create("IniDocument")
    ini.FileName = nx_resource_path() .. "share\\Karma\\karma_config.ini"
    if not ini:LoadFromFile() then
      return 0
    end
    local buddy_value = ini:ReadInteger("NPC_RELATION_BUDDY", "Value", 0)
    local relation_karma = role:QueryRecord("rec_npc_relation", index, 2)
    if buddy_value >= relation_karma then
      return 0
    end
  end
  return 1
end
function is_visible_npc_attention_add_menu(role, target)
  if is_human_type(role, target) == 0 then
    return 0
  end
  local config_id = target:QueryProp("ConfigID")
  local index = role:FindRecordRow("rec_npc_attention", 0, config_id)
  if 0 <= index then
    return 0
  end
  return 1
end
function is_visible_npc_relation_cut_menu(role, target)
  if is_human_type(role, target) == 0 then
    return 0
  end
  local config_id = target:QueryProp("ConfigID")
  local index = role:FindRecordRow("rec_npc_relation", 0, config_id)
  if index < 0 then
    return 0
  end
  local relation_type = role:QueryRecord("rec_npc_relation", index, 3)
  if relation_type ~= 1 and relation_type ~= 0 then
    return 0
  end
  return 1
end
function is_visible_npc_attention_remove_menu(role, target)
  if is_human_type(role, target) == 0 then
    return 0
  end
  local config_id = target:QueryProp("ConfigID")
  local index = role:FindRecordRow("rec_npc_attention", 0, config_id)
  if index < 0 then
    return 0
  end
  return 1
end
function is_visible_npc_gift_add_menu(role, target)
  if is_human_type(role, target) == 0 then
    return 0
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return 0
  end
  if not condition_manager:CanSatisfyCondition(role, role, nx_int(26536)) then
    return 0
  end
  return 1
end
function is_visible_cure_hero_npc_add_menu(role, target)
  local type_ = target:QueryProp("NpcType")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if type_ ~= 401 then
    return 0
  end
  if client_player:FindProp("Mount") and 0 < string.len(client_player:QueryProp("Mount")) then
    return 0
  end
  local npc_buffer = nx_function("find_buffer", target, WORLD_WAR_HERO_HURT_BUFF)
  if not npc_buffer then
    return 0
  end
  return 1
end
function is_visible_npc_good_feeling_add_menu(role, target)
  if is_human_type(role, target) == 0 then
    return 0
  end
  return 1
end
function is_visible_far_npc_avenge_serve_menu(role, target)
  local npc_id = nx_string(target)
  if not nx_execute("form_stage_main\\form_relation\\form_avenge_search", "is_avenge_npc", npc_id) then
    return 0
  end
  return 1
end
function is_visible_far_add_npc_friend_menu(role, target)
  local config_id = nx_string(target)
  local index = role:FindRecordRow("rec_npc_relation", 0, config_id)
  if index < 0 then
    return 0
  else
    if role:QueryRecord("rec_npc_relation", index, 3) == 0 then
      return 0
    end
    local ini = nx_create("IniDocument")
    ini.FileName = nx_resource_path() .. "share\\Karma\\karma_config.ini"
    if not ini:LoadFromFile() then
      return 0
    end
    local friend_value = ini:ReadInteger("NPC_RELATION_FRIEND", "Value", 0)
    local relation_karma = role:QueryRecord("rec_npc_relation", index, 2)
    if friend_value >= relation_karma then
      return 0
    end
  end
  return 1
end
function is_visible_far_add_npc_buddy_menu(role, target)
  local config_id = nx_string(target)
  local index = role:FindRecordRow("rec_npc_relation", 0, config_id)
  if index < 0 then
    return 0
  else
    if role:QueryRecord("rec_npc_relation", index, 3) == 1 then
      return 0
    end
    local ini = nx_create("IniDocument")
    ini.FileName = nx_resource_path() .. "share\\Karma\\karma_config.ini"
    if not ini:LoadFromFile() then
      return 0
    end
    local buddy_value = ini:ReadInteger("NPC_RELATION_BUDDY", "Value", 0)
    local relation_karma = role:QueryRecord("rec_npc_relation", index, 2)
    if buddy_value >= relation_karma then
      return 0
    end
  end
  return 1
end
function is_visible_far_add_npc_attention_menu(role, target)
  local config_id = nx_string(target)
  local index = role:FindRecordRow("rec_npc_attention", 0, config_id)
  if 0 <= index then
    return 0
  end
  return 1
end
function is_visible_far_cut_npc_relation_menu(role, target)
  local config_id = nx_string(target)
  local index = role:FindRecordRow("rec_npc_relation", 0, config_id)
  if index < 0 then
    return 0
  end
  local relation_type = role:QueryRecord("rec_npc_relation", index, 3)
  if relation_type ~= 1 and relation_type ~= 0 then
    return 0
  end
  return 1
end
function is_visible_far_remove_npc_attention_menu(role, target)
  local config_id = nx_string(target)
  local index = role:FindRecordRow("rec_npc_attention", 0, config_id)
  if index < 0 then
    return 0
  end
  return 1
end
function is_visible_far_give_npc_gift_menu(role, target)
  local config_id = nx_string(target)
  local index_1 = role:FindRecordRow("rec_npc_relation", 0, config_id)
  local index_2 = role:FindRecordRow("rec_npc_attention", 0, config_id)
  if index_1 < 0 and index_2 < 0 then
    return 0
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return 0
  end
  if not condition_manager:CanSatisfyCondition(role, role, nx_int(26536)) then
    return 0
  end
  return 1
end
function is_visible_far_look_npc_info_menu(role, target)
  return 1
end
function is_visible_far_npc_good_feeling_add_menu(role, target)
  return 1
end
function is_visible_multi_ride_menu(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local target_type = target:QueryProp("Type")
  if target_type ~= 2 then
    return 0
  end
  local targetName = target:QueryProp("Name")
  local target_row = role:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(targetName))
  if target_row < 0 then
    return 0
  end
  local selfRiding = role:QueryProp("Mount")
  if string.len(selfRiding) == 0 or selfRiding == 0 then
    return 0
  end
  local is_use_saddle = role:QueryProp("Saddle")
  if string.len(is_use_saddle) == 0 or is_use_saddle == 0 then
    return 0
  end
  if 0 < role:QueryProp("RideLinkState") or 0 < target:QueryProp("RideLinkState") then
    return 0
  end
  local targetRiding = target:QueryProp("Mount")
  if string.len(targetRiding) == 0 or targetRiding == 0 then
    return 1
  end
  return 0
end
function is_visible_chat_panel_secret_chat(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and (nx_string(target.mark_type) == nx_string("filter") or nx_string(target.mark_type) == nx_string("filter_native")) then
    return 0
  end
  return 1
end
function is_visible_chat_panel_request_team(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") then
    if nx_find_custom(target, "mark_type") and (nx_string(target.mark_type) == nx_string("enemy") or nx_string(target.mark_type) == nx_string("blood")) then
      return 0
    end
    if nx_find_custom(target, "is_online") and target.is_online then
      return 1
    end
  end
  return 0
end
function is_visible_chat_panel_send_mail(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and (nx_string(target.mark_type) == nx_string("enemy") or nx_string(target.mark_type) == nx_string("blood") or nx_string(target.mark_type) == nx_string("filter") or nx_string(target.mark_type) == nx_string("filter_native")) then
    return 0
  end
  return 1
end
function is_visible_chat_panel_invite_member(role, target)
  local self_guild = role:QueryProp("GuildName")
  local b_have_guild = false
  if not nx_ws_equal(nx_widestr(self_guild), nx_widestr("")) and not nx_ws_equal(nx_widestr(self_guild), nx_widestr("0")) then
    b_have_guild = true
  end
  if b_have_guild and nx_find_custom(target, "is_online") and target.is_online then
    return 1
  end
  return 0
end
function is_visible_chat_panel_summon_player(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  local cansummon = role:QueryProp("CanSummonInAdve")
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "is_online") and target.is_online and nx_number(cansummon) == 1 then
    return 1
  end
  return 0
end
function is_visible_chat_panel_invite_player(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "is_online") and target.is_online and nx_find_custom(target, "mark_type") and (nx_string(target.mark_type) == nx_string("friend") or nx_string(target.mark_type) == nx_string("buddy")) then
    local game_client = nx_value("game_client")
    local scene = game_client:GetScene()
    local owner_name = ""
    if nx_is_valid(scene) and scene:FindProp("AvatarCloneOwner") then
      owner_name = scene:QueryProp("AvatarCloneOwner")
    end
    local game_role = game_client:GetPlayer()
    local role_name = game_role:QueryProp("Name")
    if nx_widestr(owner_name) == nx_widestr(role_name) then
      return 1
    end
  end
  return 0
end
function is_visible_chat_panel_sanhill_invite(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "is_online") and target.is_online and nx_find_custom(target, "mark_type") and (nx_string(target.mark_type) == nx_string("friend") or nx_string(target.mark_type) == nx_string("buddy")) then
    local game_client = nx_value("game_client")
    local scene = game_client:GetScene()
    local owner_name = ""
    if nx_is_valid(scene) and scene:FindProp("SanHillPlayer") then
      owner_name = scene:QueryProp("SanHillPlayer")
    end
    local game_role = game_client:GetPlayer()
    local role_name = game_role:QueryProp("Name")
    if nx_widestr(owner_name) == nx_widestr(role_name) then
      return 1
    end
  end
  return 0
end
function is_visible_chat_panel_teacher_invite(role, target)
  if not nx_is_valid(role) or not nx_is_valid(target) then
    return 0
  end
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return 0
  end
  if not nx_find_custom(target, "is_online") or not nx_find_custom(target, "ctrltype") then
    return 0
  end
  if interactmgr:GetInteractStatus(ITT_TEACH_EXAM) ~= PIS_IN_GAME then
    return 0
  end
  if target.is_online and nx_name(target) == "GroupBox" and nx_string(target.ctrltype) == "item" then
    local is_teacher_of = nx_execute("form_stage_main\\form_chat_system\\chat_util_define", "is_teacher_of", target.lbl_name.Text)
    return is_teacher_of
  end
  return 0
end
function is_visible_chat_panel_home_game_invite(role, target)
  if not nx_is_valid(role) or not nx_is_valid(target) then
    return 0
  end
  local can_invite = role:QueryProp("HomeFengShuiGameInviteType")
  if can_invite <= 0 then
    return 0
  end
  if not (nx_find_custom(target, "is_online") and nx_find_custom(target, "ctrltype")) or not nx_find_custom(target, "mark_type") then
    return 0
  end
  if target.is_online and nx_name(target) == "GroupBox" and nx_string(target.ctrltype) == "item" then
    return nx_string(target.mark_type) == nx_string("friend") or nx_string(target.mark_type) == nx_string("buddy")
  end
  return 0
end
function is_visible_chat_panel_update_zhiyou(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("friend") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_delete_friend(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("friend") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_down_haoyou(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("buddy") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_delete_buddy(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("buddy") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_update_xuechou(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("enemy") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_delete_enemy(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("enemy") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_down_choujia(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("blood") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_delete_blood(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("blood") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_add_friend(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and (nx_string(target.mark_type) == nx_string("acquaint") or nx_string(target.mark_type) == nx_string("attention")) then
    return 1
  end
  return 0
end
function is_visible_chat_panel_delete_attention(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("attention") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_delete_acquaint(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("acquaint") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_jiawei_filter(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("acquaint") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_delete_filter(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("filter") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_delete_filter_native(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and nx_string(target.mark_type) == nx_string("filter_native") then
    return 1
  end
  return 0
end
function is_visible_chat_panel_game_info_look(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") then
    if nx_find_custom(target, "mark_type") and (nx_string(target.mark_type) == nx_string("filter") or nx_string(target.mark_type) == nx_string("filter_native")) then
      return 0
    end
    if nx_find_custom(target, "is_online") and not target.is_online then
      return 0
    end
  end
  return 1
end
function is_visible_chat_group_request_team(role, target)
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "online_state") and nx_int(target.online_state) == nx_int(1) then
    return 1
  end
  return 0
end
function is_visible_pupil_baishi(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local target_type = target:QueryProp("Type")
  if target_type ~= 2 then
    return 0
  end
  local targetName = target:QueryProp("Name")
  local target_row = role:FindRecordRow("TeacherPupilRelationList", 0, nx_widestr(targetName))
  if 0 < target_row then
    return 0
  end
  local target_row = role:FindRecordRow("TeacherPupilRelationList", 1, 2)
  if 0 < target_row then
    return 0
  end
  return 1
end
function is_visible_shou_tu(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local target_type = target:QueryProp("Type")
  if target_type ~= 2 then
    return 0
  end
  local targetName = target:QueryProp("Name")
  local target_row = role:FindRecordRow("TeacherPupilRelationList", 0, nx_widestr(targetName))
  if 0 < target_row then
    return 0
  end
  local target_row = role:FindRecordRow("TeacherPupilRelationList", 1, 1)
  if 0 < target_row then
    return 0
  end
  return 1
end
function is_visible_pet_gone_menu(role, target)
  if not target:FindProp("Master") then
    return 0
  end
  local master = target:QueryProp("Master")
  if nx_ws_equal(nx_widestr(master), nx_widestr("")) then
    return 0
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindProp("Name") then
    return 0
  end
  local name = client_player:QueryProp("Name")
  if nx_ws_equal(nx_widestr(name), nx_widestr("")) then
    return 0
  end
  if not nx_ws_equal(nx_widestr(name), nx_widestr(master)) then
    return 0
  end
  if nx_string(target:QueryProp("ConfigID")) == nx_string("pet_diao_gensui_1") then
    return 0
  end
  return 1
end
function is_visible_dismiss_normalpet_menu(role, target)
  if not target:FindProp("Master") then
    return 0
  end
  local master = target:QueryProp("Master")
  if nx_ws_equal(nx_widestr(master), nx_widestr("")) then
    return 0
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindProp("Name") then
    return 0
  end
  local name = client_player:QueryProp("Name")
  if nx_ws_equal(nx_widestr(name), nx_widestr("")) then
    return 0
  end
  if not nx_ws_equal(nx_widestr(name), nx_widestr(master)) then
    return 0
  end
  return 1
end
function is_visible_open_depot_menu(role, target)
  if not target:FindProp("Master") then
    return 0
  end
  local master = target:QueryProp("Master")
  if nx_ws_equal(nx_widestr(master), nx_widestr("")) then
    return 0
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindProp("Name") then
    return 0
  end
  local name = client_player:QueryProp("Name")
  if nx_ws_equal(nx_widestr(name), nx_widestr("")) then
    return 0
  end
  if not nx_ws_equal(nx_widestr(name), nx_widestr(master)) then
    return 0
  end
  local pet_type = target:QueryProp("NpcType")
  if pet_type ~= 704 then
    return 0
  end
  return 1
end
function is_visible_player_report_ad(role, target)
  return 0
end
function is_visible_chit_report_ad(role, target)
  local switchmgr = nx_value("SwitchManager")
  if nx_is_valid(switchmgr) then
    local enable = switchmgr:CheckSwitchEnable(ST_FUNCTION_GMCC_JUBAO)
    if not enable then
      return 0
    end
  end
  if nx_is_valid(target) and nx_name(target) == "MultiTextBox" and nx_find_custom(target, "report_index") and nx_find_custom(target, "report_name") then
    return 1
  end
  return 0
end
function is_visible_schoolfight_kick(role, target)
  if not nx_is_valid(role) or not nx_is_valid(target) then
    return 0
  end
  if target:QueryProp("Type") ~= 2 then
    return 0
  end
  local self_side = role:QueryProp("ArenaSide")
  local target_side = target:QueryProp("ArenaSide")
  if self_side ~= target_side then
    return 0
  end
  local result = nx_execute("form_stage_main\\form_school_fight\\form_school_fight_map", "CanKickTarget")
  if not result then
    return 0
  end
  return 1
end
function is_visible_schoolfight_report(role, target)
  if not nx_is_valid(role) or not nx_is_valid(target) then
    return 0
  end
  if target:QueryProp("Type") ~= 2 then
    return 0
  end
  local self_side = role:QueryProp("ArenaSide")
  local target_side = target:QueryProp("ArenaSide")
  if self_side ~= target_side then
    return 0
  end
  if role:QueryProp("IsInSchoolFight") ~= 1 then
    return 0
  end
  return 1
end
function is_visible_schoolfight_rank_kick(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  if nx_ws_equal(nx_widestr(target), nx_widestr("")) then
    return 0
  end
  local result = nx_execute("form_stage_main\\form_school_fight\\form_school_fight_map", "CanKickTarget")
  if not result then
    return 0
  end
  return 1
end
function is_visible_make_item(role, target)
  if not target:FindProp("Force") then
    return 0
  end
  local force = target:QueryProp("Force")
  if nx_string(force) ~= nx_string("force_taohua") then
    return 0
  end
  return 1
end
function is_visible_sale_home(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  if nx_number(target) ~= nx_number(3) then
    return 0
  end
  return 1
end
function is_visible_home_setca(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  if nx_number(target) ~= nx_number(3) then
    return 0
  end
  return 1
end
function is_visible_home_equip_exchange(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  if nx_number(target) ~= nx_number(2) then
    return 0
  end
  return 1
end
function is_visible_home_equip_split(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  if nx_number(target) ~= nx_number(2) then
    return 0
  end
  return 1
end
function is_visible_home_equip_composite(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  if nx_number(target) ~= nx_number(2) then
    return 0
  end
  return 1
end
function is_visible_home_weapon_reset(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  if nx_number(target) ~= nx_number(2) then
    return 0
  end
  return 1
end
function is_visible_home_clothes_reset(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  if nx_number(target) ~= nx_number(2) then
    return 0
  end
  return 1
end
function is_visible_home_move(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if not target:FindProp("ConfigID") then
    return 0
  end
  local config_id = target:QueryProp("ConfigID")
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return 0
  end
  local script = ItemsQuery:GetItemPropByConfigID(config_id, "script")
  if nx_string(script) == nx_string("HomeToolBoxNpc") then
    return 0
  end
  if HomeManager:IsMyHome() then
  elseif HomeManager:IsPartnerHome() then
    if nx_string(script) == nx_string("HomeWuXueNpc") then
      return 0
    end
  else
    return 0
  end
  return 1
end
function is_visible_home_back(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if not target:FindProp("ConfigID") then
    return 0
  end
  local config_id = target:QueryProp("ConfigID")
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return 0
  end
  local script = ItemsQuery:GetItemPropByConfigID(config_id, "script")
  if nx_string(script) == nx_string("HomeToolBoxNpc") then
    return 0
  elseif nx_string(script) == nx_string("HomeWuXueNpc") then
    return 0
  elseif nx_string(script) == nx_string("InterFurnNpc") and target:FindProp("InterFurnType") and nx_number(target:QueryProp("InterFurnType")) == nx_number(6) then
    return 0
  end
  if not HomeManager:IsMyHome() and not HomeManager:IsPartnerHome() then
    return 0
  end
  return 1
end
function is_visible_home_del(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if not target:FindProp("ConfigID") then
    return 0
  end
  local config_id = target:QueryProp("ConfigID")
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return 0
  end
  local script = ItemsQuery:GetItemPropByConfigID(config_id, "script")
  if nx_string(script) == nx_string("HomeToolBoxNpc") then
    return 0
  elseif nx_string(script) == nx_string("HomeWuXueNpc") then
    return 0
  end
  if not HomeManager:IsMyHome() and not HomeManager:IsPartnerHome() then
    return 0
  end
  return 1
end
function is_visible_home_turn_round(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if not target:FindProp("ConfigID") then
    return 0
  end
  local config_id = target:QueryProp("ConfigID")
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return 0
  end
  local script = ItemsQuery:GetItemPropByConfigID(config_id, "script")
  if nx_string(script) == nx_string("HomeToolBoxNpc") then
    return 0
  end
  if HomeManager:IsMyHome() then
  elseif HomeManager:IsPartnerHome() then
    if nx_string(script) == nx_string("HomeWuXueNpc") then
      return 0
    end
  else
    return 0
  end
  return 1
end
function is_visible_invite_guild_war(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local target_guild = target:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(target_guild), nx_widestr("")) == true and nx_ws_equal(nx_widestr(target_guild), nx_widestr("0")) == true then
    return 0
  end
  local self_guild = role:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr(target_guild), nx_widestr(self_guild)) == false then
    return 0
  end
  return 1
end
function is_visible_visit_home(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  local groupid = role:QueryProp("GroupID")
  if nx_int(groupid) == nx_int(-1) then
    return 1
  end
  return 0
end
function is_visible_ssg_yjp(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local newschool = target:QueryProp("NewSchool")
  if nx_string(newschool) == nx_string("newschool_shenshui") then
    return 1
  end
  return 0
end
function is_visible_outland_war_report(role, target)
  if not nx_is_valid(target) then
    return 0
  end
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return 0
  end
  if interactmgr:GetInteractStatus(ITT_OUTLAND_WAR) == PIS_IN_GAME then
    return 1
  end
  return 0
end
function is_visible_chat_panel_rtm_invite(role, target)
  if not nx_is_valid(role) then
    return 0
  end
  if nx_is_valid(target) and nx_name(target) == "GroupBox" and nx_find_custom(target, "ctrltype") and nx_string(target.ctrltype) == nx_string("item") and nx_find_custom(target, "mark_type") and (nx_string(target.mark_type) == nx_string("friend") or nx_string(target.mark_type) == nx_string("buddy")) and nx_execute("form_stage_main\\form_chat_system\\form_chat_panel", "is_can_invite") then
    return 1
  end
  return 0
end
function is_enable_chat_auction(role, target)
  if not nx_is_valid(role) then
    return 2
  end
  local switchmgr = nx_value("SwitchManager")
  if nx_is_valid(switchmgr) then
    local enable = switchmgr:CheckSwitchEnable(ST_FUNCTION_AUCTION_COMPANY)
    if not enable then
      return 1
    end
  end
  return 2
end
function is_visible_member_groupchat_quit(role, item)
  if not nx_is_valid(role) and not nx_is_valid(item) then
    return 0
  end
  if not nx_find_custom(item, "groupid") or not nx_find_custom(item, "target") then
    return 0
  end
  if nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "is_groupchat_master", item.groupid) then
    return 0
  end
  if not nx_ws_equal(role:QueryProp("Name"), item.target) then
    return 0
  end
  return 1
end
function is_visible_member_groupchat_del_member(role, item)
  if not nx_is_valid(role) and not nx_is_valid(item) then
    return 0
  end
  if not nx_find_custom(item, "groupid") or not nx_find_custom(item, "target") then
    return 0
  end
  if nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "is_groupchat_master", item.groupid) and not nx_ws_equal(role:QueryProp("Name"), item.target) then
    return 1
  end
  return 0
end
function is_visible_member_groupchat_del_group(role, item)
  if not nx_is_valid(role) and not nx_is_valid(item) then
    return 0
  end
  if not nx_find_custom(item, "groupid") or not nx_find_custom(item, "target") then
    return 0
  end
  if not nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "is_groupchat_master", item.groupid) then
    return 0
  end
  if not nx_ws_equal(role:QueryProp("Name"), item.target) then
    return 0
  end
  return 1
end
function is_visible_groupchat_quit(role, item)
  if not nx_is_valid(role) and not nx_is_valid(item) then
    return 0
  end
  if not nx_find_custom(item, "groupid") then
    return 0
  end
  if nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "is_groupchat_master", item.groupid) then
    return 0
  end
  return 1
end
function is_visible_groupchat_del_group(role, item)
  if not nx_is_valid(role) and not nx_is_valid(item) then
    return 0
  end
  if not nx_find_custom(item, "groupid") then
    return 0
  end
  if not nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "is_groupchat_master", item.groupid) then
    return 0
  end
  return 1
end
