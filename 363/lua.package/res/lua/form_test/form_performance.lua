local performance_list = {
  DIP = {
    1,
    0,
    "255,0,0,255",
    15000,
    "255,255,0,0",
    4000,
    "255,128,128,0",
    0,
    "\197\250\180\206\202\253"
  },
  TL = {
    2,
    0,
    "255,0,0,255",
    3000000,
    "255,255,0,0",
    1000000,
    "255,128,128,0",
    0,
    "\200\253\189\199\195\230\202\253"
  }
}
function log(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  if gui.DeviceWidth > self.Width + 20 then
    self.ori_width = gui.DeviceWidth - 20
  else
    self.ori_width = self.Width
  end
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = 0
  self.Top = gui.Height - self.Height
  set_query(self, false)
  local status_form = nx_value("status_form")
  if nx_is_valid(status_form) then
    self.Top = self.Top - status_form.Height
  end
  for index, item in pairs(performance_list) do
    init_prog_bar(self, item[1], item[2], item[3], item[4], item[5], item[6], item[7], item[8], item[9])
  end
  nx_execute(nx_current(), "listener_performance", self)
  return 1
end
function main_form_close(self)
  nx_destroy(self)
  return 1
end
function close_btn_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
local function get_unit_count()
  local count = 0
  for index, item in pairs(performance_list) do
    count = count + 1
  end
  return count
end
function listener_performance(form)
  local gui = nx_value("gui")
  local unit_count = get_unit_count()
  local data = {}
  while nx_is_valid(form) do
    local DP, DPU, DIP, DIPU, PL, LL, LS, TL, TS, TF = gui:GetPrimitiveInfo()
    data[1] = DIP
    data[2] = TL
    for index = 1, unit_count do
      set_prog_bar(form, index, data[index])
    end
    nx_pause(0)
  end
  return 1
end
local parse_color = function(color)
  local alpha = 0
  local red = 0
  local green = 0
  local blue = 0
  local pos1 = string.find(color, ",")
  if pos1 == nil then
    return alpha, red, green, blue
  end
  local pos2 = string.find(color, ",", pos1 + 1)
  if pos2 == nil then
    return alpha, red, green, blue
  end
  local pos3 = string.find(color, ",", pos2 + 1)
  if pos3 == nil then
    return alpha, red, green, blue
  end
  local alpha = nx_number(string.sub(color, 1, pos1 - 1))
  local red = nx_number(string.sub(color, pos1 + 1, pos2 - 1))
  local green = nx_number(string.sub(color, pos2 + 1, pos3 - 1))
  local blue = nx_number(string.sub(color, pos3 + 1))
  return alpha, red, green, blue
end
local get_near_int = function(f)
  local sign = 1
  if f < 0 then
    sign = -1
  end
  local v = math.abs(f)
  local low = math.floor(v)
  if v <= low + 0.5 then
    return low * sign
  else
    return (low + 1) * sign
  end
end
local lerp = function(x, y, s)
  return x + s * (y - x)
end
local function lerp_color(color1, color2, s)
  local a1, r1, g1, b1 = parse_color(color1)
  local a2, r2, g2, b2 = parse_color(color2)
  local a = get_near_int(lerp(a1, a2, s))
  local r = get_near_int(lerp(r1, r2, s))
  local g = get_near_int(lerp(g1, g2, s))
  local b = get_near_int(lerp(b1, b2, s))
  return nx_string(a) .. "," .. nx_string(r) .. "," .. nx_string(g) .. "," .. nx_string(b)
end
local float_equal = function(v1, v2, epsilon)
  return v1 <= v2 + epsilon and v1 >= v2 - epsilon
end
local function get_color(min_value, min_color, max_value, max_color, ref_value, ref_color, cur_value)
  if float_equal(min_value, ref_value, 0.1) or float_equal(max_value, ref_value, 0.1) then
    local x = (cur_value - min_value) / (max_value - min_value)
    return lerp_color(min_color, max_color, x)
  end
  if min_value <= cur_value and cur_value <= ref_value then
    local x = (cur_value - min_value) / (ref_value - min_value)
    return lerp_color(min_color, ref_color, x)
  else
    local x = (cur_value - ref_value) / (max_value - ref_value)
    return lerp_color(ref_color, max_color, x)
  end
end
function init_prog_bar(form, index, min_value, min_color, max_value, max_color, ref_value, ref_color, cur_value, info)
  local prog_bar = form:Find("prog_bar_" .. index)
  local refer_value_label = form:Find("refer_value_label_" .. index)
  local desc_label = form:Find("desc_label_" .. index)
  local ref_label = form:Find("ref_label_" .. index)
  local delta_height = 0
  if nx_is_valid(prog_bar) then
    prog_bar.TextVisible = true
    prog_bar.TextPercent = false
    prog_bar.Minimum = min_value
    prog_bar.Maximum = max_value
    prog_bar.Value = cur_value
    prog_bar.ref_value = ref_value
    prog_bar.min_color = min_color
    prog_bar.max_color = max_color
    prog_bar.ref_color = ref_color
    prog_bar.ForeColor = get_color(min_value, min_color, max_value, max_color, ref_value, ref_color, cur_value)
    delta_height = prog_bar.Height * (prog_bar.ref_value / prog_bar.Maximum)
  end
  if nx_is_valid(refer_value_label) then
    refer_value_label.Top = refer_value_label.Top - delta_height
  end
  if nx_is_valid(desc_label) then
    desc_label.Text = nx_widestr(info)
  end
  if nx_is_valid(ref_label) then
    ref_label.NoFrame = true
    ref_label.Top = ref_label.Top - delta_height
    ref_label.Text = nx_widestr("\198\191\190\177\214\181\163\186") .. nx_widestr(ref_value)
  end
  return true
end
function set_prog_bar(form, index, value)
  local prog_bar = form:Find("prog_bar_" .. index)
  if nx_is_valid(prog_bar) then
    prog_bar.Value = value
    prog_bar.ForeColor = get_color(prog_bar.Minimum, prog_bar.min_color, prog_bar.Maximum, prog_bar.max_color, prog_bar.ref_value, prog_bar.ref_color, value)
  end
  return true
end
function set_query(form, value)
  if value then
    form.query_check.Text = nx_widestr("<<\178\233\209\175")
    form.Width = form.ori_width
    form.visual_list.Width = form.Width - form.pos_label.Left - 20
  else
    form.query_check.Text = nx_widestr("\178\233\209\175>>")
    form.Width = form.pos_label.Left
  end
end
function query_checked_changed(self)
  local form = self.Parent
  set_query(form, self.Checked)
  return 1
end
local get_zone_row_col_from_file_name = function(zone_name)
  local zone_row, zone_col
  local pos1 = string.find(zone_name, "_")
  if pos1 == nil then
    return zone_row, zone_col
  end
  local pos2 = string.find(zone_name, "_", pos1 + 1)
  if pos2 == nil then
    return zone_row, zone_col
  end
  local zone_row = nx_number(string.sub(zone_name, pos1 + 1, pos2 - 1))
  local zone_col = nx_number(string.sub(zone_name, pos2 + 1))
  return zone_row, zone_col
end
local search_file_to_list = function(dir, filter, list)
  local fs = nx_create("FileSearch")
  fs:SearchFile(dir, filter)
  local file_table = fs:GetFileList()
  local file_count = table.getn(file_table)
  for i = 1, file_count do
    local file_name = file_table[i]
    local child = list:CreateChild(file_name)
  end
  nx_destroy(fs)
  return file_count
end
local function go_zone(zone_name)
  local terrain = nx_value("terrain")
  if not nx_is_valid(terrain) then
    return 0
  end
  local zone_row, zone_col = get_zone_row_col_from_file_name(zone_name)
  if nil == zone_row then
    return 0
  end
  if zone_row < 0 or zone_row >= terrain.ZoneRows or zone_col < 0 or zone_col >= terrain.ZoneCols then
    return 0
  end
  local camera = nx_value("camera")
  if nx_is_valid(camera) then
    local new_y = camera.PositionY
    local new_x = terrain.ZoneScale * terrain.UnitSize * (zone_col - terrain.ZoneOriginCol)
    local new_z = terrain.ZoneScale * terrain.UnitSize * (zone_row - terrain.ZoneOriginRow)
    camera:SetPosition(new_x, new_y, new_z)
  end
  return 1
end
local wait_terrain_load_finish = function()
  nx_pause(0.1)
  local terrain = nx_value("terrain")
  while nx_is_valid(terrain) and not terrain.LoadFinish do
    nx_pause(0)
  end
end
function show_info(info, font_color)
  local tool_bar_form = nx_value("tool_bar_form")
  if nx_is_valid(tool_bar_form) then
    tool_bar_form.hint_label.ForeColor = font_color
    tool_bar_form.hint_label.Text = nx_widestr(info)
  end
  return true
end
local restore_camera = function(succeed, info, x, y, z)
  if succeed then
    show_info(info, "255,0,0,255")
  else
    show_info(info, "255,255,0,0")
  end
  local camera = nx_value("camera")
  if nx_is_valid(camera) then
    camera:SetPosition(x, y, z)
  end
  if succeed then
    return 1
  else
    return 0
  end
end
local function search_viusal(form, search_type, base_count)
  if "triangle_count" ~= search_type and "vertex_count" ~= search_type then
    return 0
  end
  if base_count <= 0 then
    return 0
  end
  local camera = nx_value("camera")
  if not nx_is_valid(camera) then
    return 0
  end
  local terrain = nx_value("terrain")
  if not nx_is_valid(terrain) then
    return 0
  end
  local visual_file_table = nx_call("util_gui", "get_global_arraylist", "visual_file_table")
  search_file_to_list(terrain.FilePath, "*.visual", visual_file_table)
  local visual_file_list = visual_file_table:GetChildList()
  local visual_file_count = table.getn(visual_file_list)
  if visual_file_count <= 0 then
    nx_destroy(visual_file_table)
    return 0
  end
  form.visual_list:ClearString()
  form.visual_list:BeginUpdate()
  local old_x, old_y, old_z = camera.PositionX, camera.PositionY, camera.PositionZ
  for i = 1, visual_file_count do
    local zone_name = visual_file_list[i].Name
    if 0 == go_zone(zone_name) then
      form.visual_list:EndUpdate()
      nx_destroy(visual_file_table)
      return restore_camera(false, "\178\233\213\210\179\172\185\253\214\184\182\168\195\230\202\253\181\196\196\163\208\205\202\177\179\246\180\237", old_x, old_y, old_z)
    end
    wait_terrain_load_finish()
    if not nx_is_valid(form) then
      nx_destroy(visual_file_table)
      return restore_camera(false, "\200\161\207\251\178\233\213\210\179\172\185\253\214\184\182\168\195\230\202\253\181\196\196\163\208\205", old_x, old_y, old_z)
    end
    local ter_y = terrain:GetPosiY(camera.PositionX, camera.PositionZ)
    ter_y = ter_y + 50
    camera:SetPosition(camera.PositionX, ter_y, camera.PositionZ)
    local zone_index = terrain.Editor:GetZoneIndex(camera.PositionX, camera.PositionZ)
    if 0 <= zone_index then
      local visual_table = terrain.Editor:GetZoneVisualList(zone_index)
      for j = 1, table.getn(visual_table) do
        local visual = visual_table[j]
        if nx_name(visual) == "Model" then
          local count = 0
          if "triangle_count" == search_type then
            count = visual:GetAllTriangleCount()
          elseif "vertex_count" == search_type then
            count = visual:GetAllVertexCount()
          end
          if base_count <= count then
            local info = visual.ModelFile .. ",pos=" .. nx_decimals(visual.PositionX, 1) .. "," .. nx_decimals(visual.PositionY, 1) .. "," .. nx_decimals(visual.PositionZ, 1) .. "," .. nx_string(visual.name) .. "," .. search_type .. "=" .. nx_string(count)
            form.visual_list:AddString(nx_widestr(info))
          end
        end
      end
      show_info("\178\233\213\210\179\172\185\253\214\184\182\168\195\230\202\253\181\196\196\163\208\205\163\172\205\234\179\201\181\218" .. nx_string(i) .. "\184\246\206\196\188\254\181\196\203\209\203\247(\185\178" .. nx_string(visual_file_count) .. "\184\246\206\196\188\254)", "255,0,0,255")
    end
  end
  form.visual_list:EndUpdate()
  nx_destroy(visual_file_table)
  return restore_camera(true, "\178\233\213\210\179\172\185\253\214\184\182\168\195\230\202\253\181\196\196\163\208\205\179\201\185\166\189\225\202\248", old_x, old_y, old_z)
end
function search_triangle_count_btn_click(self)
  local form = self.Parent
  search_viusal(form, "triangle_count", nx_number(form.triangle_count_fe.Text))
  return 1
end
function search_vertex_count_btn_click(self)
  local form = self.Parent
  search_viusal(form, "vertex_count", nx_number(form.vertex_count_fe.Text))
  return 1
end
local parse_info = function(info)
  local x, y, z, name
  local pos1 = string.find(info, "pos=")
  if nil == pos1 then
    return x, y, z, name
  end
  pos1 = pos1 + 3
  local pos2 = string.find(info, ",", pos1 + 1)
  if pos2 == nil then
    return x, y, z, name
  end
  local pos3 = string.find(info, ",", pos2 + 1)
  if pos3 == nil then
    return x, y, z, name
  end
  local pos4 = string.find(info, ",", pos3 + 1)
  if pos4 == nil then
    return x, y, z, name
  end
  local pos5 = string.find(info, ",", pos4 + 1)
  if pos5 == nil then
    return x, y, z, name
  end
  local x = nx_number(string.sub(info, pos1 + 1, pos2 - 1))
  local y = nx_number(string.sub(info, pos2 + 1, pos3 - 1))
  local z = nx_number(string.sub(info, pos3 + 1, pos4 - 1))
  local name = string.sub(info, pos4 + 1, pos5 - 1)
  return x, y, z, name
end
local normalize_angle = function(angle)
  local value = math.fmod(angle, math.pi * 2)
  if value < 0 then
    value = value + math.pi * 2
  end
  return value
end
function restore_visual(visual, seconds)
  nx_pause(seconds)
  if not nx_is_valid(visual) then
    return false
  end
  visual.ShowBoundBox = false
  visual.Color = visual.old_color
  return true
end
function visual_list_select_double_click(self)
  local form = self.Parent
  local terrain = nx_value("terrain")
  if not nx_is_valid(terrain) then
    return 0
  end
  local camera = nx_value("camera")
  if not nx_is_valid(camera) then
    return 0
  end
  local x, y, z, name = parse_info(nx_string(self.SelectString))
  if nil == x then
    return 0
  end
  local ay = normalize_angle(math.pi)
  local dis = 10
  local cam_x = dis * math.sin(ay)
  local cam_z = dis * math.cos(ay)
  camera:SetPosition(x + cam_x, y + 1 + dis, z + cam_z)
  camera:SetAngle(0.7, math.pi + ay, 0)
  nx_pause(0.1)
  wait_terrain_load_finish()
  if not nx_is_valid(form) then
    return 0
  end
  local visual = terrain:GetVisual(name)
  if nx_is_valid(visual) then
    visual.old_color = visual.Color
    visual.ShowBoundBox = true
    visual.Color = "255,255,0,0"
    nx_execute(nx_current(), "restore_visual", visual, 2)
  end
  return 1
end
