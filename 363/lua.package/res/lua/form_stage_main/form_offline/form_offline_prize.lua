require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("form_stage_main\\form_offline\\offline_define")
local PrizeLevel_White = 1
local PrizeLevel_Yellow = 2
local PrizeLevel_Green = 3
local PrizeLevel_Blue = 4
local PrizeLevel_Purple = 5
local PrizeID_OffLineJob = 1
local PrizeID_Live = 2
local PrizeID_OffLinePoint = 5
local PrizeID_OwnProp = 9
local PrizeID_Faculty = 10
local PrizeID_HoldFaculty = 11
local Max_prize_count = 5
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
function update_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form.Visible = false
end
function init_prize(date, offTime, prizeCnt, ...)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  while loading_flag or nx_string(stage_main_flag) ~= nx_string("success") do
    nx_pause(0.1)
    stage_main_flag = nx_value("stage_main")
    loading_flag = nx_value("loading")
  end
  show_prize(date, offTime, prizeCnt, unpack(arg))
end
function show_prize(date, offTime, prizeCnt, ...)
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_offline\\form_offline_prize", true)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_prize", true, false)
  if nx_is_valid(form) then
    form.Visible = false
    nx_destroy(form)
  end
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_offline\\form_offline_prize", true)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_prize", true, false)
  if not nx_is_valid(form) then
    return false
  end
  local offTimeDay = math.floor(offTime / 24)
  local offTimeHour = math.floor(offTime % 24)
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local playerName = player:QueryProp("Name")
  local offTimeInfo = util_format_string("ui_offdesc", offTimeDay, offTimeHour, playerName)
  offTimeInfo = nx_widestr(offTimeInfo)
  form.mltbox_offTime.HtmlText = offTimeInfo
  local offmgr = nx_value("OffLineJobManager")
  if not nx_is_valid(offmgr) then
    return false
  end
  form.groupscrollbox_prize.IsEditMode = true
  local prizeHeight = 67
  local prizeInterval = 6
  form.groupscrollbox_prize.curheight = 8
  for i = 1, prizeCnt do
    local prizeID = nx_int(arg[(i - 1) * 3 + 1])
    local prizeDesc = nx_string(offmgr:GetOffLinePrizeProp(prizeID, "PrizeDesc"))
    local PicPath = nx_string(offmgr:GetOffLinePrizeProp(prizeID, "PicPath"))
    local prizeLevel = nx_string(offmgr:GetOffLinePrizeProp(prizeID, "PrizeLevel"))
    local prizeColor = GetPrizeLevelColor(nx_int(prizeLevel))
    local gui = nx_value("gui")
    local groupBox = gui:Create("GroupBox")
    if not nx_is_valid(groupBox) then
      return false
    end
    form.groupscrollbox_prize:Add(groupBox)
    groupBox.Top = form.groupscrollbox_prize.curheight - 7
    groupBox.Left = form.groupscrollbox_prize.Left + 12
    groupBox.Width = form.groupscrollbox_prize.Width - 15
    groupBox.Height = prizeHeight + 4
    groupBox.BackColor = "0,0,0,0"
    groupBox.AutoSize = fales
    groupBox.BackImage = "gui\\language\\ChineseS\\offline\\bg_list4.png"
    groupBox.DrawMode = Expand
    groupBox.NoFrame = true
    local labelImage = gui:Create("Label")
    if not nx_is_valid(labelImage) then
      return false
    end
    groupBox:Add(labelImage)
    labelImage.Top = 1
    labelImage.Left = form.groupscrollbox_prize.Left
    labelImage.LineColor = "0,0,0,0"
    labelImage.BackorColor = "0,0,0,0"
    labelImage.LineColor = "0,0,0,0"
    labelImage.ShadowColor = "0,255,0,0"
    labelImage.AutoSize = true
    labelImage.DrawMode = Tile
    labelImage.NoFrame = true
    labelImage.BackImage = PicPath
    labelImage.BackColor = prizeColor
    local prizeItemCnt = nx_int(arg[(i - 1) * 3 + 2])
    if nx_int(prizeID) == nx_int(PrizeID_OffLineJob) then
      local offLineJobInfo = getOffLineJobInfo()
      local ding, liang, wen = nx_execute("form_stage_main\\form_mail\\form_mail_send", "trans_price", prizeItemCnt)
      prizeDesc = util_format_string(prizeDesc, ding, liang, wen)
      if not nx_ws_equal(nx_widestr(offLineJobInfo), nx_widestr("")) then
        prizeDesc = nx_widestr(offLineJobInfo) .. nx_widestr("<br>") .. nx_widestr(prizeDesc)
      end
    elseif nx_int(prizeID) == nx_int(PrizeID_OffLinePoint) then
      local ding, liang, wen = nx_execute("form_stage_main\\form_mail\\form_mail_send", "trans_price", prizeItemCnt)
      prizeDesc = util_format_string(prizeDesc, ding, liang, wen)
    elseif nx_int(prizeID) == nx_int(PrizeID_Live) then
      prizeItemCnt = math.floor(prizeItemCnt / 1000)
      prizeDesc = util_format_string(prizeDesc, prizeItemCnt)
    elseif nx_int(prizeID) == nx_int(PrizeID_OwnProp) then
      prizeDesc = util_text(prizeDesc)
    else
      prizeDesc = util_format_string(prizeDesc, prizeItemCnt)
    end
    prizeDesc = nx_widestr(prizeDesc)
    local mltbox_prizeInfo = gui:Create("MultiTextBox")
    if not nx_is_valid(mltbox_prizeInfo) then
      return false
    end
    groupBox:Add(mltbox_prizeInfo)
    mltbox_prizeInfo.Top = labelImage.Top + 14
    mltbox_prizeInfo.Left = labelImage.Left + labelImage.Width + 20
    mltbox_prizeInfo.Width = 320
    mltbox_prizeInfo.Height = prizeHeight - 20
    mltbox_prizeInfo.ViewRect = "5, 5," .. mltbox_prizeInfo.Width - 5 .. "," .. mltbox_prizeInfo.Height - 5
    mltbox_prizeInfo.TextColor = "255,128,101,74"
    mltbox_prizeInfo.LineColor = "0,0,0,0"
    mltbox_prizeInfo.BackColor = "0,0,0,0"
    mltbox_prizeInfo.ShadowColor = "0,255,0,0"
    mltbox_prizeInfo.Font = "font_main"
    mltbox_prizeInfo.SelectBarColor = "0,0,0,0"
    mltbox_prizeInfo.MouseInBarColor = "0,0,0,0"
    mltbox_prizeInfo.HtmlText = prizeDesc
    mltbox_prizeInfo.Solid = true
    local btn_receive = gui:Create("Button")
    if not nx_is_valid(btn_receive) then
      return false
    end
    groupBox:Add(btn_receive)
    btn_receive.NormalImage = "gui\\common\\button\\btn_normal2_out.png"
    btn_receive.FocusImage = "gui\\common\\button\\btn_normal2_on.png"
    btn_receive.PushImage = "gui\\common\\button\\btn_normal2_down.png"
    btn_receive.DrawMode = "ExpandH"
    btn_receive.Top = mltbox_prizeInfo.Top + 3
    btn_receive.Left = mltbox_prizeInfo.Left + mltbox_prizeInfo.Width
    btn_receive.Width = 62
    btn_receive.Height = 30
    btn_receive.ShadowColor = "0,255,0,0"
    btn_receive.Font = "font_main"
    btn_receive.ForeColor = "255,255,255,255"
    btn_receive.ShadowColor = "0,255,0,0"
    btn_receive.DisableColor = "255,0,0,0"
    btn_receive.Text = nx_widestr(util_text("ui_offline_form_get"))
    nx_bind_script(btn_receive, nx_current())
    nx_callback(btn_receive, "on_click", "on_btn_down")
    btn_receive.Enabled = true
    btn_receive.PrizeID = prizeID
    form.groupscrollbox_prize.curheight = form.groupscrollbox_prize.curheight + prizeHeight + prizeInterval
  end
  form.groupscrollbox_prize.IsEditMode = false
  form.groupscrollbox_prize.HasVScroll = true
  form.groupscrollbox_prize.VScrollBar.Value = 0
