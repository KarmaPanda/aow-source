require("util_functions")
require("util_role_prop")
function terrain_init(self)
  nx_callback(self, "on_visual_load", "terrain_visual_load")
  self:SetTraceMask("Role", true)
  self:SetTraceMask("Particle", true)
  self:SetTraceMask("Light", true)
  self:SetTraceMask("Sound", true)
  local scene = self.scene
  nx_call("terrain\\role_param", "create_role_param", scene)
  return 1
end
function terrain_visual_load(self, visual)
  return 1
end
function create_screen(scene)
  local screen = nx_call("util_gui", "get_global_arraylist", nx_current())
  screen.alpha_ref = 128
  screen.far_clip = 500
  screen.grass_radius = 100
  screen.ground_envmap = 0
  screen.visual_envmap = 0
  screen.alpha_fade_radius = 100
  screen.alpha_hide_radius = 200
  screen.visual_radius_small = 1
  screen.visual_radius_big = 30
  screen.clip_radius_near = 100
  screen.clip_radius_far = 200
  screen.load_radius_add = 50
  screen.unload_radius_add = 50
  scene.screen = screen
  return true
end
function change_screen(scene)
  local world = nx_value("world")
  local screen = scene.screen
  world.RenderAlphaRef = screen.alpha_ref
  if nx_is_valid(scene) then
    scene.FarClipDistance = screen.far_clip
  end
  local terrain = scene.terrain
  if nx_is_valid(terrain) then
    terrain.GrassRadius = screen.grass_radius
    terrain.GroundEnvMap = screen.ground_envmap
    terrain.VisualEnvMap = 2
    terrain.AlphaFadeRadius = screen.alpha_fade_radius
    terrain.AlphaHideRadius = screen.alpha_hide_radius
    terrain.VisualRadiusSmall = screen.visual_radius_small
    terrain.VisualRadiusBig = screen.visual_radius_big
    terrain.ClipRadiusNear = screen.clip_radius_near
    terrain.ClipRadiusFar = screen.clip_radius_far
    terrain.LoadRadiusAdd = screen.load_radius_add
    terrain.UnloadRadiusAdd = screen.unload_radius_add
    terrain.LodRadius = screen.terrain_lod_radius
    terrain.NoLodRadius = screen.terrain_no_lod_radius
    terrain.FarLodCheckError = screen.terrain_far_lod_check_error
    terrain.GrassLodBegin = screen.grass_lod_begin
    terrain.FarLodLevel = screen.terrain_far_lod_level
    terrain:RefreshGrass()
    terrain:RefreshWater()
    terrain:RefreshVisual()
    terrain:RefreshGround()
  end
  return true
end
function load_screen_ini(scene, filename)
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local screen = scene.screen
  screen.alpha_ref = ini:ReadInteger("screen", "AlphaRef", 128)
  screen.far_clip = ini:ReadFloat("screen", "FarClip", 500)
  screen.grass_radius = ini:ReadFloat("screen", "GrassRadius", 50)
  screen.ground_envmap = ini:ReadInteger("screen", "GroundEnvMap", 0)
  screen.visual_envmap = ini:ReadInteger("screen", "VisualEnvMap", 0)
  screen.alpha_fade_radius = ini:ReadFloat("screen", "AlphaFadeRadius", 100)
  screen.alpha_hide_radius = ini:ReadFloat("screen", "AlphaHideRadius", 200)
  screen.visual_radius_small = ini:ReadFloat("screen", "VisualRadiusSmall", 1)
  screen.visual_radius_big = ini:ReadFloat("screen", "VisualRadiusBig", 50)
  screen.clip_radius_near = ini:ReadFloat("screen", "ClipRadiusNear", 100)
  if screen.clip_radius_near < 10 then
    screen.clip_radius_near = 10
  elseif screen.clip_radius_near > 300 then
    screen.clip_radius_near = 300
  end
  screen.clip_radius_far = ini:ReadFloat("screen", "ClipRadiusFar", 200)
  screen.load_radius_add = 10
  screen.unload_radius_add = 10
  screen.terrain_lod_radius = ini:ReadFloat("screen", "TerrainLodRadius", 300)
  screen.terrain_no_lod_radius = ini:ReadFloat("screen", "TerrainNoLodRadius", 50)
  screen.terrain_far_lod_check_error = ini:ReadString("screen", "TerrainFarLodCheckError", "false") == "true"
  screen.far_plane = ini:ReadFloat("screen", "FarPlane", 1200)
  screen.grass_lod_begin = ini:ReadFloat("screen", "GrassLodBegin", 50)
  screen.terrain_far_lod_level = ini:ReadInteger("screen", "TerrainFarLodLevel", -1)
  if screen.grass_radius > 100 then
    screen.grass_radius = 100
  end
  nx_destroy(ini)
  return true
end
function read_grass_data(ini, grass)
  local sect = grass.Name
  grass.Texture = "map\\" .. ini:ReadString(sect, "Texture", grass.Texture)
  grass.TexScale = ini:ReadInteger(sect, "TexScale", grass.TexScale)
  grass.FrameWidth = ini:ReadInteger(sect, "FrameWidth", grass.FrameWidth)
  grass.FrameHeight = ini:ReadInteger(sect, "FrameHeight", grass.FrameHeight)
  grass.MinWidth = ini:ReadFloat(sect, "MinWidth", grass.MinWidth)
  grass.MaxWidth = ini:ReadFloat(sect, "MaxWidth", grass.MaxWidth)
  grass.MinHeight = ini:ReadFloat(sect, "MinHeight", grass.MinHeight)
  grass.MaxHeight = ini:ReadFloat(sect, "MaxHeight", grass.MaxHeight)
  grass.MinPitch = ini:ReadFloat(sect, "MinPitch", grass.MinPitch)
  grass.MaxPitch = ini:ReadFloat(sect, "MaxPitch", grass.MaxPitch)
  return true
