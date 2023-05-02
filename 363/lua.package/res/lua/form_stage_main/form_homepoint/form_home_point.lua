require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
require("share\\client_custom_define")
require("util_vip")
require("form_stage_main\\form_homepoint\\home_point_data")
FORM_HOME_POINT = "form_stage_main\\form_homepoint\\form_home_point"
HOMEPOINT_HEIGHT = 24
HOMEPOINT_TITLE = 30
Query_TimeDown = 0
Use_HomePoint = 1
Add_HomePoint = 2
Del_HomePoint = 3
Prior_HomePoint = 4
Ext_HomePoint = 5
Rep_HomePoint = 6
Cancel_HomePoint = 7
ItemAdd_HomePoint = 8
ADD_HIRE_FIX = 9
DEL_HIRE_FIX = 10
BUY_HIRE_TIME = 11
local guild_domain_list = {}
FORM_WIDTH = 670
FORM_WIDTH_EXT = 910
School_HomePoint = 2
Guild_HomePoint = 3
JiangHu_HomePoint = 4
Relive_HomePoint = 5
HireJianghu_HomePoint = 6
HireFix_HomePoint = 7
HPS_NORMAL = 1
HPS_KUONGZHI = 2
HPS_KUOCHONG = 3
HPS_RELIVE = 4
function auto_show_hide_point_form()
  local form = nx_value(FORM_HOME_POINT)
  if nx_is_valid(form) then
    if not form.Visible then
      ShowHomePointForm()
    else
      reset_homepoint_timedown(form)
      form.pbar_timedown.Value = 0
      form.lbl_time.Text = ""
      form.Visible = false
      reset_hire_timedown(form)
      form:Close()
    end
  else
    ShowHomePointForm()
  end
end
function ShowHomePointForm()
  send_homepoint_msg_to_server(Query_TimeDown)
end
function reset_scene()
  local bVisible = false
  local form = nx_value(FORM_HOME_POINT)
  if nx_is_valid(form) then
    bVisible = false
    form.Visible = false
    form:Close()
  else
    bVisible = false
  end
  nx_execute("util_gui", "util_auto_show_hide_form", FORM_HOME_POINT)
  form = nx_value(FORM_HOME_POINT)
  if nx_is_valid(form) then
    form.Visible = bVisible
    if bVisible then
      refresh_form(form)
    else
    end
  end
end
function refresh_form(form)
  if nx_is_valid(form) then
    ShowHomePointForm()
    on_homepoint_rec_refresh(form, "", "update", -1, -1)
  end
end
function DelayExecute(ms, count, formname, func)
  local form = nx_value(formname)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(formname, func, form)
    timer:Register(ms, count, formname, func, form, -1, -1)
  end
end
function ClearDelay(formname, func)
  local form = nx_value(formname)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(formname, func, form)
  end
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  center_for_screen(form)
  form.timer_span = 1000
  form.pbar_timedown.Maximum = THIRTY_MINUTE
  form.pbar_timedown.Minimum = 0
  form.hp_grp.area_hp = ""
  form.groupbox_rep.Visible = false
  Init_homepoint_abstruct(form)
  form.btn_xunlu.Text = nx_widestr(util_text("ui_map"))
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("HomePointList", form, nx_current(), "on_homepoint_rec_refresh")
    databinder:AddTableBind("DongHaiHomePointList", form, nx_current(), "on_homepoint_rec_refresh")
    databinder:AddTableBind("HireHomePointList", form, nx_current(), "on_homepoint_hire_rec_refresh")
    databinder:AddRolePropertyBind("JiangHuHomePointCount", "int", form, nx_current(), "on_homepoint_rec_refresh")
    databinder:AddRolePropertyBind("GuildHomePointCount", "int", form, nx_current(), "on_homepoint_rec_refresh")
    databinder:AddRolePropertyBind("RelivePositon", "string", form, nx_current(), "refresh_relive")
    databinder:AddRolePropertyBind("DongHaiRelivePositon", "string", form, nx_current(), "refresh_relive")
  end
  form.grp_hire.Visible = false
  form.hire_time = 0
  if nx_int(form.hire_time) <= nx_int(0) then
    form.grp_hire_time.Visible = false
    form.lbl_hire_text.Visible = true
  else
    form.grp_hire_time.Visible = true
    form.lbl_hire_text.Visible = false
  end
  form.open_by_guide = 1
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("HomePointList", form)
    databinder:DelTableBind("DongHaiHomePointList", form)
    databinder:DelTableBind("HireHomePointList", form)
    databinder:DelRolePropertyBind("JiangHuHomePointCount", form)
    databinder:DelRolePropertyBind("GuildHomePointCount", form)
    databinder:DelRolePropertyBind("RelivePositon", form)
    databinder:DelRolePropertyBind("DongHaiRelivePositon", form)
  end
  reset_homepoint_timedown(form)
  reset_hire_timedown(form)
  nx_destroy(form)
end
function on_form_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  auto_show_hide_point_form()
end
function ok_btn_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if nx_is_valid(player) then
    local status = nx_number(player:QueryProp("NeigongPKStatus"))
    if status ~= 0 then
      return
    end
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  local hp = form_home_point.SelectHp
  local hp_type = form_home_point.SelectHpType
  if string.len(hp) == 0 then
    return
  end
  if not check_home_point(hp, hp_type) then
    return
  end
  if not ShowTipDialog(nx_widestr(util_text("ui_homepoint_limit"))) then
    return
  end
  nx_function("ext_clear_v_h_orient")
  send_homepoint_msg_to_server(Use_HomePoint, hp, hp_type)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function cancel_btn_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_rbtn_hp_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  form_home_point:ShowHomePointList(form, SHOW_TYPE_HOMEPOINT)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_show_scene_homepoint_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  form_home_point:ShowHomePointList(form, SHOW_TYPE_SCENE_HOMEPOINT)
end
function on_btn_oper_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  local hpid = form_home_point.SelectHp
  if "" == hpid or nil == hpid then
    return
  end
  if not check_home_point(hpid, form_home_point.SelectHpType) then
    return
  end
  local hp_info = form_home_point:GetHomePointInfo(hpid)
  local hp_name = hp_info[HP_NAME]
  if form.show_type == SHOW_TYPE_HOMEPOINT then
    if nx_int(hp_info[HP_TYPE]) == nx_int(School_HomePoint) and IsSchoolHomePoint(hp_info) == true then
      ShowTipDialog(nx_widestr(util_text("ui_schoolhp_limit")))
      return
    end
    if not ShowTipDialog(nx_widestr(util_text("ui_delete_limit"))) then
      return
    end
    send_homepoint_msg_to_server(Del_HomePoint, hpid)
  else
    if form_home_point:IsExistCurHomePoint(hpid) then
      ShowTipDialog(nx_widestr(util_text("ui_reset_limit")))
      return
    end
    local hp_type = get_hp_type(hp_info[HP_TYPE])
    local MaxTypeCount = GetTypeHomePointCount(hp_type)
    local nExistCount = GetExistHomePointCount(hp_type)
    if hp_type == JiangHu_HomePoint then
      MaxTypeCount = MaxTypeCount + GetHireJianghuMaxCount()
    end
    if nExistCount >= MaxTypeCount then
      if not ShowTipDialog(nx_widestr(util_text("ui_changehomepoint1"))) then
        return
      end
      if nx_is_valid(form) and nx_find_custom(form, "domainlist") then
        show_rep_hp_list(form, hp_type)
      end
    elseif IsSetHomePoint(hp_name) == true then
      send_homepoint_msg_to_server(Add_HomePoint, hpid)
    end
  end
