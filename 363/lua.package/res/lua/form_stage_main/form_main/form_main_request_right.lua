require("const_define")
require("define\\notice_type")
require("share\\client_custom_define")
require("share\\capital_define")
require("util_functions")
require("define\\request_type")
BEG_INI_FILE = "share\\Life\\BegInfo.ini"
NOTICE_ARRAY = {}
local INDEX_NOTICE_TYPE = 1
local INDEX_NOTICE_PLAYER = 2
local INDEX_NOTICE_PARAMS = 3
local INDEX_NOTICE_BUTTON = 4
local NORMAL_IMAGE = 1
local FOCUS_IMAGE = 2
local PUSH_IMAGE = 3
local NOTICE_ICON = {
  [NOTICE_TYPE_HURT] = {
    "gui\\mainform\\intercourse\\btn_hurt_out.png",
    "gui\\mainform\\intercourse\\btn_hurt_on.png",
    "gui\\mainform\\intercourse\\btn_hurt_down.png"
  },
  [NOTICE_TYPE_GAIN] = {
    "gui\\mainform\\intercourse\\btn_income_out.png",
    "gui\\mainform\\intercourse\\btn_income_on.png",
    "gui\\mainform\\intercourse\\btn_income_down.png"
  },
  [NOTICE_TYPE_STATE] = {
    "gui\\mainform\\intercourse\\btn_special_out.png",
    "gui\\mainform\\intercourse\\btn_special_on.png",
    "gui\\mainform\\intercourse\\btn_special_down.png"
  },
  [NOTICE_TYPE_PRESENT] = {
    "gui\\mainform\\intercourse\\btn_gift_out.png",
    "gui\\mainform\\intercourse\\btn_gift_on.png",
    "gui\\mainform\\intercourse\\btn_gift_down.png"
  },
  [NOTICE_TYPE_WISH] = {
    "gui\\mainform\\intercourse\\btn_beatitude_out.png",
    "gui\\mainform\\intercourse\\btn_beatitude_on.png",
    "gui\\mainform\\intercourse\\btn_beatitude_down.png"
  },
  [NOTICE_TYPE_ACTION] = {
    "gui\\mainform\\intercourse\\btn_info1_out.png",
    "gui\\mainform\\intercourse\\btn_info1_on.png",
    "gui\\mainform\\intercourse\\btn_info1_down.png"
  },
  [NOTICE_TYPE_GROW_UP] = {
    "gui\\mainform\\intercourse\\btn_info1_out.png",
    "gui\\mainform\\intercourse\\btn_info1_on.png",
    "gui\\mainform\\intercourse\\btn_info1_down.png"
  }
}
function Init(form_main)
  if not nx_is_valid(form_main) then
    form_main = nx_value(GAME_GUI_MAIN)
  end
  if not nx_is_valid(form_main) then
    return
  end
  form_main.g_notice_image_width = 32
  local form_light_absleft, form_light_abstop, form_light_height = nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "get_form_btn_absleft_top")
  if form_light_absleft == nil or form_light_abstop == nil or form_light_height == nil then
    form_main.g_notice_left = form_light_absleft
    form_main.g_notice_to_desktop_top = form_light_abstop - form_main.g_notice_image_width - 10
  else
    form_main.g_notice_left = form_main.Width - 44
    form_main.g_notice_to_desktop_top = form_main.Height / 5 * 3 - 34
  end
  form_main.g_notice_start_top = form_main.Height / 4
  form_main.g_notice_image_inter = 10
  form_main.g_notice_move_speed = 5
  form_main.g_notice_show_count = 7
end
function clear_request()
  if nx_running("form_stage_main\\form_main\\form_main_request_right", "begin_move_action") then
    nx_kill("form_stage_main\\form_main\\form_main_request_right", "begin_move_action")
  end
  if nx_running("form_stage_main\\form_main\\form_main_request_right", "reset_form_size") then
    nx_kill("form_stage_main\\form_main\\form_main_request_right", "reset_form_size")
  end
end
function has_request_item(request_type)
  for _, data in ipairs(NOTICE_ARRAY) do
    if nil ~= data[INDEX_NOTICE_TYPE] then
      local req_type = data[INDEX_NOTICE_TYPE]
      if req_type == request_type then
        return true
      end
    end
  end
  return false
