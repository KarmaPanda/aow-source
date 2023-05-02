require("const_define")
require("define\\object_type_define")
require("define\\task_npc_flag")
require("util_functions")
require("share\\pk_define")
require("share\\view_define")
require("share\\logicstate_define")
require("define\\player_name_color_define")
require("share\\npc_type_define")
require("util_gui")
NORMALINFO = 1
STALLINFO = 2
ALWAYSINFO = 3
UNREFRESHINFO = 4
HEAD_MAX_WIDTH = 320
HEAD_MIN_HEIGHT = 100
local HeadEffectType = {
  ["50"] = "func_11",
  ["51"] = "func_11",
  ["61"] = "",
  ["62"] = "func_01",
  ["63"] = "func_02",
  ["64"] = "func_03",
  ["66"] = "func_04",
  ["65"] = "func_05",
  ["68"] = "func_06",
  ["67"] = "func_07",
  ["69"] = "func_08",
  ["300"] = "func_05",
  ["122"] = "func_10",
  ["123"] = "func_10",
  ["124"] = "func_10",
  ["125"] = "func_10",
  ["126"] = "func_10",
  ["127"] = "func_10",
  ["128"] = "func_10",
  ["129"] = "func_10",
  ["130"] = "func_10",
  ["131"] = "func_10",
  ["132"] = "func_10",
  ["133"] = "func_10",
  ["134"] = "func_10",
  ["135"] = "func_10",
  ["136"] = "func_10",
  ["137"] = "func_10",
  ["138"] = "func_10",
  ["152"] = "func_10",
  ["224"] = "obj_move_222n",
  ["80"] = "obj_move_221n",
  ["226"] = "obj_move_224n",
  ["216"] = "light_hold_37",
  ["222"] = "light_hold_38",
  ["223"] = "light_hold_39",
  ["211"] = "light_hold_40",
  ["217"] = "light_hold_41",
  ["237"] = "light_hold_42",
  ["238"] = "light_hold_43",
  ["233"] = "light_hold_44",
  ["234"] = "light_hold_45",
  ["235"] = "light_hold_46",
  ["236"] = "light_hold_47",
  ["239"] = "task06",
  ["9"] = "test_guanghuan1"
}
head_client_npc_data = {
  [NORMALINFO] = {
    Name = {
      ControlType = "Label",
      ControlProp = {
        Font = "font_title",
        ForeColor = "255,204,255,0",
        Width = HEAD_MAX_WIDTH,
        Align = "Center"
      }
    }
  },
  [UNREFRESHINFO] = {
    Chat = {
      ControlType = "GroupBox",
      ControlProp = {
        Width = HEAD_MAX_WIDTH,
        LineColor = "0,0,0,0",
        Height = HEAD_MAX_HEIGHT,
        AutoSize = false,
        BackColor = "0,255,255,255"
      }
    }
  }
}
head_client_jy_npc_data = {
  [NORMALINFO] = {
    Name = {
      ControlType = "MultiTextBox",
      ControlProp = {
        Font = "HEIT12",
        ForeColor = "255,230,232,250",
        Width = HEAD_MAX_WIDTH,
        Height = 200,
        LineColor = "0,0,0,0",
        LineHeight = 7,
        AutoSize = false,
        DrawMode = "Expand",
        ViewRect = "10,10," .. HEAD_MAX_WIDTH / 2 - 10 .. "," .. 390,
        BackImage = "gui\\mainform\\bg_talk.png",
        HasVScroll = false,
        AlwaysVScroll = false,
        AutoScroll = false,
        VScrollLeft = false
      }
    }
  }
}
head_client_prisoner_npc_data = {
  [NORMALINFO] = {
    Name = {
      ControlType = "Label",
      ControlProp = {
        Font = "HEIT12",
        ForeColor = "255,255,0,0",
        Width = HEAD_MAX_WIDTH,
        Align = "Center"
      }
    }
  }
}
function RefreshChildrenPos(ball)
  local gui = nx_value("gui")
  local groupbox = ball.Control
  if not nx_is_valid(groupbox) then
    return false
  end
  local count = groupbox:GetChildControlCount()
  local y = 0
  local NeedHeight = 0
  for i = 0, count - 1 do
    local index = count - 1 - i
    local control = groupbox:GetChildControlByIndex(index)
    if control.Visible then
      control.HAnchor = "Center"
      control.Left = -control.Width / 2
      control.Top = y
      y = y + control.Height
      NeedHeight = NeedHeight + control.Height
    end
  end
  local chat_control = ball.Control:Find("Chat")
  if not nx_is_valid(chat_control) then
    return false
  end
  chat_control.Left = 0
  chat_control.Top = NeedHeight - chat_control.Height
  groupbox.Height = NeedHeight
  ball.OffsetTop = -groupbox.Height / 2 - 10
