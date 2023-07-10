require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("form_stage_main\\form_offline\\offline_define")
require("util_vip")
local ImagePath = "gui\\special\\freshman\\offline\\"
local FORM_CHARACTER = "form_stage_main\\form_sweet_employ\\form_offline_character"
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  form.Visible = true
  form.btn_training.Visible = false
  if is_1st_day() then
    form.btn_daily.Visible = false
  else
    form.btn_daily.Visible = true
  end
  enbale_offline_prize_btn(form)
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_quit_click(btn)
  nx_execute("main", "confirm_exit_game")
end
function show_window(date)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\sub_form_offline", true, false)
  if init_form(form, date) then
    return true
  end
  return false
end
function on_btn_get_prize_click(btn)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_GET_DAILY_PRIZE))
  end
end
function init_form(form, date, show_type, job_id1, job_id2, job_id3, job_id4, job_id5, idCnt, nSceneID, jobSuff, isNewRole, stage)
  show_ctrl(form, isNewRole)
  if nx_int(isNewRole) > nx_int(0) then
    update_newRole_prize_ctrl(form, nx_int(stage))
  end
  local gui = nx_value("gui")
  local form_offline = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline", true, false)
  form.form_offline = form_offline
  local offmgr = nx_value("OffLineJobManager")
  if not nx_is_valid(offmgr) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  date = date + 1
  local isAbducted = 0
  local abductedjobID
  if client_player:FindProp("IsAbducted") then
    isAbducted = client_player:QueryProp("IsAbducted")
  end
  if nx_number(isAbducted) > nx_number(0) then
    if not client_player:FindRecord("OffLineJob_Log") then
      return false
    end
    local log_row = get_job_row(date)
    if 0 > nx_number(log_row) then
      return false
    end
    abductedjobID = client_player:QueryRecord("OffLineJob_Log", log_row, REC_LOG_NEW_JOB_ID)
    if nx_int(string.len(abductedjobID)) ~= nx_int(10) then
      abductedjobID = client_player:QueryRecord("OffLineJob_Log", log_row, REC_LOG_ID)
    end
    if nx_int(string.len(abductedjobID)) ~= nx_int(10) then
      return false
    end
  end
  local strSceneName = offmgr:GetOffLineJobSProp(nSceneID, job_id1, "SceneName")
  local strSceneDesc = offmgr:GetOffLineJobSProp(nSceneID, job_id1, "SceneDesc")
  local jobInfo
  if nx_number(isAbducted) > nx_number(0) then
    isAbducted = true
    jobInfo = util_text("ui_offline_form_zhinengchengwei")
  else
    isAbducted = false
    jobInfo = util_text("ui_offline_form_kenengchengwei")
  end
  if isAbducted then
    idCnt = 1
    strSceneName = offmgr:GetOffLineJobSPropViaJobID(abductedjobID, "SceneName")
    strSceneDesc = offmgr:GetOffLineJobSPropViaJobID(abductedjobID, "SceneDesc")
  end
  strInfo = nx_widestr("<font face=\"font_text_title1\" color=\"#766144\" size=\"20\">") .. nx_widestr(util_text(strSceneName)) .. nx_widestr("</font>") .. nx_widestr(util_text(strSceneDesc))
  form.mltbox_Scene:Clear()
  form.mltbox_Scene:AddHtmlText(strInfo, -1)
  form.lbl_job1.Top = form.lbl_jobInfo.Top + form.lbl_jobInfo.Height
  form.lbl_job1.Left = (form.Width - form.lbl_job1.Width * idCnt) / 2
  form.lbl_job2.Width = form.lbl_job1.Width
  form.lbl_job3.Width = form.lbl_job2.Width
  form.lbl_job4.Width = form.lbl_job3.Width
  form.lbl_job5.Width = form.lbl_job4.Width
  form.lbl_job2.Height = form.lbl_job1.Height
  form.lbl_job3.Height = form.lbl_job2.Height
  form.lbl_job4.Height = form.lbl_job3.Height
  form.lbl_job5.Height = form.lbl_job4.Height
  form.lbl_job2.Top = form.lbl_job1.Top
  form.lbl_job3.Top = form.lbl_job2.Top
  form.lbl_job4.Top = form.lbl_job3.Top
  form.lbl_job5.Top = form.lbl_job4.Top
  form.lbl_job2.Left = form.lbl_job1.Left + form.lbl_job1.Width
  form.lbl_job3.Left = form.lbl_job2.Left + form.lbl_job2.Width
  form.lbl_job4.Left = form.lbl_job3.Left + form.lbl_job3.Width
  form.lbl_job5.Left = form.lbl_job4.Left + form.lbl_job4.Width
  form.mltbox_job_desc1.Top = form.lbl_job1.Top + form.lbl_job1.Height
  form.mltbox_job_desc1.Left = form.lbl_job1.Left
  form.mltbox_job_desc2.Width = form.mltbox_job_desc1.Width
  form.mltbox_job_desc3.Width = form.mltbox_job_desc2.Width
  form.mltbox_job_desc4.Width = form.mltbox_job_desc3.Width
  form.mltbox_job_desc5.Width = form.mltbox_job_desc4.Width
  form.mltbox_job_desc2.Height = form.mltbox_job_desc1.Height
  form.mltbox_job_desc3.Height = form.mltbox_job_desc2.Height
  form.mltbox_job_desc4.Height = form.mltbox_job_desc3.Height
  form.mltbox_job_desc5.Height = form.mltbox_job_desc4.Height
  form.mltbox_job_desc2.Top = form.mltbox_job_desc1.Top
  form.mltbox_job_desc3.Top = form.mltbox_job_desc2.Top
  form.mltbox_job_desc4.Top = form.mltbox_job_desc3.Top
  form.mltbox_job_desc5.Top = form.mltbox_job_desc4.Top
  form.mltbox_job_desc2.Left = form.lbl_job2.Left
  form.mltbox_job_desc3.Left = form.lbl_job3.Left
  form.mltbox_job_desc4.Left = form.lbl_job4.Left
  form.mltbox_job_desc5.Left = form.lbl_job5.Left
  form.lbl_line2.Top = form.mltbox_job_desc1.Top + form.mltbox_job_desc1.Height
  if nx_number(idCnt) == nx_number(4) then
    form.lbl_job5.Visible = false
    form.mltbox_job_desc5.Visible = false
  end
  if nx_number(idCnt) == nx_number(3) then
    form.lbl_job5.Visible = false
    form.lbl_job4.Visible = false
    form.mltbox_job_desc5.Visible = false
    form.mltbox_job_desc4.Visible = false
  end
  if nx_number(idCnt) == nx_number(2) then
    form.lbl_job5.Visible = false
    form.lbl_job4.Visible = false
    form.lbl_job3.Visible = false
    form.mltbox_job_desc5.Visible = false
    form.mltbox_job_desc4.Visible = false
    form.mltbox_job_desc3.Visible = false
  end
  if nx_number(idCnt) == nx_number(1) then
    form.lbl_job5.Visible = false
    form.lbl_job4.Visible = false
    form.lbl_job3.Visible = false
    form.lbl_job2.Visible = false
    form.mltbox_job_desc5.Visible = false
    form.mltbox_job_desc4.Visible = false
    form.mltbox_job_desc3.Visible = false
    form.mltbox_job_desc2.Visible = false
  end
  form.btn_ransom.Visible = isAbducted
  form.lbl_jobInfo.Text = nx_widestr(jobInfo)
  if isAbducted then
    local strPicPath = offmgr:GetOffLineJobSPropViaJobID(abductedjobID, "PicPathAbducted")
    local strJobDesc = offmgr:GetOffLineJobSPropViaJobID(abductedjobID, "JobDesc")
    local strJobName = offmgr:GetOffLineJobSPropViaJobID(abductedjobID, "JobName")
    strJobInfo = nx_widestr("<font color=\"#ff0000\" size=\"20\">") .. nx_widestr(util_text(strJobName)) .. nx_widestr("</font>") .. nx_widestr(util_text(strJobDesc))
    form.lbl_job1.BackImage = nx_string(strPicPath)
    form.mltbox_job_desc1:Clear()
    form.mltbox_job_desc1:AddHtmlText(strJobInfo, -1)
  else
    if nx_number(job_id1) > nx_number(0) then
      local strPicPath = offmgr:GetOffLineJobSProp(nSceneID, job_id1, "PicPathNormal")
      local strJobDesc = offmgr:GetOffLineJobSProp(nSceneID, job_id1, "JobDesc")
      local strJobName = offmgr:GetOffLineJobSProp(nSceneID, job_id1, "JobName")
      strJobInfo = nx_widestr("<font color=\"#ff0000\" size=\"20\">") .. nx_widestr(util_text(strJobName)) .. nx_widestr("</font>") .. nx_widestr(util_text(strJobDesc))
      form.lbl_job1.BackImage = nx_string(strPicPath)
      form.mltbox_job_desc1:Clear()
      form.mltbox_job_desc1:AddHtmlText(strJobInfo, -1)
    end
    if nx_number(job_id2) > nx_number(0) then
      local strPicPath = offmgr:GetOffLineJobSProp(nSceneID, job_id2, "PicPathNormal")
      local strJobDesc = offmgr:GetOffLineJobSProp(nSceneID, job_id2, "JobDesc")
      local strJobName = offmgr:GetOffLineJobSProp(nSceneID, job_id2, "JobName")
      strJobInfo = nx_widestr("<font color=\"#ff0000\" size=\"20\">") .. nx_widestr(util_text(strJobName)) .. nx_widestr("</font>") .. nx_widestr(util_text(strJobDesc))
      form.lbl_job2.BackImage = nx_string(strPicPath)
      form.mltbox_job_desc2:Clear()
      form.mltbox_job_desc2:AddHtmlText(strJobInfo, -1)
    end
    if nx_number(job_id3) > nx_number(0) then
      local strPicPath = offmgr:GetOffLineJobSProp(nSceneID, job_id3, "PicPathNormal")
      local strJobDesc = offmgr:GetOffLineJobSProp(nSceneID, job_id3, "JobDesc")
      local strJobName = offmgr:GetOffLineJobSProp(nSceneID, job_id3, "JobName")
      strJobInfo = nx_widestr("<font color=\"#ff0000\" size=\"20\">") .. nx_widestr(util_text(strJobName)) .. nx_widestr("</font>") .. nx_widestr(util_text(strJobDesc))
      form.lbl_job3.BackImage = nx_string(strPicPath)
      form.mltbox_job_desc3:Clear()
      form.mltbox_job_desc3:AddHtmlText(strJobInfo, -1)
    end
    if nx_number(job_id4) > nx_number(0) then
      local strPicPath = offmgr:GetOffLineJobSProp(nSceneID, job_id4, "PicPathNormal")
      local strJobDesc = offmgr:GetOffLineJobSProp(nSceneID, job_id4, "JobDesc")
      local strJobName = offmgr:GetOffLineJobSProp(nSceneID, job_id4, "JobName")
      strJobInfo = nx_widestr("<font color=\"#ff0000\" size=\"20\">") .. nx_widestr(util_text(strJobName)) .. nx_widestr("</font>") .. nx_widestr(util_text(strJobDesc))
      form.lbl_job4.BackImage = nx_string(strPicPath)
      form.mltbox_job_desc4:Clear()
      form.mltbox_job_desc4:AddHtmlText(strJobInfo, -1)
    end
    if nx_number(job_id5) > nx_number(0) then
      local strPicPath = offmgr:GetOffLineJobSProp(nSceneID, job_id5, "PicPathNormal")
      local strJobDesc = offmgr:GetOffLineJobSProp(nSceneID, job_id5, "JobDesc")
      local strJobName = offmgr:GetOffLineJobSProp(nSceneID, job_id5, "JobName")
      strJobInfo = nx_widestr("<font color=\"#ff0000\" size=\"20\">") .. nx_widestr(util_text(strJobName)) .. nx_widestr("</font>") .. nx_widestr(util_text(strJobDesc))
      form.lbl_job5.BackImage = nx_string(strPicPath)
      form.mltbox_job_desc5:Clear()
      form.mltbox_job_desc5:AddHtmlText(strJobInfo, -1)
    end
  end
  local strJobSuff = ""
  if nx_number(jobSuff) > nx_number(0) then
    strJobSuff = nx_widestr("<font color=\"#008B00\" size=\"20\">") .. nx_widestr(util_text("Desc_Offline_Job_01")) .. nx_widestr("</font>")
  else
    strJobSuff = nx_widestr("<font color=\"#ff0000\" size=\"20\">") .. nx_widestr(util_text("Desc_Offline_Job_02")) .. nx_widestr("</font>")
  end
  form.mltbox_jobSuff:Clear()
  form.mltbox_jobSuff:AddHtmlText(strJobSuff, -1)
  return true
