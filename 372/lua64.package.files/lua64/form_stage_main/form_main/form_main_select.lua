require("util_gui")
require("const_define")
require("define\\object_type_define")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\npc_type_define")
require("util_static_data")
require("scenario_npc_manager")
require("tips_game")
require("util_role_prop")
require("form_stage_main\\form_tvt\\define")
local ELITE_PLAYER_LEVEL = 86
local skill_name = "ui_skill001"
local skill_photo = "icon\\skill\\wx_sl0903.png"
local global_logic_name = "form_main_select_logic"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local function get_method_arg(ent, method_list)
  local nifo_list = nx_method(ent, method_list)
  log("method_list bagin")
  for _, info in pairs(nifo_list) do
    log("info = " .. nx_string(info))
  end
  log("method_list end")
end
local function get_method(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local method_list = nx_method_list(ent)
  log("method_list bagin")
  for _, method in ipairs(method_list) do
    log("method = " .. method)
  end
  log("method_list end")
end
function main_form_init(self)
  self.Fixed = true
  self.bind = false
  self.b_first = true
  self.name_pos = 0
  self.str_font = ""
  self.selectobjname = nil
  self.selectobjtype = nil
  self.cantopen = false
  self.role_actor2 = nx_null()
  self.no_need_motion_alpha = true
  return 1
end
function main_form_open(form)
  local gui = nx_value("gui")
  if form.b_first then
    form.name_pos = form.lbl_name.AbsTop
    form.str_font = form.lbl_name.Font
    form.b_first = false
  end
  form.buff_grid.ImageAsync = true
  form.buff_grid.unhelpful_total = 0
  form.buff_grid.helpful_total = 0
  form.prog_hp.tge_value = 0
  form.prog_hp.sat_value = 0
  form.prog_hp.cur_value = 0
  form.prog_hp.cur_ratio = 0.01
  form.prog_hp.resume_hp = form.prog_resume_hp
  form.prog_hp.end_time = 2000
  form.prog_hp.cur_time = 0
  form.prog_mp.tge_value = 0
  form.prog_mp.sat_value = 0
  form.prog_mp.cur_value = 0
  form.prog_mp.cur_ratio = 0.01
  form.prog_mp.end_time = 2000
  form.prog_mp.cur_time = 0
  form.pbar_hp.tge_value = 0
  form.pbar_hp.sat_value = 0
  form.pbar_hp.cur_value = 0
  form.pbar_hp.cur_ratio = 0.01
  form.pbar_hp.resume_hp = form.pbar_resume_hp
  form.pbar_hp.end_time = 2000
  form.pbar_hp.cur_time = 0
  form.prog_resume_hp.tge_value = 0
  form.prog_resume_hp.sat_value = 0
  form.prog_resume_hp.cur_value = 0
  form.prog_resume_hp.cur_ratio = 0.005
  form.prog_resume_hp.cur_stage = 1
  form.prog_resume_hp.end_time = 2000
  form.prog_resume_hp.cur_time = 0
  form.prog_resume_hp.Visible = false
  form.prog_resume_hp.obj = nil
  form.prog_resume_hp.prop = "HPRatio"
  form.pbar_resume_hp.tge_value = 0
  form.pbar_resume_hp.sat_value = 0
  form.pbar_resume_hp.cur_value = 0
  form.pbar_resume_hp.cur_ratio = 0.005
  form.pbar_resume_hp.cur_stage = 1
  form.pbar_resume_hp.Visible = false
  form.pbar_resume_hp.obj = nil
  form.pbar_resume_hp.end_time = 2000
  form.pbar_resume_hp.cur_time = 0
  form.pbar_resume_hp.prop = "HitHPRatio"
  form.groupbox_skill.Visible = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) and not form.bind then
    local form_logic = nx_create("form_main_select")
    nx_set_value(global_logic_name, form_logic)
    if nx_is_valid(form_logic) then
      form_logic:LoadLblBuffBackImage()
    end
    form.bind = true
  end
  local timer = nx_value("timer_game")
  local asynor = nx_value("common_execute")
  asynor:AddExecute("ExecuteBuffersCyc", form, nx_float(0.15))
  asynor:AddExecute("HPResumeEx", form, nx_float(0), form.prog_hp, form.prog_mp, form.prog_resume_hp)
  asynor:AddExecute("HPResumeEx", form.groupbox_select, nx_float(0), form.pbar_hp, nil, form.pbar_resume_hp)
  form.btn_YY.Visible = false
  form.yy_query_time = 0
end
function on_main_form_shut(form)
  if nx_find_custom(form, "role_actor2") and nx_is_valid(form.role_actor2) then
    clear_form_model(form, form.role_actor2)
  end
  local form_logic = nx_value(global_logic_name)
  if nx_is_valid(form_logic) then
    form_logic:UnLoadLblBuffBackImage()
    nx_destroy(form_logic)
  end
end
function main_form_close(self)
  local old_sel_vis_object = nx_null()
  if nx_find_value(GAME_SELECT_OBJECT) then
    local old_sel_client_object = nx_value(GAME_SELECT_OBJECT)
    local game_visual = nx_value("game_visual")
    if nx_is_valid(old_sel_client_object) and nx_is_valid(game_visual) then
      old_sel_vis_object = game_visual:GetSceneObj(old_sel_client_object.Ident)
    end
  end
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("ExecuteBuffersCyc", self)
  asynor:RemoveExecute("HPResumeEx", self)
  asynor:RemoveExecute("HPResumeEx", self.groupbox_select)
  remove_select_effect(old_sel_vis_object)
  self.buff_grid.unhelpful_total = 0
  self.buff_grid.helpful_total = 0
end
function on_gui_size_change()
  local form = nx_value("form_stage_main\\form_main\\form_main_select")
  if not nx_is_valid(form) then
    return
  end
