require("const_define")
require("util_gui")
require("define\\object_type_define")
require("define\\task_npc_flag")
require("share\\logicstate_define")
require("form_stage_main\\form_task\\task_define")
require("util_vip")
require("define\\team_rec_define")
require("form_stage_main\\form_9yinzhi\\form_9yinzhi_main")
require("form_stage_main\\switch\\url_define")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
require("control_set")
require("form_stage_main\\form_world_war\\form_world_war_define")
require("form_stage_main\\form_scene_compete\\util_scene_compete_define")
require("util_role_prop")
require("util_static_data")
require("form_stage_main\\form_tvt\\define")
require("share\\client_custom_define")
require("player_state\\state_const")
local CHILD_FORM_NAME = "form_stage_main\\form_freshman\\form_freshman_particularize"
local g_pro_Max = 100
local g_pro_Min = 0
local g_Finish_list = {
  "lilianyindao",
  "zuowangongxiulian",
  "wuguanyindao",
  "dazuotiaoxi",
  "qinggongyindao",
  "anqiyindao",
  "neixiuyindao",
  "bairushimen"
}
local table_func_form = {
  "form_stage_main\\form_card\\form_card_skill",
  "form_stage_main\\form_main\\form_main_shortcut_onestep",
  "form_stage_main\\form_animalkeep\\form_sable_skill",
  "form_stage_main\\form_main\\form_main_equip_buffer_list"
}
local POS_INI = "ini\\form_pos.ini"
local market_item_table = {}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local get_global_list = function(global_list_name)
  return get_global_arraylist(global_list_name)
end
local function get_new_global_list(global_list_name)
  local global_list = get_global_list(global_list_name)
  global_list:ClearChild()
  return global_list
end
function main_form_init(form)
  form.Fixed = true
  local texture_tool = nx_value("TextureTool")
  if not nx_is_valid(texture_tool) then
    texture_tool = nx_create("TextureTool")
  end
  form.texture_tool = texture_tool
  return 1
end
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function reset_form_size()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if nx_is_valid(form) then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      form.groupmap_objs:AddMainPlayerBind("gui\\map\\icon\\me.png", game_visual:GetPlayer())
    end
  end
end
function init_form_main_map_logic()
  local form_logic = nx_value("form_main_map_logic")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_main_map")
  nx_set_value("form_main_map_logic", form_logic)
end
function main_form_open(form)
  init_form_main_map_logic()
  form.no_need_motion_alpha = true
  form.map_query = nx_value("MapQuery")
  local gui = nx_value("gui")
  gui.Desktop:ToBack(form)
  on_btn_show_click(form.btn_show)
  form.has_unreadletter = false
  form.status = 1
  form.btn_net_green.Visible = true
  form.btn_net_yellow.Visible = false
  form.btn_net_red.Visible = false
  form.btn_wujidao_war.Visible = false
  form.lbl_regulations_note.Visible = false
  form.roundbox_smallmap.TerrainWidth = 0
  form.roundbox_smallmap.TerrainHeight = 0
  form.roundbox_smallmap.TerrainStartX = 0
  form.roundbox_smallmap.TerrainStartZ = 0
  local gui = nx_value("gui")
  form.roundbox_smallmap.Parent:ToBack(form.roundbox_smallmap)
  form.roundbox_smallmap.ZoomWidth = 0.66
  form.roundbox_smallmap.ZoomHeight = 0.66
  form.roundbox_smallmap.Parent.BlendAlpha = 220
  form.mltbox_area_limit.Visible = false
  form.mltbox_area_limit.AbsLeft = form.roundbox_smallmap.AbsLeft
  form.groupmap_objs:SetShape(2)
  form.groupmap_objs.MapControl = form.roundbox_smallmap
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", form, nx_current(), "update_newjh_map_ui")
    databinder:AddRolePropertyBind("NLBSchoolMeetGroup", "int", form, nx_current(), "refresh_nlb_shimen_btn")
    databinder:AddRolePropertyBind("InteractStatus", "int", form, nx_current(), "refresh_hsp_meet_btn")
    databinder:AddRolePropertyBind("IsSanmeng", "int", form, nx_current(), "refresh_sanmeng_btn")
    databinder:AddRolePropertyBind("BalanceWarIsInWar", "int", form, nx_current(), "reset_balance_war_ctrl")
    databinder:AddRolePropertyBind("WuDaoPlayerState", "int", form, nx_current(), "reset_wudao_war_ctrl")
    databinder:AddRolePropertyBind("LuanDouPlayerState", "int", form, nx_current(), "reset_luandou_ctrl")
    databinder:AddRolePropertyBind("JiuYangFacultyDefendKillNums", "int", form, nx_current(), "reset_jiuyang_ctrl")
    databinder:AddRolePropertyBind("JiuYangFacultyHarmKillNums", "int", form, nx_current(), "reset_jiuyang_ctrl")
    databinder:AddRolePropertyBind("CrossType", "int", form, nx_current(), "reset_cross_btn")
    databinder:AddRolePropertyBind("CW_TYPE", "int", form, nx_current(), "reset_guild_balance_war")
    databinder:AddTableBind("EquipOtherBufferRec", form, nx_current(), "refresh_cbtn_equip_buff")
    databinder:AddRolePropertyBind("IsNewWarRule", "int", form, nx_current(), "refresh_new_war_rule_btn")
  end
  form.pic_map = form.roundbox_smallmap
  on_vip_status_changed(form)
  nx_execute("form_stage_main\\form_main\\form_main_map", "reset_scene")
  form.mltbox_tips_info.Visible = false
  form.btn_regulations.data_source = ""
  form.btn_regulations.is_show_tips = false
  form.groupbox_filter.Visible = false
  load_btn_state(form)
  init_npc_type(form)
  form.lbl_9yin.Top = form.btn_9yinzhi.Top + (form.btn_9yinzhi.Height - form.lbl_9yin.Height) / 2
  form.lbl_9yin.Left = form.btn_9yinzhi.Left + (form.btn_9yinzhi.Width - form.lbl_9yin.Width) / 2
  form.lbl_9yin.Visible = false
  set_FreshManPro(form)
  form.btn_seven.Visible = false
  form.btn_scene_compete.Visible = false
  form.btn_wuque_buy.Visible = false
  form.lbl_wuque_buy.Visible = false
  set_btn_playsnail_main_status(form)
  form.imagegrid_func.page = 0
  local func_icon_mgr = nx_value("func_icon_mgr")
  if nx_is_valid(func_icon_mgr) then
    nx_destroy(func_icon_mgr)
  end
  func_icon_mgr = nx_create("func_icon_mgr")
  if nx_is_valid(func_icon_mgr) then
    nx_set_value("func_icon_mgr", func_icon_mgr)
  end
  func_icon_mgr:RefreshGrid(form.imagegrid_func)
  form.ipt_search_key.Text = util_text("ui_trade_search_key")
  form.combobox_1.config = ""
  form.groupbox_filter1.Visible = false
  local mgr = nx_value("SwitchManager")
  if not nx_is_valid(mgr) then
    return
  end
  local flag = mgr:CheckSwitchEnable(ST_NORMAL_ACTIVITY_GUIDE)
  if flag then
    form.btn_activity_guide.Visible = true
  else
    form.btn_activity_guide.Visible = false
  end
  set_btn_jy_rank_visible(false)
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) and nx_find_property(game_config_info, "show_change_equip") and nx_number(game_config_info.show_change_equip) == 1 then
    form.cbtn_hz.Checked = true
  end
end
function refresh_cbtn_equip_buff(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local form_buff = nx_value("form_stage_main\\form_main\\form_main_equip_buffer_list")
  if not nx_is_valid(form_buff) then
    return
  end
  local rows = client_player:GetRecordRows("EquipOtherBufferRec")
  if nx_int(rows) <= nx_int(0) then
    form_buff.Visible = false
  elseif form.cbtn_equip_buff.Checked then
    form_buff.Visible = true
  end
end
function on_ready()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) and nx_find_property(game_config_info, "show_equip_buff") and nx_number(game_config_info.show_equip_buff) == 1 and form.cbtn_equip_buff.Checked == false then
    form.cbtn_equip_buff.Checked = true
  end
end
function init_npc_type(form)
  for t = 82, 107 do
    form.groupmap_objs:ShowType(t, true)
  end
  form.groupmap_objs:ShowType(110, true)
  form.groupmap_objs:ShowType(340, true)
  form.groupmap_objs:ShowType(341, true)
  form.groupmap_objs:ShowType(342, true)
  form.groupmap_objs:ShowType(343, true)
  form.groupmap_objs:ShowType(345, true)
  form.groupmap_objs:ShowType(160, true)
  form.groupmap_objs:ShowType(350, true)
  form.groupmap_objs:ShowType(480, true)
end
function set_freshman_show(form, visible)
  if not nx_is_valid(form) then
    return
  end
  if visible == true then
    if not check_node_valid(g_Finish_list[table.getn(g_Finish_list)]) then
      form.btn_curfreshman.Visible = false
      form.pbar_curfreshmanpro.Visible = false
      form.mltbox_freshman_tip1.Visible = false
      form.lbl_freshman_tip2.Visible = false
      form.lbl_freshman_pro.Visible = false
      return
    end
    form.btn_curfreshman.Visible = true
    form.pbar_curfreshmanpro.Visible = true
    form.mltbox_freshman_tip1.Visible = true
    form.lbl_freshman_tip2.Visible = true
    form.lbl_freshman_pro.Visible = true
    return
  end
  form.btn_curfreshman.Visible = false
  form.pbar_curfreshmanpro.Visible = false
  form.mltbox_freshman_tip1.Visible = false
  form.lbl_freshman_tip2.Visible = false
  form.lbl_freshman_pro.Visible = false
end
function set_FreshManPro(form)
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("SwitchManager")
  if not nx_is_valid(mgr) then
    set_freshman_show(form, false)
    return
  end
  local flag = mgr:CheckSwitchEnable(ST_SNDA_ACTIVITY_JION_MENPAI)
  if flag == false then
    set_freshman_show(form, false)
    return
  end
  local maxcount = table.getn(g_Finish_list)
  local cur = get_curFreshmanPro()
  if maxcount <= cur then
    set_freshman_show(form, false)
    return
  end
  cur = cur / maxcount * g_pro_Max
  local gui = nx_value("gui")
  local text1 = gui.TextManager:GetText("ui_hd_menpai_02")
  local text2 = gui.TextManager:GetText("ui_hd_menpai_03")
  text2 = nx_widestr(text2) .. nx_widestr(cur) .. nx_widestr("%")
  form.lbl_freshman_tip1.Text = nx_widestr(text1)
  form.lbl_freshman_tip2.Text = text2
  form.pbar_curfreshmanpro.Value = cur
  form.pbar_curfreshmanpro.MinNum = g_pro_Min
  form.pbar_curfreshmanpro.MaxNum = g_pro_Max
  set_freshman_show(form, true)
