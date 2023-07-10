require("util_functions")
require("define\\define")
require("define\\gamehand_type")
require("define\\team_rec_define")
require("form_stage_main\\form_map\\map_logic")
require("share\\logicstate_define")
require("share\\client_custom_define")
require("form_stage_main\\form_task\\task_define")
require("define\\sysinfo_define")
require("util_gui")
require("define\\map_lable_define")
require("tips_data")
require("util_role_prop")
require("form_stage_main\\form_home\\form_home_function")
local TEAM_REC = "team_rec"
local STEP_WORLD = 0
local STEP_AREA = 1
local STEP_SCENE = 3
local PHOTO_COMMIT_NPC = "gui\\map\\icon\\w04.png"
local PHOTO_ACCEPT_NPC = "gui\\map\\icon\\j04.png"
local PHOTO_SELECT_OUT = "gui\\common\\checkbutton\\cbtn_2_out.png"
local PHOTO_SELECT_ON = "gui\\common\\checkbutton\\cbtn_2_on.png"
local PHOTO_SELECT_DOWN = "gui\\common\\checkbutton\\cbtn_2_down.png"
local PHOTO_SELECT2_OUT = "gui\\common\\checkbutton\\cbtn_3_out.png"
local PHOTO_SELECT2_ON = "gui\\common\\checkbutton\\cbtn_3_on.png"
local PHOTO_SELECT2_DOWN = "gui\\common\\checkbutton\\cbtn_3_down.png"
local MLTBOX_WIDTH = 180
local MAP_NEW_INI = "gui\\map\\map_new.ini"
local MAP_PIC_MASK_INI = "gui\\map\\scene_fog.ini"
local CLIENT_MSG_DS_REQUEST_MAP_MARK = 2
local ITT_SCHOOL_COUNTER_ATTACK = 144
local PIS_IN_GAME = 3
local MAP_FORM_NAME = "form_stage_main\\form_map\\form_map_scene"
local PHOTO_HOSTAGE_MARK = "gui\\special\\school_fangong\\school_fangong_renzhi.png"
local PHOTO_BOSS_MARK = "gui\\special\\school_fangong\\school_fangong_boss.png"
table_extincted_scene_config = {
  "ini\\scene\\school01_mie",
  "ini\\scene\\school02_mie",
  "ini\\scene\\school03_mie",
  "ini\\scene\\school04_mie",
  "ini\\scene\\school05_mie",
  "ini\\scene\\school06_mie",
  "ini\\scene\\school07_mie",
  "ini\\scene\\school08_mie",
  "ini\\scene\\school01_fangong",
  "ini\\scene\\school02_fangong",
  "ini\\scene\\school03_fangong",
  "ini\\scene\\school04_fangong",
  "ini\\scene\\school05_fangong",
  "ini\\scene\\school06_fangong",
  "ini\\scene\\school07_fangong",
  "ini\\scene\\school08_fangong"
}
map_area = {
  jiangnan = "8,24,7,14,3,15",
  xinan = "23,22,1,21,10,17,9",
  xibei = "25,2,26",
  huabei = "13,4,18,5,20,6,19",
  zhongyuan = "16,12,11",
  donghai = "603,604,605",
  all = "23,22,1,21,10,17,9,8,24,7,14,3,15,25,2,26,13,4,18,5,20,6,19,16,12,11"
}
function can_open_map()
  local gui = nx_value("gui")
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return false
  end
  local can_open = map_query:CanOpen(map_query:GetCurrentScene())
  if false == can_open then
    local text = gui.TextManager:GetText("3800")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    local form = nx_value("form_stage_main\\form_map\\form_map_scene")
    if nx_is_valid(form) then
      local open_type = map_query:GetMapOpenType()
      if open_type == 0 then
        form.Visible = false
      else
        form:Close()
      end
    end
    return false
  else
    return true
  end
end
function open_form()
  auto_show_hide_map_scene()
end
function auto_show_hide_map_scene()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  local gui = nx_value("gui")
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  if not can_open_map() then
    return
  end
  local big_map_limit = false
  local role = nx_value("role")
  if nx_is_valid(role) and nx_find_custom(role, "big_map_limit") then
    big_map_limit = role.big_map_limit
  end
  if big_map_limit then
    local text = gui.TextManager:GetText("3800")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    if nx_is_valid(form) then
      local open_type = form.map_query:GetMapOpenType()
      if open_type == 0 then
        form.Visible = false
      else
        form:Close()
      end
    end
    return
  end
  local open_type = map_query:GetMapOpenType()
  if open_type == 0 then
    if nx_is_valid(form) then
      form.Visible = not form.Visible
      if form.Visible then
        update_form_on_timer(form)
        set_role_to_map_center(form)
        render_main_waypoints()
        init_scene_list(form)
        local index = form.combobox_is_show_task.DropListBox.SelectIndex
        is_show_task(form, index)
        clear_faction(form)
        turn_to_scene_map(form, form.map_query:GetCurrentScene())
        local form_filter = nx_value("form_stage_main\\form_map\\form_map_scene")
        if not nx_is_valid(form_filter) then
          nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_map\\form_map_scene")
        end
        form.is_open = true
        update_form_map_set()
        gui.Desktop:ToFront(form)
        nx_execute("form_stage_main\\form_marry\\form_dongfang_info", "show_marry_pos", form)
        change_form_size()
        init_btn_newdrop_box(form.btn_newdrop_box)
      else
        hide_all(form)
        form.is_open = false
        mouse_right_up()
        local form_label_list = nx_value("form_stage_main\\form_map\\form_map_label_list")
        if nx_is_valid(form_label_list) then
          form_label_list.Visible = false
        end
        local form_tianqi = nx_value("form_stage_main\\form_main\\form_main_tianqi")
        if nx_is_valid(form_tianqi) then
          form_tianqi:Close()
        end
        nx_execute("tips_game", "hide_tip", form)
        nx_execute("form_stage_main\\form_marry\\form_dongfang_info", "hide_marry_pos", form)
        local form_drop = nx_value("form_stage_main\\form_map\\form_map_drop")
        if nx_is_valid(form_drop) then
          form_drop:Close()
        end
        local form_clearfog = nx_value("form_stage_main\\form_map\\form_newmap_clearfog")
        if nx_is_valid(form_clearfog) then
          form_clearfog:Close()
        end
      end
    else
      nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_map\\form_map_scene")
    end
  elseif nx_is_valid(form) then
    form:Close()
  else
    local form = util_get_form("form_stage_main\\form_map\\form_map_scene", true, false, "", true)
    form_load_finish(form)
  end
  if nx_is_valid(form) then
    form.rbtn_scene_map.Checked = true
    local bIsNewJHModule = is_newjhmodule()
    if bIsNewJHModule then
      form.pic_mask.Visible = not canclosemask()
    else
      form.pic_mask.Visible = false
    end
    request_sca_npc_pos(form)
    hide_map_btn()
    add_jyf_icon()
  end
end
function form_load_finish(form)
  if not nx_is_valid(form) then
    return
  end
  while nx_is_valid(form) and not form.LoadFinish do
    nx_pause(0.1)
  end
  nx_pause(0.1)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_is_valid(form) then
    if form.map_query:GetMapOpenType() == 0 and not form.Visible then
      return
    end
    if form.groupbox_shangren.Visible then
      form.groupbox_shangren.AbsLeft = form.cbtn_shangren.AbsLeft
      form.groupbox_shangren.AbsTop = form.cbtn_shangren.AbsTop - form.groupbox_shangren.Height
    elseif form.groupbox_caiji.Visible then
      form.groupbox_caiji.AbsLeft = form.cbtn_caiji.AbsLeft
      form.groupbox_caiji.AbsTop = form.cbtn_caiji.AbsTop - form.groupbox_caiji.Height
    elseif form.groupbox_wanfa.Visible then
      form.groupbox_wanfa.AbsLeft = form.cbtn_wanfa.AbsLeft
      form.groupbox_wanfa.AbsTop = form.cbtn_wanfa.AbsTop - form.groupbox_wanfa.Height
    elseif form.groupbox_base.Visible then
      form.groupbox_base.AbsLeft = form.cbtn_base.AbsLeft
      form.groupbox_base.AbsTop = form.cbtn_base.AbsTop - form.groupbox_base.Height
    elseif form.groupbox_life.Visible then
      form.groupbox_life.AbsLeft = form.cbtn_life.AbsLeft
      form.groupbox_life.AbsTop = form.cbtn_life.AbsTop - form.groupbox_life.Height
    end
    local gui = nx_value("gui")
    local desktop = gui.Desktop
    form.Left = (desktop.Width - form.Width) / 2
    form.Top = (desktop.Height - form.Height) / 2
  end
end
function mouse_right_up()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_is_valid(form) and nx_find_custom(form.pic_map, "right_down") and form.pic_map.right_down then
    on_pic_map_right_up(form.pic_map, 0, 0)
  end
end
function prepare_scene_data()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  local scene_name = form.map_query:GetCurrentScene()
  if nx_find_custom(form, "pre_scene") and nil ~= form.pre_scene and scene_name ~= form.pre_scene then
    form.map_query:UnloadNpcCreator(form.pre_scene)
  end
  if nil ~= scene_name then
    form.pre_scene = scene_name
    form.map_query:LoadNpcCreator(scene_name)
  end
end
function set_current_scene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_is_valid(form) then
    local scene_config = client_scene:QueryProp("ConfigID")
    local current_scene = gui.TextManager:GetText(scene_config)
    form.lbl_current_scene.Text = nx_widestr(current_scene)
    local scene_name = form.map_query:GetCurrentScene()
    local area_name = form.map_query:GetAreaOfScene(scene_name)
    show_area_player(form)
  end
end
function reset_scene()
  prepare_scene_data()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_is_valid(form) then
    local visible = form.Visible
    form:Close()
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_map\\form_map_scene")
    local form = nx_value("form_stage_main\\form_map\\form_map_scene")
    if nx_is_valid(form) and can_open_map() then
      form.Visible = visible
    end
  else
    local map_query = nx_value("MapQuery")
    if not nx_is_valid(map_query) then
      return
    end
    local open_type = map_query:GetMapOpenType()
    if 0 == open_type then
      nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_map\\form_map_scene")
      local form = nx_value("form_stage_main\\form_map\\form_map_scene")
      form.Visible = false
    end
  end
end
function hide_map_label_detail()
  local dialog = nx_value("form_stage_main\\form_map\\form_map_label_detail")
  if nx_is_valid(dialog) then
    dialog:Close()
  end
end
function main_form_init(form)
  form.Fixed = false
  form.no_need_motion_alpha = true
  form.map_query = nx_value("MapQuery")
  form.current_map = ""
  form.pre_scene = nil
  form.form_world = nil
  form.watched_area = nil
  form.show_teammates = false
  form.show_role_pos = true
  form.current_step = nil
  form.domain_id1 = ""
  form.domain_id2 = ""
  form.is_open = false
  form.last_time = 0
  local file_name = "mapui.ini"
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and nx_find_property(game_config, "login_account") then
    local account = game_config.login_account
    file_name = account .. "\\" .. "mapui.ini"
  end
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  ini:LoadFromFile()
  form.map_ui_ini = ini
  local area = form.map_query:GetCurrentArea()
  form.watched_area = area
  local texture_tool = nx_value("TextureTool")
  if not nx_is_valid(texture_tool) then
    texture_tool = nx_create("TextureTool")
  end
  form.texture_tool = texture_tool
  return 1
end
function main_form_open(form)
  form.pic_map.AsyncLoad = false
  form.btn_dir.Visible = false
  form.btn_trace.Visible = false
  form.btn_newdrop_box.Visible = false
  form.groupbox_faction_1.show = false
  form.groupbox_faction_2.show = false
  form.groupbox_faction_1.Visible = false
  form.groupbox_faction_2.Visible = false
  form.pic_map.init_width = form.pic_map.Width
  form.pic_map.init_left = form.pic_map.Left
  form.pic_map.left_down = false
  form.pic_map.right_down = false
  form.pic_map.mouse_move = false
  form.pic_map.drag_move = false
  form.pic_map.TerrainStartX = 0
  form.pic_map.TerrainStartZ = 0
  form.pic_map.TerrainWidth = 1024
  form.pic_map.TerrainHeight = 1024
  form.pic_map.max_zoom_width = 1.2
  form.pic_map.max_zoom_height = 1.2
  form.pic_mask.Left = form.pic_map.Left
  form.pic_mask.Top = form.pic_map.Top
  form.pic_mask.Width = form.pic_map.Width
  form.pic_mask.Height = form.pic_map.Height
  form.pic_mask.Visible = false
  form.pic_mask.old_pos_x = 0
  form.pic_mask.old_pos_y = 0
  form.map_query:GroupmapInit(form)
  init_form_set(form)
  turn_to_scene_map(form, form.map_query:GetCurrentScene())
  set_current_scene()
  render_main_waypoints()
  update_direction_hint(form)
  set_role_to_map_center(form)
  local databinder = nx_value("data_binder")
  databinder:AddTableBind("OpenMapRec", form, nx_current(), "update_scene_list_by_OpenMapRec")
  databinder:AddTableBind("Task_Accepted", form, nx_current(), "update_record_Task_Accepted")
  databinder:AddTableBind("Task_Record", form, nx_current(), "update_task_record_change")
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "update_form_on_timer", form, -1, -1)
  timer:Register(5000, -1, nx_current(), "refresh_npc_pos", form, -1, -1)
  nx_execute("freshman_help", "form_on_open_callback", "form_stage_main\\form_map\\form_map_scene")
  change_form_size()
  form.rbtn_task.Checked = true
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.combobox_is_show_task.DropListBox:ClearString()
    form.combobox_is_show_task.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_task_off")))
    form.combobox_is_show_task.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_task_on")))
    form.combobox_is_show_task.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_task2_on")))
    form.combobox_is_show_task.DropListBox.SelectIndex = 0
    form.combobox_is_show_task.InputEdit.Text = form.combobox_is_show_task.DropListBox:GetString(0)
    is_show_task(form, 0)
  end
  local asynor = nx_value("common_execute")
  if nx_is_valid(asynor) then
    asynor:AddExecute("RefreshMapScenePlayer", form, 0)
    asynor:AddExecute("RefreshMapMaskPic", form, 0)
  end
  form.lbl_chouren.Visible = false
  form.lbl_zhuizong.Visible = false
  request_sca_npc_pos(form)
  if is_extinct_scene(form) then
    extinct_scene_hide(form)
  end
end
function main_form_close(form)
  save_fog_info()
  clear_move_npc_icon(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "update_form_on_timer", form)
  timer:UnRegister(nx_current(), "refresh_npc_pos", form)
  local asynor = nx_value("common_execute")
  if nx_is_valid(asynor) then
    asynor:RemoveExecute("RefreshMapScenePlayer", form)
    asynor:RemoveExecute("RefreshMapMaskPic", form)
  end
  local databinder = nx_value("data_binder")
  databinder:DelTableBind("OpenMapRec", form)
  databinder:DelTableBind("Task_Accepted", form)
  databinder:DelTableBind("Task_Record", form)
  form.map_query:ClearTeamMates()
  form.map_query:ClearDropBox()
  form.map_query:ClearEscortInfo()
  form.map_query:ClearQiZhiInfo()
  form.map_query:ClearMapMarkLabel()
  if nx_find_method(form.map_query, "ClearMapScene") then
    form.map_query:ClearMapScene(form)
  end
  nx_execute("freshman_help", "form_on_close_callback", "form_stage_main\\form_map\\form_map_scene")
  clean_before_step(form)
  if nx_find_custom(form, "map_ui_ini") and nx_is_valid(form.map_ui_ini) then
    form.map_ui_ini:SaveToFile()
    nx_destroy(form.map_ui_ini)
    form.map_ui_ini = nx_null()
  end
  if nx_find_custom(form, "label_ini") and nx_is_valid(form.label_ini) then
    form.label_ini:SaveToFile()
    nx_destroy(form.label_ini)
    form.label_ini = nx_null()
  end
  if nx_find_custom(form, "current_map") and form.map_query:GetCurrentScene() ~= form.current_map then
    form.map_query:UnloadNpcCreator(form.current_map)
  end
  form.map_query = nx_null()
  if nx_running(nx_current(), "form_load_finish") then
    nx_kill(nx_current(), "form_load_finish")
  end
  if nx_running(nx_current(), "refresh_scene_map") then
    nx_kill(nx_current(), "refresh_scene_map")
  end
  if nx_running(nx_current(), "turn_to_scene_map") then
    nx_kill(nx_current(), "turn_to_scene_map")
  end
  if nx_running(nx_current(), "auto_show_hide_map_scene") then
    nx_kill(nx_current(), "auto_show_hide_map_scene")
  end
  if nx_running(nx_current(), "main_form_open") then
    nx_kill(nx_current(), "main_form_open")
  end
  mouse_right_up()
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    IniManager:UnloadIniFromManager(MAP_PIC_MASK_INI)
    IniManager:UnloadIniFromManager(MAP_NEW_INI)
  end
  local form_drop = nx_value("form_stage_main\\form_map\\form_map_drop")
  if nx_is_valid(form_drop) then
    form_drop:Close()
  end
  if nx_is_valid(form.texture_tool) then
    nx_destroy(form.texture_tool)
  end
  nx_destroy(form)
end
function on_btn_help_checked_changed(self)
  local data = "tsjl,xingzoujh02,jiaotongzn03,ditu04"
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", data)
end
function init_scene_list(form)
  form.groupbox_scene_list.AbsLeft = form.groupbox_select.AbsLeft
  form.groupbox_scene_list.AbsTop = form.groupbox_select.AbsTop
  form.groupbox_scene_list.Width = form.groupbox_select.Width
  form.groupbox_scene_list.Height = form.groupbox_select.Height
  form.groupscrollbox_static.AbsLeft = form.groupbox_scene_list.AbsLeft
  form.groupscrollbox_static.AbsTop = form.groupbox_scene_list.AbsTop
  form.groupscrollbox_static.Width = form.groupbox_scene_list.Width
  form.groupscrollbox_static.Height = form.groupbox_scene_list.Height - form.groupscrollbox_static.Top - 20
  form.btn_xinan.Expand = false
  form.btn_xibei.Expand = false
  form.btn_huabei.Expand = false
  form.btn_zhongyuan.Expand = false
  form.btn_jiangnan.Expand = false
  form.btn_donghai.Expand = false
  update_scene_list(form)
end
function folder_scene_list(form)
  form.btn_xinan.Expand = false
  form.btn_xibei.Expand = false
  form.btn_huabei.Expand = false
  form.btn_zhongyuan.Expand = false
  form.btn_jiangnan.Expand = false
  form.btn_donghai.Expand = false
  update_scene_list(form)
end
function unfolder_scene_list(form, area_name)
  local btns = {
    form.btn_xinan,
    form.btn_xibei,
    form.btn_huabei,
    form.btn_zhongyuan,
    form.btn_jiangnan,
    form.btn_donghai
  }
  for _, btn in ipairs(btns) do
    btn.Expand = btn.DataSource == area_name
  end
  update_scene_list(form)
end
function update_scene_list(form)
  local left_of_groupbox_area = form.groupbox_xinan.Left
  local left_of_groupbox_scene = form.groupbox_xinan_scene.Left
  form.groupbox_xibei.Left = left_of_groupbox_area
  form.groupbox_huabei.Left = left_of_groupbox_area
  form.groupbox_zhongyuan.Left = left_of_groupbox_area
  form.groupbox_jiangnan.Left = left_of_groupbox_area
  form.groupbox_donghai.Left = left_of_groupbox_area
  form.groupbox_xibei_scene.Left = left_of_groupbox_scene
  form.groupbox_huabei_scene.Left = left_of_groupbox_scene
  form.groupbox_zhongyuan_scene.Left = left_of_groupbox_scene
  form.groupbox_jiangnan_scene.Left = left_of_groupbox_scene
  form.groupbox_donghai_scene.Left = left_of_groupbox_scene
  form.groupbox_xinan_scene.Visible = form.btn_xinan.Expand
  form.groupbox_xibei_scene.Visible = form.btn_xibei.Expand
  form.groupbox_huabei_scene.Visible = form.btn_huabei.Expand
  form.groupbox_zhongyuan_scene.Visible = form.btn_zhongyuan.Expand
  form.groupbox_jiangnan_scene.Visible = form.btn_jiangnan.Expand
  form.groupbox_donghai_scene.Visible = form.btn_donghai.Expand
  form.groupbox_xinan.AbsTop = form.groupbox_area_list.AbsTop
  local height = form.groupbox_xinan.Top + form.groupbox_xinan.Height
  if form.groupbox_xinan_scene.Visible then
    form.groupbox_xinan_scene.Top = height
    height = form.groupbox_xinan_scene.Top + form.groupbox_xinan_scene.Height
  end
  form.groupbox_xibei.Top = height
  height = form.groupbox_xibei.Top + form.groupbox_xibei.Height
  if form.groupbox_xibei_scene.Visible then
    form.groupbox_xibei_scene.Top = height
    height = form.groupbox_xibei_scene.Top + form.groupbox_xibei_scene.Height
  end
  form.groupbox_huabei.Top = height
  height = form.groupbox_huabei.Top + form.groupbox_huabei.Height
  if form.groupbox_huabei_scene.Visible then
    form.groupbox_huabei_scene.Top = height
    height = form.groupbox_huabei_scene.Top + form.groupbox_huabei_scene.Height
  end
  form.groupbox_zhongyuan.Top = height
  height = form.groupbox_zhongyuan.Top + form.groupbox_zhongyuan.Height
  if form.groupbox_zhongyuan_scene.Visible then
    form.groupbox_zhongyuan_scene.Top = height
    height = form.groupbox_zhongyuan_scene.Top + form.groupbox_zhongyuan_scene.Height
  end
  form.groupbox_jiangnan.Top = height
  height = form.groupbox_jiangnan.Top + form.groupbox_jiangnan.Height
  if form.groupbox_jiangnan_scene.Visible then
    form.groupbox_jiangnan_scene.Top = height
    height = form.groupbox_jiangnan_scene.Top + form.groupbox_jiangnan_scene.Height
  end
  form.groupbox_donghai.Top = height
  height = form.groupbox_donghai.Top + form.groupbox_donghai.Height
  if form.groupbox_donghai_scene.Visible then
    form.groupbox_donghai_scene.Top = height
    height = form.groupbox_donghai_scene.Top + form.groupbox_donghai_scene.Height
  end
  form.groupbox_area_list.Height = height + 20
  form.groupbox_area_list.Width = form.groupbox_xinan.Width
  form.groupscrollbox_static.IsEditMode = false
  form.groupscrollbox_static:ResetChildrenYPos()
  update_scene_list_by_OpenMapRec(form)
