require("form_stage_main\\form_main\\form_main_fightvs_util")
local hide_bar_skill_tab = {
  "pet_monkey_act1",
  "pet_monkey_act2",
  "pet_panda_act1",
  "pet_panda_act2"
}
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = gui.Desktop.Height - form.Height - 150
  gui.Desktop:ToBack(form)
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_effect")
  if bMovie then
    form.Visible = false
    nx_execute("form_stage_main\\form_movie_effect", "add_hide_control", form)
  else
    form.Visible = true
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function change_form_size()
  local form = util_get_form(FORM_FIGHT_VS_ALONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = gui.Desktop.Height - form.Height - 140
end
function get_skill_photo(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local skill_id = client_player:QueryProp("CurSkillID")
  if string.len(skill_id) < 0 then
    return ""
  end
  return skill_static_query_by_id(skill_id, "Photo")
end
function special_skill_hide_bar(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local skill_id = player:QueryProp("CurSkillID")
  if string.len(skill_id) <= 0 then
    return
  end
  for i, str in pairs(hide_bar_skill_tab) do
    if skill_id == str then
      form.Visible = false
      return
    end
  end
end
function star_taolu_progress(ticks, curse_text)
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return 0
  end
  local photo = get_skill_photo()
  if nx_string(photo) == "" then
    return 0
  end
  local form = util_get_form(FORM_FIGHT_VS_ALONE, true, false)
  if not nx_is_valid(form) then
    return 0
  end
  form.lbl_photo.BackImage = nx_string(photo)
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    local total_width = 174
    local init_left = form.groupbox_1.Left
    form.fCountWidth = 0
    common_execute:RemoveExecute("IncantProgressBar", form)
    common_execute:AddExecute("IncantProgressBar", form, 0.05, nx_float(ticks), nx_float(total_width), nx_float(init_left))
  end
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_effect")
  if bMovie then
    form.Visible = false
    nx_execute("form_stage_main\\form_movie_effect", "add_hide_control", form)
  else
    util_show_form(FORM_FIGHT_VS_ALONE, true)
    form.Visible = true
  end
  special_skill_hide_bar(form)
end
function stop_taolu_progress(msg)
  local form = util_get_form(FORM_FIGHT_VS_ALONE, false)
  if nx_is_valid(form) then
    form.Visible = false
  end
end
function begin_compare_zhaoshi()
  local form = util_get_form(FORM_FIGHT_VS_ALONE, false)
  if not nx_is_valid(form) then
    return 0
  end
  form.Visible = false
end