end
function get_curFreshmanPro()
  local cur = 0
  for i, name in ipairs(g_Finish_list) do
    if not check_node_valid(name) then
      cur = cur + 1
    end
  end
  return cur
end
function change_switch(msg_type, is_open)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  set_FreshManPro(form)
end
function check_node_valid(node_name)
  local index = get_node_indx(node_name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_int(-1) == nx_int(index) then
    return false
  end
  local str_rec = client_player:QueryProp("FinishFreshmanRecStr")
  local value = nx_function("get_str_rec_flag", str_rec, index - 1)
  return not value
end
function get_node_indx(node_name)
  local ini_doc = get_ini("share\\Rule\\Freshman.ini")
  if not nx_is_valid(ini_doc) then
    return -1
  end
  local size = ini_doc:GetSectionCount() - 1
  for n_index = 0, size do
    if node_name == ini_doc:GetSectionItemValue(n_index, 0) then
      return nx_number(ini_doc:GetSectionByIndex(n_index))
    end
  end
  return -1
end
function on_btn_curfreshman_click(btn)
  local cur = get_curFreshmanPro()
  nx_execute("form_stage_main\\form_freshman\\form_freshman_main", "util_open_form", "")
end
function main_form_close(form)
  local form_logic = nx_value("form_main_map_logic")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  if nx_running(nx_current(), "hide_area_limit") then
    nx_kill(nx_current(), "hide_area_limit")
  end
  if nx_find_custom(form, "map_ui_ini") and nx_is_valid(form.map_ui_ini) then
    form.map_ui_ini:SaveToFile()
    nx_destroy(form.map_ui_ini)
    form.map_ui_ini = nx_null()
  end
  form.map_query = nx_null()
  local func_icon_mgr = nx_value("func_icon_mgr")
  if nx_is_valid(func_icon_mgr) then
    nx_destroy(func_icon_mgr)
  end
  if nx_is_valid(form.texture_tool) then
    nx_destroy(form.texture_tool)
  end
end
function on_btn_gen_info_click(self)
  nx_execute("form_stage_main\\form_main\\form_main_general_info", "auto_show_hide_general_info")
end
function on_btn_sf_order_click(self)
  if can_show_sf_order() then
    util_show_form("form_stage_main\\form_school_war\\form_school_fight_rank", true)
  end
end
function can_show_sf_order()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local is_in_fight = client_player:QueryProp("IsInSchoolFight")
  if nx_int(is_in_fight) ~= nx_int(1) then
    return false
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return false
  end
  if not client_scene:FindRecord("Time_Limit_Form_Rec") then
    return false
  end
  return true
end
function on_btn_zoom_in_click(btn)
  btn.MouseDown = false
end
function on_btn_zoom_in_get_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local cursor_x, cursor_y = gui:GetCursorPosition()
  local widestr_info = gui.TextManager:GetText("ui_littlemap_tips_fangda")
  nx_execute("tips_game", "show_text_tip", nx_widestr(widestr_info), cursor_x, cursor_y, 0, form)
end
function on_btn_zoom_in_lost_capture(btn)
  local form = btn.ParentForm
  btn.MouseDown = false
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_zoom_in_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local zoom = form.roundbox_smallmap.ZoomWidth
  while btn.MouseDown do
    local elapse = nx_pause(0)
    zoom = zoom + 1 * elapse
    if not nx_is_valid(form) then
      return
    end
    if 1.5 < zoom then
      form.roundbox_smallmap.ZoomWidth = 1.5
      form.roundbox_smallmap.ZoomHeight = 1.5
      break
    end
    form.roundbox_smallmap.ZoomWidth = zoom
    form.roundbox_smallmap.ZoomHeight = zoom
  end
  return 1
end
function zoom_out_push()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  local btn = form.btn_zoom_out
  on_btn_zoom_out_push(btn)
end
function zoom_in_push()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  local btn = form.btn_zoom_in
  on_btn_zoom_in_push(btn)
end
function zoom_out_end()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  local btn = form.btn_zoom_out
  on_btn_zoom_out_click(btn)
end
function zoom_in_end()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  local btn = form.btn_zoom_in
  on_btn_zoom_in_click(btn)
end
function on_btn_zoom_out_click(btn)
  btn.MouseDown = false
end
function on_btn_zoom_out_get_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local cursor_x, cursor_y = gui:GetCursorPosition()
  local widestr_info = gui.TextManager:GetText("ui_littlemap_tips_suoxiao")
  nx_execute("tips_game", "show_text_tip", nx_widestr(widestr_info), cursor_x, cursor_y, 0, form)
end
function on_btn_zoom_out_lost_capture(btn)
  local form = btn.ParentForm
  btn.MouseDown = false
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_zoom_out_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local zoom = form.roundbox_smallmap.ZoomWidth
  while btn.MouseDown do
    local elapse = nx_pause(0)
    zoom = zoom - 1 * elapse
    if not nx_is_valid(form) then
      return
    end
    if zoom < 0.5 then
      form.roundbox_smallmap.ZoomWidth = 0.5
      form.roundbox_smallmap.ZoomHeight = 0.5
      break
    end
    form.roundbox_smallmap.ZoomWidth = zoom
    form.roundbox_smallmap.ZoomHeight = zoom
  end
  return 1
end
function on_btn_bigmap_click(btn)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  nx_execute("freshman_help", "close_scene_map_effect")
  if client_player:QueryProp("IsInWorldWar") == 1 then
    nx_execute("form_stage_main\\form_world_war\\form_world_war_map", "open_form")
  elseif client_player:QueryProp("InteractStatus") == ITT_PROTECT_SCHOOL then
    nx_execute("form_stage_main\\form_school_destroy\\form_protect_school_map", "open_form")
  else
    nx_execute("form_stage_main\\form_map\\form_map_scene", "auto_show_hide_map_scene")
  end
end
function on_btn_9yinzhi_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  if util_is_lockform_visible("form_stage_main\\form_9yinzhi") then
    nx_execute("form_stage_main\\form_9yinzhi\\form_9yinzhi_main", "ansyn_close_9yinzhi")
  else
    nx_execute("form_stage_main\\form_9yinzhi\\form_9yinzhi_main", "ansyn_open_9yinzhi")
    if btn.Parent.lbl_9yin.Visible then
      btn.Parent.lbl_9yin.Visible = false
      sendCustomMsgGetInfo(MSGID_JIUYINZHI_UPDATE_VIEW_GAME_STEP)
    end
  end
end
function on_cbtn_visible_checked_changed(btn)
  local role = nx_value("role")
  if nx_is_valid(role) and nx_find_custom(role, "small_map_limit") and role.small_map_limit == true then
    return
  end
  local form = btn.ParentForm
  form.groupbox_smallmap.Visible = btn.Checked
  form.btn_zoom_out.Visible = btn.Checked
  form.btn_zoom_in.Visible = btn.Checked
  form.lbl_1.Visible = btn.Checked
  if not form.groupbox_smallmap.Visible then
    form.mltbox_area_limit.Visible = false
  end
end
function on_cbtn_hide_checked_changed(self)
  local form = self.ParentForm
  local flag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
  if flag then
    self.Checked = false
  end
  local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if flag_apex then
    self.Checked = false
  end
  form.groupmap_objs:ShowType(0, self.Checked)
  change_player_image(form, "team_rec", TEAM_REC_COL_NAME)
  change_player_image(form, "rec_enemy", 1)
  change_player_image(form, "rec_blood", 1)
  save_btn_state("small_map_icon_role", self.Checked)
end
function on_cbtn_eshili_checked_changed(self)
  local form = self.ParentForm
  for t = 1, 4 do
    form.groupmap_objs:ShowType(t, self.Checked)
  end
  for t = 7, 7 do
    form.groupmap_objs:ShowType(t, self.Checked)
  end
  save_btn_state("small_map_icon_enemy_guild", self.Checked)
end
function on_cbtn_zudui_checked_changed(self)
  local form = self.ParentForm
  change_player_image(form, "team_rec", TEAM_REC_COL_NAME)
  form.groupmap_objs:ShowType(168, self.Checked)
  save_btn_state("small_map_icon_team", self.Checked)
end
function on_cbtn_tuandui_checked_changed(self)
  local form = self.ParentForm
  change_player_image(form, "team_rec", TEAM_REC_COL_NAME)
  form.groupmap_objs:ShowType(169, self.Checked)
  save_btn_state("small_map_icon_group", self.Checked)
end
function on_cbtn_chouren_checked_changed(self)
  local form = self.ParentForm
  change_player_image(form, "rec_enemy", 1)
  change_player_image(form, "rec_blood", 1)
  form.groupmap_objs:ShowType(311, self.Checked)
  save_btn_state("small_map_icon_enemy", self.Checked)
end
function on_btn_show_click(self)
  local form = self.ParentForm
  local groupbox = form.groupbox_filter
  groupbox.Visible = not groupbox.Visible
  groupbox.AbsLeft = self.AbsLeft - groupbox.Width
  groupbox.AbsTop = self.AbsTop + 10
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
end
function show_object(obj_type, flag)
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  form.groupmap_objs:ShowType(obj_type, flag)
end
function remove_object(ident)
end
function on_groupmap_objs_click_obj(self, vis_obj)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if client_player:FindProp("LogicState") then
    local offline_state = client_player:QueryProp("LogicState")
    if nx_int(offline_state) == nx_int(LS_OFFLINEJOB) then
      return
    end
  end
  local game_visual = nx_value("game_visual")
  local vis_obj_ident = game_visual:QueryRoleClientIdent(vis_obj)
  if not client_player:FindProp("LastObject") or not nx_id_equal(client_player:QueryProp("LastObject"), nx_object(vis_obj_ident)) then
    nx_execute("custom_sender", "custom_select", vis_obj_ident)
  end
  local trace = nx_value("path_finding")
  if not nx_is_valid(trace) then
    return
  end
  local trace_flag = trace.AutoTraceFlag
  if trace_flag == 1 or trace_flag == 2 then
    trace:TraceTarget(vis_obj, 2, "", "")
  end
end
function on_groupmap_objs_mouse_in_obj(self, vis_obj, x, y)
  local form = self.ParentForm
  if not form.groupbox_smallmap.Visible then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local vis_obj_ident = game_visual:QueryRoleClientIdent(vis_obj)
  local client_obj = game_client:GetSceneObj(vis_obj_ident)
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local self_y = visual_player.PositionY
  local other_y
  if not nx_is_valid(client_obj) then
    return
  end
  local widestr_info
  local obj_type = client_obj:QueryProp("Type")
  if obj_type == TYPE_NPC then
    local configid = client_obj:QueryProp("ConfigID")
    widestr_info = gui.TextManager:GetText(configid)
    local mgr = nx_value("SceneCreator")
    local map_query = nx_value("MapQuery")
    if nx_is_valid(mgr) and nx_is_valid(map_query) then
      local res = mgr:GetNpcPosition(map_query:GetCurrentScene(), configid)
      if table.getn(res) == 3 then
        other_y = res[2]
      end
    end
  elseif obj_type == TYPE_PLAYER then
    local game_role = game_client:GetPlayer()
    local scene = game_client:GetScene()
    local is_clone = false
    if nx_is_valid(scene) then
      is_clone = scene:FindProp("SourceID")
    end
    local pkmode = game_role:QueryProp("PKMode")
    local selfArenaSide = game_role:QueryProp("ArenaSide")
    local arenaSide = client_obj:QueryProp("ArenaSide")
    local visual_obj = game_visual:GetSceneObj(vis_obj_ident)
    if nx_is_valid(visual_obj) then
      other_y = visual_obj.PositionY
    end
    if nx_boolean(is_clone) then
      if nx_number(pkmode) == 3 then
        if nx_number(selfArenaSide) == nx_number(arenaSide) then
          widestr_info = client_obj:QueryProp("Name")
        end
      else
        widestr_info = client_obj:QueryProp("Name")
      end
    else
      widestr_info = client_obj:QueryProp("Name")
    end
    if is_in_outlandwar() and nx_number(selfArenaSide) ~= nx_number(arenaSide) then
      widestr_info = nil
    end
    local interactmgr = nx_value("InteractManager")
    if nx_is_valid(interactmgr) and interactmgr:GetInteractStatus(ITT_MAZE_HUNT_HILL) == PIS_IN_GAME then
      widestr_info = gui.TextManager:GetText("ui_maze_hunt_player")
    end
    local in_battle = client_obj:QueryProp("BattlefieldState")
    local STATE_ALREADY_ENTER = 3
    if STATE_ALREADY_ENTER == in_battle then
      local selfArenaSide = game_role:QueryProp("ArenaSide")
      local ARENA_MODE_SINGLE = 0
      if ARENA_MODE_SINGLE == selfArenaSide then
        widestr_info = gui.TextManager:GetText("ui_battle_name")
      else
        local arenaSide = client_obj:QueryProp("ArenaSide")
        if selfArenaSide ~= arenaSide then
          widestr_info = gui.TextManager:GetText("ui_battle_name")
        end
      end
    end
    local hide_name_type = nx_int(client_obj:QueryProp("IsHideName"))
    if hide_name_type > nx_int(0) then
      if hide_name_type == nx_int(1) then
        widestr_info = gui.TextManager:GetText("ui_shimendahui_player")
      elseif hide_name_type == nx_int(2) then
        widestr_info = gui.TextManager:GetText("ui_wugenmen_shilian_player")
      end
    end
    if 0 < client_obj:QueryProp("IsHideFace") then
      widestr_info = gui.TextManager:GetText("ui_mengmianren")
    end
    if 0 < game_role:QueryProp("IsRevenge") then
      widestr_info = gui.TextManager:GetText("ui_tianti_playername")
    end
    if nx_execute("form_stage_main\\form_night_forever\\form_fin_main", "is_in_flee_in_night") then
      widestr_info = gui.TextManager:GetText("ui_fin_name")
    end
  end
  if widestr_info ~= nil then
    local gui = nx_value("gui")
    if self_y ~= nil and other_y ~= nil then
      local image = ""
      local value = other_y - self_y
      if 5 < value then
        image = "gui\\map\\minimap\\icon_up.png"
        value = nx_int(math.abs(value))
        gui.TextManager:Format_SetIDName("ui_minimaptipy")
        gui.TextManager:Format_AddParam(widestr_info)
        gui.TextManager:Format_AddParam(nx_string(image))
        gui.TextManager:Format_AddParam(nx_string(value) .. " ")
        widestr_info = gui.TextManager:Format_GetText()
      elseif value < -5 then
        image = "gui\\map\\minimap\\icon_down.png"
        value = nx_int(math.abs(value))
        gui.TextManager:Format_SetIDName("ui_minimaptipy2")
        gui.TextManager:Format_AddParam(widestr_info)
        gui.TextManager:Format_AddParam(nx_string(image))
        gui.TextManager:Format_AddParam(nx_string(value) .. " ")
        widestr_info = gui.TextManager:Format_GetText()
      end
    end
    form.mouse_in_obj = true
    nx_execute("tips_game", "show_text_tip", nx_widestr(widestr_info), x, y, 0, form)
  end
end
function on_groupmap_objs_mouse_out_obj(self, vis_obj)
  local form = self.ParentForm
  form.mouse_in_obj = false
  nx_execute("tips_game", "hide_tip", form)
end
function on_roundbox_smallmap_left_up(round_map, offset_x, offset_y)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindProp("LogicState") then
    local offline_state = client_player:QueryProp("LogicState")
    if nx_int(offline_state) == nx_int(LS_OFFLINEJOB) then
      return
    end
  end
  local terrain_width = round_map.TerrainWidth
  local terrain_height = round_map.TerrainHeight
  local terrain_start_x = round_map.TerrainStartX
  local terrain_start_z = round_map.TerrainStartZ
  local map_width = round_map.ImageWidth
  local map_height = round_map.ImageHeight
  local scale = round_map.ZoomWidth
  local inter_xpos = -(round_map.Width / 2 - offset_x)
  local inter_ypos = round_map.Height / 2 - offset_y
  inter_xpos = map_width - round_map.CenterX - inter_xpos / scale
  inter_ypos = round_map.CenterY - inter_ypos / scale
  inter_xpos = terrain_start_x + inter_xpos * terrain_width / map_width
  inter_zpos = terrain_start_z + inter_ypos * terrain_height / map_height
  local path_finding = nx_value("path_finding")
  path_finding:FindPath(inter_xpos, -10000, inter_zpos, 0)
end
function on_roundbox_smallmap_get_capture(round_map)
end
function on_roundbox_smallmap_lost_capture(round_map)
  local form = round_map.ParentForm
  if nx_find_custom(form, "mouse_in_obj") and form.mouse_in_obj then
    return
  end
  nx_execute("tips_game", "hide_tip", round_map.ParentForm)
end
function on_roundbox_smallmap_mouse_move(round_map, offset_x, offset_y)
  local form = round_map.ParentForm
  if not form.groupbox_smallmap.Visible then
    return
  end
  if nx_find_custom(form, "mouse_in_obj") and form.mouse_in_obj then
    return
  end
  local terrain_width = round_map.TerrainWidth
  local terrain_height = round_map.TerrainHeight
  local terrain_start_x = round_map.TerrainStartX
  local terrain_start_z = round_map.TerrainStartZ
  local map_width = round_map.ImageWidth
  local map_height = round_map.ImageHeight
  local scale = round_map.ZoomWidth
  local inter_xpos = -(round_map.Width / 2 - offset_x)
  local inter_ypos = round_map.Height / 2 - offset_y
  inter_xpos = map_width - round_map.CenterX - inter_xpos / scale
  inter_ypos = round_map.CenterY - inter_ypos / scale
  inter_xpos = terrain_start_x + inter_xpos * terrain_width / map_width
  inter_ypos = terrain_start_z + inter_ypos * terrain_height / map_height
  local text = nx_widestr(nx_int(inter_xpos)) .. nx_widestr(",") .. nx_widestr(nx_int(inter_ypos))
  nx_execute("tips_game", "show_text_tip", text, round_map.AbsLeft + offset_x, round_map.AbsTop + offset_y, 0, round_map.ParentForm)
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  form.btn_scene_compete.Visible = false
  local mapQuery = nx_value("MapQuery")
  if nx_is_valid(mapQuery) then
    if mapQuery:IsSpecialScene() then
      form.Visible = false
    else
      form.Visible = true
    end
  end
  form.groupbox_filter1.Visible = false
  local scale = form.roundbox_smallmap.ZoomWidth
  local gui = nx_value("gui")
  local scene_config = client_scene:QueryProp("ConfigID")
  local scene_name = gui.TextManager:GetFormatText(scene_config)
  form.lbl_map_name.Text = nx_widestr(scene_name)
  local resource = client_scene:QueryProp("Resource")
  local file_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".ini"
  local map_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".dds"
  form.roundbox_smallmap.Image = map_name
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. file_name
  ini:LoadFromFile()
  form.roundbox_smallmap.TerrainStartX = ini:ReadInteger("Map", "StartX", 0)
  form.roundbox_smallmap.TerrainStartZ = ini:ReadInteger("Map", "StartZ", 0)
  form.roundbox_smallmap.TerrainWidth = ini:ReadInteger("Map", "Width", 1024)
  form.roundbox_smallmap.TerrainHeight = ini:ReadInteger("Map", "Height", 1024)
  form.roundbox_smallmap.ZoomWidth = 1
  form.roundbox_smallmap.ZoomHeight = 1
  form.groupmap_objs:Clear()
  form.groupmap_objs:InitTerrain(form.roundbox_smallmap.TerrainStartX, form.roundbox_smallmap.TerrainStartZ, form.roundbox_smallmap.TerrainWidth, form.roundbox_smallmap.TerrainHeight)
  reset_obj(form)
  reset_schoolfight_control(form)
  local is_random = ini:ReadInteger("Map", "random", 1)
  local random_info = client_scene:QueryProp("RandomTerrainInfo")
  if random_info ~= "" and is_random == 0 then
    local res = create_random_terrain_map(form, resource, resource, form.roundbox_smallmap.ImageWidth, form.roundbox_smallmap.ImageHeight)
    if not res then
      form.roundbox_smallmap.Image = map_name
    end
  end
  nx_destroy(ini)
  if not is_in_cross_station_war() then
    form.btn_cross_station_war.Visible = false
  end
  if not is_in_league_matches() then
    form.btn_league_matches.Visible = false
  end
  if not is_in_guild_war() then
    form.btn_guild_battle_war.Visible = false
  end
  local flag = is_in_balance_war()
  if not flag then
    form.btn_balance_war.Visible = false
  end
  local in_wudao = nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "is_in_wudao_fight_scene")
  if not in_wudao then
    form.btn_wudao.Visible = false
  end
  reset_luandou_ctrl(form)
  reset_taosha_ctrl(form)
