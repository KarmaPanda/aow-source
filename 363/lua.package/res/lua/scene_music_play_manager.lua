require("util_functions")
function init(scene_music_play_manager)
  nx_callback(scene_music_play_manager, "on_load_finished", "on_load_finished")
  nx_callback(scene_music_play_manager, "on_again_random_scene_music", "on_again_random_scene_music")
end
function on_load_finished(music_name)
end
function on_again_random_scene_music(scene_music_play_manager, music_name)
  if string.find(nx_string(music_name), "main_scene_music_") then
    player_scene_music()
  end
end
function player_scene_music()
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local scene = world.MainScene
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local scene_res_name = client_scene:QueryProp("Resource")
  local sceneid = client_scene:QueryProp("ConfigID")
  if string.find(sceneid, "war") ~= nil then
    local i, j = string.find(sceneid, "ini\\scene\\")
    local music_index_name = string.sub(sceneid, j + 1)
    nx_execute("util_functions", "play_music", scene, "scene", music_index_name)
  else
    nx_execute("util_functions", "play_scene_random_music", scene, "scene", scene_res_name)
  end
end
