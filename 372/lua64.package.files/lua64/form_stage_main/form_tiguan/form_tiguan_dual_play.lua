require("util_gui")
require("util_functions")
require("util_static_data")
require("custom_sender")
local FORM_TIGUAN_DUAL_PLAY = "form_stage_main\\form_tiguan\\form_tiguan_dual_play"
local FORM_DUAL_PLAY_RESULT = "form_stage_main\\form_tiguan\\form_tiguan_dual_play_result"
local FORM_DUAL_PLAY_INVITE = "form_stage_main\\form_tiguan\\form_tiguan_dual_play_invite"
local FORM_DUAL_PLAY_EXCHANGE = "form_stage_main\\form_tiguan\\form_tiguan_dual_play_exchange"
local FORM_TIGUAN_DUAL_PLAY_INTRODUCTION = "form_stage_main\\form_tiguan\\form_tiguan_dual_play_introduction"
local FORM_TIGUAN_DUALPLAY_LASTWEEK_RANK = "form_stage_main\\form_tiguan\\form_tiguan_dual_play_lastweek_rank"
local INI_TIGUAN_DUALPLAY_EXCHANGE = "share\\War\\tiguan_dual_player_exchange.ini"
local INI_TIGUAN_DUALPLAY_CONFIG = "share\\War\\tiguan_dual_player.ini"
local INI_TIGUAN = "share\\War\\tiguan.ini"
local INI_TIGUAN_CONDITION = "share\\War\\tiguan_success_condition.ini"
local INI_TIGUAN_SKILL = "ini\\ui\\tiguan\\tiguan_dual_player_skill.ini"
local SUBFORM_CHALLENGE = 1
local SUBFORM_RANKING = 2
local SUBFORM_REWARD = 3
local SUBFORM_EXCHANGE = 4
local SUBFORM_RECORD = 5
local SUBFORM_SKILL = 6
local MAX_CHALLENGE_STEP = 5
local RANK_NAME_TIGUAN_DUAL_PLAY = "rank_srltzbs_geren_001"
local SERVER_USE_CACHE = 1
local SERVER_CLEAR_CACHE = 2
local SERVER_NEW_DATA = 3
local SUB_CLIENT_CHECK = 1
local SUB_CLIENT_QUERY = 2
local COL_COUNT = 7
local HUXIAO_POINT_ONLY = 1
local GUPU_POINT_ONLY = 2
local CLIENT_CUSTOMMSG_TIGUAN_DUAL_PLAYER = 802
local CLIENT_MSG_DP_ADD_PARTNER = 0
local CLIENT_MSG_DP_REMOVE_PARTNER = 1
local CLIENT_MSG_DP_REQUEST_FIGHT = 2
local CLIENT_MSG_DP_REQUEST_FORM = 3
local CLIENT_MSG_DP_REQUEST_SCORE_MEMORIZE = 4
local CLIENT_MSG_DP_REQUEST_EXCHANGE = 5
local CLIENT_MSG_DP_REQUEST_EXCHANGE_LIMIT = 6
local CLIENT_MSG_DP_REQUEST_RESET = 7
local CLIENT_MSG_DP_REQUEST_LASTWEEK_RANK = 8
local SERVER_MSG_DP_TURN_CAL = 0
local SERVER_MSG_DP_FORM_INFO = 1
local SERVER_MSG_DP_SCORE_MEMORIZE = 2
local SERVER_MSG_DP_EXCHANGE_INFO = 3
local SERVER_MSG_DP_PROP_INFO = 4
local SERVER_MSG_DP_COMPLETE_BASE_CONDITION = 5
local SERVER_MSG_DP_OPEN_FORM = 6
local SERVER_MSG_DP_TIGUAN_TIME = 7
local SERVER_MSG_DP_END = 8
local SERVER_MSG_DP_LASTWEEK_RANK = 9
local TG_SHOW_DETAIL_CLOSE = 1
local TG_SHOW_DETAIL_DUALPLAYER_OPEN = 2
local NODE_PROP = {
  [1] = {
    NodeBackImage = "gui\\special\\smzb\\anniu_out.png",
    NodeFocusImage = "gui\\special\\smzb\\anniu_on.png",
    NodeSelectImage = "gui\\special\\smzb\\anniu_on.png",
    NodeCoverImage = "gui\\special\\tiguan\\chac.png",
    Font = "font_treeview",
    ForeColor = "255,197,184,159",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 1,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 6
  },
  [2] = {
    NodeBackImage = "gui\\common\\treeview\\tree_2_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeCoverImage = "gui\\special\\tiguan\\chac.png",
    Font = "font_treeview",
    ItemHeight = 22,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 3
  }
}
function open_form()
  local ST_FUNCTION_DUAL_PLAYER_TIGUAN = 859
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_DUAL_PLAYER_TIGUAN) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19919"), 2)
    end
    return
  end
  util_auto_show_hide_form(FORM_TIGUAN_DUAL_PLAY)
end
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.groupbox_template_reward.Visible = false
  form.gbox_template_skill.Visible = false
  form.groupbox_challenge.Visible = false
  form.groupbox_ranking.Visible = false
  form.groupbox_reward.Visible = false
  form.groupbox_exchange.Visible = false
  form.groupbox_record.Visible = false
  form.groupbox_skill.Visible = false
  form.lbl_select.Visible = false
  local Left = form.groupbox_challenge.Left
  local Top = form.groupbox_challenge.Top
  form.groupbox_ranking.Left = Left
  form.groupbox_ranking.Top = Top
  form.groupbox_reward.Left = Left
  form.groupbox_reward.Top = Top
  form.groupbox_exchange.Left = Left
  form.groupbox_exchange.Top = Top
  form.groupbox_record.Left = Left
  form.groupbox_record.Top = Top
  form.groupbox_skill.Left = Left
  form.groupbox_skill.Top = Top
  form.cur_subform = 0
  form.guan_count = -1
  form.guan_cur_progress = -1
  form.record_curpage = -1
  form.huxiao_point = 0
  form.gupu_point = 0
  form.record_text = nx_widestr("")
  form.partner_name = nx_widestr("")
  form.ini_config = get_tiguan_dualplay_ini(INI_TIGUAN_DUALPLAY_CONFIG)
  form.ini_exchange = get_tiguan_dualplay_ini(INI_TIGUAN_DUALPLAY_EXCHANGE)
  form.ini_tiguan = get_tiguan_dualplay_ini(INI_TIGUAN)
  form.ini_tiguan_condition = get_tiguan_dualplay_ini(INI_TIGUAN_CONDITION)
  form.ini_skill = get_tiguan_dualplay_ini(INI_TIGUAN_SKILL)
  local cache_list = nx_value("Cache_Tiguan_dualplay_Rank")
  if not nx_is_valid(cache_list) then
    form.cache_list = nx_call("util_gui", "get_global_arraylist", "Cache_Tiguan_dualplay_Rank")
    init_rank_cache(form.cache_list)
  else
    form.cache_list = cache_list
  end
  request_query(form)
  form.rbtn_challenge.Checked = true
