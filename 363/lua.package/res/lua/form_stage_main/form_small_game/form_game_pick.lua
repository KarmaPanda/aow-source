require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_small_game\\form_game_pick"
local timelimit = 20
local formtimelimit = 0
local pooltop = 0
local poolwidthsingle = 0
local poolheightsingle = 0
local picktop = 0
local targettop = 0
local width = 0
local height = 0
local poolnum = 0
local picknum = 0
local pickmargin = 0
local photoempty = 0
local photolist = {}
local poollist = {}
local targetlist = {}
local labellist = {}
local picklist = {}
local dragleft = 0
local dragtop = 0
local dragright = 0
local dragbottom = 0
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
  self.btn_ok.Visible = false
  self.is_start = false
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_form_time", self, -1, -1)
end
function on_update_form_time(form)
  if nx_int(form.formtimelimit) == nx_int(0) then
    close_form()
    return
  end
  form.formtimelimit = nx_widestr(nx_int(form.formtimelimit) - 1)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", self)
    timer:UnRegister(nx_current(), "on_update_form_time", self)
  end
  local ret = check_result()
  nx_execute("custom_sender", "custom_ancient_tomb_sender", 1, nx_int(ret))
  nx_destroy(self)
end
function open_form_by_diff(diff)
  if load_resource(diff) == false then
    return
  end
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  load_resource(diff)
  init_form()
  form.Visible = true
  form:Show()
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_start_click(btn)
  btn.ParentForm.is_start = 1
  local form = btn.ParentForm
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
  btn.Visible = false
  form.btn_ok.Visible = true
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_ok_click(btn)
  close_form()
end
function on_pic_left_down(pic)
  if not pic.ParentForm.is_start then
    return
  end
  pic.x = pic.Left
  pic.y = pic.Top
end
function on_pic_left_up(pic)
  if not pic.ParentForm.is_start then
    return
  end
  local index = get_pick_index(pic.x, pic.y)
  if 0 < index then
    picklist[index] = nil
  end
  if pic.Top >= picktop - height and not check_in_pick_area(pic) then
    pic.Left = pic.x
    pic.Top = pic.y
  end
end
function on_pic_drag_move(pic, x, y)
  if not pic.ParentForm.is_start then
    return
  end
  local tempx = pic.Left + x
  local tempy = pic.Top + y
  if tempy >= dragtop and tempy + height <= dragbottom and tempx >= dragleft and tempx + width <= dragright then
    pic.Left = tempx
    pic.Top = tempy
  end
end
function on_pic_drag_leave(pic, x, y)
end
function on_update_time(form)
  if nx_int(form.lbl_time.Text) == nx_int(0) then
    close_form()
    return
  end
  form.lbl_time.Text = nx_widestr(nx_int(form.lbl_time.Text) - 1)
  form.pbar_1.Value = nx_int(form.lbl_time.Text)
