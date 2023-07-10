require("util_functions")
require("util_gui")
require("role_composite")
require("tips_data")
require("share\\view_define")
require("form_stage_main\\form_home\\form_home_msg")
require("util_role_prop")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
local item_type = {
  [1] = "HomeCJ",
  [2] = "HomeCF",
  [3] = "HomeXL",
  [4] = "HomeZM",
  [5] = "HomeQJ",
  [6] = "HomeZS",
  [7] = "HomeBJ",
  [8] = "HomeCW"
}
local filter_form_table = {
  "form_stage_main\\form_home\\form_home_enter",
  "form_stage_main\\form_main\\form_main_chat",
  "form_stage_main\\form_main\\form_main_marry",
  "form_stage_main\\form_main\\form_main_sysinfo",
  "form_stage_main\\form_home\\form_home_model",
  "form_stage_main\\form_home\\form_home_help",
  "form_stage_main\\form_home\\form_home_help_ty",
  "form_stage_main\\form_main\\form_main_buff",
  "form_stage_main\\form_main\\form_notice_shortcut",
  "form_stage_main\\form_main\\form_main_player",
  "form_stage_main\\form_home\\form_home_help_tygn"
}
local close_form_table = {
  "form_stage_main\\form_home\\form_home_function"
}
local furniture_type_list = {}
local BUTTON_MAX = 7
local my_home_form_path = "form_stage_main\\form_home\\form_home_myhome"
local hide_control = {"groupbox_4"}
local hide_home_form_table_home = {
  "form_stage_main\\form_main\\form_main_shortcut_extraskill",
  "form_stage_main\\form_home\\form_home_model",
  "form_stage_main\\form_home\\form_home_function",
  "form_stage_main\\form_home\\form_home_myhome",
  "form_stage_main\\form_home\\form_home_enter",
  "form_stage_main\\form_home\\form_home_main",
  "form_stage_main\\form_home\\form_home_guyong",
  "form_stage_main\\form_home\\form_home_mutual",
  "form_stage_main\\form_home\\form_home_kuojian"
}
local show_home_form_table_home = {
  "form_stage_main\\form_main\\form_main_shortcut"
}
local control_hide_home_table = {}
function tc(aaa, bbb, ccc, ddd)
  nx_msgbox(nx_string(aaa) .. "/" .. nx_string(bbb) .. "/" .. nx_string(ccc) .. "/" .. nx_string(ddd))
end
function open_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    local form = nx_value(nx_current())
    if nx_is_valid(form) then
      form:Close()
    end
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function check_close_form()
  local form = nx_value(nx_current())
  local homeid = get_current_homeid()
  if homeid == nx_string("") and nx_is_valid(form) then
    form:Close()
  end
end
function close_filter_form(bool)
  for i, path in pairs(close_form_table) do
    local form = nx_value(path)
    if nx_is_valid(form) then
      form:Close()
    end
  end
end
function main_form_init(form)
  form.Fixed = true
  form.open_type = 0
  form.button_page = 1
  form.max_page = 0
  form.check_button = nil
end
function on_main_form_open(form)
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    return
  end
  on_size_change()
  nx_execute("gui", "gui_close_allsystem_form", 3)
  nx_execute("form_stage_main\\form_home\\form_home_model", "set_home_model", 2)
  form_init(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_HOME_BOX, form, nx_current(), "on_viewport_change")
    databinder:AddTableBind("HomeFurnitureRec", form, nx_current(), "on_HomeFurnitureRec_refresh")
    databinder:AddRolePropertyBind("CurHomeUID", "string", form, "form_stage_main\\form_home\\form_home_enter", "on_cur_homeid_changed")
    databinder:AddRolePropertyBind("CurHomeOwnerName", "widestr", form, nx_current(), "on_cur_home_ownername_changed")
    databinder:AddRolePropertyBind("CurHomeInOutType", "int", form, nx_current(), "on_home_inout_type_changed")
  end
  show_filter_form()
  hide_main_form_control()
  form_fresh(form)
  init_furniture_type(form)
  refresh_furniture_type_form()
  show_design_line()
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_cur_homeid_changed(form)
  if not nx_is_valid(form) then
    return
  end
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    form:Close()
    return
  end
