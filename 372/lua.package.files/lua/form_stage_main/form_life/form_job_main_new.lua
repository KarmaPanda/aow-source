require("util_functions")
require("define\\gamehand_type")
require("util_gui")
require("share\\itemtype_define")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("define\\sysinfo_define")
local cai_table = {
  "sh_kg",
  "sh_lh",
  "sh_nf",
  "sh_qf",
  "sh_yf"
}
local zao_table = {
  "sh_cf",
  "sh_cs",
  "sh_ds",
  "sh_jq",
  "sh_tj",
  "sh_ys"
}
local wen_table = {
  "sh_qs",
  "sh_qis",
  "sh_ss",
  "sh_hs"
}
local shi_table = {"sh_gs", "sh_qg"}
local vip_table = {
  "sh_kg",
  "sh_lh",
  "sh_nf",
  "sh_qf",
  "sh_yf",
  "sh_ds",
  "sh_ys"
}
local seach_btn_table = {
  sh_kg = "btn_kg",
  sh_lh = "btn_lh",
  sh_nf = "btn_nf",
  sh_qf = "btn_qf",
  sh_yf = "btn_yf",
  sh_cf = "btn_cf",
  sh_cs = "btn_cs",
  sh_ds = "btn_ds",
  sh_jq = "btn_jq",
  sh_tj = "btn_tj",
  sh_ys = "btn_ys",
  sh_qs = "btn_qs",
  sh_qis = "btn_qis",
  sh_ss = "btn_ss",
  sh_hs = "btn_hs",
  sh_gs = "btn_gs",
  sh_qg = "btn_qg"
}
local seach_photo_table = {
  sh_kg = {"btn_kg_", 32},
  sh_lh = {"btn_lh_", 33},
  sh_nf = {"btn_nf_", 34},
  sh_qf = {"btn_qf_", 35},
  sh_yf = {"btn_yf_", 36},
  sh_cf = {"btn_cf_", 39},
  sh_cs = {"btn_cs_", 40},
  sh_ds = {"btn_ds_", 37},
  sh_jq = {"btn_qj_", 41},
  sh_tj = {"btn_tj_", 42},
  sh_ys = {"btn_ys_", 38},
  sh_qs = {"btn_qs_", 43},
  sh_qis = {"btn_qis_", 44},
  sh_ss = {"btn_ss_", 45},
  sh_hs = {"btn_hs_", 46},
  sh_gs = {"btn_gs_", 47},
  sh_qg = {"btn_qg_", 48}
}
FORM_JOB_MAIN_NEW = "form_stage_main\\form_life\\form_job_main_new"
local g_jobid = ""
local g_form_type = 9
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function auto_show_hide_life_form()
  local form = nx_value(FORM_JOB_MAIN_NEW)
  if nx_is_valid(form) then
    form.Visible = not form.Visible
    if form.Visible then
      center_for_screen(form)
      form:Show()
      DelayExecute(300, 1, FORM_JOB_MAIN_NEW, "DelayRefresh")
      refresh_player_culture_job_use_vip()
    else
      ClearDelay(FORM_JOB_MAIN_NEW, "DelayRefresh")
    end
  else
    nx_execute("util_gui", "util_auto_show_hide_form", FORM_JOB_MAIN_NEW)
  end
  hide_all_combobox()
  local form = nx_value(FORM_JOB_MAIN_NEW)
  nx_execute("util_gui", "ui_show_attached_form", form)
end
function reset_scene()
  local bVisible = false
  local form = nx_value(FORM_JOB_MAIN_NEW)
  if nx_is_valid(form) then
    bVisible = form.Visible
    form:Close()
  else
    bVisible = false
  end
  nx_execute("util_gui", "util_auto_show_hide_form", FORM_JOB_MAIN_NEW)
  form = nx_value(FORM_JOB_MAIN_NEW)
  if nx_is_valid(form) then
    form.Visible = bVisible
    if bVisible then
      center_for_screen(form)
      refresh_form(form)
    else
    end
  end
end
function refresh_form(form)
  if nx_is_valid(form) then
    fresh_form(form)
    fresh_job_info(form, form.job_id)
    local helper_form = nx_value("helper_form")
    if helper_form then
      hide_all_child_form()
      show_or_hide_main_form(true)
    end
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
function DelayRefresh(form)
  refresh_form(form)
  local formgather = nx_value("form_stage_main\\form_life\\form_job_gather")
  if nx_is_valid(formgather) and formgather.Visible then
    nx_execute("form_stage_main\\form_life\\form_job_gather", "fresh_form", formgather, form.job_id)
  end
  local formgathernew = nx_value("form_stage_main\\form_life\\form_job_gather_new")
  if nx_is_valid(formgathernew) and formgathernew.Visible then
    nx_execute("form_stage_main\\form_life\\form_job_gather_new", "fresh_form", formgathernew, form.job_id)
  end
  local formcomposite = nx_value("form_stage_main\\form_life\\form_job_composite")
  if nx_is_valid(formcomposite) and formcomposite.Visible then
    nx_execute("form_stage_main\\form_life\\form_job_composite", "fresh_form", formcomposite)
  end
  local formqishi = nx_value("form_stage_main\\form_life\\form_job_qishi")
  if nx_is_valid(formqishi) and formqishi.Visible then
    nx_execute("form_stage_main\\form_life\\form_job_qishi", "fresh_form", formqishi)
  end
  local formcrop = nx_value("form_stage_main\\form_life\\form_farm_crop")
  if nx_is_valid(formcrop) and formcrop.Visible then
    nx_execute("form_stage_main\\form_life\\form_farm_crop", "fresh_form", formcrop)
  end
  local formwar = nx_value("form_stage_main\\form_life\\form_job_war")
  if nx_is_valid(formwar) and formwar.Visible then
    nx_execute("form_stage_main\\form_life\\form_job_war", "fresh_form", formwar)
  end
end
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
  nx_execute("util_functions", "get_ini", "share\\Life\\job_info.ini")
  nx_execute("util_functions", "get_ini", "share\\Life\\job_skill.ini")
  form.job_id = "sh_kg"
end
function on_main_form_open(form)
  data_bind_prop(form)
  center_for_screen(form)
  fresh_form(form)
  fresh_job_info(form, form.job_id)
  local helper_form = nx_value("helper_form")
  if true == helper_form then
    hide_all_child_form()
    show_or_hide_main_form(true)
  end
  form.cbtn_use_vip.Visible = false
end
function on_main_form_visible(form)
  DelayRefresh(form)
  refresh_player_culture_job_use_vip()
end
function on_main_form_close(form)
  local is_help = nx_custom(form, "is_help")
  if is_help == nil or is_help == false then
    del_data_bind_prop(form)
    form.Visible = false
  end
  ui_destroy_attached_form(form)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("job_rec", form, nx_current(), "on_job_rec_refresh")
    databinder:AddTableBind("title_rec", form, nx_current(), "on_job_rec_refresh")
    databinder:AddTableBind("sh_gather_vip_rec", form, nx_current(), "on_gather_vip_rec_refresh")
    databinder:AddRolePropertyBind("OpenLifeJob", "string", form, nx_current(), "on_update_open_life_flag")
  end
end
function del_data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("job_rec", form)
    databinder:DelTableBind("title_rec", form)
    databinder:DelTableBind("sh_gather_vip_rec", form)
  end
end
function center_for_screen(form)
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  local is_help = nx_custom(form, "is_help")
  if is_help == nil or is_help == false then
  else
    form.is_help = false
    nx_execute("form_stage_main\\form_helper\\form_move_win", "util_open_move_win", form.AbsLeft, form.AbsTop, form.Width, form.Height, "", "btn_job,open_form_job")
  end
  auto_show_hide_life_form()
end
function fresh_form(form)
  form.btn_kg.job_id = "sh_kg"
  form.btn_lh.job_id = "sh_lh"
  form.btn_nf.job_id = "sh_nf"
  form.btn_qf.job_id = "sh_qf"
  form.btn_yf.job_id = "sh_yf"
  form.btn_cf.job_id = "sh_cf"
  form.btn_cs.job_id = "sh_cs"
  form.btn_ds.job_id = "sh_ds"
  form.btn_jq.job_id = "sh_jq"
  form.btn_tj.job_id = "sh_tj"
  form.btn_ys.job_id = "sh_ys"
  form.btn_qs.job_id = "sh_qs"
  form.btn_qis.job_id = "sh_qis"
  form.btn_ss.job_id = "sh_ss"
  form.btn_hs.job_id = "sh_hs"
  form.btn_gs.job_id = "sh_gs"
  form.btn_qg.job_id = "sh_qg"
