require("util_gui")
require("util_functions")
require("share\\view_define")
require("define\\map_lable_define")
local CLIENT_SUB_ROUND_BEGIN = 1
local CLIENT_SUB_ROUND_CANCEL = 2
local CLIENT_SUB_PAY_SHOW_MONEY = 3
local CLIENT_SUB_CHOOSE_ACTION = 10
local CLIENT_SUB_GIVE_WISHING = 11
local CLIENT_SUB_SCORE_DONGFANG = 21
local CLIENT_SUB_REQUEST_MARRY_POS = 30
local SERVER_SUB_OPEN_WINDOW = 1
local SERVER_SUB_SELECTN_ITEM = 2
local SERVER_SUB_SCORE_DONGFANG = 3
local SERVER_SUB_PAY_SHOW_MONEY = 4
local SERVER_SUB_REQUEST_MARRY_POS = 10
local TYPE_XIN_MALE = 1
local TYPE_XIN_LADY = 2
local TOPICAL_COUNT = 4
local DONGFANG_ACT_INI = "share\\InterActive\\DongFang\\dongfang_act.ini"
function main_form_init(form)
  form.Fixed = false
  form.time = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  set_item(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("DongFangNum", "int", form, nx_current(), "on_DongFangNum_change")
  end
  form.lbl_bg.BackImage = "gui\\special\\marry\\dongfang\\df_back_1.png"
  form.mltbox_text.HtmlText = nx_widestr(gui.TextManager:GetText("ui_jhndf_01"))
  on_refresh_score(form)
  local timer = nx_value(GAME_TIMER)
  timer:Register(10000, -1, nx_current(), "on_refresh_score", form, -1, -1)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelRolePropertyBind("DongFangNum", form)
  end
  nx_destroy(form)
end
function on_main_form_shut(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister("form_stage_main\\form_marry\\form_dongfang_info", "on_refresh_score", self)
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_refuel_click(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local man_type = client_player:QueryProp("DongFangRuleType")
  if nx_int(man_type) > nx_int(2) then
    nx_execute("custom_sender", "custom_dongfang_msg", CLIENT_SUB_GIVE_WISHING)
  end
end
function on_btn_ready_click(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local man_type = client_player:QueryProp("DongFangRuleType")
  if nx_int(man_type) == nx_int(1) then
    nx_execute("custom_sender", "custom_dongfang_msg", CLIENT_SUB_ROUND_BEGIN)
  end
end
function on_btn_end_click(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local man_type = client_player:QueryProp("DongFangRuleType")
  if nx_int(man_type) ~= nx_int(TYPE_XIN_MALE) then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetText("ui_dongfang_end_confirm"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_dongfang_msg", CLIENT_SUB_ROUND_CANCEL)
  end
end
function on_btn_item_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local count = self.DataSource
  for i = 1, TOPICAL_COUNT do
    if nx_int(count) == nx_int(i) then
      form.lbl_bg.BackImage = "gui\\special\\marry\\dongfang\\df_back_" .. i .. ".png"
      form.mltbox_text.HtmlText = nx_widestr(gui.TextManager:GetText("ui_jhndf_0" .. i))
    end
  end
end
function on_btn_help_click(self)
  util_auto_show_hide_form("form_stage_main\\form_marry\\form_dongfang_bz", true)
end
function on_msg(sub_cmd, ...)
  if nx_int(sub_cmd) == nx_int(SERVER_SUB_OPEN_WINDOW) then
    local form = util_get_form("form_stage_main\\form_marry\\form_dongfang_info", true)
    if not nx_is_valid(form) then
      return
    end
    form.lbl_bridegroom.Text = nx_widestr(arg[1])
    form.lbl_bride.Text = nx_widestr(arg[2])
    form.lbl_choice_man.Text = nx_widestr(arg[3])
    form.time = nx_int(arg[4] / nx_int64(1000))
    set_time(form)
    util_show_form("form_stage_main\\form_marry\\form_dongfang_info", true)
  elseif nx_int(sub_cmd) == nx_int(SERVER_SUB_SELECTN_ITEM) then
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_marry\\form_dongfang_select", true)
    nx_execute("form_stage_main\\form_marry\\form_dongfang_select", "refresh_btn_enabled", nx_number(arg[1]), nx_number(arg[2]))
  elseif nx_int(sub_cmd) == nx_int(SERVER_SUB_SCORE_DONGFANG) then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_marry\\form_dongfang_info", false)
    if not nx_is_valid(form) then
      return
    end
    form.lbl_score.Text = nx_widestr(arg[1])
  elseif nx_int(sub_cmd) == nx_int(SERVER_SUB_PAY_SHOW_MONEY) then
    show_confirm_pay_form()
  elseif nx_int(sub_cmd) == nx_int(SERVER_SUB_REQUEST_MARRY_POS) then
    local man_x = arg[1]
    local man_z = arg[2]
    local woman_x = arg[3]
    local woman_z = arg[4]
    local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
    if nx_is_valid(form_map) and form_map.Visible == true then
      nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", MARRY_MAN, man_x, man_z)
      nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", MARRY_WOMAN, woman_x, woman_z)
    end
  end
end
function set_item(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local man_type = client_player:QueryProp("DongFangRuleType")
  if nx_int(man_type) == nx_int(1) then
    form.btn_refuel.Enabled = false
    form.btn_ready.Enabled = true
    form.btn_end.Enabled = true
  elseif nx_int(man_type) > nx_int(2) then
    form.btn_refuel.Enabled = true
    form.btn_ready.Enabled = false
    form.btn_end.Enabled = false
  else
    form.btn_refuel.Enabled = false
    form.btn_ready.Enabled = false
    form.btn_end.Enabled = false
  end
end
function on_refresh_score(form)
  nx_execute("custom_sender", "custom_dongfang_msg", CLIENT_SUB_SCORE_DONGFANG)
end
function set_item(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local man_type = client_player:QueryProp("DongFangRuleType")
  if nx_int(man_type) == nx_int(TYPE_XIN_MALE) then
    form.btn_refuel.Enabled = false
    form.btn_ready.Enabled = true
    form.btn_end.Enabled = true
  elseif nx_int(man_type) == nx_int(TYPE_XIN_LADY) then
    form.btn_refuel.Enabled = false
    form.btn_ready.Enabled = false
    form.btn_end.Enabled = false
  else
    form.btn_refuel.Enabled = true
    form.btn_ready.Enabled = false
    form.btn_end.Enabled = false
  end
end
function set_time(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.time) <= nx_int(0) then
    return
  end
  local time_text = ""
  local hour = nx_int(form.time / 3600)
  local minute = nx_int(form.time % 3600 / 60)
  local second = nx_int(form.time % 60)
  time_text = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(minute), nx_number(second))
  form.lbl_time.Text = nx_widestr(time_text)
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_show_time", form, -1, -1)
end
function on_show_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.time = form.time - nx_int(1)
  local time_text = ""
  local hour = nx_int(form.time / 3600)
  local minute = nx_int(form.time % 3600 / 60)
  local second = nx_int(form.time % 60)
  time_text = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(minute), nx_number(second))
  form.lbl_time.Text = nx_widestr(time_text)
  if nx_int(form.time) == nx_int(0) then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_show_time", form)
    end
  end
end
function show_confirm_pay_form()
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_text("ui_dongfang_confirm_pay_show")))
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_dongfang_msg", CLIENT_SUB_PAY_SHOW_MONEY)
  end
end
function on_DongFangNum_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local room_id = client_player:QueryProp("DongFangNum")
  if nx_int(room_id) <= nx_int(0) then
    form:Close()
  end
end
function show_marry_pos(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local wedding_rite = client_scene:QueryProp("WeddingRite")
  if nx_int(wedding_rite) <= nx_int(0) or form.Visible == false then
    return
  end
  nx_execute("custom_sender", "custom_dongfang_msg", nx_int(CLIENT_SUB_REQUEST_MARRY_POS))
end
function hide_marry_pos(form)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", MARRY_MAN)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", MARRY_WOMAN)
end
