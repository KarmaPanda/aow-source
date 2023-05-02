require("form_stage_main\\puzzle_quest\\puzzle_quest_define")
require("form_stage_main\\puzzle_quest\\puzzle_effect_data")
require("util_functions")
require("share\\view_define")
require("player_state\\state_input")
require("util_gui")
data_lst = {}
new_data_lst = {}
patch_lst = {}
diamond_lst = {}
control_lst = {}
select_lst = {}
change_control_show_lst = {}
max_col = 0
max_row = 0
temp_scale = 1
local MUSIC_STOP = 0
local MUSIC_PLAY = 1
local ORIGIN_MUSIC_PAUSE = 3
local ORIGIN_MUSIC_RESUME = 4
local diamond_normal = 1
local diamond_mousein = 2
local diamond_mouseclick = 3
local DIAMOND_MATRIX_LEFT_OFFSET = 292
local DIAMOND_MATRIX_TOP_OFFSET = 160
local CONTROL_NAME_SUFFIX = {
  ["0"] = "a",
  ["1"] = "b"
}
local game_time = 0
local damage_type = {
  damage_magic = 0,
  damage_skull = 1,
  damage_weapon = 2
}
local chat_left = 0
local chat_top = 0
local chat_width = 400
local chat_height = 170
local POMEN = 2
local game_type = -1
local current_form_name
local door_hits_cout = 0
local work_type = -1
local heroichit_cout = 0
local fivestrat_cout = 0
local is_show_over = true
local is_creart_matrix_over = false
local is_game_over = false
local is_need_recover = false
function log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
  nx_function("ext_trace_log", info)
