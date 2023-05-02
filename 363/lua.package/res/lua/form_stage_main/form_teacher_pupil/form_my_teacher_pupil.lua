require("util_gui")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
require("role_composite")
require("tips_data")
require("define\\request_type")
require("form_stage_main\\form_teacher_pupil\\teacherpupil_define")
require("form_stage_main\\form_teacher_pupil\\form_teacherpupil_func")
FLAG_SLT_ERROR = -1
FLAG_SLT_NEIGONG_TEACHER = 0
FLAG_SLT_NEIGONG_PUPIL1 = 1
FLAG_SLT_NEIGONG_PUPIL2 = 2
FLAG_SLT_JINGMAI_TEACHER = 3
FLAG_SLT_JINGMAI_PUPIL1 = 4
FLAG_SLT_JINGMAI_PUPIL2 = 5
BtnSelectFlag = "btnselectflag"
g_select_flag = nil
TPZC_SECTION_TIGUAN = "0"
TPZC_SECTION_BF = "1"
TPZC_SECTION_SCHOOL_FIGHT = "2"
TPZC_SECTION_TEAMFACTULTY = "3"
TPZC_SECTION_CLONEFINISH = "4"
TPZC_SECTION_SHITUTASK = "5"
TP_SECTION_CHUSHI = "chushi"
function on_main_form_init(form)
end
function on_main_form_open(form)
  form.shitu_type = 0
  form.tp_level = 0
  form.tp_acitvity = 0
  form.ng_level = 0
  form.xw_count = 0
  form.groupbox_jingmai_award.Visible = false
  form.textgrid_fuli.Visible = false
  form.textgrid_prize.Visible = true
  form.textgrid_info.Visible = false
  form.body_type = 0
  g_select_flag = get_default_select_flag(form)
  init_prize_grid(form.textgrid_prize)
  refresh_form(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_pupil1_click(btn)
  if not nx_find_custom(btn, BtnSelectFlag) then
    return
  end
  if g_select_flag ~= nx_custom(btn, BtnSelectFlag) then
    g_select_flag = nx_custom(btn, BtnSelectFlag)
    refresh_form(btn.ParentForm)
  end
end
function on_btn_pupil2_click(btn)
  if not nx_find_custom(btn, BtnSelectFlag) then
    return
  end
  if g_select_flag ~= nx_custom(btn, BtnSelectFlag) then
    g_select_flag = nx_custom(btn, BtnSelectFlag)
    refresh_form(btn.ParentForm)
  end
end
function on_btn_quit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  jiechu_shitu_relation(1)
end
function on_btn_xieshang_remove_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  jiechu_shitu_relation(2)
end
function on_btn_qiangzhi_remove_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  jiechu_shitu_relation(3)
end
function on_btn_talk_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = get_current_name()
  if nx_string(name) == "0" or nx_string(name) == "" or name == nil then
    return
  end
  nx_execute("custom_sender", "custom_request_chat", nx_widestr(name))
end
function on_btn_team_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = get_current_name()
  if nx_string(name) == "0" or nx_string(name) == "" or name == nil then
    return
  end
  nx_execute("custom_sender", "custom_team_invite", nx_widestr(name))
end
function on_imagegrid_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_rbtn_1_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  init_prize_grid(form.textgrid_prize)
  if nx_int(ShiTuType_NeiGong) == nx_int(form.shitu_type) then
    show_shitu_prize(form.textgrid_prize, form.tp_acitvity, form.shitu_type, form.tp_level, form.ng_level)
  else
    show_shitu_prize(form.textgrid_prize, form.tp_acitvity, form.shitu_type, form.xw_count)
  end
  form.textgrid_info.Visible = false
  form.textgrid_fuli.Visible = false
  form.textgrid_prize.Visible = true
end
function on_rbtn_2_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  init_grid_fuli_info(form.textgrid_fuli)
  show_fuli_info(form.textgrid_fuli)
  form.textgrid_info.Visible = false
  form.textgrid_fuli.Visible = true
  form.textgrid_prize.Visible = false
end
function on_rbtn_3_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_info.Visible = true
  form.textgrid_prize.Visible = false
  form.textgrid_fuli.Visible = false
  init_grid_shitu_value_info(form.textgrid_info)
  show_shitu_value_info(form.textgrid_info)
end
function on_click_fuli_btn(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = get_current_name()
  if nx_string(name) == "0" or nx_string(name) == "" or name == nil then
    return
  end
  nx_execute("custom_sender", "custom_teacher_pupil", TP_CTS_FULI, btn.fuli_type, nx_widestr(name))
end
function on_btn_return_click(btn)
  nx_execute(FORM_MSG, "show_main_page")
end
function get_self_sex()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sex = client_player:QueryProp("Sex")
  return sex
end
function show_role_model(form, sex, role_info, body_type, face)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not nx_is_valid(form.scenebox_1.Scene) then
    util_addscene_to_scenebox(form.scenebox_1)
  end
  check_actor2_model(form, player, sex, body_type)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  while nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0.1)
  end
  local skin_info = util_split_string(role_info, "#")
  local show_type = nx_int(skin_info[1])
  local body_face = nx_int(skin_info[3])
  local hat = nx_string(skin_info[4])
  local cloth = nx_string(skin_info[5])
  local pants = nx_string(skin_info[6])
  local shoes = nx_string(skin_info[7])
  link_skin(actor2, "hat", hat .. ".xmod", false)
  link_skin(actor2, "cloth", cloth .. ".xmod", false)
  link_skin(actor2, "pants", pants .. ".xmod", false)
  link_skin(actor2, "shoes", shoes .. ".xmod", false)
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    if nx_number(body_face) > nx_number(0) then
      role_composite:LinkFaceSkin(actor2, nx_int(sex), nx_number(body_face), false)
    elseif 0 < string.len(face) then
      role_composite:SetPlayerFaceDetial(get_role_face(actor2), nx_string(face), nx_int(sex), nx_null())
    end
  end
  if nx_int(show_type) == nx_int(1) then
    link_skin(actor2, "cloth_h", cloth .. "_h.xmod", false)
  end
  return add_actor2_to_scenebox(form, actor2)
end
function check_actor2_model(form, player, item_sex, body_type)
  if not nx_is_valid(form) or not nx_is_valid(player) then
    return
  end
  local actor2
  if nx_find_custom(form, "actor2") then
    actor2 = form.actor2
    if nx_is_valid(actor2) and item_sex ~= 2 and item_sex ~= form.sex then
      remove_role(actor2)
    end
  end
  if nx_is_valid(actor2) then
    return
  end
  actor2 = create_role_composite(form.scenebox_1.Scene, true, item_sex, "stand", nx_number(body_type))
  form.sex = item_sex
  form.actor2 = actor2
end
function add_actor2_to_scenebox(form, actor2)
  util_add_model_to_scenebox(form.scenebox_1, actor2)
  local temp_act2 = form.actor2
  if nx_is_valid(temp_act2) then
  end
  form.actor2 = actor2
end
function remove_role(actor2)
  if nx_is_valid(actor2) then
    local world = nx_value("world")
    world:Delete(actor2)
  end
end
function set_role_model_camera(form, body_type)
  if not nx_is_valid(form) then
    return
  end
  local camera = form.scenebox_1.Scene.camera
  if not nx_is_valid(camera) then
    return
  end
  local radius = 0.5
  camera:SetAngle(0, 0, 0)
  if nx_int(body_type) == nx_int(3) or nx_int(body_type) == nx_int(4) then
    camera:SetPosition(0, radius * 2.5, -radius * 2)
  else
    camera:SetPosition(0, radius * 3.1, -radius * 2)
  end
end
function get_default_select_flag(self)
  local player = get_player()
  if not nx_is_valid(player) then
    return FLAG_SLT_ERROR
  end
  if not nx_find_custom(self.btn_pupil1, BtnSelectFlag) then
    nx_set_custom(self.btn_pupil1, BtnSelectFlag, FLAG_SLT_ERROR)
  end
  if not nx_find_custom(self.btn_pupil2, BtnSelectFlag) then
    nx_set_custom(self.btn_pupil1, BtnSelectFlag, FLAG_SLT_ERROR)
  end
  local row_num = 0
  local teacher_count = 0
  local pupil_count = 0
  row_num = player:GetRecordRows(nx_string(TBL_NAME_TEACHERPUPIL_NEIGONG))
  if row_num == 1 then
    local tp_type = player:QueryRecord(nx_string(TBL_NAME_TEACHERPUPIL_NEIGONG), 0, 1)
    if tp_type == 1 then
      nx_set_custom(self.btn_pupil1, BtnSelectFlag, FLAG_SLT_NEIGONG_TEACHER)
      teacher_count = teacher_count + 1
      return FLAG_SLT_NEIGONG_TEACHER
    elseif tp_type == 2 then
      nx_set_custom(self.btn_pupil1, BtnSelectFlag, FLAG_SLT_NEIGONG_PUPIL1)
      pupil_count = pupil_count + 1
    end
  elseif row_num == 2 then
    nx_set_custom(self.btn_pupil1, BtnSelectFlag, FLAG_SLT_NEIGONG_PUPIL1)
    nx_set_custom(self.btn_pupil2, BtnSelectFlag, FLAG_SLT_NEIGONG_PUPIL2)
    pupil_count = pupil_count + 2
  end
  row_num = player:GetRecordRows(nx_string(TBL_NAME_TEACHERPUPIL_JINGMAI))
  if row_num == 1 then
    local tp_type = player:QueryRecord(nx_string(TBL_NAME_TEACHERPUPIL_JINGMAI), 0, 6)
    if tp_type == 1 then
      if 0 < teacher_count then
        return FLAG_SLT_ERROR
      end
      if 0 < pupil_count then
        return FLAG_SLT_ERROR
      end
      nx_set_custom(self.btn_pupil1, BtnSelectFlag, FLAG_SLT_JINGMAI_TEACHER)
      teacher_count = teacher_count + 1
      return FLAG_SLT_JINGMAI_TEACHER
    elseif tp_type == 2 then
      if 0 < teacher_count then
        return FLAG_SLT_ERROR
      end
      if 2 <= pupil_count then
        return FLAG_SLT_ERROR
      end
      if pupil_count == 1 then
        nx_set_custom(self.btn_pupil2, BtnSelectFlag, FLAG_SLT_JINGMAI_PUPIL1)
        pupil_count = pupil_count + 1
      else
        nx_set_custom(self.btn_pupil1, BtnSelectFlag, FLAG_SLT_JINGMAI_PUPIL1)
        pupil_count = pupil_count + 1
      end
    end
  elseif row_num == 2 then
    if 0 < teacher_count then
      return FLAG_SLT_ERROR
    end
    if 0 < pupil_count then
      return FLAG_SLT_ERROR
    end
    nx_set_custom(self.btn_pupil1, BtnSelectFlag, FLAG_SLT_JINGMAI_PUPIL1)
    nx_set_custom(self.btn_pupil2, BtnSelectFlag, FLAG_SLT_JINGMAI_PUPIL2)
  end
  return nx_custom(self.btn_pupil1, BtnSelectFlag)
end
function get_current_name()
  local current_select = g_select_flag
  local tbl = ""
  local row = 0
  local col = 0
  if current_select == FLAG_SLT_NEIGONG_TEACHER then
    tbl = TBL_NAME_TEACHERPUPIL_NEIGONG
    row = 0
    col = 0
  elseif current_select == FLAG_SLT_NEIGONG_PUPIL1 then
    tbl = TBL_NAME_TEACHERPUPIL_NEIGONG
    row = 0
    col = 0
  elseif current_select == FLAG_SLT_NEIGONG_PUPIL2 then
    tbl = TBL_NAME_TEACHERPUPIL_NEIGONG
    row = 1
    col = 0
  elseif current_select == FLAG_SLT_JINGMAI_TEACHER then
    tbl = TBL_NAME_TEACHERPUPIL_JINGMAI
    row = 0
    col = 1
  elseif current_select == FLAG_SLT_JINGMAI_PUPIL1 then
    tbl = TBL_NAME_TEACHERPUPIL_JINGMAI
    row = 0
    col = 1
  elseif current_select == FLAG_SLT_JINGMAI_PUPIL2 then
    tbl = TBL_NAME_TEACHERPUPIL_JINGMAI
    row = 1
    col = 1
  else
    return ""
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return ""
  end
  return player:QueryRecord(tbl, row, col)
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
  if table.getn(table_prop_name) <= 0 then
    return
  end
  table_prop_value.ConfigID = nx_string(prize_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", "task_grid_data")
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_set_custom(grid.Data, "is_static", true)
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
  grid.Data:ClearChild()
end
function get_incbuffcount(xw_count)
  local player = get_player()
  if not nx_is_valid(player) then
    return 0, 0
  end
  local canbuy_count = 0
  local buy_count = 0
  if player:FindProp("ShiTu_IncFacultyTimes") then
    buy_count = player:QueryProp("ShiTu_IncFacultyTimes")
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\shitu\\jingmaiteacherpupil.ini")
  if not nx_is_valid(ini) then
    return 0, 0
  end
  local sec_index = ini:FindSectionIndex("buffcount")
  if nx_int(sec_index) < nx_int(0) then
    return 0, 0
  end
  local group_data = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, nx_number(table.getn(group_data)) do
    local step_data = util_split_string(group_data[i], ",")
    if nx_int(step_data[1]) == nx_int(xw_count) then
      canbuy_count = nx_int(step_data[2])
      break
    end
  end
  if canbuy_count == 0 then
    local last_index = table.getn(group_data)
    local step_data = util_split_string(group_data[last_index], ",")
    canbuy_count = nx_int(step_data[2])
  end
  return canbuy_count, buy_count
end
function get_facultycount(xw_count)
  local player = get_player()
  if not nx_is_valid(player) then
    return 0, 0, 0
  end
  local facultycount = 0
  local canfacultycount = 0
  local weekfacultycount = 0
  local weekcanfacultycount = 0
  if player:FindProp("ShiTu_IncFacultyTimes") then
    facultycount = player:QueryProp("ShiTu_IncFacultyTimes")
  end
  if player:FindProp("ShiTu_WeekIncFacultyTimes") then
    weekfacultycount = player:QueryProp("ShiTu_WeekIncFacultyTimes")
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\jingmaiteacherpupil.ini")
  if not nx_is_valid(ini) then
    return 0, 0, 0
  end
  local sec_index = ini:FindSectionIndex("buffcount")
  if nx_int(sec_index) < nx_int(0) then
    return 0, 0, 0
  end
  local group_data = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, nx_number(table.getn(group_data)) do
    local step_data = util_split_string(group_data[i], ",")
    if nx_int(step_data[1]) == nx_int(xw_count) then
      canfacultycount = nx_int(step_data[2])
      break
    end
  end
  if canfacultycount == 0 then
    local last_index = table.getn(group_data)
    local step_data = util_split_string(group_data[last_index], ",")
    canfacultycount = nx_int(step_data[2])
  end
  sec_index = ini:FindSectionIndex("TeamFaculty")
  if nx_int(sec_index) < nx_int(0) then
    return 0, 0, 0
  end
  weekcanfacultycount = ini:ReadInteger(sec_index, "WeekIncBufferTimes", 0)
  local allcanteamcount = canfacultycount - facultycount
  local weekcanfacultycount = weekcanfacultycount - weekfacultycount
  if nx_int(weekcanfacultycount) > nx_int(allcanteamcount) then
    weekcanfacultycount = allcanteamcount
  end
  if nx_int(allcanteamcount) < nx_int(0) then
    allcanteamcount = 0
  end
  if nx_int(weekcanfacultycount) < nx_int(0) then
    weekcanfacultycount = 0
  end
  return allcanteamcount, weekfacultycount, weekcanfacultycount
end
function get_sliver()
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\teacherpupil.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("BaseConfig")
  if index < 0 then
    return
  end
  local capital_type = ini:ReadInteger(index, "CapitalType", 0)
  local capital_count = ini:ReadInteger(index, "CapitalTypecount", 0)
  return capital_type, capital_count
end
function jiechu_shitu_relation(jiechu_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  dialog.mltbox_info:Clear()
  local type, count = get_sliver()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(jiechu_type) == nx_int(1) then
    gui.TextManager:Format_SetIDName("ui_shitu_shituguanxi")
  elseif nx_int(jiechu_type) == nx_int(2) then
    gui.TextManager:Format_SetIDName("ui_shitu_jiechu_4")
  else
    gui.TextManager:Format_SetIDName("ui_shitu_jiechu_3")
  end
  gui.TextManager:Format_AddParam(nx_int(count))
  local text = gui.TextManager:Format_GetText()
  dialog.mltbox_info:AddHtmlText(nx_widestr(text), -1)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local name = get_current_name()
    if nx_string(name) == "0" or nx_string(name) == "" or name == nil then
      return
    end
    if nx_int(jiechu_type) == nx_int(1) then
      nx_execute("custom_sender", "custom_teacher_pupil", TP_CTS_JIECHU, nx_widestr(name))
    elseif nx_int(jiechu_type) == nx_int(2) then
      nx_execute("custom_sender", "custom_request", 64, nx_widestr(name))
    elseif nx_int(jiechu_type) == nx_int(3) then
      nx_execute("custom_sender", "custom_teacher_pupil", TP_CTS_FORCE_JIECHU, nx_widestr(name))
    end
    local closeform = nx_value("form_stage_main\\form_school_war\\form_school_msg_info")
    if nx_is_valid(closeform) then
      closeform:Close()
    end
  end
end
function refresh_form(form)
  if g_select_flag == FLAG_SLT_NEIGONG_TEACHER or g_select_flag == FLAG_SLT_NEIGONG_PUPIL1 or g_select_flag == FLAG_SLT_NEIGONG_PUPIL2 then
    refresh_neigong(form)
  elseif g_select_flag == FLAG_SLT_JINGMAI_TEACHER or g_select_flag == FLAG_SLT_JINGMAI_PUPIL1 or g_select_flag == FLAG_SLT_JINGMAI_PUPIL2 then
    nx_execute("custom_sender", "custom_teacher_pupil", 8)
    refresh_jingmai(form)
  end
end
function refresh_neigong(form)
  local record_idx = 0
  if g_select_flag == FLAG_SLT_NEIGONG_PUPIL2 then
    record_idx = 1
  end
  player = get_player()
  if player:GetRecordRows(TBL_NAME_TEACHERPUPIL_NEIGONG) == 0 then
    return
  end
  local name = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 0)
  local power_level = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 2)
  local baishi_time = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 3)
  local is_online = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 6)
  local ng_level = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 8)
  local phase_level = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 9)
  local tp_level = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 10)
  local tp_acitvity = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 11)
  local tp_sex = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 12)
  local role_info = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 13)
  local school_id = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 19)
  local role_model_info = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 17)
  local face = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 20)
  school_id = get_school_id(school_id)
  if nx_int(0) == nx_int(tp_level) then
    return
  end
  if g_select_flag == FLAG_SLT_NEIGONG_TEACHER then
    ng_level = get_pupil_current_level(tp_level)
    phase_level = get_pupil_phase_level()
    school_id = get_self_school_id()
  end
  form.lbl_name.Text = nx_widestr(name)
  form.lbl_powerlevel.Text = nx_widestr(Get_PowerLevel_Name(power_level))
  form.lbl_tptime.Text = nx_widestr(get_date_string(baishi_time))
  local shitu_value = get_shitu_value()
  form.lbl_tpvalue.Text = nx_widestr(shitu_value)
  local info = util_split_string(nx_string(role_model_info), ",")
  local face, offset = get_face(info)
  local body_type = 0
  if table.getn(info) >= 37 + offset then
    body_type = nx_int(info[37 + offset])
  end
  show_role_model(form, tp_sex, role_info, body_type, face)
  set_role_model_camera(form, body_type)
  refresh_ng_left(form, school_id, ng_level, tp_level, tp_sex)
  show_shitu_prize(form.textgrid_prize, tp_acitvity, ShiTuType_NeiGong, tp_level, ng_level)
  form.shitu_type = ShiTuType_NeiGong
  form.tp_level = tp_level
  form.tp_acitvity = tp_acitvity
  form.ng_level = ng_level
  if nx_int(is_online) == nx_int(0) then
    form.btn_xieshang_remove.Enabled = true
  else
    form.btn_xieshang_remove.Enabled = false
  end
  form.groupbox_jingmai_award.Visible = false
