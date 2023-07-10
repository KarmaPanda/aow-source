require("custom_sender")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local LOGO_MAX_COUNT = 32
local FRAME_MAX_COUNT = 10
function main_form_init(self)
  self.Fixed = false
  self.MaxPreview = 5
  self.frame_path = nx_resource_path() .. "gui\\guild\\frame\\"
  self.logo_path = nx_resource_path() .. "gui\\guild\\logo\\"
  self.frame_begin = 0
  self.logo_begin = 0
  self.selected_frame = ""
  self.selected_logo = ""
  self.selected_color = "0,255,255,255"
  self.hue = 0
  self.sat = 1
  self.bri = 1
end
function on_main_form_open(self)
  self.frame_array = nx_call("util_gui", "get_arraylist", nx_current() .. "_frame_array")
  local temp_frame_array = nx_call("util_gui", "get_arraylist", nx_current() .. "_frame_array")
  self.frame_array = temp_frame_array
  load_image_to_array(self.frame_array, self.frame_path, "ini\\Guild\\guild_frame.ini", FRAME_MAX_COUNT)
  local temp_logo_array = nx_call("util_gui", "get_arraylist", nx_current() .. "_logo_array")
  self.logo_array = temp_logo_array
  load_image_to_array(self.logo_array, self.logo_path, "ini\\Guild\\guild_logo.ini", LOGO_MAX_COUNT)
  self.btn_frame_pre.Enabled = false
  self.btn_logo_pre.Enabled = false
  init_ctrl(self.textgrid_frame, self.MaxPreview)
  init_ctrl(self.textgrid_logo, self.MaxPreview)
  show_thumbnail(self.textgrid_frame, self.frame_array, 0)
  show_thumbnail(self.textgrid_logo, self.logo_array, 0)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  setup_color_board(self)
  custom_guild_get_logo()
  return 1
end
function on_main_form_close(self)
  self.logo_array:ClearChild()
  self.frame_array:ClearChild()
  nx_destroy(self.frame_array)
  nx_destroy(self.logo_array)
  nx_destroy(self)
end
function setup_color_board(form)
  local world = nx_value("world")
  local edit_color = world:Create("EditColor")
  edit_color:MakeColorTex("inner_tex:color_hue_sat", 256, 256)
  edit_color:MakeBrightTex("inner_tex:color_bright", 16, 256, form.hue, form.sat)
  form.trackrect_color.BackImage = "inner_tex:color_hue_sat,0,0,256,256"
  form.trackrect_color.DrawMode = ""
  form.tbar_bright.BackImage = "inner_tex:color_bright,0,0,16,256"
  form.tbar_bright.TrackButton.Height = 8
  world:Delete(edit_color)
end
function on_trackrect_color_horizon_changed(self)
  local form = self.ParentForm
  if nx_is_valid(form) then
    form.hue = nx_number(self.HorizonValue) / 360
    set_bright_color(form)
    update_selected_color(form)
  end
end
function on_trackrect_color_vertical_changed(self)
  local form = self.ParentForm
  if nx_is_valid(form) then
    form.sat = 1 - nx_number(self.VerticalValue) / 100
    set_bright_color(form)
    update_selected_color(form)
  end
end
function set_bright_color(form)
  local world = nx_value("world")
  local edit_color = world:Create("EditColor")
  edit_color:MakeBrightTex("inner_tex:color_bright", 16, 256, form.hue, form.sat)
  world:Delete(edit_color)
  return 1
end
function update_selected_color(form)
  local red, green, blue = nx_function("ext_hsb_to_rgb", form.hue, form.sat, form.bri)
  form.selected_color = "255," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
  form.groupbox_preview.BackColor = form.selected_color
end
function on_tbar_bright_value_changed(self)
  local form = self.ParentForm
  if nx_is_valid(form) then
    form.bri = 1 - nx_number(self.Value) / 100
    update_selected_color(form)
  end
end
function load_image_to_array(array, path, ini_path, count)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. ini_path
  if not ini:LoadFromFile() then
    return false
  end
  local section_table = ini:GetSectionList()
  for index = 1, count do
    local image_name = ini:ReadString(nx_string(section_table[1]), nx_string(index), nx_string(""))
    if not nx_is_valid(array) then
    end
    local data = array:CreateChild(nx_string(index - 1))
    data.image = path .. nx_string(image_name)
    data.file_name = image_name
  end
