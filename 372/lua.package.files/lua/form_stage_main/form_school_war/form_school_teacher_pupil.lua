require("util_gui")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
require("role_composite")
require("form_stage_main\\form_school_war\\form_school_teacher_pupil_func")
require("tips_data")
FUNC_PATH = "form_stage_main\\form_school_war\\form_school_teacher_pupil_func"
SUCCESS_PNG_PATTH = "gui\\language\\chineses\\wancheng.png"
UN_SUCCESS_PNG_PATTH = "gui\\language\\chineses\\weiwancheng.png"
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
function open_form()
  if nx_execute("form_stage_main\\form_school_war\\form_school_teacher_pupil_func", "get_teacher_pupil_count") > 0 then
    nx_execute("form_stage_main\\form_school_war\\form_school_msg_info", "open_school_form_and_show_sub_page", 8)
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("16571"))
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
  local shitu_value = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 5)
  local is_online = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 6)
  local ng_level = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 8)
  local phase_level = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 9)
  local tp_level = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 10)
  local tp_acitvity = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 11)
  local tp_sex = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 12)
  local role_info = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, record_idx, 13)
  local ng_name = get_pupil_neigong_name(tp_level)
  if nx_int(0) == nx_int(tp_level) then
    return
  end
  if g_select_flag == FLAG_SLT_NEIGONG_TEACHER then
    ng_level = get_pupil_current_level(tp_level)
    phase_level = get_pupil_phase_level()
  end
  form.lbl_name.Text = nx_widestr(name)
  form.lbl_powerlevel.Text = nx_widestr(Get_PowerLevel_Name(power_level))
  form.lbl_tptime.Text = nx_widestr(get_date_string(baishi_time))
  form.lbl_tpvalue.Text = nx_widestr(shitu_value)
  show_role_model(form, tp_sex, role_info)
  set_role_model_camera(form)
  refresh_ng_left(form, ng_name, ng_level, tp_level, tp_sex)
  refresh_zhouchang_award(form, tp_acitvity)
  refresh_zhouchang_award_icon(form)
  form.groupbox_neigong_award.Visible = true
  form.groupbox_jingmai_award.Visible = false
  refresh_ng_phase_award(form, ng_name, ng_level, phase_level, tp_level)
  refresh_ng_chushi_award(form, tp_level)
  if nx_int(is_online) == nx_int(0) then
    form.btn_xieshang_remove.Enabled = true
  else
    form.btn_xieshang_remove.Enabled = false
  end
