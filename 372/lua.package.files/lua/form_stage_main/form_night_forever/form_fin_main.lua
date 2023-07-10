require("util_gui")
require("util_functions")
require("custom_sender")
require("form_stage_main\\form_common_notice")
require("util_static_data")
local FORM_NAME = "form_stage_main\\form_night_forever\\form_fin_main"
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  nx_execute("custom_sender", "custom_flee_in_night", nx_int(2))
  refresh_subform_reward(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_go_click(btn)
  custom_flee_in_night(0)
end
function on_btn_close_click(btn)
  close_form()
end
function on_rbtn_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = true
    form.gb_2.Visible = false
    form.gb_3.Visible = false
  end
end
function on_rbtn_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = false
    form.gb_2.Visible = true
    form.gb_3.Visible = false
  end
end
function on_rbtn_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = false
    form.gb_2.Visible = false
    form.gb_3.Visible = true
  end
end
function on_imagegrid_item_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local item_id = grid.DataSource
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", item_id, x, y, form)
end
function on_imagegrid_item_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_player_info(...)
  local shaqi = nx_number(arg[1])
  local kill = nx_number(arg[2])
  local kill_combo = nx_number(arg[3])
  local assist = nx_number(arg[4])
  local score_round = nx_number(arg[5])
  local price_nums = nx_number(arg[6])
  local side_player_nums_1 = nx_number(arg[7])
  local side_player_nums_2 = nx_number(arg[8])
  local desc = nx_widestr("")
  desc = desc .. nx_widestr("<br>") .. util_format_string("ui_fin_info_007", side_player_nums_1, side_player_nums_2)
  desc = desc .. nx_widestr("<br>") .. util_format_string("ui_fin_info_001", shaqi)
  desc = desc .. nx_widestr("<br>") .. util_format_string("ui_fin_info_002", kill)
  desc = desc .. nx_widestr("<br>") .. util_format_string("ui_fin_info_003", kill_combo)
  desc = desc .. nx_widestr("<br>") .. util_format_string("ui_fin_info_004", assist)
  desc = desc .. nx_widestr("<br>") .. util_format_string("ui_fin_info_005", score_round)
  desc = desc .. nx_widestr("<br>") .. util_format_string("ui_fin_info_006", price_nums)
  nx_execute("form_stage_main\\form_common_notice", "NotifyText", nx_int(126), desc)
end
function on_update_info(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local price_nums = nx_number(arg[1])
  local score_today = nx_number(arg[2])
  local score_today_info = nx_string(arg[3])
  local score_month = nx_number(arg[4])
  form.lbl_price_nums.Text = nx_widestr(price_nums)
  form.lbl_score_today.Text = nx_widestr(score_today)
  form.lbl_score_month.Text = nx_widestr(score_month)
  local tab_score_today = util_split_string(score_today_info, ",")
  table.sort(tab_score_today, function(a, b)
    return nx_number(a) > nx_number(b)
  end)
  local tips = nx_widestr("")
  tips = tips .. nx_widestr(util_text("ui_fin_score_1"))
  for i = 1, table.getn(tab_score_today) do
    if nx_number(tab_score_today[i]) > 0 then
      tips = tips .. nx_widestr("<br>") .. nx_widestr(util_format_string("ui_fin_score_2", i, nx_number(tab_score_today[i])))
    end
  end
  form.lbl_score_1.HintText = tips
end
function is_in_flee_in_night()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_FLEE_IN_NIGHT) == PIS_IN_GAME then
    return true
  end
  return false
end
function refresh_subform_reward(form)
  for i = 1, 10 do
    for j = 1, 3 do
      local grid_index = (i - 1) * 3 + j
      local grid = nx_custom(form, "imagegrid_" .. nx_string(grid_index))
      if not nx_is_valid(grid) then
        return
      end
      local item_id = nx_string(grid.DataSource)
      if nx_is_valid(grid) and item_id ~= "" then
        grid:Clear()
        local photo = item_query_ArtPack_by_id(item_id, "Photo")
        grid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
        grid:CoverItem(0, true)
      end
    end
  end
end
function show_snow_warn_animation()
  local gui = nx_value("gui")
  local animation_1_left = gui.Width / 12
  local animation_1_top = gui.Height / 5
  local animation_1 = show_animation("nightwar_time", animation_1_left, gui.Height / 5)
  local animation_2 = show_animation("second_ten", animation_1_left + 128, animation_1_top + 53)
end
function show_animation(ani_name, left, top)
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.AnimationImage = nx_string(ani_name)
  animation.Transparent = true
  gui.Desktop:Add(animation)
  animation.Left = left
  animation.Top = top
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "end_animation")
  animation:Play()
  return animation
end
function end_animation(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
function a(info)
  nx_msgbox(nx_string(info))
end
function reload_res()
  local mgr = nx_value("SceneCreator")
  mgr:LoadFleeInNightAreaRes()
end
