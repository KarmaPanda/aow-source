require("util_functions")
g_menu_id = {
  task_accept = 100,
  task_submit = 200,
  task_giveup = 300,
  task_share = 400,
  task_doing = 500,
  task_leave = 600,
  task_uncomplete = 700,
  task_max = 800,
  task_type = 100000000,
  base = 1000000,
  leave = 600000000,
  func = 500000,
  func_talk = 802,
  func_talk_hide_task = 803,
  func_fight = 804,
  func_shop = 805,
  func_life = 806,
  func_storage = 807,
  func_guild = 809,
  func_relive = 811,
  func_school_war = 846,
  func_free_talk = 860,
  func_tiguan = 878,
  func_home_point = 881000001,
  func_tiaozhan = 882,
  func_menu_shop = 805000000,
  func_menu_fuse = 806000008,
  func_menu_split = 806000009,
  func_menu_depot = 807000000,
  func_menu_marry_collect = 851000001,
  func_menu_marry_confirmdate = 851000005,
  func_menu_shop_single = 861000000,
  func_menu_dazaotai_fuse = 899000052
}
g_task_line = {
  "ui_task_zhuanj",
  "ui_task_wux",
  "ui_task_shengh",
  "ui_task_menp",
  "ui_task_jiangh",
  "ui_task_jind",
  "ui_task_eny",
  "ui_task_qiy",
  "ui_task_yind"
}
local title_talk = ""
local title_talk_id = ""
local menu_task_main = ""
local menu_task_wuxue = ""
local menu_task_shenghuo = ""
local menu_task_menpai = ""
local menu_task_side = ""
local menu_task_clone = ""
local menu_task_enyuan = ""
local menu_task_adventure = ""
local menu_register = ""
local menu_shop = ""
local menu_job = ""
local menu_free_talk = ""
local menu_leave = ""
local menu_other = ""
function talk_data_reset_menu_title()
  title_talk = ""
  title_talk_id = ""
  menu_task_main = ""
  menu_task_wuxue = ""
  menu_task_shenghuo = ""
  menu_task_menpai = ""
  menu_task_side = ""
  menu_task_clone = ""
  menu_task_enyuan = ""
  menu_task_adventure = ""
  menu_register = ""
  menu_shop = ""
  menu_job = ""
  menu_free_talk = ""
  menu_leave = ""
  menu_other = ""
end
function talk_data_add_save_menu(func_id, descid)
  local flag = nx_int(func_id / g_menu_id.base)
  if flag == nx_int(g_menu_id.task_leave) then
    menu_leave = talk_data_add_menu_to_string(menu_leave, func_id, descid)
    return
  elseif flag == nx_int(g_menu_id.func_shop) then
    menu_shop = talk_data_add_menu_to_string(menu_shop, func_id, descid)
    return
  elseif flag >= nx_int(g_menu_id.task_accept) and flag <= nx_int(g_menu_id.task_max) then
    menu_task_main = talk_data_add_menu_to_string(menu_task_main, func_id, descid)
  elseif flag == nx_int(g_menu_id.func_school_war) or flag == nx_int(g_menu_id.func_tiguan) then
    menu_register = talk_data_add_menu_to_string(menu_register, func_id, descid)
    return
  elseif flag == nx_int(g_menu_id.func_life) then
    menu_job = talk_data_add_menu_to_string(menu_job, func_id, descid)
    return
  elseif flag == nx_int(g_menu_id.func_free_talk) then
    menu_free_talk = talk_data_add_menu_to_string(menu_free_talk, func_id, descid)
    return
  else
    menu_other = talk_data_add_menu_to_string(menu_other, func_id, descid)
    return
  end
end
function talk_data_add_menu_to_string(menu, func_id, descid)
  local temp_menu = ""
  if nx_string(menu) == nx_string("") then
    temp_menu = nx_widestr(func_id) .. nx_widestr("`") .. nx_widestr(descid)
  else
    temp_menu = nx_widestr(menu) .. nx_widestr("|") .. nx_widestr(func_id) .. nx_widestr("`") .. nx_widestr(descid)
  end
  return temp_menu
