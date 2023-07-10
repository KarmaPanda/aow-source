require("form_stage_main\\form_huashan\\huashan_define")
require("form_stage_main\\form_huashan\\huashan_function")
require("util_functions")
require("util_gui")
require("share\\itemtype_define")
require("custom_sender")
require("role_composite")
require("define\\request_type")
function open_form()
  local form = util_get_form(m_Main_Path, true)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  form.Visible = true
  form:Show()
  return form
end
function main_form_init(form)
  form.Fixed = false
  form.arrayList_msg = nil
  form.LimitInScreen = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.ani_loading.Visible = false
  form.lbl_loading.Visible = false
  if not nx_is_valid(form.arrayList_msg) then
    form.arrayList_msg = get_arraylist("form_huashan_main_arraylist_msg")
  end
  form.arrayList_msg:ClearChild()
  on_rbtn_click(form.rbtn_lj_msg)
  get_huashan_phase(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "get_huashan_phase", form)
    timer:Register(60000, -1, nx_current(), "get_huashan_phase", form, -1, -1)
  end
end
function on_main_form_close(form)
  closeallform(true)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timeout_cancel_loading", form)
    timer:UnRegister(nx_current(), "get_huashan_phase", form)
  end
  if nx_is_valid(form.arrayList_msg) then
    nx_destroy(form.arrayList_msg)
  end
  nx_destroy(form)
end
function open_join_match_game()
  local form = nx_value(m_Main_Path)
  if not nx_is_valid(form) then
    form = open_form()
  end
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  on_rbtn_click(form.rbtn_dz_msg)
end
function on_server_msg(...)
  local child_msg_id = arg[1]
  if HuaShanSToC_LeaveLook == child_msg_id then
    local look = nx_value(m_WuLin_Path)
    if nx_is_valid(look) then
      look:Close()
    end
    return
  elseif HuaShanSToC_FightStart == child_msg_id then
    local form_djs = nx_execute("util_gui", "util_get_form", m_Game_Djs, true, false)
    if nx_is_valid(form_djs) then
      form_djs:Show()
    end
    return
  elseif HuaShanSToC_AskJoinInvote == child_msg_id then
    nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", REQUESTTYPE_HUASHAN_JOIN_MATCH_GAME, "", 120)
    return
  elseif HuaShanSToC_FightEnd == child_msg_id then
    local form_djs = nx_execute("util_gui", "util_get_form", m_Game_Djs, true, false)
    if nx_is_valid(form_djs) then
      form_djs:Close()
    end
    return
  elseif HuaShanSToC_FightStatistics == child_msg_id then
    nx_execute(m_Game_Stat, "open_form", arg[2])
    return
  end
  local form = nx_value(m_Main_Path)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.arrayList_msg) then
    return
  end
  local flag = ""
  if HuaShanSToC_ReqPlayerList == child_msg_id then
    flag = "rw_list"
  elseif HuaShanSToC_ReqPlayerInfo == child_msg_id then
    flag = nx_string(arg[2])
  elseif HuaShanSToC_ReqVSList == child_msg_id then
    flag = "dz_msg"
  elseif HuaShanSToC_ReqFightLog == child_msg_id then
    flag = "zd_notes"
  elseif HuaShanSToC_GetRankNo == child_msg_id then
    flag = "get_rankno"
  elseif HuaShanSToC_GetHuaShanPhase == child_msg_id then
    flag = "get_phase"
  elseif HuaShanSToC_ReqAsLooker == child_msg_id then
    flag = "dz_look"
  else
    return
  end
  if "" == flag then
    return
  end
  local child = form.arrayList_msg:GetChild(flag)
  if not nx_is_valid(child) then
    return
  end
  nx_execute(child.path, child.func, unpack(arg))
  form.arrayList_msg:RemoveChildByID(child)
  if 0 == form.arrayList_msg:GetChildCount() then
    form.ani_loading.Visible = false
    form.lbl_loading.Visible = false
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "timeout_cancel_loading", form)
    end
  end
