require("util_gui")
function on_main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  init_drop_info(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_refresh_click(btn)
  local form = btn.ParentForm
  init_drop_info(form)
end
function auto_show_form()
  local form = nx_value("form_stage_main\\form_map\\form_map_drop")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_map\\form_map_drop", true, false)
    if not nx_is_valid(form) then
      return nil
    end
    form:Show()
  else
    form.Visible = not form.Visible
    if form.Visible then
      init_drop_info(form)
    end
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_is_valid(form_map) then
    form.AbsLeft = form_map.btn_newdrop_box.AbsLeft
    form.AbsTop = form_map.btn_newdrop_box.AbsTop - form.Height
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui.Desktop:ToFront(form)
    end
  end
  return form
end
function get_client_player()
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    return game_client:GetPlayer()
  end
  return nx_null()
end
function init_drop_info(form)
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  form.mltbox_info:Clear()
  local rec_name = "JHDropBoxRec"
  local row_count = client_player:GetRecordRows(rec_name)
  local index = 1
  for row_index = 0, row_count - 1 do
    local scene = client_player:QueryRecord(rec_name, row_index, 6)
    for j = 1, 3 do
      local npc_pos = client_player:QueryRecord(rec_name, row_index, 2 * j - 1)
      if npc_pos ~= "" then
        gui.TextManager:Format_SetIDName("desc_newdrop_message_box")
        gui.TextManager:Format_AddParam(nx_int(index))
        gui.TextManager:Format_AddParam(npc_pos)
        gui.TextManager:Format_AddParam(util_text("ui_scene_" .. scene))
        form.mltbox_info:AddHtmlText(gui.TextManager:Format_GetText(), -1)
        index = index + 1
      end
    end
  end
end