end
function on_main_form_close(form)
  local subform = nx_value(FORM_DUAL_PLAY_EXCHANGE)
  if nx_is_valid(subform) then
    subform:Close()
  end
  subform = nx_value(FORM_DUAL_PLAY_INVITE)
  if nx_is_valid(subform) then
    subform:Close()
  end
  subform = nx_value(FORM_TIGUAN_DUAL_PLAY_INTRODUCTION)
  if nx_is_valid(subform) then
    subform:Close()
  end
  subform = nx_value(FORM_TIGUAN_DUALPLAY_LASTWEEK_RANK)
  if nx_is_valid(subform) then
    subform:Close()
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function reset_scene()
  local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_value(FORM_DUAL_PLAY_RESULT)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_playerlist_click(btn)
  local form = nx_value(FORM_DUAL_PLAY_INVITE)
  if nx_is_valid(form) then
    form:Close()
  else
    util_show_form(FORM_DUAL_PLAY_INVITE, true)
  end
end
function on_btn_adventure_click(btn)
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local res = condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(26016))
  if not nx_boolean(res) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_tiguan_dual_play_36"), 2)
    end
    return
  end
  nx_execute("form_stage_main\\form_tiguan\\form_tiguan_one", "open_form")
end
function on_btn_force_click(btn)
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local res = condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(26001))
  if not nx_boolean(res) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_tiguan_dual_play_36"), 2)
    end
    return
  end
  local form = nx_value("form_stage_main\\form_tvt\\form_tvt_tiguan")
  if nx_is_valid(form) then
    form:Close()
  else
    nx_execute("form_stage_main\\form_tvt\\form_tvt_tiguan", "open_form")
  end
end
function on_rbtn_title_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_find_custom(form, "cur_subform") then
    return
  end
  form.cur_subform = rbtn.TabIndex
  local subform = rbtn.TabIndex
  local b_show_immediately = true
  if subform == SUBFORM_CHALLENGE then
    nx_execute("custom_sender", "custom_tiguan_dual_play", CLIENT_MSG_DP_REQUEST_FORM)
    b_show_immediately = false
  elseif subform == SUBFORM_RANKING then
    refresh_rank(form)
  elseif subform == SUBFORM_EXCHANGE then
    refresh_subform_exchange()
  elseif subform == SUBFORM_REWARD then
    refresh_subform_reward()
  elseif subform == SUBFORM_RECORD then
    form.textgrid_record:BeginUpdate()
    form.textgrid_record:ClearRow()
    local RECORD_COL_COUNT = 5
    form.textgrid_record.ColCount = RECORD_COL_COUNT
    form.textgrid_record.HeaderBackColor = "0,255,255,255"
    form.textgrid_record:SetColTitle(0, util_text("ui_tiguan_dual_play_14"))
    form.textgrid_record:SetColTitle(1, util_text("ui_tiguan_dual_play_15"))
    form.textgrid_record:SetColTitle(2, util_text("ui_tiguan_dual_play_16"))
    form.textgrid_record:SetColTitle(3, util_text("ui_tiguan_dual_play_17"))
    form.textgrid_record:SetColTitle(4, util_text("ui_tiguan_dual_play_18"))
    form.textgrid_record:EndUpdate()
    form.lbl_page.Text = nx_widestr("(1/1)")
    nx_execute("custom_sender", "custom_tiguan_dual_play", CLIENT_MSG_DP_REQUEST_SCORE_MEMORIZE)
  else
    if subform == SUBFORM_SKILL then
      refresh_subform_skill()
    else
    end
  end
  form.groupbox_challenge.Visible = b_show_immediately and subform == SUBFORM_CHALLENGE
  form.groupbox_ranking.Visible = b_show_immediately and subform == SUBFORM_RANKING
  form.groupbox_reward.Visible = b_show_immediately and subform == SUBFORM_REWARD
  form.groupbox_exchange.Visible = b_show_immediately and subform == SUBFORM_EXCHANGE
  form.groupbox_record.Visible = b_show_immediately and subform == SUBFORM_RECORD
  form.groupbox_skill.Visible = b_show_immediately and subform == SUBFORM_SKILL
end
function on_refresh(submsg, ...)
  local subform = 0
  local sub_servermsg = nx_int(submsg)
  if sub_servermsg == nx_int(SERVER_MSG_DP_TURN_CAL) then
    nx_execute(FORM_DUAL_PLAY_RESULT, "on_open_final_result_form", unpack(arg))
    subform = -1
  elseif sub_servermsg == nx_int(SERVER_MSG_DP_FORM_INFO) then
    refresh_subform_challenge(unpack(arg))
    subform = SUBFORM_CHALLENGE
  elseif sub_servermsg == nx_int(SERVER_MSG_DP_SCORE_MEMORIZE) then
    refresh_subform_record(unpack(arg))
    subform = SUBFORM_RECORD
  elseif sub_servermsg == nx_int(SERVER_MSG_DP_EXCHANGE_INFO) then
    return
  elseif sub_servermsg == nx_int(SERVER_MSG_DP_PROP_INFO) then
    local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
    if nx_is_valid(form) then
      form.lbl_huxiao.Text = util_format_string("ui_tiguan_dual_play_01", nx_int(arg[1]))
      form.lbl_gupu.Text = util_format_string("ui_tiguan_dual_play_30", nx_int(arg[2]))
      save_point(form, arg[1], arg[2])
    end
    subform = 0
  elseif sub_servermsg == nx_int(SERVER_MSG_DP_COMPLETE_BASE_CONDITION) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local finish_cdts = nx_value("tiguan_finish_cdts")
      if not nx_is_valid(finish_cdts) then
        return
      end
      local child = finish_cdts:GetChild(nx_string(nx_number(arg[1]) + 1))
      if not nx_is_valid(child) then
        return
      end
      SystemCenterInfo:ShowSystemCenterInfo(util_format_string("ui_tiguan_dual_play_34", nx_int(arg[2])), 8)
    end
    subform = 0
  elseif sub_servermsg == nx_int(SERVER_MSG_DP_OPEN_FORM) then
    open_form()
    save_tiguan_step_to_file(false)
    subform = 0
  elseif sub_servermsg == nx_int(SERVER_MSG_DP_TIGUAN_TIME) then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_dual_play_usedtime", "refresh_time", unpack(arg))
    subform = 0
  elseif sub_servermsg == nx_int(SERVER_MSG_DP_END) then
    nx_execute("form_stage_main\\form_tiguan\\form_tiguan_dual_play_usedtime", "close_form")
    subform = 0
  else
    if sub_servermsg == nx_int(SERVER_MSG_DP_LASTWEEK_RANK) then
      nx_execute(FORM_TIGUAN_DUALPLAY_LASTWEEK_RANK, "open_form", nx_widestr(arg[1]))
      return
    else
    end
  end
  local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
  if nx_is_valid(form) and form.Visible and nx_int(subform) > nx_int(0) then
    form.groupbox_challenge.Visible = subform == SUBFORM_CHALLENGE
    form.groupbox_ranking.Visible = subform == SUBFORM_RANKING
    form.groupbox_reward.Visible = subform == SUBFORM_REWARD
    form.groupbox_exchange.Visible = subform == SUBFORM_EXCHANGE
    form.groupbox_record.Visible = subform == SUBFORM_RECORD
    form.groupbox_skill.Visible = subform == SUBFORM_SKILL
  end
  if nx_int(subform) < nx_int(0) then
    local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
    if nx_is_valid(form) then
      form:Close()
    end
  end