end
function on_xunlu_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  local hpid = form_home_point.SelectHp
  local hpinfo = form_home_point:GetHomePointInfo(hpid)
  local sel_hp_type = hpinfo[HP_TYPE]
  local hp_scene_id, sceneno, x, y, z, fix_id = 0
  if HireFix_HomePoint == sel_hp_type then
    fix_id, sceneno, x, y, z = GetHireFixInfo()
  else
    sceneno, x, y, z = get_homepoint_pos(hpid)
  end
  hp_scene_id = get_scene_name(sceneno)
  local curscence_id = get_cur_scene_resource()
  if nx_string(hp_scene_id) ~= curscence_id then
    ShowTipDialog(nx_widestr(util_text("ui_maplost")))
    return
  end
  if not ShowTipDialog(nx_widestr(util_text("ui_map_limit"))) then
    return
  end
  local path_finding = nx_value("path_finding")
  if not nx_is_valid(path_finding) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) or nx_is_valid(form_map) and not form_map.Visible then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "auto_show_hide_map_scene")
  end
  nx_execute("form_stage_main\\form_map\\form_map_scene", "set_trace_npc_id", "", nx_float(x), nx_float(y), nx_float(z), curscence_id)
end
function on_click_homepoint_btn(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  if not nx_find_custom(btn, "hp_status") then
    return
  end
  if nx_find_custom(btn, "hpid") and btn.hpid ~= "" and btn.hpid ~= nil and not check_home_point(btn.hpid, btn.hp_type) then
    return
  end
  local hp_status = btn.hp_status
  if hp_status == 1 then
    if form_home_point:IsNewTerritoryType() and nx_int(btn.hp_type) ~= nx_int(JiangHu_HomePoint) then
      return
    end
    local photo, des, hp_name, sceneid
    if nx_int(btn.hp_type) ~= nx_int(HireFix_HomePoint) then
      local hpinfo = form_home_point:GetHomePointInfo(btn.hpid)
      photo = hpinfo[HP_PHOTO]
      des = hpinfo[HP_DES]
      hp_name = hpinfo[HP_NAME]
      sceneid = hpinfo[HP_SCENE_NO]
    else
      photo, des, hp_name, sceneid = get_fix_homepoint_info()
    end
    if nx_string(btn.parent_grp_name) == nx_string("hp_grp") then
      ShowHomePointInfo(form, photo, des, hp_name, sceneid)
      fresh_hp_btn(form.hp_grp, form.show_type)
    else
      form.sel_rep_hp = btn.hpid
      fresh_hp_btn(form.grp_record_hp, SHOW_TYPE_HOMEPOINT)
    end
    btn.NormalImage = SelHomePoint
    btn.FocusImage = SelHomePoint
    form_home_point.SelectHp = btn.hpid
    form_home_point.SelectHpType = btn.hp_type
    form.btn_hp.Visible = true
  else
    local Type = btn.hp_type
    if form_home_point:IsNewTerritoryType() and nx_int(Type) ~= nx_int(JiangHu_HomePoint) then
      return
    end
    if hp_status == 2 then
      local ret = false
      if nx_int(Type) == nx_int(School_HomePoint) then
        ShowTipDialog(nx_widestr(util_text("ui_schoollimit")))
      elseif nx_int(Type) == nx_int(Guild_HomePoint) then
        if IsOwnGuild() then
          local nTypeCount = GetExistHomePointCount(Guild_HomePoint)
          if nx_int(nTypeCount) > nx_int(0) then
            ret = ShowTipDialog(nx_widestr(util_text("ui_scenelimit")))
          else
            ret = ShowTipDialog(nx_widestr(util_text("ui_bangpailimit001")))
          end
        else
          ShowTipDialog(nx_widestr(util_text("ui_bangpailimit002")))
        end
      elseif HireFix_HomePoint == Type then
        ret = ShowTipDialog(nx_widestr(util_text("ui_home_ispoised")))
      else
        ret = ShowTipDialog(nx_widestr(util_text("ui_scenelimit")))
      end
      if ret then
        if HireFix_HomePoint == Type then
          send_homepoint_msg_to_server(ADD_HIRE_FIX)
        elseif nx_is_valid(form) then
          on_show_scene_homepoint_click(form.rbtn_list)
        end
      end
      return
    end
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local nCurHpCount = GetTypeHomePointCount(0)
    local nCapitalType, nCapital = Get_Ext_HomePoint_Money(nCurHpCount + 1)
    gui.TextManager:Format_SetIDName("ui_extern_hp" .. nx_string(nCapitalType))
    gui.TextManager:Format_AddParam(nx_int(nCapital))
    local text = gui.TextManager:Format_GetText()
    if ShowTipDialog(nx_widestr(text)) ~= true then
      return
    end
    send_homepoint_msg_to_server(Ext_HomePoint, Type)
    if nx_is_valid(form) then
      if nx_string(btn.parent_grp_name) == nx_string("hp_grp") then
        fresh_hp_btn(form.hp_grp, form.show_type)
      else
        fresh_hp_btn(form.grp_record_hp, SHOW_TYPE_HOMEPOINT)
      end
      btn.NormalImage = SelHomePoint
      btn.FocusImage = SelHomePoint
    end
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_click_homepoint_label(label)
  local btn = label.trans_btn
  if not nx_is_valid(btn) then
    return
  end
  on_click_homepoint_btn(btn)
end
function on_click_op_homepoint_btn(btn)
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  if form_home_point:IsNewTerritoryType() and nx_find_custom(btn, "hp_type") and JiangHu_HomePoint ~= btn.hp_type then
    return
  end
  local hpid = btn.hpid
  if hpid ~= "" and hpid ~= nil then
    if not check_home_point(hpid, btn.hp_type) then
      return
    end
    if HireFix_HomePoint == btn.hp_type then
      if not ShowTipDialog(nx_widestr(util_text("ui_delete_limit"))) then
        return
      end
      send_homepoint_msg_to_server(DEL_HIRE_FIX)
    else
      local bRet, hp_info = GetHomePointFromHPid(hpid)
      if bRet == false then
        return
      end
      if nx_int(hp_info[HP_TYPE]) == nx_int(School_HomePoint) and IsSchoolHomePoint(hp_info) == true then
        ShowTipDialog(nx_widestr(util_text("ui_schoolhp_limit")))
        return
      end
      local hp_type = get_hp_type(hp_info[HP_TYPE])
      local nTypeCount = GetExistHomePointCount(nx_int(hp_type))
      if hp_type == JiangHu_HomePoint then
        nTypeCount = nTypeCount - GetHireJianghuCount()
      end
      if IsHireJianghu(hpid) == false and nTypeCount <= 1 then
        ShowTipDialog(nx_widestr(util_text("ui_del_limit")))
        return
      end
      if not ShowTipDialog(nx_widestr(util_text("ui_delete_limit"))) then
        return
      end
      send_homepoint_msg_to_server(Del_HomePoint, hpid)
    end
  else
    local form = btn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    if HireFix_HomePoint == btn.hp_type then
      if not ShowTipDialog(nx_widestr(util_text("ui_home_ispoised"))) then
        return
      end
      send_homepoint_msg_to_server(ADD_HIRE_FIX)
    else
      on_show_scene_homepoint_click(form.rbtn_list)
    end
  end
end
function on_btn_rep_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "sel_rep_hp") then
    return
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  local sel_hp = form_home_point.SelectHp
  local sel_rep_hp = form.sel_rep_hp
  if sel_hp == "" or sel_hp == nil or sel_rep_hp == "" or sel_rep_hp == nil then
    return
  end
  if not check_home_point(sel_hp, form_home_point.SelectHpType) or not check_home_point(sel_rep_hp) then
    return
  end
  if IsExistRecordHomePoint(sel_hp) then
    ShowTipDialog(nx_widestr(util_text("ui_reset_limit")))
    return
  end
  if not ShowTipDialog(nx_widestr(util_text("ui_changehomepoint2"))) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  send_homepoint_msg_to_server(Rep_HomePoint, sel_rep_hp, sel_hp)
  if nx_is_valid(form) then
    form.groupbox_rep.Visible = false
    form.rbtn_hp.Visible = true
    form.rbtn_hire.Visible = true
    form.rbtn_hp.Checked = true
    form.Width = FORM_WIDTH
    if form_home_point:IsNewTerritoryType() then
      form.rbtn_hire.Enabled = false
      form.rbtn_hire.Visible = false
    else
      form.rbtn_hire.Enabled = true
      form.rbtn_hire.Visible = true
    end
  end
