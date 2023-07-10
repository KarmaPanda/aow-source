require("util_gui")
require("util_functions")
ST_FUNCTION_WUDAO_WAR = 784
CLIENT_CUSTOMMSG_WUDAO_WAR = 783
WuDaoWarClientMsg_SAVE_EQUIP_PLANE = 1
WuDaoWarClientMsg_SAVE_CHANNELS_PLANE = 2
WuDaoWarClientMsg_REQUEST_WUXUE = 3
WuDaoWarClientMsg_SELECT_PLANE_DATA = 4
WuDaoWarClientMsg_REQUEST_EQUIP_PLANE = 13
WuDaoWarClientMsg_REQUEST_CHANNELS_PLANE = 14
WuDaoWarClientMsg_REQUEST_EQUIP_PLANE_IN_WAR = 15
WuDaoWarClientMsg_REQUEST_BEFORE_SELECT_PLANE = 18
WuDaoWarClientMsg_REQUEST_SAVE_BEFORE_PLANE = 19
WuDaoWarClientMsg_MODIFY_TEAM_INFO = 30
WuDaoWarClientMsg_CREATE_BATTLE_TEAM = 31
WuDaoWarClientMsg_RELEASE_BATTLE_TEAM = 32
WuDaoWarClientMsg_APPLY_JOIN_BATTLE_TEAM = 33
WuDaoWarClientMsg_QUIT_BATTLE_TEAM = 34
WuDaoWarClientMsg_INVENT_PLAYER = 35
WuDaoWarClientMsg_REJECT_PLAYER = 36
WuDaoWarClientMsg_CHANGE_BATTLE_TEAM_LEADER = 37
WuDaoWarClientMsg_REQUEST_BATTLE_TEAM_INFO = 38
WuDaoWarClientMsg_REQUEST_BATTLE_TEAM_PLAYER_INFO = 39
WuDaoWarClientMsg_REQUEST_BATTLE_TEAM_EVENT = 40
WuDaoWarClientMsg_REQUEST_BATTLE_TEAM_LIST = 41
WuDaoWarClientMsg_REQUEST_OPEN_INVENT_FORM = 42
WuDaoWarClientMsg_PLAYER_AGREE_JOIN_TEAM = 43
WuDaoWarClientMsg_REQUEST_BATTLE_TEAM_APPLY = 44
WuDaoWarClientMsg_CHECK_WAR_TEAM_NAME = 45
WuDaoWarClientMsg_CLEAR_APPLY_INFO = 46
WuDaoWarClientMsg_REQUEST_SERVER_NAME = 47
WuDaoWarClientMsg_AGREE_PLAYER_APPLY = 48
WuDaoWarClientMsg_FIND_PLAYER_BY_NAME = 49
WuDaoWarClientMsg_FIND_TEAM_BY_TEAM_NAME = 50
WuDaoWarClientMsg_RejectInvent = 51
WuDaoWarClientMsg_NORMAL_TO_CROSS = 100
WuDaoWarClientMsg_QUIT_CROSS = 101
WuDaoWarClientMsg_NotAfk = 102
WuDaoWarClientMsg_Apply = 103
WuDaoWarClientMsg_Join = 104
WuDaoWarClientMsg_Quit = 105
WuDaoWarClientMsg_WarResultRequestUI = 112
WuDaoWarClientMsg_PiPeiRequestUI = 114
WuDaoWarClientMsg_PiPeiReady = 115
WuDaoWarClientMsg_PiPeiCancelReady = 116
WuDaoWarClientMsg_RequestApplyUI = 117
WuDaoWarClientMsg_RequestMainUI = 118
WuDaoWarClientMsg_RoomRequestUI = 200
WuDaoWarClientMsg_RoomRequestLook = 201
WuDaoWarClientMsg_RoomGmInvite = 202
WuDaoWarClientMsg_RoomGmStart = 203
WuDaoWarClientMsg_RoomGmClose = 204
WuDaoWarClientMsg_GroupResult = 301
WuDaoWarClientMsg_GoLook = 107
WuDaoWarClientMsg_GroupRequestUI = 300
WuDaoWarClientMsg_GroupGmStart = 302
WuDaoWarClientMsg_GroupGmPause = 303
WuDaoWarClientMsg_GroupGmSetTip = 304
WuDaoWarClientMsg_AliveAdress = 308
wudao_in_war = "sys_in_wudao_war"
local fight_player_list = {}
local cur_looking_player_name = ""
local prop_wudao_player_state = "WuDaoPlayerState"
local prop_wudao_can_look = "WuDaoCanLook"
function request_quit_wudao_war()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_Quit))
end
function get_player_wudao_state()
  local player = get_player()
  if not nx_is_valid(player) then
    return nx_int(0)
  end
  if not player:FindProp(prop_wudao_player_state) then
    return nx_int(0)
  end
  return nx_int(player:QueryProp(prop_wudao_player_state))
end
function is_in_wudao_scene()
  return get_player_wudao_state() > nx_int(0)
end
function is_in_wudao_prepare_scene()
  return get_player_wudao_state() == nx_int(1)
