require("util_functions")
require("util_gui")
require("define\\gamehand_type")
require("util_vip")
require("share\\view_define")
require("form_stage_main\\form_school_war\\school_war_define")
require("form_stage_main\\form_tvt\\define")
local school_huodong_type = {
  ITT_SPY_MENP,
  ITT_PATROL,
  ITT_DUOSHU,
  ITT_HUSHU,
  ITT_MENPAIZHAN
}
SchoolPoseID = 0
SchoolPoseUser = 1
SchoolPoseTime = 2
UserLevelTitle = 3
SchoolMsg = 0
SchoolTreasure = 1
SchoolPose = 2
SchoolRule = 3
SchoolFun = 4
SchoolFunNpc = 5
SchoolGongXian = 6
SchoolTeacherList = 7
SchoolTeacherPupil = 8
local SchoolExtermin = 9
PER_MINUTE = 60000
PER_SECOND = 1000
THIRTY_MINUTE = 600000
HOMEPOINT_INI_FILE = "share\\Rule\\HomePoint.ini"
local table_school_to_origin = {
  7,
  4,
  6,
  8,
  5,
  3,
  2,
  1
}
local schoolmsginfo = {}
local msgkey = ""
local rulekey = 1
local form_name = "form_stage_main\\form_school_war\\form_school_msg_info"
local INI_EXTERMIN = "share\\War\\School_Funcnpc_Extermin.ini"
local INI_EXTERMIN_SEARCH = "share\\War\\School_NpcSearch_Extermin.ini"
local SUBFORM_EXTERMIN = "form_stage_main\\form_school_war\\form_school_msg_info_extermination"
function open_form()
  nx_execute("form_stage_main\\form_main\\form_main", "on_btn_school_click", nil)
end
function main_form_init(form)
  form.Fixed = false
  msgkey = ""
  rulekey = 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    mgr = nx_create("InteractManager")
    if not nx_is_valid(mgr) then
      return
    end
    nx_set_value("InteractManager", mgr)
  end
  form.timer_span = 1000
  form.pbar_timedown.Maximum = THIRTY_MINUTE
  form.pbar_timedown.Minimum = 0
  form.selectBtn = nil
  form.fun_npc = 0
  form.b_extermin = false
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  nx_execute("util_functions", "get_ini", "share\\War\\School_MsgInfo.ini")
  nx_execute("util_functions", "get_ini", "share\\War\\SchoolPose_Info.ini")
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_TASK_TOOL, form, nx_current(), "on_toolbox_viewport_change")
  end
  form.rbtn_1.Checked = true
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 21)
  form.redit_notice.ReadOnly = true
  form.btn_notice_modify.Text = gui.TextManager:GetText(nx_string("ui_bianji"))
  form.groupbox_notice.Visible = true
  form.btn_notice.Visible = false
  form.btn_notice_close.Visible = true
  if not is_school_leader() then
    form.btn_notice_modify.Enabled = false
  end
  local result = nx_execute(SUBFORM_EXTERMIN, "is_school_extermination")
  if result then
    form.b_extermin = true
    show_extermin_rbtn(form, true)
  else
    show_extermin_rbtn(form, false)
  end
end
function open_subform(form, subform_path)
  local subform = nx_value(subform_path)
  if not nx_is_valid(subform) then
    subform = nx_execute("util_gui", "util_get_form", subform_path, true, false)
    if not nx_is_valid(subform) then
      return
    end
  elseif subform.Visible == true then
    return
  end
  local is_load = form:Add(subform)
  if not is_load then
    return
  end
  subform.Left = form.groupbox_msginfo.Left
  subform.Top = form.groupbox_msginfo.Top
  subform.Visible = true
  subform:Show()
end
function close_subform(subform_path)
  local subform = nx_value(subform_path)
  if not nx_is_valid(subform) then
    return
  else
    subform.Visible = false
    subform:Close()
  end
