require("util_gui")
require("share\\client_custom_define")
local LEITAI_REVENGE_INVITE = 1
local REQUESTTYPE_LEITAI_REVENGE = 40
local LEITAI_CANCEL_REVENGE_ITEM_ID = "ltitem_limit01"
local FORM_LEITAI_PATH = "form_stage_main\\form_leitai\\form_leitai"
function main_form_init(self)
  self.Fixed = false
  self.InviteType = 0
  self.revenge_name = ""
  self.time = 60
end
function on_main_form_open(self)
  init_dialog_control_info(self)
  if self.InviteType == 0 or self.InviteType == LEITAI_REVENGE_INVITE or self.InviteType == REQUESTTYPE_LEITAI_REVENGE then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_timer", self)
      timer:Register(1000, -1, nx_current(), "on_timer", self, -1, -1)
    end
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
function init_dialog_control_info(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) then
      local surplus_leitai_num_text = nx_widestr("")
      if form.InviteType == LEITAI_REVENGE_INVITE then
        local revenge_num = client_player:QueryProp("LeiTaiRevengeCount")
        surplus_leitai_num_text = gui.TextManager:GetFormatText("ui_world_leitai_player_revenge_num", nx_int(revenge_num))
        local text = gui.TextManager:GetFormatText("ui_revenge_dialog_text_info")
        form.mltbox_info:Clear()
        form.mltbox_info.HtmlText = nx_widestr(text)
        if 0 < revenge_num then
          text = gui.TextManager:GetText("ui_jieshouyaoqing_wanjia1")
        else
          text = gui.TextManager:GetText("ui_jieshouyaoqing_wanjia2")
        end
        form.mltbox_info:AddHtmlText(nx_widestr(text), nx_int(-1))
      end
      form.lbl_surplus_num.Text = nx_widestr(surplus_leitai_num_text)
    end
  end
end
function on_timer(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  form.time = nx_number(form.time) - 1
  if form.time < 1 then
    form.lbl_time.Text = nx_widestr("")
    form.Visible = false
    form:Close()
  else
    local info = nx_widestr(gui.TextManager:GetFormatText("ui_remaintime")) .. nx_widestr(form.time)
    form.lbl_time.Text = nx_widestr(info)
  end
end
function on_btn_no_accept_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "confirm_return", "cancel")
  form:Close()
end
function on_btn_accept_click(btn)
  local form = btn.ParentForm
  if form.InviteType == LEITAI_REVENGE_INVITE then
    local leitai_dialog = nx_execute("util_gui", "util_show_form", FORM_LEITAI_PATH, true)
    if nx_is_valid(leitai_dialog) then
      leitai_dialog.revenge_player_name = form.revenge_name
      nx_execute(FORM_LEITAI_PATH, "init_revenge_dialog_control", leitai_dialog)
    end
  else
    nx_gen_event(form, "confirm_return", "ok")
  end
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "confirm_return", "cancel")
  form:Close()
end