end
function is_in_wudao_fight_scene()
  local state = get_player_wudao_state()
  return state == nx_int(2) or state == nx_int(3) or state == nx_int(4)
end
function is_in_wudao_fighting()
  return get_player_wudao_state() == nx_int(3)
end
function is_in_wudao_looking()
  return get_player_wudao_state() == nx_int(4)
end
function is_can_wudao_looking()
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp(prop_wudao_can_look) then
    return false
  end
  return nx_int(player:QueryProp(prop_wudao_can_look)) == nx_int(1)
end
function show_battle_begin_animation()
  show_animation("battlefield_begin")
end
function show_animation(ani_name)
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.AnimationImage = ani_name
  animation.Transparent = true
  gui.Desktop:Add(animation)
  animation.Left = (gui.Width - 110) / 2
  animation.Top = gui.Height / 4
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "end_animation")
  animation:Play()
end
function end_animation(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
function begin_look(...)
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind(prop_wudao_can_look, "int", player, nx_current(), "on_wudao_look_prop_change")
  end
  fight_player_list = {}
  local slot = 1
  local n = #arg
  for i = 1, n, 2 do
    local player_data = {}
    player_data.team_no = arg[i]
    player_data.player_name = arg[i + 1]
    fight_player_list[slot] = player_data
    slot = slot + 1
  end
  if is_in_wudao_looking() then
    local role = nx_value("role")
    local head_game = nx_value("HeadGame")
    role.Visible = false
    head_game:ShowHead(role, false)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "timer_look_first_fight_player", player)
      timer:Register(1000, -1, nx_current(), "timer_look_first_fight_player", player, -1, -1)
    end
  else
  end
end
function end_look()
  local player = get_player()
  if not nx_is_valid(player) then
    return nx_int(0)
  end
  fight_player_list = {}
  nx_execute("form_test\\form_camera", "reset_camera_target", true)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind(prop_wudao_can_look, player)
  end
end
function on_wudao_look_prop_change(form, propname, proptype, value)
  if nx_int(value) ~= nx_int(1) then
    end_look()
  end
end
function change_look_player()
  if not is_can_wudao_looking() then
    return
  end
  local n = #fight_player_list
  if n <= 0 then
    return
  end
  local looking_player_name = get_next_valid_player_name(cur_looking_player_name)
  look_player_by_name(looking_player_name)
end
function look_player_by_name(player_name)
  local fight_player = find_obj_by_name(player_name)
  if not nx_is_valid(fight_player) then
    return false
  end
  nx_execute("form_test\\form_camera", "set_camera_target_by_name", player_name, true)
  cur_looking_player_name = player_name
  return true
end
function get_next_valid_player_name(now_player_name)
  local n = #fight_player_list
  if n <= 0 then
    return
  end
  local slot = 0
  for i = 1, n do
    local player_data = fight_player_list[i]
    if nx_widestr(player_data.player_name) == nx_widestr(now_player_name) then
      slot = i
      break
    end
  end
  for i = slot + 1, n do
    local player_data = fight_player_list[i]
    local fight_player = find_obj_by_name(player_data.player_name)
    if nx_is_valid(fight_player) then
      return player_data.player_name
    end
  end
  for i = 1, slot do
    local player_data = fight_player_list[i]
    local fight_player = find_obj_by_name(player_data.player_name)
    if nx_is_valid(fight_player) then
      return player_data.player_name
    end
  end
  return nx_widestr("")
end
function game_key_down(gui, key, shift, ctrl)
  if shift or ctrl then
    return
  end
  if key == "SPACE" or key == "Space" then
    change_look_player()
    return
  end
end
function timer_look_first_fight_player()
  local n = #fight_player_list
  if n <= 0 then
    return
  end
  local first_player_name = get_next_valid_player_name("")
  local ok = look_player_by_name(first_player_name)
  if ok then
    local player = get_player()
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "timer_look_first_fight_player", player)
    end
  end
end
function find_obj_by_name(name)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return nil
  end
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local scene_obj = game_client:GetScene()
  local scene_obj_table = scene_obj:GetSceneObjList()
  for i, val in ipairs(scene_obj_table) do
    if not nx_is_valid(val) then
      return
    end
    if nx_ws_equal(nx_widestr(name), nx_widestr(val:QueryProp("Name"))) or nx_ws_equal(nx_widestr(name), nx_widestr(util_text(val:QueryProp("ConfigID")))) then
      local target_obj = game_visual:GetSceneObj(val.Ident)
      if nx_is_valid(target_obj) then
        return target_obj
      end
    end
  end
  return nil
end
function tip_arg(...)
  local text = nx_string("\n")
  for i = 1, #arg do
    text = text .. nx_string("\178\206\202\253") .. nx_string(i) .. nx_string(" = ") .. nx_string(arg[i]) .. nx_string("\n")
  end
  nx_msgbox(nx_string("\207\251\207\162\196\218\200\221 = [") .. text .. nx_string("], \178\206\202\253\184\246\202\253 = ") .. #arg)
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