end
function fresh_all_btn_state(form)
  fresh_cai_btn_state(form, cai_table, form.groupbox_cai)
  fresh_zao_btn_state(form, zao_table, form.groupbox_zao)
  fresh_zao_btn_state(form, wen_table, form.groupbox_wen)
  fresh_cai_btn_state(form, shi_table, form.groupbox_shi)
  local job_type = get_job_type(form.job_id)
  if job_type == 2 and find_life_job(form.job_id) then
    form.btn_life_fight.Visible = true
    local ret = have_new_skill()
    if ret then
      form.lbl_new_skill.Visible = true
    else
      form.lbl_new_skill.Visible = false
    end
  else
    form.btn_life_fight.Visible = false
    form.lbl_new_skill.Visible = false
  end
  form.btn_set_share.Visible = false
  if find_life_job(form.job_id) and (form.job_id == "sh_cf" or form.job_id == "sh_cs" or form.job_id == "sh_ds" or form.job_id == "sh_jq" or form.job_id == "sh_tj" or form.job_id == "sh_ys" or form.job_id == "sh_ss" or form.job_id == "sh_hs") then
    form.btn_set_share.Visible = true
  end
  if find_life_job(form.job_id) then
    form.btn_giveup.Visible = true
  else
    form.btn_giveup.Visible = false
  end
end
function fresh_btn_state(jobid, btn, btn_type)
  if not nx_is_valid(btn) then
    return
  end
  local btn_photo_type = nx_string(seach_photo_table[jobid][1])
  local path = "gui\\special\\life_btn\\" .. btn_photo_type
  if btn_type == 1 then
    btn.NormalImage = path .. "out.png"
    btn.FocusImage = path .. "on.png"
    btn.PushImage = path .. "down.png"
  elseif btn_type == 2 then
    btn.NormalImage = path .. "disable.png"
    btn.FocusImage = path .. "disable_on.png"
    btn.PushImage = path .. "disable_down.png"
  elseif btn_type == 3 then
    btn.NormalImage = path .. "disable.png"
    btn.FocusImage = path .. "disable_on.png"
    btn.PushImage = path .. "disable_down.png"
  elseif btn_type == 4 then
    btn.NormalImage = path .. "disable.png"
    btn.FocusImage = path .. "disable.png"
    btn.PushImage = path .. "disable.png"
  else
    btn.NormalImage = path .. "disable.png"
    btn.FocusImage = path .. "disable.png"
    btn.PushImage = path .. "disable.png"
  end
  local form = btn.ParentForm
  if nx_string(form.job_id) == nx_string(jobid) then
    btn.NormalImage = btn.PushImage
    btn.FocusImage = btn.PushImage
  end
  fresh_job_flag(jobid, btn, btn_type)
end
function fresh_cai_btn_state(form, job_table, group)
  if not nx_is_valid(form) or not nx_is_valid(group) then
    return
  end
  for i, job_id in pairs(job_table) do
    local btn = group:Find(nx_string(seach_btn_table[job_id]))
    if nx_is_valid(btn) then
      if not find_life_job(job_id) then
        fresh_btn_state(job_id, btn, 2)
      else
        fresh_btn_state(job_id, btn, 1)
      end
    end
  end
end
function fresh_zao_btn_state(form, job_table, group)
  if not nx_is_valid(form) or not nx_is_valid(group) then
    return
  end
  local study_job = get_study_job(job_table)
  for i, job_id in pairs(job_table) do
    local btn = group:Find(nx_string(seach_btn_table[job_id]))
    if nx_is_valid(btn) then
      if nx_string(study_job) == "" then
        fresh_btn_state(job_id, btn, 2)
      elseif find_life_job(job_id) then
        fresh_btn_state(job_id, btn, 1)
      else
        fresh_btn_state(job_id, btn, 3)
      end
    end
  end
end
function on_btn_sh_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(btn, "job_id") then
    return
  end
  if nx_string(form.job_id) == nx_string(btn.job_id) then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    return
  end
  form.job_id = btn.job_id
  fresh_job_info(form, form.job_id)
  local res_job = false
  res_job = is_culture_job(form.job_id)
  form.cbtn_use_vip.Visible = nx_boolean(res_job)
  if nx_boolean(res_job) then
    refresh_player_culture_job_use_vip()
  end
  local helper_form = nx_value("helper_form")
  if true == helper_form then
    nx_pause(0.1)
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_sh_left_double_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(btn, "job_id") then
    return
  end
  form.job_id = btn.job_id
  g_jobid = ""
  g_form_type = 9
  if nx_string(btn.job_id) == "sh_ds" or nx_string(btn.job_id) == "sh_ys" then
    create_job_form(nx_string(btn.job_id), 1)
  elseif find_life_job(nx_string(btn.job_id)) then
    create_job_form(nx_string(btn.job_id), 0)
  end
end
function fresh_job_info(form, job_id)
  fresh_job_desc_info(form, job_id)
  fresh_job_skill_info(form, job_id)
  fresh_all_btn_state(form)
  fresh_vip_state(form)
end
function fresh_job_desc_info(form, job_id)
  local gui = nx_value("gui")
  form.mltbox_info:Clear()
  form.mltbox_name:Clear()
  if job_id == nil or job_id == "" then
    return
  end
  local desc_info_lvl = "desc_info_" .. nx_string(job_id) .. "_lvl"
  gui.TextManager:Format_SetIDName(desc_info_lvl)
  if find_life_job(job_id) then
    local job_level = get_job_level(job_id)
    local originid = get_life_must_originid(job_id, job_level)
    job_level = gui.TextManager:GetText("role_title_" .. nx_string(originid))
    gui.TextManager:Format_AddParam(job_level)
  else
    local weixide = nx_widestr("<font color=\"#FF0000\">") .. nx_widestr(gui.TextManager:GetText("ui_no_study_name")) .. nx_widestr("</font>")
    gui.TextManager:Format_AddParam(weixide)
  end
  form.mltbox_name.HtmlText = nx_widestr(gui.TextManager:Format_GetText())
  local desc_info = "desc_info_" .. nx_string(job_id)
  form.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText(desc_info))
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  form.pbar_empirical.Visible = false
  form.btn_xd_shop.Visible = false
  if nx_is_valid(client_player) then
    local max_jobpoint = 0
    local now_jobpoint = 0
    local row = client_player:FindRecordRow("job_rec", 0, job_id, 0)
    if 0 <= row then
      now_jobpoint = nx_int(client_player:QueryRecord("job_rec", row, 2))
      max_jobpoint = nx_int(client_player:QueryRecord("job_rec", row, 3))
      form.pbar_empirical.Visible = true
      form.btn_xd_shop.Visible = true
      form.pbar_empirical.Maximum = max_jobpoint
      form.pbar_empirical.Value = now_jobpoint
    end
  end
  local job_type = get_job_type(job_id)
  if job_type == 1 then
    return
  end
end
function on_pbar_empirical_left_double_click(pbr)
  local form = pbr.ParentForm
  local job_level = get_job_level(form.job_id)
  local job_sf_path = "share\\Item\\lifesfname.ini"
  local sf_ini = nx_execute("util_functions", "get_ini", job_sf_path)
  if not nx_is_valid(sf_ini) then
    return
  end
  local index = sf_ini:FindSectionIndex(nx_string(form.job_id))
  if index < 0 then
    return
  end
  local job_origin = sf_ini:ReadString(index, nx_string(job_level), "")
  local form_origin = nx_value("form_stage_main\\form_origin\\form_origin")
  if nx_is_valid(form_origin) and form_origin.Visible then
    form_origin:Close()
  else
    nx_execute("form_stage_main\\form_origin\\form_origin", "open_origin_form_by_id", nx_int(job_origin))
  end
