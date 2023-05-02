require("util_gui")
require("util_functions")
require("custom_sender")
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  init_form(form)
  local gui = nx_value("gui")
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function init_form(form)
  form.mltbox_data.Visible = false
  add_npc_karma(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_mltbox_karma_right_click_item(mltbox, index)
  local form = mltbox.ParentForm
  local list_count = mltbox.ItemCount
  local data_count = form.mltbox_data.ItemCount
  if nx_number(list_count) ~= nx_number(data_count) then
    return
  end
  local select_index = mltbox:GetSelectItemIndex()
  if nx_number(index) ~= nx_number(select_index) then
    return
  end
  local info = form.mltbox_data:GetHtmlItemText(index)
  local table_info = util_split_string(nx_string(info), ";")
  if table.getn(table_info) ~= 2 then
    return
  end
  local npcid = table_info[1]
  local sceneid = table_info[2]
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "select_npc_karma_list", "select_npc_karma_list")
  nx_execute("menu_game", "menu_recompose", menu_game)
  menu_game.npc_id = nx_string(npcid)
  menu_game.scene_id = nx_string(sceneid)
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x, y)
end
function add_npc_karma(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("rec_npc_relation") then
    return
  end
  local rows = client_player:GetRecordRows("rec_npc_relation")
  form.mltbox_karma:Clear()
  form.mltbox_data:Clear()
  for i = 0, rows - 1 do
    local npc = client_player:QueryRecord("rec_npc_relation", i, 0)
    local scene = client_player:QueryRecord("rec_npc_relation", i, 1)
    local karma = client_player:QueryRecord("rec_npc_relation", i, 2)
    local relation = client_player:QueryRecord("rec_npc_relation", i, 3)
    local text = format_karma_text(npc, scene, karma, relation)
    if nx_string(text) ~= "" then
      form.mltbox_karma:AddHtmlText(nx_widestr(text), -1)
      form.mltbox_data:AddHtmlText(nx_widestr(nx_string(npc) .. ";" .. nx_string(scene)), -1)
    end
  end
end
function format_karma_text(npc, scene, karma, relation)
  local text = ""
  text = text .. format_len(util_text(npc))
  text = text .. format_len(util_text("daily_sence" .. nx_string(scene)))
  if nx_number(relation) == 0 then
    text = text .. format_len(util_text("ui_haoyou_01"))
  elseif nx_number(relation) == 1 then
    text = text .. format_len(util_text("ui_zhiyou_01"))
  else
    text = text .. format_len(util_text("ui_putong"))
  end
  local karma_text = ""
  if nx_int(karma) >= nx_int(-100000) and nx_int(karma) < nx_int(-80000) then
    karma_text = util_text("ui_karma_rela1")
  elseif nx_int(karma) >= nx_int(-80000) and nx_int(karma) < nx_int(-40000) then
    karma_text = util_text("ui_karma_rela2")
  elseif nx_int(karma) >= nx_int(-40000) and nx_int(karma) < nx_int(0) then
    karma_text = util_text("ui_karma_rela3")
  elseif nx_int(karma) == nx_int(0) then
    karma_text = util_text("ui_karma_rela4")
  elseif nx_int(karma) <= nx_int(40000) and nx_int(karma) > nx_int(0) then
    karma_text = util_text("ui_karma_rela5")
  elseif nx_int(karma) <= nx_int(80000) and nx_int(karma) > nx_int(40000) then
    karma_text = util_text("ui_karma_rela6")
  elseif nx_int(karma) <= nx_int(100000) and nx_int(karma) > nx_int(80000) then
    karma_text = util_text("ui_karma_rela7")
  end
  text = text .. format_len(nx_string(karma_text))
  text = text .. "(" .. nx_string(karma) .. ")"
  return text
end
function format_len(text)
  local result_text = text
  local lenth = string.len(nx_string(result_text))
  local lenth_add = 8 - lenth / 2
  for i = 1, lenth_add do
    result_text = nx_string(result_text) .. nx_string("\161\161")
  end
  return result_text
end
