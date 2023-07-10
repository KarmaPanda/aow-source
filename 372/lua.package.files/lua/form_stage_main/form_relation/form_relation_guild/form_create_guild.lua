require("share\\client_custom_define")
require("util_functions")
require("util_gui")
local SUB_CUSTOMMSG_CREATE_GUILD = 1
function auto_show_hide_form_create_guild(show)
  local skin_path = "form_stage_main\\form_relation\\form_relation_guild\\form_create_guild"
  local form = nx_value(skin_path)
  if nx_is_valid(form) and form.Visible == show then
    return
  end
  if show == nil then
    if not nx_is_valid(form) then
      util_show_form(skin_path, true)
    else
      form.Visible = not form.Visible
    end
  else
    if not nx_is_valid(form) then
      util_show_form(skin_path, true)
    end
    local form = nx_value(skin_path)
    form.Visible = show
  end
  local form = nx_value(skin_path)
  ui_show_attached_form(form)
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetText("ui_guild_creatinfo1"))
  local max_guild_name_size = get_guild_name_max_size()
  if 0 < max_guild_name_size then
    form.ipt.MaxLength = max_guild_name_size
  end
  return 1
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_main_form_close(form)
  nx_execute("util_gui", "ui_destroy_attached_form", form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_relation\\form_relation_guild\\form_create_guild", nx_null())
end
function on_btn_confirm_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local guild_name = form.ipt.Text
  if nx_string(guild_name) == "" then
    local info = nx_widestr(util_text("19316"))
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(info, 0, 0)
    end
    return 0
  end
  local guild_purpose = form.redit_1.Text
  local check_words = nx_value("CheckWords")
  if not nx_is_valid(check_words) then
    return 0
  end
  if not check_words:CheckSecondNames(nx_widestr(guild_name)) or not check_words:CheckGuildPurpose(nx_widestr(guild_purpose)) then
    local gui = nx_value("gui")
    local text = nx_widestr(gui.TextManager:GetText("ui_EnterValidNote"))
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    return 0
  end
  local result = nx_execute("form_stage_create\\form_create", "check_name_separator", guild_name, "guild_name")
  if 0 < result then
    local info = util_text("ui_SeparatorError_" .. nx_string(result))
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(info, 0, 0)
    end
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_CREATE_GUILD), guild_name, guild_purpose)
  form:Close()
  return 1
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