end
function reset_schoolfight_control(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local value_flag = client_player:QueryProp("IsInSchoolFight")
  if nx_number(value_flag) == 1 then
    form.btn_sf_order.Visible = true
  else
    form.btn_sf_order.Visible = false
    nx_execute("form_stage_main\\form_school_war\\form_school_fight_rank", "close_form")
  end
end
function refresh_nlb_shimen_btn(form)
  if not nx_is_valid(form) then
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
  local value_flag = client_player:QueryProp("NLBSchoolMeetGroup")
  if nx_int(value_flag) > nx_int(0) then
    form.btn_nlb_shimen_rank.Visible = true
  else
    form.btn_nlb_shimen_rank.Visible = false
    nx_execute("form_stage_main\\form_nlb_shimen_rank", "close_form")
  end
end
function refresh_hsp_meet_btn(form)
  if not nx_is_valid(form) then
    return
  end
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return
  end
  if interactmgr:GetInteractStatus(ITT_HUASHANSCHOOL_MEET) == PIS_IN_GAME then
    form.btn_hsp_meet.Visible = true
  else
    form.btn_hsp_meet.Visible = false
  end
  if interactmgr:GetInteractStatus(ITT_OUTLAND_WAR) == PIS_IN_GAME then
    form.btn_outland_war.Visible = true
  else
    form.btn_outland_war.Visible = false
  end
  if interactmgr:GetInteractStatus(ITT_SCHOOL_COUNTER_ATTACK) == PIS_IN_GAME then
    form.btn_sca_rank.Visible = true
  else
    form.btn_sca_rank.Visible = false
  end
end
function refresh_sanmeng_btn(form, propname, proptype, value)
  if nx_int(value) == nx_int(0) then
    form.btn_sanmeng.Visible = false
  else
    form.btn_sanmeng.Visible = true
  end
end
function on_btn_sanmeng_click(btn)
  nx_execute("form_stage_main\\form_match\\form_sanmeng_score", "open_form")
end
function refresh_new_war_rule_btn(form, propname, proptype, value)
  if nx_int(value) == nx_int(0) then
    form.btn_new_war_rule.Visible = false
  else
    form.btn_new_war_rule.Visible = true
  end
end
function on_btn_new_war_rule_click(btn)
  nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_score", "open_form")
end
function reset_obj(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.groupmap_objs) then
    return
  end
  local form_logic = nx_value("form_main_map_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  form.groupmap_objs:Clear()
  local obj_list = client_scene:GetSceneObjList()
  local client_player = game_client:GetPlayer()
  local game_visual = nx_value("game_visual")
  for i = 1, table.maxn(obj_list) do
    if not game_client:IsPlayer(obj_list[i].Ident) then
      local type_string = form_logic:GetSceneObjType(obj_list[i], "")
      local vis_obj = game_visual:GetSceneObj(obj_list[i].Ident)
      if nx_is_valid(vis_obj) then
        local npc_type = obj_list[i]:QueryProp("NpcType")
        if "TEAN_PLAYER" == type_string or "REGIMENT_PLAYER" == type_string then
          npc_type = get_bind_type(obj_list[i])
        end
        vis_obj.bind_type = npc_type
        form.groupmap_objs:AddBind(type_string, vis_obj)
      end
    end
  end
  form.groupmap_objs:AddMainPlayerBind("gui\\map\\icon\\me.png", game_visual:GetPlayer())
end
function update_map_scene_obj(client_obj)
  if not nx_is_valid(client_obj) then
    return
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  local form_logic = nx_value("form_main_map_logic")
  if not nx_is_valid(form_logic) then
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
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local found = false
  local obj_list = client_scene:GetSceneObjList()
  for i = 1, table.getn(obj_list) do
    if nx_id_equal(client_obj, obj_list[i]) then
      found = true
      break
    end
  end
  if not found then
    return
  end
  if not game_client:IsPlayer(client_obj.Ident) then
    local type_string = form_logic:GetSceneObjType(client_obj, "")
    local vis_obj = game_visual:GetSceneObj(client_obj.Ident)
    if nx_is_valid(vis_obj) then
      local npc_type = client_obj:QueryProp("NpcType")
      vis_obj.bind_type = npc_type
      form.groupmap_objs:DelBind(vis_obj)
      form.groupmap_objs:AddBind(type_string, vis_obj)
    end
  end
end
function on_btn_bigmap_push(button)
end
function on_btn_bigmap_drag_move(button, x, y)
end
function on_btn_bigmap_get_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local cursor_x, cursor_y = gui:GetCursorPosition()
  local widestr_info = gui.TextManager:GetText("ui_littlemap_tips_quyuditu")
  nx_execute("tips_game", "show_text_tip", nx_widestr(widestr_info), cursor_x, cursor_y, 0, form)
end
function on_btn_bigmap_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_show_get_capture(self)
end
function on_btn_show_lost_capture(self)
end
function on_lbl_position_get_capture(self)
  local role = nx_value("role")
  if nx_is_valid(role) and nx_find_custom(role, "small_map_limit") and role.small_map_limit == true then
    return
  end
  if not nx_find_custom(self, "pos_x") or not nx_find_custom(self, "pos_z") then
    return
  end
  local form = self.ParentForm
  local gui = nx_value("gui")
  local cursor_x, cursor_y = gui:GetCursorPosition()
  local widestr_info = gui.TextManager:GetFormatText("ui_littlemap_tips_zuobiao", nx_int(self.pos_x), nx_int(self.pos_z))
  nx_execute("tips_game", "show_text_tip", nx_widestr(widestr_info), cursor_x, cursor_y, 0, form)
end
function on_lbl_position_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_area_info_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_main\\form_area_info")
end
function on_btn_pathfinding_get_capture(self)
end
function on_btn_pathfinding_lost_capture(self)
end
function on_btn_pathfinding_click(self)
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  if is_auto_find_path() then
    return
  end
  local path_finding = nx_value("path_finding")
  local drawpath = path_finding.DrawPath
  if nx_is_valid(drawpath) then
    drawpath:EndDraw()
  end
end
function format_info(strid, ...)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(strid)
  for i, para in pairs(arg) do
    local type = nx_type(para)
    if type == "number" then
      gui.TextManager:Format_AddParam(nx_int(para))
    elseif type == "string" then
      gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
    else
      gui.TextManager:Format_AddParam(para)
    end
  end
  return gui.TextManager:Format_GetText()
end
function on_btn_4_click(btn)
end
function on_btn_4_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local form_logic = nx_value("form_main_map_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  form.bShowTips = true
  local fps = nx_widestr(nx_int(gui.FPS))
  local str_fps = nx_widestr(gui.TextManager:GetText("ui_CurrentFrames"))
  local str_delay = nx_widestr(gui.TextManager:GetText("ui_NetDelay"))
  local str_serverdelay = nx_widestr(gui.TextManager:GetText("ui_serverdelay"))
  local str_diubao = nx_widestr(gui.TextManager:GetText("ui_diubao"))
  local str_ping = nx_widestr(util_text("ui_get_net_data"))
  local net_delay = form_logic.NetDelay
  local sev_delay = form_logic.SevDelay
  nx_execute("tips_game", "show_text_tip", nx_widestr(str_fps .. fps .. nx_widestr(" FPS<br>") .. str_delay .. nx_widestr(net_delay) .. nx_widestr(" ms<br>") .. str_serverdelay .. nx_widestr(sev_delay) .. nx_widestr(" ms")), btn.AbsLeft - 80, btn.AbsTop, 0, btn.ParentForm)
end
function on_btn_4_lost_capture(btn)
  local form = btn.ParentForm
  nx_execute("tips_game", "hide_tip", form)
  form.bShowTips = false
end
function update_enemy(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "update_enemy", form)
  change_player_image(form, "rec_enemy", 1)
  change_player_image(form, "rec_blood", 1)
end
function update_client_object_by_name(form, name, filter)
  local form_logic = nx_value("form_main_map_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  form_logic:UpdateClientObjectByName(form, name, filter)
end
function get_bind_type(client_obj)
  local form_logic = nx_value("form_main_map_logic")
  if not nx_is_valid(form_logic) then
    return 0
  end
  return form_logic:GetBindType(client_obj)
end
function on_vip_status_changed(form)
  local g_icon = {
    [0] = {
      NormalImage = "gui\\map\\minimap\\btn_y_on.png",
      FocusImage = "gui\\map\\minimap\\btn_y_out.png"
    },
    [1] = {
      NormalImage = "gui\\map\\minimap\\btn_x_on.png",
      FocusImage = "gui\\map\\minimap\\btn_x_out.png"
    }
  }
  local btn = form.btn_pathfinding
  local vipmodule = nx_value("VipModule")
  if not nx_is_valid(vipmodule) then
    return
  end
  local status = 0
  if nx_is_valid(vipmodule) and vipmodule:IsVip(VT_NORMAL) then
    status = 1
  end
  local c = g_icon[status]
  if c == nil then
    return
  end
  for prop, val in pairs(c) do
    btn[prop] = val
  end
end
function set_trace_npc_id(npc_id, npc_x, npc_z, scene_id)
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  form.btn_npc.scene_id = scene_id
  form.btn_npc.npc_id = npc_id
  form.btn_npc.npc_x = nx_number(npc_x)
  form.btn_npc.npc_z = nx_number(npc_z)
end
function on_btn_npc_get_capture(self)
  if not (nx_find_custom(self, "npc_id") and nx_find_custom(self, "npc_x")) or not nx_find_custom(self, "npc_z") then
    return
  end
  local form = self.ParentForm
  local npc_id = form.btn_npc.npc_id
  if npc_id == nil or npc_id == "" then
    return
  end
  local gui = nx_value("gui")
  local name = gui.TextManager:GetText(npc_id)
  if nx_find_custom(self, "scene_id") and self.scene_id and self.scene_id ~= "" and not form.map_query:IsPlayerInScene(self.scene_id) then
    local scene_name = gui.TextManager:GetText("scene_" .. self.scene_id)
    name = nx_widestr(scene_name) .. nx_widestr(" ") .. nx_widestr(name)
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(name), self.AbsLeft + 20, self.AbsTop + 10, 0, form)
end
function on_btn_npc_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_theme_helper_click(self)
  util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
end
function open_form_freshman()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  local self = form.btn_regulations
  local data_list = util_split_string(self.data_source, ";")
  if table.getn(data_list) > 0 then
    if "" == data_list[1] then
      nx_execute("form_stage_main\\form_freshman\\form_freshman_main", "util_open_form", "")
    else
      nx_execute("form_stage_main\\form_freshman\\form_freshman_main", "util_open_form", data_list[1])
    end
    self.data_source = ""
    if table.getn(data_list) > 1 then
      for i = 2, table.getn(data_list) do
        if 0 < string.len(data_list[i]) then
          self.data_source = self.data_source .. nx_string(data_list[i]) .. ";"
        end
      end
    else
      self.ParentForm.lbl_regulations_note.Visible = false
    end
  else
    nx_execute("form_stage_main\\form_freshman\\form_freshman_main", "util_open_form", "")
    self.ParentForm.lbl_regulations_note.Visible = false
  end
end
function on_btn_regulations_click(self)
  local client_player = get_player()
  local single_state = client_player:QueryProp("SingleState")
  if 0 == single_state then
    open_form_freshman()
  else
  end
end
function get_new_info()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  return form.btn_regulations.data_source
end
function helper_tips_info(form)
  if not offset_helper_index(form) then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "helper_tips_info", form)
    form.mltbox_tips_info.Visible = false
  end
end
function add_regulations_note(str_note)
  if str_note == nil or str_note == "," then
    return
  end
  local str_note_len = string.len(str_note)
  if str_note_len == 0 then
    return
  end
  if string.sub(str_note, str_note_len, str_note_len) == "," then
    str_note = string.sub(str_note, 1, str_note_len - 1)
  end
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_regulations_note.Visible = true
  local data_list = util_split_string(str_note, ",")
  if 0 >= table.getn(data_list) then
    return
  end
  form.btn_regulations.data_source = str_note
  local custom_name = data_list[table.getn(data_list)] .. "_tips"
  nx_set_custom(form.btn_regulations, custom_name, false)
  if not form.mltbox_tips_info.Visible then
    local timer = nx_value(GAME_TIMER)
    timer:Register(5000, -1, nx_current(), "helper_tips_info", form, -1, -1)
    offset_helper_index(form)
  end
end
function offset_helper_index(form)
  local btn = form.btn_regulations
  local data_source_list = util_split_string(btn.data_source, ";")
  for i, data in ipairs(data_source_list) do
    if "" ~= data then
      local data_list = util_split_string(data, ",")
      local node_name = data_list[table.getn(data_list)]
      local custom_name = node_name .. "_tips"
      if nx_find_custom(btn, custom_name) and false == nx_custom(btn, custom_name) then
        form.mltbox_tips_info.Visible = true
        local gui = nx_value("gui")
        local tips_text = gui.TextManager:GetText("tips_" .. nx_string(node_name))
        form.mltbox_tips_info:Clear()
        form.mltbox_tips_info:AddHtmlText(nx_widestr(tips_text), -1)
        form.mltbox_tips_info.Height = form.mltbox_tips_info:GetContentHeight() + 30
        nx_set_custom(btn, custom_name, true)
        gui.Desktop:ToFront(form)
        return true
      end
    end
  end
  return false
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function get_player_pos()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  return visual_player.PositionX, visual_player.PositionZ
end
function on_btn_guild_war_click(btn)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_order", "out_open")
end
function on_btn_world_war_click(btn)
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local propSceneID = client_scene:QueryProp("SourceID")
  if nx_int(propSceneID) == nx_int(400) then
    util_auto_show_hide_form("form_stage_main\\form_world_war\\form_world_war_stat")
  elseif nx_int(propSceneID) == nx_int(401) then
    util_auto_show_hide_form("form_stage_main\\form_world_war\\form_world_war_lingxiao_stat")
  end
end
function on_btn_nlb_shimen_rank_click(btn)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value_flag = client_player:QueryProp("NLBSchoolMeetGroup")
  if nx_number(value_flag) > 0 then
    util_auto_show_hide_form("form_stage_main\\form_nlb_shimen_rank")
  end
end
function on_btn_hsp_meet_click(btn)
  nx_execute("form_stage_main\\form_force\\form_force_hsp_meet", "open_or_hide")
end
function on_btn_outland_war_click(btn)
  nx_execute("form_stage_main\\form_outland_war\\form_outland_war_score", "open_or_hide")
end
function send_world_war_custom_msg(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(sub_msg), unpack(arg))
end
function on_btn_tvt_click(self)
  util_auto_show_hide_form("form_stage_main\\form_tvt\\form_tvt")
end
function change_player_image(form, rec_name, rec_col)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row_count = client_player:GetRecordRows(rec_name)
  local name = client_player:QueryProp("Name")
  for row_index = 0, row_count - 1 do
    local othername = client_player:QueryRecord(rec_name, row_index, rec_col)
    if othername ~= name then
      update_client_object_by_name(form, othername, "")
    end
  end
end
function on_btn_research_click(self)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    switch_manager:OpenUrl(URL_TYPE_9YIN_QUESTIONNAIRE)
  end
end
function on_btn_bf_order_click(btn)
  local form_order = util_get_form("form_stage_main\\form_battlefield\\form_battlefield_order", true)
  if not nx_is_valid(form_order) then
    return
  end
  local time_now = os.time()
  form_order.time_stamp = time_now
  form_order.Visible = true
  form_order:Show()
  local CLIENT_SUBMSG_QUERY_SORT = 5
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_QUERY_SORT, time_now)
end
function get_ping_value()
  local ClientDataFetch = nx_value("ClientDataFetch")
  if not nx_is_valid(ClientDataFetch) then
    return
  end
  local ave = ClientDataFetch:GetPingAve()
  local loss = ClientDataFetch:GetPingLoss()
  return ave, loss
end
function start_ping()
  local ClientDataFetch = nx_value("ClientDataFetch")
  if not nx_is_valid(ClientDataFetch) then
    return
  end
  ClientDataFetch:StartCmdPing()
end
function show_net_data(btn)
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "bShowTips") or not form.bShowTips then
    return
  end
  local gui = nx_value("gui")
  local form_logic = nx_value("form_main_map_logic")
  if not nx_is_valid(form_logic) then
    return
  end
  local fps = nx_widestr(nx_int(gui.FPS))
  local str_fps = nx_widestr(gui.TextManager:GetText("ui_CurrentFrames"))
  local str_delay = nx_widestr(gui.TextManager:GetText("ui_NetDelay"))
  local str_serverdelay = nx_widestr(gui.TextManager:GetText("ui_serverdelay"))
  local str_diubao = nx_widestr(gui.TextManager:GetText("ui_diubao"))
  local str_ping = nx_widestr(util_text("ui_get_net_data"))
  local net_delay = form_logic.NetDelay
  local sev_delay = form_logic.SevDelay
  local btn = form.btn_net_red
  nx_execute("tips_game", "show_text_tip", nx_widestr(str_fps .. fps .. nx_widestr(" FPS<br>") .. str_delay .. nx_widestr(net_delay) .. nx_widestr(" ms<br>") .. str_serverdelay .. nx_widestr(sev_delay) .. nx_widestr(" ms")), btn.AbsLeft - 80, btn.AbsTop, 0, form)
