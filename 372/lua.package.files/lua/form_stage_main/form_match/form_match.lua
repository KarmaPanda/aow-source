require("form_stage_main\\form_match\\form_revenge_function")
require("form_stage_main\\form_match\\form_manyrevenge_function")
require("util_functions")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
require("form_stage_main\\form_huashan\\huashan_define")
require("form_stage_main\\switch\\url_define")
local CTS_Apply = 0
local CTS_OpenForm = 1
local CTS_QuerySelf = 2
local CTS_QueryRank = 3
local CTS_QueryPlayer = 4
local CTS_QueryApply = 5
local CTS_QueryApplyRec = 7
local STC_OpenForm = 0
local STC_QuerySelf = 1
local STC_QueryRank = 2
local STC_QueryPlayer = 3
local STC_QueryApplyRec = 4
local MT_Day = 1
local MT_Week = 2
local school_To_week_mt = {
  school_jinyiwei = 3,
  school_gaibang = 4,
  school_junzitang = 5,
  school_jilegu = 6,
  school_tangmen = 7,
  school_emei = 8,
  school_wudang = 9,
  school_shaolin = 10,
  school_wumenpai = 12,
  newschool_xuedao = 3,
  newschool_changfeng = 4,
  newschool_huashan = 5,
  newschool_wuxian = 6,
  newschool_nianluo = 7,
  newschool_shenshui = 8,
  newschool_gumu = 9,
  newschool_damo = 10
}
local Mt_School_Month = 11
local MP_Close = 0
local MP_ApplyStart = 1
local MP_ApplyEnd = 2
local MP_Prepare = 3
local MP_Fight = 4
local match_iPhase = {
  [0] = "ui_match_Close",
  [1] = "ui_match_ApplyStart",
  [2] = "ui_match_ApplyEnd",
  [3] = "ui_Prepare",
  [4] = "ui_match_Fight"
}
local MDC_CTS_QueryWinAndLostNum = 7
local m_AllowNum = 4
local m_Max = 199
local grop_box_old
function main_form_init(form)
  form.Fixed = true
  form.LimitInScreen = true
  form.match_type = MT_Day
end
function on_match_main_form(...)
  local msgtype = arg[1]
  if msgtype == STC_OpenForm then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_match\\form_match", true, false)
    if not nx_is_valid(form) then
      return false
    end
    local match_type = form.match_type
    local iApply = arg[4]
    local AppType = arg[2]
    if AppType == MT_Week and iApply == 1 then
      form.lbl_week_ruxuan.Text = nx_widestr("@ui_match_interface03")
    elseif iApply == 0 then
      form.lbl_week_ruxuan.Text = nx_widestr("@ui_match_weiruwei")
    end
    local iPhase = arg[3]
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    if iPhase < 3 and (AppType == 2 or AppType == 11) then
      iPhase = 0
    end
    gui.TextManager:Format_SetIDName(match_iPhase[iPhase])
    if iPhase == MP_Fight then
      local iWheel = arg[5]
      gui.TextManager:Format_AddParam(nx_int(iWheel))
    end
    form.mltbox_iPhase.HtmlText = nx_widestr("<center>") .. nx_widestr(gui.TextManager:Format_GetText()) .. nx_widestr("</center>")
  end
end
function on_main_form_open(form)
  nx_execute("custom_sender", "custom_game_match", CTS_OpenForm, MT_Day)
  form.groupbox_match_week.Visible = false
  form.groupbox_match_day.Visible = false
  grop_box_old = nil
  if nx_is_valid(form.matchType1) then
    form.matchType = form.matchType1
  else
    form.matchType = MT_Day
  end
  form.fresh_time = os.time()
  form.revenge_join_row = -1
  form.revenge_join_state = 0
  form.btn_room.msgid = 0
  form.btn_match.msgid = 2
  form.btn_match.Enabled = true
  form.manyrevenge_join_row = -1
  form.btn_room_2.state = ""
  form.btn_room_1.state = ""
  Init_TreeView(form)
  nx_execute("form_stage_main\\form_huashan\\form_huashan_lj_msg", "now_month_ishave_huashan", form)
  send_msg_query_num()
