require("util_functions")
require("util_vip")
require("define\\request_type")
require("define\\team_rec_define")
require("form_stage_main\\form_team\\team_util_functions")
require("tips_data")
require("util_gui")
function hyperlink_manager_init(self)
  nx_callback(self, "on_click_hyperlink", "on_click_hyperlink")
  nx_callback(self, "on_mousein_hyperlink", "on_mousein_hyperlink")
  nx_callback(self, "on_mouseout_hyperlink", "on_mouseout_hyperlink")
  nx_callback(self, "on_doubleclick_hyperlink", "on_doubleclick_hyperlink")
  nx_callback(self, "on_right_click_hyperlink", "on_right_click_hyperlink")
end
function find_path_item(strData, click)
  local str_data = nx_string(strData)
  local wstr_data = nx_widestr(strData)
  if nx_function("ext_ws_find", wstr_data, nx_widestr("item,")) >= 0 then
    local param_table = nx_function("ext_split_wstring", wstr_data, nx_widestr(","))
    local count = table.maxn(param_table)
    if 2 < count then
      local playername = nx_widestr(param_table[2])
      local uniqueid = param_table[3]
      if playername == nil or nx_ws_length(playername) == 0 then
        local gui = nx_value("gui")
        local str_player = gui.TextManager:GetText("ui_player")
        nx_execute("custom_handler", "custom_sysinfo", "", 5, "sysinfo", 2, nx_string("7011"), str_player)
      else
        nx_set_value("look_item", true)
        nx_set_value("item_data", strData)
        nx_execute("custom_sender", "custom_chat_look_item", playername, nx_string(uniqueid))
        nx_execute("form_stage_main\\form_main\\form_main_chat", "set_tips_link_click", click)
      end
    elseif nx_int(count) == nx_int(2) then
      local id = nx_string(param_table[2])
      local item_query = nx_value("ItemQuery")
      if not nx_is_valid(item_query) then
        return
      end
      local item_type = nx_int(item_query:GetItemPropByConfigID(id, "ItemType"))
      local level = nx_int(item_query:GetItemPropByConfigID(id, "Level"))
      local sellPrice1 = nx_int(item_query:GetItemPropByConfigID(id, "sellPrice1"))
      local photo = nx_string(item_query:GetItemPropByConfigID(id, "Photo"))
      local array_list = nx_execute("tips_game", "get_tips_ArrayList")
      if not nx_is_valid(array_list) then
        return
      end
      array_list.ConfigID = id
      array_list.ItemType = item_type
      array_list.Level = level
      array_list.sellPrice1 = sellPrice1
      array_list.Photo = photo
      array_list.is_static = true
      local gui = nx_value("gui")
      if not nx_is_valid(gui) then
        return
      end
      local x, y = gui:GetCursorPosition()
      nx_execute("tips_game", "show_goods_tip", array_list, x, y, 32, 32)
    end
  end
