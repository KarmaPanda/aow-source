require("const_define")
require("util_gui")
require("share\\view_define")
require("share\\itemtype_define")
require("custom_sender")
require("define\\shortcut_key_define")
require("tips_data")
require("form_stage_main\\switch\\switch_define")
require("util_functions")
require("define\\gamehand_type")
require("util_role_prop")
require("menu_game")
FORM_JOB_MAIN_NEW = "form_stage_main\\form_life\\form_job_main_new"
local wa_left = -278
local wa_top = 50
local wa_top_dest = 300
local wa_speed = 5
local form_table_from_new_to_old = {
  show = {
    "form_stage_main\\form_task\\form_task_trace"
  },
  hide = {},
  close = {},
  open = {}
}
local form_table_from_old_to_new = {
  show = {
    "form_stage_main\\form_main\\form_main_player",
    "form_stage_main\\form_main\\form_main_func_btns",
    "form_stage_main\\form_main\\form_main_map"
  },
  hide = {
    "form_stage_main\\form_task\\form_task_trace"
  },
  close = {
    "form_stage_main\\form_home\\form_home_enter",
    "form_stage_main\\form_home\\form_home_function",
    "form_stage_main\\form_home\\form_home_model"
  },
  open = {}
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  self.first = true
  self.clicked_index = -1
  self.clicked_btn = nx_null()
  return 1
end
function main_form_open(self)
  update_newjh_groupbox(self)
  self.no_need_motion_alpha = true
  self.first = true
  on_func_btns_init(self)
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
  end
  util_show_form("form_stage_main\\form_main\\form_main_chat", true)
  util_show_form("form_stage_main\\form_main\\form_main_sysinfo", true)
  util_show_form("form_stage_main\\form_main\\form_main_team", true)
  util_show_form("form_stage_main\\form_main\\form_main_map", true)
  util_show_form("form_stage_main\\form_main\\form_main_select", true)
  util_show_form("form_stage_main\\form_main\\form_main_trumpet", true, "", true)
  util_show_form("form_stage_main\\form_main\\form_main_trumpet_cross", true)
  util_show_form("form_stage_main\\form_main\\form_notice_shortcut", true)
  util_show_form("form_stage_main\\form_main\\form_main_func_btns", true)
  util_show_form("form_stage_main\\form_main\\form_main_shortcut_onestep", true)
  util_show_form("form_stage_main\\form_main\\form_main_marry", true)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_laba_info", true, "", "", true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = false
    nx_execute("form_stage_main\\form_main\\form_laba_info", "sync_msg_form_show_status")
  end
  local form_shortcut = util_get_form("form_stage_main\\form_main\\form_main_shortcut", true, false, "", true)
  if nx_is_valid(form_shortcut) then
    form_shortcut:Show()
  end
  local chat_light_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_chat_system\\form_chat_light", true)
  if nx_is_valid(chat_light_form) then
    chat_light_form:Show()
    chat_light_form.Visible = false
  end
  local form_marry = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_laba_info_marry", true)
  if nx_is_valid(form_marry) then
    form_marry:Show()
    form_marry.Visible = false
  end
  local form_sysinfo = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
  if nx_is_valid(form_sysinfo) then
    local game_config_info = nx_value("game_config_info")
    local visible = false
    if nx_is_valid(game_config_info) and nx_find_property(game_config_info, "right_fight_info") then
      visible = game_config_info.right_fight_info == 1 and true or false
    end
    form_sysinfo.info_group.Visible = visible
  end
  util_show_form("form_stage_main\\form_main\\form_main_player", true)
  util_show_form("form_stage_main\\form_main\\form_main_buff", true)
  nx_execute("form_stage_main\\form_tiguan\\form_tiguan_trace", "open_tiguan_trace")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_extraskill", "open_extra_skill")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_copyskill", "open_copy_skill")
  local form = self
  local gui = nx_value("gui")
  nx_set_value(GAME_GUI_MAIN, self)
  nx_execute("form_stage_main\\form_main\\form_main_centerinfo", "init_center_info", self)
  form.group_pk_state.Visible = false
  util_get_global_entity("mplayer_view_manager", "MainPlayerView", true)
  nx_execute("tips_game", "init_tip_game", gui.Desktop)
  nx_execute("form_stage_main\\form_main\\form_main_request", "Init", self)
  nx_execute("form_stage_main\\form_main\\form_main_request_right", "Init", self)
  nx_execute("animation", "load_animation_info")
  nx_execute("form_stage_main\\form_outland\\form_outland_war_title", "check_on_off_this")
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    local ip_address = game_config.login_addr
    local ip_port = game_config.login_port
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("Dead", "int", self, "form_stage_main\\form_main\\form_main", "dead_changed")
    databinder:AddRolePropertyBind("OpenLifeJob", "string", form, nx_current(), "on_update_open_life_flag")
    databinder:AddRolePropertyBind("PowerLevel", "int", form, nx_current(), "on_update_power_level")
    databinder:AddRolePropertyBind("DongFangNum", "int", form, nx_current(), "on_show_dongfang")
    databinder:AddRolePropertyBind("IsInShijiaQte", "int", self, nx_current(), "IsInShijiaQte_changed")
    databinder:AddRolePropertyBind("ShijiaQteCurState", "int", self, nx_current(), "ShijiaQteCurState_changed")
    databinder:AddRolePropertyBind("CrossType", "int", self, nx_current(), "on_cross_type_changed")
  end
  check_shortcut_ride(self)
  check_be_shortcut_ride(self)
  check_sable_state(self)
  change_size()
  self.btn_server.Visible = false
  self.gb_world_auction.Visible = false
  init_form_main_logic()
  self.lbl_life_tip.Visible = false
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  add_bind_btn_life_fight(self)
  form.lbl_sns_news.Visible = false
  bind_rec_npc_relation(self)
  self.btn_need_repair.Visible = false
  set_gm_btn_image(form)
  form.btn_freshman.Visible = false
  form.btn_mutual_end.Visible = false
  if nx_find_custom(form, "web_view_yy") then
    form.web_view_yy.Visible = false
    form.web_view_yy:AddWebCallBack("jy_que_web_close", nx_current(), "web_close_form")
  end
  local switch_manager = nx_value("SwitchManager")
  local is_open = switch_manager:CheckSwitchEnable(ST_NORMAL_YY_GUILD)
  change_switch(ST_NORMAL_YY_GUILD, is_open)
  local mgr = nx_value("SwitchManager")
  if nx_is_valid(mgr) then
    local flag = mgr:CheckSwitchEnable(ST_FUNCTION_BATTLEFIELD)
    if flag then
      form.lbl_bf_text.ForeColor = "255,147,123,99"
      form.lbl_bf_png.BackImage = "gui\\special\\btn_main\\battle_out.png"
    else
      form.lbl_bf_text.ForeColor = "160,128,128,128"
      form.lbl_bf_png.BackImage = "gui\\special\\btn_main\\battle_jin.png"
    end
  end
  local l, t = load_dbomall_location()
  form.groupbox_dbomall.Top = t
  form.groupbox_dbomall.Left = l
  local m, n = load_show_update_location()
  form:ToFront(form.groupbox_dbomall)
  form:ToFront(form.btn_func_guide)
  form:ToFront(form.groupbox_show_update)
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and not game_config.show_activity then
    game_config.show_activity = true
  end
  refesh_happy_miaohui()
  local timer = nx_value(GAME_TIMER)
  local form_main_logic = nx_value("form_main_logic")
  if not nx_is_valid(form_main_logic) then
    return 1
  end
  form_main_logic:refresh_control()
  if nx_is_valid(timer) and not form_main_logic:fit_all_condition() then
    timer:Register(5000, -1, nx_current(), "form_refresh", form, -1, -1)
  end
  form.rbtn_fight.Checked = true
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return
  end
  show_jh_tour_info()
  is_show_donghai_activity_btn()
  bind_record_call_back(self)
  local need_show_tvt_update = nx_execute("form_stage_main\\form_tvt\\form_tvt_news", "is_need_tips")
  form.btn_news.Visible = need_show_tvt_update
  local cross_server_manager = nx_value("CrossServerManager")
  if nx_is_valid(cross_server_manager) and cross_server_manager:IsInBalanceCross() then
    form.btn_news.Visible = false
  end
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", form, nx_current(), "update_newjh_groupbox")
  end
  set_btn_bzt_visible(false)
  show_btn_ident(false)
  form.lbl_nts_select.Visible = false
  nx_execute("form_stage_main\\form_activity\\form_activity_new_terms_registration", "start_bind_table", form.lbl_nts_select)
  set_btn_wiki_location(form)
  local ST_FUNCTION_SIGN_N_DRAW = 899
  local SwitchManager = nx_value("SwitchManager")
  form.groupbox_sign_n_draw.Visible = nx_boolean(SwitchManager:CheckSwitchEnable(ST_FUNCTION_SIGN_N_DRAW))
  form.lbl_snd_select.Visible = false
  nx_execute("form_stage_main\\form_dbomall\\form_sign_and_draw", "refresh_activity_snd_reward_status")
  nx_execute("custom_sender", "custom_world_auction", 7)
  show_sanhill_visible(self, false)
  nx_execute("custom_sender", "custom_ver_201904", 1)
  return 1
end
function main_form_close(form)
  local funcbtns = nx_value("form_main_func_btns")
  if nx_is_valid(funcbtns) then
    nx_destroy(funcbtns)
  end
  form.first = true
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelTableBind("job_rec", form)
  end
  local timer = nx_value(GAME_TIMER)
  local game_client = nx_value("game_client")
  local toolbox_view_ids = {
    VIEWPORT_EQUIP_TOOL,
    VIEWPORT_TOOL,
    VIEWPORT_MATERIAL_TOOL,
    VIEWPORT_TASK_TOOL
  }
  for _, view_id in ipairs(toolbox_view_ids) do
    local toolbox_view = game_client:GetView(nx_string(view_id))
    if nx_is_valid(toolbox_view) then
      for i = 1, toolbox_view.Capacity do
        local view_item = toolbox_view:GetViewObj(nx_string(i))
        if nx_is_valid(view_item) then
          local item_type = view_item:QueryProp("ItemType")
          if item_type == ITEMTYPE_ADDBAG then
            timer:UnRegister("form_stage_main\\form_bag", "show_info", view_item)
          end
        end
      end
    end
  end
  local addtoolbox_view_ids = {
    VIEWPORT_EQUIP_TOOL,
    VIEWPORT_TOOL,
    VIEWPORT_MATERIAL_TOOL,
    VIEWPORT_TASK_TOOL
  }
  for _, view_id in ipairs(addtoolbox_view_ids) do
    local addtoolbox_view = game_client:GetView(nx_string(view_id))
    if nx_is_valid(addtoolbox_view) then
      for i = 1, addtoolbox_view.Capacity do
        local view_item = addtoolbox_view:GetViewObj(nx_string(i))
        if nx_is_valid(view_item) then
          timer:UnRegister("form_stage_main\\form_bag", "show_info", view_item)
        end
      end
    end
  end
  nx_execute("form_stage_main\\form_main\\form_main_centerinfo", "clear_center_info", form)
  nx_execute("form_stage_main\\form_main\\form_main_request", "clear_request")
  nx_execute("form_stage_main\\form_main\\form_main_request_right", "clear_request")
  move_over()
  local form_logic = nx_value("form_main_logic")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  timer:UnRegister(nx_current(), "form_refresh", form)
  timer:UnRegister(nx_current(), "gb_world_auction_drop", form)
  timer:UnRegister(nx_current(), "sanhill_delay_close", form)