end
function get_job_row(date)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  if not client_player:FindRecord("OffLineJob_Log") then
    return -1
  end
  local rows = client_player:GetRecordRows("OffLineJob_Log")
  if 0 < rows then
    for i = 0, rows - 1 do
      local begin_date = client_player:QueryRecord("OffLineJob_Log", i, REC_LOG_DATE_START)
      local end_date = client_player:QueryRecord("OffLineJob_Log", i, REC_LOG_DATE_END)
      if nx_number(date) >= nx_number(begin_date) and nx_number(date) <= nx_number(end_date) then
        return i
      end
    end
  end
  if nx_number(rows) == nx_number(1) then
    return 0
  end
  return -1
end
function on_btn_wuxue_click(self)
  local ret = nx_execute("form_stage_main\\form_small_game\\form_game_songjing", "is_in_minigame_song_jing")
  if ret then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local vip_status = nx_execute("util_vip", "is_vip", client_player, VT_NORMAL)
  if not vip_status then
    local form_prompt = nx_value("form_stage_main\\form_vip_prompt")
    if nx_is_valid(form_prompt) then
      form_prompt:Close()
    end
    form_prompt = util_show_form("form_stage_main\\form_vip_prompt", true)
    form_prompt.info_mltbox.HtmlText = gui.TextManager:GetText("ui_jhhy_8")
    return
  end
  util_auto_show_hide_form("form_stage_main\\form_wuxue\\form_wuxue_faculty")
