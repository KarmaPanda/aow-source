require("util_gui")
require("util_functions")
require("game_object")
function main_form_init(self)
  self.Fixed = false
  self.allow_empty = true
  self.Visible = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  form:Close()
  nx_destroy(form)
  return 1
end
function init_date(sender_type, ...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_system_friends")
  if not nx_is_valid(form) then
    return
  end
  if arg[1] == nil then
    form:Close()
    return
  end
  local table_num = table.getn(arg)
  local num = 0
  for i = 1, table_num do
    if arg[i] == nil then
      break
    end
    local str_name = "data" .. i
    nx_set_custom(form, str_name, arg[i])
    num = i
  end
  form.datanum = num
  form.curpage = 1
  if nx_int(sender_type) == nx_int(1) then
    set_gui_bevisible()
  else
    local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", 35, "", -1)
  end
end
function set_gui_bevisible()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_system_friends")
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  show_system_friends(form)
end
function show_system_friends(form)
  local form = nx_value("form_stage_main\\form_relation\\form_system_friends")
  if not nx_is_valid(form) then
    return
  end
  local begin = (form.curpage - 1) * 28 + 1
  for i = 1, 2 do
    local n = begin + (i - 1) * 14
    init_show(n, i, form)
  end
end
function init_show(begin, i, form)
  local gui = nx_value("gui")
  local num = begin
  local name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  local val = nx_custom(form, name_str)
  local btn_bind_name = "name_" .. i
  if nx_find_custom(form, btn_bind_name) then
    local bind_obj = nx_custom(form, btn_bind_name)
    bind_obj.Text = nx_widestr(val)
  end
  num = num + 1
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  val = nx_custom(form, name_str)
  btn_bind_name = "photo_" .. i
  if nx_find_custom(form, btn_bind_name) then
    local bind_obj = nx_custom(form, btn_bind_name)
    bind_obj.BackImage = nx_string(val)
  end
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  val = nx_custom(form, name_str)
  btn_bind_name = "levelstep_" .. i
  if nx_find_custom(form, btn_bind_name) then
    local bind_obj = nx_custom(form, btn_bind_name)
    bind_obj.Text = gui.TextManager:GetText("desc_" .. nx_string(val))
  end
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  val = nx_custom(form, name_str)
  btn_bind_name = "curtitle_" .. i
  local bIsSwornTitle = false
  if nx_find_custom(form, btn_bind_name) then
    local bind_obj = nx_custom(form, btn_bind_name)
    if val == 0 then
      bind_obj.Text = gui.TextManager:GetText("ui_wu")
    elseif nx_int(val) >= nx_int(9001) and nx_int(val) <= nx_int(9100) then
      bIsSwornTitle = true
    else
      bind_obj.Text = gui.TextManager:GetText("role_title_" .. nx_string(val))
    end
  end
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  val = nx_custom(form, name_str)
  btn_bind_name = "school_" .. i
  if nx_find_custom(form, btn_bind_name) then
    local bind_obj = nx_custom(form, btn_bind_name)
    bind_obj.Text = get_schoolname(val)
  end
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  val = nx_custom(form, name_str)
  btn_bind_name = "neigong_" .. i
  if nx_find_custom(form, btn_bind_name) then
    local bind_obj = nx_custom(form, btn_bind_name)
    if nx_string(val) == "" then
      bind_obj.Text = gui.TextManager:GetText("ui_wu")
    else
      bind_obj.Text = gui.TextManager:GetText(nx_string(val))
    end
  end
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  val = nx_custom(form, name_str)
  btn_bind_name = "camp_" .. i
  if nx_find_custom(form, btn_bind_name) then
    local bind_obj = nx_custom(form, btn_bind_name)
    if nx_string(val) == "" then
      bind_obj.Text = gui.TextManager:GetText("ui_wu")
    else
      bind_obj.Text = nx_widestr(val)
    end
  end
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  val = nx_custom(form, name_str)
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  local val_t = nx_custom(form, name_str)
  btn_bind_name = "charect_" .. i
  if nx_find_custom(form, btn_bind_name) then
    local bind_obj = nx_custom(form, btn_bind_name)
    bind_obj.Text = get_pk_step(val, val_t)
  end
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  val = nx_custom(form, name_str)
  btn_bind_name = "curtitle_" .. i
  if nx_find_custom(form, btn_bind_name) then
    local bind_obj = nx_custom(form, btn_bind_name)
    if bIsSwornTitle then
      local list = util_split_wstring(nx_widestr(val), nx_widestr(","))
      local counts = table.getn(list)
      if counts < 3 then
        return
      end
      local title_name = nx_widestr(list[1])
      local player_num = nx_int(list[2])
      local titld_id = nx_int(list[3])
      if nx_int(player_num) >= nx_int(2) and nx_int(player_num) <= nx_int(6) then
        bind_obj.Text = nx_widestr(gui.TextManager:GetFormatText("role_title_" .. nx_string(player_num) .. "_" .. nx_string(titld_id), nx_widestr(title_name)))
      end
    end
  end
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  local val1 = nx_custom(form, name_str)
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  local val2 = nx_custom(form, name_str)
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  local val3 = nx_custom(form, name_str)
  local job1 = nx_null()
  local job2 = nx_null()
  local job3 = nx_null()
  local stotal = nx_null()
  local firstjob = 0
  local secondjob = 0
  local thirdjob = 0
  if not nx_ws_equal(nx_widestr(val1), nx_widestr("")) then
    firstjob = 1
    job1 = get_job(val1)
    stotal = nx_widestr(job1)
  end
  if not nx_ws_equal(nx_widestr(val2), nx_widestr("")) then
    secondjob = 1
    job2 = get_job(val2)
    if firstjob == 1 then
      stotal = nx_widestr(stotal) .. nx_widestr(",")
      stotal = nx_widestr(stotal) .. nx_widestr(job2)
    else
      stotal = nx_widestr(job2)
    end
  end
  if not nx_ws_equal(nx_widestr(val3), nx_widestr("")) then
    thirdjob = 1
    job3 = get_job(val3)
    if firstjob ~= 0 or secondjob ~= 0 then
      stotal = nx_widestr(stotal) .. nx_widestr(",")
      stotal = nx_widestr(stotal) .. nx_widestr(job3)
    else
      stotal = nx_widestr(job3)
    end
  end
  btn_bind_name = "lifejob_" .. i
  if nx_find_custom(form, btn_bind_name) then
    local bind_obj = nx_custom(form, btn_bind_name)
    if firstjob ~= 0 or secondjob ~= 0 or thirdjob ~= 0 then
      bind_obj.Text = nx_widestr(stotal)
    else
      bind_obj.Text = gui.TextManager:GetText("ui_wu")
    end
  end
  num = num + 1
  name_str = "data" .. num
  if not nx_find_custom(form, name_str) then
    return
  end
  val = nx_custom(form, name_str)
  local labl = ""
  if val == "ui_sns_recommend_01" then
    labl = "levelstep_" .. i
  elseif val == "ui_sns_recommend_12" then
    labl = "school_" .. i
  else
    labl = "lifejob_" .. i
  end
  if nx_find_custom(form, labl) then
    local bind_obj = nx_custom(form, labl)
    bind_obj.ForeColor = "255,255,255,55"
  end
  btn_bind_name = "reason_" .. i
  if nx_find_custom(form, btn_bind_name) then
    local bind_obj = nx_custom(form, btn_bind_name)
    bind_obj:Clear()
    bind_obj:AddHtmlText(gui.TextManager:GetText(nx_string(val)), -1)
  end
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if form.Visible then
    form.curpage = form.curpage - 1
    if form.curpage < 1 then
      form.curpage = 1
      return
    end
    show_system_friends(form)
  end
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if form.Visible then
    form.curpage = form.curpage + 1
    if form.curpage * 2 * 13 > form.datanum + 13 then
      form.curpage = form.curpage - 1
      return
    end
    show_system_friends(form)
  end
end
function get_schoolname(school)
  local gui = nx_value("gui")
  local school_name = nx_null()
  if school == "school_shaolin" then
    school_name = gui.TextManager:GetText("ui_neigong_category_sl")
  elseif school == "school_wudang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_wd")
  elseif school == "school_emei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_em")
  elseif school == "school_junzitang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jz")
  elseif school == "school_jinyiwei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jy")
  elseif school == "school_jilegu" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jl")
  elseif school == "school_gaibang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_gb")
  elseif school == "school_tangmen" then
    school_name = gui.TextManager:GetText("ui_neigong_category_tm")
  elseif school == "school_mingjiao" then
    school_name = gui.TextManager:GetText("ui_neigong_category_mj")
  elseif school == "school_tianshan" then
    school_name = gui.TextManager:GetText("ui_neigong_category_ts")
  else
    school_name = gui.TextManager:GetText("ui_task_school_null")
  end
  return school_name
