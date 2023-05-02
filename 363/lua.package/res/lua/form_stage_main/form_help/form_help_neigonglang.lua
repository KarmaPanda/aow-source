local BUTTON_NORMAL_IMAGE = "gui\\map\\minimap\\btn_neigong_normal.png"
local BUTTON_FOCUS_IMAGE = "gui\\map\\minimap\\btn_neigong_focus.png"
local BUTTON_PUSH_IMAGE = "gui\\map\\minimap\\btn_neiigong_push.png"
function main_form_init(form)
  form.Fixed = false
  form.page_index = 1
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.page_index = 1
  form.btn_ok.Visible = false
  form.btn_front.Visible = false
  form.groupbox_1.Visible = true
  form.groupbox_2.Visible = false
  form.groupbox_3.Visible = false
  form.groupbox_4.Visible = false
  form.btn_next.Left = 248
  form.btn_next.Top = 360
  return
end
function on_main_form_close(form)
  create_focus_pos_btn(BUTTON_NORMAL_IMAGE, BUTTON_FOCUS_IMAGE, BUTTON_PUSH_IMAGE)
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  create_focus_pos_btn(BUTTON_NORMAL_IMAGE, BUTTON_FOCUS_IMAGE, BUTTON_PUSH_IMAGE)
  return
end
function create_focus_pos_btn(normal_image, focus_image, push_image)
  local gui = nx_value("gui")
  local btn = gui.Desktop:Find("btn_neigong")
  if not nx_is_valid(btn) then
    btn = gui:Create("Button")
    btn.Name = "btn_neigong"
    btn.InSound = "MouseOn1"
    btn.ClickSound = "MouseClick1"
    gui.Desktop:Add(btn)
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_next_help_click")
  else
    btn.Visible = true
    gui.Desktop:ToFront(btn)
  end
  btn.NormalImage = normal_image
  btn.FocusImage = focus_image
  btn.PushImage = push_image
  btn.AutoSize = false
  btn.Visible = true
  btn.DrawMode = "FitWindow"
  btn.Left = nx_execute("form_stage_main\\form_main\\form_main_request", "get_begin_left")
  btn.Top = nx_execute("form_stage_main\\form_main\\form_main_request", "get_begin_top")
  btn.Width = 60
  btn.Height = 60
end
function on_btn_next_help_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", "wxsd,zhandouwf02,wuqingt03,wuqingt04")
  local gui = nx_value("gui")
  if nx_is_valid(btn) then
    btn.Visible = false
  end
  gui:Delete(btn)
end
function on_btn_front_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.page_index < 2 or form.page_index > 4 then
    return
  end
  local page = {
    form.groupbox_1,
    form.groupbox_2,
    form.groupbox_3,
    form.groupbox_4
  }
  page[form.page_index].Visible = false
  page[form.page_index - 1].Visible = true
  if form.page_index == 2 then
    form.btn_front.Visible = false
    form.btn_next.Left = 248
    form.btn_next.Top = 360
  end
  form.btn_ok.Visible = false
  form.btn_next.Visible = true
  form.page_index = form.page_index - 1
  return
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.page_index < 1 or form.page_index > 4 then
    return
  end
  if form.page_index == 3 then
    form.btn_next.Visible = false
    form.btn_ok.Visible = true
  end
  if form.page_index == 1 then
    form.btn_next.Left = 352
    form.btn_next.Top = 360
  end
  form.btn_front.Visible = true
  if form.page_index == 4 then
    return
  end
  local page = {
    form.groupbox_1,
    form.groupbox_2,
    form.groupbox_3,
    form.groupbox_4
  }
  page[form.page_index].Visible = false
  page[form.page_index + 1].Visible = true
  form.page_index = form.page_index + 1
  return
end
