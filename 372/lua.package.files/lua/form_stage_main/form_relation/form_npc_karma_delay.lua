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
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "select_npc_karma_delay", "select_npc_karma_delay")
  nx_execute("menu_game", "menu_recompose", menu_game)
  menu_game.event_uid = nx_string(info)
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x, y)
end
function add_npc_karma(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("rec_npc_relation_delay") then
    return
  end
  local rows = client_player:GetRecordRows("rec_npc_relation_delay")
  form.mltbox_karma:Clear()
  form.mltbox_data:Clear()
  for i = 0, rows - 1 do
    local npc = client_player:QueryRecord("rec_npc_relation_delay", i, 0)
    local scene = client_player:QueryRecord("rec_npc_relation_delay", i, 1)
    local karma = client_player:QueryRecord("rec_npc_relation_delay", i, 2)
    local addtime = client_player:QueryRecord("rec_npc_relation_delay", i, 3)
    local uid = client_player:QueryRecord("rec_npc_relation_delay", i, 4)
    local text = format_karma_text(npc, scene, karma, addtime)
    if nx_string(text) ~= "" then
      form.mltbox_karma:AddHtmlText(nx_widestr(text), -1)
      form.mltbox_data:AddHtmlText(nx_widestr(nx_string(uid)), -1)
    end
  end
end
function format_karma_text(npc, scene, karma, addtime)
  local text = ""
  text = text .. format_len(util_text(npc), 8)
  text = text .. format_len(util_text("daily_sence" .. nx_string(scene)), 8)
  text = text .. format_len(format_date(addtime), 12)
  text = text .. "(" .. nx_string(karma) .. ")"
  return text
end
function format_len(text, fmt_len)
  local result_text = text
  local lenth = string.len(nx_string(result_text))
  local lenth_add = nx_number(fmt_len) - lenth / 2
  for i = 1, lenth_add do
    result_text = nx_string(result_text) .. nx_string("\161\161")
  end
  return result_text
end
function format_date(date)
  local str_dt = nx_function("format_date_time", nx_double(date))
  local table_dt = util_split_string(str_dt, ";")
  if table.getn(table_dt) ~= 2 then
    return ""
  end
  local format_date = format_date_text(table_dt[1])
  local format_time = format_time_text(table_dt[2])
  return format_date .. format_time
end
function format_date_text(text)
  local len = string.len(text)
  if nx_number(len) ~= 11 then
    return text
  end
  text = string.sub(nx_string(text), 6, 11)
  local hasMonth = string.find(nx_string(text), "M")
  if hasMonth ~= nil then
    text = string.gsub(nx_string(text), "M", util_text("ui_g_month"))
  end
  local hasDay = string.find(nx_string(text), "D")
  if hasDay ~= nil then
    text = string.gsub(nx_string(text), "D", util_text("ui_g_day"))
  end
  return text
end
function format_time_text(text)
  local len = string.len(text)
  if nx_number(len) ~= 8 then
    return text
  end
  local format_time = string.sub(nx_string(text), 1, 5)
  return format_time
end
