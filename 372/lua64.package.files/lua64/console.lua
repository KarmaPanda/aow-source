require("util_functions")
function console_init(self)
  self.Prompt = util_text("ui_WuXiaClient")
  nx_callback(self, "on_input_close", "console_input_close")
  nx_callback(self, "on_input_quit", "console_input_quit")
  nx_callback(self, "on_input_help", "console_input_help")
  nx_callback(self, "on_input_clear", "console_input_clear")
  nx_callback(self, "on_input_log", "console_input_log")
  nx_callback(self, "on_input_out", "console_input_out")
  nx_callback(self, "on_input_run", "console_input_run")
  nx_callback(self, "on_input_dump", "console_input_dump")
  nx_callback(self, "on_input_getp", "console_input_getp")
  nx_callback(self, "on_input_setp", "console_input_setp")
  nx_callback(self, "on_input_getc", "console_input_getc")
  nx_callback(self, "on_input_setc", "console_input_setc")
  nx_callback(self, "on_input_method", "console_input_method")
  nx_callback(self, "on_input_listp", "console_input_listp")
  nx_callback(self, "on_input_listc", "console_input_listc")
  nx_callback(self, "on_input_listm", "console_input_listm")
  nx_callback(self, "on_input_listg", "console_input_listg")
  nx_callback(self, "on_input_function", "console_input_function")
  nx_callback(self, "on_input_screenshot", "console_input_screenshot")
  nx_callback(self, "on_input_profmem", "console_input_profmem")
  nx_callback(self, "on_input_dumpmem", "console_input_dumpmem")
  nx_callback(self, "on_input_scriptperf", "console_input_logperf")
  nx_callback(self, "on_input_fileio", "console_input_logfileio")
  nx_callback(self, "on_input_netperf", "console_input_netfileperf")
  return 1
end
function console_input_close(self)
  nx_destroy(self)
  return 1
end
function console_input_quit(self)
  self:WriteOut(util_text("ui_ExitingApp"), "red")
  nx_quit()
  return 1
end
function console_input_help(self)
  self:Out(util_text("ui_CloseConsole"))
  self:Out(util_text("ui_ClearScreen"))
  self:Out(util_text("ui_ExitGame"))
  self:Out(util_text("ui_RunScript"))
  self:Out("scriptperf")
  self:Out("fileio")
  self:Out("dumpmem")
  self:Out("profmem")
  self:Out("screenshot")
  self:Out("netperf")
  return 1
end
function console_input_clear(self)
  self:Clear()
  return 1
end
function console_input_log(self, info)
  self:Log(info)
  return 1
end
function console_input_out(self, info)
  self:Out(info)
  return 1
end
function console_input_run(self, script, func, ...)
  if nx_execute(script, func, unpack(arg)) then
    self:Out(util_text("ui_RunScriptOk"))
  else
    self:Out(util_text("ui_RunScriptNo"))
  end
  return 1
end
function console_input_dump(self, type, file)
  if type == nil or file == nil then
    self:Out("dump <type> <file>")
    return 0
  end
  if nx_dump_file(type, file) then
    self:Out(util_text("ui_ExportAppInfoOk"))
  else
    self:Out(util_text("ui_ExportAppInfoNo"))
  end
  return 1
end
local index = 0
function dump_entity()
  nx_dump_file("entity", "dump_entity_" .. nx_string(index) .. ".txt")
  index = index + 1
  return 1
end
local m_index = 0
function dump_memory()
  nx_dump_file("memory", "dump_memory_" .. nx_string(m_index) .. ".txt")
  m_index = m_index + 1
  return 1
end
function lua_memory()
  local mem_use = collectgarbage("count")
  console_log("lua use memory : " .. nx_string(mem_use) .. " KBytes")
  return 1
end
local e_index = 0
function dump_effect()
  local world = nx_value("world")
  local game_effect = world.MainScene.game_effect
  if nx_is_valid(game_effect) then
    game_effect:Dump("dump_effect" .. nx_string(e_index) .. ".txt")
    console_log("dump_effect success")
  else
    console_log("dump_effect failed")
  end
  e_index = e_index + 1
  return 1