end
function on_btn_iq_click(btn)
  local mgr = nx_value("SwitchManager")
  if not nx_is_valid(mgr) then
    return
  end
  local flag = mgr:CheckSwitchEnable(ST_WENBA_RAINBOW_ACTIVE)
  if flag == false then
    return
  end
  nx_execute("form_stage_main\\form_gmcc\\form_sdqa", "open_form")
end
function on_custom_guild_enemy(...)
  nCount = table.getn(arg)
  local small_map = nx_value("form_main_map_logic")
  if not nx_is_valid(small_map) then
    return
  end
  small_map:GuildEnemyListMethod(nx_widestr(" "), 0)
  for i = 1, nCount / 2 do
    small_map:GuildEnemyListMethod(nx_widestr(arg[2 * (i - 1) + 1]), 1)
  end
end
function GuildEnemyList(MethodID, Name)
  local small_map = nx_value("form_main_map_logic")
  if not nx_is_valid(small_map) then
    return
  end
  if Name == nil and MethodID == 0 then
    small_map:GuildEnemyListMethod(nx_widestr(" "), MethodID)
  else
    small_map:GuildEnemyListMethod(Name, MethodID)
  end
end
function on_btn_seven_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_SNDA_ACTIVITY_SERVER_WISH) then
    nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "open_form", "form_stage_main\\form_activity\\form_activity_seven")
  end
