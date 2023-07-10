require("util_gui")
require("util_functions")
require("util_static_data")
local FORM_SIGN_N_DRAW = "form_stage_main\\form_dbomall\\form_sign_and_draw"
local INI_SIGN_N_DRAW = "share\\Activity\\form_sign_and_draw.ini"
local CLIENT_SUBMSG_SIGN_N_DRAW_REFRESH_FORM = 0
local CLIENT_SUBMSG_SIGN_N_DRAW_DRAW = 1
local CLIENT_SUBMSG_SIGN_N_DRAW_EXTRA_REWARD = 2
local SERVER_SUBMSG_SIGN_N_DRAW_REFRESH_FORM = 1
local SERVER_SUBMSG_SIGN_N_DRAW_RESULT = 2
local SERVER_SUBMSG_SIGN_N_DRAW_FLASH = 3
local SERVER_SUBMSG_SIGN_N_RESETDAY = 4
local MAX_REWARD_COUNT = 10
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  init_form(form)
  form.lbl_select.Visible = false
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_main_form_close(form)
  local timer_game = nx_value("timer_game")
  if nx_is_valid(timer_game) then
    timer_game:UnRegister(nx_current(), "on_update_time_left", form)
    timer_game:UnRegister(nx_current(), "on_change_circle_pos", form)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_draw_click()
  nx_execute("custom_sender", "custom_form_sign_and_draw", CLIENT_SUBMSG_SIGN_N_DRAW_DRAW)