end
local s_index = 0
function dump_sceneobj()
  local scene_obj = nx_value("scene_obj")
  if nx_is_valid(scene_obj) then
    scene_obj:Dump("dump_sceneobj" .. nx_string(s_index) .. ".txt")
    console_log("dump_sceneobj success")
  else
    console_log("dump_sceneobj failed")
  end
  s_index = s_index + 1
  return 1
end
local composite_index = 0
function dump_role_composite()
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    role_composite:Dump("dump_role_composite" .. nx_string(composite_index) .. ".txt")
    console_log("dump_role_composite success")
  else
    console_log("dump_role_composite failed")
  end
  composite_index = composite_index + 1
  return 1
end
local ini_index = 0
function dump_ini()
  local ini_manager = nx_value("IniManager")
  if nx_is_valid(ini_manager) then
    ini_manager:Dump("dump_ini" .. nx_string(ini_index) .. ".txt")
    console_log("dump_ini success")
  else
    console_log("dump_ini failed")
  end
  ini_index = ini_index + 1
  return 1
end
local xml_index = 0
function dump_xml()
  local xml_manager = nx_value("XMLManager")
  if nx_is_valid(xml_manager) then
    xml_manager:DumpXml("dump_xml" .. nx_string(xml_index) .. ".txt")
    console_log("dump_xml success")
  else
    console_log("dump_xml failed")
  end
  xml_index = xml_index + 1
  return 1
end
function get_entity(entity_name)
  local id = nx_value(entity_name)
  if id ~= nil then
    return id
  end
  id = nx_lookup(entity_name)
  if not nx_is_null(id) then
    return id
  end
  id = nx_object(entity_name)
  if nx_is_valid(id) then
    return id
  end
  return nil
end
function get_new_value(old_v, value)
  local type = nx_type(old_v)
  if type == "boolean" then
    return nx_boolean(value)
  elseif type == "number" then
    return nx_number(value)
  elseif type == "string" then
    return nx_string(value)
  elseif type == "widestr" then
    return nx_widestr(value)
  elseif type == "int" then
    return nx_int(value)
  elseif type == "int64" then
    return nx_int64(value)
  elseif type == "float" then
    return nx_float(value)
  elseif type == "double" then
    return nx_double(value)
  elseif type == "object" then
    return nx_object(value)
  end
  return value
end
function console_input_getp(self, entity, prop)
  if entity == nil or prop == nil then
    return 0
  end
  local obj = get_entity(nx_string(entity))
  if obj == nil then
    return 0
  end
  local value = nx_property(obj, nx_string(prop))
  self:Out("entity " .. nx_name(obj) .. " property " .. nx_string(prop) .. " value is " .. nx_string(value))
  return 1
end
function console_input_setp(self, entity, prop, value)
  if entity == nil or prop == nil then
    return 0
  end
  local obj = get_entity(nx_string(entity))
  if obj == nil then
    return 0
  end
  local old_v = nx_property(obj, nx_string(prop))
  local new_v = get_new_value(old_v, value)
  if not nx_set_property(obj, nx_string(prop), new_v) then
    self:Out("set property failed")
    return 0
  end
  new_v = nx_property(obj, nx_string(prop))
  self:Out("set entity " .. nx_name(obj) .. " property " .. nx_string(prop) .. " value " .. nx_string(new_v))
  return 1
end
function console_input_getc(self, entity, prop)
  if entity == nil or prop == nil then
    return 0
  end
  local obj = get_entity(nx_string(entity))
  if obj == nil then
    return 0
  end
  local value = nx_custom(obj, nx_string(prop))
  self:Out("entity " .. nx_name(obj) .. " custom " .. nx_string(prop) .. " value is " .. nx_string(value))
  return 1
end
function console_input_setc(self, entity, prop, value)
  if entity == nil or prop == nil then
    return 0
  end
  local obj = get_entity(nx_string(entity))
  if obj == nil then
    return 0
  end
  local old_v = nx_custom(obj, nx_string(prop))
  local new_v = get_new_value(old_v, value)
  if not nx_set_custom(obj, nx_string(prop), new_v) then
    self:Out("set custom failed")
    return 0
  end
  new_v = nx_custom(obj, nx_string(prop))
  self:Out("set entity " .. nx_name(obj) .. " custom " .. nx_string(prop) .. " value " .. nx_string(new_v))
  return 1