end
function refresh_ng_left(form, school_id, ng_level, tp_level, sex)
  local ng_name = get_pupil_neigong_id(school_id, tp_level)
  if g_select_flag == FLAG_SLT_NEIGONG_TEACHER then
    form.btn_pupil1.Visible = false
    form.btn_pupil2.Visible = false
    form.lbl_teacher_title.Text = util_text("ui_shitu_teacher_0" .. nx_string(tp_level) .. "_" .. nx_string(sex))
    form.lbl_him.Text = util_text("ui_shitu_shenfen_01")
    form.lbl_me.Text = util_text("ui_shitu_wodezhuangtai")
    local school_name = get_school_name()
    form.lbl_himinfo.Text = school_name .. util_text("ui_shitu_teacher_0" .. nx_string(tp_level) .. "_" .. nx_string(sex))
    form.lbl_myinfo.Text = nx_widestr(util_text(ng_name)) .. nx_widestr(ng_level) .. util_text("ui_shitu_ceng")
  elseif g_select_flag == FLAG_SLT_NEIGONG_PUPIL1 or g_select_flag == FLAG_SLT_NEIGONG_PUPIL2 then
    form.lbl_teacher_title.Visible = false
    if nx_execute(nx_string(FORM_FUNC), "get_teacher_pupil_count") <= 1 then
      form.btn_pupil2.Enabled = false
    end
    form.lbl_him.Text = util_text("ui_shitu_dangqianzhuangtai_01")
    form.lbl_me.Text = util_text("ui_shitu_wodeshenfen")
    form.lbl_himinfo.Text = nx_widestr(util_text(ng_name)) .. nx_widestr(ng_level) .. util_text("ui_shitu_ceng")
    local school_name = get_school_name()
    local self_sex = get_self_sex()
    form.lbl_myinfo.Text = school_name .. util_text("ui_shitu_teacher_0" .. nx_string(tp_level) .. "_" .. nx_string(self_sex))
  end