end
function find_path_npc_item(strData, click)
  local fight = nx_value("fight")
  if nx_is_valid(fight) then
    fight:StopUseSkill()
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  local find_npc_id = ""
  local find_npc_x, find_npc_y, find_npc_z
  local find_scene_id = ""
  local str_data = string.gsub(nx_string(strData), " ", "")
  local wstr_data = nx_widestr(strData)
  local find_npc = false
  if nx_function("ext_ws_find", wstr_data, nx_widestr("findpath")) >= 0 then
    local param_table = util_split_string(str_data, ",")
    local count = table.maxn(param_table)
    if count == 4 then
      local scene_id = param_table[2]
      local x = nx_int(param_table[3])
      local z = nx_int(param_table[4])
      path_finding:FindPathScene(scene_id, x, -10000, z, 0)
      find_npc = true
    elseif 4 <= count then
      local scene_id = param_table[2]
      local x = nx_int(param_table[3])
      local y = nx_int(param_table[4])
      local z = nx_int(param_table[5])
      path_finding:FindPathScene(scene_id, x, y, z, 0)
      find_npc = true
    end
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("findnpc_new")) then
    local param_table = nx_function("ext_split_string", str_data, ",")
    local count = table.maxn(param_table)
    if 3 <= count then
      local scene_id = param_table[2]
      local npc_id = param_table[3]
      local x, y, z = find_npc_pos(scene_id, npc_id)
      if -10000 < nx_number(x) then
        if trace_flag == 1 then
          find_scene_id = scene_id
          find_npc_id = npc_id
          find_npc_x = x
          find_npc_y = y
          find_npc_z = z
          find_npc = true
          path_finding:TraceTargetByID(scene_id, nx_float(x), nx_float(y), nx_float(z), 1.8, npc_id)
        else
          find_scene_id = scene_id
          find_npc_id = npc_id
          find_npc_x = x
          find_npc_y = y
          find_npc_z = z
          find_npc = true
          path_finding:DrawToTarget(scene_id, nx_float(x), nx_float(y), nx_float(z), 1.8, npc_id)
        end
      else
        nx_msgbox("haven`t found this npc in creator scene_id=" .. scene_id .. " npc_id = " .. npc_id)
      end
    end
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("findnpc")) then
    local param_table = nx_function("ext_split_string", str_data, ",")
    local count = table.maxn(param_table)
    if count == 4 then
      local scene_id = param_table[2]
      local x = nx_int(param_table[3])
      local z = nx_int(param_table[4])
      local npc_id = param_table[5]
      if trace_flag == 1 then
        find_npc = true
        find_scene_id = scene_id
        find_npc_id = npc_id
        find_npc_x = x
        find_npc_y = y
        find_npc_z = z
        path_finding:FindPathScene(scene_id, x, -10000, z, 0)
      else
        find_npc = true
        find_npc_x = x
        find_npc_y = y
        find_npc_z = z
        find_scene_id = scene_id
        find_npc_id = npc_id
        path_finding:DrawToTarget(scene_id, nx_float(x), nx_float(-10000), nx_float(z), 0, "")
      end
    elseif 4 < count then
      local scene_id = param_table[2]
      local x = nx_int(param_table[3])
      local y = nx_int(param_table[4])
      local z = nx_int(param_table[5])
      local npc_id = param_table[6]
      if trace_flag == 1 then
        find_npc = true
        find_npc_x = x
        find_npc_y = y
        find_npc_z = z
        find_npc_id = npc_id
        find_scene_id = scene_id
        path_finding:FindPathScene(scene_id, x, y, z, 0)
      else
        find_npc = true
        find_npc_x = x
        find_npc_y = y
        find_npc_z = z
        find_npc_id = npc_id
        find_scene_id = scene_id
        path_finding:DrawToTarget(scene_id, nx_float(x), nx_float(y), nx_float(z), 0, "")
      end
    end
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("item,")) then
    local param_table = nx_function("ext_split_wstring", wstr_data, nx_widestr(","))
    local count = table.maxn(param_table)
    if 2 < count then
      local playername = nx_widestr(param_table[2])
      local uniqueid = param_table[3]
      if playername == nil or nx_ws_length(playername) == 0 then
        local gui = nx_value("gui")
        local str_player = gui.TextManager:GetText("ui_player")
        nx_execute("custom_handler", "custom_sysinfo", "", 5, "sysinfo", 2, nx_string("7011"), str_player)
      else
        nx_set_value("look_item", true)
        nx_execute("custom_sender", "custom_chat_look_item", playername, nx_string(uniqueid))
        nx_execute("form_stage_main\\form_main\\form_main_chat", "set_tips_link_click", click)
      end
    end
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("http:")) then
    nx_function("ext_open_url_ex", wstr_data, "")
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("team,")) then
    handle_recruit_operate(wstr_data)
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("teamfaculty,")) then
    handle_recruit_teamfaculty(wstr_data)
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("tarot,")) then
    handle_recruit_tarot(wstr_data)
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("guild_req_help,")) then
    local param_table = nx_function("ext_split_wstring", wstr_data, nx_widestr(","))
    local count = table.maxn(param_table)
    if 4 <= count then
      local playername = nx_widestr(param_table[2])
      local uniqueid = param_table[3]
      local trans_cost = nx_string(param_table[4])
      local trans_cd_time = nx_string(param_table[5])
      local CLIENT_CUSTOMMSG_GUILD = 1014
      local SUB_CUSTOMMSG_GUILD_TRANS_TO_REQHELPER = 100
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return 0
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_TRANS_TO_REQHELPER), playername, uniqueid, nx_int(0), trans_cost, trans_cd_time)
    end
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("zpsb,")) then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return 0
    end
    local school = client_player:QueryProp("School")
    local SchoolID = nx_int(get_ini_prop("share\\War\\School_Config.ini", school, "ID", ""))
    if SchoolID < nx_int(1) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("83552"))
      return 0
    end
    local form = util_get_form("form_stage_main\\form_school_war\\form_school_msg_info", true)
    if form.Visible == false then
      nx_execute("custom_sender", "custom_get_school_msg_info", SchoolID, 0)
      form.SchoolID = SchoolID
      util_show_form("form_stage_main\\form_school_war\\form_school_msg_info", true)
      nx_execute("form_stage_main\\form_school_war\\form_school_msg_info", "show_schoolface_contest", form)
    else
      form:Close()
    end
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("newpacket,")) then
    local param_table = nx_function("ext_split_wstring", wstr_data, nx_widestr(","))
    local count = table.maxn(param_table)
    if 2 <= count then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return 0
      end
      local unique_id_wx = nx_widestr(param_table[2])
      local unique_id = nx_string(unique_id_wx)
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_PACKET), nx_int(5), nx_string(unique_id))
    end
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("drop_item_tips,")) then
    return
  end
  if find_npc then
    find_npc_id = find_npc_id or ""
    find_scene_id = find_scene_id or ""
    find_npc_id = nx_string(find_npc_id)
    find_npc_x = nx_number(find_npc_x)
    find_npc_y = nx_number(find_npc_y)
    find_npc_z = nx_number(find_npc_z)
    find_scene_id = nx_string(find_scene_id)
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      local visual_player = game_visual:GetPlayer()
      if nx_is_valid(visual_player) then
        local pos_x, pos_z = visual_player.PositionX, visual_player.PositionZ
        local dis_x = nx_number(pos_x) - nx_number(find_npc_x)
        local dis_z = nx_number(pos_z) - nx_number(find_npc_z)
        local dis = dis_x * dis_x + dis_z * dis_z
        if trace_flag == 2 then
          if 500 < dis then
            local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
            if not nx_is_valid(form_map) or nx_is_valid(form_map) and not form_map.Visible then
              nx_execute("form_stage_main\\form_map\\form_map_scene", "auto_show_hide_map_scene")
            end
          elseif nx_is_valid(path_finding) then
            path_finding:FindPathScene(find_scene_id, find_npc_x, -10000, find_npc_z, 0)
          end
        elseif trace_flag == 3 then
          local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
          if not nx_is_valid(form_map) or nx_is_valid(form_map) and not form_map.Visible then
            nx_execute("form_stage_main\\form_map\\form_map_scene", "auto_show_hide_map_scene")
          end
        end
      end
      nx_execute("form_stage_main\\form_main\\form_main_map", "set_trace_npc_id", find_npc_id, find_npc_x, find_npc_z, find_scene_id)
      nx_execute("form_stage_main\\form_map\\form_map_scene", "set_trace_npc_id", find_npc_id, find_npc_x, find_npc_y, find_npc_z, find_scene_id)
    end
  end
