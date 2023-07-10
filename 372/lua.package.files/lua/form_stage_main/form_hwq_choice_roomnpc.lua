require("util_gui")
local FORM_PATH = "form_stage_main\\form_hwq_choice_roomnpc"
local LUA_PATH = "form_stage_main\\form_hwq_choice_roomnpc"
local SERVER_SUB_MSG_ROOMNPC_OPEN = 0
local SERVER_SUB_MSG_ROOMNPC_CLOSE = 1
local SERVER_SUB_MSG_QUERY_ROOM = 2
local SERVER_SUB_MSG_BUY_XIUQIU = 3
local CLIENT_SUB_MSG_MOVETO_ROOM = 0
local CLIENT_SUB_MSG_QUERY_ROOM = 1
local CLIENT_SUB_MSG_BUY_CONFIRM = 2
function open_form(room_num, query_price, switch_price)
  local form = util_get_form(FORM_PATH, true)
  if not nx_is_valid(form) then
    return
  end
  if room_num ~= nil then
    form.player_room_num = nx_number(room_num)
  end
  if query_price ~= nil then
    form.query_price = nx_number(query_price)
  end
  if switch_price ~= nil then
    form.switch_price = nx_number(switch_price)
  end
  form.Visible = true
  form:Show()
end
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.player_room_num = 0
  form.query_price = 0
  form.switch_price = 0
  form.rbtn_select = 0
end
function on_main_form_open(form)
  local rbtn_list = form.groupbox_room:GetChildControlList()
  for index, rbtn in pairs(rbtn_list) do
    if form.player_room_num == nx_number(rbtn.DataSource) then
      rbtn.Enabled = false
    else
      rbtn.Enabled = true
    end
  end
  form.rbtn_select = 0
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_query_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_select < 1 or form.rbtn_select > 16 then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital = nx_number(client_player:QueryProp("CapitalType2"))
  if capital < form.query_price then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("adv0090221"), 2)
    end
    return
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "hwq_choice_room_query")
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local text = gui.TextManager:GetFormatText("yhg_wuque_room_query", nx_int(form.query_price))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  end
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "hwq_choice_room_query_confirm_return")
  if res == "ok" and nx_is_valid(form) then
    nx_execute("custom_sender", "custom_send_hwq_choice", CLIENT_SUB_MSG_QUERY_ROOM, form.rbtn_select)
  end
end
function on_btn_transport_click(btn, mouseID)
  if mouseID ~= 0 then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_select < 1 or form.rbtn_select > 16 then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital = nx_number(client_player:QueryProp("CapitalType2"))
  if capital < form.switch_price then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("adv0090221"), 2)
    end
    return
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "hwq_choice_room_switch")
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local text = gui.TextManager:GetFormatText("yhg_wuque_room_switch", nx_int(form.switch_price))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  end
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "hwq_choice_room_switch_confirm_return")
  if res == "ok" and nx_is_valid(form) then
    nx_execute("custom_sender", "custom_send_hwq_choice", CLIENT_SUB_MSG_MOVETO_ROOM, form.rbtn_select)
  end
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local groupbox = rbtn.Parent
  if not nx_is_valid(groupbox) then
    return
  end
  form.rbtn_select = nx_number(rbtn.DataSource)
end
function custom_message_callback(...)
  if table.getn(arg) < 1 then
    return
  end
  local sub_msg = nx_number(arg[1])
  if sub_msg == SERVER_SUB_MSG_ROOMNPC_OPEN then
    if table.getn(arg) < 4 then
      return
    end
    open_form(nx_number(arg[2]), nx_number(arg[3]), nx_number(arg[4]))
  elseif sub_msg == SERVER_SUB_MSG_ROOMNPC_CLOSE then
    local form = nx_value(FORM_PATH)
    if not nx_is_valid(form) then
      return
    end
    form.Visible = false
    form:Close()
    local form_query = nx_value("hwq_choice_room_query_form_confirm")
    if nx_is_valid(form_query) then
      form_query:Close()
    end
    local form_switch = nx_value("hwq_choice_room_switch_form_confirm")
    if nx_is_valid(form_switch) then
      form_switch:Close()
    end
  elseif sub_msg == SERVER_SUB_MSG_QUERY_ROOM then
    if table.getn(arg) < 3 then
      return
    end
    local red_num = nx_int(arg[2])
    local blue_num = nx_int(arg[3])
    local text = nx_widestr("")
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      text = gui.TextManager:GetFormatText("yhg_wuque_cxjieguo", red_num, blue_num)
    end
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(text), 2)
    end
  elseif sub_msg == SERVER_SUB_MSG_BUY_XIUQIU then
    if table.getn(arg) < 3 then
      return
    end
    local need_money = nx_number(arg[2])
    local xiuqiu_num = nx_number(arg[3])
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "hwq_choice_buy_xiuqiu")
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      local text = gui.TextManager:GetFormatText("yhg_wuque_rgconfirm", nx_int(need_money), nx_int(xiuqiu_num))
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    end
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "hwq_choice_buy_xiuqiu_confirm_return")
    if res == "ok" then
      local game_client = nx_value("game_client")
      local client_player = game_client:GetPlayer()
      local capital = nx_number(client_player:QueryProp("CapitalType2"))
      if need_money > capital then
        local SystemCenterInfo = nx_value("SystemCenterInfo")
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(util_text("adv0090221"), 2)
        end
      else
        nx_execute("custom_sender", "custom_send_hwq_choice", CLIENT_SUB_MSG_BUY_CONFIRM)
      end
    end
  end
end