end
function console_input_method(self, entity, method, ...)
  if entity == nil or method == nil then
    return 0
  end
  local obj = get_entity(nx_string(entity))
  if obj == nil then
    return 0
  end
  local res = nx_method(obj, nx_string(method), unpack(arg))
  if type(res) == "table" then
    self:Out("run entity " .. nx_name(obj) .. " method " .. nx_string(method) .. " return table")
    for i = 1, table.getn(res) do
      self:Out("table value " .. nx_string(i) .. ": " .. nx_string(res[i]))
    end
  else
    self:Out("run entity " .. nx_name(obj) .. " method " .. nx_string(method) .. " return " .. nx_string(res))
  end
  return 1
end
function console_input_listp(self, entity)
  if entity == nil then
    return 0
  end
  local obj = get_entity(nx_string(entity))
  if obj == nil then
    return 0
  end
  local prop_table = nx_property_list(obj)
  local num = table.getn(prop_table)
  self:Log("entity " .. nx_name(obj) .. " property number is " .. nx_string(num))
  self:Out("entity " .. nx_name(obj) .. " property number is " .. nx_string(num))
  for i = 1, num do
    self:Log(nx_string(prop_table[i]))
    self:Out(nx_string(prop_table[i]))
  end
  return 1
end
function console_input_listc(self, entity)
  if entity == nil then
    return 0
  end
  local obj = get_entity(nx_string(entity))
  if obj == nil then
    return 0
  end
  local prop_table = nx_custom_list(obj)
  local num = table.getn(prop_table)
  self:Log("entity " .. nx_name(obj) .. " custom number is " .. nx_string(num))
  self:Out("entity " .. nx_name(obj) .. " custom number is " .. nx_string(num))
  for i = 1, num do
    self:Log(nx_string(prop_table[i]))
    self:Out(nx_string(prop_table[i]))
  end
  return 1
end
function console_input_listm(self, entity)
  if entity == nil then
    return 0
  end
  local obj = get_entity(nx_string(entity))
  if obj == nil then
    return 0
  end
  local prop_table = nx_method_list(obj)
  local num = table.getn(prop_table)
  self:Log("entity " .. nx_name(obj) .. " method number is " .. nx_string(num))
  self:Out("entity " .. nx_name(obj) .. " method number is " .. nx_string(num))
  for i = 1, num do
    self:Log(nx_string(prop_table[i]))
    self:Out(nx_string(prop_table[i]))
  end
  return 1
end
function console_input_listg(self)
  local global_table = nx_value_list()
  local num = table.getn(global_table)
  self:Log("global number is " .. nx_string(num))
  self:Out("global number is " .. nx_string(num))
  for i = 1, num do
    local name = global_table[i]
    local value = nx_value(name)
    self:Log(nx_string(name) .. "[" .. nx_type(value) .. "]: " .. nx_string(value))
    self:Out(nx_string(name) .. "[" .. nx_type(value) .. "]: " .. nx_string(value))
  end
  return 1
end
function console_input_function(self, func, ...)
  if func == nil or func == "" then
    return 0
  end
  local res = nx_function(func, unpack(arg))
  if type(res) == "table" then
    self:Out("run function " .. nx_string(func) .. " return table")
    for i = 1, table.getn(res) do
      self:Out("result" .. nx_string(i) .. ": " .. nx_string(res[i]))
    end
  else
    self:Out("run function " .. nx_string(func) .. " return " .. nx_string(res))
  end
  return 1
end
function console_input_screenshot(self, name)
  if name == nil then
    return 0
  end
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return 0
  end
  if world:ScreenShot(name) then
    self:Out("screen shot succeed")
  else
    self:Out("screen shot failed")
  end
  return 1
