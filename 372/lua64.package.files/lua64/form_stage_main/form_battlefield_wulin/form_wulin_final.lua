require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\sysinfo_define")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
require("custom_sender")
local FORM_WULIN_FINAL = "form_stage_main\\form_battlefield_wulin\\form_wulin_final"
local array_final = {
  [1] = {
    turn_name = "ui_wudaodahui_gm_1"
  },
  [2] = {
    turn_name = "ui_wudaodahui_gm_2"
  },
  [3] = {
    turn_name = "ui_wudaodahui_gm_3"
  },
  [4] = {
    turn_name = "ui_wudaodahui_gm_4"
  },
  [5] = {
    turn_name = "ui_wudaodahui_gm_4"
  },
  [6] = {
    turn_name = "ui_wudaodahui_gm_4"
  },
  [7] = {
    turn_name = "ui_wudaodahui_gm_4"
  }
}
local array_match = {
  [1] = {},
  [2] = {
    1,
    1,
    1,
    2,
    1,
    3,
    1,
    4,
    1,
    5,
    1,
    6,
    1,
    7,
    1,
    8,
    1,
    1,
    1,
    2,
    1,
    3,
    1,
    4,
    1,
    5,
    1,
    6,
    1,
    7,
    1,
    8
  },
  [3] = {
    2,
    5,
    2,
    6,
    2,
    1,
    2,
    2,
    2,
    7,
    2,
    8,
    2,
    3,
    2,
    4
  },
  [4] = {
    2,
    1,
    2,
    2,
    2,
    3,
    2,
    4,
    3,
    1,
    3,
    2,
    3,
    3,
    3,
    4
  },
  [5] = {
    4,
    3,
    4,
    4,
    4,
    1,
    4,
    2
  },
  [6] = {
    4,
    1,
    4,
    2,
    5,
    1,
    5,
    2
  },
  [7] = {
    6,
    1,
    6,
    2
  }
}
function open_form()
  local form = get_form()
  if nx_is_valid(form) then
    form:Close()
  else
    util_show_form(FORM_WULIN_FINAL, true)
  end
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  self.player_type = nx_int(0)
  init_all_turn()
  request_final_ui()
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function on_btn_save_click(btn)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local turn = btn.turn
  local turn_info = array_final[turn]
  local edit_tip = turn_info.header_ipt_tip
  request_set_tip(turn, edit_tip.Text)
end
function on_btn_choose_click(btn)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local team_control = get_team_control(btn.turn, btn.row)
  local listbox_team = team_control.listbox_team
  listbox_team.Visible = not listbox_team.Visible
  if listbox_team.Visible then
    local match = array_match[btn.turn]
    local team1_turn = match[(btn.row - 1) * 4 + 1]
    local team1_index = match[(btn.row - 1) * 4 + 2]
    local team2_turn = match[(btn.row - 1) * 4 + 3]
    local team2_index = match[(btn.row - 1) * 4 + 4]
    local team1_control = get_team_control(team1_turn, team1_index)
    local team2_control = get_team_control(team2_turn, team2_index)
    local team1_name = get_team_name(team1_control)
    local team2_name = get_team_name(team2_control)
    listbox_team:ClearString()
    listbox_team:AddString(team1_name)
    listbox_team:AddString(team2_name)
    local now_team_name = get_team_name(team_control)
    if now_team_name == team1_name then
      listbox_team.SelectIndex = 0
    elseif now_team_name == team2_name then
      listbox_team.SelectIndex = 1
    end
    team_control.Height = team_control.original_height
    form:ToFront(team_control)
  else
    team_control.Height = listbox_team.Top
  end
end
function on_team_list_select_click(list)
  if list.SelectIndex < 0 then
    return
  end
  local team_name = nx_string(list.SelectString)
  request_set_team(list.turn, list.row, team_name)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function request_final_ui()
  custom_wudao(nx_int(305))
end
function request_set_tip(turn, tip)
  custom_wudao(nx_int(306), nx_int(turn), nx_widestr(tip))
end
function request_set_team(turn, row, team_name)
  custom_wudao(nx_int(307), nx_int(turn), nx_int(row), nx_widestr(team_name))
end
function receive_final_ui(...)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local n = #arg
  if n < 1 then
    return
  end
  form.player_type = nx_int(arg[1])
  for turn = 1, 7 do
    clear_turn(turn)
  end
  if 2 <= n then
    for i = 2, n do
      local one_turn_text = arg[i]
      show_turn(one_turn_text)
    end
  end
end
function receive_final_ui_one_group(...)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local n = #arg
  if n <= 0 then
    return
  end
  local one_turn_text = arg[1]
  show_turn(one_turn_text)