end
function send_msg_query_num(...)
  arg[1] = nx_int(14)
  arg[2] = nx_int(17)
  arg[3] = nx_int(114)
  arg[4] = nx_int(115)
  nx_execute("custom_sender", "custom_query_match_data", MDC_CTS_QueryWinAndLostNum, unpack(arg))
end
function open_form(nType)
  local form = nx_value("form_stage_main\\form_match\\form_match")
  form = util_get_form("form_stage_main\\form_match\\form_match", true)
  if not nx_is_valid(form) then
    return
  end
  form.matchType1 = nType
  return form
end
function Init_TreeView(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ini_doc = get_ini("ini\\ui\\match\\match.ini")
  if nx_is_null(ini_doc) then
    nx_msgbox("ini\229\138\160\232\189\189\229\164\177\232\180\165")
    return false
  end
  local NodeCount = 0
  local selectNode
  local map_root = form.tree_job:CreateRootNode(nx_widestr("@match_root"))
  map_root.search_id = "match_root"
  local count_node1 = ini_doc:GetSectionCount()
  for i = 0, count_node1 - 1 do
    local name_nodeid1 = ini_doc:GetSectionByIndex(i)
    local name_node1 = nx_widestr("   ") .. gui.TextManager:GetFormatText(name_nodeid1)
    if nx_ws_equal(name_node1, nx_widestr("")) then
      return
    end
    local map_node1 = map_root:CreateNode(nx_widestr(""))
    map_node1.search_id = name_nodeid1
    map_node1.back_image_id = i + 1
    set_main_node_style(map_node1)
    local count_node2 = ini_doc:GetSectionItemCount(i)
    for j = 0, count_node2 - 1 do
      local infos = ini_doc:GetSectionItemValue(i, j)
      local info_list = util_split_string(infos, nx_string(","))
      local nCount = table.getn(info_list)
      if nCount < 2 then
        return
      end
      local name_nodeid2 = info_list[1]
      local name_node2 = nx_widestr("   ") .. gui.TextManager:GetFormatText(info_list[2])
      if nx_ws_equal(name_node2, nx_widestr("")) then
        return
      end
      local map_node2 = map_node1:CreateNode(name_node2)
      map_node2.search_id = name_nodeid2
      if name_nodeid2 == "3" then
        map_node2.search_id = get_school()
      end
      if name_nodeid2 == "4" then
        map_node2.search_id = 11
      end
      map_node2.search_name = info_list[3]
      if nx_string(13) == name_nodeid2 then
        selectNode = map_node2
      end
      set_sub_node_style(map_node2)
    end
  end
  form.tree_job.SelectNode = selectNode
  form.tree_job.Width = 205
  map_root:ExpandAll()
  if form.tree_job.VScrollBar.Visible == false then
    form.tree_job.Width = 184
  end
end
function on_main_form_close(form)
  grop_box_old = nil
  form.matchType = MT_Day
  nx_execute("form_stage_main\\form_match\\form_match_rank", "CaneClearArry")
  nx_destroy(form)
end
function close_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
    local general_main = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_general_info\\form_general_info_main", false, true)
    if nx_is_valid(general_main) then
      general_main:Close()
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_tree_job_select_changed(treeView)
  local form = treeView.ParentForm
  if form.tree_job.VScrollBar.Visible == false then
    form.tree_job.Width = 184
  end
  if form.tree_job.VScrollBar.Visible == true then
    form.tree_job.Width = 205
  end
  local node = treeView.SelectNode
  local node_list = node:GetNodeList()
  local node_count = node:GetNodeCount()
  if 0 < node_count then
    return
  end
  local grop_box = form:Find(nx_string("groupbox_") .. nx_string(node.search_name))
  if not nx_is_valid(grop_box) then
    return
  end
  if grop_box_old ~= nil then
    if grop_box.Name ~= grop_box_old.Name then
      grop_box_old.Visible = false
      grop_box.Visible = true
      grop_box_old = grop_box
    end
  else
    grop_box.Visible = true
    grop_box_old = grop_box
  end
  form.matchType = nx_int(node.search_id)
  form.mltbox_iPhase.HtmlText = nx_widestr("")
  if form.matchType == 13 then
    nx_execute("custom_sender", "custom_revenge_match", 5)
    nx_execute("form_stage_main\\form_match\\form_revenge_function", "init_form_grid", form)
    local player = get_player()
    if nx_is_valid(player) then
      form.lbl_24.Text = nx_widestr(player:QueryProp("SkillIntegral"))
    end
  elseif form.matchType == 23 then
    check_join_state(form)
    local player = get_player()
    if not player:FindProp("TeamID") then
      form.btn_room_1.Enabled = false
      form.btn_match_1.Enabled = false
    end
    local LeaderName = player:QueryProp("TeamCaptain")
    local RoleName = player:QueryProp("Name")
    if player:FindRecord("team_rec") then
      local row = player:GetRecordRows("team_rec")
      if nx_number(row) < 2 or nx_string(RoleName) ~= nx_string(LeaderName) then
        form.btn_room_1.Enabled = false
        form.btn_match_1.Enabled = false
      end
    end
  elseif form.matchType == 24 then
    nx_execute("custom_sender", "custom_manyrevenge_match", 2, 1)
    check_join_state(form)
    local player = get_player()
    if not player:FindProp("TeamID") then
      form.btn_room_2.Enabled = false
      form.btn_match_2.Enabled = false
    end
    local LeaderName = player:QueryProp("TeamCaptain")
    local RoleName = player:QueryProp("Name")
    if player:FindRecord("team_rec") then
      local row = player:GetRecordRows("team_rec")
      if nx_number(row) < 2 or nx_string(RoleName) ~= nx_string(LeaderName) then
        form.btn_room_2.Enabled = false
        form.btn_match_2.Enabled = false
      end
    end
    form.lbl_24_2.Text = nx_widestr(player:QueryProp("RevengeFriendly"))
    nx_execute("form_stage_main\\form_match\\form_manyrevenge_function", "init_form_textgrid", form)
  elseif form.matchType == 99 then
    set_my_lj_msg(form)
    init_hslj_text(form)
  elseif form.matchType ~= 0 then
    nx_execute("custom_sender", "custom_game_match", CTS_OpenForm, nx_int(form.matchType))
  end
  if "revenge_match" == nx_string(node.search_name) or "match_hslj" == nx_string(node.search_name) or "revenge_match_1" == nx_string(node.search_name) or "revenge_match_2" == nx_string(node.search_name) then
    form.groupbox_2.Visible = false
    form.mltbox_iPhase.Visible = false
  else
    form.groupbox_2.Visible = true
    form.mltbox_iPhase.Visible = true
  end
end
function set_main_node_style(node)
  node.Font = "font_btn"
  node.TextOffsetX = 10
  node.TextOffsetY = 11
  node.ItemHeight = 38
  if node.back_image_id == 1 then
    node.NodeBackImage = "gui\\language\\ChineseS\\tianti\\ttlt.png"
    node.NodeFocusImage = "gui\\language\\ChineseS\\tianti\\ttlt.png"
    node.NodeSelectImage = "gui\\language\\ChineseS\\tianti\\ttlt.png"
  elseif node.back_image_id == 2 then
    node.NodeBackImage = "gui\\language\\ChineseS\\tianti\\hslj.png"
    node.NodeFocusImage = "gui\\language\\ChineseS\\tianti\\hslj.png"
    node.NodeSelectImage = "gui\\language\\ChineseS\\tianti\\hslj.png"
  end
  node.ExpandCloseOffsetX = 133
  node.ExpandCloseOffsetY = 9
  node.NodeOffsetY = 3
end
function set_sub_node_style(node)
  node.Font = "font_text"
  node.TextOffsetX = 10
  node.TextOffsetY = 5
  node.NodeImageOffsetX = 30
  node.ItemHeight = 28
  node.NodeBackImage = "gui\\special\\tianti\\strength\\btn_left_out.png"
  node.NodeFocusImage = "gui\\special\\tianti\\strength\\btn_left_on.png"
  node.NodeSelectImage = "gui\\special\\tianti\\strength\\btn_left_down.png"
end
function get_treeview_bg(bgtype)
  local path = "gui\\special\\match\\fb_paging_" .. nx_string(bgtype) .. ".png"
  return nx_string(path)
end
function get_treeview_bg11(bgtype)
  local path = "gui\\special\\match\\btn1_" .. nx_string(bgtype) .. ".png"
  return nx_string(path)
end
function on_btn_day_info_click(btn)
  local form = nx_value("form_stage_main\\form_match\\form_match_info")
  if not nx_is_valid(form) then
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, MT_Day, 0)
  else
    form:Close()
    if nx_is_valid(form) then
      nx_destroy(form)
    end
  end
