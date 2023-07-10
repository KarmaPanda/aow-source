require("util_functions")
require("util_gui")
require("custom_sender")
local FORM_MAIN_NAME = "form_stage_main\\form_dream_land\\form_dream_land"
local image_path = "gui\\special\\dream_land\\"
local postfix_name = ".png"
local STC_MSG_SUB_SHOW_CHAPTER = 0
local STC_MSG_SUB_CHAPTER_INFO = 1
local STC_MSG_SUB_OVER_COOL_TIME = 2
local STC_MSG_SUB_ACTIVATE_LAND = 3
local CTS_MSG_SUB_REQUEST_CHAPTER = 0
local CTS_MSG_SUB_ACTIVATE = 1
local CTS_MSG_SUB_ENTRY = 2
local CTS_MSG_SUB_EXIT = 3
local DREAMLAND_STATUS_LOCK = 0
local DREAMLAND_STATUS_UNLOCK = 1
local DREAMLAND_STATUS_ACTIVATE = 2
function main_form_init(self)
  self.Fixed = false
  self.refresh_time = -1
  self.refresh_reward = false
  self.cool_time = 0
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.rbtn_1.Checked = true
end
function open_form()
  util_auto_show_hide_form(FORM_MAIN_NAME)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function close_form()
  local form = util_get_form(FORM_MAIN_NAME, true)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_1_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  send_server_msg(nx_int(CTS_MSG_SUB_REQUEST_CHAPTER), nx_int(rbtn.DataSource))
  form.ChapterIndex = rbtn.DataSource
end
function on_rbtn_dream_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local btn_status = 0
  if nx_find_custom(rbtn, "DramaStatus") then
    btn_status = rbtn.DramaStatus
  end
  local chapter_index = 0
  if nx_find_custom(form, "ChapterIndex") then
    chapter_index = form.ChapterIndex
  end
  form.btn_entry.DataSource = 0
  if btn_status == DREAMLAND_STATUS_UNLOCK then
    send_server_msg(nx_int(CTS_MSG_SUB_ACTIVATE), nx_int(chapter_index), nx_int(rbtn.DataSource))
  elseif btn_status == DREAMLAND_STATUS_ACTIVATE then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    form.lbl_2.Text = nx_widestr(gui.TextManager:GetText("ui_dreamland_storytitle_" .. nx_string(chapter_index) .. "_" .. nx_string(rbtn.DataSource)))
    form.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetText("ui_dreamland_storytext_" .. nx_string(chapter_index) .. "_" .. nx_string(rbtn.DataSource)))
    form.btn_entry.DataSource = rbtn.DataSource
    local branch_value = 0
    if nx_find_custom(rbtn, "BranchValue") then
      branch_value = rbtn.BranchValue
    end
    RefreshBranchInfo(form, branch_value, chapter_index, rbtn.DataSource)
  end
end
function on_btn_entry_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local chapter_index = 0
  if nx_find_custom(form, "ChapterIndex") then
    chapter_index = form.ChapterIndex
  end
  if 0 < form.cool_time then
    return
  end
  send_server_msg(nx_int(CTS_MSG_SUB_ENTRY), nx_int(chapter_index), nx_int(btn.DataSource))
end
function on_server_msg(sub_msg, ...)
  if sub_msg == STC_MSG_SUB_SHOW_CHAPTER then
    open_form()
  elseif sub_msg == STC_MSG_SUB_CHAPTER_INFO then
    show_chapter_info(unpack(arg))
  elseif sub_msg == STC_MSG_SUB_OVER_COOL_TIME then
    RefreshCoolTime(unpack(arg))
  elseif sub_msg == STC_MSG_SUB_ACTIVATE_LAND then
    Activate_drama_info(unpack(arg))
  end
end
function send_server_msg(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_DREAM_LAND), unpack(arg))
end
function show_chapter_info(...)
  local form = nx_value(FORM_MAIN_NAME)
  if not nx_is_valid(form) then
    return
  end
  local chapter_count = table.getn(arg) / 3
  for i = 1, chapter_count do
    local btn = nx_custom(form, "rbtn_dream_" .. nx_string(i))
    if nx_is_valid(btn) then
      local drama_index = arg[(i - 1) * 3 + 1]
      local branch_value = arg[(i - 1) * 3 + 2]
      local drama_status = arg[(i - 1) * 3 + 3]
      btn.DataSource = nx_string(drama_index)
      btn.DramaStatus = drama_status
      btn.BranchValue = branch_value
      if drama_status == DREAMLAND_STATUS_LOCK then
        local lock_image = image_path .. "lock" .. postfix_name
        btn.BackImage = lock_image
        btn.Enabled = false
      elseif drama_status == DREAMLAND_STATUS_UNLOCK then
        local open_image = image_path .. "open" .. postfix_name
        btn.BackImage = open_image
        btn.Enabled = true
        local ani = nx_custom(form, "ani_" .. nx_string(i))
        if nx_is_valid(ani) then
          ani.AnimationImage = "dream_land_canopen"
          ani.AutoSize = true
          ani.Loop = true
          ani:Play()
        end
      elseif drama_status == DREAMLAND_STATUS_ACTIVATE then
        local out_image = image_path .. "part" .. nx_string(i) .. "_out" .. postfix_name
        local on_image = image_path .. "part" .. nx_string(i) .. "_on" .. postfix_name
        local down_image = image_path .. "part" .. nx_string(i) .. "_down" .. postfix_name
        btn.BackImage = out_image
        btn.FocusImage = on_image
        btn.PushImage = down_image
        btn.CheckedImage = down_image
      end
      if i == 1 then
        btn.Checked = true
      end
    end
  end
