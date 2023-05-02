require("util_gui")
require("define\\move_define")
require("util_functions")
local SuspendTable = {}
local SuspendFontTable = {
  Font_Image_damage = {},
  Font_Image_damage2 = {}
}
local SuspendTableSections = {}
local BalloonTrackList = {}
local BalloonTrackIndex = {other_damage_hp_normal = 1}
local lGroupBoxCount = 0
function on_init()
  ReadSuspendTable("ini\\ui\\fightword\\fightword.ini")
  ReadSuspendImageTable("ini\\ui\\fightword\\WordImage.ini")
end
function ReadBallTrack(FilePath)
  local ini = nx_execute("util_functions", "get_ini", FilePath)
  local sec_count = ini:GetSectionCount()
  BalloonTrackList = {}
  local index = 1
  BalloonTrackIndex = {}
  for i = 0, sec_count - 1 do
    local sect = ini:GetSectionByIndex(i)
    local TrackMode = {}
    local startcolor = ini:ReadString(nx_string(sect), "start_color", "255,255,255,255")
    local endcolor = ini:ReadString(nx_string(sect), "end_color", "255,255,255,255")
    local start_x = ini:ReadFloat(nx_string(sect), "start_x", 50)
    local start_y = ini:ReadFloat(nx_string(sect), "start_y", 0)
    local x_speed = ini:ReadFloat(nx_string(sect), "x_speed", 0)
    local y_speed = ini:ReadFloat(nx_string(sect), "y_speed", 0)
    local start_w = ini:ReadFloat(nx_string(sect), "start_w", 0)
    local start_h = ini:ReadFloat(nx_string(sect), "start_h", 0)
    local w_speed = ini:ReadFloat(nx_string(sect), "w_speed", 0)
    local h_speed = ini:ReadFloat(nx_string(sect), "h_speed", 0)
    local stoptime = ini:ReadFloat(nx_string(sect), "stoptime", 3)
    local movetime = ini:ReadFloat(nx_string(sect), "movetime", 3)
    local w_stop_speed = ini:ReadFloat(nx_string(sect), "w_stop_speed", 0)
    local h_stop_speed = ini:ReadFloat(nx_string(sect), "h_stop_speed", 0)
    local ax_speed = ini:ReadFloat(nx_string(sect), "ax_speed", 0)
    local ay_speed = ini:ReadFloat(nx_string(sect), "ay_speed", 0)
    local colorTime = ini:ReadFloat(nx_string(sect), "colorTime", 0)
    local OfsetY = ini:ReadFloat(nx_string(sect), "OfsetY", 0.8)
    TrackMode.startcolor = startcolor
    TrackMode.endcolor = endcolor
    TrackMode.start_x = start_x
    TrackMode.start_y = start_y
    TrackMode.x_speed = x_speed
    TrackMode.y_speed = y_speed
    TrackMode.start_w = start_w
    TrackMode.start_h = start_h
    TrackMode.w_speed = w_speed
    TrackMode.h_speed = h_speed
    TrackMode.stoptime = stoptime
    TrackMode.movetime = movetime
    TrackMode.w_stop_speed = w_stop_speed
    TrackMode.h_stop_speed = h_stop_speed
    TrackMode.ay_speed = ay_speed
    TrackMode.ax_speed = ax_speed
    TrackMode.colorTime = colorTime
    TrackMode.OfsetY = OfsetY
    BalloonTrackIndex[nx_string(sect)] = index
    index = index + 1
    table.insert(BalloonTrackList, TrackMode)
  end