end
function is_1st_day()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindRecord("OffLineJob_Log") then
    return false
  end
  local rows = client_player:GetRecordRows("OffLineJob_Log")
  if rows == 1 then
    local begin_date = client_player:QueryRecord("OffLineJob_Log", 0, REC_LOG_DATE_START)
    local end_date = client_player:QueryRecord("OffLineJob_Log", 0, REC_LOG_DATE_END)
    if nx_number(begin_date) == nx_number(end_date) then
      return true
    end
  end
  return false
end
function on_btn_log_click(btn)
  local ret = nx_execute("form_stage_main\\form_small_game\\form_game_songjing", "is_in_minigame_song_jing")
  if ret then
    return
  end
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_offline\\form_offline", "show_log", form.form_offline)
end
function on_btn_daily_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_offline\\form_offline", "show_daily", form.form_offline)
end
function on_btn_training_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_offline\\form_offline", "show_training", form.form_offline)
end
function on_btn_stall_click(btn)
  local ret = nx_execute("form_stage_main\\form_small_game\\form_game_songjing", "is_in_minigame_song_jing")
  if ret then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local vip_status = nx_execute("util_vip", "is_vip", client_player, VT_NORMAL)
  if not vip_status then
    local form_prompt = nx_value("form_stage_main\\form_vip_prompt")
    if nx_is_valid(form_prompt) then
      form_prompt:Close()
    end
    form_prompt = util_show_form("form_stage_main\\form_vip_prompt", true)
    form_prompt.info_mltbox.HtmlText = gui.TextManager:GetText("ui_jhhy_4")
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_main", true, false)
  dialog.IsOnline = false
  dialog:Show()
  local form_offline = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline", true, false)
  nx_execute("form_stage_main\\form_offline\\form_offline", "on_btn_close_click", form_offline.btn_close)