end
function on_main_form_close(form)
  reset_homepoint_timedown(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("SchoolPoseRec", form)
  end
  closetreasureform(form)
  nx_destroy(form)
end
function closetreasureform(btn)
  local form = btn.ParentForm
  form.groupbox_msginfo.Visible = true
  close_subform("form_stage_main\\form_school_war\\form_school_fight_item")
end
function cloaseteacherlistform()
  close_subform("form_stage_main\\form_school_war\\form_school_teacher_list")
end
function closeteacherpupilform()
  close_subform("form_stage_main\\form_school_war\\form_school_teacher_pupil")
end
function open_school_form_and_show_sub_page(sub_page)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local playerschool = client_player:QueryProp("School")
  if playerschool == nil or nx_string(playerschool) == nx_string("") then
    return
  end
  local SchoolID = 5
  if playerschool == "school_jinyiwei" then
    SchoolID = 5
  elseif playerschool == "school_gaibang" then
    SchoolID = 6
  elseif playerschool == "school_junzitang" then
    SchoolID = 7
  elseif playerschool == "school_jilegu" then
    SchoolID = 8
  elseif playerschool == "school_tangmen" then
    SchoolID = 9
  elseif playerschool == "school_emei" then
    SchoolID = 10
  elseif playerschool == "school_wudang" then
    SchoolID = 11
  elseif playerschool == "school_shaolin" then
    SchoolID = 12
  elseif playerschool == "school_mingjiao" then
    SchoolID = 769
  elseif playerschool == "school_tianshan" then
    SchoolID = 832
  end
  local form = util_show_form(nx_current(), true)
  if nx_is_valid(form) then
    form.SchoolID = SchoolID
    on_school_refresh(form)
    ShowPage(form, sub_page)
  end
end
function on_toolbox_viewport_change(form, optype, view_ident, index)
  local form = nx_value("form_stage_main\\form_school_war\\form_school_msg_info")
  if nx_is_valid(form) then
    if form.Visible == false then
      return
    end
  else
    return
  end
  fresh_SchoolPoint(form)
end
function fresh_SchoolPoint(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local School = client_player:QueryProp("School")
  form.lbl_schoolpoint.Text = nx_widestr("0")
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\School_Config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(School)
  if index < 0 then
    return
  end
  local NeedsItem = ini:ReadString(index, "NeedsItem", "")
  local view = game_client:GetView(nx_string(VIEWPORT_TASK_TOOL))
  if not nx_is_valid(view) then
    return
  end
  local cur_amount = nx_int(0)
  local viewobj_list = view:GetViewObjList()
  for j, obj in pairs(viewobj_list) do
    local tempid = obj:QueryProp("ConfigID")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(NeedsItem)) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
    end
  end
  form.lbl_schoolpoint.Text = nx_widestr(cur_amount)
end
function on_school_refresh(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gui = nx_value("gui")
  if not nx_is_valid(client_player) then
    return
  end
  local School = client_player:QueryProp("School")
  local SchoolID = form.SchoolID
  local DescName, Desc, SchoolName, HomepointInfo, SchoolSign
  if SchoolID == 5 then
    DescName = gui.TextManager:GetText(nx_string("ui_desctitle_school01"))
    Desc = gui.TextManager:GetText(nx_string("desc_school01_jinyiwei"))
    SchoolName = gui.TextManager:GetText(nx_string("ui_neigong_category_jy"))
    HomepointInfo = gui.TextManager:GetText(nx_string("desc_chatschool01"))
    SchoolSign = "gui//language//ChineseS//shengwang//jy.png"
  elseif SchoolID == 6 then
    DescName = gui.TextManager:GetText(nx_string("ui_desctitle_school02"))
    Desc = gui.TextManager:GetText(nx_string("desc_school02_gaibang"))
    SchoolName = gui.TextManager:GetText(nx_string("ui_neigong_category_gb"))
    HomepointInfo = gui.TextManager:GetText(nx_string("desc_chatschool02"))
    SchoolSign = "gui//language//ChineseS//shengwang//gb.png"
  elseif SchoolID == 7 then
    DescName = gui.TextManager:GetText(nx_string("ui_desctitle_school03"))
    Desc = gui.TextManager:GetText(nx_string("desc_school03_junzitang"))
    SchoolName = gui.TextManager:GetText(nx_string("ui_neigong_category_jz"))
    HomepointInfo = gui.TextManager:GetText(nx_string("desc_chatschool03"))
    SchoolSign = "gui//language//ChineseS//shengwang//jz.png"
  elseif SchoolID == 8 then
    DescName = gui.TextManager:GetText(nx_string("ui_desctitle_school04"))
    Desc = gui.TextManager:GetText(nx_string("desc_school04_jilegu"))
    SchoolName = gui.TextManager:GetText(nx_string("ui_neigong_category_jl"))
    HomepointInfo = gui.TextManager:GetText(nx_string("desc_chatschool04"))
    SchoolSign = "gui//language//ChineseS//shengwang//jl.png"
  elseif SchoolID == 9 then
    DescName = gui.TextManager:GetText(nx_string("ui_desctitle_school05"))
    Desc = gui.TextManager:GetText(nx_string("desc_school05_tangmen"))
    SchoolName = gui.TextManager:GetText(nx_string("ui_neigong_category_tm"))
    HomepointInfo = gui.TextManager:GetText(nx_string("desc_chatschool05"))
    SchoolSign = "gui//language//ChineseS//shengwang//tm.png"
  elseif SchoolID == 10 then
    DescName = gui.TextManager:GetText(nx_string("ui_desctitle_school06"))
    Desc = gui.TextManager:GetText(nx_string("desc_school06_emei"))
    SchoolName = gui.TextManager:GetText(nx_string("ui_neigong_category_em"))
    HomepointInfo = gui.TextManager:GetText(nx_string("desc_chatschool06"))
    SchoolSign = "gui//language//ChineseS//shengwang//em.png"
  elseif SchoolID == 11 then
    DescName = gui.TextManager:GetText(nx_string("ui_desctitle_school07"))
    Desc = gui.TextManager:GetText(nx_string("desc_school07_wudang"))
    SchoolName = gui.TextManager:GetText(nx_string("ui_neigong_category_wd"))
    HomepointInfo = gui.TextManager:GetText(nx_string("desc_chatschool07"))
    SchoolSign = "gui//language//ChineseS//shengwang//wd.png"
  elseif SchoolID == 12 then
    DescName = gui.TextManager:GetText(nx_string("ui_desctitle_school08"))
    Desc = gui.TextManager:GetText(nx_string("desc_school08_shaolin"))
    SchoolName = gui.TextManager:GetText(nx_string("ui_neigong_category_sl"))
    HomepointInfo = gui.TextManager:GetText(nx_string("desc_chatschool08"))
    SchoolSign = "gui//language//ChineseS//shengwang//sl.png"
  elseif SchoolID == 769 then
    DescName = gui.TextManager:GetText(nx_string("ui_desctitle_school20"))
    Desc = gui.TextManager:GetText(nx_string("desc_school20_mingjiao"))
    SchoolName = gui.TextManager:GetText(nx_string("ui_neigong_category_mj"))
    HomepointInfo = gui.TextManager:GetText(nx_string("desc_chatschool20"))
    SchoolSign = "gui//language//ChineseS//shengwang//mj.png"
  elseif SchoolID == 832 then
    DescName = gui.TextManager:GetText(nx_string("ui_desctitle_school22"))
    Desc = gui.TextManager:GetText(nx_string("desc_school22_tianshan"))
    SchoolName = gui.TextManager:GetText(nx_string("ui_neigong_category_ts"))
    HomepointInfo = gui.TextManager:GetText(nx_string("desc_chatschool22"))
    SchoolSign = "gui//language//ChineseS//shengwang//ts.png"
  end
  local zhangmenid = SchoolID * 100 + 11
  form.lbl_Title.Text = SchoolName
  form.lbl_schoolname.Text = SchoolName
  form.lbl_school_sign.BackImage = SchoolSign
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\SchoolPose_Info.ini")
  if not nx_is_valid(ini) then
    return
  end
  local rows = client_player:FindRecordRow("SchoolPoseRec", SchoolPoseID, zhangmenid)
  if rows < 0 then
    return
  end
  local index = ini:FindSectionIndex(nx_string(zhangmenid))
  if index < 0 then
    index = 0
  end
  local postitle = "role_title_" .. ini:ReadString(index, "GetOrigin", "")
  local poseuser = client_player:QueryRecord("SchoolPoseRec", rows, SchoolPoseUser)
  local level_title = "desc_" .. client_player:QueryRecord("SchoolPoseRec", rows, UserLevelTitle)
  form.lbl_school_zhangmen_name.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(poseuser)))
  form.lbl_school_zhangmen_power.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(level_title)))
  form.lbl_school_zhangmen_origin.Text = nx_widestr(gui.TextManager:GetFormatText(postitle))
  form.lbl_my_name.Text = nx_widestr(client_player:QueryProp("Name"))
  level_title = "desc_" .. client_player:QueryProp("LevelTitle")
  form.lbl_my_power.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(level_title)))
  local guildname = client_player:QueryProp("GuildName")
  if guildname == 0 then
    guildname = ""
  end
  form.lbl_my_guild.Text = nx_widestr(guildname)
  local CharacterFlag = nx_number(client_player:QueryProp("CharacterFlag"))
  local CharacterValue = nx_number(client_player:QueryProp("CharacterValue"))
  local text = get_xiae_text(CharacterFlag, CharacterValue)
  form.lbl_my_shane.Text = nx_widestr(text)
  local titlerec = GetTitles(2)
  if titlerec ~= nil and 0 < table.getn(titlerec) then
    form.lbl_my_origin.Text = nx_widestr(gui.TextManager:GetFormatText("role_title_" .. titlerec[table.getn(titlerec)]))
  else
    form.lbl_my_origin.Text = nx_widestr("")
  end
  form.lbl_school_tresure.BackImage = item_table[school_table[SchoolID].itemID][3]
  form.lbl_treasure_info.Text = nx_widestr(gui.TextManager:GetFormatText(item_table[school_table[SchoolID].itemID][2]))
  ini = nx_execute("util_functions", "get_ini", "ini\\ui\\schoolface\\school_interface.ini")
  if not nx_is_valid(ini) then
    return
  end
  index = ini:FindSectionIndex(string.format("%d", SchoolID))
  if index < 0 then
    return
  end
  form.lbl_title_back.BackImage = ini:ReadString(index, "Photo", "")
  form.lbl_homepoint_info_back.BackImage = ini:ReadString(index, "Photo", "")
  form.lbl_msg_info_back.BackImage = ini:ReadString(index, "Photo", "")
  form.mltbox_school_homepoint_info:Clear()
  form.mltbox_school_homepoint_info:AddHtmlText(nx_widestr(HomepointInfo), nx_int(-1))
  ShowSchoolRule(form)
  fresh_SchoolPoint(form)
  fresh_school_pos_info(form)
  fresh_school_fun_npc(form)
  fresh_school_fun(form)
end
function GetTitles(type)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:GetRecordRows("title_rec") <= 0 then
    return nil
  end
  local list_titles = {}
  local row_count = client_player:GetRecordRows("title_rec")
  for r = 0, row_count - 1 do
    local rec_type = client_player:QueryRecord("title_rec", r, 1)
    if nx_int(rec_type) == nx_int(type) then
      local rec_title = client_player:QueryRecord("title_rec", r, 0)
      table.insert(list_titles, rec_title)
    end
  end
  return list_titles
end
function get_xiae_text(CharacterFlag, CharacterValue)
  local text = nx_execute("form_stage_main\\form_role_info\\form_role_info", "get_xiae_text", CharacterFlag, CharacterValue)
  return text
end
function on_btn_orign_click(btn)
  nx_execute("form_stage_main\\form_origin\\form_origin", "auto_show_hide_origin")
  local form = nx_value("form_stage_main\\form_origin\\form_origin")
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_main_1.Checked = true
  local SchoolID = btn.ParentForm.SchoolID
  local sub_id = SchoolID - 4
  if sub_id < 1 or 8 < sub_id then
    return
  end
  local rbtn_sub = form.groupbox_tab_sub:Find("rbtn_sub_" .. nx_string(table_school_to_origin[sub_id]))
  if nx_is_valid(rbtn_sub) then
    rbtn_sub.Checked = true
  end
