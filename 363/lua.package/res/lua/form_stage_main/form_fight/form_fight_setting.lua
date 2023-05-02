require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
require("util_functions")
local ARENA_MODE_MAX_COUNT = 5
local FORM_FIGHT_SETTING = "form_stage_main\\form_fight\\form_fight_setting"
local combobox_list = {
  "combobox_player_1",
  "combobox_player_2",
  "combobox_referee"
}
function main_form_init(form)
  form.Fixed = false
  form.target_scene_id = 0
  form.life_time = 180
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  init_form_data(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "update_time", form, -1, -1)
  end
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_time", form)
  end
  nx_destroy(form)
end
function on_main_form_shut(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local mode, total, win, p1, p2, referee = get_arena_param(form)
  if nx_string(p1) == nx_string(p2) or nx_string(p1) == nx_string(referee) or nx_string(p2) == nx_string(referee) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("88009"), 2)
    end
    return
  end
  custom_arena_init(mode, total, win, p1, p2, referee)
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form_by_param(selected_scene_id)
  local form_fight_setting = nx_execute("util_gui", "util_show_form", FORM_FIGHT_SETTING, true)
  if not nx_is_valid(form_fight_setting) then
    return
  end
  form_fight_setting.lbl_scene_name.Text = nx_widestr(util_text("arena_scene_name_" .. nx_string(selected_scene_id)))
  form_fight_setting.lbl_scene_image.BackImage = "gui\\special\\leitai\\fight_" .. nx_string(selected_scene_id) .. ".png"
end
function init_form_data(form)
  local game_client = nx_value("game_client")
  local game_scene = game_client:GetScene()
  local table_client_obj = game_scene:GetSceneObjList()
  for i = 1, #table_client_obj do
    local client_obj = table_client_obj[i]
    if client_obj:FindProp("Name") then
      local name = client_obj:QueryProp("Name")
      local obj_type = client_obj:QueryProp("Type")
      if nx_int(obj_type) == nx_int(2) then
        form.combobox_player_1.DropListBox:AddString(name)
        form.combobox_player_2.DropListBox:AddString(name)
        form.combobox_referee.DropListBox:AddString(name)
      end
    end
  end
  local gui = nx_value("gui")
  form.lbl_scene_name.Text = gui.TextManager:GetText("area_scene02_TYXJ_taiyitai")
  for i = 1, ARENA_MODE_MAX_COUNT do
    form.combobox_mode.DropListBox:AddString(nx_widestr(i))
  end
  form.combobox_mode.Text = nx_widestr("2")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_is_valid(client_player) then
    form.combobox_referee.Text = nx_widestr(client_player:QueryProp("Name"))
  end
end
function get_arena_param(form)
  local player_1 = form.combobox_player_1.Text
  local player_2 = form.combobox_player_2.Text
  local referee = form.combobox_referee.Text
  local win_count = nx_int(form.combobox_mode.Text)
  local total_count = win_count * 2 - 1
  return 1, total_count, win_count, player_1, player_2, referee
end
function update_time(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.life_time) < nx_int(0) then
    form:Close()
  else
    form.life_time = form.life_time - 1
    local gui = nx_value("gui")
    form.lbl_life_time.Text = nx_widestr(gui.TextManager:GetFormatText("ui_arena_life_time", nx_int(form.life_time)))
  end
end
