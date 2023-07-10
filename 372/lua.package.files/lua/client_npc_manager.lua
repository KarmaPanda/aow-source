require("util_functions")
require("share\\logicstate_define")
require("role_composite")
function create_scene_npc(terrain, res_name)
  local world = nx_value("world")
  local scene = terrain.scene
  local actor2 = nx_null()
  if res_name ~= nil and string.len(res_name) > 0 then
    actor2 = create_actor2(scene)
    if not nx_is_valid(actor2) then
      return 0
    end
    actor2.AsyncLoad = true
    local result = load_from_ini(actor2, "ini\\" .. res_name .. ".ini")
    if not result then
      scene:Delete(actor2)
      return nx_null()
    end
  end
  return actor2
end
function init(manager)
  nx_callback(manager, "on_npc_create", "on_npc_create")
  nx_callback(manager, "on_npc_delete", "on_npc_delete")
end
function on_npc_create(manager, name, resource, nameid, info)
  local actor2 = create_scene_npc(manager.Terrain, resource)
  if nx_is_valid(actor2) then
    actor2.Color = "0,255,255,255"
    manager:SetNpcModel(name, actor2)
    actor2.name = nameid
    actor2.info = info
    if nx_string(info) == "" then
      return 1
    end
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(20000, -1, nx_current(), "self_add_heart", actor2, -1, -1)
    end
  end
  return 1
end
function self_add_heart(actor2)
  if nx_is_valid(actor2) then
    local headgame = nx_value("HeadGame")
    nx_execute("head_game", "create_client_npc_head", actor2)
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText(actor2.info)
    headgame:ShowClientNpcChatTextOnHead(actor2, text, 5000)
  end
end
function on_npc_delete(manager, name, model)
  local scene = manager.Terrain.scene
  if nx_is_valid(model) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "self_add_heart", model)
    end
    scene:Delete(model)
  end
end