end
function load_grass_ini(scene, filename, is_create)
  ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local terrain = scene.terrain
  terrain:ClearGrass()
  local sect_table = ini:GetSectionList()
  for i = 1, table.getn(sect_table) do
    local grass_name = sect_table[i]
    local grass = nx_null()
    if is_create then
      grass = terrain:CreateGrass(grass_name)
    else
      grass = terrain:GetGrass(grass_name)
    end
    if nx_is_valid(grass) then
      read_grass_data(ini, grass)
    end
  end
  nx_destroy(ini)
  return true
end
function convert_color(color)
  local pos = string.find(color, ",")
  if pos ~= nil then
    return color
  end
  local num = nx_number(color)
  local alpha = math.floor(num / 16777216)
  num = num - alpha * 256 * 256 * 256
  local red = math.floor(num / 65536)
  num = num - red * 256 * 256
  local green = math.floor(num / 256)
  num = num - green * 256
  local blue = math.floor(num)
  return nx_string(alpha) .. "," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
end
function read_water_data(ini, water)
  local sect = water.Name
  water.BaseHeight = ini:ReadFloat(sect, "BaseHeight", 0)
  water.WaterColor = convert_color(ini:ReadString(sect, "WaterColor", water.WaterColor))
  water.SunColorStart = convert_color(ini:ReadString(sect, "SunColorStart", water.SunColorStart))
  water.SunColorEnd = convert_color(ini:ReadString(sect, "SunColorEnd", water.SunColorEnd))
  water.WaveGradient0 = ini:ReadFloat(sect, "WaveGradient0", water.WaveGradient0)
  water.WaveGradient1 = ini:ReadFloat(sect, "WaveGradient1", water.WaveGradient1)
  water.WaveGradient2 = ini:ReadFloat(sect, "WaveGradient2", water.WaveGradient2)
  water.WaveGradient3 = ini:ReadFloat(sect, "WaveGradient3", water.WaveGradient3)
  water.WaveGradient4 = ini:ReadFloat(sect, "WaveGradient4", water.WaveGradient4)
  water.WaveSwing0 = ini:ReadFloat(sect, "WaveSwing0", water.WaveSwing0)
  water.WaveSwing1 = ini:ReadFloat(sect, "WaveSwing1", water.WaveSwing1)
  water.WaveSwing2 = ini:ReadFloat(sect, "WaveSwing2", water.WaveSwing2)
  water.WaveSwing3 = ini:ReadFloat(sect, "WaveSwing3", water.WaveSwing3)
  water.WaveSwing4 = ini:ReadFloat(sect, "WaveSwing4", water.WaveSwing4)
  water.WaveAngleFreq0 = ini:ReadFloat(sect, "WaveAngleFreq0", water.WaveAngleFreq0)
  water.WaveAngleFreq1 = ini:ReadFloat(sect, "WaveAngleFreq1", water.WaveAngleFreq1)
  water.WaveAngleFreq2 = ini:ReadFloat(sect, "WaveAngleFreq2", water.WaveAngleFreq2)
  water.WaveAngleFreq3 = ini:ReadFloat(sect, "WaveAngleFreq3", water.WaveAngleFreq3)
  water.WaveAngleFreq4 = ini:ReadFloat(sect, "WaveAngleFreq4", water.WaveAngleFreq4)
  water.WavePhaX0 = ini:ReadFloat(sect, "WavePhaX0", water.WavePhaX0)
  water.WavePhaX1 = ini:ReadFloat(sect, "WavePhaX1", water.WavePhaX1)
  water.WavePhaX2 = ini:ReadFloat(sect, "WavePhaX2", water.WavePhaX2)
  water.WavePhaX3 = ini:ReadFloat(sect, "WavePhaX3", water.WavePhaX3)
  water.WavePhaX4 = ini:ReadFloat(sect, "WavePhaX4", water.WavePhaX4)
  water.WavePhaZ0 = ini:ReadFloat(sect, "WavePhaZ0", water.WavePhaZ0)
  water.WavePhaZ1 = ini:ReadFloat(sect, "WavePhaZ1", water.WavePhaZ1)
  water.WavePhaZ2 = ini:ReadFloat(sect, "WavePhaZ2", water.WavePhaZ2)
  water.WavePhaZ3 = ini:ReadFloat(sect, "WavePhaZ3", water.WavePhaZ3)
  water.WavePhaZ4 = ini:ReadFloat(sect, "WavePhaZ4", water.WavePhaZ4)
  water.WaveDirectionX0 = ini:ReadFloat(sect, "WaveDirectionX0", water.WaveDirectionX0)
  water.WaveDirectionX1 = ini:ReadFloat(sect, "WaveDirectionX1", water.WaveDirectionX1)
  water.WaveDirectionX2 = ini:ReadFloat(sect, "WaveDirectionX2", water.WaveDirectionX2)
  water.WaveDirectionX3 = ini:ReadFloat(sect, "WaveDirectionX3", water.WaveDirectionX3)
  water.WaveDirectionX4 = ini:ReadFloat(sect, "WaveDirectionX4", water.WaveDirectionX4)
  water.WaveDirectionZ0 = ini:ReadFloat(sect, "WaveDirectionZ0", water.WaveDirectionZ0)
  water.WaveDirectionZ1 = ini:ReadFloat(sect, "WaveDirectionZ1", water.WaveDirectionZ1)
  water.WaveDirectionZ2 = ini:ReadFloat(sect, "WaveDirectionZ2", water.WaveDirectionZ2)
  water.WaveDirectionZ3 = ini:ReadFloat(sect, "WaveDirectionZ3", water.WaveDirectionZ3)
  water.WaveDirectionZ4 = ini:ReadFloat(sect, "WaveDirectionZ4", water.WaveDirectionZ4)
  water.NormalMapScale0 = ini:ReadFloat(sect, "NormalMapScale0", water.NormalMapScale0)
  water.NormalMapScale1 = ini:ReadFloat(sect, "NormalMapScale1", water.NormalMapScale1)
  water.NormalMapScale2 = ini:ReadFloat(sect, "NormalMapScale2", water.NormalMapScale2)
  water.NormalMapScale3 = ini:ReadFloat(sect, "NormalMapScale3", water.NormalMapScale3)
  water.NormalMapSpeedX0 = ini:ReadFloat(sect, "NormalMapSpeedX0", water.NormalMapSpeedX0)
  water.NormalMapSpeedX1 = ini:ReadFloat(sect, "NormalMapSpeedX1", water.NormalMapSpeedX1)
  water.NormalMapSpeedX2 = ini:ReadFloat(sect, "NormalMapSpeedX2", water.NormalMapSpeedX2)
  water.NormalMapSpeedX3 = ini:ReadFloat(sect, "NormalMapSpeedX3", water.NormalMapSpeedX3)
  water.NormalMapSpeedZ0 = ini:ReadFloat(sect, "NormalMapSpeedZ0", water.NormalMapSpeedZ0)
  water.NormalMapSpeedZ1 = ini:ReadFloat(sect, "NormalMapSpeedZ1", water.NormalMapSpeedZ1)
  water.NormalMapSpeedZ2 = ini:ReadFloat(sect, "NormalMapSpeedZ2", water.NormalMapSpeedZ2)
  water.NormalMapSpeedZ3 = ini:ReadFloat(sect, "NormalMapSpeedZ3", water.NormalMapSpeedZ3)
  water.DistanceScale = ini:ReadFloat(sect, "DistanceScale", water.DistanceScale)
  water.ReflectionInten = ini:ReadFloat(sect, "ReflectionInten", water.ReflectionInten)
  water.RefractionInten = ini:ReadFloat(sect, "RefractionInten", water.RefractionInten)
  water.ReflectionWeight = ini:ReadFloat(sect, "ReflectionWeight", water.ReflectionWeight)
  water.RefractionWeight = ini:ReadFloat(sect, "RefractionWeight", water.RefractionWeight)
  water.SunLevel = ini:ReadFloat(sect, "SunLevel", water.SunLevel)
  water.ReflectionSunInten = ini:ReadFloat(sect, "ReflectionSunInten", water.ReflectionSunInten)
  water.NormalMapFileName1 = "map\\" .. ini:ReadString(sect, "NormalMapFileName1", water.NormalMapFileName1)
  water.NormalMapFileName2 = "map\\" .. ini:ReadString(sect, "NormalMapFileName2", water.NormalMapFileName2)
  water.NormalMapFileName3 = "map\\" .. ini:ReadString(sect, "NormalMapFileName3", water.NormalMapFileName3)
  water.NormalMapFileName4 = "map\\" .. ini:ReadString(sect, "NormalMapFileName4", water.NormalMapFileName4)
  water.CausticSpeed = ini:ReadFloat(sect, "CausticSpeed", water.CausticSpeed)
  water.CausticScale = ini:ReadFloat(sect, "CausticScale", water.CausticScale)
  water.CausticBright = ini:ReadFloat(sect, "CausticBright", water.CausticBright)
  water.CausticFocus = ini:ReadFloat(sect, "CausticFocus", water.CausticFocus)
  water.CausticMap = "map\\tex\\water\\caust.dds"
  water.NoiseMap = "map\\tex\\noise.dds"
  return true