end
function on_main_form_shut(self, parent)
end
function check_groupbox_4()
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  local cross_server_manager = nx_value("CrossServerManager")
  if not nx_is_valid(cross_server_manager) then
    return
  end
  if cross_server_manager:IsInBalanceCross() then
    form.btn_news.Visible = false
    form.groupbox_openweb.Visible = false
    form.groupbox_4.Visible = false
    form.gb_balance.Visible = true
  else
    local need_show_tvt_update = nx_execute("form_stage_main\\form_tvt\\form_tvt_news", "is_need_tips")
    form.btn_news.Visible = need_show_tvt_update
    form.groupbox_openweb.Visible = true
    form.groupbox_4.Visible = true
    form.gb_balance.Visible = false
  end
  local homeid = get_current_homeid()
  if homeid ~= nx_string("") then
    nx_execute("form_stage_main\\form_home\\form_home_enter", "hide_main_form_control")
  end
end
function get_current_homeid()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp("CurHomeUID") then
    return ""
  end
  return nx_string(client_player:QueryProp("CurHomeUID"))
end
function on_cross_type_changed(form, prop_name, prop_type, prop_value)
  check_groupbox_4()
end
function on_tvt_changed(form, prop_name, prop_type, prop_value)
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return
  end
  if nx_int(interactmgr:GetCurrentTvtType()) == nx_int(ITT_GEW) then
    form.gb_gew.Visible = true
    local game_client = nx_value("game_client")
    local scene_obj = game_client:GetScene()
    local defend_guild = nx_widestr(scene_obj:QueryProp("GewDefendGuild"))
    local old_guild = nx_widestr(scene_obj:QueryProp("GewOldGuild"))
    local dragon_hp = nx_int(scene_obj:QueryProp("GewDragonHP"))
    local stage = nx_int(scene_obj:QueryProp("GewStage"))
    local snatch_guild = nx_widestr(scene_obj:QueryProp("GewSnatchGuild"))
    local snatch_sec = nx_int(scene_obj:QueryProp("GewSnatchSec"))
    local snatch_lose_sec = nx_int(scene_obj:QueryProp("GewSnatchLoseSec"))
    update_gew(defend_guild, old_guild, dragon_hp, stage, snatch_guild, snatch_sec, snatch_lose_sec)
  else
    form.gb_gew.Visible = false
  end
  if nx_int(interactmgr:GetCurrentTvtType()) == nx_int(ITT_SEEK_EMPEROR_CITY) then
    form.gb_sec.Visible = true
    local game_client = nx_value("game_client")
    local scene_obj = game_client:GetScene()
    local round = nx_number(scene_obj:QueryProp("SecRound"))
    local floor = nx_number(scene_obj:QueryProp("SecFloor"))
    local f0_end = nx_double(scene_obj:QueryProp("SecF0End"))
    local round_time = nx_number(scene_obj:QueryProp("SecRoundTime"))
    local f1_kill = nx_number(scene_obj:QueryProp("SecF1Kill"))
    local f1_kill_max = nx_number(scene_obj:QueryProp("SecF1KillMax"))
    local f2_mine = nx_number(scene_obj:QueryProp("SecF2Mine"))
    local f2_mine_max = nx_number(scene_obj:QueryProp("SecF2MineMax"))
    local f3_set_c4 = nx_number(scene_obj:QueryProp("SecF3SetC4"))
    local f3_sec = nx_number(scene_obj:QueryProp("SecF3Sec"))
    local f4_kill = nx_number(scene_obj:QueryProp("SecF4Kill"))
    local f4_kill_max = nx_number(scene_obj:QueryProp("SecF4KillMax"))
    local f5_kill = nx_number(scene_obj:QueryProp("SecF5Kill"))
    local f5_kill_max = nx_number(scene_obj:QueryProp("SecF5KillMax"))
    local f6_end = nx_double(scene_obj:QueryProp("SecF6End"))
    local floor_win = nx_number(scene_obj:QueryProp("SecFloorWin"))
    update_sec(round, floor, f0_end, round_time, f1_kill, f1_kill_max, f2_mine, f2_mine_max, f3_set_c4, f3_sec, f4_kill, f4_kill_max, f5_kill, f5_kill_max, f6_end, floor_win)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "timer_sec", form)
      timer:Register(1000, -1, nx_current(), "timer_sec", form, -1, -1)
    end
  else
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "timer_sec", form)
    end
    form.gb_sec.Visible = false
  end
end
function on_cbtn_sec_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.gb_sec.old_height = form.gb_sec.Height
    form.gb_sec.Height = nx_number(cbtn.DataSource)
  else
    form.gb_sec.Height = form.gb_sec.old_height
  end
end
function on_btn_sec_out_click(btn)
  local dialog = nx_execute("form_stage_main\\form_seek_emperor_city\\sec_main_util", "show_dialog", util_text("ui_sec_bac"))
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_sec_back")
  end
end
function timer_sec(form)
  local f0_left_time = nx_number(form.lbl_sec_time_ready.left_time)
  local f6_left_time = nx_number(form.lbl_sec_time_f6.left_time)
  local game_client = nx_value("game_client")
  local scene_obj = game_client:GetScene()
  if not nx_is_valid(scene_obj) then
    return
  end
  if math.mod(f0_left_time, 10) == 0 or f0_left_time <= 0 then
    local f0_end = nx_double(scene_obj:QueryProp("SecF0End"))
    f0_left_time = get_remain_time(f0_end)
  else
    f0_left_time = f0_left_time - 1
  end
  if math.mod(f6_left_time, 10) == 0 or f6_left_time <= 0 then
    local f6_end = nx_double(scene_obj:QueryProp("SecF6End"))
    f6_left_time = get_remain_time(f6_end)
  else
    f6_left_time = f6_left_time - 1
  end
  form.lbl_sec_time_ready.left_time = f0_left_time
  form.lbl_sec_time_ready.Text = nx_widestr(get_time_text(f0_left_time))
  form.lbl_sec_time_f6.left_time = f6_left_time
  form.lbl_sec_time_f6.Text = nx_widestr(get_time_text(f6_left_time))
end
function update_sec(round, floor, f0_end, round_time, f1_kill, f1_kill_max, f2_mine, f2_mine_max, f3_set_c4, f3_sec, f4_kill, f4_kill_max, f5_kill, f5_kill_max, f6_end, floor_win)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "gb_sec") or not nx_is_valid(form.gb_sec) then
    return
  end
  if nx_number(f0_end) == 0 then
    form.lbl_sec_time_ready.left_time = 300
    form.lbl_sec_time_f6.left_time = 0
  else
    form.lbl_sec_time_ready.left_time = get_remain_time(f0_end)
    form.lbl_sec_time_f6.left_time = get_remain_time(f6_end)
  end
  form.lbl_sec_time_ready.Text = nx_widestr(get_time_text(form.lbl_sec_time_ready.left_time))
  form.lbl_sec_time_f6.Text = nx_widestr(get_time_text(form.lbl_sec_time_f6.left_time))
  form.lbl_sec_time_round.Text = nx_widestr(get_time_text(round_time))
  form.lbl_sec_round.Text = nx_widestr(round)
  form.lbl_sec_floor.Text = nx_widestr(util_text("ui_sec_main_title_f" .. nx_string(floor)))
  form.lbl_sec_f1_kill.Text = nx_widestr(util_format_string("ui_sec_main_f1", f1_kill_max - f1_kill))
  form.lbl_sec_f1_kill_max.Text = nx_widestr(f1_kill_max)
  form.lbl_sec_f2_mine.Text = nx_widestr(util_format_string("ui_sec_main_f2", f2_mine, f2_mine_max))
  form.lbl_sec_f2_mine_max.Text = nx_widestr(f2_mine_max)
  form.lbl_sec_f3_c4_time.Text = nx_widestr(util_format_string("ui_sec_main_f3_time", f3_sec))
  if f3_set_c4 == 0 then
    form.lbl_sec_f3_set_c4.Text = nx_widestr(util_text("ui_sec_main_f3_0"))
    form.lbl_sec_f3_c4_time.Visible = false
  else
    form.lbl_sec_f3_set_c4.Text = nx_widestr(util_text("ui_sec_main_f3_1"))
    form.lbl_sec_f3_c4_time.Visible = true
  end
  form.lbl_sec_f4_kill.Text = nx_widestr(f4_kill)
  form.lbl_sec_f4_kill_max.Text = nx_widestr(f4_kill_max)
  if f5_kill ~= f5_kill_max then
    form.lbl_sec_f5_kill.Text = nx_widestr(util_format_string("ui_sec_main_f5_0", f5_kill_max - f5_kill))
  else
    form.lbl_sec_f5_kill.Text = nx_widestr(util_text("ui_sec_main_f5_1"))
  end
  form.lbl_sec_ready.Visible = false
  form.lbl_sec_fight.Visible = false
  form.lbl_sec_price.Visible = false
  form.lbl_sec_time_ready.Visible = false
  form.lbl_sec_time_round.Visible = false
  form.lbl_sec_time_f6.Visible = false
  form.gb_sec_f0.Visible = false
  form.gb_sec_f1.Visible = false
  form.gb_sec_f2.Visible = false
  form.gb_sec_f3.Visible = false
  form.gb_sec_f4.Visible = false
  form.gb_sec_f5.Visible = false
  form.gb_sec_f6.Visible = false
  form.gb_sec_floor_win.Visible = false
  form.btn_sec_out.Visible = false
  if floor_win == 1 then
    form.gb_sec_floor_win.Visible = true
  end
  if 0 == nx_number(floor) then
    form.gb_sec_f0.Visible = not form.gb_sec_floor_win.Visible
    form.lbl_sec_time_ready.Visible = true
    form.lbl_sec_ready.Visible = true
    form.btn_sec_out.Visible = true
  elseif 1 == nx_number(floor) then
    form.gb_sec_f1.Visible = not form.gb_sec_floor_win.Visible
    form.lbl_sec_time_round.Visible = true
    form.lbl_sec_fight.Visible = true
  elseif 2 == nx_number(floor) then
    form.gb_sec_f2.Visible = not form.gb_sec_floor_win.Visible
    form.lbl_sec_time_round.Visible = true
    form.lbl_sec_fight.Visible = true
  elseif 3 == nx_number(floor) then
    form.gb_sec_f3.Visible = not form.gb_sec_floor_win.Visible
    form.lbl_sec_time_round.Visible = true
    form.lbl_sec_fight.Visible = true
  elseif 4 == nx_number(floor) then
    form.gb_sec_f4.Visible = not form.gb_sec_floor_win.Visible
    form.lbl_sec_time_round.Visible = true
    form.lbl_sec_fight.Visible = true
  elseif 5 == nx_number(floor) then
    form.gb_sec_f5.Visible = not form.gb_sec_floor_win.Visible
    form.lbl_sec_time_round.Visible = true
    form.lbl_sec_fight.Visible = true
  elseif 6 == nx_number(floor) then
    form.gb_sec_f6.Visible = not form.gb_sec_floor_win.Visible
    form.lbl_sec_time_f6.Visible = true
    form.lbl_sec_price.Visible = true
  end
