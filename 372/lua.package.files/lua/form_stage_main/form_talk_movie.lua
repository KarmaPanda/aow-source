require("util_gui")
require("form_stage_main\\form_task\\task_define")
require("form_stage_main\\form_talk_data")
require("define\\object_type_define")
require("control_set")
require("share\\chat_define")
require("util_role_prop")
local task_util = "form_stage_main\\form_task\\task_util"
local form_name = "form_stage_main\\form_talk_movie"
local around_obj_table = {}
local trace_hide_obj_table = {}
local table_task_npc = {}
local menu_num_table = {}
local GAME_CAMERA_NORMAL = 0
local GAME_CAMERA_STORY = 2
local TALK_CAMERA_DISTANCE = 2
local MAX_DISTANCE = 10
local CLOSE_TYPE_0 = 0
local CLOSE_TYPE_1 = 1
local CAMERA_ANGLE_X, CAMERA_ANGLE_Y, CAMERA_DISTANCE, NPC_POS_X, NPC_POS_Z
local SHOWHEAD_HP = 1
local SHOWHEAD_INFO = 1
local SHOWQG_INFO = 1
local npc_talk_action = {stand = "ty_talk1"}
local repute_name_table = {
  repute_jianghu = "ui_talk_movie_jianghu",
  repute_shaolin = "ui_talk_movie_shaolin",
  repute_wudang = "ui_talk_movie_wudang",
  repute_emei = "ui_talk_movie_emei",
  repute_gaibang = "ui_talk_movie_gaibang",
  repute_junzitang = "ui_talk_movie_junzi",
  repute_tangmen = "ui_talk_movie_tangmen",
  repute_jinyiwei = "ui_talk_movie_jinyi",
  repute_jilegu = "ui_talk_movie_jile",
  repute_chaoting = ""
}
local school_npc_id = {
  FuncNpc01608 = "school_wudang",
  FuncNpc00728 = "school_shaolin",
  FuncNpc01114 = "school_emei",
  FuncNpc01203 = "school_gaibang",
  FuncNpc01020 = "school_tangmen",
  FuncNpc01307 = "school_junzitang",
  FuncNpc01505 = "school_jinyiwei",
  FuncNpc01404 = "school_jilegu",
  newmp_mjzyb_001 = "school_mingjiao",
  newmp_tszyb_001 = "school_tianshan"
}
local npc_y_offset = {npc_dreamtask_001 = -0.5}
function main_form_init(form)
  form.Fixed = true
  form.acceptMoney = 0
  form.deductLuck = 0
  form.taskid = 0
  form.npcid = ""
  form.singleselect = 0
  form.ischoose = 0
  form.issubmit = 0
  form.close_type = 0
  form.condition_level = 0
  form.condition_tips = ""
  form.menu_page = 1
  form.menus = nx_widestr("")
  form.npcobj = nil
  form.tiaozhan = nil
  form.no_need_motion_alpha = true
  return 1
end
function on_main_form_open(form)
  clear_select_light_or_corlor(form)
  clear_hide_obj_table()
  hide_control_desktop()
  set_camra_movie(form)
  start_ppdof_effect()
  hide_around_obj()
  hide_head_info()
  start_check_pos(form)
  remove_task_effect()
  remove_life_effect()
  show_npc_worldview_page(form)
  set_talk_movie(true)
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:HideTips("0-0")
  end
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  local max_count = {
    "5",
    "10",
    "15",
    "20",
    "25"
  }
  for i = 1, table.getn(max_count) do
    nx_execute("form_stage_main\\form_single_notice", "remove_item", 2, 49, "count_question_" .. nx_string(max_count[i]))
  end
  nx_execute("form_stage_main\\form_single_notice", "remove_item", 2, 49, "count_question_current")
  nx_execute("form_stage_main\\form_main\\form_main_team", "update_team_panel")
  local form_equipblend = nx_value("form_stage_main\\form_equipblend")
  if nx_is_valid(form_equipblend) then
    form_equipblend:Close()
  end
  reset_select_light_or_corlor(form)
  show_control_desktop()
  if form.close_type == CLOSE_TYPE_0 then
    set_camra_normal(form)
  end
  cancel_ppdof_effect()
  show_around_obj()
  show_head_info()
  stop_check_pos(form)
  reset_life_effect()
  reset_task_effect()
  reset_npc_groupbox_karma(form.npcid)
  if nx_is_valid(form.talk_moive_page) then
    form.talk_moive_page:Close()
  end
  request_npc_restart_ai(form.npcid)
  form.Visible = false
  clear_hide_obj_table()
  set_talk_movie(false)
  clear_data(form)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_itemskill", "shortcut_itemskill_view")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_buff_common", "shortcut_buff_common_view")
  return 1
end
function form_close(close_type)
  local form = nx_value("form_stage_main\\form_talk_movie")
  if not nx_is_valid(form) then
    return
  end
  if close_type == nil then
    close_type = 0
  end
  form.close_type = close_type
  form:Close()
end
function show_window(npcid, title_id, title, menu)
  local form = nx_execute("util_gui", "util_get_form", form_name, true)
  if not nx_is_valid(form) then
    return
  end
  clear_data(form)
  init_controls(form)
  form.npcid = nx_string(npcid)
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:PlaySoundByFile(title_id, form.npcid)
  end
  if update_menu_control(form, menu) then
    if is_new_world_scene() then
      show_old_talk(form, false)
      show_new_talk(form, true)
      set_talk_pos()
      update_talk(form, npcid, title, menu)
      form:Show()
      return
    else
      show_old_talk(form, true)
      show_new_talk(form, false)
    end
    add_title(title)
    update_func_button(form, menu)
    form:Show()
    play_talk_action(npcid)
  else
    request_npc_restart_ai(npcid)
    if nx_string(title_id) ~= nx_string(title) then
      show_chat_text_onhead(npcid, title)
    end
  end
end
function on_form_shop_open()
end
function on_form_shop_close()
end
function show_npc_worldview_page(form)
  local npc_worldview_page = nx_value("form_stage_main\\form_talk_npc_worldview")
  if not nx_is_valid(npc_worldview_page) then
    npc_worldview_page = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_talk_npc_worldview", true)
  end
  if not nx_is_valid(npc_worldview_page) then
    return
  end
  local ret = form:Add(npc_worldview_page)
  nx_execute("form_stage_main\\form_talk_npc_worldview", "init_info", form.npcid, npc_worldview_page)
  form.talk_moive_page = npc_worldview_page
  form.talk_moive_page.Left = form.Width - form.talk_moive_page.Width - 20
  form.talk_moive_page.Top = 0
  form:ToFront(form.talk_moive_page)
end
function add_title(text_title)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_title:Clear()
  form.mltbox_title.HtmlText = nx_widestr("<center><font color=\"#FFFFFF\"></font>") .. nx_widestr(text_title) .. nx_widestr("</center>")
  fresh_title_control(form)
end
function end_menu(npcid, title, menu)
end
function update_menu_control(form, menu)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local menu_control = form.mltbox_menu
  menu_control:Clear()
  form.menus = menu
  local height = gui.Height
  local height_groupbox = menu_control.LineHeight * 4
  local page = form.menu_page
  local cur_menu_num = 0
  for i = 1, table.getn(menu_num_table) do
    if nx_int(i) >= nx_int(page) then
      break
    end
    cur_menu_num = cur_menu_num + menu_num_table[i]
  end
  local menu_table = util_split_wstring(nx_widestr(menu), nx_widestr("|"))
  local menu_num = table.getn(menu_table)
  local strat_num = cur_menu_num + 1
  local num = 0
  local temp_num = 0
  for i = strat_num, menu_num do
    if 4 <= num then
      break
    end
    local menu_sub_table = util_split_wstring(menu_table[i], "`")
    if table.getn(menu_sub_table) == 2 then
      local func_id = nx_int(menu_sub_table[1])
      local test_desc_id = menu_sub_table[2]
      if not is_func_btn_menu(func_id) then
        local photo = get_photo_form_funcid(func_id)
        local text_menu = nx_widestr(photo) .. nx_widestr(" ")
        if gui.TextManager:IsIDName(nx_string(test_desc_id)) then
          text_menu = text_menu .. gui.TextManager:GetText(nx_string(test_desc_id))
        else
          text_menu = text_menu .. nx_widestr(menu_sub_table[2])
        end
        menu_index = menu_control:AddHtmlText(text_menu, func_id)
        if height_groupbox < menu_control:GetContentHeight() and 0 < num then
          menu_control:DelHtmlItem(menu_index)
          break
        end
        num = num + 1
      end
      temp_num = temp_num + 1
    end
  end
  if page > table.getn(menu_num_table) then
    table.insert(menu_num_table, temp_num)
  else
    menu_num_table[page] = temp_num
  end
  if nx_int(menu_num) == nx_int(0) then
    return false
  elseif nx_int(menu_num) == nx_int(1) then
    local funcid = menu_control:GetItemKeyByIndex(0)
    local have_story = nx_execute("form_stage_main\\form_talk_npc_worldview", "is_have_story", form.npcid)
    if not form.Visible and nx_int(funcid) == nx_int(g_menu_id.leave) and not have_story then
      return false
    end
  end
  fresh_page_btn(form, form.menu_page, cur_menu_num + temp_num, menu_num)
  return true
end
function update_func_button(form, menu)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local menu_table = util_split_wstring(nx_widestr(menu), nx_widestr("|"))
  local menu_num = table.getn(menu_table)
  local groupbox_func = form.groupbox_func
  local num = 0
  for i = 1, menu_num do
    local menu_sub_table = util_split_wstring(menu_table[i], nx_widestr("`"))
    if table.getn(menu_sub_table) == 2 then
      local func_id = nx_int(menu_sub_table[1])
      local test_desc_id = nx_string(menu_sub_table[2])
      if is_func_btn_menu(func_id) then
        num = num + 1
        local btn = groupbox_func:Find("btn_func_" .. nx_string(num))
        if nx_is_valid(btn) then
          btn.Visible = true
          if gui.TextManager:IsIDName(test_desc_id) then
            btn.Text = gui.TextManager:GetText(test_desc_id)
          else
            btn.Text = menu_sub_table[2]
          end
          btn.func_id = func_id
        end
      end
    end
  end
  if 0 < num then
    groupbox_func.Visible = true
  end
end
function is_func_btn_menu(menu_id)
  if nx_int(menu_id) == nx_int(g_menu_id.func_menu_shop) or nx_int(menu_id) == nx_int(g_menu_id.func_menu_fuse) or nx_int(menu_id) == nx_int(g_menu_id.func_menu_split) or nx_int(menu_id) == nx_int(g_menu_id.func_menu_depot) or nx_int(menu_id) == nx_int(g_menu_id.func_menu_marry_collect) or nx_int(menu_id) == nx_int(g_menu_id.func_menu_marry_confirmdate) or nx_int(menu_id) == nx_int(g_menu_id.func_menu_dazaotai_fuse) or nx_int(menu_id) == nx_int(g_menu_id.func_menu_shop_single) then
    return true
  end
  return false
