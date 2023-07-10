require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
require("define\\sysinfo_define")
local stall_style_table
local level_step = {
  1,
  31,
  61,
  101,
  131,
  161,
  201,
  231,
  261,
  300
}
local stall_info = {
  name = "",
  stylename = "",
  stalltalk = "",
  price = {
    {
      0,
      0,
      0
    },
    {
      0,
      0,
      0
    },
    {
      0,
      0,
      0
    }
  }
}
function getjoblevel(rank)
  local level = 0
  for i = 1, table.getn(level_step) do
    if rank >= level_step[i] then
      level = level + 1
    end
  end
  return level
end
function init_style_table()
  local _data = {
    [1] = util_text("ui_gs_jm5"),
    [2] = util_text("ui_gs_jm6"),
    [3] = util_text("ui_gs_jm7")
  }
  return _data
end
local talking_text = {
  "ui_gs_hh1",
  "ui_gs_hh2",
  "ui_gs_hh3"
}
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function main_form_init(form)
  form.Fixed = false
  stall_style_table = init_style_table()
end
function show_stall_info(form)
  local visual_player = get_client_player()
  if not nx_is_valid(visual_player) then
    return
  end
  local stallstate = visual_player:QueryProp("FortuneTellingState")
  if stallstate ~= 2 then
    return
  end
  if nx_widestr(stall_info.name) ~= nx_widestr("") then
    form.edit_name.Text = nx_widestr(stall_info.name)
  end
  if nx_widestr(stall_info.stylename) ~= nx_widestr("") then
    form.combobox_style.Text = nx_widestr(stall_info.stylename)
  end
  if nx_widestr(stall_info.stalltalk) ~= nx_widestr("") then
    form.combobox_talk.Text = nx_widestr(stall_info.stalltalk)
  end
  for i, v in ipairs(stall_info.price) do
    for j = 1, 3 do
      local index = (i - 1) * 3 + j
      local edit = form.groupbox_1:Find("edit_" .. nx_string(index))
      edit.Text = nx_widestr(v[j])
    end
  end
end
function on_main_form_open(self)
  if not nx_execute("form_stage_main\\form_stall\\form_stall_main", "Stall_Fortunetell_Mutual", self, 1) then
    return
  end
  self.Fixed = false
  stall_style_table = init_style_table()
  self.combobox_style.InputEdit.Text = nx_widestr("")
  self.combobox_style.DropListBox:ClearString()
  for _, item_str in ipairs(stall_style_table) do
    self.combobox_style.DropListBox:AddString(nx_widestr(item_str))
  end
  self.combobox_style.Text = nx_widestr(stall_style_table[1])
  self.combobox_talk.InputEdit.Text = nx_widestr("")
  self.combobox_talk.DropListBox:ClearString()
  for i = 1, table.getn(talking_text) do
    local text = util_text(talking_text[i])
    self.combobox_talk.DropListBox:AddString(nx_widestr(text))
  end
  self.combobox_talk.Text = nx_widestr(util_text(talking_text[1]))
  self.btn_stall.Text = nx_widestr(util_text("ui_baitan005"))
  local visual_player = get_client_player()
  if nx_is_valid(visual_player) then
    local stallstate = visual_player:QueryProp("FortuneTellingState")
    if stallstate == 2 then
      self.btn_stall.Text = nx_widestr(util_text("ui_CancelStallBox"))
    end
  end
  local row = visual_player:FindRecordRow("job_rec", 0, "sh_gs", 0)
  local rank = 0
  if 0 <= row then
    rank = visual_player:QueryRecord("job_rec", row, 1)
  end
  local level = 2
  for i = 1, 3 do
    for j = 1, 3 do
      local temp = (i - 1) * 3 + j
      local type_lable = self.groupbox_1:Find("type_" .. nx_string(i))
      local edit = self.groupbox_1:Find("edit_" .. nx_string(temp))
      local edit_lable = self.groupbox_1:Find("edit_lbl_" .. nx_string(temp))
      if i <= level then
        type_lable.Visible = true
        edit.Visible = true
        edit_lable.Visible = true
      else
        type_lable.Visible = false
        edit.Visible = false
        edit_lable.Visible = false
      end
    end
  end
  show_stall_info(self)
  change_form_position(self, level)
end
function change_form_position(form, level)
  if 3 <= level or level <= 0 then
    return
  end
  local delat = form.groupbox_1.Height - form.groupbox_1.Height * level / 3
  form.groupbox_1.Height = form.groupbox_1.Height * level / 3
  form.groupbox_2.AbsTop = form.groupbox_2.AbsTop - delat
  form.Height = form.Height - delat
  form.groupbox_4.AbsTop = form.groupbox_4.AbsTop - delat
  form.lbl_9.Height = form.groupbox_3.Height + form.groupbox_1.Height + form.groupbox_4.Height
  form.lbl_3.AbsTop = form.lbl_9.AbsTop + form.lbl_9.Height - 5
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_btn_click(self)
  close_form()
