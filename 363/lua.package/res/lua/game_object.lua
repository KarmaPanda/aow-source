function get_client_scene()
  local client = nx_value("game_client")
  return client:GetScene()
end
function is_client_player(ident)
  local client = nx_value("game_client")
  return client:IsPlayer(ident)
end
function get_client_player()
  local client = nx_value("game_client")
  return client:GetPlayer()
end
function get_client_scene_obj(ident)
  local client = nx_value("game_client")
  return client:GetSceneObj(ident)
end
function get_client_view(view_ident)
  local client = nx_value("game_client")
  return client:GetView(view_ident)
end
function get_client_view_obj(view_ident, item_ident)
  local client = nx_value("game_client")
  return client:GetViewObj(view_ident, item_ident)
end
function get_visual_scene()
  local visual = nx_value("game_visual")
  return visual:GetScene()
end
function get_visual_player()
  local visual = nx_value("game_visual")
  return visual:GetPlayer()
end
function get_visual_scene_obj(ident)
  local visual = nx_value("game_visual")
  return visual:GetSceneObj(ident)
end
function get_visual_view(view_ident)
  local visual = nx_value("game_visual")
  return visual:GetView(view_ident)
end
function get_visual_view_obj(view_ident, item_ident)
  local visual = nx_value("game_visual")
  return visual:GetViewObj(view_ident, item_ident)
end