end
function refresh_ng_left(form, ng_name, ng_level, tp_level, sex)
  if g_select_flag == FLAG_SLT_NEIGONG_TEACHER then
    form.btn_pupil1.Visible = false
    form.btn_pupil2.Visible = false
    if tp_level == 2 then
      form.lbl_teacher_title.Text = util_text("ui_shitu_teacher_02_" .. nx_string(sex))
    elseif tp_level == 3 then
      form.lbl_teacher_title.Text = util_text("ui_shitu_teacher_03_" .. nx_string(sex))
    end
    form.lbl_him.Text = util_text("ui_shitu_shenfen_01")
    form.lbl_me.Text = util_text("ui_shitu_wodezhuangtai")
    local school_name = get_school_name()
    if tp_level == 2 then
      form.lbl_himinfo.Text = school_name .. util_text("ui_shitu_teacher_02_" .. nx_string(sex))
    elseif tp_level == 3 then
      form.lbl_himinfo.Text = school_name .. util_text("ui_shitu_teacher_03_" .. nx_string(sex))
    end
    form.lbl_myinfo.HtmlText = nx_widestr(ng_name) .. nx_widestr(ng_level) .. util_text("ui_shitu_ceng")
  elseif g_select_flag == FLAG_SLT_NEIGONG_PUPIL1 or g_select_flag == FLAG_SLT_NEIGONG_PUPIL2 then
    form.lbl_teacher_title.Visible = false
    if nx_execute(FUNC_PATH, "get_teacher_pupil_count") <= 1 then
      form.btn_pupil2.Enabled = false
    end
    form.lbl_him.Text = util_text("ui_shitu_dangqianzhuangtai_01")
    form.lbl_me.Text = util_text("ui_shitu_wodeshenfen")
    form.lbl_himinfo.Text = nx_widestr(ng_name) .. nx_widestr(ng_level) .. util_text("ui_shitu_ceng")
    local school_name = get_school_name()
    local self_sex = get_self_sex()
    if tp_level == 2 then
      form.lbl_myinfo.Text = school_name .. util_text("ui_shitu_teacher_02_" .. nx_string(self_sex))
    elseif tp_level == 3 then
      form.lbl_myinfo.HtmlText = school_name .. util_text("ui_shitu_teacher_03_" .. nx_string(self_sex))
    end
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
  local baishi_time = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 7)
  local tp_acitvity = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 9)
  local is_online = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 10)
  local xw_count = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 11)
  local shitu_value = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 12)
  local power_level = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, record_idx, 13)
  if g_select_flag == FLAG_SLT_JINGMAI_TEACHER then
    xw_count = get_pupil_jingmai_xwcount()
  end
  form.lbl_name.Text = nx_widestr(name)
  form.lbl_powerlevel.Text = nx_widestr(Get_PowerLevel_Name(power_level))
  form.lbl_tptime.Text = nx_widestr(get_date_string(baishi_time))
  form.lbl_tpvalue.Text = nx_widestr(shitu_value)
  show_role_model(form, tp_sex, role_info)
  set_role_model_camera(form)
  refresh_jm_left(form, xw_count, tp_sex)
  refresh_zhouchang_award(form, tp_acitvity)
  refresh_zhouchang_award_icon(form)
  form.groupbox_neigong_award.Visible = false
  form.groupbox_jingmai_award.Visible = true
  refresh_jm_award(form, xw_count)
  if nx_int(is_online) == nx_int(0) then
    form.btn_xieshang_remove.Enabled = true
  else
    form.btn_xieshang_remove.Enabled = false
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
    if nx_execute(FUNC_PATH, "get_teacher_pupil_count") <= 1 then
      form.btn_pupil2.Enabled = false
    end
    form.lbl_him.Text = util_text("ui_shitu_dangqianzhuangtai_01")
    form.lbl_me.Text = util_text("ui_shitu_wodeshenfen")
    local school_name = get_school_name()
    local self_sex = get_self_sex()
    form.lbl_himinfo.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_xuwei", nx_int(xw_count)))
    form.lbl_myinfo.HtmlText = school_name .. util_text("ui_shitu_jingmai_sx_" .. nx_string(self_sex))
  end
end
function refresh_jm_award(form, xw_count)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.mltbox_jingmai_bycount.Visible = true
  form.lbl_jingmai_canbuycount.Visible = true
  form.lbl_jingmai_buycount.Visible = true
  if g_select_flag == FLAG_SLT_JINGMAI_TEACHER then
    canbuycount, buycount = get_incbuffcount(xw_count)
    form.mltbox_jingmai_bycount.HtmlText = util_text("ui_shitu_jingmai_1")
    form.lbl_jingmai_canbuycount.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_jingmai_2", nx_int(canbuycount)))
    form.lbl_jingmai_buycount.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_jingmai_3", nx_int(canbuycount - buycount)))
    form.mltbox_jingmai_xwcount.HtmlText = util_text("ui_shitu_jingmai_4")
    form.lbl_jingmai_xwcount.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_jingmai_5", nx_int(xw_count)))
    form.mltbox_jingmai_info:Clear()
    form.mltbox_jingmai_info:AddHtmlText(util_text("ui_shitu_jingmai_6"), nx_int(-1))
  elseif g_select_flag == FLAG_SLT_JINGMAI_PUPIL1 or g_select_flag == FLAG_SLT_JINGMAI_PUPIL2 then
    canfacultycount, weekfacultycount, canweekfacultycount = get_facultycount(xw_count)
    form.mltbox_jingmai_bycount.HtmlText = util_text("ui_shitu_jingmai_10")
    form.lbl_jingmai_canbuycount.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_jingmai_3", nx_int(canfacultycount)))
    form.lbl_jingmai_buycount.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_jingmai_11", nx_int(weekfacultycount), nx_int(canweekfacultycount)))
    form.mltbox_jingmai_xwcount.HtmlText = util_text("ui_shitu_jingmai_8")
    form.lbl_jingmai_xwcount.Text = nx_widestr(gui.TextManager:GetFormatText("ui_shitu_jingmai_5", nx_int(xw_count)))
    form.mltbox_jingmai_info:Clear()
    form.mltbox_jingmai_info:AddHtmlText(util_text("ui_shitu_jingmai_9"), nx_int(-1))
  end