end
function on_cur_home_ownername_changed(form)
  if not nx_is_valid(form) then
    return
  end
  form_init(form)
end
function reset_scene()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
end
function init_furniture_type(form)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\home_furniture_type.ini", true)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("MainTitle")
  if sec_index < 0 then
    return
  end
  furniture_type_list = {}
  local home_inout_type = nx_int(get_player_home_inout())
  local show_item_count = 0
  local item_count = ini:GetSectionItemCount(sec_index)
  for i = 1, item_count do
    local item_key = nx_int(ini:GetSectionItemKey(sec_index, i - 1))
    local item_value = ini:GetSectionItemValue(sec_index, i - 1)
    local str_list = util_split_string(item_value, ",")
    local info = {}
    info.furniture_name = str_list[1]
    info.furniture_type = str_list[2]
    local furniture_type = nx_int(info.furniture_type)
    if furniture_type == home_inout_type or furniture_type == nx_int(-1) then
      table.insert(furniture_type_list, info)
      show_item_count = show_item_count + 1
    end
  end
  form.max_page = nx_int(show_item_count / BUTTON_MAX)
  if show_item_count % BUTTON_MAX ~= 0 then
    form.max_page = form.max_page + 1
  end
end
function clear_furniture_type_item(form)
  local item_list = form.groupbox_type:GetChildControlList()
  local gui = nx_value("gui")
  for i = 1, table.getn(item_list) do
    if item_list[i].Visible then
      form.groupbox_type:Remove(item_list[i])
      gui:Delete(item_list[i])
    end
  end
end
function refresh_furniture_type_form()
  local item_count = table.getn(furniture_type_list)
  if nx_int(item_count) <= nx_int(0) then
    return
  end
  local gui = nx_value("gui")
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local begin_index = (form.button_page - 1) * BUTTON_MAX + 1
  local end_index = form.button_page * BUTTON_MAX
  if item_count < end_index then
    end_index = item_count
  end
  local info = nx_string(form.button_page) .. ":" .. nx_string(begin_index) .. ":" .. nx_string(end_index)
  form.lbl_page.Text = nx_widestr(info)
  form.groupbox_type:DeleteAll()
  local index = 0
  local group = form.groupbox_type
  local cell_width = group.Width / BUTTON_MAX
  local cell_height = group.Height
  local image_path = "gui\\special\\home\\baifang\\"
  form.check_button = nil
  for i = begin_index, end_index do
    local cur_furniture_name = nx_string(furniture_type_list[i].furniture_name)
    local cur_furniture_type = nx_int(furniture_type_list[i].furniture_type)
    local cbtn = gui:Create("RadioButton")
    if nx_is_valid(cbtn) then
      cbtn.Name = cur_furniture_name
      cbtn.Text = nx_widestr("")
      cbtn.TabIndex = nx_int(i)
      if i == 1 then
        cbtn.Checked = true
      else
        cbtn.Checked = false
      end
      if cbtn.Checked then
        form.check_button = cbtn
        form_fresh(form)
      end
      cbtn.NormalImage = image_path .. nx_string(cur_furniture_name) .. "_out.png"
      cbtn.FocusImage = image_path .. nx_string(cur_furniture_name) .. "_on.png"
      cbtn.CheckedImage = image_path .. nx_string(cur_furniture_name) .. "_down.png"
      cbtn.DrawMode = "FitWindow"
      nx_bind_script(cbtn, nx_current())
      nx_callback(cbtn, "on_checked_changed", "on_cbtn_furniture_type_checked_changed")
      form.groupbox_type:Add(cbtn)
      cbtn.Top = cell_height - 50
      cbtn.Left = index * cell_width
      cbtn.Width = 58
      cbtn.Height = 58
      index = index + 1
    end
  end
