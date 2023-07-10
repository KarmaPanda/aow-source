require("util_gui")
require("util_functions")
require("util_static_data")
local FORM_NAME = "form_stage_main\\form_skyhill\\form_sanhill_rank"
local master_col = 1
local helper_col = 2
local pub_times_col = 3
local self_times_col = 4
local success_num_col = 5
local col_count = 5
function on_main_form_init(form)
end
function on_main_form_open(form)
  nx_execute("custom_sender", "custom_sanhill_msg", 8)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local temp_table = arg
  local gui = nx_value("gui")
  local grid = form.rank_grid
  grid:ClearRow()
  local size = nx_number(table.getn(temp_table)) / nx_number(col_count)
  local index = 1
  for i = index, size do
    local master_name = nx_widestr(temp_table[(i - 1) * col_count + master_col])
    local helper_name = nx_widestr(temp_table[(i - 1) * col_count + helper_col])
    local pub_times = nx_widestr(temp_table[(i - 1) * col_count + pub_times_col])
    local self_times = nx_widestr(temp_table[(i - 1) * col_count + self_times_col])
    local success_num = nx_widestr(temp_table[(i - 1) * col_count + success_num_col])
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(row + 1))
    grid:SetGridText(row, 1, nx_widestr(master_name))
    grid:SetGridText(row, 2, nx_widestr(helper_name))
    grid:SetGridText(row, 3, nx_widestr(pub_times))
    grid:SetGridText(row, 4, nx_widestr(self_times))
    grid:SetGridText(row, 5, nx_widestr(success_num))
  end
end