end
function on_btn_exit_click(btn)
  nx_execute("main", "wait_exit_game")
end
function on_btn_ransom_click(btn)
  local ret = nx_execute("form_stage_main\\form_small_game\\form_game_songjing", "is_in_minigame_song_jing")
  if ret then
    return
  end
  local sub_form_offline_log = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\sub_form_offline_log", true, false)
  nx_execute("form_stage_main\\form_offline\\sub_form_offline_log", "on_btn_setfree_click", sub_form_offline_log.btn_setfree)
end
function on_btn_prize_click(btn)
  local ret = nx_execute("form_stage_main\\form_small_game\\form_game_songjing", "is_in_minigame_song_jing")
  if ret then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_prize", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
end
function enbale_offline_prize_btn(form)
  local fromOffPrize = nx_value("form_stage_main\\form_offline\\form_offline_prize")
  if nx_is_valid(fromOffPrize) then
    form.btn_prize.Enabled = true
  else
    form.btn_prize.Enabled = false
  end
end
function show_ctrl(form, showPrize)
  if nx_int(showPrize) > nx_int(0) then
    show_jobInfo_ctrl(form, 0)
    show_newRole_prize_ctrl(form, 1)
  else
    show_jobInfo_ctrl(form, 1)
    show_newRole_prize_ctrl(form, 0)
  end