end
function console_input_logperf(self, name)
  if name == nil then
    self:Out("cmd format: scriptperf on/off")
    return 0
  end
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return 0
  end
  if name == "on" then
    world:SetLogScript(true)
    self:Out("lua run perf ... on")
  elseif name == "off" then
    world:SetLogScript(false)
    self:Out("lua run perf ... off")
  end
  return 1
end
function console_input_netfileperf(self, name)
  if name == nil then
    self:Out("cmd format: netperf filename")
    return 0
  end
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    self:Out("Not Find game_sock!")
    return 0
  end
  sock.Receiver:DumpMsgStat(name)
  self:Out("netfileperf ok")
end
function console_input_logfileio(self, name)
  if name == nil then
    self:Out("cmd format: fileio on/off")
    return 0
  end
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return 0
  end
  if name == "on" then
    world:SetLogFileIO(true)
    self:Out("fileio log ... on")
  elseif name == "off" then
    world:SetLogFileIO(false)
    self:Out("fileio log ... off")
  end
  return 1
end
function console_input_profmem(self, src, dst)
  if src == nil or dst == nil then
    self:Out("profmem <src_file> <dst_file>")
  end
  if nx_function("ext_profile_memory", src, dst) then
    self:Out("profile memory succeed")
  else
    self:Out("profile memory failed")
  end
  return 1
end
function console_input_dumpmem(self)
  self:Out("dumping FxWorld heap...")
  nx_function("ext_dump_memory_fx_world")
  self:Out("dumping FxSound heap...")
  nx_function("ext_dump_memory_fx_sound")
  self:Out("dumping FxRender heap...")
  nx_function("ext_dump_memory_fx_render")
  self:Out("dumping FxModel heap...")
  nx_function("ext_dump_memory_fx_model")
  self:Out("dumping FxModelAdv heap...")
  nx_function("ext_dump_memory_fx_modeladv")
  self:Out("dumping FxTerrain heap...")
  nx_function("ext_dump_memory_fx_terrain")
  self:Out("dumping FxGui heap...")
  nx_function("ext_dump_memory_fx_gui")
  self:Out("dumping FxTool heap...")
  nx_function("ext_dump_memory_fx_tool")
  self:Out("dumping FxSpecial heap...")
  nx_function("ext_dump_memory_fx_special")
  self:Out("dumping FxNet2 heap...")
  nx_function("ext_dump_memory_fx_net2")
  self:Out("dumping FxGameLogic heap...")
  nx_function("ext_dump_memory_fx_gamelogic")
  self:Out("dumping FxCore heap...")
  nx_dump_file("heap", "memory.log")
  if nx_find_kind("PackageManager") then
    self:Out("dumping FxPackage heap...")
    nx_function("ext_dump_memory_fx_package")
  end
  self:Out("dump memory finished")
  return 1
end
function console_input_dumpmem2()
  nx_function("ext_dump_memory_fx_world")
  nx_function("ext_dump_memory_fx_sound")
  nx_function("ext_dump_memory_fx_render")
  nx_function("ext_dump_memory_fx_model")
  nx_function("ext_dump_memory_fx_modeladv")
  nx_function("ext_dump_memory_fx_terrain")
  nx_function("ext_dump_memory_fx_gui")
  nx_function("ext_dump_memory_fx_tool")
  nx_function("ext_dump_memory_fx_special")
  nx_function("ext_dump_memory_fx_net2")
  nx_function("ext_dump_memory_fx_gamelogic")
  nx_dump_file("heap", "memory.log")
  return 1
end
function show_player()
  local role = nx_value("role")
  if nx_is_valid(role) then
    role.Visible = true
  end
end
function change_0()
  change_target(0)
end
function change_1()
  change_target(1)
end
function change_2()
  change_target(2)
end
function change_3()
  change_target(3)
end
function camera_pause()
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return 0
  end
  game_control.Pause = true
  return 1
end
function camera_move()
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return 0
  end
  game_control.Pause = false
  return 1
