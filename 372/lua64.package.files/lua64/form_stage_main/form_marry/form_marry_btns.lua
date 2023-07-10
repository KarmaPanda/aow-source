require("form_stage_main\\form_marry\\form_marry_util")
require("define\\sysinfo_define")
local MARRY_BTN_COUNT = 3
local MARRY_BTN_NAME = {
  [1] = "btn_laba",
  [2] = "btn_zhufu",
  [3] = "btn_dongfang"
}
local TVT_TYPE_MARRY_BTNS = 33
function main_form_init(form)
  form.Fixed = false
  for i = 1, MARRY_BTN_COUNT do
    nx_set_custom(form, "show_btn_" .. nx_string(i), false)
  end
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 1
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = gui.Height - form.Height - 200
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "add_form", 1, TVT_TYPE_MARRY_BTNS)
  return 1
end
function on_main_form_close(form)
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "del_form", 1, TVT_TYPE_MARRY_BTNS)
  nx_destroy(form)
end
function on_btn_suo_click(self)
  local form = self.ParentForm
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "check_cbtn_state", 1, TVT_TYPE_MARRY_BTNS)
  form.Visible = false
end
function on_btn_laba_click(self)
  local ST_FUNCTION_SPEAKER = 1101
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_SPEAKER) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_01")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  local gui = nx_value("gui")
  local form_laba = nx_value("form_stage_main\\form_main\\form_laba_info_marry")
  if nx_is_valid(form_laba) then
    form_laba.Visible = not form_laba.Visible
    if form_laba.Visible then
      nx_execute("form_stage_main\\form_main\\form_laba_info_marry", "init", form_laba)
      gui.Desktop:ToFront(form_laba)
    end
  end
end
function on_btn_zhufu_click(self)
  request_wish_cost()
end
function on_btn_dongfang_click(self)
  local CLIENT_SUB_OPEN_WINDOW = 20
  nx_execute("custom_sender", "custom_dongfang_msg", CLIENT_SUB_OPEN_WINDOW)
end
function show_data(btn_type, visible)
  local form = util_get_form(FORM_MARRY_BTNS, false)
  if visible == false and not nx_is_valid(form) then
    return 0
  end
  local is_show = not nx_is_valid(form)
  local form = util_get_form(FORM_MARRY_BTNS, true)
  if not nx_is_valid(form) then
    return 0
  end
  nx_set_custom(form, "show_btn_" .. nx_string(btn_type), visible)
  local count = 0
  for i = 1, MARRY_BTN_COUNT do
    local visible = nx_custom(form, "show_btn_" .. nx_string(i))
    local btn = form:Find(MARRY_BTN_NAME[i])
    if nx_is_valid(btn) then
      btn.Visible = visible
    end
    if visible == true then
      count = count + 1
    end
  end
  if count == 0 then
    form:Close()
    return 0
  end
  local remainder = count % 2
  local center_count = nx_number(nx_int(count / 2)) + remainder
  local index = 1
  for i = 1, MARRY_BTN_COUNT do
    local btn = form:Find(MARRY_BTN_NAME[i])
    if nx_is_valid(btn) and btn.Visible == true then
      btn.Left = form.Width / 2 + (index - center_count) * 80
      if remainder == 0 then
        btn.Left = btn.Left - 40
      end
      if center_count > index then
        btn.Left = btn.Left - 1 * btn.Width
      elseif index == center_count then
        if remainder == 1 then
          btn.Left = btn.Left - 0.5 * btn.Width
        else
          btn.Left = btn.Left - 1 * btn.Width
        end
      end
      index = index + 1
    end
  end
  if is_show then
    util_show_form(FORM_MARRY_BTNS, true)
  end
end