end
function update_scene_list_by_OpenMapRec(form)
  form.map_query:UpdateSceneListByOpenMapRec(form)
end
function on_btn_scene_area_click(self)
  local form = self.ParentForm
  local step = form.current_step
  if step == STEP_WORLD then
    unfolder_scene_list(form, self.DataSource)
    turn_to_area_map(form, self.DataSource)
  elseif step == STEP_AREA then
    unfolder_scene_list(form, self.DataSource)
    turn_to_area_map(form, self.DataSource)
  elseif step == STEP_SCENE then
    unfolder_scene_list(form, self.DataSource)
    turn_to_area_map(form, self.DataSource)
  end
end
function on_btn_spot_click(self)
  local scene = nx_string(self.DataSource)
  local form = self.ParentForm
  if form.map_query:IsSceneVisited(scene) then
    turn_to_scene_map(self.ParentForm, scene)
  end
end
function turn_to_current_scene_map(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  if form.current_step ~= STEP_SCENE then
    local resource = client_scene:QueryProp("Resource")
    turn_to_scene_map(form, resource)
  end
end
function on_btn_road_click(self)
  local form = self.ParentForm
  show_main_waypoints(form, not form.main_path.Visible)
end
function on_btn_home_click(self)
  local form = self.ParentForm
  local step = form.current_step
  if step == STEP_SCENE then
    set_role_to_map_center(form)
  end
end
function on_btn_back_click(self)
  local form = self.ParentForm
  local step = form.current_step
  if step == STEP_AREA then
    turn_to_world_map(form)
  elseif step == STEP_SCENE then
    init_scene_list(form)
    turn_to_area_map(form, form.watched_area, nil)
  end
  form.btn_add_label.Enabled = false
  form.btn_find_pos.Enabled = false
  form.can_add_label = false
  hide_all(form)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  map_query:DeleteAllLabel()
end
function show_main_waypoints(form, visible)
  form.main_path.Visible = visible
  render_main_waypoints()
end
function on_btn_alpha_click(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  local open_type = form.map_query:GetMapOpenType()
  if open_type == 0 then
    form.Visible = false
    local form_filter = nx_value("form_stage_main\\form_map\\form_map_label_list")
    if nx_is_valid(form_filter) then
      form_filter.Visible = false
      form_filter.btn_label.Checked = false
      local gui = nx_value("gui")
      if nx_is_valid(gui) then
        gui.GameHand:ClearHand()
      end
    end
    hide_all(form)
    local form_tianqi = nx_value("form_stage_main\\form_main\\form_main_tianqi")
    if nx_is_valid(form_tianqi) then
      form_tianqi:Close()
    end
    local form_drop = nx_value("form_stage_main\\form_map\\form_map_drop")
    if nx_is_valid(form_drop) then
      form_drop:Close()
    end
  else
    form:Close()
  end
end
function on_lbl_spot_click(lbl)
  local form = lbl.ParentForm
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local resource = client_scene:QueryProp("Resource")
  turn_to_scene_map(form, resource)
end
function turn_to_world_map(form)
  form.current_step = STEP_WORLD
  clean_before_step(form)
  form.pic_map.Left = form.pic_map.init_left
  form.pic_map.Width = form.pic_map.init_width
  local map_name = "gui\\map\\world\\world.png"
  form.current_map = "world"
  form.pic_map.Image = map_name
  form.lbl_role.Visible = false
  form.show_role_pos = form.map_query:IsPlayerInScene("world")
  refresh_world_map(form)
  local cur_scene = form.map_query:GetCurrentScene()
  if not nx_find_custom(form, "form_world") then
    return
  end
  local form_world = form.form_world
  local groupbox = form_world.groupbox_3
  local childs = groupbox:GetChildControlList()
  for _, child in ipairs(childs) do
    local cur_area = nx_string(child.DataSource)
    local sence_lst = form.map_query:GetScenesOfArea(cur_area)
    local bshow = false
    counts = table.getn(sence_lst)
    for i = 1, counts do
      if sence_lst[i] == cur_scene then
        bshow = true
      end
      child.Visible = bshow
    end
  end
  folder_scene_list(form)
end
function create_form_world(form, list, xml)
  local gui = nx_value("gui")
  local form_world = nx_execute("util_gui", "util_get_form", xml, true, false)
  form.form_world = form_world
  local ret = form:Add(form_world)
  local abs_left = form.lbl_back.AbsLeft
  local abs_top = form.lbl_back.AbsTop
  local abs_width = form.lbl_back.Width
  local abs_height = form.lbl_back.Height
  form_world.AbsLeft = abs_left
  form_world.AbsTop = abs_top
  form_world.groupbox_1.Left = 0
  form_world.groupbox_1.Top = 0
  form_world.groupbox_2.Left = 0
  form_world.groupbox_2.Top = 0
  form_world.groupbox_1.Width = abs_width
  form_world.groupbox_1.Height = abs_height
  form_world.groupbox_2.Width = abs_width
  form_world.groupbox_2.Height = abs_height
  local rateX = nx_float(abs_width / form_world.Width)
  local rateY = nx_float(abs_height / form_world.Height)
  form_world.Width = abs_width - 4
  form_world.Height = abs_height - 2
  local itemtable = form_world.groupbox_1:GetChildControlList()
  for i = 1, table.getn(itemtable) do
    local newleft = itemtable[i].Left * rateX
    local newtop = itemtable[i].Top * rateY
    local newwidth = itemtable[i].Width * rateX
    local newheight = itemtable[i].Height * rateY
    itemtable[i].Left = newleft
    itemtable[i].Top = newtop
    itemtable[i].Width = newwidth
    itemtable[i].Height = newheight
    itemtable[i].name = list[i]
    itemtable[i].form = form
    nx_bind_script(itemtable[i], nx_current())
    nx_callback(itemtable[i], "on_click", "on_click_btn")
  end
  local labeltable = form_world.groupbox_2:GetChildControlList()
  for i = 1, table.getn(labeltable) do
    local newleft = labeltable[i].Left * rateX
    local newtop = labeltable[i].Top * rateY
    local newwidth = labeltable[i].Width * rateX
    local newheight = labeltable[i].Height * rateY
    labeltable[i].Left = newleft
    labeltable[i].Top = newtop
    labeltable[i].Width = newwidth
    labeltable[i].Height = newheight
  end
end
function on_btn_tianqi_click(self)
  local form_tianqi = nx_value("form_stage_main\\form_main\\form_main_tianqi")
  if nx_is_valid(form_tianqi) then
    form_tianqi:Close()
    return
  end
  local form = self.ParentForm
  local cur_time = nx_function("ext_get_tickcount")
  if cur_time - form.last_time < 1000 then
    return
  end
  form.last_time = cur_time
  if nx_is_valid(form) and form.Visible then
    nx_execute("custom_sender", "custom_get_area_tianqi", map_area.all, 2)
  end
end
function refresh_world_map(form)
  local list = form.map_query:GetAreasOfWorld()
  local xml = form.map_query:GetGuiXmlOfWorld()
  create_form_world(form, list, xml)
  modify_zorder(form)
end
function on_click_btn(btn)
  local form = btn.form
  if form.current_step == STEP_WORLD then
    if nx_find_custom(btn, "name") and "jinling" == btn.name then
    else
      unfolder_scene_list(form, btn.name)
      turn_to_area_map(form, btn.name, nil)
    end
  elseif form.current_step == STEP_AREA then
    local scene_name = btn.DataSource
    if nil ~= scene_name and "" ~= scene_name and form.map_query:IsSceneVisited(scene_name) then
      turn_to_scene_map(form, scene_name)
    end
  end
end
function on_btn_up_click(self)
  self.mouse_down_move_up = false
end
function on_btn_up_push(self)
  local form = self.ParentForm
  self.mouse_down_move_up = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while nx_is_valid(form) and self.mouse_down_move_up do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_y = form.pic_map.CenterY - 10
    if center_z_min >= center_y then
      center_y = center_z_min
    end
    form.pic_map.CenterY = center_y
    render_main_waypoints()
    update_form_on_timer(form)
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdatePolygonBox(false)
      mgr:UpdateGuildPkArena(false)
      mgr:UpdateSchoolPkArena(false)
      mgr:UpdateArenaCircle()
      mgr:UpdateAllArea(false)
    end
    form.map_query:UpdateMapLabel()
    update_map_mark_info(form)
    if center_z_min >= center_y then
      break
    end
  end
end
function on_btn_down_click(self)
  self.mouse_down_move_down = false
end
function on_btn_down_push(self)
  local form = self.ParentForm
  self.mouse_down_move_down = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while nx_is_valid(form) and self.mouse_down_move_down do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_y = form.pic_map.CenterY + 10
    if center_z_max <= center_y then
      center_y = center_z_max
    end
    form.pic_map.CenterY = center_y
    render_main_waypoints()
    update_form_on_timer(form)
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdatePolygonBox(false)
      mgr:UpdateGuildPkArena(false)
      mgr:UpdateSchoolPkArena(false)
      mgr:UpdateArenaCircle()
      mgr:UpdateAllArea(false)
    end
    form.map_query:UpdateMapLabel()
    update_map_mark_info(form)
    if center_z_max <= center_y then
      break
    end
  end
end
function on_btn_left_click(self)
  self.mouse_down_move_left = false
end
function on_btn_left_push(self)
  local form = self.ParentForm
  self.mouse_down_move_left = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while nx_is_valid(form) and self.mouse_down_move_left do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_x = form.pic_map.CenterX - 10
    if center_x_min >= center_x then
      center_x = center_x_min
    end
    form.pic_map.CenterX = center_x
    form.pic_mask.CenterX = center_x
    render_main_waypoints()
    update_form_on_timer(form)
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdatePolygonBox(false)
      mgr:UpdateGuildPkArena(false)
      mgr:UpdateSchoolPkArena(false)
      mgr:UpdateArenaCircle()
      mgr:UpdateAllArea(false)
    end
    form.map_query:UpdateMapLabel()
    update_map_mark_info(form)
    if center_x_min >= center_x then
      break
    end
  end
end
function on_btn_right_click(self)
  self.mouse_down_move_right = false
end
function on_btn_right_push(self)
  local form = self.ParentForm
  self.mouse_down_move_right = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while nx_is_valid(form) and self.mouse_down_move_right do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_x = form.pic_map.CenterX + 10
    if center_x_max <= center_x then
      center_x = center_x_max
    end
    form.pic_map.CenterX = center_x
    form.pic_mask.CenterX = center_x
    render_main_waypoints()
    update_form_on_timer(form)
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdatePolygonBox(false)
      mgr:UpdateGuildPkArena(false)
      mgr:UpdateSchoolPkArena(false)
      mgr:UpdateArenaCircle()
      mgr:UpdateAllArea(false)
    end
    form.map_query:UpdateMapLabel()
    update_map_mark_info(form)
    if center_x_max <= center_x then
      break
    end
  end
end
function on_tbar_zoom_value_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form.pic_map, "min_zoom_width") then
    return
  end
  local ratio = self.Value / (self.Maximum - self.Minimum)
  ratio = 1 - ratio
  local zoom_width = form.pic_map.min_zoom_width + ratio * (form.pic_map.max_zoom_width - form.pic_map.min_zoom_width)
  local zoom_height = form.pic_map.min_zoom_height + ratio * (form.pic_map.max_zoom_height - form.pic_map.min_zoom_height)
  set_map_zoom(form, zoom_width, zoom_height)
  render_main_waypoints()
  update_form_on_timer(form)
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    mgr:UpdatePolygonBox(false)
    mgr:UpdateGuildPkArena(false)
    mgr:UpdateSchoolPkArena(false)
    mgr:UpdateArenaCircle()
    mgr:UpdateAllArea(false)
  end
  form.map_query:UpdateMapLabel()
  update_map_mark_info(form)
end
function on_btn_zoom_in_push(self)
  local form = self.ParentForm
  if not nx_find_custom(form.pic_map, "min_zoom_width") then
    return
  end
  self.mouse_down_zoom_in = true
  while nx_is_valid(form) and self.mouse_down_zoom_in do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local zoom_width = form.pic_map.ZoomWidth + 0.05
    local zoom_height = form.pic_map.ZoomHeight + 0.05
    if zoom_width >= form.pic_map.max_zoom_width or zoom_height >= form.pic_map.max_zoom_height then
      zoom_width = form.pic_map.max_zoom_width
      zoom_height = form.pic_map.max_zoom_height
    end
    local ratio = (zoom_width - form.pic_map.min_zoom_width) / (form.pic_map.max_zoom_width - form.pic_map.min_zoom_width)
    ratio = 1 - ratio
    form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
    set_map_zoom(form, zoom_width, zoom_height)
    render_main_waypoints()
    update_form_on_timer(form)
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdatePolygonBox(false)
      mgr:UpdateGuildPkArena(false)
      mgr:UpdateSchoolPkArena(false)
      mgr:UpdateArenaCircle()
      mgr:UpdateAllArea(false)
    end
    form.map_query:UpdateMapLabel()
    update_map_mark_info(form)
  end
end
function on_btn_zoom_in_click(self)
  local form = self.ParentForm
  self.mouse_down_zoom_in = false
end
function on_btn_zoom_out_push(self)
  local form = self.ParentForm
  if not nx_find_custom(form.pic_map, "min_zoom_width") then
    return
  end
  self.mouse_down_zoom_out = true
  while nx_is_valid(form) and self.mouse_down_zoom_out do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local zoom_width = form.pic_map.ZoomWidth - 0.05
    local zoom_height = form.pic_map.ZoomHeight - 0.05
    if zoom_width <= form.pic_map.min_zoom_width or zoom_height <= form.pic_map.min_zoom_height then
      zoom_width = form.pic_map.min_zoom_width
      zoom_height = form.pic_map.min_zoom_height
    end
    local ratio = (zoom_width - form.pic_map.min_zoom_width) / (form.pic_map.max_zoom_width - form.pic_map.min_zoom_width)
    ratio = 1 - ratio
    form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
    set_map_zoom(form, zoom_width, zoom_height)
    render_main_waypoints()
    update_form_on_timer(form)
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdatePolygonBox(false)
      mgr:UpdateGuildPkArena(false)
      mgr:UpdateSchoolPkArena(false)
      mgr:UpdateArenaCircle()
      mgr:UpdateAllArea(false)
    end
    form.map_query:UpdateMapLabel()
    update_map_mark_info(form)
  end
end
function on_btn_zoom_out_click(self)
  local form = self.ParentForm
  self.mouse_down_zoom_out = false
end
function turn_to_area_map(form, name, opencity)
  if name == nil then
    return
  end
  local sence_lst = form.map_query:GetGuiXmlOfArea(name)
  if sence_lst == nil then
    return
  end
  form.groupbox_label_set.Visible = false
  form.groupbox_new_jh_label_set.Visible = false
  local gui = nx_value("gui")
  form.current_step = STEP_AREA
  form.watched_area = name
  clean_before_step(form)
  form.pic_map.Left = form.pic_map.init_left
  form.pic_map.Width = form.pic_map.init_width
  form.current_map = name
  form.show_role_pos = form.map_query:IsPlayerInScene(name)
  refresh_area_map(form, name, opencity)
  show_team_labels(form)
  show_area_player(form)
  if name ~= "" and name ~= nil then
    nx_execute("custom_sender", "custom_get_area_tianqi", map_area[name], 1)
  end
  unfolder_scene_list(form, name)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    hide_control()
  else
    form.groupbox_scene_list.Visible = true
    form.groupbox_task.Visible = false
    form.groupbox_1.Visible = false
    form.groupbox_scene_page.Visible = false
    form.Width = 920
    form.Height = 680
  end
end
function create_form_area(form, list, xml)
  form.lbl_pos.Visible = false
  if xml == nil or xml == "" then
    return
  end
  local subform = nx_execute("util_gui", "util_get_form", xml, true, false)
  form.form_world = subform
  local ret = form:Add(subform)
  nx_execute("form_stage_main\\form_map\\form_map_area_logic", "fix_area_form", form, subform)
end
function refresh_area_map(form, name)
  local list = form.map_query:GetScenesOfArea(name)
  local xml = form.map_query:GetGuiXmlOfArea(name)
  create_form_area(form, list, xml)
  modify_zorder(form)
end
function show_team_labels(form)
  if form.current_step ~= STEP_AREA then
    return
  end
  if not nx_find_custom(form, "form_world") then
    return
  end
  local form_world = form.form_world
  if not nx_is_valid(form_world) then
    return
  end
  if not nx_find_custom(form_world, "groupbox_5") then
    return
  end
  local lbl_lst = form_world.groupbox_5:GetChildControlList()
  for index, lbl in ipairs(lbl_lst) do
    lbl.Visible = false
  end
end
function show_area_tianqi(info)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  if form.current_step ~= STEP_AREA then
    return
  end
  if not nx_find_custom(form, "form_world") then
    return
  end
  local form_world = form.form_world
  if not nx_is_valid(form_world) then
    return
  end
  if not nx_find_custom(form_world, "groupbox_tianqi") then
    return
  end
  form_world:ToFront(form_world.groupbox_tianqi)
  local list = util_split_string(info, ";")
  local info_num = table.getn(list)
  for i = 1, info_num do
    local label = form_world.groupbox_tianqi:Find("lbl_tianqi_" .. nx_string(i))
    if nx_is_valid(label) then
      if nx_string(list[i]) ~= "0" then
        label.BackImage = "wt_" .. nx_string(list[i])
      else
        label.BackImage = ""
      end
    end
  end
end
function on_lbl_team_get_capture(lbl)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  local scene_name = nx_string(lbl.DataSource)
  local text = get_team_members(scene_name)
  if text ~= "" then
    local gui = nx_value("gui")
    nx_execute("tips_game", "show_text_tip", nx_widestr(text), lbl.AbsLeft + lbl.Width / 2, lbl.AbsTop - lbl.Height / 2, 0, form)
  end
end
function on_lbl_team_lost_capture(lbl)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  nx_execute("tips_game", "hide_tip", form)
end
function show_area_player(form)
  if form.current_step ~= STEP_AREA then
    return
  end
  if not nx_find_custom(form, "form_world") then
    return
  end
  local form_world = form.form_world
  if nil == form_world or not nx_is_valid(form_world) then
    return
  end
  if not nx_find_custom(form_world, "groupbox_6") then
    return
  end
  local cur_scene = form.map_query:GetCurrentScene()
  if cur_scene == nil then
    return
  end
  local groupbox = form_world.groupbox_6
  local childs = groupbox:GetChildControlList()
  for _, child in ipairs(childs) do
    local scene_name = nx_string(child.DataSource)
    child.Visible = scene_name == cur_scene
  end
end
function turn_to_scene_map(form, name)
  form.map_query:GetFaction(form, name)
  local spot_scene_name = form.map_query:GetSpotScene(name)
  if form.current_map == name and spot_scene_name == "" then
    return
  end
  local find = form.map_query:CanFindLabel(name)
  local add = form.map_query:CanAddLabel(name)
  if true == find then
    form.btn_find_pos.Enabled = true
  else
    form.btn_find_pos.Enabled = false
  end
  if true == add then
    form.btn_add_label.Enabled = true
    form.can_add_label = true
  else
    form.btn_add_label.Enabled = false
    form.can_add_label = false
  end
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    mgr:UpdatePolygonBox(true)
    mgr:UpdateGuildPkArena(true)
    mgr:UpdateSchoolPkArena(true)
    mgr:UpdateArenaCircle()
    mgr:UpdateAllArea(false)
  end
  form.current_step = STEP_SCENE
  clean_before_step(form)
  refresh_scene_map(form, name)
  form.lbl_role.Visible = form.map_query:IsPlayerInScene(name)
  form.show_role_pos = form.map_query:IsPlayerInScene(name)
  form.lbl_pos.Visible = true
  set_role_to_map_center(form)
  render_main_waypoints()
  local index = form.combobox_is_show_task.DropListBox.SelectIndex
  is_show_task(form, index)
  update_form_map_set()
  refresh_trace_info(form)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    hide_control()
  else
    form.groupbox_scene_list.Visible = false
    form.groupbox_scene_page.Visible = not form.rbtn_task.Checked
    form.groupbox_task.Visible = form.rbtn_task.Checked
    form.groupbox_label_set.Visible = true
    form.groupbox_1.Visible = true
    form.Width = 920
    form.Height = 680
  end
  form.tree_search_npc.VScrollBar.Value = 0
  form.tree_npc.VScrollBar.Value = 0
  if nx_find_custom(form.map_query, "npc_id") and nx_find_custom(form.map_query, "x") and nx_find_custom(form.map_query, "y") and nx_find_custom(form.map_query, "z") and nx_find_custom(form.map_query, "scene_id") then
    set_trace_npc_id(form.map_query.npc_id, form.map_query.x, form.map_query.y, form.map_query.z, form.map_query.scene_id, false)
  end
  local form_label_list = nx_value("form_stage_main\\form_map\\form_map_label_list")
  if nx_is_valid(form_label_list) then
    nx_execute("form_stage_main\\form_map\\form_map_label_list", "update_label_groupbox", form_label_list)
  end
  if is_extinct_scene(form) then
    extinct_scene_hide(form)
  end
  add_jyf_icon()
end
function refresh_scene_map(form, name)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local gui = nx_value("gui")
  local resource = client_scene:QueryProp("Resource")
  if name ~= nil then
    resource = name
  end
  local file_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".ini"
  local map_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".dds"
  local image_name = resource
  local spot_scene_name = form.map_query:GetSpotScene(resource)
  if spot_scene_name ~= "" then
    file_name = "gui\\map\\scene\\" .. resource .. "\\" .. spot_scene_name .. ".ini"
    map_name = "gui\\map\\scene\\" .. resource .. "\\" .. spot_scene_name .. ".dds"
    image_name = spot_scene_name
  end
  if nx_find_custom(form.pic_map, "init_left") then
    form.pic_map.Left = form.pic_map.init_left
  end
  if nx_find_custom(form.pic_map, "init_width") then
    form.pic_map.Width = form.pic_map.init_width
  end
  form.pic_map.Image = map_name
  form.current_map = resource
  local ini = get_ini(file_name)
  if not nx_is_valid(ini) then
    nx_msgbox(get_msg_str("msg_418") .. file_name)
    return
  end
  local map_max_scale = 1
  local res_ini = get_ini("ini\\res_ver.ini")
  if nx_is_valid(res_ini) then
    local sect_index = res_ini:FindSectionIndex("config")
    if 0 <= sect_index then
      map_max_scale = res_ini:ReadFloat(sect_index, "map_max_scale", 1)
    end
  end
  form.pic_map.TerrainStartX = ini:ReadInteger("Map", "StartX", 0)
  form.pic_map.TerrainStartZ = ini:ReadInteger("Map", "StartZ", 0)
  form.pic_map.TerrainWidth = ini:ReadInteger("Map", "Width", 1024)
  form.pic_map.TerrainHeight = ini:ReadInteger("Map", "Height", 1024)
  local real_zoom_width = form.pic_map.TerrainWidth / form.pic_map.ImageWidth
  local real_zoom_height = form.pic_map.TerrainHeight / form.pic_map.ImageHeight
  local max_zoom_width = real_zoom_width
  local max_zoom_height = real_zoom_height
  local min_zoom_width = form.pic_map.Width / form.pic_map.ImageWidth
  local min_zoom_height = form.pic_map.Height / form.pic_map.ImageHeight
  if max_zoom_width < min_zoom_width then
    max_zoom_width = min_zoom_width
  end
  if max_zoom_height < min_zoom_height then
    max_zoom_height = min_zoom_height
  end
  local max_zoom_value = 1.2
  if max_zoom_width > max_zoom_value then
    max_zoom_width = max_zoom_value
  end
  if max_zoom_height > max_zoom_value then
    max_zoom_height = max_zoom_value
  end
  form.pic_map.min_zoom_width = min_zoom_width
  form.pic_map.min_zoom_height = min_zoom_height
  form.pic_map.max_zoom_width = max_zoom_width * map_max_scale
  form.pic_map.max_zoom_height = max_zoom_height * map_max_scale
  form.pic_map.ImageWidthOrg = 0
  form.pic_map.ImageHeightOrg = 0
  form.pic_map.AddXL = 0
  form.pic_map.AddXR = 0
  form.pic_map.AddYU = 0
  form.pic_map.AddYD = 0
  form.pic_map.CenterX = form.pic_map.ImageWidth / 2
  form.pic_map.CenterY = form.pic_map.ImageHeight / 2
  form.pic_mask.Left = form.pic_map.Left
  form.pic_mask.Top = form.pic_map.Top
  form.pic_mask.Width = form.pic_map.Width
  form.pic_mask.Height = form.pic_map.Height
  form.pic_mask.TextureWidth = form.pic_map.ImageWidth
  form.pic_mask.TextureHeight = form.pic_map.ImageHeight
  form.pic_mask.ZoomWidth = form.pic_map.ZoomWidth
  form.pic_mask.ZoomHeight = form.pic_map.ZoomHeight
  form.pic_mask.CenterX = form.pic_map.CenterX
  form.pic_mask.CenterY = form.pic_map.CenterY
  form.pic_mask.MaskTexture = get_ini_prop(MAP_PIC_MASK_INI, "back_image", "map_back_image", "")
  if is_newjhmodule() then
    local device_caps = nx_value("device_caps")
    local card_level = 1
    if nx_is_valid(device_caps) then
      card_level = nx_execute("device_test", "get_video_card_level", device_caps)
    end
    if card_level <= 1 then
      form.pic_mask.DownLevel = 4
    end
    form.pic_mask:CreateTexture()
    load_fog_info(form)
  end
  local scene_name = gui.TextManager:GetText("scene_" .. resource)
  form.lbl_current_scene.Text = nx_widestr(scene_name)
  form.tree_search_npc.Visible = false
  form.tree_npc.Visible = true
  if is_extinct_scene(form) then
    extinct_create_scene_npc(form)
  else
    create_scene_npc(form)
  end
  local ratio = (form.pic_map.ZoomWidth - form.pic_map.min_zoom_width) / (form.pic_map.max_zoom_width - form.pic_map.min_zoom_width)
  ratio = 1 - ratio
  local value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
  if value < 0 or 100 < value then
    value = 0
  end
  form.tbar_zoom.Value = value
  on_tbar_zoom_value_changed(form.tbar_zoom)
  modify_zorder(form)
  show_main_waypoints(form, false)
  local is_random = ini:ReadInteger("Map", "random", 1)
  local random_info = client_scene:QueryProp("RandomTerrainInfo")
  if random_info ~= "" and is_random == 0 then
    local res = create_random_terrain_map(form, resource, image_name, form.pic_map.ImageWidth, form.pic_map.ImageHeight)
    if not res then
      form.pic_map.Image = map_name
    end
  end
end
function on_lbl_click(lbl)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(lbl) then
    return
  end
  if nx_find_custom(lbl, "id") then
    local id = lbl.id
    local target_scene = form.map_query:GetTransNpcScene(nx_string(id))
    if "" ~= target_scene and nil ~= target_scene then
      turn_to_scene_map(form, nx_string(target_scene))
      return
    end
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  if lbl.npc_type == 0 then
    if trace_flag == 1 or trace_flag == 2 then
      path_finding:FindPath(lbl.x, lbl.y, lbl.z, 0)
    end
  elseif lbl.npc_type == 240 or lbl.npc_type == 241 or lbl.npc_type == 242 or lbl.npc_type == 243 or lbl.npc_type == 244 then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return 0
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CLONE_STRONGPOINT_MSG), nx_int(lbl.npc_type))
  else
    local form = nx_value("form_stage_main\\form_map\\form_map_scene")
    if trace_flag == 1 or trace_flag == 2 then
      path_finding:TraceTargetByID(form.current_map, lbl.x, lbl.y, lbl.z, 1.8, lbl.npc_id)
    end
  end
