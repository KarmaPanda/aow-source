require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
local enter_type_owner = 1
local enter_type_visit = 2
local enter_type_open_lock = 3
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function main_form_init(form)
  form.Fixed = false
  form.sign_id = 0
  form.npc = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 4
  form.groupbox_mod.Visible = false
end
function on_main_form_close(form)
  nx_destroy(form)
end
function open_form(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  end
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.sign_id = arg[1]
  form.npc = arg[2]
  fresh_form(form, unpack(arg))
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_shopinfo_click(btn)
  local homeid = btn.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if not is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_02")
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_SELLINFO, nx_string(homeid), nx_int(form.sign_id), nx_object(form.npc))
  close_form()
end
function on_btn_sell_click(btn)
  local homeid = btn.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if not is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_02")
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_REQUEST_SELLHOME, nx_string(homeid), nx_int(form.sign_id), nx_object(form.npc))
end
function on_btn_buy_click(btn)
  local homeid = btn.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_03")
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_BUYHOME, nx_string(homeid), nx_int(form.sign_id), nx_object(form.npc))
  close_form()
end
function on_btn_jw_click(btn)
  local homeid = btn.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_03")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ADD_NEIGHBOUR, nx_string(homeid))
end
function on_btn_dm_click(btn)
  local homeid = btn.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_03")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ENTRY, nx_string(homeid), nx_int(enter_type_visit))
end
function on_btn_qs_click(btn)
  local homeid = btn.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_03")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ENTRY, nx_string(homeid), nx_int(enter_type_open_lock))
end
function on_btn_gohome_click(btn)
  local homeid = btn.homeid
  if nx_string(homeid) == nx_string("") then
    return
  end
  if not is_my_home(homeid) then
    self_systemcenterinfo("home_enter_failed_02")
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ENTRY, nx_string(homeid), nx_int(enter_type_owner))
end
function on_btn_close_click(btn)
  close_form()
end
function self_systemcenterinfo(msgid)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(util_text(nx_string(msgid))), 2)
  end
