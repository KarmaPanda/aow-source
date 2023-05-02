require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
function main_form_init(form)
  form.Fixed = true
  form.scene_id = 400
end
function on_main_form_open(form)
  update_desc_info(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_textgrid_sub_game_select_row(grid, row)
  local form = grid.ParentForm
  form.mltbox_sub_desc.HtmlText = nx_widestr(util_text("ui_ww_sub_desc_" .. nx_string(form.scene_id) .. "_" .. nx_string(row)))
end
function update_desc_info(form)
  if sub_game_table[nx_string(form.scene_id)] == nil then
    return
  end
  local sub_game_count = #sub_game_table[nx_string(form.scene_id)]
  form.textgrid_sub_game:ClearSelect()
  form.textgrid_sub_game:ClearRow()
  for i = 1, sub_game_count do
    local row = form.textgrid_sub_game:InsertRow(-1)
    form.textgrid_sub_game:SetGridText(row, 0, nx_widestr(util_text("ui_ww_sub_game" .. sub_game_table[nx_string(form.scene_id)][i])))
  end
  if 0 < form.textgrid_sub_game.RowCount then
    on_textgrid_sub_game_select_row(form.textgrid_sub_game, 0)
  end
  form.mltbox_side_desc.HtmlText = nx_widestr(util_text("ui_ww_side_desc_" .. nx_string(form.scene_id) .. "_1"))
end