end
function show_jobInfo_ctrl(form, showFlag)
  if nx_int(showFlag) > nx_int(0) then
    form.groupbox_job.Visible = true
  else
    form.groupbox_job.Visible = false
  end
end
function show_newRole_prize_ctrl(form, showFlag)
  if nx_int(showFlag) > nx_int(0) then
    form.groupbox_prize.Visible = true
  else
    form.groupbox_prize.Visible = false
  end
end
function update_newRole_prize_ctrl(form, stage)
  for i = 0, stage - 1 do
    local lbl_name = "lbl_prize" .. nx_string(i + 1)
    local lbl = nx_custom(form, lbl_name)
    if nx_is_valid(lbl) then
      lbl.BackImage = ImagePath .. nx_string(i + 1) .. "2.png"
    end
  end
end
function on_lbl_prize_get_capture(lbl)
  local offmgr = nx_value("OffLineJobManager")
  if not nx_is_valid(offmgr) then
    return
  end
  local index = lbl.DataSource
  if nx_int(index) <= nx_int(0) then
    return
  end
  local table_prize = offmgr:GetNewRolePrize(nx_int(index))
  local nCnt = table.getn(table_prize)
  if nx_int(nCnt % 2) ~= nx_int(0) then
    return
  end
  local tips_text = nx_widestr("")
  for i = 1, nCnt, 2 do
    local itemID = table_prize[i]
    local Cnt = table_prize[i + 1]
    tips_text = tips_text .. util_format_string("tips_newRolePrize", itemID, Cnt)
  end
  nx_execute("tips_game", "show_text_tip", tips_text, lbl.AbsLeft, lbl.AbsTop)
end
function on_lbl_prize_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function on_btn_char_click(btn)
  local ret = nx_execute("form_stage_main\\form_small_game\\form_game_songjing", "is_in_minigame_song_jing")
  if ret then
    return
  end
  local form_character = util_get_form(FORM_CHARACTER, true, false)
  if not nx_is_valid(form_character) then
    return
  end
  util_show_form(FORM_CHARACTER, true)
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form_character)
end