end
function ShowNpcSkillNameOnHead(visual_scene_obj, widetext, delaytime)
  local game_client = nx_value("game_client")
  if not nx_is_valid(visual_scene_obj) then
    return false
  end
  if not nx_find_custom(visual_scene_obj, "balloon_name") then
    return false
  end
  local ball = visual_scene_obj.balloon_name
  if not nx_is_valid(ball) then
    return false
  end
  local ball_control = ball.Control
  if not nx_is_valid(ball_control) then
    return
  end
  if not nx_is_kind(ball_control, "Form") then
    return
  end
  local head_game = nx_value("HeadGame")
  if not nx_is_valid then
    return
  end
  local skillName_control = ball_control:Find("SkillName")
  if not nx_is_valid(skillName_control) then
    return false
  end
  local MultiTexBox_control = skillName_control:Find("lbl_1")
  if not nx_is_valid(MultiTexBox_control) then
    return false
  end
  local skillPause_control = ball_control:Find("SkillPause")
  if nx_is_valid(skillPause_control) then
    skillPause_control.BlendAlpha = 0
    skillPause_control.Visible = false
  end
  MultiTexBox_control.Text = nx_widestr(widetext)
  skillName_control.BlendAlpha = 255
  skillName_control.Visible = true
  skillName_control.is_chat = true
  head_game:RefreshDataAndPos(visual_scene_obj, false)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    if delaytime == nil or delaytime == "" or delaytime == 0 then
      timer:Register(3000, 1, "head_game", "timer_callback", skillName_control, -1, -1)
    else
      timer:Register(delaytime, 1, "head_game", "timer_callback", skillName_control, -1, -1)
    end
  end
end
function timer_callback(chat_control, param1, param2)
  alpha_disappear(chat_control, 0.5)
end
function alpha_disappear(chat_control, keeptime)
  if nx_is_valid(chat_control) then
    local old_alpha = chat_control.BlendAlpha
    local timecount = 0
    while true do
      timecount = timecount + nx_pause(0)
      if keeptime > timecount then
        if nx_is_valid(chat_control) then
          chat_control.BlendAlpha = old_alpha - old_alpha * timecount / keeptime
        end
      else
        if nx_is_valid(chat_control) then
          chat_control.Visible = false
          chat_control.is_chat = false
          chat_control.BlendAlpha = 255
        end
        break
      end
    end
  end
end
function CreateClientNpcHeadControl(visual_scene_obj)
  local gui = nx_value("gui")
  local headdata = head_client_npc_data
  if nx_find_custom(visual_scene_obj, "JyNpc") then
    headdata = head_client_jy_npc_data
  end
  if nx_find_custom(visual_scene_obj, "prisoner_npc") then
    headdata = head_client_prisoner_npc_data
  end
  local groupbox = gui:Create("GroupScrollableBox")
  groupbox.DataSource = headtype
  groupbox.LineColor = "0,0,0,0"
  groupbox.BackColor = "0,0,0,0"
  groupbox.Width = HEAD_MAX_WIDTH
  for fresh_type, control_list in pairs(headdata) do
    for control_name, control_info in pairs(control_list) do
      local control = gui:Create(control_info.ControlType)
      if nx_is_valid(control) then
        control.fresh_type = fresh_type
        control.Name = control_name
        for prop, value in pairs(control_info.ControlProp) do
          nx_set_property(control, prop, value)
        end
        groupbox:Add(control)
        if fresh_type == UNREFRESHINFO then
          control.Visible = false
        end
      end
    end
  end
  local chat_control = groupbox:Find("Chat")
  if nx_is_valid(chat_control) then
    local MultiTexBox_control = chat_control:Find("MultiTextBox_1")
    if not nx_is_valid(MultiTexBox_control) then
      MultiTexBox_control = gui:Create("MultiTextBox")
      MultiTexBox_control.Name = "MultiTextBox_1"
      MultiTexBox_control.DrawMode = "Expand"
      MultiTexBox_control.TipAutoSize = true
      MultiTexBox_control.TipMaxWidth = HEAD_MAX_WIDTH
      MultiTexBox_control.LineColor = "0,0,0,0"
      MultiTexBox_control.TipAutoSize = true
      MultiTexBox_control.Solid = false
      MultiTexBox_control.AutoSize = false
      chat_control:Add(MultiTexBox_control)
    end
    groupbox:ToFront(chat_control)
  end
  local control = groupbox:Find("Name")
  if nx_is_valid(control) and nx_find_custom(visual_scene_obj, "JyNpc") then
    groupbox.Width = control.Width
    groupbox.Height = control.Height
    control.ViewRect = "10,10," .. control.Width - 10 .. "," .. control.Height - 10
  end
  return groupbox
