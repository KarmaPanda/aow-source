require("util_gui")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2 + 5
  form.Top = (gui.Height - form.Height) / 2 + 15
  fresh_form(form)
  form.btn_back.Parent:ToFront(form.btn_back)
end
function on_main_form_close(form)
  nx_destroy(form)
  local form_gather = nx_value("form_stage_main\\form_life\\form_job_gather")
  local form_composite = nx_value("form_stage_main\\form_life\\form_job_composite")
  if nx_is_valid(form_gather) then
    nx_destroy(form_gather)
  end
  if nx_is_valid(form_composite) then
    nx_destroy(form_composite)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_back_click(btn)
  on_btn_close_click(btn)
  local form_job = nx_value("form_stage_main\\form_life\\form_job_main_new")
  if nx_is_valid(form_job) then
    if not form_job.Visible then
      form_job.Visible = true
      form_job:Show()
    end
  else
    util_auto_show_hide_form("form_stage_main\\form_life\\form_job_main_new")
  end
end
function fresh_form(form)
  local jobid = form.JobID
  if jobid == nil or jobid == "" then
    return
  end
  if nx_string(jobid) == "sh_kg" or nx_string(jobid) == "sh_ds" or nx_string(jobid) == "sh_ys" then
    form.groupbox_2.Visible = true
    form.rbtn_gather.ClickEvent = true
    form.rbtn_composite.ClickEvent = true
    form.rbtn_gather.Checked = true
    load_form_gather(form, false)
    load_form_composite(form, false)
    return
  end
  if nx_string(jobid) == "sh_lh" or nx_string(jobid) == "sh_nf" or nx_string(jobid) == "sh_qf" or nx_string(jobid) == "sh_yf" then
    form.groupbox_2.Visible = false
    load_form_gather(form, true)
    return
  end
  if nx_string(jobid) == "sh_cf" or nx_string(jobid) == "sh_cs" or nx_string(jobid) == "sh_jq" or nx_string(jobid) == "sh_tj" or nx_string(jobid) == "sh_ss" or nx_string(jobid) == "sh_hs" then
    form.groupbox_2.Visible = false
    load_form_composite(form, true)
    return
  end
end
function on_rbtn_info_click(rbtn)
  local form = rbtn.ParentForm
  local form_gather = nx_value("form_stage_main\\form_life\\form_job_gather")
  local form_composite = nx_value("form_stage_main\\form_life\\form_job_composite")
  if not nx_is_valid(form_gather) then
    return
  end
  if not nx_is_valid(form_composite) then
    return
  end
  form_gather.JobID = form.JobID
  form_composite.JobID = form.JobID
  if rbtn.TabIndex == 1 then
    form_gather.Visible = true
    form_composite.Visible = false
  elseif rbtn.TabIndex == 2 then
    form_gather.Visible = false
    form_composite.Visible = true
  end
end
function load_form_gather(form, show)
  local form_gather = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_gather", true, false)
  if not nx_is_valid(form_gather) then
    return
  end
  local is_load = form:Add(form_gather)
  if is_load == true then
    form_gather.Left = 8
    form_gather.Top = 10
  end
  form_gather.JobID = form.JobID
  form_gather.Visible = show
end
function load_form_composite(form, show)
  local form_composite = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_composite", true, false)
  if not nx_is_valid(form_composite) then
    return
  end
  local is_load = form:Add(form_composite)
  if is_load == true then
    form_composite.Left = 8
    form_composite.Top = 10
  end
  form_composite.JobID = form.JobID
  form_composite.Visible = show
end
function open_form_job(job_id)
  local form = util_get_form("form_stage_main\\form_life\\form_job_info", true)
  if not nx_is_valid(form) then
    return
  end
  form.JobID = job_id
  util_auto_show_hide_form("form_stage_main\\form_life\\form_job_info")
end