end
function refresh_subform_challenge(...)
  local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
  if not nx_is_valid(form) then
    return
  end
  local arg_huxiao_point = arg[1]
  local arg_gupu_point = arg[2]
  local arg_curweek_higest = arg[3]
  local arg_lastweek = arg[4]
  local arg_curweek_times = arg[5]
  local arg_lastweek_higest = arg[6]
  local arg_final_score = arg[7]
  local arg_remaining_time = arg[8]
  local arg_partner_type = arg[9]
  local arg_partner_name = arg[10]
  local arg_guan_count = arg[11]
  local arg_guan_cur_progress = arg[12]
  local arg_progress_list_start = 13
  save_point(form, arg_huxiao_point, arg_gupu_point)
  form.lbl_huxiao.Text = util_format_string("ui_tiguan_dual_play_01", nx_int(arg_huxiao_point))
  form.lbl_gupu.Text = util_format_string("ui_tiguan_dual_play_30", nx_int(arg_gupu_point))
  form.lbl_curweek_higest.Text = util_format_string("ui_tiguan_dual_play_02", nx_int(arg_curweek_higest))
  form.lbl_lastweek.Text = util_format_string("ui_tiguan_dual_play_03", nx_int(arg_lastweek))
  form.lbl_curweek_times.Text = util_format_string("ui_tiguan_dual_play_04", nx_int(arg_curweek_times))
  form.lbl_lastweek_higest.Text = util_format_string("ui_tiguan_dual_play_05", nx_int(arg_lastweek_higest))
  form.mltbox_final_score.HtmlText = util_format_string("ui_tiguan_dual_play_06", nx_int(arg_final_score))
  form.mltbox_remaining_time.HtmlText = util_format_string("ui_tiguan_dual_play_07", get_format_time_string(arg_remaining_time, true))
  form.partner_name_type = nx_int(arg_partner_type)
  form.lbl_playername.Text = util_format_string("ui_tiguan_dual_play_08", nx_widestr(arg_partner_name))
  form.partner_name = nx_widestr(arg_partner_name)
  form.guan_count = arg_guan_count
  if nx_int(arg_guan_count) == nx_int(3) then
    form.lbl_guan_lock4.Visible = true
    form.lbl_guan_lock5.Visible = true
  elseif nx_int(arg_guan_count) == nx_int(5) then
    form.lbl_guan_lock4.Visible = false
    form.lbl_guan_lock5.Visible = false
  end
  form.guan_cur_progress = arg_guan_cur_progress
  local info_index = arg_progress_list_start
  local tiguan_step = 0
  local guan_name, boss_name, used_time, single_score, sec_index
  for i = 1, MAX_CHALLENGE_STEP do
    guan_name = get_guan_name(arg[info_index])
    boss_name = get_boss_name(arg[info_index], arg[info_index + 1])
    used_time = nx_int(arg[info_index + 2])
    single_score = nx_int(arg[info_index + 3])
    if nx_ws_equal(nx_widestr(guan_name), nx_widestr("")) or nx_ws_equal(nx_widestr(boss_name), nx_widestr("")) then
      break
    end
    reload_gbox_info(form, i, guan_name, boss_name, used_time, single_score, nx_int(arg[info_index]))
    tiguan_step = i
    info_index = info_index + 4
  end
  refresh_challenge_step(form, form.guan_cur_progress)
end
function reload_gbox_info(form, gbox_index, guan_name, boss_name, used_time, single_score, guan_id_index)
  if not nx_is_valid(form) or gbox_index == nil or guan_name == nil or boss_name == nil or used_time == nil or single_score == nil then
    return
  end
  if gbox_index < 0 or gbox_index > MAX_CHALLENGE_STEP then
    return
  end
  local btn = nx_custom(form, "btn_step" .. nx_string(gbox_index))
  if nx_is_valid(btn) then
    btn.guan_name = nx_widestr(guan_name)
    btn.boss_name = nx_widestr(boss_name)
    btn.used_time = nx_widestr(used_time)
    btn.single_score = nx_widestr(single_score)
    btn.TempHintText = nx_widestr(get_guan_hinttext(guan_id_index))
  end
end
function refresh_challenge_step(form, tiguanstep)
  if not nx_is_valid(form) then
    return
  end
  local tiguan_step = nx_number(tiguanstep)
  if tiguan_step < 0 or tiguan_step > MAX_CHALLENGE_STEP then
    return
  end
  local lbl_mask, lbl_mask2, btn, lbl, mltbox = nx_null(), nx_null(), nx_null(), nx_null(), nx_null()
  for i = 1, MAX_CHALLENGE_STEP do
    lbl_mask = nx_custom(form, "lbl_mask_step" .. nx_string(i))
    lbl_mask2 = nx_custom(form, "lbl_sz_step" .. nx_string(i))
    btn = nx_custom(form, "btn_step" .. nx_string(i))
    lbl = nx_custom(form, "lbl_step" .. nx_string(i))
    mltbox_boss = nx_custom(form, "mltbox_boss" .. nx_string(i))
    mltbox_usedtime = nx_custom(form, "mltbox_time" .. nx_string(i))
    mltbox_score = nx_custom(form, "mltbox_fenshu" .. nx_string(i))
    if not (nx_is_valid(lbl_mask) and nx_is_valid(btn) and nx_is_valid(lbl) and nx_is_valid(lbl_mask2) and nx_is_valid(mltbox_boss) and nx_is_valid(mltbox_usedtime)) or not nx_is_valid(mltbox_score) then
      return
    end
    if tiguan_step == 0 then
      lbl_mask.Visible = true
      btn.Enabled = i == 1
      set_selected_step(1)
    else
      lbl_mask.Visible = i > tiguan_step
      btn.Enabled = i == tiguan_step + 1
      set_selected_step(tiguan_step + 1)
    end
    lbl_mask2.Visible = lbl_mask.Visible
    if nx_find_custom(btn, "guan_name") and nx_find_custom(btn, "boss_name") and nx_find_custom(btn, "used_time") and nx_find_custom(btn, "single_score") then
      lbl.Text = nx_widestr(btn.guan_name)
      mltbox_boss.HtmlText = util_format_string("ui_tiguan_dual_play_25", nx_widestr(btn.boss_name))
      mltbox_usedtime.HtmlText = util_format_string("ui_tiguan_dual_play_26", get_format_time_string(btn.used_time, true))
      mltbox_score.HtmlText = util_format_string("ui_tiguan_dual_play_27", nx_widestr(btn.single_score))
    end
  end
  if get_tiguan_step_from_file() then
    local cur_btn = nx_custom(form, "btn_step" .. nx_string(tiguan_step + 1))
    if nx_is_valid(cur_btn) then
      on_btn_step_click(cur_btn)
    end
  end
  refresh_guan_introduction(form)