end
function on_btn_down(btn)
  btn.Enabled = false
  btn.Text = nx_widestr(util_text("ui_yilingqu"))
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_OFFLINE_PRIZE), nx_int(btn.PrizeID))
end
function GetPrizeLevelColor(prizeLevel)
  local color
  if prizeLevel == nx_int(PrizeLevel_White) then
    color = "255, 255, 255, 255"
  elseif prizeLevel == nx_int(PrizeLevel_Yellow) then
    color = "255, 255, 255, 0"
  elseif prizeLevel == nx_int(PrizeLevel_Green) then
    color = "255, 0, 255, 0"
  elseif prizeLevel == nx_int(PrizeLevel_Blue) then
    color = "255, 0, 0, 255"
  elseif prizeLevel == nx_int(PrizeLevel_Purple) then
    color = "255, 255, 0, 255"
  else
    color = "255, 255, 255, 255"
  end
  return color
end
function getOffLineJobInfo()
  local gui = nx_value("gui")
  local offmgr = nx_value("OffLineJobManager")
  if not nx_is_valid(offmgr) then
    return nx_widestr("")
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nx_widestr("")
  end
  if not client_player:FindRecord("OffLineJob_Log") then
    return nx_widestr("")
  end
  local row_count = client_player:GetRecordRows("OffLineJob_Log")
  if nx_number(row_count) == nx_number(0) then
    return nx_widestr("")
  end
  local off_id = client_player:QueryRecord("OffLineJob_Log", row_count - 1, REC_LOG_ID)
  local off_date = client_player:QueryRecord("OffLineJob_Log", row_count - 1, REC_LOG_DATE_END)
  local area = offmgr:GetOffLineJobProp(off_id, "WorkArea")
  local str_date = nx_function("format_date_time", nx_double(off_date))
  local table_dt = util_split_string(str_date, ";")
  if table.getn(table_dt) ~= 2 then
    return nx_widestr("")
  end
  local format_date = nx_execute("form_stage_main\\form_offline\\sub_form_offline_daily", "format_date_text", table_dt[1])
  return nx_widestr(format_date) .. nx_widestr(" ") .. nx_widestr(util_text(area)) .. nx_widestr(" ") .. nx_widestr(util_text(off_id))
end