end
function load_water_ini(scene, filename, is_create)
  ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local terrain = scene.terrain
  if is_create then
    terrain:ClearWater()
  end
  local sect_table = ini:GetSectionList()
  for i = 1, table.getn(sect_table) do
    local water_name = sect_table[i]
    local water = nx_null()
    if is_create then
      water = terrain:CreateWater(water_name)
    else
      water = terrain:GetWater(water_name)
    end
    if nx_is_valid(water) then
      read_water_data(ini, water)
      water:UpdateSeaData()
    end
  end
  nx_destroy(ini)
  return true
end
function load_material_ini(scene, filename)
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local terrain = scene.terrain
  local material = terrain.Material
  material.DiffuseAlpha = nx_number(ini:ReadString("material", "DiffuseAlpha", "1.0"))
  material.DiffuseRed = nx_number(ini:ReadString("material", "DiffuseRed", "1.0"))
  material.DiffuseGreen = nx_number(ini:ReadString("material", "DiffuseGreen", "1.0"))
  material.DiffuseBlue = nx_number(ini:ReadString("material", "DiffuseBlue", "1.0"))
  material.AmbientAlpha = nx_number(ini:ReadString("material", "AmbientAlpha", "1.0"))
  material.AmbientRed = nx_number(ini:ReadString("material", "AmbientRed", "1.0"))
  material.AmbientGreen = nx_number(ini:ReadString("material", "AmbientGreen", "1.0"))
  material.AmbientBlue = nx_number(ini:ReadString("material", "AmbientBlue", "1.0"))
  material.SpecularAlpha = nx_number(ini:ReadString("material", "SpecularAlpha", "1.0"))
  material.SpecularRed = nx_number(ini:ReadString("material", "SpecularRed", "0.0"))
  material.SpecularGreen = nx_number(ini:ReadString("material", "SpecularGreen", "0.0"))
  material.SpecularBlue = nx_number(ini:ReadString("material", "SpecularBlue", "0.0"))
  material.EmissiveAlpha = nx_number(ini:ReadString("material", "EmissiveAlpha", "1.0"))
  material.EmissiveRed = nx_number(ini:ReadString("material", "EmissiveRed", "0.0"))
  material.EmissiveGreen = nx_number(ini:ReadString("material", "EmissiveGreen", "0.0"))
  material.EmissiveBlue = nx_number(ini:ReadString("material", "EmissiveBlue", "0.0"))
  material.Power = nx_number(ini:ReadString("material", "Power", "0.0"))
  material.SpecularEnable = nx_boolean(ini:ReadString("material", "SpecularEnable", "false"))
  terrain.FarGroundColor = ini:ReadString("material", "FarGroundColor", "0,0,0,0")
  terrain.FarGroundBegin = ini:ReadFloat("material", "FarGroundBegin", 100)
  terrain.FarGroundEnd = ini:ReadFloat("material", "FarGroundEnd", 500)
  nx_destroy(ini)
  return true