end
function get_client_obj_type(client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return -1
  end
  local obj_type = nx_number(client_scene_obj:QueryProp("Type"))
  return obj_type
end
function remove_select_effect(target)
  local game_select_decal = nx_value("GameSelectDecal")
  if nx_is_valid(game_select_decal) then
    game_select_decal:ChangeTarget(nx_null())
  end
end
function set_select_effect(target)
  if nx_is_valid(target) then
    local game_select_decal = nx_value("GameSelectDecal")
    if nx_is_valid(game_select_decal) then
      game_select_decal:ChangeTarget(target)
    end
  end
end
function set_target_model(ident, game_client, game_visual)
  local select_client_obj = game_client:GetSceneObj(nx_string(ident))
  local target_model
  if nx_is_valid(select_client_obj) then
    local type = select_client_obj:QueryProp("Type")
    target_model = game_visual:GetSceneObj(nx_string(ident))
    if type == 2 and nx_is_valid(target_model) then
      target_model = target_model:GetLinkObject("actor_role")
    end
  end
  if target_model == nil or not nx_is_valid(target_model) then
    target_model = nil
  end
  nx_set_value("target_model", target_model)
end
function show_selectobj_form(client_scene_obj)
end
function update_button_pos(form, client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return
  end
  form.btn_flag.Visible = false
  local obj_type = client_scene_obj:QueryProp("Type")
  if obj_type == TYPE_PLAYER then
    local abs_top = form.btn_flag.AbsTop
    local abs_left = form.btn_flag.AbsLeft
    form.btn_miliao.AbsLeft = form.btn_flag.AbsLeft
    form.btn_miliao.AbsTop = abs_top
    form.btn_offline.AbsLeft = form.btn_flag.AbsLeft
    form.btn_offline.AbsTop = abs_top
    abs_left = abs_left - form.btn_chakan.Width
    form.btn_chakan.AbsLeft = abs_left
    form.btn_chakan.AbsTop = abs_top
    abs_left = abs_left - form.btn_jiaohu.Width
    form.btn_jiaohu.AbsLeft = abs_left
    form.btn_jiaohu.AbsTop = abs_top
  elseif obj_type == TYPE_NPC then
    local abs_top = form.btn_flag.AbsTop
    local abs_left = form.btn_flag.AbsLeft
    form.btn_info.AbsLeft = form.btn_flag.AbsLeft
    form.btn_info.AbsTop = abs_top
    abs_left = abs_left - form.btn_copy.Width
    form.btn_copy.AbsLeft = abs_left
    form.btn_copy.AbsTop = abs_top
  end
end
function get_school_name(school_id)
  local gui = nx_value("gui")
  local school_name = ""
  if school_id == "school_shaolin" then
    school_name = gui.TextManager:GetText("ui_neigong_category_sl")
  elseif school_id == "school_wudang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_wd")
  elseif school_id == "school_emei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_em")
  elseif school_id == "school_junzitang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jz")
  elseif school_id == "school_jinyiwei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jy")
  elseif school_id == "school_jilegu" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jl")
  elseif school_id == "school_gaibang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_gb")
  elseif school_id == "school_tangmen" then
    school_name = gui.TextManager:GetText("ui_neigong_category_tm")
  elseif school_id == "school_mingjiao" then
    school_name = gui.TextManager:GetText("ui_neigong_category_mj")
  elseif school_id == "school_tianshan" then
    school_name = gui.TextManager:GetText("ui_neigong_category_ts")
  else
    school_name = gui.TextManager:GetText("ui_task_school_null")
  end
  return school_name
end
function on_look_selectobj_prop(self)
  local selectobj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(selectobj) then
    return 0
  end
  local target_type = selectobj:QueryProp("Type")
  if target_type == TYPE_PLAYER then
    local name = selectobj:QueryProp("Name")
    nx_execute("form_stage_main\\form_role_chakan", "get_player_info", name)
  end
  return 1
end
function on_look_selectobj_binglu(self)
  local selectobj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(selectobj) then
    return 0
  end
  local target_type = selectobj:QueryProp("Type")
  if target_type == TYPE_PLAYER then
    local name = selectobj:QueryProp("Name")
    nx_execute("form_stage_main\\form_binglu_chakan", "get_player_binglu_info", name)
  end
  return 1
end
function on_look_selectobj_tvt(self)
  local selectobj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(selectobj) then
    return 0
  end
  local target_type = selectobj:QueryProp("Type")
  if target_type == TYPE_PLAYER then
    local name = selectobj:QueryProp("Name")
    nx_execute("form_stage_main\\form_tvt_person_info", "get_player_tvt_info", name)
  end
  return 1
end
function on_show_selectobj_menu(self, x, y)
  local form = self.ParentForm
  local lbl = form.lbl_photo
  local gui = nx_value("gui")
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return
  end
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  local select_target_ident = game_role:QueryProp("LastObject")
  local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
  if not nx_is_valid(select_target) then
    return
  end
  local target_type = select_target:QueryProp("Type")
  local is_need_show = 0
  if target_type == TYPE_NPC then
    local npc_type = select_target:QueryProp("NpcType")
    if npc_type == 283 then
      is_need_show = 1
    end
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule and nx_int(is_need_show) <= nx_int(0) then
    return
  end
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "selectobj", "selectobj")
  nx_execute("menu_game", "menu_recompose", menu_game)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx + 25, cury)
  if target_type == TYPE_PLAYER then
    local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
    local scene = game_client:GetScene()
    local is_clone = false
    if nx_is_valid(scene) then
      is_clone = scene:FindProp("SourceID")
    end
    local pkmode = game_role:QueryProp("PKMode")
    local selfArenaSide = game_role:QueryProp("ArenaSide")
    local arenaSide = select_target:QueryProp("ArenaSide")
    if nx_boolean(is_clone) and nx_number(pkmode) == 3 and nx_number(selfArenaSide) ~= nx_number(arenaSide) then
      menu_game.Visible = false
    end
    local IsHideName = select_target:QueryProp("IsHideName")
    local IsHideFace = select_target:QueryProp("IsHideFace")
    if 0 < IsHideName or 0 < IsHideFace then
      local logic_state = target:QueryProp("LogicState")
      if nx_int(logic_state) ~= nx_int(LS_OFFLINEJOB) then
        menu_game.Visible = false
      end
    end
    local in_battle = select_target:QueryProp("BattlefieldState")
    local STATE_ALREADY_ENTER = 3
    if STATE_ALREADY_ENTER == in_battle then
      local ARENA_MODE_SINGLE = 0
      if ARENA_MODE_SINGLE == selfArenaSide then
        menu_game.Visible = false
      elseif selfArenaSide ~= arenaSide then
        menu_game.Visible = false
      end
    end
    if is_in_outlandwar() and selfArenaSide ~= arenaSide then
      menu_game.Visible = false
    end
    if is_in_maze_hunt() then
      menu_game.Visible = false
    end
    if is_in_sjy_school_meet() then
      menu_game.Visible = false
    end
    if is_in_xmg_school_meet() then
      menu_game.Visible = false
    end
    local huashan_gz = nx_value("form_stage_main\\form_huashan\\form_huashan_fight_main")
    if nx_is_valid(huashan_gz) then
      menu_game.Visible = false
    end
    local isSBKiller = select_target:QueryProp("InSBKillBuff")
    if nx_int(isSBKiller) > nx_int(0) then
      menu_game.Visible = false
    end
  end
  if nx_int(game_role:QueryProp("IsSanmeng")) == nx_int(1) then
    menu_game.Visible = false
  end
  if nx_int(game_role:QueryProp("IsNewWarRule")) == nx_int(1) then
    menu_game.Visible = false
  end
  if nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene") and not nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_dead") then
    menu_game.Visible = false
  end
  if nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene") and not nx_execute("form_stage_main\\form_taosha\\apex_util", "is_dead") then
    menu_game.Visible = false
  end
