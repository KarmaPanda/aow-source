require("form_stage_main\\puzzle_quest\\puzzle_quest_define")
effect_content = {
  [1] = {
    "AnimationImage",
    "SmoothPath",
    "Loop",
    "ClosePath",
    "CreateMinInterval",
    "CreateMaxInterval",
    "RotateSpeed",
    "BeginAlpha",
    "AlphaChangeSpeed",
    "BeginScale",
    "ScaleSpeed",
    "MaxTime",
    "MaxWave"
  },
  [2] = {
    "color",
    "AnimationImage",
    "SmoothPath",
    "Loop",
    "ClosePath",
    "CreateMinInterval",
    "CreateMaxInterval",
    "RotateSpeed",
    "BeginAlpha",
    "AlphaChangeSpeed",
    "BeginScale",
    "ScaleSpeed",
    "MaxTime",
    "MaxWave"
  },
  [3] = {
    "destcontrol",
    "effecttarget",
    "AnimationImage",
    "SmoothPath",
    "Loop",
    "ClosePath",
    "CreateMinInterval",
    "CreateMaxInterval",
    "RotateSpeed",
    "BeginAlpha",
    "AlphaChangeSpeed",
    "BeginScale",
    "ScaleSpeed",
    "MaxTime",
    "MaxWave"
  },
  [4] = {
    "destcontrol",
    "effecttarget",
    "color",
    "AnimationImage",
    "SmoothPath",
    "Loop",
    "ClosePath",
    "CreateMinInterval",
    "CreateMaxInterval",
    "RotateSpeed",
    "BeginAlpha",
    "AlphaChangeSpeed",
    "BeginScale",
    "ScaleSpeed",
    "MaxTime",
    "MaxWave"
  },
  [5] = {
    "photo",
    "destcontrol",
    "effecttarget",
    "offset_x",
    "offset_y",
    "effecttime",
    "width",
    "height"
  },
  [6] = {},
  [7] = {},
  [8] = {
    "srccontrol",
    "destcontrol",
    "effectsrctarget",
    "effectdesttarget",
    "color",
    "AnimationImage",
    "SmoothPath",
    "Loop",
    "ClosePath",
    "CreateMinInterval",
    "CreateMaxInterval",
    "RotateSpeed",
    "BeginAlpha",
    "AlphaChangeSpeed",
    "BeginScale",
    "ScaleSpeed",
    "MaxTime",
    "MaxWave"
  }
}
effect_lst = {}
local gem_effect_ini = "ini\\ui\\puzzlequest\\effect_data.ini"
function init_gem_effet_data()
  local ini = nx_execute("util_functions", "get_ini", gem_effect_ini)
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_count = ini:GetSectionCount()
  for i = 0, sec_count - 1 do
    local sect = ini:GetSectionByIndex(i)
    local effecttype = ini:ReadInteger(i, "effecttype", 0)
    if effecttype == 1 or effecttype == 2 or effecttype == 3 or effecttype == 4 or effecttype == 5 or effecttype == 8 then
      local effect_info = {
        effecttype = 0,
        list = {}
      }
      effect_info.effecttype = effecttype
      for j = 1, table.getn(effect_content[effecttype]) do
        local key = effect_content[effecttype][j]
        effect_info.list[key] = ini:ReadString(i, key, "")
      end
      effect_lst[nx_number(sect)] = effect_info
    elseif effecttype == 6 then
      local effect_info = {
        effecttype = 0,
        list = {},
        color = "",
        offset_x = 0,
        offset_y = 0,
        destcontrol = "",
        effecttarget = 0,
        AnimationImage = "gui\\animations\\path_effect\\star.dds",
        SmoothPath = 1,
        Loop = 0,
        ClosePath = 0,
        CreateMinInterval = 5,
        CreateMaxInterval = 10,
        RotateSpeed = 4,
        BeginAlpha = 0.8,
        AlphaChangeSpeed = 0.3,
        BeginScale = 0.4,
        ScaleSpeed = 0,
        MaxTime = 1000,
        MaxWave = 0.05
      }
      effect_info.effecttype = effecttype
      local line_count = ini:ReadInteger(i, "line_count", 0)
      effect_info.color = ini:ReadString(i, "color", "")
      effect_info.offset_x = ini:ReadInteger(i, "offset_x", 0)
      effect_info.offset_y = ini:ReadInteger(i, "offset_y", 0)
      effect_info.destcontrol = ini:ReadString(i, "destcontrol", "")
      effect_info.effecttarget = ini:ReadInteger(i, "effecttarget", 0)
      effect_info.AnimationImage = ini:ReadString(i, "AnimationImage", "gui\\animations\\path_effect\\star.dds")
      effect_info.SmoothPath = ini:ReadInteger(i, "SmoothPath", 1)
      effect_info.Loop = ini:ReadInteger(i, "Loop", 0)
      effect_info.ClosePath = ini:ReadInteger(i, "ClosePath", 0)
      effect_info.CreateMinInterval = ini:ReadInteger(i, "CreateMinInterval", 5)
      effect_info.CreateMaxInterval = ini:ReadString(i, "CreateMaxInterval", 10)
      effect_info.RotateSpeed = ini:ReadFloat(i, "RotateSpeed", 4)
      effect_info.BeginAlpha = ini:ReadFloat(i, "BeginAlpha", 0.8)
      effect_info.AlphaChangeSpeed = ini:ReadFloat(i, "AlphaChangeSpeed", 0.3)
      effect_info.BeginScale = ini:ReadFloat(i, "BeginScale", 0.4)
      effect_info.ScaleSpeed = ini:ReadFloat(i, "BeginScale", 0)
      effect_info.MaxTime = ini:ReadInteger(i, "BeginScale", 1000)
      effect_info.MaxWave = ini:ReadFloat(i, "BeginScale", 0.05)
      for p = 1, line_count do
        local line_info_count = ini:ReadInteger(i, nx_string(p) .. "_count", 0)
        local line_info_list = {}
        for q = 1, line_info_count do
          local line_info = {posx = 0, posy = 0}
          line_info.posx = ini:ReadInteger(i, nx_string(p) .. "_" .. nx_string(q) .. "_posx", 0)
          line_info.posy = ini:ReadInteger(i, nx_string(p) .. "_" .. nx_string(q) .. "_posy", 0)
          line_info_list[q] = line_info
        end
        effect_info.list[p] = line_info_list
      end
      effect_lst[nx_number(sect)] = effect_info
    elseif effecttype == 7 then
      local effect_info = {
        effecttype = 0,
        list = {},
        subeffectcount = 0,
        counttype = 0
      }
      effect_info.effecttype = effecttype
      effect_info.subeffectcount = ini:ReadInteger(i, "subeffectcount", 0)
      effect_info.counttype = ini:ReadInteger(i, "counttype", 0)
      for t = 1, effect_info.subeffectcount do
        local one_effect_info = {subeffect = 0, subeffecttime = 0}
        one_effect_info.subeffect = ini:ReadInteger(i, "subeffect" .. nx_string(t), 0)
        one_effect_info.subeffecttime = ini:ReadInteger(i, "subeffecttime" .. nx_string(t), 0)
        effect_info.list[t] = one_effect_info
      end
      effect_lst[nx_number(sect)] = effect_info
    end
  end