end
function init_all_turn()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local turn_info = array_final[1]
  turn_info.array_team_control = {
    form.lbl_16,
    form.lbl_17,
    form.lbl_18,
    form.lbl_19,
    form.lbl_20,
    form.lbl_21,
    form.lbl_22,
    form.lbl_23
  }
  turn_info.header_ipt_tip = form.groupbox_2:Find("ipt_1")
  turn_info.header_btn_save = form.groupbox_2:Find("btn_1")
  turn_info = array_final[2]
  turn_info.array_team_control = {
    form.groupbox_8,
    form.groupbox_9,
    form.groupbox_10,
    form.groupbox_11,
    form.groupbox_12,
    form.groupbox_13,
    form.groupbox_14,
    form.groupbox_15
  }
  turn_info.header_ipt_tip = form.groupbox_3:Find("ipt_2")
  turn_info.header_btn_save = form.groupbox_3:Find("btn_2")
  turn_info = array_final[3]
  turn_info.array_team_control = {
    form.groupbox_20,
    form.groupbox_21,
    form.groupbox_22,
    form.groupbox_23
  }
  turn_info.header_ipt_tip = form.groupbox_4:Find("ipt_3")
  turn_info.header_btn_save = form.groupbox_4:Find("btn_3")
  turn_info = array_final[4]
  turn_info.array_team_control = {
    form.groupbox_16,
    form.groupbox_17,
    form.groupbox_24,
    form.groupbox_25
  }
  turn_info.header_ipt_tip = form.groupbox_5:Find("ipt_4")
  turn_info.header_btn_save = form.groupbox_5:Find("btn_4")
  turn_info = array_final[5]
  turn_info.array_team_control = {
    form.groupbox_26,
    form.groupbox_27
  }
  turn_info.header_ipt_tip = form.groupbox_6:Find("ipt_5")
  turn_info.header_btn_save = form.groupbox_6:Find("btn_5")
  turn_info = array_final[6]
  turn_info.array_team_control = {
    form.groupbox_18,
    form.groupbox_28
  }
  turn_info.header_ipt_tip = form.groupbox_7:Find("ipt_6")
  turn_info.header_btn_save = form.groupbox_7:Find("btn_6")
  turn_info = array_final[7]
  turn_info.array_team_control = {
    form.groupbox_19
  }
  replace(2, 1, 2, 1)
  replace(2, 1, 2, 2)
  replace(2, 1, 2, 3)
  replace(2, 1, 2, 4)
  replace(2, 5, 2, 5)
  replace(2, 5, 2, 6)
  replace(2, 5, 2, 7)
  replace(2, 5, 2, 8)
  replace(2, 1, 3, 1)
  replace(2, 1, 3, 3)
  replace(2, 5, 3, 2)
  replace(2, 5, 3, 4)
  replace(2, 1, 4, 1)
  replace(2, 1, 4, 2)
  replace(2, 1, 4, 3)
  replace(2, 1, 4, 4)
  replace(2, 1, 5, 1)
  replace(2, 5, 5, 2)
  replace(2, 1, 6, 1)
  replace(2, 1, 6, 2)
  replace(2, 1, 7, 1)
  for turn = 1, 7 do
    init_turn(turn)
  end
end
function init_turn(turn)
  local turn_info = array_final[turn]
  if turn_info == nil then
    return
  end
  local turn_info = array_final[turn]
  local btn_save = turn_info.header_btn_save
  if nx_is_valid(btn_save) then
    btn_save.turn = turn
    nx_bind_script(btn_save, nx_current())
    nx_callback(btn_save, "on_click", "on_btn_save_click")
  end
  for i = 1, #turn_info.array_team_control do
    local team_control = turn_info.array_team_control[i]
    team_control.turn = turn
    team_control.row = i
  end
  clear_turn(turn)
end
function clear_turn(turn)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  if not is_turn_valid(turn) then
    return
  end
  local is_gm = is_player_gm()
  local turn_info = array_final[turn]
  if turn_info == nil then
    return
  end
  if turn_info.header_ipt_tip ~= nil then
    turn_info.header_ipt_tip.Text = nx_widestr("")
    turn_info.header_ipt_tip.HintText = nx_widestr("")
    turn_info.header_ipt_tip.ReadOnly = not is_gm
  end
  if turn_info.header_btn_save ~= nil then
    turn_info.header_btn_save.Visible = is_gm
  end
  for i = 1, #turn_info.array_team_control do
    local team_control = turn_info.array_team_control[i]
    if 1 >= team_control.turn then
      team_control.Text = nx_widestr("")
    else
      team_control.lbl_team_name.Text = nx_widestr("")
      team_control.listbox_team.Visible = false
      team_control.btn_choose.Visible = is_gm
      team_control.Height = team_control.listbox_team.Top
      if is_gm then
        team_control.lbl_team_name.Width = team_control.lbl_team_name.original_width
      else
        team_control.lbl_team_name.AutoSize = false
        team_control.lbl_team_name.DrawMode = "Expand"
        team_control.lbl_team_name.Width = team_control.lbl_team_name.original_width + 11
      end
    end
  end