end
function talk_data_merge_menu()
  local menu = ""
  menu = talk_data_link_string(menu, menu_task_main)
  menu = talk_data_link_string(menu, menu_register)
  menu = talk_data_link_string(menu, menu_shop)
  menu = talk_data_link_string(menu, menu_job)
  menu = talk_data_link_string(menu, menu_free_talk)
  menu = talk_data_link_string(menu, menu_other)
  menu = talk_data_link_string(menu, menu_leave)
  return menu
end
function talk_data_link_string(src_str, str)
  local temp_str = src_str
  if nx_string(str) == nx_string("") then
    return temp_str
  end
  if nx_string(src_str) == nx_string("") then
    temp_str = nx_widestr(str)
  else
    temp_str = nx_widestr(temp_str) .. nx_widestr("|") .. nx_widestr(str)
  end
  return temp_str
end
function on_beginmenu()
  talk_data_reset_menu_title()
end
function on_addtitle(string_id, ...)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 0
  end
  gui.TextManager:Format_SetIDName(string_id)
  for i, para in pairs(arg) do
    if type(i) == "string" then
      break
    end
    if type(para) == "number" then
      gui.TextManager:Format_AddParam(nx_int(para))
    else
      gui.TextManager:Format_AddParam(para)
    end
  end
  local player_name = player:QueryProp("Name")
  gui.TextManager:Format_AddParam(player_name)
  local info = gui.TextManager:Format_GetText()
  title_talk_id = string_id
  title_talk = info
end
function on_addmenu(func_id, string_id, ...)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(string_id)
  for i, para in pairs(arg) do
    if type(para) == "number" then
      gui.TextManager:Format_AddParam(nx_int(para))
    else
      gui.TextManager:Format_AddParam(para)
    end
  end
  local info = gui.TextManager:Format_GetText()
  talk_data_add_save_menu(func_id, info)
end
function on_endmenu(target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_target = game_client:GetSceneObj(nx_string(target))
  if not nx_is_valid(client_target) then
    return 0
  end
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    return
  end
  local talktype = client_target:QueryProp("NpcTalkType")
  local form_talk = "form_stage_main\\form_talk_movie"
  if nx_int(talktype) == nx_int(1) then
    form_talk = "form_stage_main\\form_talk"
  end
  local menu = talk_data_merge_menu()
  nx_execute(form_talk, "show_window", nx_string(target), title_talk_id, title_talk, menu)
end
function on_closemenu()
  local form_talk = "form_stage_main\\form_talk_movie"
  local form = nx_value(form_talk)
  if nx_is_valid(form) and form.Visible then
    form:Close()
  end
  form_talk = "form_stage_main\\form_talk"
  form = nil
  form = nx_value(form_talk)
  if nx_is_valid(form) and form.Visible then
    form:Close()
  end
end
function on_show_accept_form(...)
  local target = arg[1]
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_target = game_client:GetSceneObj(nx_string(target))
  if not nx_is_valid(client_target) then
    return 0
  end
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    return
  end
  local talktype = client_target:QueryProp("NpcTalkType")
  local form_talk = "form_stage_main\\form_talk_movie"
  if nx_int(talktype) == nx_int(1) then
    form_talk = "form_stage_main\\form_talk"
  end
  nx_execute(form_talk, "show_accept_form", unpack(arg))
end
function on_show_submit_form(...)
  local target = arg[1]
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_target = game_client:GetSceneObj(nx_string(target))
  if not nx_is_valid(client_target) then
    return 0
  end
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    return
  end
  local talktype = client_target:QueryProp("NpcTalkType")
  local form_talk = "form_stage_main\\form_talk_movie"
  if nx_int(talktype) == nx_int(1) then
    form_talk = "form_stage_main\\form_talk"
  end
  nx_execute(form_talk, "show_submit_form", unpack(arg))
end
function on_show_task_uncomplete_info(...)
  local npc = arg[1]
  local task_id = arg[2]
  local menu_str = arg[3]
end
function on_show_share_form(task_id, task_title, sharer_name)
  nx_execute("form_stage_main\\form_talk_share", "show_window", task_id, task_title, sharer_name)
end