end
function refresh_guan_introduction(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, MAX_CHALLENGE_STEP do
    local lbl_mask = nx_custom(form, "lbl_mask_step" .. nx_string(i))
    local btn = nx_custom(form, "btn_step" .. nx_string(i))
    if nx_is_valid(lbl_mask) and nx_is_valid(btn) then
      if nx_boolean(lbl_mask.Visible) then
        btn.HintText = nil
      else
        btn.HintText = nx_widestr(btn.TempHintText)
      end
    end
  end
end
function on_btn_step_click(btn)
  local form = btn.ParentForm
  local index = nx_int(btn.TabIndex)
  local lbl_lock = nx_custom(form, "lbl_guan_lock" .. nx_string(index))
  if nx_is_valid(lbl_lock) and nx_boolean(lbl_lock.Visible) then
    return
  end
  local lbl_mask = nx_custom(form, "lbl_mask_step" .. nx_string(index))
  if not nx_is_valid(lbl_mask) or not nx_boolean(lbl_mask.Visible) then
    return
  end
  if nx_find_custom(btn, "used_time") and nx_find_custom(btn, "single_score") then
    local tmp_int = nx_int(btn.used_time)
    if tmp_int < nx_int(0) then
      local mltbox_usedtime = nx_custom(form, "mltbox_time" .. nx_string(index))
      if nx_is_valid(mltbox_usedtime) then
        mltbox_usedtime.Visible = false
      end
    end
    tmp_int = nx_int(btn.single_score)
    if tmp_int < nx_int(0) then
      local mltbox_score = nx_custom(form, "mltbox_fenshu" .. nx_string(index))
      if nx_is_valid(mltbox_score) then
        mltbox_score.Visible = false
      end
    end
  else
    return
  end
  lbl_mask.Visible = false
  form.lbl_select.Visible = false
  local lbl_mask2 = nx_custom(form, "lbl_sz_step" .. nx_string(index))
  if nx_is_valid(lbl_mask2) then
    lbl_mask2.Visible = false
  end
  save_tiguan_step_to_file(true)
  refresh_guan_introduction(form)
end
function set_selected_step(step_index)
  local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
  if not nx_is_valid(form) then
    return
  end
  local gbox = nx_custom(form, "groupbox_step" .. nx_string(step_index))
  if nx_is_valid(gbox) then
    form.lbl_select.Left = gbox.Left
    form.lbl_select.Top = gbox.Top
    form.lbl_select.Visible = true
  else
    form.lbl_select.Visible = false
  end
  local lbl_lock = nx_custom(form, "lbl_guan_lock" .. nx_string(step_index))
  if nx_is_valid(lbl_lock) and nx_boolean(lbl_lock.Visible) then
    form.lbl_select.Visible = false
  end
end
function on_btn_reset_click(btn)
  local res = confirm_reset_current_progress()
  if nx_boolean(res) then
    nx_execute("custom_sender", "custom_tiguan_dual_play", CLIENT_MSG_DP_REQUEST_RESET)
  end
  save_tiguan_step_to_file(false)
end
function on_btn_confirm_click(btn)
  nx_execute("custom_sender", "custom_tiguan_dual_play", CLIENT_MSG_DP_REQUEST_FIGHT)
end
function confirm_reset_current_progress()
  local dialog = util_get_form("form_common\\form_confirm", true, false, "dualplay_reset")
  if nx_is_valid(dialog) then
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_tiguan_dual_play_24"))
    dialog:ShowModal()
    local rv = nx_wait_event(100000000, dialog, "confirm_return")
    if "ok" == rv then
      return true
    end
  end
end
function on_btn_introduction_click(btn)
  local form_introduction = nx_value(FORM_TIGUAN_DUAL_PLAY_INTRODUCTION)
  if nx_is_valid(form_introduction) then
    form_introduction:Close()
    return
  end
  util_show_form(FORM_TIGUAN_DUAL_PLAY_INTRODUCTION, true)
end
function on_btn_last_week_rank_click(btn)
  nx_execute("custom_sender", "custom_tiguan_dual_play", CLIENT_MSG_DP_REQUEST_LASTWEEK_RANK)
end
function on_rank_data_changed(...)
  if table.getn(arg) < 2 then
    return
  end
  local sub_cmd = arg[1]
  local rank_name = arg[2]
  if rank_name == nil or nx_string(rank_name) == nx_string("") then
    return
  end
  local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_CLEAR_CACHE) then
    on_clear_cache(form, rank_name)
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_USE_CACHE) then
    on_use_cache(form, rank_name)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(500, 1, nx_current(), "on_time_refresh", form, -1, -1)
    end
    return
  end
  if nx_int(sub_cmd) == nx_int(SERVER_NEW_DATA) then
    local rank_rows = arg[3]
    local publish_time = arg[4]
    local rank_string = arg[5]
    on_set_cache(form, rank_name, rank_rows, publish_time, rank_string)
    on_use_cache(form, rank_name)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(500, 1, nx_current(), "on_time_refresh", form, -1, -1)
    end
    return
  end
end
function init_rank_cache(cache_list)
  if not nx_is_valid(cache_list) then
    return
  end
  cache_list:ClearChild()
  local ini = get_ini("share\\Rule\\rank_prop.ini")
  if not nx_is_valid(ini) then
    return
  end
  local child = cache_list:CreateChild(RANK_NAME_TIGUAN_DUAL_PLAY)
  if nx_is_valid(child) then
    child.total_rows = 0
    child.publish_time = -1
    child.rank_string = "null"
  end
end
function get_cache(form, rank_name)
  if not nx_is_valid(form) then
    return
  end
  local cache = form.cache_list
  if not nx_is_valid(cache) then
    return
  end
  local obj = cache:GetChild(nx_string(rank_name))
  if not nx_is_valid(obj) then
    return
  end
  return obj
end
function on_clear_cache(form, rank_name)
  if not nx_is_valid(form) then
    return
  end
  local rank_obj = get_cache(form, rank_name)
  if nx_is_valid(rank_obj) then
    rank_obj.total_rows = 0
    rank_obj.publish_time = -1
    rank_obj.rank_string = "null"
  end
end
function on_use_cache(form, rank_name)
  if not nx_is_valid(form) then
    return
  end
  local rank_obj = get_cache(form, rank_name)
  if nx_is_valid(rank_obj) then
    form.rank_name = rank_name
    form.rank_rows = rank_obj.total_rows
    form.rank_string = rank_obj.rank_string
  end
end
function on_set_cache(form, rank_name, rank_rows, publish_time, rank_string)
  if not nx_is_valid(form) then
    return
  end
  local rank_obj = get_cache(form, rank_name)
  if nx_is_valid(rank_obj) then
    rank_obj.total_rows = rank_rows
    rank_obj.publish_time = publish_time
    rank_obj.rank_string = rank_string
  end
