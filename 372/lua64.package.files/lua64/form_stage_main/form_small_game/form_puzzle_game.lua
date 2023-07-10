require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\client_custom_define")
local CLIENT_MSG = {
  CLIENT_MSG_HEAD = CLIENT_CUSTOMMSG_PUZZLE_GAME,
  SUBMSG_ADD_ITEM = 1,
  SUBMSG_QUIT_GAME = 2
}
local SERVER_SUBMSG = {
  OPEN_FORM = 1,
  QUIT_GAME = 2,
  ITEM_ADD_SUCCESS = 3,
  ITEM_ADD_FAILURE = 4,
  BAG_FULL = 5
}
function main_form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.Fixed = false
  return
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  return
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.Focused = nx_null()
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  if not nx_is_valid(btn) then
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
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_MSG.CLIENT_MSG_HEAD), nx_int(CLIENT_MSG.SUBMSG_QUIT_GAME))
  local parent_form = btn.ParentForm
  parent_form:Close()
  return
end
function on_btn_item_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  btn.Visible = false
  local data_source = btn.DataSource
  if data_source == nil then
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
  local story_id = player.puzzle_story_id
  if story_id == nil then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_MSG.CLIENT_MSG_HEAD), nx_int(CLIENT_MSG.SUBMSG_ADD_ITEM), nx_int(story_id), nx_int(data_source))
  return
end
function on_puzzle_game_svr_msg(chander, arg_num, ...)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\PuzzleGame.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sub_msg = arg[2]
  if nx_number(SERVER_SUBMSG.OPEN_FORM) == nx_number(sub_msg) then
    if arg_num < 3 then
      return
    end
    local puzzle_story_id = arg[3]
    local sec_index = ini:FindSectionIndex(nx_string(puzzle_story_id))
    if sec_index < 0 then
      return
    end
    local item_index = ini:FindSectionItemIndex(sec_index, nx_string("FormPath"))
    if item_index < 0 then
      return
    end
    local form_path = ini:GetSectionItemValue(sec_index, item_index)
    local form = nx_execute("util_gui", "util_get_form", nx_string(form_path), true, false)
    if nx_is_valid(form) then
      player.puzzle_story_id = puzzle_story_id
      player.puzzle_game_form = form
      form.Visible = true
      form:Show()
    end
  elseif nx_number(SERVER_SUBMSG.QUIT_GAME) == nx_number(sub_msg) then
    player.puzzle_story_id = nil
    player.puzzle_game_form = nil
  elseif nx_number(SERVER_SUBMSG.ITEM_ADD_SUCCESS) == nx_number(sub_msg) then
  elseif nx_number(SERVER_SUBMSG.BAG_FULL) == nx_number(sub_msg) then
    if arg_num < 4 then
      return
    end
    local form = player.puzzle_game_form
    local current_story_id = player.puzzle_story_id
    if not nx_is_valid(form) or current_story_id == nil then
      return
    end
    local story_id = arg[3]
    local btn_data_source = arg[4]
    if story_id ~= current_story_id then
      return
    end
    local btn_name = "btn_" .. btn_data_source
    local btn = form:Find(btn_name)
    if not nx_is_valid(btn) then
      return
    end
    btn.Visible = true
  elseif nx_number(SERVER_SUBMSG.ITEM_ADD_FAILURE) == nx_number(sub_msg) then
  end
  return
end