end
function load_base_format_ini(scene, filename)
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return false
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local sect_table = ini:GetSectionList()
  for i = 1, table.getn(sect_table) do
    local sect = sect_table[i]
    local tex_name = ini:ReadString(sect, "BaseTex", "")
    if terrain:FindBaseTex(tex_name) then
      local format = ini:ReadInteger(sect, "Format", 0)
      local scale_u = ini:ReadInteger(sect, "ScaleU", 100)
      local scale_v = ini:ReadInteger(sect, "ScaleV", 100)
      local angle_x = ini:ReadInteger(sect, "AngleX", 0)
      local angle_y = ini:ReadInteger(sect, "AngleY", 0)
      local angle_z = ini:ReadInteger(sect, "AngleZ", 0)
      terrain:SetBaseFormatScaleU(tex_name, 0, scale_u)
      terrain:SetBaseFormatScaleV(tex_name, 0, scale_v)
      terrain:SetBaseFormatAngleX(tex_name, 0, angle_x)
      terrain:SetBaseFormatAngleY(tex_name, 0, angle_y)
      terrain:SetBaseFormatAngleZ(tex_name, 0, angle_z)
    end
  end
  nx_destroy(ini)
  return true
end
function load_format_ini(scene, filename)
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return false
  end
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local sect_table = ini:GetSectionList()
  for i = 1, table.getn(sect_table) do
    local sect = sect_table[i]
    local tex_name = ini:ReadString(sect, "BlendTex", "")
    if terrain:FindBlendTex(tex_name) then
      local format = ini:ReadInteger(sect, "Format", 0)
      local scale_u = ini:ReadInteger(sect, "ScaleU", 100)
      local scale_v = ini:ReadInteger(sect, "ScaleV", 100)
      local angle_x = ini:ReadInteger(sect, "AngleX", 0)
      local angle_y = ini:ReadInteger(sect, "AngleY", 0)
      local angle_z = ini:ReadInteger(sect, "AngleZ", 0)
      if format >= terrain:GetBlendFormatCount(tex_name) then
        terrain:AddBlendFormat(tex_name, scale_u, scale_v, angle_x, angle_y, angle_z)
      else
        terrain:SetBlendFormatScaleU(tex_name, format, scale_u)
        terrain:SetBlendFormatScaleV(tex_name, format, scale_v)
        terrain:SetBlendFormatAngleX(tex_name, format, angle_x)
        terrain:SetBlendFormatAngleY(tex_name, format, angle_y)
        terrain:SetBlendFormatAngleZ(tex_name, format, angle_z)
      end
    end
  end
  nx_destroy(ini)
  return true