end
function on_groupbox_select_left_double_click(grid)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(sel_obj) then
    return
  end
  local tar_obj_id = sel_obj:QueryProp("LastObject")
  local game_client = nx_value("game_client")
  local tar_obj = game_client:GetSceneObj(nx_string(tar_obj_id))
  nx_execute("custom_sender", "custom_select", tar_obj.Ident)
end
function on_select_photo_box_click(target_face)
  local game_visual = nx_value("game_visual")
  local select_obj_ident = nx_value("select_obj_ident")
  local visual_scene_object = game_visual:GetSceneObj(select_obj_ident)
  if nx_is_valid(visual_scene_object) then
    nx_execute("shortcut_game", "mouse_use_item", visual_scene_object, "left")
  end
end
function del_buff_icon(grid, index)
  grid:DelItem(nx_int(index))
end
function get_buff_level(buff_id, sender_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local SelectObj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(SelectObj) then
    return
  end
  local result = nx_function("get_buffer_info", SelectObj, buff_id, sender_id)
  if result == nil or table.getn(result) < 3 then
    return
  end
  return result[1]
end
function on_imagegrid_buffer_mousein_grid(grid, index)
  local buff_info = nx_string(grid:GetItemName(index))
  if buff_info == "" or buff_info == nil then
    return 1
  end
  local info_lst = util_split_string(buff_info, ",")
  if table.getn(info_lst) < 2 then
    return 1
  end
  local buff_id = info_lst[1]
  local sender_id = info_lst[2]
  if buff_id == "" or buff_id == nil then
    return 1
  end
  if sender_id == nil then
    return 1
  end
  local level = get_buff_level(buff_id, sender_id)
  local str_index = "desc_" .. nx_string(buff_id) .. "_0"
  if level ~= nil and nx_int(level) > nx_int(0) then
    str_index = "desc_" .. nx_string(buff_id) .. "_" .. nx_string(level)
  elseif level == nil then
    return 1
  end
  if buff_id == "buff_EquipOtherBuffFlags" then
    nx_execute("tips_game", "show_special_buffer_tip", grid:GetMouseInItemLeft() + 35, grid:GetMouseInItemTop() + 35, 1, 3, grid.ParentForm)
    return 1
  elseif buff_id == "buff_FoodEatBuffFlags" then
    nx_execute("tips_game", "show_special_buffer_tip", grid:GetMouseInItemLeft() + 35, grid:GetMouseInItemTop() + 35, 1, 4, grid.ParentForm)
    return 1
  end
  local gui = nx_value("gui")
  nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText(str_index), grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
  return 1
end
function get_special_buff_flage_desc(special_buff_rec)
  local selectobj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(selectobj) then
    return ""
  end
  local buffer_effect = nx_value("BufferEffect")
  if not nx_is_valid(buffer_effect) then
    return ""
  end
  local gui = nx_value("gui")
  if not selectobj:FindRecord(nx_string(special_buff_rec)) then
    return ""
  end
  local str_index = ""
  local rownum = selectobj:GetRecordRows(nx_string(special_buff_rec))
  for i = 0, rownum - 1 do
    local buff_id = selectobj:QueryRecord(nx_string(special_buff_rec), i, 0)
    local level = selectobj:QueryRecord(nx_string(special_buff_rec), i, 3)
    if level ~= nil and nx_int(level) > nx_int(0) then
      str_index = str_index .. nx_string(gui.TextManager:GetText("desc_" .. nx_string(buff_id) .. "_" .. nx_string(level))) .. nx_string("<br>")
    else
      str_index = str_index .. nx_string(gui.TextManager:GetText("desc_" .. nx_string(buff_id) .. "_" .. "0")) .. nx_string("<br>")
    end
    local msgdelay = nx_value("MessageDelay")
    local server_time = msgdelay:GetServerNowTime()
    local end_time = selectobj:QueryRecord(nx_string(special_buff_rec), i, 1)
    local live_time = end_time - server_time
    if nx_int(live_time) > nx_int(0) then
      str_index = str_index .. nx_string("<font color=\"#00FF00\">") .. nx_string(gui.TextManager:GetText(nx_string(get_format_time(live_time / 1000)))) .. nx_string("</font>")
    end
    local times = selectobj:QueryRecord(nx_string(special_buff_rec), i, 2)
    if nx_int(times) > nx_int(1) then
      str_index = str_index .. "  " .. nx_string("<font color=\"#FFFF00\">") .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_lay_times", nx_int(times))) .. nx_string("</font>")
    end
    str_index = str_index .. nx_string("<br>")
  end
  return str_index
end
function get_format_time(time)
  if nx_number(time) < nx_number(0) then
    return ""
  end
  local hour = nx_int(nx_number(time) / 3600)
  local minute = nx_int(nx_number(time) % 3600 / 60)
  local second = nx_int(nx_number(time) % 60)
  local gui = nx_value("gui")
  local str = ""
  if nx_int(hour) > nx_int(0) then
    str = str .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_live_time_1", nx_int(hour)))
  end
  if nx_int(minute) > nx_int(0) then
    str = str .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_live_time_2", nx_int(minute)))
  end
  if nx_int(second) > nx_int(0) then
    str = str .. nx_string(gui.TextManager:GetFormatText("ui_special_buff_live_time_3", nx_int(second)))
  end
  return str
end
function on_imagegrid_buffer_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_jiaohu_click(btn)
  local menu_game = nx_value("menu_game")
  local gui = nx_value("gui")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
    menu_game.Visible = false
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(menu_game) then
    if nx_find_custom(menu_game, "type") then
      local type = menu_game.type
      if type ~= "selectobj" and menu_game.Visible then
        menu_game.Visible = false
      end
    end
    menu_game.need_visible = not menu_game.Visible
  end
  timer:UnRegister("form_stage_main\\form_main\\form_main_select", "on_menu_visible_change", btn)
  timer:Register(10, 1, "form_stage_main\\form_main\\form_main_select", "on_menu_visible_change", btn, -1, -1)
end
function on_btn_chakan_click(btn)
  on_look_selectobj_prop()
end
function on_btn_tvt_info_click(btn)
  on_look_selectobj_tvt()
end
function on_btn_miliao_click(btn)
  local form_main_select = nx_value("form_stage_main\\form_main\\form_main_select")
  local form = nx_value("form_stage_main\\form_main\\form_main_chat")
  local gui = nx_value("gui")
  form.chat_channel_btn.Text = gui.TextManager:GetText("ui_chat_channel_3")
  form.chat_edit.chat_type = 3
  gui.Focused = form.chat_edit
  local name = form_main_select.selectobjname
  form.chat_edit.Text = nx_widestr("")
  form.chat_edit:Append(nx_widestr(name), -1)
  form.chat_edit:Append(nx_widestr(" "), -1)
  nx_execute("form_stage_main\\form_main\\form_main_chat", "show_chat")
end
function on_btn_info_click(btn)
  on_look_selectobj_prop()
end
function on_btn_copy_click(btn)
  local sel_obj = nx_value(GAME_SELECT_OBJECT)
  if not nx_is_valid(sel_obj) then
    return
  end
  local name
  local target_type = sel_obj:QueryProp("Type")
  if TYPE_PLAYER == target_type then
    name = sel_obj:QueryProp("Name")
  else
    local config_id = sel_obj:QueryProp("ConfigID")
    local gui = nx_value("gui")
    name = gui.TextManager:GetText(config_id)
  end
  nx_function("ext_copy_wstr", nx_widestr(name))
end
function on_menu_visible_change(btn, need_visible)
  local form = nx_value("form_stage_main\\form_main\\form_main_select")
  if not nx_is_valid(form) then
    return
  end
  local menu_game = nx_value("menu_game")
  local gui = nx_value("gui")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  menu_game.Visible = menu_game.need_visible
  if menu_game.Visible then
    on_show_selectobj_menu(form.btn_jiaohu)
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_main\\form_main_select")
  if not nx_is_valid(form) then
    return
  end
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    return
  end
  if not menu_game.Visible then
    return
  end
  if not nx_find_custom(menu_game, "type") then
    return
  end
  local type = menu_game.type
  if type == "selectobj" then
    menu_game.AbsLeft = form.btn_jiaohu.AbsLeft + form.btn_jiaohu.Width
    menu_game.AbsTop = form.btn_jiaohu.AbsTop + form.btn_jiaohu.Height
  end
end
function select_target_byName(playername)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_client) then
    return
  end
  if not nx_is_valid(game_visual) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local obj_list = client_scene:GetSceneObjList()
  for i = 1, table.maxn(obj_list) do
    local client_scene_obj = obj_list[i]
    local visual_scene_obj = game_visual:GetSceneObj(client_scene_obj.Ident)
    local type = client_scene_obj:QueryProp("Type")
    if type == TYPE_PLAYER then
      local Name = client_scene_obj:QueryProp("Name")
      if nx_string(playername) == nx_string(Name) then
        local fight = nx_value("fight")
        fight:SelectTarget(visual_scene_obj)
      end
    end
  end