end
function find_npc_pos(scene_id, search_npc_id)
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    local res = mgr:GetNearestNpcPos(scene_id, search_npc_id)
    if res ~= nil and table.getn(res) == 3 then
      return res[1], res[2], res[3]
    end
  end
  return -10000, -10000, -10000
end
function add_map_label_by_hyerlink(szLinkData)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  szLinkData = string.gsub(nx_string(szLinkData), " ", "")
  local param_table = nx_function("ext_split_string", szLinkData, ",")
  local count = table.maxn(param_table)
  if count <= 0 then
    return
  end
  if param_table[1] == "label" then
    local text = gui.TextManager:GetText("ui_maplabel_tips5")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
      if not nx_is_valid(form_map) then
        return
      end
      nx_execute("form_stage_main\\form_map\\form_map_scene", "add_defined_label_byhtml", form_map, param_table[4], 0, param_table[5], param_table[6], param_table[2], param_table[3])
    end
  end
end
function on_click_hyperlink(self, szLinkData)
  add_map_label_by_hyerlink(szLinkData)
  find_path_npc_item(szLinkData, true)
end
function on_mousein_hyperlink(self, szLinkData)
  local str_data = string.gsub(nx_string(szLinkData), " ", "")
  local wstr_data = nx_widestr(szLinkData)
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    gui.GameHand:SetHand("hyperlink", "HyperLink", " ", " ", " ", " ")
  end
  if nx_function("ext_ws_find", wstr_data, nx_widestr("findnpc_new")) >= 0 then
    local param_table = nx_function("ext_split_string", str_data, ",")
    local count = table.maxn(param_table)
    if 3 <= count then
      local scene_id = param_table[2]
      local npc_id = param_table[3]
      local x, y, z = find_npc_pos(scene_id, npc_id)
      local scene_name = get_scene_name(scene_id)
      local gui = nx_value("gui")
      local mouse_x, mouse_z = gui:GetCursorPosition()
      nx_execute("tips_game", "show_text_tip", nx_widestr(scene_name) .. nx_widestr(nx_string(nx_int(x)) .. "," .. nx_string(nx_int(z))), mouse_x, mouse_z)
    end
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("findnpc")) then
    local infos = util_split_string(str_data, ",")
    local count = table.getn(infos)
    if count == 5 then
      local scene_id = infos[2]
      local x, z = infos[3], infos[5]
      local scene_name = get_scene_name(scene_id)
      local gui = nx_value("gui")
      local mouse_x, mouse_z = gui:GetCursorPosition()
      local tip = nx_widestr(scene_name) .. nx_widestr(nx_int(x)) .. nx_widestr(",") .. nx_widestr(nx_int(z))
      nx_execute("tips_game", "show_text_tip", nx_widestr(tip), mouse_x, mouse_z)
    end
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("label,")) then
    local param_table = nx_function("ext_split_wstring", wstr_data, nx_widestr(","))
    local count = table.maxn(param_table)
    local mouse_x, mouse_z = gui:GetCursorPosition()
    local str_name = id
    local str_scene_name = ""
    local pos_x = 0
    local pos_z = 0
    if 5 < count then
      str_name = param_table[2]
      str_scene_name = gui.TextManager:GetText("scene_" .. nx_string(param_table[3]))
      pos_x = param_table[4]
      pos_z = param_table[5]
    end
    local text = gui.TextManager:GetFormatText("<font color=\"#FFFFFF\">{@0:name}</font><br><font color=\"#B9B29F\">[{@1:scene}]</font><br><font color=\"#ED5F00\">({@2:x},{@3:y})</font>", nx_widestr(str_name), nx_widestr(str_scene_name), nx_int(pos_x), nx_int(pos_z))
    nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("label_tips,")) then
    local param_table = nx_function("ext_split_wstring", wstr_data, nx_widestr(","))
    local count = table.maxn(param_table)
    local mouse_x, mouse_z = gui:GetCursorPosition()
    local textid = nx_string(param_table[2])
    local text = util_text(textid)
    nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
  elseif 0 <= nx_function("ext_ws_find", wstr_data, nx_widestr("drop_item_tips,")) then
    local param_table = nx_function("ext_split_wstring", wstr_data, nx_widestr(","))
    local count = table.maxn(param_table)
    local mouse_x, mouse_z = gui:GetCursorPosition()
    local str_config_info = nx_string(param_table[2])
    local amount = nx_int(param_table[3])
    local bind = nx_int(param_table[4])
    local config_info = util_split_string(str_config_info, ":")
    local config_id = nx_string(config_info[2])
    nx_execute("tips_game", "show_tips_by_config_more", config_id, amount, bind, mouse_x, mouse_z, self)
    return
  end
  find_path_item(szLinkData, false)
