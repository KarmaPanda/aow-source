require("util_functions")
require("util_gui")
require("util_static_data")
require("share\\client_custom_define")
LEAVE_SCHOOL_TYPE = 1
LEAVE_SCHOOL_INFO_TITLE = 2
LEAVE_SCHOOL_INFO_IMAGE = 3
LEAVE_SCHOOL_INFO_DES_TEXT1 = 4
LEAVE_SCHOOL_INFO_DES_TEXT2 = 5
LEAVE_SCHOOL_INFO_DES_TEXT3 = 6
LEAVE_SCHOOL_INFO_DES_TEXT4 = 7
LEAVE_SCHOOL_INFO_DES_TEXT5 = 8
LEAVE_SCHOOL_INFO_DES_TEXT6 = 9
function open_form(type)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_school_war\\form_school_leave", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  if nx_int(3) == nx_int(type) then
    form.btn_1.Visible = false
  else
    form.btn_1.Visible = true
  end
  refresh_leave_school_msg(form, type)
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
  form.leave_type = 0
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local bret = ShowTipDialog(util_text(nx_string("ui_leaveschool_type_") .. nx_string(form.leave_type)))
  if not bret then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUIDE_ADD_SCHOOL), 2, nx_int(form.leave_type))
end
function refresh_leave_school_msg(form, type)
  local school = getschool()
  if school == nil or nx_string(school) == nx_string("") then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\leaveschool\\leaveschool_info.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(school))
  if nx_int(sec_index) < nx_int(0) then
    return
  end
  local infolist = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, nx_number(table.getn(infolist)) do
    local info = util_split_string(infolist[i], ",")
    if nx_int(info[LEAVE_SCHOOL_TYPE]) == nx_int(type) then
      form.leave_type = type
      form.lbl_title.Text = nx_widestr(util_text(nx_string(info[LEAVE_SCHOOL_INFO_TITLE])))
      form.lbl_image.BackImage = nx_string(info[LEAVE_SCHOOL_INFO_IMAGE])
      form.mltbox_1.HtmlText = nx_widestr(util_text(nx_string(info[LEAVE_SCHOOL_INFO_DES_TEXT1])))
      form.mltbox_2.HtmlText = nx_widestr(util_text(nx_string(info[LEAVE_SCHOOL_INFO_DES_TEXT2])))
      form.mltbox_3.HtmlText = nx_widestr(util_text(nx_string(info[LEAVE_SCHOOL_INFO_DES_TEXT3])))
      form.mltbox_4.HtmlText = nx_widestr(util_text(nx_string(info[LEAVE_SCHOOL_INFO_DES_TEXT4])))
      form.mltbox_5.HtmlText = nx_widestr(util_text(nx_string(info[LEAVE_SCHOOL_INFO_DES_TEXT5])))
      form.mltbox_6.HtmlText = nx_widestr(util_text(nx_string(info[LEAVE_SCHOOL_INFO_DES_TEXT6])))
      break
    end
  end
end
function getschool()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local playerschool = client_player:QueryProp("School")
  return playerschool
end