end
function load_btn_state(form)
  form.cbtn_hide.Checked = GetCfgInfo("small_map_icon_role") == 1
  form.cbtn_chouren.Checked = GetCfgInfo("small_map_icon_enemy") == 1
  form.cbtn_eshili.Checked = GetCfgInfo("small_map_icon_enemy_guild") == 1
  form.cbtn_zudui.Checked = GetCfgInfo("small_map_icon_team") == 1
  form.cbtn_tuandui.Checked = GetCfgInfo("small_map_icon_group") == 1
end
function save_btn_state(PropertyName, BtnValue)
  local btnchk = GetCfgInfo(PropertyName) == 1
  if btnchk == BtnValue then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  if BtnValue == true then
    nx_set_property(game_config, nx_string(PropertyName), 1)
    nx_execute("game_config", "save_game_config_item", "system_set.ini", "Main", nx_string(PropertyName), 1)
  else
    nx_set_property(game_config, nx_string(PropertyName), 0)
    nx_execute("game_config", "save_game_config_item", "system_set.ini", "Main", nx_string(PropertyName), 0)
  end
end
function on_btn_playsnail_main_click(self)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OPEN_PLAYSNAIL_MAIN))
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  local cur_page = form.imagegrid_func.page
  if cur_page < 0 then
    return
  end
  local func_icon_mgr = nx_value("func_icon_mgr")
  if not nx_is_valid(func_icon_mgr) then
    return
  end
  form.imagegrid_func.page = cur_page - 1
  func_icon_mgr:RefreshGrid(form.imagegrid_func)
end
function on_btn_right_click(btn)
  local func_icon_mgr = nx_value("func_icon_mgr")
  if not nx_is_valid(func_icon_mgr) then
    return
  end
  local form = btn.ParentForm
  local max_page = func_icon_mgr:GetMaxPage(form.imagegrid_func)
  local cur_page = form.imagegrid_func.page
  if max_page <= cur_page + 1 then
    return
  end
  form.imagegrid_func.page = cur_page + 1
  func_icon_mgr:RefreshGrid(form.imagegrid_func)