end
function on_time_refresh(form)
  if not nx_is_valid(form) then
    return
  end
  refresh_rank(form)
end
function request_query(form)
  if not nx_is_valid(form) then
    return
  end
  local rank_name = RANK_NAME_TIGUAN_DUAL_PLAY
  local rank_obj = get_cache(form, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
  if rank_obj.rank_string ~= "null" then
    send_query_rank(SUB_CLIENT_CHECK, rank_name, rank_obj.publish_time)
  else
    send_query_rank(SUB_CLIENT_QUERY, rank_name, 0)
  end
end
function send_query_rank(sub_cmd, rank_name, publish_time)
  if sub_cmd == nil or rank_name == nil then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_RANK), nx_int(sub_cmd), nx_string(rank_name), nx_int(publish_time))
end
function refresh_rank(form)
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local key_name = client_player:QueryProp("Name")
  local rank_name = RANK_NAME_TIGUAN_DUAL_PLAY
  local rank_string
  local rank_obj = get_cache(form, rank_name)
  if not nx_is_valid(rank_obj) then
    return
  end
  rank_string = rank_obj.rank_string
  if nx_ws_equal(nx_widestr(rank_string), nx_widestr("null")) or rank_string == nil then
    return
  end
  local rank_gird = form.textgrid_ranking
  if not nx_is_valid(rank_gird) then
    return
  end
  rank_gird:BeginUpdate()
  rank_gird:ClearRow()
  rank_gird.ColCount = COL_COUNT
  rank_gird.ColWidths = nx_string(get_rank_prop(rank_name, "ColWide"))
  rank_gird.HeaderBackColor = "0,255,255,255"
  local col_list = nx_function("ext_split_string", get_rank_prop(rank_name, "ColName"), ",")
  if table.getn(col_list) == COL_COUNT then
    for i = 1, COL_COUNT do
      local head_name = util_text(col_list[i])
      rank_gird:SetColTitle(i - 1, nx_widestr(head_name))
    end
  end
  local rank_type = get_rank_prop(rank_name, "Type")
  local main_type = get_rank_prop(rank_name, "MainType")
  local string_table = util_split_wstring(nx_widestr(rank_string), ",")
  form.self_row = -1
  local begin_index = 1
  for row = 0, 99 do
    if begin_index + COL_COUNT > table.getn(string_table) then
      break
    end
    rank_gird:InsertRow(-1)
    for index = 0, COL_COUNT - 1 do
      rank_gird:SetGridText(row, index, nx_widestr(string_table[begin_index]))
      if index == 1 then
        local last_test, last_color = get_last_no(rank_gird:GetGridText(row, 0), rank_gird:GetGridText(row, 1))
        rank_gird:SetGridText(row, 1, nx_widestr(last_test))
        rank_gird:SetGridForeColor(row, 1, last_color)
      end
      if index == 5 then
        rank_gird:SetGridText(row, index, util_text(nx_string(string_table[begin_index])))
      end
      begin_index = begin_index + 1
    end
    local temp_name = rank_gird:GetGridText(row, 2)
    if nx_ws_equal(nx_widestr(key_name), nx_widestr(temp_name)) then
      form.self_row = row
    end
  end
  if nx_int(form.self_row) >= nx_int(0) then
    for index = 0, COL_COUNT - 1 do
      rank_gird:SetGridForeColor(form.self_row, index, "255,255,0,0")
    end
  end
  rank_gird:EndUpdate()
end
function on_btn_find_yourself_click(btn)
  local form = btn.ParentForm
  if not (nx_is_valid(form) and nx_find_custom(form, "self_row")) or form.self_row < 0 then
    return
  end
  form.textgrid_ranking:SelectRow(form.self_row)
end
function refresh_subform_reward(...)
  local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
  if not nx_is_valid(form) then
    return false
  end
  for i = 1, 3 do
    for j = 1, 3 do
      local grid = nx_custom(form, "imagegrid_reward_" .. nx_string(i) .. nx_string(j))
      local item_id = nx_string(grid.DataSource)
      if nx_is_valid(grid) and item_id ~= "" then
        grid:Clear()
        local photo = item_query_ArtPack_by_id(item_id, "Photo")
        grid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
        grid:CoverItem(0, true)
      end
    end
  end
end
function refresh_subform_exchange()
  local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
  if not nx_is_valid(form) then
    return
  end
  inner_refresh_exchange_item_list()
end
function inner_refresh_exchange_item_list()
  local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
  if not nx_is_valid(form) then
    return
  end
  local ini_exchange = get_tiguan_dualplay_ini(INI_TIGUAN_DUALPLAY_EXCHANGE)
  if not nx_is_valid(ini_exchange) then
    return
  end
  local sec_index = ini_exchange:FindSectionIndex("0")
  local node_list, node_count, subnode_list, subnode_count, node_name, tmp_list, tmp_count, tmp_node, tmp_subnode
  local root_exchange = form.tree_exchange:CreateRootNode(nx_widestr("root"))
  local key_node_list = ini_exchange:GetItemValueList(sec_index, "r")
  local first_node
  form.tree_exchange:BeginUpdate()
  for m = 1, table.getn(key_node_list) do
    sec_index = ini_exchange:FindSectionIndex(nx_string(key_node_list[m]))
    node_list = ini_exchange:GetItemValueList(sec_index, "Node")
    node_count = table.getn(node_list)
    if node_count <= 0 then
      return
    end
    node_name = util_text(node_list[1])
    tmp_node = root_exchange:CreateNode(node_name)
    if m == 1 then
      first_node = tmp_node
    end
    set_node_prop(tmp_node, 1)
    tmp_node.node_type = nx_string(m) .. "_" .. nx_string(1)
    subnode_list = ini_exchange:GetItemValueList(sec_index, "SubNode")
    subnode_count = table.getn(subnode_list)
    for i = 1, subnode_count do
      tmp_list = util_split_string(nx_string(subnode_list[i]), ",")
      tmp_count = table.getn(tmp_list)
      if 2 <= tmp_count then
        node_name = util_text(tmp_list[1])
        if not nx_ws_equal(node_name, nx_widestr("")) then
          tmp_subnode = tmp_node:CreateNode(node_name)
          if i == 1 then
            first_node = tmp_subnode
          end
          set_node_prop(tmp_subnode, 2)
          tmp_subnode.node_type = nx_string(m) .. "_" .. nx_string(i)
        end
      end
    end
  end
  root_exchange.Expand = true
  root_exchange:ExpandAll()
  form.tree_exchange.IsNoDrawRoot = true
  form.tree_exchange:EndUpdate()
  if nx_is_valid(first_node) then
    form.tree_exchange.SelectNode = first_node
  end
end
function on_tree_exchange_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(cur_node, "node_type") then
    show_exchange_info(form, cur_node.node_type)
  end
