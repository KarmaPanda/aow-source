require("util_gui")
local FORM_NAME = "form_stage_main\\form_small_game\\form_game_baguapintu"
local image_random_sequence = {}
local edge_top = 0
local edge_left = 0
local edge_bootm = 0
local edge_right = 0
local form_limit_time = 120
local CTS_SUB_MSG_ANCIENTTOMB_JQ_BAGUAPINTU = 41
local image_info = {
  [1] = {
    path = "gui\\special\\baguatu\\down\\1.png",
    path_real = "gui\\special\\baguatu\\jiaodu\\1.png",
    left = 24,
    top = 10,
    width = 80,
    height = 40
  },
  [2] = {
    path = "gui\\special\\baguatu\\down\\2.png",
    path_real = "gui\\special\\baguatu\\jiaodu\\2.png",
    left = 112,
    top = 10,
    width = 80,
    height = 40
  },
  [3] = {
    path = "gui\\special\\baguatu\\down\\3.png",
    path_real = "gui\\special\\baguatu\\jiaodu\\3.png",
    left = 210,
    top = 10,
    width = 80,
    height = 40
  },
  [4] = {
    path = "gui\\special\\baguatu\\down\\4.png",
    path_real = "gui\\special\\baguatu\\jiaodu\\4.png",
    left = 302,
    top = 10,
    width = 80,
    height = 40
  },
  [5] = {
    path = "gui\\special\\baguatu\\down\\5.png",
    path_real = "gui\\special\\baguatu\\jiaodu\\5.png",
    left = 24,
    top = 60,
    width = 80,
    height = 40
  },
  [6] = {
    path = "gui\\special\\baguatu\\down\\6.png",
    path_real = "gui\\special\\baguatu\\jiaodu\\6.png",
    left = 112,
    top = 60,
    width = 80,
    height = 40
  },
  [7] = {
    path = "gui\\special\\baguatu\\down\\7.png",
    path_real = "gui\\special\\baguatu\\jiaodu\\7.png",
    left = 208,
    top = 60,
    width = 80,
    height = 40
  },
  [8] = {
    path = "gui\\special\\baguatu\\down\\8.png",
    path_real = "gui\\special\\baguatu\\jiaodu\\8.png",
    left = 304,
    top = 60,
    width = 80,
    height = 40
  },
  [9] = {
    path = "gui\\special\\baguatu\\back.png",
    left = 80,
    top = 120,
    width = 240,
    height = 240
  }
}
local target_location_info = {
  [1] = {
    left = 160,
    top = 130,
    width = 80,
    height = 36
  },
  [2] = {
    left = 233,
    top = 136,
    width = 72,
    height = 72
  },
  [3] = {
    left = 273,
    top = 199,
    width = 36,
    height = 80
  },
  [4] = {
    left = 234,
    top = 272,
    width = 72,
    height = 73
  },
  [5] = {
    left = 160,
    top = 314,
    width = 80,
    height = 36
  },
  [6] = {
    left = 94,
    top = 272,
    width = 71,
    height = 73
  },
  [7] = {
    left = 88,
    top = 198,
    width = 39,
    height = 80
  },
  [8] = {
    left = 94,
    top = 134,
    width = 71,
    height = 72
  }
}
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.is_start = false
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_time_click", self)
  end
  nx_destroy(self)
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local ret = check_result(form)
  if nx_int(ret) == nx_int(0) then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("zyb_yx_001"), 2)
    end
  else
    nx_execute("custom_sender", "custom_ancient_tomb_sender", nx_int(CTS_SUB_MSG_ANCIENTTOMB_JQ_BAGUAPINTU), nx_int(ret))
  end
  form:Close()
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.right_count = 0
  form.is_start = true
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_time_click", form, -1, -1)
  form.total_time = form_limit_time
  form.pbar_1.Maximum = form_limit_time
  form.pbar_1.Minimum = 0
  form.pbar_1.Value = form_limit_time
  btn.Visible = false
end
function on_btn_ok_click(btn)
  if not btn.ParentForm.is_start then
    return
  end
  close_form()
end
function on_btn_close_click(btn)
  close_form()
end
function on_time_click(self)
  self.total_time = self.total_time - 1
  self.pbar_1.Value = self.total_time
  if nx_int(self.total_time) == nx_int(0) then
    close_form()
  end
end
function open_form_baguapintu()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  edge_top = 0
  edge_left = 0
  edge_bottom = 400
  edge_right = 400
  random_image_order()
  update_form(form)
  form.right_count = 0
  form.Visible = true
  form:Show()
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
  if not check_in_right_area(pic) then
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
  if tempy >= edge_top and tempy + pic.Height <= edge_bottom and tempx >= edge_left and tempx + pic.Width <= edge_right then
    pic.Left = tempx
    pic.Top = tempy
  end
end
function update_form(self)
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  for i = 1, 8 do
    local pic = gui:Create("Picture")
    local index = image_random_sequence[i]
    pic.NoFrame = true
    pic.Left = image_info[i].left
    pic.Top = image_info[i].top
    pic.Image = image_info[index].path
    pic.Width = image_info[nx_number(index)].width
    pic.Height = image_info[nx_number(index)].height
    pic.index = index
    nx_bind_script(pic, nx_current())
    nx_callback(pic, "on_drag_move", "on_pic_drag_move")
    nx_callback(pic, "on_left_down", "on_pic_left_down")
    nx_callback(pic, "on_left_up", "on_pic_left_up")
    self.groupbox_main:Add(pic)
  end
  self.lbl_bagua.BackImage = image_info[nx_number(9)].path
  self.lbl_bagua.Left = image_info[nx_number(9)].left
  self.lbl_bagua.Top = image_info[nx_number(9)].top
  self.lbl_bagua.Width = image_info[nx_number(9)].width
  self.lbl_bagua.Height = image_info[nx_number(9)].height
end
function random_image_order()
  math.randomseed(os.time())
  image_random_sequence = {
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8
  }
  for i = 1, 10 do
    local index_1 = math.random(8)
    local index_2 = math.random(8)
    if index_1 ~= index_2 then
      local temp = image_random_sequence[nx_number(index_1)]
      image_random_sequence[nx_number(index_1)] = image_random_sequence[nx_number(index_2)]
      image_random_sequence[nx_number(index_2)] = temp
    end
  end
end
function check_in_right_area(pic)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return false
  end
  local index = pic.index
  local top = target_location_info[index].top
  local left = target_location_info[index].left
  local width = target_location_info[index].width
  local height = target_location_info[index].height
  local pic_centerx = pic.Left + pic.Width / 2
  local pic_centery = pic.Top + pic.Height / 2
  if left <= pic_centerx and pic_centerx <= left + width and top <= pic_centery and pic_centery <= top + height then
    pic.Left = left
    pic.Top = top
    pic.Width = width
    pic.Height = height
    pic.Image = image_info[index].path_real
    form.right_count = form.right_count + 1
    return true
  end
  return false
end
function check_result(self)
  if nx_int(self.right_count) < nx_int(8) then
    return 0
  end
  return 1
end
