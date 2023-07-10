function open_npc_talk(ident)
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return false
  end
  local receiver = sock.Receiver
  local game_client = nx_value("game_client")
  local client_scene_obj = game_client:GetSceneObj(ident)
  close_npc_talk()
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_talk", true, false)
  dialog:Show()
  if nx_is_valid(client_scene_obj) then
    dialog.name_label.Text = client_scene_obj:QueryProp("Name")
  end
  local select_count = 0
  local num = nx_number(receiver:GetMenuCount())
  nx_set_value("npc_talk_form", dialog)
  return true
end
function close_npc_talk()
  local npc_talk_form = nx_value("npc_talk_form")
  if nx_is_valid(npc_talk_form) then
    npc_talk_form:Close()
    nx_destroy(npc_talk_form)
  end
  return true
end
function on_menu_select(select_list, index)
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return 0
  end
  local receiver = sock.Receiver
  local mindex = nx_int(index) + select_list.menu_begin
  local ident = select_list.menu_ident
  local menu_mark = receiver:GetMenuMark(mindex)
  sock.Sender:Select(nx_object(ident), menu_mark)
  close_npc_talk()
end
