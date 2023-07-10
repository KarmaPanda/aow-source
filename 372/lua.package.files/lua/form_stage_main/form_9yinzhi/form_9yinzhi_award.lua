require("share\\server_custom_define")
require("share\\client_custom_define")
require("const_define")
require("define\\jiuyinzhi_define")
require("util_gui")
local FORM_JIUYINZHI_AWARD_PATH = "form_stage_main\\form_9yinzhi\\form_9yinzhi_award"
local FORM_JIUYINZHI_AWARD_LUA_PATH = "form_stage_main\\form_9yinzhi\\form_9yinzhi_award"
function open_form(...)
  if table.getn(arg) < 5 then
    return
  end
  local award_id = nx_string(arg[1])
  local award_num = nx_int(arg[2])
  local join_value = nx_int(arg[3])
  local cur_value = nx_int(arg[4])
  local max_value = nx_int(arg[5])
  local form_old = nx_value(FORM_JIUYINZHI_AWARD_PATH)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) and nx_is_valid(form_old) then
    timer:UnRegister(FORM_JIUYINZHI_AWARD_LUA_PATH, "tread_close", form_old)
  end
  local bIsCreate = true
  if nx_is_valid(form_old) then
    bIsCreate = false
  end
  local form_new = util_get_form(FORM_JIUYINZHI_AWARD_PATH, bIsCreate, true)
  if not nx_is_valid(form_new) then
    return
  end
  form_new.award_id = award_id
  form_new.award_num = award_num
  form_new.join_value = join_value
  form_new.cur_value = cur_value
  form_new.max_value = max_value
  nx_set_value(FORM_JIUYINZHI_AWARD_PATH, form_new)
  util_show_form(FORM_JIUYINZHI_AWARD_PATH, false)
  util_show_form(FORM_JIUYINZHI_AWARD_PATH, true)
end
function close_form()
  local form = util_show_form(FORM_JIUYINZHI_AWARD_PATH, false)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) and nx_is_valid(form) then
    timer:Register(2000, 1, FORM_JIUYINZHI_AWARD_LUA_PATH, "tread_close", form, -1, -1)
  end
end
function tread_close(obj, param1, param2)
  local form = obj
  if nx_is_valid(form) then
    nx_remove_value(FORM_JIUYINZHI_AWARD_PATH)
    nx_destroy(form)
  end
end
function main_form_init(form)
  form.Fixed = false
  return
end
function on_main_form_open(form)
  clearControllerState(form)
  draw(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
end
function clearControllerState(form)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_title:Clear()
  form.mltbox_content:Clear()
  form.mltbox_process:Clear()
  form.mltbox_award_num:Clear()
end
function draw(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local suffix = nx_string(form.award_id)
  local textID = ""
  local hintText = ""
  local base_top = 0
  textID = "jyz_award_title_" .. suffix
  local mltTextStr = gui.TextManager:GetFormatText(textID)
  form.mltbox_title:AddHtmlText(mltTextStr, -1)
  form.mltbox_title.Height = form.mltbox_title:GetContentHeight()
  form.mltbox_title.Width = form.mltbox_title:GetContentWidth()
  form.mltbox_title.Top = base_top + 6
  form.mltbox_title.Left = (form.Width - form.mltbox_title.Width) / 2
  base_top = form.mltbox_title.Top + form.mltbox_title.Height
  textID = "jyz_award_content_" .. suffix
  mltTextStr = gui.TextManager:GetFormatText(textID)
  form.mltbox_content:AddHtmlText(mltTextStr, -1)
  form.mltbox_content.Height = form.mltbox_content:GetContentHeight()
  form.mltbox_content.Width = form.mltbox_content:GetContentWidth()
  form.mltbox_content.Top = base_top + 20
  base_top = form.mltbox_content.Top + form.mltbox_content.Height
  if nx_int(form.join_value) > nx_int(0) then
    textID = "jyz_award_process_" .. suffix
    mltTextStr = gui.TextManager:GetFormatText(textID, nx_int(form.cur_value), nx_int(form.max_value))
    form.mltbox_process:AddHtmlText(mltTextStr, -1)
    textID = "jyz_award_process_tips_" .. suffix
    hintText = gui.TextManager:GetFormatText(textID)
    form.mltbox_process.HintText = hintText
    form.mltbox_process.Height = form.mltbox_process:GetContentHeight()
    form.mltbox_process.Width = form.mltbox_process:GetContentWidth()
    form.mltbox_process.Top = base_top + 20
    base_top = form.mltbox_process.Top + form.mltbox_process.Height
  end
  textID = "jyz_award_event_num"
  mltTextStr = gui.TextManager:GetFormatText(textID, nx_int(form.award_num))
  form.mltbox_award_num:AddHtmlText(mltTextStr, -1)
  form.mltbox_award_num.Height = form.mltbox_award_num:GetContentHeight()
  form.mltbox_award_num.Width = form.mltbox_award_num:GetContentWidth()
  form.mltbox_award_num.Top = base_top + 20
  base_top = form.mltbox_award_num.Top + form.mltbox_award_num.Height
  if nx_int(form.join_value) > nx_int(0) then
    form.btn_award.Enabled = false
  else
    form.btn_award.Enabled = true
  end
  form.btn_award.Top = base_top + 20
  form.btn_award.Left = (form.Width - form.btn_award.Width) / 2
  base_top = form.btn_award.Top + form.btn_award.Height
  form.Height = base_top + 20
end
function on_btn_award_click(btn, mouseID)
  local form = nx_value(FORM_JIUYINZHI_AWARD_PATH)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_9yinzhi\\form_9yinzhi_main", "sendCustomMsgGetInfo", MSGID_JIUYINZHI_GET_AWARD_EVENT, nx_string(form.award_id))
end