end
function RefreshBranchInfo(form, branch_value, chapter_index, drama_index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local MAX_BIT = 6
  local bit_array = get_bit_value(branch_value, 32)
  local gui = nx_value("gui")
  for i = 1, MAX_BIT do
    local lbl_bi = nx_custom(form, "lbl_bi_" .. nx_string(i))
    if nx_is_valid(lbl_bi) then
      local back_image = image_path
      if nx_number(bit_array[i]) == 1 then
        back_image = back_image .. "jieju" .. nx_string(i) .. "_on" .. postfix_name
        lbl_bi.BackImage = back_image
      else
        back_image = back_image .. "jieju" .. nx_string(chapter_index) .. "_" .. nx_string(drama_index) .. "_" .. nx_string(i) .. "_down" .. postfix_name
        lbl_bi.BackImage = back_image
      end
    end
    local lbl_bt = nx_custom(form, "lbl_bt_" .. nx_string(i))
    if nx_is_valid(lbl_bt) then
      lbl_bt.Text = nx_widestr(gui.TextManager:GetText("ui_dreamland_storyending_" .. nx_string(chapter_index) .. "_" .. nx_string(drama_index) .. "_" .. nx_string(i)))
    end
  end
end
function get_bit_value(data, bit_count)
  local result = {}
  for i = 1, nx_number(bit_count) do
    table.insert(result, 0)
  end
  local tmpdata = nx_int64(data)
  for i = nx_number(bit_count) - 1, 0, -1 do
    if nx_number(tmpdata) <= nx_number(0) then
      return result
    end
    local tmp = math.floor(tmpdata / math.pow(2, i))
    if nx_number(tmp) == 1 then
      result[i + 1] = nx_number(tmp)
      tmpdata = tmpdata - math.pow(2, i)
    end
  end
  return result
end
function RefreshCoolTime(cool_time)
  local form = util_get_form(FORM_MAIN_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local over_cool_time = nx_int((cool_time - cur_date_time) * 86400)
  if nx_int(over_cool_time) <= nx_int(0) then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_time", form)
    end
    return
  end
  form.cool_time = over_cool_time
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "on_timer", form, -1, -1)
  end
end
function on_timer(form)
  if not nx_is_valid(form) then
    return
  end
  form.cool_time = form.cool_time - 1
  form.time_box:Clear()
  local cool_time = form.cool_time
  if cool_time < 0 then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_time", form)
    end
    return
  end
  local hour = math.floor(nx_number(cool_time) / nx_number(3600))
  local minute = math.floor((nx_number(cool_time) - nx_number(hour) * 3600) / nx_number(60))
  local second = nx_number(cool_time) - nx_number(hour) * 3600 - nx_number(minute) * 60
  local str_hour = ""
  if nx_int(hour) > nx_int(10) then
    str_hour = nx_string(hour)
  else
    str_hour = "0" .. nx_string(hour)
  end
  local str_min = ""
  if nx_int(minute) >= nx_int(10) then
    str_min = nx_string(minute)
  else
    str_min = "0" .. nx_string(minute)
  end
  local str_sec = ""
  if nx_int(second) >= nx_int(10) then
    str_sec = nx_string(second)
  else
    str_sec = "0" .. nx_string(second)
  end
  local str = str_hour .. ":" .. str_min .. ":" .. str_sec
  form.time_box:AddHtmlText(nx_widestr(str), -1)
end
function Activate_drama_info(ChapterIndex, DramaIndex)
  local form = util_get_form(FORM_MAIN_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local chapter_index = 0
  if nx_find_custom(form, "ChapterIndex") then
    chapter_index = form.ChapterIndex
  end
  if nx_int(ChapterIndex) ~= nx_int(chapter_index) then
    return
  end
  local ani = nx_custom(form, "ani_" .. nx_string(DramaIndex))
  if nx_is_valid(ani) then
    ani.AnimationImage = "dream_land_open"
    ani.AutoSize = true
    ani.Loop = false
    nx_callback(ani, "on_animation_end", "animation_end")
    ani.DramaIndex = DramaIndex
    ani:Play()
  end
end
function animation_end(self)
  if not nx_is_valid(self) then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local drama_index = 0
  if nx_find_custom(self, "DramaIndex") then
    drama_index = self.DramaIndex
  end
  self.AnimationImage = ""
  self.DramaIndex = 0
  if 0 == drama_index then
    return
  end
  local btn = nx_custom(form, "rbtn_dream_" .. nx_string(drama_index))
  if nx_is_valid(btn) then
    local out_image = image_path .. "part" .. nx_string(drama_index) .. "_out" .. postfix_name
    local on_image = image_path .. "part" .. nx_string(drama_index) .. "_on" .. postfix_name
    local down_image = image_path .. "part" .. nx_string(drama_index) .. "_down" .. postfix_name
    btn.BackImage = out_image
    btn.FocusImage = on_image
    btn.PushImage = down_image
    btn.CheckedImage = down_image
    btn.DramaStatus = DREAMLAND_STATUS_ACTIVATE
    btn.Checked = true
    on_rbtn_dream_checked_changed(btn)
  end
end
function request_quit_dream_land()
  send_server_msg(nx_int(CTS_MSG_SUB_EXIT))
end
