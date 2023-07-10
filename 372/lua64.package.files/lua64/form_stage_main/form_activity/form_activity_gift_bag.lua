require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_activity\\form_activity_gift_bag"
local col_count = 3
local grid_table = {
  [1] = {col_width_per = 2, col_title = "ui_paiming"},
  [2] = {
    col_width_per = 2,
    col_title = "ui_roleinfo_name"
  },
  [3] = {
    col_width_per = 2,
    col_title = "ui_submit_total_num"
  }
}
local grid_per_base_num = 6
local CLIENT_CUSTOMMSG_ACTIVITY_MANAGE = 182
local CLIENT_SUBMSG_REQUEST_HANDIN_GIFTBAG = 3
local CLIENT_SUBMSG_REQUEST_HANDIN_INFO = 5
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  init_controls(form)
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  nx_set_value(FORM_NAME, form)
  clear_grid(form)
  request_gift_data()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_set_value(FORM_NAME, nx_null())
  nx_destroy(form)
end
function on_btn_close_click(btn_close)
  local form = btn_close.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_submit_click(self)
  local form = self.ParentForm
  request_submit()
  form:Close()
end
function on_rec_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  clear_grid(form)
  local size = table.getn(arg) - 3
  if size <= 0 or size % 2 ~= 0 then
    return
  end
  local grid = form.textgrid
  if not nx_is_valid(grid) then
    return
  end
  form.lbl_self_submit_num.Text = nx_widestr(arg[1])
  form.lbl_take_num.Text = nx_widestr(arg[2]) .. nx_widestr("/") .. nx_widestr(arg[3])
  local cache_table = {}
  for j = 1, size / 2 do
    local temp_index = (j - 1) * 2 + 4
    if nx_int(arg[temp_index + 1]) > nx_int(0) then
      table.insert(cache_table, {
        arg[temp_index],
        arg[temp_index + 1]
      })
    end
  end
  table.sort(cache_table, function(a, b)
    return a[2] > b[2]
  end)
  grid:BeginUpdate()
  for i = 1, table.getn(cache_table) do
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(row + 1))
    grid:SetGridText(row, 1, nx_widestr(cache_table[i][1]))
    grid:SetGridText(row, 2, nx_widestr(cache_table[i][2]))
  end
  grid:EndUpdate()
end
function request_gift_data()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_HANDIN_INFO))
end
function request_submit()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local number = nx_int(form.txt_number.Text)
  if nx_int(number) <= nx_int(0) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_HANDIN_GIFTBAG), nx_int(number))
end
function init_controls(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  local grid_width = grid.Width - 30
  for i = 1, table.getn(grid_table) do
    grid:SetColWidth(i - 1, grid_width / grid_per_base_num * nx_int(grid_table[i].col_width_per))
    grid:SetColTitle(i - 1, nx_widestr(util_text(nx_string(grid_table[i].col_title))))
  end
  grid:EndUpdate()
end
function clear_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid
  grid:BeginUpdate()
  grid:ClearRow()
  grid:EndUpdate()
end
function on_btn_info_click(btn)
  nx_function("ext_open_url", "http://9yin.woniu.com/web3/news/news_detail.asp?id=140482%20&CategoryID=3452")
end