end
function show_exchange_info(form, node_type)
  if not nx_is_valid(form) then
    return
  end
  local tmp_list = util_split_string(nx_string(node_type), "_")
  if table.getn(tmp_list) ~= 2 then
    return
  end
  local find_index_node = nx_number(tmp_list[1])
  local find_index_subnode = nx_number(tmp_list[2])
  local ini_exchange = get_tiguan_dualplay_ini(INI_TIGUAN_DUALPLAY_EXCHANGE)
  if not nx_is_valid(ini_exchange) then
    return
  end
  local sec_index = ini_exchange:FindSectionIndex(nx_string(find_index_node))
  if sec_index < 0 then
    return
  end
  local subnode_list = ini_exchange:GetItemValueList(sec_index, "SubNode")
  local subnode_count = table.getn(subnode_list)
  if subnode_count <= 0 or find_index_subnode > subnode_count then
    return
  end
  local subnode_string = util_split_string(nx_string(subnode_list[find_index_subnode]), ",")
  local subnode_string_count = table.getn(subnode_string)
  local div, mod
  if 4 < subnode_string_count then
    div = nx_int((subnode_string_count - 1) / 4)
    mod = math.mod(subnode_string_count - 1, 4)
    if mod ~= 0 then
      div = div + 1
    end
  else
    div = 1
  end
  form.groupscrollbox_reward_items.IsEditMode = true
  form.groupscrollbox_reward_items:DeleteAll()
  local t_gbox, t_btn, t_imagegrid, t_mltbox_name, t_mltbox_exchange, t_mltbox_desc, t_mltbox_condition, gbox_parent, gbox, btn, imagegrid, mltbox_name, mltbox_exchange, mltbox_desc, mltbox_condition, tmp_text, photo
  local begin_index = 2
  for i = 1, nx_number(div) do
    gbox_parent = clone_control("GroupBox", "gbox_exchange_parent_" .. nx_string(i), form.groupbox_template_reward, form.groupscrollbox_reward_items)
    if nx_is_valid(gbox_parent) then
      gbox_parent.Left = 0
      gbox_parent.Visible = true
      for j = 1, 4 do
        t_gbox = nx_custom(form, "groupbox_template_eh" .. nx_string(j))
        gbox = clone_control("GroupBox", "gbox_exchange_" .. nx_string(i) .. nx_string(j), t_gbox, gbox_parent)
        if nx_is_valid(gbox) then
          sec_index = ini_exchange:FindSectionIndex(nx_string(subnode_string[begin_index]))
          if 0 <= sec_index then
            gbox.Visible = true
            t_btn = nx_custom(form, "btn_tmp_back" .. nx_string(j))
            btn = clone_control("Button", "btn_exchange_" .. nx_string(i) .. nx_string(j), t_btn, gbox)
            if nx_is_valid(btn) then
              tmp_text = ini_exchange:ReadString(sec_index, "ConditionID", "")
              if nx_string(tmp_text) == "" then
                tmp_text = 0
              end
              btn.condition_id = nx_int(tmp_text)
              btn.Visible = true
              btn.DataSource = subnode_list[begin_index]
              nx_bind_script(btn, nx_current())
              nx_callback(btn, "on_click", "on_btn_exchange_click")
            end
            t_imagegrid = nx_custom(form, "imagegrid_eh" .. nx_string(j))
            imagegrid = clone_control("ImageGrid", "imagegrid_exchange_" .. nx_string(i) .. nx_string(j), t_imagegrid, gbox)
            if nx_is_valid(imagegrid) then
              imagegrid.Visible = true
              imagegrid.TestTrans = false
              imagegrid.Transparent = false
              tmp_text = ini_exchange:ReadString(sec_index, "ItemID", "")
              if nx_is_valid(btn) then
                btn.item_id = tmp_text
              end
              imagegrid:Clear()
              photo = item_query_ArtPack_by_id(tmp_text, "Photo")
              imagegrid.DataSource = tmp_text
              imagegrid:AddItem(0, photo, nx_widestr(tmp_text), 1, -1)
              imagegrid:CoverItem(0, true)
              nx_bind_script(imagegrid, nx_current())
              nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_item_mousein_grid")
              nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_item_mouseout_grid")
            end
            t_mltbox_name = nx_custom(form, "mltbox_tmp_name" .. nx_string(j))
            mltbox_name = clone_control("MultiTextBox", "mltbox_exchange_name_" .. nx_string(i) .. nx_string(j), t_mltbox_name, gbox)
            if nx_is_valid(mltbox_name) then
              mltbox_name.Visible = true
              mltbox_name.TestTrans = true
              mltbox_name.Transparent = true
              if nx_is_valid(btn) then
                mltbox_name.HtmlText = util_text(nx_string(btn.item_id))
              end
            end
            t_mltbox_desc = nx_custom(form, "mltbox_tmp_desc" .. nx_string(j))
            mltbox_desc = clone_control("MultiTextBox", "mltbox_exchange_desc_" .. nx_string(i) .. nx_string(j), t_mltbox_desc, gbox)
            if nx_is_valid(mltbox_desc) then
              mltbox_desc.Visible = true
              mltbox_desc.TestTrans = true
              mltbox_desc.Transparent = true
              tmp_text = ini_exchange:ReadString(sec_index, "NeedHuxiaoPoint", "")
              local point_count = nx_int(tmp_text)
              if point_count > nx_int(0) then
                mltbox_desc.HtmlText = util_format_string("ui_tiguan_dual_play_28", point_count)
                if nx_is_valid(btn) then
                  btn.limit_point_type = nx_int(HUXIAO_POINT_ONLY)
                end
              else
                tmp_text = ini_exchange:ReadString(sec_index, "NeedGupuPoint", "")
                point_count = nx_int(tmp_text)
                if point_count > nx_int(0) then
                  mltbox_desc.HtmlText = util_format_string("ui_tiguan_dual_play_29", point_count)
                  if nx_is_valid(btn) then
                    btn.limit_point_type = nx_int(GUPU_POINT_ONLY)
                  end
                end
              end
              if nx_is_valid(btn) then
                btn.limit_info = mltbox_desc.HtmlText
                btn.limit_point_count = nx_int(point_count)
              end
            end
            t_mltbox_exchange = nx_custom(form, "mltbox_tmp_exchange" .. nx_string(j))
            mltbox_exchange = clone_control("MultiTextBox", "mltbox_exchange_info_" .. nx_string(i) .. nx_string(j), t_mltbox_exchange, gbox)
            if nx_is_valid(mltbox_exchange) then
              mltbox_exchange.Visible = true
              mltbox_exchange.TestTrans = true
              mltbox_exchange.Transparent = true
              mltbox_exchange.exchange_type = 0
              mltbox_exchange.exchange_count = 0
              tmp_text = ini_exchange:ReadString(sec_index, "ExchangeType", "")
              mltbox_exchange.exchange_type = tmp_text
              if nx_int(tmp_text) <= nx_int(0) then
                mltbox_exchange.HtmlText = util_text("ui_tiguan_dual_play_11")
              elseif nx_int(tmp_text) == nx_int(1) then
                tmp_text = ini_exchange:ReadString(sec_index, "ExchangeCount", "")
                mltbox_exchange.HtmlText = util_format_string("ui_tiguan_dual_play_12", nx_int(tmp_text))
                mltbox_exchange.exchange_count = tmp_text
              elseif nx_int(tmp_text) == nx_int(2) then
                tmp_text = ini_exchange:ReadString(sec_index, "ExchangeCount", "")
                mltbox_exchange.HtmlText = util_format_string("ui_tiguan_dual_play_13", nx_int(tmp_text))
                mltbox_exchange.exchange_count = tmp_text
              end
            end
            t_mltbox_condition = nx_custom(form, "mltbox_condicon" .. nx_string(j))
            mltbox_condition = clone_control("MultiTextBox", "mltbox_condiconinfo" .. nx_string(i) .. nx_string(j), t_mltbox_condition, gbox)
            if nx_is_valid(mltbox_condition) then
              tmp_text = ini_exchange:ReadString(sec_index, "ConditionID", "")
              mltbox_condition.HtmlText = util_text("tiguan_dual_exchange_condition_" .. nx_string(tmp_text))
            end
          else
            gbox.Visible = false
          end
          begin_index = begin_index + 1
        end
      end
    end
  end
  form.groupscrollbox_reward_items.IsEditMode = false
  form.groupscrollbox_reward_items:ResetChildrenYPos()
