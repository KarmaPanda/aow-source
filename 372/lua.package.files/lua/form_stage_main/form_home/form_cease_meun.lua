require("share\\client_custom_define")
require("util_functions")
local IFT_CUSHION = 0
local IFT_BATH = 1
local IFT_BED = 2
local IFT_LIGHT = 3
local IFT_BROOM = 4
local IFT_CHAIR = 5
local IFT_BANQUET = 6
local IFT_SHAREFURN_BED = 7
local IFT_SHAREFURN_BATH = 8
local IFT_SHAREFURN_COUCH = 9
local IFT_OUTDOOR_STOOL = 23
local IFT_OUTDOOR_TABLE = 24
local IFT_LIGHT_CHAIR = 25
local IFT_EXTAND_BEGIN = 26
local IFT_SHAREFURN_JIGUANREN = 27
local IFT_EXTAND_END = 50
local FURNITURE_DESC = {
  [IFT_CUSHION] = "ui_xljj_pt",
  [IFT_BATH] = "ui_xljj_yt",
  [IFT_BED] = "ui_xljj_bed",
  [IFT_CHAIR] = "ui_xljj_chair",
  [IFT_SHAREFURN_BED] = "ui_xljj_bed_1",
  [IFT_SHAREFURN_BATH] = "ui_xljj_yt_1",
  [IFT_SHAREFURN_COUCH] = "ui_xljj_bed_2",
  [IFT_OUTDOOR_STOOL] = "ui_xljj_outdoor_stool",
  [IFT_OUTDOOR_TABLE] = "ui_xljj_outdoor_table",
  [IFT_LIGHT_CHAIR] = "ui_xljj_chair",
  [IFT_EXTAND_BEGIN] = "ui_xljj_cyb",
  [IFT_SHAREFURN_JIGUANREN] = "ui_xljj_jgr"
}
function main_form_init(self)
  self.Fixed = false
  self.big_cooldown_id = 0
  self.cd_end_time = 0
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = self.Width
  self.AbsTop = self.Height / 4
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", self)
    timer:UnRegister(nx_current(), "on_update_cd_time", self)
    timer:UnRegister(nx_current(), "on_delay_show_form_time", self)
  end
  nx_destroy(self)
end
function on_btn_quit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), 5)
  end
end
function show_form(inter_type, limit_time, cd_life_time, total_time, big_cooldown_id)
  local form_cease_menu = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_cease_meun", true, false)
  if not nx_is_valid(form_cease_menu) then
    return
  end
  local cooldownbig = nx_value("CoolDownBig")
  if not nx_is_valid(cooldownbig) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.Desktop:ToFront(form_cease_menu)
  form_cease_menu.mltbox_award_desc:Clear()
  if FURNITURE_DESC[nx_number(inter_type)] ~= nil then
    local desc = util_text(FURNITURE_DESC[nx_number(inter_type)])
    form_cease_menu.mltbox_award_desc:AddHtmlText(nx_widestr(desc), -1)
  end
  local msgdelay = nx_value("MessageDelay")
  if not nx_is_valid(msgdelay) then
    return
  end
  local CurServerTime = msgdelay:GetServerNowTime()
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  if nx_number(limit_time) > 0 then
    form_cease_menu.timelimit = nx_number(limit_time)
    form_cease_menu.totaltime = nx_number(total_time)
  end
  if nx_number(cd_life_time) > 0 then
    local format_timer = get_format_time_text(nx_number(cd_life_time))
    form_cease_menu.lbl_cd_time.Text = nx_widestr(format_timer)
    form_cease_menu.cd_end_time = nx_number(CurServerTime) + nx_number(cd_life_time)
    form_cease_menu.pbar_1.Value = 100
  end
  form_cease_menu.big_cooldown_id = nx_number(big_cooldown_id)
  if 0 < form_cease_menu.big_cooldown_id then
    update_remain_count(form_cease_menu)
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    timer:UnRegister(nx_current(), "on_delay_show_form_time", form_cease_menu)
    timer:Register(2000, -1, nx_current(), "on_delay_show_form_time", form_cease_menu, -1, -1)
  else
    form_cease_menu:Show()
  end
  form_cease_menu.pbar_1.Visible = false
  if nx_find_custom(form_cease_menu, "timelimit") and 0 < nx_number(form_cease_menu.timelimit) then
    form_cease_menu.pbar_1.Visible = true
    timer:UnRegister(nx_current(), "on_update_time", form_cease_menu)
    timer:Register(1000, -1, nx_current(), "on_update_time", form_cease_menu, -1, -1)
  end
  if util_in_cd(form_cease_menu) then
    timer:UnRegister(nx_current(), "on_update_cd_time", form_cease_menu)
    timer:Register(1000, -1, nx_current(), "on_update_cd_time", form_cease_menu, -1, -1)
  end
  on_update_time(form_cease_menu)
  on_update_cd_time(form_cease_menu)
end
function update_remain_count(form)
  if form.big_cooldown_id <= 0 then
    return
  end
  local cooldownbig = nx_value("CoolDownBig")
  if not nx_is_valid(cooldownbig) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.mltbox_remain_count:Clear()
  local remain_count = cooldownbig:GetCoolDownBigLeftCount(form.big_cooldown_id)
  local desc = gui.TextManager:GetFormatText("sys_home_newcd", nx_int(remain_count))
  form.mltbox_remain_count:AddHtmlText(nx_widestr(desc), -1)
end
function util_in_cd(form)
  local msgdelay = nx_value("MessageDelay")
  if not nx_is_valid(msgdelay) then
    return false
  end
  if not nx_find_custom(form, "cd_end_time") then
    return false
  end
  local CurServerTime = msgdelay:GetServerNowTime()
  return nx_number(form.cd_end_time) > nx_number(CurServerTime)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_cease_meun", false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_update_time(form)
  if not nx_is_valid(form) then
    return
  end
  local msgdelay = nx_value("MessageDelay")
  if not nx_is_valid(msgdelay) then
    return
  end
  if not nx_find_custom(form, "timelimit") or not nx_find_custom(form, "totaltime") then
    return
  end
  local CurServerTime = msgdelay:GetServerNowTime()
  if nx_number(CurServerTime) >= nx_number(form.timelimit) then
    return
  end
  if util_in_cd(form) then
    form.pbar_1.Value = 100
    return
  end
  local livetime = nx_number(form.timelimit) - nx_number(CurServerTime)
  form.pbar_1.Value = nx_int((1 - livetime / form.totaltime) * 100)
  if form.pbar_1.Value >= 100 then
    update_remain_count(form)
  end
end
function on_update_cd_time(form)
  if not nx_is_valid(form) then
    return
  end
  local msgdelay = nx_value("MessageDelay")
  if not nx_is_valid(msgdelay) then
    return
  end
  local CurServerTime = msgdelay:GetServerNowTime()
  local life_time = nx_number(form.cd_end_time) - nx_number(CurServerTime)
  if nx_number(life_time) <= 0 then
    life_time = 0
  end
  local format_timer = get_format_time_text(life_time)
  form.lbl_cd_time.Text = nx_widestr(format_timer)
  if nx_number(life_time) <= 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_cd_time", form)
    end
  end
end
function on_delay_show_form_time(form)
  if not nx_is_valid(form) then
    return
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  if loading_flag or nx_string(stage_main_flag) ~= nx_string("success") then
    return
  end
  form:Show()
  local delay_timer = nx_value("timer_game")
  delay_timer:UnRegister(nx_current(), "on_delay_show_form_time", form)
end
function get_format_time_text(time)
  local format_time = ""
  time = nx_number(time / 1000)
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time)
end
