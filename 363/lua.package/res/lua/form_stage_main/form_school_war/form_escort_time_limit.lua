require("util_functions")
require("share\\client_custom_define")
require("util_gui")
function main_form_init(form)
  form.Fixed = false
  form.ServerTime = 0
  return 1
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  form.ServerTime = 0
  nx_destroy(form)
end
function ShowEscortTimeLimit(timelimit, goodsnum, tolgoodsnum)
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  while loading_flag or nx_string(stage_main_flag) ~= nx_string("success") do
    nx_pause(0.1)
    stage_main_flag = nx_value("stage_main")
    loading_flag = nx_value("loading")
  end
  local form = util_get_form("form_stage_main\\form_school_war\\form_escort_time_limit", true)
  form.ServerTime = timelimit
  form.Visible = true
  form.goodsnumber.Text = nx_widestr(goodsnum .. "/" .. tolgoodsnum)
  form:Show()
  form.goods_total = tolgoodsnum
  form.cur_goods = goodsnum
  update_info(form)
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
  init_timer(form)
  return 1
end
function Update_goodsinfo(goodsnum)
  local form = util_get_form("form_stage_main\\form_school_war\\form_escort_time_limit", true)
  if not nx_is_valid(form) then
    return
  end
  form.cur_goods = goodsnum
  form.goodsnumber.Text = nx_widestr(goodsnum .. "/" .. form.goods_total)
end
function init_timer(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
end
function get_format_time_text(time)
  local format_time = ""
  local min = nx_int(time / 60)
  local sec = nx_int(math.mod(time, 60))
  format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  return nx_string(format_time) .. "<br>"
end
function update_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.ImageControlGrid:Clear()
  local timer = form.ServerTime
  if nx_int(timer) < nx_int(0) then
    timer = 0
  end
  local format_timer = get_format_time_text(timer)
  form.ImageControlGrid:AddItem(0, nx_string(""), nx_widestr(format_timer), nx_int(0), nx_int(0))
end
function on_update_time(form)
  form.ServerTime = form.ServerTime - 1
  update_info(form)
end
function ClosetTimeLimit()
  local form = util_get_form("form_stage_main\\form_school_war\\form_escort_time_limit", true)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  form.ImageControlGrid:Clear()
  form:Close()
end
function get_goods_time_info()
  local form = util_get_form("form_stage_main\\form_school_war\\form_escort_time_limit", true)
  if not nx_is_valid(form) then
    return
  end
  local timer = form.ServerTime
  local goodsnum = nx_string(form.cur_goods .. "/" .. form.goods_total)
  return goodsnum, timer
end