end
function on_btn_exchange_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "huxiao_point") or not nx_find_custom(form, "gupu_point") then
    return
  end
  local huxiao_point = nx_int(form.huxiao_point)
  local gupu_point = nx_int(form.gupu_point)
  if huxiao_point < nx_int(0) or gupu_point < nx_int(0) then
    return
  end
  local single_point = nx_int(0)
  local need_point = nx_int(btn.limit_point_count)
  local need_type = nx_int(btn.limit_point_type)
  if need_type == nx_int(HUXIAO_POINT_ONLY) then
    single_point = huxiao_point
  elseif need_type == nx_int(GUPU_POINT_ONLY) then
    single_point = gupu_point
  end
  nx_execute(FORM_DUAL_PLAY_EXCHANGE, "show_exchange_item_subform", btn.item_id, btn.limit_info, single_point, need_point, btn.condition_id)
end
function on_imagegrid_item_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local item_id = grid.DataSource
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", item_id, x, y, form)
end
function on_imagegrid_item_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function refresh_subform_record(...)
  local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
  if not nx_is_valid(form) then
    return false
  end
  local text = nx_widestr("")
  local mod, tmp_str
  for i = 1, table.getn(arg) do
    mod = math.mod(i, 5)
    if mod == 1 then
      tmp_str = get_guan_name(arg[i])
      text = text .. tmp_str
    else
      text = text .. nx_widestr(arg[i])
    end
    if i + 1 <= table.getn(arg) then
      text = text .. nx_widestr(",")
    end
  end
  if nx_ws_equal(nx_widestr(text), nx_widestr("")) then
    return
  end
  form.record_text = text
  show_record_info(form, 1)
end
function show_record_info(form, page)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "record_text") then
    return
  end
  local info_text = nx_widestr(form.record_text)
  local string_table = util_split_wstring(nx_widestr(info_text), ",")
  local record_count = table.getn(string_table)
  local page_count = nx_int(record_count / 50)
  local mod = math.mod(record_count, 50)
  if nx_int(mod) ~= nx_int(0) then
    page_count = page_count + nx_int(1)
  end
  local begin_index = (page - 1) * 50 + 1
  if page <= 0 or record_count < begin_index then
    return
  end
  local record_grid = form.textgrid_record
  if not nx_is_valid(record_grid) then
    return
  end
  record_grid:BeginUpdate()
  record_grid:ClearRow()
  local RECORD_COL_COUNT = 5
  for row = 0, 9 do
    record_grid:InsertRow(-1)
    for index = 0, RECORD_COL_COUNT - 1 do
      if record_count >= begin_index then
        record_grid:SetGridText(row, index, nx_widestr(string_table[nx_number(begin_index)]))
        begin_index = begin_index + 1
      end
    end
  end
  record_grid:EndUpdate()
  form.record_curpage = page
  form.lbl_page.Text = nx_widestr("(") .. nx_widestr(nx_int(page)) .. nx_widestr("/") .. nx_widestr(nx_int(page_count)) .. nx_widestr(")")
end
function on_btn_page_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "record_curpage") then
    return
  end
  cur_page = form.record_curpage
  local direction = btn.TabIndex
  if direction == 1 then
    show_record_info(form, cur_page - 1)
  elseif direction == 2 then
    show_record_info(form, cur_page + 1)
  end
end
function refresh_subform_skill()
  local form = nx_value(FORM_TIGUAN_DUAL_PLAY)
  if not nx_is_valid(form) then
    return
  end
  local ini_skill = get_tiguan_dualplay_ini(INI_TIGUAN_SKILL)
  if not nx_is_valid(ini_skill) then
    return
  end
  local index = ini_skill:FindSectionIndex("skill")
  if index < 0 then
    return
  end
  local skill_list = ini_skill:GetItemValueList(index, "r")
  local skill_count = table.getn(skill_list)
  form.groupbox_skill_list:DeleteAll()
  local next_left, next_top = 0, 0
  local gbox, lbl_skill, lbl_name
  for i = 1, skill_count do
    local skill_str = util_split_string(nx_string(skill_list[i]), ",")
    gbox = clone_control("GroupBox", "gbox_skill" .. nx_string(i), form.gbox_template_skill, form.groupbox_skill_list)
    if nx_is_valid(gbox) then
      if next_left + gbox.Width > form.groupbox_skill_list.Width then
        next_left = 0
        next_top = next_top + gbox.Height
      end
      gbox.Left = next_left
      gbox.Top = next_top
      next_left = next_left + gbox.Width
      gbox.Visible = true
      lbl_skill = clone_control("Label", "lbl_skill" .. nx_string(i), form.lbl_tmp_skill, gbox)
      if nx_is_valid(lbl_skill) then
        lbl_skill.ClickEvent = true
        lbl_skill.Transparent = false
        lbl_skill.skill_id = nx_string(skill_str[1])
        nx_bind_script(lbl_skill, nx_current())
        nx_callback(lbl_skill, "on_get_capture", "on_lbl_skill_get_capture")
        nx_callback(lbl_skill, "on_lost_capture", "on_lbl_skill_lost_capture")
        lbl_skill.BackImage = nx_string(skill_str[2])
      end
      lbl_name = clone_control("Label", "lbl_skillname" .. nx_string(i), form.lbl_tmp_skillname, gbox)
      if nx_is_valid(lbl_name) then
        lbl_name.Text = util_text(nx_string(skill_str[3]))
      end
    end
  end