end
function ReadSuspendImageTable(FilePath)
  local ini = nx_execute("util_functions", "get_ini", FilePath)
  local sec_count = ini:GetSectionCount()
  for i = 0, sec_count - 1 do
    local sect = ini:GetSectionByIndex(i)
    local SuspendImageTable = {
      char_1 = "",
      char_2 = "",
      char_3 = "",
      char_4 = "",
      char_5 = "",
      char_6 = "",
      char_7 = "",
      char_8 = "",
      char_9 = "",
      char_0 = "",
      ["char_+"] = "",
      ["char_-"] = ""
    }
    SuspendImageTable.char_1 = ini:ReadString(sect, "char_1", "")
    SuspendImageTable.char_2 = ini:ReadString(sect, "char_2", "")
    SuspendImageTable.char_3 = ini:ReadString(sect, "char_3", "")
    SuspendImageTable.char_4 = ini:ReadString(sect, "char_4", "")
    SuspendImageTable.char_5 = ini:ReadString(sect, "char_5", "")
    SuspendImageTable.char_6 = ini:ReadString(sect, "char_6", "")
    SuspendImageTable.char_7 = ini:ReadString(sect, "char_7", "")
    SuspendImageTable.char_8 = ini:ReadString(sect, "char_8", "")
    SuspendImageTable.char_9 = ini:ReadString(sect, "char_9", "")
    SuspendImageTable.char_0 = ini:ReadString(sect, "char_0", "")
    SuspendImageTable["char_+"] = ini:ReadString(sect, "char_+", "")
    SuspendImageTable["char_-"] = ini:ReadString(sect, "char_-", "")
    SuspendFontTable[sect] = SuspendImageTable
  end
end
function get_TrackInfoList()
  ReadBallTrack("ini\\ui\\fightword\\BalloonTrack.ini")
  return BalloonTrackList
end
function ReadSuspendTable(FilePath)
  local ini = nx_execute("util_functions", "get_ini", FilePath)
  ReadBallTrack("ini\\ui\\fightword\\BalloonTrack.ini")
  local index = 1
  local sec_count = ini:GetSectionCount()
  for i = 0, sec_count - 1 do
    local sect = ini:GetSectionByIndex(i)
    local offset = ini:ReadFloat(nx_string(sect), "offset", 0)
    local font = ini:ReadString(nx_string(sect), "font", "Font_Image_damage")
    local TrackMode = ini:ReadString(nx_string(sect), "TrackMode", "self_damage_hp_normal")
    local BackImage = ini:ReadString(nx_string(sect), "BackImage", "")
    local BackImageW = ini:ReadFloat(nx_string(sect), "BackImageW", 0)
    local BackImageH = ini:ReadFloat(nx_string(sect), "BackImageH", 0)
    local FontOffsetX = ini:ReadFloat(nx_string(sect), "FontOffsetX", 0)
    local FontOffsetY = ini:ReadFloat(nx_string(sect), "FontOffsetY", 0)
    local IsObjPos = ini:ReadFloat(nx_string(sect), "IsObjPos", 1)
    local Keyword = ini:ReadString(nx_string(sect), "Keyword", "normal")
    local balloon_control = {}
    local TrackModeName = nx_string(TrackMode) .. "_" .. nx_string(Keyword)
    balloon_control.TrackMode = TrackMode
    local TrackMode = BalloonTrackList[BalloonTrackIndex[TrackModeName]]
    if TrackMode == nil then
      nx_log("Not Find TrackMode " .. nx_string(TrackModeName))
      return
    end
    balloon_control.offset = offset / TrackMode.start_w
    balloon_control.font = font
    balloon_control.BackImage = BackImage
    balloon_control.BackImageW = BackImageW
    balloon_control.BackImageH = BackImageH
    balloon_control.FontOffsetY = FontOffsetY
    balloon_control.FontOffsetX = FontOffsetX
    balloon_control.IsObjPos = IsObjPos
    balloon_control.Keyword = Keyword
    SuspendTableSections[nx_string(sect)] = index
    index = index + 1
    table.insert(SuspendTable, balloon_control)
  end
end
function get_TrackInfo(TrackModeIndex, Keyword)
  TrackModeName = nx_string(TrackModeIndex) .. "_" .. nx_string(Keyword)
  local TrackMode = BalloonTrackList[BalloonTrackIndex[TrackModeName]]
  return TrackMode
