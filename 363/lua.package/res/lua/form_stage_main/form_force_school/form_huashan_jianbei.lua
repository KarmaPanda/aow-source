require("util_functions")
require("util_gui")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
  self.Visible = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  local talk_text = form.redit_talk.Text
  local checkword = nx_value("CheckWords")
  if nx_is_valid(checkword) then
    talk_text = checkword:CleanWords(talk_text)
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HUASHAN_JIANBEI), talk_text)
  form:Close()
  return 1
end
function on_server_msg(...)
  local type = arg[1]
  if type == "open" then
    util_show_form("form_stage_main\\form_force_school\\form_huashan_jianbei", true)
  elseif type == "talk" then
    local ident = nx_string(arg[2])
    local talk_text = nx_widestr(arg[3])
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("sys_item_hsp_006")
    gui.TextManager:Format_AddParam(talk_text)
    gui.TextManager:Format_GetText()
    local text = gui.TextManager:Format_GetText()
    local game_client = nx_value("game_client")
    local client_scene_obj = game_client:GetSceneObj(ident)
    local head_game = nx_value("HeadGame")
    if nx_is_valid(head_game) then
      head_game:ShowChatTextOnHead(client_scene_obj, nx_widestr(text), 5000)
    end
  end
end