end
function update_gew(defend_guild, old_guild, dragon_hp, stage, snatch_guild, snatch_sec, snatch_lose_sec)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "gb_gew_crusade") or not nx_is_valid(form.gb_gew_crusade) then
    return
  end
  if nx_number(stage) == 0 then
    nx_execute("form_stage_main\\form_main\\form_main_map", "show_gew_rank_btn", 1)
    form.gb_gew_crusade.Visible = true
    form.gb_gew_snatch.Visible = false
  elseif nx_number(stage) == 1 then
    nx_execute("form_stage_main\\form_main\\form_main_map", "show_gew_rank_btn", 0)
    form.gb_gew_crusade.Visible = false
    form.gb_gew_snatch.Visible = true
  end
  if nx_widestr(defend_guild) ~= nx_widestr("") and nx_widestr(defend_guild) ~= nx_widestr("0") then
    if nx_number(dragon_hp) == 0 then
      dragon_hp = 100
    end
    form.lbl_gew_defend_guild.Text = nx_widestr(defend_guild)
    form.lbl_gew_dragon_hp.Text = util_format_string("ui_gew_crusade_hp", nx_int(dragon_hp))
    form.pbar_gew_dragon_hp.Value = nx_number(dragon_hp)
  elseif nx_widestr(old_guild) ~= nx_widestr("") and nx_widestr(old_guild) ~= nx_widestr("0") then
    form.lbl_gew_defend_guild.Text = nx_widestr(old_guild)
    form.lbl_gew_dragon_hp.Text = util_format_string("ui_gew_crusade_hp", nx_int(dragon_hp))
    form.pbar_gew_dragon_hp.Value = nx_number(dragon_hp)
  end
  if nx_widestr(snatch_guild) == nx_widestr("") or nx_widestr(defend_guild) == nx_widestr("0") then
    form.lbl_gew_snatch_guild.Text = nx_widestr(util_text("ui_gew_no_snatch_guild"))
    form.lbl_gew_snatch_sec.Text = util_format_string("ui_gew_snatch_sec", nx_int(0))
    form.pbar_gew_snatch_sec.Value = nx_number(0)
  else
    form.lbl_gew_snatch_guild.Text = nx_widestr(snatch_guild)
    local value = snatch_sec - snatch_lose_sec
    form.lbl_gew_snatch_sec.Text = util_format_string("ui_gew_snatch_sec", nx_int(value))
    form.pbar_gew_snatch_sec.Value = nx_number(value)
  end
end
function delete_bag(bag_item, view, index)
  local game_client = nx_value("game_client")
  local toolbox_view_id = ""
  local goods_grid = nx_value("GoodsGrid")
  if nx_is_valid(goods_grid) then
    toolbox_view_id = goods_grid:GetToolBoxViewport(bag_item)
  end
  local beginpos = bag_item:QueryProp("BeginPos")
  local endpos = bag_item:QueryProp("EndPos")
  for i = beginpos, endpos do
    game_client:GetViewObj(nx_string(toolbox_view_id), nx_string(i))
    if nx_is_valid(view_item) then
      return false
    end
  end
  local addtoolbox_view_id = ""
  local goods_grid = nx_value("GoodsGrid")
  if nx_is_valid(goods_grid) then
    addtoolbox_view_id = goods_grid:GetAddToolBoxViewport(bag_item)
  end
  local addtoolbox_view = game_client:GetView(nx_string(addtoolbox_view_id))
  if nx_is_valid(addtoolbox_view) and nx_id_equal(addtoolbox_view, view) then
    nx_execute("custom_sender", "custom_delete_item", addtoolbox_view_id, index, 1)
    return true
  end
  return false
end
function on_btn_balance_click(btn)
  nx_execute("form_stage_main\\form_war_scuffle\\form_balance_total", "open_form")
end
function on_click_btn_selfshop(self)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SELFSHOP))
  if nx_is_valid(view) then
    nx_execute("custom_sender", "custom_stall_stop_stall")
  else
    nx_execute("custom_sender", "custom_stall_open_stall", util_text("ui_Stallbox"))
  end
  return 1
end
function on_click_btn_zhaomu(self)
  util_auto_show_hide_form("form_stage_main\\form_team\\form_team_recruit")
  return 1
end
function get_force()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return "0"
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return "0"
  end
  local playerschool = client_player:QueryProp("Force")
  return nx_string(playerschool)
end
function get_new_school()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return "0"
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return "0"
  end
  local playerschool = client_player:QueryProp("NewSchool")
  return nx_string(playerschool)
end
function on_btn_school_click(self)
  local force = get_force()
  if force ~= "0" and force ~= "" then
    util_auto_show_hide_form("form_stage_main\\form_school_war\\form_new_school_msg_info")
    local form = nx_value("form_stage_main\\form_school_war\\form_new_school_msg_info")
    if nx_is_valid(form) then
      form:Show()
      form.Visible = true
      form.rbtn_m7.Checked = true
    end
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local new_school = get_new_school()
  if "0" ~= new_school and "" ~= new_school then
    local SchoolID = nx_int(get_ini_prop("share\\War\\new_school_config.ini", new_school, "ID", ""))
    if SchoolID < nx_int(1) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("83552"))
      return 0
    end
    util_auto_show_hide_form("form_stage_main\\form_school_war\\form_newschool_school_msg_info")
    local form = nx_value("form_stage_main\\form_school_war\\form_newschool_school_msg_info")
    if nx_is_valid(form) then
      nx_execute("custom_sender", "custom_get_school_msg_info", SchoolID, 0)
      form.SchoolID = SchoolID
      form:Show()
      form.Visible = true
      form.rbtn_m7.Checked = true
    end
    return
  end
  local school = client_player:QueryProp("School")
  local SchoolID = nx_int(get_ini_prop("share\\War\\School_Config.ini", school, "ID", ""))
  if SchoolID < nx_int(1) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("83552"))
    return 0
  end
  local form = util_get_form("form_stage_main\\form_school_war\\form_school_msg_info", true)
  if form.Visible == false then
    nx_execute("custom_sender", "custom_get_school_msg_info", SchoolID, 0)
    form.SchoolID = SchoolID
    util_show_form("form_stage_main\\form_school_war\\form_school_msg_info", true)
  else
    form:Close()
  end
  return 1
end
function on_show_teamrecruit(self)
  util_auto_show_hide_form("form_stage_main\\form_team\\form_team_recruit")
  return 1
end
function on_show_technique(self)
  util_auto_show_hide_form("form_technique")
  return 1
end
function on_show_pk_list(self)
  local form = self.Parent.Parent
  form.group_pk_state.Visible = not form.group_pk_state.Visible
end
function on_pkstate_change(self)
  local newpkstate = nx_int(self.DataSource)
  local oldpkstate = 1
  local pk_name = nx_string(self.Text)
  local pk_mode = nx_int(self.DataSource)
  nx_execute("custom_sender", "custom_set_pkmode", pk_mode)
  self.Parent.Visible = false
end
function reset_scene()
  local gui = nx_value("gui")
  local shortcut_main_form = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if nx_is_valid(shortcut_main_form) then
    gui.shortcut_main_page = shortcut_main_form.grid_shortcut_main.page
    gui.shortcut_fix = shortcut_main_form.btn_fix.Visible
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  if nx_is_valid(form) then
    gui.chat_type = form.chat_edit.chat_type
    gui.chat_btn_Text = form.chat_channel_btn.Text
    gui.chat_btn_ForeColor = form.chat_channel_btn.ForeColor
    gui.chatlist_Width = form.chat_list.Width
    gui.chatlist_Height = form.chat_list.Height
  end
  gui.Desktop:Close()
  gui.Loader:LoadDesktop(nx_resource_path(), gui.skin_path .. "form_stage_main\\form_main\\form_main.xml")
  gui.Desktop.Left = 0
  gui.Desktop.Top = 0
  gui.Desktop.Width = gui.Width
  gui.Desktop.Height = gui.Height
  gui.Desktop.Transparent = true
  gui.Desktop:ShowModal()
end
function clear_save_chat_info(common_array, form)
  for i = 0, form.new_page_count do
    if common_array:FindArray("chat_list" .. nx_string(i)) then
      common_array:RemoveArray("chat_list" .. nx_string(i))
    end
  end
  common_array.edit_info = nil
end
function save_player_chat_info()
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  local common_array = nx_value("common_array")
  if not nx_is_valid(form) or not nx_is_valid(common_array) then
    return
  end
  clear_save_chat_info(common_array, form)
  local list = form.chat_list
  if nx_is_valid(list) then
    save_control_info(common_array, list, "chat_list0")
  end
  for i = 1, form.new_page_count do
    list = form.chat_group:Find("new_chatlist" .. nx_string(nx_int(i)))
    if nx_is_valid(list) then
      save_control_info(common_array, list, "chat_list" .. nx_string(nx_int(i)))
    end
  end
  common_array.edit_info = form.chat_edit.Text
end
function save_fight_system_info()
  local common_array = nx_value("common_array")
  local fight_sys_form = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
  if not nx_is_valid(common_array) or not nx_is_valid(fight_sys_form) then
    return
  end
  if common_array:FindArray("info_list") then
    common_array:RemoveArray("info_list")
  end
  if common_array:FindArray("fight_list") then
    common_array:RemoveArray("fight_list")
  end
  local ctrl_fight = fight_sys_form.fight_list
  local ctrl_sys = fight_sys_form.info_list
  save_control_info(common_array, ctrl_fight, "fight_list")
  save_control_info(common_array, ctrl_sys, "info_list")
end
function save_control_info(common_array, multitext_box, name)
  if not common_array:FindArray(nx_string(name)) then
    common_array:RemoveArray(nx_string(name))
  end
  common_array:AddArray(nx_string(name), common_array, 5000, false)
  if not nx_is_valid(multitext_box) then
    return
  end
  if multitext_box.ItemCount <= 0 then
    return
  end
  for index = 0, multitext_box.ItemCount - 1 do
    common_array:AddChild(name, "info" .. nx_string(index), multitext_box:GetHtmlItemText(index))
    common_array:AddChild(name, "type" .. nx_string(index), multitext_box:GetItemKeyByIndex(index))
  end
end
function dead_changed(form, prop_name, prop_type, prop_value)
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  local delay_time = 3
  if nx_number(prop_value) > 0 then
    common_execute:RemoveExecute("show_dead_form_delay", form)
    common_execute:AddExecute("show_dead_form_delay", form, delay_time, form)
    local form = nx_value("form_stage_main\\form_hurt_danger")
    if nx_is_valid(form) then
      nx_execute("form_stage_main\\form_hurt_danger", "close_relive_form")
    end
  else
    common_execute:RemoveExecute("show_dead_form_delay", form)
    nx_execute("form_stage_main\\form_die_util.lua", "close_dead_form")
  end
end
function check_shortcut_ride(self)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local mount = client_player:QueryProp("Mount")
  if string.len(mount) == 0 or mount == 0 then
    return
  end
  if nx_find_custom(client_player, "mount_name") and 0 < string.len(nx_string(client_player.mount_name)) then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "server_up_special_ride", 2, nx_string(client_player.mount_name))
  end
