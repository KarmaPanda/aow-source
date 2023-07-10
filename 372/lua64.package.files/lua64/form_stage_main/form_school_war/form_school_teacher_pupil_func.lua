require("util_gui")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
TBL_NAME_TEACHERPUPIL_NEIGONG = "rec_teacherpupil"
TBL_NAME_TEACHERPUPIL_JINGMAI = "rec_jingmai_tp"
FORM_NAME_TEACHERPUPIL = "form_school_teacher_pupil"
FORM_NAME_TEACHERLIST = "form_school_teacher_list"
school_neigong_id = {
  [2] = {
    school_shaolin = "ng_sl_002",
    school_emei = "ng_em_002",
    school_tangmen = "ng_tm_002",
    school_jilegu = "ng_jl_002",
    school_jinyiwei = "ng_jy_002",
    school_wudang = "ng_wd_002",
    school_gaibang = "ng_gb_002",
    school_junzitang = "ng_jz_002"
  },
  [3] = {
    school_shaolin = "ng_sl_003",
    school_emei = "ng_em_003",
    school_tangmen = "ng_tm_003",
    school_jilegu = "ng_jl_003",
    school_jinyiwei = "ng_jy_003",
    school_wudang = "ng_wd_003",
    school_gaibang = "ng_gb_003",
    school_junzitang = "ng_jz_003"
  }
}
school_tprule_desc = {
  [1] = "ui_shitu_rule_desc_01",
  [2] = {
    school_shaolin = "ui_shitu_rule_desc_02_shaolin",
    school_emei = "ui_shitu_rule_desc_02_emei",
    school_tangmen = "ui_shitu_rule_desc_02_tangmen",
    school_jilegu = "ui_shitu_rule_desc_02_jilegu",
    school_jinyiwei = "ui_shitu_rule_desc_02_jinyiwei",
    school_wudang = "ui_shitu_rule_desc_02_wudang",
    school_gaibang = "ui_shitu_rule_desc_02_gaibang",
    school_junzitang = "ui_shitu_rule_desc_02_junzitang"
  },
  [3] = "ui_shitu_rule_desc_03"
}
school_name_id = {
  school_shaolin = "ui_neigong_category_sl",
  school_emei = "ui_neigong_category_em",
  school_tangmen = "ui_neigong_category_tm",
  school_jilegu = "ui_neigong_category_jl",
  school_jinyiwei = "ui_neigong_category_jy",
  school_wudang = "ui_neigong_category_wd",
  school_gaibang = "ui_neigong_category_gb",
  school_junzitang = "ui_neigong_category_jz"
}
function Get_PowerLevel_Name(PowerLevel)
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\FacultyLevel.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  if not ini:FindSection(nx_string("config")) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string("config"))
  if sec_index < 0 then
    return ""
  end
  local power_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
  for i = 1, table.getn(power_table) do
    local powerinfo = power_table[i]
    local info_lst = util_split_string(powerinfo, ",")
    if nx_int(PowerLevel) == nx_int(info_lst[1]) then
      return util_text("desc_" .. nx_string(info_lst[3]))
    end
  end
  return ""
end
function get_date_string(_date)
  local year, month, day = nx_function("ext_decode_date", nx_double(_date))
  year = year or 1970
  month = month or 1
  day = day or 1
  return string.format("%s-%s-%s", year, month, day)
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function get_teacher_pupil_count()
  local player = get_player()
  if not nx_is_valid(player) then
    return 0
  end
  local num = 0
  if player:FindRecord(TBL_NAME_TEACHERPUPIL_NEIGONG) then
    num = num + player:GetRecordRows(TBL_NAME_TEACHERPUPIL_NEIGONG)
  end
  if player:FindRecord(TBL_NAME_TEACHERPUPIL_JINGMAI) then
    num = num + player:GetRecordRows(TBL_NAME_TEACHERPUPIL_JINGMAI)
  end
  return num