end
function on_btn_week_info_click(btn)
  local form = nx_value("form_stage_main\\form_match\\form_match_info")
  if not nx_is_valid(form) then
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, MT_Week, 0)
  else
    form:Close()
    if nx_is_valid(form) then
      nx_destroy(form)
    end
  end
end
function on_btn_day_info_31_click(btn)
  local form = nx_value("form_stage_main\\form_match\\form_match_info")
  if not nx_is_valid(form) then
    local Mt_School_Week = get_school()
    if Mt_School_Week == 0 then
      return
    end
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, Mt_School_Week, 0)
  else
    form:Close()
    if nx_is_valid(form) then
      nx_destroy(form)
    end
  end
end
function on_btn_day_info_32_click(btn)
  local form = nx_value("form_stage_main\\form_match\\form_match_info")
  if not nx_is_valid(form) then
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, Mt_School_Month, 0)
  else
    form:Close()
    if nx_is_valid(form) then
      nx_destroy(form)
    end
  end
end
function on_btn_day_rank_click(btn)
  local form = nx_value("form_stage_main\\form_match\\form_match_rank")
  if nx_is_valid(form) then
    local ui_type = form.stc_type
    form:Close()
    if nx_is_valid(form) then
      nx_destroy(form)
    end
    if CTS_QueryRank == ui_type then
      return
    end
  end
  nx_execute("custom_sender", "custom_game_match", CTS_QueryRank, MT_Day)
