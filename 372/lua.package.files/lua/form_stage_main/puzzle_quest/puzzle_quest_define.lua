require("util_functions")
FORM_JINGMAI = "form_stage_main\\puzzle_quest\\form_jingmai"
FORM_PUZZLE_QUEST = "form_stage_main\\puzzle_quest\\form_puzzle_quest"
FORM_CAIFENG = "form_stage_main\\puzzle_quest\\form_caifeng"
gem_game_type = {
  gt_caifeng = 1,
  gt_datongjingmai = 2,
  gt_tiejiang = 3,
  gt_qiaojiang = 4,
  gt_dushi = 5,
  gt_yaoshi = 6,
  gt_chushi = 7,
  gt_gemegggame = 8,
  gt_gemtaskgame = 9,
  gt_gemtaskegggame = 10
}
gem_game_mode = {
  VSMode = 0,
  FacultyMode = 1,
  BrokenDoorMode = 2,
  EggMode = 3,
  TaskMode = 4,
  TaskEggMode = 5
}
gem_type = {
  None = 0,
  Red = 1,
  Yellow = 2,
  Blue = 3,
  Green = 4,
  Purple = 5,
  Colour = 6,
  Skull = 7,
  MovePoint = 8
}
gem_prop = {
  "Passion",
  "Vitality",
  "Energy",
  "Specialty",
  "Talent"
}
gem_color_image = {
  "gui\\animations\\path_effect\\red.dds",
  "gui\\animations\\path_effect\\yellow.dds",
  "gui\\animations\\path_effect\\blue.dds",
  "gui\\animations\\path_effect\\green.dds",
  "gui\\animations\\path_effect\\purple.dds"
}
special_type = {Edge = 9}
gem_color = {}
gem_number_effect = {}
diamond_photo = {}
diamond_photo2 = {}
diamond_bomb = {}
diamond_img_text = {}
diamond_hurt_effect = {}
scene_effect_position = {}
diamond_sound_effect = {}
diamond_type_count = 8
select_diamond_img = "quanlv"
select_diamond_img2 = "quanhong"
diamond_width = 70
diamond_height = 70
tip_fix_width = 42
tip_fix_x = 22
bomb_fix_x = 70
bomb_fix_y = 62
tip_img = "tishi"
skillanim = ""
diamond_matrix_x = 0
diamond_matrix_y = 0
config_lst = {
  [gem_game_type.gt_caifeng] = "ini\\ui\\puzzlequest\\caifeng.ini",
  [gem_game_type.gt_datongjingmai] = "ini\\ui\\puzzlequest\\datongjingmai.ini",
  [gem_game_type.gt_tiejiang] = "ini\\ui\\puzzlequest\\tiejiang.ini",
  [gem_game_type.gt_qiaojiang] = "ini\\ui\\puzzlequest\\qiaojiang.ini",
  [gem_game_type.gt_dushi] = "ini\\ui\\puzzlequest\\dushi.ini",
  [gem_game_type.gt_yaoshi] = "ini\\ui\\puzzlequest\\yaoshi.ini",
  [gem_game_type.gt_chushi] = "ini\\ui\\puzzlequest\\chushi.ini",
  [gem_game_type.gt_gemtaskgame] = "ini\\ui\\puzzlequest\\renwu_wuqi.ini"
}
config_lst_1 = {
  [gem_game_type.gt_caifeng] = "ini\\ui\\puzzlequest\\caifeng_quest.ini",
  [gem_game_type.gt_datongjingmai] = "ini\\ui\\puzzlequest\\datongjingmai.ini",
  [gem_game_type.gt_tiejiang] = "ini\\ui\\puzzlequest\\tiejiang_quest.ini",
  [gem_game_type.gt_qiaojiang] = "ini\\ui\\puzzlequest\\qiaojiang_quest.ini",
  [gem_game_type.gt_dushi] = "ini\\ui\\puzzlequest\\dushi_quest.ini",
  [gem_game_type.gt_yaoshi] = "ini\\ui\\puzzlequest\\yaoshi_quest.ini",
  [gem_game_type.gt_chushi] = "ini\\ui\\puzzlequest\\chushi_quest.ini"
}
config_lst_2 = {
  [gem_game_type.gt_gemegggame] = "ini\\ui\\puzzlequest\\zadan.ini",
  [gem_game_type.gt_gemtaskegggame] = "ini\\ui\\puzzlequest\\yhg_zadan.ini"
}
skin_lst = {
  [gem_game_type.gt_caifeng] = "form_stage_main\\puzzle_quest\\form_caifeng",
  [gem_game_type.gt_tiejiang] = "form_stage_main\\puzzle_quest\\form_tiejiang",
  [gem_game_type.gt_qiaojiang] = "form_stage_main\\puzzle_quest\\form_qiaojiang",
  [gem_game_type.gt_dushi] = "form_stage_main\\puzzle_quest\\form_dushi",
  [gem_game_type.gt_yaoshi] = "form_stage_main\\puzzle_quest\\form_yaoshi",
  [gem_game_type.gt_chushi] = "form_stage_main\\puzzle_quest\\form_chushi",
  [gem_game_type.gt_gemtaskgame] = "form_stage_main\\puzzle_quest\\form_renwu_wuqi"
}
skin_lst_1 = {
  [gem_game_type.gt_caifeng] = "form_stage_main\\puzzle_quest\\form_caifeng_quest",
  [gem_game_type.gt_tiejiang] = "form_stage_main\\puzzle_quest\\form_tiejiang_quest",
  [gem_game_type.gt_qiaojiang] = "form_stage_main\\puzzle_quest\\form_qiaojiang_quest",
  [gem_game_type.gt_dushi] = "form_stage_main\\puzzle_quest\\form_dushi_quest",
  [gem_game_type.gt_yaoshi] = "form_stage_main\\puzzle_quest\\form_yaoshi_quest",
  [gem_game_type.gt_chushi] = "form_stage_main\\puzzle_quest\\form_chushi_quest"
}
skin_lst_2 = {
  [gem_game_type.gt_gemegggame] = "form_stage_main\\puzzle_quest\\form_smahing_egg",
  [gem_game_type.gt_gemtaskegggame] = "form_stage_main\\puzzle_quest\\form_smahing_yhg"
}
help_skin_lst_1 = {
  [gem_game_type.gt_caifeng] = "form_stage_main\\form_help\\form_help_bsyx_cf",
  [gem_game_type.gt_tiejiang] = "form_stage_main\\form_help\\form_help_bsyx_tj",
  [gem_game_type.gt_qiaojiang] = "form_stage_main\\form_help\\form_help_bsyx_jq",
  [gem_game_type.gt_dushi] = "form_stage_main\\form_help\\form_help_bsyx_ds",
  [gem_game_type.gt_yaoshi] = "form_stage_main\\form_help\\form_help_bsyx_ys",
  [gem_game_type.gt_chushi] = "form_stage_main\\form_help\\form_help_bsyx_cs"
}
help_skin_lst = {
  [gem_game_type.gt_caifeng] = "form_stage_main\\form_help\\form_help_bsyx_cfbp",
  [gem_game_type.gt_tiejiang] = "form_stage_main\\form_help\\form_help_bsyx_tjbp",
  [gem_game_type.gt_qiaojiang] = "form_stage_main\\form_help\\form_help_bsyx_jqbp",
  [gem_game_type.gt_dushi] = "form_stage_main\\form_help\\form_help_bsyx_dsbp",
  [gem_game_type.gt_yaoshi] = "form_stage_main\\form_help\\form_help_bsyx_ysbp",
  [gem_game_type.gt_chushi] = "form_stage_main\\form_help\\form_help_bsyx_csbp"
}
job_id = {
  [gem_game_type.gt_caifeng] = "sh_cf",
  [gem_game_type.gt_tiejiang] = "sh_tj",
  [gem_game_type.gt_qiaojiang] = "sh_jq",
  [gem_game_type.gt_dushi] = "sh_ds",
  [gem_game_type.gt_yaoshi] = "sh_ys",
  [gem_game_type.gt_chushi] = "sh_cs"
}
function init_gem_game_info(type, game_type)
  local config_ini
  if game_type == 0 then
    config_ini = nx_execute("util_functions", "get_ini", config_lst[type])
  elseif game_type == 2 then
    config_ini = nx_execute("util_functions", "get_ini", config_lst_1[type])
  elseif game_type == 3 then
    config_ini = nx_execute("util_functions", "get_ini", config_lst_2[type])
  elseif game_type == 4 then
    config_ini = nx_execute("util_functions", "get_ini", config_lst[type])
  elseif game_type == 5 then
    config_ini = nx_execute("util_functions", "get_ini", config_lst_2[type])
  end
  if not nx_is_valid(config_ini) then
    return 0
  end
  local index = config_ini:FindSectionIndex("config")
  if index ~= -1 then
    diamond_type_count = config_ini:ReadInteger(index, "diamond_count", 0)
    select_diamond_img = config_ini:ReadString(index, "self_select_img", "")
    select_diamond_img2 = config_ini:ReadString(index, "self_select_img2", "")
    diamond_width = config_ini:ReadInteger(index, "diamond_width", 0)
    diamond_height = config_ini:ReadInteger(index, "diamond_height", 0)
    tip_img = config_ini:ReadString(index, "tip_img", "")
    tip_fix_width = config_ini:ReadInteger(index, "tip_fix_width", 0)
    tip_fix_x = config_ini:ReadInteger(index, "tip_fix_x", 0)
    bomb_fix_x = config_ini:ReadInteger(index, "bomb_fix_x", 0)
    bomb_fix_y = config_ini:ReadInteger(index, "bomb_fix_y", 0)
    diamond_matrix_x = config_ini:ReadInteger(index, "diamond_matrix_x", 0)
    diamond_matrix_y = config_ini:ReadInteger(index, "diamond_matrix_y", 0)
  end
  for i = 1, diamond_type_count do
    local diamond_index = config_ini:FindSectionIndex("diamond" .. nx_string(i))
    if diamond_index ~= -1 then
      gem_color[i] = config_ini:ReadString(diamond_index, "color", "")
      gem_number_effect[i] = config_ini:ReadString(diamond_index, "number", "")
      diamond_photo[i] = config_ini:ReadString(diamond_index, "photo", "")
      diamond_photo2[i] = config_ini:ReadString(diamond_index, "photo2", "")
      diamond_bomb[i] = config_ini:ReadString(diamond_index, "bomb", "")
    end
  end
  local text_index = config_ini:FindSectionIndex("text")
  if text_index ~= -1 then
    local text_count = config_ini:GetSectionItemCount(text_index)
    for i = 0, text_count - 1 do
      local key = config_ini:GetSectionItemKey(text_index, i)
      diamond_img_text[key] = config_ini:GetSectionItemValue(text_index, i)
    end
  end
  local scene_index = config_ini:FindSectionIndex("scene")
  if scene_index ~= -1 then
    local scene_count = config_ini:GetSectionItemCount(scene_index)
    for i = 0, scene_count - 1 do
      local key = config_ini:GetSectionItemKey(scene_index, i)
      diamond_hurt_effect[key] = config_ini:GetSectionItemValue(scene_index, i)
    end
  end
  local scene_position_index = config_ini:FindSectionIndex("sceneposition")
  if scene_position_index ~= -1 then
    local scene_position_count = config_ini:GetSectionItemCount(scene_position_index)
    for i = 0, scene_position_count - 1 do
      local key = config_ini:GetSectionItemKey(scene_position_index, i)
      scene_effect_position[key] = config_ini:GetSectionItemValue(scene_position_index, i)
    end
  end
  local skill_anim_index = config_ini:FindSectionIndex("skillanim")
  if skill_anim_index ~= -1 then
    skillanim = config_ini:ReadString(skill_anim_index, "skillanim", "")
  end
  local sound_index = config_ini:FindSectionIndex("sound")
  if sound_index ~= -1 then
    local sound_count = config_ini:GetSectionItemCount(sound_index)
    for i = 0, sound_count - 1 do
      local key = config_ini:GetSectionItemKey(sound_index, i)
      diamond_sound_effect[key] = config_ini:GetSectionItemValue(sound_index, i)
    end
  end
