require("util_functions")
local FORM_OUT_CLONE = "form_stage_main\\form_team\\form_team_out_clone"
function show_out_clone_time(time)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local form = nx_value(FORM_OUT_CLONE)
  if not nx_is_valid(form) then
    form = nx_call("util_gui", "util_get_form", FORM_OUT_CLONE, true, true)
  end
  form.mltbox_1:Clear()
  form.mltbox_1:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("ui_fuben0010", nx_int(time))), nx_int(-1))
  form:Show()
  form.Visible = true
  local leavetime = time
  while true do
    local sec = nx_pause(1)
    if not nx_is_valid(form) then
      break
    end
    leavetime = leavetime - 1
    if leavetime < 0 then
      form:Close()
      break
    end
    form.mltbox_1:Clear()
    form.mltbox_1:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("ui_fuben0010", nx_int(leavetime))), nx_int(-1))
  end
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 8
  return 1
end
function on_main_form_close(self)
  self.mltbox_1:Clear()
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
