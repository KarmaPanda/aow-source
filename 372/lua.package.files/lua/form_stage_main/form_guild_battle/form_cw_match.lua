require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_guild_battle\\form_cw_match"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.lbl_time.Text = nx_widestr(0)
  local form_guild = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", false)
  if nx_is_valid(form_guild) then
    form_guild:Close()
  end
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_time", self, -1, -1)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", self)
  end
  nx_destroy(self)
end
function on_update_time(form)
  local sec = nx_number(form.lbl_time.Text)
  sec = sec + 1
  form.lbl_time.Text = nx_widestr(sec)
end
function open_form(war_type, players_info)
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
  form.lbl_type.BackImage = nx_string("gui\\guild\\guildwar_new\\entrance_" .. nx_string(war_type) .. ".png")
  form.mltbox_1.HtmlText = nx_widestr(util_text("tips_mlt_cw_" .. nx_string(war_type)))
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog:ShowModal()
    local text = nx_widestr(util_text("ui_cw_quit_match"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      custom_champion_war(105)
    end
  end
end
