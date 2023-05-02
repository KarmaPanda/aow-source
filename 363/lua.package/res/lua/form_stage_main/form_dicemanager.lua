DiceItemTable = {}
DiceShowTrack = {
  top = 0,
  mid = 0,
  bot = 0
}
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function reset_scene()
  if nx_running(nx_current(), "update_time") then
    nx_kill(nx_current(), "update_time")
  end
  DiceShowTrack.top = 0
  DiceShowTrack.mid = 0
  DiceShowTrack.bot = 0
  DiceItemTable = {}
end
function push_dice_item(item, item_info, amount, wait_time)
  push_into_table(item, item_info, amount, wait_time)
  update_dice_show()
  if table.getn(DiceItemTable) > 0 and not nx_running(nx_current(), "update_time") then
    nx_execute(nx_current(), "update_time")
  end
end
function update_time()
  while true do
    if table.getn(DiceItemTable) == 0 and nx_running(nx_current(), "update_time") then
      return
    end
    nx_pause(1)
    for i = 1, table.getn(DiceItemTable) do
      DiceItemTable[i].waittime = DiceItemTable[i].waittime - 1
      if nx_int(DiceItemTable[i].waittime) <= nx_int(0) then
        DiceItemTable[i].waittime = 0
      end
    end
  end
end
function update_dice_show()
  local pos = get_display_pos()
  if pos == -1 then
    return
  end
  local bhave, info = pop_from_table()
  if bhave then
    create_dice_form(pos, info.item, info.iteminfo, info.amount, info.waittime)
  end
end
function create_dice_form(pos, item, item_info, amount, wait_time)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_dice", true, false, pos)
  dialog.item = item
  dialog.item_info = item_info
  dialog.amount = amount
  dialog.wait_time = wait_time
  dialog.pos = pos
  dialog.Left = (gui.Width - dialog.Width) / 4
  dialog.Top = gui.Height / 1.5 - dialog.Height * pos
  dialog:Show()
  set_display_pos(pos)
end
function send_dice_result(pos, item, dice_mode)
  reset_display_pos(pos)
  nx_execute("custom_sender", "custom_roll_item_result", item, dice_mode)
  update_dice_show()
end
function push_into_table(item, item_info, amount, wait_time)
  local count = table.getn(DiceItemTable)
  for i = 1, count do
    local data = DiceItemTable[i]
    if nx_string(item) == nx_string(data.item) and nx_string(item_info) == nx_string(data.iteminfo) and nx_int(amount) == nx_int(data.amount) and nx_int(wait_time) == nx_int(data.waittime) then
      return
    end
  end
  local index = count + 1
  DiceItemTable[index] = {
    item = item,
    iteminfo = item_info,
    amount = amount,
    waittime = wait_time
  }
end
function pop_from_table()
  if table.getn(DiceItemTable) <= 0 then
    return false, nil
  end
  local info = table.remove(DiceItemTable, 1)
  return true, info
end
function set_display_pos(pos)
  if nx_int(pos) == nx_int(0) then
    DiceShowTrack.top = 1
  elseif nx_int(pos) == nx_int(1) then
    DiceShowTrack.mid = 1
  elseif nx_int(pos) == nx_int(2) then
    DiceShowTrack.bot = 1
  else
    return false
  end
  return true
end
function reset_display_pos(pos)
  if nx_int(pos) == nx_int(0) then
    DiceShowTrack.top = 0
  elseif nx_int(pos) == nx_int(1) then
    DiceShowTrack.mid = 0
  elseif nx_int(pos) == nx_int(2) then
    DiceShowTrack.bot = 0
  else
    return false
  end
  return true
end
function get_display_pos()
  local form0 = get_dice_form(0)
  if not nx_is_valid(form0) then
    DiceShowTrack.top = 0
  else
    DiceShowTrack.top = 1
  end
  local form1 = get_dice_form(1)
  if not nx_is_valid(form1) then
    DiceShowTrack.mid = 0
  else
    DiceShowTrack.mid = 1
  end
  local form2 = get_dice_form(2)
  if not nx_is_valid(form2) then
    DiceShowTrack.bot = 0
  else
    DiceShowTrack.bot = 1
  end
  if DiceShowTrack.top == 0 then
    return 0
  end
  if DiceShowTrack.mid == 0 then
    return 1
  end
  if DiceShowTrack.bot == 0 then
    return 2
  end
  return -1
end
function get_dice_form(pos)
  local FORM_DICE = "form_stage_main\\form_dice"
  if pos ~= nil or pos ~= "" then
    return nx_value(FORM_DICE .. nx_string(pos))
  end
  return nil
end
function close_dice_form(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_timer", form)
  end
  reset_display_pos(form.pos)
  form:Close()
  update_dice_show()
end
