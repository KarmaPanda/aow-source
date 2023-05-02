require("util_functions")
require("util_gui")
require("role_composite")
require("create_scene")
require("form_stage_create\\create_logic")
require("form_stage_create\\create_control")
local openbook_table = {
  book1 = {
    0,
    false,
    "rbtn_1"
  },
  book2 = {
    0,
    false,
    "rbtn_4"
  },
  book4 = {
    0,
    false,
    "rbtn_3"
  },
  book5 = {
    0,
    false,
    "rbtn_2"
  }
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local function get_property(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local prop_list = nx_property_list(ent)
  log("property_list bagin")
  for _, prop in ipairs(prop_list) do
    log("prop = " .. prop)
  end
  log("property_list end")
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
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  local world = nx_value("world")
  world:CollectResource()
  form.rbtn_1.book_vis = false
  form.rbtn_2.book_vis = false
  form.rbtn_3.book_vis = false
  form.rbtn_4.book_vis = false
  form.rbtn_5.book_vis = false
  form.mltbox_tips_1.Visible = false
  form.mltbox_tips_2.Visible = false
  set_btn_visible(form, false)
  local form_select_book = nx_create("form_select_book")
  form_select_book:LoadResource("ini\\form\\effect_model.ini")
  nx_set_value("form_select_book", form_select_book)
  nx_set_value("form_stage_create\\form_select_book", form)
  on_size_change(form)
  form.bookid = ""
  form.sexLimit = ""
  form.nameLimit = ""
  form.is_move = false
  form.select_npc = nx_null()
  form.btn_ok.Visible = false
  form.groupbox_ani.Visible = false
  form.btn_repeat_select.Visible = false
  form.btn_back.Visible = false
  form.last_checked_index = "0"
  form.npc_count = 0
  form.book_id = ""
  form.mltbox_2.step_height = 10
  form.lbl_bg.Width = form.Width
  form.lbl_bg.Height = form.Height
  form.lbl_bg.Visible = true
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("SceneBlendColor", form)
  form.lbl_bg.speed_time = 500
  form.lbl_bg.stop_time = form.stop_time
  form.lbl_bg.cur_blend = 255
  form.lbl_bg.BlendColor = "255,255,255,255"
  init_camera(form)
  asynor:AddExecute("SceneBlendColor", form, nx_float(0), form.lbl_bg, nx_current(), "call_back_blend_color_visible")
  local scene = nx_value("game_scene")
  form.effectmodel = nx_null()
  form.effectmodel = nx_execute("form_stage_create\\create_logic", "create_effect_model", scene)
  local sock = nx_value("game_sock")
  if nx_is_valid(sock) then
    sock.Sender:GetWorldInfo(0)
  end
  return 1
end
function on_main_form_close(form)
  local scene = nx_value("game_scene")
  if nx_is_valid(scene) then
    clear_create_scene_private(scene)
  end
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("SceneBlendColor", form)
  if nx_running(nx_current(), "call_back_blend_color_visible") then
    nx_kill(nx_current(), "call_back_blend_color_visible")
  end
  if nx_running(nx_current(), "exe_action_finished") then
    nx_kill(nx_current(), "exe_action_finished")
  end
  if nx_running(nx_current(), "camera_move_end") then
    nx_kill(nx_current(), "camera_move_end")
  end
  if nx_running(nx_current(), "add_role_for_test") then
    nx_kill(nx_current(), "add_role_for_test")
  end
  if nx_running(nx_current(), "add_npc_for_test") then
    nx_kill(nx_current(), "add_npc_for_test")
  end
  nx_set_value("form_stage_create\\form_select_book", nil)
  local count = nx_number(form.npc_count)
  for i = 1, count do
    if nx_find_custom(form, "npc_" .. nx_string(i)) then
      local visual_player = nx_custom(form, "npc_" .. nx_string(i))
      if nx_is_valid(visual_player) then
        scene:Delete(visual_player)
      end
    end
  end
  local effectmodel = form.effectmodel
  if nx_is_valid(effectmodel) then
    scene:Delete(effectmodel)
  end
  local form_select_book = nx_value("form_select_book")
  nx_destroy(form_select_book)
  return 1
end
function enter_game()
  local form = nx_value(nx_current())
  if nx_is_valid(form) and nx_execute("util_gui", "util_is_form_visible", nx_current()) then
    enter_create_form(form)
  end
end
function on_btn_back_click(btn)
  local sock = nx_value("game_sock")
  if nx_is_valid(sock) then
    sock:Disconnect()
  end
  local AOWSteamClient = nx_value("AOWSteamClient")
  if nx_is_valid(AOWSteamClient) then
    return
  end
  nx_execute("stage", "set_current_stage", "login")
  return 1
end
function on_btn_ok_click(self)
  if has_selected_npc() then
    local form = self.ParentForm
    form.bookid = "book1"
    enter_create_form(form)
  end
  return 1
end
function set_selected_npc(npc_obj)
  local form = nx_value("form_stage_create\\form_select_book")
  if not nx_is_valid(form) then
    return
  end
  form.npc_obj = npc_obj
  form.btn_ok.Visible = true
end
function has_selected_npc()
  local form = nx_value("form_stage_create\\form_select_book")
  if not nx_is_valid(form) then
    return false
  end
  if not nx_find_custom(form, "select_npc") then
    return false
  end
  if not nx_is_valid(form.select_npc) then
    return false
  end
  return true
end
function return_to_login_form()
  local form = nx_value("form_stage_create\\form_select_book")
  if nx_is_valid(form) then
    form:Close()
  end
  local sock = nx_value("game_sock")
  if nx_is_valid(sock) then
    sock:Disconnect()
  end
  local AOWSteamClient = nx_value("AOWSteamClient")
  if nx_is_valid(AOWSteamClient) then
    return
  end
  nx_execute("stage", "set_current_stage", "login")
end
function init_camera_pos_angle()
  local form = nx_value("form_stage_create\\form_select_book")
  if nx_is_valid(form) then
    form.btn_ok.Visible = false
    form.npc_obj = nx_null()
  end
  local main_scene = nx_value("game_scene")
  if nx_is_valid(main_scene) then
    apply_camera(main_scene)
  end
end
function on_btn_return_click(self)
  local form = self.ParentForm
  if has_selected_npc() then
    init_camera_pos_angle()
  else
    return_to_login_form()
  end
end
function on_size_change(form)
  local gui = nx_value("gui")
  form.Width = gui.Width
  form.Height = gui.Height
  form.lbl_1.Width = form.Width + 20
  form.lbl_2.Width = form.Width
  return 1
end
function enter_create_form(form)
  local gui = nx_value("gui")
  local scene = nx_value("game_scene")
  local login_control = scene.login_control
  local select_npc = form.select_npc
  local book_id = select_npc.book_id
  form.book_id = book_id
  local sexLimit = form.sexLimit
  local nameLimit = form.nameLimit
  recover_play_dof_info(form)
  gui.Desktop:Close()
  gui.Desktop:DeleteAll()
  nx_bind_script(gui.Desktop, "")
  local world = nx_value("world")
  world:CollectResource()
  nx_execute("create_scene", "clear_game_control", scene)
  nx_execute("form_stage_create\\form_create", "init_camera")
  gui.Loader:LoadDesktop(nx_resource_path(), gui.skin_path .. "form_stage_create\\form_create.xml")
  gui.Desktop.bookid = book_id
  gui.Desktop.nameLimit = nameLimit
  gui.Desktop.Left = 0
  gui.Desktop.Top = 0
  gui.Desktop.Width = gui.Width
  gui.Desktop.Height = gui.Height
  gui.Desktop.Transparent = true
  gui.Desktop:ShowModal()
  nx_set_value("form_stage_create\\form_create", gui.Desktop)
  if nx_is_valid(login_control) and login_control ~= nil then
    login_control.Target = nx_null()
    scene.login_control = nx_null()
  end
  return 1
end
function get_pi(degree)
  return math.pi * degree / 180
end
function add_npc_for_test(form, res_name, px, py, pz, ax, ay, az, sz, sy, sz, action_name)
  local main_scene = nx_value("game_scene")
  local terrain = main_scene.terrain
  local visual_player = create_scene_npc(terrain, res_name)
  if not nx_is_valid(visual_player) then
    return
  end
  while nx_is_valid(visual_player) and not visual_player.LoadFinish do
    nx_log("not visual_player.LoadFinish")
    nx_pause(0)
  end
  add_role_in_scene(main_scene, visual_player, px, py, pz, ax, ay, az, sz, sy, sz)
  local action = nx_value("action_module")
  if not nx_is_valid(visual_player) then
    return
  end
  if not nx_is_valid(action) then
    return
  end
  action:ActionInit(visual_player)
  action:ClearAction(visual_player)
  action:ClearState(visual_player)
  action:BlendAction(visual_player, action_name, true, true)
  form.visual_player = visual_player
  return visual_player
end
function add_role_for_test(form, px, py, pz, ax, ay, az)
  if not nx_is_valid(form) then
    return
  end
  local main_scene = nx_value("game_scene")
  local visual_player = create_role_composite(main_scene, true, 0)
  if not nx_is_valid(visual_player) then
    return nx_null()
  end
  while nx_call("role_composite", "is_loading", 2, visual_player) do
    nx_pause(0)
  end
  local skin_info = {
    [1] = {
      link_name = "hat",
      model_name = "obj\\char\\b_hair\\b_hair1"
    },
    [2] = {
      link_name = "cloth",
      model_name = "obj\\char\\b_jianghu001\\b_cloth001"
    },
    [3] = {
      link_name = "pants",
      model_name = "obj\\char\\b_jianghu001\\b_pants001"
    },
    [4] = {
      link_name = "shoes",
      model_name = "obj\\char\\b_jianghu001\\b_shoes001"
    }
  }
  for i, info in pairs(skin_info) do
    if info.model_name ~= nil then
      link_skin(visual_player, info.link_name, info.model_name .. ".xmod")
    end
  end
  while nx_is_valid(visual_player) and not visual_player.LoadFinish do
    nx_log("not visual_player.LoadFinish")
    nx_pause(0)
  end
  if not nx_is_valid(visual_player) then
    return
  end
  add_role_in_scene(main_scene, visual_player, px, py, pz, ax, ay, az)
  return visual_player
end
function on_btn_repeat_select_click(btn)
  local form = btn.ParentForm
  local visual_npc = form.select_npc
  form.select_npc = nx_null()
  if nx_is_valid(visual_npc) then
    visual_npc.is_click = false
  end
  local ini = get_ini("ini\\form\\book_camera.ini", true)
  local scene = nx_value("game_scene")
  local game_control = nx_execute("create_scene", "create_game_control", scene)
  local story_camera = game_control:GetCameraController(2)
  story_camera:ClearRoute()
  form.groupbox_ani.Visible = false
  form.btn_repeat_select.Visible = false
  form.btn_ok.Visible = false
  if not ini:FindSection("origin") then
    return
  end
  local index = ini:FindSectionIndex("origin")
  local pos_value = ini:ReadString(index, "pos", "0,0,0")
  local ang_value = ini:ReadString(index, "ang", "0,0,0")
  local pos_list = util_split_string(pos_value, ",")
  local ang_list = util_split_string(ang_value, ",")
  story_camera:SetCameraDirect(nx_float(pos_list[1]), nx_float(pos_list[2]), nx_float(pos_list[3]), nx_float(ang_list[1]), nx_float(ang_list[2]), nx_float(ang_list[3]))
  form.rbtn_6.Checked = true
  form.last_checked_index = "0"
  recover_play_dof_info(form)
end
function on_fipt_drag(fipt)
  local form = fipt.ParentForm
  local main_scene = nx_value("game_scene")
  local game_control = nx_execute("create_scene", "create_game_control", main_scene)
  local story_camera = game_control:GetCameraController(2)
  story_camera:ClearRoute()
  local pos_x = nx_float(form.fipt_1.Text)
  local pos_y = nx_float(form.fipt_2.Text)
  local pos_z = nx_float(form.fipt_3.Text)
  local ang_x = nx_float(form.fipt_4.Text)
  local ang_y = nx_float(form.fipt_5.Text)
  local ang_z = nx_float(form.fipt_6.Text)
  local camera = nx_value("control_camera")
  if nx_is_valid(camera) then
    camera:SetPosition(pos_x, pos_y, pos_z)
    camera:SetAngle(ang_x, ang_y, ang_z)
  else
    story_camera:SetCameraDirect(pos_x, pos_y, pos_z, ang_x, ang_y, ang_z)
  end
end
function on_btn_2_click(btn)
  local form = btn.ParentForm
  local main_scene = nx_value("game_scene")
  local game_control = nx_execute("create_scene", "create_game_control", main_scene)
  local camera = nx_value("control_camera")
  if not nx_is_valid(camera) then
    camera = game_control.Camera
  end
  form.fipt_1.Text = nx_widestr(camera.PositionX)
  form.fipt_2.Text = nx_widestr(camera.PositionY)
  form.fipt_3.Text = nx_widestr(camera.PositionZ)
  form.fipt_4.Text = nx_widestr(camera.AngleX)
  form.fipt_5.Text = nx_widestr(camera.AngleY)
  form.fipt_6.Text = nx_widestr(camera.AngleZ)
end
function on_groupbox_edit_get_capture(grid)
  on_btn_2_click(grid)
end
function call_back_blend_color_visible(form)
  local ini = get_ini("ini\\create\\book_npc.ini", true)
  if not nx_is_valid(form) or not nx_is_valid(ini) then
    return
  end
  local count = ini:GetSectionCount()
  local sect_list = ini:GetSectionList()
  for i, sect in ipairs(sect_list) do
    local pos_value = ini:ReadString(i - 1, "pos", "0,0,0")
    local pos_list = util_split_string(pos_value, ",")
    local ang_value = ini:ReadString(i - 1, "ang", "0,0,0")
    local ang_list = util_split_string(ang_value, ",")
    local track = ini:ReadString(i - 1, "track", "0,0,0")
    local config = ini:ReadString(i - 1, "config", "")
    local book_id = ini:ReadString(i - 1, "book", "")
    local action_name = ini:ReadString(i - 1, "action", "")
    local call_action = ini:ReadString(i - 1, "call_action", "")
    if nil ~= openbook_table[book_id] then
      local rbtn = nx_custom(form, openbook_table[book_id][3])
      if nx_is_valid(rbtn) and rbtn.book_vis then
        local visual_player = add_npc_for_test(form, config, nx_number(pos_list[1]), nx_number(pos_list[2]), nx_number(pos_list[3]), nx_number(ang_list[1]), nx_number(ang_list[2]), nx_number(ang_list[3]), 1, 1, 1, action_name)
        if nx_is_valid(visual_player) then
          nx_set_custom(visual_player, "track", track)
          visual_player.is_click = false
          visual_player.book_id = book_id
          visual_player.enabled = rbtn.Enabled
          visual_player.action = action_name
          visual_player.call_action = call_action
          nx_set_custom(form, nx_string("npc_" .. nx_string(i)), visual_player)
        end
      end
    end
  end
  if not nx_is_valid(form) then
    return
  end
  nx_set_custom(form, "npc_count", nx_number(count))
  nx_execute("form_stage_create\\create_logic", "set_camera_move", form, "main")
  local form_select_book = nx_value("form_select_book")
  if not nx_is_valid(form_select_book) then
    return
  end
  nx_execute("form_stage_create\\create_logic", "start_play_open_door", form_select_book.DoorModel)
end
function init_camera()
  local scene = nx_value("game_scene")
  local game_control = nx_execute("create_scene", "create_game_control", scene)
  game_control.Player = scene.camera
  game_control.Camera = scene.camera
  game_control.CameraMode = 2
  local story_camera = game_control:GetCameraController(2)
  local ini = get_ini("ini\\form\\book_camera.ini", true)
  story_camera:ClearRoute()
  local time_count = 0
  local move_type = "main"
  if ini:FindSection(move_type) then
    local index = ini:FindSectionIndex(move_type)
    local item_value_list = ini:GetItemValueList(index, "r")
    local value_list = util_split_string(item_value_list[1], ",")
    time_count = time_count + nx_float(value_list[19])
    story_camera:AddMoveRoute(nx_float(value_list[1]), nx_float(value_list[2]), nx_float(value_list[3]), nx_float(value_list[4]), nx_float(value_list[5]), nx_float(value_list[6]), nx_float(value_list[1]), nx_float(value_list[2]), nx_float(value_list[3]), nx_float(value_list[4]), nx_float(value_list[5]), nx_float(value_list[6]), nx_float(value_list[1]), nx_float(value_list[2]), nx_float(value_list[3]), nx_float(value_list[1]), nx_float(value_list[2]), nx_float(value_list[3]), nx_float(1))
  end
  story_camera.StartRouteMove = true
  local camera = game_control.Camera
  camera.Fov = 0.09722222222222222 * math.pi * 2
  camera.fov_angle = 35
end
function on_btn_book_select_click(btn)
  local form = btn.ParentForm
  local data_source = btn.DataSource
  local npc_count = nx_number(form.npc_count)
  if btn.Checked then
    local last_checked_index = form.last_checked_index
    local index_list = util_split_string(nx_string(btn.Name), "_")
    form.last_checked_index = index_list[2]
    local track = last_checked_index .. "-" .. index_list[2]
    if "" == data_source or 0 == npc_count then
      return
    end
    for i = 1, npc_count do
      if nx_find_custom(form, "npc_" .. nx_string(i)) then
        local visual_player = nx_custom(form, "npc_" .. nx_string(i))
        if nx_is_valid(visual_player) and visual_player.book_id == data_source then
          nx_execute("form_stage_create\\create_control", "track_select_npc", visual_player, form, track)
          form.groupbox_ani.Visible = false
          form.btn_repeat_select.Visible = false
          form.btn_ok.Visible = false
          return
        end
      end
    end
  else
  end
end
function on_server_world_info(info_type, info)
  local info_list = util_split_string(nx_string(info), ",")
  local size = nx_int(table.getn(info_list) / 2) - 1
  local form = nx_value("form_stage_create\\form_select_book")
  local max_player_book = 0
  local min_player_book = 9999999
  local min_player_rbtn_name = ""
  for i = 1, size do
    local book = info_list[(i - 1) * 2 + 2]
    local num = nx_number(info_list[(i - 1) * 2 + 3])
    if nil ~= openbook_table[book] then
      openbook_table[book][1] = num
      if min_player_book >= num then
        min_player_book = num
        min_player_rbtn_name = openbook_table[book][3]
      end
      if max_player_book <= num then
        max_player_book = num
      end
      openbook_table[book][2] = true
    end
  end
  if not nx_is_valid(form) then
    return
  end
  for i, openbook in pairs(openbook_table) do
    local rbtn = nx_custom(form, openbook[3])
    if nx_is_valid(rbtn) then
      nx_set_custom(rbtn, "book_vis", openbook[2])
      nx_set_custom(rbtn, "num", openbook[1])
      nx_set_custom(rbtn, "is_recommend", false)
    end
  end
  local top = 10
  local count = 0
  for i, openbook in pairs(openbook_table) do
    local rbtn = nx_custom(form, openbook[3])
    if nx_is_valid(rbtn) and rbtn.Visible then
      rbtn.Top = count * 60 + top
      count = count + 1
    end
  end
  local ini_manager = nx_value("IniManager")
  local file_name = "ini\\ui\\book_player_limit.ini"
  local ini = ini_manager:LoadIniToManager("ini\\ui\\book_player_limit.ini")
  local section_count = ini:GetSectionCount()
  local min_player = 0
  local max_player = 0
  for i = 1, section_count do
    local max_num = nx_number(ini:ReadInteger(i - 1, "max", 99999999))
    local min_num = nx_number(ini:ReadInteger(i - 1, "min", 0))
    if min_player_book >= min_num and min_player_book < max_num then
      min_player = min_num
      max_player = max_num
    end
  end
  ini_manager:UnloadIniFromManager(file_name)
  local child_control_list = form.groupbox_1:GetChildControlList()
  local enabled_count = 0
  for i, rbtn in ipairs(child_control_list) do
    if nx_find_custom(rbtn, "num") and nx_name(rbtn) ~= "rbtn_5" and nx_int(rbtn.num) >= nx_int(max_player) then
      rbtn.Enabled = false
      enabled_count = enabled_count + 1
    end
  end
  if enabled_count == table.getn(child_control_list) - 1 then
    for i, rbtn in ipairs(child_control_list) do
      rbtn.Enabled = true
    end
  end
  local min_player_rbtn = nx_custom(form, min_player_rbtn_name)
  if nx_is_valid(min_player_rbtn) then
    form.lbl_recommend.AbsLeft = min_player_rbtn.AbsLeft + min_player_rbtn.Width
    form.lbl_recommend.AbsTop = min_player_rbtn.AbsTop + 10
    min_player_rbtn.is_recommend = true
  end
end
function on_rbtn_get_capture(rbtn)
  local form = rbtn.ParentForm
  local gui = nx_value("gui")
  if rbtn.Enabled then
    if rbtn.is_recommend then
      local title = gui.TextManager:GetText("ui_juqing_tips1")
      form.mltbox_tips_1:Clear()
      form.mltbox_tips_1:AddHtmlText(title, -1)
      form.mltbox_tips_1.Visible = true
      form.mltbox_tips_1.AbsLeft = rbtn.AbsLeft + rbtn.Width
      form.mltbox_tips_1.AbsTop = rbtn.AbsTop
    end
  else
    local title = gui.TextManager:GetText("ui_juqing_tips2")
    form.mltbox_tips_1:Clear()
    form.mltbox_tips_1:AddHtmlText(title, -1)
    form.mltbox_tips_1.Visible = true
    form.mltbox_tips_1.AbsLeft = rbtn.AbsLeft + rbtn.Width + 50
    form.mltbox_tips_1.AbsTop = rbtn.AbsTop
  end
end
function on_rbtn_lost_capture(rbtn)
  local form = rbtn.ParentForm
  form.mltbox_tips_1:Clear()
  form.mltbox_tips_1.Visible = false
end
function set_mltbox_tips(rbtn)
  local form = rbtn.ParentForm
  local gui = nx_value("gui")
  local title = gui.TextManager:GetText("ui_juqing_tips2")
  form.mltbox_tips_2:Clear()
  form.mltbox_tips_2:AddHtmlText(title, -1)
  form.mltbox_tips_2.Visible = true
  form.mltbox_tips_2.AbsLeft = (gui.Width - form.mltbox_tips_2.Width) / 2
  form.mltbox_tips_2.AbsTop = (gui.Height - form.mltbox_tips_2.Height) / 2
  local timer = nx_value(GAME_TIMER)
  timer:Register(2000, 1, nx_current(), "hide_tip", form, -1, -1)
end
function hide_tip(form)
  if nx_is_valid(form) then
    form.mltbox_tips_2:Clear()
    form.mltbox_tips_2.Visible = false
  end
end
function action_finished(form, actor2, action_name)
  if nx_running(nx_current(), "exe_action_finished") then
    nx_kill(nx_current(), "exe_action_finished")
  end
  nx_execute(nx_current(), "exe_action_finished", form, actor2, action_name)
end
function exe_action_finished(form, actor2, action_name)
  local action = nx_value("action_module")
  if not (nx_is_valid(action) and nx_is_valid(actor2)) or not nx_is_valid(form) then
    return
  end
  local time_count = 0
  while nx_is_valid(action) and not action:ActionFinished(actor2, action_name) do
    time_count = time_count + nx_pause(0)
  end
  if not (nx_is_valid(action) and nx_is_valid(actor2)) or not nx_is_valid(form) then
    return
  end
  action:BlendAction(actor2, actor2.action, true, true)
end
function set_play_dof_info(form, visual_player)
  local game_config = nx_value("game_config")
  local game_scene = nx_value("game_scene")
  local ppdof_uiparam = game_scene.ppdof_uiparam
  if not nx_is_valid(ppdof_uiparam) then
    return
  end
  form.old_focusdepth = ppdof_uiparam.focusdepth
  form.old_blurvalue = ppdof_uiparam.blurvalue
  form.old_maxofblur = ppdof_uiparam.maxofblur
  form.old_dof_enable = ppdof_uiparam.enable
  ppdof_uiparam.focusdepth = 17
  ppdof_uiparam.blurvalue = 1
  ppdof_uiparam.maxofblur = 3
  nx_execute("game_config", "set_dof_enable", game_scene, true)
  local ppdof = game_scene.ppdof
  if nx_is_valid(ppdof) then
    ppdof.FocusObject = visual_player
  end
end
function recover_play_dof_info(form)
  local game_scene = nx_value("game_scene")
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_scene) or not nx_is_valid(game_config) then
    return
  end
  local ppdof_uiparam = game_scene.ppdof_uiparam
  if not nx_is_valid(ppdof_uiparam) or not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "old_focusdepth") then
    ppdof_uiparam.focusdepth = form.old_focusdepth
  end
  if nx_find_custom(form, "old_blurvalue") then
    ppdof_uiparam.blurvalue = form.old_blurvalue
  end
  if nx_find_custom(form, "old_maxofblur") then
    ppdof_uiparam.maxofblur = form.old_maxofblur
  end
  if nx_find_custom(form, "old_dof_enable") then
    ppdof_uiparam.enable = form.old_dof_enable
  end
  nx_execute("game_config", "set_dof_enable", game_scene, ppdof_uiparam.enable)
end