end
function on_btn_close_rep_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  form.groupbox_rep.Visible = false
  form.rbtn_hp.Visible = true
  form.Width = FORM_WIDTH
  if form_home_point:IsNewTerritoryType() then
    form.rbtn_hire.Enabled = false
    form.rbtn_hire.Visible = false
  else
    form.rbtn_hire.Enabled = true
    form.rbtn_hire.Visible = true
  end
end
function on_relive_get_capture(lbl)
  nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_home_prompt")), lbl.AbsLeft + 5, lbl.AbsTop + 5, 0, lbl.ParentForm)
end
function on_relive_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function on_flag_get_capture(lbl)
  nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_home_save")), lbl.AbsLeft + 5, lbl.AbsTop + 5, 0, lbl.ParentForm)
end
function on_flag_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function on_area_get_capture(lbl)
  nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_hp_pos")), lbl.AbsLeft + 5, lbl.AbsTop + 5, 0, lbl.ParentForm)
end
function on_area_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function on_homepoint_get_capture(btn)
  if not nx_find_custom(btn, "hp_status") then
    return
  end
  local hp_status = btn.hp_status
  if nx_int(hp_status) ~= nx_int(HPS_NORMAL) then
    return
  end
  if not nx_find_custom(btn, "sceneid") then
    return
  end
  local sceneid = btn.sceneid
  if nx_int(0) >= nx_int(sceneid) then
    return
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_scene_" .. nx_string(nx_int(sceneid)))), btn.AbsLeft + 5, btn.AbsTop + 5, 0, btn.ParentForm)
end
function on_homepoint_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function on_get_capture_label(label)
  local btn = label.trans_btn
  if not nx_is_valid(btn) then
    return
  end
  on_homepoint_get_capture(btn)
end
function on_lost_capture_label(label)
  local btn = label.trans_btn
  if not nx_is_valid(btn) then
    return
  end
  on_homepoint_lost_capture(btn)
end
function on_click_relive_btn(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local rc, hpid = getReturnCityName()
  if nx_string(nil) == nx_string(hpid) or nx_string(hpid) == "" then
    return
  end
  local pic, des, hp_name, sceneid = get_homepoint_info(hpid)
  ShowHomePointInfo(form, pic, des, hp_name, sceneid)
  form.btn_hp.Visible = false
  form.btn_xunlu.Visible = false
end
function center_for_screen(form)
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
end
function get_homepoint_info(hpid)
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  local hpinfo = form_home_point:GetHomePointInfo(hpid)
  local pic = hpinfo[HP_PHOTO]
  local des = hpinfo[HP_DES]
  local homepoint_name = hpinfo[HP_NAME]
  local sceneID = hpinfo[HP_SCENE_NO]
  return pic, des, homepoint_name, sceneID
end
function get_fix_homepoint_info()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  hire_id, hire_scene, hire_x, hire_y, hire_z = GetHireFixInfo()
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_poised_location_title", nx_int(hire_x), nx_int(hire_y), nx_int(hire_z)))
  return Hp_Fix, text, hire_id, hire_scene
end
function get_default_homepoint_info()
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  return get_homepoint_info(form_home_point.SelectHp)
end
function get_homepoint_pos(hpid)
  local ini = nx_execute("util_functions", "get_ini", HOMEPOINT_INI_FILE)
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(hpid)
  if index < 0 then
    return
  end
  local pos_text = ini:ReadString(index, "PositonXYZ", "")
  local sceneNO = ini:ReadInteger(index, "SceneID", 0)
  local pos = util_split_string(nx_string(pos_text), ",")
  return sceneNO, pos[1], pos[2], pos[3]
end
function Get_Ext_HomePoint_Money(Count)
  local ini = nx_execute("util_functions", "get_ini", HOMEPOINT_PRICE_INI_FILE)
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(Count))
  if index < 0 then
    return 0
  end
  local nCapitalType0 = ini:ReadInteger(index, "CapitalType0", 0)
  local nCapitalType1 = ini:ReadInteger(index, "CapitalType1", 0)
  local nCapitalType2 = ini:ReadInteger(index, "CapitalType2", 0)
  if nx_int(nCapitalType0) > nx_int(0) then
    return 0, nCapitalType0
  elseif nx_int(nCapitalType1) > nx_int(0) then
    return 1, nCapitalType1
  elseif nx_int(nCapitalType2) > nx_int(0) then
    return 2, nCapitalType2
  end
  return 0, 0
end
function InitHomePointForm(...)
  local TimeDown = nx_int(arg[1])
  local DomainList = nx_string(arg[2])
  local areahp = nx_string(arg[3])
  hire_time = nx_int(arg[4])
  local form = util_get_form(FORM_HOME_POINT, true)
  if not nx_is_valid(form) then
    return
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  form.groupbox_rep.Visible = false
  form.rbtn_hp.Visible = true
  form.btn_oper.Visible = false
  form.Width = FORM_WIDTH
  form.timer_span = 1000
  form.timer_down = TimeDown
  form.domainlist = DomainList
  form.hire_time = hire_time
  if form_home_point:IsNewTerritoryType() then
    form.rbtn_hire.Enabled = false
    form.rbtn_hire.Visible = false
  else
    form.rbtn_hire.Enabled = true
    form.rbtn_hire.Visible = true
  end
  if nx_int(TimeDown) ~= nx_int(0) then
    form.lbl_time.Text = nx_widestr(get_format_time_text(TimeDown / 1000))
  else
    form.lbl_time.Text = nx_widestr(util_text("ui_timeend"))
  end
  if nx_int(form.hire_time) <= nx_int(0) then
    form.grp_hire_time.Visible = false
    form.lbl_hire_text.Visible = true
  else
    form.grp_hire_time.Visible = true
    form.lbl_hire_text.Visible = false
  end
  InitGuildDomainIDList(DomainList)
  homepoint_timedown_started(form)
  util_show_form(FORM_HOME_POINT, true)
  if nx_string(form.hp_grp.area_hp) ~= nx_string(areahp) then
    form.hp_grp.area_hp = areahp
    show_homepoint_list(form, SHOW_TYPE_HOMEPOINT)
  end
  form.pbar_timedown.Value = THIRTY_MINUTE - TimeDown
  local form = nx_value(FORM_HOME_POINT)
  ui_show_attached_form(form)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "homepoint_guide_flag", false)
end
function Init_homepoint_abstruct(form)
  local pic, des, hp_name, sceneid = get_default_homepoint_info()
  if hp_name == "" or hp_name == nil then
    ShowHomePointInfo(form, "", "", "")
  else
    ShowHomePointInfo(form, pic, des, hp_name, sceneid)
  end
end
function get_format_time_text(time)
  local format_time = ""
  local min = nx_int(time / 60)
  local sec = nx_int(math.mod(time, 60))
  format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  return nx_string(format_time)
end
function on_update_timedown(form)
  local time = form.timer_down
  if nx_int(0) >= nx_int(time) then
    form.pbar_timedown.Value = THIRTY_MINUTE
    form.lbl_time.Text = nx_widestr(util_text("ui_timeend"))
    reset_homepoint_timedown(form)
    return
  end
  form.lbl_time.Text = nx_widestr(get_format_time_text(time / 1000))
  form.timer_down = nx_int(time) - nx_int(PER_SECOND)
  form.pbar_timedown.Value = THIRTY_MINUTE - form.timer_down