end
function set_trace_npc_id(npc_id, npc_x, npc_y, npc_z, scene_id, no_center)
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local btn_trace = form_map.btn_trace
  if not nx_find_custom(btn_trace, "npc_id") then
    btn_trace.npc_id = nil
  end
  if not nx_find_custom(btn_trace, "scene_id") then
    btn_trace.scene_id = nil
  end
  form_map.btn_trace.old_npc_id = form_map.btn_trace.npc_id
  form_map.btn_trace.old_scene_id = form_map.btn_trace.scene_id
  form_map.btn_trace.scene_id = scene_id
  form_map.btn_trace.npc_id = npc_id
  form_map.btn_trace.x = nx_number(nx_int(npc_x))
  form_map.btn_trace.y = nx_number(nx_int(npc_y))
  form_map.btn_trace.z = nx_number(nx_int(npc_z))
  local map_query = form_map.map_query
  if not nx_find_custom(map_query, "npc_id") then
    map_query.npc_id = nil
  end
  if not nx_find_custom(map_query, "scene_id") then
    map_query.scene_id = nil
  end
  map_query.old_npc_id = map_query.npc_id
  map_query.old_scene_id = map_query.scene_id
  map_query.scene_id = scene_id
  map_query.npc_id = npc_id
  map_query.x = nx_number(nx_int(npc_x))
  map_query.y = nx_number(nx_int(npc_y))
  map_query.z = nx_number(nx_int(npc_z))
  if map_query.old_npc_id == nil then
    map_query.old_npc_id = map_query.npc_id
  end
  if map_query.old_scene_id == nil then
    map_query.old_scene_id = map_query.scene_id
  end
  if not no_center and npc_id ~= nil and npc_x ~= nil and npc_z ~= nil then
    if scene_id == form_map.current_map then
      set_map_center_according_world_pos(form_map, npc_x, npc_z)
    else
      local path_finding = nx_value("path_finding")
      if nx_is_valid(path_finding) then
        local draw_count = path_finding:GetDrawPointCount(form_map.current_map, true)
        if 0 < draw_count then
          dest_point = path_finding:GetPointByIndex(draw_count - 1, form_map.current_map)
          if dest_point ~= nil and dest_point[1] ~= nil and dest_point[3] ~= nil then
            set_map_center_according_world_pos(form_map, dest_point[1], dest_point[3])
          end
        end
      end
    end
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "set_trace_npc_id", npc_id, npc_x, npc_z, scene_id)
end
function on_btn_trace_click(self)
  local form = self.ParentForm
  local map_query = form.map_query
  if not nx_find_custom(map_query, "x") or map_query.x == nil then
    return
  end
  if not nx_find_custom(map_query, "y") or map_query.y == nil then
    return
  end
  if not nx_find_custom(map_query, "z") or map_query.z == nil then
    return
  end
  if not nx_find_custom(map_query, "scene_id") or map_query.scene_id == nil then
    return
  end
  local npc_id
  if nx_find_custom(map_query, "npc_id") and map_query.npc_id ~= nil then
    npc_id = map_query.npc_id
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  if trace_flag == 3 then
    return
  end
  if npc_id == nil then
    path_finding:FindPathScene(map_query.scene_id, map_query.x, map_query.y, map_query.z, 0)
  else
    path_finding:TraceTargetByID(map_query.scene_id, map_query.x, map_query.y, map_query.z, 1.8, map_query.npc_id)
  end
end
function on_btn_trace_get_capture(self)
  local flag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
  local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if flag or flag_apex then
    return
  end
  local form = self.ParentForm
  local map_query = form.map_query
  local x, z, npc_id, scene_id
  if not nx_find_custom(map_query, "x") then
    return
  end
  if not nx_find_custom(map_query, "z") then
    return
  end
  if not nx_find_custom(map_query, "scene_id") then
    return
  end
  x = map_query.x
  z = map_query.z
  scene_id = map_query.scene_id
  if nx_find_custom(map_query, "npc_id") then
    npc_id = map_query.npc_id
  end
  local text = nx_widestr("(") .. nx_widestr(x) .. nx_widestr(",") .. nx_widestr(z) .. nx_widestr(")")
  local gui = nx_value("gui")
  if npc_id ~= nil and nx_string(gui.TextManager:GetText(npc_id)) ~= "" then
    text = gui.TextManager:GetText(npc_id) .. nx_widestr("<br>") .. text
  end
  if scene_id ~= nil and form.current_map ~= scene_id then
    local scene_name = gui.TextManager:GetText("scene_" .. scene_id)
    text = nx_widestr(scene_name) .. nx_widestr("<br>") .. text
  end
  nx_execute("tips_game", "show_text_tip", text, self.AbsLeft, self.AbsTop, 0, form)
end
function on_btn_trace_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function add_defined_label(form, x, y, z, npc_type, id)
  local key = 1
  local bFindKey = false
  for i = 1, 1000 do
    local bFind = form.label_ini:FindItem("MapLabel", nx_string(i))
    if not bFind then
      key = i
      bFindKey = true
      break
    end
  end
  if not bFindKey then
    return
  end
  npc_type = npc_type or "1996"
  form.groupmap_objs:AddLabel(npc_type, x, y, z, nx_string(key), nx_widestr(id))
  form.label_ini:WriteString("MapLabel", nx_string(key), nx_string(form.current_map) .. "," .. nx_string(id) .. "," .. x .. "," .. y .. "," .. z .. "," .. npc_type)
  form.label_ini:SaveToFile()
  nx_execute("form_stage_main\\form_map\\form_map_label_list", "add_map_label", nx_string(key))