end
function get_scene_obj_strength_photo(client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return ""
  end
  if not client_scene_obj:FindProp("Level") and not client_scene_obj:FindProp("PowerLevel") then
    return ""
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if nx_id_equal(client_player, client_scene_obj) then
    return ""
  end
  local self_level = client_player:QueryProp("PowerLevel")
  local obj_level
  local obj_type = client_scene_obj:QueryProp("Type")
  if obj_type == TYPE_PLAYER then
    obj_level = client_scene_obj:QueryProp("PowerLevel")
  elseif obj_type == TYPE_NPC then
    obj_level = client_scene_obj:QueryProp("Level")
  end
  if nil == obj_level then
    return ""
  end
  local diff_level = obj_level - self_level
  if diff_level < -10 then
    return "gui\\special\\monster\\Lv_1.png"
  elseif -10 <= diff_level and diff_level <= 5 then
    return "gui\\special\\monster\\Lv_2.png"
  elseif 6 <= diff_level and diff_level <= 15 then
    return "gui\\special\\monster\\Lv_3.png"
  elseif 16 <= diff_level and diff_level <= 20 then
    return "gui\\special\\monster\\Lv_4.png"
  elseif 20 < diff_level then
    return "gui\\special\\monster\\Lv_5.png"
  end
  return ""
end
function get_scene_obj_strength_photo_special(client_scene_obj)
  if not nx_is_valid(client_scene_obj) then
    return ""
  end
  if not client_scene_obj:FindProp("Level") and not client_scene_obj:FindProp("PowerLevel") then
    return ""
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if nx_id_equal(client_player, client_scene_obj) then
    return ""
  end
  local self_level = client_player:QueryProp("PowerLevel")
  local obj_level
  local obj_type = client_scene_obj:QueryProp("Type")
  if obj_type == TYPE_PLAYER then
    obj_level = client_scene_obj:QueryProp("PowerLevel")
  elseif obj_type == TYPE_NPC then
    obj_level = client_scene_obj:QueryProp("Level")
  end
  if nil == obj_level then
    return ""
  end
  local diff_level = obj_level - self_level
  if diff_level < -10 then
    return "gui\\special\\monster\\mlv_1.png"
  elseif -10 <= diff_level and diff_level <= 5 then
    return "gui\\special\\monster\\mlv_2.png"
  elseif 6 <= diff_level and diff_level <= 15 then
    return "gui\\special\\monster\\mlv_3.png"
  elseif 16 <= diff_level and diff_level <= 20 then
    return "gui\\special\\monster\\mlv_4.png"
  elseif 20 < diff_level then
    return "gui\\special\\monster\\mlv_5.png"
  end
  return ""
end
function color_hex_d(color)
  local r = string.sub(color, 2, 3)
  local g = string.sub(color, 4, 5)
  local b = string.sub(color, 6, 7)
  return "\"255," .. string.format("%d", tonumber(r, 16)) .. "," .. string.format("%d", tonumber(g, 16)) .. "," .. string.format("%d", tonumber(b, 16)) .. "\""
end
function on_lbl_level_get_capture(lbl)
  if lbl.BackImage == "" then
    return
  end
  local gui = nx_value("gui")
  local textinfo = gui.TextManager:GetText("ui_select_lever")
  local power = 0
  if nx_find_custom(lbl, "PowerLevel") then
    power = lbl.PowerLevel
  end
  if power >= ELITE_PLAYER_LEVEL then
    textinfo = textinfo .. nx_widestr("<br>") .. gui.TextManager:GetText("tips_levelpunish_t")
  end
  local x, y = gui:GetCursorPosition()
  x = x - 32
  show_text_tip(nx_widestr(textinfo), x, y, 120, lbl)
end
function on_lbl_level_lost_capture(lbl)
  if lbl.BackImage == "" then
    return
  end
  hide_tip(lbl)
end
function on_refresh_face(form, client_player)
  if not nx_is_valid(form.scenebox_1.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_1)
    form.scenebox_1.Scene.RoundScene = true
  end
  local scene = form.scenebox_1.Scene
  form.scenebox_1.Visible = true
  local select_type = client_player:QueryProp("Type")
  if nx_find_custom(form, "role_actor2") and nx_is_valid(form.role_actor2) then
    clear_form_model(form, form.role_actor2)
  end
  if nx_running(nx_current(), "on_refresh_npc_face") then
    nx_kill(nx_current(), "on_refresh_npc_face")
  end
  if nx_running(nx_current(), "on_refresh_role_face") then
    nx_kill(nx_current(), "on_refresh_role_face")
  end
  if select_type == TYPE_PLAYER then
    nx_execute(nx_current(), "on_refresh_role_face", form, scene, client_player, form.role_actor2)
  else
    nx_execute(nx_current(), "on_refresh_npc_face", form, scene, client_player, form.role_actor2)
  end
end
function get_pi(degree)
  return math.pi * degree / 180
end
function on_refresh_npc_face(form, scene, client_player, role_actor2)
  local resource = client_player:QueryProp("Resource")
  if is_special(resource) then
    form.lbl_photo.BackImage = client_player:QueryProp("Photo")
    form.lbl_photo.Visible = true
    form.scenebox_1.Visible = false
    return nx_null()
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return nx_null()
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return nx_null()
  end
  local npc_actor2 = role_composite:CreateSceneObject(scene, client_player, true, true)
  form.role_actor2 = npc_actor2
  if not nx_is_valid(npc_actor2) or not nx_is_valid(scene) then
    clear_form_model(form, role_actor2)
    return nx_null()
  end
  local time_count = 0
  while nx_is_valid(npc_actor2) and not game_visual:QueryRoleCreateFinish(npc_actor2) do
    time_count = time_count + nx_pause(0)
  end
  local action_time_count = 0
  if not nx_is_valid(npc_actor2) then
    clear_form_model(form, role_actor2)
    return nx_null()
  end
  if npc_actor2:FindAction("ty_stand") ~= -1 then
    if npc_actor2:BlendAction("ty_stand", true, true) then
      while nx_is_valid(npc_actor2) and not (0 < npc_actor2:GetActionFrame("ty_stand")) and action_time_count < 0.2 do
        action_time_count = action_time_count + nx_pause(0)
      end
    end
  else
    if npc_actor2:FindAction("stand") ~= -1 and npc_actor2:BlendAction("stand", true, true) then
      while nx_is_valid(npc_actor2) and not (0 < npc_actor2:GetActionFrame("stand")) and action_time_count < 0.2 do
        action_time_count = action_time_count + nx_pause(0)
      end
    else
    end
  end
  if not nx_is_valid(npc_actor2) then
    clear_form_model(form, role_actor2)
    return nx_null()
  end
  clear_form_model(form, role_actor2)
  npc_actor2.Visible = false
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_1, npc_actor2)
  time_count = 0
  form.role_actor2 = npc_actor2
  while time_count < 0.25 do
    time_count = time_count + nx_pause(0)
  end
  local r = 0.6
  local f_x, f_y, f_z = 0, 0, 0
  local is_angle = false
  if not nx_is_valid(npc_actor2) then
    clear_form_model(form, role_actor2)
    return nx_null()
  end
  if npc_actor2:NodeIsExist("BoneRUe05") then
    f_x, f_y, f_z = npc_actor2:GetNodePosition("BoneRUe05")
    is_angle = true
  end
  form.role_actor2 = npc_actor2
  if nx_find_custom(scene, "camera") and is_angle then
    local camera = scene.camera
    if nx_is_valid(camera) then
      camera:SetPosition(r * math.sin(get_pi(15)) + f_x, f_y, -1 * r * math.cos(get_pi(15)) + f_z)
      camera:SetAngle(0, get_pi(-15), 0)
      camera.Fov = 0.10416666666666667 * math.pi * 2
    end
  end
  npc_actor2.Visible = true
  local fov, far, near, target_dis, target_id = -1, -1, -1, -1, -1
  local c_p_x, c_p_y, c_p_z = -1, -1, -1
  local c_a_x, c_a_y, c_a_z = -1, -1, -1
  if nx_find_custom(scene, "camera") then
    local camera = scene.camera
    if nx_is_valid(camera) then
      local visual_list = npc_actor2:GetVisualList()
      for _, obj in ipairs(visual_list) do
        if "Skin" == nx_name(obj) then
          fov, far, near, target_dis, target_id = obj:GetCameraInfo("head_camera")
          c_p_x, c_p_y, c_p_z = obj:GetHelperPosition("", "head_camera")
          c_a_x, c_a_y, c_a_z = obj:GetHelperAngle("", "head_camera")
          if nil ~= c_p_x and nil ~= c_p_y and nil ~= c_p_z and nil ~= c_a_x and nil ~= c_a_y and nil ~= c_a_z and nx_find_custom(scene, "camera") then
            local camera = scene.camera
            if nx_is_valid(camera) then
              camera:SetPosition(c_p_x, c_p_y, c_p_z)
              camera:SetAngle(c_a_x, c_a_y, c_a_z)
              camera.Fov = fov
              log("ok")
            end
            log("c_p_x = " .. c_p_x .. ", c_p_y = " .. c_p_y .. ", c_p_z = " .. c_p_z)
          end
        end
      end
    end
  end
  console_log("on_refresh_npc_face end")
  return npc_actor2
