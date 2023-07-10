require("util_functions")
local tab_type_photo = {
  [1] = "shangshangqian",
  [2] = "gui\\special\\day_divine\\zhongping.png",
  [3] = "xiaxiaqian",
  [4] = "lingqian"
}
local tab_type_sysinfo = {
  [1] = "day_divine_2",
  [2] = "day_divine_3",
  [3] = "day_divine_4",
  [4] = "day_divine_5"
}
function on_main_form_init(self)
  self.Fixed = true
  self.type = 0
  self.heartbeat_count = 0
  self.flag = 0
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = 0
  self.AbsTop = 0
  self.Height = gui.Height
  self.Width = gui.Width
  self.lbl_ShowCartoon.AbsLeft = (self.Width - self.lbl_ShowCartoon.Width) / 2
  self.lbl_result.AbsLeft = (self.Width - self.lbl_result.Width) / 2
  self.btn_close.Visible = false
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", self)
  timer:Register(1, -1, nx_current(), "on_update_time", self, -1, -1)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_update_time(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local timer = nx_value("timer_game")
  if form.heartbeat_count <= 20 then
    timer:UnRegister(nx_current(), "on_update_time", form)
    timer:Register(50, -1, nx_current(), "on_update_time", form, -1, -1)
    form.heartbeat_count = form.heartbeat_count + 1
    update_pos(form)
  else
    timer:UnRegister(nx_current(), "on_update_time", form)
    timer:Register(2000, -1, nx_current(), "on_close_time", form, -1, -1)
    show_result(form)
  end
end
function on_close_time(form)
  form:Close()
end
function update_pos(form)
  form.lbl_result.Visible = false
  if form.flag == 0 then
    form.lbl_ShowCartoon.AbsLeft = form.lbl_ShowCartoon.AbsLeft + 5
    form.flag = 1
  else
    form.lbl_ShowCartoon.AbsLeft = form.lbl_ShowCartoon.AbsLeft - 5
    form.flag = 0
  end
end
function show_result(form)
  form.lbl_ShowCartoon.Visible = false
  form.lbl_result.Visible = true
  if form.type > 4 then
    form.type = 4
  end
  local photo = tab_type_photo[form.type]
  if photo ~= nil then
    form.lbl_result.BackImage = photo
  end
  local tips = tab_type_sysinfo[form.type]
  if tips ~= nil then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(tips), 2)
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_server_msg(...)
  local type = arg[1]
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_day_divine\\form_day_divine", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.type = type
  form:Show()
end