end
function add_request_item(request_type, request_player)
  local form_main = nx_value(GAME_GUI_MAIN)
  if not nx_is_valid(form_main) then
    return
  end
  if request_type == NOTICE_TYPE_PRESENT and has_request_item(NOTICE_TYPE_PRESENT) then
    return
  end
  if request_type == NOTICE_TYPE_WISH and has_request_item(NOTICE_TYPE_WISH) then
    return
  end
  local gui = nx_value("gui")
  local button = gui:Create("Button")
  button.NormalImage = "icon\\func\\default.png"
  button.FocusImage = "icon\\func\\default.png"
  button.PushImage = "icon\\func\\default.png"
  if request_type >= NOTICE_TYPE_MIN and request_type < NOTICE_TYPE_MAX then
    if NOTICE_ICON[request_type] ~= nil then
      button.NormalImage = NOTICE_ICON[request_type][NORMAL_IMAGE]
      button.FocusImage = NOTICE_ICON[request_type][FOCUS_IMAGE]
      button.PushImage = NOTICE_ICON[request_type][PUSH_IMAGE]
    else
      button.NormalImage = "gui\\mainform\\intercourse\\btn_info1_out.png"
      button.FocusImage = "gui\\mainform\\intercourse\\btn_info1_on.png"
      button.PushImage = "gui\\mainform\\intercourse\\btn_info1_down.png"
    end
  elseif request_type == REQUESTTYPE_SPY_CALL then
    button.NormalImage = "icon\\func\\open_form_spy01.png"
    button.FocusImage = "icon\\func\\open_form_spy02.png"
    button.PushImage = "icon\\func\\open_form_spy03.png"
  end
  button.Visible = false
  button.AutoSize = false
  button.DrawMode = "FitWindow"
  button.Height = 32
  button.Width = 32
  button.Cursor = "Hand"
  button.HAnchor = "Right"
  button.first_move = true
  form_main:Add(button)
  if nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_relationship") then
    form_main:ToBack(button)
  end
  local index, sub_index
  for i = 1, table.getn(NOTICE_ARRAY) do
    local req_type = NOTICE_ARRAY[i][INDEX_NOTICE_TYPE]
    if req_type == request_type then
      index = i
      break
    end
  end
  if index == nil then
    local size = table.maxn(NOTICE_ARRAY) + 1
    index = size
    NOTICE_ARRAY[size] = {}
    NOTICE_ARRAY[size][INDEX_NOTICE_TYPE] = request_type
    NOTICE_ARRAY[size][INDEX_NOTICE_PLAYER] = {}
    NOTICE_ARRAY[size][INDEX_NOTICE_PARAMS] = {}
    NOTICE_ARRAY[size][INDEX_NOTICE_BUTTON] = {}
    table.insert(NOTICE_ARRAY[size][INDEX_NOTICE_BUTTON], button)
    table.insert(NOTICE_ARRAY[size][INDEX_NOTICE_PLAYER], request_player)
    sub_index = table.getn(NOTICE_ARRAY[size][INDEX_NOTICE_BUTTON])
    NOTICE_ARRAY[size][INDEX_NOTICE_PARAMS][sub_index] = {}
  else
    table.insert(NOTICE_ARRAY[index][INDEX_NOTICE_BUTTON], button)
    table.insert(NOTICE_ARRAY[index][INDEX_NOTICE_PLAYER], request_player)
    sub_index = table.getn(NOTICE_ARRAY[index][INDEX_NOTICE_BUTTON])
    NOTICE_ARRAY[index][INDEX_NOTICE_PARAMS][sub_index] = {}
  end
  nx_bind_script(button, nx_current(), "button_init")
  show_request()
  return index, sub_index
end
function button_init(btn)
  nx_callback(btn, "on_click", "on_click_request")
end
function add_request_para(index, sub_index, para)
  if NOTICE_ARRAY[index][INDEX_NOTICE_PARAMS][sub_index] == nil then
    NOTICE_ARRAY[index][INDEX_NOTICE_PARAMS][sub_index] = {}
  end
  local para_index = table.getn(NOTICE_ARRAY[index][INDEX_NOTICE_PARAMS][sub_index])
  NOTICE_ARRAY[index][INDEX_NOTICE_PARAMS][sub_index][para_index + 1] = para