end
function create_client_npc_head(visual_scene_obj)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  if nx_find_custom(visual_scene_obj, "balloon_name") then
    return
  end
  local balls = nx_value("balls")
  if not nx_is_valid(balls) then
    return
  end
  local groupbox = CreateClientNpcHeadControl(visual_scene_obj)
  local ball = balls:AddBalloon(groupbox, visual_scene_obj, 3)
  ball.OffsetTop = 0
  ball.NearDistance = 1
  ball.FarDistance = 50
  ball.Control.model = visual_scene_obj
  visual_scene_obj.balloon_name = ball
  refresh_client_npc_head(visual_scene_obj)
  local NameControl = groupbox:Find("Name")
  if nx_find_custom(visual_scene_obj, "text_name") then
    NameControl.Text = visual_scene_obj.text_name
  else
    local gui = nx_value("gui")
    NameControl.Text = gui.TextManager:GetText(visual_scene_obj.name)
  end
  if nx_find_custom(visual_scene_obj, "JyNpc") then
    visual_scene_obj.control = NameControl
  end
  return 1
end
function refresh_client_npc_head(visual_scene_obj)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  if not nx_find_custom(visual_scene_obj, "balloon_name") then
    return
  end
  local ball = visual_scene_obj.balloon_name
  if not nx_is_valid(ball) then
    return
  end
  local control_group = ball.Control
  local b_show = false
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  if nx_find_custom(game_control, "show_all_balloon") and game_control.show_all_balloon then
    b_show = true
  end
  if not b_show and nx_find_custom(game_control, "pick_id") and nx_id_equal(visual_scene_obj, game_control.pick_id) then
    b_show = true
  end
  if not b_show and nx_find_value(GAME_SELECT_OBJECT) then
    local select_object = nx_value(GAME_SELECT_OBJECT)
    if nx_is_valid(select_object) and nx_id_equal(select_object, visual_scene_obj) then
      b_show = true
    end
  end
  if nx_find_custom(visual_scene_obj, "JyNpc") and nx_find_custom(visual_scene_obj, "show_head_text") then
    b_show = visual_scene_obj.show_head_text
  end
  if nx_find_custom(visual_scene_obj, "prisoner_npc") and nx_find_custom(visual_scene_obj, "show_head_text") then
    b_show = visual_scene_obj.show_head_text
  end
  if not b_show and nx_find_custom(visual_scene_obj, "show_name") then
    b_show = visual_scene_obj.show_name
  end
  local NameControl = control_group:Find("Name")
  NameControl.Visible = b_show
  return 1
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
function set_npc_head_effect(visual_scene_obj)
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  if nx_find_method(head_game, "CreateNpcHeadEffect") then
    head_game:CreateNpcHeadEffect(visual_scene_obj)
    return
  end
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(visual_scene_obj)
  local client_scene_obj = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  if nx_find_custom(client_scene_obj, "Head_Effect_Flag") and nx_number(client_scene_obj.Head_Effect_Flag) > nx_number(0) then
    return
  end
  if not client_scene_obj:FindProp("NpcType") then
    return
  end
  local npc_type = client_scene_obj:QueryProp("NpcType")
  local head_effect = HeadEffectType[nx_string(npc_type)]
  if head_effect == nil then
    return
  end
  if head_effect == "" then
    return
  end
  create_effect(nx_string(head_effect), visual_scene_obj, visual_scene_obj, nx_string(client_ident), "", "", "", "", true)
end
function cancel_npc_head_effect(visual_scene_obj)
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  if nx_find_method(head_game, "DeleteNpcHeadEffect") then
    head_game:DeleteNpcHeadEffect(visual_scene_obj)
    return
  end
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(visual_scene_obj)
  local client_scene_obj = game_client:GetSceneObj(client_ident)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local npc_type = client_scene_obj:QueryProp("NpcType")
  local head_effect = HeadEffectType[nx_string(npc_type)]
  if nx_number(npc_type) == NpcType201 then
    remove_crop_effect(visual_scene_obj)
  end
  if head_effect == nil then
    return
  end
  if head_effect == "" then
    return
  end
  nx_execute("game_effect", "remove_effect", nx_string(head_effect), visual_scene_obj, visual_scene_obj)
end
function remove_crop_effect(visual_scene_obj)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local scene = visual_scene_obj.scene
  if not nx_is_valid(scene) then
    return
  end
  local game_effect = scene.game_effect
  if not nx_find_custom(visual_scene_obj, "crop_effect") then
    return
  end
  local effect_name = nx_custom(visual_scene_obj, "crop_effect")
  local result = nx_is_valid(visual_scene_obj) and game_effect:RemoveEffect(effect_name, visual_scene_obj, visual_scene_obj)
end
