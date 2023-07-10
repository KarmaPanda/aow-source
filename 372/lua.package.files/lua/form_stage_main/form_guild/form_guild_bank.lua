require("util_gui")
function main_form_init(form)
  form.Fixed = false
  form.FirstInflag = true
  form.npcid = nil
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  local bvisible = form_is_visible(form)
  if bvisible == true then
  else
    form:Close()
    return false
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  if form.FirstInflag then
    local page_info = util_get_form("form_stage_main\\form_guild\\form_guild_bank_info", true, false)
    if form:Add(page_info) then
      form.page_info = page_info
      form.page_info.Visible = true
      form.page_info.Fixed = true
      form.page_info.Left = 18
      form.page_info.Top = 100
      form.page_info.npcid = form.npcid
      form:Show()
      nx_execute("form_stage_main\\form_guild\\form_guild_bank_info", "on_main_form_open", page_info)
    end
    local page_distribute = util_get_form("form_stage_main\\form_guild\\form_guild_bank_distribute", true, false)
    if form:Add(page_distribute) then
      form.page_distribute = page_distribute
      form.page_distribute.Visible = false
      form.page_distribute.Fixed = true
      form.page_distribute.Left = 18
      form.page_distribute.Top = 100
      form.page_distribute.npcid = form.npcid
    end
    local page_event = util_get_form("form_stage_main\\form_guild\\form_guild_bank_event", true, false)
    if form:Add(page_event) then
      form.page_event = page_event
      form.page_event.Visible = false
      form.page_event.Fixed = true
      form.page_event.Left = 18
      form.page_event.Top = 100
      form.page_event.npcid = form.npcid
    end
    form.FirstInflag = false
  end
  form.page_info.npcid = form.npcid
  form.page_distribute.npcid = form.npcid
  form.page_event.npcid = form.npcid
  local game_client = nx_value("game_client")
  local ident = nx_string(form.npcid)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return false
  end
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_guild\\form_guild_bank", nx_null())
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_btn_help_click(btn)
  local form = btn.ParentForm
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return false
  end
  local form = rbtn.ParentForm
  local tab = rbtn.TabIndex
  hide_all_sub_form(form)
  if tab == 1 then
    if not nx_is_valid(form.page_info) then
      local page_info = util_get_form("form_stage_main\\form_guild\\form_guild_bank_info", true, false)
      if form:Add(page_info) then
        form.page_info = page_shop
        form.page_info.Visible = true
        form.page_info.Fixed = true
        form.page_info.Left = 18
        form.page_info.Top = 100
        form.page_info.npcid = form.npcid
      end
    end
    form.page_info.Visible = true
    form:ToFront(form.page_info)
    nx_execute("form_stage_main\\form_guild\\form_guild_bank_info", "on_main_form_open", form.page_info)
    form.btn_cancel.Visible = true
  elseif tab == 2 then
    if not nx_is_valid(form.page_distribute) then
      local page_distribute = util_get_form("form_stage_main\\form_guild\\form_guild_distribute", true, false)
      if form:Add(page_distribute) then
        form.page_distribute = page_distribute
        form.page_distribute.Visible = true
        form.page_distribute.Fixed = true
        form.page_distribute.Left = 0
        form.page_distribute.Top = 0
        form.page_distribute.npcid = form.npcid
      end
    end
    form.page_distribute.Visible = true
    form:ToFront(form.page_distribute)
    nx_execute("form_stage_main\\form_guild\\form_guild_bank_distribute", "on_main_form_open", form.page_distribute)
  elseif tab == 3 then
    if not nx_is_valid(form.page_event) then
      local page_event = util_get_form("form_stage_main\\form_guild\\form_guild_event", true, false)
      if form:Add(page_event) then
        form.page_event = page_event
        form.page_event.Visible = true
        form.page_event.Fixed = true
        form.page_event.Left = 0
        form.page_event.Top = 0
        form.page_event.npcid = form.npcid
      end
    end
    form.page_event.Visible = true
    form:ToFront(form.page_event)
    nx_execute("form_stage_main\\form_guild\\form_guild_bank_event", "on_main_form_open", form.page_event)
  end
end
function hide_all_sub_form(form)
  if nx_is_valid(form.page_info) then
    form.page_info.Visible = false
  end
  if nx_is_valid(form.page_distribute) then
    form.page_distribute.Visible = false
  end
  if nx_is_valid(form.page_event) then
    form.page_event.Visible = false
  end
  form.btn_cancel.Visible = false
end
function form_is_visible(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local ident = nx_string(form.npcid)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return false
  end
  if client_player:FindProp("GuildName") then
    local guild_name = client_player:QueryProp("GuildName")
    if nx_widestr(guild_name) == nx_widestr("") then
      return false
    end
    local npc_guild_name = npc:QueryProp("GuildName")
    if guild_name ~= npc_guild_name then
      return false
    end
  end
  return true
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
  local timer = nx_value(GAME_TIMER)
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