end
function show_balloon(index, imagetext, target_ident, text)
  if text == nil then
    text = nx_string("")
  end
  if AddSprite(index, imagetext, text, target_ident) then
    return
  end
  ReadSuspendTable("ini\\ui\\fightword\\fightword.ini")
  local balloon = SuspendTable[SuspendTableSections[index]]
  if type(balloon) ~= "table" then
    return
  end
  local BalloonTrackMode = get_TrackInfo(balloon.TrackMode, balloon.Keyword)
  local labelList = {}
  local W = 0
  labelList, W = get_control(balloon, text)
  local index = 1
  index = index + 1
  local groupbox = get_groupbox(labelList, balloon)
  local gui = nx_value("gui")
  local MainForm = gui.Desktop
  MainForm:Add(groupbox)
  groupbox.Visible = true
  local start_x = 1
  local start_y = 1
  if balloon.IsObjPos == 1 then
    start_x, start_y = GetScreenPos(target_ident, BalloonTrackMode)
  elseif balloon.IsObjPos == 0 then
    start_x = BalloonTrackMode.start_x * gui.Width
    start_y = BalloonTrackMode.start_y * gui.Height
  end
  groupbox.Left = start_x
  groupbox.Top = start_y
  local ltime = BalloonTrackMode.stoptime + BalloonTrackMode.movetime
  local elapsetime = 0
  local millisecond
  if lGroupBoxCount == 1000 then
    lGroupBoxCount = 1
  end
  lGroupBoxCount = lGroupBoxCount + 1
  while true do
    elapsetime = elapsetime + nx_pause(0)
    millisecond = elapsetime
    if millisecond < BalloonTrackMode.stoptime then
      refresh_ControlListW(labelList, millisecond, 0, BalloonTrackMode.w_stop_speed, BalloonTrackMode.start_w, 0, balloon.offset, balloon.FontOffsetX, balloon.BackImageW)
      refresh_ControlListH(labelList, millisecond, 0, BalloonTrackMode.h_stop_speed, BalloonTrackMode.start_h, 0, balloon.BackImageH)
    else
      refresh_ball_info(groupbox, millisecond - BalloonTrackMode.stoptime, BalloonTrackMode.x_speed, BalloonTrackMode.y_speed, start_x, start_y, BalloonTrackMode.ax_speed, BalloonTrackMode.ay_speed)
      refresh_ControlListW(labelList, millisecond - BalloonTrackMode.stoptime, BalloonTrackMode.stoptime, BalloonTrackMode.w_speed, BalloonTrackMode.start_w, BalloonTrackMode.w_stop_speed, balloon.offset, balloon.FontOffsetX, balloon.BackImageW)
      refresh_ControlListH(labelList, millisecond - BalloonTrackMode.stoptime, BalloonTrackMode.stoptime, BalloonTrackMode.h_speed, BalloonTrackMode.start_h, BalloonTrackMode.h_stop_speed, balloon.BackImageH)
    end
    refresh_labelListColor(labelList, elapsetime - BalloonTrackMode.colorTime, ltime - BalloonTrackMode.colorTime, BalloonTrackMode.startcolor, BalloonTrackMode.endcolor)
    refresh_GroupBoxAlpha(groupbox, elapsetime - BalloonTrackMode.colorTime, ltime - BalloonTrackMode.colorTime, BalloonTrackMode.startcolor, BalloonTrackMode.endcolor)
    if ltime < millisecond then
      MainForm:Remove(groupbox)
      return
    end
  end
end
function GetScreenPos(target_ident, offsetY)
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_scene_obj) then
    return -200, -200
  end
  local game_scene = visual_scene_obj.scene
  local x, y = game_scene.camera:GetScreenPos(visual_scene_obj.PositionX, visual_scene_obj.PositionY + visual_scene_obj.BoxSizeY * offsetY, visual_scene_obj.PositionZ)
  return x - 30, y