end
function load_terrain(scene, filepath, is_login, weather)
  local camera = scene.camera
  local ini_support_physics = false
  local ini_support_physx_cloth = false
  local ini_support_physx_terrain = false
  if nil ~= filepath and "" ~= filepath then
    local tbl_resource = nx_function("ext_split_string", filepath, "\\")
    local tbl_count = table.getn(tbl_resource)
    if 1 < tbl_count then
      local section = tbl_resource[tbl_count - 1]
      local ini_broken = get_ini("ini\\broken_scene_info.ini")
      if nx_is_valid(ini_broken) then
        local index = ini_broken:FindSectionIndex(section)
        if 0 <= index then
          ini_support_physics = nx_boolean(ini_broken:ReadString(index, "SupportPhysics", "false"))
          ini_support_physx_cloth = nx_boolean(ini_broken:ReadString(index, "SupportPhysxCloth", "false"))
          ini_support_physx_terrain = nx_boolean(ini_broken:ReadString(index, "SupportPhysxTerrain", "false"))
        end
      end
    end
  end
  camera.Bind = nx_null()
  local ini = nx_create("IniDocument")
  ini.FileName = filepath .. "terrain.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    nx_msgbox(get_msg_str("msg_459") .. filepath .. "terrain.ini")
    return false
  end
  local zone_scale = ini:ReadInteger("system", "ZoneScale", 256)
  local chunk_scale = ini:ReadInteger("system", "ChunkScale", 32)
  local texture_scale = ini:ReadInteger("system", "TextureScale", 256)
  local texture_units = ini:ReadInteger("system", "TextureUnits", 4)
  local alpha_per_unit = ini:ReadInteger("system", "AlphaPerUnit", 2)
  local light_per_unit = ini:ReadInteger("system", "LightPerUnit", 2)
  local collide_per_unit = ini:ReadInteger("system", "CollidePerUnit", 2)
  local zone_rows = ini:ReadInteger("system", "ZoneRows", 100)
  local zone_cols = ini:ReadInteger("system", "ZoneCols", 100)
  local origin_row = ini:ReadInteger("system", "OriginRow", 50)
  local origin_col = ini:ReadInteger("system", "OriginCol", 50)
  local zone_range = ini:ReadInteger("system", "ZoneRange", 2)
  local unit_size = ini:ReadFloat("system", "UnitSize", 1)
  if not ini:FindItem("system", "UnitSize") then
    unit_size = ini:ReadFloat("system", "UnitX", unit_size)
  end
  local height_map = ini:ReadString("system", "HeightMap", "")
  local init_height = ini:ReadFloat("system", "InitHeight", 0)
  local light_tex_scale = ini:ReadInteger("system", "LightTexScale", 256)
  local model_effect = ini:ReadString("system", "ModelEffect", "")
  local zone_light_path = ini:ReadString("system", "ZoneLightPath", "lzone")
  local model_light_path = ini:ReadString("system", "ModelLightPath", "lmodel")
  local walkable_path = ini:ReadString("system", "WalkablePath", "walk")
  local no_light = nx_boolean(ini:ReadString("system", "NoLight", "false"))
  local normalmap = nx_boolean(ini:ReadString("system", "NormalMap", "false"))
  local pom = nx_boolean(ini:ReadString("system", "POM", "false"))
  local support_physics = ini_support_physics
  local support_physx_cloth = ini_support_physx_cloth
  local support_physx_terrain = ini_support_physx_terrain
  local compressed_height_data = nx_boolean(ini:ReadString("system", "CompressedHeightData", "false"))
  local compressed_normal_data = nx_boolean(ini:ReadString("system", "CompressedNormalData", "false"))
  local world = nx_value("world")
  if support_physics then
    world.SupportPhysics = true
    world.SupportPhysicsDestructible = true
    world.SupportPhysicsRagdoll = true
    world.SupportPhysicsRigidBody = true
  else
    world.SupportPhysics = false
    world.SupportPhysicsDestructible = false
    world.SupportPhysicsRagdoll = false
    world.SupportPhysicsRigidBody = false
  end
  if support_physics then
    if support_physx_cloth then
      if nx_execute("form_stage_main\\form_system\\form_system_setting", "can_support_physics") then
        world.SupportPhysicsCloth = true
      end
    else
      world.SupportPhysicsCloth = false
    end
    if support_physx_terrain then
      world.SupportPhysicsTerrain = true
    else
      world.SupportPhysicsTerrain = false
    end
  end
  if world.SupportPhysics and (not nx_find_custom(scene, "physics_scene") or not nx_is_valid(scene.physics_scene)) then
    local PhysicsScene = scene:Create("PhysicsScene")
    scene:AddObject(PhysicsScene, 999)
    scene.physics_scene = PhysicsScene
    nx_set_value("physics_scene", PhysicsScene)
  end
  nx_execute("game_config", "set_logic_sound_enable", scene, 0, false)
  local terrain = scene:Create("Terrain")
  terrain.scene = scene
  terrain.AppendPath = "map\\"
  terrain.SkyManager = nx_execute("terrain\\weather", "create_sky_manager", scene)
  scene.terrain = terrain
  terrain:SetParameter(zone_scale, chunk_scale, texture_scale, texture_units, alpha_per_unit, collide_per_unit)
  terrain.LightPerUnit = light_per_unit
  terrain.FilePath = filepath
  terrain.DesignMode = false
  terrain.UnitSize = unit_size
  terrain.HeightMap = height_map
  terrain.InitHeight = init_height
  terrain.LightTexScale = light_tex_scale
  terrain.ZoneLightPath = zone_light_path
  terrain.ModelLightPath = model_light_path
  terrain.WalkablePath = walkable_path
  terrain.NoLight = no_light
  terrain.EnableNormalMap = normalmap
  terrain.ModelEffect = model_effect
  terrain.CollideScale = 8
  local open_pom = false
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and (game_config.level == "high" or game_config.level == "ultra") then
    open_pom = true
  end
  if not support_pom_rian_skin() then
    open_pom = false
  end
  if open_pom then
    terrain.EnablePOM = pom
  else
    terrain.EnablePOM = false
  end
  terrain:ClearBaseTex()
  local rain_enable = false
  local WeatherTimeManager = nx_value("WeatherTimeManager")
  if nx_is_valid(game_config) and nx_is_valid(WeatherTimeManager) then
    local rain_type = WeatherTimeManager:GetWeatherType(-1)
    if game_config.weather_enable and (rain_type == 1 or rain_type == 2 or rain_type == 3) then
      rain_enable = true
    end
  end
  if not support_pom_rian_skin() then
    rain_enable = false
    open_pom = false
  end
  if open_pom then
    terrain.EnableRain = rain_enable
  else
    terrain.EnableRain = false
  end
  load_ripple_ini(terrain, filepath .. "ripple.ini")
  local base_table = ini:GetItemList("base")
  for i = 1, table.getn(base_table) do
    local base_name = base_table[i]
    local base_tex = ini:ReadString("base", base_name, "")
    if base_tex ~= "" then
      terrain:AddBaseTex(base_name, terrain.AppendPath .. base_tex)
    end
  end
  terrain:ClearBlendTex()
  local blend_table = ini:GetItemList("blend")
  for i = 1, table.getn(blend_table) do
    local blend_name = blend_table[i]
    local blend_tex = ini:ReadString("blend", blend_name, "")
    if blend_tex ~= "" then
      terrain:AddBlendTex(blend_name, terrain.AppendPath .. blend_tex)
    end
  end
  terrain.CompressedHeightData = compressed_height_data
  terrain.CompressedNormalData = compressed_normal_data
  terrain:ClearTexturePath()
  local tex_path_table = ini:GetItemList("tex_path")
  for i = 1, table.getn(tex_path_table) do
    local key = tex_path_table[i]
    local tex_path = ini:ReadString("tex_path", key, "")
    if tex_path ~= "" then
      terrain:AddTexturePath(terrain.AppendPath .. tex_path)
    end
  end
  nx_destroy(ini)
  terrain.GlobalEnvironmentMap = "map\\tex\\environment_reflect.dds"
  terrain.GrassRadius = 50
  terrain.GroundEnvMap = 0
  terrain.VisualEnvMap = 0
  terrain.AlphaFadeRadius = 200
  terrain.AlphaHideRadius = 250
  terrain.VisualRadiusSmall = 1
  terrain.VisualRadiusBig = 50
  terrain.ClipRadiusNear = 200
  terrain.ClipRadiusFar = 250
  terrain.LoadRadiusAdd = 50
  terrain.UnloadRadiusAdd = 50
  nx_bind_script(terrain, "terrain\\terrain", "terrain_init")
  load_scene_screeneffect(scene, filepath, true, weather)
  load_water_ini(scene, filepath .. "water.ini", true)
  nx_execute("ocean_edit\\ocean_edit", "terrain_read_ocean")
  load_grass_ini(scene, filepath .. "grass.ini", true)
  load_material_ini(scene, filepath .. "material.ini")
  load_base_format_ini(scene, filepath .. "base_format.ini")
  load_format_ini(scene, filepath .. "format.ini")
  local open_skin = false
  if nx_is_valid(game_config) and (game_config.level == "high" or game_config.level == "ultra") then
    open_skin = true
  end
  if not support_pom_rian_skin() then
    open_skin = false
  end
  if open_skin then
    load_skin_effect_ini(scene, filepath .. "skin_effect.ini")
  else
    scene.EnableSkinEffect = false
  end
  terrain.HorizontalCulling = true
  terrain.VisualSortOrder = 1
  terrain.GroundSortOrder = 1
  if terrain.UnitSize == 1 then
    terrain.GroundLevelDown = 1
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local str_zone_info = ""
  if nx_is_valid(client_scene) then
    str_zone_info = nx_string(client_scene:QueryProp("RandomTerrainInfo"))
  end
  if str_zone_info ~= "0" and str_zone_info ~= "" then
    local returnTable = util_split_string(str_zone_info, ",")
    local zone_num = table.getn(returnTable) / 4
    terrain.RandTerrain = true
    local mapping = terrain.ZoneMapping
    for i = 1, zone_num do
      local zone_name = "zone_" .. nx_string(returnTable[(i - 1) * 4 + 3]) .. "_" .. nx_string(returnTable[(i - 1) * 4 + 4])
      mapping:AddName(i, zone_name)
    end
    local m, n = string.find(filepath, "map\\ter\\")
    local append_path = string.sub(filepath, n + 1, string.len(filepath) - 1)
    mapping.AppendPath = "map\\ter\\" .. append_path .. "\\"
    for i = 1, zone_num do
      mapping:AddMapping(nx_int(returnTable[(i - 1) * 4 + 1]), nx_int(returnTable[(i - 1) * 4 + 2]), i)
    end
  end
  terrain:Load()
  scene:AddObject(terrain, 20)
  scene.terrain = terrain
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual.Terrain = terrain
  end
  terrain.Sky = scene.sky
  local game_config = nx_value("game_config")
  if (is_login == nil or not is_login) and game_config.level == "simple" then
    zone_range = 1
  end
  if not can_open_big_view_for_set_zone_range() and 2 < zone_range then
    zone_range = 2
  end
  terrain:InitZones(zone_rows, zone_cols, origin_row, origin_col, zone_range)
  if is_login == nil or not is_login then
    nx_execute("game_config", "apply_performance_config", scene, game_config)
  end
  while not terrain.LoadFinish do
    nx_pause(0)
    if not nx_is_valid(terrain) then
      return false
    end
  end
  load_client_npc(terrain, filepath)
  local scenario_npc_manager = nx_value("scenario_npc_manager")
  if nx_is_valid(scenario_npc_manager) then
    scenario_npc_manager.Terrain = terrain
    scenario_npc_manager.SceneClipDistance = scene.FarClipDistance
  end
  scene:LayerAdd("sun_trace", terrain)
  scene:LayerAdd("shadow", terrain)
  scene:LayerAdd("sea_reflection", terrain)
  local water_table = terrain:GetWaterList()
  for i = 1, table.getn(water_table) do
    water_table[i]:Start()
  end
  terrain:RefreshGround()
  terrain:RefreshVisual()
  terrain:RefreshWater()
  terrain:RefreshGrass()
  return true