end
function get_game_custom_effect_type(effect_id)
  if effect_lst[nx_number(effect_id)] == nil then
    return 0
  end
  return effect_lst[nx_number(effect_id)].effecttype
end
function get_game_custom_effect_count(effect_id)
  if effect_lst[nx_number(effect_id)] == nil then
    return 0
  end
  if effect_lst[nx_number(effect_id)].effecttype ~= 7 then
    return 1
  end
  if effect_lst[nx_number(effect_id)].counttype == 1 then
    return effect_lst[nx_number(effect_id)].subeffectcount
  else
    return 1
  end
end
function get_fill_ball_pos()
  local effect_jingmai = nx_value("EffectJingMai")
  if not nx_is_valid(effect_jingmai) then
    return 0, 0
  end
  local pos = effect_jingmai:GetBall2DPos(0, 0)
  if pos[1] == nil then
    pos[1] = 0
  end
  if pos[2] == nil then
    pos[2] = 0
  end
  return pos[1], pos[2]
end
local jimgmai_conver = {
  [1] = 1,
  [2] = 2,
  [3] = 3,
  [4] = 4,
  [5] = 5,
  [6] = 0,
  [7] = 6,
  [8] = 7
}
function get_break_ball_pos(index)
  local effect_jingmai = nx_value("EffectJingMai")
  if not nx_is_valid(effect_jingmai) then
    return 0, 0
  end
  if jimgmai_conver[index] == nil then
    return 0, 0
  end
  if jimgmai_conver[index] == 0 then
    return 0, 0
  end
  local form = nx_value("form_stage_main\\puzzle_quest\\form_jingmai")
  local final_index = jimgmai_conver[index]
  local flag = nx_custom(form, "break_full" .. nx_string(final_index))
  if flag then
    final_index = 8
  end
  local pos = effect_jingmai:GetBall2DPos(1, final_index - 1)
  if pos[1] == nil then
    pos[1] = 0
  end
  if pos[2] == nil then
    pos[2] = 0
  end
  return pos[1], pos[2]
end