end
function on_menu_select(menu, index)
  local funcid = menu:GetItemKeyByIndex(index)
  if is_add_school(funcid) then
    return
  end
  menu_select(funcid)
end
function on_btn_func_click(btn)
  if not nx_find_custom(btn, "func_id") then
    return
  end
  local funcid = btn.func_id
  menu_select(funcid)
end
function menu_select(funcid)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local flag = nx_int(funcid / g_menu_id.base)
  if flag == nx_int(g_menu_id.func_tiaozhan) then
    local path = "form_stage_main\\form_task\\form_tiaozhan"
    util_show_form(path, true)
    local cfm = nx_value(path)
    if nx_is_valid(cfm) and cfm.Visible then
      cfm.npc = nx_object(form.npcid)
      cfm.taskid = nx_int(math.mod(funcid, g_menu_id.base))
      cfm.tiaozhan = form.tiaozhan
      nx_execute(path, "show_tiaozhan", cfm, true)
      util_show_form("form_stage_main\\form_talk_movie", false)
      return 0
    end
  end
  if flag >= nx_int(g_menu_id.task_submit) and flag < nx_int(g_menu_id.task_giveup) then
    form.lbl_item.BackImage = ""
    if form.issubmit == 1 and form.ischoose == 1 and form.singleselect == 0 then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("9629"))
      form.lbl_item.BackImage = "BianZhao"
      return 0
    end
    if form.issubmit ~= 1 then
      form.singleselect = 0
    end
    local sigle = form.singleselect
    funcid = funcid + sigle * g_menu_id.base
    local sock = nx_value("game_sock")
    if not nx_is_valid(sock) then
      return 0
    end
    local ident = form.npcid
    sock.Sender:Select(ident, nx_int(funcid))
  else
    if nx_int(funcid) == nx_int(g_menu_id.leave) then
      local head_game = nx_value("HeadGame")
      if nx_is_valid(head_game) then
        head_game:PlaySoundByFile(get_npcconfigid_by_id(form.npcid) .. "_end", form.npcid)
      end
    end
    local acceptmoney = nx_int(form.acceptMoney)
    local isAccept = nx_int(funcid / g_menu_id.task_type) == nx_int(1)
    if isAccept and acceptmoney > nx_int(0) then
      funcid = show_confirm_dialog(form, funcid, 0, acceptmoney)
      form.acceptMoney = 0
    end
    local deductLuck = nx_int(form.deductLuck)
    if isAccept and deductLuck > nx_int(0) then
      funcid = show_confirm_dialog(form, funcid, 1, deductLuck)
      form.deductLuck = 0
    end
    if nx_int(funcid) == nx_int(g_menu_id.func_home_point) and not IsSetHomePoint() then
      return 0
    end
    if isAccept and form.tiaozhan ~= nil and 0 < nx_number(form.tiaozhan) then
      local path = "form_stage_main\\form_task\\form_tiaozhan"
      util_show_form(path, true)
      local cfm = nx_value(path)
      if nx_is_valid(cfm) and cfm.Visible then
        cfm.npc = form.npcobj
        cfm.taskid = nx_int(math.mod(funcid, g_menu_id.base))
        cfm.tiaozhan = form.tiaozhan
        nx_execute(path, "show_tiaozhan", cfm, false)
        util_show_form("form_stage_main\\form_talk_movie", false)
        return 0
      end
    end
    local sock = nx_value("game_sock")
    if not nx_is_valid(sock) then
      return 0
    end
    local ident = form.npcid
    sock.Sender:Select(ident, nx_int(funcid))
  end
end
function get_npcconfigid_by_id(npcid)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_scene_obj = game_client:GetSceneObj(nx_string(npcid))
  local string_id = ""
  if nx_is_valid(client_scene_obj) then
    string_id = client_scene_obj:QueryProp("ConfigID")
  end
  return string_id
end
function show_confirm_dialog(form, funcid, rule_id, value)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(rule_id) == nx_int(0) then
    gui.TextManager:Format_SetIDName("dec_money_accept")
  elseif nx_int(rule_id) == nx_int(1) then
    gui.TextManager:Format_SetIDName("dec_luck_accept")
  end
  gui.TextManager:Format_AddParam(value)
  dialog.mltbox_info.HtmlText = gui.TextManager:Format_GetText()
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    funcid = g_menu_id.leave
  end
  if not nx_is_valid(form) then
    return funcid
  end
  if form.Visible == false then
    return funcid
  end
  return funcid
end
function show_accept_form(...)
  local form = nx_value("form_stage_main\\form_talk_movie")
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 2 then
    return
  end
  local npc = arg[1]
  local info = arg[2]
  if info == nil or info == "" then
    return
  end
  info = util_split_string(info, "|")
  if table.getn(info) < 12 then
    return
  end
  local funcid = info[1]
  local task_id = info[2]
  local titleid = info[3]
  local menuid = info[4]
  local prize_base = info[5]
  local prize_ex = info[6]
  local prize_over = info[7]
  local decMoney = info[8]
  local adventure_plot = info[9]
  local lock_value = info[10]
  local strLimit = info[11]
  local title = info[12]
  local line = info[13]
  local tiaozhan = info[14]
  local gui = nx_value("gui")
  clear_data(form)
  form.npcid = nx_string(npc)
  form.tiaozhan = tiaozhan
  form.npcobj = npc
  local title_text = nx_widestr("") .. gui.TextManager:GetText(title)
  title_text = nx_widestr("<font color=\"#FFB428\">") .. title_text .. nx_widestr("</font>")
  local context_text = nx_execute(task_util, "get_title_task_context", titleid)
  local talk_context = title_text .. nx_widestr("<br>") .. nx_widestr(context_text)
  local flag = nx_int(funcid / g_menu_id.base)
  local strAccept = "task_menu_accept_" .. nx_string(task_id)
  if flag >= nx_int(g_menu_id.task_accept) and flag < nx_int(g_menu_id.task_accept + 100) and menuid == strAccept and not gui.TextManager:IsIDName(nx_string(menuid)) then
    menuid = "ui_form_talk_receive_task"
  end
  if decMoney ~= nil and nx_int(decMoney) > nx_int(0) then
    gui.TextManager:Format_SetIDName("dec_money_accept")
    gui.TextManager:Format_AddParam(nx_int(decMoney))
    talk_context = talk_context .. nx_widestr("<br>") .. gui.TextManager:Format_GetText()
    form.acceptMoney = decMoney
  end
  if adventure_plot ~= nil and nx_int(adventure_plot) > nx_int(0) then
    local isDeductLuck = false
    local game_client = nx_value("game_client")
    local player = game_client:GetPlayer()
    if not nx_is_valid(player) then
      return
    end
    local cdtkmgr = nx_value("ConditionManager")
    if not nx_is_valid(cdtkmgr) then
      return
    end
    local table_limmit_desc = {}
    local table_limit = util_split_string(strLimit, ",")
    for i, limit_id in pairs(table_limit) do
      if not cdtkmgr:CanSatisfyCondition(player, player, nx_int(limit_id)) then
        isDeductLuck = true
        break
      end
    end
    if isDeductLuck then
      form.deductLuck = lock_value
    end
  end
  add_title(talk_context)
  local menu = nx_widestr(funcid) .. nx_widestr("`") .. nx_widestr(menuid) .. nx_widestr("|") .. nx_widestr(g_menu_id.leave) .. nx_widestr("`") .. nx_widestr("ui_form_talk_leave")
  update_menu_control(form, menu)
  init_prize_control(form)
  fill_prize(form, prize_base, prize_ex, prize_over, "")
  fresh_rbtn_text(form, task_id)
end
function show_submit_form(...)
  local form = nx_value("form_stage_main\\form_talk_movie")
  if not nx_is_valid(form) then
    return
  end
  if table.getn(arg) < 8 then
    return
  end
  local npc = arg[1]
  local funcid = arg[2]
  local task_id = arg[3]
  local titleid = arg[4]
  local menuid = arg[5]
  local conditionLevel = arg[6]
  local conditionTips = arg[7]
  local line = arg[8]
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local row = player:FindRecordRow(REC_TASK_ACCEPT, accept_rec_id, nx_int(task_id), 0)
  if row < 0 then
    return
  end
  clear_data(form)
  form.npcid = nx_string(npc)
  form.condition_level = nx_int(conditionLevel)
  form.condition_tips = nx_string(conditionTips)
  form.issubmit = 1
  local title = player:QueryRecord(REC_TASK_ACCEPT, row, accept_rec_title)
  local title_text = nx_widestr("") .. gui.TextManager:GetText(title)
  if string.find(nx_string(title_text), "<font") == nil then
    title_text = nx_widestr("<font color=\"#FFB428\">") .. title_text .. nx_widestr("</font>")
  end
  local context_text = nx_execute(task_util, "get_title_task_context", titleid)
  local talk_context = title_text .. nx_widestr("<br>") .. nx_widestr(context_text)
  local flag = nx_int(funcid / g_menu_id.base)
  local strSubmit = "task_menu_complete_" .. nx_string(task_id)
  if flag >= nx_int(g_menu_id.task_submit) and flag < nx_int(g_menu_id.task_submit + 100) and menuid == strSubmit and not gui.TextManager:IsIDName(menuid) then
    menuid = nx_string("ui_form_talk_complete_task")
  end
  add_title(talk_context)
  local menu = nx_widestr(funcid) .. nx_widestr("`") .. nx_widestr(menuid) .. nx_widestr("|") .. nx_widestr(g_menu_id.leave) .. nx_widestr("`") .. nx_widestr("ui_form_talk_leave")
  update_menu_control(form, menu)
  local prize_base = player:QueryRecord(REC_TASK_ACCEPT, row, accept_rec_prize_base)
  local prize_ex = player:QueryRecord(REC_TASK_ACCEPT, row, accept_rec_prize_ex)
  local prize_over = player:QueryRecord(REC_TASK_ACCEPT, row, accept_rec_prize_over)
  local prize_condition = player:QueryRecord(REC_TASK_ACCEPT, row, accept_rec_prize_condition)
  init_prize_control(form)
  fill_prize(form, prize_base, prize_ex, prize_over, prize_condition)
  fresh_rbtn_text(form, task_id)
end
function fill_prize(form, prize_base, prize_ex, prize_over, prize_condition)
  if not nx_is_valid(form) then
    return
  end
  local have_prize = false
  local temp_rbtn
  if nx_string(prize_over) ~= "" and is_have_prize(prize_over) then
    form.rbtn_over.Visible = true
    form.rbtn_over.prize_info = prize_over
    have_prize = true
    temp_rbtn = form.rbtn_over
  end
  if nx_string(prize_ex) ~= "" and is_have_prize(prize_ex) then
    form.rbtn_extra.Visible = true
    form.rbtn_extra.prize_info = prize_ex
    have_prize = true
    temp_rbtn = form.rbtn_extra
  end
  if nx_string(prize_base) ~= "" and is_have_prize(prize_base) then
    form.rbtn_task.Visible = true
    form.rbtn_task.prize_info = prize_base
    have_prize = true
    temp_rbtn = form.rbtn_task
  end
  if have_prize then
    form.groupbox_prize.Visible = true
    temp_rbtn.Checked = true
    on_rbtn_click(temp_rbtn)
  end
