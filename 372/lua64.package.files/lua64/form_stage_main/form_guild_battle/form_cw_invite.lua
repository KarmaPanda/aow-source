require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_guild_battle\\form_cw_invite"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  nx_execute("form_stage_main\\form_guild_battle\\form_cw_match", "close_form")
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
  local sec = get_sec(form)
  sec = sec - 1
  set_sec(form, sec)
  if sec < 0 then
    close_form()
  end
end
function get_sec(form)
  local sec_text = form.lbl_time.Text
  local tab_sec = util_split_wstring(sec_text, ":")
  local sec = nx_number(tab_sec[1]) * 60 + nx_number(tab_sec[2])
  return sec
end
function set_sec(form, sec)
  local minute = math.floor(sec / 60)
  local second = math.mod(sec, 60)
  local sec_text = string.format("%02d:%02d", minute, second)
  form.lbl_time.Text = nx_widestr(sec_text)
end
function open_form(war_type)
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
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_time", form)
    end
    form:Close()
  end
end
function on_btn_go_click(btn)
  custom_champion_war(0)
end