end
function on_custom_msg(path, funcname, child_msg_id, ...)
  local form = nx_value(m_Main_Path)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.arrayList_msg) then
    return
  end
  local flag = ""
  if HuaShanCToS_ReqPlayerList == child_msg_id then
    flag = "rw_list"
  elseif HuaShanCToS_ReqPlayerInfo == child_msg_id then
    flag = nx_string(arg[1])
    if flag == nx_string(get_name(m_Name_NULL)) then
      return
    end
    if m_Name_NULL == flag then
      return
    end
  elseif HuaShanCToS_ReqVSList == child_msg_id then
    flag = "dz_msg"
  elseif HuaShanCToS_AnswerInvote == child_msg_id then
  elseif HuaShanCToS_ReqFightLog == child_msg_id then
    flag = "zd_notes"
  elseif HuaShanCToS_ReqAsLooker == child_msg_id then
    flag = "dz_look"
  elseif HuaShanCToS_GetRankNo == child_msg_id then
    flag = "get_rankno"
  elseif HuaShanCToS_GetHuaShanPhase == child_msg_id then
    flag = "get_phase"
  elseif HuaShanCToS_ReqLeaveLooker == child_msg_id then
  end
  if "" ~= path and "" ~= funcname then
    if "" == flag then
      return
    end
    local child = form.arrayList_msg:CreateChild(flag)
    nx_set_custom(child, "path", path)
    nx_set_custom(child, "func", funcname)
    form.ani_loading.PlayMode = 0
    form.ani_loading.Visible = true
    form.lbl_loading.Visible = true
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "timeout_cancel_loading", form)
      timer:Register(15000, 1, nx_current(), "timeout_cancel_loading", form, -1, -1)
    end
  end
  nx_execute("custom_sender", "custom_request_huashan", nx_int(child_msg_id), unpack(arg))
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_rbtn_click(btn)
  btn.Checked = true
  if 4 == btn.TabIndex then
    nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "show_origin")
    return
  elseif 5 == btn.TabIndex then
    nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "show_ytj")
    return
  elseif 6 == btn.TabIndex then
    nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "show_wuxuege")
    return
  end
  local form = btn.ParentForm
  closeallform(false)
  local child_path = m_child_list[btn.TabIndex]
  local form_child = nx_value(child_path)
  if not nx_is_valid(form_child) then
    form_child = nx_execute("util_gui", "util_get_form", child_path, true, false)
    if not nx_is_valid(form_child) then
      return
    end
    local is_load = form.groupbox_main:Add(form_child)
    if is_load == true then
      form_child.Top = 0
      form_child.Left = 0
    else
      return
    end
  end
  form_child.Visible = true
  get_huashan_phase(form)
end
function on_server_get_phase(...)
  if HuaShanSToC_GetHuaShanPhase ~= arg[1] then
    return
  end
  local phase = nx_number(arg[2])
  if phase < HuaShanNotStart and phase > HuaShanFighting then
    return
  end
  local form = nx_value(m_Main_Path)
  if not nx_is_valid(form) then
    return
  end
  local choose = nx_number(arg[3])
  form.ani_1.Visible = false
  form.ani_2.Visible = false
  form.ani_3.Visible = false
  form.ani_4.Visible = false
  form.ani_5.Visible = false
  form.rbtn_rw_list.Enabled = false
  form.rbtn_dz_msg.Enabled = false
  if HuaShanRankDay == phase then
    form.ani_1.PlayMode = 0
    form.ani_1.Visible = true
  elseif HuaShanFightDay == phase then
    form.ani_2.PlayMode = 0
    form.ani_2.Visible = true
    form.rbtn_rw_list.Enabled = true
  elseif HuaShanFighting == phase then
    form.ani_3.PlayMode = 0
    form.ani_3.Visible = true
    form.rbtn_rw_list.Enabled = true
    form.rbtn_dz_msg.Enabled = true
  end
  if 0 < choose then
    form.ani_4.PlayMode = 0
    form.ani_4.Visible = true
    form.ani_5.PlayMode = 0
    form.ani_5.Visible = true
  end
end
function get_huashan_phase(form)
  on_custom_msg(m_Main_Path, "on_server_get_phase", HuaShanCToS_GetHuaShanPhase)
end
function timeout_cancel_loading(form)
  if not nx_is_valid(form) then
    return
  end
  if 0 == form.arrayList_msg:GetChildCount() then
    return
  end
  form.arrayList_msg:ClearChild()
  form.ani_loading.Visible = false
  form.lbl_loading.Visible = false
  self_systemcenterinfo(1000050)
end
function closeallform(isclose)
  for i, path in ipairs(m_child_list) do
    local form = nx_value(path)
    if nx_is_valid(form) then
      if isclose then
        form:Close()
      else
        form.Visible = false
      end
    end
  end
end