end
function log2(info)
end
function log3(info)
end
function log4(info)
end
function log5(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function diamond_operate(diamond_label, op)
  if nx_is_valid(diamond_label) and nx_find_custom(diamond_label, "operate_lst") then
    if diamond_label.operate_lst == "" then
      if op == "up" then
        mov_up(diamond_label)
      elseif op == "down" then
        mov_down(diamond_label)
      elseif op == "left" then
        mov_left(diamond_label)
      elseif op == "right" then
        mov_right(diamond_label)
      elseif op == "bomb" then
        mov_bomb(diamond_label)
      elseif op == "drop" then
        mov_drop(diamond_label)
      end
      diamond_label.operate_lst = op
    else
      diamond_label.operate_lst = diamond_label.operate_lst .. "," .. op
    end
  end
end
function diamond_operate_finish(diamond_label, op)
  local index = string.find(diamond_label.operate_lst, op)
  if index == nil then
    return
  end
  string.sub(diamond_label.operate_lst, 1, index - 1)
  index = string.find(diamond_label.operate_lst, op)
  if index == nil then
    return
  end
  diamond_label.operate_lst = nx_string(string.sub(diamond_label.operate_lst, 1, index - 1)) .. nx_string(string.sub(diamond_label.operate_lst, index + string.len(op) + 1, -1))
end
function diamond_operate_continue(diamond_label)
  if diamond_label.operate_lst == "" then
    return false
  end
  local index = string.find(diamond_label.operate_lst, ",")
  cur_op = diamond_label.operate_lst
  if index ~= nil then
    cur_op = string.sub(diamond_label.operate_lst, 1, index - 1)
  end
  if cur_op == "up" then
    mov_up(diamond_label)
  elseif cur_op == "down" then
    mov_down(diamond_label)
  elseif cur_op == "left" then
    mov_left(diamond_label)
  elseif cur_op == "right" then
    mov_right(diamond_label)
  elseif cur_op == "bomb" then
    mov_bomb(diamond_label)
  elseif cur_op == "drop" then
    mov_drop(diamond_label)
  end
  return true
end
function while_ask_operate(form)
  if (form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi or form.gem_game_type == gem_game_type.gt_gemtaskgame) and (game_type == 0 or game_type == 4) then
    nx_execute(FORM_CAIFENG, "increase_all_to_final_count", form.puzzle_page, 10)
  end
  for i = 1, table.getn(diamond_lst) do
    diamond_label = diamond_lst[i]
    if nx_is_valid(diamond_label) and diamond_label.operate_lst ~= "" then
      operate_lst_rec = util_split_string(diamond_label.operate_lst, ",")
      local cur_op = operate_lst_rec[1]
      if cur_op == "up" then
        mov_up_time(diamond_label, diamond_label.next_left, diamond_label.next_top)
      elseif cur_op == "down" then
        mov_down_time(diamond_label, diamond_label.next_left, diamond_label.next_top)
      elseif cur_op == "left" then
        mov_left_time(diamond_label, diamond_label.next_left, diamond_label.next_top)
      elseif cur_op == "right" then
        mov_right_time(diamond_label, diamond_label.next_left, diamond_label.next_top)
      elseif cur_op == "bomb" then
        mov_bomb_time(diamond_label, diamond_label.next_left, diamond_label.next_top)
      elseif cur_op == "drop" then
        mov_drop_time(diamond_label, diamond_label.next_left, diamond_label.next_top)
      end
    end
  end
  if form.is_wait_result then
    on_diamond_result_time(form, -1, -1)
  end
end
function mov_drop(diamond_label)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  local next_left = diamond_label.diamond_col * diamond_width
  local next_top = (diamond_label.drop_dest_row - 1) * diamond_height
  form.drop_time = form.drop_time + 1
  diamond_label.next_left = next_left
  diamond_label.next_top = next_top
  diamond_label.mov_add = 1
end
function mov_bomb(diamond_label)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  form.bomb_time = form.bomb_time + 1
end
function mov_up(diamond_label)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  local next_left = diamond_label.Left
  local next_top = diamond_label.Top - diamond_height
  form.no_operate = form.no_operate + 1
  diamond_label.next_left = next_left
  diamond_label.next_top = next_top
  diamond_label.mov_add = 1
end
function mov_right(diamond_label)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  local next_left = diamond_label.Left + diamond_width
  local next_top = diamond_label.Top
  form.no_operate = form.no_operate + 1
  diamond_label.next_left = next_left
  diamond_label.next_top = next_top
  diamond_label.mov_add = 1
end
function mov_down(diamond_label)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  local next_left = diamond_label.Left
  local next_top = diamond_label.Top + diamond_height
  form.no_operate = form.no_operate + 1
  diamond_label.next_left = next_left
  diamond_label.next_top = next_top
  diamond_label.mov_add = 1
end
function mov_left(diamond_label)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  local next_left = diamond_label.Left - diamond_width
  local next_top = diamond_label.Top
  form.no_operate = form.no_operate + 1
  diamond_label.next_left = next_left
  diamond_label.next_top = next_top
  diamond_label.mov_add = 1
end
function move_select_time(diamond_label)
  for i = 1, table.getn(select_lst) do
    if select_lst[i].cur_row == diamond_label.diamond_row and select_lst[i].cur_col == diamond_label.diamond_col then
      select_lst[i].Visible = true
      local form = diamond_label.Parent.Parent
      select_lst[i].Left = form.diamond_control.Left + diamond_label.Left - tip_fix_x
      select_lst[i].Top = form.diamond_control.Top + diamond_label.Top - tip_fix_x
    end
  end
end
function end_select_time(diamond_label)
  for i = 1, table.getn(select_lst) do
    if select_lst[i].cur_row == diamond_label.diamond_row and select_lst[i].cur_col == diamond_label.diamond_col then
      select_lst[i].Visible = false
    end
  end
end
function mov_up_time(diamond_label, next_left, next_top)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  diamond_label.Top = diamond_label.Top - 1 - diamond_label.mov_add
  diamond_label.mov_add = diamond_label.mov_add + 0.3
  move_select_time(diamond_label)
  if next_top > diamond_label.Top then
    end_up_time(form, timer, diamond_label, next_left, next_top)
  end
end
function end_up_time(form, timer, diamond_label, next_left, next_top)
  diamond_label.Top = next_top
  diamond_label.BackImage = get_diamond_photo(nx_number(diamond_label.diamond_type))
  end_select_time(diamond_label)
  diamond_operate_finish(diamond_label, "up")
  form.no_operate = form.no_operate - 1
  diamond_operate_continue(diamond_label)
end
function mov_down_time(diamond_label, next_left, next_top)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  diamond_label.Top = diamond_label.Top + 1 + diamond_label.mov_add
  diamond_label.mov_add = diamond_label.mov_add + 0.3
  move_select_time(diamond_label)
  if next_top < diamond_label.Top then
    end_down_time(form, timer, diamond_label, next_left, next_top)
  end
end
function end_down_time(form, timer, diamond_label, next_left, next_top)
  diamond_label.Top = next_top
  diamond_label.BackImage = get_diamond_photo(nx_number(diamond_label.diamond_type))
  end_select_time(diamond_label)
  diamond_operate_finish(diamond_label, "down")
  form.no_operate = form.no_operate - 1
  diamond_operate_continue(diamond_label)
end
function mov_left_time(diamond_label, next_left, next_top)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  diamond_label.Left = diamond_label.Left - 1 - diamond_label.mov_add
  diamond_label.mov_add = diamond_label.mov_add + 0.3
  move_select_time(diamond_label)
  if next_left > diamond_label.Left then
    end_left_time(form, timer, diamond_label, next_left, next_top)
  end
end
function end_left_time(form, timer, diamond_label, next_left, next_top)
  diamond_label.Left = next_left
  diamond_label.BackImage = get_diamond_photo(nx_number(diamond_label.diamond_type))
  end_select_time(diamond_label)
  diamond_operate_finish(diamond_label, "left")
  form.no_operate = form.no_operate - 1
  diamond_operate_continue(diamond_label)
end
function mov_right_time(diamond_label, next_left, next_top)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  diamond_label.Left = diamond_label.Left + 1 + diamond_label.mov_add
  diamond_label.mov_add = diamond_label.mov_add + 0.3
  move_select_time(diamond_label)
  if next_left < diamond_label.Left then
    end_right_time(form, timer, diamond_label, next_left, next_top)
  end
end
function end_right_time(form, timer, diamond_label, next_left, next_top)
  diamond_label.Left = next_left
  diamond_label.BackImage = get_diamond_photo(nx_number(diamond_label.diamond_type))
  end_select_time(diamond_label)
  diamond_operate_finish(diamond_label, "right")
  form.no_operate = form.no_operate - 1
  diamond_operate_continue(diamond_label)
end
function mov_bomb_time(diamond_label, next_left, next_top)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  if form.no_operate == 0 then
    end_bomb_time(form, timer, diamond_label, next_left, next_top)
  end
end
function end_bomb_time(form, timer, diamond_label, next_left, next_top)
  diamond_operate_finish(diamond_label, "bomb")
  bomb_diamond(form, diamond_label)
  local patch_data = patch_lst[diamond_label.diamond_col]
  local first_index = 0
  local data = 0
  local count = 0
  for i = 1, max_row do
    local r_i = max_row - i + 1
    if patch_data[r_i] ~= nil then
      if patch_data[r_i] ~= -1 and first_index == 0 then
        data = patch_data[r_i]
        first_index = r_i
        patch_data[r_i] = -1
        patch_lst[diamond_label.diamond_col] = patch_data
      end
      count = count + 1
    end
  end
  diamond_label.drop_dest_row = first_index
  diamond_label.diamond_type = nx_number(data)
  diamond_label.BackImage = get_diamond_photo(nx_number(data))
  diamond_label.Top = -(count - first_index + 1) * diamond_height
  diamond_label.Top = diamond_label.Top - (count - first_index + 1) * diamond_height - 1.5 * diamond_height
  form.bomb_time = form.bomb_time - 1
  diamond_operate_continue(diamond_label)
end
function mov_drop_time(diamond_label, next_left, next_top)
  local timer = nx_value("timer_game")
  local form = diamond_label.Parent.Parent
  if form.no_operate == 0 then
    diamond_label.Top = diamond_label.Top + 1 + diamond_label.mov_add
    diamond_label.mov_add = diamond_label.mov_add + 0.2
    if next_top < diamond_label.Top then
      end_drop_time(form, timer, diamond_label, next_left, next_top)
    end
  end
end
function end_drop_time(form, timer, diamond_label, next_left, next_top)
  diamond_label.Top = next_top
  diamond_operate_finish(diamond_label, "drop")
  diamond_operate_continue(diamond_label)
  form.drop_time = form.drop_time - 1
  change_diamond_label(diamond_label, diamond_label.drop_dest_row, diamond_label.diamond_col)
  data_lst[(diamond_label.drop_dest_row - 1) * max_col + diamond_label.diamond_col] = diamond_label.diamond_type
  diamond_label.BackImage = get_diamond_photo(nx_number(diamond_label.diamond_type))
end
function move_diamond(src_row, src_col, dest_row, dest_col)
  local form = nx_value(FORM_PUZZLE_QUEST)
  if not change_diamond(src_row, src_col, dest_row, dest_col) then
    recover_diamond(src_row, src_col, dest_row, dest_col)
    form.error_max = form.error_max - 1
    if form.error_max <= 0 then
      local jewel_game_manager = nx_value("jewel_game_manager")
      return jewel_game_manager:CheckOperate(op_sysn)
    end
  else
    form.error_max = 1
  end
  form.src_select = nil
  form.dest_select = nil
end
function recover_diamond(src_row, src_col, dest_row, dest_col)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local src_op, dest_op = get_change_direct(src_row, src_col, dest_row, dest_col)
  diamond_operate(form.src_select, dest_op)
  diamond_operate(form.dest_select, src_op)
end
function get_change_direct(src_row, src_col, dest_row, dest_col)
  if dest_row < src_row then
    return "up", "down"
  end
  if src_row < dest_row then
    return "down", "up"
  end
  if src_col < dest_col then
    return "right", "left"
  end
  if dest_col < src_col then
    return "left", "right"
  end
  return "error", "error"
end
function change_diamond_label(diamond_label, row, col)
  diamond_name = "diamond" .. nx_string(row) .. nx_string(col)
  diamond_label.Name = diamond_name
  diamond_label.diamond_row = row
  diamond_label.diamond_col = col
end
function change_diamond(src_row, src_col, dest_row, dest_col)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local src_op, dest_op = get_change_direct(src_row, src_col, dest_row, dest_col)
  diamond_operate(form.src_select, src_op)
  diamond_operate(form.dest_select, dest_op)
  if can_change(src_row, src_col, dest_row, dest_col) then
    local tmp = data_lst[(src_row - 1) * max_col + src_col]
    data_lst[(src_row - 1) * max_col + src_col] = data_lst[(dest_row - 1) * max_col + dest_col]
    data_lst[(dest_row - 1) * max_col + dest_col] = tmp
    change_diamond_label(form.src_select, dest_row, dest_col)
    select_lst[1].cur_row = dest_row
    select_lst[1].cur_col = dest_col
    change_diamond_label(form.dest_select, src_row, src_col)
    select_lst[2].cur_row = src_row
    select_lst[2].cur_col = src_col
    local src_index = (src_row - 1) * max_col + src_col
    local dest_index = (dest_row - 1) * max_col + dest_col
    change_diamond_end(src_index, dest_index)
    return true
  end
  return false
end
function can_change(src_row, src_col, dest_row, dest_col)
  local src_index = (src_row - 1) * max_col + src_col
  local dest_index = (dest_row - 1) * max_col + dest_col
  local jewel_game_manager = nx_value("jewel_game_manager")
  return jewel_game_manager:CheckOperate(op_swap, src_index, dest_index)
end
function change_diamond_end(src_index, dest_index)
  nx_execute(nx_current(), "check_op", src_index, dest_index)
end
function check_op(src_index, dest_index)
  while true do
    nx_pause(0.01)
    local form = nx_value(FORM_PUZZLE_QUEST)
    if nx_is_valid(form) and nx_find_custom(form, "no_operate") and form.no_operate == 0 then
      send_diamond_result(src_index, dest_index)
      break
    end
  end
end
function send_diamond_result(src_index, dest_index)
  local jewel_game_manager = nx_value("jewel_game_manager")
  jewel_game_manager:SendServerOperate(op_swap, src_index, dest_index)
end
function on_diamond_result_time(form, param1, param2)
  if form.drop_time <= 0 and 0 >= form.bomb_time and 0 >= form.no_operate then
    form.is_wait_result = false
    local jewel_game_manager = nx_value("jewel_game_manager")
    jewel_game_manager:CheckOperate(op_bomb)
  end
end
function create_skill_font(form, skill_id)
  local gui = nx_value("gui")
  local skill_font = form:Find("skill_font")
  if not nx_is_valid(skill_font) then
    skill_font = gui:Create("Label")
    form:Add(skill_font)
  end
  local control
  local cur_group = form.puzzle_page.gemgame_lst.CurOPGroup
  if cur_group == 0 then
    control = form.puzzle_page.lbl_mark_pos_1
  elseif cur_group == 1 then
    control = form.puzzle_page.lbl_mark_pos_2
  else
    return
  end
  if control == nil then
    return
  end
  form:ToFront(skill_font)
  skill_font.Font = "font_sns_btn_2"
  skill_font.ForeColor = "255,255,255,255"
  skill_font.Text = nx_widestr(gui.TextManager:GetText(nx_string(skill_id)))
  skill_font.Height = 62
  skill_font.Width = 200
  skill_font.Left = control.AbsLeft
  skill_font.Top = control.AbsTop
  skill_font.Name = "skill_font"
  skill_font.Visible = true
  nx_pause(2)
  if nx_is_valid(skill_font) then
    skill_font.Visible = false
  end
end
local sh_zhiye = {
  sh_tj = gem_game_type.gt_tiejiang,
  sh_jq = gem_game_type.gt_qiaojiang,
  sh_ds = gem_game_type.gt_dushi,
  sh_ys = gem_game_type.gt_yaoshi,
  sh_cf = gem_game_type.gt_caifeng,
  sh_cs = gem_game_type.gt_chushi,
  gemegggame = gem_game_type.gt_gemegggame,
  gemtaskgame = gem_game_type.gt_gemtaskgame,
  gemtaskegggame = gem_game_type.gt_gemtaskegggame
}
function on_receiver_result(op, str_res)
  local arg = util_split_string(str_res, ",")
  if op == op_create then
    data_lst = {}
    local game_zhiye = arg[1]
    max_row = nx_number(arg[2])
    max_col = nx_number(arg[3])
    local size = 1
    for i = 4, table.getn(arg) do
      data_lst[size] = nx_number(arg[i])
      size = size + 1
    end
    local form = nx_value(FORM_PUZZLE_QUEST)
    if not nx_is_valid(form) then
      show_form(sh_zhiye[game_zhiye])
    end
    form = nx_value(FORM_PUZZLE_QUEST)
    create_diamond_control(form, max_row, max_col)
    create_diamond_matrix(form, max_row, max_col)
    is_creart_matrix_over = true
    if game_type == 2 then
      local timer = nx_value("timer_game")
      if nx_is_valid(timer) then
        timer:UnRegister(FORM_PUZZLE_QUEST, "give_tip", form)
      end
      timer:Register(15000, -1, FORM_PUZZLE_QUEST, "give_tip", form, -1, -1)
    end
    local gui = nx_value("gui")
    if game_type == 2 then
      create_img_ani("puzzle_start", gui.Desktop.Width / 2 - 258, gui.Desktop.Height / 5)
    end
  elseif op == op_reset then
    data_lst = {}
    max_row = nx_number(arg[1])
    max_col = nx_number(arg[2])
    local size = 1
    for i = 3, table.getn(arg) do
      data_lst[size] = nx_number(arg[i])
      size = size + 1
    end
    play_sound("en_lost")
    reset_diamond_matrix()
  elseif op == op_swap then
    local form = nx_value(FORM_PUZZLE_QUEST)
    if not nx_is_valid(form) or not form.Visible then
      return
    end
    local src_index = nx_number(arg[1])
    local dest_index = nx_number(arg[2])
    local form = nx_value(FORM_PUZZLE_QUEST)
    local src_row = nx_number(nx_int(src_index / max_col)) + 1
    local src_col = math.mod(src_index, max_col) + 1
    local dest_row = nx_number(nx_int(dest_index / max_col)) + 1
    local dest_col = math.mod(dest_index, max_col) + 1
    local src_op, dest_op = get_change_direct(src_row, src_col, dest_row, dest_col)
    local src_diamond = form.diamond_scene:Find("diamond" .. nx_string(src_row) .. nx_string(src_col))
    local dest_diamond = form.diamond_scene:Find("diamond" .. nx_string(dest_row) .. nx_string(dest_col))
    if not nx_is_valid(src_diamond) or not nx_is_valid(dest_diamond) then
      return
    end
    create_diamond_select(form.diamond_control, src_row, src_col, 1, false)
    create_diamond_select(form.diamond_control, dest_row, dest_col, 2, false)
    diamond_operate(src_diamond, src_op)
    diamond_operate(dest_diamond, dest_op)
    local tmp = data_lst[(src_row - 1) * max_col + src_col]
    data_lst[(src_row - 1) * max_col + src_col] = data_lst[(dest_row - 1) * max_col + dest_col]
    data_lst[(dest_row - 1) * max_col + dest_col] = tmp
    change_diamond_label(src_diamond, dest_row, dest_col)
    select_lst[1].cur_row = dest_row
    select_lst[1].cur_col = dest_col
    change_diamond_label(dest_diamond, src_row, src_col)
    select_lst[2].cur_row = src_row
    select_lst[2].cur_col = src_col
    form.is_wait_result = true
  elseif op == op_drop then
    local form = nx_value(FORM_PUZZLE_QUEST)
    if not nx_is_valid(form) or not form.Visible then
      return
    end
    for i = 1, max_col do
      local patch_data = {}
      patch_lst[i] = patch_data
    end
    for i = 1, table.getn(arg) / 2 do
      local index = arg[i * 2 - 1]
      local patch_row = nx_number(nx_int(index / max_col)) + 1
      local patch_col = math.mod(index, max_col) + 1
      local value = arg[i * 2]
      patch_lst[patch_col][patch_row] = nx_number(value)
    end
    destory_diamond_matrix()
    local form = nx_value(FORM_PUZZLE_QUEST)
    form.is_wait_result = true
  elseif op == op_bomb then
    local form = nx_value(FORM_PUZZLE_QUEST)
    if not nx_is_valid(form) or not form.Visible then
      return
    end
    is_need_recover = false
    local sub_arg = {}
    local sub_count = 0
    local star_count = 0
    form.src_select = nil
    if nx_is_valid(select_lst[1]) then
      select_lst[1].Visible = false
    end
    form.can_eat = arg[1]
    for i = 2, table.getn(arg) do
      local ar = math.mod(arg[i], 10000)
      if nx_number(ar) ~= -1 then
        sub_count = sub_count + 1
        star_count = star_count + 1
        sub_arg[sub_count] = ar
      else
        if game_type == 0 or game_type == 4 then
          create_diamond_number_effect(form, sub_arg)
        end
        sub_count = 0
        if 0 < star_count then
          for i = 1, table.getn(sub_arg) do
            local ins = nx_number(sub_arg[i])
            local row = nx_number(nx_int(ins / max_col)) + 1
            local col = math.mod(ins, max_col) + 1
            local key_diamond = form.diamond_scene:Find("diamond" .. nx_string(row) .. nx_string(col))
            if nx_is_valid(key_diamond) then
              if star_count == 5 then
                fivestrat_cout = fivestrat_cout + 1
              end
              create_diamond_star_img_effect(key_diamond.AbsLeft, key_diamond.AbsTop, star_count)
              break
            end
          end
        end
        star_count = 0
        sub_arg = {}
      end
    end
    local is_doorhit = true
    if game_type == 2 then
      for i = 2, table.getn(arg) do
        local number = math.mod(arg[i], 10000) + 1
        if nx_number(arg[i]) ~= -1 then
          if nx_number(get_diamond_type(data_lst[nx_number(math.mod(arg[i], 10000) + 1)])) ~= nx_number(gem_type.Skull) then
            is_doorhit = false
          end
        else
          if is_doorhit == true then
            door_hits_cout = door_hits_cout + 1
          end
          is_doorhit = true
        end
        if nx_number(arg[i]) > 10000 and nx_number(get_diamond_type(data_lst[nx_number(number)])) == nx_number(gem_type.Skull) then
          local is_creart_effect = true
          local j = i - 1
          while 2 <= j and nx_number(arg[j]) ~= -1 do
            if nx_number(get_diamond_type(data_lst[nx_number(math.mod(arg[j], 10000) + 1)])) ~= nx_number(gem_type.Skull) then
              is_creart_effect = false
              break
            end
            j = j - 1
          end
          if is_creart_effect then
            local k = i + 1
            while nx_number(arg[k]) ~= -1 do
              if nx_number(get_diamond_type(data_lst[nx_number(math.mod(arg[k], 10000) + 1)])) ~= nx_number(gem_type.Skull) then
                is_creart_effect = false
                break
              end
              k = k + 1
            end
          end
          if is_creart_effect then
            local row = 0
            local col = 0
            row = math.floor((number - 1) / max_col) + 1
            col = math.mod(number - 1, max_col) + 1
            local diamond = find_diamond(form, row, col)
            if nx_find_custom(form.puzzle_page, "gemgame_lst") then
              create_diamond_path_effect(form, nx_number(form.puzzle_page.gemgame_lst.CurOPGroup), diamond, get_diamond_type(data_lst[nx_number(number)]))
            end
          end
        end
      end
    end
    if game_type == 0 then
      for i = 2, table.getn(arg) do
        if nx_number(arg[i]) ~= -1 and nx_number(arg[i]) ~= 1 then
          local number = math.mod(arg[i], 10000) + 1
          local row = 0
          local col = 0
          row = math.floor((number - 1) / max_col) + 1
          col = math.mod(number - 1, max_col) + 1
          diamond_name = "diamond" .. nx_string(row) .. nx_string(col)
          local diamond_label = form.diamond_scene:Find(diamond_name)
          if nx_is_valid(diamond_label) then
            diamond_label.Text = nx_widestr("")
          end
        end
      end
    end
    local control_lst = {}
    for i = 2, table.getn(arg) do
      if nx_number(arg[i]) ~= -1 and nx_number(arg[i]) < 10000 then
        index = nx_number(arg[i]) + 1
        data_lst[index] = -1
        local row = nx_number(nx_int(nx_number(arg[i]) / max_col)) + 1
        local col = math.mod(nx_number(arg[i]), max_col) + 1
        local key_diamond = form.diamond_scene:Find("diamond" .. nx_string(row) .. nx_string(col))
        control_lst[i - 1] = key_diamond
      end
    end
    create_custom_effect(unpack(control_lst))
  elseif op == op_born then
    is_show_over = false
    play_sound("diamond_change")
    local form = nx_value(FORM_PUZZLE_QUEST)
    form.src_select = nil
    if nx_is_valid(select_lst[1]) then
      select_lst[1].Visible = false
    end
    born_diamond_matrix(arg)
  elseif op == op_change then
    local form = nx_value(FORM_PUZZLE_QUEST)
    form.src_select = nil
    if nx_is_valid(select_lst[1]) then
      select_lst[1].Visible = false
    end
    play_sound("diamond_change")
    change_diamond_matrix(arg)
  elseif op == op_skill then
    local form = nx_value(FORM_PUZZLE_QUEST)
    if nx_find_custom(form, "gem_game_type") and form.gem_game_type ~= gem_game_type.gt_datongjingmai then
      form.is_wait_result = true
      local control_lst = {}
      create_custom_effect(unpack(control_lst))
    else
      nx_execute(FORM_CAIFENG, "reflesh_fight_dyn_info")
      skill_general_effect(arg)
      local control_lst = {}
      create_custom_effect(unpack(control_lst))
    end
  elseif op == op_damage then
    local form = nx_value(FORM_PUZZLE_QUEST)
    if game_type == 0 then
      local player_name = arg[1]
      local group, index = get_group_index_by_name(player_name)
      if group == -1 then
        form.is_wait_result = true
        return
      end
      local hurt = arg[2]
      local type = arg[3]
      local is_block = nx_number(arg[4]) == 1
      local is_crit = nx_number(arg[5]) == 1
      nx_execute(nx_current(), "create_diamond_hurt_effect", form, group, hurt, player_name, type, is_block, is_crit)
    elseif nx_is_valid(form) and nx_find_custom(form, "is_wait_result") then
      form.is_wait_result = true
    end
  elseif op == op_effective then
    local form = nx_value(FORM_PUZZLE_QUEST)
    if not nx_is_valid(form) or not form.Visible then
      return
    end
    form.cur_skill_name = arg[1]
    if arg[1] == nil then
      form.is_wait_result = true
      return
    end
    form.cur_skill_index, form.cur_skill_effect_count = get_cur_skill_index_and_effect_count(form, form.cur_skill_name)
    if form.cur_skill_name ~= "gemskill_fight" and form.cur_skill_name ~= "gemskill_defense" then
      nx_execute(nx_current(), "create_skill_font", form, form.cur_skill_name)
    end
    form.is_wait_result = true
  elseif op == op_sysn then
    data_lst = {}
    max_row = nx_number(arg[1])
    max_col = nx_number(arg[2])
    local size = 1
    for i = 3, table.getn(arg) do
      data_lst[size] = nx_number(arg[i])
      size = size + 1
    end
    local form = nx_value(FORM_PUZZLE_QUEST)
    for i = 1, max_row do
      for j = 1, max_col do
        diamond_name = "diamond" .. nx_string(i) .. nx_string(j)
        local diamond_label = form.diamond_scene:Find(diamond_name)
        if nx_is_valid(diamond_label) then
          local type = data_lst[(i - 1) * max_col + j]
          diamond_label.Visible = true
          diamond_label.BackImage = get_diamond_photo(type)
          diamond_label.diamond_type = type
          diamond_lst[(i - 1) * max_col + j] = diamond_label
        end
      end
    end
    form.error_max = 1
    form.src_select = nil
  elseif op == op_synskill then
    local form = nx_value(FORM_PUZZLE_QUEST)
    if nx_find_custom(form, "gem_game_type") and form.gem_game_type == gem_game_type.gt_datongjingmai then
      nx_execute(FORM_JINGMAI, "sysn_skill")
    end
  elseif op == op_exit then
    is_game_over = true
    local form = nx_value(FORM_PUZZLE_QUEST)
    if nx_is_valid(form) and form.Visible then
      if nx_find_custom(form, "gem_game_type") and form.gem_game_type == gem_game_type.gt_datongjingmai then
        specialform_alpha_out(FORM_PUZZLE_QUEST, 1)
      elseif game_type == 2 then
        if nx_number(arg[1]) ~= -1 then
          if nx_number(arg[1]) == 1 then
            nx_execute("form_stage_main\\puzzle_quest\\form_caifeng_quest", "failure_tips_dialog")
          end
          show_exit_effect(form, nx_number(form.self_group) == nx_number(arg[1]))
        else
          show_world_alpha_out()
        end
      elseif nx_number(arg[1]) ~= -1 then
        show_exit_effect(form, nx_number(form.self_group) == nx_number(arg[1]))
      else
        show_world_alpha_out()
      end
    end
  elseif op == op_heroichit then
    heroichit_cout = heroichit_cout + 1
  elseif op == op_gamelevel then
    local form = nx_value(FORM_PUZZLE_QUEST)
    if nx_is_valid(form) and nx_find_custom(form, "puzzle_page") and nx_is_valid(form.puzzle_page) then
      local game_level = form.puzzle_page:Find("ani_game_level")
      if nx_is_valid(game_level) then
        game_level.Visible = true
        game_level.AnimationImage = nx_string("bspass0" .. nx_string(nx_number(arg[1]) + 1))
      end
    end
  elseif op == op_act_over then
    is_show_over = true
    local form = nx_value(FORM_PUZZLE_QUEST)
    hid_tip(form)
    if game_type == 2 and door_hits_cout ~= 0 then
      nx_execute("form_stage_main\\puzzle_quest\\form_caifeng_quest", "play_skull_ainm")
      door_hits_cout = 0
    end
    if nx_is_valid(form) and nx_find_custom(form, "gem_game_type") and form.gem_game_type ~= gem_game_type.gt_datongjingmai then
      local timer = nx_value("timer_game")
      if nx_is_valid(timer) then
        timer:UnRegister(FORM_PUZZLE_QUEST, "give_tip", form)
      end
      timer:Register(15000, -1, FORM_PUZZLE_QUEST, "give_tip", form, -1, -1)
    end
  end
end
function reset_diamond_matrix()
  local form = nx_value(FORM_PUZZLE_QUEST)
  local gui = nx_value("gui")
  form.no_operate = 100
  form.is_wait_result = true
  create_diamond_reset_effect(form.Left + form.Width / 2 - 500, form.Top + form.Height / 2)
  for j = 1, table.getn(diamond_photo) do
    if j ~= 7 then
      for i = 1, table.getn(diamond_lst) do
        diamond_label = diamond_lst[i]
        if nx_is_valid(diamond_label) and nx_find_custom(diamond_label, "diamond_type") and get_diamond_type(diamond_label.diamond_type) == j then
          diamond_label.Visible = false
          gui:Delete(diamond_label)
        end
      end
      nx_pause(0.2)
    end
  end
  for i = 1, table.getn(diamond_lst) do
    diamond_label = diamond_lst[i]
    if nx_is_valid(diamond_label) and nx_find_custom(diamond_label, "diamond_type") and get_diamond_type(diamond_label.diamond_type) == 7 then
      diamond_label.Visible = false
      gui:Delete(diamond_label)
    end
  end
  nx_pause(0.2)
  create_diamond_matrix(form, max_row, max_col)
  if nx_is_valid(form) then
    form.no_operate = 0
    form.drop_time = 0
    form.bomb_time = 0
  end
end
function destory_diamond_matrix()
  local form = nx_value(FORM_PUZZLE_QUEST)
  for i = 1, max_col do
    for j = 1, max_row do
      if data_lst[(j - 1) * max_col + i] == -1 then
        local diamond = find_diamond(form, j, i)
        if nx_is_valid(diamond) then
          diamond_operate(diamond, "bomb")
          diamond_operate(diamond, "drop")
        end
      end
    end
  end
  for i = 1, max_col do
    for j = 1, max_row do
      local r_j = max_row - j + 1
      if data_lst[(r_j - 1) * max_col + i] == -1 then
        for t = 1, r_j - 1 do
          local r_t = r_j - t
          if data_lst[(r_t - 1) * max_col + i] ~= -1 and get_diamond_type(data_lst[(r_t - 1) * max_col + i]) ~= special_type.Edge then
            local diamond = find_diamond(form, r_t, i)
            if nx_is_valid(diamond) then
              diamond.drop_dest_row = r_j
              diamond_operate(diamond, "drop")
            end
            data_lst[(r_j - 1) * max_col + i] = data_lst[(r_t - 1) * max_col + i]
            data_lst[(r_t - 1) * max_col + i] = -1
            break
          end
        end
      end
    end
  end
end
function skill_general_effect(arg)
  local form = nx_value(FORM_PUZZLE_QUEST)
  form.no_operate = 100
  form.is_wait_result = true
  form.no_operate = 0
end
function born_diamond_matrix(arg)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local control_lst = {}
  for i = 1, table.getn(arg) / 2 do
    local index = arg[i * 2 - 1]
    local patch_row = nx_number(nx_int(index / max_col)) + 1
    local patch_col = math.mod(index, max_col) + 1
    local value = arg[i * 2]
    data_lst[index + 1] = value
    diamond_name = "diamond" .. nx_string(patch_row) .. nx_string(patch_col)
    local diamond_label = form.diamond_scene:Find(diamond_name)
    control_lst[i] = diamond_label
    create_diamond_bomb_effect(form, diamond_label)
    diamond_label.diamond_type = nx_number(value)
    diamond_label.BackImage = get_diamond_photo(nx_number(value))
  end
  create_custom_effect(unpack(control_lst))
end
function change_diamond_matrix(arg)
  local form = nx_value(FORM_PUZZLE_QUEST)
  form.no_operate = 100
  form.is_wait_result = true
  local control_lst = {}
  for i = 1, table.getn(arg) / 2 do
    local index = arg[i * 2 - 1]
    local patch_row = nx_number(nx_int(index / max_col)) + 1
    local patch_col = math.mod(index, max_col) + 1
    local value = arg[i * 2]
    data_lst[index + 1] = value
    diamond_name = "diamond" .. nx_string(patch_row) .. nx_string(patch_col)
    local diamond_label = form.diamond_scene:Find(diamond_name)
    control_lst[i] = diamond_label
    create_diamond_bomb_effect(form, diamond_label)
    diamond_label.diamond_type = nx_number(value)
    diamond_label.BackImage = get_diamond_photo(nx_number(value))
    if nx_number(get_diamond_value(nx_number(value))) ~= 1 then
      diamond_label.Text = nx_widestr("+" .. nx_string(get_diamond_value(nx_number(value))))
    end
  end
  create_custom_effect(unpack(control_lst))
  nx_pause(2)
  if nx_is_valid(form) and nx_find_custom(form, "no_operate") then
    form.no_operate = 0
  end
end
function bomb_diamond(form, diamond)
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi or form.gem_game_type == gem_game_type.gt_gemegggame or form.gem_game_type == gem_game_type.gt_gemtaskgame or form.gem_game_type == gem_game_type.gt_gemtaskegggame then
    local gui = nx_value("gui")
    local bomb_effect = create_diamond_bomb_effect(form, diamond, bomb_effect)
    local bomb_path
    if game_type == 0 or game_type == 4 then
      if get_diamond_type(diamond.diamond_type) >= gem_type.Red and get_diamond_type(diamond.diamond_type) <= gem_type.Purple then
        play_sound("bomb_1")
        play_sound("en")
        bomb_path = create_diamond_path_effect(form, nx_number(form.puzzle_page.gemgame_lst.CurOPGroup), diamond, get_diamond_type(diamond.diamond_type))
        return
      end
      if get_diamond_type(diamond.diamond_type) == gem_type.Colour then
        if nx_find_custom(diamond, "color") and diamond.color ~= gem_type.Colour then
          play_sound("bomb_1")
          play_sound("en")
          bomb_path = create_diamond_path_effect(form, nx_number(form.puzzle_page.gemgame_lst.CurOPGroup), diamond, nx_number(diamond.color))
        end
        return
      end
      if get_diamond_type(diamond.diamond_type) == gem_type.Skull then
        play_sound("bomb_kulou")
        return
      end
      if get_diamond_type(diamond.diamond_type) == gem_type.MovePoint then
        play_sound("bomb_2")
        return
      end
    elseif game_type == 2 then
      if get_diamond_type(diamond.diamond_type) == gem_type.Skull then
        play_sound("bomb_1")
        play_sound("en")
        bomb_path = create_diamond_path_effect(form, nx_number(form.puzzle_page.gemgame_lst.CurOPGroup), diamond, get_diamond_type(diamond.diamond_type))
        return
      end
    elseif game_type == 3 or game_type == gem_game_mode.TaskEggMode then
      play_sound("bomb_1")
    end
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    local gui = nx_value("gui")
    local bomb_effect = create_diamond_bomb_effect(form, diamond, bomb_effect)
    local bomb_path
    play_sound("bomb_1")
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    bomb_path = create_diamond_path_effect(form, nx_number(client_player:QueryProp("CurFillState")), diamond, get_diamond_type(diamond.diamond_type))
  end
end
function give_tip(form, param1, param2)
  if is_creart_matrix_over == false then
    return
  end
  local jewel_game_manager = nx_value("jewel_game_manager")
  local res_str = jewel_game_manager:QueryDataOperate(nx_string(op_query_tip))
  if string.len(res_str) <= 0 then
    return
  end
  local res_lst = util_split_string(res_str, ",")
  show_tip(form, nx_number(res_lst[1]), nx_number(res_lst[2]))
end
function hid_tip(form)
  if nx_is_valid(form) and nx_is_valid(form:Find("diamond_scene")) then
    local diamond_tip1 = form.diamond_scene:Find("diamond_tip1")
    if nx_is_valid(diamond_tip1) then
      diamond_tip1.Visible = false
    end
    local diamond_tip2 = form.diamond_scene:Find("diamond_tip2")
    if nx_is_valid(diamond_tip2) then
      diamond_tip2.Visible = false
    end
  end
end
function show_tip(form, tip_index1, tip_index2)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.diamond_scene) then
    return
  end
  local gui = nx_value("gui")
  local diamond_tip1 = form.diamond_scene:Find("diamond_tip1")
  if not nx_is_valid(diamond_tip1) then
    diamond_tip1 = gui:Create("Label")
    diamond_tip1.AutoSize = true
    diamond_tip1.Transparent = false
    diamond_tip1.BackImage = tip_img
    diamond_tip1.DrawMode = "Tile"
    diamond_tip1.Name = "diamond_tip1"
    form.diamond_scene:Add(diamond_tip1)
    form.diamond_scene:ToFront(diamond_tip1)
    diamond_tip1.Width = 37
    diamond_tip1.Height = 38
    nx_bind_script(diamond_tip1, nx_current())
  end
  local diamond_tip2 = form.diamond_scene:Find("diamond_tip2")
  if not nx_is_valid(diamond_tip2) then
    diamond_tip2 = gui:Create("Label")
    diamond_tip2.AutoSize = true
    diamond_tip2.Transparent = false
    diamond_tip2.BackImage = tip_img
    diamond_tip2.DrawMode = "Tile"
    diamond_tip2.Name = "diamond_tip2"
    form.diamond_scene:Add(diamond_tip2)
    form.diamond_scene:ToFront(diamond_tip2)
    diamond_tip2.Width = 37
    diamond_tip2.Height = 38
    nx_bind_script(diamond_tip2, nx_current())
  end
  local src_row = nx_number(nx_int(tip_index1 / max_col)) + 1
  local src_col = math.mod(tip_index1, max_col) + 1
  local dest_row = nx_number(nx_int(tip_index2 / max_col)) + 1
  local dest_col = math.mod(tip_index2, max_col) + 1
  form.diamond_scene:ToFront(diamond_tip1)
  form.diamond_scene:ToFront(diamond_tip2)
  diamond_tip1.Visible = true
  diamond_tip2.Visible = true
  diamond_tip1.Top = (src_row - 1) * diamond_height
  diamond_tip1.Left = (src_col - 1) * diamond_width + diamond_width / 2 - diamond_tip1.Width / 2
  diamond_tip2.Top = (dest_row - 1) * diamond_height
  diamond_tip2.Left = (dest_col - 1) * diamond_width + diamond_width / 2 - diamond_tip2.Width / 2
