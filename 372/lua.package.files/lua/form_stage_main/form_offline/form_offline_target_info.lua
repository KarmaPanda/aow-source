require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("form_stage_main\\form_offline\\offline_define")
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  update_form_pos(form)
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function update_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function refresh_offline_info(form, obj)
  if not nx_is_valid(obj) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local offmgr = nx_value("OffLineJobManager")
  if not nx_is_valid(offmgr) then
    return
  end
  if obj:FindProp("Name") then
    form.lbl_name_text.Text = nx_widestr(obj:QueryProp("Name"))
  end
  if obj:FindProp("Sex") then
    local sex_num = obj:QueryProp("Sex")
    if sex_num == 0 then
      form.lbl_sex_text.Text = nx_widestr(util_text("ui_male"))
    elseif sex_num == 1 then
      form.lbl_sex_text.Text = nx_widestr(util_text("ui_female"))
    end
  else
    form.lbl_sex_text.Text = nx_widestr(util_text("ui_male"))
  end
  form.lbl_school_text.Text = nx_widestr(util_text("str_none"))
  if obj:FindProp("School") then
    local school = obj:QueryProp("School")
    if nx_string(school) ~= "" then
      form.lbl_school_text.Text = nx_widestr(util_text(school))
    end
  end
  form.lbl_guild_text.Text = nx_widestr(util_text("str_none"))
  if obj:FindProp("GuildName") then
    local guild = obj:QueryProp("GuildName")
    if nx_string(guild) ~= "" then
      form.lbl_guild_text.Text = nx_widestr(util_text(guild))
    end
  end
  form.lbl_power_text.Text = nx_widestr(util_text("str_none"))
  if obj:FindProp("LevelTitle") then
    local power = obj:QueryProp("LevelTitle")
    if nx_string(power) ~= "" then
      form.lbl_power_text.Text = nx_widestr(util_text("desc_" .. nx_string(power)))
    end
  end
  form.lbl_sat_text.Text = nx_widestr("0")
  if obj:FindProp("Sat") then
    local sat = obj:QueryProp("Sat")
    form.lbl_sat_text.Text = nx_widestr(sat)
  end
  form.lbl_ene_text.Text = nx_widestr("0")
  if obj:FindProp("Ene") then
    local ene = obj:QueryProp("Ene")
    form.lbl_ene_text.Text = nx_widestr(ene)
  end
  local logicstate = obj:QueryProp("LogicState")
  if logicstate == LS_OFFLINEJOB then
    local off_id = obj:QueryProp("OfflineJobId")
    local off_type = offmgr:GetOffLineJobProp(off_id, "IsFreedom")
    if nx_number(off_type) == 0 then
      form.lbl_origin_text.Text = nx_widestr(util_text(off_id)) .. nx_widestr("(") .. nx_widestr(util_text("ui_off_free_job")) .. nx_widestr(")")
    else
      form.lbl_origin_text.Text = nx_widestr(util_text(off_id)) .. nx_widestr("(") .. nx_widestr(util_text("ui_off_unfree_job")) .. nx_widestr(")")
    end
  elseif nx_number(logicstate) == nx_number(LS_OFFLINE_LIFE) then
    form.lbl_origin_text.Text = nx_widestr(util_text("ui_off_lifejob_pracitice"))
  elseif nx_number(logicstate) == nx_number(LS_OFFLINE_WUXUE) then
    form.lbl_origin_text.Text = nx_widestr(util_text("ui_off_wuxuw_practice"))
  elseif nx_number(logicstate) == nx_number(LS_OFFLINE_STALL) then
    form.lbl_origin_text.Text = nx_widestr(util_text("ui_off_stall"))
  end
  form.lbl_time_text.Text = nx_widestr("0")
  if nx_number(logicstate) == nx_number(LS_OFFLINEJOB) then
    if obj:FindProp("Fag") then
      local fag = obj:QueryProp("Fag")
      if 0 < nx_number(fag) then
        form.lbl_time_text.Text = nx_widestr(fag) .. nx_widestr(util_text("ui_off_minute"))
        form.lbl_time_text.Visible = true
      end
    end
  elseif nx_number(logicstate) == nx_number(LS_OFFLINE_WUXUE) then
    if obj:FindProp("TrusteeTime") then
      local trusteetime = obj:QueryProp("TrusteeTime")
      if 0 < nx_number(trusteetime) then
        form.lbl_time_text.Text = nx_widestr(trusteetime) .. nx_widestr(util_text("ui_off_minute"))
        form.lbl_time_text.Visible = true
      end
    end
  else
    form.lbl_time_text.Visible = false
  end
end
