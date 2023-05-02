require("util_gui")
require("util_functions")
local SUB_SERVER_BEGIN = 1
local SUB_SERVER_END = 2
local SUB_SERVER_BEGIN_TIME = 3
function main_form_init(self)
end
function on_main_form_open(self)
  change_form_size()
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("IsChallenge", "int", self, nx_current(), "on_challenge_state_change")
  end
end
function on_main_form_close(self)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelRolePropertyBind("IsChallenge", self)
  end
  nx_destroy(self)
end
function on_btn_lose_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local challenge_state = client_player:QueryProp("IsChallenge")
  if nx_int(challenge_state) > nx_int(0) then
    nx_execute("custom_sender", "custom_send_challenge_lose")
  end
end
function on_msg(sub_type)
  if sub_type == nil then
    return false
  end
  if nx_int(sub_type) == nx_int(SUB_SERVER_BEGIN) then
    util_show_form("form_stage_main\\form_leitai\\form_challenge_lose", true)
  elseif nx_int(sub_type) == nx_int(SUB_SERVER_END) then
    util_show_form("form_stage_main\\form_leitai\\form_challenge_lose", false)
    battle_begin_animation("battle_over")
  end
  if nx_int(sub_type) == nx_int(SUB_SERVER_BEGIN_TIME) then
    battle_begin_animation("battle_begin")
  end
end
function on_challenge_state_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local challenge_state = client_player:QueryProp("IsChallenge")
  if nx_int(challenge_state) == nx_int(0) then
    form:Close()
  end
end
function change_form_size()
  local form = util_get_form("form_stage_main\\form_leitai\\form_challenge_lose", false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = gui.Width - form.Width
end
function battle_begin_animation(ani_name)
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.AnimationImage = ani_name
  animation.Transparent = true
  gui.Desktop:Add(animation)
  animation.Left = (gui.Width - 110) / 2
  animation.Top = gui.Height / 4
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "battle_animation_end")
  animation:Play()
end
function battle_animation_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