end
function show_turn(one_turn_text)
  local one_turn = util_split_wstring(nx_widestr(one_turn_text), nx_widestr(","))
  local split_num = #one_turn
  local turn = tonumber(nx_string(one_turn[1]))
  local tip = nx_widestr(one_turn[2])
  if not is_turn_valid(turn) then
    return
  end
  clear_turn(turn)
  local is_gm = is_player_gm()
  local turn_info = array_final[turn]
  local team_count = #turn_info.array_team_control
  if turn_info.header_ipt_tip ~= nil then
    turn_info.header_ipt_tip.Text = tip
    turn_info.header_ipt_tip.HintText = tip
  end
  for index = 3, split_num do
    local row = index - 2
    if team_count < row then
      break
    end
    local team_name = nx_widestr(one_turn[index])
    local team_control = turn_info.array_team_control[row]
    if turn == 1 then
      team_control.Text = team_name
    else
      team_control.lbl_team_name.Text = team_name
    end
  end
end
function get_form()
  local form = nx_value(FORM_WULIN_FINAL)
  return form
end
function replace(from_turn, from_row, to_turn, to_row)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local from_turn_info = array_final[from_turn]
  local to_turn_info = array_final[to_turn]
  local from_control = from_turn_info.array_team_control[from_row]
  local to_control = to_turn_info.array_team_control[to_row]
  if not nx_is_valid(to_control) then
    return
  end
  local name = nx_string("team_") .. nx_string(to_turn) .. nx_string(to_row)
  local copy = clone(from_control, name)
  copy.Top = to_control.Top
  copy.Left = to_control.Left
  form:Add(copy)
  if from_row == 1 then
    copy.lbl_team_name = copy:Find("lbl_14")
    copy.lbl_result = copy:Find("lbl_15")
    copy.btn_choose = copy:Find("btn_7")
    copy.listbox_team = copy:Find("listbox_1")
  else
    copy.lbl_team_name = copy:Find("lbl_38")
    copy.lbl_result = copy:Find("lbl_39")
    copy.btn_choose = copy:Find("btn_11")
    copy.listbox_team = copy:Find("listbox_5")
  end
  nx_bind_script(copy.btn_choose, nx_current())
  nx_callback(copy.btn_choose, "on_click", "on_btn_choose_click")
  nx_bind_script(copy.listbox_team, nx_current())
  nx_callback(copy.listbox_team, "on_select_click", "on_team_list_select_click")
  copy.original_height = copy.Height
  copy.btn_choose.turn = to_turn
  copy.btn_choose.row = to_row
  copy.listbox_team.turn = to_turn
  copy.listbox_team.row = to_row
  copy.turn = to_turn
  copy.row = to_row
  copy.lbl_team_name.original_width = copy.lbl_team_name.Width
  local turn_info = array_final[to_turn]
  turn_info.array_team_control[to_row] = copy
  to_control.Visible = false
  copy.Visible = true
end
function clone(old_control, new_name)
  local gui = nx_value("gui")
  local copy = gui.Designer:Clone(old_control)
  if nx_is_valid(copy) then
    local child_list = old_control:GetChildControlList()
    for _, old_child in pairs(child_list) do
      if nx_is_valid(old_child) then
        local new_child = gui.Designer:Clone(old_child)
        new_child.fatherctl = new_control
        new_child.DesignMode = false
        new_child.Name = old_child.Name
        new_child.aid = aid
        copy:Add(new_child)
      end
    end
    copy.Name = nx_string(new_name)
    nx_bind_script(copy, nx_current())
    return copy
  end
end
function get_team_control(turn, row)
  if not is_turn_valid(turn) then
    return nil
  end
  local turn_info = array_final[turn]
  return turn_info.array_team_control[row]
end
function get_team_name(team_control)
  if team_control == nil then
    return nx_widestr("")
  end
  if team_control.turn == 1 then
    return team_control.Text
  else
    return team_control.lbl_team_name.Text
  end
end
function is_turn_valid(turn)
  if turn == nil then
    return false
  end
  local n = #array_final
  if turn <= 0 or turn > n then
    return false
  end
  return true
end
function is_player_gm()
  local form = get_form()
  if not nx_is_valid(form) then
    return false
  end
  return nx_int(form.player_type) == nx_int(4)
end
function l(info)
  nx_msgbox(nx_string(info))
end
function close_form()
  local form = get_form()
  if nx_is_valid(form) then
    form:Close()
  end
end
