require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
function main_form_init(form)
  form.Fixed = true
  form.ramain_time = 0
end
function on_main_form_open(form)
  form.DrawLines_stage.max_escort = 10
  form.DrawLines_stage.max_point = 10
  form.DrawLines_stage.max_kill = 10
  form.DrawLines_stage.color_1 = ""
  form.DrawLines_stage.color_2 = ""
  form.DrawLines_stage.base_x = form.DrawLines_stage.Width / 2
  form.DrawLines_stage.base_y = form.DrawLines_stage.Height * 2 / 3
  init_drawlines_info(form.DrawLines_stage)
  req_war_info()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function req_war_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(CLIENT_WORLDWAR_INFO))
end
function rev_war_info(...)
  local form = util_get_form("form_stage_main\\form_world_war\\form_world_war_stage", true, false)
  if not nx_is_valid(form) then
    return
  end
  local worldwar_manager = nx_value("WorldWarManager")
  if not nx_is_valid(worldwar_manager) then
    return
  end
  form.lbl_cur_attack_index.Text = nx_widestr(arg[1])
  form.ramain_time = nx_int(arg[2])
  form.lbl_num_1.Text = nx_widestr(arg[3])
  form.lbl_num_3.Text = nx_widestr(arg[4])
  form.lbl_num_4.Text = nx_widestr(arg[5])
  form.lbl_num_2.Text = nx_widestr(arg[6])
  form.lbl_score_1.Text = nx_widestr(arg[7])
  form.lbl_num_5.Text = nx_widestr(arg[8])
  form.lbl_num_7.Text = nx_widestr(arg[9])
  form.lbl_num_8.Text = nx_widestr(arg[10])
  form.lbl_num_6.Text = nx_widestr(arg[11])
  form.lbl_score_2.Text = nx_widestr(arg[12])
  update_max_value(form.DrawLines_stage, unpack(arg))
  form.DrawLines_stage:Clear()
  if nx_find_custom(form.DrawLines_stage, "color_1") then
    update_contrast(form.DrawLines_stage, arg[5], arg[4], arg[13], form.DrawLines_stage.color_1)
  end
  if nx_find_custom(form.DrawLines_stage, "color_2") then
    update_contrast(form.DrawLines_stage, arg[10], arg[9], arg[14], form.DrawLines_stage.color_2)
  end
end
function init_drawlines_info(drawlines)
  local ini = nx_execute("util_functions", "get_ini", "ini\\worldwar\\worldwar_stage_info.ini")
  if not nx_is_valid(ini) then
    return
  end
  index = ini:FindSectionIndex("color")
  if index < 0 then
    return
  end
  drawlines.color_1 = ini:ReadString(index, "side_1", "")
  drawlines.color_2 = ini:ReadString(index, "side_2", "")
end
function update_contrast(drawlines, parm1, parm2, parm3, color)
  if not nx_is_valid(drawlines) then
    return
  end
  if parm1 < 0 or parm2 < 0 or parm3 < 0 then
    return
  end
  if 0 >= drawlines.max_escort or 0 >= drawlines.max_point or 0 >= drawlines.max_kill then
    return
  end
  local temp_len_1 = drawlines.base_y - parm1 / drawlines.max_escort * drawlines.base_y
  local temp_len_2 = drawlines.base_y - parm2 / drawlines.max_point * drawlines.base_y
  local temp_len_3 = drawlines.base_y - parm3 / drawlines.max_kill * drawlines.base_y
  local x1, y1 = drawlines.base_x, temp_len_1
  local x2, y2 = drawlines.Width - math.cos(math.pi / 6) * temp_len_2, drawlines.Height - 0.5 * temp_len_2
  local x3, y3 = math.cos(math.pi / 6) * temp_len_3, drawlines.Height - 0.5 * temp_len_3
  drawlines:SetLineColor(drawlines:AddLine(x1, y1, x2, y2), color)
  drawlines:SetLineColor(drawlines:AddLine(x2, y2, x3, y3), color)
  drawlines:SetLineColor(drawlines:AddLine(x3, y3, x1, y1), color)
end
function update_max_value(drawlines, ...)
  local max_escort = 1
  local max_point = 1
  local max_kill = 1
  if arg[5] >= arg[10] then
    max_escort = arg[5]
  else
    max_escort = arg[10]
  end
  if max_escort <= 0 then
    max_escort = 1
  end
  if arg[4] >= arg[9] then
    max_point = arg[4]
  else
    max_point = arg[9]
  end
  if max_point <= 0 then
    max_point = 1
  end
  if arg[13] >= arg[14] then
    max_kill = arg[13]
  else
    max_kill = arg[14]
  end
  if max_kill <= 0 then
    max_kill = 1
  end
  drawlines.max_escort = max_escort
  drawlines.max_point = max_point
  drawlines.max_kill = max_kill
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time)
end
