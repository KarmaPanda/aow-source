require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
require("util_gui")
require("tips_data")
require("form_stage_main\\switch\\url_define")
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function open_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
    return
  end
  local ST_NORMAL_ACTIVITY_LOGIN = 2027
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_NORMAL_ACTIVITY_LOGIN) then
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "add_sub_form", form)
  form.Visible = true
  form:Show()
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  return game_client:GetPlayer()
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  label_init(form)
  data_init(form)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    if nx_string(switch_manager:GetUrl(URL_TYPE_SAFE_LOGIN)) == "" then
      form.btn_url.Visible = false
    end
    if nx_string(switch_manager:GetUrl(URL_TYPE_SDO_SAFE_LOGIN)) == "" then
      form.btn_url_sdo.Visible = false
    end
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_url_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  switch_manager:OpenUrl(URL_TYPE_SAFE_LOGIN)
end
function on_btn_url_sdo_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  switch_manager:OpenUrl(URL_TYPE_SDO_SAFE_LOGIN)
end
function label_init(form)
  form.ani_2.Visible = false
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Activity\\safeloginprize.ini")
  if not nx_is_valid(ini) then
    return
  end
  local Day_index = ini:FindSectionIndex("Day")
  if Day_index < 0 then
    return
  end
  for i = 1, 35 do
    local name = "ImageControlGrid" .. nx_string(i)
    local imggrid = form.groupbox_1:Find(name)
    if nx_is_valid(imggrid) then
      nx_bind_script(imggrid, nx_current())
      nx_callback(imggrid, "on_mousein_grid", "on_ImageControlGrid_mousein_grid")
      nx_callback(imggrid, "on_mouseout_grid", "on_ImageControlGrid_mouseout_grid")
      local prize = ini:ReadString(Day_index, nx_string(i), "")
      local configid, number = get_configid_and_num(prize)
      imggrid.configid = configid
      local item_photo = ItemQuery:GetItemPropByConfigID(configid, "Photo")
      imggrid:AddItem(nx_int(0), item_photo, "", number, -1)
      imggrid:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(configid))
      imggrid:ChangeItemImageToBW(nx_int(0), true)
      imggrid.MultiTextBox1.BackImage = ""
    end
  end
  local SeriesDay_index = ini:FindSectionIndex("SeriesDay")
  if SeriesDay_index < 0 then
    return
  end
  for i = 36, 40 do
    local name = "ImageControlGrid" .. nx_string(i)
    local imggrid = form.groupbox_2:Find(name)
    if nx_is_valid(imggrid) then
      nx_bind_script(imggrid, nx_current())
      nx_callback(imggrid, "on_mousein_grid", "on_ImageControlGrid_mousein_grid")
      nx_callback(imggrid, "on_mouseout_grid", "on_ImageControlGrid_mouseout_grid")
      local iSeriesDay = ini:GetSectionItemKey(SeriesDay_index, i - 36)
      local prize = ini:GetSectionItemValue(SeriesDay_index, i - 36)
      imggrid.iSeriesDay = iSeriesDay
      local configid, number = get_configid_and_num(prize)
      imggrid.configid = configid
      local item_photo = ItemQuery:GetItemPropByConfigID(configid, "Photo")
      imggrid:AddItem(nx_int(0), item_photo, "", number, -1)
      imggrid:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(configid))
      imggrid:ChangeItemImageToBW(nx_int(0), true)
    end
  end