end
function on_rbtn_click(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local mgr = nx_value("PlayerTrackModule")
  if not nx_is_valid(mgr) then
    mgr = nx_create("PlayerTrackModule")
    nx_set_value("PlayerTrackModule", mgr)
  end
  if nx_is_valid(mgr) then
    mgr:EndShowTrack()
  end
  init_prize_control2(form)
  local prize_info = rbtn.prize_info
  local table_prize_info = util_split_string(prize_info, ",")
  if table.getn(table_prize_info) ~= 23 then
    return
  end
  local control_left = 16
  local control_top = 42
  local add_top = 20
  local cur_value_left = 128
  local new_value_left = 208
  local pic_up_left = 168
  local have_prize = false
  if nx_string(table_prize_info[2]) ~= "0" and client_player:FindProp("Faculty") then
    local cur_faculty = client_player:QueryProp("Faculty")
    local new_faculty = nx_number(cur_faculty) + nx_number(table_prize_info[2])
    form.lbl_faculty_curvalue.Text = nx_widestr(cur_faculty)
    form.lbl_faculty_newvalue.Text = nx_widestr(new_faculty)
    have_prize = true
    form.lbl_growth.Visible = true
    form.groupbox_faculty.Visible = true
    form.lbl_growth.Left = control_left
    form.lbl_growth.Top = control_top
    control_top = control_top + add_top
    form.groupbox_faculty.Left = control_left
    form.groupbox_faculty.Top = control_top
    control_top = control_top + add_top
  end
  local live_type = nx_number(table_prize_info[20])
  if nx_string(table_prize_info[20]) ~= "0" and nx_string(table_prize_info[21]) ~= "0" then
    local cur_groove = client_player:QueryProp("LiveGroove_1") + client_player:QueryProp("LiveGroove_2") + client_player:QueryProp("LiveGroove_3") + client_player:QueryProp("LiveGroove_4") + client_player:QueryProp("LiveGroove_5")
    cur_groove = nx_int(cur_groove / 1000)
    local new_groove = nx_number(cur_groove) + nx_number(nx_number(table_prize_info[21]) / nx_number(1000))
    form.lbl_groove_curvalue.Text = nx_widestr(cur_groove)
    form.lbl_groove_newvalue.Text = nx_widestr(new_groove)
    form.lbl_growth.Visible = true
    form.groupbox_groove.Visible = true
    if not have_prize then
      have_prize = true
      form.lbl_growth.Left = control_left
      form.lbl_growth.Top = control_top
      control_top = control_top + add_top
    end
    form.groupbox_groove.Left = control_left
    form.groupbox_groove.Top = control_top
    control_top = control_top + add_top
  end
  if have_prize then
    form.lbl_line_1.Visible = true
    form.lbl_line_1.Top = control_top + 5
    control_top = control_top + add_top
  end
  have_prize = false
  if nx_string(table_prize_info[3]) ~= "0" and nx_string(table_prize_info[4]) ~= "0" then
    local cur_repute = query_repute(nx_string(table_prize_info[3]))
    local new_repute = nx_number(cur_repute) + nx_number(table_prize_info[4])
    form.lbl_mprepute_curvalue.Text = nx_widestr(cur_repute)
    form.lbl_mprepute_newvalue.Text = nx_widestr(new_repute)
    local repute_text = "ui_talk_movie_" .. nx_string(table_prize_info[3])
    form.lbl_mprepute.Text = nx_widestr(util_text(nx_string(repute_text)))
    have_prize = true
    form.lbl_repute.Visible = true
    form.groupbox_mprepute.Visible = true
    form.lbl_repute.Left = control_left
    form.lbl_repute.Top = control_top
    control_top = control_top + add_top
    form.groupbox_mprepute.Left = control_left
    form.groupbox_mprepute.Top = control_top
    control_top = control_top + add_top
  end
  if nx_string(table_prize_info[5]) ~= "0" and nx_string(table_prize_info[6]) ~= "0" then
    local cur_repute = query_repute(nx_string(table_prize_info[5]))
    local new_repute = nx_number(cur_repute) + nx_number(table_prize_info[6])
    form.lbl_jhrepute_curvalue.Text = nx_widestr(cur_repute)
    form.lbl_jhrepute_newvalue.Text = nx_widestr(new_repute)
    local repute_text = "ui_talk_movie_" .. nx_string(table_prize_info[5])
    form.lbl_jhrepute.Text = nx_widestr(util_text(nx_string(repute_text)))
    form.lbl_repute.Visible = true
    form.groupbox_jhrepute.Visible = true
    if not have_prize then
      have_prize = true
      form.lbl_repute.Left = control_left
      form.lbl_repute.Top = control_top
      control_top = control_top + add_top
    end
    form.groupbox_jhrepute.Left = control_left
    form.groupbox_jhrepute.Top = control_top
    control_top = control_top + add_top
  end
  if have_prize then
    form.lbl_line_2.Visible = true
    form.lbl_line_2.Top = control_top + 5
    control_top = control_top + add_top
  end
  have_prize = false
  if nx_string(table_prize_info[1]) ~= "0" then
    local d, l, w = format_prize_money(nx_int64(table_prize_info[1]))
    local money_text = ""
    if nx_number(d) > 0 then
      money_text = nx_widestr(d) .. nx_widestr(util_text("ui_bag_ding"))
    end
    if nx_number(l) > 0 then
      money_text = nx_widestr(money_text) .. nx_widestr(l) .. nx_widestr(util_text("ui_bag_liang"))
    end
    if nx_number(w) > 0 then
      money_text = nx_widestr(money_text) .. nx_widestr(w) .. nx_widestr(util_text("ui_bag_wen"))
    end
    form.lbl_money_value.Text = nx_widestr(money_text)
    have_prize = true
    form.lbl_money.Visible = true
    form.groupbox_money.Visible = true
    form.lbl_money.Left = control_left
    form.lbl_money.Top = control_top
    control_top = control_top + add_top
    form.groupbox_money.Left = control_left
    form.groupbox_money.Top = control_top
    control_top = control_top + add_top
  end
  if nx_string(table_prize_info[22]) ~= "0" then
    local d, l, w = format_prize_money(nx_int64(table_prize_info[22]))
    local money_text = ""
    if nx_number(d) > 0 then
      money_text = nx_widestr(d) .. nx_widestr(util_text("ui_bag_ding"))
    end
    if nx_number(l) > 0 then
      money_text = nx_widestr(money_text) .. nx_widestr(l) .. nx_widestr(util_text("ui_bag_liang"))
    end
    if nx_number(w) > 0 then
      money_text = nx_widestr(money_text) .. nx_widestr(w) .. nx_widestr(util_text("ui_bag_wen"))
    end
    form.lbl_money_value2.Text = nx_widestr(money_text)
    form.lbl_money.Visible = true
    form.groupbox_money2.Visible = true
    if not have_prize then
      have_prize = true
      form.lbl_money.Left = control_left
      form.lbl_money.Top = control_top
      control_top = control_top + add_top
    end
    form.groupbox_money2.Left = control_left
    form.groupbox_money2.Top = control_top
    control_top = control_top + add_top
  end
  if have_prize then
    form.lbl_line_3.Visible = true
    form.lbl_line_3.Top = control_top + 5
    control_top = control_top + add_top
  end
  have_prize = false
  local index_base = 0
  for i = 11, 18, 2 do
    if nx_string(table_prize_info[i]) ~= "0" then
      local id = table_prize_info[i]
      local num = table_prize_info[i + 1]
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", id, "Photo")
      form.imagegrid_prize_item:AddItem(index_base, nx_string(photo), nx_widestr(id), nx_int(num), 0)
      index_base = index_base + 1
      have_prize = true
    end
  end
  if have_prize then
    if nx_string(table_prize_info[9]) == "1" then
      if form.issubmit == 1 then
        form.lbl_item_tip.Visible = true
        form.imagegrid_prize_item.DrawMouseSelect = "xuanzekuang"
      else
        form.imagegrid_prize_item.DrawMouseSelect = "RECT"
      end
      form.ischoose = 1
    else
      form.lbl_item_tip.Visible = false
      form.imagegrid_prize_item.DrawMouseSelect = "RECT"
    end
    form.lbl_item.Visible = true
    form.imagegrid_prize_item.Visible = true
    form.lbl_item.Left = control_left
    form.lbl_item.Top = control_top
    form.lbl_item_tip.Top = control_top
    control_top = control_top + add_top
    form.imagegrid_prize_item.Left = control_left
    form.imagegrid_prize_item.Top = control_top
    control_top = control_top + 42
    form.lbl_line_4.Visible = true
    form.lbl_line_4.Top = control_top + 5
    control_top = control_top + add_top
  end
  have_prize = false
  if nx_string(table_prize_info[10]) ~= "0" then
    local rand_photo = "icon\\prop\\prop024.png"
    local tips = util_text("ui_task_prize_random")
    form.imagegrid_rand_item.Visible = true
    form.lbl_rand.Visible = true
    form.imagegrid_rand_item:AddItem(0, rand_photo, nx_widestr(tips), 1, 2)
    have_prize = true
    control_top = control_top + 10
    form.lbl_rand.Top = control_top
    control_top = control_top + add_top + 10
    form.imagegrid_rand_item.Top = control_top
  end
end
function is_have_prize(prize_info)
  local table_prize_info = util_split_string(nx_string(prize_info), ",")
  if table.getn(table_prize_info) ~= 23 then
    return false
  end
  for i, info in pairs(table_prize_info) do
    if nx_string(info) ~= "0" then
      return true
    end
  end
  return false
end
function format_prize_money(money)
  local ding = nx_int64(money / 1000000)
  local temp = nx_int64(money - ding * 1000000)
  local liang = nx_int64(temp / 1000)
  local wen = nx_int64(temp - liang * 1000)
  return ding, liang, wen
end
function on_grid_present_select(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  index = index + 1
  if 0 < index then
    form.singleselect = index
  end
end
function on_btn_pagedown_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local line_num = nx_int(form.mltbox_title.Height / form.mltbox_title.LineHeight)
  line_num = nx_number(line_num)
  form.mltbox_title.VScrollBar.Value = form.mltbox_title.VScrollBar.Value + line_num
  fresh_title_control(form)
end
function on_btn_prev_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.menu_page = form.menu_page - 1
  if nx_int(form.menu_page) < nx_int(1) then
    form.menu_page = 1
  end
  update_menu_control(form, form.menus)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.menu_page = form.menu_page + 1
  update_menu_control(form, form.menus)
end
function on_grid_mousein(grid, index)
  nx_execute("form_stage_main\\form_task\\form_task_main", "show_prize_tips", grid, index)
end
function on_grid_mouseout(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function init_controls(form)
  if not nx_is_valid(form) then
    return
  end
  init_controls_size(form)
  form.mltbox_title:Clear()
  form.mltbox_menu:Clear()
  form.groupbox_prize.Visible = false
  form.groupbox_func.Visible = false
  form.btn_func_1.Visible = false
  form.btn_func_2.Visible = false
  form.btn_func_3.Visible = false
  form.btn_func_4.Visible = false
end
function init_controls_size(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local width = gui.Width
  local height = gui.Height
  form.Width = width
  form.Height = height
  local height_groupbox = height * 0.2
  local scroll_width = 22
  form.groupbox_top.Width = width * 5 / 7
  form.groupbox_top.Height = height_groupbox * 0.5
  form.groupbox_top.Left = (form.Width - form.groupbox_top.Width) * 0.5
  form.groupbox_top.Top = -height_groupbox * 1.5
  form.groupbox_title.Left = 0
  form.groupbox_title.Top = 0
  form.groupbox_title.Width = form.groupbox_top.Width
  form.groupbox_title.Height = form.groupbox_top.Height
  form.mltbox_title.Left = form.groupbox_top.Width / 10
  form.mltbox_title.Top = 0
  form.mltbox_title.Width = form.groupbox_top.Width * 0.8
  form.mltbox_title.Height = form.groupbox_top.Height
  form.mltbox_title.ViewRect = "0,0," .. nx_string(form.mltbox_title.Width) .. "," .. nx_string(form.groupbox_top.Height)
  form.lbl_cover.Left = form.mltbox_title.Left + form.mltbox_title.Width - 10
  form.lbl_cover.Top = form.mltbox_title.Top
  form.lbl_cover.Width = 10
  form.lbl_cover.Height = form.mltbox_title.Height
  form.btn_pagedown.Left = -form.groupbox_top.Width / 11
  form.btn_pagedown.Top = -form.btn_pagedown.Height - 5
  form.groupbox_bottom.Width = width
  form.groupbox_bottom.Height = height_groupbox * 1.5
  form.groupbox_bottom.Left = 0
  form.groupbox_bottom.Top = -form.groupbox_bottom.Height
  form.mltbox_menu.Width = width * 0.5
  form.mltbox_menu.Height = height_groupbox * 0.8
  form.mltbox_menu.Left = (form.groupbox_bottom.Width - form.mltbox_menu.Width) * 0.5
  form.mltbox_menu.Top = -height_groupbox * 0.8
  form.mltbox_menu.ViewRect = "0,0," .. nx_string(form.mltbox_menu.Width - scroll_width) .. "," .. nx_string(form.mltbox_menu.Height)
  form.btn_prev.Left = -form.groupbox_bottom.Width * 0.208
  form.btn_prev.Top = form.groupbox_bottom.Height * 0.5
  form.btn_next.Left = -form.groupbox_bottom.Width * 0.208
  form.btn_next.Top = form.groupbox_bottom.Height * 0.8
  form.groupbox_prize.Left = 0
  form.groupbox_prize.Top = 0
  form.groupbox_func.Left = (width - form.groupbox_func.Width) / 2
  form.groupbox_func.Top = form.groupbox_top.Top + form.groupbox_top.Height
end
function reset_menu_control(form)
  if not nx_is_valid(form) then
    return
  end
  local menu = form.mltbox_menu
  local temp_menu = {}
  local menu_num = menu.ItemCount
  if nx_int(menu_num) > nx_int(0) and menu.Visible then
    for i = 0, menu_num - 1 do
      local htmltext = menu:GetHtmlItemText(i)
      local key = menu:GetItemKeyByIndex(i)
      table.insert(temp_menu, htmltext)
      table.insert(temp_menu, key)
    end
    menu:Clear()
    for i = 1, table.getn(temp_menu), 2 do
      menu:AddHtmlText(temp_menu[i], temp_menu[i + 1])
    end
  end
end
function fresh_page_btn(form, cur_page, cur_num, menu_num)
  if not nx_is_valid(form) then
    return
  end
  local width = form.groupbox_bottom.Width
  local height = form.groupbox_bottom.Height
  form.btn_next.Visible = false
  form.btn_prev.Visible = false
  if nx_int(cur_page) == nx_int(1) and nx_int(cur_num) < nx_int(menu_num) then
    form.btn_next.Visible = true
    form.btn_prev.Visible = false
  elseif nx_int(cur_page) > nx_int(1) and nx_int(cur_num) >= nx_int(menu_num) then
    form.btn_next.Visible = false
    form.btn_prev.Visible = true
  elseif nx_int(cur_page) > nx_int(1) and nx_int(cur_num) < nx_int(menu_num) then
    form.btn_next.Visible = true
    form.btn_prev.Visible = true
  end
end
function fresh_title_control(form)
  if not nx_is_valid(form) then
    return
  end
  local line_num = nx_int(form.mltbox_title.Height / form.mltbox_title.LineHeight)
  line_num = nx_number(line_num)
  local fmod = math.fmod(form.mltbox_title.VScrollBar.Maximum, line_num)
  if fmod ~= 0 then
    form.mltbox_title.VScrollBar.Maximum = form.mltbox_title.VScrollBar.Maximum + line_num - fmod
  end
  if form.mltbox_title.VScrollBar.Visible and form.mltbox_title.VScrollBar.Value < form.mltbox_title.VScrollBar.Maximum then
    form.btn_pagedown.Visible = true
  else
    form.btn_pagedown.Visible = false
  end
  if not form.mltbox_title.VScrollBar.Visible then
    local title_height = form.mltbox_title:GetContentHeight()
    form.mltbox_title.Top = (form.mltbox_title.Height - title_height) / 2
  else
    form.mltbox_title.Top = 0
  end
end
function clear_data(form)
  if not nx_is_valid(form) then
    return
  end
  form.acceptMoney = 0
  form.deductLuck = 0
  form.taskid = 0
  form.npcid = ""
  form.singleselect = 0
  form.ischoose = 0
  form.issubmit = 0
  form.close_type = 0
  form.condition_level = 0
  form.condition_tips = ""
  form.menu_page = 1
  form.menus = nx_widestr("")
  form.npcobj = nil
  form.tiaozhan = nil
  menu_num_table = {}
  nx_execute("tips_game", "hide_tip")
end
function init_prize_control(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_prize.Visible = false
  form.lbl_growth.Visible = false
  form.groupbox_faculty.Visible = false
  form.groupbox_groove.Visible = false
  form.lbl_repute.Visible = false
  form.groupbox_mprepute.Visible = false
  form.groupbox_jhrepute.Visible = false
  form.lbl_money.Visible = false
  form.groupbox_money.Visible = false
  form.groupbox_money2.Visible = false
  form.lbl_item.Visible = false
  form.lbl_item_tip.Visible = false
  form.imagegrid_prize_item.Visible = false
  form.lbl_rand.Visible = false
  form.imagegrid_rand_item.Visible = false
  form.rbtn_task.Visible = false
  form.rbtn_extra.Visible = false
  form.rbtn_over.Visible = false
  form.rbtn_task.prize_info = ""
  form.rbtn_extra.prize_info = ""
  form.rbtn_over.prize_info = ""
  form.lbl_line_1.Visible = false
  form.lbl_line_2.Visible = false
  form.lbl_line_3.Visible = false
  form.lbl_line_4.Visible = false
  form.imagegrid_prize_item:Clear()
  form.imagegrid_rand_item:Clear()
end
function init_prize_control2(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_growth.Visible = false
  form.groupbox_faculty.Visible = false
  form.groupbox_groove.Visible = false
  form.lbl_repute.Visible = false
  form.groupbox_mprepute.Visible = false
  form.groupbox_jhrepute.Visible = false
  form.lbl_money.Visible = false
  form.groupbox_money.Visible = false
  form.groupbox_money2.Visible = false
  form.lbl_item.Visible = false
  form.lbl_item_tip.Visible = false
  form.imagegrid_prize_item.Visible = false
  form.imagegrid_prize_item:SetSelectItemIndex(-1)
  form.lbl_rand.Visible = false
  form.imagegrid_rand_item.Visible = false
  form.lbl_line_1.Visible = false
  form.lbl_line_2.Visible = false
  form.lbl_line_3.Visible = false
  form.lbl_line_4.Visible = false
  form.imagegrid_prize_item:Clear()
  form.imagegrid_rand_item:Clear()
end
function get_photo_form_funcid(funcid)
  local form = nx_value("form_stage_main\\form_talk_movie")
  if not nx_is_valid(form) then
    return
  end
  local menu_task_photo = "<img src=\"gui\\special\\task\\leixing\\talk_type_task_main.png\" valign=\"center\" only=\"line\" data=\"\" />"
  local menu_task_complete_photo = ""
  local menu_leave_photo = "<img src=\"gui\\special\\task\\leixing\\talk_type_leave.png\" valign=\"center\" only=\"line\" data=\"\" />"
  local menu_talk_photo = "<img src=\"gui\\special\\task\\leixing\\talk_type_talk.png\" valign=\"center\" only=\"line\" data=\"\" />"
  local menu_shop_photo = "<img src=\"gui\\special\\task\\leixing\\talk_type_shop.png\" valign=\"center\" only=\"line\" data=\"\" />"
  local menu_job_photo = "<img src=\"gui\\special\\task\\leixing\\talk_type_study.png\" valign=\"center\" only=\"line\" data=\"\" />"
  local menu_guild_photo = "<img src=\"gui\\special\\task\\leixing\\talk_type_guild.png\" valign=\"center\" only=\"line\" data=\"\" />"
  local menu_return_photo = "<img src=\"gui\\special\\task\\leixing\\talk_type_leave.png\" valign=\"center\" only=\"line\" data=\"\" />"
  local menu_chess_photo = "<img src=\"gui\\special\\task\\leixing\\talk_type_chess.png\" valign=\"center\" only=\"line\" data=\"\" />"
  local menu_other_photo = "<img src=\"gui\\special\\task\\leixing\\talk_type_op.png\" valign=\"center\" only=\"line\" data=\"\" />"
  if funcid == 2 then
    return menu_leave_photo
  elseif funcid == 806000007 then
    return menu_chess_photo
  end
  local flag = nx_int(funcid / g_menu_id.base)
  if flag == nx_int(g_menu_id.task_leave) then
    return menu_leave_photo
  elseif flag >= nx_int(g_menu_id.task_accept) and flag <= nx_int(g_menu_id.task_max) then
    return menu_task_photo
  elseif flag == nx_int(g_menu_id.func_talk) or flag == nx_int(g_menu_id.func_talk_hide_task) then
    return menu_talk_photo
  elseif flag == nx_int(g_menu_id.func_shop) then
    return menu_shop_photo
  elseif flag == nx_int(g_menu_id.func_life) then
    return menu_job_photo
  elseif flag == nx_int(g_menu_id.func_guild) then
    return menu_guild_photo
  end
  return menu_other_photo
end
function hide_control_desktop()
  nx_execute("form_stage_main\\form_main\\form_main", "move_over")
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(form_main) then
    form_main.groupbox_4.Visible = false
  end
  local scenario_npc_manager = nx_value("scenario_npc_manager")
  if nx_is_valid(scenario_npc_manager) then
    scenario_npc_manager:StopCameraPath()
  end
  nx_execute("gui", "gui_close_allsystem_form")
end
function show_control_desktop()
  local homeid = get_current_homeid()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(form_main) then
    local bIsNewJHModule = is_newjhmodule()
    if not bIsNewJHModule then
      form_main.groupbox_4.Visible = homeid == nx_string("")
    end
  end
  nx_execute("gui", "gui_open_closedsystem_form")
end
function get_current_homeid()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp("CurHomeUID") then
    return ""
  end
  return nx_string(client_player:QueryProp("CurHomeUID"))
end
function set_camra_movie(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local visual_npc = game_visual:GetSceneObj(nx_string(form.npcid))
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_npc) or not nx_is_valid(visual_player) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  CAMERA_ANGLE_X = camera.AngleX
  CAMERA_ANGLE_Y = camera.AngleY
  local distance_x = camera.PositionX - visual_player.PositionX
  local distance_y = camera.PositionY - (visual_player.PositionY + game_control.BindHeight)
  local distance_z = camera.PositionZ - visual_player.PositionZ
  CAMERA_DISTANCE = math.sqrt(distance_x * distance_x + distance_y * distance_y + distance_z * distance_z)
  game_control.CameraMode = GAME_CAMERA_STORY
  game_control.CameraCollide = false
  local camera_story = game_control:GetCameraController(GAME_CAMERA_STORY)
  local npc_pos_y = 0
  if visual_npc:NodeIsExist("Model::head_01") then
    local x, y, z = visual_npc:GetNodePosition("Model::head_01")
    npc_pos_y = y
  end
  local npc_head_height = visual_npc.height * 7 / 8
  if nx_number(npc_pos_y) == nx_number(0) then
    npc_pos_y = visual_npc.PositionY + npc_head_height
  end
  local npc_pos_x = visual_npc.PositionX
  local npc_pos_z = visual_npc.PositionZ
  local npc_angle_y = visual_npc.AngleY
  NPC_POS_X = npc_pos_x
  NPC_POS_Z = npc_pos_z
  local camera_pos_x = npc_pos_x + TALK_CAMERA_DISTANCE * math.sin(npc_angle_y)
  local camera_pos_z = npc_pos_z + TALK_CAMERA_DISTANCE * math.cos(npc_angle_y)
  local camera_pos_y = npc_pos_y
  local camera_angle_x = 0
  local camera_angle_y = npc_angle_y + math.pi
  local camera_angle_z = 0
  local client_npc = game_client:GetSceneObj(form.npcid)
  local npc_state = nx_string(client_npc:QueryProp("State"))
  if camera_pos_y - visual_npc.PositionY < 0.5 then
    camera_pos_y = npc_pos_y + npc_head_height
    camera_angle_x = math.atan(npc_head_height / TALK_CAMERA_DISTANCE)
  end
  local off_y = npc_y_offset[client_npc:QueryProp("ConfigID")]
  if off_y == nil then
    off_y = 0
  end
  camera_pos_y = camera_pos_y - npc_head_height / 12 + off_y
  if is_new_world_scene() then
    local offset = 1.2
    local off_x = offset * math.sin(0.5 * math.pi - npc_angle_y)
    local off_z = offset * math.cos(0.5 * math.pi - npc_angle_y)
    camera_pos_x = camera_pos_x - off_x
    camera_pos_z = camera_pos_z + off_z
  end
  camera_story:SetCameraDirect(camera_pos_x, camera_pos_y, camera_pos_z, camera_angle_x, camera_angle_y, camera_angle_z)
  camera_story.StartPlayerMove = false
  visual_npc.AimObject = camera
end
function set_camra_normal(form)
  if not nx_is_valid(form) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_npc = game_visual:GetSceneObj(nx_string(form.npcid))
  if nx_is_valid(visual_npc) then
    visual_npc.AimObject = nil
  end
  local game_control = scene.game_control
  local camera = scene.camera
  if not nx_is_valid(game_control) then
    return
  end
  if not nx_is_valid(camera) then
    return
  end
  local camera_mode = GetIniInfo("camera_value")
  game_control.CameraMode = nx_int(camera_mode)
  game_control.CameraCollide = true
  if CAMERA_ANGLE_X == nil or CAMERA_ANGLE_Y == nil or CAMERA_DISTANCE == nil then
    return
  end
  game_control.PitchAngle = CAMERA_ANGLE_X
  game_control.YawAngle = CAMERA_ANGLE_Y
  game_control.Distance = CAMERA_DISTANCE
end
function start_ppdof_effect()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local scenario_manager = nx_value("scenario_npc_manager")
  if not nx_is_valid(scenario_manager) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return
  end
  local visual_target = game_visual:GetSceneObj(target.Ident)
  local ppdof_uiparam = scene.ppdof_uiparam
  scenario_manager.old_FocusDepth = ppdof_uiparam.focusdepth
  scenario_manager.old_BlurValue = ppdof_uiparam.blurvalue
  scenario_manager.old_MaxofBlur = ppdof_uiparam.maxofblur
  scenario_manager.old_dof_enable = game_config.dof_enable
  game_config.dof_enable = true
  ppdof_uiparam.blurvalue = 0.6
  ppdof_uiparam.maxofblur = 1
  ppdof_uiparam.focusdepth = TALK_CAMERA_DISTANCE
  nx_execute("game_config", "set_dof_enable", scene, game_config.dof_enable)
  local ppdof = scene.ppdof
  if nx_is_valid(ppdof) then
    ppdof.FocusObject = visual_target
  end
  set_role_falloff(scene, false)
end
function cancel_ppdof_effect()
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local scenario_manager = nx_value("scenario_npc_manager")
  if not nx_is_valid(scenario_manager) then
    return
  end
  local ppdof_uiparam = scene.ppdof_uiparam
  if nx_find_custom(scenario_manager, "old_FocusDepth") then
    ppdof_uiparam.focusdepth = scenario_manager.old_FocusDepth
  end
  if nx_find_custom(scenario_manager, "old_BlurValue") then
    ppdof_uiparam.blurvalue = scenario_manager.old_BlurValue
  end
  if nx_find_custom(scenario_manager, "old_MaxofBlur") then
    ppdof_uiparam.maxofblur = scenario_manager.old_MaxofBlur
  end
  if nx_find_custom(scenario_manager, "old_dof_enable") then
    game_config.dof_enable = scenario_manager.old_dof_enable
  end
  nx_execute("game_config", "set_dof_enable", scene, game_config.dof_enable)
  local ppdof = scene.ppdof
  local terrain = scene.terrain
  if nx_is_valid(ppdof) and nx_is_valid(terrain) then
    ppdof.FocusObject = terrain.Player
  end
  set_role_falloff(scene, true)
end
function clear_hide_obj_table()
  around_obj_table = {}
  trace_hide_obj_table = {}
end
function hide_around_obj()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  around_obj_table = get_around_obj()
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  for i, client_obj in pairs(around_obj_table) do
    if nx_is_valid(client_obj) then
      local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
      if nx_is_valid(visual_obj) then
        if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_PLAYER) then
          visual_obj.Visible = false
        end
        head_game:ShowHead(visual_obj, false)
      end
    end
  end
end
function show_around_obj()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  around_obj_table = get_around_obj()
  local main_player = game_visual:GetPlayer()
  local b_show_player = not game_visual.HidePlayer
  for i, client_obj in pairs(around_obj_table) do
    if nx_is_valid(client_obj) then
      local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
      if nx_is_valid(visual_obj) then
        if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_PLAYER) and (b_show_player or nx_id_equal(visual_obj, main_player)) then
          visual_obj.Visible = true
        end
        head_game:ShowHead(visual_obj, true)
      end
    end
  end
  nx_function("ext_hide_player_F9")
  nx_function("ext_hide_no_attack_player")
end
function get_around_obj()
  local visual_obj_lst = {}
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return visual_obj_lst
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return visual_obj_lst
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return visual_obj_lst
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  for i, client_obj in pairs(client_obj_lst) do
    if nx_is_valid(client_obj) and (tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_PLAYER) or tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_NPC)) then
      table.insert(visual_obj_lst, client_obj)
    end
  end
  return visual_obj_lst
end
function hide_head_info()
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  SHOWHEAD_HP = game_config_info.showhead_hp
  SHOWHEAD_INFO = game_config_info.showhead_info
  SHOWQG_INFO = game_config_info.showself_qg
  game_config_info.showhead_hp = 0
  game_config_info.showhead_info = 0
  game_config_info.showself_qg = 0
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  head_game:RefreshHeadConfig()
end
function show_head_info()
  local game_config_info = nx_value("game_config_info")
  if not nx_is_valid(game_config_info) then
    return
  end
  game_config_info.showhead_hp = SHOWHEAD_HP
  game_config_info.showhead_info = SHOWHEAD_INFO
  game_config_info.showself_qg = SHOWQG_INFO
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  head_game:RefreshHeadConfig()
  refresh_obj_head()
end
function refresh_obj_head()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  for i, client_obj in pairs(client_obj_lst) do
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    head_game:RefreshAll(visual_obj)
  end
end
function start_check_pos(form)
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:RemoveExecute("FormTalkTick", form)
    common_execute:AddExecute("FormTalkTick", form, nx_float(0), nx_string(NPC_POS_X), nx_string(NPC_POS_Z), nx_string(form.npcid))
  end
end
function stop_check_pos(form)
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:RemoveExecute("FormTalkTick", form)
  end
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:ShowTraceHitObj()
  end
end
function form_talk_tick(form)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  if NPC_POS_X == nil or NPC_POS_Z == nil then
    return
  end
  local visual_npc = game_visual:GetSceneObj(nx_string(form.npcid))
  if not nx_is_valid(visual_npc) then
    return
  end
  while true do
    nx_pause(0.5)
    if not nx_is_valid(form) then
      break
    end
    if not nx_is_valid(visual_npc) or not nx_is_valid(visual_player) then
      if nx_is_valid(form) then
        form:Close()
      end
      break
    end
    hide_trace_hit_obj(visual_npc)
    local sx = visual_player.PositionX - visual_npc.PositionX
    local sz = visual_player.PositionZ - visual_npc.PositionZ
    local distance = math.sqrt(sx * sx + sz * sz)
    if nx_int(NPC_POS_X) ~= nx_int(visual_npc.PositionX) or nx_int(NPC_POS_Z) ~= nx_int(visual_npc.PositionZ) or tonumber(distance) > tonumber(MAX_DISTANCE) then
      if nx_is_valid(form) then
        form:Close()
      end
      break
    end
  end
end
function hide_trace_hit_obj(target)
  if not nx_is_valid(target) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  local obj_table = get_around_obj()
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  local temp_table = {}
  for i, client_obj in pairs(obj_table) do
    if nx_is_valid(client_obj) and tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_NPC) then
      local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
      if nx_is_valid(visual_obj) and nx_string(visual_obj) ~= nx_string(target) then
        local distance1 = get_sqrt(visual_obj.PositionX, visual_obj.PositionZ, target.PositionX, target.PositionZ)
        local distance2 = get_sqrt(visual_obj.PositionX, visual_obj.PositionZ, camera.PositionX, camera.PositionZ)
        if distance1 + distance2 < TALK_CAMERA_DISTANCE + 0.5 then
          table.insert(temp_table, visual_obj)
        end
      end
    end
  end
  for j, v_obj in pairs(trace_hide_obj_table) do
    if nx_is_valid(v_obj) and not is_exist_obj(temp_table, v_obj) then
      v_obj.Visible = true
    end
  end
  trace_hide_obj_table = {}
  for k, obj in pairs(temp_table) do
    if nx_is_valid(obj) then
      obj.Visible = false
      table.insert(trace_hide_obj_table, obj)
    end
  end
end
function show_trace_hit_obj()
  for i, visual_obj in pairs(trace_hide_obj_table) do
    if nx_is_valid(visual_obj) then
      visual_obj.Visible = true
    end
  end
end
function play_open_ani(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_top.Top = -form.groupbox_top.Height
  form.groupbox_bottom.Top = 0
  local timer = nx_value("timer_game")
  timer:Register(100, -1, nx_current(), "on_open_ani", form, -1, -1)
end
function play_close_ani(form)
end
function on_open_ani(form, param1, param2)
  if not nx_is_valid(form) then
    return
  end
  local top = form.groupbox_top.Top + form.groupbox_top.Height / 5
  if 0 <= top then
    top = 0
  end
  form.groupbox_top.Top = top
  top = form.groupbox_bottom.Top - form.groupbox_bottom.Height / 5
  if top <= -form.groupbox_bottom.Height then
    top = -form.groupbox_bottom.Height
  end
  form.groupbox_bottom.Top = top
  if form.groupbox_top.Top >= 0 and form.groupbox_bottom.Top <= -form.groupbox_bottom.Height then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_open_ani", form)
  end
end
function on_in_fighting()
end
function on_out_fighting()
end
function request_npc_restart_ai(npcid)
  nx_execute("custom_sender", "custom_request_restart_ai", npcid)
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_talk_movie")
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  local timer = nx_value(GAME_TIMER)
  init_controls_size(form)
  reset_menu_control(form)
  local text = form.mltbox_title.HtmlText
  form.mltbox_title:Clear()
  form.mltbox_title.HtmlText = text
  fresh_title_control(form)
  if nx_find_custom(form, "talk_moive_page") and nx_is_valid(form.talk_moive_page) then
    form.talk_moive_page.Left = form.Width - form.talk_moive_page.Width - 20
    form.talk_moive_page.Top = 0
  end
  if is_new_world_scene() then
    set_talk_pos()
  end
end
function format_info(strid, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return strid
  end
  gui.TextManager:Format_SetIDName(strid)
  for i, para in pairs(arg) do
    local type = nx_type(para)
    if type == "number" then
      gui.TextManager:Format_AddParam(nx_int(para))
    elseif type == "string" then
      gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
    else
      gui.TextManager:Format_AddParam(para)
    end
  end
  return gui.TextManager:Format_GetText()
end
function sysinfo(strid, ...)
  local info = format_info(strid, unpack(arg))
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(info, 2)
  end
  local form_main_chat_logic = nx_value("form_main_chat")
  if nx_is_valid(form_main_chat_logic) then
    form_main_chat_logic:AddChatInfoEx(info, CHATTYPE_SYSTEM, false)
  end
end
function show_spy_prize(npc, funcid, title, menu, prize_info)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local title_text = gui.TextManager:GetText(title)
  local form = nx_value("form_stage_main\\form_talk_movie")
  if not nx_is_valid(form) then
    return
  end
  clear_data(form)
  form.npcid = nx_string(npc)
  add_title(title_text)
  local menu = nx_widestr(funcid) .. nx_widestr("`") .. nx_widestr(menu) .. nx_widestr("|") .. nx_widestr(g_menu_id.leave) .. nx_widestr("`") .. nx_widestr("ui_form_talk_leave")
  update_menu_control(form, menu)
  init_prize_control(form)
  fill_prize(form, prize_info, "", "", "")
end
function remove_task_effect()
  local client_obj_lst = get_around_obj_tmp()
  for i, client_obj in pairs(client_obj_lst) do
    if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_NPC) and nx_find_custom(client_obj, "Head_Effect_Flag") and nx_number(client_obj.Head_Effect_Flag) > nx_number(0) then
      local taskmgr = nx_value("TaskManager")
      if nx_is_valid(taskmgr) then
        taskmgr:ChangeTaskNpcHeadFlag(client_obj, 0)
      end
      table.insert(table_task_npc, client_obj)
    end
  end
end
function reset_task_effect()
  for i, client_obj in pairs(table_task_npc) do
    if nx_is_valid(client_obj) then
      nx_execute("custom_sender", "custom_refresh_npc_effect", client_obj.Ident)
    end
  end
  table_task_npc = {}
end
function remove_life_effect()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_obj_lst = get_around_obj_tmp()
  for i, client_obj in pairs(client_obj_lst) do
    if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_NPC) then
      local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
      nx_execute("head_game", "cancel_npc_head_effect", visual_obj)
    end
  end
end
function reset_life_effect()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_obj_lst = get_around_obj_tmp()
  for i, client_obj in pairs(client_obj_lst) do
    if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_NPC) then
      local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
      nx_execute("head_game", "set_npc_head_effect", visual_obj)
    end
  end