end
function init_ctrl(grid, max_count)
  local gui = nx_value("gui")
  grid:BeginUpdate()
  grid:ClearRow()
  grid:InsertRow(-1)
  for i = 0, max_count - 1 do
    local pic_ctrl = gui:Create("Picture")
    pic_ctrl.Width = 64
    pic_ctrl.Height = 64
    pic_ctrl.LineColor = "255, 255, 255, 255"
    pic_ctrl.NoFrame = true
    nx_bind_script(pic_ctrl, nx_current())
    nx_callback(pic_ctrl, "on_left_down", "picture_left_down")
    grid:SetGridControl(0, i, pic_ctrl)
  end
  grid:EndUpdate()
end
function show_thumbnail(grid, array, begin)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local begin_idx = begin
  local end_idx = begin + form.MaxPreview
  local total = array:GetChildCount()
  if nx_int(total) <= nx_int(form.MaxPreview) then
    begin_idx = 0
    end_idx = total
  elseif total < end_idx then
    begin_idx = total - form.MaxPreview
    end_idx = total
  end
  for i = 0, form.MaxPreview - 1 do
    local pic_ctrl = grid:GetGridControl(0, i)
    if nx_number(i) + nx_number(begin_idx) < nx_number(end_idx) then
      local item = array:GetChild(nx_string(i + begin_idx))
      pic_ctrl.Image = item.image
      pic_ctrl.file_name = item.file_name
    else
      pic_ctrl.Image = ""
      pic_ctrl.file_name = ""
    end
  end
end
function picture_left_down(self)
  local form = self.ParentForm
  if not nx_is_valid(self) then
    return
  end
  local grid = self.Parent
  if grid.Name == "textgrid_frame" then
    form.selected_frame = self.file_name
    form.pic_frame.Image = self.Image
  elseif grid.Name == "textgrid_logo" then
    form.selected_logo = self.file_name
    form.pic_logo.Image = self.Image
  end
end
function on_btn_frame_pre_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.frame_begin > 0 then
    form.frame_begin = form.frame_begin - 1
    show_thumbnail(form.textgrid_frame, form.frame_array, form.frame_begin)
    form.btn_frame_next.Enabled = true
    if form.frame_begin == 0 then
      btn.Enabled = false
    end
  end
end
function on_btn_frame_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local total = form.frame_array:GetChildCount()
  if total > form.frame_begin + 5 then
    form.frame_begin = form.frame_begin + 1
    show_thumbnail(form.textgrid_frame, form.frame_array, form.frame_begin)
    form.btn_frame_pre.Enabled = true
    if form.frame_begin + 5 == total then
      btn.Enabled = false
    end
  end
end
function on_btn_logo_pre_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.logo_begin > 0 then
    form.logo_begin = form.logo_begin - 1
    show_thumbnail(form.textgrid_logo, form.logo_array, form.logo_begin)
    form.btn_logo_next.Enabled = true
    if form.logo_begin == 0 then
      btn.Enabled = false
    end
  end
end
function on_btn_logo_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local total = form.logo_array:GetChildCount()
  if total > form.logo_begin + 5 then
    form.logo_begin = form.logo_begin + 1
    show_thumbnail(form.textgrid_logo, form.logo_array, form.logo_begin)
    form.btn_logo_pre.Enabled = true
    if form.logo_begin + 5 == total then
      btn.Enabled = false
    end
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local logo = form.selected_frame .. "#" .. form.selected_logo .. "#" .. form.selected_color
  custom_guild_set_logo(nx_string(logo))
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_recv_logo(logo)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_logo")
  if not nx_is_valid(form) then
    return
  end
  local logo_info = util_split_string(logo, "#")
  if table.getn(logo_info) == 3 then
    form.selected_frame = logo_info[1]
    form.selected_logo = logo_info[2]
    form.selected_color = logo_info[3]
    form.pic_frame.Image = nx_resource_path() .. "gui\\guild\\frame\\" .. logo_info[1]
    form.pic_logo.Image = nx_resource_path() .. "gui\\guild\\logo\\" .. logo_info[2]
    form.groupbox_preview.BackColor = logo_info[3]
  end
end
function on_btn_reset_logo_click(btn)
  local form = btn.ParentForm
  form.selected_frame = ""
  form.selected_logo = ""
  form.selected_color = "0,255,255,255"
  form.pic_frame.Image = ""
  form.pic_logo.Image = ""
  form.groupbox_preview.BackColor = "0,255,255,255"
end