end
function get_degree(i)
  return 180 * i / math.pi
end
function on_refresh_role_face(form, scene, client_player, actor2)
  local sex = client_player:QueryProp("Sex")
  if not nx_is_valid(scene) then
    clear_form_model(form, actor2)
    return nx_null()
  end
  local role_actor2 = nx_execute("role_composite", "create_actor2", scene)
  if not nx_is_valid(role_actor2) then
    return nx_null()
  end
  form.role_actor2 = role_actor2
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return nx_null()
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return nx_null()
  end
  role_composite:CreateSceneObjectWithActor2(scene, client_player, role_actor2, true, false, false, true)
  if not nx_is_valid(role_actor2) then
    clear_form_model(form, actor2)
    return nx_null()
  end
  while nx_is_valid(role_actor2) and not game_visual:QueryRoleCreateFinish(role_actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(role_actor2) then
    clear_form_model(form, actor2)
    return nx_null()
  end
  local actor_role = role_actor2:GetLinkObject("actor_role")
  local time_count = 0
  while nx_is_valid(role_actor2) and not nx_is_valid(actor_role) and time_count < 2 do
    actor_role = role_actor2:GetLinkObject("actor_role")
    time_count = time_count + nx_pause(0)
  end
  if not nx_is_valid(role_actor2) or not nx_is_valid(actor_role) then
    clear_form_model(form, actor2)
    return nx_null()
  end
  while nx_is_valid(role_actor2) and nx_is_valid(actor_role) and not actor_role.LoadFinish do
    time_count = time_count + nx_pause(0)
  end
  clear_form_model(form, actor2)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_1, role_actor2)
  if sex == 0 then
    actor_role:BlendAction("logoin_stand_2", true, true)
  elseif sex == 1 then
    actor_role:BlendAction("stand", true, true)
  end
  local dr = sex == 0 and 0.55 or 0.5
  local dx = sex == 0 and 0.03 or 0
  local dh = sex == 0 and 1.67 or 1.58
  if nx_is_valid(actor_role) and nx_find_custom(scene, "camera") then
    local camera = scene.camera
    if nx_is_valid(camera) then
      camera:SetPosition(dr * math.sin(get_pi(15)) - dx, dh, -dr * math.cos(get_pi(15)))
      camera:SetAngle(0, get_pi(-15), 0)
    end
  end
  local form_main_buff = nx_value("form_main_buff")
  if not nx_is_valid(form_main_buff) then
    return
  end
  form_main_buff:OnRefreshMaskFace(client_player, true)
  console_log("on_refresh_role_face end")
  return role_actor2