end
function reset_npc_groupbox_karma(npcid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local visual_scene_obj = game_visual:GetSceneObj(nx_string(npcid))
  if not nx_is_valid(visual_scene_obj) then
    return 0
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_scene_obj = game_client:GetSceneObj(nx_string(npcid))
  if not nx_is_valid(client_scene_obj) then
    return 0
  end
  if not nx_find_custom(visual_scene_obj, "balloon_name") then
    return 0
  end
  local ball = visual_scene_obj.balloon_name
  if not nx_is_valid(ball) then
    return 0
  end
  local groupbox_karma = ball.Control:Find("groupbox_karma")
  if not nx_is_valid(groupbox_karma) then
    return 0
  end
  groupbox_karma.Visible = false
  local lbl_karma = ball.Control:Find("Karma")
  if not nx_is_valid(lbl_karma) then
    return 0
  end
  if 0 < client_scene_obj:QueryProp("KarmaMatchingID") then
    lbl_karma.Visible = true
  end
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:RefreshDataAndPos(visual_scene_obj, false)
  end
end
function get_around_obj_tmp()
  local table_npc = {}
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return table_npc
  end
  return game_scene:GetSceneObjList()
end
function get_photo_by_condition(level)
  local photo = "icon\\prop\\prop024.png"
  if nx_number(level) == nx_number(0) then
    photo = "icon\\prop\\prop024.png"
  elseif nx_number(level) == nx_number(1) then
    photo = "icon\\prop\\prop295.png"
  elseif nx_number(level) == nx_number(2) then
    photo = "icon\\prop\\prop591.png"
  elseif nx_number(level) == nx_number(3) then
    photo = "icon\\prop\\prop036.png"
  elseif nx_number(level) == nx_number(4) then
    photo = "icon\\prop\\prop461.png"
  elseif nx_number(level) == nx_number(5) then
    photo = "icon\\prop\\prop462.png"
  elseif nx_number(level) == nx_number(6) then
    photo = "icon\\prop\\prop466.png"
  elseif nx_number(level) == nx_number(7) then
    photo = "icon\\prop\\prop436.png"
  elseif nx_number(level) == nx_number(8) then
    photo = "icon\\prop\\prop440.png"
  elseif nx_number(level) == nx_number(9) then
    photo = "icon\\prop\\prop447.png"
  elseif nx_number(level) == nx_number(10) then
    photo = "icon\\prop\\prop437.png"
  elseif nx_number(level) == nx_number(11) then
    photo = "icon\\prop\\prop441.png"
  elseif nx_number(level) == nx_number(12) then
    photo = "icon\\prop\\prop448.png"
  elseif nx_number(level) == nx_number(13) then
    photo = "icon\\equip\\b_cloth001.png"
  elseif nx_number(level) == nx_number(14) then
    photo = "icon\\equip\\b_cloth028.png"
  elseif nx_number(level) == nx_number(15) then
    photo = "icon\\equip\\b_cloth028.png"
  end
  return photo
end
function set_role_falloff(scene, cmd)
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "role_param") then
    return
  end
  local role_param = nx_call("util_gui", "get_arraylist", "role_param")
  role_param.enable_camera_light = false
  role_param.camera_light_color = "255,128,128,128"
  role_param.enable_role_falloff = cmd
  role_param.role_falloff_color = scene.role_param.role_falloff_color
  role_param.role_falloff_inten = scene.role_param.role_falloff_inten
  role_param.role_falloff_power = scene.role_param.role_falloff_power
  role_param.role_diffuse_factor = scene.role_param.role_diffuse_factor
  role_param.role_ambient_factor = scene.role_param.role_diffuse_factor
  role_param.role_specular_factor = scene.role_param.role_diffuse_factor
  scene.role_param = role_param
