require("util_functions")
require("util_gui")
require("custom_sender")
local FORM_PATH = "form_stage_main\\form_match\\form_taolu_confirm"
local array_name = "form_taolu_confirm_array"
local cbox_taolu_list = {
  "ui_match_taolu_1",
  "ui_match_taolu_2",
  "ui_match_taolu_3",
  "ui_match_taolu_4",
  "ui_match_taolu_5",
  "ui_match_taolu_6",
  "ui_match_taolu_7",
  "ui_match_taolu_8",
  "ui_match_taolu_9",
  "ui_match_taolu_10"
}
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.limit_id = 0
  form.lbl_taolu_1.taolu_id = ""
  form.lbl_taolu_2.taolu_id = ""
  form.lbl_taolu_3.taolu_id = ""
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not common_array:FindArray(array_name) then
    common_array:AddArray(array_name, form, 60, true)
  end
  common_array:ClearChild(array_name)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function open_form(...)
  local form = nx_value(FORM_PATH)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", FORM_PATH, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.limit_id = nx_int(arg[2])
  LoadTaolu()
  form.cbox_taolu.Text = util_text(cbox_taolu_list[1])
  count = table.getn(cbox_taolu_list)
  for i = 1, count do
    form.cbox_taolu.DropListBox:AddString(nx_widestr(util_text(cbox_taolu_list[i])))
  end
  form.cbox_taolu.DropListBox.SelectIndex = 0
  form.cbox_taolu.Text = nx_widestr(form.cbox_taolu.DropListBox:GetString(form.cbox_taolu.DropListBox.SelectIndex))
  on_cbox_taolu_selected(form.cbox_taolu)
end
function on_btn_submit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  nx_execute("custom_sender", "custom_egwar_trans", nx_number(8), nx_number(form.limit_id), nx_string(form.lbl_taolu_1.taolu_id), nx_string(form.lbl_taolu_2.taolu_id), nx_string(form.lbl_taolu_3.taolu_id))
  form:Close()
end
function on_cbox_taolu_selected(cbox)
  local form = cbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = nx_string(get_now_group_index(form))
  if index == "" then
    record_oper_info(1, "get now group index is null.")
    return
  end
  form.lbl_taolu_1.Text = nx_widestr("")
  form.lbl_taolu_2.Text = nx_widestr("")
  form.lbl_taolu_3.Text = nx_widestr("")
  form.lbl_taolu_1.taolu_id = Get_taolu(nx_string(form.limit_id) .. "_" .. index .. "_1")
  form.lbl_taolu_2.taolu_id = Get_taolu(nx_string(form.limit_id) .. "_" .. index .. "_2")
  form.lbl_taolu_3.taolu_id = Get_taolu(nx_string(form.limit_id) .. "_" .. index .. "_3")
  if nx_string(form.lbl_taolu_1.taolu_id) ~= "" then
    form.lbl_taolu_1.Text = util_text(form.lbl_taolu_1.taolu_id)
  end
  if nx_string(form.lbl_taolu_2.taolu_id) ~= "" then
    form.lbl_taolu_2.Text = util_text(form.lbl_taolu_2.taolu_id)
  end
  if nx_string(form.lbl_taolu_3.taolu_id) ~= "" then
    form.lbl_taolu_3.Text = util_text(form.lbl_taolu_3.taolu_id)
  end
end
function LoadTaolu()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    record_oper_info(1, "create ini failed.")
    return
  end
  ini.FileName = account .. "\\match_taolu.ini"
  if not ini:LoadFromFile() then
    local error_info = "load ini failed. FileName is " .. ini.FileName
    record_oper_info(1, error_info)
  end
  for i = 1, table.maxn(cbox_taolu_list) do
    local ctaolu = nx_string(form.limit_id) .. "_" .. nx_string(cbox_taolu_list[i])
    if ctaolu ~= "" then
      local taolu_1 = ini:ReadString(nx_string(ctaolu), "taolu1", "")
      local taolu_2 = ini:ReadString(nx_string(ctaolu), "taolu2", "")
      local taolu_3 = ini:ReadString(nx_string(ctaolu), "taolu3", "")
      Add_taolu(ctaolu .. "_1", nx_string(taolu_1))
      Add_taolu(ctaolu .. "_2", nx_string(taolu_2))
      Add_taolu(ctaolu .. "_3", nx_string(taolu_3))
    end
  end
  nx_destroy(ini)
end
function Add_taolu(section, values)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return false
  end
  if not common_array:FindArray(array_name) then
    local error_info = "Add_taolu Oper FindArray failed. array_name is " .. array_name
    record_oper_info(1, error_info)
    return false
  end
  common_array:RemoveChild(array_name, nx_string(section))
  return common_array:AddChild(array_name, nx_string(section), nx_string(values))
end
function Get_taolu(section)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return ""
  end
  if not common_array:FindArray(array_name) then
    local error_info = "Get_taolu oper FindArray failed. array_name is " .. array_name
    record_oper_info(1, error_info)
    return ""
  end
  if common_array:FindChild(array_name, nx_string(section)) == "" then
    record_oper_info(1, "get taolu is null. taolu_section is " .. section)
  end
  return common_array:FindChild(array_name, nx_string(section))
end
function get_now_group_index(form)
  local text = nx_widestr(form.cbox_taolu.DropListBox:GetString(form.cbox_taolu.DropListBox.SelectIndex))
  for i = 1, table.maxn(cbox_taolu_list) do
    local group = nx_string(cbox_taolu_list[i])
    local _text = util_text(group)
    if text == _text then
      return group
    end
  end
  local error_info = "Get text is " .. nx_string(text) .. ". DropListBox SelectIndex is " .. nx_string(form.cbox_taolu.DropListBox.SelectIndex)
  record_oper_info(1, error_info)
  return ""
end
function record_oper_info(msgType, msg_info)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RECEIVE_LOG_MSG), nx_int(msgType), nx_string(msg_info))
end