end
function on_imagegrid_func_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local func_icon_mgr = nx_value("func_icon_mgr")
  if not nx_is_valid(func_icon_mgr) then
    return
  end
  local func_index = grid:GetBindIndex(index)
  local tips_text = func_icon_mgr:GetTipsText(func_index)
  nx_execute("tips_game", "show_text_tip", util_text(tips_text), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop())
end
function on_imagegrid_func_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_func_select_changed(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local func_index = grid:GetBindIndex(index)
  local func_icon_mgr = nx_value("func_icon_mgr")
  if nx_is_valid(func_icon_mgr) then
    func_icon_mgr:OnClick(func_index)
  end
end
function on_cbtn_2_checked_changed(cbtn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = cbtn.ParentForm
  form.groupbox_main_box.Visible = cbtn.Checked
  if cbtn.Checked then
    gui.Desktop:ToFront(form.groupbox_main_box)
    local form_main = nx_value("form_stage_main\\form_main\\form_main")
    if nx_is_valid(form_main) then
      gui.Desktop:ToBack(form_main.btn_open_yy)
    end
  end
end
function on_cbtn_gmcc_url_checked_changed(cbtn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    switch_manager:OpenUrl(URL_TYPE_OPEN_GMCC_URL)
  end
end
function set_btn_playsnail_main_status(form)
  local isShow = nx_execute("playsnail\\playsnail_common", "GetCfgItem", "playsnail", "IsShow")
  if nx_int(isShow) > nx_int(0) then
    form.btn_playsnail_main.Visible = true
  else
    form.btn_playsnail_main.Visible = false
  end
end
function on_btn_2_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_tvt\\form_tvt_news")
end
function update_weather()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  local WeatherTimeManager = nx_value("WeatherTimeManager")
  if nx_is_valid(WeatherTimeManager) then
    local name_id = WeatherTimeManager:GetWeatherType(-1)
    if 0 == name_id then
      form.lbl_tianqi.BackImage = ""
      form.lbl_tianqi.HintText = nx_widestr("")
      return
    end
    form.lbl_tianqi.BackImage = "gui\\map\\weather\\tianqi_" .. nx_string(name_id) .. ".png"
    form.lbl_tianqi.HintText = util_text("tianqi_" .. nx_string(name_id))
  end
end
function hide_world_war_btn()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  form.btn_world_war.Visible = false
end
function show_scene_compete_icon(bVisible)
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if bVisible then
    while not nx_is_valid(form) do
      nx_pause(1)
      form = nx_value("form_stage_main\\form_main\\form_main_map")
    end
    form.btn_scene_compete.Visible = true
  else
    if not nx_is_valid(form) then
      return
    end
    form.btn_scene_compete.Visible = false
  end
end
function on_btn_scene_compete_click(btn)
  local form_scene_compete = nx_value("form_stage_main\\form_scene_compete\\form_scene_compete")
  if nx_is_valid(form_scene_compete) then
    form_scene_compete:Close()
  else
    nx_execute("custom_sender", "custom_send_scene_compete_msg", OP_SCENE_COMPETE_REQUESTDLG)
  end
end
function on_btn_wuque_buy_click(btn)
  nx_execute("form_stage_main\\form_force\\form_wuque_buy_extra", "open_or_hide")
end
function set_drop_box_npc_id(npc_id, npc_x, npc_z, scene_id)
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  form.btn_drop_npc.scene_id = scene_id
  form.btn_drop_npc.npc_id = npc_id
  form.btn_drop_npc.npc_x = nx_number(npc_x)
  form.btn_drop_npc.npc_z = nx_number(npc_z)
end
function on_btn_drop_npc_get_capture(btn)
  local form = btn.ParentForm
  nx_execute("tips_game", "show_text_tip", util_text("tips_jh_drop_tbyd"), btn.AbsLeft + btn.Width / 2, btn.AbsTop - btn.Height / 2, 0, form)
end
function on_btn_drop_npc_lost_capture(btn)
  local form = btn.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_drop_npc_click(btn)
  btn.npc_id = ""
end
function on_label_drop_get_capture(lbl)
  local form = lbl.ParentForm
  if not (nx_find_custom(lbl, "x") and nx_find_custom(lbl, "z")) or not nx_find_custom(lbl, "stop_time") then
    return
  end
  local MessageDelay = nx_value("MessageDelay")
  if not nx_is_valid(MessageDelay) then
    return
  end
  local stop_time = lbl.stop_time
  local cur_time = MessageDelay:GetServerSecond()
  local dis = stop_time - cur_time
  local time_minute = nx_int(dis / 60)
  local time_second = math.fmod(dis, 60)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("tips_jh_drop_info")
  gui.TextManager:Format_AddParam(nx_int(lbl.x))
  gui.TextManager:Format_AddParam(nx_int(lbl.z))
  gui.TextManager:Format_AddParam(nx_int(time_minute))
  gui.TextManager:Format_AddParam(nx_int(time_second))
  nx_execute("tips_game", "show_text_tip", gui.TextManager:Format_GetText(), lbl.AbsLeft + lbl.Width / 2, lbl.AbsTop - lbl.Height / 2, 0, form)
end
function on_label_drop_lost_capture(lbl)
  local form = lbl.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function update_newjh_map_ui(form)
  local ini = get_ini("ini\\ui\\newjh\\NewJHUIConf.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("Form_Main_Map"))
  if sec_index < 0 then
    return
  end
  local new_hide_item = ini:ReadString(sec_index, "new_hide", "")
  local tbItems = nx_function("ext_split_string", nx_string(new_hide_item), ",")
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    show_hide_controls(form, tbItems, false)
    form.lbl_13.Visible = true
    local new_lbl_7_item = ini:ReadString(sec_index, "new_lbl_7", "")
    local tbNewLbl7Items = nx_function("ext_split_string", nx_string(new_lbl_7_item), ",")
    show_form_pos(form, "lbl_7", tbNewLbl7Items[1], tbNewLbl7Items[2], tbNewLbl7Items[3], tbNewLbl7Items[4], tbNewLbl7Items[5])
    local new_lbl_time_item = ini:ReadString(sec_index, "new_lbl_time", "")
    local tbNewLblTimeItems = nx_function("ext_split_string", nx_string(new_lbl_time_item), ",")
    show_form_pos(form, "lbl_time", tbNewLblTimeItems[1], tbNewLblTimeItems[2], tbNewLblTimeItems[3], tbNewLblTimeItems[4], tbNewLblTimeItems[5])
    local new_lbl_tianqi_item = ini:ReadString(sec_index, "new_lbl_tianqi", "")
    local tbNewLblTianQiItems = nx_function("ext_split_string", nx_string(new_lbl_tianqi_item), ",")
    show_form_pos(form, "lbl_tianqi", tbNewLblTianQiItems[1], tbNewLblTianQiItems[2], tbNewLblTianQiItems[3], tbNewLblTianQiItems[4], tbNewLblTianQiItems[5])
    local new_lbl_11_item = ini:ReadString(sec_index, "new_lbl_11", "")
    local tbNewLbl11Items = nx_function("ext_split_string", nx_string(new_lbl_11_item), ",")
    show_form_pos(form, "lbl_11", tbNewLbl11Items[1], tbNewLbl11Items[2], tbNewLbl11Items[3], tbNewLbl11Items[4], tbNewLbl11Items[5])
    form.groupbox_jhscene_btns.Visible = true
    local new_btn_9yinzhi_item = ini:ReadString(sec_index, "new_btn_9yinzhi", "")
    local tbNewbtn_9yinzhiItems = nx_function("ext_split_string", nx_string(new_btn_9yinzhi_item), ",")
    show_form_pos(form, "btn_9yinzhi", tbNewbtn_9yinzhiItems[1], tbNewbtn_9yinzhiItems[2], tbNewbtn_9yinzhiItems[3], tbNewbtn_9yinzhiItems[4], tbNewbtn_9yinzhiItems[5])
  else
    show_hide_controls(form, tbItems, true)
    form.lbl_13.Visible = false
    local old_lbl_7_item = ini:ReadString(sec_index, "old_lbl_7", "")
    local tbOldLbl7Items = nx_function("ext_split_string", nx_string(old_lbl_7_item), ",")
    show_form_pos(form, "lbl_7", tbOldLbl7Items[1], tbOldLbl7Items[2], tbOldLbl7Items[3], tbOldLbl7Items[4], tbOldLbl7Items[5])
    local old_lbl_time_item = ini:ReadString(sec_index, "old_lbl_time", "")
    local tbOldLblTimeItems = nx_function("ext_split_string", nx_string(old_lbl_time_item), ",")
    show_form_pos(form, "lbl_time", tbOldLblTimeItems[1], tbOldLblTimeItems[2], tbOldLblTimeItems[3], tbOldLblTimeItems[4], tbOldLblTimeItems[5])
    local old_lbl_tianqi_item = ini:ReadString(sec_index, "old_lbl_tianqi", "")
    local tbOldLblTianQiItems = nx_function("ext_split_string", nx_string(old_lbl_tianqi_item), ",")
    show_form_pos(form, "lbl_tianqi", tbOldLblTianQiItems[1], tbOldLblTianQiItems[2], tbOldLblTianQiItems[3], tbOldLblTianQiItems[4], tbOldLblTianQiItems[5])
    local old_lbl_11_item = ini:ReadString(sec_index, "old_lbl_11", "")
    local tbOldLbl11Items = nx_function("ext_split_string", nx_string(old_lbl_11_item), ",")
    show_form_pos(form, "lbl_11", tbOldLbl11Items[1], tbOldLbl11Items[2], tbOldLbl11Items[3], tbOldLbl11Items[4], tbOldLbl11Items[5])
    form.groupbox_jhscene_btns.Visible = false
    local old_btn_9yinzhi_item = ini:ReadString(sec_index, "old_btn_9yinzhi", "")
    local tbOldbtn_9yinzhiItems = nx_function("ext_split_string", nx_string(old_btn_9yinzhi_item), ",")
    show_form_pos(form, "btn_9yinzhi", tbOldbtn_9yinzhiItems[1], tbOldbtn_9yinzhiItems[2], tbOldbtn_9yinzhiItems[3], tbOldbtn_9yinzhiItems[4], tbOldbtn_9yinzhiItems[5])
    form.btn_world_war.Visible = false
    form.btn_sf_order.Visible = false
    form.btn_bf_order.Visible = false
    form.btn_guild_war.Visible = false
    form.btn_nlb_shimen_rank.Visible = false
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local isInWroldWar = client_player:QueryProp("IsInWorldWar")
    local isSchoolFight = client_player:QueryProp("IsInSchoolFight")
    local battleValue = client_player:QueryProp("BattlefieldState")
    local guildWarID = client_player:QueryProp("GuildWarDomainID")
    local NLBGroup = client_player:QueryProp("NLBSchoolMeetGroup")
    if 0 < isInWroldWar then
      form.btn_world_war.Visible = true
      return
    end
    if isSchoolFight == 1 then
      form.btn_sf_order.Visible = true
      return
    end
    if battleValue == 3 then
      form.btn_bf_order.Visible = true
      return
    end
    if 0 < guildWarID then
      form.btn_guild_war.Visible = true
      return
    end
    if 0 < NLBGroup then
      form.btn_nlb_shimen_rank.Visible = true
      return
    end
  end
  return
end
function show_hide_controls(form, tbControls, bShow)
  if not nx_is_valid(form) then
    return
  end
  for _, item in pairs(tbControls) do
    local control = nx_custom(form, item)
    if nx_is_valid(control) then
      control.Visible = bShow
    end
  end
end
function show_form_pos(form, control_name, x, y, width, height, bg)
  if not nx_is_valid(form) then
    return
  end
  if bg == nil then
    bg = ""
  end
  local control = nx_custom(form, control_name)
  if nx_is_valid(control) then
    control.Visible = true
    control.Left = nx_int(x)
    control.Top = nx_int(y)
    control.Width = nx_int(width)
    control.Height = nx_int(height)
    if nx_string(bg) ~= "" then
      control.BackImage = nx_string(bg)
    end
  end
end
function on_btn_guide_click(btn)
  nx_execute("form_stage_main\\form_task\\form_jianghu_guide_main", "open_form")
end
function on_btn_11_click(btn)
  local form = btn.ParentForm
  form.groupbox_10.Visible = not form.groupbox_10.Visible
end
function on_btn_key_click(btn)
  local form = btn.ParentForm
  local ItemQuery = nx_value("ItemQuery")
  local gui = nx_value("gui")
  if not nx_is_valid(ItemQuery) or not nx_is_valid(gui) then
    return
  end
  if not nx_find_custom(form.combobox_1, "config") then
    return
  end
  local item_name = btn.ParentForm.ipt_search_key.Text
  local item_config_id = form.combobox_1.config
  nx_execute("form_stage_main\\form_market\\form_market", "auto_show_hide_form_market", true)
  local form_market = nx_value("form_stage_main\\form_market\\form_market")
  if not nx_is_valid(form_market) then
    return
  end
  gui.Focused = form_market.ipt_search_key
  local node = form_market.tree_market.RootNode:FindNode(util_text("ui_market_node_" .. "1"))
  form_market.tree_market.SelectNode = node
  form_market.ipt_search_key.Text = nx_widestr(item_name)
  form_market.combobox_itemname.DroppedDown = false
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config_id), nx_string("ItemType"))
  local color_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config_id), nx_string("ColorLevel"))
  local SUB_CLIENT_ITEM_SELECT_CONFIGID = 21
  nx_execute("custom_sender", "custom_market_msg", SUB_CLIENT_ITEM_SELECT_CONFIGID, nx_int(item_type), nx_int(color_level), nx_string(item_config_id))
  form_market.item_type = 0
  form_market.search_type = nx_int(1)
  form_market.combobox_itemname.config = item_config_id