end
function check_be_shortcut_ride(self)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local ride_state = client_player:QueryProp("RideLinkState")
  if ride_state == 2 then
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "multi_ride_handle", 1)
  end
end
function check_sable_state(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local sable = client_player:QueryProp("Sable")
  if string.len(sable) == 0 or sable == 0 then
    return
  end
  if not client_player:FindRecord("sable_rec") then
    return
  end
  local row = client_player:QueryProp("SableCarryID")
  local row_max = client_player:GetRecordRows("sable_rec")
  if row < 0 or row >= row_max then
    return
  end
  local item_config = client_player:QueryRecord("sable_rec", row, 3)
  local sable_state = client_player:QueryProp("SableState")
  if 0 < nx_number(sable_state) then
    local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_animalkeep\\form_sable_skill", true)
    nx_execute("form_stage_main\\form_animalkeep\\form_sable_skill", "server_open_sable_skill", form, item_config)
  else
    local gui = nx_value("gui")
    local item_name = gui.TextManager:GetText(item_config)
    local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_animalkeep\\form_sable_info", true)
    if nx_is_valid(form) then
      nx_execute("form_stage_main\\form_animalkeep\\form_sable_info", "init_sableinfo", form, item_config, item_name)
    end
  end
end
function on_btn_jianghu_click(self)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_life_click(self)
end
function on_btn_fight_click(self)
end
function fix_btn_life_by_job_rec(form)
  local form_logic = nx_value("form_main_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  local gui = nx_value("gui")
  local has_job = is_study_job()
  local show_flag = form_logic:GetShowFlag()
  if show_flag == 1 then
    form.lbl_flag.Visible = false
  elseif show_flag == 2 then
    if not has_job then
      form.rbtn_life.Enabled = false
      form.lbl_flag.Visible = false
    else
      form.rbtn_life.Enabled = true
      form.lbl_3.Text = nx_widestr(gui.TextManager:GetText("ui_mylife"))
      form.lbl_4.BackImage = "gui\\special\\btn_main\\btn_life_out_36.png"
      local count = nx_execute(FORM_JOB_MAIN_NEW, "get_open_life_flag_count")
      if 0 < count and refresh_condition_func(26001) then
        form.lbl_flag.Visible = true
        form.lbl_flag.Text = nx_widestr(nx_string(count))
      else
        form.lbl_flag.Visible = false
      end
    end
  elseif show_flag == 3 then
  end
end
function fix_btn_fight(form)
  local form_logic = nx_value("form_main_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  local gui = nx_value("gui")
  local show_flag = form_logic:GetShowFlag()
  if show_flag == 1 then
    form.lbl_flag.Visible = false
  elseif show_flag == 2 then
  elseif show_flag == 3 then
  end
end
function change_size()
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_find_custom(form, "groupbox_4") and nx_is_valid(form.groupbox_4) then
    form.groupbox_4.AbsLeft = 0
    form.groupbox_4.AbsTop = gui.Height - form.groupbox_4.Height
  end
  if nx_find_custom(form, "gb_balance") and nx_is_valid(form.gb_balance) then
    form.gb_balance.AbsLeft = 0
    form.gb_balance.AbsTop = gui.Height - form.gb_balance.Height
  end
  if nx_find_custom(form, "groupbox_dbomall") and nx_is_valid(form.groupbox_dbomall) and (form.groupbox_dbomall.Top + form.groupbox_dbomall.Height > gui.Height or form.groupbox_dbomall.Left + form.groupbox_dbomall.Width > gui.Width) then
    form.groupbox_dbomall.Top = 0
    form.groupbox_dbomall.Left = 359
  end
  if nx_find_custom(form, "ani_cd") and nx_is_valid(form.ani_cd) and form.ani_cd.Visible then
    form.ani_cd.AbsLeft = (gui.Width - form.ani_cd.Width) / 2
    form.ani_cd.AbsTop = (gui.Height - form.ani_cd.Height) / 3
  end
  if nx_find_custom(form, "groupbox_kill_num") and nx_is_valid(form.groupbox_kill_num) and form.groupbox_kill_num.Visible then
    form.groupbox_kill_num.AbsLeft = (gui.Width - form.groupbox_kill_num.Width) / 4 * 3
    form.groupbox_kill_num.AbsTop = (gui.Height - form.groupbox_kill_num.Height) / 3
  end
end
function change_state()
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_fight.Checked = true
end
function move_over()
  local form_logic = nx_value("form_main_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  if nx_find_method(form_logic, "Recover") then
    form_logic:Recover()
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "change_form_size")
  end
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(form) then
    fix_btn_life_by_job_rec(form)
    fix_btn_fight(form)
  end
end
function on_btn_system_click(self)
  util_auto_show_hide_form("form_stage_main\\form_system\\form_system_option")
end
function add_bind_btn_life_fight(form_main)
  local data_binder = nx_value("data_binder")
  if not nx_is_valid(data_binder) then
    return
  end
  form_main.init_has_job_rec = is_study_job()
  data_binder:AddTableBind("job_rec", form_main, nx_current(), "reflash_btn_life_fight")
end
function reflash_btn_life_fight(form_main)
  local gui = nx_value("gui")
  local form_logic = nx_value("form_main_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  local show_step = 0
  if nx_find_method(form_logic, "GetShowFlag") then
    show_step = form_logic:GetShowFlag()
  end
  local has_job = is_study_job()
  if show_step == 1 then
    if not has_job then
      form_main.rbtn_fight.Checked = true
    end
  elseif show_step == 2 or show_step == 3 then
    fix_btn_life_by_job_rec(form_main)
    if has_job and not form_main.init_has_job_rec then
      form_main.init_has_job_rec = true
      local timer_game = nx_value("timer_game")
      if nx_is_valid(timer_game) then
        form_main.lbl_life_tip.Visible = true
        timer_game:Register(3000, 1, nx_current(), "del_btn_life_tip", form_main, -1, 1)
      end
    end
  end
end
function del_btn_life_tip(form_main)
  if not nx_is_valid(form_main) then
    return
  end
  local timer_game = nx_value("timer_game")
  if nx_is_valid(timer_game) then
    form_main.lbl_life_tip.Visible = false
    timer_game:UnRegister(nx_current(), "del_btn_life_tip", form_main)
  end
end
function is_study_job()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindRecord("job_rec") then
    return false
  end
  local job_cnt = client_player:GetRecordRows("job_rec")
  if 0 < job_cnt then
    return true
  end
  return false
end
function init_form_main_logic()
  local form_logic = nx_value("form_main_logic")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_main")
  nx_set_value("form_main_logic", form_logic)
end
function on_update_open_life_flag(form)
  local form_logic = nx_value("form_main_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  local show_step = 0
  if nx_find_method(form_logic, "GetShowFlag") then
    show_step = form_logic:GetShowFlag()
  end
  if show_step == 2 or show_step == 3 then
    fix_btn_life_by_job_rec(form)
  end
end
function on_btn_battle_click()
  util_auto_show_hide_form("form_stage_main\\form_tvt\\form_tvt_main")
end
function on_update_power_level(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  if nx_number(prop_value) > 10 then
    local common_execute = nx_value("common_execute")
    if nx_is_valid(common_execute) then
      form.mltbox_battle.vis_time = 0
      form.mltbox_battle.Visible = true
      form.lbl_battle_ani.Visible = true
      common_execute:AddExecute("HelperTips", form.mltbox_battle, nx_float(0), nx_float(10))
    end
  end
  refresh_battlefield_btn_show(form, false)
end
function on_show_dongfang(form, prop_name, prop_type, prop_value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local room_id = client_player:QueryProp("DongFangNum")
  if nx_int(room_id) > nx_int(0) then
    nx_execute("form_stage_main\\form_marry\\form_marry_btns", "show_data", 3, true)
  else
    nx_execute("form_stage_main\\form_marry\\form_marry_btns", "show_data", 3, false)
  end
end
function on_btn_market_click()
  nx_execute("form_stage_main\\form_market\\form_market", "auto_show_hide_form_market")
end
function on_btn_gmhelp_click()
end
function on_btn_guild_click(btn)
  local is_in_guild = nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", "is_in_guild")
  if not is_in_guild then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19025"), 2)
    end
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", "auto_show_hide_form_new_guild")
end
function on_btn_show_declare_click(btn)
  local form = btn.ParentForm
  form.groupbox_declare.Visible = false
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "declare_timer", form)
  end
  if nx_custom(btn, "time") and nx_int(btn.time) > nx_int(0) then
    local form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
    if nx_is_valid(form_guild_domain_map) then
      form_guild_domain_map.Visible = true
    end
  end
end
function declare_timer(form)
  if nx_int(form.btn_show_declare.time) > nx_int(0) then
    form.btn_show_declare.time = form.btn_show_declare.time - 1
    form.lbl_declare_timer.Text = nx_widestr(form.btn_show_declare.time)
  else
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "declare_timer", form)
    end
    form.groupbox_declare.Visible = false
    local form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
    if nx_is_valid(form_guild_domain_map) and not form_guild_domain_map.Visible then
      form_guild_domain_map:Close()
    end
  end
end
function show_declare_btn(time)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(form) or not nx_is_valid(timer) then
    return
  end
  if time <= 0 then
    timer:UnRegister(nx_current(), "declare_timer", form)
    form.groupbox_declare.Visible = false
    return
  end
  form.btn_show_declare.time = time
  form.lbl_declare_timer.Text = nx_widestr(time)
  form.groupbox_declare.Left = -300
  form.groupbox_declare.Top = 100
  timer:Register(1000, -1, nx_current(), "declare_timer", form, -1, -1)
  form.groupbox_declare.Visible = true
end
function set_gm_btn_image(form)
  local gui = nx_value("gui")
  local ver_type = 2
  if ver_type == "0" then
    form.btn_gmhelp.NormalImage = "gui\\special\\help_gm\\btn_gmcc.png"
    form.btn_gmhelp.FocusImage = "gui\\special\\help_gm\\btn_gmcc.png"
    form.btn_gmhelp.PushImage = "gui\\special\\help_gm\\btn_gmcc.png"
    form.btn_gmhelp.HintText = gui.TextManager:GetText("ui_tips_kefu")
  elseif ver_type == "1" then
    form.btn_gmhelp.NormalImage = "gui\\special\\help_gm\\btn_gmcc_sd.png"
    form.btn_gmhelp.FocusImage = "gui\\special\\help_gm\\btn_gmcc_sd.png"
    form.btn_gmhelp.PushImage = "gui\\special\\help_gm\\btn_gmcc_sd.png"
    form.btn_gmhelp.HintText = gui.TextManager:GetText("ui_tips_caihong")
  elseif ver_type == "2" then
    form.btn_gmhelp.NormalImage = "gui\\special\\help_gm\\btn_gmcc.png"
    form.btn_gmhelp.FocusImage = "gui\\special\\help_gm\\btn_gmcc.png"
    form.btn_gmhelp.PushImage = "gui\\special\\help_gm\\btn_gmcc.png"
    form.btn_gmhelp.HintText = gui.TextManager:GetText("ui_tips_kefu")
  end
end
function on_btn_server_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_publish_pop_news")
end
function open_btn_freshman(mark_name)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "btn_freshman") then
    return
  end
  if not nx_is_valid(form.btn_freshman) then
    return
  end
  if not nx_find_custom(form.btn_freshman, "mark_name") then
    return
  end
  form.btn_freshman.mark_name = mark_name
  form.btn_freshman.Visible = true
end
function on_btn_freshman_click(self)
  nx_execute("form_stage_main\\form_main\\form_main_map", "open_form_freshman")
  self.Visible = false
end
function on_btn_chargeshop_click(btn)
  nx_execute("form_stage_main\\form_charge_shop\\form_charge_shop", "open_shop", -1)
end
function on_btn_battlefield_click(btn)
end
function on_btn_open_yy_click(self)
  local form = self.ParentForm
  local game_config = nx_value("game_config")
  local gui = nx_value("gui")
  if not nx_is_valid(game_config) then
    return 1
  end
  form.web_view_yy.Visible = not form.web_view_yy.Visible
  if form.web_view_yy.Visible then
    local server_id = game_config.server_id
    local yy_url = gui.TextManager:GetFormatText("http://9yin.woniu.com/static/act/yy/?area={@0:ID}&server={@0:ID}#", nx_int(server_id), nx_int(server_id))
    form.web_view_yy.Url = yy_url
    form.web_view_yy:Refresh()
    form.web_view_yy:Enable()
  end
end
function web_close_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form.web_view_yy.Visible = false
  else
    nx_execute("form_common\\form_queue", "web_close_form")
  end
end
function change_switch(msg_type, is_open)
end
function bind_rec_npc_relation(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("rec_npc_relation", form, nx_current(), "on_npc_relation_change")
    databinder:AddTableBind("rec_npc_relation_delay", form, nx_current(), "on_npc_relation_change")
  end
end
function on_npc_relation_change(self, recordname, optype, row, clomn)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.lbl_sns_news) then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local npc_list = karmamgr:GetPrizeNpcList()
  local npc_num = table.getn(npc_list)
  if npc_num ~= 0 and refresh_condition_func(26001) then
    form.lbl_sns_news.Visible = true
    form.lbl_sns_news.Text = nx_widestr(npc_num)
  else
    form.lbl_sns_news.Visible = false
  end
end
function show_btn_mutual(vis)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  if vis then
    form.btn_mutual_end.NormalImage = "jiaohu_close"
    form.btn_mutual_end.FocusImage = "jiaohu_close"
    form.btn_mutual_end.PushImage = "jiaohu_close"
  end
  form.btn_mutual_end.Visible = vis
end
function on_btn_mutual_end_click(btn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return true
  end
  local guild_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local show_Info = gui.TextManager:GetText("ui_over_mutual")
  nx_execute("form_common\\form_confirm", "show_common_text", guild_dialog, show_Info)
  guild_dialog:ShowModal()
  guild_dialog.Left = (gui.Width - guild_dialog.Width) / 2
  guild_dialog.Top = (gui.Height - guild_dialog.Height) / 2
  local res = nx_wait_event(100000000, guild_dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_over_mutual_action")
  end
end
function on_btn_need_repair_click()
  local form_role_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_role_info) and nx_is_valid(form_bag) then
    local vis_form_role = form_role_info.Visible
    local vis_form_bag = form_bag.Visible
    if vis_form_role == false and vis_form_bag == true then
      nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
    end
    if vis_form_role == true and vis_form_bag == false then
      nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag")
    end
    if vis_form_role == true and vis_form_bag == true then
      nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
      nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag")
    end
    if vis_form_role == false and vis_form_bag == false then
      nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
      nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag")
    end
  end
end
function refresh_battlefield_btn_show(form, on_complete)
end
function on_btn_act_0_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_LOTTERY) then
    nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "open_form", "form_stage_main\\form_lottery\\form_lottery_main")
  end
end
function on_btn_act_1_click(btn)
  local form = nx_value("form_stage_main\\form_act_grouppurchase")
  if nx_is_valid(form) and form.Visible == true then
    form:Close()
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GROUP_PURCHASE), 0)
end
function on_btn_act_2_click(btn)
  nx_execute("form_stage_main\\form_activity\\form_activity_signin", "open_form")
end
function on_btn_act_3_click(btn)
  nx_execute("custom_sender", "custom_get_power_num")
end
function on_btn_act_4_click(btn)
  if happy_baccy_show_hide() then
    util_auto_show_hide_form("form_stage_main\\form_main\\form_main_happy_baccy_help")
  end
end
function on_btn_act_5_click(btn)
  nx_execute("custom_sender", "custom_get_novice_num")
end
function on_btn_oldserver_click(btn)
  nx_execute("custom_sender", "custom_get_old_num")
end
function on_btn_act_6_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_SNDA_ACTIVITY_SERVER_WISH) then
    nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "open_form", "form_stage_main\\form_activity\\form_activity_seven")
  end