end
function get_cur_title(Value)
  local gui = nx_value("gui")
  return gui.TextManager:GetText("role_title_" .. nx_string(Value))
end
function get_level_step(title)
  local gui = nx_value("gui")
  return gui.TextManager:GetText("desc_" .. title)
end
function get_pk_step(CharacterFlag, CharacterValue)
  local text = nx_execute("form_stage_main\\form_role_info\\form_role_info", "get_xiae_text", CharacterFlag, CharacterValue)
  return text
end
function get_job(val)
  local jobtext
  if val == "sh_kg" then
    jobtext = "ui_KuangGong"
  elseif val == "sh_lh" then
    jobtext = "ui_LieHu"
  elseif val == "sh_nf" then
    jobtext = "ui_NongFu"
  elseif val == "sh_qf" then
    jobtext = "ui_QiaoFu"
  elseif val == "sh_yf" then
    jobtext = "ui_YuFu"
  elseif val == "sh_cf" then
    jobtext = "ui_CaiFeng"
  elseif val == "sh_cs" then
    jobtext = "ui_ChuShi"
  elseif val == "sh_ds" then
    jobtext = "ui_DuShi"
  elseif val == "sh_jq" then
    jobtext = "ui_JinJiang"
  elseif val == "sh_tj" then
    jobtext = "ui_TieJiang"
  elseif val == "sh_ys" then
    jobtext = "ui_YaoShi"
  elseif val == "sh_qs" then
    jobtext = "ui_QinShi"
  elseif val == "sh_qis" then
    jobtext = "ui_QiShi"
  elseif val == "sh_ss" then
    jobtext = "ui_ShuSheng"
  elseif val == "sh_hs" then
    jobtext = "ui_HuaShi"
  elseif val == "sh_gs" then
    jobtext = "ui_GuaShi"
  elseif val == "sh_qg" then
    jobtext = "ui_QiGai"
  else
    jobtext = ""
  end
  local gui = nx_value("gui")
  return gui.TextManager:GetText(jobtext)
end
function on_befriend_1_click(btn)
  local form = btn.ParentForm
  local name = form.name_1.Text
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_friend", name)
end
function on_befriend_2_click(btn)
  local form = btn.ParentForm
  local name = form.name_2.Text
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_friend", name)
end
function on_talk_1_click(btn)
  local form = btn.ParentForm
  local name = form.name_1.Text
  nx_execute("custom_sender", "custom_request_chat", name)
end
function on_talk_2_click(btn)
  local form = btn.ParentForm
  local name = form.name_2.Text
  nx_execute("custom_sender", "custom_request_chat", name)
end
