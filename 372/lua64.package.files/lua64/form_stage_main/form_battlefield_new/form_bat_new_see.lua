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
local FORM_NAME = "form_stage_main\\form_battlefield_new\\form_bat_new_see"
local CLIENT_SUB_REQ_STOP_SEE = 521
local CLIENT_SUB_REQ_SEE_WAR = 523
local CLIENT_SUB_REQ_MEMBER = 524
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = gui.Width - form.Width
  form.Top = (gui.Height - form.Height) / 2
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_REQ_MEMBER))
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  on_main_form_close(form)
end
function open_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
    form:Show()
  else
    util_show_form(FORM_NAME, true)
  end
end
function close_form()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  on_main_form_close(form)
end
function show_war_member(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local info_table = {}
  local count = table.getn(arg)
  for i = 1, count do
    local info_list = util_split_wstring(arg[i], ",")
    local no = nx_widestr(info_list[1])
    local name = nx_widestr(info_list[2])
    table.insert(info_table, {no, name})
  end
  local gb_1 = form.groupbox_1
  local gb_2 = form.groupbox_2
  for i = 1, 6 do
    local lbl_t1 = gb_1:Find("lbl_t1_name_" .. nx_string(i))
    local lbl_t2 = gb_2:Find("lbl_t2_name_" .. nx_string(i))
    local btn_t1 = gb_1:Find("btn_see_t1_" .. nx_string(i))
    local btn_t2 = gb_2:Find("btn_see_t2_" .. nx_string(i))
    if nx_is_valid(lbl_t1) and nx_is_valid(lbl_t2) and nx_is_valid(btn_t1) and nx_is_valid(btn_t2) then
      lbl_t1.Visible = false
      lbl_t2.Visible = false
      btn_t1.Visible = false
      btn_t2.Visible = false
    end
  end
  local index_1 = 0
  local index_2 = 0
  for i = 1, table.getn(info_table) do
    if nx_int(info_table[i][1]) == nx_int(1) then
      local gb = form.groupbox_1
      index_1 = index_1 + 1
      local lbl_name = gb:Find("lbl_t1_name_" .. nx_string(index_1))
      local btn_see = gb:Find("btn_see_t1_" .. nx_string(index_1))
      if nx_is_valid(lbl_name) and nx_is_valid(btn_see) then
        lbl_name.Visible = true
        btn_see.Visible = true
        lbl_name.Text = nx_widestr(info_table[i][2])
        btn_see.player_name = nx_widestr(info_table[i][2])
      end
    elseif nx_int(info_table[i][1]) == nx_int(2) then
      local gb = form.groupbox_2
      index_2 = index_2 + 1
      local lbl_name = gb:Find("lbl_t2_name_" .. nx_string(index_2))
      local btn_see = gb:Find("btn_see_t2_" .. nx_string(index_2))
      if nx_is_valid(lbl_name) and nx_is_valid(btn_see) then
        lbl_name.Visible = true
        btn_see.Visible = true
        lbl_name.Text = nx_widestr(info_table[i][2])
        btn_see.player_name = nx_widestr(info_table[i][2])
      end
    end
  end
end
function on_btn_see_click(btn)
  if nx_widestr(btn.player_name) == nx_widestr("") then
    return
  end
  local target_name = btn.player_name
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_REQ_SEE_WAR), nx_widestr(target_name))
end
function on_btn_quit_see_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_REQ_STOP_SEE))
end
function a(q)
  nx_msgbox(nx_string(q))
end
