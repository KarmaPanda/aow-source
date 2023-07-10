require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("util_functions")
APPEND_TYPE_0 = 0
APPEND_TYPE_1 = 1
APPEND_TYPE_2 = 2
APPEND_TYPE_3 = 3
APPEND_TYPE_4 = 4
APPEND_TYPE_5 = 5
function load_cdt_data(cg_id, cdt_id, append_id, append_sub_id, ...)
  local gui = nx_value("gui")
  local cdt_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_CDT_INI)
  local sharecgini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  local append_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_APPEND_CDT_INI)
  if not (nx_is_valid(cdt_ini) and nx_is_valid(sharecgini)) or not nx_is_valid(append_ini) then
    return 0
  end
  local finish_cdts = nx_call("util_gui", "get_global_arraylist", "tiguan_finish_cdts")
  finish_cdts:ClearChild()
  finish_cdts.cg_id = nx_number(cg_id)
  finish_cdts.random_type = -1
  finish_cdts.random_num = 0
  finish_cdts.random_identifier = ""
  finish_cdts.random_have = 0
  local index = append_ini:FindSectionIndex(nx_string(nx_int(append_id)))
  if 0 <= index then
    local append_tab = append_ini:GetItemValueList(index, "r")
    if nx_number(append_sub_id) < table.getn(append_tab) then
      local append_info = util_split_string(nx_string(append_tab[nx_int(append_sub_id) + 1]), ",")
      if table.getn(append_info) == 5 then
        finish_cdts.random_type = nx_number(append_info[1])
        finish_cdts.random_num = nx_number(append_info[2])
        finish_cdts.random_identifier = nx_string(append_info[3])
      end
    end
  end
  finish_cdts.star_time = nx_function("ext_get_tickcount")
  local index = sharecgini:FindSectionIndex(nx_string(cg_id))
  if index < 0 then
    return 0
  end
  finish_cdts.successclosetime = sharecgini:ReadString(index, "SuccessCloseTime", "")
  finish_cdts.failedclosetime = sharecgini:ReadString(index, "FailedCloseTime", "")
  local index = cdt_ini:FindSectionIndex(nx_string(cdt_id))
  if index < 0 then
    return 0
  end
  local cdt_tab = cdt_ini:GetItemValueList(index, "r")
  for i = 1, table.getn(cdt_tab) do
    local info_tab = util_split_string(nx_string(cdt_tab[i]), ",")
    if table.getn(info_tab) < 6 then
      break
    end
    if table.getn(info_tab) ~= 9 or nx_number(info_tab[9]) == 0 then
      local child = finish_cdts:CreateChild(nx_string(i))
      if nx_is_valid(child) then
        child.uiID = "ui_tiguan_cdtdesc_" .. nx_string(cdt_id) .. "_" .. nx_string(i)
        child.have = "0"
        child.need = nx_string(info_tab[3])
        child.ismust = nx_string(info_tab[4])
        child.faculty = nx_string(info_tab[5])
        child.repute = nx_string(info_tab[6])
        child.cdt_id = nx_number(cdt_id)
      end
    end
  end
