require("const_define")
require("util_functions")
require("share\\npc_type_define")
require("link")
function Meet_npc_move(link_ident, ident)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_is_valid(game_visual) then
    return
  end
  local obj_target = game_client:GetSceneObj(link_ident)
  local vis_role = game_client:GetSceneObj(ident)
  local vis_target = game_visual:GetSceneObj(link_ident)
  while true do
    nx_pause(0)
    if nx_is_valid(obj_target) and nx_is_valid(vis_target) and nx_is_valid(vis_role) then
      break
    end
  end
  if nx_is_valid(obj_target) and nx_is_valid(vis_target) and obj_target:QueryProp("NpcType") == NpcType45 then
    vis_target.npc_index = math.random(1, 3)
    local config_id = obj_target:QueryProp("ConfigID")
    local flag = string.sub(config_id, 1, 3) == "fb_"
    if flag then
      vis_target.npc_index = 0
    end
    local resource = obj_target:QueryProp("Resource")
    vis_target.is_zhufa = string.find(resource, "zhufa")
    link_driver(link_ident)
    if not flag then
      link_JY_npc(link_ident, ident)
    end
    if not nx_is_valid(obj_target) then
      return
    end
    if obj_target:QueryProp("IsRun") == 1 then
      local trans_tool_npc_manager = nx_value("TransToolNpcManager")
      trans_tool_npc_manager:Init_Data(link_ident, ident)
    end
  end
end
