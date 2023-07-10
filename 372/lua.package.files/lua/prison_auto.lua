require("const_define")
require("role_composite")
function link_prisoner_npc(link_ident, prisoner_names)
  local world = nx_value("world")
  local scene = world.MainScene
  if not nx_is_valid(scene) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_visual) or not nx_is_valid(game_client) then
    return 0
  end
  local vis_target = game_visual:GetSceneObj(link_ident)
  local obj_target = game_client:GetSceneObj(link_ident)
  while true do
    nx_pause(0)
    vis_target = game_visual:GetSceneObj(link_ident)
    obj_target = game_client:GetSceneObj(link_ident)
    if not nx_is_valid(obj_target) then
      break
    end
    if nx_is_valid(vis_target) and vis_target.LoadFinish then
      break
    end
  end
  if not nx_is_valid(vis_target) or not nx_is_valid(obj_target) then
    return 0
  end
  local name_tab = nx_function("ext_split_wstring", prisoner_names, ",")
  for i = 1, math.min(5, table.getn(name_tab)) do
    local actor2 = scene:Create("Actor2")
    if not nx_is_valid(actor2) then
      return 0
    end
    actor2.scene = scene
    actor2.AsyncLoad = true
    load_from_ini(actor2, "ini\\npc\\fbnpc00490.ini")
    if not nx_is_valid(actor2) then
      return 0
    end
    if nx_is_valid(vis_target) then
      vis_target:LinkToPoint(nx_string(name_tab[i]), "MaChe01_" .. nx_string(i), actor2)
      actor2:BlendAction("ty_interact376", true, false)
      actor2.text_name = name_tab[i]
      actor2.prisoner_npc = true
      actor2.show_head_text = true
      nx_execute("head_game", "create_client_npc_head", actor2)
    else
      scene:Delete(actor2)
    end
  end
end
