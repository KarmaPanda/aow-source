require("util_gui")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
end
FORM_WORLD_LEITAI_FILTER = "form_stage_main\\form_leitai\\form_world_leitai_filter"
function on_main_form_open(self)
  init_score_dialog_info(self)
  nx_execute("custom_sender", "custom_send_leitai_filter_Info_request")
end
function init_score_dialog_info(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local title = gui.TextManager:GetFormatText("ui_world_leitai_score_filter_strength")
  form.textgrid_score:SetColTitle(0, nx_widestr(title))
  title = gui.TextManager:GetFormatText("ui_world_leitai_score_filter_describe")
  form.textgrid_score:SetColTitle(1, nx_widestr(title))
  title = gui.TextManager:GetFormatText("ui_world_leitai_score_filter_player_num")
  form.textgrid_score:SetColTitle(2, nx_widestr(title))
end
function on_main_form_close(self)
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function update_data_filter_info(...)
  local form = nx_value(FORM_WORLD_LEITAI_FILTER)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local rows = table.getn(arg)
  if nx_number(rows) <= nx_number(0) then
    return
  end
  local region_num = rows - 1
  for i = 1, nx_number(region_num) do
    local row = form.textgrid_score:InsertRow(-1)
    if nx_number(row) >= nx_number(region_num) then
      return
    end
    local index = region_num - row
    local text_id = "ui_world_leitai_filter_strength_lv_" .. nx_string(index)
    local text = gui.TextManager:GetFormatText(text_id)
    form.textgrid_score:SetGridText(row, 0, nx_widestr(text))
    text_id = nx_string(text_id) .. "_desc"
    text = gui.TextManager:GetFormatText(text_id)
    form.textgrid_score:SetGridText(row, 1, nx_widestr(text))
    form.textgrid_score:SetGridText(row, 2, nx_widestr(arg[index + 1]))
  end
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) then
      local surplus_num = client_player:QueryProp("LeiTaiRandomCount")
      local surplus_leitai_num_text = gui.TextManager:GetFormatText("ui_world_leitai_surplus_leitai_num", nx_int(surplus_num))
      form.lbl_random_count.Text = nx_widestr(surplus_leitai_num_text)
    end
  end
end
function on_textgrid_score_select_row(grid, row)
  local form = nx_value(FORM_WORLD_LEITAI_FILTER)
  local leitai_form = nx_value("form_stage_main\\form_leitai\\form_leitai")
  if not nx_is_valid(leitai_form) then
    return
  end
  local select_lv = grid.RowCount - row - 1
  leitai_form.select_lv = nx_number(select_lv)
end
function on_rbtn_menu_checked_changed(btn)
end
function on_btn_send_msg_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