end
function load_resource(diff)
  local ini = get_ini("share\\Life\\PickGame.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(diff))
  if sec_index < 0 then
    return false
  end
  timelimit = ini:ReadInteger(sec_index, "timelimit", 0)
  formtimelimit = ini:ReadInteger(sec_index, "formtimelimit", 0)
  pooltop = ini:ReadInteger(sec_index, "pooltop", 0)
  poolwidthsingle = ini:ReadInteger(sec_index, "poolwidthsingle", 0)
  poolheightsingle = ini:ReadInteger(sec_index, "poolheightsingle", 0)
  picktop = ini:ReadInteger(sec_index, "picktop", 0)
  targettop = ini:ReadInteger(sec_index, "targettop", 0)
  width = ini:ReadInteger(sec_index, "width", 0)
  height = ini:ReadInteger(sec_index, "height", 0)
  poolnum = ini:ReadInteger(sec_index, "poolnum", 0)
  picknum = ini:ReadInteger(sec_index, "picknum", 0)
  pickmargin = ini:ReadInteger(sec_index, "pickmargin", 0)
  photoempty = ini:ReadString(sec_index, "photoempty", "")
  dragleft = ini:ReadInteger(sec_index, "drogleft", 0)
  dragtop = ini:ReadInteger(sec_index, "dragtop", 0)
  dragright = ini:ReadInteger(sec_index, "dragright", 0)
  dragbottom = ini:ReadInteger(sec_index, "dragbottom", 0)
  photolist = {}
  for i = 1, 100 do
    local photo = ini:ReadString(sec_index, "photo" .. nx_string(i), "")
    if nx_string(photo) == nx_string("") then
      break
    end
    table.insert(photolist, nx_string(photo))
    local rand = math.random(1, nx_number(table.getn(photolist)))
    local temp = photolist[rand]
    photolist[rand] = photolist[table.getn(photolist)]
    photolist[table.getn(photolist)] = temp
  end
  return true
end
function init_form()
  init_bind_callback()
  init_time()
  RandomPool()
  RandomTarget()
  create_pick_pool()
  create_photo_pool()
  create_target_pool()
end
function init_bind_callback()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  nx_bind_script(form.btn_ok, nx_current())
  nx_callback(form.btn_ok, "on_click", "on_btn_ok_click")
  nx_bind_script(form.btn_close, nx_current())
  nx_callback(form.btn_close, "on_click", "on_btn_close_click")
  nx_bind_script(form.btn_start, nx_current())
  nx_callback(form.btn_start, "on_click", "on_btn_start_click")
end
function init_time()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.formtimelimit = formtimelimit
  form.lbl_time.Text = nx_widestr(timelimit)
  form.pbar_1.Maximum = timelimit
  form.pbar_1.Minimum = 0
  form.pbar_1.Value = timelimit
end
function RandomPool()
  local count = table.getn(photolist)
  local index = math.random(1, nx_number(count))
  poollist = {}
  for i = 1, poolnum do
    local real = (index + i - 1) % count + 1
    table.insert(poollist, photolist[real])
    local rand = math.random(1, nx_number(table.getn(poollist)))
    local temp = poollist[rand]
    poollist[rand] = poollist[table.getn(poollist)]
    poollist[table.getn(poollist)] = temp
  end
end
function RandomTarget()
  local templist = {}
  for i = 1, table.getn(poollist) do
    table.insert(templist, poollist[i])
    local rand = math.random(1, nx_number(table.getn(templist)))
    local temp = templist[rand]
    templist[rand] = templist[table.getn(templist)]
    templist[table.getn(templist)] = temp
  end
  local index = math.random(1, nx_number(table.getn(templist)))
  targetlist = {}
  for i = 1, picknum do
    local real = (i + index - 1) % table.getn(templist) + 1
    table.insert(targetlist, templist[real])
  end
end
function create_photo_pool()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local cols = math.floor(form.groupbox_main.Width / poolwidthsingle)
  for i = 1, table.getn(poollist) do
    local row = math.floor((i - 1) / cols) + 1
    local col = (i - 1) % cols + 1
    local x = (col - 1) * poolwidthsingle + math.random(1, nx_number(poolwidthsingle - width)) + 20
    local y = (row - 1) * poolheightsingle + math.random(1, nx_number(poolheightsingle - height))
    local pic = gui:Create("Picture")
    pic.Left = x
    pic.Top = pooltop + y
    pic.Width = width
    pic.Height = height
    pic.NoFrame = true
    pic.Image = poollist[i]
    nx_bind_script(pic, nx_current())
    nx_callback(pic, "on_drag_move", "on_pic_drag_move")
    nx_callback(pic, "on_drag_leave", "on_pic_drag_leave")
    nx_callback(pic, "on_left_down", "on_pic_left_down")
    nx_callback(pic, "on_left_up", "on_pic_left_up")
    form.groupbox_main:Add(pic)
  end
end
function create_pick_pool()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local base_left = (form.groupbox_main.Width - width * picknum - pickmargin * (picknum - 1)) / 2
  labellist = {}
  picklist = {}
  for i = 1, picknum do
    local lbl = gui:Create("Label")
    lbl.Left = base_left + (i - 1) * (width + pickmargin)
    lbl.Top = picktop
    lbl.Width = width
    lbl.Height = height
    lbl.BackImage = photoempty
    lbl.DrawMode = FitWindow
    form.groupbox_main:Add(lbl)
    table.insert(labellist, lbl)
    table.insert(picklist, nil)
  end
end
function create_target_pool()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local base_left = (form.groupbox_main.Width - width * picknum - pickmargin * (picknum - 1)) / 2
  for i = 1, table.getn(targetlist) do
    local lbl = gui:Create("Label")
    lbl.Left = base_left + (i - 1) * (width + pickmargin)
    lbl.Top = targettop
    lbl.Width = width
    lbl.Height = height
    lbl.BackImage = targetlist[i]
    lbl.DrawMode = FitWindow
    form.groupbox_main:Add(lbl)
  end
end
function check_in_pick_area(pic)
  local x = pic.Left
  local y = pic.Top
  for i = 1, table.getn(labellist) do
    local old_pic = check_pick(i)
    local lbl = labellist[i]
    if x < lbl.Left + width and x + width > lbl.Left and y < lbl.Top + height and y + height > lbl.Top then
      pic.Left = lbl.Left
      pic.Top = lbl.Top
      if nx_is_valid(old_pic) then
        old_pic.Left = pic.x
        old_pic.Top = pic.y
        local index = get_pick_index(old_pic.Left, old_pic.Top)
        if 0 < index then
          picklist[index] = old_pic
        end
      end
      picklist[i] = pic
      local form = pic.ParentForm
      if nx_is_valid(form) then
        form.groupbox_main:ToFront(pic)
      end
      return true
    end
  end
  return false
end
function check_pick(index)
  return picklist[index]
end
function get_pick_index(x, y)
  for i = 1, table.getn(labellist) do
    local lbl = labellist[i]
    if nx_is_valid(lbl) and lbl.Left == x and lbl.Top == y then
      return i
    end
  end
  return 0
end
function check_result()
  for i = 1, picknum do
    local pic = picklist[i]
    if not nx_is_valid(pic) then
      return 0
    end
    if pic.Image ~= targetlist[i] then
      return 0
    end
  end
  return 1
end
function custom_sender(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(773), unpack(arg))
end