end
function on_btn_act_7_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_SNDA_ACTIVITY_SEEK_MINE) then
    nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "open_form", "form_stage_main\\form_task\\form_seek_mine")
  end
end
function on_btn_act_8_click(btn)
  nx_execute("form_stage_main\\form_activity\\form_activity_login", "open_form")
end
function on_btn_act_9_click(btn)
  nx_execute("form_common\\form_bind_yy", "open_form")
end
function on_btn_act_10_click(btn)
  util_show_form("form_stage_main\\form_enthrall\\form_yytaskcode", true)
end
function on_btn_act_11_click(btn)
  nx_execute("form_stage_main\\form_activity\\form_activity_login_safe", "open_form")
end
function on_btn_act_12_click(btn)
  nx_execute("form_stage_main\\form_activity\\form_activity_answer_join", "open_form")
end
function save_active_location()
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return false
  end
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\form_main.ini"
  ini:LoadFromFile()
  local groupbox_dbomall = form.groupbox_dbomall
  ini:WriteInteger("dbomall", "Left", nx_int(groupbox_dbomall.Left))
  ini:WriteInteger("dbomall", "Top", nx_int(groupbox_dbomall.Top))
  ini:SaveToFile()
  nx_destroy(ini)
end
function save_int_prop_value(section, prop, value)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\form_main.ini"
  ini:LoadFromFile()
  ini:WriteInteger(nx_string(section), nx_string(prop), nx_int(value))
  ini:SaveToFile()
  nx_destroy(ini)
end
function get_int_prop_value(section, prop)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local rst = 0
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\form_main.ini"
    if ini:LoadFromFile() then
      rst = ini:ReadInteger(nx_string(section), nx_string(prop), 0)
    end
  end
  nx_destroy(ini)
  return rst
end
function load_active_location()
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local gui = nx_value("gui")
  local left = 379
  top = 23
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    nx_destroy(ini)
    return left, top
  end
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\form_main.ini"
    if ini:LoadFromFile() then
      left = ini:ReadInteger("active", "Left", left)
      top = ini:ReadInteger("active", "Top", top)
    end
  end
  nx_destroy(ini)
  return left, top
end
function load_update_location()
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local gui = nx_value("gui")
  local left = 437
  top = 23
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    nx_destroy(ini)
    return left, top
  end
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\form_main.ini"
    if ini:LoadFromFile() then
      left = ini:ReadInteger("update", "Left", left)
      top = ini:ReadInteger("update", "Top", top)
    end
  end
  nx_destroy(ini)
  return left, top
end
function load_show_update_location()
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local gui = nx_value("gui")
  local left = 400
  local top = 13
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    nx_destroy(ini)
    return left, top
  end
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\form_main.ini"
    if ini:LoadFromFile() then
      left = ini:ReadInteger("show_update", "Left", left)
      top = ini:ReadInteger("show_update", "Top", top)
    end
  end
  nx_destroy(ini)
  return left, top
end
function on_btn_update_drag_move(btn, x, y)
  local new_x = btn.Left + x
  local new_y = btn.Top + y
  local gui = nx_value("gui")
  if new_x < 0 or new_x > gui.Width or new_y < 0 or new_y > gui.Height then
  end
  btn.Top = new_y
  btn.Left = new_x
end
function on_btn_update_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_main\\form_main_update")
end
function on_btn_weaponandorigin_click(btn)
  local form = nx_value("form_stage_main\\form_advanced_weapon_and_origin")
  if not nx_is_valid(form) or not form.Visible then
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_advanced_weapon_and_origin")
  end
end
function on_btn_act_4_click(btn)
  if happy_baccy_show_hide() then
    util_auto_show_hide_form("form_stage_main\\form_main\\form_main_happy_baccy_help")
  end
end
function happy_baccy_show_hide()
  local mgr = nx_value("SwitchManager")
  if not nx_is_valid(mgr) then
    return false
  end
  return mgr:CheckSwitchEnable(ST_SNDA_HAPPY_BACCY)
end
function refesh_happy_miaohui()
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(form) and nx_is_valid(form.groupbox_6) then
    form.groupbox_6.Visible = happy_baccy_show_hide()
  end
end
function on_btn_smahing_egg_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_SNDA_GEM_EGG_GAME) then
    nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "open_form", "form_stage_main\\puzzle_quest\\form_select_egg")
  end
end
function form_refresh(form)
  local form_main_logic = nx_value("form_main_logic")
  if not nx_is_valid(form_main_logic) then
    return
  end
  if form_main_logic:fit_all_condition() then
    form_refresh_cancel(form)
  end
  form_main_logic:refresh_control()
end
function form_refresh_cancel(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "form_refresh", form)
  end
end
function refresh_condition_func(nid)
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(nid))
end
function on_func_btns_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_animation_0.Visible = false
  form.lbl_text_0.Visible = false
  form.lbl_animation_1.Visible = false
  form.lbl_text_1.Visible = false
  form.lbl_animation_2.Visible = false
  form.lbl_text_2.Visible = false
  local funcbtns = nx_value("form_main_func_btns")
  if nx_is_valid(funcbtns) then
    return
  end
  funcbtns = nx_create("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return false
  end
  nx_set_value("form_main_func_btns", funcbtns)
  local ini = nx_resource_path() .. "ini\\func_btns.ini"
  funcbtns:LoadDefaultBtnInfo(ini)
  ini = nx_resource_path() .. "ini\\func_btns_ex.ini"
  funcbtns:LoadAddFuncBtnInfo(ini)
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local file = account .. "\\func_" .. nx_string(game_config.server_name) .. ".ini"
  funcbtns:LoadCustomBtnInfo(file)
  return true
end
function on_show_func_btns_list(btn, index)
  if not nx_is_valid(btn) then
    return
  end
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  if index < 0 or 2 < index then
    return
  end
  on_del_hide_func_timer(form_main)
  on_hide_funcbtns_list(form_main)
  form_main.clicked_index = index
  form_main.clicked_btn = btn
  util_show_form("form_stage_main\\form_main\\form_main_func_btns_ex", true)
end
function on_rbtn_fight_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local gui = nx_value("gui")
  local form = rbtn.ParentForm
  local form_logic = nx_value("form_main_logic")
  if nx_is_valid(form_logic) then
    form_logic:SwitchToFight()
  end
  fix_btn_life_by_job_rec(form)
  fix_btn_fight(form)
  on_del_hide_func_timer(form)
  on_hide_funcbtns_list(form)
end
function on_rbtn_fight_lost_capture(rbtn)
  on_hide_func_timer(rbtn)
end
function on_rbtn_fight_get_capture(rbtn)
  on_hide_text_tip(rbtn.ParentForm, 0)
  on_show_func_btns_list(rbtn, 0)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_rbtn_jianghu_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local helper_form = nx_value("helper_form")
  if helper_form then
    return
  end
  local form_main = rbtn.ParentForm
  on_del_hide_func_timer(form_main)
  on_hide_funcbtns_list(form_main)
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) or not form.Visible then
    local form_logic = nx_value("form_main_logic")
    if nx_is_valid(form_logic) then
      form_logic:SwitchToSns()
    end
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_relationship")
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_rbtn_jianghu_lost_capture(rbtn)
  local helper_form = nx_value("helper_form")
  if helper_form then
    return
  end
  on_hide_func_timer(rbtn)