end
function check_diamond_select(src_row, src_col, dest_row, dest_col)
  if src_row == dest_row and math.abs(src_col - dest_col) == 1 then
    return true
  elseif src_col == dest_col and math.abs(src_row - dest_row) == 1 then
    return true
  else
    return false
  end
end
function create_diamond_matrix(form, max_row, max_col)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.diamond_scene) then
    return
  end
  form.max_row = max_row
  form.max_col = max_col
  for i = 1, max_row do
    for j = 1, max_col do
      diamond_name = "diamond" .. nx_string(i) .. nx_string(j)
      local diamond_label = form.diamond_scene:Find(diamond_name)
      if not nx_is_valid(diamond_label) then
        diamond_label = gui:Create("Label")
        diamond_label.AutoSize = false
        diamond_label.Transparent = false
        form.diamond_scene:Add(diamond_label)
        form.diamond_scene:ToFront(diamond_label)
        nx_bind_script(diamond_label, nx_current())
      end
      local type = data_lst[(i - 1) * max_col + j]
      diamond_label.Visible = true
      diamond_label.DrawMode = "FitWindow"
      diamond_label.BackImage = get_diamond_photo(type)
      diamond_label.Font = "Default"
      diamond_label.ForeColor = "255,255,0,0"
      diamond_label.Align = "Center"
      diamond_label.ShadowColor = "255,0,0,0"
      diamond_label.Left = (j - 1) * diamond_width
      diamond_label.Top = (i - 1) * diamond_height
      diamond_label.next_left = 0
      diamond_label.next_top = 0
      diamond_label.Width = diamond_width
      diamond_label.Height = diamond_height
      diamond_label.diamond_type = type
      diamond_label.operate_lst = ""
      diamond_label.drop_dest_row = 0
      change_diamond_label(diamond_label, i, j)
      diamond_lst[(i - 1) * max_col + j] = diamond_label
    end
  end
end
function create_diamond_control(form, max_row, max_col)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.diamond_control) then
    return
  end
  for i = 1, max_row do
    for j = 1, max_col do
      btn_name = "btn" .. nx_string(i) .. nx_string(j)
      local btn = form.diamond_control:Find(btn_name)
      if not nx_is_valid(btn) then
        btn = gui:Create("Button")
        btn.AutoSize = true
        btn.Transparent = false
        form.diamond_control:Add(btn)
        form.diamond_control:ToFront(btn)
        nx_bind_script(btn, nx_current())
        nx_callback(btn, "on_click", "on_btn_click")
        nx_callback(btn, "on_get_capture", "on_btn_get_capture")
        nx_callback(btn, "on_lost_capture", "on_btn_lost_capture")
      end
      btn.BackImage = ""
      btn.PushImage = ""
      btn.FocusImage = ""
      btn.NormalImage = ""
      btn.LineColor = "0,0,0,0"
      btn.DrawMode = "Center"
      btn.Left = (j - 1) * diamond_width
      btn.Top = (i - 1) * diamond_height
      btn.Width = diamond_width
      btn.Height = diamond_height
      btn.Name = btn_name
      btn.diamond_row = i
      btn.diamond_col = j
      control_lst[(i - 1) * max_col + j] = btn
    end
  end
end
function create_diamond_select(diamond_control, cur_row, cur_col, index, is_self)
  local gui = nx_value("gui")
  local form = nx_value(FORM_PUZZLE_QUEST)
  local select_label = form:Find("select_label" .. nx_string(index))
  if not nx_is_valid(select_label) then
    select_label = gui:Create("Label")
    form:Add(select_label)
    form:ToFront(select_label)
  end
  select_label.Visible = true
  local diamond_label = form.diamond_scene:Find("diamond" .. nx_string(cur_row) .. nx_string(cur_col))
  select_label.BackImage = get_diamond_photo(nx_number(diamond_label.diamond_type), diamond_mouseclick)
  select_label.VAnchor = "Center"
  select_label.HAnchor = "Center"
  select_label.DrawMode = "FitWindow"
  select_label.Name = "select_label" .. nx_string(index)
  select_label.Width = diamond_width + tip_fix_width
  select_label.Height = diamond_height + tip_fix_width
  select_label.cur_row = cur_row
  select_label.cur_col = cur_col
  select_label.Left = diamond_control.Left + (cur_col - 1) * diamond_width - tip_fix_x
  select_label.Top = diamond_control.Top + (cur_row - 1) * diamond_height - tip_fix_x
  select_lst[index] = select_label
end
function clear_diamond_select()
  local form = nx_value(FORM_PUZZLE_QUEST)
  if not nx_is_valid(form) then
    return
  end
  local select_button1 = form:Find("select_label1")
  local select_button2 = form:Find("select_label2")
  if nx_is_valid(select_button1) and select_button1.Visible then
    select_button1.Visible = false
  end
  if nx_is_valid(select_button2) and select_button2.Visible then
    select_button2.Visible = false
  end
end
function get_group_index_by_name(name)
  local game_client = nx_value("game_client")
  local view_lst = {}
  view_lst[1] = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_A))
  view_lst[2] = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_B))
  for i = 1, 2 do
    if nx_is_valid(view_lst[i]) then
      local player_list = view_lst[i]:GetViewObjList()
      for j, view_item in pairs(player_list) do
        if nx_is_valid(view_item) and nx_widestr(view_item:QueryProp("PlayerName")) == nx_widestr(name) then
          return i - 1, j
        end
      end
    end
  end
  return -1, -1
end
function get_cur_skill_index_and_effect_count(form, skill_name)
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
    if game_type == 0 then
      local cur_group, cur_index = get_cur_group_and_index(form)
      local game_client = nx_value("game_client")
      local view
      if cur_group == 0 then
        view = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_A))
      else
        view = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_B))
      end
      if not nx_is_valid(view) then
        return
      end
      local view_item = view:GetViewObj(nx_string(cur_index))
      if not nx_is_valid(view_item) then
        return
      end
      skill_index = view_item:FindRecordRow("TempGemSkillRec", 0, skill_name) + 1
      local jewel_game_manager = nx_value("jewel_game_manager")
      local effect_id = nx_number(jewel_game_manager:GetGemeffect(skill_name))
      if effect_id <= 0 then
        return skill_index, 0
      end
      return skill_index, get_game_custom_effect_count(effect_id)
    else
      return 0, get_game_custom_effect_count(effect_id)
    end
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_A))
    if not nx_is_valid(view) then
      return
    end
    local view_item = view:GetViewObj("1")
    if not nx_is_valid(view_item) then
      return
    end
    skill_index = view_item:FindRecordRow("TempGemSkillRec", 0, skill_name) + 1
    local jewel_game_manager = nx_value("jewel_game_manager")
    local effect_id = nx_number(jewel_game_manager:GetJMGemeffect(skill_name))
    if effect_id <= 0 then
      return skill_index, 0
    end
    return skill_index, get_game_custom_effect_count(effect_id)
  end
