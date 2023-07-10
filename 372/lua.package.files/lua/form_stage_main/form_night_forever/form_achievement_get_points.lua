require("util_gui")
require("util_functions")
require("share\\view_define")
require("util_static_data")
local FORM_ACHIEVEMENT_GET_POINTS = "form_stage_main\\form_night_forever\\form_achievement_get_points"
local MAX_NUMS = 10
function open_form(...)
  if table.getn(arg) ~= 2 then
    return
  end
  local gui = nx_value("gui")
  local instanceid = get_free_form_num()
  if nx_int(instanceid) == nx_int(0) then
    return
  end
  for i = 1, instanceid - 1 do
    local form_name = "form_stage_main\\form_night_forever\\form_achievement_get_points" .. nx_string(i)
    local form_finish = nx_value(form_name)
    if nx_is_valid(form_finish) then
      form_finish.Top = gui.Height * 2 / 3 - form_finish.Height / 2 - form_finish.Height * (instanceid - i)
    end
  end
  local form = util_get_form(FORM_ACHIEVEMENT_GET_POINTS, true, false, instanceid)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local title = "ui_achievement_type_title_" .. nx_string(arg[1])
  form.lbl_achievement_title.Text = nx_widestr(gui.TextManager:GetFormatText(title))
  local content = "ui_achievement_type_content_" .. nx_string(arg[1])
  form.lbl_achievement_content.Text = nx_widestr(gui.TextManager:GetFormatText(content))
  form.lbl_achievement_points.Text = nx_widestr(nx_string(arg[2]))
  gui.Desktop:ToFront(form)
end
function get_free_form_num()
  for i = 1, MAX_NUMS do
    local form_name = "form_stage_main\\form_night_forever\\form_achievement_get_points" .. nx_string(i)
    local form_finish = nx_value(form_name)
    if not nx_is_valid(form_finish) then
      return i
    end
  end
  return 0
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = gui.Height * 2 / 3 - self.Height / 2
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) and not common_execute:FindExecute("ShowGetAchievementPoints", self) then
    common_execute:AddExecute("ShowGetAchievementPoints", self, nx_float(0))
  end
end
function on_main_form_close(self)
  nx_destroy(self)
end