end
function on_rbtn_jianghu_get_capture(rbtn)
  on_hide_text_tip(rbtn.ParentForm, 2)
  on_show_func_btns_list(rbtn, 2)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_rbtn_life_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local gui = nx_value("gui")
  local form = rbtn.ParentForm
  local form_logic = nx_value("form_main_logic")
  if nx_is_valid(form_logic) then
    form_logic:SwitchToLife()
  end
  fix_btn_life_by_job_rec(form)
  fix_btn_fight(form)
  on_del_hide_func_timer(form)
  on_hide_funcbtns_list(form)
end
function on_rbtn_life_lost_capture(rbtn)
  on_hide_func_timer(rbtn)
end
function on_rbtn_life_get_capture(rbtn)
  on_hide_text_tip(rbtn.ParentForm, 1)
  on_show_func_btns_list(rbtn, 1)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_hide_func_timer(rbtn)
  local form = rbtn.ParentForm
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(1000, 1, nx_current(), "on_hide_funcbtns_list", form, -1, -1)
  end
end
function on_del_hide_func_timer(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_hide_funcbtns_list", form)
  end
end
function on_hide_funcbtns_list(form_main)
  local form_btn_ex = nx_value("form_stage_main\\form_main\\form_main_func_btns_ex")
  if nx_is_valid(form_btn_ex) then
    form_btn_ex.Visible = false
    form_btn_ex:Close()
  end
end
function on_btn_lead_info(index)
  if index < 0 or 2 < index then
    return
  end
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  local groupbox = form_main.groupbox_4
  local rbtn = nx_null()
  if index == 0 then
    rbtn = form_main.rbtn_fight
  elseif index == 1 then
    rbtn = form_main.rbtn_life
  elseif index == 2 then
    rbtn = form_main.rbtn_jianghu
  end
  if not nx_is_valid(rbtn) or not nx_is_valid(groupbox) then
    return
  end
  if rbtn.Visible == false then
    return
  end
  local lbl_ani = groupbox:Find("lbl_animation_" .. nx_string(index))
  local lbl_text = groupbox:Find("lbl_text_" .. nx_string(index))
  if not nx_is_valid(lbl_ani) or not nx_is_valid(lbl_text) then
    return
  end
  if lbl_ani.Visible == true or lbl_text.Visible == true then
    return
  end
  lbl_ani.Top = rbtn.Top - 5
  lbl_ani.Visible = true
  lbl_text.Top = lbl_ani.Top - lbl_text.Height + 4
  lbl_text.Visible = true
end
function on_hide_text_tip(form, index)
  if not nx_is_valid(form) then
    return
  end
  if index < 0 or 2 < index then
    return
  end
  local groupbox = form.groupbox_4
  if not nx_is_valid(groupbox) then
    return
  end
  local lbl_text = groupbox:Find("lbl_text_" .. nx_string(index))
  if nx_is_valid(lbl_text) then
    lbl_text.Visible = false
  end
end
function on_btn_ad_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_main\\form_main_ad")
end
function on_groupbox_ad_get_capture(groupbox)
  groupbox.BackImage = "gui\\common\\form_line\\mibox_1.png"
end
function on_groupbox_ad_lost_capture(groupbox)
  groupbox.BackImage = ""
end
function update_newjh_groupbox(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.groupbox_4) then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form.groupbox_4.Visible = false
    form.btn_ad.Visible = false
    form.groupbox_ad.Visible = false
    form.btn_open_yy.Visible = false
    form.mltbox_battle.Visible = false
    form.groupbox_jhtsmini.Visible = true
    form.btn_func_guide.Visible = false
    form.groupbox_show_update.Visible = true
    form.groupbox_dbomall.Visible = true
    show_hide_filter_form(form_table_from_old_to_new.hide, false)
    show_hide_filter_form(form_table_from_old_to_new.show, true)
    close_filter_form(form_table_from_old_to_new.close, false)
  else
    form.groupbox_4.Visible = true
    form.btn_ad.Visible = true
    form.groupbox_ad.Visible = true
    form.btn_open_yy.Visible = true
    form.mltbox_battle.Visible = true
    form.groupbox_jhtsmini.Visible = false
    form.btn_func_guide.Visible = true
    form.groupbox_show_update.Visible = true
    form.groupbox_dbomall.Visible = true
    show_hide_filter_form(form_table_from_new_to_old.show, true)
  end
  return
end
function on_btn_func_guide_click(self)
  util_auto_show_hide_form("form_stage_main\\form_func_guide")
end
function show_jh_tour_info()
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.pbar_1) then
    return
  end
  if not nx_is_valid(form.pbar_2) then
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
  local gui = nx_value("gui")
  local cur_scene_id = get_scene_id()
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return
  end
  local tab_scene_info = jhmgr:GetTourRenownConfig(cur_scene_id)
  local tour_config = tab_scene_info[1]
  local renown_config = tab_scene_info[2]
  local row = 0
  local tour_point = 0
  local tour_level = 0
  if client_player:FindRecord("JHTour_Record") then
    row = client_player:FindRecordRow("JHTour_Record", 0, nx_string(tour_config))
    if 0 <= row then
      tour_point = client_player:QueryRecord("JHTour_Record", row, 1)
      tour_level = client_player:QueryRecord("JHTour_Record", row, 2)
    end
  end
  if nx_int(tour_level) == nx_int(0) then
    tour_level = 1
  end
  local tab_tour_need_point = jhmgr:GetJhTourMaxPoint(nx_int(tour_level + 1))
  form.pbar_1.Maximum = nx_int(tab_tour_need_point[1])
  form.pbar_1.Value = nx_int(tour_point)
  form.pbar_1.Visible = true
  form.pbar_1.HintText = nx_widestr(gui.TextManager:GetFormatText("ui_jh_jhts_72", nx_widestr(util_text("ui_youli_" .. nx_string(nx_int(tour_level)))), nx_widestr(tour_point)))
  local renown_point = 0
  local renown_level = 0
  if client_player:FindRecord("JHRenown_Record") then
    row = client_player:FindRecordRow("JHRenown_Record", 0, nx_string(renown_config))
    if 0 <= row then
      renown_point = client_player:QueryRecord("JHRenown_Record", row, 1)
      renown_level = client_player:QueryRecord("JHRenown_Record", row, 2)
    end
  end
  if nx_int(renown_level) == nx_int(0) then
    renown_level = 1
  end
  local renown_need_point = jhmgr:GetJhRenownMaxPoint(nx_int(renown_level + 1))
  form.pbar_2.Maximum = nx_int(renown_need_point[1])
  form.pbar_2.Value = nx_int(renown_point)
  form.pbar_2.HintText = nx_widestr(gui.TextManager:GetFormatText("ui_jh_jhts_73", nx_widestr(util_text("ui_" .. nx_string(renown_config) .. "_" .. nx_string(renown_level))), nx_widestr(renown_point)))
end
function bind_record_call_back(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("JHTour_Record", form, "form_stage_main\\form_main\\form_main", "on_jhtour_record_change")
    databinder:AddTableBind("JHRenown_Record", form, "form_stage_main\\form_main\\form_main", "on_jhrenown_record_change")
  end
end
function on_jhtour_record_change(self, recordname, optype, row, clomn)
  if not is_jh_scene() then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main", true, false)
  if not nx_is_valid(form) then
    return 0
  end
  if not client_player:FindRecord("JHTour_Record") then
    return 0
  end
  if optype == "add" or optype == "update" or optype == "del" or optype == "clear" then
    show_jh_tour_info()
  end
end
function on_jhrenown_record_change(self, recordname, optype, row, clomn)
  if not is_jh_scene() then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main", true, false)
  if not nx_is_valid(form) then
    return 0
  end
  if not client_player:FindRecord("JHRenown_Record") then
    return 0
  end
  if optype == "add" or optype == "update" or optype == "del" or optype == "clear" then
    show_jh_tour_info()
  end
end
function is_jh_scene()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not player:FindProp("CurJHSceneConfigID") then
    return false
  end
  local jh_scene = player:QueryProp("CurJHSceneConfigID")
  if jh_scene == nil or jh_scene == "" then
    return false
  end
  return true
end
function on_btn_news_click(btn)
  btn.Visible = false
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_tvt\\form_tvt_news", true)
end
function on_btn_changfeng_ying_click(btn)
  nx_execute("form_stage_main\\form_force\\form_force_longmen_ying_response", "show_or_hide")
end
function on_btn_changfeng_jiu_click(btn)
  nx_execute("form_stage_main\\form_force\\form_force_longmen_jiu_response", "show_or_hide")
end
function on_btn_changfeng_dajian_click(btn)
  nx_execute("form_stage_main\\form_force\\form_force_longmen_dajian", "show_or_hide")
end
function show_changfeng_ying_btn(vis)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main", false)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_changfeng_ying.Visible = vis
end
function show_changfeng_jiu_btn(vis)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main", false)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_changfeng_jiu.Visible = vis
end
function show_changfeng_dajian_btn(vis)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main", false)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_changfeng_dajian.Visible = vis
end
function on_btn_weixin_click(btn)
  util_auto_show_hide_form("form_common\\form_gzwx")
end
function load_dbomall_location()
  local gui = nx_value("gui")
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local left = 482
  local top = 23
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    nx_destroy(ini)
    return left, top
  end
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\form_main.ini"
    if ini:LoadFromFile() then
      left = ini:ReadInteger("dbomall", "Left", left)
      top = ini:ReadInteger("dbomall", "Top", top)
    end
  end
  nx_destroy(ini)
  return left, top
end
function on_groupbox_dbomall_get_capture(groupbox)
  groupbox.BackImage = "gui\\common\\form_line\\mibox_1.png"
end
function on_groupbox_dbomall_lost_capture(groupbox)
  groupbox.BackImage = ""
end
function on_btn_dbomall_click(groupbox)
  local form_dbomall = nx_value("form_stage_main\\form_dbomall\\form_dbomall")
  if nx_is_valid(form_dbomall) then
    form_dbomall:Close()
  else
    local dbomall_manager = nx_value("dbomall_manager")
    if nx_is_valid(dbomall_manager) and dbomall_manager:IsAllConditionClosed() then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("96088"))
      return
    end
    util_show_form("form_stage_main\\form_dbomall\\form_dbomall", true)
  end
end
function on_btn_donghai_activity_click(self)
  util_auto_show_hide_form("form_stage_main\\form_activity\\form_activity_donghai")