end
function on_btn_type_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(form.button_page) <= nx_number(1) then
    return
  end
  form.button_page = form.button_page - 1
  init_furniture_type(form)
  refresh_furniture_type_form()
end
function on_btn_type_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.button_page >= form.max_page then
    return
  end
  form.button_page = form.button_page + 1
  init_furniture_type(form)
  refresh_furniture_type_form()
end
function on_cbtn_furniture_type_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked then
    form.check_button = btn
  end
  form_fresh(form)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function add_mount_card_form(form)
  local form_my_home = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_home_myhome", true, false)
  if not nx_is_valid(form_my_home) then
    return
  end
  local is_load = form.groupbox_info:Add(form_my_home)
  if is_load then
    form_my_home.Left = 0
    form_my_home.Top = 0
    form_my_home.combobox_my.Visible = false
    form_my_home.lbl_home_name.Text = nx_widestr(form_my_home.home_name)
    form_my_home.Visible = true
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
    databinder:DelTableBind("HomeFurnitureRec", form)
    databinder:DelRolePropertyBind("CurHomeUID", form)
    databinder:DelRolePropertyBind("CurHomeOwnerName", form)
    databinder:DelRolePropertyBind("CurHomeInOutType", form)
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if HomeManager.ShowDesignLine then
    HomeManager.ShowDesignLine = false
  end
  nx_destroy(form)
  close_filter_form()
  nx_execute("gui", "gui_open_closedsystem_form")
  local form_main = util_get_form("form_stage_main\\form_main\\form_main", false)
  if nx_is_valid(form_main) and nx_is_valid(form_main.groupbox_4) and nx_is_valid(form_main.groupbox_5) then
    form_main.groupbox_4.Visible = true
    form_main.groupbox_5.Visible = true
    if nx_is_valid(form_main.groupbox_update) then
      form_main.groupbox_update.Visible = true
    end
  end
end
function on_btn_home_click(btn)
  nx_execute("form_stage_main\\form_home\\form_home", "open_form")
end
function on_btn_storage_click(btn)
  nx_execute("form_stage_main\\form_home\\form_home_storage", "open_form")
end
function on_btn_gy_click(btn)
  nx_execute("form_stage_main\\form_home\\form_home_guyong", "open_form")
end
function on_btn_line_click(btn)
  show_design_line()
end
function show_design_line()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if form.open_type ~= 1 then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  HomeManager.ShowDesignLine = not HomeManager.ShowDesignLine
end
function on_btn_exit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    return
  end
  form:Close()
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_LEFT, homeid)
end
function on_btn_op_m_click(btn)
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_EVENT, homeid, 2)
end
function on_btn_op_n_click(btn)
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_EVENT, homeid, 1)
end
function form_init(form)
  form.groupbox_op.Visible = false
  form.groupbox_str_m.Visible = false
  form.groupbox_str_n.Visible = false
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  form.pbar_cur_m.texts = nx_widestr("")
  form.pbar_cur_n.texts = nx_widestr("")
  if HomeManager:IsMyHome() or HomeManager:IsPartnerHome() then
    form.groupbox_op.Visible = true
    form.groupbox_str_n.Visible = true
    form.open_type = 1
    form.lbl_num.count = 0
    form.lbl_num.now = 1
    form.lbl_num.max = 1
    form.lbl_num.number = 0
  elseif HomeManager:IsNeighbourHome() then
    form.groupbox_str_n.Visible = true
    form.open_type = 2
  else
    form.groupbox_str_m.Visible = true
    form.open_type = 3
  end