end
function on_lbl_skill_get_capture(lbl)
  local form = lbl.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ITEMTYPE_ZHAOSHI = 1000
  local config_id = nx_string(lbl.skill_id)
  local ini_skill = get_ini("share\\Skill\\skill_new.ini", false)
  if not nx_is_valid(ini_skill) then
    return
  end
  local index = ini_skill:FindSectionIndex(nx_string(config_id))
  if nx_number(index) < 0 then
    return
  end
  local static_data = ini_skill:ReadString(index, "StaticData", "")
  local item_data = nx_execute("tips_game", "get_tips_ArrayList")
  item_data.ConfigID = nx_string(config_id)
  item_data.ItemType = nx_int(ITEMTYPE_ZHAOSHI)
  item_data.Level = 1
  item_data.SkillMaxLevel = 1
  item_data.StaticData = nx_int(static_data)
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_goods_tip", item_data, x, y, 32, 32, form)
end
function on_lbl_skill_lost_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  return game_client:GetPlayer()
end
function set_node_prop(node, index)
  if not nx_is_valid(node) then
    return
  end
  if nx_number(index) < 0 or nx_number(index) > table.getn(NODE_PROP) then
    return
  end
  for prop_name, value in pairs(NODE_PROP[nx_number(index)]) do
    nx_set_property(node, nx_string(prop_name), value)
  end
end
function clone_control(ctrl_type, name, refer_ctrl, parent_ctrl)
  if not (nx_is_valid(refer_ctrl) and nx_is_valid(parent_ctrl)) or ctrl_type == "" or name == "" then
    return nx_null()
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local cloned_ctrl = gui:Create(ctrl_type)
  if not nx_is_valid(cloned_ctrl) then
    return nx_null()
  end
  local prop_list = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_list) do
    nx_set_property(cloned_ctrl, prop_list[i], nx_property(refer_ctrl, prop_list[i]))
  end
  cloned_ctrl.Left = refer_ctrl.Left
  cloned_ctrl.Top = refer_ctrl.Top
  nx_set_custom(parent_ctrl.ParentForm, name, cloned_ctrl)
  cloned_ctrl.Name = name
  parent_ctrl:Add(cloned_ctrl)
  return cloned_ctrl
end
function get_rank_prop(rank_name, prop)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\rank_prop.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(rank_name))
  if sec_index < 0 then
    return ""
  end
  return ini:ReadString(sec_index, nx_string(prop), "")
end
function get_tiguan_dualplay_ini(path)
  return get_ini(nx_string(path), false)
end
function get_guan_name(guan_id)
  local ini_tiguan = get_tiguan_dualplay_ini("share\\War\\tiguan.ini")
  if not nx_is_valid(ini_tiguan) then
    return nx_widestr("")
  end
  local sec_index = ini_tiguan:FindSectionIndex(nx_string(guan_id))
  if 0 <= sec_index then
    local text = ini_tiguan:ReadString(sec_index, "Name", "")
    return util_text(nx_string(text))
  end
  return nx_widestr("")
end
function get_guan_hinttext(guan_id)
  local ini_tiguan = get_tiguan_dualplay_ini("share\\War\\tiguan.ini")
  if not nx_is_valid(ini_tiguan) then
    return nx_widestr("")
  end
  local sec_index = ini_tiguan:FindSectionIndex(nx_string(guan_id))
  if 0 <= sec_index then
    local text = ini_tiguan:ReadString(sec_index, "Name", "")
    return util_text(nx_string(text) .. "_tiguan_dual_play_hinttextid")
  end
  return nx_widestr("")
end
function get_boss_name(guan_id, group_id)
  local ini_tiguan = get_tiguan_dualplay_ini("share\\War\\tiguan.ini")
  if not nx_is_valid(ini_tiguan) then
    return nx_widestr("")
  end
  local sec_index = ini_tiguan:FindSectionIndex(nx_string(guan_id))
  if 0 <= sec_index then
    local tmp_str = ini_tiguan:ReadString(sec_index, "BossList", "")
    local boss_list = util_split_string(tmp_str, ";")
    tmp_str = boss_list[nx_number(group_id) + 1]
    if tmp_str ~= nil then
      return util_text(nx_string(tmp_str))
    end
  end
  return nx_widestr("")
end
function get_format_time_string(second, show_0min)
  local tmp_time = nx_int(second)
  if tmp_time < nx_int(0) then
    return nx_widestr(0) .. util_text("ui_min") .. nx_widestr(0) .. util_text("ui_sec")
  end
  local tmp_min, tmp_second = nx_int(0), nx_int(0)
  if tmp_time < nx_int(60) then
    tmp_second = tmp_time
  elseif tmp_time >= nx_int(60) then
    tmp_min = nx_int(tmp_time / nx_int(60))
    tmp_second = tmp_time - tmp_min * 60
  end
  if nx_boolean(show_0min) then
    return nx_widestr(tmp_min) .. util_text("ui_min") .. nx_widestr(tmp_second) .. util_text("ui_sec")
  elseif tmp_min == nx_int(0) then
    return nx_widestr(tmp_second) .. util_text("ui_sec")
  else
    return nx_widestr(tmp_min) .. util_text("ui_min") .. nx_widestr(tmp_second) .. util_text("ui_sec")
  end
end
function save_point(form, huxiao_point, gupu_point)
  if not nx_is_valid(form) then
    return
  end
  local tmp_count = nx_int(huxiao_point)
  if tmp_count >= nx_int(0) then
    form.huxiao_point = tmp_count
  end
  tmp_count = nx_int(gupu_point)
  if tmp_count >= nx_int(0) then
    form.gupu_point = tmp_count
  end
end
function save_tiguan_step_to_file(b_opened)
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
  if nx_boolean(b_opened) then
    ini:WriteInteger("tiguan_dualplay", "opened", 1)
  else
    ini:WriteInteger("tiguan_dualplay", "opened", 0)
  end
  ini:SaveToFile()
  if nx_is_valid(ini) then
    nx_destroy(ini)
  end
end
function get_tiguan_step_from_file()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return false
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return false
  end
  local cur_step = 0
  ini.FileName = nx_string(account) .. "\\form_main.ini"
  if ini:LoadFromFile() then
    cur_step = ini:ReadInteger("tiguan_dualplay", "opened", 0)
  end
  if nx_is_valid(ini) then
    nx_destroy(ini)
  end
  return cur_step == 1
end
function get_last_no(cur_no, last_no)
  local text = ""
  local color = "255,255,255,255"
  if nx_int(cur_no) <= nx_int(0) then
    return text, color
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return text, color
  end
  if nx_int(last_no) <= nx_int(0) then
    text = gui.TextManager:GetFormatText("ui_rank_change_new")
    color = "255,255,0,0"
    return text, color
  end
  if nx_int(cur_no) == nx_int(last_no) then
    text = gui.TextManager:GetFormatText("ui_rank_change_no")
    color = "255,197,184,150"
    return text, color
  end
  if nx_int(cur_no) < nx_int(last_no) then
    text = gui.TextManager:GetFormatText("ui_rank_change_up")
    text = nx_string(text) .. nx_string(nx_int(last_no) - nx_int(cur_no))
    color = "255,0,255,0"
    return text, color
  end
  if nx_int(cur_no) > nx_int(last_no) then
    text = gui.TextManager:GetFormatText("ui_rank_change_down")
    text = nx_string(text) .. nx_string(nx_int(cur_no) - nx_int(last_no))
    color = "255,255,0,0"
    return text, color
  end
end