end
function on_mouseout_hyperlink(self, szLinkData)
  local gui = nx_value("gui")
  if not gui.GameHand:IsEmpty() and gui.GameHand.Type == "hyperlink" then
    gui.GameHand:ClearHand()
  end
  nx_execute("tips_game", "hide_tip")
  nx_set_value("look_item", false)
end
function on_doubleclick_hyperlink(self, szLinkData)
  local param_table = nx_function("ext_split_string", szLinkData, ",")
  local count = table.maxn(param_table)
  if count <= 0 then
    return
  end
end
function on_right_click_hyperlink(self, szLinkData)
end
function get_scene_name(scene_id)
  local gui = nx_value("gui")
  return gui.TextManager:GetText(nx_string("ini\\scene\\scene_" .. nx_string(scene_id)))
end
function handle_recruit_operate(strData)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local data_list = util_split_wstring(nx_widestr(strData), ",")
  local player_name = data_list[2]
  local player_is_captain = nx_int(data_list[3]) == nx_int(1)
  local player_type = data_list[4]
  local player_mission = data_list[5]
  local self_name = client_player:QueryProp("Name")
  local self_is_captain = is_team_captain()
  local self_is_in_team = is_in_team()
  if nx_ws_equal(nx_widestr(self_name), nx_widestr(player_name)) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7356"))
    return
  end
  local bShowDialog = false
  local bPromptInvite = false
  if self_is_captain then
    if not player_is_captain then
      bShowDialog = true
      bPromptInvite = true
    else
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7357"))
      return
    end
  elseif self_is_in_team then
    if get_team_type() == TYPE_LARGE_TEAM and get_team_work() == 2 and not player_is_captain then
      bShowDialog = true
      bPromptInvite = true
    else
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7358"))
      return
    end
  elseif player_is_captain then
    bShowDialog = true
    bPromptInvite = false
  else
    bShowDialog = true
    bPromptInvite = true
  end
  if bShowDialog then
    local txtZhaomu = gui.TextManager:GetText("ui_Recruit")
    local txtXunzu = gui.TextManager:GetText("ui_SearchTeam")
    gui.TextManager:Format_SetIDName(bPromptInvite and "ui_zudui_zm2" or "ui_zudui_zm1")
    gui.TextManager:Format_AddParam(player_name)
    gui.TextManager:Format_AddParam(player_is_captain and txtZhaomu or txtXunzu)
    gui.TextManager:Format_AddParam(player_type)
    gui.TextManager:Format_AddParam(player_mission)
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, gui.TextManager:Format_GetText())
    dialog.lbl_1.Text = nx_widestr("@ui_zudui")
    dialog.ok_btn.Text = nx_widestr(bPromptInvite and "@ui_zudui0003" or "@ui_zudui0002")
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local result = nx_wait_event(100000000, dialog, "confirm_return")
    if result == "ok" then
      if bPromptInvite then
        nx_execute("custom_sender", "custom_team_invite", player_name)
      else
        nx_execute("custom_sender", "custom_team_request_join", player_name)
      end
    end
  end
