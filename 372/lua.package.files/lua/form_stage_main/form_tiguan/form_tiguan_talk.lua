require("form_stage_main\\form_tiguan\\form_tiguan_util")
RANDOM_TALK_TIME_SHOW = 3
RANDOM_TALK_TIME_CLOSE = 8
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "close_form", self)
  timer:UnRegister(nx_current(), "show_form", self)
  nx_destroy(self)
end
function show_tiguan_talk(npc_id, grp_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local guan_id = player:QueryProp("CurGuanID")
  if nx_number(guan_id) <= 0 then
    return
  end
  local grp_id = nx_string(grp_id)
  local npc_id = nx_string(npc_id)
  local form = util_get_form(FORM_TIGUAN_TALK, true)
  local itemQuery = nx_value("ItemQuery")
  if not nx_is_valid(itemQuery) then
    return 0
  end
  local photo = itemQuery:GetItemPropByConfigID(npc_id, nx_string("Photo"))
  local name = gui.TextManager:GetText("ui_tiguan_npcname_" .. npc_id)
  local talk_str = gui.TextManager:GetText("ui_tiguan_talk_" .. grp_id)
  form.grid_photo:AddItem(0, nx_string(photo), "", 1, -1)
  form.lbl_name.Text = nx_widestr(name)
  form.mbx_talk:AddHtmlText(nx_widestr(talk_str), -1)
  local timer = nx_value("timer_game")
  timer:Register(RANDOM_TALK_TIME_SHOW * 1000, 1, nx_current(), "show_form", form, -1, -1)
  timer:Register(RANDOM_TALK_TIME_CLOSE * 1000, 1, nx_current(), "close_form", form, -1, -1)
end
function close_form(form)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function show_form(form)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("util_gui", "util_show_form", FORM_TIGUAN_TALK, true)
end