end
function IsSetHomePoint()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_sethomepoint"))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
end
function fresh_rbtn_text(form, task_id)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id), 0)
  if row < 0 then
    return
  end
  local line = client_player:QueryRecord("Task_Accepted", row, accept_rec_line)
  if line == task_line_main or line == task_line_menpai then
    form.rbtn_task.Text = nx_widestr(util_text("ui_task_buzhou_prize"))
  elseif line == task_line_side then
    form.rbtn_task.Text = nx_widestr(util_text("ui_task_renwu_prize"))
  elseif line == task_line_enyuan then
    form.rbtn_task.Text = nx_widestr(util_text("ui_task_enyuan_prize"))
  end
  local current_round = 0
  if line == task_line_main then
    if client_player:FindRecord("DramaRec") and 0 < client_player:GetRecordRows("DramaRec") then
      current_round = client_player:QueryRecord("DramaRec", 0, 2)
    end
    if 4 == current_round then
      form.rbtn_extra.Text = nx_widestr(util_text("ui_task_chapter_prize"))
    else
      form.rbtn_extra.Text = nx_widestr(util_text("ui_task_round_prize"))
    end
  elseif line == task_line_menpai then
    if client_player:FindRecord("SchoolDramaRec") and 0 < client_player:GetRecordRows("SchoolDramaRec") then
      current_round = client_player:QueryRecord("SchoolDramaRec", 0, 2)
    end
    if 4 == current_round then
      form.rbtn_extra.Text = nx_widestr(util_text("ui_task_chapter_prize"))
    else
      form.rbtn_extra.Text = nx_widestr(util_text("ui_task_round_prize"))
    end
  end