end
function clear_form_model(form, role_actor2)
  if nx_is_valid(role_actor2) then
    form.scenebox_1.Scene:Delete(role_actor2)
  end
end
function show_select_skill(npc, time)
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local attacker_client = game_client:GetSceneObj(nx_string(npc))
  if not nx_is_valid(attacker_client) then
    return
  end
  local skill_id = attacker_client:QueryProp("CurSkillID")
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_select", false, false)
  if not nx_is_valid(form) then
    return
  end
  local select_obj_ident = nx_value("select_obj_ident")
  if nx_string(npc) == nx_string(select_obj_ident) then
    local photo = nx_execute("util_static_data", "skill_static_query_by_id", skill_id, "Photo")
    if photo == "" or photo == nil then
      photo = skill_photo
    end
    form.imagegrid_curskill:AddItem(nx_int(0), photo, "", 0, -1)
    form.lbl_skillname.Text = nx_widestr(gui.TextManager:GetFormatText(skill_id))
    nx_execute(nx_current(), "show_skill_par", form, time)
  else
    form.groupbox_skill.Visible = false
  end
end
function show_skill_par(form, time)
  local space = nx_float(time / 30000)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "groupbox_skill") or not nx_is_valid(form.groupbox_skill) then
    return
  end
  if not nx_find_custom(form, "pbar_curskill") or not nx_is_valid(form.pbar_curskill) then
    return
  end
  form.groupbox_skill.Visible = true
  form.pbar_curskill.Minimum = 0
  form.pbar_curskill.Maxinum = 30
  form.pbar_curskill.Value = 0
  for i = 1, 30 do
    nx_pause(space)
    if not nx_is_valid(form) then
      return
    end
    if not nx_find_custom(form, "groupbox_skill") or not nx_is_valid(form.groupbox_skill) then
      return
    end
    if not nx_find_custom(form, "pbar_curskill") or not nx_is_valid(form.pbar_curskill) then
      return
    end
    form.pbar_curskill.Value = form.pbar_curskill.Value + 1
  end
  form.groupbox_skill.Visible = false
