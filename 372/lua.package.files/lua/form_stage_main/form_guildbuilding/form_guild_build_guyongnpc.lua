require("util_functions")
local NPC_EMPLOY_ROLE_PATH = "share\\Guild\\GuildFuncNpc\\guildfuncnpc_employ_rule.ini"
local pos_list = {}
local KEY_LIST = {
  RemoveType = 1,
  CapitalType1 = 1,
  FuncType = 1,
  EmployTime = 1,
  Resource = 1,
  Contribution = 1,
  GuildLevel = 1,
  GuildHotness = 1
}
function main_form_init(form)
  form.Fixed = false
  form.ini = load_ini(nx_resource_path() .. NPC_EMPLOY_ROLE_PATH)
  form.npcid = ""
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  if nx_find_custom(form, "npc_id") then
    local npc_id = nx_string(form.npc_id)
    if npc_id ~= "" then
      local game_client = nx_value("game_client")
      local npc = game_client:GetSceneObj(npc_id)
      if nx_is_valid(npc) then
        local config_id = npc:QueryProp("ConfigID")
        local resource = npc:QueryProp("Resource")
        refresh_employ_npc(form, npc, config_id, resource)
      end
    end
  end
end
function on_main_form_close(form)
  if nx_find_custom(form, "actor2") and nx_is_valid(form.actor2) then
    form.scenebox_1.Scene:Delete(form.actor2)
  end
  nx_execute("scene", "delete_scene", form.scenebox_1.Scene)
  if nx_is_valid(form.ini) then
    nx_destroy(form.ini)
  end
  nx_destroy(form)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_employ_click(btn)
  local form = btn.ParentForm
  local select_index = form.combobox_pos.DropListBox.SelectIndex
  if select_index == -1 then
    nx_msgbox(nx_string("not select_index"))
    return
  end
  local pos = pos_list[select_index + 1]
  if pos == nil then
    nx_msgbox(nx_string("no pos"))
    return
  end
  if nx_find_custom(form, "npc_id") then
    local npc_id = nx_string(form.npc_id)
    if npc_id ~= "" then
      if btn.free_num ~= nil and nx_int(btn.free_num) > nx_int(0) then
        nx_execute("custom_sender", "custom_guildbuilding_employ_npc", npc_id, pos)
      else
        local gui = nx_value("gui")
        local info = nx_widestr(gui.TextManager:GetFormatText("19282"))
        local form_main_chat_logic = nx_value("form_main_chat")
        if nx_is_valid(form_main_chat_logic) then
          form_main_chat_logic:AddChatInfoEx(info, 1, false)
        end
      end
      form:Close()
    end
  end
end
function on_combobox_pos_selected(self)
  local form = self.ParentForm
  local select_index = form.combobox_pos.DropListBox.SelectIndex
  if select_index == -1 then
    return
  end
  form.lbl_employ_info.Visible = false
  local pos = pos_list[select_index + 1]
  if pos ~= nil then
    nx_execute("custom_sender", "custom_query_employ_info", pos, form.npc_id)
  end
end
function load_ini(path)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(path)
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return nx_null()
  end
  return ini
end
function refresh_employ_npc(form, npc, npc_id, resource)
  if not nx_is_valid(form.ini) then
    return
  end
  if npc_id == nil or npc_id == "" then
    return
  end
  local name = npc_id
  local employ_time = form.ini:ReadString(npc_id, "EmployTime", "")
  local func_type = form.ini:ReadString(npc_id, "FuncType", "")
  local contribution = form.ini:ReadString(npc_id, "Contribution", "")
  local conditon_list = {}
  local remove_type = form.ini:ReadString(npc_id, "RemoveType", "")
  conditon_list.CapitalType0 = form.ini:ReadString(npc_id, "CapitalType0", "")
  conditon_list.CapitalType1 = form.ini:ReadString(npc_id, "CapitalType1", "")
  conditon_list.GuildLevel = form.ini:ReadString(npc_id, "GuildLevel", "")
  conditon_list.GuildHotness = form.ini:ReadString(npc_id, "GuildHotness", "")
  local other_prop = {}
  local item_list = form.ini:GetItemList()
  for i = 1, table.getn(item_list) do
    local item_key = item_list[i]
    local item_value = form.ini:ReadString(npc_id, item_key, "")
    if item_value ~= "" and KEY_LIST[item_value] == nil then
      other_prop[item_key] = item_value
    end
  end
  hide_prop_control(form)
  local gui = nx_value("gui")
  form.lbl_name.Text = nx_widestr(gui.TextManager:GetText(name))
  form.lbl_prop_1.Text = nx_widestr(gui.TextManager:GetFormatText("ui_EmployTime", nx_int(employ_time)))
  form.lbl_contribution.Text = nx_widestr(contribution)
  form.mltbox_NPC_desc.HtmlText = nx_widestr(gui.TextManager:GetText("desc_" .. string.lower(npc_id)))
  form.lbl_11.Text = nx_widestr(form.ini:ReadString(npc_id, "nFacultyAdd", ""))
  form.lbl_12.Text = nx_widestr(nx_int(form.ini:ReadString(npc_id, "nLivePointAdd", "")) / 1000)
  form.lbl_13.Text = nx_widestr(form.ini:ReadString(npc_id, "nLiveBuffLevelAdd", ""))
  form.lbl_14.Text = nx_widestr(nx_int(form.ini:ReadString(npc_id, "nLifeExpAdd", "")) * 10 .. "%")
  for i, v in pairs(other_prop) do
    local lbl_control = form:Find("lbl_prop_" .. nx_string(i + 1))
    if nx_is_valid(lbl_control) then
      lbl_control.Text = nx_widestr(gui.TextManager:GetFormatText("ui_" .. i, nx_int(v)))
      lbl_control.Visible = true
    end
  end
  local control_index = 1
  for i, v in pairs(conditon_list) do
    if v ~= "" then
      local lbl_control = form:Find("lbl_condition_" .. nx_string(control_index))
      if nx_is_valid(lbl_control) then
        if i == "CapitalType0" then
          local liang = nx_int(v / 1000)
          lbl_control.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_" .. i, nx_int(liang))) .. nx_widestr("<img src=\"gui\\common\\money\\jyb.png\" valign=\"center\" only=\"line\" data=\"\" />")
        elseif i == "CapitalType1" then
          local liang = nx_int(v / 1000)
          lbl_control.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_" .. i, nx_int(liang))) .. nx_widestr("<img src=\"gui\\common\\money\\liang.png\" valign=\"center\" only=\"line\" data=\"\" />")
        else
          lbl_control.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_" .. i, nx_int(v)))
        end
        lbl_control.Visible = true
        control_index = control_index + 1
      end
    end
  end
  pos_list = {}
  form.combobox_pos.DropListBox:ClearString()
  form.combobox_pos.DropListBox.SelectIndex = -1
  form.combobox_pos.InputEdit.Text = nx_widestr("")
  pos_list = util_split_string(func_type, ",")
  show_building_name(form, npc, pos_list)
  if nx_find_custom(form, "actor2") and nx_is_valid(form.actor2) then
    nx_execute("util_gui", "ui_ClearModel", form.scenebox_1)
  end
  if not nx_running(nx_current(), "form_showrole") then
    nx_execute(nx_current(), "form_showrole", form, npc, resource)
  end