end
function get_sqrt(x1, y1, x2, y2)
  local num = (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)
  return math.sqrt(num)
end
function is_exist_obj(obj_table, obj)
  local num
  table.getn(obj_table)
  if num == 0 then
    return false
  end
  for i, object in pairs(obj_table) do
    if nx_string(object) == nx_string(obj) then
      return true
    end
  end
  return false
end
function show_chat_text_onhead(npc, text)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene_obj = game_client:GetSceneObj(npc)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:ShowChatTextOnHead(client_scene_obj, nx_widestr(text), 5000)
  end
end
function play_talk_action(npc)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local visual_npc = game_visual:GetSceneObj(nx_string(npc))
  if not nx_is_valid(visual_npc) then
    return
  end
  local client_npc = game_client:GetSceneObj(nx_string(npc))
  if not nx_is_valid(client_npc) then
    return
  end
  local state = client_npc:QueryProp("State")
  state = npc_talk_action[state]
  if state == nil or nx_string(state) == "" then
    return
  end
  local action_module = nx_value("action_module")
  if nx_is_valid(action_module) then
    action_module:DoAction(visual_npc, nx_string(state))
  end
end
function query_repute(repute_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("Repute_Record") then
    return 0
  end
  local row = client_player:FindRecordRow("Repute_Record", 0, nx_string(repute_id), 0)
  if row < 0 then
    return 0
  end
  return client_player:QueryRecord("Repute_Record", row, 1)
end
function clear_select_corlor(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_npc = game_visual:GetSceneObj(nx_string(form.npcid))
  if not nx_is_valid(visual_npc) then
    return
  end
  local auto_select_object = nx_value("auto_select_obj")
  local client_ident = game_visual:QueryRoleClientIdent(visual_npc)
  if nx_string(auto_select_object) ~= nx_string(client_ident) then
    return
  end
  local scene_obj = nx_value("scene_obj")
  if not nx_is_valid(scene_obj) then
    return
  end
  scene_obj:ChangeSelectColor(visual_npc, 16777215)
end
function reset_select_corlor(client_ident)
  local joystick_mode = nx_execute("control_set", "is_joystick_fight_operate_mode")
  if not joystick_mode then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_npc = game_visual:GetSceneObj(nx_string(client_ident))
  if not nx_is_valid(visual_npc) then
    return
  end
  local auto_select_object = nx_value("auto_select_obj")
  if nx_string(auto_select_object) ~= nx_string(client_ident) then
    return
  end
  local scene_obj = nx_value("scene_obj")
  if not nx_is_valid(scene_obj) then
    return
  end
  scene_obj:ChangeSelectColor(visual_npc, 65280)
end
function set_select_hight_light(form)
  local game_config_info = nx_value("game_config_info")
  if util_get_property_key(game_config_info, "select_effect", 0) == 0 then
    local game_visual = nx_value("game_visual")
    local visual_scene_obj = game_visual:GetSceneObj(form.npcid)
    nx_function("ext_set_select_light", visual_scene_obj, "0.68,0.68,0.68", "0.68,0.68,0.68")
  else
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    local visual_npc = game_visual:GetSceneObj(nx_string(form.npcid))
    if not nx_is_valid(visual_npc) then
      return
    end
    local scene_obj = nx_value("scene_obj")
    if not nx_is_valid(scene_obj) then
      return
    end
    scene_obj:ChangeSelectColor(visual_npc, 65280)
  end
end
function reset_select_hight_light(form)
  local game_config_info = nx_value("game_config_info")
  if util_get_property_key(game_config_info, "select_effect", 0) == 0 then
    local game_visual = nx_value("game_visual")
    local visual_scene_obj = game_visual:GetSceneObj(form.npcid)
    nx_function("ext_set_select_light", visual_scene_obj, "0.588,0.588,0.588", "0.588,0.588,0.588")
  else
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    local visual_npc = game_visual:GetSceneObj(nx_string(form.npcid))
    if not nx_is_valid(visual_npc) then
      return
    end
    local scene_obj = nx_value("scene_obj")
    if not nx_is_valid(scene_obj) then
      return
    end
    scene_obj:ChangeSelectColor(visual_npc, 16777215)
  end
end
function clear_select_light_or_corlor(form)
  local game_config_info = nx_value("game_config_info")
  if util_get_property_key(game_config_info, "camera_value", 0) == 0 then
    reset_select_hight_light(form)
  else
    clear_select_corlor(form)
  end
end
function reset_select_light_or_corlor(form)
  local game_config_info = nx_value("game_config_info")
  if util_get_property_key(game_config_info, "camera_value", 0) == 0 then
    set_select_hight_light(form)
  else
    reset_select_corlor(form)
  end
end
function set_talk_movie(value)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual.TalkMovie = value
end
function is_add_school(funcid)
  if funcid ~= 1000 then
    return false
  end
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return false
  end
  local npcid = nx_string(target:QueryProp("ConfigID"))
  if "" == npcid then
    return false
  end
  local school_id = school_npc_id[npcid]
  if "" == school_id or nil == school_id then
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  gui.TextManager:Format_SetIDName("ui_decide")
  gui.TextManager:Format_AddParam(school_id)
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return false
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  dialog.relogin_btn.Visible = true
  dialog.relogin_btn.Text = gui.TextManager:GetText("ui_chakanmenpai")
  dialog.relogin_btn.Left = 3
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return false
  elseif res == "cancel" then
    return true
  else
    local str = "form_stage_main\\form_main\\form_school_introduce"
    local form = nx_value(str)
    if nx_is_valid(form) then
      form:Close()
    end
    util_auto_show_hide_form(str)
  end
  return true
end
function is_kuaihuolin_npc(npcid)
  if npcid == nil or nx_string(npcid) == nx_string("") then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local npc_table = {
    "khdnpc_ck0001"
  }
  local client_scene_obj = game_client:GetSceneObj(nx_string(npcid))
  if nx_is_valid(client_scene_obj) then
    local config_id = nx_string(client_scene_obj:QueryProp("ConfigID"))
    for i = 1, table.getn(npc_table) do
      if nx_string(config_id) == nx_string(npc_table[i]) then
        return true
      end
    end
  end
  return false
end
local table_new_world_scene = {
  ["ini\\scene\\scene12"] = 1,
  ["ini\\scene\\scene13"] = 1,
  ["ini\\scene\\scene14"] = 1,
  ["ini\\scene\\scene15"] = 1,
  ["ini\\scene\\scene20"] = 1,
  ["ini\\scene\\scene21"] = 1,
  ["ini\\scene\\scene22"] = 1,
  ["ini\\scene\\scene23"] = 1,
  ["ini\\scene\\jianghu_newtype01"] = 1,
  ["ini\\scene\\jianghu_newtype02"] = 1,
  ["ini\\scene\\jianghu_hole01"] = 1,
  ["ini\\scene\\jianghu_hole02"] = 1,
  ["ini\\scene\\jianghu_hole03"] = 1,
  ["ini\\scene\\jianghu_hole04"] = 1,
  ["ini\\scene\\jianghu_hole05"] = 1,
  ["ini\\scene\\jianghu_hole06"] = 1
}
local table_player_talk_info = {}
local MAX_TALK_MLTBOX_COUNT = 8
local MAX_TALK_COUNT_ONE_PAGE = 4
local TEXT_ASIDE = "ui_new_dialogue_pangbai"
function is_new_world_scene()
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return false
  end
  local scene = client:GetScene()
  if not nx_is_valid(scene) then
    return false
  end
  local scene_id = scene:QueryProp("ConfigID")
  if nx_int(table_new_world_scene[scene_id]) > nx_int(0) then
    return true
  end
  return false
end
function update_talk(form, npc_id, title, menu)
  update_npc_talk(form, npc_id, title)
  update_player_talk(form, menu, title)
end
function update_npc_talk(form, npc_id, talk)
  update_npc_info(form, npc_id)
  update_npc_talk_menu(form, npc_id, talk)
end
function update_player_talk(form, menu, title)
  update_player_info(form)
  get_player_talk_info(menu)
  update_player_talk_menu(form, menu)
  update_player_talk_mltbox(form, menu, title)
end
function update_npc_info(form, npc_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return false
  end
  local npc = client:GetSceneObj(nx_string(npc_id))
  if not nx_is_valid(npc) then
    return false
  end
  local config_id = npc:QueryProp("ConfigID")
  local npc_name = gui.TextManager:GetText(nx_string(config_id))
  form.lbl_npc_name.Text = nx_widestr(npc_name)
end
function update_npc_talk_menu(form, npc_id, talk)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  if not nx_is_valid(form) then
    return false
  end
  local menu = form.mltbox_npc_talk
  if not nx_is_valid(menu) then
    return false
  end
  menu:Clear()
  local content
  if gui.TextManager:IsIDName(nx_string(talk)) then
    content = gui.TextManager:GetText(nx_string(talk))
  else
    content = nx_widestr(talk)
  end
  local menu_index = menu:AddHtmlText(content, 300)
  show_npc_talk(form)
  return true
end
function on_lbl_npc_bg_total_click(label)
  local form = label.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(table_player_talk_info)
  if nx_int(count) <= nx_int(0) then
    menu_select(g_menu_id.leave)
    return
  end
  show_player_talk(form)
end
function on_lbl_player_bg_total_click(label)
  local form = label.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local func_id = nx_int(label.DateSource)
  menu_select(func_id)
end
function update_player_info(form)
  local name = get_player_prop("Name")
  form.lbl_player_name.Text = nx_widestr(name)
end
function get_player_talk_info(menu)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  table_player_talk_info = {}
  local table_menu = util_split_wstring(nx_widestr(menu), nx_widestr("|"))
  local menu_count = table.getn(table_menu)
  local count = 0
  for i = 1, menu_count do
    local table_talk = util_split_wstring(table_menu[i], "`")
    if table.getn(table_talk) ~= 2 then
      return false
    end
    local func_id = nx_int(table_talk[1])
    local talk_id = nx_string(table_talk[2])
    if not is_func_btn_menu(func_id) and nx_int(func_id) ~= nx_int(g_menu_id.leave) then
      local txt_exit = gui.TextManager:GetText("ui_exit")
      local txt_return = gui.TextManager:GetText("ui_return")
      if nx_string(txt_exit) ~= nx_string(talk_id) and nx_string(txt_return) ~= nx_string(talk_id) then
        count = count + 1
        table_player_talk_info[count] = i
      end
    end
    if nx_int(func_id) == nx_int(g_menu_id.func_menu_shop) then
      count = count + 1
      table_player_talk_info[count] = i
      table_player_talk_info[count] = table_player_talk_info[1]
      table_player_talk_info[1] = i
    end
  end
  return true
end
function update_player_talk_menu(form, menu)
  show_player_talk_menu(form, false)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local menu_control = form.mltbox_player_talk
  if not nx_is_valid(menu_control) then
    return false
  end
  menu_control:Clear()
  local count = table.getn(table_player_talk_info)
  if nx_int(count) ~= nx_int(1) then
    return false
  end
  local table_menu = util_split_wstring(nx_widestr(menu), nx_widestr("|"))
  if table.getn(table_menu) < 1 then
    return false
  end
  local id = table_player_talk_info[1]
  local table_talk = util_split_wstring(table_menu[id], "`")
  if table.getn(table_talk) ~= 2 then
    return false
  end
  local func_id = nx_int(table_talk[1])
  local talk_id = table_talk[2]
  local content
  if gui.TextManager:IsIDName(nx_string(talk_id)) then
    content = gui.TextManager:GetText(nx_string(talk_id))
  else
    content = nx_widestr(talk_id)
  end
  local menu_index = menu_control:AddHtmlText(content, func_id)
  show_player_talk_menu(form, true)
  local lb_total = form.lbl_player_bg_total
  if not nx_is_valid(lb_total) then
    return false
  end
  lb_total.DateSource = nx_string(func_id)
  return true
end
function update_player_talk_mltbox(form, menu, title)
  show_talk_1st_page(form, false)
  show_talk_2nd_page(form, false)
  show_player_talk_aside(form, false)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local count = table.getn(table_player_talk_info)
  if nx_int(count) <= nx_int(1) then
    return false
  end
  local table_menu = util_split_wstring(nx_widestr(menu), nx_widestr("|"))
  if table.getn(table_menu) <= 1 then
    return false
  end
  if nx_int(count) > nx_int(MAX_TALK_MLTBOX_COUNT) then
    count = MAX_TALK_MLTBOX_COUNT
  end
  for i = 1, count do
    local id = table_player_talk_info[i]
    local table_talk = util_split_wstring(table_menu[id], "`")
    if table.getn(table_talk) ~= 2 then
      return false
    end
    local func_id = nx_int(table_talk[1])
    local talk_id = table_talk[2]
    local content
    if gui.TextManager:IsIDName(nx_string(talk_id)) then
      content = gui.TextManager:GetText(nx_string(talk_id))
    else
      content = nx_widestr(talk_id)
    end
    local groupbox_player = form.groupbox_player
    local groupbox_mltbox = groupbox_player:Find("groupbox_mltbox")
    if not nx_is_valid(groupbox_mltbox) then
      return false
    end
    local mltbox = groupbox_mltbox:Find("mltbox_0" .. nx_string(i))
    if not nx_is_valid(mltbox) then
      return false
    end
    local label = groupbox_mltbox:Find("lbl_0" .. nx_string(i))
    if not nx_is_valid(label) then
      return false
    end
    mltbox.HtmlText = nx_widestr(content)
    mltbox.DateSource = nx_string(func_id)
    label.DateSource = nx_string(func_id)
  end
  for i = count + 1, MAX_TALK_MLTBOX_COUNT do
    local groupbox_player = form.groupbox_player
    local groupbox_mltbox = groupbox_player:Find("groupbox_mltbox")
    if not nx_is_valid(groupbox_mltbox) then
      return false
    end
    local mltbox = groupbox_mltbox:Find("mltbox_0" .. nx_string(i))
    if not nx_is_valid(mltbox) then
      return false
    end
    local label = groupbox_mltbox:Find("lbl_0" .. nx_string(i))
    if not nx_is_valid(label) then
      return false
    end
    mltbox.HtmlText = nx_widestr("")
    mltbox.DateSource = nx_string("")
    label.DateSource = nx_string("")
  end
  show_talk_1st_page(form, true)
  show_talk_2nd_page(form, false)
  set_player_talk_aside(form, title)
  show_player_talk_aside(form, true)
end
function on_player_talk_menu_select(menu, index)
  local func_id = menu:GetItemKeyByIndex(index)
  menu_select(func_id)
end
function show_npc_talk(form)
  form.groupbox_npc.Visible = true
  form.groupbox_player.Visible = false
  form:ToFront(form.groupbox_npc)
end
function show_player_talk(form)
  form.groupbox_npc.Visible = false
  form.groupbox_player.Visible = true
  form:ToFront(form.groupbox_player)
end
function show_player_talk_menu(form, show)
  form.lbl_player_name.Visible = show
  form.mltbox_player_talk.Visible = show
  form.lbl_player_talk_back.Visible = show
  form.lbl_player_name_back.Visible = show
  form.lbl_player_bg_total.Visible = show
end
function show_talk_1st_page(form, show)
  local count = get_player_talk_count(form)
  if nx_int(count) > nx_int(MAX_TALK_COUNT_ONE_PAGE) then
    count = MAX_TALK_COUNT_ONE_PAGE
  end
  local groupbox_player = form.groupbox_player
  local groupbox_mltbox = groupbox_player:Find("groupbox_mltbox")
  if not nx_is_valid(groupbox_mltbox) then
    return false
  end
  if show then
    for i = 1, count do
      local mltbox = groupbox_mltbox:Find("mltbox_0" .. nx_string(i))
      if nx_is_valid(mltbox) then
        mltbox.Visible = true
      end
      local label = groupbox_mltbox:Find("lbl_0" .. nx_string(i))
      if nx_is_valid(label) then
        label.Visible = true
      end
    end
  else
    for i = 1, MAX_TALK_COUNT_ONE_PAGE do
      local mltbox = groupbox_mltbox:Find("mltbox_0" .. nx_string(i))
      if nx_is_valid(mltbox) then
        mltbox.Visible = false
      end
      local label = groupbox_mltbox:Find("lbl_0" .. nx_string(i))
      if nx_is_valid(label) then
        label.Visible = false
      end
    end
  end
  if show then
    local count = get_player_talk_count(form)
    if nx_int(count) > nx_int(MAX_TALK_COUNT_ONE_PAGE) then
      form.btn_next_page.Visible = true
    else
      form.btn_next_page.Visible = false
    end
  else
    form.btn_next_page.Visible = false
  end
end
function show_talk_2nd_page(form, show)
  local count = get_player_talk_count(form)
  if nx_int(count) > nx_int(MAX_TALK_COUNT_ONE_PAGE) then
    count = count - MAX_TALK_COUNT_ONE_PAGE
  end
  local groupbox_player = form.groupbox_player
  local groupbox_mltbox = groupbox_player:Find("groupbox_mltbox")
  if not nx_is_valid(groupbox_mltbox) then
    return false
  end
  if show then
    for i = 1, count do
      local id = MAX_TALK_COUNT_ONE_PAGE + i
      local mltbox = groupbox_mltbox:Find("mltbox_0" .. nx_string(id))
      if nx_is_valid(mltbox) then
        mltbox.Visible = true
      end
      local label = groupbox_mltbox:Find("lbl_0" .. nx_string(id))
      if nx_is_valid(label) then
        label.Visible = true
      end
    end
  else
    for i = 1, MAX_TALK_COUNT_ONE_PAGE do
      local id = MAX_TALK_COUNT_ONE_PAGE + i
      local mltbox = groupbox_mltbox:Find("mltbox_0" .. nx_string(id))
      if nx_is_valid(mltbox) then
        mltbox.Visible = false
      end
      local label = groupbox_mltbox:Find("lbl_0" .. nx_string(id))
      if nx_is_valid(label) then
        label.Visible = false
      end
    end
  end
  if show then
    form.btn_prev_page.Visible = true
  else
    form.btn_prev_page.Visible = false
  end
end
function get_player_talk_count(form)
  local count = 0
  local groupbox_player = form.groupbox_player
  local groupbox_mltbox = groupbox_player:Find("groupbox_mltbox")
  if not nx_is_valid(groupbox_mltbox) then
    return false
  end
  for i = 1, MAX_TALK_MLTBOX_COUNT do
    local mltbox = groupbox_mltbox:Find("mltbox_0" .. nx_string(i))
    if not nx_is_valid(mltbox) then
      return false
    end
    if nx_widestr(mltbox.HtmlText) ~= nx_widestr("") then
      count = count + 1
    end
  end
  return count
end
function set_player_talk_aside(form, title)
  local menu = form.mltbox_npc_talk
  if not nx_is_valid(menu) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local aside = gui.TextManager:GetText(TEXT_ASIDE)
  local content = nx_widestr(title) .. nx_widestr("<br>") .. nx_widestr(aside)
  form.mltbox_pangbai:Clear()
  form.mltbox_pangbai:AddHtmlText(content, 0)
end
function show_player_talk_aside(form, show)
  form.mltbox_pangbai.Visible = show
  form.lbl_pangbai_back.Visible = show
end
function on_lbl_player_talk_click(label)
  local func_id = nx_int(label.DateSource)
  menu_select(func_id)
end
function set_talk_pos()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  set_npc_talk_pos(form)
  set_player_talk_pos(form)
end
function set_npc_talk_pos(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local width = gui.Width
  local height = gui.Height
  local gb_npc = form.groupbox_npc
  gb_npc.Width = width
  gb_npc.Height = height
  gb_npc.Left = 0
  gb_npc.Top = 0
  local lb_bg = form.lbl_npc_bg
  lb_bg.Width = width
  lb_bg.Left = 0
  lb_bg.Top = gb_npc.Height - lb_bg.Height
  local lb_bg2 = form.lbl_npc_bg2
  lb_bg2.Width = width
  lb_bg2.Left = 0
  lb_bg2.Top = 0
  local gb_npc3 = form.groupbox_npc3
  gb_npc3.Width = width
  gb_npc3.Left = 0
  gb_npc3.Top = height - gb_npc3.Height
  local lb_total = form.lbl_npc_bg_total
  lb_total.Width = width
  lb_total.Height = height
  lb_total.Left = 0
  lb_total.Top = 0
end
function set_player_talk_pos(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local width = gui.Width
  local height = gui.Height
  local gb_player = form.groupbox_player
  gb_player.Width = width
  gb_player.Height = height
  gb_player.Left = 0
  gb_player.Top = 0
  local lb_bg = form.lbl_player_bg
  lb_bg.Width = width
  lb_bg.Left = 0
  lb_bg.Top = gb_player.Height - lb_bg.Height
  local lb_bg2 = form.lbl_player_bg2
  lb_bg2.Width = width
  lb_bg2.Left = 0
  lb_bg2.Top = 0
  local gb_mltbox = form.groupbox_mltbox
  gb_mltbox.Left = (width - gb_mltbox.Width) / 2
  gb_mltbox.Top = 0
  local gb_player3 = form.groupbox_player3
  gb_player3.Width = width
  gb_player3.Left = 0
  gb_player3.Top = height - gb_player3.Height
  local lb_total = form.lbl_player_bg_total
  lb_total.Width = width
  lb_total.Height = height
  lb_total.Left = 0
  lb_total.Top = 0
end
function on_btn_next_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_talk_1st_page(form, false)
  show_talk_2nd_page(form, true)
end
function on_btn_prev_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_talk_1st_page(form, true)
  show_talk_2nd_page(form, false)
end
function show_old_talk(form, show)
  form.groupbox_top.Visible = show
  form.groupbox_bottom.Visible = show
end
function show_new_talk(form, show)
  form.groupbox_npc.Visible = show
  form.groupbox_player.Visible = show
end
function get_player_prop(prop)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return ""
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return ""
  end
  if not player:FindProp(nx_string(prop)) then
    return ""
  end
  return player:QueryProp(nx_string(prop))
end