end
function ShowPage(form, page)
  if page ~= SchoolTreasure then
    closetreasureform(form)
  end
  form.groupbox_title.Visible = false
  form.groupbox_homepoint.Visible = false
  form.groupbox_msg.Visible = false
  form.groupbox_rule.Visible = false
  form.groupbox_npclist.Visible = false
  form.groupbox_gongxun.Visible = false
  form.groupbox_school_dance.Visible = false
  form.groupbox_extermin.Visible = false
  form.btn_school_treasure.Checked = false
  form.btn_msginfo.Checked = false
  form.btn_school_rule.Checked = false
  form.btn_school_fun.Checked = false
  form.btn_school_fun_npc.Checked = false
  form.btn_title.Checked = false
  form.btn_school_gongxun.Checked = false
  form.rbtn_extermin.Checked = false
  form.btn_school_dance.Checked = false
  if SchoolMsg == page then
    form.groupbox_msg.Visible = true
    form.btn_msginfo.Checked = true
  elseif SchoolTreasure == page then
    form.btn_school_treasure.Checked = true
    open_subform(form, "form_stage_main\\form_school_war\\form_school_fight_item")
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 2)
  elseif SchoolPose == page then
    form.btn_title.Checked = true
    form.groupbox_title.Visible = true
  elseif SchoolFunNpc == page then
    form.btn_school_fun_npc.Checked = true
    form.groupbox_npclist.Visible = true
    local cbtnbutton = form.groupbox_npclist:Find("cbtn_base1")
    if nx_is_valid(cbtnbutton) then
      cbtnbutton.Checked = false
      on_base_button_click(cbtnbutton)
    end
  elseif SchoolRule == page then
    form.btn_school_rule.Checked = true
    form.groupbox_rule.Visible = true
  elseif SchoolFun == page then
    form.btn_school_fun.Checked = true
    form.groupbox_homepoint.Visible = true
    nx_execute("custom_sender", "custom_get_school_homepoint_info", form.SchoolID)
  elseif SchoolGongXian == page then
    form.btn_school_gongxun.Checked = true
    form.groupbox_gongxun.Visible = true
    nx_execute("custom_sender", "custom_school_gxd")
  elseif SchoolDance == page then
    form.btn_school_dance.Checked = true
    form.groupbox_school_dance.Visible = true
    show_school_dance_info(form)
  elseif SchoolExtermin == page then
    local subform = nx_execute(SUBFORM_EXTERMIN, "open_form")
    if not nx_is_valid(subform) then
      return
    end
    form.groupbox_extermin:Add(subform)
    form.groupbox_extermin.Visible = true
    form.rbtn_extermin.Checked = true
    nx_execute(SUBFORM_EXTERMIN, "change_form_size", form)
  end
end
function on_btn_school_treasure_click(btn)
  local form = btn.ParentForm
  ShowPage(form, SchoolTreasure)
end
function on_btn_title_click(btn)
  local form = btn.ParentForm
  ShowPage(form, SchoolPose)
end
function on_btn_msginfo_click(btn)
  local form = btn.ParentForm
  ShowPage(form, SchoolMsg)
end
function on_btn_school_fun_click(btn)
  local form = btn.ParentForm
  ShowPage(form, SchoolFun)
end
function on_btn_school_gongxun_click(btn)
  local form = btn.ParentForm
  ShowPage(form, SchoolGongXian)
end
function on_btn_school_rule_click(btn)
  local form = btn.ParentForm
  ShowPage(form, SchoolRule)
end
function on_btn_school_teacherlist_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_school_war\\form_school_teacher_list", "request_teacher_list")
end
function on_btn_school_teacherpupil_click(btn)
  local form = btn.ParentForm
end
function on_btn_school_fun_npc_click(btn)
  local form = btn.ParentForm
  fresh_school_fun_npc(form)
  ShowPage(form, SchoolFunNpc)
end
function on_btn_school_dance_click(btn)
  local form = btn.ParentForm
  ShowPage(form, SchoolDance)
end
function on_rbtn_extermin_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  ShowPage(form, SchoolExtermin)
end
function on_btn_backtown_click(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gui = nx_value("gui")
  if not nx_is_valid(client_player) then
    return
  end
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return
  end
  local school = client_player:QueryProp("School")
  if school ~= "" then
    nx_execute("custom_sender", "custom_return_school_home_point")
  end
end
function on_btn_findpath_click(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local school = client_player:QueryProp("School")
  if school == "" then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\School_Config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(school)
  if index < 0 then
    return
  end
  local hpid = ini:ReadString(index, "HomePointID", "")
  if hpid == "" then
    return
  end
  local scene_id, x, y, z = get_homepoint_pos(hpid)
  local path_finding = nx_value("path_finding")
  if not nx_is_valid(path_finding) then
    return
  end
  if is_auto_find_path() then
    path_finding:FindPathScene(get_scene_name(scene_id), nx_float(x), nx_float(y), nx_float(z), 0)
  else
    path_finding:DrawToTarget(get_scene_name(scene_id), nx_float(x), nx_float(y), nx_float(z), 0, "")
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) or nx_is_valid(form_map) and not form_map.Visible then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "auto_show_hide_map_scene")
  end
end
function on_btn_vote_click(btn)
  nx_execute("custom_sender", "custom_get_school_vote_info")
end
function get_homepoint_pos(hpid)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\HomePoint.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(hpid)
  if index < 0 then
    return
  end
  local pos_text = ini:ReadString(index, "PositonXYZ", "")
  local senceNO = ini:ReadInteger(index, "SceneID", 0)
  local pos = util_split_string(nx_string(pos_text), ",")
  return senceNO, pos[1], pos[2], pos[3]
