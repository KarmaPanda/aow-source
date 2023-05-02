require("util_gui")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  on_update_form(self)
  databinder:AddRolePropertyBind("FindWaterRate", "int", self, nx_current(), "on_update_form")
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
  return 1
end
function on_update_form(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local rate = client_player:QueryProp("FindWaterRate")
  form.pbar_1.Value = rate
end
function on_btn_break_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = nx_widestr(gui.TextManager:GetText(nx_string("ui_isneed_break_find_water")))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FIND_WATER))
end
function on_server_msg(...)
  local type = arg[1]
  if type == "open" then
    local stage_main_flag = nx_value("stage_main")
    while nx_string(stage_main_flag) ~= nx_string("success") do
      nx_pause(0.5)
      stage_main_flag = nx_value("stage_main")
    end
    util_show_form("form_stage_main\\form_task\\form_find_water", true)
  elseif type == "close" then
    local form = nx_value("form_stage_main\\form_task\\form_find_water")
    if nx_is_valid(form) then
      form:Close()
    end
  end
end
