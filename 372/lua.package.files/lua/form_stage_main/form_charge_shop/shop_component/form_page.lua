require("util_gui")
require("util_functions")
require("form_stage_main\\form_charge_shop\\shop_util")
local g_form_name = "form_stage_main\\form_charge_shop\\shop_component\\form_page"
local g_pages = 7
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  form.page = 1
  form.max_page = 1
  form.base_page = 0
  local g_page_items = {
    [1] = form.rbtn_page_1,
    [2] = form.rbtn_page_2,
    [3] = form.rbtn_page_3,
    [4] = form.rbtn_page_4,
    [5] = form.rbtn_page_5,
    [6] = form.rbtn_page_6,
    [7] = form.rbtn_page_7,
    [8] = form.rbtn_page_8,
    [9] = form.rbtn_page_9
  }
  for index, item in pairs(g_page_items) do
    nx_set_custom(item, "page", index)
    item.ForeColor = "255,255,127,0"
  end
end
function on_main_form_close(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function set_first_page_selected()
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local rbtn = form.rbtn_page_1
  if rbtn.Checked then
    set_cur_page(form, 1)
  else
    rbtn.Checked = true
  end
end
function set_max_page(item_count, breset)
  local maxpage = math.ceil(item_count / g_item_count_page)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  form.max_page = maxpage
  for i = 1, g_pages do
    local item = form["rbtn_page_" .. tostring(i)]
    item.Text = nx_widestr(i)
    item.Enabled = i <= form.max_page
    nx_set_custom(item, "page", i)
  end
  local rbtn = form["rbtn_page_" .. tostring(g_pages + 2)]
  rbtn.Text = nx_widestr(maxpage)
  nx_set_custom(rbtn, "page", maxpage)
  set_cur_page(form, 1)
  if breset ~= 0 then
    set_first_page_selected()
  end
end
function set_cur_page(form, page)
  if page < 1 then
    page = 1
  end
  if page > form.max_page then
    page = form.max_page
  end
  form.page = page
  form["rbtn_page_" .. tostring(g_pages + 1)].Enabled = false
  form["rbtn_page_" .. tostring(g_pages + 2)].Enabled = page < form.max_page
  form.btn_pre_page.Enabled = page > g_pages
  form.btn_next_page.Enabled = nx_custom(form["rbtn_page_" .. tostring(g_pages)], "page") < form.max_page
  nx_execute("form_stage_main\\form_charge_shop\\form_charge_shop", "refresh_shop")
end
function on_pre_page_click(btn)
  local form = btn.ParentForm
  local rbtn = form.rbtn_page_1
  local page_begin = nx_custom(rbtn, "page") - g_pages
  if page_begin < 1 then
    return
  end
  for i = 1, g_pages do
    local item = form["rbtn_page_" .. tostring(i)]
    local page = i + page_begin - 1
    item.Text = nx_widestr(page)
    item.Enabled = page <= form.max_page
    nx_set_custom(item, "page", page)
  end
  if rbtn.Checked then
    set_cur_page(form, page_begin)
  else
    rbtn.Checked = true
  end
end
function on_next_page_click(btn)
  local form = btn.ParentForm
  local rbtn = form.rbtn_page_1
  local page_begin = nx_custom(rbtn, "page") + g_pages
  if page_begin > form.max_page then
    return
  end
  for i = 1, g_pages do
    local item = form["rbtn_page_" .. tostring(i)]
    local page = i + page_begin - 1
    item.Text = nx_widestr(page)
    item.Enabled = page <= form.max_page
    nx_set_custom(item, "page", page)
  end
  if rbtn.Checked then
    set_cur_page(form, page_begin)
  else
    rbtn.Checked = true
  end
end
function on_page_changed(rbtn)
  if rbtn.Checked then
    local i = nx_custom(rbtn, "page")
    set_cur_page(rbtn.ParentForm, i)
  end
end