end
function close_form()
  local form_talk = nx_value("form_stage_main\\form_life\\form_fortunetelling_op")
  if nx_is_valid(form_talk) then
    form_talk.Visible = false
    form_talk:Close()
  end
end
function end_fortunetelling()
  nx_execute("custom_sender", "custom_stop_fortunetelling")
end
function prepare_fortunetelling()
  local visual_player = get_client_player()
  if nx_is_valid(visual_player) then
    local stallstate = visual_player:QueryProp("FortuneTellingState")
    if stallstate ~= 0 then
      util_auto_show_hide_form("form_stage_main\\form_life\\form_fortunetelling_op")
    else
      nx_execute("custom_sender", "custom_repare_fortunetelling")
    end
  end
end
function check_stall_name(name)
  if name == nx_widestr("") then
    return false
  end
  local temp = nx_string(name)
  temp = string.gsub(temp, "%s+", "")
  return 0 < string.len(temp)
end
function check_stall_price(form)
  for i = 1, 3 do
    local index = (i - 1) * 3 + 1
    local edit = form.groupbox_1:Find("edit_" .. nx_string(index))
    if edit.Visible == true then
      local edit_1 = form.groupbox_1:Find("edit_" .. nx_string(index + 1))
      local edit_2 = form.groupbox_1:Find("edit_" .. nx_string(index + 2))
      if nx_widestr(edit.Text) == nx_widestr("") and nx_widestr(edit_1.Text) == nx_widestr("") and nx_widestr(edit_2.Text) == nx_widestr("") then
        return false
      end
    end
  end
  return true
end
function start_fortunetelling()
  local form_talk = nx_value("form_stage_main\\form_life\\form_fortunetelling_op")
  if nx_is_valid(form_talk) then
    form_talk.btn_stall.Text = nx_widestr(util_text("ui_CancelStallBox"))
  end
end
function on_stall_btn_click(self)
  local game_client = nx_value("game_client")
  local client_role = game_client:GetPlayer()
  if not nx_is_valid(client_role) then
    nx_log("no client player")
    return 0
  end
  local root = self.Parent.Parent
  local state = client_role:QueryProp("LogicState")
  if nx_int(state) ~= nx_int(LS_STALLED) then
    if nx_int(state) ~= nx_int(LS_NORMAL) and nx_int(state) ~= nx_int(LS_WARNING) then
      return 0
    end
    local name = nx_widestr(root.edit_name.Text)
    if not check_stall_name(name) or not check_stall_price(root) then
      local gui = nx_value("gui")
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
      dialog.info_label.Text = nx_widestr(util_text("ui_moneycannotbeempty"))
      if not check_stall_name(name) then
        dialog.info_label.Text = nx_widestr(util_text("ui_StallNameCanNotBeEmpty"))
      end
      dialog.Left = root.Left + (root.Width - dialog.Width) / 2
      dialog.Top = root.Top + (root.Height - dialog.Height) / 2
      dialog:ShowModal()
      nx_wait_event(100000000, dialog, "error_return")
      return 0
    end
    local cur_sel = root.combobox_style.DropListBox.SelectIndex + 1
    if cur_sel < 1 then
      cur_sel = 1
    end
    local role = nx_value("role")
    stall_info.name = root.edit_name.Text
    stall_info.stylename = root.combobox_style.Text
    stall_info.stalltalk = root.combobox_talk.Text
    for i = 1, 3 do
      for j = 1, 3 do
        local index = (i - 1) * 3 + j
        local edit = root.groupbox_1:Find("edit_" .. nx_string(index))
        stall_info.price[i][j] = nx_int(edit.Text)
      end
    end
    local sprite_price = nx_int(root.edit_1.Text) * 1000000 + nx_int(root.edit_2.Text) * 1000 + nx_int(root.edit_3.Text)
    local person_price = nx_int(root.edit_4.Text) * 1000000 + nx_int(root.edit_5.Text) * 1000 + nx_int(root.edit_6.Text)
    local god_price = nx_int(root.edit_7.Text) * 1000000 + nx_int(root.edit_8.Text) * 1000 + nx_int(root.edit_9.Text)
    nx_execute("custom_sender", "custom_begin_fortunetelling", root.edit_name.Text, cur_sel, root.combobox_talk.InputEdit.Text, sprite_price, person_price, god_price)
  else
    end_fortunetelling()
  end
end
