require("util_functions")
require("role_composite")
require("game_object")
require("define\\object_type_define")
function prep_show_npc()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local scene_client_obj = game_client:GetScene()
  if not nx_is_valid(scene_client_obj) then
    return
  end
  if not scene_client_obj:FindRecord("prep_show_npc_rec") then
    return
  end
  local rows = scene_client_obj:GetRecordRows("prep_show_npc_rec")
  local world = nx_value("world")
  for i = 0, rows - 1 do
    local npc_id = scene_client_obj:QueryRecord("prep_show_npc_rec", i, 0)
    local x = scene_client_obj:QueryRecord("prep_show_npc_rec", i, 1)
    local y = scene_client_obj:QueryRecord("prep_show_npc_rec", i, 2)
    local z = scene_client_obj:QueryRecord("prep_show_npc_rec", i, 3)
    local o = scene_client_obj:QueryRecord("prep_show_npc_rec", i, 4)
    local scale_x = scene_client_obj:QueryRecord("prep_show_npc_rec", i, 5)
    local scale_y = scene_client_obj:QueryRecord("prep_show_npc_rec", i, 6)
    local scale_z = scene_client_obj:QueryRecord("prep_show_npc_rec", i, 7)
    local module = create_visual_obj(npc_id, x, y, z, o, scale_x, scale_y, scale_z)
    if nx_is_valid(module) then
      nx_set_custom(scene_client_obj, "preload_" .. nx_string(npc_id), module)
    end
  end
end
function create_visual_obj(npc_id, x, y, z, o, scale_x, scale_y, scale_z)
  local world = nx_value("world")
  local scene = world.MainScene
  local terrain = scene.terrain
  if not nx_is_valid(scene) then
    return nx_null()
  end
  local actor2 = nx_null()
  actor2 = nx_execute("role_composite", "create_actor2", scene)
  local res = get_npc_resource(npc_id)
  if res == "" then
    scene:Delete(actor2)
    return nx_null()
  end
  local result = load_from_ini(actor2, "ini\\" .. nx_string(res) .. ".ini")
  if not result then
    scene:Delete(actor2)
    return nx_null()
  end
  while not actor2.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(actor2) then
      return nx_null()
    end
  end
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:SetRoleClientIdent(actor2, "")
  actor2.createfinish = true
  actor2.shadow = nx_null()
  terrain:AddVisual("Model", actor2)
  terrain:RelocateVisual(actor2, nx_float(x), nx_float(y), nx_float(z))
  actor2:SetScale(nx_float(scale_x), nx_float(scale_y), nx_float(scale_z))
  actor2:SetAngle(0, nx_float(o), 0)
  terrain:RefreshVisual()
  return actor2
end
function break_associate_npc_with_module(ident)
  local game_visual = nx_value("game_visual")
  local visual_obj = game_visual:GetSceneObj(nx_string(ident))
  if not nx_is_valid(visual_obj) then
    return false
  end
  if nx_find_custom(visual_obj, "preploadflg") then
    return true
  end
  return false
end
function delete_prep_load_npc(record_name, del_row)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local scene_obj = game_client:GetScene()
  if not nx_is_valid(scene_obj) then
    return false
  end
  local config_id = scene_obj:QueryRecord(nx_string(record_name), del_row, 0)
  if config_id == nil then
    return false
  end
  local world = nx_value("world")
  local scene = world.MainScene
  local terrain = scene.terrain
  if not scene_obj:FindRecord("prep_show_npc_rec") then
    return false
  end
  if nx_find_custom(scene_obj, "preload_" .. nx_string(config_id)) then
    local actor2_module = nx_custom(scene_obj, "preload_" .. nx_string(config_id))
    if nx_is_valid(actor2_module) then
      scene:Delete(actor2_module)
      terrain:RefreshVisual()
      return true
    end
  end
  return false
end
function get_npc_resource(configid)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return ""
  end
  local bExist = item_query:FindItemByConfigID(nx_string(configid))
  if not bExist then
    return ""
  end
  local text = item_query:GetItemPropByConfigID(nx_string(configid), nx_string("script"))
  return nx_string(text)
end
