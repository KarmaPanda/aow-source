require("util_functions")
require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_match\\form_sanmeng_rank_stat"
local first_anim = "smzb_yu"
local second_anim = "smzb_jin"
local third_anim = "smzb_yin"
local BST_SANMENG = 1
local BST_GUILD_UNION = 2
function main_form_init(self)
  self.Fixed = false
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if nx_is_valid(client_scene) then
    self.tianwei_score = client_scene:QueryProp("ZhengqiIntegral")
    self.tianwu_score = client_scene:QueryProp("HaoqiIntegral")
    self.tianqi_score = client_scene:QueryProp("YiqiIntegral")
  end
  return
end
function on_main_form_open(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sub_type = client_player:QueryProp("BattleSubType")
  if sub_type == BST_GUILD_UNION then
    self.lbl_tianqi_score.Visible = false
    self.lbl_tianqi.Visible = false
    self.BackImage = "gui\\special\\smzb\\bg_jx_1.png"
  end
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.lbl_tianwei_score.Text = nx_widestr(self.tianwei_score)
  self.lbl_tianwu_score.Text = nx_widestr(self.tianwu_score)
  self.lbl_tianqi_score.Text = nx_widestr(self.tianqi_score)
  self.ani_1st.Visible = false
  self.ani_2nd.Visible = false
  self.ani_3rd.Visible = false
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(500, 1, FORM_NAME, "show_rank", self, -1, -1)
  end
end
function on_main_form_close(self)
  nx_destroy(self)
end
function ok_btn_click(btn)
  btn.ParentForm:Close()
end
function show_rank()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not (nx_find_custom(form, "tianwei_score") and nx_find_custom(form, "tianwu_score")) or not nx_find_custom(form, "tianqi_score") then
    return
  end
  show_tianwei_rank(form)
end
function show_tianwei_rank(self)
  local rank = calc_rank(self.tianwei_score, self.tianwu_score, self.tianqi_score)
  local anim
  if rank == 1 then
    anim = first_anim
  elseif rank == 2 then
    anim = second_anim
  elseif rank == 3 then
    anim = third_anim
  else
    return
  end
  self.ani_1st.AnimationImage = anim
  self.ani_1st.Visible = true
  self.ani_1st.Loop = false
  self.ani_1st.PlayMode = 0
  nx_callback(self.ani_1st, "on_animation_end", "show_tianwu_rank")
end
function show_tianwu_rank(self)
  self = self.ParentForm
  local rank = calc_rank(self.tianwu_score, self.tianwei_score, self.tianqi_score)
  local anim
  if rank == 1 then
    anim = first_anim
  elseif rank == 2 then
    anim = second_anim
  elseif rank == 3 then
    anim = third_anim
  else
    return
  end
  self.ani_2nd.AnimationImage = anim
  self.ani_2nd.Visible = true
  self.ani_2nd.Loop = false
  self.ani_2nd.PlayMode = 0
  nx_callback(self.ani_2nd, "on_animation_end", "show_tianqi_rank")
end
function show_tianqi_rank(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local sub_type = client_player:QueryProp("BattleSubType")
  if sub_type == BST_GUILD_UNION then
    return
  end
  self = self.ParentForm
  local rank = calc_rank(self.tianqi_score, self.tianwei_score, self.tianwu_score)
  local anim
  if rank == 1 then
    anim = first_anim
  elseif rank == 2 then
    anim = second_anim
  elseif rank == 3 then
    anim = third_anim
  else
    return
  end
  self.ani_3rd.AnimationImage = anim
  self.ani_3rd.Visible = true
  self.ani_3rd.Loop = false
  self.ani_3rd.PlayMode = 0
end
function calc_rank(self_score, other_score1, other_score2)
  if other_score1 < self_score and other_score2 < self_score then
    return 1
  elseif self_score < other_score1 and self_score < other_score2 then
    return 3
  elseif other_score1 < self_score and self_score < other_score2 then
    return 2
  elseif self_score < other_score1 and other_score2 < self_score then
    return 2
  elseif self_score == other_score1 and self_score == other_score2 then
    return 3
  elseif self_score == other_score1 and other_score2 < self_score then
    return 2
  elseif other_score1 < self_score and self_score == other_score2 then
    return 2
  elseif self_score == other_score1 and self_score < other_score2 then
    return 3
  elseif self_score < other_score1 and self_score == other_score2 then
    return 3
  end
end
