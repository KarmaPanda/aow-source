require("util_functions")
require("util_gui")
require("form_stage_main\\form_tiguan\\form_tiguan_util")
function main_form_init(form)
  form.Fixed = false
  form.time = 0
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_trace", form)
  end
  nx_destroy(form)
end
function on_btn_fast_invite_click(self)
  local form = self.ParentForm
  local now = os.time()
  if now - form.time < 5 then
    return
  end
  form.time = now
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_INVITE_ALLY)
end
function show_ds_trace(type, guan_id, use_time, best_score, best_time, invite_num)
  local form = util_get_form(nx_current(), true)
  if not nx_is_valid(form) then
    return
  end
  form.guan_id = guan_id
  form.use_time = use_time + 1
  form.best_score = best_score
  form.best_time = best_time
  form.invite_num = invite_num
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_trace", form)
    timer:Register(1000, -1, nx_current(), "on_update_trace", form, -1, -1)
  end
  if form.best_time == 0 then
    form.lbl_best_use_time.Text = nx_widestr("--:--")
  else
    form.lbl_best_use_time.Text = nx_widestr(get_time_str(form.best_time))
  end
  form.mltbox_invite_num:Clear()
  form.mltbox_invite_num:AddHtmlText(util_format_string("ui_mengyou_times", invite_num), -1)
  if JION_TIGUAN_BEGIN == type then
    util_show_form(nx_current(), true)
  end
end
function on_update_trace(form)
  form.use_time = form.use_time + 1
  form.lbl_now_use_time.Text = nx_widestr(get_time_str(form.use_time))
end
function get_time_str(times)
  local szTime = ""
  local minute = nx_number(nx_int(times / 60))
  if minute < 10 then
    szTime = szTime .. "0" .. nx_string(minute)
  else
    szTime = szTime .. nx_string(minute)
  end
  szTime = szTime .. ":"
  local second = times - minute * 60
  if second < 10 then
    szTime = szTime .. "0" .. nx_string(second)
  else
    szTime = szTime .. nx_string(second)
  end
  return szTime
end
function close_form()
  local form = util_get_form(nx_current(), false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_ds_trace()
  local form = util_get_form(nx_current(), false)
  if nx_is_valid(form) then
    form.Visible = true
    form:Show()
  end
end
function invite_ally_suc(...)
  local form = util_get_form(nx_current(), false)
  if nx_is_valid(form) then
    form.btn_fast_invite.Enabled = false
    form.lbl_flicker.Visible = false
  end
end
function updata_remain_invite(invite_num)
  local form = util_get_form(nx_current(), false)
  if nx_is_valid(form) then
    form.invite_num = invite_num
    form.mltbox_invite_num:Clear()
    form.mltbox_invite_num:AddHtmlText(util_format_string("ui_mengyou_times", invite_num), -1)
  end
end
