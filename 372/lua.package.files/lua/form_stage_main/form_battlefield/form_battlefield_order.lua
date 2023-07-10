require("util_gui")
require("util_functions")
local FORM_BATTLEFIELD_ORDER = "form_stage_main\\form_battlefield\\form_battlefield_order"
local EVERYTIME_MSG_COUNT = 16
local BATTLEFIELD_ORDER_ARRAY_INFO = "battlefield_order_array"
local SIDE_UNKNOWN = 0
local SIDE_NORMAL = 1
local SIDE_BOSS = 2
local SIDE_WHITE = 3
local SIDE_BLACK = 4
local PLAY_WAY_NONE = 0
local PLAY_WAY_SHADI = 1
local PLAY_WAY_ZHANLING = 2
local PLAY_WAY_DUOQI = 3
local PLAY_WAY_DEADTH = 10
local BF_RESULT_UNKNOWN = 0
local BF_RESULT_DOGFALL = 1
local BF_RESULT_SUCCEED = 2
local BF_RESULT_FAILED = 3
local BF_RESULT_ESCAPE = 4
local BF_RESULT_SUCCEED_FULLY = 5
local BF_RESULT_SUCCEED_LARGE = 6
local BF_RESULT_SUCCEED_LESS = 7
local BF_RESULT_FAILED_FULLY = 8
local BF_RESULT_FAILED_LARGE = 9
local BF_RESULT_FAILED_LESS = 10
local grid_order_data = {}
local bf_order_head_name = {
  "ui_guildwar_order_mingci",
  "ui_guildwar_order_xingming",
  "ui_menpai",
  "ui_battle_getpoint",
  "ui_battle_killenemy",
  "ui_battle_maxkill",
  "ui_battle_dead",
  "ui_battle_grapbanner",
  "ui_battle_retbanner",
  "ui_battle_killboss2",
  "ui_battle_getmoney",
  "ui_battle_help",
  "ui_battle_damage"
}
local battlefield_school_pic = {
  [""] = "gui\\language\\ChineseS\\shengwang\\wmp.png",
  school_shaolin = "gui\\language\\ChineseS\\shengwang\\sl.png",
  school_wudang = "gui\\language\\ChineseS\\shengwang\\wd.png",
  school_gaibang = "gui\\language\\ChineseS\\shengwang\\gb.png",
  school_tangmen = "gui\\language\\ChineseS\\shengwang\\tm.png",
  school_emei = "gui\\language\\ChineseS\\shengwang\\em.png",
  school_jinyiwei = "gui\\language\\ChineseS\\shengwang\\jy.png",
  school_jilegu = "gui\\language\\ChineseS\\shengwang\\jl.png",
  school_junzitang = "gui\\language\\ChineseS\\shengwang\\jz.png",
  school_mingjiao = "gui\\language\\ChineseS\\shengwang\\mj.png",
  school_tianshan = "gui\\language\\ChineseS\\shengwang\\ts.png",
  force_jinzhen = "gui\\special\\forceschool\\shililogo\\jinzhen02.png",
  force_taohua = "gui\\special\\forceschool\\shililogo\\taohua02.png",
  force_wanshou = "gui\\special\\forceschool\\shililogo\\wanshou02.png",
  force_wugen = "gui\\special\\forceschool\\shililogo\\wugen02.png",
  force_xujia = "gui\\special\\forceschool\\shililogo\\xujia02.png",
  force_yihua = "gui\\special\\forceschool\\shililogo\\yihua02.png"
}
function main_form_init(self)
  self.self_side = SIDE_UNKNOWN
  self.other_side = SIDE_UNKNOWN
  self.have_score = false
  self.play_way = PLAY_WAY_NONE
  self.Fixed = false
  local client = nx_value("game_client")
  local client_role = client:GetPlayer()
  if not nx_is_valid(client_role) then
    return
  end
  if not client_role:FindProp("Name") then
    return
  end
  local player_name = nx_widestr(client_role:QueryProp("Name"))
  self.self_name = player_name
  self.show_win = 0
end
function on_main_form_open(self)
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  hide_effect(self)
  local grid = self.textgrid_battle_order
  if not nx_is_valid(grid) then
    return
  end
  gui.TextManager:GetText("ui_battle_killenemy")
  grid:ClearRow()
  self.btn_exit_bf.Visible = false
  self.ani_connect.Visible = true
  self.ani_connect.PlayMode = 2
  self.lbl_connect.Visible = true
  return 1
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
  return
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
end
function on_rbtn_side1_checked_changed(self)
  if self.Checked then
    local form = self.Parent
    refresh_battlefield_order_grid(form.textgrid_battle_order, form.self_side)
  end