end
function get_cur_group_and_index(form)
  local game_client = nx_value("game_client")
  local cur_group = form.puzzle_page.gemgame_lst.CurOPGroup
  local cur_index = 0
  local view
  if cur_group == 0 then
    cur_index = form.puzzle_page.gemgame_lst.CurGroupAIndex
  else
    cur_index = form.puzzle_page.gemgame_lst.CurGroupBIndex
  end
  return cur_group, cur_index
end
function main_form_init(self)
  self.bLoop = false
  self.no_need_motion_alpha = true
end
function resize_page(self, control)
  if not nx_is_valid(self.Parent) then
    return
  end
  if self.gem_game_type == gem_game_type.gt_caifeng or self.gem_game_type == gem_game_type.gt_tiejiang or self.gem_game_type == gem_game_type.gt_qiaojiang or self.gem_game_type == gem_game_type.gt_dushi or self.gem_game_type == gem_game_type.gt_yaoshi or self.gem_game_type == gem_game_type.gt_chushi or self.gem_game_type == gem_game_type.gt_gemegggame or self.gem_game_type == gem_game_type.gt_gemtaskgame or self.gem_game_type == gem_game_type.gt_gemtaskegggame then
    self.Width = self.Parent.Width
    self.Height = self.Parent.Height
    self.Left = self.Parent.Left
    self.Top = self.Parent.Top
    control.Width = self.Width
    control.Height = self.Height
    control.Left = (self.Width - control.Width) / 2
    control.Top = (self.Height - control.Height) / 2
    self.BackColor = "255,255,255,255"
    self.LineColor = "255,0,0,0"
    self.diamond_bg.Left = control.Left - 55
    self.diamond_bg.Top = control.Top - 60
    self.diamond_bg.Visible = true
    self:ToBack(self.diamond_bg)
    self.diamond_bg.Width = 55 + control.Width + 61
    self.diamond_bg.Height = 44 + control.Height + 34
    self.diamond_scene.Left = control.Left + diamond_matrix_x
    self.diamond_scene.Top = control.Top + diamond_matrix_y
    self.diamond_scene.Width = 560
    self.diamond_scene.Height = 560
    self.diamond_effect.Visible = false
    self.diamond_control.Left = control.Left + diamond_matrix_x
    self.diamond_control.Top = control.Top + diamond_matrix_y
    self.diamond_control.Width = 560
    self.diamond_control.Height = 560
    self.Transparent = false
    if game_type == 0 then
      create_diamond_select_effect(self, self.puzzle_page.gemgame_lst.CurOPGroup)
    end
    local form_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
    local gui = nx_value("gui")
    if nx_is_valid(form_chat) then
      if game_type == 2 then
        form_chat.AbsLeft = self.puzzle_page.AbsLeft - 5
        form_chat.AbsTop = gui.Desktop.Height - form_chat.Height + 100
      elseif game_type == 0 or game_type == 4 then
        form_chat.AbsLeft = gui.Desktop.Width / 2 - 166
        form_chat.AbsTop = gui.Desktop.Height - form_chat.Height + 100
      elseif game_type == 3 then
        form_chat.AbsLeft = self.puzzle_page.AbsLeft - 5
        form_chat.AbsTop = gui.Desktop.Height - form_chat.Height + 100
      end
    end
  elseif self.gem_game_type == gem_game_type.gt_datongjingmai then
    local gui = nx_value("gui")
    self.Fixed = false
    self.Width = control.Width
    self.Height = control.Height + 20
    self.Left = gui.Desktop.Width * 0.4
    if self.Left + self.Width > gui.Desktop.Width then
      self.Left = gui.Desktop.Width - self.Width
    end
    self.Top = (gui.Desktop.Height - self.Height) / 2
    if self.Top + self.Height > gui.Desktop.Height then
      self.Top = gui.Desktop.Height - self.Height
    end
    local form_back = nx_value("form_stage_main\\puzzle_quest\\form_back")
    if nx_is_valid(form_back) then
      form_back.Left = 0
      form_back.Top = 0
      form_back.Width = gui.Desktop.Width
      form_back.Height = gui.Desktop.Height
      form_back.lbl_back.Width = form_back.Width
      form_back.lbl_back.Height = form_back.Height
      form_back.btn_help.Left = form_back.Width - form_back.btn_help.Width
      form_back.btn_help.Top = 0
      nx_bind_script(form_back.btn_help, nx_current(), "back_init")
      nx_callback(form_back.btn_help, "on_click", "on_btn_help_click")
      form_back.btn_quit.Left = form_back.btn_help.Left
      form_back.btn_quit.Top = form_back.btn_help.Height
      nx_bind_script(form_back.btn_quit, nx_current(), "back_init")
      nx_callback(form_back.btn_quit, "on_click", "on_btn_quit_click")
    end
    control.Left = 0
    control.Top = 20
    self.BackImage = ""
    self.BackColor = "0,255,255,255"
    self.LineColor = "0,0,0,0"
    self.diamond_bg.Visible = false
    self:ToBack(self.diamond_bg)
    self.diamond_scene.Left = control.Left + 65 + 33
    self.diamond_scene.Top = control.Top + 105 - 18
    self.diamond_scene.Width = 360
    self.diamond_scene.Height = 360
    self.diamond_effect.Visible = false
    self.diamond_control.Left = control.Left + 65 + 33
    self.diamond_control.Top = control.Top + 105 - 18
    self.diamond_control.Width = 360
    self.diamond_control.Height = 360
    self.Transparent = false
  end
end
function back_init(self)
end
function on_btn_help_click(self)
end
function on_btn_quit_click(self)
  nx_execute(nx_current(), "hide_form")
end
function on_main_form_close(self)
  local jewel_game_manager = nx_value("jewel_game_manager")
  jewel_game_manager:SendServerOperate(op_exit)
  local gui = nx_value("gui")
  if nx_find_custom(self, "op_player_effect") and nx_is_valid(self.op_player_effect) then
    gui:Delete(self.op_player_effect)
  end
  if nx_is_valid(self.puzzle_page) then
    self.puzzle_page:Close()
  end
  after_op()
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
  stop_music()
  local form_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
  if nx_is_valid(form_chat) then
    form_chat.Left = -3
    form_chat.Top = -681
    nx_execute("form_stage_main\\form_main\\form_main_chat", "chat_size_change", chat_width, chat_height)
    nx_execute("form_stage_main\\form_main\\form_laba_info", "set_all_trumpet_form_visible", true)
  end
end
function change_form_size()
  local form = nx_value(FORM_PUZZLE_QUEST)
  if nx_is_valid(form) and form.Visible then
    resize_page(form, form.puzzle_page)
  end
end
function on_main_form_open(self)
  local form_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
  chat_width = form_chat.chat_list.Width
  chat_height = form_chat.chat_list.Height
  if game_type ~= 3 then
    tip_fix_width = 9
    tip_fix_x = 4
  end
  self.puzzle_page.Visible = true
  self.diamond_control.Visible = true
  self.diamond_scene.Visible = true
  self.max_row = 0
  self.max_col = 0
  change_form_size()
  local gui = nx_value("gui")
  if game_type == 3 then
    play_music("gem_egg_start")
  else
    play_music("gem_start")
  end
  nx_execute("form_stage_main\\form_main\\form_laba_info", "set_all_trumpet_form_visible", false)
end
function on_btn_get_capture(self)
  local diamond_control = self.Parent
  local form = diamond_control.Parent
  if form.gem_game_type == gem_game_type.gt_datongjingmai then
    local gui = nx_value("gui")
    local diamond = find_diamond(form, self.diamond_row, self.diamond_col)
    if not nx_is_valid(diamond) or not nx_find_custom(diamond, "diamond_type") then
      return
    end
    local diamond_type = get_diamond_type(diamond.diamond_type)
    if nx_find_custom(form.puzzle_page, "jm_ratio" .. nx_string(diamond_type)) then
      diamond_ratio = nx_custom(form.puzzle_page, "jm_ratio" .. nx_string(diamond_type))
      nx_execute("tips_game", "show_text_tip", nx_widestr(gui.TextManager:GetFormatText("ui_xl_baoshi", nx_int(diamond_ratio))), self.AbsLeft, self.AbsTop, 150, self.ParentForm)
    end
    diamond.BackImage = get_diamond_photo(nx_number(diamond.diamond_type), diamond_mousein)
  end
end
function on_btn_lost_capture(self)
  local diamond_control = self.Parent
  local form = diamond_control.Parent
  if form.gem_game_type == gem_game_type.gt_datongjingmai then
    nx_execute("tips_game", "hide_tip")
    local diamond = find_diamond(form, self.diamond_row, self.diamond_col)
    if nx_is_valid(diamond) then
      diamond.BackImage = get_diamond_photo(nx_number(diamond.diamond_type), diamond_normal)
    end
  end
end
function get_item_in_bag_count(configid)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return 0
  end
  local count = goods_grid:GetItemCount(configid)
  return count
end
function on_btn_click(self)
  local diamond_control = self.Parent
  local form = diamond_control.Parent
  local form = nx_value(FORM_PUZZLE_QUEST)
  if form.no_operate == 0 and form.drop_time == 0 and form.bomb_time == 0 and form.self_control then
    local diamond = find_diamond(form, self.diamond_row, self.diamond_col)
    if not nx_is_valid(diamond) then
      return
    end
    if get_diamond_type(diamond.diamond_type) == special_type.Edge then
      return
    end
    if game_type == 3 and form.gem_game_type == gem_game_type.gt_gemegggame then
      if get_diamond_type(diamond.diamond_type) > 9 then
        return
      elseif math.mod(diamond.diamond_type, 100) > 1 then
        return
      end
    end
    play_sound("click")
    if form.gem_game_type == gem_game_type.gt_datongjingmai then
      local gui = nx_value("gui")
      if nx_string(gui.GameHand.Type) == "diamond_skill" then
        form.src_select = nil
        if nx_is_valid(select_lst[1]) then
          select_lst[1].Visible = false
        end
        form.src_select = diamond
        create_diamond_select(diamond_control, self.diamond_row, self.diamond_col, 1, true)
        if form.puzzle_page.select_skill_type == 1 or form.puzzle_page.select_skill_type == 3 then
          nx_execute(FORM_JINGMAI, "on_use_jingmai_skill", form.puzzle_page.select_skill_id, form.puzzle_page.select_skill_index)
        elseif form.puzzle_page.select_skill_type == 2 then
          nx_execute(FORM_JINGMAI, "on_use_jingmai_item", form.puzzle_page.select_skill_id, form.puzzle_page.select_skill_index)
        end
        local gui = nx_value("gui")
        gui.GameHand:ClearHand()
        return
      end
    end
    if game_type == 0 and form.gem_game_type ~= gem_game_type.gt_datongjingmai then
      local gui = nx_value("gui")
      if nx_string(gui.GameHand.Type) == "diamond_skill" then
        form.src_select = nil
        if nx_is_valid(select_lst[1]) then
          select_lst[1].Visible = false
        end
        form.src_select = diamond
        create_diamond_select(diamond_control, self.diamond_row, self.diamond_col, 1, true)
        if form.src_select ~= nil then
          select_diamond_index = (form.src_select.diamond_row - 1) * form.max_col + form.src_select.diamond_col - 1
        end
        local jewel_game_manager = nx_value("jewel_game_manager")
        jewel_game_manager:SendServerOperate(op_skill, nx_string(form.select_skill_id), select_diamond_index)
        local gui = nx_value("gui")
        gui.CoolManager:StartACool(nx_int(984125), 1000, nx_int(-1), 0)
        gui.GameHand:ClearHand()
        return
      end
    end
    if game_type == 3 and form.gem_game_type == gem_game_type.gt_gemegggame or game_type == gem_game_mode.TaskEggMode and form.gem_game_type == gem_game_type.gt_gemtaskegggame then
      local gui = nx_value("gui")
      if nx_string(gui.GameHand.Type) == "diamond_skill" and nx_find_custom(form, "select_skill_id") then
        form.src_select = nil
        if nx_is_valid(select_lst[1]) then
          select_lst[1].Visible = false
        end
        local skill_desc = {
          gemegg_001 = "ui_ydhd_skill_01",
          gemegg_002 = "ui_ydhd_skill_02",
          gemegg_003 = "ui_ydhd_skill_03",
          gemegg_004 = "ui_ydhd_skill_03"
        }
        local skill_desc_1 = {
          gemegg_001 = "ui_ydhd_skill_05",
          gemegg_002 = "ui_ydhd_skill_06",
          gemegg_003 = "ui_ydhd_skill_07",
          gemegg_004 = "ui_ydhd_skill_07"
        }
        local skill_to_item = {
          gemegg_001 = "item_zd_yinchui",
          gemegg_002 = "item_zd_jinchui",
          gemegg_003 = "item_zd_yuchui",
          gemegg_004 = "item_zd_yuchui"
        }
        form.src_select = diamond
        create_diamond_select(diamond_control, self.diamond_row, self.diamond_col, 1, true)
        if form.src_select ~= nil then
          select_diamond_index = (form.src_select.diamond_row - 1) * form.max_col + form.src_select.diamond_col - 1
        end
        local jewel_game_manager = nx_value("jewel_game_manager")
        local ask_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
        ask_dialog.Left = form.Left + (form.Width - ask_dialog.Width) / 2
        ask_dialog.Top = form.Top + (form.Height - ask_dialog.Height) / 2
        local text
        if game_type == gem_game_mode.TaskEggMode and form.select_skill_id == "gemegg_004" then
          text = gui.TextManager:GetText("ui_yhgzd_confirm")
        elseif 0 < get_item_in_bag_count(skill_to_item[form.select_skill_id]) then
          text = gui.TextManager:GetText(skill_desc_1[form.select_skill_id])
        else
          text = gui.TextManager:GetText(skill_desc[form.select_skill_id])
        end
        nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
        ask_dialog:ShowModal()
        ask_dialog.no_need_motion_alpha = false
        local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
        if res == "ok" then
          if nx_is_valid(form) then
            jewel_game_manager:SendServerOperate(op_skill, nx_string(form.select_skill_id), select_diamond_index)
            local gui = nx_value("gui")
            gui.CoolManager:StartACool(nx_int(984125), 1000, nx_int(-1), 0)
            gui.GameHand:ClearHand()
          end
        elseif res == "cancel" then
        end
        return
      end
    end
    if form.src_select == nil then
      form.src_select = diamond
      create_diamond_select(diamond_control, self.diamond_row, self.diamond_col, 1, true)
    elseif nx_string(form.src_select) == nx_string(diamond) then
      form.src_select = nil
      if nx_is_valid(select_lst[1]) then
        select_lst[1].Visible = false
      end
    elseif check_diamond_select(form.src_select.diamond_row, form.src_select.diamond_col, diamond.diamond_row, diamond.diamond_col) then
      is_need_recover = true
      form.dest_select = diamond
      create_diamond_select(diamond_control, self.diamond_row, self.diamond_col, 2, true)
      hid_tip(form)
      move_diamond(form.src_select.diamond_row, form.src_select.diamond_col, form.dest_select.diamond_row, form.dest_select.diamond_col)
    else
      form.src_select = diamond
      create_diamond_select(diamond_control, self.diamond_row, self.diamond_col, 1, true)
    end
  else
    play_sound("click_error")
  end
end
function find_diamond(form, row, col)
  local diamond_label_name = "diamond" .. nx_string(row) .. nx_string(col)
  return form.diamond_scene:Find(diamond_label_name)
