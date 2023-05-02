require("util_functions")
require("util_gui")
require("tips_data")
local RELATION_TYPE_FRIEND = 0
local RELATION_TYPE_BUDDY = 1
function on_main_form_init(form)
  form.Fixed = false
  form.select_name = nx_widestr("")
end
function on_main_form_open(form)
  change_form_size()
end
function on_main_form_close(form)
  nx_destroy(form)
end
function open_form(name, is_show_delete)
  local form = nx_value("form_stage_main\\form_chat_system\\form_new_friend_menu")
  if nx_is_valid(form) then
    form.Visible = true
    form.select_name = name
    change_form_size()
    local gui = nx_value("gui")
    gui.Desktop:ToFront(form)
  else
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_chat_system\\form_new_friend_menu", true, false)
    if not nx_is_valid(form) then
      return false
    end
    form.select_name = name
    form:Show()
  end
  if is_show_delete then
    form.btn_delete_friend.Enabled = true
    form.btn_bund.Enabled = true
    form.btn_goto.Enabled = true
    form.btn_callup.Enabled = true
  else
    form.btn_delete_friend.Enabled = false
    form.btn_bund.Enabled = false
    form.btn_goto.Enabled = false
    form.btn_callup.Enabled = false
  end
  return true
end
function change_form_size()
  local gui = nx_value("gui")
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local form = nx_value("form_stage_main\\form_chat_system\\form_new_friend_menu")
  if not nx_is_valid(form) then
    return
  end
  form.AbsLeft = mouse_x
  form.AbsTop = mouse_z
end
function on_btn_goto_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.select_name ~= nx_widestr("") then
    nx_execute("form_stage_main\\form_relation\\form_new_world_player_info", "scene_jhpk_goto", form.select_name)
  end
  form:Close()
end
function on_btn_callup_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.select_name ~= nx_widestr("") then
    nx_execute("form_stage_main\\form_relation\\form_new_world_player_info", "scene_jhpk_callup", form.select_name)
  end
  form:Close()
end
function on_btn_chat_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.select_name ~= nx_widestr("") then
    nx_execute("form_stage_main\\form_relation\\form_new_world_player_info", "scene_jhpk_chat", form.select_name)
  end
  form:Close()
end
function on_btn_bund_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.select_name ~= nx_widestr("") then
    nx_execute("form_stage_main\\form_relation\\form_new_world_player_info", "scene_jhpk_bund", form.select_name)
  end
  form:Close()
end
function on_btn_info_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.select_name ~= nx_widestr("") then
    nx_execute("custom_sender", "custom_send_get_player_game_info", form.select_name)
  end
  form:Close()
end
function on_btn_delete_friend_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_client_player()
  if not nx_is_valid(client_player) then
    return
  end
  local relation_type = -1
  if form.select_name ~= nx_widestr("") then
    local row = client_player:FindRecordRow("rec_friend", 1, form.select_name, 0)
    if row < 0 then
      row = client_player:FindRecordRow("rec_buddy", 1, form.select_name, 0)
      if row < 0 then
        local gui = nx_value("gui")
        local text = gui.TextManager:GetFormatText("sns_new_08")
        local SystemCenterInfo = nx_value("SystemCenterInfo")
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(text, 2)
        end
        return
      else
        relation_type = RELATION_TYPE_BUDDY
      end
    else
      relation_type = RELATION_TYPE_FRIEND
    end
    local gui = nx_value("gui")
    local info = gui.TextManager:GetFormatText("ui_menu_friend_confirm_delete", form.select_name)
    local res = util_form_confirm("", info)
    if res == "ok" then
      nx_execute("custom_sender", "custom_add_relation", 7, form.select_name, relation_type, nx_int(-1))
      local form_friend_list = nx_value("form_stage_main\\form_chat_system\\form_new_friend_list")
      if nx_is_valid(form_friend_list) then
        local timer = nx_value("timer_game")
        timer:Register(1000, 1, "form_stage_main\\form_chat_system\\form_new_friend_list", "rest_friend", form_friend_list, -1, -1)
      end
    end
  end
  form:Close()
end
function get_client_player()
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    return game_client:GetPlayer()
  end
  return nx_null()
end