end
function add_defined_label_byhtml(form, x, y, z, npc_type, id, scene_id)
  local key = 1
  local bFindKey = false
  for i = 1, 1000 do
    local bFind = form.label_ini:FindItem("MapLabel", nx_string(i))
    if not bFind then
      key = i
      bFindKey = true
      break
    end
  end
  if not bFindKey then
    return
  end
  npc_type = npc_type or "1996"
  if nx_string(form.current_map) == nx_string(scene_id) then
    form.groupmap_objs:AddLabel(npc_type, nx_float(x), nx_float(y), nx_float(z), nx_string(key), nx_widestr(id))
    nx_execute("form_stage_main\\form_map\\form_map_func", "update_label_npc")
  end
  form.label_ini:WriteString("MapLabel", nx_string(key), nx_string(scene_id) .. "," .. nx_string(id) .. "," .. x .. "," .. y .. "," .. z .. "," .. npc_type)
  form.label_ini:SaveToFile()
  nx_execute("form_stage_main\\form_map\\form_map_label_list", "add_map_label", nx_string(key))
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, SYSTYPE_FIGHT, "3801")
end
function groupmap_begin(form)
  form.groupmap_objs:Clear()
  form.groupmap_objs.Left = form.pic_map.Left
  form.groupmap_objs.Top = form.pic_map.Top
  form.groupmap_objs.Width = form.pic_map.Width
  form.groupmap_objs.Height = form.pic_map.Height
  form.groupmap_objs:InitTerrain(form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  if nx_find_custom(form, "label_ini") and nx_is_valid(form.label_ini) then
    form.label_ini:SaveToFile()
  else
    form.label_ini = nx_create("IniDocument")
  end
  form.map_query:LoadMapLabel(form)
  form.map_query:LoadMapText(form, form.current_map)
end
function on_groupmap_objs_click_obj(self, obj_type, id, npc_type, x, y, z)
  self.x = x
  self.y = y
  self.z = z
  self.id = id
  self.npc_id = id
  self.npc_type = npc_type
  on_lbl_click(self)
end
function on_groupmap_objs_mouse_in_obj(self, obj_type, id, npc_type, x, y, z)
  local form = self.ParentForm
  if obj_type == 3 then
    return
  end
  if form.pic_mask.Visible then
    return
  end
  local gui = nx_value("gui")
  local text = nx_widestr("")
  local str_id = ""
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  if form.map_query:HasNpcTypeInfo(nx_string(npc_type)) then
    str_id = form.map_query:GetNpcTypeStrId(nx_string(npc_type))
    local title = gui.TextManager:GetText(str_id)
    local name = gui.TextManager:GetText(id)
    text = gui.TextManager:GetFormatText("<font color=\"#B9B29F\">[{@0:type}]</font><br><font color=\"#FFFFFF\">{@1:name}</font><br><font color=\"#ED5F00\">({@2:x},{@3:y})</font>", title, name, nx_int(x), nx_int(z))
  else
    local str_name = id
    local str_scene_name = ""
    if nx_find_custom(form, "label_ini") and nx_is_valid(form.label_ini) then
      local ini = form.label_ini
      local sect = "MapLabel"
      local value = ini:ReadString(sect, nx_string(id), "")
      local tuple = util_split_string(value, ",")
      if 0 < table.getn(tuple) then
        local show_name = nx_widestr(tuple[2])
        if nx_ws_length(show_name) > 6 then
          show_name = nx_function("ext_ws_substr", show_name, 0, 6)
        end
        str_name = show_name
        str_scene_name = gui.TextManager:GetText("scene_" .. nx_string(nx_string(tuple[1])))
      end
    end
    text = gui.TextManager:GetFormatText("<font color=\"#FFFFFF\">{@0:name}</font><br><font color=\"#B9B29F\">[{@1:scene}]</font><br><font color=\"#ED5F00\">({@2:x},{@3:y})</font>", str_name, nx_widestr(str_scene_name), nx_int(x), nx_int(z))
  end
  text = nx_widestr(text)
  if text ~= nx_widestr("") then
    local sx, sz = trans_scene_pos_to_map(x, z, form.pic_map, form.current_step)
    local AbsLeft = form.pic_map.AbsLeft + sx - 10
    local AbsTop = form.pic_map.AbsTop + sz - 60
    local show_tips = true
    if nx_find_custom(form.pic_map, "right_down") and form.pic_map.right_down == true then
      show_tips = false
    end
    if show_tips then
      local form = nx_value("form_stage_main\\form_map\\form_map_scene")
      nx_execute("tips_game", "show_text_tip", nx_widestr(text), AbsLeft, AbsTop, 0, form)
    end
  end
end
function on_groupmap_objs_mouse_out_obj(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_ipt_name_enter(self)
  local form = self.ParentForm
  local sel_node = form.tree_search_npc.SelectNode
  if nx_is_valid(sel_node) then
    show_tree_node_npc(form, sel_node, false)
  end
  local key_word = self.Text
  search_npc(form, key_word)
  form.tree_npc.Visible = false
  form.tree_search_npc.Visible = true
end
function on_btn_tree_click(self)
  local form = self.ParentForm
  form.tree_search_npc.Visible = false
  form.tree_search_npc.SelectNode = form.tree_search_npc.RootNode
  form.tree_npc.Visible = true
end
function search_npc(form, key)
  local tree = form.tree_search_npc
  local root = tree.RootNode
  if nx_is_valid(root) then
    root:ClearNode()
  end
  form.tree_search_npc.Visible = true
  form.tree_npc.Visible = false
  if nx_execute("util_functions", "is_space", nx_string(key)) then
    form.tree_search_npc.Visible = false
    return
  end
  fill_scene_npc_tree(form, form.current_map, tree)
  local found = false
  local root_npc = form.tree_npc.RootNode
  if not nx_is_valid(root_npc) then
    return
  end
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    mgr:AddNpcToSearchTree(key)
  end
  remove_empty_node(tree)
  local tree = form.tree_search_npc
  local root = tree.RootNode
  local area_nodes = root:GetNodeList()
  for _, area_nd in ipairs(area_nodes) do
    area_nd.Expand = true
  end
  if not found then
    tree.Visible = false
  else
    tree.Visible = true
  end
end
function remove_empty_node(tree)
  local root = tree.RootNode
  if not nx_is_valid(root) then
    return
  end
  local area_nodes = root:GetNodeList()
  for _, area_node in ipairs(area_nodes) do
    local sub_nodes = area_node:GetNodeList()
    for _, subarea_node in ipairs(sub_nodes) do
      if 0 == subarea_node:GetNodeCount() then
        area_node:RemoveNode(subarea_node)
      else
      end
    end
    if 0 == area_node:GetNodeCount() then
    else
    end
  end
end
function on_btn_search_click(self)
  local form = self.ParentForm
  on_ipt_name_enter(form.ipt_name)
end
function scene_npc_search_tree_add_npc(form, tree, main_area, sub_area, configid, npc_type, x, z)
  local gui = nx_value("gui")
  local root = tree.RootNode
  local node_area = root:FindNode(gui.TextManager:GetText(main_area))
  if not nx_is_valid(node_area) then
    return
  end
  local mark = form.map_query:GetNpcTypeMark(npc_type)
  local node_sub_area = node_area:FindNodeByMark(nx_int(mark))
  if not nx_is_valid(node_sub_area) then
    return
  end
  local name = gui.TextManager:GetText(configid)
  local child = node_sub_area:FindNode(name)
  if nx_is_valid(child) then
    return
  end
  child = node_sub_area:CreateNode(nx_widestr(name))
  child.npc_id = configid
  child.main_area = main_area
  child.sub_area = sub_area
  child.TextOffsetX = 30
  child.TextOffsetY = 4
  child.ExpandCloseOffsetX = 10
  child.ExpandCloseOffsetY = 8
  child.NodeImageOffsetX = 16
  child.NodeImageOffsetY = 2
  child.ItemHeight = 26
  child.NodeFocusImage = "gui\\common\\treeview\\tree_3_on.png"
  child.NodeSelectImage = "gui\\common\\treeview\\tree_3_on.png"
  child.Font = "font_treeview"
  child.ShadowColor = "0,255,0,0"
  child.x = x
  child.z = z
  npc_type = nx_string(npc_type)
  if npc_type == "1" or npc_type == "2" or npc_type == "3" or npc_type == "4" or npc_type == "6" then
    child.ImageIndex = form.map_query:GetNpcLevelPhotoIndex(configid)
  end
end
function on_tree_search_npc_select_changed(self, sel_node, old_node)
  local form = self.ParentForm
  show_search_tree_node_npc(form, old_node, false)
  show_search_tree_node_npc(form, sel_node, true)
  if nx_find_custom(sel_node, "x") and nx_find_custom(sel_node, "z") and nx_find_custom(sel_node, "npc_id") and nx_find_custom(sel_node, "npc_type") then
    set_map_center_according_world_pos(form, sel_node.x, sel_node.z)
    form.groupmap_objs.x = sel_node.x
    form.groupmap_objs.y = sel_node.y
    form.groupmap_objs.z = sel_node.z
    form.groupmap_objs.id = sel_node.npc_id
    form.groupmap_objs.npc_id = sel_node.npc_id
    form.groupmap_objs.npc_type = sel_node.npc_type
    on_lbl_click(form.groupmap_objs)
  end
end
function show_search_tree_node_npc(form, node, flag)
  if not nx_is_valid(node) then
    return
  end
  if nx_find_custom(node, "main_area") and nx_find_custom(node, "sub_area") and nx_find_custom(node, "npc_id") then
    if flag then
      local is_show = false
      is_show = creat_PolygonBox(node.npc_id, node.sub_area, "", "")
      if not is_show then
        form.groupmap_objs:ShowAreaBind(node.main_area, node.npc_id, flag)
      end
    else
      local mgr = nx_value("SceneCreator")
      if nx_is_valid(mgr) then
        mgr:DeletePolygonBox(node.npc_id)
      end
      if not check_npc_type(node.npc_type) then
        form.groupmap_objs:ShowAreaBind(node.main_area, node.npc_id, flag)
      end
    end
  elseif nx_find_custom(node, "main_area") and nx_find_custom(node, "MinNpcType") and nx_find_custom(node, "MaxNpcType") then
    if flag then
      node.ForeColor = "255,255,255,255"
    elseif node.Mark == 1 or node.Mark == 7 then
      node.ForeColor = "255,255,0,0"
    else
      node.ForeColor = "255,76,61,44"
    end
  end
end
function update_scene_npc_tree_for_role(form)
  if form.current_step ~= STEP_SCENE then
    return nx_null()
  end
  if not form.map_query:IsPlayerInScene(form.current_map) then
    return nx_null()
  end
  local scene_area_name = ""
  local role = nx_value("role")
  if nx_is_valid(role) and nx_find_custom(role, "scene") and nx_is_valid(role.scene) and nx_find_custom(role.scene, "terrain") and nx_is_valid(role.scene.terrain) then
    local scene = role.scene
    local terrain = scene.terrain
    scene_area_name = terrain:GetAreaName(role.PositionX, role.PositionZ)
  end
  if not nx_is_valid(form.tree_npc.RootNode) then
    return
  end
  local player_node = nx_null()
  local nodes = form.tree_npc.RootNode:GetNodeList()
  for _, node_area in ipairs(nodes) do
    if form.map_query:IsSubRegion(form.current_map, node_area.main_area, scene_area_name) then
      node_area.ImageIndex = 6
      node_area.NodeImageOffsetX = 12
      node_area.NodeImageOffsetY = 12
      player_node = node_area
    else
      node_area.ImageIndex = -1
    end
  end
  return player_node
end
function update_direction_hint(form)
  form.btn_dir.Visible = false
  if form.current_step ~= STEP_SCENE then
    return
  end
  if form.current_map ~= form.map_query:GetCurrentScene() then
    return
  end
  local lbl_role = form.lbl_role
  if form.map_query:IsInMap(lbl_role, form.pic_map) then
    form.btn_dir.Visible = false
    return
  end
  if not nx_find_custom(form.pic_map, "TerrainStartX") then
    return
  end
  local map_x, map_z = trans_scene_pos_to_image(lbl_role.x, lbl_role.z, form.pic_map.ImageWidth, form.pic_map.ImageHeight, form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  local delta_x = map_x - form.pic_map.CenterX
  local delta_z = map_z - form.pic_map.CenterY
  form.btn_dir.Visible = true
  local flag_x = 0 < delta_x
  local flag_z = 0 < delta_z
  local map_role_x, map_role_z = trans_scene_pos_to_map(lbl_role.x, lbl_role.z, form.pic_map)
  local map_center_x, map_center_z = form.pic_map.Width / 2, form.pic_map.Height / 2
  local exact_x = 0
  local exact_y = 0
  local k = (map_role_z - map_center_z) / (map_role_x - map_center_x)
  local b = map_center_z - k * map_center_x
  if not flag_x and flag_z then
    exact_x = 0
    exact_y = k * exact_x + b
    if exact_y > form.pic_map.Height then
      exact_y = form.pic_map.Height
      exact_x = (exact_y - b) / k
    end
  elseif not flag_x and not flag_z then
    exact_x = 0
    exact_y = k * exact_x + b
    if exact_y < 0 then
      exact_y = 0
      exact_x = (exact_y - b) / k
    end
  elseif flag_x and not flag_z then
    exact_y = 0
    exact_x = (exact_y - b) / k
    if exact_x > form.pic_map.Width then
      exact_x = form.pic_map.Width
      exact_y = k * exact_x + b
    end
  elseif flag_x and flag_z then
    exact_x = form.pic_map.Width
    exact_y = k * exact_x + b
    if exact_y > form.pic_map.Height then
      exact_y = form.pic_map.Height
      exact_x = (exact_y - b) / k
    end
  end
  if exact_x == 0 then
    exact_y = exact_y - form.btn_dir.Height / 2
  end
  if exact_x == form.pic_map.Width then
    exact_x = exact_x - form.btn_dir.Width
    exact_y = exact_y - form.btn_dir.Height / 2
  end
  if exact_y == 0 then
    exact_x = exact_x - form.btn_dir.Width / 2
  end
  if exact_y == form.pic_map.Height then
    exact_y = exact_y - form.btn_dir.Height
    exact_x = exact_x - form.btn_dir.Width / 2
  end
  form.btn_dir.AbsLeft = form.pic_map.AbsLeft + exact_x
  form.btn_dir.AbsTop = form.pic_map.AbsTop + exact_y
end
function fill_scene_npc_tree(form, scene, tree)
  local gui = nx_value("gui")
  local imagelist = gui:CreateImageList()
  imagelist:AddImage("gui\\special\\monster\\mLv_0.png")
  imagelist:AddImage("gui\\special\\monster\\mLv_1.png")
  imagelist:AddImage("gui\\special\\monster\\mLv_2.png")
  imagelist:AddImage("gui\\special\\monster\\mLv_3.png")
  imagelist:AddImage("gui\\special\\monster\\mLv_4.png")
  imagelist:AddImage("gui\\special\\monster\\mLv_5.png")
  imagelist:AddImage("gui\\map\\icon\\role.png")
  tree.ImageList = imagelist
  local root = tree.RootNode
  if not nx_is_valid(root) then
    root = tree:CreateRootNode(nx_widestr("Root"))
  end
  root:ClearNode()
  local groupmap_objs = form.groupmap_objs
  tree:BeginUpdate()
  tree.AlwaysVScroll = true
  local areas = form.map_query:GetRegionsOfScene(scene)
  for _, area in ipairs(areas) do
    local node_area = root:CreateNode(gui.TextManager:GetText(area))
    node_area.main_area = area
    node_area.ForeColor = "255,76,61,44"
    node_area.ShadowColor = "0,255,0,0"
    node_area.Expand = false
    node_area.ImageIndex = -1
    node_area.ItemHeight = 43
    node_area.TextOffsetY = 14
    node_area.TextOffsetX = 16
    node_area.ExpandCloseOffsetY = 18
    node_area.NodeBackImage = "gui\\common\\treeview\\tree2_1_out.png"
    node_area.NodeFocusImage = "gui\\common\\treeview\\tree2_1_on.png"
    node_area.NodeSelectImage = "gui\\common\\treeview\\tree2_1_down.png"
    node_area.Font = "font_main"
    set_npc_tree_node(node_area, "ui_EShiLi", "255,255,0,0", 1, 4)
    set_npc_tree_node(node_area, "ui_YeShou", "255,255,0,0", 7, 7)
    set_npc_tree_node(node_area, "ui_XinShiLi", "255,255,0,0", 14, 14)
    set_npc_tree_node(node_area, "ui_ShangRen", "255,76,61,44", 61, 68)
    set_npc_tree_node(node_area, "ui_YiZhan", "255,76,61,44", 69, 71)
    set_npc_tree_node(node_area, "ui_BaiXing", "255,76,61,44", 82, 107)
    set_npc_tree_node(node_area, "ui_DongWu", "255,76,61,44", 112, 112)
    set_npc_tree_node(node_area, "ui_ShengHuoShiFu", "255,76,61,44", 122, 138)
    set_npc_tree_node(node_area, "ui_yihua", "255,76,61,44", 116, 116)
    set_npc_tree_node(node_area, "ui_taohua", "255,76,61,44", 117, 117)
    set_npc_tree_node(node_area, "ui_xujia", "255,76,61,44", 189, 189)
    set_npc_tree_node(node_area, "ui_shenjia", "255,76,61,44", 118, 118)
    set_npc_tree_node(node_area, "ui_wanshou", "255,76,61,44", 119, 119)
    set_npc_tree_node(node_area, "ui_wugeng", "255,76,61,44", 120, 120)
  end
  root.Expand = true
  tree:EndUpdate()
end
function set_npc_tree_node(node_area, name, color, min_type, max_type)
  local gui = nx_value("gui")
  local node = node_area:CreateNode(gui.TextManager:GetText(name))
  node.main_area = area
  node.ForeColor = color
  node.ShadowColor = "0,255,0,0"
  node.Mark = nx_int(min_type)
  node.MinNpcType = min_type
  node.MaxNpcType = max_type
  node.ItemHeight = 25
  node.TextOffsetY = 4
  node.TextOffsetX = 6
  node.ExpandCloseOffsetX = 10
  node.ExpandCloseOffsetY = 8
  node.NodeBackImage = "gui\\common\\treeview\\tree2_2_out.png"
  node.NodeFocusImage = "gui\\common\\treeview\\tree2_2_on.png"
  node.NodeSelectImage = "gui\\common\\treeview\\tree2_2_down.png"
  node.Font = "font_treeview"
end
function show_tree_node_npc(form, node, flag)
  if not nx_is_valid(node) then
    return
  end
  if nx_find_custom(node, "main_area") and nx_find_custom(node, "MinNpcType") and nx_find_custom(node, "MaxNpcType") then
    if flag then
      node.ForeColor = "255,255,255,255"
    elseif node.Mark == 1 or node.Mark == 7 or node.Mark == 14 then
      node.ForeColor = "255,255,0,0"
    else
      node.ForeColor = "255,76,61,44"
    end
  elseif nx_find_custom(node, "main_area") and nx_find_custom(node, "sub_area") and nx_find_custom(node, "npc_id") then
    if flag then
      local is_show = false
      is_show = creat_PolygonBox(node.npc_id, node.sub_area, "", "")
      if not is_show then
        form.groupmap_objs:ShowAreaBind(node.main_area, node.npc_id, flag)
      end
    else
      local mgr = nx_value("SceneCreator")
      if nx_is_valid(mgr) then
        mgr:DeletePolygonBox(node.npc_id)
      end
      if not check_npc_type(node.npc_type) then
        form.groupmap_objs:ShowAreaBind(node.main_area, node.npc_id, flag)
      end
    end
  end
end
function check_npc_type(npc_type)
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return false
  end
  local cbtns = form_map.groupbox_caiji:GetChildControlList()
  for _, btn in ipairs(cbtns) do
    if nx_name(btn) == "CheckButton" and nx_find_custom(btn, "NpcTypes") and btn.Checked and nx_string(npc_type) == btn.NpcTypes then
      return true
    end
  end
  local cbtns = form_map.groupbox_base:GetChildControlList()
  for _, btn in ipairs(cbtns) do
    if nx_name(btn) == "CheckButton" and nx_find_custom(btn, "NpcTypes") and btn.Checked and nx_string(npc_type) == btn.NpcTypes then
      return true
    end
  end
  local cbtns = form_map.groupbox_guild:GetChildControlList()
  for _, btn in ipairs(cbtns) do
    if nx_name(btn) == "CheckButton" and nx_find_custom(btn, "NpcTypes") and btn.Checked and nx_string(npc_type) == btn.NpcTypes then
      return true
    end
  end
  local cbtns = form_map.groupbox_life:GetChildControlList()
  for _, btn in ipairs(cbtns) do
    if nx_name(btn) == "CheckButton" and nx_find_custom(btn, "NpcTypes") and btn.Checked and nx_string(npc_type) == btn.NpcTypes then
      return true
    end
  end
  local cbtns = form_map.groupbox_menpai:GetChildControlList()
  for _, btn in ipairs(cbtns) do
    if nx_name(btn) == "CheckButton" and nx_find_custom(btn, "NpcTypes") and btn.Checked and nx_string(npc_type) == btn.NpcTypes then
      return true
    end
  end
  local cbtns = form_map.groupbox_shangren:GetChildControlList()
  for _, btn in ipairs(cbtns) do
    if nx_name(btn) == "CheckButton" and nx_find_custom(btn, "NpcTypes") and btn.Checked and nx_string(npc_type) == btn.NpcTypes then
      return true
    end
  end
  local cbtns = form_map.groupbox_wanfa:GetChildControlList()
  for _, btn in ipairs(cbtns) do
    if nx_name(btn) == "CheckButton" and nx_find_custom(btn, "NpcTypes") and btn.Checked and nx_string(npc_type) == btn.NpcTypes then
      return true
    end
  end
  return false
end
function on_tree_npc_select_changed(self, sel_node, old_node)
  local form = self.ParentForm
  show_tree_node_npc(form, old_node, false)
  show_tree_node_npc(form, sel_node, true)
  if nx_find_custom(sel_node, "sub_area") and nx_find_custom(sel_node, "npc_id") and nx_find_custom(sel_node, "npc_type") and nx_find_custom(sel_node, "x") and nx_find_custom(sel_node, "z") then
    set_map_center_according_world_pos(form, sel_node.x, sel_node.z)
    form.groupmap_objs.x = sel_node.x
    form.groupmap_objs.y = sel_node.y
    form.groupmap_objs.z = sel_node.z
    form.groupmap_objs.id = sel_node.npc_id
    form.groupmap_objs.npc_id = sel_node.npc_id
    form.groupmap_objs.npc_type = sel_node.npc_type
    on_lbl_click(form.groupmap_objs)
  end
end
function set_map_zoom(form, zoom_width, zoom_height)
  form.pic_map.ZoomWidth = zoom_width
  form.pic_map.ZoomHeight = zoom_height
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  if center_x_min > form.pic_map.CenterX then
    form.pic_map.CenterX = center_x_min
  end
  if center_x_max < form.pic_map.CenterX then
    form.pic_map.CenterX = center_x_max
  end
  if center_z_min > form.pic_map.CenterY then
    form.pic_map.CenterY = center_z_min
  end
  if center_z_max < form.pic_map.CenterY then
    form.pic_map.CenterY = center_z_max
  end
  form.pic_mask.ZoomWidth = form.pic_map.ZoomWidth
  form.pic_mask.ZoomHeight = form.pic_map.ZoomHeight
  form.pic_mask.CenterX = form.pic_map.CenterX
  form.pic_mask.CenterY = form.pic_map.CenterY
  form.groupmap_objs:ShowText("A", true)
  form.groupmap_objs:ShowText("B", false)
  form.groupmap_objs:ShowText("C", false)
  if not nx_find_custom(form.pic_map, "min_zoom_width") then
    return
  end
  local min_zoom_width = form.pic_map.min_zoom_width
  local max_zoom_width = form.pic_map.max_zoom_width
  local max_zoom_height = form.pic_map.max_zoom_height
  local average_zoom_width = (max_zoom_width - min_zoom_width) / 3
  if zoom_width >= min_zoom_width + average_zoom_width * 0 and (not nx_find_custom(form.pic_map, "ZoomLevel") or form.pic_map.ZoomLevel ~= 1) then
    form.pic_map.ZoomLevel = 1
    form.groupbox_faction_1.show = false
    form.groupbox_faction_2.show = false
  end
  if zoom_width >= min_zoom_width + average_zoom_width * 1 and (not nx_find_custom(form.pic_map, "ZoomLevel") or form.pic_map.ZoomLevel ~= 2) then
    form.pic_map.ZoomLevel = 2
    form.groupmap_objs:ShowText("B", true)
    form.groupbox_faction_2.show = true
    form.groupbox_faction_1.show = true
  end
  if zoom_width >= min_zoom_width + average_zoom_width * 2 and (not nx_find_custom(form.pic_map, "ZoomLevel") or form.pic_map.ZoomLevel ~= 3) then
    form.pic_map.ZoomLevel = 3
    form.groupmap_objs:ShowText("C", true)
  end
  form.map_ui_ini:WriteFloat("map", "ZoomWidth", form.pic_map.ZoomWidth)
  form.map_ui_ini:WriteFloat("map", "ZoomHeight", form.pic_map.ZoomHeight)
  form.map_ui_ini:SaveToFile()
end
function set_map_center(form, center_x, center_z)
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  if center_x < center_x_min then
    center_x = center_x_min
  end
  if center_x_max < center_x then
    center_x = center_x_max
  end
  if center_z < center_z_min then
    center_z = center_z_min
  end
  if center_z_max < center_z then
    center_z = center_z_max
  end
  form.pic_map.CenterX = center_x
  form.pic_map.CenterY = center_z
  form.pic_mask.CenterX = center_x
  form.pic_mask.CenterY = center_z
  update_form_on_timer(form)
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    mgr:UpdatePolygonBox(false)
    mgr:UpdateGuildPkArena(false)
    mgr:UpdateSchoolPkArena(false)
    mgr:UpdateArenaCircle()
    mgr:UpdateAllArea(false)
  end
  form.map_query:UpdateMapLabel()
  update_map_mark_info(form)
end
function on_pic_map_drag_move(pic_map, offset_x, offset_y)
  if not nx_find_custom(pic_map, "click_center_x") then
    return
  end
  local sx = -offset_x / pic_map.ZoomWidth * 0.5
  local sz = -offset_y / pic_map.ZoomHeight * 0.5
  local map_x = sx + pic_map.click_center_x
  local map_z = sz + pic_map.click_center_z
  local form = pic_map.ParentForm
  set_map_center(form, map_x, map_z)
  render_main_waypoints()
end
function on_pic_map_mouse_move(pic_map, offset_x, offset_y)
  local form = pic_map.ParentForm
  if nx_find_custom(pic_map, "right_down") and pic_map.right_down then
    on_pic_map_drag_move(pic_map, offset_x - pic_map.click_offset_x, offset_y - pic_map.click_offset_y)
  else
    if not nx_find_custom(pic_map, "TerrainStartX") then
      return
    end
    form.pic_map.mouse_move = true
    local sx = -(pic_map.Width / 2 - offset_x)
    local sz = pic_map.Height / 2 - offset_y
    local map_x = pic_map.ImageWidth - pic_map.CenterX - sx / pic_map.ZoomWidth
    local map_z = pic_map.CenterY - sz / pic_map.ZoomHeight
    local pos_x, pos_z = trans_image_pos_to_scene(map_x, map_z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
    pic_map.ParentForm.lbl_pos.Text = nx_widestr(nx_string(nx_int(pos_x)) .. "," .. nx_string(nx_int(pos_z)))
  end
end
function on_pic_map_left_down(pic_map, x, y)
end
function on_pic_map_left_up(pic_map, x, y)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if client_player:FindProp("LogicState") then
    local offline_state = client_player:QueryProp("LogicState")
    if nx_int(offline_state) == nx_int(LS_OFFLINEJOB) then
      return
    end
  end
  local sx = -(pic_map.Width / 2 - x)
  local sz = pic_map.Height / 2 - y
  local map_x = pic_map.ImageWidth - pic_map.CenterX - sx / pic_map.ZoomWidth
  local map_z = pic_map.CenterY - sz / pic_map.ZoomHeight
  local pos_x, pos_z = trans_image_pos_to_scene(map_x, map_z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local form = pic_map.ParentForm
  if form.current_step == STEP_SCENE then
    local defined_label = false
    local form_label_list = nx_value("form_stage_main\\form_map\\form_map_label_list")
    if nx_is_valid(form_label_list) and form_label_list.btn_label.Checked then
      defined_label = true
    end
    if defined_label then
      local gui = nx_value("gui")
      local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_map\\form_map_label_detail", true, false)
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "input_name_return")
      if res == "cancel" then
        return
      end
      local npc_id = nx_string(dialog.name_edit.Text)
      local npc_type = dialog.NpcTypes
      add_defined_label(form, pos_x, 0, pos_z, npc_type, npc_id)
    else
      local role = nx_value("role")
      if nx_is_valid(role) and nx_find_custom(role, "find_path_limit") and role.find_path_limit == true then
        return
      end
      local client_scene = game_client:GetScene()
      local cur_scene_id = client_scene:QueryProp("Resource")
      local path_finding = nx_value("path_finding")
      local trace_flag = path_finding.AutoTraceFlag
      if path_finding:IsDynamicCloneScene() and path_finding:IsInDynamicCloneRandomZone(pos_x, pos_z) then
        local list = path_finding:get_zone_row_col_by_pos(pos_x, pos_z)
        local row = list[1]
        local col = list[2]
        if -1 == row or -1 == col then
          return
        end
        local tag_zone_name = cur_scene_id .. "_zone_" .. nx_string(row) .. "_" .. nx_string(col)
        path_finding:FindPathZone(tag_zone_name, pos_x, -10000, pos_z, 0)
        return
      end
      if cur_scene_id == form.current_map then
        if trace_flag == 1 or trace_flag == 2 then
          path_finding:FindPath(pos_x, -10000, pos_z, 0)
        end
        set_trace_npc_id(nil, pos_x, -10000, pos_z, form.current_map, true)
      else
        set_trace_npc_id(nil, pos_x, -10000, pos_z, nil, true)
        if trace_flag == 1 or trace_flag == 2 then
          path_finding:FindPathScene(form.current_map, pos_x, -10000, pos_z, 0)
        end
      end
    end
  end
end
function on_pic_map_right_down(pic_map, x, y)
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, "snapmap", "", "", "", "")
  pic_map.mouse_move = false
  pic_map.right_down = true
  pic_map.click_center_x = pic_map.CenterX
  pic_map.click_center_z = pic_map.CenterY
  pic_map.click_offset_x = x
  pic_map.click_offset_y = y
end
function on_pic_map_right_up(pic_map, x, y)
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  pic_map.right_down = false
  pic_map.mouse_move = false
  pic_map.drag_move = false
  local form_label_list = nx_value("form_stage_main\\form_map\\form_map_label_list")
  if nx_is_valid(form_label_list) and form_label_list.btn_label.Checked then
    gui.GameHand:SetHand(GHT_FUNC, "add", "", "", "", "")
  end
end
function render_path_finding(form)
  form.line_path:Clear()
  form.line_path.Visible = false
  if form.current_step ~= STEP_SCENE then
    return
  end
  if form.current_map ~= form.map_query:GetCurrentScene() then
    return
  end
  form.map_query:RenderPathFinding(form, form.line_path, form.pic_map)
end
function update_trace_pos(form)
  form.btn_trace.Visible = false
  if form.current_step == STEP_SCENE then
    form.map_query:UpdateSceneMapTrace()
  end
end
function render_main_waypoints()
  do return end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) and not game_visual.GameTest then
    return
  end
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local scene = client:GetScene()
  if not nx_is_valid(scene) then
    return
  end
  local scene_id = scene:QueryProp("Resource")
  local path_finding = nx_value("path_finding")
  if not path_finding:IsLoaded(scene_id) then
    path_finding:LoadPath(scene_id)
  end
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) and not form.Visible then
    return
  end
  if not form.main_path.Visible then
    form.main_path:Clear()
    return
  end
  form.main_path.UseTexture = false
  form.main_path.LineStyle = 0
  form.main_path.LineColor = "255,0,255,0"
  form.main_path.AbsLeft = form.pic_map.AbsLeft
  form.main_path.AbsTop = form.pic_map.AbsTop
  form.main_path.Width = form.pic_map.Width
  form.main_path.Height = form.pic_map.Height
  form.main_path:Clear()
  scene_id = scene_id .. "_main"
  local count = path_finding:GetPathPointCount(scene_id)
  for n = 1, count do
    local xr, yr, zr = path_finding:GetPathPointPos(scene_id, n)
    local points = path_finding:GetLinkPoints(scene_id, n)
    for p = 1, table.getn(points) do
      local xo, yo, zo = path_finding:GetPathPointPos(scene_id, points[p])
      local x1, z1 = trans_scene_pos_to_map(xr, zr, form.pic_map)
      local x2, z2 = trans_scene_pos_to_map(xo, zo, form.pic_map)
      form.main_path:AddLine(x1, z1, x2, z2)
    end
  end
end
function update_form_on_timer(form, param1, param2)
  if not form.Visible then
    return
  end
  update_faction(form)
  update_chouren()
  update_zhuizong()
  update_direction_hint(form)
  update_team_info(form)
  update_escort_record(form)
  update_scene_npc_tree_for_role(form)
  render_path_finding(form)
  update_trace_pos(form)
  update_qizhi_info(form)
end
function set_role_to_map_center(form)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local visual_player = game_visual:GetPlayer()
    if nx_is_valid(visual_player) then
      local x = visual_player.PositionX
      local z = visual_player.PositionZ
      set_map_center_according_world_pos(form, x, z)
    end
  end
end
function set_map_center_according_world_pos(form, x, z)
  if not nx_find_custom(form.pic_map, "TerrainStartX") then
    return
  end
  local map_x, map_z = trans_scene_pos_to_image(x, z, form.pic_map.ImageWidth, form.pic_map.ImageHeight, form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  local sx = (map_x - form.pic_map.CenterX) * form.pic_map.ZoomWidth
  local sz = (map_z - form.pic_map.CenterY) * form.pic_map.ZoomHeight
  local center_x = form.pic_map.CenterX + sx / form.pic_map.ZoomWidth
  local center_z = form.pic_map.CenterY + sz / form.pic_map.ZoomHeight
  set_map_center(form, center_x, center_z)
end
function create_scene_npc(form)
  form.is_open = true
  groupmap_begin(form)
  form.map_query:CreateNpcToGroupBigMapFromFiles(form, form.current_map)
  update_form_map_set()
  local exact_zoom_width = form.map_ui_ini:ReadFloat("map", "ZoomWidth", 0.8)
  local exact_zoom_height = form.map_ui_ini:ReadFloat("map", "ZoomHeight", 0.8)
  set_map_zoom(form, exact_zoom_width, exact_zoom_height)
  create_npc_tree(form, form.current_map)
end
function create_npc_tree(form, scene)
  if nx_is_valid(form) then
    fill_scene_npc_tree(form, scene, form.tree_npc)
    form.map_query:CreateNpcToTreeFromFiles(form, scene)
    remove_empty_node(form.tree_npc)
  end
end
function update_record_Task_Accepted(form, record_name, opttype, row, col)
  nx_execute(nx_current(), "async_update_record_task_accept", form, record_name, opttype, row, col)
end
function async_update_record_task_accept(form, record_name, opttype, row, col)
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
  refresh_trace_info(form)
  local photo = ""
  local npc_committed = ""
  local npc_accepted = ""
  local npc_type = -1
  if "del" == opttype then
    npc_committed = client_player:QueryRecord(record_name, row, accept_rec_submit_npc)
    npc_accepted = client_player:QueryRecord(record_name, row, accept_rec_accept_npc)
    if nil ~= npc_committed and "" ~= npc_committed then
      npc_type = form.map_query:GetNpcType(npc_committed)
      photo = form.map_query:GetNpcTypeProp(nx_string(npc_type), "Photo")
      form.groupmap_objs:ModifyPhoto(npc_committed, photo)
      form.groupmap_objs:ShowBind(npc_committed, false)
    end
    if nil ~= npc_accepted and "" ~= npc_accepted then
      npc_type = form.map_query:GetNpcType(npc_accepted)
      photo = form.map_query:GetNpcTypeProp(nx_string(npc_type), "Photo")
      form.groupmap_objs:ModifyPhoto(npc_accepted, photo)
    end
    return
  end
  local row_count = client_player:GetRecordRows(record_name)
  for row_index = 0, row_count - 1 do
    npc_accepted = client_player:QueryRecord(record_name, row_index, accept_rec_accept_npc)
    if nil ~= npc_accepted and "" ~= npc_accepted then
      form.groupmap_objs:ShowBind(npc_accepted, false)
    end
  end
end
function update_task_record_change(form, recordname, optype, row, clomn)
  nx_execute(nx_current(), "async_update_task_record_change", form, recordname, optype, row, clomn)
end
function async_update_task_record_change(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return
  end
  refresh_trace_info(form)
end
function update_escort_record(form)
  if not form.Visible or form.current_step ~= STEP_SCENE then
    return
  end
  form.map_query:UpdateEscortInfo()
end
function on_label_escort_get_capture(self)
  local form = self.ParentForm
  local text = nx_widestr(self.EscortInfo)
  nx_execute("tips_game", "show_text_tip", text, self.AbsLeft, self.AbsTop, 0, form)
end
function on_label_escort_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function update_team_info(form)
  if form.current_step ~= STEP_SCENE then
    return
  end
  local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if not flag_apex then
    form.map_query:UpdateTeamMates()
  end
  form.map_query:UpdateDropBox()
  refresh_sns_pos(form)
end
function on_label_team_get_capture(lab)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("{@0:name}({@1:x},{@2:y})", nx_string(lab.name), nx_int(lab.x), nx_int(lab.z))
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), lab.AbsLeft, lab.AbsTop - 60, 0, form)
end
function on_label_team_lost_capture(lbl)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  nx_execute("tips_game", "hide_tip", form)
end
function get_team_members(scene_name)
  local text = nx_widestr("")
  local gui = nx_value("gui")
  scene_name = gui.TextManager:GetText("scene_" .. scene_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local self_name = client_player:QueryProp("Name")
  local row_num = client_player:GetRecordRows(TEAM_REC)
  for index = 0, row_num - 1 do
    local player_name = client_player:QueryRecord(TEAM_REC, index, TEAM_REC_COL_NAME)
    if self_name ~= player_name then
      local sceneid = client_player:QueryRecord(TEAM_REC, index, TEAM_REC_COL_SCENE)
      local scene = gui.TextManager:GetText(sceneid)
      if scene_name == scene then
        text = text .. player_name .. nx_widestr("<br>")
      end
    end
  end
  return text
end
function update_qizhi_info(form)
  if form.current_step ~= STEP_SCENE then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
    return
  end
  form.map_query:UpdateQiZhiInfo()
end
function trans_scene_pos_to_image(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local map_x = map_width - (x - terrain_start_x) / terrain_width * map_width
  local map_z = (z - terrain_start_z) / terrain_height * map_height
  return map_x, map_z
end
function trans_image_pos_to_scene(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local pos_x = x * terrain_width / map_width + terrain_start_x
  local pos_z = z * terrain_height / map_height + terrain_start_z
  return pos_x, pos_z
end
function trans_scene_pos_to_map(x, z, pic_map)
  local map_x, map_z
  map_x, map_z = trans_scene_pos_to_image(x, z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local sx = (map_x - pic_map.CenterX) * pic_map.ZoomWidth
  local sz = (map_z - pic_map.CenterY) * pic_map.ZoomHeight
  sx = sx + pic_map.Width / 2
  sz = sz + pic_map.Height / 2
  return sx, sz
end
function canclosemask()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_player) then
    return false
  end
  if not nx_is_valid(client_scene) then
    return false
  end
  if not client_player:FindRecord("MapMaskRec") then
    return false
  end
  local scene_name = client_scene:QueryProp("Resource")
  local rows = client_player:GetRecordRows("MapMaskRec")
  for j = 0, rows - 1 do
    if scene_name == client_player:QueryRecord("MapMaskRec", j, 1) and 1 == client_player:QueryRecord("MapMaskRec", j, 2) then
      return true
    end
  end
  return false
end
function modify_zorder(form)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  local step = form.current_step
  if step == STEP_WORLD then
    form.groupbox_map.Visible = false
    form.groupbox_back.Visible = true
    form.groupbox_player_pos.Visible = false
    form.btn_trace.Visible = false
    form.btn_back.Visible = false
    form.groupbox_scene_list.AbsLeft = form.groupbox_select.AbsLeft
    form.groupbox_scene_list.AbsTop = form.groupbox_select.AbsTop
    form.groupbox_scene_list.Width = form.groupbox_select.Width
    form.groupbox_scene_list.Height = form.groupbox_select.Height
  elseif step == STEP_AREA then
    form.groupbox_map.Visible = false
    form.groupbox_back.Visible = true
    form.groupbox_player_pos.Visible = false
    form.btn_trace.Visible = false
    form.btn_back.Visible = true
    form:ToFront(form.btn_back)
  elseif step == STEP_SCENE then
    form.groupbox_map.Visible = true
    form.groupbox_back.Visible = true
    form.groupbox_player_pos.Visible = true
    form.btn_back.Visible = true
    form.groupbox_scene_list.AbsLeft = form.groupbox_select.AbsLeft
    form.groupbox_scene_list.AbsTop = form.groupbox_select.AbsTop
    form.groupbox_scene_list.Width = form.groupbox_select.Width
    form.groupbox_scene_list.Height = form.groupbox_select.Height
    form.groupbox_map:ToFront(form.groupmap_objs)
    form.groupbox_map:ToFront(form.lbl_role)
    local bIsNewJHModule = is_newjhmodule()
    if bIsNewJHModule then
      form.groupbox_map:ToFront(form.pic_mask)
      form.pic_mask.Visible = not canclosemask()
      hide_control()
      reset_form_ui(form)
    else
      form.pic_mask.Visible = false
      show_control()
    end
    form.groupbox_map:ToFront(form.groupbox_move)
    form:ToFront(form.combobox_is_show_task)
    local player_node = update_scene_npc_tree_for_role(form)
    if nx_is_valid(player_node) then
      player_node.Expand = true
    end
  end
end
function clean_before_step(form)
  if not nx_find_custom(form, "form_world") then
    return
  end
  local form_world = form.form_world
  if form_world ~= nil and nx_is_valid(form_world) then
    form_world:Close()
    nx_destroy(form_world)
    form_world = nil
  end
end
function get_faction_pos(domain_id, sence)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return nil, nil
  end
  local scene_map_ini = nx_execute("util_functions", "get_ini", "ini\\Guild\\guild_map.ini")
  if not nx_is_valid(scene_map_ini) then
    return nil, nil
  end
  local section_index = scene_map_ini:FindSectionIndex(sence)
  if section_index < 0 then
    return nil, nil
  end
  local x, y
  local key = nx_string(domain_id) .. "X"
  x = scene_map_ini:ReadInteger(section_index, key, -1)
  key = domain_id .. "Y"
  y = scene_map_ini:ReadInteger(section_index, key, -1)
  return x, y
end
function clear_faction(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_faction_1.Visible = false
  form.groupbox_faction_2.Visible = false
  form.lbl_faction1_name.Text = nx_widestr("")
  form.lbl_faction1_state.BackImage = ""
  form.lbl_faction2_name.Text = nx_widestr("")
  form.lbl_faction2_state.BackImage = ""
end
function show_faction(faction_name, faction_state, num)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  if nx_string(faction_name) == "" then
    if num == 1 then
      form.groupbox_faction_1.Visible = false
    else
      form.groupbox_faction_2.Visible = false
    end
    return
  end
  local state_photo
  if nx_number(faction_state) == 0 then
    state_photo = "gui\\guild\\map\\piece.png"
  elseif nx_number(faction_state) == 1 then
    state_photo = "gui\\guild\\map\\zhunbei.png"
  elseif nx_number(faction_state) == 2 then
    state_photo = "gui\\guild\\map\\battle.png"
  elseif nx_number(faction_state) == 3 then
    state_photo = "gui\\guild\\map\\beixuanzhan.png"
  else
    return
  end
  if num == 1 then
    local groupbox1 = form.groupbox_faction_1
    local x, y = get_faction_pos(form.domain_id1, form.current_map)
    if x == nil or y == nil then
      return
    end
    local sx, sz = trans_scene_pos_to_map(x, y, form.pic_map)
    form.lbl_faction1_name.Text = nx_widestr(faction_name)
    form.lbl_faction1_state.BackImage = state_photo
    groupbox1.AbsLeft = form.pic_map.AbsLeft + sx - groupbox1.Width / 2 + 50
    groupbox1.AbsTop = form.pic_map.AbsTop + sz - groupbox1.Height / 2
    groupbox1.Visible = form.map_query:IsInMap(groupbox1, form.pic_map)
  else
    local groupbox2 = form.groupbox_faction_2
    local x, y = get_faction_pos(form.domain_id2, form.current_map)
    if x == nil or y == nil then
      return
    end
    local sx, sz = trans_scene_pos_to_map(x, y, form.pic_map)
    form.lbl_faction2_name.Text = nx_widestr(faction_name)
    form.lbl_faction2_state.BackImage = state_photo
    groupbox2.AbsLeft = form.pic_map.AbsLeft + sx - groupbox2.Width / 2 + 50
    groupbox2.AbsTop = form.pic_map.AbsTop + sz - groupbox2.Height / 2
    groupbox2.Visible = form.map_query:IsInMap(groupbox2, form.pic_map)
  end
end
function update_faction(form)
  if form.current_step ~= STEP_SCENE then
    return
  end
  if form.domain_id1 ~= "" then
    local groupbox1 = form.groupbox_faction_1
    if nx_find_custom(groupbox1, "show") and groupbox1.show then
      local x, y = get_faction_pos(form.domain_id1, form.current_map)
      if x == nil or y == nil then
        return
      end
      local sx, sz = trans_scene_pos_to_map(x, y, form.pic_map)
      groupbox1.AbsLeft = form.pic_map.AbsLeft + sx - groupbox1.Width / 2 + 50
      groupbox1.AbsTop = form.pic_map.AbsTop + sz - groupbox1.Height / 2
      groupbox1.Visible = form.map_query:IsInMap(groupbox1, form.pic_map)
    else
      form.groupbox_faction_1.Visible = false
    end
  end
  if form.domain_id2 ~= "" then
    local groupbox2 = form.groupbox_faction_2
    if nx_find_custom(groupbox2, "show") and groupbox2.show then
      local x, y = get_faction_pos(form.domain_id2, form.current_map)
      if x == nil or y == nil then
        return
      end
      local sx, sz = trans_scene_pos_to_map(x, y, form.pic_map)
      groupbox2.AbsLeft = form.pic_map.AbsLeft + sx - groupbox2.Width / 2 + 50
      groupbox2.AbsTop = form.pic_map.AbsTop + sz - groupbox2.Height / 2
      groupbox2.Visible = form.map_query:IsInMap(groupbox2, form.pic_map)
    else
      form.groupbox_faction_2.Visible = false
    end
  end
end
function on_lbl_faction_get_capture(self)
  local info = nx_widestr("")
  local gui = nx_value("gui")
  if self.BackImage == "gui\\guild\\map\\piece.png" then
    info = gui.TextManager:GetText("ui_guildwar_heping")
  elseif self.BackImage == "gui\\guild\\map\\beixuanzhan.png" then
    info = gui.TextManager:GetText("ui_guildwar_xuanzhan")
  elseif self.BackImage == "gui\\guild\\map\\battle.png" then
    info = gui.TextManager:GetText("ui_guildwar_zhandou")
  elseif self.BackImage == "gui\\guild\\map\\zhunbei.png" then
    info = gui.TextManager:GetText("ui_guildwar_zhunbei")
  else
    return
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(info), self.AbsLeft + self.Width / 2, self.AbsTop - self.Height / 2, 0, self.ParentForm)
end
function on_lbl_faction_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function set_cbtn_checked(form, cbtn)
  if form.cbtn_shangren.Name ~= cbtn.Name then
    form.cbtn_shangren.Checked = false
  end
  if form.cbtn_wanfa.Name ~= cbtn.Name then
    form.cbtn_wanfa.Checked = false
  end
  if form.cbtn_menpaizhiyin.Name ~= cbtn.Name then
    form.cbtn_menpaizhiyin.Checked = false
  end
  if form.cbtn_caiji.Name ~= cbtn.Name then
    form.cbtn_caiji.Checked = false
  end
  if form.cbtn_base.Name ~= cbtn.Name then
    form.cbtn_base.Checked = false
  end
  if form.cbtn_life.Name ~= cbtn.Name then
    form.cbtn_life.Checked = false
  end
  if form.cbtn_guild.Name ~= cbtn.Name then
    form.cbtn_guild.Checked = false
  end
  if form.cbtn_home.Name ~= cbtn.Name then
    form.cbtn_home.Checked = false
  end
  if form.cbtn_boss.Name ~= cbtn.Name then
    form.cbtn_boss.Checked = false
  end
  if form.cbtn_mijing.Name ~= cbtn.Name then
    form.cbtn_mijing.Checked = false
  end
  if form.cbtn_supply.Name ~= cbtn.Name then
    form.cbtn_supply.Checked = false
  end
  if form.cbtn_explore.Name ~= cbtn.Name then
    form.cbtn_explore.Checked = false
  end
  if form.cbtn_produce.Name ~= cbtn.Name then
    form.cbtn_produce.Checked = false
  end
end
function on_cbtn_life_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_life.Visible then
    form.groupbox_life.Visible = false
    return
  end
  set_cbtn_checked(form, self)
  form.groupbox_life.AbsLeft = self.AbsLeft
  form.groupbox_life.AbsTop = self.AbsTop - form.groupbox_life.Height
  form.groupbox_life.Visible = self.Checked
end
function on_cbtn_shangren_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_shangren.Visible then
    form.groupbox_shangren.Visible = false
    return
  end
  set_cbtn_checked(form, self)
  form.groupbox_shangren.AbsLeft = self.AbsLeft
  form.groupbox_shangren.AbsTop = self.AbsTop - form.groupbox_shangren.Height
  form.groupbox_shangren.Visible = self.Checked
end
function on_cbtn_caiji_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_caiji.Visible then
    form.groupbox_caiji.Visible = false
    return
  end
  set_cbtn_checked(form, self)
  form.groupbox_caiji.AbsLeft = self.AbsLeft
  form.groupbox_caiji.AbsTop = self.AbsTop - form.groupbox_caiji.Height
  form.groupbox_caiji.Visible = self.Checked
end
function on_cbtn_base_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_base.Visible then
    form.groupbox_base.Visible = false
    return
  end
  set_cbtn_checked(form, self)
  form.groupbox_base.AbsLeft = self.AbsLeft
  form.groupbox_base.AbsTop = self.AbsTop - form.groupbox_base.Height
  form.groupbox_base.Visible = self.Checked
end
function on_cbtn_menpaizhiyin_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_menpai.Visible then
    form.groupbox_menpai.Visible = false
    return
  end
  set_cbtn_checked(form, self)
  form.groupbox_menpai.AbsLeft = self.AbsLeft
  form.groupbox_menpai.AbsTop = self.AbsTop - form.groupbox_menpai.Height
  form.groupbox_menpai.Visible = self.Checked
end
function on_cbtn_guild_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_guild.Visible then
    form.groupbox_guild.Visible = false
    return
  end
  set_cbtn_checked(form, self)
  form.groupbox_guild.AbsLeft = self.AbsLeft
  form.groupbox_guild.AbsTop = self.AbsTop - form.groupbox_guild.Height
  form.groupbox_guild.Visible = self.Checked
end
function on_cbtn_wanfa_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_wanfa.Visible then
    form.groupbox_wanfa.Visible = false
    return
  end
  set_cbtn_checked(form, self)
  form.groupbox_wanfa.AbsLeft = self.AbsLeft
  form.groupbox_wanfa.AbsTop = self.AbsTop - form.groupbox_wanfa.Height
  form.groupbox_wanfa.Visible = self.Checked
end
function update_form_map_set()
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    update_new_boss_npc()
    update_new_mijing_npc()
    update_new_supply_npc()
    update_new_explore_npc()
    update_new_produce_npc()
  else
    update_caiji_npc()
    update_life_npc()
    update_shangren_npc()
    update_wanfa()
    update_base()
    update_menpai()
    update_guild()
    update_home_npc()
  end
  auto_show_npc()
end
function refresh_trace_info(form)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  if is_extinct_scene(form) then
    return
  end
  map_query:RefreshTraceInfo(form)
end
function creat_task_control(form, text_format, task_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local groupscrollbox_task = form.groupscrollbox_task
  if "lbl_task_title1" == text_format then
    local lab = groupscrollbox_task:Find(text_format)
    if not nx_is_valid(lab) then
      lab = gui:Create("Label")
      lab.Name = text_format
      lab.DrawMode = "Expand"
      lab.LineColor = "0,0,0,0"
      lab.ForeColor = "255,76,61,44"
      lab.Solid = false
      lab.Text = gui.TextManager:GetFormatText("ui_map_localtask")
      lab.Align = "Center"
      lab.Font = "font_story_chapter"
      groupscrollbox_task:Add(lab)
      lab.Left = 10
      lab.Top = 10
      lab.Width = 170
      lab.Height = 43
      lab.BackImage = "gui\\map\\mapn\\bg_title.png"
      lab.DrawMode = "FitWindow"
    end
    return
  elseif "lbl_task_title2" == text_format then
    local lab = groupscrollbox_task:Find(text_format)
    if not nx_is_valid(lab) then
      lab = gui:Create("Label")
      lab.Name = text_format
      lab.DrawMode = "Expand"
      lab.LineColor = "0,0,0,0"
      lab.Solid = false
      lab.Text = gui.TextManager:GetFormatText("ui_map_othertask")
      lab.ForeColor = "255,76,61,44"
      lab.Align = "Center"
      lab.Font = "font_story_chapter"
      groupscrollbox_task:Add(lab)
      lab.Left = 10
      lab.Top = groupscrollbox_task.curposY + 25
      lab.Width = 170
      lab.Height = 43
      groupscrollbox_task.curposY = groupscrollbox_task.curposY + lab.Height + 25
      lab.BackImage = "gui\\map\\mapn\\bg_title.png"
      lab.DrawMode = "FitWindow"
    end
    return
  end
  local groupbox_name = "groupbox_task_" .. nx_string(task_id)
  local mltbox_name = "mltbox_task_" .. nx_string(task_id)
  local lab_name = "lab_task_" .. nx_string(task_id)
  local groupbox = groupscrollbox_task:Find(groupbox_name)
  if not nx_is_valid(groupbox) then
    groupbox = gui:Create("GroupBox")
    groupbox.Name = groupbox_name
    groupbox.Width = 185
    groupbox.Height = 220
    groupbox.BackColor = "0,255,255,255"
    groupbox.DrawMode = "FitWindow"
    groupbox.NoFrame = true
    groupbox.Transparent = true
    groupscrollbox_task:Add(groupbox)
    groupbox.Left = 5
    groupbox.Top = groupscrollbox_task.curposY + 25
    groupbox.Visible = true
    groupbox.is_checked = false
    local MultiTexBox_task = groupbox:Find(mltbox_name)
    if not nx_is_valid(MultiTexBox_task) then
      MultiTexBox_task = gui:Create("MultiTextBox")
      MultiTexBox_task.Name = mltbox_name
      MultiTexBox_task.DrawMode = "Expand"
      MultiTexBox_task.LineColor = "0,0,0,0"
      MultiTexBox_task.Solid = false
      MultiTexBox_task.AutoSize = false
      MultiTexBox_task.Font = "font_conten_tasktrace"
      MultiTexBox_task.LineTextAlign = "Top"
      MultiTexBox_task.TextColor = "255,255,255,255"
      MultiTexBox_task.SelectBarColor = "0,0,0,0"
      MultiTexBox_task.MouseInBarColor = "0,0,0,0"
      MultiTexBox_task.BackColor = "0,255,255,255"
      groupbox:Add(MultiTexBox_task)
      MultiTexBox_task.ViewRect = "5,5,175,200"
      MultiTexBox_task.Width = MLTBOX_WIDTH
      MultiTexBox_task:AddHtmlText(nx_widestr(text_format), nx_int(task_id))
      MultiTexBox_task.Height = MultiTexBox_task:GetContentHeight() + 5
      MultiTexBox_task.Left = 10
      MultiTexBox_task.Top = 0
      MultiTexBox_task.DataSource = nx_string(task_id)
      nx_bind_script(MultiTexBox_task, nx_current())
      nx_callback(MultiTexBox_task, "on_click_image", "on_mltobx_task_click_image")
      nx_callback(MultiTexBox_task, "on_mousein_image", "on_mltobx_task_mousein_image")
      nx_callback(MultiTexBox_task, "on_mouseout_image", "on_mltobx_task_mouseout_image")
      nx_callback(MultiTexBox_task, "on_get_capture", "on_mltobx_task_get_capture")
      nx_callback(MultiTexBox_task, "on_lost_capture", "on_mltobx_task_lost_capture")
      groupbox:Add(MultiTexBox_task)
      groupbox.Height = MultiTexBox_task.Height + 15
    end
    groupscrollbox_task.curposY = groupscrollbox_task.curposY + groupbox.Height
  end
end
function on_mltobx_task_mousein_image(self, item_index, image_index)
  local data = self:GetImageData(item_index, image_index)
  if data ~= "index" then
    return
  end
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local form = self.ParentForm
  local task_id = self:GetItemKeyByIndex(item_index)
  local picture = mgr:GetTaskIndexPicture(nx_int(task_id), 2)
  local gb_box = self.Parent
  if nx_find_custom(gb_box, "is_checked") and not gb_box.is_checked then
    self:ChangeImage(item_index, image_index, nx_string(picture))
  end
end
function on_mltobx_task_mouseout_image(self, item_index, image_index)
  local data = self:GetImageData(item_index, image_index)
  if data ~= "index" then
    return
  end
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local form = self.ParentForm
  local task_id = self:GetItemKeyByIndex(item_index)
  local picture = mgr:GetTaskIndexPicture(nx_int(task_id), 1)
  local gb_box = self.Parent
  if nx_find_custom(gb_box, "is_checked") and not gb_box.is_checked then
    self:ChangeImage(item_index, image_index, nx_string(picture))
  end
end
function on_mltobx_task_click_image(self, item_index, image_index)
  local data = self:GetImageData(item_index, image_index)
  if data ~= "index" then
    return
  end
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local form = self.ParentForm
  local task_id = self:GetItemKeyByIndex(item_index)
  local form = self.ParentForm
  local groupscrollbox_task = form.groupscrollbox_task
  local list = groupscrollbox_task:GetChildControlList()
  if table.getn(list) < 0 then
    return
  end
  for _, control in pairs(list) do
    if control ~= nil and nx_find_custom(control, "is_checked") then
      control.BackImage = ""
      control.is_checked = false
      local child_list = control:GetChildControlList()
      for _, mul_box in pairs(child_list) do
        if nx_name(mul_box) == "MultiTextBox" then
          local pic = mgr:GetTaskIndexPicture(nx_int(mul_box.DataSource), 1)
          mul_box:ChangeImage(0, 0, nx_string(pic))
          update_label_image(form, mul_box.DataSource, pic, false)
        end
      end
    end
  end
  local picture = mgr:GetTaskIndexPicture(nx_int(task_id), 3)
  self:ChangeImage(item_index, image_index, nx_string(picture))
  update_label_image(form, task_id, picture, true)
  local gb_box = self.Parent
  gb_box.BackImage = "gui\\map\\mapn\\select_on.png"
  gb_box.is_checked = true
end
function on_mltobx_task_get_capture(self)
  local gb_box = self.Parent
  if nx_find_custom(gb_box, "is_checked") and not gb_box.is_checked then
    gb_box.BackImage = "gui\\map\\mapn\\select_on.png"
  end
end
function on_mltobx_task_lost_capture(self)
  local gb_box = self.Parent
  if nx_find_custom(gb_box, "is_checked") and not gb_box.is_checked then
    gb_box.BackImage = ""
  end
end
function update_label_image(form, task_id, picture, flag)
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    local is_find = mgr:ChangeLabelImage(nx_string(task_id), picture)
    if is_find and flag then
      local x = mgr:GetTaskLabelX(nx_string(task_id))
      local y = mgr:GetTaskLabelY(nx_string(task_id))
      set_map_center_according_world_pos(form, x, y)
    end
    if not is_find and flag then
      local gui = nx_value("gui")
      local text = gui.TextManager:GetFormatText("40102")
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      end
    end
  end
end
function creat_PolygonBox(npc_id, area, picture, task_id)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    local flag = mgr:GetPointList(form.map_query:GetCurrentScene(), area, npc_id, picture, nx_string(task_id))
    return flag
  end
end
function creat_task_polygonbox(npc_id, area, picture, task_id)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    auto_show_hide_map_scene()
  end
  local mgr = nx_value("TaskManager")
  if not nx_is_valid(mgr) then
    return
  end
  local groupscrollbox_task = form.groupscrollbox_task
  local list = groupscrollbox_task:GetChildControlList()
  if table.getn(list) < 0 then
    return
  end
  for _, control in pairs(list) do
    if control ~= nil and nx_find_custom(control, "is_checked") then
      control.BackImage = ""
      control.is_checked = false
      local child_list = control:GetChildControlList()
      for _, mul_box in pairs(child_list) do
        if nx_name(mul_box) == "MultiTextBox" then
          local pic = mgr:GetTaskIndexPicture(nx_int(mul_box.DataSource), 1)
          local gb_box = mul_box.Parent
          if nx_string(mul_box.DataSource) == nx_string(task_id) then
            mul_box:ChangeImage(0, 0, nx_string(picture))
            gb_box.BackImage = "gui\\map\\mapn\\select_on.png"
            gb_box.is_checked = true
          else
            mul_box:ChangeImage(0, 0, nx_string(pic))
            gb_box.BackImage = ""
            gb_box.is_checked = false
          end
          update_label_image(form, mul_box.DataSource, pic, false)
        end
      end
    end
  end
  update_label_image(form, task_id, picture, true)
end
function on_combobox_is_show_task_selected(self)
  local form = self.Parent
  local index = self.DropListBox.SelectIndex
  is_show_task(form, index)
end
function is_show_task(form, index)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  map_query:IsShowTask(form, index)
end
function get_scene_id(config_id)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return nx_int(-1)
  end
  return map_query:GetSceneId(config_id)
end
function save_check_flag(name, npctype, flag, pos)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_null()
  if nx_find_custom(form, "map_ui_ini") and nx_is_valid(form.map_ui_ini) then
    ini = form.map_ui_ini
  end
  if nx_is_valid(ini) then
    ini:WriteInteger(name, npctype, flag)
    ini:SaveToFile()
  end
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  if flag then
    head_game:SetMapSelectNpcInfo(nx_number(npctype), 1)
  else
    head_game:SetMapSelectNpcInfo(nx_number(npctype), 0)
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  for i, client_obj in pairs(client_obj_lst) do
    if client_obj:QueryProp("Type") == 4 and client_obj:QueryProp("NpcType") == nx_number(npctype) then
      local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
      head_game:RefreshAll(visual_obj)
    end
  end
end
function init_chtn_checked(ini, groupbox, sect_name)
  local list = groupbox:GetChildControlList()
  for _, control in pairs(list) do
    if control ~= nil and nx_name(control) == "CheckButton" then
      control.Checked = 1 == ini:ReadInteger(sect_name, control.NpcTypes, 1)
    end
  end
end
function load_check_flag(self)
  local ini = nx_null()
  if nx_find_custom(self, "map_ui_ini") and nx_is_valid(self.map_ui_ini) then
    ini = self.map_ui_ini
  end
  if nx_is_valid(ini) then
    local is_new_jh = is_newjhmodule()
    if is_new_jh then
      init_chtn_checked(ini, self.groupbox_new_boss, "new_boss")
      init_chtn_checked(ini, self.groupbox_new_mijing, "new_mijing")
      init_chtn_checked(ini, self.groupbox_new_supply, "new_supply")
      init_chtn_checked(ini, self.groupbox_new_explore, "new_explore")
      init_chtn_checked(ini, self.groupbox_new_produce, "new_produce")
    else
      init_chtn_checked(ini, self.groupbox_life, "Life")
      init_chtn_checked(ini, self.groupbox_shangren, "ShangRen")
      init_chtn_checked(ini, self.groupbox_caiji, "CaiJi")
      init_chtn_checked(ini, self.groupbox_wanfa, "wanfa")
      init_chtn_checked(ini, self.groupbox_base, "base")
      init_chtn_checked(ini, self.groupbox_menpai, "menpai")
      init_chtn_checked(ini, self.groupbox_guild, "guild")
      init_chtn_checked(ini, self.groupbox_jiayuan, "home")
    end
  end
end
function get_checked_number(groupbox)
  local cbtns = groupbox:GetChildControlList()
  local nums = 0
  local max_nums = 0
  for _, btn in ipairs(cbtns) do
    if nx_name(btn) == "CheckButton" then
      max_nums = max_nums + 1
      if btn.Checked then
        show_npc_by_type(btn.NpcTypes, btn.Checked)
        nums = nums + 1
      elseif nx_name(btn) == "CheckButton" and not btn.Checked and nx_find_custom(btn, "NpcTypes") and btn.NpcTypes ~= "" then
        nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(btn.NpcTypes), btn.Checked)
      end
    end
  end
  return nums, max_nums
end
function update_life_npc()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_life)
  change_cbtn_image(form_map.cbtn_select_life, max_num, nums)
end
function update_wanfa()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_wanfa)
  change_cbtn_image(form_map.cbtn_select_wanfa, max_num, nums)
end
function update_guild()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_guild)
  change_cbtn_image(form_map.cbtn_select_guild, max_num, nums)
end
function update_base()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_base)
  change_cbtn_image(form_map.cbtn_select_base, max_num, nums)
  if form_map.cbtn_npctype298.NpcTypes == "298" then
    show_npc_by_type("299", form_map.cbtn_npctype298.Checked)
    show_npc_by_type("303", form_map.cbtn_npctype298.Checked)
    show_npc_by_type("304", form_map.cbtn_npctype298.Checked)
    show_npc_by_type("306", form_map.cbtn_npctype298.Checked)
  end
  if form_map.cbtn_npctype43.NpcTypes == "43" then
    show_npc_by_type("53", form_map.cbtn_npctype43.Checked)
  end
