require("custom_sender")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
function main_form_init(self)
  self.Fixed = false
  self.to_player = ""
  self.string_id = "ui_guild_shanrang_confirm"
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return false
  end
  local player_name = game_role:QueryProp("Name")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm_equal_text", true, false)
  nx_execute("form_common\\form_confirm_equal_text", "set_text", dialog, "ui_guild_shanrang_name", player_name)
  dialog.event_type = "equal_text"
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "equal_text_confirm_return")
  if "ok" == res then
    custom_guild_shanrang(form.to_player)
    form:Close()
    return
  else
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19964"), 2)
    end
    return
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_shangrang(to_player)
  local form = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_shanrang", true)
  if nx_is_valid(form) then
    form.to_player = to_player
    form.redit_1.Text = guild_util_get_text(form.string_id, nx_widestr(to_player))
    form.Visible = true
    form:Show()
  end
end
