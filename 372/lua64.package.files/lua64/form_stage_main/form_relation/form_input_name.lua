require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  gui.Focused = self.name_edit
  self.lbl_back_group.Visible = false
  self.ani_loading.Visible = false
  self.is_siliao = false
  return 1
end
function is_siliao(flag)
  local form = nx_value("form_stage_main\\form_relation\\form_input_name")
  if not nx_is_valid(form) then
    return
  end
  if flag then
    form.is_siliao = true
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.ok_btn.Text = nx_widestr(gui.TextManager:GetText("ui_sns_chat_top_title"))
      form.lbl_title.Text = nx_widestr(gui.TextManager:GetText("ui_sns_chat_top_title"))
    end
  else
    form.is_siliao = false
  end
end
function on_main_form_close(self)
  self.Visible = false
  nx_destroy(self)
end
function on_search(form)
  local name = nx_widestr(form.name_edit.Text)
  if nx_ws_equal(name, nx_widestr("")) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SNS_SEARCH_FRIEND), nx_widestr(name))
  form.lbl_back_group.Visible = true
  form.ani_loading.Visible = true
  form.ani_loading.PlayMode = 0
end
function ok_btn_click(self)
  local form = self.Parent
  on_search(form)
  return 1
end
function on_name_edit_enter(btn)
  local form = btn.ParentForm
  on_search(form)
  return 1
end
function cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
  return 1
end