end
function refresh_zhouchang_award(form, tp_acitvity)
  local tiguan = nx_function("ext_get_bit_value", nx_int(tp_acitvity), nx_int(1))
  local jindi = nx_function("ext_get_bit_value", nx_int(tp_acitvity), nx_int(5))
  local shouye = nx_function("ext_get_bit_value", nx_int(tp_acitvity), nx_int(6))
  if tiguan == 0 then
    form.lbl_tiguan.BackImage = UN_SUCCESS_PNG_PATTH
  else
    form.lbl_tiguan.BackImage = SUCCESS_PNG_PATTH
  end
  if jindi == 0 then
    form.lbl_jindi.BackImage = UN_SUCCESS_PNG_PATTH
  else
    form.lbl_jindi.BackImage = SUCCESS_PNG_PATTH
  end
  if shouye == 0 then
    form.lbl_task.BackImage = UN_SUCCESS_PNG_PATTH
  else
    form.lbl_task.BackImage = SUCCESS_PNG_PATTH
  end
end
function refresh_zhouchang_award_icon(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(nx_resource_path() .. "share\\Rule\\shituzhouchang.ini")
  if ini:LoadFromFile() == false then
    return
  end
  local tiguan_id = ini:ReadString(TPZC_SECTION_TIGUAN, "prize", "")
  local tiguan_photo = get_prop_in_ItemQuery(tiguan_id, "Photo")
  form.imagegrid_tiguan_award:Clear()
  form.imagegrid_tiguan_award:AddItem(0, tiguan_photo, nx_widestr(tiguan_id), 0, 0)
  local jindi_id = ini:ReadString(TPZC_SECTION_CLONEFINISH, "prize", "")
  local jindi_photo = get_prop_in_ItemQuery(jindi_id, "Photo")
  form.imagegrid_jindi_award:Clear()
  form.imagegrid_jindi_award:AddItem(0, jindi_photo, nx_widestr(jindi_id), 0, 0)
  local shouye_id = ini:ReadString(TPZC_SECTION_SHITUTASK, "prize", "")
  local shouye_photo = get_prop_in_ItemQuery(shouye_id, "Photo")
  form.imagegrid_task_award:Clear()
  form.imagegrid_task_award:AddItem(0, shouye_photo, nx_widestr(shouye_id), 0, 0)
end
function refresh_ng_phase_award(form, ng_name, ng_level, phase_level, tp_level)
  if 0 < phase_level then
    form.lbl_stage.Text = nx_widestr(ng_name) .. nx_widestr(" ") .. nx_widestr(ng_level) .. nx_widestr("/") .. nx_widestr(phase_level)
    form.lbl_stage.BackImage = ""
  else
    form.lbl_stage.Text = nx_widestr("")
    form.lbl_stage.BackImage = SUCCESS_PNG_PATTH
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\shituprize.ini")
  if not nx_is_valid(ini) then
    return
  end
  form.imagegrid_stage_award.Visible = false
  form.lbl_stage_award.Visible = false
  if 0 < phase_level then
    local award_id, award_photo
    local sec_index = ini:FindSectionIndex(nx_string(phase_level))
    if 0 <= sec_index then
      local phase_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
      for i = 1, table.getn(phase_table) do
        local phaseinfo = phase_table[i]
        local info_lst = util_split_string(phaseinfo, ",")
        if nx_string(tp_level) == nx_string(info_lst[1]) then
          if g_select_flag == FLAG_SLT_NEIGONG_TEACHER then
            award_id = nx_string(info_lst[2])
            break
          end
          award_id = nx_string(info_lst[5])
          break
        end
      end
    end
    award_photo = get_prop_in_ItemQuery(award_id, "Photo")
    if award_id ~= nil and award_photo ~= nil then
      form.imagegrid_stage_award:Clear()
      form.imagegrid_stage_award:AddItem(0, award_photo, nx_widestr(award_id), 0, 0)
      form.imagegrid_stage_award.Visible = true
      form.lbl_stage_award.Visible = true
    end
  end
end
function refresh_ng_chushi_award(form, tp_level)
  local award_chushi_id
  if g_select_flag == FLAG_SLT_NEIGONG_TEACHER then
    if tp_level == 2 then
      award_chushi_id = "ui_shitu_erneishidichushi"
    elseif tp_level == 3 then
      award_chushi_id = "ui_shitu_sanneishidichushi"
    end
  elseif tp_level == 2 then
    award_chushi_id = "ui_shitu_erneishixiongchushi"
  elseif tp_level == 3 then
    award_chushi_id = "ui_shitu_sanneishixiongchushi"
  end
  if award_chushi_id ~= nil then
    form.lbl_chushi_award:Clear()
    form.lbl_chushi_award.HtmlText = util_text(award_chushi_id)
  end
  form.lbl_success.BackImage = UN_SUCCESS_PNG_PATTH
end
function show_role_model(form, sex, role_info)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not nx_is_valid(form.scenebox_1.Scene) then
    util_addscene_to_scenebox(form.scenebox_1)
  end
  check_actor2_model(form, player, sex)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  while nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0.1)
  end
  local skin_info = util_split_string(role_info, "#")
  local count = table.getn(skin_info)
  local link_name = {
    "Face",
    "Hat",
    "Cloth",
    "Pants",
    "Shoes",
    "Impress",
    "Hair"
  }
  if 0 == count then
    return
  end
  for i = 2, count do
    if "Cloth" == link_name[i] and (nx_string(skin_info[i]) ~= nil or nx_string(skin_info[i]) ~= "") then
      local role_composite = nx_value("role_composite")
      link_cloth_skin(role_composite, actor2, nx_string(skin_info[i]))
    elseif link == "Hat" or link == "hat" then
      link_hat_skin(role_composite, actor2, nx_string(skin_info[i]))
    elseif nx_string(skin_info[i]) ~= nil or nx_string(skin_info[i]) ~= "" then
      link_skin(actor2, link_name[i - 1], nx_string(skin_info[i]) .. ".xmod")
    end
  end
  return add_actor2_to_scenebox(form, actor2)
