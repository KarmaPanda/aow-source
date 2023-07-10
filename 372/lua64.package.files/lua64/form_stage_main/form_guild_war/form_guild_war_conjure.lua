require("util_functions")
require("share\\client_custom_define")
local CLIENT_SUBMSG_RESPOND_OK = 15
local CLIENT_SUBMSG_RESPOND_CANCEL = 16
local CLIENT_SUBMSG_RESPOND_OTHER_GUILD = 17
local COUNT_TIME = 120
local GUILDWAR_STAGE_READY = 1
local GUILDWAR_STAGE_FIGHTING = 2
function main_form_init(self)
  self.Fixed = false
end
function main_form_open(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.Default = self.ok_btn
  check_loading(self)
end
function on_main_form_close(form)
  form.info_mltbox:Clear()
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function ok_btn_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_RESPOND_OK), form.conjureGuildName, form.conjurePlayerName, form.conjureDomainId)
  end
  form:Close()
end
function cancel_btn_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_RESPOND_CANCEL), form.conjurePlayerName)
  end
  form:Close()
end
function refresh_count_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.CountTime = form.CountTime - 1
  if nx_int(form.CountTime) <= nx_int(0) then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_RESPOND_OK), form.conjureGuildName, form.conjurePlayerName, form.conjureDomainId)
    end
    form:Close()
    return
  end
  form.lbl_revert.Text = nx_widestr(form.CountTime)
end
function show_conjure_text(dialog, text)
  if not nx_is_valid(dialog) then
    return
  end
  dialog.info_mltbox.Visible = true
  dialog.info_mltbox:Clear()
  dialog.info_mltbox:AddHtmlText(nx_widestr(text), -1)
end
function show_conjure_form(...)
  local data_size = table.getn(arg)
  if nx_int(data_size) ~= nx_int(4) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_conjure", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog.CountTime = COUNT_TIME
  dialog.conjureGuildName = nx_widestr(arg[1])
  dialog.conjurePlayerName = nx_widestr(arg[2])
  dialog.conjureDomainId = nx_int(arg[3])
  local domain_str = "ui_dipan_" .. nx_string(arg[3])
  local war_satge = nx_int(arg[4])
  local info_id = "ui_guild_conjure_tool_use_1"
  if war_satge == nx_int(GUILDWAR_STAGE_FIGHTING) then
    info_id = "ui_guild_conjure_tool_use_2"
  end
  local text = nx_widestr(gui.TextManager:GetFormatText(nx_string(info_id), dialog.conjurePlayerName, domain_str))
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_conjure", "show_conjure_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "refresh_count_time", dialog, -1, -1)
  else
    dialog:Close()
    return
  end
end
function check_loading(form)
  local form_load = nx_value("form_common\\form_loading")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_is_valid(form_load) then
    gui.Desktop:ToBack(form)
  else
    gui.Desktop:ToFront(form)
  end
end