end
function prepare_op()
  local form = nx_value(FORM_PUZZLE_QUEST)
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi or form.gem_game_type == gem_game_type.gt_gemegggame or form.gem_game_type == gem_game_type.gt_gemtaskegggame then
    local world = nx_value("world")
    local scene = world.MainScene
    local game_config = nx_value("game_config")
    local game_config_simple = nx_value("game_config_simple")
    local temp_config = nx_create("GameConfig")
    local custom_table = nx_property_list(game_config)
    for i = 1, table.getn(custom_table) do
      local custom_name = custom_table[i]
      local custom_value = nx_property(game_config, custom_name)
      nx_set_property(temp_config, custom_name, custom_value)
    end
    temp_config.level = "simple"
    temp_config.area_music_enable = false
    nx_execute("game_config", "copy_performance_config", temp_config, game_config_simple)
    nx_execute("game_config", "apply_performance_config", scene, temp_config)
    nx_destroy(temp_config)
    local gui = nx_value("gui")
    temp_scale = gui.ScaleRatio
    gui.ScaleRatio = 1
    gui.Desktop.Width = gui.Width
    gui.Desktop.Height = gui.Height
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    nx_execute("gui", "gui_close_allsystem_form")
    local gui = nx_value("gui")
    temp_scale = gui.ScaleRatio
    gui.ScaleRatio = 1
    gui.Desktop.Width = gui.Width
    gui.Desktop.Height = gui.Height
    local form_back = util_get_form("form_stage_main\\puzzle_quest\\form_back", true)
    if nx_is_valid(form_back) then
      form_back.lbl_cantfaculty.Visible = false
      form_back.Left = 0
      form_back.Top = 0
      form_back.Width = gui.Desktop.Width
      form_back.Height = gui.Desktop.Height
      form_back.lbl_back.Width = form_back.Width
      form_back.lbl_back.Height = form_back.Height
    end
    auto_show_hide_alpha_in_out("form_stage_main\\puzzle_quest\\form_back")
  end
end
function after_op()
  local form = nx_value(FORM_PUZZLE_QUEST)
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi or form.gem_game_type == gem_game_type.gt_gemegggame or form.gem_game_type == gem_game_type.gt_gemtaskegggame then
    local world = nx_value("world")
    local scene = world.MainScene
    scene.terrain.WaterVisible = true
    scene.terrain.GroundVisible = true
    scene.terrain.VisualVisible = true
    scene.terrain.HelperVisible = true
    local game_config = nx_value("game_config")
    nx_execute("game_config", "apply_performance_config", scene, game_config)
    local gui = nx_value("gui")
    gui.ScaleRatio = temp_scale
    gui.Desktop.Width = gui.Width
    gui.Desktop.Height = gui.Height
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    nx_execute("gui", "gui_open_closedsystem_form")
    local gui = nx_value("gui")
    gui.ScaleRatio = temp_scale
    local scene = nx_value("game_scene")
    scene.game_control.AllowControl = true
    gui.Desktop.Width = gui.Width
    gui.Desktop.Height = gui.Height
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\puzzle_quest\\form_back")
  end
end
function show_form(type)
  change_control_show_lst = {}
  is_game_over = false
  local form = nx_execute("util_gui", "util_get_form", FORM_PUZZLE_QUEST, true)
  form.gem_game_type = type
  form.Fixed = true
  form.src_select = nil
  form.dest_select = nil
  form.no_operate = 0
  form.drop_time = 0
  form.bomb_time = 0
  form.self_control = true
  form.self_group = 0
  form.self_index = 0
  form.error_max = 1
  form.can_eat = 1
  form.is_wait_result = false
  form.cur_skill_index = 0
  form.cur_skill_name = ""
  form.cur_skill_effect_count = 0
  if form.gem_game_type ~= gem_game_type.gt_datongjingmai then
    local game_client = nx_value("game_client")
    local view_item = game_client:GetView(nx_string(VIEWPORT_GEM_BOX))
    game_type = nx_number(view_item:QueryProp("Type"))
    init_gem_game_info(form.gem_game_type, game_type)
  else
    init_gem_game_info(form.gem_game_type, game_type)
  end
  init_gem_effet_data()
  prepare_op()
  local caifeng_page
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi or form.gem_game_type == gem_game_type.gt_gemegggame or form.gem_game_type == gem_game_type.gt_gemtaskgame or form.gem_game_type == gem_game_type.gt_gemtaskegggame then
    local game_client = nx_value("game_client")
    local view_item = game_client:GetView(nx_string(VIEWPORT_GEM_BOX))
    game_type = nx_number(view_item:QueryProp("Type"))
    if game_type == 0 then
      play_sound("start")
      caifeng_page = nx_execute("util_gui", "util_get_form", skin_lst[form.gem_game_type], true, false)
    elseif game_type == 2 then
      current_form_name = skin_lst_1[form.gem_game_type]
      work_type = form.gem_game_type
      caifeng_page = nx_execute("util_gui", "util_get_form", skin_lst_1[form.gem_game_type], true, false)
    elseif game_type == 3 then
      caifeng_page = nx_execute("util_gui", "util_get_form", skin_lst_2[form.gem_game_type], true, false)
    elseif game_type == 4 then
      caifeng_page = nx_execute("util_gui", "util_get_form", skin_lst[form.gem_game_type], true, false)
    elseif game_type == 5 then
      caifeng_page = nx_execute("util_gui", "util_get_form", skin_lst_2[form.gem_game_type], true, false)
    end
    caifeng_page.gem_game_type = form.gem_game_type
    caifeng_page.skillanim = skillanim
    caifeng_page.type = form.gem_game_type
    local ret = form:Add(caifeng_page)
    if ret == true then
      form.puzzle_page = caifeng_page
      form.puzzle_page.Left = 0
      form.puzzle_page.Top = 0
      form:ToBack(form.puzzle_page)
    end
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    local jingmai_page = nx_execute("util_gui", "util_get_form", FORM_JINGMAI, true, false)
    local ret = form:Add(jingmai_page)
    if ret == true then
      form.puzzle_page = jingmai_page
      form.puzzle_page.Left = 0
      form.puzzle_page.Top = 0
      form:ToBack(form.puzzle_page)
    end
  end
  auto_show_hide_alpha_in_out(FORM_PUZZLE_QUEST)
  if form.gem_game_type ~= gem_game_type.gt_datongjingmai then
    local gui = nx_value("gui")
    local form_chat
    form_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
    form.Parent:ToFront(form_chat)
    if game_type == 2 then
      form_chat.AbsLeft = form.puzzle_page.AbsLeft - 5
      form_chat.AbsTop = gui.Desktop.Height - form_chat.Height + 100
      local btn = form_chat:Find("btn_marry")
      if nx_is_valid(btn) then
        btn.Visible = false
      end
    elseif game_type == 0 then
      form_chat.AbsLeft = gui.Desktop.Width / 2 - 166
      form_chat.AbsTop = gui.Desktop.Height - form_chat.Height + 100
      form_chat.chat_list.Width = 270
      form_chat.chat_list.Height = 170
      nx_execute("form_stage_main\\form_main\\form_main_chat", "chat_size_change", form_chat.chat_list.Width, form_chat.chat_list.Height)
      local btn = form_chat:Find("btn_marry")
      if nx_is_valid(btn) then
        btn.Visible = false
      end
    elseif game_type == 3 then
      form_chat.AbsLeft = form.puzzle_page.AbsLeft - 5
      form_chat.AbsTop = gui.Desktop.Height - form_chat.Height + 100
      local btn = form_chat:Find("btn_marry")
      if nx_is_valid(btn) then
        btn.Visible = false
      end
    end
  end
  local world = nx_value("world")
  local scene = world.MainScene
  scene.terrain.WaterVisible = false
  scene.terrain.GroundVisible = false
  scene.terrain.VisualVisible = false
  scene.terrain.HelperVisible = false
  form.bLoop = true
  nx_execute("form_stage_main\\form_main\\form_laba_info", "set_all_trumpet_form_visible", false)
end
function hide_form()
  local form = nx_value(FORM_PUZZLE_QUEST)
  if not nx_is_valid(form) then
    return
  end
  if form.BlendAlpha < 255 then
    return
  end
  if form.gem_game_type == 0 or form.gem_game_type == 2 then
    local puzzle_help_form = nx_value(help_skin_lst[form.puzzle_page.gem_game_type])
    local puzzle_quest_help_form = nx_value(help_skin_lst_1[form.puzzle_page.gem_game_type])
    if nx_is_valid(puzzle_help_form) and puzzle_help_form.Visible then
      puzzle_help_form:Close()
      return
    end
    local puzzle_life_fight = nx_value("form_stage_main\\puzzle_quest\\form_puzzle_life_fight")
    if nx_is_valid(puzzle_life_fight) and puzzle_life_fight.Visible then
      puzzle_life_fight:Close()
      return
    end
    if nx_is_valid(puzzle_quest_help_form) and puzzle_quest_help_form.Visible then
      puzzle_quest_help_form:Close()
      return
    end
  end
  local gui = nx_value("gui")
  local ask_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  ask_dialog.Left = form.Left + (form.Width - ask_dialog.Width) / 2
  ask_dialog.Top = form.Top + (form.Height - ask_dialog.Height) / 2
  local text = nx_widestr("")
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi or form.gem_game_type == gem_game_type.gt_gemtaskgame then
    text = nx_widestr(gui.TextManager:GetText("ui_diamond_wantquit"))
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    text = nx_widestr(gui.TextManager:GetText("ui_diamond2_wantquit"))
  elseif form.gem_game_type == gem_game_type.gt_gemegggame then
    text = nx_widestr(gui.TextManager:GetText("ui_ydhd_close"))
  elseif form.gem_game_type == gem_game_type.gt_gemtaskegggame then
    text = nx_widestr(gui.TextManager:GetText("ui_yhg_mrzd_exit"))
  end
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  ask_dialog:ShowModal()
  ask_dialog.no_need_motion_alpha = false
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  if res == "ok" then
    if nx_is_valid(form) then
      if form.gem_game_type == gem_game_type.gt_datongjingmai then
        specialform_alpha_out(FORM_PUZZLE_QUEST, 1)
      else
        show_world_alpha_out()
      end
    end
  elseif res == "cancel" then
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.CoolManager:StartACool(nx_int(984125), 1000, nx_int(-1), 0)
    gui.GameHand:ClearHand()
  end
end
function create_diamond_select_effect(form, camp)
  local ani_path_pos_list = {}
  local control
  if not nx_is_valid(form) then
    return
  end
  if camp == 0 then
    if nx_find_custom(form, "puzzle_page") and nx_is_valid(form.puzzle_page) then
      form.puzzle_page.lbl_ani_b.Visible = false
      form.puzzle_page.lbl_photo_a.Visible = false
      form.puzzle_page.lbl_ani_a.BackImage = diamond_hurt_effect.showcamp0
      form.puzzle_page.lbl_ani_a.Visible = true
      form.puzzle_page.lbl_photo_b.Visible = true
    end
  elseif nx_find_custom(form, "puzzle_page") and nx_is_valid(form.puzzle_page) then
    form.puzzle_page.lbl_ani_a.Visible = false
    form.puzzle_page.lbl_photo_b.Visible = false
    form.puzzle_page.lbl_ani_b.BackImage = diamond_hurt_effect.showcamp1
    form.puzzle_page.lbl_ani_b.Visible = true
    form.puzzle_page.lbl_photo_a.Visible = true
  end
end
local jimgmai_after = {
  [1] = "jing",
  [2] = "mu",
  [3] = "shui",
  [4] = "huo",
  [5] = "tu",
  [6] = "",
  [7] = "yin",
  [8] = "yang"
}
function on_end_create_path(form)
  if form.gem_game_type == gem_game_type.gt_datongjingmai then
    local scene = nx_value("game_scene")
    scene.game_control.AllowControl = true
  end
end
function create_diamond_path_effect(form, camp, diamond_label, dest_color_index)
  if form.can_eat == 0 then
    return
  end
  local after_str = ""
  local ani_param = {}
  if 5 < dest_color_index then
    ani_param.AnimationImage = "gui\\animations\\path_effect\\star.dds"
  else
    ani_param.AnimationImage = gem_color_image[nx_number(dest_color_index)]
  end
  ani_param.SmoothPath = true
  ani_param.Loop = false
  ani_param.ClosePath = false
  ani_param.CreateMinInterval = 5
  ani_param.CreateMaxInterval = 10
  ani_param.RotateSpeed = 3
  ani_param.BeginAlpha = 0.8
  ani_param.AlphaChangeSpeed = 0.3
  ani_param.BeginScale = 0.27
  ani_param.ScaleSpeed = 0
  ani_param.MaxTime = 1000
  ani_param.MaxWave = 0.05
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_end_create_path", form)
    timer:Register(ani_param.MaxTime * 3, 1, nx_current(), "on_end_create_path", form, -1, -1)
  end
  local ani_path_pos_list = {}
  ani_path_pos_list[1] = {left = 0, top = 0}
  ani_path_pos_list[1].left = diamond_label.AbsLeft + diamond_label.Width / 2
  ani_path_pos_list[1].top = diamond_label.AbsTop + diamond_label.Height / 2
  local dest_control
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi or form.gem_game_type == gem_game_type.gt_gemtaskgame then
    if game_type == 2 then
      dest_control = form.puzzle_page.product_grid
      ani_path_pos_list[3] = {left = 0, top = 0}
      ani_path_pos_list[3].left = dest_control.AbsLeft + dest_control.Width / 2
      ani_path_pos_list[3].top = dest_control.AbsTop + dest_control.Height / 2
    else
      if camp == 0 then
        after_str = "_a"
      else
        after_str = "_b"
      end
      local denglong = form.puzzle_page:Find("gb_denglong" .. after_str)
      dest_control = denglong:Find("lbl_dlback" .. nx_string(dest_color_index) .. after_str)
      if nx_is_valid(dest_control) then
        ani_path_pos_list[3] = {left = 0, top = 0}
        ani_path_pos_list[3].left = dest_control.AbsLeft + dest_control.Width / 2
        ani_path_pos_list[3].top = dest_control.AbsTop + dest_control.Height / 2
      end
    end
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    local scene = nx_value("game_scene")
    scene.game_control.AllowControl = false
    local scene_x = 0
    local scene_y = 0
    if camp == 1 then
      scene_x, scene_y = get_fill_ball_pos()
    elseif camp == 2 then
      scene_x, scene_y = get_break_ball_pos(dest_color_index)
    end
    ani_path_pos_list[3] = {left = 0, top = 0}
    ani_path_pos_list[3].left = scene_x
    ani_path_pos_list[3].top = scene_y
  end
  ani_path_pos_list[2] = {left = 0, top = 0}
  if ani_path_pos_list[3] == nil then
    return
  end
  ani_path_pos_list[2].left = math.random(math.min(ani_path_pos_list[1].left, ani_path_pos_list[3].left), math.max(ani_path_pos_list[1].left, ani_path_pos_list[3].left))
  ani_path_pos_list[2].top = math.random(math.min(ani_path_pos_list[1].top, ani_path_pos_list[3].top), math.max(ani_path_pos_list[1].top, ani_path_pos_list[3].top))
  return create_path_ani(form, ani_path_pos_list, ani_param, true)
end
function create_use_weapon_path_effect(form, src_control, dest_control)
  local ani_param = {}
  ani_param.AnimationImage = "gui\\animations\\path_effect\\star.dds"
  ani_param.SmoothPath = true
  ani_param.Loop = false
  ani_param.ClosePath = false
  ani_param.CreateMinInterval = 5
  ani_param.CreateMaxInterval = 10
  ani_param.RotateSpeed = 3
  ani_param.BeginAlpha = 0.8
  ani_param.AlphaChangeSpeed = 0.3
  ani_param.BeginScale = 0.27
  ani_param.ScaleSpeed = 0
  ani_param.MaxTime = 1000
  ani_param.MaxWave = 0.05
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_end_create_path", form)
    timer:Register(ani_param.MaxTime * 3, 1, nx_current(), "on_end_create_path", form, -1, -1)
  end
  local ani_path_pos_list = {}
  ani_path_pos_list[1] = {left = 0, top = 0}
  ani_path_pos_list[1].left = src_control.AbsLeft + src_control.Width / 2
  ani_path_pos_list[1].top = src_control.AbsTop + src_control.Height / 2
  ani_path_pos_list[2] = {left = 0, top = 0}
  ani_path_pos_list[2].left = dest_control.AbsLeft + dest_control.Width / 2
  ani_path_pos_list[2].top = dest_control.AbsTop + dest_control.Height / 2
  return create_path_ani(form, ani_path_pos_list, ani_param, true)