end
function change_target(mode, point)
  local game_visual = nx_value("game_visual")
  local vis_player = game_visual:GetPlayer()
  local game_control = vis_player.scene.game_control
  if not nx_is_valid(game_control) then
    return 0
  end
  if mode < 0 or 4 <= mode then
    return 0
  end
  if mode == 0 then
    game_control.TargetMode = mode
  elseif mode == 1 then
    local target_model = nx_value("target_model")
    game_control.Target = target_model
    game_control.TargetMode = mode
  elseif mode == 2 then
    if point == nil then
      change_target(0)
    end
    game_control.TargetPoint = point
    game_control.TargetMode = mode
  elseif mode == 3 then
    if point == nil then
      change_target(1)
    end
    local target_model = nx_value("target_model")
    game_control.Target = target_model
    game_control.TargetPoint = point
    game_control.TargetMode = mode
  end
  return 1
end
function hide_player()
  local role = nx_value("role")
  if nx_is_valid(role) then
    role.Visible = false
  end
  return 1
end
function show_balloon_info()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local client_objlist = client_scene:GetSceneObjList()
  console_log("net objects count =" .. nx_string(table.maxn(client_objlist)))
  local game_visual = nx_value("game_visual")
  local visual_objlist = game_visual:GetSceneObjList()
  console_log("visual objects count =" .. nx_string(table.maxn(visual_objlist)))
  local ballset = nx_value("balls")
  if nx_is_valid(ballset) then
    local balloon_list = ballset:GetBalloonList()
    console_log("balloon count =" .. nx_string(table.maxn(balloon_list)))
  end
  return 1
