require("share\\server_custom_define")
require("share\\client_custom_define")
require("util_functions")
require("custom_sender")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local CLIENT_SUBMSG_JOIN_WAR = 29
local CLIENT_SUBMSG_REFRESH_DOMAIN_LIST = 34
function show_guild_war_baoming(playerName)
  local form = util_get_form("form_stage_main\\form_guild_war\\form_guild_war_baoming_member", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.playerName = playerName
  form:Show()
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  request_domain_list()
end
function on_main_form_close(form)
  nx_destroy(form)
  ui_destroy_attached_form(form)
end
function on_ok_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_JOIN_WAR), nx_int(form.domainID), form.playerName)
  form:Close()
end
function on_cancel_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form:Close()
end
function on_combobox_domain_selected(combobox)
  local form = combobox.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local select_index = combobox.DropListBox.SelectIndex
  local obj_id = combobox.DropListBox:GetTag(select_index)
  local id = nx_string(obj_id)
  local domian_id = nx_int(id)
  form.domainID = domian_id
end
function request_domain_list()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_REFRESH_DOMAIN_LIST))
end
function on_recv_domain_list(...)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_baoming_member")
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  form.combobox_domain.DropListBox:ClearString()
  domain_list = {}
  local size = table.getn(arg)
  if size <= 0 or size % 2 ~= 0 then
    return 0
  end
  local rows = size / 2
  for i = 1, rows do
    local base = (i - 1) * 2
    local domain_id = arg[base + 1]
    local max_join = arg[base + 2]
    table.insert(domain_list, {domain_id, max_join})
    form.combobox_domain.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_dipan_" .. nx_string(domain_id))))
    local id = nx_string(domain_id) .. "-0"
    form.combobox_domain.DropListBox:SetTag(i - 1, nx_object(id))
  end
  form.combobox_domain.DropListBox.SelectIndex = 0
  form.combobox_domain.Text = form.combobox_domain.DropListBox:GetString(0)
  local obj_id = form.combobox_domain.DropListBox:GetTag(0)
  local id = nx_string(obj_id)
  local domian_id = nx_int(id)
  form.domainID = domian_id
end
