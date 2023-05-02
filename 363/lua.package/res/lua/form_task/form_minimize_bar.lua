require("theme")
local BTN_WIDTH = 100
local BTN_HEIGHT = 20
function main_form_init(self)
  self.Fixed = false
  self.script_file_name = nx_current()
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  local form = nx_value("status_form")
  self.Height = BTN_HEIGHT
  self.Width = 0
  self.Left = 0
  self.Top = gui.Height - form.Height - BTN_HEIGHT
  return 1
end
local get_container = function()
  local minimize_form = nx_value("minimize_form")
  if not nx_is_valid(minimize_form) then
    local gui = nx_value("gui")
    local form = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_minimize_bar.xml")
    form:Show()
    form.Visible = false
    nx_set_value("minimize_form", form)
    return form
  end
  return minimize_form
end
function create_custom_define_btn(x, y, name, form)
  local gui = nx_value("gui")
  local btn = CREATE_CONTROL("Button")
  btn.Left = x
  btn.Top = y
  btn.Width = BTN_WIDTH
  btn.Height = BTN_HEIGHT
  btn.NoFrame = true
  btn.BackColor = "0,0,0,0"
  btn.Text = nx_widestr(name)
  btn.form = form
  nx_bind_script(btn, nx_current())
  nx_callback(btn, "on_click", "on_btn_costom_define_minimize_click")
  gui.Desktop:Add(btn)
  form.Visible = false
end
function on_btn_costom_define_minimize_click(self)
  self.form.Visible = true
  local gui = nx_value("gui")
  gui:Delete(self)
end
local function create_btn(index, name, form)
  local gui = nx_value("gui")
  local btn = CREATE_CONTROL("Button")
  btn.Left = index * BTN_WIDTH
  btn.Top = 0
  btn.Width = BTN_WIDTH
  btn.Height = BTN_HEIGHT
  btn.NoFrame = true
  btn.BackColor = "0,0,0,0"
  btn.Text = nx_widestr(name)
  btn.form = form
  nx_bind_script(btn, nx_current())
  nx_callback(btn, "on_click", "on_btn_minimize_click")
  return btn
end
function on_btn_minimize_click(self)
  self.form.Visible = true
  nx_execute("form_task\\minimize_manager", "delete", self.form)
end
function update(minimize_form_array)
  local count = minimize_form_array:GetChildCount()
  local form = get_container()
  form:DeleteAll()
  form.Width = count * BTN_WIDTH
  for i = 0, count - 1 do
    local obj = minimize_form_array:GetChildByIndex(i)
    local btn = create_btn(i, obj.name, obj.form)
    form:Add(btn)
  end
  if 1 <= count then
    form.Visible = true
  else
    form.Visible = false
  end
  return 1
end
function on_gui_size(self, Width, height)
  local gui = nx_value("gui")
  local status_form = nx_value("status_form")
  if nx_is_valid(gui) and nx_is_valid(status_form) then
    self.Top = gui.Height - self.Height - status_form.Height
  end
end