end
function create_diamond_bomb_effect(form, diamond_label)
  local ani_param = {}
  ani_param.Width = diamond_width
  ani_param.Height = diamond_height
  ani_param.Left = form.diamond_control.Left + diamond_label.Left
  ani_param.Top = form.diamond_control.Top + diamond_label.Top
  ani_param.OffsetX = -bomb_fix_x
  ani_param.OffsetY = -bomb_fix_y
  ani_param.VAnchor = "Left"
  ani_param.HAnchor = "Top"
  ani_param.Loop = false
  return create_fix_ani(diamond_bomb[get_diamond_type(diamond_label.diamond_type)], gem_color[get_diamond_type(diamond_label.diamond_type)], ani_param, true, true)
end
function create_diamond_number_effect(form, args)
  local count = table.getn(args)
  local diamond_label
  local diamond_value = 0
  local diamond_type = 0
  local is_get_diamond_type = false
  local is_have_color_diamond = false
  local color_diamond_index = -1
  for i = 1, table.getn(args) do
    local index = args[i]
    diamond_value = diamond_value + get_diamond_value(nx_number(data_lst[index + 1]))
    local tmp_type = get_diamond_type(data_lst[index + 1])
    if is_get_diamond_type == false and nx_number(tmp_type) ~= nx_number(gem_type.Colour) then
      diamond_type = tmp_type
      is_get_diamond_type = true
    end
    if is_have_color_diamond == false and nx_number(tmp_type) == nx_number(gem_type.Colour) then
      color_diamond_index = index
      is_have_color_diamond = true
    end
    if i == count then
      local row = nx_number(nx_int(index / max_col)) + 1
      local col = math.mod(index, max_col) + 1
      diamond_label = form.diamond_scene:Find("diamond" .. nx_string(row) .. nx_string(col))
    end
  end
  if is_have_color_diamond then
    local row = nx_number(nx_int(color_diamond_index / max_col)) + 1
    local col = math.mod(color_diamond_index, max_col) + 1
    local color_diamond_label = form.diamond_scene:Find("diamond" .. nx_string(row) .. nx_string(col))
    color_diamond_label.color = diamond_type
  end
  diamond_value = diamond_value + nx_number(prop_add_value(diamond_type))
  if nx_is_valid(diamond_label) and nx_number(diamond_type) ~= 0 then
    create_number_ani(diamond_value, gem_number_effect[diamond_type], diamond_label.AbsLeft, diamond_label.AbsTop, true)
  end
end
function prop_add_value(diamond_type)
  local game_client = nx_value("game_client")
  local view_index = -1
  local form = nx_value(FORM_PUZZLE_QUEST)
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_find_custom(form, "puzzle_page") or not nx_is_valid(form.puzzle_page) then
    return 0
  end
  if not nx_find_custom(form.puzzle_page, "gemgame_lst") or not nx_is_valid(form.puzzle_page.gemgame_lst) then
    return 0
  end
  if not nx_find_custom(form.puzzle_page.gemgame_lst, "CurOPGroup") then
    return 0
  end
  if form.puzzle_page.gemgame_lst.CurOPGroup == 0 then
    view_index = VIEWPORT_GEM_GROUP_A
  else
    view_index = VIEWPORT_GEM_GROUP_B
  end
  if view_index == -1 then
    return 0
  end
  local view = game_client:GetView(nx_string(view_index))
  if not nx_is_valid(view) then
    return 0
  end
  local view_item = view:GetViewObj(nx_string(form.self_index))
  if not nx_is_valid(view_item) then
    return 0
  end
  local value = nx_number(view_item:QueryProp(nx_string(gem_prop[diamond_type])))
  if 1 <= value and value < 3 then
    return 0
  elseif 3 <= value and value < 6 then
    return 1
  elseif 6 <= value and value < 10 then
    return 2
  elseif 10 <= value and value < 15 then
    return 3
  elseif 15 <= value and value < 21 then
    return 4
  elseif 21 <= value and value < 28 then
    return 5
  elseif 28 <= value and value < 36 then
    return 6
  elseif 36 <= value and value < 45 then
    return 7
  elseif 45 <= value and value < 55 then
    return 8
  elseif 55 <= value and value < 66 then
    return 9
  elseif 66 <= value then
    return 10
  else
    return 0
  end
end
function create_diamond_star_img_effect(start_x, start_z, count)
  if count < 4 then
    return
  end
  if 8 < count then
    count = 8
  end
  local effect_name = nx_string(count) .. "star"
  create_img_ani(diamond_img_text[effect_name], start_x, start_z)
  play_sound(nx_string(count) .. "star")
  local form = nx_value(FORM_PUZZLE_QUEST)
  if game_type == 0 and form.gem_game_type ~= gem_game_type.gt_datongjingmai then
    create_img_ani(diamond_img_text.ex_turn, start_x + 200, start_z + 20)
  end
end
function create_diamond_hits_img_effect(start_x, start_z, count)
  if count < 3 then
    return
  end
  if 5 < count then
    count = 5
  end
  local effect_name = nx_string(count) .. "hits"
  create_img_ani(diamond_img_text[effect_name], start_x, start_z)
  play_sound(nx_string(count) .. "hit")
  local form = nx_value(FORM_PUZZLE_QUEST)
  if form.gem_game_type ~= gem_game_type.gt_datongjingmai then
    create_img_ani(diamond_img_text.ex_turn, start_x + 210, start_z + 20)
  end
end
function create_diamond_start_effect(start_x, start_z, is_self_group)
  if is_self_group then
    create_img_ani(diamond_img_text.my_turn, start_x, start_z)
  else
    create_img_ani(diamond_img_text.other_turn, start_x, start_z)
  end
end
function create_diamond_reset_effect(start_x, start_z)
  create_img_ani(diamond_img_text.reset, start_x, start_z)
end
function create_diamond_prop_effect(form, camp, control_name, ani)
  local after_str_lst = {
    [0] = "a",
    [1] = "b"
  }
  local gui = nx_value("gui")
  local after_str = after_str_lst[camp]
  local control
  if nx_find_custom(form.puzzle_page, control_name .. "_" .. after_str) then
    control = nx_custom(form.puzzle_page, control_name .. "_" .. after_str)
  end
  local ani_img = "ani_" .. control_name .. "_" .. after_str
  local ani_img_control = form:Find(ani_img)
  if not nx_is_valid(ani_img_control) then
    ani_img_control = gui:Create("Label")
    form:Add(ani_img_control)
    form:ToFront(ani_img_control)
    ani_img_control.BackImage = diamond_hurt_effect[ani]
    ani_img_control.Width = 84
    ani_img_control.Height = 84
    ani_img_control.Left = control.AbsLeft - ani_img_control.Width / 2 + 12
    ani_img_control.Top = control.AbsTop - ani_img_control.Height / 2 + 12
    ani_img_control.DrawMode = "Tile"
    ani_img_control.Name = "ani_img_control"
  end
  ani_img_control.Visible = true
  nx_pause(2)
  if nx_is_valid(ani_img_control) then
    ani_img_control.Visible = false
  end
end
function create_diamond_hurt_effect(form, camp, hurt, player_name, type, is_block, is_crit)
  if not nx_is_valid(form) then
    return
  end
  local control, pos_control, use_weapon_src_control, use_weapon_dest_control
  if camp == 0 then
    control = form.puzzle_page.gb_one_role_a
    pos_control = form.puzzle_page.lbl_mark_damage_pos_1
    use_weapon_src_control = form.puzzle_page.grid_item_left_b
    use_weapon_dest_control = form.puzzle_page.lbl_photo_a
  else
    control = form.puzzle_page.gb_one_role_b
    pos_control = form.puzzle_page.lbl_mark_damage_pos_2
    use_weapon_src_control = form.puzzle_page.grid_item_left_a
    use_weapon_dest_control = form.puzzle_page.lbl_photo_b
  end
  local control_name = scene_effect_position.hurt .. "_" .. CONTROL_NAME_SUFFIX[nx_string(camp)]
  control_hurt = control:Find(control_name)
  if not nx_find_custom(form, "no_operate") then
    return
  end
  form.no_operate = form.no_operate + 1
  form.is_wait_result = true
  if nx_number(type) == damage_type.damage_magic then
    if nx_is_valid(pos_control) then
      if nx_number(hurt) == 0 then
        create_img_ani(diamond_img_text.get_offset, pos_control.AbsLeft - 70, pos_control.AbsTop)
      else
        create_only_number_ani(hurt, diamond_img_text.get_hurt, pos_control.AbsLeft - 138, pos_control.AbsTop)
      end
    end
  elseif nx_number(type) == damage_type.damage_skull or nx_number(type) == damage_type.damage_weapon then
    if nx_is_valid(pos_control) and nx_number(hurt) ~= 0 then
      if is_crit and is_block then
        create_img_ani(diamond_img_text.get_break, pos_control.AbsLeft - 120, pos_control.AbsTop)
        create_only_number_ani(hurt, diamond_img_text.get_parry, pos_control.AbsLeft, pos_control.AbsTop)
      elseif is_crit and not is_block then
        create_only_number_ani(hurt, diamond_img_text.get_break, pos_control.AbsLeft - 100, pos_control.AbsTop)
      elseif is_block and not is_crit then
        create_only_number_ani(hurt, diamond_img_text.get_parry, pos_control.AbsLeft - 70, pos_control.AbsTop)
      else
        create_only_number_ani(hurt, diamond_img_text.get_hurt, pos_control.AbsLeft - 138, pos_control.AbsTop)
      end
    elseif nx_is_valid(pos_control) and nx_number(hurt) == 0 then
      create_img_ani("get_absorb", pos_control.AbsLeft - 100, pos_control.AbsTop)
    end
    if nx_number(type) == damage_type.damage_weapon and nx_is_valid(use_weapon_src_control) and nx_is_valid(use_weapon_dest_control) then
      create_use_weapon_path_effect(form, use_weapon_src_control, use_weapon_dest_control)
    end
  end
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "no_operate") then
    return
  end
  form.no_operate = form.no_operate - 1
  if camp == 0 then
    form.puzzle_page.lbl_photo_a.Visible = false
    form.puzzle_page.lbl_ani_a.BackImage = diamond_hurt_effect.hurt0
    form.puzzle_page.lbl_ani_a.Visible = true
  else
    form.puzzle_page.lbl_photo_b.Visible = false
    form.puzzle_page.lbl_ani_b.BackImage = diamond_hurt_effect.hurt1
    form.puzzle_page.lbl_ani_b.Visible = true
  end
  local gui = nx_value("gui")
  if nx_string(form.puzzle_page.role_name) ~= nx_string(player_name) then
    nx_pause(1.5)
    if nx_is_valid(form) and nx_find_custom(form, "puzzle_page") then
      form.puzzle_page.lbl_photo_a.Visible = true
      form.puzzle_page.lbl_ani_a.Visible = false
      create_diamond_select_effect(form, camp)
    end
    return
  end
  local hurt_self_scene_label = form:Find("hurt_self_scene")
  if not nx_is_valid(hurt_self_scene_label) then
    hurt_self_scene_label = gui:Create("Label")
    form:Add(hurt_self_scene_label)
    form:ToFront(hurt_self_scene_label)
  end
  hurt_self_scene_label.Visible = true
  hurt_self_scene_label.BackImage = diamond_hurt_effect.normal
  hurt_self_scene_label.DrawMode = "FitWindow"
  hurt_self_scene_label.Name = "hurt_scene" .. nx_string(camp)
  hurt_self_scene_label.Width = form.Width
  hurt_self_scene_label.Height = form.Height
  hurt_self_scene_label.Left = form.AbsLeft
  hurt_self_scene_label.Top = form.AbsTop
  nx_pause(1.5)
  if nx_is_valid(form) and nx_find_custom(form, "puzzle_page") then
    form.puzzle_page.lbl_photo_a.Visible = true
    form.puzzle_page.lbl_ani_a.Visible = false
  end
  if nx_is_valid(hurt_self_scene_label) then
    hurt_self_scene_label.Visible = false
  end
  create_diamond_select_effect(form, camp)
end
function on_ani_fix_end(self)
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
function create_number_ani(number, color, start_x, start_z)
  local SpriteManager = nx_value("SpriteManager")
  SpriteManager:ShowBallFormScreenPos(nx_string(color), "+" .. nx_string(number), start_x, start_z, "")
end
function create_only_number_ani(number, color, start_x, start_z)
  local SpriteManager = nx_value("SpriteManager")
  SpriteManager:ShowBallFormScreenPos(nx_string(color), nx_string(number), start_x, start_z, "")
end
function create_img_ani(sect, start_x, start_z)
  local SpriteManager = nx_value("SpriteManager")
  SpriteManager:ShowBallFormScreenPos(sect, "", start_x, start_z, "")
end
function create_fix_ani(ani_source, ani_color, ani_param, be_show, be_center)
  local gui = nx_value("gui")
  local ani_fix = gui:Create("Animation")
  ani_fix.AnimationImage = ani_source
  ani_fix.BlendColor = ani_color
  form = nx_value(FORM_PUZZLE_QUEST)
  form:Add(ani_fix)
  nx_bind_script(ani_fix, nx_current())
  nx_callback(ani_fix, "on_animation_end", "on_ani_fix_end")
  ani_fix.Visible = true
  if be_center then
    ani_fix.VAnchor = "Center"
    ani_fix.HAnchor = "Center"
  end
  ani_fix.Loop = ani_param.Loop
  ani_fix.Left = ani_param.Left
  ani_fix.Top = ani_param.Top
  ani_fix.OffsetX = ani_param.OffsetX
  ani_fix.OffsetY = ani_param.OffsetY
  ani_fix:Stop()
  if be_show then
    ani_fix:Play()
  end
  return ani_fix
end
function on_ani_path_end(self)
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
function create_path_ani(form, ani_path_pos_list, ani_param, be_show)
  local gui = nx_value("gui")
  local ani_path = gui:Create("AnimationPath")
  ani_path.Name = ani_name
  form:Add(ani_path)
  ani_path.AnimationImage = ani_param.AnimationImage
  ani_path.SmoothPath = ani_param.SmoothPath
  ani_path.Loop = ani_param.Loop
  ani_path.ClosePath = ani_param.ClosePath
  ani_path.Color = ani_param.Color
  ani_path.CreateMinInterval = ani_param.CreateMinInterval
  ani_path.CreateMaxInterval = ani_param.CreateMaxInterval
  ani_path.RotateSpeed = ani_param.RotateSpeed
  ani_path.BeginAlpha = ani_param.BeginAlpha
  ani_path.AlphaChangeSpeed = ani_param.AlphaChangeSpeed
  ani_path.BeginScale = ani_param.BeginScale
  ani_path.ScaleSpeed = ani_param.ScaleSpeed
  ani_path.MaxTime = ani_param.MaxTime
  ani_path.MaxWave = ani_param.MaxWave
  ani_path:ClearPathPoints()
  for i = 1, table.getn(ani_path_pos_list) do
    local ani_path_pos = ani_path_pos_list[i]
    ani_path:AddPathPoint(ani_path_pos.left, ani_path_pos.top)
  end
  ani_path:AddPathPointFinish()
  nx_bind_script(ani_path, nx_current())
  nx_callback(ani_path, "on_animation_end", "on_ani_path_end")
  if be_show then
    ani_path:Play()
  end
  return ani_path
end
function change_control(form, group_index)
  if is_need_recover then
    local jewel_game_manager = nx_value("jewel_game_manager")
    jewel_game_manager:CheckOperate(op_sysn)
  end
  nx_pause(0.5)
  if nx_is_valid(form) then
    create_diamond_select_effect(form, group_index)
    table.insert(change_control_show_lst, group_index)
    if not nx_find_custom(form, "delay_showing") or not form.delay_showing then
      local timer = nx_value("timer_game")
      if nx_is_valid(timer) then
        timer:Register(500, -1, nx_current(), "delay_show_change_control", form, -1, -1)
        form.delay_showing = true
      end
    end
  end
end
function delay_show_change_control(form)
  local gui = nx_value("gui")
  if is_game_over == false then
    create_diamond_start_effect(gui.Desktop.Width / 2 - 260, gui.Desktop.Width / 4, change_control_show_lst[1] == form.self_group)
  end
  table.remove(change_control_show_lst, 1)
  if table.getn(change_control_show_lst) == 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "delay_show_change_control", form)
      form.delay_showing = false
    end
  end
