require("custom_sender")
require("util_gui")
local head_effect = {
  [1] = "task_fire",
  [2] = "task_water"
}
function create_fire_head_effect(game_obj)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_is_valid(game_visual) then
    return
  end
  if not nx_is_valid(game_obj) then
    return
  end
  local visual_obj = game_visual:GetSceneObj(game_obj.Ident)
  if not nx_is_valid(visual_obj) then
    return
  end
  for i = 0, table.getn(head_effect) do
    nx_execute("game_effect", "remove_effect", nx_string(head_effect[i]), visual_obj, visual_obj)
  end
  local state = game_obj:QueryProp("PlayerFireState")
  if head_effect[state] ~= nil then
    create_effect(nx_string(head_effect[state]), visual_obj, visual_obj, "", "", game_obj.Ident, "", visual_obj, visual_obj.b_show_effect)
  end
end
function create_effect(effect_name, self, target, user_flag, action_name, self_client_ident, target_client_ident, visual_object, bshow)
  if effect_name == nil or nx_string(effect_name) == nx_string("") or nx_string(effect_name) == nx_string("nil") then
    return false
  end
  if not nx_is_valid(self) then
    return false
  end
  local scene = self.scene
  if not nx_is_valid(scene) then
    return false
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect) then
    return false
  end
  if not nx_is_valid(game_effect.Scene) then
    game_effect.Scene = scene
  end
  if not nx_is_valid(game_effect.Terrain) then
    game_effect.Terrain = scene.terrain
  end
  return game_effect:CreateEffect(nx_string(effect_name), self, target, user_flag, action_name, self_client_ident, target_client_ident, visual_object, bshow)
end
local GUILD_FIRE_TASK_SUB_CMD_ACCEPT_WATER_TASK = 6
function show_water_task_confirm()
  local gui = nx_value("gui")
  local confirm_dlg = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "water_task")
  if not nx_is_valid(confirm_dlg) then
    return
  end
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_water_task_confirm"))
  nx_execute("form_common\\form_confirm", "show_common_text", confirm_dlg, nx_widestr(text))
  confirm_dlg:ShowModal()
  local res = nx_wait_event(100000000, confirm_dlg, "confirm_return")
  if nx_string(res) == nx_string("ok") then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_TASK_SUB_CMD_ACCEPT_WATER_TASK))
    end
  end
end
local GUILD_FIRE_TASK_SUB_CMD_GIVEUP_FIRE_TASK = 14
local GUILD_FIRE_TASK_SUB_CMD_GIVEUP_WATER_TASK = 16
function GiveupFireTask()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_TASK_SUB_CMD_GIVEUP_FIRE_TASK))
  end
end
function GiveupWaterTask()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQ_GUILD_FIRE_TASK), nx_int(GUILD_FIRE_TASK_SUB_CMD_GIVEUP_WATER_TASK))
  end
end