end
function update_menpai()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_menpai)
  change_cbtn_image(form_map.cbtn_select_menpaizhiyin, max_num, nums)
end
function update_shangren_npc()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_shangren)
  change_cbtn_image(form_map.cbtn_select_shangren, max_num, nums)
end
function update_caiji_npc()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local cbtns = form_map.groupbox_caiji:GetChildControlList()
  local nums = 0
  local max_num = 0
  for _, btn in ipairs(cbtns) do
    if nx_name(btn) == "CheckButton" and nx_find_custom(btn, "life_id") then
      if btn.Checked then
        local flag = nx_execute("form_stage_main\\form_main\\form_main_shortcut", "is_learn_life_job", btn.life_id)
        if flag then
          show_npc_by_type(btn.NpcTypes, btn.Checked)
          nums = nums + 1
        else
          btn.Checked = false
          show_npc_by_type(btn.NpcTypes, false)
        end
      end
      max_num = max_num + 1
    end
    if nx_name(btn) == "CheckButton" and not btn.Checked and nx_find_custom(btn, "NpcTypes") then
      nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(btn.NpcTypes), btn.Checked)
    end
  end
  if form_map.cbtn_bingren.Checked then
    show_npc_by_type(form_map.cbtn_bingren.NpcTypes, form_map.cbtn_bingren.Checked)
    nums = nums + 1
  end
  max_num = max_num + 1
  change_cbtn_image(form_map.cbtn_select_caiji, max_num, nums)