end
function on_pbar_empirical_get_capture(pbr)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local form = pbr.ParentForm
  local curdayjobpoint = 0
  local row = client_player:FindRecordRow("job_rec", 0, form.job_id, 0)
  local max_point = client_player:QueryRecord("job_rec", row, 6)
  local now_point = client_player:QueryRecord("job_rec", row, 7)
  if 0 <= row then
    local totaljobpoint = client_player:QueryRecord("job_rec", row, 2)
    curdayjobpoint = max_point - now_point
    if curdayjobpoint < 0 then
      curdayjobpoint = 0
    end
  end
  local sh_integral = 0
  local row = nx_int(seach_photo_table[form.job_id][2])
  local rows = client_player:GetRecordRows("data_record")
  if row < nx_int(rows) then
    sh_integral = nx_int(client_player:QueryRecord("data_record", row, 0))
  end
  local can_num = math.floor(curdayjobpoint * 10 / max_point)
  if math.floor(curdayjobpoint * 10 % max_point) ~= 0 then
    can_num = can_num + 1
  end
  gui.TextManager:Format_SetIDName("tips_xinde_2")
  gui.TextManager:Format_AddParam(nx_int(curdayjobpoint))
  gui.TextManager:Format_AddParam(nx_int(sh_integral))
  gui.TextManager:Format_AddParam(nx_int(can_num))
  local text = nx_widestr(gui.TextManager:Format_GetText())
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, pbr.ParentForm)
end
function on_pbar_empirical_lost_capture(pbr)
  nx_execute("tips_game", "hide_tip", pbr.ParentForm)
end
function fresh_job_skill_info(form, job_id)
  local job_info_path = "share\\Life\\job_info.ini"
  local job_skill_path = "share\\Life\\job_skill.ini"
  if job_id == nil or nx_string(job_id) == "" then
    return
  end
  local job_skill_ini = nx_execute("util_functions", "get_ini", job_skill_path)
  local job_info_ini = nx_execute("util_functions", "get_ini", job_info_path)
  if not nx_is_valid(job_skill_ini) or not nx_is_valid(job_info_ini) then
    return
  end
  local sec_index = job_info_ini:FindSectionIndex(nx_string(job_id))
  if sec_index < 0 then
    nx_log("share\\Life\\job_info.ini sec_index = " .. nx_string(job_id))
    return
  end
  local job_skill_str = job_info_ini:ReadString(sec_index, "jobskill", "")
  local sub_str = util_split_string(job_skill_str, ",")
  local grid = form.imagegrid_skill
  grid:Clear()
  form.groupbox_skill.Visible = true
  local skill_num = table.getn(sub_str)
  if skill_num <= 0 or not find_life_job(nx_string(job_id)) then
    form.groupbox_skill.Visible = false
    return
  end
  local gui = nx_value("gui")
  local job_level = get_job_level(job_id)
  local clomn_num = 0
  for i = 1, skill_num do
    sec_index = job_skill_ini:FindSectionIndex(nx_string(sub_str[i]))
    if sec_index < 0 then
      nx_log("share\\Life\\job_skill.ini sec_index = " .. nx_string(sub_str[i]))
      return
    end
    local need_level = job_skill_ini:ReadInteger(sec_index, "needlevel", 0)
    if nx_int(job_level) >= nx_int(need_level) then
      clomn_num = clomn_num + 1
      local photo = job_skill_ini:ReadString(sec_index, "photo", "")
      grid:AddItem(i - 1, nx_string(photo), nx_widestr(sub_str[i]), 1, -1)
      local skill_configID = grid:GetItemName(nx_int(i - 1))
      if skill_configID ~= nil and nx_string(skill_configID) ~= "" then
        local skill_name = gui.TextManager:GetText("ui_" .. nx_string(skill_configID))
        local length = string.len(nx_string(skill_name))
        if nx_int(length) <= nx_int(4) then
          grid:SetItemAddInfo(nx_int(i - 1), nx_int(0), nx_widestr(skill_name))
        end
      end
    end
  end
  form.groupbox_skill.Width = grid.Width + 12
