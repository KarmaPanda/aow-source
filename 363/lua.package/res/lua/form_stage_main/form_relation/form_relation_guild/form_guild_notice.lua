require("custom_sender")
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  self.redit_content.ReadOnly = true
  self.IsEdit = true
  nx_set_value("form_stage_main\\form_relation\\form_relation_guild\\form_notice", self)
end
function on_btn_edit_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local form_guild = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild")
  if not nx_is_valid(form_guild) then
    return 0
  end
  if not form_guild.NoticeAuth then
    local text = nx_widestr(gui.TextManager:GetText("19018"))
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(text, 1, 0)
    end
    return 0
  end
  if true == form.IsEdit then
    form.redit_content.ReadOnly = false
    form.IsEdit = false
    local publish_text = nx_widestr(gui.TextManager:GetText("ui_guild_notice_publish"))
    btn.Text = publish_text
  elseif false == form.IsEdit then
    local content = form.redit_content.Text
    local check_words = nx_value("CheckWords")
    if nx_is_valid(check_words) and nx_widestr(content) ~= nx_widestr(check_words:CleanWords(nx_widestr(content))) then
      local gui = nx_value("gui")
      local text = nx_widestr(gui.TextManager:GetText("ui_EnterValidNote"))
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      return 0
    end
    custom_request_set_notice(content)
    form.redit_content.ReadOnly = true
    form.IsEdit = true
    local edit_text = nx_widestr(gui.TextManager:GetText("ui_guild_notice_edit"))
    btn.Text = edit_text
  end
end
function on_recv_notice(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_notice")
  if not nx_is_valid(form) or table.getn(arg) < 8 then
    return 0
  end
  form.redit_content.Text = nx_widestr(arg[8])
end
