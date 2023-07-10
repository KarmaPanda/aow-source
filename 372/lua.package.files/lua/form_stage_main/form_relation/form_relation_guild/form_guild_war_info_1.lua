require("util_functions")
require("custom_sender")
require("util_gui")
local GUILD_CAPTAIN_COUNT = 8
local CTS_GCW_SET_CROSSEWAR_LIMIT = 10
local CTS_GCW_GET_CROSSEWAR_LIMIT = 11
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(form)
  init_form_ui(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function close_form()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_war_info_1")
  if nx_is_valid(form) then
    form:Close()
  end
end
function init_form_ui(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2 - 100
  form.Top = (gui.Height - form.Height) / 2 - 50
  local combobox_text
  for i = 1, nx_number(GUILD_CAPTAIN_COUNT) do
    local ui_text = "ui_guild_pos_level" .. nx_string(i) .. "_name"
    combobox_text = gui.TextManager:GetFormatText(ui_text)
    form.combobox_1.DropListBox:AddString(nx_widestr(combobox_text))
  end
  nx_execute("custom_sender", "custom_cross_guild_war", nx_int(CTS_GCW_GET_CROSSEWAR_LIMIT))
end
function on_btn_member_ok_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local cross_war_manager = nx_value("GuildCrossWarManager")
  if not nx_is_valid(cross_war_manager) then
    return 0
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local max_active_value = cross_war_manager:GetMaxActiveValue()
  local guild_captain_level = form.combobox_1.DropListBox.SelectIndex + 1
  local active_value = nx_int(form.fipt_1.Text)
  if guild_captain_level > GUILD_CAPTAIN_COUNT or guild_captain_level <= 0 then
    return
  end
  if nx_number(active_value) > nx_number(max_active_value) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1000398"))
    return
  end
  nx_execute("custom_sender", "custom_cross_guild_war", nx_int(CTS_GCW_SET_CROSSEWAR_LIMIT), nx_int(active_value), nx_int(guild_captain_level))
  close_form()
end
function manager_form_data(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_war_info_1")
  if not nx_is_valid(form) then
    return 0
  end
  refresh_limited_form(unpack(arg))
end
function refresh_limited_form(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_war_info_1")
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if table.getn(arg) < 2 then
    return 0
  end
  local guild_captain_level = nx_int(arg[1])
  local active_value = nx_int(arg[2])
  if 0 >= nx_number(guild_captain_level) then
    guild_captain_level = GUILD_CAPTAIN_COUNT
  end
  if 0 >= nx_number(active_value) then
    active_value = 0
  end
  form.combobox_1.DropListBox.SelectIndex = guild_captain_level - 1
  form.combobox_1.InputEdit.Text = form.combobox_1.DropListBox.SelectString
  form.fipt_1.Text = nx_widestr(active_value)
end