end
function load_scene_screeneffect(scene, filepath, is_create, weather)
  if weather ~= nil and nx_string(weather) ~= nx_string("0") and nx_string(weather) ~= nx_string("") and string.find(nx_string(weather), "\\") ~= nil then
    nx_call("terrain\\weather", "load_weather_ini", scene, nx_resource_path() .. nx_string(weather))
    local len = 0
    local tbl_dir = util_split_string(nx_string(weather), "\\")
    local count = table.getn(tbl_dir)
    if 0 < count then
      len = string.len(tbl_dir[count])
      if len <= 0 then
        return
      end
    else
      return
    end
    local dir = nx_resource_path() .. string.sub(nx_string(weather), 1, -(len + 1))
    if nx_file_exists(nx_string(dir) .. "shadow.ini") then
      nx_call("terrain\\weather", "load_shadow_ini", scene, nx_string(dir) .. "shadow.ini")
    end
    if nx_file_exists(nx_string(dir) .. "screen.ini") then
      load_screen_ini(scene, nx_string(dir) .. "screen.ini")
    end
    if nx_file_exists(nx_string(dir) .. "ppbloom.ini") then
      nx_call("terrain\\bloom", "load_ppbloom_ini", scene, nx_string(dir) .. "ppbloom.ini")
    end
    if nx_file_exists(nx_string(dir) .. "ppvolumelighting.ini") then
      nx_call("terrain\\volumelighting", "load_ppvolumelighting_ini", scene, nx_string(dir) .. "ppvolumelighting.ini")
    end
    if nx_file_exists(nx_string(dir) .. "ppscreenrefraction.ini") then
      nx_call("terrain\\screenrefraction", "load_ppscreenrefraction_ini", scene, nx_string(dir) .. "ppscreenrefraction.ini")
    end
    if nx_file_exists(nx_string(dir) .. "pppixelrefraction.ini") then
      nx_call("terrain\\pixelrefraction", "load_pppixelrefraction_ini", scene, nx_string(dir) .. "pppixelrefraction.ini")
    end
    if nx_file_exists(nx_string(dir) .. "role.ini") then
      nx_call("terrain\\role_param", "load_role_ini", scene, nx_string(dir) .. "role.ini")
    end
    if nx_file_exists(nx_string(dir) .. "pssm.ini") then
      nx_call("terrain\\pssm", "load_pssm_ini", scene, nx_string(dir) .. "pssm.ini")
    end
    if nx_file_exists(nx_string(dir) .. "ssao.ini") then
      nx_call("terrain\\ssao", "load_ssao_ini", scene, nx_string(dir) .. "ssao.ini")
    end
    if nx_file_exists(nx_string(dir) .. "ppdof.ini") then
      nx_call("terrain\\dof", "load_ppdof_ini", scene, nx_string(dir) .. "ppdof.ini")
    end
    if nx_file_exists(nx_string(dir) .. "ppscrblur.ini") then
      nx_call("terrain\\screenblur", "load_ppscreenblur_ini", scene, nx_string(dir) .. "ppscrblur.ini")
    end
    if nx_file_exists(nx_string(dir) .. "ppfilter.ini") then
      nx_call("terrain\\filter", "load_ppfilter_ini", scene, nx_string(dir) .. "ppfilter.ini")
    end
    if nx_file_exists(nx_string(dir) .. "pphdr.ini") then
      nx_call("terrain\\hdr", "load_pphdr_ini", scene, nx_string(dir) .. "pphdr.ini")
    end
  else
    nx_call("terrain\\weather", "load_weather_ini", scene, filepath .. "weather.ini")
    nx_call("terrain\\weather", "load_shadow_ini", scene, filepath .. "shadow.ini")
    load_screen_ini(scene, filepath .. "screen.ini")
    nx_call("terrain\\bloom", "load_ppbloom_ini", scene, filepath .. "ppbloom.ini")
    nx_call("terrain\\volumelighting", "load_ppvolumelighting_ini", scene, filepath .. "ppvolumelighting.ini")
    nx_call("terrain\\screenrefraction", "load_ppscreenrefraction_ini", scene, filepath .. "ppscreenrefraction.ini")
    nx_call("terrain\\pixelrefraction", "load_pppixelrefraction_ini", scene, filepath .. "pppixelrefraction.ini")
    nx_call("terrain\\role_param", "load_role_ini", scene, filepath .. "role.ini")
    nx_call("terrain\\pssm", "load_pssm_ini", scene, filepath .. "pssm.ini")
    nx_call("terrain\\ssao", "load_ssao_ini", scene, filepath .. "ssao.ini")
    nx_call("terrain\\dof", "load_ppdof_ini", scene, filepath .. "ppdof.ini")
    nx_call("terrain\\screenblur", "load_ppscreenblur_ini", scene, filepath .. "ppscrblur.ini")
    nx_call("terrain\\filter", "load_ppfilter_ini", scene, filepath .. "ppfilter.ini")
    nx_call("terrain\\hdr", "load_pphdr_ini", scene, filepath .. "pphdr.ini")
  end
  nx_call("terrain\\weather", "change_weather", scene)
  nx_call("terrain\\weather", "load_cloud_ini", scene, filepath .. "cloud.ini")
  change_screen(scene)
  nx_call("terrain\\role_param", "change_role_param", scene)
  nx_call("terrain\\volumelighting", "change_ppvolumelighting", scene)
  nx_call("terrain\\screenrefraction", "change_ppscreenrefraction", scene)
  nx_call("terrain\\pixelrefraction", "change_pppixelrefraction", scene)
  nx_call("terrain\\pssm", "change_pssm", scene)
  nx_call("terrain\\ssao", "change_ssao", scene)
  nx_call("terrain\\dof", "change_ppdof", scene)
  nx_call("terrain\\screenblur", "change_ppscreenblur", scene)
  nx_call("terrain\\bloom", "change_ppbloom", scene)
  nx_call("terrain\\filter", "change_ppfilter", scene)
  nx_call("terrain\\hdr", "change_pphdr", scene)
  nx_call("terrain\\glow", "change_ppglow", scene)
  nx_call("terrain\\fxaa", "change_fxaa", scene)