end
function get_scene_name(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\maplist.ini")
  if not nx_is_valid(ini) then
    return
  end
  return ini:ReadString(0, nx_string(index), "")
end
function on_school_msg_rec_refresh(form, recordname, optype, row, clomn)
  if optype == "update" or optype == "del" then
    fresh_school_pos_info(form)
  end
end
function fresh_school_fun(form)
  on_btn_declare_warinfo_click(form)
end
function fresh_school_fun_npc(form)
  if not nx_value(nx_string(form.Name)) then
    return
  end
  if not nx_find_custom(form, "fun_npc") then
    return
  end
  if form.fun_npc == 1 then
    return
  end
  form.cbtn_sub_base.Visible = false
  form.cbtn_base.Visible = false
  form.groupbox_funnpcsimple.Visible = false
  local npcnodeini
  if form.b_extermin then
    npcnodeini = get_ini(INI_EXTERMIN_SEARCH, true)
  else
    npcnodeini = get_ini("share\\War\\School_NpcSearch.ini", true)
  end
  if not nx_is_valid(npcnodeini) then
    return
  end
  local gui = nx_value("gui")
  local nCount = npcnodeini:GetSectionCount()
  local button = form.groupbox_npclist:Find("cbtn_base1")
  if nx_is_valid(button) then
    return
  end
  for i = 1, nCount do
    local sec_index = npcnodeini:FindSectionIndex(nx_string(i))
    if 0 <= sec_index then
      local section = npcnodeini:GetSectionByIndex(sec_index)
      local Storey = npcnodeini:ReadInteger(sec_index, "Storey", 0)
      if nx_int(Storey) == nx_int(0) then
        local clonebutton = clone_checkbutton(form.cbtn_base)
        clonebutton.Name = nx_string(clonebutton.Name) .. nx_string(section)
        local text = npcnodeini:ReadString(sec_index, "Desc", "")
        clonebutton.Text = nx_widestr(gui.TextManager:GetFormatText(text))
        clonebutton.Visible = true
        clonebutton.Left = form.cbtn_base.Left + (nx_int(section) - 1) * (clonebutton.Width + 8)
        clonebutton.index = section
        clonebutton.maxindex = 0
        nx_bind_script(clonebutton, nx_current())
        nx_callback(clonebutton, "on_click", "on_base_button_click")
        form.groupbox_npclist:Add(clonebutton)
      else
        local clonebutton = clone_button(form.cbtn_sub_base)
        local basebutton = form.groupbox_npclist:Find("cbtn_base" .. nx_string(Storey))
        if nx_is_valid(basebutton) then
          clonebutton.Left = basebutton.Left
          basebutton.maxindex = basebutton.maxindex + 1
          clonebutton.Name = nx_string(clonebutton.Name) .. nx_string(basebutton.index) .. "_" .. nx_string(basebutton.maxindex)
          clonebutton.Top = basebutton.Top - (clonebutton.Height - 1) * basebutton.maxindex
          clonebutton.Visible = false
          local text = npcnodeini:ReadString(sec_index, "Desc", "")
          clonebutton.Text = nx_widestr(gui.TextManager:GetFormatText(text))
          clonebutton.parentindex = Storey
          clonebutton.index = section
          nx_bind_script(clonebutton, nx_current())
          nx_callback(clonebutton, "on_click", "on_sub_button_click")
          form.groupbox_npclist:Add(clonebutton)
        end
      end
    end
  end
  fresh_school_all_fun_npc(form)
  form.fun_npc = 1
end
function fresh_school_all_fun_npc(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "b_extermin") then
    return
  end
  local npcnodeini
  if form.b_extermin then
    npcnodeini = get_ini(INI_EXTERMIN, true)
  else
    npcnodeini = get_ini("share\\War\\School_Funcnpc.ini", true)
  end
  if not nx_is_valid(npcnodeini) then
    return
  end
  form.groupscrollbox_npclist:DeleteAll()
  form.groupscrollbox_npclist.IsEditMode = true
  local gui = nx_value("gui")
  local nCount = npcnodeini:GetSectionCount()
  for i = 1, nCount do
    local sec_index = npcnodeini:FindSectionIndex(nx_string(i))
    local school = npcnodeini:ReadInteger(sec_index, "school", 0)
    local Type = npcnodeini:ReadInteger(sec_index, "type", 0)
    local NpcDesc = npcnodeini:ReadString(sec_index, "NpcDesc", "")
    local NpcID = npcnodeini:ReadString(sec_index, "NpcID", "")
    local NpcTrack = npcnodeini:ReadString(sec_index, "NpcTrack", "")
    local SchoolFunc = npcnodeini:ReadString(sec_index, "SchoolFunc", "")
    local SchoolLogo = npcnodeini:ReadString(sec_index, "SchoolLogo", "")
    local SchoolPicture = npcnodeini:ReadString(sec_index, "SchoolPicture", "")
    local SchoolTitle = npcnodeini:ReadString(sec_index, "SchoolTitle", "")
    if school == form.SchoolID then
      local clonegroupbox = clone_groupbox_funnpc(form, form.groupbox_funnpcsimple, NpcID, NpcTrack, NpcDesc, SchoolFunc, SchoolLogo, SchoolPicture, SchoolTitle)
      form.groupscrollbox_npclist:Add(clonegroupbox)
    end
  end
  form.groupscrollbox_npclist:ResetChildrenYPos()
  form.groupscrollbox_npclist.IsEditMode = false
end
function on_base_button_click(btn)
  local form = btn.ParentForm
  if btn.Checked == false then
    fresh_school_all_fun_npc(form)
  end
  showallsubbutton(btn, btn.Checked)
end
function showallsubbutton(btn, open)
  local form = btn.ParentForm
  local nCount = btn.maxindex
  for i = 1, nCount + 1 do
    local subbutton = form.groupbox_npclist:Find("cbtn_sub_base" .. nx_string(btn.index) .. "_" .. nx_string(i))
    if nx_is_valid(subbutton) then
      subbutton.Visible = open
    end
  end
  if form.selectBtn ~= nil and form.selectBtn.index ~= btn.index then
    nCount = form.selectBtn.maxindex
    for i = 1, nCount + 1 do
      local subbutton = form.groupbox_npclist:Find("cbtn_sub_base" .. nx_string(form.selectBtn.index) .. "_" .. nx_string(i))
      if nx_is_valid(subbutton) then
        subbutton.Visible = false
      end
    end
    form.selectBtn.Checked = false
  end
  form.selectBtn = btn
end
function on_sub_button_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "b_extermin") then
    return
  end
  local npcnodeini
  if form.b_extermin then
    npcnodeini = get_ini(INI_EXTERMIN, true)
  else
    npcnodeini = get_ini("share\\War\\School_Funcnpc.ini", true)
  end
  if not nx_is_valid(npcnodeini) then
    return
  end
  form.groupscrollbox_npclist:DeleteAll()
  form.groupscrollbox_npclist.IsEditMode = true
  local gui = nx_value("gui")
  local nCount = npcnodeini:GetSectionCount()
  for i = 1, nCount do
    local sec_index = npcnodeini:FindSectionIndex(nx_string(i))
    local school = npcnodeini:ReadInteger(sec_index, "school", 0)
    local Type = npcnodeini:ReadInteger(sec_index, "Chapters", 0)
    local NpcDesc = npcnodeini:ReadString(sec_index, "NpcDesc", "")
    local NpcID = npcnodeini:ReadString(sec_index, "NpcID", "")
    local NpcTrack = npcnodeini:ReadString(sec_index, "NpcTrack", "")
    local SchoolFunc = npcnodeini:ReadString(sec_index, "SchoolFunc", "")
    local SchoolLogo = npcnodeini:ReadString(sec_index, "SchoolLogo", "")
    local SchoolPicture = npcnodeini:ReadString(sec_index, "SchoolPicture", "")
    local SchoolTitle = npcnodeini:ReadString(sec_index, "SchoolTitle", "")
    if school == form.SchoolID and Type == nx_number(btn.index) then
      local clonegroupbox = clone_groupbox_funnpc(form, form.groupbox_funnpcsimple, NpcID, NpcTrack, NpcDesc, SchoolFunc, SchoolLogo, SchoolPicture, SchoolTitle)
      form.groupscrollbox_npclist:Add(clonegroupbox)
    end
  end
  form.groupscrollbox_npclist:ResetChildrenYPos()
  form.groupscrollbox_npclist.IsEditMode = false
  local basebutton = form.groupbox_npclist:Find("cbtn_base" .. nx_string(btn.parentindex))
  if nx_is_valid(basebutton) then
    showallsubbutton(basebutton, false)
    basebutton.Checked = false
  end
end
function fresh_school_pos_info(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gui = nx_value("gui")
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:GetRecordRows("SchoolPoseRec")
  if nx_int(row) < nx_int(0) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\SchoolPose_Info.ini")
  if not nx_is_valid(ini) then
    return
  end
  for i = 0, row - 1 do
    local posindex = client_player:QueryRecord("SchoolPoseRec", i, SchoolPoseID)
    if nx_int(posindex / 100) == nx_int(form.SchoolID) then
      local index = ini:FindSectionIndex(nx_string(posindex))
      if index < 0 then
        index = 0
      end
      local postitle = "role_title_" .. ini:ReadString(index, "GetOrigin", "")
      local poseuser = client_player:QueryRecord("SchoolPoseRec", i, SchoolPoseUser)
      local level_title = "desc_" .. client_player:QueryRecord("SchoolPoseRec", i, UserLevelTitle)
      local basename = "lbl_title_" .. nx_string(posindex % 100)
      local lbl_bg = form.groupbox_title:Find(nx_string(basename .. "_name"))
      if nx_is_valid(lbl_bg) then
        local show_name = nx_widestr(gui.TextManager:GetFormatText(nx_string(poseuser)))
        if nx_ws_length(show_name) > 5 then
          lbl_bg.HintText = nx_widestr(gui.TextManager:GetFormatText(nx_string(poseuser)))
          show_name = nx_function("ext_ws_substr", show_name, 0, 3) .. nx_widestr("...")
        else
          lbl_bg.HintText = nx_widestr("")
        end
        lbl_bg.Text = show_name
      end
      lbl_bg = form.groupbox_title:Find(nx_string(basename .. "_pic"))
      if nx_is_valid(lbl_bg) then
        lbl_bg.BackImage = ini:ReadString(index, "Photo", "") .. ".png"
        lbl_bg.SchoolPoseID = posindex
        lbl_bg.poseuser = poseuser
      end
      lbl_bg = form.groupbox_title:Find(nx_string(basename .. "_status"))
      if nx_is_valid(lbl_bg) then
        if gui.TextManager:GetFormatText(nx_string(poseuser)) == poseuser then
          lbl_bg.Text = nx_widestr(gui.TextManager:GetFormatText("ui_schoolpose_disciple"))
        else
          lbl_bg.Text = nx_widestr(gui.TextManager:GetFormatText("ui_schoolpose_oldschool"))
        end
      end
      lbl_bg = form.groupbox_title:Find(nx_string(basename .. "_origin"))
      if nx_is_valid(lbl_bg) then
        lbl_bg.Text = nx_widestr(gui.TextManager:GetFormatText(postitle))
      end
      local mltbox = form.groupbox_title:Find(nx_string("mltbox_school_title_info_" .. nx_string(posindex % 100)))
      if nx_is_valid(mltbox) then
        mltbox:Clear()
        mltbox:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText(level_title)), nx_int(-1))
      end
    end
  end
  local Name = client_player:QueryProp("Name")
  local rows = client_player:FindRecordRow("SchoolPoseRec", 1, Name)
  if 0 <= rows then
    local rank = nx_int(client_player:QueryRecord("SchoolPoseRec", rows, SchoolPoseID) % 100 / 10)
    if rank == nx_int(1) then
      form.lbl_roletitle.Text = gui.TextManager:GetText(nx_string("ui_schoolpost_name01"))
    elseif rank == nx_int(2) then
      form.lbl_roletitle.Text = gui.TextManager:GetText(nx_string("ui_schoolpost_name02"))
    elseif rank == nx_int(3) then
      form.lbl_roletitle.Text = gui.TextManager:GetText(nx_string("ui_schoolpost_name03"))
    end
  else
    form.lbl_roletitle.Text = gui.TextManager:GetText(nx_string("ui_schoolinformation_trends_disciple"))
  end