end
function show_npc_by_type(types, flag)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  form.groupmap_objs:ShowType(nx_string(types), flag)
end
function init_form_set(self)
  hide_all(self)
  self.map_query:SetCbtnNpcTypes(self.groupbox_life)
  self.map_query:SetCbtnNpcTypes(self.groupbox_shangren)
  self.map_query:SetCbtnNpcTypes(self.groupbox_caiji)
  self.map_query:SetCbtnNpcTypes(self.groupbox_wanfa)
  self.map_query:SetCbtnNpcTypes(self.groupbox_base)
  self.map_query:SetCbtnNpcTypes(self.groupbox_menpai)
  self.map_query:SetCbtnNpcTypes(self.groupbox_guild)
  local ini = nx_execute("util_functions", "get_ini", "gui\\map\\map_func_sel.ini")
  local sect = ini:FindSectionIndex("Life")
  if 0 <= sect then
    local cbtns = self.groupbox_life:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  sect = ini:FindSectionIndex("CaiJi")
  if 0 <= sect then
    local cbtns = self.groupbox_caiji:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
    self.cbtn_buyu.life_id = "sh_yf"
    self.cbtn_kuangshi.life_id = "sh_kg"
    self.cbtn_famu.life_id = "sh_qf"
    self.cbtn_caoyao.life_id = "sh_ys"
    self.cbtn_duyao.life_id = "sh_ds"
    self.cbtn_canjia.life_id = "sh_nf"
    self.cbtn_duiyizhe.life_id = "sh_qis"
  end
  sect = ini:FindSectionIndex("ShangRen")
  if 0 <= sect then
    local cbtns = self.groupbox_shangren:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  sect = ini:FindSectionIndex("wanfa")
  if 0 <= sect then
    local cbtns = self.groupbox_wanfa:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  sect = ini:FindSectionIndex("base")
  if 0 <= sect then
    local cbtns = self.groupbox_base:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  sect = ini:FindSectionIndex("menpai")
  if 0 <= sect then
    local cbtns = self.groupbox_menpai:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  sect = ini:FindSectionIndex("guild")
  if 0 <= sect then
    local cbtns = self.groupbox_guild:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  sect = ini:FindSectionIndex("home")
  if 0 <= sect then
    local cbtns = self.groupbox_jiayuan:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  sect = ini:FindSectionIndex("produce")
  if 0 <= sect then
    local cbtns = self.groupbox_new_produce:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  sect = ini:FindSectionIndex("explore")
  if 0 <= sect then
    local cbtns = self.groupbox_new_explore:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  sect = ini:FindSectionIndex("boss")
  if 0 <= sect then
    local cbtns = self.groupbox_new_boss:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  sect = ini:FindSectionIndex("mijing")
  if 0 <= sect then
    local cbtns = self.groupbox_new_mijing:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  sect = ini:FindSectionIndex("supply")
  if 0 <= sect then
    local cbtns = self.groupbox_new_supply:GetChildControlList()
    for _, cbtn in ipairs(cbtns) do
      if nx_name(cbtn) == "CheckButton" then
        cbtn.NpcTypes = ini:ReadString(sect, cbtn.Name, "")
      end
    end
  end
  self.cbtn_select_base.can_jump = false
  self.cbtn_select_shangren.can_jump = false
  self.cbtn_select_caiji.can_jump = false
  self.cbtn_select_life.can_jump = false
  self.cbtn_select_menpaizhiyin.can_jump = false
  self.cbtn_select_wanfa.can_jump = false
  self.cbtn_select_guild.can_jump = false
  self.cbtn_select_home.can_jump = false
  load_check_flag(self)
  self.cbtn_select_base.can_jump = true
  self.cbtn_select_shangren.can_jump = true
  self.cbtn_select_caiji.can_jump = true
  self.cbtn_select_life.can_jump = true
  self.cbtn_select_menpaizhiyin.can_jump = true
  self.cbtn_select_wanfa.can_jump = true
  self.cbtn_select_guild.can_jump = true
  self.cbtn_select_home.can_jump = true
end
function hide_all(form)
  form.groupbox_life.Visible = false
  form.groupbox_shangren.Visible = false
  form.groupbox_caiji.Visible = false
  form.groupbox_wanfa.Visible = false
  form.groupbox_base.Visible = false
  form.groupbox_menpai.Visible = false
  form.groupbox_guild.Visible = false
  form.groupbox_jiayuan.Visible = false
  form.groupbox_new_explore.Visible = false
  form.groupbox_new_supply.Visible = false
  form.groupbox_new_mijing.Visible = false
  form.groupbox_new_boss.Visible = false
  form.groupbox_new_produce.Visible = false
end
function auto_show_npc()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  map_query:SetAutoShowNpc(form.groupmap_objs)
end
function on_check_changed_shangren_npc(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_select_shangren, self.NpcTypes)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_shangren)
  change_cbtn_image(form_map.cbtn_select_shangren, max_num, nums)
  save_check_flag("shangren", self.NpcTypes, self.Checked, self.DataSource)
end
function on_check_changed_caiji_npc(self)
  local form_map = self.ParentForm
  local flag = nx_execute("form_stage_main\\form_main\\form_main_shortcut", "is_learn_life_job", self.life_id)
  if flag then
    show_npc_by_type(self.NpcTypes, self.Checked)
    nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  else
    if self.Checked then
      if form_map.is_open then
        local gui = nx_value("gui")
        gui.TextManager:Format_SetIDName("1148")
        gui.TextManager:Format_AddParam(self.life_id)
        local text = gui.TextManager:Format_GetText()
        local SystemCenterInfo = nx_value("SystemCenterInfo")
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(text, 2)
        end
      end
      self.Checked = false
    end
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_caiji)
  change_cbtn_image(form_map.cbtn_select_caiji, max_num, nums)
  save_check_flag("CaiJi", self.NpcTypes, self.Checked, self.DataSource)
end
function on_cbtn_lingcao_checked_changed(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_caiji)
  change_cbtn_image(form_map.cbtn_select_caiji, max_num, nums)
  save_check_flag("CaiJi", self.NpcTypes, self.Checked, self.DataSource)
end
function on_check_changed_bingren(self)
  local form_map = self.ParentForm
  if self.Checked then
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    if not nx_function("find_buffer", client_player, "buf_jzsj_029") then
      if form_map.is_open then
        local gui = nx_value("gui")
        local SystemCenterInfo = nx_value("SystemCenterInfo")
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("5555501"), 2)
        end
      end
      self.Checked = false
      return
    end
  end
  show_npc_by_type(self.NpcTypes, self.Checked)
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_caiji)
  change_cbtn_image(form_map.cbtn_select_caiji, max_num, nums)
  save_check_flag("CaiJi", self.NpcTypes, self.Checked, self.DataSource)
end
function on_check_changed_life_npc(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_select_life, self.NpcTypes)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_life)
  change_cbtn_image(form_map.cbtn_select_life, max_num, nums)
  save_check_flag("Life", self.NpcTypes, self.Checked, self.DataSource)
end
function on_check_changed_base(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.NpcTypes == "298" then
    show_npc_by_type("299", self.Checked)
    show_npc_by_type("303", self.Checked)
    show_npc_by_type("304", self.Checked)
    show_npc_by_type("306", self.Checked)
  elseif self.NpcTypes == "43" then
    show_npc_by_type("53", self.Checked)
    nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(53), self.Checked)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_select_base, self.NpcTypes)
  end
  local nums, max_num = get_checked_number(form_map.groupbox_base)
  change_cbtn_image(form_map.cbtn_select_base, max_num, nums)
  save_check_flag("base", self.NpcTypes, self.Checked, self.DataSource)
end
function on_check_changed_menpai(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_select_menpaizhiyin, self.NpcTypes)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_menpai)
  change_cbtn_image(form_map.cbtn_select_menpaizhiyin, max_num, nums)
  save_check_flag("menpai", self.NpcTypes, self.Checked, self.DataSource)
end
function on_check_changed_guild(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_select_guild, self.NpcTypes)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_guild)
  change_cbtn_image(form_map.cbtn_select_guild, max_num, nums)
  save_check_flag("guild", self.NpcTypes, self.Checked, self.DataSource)
end
function on_cbtn_guild_pk_arena_checked_changed(self)
  local form_map = self.ParentForm
  local mgr = nx_value("SceneCreator")
  if not nx_is_valid(mgr) then
    return
  end
  if self.Checked then
  else
    mgr:DeleteGuildPkArena()
  end
  local nums, max_num = get_checked_number(form_map.groupbox_guild)
  change_cbtn_image(form_map.cbtn_select_guild, max_num, nums)
  save_check_flag("guild", self.NpcTypes, self.Checked, self.DataSource)
end
function on_cbtn_school_pk_arena_checked_changed(self)
  local form_map = self.ParentForm
  local mgr = nx_value("SceneCreator")
  if not nx_is_valid(mgr) then
    return
  end
  if self.Checked then
    mgr:RefreshSchoolPkArena()
  else
    mgr:DeleteSchoolPkArena()
  end
  local nums, max_num = get_checked_number(form_map.groupbox_menpai)
  change_cbtn_image(form_map.cbtn_select_menpaizhiyin, max_num, nums)
  save_check_flag("menpai", self.NpcTypes, self.Checked, self.DataSource)
end
function on_check_changed_wanfa(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_select_wanfa, self.NpcTypes)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_wanfa)
  change_cbtn_image(form_map.cbtn_select_wanfa, max_num, nums)
  save_check_flag("wanfa", self.NpcTypes, self.Checked, self.DataSource)
end
function change_cbtn_image(cbtn, max_num, nums)
  if nums == max_num then
    cbtn.Checked = true
    cbtn.NormalImage = PHOTO_SELECT_OUT
    cbtn.FocusImage = PHOTO_SELECT_ON
    cbtn.CheckedImage = PHOTO_SELECT_DOWN
  elseif nums == 0 then
    cbtn.Checked = false
    cbtn.NormalImage = PHOTO_SELECT_OUT
    cbtn.FocusImage = PHOTO_SELECT_ON
    cbtn.CheckedImage = PHOTO_SELECT_DOWN
  else
    cbtn.NormalImage = PHOTO_SELECT2_OUT
    cbtn.FocusImage = PHOTO_SELECT2_ON
    cbtn.CheckedImage = PHOTO_SELECT2_DOWN
  end
end
function on_rbtn_task_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_task.Visible = self.Checked
  form.groupbox_scene_page.Visible = not self.Checked
end
function on_rbtn_npc_find_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_task.Visible = not self.Checked
  form.groupbox_scene_page.Visible = self.Checked
end
function on_cbtn_select_life_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_life, self)
  form.cbtn_select_life.NormalImage = PHOTO_SELECT_OUT
  form.cbtn_select_life.FocusImage = PHOTO_SELECT_ON
  form.cbtn_select_life.CheckedImage = PHOTO_SELECT_DOWN
end
function on_cbtn_select_shangren_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_shangren, self)
  form.cbtn_select_shangren.NormalImage = PHOTO_SELECT_OUT
  form.cbtn_select_shangren.FocusImage = PHOTO_SELECT_ON
  form.cbtn_select_shangren.CheckedImage = PHOTO_SELECT_DOWN
end
function on_cbtn_select_caiji_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_caiji, self)
  local nums, max_num = get_checked_number(form.groupbox_caiji)
  change_cbtn_image(form.cbtn_select_caiji, max_num, nums)
end
function on_cbtn_select_wanfa_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_wanfa, self)
  form.cbtn_select_wanfa.NormalImage = PHOTO_SELECT_OUT
  form.cbtn_select_wanfa.FocusImage = PHOTO_SELECT_ON
  form.cbtn_select_wanfa.CheckedImage = PHOTO_SELECT_DOWN
end
function on_cbtn_select_base_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_base, self)
  form.cbtn_select_base.NormalImage = PHOTO_SELECT_OUT
  form.cbtn_select_base.FocusImage = PHOTO_SELECT_ON
  form.cbtn_select_base.CheckedImage = PHOTO_SELECT_DOWN
