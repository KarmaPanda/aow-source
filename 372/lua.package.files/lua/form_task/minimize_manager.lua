require("theme")
local MIN_MAX_CLOSE_COM_WIDTH = 25
local MIN_MAX_CLOSE_COM_HEIGHT = 20
local MIN_MAX_CLOSE_COM_OFFSET = 10
local COM_COUNT = 3
local function create_btn(text, left, top, is_enable)
  local gui = nx_value("gui")
  local btn = CREATE_CONTROL("Button")
  btn.Left = left
  btn.Top = top
  btn.Width = MIN_MAX_CLOSE_COM_WIDTH
  btn.Height = MIN_MAX_CLOSE_COM_HEIGHT
  btn.NoFrame = true
  btn.ForeColor = "255,255,255,255"
  btn.Text = nx_widestr(text)
  btn.NormalImage = "skin\\png\\common\\button\\button_out.png"
  btn.FocusImage = "skin\\png\\common\\button\\button_on.png"
  btn.PushImage = "skin\\png\\common\\button\\button_down.png"
  btn.DrawMode = "Expand"
  btn.Enabled = is_enable
  return btn
end
local function create_com_group(left, top)
  local gui = nx_value("gui")
  local group_box = CREATE_CONTROL("GroupBox")
  group_box.Left = left
  group_box.Top = top
  group_box.Width = MIN_MAX_CLOSE_COM_WIDTH * COM_COUNT
  group_box.Height = MIN_MAX_CLOSE_COM_HEIGHT
  group_box.Text = nx_widestr("")
  group_box.BackColor = "0,0,0,0"
  group_box.LineColor = "0,0,0,0"
  return group_box
end
function create_min_max_close_component(form, has_min_box, has_max_box, has_close_box, align_mode)
  local com_left = MIN_MAX_CLOSE_COM_OFFSET
  local com_top = MIN_MAX_CLOSE_COM_OFFSET
  if align_mode == "Left" then
  elseif align_mode == "Right" then
    com_left = form.Width - MIN_MAX_CLOSE_COM_WIDTH * COM_COUNT - MIN_MAX_CLOSE_COM_OFFSET
  end
  local min_btn = create_btn("-", MIN_MAX_CLOSE_COM_WIDTH * 0, 0, has_min_box)
  local max_btn = create_btn("\191\218", MIN_MAX_CLOSE_COM_WIDTH * 1, 0, has_max_box)
  local close_btn = create_btn("x", MIN_MAX_CLOSE_COM_WIDTH * 2, 0, has_close_box)
  local group = create_com_group(com_left, com_top)
  group:Add(min_btn)
  group:Add(max_btn)
  group:Add(close_btn)
  group.min_btn = min_btn
  group.max_btn = max_btn
  group.close_btn = close_btn
  form:Add(group)
  form.min_max_close_component = group
  nx_bind_script(min_btn, nx_current())
  nx_callback(min_btn, "on_click", "default_process_min_btn_method")
  nx_bind_script(max_btn, nx_current())
  nx_callback(max_btn, "on_click", "default_process_max_btn_method")
  nx_bind_script(close_btn, nx_current())
  nx_callback(close_btn, "on_click", "default_process_close_btn_method")
  return group
end
function default_process_min_btn_method(self)
  if false == nx_find_custom(self, "name") then
    self.name = "...."
  end
  add(self.ParentForm, self.name)
  self.ParentForm.Visible = false
  return 1
end
function default_process_max_btn_method(self)
  if false == nx_find_custom(self, "aim_width") or false == nx_find_custom(self, "aim_height") then
    return 0
  end
  local form = self.ParentForm
  local previous_width = form.Width
  local previous_height = form.Height
  form.Width = self.aim_width
  form.Height = self.aim_height
  self.aim_width = previous_width
  self.aim_height = previous_height
  if self.Text == nx_widestr("\191\218") then
    self.Text = nx_widestr("\194\192")
  else
    self.Text = nx_widestr("\191\218")
  end
  return 1
end
function default_process_close_btn_method(self)
  local form = self.ParentForm
  form:Close()
  nx_destroy(form)
  return 1
end
local get_array = function()
  local minimize_form_array = nx_value("minimize_form_array")
  if not nx_is_valid(minimize_form_array) then
    minimize_form_array = nx_create("ArrayList", "minimize_form_array")
    nx_set_value("minimize_form_array", minimize_form_array)
  end
  return minimize_form_array
end
local function get_minimize_form_index(form)
  local minimize_form_array = get_array()
  local count = minimize_form_array:GetChildCount()
  for i = 0, count - 1 do
    local child = minimize_form_array:GetChildByIndex(i)
    if nx_id_equal(form, child.form) then
      return i
    end
  end
  return -1
end
local update_minimize_bar = function(minimize_form_array)
  nx_execute("form_task\\form_minimize_bar", "update", minimize_form_array)
  return 1
end
function add(form, text)
  if not nx_is_valid(form) then
    return 0
  end
  local minimize_form_array = get_array()
  if is_exist(form) then
    return 0
  end
  local name = nx_function("ext_gen_unique_name")
  local child = minimize_form_array:CreateChild(name)
  child.form = form
  child.name = text
  update_minimize_bar(minimize_form_array)
  return 1
end
function is_exist(form)
  if get_minimize_form_index(form) == -1 then
    return false
  end
  return true
end
function delete(form)
  if not nx_is_valid(form) then
    return 0
  end
  local index = get_minimize_form_index(form)
  if index == -1 then
    return 0
  end
  local minimize_form_array = get_array()
  minimize_form_array:RemoveChildByIndex(index)
  update_minimize_bar(minimize_form_array)
  return 1
end
function clear()
  local minimize_form_array = get_array()
  minimize_form_array:ClearChild()
  update_minimize_bar(minimize_form_array)
  return 1
end