end
function show_request()
  local form_main = nx_value(GAME_GUI_MAIN)
  if not nx_is_valid(form_main) then
    return
  end
  local size = table.maxn(NOTICE_ARRAY)
  local move_count = size
  if size < form_main.g_notice_show_count then
    move_count = size
  else
    move_count = form_main.g_notice_show_count
  end
  for i = 1, move_count do
    local buttons = NOTICE_ARRAY[i][INDEX_NOTICE_BUTTON]
    for sub_index, button in ipairs(buttons) do
      if nx_is_valid(button) then
        if button.first_move then
          button.AbsLeft = form_main.g_notice_left
          button.AbsTop = form_main.g_notice_start_top
          button.first_move = false
        end
        button.index = i
        button.sub_index = sub_index
        button.Visible = true
        local timer = nx_value(GAME_TIMER)
        timer:Register(10, 1, nx_current(), "begin_move_action", button, i, -1)
      end
    end
  end
end
function begin_move_action(button, index)
  local form_main = button.ParentForm
  local dest_top = form_main.g_notice_to_desktop_top - (index - 1) * (form_main.g_notice_image_width + form_main.g_notice_image_inter)
  while nx_is_valid(button) and dest_top > button.AbsTop do
    nx_pause(0)
    if nx_is_valid(button) then
      button.AbsTop = button.AbsTop + form_main.g_notice_move_speed
    end
  end
  if nx_is_valid(button) then
    button.AbsTop = dest_top
    button.move_end = true
  end
end
function on_click_request(button)
  local form = button.ParentForm
  local index = button.index
  local sub_index = button.sub_index
  local size = table.maxn(NOTICE_ARRAY)
  if index > size or index < 1 then
    return
  end
  local gui = nx_value("gui")
  local request_type = NOTICE_ARRAY[index][INDEX_NOTICE_TYPE]
  if request_type == NOTICE_TYPE_HURT or request_type == NOTICE_TYPE_GAIN or request_type == NOTICE_TYPE_STATE then
    if not second_word_unlock() then
      return
    end
    local info = NOTICE_ARRAY[index][INDEX_NOTICE_PARAMS][sub_index][1]
    local table_para = util_split_wstring(nx_widestr(info), "&")
    if table.getn(table_para) ~= 4 then
      return
    end
    if nx_string(table_para[1]) == "" then
      return
    end
    if nx_string(table_para[2]) == "" then
      return
    end
    if nx_string(table_para[3]) == "" then
      return
    end
    local form = nx_execute("form_common\\form_sns_dialog", "get_new_confirm_form", "notice_bottom")
    if not nx_is_valid(form) then
      return
    end
    nx_execute("form_common\\form_sns_dialog", "show_common_text", form, nx_widestr(table_para[2]))
    form.btn_reply.Visible = false
    form.btn_goto.Visible = false
    form.btn_broadcast.Visible = false
    local table_btn_visible = util_split_wstring(nx_widestr(table_para[4]), ",")
    if table.getn(table_btn_visible) ~= 3 then
      return
    end
    local table_btn = {
      form.btn_reply,
      form.btn_goto,
      form.btn_broadcast
    }
    local left_total = 6
    for i = 1, 3 do
      if nx_number(table_btn_visible[i]) == 1 then
        table_btn[i].Visible = true
        table_btn[i].Left = left_total
        left_total = left_total + table_btn[i].Width
      end
    end
    if form.btn_reply.Visible then
      form.btn_reply.FeedId = nx_string(table_para[3])
      form.btn_reply.Owner = nx_widestr(table_para[1])
    end
    if form.btn_goto.Visible then
      form.btn_goto.GotoName = nx_widestr(table_para[1])
    end
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
    form.Visible = true
    form:ShowModal()
  elseif request_type == NOTICE_TYPE_PRESENT then
    local gui = nx_value("gui")
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_present", true, false)
    dialog.TypeMode = 1
    dialog:Show()
  elseif request_type == NOTICE_TYPE_WISH then
    local gui = nx_value("gui")
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_qifu", true, false)
    dialog.TypeMode = 1
    dialog:Show()
  elseif request_type == NOTICE_TYPE_ACTION then
  elseif request_type == NOTICE_TYPE_GROW_UP then
  elseif request_type == REQUESTTYPE_SPY_CALL then
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "show_call_form")
  end
  if not nx_is_valid(button) then
    return
  end
  index = button.index
  local player = NOTICE_ARRAY[index][INDEX_NOTICE_PLAYER][sub_index]
  form:Remove(button)
  gui:Delete(button)
  table.remove(NOTICE_ARRAY[index][INDEX_NOTICE_PLAYER], sub_index)
  table.remove(NOTICE_ARRAY[index][INDEX_NOTICE_PARAMS], sub_index)
  table.remove(NOTICE_ARRAY[index][INDEX_NOTICE_BUTTON], sub_index)
  if 0 == table.getn(NOTICE_ARRAY[index][INDEX_NOTICE_BUTTON]) then
    table.remove(NOTICE_ARRAY, index)
  end
  show_request()