end
function play_sound(sound_name)
  local sound_file = diamond_sound_effect[sound_name]
  if sound_file == nil then
    return
  end
  local gui = nx_value("gui")
  if not gui:FindSound(sound_file) then
    gui:AddSound(sound_name, nx_resource_path() .. sound_file)
  end
  gui:PlayingSound(sound_name)
end
function play_music(sound_name)
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  nx_execute("util_functions", "play_music", scene, "scene", sound_name)
end
function stop_music()
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  local sound_man = scene.sound_man
  if not nx_is_valid(sound_man) then
    return
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local scene_music = client_scene:QueryProp("Resource")
  if sound_man.cur_music_name == scene_music then
    return
  end
  nx_execute("util_functions", "play_scene_random_music", scene, "scene", scene_music)
end
function create_custom_effect(...)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local jewel_game_manager = nx_value("jewel_game_manager")
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
    local cur_group, cur_index = get_cur_group_and_index(form)
    local cur_skill_index = form.cur_skill_index
    if form.cur_skill_effect_count == nil or form.cur_skill_effect_count <= 0 then
      return
    end
    local effect_id = nx_number(jewel_game_manager:GetGemeffect(form.cur_skill_name))
    local effect_type = get_game_custom_effect_type(effect_id)
    form.cur_skill_effect_count = form.cur_skill_effect_count - 1
    create_game_custom_effect(effect_id, effect_type, cur_group, form.cur_skill_index, unpack(arg))
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    if form.cur_skill_effect_count <= 0 then
      return
    end
    local effect_id = nx_number(jewel_game_manager:GetJMGemeffect(form.cur_skill_name))
    local effect_type = get_game_custom_effect_type(effect_id)
    form.cur_skill_effect_count = form.cur_skill_effect_count - 1
    create_game_custom_effect(effect_id, effect_type, 0, form.cur_skill_index, unpack(arg))
  end
end
function create_game_custom_effect(effect_id, effecttype, ...)
  nx_execute(nx_current(), "create_effect_" .. nx_string(effecttype), effect_id, unpack(arg))
end
local effect_param = {
  self_index = 1,
  skill_control_index = 2,
  diamond_index_begin = 3
}
function create_effect_1(effect_id, ...)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local skill_control
  local self_group = nx_number(arg[effect_param.self_index])
  local skill_index = nx_number(arg[effect_param.skill_control_index])
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
    local after_str_lst = {
      [0] = "a",
      [1] = "b"
    }
    local skill_control_name = "gb_skill" .. nx_string(skill_index) .. "_" .. after_str_lst[self_group]
    if not nx_find_custom(form.puzzle_page, skill_control_name) then
      return
    end
    skill_control = nx_custom(form.puzzle_page, skill_control_name)
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    local skill_control_name = ""
    if form.puzzle_page.select_skill_type == 1 then
      skill_control_name = "imagegrid_skill"
    elseif form.puzzle_page.select_skill_type == 2 then
      skill_control_name = "imagegrid_shortcut"
    elseif form.puzzle_page.select_skill_type == 3 then
      skill_control_name = "imagegrid_prize_skill"
    end
    if not nx_find_custom(form.puzzle_page, skill_control_name) then
      return
    end
    skill_control = nx_custom(form.puzzle_page, skill_control_name)
    skill_index = form.puzzle_page.select_skill_index
  end
  for i = effect_param.diamond_index_begin, table.getn(arg) do
    local ani_param = {}
    ani_param.AnimationImage = nx_string(effect_lst[nx_number(effect_id)].list.AnimationImage)
    ani_param.SmoothPath = nx_number(effect_lst[nx_number(effect_id)].list.SmoothPath) == 1
    ani_param.Loop = nx_number(effect_lst[nx_number(effect_id)].list.Loop) == 1
    ani_param.ClosePath = nx_number(effect_lst[nx_number(effect_id)].list.ClosePath) == 1
    ani_param.Color = gem_color[get_diamond_type(nx_number(arg[i].diamond_type))]
    ani_param.CreateMinInterval = nx_number(effect_lst[nx_number(effect_id)].list.CreateMinInterval)
    ani_param.CreateMaxInterval = nx_number(effect_lst[nx_number(effect_id)].list.CreateMaxInterval)
    ani_param.RotateSpeed = nx_number(effect_lst[nx_number(effect_id)].list.RotateSpeed)
    ani_param.BeginAlpha = nx_number(effect_lst[nx_number(effect_id)].list.BeginAlpha)
    ani_param.AlphaChangeSpeed = nx_number(effect_lst[nx_number(effect_id)].list.AlphaChangeSpeed)
    ani_param.BeginScale = nx_number(effect_lst[nx_number(effect_id)].list.BeginScale)
    ani_param.ScaleSpeed = nx_number(effect_lst[nx_number(effect_id)].list.ScaleSpeed)
    ani_param.MaxTime = nx_number(effect_lst[nx_number(effect_id)].list.MaxTime)
    ani_param.MaxWave = nx_number(effect_lst[nx_number(effect_id)].list.MaxWave)
    if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
      create_simple_effect(form, skill_control, arg[i], ani_param)
    elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
      if form.puzzle_page.select_skill_type == 1 or form.puzzle_page.select_skill_type == 3 then
        local skill_row_index = nx_int(skill_index / 2)
        local skill_col_index = math.mod(skill_index, 2)
        create_simple_effect(form, skill_control, arg[i], ani_param, skill_row_index, skill_col_index, 46, 46, 20, 0)
      elseif form.puzzle_page.select_skill_type == 2 then
        local skill_row_index = 0
        local skill_col_index = nx_int(skill_index)
        create_simple_effect(form, skill_control, arg[i], ani_param, skill_row_index, skill_col_index, 46, 46, 20, 0)
      end
    end
  end
end
function create_effect_2(effect_id, ...)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local skill_control
  local self_group = nx_number(arg[effect_param.self_index])
  local skill_index = nx_number(arg[effect_param.skill_control_index])
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
    local after_str_lst = {
      [0] = "a",
      [1] = "b"
    }
    local skill_control_name = "gb_skill" .. nx_string(skill_index) .. "_" .. after_str_lst[self_group]
    if not nx_find_custom(form.puzzle_page, skill_control_name) then
      return
    end
    skill_control = nx_custom(form.puzzle_page, skill_control_name)
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    local skill_control_name = ""
    if form.puzzle_page.select_skill_type == 1 then
      skill_control_name = "imagegrid_skill"
    elseif form.puzzle_page.select_skill_type == 2 then
      skill_control_name = "imagegrid_shortcut"
    elseif form.puzzle_page.select_skill_type == 3 then
      skill_control_name = "imagegrid_prize_skill"
    end
    if not nx_find_custom(form.puzzle_page, skill_control_name) then
      return
    end
    skill_control = nx_custom(form.puzzle_page, skill_control_name)
    skill_index = skill_control.select_index
  end
  local color = effect_lst[nx_number(effect_id)].list.color
  local form = nx_value(FORM_PUZZLE_QUEST)
  for i = effect_param.diamond_index_begin, table.getn(arg) do
    local ani_param = {}
    ani_param.AnimationImage = nx_string(effect_lst[nx_number(effect_id)].list.AnimationImage)
    ani_param.SmoothPath = nx_number(effect_lst[nx_number(effect_id)].list.SmoothPath) == 1
    ani_param.Loop = nx_number(effect_lst[nx_number(effect_id)].list.Loop) == 1
    ani_param.ClosePath = nx_number(effect_lst[nx_number(effect_id)].list.ClosePath) == 1
    ani_param.Color = color
    ani_param.CreateMinInterval = nx_number(effect_lst[nx_number(effect_id)].list.CreateMinInterval)
    ani_param.CreateMaxInterval = nx_number(effect_lst[nx_number(effect_id)].list.CreateMaxInterval)
    ani_param.RotateSpeed = nx_number(effect_lst[nx_number(effect_id)].list.RotateSpeed)
    ani_param.BeginAlpha = nx_number(effect_lst[nx_number(effect_id)].list.BeginAlpha)
    ani_param.AlphaChangeSpeed = nx_number(effect_lst[nx_number(effect_id)].list.AlphaChangeSpeed)
    ani_param.BeginScale = nx_number(effect_lst[nx_number(effect_id)].list.BeginScale)
    ani_param.ScaleSpeed = nx_number(effect_lst[nx_number(effect_id)].list.ScaleSpeed)
    ani_param.MaxTime = nx_number(effect_lst[nx_number(effect_id)].list.MaxTime)
    ani_param.MaxWave = nx_number(effect_lst[nx_number(effect_id)].list.MaxWave)
    if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
      create_simple_effect(form, skill_control, arg[i], ani_param)
    elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
      if form.puzzle_page.select_skill_type == 1 or form.puzzle_page.select_skill_type == 3 then
        local skill_row_index = nx_int(skill_index / 2)
        local skill_col_index = math.mod(skill_index, 2)
        create_simple_effect(form, skill_control, arg[i], ani_param, skill_row_index, skill_col_index, 46, 46, 20, 0)
      elseif form.puzzle_page.select_skill_type == 2 then
        local skill_row_index = 0
        local skill_col_index = nx_int(skill_index)
        create_simple_effect(form, skill_control, arg[i], ani_param, skill_row_index, skill_col_index, 46, 46, 20, 0)
      end
    end
  end
end
function create_effect_3(effect_id, ...)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local self_group = nx_number(arg[effect_param.self_index])
  local destcontrol_name = ""
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
    local after_str_lst = {
      [0] = "a",
      [1] = "b"
    }
    local effect_target = nx_number(effect_lst[nx_number(effect_id)].list.effecttarget)
    local after_str = ""
    if effect_target == 0 then
      after_str = after_str_lst[self_group]
    elseif effect_target == 1 then
      after_str = after_str_lst[1 - self_group]
    end
    destcontrol_name = nx_string(effect_lst[nx_number(effect_id)].list.destcontrol) .. "_" .. after_str
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    destcontrol_name = nx_string(effect_lst[nx_number(effect_id)].list.destcontrol)
  end
  if nx_find_custom(form.puzzle_page, destcontrol_name) then
    local destcontrol = nx_custom(form.puzzle_page, destcontrol_name)
    for i = effect_param.diamond_index_begin, table.getn(arg) do
      local ani_param = {}
      ani_param.AnimationImage = nx_string(effect_lst[nx_number(effect_id)].list.AnimationImage)
      ani_param.SmoothPath = nx_number(effect_lst[nx_number(effect_id)].list.SmoothPath) == 1
      ani_param.Loop = nx_number(effect_lst[nx_number(effect_id)].list.Loop) == 1
      ani_param.ClosePath = nx_number(effect_lst[nx_number(effect_id)].list.ClosePath) == 1
      ani_param.Color = gem_color[get_diamond_type(nx_number(arg[i].diamond_type))]
      ani_param.CreateMinInterval = nx_number(effect_lst[nx_number(effect_id)].list.CreateMinInterval)
      ani_param.CreateMaxInterval = nx_number(effect_lst[nx_number(effect_id)].list.CreateMaxInterval)
      ani_param.RotateSpeed = nx_number(effect_lst[nx_number(effect_id)].list.RotateSpeed)
      ani_param.BeginAlpha = nx_number(effect_lst[nx_number(effect_id)].list.BeginAlpha)
      ani_param.AlphaChangeSpeed = nx_number(effect_lst[nx_number(effect_id)].list.AlphaChangeSpeed)
      ani_param.BeginScale = nx_number(effect_lst[nx_number(effect_id)].list.BeginScale)
      ani_param.ScaleSpeed = nx_number(effect_lst[nx_number(effect_id)].list.ScaleSpeed)
      ani_param.MaxTime = nx_number(effect_lst[nx_number(effect_id)].list.MaxTime)
      ani_param.MaxWave = nx_number(effect_lst[nx_number(effect_id)].list.MaxWave)
      create_simple_effect(form, arg[i], destcontrol, ani_param)
    end
  end
end
function create_effect_4(effect_id, ...)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local self_group = nx_number(arg[effect_param.self_index])
  local skill_index = nx_number(arg[effect_param.skill_control_index])
  local skill_control
  local destcontrol_name = ""
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
    local after_str_lst = {
      [0] = "a",
      [1] = "b"
    }
    local skill_control_name = "gb_skill" .. nx_string(skill_index) .. "_" .. after_str_lst[self_group]
    if not nx_find_custom(form.puzzle_page, skill_control_name) then
      return
    end
    skill_control = nx_custom(form.puzzle_page, skill_control_name)
    local effect_target = nx_number(effect_lst[nx_number(effect_id)].list.effecttarget)
    local color = nx_number(effect_lst[nx_number(effect_id)].list.color)
    local after_str = ""
    if effect_target == 0 then
      after_str = after_str_lst[self_group]
    elseif effect_target == 1 then
      after_str = after_str_lst[1 - self_group]
    end
    destcontrol_name = nx_string(effect_lst[nx_number(effect_id)].list.destcontrol) .. "_" .. after_str
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    local skill_control_name = ""
    if form.puzzle_page.select_skill_type == 1 then
      skill_control_name = "imagegrid_skill"
    elseif form.puzzle_page.select_skill_type == 2 then
      skill_control_name = "imagegrid_shortcut"
    elseif form.puzzle_page.select_skill_type == 3 then
      skill_control_name = "imagegrid_prize_skill"
    end
    if not nx_find_custom(form.puzzle_page, skill_control_name) then
      return
    end
    skill_control = nx_custom(form.puzzle_page, skill_control_name)
    skill_index = skill_control.select_index
    destcontrol_name = nx_string(effect_lst[nx_number(effect_id)].list.destcontrol)
  end
  if nx_find_custom(form.puzzle_page, destcontrol_name) then
    local destcontrol = nx_custom(form.puzzle_page, destcontrol_name)
    local ani_param = {}
    ani_param.AnimationImage = nx_string(effect_lst[nx_number(effect_id)].list.AnimationImage)
    ani_param.SmoothPath = nx_number(effect_lst[nx_number(effect_id)].list.SmoothPath) == 1
    ani_param.Loop = nx_number(effect_lst[nx_number(effect_id)].list.Loop) == 1
    ani_param.ClosePath = nx_number(effect_lst[nx_number(effect_id)].list.ClosePath) == 1
    ani_param.Color = color
    ani_param.CreateMinInterval = nx_number(effect_lst[nx_number(effect_id)].list.CreateMinInterval)
    ani_param.CreateMaxInterval = nx_number(effect_lst[nx_number(effect_id)].list.CreateMaxInterval)
    ani_param.RotateSpeed = nx_number(effect_lst[nx_number(effect_id)].list.RotateSpeed)
    ani_param.BeginAlpha = nx_number(effect_lst[nx_number(effect_id)].list.BeginAlpha)
    ani_param.AlphaChangeSpeed = nx_number(effect_lst[nx_number(effect_id)].list.AlphaChangeSpeed)
    ani_param.BeginScale = nx_number(effect_lst[nx_number(effect_id)].list.BeginScale)
    ani_param.ScaleSpeed = nx_number(effect_lst[nx_number(effect_id)].list.ScaleSpeed)
    ani_param.MaxTime = nx_number(effect_lst[nx_number(effect_id)].list.MaxTime)
    ani_param.MaxWave = nx_number(effect_lst[nx_number(effect_id)].list.MaxWave)
    if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
      create_simple_effect(form, skill_control, destcontrol, ani_param)
    elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
      if form.puzzle_page.select_skill_type == 1 or form.puzzle_page.select_skill_type == 3 then
        local skill_row_index = nx_int(skill_index / 2)
        local skill_col_index = math.mod(skill_index, 2)
        create_simple_effect(form, skill_control, arg[i], ani_param, skill_row_index, skill_col_index, 46, 46, 20, 0)
      elseif form.puzzle_page.select_skill_type == 2 then
        local skill_row_index = 0
        local skill_col_index = nx_int(skill_index)
        create_simple_effect(form, skill_control, arg[i], ani_param, skill_row_index, skill_col_index, 46, 46, 20, 0)
      end
    end
  end