end
function is_show_donghai_activity_btn()
  local scene_xaikedao = "scene17"
  local scene_penglaidao = "scene16"
  local scene_wujidao = "scene19"
  local main_form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(main_form) then
    return
  end
  local grp = main_form.groupbox_donghai_activity
  if not nx_is_valid(grp) then
    return
  end
  grp.Visible = false
  grp.Fixed = true
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local resource = client_scene:QueryProp("Resource")
  local scene = nx_string(resource)
  if scene == nx_string(scene_xaikedao) or scene == nx_string(scene_penglaidao) or scene == nx_string(scene_wujidao) then
    grp.Visible = true
    grp.Fixed = false
  else
    grp.Visible = false
    grp.Fixed = true
  end
end
function on_btn_new_version_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_main\\form_main_show_update")
  new_version_btn_clicked()
  local main_form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(main_form) then
    return
  end
  local grp = main_form.groupbox_new_version
  if nx_is_valid(grp) then
    grp.Visible = false
    grp.Fixed = true
  end
end
function is_show_new_version_btn()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    nx_destroy(ini)
    return
  end
  local main_form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(main_form) then
    return
  end
  local grp = main_form.groupbox_new_version
  if not nx_is_valid(grp) then
    return
  end
  ini.FileName = account .. "\\form_main.ini"
  if not ini:LoadFromFile() then
    grp.Visible = true
    grp.Fixed = false
    nx_destroy(ini)
    return
  end
  local res = nx_boolean(ini:ReadString("login", "first_time_login", "false"))
  if res == false then
    grp.Visible = true
    grp.Fixed = false
  else
    grp.Visible = false
    grp.Fixed = true
  end
  nx_destroy(ini)
end
function new_version_btn_clicked()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    nx_destroy(ini)
    return
  end
  ini.FileName = account .. "\\form_main.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return
  end
  ini:WriteString("login", "first_time_login", "true")
  ini:SaveToFile()
  nx_destroy(ini)
end
function on_groupbox_show_update_get_capture(groupbox)
  groupbox.BackImage = "gui\\common\\form_line\\mibox_1.png"
end
function on_groupbox_show_update_lost_capture(groupbox)
  groupbox.BackImage = ""
end
function on_btn_show_update_click(btn)
  nx_execute("form_stage_main\\form_power_guide", "open_form")
  local main_form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(main_form) then
    return
  end
  local grp = main_form.groupbox_show_update
  if not nx_is_valid(grp) then
    return
  end
  grp.Fixed = false
end
function show_btn_ident(show)
end
function on_btn_ident_click(btn)
end
function on_btn_sjqte_ready_click(btn)
  nx_execute("custom_sender", "custom_shijia_qte", 0)
end
function on_btn_sjqte_quit_click(btn)
  nx_execute("custom_sender", "custom_shijia_qte", 1)
end
function IsInShijiaQte_changed(form, prop_name, prop_type, prop_value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local state = client_player:QueryProp("ShijiaQteCurState")
  if nx_int(prop_value) == nx_int(1) and nx_int(state) == nx_int(0) then
    form.btn_sjqte_ready.Visible = true
  else
    form.btn_sjqte_ready.Visible = false
  end
end
function ShijiaQteCurState_changed(form, prop_name, prop_type, prop_value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local in_qte = client_player:QueryProp("IsInShijiaQte")
  if nx_int(prop_value) > nx_int(0) and nx_int(in_qte) == nx_int(1) then
    form.btn_sjqte_quit.Visible = true
  else
    form.btn_sjqte_quit.Visible = false
  end
  if nx_int(in_qte) == nx_int(1) and nx_int(prop_value) == nx_int(0) then
    form.btn_sjqte_ready.Visible = true
  else
    form.btn_sjqte_ready.Visible = false
  end
end
function set_btn_bzt_visible(...)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return
  end
  if table.getn(arg) < 1 then
    return
  end
  local flag = false
  if nx_int(arg[1]) == nx_int(1) then
    flag = true
  end
  local btn = form.btn_bzt
  if not nx_is_valid(btn) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  btn.Left = (gui.Width - btn.Width) / 2
  if flag and nx_int(interactmgr:GetCurrentTvtType()) == nx_int(ITT_FF_ACTIVITY) then
    if table.getn(arg) < 2 then
      return
    end
    local group = arg[2]
    nx_set_custom(btn, "group", group)
    btn.Visible = true
    return
  end
  local form_bzt = nx_value("form_stage_main\\form_small_game\\form_game_bazhentu")
  if nx_is_valid(form_bzt) then
    form_bzt:Close()
  end
  btn.Visible = false
end
function on_btn_bzt_click(btn)
  btn.Visible = false
  util_show_form("form_stage_main\\form_small_game\\form_game_bazhentu", true)
end
function on_ani_2_animation_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
end
function on_btn_wudoa_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "custom_wudao_request_web_adress")
end
function show_or_hide_effect(...)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  local btn = form.btn_wudoa
  if not nx_is_valid(btn) then
    return
  end
  local step = nx_int(arg[1])
  if nx_int(step) == nx_int(3) or nx_int(step) == nx_int(4) then
    btn.NormalImage = "wudao_02"
    btn.FocusImage = "wudao_02"
    btn.PushImage = "wudao_02"
  else
    btn.NormalImage = "wudao_01"
    btn.FocusImage = "wudao_01"
    btn.PushImage = "wudao_01"
  end
end
function on_groupbox_wudao_get_capture(gbox)
  gbox.BackImage = "gui\\common\\form_line\\mibox_1.png"
end
function on_groupbox_wudao_lost_capture(gbox)
  gbox.BackImage = ""
end
function open_alive_web(...)
  local web_adress = nx_string(arg[1])
  if nx_string(web_adress) == nx_string("") or nx_string(web_adress) == nil then
    return
  end
  nx_function("ext_open_url", web_adress)
end
function hide_wudao_fire()
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  local btn = form.btn_wudoa
  if not nx_is_valid(btn) or not btn.Visible then
    return
  end
  btn.NormalImage = "wudao_01"
  btn.FocusImage = "wudao_01"
  btn.PushImage = "wudao_01"
end
function on_btn_new_terms_sign_click(btn)
end
function on_btn_openweb_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  switch_manager:OpenUrl(nx_int(URL_TYPE_9YIN_WIKI))
end
function on_groupbox_openweb_get_capture(groupbox)
  groupbox.BackImage = "gui\\common\\form_line\\mibox_1.png"
end
function on_groupbox_openweb_lost_capture(groupbox)
  groupbox.BackImage = ""
  save_btn_wiki_location()
end
function save_btn_wiki_location()
end
function set_btn_wiki_location(form)
end
function on_btn_sign_n_draw_click(btn)
  local form = nx_value("form_stage_main\\form_dbomall\\form_sign_and_draw")
  if nx_is_valid(form) then
    form:Close()
    return
  end
  nx_execute("form_stage_main\\form_dbomall\\form_sign_and_draw", "open_form")
end
function show_world_auction()
  local form = util_get_form("form_stage_main\\form_main\\form_main", false)
  if not nx_is_valid(form) then
    return
  end
  if form.gb_world_auction.Visible == true then
    return
  end
  form.gb_world_auction.Visible = true
  form.gb_world_auction.AbsTop = wa_top
  if form.gb_world_auction.AbsTop < wa_top_dest and 0 < wa_speed then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "gb_world_auction_drop", form)
    timer:Register(10, -1, nx_current(), "gb_world_auction_drop", form, -1, -1)
  end
end
function hide_world_auction()
  local form = util_get_form("form_stage_main\\form_main\\form_main", false)
  if not nx_is_valid(form) then
    return
  end
  form.gb_world_auction.Visible = false
  form.gb_world_auction.Left = wa_left
  form.gb_world_auction.AbsTop = wa_top
end
function gb_world_auction_drop(form)
  form.gb_world_auction.AbsTop = form.gb_world_auction.AbsTop + wa_speed
  if form.gb_world_auction.AbsTop > wa_top_dest then
    form.gb_world_auction.AbsTop = wa_top_dest
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "gb_world_auction_drop", form)
  end
end
function on_gb_world_auction_get_capture(groupbox)
  groupbox.BackImage = "gui\\common\\form_line\\mibox_1.png"
end
function on_gb_world_auction_lost_capture(groupbox)
  groupbox.BackImage = ""
end
function on_btn_world_auction_click(btn)
  nx_execute("form_stage_main\\form_world_auction\\form_world_auction", "open_or_close")
end
function on_groupbox_sign_n_draw_get_capture(groupbox)
  groupbox.BackImage = "gui\\common\\form_line\\mibox_1.png"
end
function on_groupbox_sign_n_draw_lost_capture(groupbox)
  groupbox.BackImage = ""
  save_btn_location(groupbox, "sign_n_draw")
end
function save_btn_location(gbox, sec_name)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not (nx_is_valid(form) and nx_is_valid(gbox)) or nx_string(sec_name) == "" then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = nx_string(account) .. "\\form_main.ini"
  ini:LoadFromFile()
  ini:WriteInteger(nx_string(sec_name), "Left", nx_int(gbox.Left))
  ini:WriteInteger(nx_string(sec_name), "Top", nx_int(gbox.Top))
  ini:SaveToFile()
  nx_destroy(ini)
end
function set_btn_location(form, gbox, sec_name)
  if not (nx_is_valid(form) and nx_is_valid(gbox)) or nx_string(sec_name) == "" then
    return
  end
  local tmp_pos = 0
  tmp_pos = get_int_prop_value(nx_string(sec_name), "Left")
  if tmp_pos <= 0 or tmp_pos == nil then
    return
  end
  gbox.Left = nx_int(tmp_pos)
  tmp_pos = get_int_prop_value(nx_string(sec_name), "Top")
  if tmp_pos <= 0 or tmp_pos == nil then
    return
  end
  gbox.Top = nx_int(tmp_pos)
end
function check_show_sjy_meet_ui()
  local hidden = 1
  local show = 0
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return
  end
  if nx_int(interactmgr:GetCurrentTvtType()) ~= nx_int(ITT_SJY_MEET) then
    refresh_kill_num(hidden)
    nx_execute("form_stage_main\\form_main\\form_main_map", "show_sjy_school_meet_ui", hidden)
    return
  end
  refresh_kill_num(show)
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_sjy_school_meet_ui", show)
  nx_execute("custom_sender", "custom_send_sjy_shimen", nx_int(2))
end
function check_show_xmg_meet_ui()
  local hidden = 1
  local show = 0
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return
  end
  if nx_int(interactmgr:GetCurrentTvtType()) ~= nx_int(ITT_XMG_MEET) then
    refresh_kill_num(hidden)
    nx_execute("form_stage_main\\form_main\\form_main_map", "show_xmg_school_meet_ui", hidden)
    return
  end
  refresh_kill_num(show)
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_xmg_school_meet_ui", show)
  nx_execute("custom_sender", "custom_send_xmg_shimen", nx_int(2))
end
function refresh_kill_num(is_show, kill_num)
  local b_show = nx_int(is_show) == nx_int(0)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_custom(form, "ani_cd") or not nx_is_valid(form.ani_cd) then
    return
  end
  if not nx_custom(form, "groupbox_kill_num") or not nx_is_valid(form.groupbox_kill_num) then
    return
  end
  if nx_int(is_show) == nx_int(0) then
    form.ani_cd.AbsLeft = (gui.Width - form.ani_cd.Width) / 2
    form.ani_cd.AbsTop = (gui.Height - form.ani_cd.Height) / 3
    form.groupbox_kill_num.AbsLeft = (gui.Width - form.groupbox_kill_num.Width) / 4 * 3
    form.groupbox_kill_num.AbsTop = (gui.Height - form.groupbox_kill_num.Height) / 3
    set_kill_num(form, kill_num)
    form.groupbox_kill_num.Visible = true
  else
    form.groupbox_kill_num.Visible = false
    form.ani_cd.Visible = false
  end