end
function fresh_form(form, ...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local sign_id = arg[1]
  local groupboxmain = form.groupscrollbox_zh
  form.groupscrollbox_zh:DeleteAll()
  groupboxmain.IsEditMode = true
  local number = 0
  for i = 3, table.getn(arg), 4 do
    local homeid = nx_string(arg[i])
    local homename = nx_widestr(arg[i + 1])
    local playername = nx_widestr(arg[i + 2])
    local homestatus = nx_int(arg[i + 3])
    if is_my_home(homeid) then
      local groupbox = creat_home_group(form, groupboxmain, homeid, homename, playername, number, homestatus)
      if groupbox ~= nil then
        number = number + 1
      end
      set_groupbox_pos(form, groupbox, number)
    end
  end
  for i = 3, table.getn(arg), 4 do
    local homeid = nx_string(arg[i])
    local homename = nx_widestr(arg[i + 1])
    local playername = nx_widestr(arg[i + 2])
    local homestatus = nx_int(arg[i + 3])
    if not is_my_home(homeid) then
      local groupbox = creat_home_group(form, groupboxmain, homeid, homename, playername, number, homestatus)
      if groupbox ~= nil then
        number = number + 1
      end
      set_groupbox_pos(form, groupbox, number)
    end
  end
  local last_group_box = form.groupscrollbox_zh:Find("Home_groupBox_" .. nx_string(number - 1))
  if nx_is_valid(last_group_box) then
    local max_value = last_group_box.Top - last_group_box.Height
    form.groupscrollbox_zh.VScrollBar.Maximum = max_value
  end
  groupboxmain.IsEditMode = false
  if 0 >= groupboxmain:GetChildControlCount() then
    form:Close()
  end
end
function set_groupbox_pos(form, groupbox, number)
  local row = 0
  local col = 0
  if number % 3 == 0 then
    row = number / 3 - 1
    col = 2
  else
    row = nx_int(number / 3)
    col = number % 3 - 1
  end
  groupbox.Left = col * groupbox.Width
  groupbox.Top = row * groupbox.Height
end
function is_my_home(homeid)
  local recordname = "self_home_rec"
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  row = client_player:FindRecordRow(recordname, 0, homeid, 0)
  if row >= 0 then
    return true
  end
  return false
end
function creat_home_group(form, groupboxmain, homeid, homename, playername, number, homestatus)
  local gui = nx_value("gui")
  if nx_string(homeid) == nx_string("") then
    return nil
  end
  local groupbox = gui:Create("GroupBox")
  groupboxmain:Add(groupbox)
  groupbox.Name = "Home_groupBox_" .. nx_string(number)
  clone_groupbox(groupbox, form.groupbox_mod)
  groupbox.Left = 0
  groupbox.Top = groupbox.Height * number + 9
  local lable_1 = gui:Create("Label")
  groupbox:Add(lable_1)
  lable_1.Name = "Home_lbl_1_" .. nx_string(number)
  clone_lable(lable_1, form.lbl_mod_1)
  local lable_2 = gui:Create("Label")
  groupbox:Add(lable_2)
  lable_2.Name = "Home_lbl_2_" .. nx_string(number)
  clone_lable(lable_2, form.lbl_mod_2)
  local lable_homename = gui:Create("Label")
  groupbox:Add(lable_homename)
  lable_homename.Name = "Home_lbl_homename_" .. nx_string(number)
  clone_lable(lable_homename, form.lbl_homename)
  lable_homename.Text = nx_widestr(homename)
  local lable_playername = gui:Create("Label")
  groupbox:Add(lable_playername)
  lable_playername.Name = "Home_lbl_playername_" .. nx_string(number)
  clone_lable(lable_playername, form.lbl_playername)
  lable_playername.Text = nx_widestr(playername)
  local button_jw = gui:Create("Button")
  groupbox:Add(button_jw)
  button_jw.Name = "Home_button_jw_" .. nx_string(number)
  clone_button(button_jw, form.btn_jw, "on_btn_jw_click")
  button_jw.homeid = homeid
  local button_dm = gui:Create("Button")
  groupbox:Add(button_dm)
  button_dm.Name = "Home_button_dm_" .. nx_string(number)
  clone_button(button_dm, form.btn_dm, "on_btn_dm_click")
  button_dm.homeid = homeid
  local button_qs = gui:Create("Button")
  groupbox:Add(button_qs)
  button_qs.Name = "Home_button_qs_" .. nx_string(number)
  clone_button(button_qs, form.btn_qs, "on_btn_qs_click")
  button_qs.homeid = homeid
  if is_my_home(homeid) then
    local button_gohome = gui:Create("Button")
    groupbox:Add(button_gohome)
    button_gohome.Name = "Home_button_gohome_" .. nx_string(number)
    clone_button(button_gohome, form.btn_gohome, "on_btn_gohome_click")
    button_gohome.homeid = homeid
  end
  local button_shopinfo = gui:Create("Button")
  groupbox:Add(button_shopinfo)
  button_shopinfo.Name = "button_shopinfo" .. nx_string(number)
  clone_button(button_shopinfo, form.btn_shopinfo, "on_btn_shopinfo_click")
  button_shopinfo.homeid = homeid
  local button_sell = gui:Create("Button")
  groupbox:Add(button_sell)
  button_sell.Name = "button_sell" .. nx_string(number)
  clone_button(button_sell, form.btn_sell, "on_btn_sell_click")
  button_sell.homeid = homeid
  if is_my_home(homeid) then
    if nx_int(homestatus) == nx_int(HOME_STATUS_LIVE) then
      button_sell.Visible = true
      button_shopinfo.Visible = false
    end
    if nx_int(homestatus) == nx_int(HOME_STATUS_SELL) then
      button_sell.Visible = false
      button_shopinfo.Visible = true
    end
  else
    button_sell.Visible = false
    button_shopinfo.Visible = false
  end
  local button_buy = gui:Create("Button")
  groupbox:Add(button_buy)
  button_buy.Name = "button_buy" .. nx_string(number)
  clone_button(button_buy, form.btn_buy, "on_btn_buy_click")
  button_buy.homeid = homeid
  if is_my_home(homeid) then
    button_buy.Visible = false
  elseif nx_int(homestatus) == nx_int(HOME_STATUS_SELL) then
    button_buy.Visible = true
  else
    button_buy.Visible = false
  end
  return groupbox
end
function clone_lable(lable, modd)
  if not nx_is_valid(lable) then
    return
  end
  if not nx_is_valid(modd) then
    return
  end
  lable.Left = modd.Left
  lable.Top = modd.Top
  lable.Width = modd.Width
  lable.Height = modd.Height
  lable.ForeColor = modd.ForeColor
  lable.Font = modd.Font
  lable.Text = modd.Text
  lable.Align = modd.Align
end
function clone_button(button, modd, click_function)
  if not nx_is_valid(button) then
    return
  end
  if not nx_is_valid(modd) then
    return
  end
  button.Left = modd.Left
  button.Top = modd.Top
  button.Width = modd.Width
  button.Height = modd.Height
  button.ForeColor = modd.ForeColor
  button.LineColor = modd.LineColor
  button.BackColor = modd.BackColor
  button.Font = modd.Font
  button.Text = modd.Text
  button.AutoSize = modd.AutoSize
  button.DrawMode = modd.DrawMode
  button.InSound = modd.InSound
  button.OutSound = modd.OutSound
  button.ClickSound = modd.ClickSound
  button.NormalImage = modd.NormalImage
  button.FocusImage = modd.FocusImage
  button.HintText = modd.HintText
  button.PushImage = modd.PushImage
  nx_bind_script(button, nx_current())
  nx_callback(button, "on_click", nx_string(click_function))
end
function clone_groupbox(groupbox, modd)
  if not nx_is_valid(groupbox) then
    return
  end
  if not nx_is_valid(modd) then
    return
  end
  groupbox.Width = modd.Width
  groupbox.Height = modd.Height
  groupbox.ForeColor = modd.ForeColor
  groupbox.BackColor = modd.BackColor
  groupbox.LineColor = modd.LineColor
  groupbox.NoFrame = modd.NoFrame
  groupbox.BackImage = modd.BackImage
  groupbox.AutoSize = modd.AutoSize
  groupbox.DrawMode = modd.DrawMode
end