end
function on_cbtn_select_menpaizhiyin_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_menpai, self)
  form.cbtn_school_pk_arena.Checked = self.Checked
  form.cbtn_select_menpaizhiyin.NormalImage = PHOTO_SELECT_OUT
  form.cbtn_select_menpaizhiyin.FocusImage = PHOTO_SELECT_ON
  form.cbtn_select_menpaizhiyin.CheckedImage = PHOTO_SELECT_DOWN
end
function on_cbtn_select_guild_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_guild, self)
  form.cbtn_select_guild.NormalImage = PHOTO_SELECT_OUT
  form.cbtn_select_guild.FocusImage = PHOTO_SELECT_ON
  form.cbtn_select_guild.CheckedImage = PHOTO_SELECT_DOWN
end
function select_all(form, groupbox, self)
  local list = groupbox:GetChildControlList()
  if table.getn(list) < 0 then
    return
  end
  for _, control in pairs(list) do
    if control ~= nil and nx_name(control) == "CheckButton" and control.NpcTypes ~= "" then
      control.Checked = self.Checked
    end
  end
end
function on_btn_label_show_click(self)
  local form = self.ParentForm
  local form_label_list = nx_value("form_stage_main\\form_map\\form_map_label_list")
  if not nx_is_valid(form_label_list) then
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_map\\form_map_label_list")
  else
    form_label_list.Visible = not form_label_list.Visible
  end
  local form_label_list = nx_value("form_stage_main\\form_map\\form_map_label_list")
  if nx_is_valid(form_label_list) and form_label_list.Visible then
    local gui = nx_value("gui")
    gui.Desktop:ToFront(form_label_list)
    form_label_list.btn_label.Enabled = form.can_add_label
  end
end
function show_chouren(show, name, pos_x, pos_y, scene)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  if nx_string(scene) ~= nx_string(form.map_query:GetCurrentScene()) then
    form.lbl_chouren.Visible = false
    return
  end
  local sx, sy = trans_scene_pos_to_map(pos_x, pos_y, form.pic_map)
  form.lbl_chouren.AbsLeft = form.pic_map.AbsLeft + sx
  form.lbl_chouren.AbsTop = form.pic_map.AbsTop + sy
  form.lbl_chouren.name = name
  form.lbl_chouren.x = pos_x
  form.lbl_chouren.y = pos_y
  form.lbl_chouren.Visible = show
end
function show_zhuizong(show, name, pos_x, pos_y, scene)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  if nx_string(scene) ~= nx_string(form.map_query:GetCurrentScene()) then
    form.lbl_zhuizong.Visible = false
    form.lbl_zhuizong.show = false
    return
  end
  local sx, sy = trans_scene_pos_to_map(pos_x, pos_y, form.pic_map)
  form.lbl_zhuizong.AbsLeft = form.pic_map.AbsLeft + sx
  form.lbl_zhuizong.AbsTop = form.pic_map.AbsTop + sy
  form.lbl_zhuizong.name = name
  form.lbl_zhuizong.x = pos_x
  form.lbl_zhuizong.y = pos_y
  form.lbl_zhuizong.show = show
  if nx_find_custom(form.lbl_zhuizong, "show") and form.lbl_zhuizong.show then
    form.lbl_zhuizong.Visible = form.map_query:IsInMap(form.lbl_zhuizong, form.pic_map)
  else
    form.lbl_zhuizong.Visible = false
  end
end
function on_lbl_chouren_get_capture(self)
  if not self.Visible then
    return
  end
  if not (nx_find_custom(self, "name") and nx_find_custom(self, "x")) or not nx_find_custom(self, "y") then
    return
  end
  local gui = nx_value("gui")
  local title = gui.TextManager:GetText("ui_xuechou_01")
  local text = gui.TextManager:GetFormatText("<font color=\"#B9B29F\">[{@0:type}]</font><br><font color=\"#FFFFFF\">{@1:name}</font><br><font color=\"#ED5F00\">({@2:x},{@3:y})</font>", title, nx_widestr(self.name), nx_int(self.x), nx_int(self.y))
  local form = self.ParentForm
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 0, form)
end
function on_lbl_zhuizong_get_capture(self)
  if not self.Visible then
    return
  end
  if not (nx_find_custom(self, "name") and nx_find_custom(self, "x")) or not nx_find_custom(self, "y") then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("<font color=\"#FFFFFF\">{@0:name}</font><br><font color=\"#ED5F00\">({@1:x},{@2:y})</font>", nx_widestr(self.name), nx_int(self.x), nx_int(self.y))
  local form = self.ParentForm
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 0, form)
end
function on_lbl_chouren_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_lbl_zhuizong_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function update_chouren()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not (nx_is_valid(form) and nx_find_custom(form.lbl_chouren, "x")) or not nx_find_custom(form.lbl_chouren, "y") then
    return
  end
  if not form.lbl_chouren.Visible then
    return
  end
  local sx, sz = trans_scene_pos_to_map(form.lbl_chouren.x, form.lbl_chouren.y, form.pic_map)
  form.lbl_chouren.AbsLeft = form.pic_map.AbsLeft + sx
  form.lbl_chouren.AbsTop = form.pic_map.AbsTop + sz
end
function update_zhuizong()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not (nx_is_valid(form) and nx_find_custom(form.lbl_zhuizong, "x")) or not nx_find_custom(form.lbl_zhuizong, "y") then
    return
  end
  if nx_find_custom(form.lbl_zhuizong, "show") and form.lbl_zhuizong.show then
    form.lbl_zhuizong.Visible = form.map_query:IsInMap(form.lbl_zhuizong, form.pic_map)
  else
    form.lbl_zhuizong.Visible = false
  end
  local sx, sz = trans_scene_pos_to_map(form.lbl_zhuizong.x, form.lbl_zhuizong.y, form.pic_map)
  form.lbl_zhuizong.AbsLeft = form.pic_map.AbsLeft + sx
  form.lbl_zhuizong.AbsTop = form.pic_map.AbsTop + sz
end
function point_is_in_map(form, x, y)
  local gui = nx_value("gui")
  if "" == nx_string(form.ipt_x.Text) or "" == nx_string(form.ipt_y.Text) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
    if nx_is_valid(dialog) then
      dialog.mltbox_info:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_map_zuobiao_Tips")), -1)
      dialog.Left = form.Left + (form.Width - dialog.Width) / 2
      dialog.Top = form.Top + (form.Height - dialog.Height) / 2
      dialog:ShowModal()
    end
    return false
  end
  local start_x = form.pic_map.TerrainStartX
  local start_y = form.pic_map.TerrainStartZ
  local map_width = form.pic_map.TerrainWidth
  local map_height = form.pic_map.TerrainHeight
  if x < start_x or x > start_x + map_width or y < start_y or y > start_y + map_height then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
    if nx_is_valid(dialog) then
      dialog.mltbox_info:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_map_zuobiao_serch")), -1)
      dialog.Left = form.Left + (form.Width - dialog.Width) / 2
      dialog.Top = form.Top + (form.Height - dialog.Height) / 2
      dialog:ShowModal()
    end
    return false
  end
  return true
end
function on_btn_find_pos_click(self)
  local flag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
  local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if flag or flag_apex then
    return
  end
  local form = self.ParentForm
  local x = nx_number(form.ipt_x.Text)
  local y = nx_number(form.ipt_y.Text)
  if not point_is_in_map(form, x, y) then
    return
  end
  set_map_center_according_world_pos(form, x, y)
  set_trace_npc_id(nil, x, -10000, y, form.current_map, true)
end
function on_btn_add_label_click(self)
  local flag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
  local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if flag or flag_apex then
    return
  end
  local form = self.ParentForm
  local pic_map = form.pic_map
  local x = nx_number(form.ipt_x.Text)
  local y = nx_number(form.ipt_y.Text)
  if not point_is_in_map(form, x, y) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_map\\form_map_label_detail", true, false)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "cancel" then
    return
  end
  local npc_id = nx_string(dialog.name_edit.Text)
  local npc_type = dialog.NpcTypes
  add_defined_label(form, x, 0, y, npc_type, npc_id)
end
function set_npc_center(cbtn, npc_type)
  if nx_find_custom(cbtn, "can_jump") and not cbtn.can_jump then
    return
  end
  local form = cbtn.ParentForm
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    local x, y, z = mgr:GetNpcPositionByNpcType(form.map_query:GetCurrentScene(), nx_int(npc_type))
    if x and z then
      set_map_center_according_world_pos(form, x, z)
    end
  end
end
function on_show_scene_npc(scene, npc_type)
  if nx_running(nx_current(), "on_show_scene_npc") then
    return
  end
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_is_valid(form) then
    if not form.Visible then
      auto_show_hide_map_scene()
    end
  else
    auto_show_hide_map_scene()
    form = nx_value("form_stage_main\\form_map\\form_map_scene")
  end
  if not nx_is_valid(form) then
    return
  end
  turn_to_scene_map(form, scene)
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    local x, y, z = mgr:GetNpcPositionByNpcType(scene, nx_int(npc_type))
    if x and z then
      set_map_center_according_world_pos(form, x, z)
      set_trace_npc_id(nil, x, -10000, z, form.current_map, true)
    end
  end
end
function on_tree_npc_mouse_in_node(self, node)
  local gui = nx_value("gui")
  local form = self.ParentForm
  if nx_find_custom(node, "main_area") and nx_find_custom(node, "sub_area") and nx_find_custom(node, "work") then
    local mouse_x, mouse_z = gui:GetCursorPosition()
    local name = gui.TextManager:GetText(nx_string(node.npc_id))
    local text = nx_widestr("<font color=\"#ffffff\">") .. name .. nx_widestr("</font><br><font color=\"#00B0F0\">") .. nx_widestr(node.work) .. nx_widestr("</font>")
    nx_execute("tips_game", "show_text_tip", nx_widestr(text), mouse_x, mouse_z, 0, form)
  end
end
function on_tree_npc_mouse_out_node(self, node)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_rbtn_guild_map_checked_changed(rbtn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and not switch_manager:CheckSwitchEnable(906) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("desc_events_250"))
    return
  end
  if not rbtn.Checked then
    return
  end
  if is_in_cross_station_war() then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_cross_station_war_map", "open_form_for_browse")
  else
    nx_execute("form_stage_main\\form_guild_global_war\\form_guild_global_war_domain", "open_form_for_browse")
  end
  auto_show_hide_map_scene()
end
function is_in_cross_station_war()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local cross_type = client_player:QueryProp("CrossType")
  return nx_int(28) == nx_int(cross_type)
end
function on_rbtn_school_map_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  nx_execute("form_stage_main\\form_school_domain\\form_school_domain_map", "open_form_for_browse")
  auto_show_hide_map_scene()
end
function add_label_to_map(id, x, z, label_type, tips)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  if label_type == nil then
    label_type = MAP_CLIENT_NPC
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  if map_query:GetCurrentScene() ~= form.current_map then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local sx, sz = trans_scene_pos_to_map(x, z, form.pic_map)
  local lab = form.groupbox_map:Find("map_label_" .. nx_string(id))
  if not nx_is_valid(lab) then
    lab = gui:Create("Label")
    lab.Name = "map_label_" .. nx_string(id)
    lab.AutoSize = true
    lab.BackImage = map_lable_icon[id]
    lab.Left = sx - lab.Width / 2
    lab.Top = sz - lab.Height / 2
    lab.Transparent = false
    if tips ~= nil then
      lab.HintText = nx_widestr(util_text(tips))
    end
    form.groupbox_map:Add(lab)
  else
    lab.Left = sx - lab.Width / 2
    lab.Top = sz - lab.Height / 2
  end
  map_query:AddLabelToMap("map_label_" .. nx_string(id), lab, x, z, label_type)
  lab.Visible = map_query:IsInMap(lab, form.pic_map)
end
function add_label_to_map_ani(id, x, z, width, height, label_type, tips)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  if label_type == nil then
    label_type = MAP_CLIENT_NPC
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  if map_query:GetCurrentScene() ~= form.current_map then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local sx, sz = trans_scene_pos_to_map(x, z, form.pic_map)
  local lab = form.groupbox_map:Find("map_label_" .. nx_string(id))
  if not nx_is_valid(lab) then
    lab = gui:Create("Label")
    lab.Name = "map_label_" .. nx_string(id)
    lab.BackImage = map_lable_icon[id]
    lab.Left = sx - width / 2
    lab.Top = sz - height / 2
    lab.Width = width
    lab.Height = height
    lab.Transparent = false
    if tips ~= nil then
      lab.HintText = nx_widestr(util_text(tips))
    end
    form.groupbox_map:Add(lab)
  else
    lab.Left = sx - width / 2
    lab.Top = sz - height / 2
  end
  map_query:AddLabelToMap("map_label_" .. nx_string(id), lab, x, z, nx_int(label_type))
  lab.Visible = map_query:IsInMap(lab, form.pic_map)
end
function delete_map_label(id)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local lab = form.groupbox_map:Find("map_label_" .. nx_string(id))
  if nx_is_valid(lab) then
    gui:Delete(lab)
    local map_query = nx_value("MapQuery")
    if nx_is_valid(map_query) then
      map_query:DeleteMapLabel("map_label_" .. nx_string(id))
    end
  end
end
function open_XinShiLi_node()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  if not form_map.Visible then
    auto_show_hide_map_scene()
  end
  form_map.rbtn_npc_find.Checked = true
  local npc_tree = form_map.tree_npc
  if not nx_is_valid(npc_tree) then
    return
  end
  local node = npc_tree.RootNode
  if not nx_is_valid(node) then
    return
  end
  local gui = nx_value("gui")
  local areas = form_map.map_query:GetRegionsOfScene(form_map.current_map)
  for _, area in ipairs(areas) do
    local sub_tree_note = node:FindNode(gui.TextManager:GetText(area))
    if nx_is_valid(sub_tree_note) then
      local node_xinshili = sub_tree_note:FindNode(util_text("ui_XinShiLi"))
      if nx_is_valid(node_xinshili) then
        node_xinshili.Expand = true
        sub_tree_note.Expand = true
        return
      end
    end
  end
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "30354")
end
function refresh_npc_pos(form)
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  nx_execute("custom_sender", "custom_map_get_dynamic_object_pos", MAP_TENT_NPC)
end
function refresh_sns_pos(form)
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  map_query:UpdateSnsData()
end
function hide_control()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_select.Visible = false
  form.groupbox_label_set.Visible = false
  form.groupbox_task.Visible = false
  form.btn_label_show.Visible = false
  form.groupbox_1.Visible = false
  form.btn_back.Visible = false
  form.combobox_is_show_task.Visible = false
  form.lbl_7.Visible = false
  form.groupbox_switch_rbtn.Visible = false
  form.groupbox_find_pos.Visible = false
  form.btn_tianqi.Visible = false
  form.lbl_zoom.Visible = false
  form.btn_up.Visible = false
  form.btn_down.Visible = false
  form.btn_left.Visible = false
  form.btn_right.Visible = false
  form.btn_home.Visible = false
  form.btn_newdrop_box.Visible = true
  form.groupbox_new_jh_label_set.Visible = true
  init_btn_newdrop_box(form.btn_newdrop_box)
  form.Width = 718
  form.Height = 680
  form:ToFront(form.groupbox_back)
  form:ToFront(form.groupbox_new_jh_label_set)
end
function show_control()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_select.Visible = true
  form.groupbox_label_set.Visible = true
  form.btn_label_show.Visible = true
  form.groupbox_1.Visible = true
  form.btn_back.Visible = true
  form.combobox_is_show_task.Visible = true
  form.lbl_7.Visible = true
  form.groupbox_switch_rbtn.Visible = true
  form.groupbox_find_pos.Visible = true
  form.btn_tianqi.Visible = true
  form.lbl_zoom.Visible = true
  form.btn_up.Visible = true
  form.btn_down.Visible = true
  form.btn_left.Visible = true
  form.btn_right.Visible = true
  form.btn_home.Visible = true
  form.btn_newdrop_box.Visible = false
  form.groupbox_new_jh_label_set.Visible = false
  form.Width = 920
  form.Height = 680
  form:ToBack(form.groupbox_back)
end
function on_label_drop_get_capture(lbl)
  local form = lbl.ParentForm
  if not (nx_find_custom(lbl, "x") and nx_find_custom(lbl, "z")) or not nx_find_custom(lbl, "stop_time") then
    return
  end
  local MessageDelay = nx_value("MessageDelay")
  if not nx_is_valid(MessageDelay) then
    return
  end
  local stop_time = lbl.stop_time
  local cur_time = MessageDelay:GetServerSecond()
  local dis = stop_time - cur_time
  local time_minute = nx_int(dis / 60)
  local time_second = math.fmod(dis, 60)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("tips_jh_drop_info")
  gui.TextManager:Format_AddParam(nx_int(lbl.x))
  gui.TextManager:Format_AddParam(nx_int(lbl.z))
  gui.TextManager:Format_AddParam(nx_int(time_minute))
  gui.TextManager:Format_AddParam(nx_int(time_second))
  nx_execute("tips_game", "show_text_tip", gui.TextManager:Format_GetText(), lbl.AbsLeft + lbl.Width / 2, lbl.AbsTop - lbl.Height / 2, 0, form)
end
function on_label_drop_lost_capture(lbl)
  local form = lbl.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function on_label_drop_click(lbl)
  local form = lbl.ParentForm
  if not (nx_find_custom(lbl, "x") and nx_find_custom(lbl, "z")) or not nx_find_custom(lbl, "box_npc") then
    return
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "set_drop_box_npc_id", lbl.box_npc, lbl.x, lbl.z, form.current_map)
end
function set_control_ui(control)
  if not nx_is_valid(control) then
    return
  end
  local out_image = get_ini_prop(MAP_NEW_INI, control.Name, "out", "")
  local on_image = get_ini_prop(MAP_NEW_INI, control.Name, "on", "")
  local down_image = get_ini_prop(MAP_NEW_INI, control.Name, "down", "")
  local left = get_ini_prop(MAP_NEW_INI, control.Name, "left", "")
  local top = get_ini_prop(MAP_NEW_INI, control.Name, "top", "")
  local width = get_ini_prop(MAP_NEW_INI, control.Name, "width", "")
  local height = get_ini_prop(MAP_NEW_INI, control.Name, "height", "")
  if nx_name(control) == "Label" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "Button" then
    if out_image ~= "" then
      control.NormalImage = out_image
    end
    if on_image ~= "" then
      control.FocusImage = on_image
    end
    if down_image ~= "" then
      control.PushImage = down_image
    end
  elseif nx_name(control) == "CheckButton" or nx_name(control) == "RadioButton" then
    if out_image ~= "" then
      control.NormalImage = out_image
    end
    if on_image ~= "" then
      control.FocusImage = on_image
    end
    if down_image ~= "" then
      control.CheckedImage = down_image
    end
  elseif nx_name(control) == "GroupBox" or nx_name(control) == "GroupScrollableBox" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "Edit" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "MultiTextBox" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "TrackBar" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
    control.TrackButton.NormalImage = get_ini_prop(MAP_NEW_INI, "TrackButton", "out", "")
    control.TrackButton.FocusImage = get_ini_prop(MAP_NEW_INI, "TrackButton", "on", "")
    control.TrackButton.PushImage = get_ini_prop(MAP_NEW_INI, "TrackButton", "down", "")
  else
    return
  end
  if left ~= "" and top ~= "" then
    control.Left = nx_number(left)
    control.Top = nx_number(top)
  end
  if width ~= "" and height ~= "" then
    control.Width = nx_number(width)
    control.Height = nx_number(height)
  end
end
function reset_form_ui(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", MAP_NEW_INI)
  if not nx_is_valid(ini) then
    return
  end
  local gui = nx_value("gui")
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local sec_name = ini:GetSectionByIndex(i)
    local control = nx_custom(form, sec_name)
    if nx_is_valid(control) then
      set_control_ui(control)
    end
  end
end
function on_btn_newdrop_box_click(btn)
  nx_execute("form_stage_main\\form_map\\form_map_drop", "auto_show_form")
  btn.NormalImage = "gui\\map\\mapn\\map_new\\bag_1.png"
end
function init_btn_newdrop_box(btn)
  if not nx_is_valid(btn) then
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
  local rec_name = "JHDropBoxRec"
  local row_count = client_player:GetRecordRows(rec_name)
  if 0 < row_count then
    btn.NormalImage = "jh_drop_mapbox"
  else
    btn.NormalImage = "gui\\map\\mapn\\map_new\\bag_1.png"
  end
end
function on_cbtn_home_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_jiayuan.Visible then
    form.groupbox_jiayuan.Visible = false
    return
  end
  set_cbtn_checked(form, cbtn)
  form.groupbox_jiayuan.AbsLeft = cbtn.AbsLeft
  form.groupbox_jiayuan.AbsTop = cbtn.AbsTop - form.groupbox_jiayuan.Height
  form.groupbox_jiayuan.Visible = cbtn.Checked
end
function on_cbtn_select_home_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_jiayuan, cbtn)
  cbtn.NormalImage = PHOTO_SELECT_OUT
  cbtn.FocusImage = PHOTO_SELECT_ON
  cbtn.CheckedImage = PHOTO_SELECT_DOWN
end
function on_check_changed_home_npc(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_select_home, self.NpcTypes)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local cbtns = form_map.groupbox_jiayuan:GetChildControlList()
  local nums, max_num = get_checked_number(form_map.groupbox_jiayuan)
  change_cbtn_image(form_map.cbtn_select_home, max_num, nums)
  save_check_flag("home", self.NpcTypes, self.Checked, self.DataSource)
end
function on_rbtn_home_map_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home", "open_form")
  auto_show_hide_map_scene()
end
function update_home_npc()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_jiayuan)
  change_cbtn_image(form_map.cbtn_select_home, max_num, nums)
end
function on_btn_clearfog_box_click(btn)
  local form = nx_value("form_stage_main\\form_map\\form_newmap_clearfog")
  if nx_is_valid(form) then
    form:Close()
  else
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_map\\form_newmap_clearfog", true, false)
    form:Show()
  end
end
function save_fog_info()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  if not form.pic_mask.Visible then
    return
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  map_query:SavePixelMap(form.pic_mask, form.current_map)
end
function load_fog_info(form)
  if not nx_is_valid(form) then
    return
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  local len = form.pic_mask:GetPixelMapLen()
  map_query:SetPixelMap(form.pic_mask, form.current_map, len)
end
function on_cbtn_boss_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_new_boss.Visible then
    form.groupbox_new_boss.Visible = false
    return
  end
  set_cbtn_checked(form, cbtn)
  form.groupbox_new_boss.AbsLeft = cbtn.AbsLeft
  form.groupbox_new_boss.AbsTop = cbtn.AbsTop - form.groupbox_new_boss.Height
  form.groupbox_new_boss.Visible = cbtn.Checked