end
function refresh_labelListColor(labelList, elapsetime, totaltime, startcolor, endcolor)
  for i, label in pairs(labelList) do
    if nx_is_valid(label) then
      if 0 < elapsetime then
        label.BlendColor = get_color(elapsetime, totaltime, startcolor, endcolor)
      else
        label.BlendColor = get_color(0, 0, startcolor, startcolor)
      end
    end
  end
end
function refresh_GroupBoxAlpha(GroupBox, elapsetime, totaltime, startcolor, endcolor)
  if nx_is_valid(GroupBox) then
    if 0 < elapsetime then
      GroupBox.BlendAlpha = get_Alpha(elapsetime, totaltime, startcolor, endcolor)
    else
      GroupBox.BlendAlpha = get_Alpha(0, 0, startcolor, startcolor)
    end
  end
end
function get_color(elapsetime, totaltime, startcolor, endcolor)
  local Value = fuct(elapsetime, totaltime)
  local r = Value * (get_color_monomer(endcolor, "r") - get_color_monomer(startcolor, "r")) + get_color_monomer(startcolor, "r")
  local g = Value * (get_color_monomer(endcolor, "g") - get_color_monomer(startcolor, "g")) + get_color_monomer(startcolor, "g")
  local b = Value * (get_color_monomer(endcolor, "b") - get_color_monomer(startcolor, "b")) + get_color_monomer(startcolor, "b")
  return nx_string("255" .. "," .. r .. "," .. g .. "," .. b)
end
function get_Alpha(elapsetime, totaltime, startcolor, endcolor)
  local Value = fuct(elapsetime, totaltime)
  local a = Value * (get_color_monomer(endcolor, "a") - get_color_monomer(startcolor, "a")) + get_color_monomer(startcolor, "a")
  return a
end
function get_color_monomer(color, colortype)
  local tuple = util_split_string(color, ",")
  local index = 1
  if nx_ws_equal(nx_widestr(colortype), nx_widestr("a")) then
    index = 1
  elseif nx_ws_equal(nx_widestr(colortype), nx_widestr("r")) then
    index = 2
  elseif nx_ws_equal(nx_widestr(colortype), nx_widestr("g")) then
    index = 3
  elseif nx_ws_equal(nx_widestr(colortype), nx_widestr("b")) then
    index = 4
  end
  return nx_int(tuple[index])
end
function fuct(Value, maxValue)
  if maxValue == 0 then
    return 0
  end
  return Value / maxValue
end
function refresh_ball_info(ball, elapsetime, x_speed, y_speed, start_x, start_y, ax_speed, ay_speed)
  local ax_v = ax_speed * elapsetime
  local ay_v = ay_speed * elapsetime
  if nx_is_valid(ball) then
    ball.Left = start_x + elapsetime * x_speed + ax_v * elapsetime
    ball.Top = start_y + elapsetime * y_speed + ay_v * elapsetime
  end
end
function refresh_ControlListW(labelList, elapsetime, oldelapsetime, w_speed, start_w, oldw_speed, offset, FontOffsetX, BackImageW)
  local W = 0
  for i, label in pairs(labelList) do
    if nx_is_valid(label) then
      label.Width = start_w + w_speed * elapsetime + oldw_speed * oldelapsetime
      label.Left = W + offset * W + FontOffsetX
      W = W + label.Width
    end
  end
end
function refresh_ControlListH(labelList, elapsetime, oldelapsetime, h_speed, start_h, oldh_speed, BackImageH)
  for i, label in pairs(labelList) do
    if nx_is_valid(label) then
      label.Height = start_h + h_speed * elapsetime + oldh_speed * oldelapsetime
    end
  end