end
function on_btn_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_declare_war_click(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local Name = client_player:QueryProp("Name")
  local rows = client_player:FindRecordRow("SchoolPoseRec", 1, Name)
  if 0 <= rows then
    local rank = nx_int(client_player:QueryRecord("SchoolPoseRec", rows, SchoolPoseID) % 100 / 10)
    if rank == nx_int(1) then
      local hour, minute, second = get_server_time()
      local now_time = nx_number(hour) * 100 + nx_number(minute)
      if nx_number(now_time) < 5 or nx_number(now_time) >= 1800 then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 17, "83161", 18)
        return
      end
      util_show_form("form_stage_main\\form_school_war\\form_school_war_control", true)
    end
  end
end
function on_rbtn_1_click(btn)
  msgkey = ""
  fresh_msg_info(btn.ParentForm)
end
function on_rbtn_2_click(btn)
  msgkey = "ui_schooltypedesc_01"
  fresh_msg_info(btn.ParentForm)
end
function on_rbtn_3_click(btn)
  msgkey = "ui_schooltypedesc_02"
  fresh_msg_info(btn.ParentForm)
end
function on_rbtn_4_click(btn)
  msgkey = "ui_schooltypedesc_03"
  fresh_msg_info(btn.ParentForm)
end
function on_btn_school_xiushen_click(btn)
  rulekey = 0
  ShowSchoolRule(btn.ParentForm)
end
function on_btn_school_chushi_click(btn)
  rulekey = 1
  ShowSchoolRule(btn.ParentForm)
end
function fresh_msg_info(form)
  local gui = nx_value("gui")
  local TreasureSchool = schoolmsginfo[1]
  local row = schoolmsginfo[2]
  if nx_number(row) > 0 then
    form.mltbox_school_msg_info:Clear()
    local ini = nx_execute("util_functions", "get_ini", "share\\War\\School_MsgInfo.ini")
    if not nx_is_valid(ini) then
      return
    end
    for i = 0, nx_number(row) - 1 do
      local msgtype = schoolmsginfo[i * 5 + 3]
      local startTime = schoolmsginfo[i * 5 + 4]
      local msgparm = schoolmsginfo[i * 5 + 5]
      local deletime = schoolmsginfo[i * 5 + 6]
      local index = ini:FindSectionIndex(nx_string(msgtype))
      local desc = ""
      local typedesc = ""
      if 0 <= index then
        desc = ini:ReadString(index, "DescID", "")
        typedesc = ini:ReadString(index, "TypeDescID", "")
      end
      if msgkey == "" or msgkey == typedesc then
        gui.TextManager:Format_SetIDName(desc)
        local paralst = util_split_string(nx_string(msgparm), ";")
        for i, buf in pairs(paralst) do
          if buf == "School5" then
            buf = "ui_neigong_category_jy"
          elseif buf == "School6" then
            buf = "ui_neigong_category_gb"
          elseif buf == "School7" then
            buf = "ui_neigong_category_jz"
          elseif buf == "School8" then
            buf = "ui_neigong_category_jl"
          elseif buf == "School9" then
            buf = "ui_neigong_category_tm"
          elseif buf == "School10" then
            buf = "ui_neigong_category_em"
          elseif buf == "School11" then
            buf = "ui_neigong_category_wd"
          elseif buf == "School12" then
            buf = "ui_neigong_category_sl"
          elseif buf == "School769" then
            buf = "ui_neigong_category_mj"
          elseif buf == "School832" then
            buf = "ui_neigong_category_ts"
          end
          gui.TextManager:Format_AddParam(buf)
        end
        local wcsInfo = gui.TextManager:GetText(nx_string(typedesc)) .. nx_widestr(" ") .. nx_widestr(startTime) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:Format_GetText())
        form.mltbox_school_msg_info:AddHtmlText(nx_widestr(wcsInfo), nx_int(i - 1))
      end
    end
  end
end
function ShowSchoolRule(form)
  local ruleini = nx_execute("util_functions", "get_ini", "share\\War\\school_rule.ini")
  local gui = nx_value("gui")
  if not nx_is_valid(ruleini) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local playerSchool = form.SchoolID
  clear_tree_view(form.tree_ex_schoolrule)
  local root_node = form.tree_ex_schoolrule.RootNode
  if not nx_is_valid(root_node) then
    root_node = form.tree_ex_schoolrule:CreateRootNode(nx_widestr(""))
    root_node.Mark = 0
    root_node.DrawMode = "Tile"
  end
  local nCount = ruleini:GetSectionCount()
  for i = 1, nCount do
    local sec_index = ruleini:FindSectionIndex(nx_string(i))
    if 0 <= sec_index then
      local School = ruleini:ReadString(sec_index, "School", "")
      if nx_int(School) == nx_int(playerSchool) then
        local section = ruleini:GetSectionByIndex(sec_index)
        local Chapters = ruleini:ReadInteger(sec_index, "Chapters", 0)
        local Crime = ruleini:ReadInteger(sec_index, "Crime", 0)
        local Type = ruleini:ReadString(sec_index, "Type", "")
        local UiRes = ruleini:ReadString(sec_index, "UiRes", "")
        if nx_int(Type) == nx_int(rulekey) then
          local main_node
          if nx_int(Chapters) == nx_int(0) then
            main_node = root_node
          else
            main_node = root_node:FindNodeByMark(nx_int(Chapters))
          end
          if nx_is_valid(main_node) then
            local rule_node = main_node:CreateNode(nx_widestr(gui.TextManager:GetText(UiRes)))
            rule_node.Mark = nx_int(section)
            rule_node.Font = "font_treeview"
            rule_node.ShadowColor = "0,200,0,0"
            rule_node.TextOffsetX = 30
            rule_node.TextOffsetY = 6
            rule_node.ForeColor = "255,197,184,159"
            rule_node.DrawMode = "FitWindow"
            rule_node.ItemHeight = 30
            if Chapters == 0 then
              rule_node.NodeBackImage = "gui\\special\\school\\2_bg_2_1.png"
              rule_node.NodeFocusImage = "gui\\special\\school\\2_bg_2_1.png"
              rule_node.NodeSelectImage = "gui\\special\\school\\2_bg_2_1.png"
            else
              rule_node.NodeBackImage = "gui\\special\\school\\2_bg_2_2.png"
              rule_node.NodeFocusImage = "gui\\special\\school\\2_bg_2_2.png"
              rule_node.NodeSelectImage = "gui\\special\\school\\2_bg_2_2.png"
            end
          end
        end
      end
    end
  end
  local ruledesc = gui.TextManager:GetText("ui_schoollaw_rule")
  local contributing = gui.TextManager:GetText("ui_schoollaw_contributing")
  if not nx_find_custom(form, "b_extermin") then
    return
  end
  if form.b_extermin then
    local school_id = nx_number(playerSchool)
    if 5 <= school_id and school_id <= 12 then
      local tmp_str, tmp_num
      tmp_num = school_id - 4
      tmp_str = util_text("ui_schoollaw_rule_extermin0" .. nx_string(tmp_num))
      ruledesc = ruledesc .. tmp_str
      tmp_str = util_text("ui_schoollaw_contributing_extermin0" .. nx_string(tmp_num))
      contributing = contributing .. tmp_str
    end
  elseif playerSchool == 5 then
    ruledesc = ruledesc .. gui.TextManager:GetText("ui_schoollaw_rule01")
    contributing = contributing .. gui.TextManager:GetText("ui_schoollaw_contributing01")
  elseif playerSchool == 6 then
    ruledesc = ruledesc .. gui.TextManager:GetText("ui_schoollaw_rule02")
    contributing = contributing .. gui.TextManager:GetText("ui_schoollaw_contributing02")
  elseif playerSchool == 7 then
    ruledesc = ruledesc .. gui.TextManager:GetText("ui_schoollaw_rule03")
    contributing = contributing .. gui.TextManager:GetText("ui_schoollaw_contributing03")
  elseif playerSchool == 8 then
    ruledesc = ruledesc .. gui.TextManager:GetText("ui_schoollaw_rule04")
    contributing = contributing .. gui.TextManager:GetText("ui_schoollaw_contributing04")
  elseif playerSchool == 9 then
    ruledesc = ruledesc .. gui.TextManager:GetText("ui_schoollaw_rule05")
    contributing = contributing .. gui.TextManager:GetText("ui_schoollaw_contributing05")
  elseif playerSchool == 10 then
    ruledesc = ruledesc .. gui.TextManager:GetText("ui_schoollaw_rule06")
    contributing = contributing .. gui.TextManager:GetText("ui_schoollaw_contributing06")
  elseif playerSchool == 11 then
    ruledesc = ruledesc .. gui.TextManager:GetText("ui_schoollaw_rule07")
    contributing = contributing .. gui.TextManager:GetText("ui_schoollaw_contributing07")
  elseif playerSchool == 12 then
    ruledesc = ruledesc .. gui.TextManager:GetText("ui_schoollaw_rule08")
    contributing = contributing .. gui.TextManager:GetText("ui_schoollaw_contributing08")
  elseif playerSchool == 769 then
    ruledesc = ruledesc .. gui.TextManager:GetText("ui_schoollaw_rule20")
    contributing = contributing .. gui.TextManager:GetText("ui_schoollaw_contributing20")
  elseif playerSchool == 832 then
    ruledesc = ruledesc .. gui.TextManager:GetText("ui_schoollaw_rule22")
    contributing = contributing .. gui.TextManager:GetText("ui_schoollaw_contributing22")
  end
  form.mltbox_rule:Clear()
  form.mltbox_rule:AddHtmlText(nx_widestr(ruledesc), nx_int(-1))
  form.mltbox_gongxun:Clear()
  form.mltbox_gongxun:AddHtmlText(nx_widestr(contributing), nx_int(-1))
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local SchoolRuleValue = client_player:QueryProp("SchoolRuleValue")
  form.lbl_Crime.Text = gui.TextManager:GetText("ui_schoollaw_punishment") .. nx_widestr(SchoolRuleValue)
  if 100 < SchoolRuleValue then
    form.pbar_crime.ProgressImage = "gui\\common\\progressbar\\pbr_1.png"
  end
  form.pbar_crime.Value = SchoolRuleValue
  root_node:ExpandAll()