end
function on_cbtn_mijing_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_new_mijing.Visible then
    form.groupbox_new_mijing.Visible = false
    return
  end
  set_cbtn_checked(form, cbtn)
  form.groupbox_new_mijing.AbsLeft = cbtn.AbsLeft
  form.groupbox_new_mijing.AbsTop = cbtn.AbsTop - form.groupbox_new_mijing.Height
  form.groupbox_new_mijing.Visible = cbtn.Checked
end
function on_cbtn_supply_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_new_supply.Visible then
    form.groupbox_new_supply.Visible = false
    return
  end
  set_cbtn_checked(form, cbtn)
  form.groupbox_new_supply.AbsLeft = cbtn.AbsLeft
  form.groupbox_new_supply.AbsTop = cbtn.AbsTop - form.groupbox_new_supply.Height
  form.groupbox_new_supply.Visible = cbtn.Checked
end
function on_cbtn_produce_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_new_produce.Visible then
    form.groupbox_new_produce.Visible = false
    return
  end
  set_cbtn_checked(form, cbtn)
  form.groupbox_new_produce.AbsLeft = cbtn.AbsLeft
  form.groupbox_new_produce.AbsTop = cbtn.AbsTop - form.groupbox_new_produce.Height
  form.groupbox_new_produce.Visible = cbtn.Checked
end
function on_cbtn_explore_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_new_explore.Visible then
    form.groupbox_new_explore.Visible = false
    return
  end
  set_cbtn_checked(form, cbtn)
  form.groupbox_new_explore.AbsLeft = cbtn.AbsLeft
  form.groupbox_new_explore.AbsTop = cbtn.AbsTop - form.groupbox_new_explore.Height
  form.groupbox_new_explore.Visible = cbtn.Checked
end
function on_cbtn_boss_select_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_new_boss, cbtn)
  cbtn.NormalImage = PHOTO_SELECT_OUT
  cbtn.FocusImage = PHOTO_SELECT_ON
  cbtn.CheckedImage = PHOTO_SELECT_DOWN
end
function on_cbtn_mijing_select_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_new_mijing, cbtn)
  cbtn.NormalImage = PHOTO_SELECT_OUT
  cbtn.FocusImage = PHOTO_SELECT_ON
  cbtn.CheckedImage = PHOTO_SELECT_DOWN
end
function on_cbtn_supply_select_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_new_supply, cbtn)
  cbtn.NormalImage = PHOTO_SELECT_OUT
  cbtn.FocusImage = PHOTO_SELECT_ON
  cbtn.CheckedImage = PHOTO_SELECT_DOWN
end
function on_cbtn_explore_select_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_new_explore, cbtn)
  cbtn.NormalImage = PHOTO_SELECT_OUT
  cbtn.FocusImage = PHOTO_SELECT_ON
  cbtn.CheckedImage = PHOTO_SELECT_DOWN
end
function on_cbtn_produce_select_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_all(form, form.groupbox_new_produce, cbtn)
  cbtn.NormalImage = PHOTO_SELECT_OUT
  cbtn.FocusImage = PHOTO_SELECT_ON
  cbtn.CheckedImage = PHOTO_SELECT_DOWN
end
function on_check_changed_new_boss_npc(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_boss_select, self.NpcTypes)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_new_boss)
  change_cbtn_image(form_map.cbtn_boss_select, max_num, nums)
  save_check_flag("new_boss", self.NpcTypes, self.Checked, self.DataSource)
end
function on_check_changed_new_mijing_npc(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_mijing_select, self.NpcTypes)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_new_mijing)
  change_cbtn_image(form_map.cbtn_mijing_select, max_num, nums)
  save_check_flag("new_mijing", self.NpcTypes, self.Checked, self.DataSource)
end
function on_check_changed_new_supply_npc(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_supply_select, self.NpcTypes)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_new_supply)
  change_cbtn_image(form_map.cbtn_supply_select, max_num, nums)
  save_check_flag("new_supply", self.NpcTypes, self.Checked, self.DataSource)
end
function on_check_changed_new_produce_npc(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_produce_select, self.NpcTypes)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_new_produce)
  change_cbtn_image(form_map.cbtn_produce_select, max_num, nums)
  save_check_flag("new_produce", self.NpcTypes, self.Checked, self.DataSource)
end
function on_check_changed_new_explore_npc(self)
  local form_map = self.ParentForm
  show_npc_by_type(self.NpcTypes, self.Checked)
  if self.Checked then
    set_npc_center(form_map.cbtn_explore_select, self.NpcTypes)
  end
  nx_execute("form_stage_main\\form_main\\form_main_map", "show_object", nx_int(self.NpcTypes), self.Checked)
  local nums, max_num = get_checked_number(form_map.groupbox_new_explore)
  change_cbtn_image(form_map.cbtn_explore_select, max_num, nums)
  save_check_flag("new_explore", self.NpcTypes, self.Checked, self.DataSource)
end
function update_new_boss_npc()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_new_boss)
  change_cbtn_image(form_map.cbtn_boss_select, max_num, nums)
end
function update_new_mijing_npc()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_new_mijing)
  change_cbtn_image(form_map.cbtn_mijing_select, max_num, nums)
end
function update_new_supply_npc()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_new_supply)
  change_cbtn_image(form_map.cbtn_supply_select, max_num, nums)
end
function update_new_explore_npc()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_new_explore)
  change_cbtn_image(form_map.cbtn_explore_select, max_num, nums)
end
function update_new_produce_npc()
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local nums, max_num = get_checked_number(form_map.groupbox_new_produce)
  change_cbtn_image(form_map.cbtn_produce_select, max_num, nums)
end
function create_random_terrain_map(form, scene_name, map_name, width, height)
  if not nx_is_valid(form) then
    return false
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return false
  end
  local dynamic_clone_helper = nx_value("DynamicCloneHelper")
  if not nx_is_valid(dynamic_clone_helper) then
    return false
  end
  local texture_tool = form.texture_tool
  if not nx_is_valid(texture_tool) then
    return false
  end
  if map_name == "" then
    return false
  end
  local pic_width = map_query:GetDynPicWidth(scene_name)
  local pic_path = map_query:GetDynPicPath(scene_name)
  if pic_width == 0 or pic_path == "" then
    return false
  end
  local info = dynamic_clone_helper:GetDynamicCloneMapInfo()
  local list = util_split_string(info, ";")
  if table.getn(list) ~= 2 then
    return false
  end
  local list_info = util_split_string(list[1], ",")
  if table.getn(list_info) ~= 5 then
    return false
  end
  local row_count = nx_int(list_info[1])
  local col_count = nx_int(list_info[2])
  local zone_size = nx_int(list_info[3])
  local first_scene_x = nx_int(list_info[4])
  local first_scene_z = nx_int(list_info[5])
  local list_pic = util_split_string(list[2], ",")
  if table.getn(list_pic) ~= row_count * col_count then
    return false
  end
  local image_x, image_z = SceneCoordToImageCoord(width, height, first_scene_x, first_scene_z, form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  image_x = image_x - pic_width
  texture_tool:ClearCopyTextures()
  texture_tool:AddCopyTexture(pic_path .. map_name .. ".dds", 0, 0, width, height)
  for i = 0, row_count - 1 do
    local cur_row = image_z + i * pic_width
    for j = col_count - 1, 0, -1 do
      local pic_name = list_pic[row_count * i + col_count - j]
      if pic_name ~= "-1_-1" then
        local pic = pic_path .. pic_name .. ".dds"
        local cur_col = image_x - (col_count - 1 - j) * pic_width
        texture_tool:AddCopyTexture(pic, cur_row, cur_col, pic_width, pic_width)
      end
    end
  end
  local res = texture_tool:GenTexture("RandomTerrainBigMap", width, height)
  form.pic_map.Image = "RandomTerrainBigMap"
  texture_tool:ReleaseGenTexture()
  return res
end
function SceneCoordToImageCoord(fImageWidth, fImageHeight, fSceneX, fSceneZ, fSceneStartX, fSceneStartZ, fSceneWidth, fSceneHeight)
  local fImageX = (1 - (fSceneX - fSceneStartX) / fSceneWidth) * fImageWidth
  local fImageZ = (fSceneZ - fSceneStartZ) / fSceneHeight * fImageHeight
  return fImageX, fImageZ
end
function request_sca_npc_pos(form)
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return
  end
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  if interactmgr:GetInteractStatus(ITT_SCHOOL_COUNTER_ATTACK) ~= PIS_IN_GAME then
    return
  end
  nx_execute("custom_sender", "custom_school_counter_attack_data", CLIENT_MSG_DS_REQUEST_MAP_MARK)
end
function refresh_sca_npc_pos(...)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return
  end
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  if map_query:GetCurrentScene() ~= form.current_map then
    return
  end
  if interactmgr:GetInteractStatus(ITT_SCHOOL_COUNTER_ATTACK) ~= PIS_IN_GAME then
    return
  end
  local count = table.getn(arg)
  if count < 7 or count % 7 ~= 0 then
    return
  end
  local label_num = count / 7
  local index = 0
  local back_image = ""
  for i = 1, label_num do
    index = (i - 1) * 7 + 1
    if arg[index + 1] == 0 then
      if arg[index + 2] == 0 then
        back_image = PHOTO_BOSS_MARK
      end
    elseif arg[index + 1] == 1 and arg[index + 2] == 0 then
      back_image = PHOTO_HOSTAGE_MARK
    end
    if arg[index + 2] ~= 0 then
      form.map_query:DeleteMapMarkLabel(arg[index])
    else
      local label_name = "map_mark_lbl_" .. arg[index]
      local npc_label = form.groupbox_map:Find(label_name)
      if not nx_is_valid(npc_label) then
        form.map_query:AddMarkLabelToMap(arg[index], arg[index + 3], arg[index + 5], back_image)
      end
    end
  end
  form.map_query:UpdateMapMarkLabel()
end
function update_map_mark_info(form)
  if form.current_step ~= STEP_SCENE then
    return
  end
  form.map_query:UpdateMapMarkLabel()
end
function extinct_create_scene_npc(form)
  form.is_open = true
  groupmap_begin(form)
  local exact_zoom_width = form.map_ui_ini:ReadFloat("map", "ZoomWidth", 0.8)
  local exact_zoom_height = form.map_ui_ini:ReadFloat("map", "ZoomHeight", 0.8)
  set_map_zoom(form, exact_zoom_width, exact_zoom_height)
end
function is_extinct_scene(form)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return false
  end
  if form.current_map ~= form.map_query:GetCurrentScene() then
    return false
  end
  local scene_config = client_scene:QueryProp("ConfigID")
  for i, configid in pairs(table_extincted_scene_config) do
    if nx_string(configid) == nx_string(scene_config) then
      return true
    end
  end
  return false
end
function extinct_scene_hide(form)
  form.groupbox_label_set.Visible = false
  form.groupbox_new_jh_label_set.Visible = false
  form.groupbox_scene_list.Visible = false
  form.groupbox_task.Visible = false
  form.groupbox_1.Visible = false
  form.groupbox_scene_page.Visible = false
  form.cbtn_school_pk_arena.Checked = false
end
function clear_move_npc_icon(form)
  local childs = form.groupbox_map:GetChildControlList()
  for _, child in ipairs(childs) do
    if nx_find_custom(child, "moving_npc_uid") then
      local TaoShaManager = nx_value("TaoShaManager")
      if nx_is_valid(TaoShaManager) then
        TaoShaManager:UpdateTaoShaEventLabelAtMap(child.Name, "", nx_int(0), nx_int(0), nx_int(0), nx_int(0))
      end
      delete_map_label(child.moving_npc_uid, child.npc_icon_type)
    end
  end
end
function add_move_npc_icon(npc, npc_id, npc_icon_type, x, y, z, o, ...)
  local form = nx_value(MAP_FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local npc_uid = get_move_npc_icon_uid(npc, npc_icon_type)
  local label_name = "map_label_" .. npc_uid
  local npc_label = form.groupbox_map:Find(label_name)
  if not nx_is_valid(npc_label) then
    add_label_to_map(npc_uid, x, z)
    local label = form.groupbox_map:Find(label_name)
    if not nx_is_valid(label) then
      return
    end
    label.moving_npc_uid = npc_uid
    label.npc_id = npc_id
    label.npc_icon_type = nx_int(npc_icon_type)
    label.x = x
    label.y = y
    label.z = z
    label.o = o
    nx_bind_script(label, nx_current())
    nx_callback(label, "on_get_capture", "on_move_npc_icon_label_get_capture")
    nx_callback(label, "on_lost_capture", "on_move_npc_icon_label_lost_capture")
    update_move_npc_icon(form, label, unpack(arg))
    form.map_query:UpdateMapLabel()
    npc_label = label
  else
    npc_label.x = x
    npc_label.y = y
    npc_label.z = z
    npc_label.o = o
    add_label_to_map(npc_uid, x, z)
    update_move_npc_icon(form, npc_label, unpack(arg))
  end
  local TaoShaManager = nx_value("TaoShaManager")
  if nx_is_valid(TaoShaManager) then
    TaoShaManager:UpdateTaoShaEventLabelAtMap(label_name, npc_label.BackImage, nx_int(x), nx_int(y), nx_int(z), nx_int(1))
    TaoShaManager:RefreshTaoShaEventLabelAtMap()
  end
end
function del_move_npc_icon(npc, npc_icon_type)
  local form = nx_value(MAP_FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  delete_map_label(get_move_npc_icon_uid(npc, npc_icon_type))
  local TaoShaManager = nx_value("TaoShaManager")
  if nx_is_valid(TaoShaManager) then
    local npc_uid = get_move_npc_icon_uid(npc, npc_icon_type)
    local label_name = "map_label_" .. npc_uid
    TaoShaManager:UpdateTaoShaEventLabelAtMap(label_name, "", nx_int(0), nx_int(0), nx_int(0), nx_int(0))
  end
end
function update_move_npc_icon(form, npc_label, ...)
  local n = #arg
  if npc_label.npc_icon_type == MAP_NPC_ICON_GUILD_ESCORT_CAR then
    if n < 1 then
      return
    end
    npc_label.guild_name = nx_string(arg[1])
    npc_label.hp_scale = nx_int(arg[2])
    npc_label.BackImage = "gui\\special\\tvt\\yunbiao\\sign\\icon_target.png"
  elseif npc_label.npc_icon_type == MAP_NPC_ICON_LUANDOU_FLAG then
    if n < 1 then
      return
    end
    local war_type = nx_number(arg[2])
    if war_type == 1 then
      if nx_int(arg[1]) <= nx_int(1) then
        npc_label.BackImage = "gui\\commom_new\\special\\guild_lm\\point_on.png"
      elseif nx_int(arg[1]) == nx_int(2) then
        npc_label.BackImage = "gui\\commom_new\\special\\guild_lm\\point_off.png"
      end
    elseif nx_int(arg[1]) <= nx_int(1) then
      npc_label.BackImage = "gui\\special\\war_scuffle\\point_on.png"
    elseif nx_int(arg[1]) == nx_int(2) then
      npc_label.BackImage = "gui\\special\\war_scuffle\\point_off.png"
    end
  elseif npc_label.npc_icon_type == MAP_PLAYER_ICON_TAOSHA then
    if n < 1 then
      return
    end
    npc_label.PlayerName = nx_widestr(arg[1])
    npc_label.BackImage = "gui\\special\\WorldWar\\mapicon\\22.png"
  elseif npc_label.npc_icon_type == MAP_PLAYER_ICON_TAOSHA_ENCOUNTER then
    if n < 1 then
      return
    end
    npc_label.PlayerName = nx_widestr(arg[1])
    npc_label.BackImage = "gui\\special\\WorldWar\\lxcmapr\\lx_map_p02.png"
  elseif npc_label.npc_icon_type == MAP_PLAYER_ICON_APEX then
    if n < 1 then
      return
    end
    npc_label.PlayerName = nx_widestr(arg[1])
    npc_label.BackImage = "gui\\special\\newtaosha\\map_02.png"
  elseif npc_label.npc_icon_type == MAP_PLAYER_ICON_APEX_RELIFENPC then
    if n < 1 then
      return
    end
    npc_label.PlayerName = nx_widestr(arg[1])
    npc_label.BackImage = "gui\\special\\newtaosha\\map_01.png"
  elseif npc_label.npc_icon_type == MAP_PLAYER_ICON_APEX_BOX then
    if n < 1 then
      return
    end
    npc_label.PlayerName = nx_widestr(arg[1])
    npc_label.BackImage = "gui\\special\\newtaosha\\map_03.png"
  elseif npc_label.npc_icon_type == MAP_PLAYER_ICON_APEX_BOX_PREPARE then
    if n < 1 then
      return
    end
    npc_label.PlayerName = nx_widestr(arg[1])
    npc_label.BackImage = "apex_kongtou"
  elseif npc_label.npc_icon_type == MAP_NPC_ICON_SCHOOL_FIGHT_BOSS then
    npc_label.BackImage = "gui\\map\\npcicon\\zhangmen.png"
  elseif npc_label.npc_icon_type == MAP_PLAYER_ICON_FIN_GOD then
    if n < 1 then
      return
    end
    npc_label.PlayerName = nx_widestr(arg[1])
    npc_label.BackImage = "gui\\map\\npcicon\\fin_god.png"
  elseif npc_label.npc_icon_type == MAP_NPC_ICON_ROGUE_BOX then
    npc_label.BackImage = "gui\\map\\npcicon\\npctype482.png"
  end
end
function a(info)
  nx_msgbox(nx_string(info))
end
function get_move_npc_icon_uid(npc, npc_icon_type)
  local uid = nx_string(npc) .. "_" .. nx_string(npc_icon_type)
  return uid
end
function on_move_npc_icon_label_get_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(lbl.BackImage) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local text
  if lbl.npc_icon_type == MAP_NPC_ICON_GUILD_ESCORT_CAR then
    local car = lbl
    local car_name = gui.TextManager:GetText(car.npc_id)
    text = gui.TextManager:GetFormatText("<font color=\"#B9B29F\">[{@0:car_name}]</font><br><font color=\"#FFFFFF\">{@1:guild_name}</font><br><font color=\"#ED5F00\">({@2:x},{@3:y})</font>", car_name, car.guild_name, nx_int(car.x), nx_int(car.z), car.hp_scale)
  elseif lbl.npc_icon_type == MAP_NPC_ICON_LUANDOU_FLAG then
    text = util_text(lbl.npc_id)
  elseif lbl.npc_icon_type == MAP_PLAYER_ICON_TAOSHA then
    text = lbl.PlayerName
  elseif lbl.npc_icon_type == MAP_PLAYER_ICON_TAOSHA_ENCOUNTER then
    text = lbl.PlayerName
  elseif lbl.npc_icon_type == MAP_PLAYER_ICON_APEX then
    text = lbl.PlayerName
  elseif lbl.npc_icon_type == MAP_PLAYER_ICON_APEX_RELIFENPC then
    text = lbl.PlayerName
  elseif lbl.npc_icon_type == MAP_PLAYER_ICON_APEX_BOX then
    text = util_text(lbl.npc_id)
  elseif lbl.npc_icon_type == MAP_PLAYER_ICON_APEX_BOX_PREPARE then
    text = util_text(lbl.npc_id)
  elseif lbl.npc_icon_type == MAP_NPC_ICON_SCHOOL_FIGHT_BOSS then
    text = util_format_string("ui_newschoolwar_guj_033", lbl.x, lbl.z)
  elseif lbl.npc_icon_type == MAP_PLAYER_ICON_FIN_GOD then
    text = lbl.PlayerName
  elseif lbl.npc_icon_type == MAP_NPC_ICON_ROGUE_BOX then
    text = util_text(lbl.npc_id)
  end
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y, 0, form)
end
function on_move_npc_icon_label_lost_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function hide_map_btn()
  local home_uid = get_current_homeid()
  if nx_widestr(home_uid) == nx_widestr("") then
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid then
    return
  end
  form.groupbox_switch_rbtn.Visible = false
end
function open_form_and_switch_scene(scene, x, z)
  local form = nx_value(MAP_FORM_NAME)
  if not nx_is_valid(form) then
    form = util_auto_show_hide_form(MAP_FORM_NAME)
  end
  if form.Visible == false then
    form.Visible = true
    form:Show()
  end
  turn_to_scene_map(form, scene)
  set_trace_npc_id(nil, x, -10000, z, scene, false)
  form.tbar_zoom.Value = form.tbar_zoom.Maximum
end
function set_jyf_info(info)
  local form = nx_value(MAP_FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.cur_jyf_info = nx_string(info)
  add_jyf_icon(form)
end
function parse_jyf_info(form)
  if not nx_find_custom(form, "cur_jyf_info") then
    return nil, nil
  end
  local info = form.cur_jyf_info
  local infos = util_split_string(info, ",")
  if table.getn(infos) < 2 then
    return nil, nil
  end
  return nx_int(infos[1]), nx_int(infos[2])
end
function get_jyf_icon_pos(jyf_chapter)
  local INI_FILE = "share\\War\\JiuYangFaculty\\jiuyang_faculty_form.ini"
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(INI_FILE) then
    IniManager:LoadIniToManager(INI_FILE)
  end
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return nil, nil
  end
  local sec_index = ini:FindSectionIndex(nx_string("map_pos"))
  if sec_index < 0 then
    return nil, nil
  end
  local var = ini:ReadString(sec_index, nx_string(jyf_chapter), "")
  if nx_string(var) == nx_string("") then
    return nil, nil
  end
  local vars = util_split_string(var, ",")
  if table.getn(vars) < 2 then
    return nil, nil
  end
  local x = nx_float(vars[1])
  local z = nx_float(vars[2])
  return x, z
end
function add_jyf_icon(form)
  if not nx_is_valid(form) then
    return
  end
  local jyf_scene_id, jyf_chapter = parse_jyf_info(form)
  if jyf_scene_id == nil or jyf_chapter == nil then
    return
  end
  local x, z = get_jyf_icon_pos(jyf_chapter)
  if x == nil or z == nil then
    return
  end
  local scene_id = get_scene_id(form.current_map)
  if nx_int(scene_id) ~= nx_int(jyf_scene_id) then
    return
  end
  local name = "jyf_icon"
  local label_name = "map_label_" .. name
  local label = form.groupbox_map:Find(label_name)
  if not nx_is_valid(label) then
    add_label_to_map(name, x, z)
    local label = form.groupbox_map:Find(label_name)
    if not nx_is_valid(label) then
      return
    end
    label.HintText = nx_widestr(util_text("sys_jiuyang_009"))
    label.DrawMode = "FitWindow"
    label.BackImage = "gui\\special\\agree_war\\Ebtn_1_4.png"
  else
    add_label_to_map(name, x, z)
  end
end
function del_jyf_icon()
  delete_map_label("jyf_icon")
end