end
function start_counddown()
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.ani_cd.Loop = false
  form.ani_cd.PlayMode = 2
  form.ani_cd.Visible = true
  form.ani_cd:Play()
end
function on_ani_cd_animation_end(animation, ani_name, mode)
  animation.Visible = false
end
function set_kill_num(form, kill_num)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(kill_num) < nx_int(10) then
    form.lbl_kn_bai.Visible = false
    form.lbl_kn_shi.Visible = false
    form.lbl_kn_ge.Visible = true
    form.lbl_kn_ge.Left = form.lbl_kn.Left + form.lbl_kn.Width
    form.lbl_kn_ge.BackImage = nx_string("gui\\special\\clone\\") .. nx_string(nx_int(kill_num)) .. nx_string(".png")
  elseif nx_int(kill_num) < nx_int(100) then
    form.lbl_kn_bai.Visible = false
    form.lbl_kn_shi.Visible = true
    form.lbl_kn_ge.Visible = true
    form.lbl_kn_shi.Left = form.lbl_kn.Left + form.lbl_kn.Width
    form.lbl_kn_ge.Left = form.lbl_kn_shi.Left + form.lbl_kn_shi.Width
    form.lbl_kn_shi.BackImage = nx_string("gui\\special\\clone\\") .. nx_string(math.floor(kill_num / 10)) .. nx_string(".png")
    form.lbl_kn_ge.BackImage = nx_string("gui\\special\\clone\\") .. nx_string(kill_num % 10) .. nx_string(".png")
  elseif nx_int(kill_num) < nx_int(1000) then
    form.lbl_kn_bai.Visible = true
    form.lbl_kn_shi.Visible = true
    form.lbl_kn_ge.Visible = true
    form.lbl_kn_bai.Left = form.lbl_kn.Left + form.lbl_kn.Width
    form.lbl_kn_shi.Left = form.lbl_kn_bai.Left + form.lbl_kn_bai.Width
    form.lbl_kn_ge.Left = form.lbl_kn_shi.Left + form.lbl_kn_shi.Width
    form.lbl_kn_bai.BackImage = nx_string("gui\\special\\clone\\") .. nx_string(math.floor(kill_num / 100)) .. nx_string(".png")
    form.lbl_kn_shi.BackImage = nx_string("gui\\special\\clone\\") .. nx_string(math.floor(kill_num % 100 / 10)) .. nx_string(".png")
    form.lbl_kn_ge.BackImage = nx_string("gui\\special\\clone\\") .. nx_string(kill_num % 10) .. nx_string(".png")
  end
end
function clear()
  local form = util_get_form("form_stage_main\\form_main\\form_main", false)
  if not nx_is_valid(form) then
    return
  end
end
function create_boss_drop_grid(form, top, left)
  local gui = nx_value("gui")
  local imagegrid = gui:Create("ImageGrid")
  if nx_is_valid(imagegrid) then
    imagegrid.NoFrame = true
    imagegrid.BackColor = "0,255,255,255"
    imagegrid.BackImage = nx_string("gui\\special\\world_auction\\jingpaidaojukuang.png")
    imagegrid.Width = 55
    imagegrid.Height = 55
    imagegrid.DrawMode = "FitWindow"
    imagegrid.DrawMouseIn = ""
    imagegrid.GridWidth = 47
    imagegrid.GridHeight = 47
    imagegrid.GridBackOffsetX = -4
    imagegrid.GridBackOffsetY = -4
    imagegrid.Top = top
    imagegrid.Left = left
    imagegrid.Visible = false
    imagegrid.SelectColor = "0,0,0,0"
    imagegrid.MouseInColor = "0,0,0,0"
    imagegrid.GridsPos = nx_string("4,4")
    nx_bind_script(imagegrid, nx_current())
    nx_callback(imagegrid, "on_mousein_grid", "on_boss_drop_grid_mousein")
    nx_callback(imagegrid, "on_mouseout_grid", "on_boss_drop_grid_mouseout")
    form:Add(imagegrid)
    return imagegrid
  end
end
function on_boss_drop_grid_mousein(grid)
  if not nx_is_valid(grid) then
    return
  end
  local gui = nx_value("gui")
  local x = grid:GetMouseInItemLeft()
  local y = grid:GetMouseInItemTop()
  local form = grid.ParentForm
  nx_execute("tips_game", "show_tips_by_config", grid.config_id, x, y, form)
end
function on_boss_drop_grid_mouseout(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_boss_drop_info(drop_info, top, left)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local valid_count = 0
  local item_list = util_split_string(drop_info, ";")
  for i = 1, table.getn(item_list) do
    local item_info = util_split_string(item_list[i], ",")
    if table.getn(item_info) >= 3 then
      local item_id = item_info[1]
      local count = item_info[2]
      local bind = item_info[3]
      local grid = create_boss_drop_grid(form, top, left + nx_int(i - 1) * nx_int(57))
      if nx_is_valid(grid) then
        local ItemQuery = nx_value("ItemQuery")
        if nx_is_valid(ItemQuery) then
          local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_id), nx_string("Photo"))
          grid:AddItem(0, photo, "", nx_int(count), -1)
        end
        grid.config_id = item_id
        nx_set_custom(form, "boss_drop_grid_" .. nx_string(i), grid)
        valid_count = valid_count + 1
      end
    end
  end
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(timer) then
    return
  end
  if nx_int(valid_count) <= nx_int(0) then
    return
  end
  form.total_show_boss_drop = nx_int(valid_count)
  form.cur_hide_boss_drop = 0
  form.cur_show_boss_drop = nx_int(1)
  timer:UnRegister(nx_current(), "show_boss_drop_grid", form)
  timer:Register(100, valid_count, nx_current(), "show_boss_drop_grid", form, -1, -1)
end
function show_boss_drop_grid(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_show_boss_drop") then
    return
  end
  local ctrl = nx_custom(form, "boss_drop_grid_" .. nx_string(form.cur_show_boss_drop))
  if not nx_is_valid(ctrl) then
    return
  end
  ctrl.Visible = true
  form.cur_show_boss_drop = form.cur_show_boss_drop + nx_int(1)
end
function hide_boss_drop_info()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(timer) then
    return
  end
  if not nx_find_custom(form, "total_show_boss_drop") then
    return
  end
  if nx_int(form.total_show_boss_drop) <= nx_int(0) then
    return
  end
  timer:UnRegister(nx_current(), "show_boss_drop_grid", form)
  for i = 1, nx_number(form.total_show_boss_drop) do
    local ctrl = nx_custom(form, "boss_drop_grid_" .. i)
    if nx_is_valid(ctrl) then
      ctrl.Visible = true
    end
  end
  form.cur_hide_boss_drop = nx_int(1)
  timer:Register(100, form.total_show_boss_drop, nx_current(), "hide_boss_drop_grid", form, -1, -1)
end
function hide_boss_drop_grid(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_hide_boss_drop") then
    return
  end
  local ctrl = nx_custom(form, "boss_drop_grid_" .. nx_string(form.cur_hide_boss_drop))
  if not nx_is_valid(ctrl) then
    return
  end
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:AddExecute("BezierMove", ctrl, nx_float(0.01), ctrl, form.btn_world_auction.AbsLeft, form.btn_world_auction.AbsTop, nx_float(1), 300, nx_current(), nx_string("boss_drop_gird_move_end"))
  end
  form.cur_hide_boss_drop = form.cur_hide_boss_drop + nx_int(1)
end
function boss_drop_gird_move_end(ctrl)
  if not nx_is_valid(ctrl) then
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Remove(ctrl)
end
function move_boss_drop_grid(top, left)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "total_show_boss_drop") then
    return
  end
  if nx_find_custom(form, "cur_hide_boss_drop") and nx_int(form.cur_hide_boss_drop) ~= nx_int(0) then
    return
  end
  for i = 1, nx_number(form.total_show_boss_drop) do
    local ctrl = nx_custom(form, "boss_drop_grid_" .. nx_string(i))
    if not nx_is_valid(ctrl) then
      return
    end
    ctrl.Top = top
    ctrl.Left = left + nx_int(i - 1) * nx_int(57)
  end
end
function show_sanhill_visible(form, flag)
  form.ani_sanhill_title_open.Visible = flag
  form.ani_sanhill_title_close.Visible = flag
  form.ani_sanhill_content.Visible = flag
  form.sanhill_groupbox.Visible = flag
  local gui = nx_value("gui")
  form.ani_sanhill_title_open.Left = (gui.Width - form.ani_sanhill_title_open.Width) / 2
  form.ani_sanhill_title_open.Top = (gui.Height - form.ani_sanhill_title_open.Height) / 6
  form.ani_sanhill_title_close.Left = (gui.Width - form.ani_sanhill_title_close.Width) / 2
  form.ani_sanhill_title_close.Top = (gui.Height - form.ani_sanhill_title_close.Height) / 6
  form.sanhill_groupbox.Left = (gui.Width - form.sanhill_groupbox.Width) / 2
  form.sanhill_groupbox.Top = (gui.Height - form.sanhill_groupbox.Height) / 6
end
function on_ani_sanhill_title_open_animation_end(ani)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  ani.Visible = false
  form.sanhill_groupbox.Left = (gui.Width - form.sanhill_groupbox.Width) / 2
  form.sanhill_groupbox.Visible = true
  local timer = nx_value("timer_game")
  timer:UnRegister(form, "sanhill_delay_close", form)
  timer:Register(5000, -1, nx_current(), "sanhill_delay_close", form, -1, -1)
end
function on_ani_sanhill_title_close_animation_end(ani)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  ani.Visible = false
  form.ani_sanhill_content.Loop = false
  form.ani_sanhill_content.PlayMode = 2
  form.ani_sanhill_content.Visible = true
  form.ani_sanhill_content:Play()
end
function on_ani_sanhill_content_animation_end(ani)
  ani.Visible = false
  local level = ani.level
  local limit_time = ani.limit_time
  local dead_count = ani.dead_count
  local content1 = ani.content1
  local content2 = ani.content2
  nx_execute("form_stage_main\\form_skyhill\\form_sanhill", "show_passlevel_info", level, limit_time, dead_count, content1, content2)
end
function play_sanhill_ani_close()
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  form.sanhill_groupbox.Visible = false
  local gui = nx_value("gui")
  form.ani_sanhill_title_close.Left = (gui.Width - form.ani_sanhill_title_close.Width) / 2
  form.ani_sanhill_title_close.Loop = false
  form.ani_sanhill_title_close.PlayMode = 2
  form.ani_sanhill_title_close.Visible = true
  form.ani_sanhill_title_close:Play()
end
function sanhill_delay_close(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "sanhill_delay_close", form)
  play_sanhill_ani_close()
end
function close_moreform()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if nx_find_custom(game_client, "ready") and game_client.ready == false then
    return
  end
  form.gb_world_auction.Visible = false
end