end
local res_info = {
  "monster001",
  "monster002",
  "monster003",
  "monster004",
  "monster006",
  "monster007",
  "monster008",
  "monster009",
  "monster013",
  "monster017",
  "monster018",
  "monster023",
  "monster117",
  "monster118",
  "monster119",
  "monster120",
  "monster127",
  "monster128",
  "monster129",
  "monster130",
  "monster131",
  "monster135",
  "monster136",
  "monster137",
  "monster139",
  "monster550",
  "monster551",
  "monster600",
  "monster603",
  "monster605",
  "monster610",
  "monster611",
  "monster612",
  "fbnpc00010",
  "fbnpc00245",
  "fbnpc00246",
  "fbboss00361",
  "fbnpc019019",
  "fbnpc00004",
  "fbfunnpc00223",
  "fbnpc019020",
  "fbnpc019004",
  "worldnpc1101",
  "worldnpc1104",
  "worldnpc1105",
  "worldnpc1107",
  "worldnpc1110",
  "worldnpc143",
  "worldnpc144",
  "worldnpc145",
  "worldnpc146",
  "worldnpc147",
  "worldnpc148",
  "worldnpc149",
  "worldnpc150",
  "petm_c_0100",
  "petm_c_0200",
  "petm_c_0300",
  "petm_c_0400",
  "petm_c_0500",
  "petm_c_0600",
  "petm_c_0602",
  "petm_c_0603",
  "petm_c_0604",
  "petm_c_0700",
  "petm_c_0800",
  "petm_c_0900",
  "petm_c_1000",
  "petm_c_1001",
  "petm_c_1003",
  "petm_c_1100",
  "petm_c_1200",
  "petm_c_1201",
  "petm_c_1300",
  "petm_c_1400",
  "petm_c_1500",
  "petm_c_1503",
  "petm_c_1600",
  "petm_y_0602",
  "petm_y_0603",
  "petm_y_0604",
  "petm_y_0700",
  "petm_y_0900",
  "petm_y_1000",
  "petm_y_1001",
  "petm_y_1003",
  "petm_y_1100",
  "petm_y_1200",
  "petm_y_1201",
  "petm_y_1300",
  "petm_y_1400",
  "petm_y_1500",
  "petm_y_1503",
  "biaochept01",
  "EscortNpc0200",
  "EscortNpc0201",
  "EscortNpc0202",
  "EscortNpc0203",
  "EscortNpc0204",
  "EscortNpc0205",
  "EscortNpc0206",
  "EscortNpc0207",
  "EscortNpc0208",
  "EscortNpc0209",
  "EscortNpc0210",
  "EscortNpc0211",
  "EscortNpc0212",
  "EscortNpc0213",
  "EscortNpc0214",
  "EscortNpc0215",
  "EscortNpc0216",
  "EscortNpc0217",
  "EscortNpc0218",
  "EscortNpc0219",
  "EscortNpc0220",
  "EscortNpc0221",
  "EscortNpc0222",
  "EscortNpc0223",
  "EscortNpc0224",
  "EscortNpc0225",
  "EscortNpc0226",
  "EscortNpc0227",
  "EscortNpc0228",
  "EscortNpc0229",
  "EscortNpc0230",
  "EscortNpc0231",
  "EscortNpc0232",
  "EscortNpc0233",
  "EscortNpc0234",
  "EscortNpc0235",
  "EscortNpc0236",
  "EscortNpc0237",
  "EscortNpc0238",
  "EscortNpc0239",
  "EscortNpc0240",
  "EscortNpc0241",
  "EscortNpc0242",
  "EscortNpc0243",
  "EscortNpc0244",
  "EscortNpc0245",
  "EscortNpc0246",
  "EscortNpc0247",
  "EscortNpc0248",
  "EscortNpc0249",
  "EscortNpc0250",
  "EscortNpc0251",
  "EscortNpc0252",
  "EscortNpc0253",
  "EscortNpc0254",
  "EscortNpc0255",
  "EscortNpc0256",
  "EscortNpc0257",
  "EscortNpc0258",
  "EscortNpc0259",
  "EscortNpc0260",
  "EscortNpc0261",
  "EscortNpc0262",
  "EscortNpc0263",
  "EscortNpc0264",
  "EscortNpc0265",
  "EscortNpc0300",
  "EscortNpc0301",
  "EscortNpc0302",
  "EscortNpc0303",
  "EscortNpc0304",
  "EscortNpc0305",
  "EscortNpc0306",
  "EscortNpc0307",
  "EscortNpc0308",
  "EscortNpc0309",
  "EscortNpc0310",
  "EscortNpc0311",
  "EscortNpc0312",
  "EscortNpc0313",
  "EscortNpc0314",
  "EscortNpc0315",
  "EscortNpc0316",
  "EscortNpc0317",
  "EscortNpc0318",
  "EscortNpc0319",
  "EscortNpc0320",
  "EscortNpc0321",
  "EscortNpc0322",
  "EscortNpc0323",
  "EscortNpc0324",
  "EscortNpc0325",
  "EscortNpc0326",
  "EscortNpc0327",
  "EscortNpc0328",
  "EscortNpc0329",
  "EscortNpc0330",
  "EscortNpc0331",
  "EscortNpc0332",
  "boss064",
  "boss065",
  "boss068",
  "biaochept01",
  "biaochept02",
  "biaochept03",
  "biaochejg01",
  "biaochejg02",
  "biaochejg03",
  "biaochejl01",
  "biaochejl02",
  "biaochejl03",
  "monster134a",
  "mache001_4nei",
  "petm_c_1502"
}
function is_special(name)
  local config_id = ""
  for i, info in ipairs(res_info) do
    config_id = "npc\\" .. info
    if nx_string(name) == nx_string(config_id) then
      return true
    end
  end
  return false