end
function check_actor2_model(form, player, item_sex)
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
  actor2 = create_role_composite(form.scenebox_1.Scene, true, item_sex)
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
function set_role_model_camera(form)
  if not nx_is_valid(form) then
    return
  end
  local camera = form.scenebox_1.Scene.camera
  if not nx_is_valid(camera) then
    return
  end
  local radius = 0.5
  camera:SetPosition(0, radius * 3.1, -radius * 2)
  camera:SetAngle(0, 0, 0)
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
  row_num = player:GetRecordRows(TBL_NAME_TEACHERPUPIL_NEIGONG)
  if row_num == 1 then
    local tp_type = player:QueryRecord(TBL_NAME_TEACHERPUPIL_NEIGONG, 0, 1)
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
  row_num = player:GetRecordRows(TBL_NAME_TEACHERPUPIL_JINGMAI)
  if row_num == 1 then
    local tp_type = player:QueryRecord(TBL_NAME_TEACHERPUPIL_JINGMAI, 0, 6)
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
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\jingmaiteacherpupil.ini")
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
      nx_execute("custom_sender", "custom_teacher_pupil", 4, nx_widestr(name))
    elseif nx_int(jiechu_type) == nx_int(2) then
      nx_execute("custom_sender", "custom_request", 64, nx_widestr(name))
    elseif nx_int(jiechu_type) == nx_int(3) then
      nx_execute("custom_sender", "custom_teacher_pupil", 5, nx_widestr(name))
    end
    local closeform = nx_value("form_stage_main\\form_school_war\\form_school_msg_info")
    if nx_is_valid(closeform) then
      closeform:Close()
    end
  end
end
function on_main_form_init(self)
end
function on_main_form_open(self)
  g_select_flag = get_default_select_flag(self)
  refresh_form(self)
  self.btn_summon.Visible = false
end
function on_main_form_close(self)
  if nx_is_valid(self.imagegrid_tiguan_award.Data) then
    nx_destroy(self.imagegrid_tiguan_award.Data)
  end
  if nx_is_valid(self.imagegrid_jindi_award.Data) then
    nx_destroy(self.imagegrid_jindi_award.Data)
  end
  if nx_is_valid(self.imagegrid_task_award.Data) then
    nx_destroy(self.imagegrid_task_award.Data)
  end
  if nx_is_valid(self.imagegrid_stage_award.Data) then
    nx_destroy(self.imagegrid_stage_award.Data)
  end
  nx_destroy(self)
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
function on_btn_summon_click(btn)
end
function on_imagegrid_tiguan_award_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_tiguan_award_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
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