end
function open_form()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local is_jyf_faculty = player:QueryProp("IsJYFaucltyAttacker")
  if nx_int(is_jyf_faculty) == nx_int(1) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_activity_sign_n_draw_08"), 2)
    end
    return
  end
  local ST_FUNCTION_SIGN_N_DRAW = 899
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_SIGN_N_DRAW) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19919"), 2)
    end
    return
  end
  local form = util_show_form(FORM_SIGN_N_DRAW, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  nx_execute("custom_sender", "custom_form_sign_and_draw", CLIENT_SUBMSG_SIGN_N_DRAW_REFRESH_FORM)
end
function on_refresh(sub_msg, ...)
  local arg_count = table.getn(arg)
  if nx_int(sub_msg) == nx_int(SERVER_SUBMSG_SIGN_N_DRAW_REFRESH_FORM) then
    local form = nx_value(FORM_SIGN_N_DRAW)
    if not nx_is_valid(form) then
      local draw_count = nx_int(arg[2])
      if draw_count > nx_int(0) then
        set_flash(true)
      else
        set_flash(false)
      end
      return
    end
    refresh_remain_time(form, nx_int64(arg[1]))
    local draw_count = nx_int(arg[2])
    if draw_count < nx_int(0) then
      draw_count = nx_int(0)
    end
    form.mltbox_num.HtmlText = nx_widestr(draw_count)
    if nx_int64(arg[1]) < nx_int64(0) and nx_int(draw_count) <= nx_int(0) then
      form.btn_draw.Enabled = false
    else
      form.btn_draw.Enabled = true
    end
    form.btn_draw2.Enabled = nx_int(arg[3]) == nx_int(1)
    local imagegrid = nx_null()
    for i = 1, MAX_REWARD_COUNT do
      local b_find = false
      for j = 4, arg_count do
        if nx_int(arg[j]) == nx_int(i) then
          b_find = true
          break
        end
      end
      refresh_imagegrid_status(form, i, b_find)
    end
    form.Visible = true
  elseif nx_int(sub_msg) == nx_int(SERVER_SUBMSG_SIGN_N_DRAW_RESULT) then
    local form = nx_value(FORM_SIGN_N_DRAW)
    if not nx_is_valid(form) then
      return
    end
    start_draw(form, arg[1])
    set_flash(false)
  elseif nx_int(sub_msg) == nx_int(SERVER_SUBMSG_SIGN_N_DRAW_FLASH) then
    set_flash(true)
  elseif nx_int(sub_msg) == nx_int(SERVER_SUBMSG_SIGN_N_RESETDAY) then
    set_flash(false)
    local form_main = nx_value("form_stage_main\\form_main\\form_main")
    if nx_is_valid(form_main) then
      nx_execute("form_stage_main\\form_activity\\form_activity_new_terms_registration", "show_flashing_icon", form_main.lbl_nts_select)
    end
  end
end
function refresh_remain_time(form, time_count)
  if not nx_is_valid(form) then
    return
  end
  local timer_game = nx_value("timer_game")
  if not nx_is_valid(timer_game) then
    return
  end
  if nx_int64(time_count) < nx_int64(0) then
    timer_game:UnRegister(nx_current(), "on_update_time_left", form)
    form.mltbox_time.HtmlText = util_text("sys_activity_sign_n_draw_04")
    return
  end
  timer_game:UnRegister(nx_current(), "on_update_time_left", form)
  form.use_time = nx_int(nx_int(time_count) / nx_int(1000))
  form.mltbox_time.HtmlText = nx_widestr(get_time_str(nx_number(form.use_time)))
  timer_game:Register(1000, -1, nx_current(), "on_update_time_left", form, -1, -1)
end
function on_update_time_left(form)
  if not nx_is_valid(form) then
    return
  end
  form.use_time = form.use_time - 1
  if nx_int(form.use_time) < nx_int(0) then
    local timer_game = nx_value("timer_game")
    if nx_is_valid(timer_game) then
      timer_game:UnRegister(nx_current(), "on_update_time_left", form)
    end
    nx_execute("custom_sender", "custom_form_sign_and_draw", CLIENT_SUBMSG_SIGN_N_DRAW_REFRESH_FORM)
    return
  end
  form.mltbox_time.HtmlText = nx_widestr(get_time_str(nx_number(form.use_time)))
end
function get_time_str(times)
  local szTime = ""
  local minute = nx_number(nx_int(times / 60))
  if minute < 10 then
    szTime = szTime .. "0" .. nx_string(minute)
  else
    szTime = szTime .. nx_string(minute)
  end
  szTime = szTime .. ":"
  local second = times - minute * 60
  if second < 10 then
    szTime = szTime .. "0" .. nx_string(second)
  else
    szTime = szTime .. nx_string(second)
  end
  return szTime
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = get_ini(INI_SIGN_N_DRAW, true)
  if not nx_is_valid(ini) then
    return
  end
  local sec_default = ini:FindSectionIndex("default")
  if sec_default < 0 then
    return
  end
  local tmp_string = ini:ReadString(sec_default, "RewardItemID", "")
  local tmp_list = util_split_string(nx_string(tmp_string), ",")
  if 0 >= table.getn(tmp_list) then
    return
  end
  local imagegrid = nx_null()
  local item_id = ""
  for i = 1, table.getn(tmp_list) do
    imagegrid = nx_custom(form, "imagegrid_" .. nx_string(i))
    if nx_is_valid(imagegrid) then
      item_id = tmp_list[i]
      photo = item_query_ArtPack_by_id(item_id, "Photo")
      imagegrid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
      imagegrid:CoverItem(0, true)
      nx_bind_script(imagegrid, nx_current())
      nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_item_mousein_grid")
      nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_item_mouseout_grid")
    end
  end
  tmp_string = ini:ReadString(sec_default, "ExtraRewardItemID", "")
  photo = item_query_ArtPack_by_id(tmp_string, "Photo")
  form.imagegrid_extra:AddItem(0, photo, nx_widestr(tmp_string), 1, -1)
  form.imagegrid_extra:CoverItem(0, true)
end
function start_draw(form, select_pos)
  if not nx_is_valid(form) then
    return
  end
  if nx_number(select_pos) <= 0 then
    return
  end
  form.circle_select = select_pos
  form.end_post = nx_int(MAX_REWARD_COUNT) + nx_int(select_pos)
  form.circle_pos = 1
  local timer_game = nx_value("timer_game")
  if nx_is_valid(timer_game) then
    form.lbl_select.Visible = false
    timer_game:UnRegister(nx_current(), "on_change_circle_pos", form)
    timer_game:Register(100, nx_int(form.end_post), nx_current(), "on_change_circle_pos", form, -1, -1)
  end
end
function on_change_circle_pos(form)
  if not nx_is_valid(form) then
    return
  end
  local is_last = false
  if nx_int(form.circle_pos) >= nx_int(form.end_post) then
    is_last = true
  end
  local pos = nx_int(form.circle_pos)
  if nx_int(form.circle_pos) > nx_int(MAX_REWARD_COUNT) then
    pos = nx_int(form.circle_pos) - nx_int(MAX_REWARD_COUNT)
  end
  local lbl = nx_custom(form, "lbl_" .. nx_string(pos))
  if nx_is_valid(lbl) then
    form.lbl_select.Left = lbl.Left
    form.lbl_select.Top = lbl.Top
    form.lbl_select.Visible = true
    form:ToFront(form.lbl_select)
  else
    return
  end
  if nx_boolean(is_last) then
    refresh_imagegrid_status(form, pos, true)
    nx_execute("custom_sender", "custom_form_sign_and_draw", CLIENT_SUBMSG_SIGN_N_DRAW_REFRESH_FORM)
    return
  end
  form.circle_pos = nx_int(form.circle_pos) + nx_int(1)
end
function refresh_imagegrid_status(form, index, b_change)
  if not nx_is_valid(form) then
    return
  end
  local imagegrid = nx_custom(form, "imagegrid_" .. nx_string(index))
  if nx_is_valid(imagegrid) then
    imagegrid:ChangeItemImageToBW(nx_int(0), nx_boolean(b_change))
  end
  local lbl = nx_custom(form, "lbl_" .. nx_string(index))
  if nx_is_valid(lbl) then
    if nx_boolean(b_change) then
      lbl.BackImage = "gui\\special\\gujassets\\prop_bg_2.png"
    else
      lbl.BackImage = "gui\\special\\gujassets\\prop_bg.png"
    end
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
  local x, y = gui:GetCursorPosition()
  local item_id = grid:GetItemName(index)
  if item_id == nx_widestr("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_id, x, y, form)
end
function on_imagegrid_item_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function set_flash(b_show)
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  local lbl = nx_custom(form, "lbl_snd_select")
  if nx_is_valid(lbl) then
    lbl.Visible = nx_boolean(b_show)
  end
end
function refresh_activity_snd_reward_status()
  nx_execute("custom_sender", "custom_form_sign_and_draw", CLIENT_SUBMSG_SIGN_N_DRAW_REFRESH_FORM)
end
function reset_scene()
  local form = nx_value(FORM_SIGN_N_DRAW)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_draw2_click(btn)
  nx_execute("custom_sender", "custom_form_sign_and_draw", CLIENT_SUBMSG_SIGN_N_DRAW_EXTRA_REWARD)
end
function on_btn_draw2_get_capture(btn)
  if nx_boolean(btn.Enabled) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local text = util_text("sys_activity_sign_n_draw_12")
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z)
end
function on_btn_draw2_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