end
function delete_scene_screeneffect(scene)
  nx_call("terrain\\bloom", "delete_ppbloom", scene)
  nx_call("terrain\\volumelighting", "delete_ppvolumelighting", scene)
  nx_call("terrain\\screenrefraction", "delete_ppscreenrefraction", scene)
  nx_call("terrain\\pixelrefraction", "delete_pppixelrefraction", scene)
  nx_call("terrain\\pssm", "delete_pssm", scene)
  nx_call("terrain\\ssao", "delete_ssao", scene)
  nx_call("terrain\\dof", "delete_ppdof", scene)
  nx_call("terrain\\screenblur", "delete_ppscreenblur", scene)
  nx_call("terrain\\filter", "delete_ppfilter_force", scene)
  nx_call("terrain\\hdr", "delete_pphdr_force", scene)
  return true
end
function unload_terrain(scene)
  if not nx_find_custom(scene, "terrain") or not nx_is_valid(scene.terrain) then
    return false
  end
  nx_call("terrain\\weather_set", "delete_weather_data")
  local terrain = scene.terrain
  delete_scene_screeneffect(scene)
  local client_npc_manager = nx_value("client_npc_manager")
  if nx_is_valid(client_npc_manager) then
    client_npc_manager:Clear()
  end
  scene:RemoveObject(terrain)
  terrain:ReleaseAllZoneLoader()
  scene:Delete(terrain)
  scene:Delete(scene.sky)
  scene:Delete(scene.sun)
  nx_log("unload_terrain")
  return true