end
function on_btn_week_rank_click(btn)
  local form = nx_value("form_stage_main\\form_match\\form_match_rank")
  if nx_is_valid(form) then
    local ui_type = form.stc_type
    form:Close()
    if nx_is_valid(form) then
      nx_destroy(form)
    end
    if CTS_QueryRank == ui_type then
      return
    end
  end
  nx_execute("custom_sender", "custom_game_match", CTS_QueryRank, MT_Week)
end
function on_btn_day_rank_31_click(btn)
  local form = nx_value("form_stage_main\\form_match\\form_match_rank")
  if nx_is_valid(form) then
    local ui_type = form.stc_type
    form:Close()
    if nx_is_valid(form) then
      nx_destroy(form)
    end
    if CTS_QueryRank == ui_type then
      return
    end
  end
  local Mt_School_Week = get_school()
  if Mt_School_Week == 0 then
    return
  end
  nx_execute("custom_sender", "custom_game_match", CTS_QueryRank, Mt_School_Week)
end
function on_btn_day_rank_32_click(btn)
  local form = nx_value("form_stage_main\\form_match\\form_match_rank")
  if nx_is_valid(form) then
    local ui_type = form.stc_type
    form:Close()
    if nx_is_valid(form) then
      nx_destroy(form)
    end
    if CTS_QueryRank == ui_type then
      return
    end
  end
  local Mt_School_Week = get_school()
  if Mt_School_Week == 0 then
    return
  end
  nx_execute("custom_sender", "custom_game_match", CTS_QueryRank, Mt_School_Month)
end
function on_btn_apply_click(btn)
  nx_execute("custom_sender", "custom_game_match", CTS_Apply, MT_Day)
end
function on_btn_apply_31_click(btn)
  local Mt_School_Week = get_school()
  if Mt_School_Week == 0 then
    return
  end
  nx_execute("custom_sender", "custom_game_match", CTS_Apply, Mt_School_Week)