end
function refresh_jingmai(form)
  local record_idx = 0
  if g_select_flag == FLAG_SLT_JINGMAI_PUPIL2 then
    record_idx = 1
  end
  player = get_player()
  if player:GetRecordRows(TBL_NAME_TEACHERPUPIL_JINGMAI) == 0 then
    return
  end
  local name = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 1)
  local tp_sex = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 3)
  local role_info = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 4)
  local role_model_info = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 5)
  local baishi_time = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 7)
  local tp_acitvity = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 9)
  local is_online = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 10)
  local xw_count = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 11)
  local power_level = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 13)
  local face = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 16)
  if g_select_flag == FLAG_SLT_JINGMAI_TEACHER then
    xw_count = get_pupil_jingmai_xwcount()
  end
  form.lbl_name.Text = nx_widestr(name)
  form.lbl_powerlevel.Text = nx_widestr(Get_PowerLevel_Name(power_level))
  form.lbl_tptime.Text = nx_widestr(get_date_string(baishi_time))
  local shitu_value = get_shitu_value()
  form.lbl_tpvalue.Text = nx_widestr(shitu_value)
  local info = util_split_string(nx_string(role_model_info), ",")
  local face, offset = get_face(info)
  local body_type = 0
  if table.getn(info) >= 37 + offset then
    body_type = nx_int(info[37 + offset])
  end
  show_role_model(form, tp_sex, role_info, body_type, face)
  set_role_model_camera(form, body_type)
  refresh_jm_left(form, xw_count, tp_sex)
  refresh_jm_award(form, xw_count)
  show_shitu_prize(form.textgrid_prize, tp_acitvity, ShiTuType_JingMai, xw_count)
  form.shitu_type = ShiTuType_JingMai
  form.xw_count = xw_count
  form.tp_acitvity = tp_acitvity
  if nx_int(is_online) == nx_int(0) then
    form.btn_xieshang_remove.Enabled = true
  else
    form.btn_xieshang_remove.Enabled = false
  end
