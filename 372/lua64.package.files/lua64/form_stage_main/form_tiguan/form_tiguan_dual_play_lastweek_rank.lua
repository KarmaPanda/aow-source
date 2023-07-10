require("util_gui")
require("util_functions")
require("form_stage_main\\form_tiguan\\form_tiguan_dual_play")
local FORM_TIGUAN_DUALPLAY_LASTWEEK_RANK = "form_stage_main\\form_tiguan\\form_tiguan_dual_play_lastweek_rank"
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
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
function open_form(rank_string)
  local form = util_show_form(FORM_TIGUAN_DUALPLAY_LASTWEEK_RANK, true)
  if nx_is_valid(form) then
    refresh_last_week_rank(rank_string)
  end
end
function on_btn_find_yourself_click(btn)
  local form = btn.ParentForm
  if not (nx_is_valid(form) and nx_find_custom(form, "self_row")) or form.self_row < 0 then
    return
  end
  form.textgrid_ranking:SelectRow(form.self_row)
end
function refresh_last_week_rank(rankstring)
  local form = nx_value(FORM_TIGUAN_DUALPLAY_LASTWEEK_RANK)
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local key_name = client_player:QueryProp("Name")
  local rank_string = nx_widestr(rankstring)
  if nx_ws_equal(nx_widestr(rank_string), nx_widestr("null")) or rank_string == nil then
    return
  end
  local rank_gird = form.textgrid_ranking
  if not nx_is_valid(rank_gird) then
    return
  end
  rank_gird:BeginUpdate()
  rank_gird:ClearRow()
  local COL_COUNT = 7
  local rank_name = "rank_srltzbs_geren_001"
  rank_gird.ColCount = COL_COUNT
  rank_gird.ColWidths = nx_string(get_rank_prop(rank_name, "ColWide"))
  rank_gird.HeaderBackColor = "0,255,255,255"
  local col_list = nx_function("ext_split_string", get_rank_prop(rank_name, "ColName"), ",")
  if table.getn(col_list) == COL_COUNT then
    for i = 1, COL_COUNT do
      local head_name = util_text(col_list[i])
      rank_gird:SetColTitle(i - 1, nx_widestr(head_name))
    end
  end
  local rank_type = get_rank_prop(rank_name, "Type")
  local main_type = get_rank_prop(rank_name, "MainType")
  local string_table = util_split_wstring(nx_widestr(rank_string), ",")
  form.self_row = -1
  local begin_index = 1
  for row = 0, 99 do
    if begin_index + COL_COUNT > table.getn(string_table) then
      break
    end
    rank_gird:InsertRow(-1)
    for index = 0, COL_COUNT - 1 do
      rank_gird:SetGridText(row, index, nx_widestr(string_table[begin_index]))
      if index == 1 then
        local last_test, last_color = get_last_no(rank_gird:GetGridText(row, 0), rank_gird:GetGridText(row, 1))
        rank_gird:SetGridText(row, 1, nx_widestr(last_test))
        rank_gird:SetGridForeColor(row, 1, last_color)
      end
      if index == 5 then
        rank_gird:SetGridText(row, index, util_text(nx_string(string_table[begin_index])))
      end
      begin_index = begin_index + 1
    end
    local temp_name = rank_gird:GetGridText(row, 2)
    if nx_ws_equal(nx_widestr(key_name), nx_widestr(temp_name)) then
      form.self_row = row
    end
  end
  if nx_int(form.self_row) >= nx_int(0) then
    for index = 0, COL_COUNT - 1 do
      rank_gird:SetGridForeColor(form.self_row, index, "255,255,0,0")
    end
  end
  rank_gird:EndUpdate()
end
