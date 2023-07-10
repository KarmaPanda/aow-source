require("util_gui")
require("util_functions")
require("game_object")
function on_main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "close_form", self)
  end
  nx_destroy(self)
end
function show_rob_prison_detail(...)
  if arg == nil or table.getn(arg) < 3 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = util_get_form("form_stage_main\\form_rob_prison\\form_rob_prison_detail", true, false)
  if not nx_is_valid(form) then
    return
  end
  local detail_type = nx_number(arg[1])
  local name = nx_widestr(arg[2])
  local time_limit = nx_number(arg[3])
  if detail_type == 0 then
    form.groupbox_0.Visible = true
    form.mltbox_0:AddHtmlText(gui.TextManager:GetFormatText("ui_jieyu_chenggong", name), -1)
  elseif detail_type == 1 then
    form.groupbox_1.Visible = true
  elseif detail_type == 2 then
    form.groupbox_2.Visible = true
    form.mltbox_2:AddHtmlText(gui.TextManager:GetFormatText("ui_jieyu_zhuibu", name), -1)
  elseif detail_type == 3 then
    form.groupbox_3.Visible = true
  end
  local timer = nx_value("timer_game")
  if nx_is_valid then
    timer:Register(time_limit * 1000, 1, nx_current(), "close_form", form, -1, -1)
  end
  form.Visible = true
  form:Show()
end
function close_form(form)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
