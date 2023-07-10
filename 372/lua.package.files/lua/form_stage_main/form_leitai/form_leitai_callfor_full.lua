function main_form_init(self)
  self.Fixed = false
  local game_visual = nx_value("game_visual")
  local vis_player = game_visual:GetPlayer()
  if not nx_find_custom(vis_player, "leitai_attention") then
    vis_player.leitai_attention = false
  end
  self.leitai_attention = vis_player.leitai_attention
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  local info = nx_string(gui.TextManager:GetText("ui_leitai_join_text"))
  self.btn_join.Text = nx_widestr(info .. nx_string(self.leitai_callfor_time))
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", self)
    timer:Register(1000, -1, nx_current(), "on_timer", self, -1, -1)
  end
  local gui = nx_value("gui")
  if self.leitai_attention then
    self.btn_attention.Text = nx_widestr(gui.TextManager:GetText("ui_leitai_cancel_attention"))
  else
    self.btn_attention.Text = nx_widestr(gui.TextManager:GetText("ui_leitai_attention"))
  end
  local game_client = nx_value("game_client")
  local cli_player = game_client:GetPlayer()
  local cur_state = nx_number(cli_player:QueryProp("LeiTaiCurPlayerState"))
  if 0 < cur_state then
    self.btn_join.Enabled = false
  else
    self.btn_join.Enabled = true
  end
end
function on_timer(self)
  local gui = nx_value("gui")
  local info = nx_string(gui.TextManager:GetText("ui_leitai_join_text"))
  self.leitai_callfor_time = nx_number(self.leitai_callfor_time) - 1
  self.btn_join.Text = nx_widestr(info .. nx_string(self.leitai_callfor_time))
  if self.leitai_callfor_time < 0 then
    self:Close()
  end
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", self)
  end
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function on_btn_join_click(self)
  nx_execute("custom_sender", "custom_send_leitai_call_for_confirm", 0)
  nx_gen_event(self.Parent, "leitai_pk_return", "ok")
  self.Parent:Close()
end
function on_btn_attention_click(self)
  local game_visual = nx_value("game_visual")
  local vis_player = game_visual:GetPlayer()
  if not self.Parent.leitai_attention then
    nx_execute("custom_sender", "custom_send_leitai_call_for_confirm", 1)
    vis_player.leitai_attention = true
  else
    nx_execute("custom_sender", "custom_send_leitai_call_for_confirm", 2)
    vis_player.leitai_attention = false
    local leitai_time_form = nx_value("form_stage_main\\form_leitai\\form_leitai_time")
    if nx_is_valid(leitai_time_form) then
      leitai_time_form:Close()
    end
  end
  self.Parent:Close()
end