end
function refresh_jm_award(form, xw_count)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupbox_jingmai_award.Visible = true
  form.lbl_jingmai_canbuycount.Visible = true
  form.lbl_jingmai_buycount.Visible = true
  if g_select_flag == FLAG_SLT_JINGMAI_TEACHER then
    canbuycount, buycount = get_incbuffcount(xw_count)
    form.lbl_jingmai_canbuycount.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_jingmai_2", nx_int(canbuycount)))
    form.lbl_jingmai_buycount.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_jingmai_3", nx_int(canbuycount - buycount)))
    form.mltbox_jingmai_xwcount.HtmlText = util_text("ui_shitu_jingmai_4")
  elseif g_select_flag == FLAG_SLT_JINGMAI_PUPIL1 or g_select_flag == FLAG_SLT_JINGMAI_PUPIL2 then
    canfacultycount, weekfacultycount, canweekfacultycount = get_facultycount(xw_count)
    form.lbl_jingmai_canbuycount.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_jingmai_3", nx_int(canfacultycount)))
    form.lbl_jingmai_buycount.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_jingmai_11", nx_int(weekfacultycount), nx_int(canweekfacultycount)))
    form.mltbox_jingmai_xwcount.HtmlText = util_text("ui_shitu_jingmai_8")
  end