end
function clear_tree_view(tree_view)
  if not nx_is_valid(tree_view) then
    return
  end
  local root_node = tree_view.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  local table_main_node = root_node:GetNodeList()
  for i, main_node in pairs(table_main_node) do
    main_node:ClearNode()
  end
  root_node:ClearNode()
end
function show_msg_info(SchoolID, first, ...)
  local form = util_get_form("form_stage_main\\form_school_war\\form_school_msg_info", true)
  if not nx_is_valid(form) then
    return
  end
  form.SchoolID = SchoolID
  schoolmsginfo = arg
  on_school_refresh(form)
  fresh_msg_info(form)
  if nx_int(first) == nx_int(1) then
    fresh_school_fun_npc(form)
    ShowPage(form, 5)
  end
end
function show_homepoint_info(SchoolID, TimeDown)
  local form = util_get_form("form_stage_main\\form_school_war\\form_school_msg_info", true)
  if not nx_is_valid(form) then
    return
  end
  form.SchoolID = SchoolID
  on_school_refresh(form)
  ShowHomePointForm(form, TimeDown)
end
function show_schoolface_contest(form)
  ShowPage(form, SchoolFun)
  form.btn_voteinfo.Checked = true
end
function show_schoolface_contest(form)
  ShowPage(form, SchoolFun)
  form.btn_voteinfo.Checked = true
end
function show_rule_info(SchoolID)
  local form = util_get_form("form_stage_main\\form_school_war\\form_school_msg_info", true)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible == false then
    util_show_form("form_stage_main\\form_school_war\\form_school_msg_info", true)
  end
  form.SchoolID = SchoolID
  on_school_refresh(form)
  ShowPage(form, SchoolRule)
  util_show_form("form_stage_main\\form_school_war\\form_school_msg_info", true)
