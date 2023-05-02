require("util_functions")
gem_game_type = {
  gt_caifeng = 1,
  gt_datongjingmai = 2,
  gt_tiejiang = 3,
  gt_qiaojiang = 4,
  gt_dushi = 5,
  gt_yaoshi = 6,
  gt_chushi = 7
}
anim_cout = 0
label_cout = 0
anim_image_array = {}
label_image_array = {}
anims_type_array = {}
anim_x = 10
anim_skull = ""
anim_config_lst = {
  [gem_game_type.gt_caifeng] = "ini\\ui\\puzzlequest\\caifeng_anim.ini",
  [gem_game_type.gt_tiejiang] = "ini\\ui\\puzzlequest\\tiejiang_anim.ini",
  [gem_game_type.gt_qiaojiang] = "ini\\ui\\puzzlequest\\qiaojiang_anim.ini",
  [gem_game_type.gt_dushi] = "ini\\ui\\puzzlequest\\dushi_anim.ini",
  [gem_game_type.gt_yaoshi] = "ini\\ui\\puzzlequest\\yaoshi_anim.ini",
  [gem_game_type.gt_chushi] = "ini\\ui\\puzzlequest\\chushi_anim.ini"
}
function init_anim_info(type)
  local config_ini = nx_execute("util_functions", "get_ini", anim_config_lst[type])
  if not nx_is_valid(config_ini) then
    return 0
  end
  local index = config_ini:FindSectionIndex("config")
  if index ~= -1 then
    anim_cout = config_ini:ReadInteger(index, "ani_layer", 0)
    label_cout = config_ini:ReadInteger(index, "lbl_layer", 0)
    anim_skull = config_ini:ReadString(index, "anim_skull", "")
  end
  local anim_index = config_ini:FindSectionIndex("anims")
  if anim_index ~= -1 then
    local anim_count = config_ini:GetSectionItemCount(anim_index)
    anim_x = config_ini:ReadInteger(index, "anim_x", 0)
    for i = 0, anim_count - 1 do
      local key = config_ini:GetSectionItemKey(anim_index, i)
      anim_image_array[key] = config_ini:GetSectionItemValue(anim_index, i)
    end
  end
  local label_index = config_ini:FindSectionIndex("label")
  if label_index ~= -1 then
    local label_count = config_ini:GetSectionItemCount(label_index)
    for i = 0, label_count - 1 do
      local key = config_ini:GetSectionItemKey(label_index, i)
      label_image_array[key] = config_ini:GetSectionItemValue(label_index, i)
    end
  end
  local anims_index = config_ini:FindSectionIndex("event")
  if anims_index ~= -1 then
    local anims_count = config_ini:GetSectionItemCount(anims_index)
    for i = 0, anims_count - 1 do
      local key = config_ini:GetSectionItemKey(anims_index, i)
      anims_type_array[nx_string(key)] = config_ini:GetSectionItemValue(anims_index, i)
    end
  end
end
function get_anim_image(id, level)
  local anim_image_list = util_split_string(anim_image_array[nx_string(id)], ",")
  return anim_image_list[level]
end
function get_anim_label(id, level)
  local label_image_list = util_split_string(label_image_array[nx_string(id)], ",")
  return label_image_list[level]
end