end
function form_fresh(form)
  if not nx_is_valid(form) then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local grid = form.ImageControlGrid_item
  grid:Clear()
  form.lbl_num.count = 0
  form.lbl_num.now = 1
  form.lbl_num.max = 1
  form.lbl_num.number = 0
  form.lbl_num.Text = nx_widestr("1/1")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord("HomeFurnitureRec") then
    return
  end
  local rows = client_player:GetRecordRows("HomeFurnitureRec")
  if rows <= 0 then
    return
  end
  local type_name = get_click_furniture_type(form)
  if type_name == nil or type_name == "" then
    return
  end
  local player_inout = get_player_home_inout()
  local number = 0
  for i = 0, rows - 1 do
    local configid = nx_string(client_player:QueryRecord("HomeFurnitureRec", i, 0))
    local count = nx_int(client_player:QueryRecord("HomeFurnitureRec", i, 1))
    local bindstatus = nx_int(client_player:QueryRecord("HomeFurnitureRec", i, 2))
    local display_type = HomeManager:GetHomeDisplayType(configid)
    local item_type = get_item_type(form, configid)
    if type_name == item_type and (display_type < 0 or display_type == player_inout) then
      number = number + 1
    end
  end
  local count = grid.RowNum * grid.ClomnNum
  local yushu = 0
  if 0 < number % count then
    yushu = yushu + 1
  end
  form.lbl_num.count = count
  form.lbl_num.now = 1
  form.lbl_num.max = nx_int(number / count) + nx_int(yushu)
  if 0 >= form.lbl_num.max then
    form.lbl_num.max = 1
  end
  form.lbl_num.number = number
  fresh_item(form)
end
function get_item_type(form, configid)
  if not nx_is_valid(form) then
    return
  end
  if configid == "" then
    return
  end
  local script = get_ini_prop("share\\Item\\tool_item.ini", nx_string(configid), "script", "")
  if script == "" then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\home_furniture_type.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(script))
  if sec_index < 0 then
    return
  end
  local item_index = ini:FindSectionItemIndex(sec_index, nx_string(configid))
  if item_index < 0 then
    return
  end
  local type_name = ini:GetSectionItemValue(sec_index, item_index)
  return type_name