end
function show_school_dance_info(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local school = client_player:QueryProp("School")
  if not nx_find_custom(form, "b_extermin") then
    return
  end
  local text
  if form.b_extermin then
    text = util_text("ui_school_dance_npc_extermin_" .. nx_string(school))
  else
    text = gui.TextManager:GetFormatText("ui_school_dance_npc_" .. nx_string(school))
  end
  form.mltbox_school_dance.HtmlText = text
  local total_score = client_player:QueryProp("SchoolDanceTotalScore")
  local day_score = client_player:QueryProp("SchoolDanceDayScore")
  form.pbar_score_total.Value = nx_int(total_score)
  form.pbar_score_day.Value = nx_int(day_score)
end
function ShowHomePointForm(form, TimeDown)
  if not nx_is_valid(form) then
    return
  end
  form.timer_span = 1000
  form.timer_down = TimeDown
  form.record_count = 0
  homepoint_timedown_started(form)
end
function homepoint_timedown_started(form)
  local timer = nx_value(GAME_TIMER)
  timer:Register(nx_int(form.timer_span), -1, nx_current(), "on_update_timedown", form, -1, -1)
  on_update_timedown(form)
end
function reset_homepoint_timedown(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_timedown", form)
  form.timer_down = 0
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
    form.time.Text = nx_widestr(util_text("ui_timeend"))
    return
  end
  form.time.Text = nx_widestr(get_format_time_text(time / 1000))
  form.timer_down = nx_int(time) - nx_int(PER_SECOND)
  form.pbar_timedown.Value = THIRTY_MINUTE - form.timer_down
end
function clone_button(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Button")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.NormalImage = source.NormalImage
  clone.FocusImage = source.FocusImage
  clone.PushImage = source.PushImage
  clone.NormalColor = source.NormalColor
  clone.FocusColor = source.FocusColor
  clone.PushColor = source.PushColor
  clone.DisableColor = source.DisableColor
  clone.BackColor = source.BackColor
  clone.ShadowColor = source.ShadowColor
  clone.Text = source.Text
  clone.AutoSize = source.AutoSize
  clone.DrawMode = source.DrawMode
  return clone
end
function clone_checkbutton(source)
  local gui = nx_value("gui")
  local clone = gui:Create("CheckButton")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.NormalImage = source.NormalImage
  clone.FocusImage = source.FocusImage
  clone.PushImage = source.CheckedImage
  clone.NormalColor = source.NormalColor
  clone.FocusColor = source.FocusColor
  clone.PushColor = source.PushColor
  clone.DisableColor = source.DisableColor
  clone.BackColor = source.BackColor
  clone.ShadowColor = source.ShadowColor
  clone.Text = source.Text
  clone.AutoSize = source.AutoSize
  clone.DrawMode = source.DrawMode
  clone.ClickEvent = source.ClickEvent
  clone.HideBox = source.HideBox
  return clone
end
function clone_label(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Label")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.Text = source.Text
  clone.BackImage = source.BackImage
  clone.DrawMode = source.DrawMode
  return clone
end
function clone_groupbox(source)
  local gui = nx_value("gui")
  local clone = gui:Create("GroupBox")
  clone.AutoSize = source.AutoSize
  clone.Name = source.Name
  clone.BackColor = source.BackColor
  clone.NoFrame = source.NoFrame
  clone.Left = 0
  clone.Top = 0
  clone.Width = source.Width
  clone.Height = source.Height
  clone.LineColor = source.LineColor
  return clone
end
function clone_mltboxbox(source)
  local gui = nx_value("gui")
  local clone = gui:Create("MultiTextBox")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.HAlign = source.HAlign
  clone.VAlign = source.VAlign
  clone.ViewRect = source.ViewRect
  clone.HtmlText = source.HtmlText
  clone.MouseInBarColor = source.MouseInBarColor
  clone.SelectBarColor = source.SelectBarColor
  clone.TextColor = source.TextColor
  clone.Font = source.Font
  clone.NoFrame = source.NoFrame
  clone.LineColor = source.LineColor
  clone.ViewRect = source.ViewRect
  clone.LineHeight = source.LineHeight
  clone.TextColor = source.TextColor
  clone.SelectBarColor = source.SelectBarColor
  clone.MouseInBarColor = source.MouseInBarColor
  return clone
end
function clone_groupbox_funnpc(form, source, NpcID, NpcTrack, NpcDesc, SchoolFunc, SchoolLogo, SchoolPicture, SchoolTitle)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  local clonegroupbox = clone_groupbox(form.groupbox_funnpcsimple)
  local clonenpcpos = clone_mltboxbox(form.mltbox_npcpos)
  gui.TextManager:Format_SetIDName(NpcTrack)
  gui.TextManager:Format_AddParam(nx_string(NpcID))
  clonenpcpos:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
  local clonenpcbtn = clone_button(form.btn_npc_func_ui)
  clonenpcbtn.Text = nx_widestr("  ") .. nx_widestr(gui.TextManager:GetFormatText(SchoolFunc))
  clonenpcbtn.Align = "Left"
  nx_bind_script(clonenpcbtn, nx_current())
  nx_callback(clonenpcbtn, "on_click", "on_btn_checked_changed")
  clonenpcbtn.schoolTitle = SchoolTitle
  clonenpcbtn.npcDesc = NpcDesc
  clonenpcbtn.schoolLogo = SchoolLogo
  clonenpcbtn.schoolPicture = SchoolPicture
  clonegroupbox:Add(clonenpcbtn)
  clonegroupbox:Add(clonenpcpos)
  if "SchoolFunc_002" == SchoolFunc then
    form.lbl_49.Text = nx_widestr(gui.TextManager:GetFormatText(SchoolTitle))
    form.mltbox_3.HtmlText = nx_widestr(gui.TextManager:GetFormatText(NpcDesc))
    form.lbl_50.BackImage = SchoolLogo
    form.lbl_51.BackImage = SchoolPicture
  end
  return clonegroupbox
end
function on_btn_checked_changed(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  form.lbl_49.Text = nx_widestr(gui.TextManager:GetFormatText(btn.schoolTitle))
  form.mltbox_3.HtmlText = nx_widestr(gui.TextManager:GetFormatText(btn.npcDesc))
  form.lbl_51.BackImage = btn.schoolPicture
end
function on_mltbox_news_click_hyperlink(self, index, data)
  data = nx_string(data)
  local form = self.ParentForm
  if nx_is_valid(form) then
  end
end
function on_btn_voteinfo_click(btn)
  local form = btn.ParentForm
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\School_Config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(school_table[form.SchoolID].school)
  if index < 0 then
    index = 0
  end
  local gui = nx_value("gui")
  form.lbl_kx2.BackImage = ini:ReadString(index, "SchoolPosePhoto", "")
  form.mltbox_school_homepoint_info:Clear()
  form.mltbox_school_homepoint_info:AddHtmlText(nx_widestr(gui.TextManager:GetText(ini:ReadString(index, "SchoolPoseDesc", ""))), nx_int(-1))
  form.btn_declare_war.Visible = false
  form.btn_vote.Visible = true
  form.btn_findpath.Visible = false
  form.btn_backtown.Visible = false
  form.pbar_timedown.Visible = false
  form.lbl_timedown.Visible = false
  form.btn_schoolwar_aid.Visible = false
  form.time.Visible = false
  form.btn_appoint.Visible = false
  form.btn_discharge.Visible = false
  form.lbl_director_title.Visible = false
  form.lbl_director_name.Visible = false
end
function on_btn_declare_warinfo_click(btn)
  local form = btn.ParentForm
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\School_Config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(school_table[form.SchoolID].school)
  if index < 0 then
    index = 0
  end
  form.lbl_kx2.BackImage = ini:ReadString(index, "WardeClarePhoto", "")
  local gui = nx_value("gui")
  form.mltbox_school_homepoint_info:Clear()
  form.mltbox_school_homepoint_info:AddHtmlText(nx_widestr(gui.TextManager:GetText(ini:ReadString(index, "WardeClareDesc", ""))), nx_int(-1))
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local Name = client_player:QueryProp("Name")
  local rows = client_player:FindRecordRow("SchoolPoseRec", 1, Name)
  form.btn_declare_war.Visible = false
  if 0 <= rows then
    local rank = nx_int(client_player:QueryRecord("SchoolPoseRec", rows, SchoolPoseID) % 100 / 10)
    if rank == nx_int(1) then
      form.btn_declare_war.Visible = true
    end
  end
  form.btn_vote.Visible = false
  form.btn_findpath.Visible = false
  form.btn_backtown.Visible = false
  form.pbar_timedown.Visible = false
  form.lbl_timedown.Visible = false
  form.time.Visible = false
  form.btn_schoolwar_aid.Visible = false
  form.btn_appoint.Visible = false
  form.btn_discharge.Visible = false
  form.lbl_director_title.Visible = false
  form.lbl_director_name.Visible = false
end
function on_btn_homepoint_click(btn)
  local form = btn.ParentForm
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\School_Config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(school_table[form.SchoolID].school)
  if index < 0 then
    index = 0
  end
  local gui = nx_value("gui")
  form.mltbox_school_homepoint_info:Clear()
  form.mltbox_school_homepoint_info:AddHtmlText(nx_widestr(gui.TextManager:GetText(ini:ReadString(index, "HomePointDesc", ""))), nx_int(-1))
  local hpid = ini:ReadString(index, "HomePointID", "")
  ini = nx_execute("util_functions", "get_ini", "share\\Rule\\HomePoint.ini")
  if not nx_is_valid(ini) then
    return
  end
  index = ini:FindSectionIndex(hpid)
  if index < 0 then
    return
  end
  form.lbl_kx2.BackImage = ini:ReadString(index, "Ui_Picture", "")
  form.btn_declare_war.Visible = false
  form.btn_vote.Visible = false
  form.btn_findpath.Visible = true
  form.btn_backtown.Visible = true
  form.pbar_timedown.Visible = true
  form.lbl_timedown.Visible = true
  form.time.Visible = true
  form.btn_schoolwar_aid.Visible = false
  form.btn_appoint.Visible = false
  form.btn_discharge.Visible = false
  form.lbl_director_title.Visible = false
  form.lbl_director_name.Visible = false
end
function on_btn_schoolwar_fsl_click(btn)
  local form = btn.ParentForm
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\School_Config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(school_table[form.SchoolID].school)
  if index < 0 then
    index = 0
  end
  local gui = nx_value("gui")
  form.mltbox_school_homepoint_info:Clear()
  form.mltbox_school_homepoint_info:AddHtmlText(nx_widestr(gui.TextManager:GetText(ini:ReadString(index, "SchoolFightCloseDesc", ""))), nx_int(-1))
  form.lbl_kx2.BackImage = ini:ReadString(index, "SchoolFightClosePhoto", "")
  form.btn_declare_war.Visible = false
  form.btn_vote.Visible = false
  form.btn_findpath.Visible = false
  form.btn_backtown.Visible = false
  form.pbar_timedown.Visible = false
  form.lbl_timedown.Visible = false
  form.time.Visible = false
  form.btn_schoolwar_aid.Visible = false
  form.btn_appoint.Visible = false
  form.btn_discharge.Visible = false
  form.lbl_director_title.Visible = false
  form.lbl_director_name.Visible = false
end
function on_btn_schoolwar_aidinfo_click(btn)
  local form = btn.ParentForm
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\School_Config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(school_table[form.SchoolID].school)
  if index < 0 then
    index = 0
  end
  form.lbl_kx2.BackImage = ini:ReadString(index, "WarAskphoto", "")
  local gui = nx_value("gui")
  form.mltbox_school_homepoint_info:Clear()
  form.mltbox_school_homepoint_info:AddHtmlText(nx_widestr(gui.TextManager:GetText(ini:ReadString(index, "WarAskDesc", ""))), nx_int(-1))
  form.btn_declare_war.Visible = false
  form.btn_vote.Visible = false
  form.btn_findpath.Visible = false
  form.btn_backtown.Visible = false
  form.pbar_timedown.Visible = false
  form.lbl_timedown.Visible = false
  form.time.Visible = false
  form.btn_schoolwar_aid.Visible = true
  form.btn_appoint.Visible = false
  form.btn_discharge.Visible = false
  form.lbl_director_title.Visible = false
  form.lbl_director_name.Visible = false
end
function on_btn_schoolwar_aid_click(btn)
  nx_execute("form_stage_main\\form_school_war\\form_school_fight_info", "request_open_form")
end
function on_schoolposman_right_click(lbl)
  local gui = nx_value("gui")
  if gui.TextManager:GetFormatText(nx_string(poseuser)) ~= poseuser then
    return
  end
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_player_menu", true)
  local form = nx_value("form_stage_main\\form_main\\form_player_menu")
  form.AbsLeft = lbl.AbsLeft + lbl.Width / 2
  form.AbsTop = lbl.AbsTop + lbl.Height / 2
  if nx_is_valid(form) then
    form.sender_name = lbl.poseuser
  end
end
function on_btn_schoolwar_director_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\School_Config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(school_table[form.SchoolID].school)
  if index < 0 then
    index = 0
  end
  form.lbl_kx2.BackImage = ini:ReadString(index, "SchoolDirectorPhoto", "")
  local gui = nx_value("gui")
  form.mltbox_school_homepoint_info:Clear()
  form.mltbox_school_homepoint_info:AddHtmlText(nx_widestr(gui.TextManager:GetText(ini:ReadString(index, "SchoolDirectorDesc", ""))), nx_int(-1))
  form.btn_appoint.Visible = false
  form.btn_discharge.Visible = false
  if is_school_leader() then
    form.btn_appoint.Visible = true
    form.btn_discharge.Visible = true
  end
  form.lbl_director_name.Text = nx_widestr("")
  form.lbl_director_title.Visible = true
  form.lbl_director_name.Visible = true
  form.btn_declare_war.Visible = false
  form.btn_vote.Visible = false
  form.btn_findpath.Visible = false
  form.btn_backtown.Visible = false
  form.pbar_timedown.Visible = false
  form.lbl_timedown.Visible = false
  form.time.Visible = false
  form.btn_schoolwar_aid.Visible = false
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 16)
end
function on_btn_appoint_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_school_leader() then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(util_text("ui_schoolwar_title"))
  dialog.info_label.Text = nx_widestr(util_text("ui_norolename"))
  dialog.allow_empty = false
  dialog.name_edit.MaxLength = 20
  dialog:ShowModal()
  local res, text = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 13, 1, nx_widestr(text))
  end
end
function on_btn_discharge_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_school_leader() then
    return
  end
  if nx_ws_length(form.lbl_director_name.Text) == 0 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(util_format_string("ui_SchoolDirector_fire", nx_widestr(form.lbl_director_name.Text)))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 13, 2)
  end
end
function refresh_commander_info(name)
  local form = util_get_form(form_name, false)
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_homepoint.Visible or not form.btn_schoolwar_director.Checked then
    return
  end
  form.lbl_director_name.Text = nx_widestr(name)
end
function is_school_leader()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local name = client_player:QueryProp("Name")
  local rows = client_player:FindRecordRow("SchoolPoseRec", 1, name)
  if 0 <= rows then
    local rank = nx_int(client_player:QueryRecord("SchoolPoseRec", rows, SchoolPoseID) % 100 / 10)
    if rank == nx_int(1) then
      return true
    end
  end
  return false
end
function get_server_time()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return 0
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local strdate = nx_function("format_date_time", nx_double(cur_date_time))
  local table_date = util_split_string(strdate, ";")
  if table.getn(table_date) ~= 2 then
    return 0
  end
  local table_time = util_split_string(table_date[2], ":")
  if table.getn(table_time) ~= 3 then
    return 0
  end
  return nx_number(table_time[1]), nx_number(table_time[2]), nx_number(table_time[3])
end
function refresh_grid_list(grid)
  if not nx_is_valid(grid) then
    return
  end
  clear_grid_data(grid)
  local form = grid.ParentForm
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  grid.ColCount = 4
  grid.ColWidths = "20, 200, 160, 120"
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ini_doc = get_ini("ini\\ui\\schooldevote\\menpai_huodong.ini")
  if nx_is_null(ini_doc) then
    nx_msgbox("ini\188\211\212\216\202\167\176\220")
    return false
  end
  local mgr = nx_value("InteractManager")
  local week = mgr:GetWeek()
  for _, tvt_type in pairs(school_huodong_type) do
    if not ini_doc:FindSection(nx_string(tvt_type)) then
      return false
    end
    if tvt_type == ITT_MENPAIZHAN and week ~= 5 and week ~= 6 then
      return
    end
    local index = ini_doc:FindSectionIndex(nx_string(tvt_type))
    local tvt_name = ini_doc:ReadString(index, "name", "")
    local tvt_prize = ini_doc:ReadString(index, "jl", "")
    local times = mgr:GetInteractTime(tvt_type)
    local max_times = ini_doc:ReadString(index, "Max_times", "")
    local tvt_max_times = util_text("wuxianzhi")
    local tvt_aready_times = 0
    if times ~= -1 then
      tvt_aready_times = times
    end
    if max_times ~= nil and max_times ~= "0" then
      tvt_max_times = max_times
    end
    local row = grid:InsertRow(grid.RowCount)
    grid:SetGridText(row, 1, nx_widestr(gui.TextManager:GetText(tvt_name)))
    grid:SetGridText(row, 2, nx_widestr(tvt_prize))
    grid:SetGridText(row, 3, nx_widestr(tvt_aready_times) .. nx_widestr("/") .. nx_widestr(tvt_max_times))
  end
end
function refresh_gxd(gxd_sum)
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) then
    return
  end
  form.gongxun_crime.Value = gxd_sum
  form.lbl_63.Text = nx_widestr(gxd_sum)
  refresh_grid_list(form.textgrid_2)
end
function clear_grid_data(grid)
  if nx_is_valid(grid) then
    for i = 0, grid.RowCount - 1 do
      local data = grid:GetGridTag(i, 0)
      if nx_is_valid(data) then
        nx_destroy(data)
      end
    end
  end
end
function on_btn_notice_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_notice.Visible == false then
    form.groupbox_notice.Visible = true
    form.btn_notice.Visible = false
    form.btn_notice_close.Visible = true
  end
end
function on_btn_notice_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_notice.Visible == true then
    form.groupbox_notice.Visible = false
    form.btn_notice.Visible = true
    form.btn_notice_close.Visible = false
  end
end
function on_btn_notice_modify_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_school_leader() then
    return
  end
  local gui = nx_value("gui")
  if form.redit_notice.ReadOnly == true then
    form.redit_notice.ReadOnly = false
    form.btn_notice_modify.Text = gui.TextManager:GetText(nx_string("ui_complete"))
  else
    form.redit_notice.ReadOnly = true
    form.btn_notice_modify.Text = gui.TextManager:GetText(nx_string("ui_bianji"))
    local CheckWords = nx_value("CheckWords")
    if not nx_is_valid(CheckWords) then
      return 0
    end
    local new_word = nx_widestr(CheckWords:CleanWords(nx_widestr(form.redit_notice.Text)))
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 22, nx_widestr(new_word))
  end