end
function show_cdt_data()
  local finish_cdts = nx_value("tiguan_finish_cdts")
  if not nx_is_valid(finish_cdts) or finish_cdts:GetChildCount() < 1 then
    return 0
  end
  local cdt_tab = finish_cdts:GetChildList()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local all_desc = nx_widestr("")
  local title_desc = gui.TextManager:GetText("ui_tiguan_cdt_must")
  all_desc = all_desc .. title_desc
  for i = 1, table.getn(cdt_tab) do
    local child = cdt_tab[i]
    if nx_number(child.ismust) == 1 then
      local cdt_desc = nx_widestr(" ")
      if nx_number(child.have) >= nx_number(child.need) then
        cdt_desc = cdt_desc .. gui.TextManager:GetFormatText(child.uiID, "#ffcc00") .. nx_widestr("<font color=\"#ffcc00\">") .. nx_widestr("(") .. nx_widestr(child.have) .. nx_widestr("/") .. nx_widestr(child.need) .. nx_widestr(")") .. nx_widestr("</font>")
      else
        cdt_desc = cdt_desc .. gui.TextManager:GetFormatText(child.uiID, "#ffffff") .. nx_widestr("<font color=\"#ffffff\">") .. nx_widestr("(") .. nx_widestr(child.have) .. nx_widestr("/") .. nx_widestr(child.need) .. nx_widestr(")") .. nx_widestr("</font>")
      end
      all_desc = all_desc .. nx_widestr("<br>") .. cdt_desc
    end
  end
  title_desc = gui.TextManager:GetText("ui_tiguan_cdt_optional")
  all_desc = all_desc .. nx_widestr("<br>") .. title_desc
  for i = 1, table.getn(cdt_tab) do
    local child = cdt_tab[i]
    if nx_number(child.ismust) ~= 1 then
      local cdt_desc = nx_widestr(" ")
      if nx_number(child.have) >= nx_number(child.need) then
        cdt_desc = cdt_desc .. gui.TextManager:GetFormatText(child.uiID, "#ffcc00") .. nx_widestr("<font color=\"#ffcc00\">") .. nx_widestr("(") .. nx_widestr(child.have) .. nx_widestr("/") .. nx_widestr(child.need) .. nx_widestr(")") .. nx_widestr("</font>")
      else
        cdt_desc = cdt_desc .. gui.TextManager:GetFormatText(child.uiID, "#ffffff") .. nx_widestr("<font color=\"#ffffff\">") .. nx_widestr("(") .. nx_widestr(child.have) .. nx_widestr("/") .. nx_widestr(child.need) .. nx_widestr(")") .. nx_widestr("</font>")
      end
      all_desc = all_desc .. nx_widestr("<br>") .. cdt_desc
    end
  end
  title_desc = gui.TextManager:GetText("ui_tiguan_random_challenge")
  all_desc = all_desc .. nx_widestr("<br>") .. title_desc
  if finish_cdts.random_type ~= -1 then
    local random_desc = nx_widestr(" ")
    local random_type = nx_number(finish_cdts.random_type)
    local random_num = nx_number(finish_cdts.random_num)
    if random_type == APPEND_TYPE_3 then
      random_num = nx_int(random_num / 60)
    end
    local random_identifier = finish_cdts.random_identifier
    local ui_str = "ui_tiguan_random_challenge" .. "_" .. nx_string(nx_int(random_type))
    if random_identifier == nil or random_identifier == "" then
      random_desc = random_desc .. gui.TextManager:GetFormatText(ui_str, nx_int(random_num))
    else
      random_identifier = gui.TextManager:GetText(random_identifier)
      random_desc = random_desc .. gui.TextManager:GetFormatText(ui_str, nx_int(random_num), random_identifier)
    end
    if random_type == APPEND_TYPE_0 or random_type == APPEND_TYPE_1 or random_type == APPEND_TYPE_2 or random_type == APPEND_TYPE_4 then
      random_desc = random_desc .. nx_widestr("(") .. nx_widestr(finish_cdts.random_have) .. nx_widestr("/") .. nx_widestr(finish_cdts.random_num) .. nx_widestr(")")
    end
    all_desc = all_desc .. nx_widestr("<br>") .. random_desc
  end
  title_desc = gui.TextManager:GetText("ui_tiguan_infor")
  all_desc = all_desc .. nx_widestr("<br>") .. title_desc
  for i = 1, table.getn(cdt_tab) do
    local child = cdt_tab[i]
    if nx_number(child.ismust) == 1 then
      local boss_place = nx_widestr(" ") .. gui.TextManager:GetText("ui_tiguan_place_" .. nx_string(child.cdt_id))
      all_desc = all_desc .. nx_widestr("<br>") .. boss_place
    end
  end
  nx_execute("form_stage_main\\form_common_notice", "NotifyText", 5, all_desc)