end
function on_rbtn_side2_checked_changed(self)
  if self.Checked then
    local form = self.Parent
    refresh_battlefield_order_grid(form.textgrid_battle_order, form.other_side)
  end
end
function show_effect(form, isWinner)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_win_text.Visible = isWinner == 1
  form.lbl_lose_text.Visible = isWinner == 2
  form.lbl_succeed_fully.Visible = isWinner == 3
  form.lbl_succeed_large.Visible = isWinner == 4
  form.lbl_succeed_less.Visible = isWinner == 5
  form.lbl_failed_fully.Visible = isWinner == 6
  form.lbl_failed_large.Visible = isWinner == 7
  form.lbl_failed_less.Visible = isWinner == 8
end
function hide_effect(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_win_text.Visible = false
  form.lbl_lose_text.Visible = false
  form.lbl_succeed_fully.Visible = false
  form.lbl_succeed_large.Visible = false
  form.lbl_succeed_less.Visible = false
  form.lbl_failed_fully.Visible = false
  form.lbl_failed_large.Visible = false
  form.lbl_failed_less.Visible = false
end
function update_battlefield_order(have_score, ...)
  local form
  local client = nx_value("game_client")
  local client_role = client:GetPlayer()
  if not nx_is_valid(client_role) then
    return
  end
  if not client_role:FindProp("Name") then
    return
  end
  if have_score then
    form = util_get_form(FORM_BATTLEFIELD_ORDER, true)
    form.have_score = true
  else
    form = util_get_form(FORM_BATTLEFIELD_ORDER, false)
  end
  if not nx_is_valid(form) then
    return
  end
  local param_count = table.getn(arg)
  if param_count < 5 then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local timeS = arg[1]
  local allMsgCount = arg[2]
  local thisMsg = arg[3]
  local play_way = arg[4]
  if thisMsg == 1 then
    for i = 1, 48 do
      local array_name = BATTLEFIELD_ORDER_ARRAY_INFO .. nx_string(i)
      common_array:RemoveArray(array_name)
    end
    form.rbtn_side1.Visible = false
    form.rbtn_side2.Visible = false
    form.play_way = play_way
    if have_score then
      form.time_stamp = timeS
    end
  end
  if not nx_find_custom(form, "time_stamp") then
    return
  end
  if timeS ~= form.time_stamp then
    return
  end
  for i = 0, EVERYTIME_MSG_COUNT - 1 do
    local msg_index = 4 + i * 12
    if have_score then
      msg_index = 4 + i * 15
    end
    if param_count <= msg_index then
      break
    end
    local array_name = BATTLEFIELD_ORDER_ARRAY_INFO .. nx_string((thisMsg - 1) * EVERYTIME_MSG_COUNT + i + 1)
    common_array:AddArray(array_name, form, 600, true)
    common_array:AddChild(array_name, "b_order_player_name", nx_widestr(arg[msg_index + 1]))
    common_array:AddChild(array_name, "b_order_side", nx_int(arg[msg_index + 2]))
    if not nx_find_custom(form, "self_name") then
      local player_name = nx_widestr(client_role:QueryProp("Name"))
      form.self_name = player_name
    end
    if form.self_name == nx_widestr(arg[msg_index + 1]) then
      form.self_side = nx_int(arg[msg_index + 2])
      if have_score and (SIDE_WHITE == form.self_side or SIDE_BLACK == form.self_side) then
        local result = arg[msg_index + 12]
        if BF_RESULT_SUCCEED == result then
          form.show_win = 1
        elseif BF_RESULT_FAILED == result then
          form.show_win = 2
        elseif BF_RESULT_SUCCEED_FULLY == result then
          form.show_win = 3
        elseif BF_RESULT_SUCCEED_LARGE == result then
          form.show_win = 4
        elseif BF_RESULT_SUCCEED_LESS == result then
          form.show_win = 5
        elseif BF_RESULT_FAILED_FULLY == result then
          form.show_win = 6
        elseif BF_RESULT_FAILED_LARGE == result then
          form.show_win = 7
        elseif BF_RESULT_FAILED_LESS == result then
          form.show_win = 8
        end
      end
    end
    common_array:AddChild(array_name, "b_order_kill_count", nx_int(arg[msg_index + 3]))
    common_array:AddChild(array_name, "b_order_dead_count", nx_int(arg[msg_index + 4]))
    common_array:AddChild(array_name, "b_order_boss_count", nx_int(arg[msg_index + 5]))
    common_array:AddChild(array_name, "b_order_queue_kill", nx_int(arg[msg_index + 6]))
    common_array:AddChild(array_name, "b_order_grap_banner", nx_int(arg[msg_index + 7]))
    common_array:AddChild(array_name, "b_order_ret_banner", nx_int(arg[msg_index + 8]))
    common_array:AddChild(array_name, "b_order_school", nx_string(arg[msg_index + 9]))
    common_array:AddChild(array_name, "b_order_help_kill", nx_string(arg[msg_index + 10]))
    if have_score then
      common_array:AddChild(array_name, "b_order_score", nx_int(arg[msg_index + 11]))
      common_array:AddChild(array_name, "b_order_money", nx_int(arg[msg_index + 13]))
      common_array:AddChild(array_name, "b_order_batdamage", nx_int(arg[msg_index + 14]))
      common_array:AddChild(array_name, "b_order_eliminated", nx_int(arg[msg_index + 15]))
    else
      common_array:AddChild(array_name, "b_order_batdamage", nx_string(arg[msg_index + 11]))
      common_array:AddChild(array_name, "b_order_eliminated", nx_int(arg[msg_index + 12]))
    end
  end
  local gui = nx_value("gui")
  if form.self_side ~= SIDE_UNKNOWN then
    if SIDE_NORMAL == form.self_side or SIDE_BOSS == form.self_side then
      form.other_side = 3 - form.self_side
      form.rbtn_side1.Visible = true
      form.rbtn_side1.Text = gui.TextManager:GetText("ui_battle_ranking")
      form.rbtn_side1.Checked = true
      form.rbtn_side1.Enable = false
      form.rbtn_side2.Visible = false
    elseif SIDE_WHITE == form.self_side or SIDE_BLACK == form.self_side then
      form.other_side = 7 - form.self_side
      form.rbtn_side1.Visible = true
      form.rbtn_side2.Visible = true
      form.rbtn_side1.Text = gui.TextManager:GetText("ui_battle_friend")
      form.rbtn_side2.Text = gui.TextManager:GetText("ui_battle_enemy")
      form.rbtn_side1.Checked = true
    else
      form.self_side = SIDE_UNKNOWN
      form.other_side = SIDE_UNKNOWN
      form.rbtn_side1.Visible = false
      form.rbtn_side2.Visible = false
    end
  end
  if allMsgCount == thisMsg then
    InitGridCol(form)
    form.Visible = true
    form:Show()
    form.ani_connect.Visible = false
    form.ani_connect.PlayMode = 0
    form.lbl_connect.Visible = false
    if form.have_score then
      form.btn_exit_bf.Visible = true
      show_effect(form, form.show_win)
    end
    refresh_battlefield_order_grid(form.textgrid_battle_order, form.self_side)
  end
end
function refresh_battlefield_order_grid(grid, battle_side)
  if not nx_is_valid(grid) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local gui = nx_value("gui")
  grid_order_data = {}
  sort_bf_info_array(form.have_score)
  grid:ClearRow()
  grid:ClearSelect()
  local rank = 1
  local HIGH_LIGHT_COLOR = "255,255,0,0"
  for i = 1, table.getn(grid_order_data) do
    local is_add_row = true
    local is_show_name = false
    local array_name = grid_order_data[i]
    if battle_side == SIDE_WHITE or battle_side == SIDE_BLACK then
      if battle_side ~= common_array:FindChild(nx_string(array_name), "b_order_side") then
        is_add_row = false
      end
      if battle_side == form.self_side then
        is_show_name = true
      end
    end
    if is_add_row then
      local row = grid:InsertRow(-1)
      local player_name = common_array:FindChild(nx_string(array_name), "b_order_player_name")
      if not form.have_score and not is_show_name and form.self_name ~= player_name then
        player_name = gui.TextManager:GetText("ui_battle_name")
      end
      if form.self_name == player_name then
        for i = 0, grid.ColCount - 1 do
          grid:SetGridForeColor(row, i, HIGH_LIGHT_COLOR)
        end
      end
      grid:SetGridText(row, 0, nx_widestr(rank))
      grid:SetGridText(row, 1, player_name)
      create_battlefield_grid_control(form, row, 2, common_array:FindChild(nx_string(array_name), "b_order_school"))
      if form.have_score then
        grid:SetGridText(row, 3, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_score")))
        grid:SetGridText(row, 4, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_kill_count")))
        grid:SetGridText(row, 5, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_batdamage")))
        grid:SetGridText(row, 6, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_queue_kill")))
        if SIDE_WHITE == form.self_side or SIDE_BLACK == form.self_side then
          grid:SetGridText(row, 7, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_help_kill")))
          if form.play_way == PLAY_WAY_DUOQI then
            grid:SetGridText(row, 8, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_grap_banner")))
            grid:SetGridText(row, 9, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_ret_banner")))
            grid:SetGridText(row, 10, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_dead_count")))
            grid:SetGridText(row, 11, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_money")))
            create_battlefield_eliminate_button(form, row, 12, player_name, common_array:FindChild(nx_string(array_name), "b_order_eliminated"))
          else
            grid:SetGridText(row, 8, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_dead_count")))
            grid:SetGridText(row, 9, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_money")))
            create_battlefield_eliminate_button(form, row, 10, player_name, common_array:FindChild(nx_string(array_name), "b_order_eliminated"))
          end
        else
          grid:SetGridText(row, 7, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_boss_count")))
          grid:SetGridText(row, 8, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_dead_count")))
          grid:SetGridText(row, 9, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_money")))
        end
      else
        grid:SetGridText(row, 3, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_kill_count")))
        grid:SetGridText(row, 4, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_batdamage")))
        grid:SetGridText(row, 5, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_queue_kill")))
        if SIDE_WHITE == form.self_side or SIDE_BLACK == form.self_side then
          grid:SetGridText(row, 6, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_help_kill")))
          if form.play_way == PLAY_WAY_DUOQI then
            grid:SetGridText(row, 7, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_grap_banner")))
            grid:SetGridText(row, 8, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_ret_banner")))
            grid:SetGridText(row, 9, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_dead_count")))
            create_battlefield_eliminate_button(form, row, 10, player_name, common_array:FindChild(nx_string(array_name), "b_order_eliminated"))
          else
            grid:SetGridText(row, 7, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_dead_count")))
            create_battlefield_eliminate_button(form, row, 8, player_name, common_array:FindChild(nx_string(array_name), "b_order_eliminated"))
          end
        else
          grid:SetGridText(row, 6, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_boss_count")))
          grid:SetGridText(row, 7, nx_widestr(common_array:FindChild(nx_string(array_name), "b_order_dead_count")))
        end
      end
      rank = rank + 1
    end
  end
end
function create_battlefield_grid_control(form, row, col, order_school)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local groupbox = gui:Create("GroupBox")
  groupbox.BackColor = "0,0,0,0"
  groupbox.NoFrame = true
  groupbox.Name = "groupbox_battlefield_school_" .. nx_string(row) .. "_" .. nx_string(col)
  local grid_item = gui:Create("ImageGrid")
  groupbox:Add(grid_item)
  grid_item.Width = 30
  grid_item.Height = 30
  grid_item.Top = 0
  grid_item.Left = 10
  grid_item.Name = "imagegrid_rank_reward_item_" .. nx_string(row) .. "_" .. nx_string(col)
  grid_item.DrawMode = "FitWindow"
  grid_item.SelectColor = "0,0,0,0"
  grid_item.MouseInColor = "0,0,0,0"
  grid_item.NoFrame = true
  grid_item.BackImage = battlefield_school_pic[order_school]
  form.textgrid_battle_order:SetGridControl(row, col, groupbox)
end
function InitGridCol(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local grid = form.textgrid_battle_order
  if not nx_is_valid(grid) then
    return
  end
  if form.have_score then
    if SIDE_WHITE == form.self_side or SIDE_BLACK == form.self_side then
      if form.play_way == PLAY_WAY_DUOQI then
        grid.ColCount = 13
      else
        grid.ColCount = 11
      end
    else
      grid.ColCount = 10
    end
  elseif SIDE_WHITE == form.self_side or SIDE_BLACK == form.self_side then
    if form.play_way == PLAY_WAY_DUOQI then
      grid.ColCount = 11
    else
      grid.ColCount = 9
    end
  else
    grid.ColCount = 8
  end
  for i = 0, grid.ColCount - 1 do
    grid:SetColWidth(i, 60)
  end
  grid:SetColWidth(1, 80)
  if form.have_score then
    if SIDE_WHITE == form.self_side or SIDE_BLACK == form.self_side then
    else
      grid:SetColWidth(5, 70)
      grid:SetColWidth(6, 70)
    end
  elseif SIDE_WHITE == form.self_side or SIDE_BLACK == form.self_side then
  else
    grid:SetColWidth(4, 70)
    grid:SetColWidth(5, 70)
  end
  grid:SetColTitle(0, gui.TextManager:GetText(bf_order_head_name[1]))
  grid:SetColTitle(1, gui.TextManager:GetText(bf_order_head_name[2]))
  grid:SetColTitle(2, gui.TextManager:GetText(bf_order_head_name[3]))
  if form.have_score then
    grid:SetColTitle(3, gui.TextManager:GetText(bf_order_head_name[4]))
    grid:SetColTitle(4, gui.TextManager:GetText(bf_order_head_name[5]))
    grid:SetColTitle(5, gui.TextManager:GetText(bf_order_head_name[13]))
    grid:SetColTitle(6, gui.TextManager:GetText(bf_order_head_name[6]))
    if SIDE_WHITE == form.self_side or SIDE_BLACK == form.self_side then
      grid:SetColTitle(7, gui.TextManager:GetText(bf_order_head_name[12]))
      if form.play_way == PLAY_WAY_DUOQI then
        grid:SetColTitle(8, gui.TextManager:GetText(bf_order_head_name[8]))
        grid:SetColTitle(9, gui.TextManager:GetText(bf_order_head_name[9]))
        grid:SetColTitle(10, gui.TextManager:GetText(bf_order_head_name[7]))
        grid:SetColTitle(11, gui.TextManager:GetText(bf_order_head_name[11]))
      else
        grid:SetColTitle(8, gui.TextManager:GetText(bf_order_head_name[7]))
        grid:SetColTitle(9, gui.TextManager:GetText(bf_order_head_name[11]))
      end
    else
      grid:SetColTitle(7, gui.TextManager:GetText(bf_order_head_name[10]))
      grid:SetColTitle(8, gui.TextManager:GetText(bf_order_head_name[7]))
      grid:SetColTitle(9, gui.TextManager:GetText(bf_order_head_name[11]))
    end
  else
    grid:SetColTitle(3, gui.TextManager:GetText(bf_order_head_name[5]))
    grid:SetColTitle(4, gui.TextManager:GetText(bf_order_head_name[13]))
    grid:SetColTitle(5, gui.TextManager:GetText(bf_order_head_name[6]))
    if SIDE_WHITE == form.self_side or SIDE_BLACK == form.self_side then
      grid:SetColTitle(6, gui.TextManager:GetText(bf_order_head_name[12]))
      if form.play_way == PLAY_WAY_DUOQI then
        grid:SetColTitle(7, gui.TextManager:GetText(bf_order_head_name[8]))
        grid:SetColTitle(8, gui.TextManager:GetText(bf_order_head_name[9]))
        grid:SetColTitle(9, gui.TextManager:GetText(bf_order_head_name[7]))
      else
        grid:SetColTitle(7, gui.TextManager:GetText(bf_order_head_name[7]))
      end
    else
      grid:SetColTitle(6, gui.TextManager:GetText(bf_order_head_name[10]))
      grid:SetColTitle(7, gui.TextManager:GetText(bf_order_head_name[7]))
    end
  end
  grid:ClearRow()
  grid:ClearSelect()
end
function on_btn_exit_bf_click(btn)
  local CLIENT_SUBMSG_REQUEST_LEAVE = 2
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_REQUEST_LEAVE)
end
function sort_bf_info_array(is_score)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if is_score then
    for i = 1, 48 do
      local array_name = BATTLEFIELD_ORDER_ARRAY_INFO .. nx_string(i)
      if common_array:FindArray(array_name) then
        if 0 == table.getn(grid_order_data) then
          table.insert(grid_order_data, array_name)
        else
          local insert_done = false
          for j = 1, table.getn(grid_order_data) do
            local score_in_table = common_array:FindChild(nx_string(grid_order_data[j]), "b_order_score")
            local score_new_array = common_array:FindChild(nx_string(array_name), "b_order_score")
            if score_in_table < score_new_array then
              table.insert(grid_order_data, j, array_name)
              insert_done = true
              break
            elseif score_new_array == score_in_table then
              local kill_in_table = common_array:FindChild(nx_string(grid_order_data[j]), "b_order_kill_count")
              local kill_new_array = common_array:FindChild(nx_string(array_name), "b_order_kill_count")
              if kill_in_table < kill_new_array then
                table.insert(grid_order_data, j, array_name)
                insert_done = true
                break
              elseif kill_new_array == kill_in_table then
                local queue_in_table = common_array:FindChild(nx_string(grid_order_data[j]), "b_order_queue_kill")
                local queue_new_array = common_array:FindChild(nx_string(array_name), "b_order_queue_kill")
                if queue_in_table < queue_new_array then
                  table.insert(grid_order_data, j, array_name)
                  insert_done = true
                  break
                elseif queue_new_array == queue_in_table then
                  local dead_in_table = common_array:FindChild(nx_string(grid_order_data[j]), "b_order_dead_count")
                  local dead_new_array = common_array:FindChild(nx_string(array_name), "b_order_dead_count")
                  if dead_in_table > dead_new_array then
                    table.insert(grid_order_data, j, array_name)
                    insert_done = true
                    break
                  end
                end
              end
            end
          end
          if not insert_done then
            table.insert(grid_order_data, array_name)
          end
        end
      end
    end
  else
    for i = 1, 48 do
      local array_name = BATTLEFIELD_ORDER_ARRAY_INFO .. nx_string(i)
      if common_array:FindArray(array_name) then
        if 0 == table.getn(grid_order_data) then
          table.insert(grid_order_data, array_name)
        else
          local insert_done = false
          for j = 1, table.getn(grid_order_data) do
            local kill_in_table = common_array:FindChild(nx_string(grid_order_data[j]), "b_order_kill_count")
            local kill_new_array = common_array:FindChild(nx_string(array_name), "b_order_kill_count")
            if kill_in_table < kill_new_array then
              table.insert(grid_order_data, j, array_name)
              insert_done = true
              break
            elseif kill_new_array == kill_in_table then
              local queue_in_table = common_array:FindChild(nx_string(grid_order_data[j]), "b_order_queue_kill")
              local queue_new_array = common_array:FindChild(nx_string(array_name), "b_order_queue_kill")
              if queue_in_table < queue_new_array then
                table.insert(grid_order_data, j, array_name)
                insert_done = true
                break
              elseif queue_new_array == queue_in_table then
                local dead_in_table = common_array:FindChild(nx_string(grid_order_data[j]), "b_order_dead_count")
                local dead_new_array = common_array:FindChild(nx_string(array_name), "b_order_dead_count")
                if dead_in_table > dead_new_array then
                  table.insert(grid_order_data, j, array_name)
                  insert_done = true
                  break
                end
              end
            end
          end
          if not insert_done then
            table.insert(grid_order_data, array_name)
          end
        end
      end
    end
  end
end
function create_battlefield_eliminate_button(form, row, col, player_name, be_eliminated)
  if 1 ~= be_eliminated then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local button = gui:Create("Button")
  if not nx_is_valid(button) then
    return
  end
  button.Name = "btn_eliminate_" .. nx_string(row)
  button.Text = gui.TextManager:GetText("tips_battlefield_KickOut")
  button.ForeColor = "255,255,255,255"
  button.HintText = gui.TextManager:GetText("tips_battlefield_KickOutDec")
  button.DataSource = nx_string(player_name)
  button.DrawMode = "FitWindow"
  button.NormalImage = "gui\\common\\button\\btn_normal1_out.png"
  button.FocusImage = "gui\\common\\button\\btn_normal1_on.png"
  button.PushImage = "gui\\common\\button\\btn_normal1_down.png"
  button.Visible = true
  nx_bind_script(button, nx_current())
  nx_callback(button, "on_click", "on_btn_eliminate_click")
  form.textgrid_battle_order:ClearGridControl(row, col)
  form.textgrid_battle_order:SetGridControl(row, col, button)
end
function on_btn_eliminate_click(btn)
  local name = nx_string(btn.DataSource)
  if nil == name or "" == name then
    return
  end
  local CLIENT_SUBMSG_REQUEST_COMPLAIN = 9
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_REQUEST_COMPLAIN, nx_widestr(name))
end
