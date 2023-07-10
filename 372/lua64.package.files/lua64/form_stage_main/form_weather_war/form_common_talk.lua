local FORM_COMMON_TALK = "form_stage_main\\form_weather_war\\form_common_talk"
local COMMON_TALK_FILE = "ini\\ui\\weather_war\\common_talk.ini"
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_close_time", self)
  nx_destroy(self)
end
function show_form(talk_id)
  local form = nx_execute("util_gui", "util_get_form", FORM_COMMON_TALK, true, false)
  if not nx_is_valid(form) then
    return
  end
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return
  end
  if not IniManager:IsIniLoadedToManager(COMMON_TALK_FILE) then
    IniManager:LoadIniToManager(COMMON_TALK_FILE)
  end
  local ini = IniManager:GetIniDocument(COMMON_TALK_FILE)
  if not nx_is_valid(ini) then
    return
  end
  local sec_name = string.format("%d", nx_number(talk_id))
  local sec_index = ini:FindSectionIndex(nx_string(sec_name))
  if sec_index < 0 then
    return
  end
  local npc_id = ini:ReadString(sec_index, "ConfigID", "")
  local talk_text = ini:ReadString(sec_index, "TalkText", "")
  local last_time = ini:ReadInteger(sec_index, "LastTime", 0)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local itemQuery = nx_value("ItemQuery")
  if not nx_is_valid(itemQuery) then
    return
  end
  local photo = itemQuery:GetItemPropByConfigID(npc_id, nx_string("Photo"))
  local name = gui.TextManager:GetText(npc_id)
  local talk_desc = gui.TextManager:GetText(talk_text)
  form.grid_photo:AddItem(0, nx_string(photo), "", 1, -1)
  form.lbl_name.Text = nx_widestr(name)
  form.mbx_talk:Clear()
  form.mbx_talk:AddHtmlText(nx_widestr(talk_desc), -1)
  form:Show()
  local timer = nx_value("timer_game")
  timer:Register(last_time * 1000, 1, nx_current(), "on_close_time", form, -1, -1)
end
function close_form(form)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_close_time(form)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