end
function create_effect_5(effect_id, ...)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local self_group = nx_number(arg[effect_param.self_index])
  local photo = nx_string(effect_lst[nx_number(effect_id)].list.photo)
  local destcontrol_name = nx_string(effect_lst[nx_number(effect_id)].list.destcontrol)
  local posx = nx_number(effect_lst[nx_number(effect_id)].list.offset_x)
  local posy = nx_number(effect_lst[nx_number(effect_id)].list.offset_y)
  local width = nx_number(effect_lst[nx_number(effect_id)].list.width)
  local height = nx_number(effect_lst[nx_number(effect_id)].list.height)
  local effect_time = nx_float(effect_lst[nx_number(effect_id)].list.effecttime)
  local effect_target = nx_number(effect_lst[nx_number(effect_id)].list.effecttarget)
  local control
  if destcontrol_name == "" then
    control = form.puzzle_page
  elseif form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
    local after_str_lst = {
      [0] = "a",
      [1] = "b"
    }
    local after_str = ""
    if effect_target == 0 then
      after_str = after_str_lst[self_group]
    elseif effect_target == 1 then
      after_str = after_str_lst[1 - self_group]
    end
    if nx_find_custom(form.puzzle_page, destcontrol_name .. "_" .. after_str) then
      control = nx_custom(form.puzzle_page, destcontrol_name .. "_" .. after_str)
    end
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai and nx_find_custom(form.puzzle_page, destcontrol_name) then
    control = nx_custom(form.puzzle_page, destcontrol_name)
  end
  if control == nil then
    return
  end
  local gui = nx_value("gui")
  local effect_img = form:Find("effect_img")
  if not nx_is_valid(effect_img) then
    effect_img = gui:Create("Label")
    form:Add(effect_img)
  end
  form:ToFront(effect_img)
  effect_img.BackImage = photo
  effect_img.Width = width
  effect_img.Height = height
  effect_img.Left = posx + control.AbsLeft
  effect_img.Top = posy + control.AbsTop
  effect_img.DrawMode = "FitWindow"
  effect_img.Name = "effect_img"
  effect_img.Visible = true
  nx_pause(effect_time / 1000)
  if nx_is_valid(effect_img) then
    effect_img.Visible = false
  end
end
function create_effect_6(effect_id, ...)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local self_group = nx_number(arg[effect_param.self_index])
  local destcontrol_name = nx_string(effect_lst[nx_number(effect_id)].destcontrol)
  local control
  if destcontrol_name == "" then
    control = form.puzzle_page
  elseif form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
    local effect_target = nx_number(effect_lst[nx_number(effect_id)].effecttarget)
    local after_str_lst = {
      [0] = "a",
      [1] = "b"
    }
    local after_str = ""
    if effect_target == 0 then
      after_str = after_str_lst[self_group]
    elseif effect_target == 1 then
      after_str = after_str_lst[1 - self_group]
    end
    if nx_find_custom(form.puzzle_page, destcontrol_name .. "_" .. after_str) then
      control = nx_custom(form.puzzle_page, destcontrol_name .. "_" .. after_str)
    end
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai and nx_find_custom(form.puzzle_page, destcontrol_name) then
    control = nx_custom(form.puzzle_page, destcontrol_name)
  end
  if control == nil then
    return
  end
  for i = 1, table.getn(effect_lst[nx_number(effect_id)].list) do
    local lst = effect_lst[nx_number(effect_id)].list[i]
    local color = effect_lst[nx_number(effect_id)].color
    local ani_list = {}
    for j = 1, table.getn(lst) do
      local line_info = lst[j]
      ani_list[j] = {left = 0, top = 0}
      ani_list[j].left = nx_number(line_info.posx) + control.AbsLeft + effect_lst[nx_number(effect_id)].offset_x
      ani_list[j].top = nx_number(line_info.posy) + control.AbsTop + effect_lst[nx_number(effect_id)].offset_y
    end
    local ani_param = {}
    ani_param.AnimationImage = nx_string(effect_lst[nx_number(effect_id)].AnimationImage)
    ani_param.SmoothPath = nx_number(effect_lst[nx_number(effect_id)].SmoothPath) == 1
    ani_param.Loop = nx_number(effect_lst[nx_number(effect_id)].Loop) == 1
    ani_param.ClosePath = nx_number(effect_lst[nx_number(effect_id)].ClosePath) == 1
    ani_param.Color = nx_string(color)
    ani_param.CreateMinInterval = nx_number(effect_lst[nx_number(effect_id)].CreateMinInterval)
    ani_param.CreateMaxInterval = nx_number(effect_lst[nx_number(effect_id)].CreateMaxInterval)
    ani_param.RotateSpeed = nx_number(effect_lst[nx_number(effect_id)].RotateSpeed)
    ani_param.BeginAlpha = nx_number(effect_lst[nx_number(effect_id)].BeginAlpha)
    ani_param.AlphaChangeSpeed = nx_number(effect_lst[nx_number(effect_id)].AlphaChangeSpeed)
    ani_param.BeginScale = nx_number(effect_lst[nx_number(effect_id)].BeginScale)
    ani_param.ScaleSpeed = nx_number(effect_lst[nx_number(effect_id)].ScaleSpeed)
    ani_param.MaxTime = nx_number(effect_lst[nx_number(effect_id)].MaxTime)
    ani_param.MaxWave = nx_number(effect_lst[nx_number(effect_id)].MaxWave)
    create_fuwen_effect(form, ani_list, ani_param)
  end
end
function create_effect_7(effect_id, ...)
  local form = nx_value(FORM_PUZZLE_QUEST)
  if nx_number(effect_lst[nx_number(effect_id)].counttype) == 1 then
    local index = effect_lst[nx_number(effect_id)].subeffectcount - form.cur_skill_effect_count
    local one_effect_info = effect_lst[nx_number(effect_id)].list[index]
    local subeffect_id = nx_number(one_effect_info.subeffect)
    local subeffecttime = nx_float(one_effect_info.subeffecttime)
    local effect_type = get_game_custom_effect_type(subeffect_id)
    create_game_custom_effect(subeffect_id, effect_type, unpack(arg))
  else
    for i = 1, table.getn(effect_lst[nx_number(effect_id)].list) do
      local one_effect_info = effect_lst[nx_number(effect_id)].list[i]
      local subeffect_id = nx_number(one_effect_info.subeffect)
      local subeffecttime = nx_float(one_effect_info.subeffecttime)
      local effect_type = get_game_custom_effect_type(subeffect_id)
      create_game_custom_effect(subeffect_id, effect_type, unpack(arg))
      nx_pause(subeffecttime / 1000)
      if not nx_is_valid(form) then
        return
      end
    end
  end
end
function create_effect_8(effect_id, ...)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local self_group = nx_number(arg[effect_param.self_index])
  local srccontrol_name = ""
  local destcontrol_name = ""
  if form.gem_game_type == gem_game_type.gt_caifeng or form.gem_game_type == gem_game_type.gt_tiejiang or form.gem_game_type == gem_game_type.gt_qiaojiang or form.gem_game_type == gem_game_type.gt_dushi or form.gem_game_type == gem_game_type.gt_yaoshi or form.gem_game_type == gem_game_type.gt_chushi then
    local after_str_lst = {
      [0] = "a",
      [1] = "b"
    }
    local effectsrctarget = nx_number(effect_lst[nx_number(effect_id)].list.effectsrctarget)
    local effectdesttarget = nx_number(effect_lst[nx_number(effect_id)].list.effectdesttarget)
    local color = nx_string(effect_lst[nx_number(effect_id)].list.color)
    local src_after_str = ""
    if effectsrctarget == 0 then
      src_after_str = after_str_lst[self_group]
    elseif effectsrctarget == 1 then
      src_after_str = after_str_lst[1 - self_group]
    end
    local dest_after_str = ""
    if effectdesttarget == 0 then
      dest_after_str = after_str_lst[self_group]
    elseif effectdesttarget == 1 then
      dest_after_str = after_str_lst[1 - self_group]
    end
    srccontrol_name = nx_string(effect_lst[nx_number(effect_id)].list.srccontrol) .. "_" .. src_after_str
    destcontrol_name = nx_string(effect_lst[nx_number(effect_id)].list.destcontrol) .. "_" .. dest_after_str
  elseif form.gem_game_type == gem_game_type.gt_datongjingmai then
    srccontrol_name = nx_string(effect_lst[nx_number(effect_id)].list.srccontrol)
    destcontrol_name = nx_string(effect_lst[nx_number(effect_id)].list.destcontrol)
  end
  if nx_find_custom(form.puzzle_page, srccontrol_name) and nx_find_custom(form.puzzle_page, destcontrol_name) then
    local srccontrol = nx_custom(form.puzzle_page, srccontrol_name)
    local destcontrol = nx_custom(form.puzzle_page, destcontrol_name)
    local ani_param = {}
    ani_param.AnimationImage = nx_string(effect_lst[nx_number(effect_id)].list.AnimationImage)
    ani_param.SmoothPath = nx_number(effect_lst[nx_number(effect_id)].list.SmoothPath) == 1
    ani_param.Loop = nx_number(effect_lst[nx_number(effect_id)].list.Loop) == 1
    ani_param.ClosePath = nx_number(effect_lst[nx_number(effect_id)].list.ClosePath) == 1
    ani_param.Color = nx_string(color)
    ani_param.CreateMinInterval = nx_number(effect_lst[nx_number(effect_id)].list.CreateMinInterval)
    ani_param.CreateMaxInterval = nx_number(effect_lst[nx_number(effect_id)].list.CreateMaxInterval)
    ani_param.RotateSpeed = nx_number(effect_lst[nx_number(effect_id)].list.RotateSpeed)
    ani_param.BeginAlpha = nx_number(effect_lst[nx_number(effect_id)].list.BeginAlpha)
    ani_param.AlphaChangeSpeed = nx_number(effect_lst[nx_number(effect_id)].list.AlphaChangeSpeed)
    ani_param.BeginScale = nx_number(effect_lst[nx_number(effect_id)].list.BeginScale)
    ani_param.ScaleSpeed = nx_number(effect_lst[nx_number(effect_id)].list.ScaleSpeed)
    ani_param.MaxTime = nx_number(effect_lst[nx_number(effect_id)].list.MaxTime)
    ani_param.MaxWave = nx_number(effect_lst[nx_number(effect_id)].list.MaxWave)
    create_simple_effect(form, srccontrol, destcontrol, ani_param)
  end
end
function create_fuwen_effect(form, ani_list, ani_param)
  return create_path_ani(form, ani_list, ani_param, true)
end
function create_simple_effect(form, src_control, dest_control, ani_param, offset_y_index, offset_x_index, offset_width, offset_height, offset_x, offset_y)
  local ani_path_pos_list = {}
  if offset_x_index ~= nil then
    ani_path_pos_list[1] = {left = 0, top = 0}
    ani_path_pos_list[1].left = src_control.AbsLeft + offset_x_index * offset_width + offset_width / 2 + offset_x
    ani_path_pos_list[1].top = src_control.AbsTop + offset_y_index * offset_height + offset_height / 2 + offset_y
    ani_path_pos_list[3] = {left = 0, top = 0}
    ani_path_pos_list[3].left = dest_control.AbsLeft + dest_control.Width / 2
    ani_path_pos_list[3].top = dest_control.AbsTop + dest_control.Height / 2
    ani_path_pos_list[2] = {left = 0, top = 0}
    ani_path_pos_list[2].left = math.random(math.min(ani_path_pos_list[1].left, ani_path_pos_list[3].left), math.max(ani_path_pos_list[1].left, ani_path_pos_list[3].left))
    ani_path_pos_list[2].top = math.random(math.min(ani_path_pos_list[1].top, ani_path_pos_list[3].top), math.max(ani_path_pos_list[1].top, ani_path_pos_list[3].top))
    return create_path_ani(form, ani_path_pos_list, ani_param, true)
  else
    ani_path_pos_list[1] = {left = 0, top = 0}
    ani_path_pos_list[1].left = src_control.AbsLeft + src_control.Width / 2
    ani_path_pos_list[1].top = src_control.AbsTop + src_control.Height / 2
    ani_path_pos_list[3] = {left = 0, top = 0}
    ani_path_pos_list[3].left = dest_control.AbsLeft + dest_control.Width / 2
    ani_path_pos_list[3].top = dest_control.AbsTop + dest_control.Height / 2
    ani_path_pos_list[2] = {left = 0, top = 0}
    ani_path_pos_list[2].left = math.random(math.min(ani_path_pos_list[1].left, ani_path_pos_list[3].left), math.max(ani_path_pos_list[1].left, ani_path_pos_list[3].left))
    ani_path_pos_list[2].top = math.random(math.min(ani_path_pos_list[1].top, ani_path_pos_list[3].top), math.max(ani_path_pos_list[1].top, ani_path_pos_list[3].top))
    return create_path_ani(form, ani_path_pos_list, ani_param, true)
  end
end
function auto_show_hide_alpha_in_out(formname)
  local form = util_get_form(formname, true)
  if not nx_is_valid(form) then
    return 0
  end
  if form.Visible then
    util_form_alpha_out(formname, 1)
  else
    form.Visible = true
    util_form_alpha_in(formname, 1)
  end
end
function specialform_alpha_out(formname, keeptime, instance_id)
  local form = util_get_form(formname, false, false, instance_id)
  if not nx_is_valid(form) then
    return 0
  end
  local old_alpha = form.BlendAlpha
  local timecount = 0
  while true do
    timecount = timecount + nx_pause(0)
    if not nx_is_valid(form) then
      break
    end
    if keeptime > timecount then
      if nx_is_valid(form) then
        form.BlendAlpha = old_alpha - old_alpha * timecount / keeptime
      end
    else
      if nx_is_valid(form) then
        form.BlendAlpha = 255
        form.Visible = false
        form:Close()
      end
      break
    end
  end
end
function show_world_alpha_out()
  local world = nx_value("world")
  local scene = world.MainScene
  scene.terrain.WaterVisible = true
  scene.terrain.GroundVisible = true
  scene.terrain.VisualVisible = true
  scene.terrain.HelperVisible = true
  local gui = nx_value("gui")
  gui.ScaleRatio = temp_scale
  gui.Desktop.Width = gui.Width
  gui.Desktop.Height = gui.Height
  specialform_alpha_out(FORM_PUZZLE_QUEST, 1.5)
end
function get_current_form_name()
  return current_form_name
end
function show_exit_effect(form, type)
  local gui = nx_value("gui")
  if type then
    if game_type ~= 2 then
      create_img_ani("win", gui.Desktop.Width / 2 - 868, gui.Desktop.Height / 5)
    else
      create_img_ani("puzzle_win", gui.Desktop.Width / 2 - 258, gui.Desktop.Height / 5)
    end
    play_sound("win")
    nx_pause(2)
    if nx_is_valid(form) then
      show_world_alpha_out()
    end
  else
    if game_type ~= 2 then
      create_img_ani("lose", gui.Desktop.Width / 2 - 868, gui.Desktop.Height / 5)
    else
      create_img_ani("puzzle_lose", gui.Desktop.Width / 2 - 258, gui.Desktop.Height / 5)
    end
    play_sound("lose")
    nx_pause(2)
    if nx_is_valid(form) then
      show_world_alpha_out()
    end
  end
end
function close_form()
  local form = nx_value("form_stage_main\\puzzle_quest\\form_puzzle_quest")
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function get_diamond_count(first_type, second_type, third_type)
  local first_count = 0
  local second_count = 0
  local third_count = 0
  for i = 1, table.getn(data_lst) do
    if get_diamond_type(data_lst[i]) == first_type then
      first_count = first_count + 1
    end
    if get_diamond_type(data_lst[i]) == second_type then
      second_count = second_count + 1
    end
    if get_diamond_type(data_lst[i]) == third_type then
      third_count = third_count + 1
    end
  end
  return first_count, second_count, third_count
end
function add_prize(...)
  local form = nx_value("form_stage_main\\puzzle_quest\\form_puzzle_quest")
  if nx_is_valid(form) and nx_find_custom(form, "gem_game_type") then
    if form.gem_game_type == gem_game_type.gt_gemegggame then
      nx_execute("form_stage_main\\puzzle_quest\\form_smahing_egg", "add_prize", unpack(arg))
    elseif form.gem_game_type == gem_game_type.gt_gemtaskegggame then
      nx_execute("form_stage_main\\puzzle_quest\\form_smahing_yhg", "add_prize", unpack(arg))
    end
  end
end