end
function fresh_vip_state(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local job_id = nx_string(form.job_id)
  if job_id == "" then
    form.groupbox_vip.Visible = false
    return
  end
  if job_id ~= "sh_kg" and job_id ~= "sh_qf" and job_id ~= "sh_yf" and job_id ~= "sh_nf" and job_id ~= "sh_lh" and job_id ~= "sh_ds" and job_id ~= "sh_ys" then
    form.groupbox_vip.Visible = false
    return
  end
  form.groupbox_vip.Visible = true
  local grid = form.ImageControlGrid_vip
  if client_player:FindRecord("sh_gather_vip_rec") then
    local mimute = 0
    local row = client_player:FindRecordRow("sh_gather_vip_rec", 0, job_id, 0)
    if 0 <= row then
      mimute = client_player:QueryRecord("sh_gather_vip_rec", row, 1)
    end
    local time_str = get_gather_vip_time_str(mimute)
    if 0 <= row then
      local photo = get_vip_photo(job_id, 1)
      grid:AddItem(0, photo, nx_widestr(time_str), 1, 0)
      grid:SetItemAddInfo(nx_int(0), nx_int(1), gui.TextManager:GetText("tips_" .. job_id .. "_zheng_1"))
      return
    end
  end
  local photo = get_vip_photo(job_id, 0)
  grid:AddItem(0, photo, nx_widestr(job_id), 1, 0)
  grid:SetItemAddInfo(nx_int(0), nx_int(1), gui.TextManager:GetText("tips_" .. job_id .. "_zheng_2"))
  grid.HasMultiTextBox = false
end
function get_gather_vip_time_str(alltime)
  local day = 0
  local hour = 0
  local minute = 0
  local zero = nx_int(0)
  if alltime <= 0 then
    return
  end
  day = nx_int(alltime / 1440)
  if zero < day then
    hour = nx_int((alltime - day * 1440) / 60)
  else
    hour = nx_int(alltime / 60)
  end
  minute = nx_int(alltime % 60)
  local gui = nx_value("gui")
  local str = nx_widestr(gui.TextManager:GetText("ui_remaintime"))
  if zero < day then
    str = str .. nx_widestr(day) .. nx_widestr(gui.TextManager:GetText("ui_g_day"))
  end
  if zero < hour then
    str = str .. nx_widestr(hour) .. nx_widestr(gui.TextManager:GetText("ui_g_hours"))
  end
  if zero < minute then
    str = str .. nx_widestr(minute) .. nx_widestr(gui.TextManager:GetText("ui_g_minutes"))
  end
  return str
end
function get_vip_photo(job_id, status)
  local photo = ""
  if job_id == "sh_kg" then
    if nx_int(status) ~= nx_int(0) then
      photo = "gui\\special\\life\\icon_miner_on.png"
    else
      photo = "gui\\special\\life\\icon_miner_off.png"
    end
  elseif job_id == "sh_ys" or job_id == "sh_ds" then
    if nx_int(status) ~= nx_int(0) then
      photo = "gui\\special\\life\\icon_apothecary_on.png"
    else
      photo = "gui\\special\\life\\icon_apothecary_off.png"
    end
  elseif job_id == "sh_yf" then
    if nx_int(status) ~= nx_int(0) then
      photo = "gui\\special\\life\\icon_fishman_on.png"
    else
      photo = "gui\\special\\life\\icon_fishman_off.png"
    end
  elseif job_id == "sh_qf" then
    if nx_int(status) ~= nx_int(0) then
      photo = "gui\\special\\life\\icon_axman_on.png"
    else
      photo = "gui\\special\\life\\icon_axman_off.png"
    end
  elseif job_id == "sh_lh" then
    if nx_int(status) ~= nx_int(0) then
      photo = "gui\\special\\life\\icon_hunter_on.png"
    else
      photo = "gui\\special\\life\\icon_hunter_off.png"
    end
  elseif job_id == "sh_nf" then
    if nx_int(status) ~= nx_int(0) then
      photo = "gui\\special\\life\\icon_farmer_on.png"
    else
      photo = "gui\\special\\life\\icon_farmer_off.png"
    end
  end
  return photo
end
function on_btn_buy_vip_click(btn)
  nx_execute(G_SHOP_PATH, "show_charge_shop", CHARGE_GATHER_SHOP)
end
function on_ImageControlGrid_vip_mousein_grid(grid, index)
  local text = grid:GetItemAddText(index, nx_int(1))
  local vip_time_str = grid:GetItemAddText(index, nx_int(0))
  local strs = nx_widestr("")
  if string.len(nx_string(vip_time_str)) > 6 then
    local weixide = nx_widestr("<font color=\"#FF0000\">") .. nx_widestr(vip_time_str) .. nx_widestr("</font>")
    strs = nx_widestr(nx_widestr(text) .. nx_widestr("<br>") .. nx_widestr(weixide))
  else
    strs = text
  end
  nx_execute("tips_game", "show_text_tip", strs, grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
end
function on_ImageControlGrid_vip_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_skill_select_changed(grid, index)
  local form = grid.ParentForm
  local job_id = nx_string(form.job_id)
  if job_id == "" or job_id == nil then
    return
  end
  local skill_configID = grid:GetItemName(index)
  local func_name = nx_string(skill_configID)
  if func_name == nil or skill_configID == nil or nx_string(skill_configID) == "" then
    return
  end
  local jobskill_path = "share\\Life\\job_skill.ini"
  local job_skill_ini = nx_execute("util_functions", "get_ini", jobskill_path)
  if not nx_is_valid(job_skill_ini) then
    return
  end
  local sec_index = job_skill_ini:FindSectionIndex(nx_string(skill_configID))
  if sec_index < 0 then
    nx_log("share\\Life\\job_skill.ini sec_index = " .. nx_string(skill_configID))
    return
  end
  local can_select = job_skill_ini:ReadString(sec_index, "canselect", "")
  if nx_int(can_select) == nx_int(0) then
    return
  end
  local gui = nx_value("gui")
  local func_manager = nx_value("func_manager")
  if nx_is_valid(func_manager) then
    local photo = job_skill_ini:ReadString(sec_index, "photo", "")
    if not nx_is_valid(gui) then
      return
    end
    if gui.GameHand:IsEmpty() then
      gui.GameHand:SetHand(GHT_FUNC, photo, "func", nx_string(func_name), "", "")
    else
      gui.GameHand:ClearHand()
    end
  end
end
function on_imagegrid_skill_rightclick_grid(grid, index)
  grid:SetSelectItemIndex(index)
  local skill_configID = grid:GetItemName(index)
  local func_name = nx_string(skill_configID)
  if skill_configID == nil or nx_string(func_name) == "" then
    return
  end
  g_jobid = ""
  g_form_type = 9
  nx_execute(nx_current(), func_name, index)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_imagegrid_skill_mousein_grid(grid, index)
  local skill_configID = grid:GetItemName(index)
  local gui = nx_value("gui")
  if skill_configID == nil or nx_string(skill_configID) == "" then
    return
  end
  local skill_name = gui.TextManager:GetText("ui_" .. nx_string(skill_configID))
  local des_info = gui.TextManager:GetText("desc_" .. nx_string(skill_configID))
  local info_val = nx_widestr(skill_name) .. nx_widestr("<br>") .. nx_widestr(des_info)
  nx_execute("tips_game", "show_text_tip", info_val, grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
end
function on_imagegrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_baoshi_select_changed(grid, index)
  on_imagegrid_baoshi_rightclick_grid(grid, index)
end
function on_btn_life_fight_click(btn)
  local form = nx_value("form_stage_main\\form_life\\form_job_main_new")
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_life_fight", "set_job", form.job_id, get_job_level(form.job_id))
  nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_life_fight", "auto_show_hide_form_puzzle_life_fight", 1)
end
function on_job_rec_refresh(form, recordname, optype, row, clomn)
  if optype ~= "add" and optype ~= "del" and optype ~= "clear" and optype ~= "update" then
    return
  end
  fresh_form(form)
  fresh_job_info(form, form.job_id)
end
function on_gather_vip_rec_refresh(form, recordname, optype, row, clomn)
  if optype ~= "add" and optype ~= "del" and optype ~= "clear" and optype ~= "update" then
    return
  end
  fresh_vip_state(form)
end
function find_life_job(job_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if 0 <= client_player:FindRecordRow("job_rec", 0, job_id, 0) then
    return true
  end
  return false
end
function get_job_level(job_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local row = client_player:FindRecordRow("job_rec", 0, job_id, 0)
  if row < 0 then
    return 0
  end
  return client_player:QueryRecord("job_rec", row, 1)
end
function get_job_type(job_id)
  for i, jobid in pairs(cai_table) do
    if nx_string(jobid) == nx_string(job_id) then
      return 1
    end
  end
  for i, jobid in pairs(zao_table) do
    if nx_string(jobid) == nx_string(job_id) then
      return 2
    end
  end
  for i, jobid in pairs(wen_table) do
    if nx_string(jobid) == nx_string(job_id) then
      return 3
    end
  end
  for i, jobid in pairs(shi_table) do
    if nx_string(jobid) == nx_string(job_id) then
      return 4
    end
  end
  return 0
end
function get_study_job(job_table)
  for i, job_id in pairs(job_table) do
    if find_life_job(job_id) then
      return job_id
    end
  end
  return ""
end
function life_skill_form_sh_kg()
  create_job_form("sh_kg", 0)
end
function life_skill_form_sh_lh()
  create_job_form("sh_lh", 0)
end
function life_skill_form_sh_nf()
  create_job_form("sh_nf", 0)
end
function life_skill_form_sh_qf()
  create_job_form("sh_qf", 0)
end
function life_skill_form_sh_yf()
  create_job_form("sh_yf", 0)
end
function life_skill_form_sh_cf()
  create_job_form("sh_cf", 1)
end
function life_skill_form_sh_cs()
  create_job_form("sh_cs", 1)
end
function life_skill_form_sh_ds()
  create_job_form("sh_ds", 1)
end
function life_skill_form_sh_jq()
  create_job_form("sh_jq", 1)
end
function life_skill_form_sh_tj()
  create_job_form("sh_tj", 1)
end
function life_skill_form_sh_ys()
  create_job_form("sh_ys", 1)
end
function life_skill_form_sh_qs()
  create_job_form("sh_qs", 2)
  refresh_player_culture_job_use_vip()
end
function life_skill_form_sh_ss()
  create_job_form("sh_ss", 1)
  refresh_player_culture_job_use_vip()
end
function life_skill_form_sh_hs()
  create_job_form("sh_hs", 1)
  refresh_player_culture_job_use_vip()
end
function life_skill_form_sh_qis(index)
  if nx_int(index) == nx_int(0) then
    index = 1
  else
    index = 2
  end
  create_job_form("sh_qis", index)
  refresh_player_culture_job_use_vip()
end
function life_skill_form_sh_gs()
  create_job_form("sh_gs", 2)
end
function life_skill_form_sh_qg(para)
  create_job_form("sh_qg", 2)
end
function life_skill_zhanshu()
  create_job_form("sh_qis", 2)
end
function life_skill_nongzuowu()
  create_job_form("sh_nf", 2)
end
function life_skill_ducao()
  create_job_form("sh_ds", 0)
end
function life_skill_zhongyao()
  create_job_form("sh_ys", 0)
end
function life_skill_fish()
  nx_execute("form_stage_main\\form_life\\form_fishing_op", "start_fishing")
end
function life_skill_jiagong()
  create_job_form("sh_nf", 1)
end
function life_skill_zhongzhi()
end
function life_skill_ronglian()
  create_job_form("sh_kg", 1)
end
function life_skill_duanzao()
end
function life_skill_zhizao()
end
function life_skill_dazao()
end
function life_skill_lianyao()
end
function life_skill_liandu()
end
function life_skill_pengren()
end
function life_skill_puqu(stringitem)
end
function life_skill_dapu()
end
function life_skill_pizhushu()
  gui = nx_value("gui")
  local photo = "cur\\maobi.ani"
  local cantphoto = "cur\\maobi1.ani"
  local jobid = "sh_ss"
  gui.GameHand:SetHand("Pizhushu", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_pizhuhua()
  gui = nx_value("gui")
  local photo = "cur\\maobi.ani"
  local cantphoto = "cur\\maobi1.ani"
  local jobid = "sh_hs"
  gui.GameHand:SetHand("Pizhuhua", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_chaolu()
  gui = nx_value("gui")
  local photo = "cur\\maobi.ani"
  local cantphoto = "cur\\maobi1.ani"
  local jobid = "sh_ss"
  gui.GameHand:SetHand("Chaolu", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_xiesheng()
end
function life_skill_suangua()
  nx_execute("form_stage_main\\form_life\\form_fortunetelling_op", "prepare_fortunetelling")
end
function life_skill_zougua()
  nx_execute("custom_sender", "custom_send_fortunetellingother", para)
end
function life_skill_famu()
end
function life_skill_bopi()
end
function life_skill_caoyao()
end
function life_skill_duyao()
end
function life_skill_yurou()
end
function life_skill_baogong()
end
function life_skill_caikuang()
end
function life_skill_tj_qianghua()
  local gui = nx_value("gui")
  local photo = "cur\\quench.ani"
  local cantphoto = "cur\\quench1.ani"
  local jobid = "sh_tj"
  gui.GameHand:SetHand("qianghua", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_cf_qianghua()
  local gui = nx_value("gui")
  local photo = "cur\\sew.ani"
  local cantphoto = "cur\\sew1.ani"
  local jobid = "sh_cf"
  gui.GameHand:SetHand("qianghua", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_cs_qianghua()
  local gui = nx_value("gui")
  local photo = "cur\\rub.ani"
  local cantphoto = "cur\\rub1.ani"
  local jobid = "sh_cs"
  gui.GameHand:SetHand("qianghua", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_jq_qianghua()
  local gui = nx_value("gui")
  local photo = "cur\\carve.ani"
  local cantphoto = "cur\\carve1.ani"
  local jobid = "sh_jq"
  gui.GameHand:SetHand("qianghua", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_ds_qianghua()
  local gui = nx_value("gui")
  local photo = "cur\\soak.ani"
  local cantphoto = "cur\\soak1.ani"
  local jobid = "sh_ds"
  gui.GameHand:SetHand("qianghua", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_ys_qianghua()
  local gui = nx_value("gui")
  local photo = "cur\\immerse.ani"
  local cantphoto = "cur\\immerse1.ani"
  local jobid = "sh_ys"
  gui.GameHand:SetHand("qianghua", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_sh_tj_split()
  local gui = nx_value("gui")
  local photo = "cur\\immerse.ani"
  local cantphoto = "cur\\immerse1.ani"
  local jobid = "sh_tj"
  gui.GameHand:SetHand("splititem", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_sh_jq_split()
  local gui = nx_value("gui")
  local photo = "cur\\immerse.ani"
  local cantphoto = "cur\\immerse1.ani"
  local jobid = "sh_jq"
  gui.GameHand:SetHand("splititem", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_sh_cf_split()
  local gui = nx_value("gui")
  local photo = "cur\\immerse.ani"
  local cantphoto = "cur\\immerse1.ani"
  local jobid = "sh_cf"
  gui.GameHand:SetHand("splititem", photo, nx_string(jobid), photo, cantphoto, "")
end
function life_skill_cf_fuse()
  nx_execute("form_stage_main\\form_life\\form_item_fuse", "on_fuse_form_open", "sh_cf")
end
function life_skill_tj_fuse()
  nx_execute("form_stage_main\\form_life\\form_item_fuse", "on_fuse_form_open", "sh_tj")
end
function life_skill_jq_fuse()
  nx_execute("form_stage_main\\form_life\\form_item_fuse", "on_fuse_form_open", "sh_jq")
end
function life_skill_ds_fuse()
  nx_execute("form_stage_main\\form_life\\form_item_fuse", "on_fuse_form_open", "sh_ds")
end
function life_skill_ys_fuse()
  nx_execute("form_stage_main\\form_life\\form_item_fuse", "on_fuse_form_open", "sh_ys")
end
function life_skill_cf_split()
  local form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_split", true)
  if nx_is_valid(form_split) then
    form_split.jobid = "sh_cf"
    nx_execute("custom_sender", "custom_lifeskill_split_item", form_split.jobid)
  end
end
function life_skill_tj_split()
  local form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_split", true)
  if nx_is_valid(form_split) then
    form_split.jobid = "sh_tj"
    nx_execute("custom_sender", "custom_lifeskill_split_item", form_split.jobid)
  end
end
function life_skill_jq_split()
  local form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_split", true)
  if nx_is_valid(form_split) then
    form_split.jobid = "sh_jq"
    nx_execute("custom_sender", "custom_lifeskill_split_item", form_split.jobid)
  end
end
function life_skill_ys_split()
  local form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_split", true)
  if nx_is_valid(form_split) then
    form_split.jobid = "sh_ys"
    nx_execute("custom_sender", "custom_lifeskill_split_item", form_split.jobid)
  end
end
function life_skill_ds_split()
  local form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_split", true)
  if nx_is_valid(form_split) then
    form_split.jobid = "sh_ds"
    nx_execute("custom_sender", "custom_lifeskill_split_item", form_split.jobid)
  end
end
function life_skill_ts_splite()
  local form_split = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_split", true)
  if nx_is_valid(form_split) then
    form_split.jobid = "treasuresplit"
    nx_execute("custom_sender", "custom_lifeskill_split_item", form_split.jobid)
  end
end
function life_skill_duiyi()
end
function create_job_form(jobid, form_type)
  if nx_string(g_jobid) == nx_string(jobid) and nx_int(g_form_type) == nx_int(form_type) then
    local form = nx_value("form_stage_main\\form_life\\form_job_main_new")
    if nx_is_valid(form) and form.Visible then
      auto_show_hide_life_form()
      return
    end
  end
  g_jobid = jobid
  g_form_type = form_type
  local form = show_or_hide_main_form(true)
  if not nx_is_valid(form) then
    return false
  end
  if nx_string(jobid) == "" or jobid == nil then
    return false
  end
  form.job_id = jobid
  fresh_job_info(form, jobid)
  if check_flag_valid(jobid) then
    nx_execute("custom_sender", "custom_cancel_open_life_flag", jobid)
  end
  if not find_life_job(jobid) then
    hide_all_child_form()
    return false
  end
  open_cai_zhao_form(jobid, form_type)
  local res_job = false
  res_job = is_culture_job(jobid)
  form.cbtn_use_vip.Visible = nx_boolean(res_job)
  return true
end
function open_cai_zhao_form(jobid, form_type)
  if jobid == nil or jobid == "" then
    return
  end
  if nx_string(jobid) == "sh_ds" or nx_string(jobid) == "sh_ys" then
    if nx_int(form_type) == nx_int(0) then
      load_form("form_stage_main\\form_life\\form_job_gather_new", "on_open_form", jobid)
    elseif nx_int(form_type) == nx_int(1) then
      load_form("form_stage_main\\form_life\\form_job_composite", "on_open_form", jobid)
    end
    return
  end
  if nx_string(jobid) == "sh_qf" then
    load_form("form_stage_main\\form_life\\form_job_gather_new", "on_open_form", jobid)
    return
  end
  if nx_string(jobid) == "sh_kg" then
    if nx_int(form_type) == nx_int(0) then
      load_form("form_stage_main\\form_life\\form_job_gather_new", "on_open_form", jobid)
    elseif nx_int(form_type) == nx_int(1) then
      load_form("form_stage_main\\form_life\\form_job_composite", "on_open_form", jobid)
    end
    return
  end
  if nx_string(jobid) == "sh_lh" or nx_string(jobid) == "sh_yf" then
    load_form("form_stage_main\\form_life\\form_job_gather", "on_open_form", jobid)
    return
  end
  if nx_string(jobid) == "sh_nf" then
    if nx_int(form_type) == nx_int(1) then
      load_form("form_stage_main\\form_life\\form_job_composite", "on_open_form", jobid)
    else
      load_form("form_stage_main\\form_life\\form_farm_crop", "on_main_form_open")
    end
    return
  end
  if nx_string(jobid) == "sh_cf" or nx_string(jobid) == "sh_cs" or nx_string(jobid) == "sh_jq" or nx_string(jobid) == "sh_tj" or nx_string(jobid) == "sh_ss" or nx_string(jobid) == "sh_hs" then
    load_form("form_stage_main\\form_life\\form_job_composite", "on_open_form", jobid)
    return
  end
  if nx_string(jobid) == "sh_qis" or nx_string(jobid) == "sh_qg" or nx_string(jobid) == "sh_qs" or nx_string(jobid) == "sh_gs" then
    if nx_int(form_type) == nx_int(2) and nx_string(jobid) == "sh_qis" then
      load_form("form_stage_main\\form_life\\form_job_war", "on_open_form", jobid)
    else
      load_form("form_stage_main\\form_life\\form_job_qishi", "on_open_form", jobid)
    end
    return
  end
end
function load_form(path, functionname, ...)
  hide_all_child_form()
  load_form_deatil(path, functionname, unpack(arg))
end
function hide_all_child_form()
  local form_gather = nx_value("form_stage_main\\form_life\\form_job_gather")
  if nx_is_valid(form_gather) then
    form_gather:Close()
  end
  local form_gather_new = nx_value("form_stage_main\\form_life\\form_job_gather_new")
  if nx_is_valid(form_gather_new) then
    form_gather_new:Close()
  end
  local form_composite = nx_value("form_stage_main\\form_life\\form_job_composite")
  if nx_is_valid(form_composite) then
    form_composite:Close()
  end
  local form_qishi = nx_value("form_stage_main\\form_life\\form_job_qishi")
  if nx_is_valid(form_qishi) then
    form_qishi:Close()
  end
  local form_war = nx_value("form_stage_main\\form_life\\form_job_war")
  if nx_is_valid(form_war) then
    form_war:Close()
  end
  local form_farm_crop = nx_value("form_stage_main\\form_life\\form_farm_crop")
  if nx_is_valid(form_farm_crop) then
    form_farm_crop:Close()
  end
end
function hide_all_combobox()
  local form_gather = nx_value("form_stage_main\\form_life\\form_job_gather")
  if nx_is_valid(form_gather) then
    form_gather.combobox_sort.DroppedDown = false
  end
  local form_gather_new = nx_value("form_stage_main\\form_life\\form_job_gather_new")
  if nx_is_valid(form_gather_new) then
    form_gather_new.combobox_sort.DroppedDown = false
  end
  local form_composite = nx_value("form_stage_main\\form_life\\form_job_composite")
  if nx_is_valid(form_composite) then
    form_composite.combobox_sort.DroppedDown = false
  end
  local form_qishi = nx_value("form_stage_main\\form_life\\form_job_qishi")
  if nx_is_valid(form_qishi) then
    form_qishi.combobox_sort.DroppedDown = false
  end
  local form_war = nx_value("form_stage_main\\form_life\\form_job_war")
  if nx_is_valid(form_war) then
    form_war.combobox_sort.DroppedDown = false
  end
end
function load_form_deatil(path, functionname, ...)
  local form = nx_value("form_stage_main\\form_life\\form_job_main_new")
  if not nx_is_valid(form) then
    return
  end
  local form_gather = nx_execute("util_gui", "util_get_form", path, true, false)
  if not nx_is_valid(form_gather) then
    return
  end
  form.groupbox_main.Visible = false
  form.groupbox_flag.Visible = false
  local is_load = form:Add(form_gather)
  if is_load == true then
    form_gather.Left = 4
    form_gather.Top = 40
  end
  form_gather.Visible = true
  nx_execute(path, functionname, form_gather, unpack(arg))
end
function show_or_hide_main_form(show)
  local form = nx_value("form_stage_main\\form_life\\form_job_main_new")
  if nx_is_valid(form) then
    if not form.Visible then
      form.Visible = true
      form:Show()
      refresh_player_culture_job_use_vip()
    end
  else
    form = util_auto_show_hide_form("form_stage_main\\form_life\\form_job_main_new")
  end
  form.groupbox_main.Visible = show
  form.groupbox_flag.Visible = show
  hide_all_combobox()
  return form
end
function open_form_job()
  util_auto_show_hide_form("form_stage_main\\form_life\\form_job_main_new")
end
function open_life_form_by_sh_id(jobid)
  if jobid == nil or jobid == "" then
    return false
  end
  local path = seach_btn_table[nx_string(jobid)]
  if path == nil or path == "" then
    return false
  end
  if not find_life_job(jobid) then
    return false
  end
  local form = show_or_hide_main_form(true)
  form.job_id = nx_string(jobid)
  g_jobid = ""
  g_form_type = 9
  return create_job_form(jobid, 1)
end
function is_can_qianghua(item)
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    return false
  end
  if gui.GameHand.Type ~= "qianghua" then
    return false
  end
  local job_needed = gui.GameHand.Para1
  if job_needed == nil or nx_string(job_needed) == "" then
    return false
  end
  if not nx_is_valid(item) then
    return false
  end
  local iscanbuild = item:QueryProp("IsCanBuild")
  if nx_number(iscanbuild) <= 0 then
    return false
  end
  local prop_get_pack = nx_number(item:QueryProp("PropGetPack"))
  if prop_get_pack <= 0 then
    return false
  end
  prop_get_pack = nx_string(prop_get_pack)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\equip_prop_rand.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(prop_get_pack))
  if sec_index < 0 then
    nx_log("share\\Rule\\equip_prop_rand.ini = " .. nx_string(prop_get_pack))
    return false
  end
  local job_id = ini:ReadString(sec_index, "JobName", "")
  if job_id == nil or job_id == "" then
    return false
  end
  if job_needed ~= job_id then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local row = client_player:FindRecordRow("job_rec", 0, job_id, 0)
  if row < 0 then
    return false
  end
  local job_level = client_player:QueryRecord("job_rec", row, 1)
  local level_needed = ini:ReadString(sec_index, "JobLevel", "")
  if level_needed == nil or level_needed == "" then
    return false
  end
  if nx_number(job_level) < nx_number(level_needed) then
    return false
  end
  return true
end
function is_can_pizhu(item, pizhu_type)
  if not nx_is_valid(item) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local item_type = item:QueryProp("ItemType")
  local jobid = ""
  local pzpackidkey = ""
  if pizhu_type == "Pizhushu" then
    if item_type ~= ITEMTYPE_WEAPON_BOOK then
      return false
    end
    jobid = "sh_ss"
    pzpackidkey = "ScholarPz"
  elseif pizhu_type == "Pizhuhua" then
    if item_type ~= ITEMTYPE_WEAPON_PAINT then
      return false
    end
    jobid = "sh_hs"
    pzpackidkey = "PainterPz"
  else
    return false
  end
  local maxpzcount = 0
  local pzcount = 0
  if item:FindProp("MaxPzCount") then
    maxpzcount = item:QueryProp("MaxPzCount")
  end
  if item:FindProp("PzCount") then
    pzcount = item:QueryProp("PzCount")
  end
  if maxpzcount - pzcount <= 0 then
    return false
  end
  if item:FindProp("ProNames") then
    local names = item:QueryProp("ProNames")
    local player_name = client_player:QueryProp("Name")
    local table_names = util_split_string(nx_string(names), ",")
    for i = 1, table.getn(table_names) do
      if nx_string(player_name) == nx_string(table_names[i]) then
        return false
      end
    end
  end
  if not item:FindProp(pzpackidkey) then
    return false
  end
  local pzpackid = item:QueryProp(pzpackidkey)
  local filepath = "share\\Life\\" .. pzpackidkey .. ".ini"
  local pz_ini = nx_execute("util_functions", "get_ini", filepath)
  if not nx_is_valid(pz_ini) then
    return false
  end
  local index = pz_ini:FindSectionIndex(nx_string(pzpackid))
  if index < 0 then
    return false
  end
  local need_level = pz_ini:ReadInteger(index, "PzNeedLevel", 0)
  local row = client_player:FindRecordRow("job_rec", 0, jobid, 0)
  if row < 0 then
    return false
  end
  local level = client_player:QueryRecord("job_rec", row, 1)
  if need_level > level then
    return false
  end
  local need_ene = pz_ini:ReadInteger(index, "NeedEne", 0)
  local ene = client_player:QueryProp("Ene")
  if need_ene > ene then
    return false
  end
  local toollimited = pz_ini:ReadInteger(index, "ToolLimited", 0)
  if not life_tool_limit_check(toollimited) then
    return false
  end
  return true
end
function life_tool_limit_check(toollimited)
  if nx_number(toollimited) < 0 then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\LifeToolLimitInfo.ini")
  if not nx_is_valid(ini) then
    return false
  end
  if ini:FindSection(nx_string(toollimited)) then
    local sec_index = ini:FindSectionIndex(nx_string(toollimited))
    if sec_index < 0 then
      nx_log("share\\Life\\LifeToolLimitInfo.ini = " .. nx_string(toollimited))
      return false
    end
    local tool_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
    for i = 1, table.getn(tool_table) do
      local info_lst = util_split_string(tool_table[i], ",")
      if table.getn(info_lst) == 3 then
        local tool_pos = tool_table[2]
        local default_view_id
        if tool_pos == 1 then
          default_view_id = VIEWPORT_EQUIP
        end
        local tool_lst = util_split_string(info_lst[1], "/")
        local tool_have = true
        for j = 1, table.getn(tool_lst) do
          local tool_id = tool_lst[j]
          if default_view_id == nil then
            default_view_id = ""
            local goods_grid = nx_value("GoodsGrid")
            if nx_is_valid(goods_grid) then
              default_view_id = goods_grid:GetToolBoxViewport(nx_string(tool_id))
            end
          end
          local view = game_client:GetView(nx_string(default_view_id))
          local viewobj_list = view:GetViewObjList()
          local view_have = false
          for i, obj in pairs(viewobj_list) do
            local tempid = obj:QueryProp("ConfigID")
            if tempid == tool_id then
              view_have = true
            end
          end
          if not view_have then
            tool_have = false
            break
          end
        end
        if tool_have then
          return true
        end
      end
    end
  end
  return false
end
function find_item_in_toolbox(config_id, count)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return false
  end
  return goods_grid:CheckItemCount(nx_string(config_id), nx_int(count))
end
function is_can_split(item, job_id)
  if not item:FindProp("LifeSplitItemPackage") then
    return false
  end
  local LifeSplitItemPackage = item:QueryProp("LifeSplitItemPackage")
  if LifeSplitItemPackage <= 0 then
    return false
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\LifeSplitItemInfo.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(LifeSplitItemPackage))
  if sec_index < 0 then
    nx_log("share\\Life\\LifeSplitItemInfo.ini = " .. nx_string(LifeSplitItemPackage))
    return false
  end
  local need_jobid = ini:ReadString(sec_index, "JobID", "")
  if nx_string(need_jobid) ~= nx_string(job_id) then
    return false
  end
  local min_level = ini:ReadInteger(sec_index, "MinLevel", 0)
  local job_level = get_job_level(job_id)
  if nx_int(job_level) < nx_int(min_level) then
    return false
  end
  local toollimited = ini:ReadInteger(sec_index, "ToolLimited", 0)
  if not life_tool_limit_check(toollimited) then
    return false
  end
  return true
end
function is_can_chaolu(item, job_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not item:FindProp("ChaoluPack") then
    return false
  end
  local chaoluPackage = item:QueryProp("ChaoluPack")
  if chaoluPackage <= 0 then
    return false
  end
  if not item:FindProp("ChaoluTimes") then
    return false
  end
  local chaoluTimes = item:QueryProp("ChaoluTimes")
  if chaoluTimes <= 0 then
    return false
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\ScholarCopy.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(chaoluPackage))
  if sec_index < 0 then
    nx_log("share\\Life\\ScholarCopy.ini sec_index = " .. nx_string(chaoluPackage))
    return false
  end
  local job_level = get_job_level(job_id)
  local need_level = ini:ReadInteger(sec_index, "MinLevel", 0)
  if nx_int(job_level) < nx_int(need_level) then
    return false
  end
  local ene = client_player:QueryProp("Ene")
  local need_ene = ini:ReadInteger(sec_index, "NeedEne", 0)
  if nx_int(ene) < nx_int(need_ene) then
    return false
  end
  local toollimited = ini:ReadInteger(sec_index, "ToolLimited", 0)
  if not life_tool_limit_check(toollimited) then
    return false
  end
  local material = ini:ReadString(sec_index, "Material", "")
  if not is_material_enough(material) then
    return false
  end
  return true
end
function is_material_enough(material)
  local game_client = nx_value("game_client")
  local str_lst = util_split_string(material, ";")
  if table.getn(str_lst) <= 0 then
    return true
  end
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    local item = str_temp[1]
    local num = str_temp[2]
    local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
    if nx_is_valid(view) then
      local viewobj_list = view:GetViewObjList()
      local total = 0
      for i, obj in pairs(viewobj_list) do
        local tempid = obj:QueryProp("ConfigID")
        if tempid == item then
          local cur_amount = obj:QueryProp("Amount")
          total = total + cur_amount
        end
      end
      if nx_int(total) < nx_int(num) then
        return false
      end
    end
  end
  return true
end
function chang_life_skill_photo(item)
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    return 0
  end
  local type = gui.GameHand.Type
  local para1 = gui.GameHand.Para1
  local para2 = gui.GameHand.Para2
  local para3 = gui.GameHand.Para3
  local para4 = gui.GameHand.Para4
  if type == "qianghua" then
    if not nx_is_valid(item) then
      gui.GameHand:ClearHand()
      gui.GameHand:SetHand(type, para2, para1, para2, para3, para4)
    elseif is_can_qianghua(item) then
      gui.GameHand:SetHand(type, para2, para1, para2, para3, para4)
    else
      gui.GameHand:SetHand(type, para3, para1, para2, para3, para4)
    end
    return 1
  end
  if type == "Pizhushu" or type == "Pizhuhua" then
    if not nx_is_valid(item) then
      gui.GameHand:ClearHand()
      gui.GameHand:SetHand(type, para2, para1, para2, para3, para4)
    elseif is_can_pizhu(item, type) then
      gui.GameHand:SetHand(type, para2, para1, para2, para3, para4)
    else
      gui.GameHand:SetHand(type, para3, para1, para2, para3, para4)
    end
    return 1
  end
  if type == "splititem" then
    if not nx_is_valid(item) then
      gui.GameHand:ClearHand()
      gui.GameHand:SetHand(type, para2, para1, para2, para3, para4)
    elseif is_can_split(item, para1) then
      gui.GameHand:SetHand(type, para2, para1, para2, para3, para4)
    else
      gui.GameHand:SetHand(type, para3, para1, para2, para3, para4)
    end
  end
  if type == "Chaolu" then
    if not nx_is_valid(item) then
      gui.GameHand:ClearHand()
      gui.GameHand:SetHand(type, para2, para1, para2, para3, para4)
    elseif is_can_chaolu(item, para1) then
      gui.GameHand:SetHand(type, para2, para1, para2, para3, para4)
    else
      gui.GameHand:SetHand(type, para3, para1, para2, para3, para4)
    end
  end
  return 1
end
function life_skill_beg_to_npc()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  local target = game_client:GetSceneObj(nx_string(client_player:QueryProp("LastObject")))
  if not nx_is_valid(target) then
    local gui = nx_value("gui")
    local info = gui.TextManager:GetText("12400")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_chat_13")
    gui.TextManager:Format_AddParam(info)
    local chat_info = gui.TextManager:Format_GetText()
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(chat_info, SYSTYPE_FIGHT, 0)
    end
    return
  end
  local para = "hc_1901001"
  nx_execute("custom_sender", "custom_send_beg", para)
end
function find_grid_item(grid, config_id)
  local size = grid.RowNum * grid.ClomnNum
  for i = 1, size do
    local skill_configID = grid:GetItemName(i - 1)
    if nx_string(skill_configID) == config_id then
      return i - 1
    end
  end
  return -1
end
function on_btn_giveup_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  gui.TextManager:Format_SetIDName("ui_lifegiveup")
  local jobtext
  if form.job_id == "sh_kg" then
    jobtext = "ui_KuangGong"
  elseif form.job_id == "sh_lh" then
    jobtext = "ui_LieHu"
  elseif form.job_id == "sh_nf" then
    jobtext = "ui_NongFu"
  elseif form.job_id == "sh_qf" then
    jobtext = "ui_QiaoFu"
  elseif form.job_id == "sh_yf" then
    jobtext = "ui_YuFu"
  elseif form.job_id == "sh_cf" then
    jobtext = "ui_CaiFeng"
  elseif form.job_id == "sh_cs" then
    jobtext = "ui_ChuShi"
  elseif form.job_id == "sh_ds" then
    jobtext = "ui_DuShi"
  elseif form.job_id == "sh_jq" then
    jobtext = "ui_JinJiang"
  elseif form.job_id == "sh_tj" then
    jobtext = "ui_TieJiang"
  elseif form.job_id == "sh_ys" then
    jobtext = "ui_YaoShi"
  elseif form.job_id == "sh_qs" then
    jobtext = "ui_QinShi"
  elseif form.job_id == "sh_qis" then
    jobtext = "ui_QiShi"
  elseif form.job_id == "sh_ss" then
    jobtext = "ui_ShuSheng"
  elseif form.job_id == "sh_hs" then
    jobtext = "ui_HuaShi"
  elseif form.job_id == "sh_gs" then
    jobtext = "ui_GuaShi"
  elseif form.job_id == "sh_qg" then
    jobtext = "ui_QiGai"
  end
  local dia = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm_del", true, false)
  dia.event_type = "my_del"
  dia:ShowModal()
  gui.TextManager:Format_AddParam(nx_widestr(gui.TextManager:GetText(jobtext)))
  local Text = nx_widestr(gui.TextManager:Format_GetText())
  dia.mltbox_info:Clear()
  dia.mltbox_info:AddHtmlText(Text, -1)
  local res = nx_wait_event(100000000, dia, "my_del_confirm_return")
  if "ok" == res then
    nx_execute("custom_sender", "custom_giveup_job", form.job_id)
    hide_all_child_form()
    show_or_hide_main_form(true)
    return
  else
    return
  end
end
function get_job_num_id(job_id)
  if job_id == "sh_kg" then
    return 0
  elseif job_id == "sh_lh" then
    return 1
  elseif job_id == "sh_nf" then
    return 2
  elseif job_id == "sh_qf" then
    return 3
  elseif job_id == "sh_yf" then
    return 4
  elseif job_id == "sh_cf" then
    return 5
  elseif job_id == "sh_cs" then
    return 6
  elseif job_id == "sh_ds" then
    return 7
  elseif job_id == "sh_jq" then
    return 8
  elseif job_id == "sh_tj" then
    return 9
  elseif job_id == "sh_ys" then
    return 10
  elseif job_id == "sh_qs" then
    return 11
  elseif job_id == "sh_qis" then
    return 12
  elseif job_id == "sh_ss" then
    return 13
  elseif job_id == "sh_hs" then
    return 14
  elseif job_id == "sh_gs" then
    return 15
  elseif job_id == "sh_qg" then
    return 16
  end
  return -1
end
function check_flag_valid(jobid)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local row = client_player:FindRecordRow("job_rec", 0, jobid, 0)
  if row < 0 then
    return false
  end
  local index = get_job_num_id(jobid)
  if nx_int(-1) == nx_int(index) then
    return false
  end
  local str_rec = client_player:QueryProp("OpenLifeJob")
  local value = nx_function("get_str_rec_flag", str_rec, index)
  return value
end
function fresh_job_flag(jobid, btn, status)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local flag_name = "lbl_flag_" .. nx_string(get_job_num_id(jobid))
  local lbl_flag = form.groupbox_flag:Find(nx_string(flag_name))
  if not nx_is_valid(lbl_flag) then
    return
  end
  lbl_flag.BackImage = ""
  if status ~= 4 then
    if check_flag_valid(jobid) then
      lbl_flag.BackImage = "gui\\mainform\\smallgame\\mylife\\gantan.png"
    end
  else
    lbl_flag.BackImage = ""
  end
end
function get_open_life_flag_count()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return -1
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  local str_rec = client_player:QueryProp("OpenLifeJob")
  local count = 0
  if client_player:FindRecord("job_rec") then
    local rows = client_player:GetRecordRows("job_rec")
    for row = 0, rows do
      local job_id = client_player:QueryRecord("job_rec", row, 0)
      if check_flag_valid(job_id) then
        count = count + 1
      end
    end
  end
  return count
end
function on_btn_set_share_click(btn)
  local form = btn.ParentForm
  local jobid = form.job_id
  if jobid == "" or jobid == nil then
    return
  end
  local formshareset = util_get_form("form_stage_main\\form_life\\form_job_share_set", true)
  if not nx_is_valid(formshareset) then
    return
  end
  if formshareset.Visible == true then
    nx_execute("form_stage_main\\form_life\\form_job_share_set", "close_form_job", jobid)
  else
    nx_execute("form_stage_main\\form_life\\form_job_share_set", "open_form_job", jobid)
  end
end
function on_update_open_life_flag(form)
  fresh_all_btn_state(form)
end
function get_life_must_originid(jobid, joblevel)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local job_sf_path = "share\\Item\\lifesfname.ini"
  local sf_ini = nx_execute("util_functions", "get_ini", job_sf_path)
  if not nx_is_valid(sf_ini) then
    return 0
  end
  local index = sf_ini:FindSectionIndex(nx_string(jobid))
  if index < 0 then
    return 0
  end
  joblevel = nx_number(joblevel)
  for i = joblevel, 1, -1 do
    local originid = sf_ini:ReadString(index, nx_string(i), "")
    local row = client_player:FindRecordRow("title_rec", 0, nx_int(originid), 0)
    if 0 <= row then
      return client_player:QueryRecord("title_rec", row, 0)
    end
  end
  return sf_ini:ReadString(index, nx_string(1), "")
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
function have_new_skill()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local newjob = client_player:QueryProp("NewJob")
  return nx_int(newjob) == nx_int(1)
end
function on_btn_introduce_click(btn)
  local form = btn.ParentForm
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  local currentscene = map_query:GetCurrentScene()
  local inifile = nx_execute("util_functions", "get_ini", "share\\Item\\LifeChangJSF.ini")
  if not nx_is_valid(inifile) then
    return
  end
  local index = inifile:FindSectionIndex(nx_string(currentscene))
  if index < 0 then
    return
  end
  local introducetext = inifile:ReadString(index, nx_string(form.job_id), "")
  local sub_str = util_split_string(introducetext, ",")
  if table.getn(sub_str) < 2 then
    return
  end
  nx_execute("form_stage_main\\form_map\\form_map_scene", "on_show_scene_npc", nx_string(sub_str[1]), nx_int(sub_str[2]))
end
function on_btn_xd_shop_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_life\\form_life_shop")
end
function on_mltbox_info_click_hyperlink(self, index, data)
  data = nx_string(data)
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", data)
end
function on_cbtn_use_vip_checked_changed(cbtn)
  if not cbtn.Checked then
    set_status_culture_job_use_vip(false)
    return
  end
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    cbtn.Checked = false
    return
  end
  local res_use = can_culture_job_use_vip(form.job_id)
  if not res_use then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_zhizunvip_condition"), 2)
    end
    cbtn.Checked = false
    return
  end
  set_status_culture_job_use_vip(true)
end
function can_culture_job_use_vip(job_id)
  local QinGame = nx_value("QinGame")
  if not nx_is_valid(QinGame) then
    return false
  end
  local res_condition = QinGame:CanPlayerCultureJobUseVIP()
  if not nx_boolean(res_condition) then
    return false
  end
  if not is_culture_job(job_id) then
    return false
  end
  return true
end
function is_culture_job(job_id)
  local ST_FUNCTION_CULTURE_JOB_USEVIP_WIN = 814
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  local res_switch = switch_manager:CheckSwitchEnable(ST_FUNCTION_CULTURE_JOB_USEVIP_WIN)
  if not nx_boolean(res_switch) then
    return false
  end
  local cur_select_job = nx_string(job_id)
  local res_job = false
  for i, wen_job_id in pairs(wen_table) do
    if cur_select_job == wen_job_id and find_life_job(cur_select_job) then
      return true
    end
  end
  return false
end
function set_status_culture_job_use_vip(b_status)
  local entity = nx_value("QinGame")
  if nx_is_valid(entity) then
    entity.bUseVIP = nx_boolean(b_status)
  end
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  local n_use = 2
  if nx_boolean(b_status) then
    n_use = 1
  end
  local n_use_vip = util_get_property_key(game_config_info, "vip_auto_play_qin", 0)
  if nx_int(n_use) ~= nx_int(n_use_vip) then
    if nx_boolean(b_status) then
      util_set_property_key(game_config_info, "vip_auto_play_qin", nx_int(1))
    else
      util_set_property_key(game_config_info, "vip_auto_play_qin", nx_int(2))
    end
    local customizing = nx_value("customizing_manager")
    if nx_is_valid(customizing) then
      customizing:SaveConfigToServer()
    end
  end
end
function is_culture_job_use_vip()
  local QinGame = nx_value("QinGame")
  if not nx_is_valid(QinGame) then
    return false
  end
  return nx_boolean(QinGame:IsPlayerCultureJobUseVIP())
end
function refresh_player_culture_job_use_vip()
  local ST_FUNCTION_CULTURE_JOB_USEVIP_WIN = 814
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local res_switch = switch_manager:CheckSwitchEnable(ST_FUNCTION_CULTURE_JOB_USEVIP_WIN)
  if not nx_boolean(res_switch) then
    return
  end
  local form = nx_value(FORM_JOB_MAIN_NEW)
  if not nx_is_valid(form) then
    return
  end
  if not nx_boolean(form.Visible) then
    return
  end
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  local n_use_vip = util_get_property_key(game_config_info, "vip_auto_play_qin", 0)
  if nx_int(n_use_vip) == nx_int(1) then
    local res_use = can_culture_job_use_vip(form.job_id)
    form.cbtn_use_vip.Checked = nx_boolean(res_use)
  else
    form.cbtn_use_vip.Checked = false
  end
end