end
function refresh_jm_left(form, xw_count, sex)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if g_select_flag == FLAG_SLT_JINGMAI_TEACHER then
    form.btn_pupil1.Visible = false
    form.btn_pupil2.Visible = false
    form.lbl_teacher_title.Visible = true
    form.lbl_teacher_title.Text = util_text("ui_shitu_jingmai_sx_" .. nx_string(sex))
    form.lbl_him.Text = util_text("ui_shitu_shenfen_01")
    form.lbl_me.Text = util_text("ui_shitu_wodezhuangtai")
    local school_name = get_school_name()
    form.lbl_himinfo.Text = school_name .. util_text("ui_shitu_jingmai_sx_" .. nx_string(sex))
    form.lbl_myinfo.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_xuwei", nx_int(xw_count)))
  elseif g_select_flag == FLAG_SLT_JINGMAI_PUPIL1 or g_select_flag == FLAG_SLT_JINGMAI_PUPIL2 then
    form.btn_pupil1.Visible = true
    form.btn_pupil2.Visible = true
    form.lbl_teacher_title.Visible = false
    if get_teacher_pupil_count() <= 1 then
      form.btn_pupil2.Enabled = false
    end
    form.lbl_him.Text = util_text("ui_shitu_dangqianzhuangtai_01")
    form.lbl_me.Text = util_text("ui_shitu_wodeshenfen")
    local school_name = get_school_name()
    local self_sex = get_self_sex()
    form.lbl_himinfo.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_xuwei", nx_int(xw_count)))
    form.lbl_myinfo.Text = school_name .. util_text("ui_shitu_jingmai_sx_" .. nx_string(self_sex))
  end