end
function refresh_employ_info(form, sub_type, already_num, max_num)
  if sub_type == nil or already_num == nil or max_num == nil then
    return
  end
  local select_index = form.combobox_pos.DropListBox.SelectIndex
  if select_index == -1 then
    return
  end
  local gui = nx_value("gui")
  local free_num = nx_number(max_num) - nx_number(already_num)
  form.btn_employ.free_num = free_num
  form.lbl_employ_info.Text = nx_widestr(gui.TextManager:GetFormatText("ui_guyong_shuliang", nx_int(free_num), nx_int(max_num)))
  form.lbl_employ_info.Visible = true
end
function hide_prop_control(form)
  form.lbl_prop_2.Visible = false
  form.lbl_prop_3.Visible = false
  form.lbl_prop_4.Visible = false
  form.lbl_prop_5.Visible = false
  form.lbl_prop_6.Visible = false
  form.lbl_prop_7.Visible = false
  form.lbl_prop_8.Visible = false
  form.lbl_condition_1.Visible = false
  form.lbl_condition_2.Visible = false
  form.lbl_condition_3.Visible = false
  form.lbl_condition_4.Visible = false
  form.lbl_condition_5.Visible = false
  form.lbl_condition_6.Visible = false
  form.lbl_condition_7.Visible = false
  form.lbl_condition_8.Visible = false
  form.lbl_employ_info.Visible = false
end
function form_showrole(form, npc, resource)
  if resource == "" then
    return
  end
  if not nx_is_valid(form.scenebox_1.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_1)
  end
  local scene = form.scenebox_1.Scene
  if not nx_is_valid(scene) then
    return
  end
  local actor2 = nx_execute("role_composite", "create_actor2", scene)
  if not nx_is_valid(actor2) then
    scene:Delete(actor2)
    return
  end
  actor2.AsyncLoad = true
  actor2.scene = scene
  nx_execute("role_composite", "load_from_ini", actor2, "ini\\" .. nx_string(resource) .. ".ini")
  while true do
    if not nx_is_valid(actor2) or actor2.LoadFinish then
      break
    end
    nx_pause(0.1)
  end
  if not nx_is_valid(actor2) then
    scene:Delete(actor2)
    return
  end
  if not nx_is_valid(form) then
    return
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_1, actor2)
  form.actor2 = actor2
  local game_visual = nx_value("game_visual")
  local visual_obj = game_visual:GetSceneObj(npc.Ident)
  local action_module = nx_value("action_module")
  game_visual:SetRoleWeaponMode(actor2, game_visual:QueryRoleWeaponMode(visual_obj))
  game_visual:SetRoleStateOld(actor2, "")
  local visual_obj_type = game_visual:QueryRoleType(visual_obj)
  game_visual:SetRoleType(actor2, visual_obj_type)
  game_visual:SetRoleCreateFinish(actor2, true)
  action_module:ChangeState(actor2, "stand", true)
end
function show_building_name(form, npc, pos_list)
  local gui = nx_value("gui")
  if not nx_is_valid(npc) then
    return 0
  end
  local ui_pos = ""
  local guild_func_type = npc:QueryProp("GuildFuncType")
  if guild_func_type == 4 then
    ui_pos = "ui_guyong_pos_"
  elseif guild_func_type == 6 then
    ui_pos = "ui_employ_pos_"
  else
    return 0
  end
  for i = 1, table.getn(pos_list) do
    local pos_info = nx_widestr(gui.TextManager:GetText(ui_pos .. pos_list[i]))
    local index = form.combobox_pos.DropListBox:AddString(pos_info)
    if index == 0 then
      form.combobox_pos.DropListBox.SelectIndex = 0
      form.combobox_pos.InputEdit.Text = form.combobox_pos.DropListBox.SelectString
      on_combobox_pos_selected(form.combobox_pos)
    end
  end
  return 1
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if form.groupbox_2.Visible then
    form.groupbox_2.Visible = false
  else
    form.groupbox_2.Visible = true
  end
end
