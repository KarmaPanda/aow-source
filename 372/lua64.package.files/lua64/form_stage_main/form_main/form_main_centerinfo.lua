require("define\\sysinfo_define")
local MAX_TEXT_HEIGHT = 1024
function init_center_info(desktop)
  local childlist = {
    desktop.mltbox_1,
    desktop.groupbox_1,
    desktop.groupbox_2,
    desktop.groupbox_3,
    desktop.mltbox_3,
    desktop.mltbox_4,
    desktop.mltbox_5,
    desktop.mltbox_6,
    desktop.mltbox_7,
    desktop.mltbox_8,
    desktop.mltbox_2
  }
  for _, control in ipairs(childlist) do
    control.Visible = false
    desktop:AddTopLayer(control)
  end
  desktop.last_info = ""
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    nx_destroy(SystemCenterInfo)
  end
  SystemCenterInfo = nx_create("SystemCenterInfo")
  nx_set_value("SystemCenterInfo", SystemCenterInfo)
  desktop.mltbox_9.Visible = false
end
function clear_center_info(desktop)
  if nx_running(nx_current(), "show_area_name") then
    nx_kill(nx_current(), "show_area_name")
  end
end
function show_area_name(info)
  local desktop = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(desktop) then
    return 0
  end
  local control = desktop.mltbox_9
  if not nx_is_valid(control) then
    return 0
  end
  control:Clear()
  control.Width = 20 + control.TipMaxWidth
  control.ViewRect = "0,0," .. control.TipMaxWidth .. "," .. MAX_TEXT_HEIGHT
  control:AddHtmlText(nx_widestr(info), -1)
  local real_width = control:GetContentWidth()
  local real_height = control:GetContentHeight()
  control.Width = real_width
  control.Height = real_height * 1.2
  control.Alpha = nx_int(255)
  control.show_count = 0
  control.Visible = true
  control.AbsLeft = (desktop.Width - control.Width) / 2
  control.AbsTop = (desktop.Height - control.Height) / 3
  while nx_is_valid(control) and control.show_count < 10 do
    if control.show_count < 0.5 then
      control.Alpha = nx_int(control.show_count * 255 / 0.5)
    elseif control.show_count > 8 then
      control.Alpha = nx_int((10 - control.show_count) * 255 / 2)
    else
      control.Alpha = nx_int(255)
    end
    nx_pause(0)
    if nx_is_valid(control) and nx_find_custom(control, "show_count") then
      control.show_count = control.show_count + nx_elapse()
      if control.show_count >= 10 then
        control.Visible = false
      end
    end
  end
end