end
function get_diamond_type(data)
  if data == nil then
    return 1
  end
  return nx_number(nx_int(data / 100))
end
function get_diamond_value(data)
  if data == nil then
    return 1
  end
  return nx_number(math.mod(data, 100))
end
function get_diamond_photo(data, state)
  if state == nil then
    state = 1
  end
  local type = get_diamond_type(data)
  local value = get_diamond_value(data)
  local diamond_photo_list = {}
  if 1 < value then
    diamond_photo_list = util_split_string(diamond_photo2[type], ",")
  else
    diamond_photo_list = util_split_string(diamond_photo[type], ",")
  end
  if diamond_photo_list[state] == nil then
    if diamond_photo_list[1] == nil then
      return ""
    end
    return diamond_photo_list[1]
  end
  return diamond_photo_list[state]
end
function get_skill_need_image(type)
  local skill_need_image = {}
  local config_ini = nx_execute("util_functions", "get_ini", config_lst[type])
  if not nx_is_valid(config_ini) then
    return 0
  end
  local image_index = config_ini:FindSectionIndex("skillimage")
  if image_index < 0 then
    return 0
  end
  local image_count = config_ini:GetSectionItemCount(image_index)
  for i = 0, image_count - 1 do
    local key = config_ini:GetSectionItemKey(image_index, i)
    skill_need_image[key] = config_ini:GetSectionItemValue(image_index, i)
  end
  return skill_need_image
end
op_create = 0
op_swap = 1
op_bomb = 2
op_exit = 3
op_act_over = 4
op_reset = 5
op_skill = 6
op_select_target = 7
op_select_member = 8
op_change = 9
op_damage = 10
op_effective = 11
op_useitem = 12
op_synskill = 13
op_heroichit = 14
op_gamelevel = 16
op_useskillsucess = 18
op_born = 113
op_drop = 114
op_query_tip = 115
op_sysn = 116