end
function del_request_item(request_type)
  local index
  for i, data in ipairs(NOTICE_ARRAY) do
    local type = data[INDEX_NOTICE_TYPE]
    if type == request_type then
      index = i
    end
  end
  if index == nil then
    return
  end
  local button = NOTICE_ARRAY[index][INDEX_NOTICE_BUTTON][1]
  if not nx_is_valid(button) then
    return
  end
  local gui = nx_value("gui")
  local form = button.ParentForm
  index = button.index
  local sub_index = button.sub_index
  local player = NOTICE_ARRAY[index][INDEX_NOTICE_PLAYER][sub_index]
  form:Remove(button)
  gui:Delete(button)
  table.remove(NOTICE_ARRAY[index][INDEX_NOTICE_PLAYER], sub_index)
  table.remove(NOTICE_ARRAY[index][INDEX_NOTICE_PARAMS], sub_index)
  table.remove(NOTICE_ARRAY[index][INDEX_NOTICE_BUTTON], sub_index)
  if 0 == table.getn(NOTICE_ARRAY[index][INDEX_NOTICE_BUTTON]) then
    table.remove(NOTICE_ARRAY, index)
  end
  show_request()
end
function reset_form_size()
  local form_main = nx_value(GAME_GUI_MAIN)
  if not nx_is_valid(form_main) then
    return
  end
  local form_light_absleft, form_light_abstop, form_light_height = nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "get_form_btn_absleft_top")
  if form_light_absleft == nil or form_light_abstop == nil or form_light_height == nil then
    return
  end
  form_main.g_notice_left = form_light_absleft
  form_main.g_notice_start_top = form_main.Height / 4
  form_main.g_notice_to_desktop_top = form_light_abstop - form_main.g_notice_image_width - 10
  local size = table.maxn(NOTICE_ARRAY)
  local move_count = size
  if size < form_main.g_notice_show_count then
    move_count = size
  else
    move_count = form_main.g_notice_show_count
  end
  for i = 1, move_count do
    local buttons = NOTICE_ARRAY[i][INDEX_NOTICE_BUTTON]
    for sub_index, button in ipairs(buttons) do
      if nx_is_valid(button) then
        if not nx_find_custom(button, "move_end") or not button.move_end then
          button.Visible = false
          while not nx_find_custom(button, "move_end") or not button.move_end do
            nx_pause(0.3)
          end
          button.Visible = true
        end
        button.AbsLeft = form_light_absleft
        button.AbsTop = form_light_abstop - i * (form_main.g_notice_image_width + form_main.g_notice_image_inter)
      end
    end
  end
end
function hide_modal()
  local dialog = nx_value("form_common\\form_sns_dialog")
  if nx_is_valid(dialog) then
    dialog:Close()
  end
  dialog = nx_value("form_stage_main\\form_relation\\form_feed_reply_simple")
  if nx_is_valid(dialog) then
    dialog:Close()
  end
end
function second_word_unlock()
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local condition_manager = nx_value("ConditionManager")
  if nx_is_valid(condition_manager) then
    local b_ok = condition_manager:CanSatisfyCondition(player, player, 23600)
    if not b_ok then
      return true
    end
  end
  local is_have_second_word = nx_number(player:QueryProp("IsHaveSecondWord"))
  if is_have_second_word == nx_number(0) then
    nx_execute("custom_sender", "request_set_second_word")
    return false
  end
  local is_have_lock = nx_number(player:QueryProp("IsCheckPass"))
  if is_have_lock == 0 then
    nx_execute("form_stage_main\\from_word_protect\\form_protect_sure", "show_form_protect_sure")
    return false
  end
  return true
end
