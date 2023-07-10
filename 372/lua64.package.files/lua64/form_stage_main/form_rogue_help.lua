require("util_gui")
require("util_functions")
require("custom_sender")
require("role_composite")
require("util_static_data")
require("util_gui")
require("util_functions")
require("util_static_data")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_attribute_mall\\form_attribute_shop")
require("form_stage_main\\switch\\switch_define")
require("define\\sysinfo_define")
require("form_stage_main\\form_tvt\\define")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
local FORM_NAME = "form_stage_main\\form_rogue_help"
local ROGUE_CONFIG = "share\\War\\Rogue\\Rogue.ini"
local ROGUE_CLIENT_MSG_RES_LV = 3
table_box_name = {
  "rogue_box_1",
  "rogue_box_2",
  "rogue_box_3",
  "rogue_box_4",
  "rogue_box_5",
  "rogue_box_6",
  "rogue_box_7",
  "rogue_box_8",
  "rogue_box_9",
  "rogue_box_10",
  "rogue_box_11",
  "rogue_box_12",
  "rogue_box_13",
  "rogue_box_14",
  "rogue_box_15"
}
table_box_pos = {
  "1448,1549",
  "1500,1474",
  "1551,1442",
  "1540,1458",
  "1330,1450",
  "1451,1454",
  "1492,1427",
  "1581,1365",
  "1466,1359",
  "1384,1330",
  "1310,1362",
  "1353,1251",
  "1369,1186",
  "1537,1186",
  "1434,1121"
}
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_ctrl(form)
end
function init_ctrl(form)
  if not nx_is_valid(form) then
    return
  end
  local gb = form.groupbox_desc
  local lbl_name_mod = form.lbl_name_mod
  local lbl_pos_mod = form.lbl_pos_mod
  local lbl_lv_mod = form.lbl_lv_mod
  local lbl_name_str = "lbl_name_"
  local lbl_pos_str = "lbl_pos_"
  local lbl_lv_str = "lbl_lv_"
  gb.IsEditMode = true
  for i = 1, 15 do
    local lbl_name = create_ctrl("Label", nx_string(lbl_name_str) .. nx_string(i), lbl_name_mod, gb)
    lbl_name.Top = (i - 1) * lbl_name.Height + 2
    lbl_name.Left = 5
    lbl_name.Text = nx_widestr(util_text(table_box_name[i]))
    local lbl_pos = create_ctrl("Label", nx_string(lbl_pos_str) .. nx_string(i), lbl_pos_mod, gb)
    lbl_pos.Top = (i - 1) * lbl_pos.Height + 2
    lbl_pos.Left = 100
    lbl_pos.Text = nx_widestr(nx_string(table_box_pos[i]))
    local lbl_lv = create_ctrl("Label", nx_string(lbl_lv_str) .. nx_string(i), lbl_lv_mod, gb)
    lbl_lv.Top = (i - 1) * lbl_lv.Height + 2
    lbl_lv.Left = 200
    lbl_lv.Text = nx_widestr(nx_string("0") .. nx_string("/1"))
  end
  gb.IsEditMode = false
  gb.Height = gb.Height
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "reduce_move_bar", self)
  end
  nx_destroy(self)
end
function open_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_NAME, true)
  end
  custom_request_lv_data()
end
function close_form(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    on_main_form_close(form)
  end
end
function custom_request_lv_data()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ROGUE), nx_int(ROGUE_CLIENT_MSG_RES_LV))
end
function updata_lv_data(...)
  if 15 ~= #arg then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gb = form.groupbox_desc
  for i = 1, #arg do
    local lbl_lv_name = nx_string("lbl_lv_") .. nx_string(i)
    local lbl_lv = gb:Find(nx_string(lbl_lv_name))
    if nx_is_valid(lbl_lv) then
      lbl_lv.Text = nx_widestr(nx_string(arg[i]) .. nx_string("/1"))
    end
  end
end
function on_btn_close_click(btn)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    on_main_form_close(form)
  end
end
function close_form(...)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    on_main_form_close(form)
  end
end
function a(info)
  nx_msgbox(nx_string(info))
end