end
function fresh_item(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.ImageControlGrid_item
  grid:Clear()
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  if 1 ~= form.open_type then
    return
  end
  local type_name = get_click_furniture_type(form)
  if type_name == nil or type_name == "" then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord("HomeFurnitureRec") then
    return
  end
  local rows = client_player:GetRecordRows("HomeFurnitureRec")
  if rows <= 0 then
    return
  end
  form.lbl_num.Text = nx_widestr(nx_string(form.lbl_num.now) .. "/" .. nx_string(form.lbl_num.max))
  local player_inout = get_player_home_inout()
  local size = (nx_int(form.lbl_num.now) - nx_int(1)) * nx_int(form.lbl_num.count)
  local index = 0
  local number = 0
  for i = 0, rows - 1 do
    local configid = nx_string(client_player:QueryRecord("HomeFurnitureRec", i, 0))
    local count = nx_int(client_player:QueryRecord("HomeFurnitureRec", i, 1))
    local bindstatus = nx_int(client_player:QueryRecord("HomeFurnitureRec", i, 2))
    local display_type = HomeManager:GetHomeDisplayType(configid)
    local item_type = get_item_type(form, configid)
    if type_name == item_type and (display_type < 0 or player_inout == display_type) then
      number = number + 1
      if nx_int(number) > nx_int(size) then
        local photo = nx_string(ItemQuery:GetItemPropByConfigID(configid, "Photo"))
        grid:AddItem(nx_int(index), photo, nx_widestr(configid), count, -1)
        grid:SetItemAddInfo(nx_int(index), nx_int(1), nx_widestr(count))
        grid:ShowItemAddInfo(nx_int(index), nx_int(1), true)
        grid:ShowItemAddInfo(nx_int(index), nx_int(0), false)
        if 0 > grid:GetSelectItemIndex() then
          grid:SetSelectItemIndex(index)
        end
        index = index + 1
        if nx_int(index) >= nx_int(form.lbl_num.count) then
          break
        end
      end
    end
  end
end
function on_viewport_change(form, optype, view_ident)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  refresh_form(form, view)
end
function on_HomeFurnitureRec_refresh(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return
  end
  if optype ~= "add" and optype ~= "del" and optype ~= "clear" and optype ~= "update" then
    return
  end
  fresh_item(form)
end
function refresh_form(form, view)
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  local cur_clean = nx_int(view:QueryProp("cur_stay"))
  local max_clean = nx_int(view:QueryProp("max_stay"))
  local conf_id = nx_int(view:QueryProp("home_id"))
  local lvl = nx_int(view:QueryProp("home_lvl"))
  local tablename = ""
  if form.open_type == 1 then
    tablename = "clean_rec"
    form.pbar_cur_n.Maximum = nx_int(max_clean)
    form.pbar_cur_n.Value = nx_int(cur_clean)
  elseif form.open_type == 2 then
    tablename = "clean_rec"
    form.pbar_cur_n.Maximum = nx_int(max_clean)
    form.pbar_cur_n.Value = nx_int(cur_clean)
  elseif form.open_type == 3 then
    tablename = "trouble_rec"
    form.pbar_cur_m.Maximum = nx_int(max_clean)
    form.pbar_cur_m.Value = nx_int(cur_clean)
  else
    return
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local nowtime = nx_int(msg_delay:GetServerDateTime())
  local value_day = 0
  if view:FindRecord(tablename) then
    local rows = view:GetRecordRows(tablename)
    for i = 0, rows - 1 do
      local uid = nx_string(view:QueryRecord(tablename, i, 0))
      local name = nx_widestr(view:QueryRecord(tablename, i, 1))
      local value = nx_number(view:QueryRecord(tablename, i, 2))
      local time = nx_double(view:QueryRecord(tablename, i, 3))
      if nowtime ~= nx_int(time) then
        break
      end
      value_day = value_day + value
    end
  end
  if form.open_type == 1 or form.open_type == 2 then
    local max_add_clean = nx_int(HomeManager:GetHomeMaxAddStay(conf_id, lvl))
    local clean = nx_int(HomeManager:GetHomeAddStay(conf_id, lvl))
    local diff = max_add_clean - value_day
    local text = util_text("ui_home_myhome_08") .. nx_widestr(" ") .. nx_widestr(diff) .. nx_widestr("<br>") .. util_text("ui_home_myhome_09") .. nx_widestr(" ") .. nx_widestr(clean)
    form.pbar_cur_n.texts = text
  elseif form.open_type == 3 then
    local max_add_clean = nx_int(HomeManager:GetHomeMaxDecStay(conf_id, lvl))
    local clean = nx_int(HomeManager:GetHomeDecStay(conf_id, lvl))
    local diff = max_add_clean - value_day
    local text = util_text("ui_home_myhome_10") .. nx_widestr(" ") .. nx_widestr(diff) .. nx_widestr("<br>") .. util_text("ui_home_myhome_11") .. nx_widestr(" ") .. nx_widestr(clean)
    form.pbar_cur_m.texts = text
  end
end
function on_rbtn_type_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form_fresh(form)
end
function on_rbtn_color_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form_fresh(form)
end
function get_type_script(form)
  if not nx_is_valid(form) then
    return ""
  end
  for i = 1, table.maxn(item_type) do
    local btn_name = "rbtn_type_" .. nx_string(i)
    local rbtn = form.groupbox_type:Find(btn_name)
    if nx_is_valid(rbtn) and rbtn.Checked then
      return item_type[i]
    end
  end
  return ""
end
function get_click_furniture_type(form)
  if not nx_is_valid(form) then
    return ""
  end
  if form.check_button == nil then
    return ""
  end
  return form.check_button.Name
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.lbl_num.now) > nx_int(1) then
    form.lbl_num.now = form.lbl_num.now - 1
    fresh_item(form)
  end
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.lbl_num.now) >= nx_int(form.lbl_num.max) then
    return
  end
  form.lbl_num.now = form.lbl_num.now + 1
  fresh_item(form)