end
function refresh_data(type, ...)
  local finish_cdts = nx_value("tiguan_finish_cdts")
  if not nx_is_valid(finish_cdts) then
    return 0
  end
  if nx_number(type) == FINISH_CDT_REFRESH_BASE or nx_number(type) == FINISH_CDT_REFRESH_BASE_CONTINUE then
    if table.getn(arg) < 2 then
      return 0
    end
    local child = finish_cdts:GetChild(nx_string(nx_number(arg[1]) + 1))
    if not nx_is_valid(child) then
      return 0
    end
    child.have = nx_number(arg[2])
    if nx_number(child.have) > nx_number(child.need) then
      child.have = child.need
    end
  elseif nx_number(type) == FINISH_CDT_REFRESH_APPEND or nx_number(type) == FINISH_CDT_REFRESH_APPEND_CONTINUE then
    if table.getn(arg) < 1 then
      return 0
    end
    finish_cdts.random_have = nx_number(arg[1])
    if nx_number(finish_cdts.random_have) > nx_number(finish_cdts.random_num) then
      finish_cdts.random_have = finish_cdts.random_num
    end
  end
end
function show_tiguan_cdts(type, ...)
  if nx_number(type) == FINISH_CDT_OPEN then
    load_cdt_data(unpack(arg))
    show_cdt_data()
  elseif nx_number(type) == FINISH_CDT_REFRESH_BASE then
    refresh_data(type, unpack(arg))
    show_cdt_data()
  elseif nx_number(type) == FINISH_CDT_REFRESH_APPEND then
    refresh_data(type, unpack(arg))
    show_cdt_data()
  elseif nx_number(type) == FINISH_CDT_OPEN_CONTINUE then
    load_cdt_data(unpack(arg))
  elseif nx_number(type) == FINISH_CDT_REFRESH_BASE_CONTINUE then
    refresh_data(type, unpack(arg))
  elseif nx_number(type) == FINISH_CDT_REFRESH_APPEND_CONTINUE then
    refresh_data(type, unpack(arg))
  elseif nx_number(type) == FINISH_CDT_CLOSE then
    nx_execute("form_stage_main\\form_common_notice", "ClearText", 5)
    local tiguan_finish_cdts = nx_value("tiguan_finish_cdts")
    if nx_is_valid(tiguan_finish_cdts) then
      nx_destroy(tiguan_finish_cdts)
    end
  end
end
function close_form()
  local finish_cdts = nx_call("util_gui", "get_global_arraylist", "tiguan_finish_cdts")
  if nx_is_valid(finish_cdts) then
    finish_cdts:ClearChild()
  end
end
function open_tiguan_trace()
  show_cdt_data()
  nx_execute("form_stage_main\\form_tiguan\\form_tiguan_ds_trace", "open_ds_trace")
end
function show_day_random_fight(type, base_val, cur_val, cur_val2)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local tiguan_manager = nx_value("tiguan_manager")
  if not nx_is_valid(tiguan_manager) then
    return 0
  end
  local TVT_TG_RANDOM_FIGHT = 55
  local all_desc = nx_widestr("")
  local guan_name = "daily_guan"
  for i = 0, 63 do
    if tiguan_manager:CheckBitFlag(base_val, i) == 1 then
      if all_desc ~= nx_widestr("") then
        all_desc = all_desc .. nx_widestr("<br>")
      end
      local guan_name = gui.TextManager:GetText("daily_guan" .. nx_string(i))
      local finish = tiguan_manager:CheckBitFlag(cur_val, i) + tiguan_manager:CheckBitFlag(cur_val2, i)
      if 1 < nx_number(finish) then
        all_desc = all_desc .. gui.TextManager:GetFormatText("ui_tiguan_random_fight1", guan_name, nx_widestr(finish))
      else
        all_desc = all_desc .. gui.TextManager:GetFormatText("ui_tiguan_random_fight2", guan_name, nx_widestr(finish))
      end
    end
  end
  nx_execute("form_stage_main\\form_single_notice", "NotifyText", TVT_TG_RANDOM_FIGHT, all_desc)
end