end
function get_node(root, id)
  if not nx_is_valid(root) then
    return nx_null()
  end
  if nx_string(root.search_id) == nx_string(id) then
    return root
  end
  local node_list = root:GetNodeList()
  local node_count = root:GetNodeCount()
  for i = 1, node_count do
    local node = get_node(node_list[i], id)
    if nx_is_valid(node) then
      return node
    end
  end
  return nx_null()
end
function on_btn_rule_info_click(btn)
  local form = nx_value("form_stage_main\\form_match\\form_match_rule_info")
  if nx_is_valid(form) then
    form:Close()
    return
  end
  form = util_get_form("form_stage_main\\form_match\\form_match_rule_info", true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  if btn.Name == "btn_jianghu_day_match_rule" then
    form.mltbox_1.HtmlText = nx_widestr("@ui_match_rule_day")
  elseif btn.Name == "btn_jianghu_week_match_rule" then
    form.mltbox_1.HtmlText = nx_widestr("@ui_match_rule_week")
  elseif btn.Name == "btn_school_week_match_rule" then
    form.mltbox_1.HtmlText = nx_widestr("@ui_school_match_week_rule")
  elseif btn.Name == "btn_school_month_match_rule" then
    form.mltbox_1.HtmlText = nx_widestr("@ui_school_match_month_rule")
  end
end
function on_btn_find_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = nx_widestr(form.ipt_1.Text)
  local fresh_time = os.time()
  local time = os.difftime(fresh_time, form.fresh_time)
  if 3 < time then
    nx_execute("custom_sender", "custom_game_match", CTS_QueryApply, form.matchType, name)
    form.fresh_time = fresh_time
  end
end
function get_school()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local playerschool = client_player:QueryProp("School")
  local playerlastschool = client_player:QueryProp("LastSchool")
  local lastschooltype = client_player:QueryProp("LeaveSchoolType")
  local playernewschool = client_player:QueryProp("NewSchool")
  if string.len(playerschool) < 5 and string.len(playernewschool) >= 5 then
    playerschool = playernewschool
  end
  if string.len(playerschool) < 5 and string.len(playerlastschool) < 5 then
    return 12
  end
  if string.len(playerschool) < 5 and nx_int(lastschooltype) == nx_int(1) then
    return 12
  end
  if string.len(playerschool) < 5 then
    playerschool = playerlastschool
  end
  return school_To_week_mt[nx_string(playerschool)]
end
function on_btn_show_jh_week_click(btn)
  local form = nx_value("form_stage_main\\form_match\\form_match_rank")
  if nx_is_valid(form) then
    local ui_type = form.stc_type
    form:Close()
    if nx_is_valid(form) then
      nx_destroy(form)
    end
    if CTS_QueryApplyRec == ui_type then
      return
    end
  end
  nx_execute("custom_sender", "custom_game_match", CTS_QueryApplyRec, MT_Week)
end
function on_btn_show_school_month_click(btn)
  local form = nx_value("form_stage_main\\form_match\\form_match_rank")
  if nx_is_valid(form) then
    local ui_type = form.stc_type
    form:Close()
    if nx_is_valid(form) then
      nx_destroy(form)
    end
    if CTS_QueryApplyRec == ui_type then
      return
    end
  end
  nx_execute("custom_sender", "custom_game_match", CTS_QueryApplyRec, Mt_School_Month)
end
function on_btn_wycx_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  switch_manager:OpenUrl(URL_TYPE_REVENGE_URL)
end
function on_server_msg_revenge(msgid, ...)
  if 1 == msgid then
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    fresh_form_grid(form, unpack(arg))
  elseif 0 == msgid then
    nx_execute("form_stage_main\\form_match\\form_revenge_fight_msg", "fresh_fight_msg", unpack(arg))
  elseif 2 == msgid then
    nx_execute("form_stage_main\\form_match\\form_revenge_fight_msg", "fresh_fight_state", unpack(arg))
  elseif 3 == msgid then
    nx_execute("form_stage_main\\form_match\\form_revenge_sub_end", "open_form", unpack(arg))
  elseif 4 == msgid then
    nx_execute("form_stage_main\\form_match\\form_revenge_all_end", "open_form", unpack(arg))
  elseif 5 == msgid then
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    fresh_join_times(form, unpack(arg))
  elseif 6 == msgid then
    nx_execute("form_stage_main\\form_match\\form_revenge_ttyd", "open_form", form, unpack(arg))
  elseif 100 == msgid then
  end
end
function on_textgrid_room_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
end
function on_btn_room_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local check_taolu = nx_execute("form_stage_main\\form_match\\form_taolu_pick", "CheckTaolu")
  if check_taolu == false then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1000282"))
  end
  local roomname = ""
  if btn.msgid == 0 then
    if form.textgrid_room.RowSelectIndex == -1 then
      return
    end
    roomname = nx_string(form.textgrid_room:GetGridText(form.textgrid_room.RowSelectIndex, 0))
  elseif btn.msgid == 1 then
    if form.revenge_join_row == -1 then
      return
    end
    roomname = nx_string(form.textgrid_room:GetGridText(form.revenge_join_row, 0))
  else
    return
  end
  nx_execute("custom_sender", "custom_revenge_match", btn.msgid, roomname)
end
function on_btn_match_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local roomname = nx_string(form.textgrid_room:GetGridText(form.revenge_join_row, 0))
  nx_execute("custom_sender", "custom_revenge_match", btn.msgid, roomname)
end
function on_btn_target_click(btn)
  local fight_msg = nx_value("form_stage_main\\form_match\\form_revenge_fight_msg")
  if nx_is_valid(fight_msg) then
    fight_msg.Visible = not fight_msg.Visible
  end
end
function on_server_msg_manyrevenge(subid, ...)
  if 0 == subid then
    nx_execute("form_stage_main\\form_match\\form_manyrevenge_function", "fresh_group_info", unpack(arg))
  elseif 1 == subid then
    nx_execute("form_stage_main\\form_tvt_fight_reason", "save_serve_tvt_msg", unpack(arg))
  elseif 2 == subid then
    nx_execute("form_stage_main\\form_tvt_fight_reason", "fresh_state_msg", unpack(arg))
  end
end
function on_btn_room_1_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("custom_sender", "custom_manyrevenge_match", 0, 2)
    form.btn_match_1.Text = nx_widestr("@ui_revenge_quit")
    form.btn_room_1.Enabled = false
    form.btn_match_1.Enabled = true
  end
end
function on_btn_match_1_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("custom_sender", "custom_manyrevenge_match", 1, 2)
    form.btn_room_1.Enabled = true
    form.btn_match_1.Enabled = false
  end
end
function on_btn_room_2_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("custom_sender", "custom_manyrevenge_match", 0, 1)
    form.btn_match_2.Text = nx_widestr("@ui_revenge_quit")
    form.btn_room_2.Enabled = false
    form.btn_match_2.Enabled = true
  end
end
function on_btn_match_2_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("custom_sender", "custom_manyrevenge_match", 1, 1)
    form.btn_match_2.Enabled = false
    form.btn_room_2.Enabled = true
  end
end
function check_join_state(form)
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local state1 = player:QueryProp("MatchTeamCapUid")
  if state1 == 0 or state1 == "" then
    form.btn_room_1.Enabled = true
    form.btn_match_1.Enabled = false
    form.btn_room_2.Enabled = true
    form.btn_match_2.Enabled = false
  else
    form.btn_room_1.Enabled = false
    form.btn_match_1.Enabled = true
    form.btn_room_2.Enabled = false
    form.btn_match_2.Enabled = true
  end
end
function on_btn_phb_click(btn)
  local form_rank_path = "form_stage_main\\form_rank\\form_rank_main"
  local form_rank = nx_value(form_rank_path)
  if not nx_is_valid(form_rank) then
    form_rank = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_rank\\form_rank_main", true, false)
  end
  if not nx_is_valid(form_rank) then
    return
  end
  form_rank:Show()
  form_rank.Visible = true
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", form_rank, "rank_8_huashanlunjian")
end
function set_my_lj_msg(form)
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local playername = client_player:QueryProp("Name")
  local point = client_player:QueryProp("HuaShanPoint")
  form.lbl_name.Text = nx_widestr(playername)
  form.lbl_point.Text = nx_widestr(nx_string(point))
  nx_execute("custom_sender", "custom_request_huashan", nx_int(HuaShanCToS_GetRankNo))
end
function on_server_msg(...)
  if HuaShanSToC_GetRankNo ~= arg[1] then
    return
  end
  local form = nx_value("form_stage_main\\form_match\\form_match")
  if not nx_is_valid(form) then
    return
  end
  local rankno = nx_number(arg[2])
  local text = ""
  if rankno <= 0 or 32 < rankno then
    text = ">32"
  else
    text = nx_string(rankno)
  end
  form.lbl_paiming.Text = nx_widestr(text)
end
function init_hslj_text(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if form.nowmonthday > 0 then
    gui.TextManager:Format_SetIDName("ui_huashan_open")
    gui.TextManager:Format_AddParam(nx_int(form.nowmonthday))
    form.lbl_hslj_3.Text = gui.TextManager:Format_GetText()
    gui.TextManager:Format_SetIDName("ui_huashan_ready")
    gui.TextManager:Format_AddParam(nx_int(form.nowmonthday))
    form.lbl_hslj_12.Text = gui.TextManager:Format_GetText()
  end
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nx_null()
  end
  return client_player
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
    nx_execute("form_stage_main\\form_huashan\\form_huashan_main", "open_form")
  end
end
function on_btn_taolu_click(btn)
  nx_execute("form_stage_main\\form_match\\form_taolu_pick", "open_form")
end
function on_btn_qiubai_click(btn)
  nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "show_ws")
end
function on_btn_hj_click(btn)
  local form = util_auto_show_hide_form("form_stage_main\\form_match\\form_haojie_guid")
  form.count = 5
end
function on_btn_jy_click(btn)
  local form = util_auto_show_hide_form("form_stage_main\\form_match\\form_jingying_guid")
  form.count = 5
end
function on_btn_tianti_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if not nx_is_valid(rang_form) then
    return
  end
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_1_RevengeIntegral")
end
function on_btn_tianti_2_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if not nx_is_valid(rang_form) then
    return
  end
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_17_ManyRevengeIntegral")
end
function set_bisai(...)
  local form = nx_value("form_stage_main\\form_match\\form_match")
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) ~= 4 then
    return
  end
  local sum = arg[1] + arg[2]
  local sum_match = arg[3] + arg[4]
  form.lbl_26.Text = nx_widestr(arg[3])
  form.lbl_43.Text = nx_widestr(sum_match)
  if 0 < sum then
    form.lbl_27.Text = nx_widestr(nx_int(arg[1] / sum * 100)) .. nx_widestr("%")
  else
    form.lbl_27.Text = nx_widestr("0")
  end
end
function on_btn_exist_cross_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  nx_execute("custom_sender", "custom_egwar_trans", nx_number(9))
  local ready_form = util_get_form("form_stage_main\\form_match\\form_war_ready", false, true)
  if nx_is_valid(ready_form) then
    ready_form.Visible = false
    ready_form:Close()
  end
  local confirm_form = util_get_form("form_stage_main\\form_match\\form_taolu_confirm_new", false, true)
  if nx_is_valid(confirm_form) then
    confirm_form.Visible = false
    confirm_form:Close()
  end
  local bantl_form = util_get_form("form_stage_main\\form_match\\form_banxuan_taolu", false, true)
  if nx_is_valid(bantl_form) then
    bantl_form.Visible = false
    bantl_form:Close()
  end
  form:Close()
end
function on_btn_reward_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local reward_form = nx_value("form_stage_main\\form_match\\form_match_reward")
  if not nx_is_valid(reward_form) then
    nx_execute("form_stage_main\\form_match\\form_match_reward", "show_match_reward_info")
    btn.Checked = true
  else
    reward_form.Visible = false
    reward_form:Close()
    btn.Checked = false
  end
end