end
function on_combobox_1_selected(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = form.combobox_1.DropListBox.SelectIndex
  if index < table.getn(market_item_table) then
    form.combobox_1.config = market_item_table[index + 1]
  end
  form.ipt_search_key.Text = form.combobox_1.Text
  form.combobox_1.Text = nx_widestr("")
end
function on_ipt_search_key_get_focus(self)
  if nx_ws_equal(self.Text, util_text("ui_trade_search_key")) then
    self.Text = ""
  end
end
function on_ipt_search_key_lost_focus(self)
  if nx_ws_length(self.Text) == 0 then
    self.Text = util_text("ui_trade_search_key")
  end
end
function on_ipt_search_key_changed(self)
  ipt_changed_timer(self)
end
function ipt_changed_timer(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_ws_length(self.Text) == 0 then
    form.combobox_1.DropListBox:ClearString()
    return
  end
  if nx_ws_equal(self.Text, util_text("ui_trade_search_key")) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  form.combobox_1.DropListBox:ClearString()
  local search_table = ItemQuery:FindItemsByName(self.Text)
  market_item_table = {}
  for _, item_config in pairs(search_table) do
    local bExist = ItemQuery:FindItemByConfigID(item_config)
    if bExist then
      local IsMarketItem = ItemQuery:GetItemPropByConfigID(item_config, "IsMarketItem")
      if nx_int(IsMarketItem) == nx_int(1) then
        local static_data = ItemQuery:GetItemPropByConfigID(item_config, "LogicPack")
        local bind_type = item_static_query(nx_int(static_data), "BindType", STATIC_DATA_ITEM_LOGIC)
        if nx_int(bind_type) ~= nx_int(1) and gui.TextManager:IsIDName(item_config) then
          form.combobox_1.DropListBox:AddString(util_text(item_config))
          table.insert(market_item_table, item_config)
        end
      end
    end
  end
  if not form.combobox_1.DroppedDown then
    form.combobox_1.DroppedDown = true
  end
end
function on_btn_huanyuan_click(btn)
  local form = btn.ParentForm
  form.groupbox_filter1.Visible = not form.groupbox_filter1.Visible
  if form.groupbox_filter1.Visible then
    refresh_func_box(form)
  end
end
function refresh_func_box(form)
  if not nx_is_valid(form) then
    return
  end
  local form_sweet = nx_value("form_stage_main\\form_main\\form_main_sweet_employ")
  if nx_is_valid(form_sweet) and form_sweet.Visible == true then
    form.cbtn_blv.Enabled = true
    form.cbtn_blv.Checked = true
  else
    form.cbtn_blv.Checked = false
    form.cbtn_blv.Enabled = false
    form.lbl_yunbiao.Enabled = false
  end
  local form_sable = nx_value("form_stage_main\\form_animalkeep\\form_sable_skill")
  if nx_is_valid(form_sable) and form_sable.Visible == true then
    form.cbtn_lc.Checked = true
  else
    form.cbtn_lc.Checked = false
  end
  local form_equip = nx_value("form_stage_main\\form_main\\form_main_shortcut_onestep")
  if nx_is_valid(form_equip) and form_equip.Visible == true then
    form.cbtn_hz.Checked = true
    form.cbtn_hz.Enabled = true
  else
    local is_vip = check_vip_player()
    if nx_int(is_vip) == nx_int(1) then
      form.cbtn_hz.Enabled = true
      form.cbtn_hz.Checked = false
    else
      form.cbtn_hz.Enabled = false
      form.cbtn_hz.Checked = false
    end
  end
  local form_fwz = nx_value("form_stage_main\\form_card\\form_card_skill")
  if nx_is_valid(form_fwz) and form_fwz.Visible == true then
    form.cbtn_fwz.Checked = true
  else
    form.cbtn_fwz.Checked = false
  end
end
function on_cbtn_info_filter_checked_changed(cbtn)
  if not nx_is_valid(cbtn) then
    return
  end
  if nx_string(cbtn.DataSource) == nx_string("4") then
    local game_config_info = nx_value("game_config_info")
    if nx_is_valid(game_config_info) then
      util_set_property_key(game_config_info, "show_equip_buff", nx_int(cbtn.Checked and "1" or "0"))
    end
    local CustomizingManager = nx_value("customizing_manager")
    if nx_is_valid(CustomizingManager) then
      CustomizingManager:SaveConfigToServer()
    end
  end
  if cbtn.Checked == false then
    if nx_string(cbtn.DataSource) == nx_string("2") then
      nx_execute("form_stage_main\\form_main\\form_main_shortcut_onestep", "show_shortcut_equip", false)
    elseif nx_string(cbtn.DataSource) == nx_string("3") then
      local form_close = nx_value(table_func_form[nx_number(cbtn.DataSource)])
      if nx_is_valid(form_close) then
        form_close.Visible = false
      end
    else
      local form_close = nx_value(table_func_form[nx_number(cbtn.DataSource)])
      if nx_is_valid(form_close) then
        form_close.Visible = false
      end
    end
    return
  end
  if nx_string(cbtn.DataSource) == nx_string("1") then
    local in_new_world = is_newjhmodule()
    local is_open = nx_execute("form_stage_main\\form_card\\form_card_skill", "is_show_cardskill_form")
    if in_new_world or is_open == false then
      cbtn.Checked = false
    else
      nx_execute("form_stage_main\\form_card\\form_card_skill", "show_form_cardskill")
    end
  elseif nx_string(cbtn.DataSource) == nx_string("2") then
    local is_vip = check_vip_player()
    if nx_int(is_vip) == nx_int(1) then
      nx_execute("form_stage_main\\form_main\\form_main_shortcut_onestep", "show_shortcut_equip", true)
    end
  elseif nx_string(cbtn.DataSource) == nx_string("3") then
    if not check_lc_state() then
      cbtn.Checked = false
    else
      open_lc()
    end
  elseif nx_string(cbtn.DataSource) == nx_string("4") then
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local rows = client_player:GetRecordRows("EquipOtherBufferRec")
    if nx_int(rows) > nx_int(0) then
      util_show_form("form_stage_main\\form_main\\form_main_equip_buffer_list", true)
    else
      util_show_form("form_stage_main\\form_main\\form_main_equip_buffer_list", false)
    end
  end
  return
end
function check_lc_state()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local sable = client_player:QueryProp("Sable")
  if string.len(sable) == 0 or sable == 0 then
    return false
  end
  if not client_player:FindRecord("sable_rec") then
    return false
  end
  local row = client_player:QueryProp("SableCarryID")
  local row_max = client_player:GetRecordRows("sable_rec")
  if row < 0 or row >= row_max then
    return false
  end
  local item_config = client_player:QueryRecord("sable_rec", row, 3)
  local sable_state = client_player:QueryProp("SableState")
  if 0 < nx_number(sable_state) then
    return true
  end
  return false
end
function open_lc()
  local form_sable = nx_value("form_stage_main\\form_animalkeep\\form_sable_skill")
  if nx_is_valid(form_sable) then
    form_sable.Visible = true
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local sable = client_player:QueryProp("Sable")
  if string.len(sable) == 0 or sable == 0 then
    return false
  end
  if not client_player:FindRecord("sable_rec") then
    return false
  end
  local row = client_player:QueryProp("SableCarryID")
  local row_max = client_player:GetRecordRows("sable_rec")
  if row < 0 or row >= row_max then
    return false
  end
  local item_config = client_player:QueryRecord("sable_rec", row, 3)
  local sable_state = client_player:QueryProp("SableState")
  if 0 < nx_number(sable_state) then
    local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_animalkeep\\form_sable_skill", true)
    nx_execute("form_stage_main\\form_animalkeep\\form_sable_skill", "server_open_sable_skill", form, item_config)
  end
end
function on_btn_weizhi_click(cbtn)
  local ini = get_ini(POS_INI, true)
  if not nx_is_valid(ini) then
    return
  end
  for i = 1, table.getn(table_func_form) do
    local form = nx_value(table_func_form[i])
    if nx_is_valid(form) and form.Visible == true then
      local sec_index = ini:FindSectionIndex(nx_string(i))
      if 0 <= sec_index then
        local left = nx_number(ini:ReadString(sec_index, "left", "0"))
        local top = nx_number(ini:ReadString(sec_index, "top", "0"))
        if 0 < left and 0 < top then
          form.Left = left
          form.Top = top
        end
      end
    end
  end
end
function check_vip_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  return client_player:QueryProp("VipStatus")
end
function create_random_terrain_map(form, scene_name, map_name, width, height)
  if not nx_is_valid(form) then
    return false
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return false
  end
  local dynamic_clone_helper = nx_value("DynamicCloneHelper")
  if not nx_is_valid(dynamic_clone_helper) then
    return false
  end
  local texture_tool = form.texture_tool
  if not nx_is_valid(texture_tool) then
    return false
  end
  if map_name == "" then
    return false
  end
  local pic_width = map_query:GetDynPicWidth(scene_name)
  local pic_path = map_query:GetDynPicPath(scene_name)
  if pic_width == 0 or pic_path == "" then
    return false
  end
  local info = dynamic_clone_helper:GetDynamicCloneMapInfo()
  local list = util_split_string(info, ";")
  if table.getn(list) ~= 2 then
    return false
  end
  local list_info = util_split_string(list[1], ",")
  if table.getn(list_info) ~= 5 then
    return false
  end
  local row_count = nx_int(list_info[1])
  local col_count = nx_int(list_info[2])
  local zone_size = nx_int(list_info[3])
  local first_scene_x = nx_int(list_info[4])
  local first_scene_z = nx_int(list_info[5])
  local list_pic = util_split_string(list[2], ",")
  if table.getn(list_pic) ~= row_count * col_count then
    return false
  end
  local image_x, image_z = SceneCoordToImageCoord(width, height, first_scene_x, first_scene_z, form.roundbox_smallmap.TerrainStartX, form.roundbox_smallmap.TerrainStartZ, form.roundbox_smallmap.TerrainWidth, form.roundbox_smallmap.TerrainHeight)
  image_x = image_x - pic_width
  texture_tool:ClearCopyTextures()
  texture_tool:AddCopyTexture(pic_path .. map_name .. ".dds", 0, 0, width, height)
  for i = 0, row_count - 1 do
    local cur_row = image_z + i * pic_width
    for j = col_count - 1, 0, -1 do
      local pic_name = list_pic[row_count * i + col_count - j]
      if pic_name ~= "-1_-1" then
        local pic = pic_path .. pic_name .. ".dds"
        local cur_col = image_x - (col_count - 1 - j) * pic_width
        texture_tool:AddCopyTexture(pic, cur_row, cur_col, pic_width, pic_width)
      end
    end
  end
  local res = texture_tool:GenTexture("RandomTerrainMiniMap", width, height)
  form.roundbox_smallmap.Image = "RandomTerrainMiniMap"
  texture_tool:ReleaseGenTexture()
  return res
end
function SceneCoordToImageCoord(fImageWidth, fImageHeight, fSceneX, fSceneZ, fSceneStartX, fSceneStartZ, fSceneWidth, fSceneHeight)
  local fImageX = (1 - (fSceneX - fSceneStartX) / fSceneWidth) * fImageWidth
  local fImageZ = (fSceneZ - fSceneStartZ) / fSceneHeight * fImageHeight
  return fImageX, fImageZ
end
function on_btn_wujidao_war_click(btn)
  nx_execute("custom_sender", "custom_wjd_request", 2)
end
function on_switch_changed(type, is_open)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if type == ST_NORMAL_ACTIVITY_GUIDE then
    form.btn_activity_guide.Visible = is_open
  end
end
function on_btn_activity_guide_click(self)
end
function is_in_outlandwar()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_OUTLAND_WAR) == PIS_IN_GAME then
    return true
  end
  return false
end
function on_btn_sca_rank_click(btn)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return
  end
  if interactmgr:GetInteractStatus(ITT_SCHOOL_COUNTER_ATTACK) == PIS_IN_GAME then
    util_auto_show_hide_form("form_stage_main\\form_school_counterattack\\form_counter_attack_rank")
  end
end
function reset_balance_war_ctrl(form, propname, proptype, value)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(value) == nx_int(0) then
    form.btn_balance_war.Visible = false
  elseif nx_int(value) == nx_int(1) then
    form.btn_balance_war.Visible = true
  end
end
function reset_luandou_ctrl(form, propname, proptype, value)
  if not nx_is_valid(form) then
    return
  end
  form.btn_scuffle.Visible = nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "is_in_luandou_scene")
