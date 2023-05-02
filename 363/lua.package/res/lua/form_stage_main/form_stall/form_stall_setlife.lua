require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
local JobRec = "job_rec"
local zao_table = {
  "sh_cf",
  "sh_cs",
  "sh_ds",
  "sh_jq",
  "sh_tj",
  "sh_ys"
}
function main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  InitInfo(self)
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function InitInfo(form)
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  form.mltbox_desc:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_stall_lifejob_desc")), nx_int(-1))
  if not player:FindRecord(JobRec) then
    form.groupbox_11.Visible = false
    form.groupbox_12.Visible = false
    return
  end
  local rows = player:GetRecordRows(JobRec)
  if rows == 0 then
    form.groupbox_11.Visible = false
    form.groupbox_12.Visible = false
    return
  end
  local is_zao = false
  local is_shi = false
  for nIndex = 0, rows - 1 do
    local job_id = player:QueryRecord(JobRec, nIndex, 0)
    local job_level = player:QueryRecord(JobRec, nIndex, 1)
    job_level = nx_widestr(job_level) .. nx_widestr(gui.TextManager:GetText("ui_guild_level"))
    for i, jobid in pairs(zao_table) do
      if nx_string(jobid) == nx_string(job_id) then
        local desc_info = "desc_info_" .. nx_string(job_id)
        gui.TextManager:Format_SetIDName(desc_info)
        gui.TextManager:Format_AddParam(job_level)
        form.mltbox_desc_1:AddHtmlText(nx_widestr(gui.TextManager:Format_GetText()), nx_int(-1))
        form.mltbox_desc_1.JobID = nx_string(job_id)
        is_zao = true
      end
    end
    if "sh_gs" == nx_string(job_id) then
      local desc_info = "desc_info_" .. nx_string(job_id)
      gui.TextManager:Format_SetIDName(desc_info)
      gui.TextManager:Format_AddParam(job_level)
      form.mltbox_desc_2:AddHtmlText(nx_widestr(gui.TextManager:Format_GetText()), nx_int(-1))
      form.mltbox_desc_2.JobID = nx_string(job_id)
      is_shi = true
    end
  end
  if not is_zao then
    form.groupbox_11.Visible = false
    form.groupbox_12.Left = 5
    form.groupbox_12.Top = 45
  end
  if not is_shi then
    form.groupbox_12.Visible = false
  end
end
function on_btn_xxset_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.mltbox_desc_1.JobID == "" then
    return
  end
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "open_life_form_by_sh_id", nx_string(form.mltbox_desc_1.JobID))
end
function on_btn_xxset_2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.mltbox_desc_2.JobID == "" then
    return
  end
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "open_life_form_by_sh_id", nx_string(form.mltbox_desc_2.JobID))
end