end
function init_prize_grid(grid)
  grid:ClearRow()
  grid.ColCount = 3
  for i = 1, grid.ColCount do
    grid:SetColAlign(i - 1, "center")
  end
  grid:SetColTitle(0, nx_widestr(util_text("ui_huodong")))
  grid:SetColTitle(1, nx_widestr(util_text("ui_jiangli")))
  grid:SetColTitle(2, nx_widestr(util_text("ui_wanchengdu")))
  grid.cur_editor_row = -1
  grid.current_task_id = ""
  grid.CanSelectRow = false
end
function show_shitu_prize(grid, ...)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\teacherpupil\\shituprice_ui.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string("zhouchang"))
  local shitu_flag = get_shitu_flag()
  if nx_int(shitu_flag) == nx_int(0) then
    return
  end
  grid:ClearRow()
  if 0 <= sec_index then
    local prize_list = ini:GetItemValueList(sec_index, nx_string("r"))
    local count = table.getn(prize_list)
    local tp_acitvity = nx_int(arg[1])
    for i = 1, count do
      local prize_info = util_split_string(prize_list[i], ",")
      local active_type = nx_int(prize_info[1]) + 1
      local flag = nx_function("ext_get_bit_value", nx_int(tp_acitvity), nx_int(active_type))
      InsertPrizeInfo(grid, shitu_flag, flag, prize_info)
    end
  end
  local shitu_type = nx_int(arg[2])
  if nx_int(shitu_type) == nx_int(ShiTuType_NeiGong) then
    local tp_level = nx_int(arg[3])
    local cur_ng_level = nx_int(arg[4])
    sec_index = ini:FindSectionIndex("neigong" .. nx_string(tp_level))
    if 0 <= sec_index then
      local prize_list = ini:GetItemValueList(sec_index, nx_string("r"))
      local count = table.getn(prize_list)
      for i = 1, count do
        local prize_info = util_split_string(prize_list[i], ",")
        local ng_level = nx_int(prize_info[1])
        local flag = 0
        if nx_int(ng_level) <= nx_int(cur_ng_level) then
          flag = 1
        end
        InsertPrizeInfo(grid, shitu_flag, flag, prize_info)
      end
    end
  elseif nx_int(shitu_type) == nx_int(ShiTuType_JingMai) then
    local xuewei_count = nx_int(arg[3])
    sec_index = ini:FindSectionIndex("jingmai")
    if 0 <= sec_index then
      local prize_list = ini:GetItemValueList(sec_index, nx_string("r"))
      local count = table.getn(prize_list)
      for i = 1, count do
        local prize_info = util_split_string(prize_list[i], ",")
        local xw_count = nx_int(prize_info[1])
        local flag = 0
        if nx_int(xw_count) <= nx_int(xuewei_count) then
          flag = 1
        end
        InsertPrizeInfo(grid, shitu_flag, flag, prize_info)
      end
    end
  end