end
function reset_cross_btn(form, propname, proptype, value)
  if is_in_cross_station_war() then
    form.btn_cross_station_war.Visible = true
  else
    form.btn_cross_station_war.Visible = false
  end
  if is_in_league_matches() then
    form.btn_league_matches.Visible = true
  else
    form.btn_league_matches.Visible = false
  end
end
function reset_guild_balance_war(form, propname, proptype, value)
  if is_in_guild_war() then
    form.btn_guild_battle_war.Visible = true
  else
    form.btn_guild_battle_war.Visible = false
  end
end
function on_btn_guild_battle_war_click(btn)
  nx_execute("form_stage_main\\form_guild_battle\\form_guild_battle_score", "open_balance_info_form")
end
function on_btn_cross_station_war_click(btn)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_h", "open_or_hide")
end
function on_btn_league_matches_click(btn)
  nx_execute("form_stage_main\\form_league_matches\\form_lm_war_info", "open_or_hide")
end
function on_btn_balance_war_click(btn)
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance_info", "open_balance_info_form")
end
function on_btn_scuffle_click(btn)
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_score", "open_form")
end
function is_in_cross_station_war()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindProp("CrossType") then
    return false
  end
  local prop_value = client_player:QueryProp("CrossType")
  return nx_int(prop_value) == nx_int(28)
end
function is_in_league_matches()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindProp("CrossType") then
    return false
  end
  local prop_value = client_player:QueryProp("CrossType")
  return nx_int(prop_value) == nx_int(32)
end
function is_in_guild_war()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindProp("CW_TYPE") then
    return false
  end
  local prop_value = client_player:QueryProp("CW_TYPE")
  if nx_int(prop_value) > nx_int(0) then
    return true
  end
  return false
end
function is_in_balance_war()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindProp("BalanceWarIsInWar") then
    return false
  end
  local prop_value = client_player:QueryProp("BalanceWarIsInWar")
  if nx_int(prop_value) == nx_int(0) then
    return false
  else
    return true
  end
end
function reset_wudao_war_ctrl(form, propname, proptype, value)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(value) == nx_int(0) or nx_int(value) == nx_int(1) then
    form.btn_wudao.Visible = false
  else
    form.btn_wudao.Visible = true
  end
end
function on_btn_wudao_click(btn)
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_result", "open_wudao_wulin_result_form")
end
function reset_taosha_ctrl(form)
  if not nx_is_valid(form) then
    return
  end
  form.btn_taosha.Visible = false
end
function show_taosha_ctrl()
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  form.btn_taosha.Visible = true
end
function on_btn_taosha_click(btn)
  nx_execute("form_stage_main\\form_taosha\\form_taosha_notice", "close_form")
  nx_execute("form_stage_main\\form_taosha\\form_taosha_notice", "request_open_form")
  btn.Visible = false
end
function set_btn_jy_rank_visible(show)
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  form.btn_jy_rank.Visible = show
  if show == true then
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local is_attack_player = client_player:QueryProp("IsJYFaucltyAttacker")
    if 0 < is_attack_player then
      local harm_kill_nums = client_player:QueryProp("JiuYangFacultyHarmKillNums")
      balance_war_open_score_form(nx_int(harm_kill_nums))
    else
      local defend_kill_nums = client_player:QueryProp("JiuYangFacultyDefendKillNums")
      balance_war_open_score_form(nx_int(defend_kill_nums))
    end
  else
    local form_battlefield_score = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_battlefield\\form_battlefield_score", true)
    if not nx_is_valid(form_battlefield_score) then
      return
    end
    form_battlefield_score:Close()
  end
end
function on_btn_jy_rank_click(btn)
  nx_execute("custom_sender", "custom_jiuyang_faculty", nx_int(5))
end
function reset_jiuyang_ctrl(form, propname, proptype, value)
  local form_battlefield_score = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_battlefield\\form_battlefield_score", true)
  if not nx_is_valid(form_battlefield_score) then
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
  local kill_nums = client_player:QueryProp(propname)
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "refresh_balance_war_kill_score", form_battlefield_score, nx_int(kill_nums))
end
function balance_war_open_score_form(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_battlefield\\form_battlefield_score", true)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_battlefield\\form_battlefield_score", true)
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "hide_win")
  local kill_score = nx_number(arg[1])
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "refresh_balance_war_kill_score", form, nx_int(kill_score))
end
function close_form_battlefield_score()
  local form_battlefield_score = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_battlefield\\form_battlefield_score", true)
  if not nx_is_valid(form_battlefield_score) then
    return
  end
  if form_battlefield_score.Visible then
    form_battlefield_score:Close()
  end
end
function show_sjy_school_meet_ui(is_show)
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  local b_show = nx_int(is_show) == nx_int(0)
  if form.btn_sjy_school_meet.Visible ~= b_show then
    form.btn_sjy_school_meet.Visible = b_show
  end
end
function on_btn_sjy_school_meet_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_sjy_shimen_rank")
end
function show_xmg_school_meet_ui(is_show)
  local form = nx_value("form_stage_main\\form_main\\form_main_map")
  if not nx_is_valid(form) then
    return
  end
  local b_show = nx_int(is_show) == nx_int(0)
  if form.btn_xmg_school_meet.Visible ~= b_show then
    form.btn_xmg_school_meet.Visible = b_show
  end
end
function on_btn_xmg_school_meet_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_xmg_shimen_rank")
end