end
function on_btn_leave_school_type_get_capture(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local select_target_ident = client_player:QueryProp("LastObject")
  local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
  if not nx_is_valid(select_target) then
    return
  end
  if nx_find_custom(select_target, "leave_school_all_text") and nx_find_custom(select_target, "leave_school_info") and nx_find_custom(select_target, "leave_force_info") and nx_find_custom(select_target, "leave_newschool_info") then
    show_leave_school_tips(select_target.leave_school_all_text, select_target.leave_school_info, select_target.leave_force_info, select_target.leave_newschool_info)
  else
    local name = select_target:QueryProp("Name")
    nx_execute("custom_sender", "custom_get_leave_school_info", 2, name)
  end
end
function on_btn_leave_school_type_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function show_leave_school_tips(text, leave_school_info, leave_force_info, leave_newschool_info)
  local gui = nx_value("gui")
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local select_target_ident = client_player:QueryProp("LastObject")
  local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
  if not nx_is_valid(select_target) then
    return
  end
  if nx_is_valid(select_target) and nx_widestr(text) == nx_widestr("") then
    if select_target:FindProp("School") and nx_string(select_target:QueryProp("School")) ~= nx_string("") then
      text = util_text(select_target:QueryProp("School")) .. util_text("ui_pupil")
    elseif select_target:FindProp("Force") and nx_string(select_target:QueryProp("Force")) ~= nx_string("") then
      text = util_text(select_target:QueryProp("Force")) .. util_text("ui_pupil")
    elseif select_target:FindProp("NewSchool") and nx_string(select_target:QueryProp("NewSchool")) ~= nx_string("") then
      text = util_text(select_target:QueryProp("NewSchool")) .. util_text("ui_pupil")
    else
      text = util_text("school_wumenpai") .. util_text("ui_pupil")
    end
    nx_execute("tips_game", "show_text_tip", text, form.btn_leave_school_type.AbsLeft, form.btn_leave_school_type.AbsTop, 400, form)
    return
  end
  if not nx_find_custom(form.btn_leave_school_type, "leave_school_text") then
    return
  end
  local tips_text = nx_widestr("")
  if form.btn_leave_school_type.leave_school_text == nx_widestr("") then
    tips_text = nx_widestr("<font color=\"#FFB428\">") .. gui.TextManager:GetText("ui_jianghu") .. gui.TextManager:GetText("ui_pupil") .. nx_widestr("</font><br>") .. text
  else
    tips_text = nx_widestr("<font color=\"#FFB428\">") .. form.btn_leave_school_type.leave_school_text .. nx_widestr("</font><br>") .. text
  end
  tips_text = tips_text .. get_leave_school_cool_down_text(leave_school_info, leave_force_info, leave_newschool_info)
  if tips_text == nx_widestr("") then
    return
  end
  nx_execute("tips_game", "show_text_tip", tips_text, form.btn_leave_school_type.AbsLeft, form.btn_leave_school_type.AbsTop, 400, form)
end
function get_leave_school_cool_down_text(leave_school_info, leave_force_info, leave_newschool_info)
  local text = nx_widestr("")
  local gui = nx_value("gui")
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return nx_widestr("")
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  if nx_string(leave_school_info) ~= "" and nx_string(leave_school_info) ~= "nil" then
    local day = math.floor(30 - (cur_date_time - nx_double(leave_school_info)))
    if 0 <= day then
      if day == 0 then
        day = 1
      end
      text = text .. gui.TextManager:GetText("ui_count_down_0")
      gui.TextManager:Format_SetIDName("ui_count_down_2")
      gui.TextManager:Format_AddParam(nx_int(day))
      text = text .. gui.TextManager:Format_GetText() .. nx_widestr("<br>")
    end
  end
  if nx_string(leave_force_info) ~= "" and nx_string(leave_force_info) ~= "nil" then
    local force_list = util_split_string(leave_force_info, ";")
    for i = 1, table.getn(force_list) do
      local force_name = util_split_string(force_list[i], ",")[1]
      local force_time = util_split_string(force_list[i], ",")[2]
      if nx_string(force_name) ~= "nil" then
        local day = math.floor(24 - (cur_date_time - nx_double(force_time)))
        if 0 <= day then
          if day == 0 then
            day = 1
          end
          text = text .. gui.TextManager:GetText("ui_count_down_1") .. gui.TextManager:GetText(force_name)
          gui.TextManager:Format_SetIDName("ui_count_down_2")
          gui.TextManager:Format_AddParam(nx_int(day))
          text = text .. gui.TextManager:Format_GetText() .. nx_widestr("<br>")
        end
      end
    end
  end
  if nx_string(leave_newschool_info) ~= "" and nx_string(leave_newschool_info) ~= "nil" then
    local newschool_list = util_split_string(leave_newschool_info, ";")
    for i = 1, table.getn(newschool_list) do
      local newschool_name = util_split_string(newschool_list[i], ",")[1]
      local newschool_time = util_split_string(newschool_list[i], ",")[2]
      if nx_string(newschool_name) ~= "nil" then
        local day = math.floor(24 - (cur_date_time - nx_double(newschool_name)))
        if 0 <= day then
          if day == 0 then
            day = 1
          end
          text = text .. gui.TextManager:GetText("ui_count_down_1") .. gui.TextManager:GetText(newschool_name)
          gui.TextManager:Format_SetIDName("ui_count_down_2")
          gui.TextManager:Format_AddParam(nx_int(day))
          text = text .. gui.TextManager:Format_GetText() .. nx_widestr("<br>")
        end
      end
    end
  end
  return text
end
function on_btn_YY_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(158) then
    return
  end
  local form_yy = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_auth_YY")
  if nx_is_valid(form_yy) and form_yy.Visible then
    form_yy:Close()
    return
  end
  local new_time = os.time()
  if nx_find_custom(btn.ParentForm, "yy_query_time") and new_time - btn.ParentForm.yy_query_time <= 3 then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19892")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  btn.ParentForm.yy_query_time = new_time
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local CLIENT_CUSTOMMSG_GUILD = 1014
  local SUB_CUSTOMMSG_GUILD_BIND_YY_QUERY = 99
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local select_target_ident = client_player:QueryProp("LastObject")
  local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
  if not nx_is_valid(select_target) then
    return
  end
  local guild_name = select_target:QueryProp("GuildName")
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_BIND_YY_QUERY), nx_int(1), guild_name)
end
function is_in_outlandwar()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_OUTLAND_WAR) == PIS_IN_GAME then
    return true
  end
  return false
end
function is_in_maze_hunt()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_MAZE_HUNT_HILL) == PIS_IN_GAME then
    return true
  end
  return false
end
function is_in_sjy_school_meet()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(163) == PIS_IN_GAME then
    return true
  end
  return false
end
function is_in_xmg_school_meet()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_XMG_MEET) == PIS_IN_GAME then
    return true
  end
  return false
end
