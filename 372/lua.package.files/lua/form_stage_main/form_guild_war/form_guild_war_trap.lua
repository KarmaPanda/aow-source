require("util_functions")
require("share\\client_custom_define")
local MAX_TRAP_COUNT = 8
local CLIENT_SUBMSG_TRAP_CHOSE_OK = 19
local CLIENT_SUBMSG_TRAP_INFO = 20
local DOMAIN_ID = 0
local MAIN_TYPE = 0
local SUB_TYPE = 0
local traps_level_table = {
  [1] = {trap_count = 1},
  [2] = {trap_count = 2},
  [3] = {trap_count = 3},
  [4] = {trap_count = 4},
  [5] = {trap_count = 5},
  [6] = {trap_count = 6}
}
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.Default = form.btn_ok
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(self)
  local dialog = self.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_TRAP_CHOSE_OK), nx_int(DOMAIN_ID), nx_int(MAIN_TYPE), nx_int(SUB_TYPE), nx_int(dialog.cbtn_1.Checked), nx_int(dialog.cbtn_2.Checked), nx_int(dialog.cbtn_3.Checked), nx_int(dialog.cbtn_4.Checked), nx_int(dialog.cbtn_5.Checked), nx_int(dialog.cbtn_6.Checked), nx_int(dialog.cbtn_7.Checked), nx_int(dialog.cbtn_8.Checked))
  dialog:Close()
  return 1
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function show_trap_chose_form(parent, build_level, domain_id, main_type, sub_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_trap", true, false)
  if not nx_is_valid(dialog) then
    return 0
  end
  DOMAIN_ID = domain_id
  MAIN_TYPE = main_type
  SUB_TYPE = sub_type
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_TRAP_INFO), nx_int(domain_id), nx_int(main_type), nx_int(sub_type))
  for i = 1, MAX_TRAP_COUNT do
    local trap_cbtn = dialog.groupbox:Find("cbtn_" .. i)
    if nx_is_valid(trap_cbtn) then
      trap_cbtn.Enabled = false
    end
  end
  local trap_table = traps_level_table[build_level]
  local count = trap_table.trap_count
  for j = 1, count do
    local trap_cbtn = dialog.groupbox:Find("cbtn_" .. j)
    if nx_is_valid(trap_cbtn) then
      trap_cbtn.Enabled = true
    end
  end
  dialog:ShowModal()
end
function set_checkbtns(is_checked_1, is_checked_2, is_checked_3, is_checked_4, is_checked_5, is_checked_6, is_checked_7, is_checked_8)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_trap")
  if not nx_is_valid(form) then
    return 0
  end
  form.cbtn_1.Checked = nx_boolean(is_checked_1)
  form.cbtn_2.Checked = nx_boolean(is_checked_2)
  form.cbtn_3.Checked = nx_boolean(is_checked_3)
  form.cbtn_4.Checked = nx_boolean(is_checked_4)
  form.cbtn_5.Checked = nx_boolean(is_checked_5)
  form.cbtn_6.Checked = nx_boolean(is_checked_6)
  form.cbtn_7.Checked = nx_boolean(is_checked_7)
  form.cbtn_8.Checked = nx_boolean(is_checked_8)
end