end
function custom_pupil_request_select(shixiong, name)
  local gui = nx_value("gui")
  if nx_int(1) == nx_int(shixiong) then
    gui.TextManager:Format_SetIDName("ui_shitu_desc_01")
  else
    gui.TextManager:Format_SetIDName("ui_shitu_desc_02")
  end
  local info = gui.TextManager:Format_GetText()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), -1)
  dialog.relogin_btn.Visible = true
  local request_type = 0
  if nx_int(1) == nx_int(shixiong) then
    dialog.relogin_btn.Text = gui.TextManager:GetText("ui_shitu_confirm_02")
    dialog.ok_btn.Text = gui.TextManager:GetText("ui_shitu_confirm_01")
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "relogin" then
      nx_execute("custom_sender", "custom_request", 53, nx_widestr(name), 1, 3)
    elseif res == "ok" then
      nx_execute("custom_sender", "custom_request", 53, nx_widestr(name), 1, 2)
    end
  elseif nx_int(2) == nx_int(shixiong) then
    dialog.relogin_btn.Text = gui.TextManager:GetText("ui_shitu_confirm_04")
    dialog.ok_btn.Text = gui.TextManager:GetText("ui_shitu_confirm_03")
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "relogin" then
      nx_execute("custom_sender", "custom_teacher_pupil", 6, nx_widestr(name), 1, 3)
    elseif res == "ok" then
      nx_execute("custom_sender", "custom_teacher_pupil", 6, nx_widestr(name), 1, 2)
    end
  end
end
function get_pupil_neigong_name(tp_level)
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return nil
  end
  local school_id = client_player:QueryProp("School")
  local neigong_id = school_neigong_id[tp_level][school_id]
  return util_text(neigong_id)
end
function get_school_name()
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return nil
  end
  local school_id = client_player:QueryProp("School")
  return util_text(school_name_id[school_id])
end
function get_pupil_current_level(tp_level)
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return 0
  end
  local school_id = client_player:QueryProp("School")
  local neigong_id = school_neigong_id[tp_level][school_id]
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_NEIGONG))
  if not nx_is_valid(view) then
    return 0
  end
  local view_lst = view:GetViewObjList()
  for _, neigong in ipairs(view_lst) do
    if nx_is_valid(neigong) then
      local temp_neigong_id = neigong:QueryProp("ConfigID")
      if nx_string(temp_neigong_id) == nx_string(neigong_id) then
        local curLevel = neigong:QueryProp("Level")
        return curLevel
      end
    end
  end
  return 0
end
function get_pupil_phase_level()
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return 0
  end
  return client_player:QueryProp("PhaseNeiGongLevel")
end
function get_pupil_jingmai_xwcount()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local view = game_client:GetView(nx_string(VIEWPORT_XUEWEI))
  if not nx_is_valid(view) then
    return 0
  end
  local item_lst = view:GetViewObjList()
  return table.getn(item_lst)
end
function on_server_msg(submsg, ...)
  if nx_int(submsg) == nx_int(1) then
  elseif nx_int(submsg) == nx_int(2) then
    util_show_form("form_stage_main\\form_school_war\\form_school_teacher_listwrite", true)
  elseif nx_int(submsg) == nx_int(3) then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local name = nx_widestr(arg[1])
    local neigonglevel = nx_int(arg[2])
    local npersent = nx_int(arg[3])
    gui.TextManager:Format_SetIDName("ui_shitu_shoutu")
    gui.TextManager:Format_AddParam(nx_widestr(name))
    gui.TextManager:Format_AddParam(nx_int(neigonglevel))
    gui.TextManager:Format_AddParam(nx_int(npersent))
    local info = gui.TextManager:Format_GetText()
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    dialog:ShowModal()
    dialog.mltbox_info:Clear()
    local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), -1)
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return
    end
    local teacher_level = nx_int(arg[4])
    nx_execute("custom_sender", "custom_request", 54, nx_widestr(name), 1, teacher_level)
  elseif nx_int(submsg) == nx_int(4) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    dialog:ShowModal()
    dialog.mltbox_info:Clear()
    local text = nx_widestr(util_text("ui_shitu_jingmai_buf_01"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_teacher_pupil", 7)
    end
  end
end