end
function refresh_school_notice(notice_info)
  local form = util_get_form(form_name, false)
  if not nx_is_valid(form) then
    return
  end
  form.redit_notice.Text = nx_widestr(notice_info)
end
function on_mltbox_3_click_hyperlink(self, index, data)
  local form = self.ParentForm
  local info_list = util_split_string(nx_string(data), nx_string(","))
  local nType = info_list[1]
  local nInfo = info_list[2]
  if nType == "0" then
    ShowPage(form, nx_number(nInfo))
  elseif nType == "1" then
    util_auto_show_hide_form(nInfo)
  end
end
function show_extermin_rbtn(form, b_show)
  if not nx_is_valid(form) then
    return
  end
  local child_control_list = form.groupbox_radio:GetChildControlList()
  local left
  if b_show then
    if form.rbtn_extermin.Left < 0 then
      for _, ctrl in ipairs(child_control_list) do
        if nx_name(ctrl) == "RadioButton" then
          left = ctrl.Left
          ctrl.Left = left + (ctrl.Width + 2)
        end
      end
    end
    form.rbtn_extermin.Visible = true
    form.rbtn_extermin.Checked = true
  else
    for _, ctrl in ipairs(child_control_list) do
      if nx_name(ctrl) == "RadioButton" then
        left = ctrl.Left
        ctrl.Left = left - (ctrl.Width + 2)
      end
    end
    form.rbtn_extermin.Visible = false
    form.btn_msginfo.Checked = true
  end
end
