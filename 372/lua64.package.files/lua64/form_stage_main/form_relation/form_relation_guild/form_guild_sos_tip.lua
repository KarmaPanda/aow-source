require("util_gui")
require("game_object")
require("share\\client_custom_define")
local SUB_CUSTOMMSG_GUILD_CONFIRM_SOS_ITEM = 112
function main_form_init(self)
  self.Fixed = false
  self.itemid = ""
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.Left = (gui.Width - self.Width) / 2 + self.Width / 2 + 165
  self.Top = (gui.Height - self.Height) / 2
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(20000, -1, nx_current(), "timer_callback", self, -1, -1)
  end
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "timer_callback", self)
    end
    nx_destroy(self)
  end
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_confirm_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_CONFIRM_SOS_ITEM), form.itemid)
  form:Close()
end
function recv_help_tip(...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_sos_tip")
  if not nx_is_valid(form) then
    return
  end
  if #arg < 3 then
    return
  end
  local guild_name = nx_widestr(arg[1])
  local attack_name = nx_widestr(arg[2])
  form.itemid = nx_string(arg[3])
  form.mltbox_tip.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guild_sos_tip", nx_widestr(guild_name), nx_widestr(attack_name), nx_widestr(util_text(form.itemid))))
end
function timer_callback(form)
  if nx_is_valid(form) then
    form:Close()
  end
end