end
function CreateImage(item_list)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local count = table.getn(item_list)
  if nx_number(0) >= nx_number(count) then
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local image_grid = gui:Create("ImageGrid")
  if not nx_is_valid(image_grid) then
    return
  end
  set_copy_ent_info(form, "imagegrid_award", image_grid)
  nx_bind_script(image_grid, nx_current())
  nx_callback(image_grid, "on_mousein_grid", "on_imagegrid_mousein_grid")
  nx_callback(image_grid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
  for i = 1, count do
    local item_id = nx_string(item_list[i])
    local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
    image_grid:AddItem(i - 1, photo, nx_widestr(item_id), 1, -1)
  end
  return image_grid
end
function create_lbl(png_path)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local label_flag = gui:Create("Label")
  label_flag.Left = 20
  label_flag.Top = 3
  label_flag.Hight = 26
  label_flag.AutoSize = true
  label_flag.BackImage = png_path
  label_flag.Transparent = false
  return label_flag
end
function set_copy_ent_info(form, source, target_ent)
  local source_ent = nx_custom(form, source)
  if not nx_is_valid(source_ent) then
    return
  end
  local prop_list = nx_property_list(source_ent)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(target_ent, prop, nx_property(source_ent, prop))
    end
  end
end
function create_multitext()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local multitextbox = gui:Create("MultiTextBox")
  if not nx_is_valid(multitextbox) then
    return
  end
  multitextbox.AutoSize = false
  multitextbox.Transparent = true
  multitextbox.Name = "MultiTextBox_path_" .. nx_string(i)
  multitextbox.TextColor = "255,128,101,74"
  multitextbox.SelectBarColor = "0,0,0,0"
  multitextbox.MouseInBarColor = "0,0,0,0"
  multitextbox.Font = "font_text"
  multitextbox.LineColor = "0,0,0,0"
  multitextbox.ShadowColor = "0,0,0,0"
  multitextbox.ViewRect = "0,0,310,80"
  return multitextbox
end
function create_button()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local button = gui:Create("Button")
  if not nx_is_valid(button) then
    return
  end
  button.Left = 0
  button.Top = 15
  button.Hight = 26
  button.AutoSize = true
  button.NormalImage = "gui\\common\\button\\btn_normal2_out.png"
  button.FocusImage = "gui\\common\\button\\btn_normal2_on.png"
  button.PushImage = "gui\\common\\button\\btn_normal2_down.png"
  nx_bind_script(button, nx_current())
  nx_callback(button, "on_click", "on_click_fuli_btn")
  return button
end
function InsertPrizeInfo(grid, shitu_flag, is_finish, prize_info)
  local row = grid:InsertRow(-1)
  local mText = create_multitext()
  local info, prize_desc
  if nx_int(shitu_flag) == nx_int(Junior_fellow_apprentice) then
    prize_desc = prize_info[2]
    info = prize_info[4]
  elseif nx_int(shitu_flag) == nx_int(Senior_fellow_apprentice) then
    prize_desc = prize_info[3]
    info = prize_info[5]
  end
  local width = grid:GetColWidth(0)
  mText.ViewRect = "0,0," .. nx_string(width) .. ",80"
  mText.HtmlText = util_text(prize_desc)
  grid:SetGridControl(row, 0, mText)
  local prize = util_split_string(info, ";")
  local type = nx_int(prize[1])
  if nx_int(type) == nx_int(1) then
    local mText = create_multitext()
    mText.HtmlText = util_text(prize[2])
    grid:SetGridControl(row, 1, mText)
  elseif nx_int(type) == nx_int(2) then
    local item_list = util_split_string(prize[2], "|")
    local image_grid = CreateImage(item_list)
    grid:SetGridControl(row, 1, image_grid)
  end
  local image = ""
  if nx_int(is_finish) == nx_int(0) then
    image = UN_SUCCESS_PNG_PATTH
  else
    image = SUCCESS_PNG_PATTH
  end
  local lbl = create_lbl(image)
  grid:SetGridControl(row, 2, lbl)
end
function init_grid_fuli_info(grid)
  grid:ClearRow()
  grid.ColCount = 2
  for i = 1, grid.ColCount do
    grid:SetColAlign(i - 1, "center")
  end
  grid:SetColTitle(0, nx_widestr(util_text("ui_force_name")))
  grid:SetColTitle(1, nx_widestr(util_text("ui_force_prize")))
  grid.cur_editor_row = -1
  grid.current_task_id = ""
  grid.CanSelectRow = false
end
function show_fuli_info(grid)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\teacherpupil\\shitufl.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  grid:ClearRow()
  local sec_count = ini:GetSectionCount()
  local shitu_flag = get_shitu_flag()
  for i = 0, sec_count - 1 do
    local fuli_list = ini:GetItemValueList(i, nx_string("r"))
    local count = table.getn(fuli_list)
    for j = 1, count do
      local fuli_info = util_split_string(fuli_list[j], ",")
      if nx_int(fuli_info[1]) == nx_int(shitu_flag) then
        local row = grid:InsertRow(-1)
        local mText = create_multitext()
        mText.HtmlText = util_text(fuli_info[2])
        local width = grid:GetColWidth(0)
        mText.ViewRect = "0,0," .. nx_string(width) .. ",80"
        grid:SetGridControl(row, 0, mText)
        local type = nx_int(ini:GetSectionByIndex(i))
        local btn = create_button()
        btn.fuli_type = type
        btn.Text = nx_widestr(util_text(fuli_info[3]))
        grid:SetGridControl(row, 1, btn)
      end
    end
  end
end
function init_grid_shitu_value_info(grid)
  grid:ClearRow()
  grid.ColCount = 1
  for i = 1, grid.ColCount do
    grid:SetColAlign(i - 1, "center")
  end
  grid:SetColTitle(0, nx_widestr(util_text("ui_shitu_14")))
  grid.cur_editor_row = -1
  grid.current_task_id = ""
  grid.CanSelectRow = false
  grid.Visible = true
end
function show_shitu_value_info(grid)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\teacherpupil\\shitu_value.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string("ShiTuValueInfo"))
  grid:ClearRow()
  local width = grid:GetColWidth(0)
  if 0 <= sec_index then
    local info_list = ini:GetItemValueList(sec_index, nx_string("r"))
    local count = table.getn(info_list)
    for i = 1, count do
      local info = info_list[i]
      local row = grid:InsertRow(-1)
      local mText = create_multitext()
      mText.ViewRect = "0,0," .. nx_string(width) .. ",80"
      mText.HtmlText = util_text(nx_string(info))
      grid:SetGridControl(row, 0, mText)
    end
  end
end
function get_face(role_info_table)
  local face = role_info_table[6]
  local count = table.getn(role_info_table)
  local offset = 0
  for i = 7, count do
    if string.len(face) > 46 or string.len(face) == 46 then
      return face, offset
    end
    face = face .. string.char(44) .. role_info_table[i]
    offset = offset + 1
  end
  return face, offset
end
function get_role_face(actor2)
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor_role_face = actor_role:GetLinkObject("actor_role_face")
  if not nx_is_valid(actor_role_face) then
    return nil
  end
  return actor_role_face
end