end
function homepoint_timedown_started(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_timedown", form)
    timer:Register(nx_int(form.timer_span), -1, nx_current(), "on_update_timedown", form, -1, -1)
    timer:UnRegister(nx_current(), "on_update_hire_timedown", form)
    timer:Register(nx_int(form.timer_span), -1, nx_current(), "on_update_hire_timedown", form, -1, -1)
  end
end
function reset_homepoint_timedown(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_timedown", form)
  end
  form.timer_down = 0
end
function InitWindowInfo(form, show_type)
  form.show_type = show_type
  if show_type == SHOW_TYPE_HOMEPOINT then
    form.btn_xunlu.Visible = true
    form.btn_hp.Visible = true
    form.btn_oper.Visible = false
    form.rbtn_hp.Visible = true
    form.rbtn_hp.Checked = true
    form.rbtn_list.Checked = false
    form.grp_hire.Visible = false
    form.rbtn_hire.Checked = false
    form.rbtn_hire.Visible = true
  elseif show_type == SHOW_TYPE_HIRE_HOMEPOINT then
    form.btn_xunlu.Visible = true
    form.btn_hp.Visible = true
    form.btn_oper.Visible = false
    form.rbtn_hp.Checked = false
    form.rbtn_list.Checked = false
    form.rbtn_hire.Checked = true
    form.rbtn_hire.Visible = true
    form.grp_hire.Visible = true
  else
    form.btn_oper.Text = nx_widestr(util_text("ui_add"))
    form.btn_hp.Visible = false
    form.btn_oper.Visible = true
    form.rbtn_hp.Checked = false
    form.rbtn_list.Checked = true
    form.grp_hire.Visible = false
  end
  if not nx_is_valid(form_home_point) then
    return
  end
  if form_home_point:IsNewTerritoryType() then
    form.rbtn_hire.Enabled = false
    form.rbtn_hire.Visible = false
  else
    form.rbtn_hire.Enabled = true
    form.rbtn_hire.Visible = true
  end
end
function show_homepoint_list(form, show_type)
  InitWindowInfo(form, show_type)
  form.show_type = show_type
  form.hp_grp:DeleteAll()
  form.hp_grp.record_count = 0
  form.hp_grp.scene_count = 0
  form.hp_grp.title_height = 0
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  if SHOW_TYPE_SCENE_HOMEPOINT == show_type then
    form_home_point:ShowSceneHomePoint(form.hp_grp, JiangHu_HomePoint)
    form_home_point:ShowSceneHomePoint(form.hp_grp, Guild_HomePoint)
  elseif SHOW_TYPE_HIRE_HOMEPOINT == show_type then
    form_home_point:ShowHireHomePoint(form.hp_grp, HireJianghu_HomePoint)
    form_home_point:ShowHireHomePoint(form.hp_grp, HireFix_HomePoint)
  else
    form_home_point:ShowRecordHomePoint(form.hp_grp, School_HomePoint)
    form_home_point:ShowRecordHomePoint(form.hp_grp, JiangHu_HomePoint)
    form_home_point:ShowRecordHomePoint(form.hp_grp, Guild_HomePoint)
    form_home_point:ShowRelivePosInfo(form.hp_grp)
  end
  init_select_btn(form)
end
function show_rep_hp_list(form, hp_type)
  local grp_record_hp = form.grp_record_hp
  if not nx_is_valid(grp_record_hp) then
    return
  end
  grp_record_hp:DeleteAll()
  grp_record_hp.record_count = 0
  grp_record_hp.scene_count = 0
  grp_record_hp.title_height = 0
  grp_record_hp.area_hp = ""
  form.groupbox_rep.Visible = true
  form.rbtn_hp.Visible = false
  form.rbtn_hire.Visible = false
  form.Width = FORM_WIDTH_EXT
  ShowRecordHomePoint(grp_record_hp, hp_type)
  Show_KuoChong_HomePoint(grp_record_hp, hp_type)
  ShowHireRecordHomePoint(grp_record_hp, HireJianghu_HomePoint)
end
function ShowSceneHomePoint(hp_grp, Type)
  local nCount = GetSceneHomePointCount()
  if nCount < 0 then
    return
  end
  add_title_homepoint(hp_grp, hp_grp.scene_count, Type)
  local scene_id = get_cur_scene_resource()
  for i = 0, nCount - 1 do
    local bRet, hp_info = GetHomePointFromIndexNo(i)
    local sceneID = get_scene_name(nx_int(hp_info[HP_SCENE_NO]))
    if nx_string(sceneID) == nx_string(scene_id) and IsOwnGuildHomePoint(hp_info) and IsSchoolHomePoint(hp_info) and nx_int(Type) == nx_int(get_hp_type(hp_info[HP_TYPE])) then
      Create_Scene_HomePoint(hp_grp, hp_grp.scene_count, hp_info, FORM_HOME_POINT)
      hp_grp.scene_count = hp_grp.scene_count + 1
    end
  end
end
function ShowRecordHomePoint(hp_grp, Type)
  if not nx_is_valid(hp_grp) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local TypeCount = 0
  local nCount = client_player:GetRecordRows(HomePointList)
  add_title_homepoint(hp_grp, hp_grp.record_count, Type)
  if nx_int(nCount) > nx_int(0) then
    for index = 0, nCount - 1 do
      local hp_id = client_player:QueryRecord(HomePointList, index, 0)
      local bRet, hp_info = GetHomePointFromHPid(hp_id)
      if bRet == true then
        local hp_type = (hp_info[HP_TYPE] == 0 or hp_info[HP_TYPE] == 1) and JiangHu_HomePoint or hp_info[HP_TYPE]
        if hp_type == Type then
          Create_Record_HomePoint(hp_grp, hp_grp.record_count, hp_info)
          hp_grp.record_count = hp_grp.record_count + 1
          TypeCount = TypeCount + 1
        end
      end
    end
  end
  local MaxTypeCount = GetTypeHomePointCount(Type)
  local kongCount = MaxTypeCount - TypeCount
  if kongCount <= 0 then
    return
  end
  for i = 1, kongCount do
    Create_Kong_HomePoint(hp_grp, hp_grp.record_count, Type)
    hp_grp.record_count = hp_grp.record_count + 1
  end
end
function GetTypeHomePointCount(Type)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local MaxTypeCount = 0
  if Type == JiangHu_HomePoint then
    MaxTypeCount = client_player:QueryProp("JiangHuHomePointCount")
  elseif Type == School_HomePoint then
    MaxTypeCount = client_player:QueryProp("SchoolHomePointCount")
  elseif Type == Guild_HomePoint then
    MaxTypeCount = client_player:QueryProp("GuildHomePointCount")
  elseif Type == HireJianghu_HomePoint then
    MaxTypeCount = client_player:QueryProp("HireJianghuCount")
  elseif Type == HireFix_HomePoint then
    MaxTypeCount = client_player:QueryProp("HireFixCount")
  else
    MaxTypeCount = client_player:QueryProp("HomePointCount")
  end
  return MaxTypeCount
end
function Show_KuoChong_HomePoint(hp_grp, Type)
  if not nx_is_valid(hp_grp) then
    return
  end
  local nTypeCount = GetTypeHomePointCount(Type)
  local nKuoChongCount = 0
  if Type == JiangHu_HomePoint then
    nKuoChongCount = Max_JiangHu_HomePoint_Count - nTypeCount
  elseif Type == School_HomePoint then
    nKuoChongCount = Max_School_HomePoint_Count - nTypeCount
  elseif Type == Guild_HomePoint then
    nKuoChongCount = Max_Guild_HomePoint_Count - nTypeCount
  end
  if nKuoChongCount <= 0 then
    return
  end
  for i = 1, nKuoChongCount do
    Create_KuoChong_HomePoint(hp_grp, hp_grp.record_count, Type)
    hp_grp.record_count = hp_grp.record_count + 1
  end
end
function show_relive_pos_info(hp_grp)
  add_title_homepoint(hp_grp, hp_grp.record_count, Relive_HomePoint)
  local rc, hp = getReturnCityName()
  if nx_widestr(rc) == nx_widestr("") or rc == nil or hp == nil or nx_string(rc) == nx_string("nil") or nx_string(rc) == nx_string("") then
    return
  end
  create_text_item(hp_grp, hp_grp.record_count, rc)
end
function add_title_homepoint(hp_grp, index, hp_type)
  if not nx_is_valid(hp_grp) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local grp = gui:Create("GroupBox")
  grp.AutoSize = false
  grp.DrawMode = "Expand"
  grp.BackColor = "0,0,0,0"
  grp.LineColor = "0,0,0,0"
  grp.Width = hp_grp.Width
  grp.Height = 30
  grp.Top = 10 + index * HOMEPOINT_HEIGHT + hp_grp.title_height
  grp.Name = nx_widestr("title_" .. nx_string(hp_type))
  grp.BackImage = "gui\\common\\treeview\\tree_1_out.png"
  local hp_title = gui:Create("Label")
  hp_title.Width = hp_grp.Width
  hp_title.Height = 30
  hp_title.DrawMode = "Tile"
  hp_title.AutoSize = false
  hp_title.Align = "Center"
  hp_title.Font = "font_main"
  hp_title.ForeColor = "225,220,197,159"
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if nx_int(hp_type) == nx_int(School_HomePoint) then
    if client_player:FindProp("School") and nx_string(client_player:QueryProp("School")) ~= nx_string("") then
      hp_title.Text = nx_widestr(util_text("ui_school_hp_title"))
    elseif client_player:FindProp("Force") and nx_string(client_player:QueryProp("Force")) ~= nx_string("") then
      hp_title.Text = nx_widestr(util_text("ui_force_hp_title"))
    elseif client_player:FindProp("NewSchool") and nx_string(client_player:QueryProp("NewSchool")) ~= nx_string("") then
      hp_title.Text = nx_widestr(util_text("ui_school_hp_title"))
    else
      hp_title.Text = nx_widestr(util_text("ui_school_wumenpai_title"))
    end
  elseif nx_int(hp_type) == nx_int(Guild_HomePoint) then
    hp_title.Text = nx_widestr(util_text("ui_guild_hp_title"))
  elseif nx_int(hp_type) == nx_int(JiangHu_HomePoint) then
    hp_title.Text = nx_widestr(util_text("ui_jianghu_hp_title"))
  elseif nx_int(hp_type) == nx_int(Relive_HomePoint) then
    hp_title.Text = nx_widestr(util_text("ui_guild_war_map_fuhuodian"))
  elseif nx_int(hp_type) == nx_int(HireJianghu_HomePoint) then
    hp_title.Text = nx_widestr(util_text("ui_hire_jianghu_hp_title"))
  elseif nx_int(hp_type) == nx_int(HireFix_HomePoint) then
    hp_title.Text = nx_widestr(util_text("ui_hire_fix_hp_title"))
  end
  grp:Add(hp_title)
  hp_grp.title_height = hp_grp.title_height + 30
  hp_grp:Add(grp)
end
function create_text_item(hp_grp, index, text)
  if not nx_is_valid(hp_grp) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local grp = gui:Create("GroupBox")
  grp.AutoSize = false
  grp.DrawMode = "ExpandH"
  grp.BackColor = "0,0,0,0"
  grp.LineColor = "0,0,0,0"
  grp.Width = hp_grp.Width
  grp.Height = HOMEPOINT_HEIGHT
  grp.Top = 10 + index * HOMEPOINT_HEIGHT + hp_grp.title_height
  grp.Name = nx_widestr("title_" .. nx_string(hp_type))
  local btn_text = gui:Create("Button")
  btn_text.Width = hp_grp.Width
  btn_text.Height = HOMEPOINT_HEIGHT
  btn_text.Left = 0
  btn_text.DrawMode = "FitWindow"
  btn_text.AutoSize = false
  btn_text.Text = nx_widestr(text)
  btn_text.Font = "font_main"
  btn_text.ForeColor = "225,220,197,159"
  btn_text.Align = "Center"
  btn_text.NormalImage = NormalImage
  btn_text.FocusImage = FocusImage
  btn_text.PushImage = PushImage
  btn_text.parent_grp_name = nx_string(hp_grp.Name)
  nx_bind_script(btn_text, nx_current())
  nx_callback(btn_text, "on_click", "on_click_relive_btn")
  nx_callback(btn_text, "on_get_capture", "on_relive_get_capture")
  nx_callback(btn_text, "on_lost_capture", "on_relive_lost_capture")
  grp:Add(btn_text)
  hp_grp.title_height = hp_grp.title_height + HOMEPOINT_HEIGHT
  hp_grp:Add(grp)
end
function create_item_homepoint(hp_grp, index, show_type, hp_name, Type, hp_info)
  if not nx_is_valid(hp_grp) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local grp = gui:Create("GroupBox")
  grp.BackColor = "0,0,0,0"
  grp.LineColor = "0,0,0,0"
  grp.Width = hp_grp.Width
  grp.Height = HOMEPOINT_HEIGHT
  grp.Top = 10 + index * HOMEPOINT_HEIGHT + hp_grp.title_height
  grp.Name = nx_string("grp" .. nx_string(index))
  local hp_button = gui:Create("Button")
  hp_button.DrawMode = "ExpandH"
  hp_button.Height = HOMEPOINT_HEIGHT
  hp_button.Width = hp_grp.Width
  hp_button.NormalImage = NormalImage
  hp_button.FocusImage = FocusImage
  hp_button.PushImage = PushImage
  hp_button.Name = nx_string("btn_hp" .. nx_string(index))
  hp_button.parent_grp_name = nx_string(hp_grp.Name)
  hp_button.hpid = hp_info[HP_ID]
  nx_bind_script(hp_button, nx_current())
  nx_callback(hp_button, "on_click", "on_click_homepoint_btn")
  nx_callback(hp_button, "on_get_capture", "on_homepoint_get_capture")
  nx_callback(hp_button, "on_lost_capture", "on_homepoint_lost_capture")
  local form = nx_value(nx_current())
  nx_set_custom(form, hp_button.Name, hp_button)
  local size = table.getn(hp_info)
  local hire_id, hire_scene, hire_x, hire_y, hire_z
  if HireFix_HomePoint == Type and SHOW_TYPE_KONG_HOMEPOINT ~= show_type then
    hire_id, hire_scene, hire_x, hire_y, hire_z = GetHireFixInfo()
    hp_button.hpid = hire_id
    local text = nx_widestr(gui.TextManager:GetFormatText("ui_poised_location_title", nx_int(hire_x), nx_int(hire_y), nx_int(hire_z)))
    hp_button.des = text
    hp_button.hp_name = hire_id
    hp_button.sceneid = hire_scene
    hp_button.photo = "gui\\map\\HomePoint\\HomePoint007.png"
    hp_button.x = hire_x
    hp_button.y = hire_y
    hp_button.z = hire_z
    hp_button.hp_status = 1
  elseif 0 < size then
    hp_button.hpid = hp_info[HP_ID]
    hp_button.des = hp_info[HP_DES]
    hp_button.hp_name = hp_info[HP_NAME]
    hp_button.sceneid = hp_info[HP_SCENE_NO]
    hp_button.photo = hp_info[HP_PHOTO]
    hp_button.x = hp_info[HP_POS][1]
    hp_button.y = hp_info[HP_POS][2]
    hp_button.z = hp_info[HP_POS][3]
    hp_button.hp_status = 1
  else
    hp_button.hp_status = 2
  end
  hp_button.hp_type = Type
  grp:Add(hp_button)
  if show_type == SHOW_TYPE_KUOCHONG_HOMEPOINT then
    local label_photo = gui:Create("Label")
    label_photo.Left = 10
    label_photo.Top = 8
    label_photo.Width = 24
    label_photo.Height = 14
    label_photo.DrawMode = "FitWindow"
    label_photo.BackImage = nx_string(Hp_KuoChong)
    label_photo.AutoSize = true
    grp:Add(label_photo)
    hp_button.hp_status = 3
  end
  local label_hp_name = gui:Create("Label")
  label_hp_name.Left = 0
  label_hp_name.Top = 6
  label_hp_name.Width = grp.Width
  label_hp_name.Height = 16
  label_hp_name.Font = "font_main"
  label_hp_name.ForeColor = "225,220,197,159"
  label_hp_name.Align = "Center"
  label_hp_name.ClickEvent = true
  label_hp_name.trans_btn = hp_button
  nx_bind_script(label_hp_name, nx_current())
  nx_callback(label_hp_name, "on_click", "on_click_homepoint_label")
  nx_callback(label_hp_name, "on_get_capture", "on_get_capture_label")
  nx_callback(label_hp_name, "on_lost_capture", "on_lost_capture_label")
  if 0 < size then
    label_hp_name.Text = nx_widestr(util_text(hp_info[HP_NAME]))
  end
  if HireFix_HomePoint == Type and SHOW_TYPE_KONG_HOMEPOINT ~= show_type then
    label_hp_name.Text = nx_widestr(util_text(hp_button.hp_name))
  end
  grp:Add(label_hp_name)
  if (show_type == SHOW_TYPE_HOMEPOINT or show_type == SHOW_TYPE_KONG_HOMEPOINT) and Type ~= School_HomePoint or Type == HireJianghu_HomePoint or Type == HireFix_HomePoint then
    local addhp_button = gui:Create("Button")
    addhp_button.DrawMode = "Tile"
    addhp_button.Left = grp.Width - 20
    addhp_button.Top = 5
    addhp_button.Width = 30
    addhp_button.Height = HOMEPOINT_HEIGHT
    addhp_button.Name = nx_string("op_hp" .. nx_string(index))
    addhp_button.AutoSize = true
    if hp_button.hp_status == 2 then
      addhp_button.NormalImage = Btn_add_NormalImage
      addhp_button.FocusImage = Btn_add_FocusImage
      addhp_button.PushImage = Btn_add_PushImage
      addhp_button.hpid = ""
    else
      addhp_button.NormalImage = Btn_Del_NormalImage
      addhp_button.FocusImage = Btn_Del_FocusImage
      addhp_button.PushImage = Btn_Del_PushImage
      addhp_button.hpid = hp_info[HP_ID]
    end
    addhp_button.hp_type = Type
    if HireFix_HomePoint == Type then
      addhp_button.hpid = hire_id
    end
    nx_bind_script(addhp_button, nx_current())
    nx_callback(addhp_button, "on_click", "on_click_op_homepoint_btn")
    grp:Add(addhp_button)
    if nx_string(hp_grp.area_hp) == nx_string(hp_info[HP_ID]) then
      local label_area_flag = gui:Create("Label")
      label_area_flag.Left = 20
      label_area_flag.Top = 6
      label_area_flag.Width = grp.Width
      label_area_flag.Height = 16
      label_area_flag.AutoSize = true
      label_area_flag.BackImage = "gui//map//HomePoint//HomePoint_logo.png"
      label_area_flag.Transparent = false
      nx_bind_script(label_area_flag, nx_current())
      nx_callback(label_area_flag, "on_get_capture", "on_area_get_capture")
      nx_callback(label_area_flag, "on_lost_capture", "on_area_lost_capture")
      grp:Add(label_area_flag)
    end
  elseif SHOW_TYPE_SCENE_HOMEPOINT == show_type and IsExistRecordHomePoint(hp_info[HP_ID]) then
    local label_hp_flag = gui:Create("Label")
    label_hp_flag.Left = 150
    label_hp_flag.Top = 6
    label_hp_flag.Width = grp.Width
    label_hp_flag.Height = 16
    label_hp_flag.AutoSize = true
    label_hp_flag.BackImage = "gui\\common\\checkbutton\\cbtn_3.png"
    label_hp_flag.Transparent = false
    nx_bind_script(label_hp_flag, nx_current())
    nx_callback(label_hp_flag, "on_get_capture", "on_flag_get_capture")
    nx_callback(label_hp_flag, "on_lost_capture", "on_flag_lost_capture")
    grp:Add(label_hp_flag)
  end
  hp_grp:Add(grp)
end
function Create_Scene_HomePoint(hp_grp, index, hp_info)
  create_item_homepoint(hp_grp, index, SHOW_TYPE_SCENE_HOMEPOINT, hp_info[HP_NAME], hp_info[HP_TYPE], hp_info)
end
function Create_Record_HomePoint(hp_grp, index, hp_info)
  create_item_homepoint(hp_grp, index, SHOW_TYPE_HOMEPOINT, hp_info[HP_NAME], hp_info[HP_TYPE], hp_info)
end
function Create_KuoChong_HomePoint(hp_grp, index, Type)
  local hp_info = {}
  create_item_homepoint(hp_grp, index, SHOW_TYPE_KUOCHONG_HOMEPOINT, "kuochong", Type, hp_info)
end
function Create_Kong_HomePoint(hp_grp, index, Type)
  local hp_info = {}
  create_item_homepoint(hp_grp, index, SHOW_TYPE_KONG_HOMEPOINT, "", Type, hp_info)
end
function on_homepoint_msg(msg_type, ...)
  if nx_int(0) == nx_int(msg_type) then
    local hp_type = arg[1]
    local hptype_name = arg[2]
    local hpid = get_type_homepoint(hptype_name)
    if hpid == "" or hpid == nil then
      return
    end
    if not check_home_point(hpid, hp_type) then
      return
    end
    local pic, des, hp_name = get_homepoint_info(hpid)
    if IsSetHomePoint(hp_name) == false then
      return
    end
    send_homepoint_msg_to_server(Add_HomePoint, hpid)
  elseif nx_int(2) == nx_int(msg_type) then
    local hpid = nx_string(arg[1])
    if not check_home_point(hpid) then
      return
    end
    local pic, des, hp_name = get_homepoint_info(hpid)
    if IsSetHomePoint(hp_name) == false then
      return
    end
    send_homepoint_msg_to_server(ItemAdd_HomePoint, hpid)
  elseif nx_int(3) == nx_int(msg_type) then
    local form = nx_value(FORM_HOME_POINT)
    if not nx_is_valid(form) then
      return
    end
    form.hire_time = nx_string(arg[1])
    if nx_int(form.hire_time) <= nx_int(0) then
      form.grp_hire_time.Visible = false
      form.lbl_hire_text.Visible = true
    else
      form.grp_hire_time.Visible = true
      form.lbl_hire_text.Visible = false
    end
    if form.open_by_guide ~= 1 then
      homepoint_timedown_started(form)
    end
    local form_home_point = nx_value("form_home_point")
    if not nx_is_valid(form_home_point) then
      return
    end
    local day = nx_int(form.hire_time / 86400)
    local hour = nx_int(math.mod(form.hire_time, 86400) / 3600)
    local min = nx_int(math.mod(math.mod(form.hire_time, 86400), 3600) / 60)
    form.lbl_hire_day.Text = nx_widestr(day)
    form.lbl_hire_hour.Text = nx_widestr(hour)
    form.lbl_hire_min.Text = nx_widestr(min)
    form_home_point:ShowHomePointList(form, SHOW_TYPE_HIRE_HOMEPOINT)
  end
end
function IsSetHomePoint(hp_name)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_tip_add_homepoint")
  gui.TextManager:Format_AddParam(util_text(hp_name))
  local tip_info = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, tip_info)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
end
function ShowHomePointInfo(form, photo, des, name, scene_id)
  if nx_string(name) == nx_string(nil) or nx_string(name) == "" then
    return
  end
  form.lbl_preview.BackImage = photo
  form.mltbox_info.HtmlText = nx_widestr(util_text(nx_string(des)))
  form.lbl_name.Text = nx_widestr(util_text(name))
  form.lbl_hp_area.BackImage = "gui\\language\\ChineseS\\luojiaodian\\scene_" .. nx_string(scene_id) .. ".png"
  local scene_resource = get_scene_name(scene_id)
  local curscence_res = get_cur_scene_resource()
  if nx_string(curscence_res) == nx_string(scene_resource) then
    form.btn_xunlu.Visible = true
  else
    form.btn_xunlu.Visible = false
  end
end
function InitGuildDomainIDList(domain_info)
  guild_domain_list = util_split_string(domain_info, ",")
end
function IsOwnGuildHomePoint(hp_info)
  if hp_info[HP_TYPE] ~= Guild_HomePoint then
    return true
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local guild_name = client_player:QueryProp("GuildName")
  if guild_name == "" or guild_name == nil then
    return false
  end
  local nCount = table.getn(guild_domain_list)
  if nCount == 0 then
    return false
  end
  for i = 1, nCount do
    if nx_int(guild_domain_list[i]) == nx_int(hp_info[HP_AREA]) then
      return true
    end
  end
  return false
end
function on_homepoint_rec_refresh(form, recordname, optype, row, clomn)
  if optype == "update" or optype == "del" or optype == "int" or optype == "add" then
    local form_home_point = nx_value("form_home_point")
    if not nx_is_valid(form_home_point) then
      return
    end
    form_home_point:ShowHomePointList(form, SHOW_TYPE_HOMEPOINT)
  end
end
function refresh_relive(form, prop_name, prop_type, prop_value)
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  form_home_point:ShowHomePointList(form, SHOW_TYPE_HOMEPOINT)
  local rc, hpid = getReturnCityName()
  if nx_string(nil) == nx_string(hpid) or nx_string(hpid) == nx_string("") or nx_string(hpid) == nx_string("nil") then
    return
  end
  local pic, des, hp_name, sceneid = get_homepoint_info(hpid)
  ShowHomePointInfo(form, pic, des, hp_name, sceneid)
end
function fresh_hp_btn(hp_grp, show_type)
  if not nx_is_valid(hp_grp) then
    return
  end
  local nCount = (nx_int(show_type) == nx_int(SHOW_TYPE_HOMEPOINT) or nx_int(show_type) == nx_int(SHOW_TYPE_HIRE_HOMEPOINT)) and hp_grp.record_count or hp_grp.scene_count
  for i = 0, nCount do
    local grp = hp_grp:Find("grp" .. nx_string(i))
    if nx_is_valid(grp) then
      local hp_btn = grp:Find("btn_hp" .. nx_string(i))
      if nx_is_valid(hp_btn) then
        hp_btn.NormalImage = NormalImage
        hp_btn.FocusImage = FocusImage
      end
    end
  end
end
function init_select_btn(form)
  local hp_grp = form.hp_grp
  local show_type = form.show_type
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  if not nx_is_valid(hp_grp) then
    return
  end
  if show_type == SHOW_TYPE_HOMEPOINT then
    local nCount = hp_grp.record_count
    local sel_hp = form_home_point.SelectHp
    for i = 0, nCount do
      local grp = hp_grp:Find("grp" .. nx_string(i))
      if nx_is_valid(grp) then
        local hp_btn = grp:Find("btn_hp" .. nx_string(i))
        if nx_is_valid(hp_btn) and hp_btn.hp_status == 1 and (nx_string(hp_btn.hpid) == nx_string(sel_hp) or nx_string("") == nx_string(sel_hp) or sel_hp == nil) then
          hp_btn.NormalImage = SelHomePoint
          hp_btn.FocusImage = SelHomePoint
          local hpinfo = form_home_point:GetHomePointInfo(hp_btn.hpid)
          local photo = hpinfo[HP_PHOTO]
          local des = hpinfo[HP_DES]
          local hp_name = hpinfo[HP_NAME]
          form.hp_name = hp_name
          form.hp_type = hpinfo[HP_TYPE]
          ShowHomePointInfo(form, photo, des, hp_name, hpinfo[HP_SCENE_NO])
          return
        end
      end
    end
  elseif show_type == SHOW_TYPE_HIRE_HOMEPOINT then
    local sel_hp = form_home_point.SelectHp
    for i = 0, hp_grp.record_count do
      local grp = hp_grp:Find("grp" .. nx_string(i))
      if nx_is_valid(grp) then
        local hp_btn = grp:Find("btn_hp" .. nx_string(i))
        if nx_is_valid(hp_btn) and hp_btn.hp_status == 1 and (nx_string(hp_btn.hpid) == nx_string(sel_hp) or nx_string("") == nx_string(sel_hp) or sel_hp == nil) then
          hp_btn.NormalImage = SelHomePoint
          hp_btn.FocusImage = SelHomePoint
          local hpinfo = form_home_point:GetHomePointInfo(hp_btn.hpid)
          local photo = hpinfo[HP_PHOTO]
          local des = hpinfo[HP_DES]
          local hp_name = hpinfo[HP_NAME]
          form.hp_name = hp_name
          form.hp_type = hpinfo[HP_TYPE]
          ShowHomePointInfo(form, photo, des, hp_name, hpinfo[HP_SCENE_NO])
        end
      end
    end
  else
    local grp = hp_grp:Find("grp0")
    if nx_is_valid(grp) then
      local hp_btn = grp:Find("btn_hp0")
      if nx_is_valid(hp_btn) and hp_btn.hp_status == 1 then
        hp_btn.NormalImage = SelHomePoint
        hp_btn.FocusImage = SelHomePoint
        local hpinfo = form_home_point:GetHomePointInfo(hp_btn.hpid)
        local photo = hpinfo[HP_PHOTO]
        local des = hpinfo[HP_DES]
        local hp_name = hpinfo[HP_NAME]
        form.hp_name = hp_name
        form.hp_type = hpinfo[HP_TYPE]
        ShowHomePointInfo(form, photo, des, hp_name, hpinfo[HP_SCENE_NO])
      end
    end
  end
end
function getReturnCityName()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  local relive_positon_name = "RelivePositon"
  if form_home_point:IsNewTerritoryType() then
    relive_positon_name = "DongHaiRelivePositon"
  end
  if not client_player:FindProp(relive_positon_name) then
    return ""
  end
  local rl_pos_info = client_player:QueryProp(relive_positon_name)
  local relive_lst = nx_function("ext_split_string", rl_pos_info, ",")
  return nx_widestr(util_text(nx_string(relive_lst[6]))), nx_string(relive_lst[7])
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function get_cur_scene_resource()
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local scene = client:GetScene()
  if not nx_is_valid(scene) then
    return
  end
  return scene:QueryProp("Resource")
end
function on_rbtn_hire_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  if form_home_point:IsNewTerritoryType() then
    form.rbtn_hire.Enabled = false
    form.rbtn_hire.Visible = false
    return
  else
    form.rbtn_hire.Enabled = true
    form.rbtn_hire.Visible = true
  end
  form_home_point:ShowHomePointList(form, SHOW_TYPE_HIRE_HOMEPOINT)
  if nx_int(form.hire_time) <= nx_int(0) then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local text = nx_widestr(gui.TextManager:GetFormatText("ui_extern_fengshui", nx_int(GetHirePrice())))
    if ShowTipDialog(nx_widestr(text)) ~= true then
      return
    end
    send_homepoint_msg_to_server(BUY_HIRE_TIME)
  else
    local day = nx_int(form.hire_time / 86400)
    local hour = nx_int(math.mod(form.hire_time, 86400) / 3600)
    local min = nx_int(math.mod(math.mod(form.hire_time, 86400), 3600) / 60)
    form.lbl_hire_day.Text = nx_widestr(day)
    form.lbl_hire_hour.Text = nx_widestr(hour)
    form.lbl_hire_min.Text = nx_widestr(min)
  end
end
function GetExistHomePointCount(Type)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return
  end
  local record_name = HomePointList
  if form_home_point:IsNewTerritoryType() then
    record_name = "DongHaiHomePointList"
  end
  local nCount = client_player:GetRecordRows(record_name)
  local nTypeCount = 0
  for i = 0, nCount - 1 do
    local nCurType = client_player:QueryRecord(record_name, i, 1)
    local sel_type = get_hp_type(Type)
    local hp_type = get_hp_type(nCurType)
    if nx_int(sel_type) == nx_int(hp_type) then
      nTypeCount = nTypeCount + 1
    end
  end
  for i = 0, client_player:GetRecordRows("HireHomePointList") - 1 do
    local nCurType = client_player:QueryRecord("HireHomePointList", i, 1)
    local sel_type = get_hp_type(Type)
    local hp_type = get_hp_type(nCurType)
    if nx_int(sel_type) == nx_int(hp_type) then
      nTypeCount = nTypeCount + 1
    end
  end
  return nTypeCount
end
function GetHireJianghuCount()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local jianghu_num = 0
  for i = 0, client_player:GetRecordRows("HireHomePointList") - 1 do
    local hp_pos = client_player:QueryRecord("HireHomePointList", i, 3)
    if nx_string(hp_pos) == "" then
      jianghu_num = jianghu_num + 1
    end
  end
  return jianghu_num
end
function GetHireJianghuMaxCount()
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\HireHomePoint.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex("property")
  if index < 0 then
    return 0
  end
  return ini:ReadInteger(index, "hire_jianghu_max", 0)
end
function GetHirePrice()
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\HireHomePoint.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex("property")
  if index < 0 then
    return 0
  end
  return ini:ReadInteger(index, "silver_price", 0)
end
function IsHireJianghu(hp_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local row = client_player:FindRecordRow("HireHomePointList", 0, nx_string(hp_id))
  if 0 <= row then
    local hp_pos = client_player:QueryRecord("HireHomePointList", row, 3)
    if nx_string(hp_pos) == "" then
      return true
    end
  end
  return false
end
function on_homepoint_hire_rec_refresh(form, recordname, optype, row, clomn)
  if optype == "update" or optype == "del" or optype == "int" or optype == "add" then
    local form_home_point = nx_value("form_home_point")
    if not nx_is_valid(form_home_point) then
      return
    end
    form_home_point:ShowHomePointList(form, SHOW_TYPE_HIRE_HOMEPOINT)
  end
end
function ShowHireRecordHomePoint(hp_grp, Type)
  if not nx_is_valid(hp_grp) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local TypeCount = 0
  local nCount = client_player:GetRecordRows("HireHomePointList")
  add_title_homepoint(hp_grp, hp_grp.record_count, Type)
  if nx_int(nCount) > nx_int(0) then
    for index = 0, nCount - 1 do
      local hp_id = client_player:QueryRecord("HireHomePointList", index, 0)
      local hp_pos = client_player:QueryRecord("HireHomePointList", index, 3)
      local bRet, hp_info = GetHomePointFromHPid(hp_id)
      if Type == HireJianghu_HomePoint and nx_string(hp_pos) == "" then
        if bRet == true then
          local hp_type = (hp_info[HP_TYPE] == 0 or hp_info[HP_TYPE] == 1) and JiangHu_HomePoint or hp_info[HP_TYPE]
          if hp_type == JiangHu_HomePoint then
            Create_Record_HomePoint(hp_grp, hp_grp.record_count, hp_info)
            hp_grp.record_count = hp_grp.record_count + 1
            TypeCount = TypeCount + 1
          end
        end
      elseif Type == HireFix_HomePoint and nx_string(hp_pos) ~= "" then
        local hp_info = {}
        Create_HireFix_HomePoint(hp_grp, hp_grp.record_count, hp_info)
        hp_grp.record_count = hp_grp.record_count + 1
        TypeCount = TypeCount + 1
      end
    end
  end
  local MaxTypeCount = GetTypeHomePointCount(Type)
  local kongCount = MaxTypeCount - TypeCount
  if kongCount <= 0 then
    return
  end
  for i = 1, kongCount do
    Create_Kong_HomePoint(hp_grp, hp_grp.record_count, Type)
    hp_grp.record_count = hp_grp.record_count + 1
  end
end
function Create_HireFix_HomePoint(hp_grp, index, hp_info)
  create_item_homepoint(hp_grp, index, SHOW_TYPE_HIRE_HOMEPOINT, "Fix", HireFix_HomePoint, hp_info)
end
function GetHireFixInfo()
  local hp_id, hp_scene, hp_x, hp_y, hp_z
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local nCount = client_player:GetRecordRows("HireHomePointList")
  for i = 0, nCount - 1 do
    local hp_pos = client_player:QueryRecord("HireHomePointList", i, 3)
    if nx_string(hp_pos) ~= "" then
      hp_id = client_player:QueryRecord("HireHomePointList", i, 0)
      local pos = util_split_string(nx_string(hp_pos), ";")
      hp_scene = nx_int(pos[1])
      hp_x = nx_int(pos[2])
      hp_y = nx_int(pos[3])
      hp_z = nx_int(pos[4])
      return hp_id, hp_scene, hp_x, hp_y, hp_z
    end
  end
end
function on_update_hire_timedown(form)
  if nx_int(form.hire_time) <= nx_int(0) then
    form.grp_hire_time.Visible = false
    form.lbl_hire_text.Visible = true
    reset_hire_timedown(form)
    return
  end
  form.lbl_hire_text.Visible = false
  local day = nx_int(form.hire_time / 86400)
  local hour = nx_int(math.mod(form.hire_time, 86400) / 3600)
  local min = nx_int(math.mod(math.mod(form.hire_time, 86400), 3600) / 60)
  form.lbl_hire_day.Text = nx_widestr(day)
  form.lbl_hire_hour.Text = nx_widestr(hour)
  form.lbl_hire_min.Text = nx_widestr(min)
  form.hire_time = form.hire_time - 1
end
function reset_hire_timedown(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_hire_timedown", form)
  end
  form.hire_time = 0
end
function check_home_point(hpid, hp_type)
  if hp_type ~= nil and nx_int(hp_type) == nx_int(HireFix_HomePoint) then
    return true
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local form_home_point = nx_value("form_home_point")
  if not nx_is_valid(form_home_point) then
    return false
  end
  local hp_info = form_home_point:GetHomePointInfo(hpid)
  local hp_territory_type = hp_info[HP_TERRITORY_TYPE]
  local hp_comp_type = hp_info[HP_COMP_TYPE]
  local territory_type = form_home_point:GetTerritoryType()
  local comp_type = client_player:QueryProp("NewTerritoryCampIndex")
  if territory_type ~= hp_territory_type then
    return false
  end
  if 0 ~= hp_comp_type and comp_type ~= hp_comp_type then
    return false
  end
  return true
end
