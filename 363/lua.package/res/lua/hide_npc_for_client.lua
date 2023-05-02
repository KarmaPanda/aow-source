require("util_functions")
local g_hided_npc = {}
function hide_npc(npc_ident)
  local sceneobj = nx_value("scene_obj")
  sceneobj:RemoveObject(nx_string(npc_ident))
end
function is_hide_npc(player, npcIdent)
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(npcIdent)
  if not nx_is_valid(npc) then
    return false
  end
  local str = npc:QueryProp("ConfigID")
  if str == "" or str == "0" then
    return false
  end
  if not player:FindRecord("Task_Hide_Rec") then
    return false
  end
  local row = player:FindRecordRow("Task_Hide_Rec", 2, str, "")
  if row < 0 then
    return false
  end
  if g_hided_npc[str] == nil then
    g_hided_npc[str] = {}
  end
  local len = table.getn(g_hided_npc)
  nx_msgbox(nx_string(len))
  for i = 1, len do
    if string(g_hided_npc[str][i]) == nx_string(str) then
      return true
    end
  end
  g_hided_npc[str][len + 1] = nx_string(npcIdent)
  return true
end
function show_or_hide_npc(type, str)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_client) or not nx_is_valid(game_visual) then
    return
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  local sceneobj = nx_value("scene_obj")
  if type == "show" then
    local showList = util_split_string(str, ",")
    for i, id in pairs(showList) do
      if id ~= nil and id ~= "" and g_hided_npc[id] ~= nil then
        local c = g_hided_npc[id]
        local len = table.getn(c)
        for j = 1, len do
          local ident = c[j]
          local old_vis_obj = game_visual:GetSceneObj(ident)
          if not nx_is_valid(old_vis_obj) then
            sceneobj:AddObject(nx_string(ident))
          end
        end
      end
    end
  elseif type == "hide" then
    local list = {}
    get_npc_obj(list, str)
    local len = table.getn(list)
    for i = 1, len do
      sceneobj:RemoveObject(nx_string(list[i]))
    end
  end
end
function get_npc_obj(list, npcConfig)
  local game_client = nx_value("game_client")
  local game_scene = game_client:GetScene()
  local client_obj_lst = game_scene:GetSceneObjList()
  if not nx_is_valid(game_client) then
    return
  end
  for i, client_obj in pairs(client_obj_lst) do
    local npc = game_client:GetSceneObj(nx_string(client_obj.Ident))
    if nx_is_valid(npc) then
      local str = npc:QueryProp("ConfigID")
      if str == npcConfig then
        local len = table.getn(list)
        list[len + 1] = nx_string(client_obj.Ident)
        local bReg = false
        if g_hided_npc[str] == nil then
          g_hided_npc[str] = {}
        end
        local len = table.getn(g_hided_npc)
        for i = 1, len do
          if string(g_hided_npc[str][i]) == nx_string(str) then
            bReg = true
            break
          end
        end
        if not bReg then
          g_hided_npc[str][len + 1] = client_obj.Ident
        end
      end
    end
  end
end
function show_hide_npc(npc_ident)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local game_scene = game_client:GetScene()
  local client_obj_lst = game_scene:GetSceneObjList()
  for i, client_obj in pairs(client_obj_lst) do
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    if nx_is_valid(visual_obj) and nx_string(client_obj.Ident) == nx_string(npc_ident) then
      return
    end
  end
  local delay = 1
  local slice = 0.01
  while 0 < delay do
    nx_pause(slice)
    delay = delay - slice
  end
  local sceneobj = nx_value("scene_obj")
  sceneobj:AddObject(nx_string(npc_ident))
end