end
function get_control(balloon_control, text)
  ReadSuspendImageTable("ini\\ui\\fightword\\WordImage.ini")
  local control_list = {}
  local gui = nx_value("gui")
  local Left = balloon_control.FontOffsetX
  local Top = balloon_control.FontOffsetY
  font = SuspendFontTable[balloon_control.font]
  for i = 1, nx_ws_length(nx_widestr(text)) do
    text = nx_string(text)
    local ImageBack = nx_string(font[nx_string("char_" .. string.sub(text, i, i))])
    local label = CreateLabel(gui, i, Left, Top, balloon_control.start_w, balloon_control.start_h, ImageBack, 0)
    Left = Left + label.Width
    table.insert(control_list, label)
  end
  return control_list, Left
end
function CreateLabel(gui, NameIndex, x, y, w, h, BackImage)
  local label = gui:Create("Label")
  label.Name = nx_string(NameIndex)
  label.DrawMode = "FitWindow"
  label.BackImage = BackImage
  label.Left = x
  label.Top = y
  label.Width = w
  label.Height = h
  label.AutoSize = false
  label.ForeColor = "0,0,0,0"
  label.Font = "FIGHT24_O"
  return label
end
function get_groupbox(control_list, balloon)
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  groupbox.Name = "groupbox_" .. nx_string(lGroupBoxCount)
  groupbox.NoFrame = true
  groupbox.ForeColor = "0,0,0,0"
  groupbox.BackColor = "0,0,0,0"
  groupbox.Height = 58
  groupbox.Width = 241
  groupbox.Left = 0
  groupbox.Top = 0
  if 0 < nx_ws_length(nx_widestr(balloon.BackImage)) then
    local label = CreateLabel(gui, "BackImage", 0, 0, balloon.BackImageW, balloon.BackImageH, balloon.BackImage)
    groupbox:Add(label)
  end
  nx_set_value("groupbox_1", groupbox)
  for i, sect in pairs(control_list) do
    groupbox:Add(sect)
  end
  return groupbox
end
function get_ball(groupbox, target_ident)
  local gui = nx_value("gui")
  groupbox.Visible = true
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(target_ident)
  if not nx_is_valid(visual_scene_obj) then
    nx_msgbox("nx_null()")
    return nx_null()
  end
  local balls = nx_value("balls")
  balls.UseDepth = 0
  local ball = balls:AddBalloon(groupbox, visual_scene_obj, 3)
  ball.Name = "SuspendManager:get_ball" .. nx_string(visual_scene_obj)
  ball.BindY = visual_scene_obj.height
  ball.NearDistance = 0
  ball.FarDistance = 200
  ball.Control.model = visual_scene_obj
  ball.MustVisible = true
  ball.Control.Text = ""
  ball.Control.ForeColor = "255," .. "220,220,56"
  ball.OffsetLeft = 0
  ball.OffsetTop = 0
  return ball
end
function delete_balloon(ball)
  if not nx_is_valid(ball) then
    return
  end
  local gui = nx_value("gui")
  local balls = nx_value("balls")
  gui:Delete(ball.Control)
  balls:DeleteBalloon(ball)
end
function set_TrackMode_Keyword(Keyword)
  for i, TrackMode in pairs(BalloonTrackList) do
    TrackMode.Keyword = Keyword
  end
end
function AddSprite(index, imagetext, text, target_ident)
  local gui = nx_value("gui")
  local SpriteManager = nx_value("SpriteManager")
  local PoolSize = SpriteManager.PoolSize + 1
  local Sprite
  for i = 1, PoolSize do
    Sprite = SpriteManager:GetSpriteID(i - 1)
    if not nx_is_valid(Sprite) then
      Sprite = gui:Create("Sprite")
      break
    end
    if not Sprite.bPaint then
      break
    end
  end
  if not nx_is_valid(Sprite) then
    return 0
  end
  do return 0 end
  Sprite.Name = nx_string(1)
  local posx, posy = GetScreenPos(target_ident, 0.6)
  local ok = SpriteManager:OnAdd(index, nx_string(imagetext), nx_string(text), Sprite, posx, posy, true)
  if nx_int(ok) ~= nx_int(0) then
    local MainForm = gui.Desktop
    MainForm:Add(Sprite)
  end
  return true
end
