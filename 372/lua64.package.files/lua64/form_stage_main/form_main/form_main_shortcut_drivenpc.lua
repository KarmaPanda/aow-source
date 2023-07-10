require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\client_custom_define")
CANNON_BUFF = "buf_CannonNpc0001"
function main_form_init(self)
  self.Fixed = false
  self.no_need_motion_alpha = true
  return 1
end
function on_main_form_open(self)
  refresh_form(self, nx_null())
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.Left = (gui.Width - self.Width) / 2
  self.Top = gui.Height - self.Height - 180
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("custom_sender", "custom_remove_buffer", form.buff_id)
    form:Close()
  end
end
function refresh_form(form, npc)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_machine_obj = game_client:GetSceneObj(nx_string(npc))
  if not nx_is_valid(client_machine_obj) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local grid = form.imagegrid_1
  grid.Npc = 0
  grid.CloseIndex = 0
  local config_id = queryprop_by_object(client_machine_obj, "ConfigID")
  local npc_photo = queryprop_by_object(client_machine_obj, "Photo")
  if npc_photo ~= nil and npc_photo ~= "" then
    form.lbl_head.BackImage = npc_photo
  end
  local buff_id = queryprop_by_object(client_machine_obj, "AddBufferID")
  form.buff_id = CANNON_BUFF
  if buff_id ~= nil or buff_id ~= "" then
    form.buff_id = buff_id
  end
  grid.Npc = client_machine_obj
  local item_query = nx_value("ItemQuery")
  local SkillRec = item_query:GetItemPropByConfigID(config_id, "table@SkillRec")
  local skill_list = util_split_string(SkillRec, ";")
  if nx_number(table.getn(skill_list)) <= nx_number(0) then
    form:Close()
    return
  end
  skill_list[1] = string.gsub(skill_list[1], "\"", "")
  local index = 0
  for i = 1, table.getn(skill_list) do
    local skill_id = util_split_string(skill_list[i], ",")
    if skill_id[1] ~= nx_string("default_normal_skill") then
      local skill_ini = nx_execute("util_functions", "get_ini", "share\\skill\\skill_new.ini")
      if not nx_is_valid(skill_ini) then
        return
      end
      local static_data = skill_ini:ReadInteger(nx_string(skill_id[1]), nx_string("StaticData"), 0)
      local photo = nx_execute("util_static_data", "skill_static_query_by_id", skill_id[1], "Photo")
      local cooltype = skill_static_query(static_data, "CoolDownCategory")
      local name = gui.TextManager:GetText(nx_string(skill_id[1]))
      grid:AddItem(nx_int(index), photo, name, nx_int(0), i - 1)
      nx_set_custom(grid, "skill_config_" .. nx_string(index), nx_string(skill_id[1]))
      if 0 < nx_number(cooltype) then
        grid:SetCoolType(nx_int(index), nx_int(cooltype))
      end
      index = index + 1
    end
  end
  grid.CloseIndex = index
  form.imagegrid_1.Width = index * 60 - 2
  form.lbl_s_back.Width = form.imagegrid_1.Width + 24
  form.btn_close.Left = form.lbl_s_back.Left + form.lbl_s_back.Width - 16
  form.gbox_skill.Width = form.lbl_s_back.Width + 100
  form.Width = form.lbl_s_back.Width + 100
end
function on_select_changed(grid, index)
  on_rightclick_grid(grid, index)
end
function on_rightclick_grid(grid, index)
  if not nx_find_custom(grid, "CloseIndex") or not nx_find_custom(grid, "Npc") then
    return
  end
  if index == grid.CloseIndex then
    local form = grid.ParentForm
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return 0
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_STOP_BIND))
    form:Close()
    return
  end
  if not nx_find_custom(grid, "skill_config_" .. nx_string(index)) then
    return
  end
  local skillid = nx_custom(grid, "skill_config_" .. nx_string(index))
  local drivenpc = nx_value("DriveNpcMgr")
  if not nx_is_valid(drivenpc) then
    return
  end
  drivenpc:UseDriveNpcSkill(skillid)
end
function on_mousein_grid(grid, index)
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local gui = nx_value("gui")
  local client_machine_obj = grid.Npc
  if not nx_is_valid(client_machine_obj) or not nx_is_valid(gui) then
    return
  end
  if not nx_find_custom(grid, "skill_config_" .. nx_string(index)) then
    return
  end
  local skillid = nx_custom(grid, "skill_config_" .. nx_string(index))
  local tip_text = gui.TextManager:GetText(nx_string("desc_") .. nx_string(skillid))
  nx_execute("tips_game", "show_text_tip", nx_widestr(tip_text), x, y, 0, grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function server_drivernpc_op(npc, open_flag)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if open_flag == 1 then
    nx_set_custom(client_player, "BandDriveNpc", npc)
    local drivenpc = nx_value("DriveNpcMgr")
    if not nx_is_valid(drivenpc) then
      return
    end
    local npcobj = game_client:GetSceneObj(nx_string(npc))
    if nx_is_valid(npcobj) and nx_int(npcobj:QueryProp("NpcType")) == nx_int(714) then
      drivenpc:SetDriveMode(3)
    else
      drivenpc:SetDriveMode(1)
    end
    begin_control_drivenpc_form(npc)
  elseif open_flag == 0 then
    end_control_drivenpc_form()
    local drivenpc = nx_value("DriveNpcMgr")
    if not nx_is_valid(drivenpc) then
      return
    end
    drivenpc:FinishDriveNpcControl()
  end
end
function begin_control_drivenpc_form(npc)
  local ItemQuery = nx_value("ItemQuery")
  local game_client = nx_value("game_client")
  local npcobj = game_client:GetSceneObj(nx_string(npc))
  local config_id = queryprop_by_object(npcobj, "ConfigID")
  local turn_angel = nx_number(ItemQuery:GetItemPropByConfigID(config_id, "TurnAngel"))
  if turn_angel ~= 0 then
    util_show_form("form_stage_main\\form_gunman", true)
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_shortcut_drivenpc", true, false)
  if nx_is_valid(form) then
    form.Visible = true
    form:Show()
    nx_execute("form_stage_main\\form_main\\form_main_shortcut_drivenpc", "refresh_form", form, npc)
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = false
  shortcut_grid.old_visible = false
  local dota_skill = nx_value("form_stage_main\\form_guild_dota\\form_guild_dota_skill")
  if nx_is_valid(dota_skill) then
    dota_skill.Visible = false
  end
end
function end_control_drivenpc_form()
  util_show_form("form_stage_main\\form_gunman", false)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_shortcut_drivenpc", false, false)
  if nx_is_valid(form) then
    form:Close()
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  local itemskill_shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
  local buff_common_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut_buff_common")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  local dota_skill = nx_value("form_stage_main\\form_guild_dota\\form_guild_dota_skill")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindProp("DotaSceneID") or client_player:QueryProp("DotaSceneID") <= 0 then
    shortcut_grid.Visible = true
  elseif nx_is_valid(dota_skill) then
    shortcut_grid.Visible = false
    dota_skill.Visible = true
  end
  if nx_is_valid(itemskill_shortcut_grid) and itemskill_shortcut_grid.Visible == true then
    shortcut_grid.Visible = false
  end
  if nx_is_valid(buff_common_grid) and buff_common_grid.Visible == true and buff_common_grid.isclose_shortgrid == 0 and buff_common_grid.isclose_shortgrid == 0 then
    shortcut_grid.Visible = false
  end
  shortcut_grid.old_visible = true
end