end
function clear_all_form()
  local gui = nx_value("gui")
  nx_log("delete balloonset begin memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
  local ballset = nx_value("balls")
  if nx_is_valid(ballset) then
    local balloon_list = ballset:GetBalloonList()
    nx_log("balloon count =" .. nx_string(table.maxn(balloon_list)))
    gui:Delete(ballset)
  end
  nx_pause(0.1)
  nx_log("delete balloonset end memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
  local childlist = gui:GetAllFormList()
  if childlist == nil then
  else
    for i = 1, table.maxn(childlist) do
      local control = childlist[i]
      if nx_is_valid(control) and not nx_id_equal(control, gui.Desktop) then
        local script_name = nx_script_name(control)
        if script_name == "" then
          script_name = control.Name
        end
        nx_log("delete form begin : " .. script_name .. " memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
        control.Visible = true
        control:Close()
        if nx_is_valid(control) then
          gui:Delete(control)
        end
        nx_pause(0.1)
        nx_log("delete form end : " .. script_name .. " memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
      end
    end
  end
  nx_log("delete desktop begin memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
  gui.Desktop:Close()
  gui.Desktop:DeleteAll()
  gui.Desktop.BackImage = ""
  nx_bind_script(gui.Desktop, "")
  nx_pause(0.1)
  nx_log("delete desktop end memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
  return 1
end
function reload_main_form()
  local gui = nx_value("gui")
  local ballset = nx_value("balls")
  if nx_is_valid(ballset) then
    gui:Delete(ballset)
  end
  gui.Desktop:Close()
  gui.Desktop:DeleteAll()
  gui.Desktop.BackImage = ""
  nx_bind_script(gui.Desktop, "")
  nx_log("desktop reload begin memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
  nx_log("flow begin load form_main")
  local balls = nx_value("balls")
  if not nx_is_valid(balls) then
    balls = gui:Create("BalloonSet")
    balls.Scene = nx_value("world").MainScene
    balls.Sort = true
    nx_set_value("balls", balls)
    gui:AddBackControl(balls)
  end
  gui.Desktop:Close()
  gui.Loader:LoadDesktop(nx_resource_path(), gui.skin_path .. "form_stage_main\\form_main\\form_main.xml")
  gui.Desktop.Left = 0
  gui.Desktop.Top = 0
  gui.Desktop.Width = gui.Width
  gui.Desktop.Height = gui.Height
  gui.Desktop.Transparent = true
  gui.Desktop:ShowModal()
  nx_pause(0.1)
  nx_log("desktop reload end memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
  return 1
end
function clear_all_form_and_reload_main()
  clear_all_form()
  reload_main_form()
  return 1
end
function clear_all_entity_byname(entity_name)
  nx_log("delete " .. entity_name .. " begin memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
  local entity_list = nx_function("ext_clear_all_entitys_byname", entity_name)
  nx_pause(0.1)
  nx_log("delete " .. entity_name .. " end memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
  return 1
end
function clear_main_scene()
  local world = nx_value("world")
  local main_scene = world.MainScene
  if nx_is_valid(world.MainScene) then
    world.MainScene = nx_null()
  end
  clear_all_entity_byname("Scene")
  nx_log("clear_main_scene end memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
end
function clear_gui()
  local world = nx_value("world")
  local gui = world.MainGui
  if nx_is_valid(gui) then
    world.MainGui = nx_null()
  end
  clear_all_entity_byname("Gui")
  nx_log("clear_gui end memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
end
function dump_lua_memory()
  local mem_use = collectgarbage("count")
  nx_log("lua use memory = " .. nx_string(mem_use))
end
function clear_all_game_entity()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if nx_is_valid(client_scene) then
    local client_objlist = client_scene:GetSceneObjList()
    nx_log("net objects count =" .. nx_string(table.maxn(client_objlist)))
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(client_scene) then
    local visual_objlist = game_visual:GetSceneObjList()
    nx_log("visual objects count =" .. nx_string(table.maxn(visual_objlist)))
  end
  clear_all_entity_byname("Sound")
  clear_all_entity_byname("Music")
  clear_all_entity_byname("Particle")
  clear_all_entity_byname("EffectModel")
  clear_all_entity_byname("Actor2")
  clear_all_entity_byname("Terrain")
  clear_all_entity_byname("Model")
  if nx_is_valid(game_visual) then
    game_visual:DeleteAll()
  end
  clear_all_entity_byname("GameEffect")
  if nx_is_valid(game_client) then
    game_client:ClearAll()
  end
  nx_log("--------------------\191\170\202\188\201\190\179\253FxNet2\214\208\198\228\203\251\202\181\204\229")
  local fxnet2_table = {
    "GameWinSock",
    "GameReceiver",
    "GameSender"
  }
  for i = 1, table.maxn(fxnet2_table) do
    clear_all_entity_byname(fxnet2_table[i])
  end
  nx_log("--------------------\191\170\202\188\201\190\179\253INI")
  clear_all_entity_byname("IniDocument")
  clear_all_entity_byname("ItemsQuery")
  clear_all_entity_byname("IniManager")
  nx_log("--------------------\191\170\202\188\201\190\179\253Cache")
  nx_function("ext_clear_all_cache")
  nx_pause(0.1)
  nx_log("ext_clear_all_cache end memory=" .. nx_string(nx_function("ext_get_cur_memory_use")))
  clear_all_entity_byname("RoleComposite")
  nx_function("ext_helper_clear_all")
  nx_log("--------------------\191\170\202\188\201\190\179\253\189\231\195\230")
  clear_all_form()
  clear_gui()
  clear_all_entity_byname("Text")
  clear_all_entity_byname("Font")
  clear_all_entity_byname("Cursor")
  clear_all_entity_byname("SceneObj")
  clear_all_entity_byname("ParticleManager")
  clear_all_entity_byname("StaticDataQueryModule")
  clear_all_entity_byname("TaskManager")
  clear_all_entity_byname("SoundManager")
  clear_main_scene()
  nx_log("--------------------\191\170\202\188\201\190\179\253FxGameLogic\214\208\198\228\203\251\202\181\204\229")
  local fxgamelogic_table = {
    "StageManager",
    "FuncManager",
    "XMLManager",
    "IniManager",
    "SceneCreator",
    "ShortcutKey",
    "MapQuery",
    "SelectLogic",
    "Action",
    "SkillEffect",
    "CGlobalEffectMgr",
    "Fight",
    "QingGong",
    "SendMove",
    "TiGuanManager",
    "TiGuanBorderManager",
    "SkillDataManager",
    "LeiTaiRewardManager",
    "Timer",
    "CommonExecute",
    "CommonArray",
    "Trace",
    "PathFinding",
    "ConditionManager",
    "DailyLPManager",
    "GuildFireManager",
    "OriginManager",
    "UpgradeRuleManager",
    "OffLineJobManager",
    "SnsManager",
    "NpcSenceQuery",
    "SysInfoSort",
    "ClientNpcManager",
    "ScenarioNpcManager",
    "NpcHeadTalkManager",
    "TaskManager",
    "ReputeModule",
    "ConnectGame",
    "ForgeGame",
    "FindpicGame",
    "QinGame",
    "PictureGame",
    "HandwritingGame",
    "RockPaperScissorsGame",
    "JingmaiGame",
    "RideGame",
    "RopeSwingGame",
    "WeiqiGame",
    "FortuneTellingGame",
    "AugurGame",
    "JigsawGame",
    "PichaiGame",
    "SudokuGame",
    "RollGame",
    "MiniGameManage",
    "CheckWords",
    "PublicBord",
    "StaticDataQueryModule",
    "QueryUtil",
    "TaoLuQuery",
    "SkillQuery",
    "WuXueQuery",
    "JingMaiQuery",
    "EffectJingMai",
    "TipsManager",
    "HeadGame",
    "GuildbuildingManager",
    "GuildJiGuanManager",
    "GuildBuildingPreCreate",
    "GoodsGrid",
    "JewelGameManager",
    "FacultyQuery",
    "MessageDelay",
    "VipModule",
    "GuildDomainManager",
    "PlayerTrackModule",
    "GameJoyStick",
    "CapitalModule",
    "GameEffect",
    "RoleComposite",
    "RoadSignNpcManager",
    "TransToolNpcManager",
    "FallDownManager",
    "NpcPreLoad",
    "SceneObj",
    "BufferEffect",
    "ChessNpcManager",
    "PlayerBindMgr",
    "InteractManager",
    "UnenthrallModule",
    "GameControl",
    "GameMessageHandler",
    "SceneObjRecord",
    "SystemCenterInfo",
    "CameraNormalController",
    "CameraBindPosController",
    "CameraCodeController",
    "CameraOnlyYawController",
    "TrangleDraw",
    "DataBinder",
    "MovieSaverModule",
    "ExchangeItemManager",
    "SceneMusicPlay",
    "FollowManager",
    "GameSelectDecal",
    "GameControlWatch",
    "GameClient",
    "GameVisual"
  }
  for i = 1, table.maxn(fxgamelogic_table) do
    clear_all_entity_byname(fxgamelogic_table[i])
  end
  clear_all_entity_byname("ArrayList")
  nx_log("--------------------\191\170\202\188\201\190\179\253FxGui\214\208\198\228\203\251\202\181\204\229")
  local fxgui_table = {
    "Caret",
    "Form",
    "HyperLinkStyleManager",
    "ImageAnimationManager",
    "CoolManager",
    "GameHand",
    "Text",
    "SpriteManager",
    "ImageList",
    "Designer"
  }
  for i = 1, table.maxn(fxgui_table) do
    clear_all_entity_byname(fxgui_table[i])
  end
  nx_log("--------------------\191\170\202\188\201\190\179\253FxSpecial\214\208\198\228\203\251\202\181\204\229")
  local fxspecial_table = {
    "PostProcessMgr",
    "PPScreenRefraction",
    "PPFilter"
  }
  for i = 1, table.maxn(fxspecial_table) do
    clear_all_entity_byname(fxspecial_table[i])
  end
  nx_log("--------------------\191\170\202\188\201\190\179\253FxWorld\214\208\198\228\203\251\202\181\204\229")
  clear_main_scene()
  local fxworld_table = {
    "Scene",
    "Weather",
    "Camera",
    "LightManager",
    "ShadowManager",
    "SaberArcManager",
    "ParticleManager",
    "SunGlow"
  }
  for i = 1, table.maxn(fxworld_table) do
    clear_all_entity_byname(fxworld_table[i])
  end
  clear_all_entity_byname("World")
  nx_msgbox("clear_all_game_entity success")
end
function dump_entity_to_tracelog()
  nx_dump_file("entity", "entity.log")
  nx_function("ext_copy_file_to_file", "trace.log", "entity.log")
  return 1
end
