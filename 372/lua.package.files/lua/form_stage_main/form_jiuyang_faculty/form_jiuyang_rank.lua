require("util_functions")
require("util_gui")
local FORM_JIUYANG_RANK = "form_stage_main\\form_jiuyang_faculty\\form_jiuyang_rank"
function main_form_init(self)
  self.Fixed = false
end
function open_form(rows, flag, ...)
  local form = util_auto_show_hide_form(FORM_JIUYANG_RANK)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.jiuyang_rank_grid:ClearRow()
  form.jiuyang_rank_grid.RowCount = rows
  local index = 1
  local rank_result_string = ""
  local name_str = ""
  for i = 0, rows - 1 do
    if flag == 1 and rows - 1 == i then
      rank_result_string = ""
      support_kill_result = arg[index + 2]
      rank_result = arg[index + 3]
      rank_result_string = nx_string(gui.TextManager:GetFormatText("ui_jiuyang_rank_result", nx_int(rank_result)))
      support_result_string = nx_string(gui.TextManager:GetFormatText("ui_jiuyang_support_rank_result", nx_int(support_kill_result)))
      name_str = util_split_string(nx_string(arg[index + 1]), "_")
      if 0 < table.getn(name_str) then
        form.player_name.Text = nx_widestr(name_str[1])
      end
      if 1 < table.getn(name_str) then
        form.server_name.Text = nx_widestr(name_str[2])
      else
        form.server_name.Text = nx_widestr(gui.TextManager:GetFormatText("ui_jiuyang_local_server"))
      end
      form.rank_num.Text = nx_widestr(nx_int(arg[index]) + 1)
      form.support_result.Text = nx_widestr(support_result_string)
      form.jiuyang_result.Text = nx_widestr(rank_result_string)
    else
      rank_result_string = ""
      support_kill_result = arg[index + 2]
      rank_result = arg[index + 3]
      rank_result_string = nx_string(gui.TextManager:GetFormatText("ui_jiuyang_rank_result", nx_int(rank_result)))
      support_result_string = nx_string(gui.TextManager:GetFormatText("ui_jiuyang_support_rank_result", nx_int(support_kill_result)))
      name_str = util_split_string(nx_string(arg[index + 1]), "_")
      if 0 < table.getn(name_str) then
        form.jiuyang_rank_grid:SetGridText(i, 2, nx_widestr(name_str[1]))
      end
      if 1 < table.getn(name_str) then
        form.jiuyang_rank_grid:SetGridText(i, 1, nx_widestr(name_str[2]))
      else
        form.jiuyang_rank_grid:SetGridText(i, 1, nx_widestr(gui.TextManager:GetFormatText("ui_jiuyang_local_server")))
      end
      form.jiuyang_rank_grid:SetGridText(i, 0, nx_widestr(nx_int(arg[index]) + 1))
      form.jiuyang_rank_grid:SetGridText(i, 3, nx_widestr(support_result_string))
      form.jiuyang_rank_grid:SetGridText(i, 4, nx_widestr(rank_result_string))
    end
    index = index + 4
  end
end
function get_format_text(msg, value)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(msg, value)
  return text
end
function on_main_form_open(form)
  set_form_pos(form)
  refresh_form(form)
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  return 1
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function refresh_form(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
