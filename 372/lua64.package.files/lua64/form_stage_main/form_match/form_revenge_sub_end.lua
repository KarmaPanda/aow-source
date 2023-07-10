require("util_functions")
require("util_gui")
FORM_PATH = "form_stage_main\\form_match\\form_revenge_sub_end"
ALL_FORM_PATH = "form_stage_main\\form_match\\form_revenge_all_end"
local hurt_type = {
  [1] = "ui_Match_end1_1",
  [2] = "ui_Match_end1_6",
  [3] = "ui_Match_end1_5",
  [4] = "ui_Match_end1_3",
  [5] = "ui_Match_end1_4",
  [6] = "ui_Match_end1_10",
  [7] = "ui_Match_end1_2",
  [8] = "ui_Match_end1_9",
  [9] = "ui_Match_end1_8",
  [10] = "ui_Match_end1_7",
  [11] = "ui_Match_end1_11"
}
local win_hurt_data = {}
local lost_hurt_data = {}
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  local all_form = nx_value(ALL_FORM_PATH)
  if nx_is_valid(all_form) then
    form.Left = 150
    form.Top = (gui.Height - form.Height) / 2
    all_form.Left = gui.Width / 2 + 100
    all_form.Top = (gui.Height - form.Height) / 2
  else
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.grid_battle.CanSelectRow = false
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
function open_form(...)
  local win_name = nx_widestr(arg[1])
  local win_school = nx_string(arg[2])
  local win_guild = nx_widestr(arg[3])
  local win_point = nx_int(arg[4])
  local win_hurt = nx_string(arg[5])
  local lost_name = nx_widestr(arg[6])
  local lost_school = nx_string(arg[7])
  local lost_guild = nx_widestr(arg[8])
  local lost_point = nx_int(arg[9])
  local lost_hurt = nx_string(arg[10])
  util_show_form(FORM_PATH, true)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.lbl_win_name.Text = nx_widestr(win_name)
  form.lbl_win_guild.Text = nx_widestr(win_guild)
  form.lbl_win_point.Text = nx_widestr(win_point)
  if nx_string(win_school) == "" then
    form.lbl_win_school.Text = nx_widestr(util_text("ui_Match_end_wmp"))
  else
    form.lbl_win_school.Text = nx_widestr(util_text(win_school))
  end
  local win_hurt = nx_string(win_hurt)
  local win_hurt_list = util_split_string(win_hurt, ";")
  for i = 1, table.getn(win_hurt_list) do
    win_hurt_data[i] = win_hurt_list[i]
  end
  form.lbl_lost_name.Text = nx_widestr(lost_name)
  form.lbl_lost_guild.Text = nx_widestr(lost_guild)
  form.lbl_lost_point.Text = nx_widestr(lost_point)
  if nx_string(lost_school) == "" then
    form.lbl_lost_school.Text = nx_widestr(util_text("ui_Match_end_wmp"))
  else
    form.lbl_lost_school.Text = nx_widestr(util_text(lost_school))
  end
  local lost_hurt = nx_string(lost_hurt)
  local lost_hurt_list = util_split_string(lost_hurt, ";")
  for i = 1, table.getn(lost_hurt_list) do
    lost_hurt_data[i] = lost_hurt_list[i]
  end
  if table.getn(win_hurt_list) ~= table.getn(lost_hurt_list) or table.getn(win_hurt_list) ~= table.getn(hurt_type) or table.getn(lost_hurt_list) ~= table.getn(hurt_type) then
    return
  end
  local win_single = 0
  local lost_single = 0
  local label = gui:Create("Label")
  label.BackImage = "gui\\special\\tianti\\end\\good.png"
  label.AutoSize = true
  form.grid_battle:ClearRow()
  for i = 1, table.getn(hurt_type) do
    if i < 11 then
      local row = form.grid_battle:InsertRow(-1)
      if nx_int(win_hurt_data[i]) > nx_int(lost_hurt_data[i]) then
        form.grid_battle:SetGridControl(row, 0, label)
        win_single = win_single + 1
      elseif nx_int(win_hurt_data[i]) < nx_int(lost_hurt_data[i]) then
        form.grid_battle:SetGridControl(row, 4, label)
        lost_single = lost_single + 1
      end
      form.grid_battle:SetGridText(row, 1, nx_widestr(win_hurt_data[i]))
      form.grid_battle:SetGridText(row, 2, nx_widestr(util_text(hurt_type[i])))
      form.grid_battle:SetGridText(row, 3, nx_widestr(lost_hurt_data[i]))
    end
  end
  form.lbl_win_single.Text = nx_widestr(win_single)
  form.lbl_lost_single.Text = nx_widestr(lost_single)
end