end
function load_client_npc(terrain, filepath)
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local client_file_name = "scenenpc.ini"
  if nx_is_valid(client_scene) and client_scene:FindProp("ClineNpcFile") then
    client_file_name = nx_string(client_scene:QueryProp("ClineNpcFile")) .. ".ini"
  end
  local client_npc_manager = nx_value("client_npc_manager")
  if nx_is_valid(client_npc_manager) then
    client_npc_manager.filepath = filepath
    client_npc_manager.Terrain = terrain
    client_npc_manager:Clear()
    client_npc_manager:Load(filepath .. client_file_name)
  end
end
function load_skin_effect_ini(scene, file_ini)
  if not nx_is_valid(scene) then
    return
  end
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    scene.EnableSkinEffect = false
    return
  end
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    scene.EnableSkinEffect = false
    return
  end
  ini.FileName = file_ini
  if not ini:LoadFromFile() then
    scene.EnableSkinEffect = false
    nx_destroy(ini)
    return
  end
  local effect_enable = nx_boolean(ini:ReadString("skin_effect", "SkinEffectEnable", "false"))
  scene.EnableSkinEffect = effect_enable
  if effect_enable then
    if nx_find_custom(scene, "ppskineffect") and nx_is_valid(scene.ppskineffect) then
      local ppskineffect = scene.ppskineffect
      ppskineffect.SSSLevel = ini:ReadFloat("skin_effect", "SSSLevel", 50)
      ppskineffect.Correction = ini:ReadFloat("skin_effect", "Correction", 800)
      ppskineffect.MaxDD = ini:ReadFloat("skin_effect", "MaxDD", 0.0115)
      ppskineffect.Variance1 = ini:ReadFloat("skin_effect", "Variance1", 0.6375)
      ppskineffect.Variance2 = ini:ReadFloat("skin_effect", "Variance2", 0.2719)
      ppskineffect.Variance3 = ini:ReadFloat("skin_effect", "Variance3", 2.0062)
    else
      local ppskineffect = scene:Create("PPSkinEffect")
      if nx_is_valid(ppskineffect) then
        postprocess_man:RegistPostProcess(ppskineffect)
        scene.ppskineffect = ppskineffect
        ppskineffect.SSSLevel = ini:ReadFloat("skin_effect", "SSSLevel", 50)
        ppskineffect.Correction = ini:ReadFloat("skin_effect", "Correction", 800)
        ppskineffect.MaxDD = ini:ReadFloat("skin_effect", "MaxDD", 0.0115)
        ppskineffect.Variance1 = ini:ReadFloat("skin_effect", "Variance1", 0.6375)
        ppskineffect.Variance2 = ini:ReadFloat("skin_effect", "Variance2", 0.2719)
        ppskineffect.Variance3 = ini:ReadFloat("skin_effect", "Variance3", 2.0062)
      end
    end
  end
  nx_destroy(ini)
end
function can_open_big_view_for_set_zone_range()
  local game_config = nx_value("game_config")
  if not nx_function("ext_is_64bit_system") then
    return false
  end
  local device_caps = nx_value("device_caps")
  if nx_is_valid(device_caps) then
    local card_level = nx_execute("device_test", "get_video_card_level", device_caps)
    if card_level < 3 then
      return false
    end
    local mem_size = device_caps.TotalVideoMemory + device_caps.TotalAgpMemory
    if mem_size < 800 then
      return false
    end
    local table_mem = device_caps:QueryMemory()
    if table_mem ~= nil and table.getn(table_mem) > 0 then
      if table_mem[2] < 3000 then
        return false
      end
    else
      return false
    end
  else
    return false
  end
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
    return false
  end
  return true
end
function can_open_big_view()
  local game_config = nx_value("game_config")
  if not nx_function("ext_is_64bit_system") then
    return false
  end
  local device_caps = nx_value("device_caps")
  if nx_is_valid(device_caps) then
    local card_level = nx_execute("device_test", "get_video_card_level", device_caps)
    if card_level < 3 then
      return false
    end
    local mem_size = device_caps.TotalVideoMemory + device_caps.TotalAgpMemory
    if mem_size < 800 then
      return false
    end
    local table_mem = device_caps:QueryMemory()
    if table_mem ~= nil and table.getn(table_mem) > 0 then
      if table_mem[2] < 3000 then
        return false
      end
    else
      return false
    end
  else
    return false
  end
  if game_config.level ~= "high" and game_config.level ~= "ultra" then
    if game_config.level == "personal" then
      if game_config.grass_lod == 1 and game_config.visual_radius == 250 and game_config.grass_radius == 100 then
        return true
      else
        return false
      end
    else
      return false
    end
  end
  return true
end
function load_ripple_ini(terrain, filename)
  if not nx_is_valid(terrain) then
    return
  end
  terrain:ClearRippleNormalMaps()
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() or not ini:FindSection("Ripples") then
    nx_destroy(ini)
    load_default_config(terrain)
    return
  end
  local item_count = ini:GetItemCount("Ripples")
  for i = 1, item_count do
    local file_path = ini:ReadString("Ripples", nx_string(i), "")
    terrain:AddRippleNormalMap("map\\" .. file_path)
  end
  nx_destroy(ini)
end
function load_default_config(terrain)
  if not nx_is_valid(terrain) then
    return
  end
  for i = 1, 24 do
    local file_path = nx_string("map\\tex\\rain\\Ripple\\ripple") .. i .. "_ddn.dds"
    terrain:AddRippleNormalMap(file_path)
  end
end