end
function data_init(form)
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_count.Text = gui.TextManager:GetFormatText("ui_aqy_count", nx_int(0))
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local state = nx_int(player:QueryProp("SafeLoginState"))
  local textid
  form.ani_1.Visible = false
  if state == nx_int(0) then
    textid = "ui_aqy_fail"
  elseif state == nx_int(-1) then
    textid = "ui_aqy_survey"
    form.ani_1.Visible = true
  elseif state == nx_int(1) then
    textid = "ui_aqy_succ"
  end
  form.lbl_state.Text = util_text(textid)
  if not player:FindRecord("SafeLoginActivityRec") then
    return
  end
  local first_date = 0
  local first_week = 0
  local nRows = player:GetRecordRows("SafeLoginActivityRec")
  local days = 0
  for i = 0, nRows - 1 do
    local time = player:QueryRecord("SafeLoginActivityRec", i, 0)
    local typp = player:QueryRecord("SafeLoginActivityRec", i, 1)
    local buqi = player:QueryRecord("SafeLoginActivityRec", i, 2)
    if nx_int(typp) <= nx_int(0) then
      break
    end
    days = days + 1
    local year, month, day, hour, mins, sec = nx_function("ext_decode_date", nx_double(time))
    local week = nx_function("ext_get_day_of_week", year, month, day)
    if week == 0 then
      week = 7
    end
    if i == 0 then
      first_date = time
      first_week = week
    end
    local diffday = nx_int(time) - nx_int(first_date)
    local cur_week = first_week + diffday
    if cur_week < 1 or 35 < cur_week then
      break
    end
    local name = "ImageControlGrid" .. nx_string(cur_week)
    local imggrid = form.groupbox_1:Find(name)
    if nx_is_valid(imggrid) then
      imggrid:ChangeItemImageToBW(nx_int(0), false)
      imggrid.MultiTextBox1.BackImage = "gui\\language\\ChineseS\\create\\yqd_qd1.png"
    end
    if nx_int(msg_delay:GetServerDateTime()) == nx_int(time) then
      show_sign_anim(form, imggrid)
    end
  end
  if 0 < days then
    local year, month, day, hour, mins, sec = nx_function("ext_decode_date", nx_double(first_date))
    local week = nx_function("ext_get_day_of_week", year, month, day)
    if week == 0 then
      week = 7
    end
    for i = week, 27 + week do
      local name = "ImageControlGrid" .. nx_string(i)
      local imggrid = form.groupbox_1:Find(name)
      if nx_is_valid(imggrid) then
        imggrid.DrawGridBack = "gui\\common\\imagegrid\\anqian_on.png"
      end
    end
  end
  for i = 36, 40 do
    local name = "ImageControlGrid" .. nx_string(i)
    local imggrid = form.groupbox_2:Find(name)
    if nx_is_valid(imggrid) and nx_int(imggrid.iSeriesDay) <= nx_int(nRows) then
      imggrid:ChangeItemImageToBW(nx_int(0), false)
      if i == 36 then
        form.lbl_10.Text = util_text("ui_aqy_addup_desc2")
      elseif i == 37 then
        form.lbl_13.Text = util_text("ui_aqy_addup_desc2")
      elseif i == 38 then
        form.lbl_14.Text = util_text("ui_aqy_addup_desc2")
      elseif i == 39 then
        form.lbl_15.Text = util_text("ui_aqy_addup_desc2")
      elseif i == 40 then
        form.lbl_16.Text = util_text("ui_aqy_addup_desc2")
      end
    end
  end
  form.lbl_count.Text = gui.TextManager:GetFormatText("ui_aqy_count", nx_int(days))
end
function get_configid_and_num(prize)
  local values = util_split_string(prize, ",")
  if table.maxn(values) < 2 then
    return "", 0
  end
  return nx_string(values[1]), nx_number(values[2])
end
function on_ImageControlGrid_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(1))
  if nx_widestr(item_config) == nx_widestr("") or nx_widestr(item_config) == nx_widestr("nil") then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", nx_string(item_config), "ItemType", "0")
  item.MaxHardiness = get_ini_prop("share\\Item\\tool_item.ini", nx_string(item_config), "MaxHardiness", "0")
  item.Hardiness = item.MaxHardiness
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_ImageControlGrid_mouseout_grid(grid, index)
  grid:SetSelectItemIndex(-1)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_detect_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_request_safe_login")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(util_text("91146"), 2)
  end
  form:Close()
  local form_dbomall = nx_value("form_stage_main\\form_dbomall\\form_dbomall")
  if nx_is_valid(form_dbomall) then
    form_dbomall:Close()
  end
end
function show_sign_anim(form, img)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(img) then
    return
  end
  form.ani_2.Left = form.groupbox_1.Left + img.Left
  form.ani_2.Top = form.groupbox_1.Top + img.Top
  form.ani_2.Visible = true
  form.ani_2:Play()
end
