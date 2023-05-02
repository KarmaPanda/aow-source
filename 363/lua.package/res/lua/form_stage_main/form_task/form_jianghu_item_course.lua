require("util_gui")
require("tips_data")
require("util_functions")
require("util_static_data")
local FORM_ITEM_COURSE = "form_stage_main\\form_task\\form_jianghu_item_course"
local PTOTO_DEFAULT = "gui\\special\\sns_new\\jh_explore\\djlc\\wh.png"
local NAME_DEFAULT = "???"
local ANIMATION_LIGHT = "newworld_item01_click"
local REC_EXPLORE = "JHExplore_Record"
local STATUS_DOING = 0
local STATUS_COMPLETE = 1
local COUNT_PER_PAGE = 4
local table_item = {}
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  set_form_pos(form)
  set_form_data(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function change_form_size()
  local form = nx_value(FORM_BLOOD_NOTICE)
  if not nx_is_valid(form) then
    return
  end
  set_form_pos(form)
end
function set_form_data(form)
  set_item_info(form)
end
function set_item_info(form)
  get_item_info()
  set_default_item_page(form)
  set_default_select_pos(form)
  set_item_show(form)
  set_item_light(form)
  set_item_desc(form)
end
function set_item_show(form)
  set_page_turn(form)
  set_default_item_label(form)
  set_item_label(form)
end
function get_item_info()
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local explorer = nx_value("JianghuExploreModule")
  if not nx_is_valid(explorer) then
    return
  end
  explorer:LoadResource(nx_resource_path() .. "share\\")
  if not player:FindRecord(REC_EXPLORE) then
    return
  end
  table_item = {}
  local rows = player:GetRecordRows(REC_EXPLORE)
  for i = 0, rows - 1 do
    local status = player:QueryRecord(REC_EXPLORE, i, 3)
    if nx_int(status) == nx_int(STATUS_DOING) then
      local explore_id = player:QueryRecord(REC_EXPLORE, i, 2)
      local table_info = explorer:GetJhPlotInfo(explore_id)
      local item_id = table_info[7]
      if nx_string(item_id) ~= nx_string("") then
        table.insert(table_item, item_id)
      end
    end
  end
end
function set_default_item_page(form)
  local total_page = 1
  local count = table.getn(table_item)
  if nx_int(count) == nx_int(0) then
    total_page = 1
  else
    local base_page = nx_int(count / COUNT_PER_PAGE)
    if count % COUNT_PER_PAGE == 0 then
      total_page = base_page
    else
      total_page = base_page + 1
    end
  end
  nx_set_custom(form, "total_page", nx_int(total_page))
  nx_set_custom(form, "cur_page", nx_int(total_page))
  form.lbl_cur_page.Text = nx_widestr(form.cur_page)
  form.lbl_total_page.Text = nx_widestr(form.total_page)
end
function set_page_turn(form)
  form.btn_prev.Visible = true
  form.btn_next.Visible = true
  if not nx_find_custom(form, "cur_page") or not nx_find_custom(form, "total_page") then
    return
  end
  local cur_page = form.cur_page
  if nx_int(cur_page) == nx_int(1) then
    form.btn_prev.Visible = false
  end
  local total_page = form.total_page
  if nx_int(cur_page) == nx_int(total_page) then
    form.btn_next.Visible = false
  end
end
function set_item_label(form)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  if not nx_find_custom(form, "cur_page") then
    return
  end
  local cur_page = form.cur_page
  local count = table.getn(table_item)
  local start_pos = (cur_page - 1) * COUNT_PER_PAGE + 1
  if nx_int(start_pos) < nx_int(1) or nx_int(start_pos) > nx_int(count) then
    return
  end
  local end_pos = math.min(start_pos + COUNT_PER_PAGE, count)
  if nx_int(start_pos) < nx_int(1) or nx_int(start_pos) > nx_int(count) then
    return
  end
  local table_part_item = {}
  for i = start_pos, end_pos do
    table.insert(table_part_item, table_item[i])
  end
  local part_count = table.getn(table_part_item)
  for i = 1, part_count do
    item_id = table_part_item[i]
    local photo = item_query:GetItemPropByConfigID(item_id, "Photo")
    local name = item_query:GetItemPropByConfigID(item_id, "Name")
    local name_photo = nx_string("lbl_photo0") .. nx_string(i)
    local name_name = nx_string("lbl_name0") .. nx_string(i)
    local ctrl_photo = form.gb_item_list:Find(name_photo)
    local ctrl_name = form.gb_item_list:Find(name_name)
    if not nx_is_valid(ctrl_photo) or not nx_is_valid(ctrl_name) then
      return
    end
    ctrl_photo.BackImage = nx_string(photo)
    ctrl_name.Text = nx_widestr(name)
    nx_set_custom(ctrl_name, "item_id", nx_string(item_id))
  end
end
function set_default_item_label(form)
  for i = 1, COUNT_PER_PAGE do
    local name_photo = nx_string("lbl_photo0") .. nx_string(i)
    local name_border = nx_string("lbl_border0") .. nx_string(i)
    local name_name = nx_string("lbl_name0") .. nx_string(i)
    local ctrl_photo = form.gb_item_list:Find(name_photo)
    local ctrl_border = form.gb_item_list:Find(name_border)
    local ctrl_name = form.gb_item_list:Find(name_name)
    if not (nx_is_valid(ctrl_photo) and nx_is_valid(ctrl_border)) or not nx_is_valid(ctrl_name) then
      return
    end
    ctrl_photo.BackImage = nx_string(PTOTO_DEFAULT)
    ctrl_border.BackImage = nx_string("")
    ctrl_name.Text = nx_widestr(NAME_DEFAULT)
    nx_set_custom(ctrl_name, "item_id", nx_string(""))
  end
end
function set_prev_page(form)
  if not nx_find_custom(form, "cur_page") then
    return
  end
  local cur_page = form.cur_page
  cur_page = math.max(1, cur_page - 1)
  nx_set_custom(form, "cur_page", nx_int(cur_page))
  form.lbl_cur_page.Text = nx_widestr(form.cur_page)
end
function set_next_page(form)
  if not nx_find_custom(form, "cur_page") or not nx_find_custom(form, "total_page") then
    return
  end
  local cur_page = form.cur_page
  local total_page = form.total_page
  cur_page = math.min(total_page, cur_page + 1)
  nx_set_custom(form, "cur_page", nx_int(cur_page))
  form.lbl_cur_page.Text = nx_widestr(form.cur_page)
end
function on_btn_prev_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  set_prev_page(form)
  set_item_show(form)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  set_next_page(form)
  set_item_show(form)
end
function set_default_select_pos(form)
  local pos_select = 0
  local count = table.getn(table_item)
  if nx_int(count) ~= nx_int(0) then
    pos_select = count % COUNT_PER_PAGE
    if nx_int(pos_select) == nx_int(0) then
      pos_select = COUNT_PER_PAGE
    end
  end
  nx_set_custom(form, "pos_select", nx_int(pos_select))
end
function set_select_pos(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local pos_select = nx_int(lbl.DataSource)
  nx_set_custom(form, "pos_select", nx_int(pos_select))
end
function clear_select_pos(form)
  nx_set_custom(form, "pos_select", nx_int(0))
end
function on_item_click(lbl)
  if not can_select_item(lbl) then
    return
  end
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  set_select_pos(lbl)
  set_item_show(form)
  set_item_light(form)
  set_item_desc(form)
end
function can_select_item(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local pos_select = nx_int(lbl.DataSource)
  local name_name = nx_string("lbl_name0") .. nx_string(pos_select)
  local ctrl_name = form.gb_item_list:Find(name_name)
  if not nx_is_valid(ctrl_name) then
    return false
  end
  if not nx_find_custom(ctrl_name, "item_id") then
    return false
  end
  local item_id = ctrl_name.item_id
  if string.len(item_id) == 0 then
    return false
  end
  return true
end
function set_item_desc(form)
  if not nx_find_custom(form, "pos_select") then
    return
  end
  local pos_select = form.pos_select
  local name_name = nx_string("lbl_name0") .. nx_string(pos_select)
  local ctrl_name = form.gb_item_list:Find(name_name)
  if not nx_is_valid(ctrl_name) then
    return
  end
  if not nx_find_custom(ctrl_name, "item_id") then
    return
  end
  local item_id = ctrl_name.item_id
  if string.len(item_id) == 0 then
    return
  end
  local desc_item = nx_string("desc_") .. nx_string(item_id) .. nx_string("_0")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local content = gui.TextManager:GetText(desc_item)
  if string.len(nx_string(content)) == 0 then
    return
  end
  local mltbox = form.mltbox_item_desc
  mltbox.HtmlText = nx_widestr(content)
end
function set_item_light(form)
  if not nx_find_custom(form, "pos_select") then
    return
  end
  local pos_select = form.pos_select
  local name_border = nx_string("lbl_border0") .. nx_string(pos_select)
  local ctrl_border = form.gb_item_list:Find(name_border)
  if not nx_is_valid(ctrl_border) then
    return
  end
  ctrl_border.BackImage = nx_string(ANIMATION_LIGHT)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
