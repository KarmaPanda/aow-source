require("util_gui")
require("custom_sender")
require("form_stage_main\\form_guild\\form_guild_util")
require("form_stage_main\\form_guildbuilding\\form_guildbuilding_usekengwei")
function main_form_init(self)
  self.Fixed = false
  self.npc_id = nil
  self.target = nil
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local kick_contribution = get_npc_faculty_info(self, KICK_CONTRIBUTION_INDEX)
  self.lbl_info.HtmlText = nx_widestr(guild_util_get_text("ui_guildbuilding_kengwei_kickout_ack", nx_widestr(kick_contribution), nx_widestr(self.target)))
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(1016), nx_int(5), form.npc_id)
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