end
function handle_recruit_teamfaculty(strData)
  local data_list = util_split_wstring(nx_widestr(strData), ",")
  if table.getn(data_list) < 2 then
    return
  end
  local player_name = data_list[2]
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if nx_ws_equal(nx_widestr(client_player:QueryProp("Name")), nx_widestr(player_name)) == true then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("8078"), 2)
    end
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(nx_string("ui_confir_join_facultyteam"), nx_string(player_name))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if result == "ok" then
    nx_execute("custom_sender", "custom_request", REQUESTTYPE_JOIN_FACULTY, nx_widestr(player_name))
  end
end
function handle_recruit_tarot(strData)
  local data_list = util_split_wstring(nx_widestr(strData), ",")
  if table.getn(data_list) < 3 then
    return
  end
  local player_name = data_list[2]
  local id = nx_number(data_list[3])
  nx_execute("form_stage_main\\form_tarot\\form_tarot_look", "look", player_name, id)
end
function is_have_hyperlink(strData)
  if string.find(strData, "findpath") then
    return true
  elseif string.find(strData, "findnpc_new") then
    return true
  elseif string.find(strData, "findnpc") then
    return true
  elseif string.find(strData, "item,") then
    return true
  elseif string.find(strData, "http:") then
    return true
  end
  return false
end
