require("util_gui")
require("util_functions")
local image_path = "gui\\language\\ChineseS\\tarot"
local card_nums = 22
local card_pre_line = 5
local card_pre_col = 2
local l_base = 57
local l_margin = 17
local t_base = 44
local t_margin = 48
local FORM_NAME = "form_stage_main\\form_tarot\\form_tarot_collect"
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.gb_card.Fixed = false
  form.gb_card.Visible = false
  form.page = 1
  init_rbtn(form)
  set_page(form, 1)
  nx_execute("custom_sender", "custom_tarot", 3)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function open_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    return
  end
  form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function test_form()
  update_form("22,1,1,1,2,1,1,3,1,1,4,1,1,5,1,1,6,1,1,7,1,1,8,1,1,9,1,1,10,1,1,11,1,1,12,1,1,13,1,1,14,1,1,15,1,1,16,1,1,17,1,1,18,1,1,19,1,1,20,1,1,21,1,1,22,1,1")
end
function on_esc()
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  if form.gb_card.Visible then
    form.gb_card.Visible = false
    local rbtn_temp = form.gb_collect:Find("rbtn_card_temp")
    if nx_is_valid(rbtn_temp) then
      rbtn_temp.Checked = true
    end
    return
  end
  close_form()
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_page_up_click(btn)
  local form = btn.ParentForm
  set_page(form, form.page - 1)
end
function on_btn_page_down_click(btn)
  local form = btn.ParentForm
  set_page(form, form.page + 1)
end
function on_rbtn_card_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_card.Visible = true
    local id_path = string.format("%02d", rbtn.id)
    form.lbl_card_main.BackImage = image_path .. "\\" .. id_path .. ".png"
    form.gb_card.id = rbtn.id
    form.lbl_card_time.Text = nx_widestr(get_time_text(rbtn.time))
  end
end
function on_rbtn_card_get_capture(rbtn)
  local form = rbtn.ParentForm
  form.lbl_capture.AbsLeft = rbtn.AbsLeft - (form.lbl_capture.Width - rbtn.Width) / 2
  form.lbl_capture.AbsTop = rbtn.AbsTop - (form.lbl_capture.Height - rbtn.Height) / 2
end
function on_rbtn_card_lost_capture(rbtn)
  local form = rbtn.ParentForm
  form.lbl_capture.AbsLeft = 9999
  form.lbl_capture.AbsTop = 9999
end
function on_btn_card_close_click(btn)
  local form = btn.ParentForm
  form.gb_card.Visible = false
  local rbtn_temp = form.gb_collect:Find("rbtn_card_temp")
  if nx_is_valid(rbtn_temp) then
    rbtn_temp.Checked = true
  end
end
function update_form(...)
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  local info = nx_string(arg[1])
  local info_list = util_split_string(info)
  local rows = nx_number(info_list[1])
  for i = 1, rows do
    local id = nx_number(info_list[2 + (i - 1) * 3])
    local time = nx_double(info_list[3 + (i - 1) * 3])
    local nums = nx_number(info_list[4 + (i - 1) * 3])
    local rbtn_card = form.gb_collect:Find("rbtn_card_" .. nx_string(id))
    if nx_is_valid(rbtn_card) then
      rbtn_card.is_collect = true
      rbtn_card.time = time
      rbtn_card.nums = nums
      rbtn_card.Enabled = true
      local id_path = string.format("%02d", id)
      rbtn_card.BackImage = image_path .. "\\" .. id_path .. ".png"
    end
  end
end
function init_rbtn(form)
  for i = 1, card_nums do
    local rbtn_card = create_ctrl("RadioButton", "rbtn_card_" .. nx_string(i), form.rbtn_mod, form.gb_collect)
    nx_bind_script(rbtn_card, nx_current())
    nx_callback(rbtn_card, "on_checked_changed", "on_rbtn_card_checked_changed")
    nx_callback(rbtn_card, "on_get_capture", "on_rbtn_card_get_capture")
    nx_callback(rbtn_card, "on_lost_capture", "on_rbtn_card_lost_capture")
    rbtn_card.id = i
    rbtn_card.is_collect = false
    rbtn_card.Enabled = false
  end
  local rbtn_temp = create_ctrl("RadioButton", "rbtn_card_temp", form.rbtn_mod, form.gb_collect)
end
function set_page(form, page)
  for i = 1, card_nums do
    local rbtn_card = form.gb_collect:Find("rbtn_card_" .. nx_string(i))
    if nx_is_valid(rbtn_card) then
      rbtn_card.Left = form.rbtn_mod.Left
      rbtn_card.Top = form.rbtn_mod.Top
    end
  end
  local page_nums = math.floor((card_nums - 1) / (card_pre_line * card_pre_col)) + 1
  if page < 1 then
    page = 1
  elseif page_nums < page then
    page = page_nums
  end
  form.lbl_page.Text = nx_widestr(nx_string(page) .. "/" .. nx_string(page_nums))
  form.page = page
  form.btn_page_up.Enabled = true
  form.btn_page_down.Enabled = true
  if page == 1 then
    form.btn_page_up.Enabled = false
  end
  if page == page_nums then
    form.btn_page_down.Enabled = false
  end
  for i = 1, card_pre_line * card_pre_col do
    local id = (page - 1) * card_pre_line * card_pre_col + i
    local rbtn_card = form.gb_collect:Find("rbtn_card_" .. nx_string(id))
    if nx_is_valid(rbtn_card) then
      rbtn_card.Left = l_base + math.fmod(i - 1, card_pre_line) * (rbtn_card.Width + l_margin)
      rbtn_card.Top = t_base + math.floor((i - 1) / card_pre_line) * (rbtn_card.Height + t_margin)
    end
  end
end
function get_time_text(time)
  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", time)
  local time_text = string.format("%04d-%02d-%02d %02d:%02d", nx_number(year), nx_number(month), nx_number(day), nx_number(hour), nx_number(mins))
  return time_text
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function a(info)
  nx_msgbox(nx_string(info))
end
