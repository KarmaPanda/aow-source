local CLIENT_CUSTOMMSG_HIRE_SHOP = 7
local money_ding_wen = 1000000
local money_siliver_wen = 1000
function main_form_init(form)
  form.Fixed = false
  form.npcid = nil
  form.remain_time = 0
  form.state = 0
  form.cur_silver = 0
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  show_shop_info(form)
  is_visibled_btn(form)
  return 1
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  local game_client = nx_value("game_client")
  local obj = game_client:GetSceneObj(nx_string(form.npcid))
  if nx_is_valid(obj) and nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", obj)
  end
  nx_destroy(form)
end
function is_visibled_btn(form)
  if not nx_is_valid(form) then
    return
  end
  if form.state == 0 then
    form.btn_show_price.Visible = true
    form.btn_official_levy.Visible = false
  else
    form.btn_show_price.Visible = false
    form.btn_official_levy.Visible = true
    form.ipt_gold.Text = nx_widestr(0)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_btn_show_price_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local game_client = nx_value("game_client")
  local ident = nx_string(form.npcid)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return false
  end
  local CostGolden = npc:QueryProp("CostGolden")
  form.ipt_gold.Text = nx_widestr(CostGolden)
  local cur_silver = 0
  if npc:FindRecord("PriceRec") then
    local max_rows = npc:GetRecordRows("PriceRec")
    if 0 < max_rows then
      cur_silver = npc:QueryRecord("PriceRec", 0, 1)
    end
  end
  local ding = nx_int(form.ipt_sell_ding.Text)
  local liang = nx_int(form.ipt_sell_liang.Text)
  local wen = nx_int(form.ipt_sell_wen.Text)
  local my_silver = ding * money_ding_wen + liang * money_siliver_wen + wen
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if my_silver < money_ding_wen / 10 then
    local info = gui.TextManager:GetText("37032")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return false
  end
  if my_silver <= cur_silver * 1.1 then
    local info = gui.TextManager:GetText("37033")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(0), form.npcid, nx_int(my_silver))
  form:Close()
  local my_compete_form = nx_value("form_stage_main\\form_hire_shop\\form_hire_shop_my_compete")
  if nx_is_valid(my_compete_form) then
    my_compete_form:Close()
    my_compete_form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_hire_shop\\form_hire_shop_my_compete", true, false)
    my_compete_form:Show()
    nx_set_value("form_stage_main\\form_hire_shop\\form_hire_shop_my_compete", my_compete_form)
  end
  return 1
end
function on_btn_shut_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_btn_official_levy_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  local ident = nx_string(form.npcid)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return
  end
  local strid = "37030"
  local OfficialLevy = npc:QueryProp("CostOfficialLevy")
  if nx_int(OfficialLevy) > nx_int(0) and not show_confirm_info(strid, nx_int(OfficialLevy)) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(10), form.npcid)
  form:Close()
end
function show_confirm_info(tip, ...)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog.mltbox_info.HtmlText = nx_widestr(format_info(tip, unpack(arg)))
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return false
    end
  end
  return true
end
function format_info(strid, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return strid
  end
  gui.TextManager:Format_SetIDName(strid)
  for i, v in ipairs(arg) do
    gui.TextManager:Format_AddParam(v)
  end
  return gui.TextManager:Format_GetText()
end
function show_shop_info(form)
  local ding = 0
  local liang = 0
  local wen = 0
  local game_client = nx_value("game_client")
  local ident = nx_string(form.npcid)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return false
  end
  form.mltbox_info:Clear()
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_hire_shop_desc")
  form.mltbox_info.HtmlText = text
  local silver = form.cur_silver
  if silver ~= nil and 0 < silver then
    ding = nx_int(silver / money_ding_wen)
    liang = nx_int((silver - ding * money_ding_wen) / money_siliver_wen)
    wen = silver - ding * money_ding_wen - liang * money_siliver_wen
  end
  form.ipt_cur_ding.Text = nx_widestr(ding)
  form.ipt_cur_liang.Text = nx_widestr(liang)
  form.ipt_cur_wen.Text = nx_widestr(wen)
  local gold_cost = nx_int(npc:QueryProp("CostGolden"))
  form.ipt_gold.Text = nx_widestr(gold_cost)
  local client_player = game_client:GetPlayer()
  local max_silver = client_player:QueryProp("CapitalType2")
  local max_ding = nx_int(max_silver / money_ding_wen)
  form.ipt_sell_ding.MaxDigit = max_ding
  if form.state == 1 then
    form.lbl_time.Text = nx_widestr("00:00:00")
  else
    local remain = get_format_time_text(form.remain_time)
    form.lbl_time.Text = nx_widestr(remain)
    if nx_int(form.remain_time) > nx_int(0) then
      init_timer(form.remain_time, form.npcid)
    end
  end
end
function init_timer(time, ident)
  local timer = nx_value("timer_game")
  temp_time = time
  local game_client = nx_value("game_client")
  while true do
    local ptime = nx_pause(0)
    if not nx_is_valid(game_client) then
      return false
    end
    local obj = game_client:GetSceneObj(nx_string(ident))
    if nx_is_valid(obj) then
      timer:Register(1000, -1, nx_current(), "on_update_time", obj, -1, -1)
      temp_time = temp_time - nx_int(ptime)
      break
    end
  end
end
function on_update_time(obj)
  temp_time = temp_time - 1
  local form = nx_value("form_stage_main\\form_hire_shop\\form_hire_shop_price")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_hire_shop\\form_hire_shop_price", true, false)
    nx_set_value("form_stage_main\\form_hire_shop\\form_hire_shop_price", form)
  end
  local remain = get_format_time_text(temp_time)
  form.lbl_time.Text = nx_widestr(remain)
  if temp_time <= 0 then
    stop_timer(obj)
  end
end
function stop_timer(obj)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "on_update_time", obj)
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time)
end