end
function on_ImageControlGrid_item_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  local npcid = get_ini_prop("share\\Item\\home_furniture.ini", nx_string(item_config), "npcid", "")
  if npcid == "" then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  HomeManager:SetCurrentGoods(npcid, nx_string(item_config), nx_int(1), 0)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_ImageControlGrid_item_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_ImageControlGrid_item_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_pbar_cur_m_get_capture(self, lost)
  local text = self.texts
  if nx_widestr(text) == nx_widestr("") then
    return
  end
  local form = self.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function on_pbar_cur_m_lost_capture(self, x, y)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_pbar_cur_n_get_capture(self, lost)
  local text = self.texts
  if nx_widestr(text) == nx_widestr("") then
    return
  end
  local form = self.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function on_pbar_cur_n_lost_capture(self, x, y)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function get_current_homeid()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp("CurHomeUID") then
    return ""
  end
  return nx_string(client_player:QueryProp("CurHomeUID"))
end
function on_size_change()
  local form = nx_value(nx_current())
  local gui = nx_value("gui")
  if nx_is_valid(form) and nx_is_valid(gui) then
    form.AbsTop = 0
    form.AbsLeft = 0
    form.Width = gui.Desktop.Width
    form.Height = gui.Desktop.Height
  end
end
function show_filter_form(bool)
  for i, path in pairs(filter_form_table) do
    local form = nx_value(path)
    if nx_is_valid(form) then
      form.Visible = true
    end
  end
end
function hide_main_form_control()
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  for i, name in pairs(hide_control) do
    local control = nx_custom(form, name)
    if nx_is_valid(control) then
      control.Visible = false
    end
  end
end
function get_conf_id()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local view = game_client:GetView(nx_string(VIEWPORT_HOME_BOX))
  if not nx_is_valid(view) then
    return 0
  end
  return nx_int(view:QueryProp("home_id"))
end
function use_home_furniture_item(viewid, pos, item_name)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local text = nx_widestr(util_format_string("ui_home_storage_text_1", item_name))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  local helper_form = nx_value("helper_form")
  if helper_form then
    dialog.HAnchor = "Left"
    dialog.Visible = true
    dialog:Show()
  else
    dialog:ShowModal()
  end
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_use_item", viewid, pos)
    if helper_form then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
  end
end
function on_btn_leave_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_home_myhome_12")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "cancel" then
    return
  end
  form:Close()
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_LEFT, homeid)
end
function on_btn_leave1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_home_myhome_12")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "cancel" then
    return
  end
  form:Close()
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_LEFT, homeid)
end
function find_grid_item(grid, control_name)
  if not nx_is_valid(grid) then
    return -1
  end
  return grid:FindItem(nx_widestr(control_name))
end
function get_player_home_inout()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return -1
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  if not client_player:FindProp("CurHomeInOutType") then
    return 0
  end
  return client_player:QueryProp("CurHomeInOutType")
end
function on_home_inout_type_changed(form)
  if nx_is_valid(form) then
    init_furniture_type(form)
    form.button_page = 1
    refresh_furniture_type_form()
  end
end
function hide_homeleitai_form()
  for i, path in pairs(hide_home_form_table_home) do
    local form = nx_value(path)
    if nx_is_valid(form) and form.Visible then
      form.Visible = false
      table.insert(control_hide_home_table, form)
    end
  end
  for i, path in pairs(show_home_form_table_home) do
    local form = nx_value(path)
    if nx_is_valid(form) and not form.Visible then
      form.Visible = true
    end
  end
end
function show_homeleitai_form()
  for i = table.maxn(control_hide_home_table), 1, -1 do
    local control = control_hide_home_table[i]
    if nx_is_valid(control) then
      control.Visible = true
    end
  end
  for i, path in pairs(show_home_form_table_home) do
    local form = nx_value(path)
    if nx_is_valid(form) and form.Visible then
      form.Visible = false
    end
  end
  control_hide_home_table = {}
end
function check_home_leitai_form()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return
  end
  if interactmgr:GetInteractStatus(ITT_WORLDLEITAI) == PIS_IN_GAME then
    hide_homeleitai_form()
  end
end
