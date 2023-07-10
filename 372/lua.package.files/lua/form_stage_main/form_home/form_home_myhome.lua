require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("tips_data")
require("share\\view_define")
require("form_stage_main\\switch\\switch_define")
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function open_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if not HomeManager:IsMyHome() then
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function open_or_close_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.Fixed = true
  form.home_id = ""
  form.show_type = 0
  form.home_name = ""
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.lbl_name.conf_id = 0
  form.lbl_name.home_lvl = 0
  form.lbl_name.hualidu = 0
  form.lbl_name.home_out_lvl = 0
  form.lbl_name.home_out_pretty = 0
  form.lbl_jynaijiu.Text = nx_widestr("")
  form.lbl_msnaijiu.Text = nx_widestr("")
  form.textgrid_my.Visible = false
  form.is_villa = 0
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("self_home_rec", form, nx_current(), "on_self_home_rec_refresh")
  end
  if not nx_find_custom(form, "isOverday") then
    nx_set_custom(form, "isOverday", 0)
  end
  add_self_home_list(form)
  refuresh_home_info_form()
end
function on_size_change()
  refuresh_home_info_form()
end
function refuresh_home_info_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    return
  end
  form.AbsLeft = 30
  form.AbsTop = 120
  form.groupbox_1.Height = 282
  form.combobox_my.Visible = false
  local home_show_name = get_home_show_name(form, homeid, form.home_name)
  form.lbl_home_name.Text = nx_widestr(home_show_name)
  form.Visible = true
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("self_home_rec", form)
  end
  nx_destroy(form)
end
function format_money(money)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_money2")
  gui.TextManager:Format_AddParam(money)
  local ret = gui.TextManager:Format_GetText()
  return ret
end
function on_btn_change_name_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.home_id) == nx_string("") then
    return
  end
  local capital = nx_int(get_ini_prop("share\\Home\\HomeSystemConf.ini", "main", "change_name_cost", "0"))
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_home_input_name", true, false)
  dialog.lbl_text.HtmlText = nx_widestr("@ui_home_housename")
  dialog.ipt_name.Text = nx_widestr("")
  dialog.lbl_yinka.Text = nx_widestr(format_money(capital))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "form_home_input_name")
  if nx_string(res) == "cancel" or nx_string(res) == "" then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_CHANGE_NAME, nx_string(form.home_id), nx_widestr(res))
end
function back_furniture(npc_obj)
  if not nx_is_valid(npc_obj) then
    return
  end
  local npcid = nx_string(npc_obj:QueryProp("ConfigID"))
  if npcid == nx_string("") then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local needmoney = home_manager:GetHomeBackMoneyByNpcID(npcid)
  if nx_int(needmoney) > nx_int(0) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_home_input_name", true, false)
    dialog.lbl_text.HtmlText = nx_widestr(util_format_string("tips_home_hs_1", nx_int(needmoney)))
    dialog.ipt_name.Text = nx_widestr("ok")
    dialog.ipt_name.Visible = false
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "form_home_input_name")
    if nx_string(res) == "cancel" or nx_string(res) == "" then
      return
    end
  end
  home_manager:BackHomeNpc(npc_obj)
end
function del_furniture(npc_obj)
  if not nx_is_valid(npc_obj) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_home_jj_del"))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    home_manager:DeleteHomeNpc(npc_obj)
  end
end
function fire_home_npc(npc_obj)
  if not nx_is_valid(npc_obj) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local tips_str = util_text("ui_home_pr_del")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(tips_str))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if nx_string(res) ~= "ok" then
    return
  end
  home_manager:FireHomeNpc(npc_obj)
end
function on_btn_kj_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.lbl_name.home_lvl) <= nx_int(0) or nx_int(form.lbl_name.conf_id) <= nx_int(0) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_kuojian", "open_form", nx_string(form.home_id), form.lbl_name.conf_id, form.lbl_name.home_lvl, form.lbl_name.hualidu, form.lbl_name.home_out_lvl, form.lbl_name.home_out_pretty)
end
function on_btn_enter_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ENTRY, nx_string(form.home_id))
end
function on_btn_shop_click(btn)
  nx_execute("form_stage_main\\form_home\\form_home_main", "open_form", 1)
end
function on_btn_compose_click(btn)
  nx_execute("form_stage_main\\form_home\\form_home_main", "open_form", 2)
end
function on_btn_sell_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_HOME_SELL) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "home_id") then
    return
  end
  if form.home_id == nil or nx_string(form.home_id) == nx_string("") then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_DIRECT_SELLHOME, nx_string(form.home_id))
end
function on_btn_power_click(btn)
end
function on_btn_storage_click(btn)
  nx_execute("form_stage_main\\form_home\\form_home_storage", "open_form")
end
function on_btn_movehome_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "home_id") then
    return
  end
  if form.home_id == nil or nx_string(form.home_id) == nx_string("") then
    return
  end
  local movehome_id = form.home_id
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "first_move_home")
  if not nx_is_valid(dialog) then
    return
  end
  dialog.lbl_1.Text = nx_widestr(util_text("ui_home_banjia_01"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_text("ui_home_banjia_02")))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local confirm_count = 0
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    confirm_count = confirm_count + 1
  else
    return
  end
  if nx_int(confirm_count) == nx_int(1) then
    nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_REQUEST_MOVEHOME, nx_string(movehome_id))
  end
end
function on_self_home_rec_refresh(form, recordname, optype, row, clomn)
  if optype ~= "add" and optype ~= "del" and optype ~= "clear" and optype ~= "update" then
    return
  end
  add_self_home_list(form)
end
function fresh_self_home(form)
  form.textgrid_wife:ClearSelect()
  form.textgrid_wife:ClearRow()
  form.combobox_my.InputEdit.Text = nx_widestr("")
  form.combobox_my.DropListBox:ClearString()
  clear_detail(form)
  for i = 0, form.textgrid_my.RowCount - 1 do
    local home_id = form.textgrid_my:GetGridText(i, 0)
    local home_name = form.textgrid_my:GetGridText(i, 1)
    local owner_name = form.textgrid_my:GetGridText(i, 2)
    local home_show_name = get_home_show_name(form, home_id, home_name)
    form.combobox_my.DropListBox:AddString(nx_widestr(home_show_name))
    if nx_string(form.home_id) == nx_string("") then
      form.home_id = nx_string(home_id)
    end
  end
  default_select_home(form)
end
function on_combobox_my_selected(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  local recordname = "self_home_rec"
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local player_name = client_player:QueryProp("Name")
  local index = form.combobox_my.DropListBox.SelectIndex
  local grid_rows = form.textgrid_my.RowCount
  if nx_number(index) < nx_number(0) or nx_number(index) >= nx_number(grid_rows) then
    return
  end
  local home_id = form.textgrid_my:GetGridText(index, 0)
  local home_name = form.textgrid_my:GetGridText(index, 1)
  local owner_name = form.textgrid_my:GetGridText(index, 2)
  local home_show_name = get_home_show_name(form, home_id, home_name)
  local select_str = form.combobox_my.DropListBox.SelectString
  if nx_widestr(home_show_name) ~= nx_widestr(select_str) then
    return
  end
  clear_detail(form)
  form.home_id = home_id
  form.home_name = home_name
  form.btn_change_name.Visible = true
  if nx_widestr(player_name) == nx_widestr(owner_name) then
    form.btn_sell.Visible = true
    form.btn_movehome.Visible = true
  else
    form.btn_sell.Visible = false
    form.btn_movehome.Visible = false
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_QUERY, nx_string(form.home_id))
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_QUERY_VISITORS, nx_string(form.home_id))
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_HIRENPC_INFO, nx_string(form.home_id))
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_REQUEST_BUILDING_ACTIVE_NUMBER, nx_string(form.home_id))
end
function on_textgrid_my_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local home_id = nx_string(grid:GetGridText(row, 0))
  if home_id == nx_string("") then
    return
  end
  clear_detail(form)
  form.home_id = home_id
  form.btn_change_name.Visible = true
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_QUERY, home_id)
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_QUERY_VISITORS, nx_string(home_id))
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_HIRENPC_INFO, nx_string(form.home_id))
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_REQUEST_BUILDING_ACTIVE_NUMBER, nx_string(form.home_id))
end
function fresh_wife_home(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.home_id) ~= nx_string(arg[1]) then
    return
  end
  form.textgrid_wife:ClearSelect()
  form.textgrid_wife:ClearRow()
  for i = 2, table.getn(arg), 2 do
    local player_id = nx_string(arg[i])
    local player_name = nx_widestr(arg[i + 1])
    if player_id == nx_string("") or nx_ws_length(player_name) <= 0 then
      break
    end
    local row = form.textgrid_wife:InsertRow(-1)
    form.textgrid_wife:SetGridText(row, 0, nx_widestr(player_id))
    form.textgrid_wife:SetGridText(row, 1, nx_widestr(player_name))
  end
end
function on_textgrid_wife_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
end
function fresh_home_detail(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local home_id = nx_string(arg[1])
  if home_id ~= nx_string(form.home_id) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local home_name = nx_widestr(arg[2])
  local conf_id = nx_int(arg[3])
  local master_name = nx_widestr(arg[5])
  local home_scene = nx_int(arg[6])
  local sign_id = nx_int(arg[7])
  local home_lvl = nx_int(arg[11])
  local home_status = nx_int(arg[12])
  local home_stay = nx_int(arg[13])
  local home_pretty = nx_int(arg[14])
  local home_des = nx_int(arg[15])
  local home_fengshui = nx_int(arg[18])
  local home_out_lvl = nx_int(arg[19])
  local home_out_pretty = nx_int(arg[20])
  local res_point = nx_int(arg[22])
  local home_over_day_is_sell = nx_int(arg[23])
  local is_villa = nx_int(arg[24])
  form.is_villa = nx_number(is_villa)
  if form.is_villa == 1 then
    form.lbl_actived_buliding.Text = nx_widestr(util_text("ui_home_building_all"))
  end
  form.lbl_name.Text = home_name
  form.lbl_name.conf_id = sign_id
  form.lbl_name.home_lvl = home_lvl
  form.lbl_name.hualidu = home_pretty
  form.lbl_name.home_out_lvl = home_out_lvl
  form.lbl_name.home_out_pretty = home_out_pretty
  local place = nx_widestr("")
  local map_query = nx_value("MapQuery")
  if nx_is_valid(map_query) then
    local home_scene_father = nx_int(home_manager:GetHomeSceneID(sign_id))
    local scene_name = "scene_" .. map_query:GetSceneName(nx_string(home_scene_father))
    place = util_text(scene_name)
    local site = "(" .. nx_string(home_manager:GetHomeX(sign_id)) .. "," .. nx_string(home_manager:GetHomeZ(sign_id)) .. ")"
    place = place .. nx_widestr(site)
  end
  form.lbl_place.Text = place
  local gui = nx_value("gui")
  for i = 1, nx_number(home_lvl) do
    local lbl_star = gui:Create("Label")
    form.groupbox_x:Add(lbl_star)
    lbl_star.Name = "lbl_star_" .. nx_string(i)
    lbl_star.Left = (i - 1) * 20 + 8
    lbl_star.Top = 9
    lbl_star.BackImage = "gui\\special\\home\\main\\start.png"
    lbl_star.AutoSize = true
  end
  local gui = nx_value("gui")
  for i = 1, nx_number(home_out_lvl) do
    local lbl_star = gui:Create("Label")
    form.groupbox_out_x:Add(lbl_star)
    lbl_star.Name = "lbl_star_out_" .. nx_string(i)
    lbl_star.Left = (i - 1) * 20 + 8
    lbl_star.Top = 9
    lbl_star.BackImage = "gui\\special\\home\\main\\start.png"
    lbl_star.AutoSize = true
  end
  form.lbl_style.Text = util_text(home_manager:GetHomeStyle(sign_id))
  if nx_string(home_id) == nx_string("") or home_id == nil then
    form.lbl_jynaijiu.Text = nx_widestr("")
  else
    form.lbl_jynaijiu.Text = nx_widestr(home_stay)
    local tips_text = util_format_string("tips_btn_home_7", nx_int(home_stay), home_manager:GetHomeMaxStay(sign_id, home_lvl))
    form.lbl_fwtp.HintText = nx_widestr(tips_text)
  end
  local msg_delay = nx_value("MessageDelay")
  if nx_is_valid(msg_delay) then
    local feiq_day = nx_int(msg_delay:GetServerDateTime()) - home_des
    if nx_int(feiq_day) <= nx_int(0) then
      feiq_day = nx_int(0)
    end
    local is_show = false
    if nx_int(home_over_day_is_sell) == nx_int(1) then
      if nx_find_custom(form, "isOverday") and 0 >= form.isOverday then
        show_home_tips(home_id)
        form.isOverday = 1
      end
      is_show = true
    end
    nx_execute("form_stage_main\\form_home\\form_home", "show_buy_myhome_btn", nx_string(home_id), is_show)
    local max_day = nx_int(get_ini_prop("share\\Home\\HomeSystemConf.ini", "main", "over_time_day", "0"))
    if is_villa == nx_int(1) then
      max_day = nx_int(get_ini_prop("share\\Home\\HomeSystemConf.ini", "main", "over_bid_day", "0"))
    end
    if max_day < nx_int(feiq_day) then
      feiq_day = max_day
    end
    form.lbl_feiqi.Text = nx_widestr(feiq_day) .. nx_widestr("/") .. nx_widestr(max_day)
  end
  form.lbl_superb.Text = nx_widestr(home_pretty)
  form.lbl_pretty_out.Text = nx_widestr(home_out_pretty)
  local max_fengshui = math.max(nx_number(home_manager:GetHomeMaxFengShui(sign_id, home_lvl)), nx_number(home_fengshui))
  form.lbl_fengshui.Text = nx_widestr(home_fengshui) .. nx_widestr("/") .. nx_widestr(max_fengshui)
  form.lbl_res_point.Text = nx_widestr(res_point)
  fresh_home_other_msg(form, sign_id, home_lvl)
  fresh_home_event(form, form.home_id, form.textgrid_event)
  nx_execute("form_stage_main\\form_home\\form_home_kuojian", "fresh_open_form", nx_string(form.home_id), form.lbl_name.conf_id, form.lbl_name.home_lvl, form.lbl_name.hualidu, form.lbl_name.home_out_lvl, form.lbl_name.home_out_pretty)
end
function show_home_tips(homeuid)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
  if nx_is_valid(dialog) then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local tips_str = gui.TextManager:GetText("ui_home_feiqi")
    dialog.mltbox_info:AddHtmlText(nx_widestr(tips_str), -1)
    dialog:ShowModal()
    nx_wait_event(100000000, dialog, "error_return")
  end
end
function fresh_guyong(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local home_id = nx_string(arg[1])
  if home_id ~= nx_string(form.home_id) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local num1 = nx_int(arg[2])
  local max1 = nx_int(arg[3])
  local num2 = nx_int(arg[4])
  local max2 = nx_int(arg[5])
  local num3 = nx_int(arg[6])
  local max3 = nx_int(arg[7])
  local home_locker_level = nx_int(arg[8])
  local cur_opened_times = nx_int(arg[9])
  local max_opened_times = nx_int(arg[10])
  local times = max_opened_times - cur_opened_times
  form.lbl_yahuan_2.Text = nx_widestr(num1) .. nx_widestr("/") .. nx_widestr(max1)
  form.lbl_huwei.Text = nx_widestr(num2) .. nx_widestr("/") .. nx_widestr(max2)
  form.lbl_yahuan_1.Text = nx_widestr(num3) .. nx_widestr("/") .. nx_widestr(max3)
  if nx_int(home_locker_level) <= nx_int(0) then
    home_locker_level = 1
  end
  if nx_int(home_locker_level) == nx_int(1) then
    form.lbl_msnaijiu.Text = nx_widestr("100")
  else
    form.lbl_msnaijiu.Text = nx_widestr(times)
  end
  local image_path = "gui\\special\\home\\qiaosuo\\home_lock_" .. nx_string(home_locker_level) .. ".png"
  form.lbl_mstp.BackImage = image_path
end
local ui_home_conditions = {
  "ui_home_goods_01_1",
  "ui_home_goods_02_1",
  "ui_home_goods_03_1",
  "ui_home_goods_04_1",
  "ui_home_goods_05_1",
  "ui_home_goods_06_1"
}
local ui_home_conditions_empty = {
  "ui_home_goods_01_0",
  "ui_home_goods_02_0",
  "ui_home_goods_03_0",
  "ui_home_goods_04_0",
  "ui_home_goods_05_0",
  "ui_home_goods_06_0"
}
function fresh_home_other_msg(form, conf_id, lvl)
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local condition1 = home_manager:GetHomeCondition1(conf_id, lvl)
  local condition2 = home_manager:GetHomeCondition2(conf_id, lvl)
  local condition_list = util_split_string(condition1, ",")
  if table.getn(condition_list) ~= 3 then
    return
  end
  form.cbtn_1.Checked = false
  form.cbtn_2.Checked = false
  form.cbtn_3.Checked = false
  if nx_int(condition_list[1]) == nx_int(1) then
    form.cbtn_1.Checked = true
  end
  if condition_list[2] == 1 then
    form.cbtn_2.Checked = true
  end
  if condition_list[3] == 1 then
    form.cbtn_3.Checked = true
  end
  local condition_list_empty = util_split_string(condition2, ",")
  if table.getn(condition_list_empty) ~= 6 then
    return
  end
  if nx_int(condition_list_empty[1]) == nx_int(0) then
    form.lbl_condition1.Text = nx_widestr(util_text(ui_home_conditions_empty[1]))
  else
    form.lbl_condition1.Text = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[1], nx_int(condition_list_empty[1])))
  end
  if nx_int(condition_list_empty[2]) == nx_int(0) then
    form.lbl_condition2.Text = nx_widestr(util_text(ui_home_conditions_empty[2]))
  else
    form.lbl_condition2.Text = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[2], nx_int(condition_list_empty[2])))
  end
  if nx_int(condition_list_empty[3]) == nx_int(0) then
    form.lbl_condition3.Text = nx_widestr(util_text(ui_home_conditions_empty[3]))
  else
    form.lbl_condition3.Text = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[3], nx_int(condition_list_empty[3])))
  end
  if nx_int(condition_list_empty[4]) == nx_int(0) then
    form.lbl_condition4.Text = nx_widestr(util_text(ui_home_conditions_empty[4]))
  else
    form.lbl_condition4.Text = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[4], nx_int(condition_list_empty[4])))
  end
  if nx_int(condition_list_empty[5]) == nx_int(0) then
    form.lbl_condition5.Text = nx_widestr(util_text(ui_home_conditions_empty[5]))
  else
    form.lbl_condition5.Text = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[5], nx_int(condition_list_empty[5])))
  end
  if nx_int(condition_list_empty[6]) == nx_int(0) then
    form.lbl_condition6.Text = nx_widestr(util_text(ui_home_conditions_empty[6]))
  else
    form.lbl_condition6.Text = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[6], nx_int(condition_list_empty[6])))
  end
end
function clear_detail(form)
  form.home_id = ""
  form.lbl_name.conf_id = 0
  form.lbl_name.home_lvl = 0
  form.lbl_name.hualidu = 0
  form.lbl_name.home_out_lvl = 0
  form.lbl_name.home_out_pretty = 0
  form.lbl_name.Text = nx_widestr("")
  form.lbl_place.Text = nx_widestr("")
  form.groupbox_x:DeleteAll()
  form.groupbox_out_x:DeleteAll()
  form.lbl_style.Text = nx_widestr("")
  form.lbl_jynaijiu.Text = nx_widestr("")
  form.lbl_feiqi.Text = nx_widestr("")
  form.lbl_superb.Text = nx_widestr("")
  form.lbl_pretty_out.Text = nx_widestr("")
  form.lbl_fengshui.Text = nx_widestr("")
  form.lbl_actived_buliding.Text = nx_widestr("")
  form.lbl_huwei.Text = nx_widestr("")
  form.lbl_yahuan_1.Text = nx_widestr("")
  form.lbl_yahuan_2.Text = nx_widestr("")
end
function fresh_home_event(form, home_id, table_grid)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(table_grid) then
    return
  end
  table_grid:ClearRow()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindProp("CurHomeUID") then
    return
  end
  local homeid = nx_string(client_player:QueryProp("CurHomeUID"))
  if homeid == "" or homeid ~= nx_string(home_id) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_HOME_BOX))
  if not nx_is_valid(view) then
    return
  end
  local tablename = {
    {
      "clean_rec",
      "ui_home_myhome_m1"
    },
    {
      "trouble_rec",
      "ui_home_myhome_m2"
    }
  }
  for i = 1, table.maxn(tablename) do
    if view:FindRecord(tablename[i][1]) then
      local rows = view:GetRecordRows(tablename[i][1])
      for j = 0, rows - 1 do
        local uid = nx_string(view:QueryRecord(tablename[i][1], j, 0))
        local name = nx_widestr(view:QueryRecord(tablename[i][1], j, 1))
        local value = nx_number(view:QueryRecord(tablename[i][1], j, 2))
        local time = nx_double(view:QueryRecord(tablename[i][1], j, 3))
        local year, month, day, hour, mins, sec = nx_function("ext_decode_date", nx_double(time))
        local text = util_format_string(nx_string(tablename[i][2]), nx_int(year), nx_int(month), nx_int(day), nx_widestr(name), nx_int(value))
        local row = table_grid:InsertRow(-1)
        table_grid:SetGridText(row, 0, nx_widestr(text))
      end
    end
  end
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
function add_visual_home_list(form, home_id, home_name, owner_name)
  if not nx_is_valid(form) then
    return
  end
  local exist_row = query_visual_home_list_row(form, home_id)
  if nx_number(exist_row) ~= nx_number(-1) then
    return
  end
  local row = form.textgrid_my:InsertRow(-1)
  form.textgrid_my:SetGridText(row, 0, nx_widestr(home_id))
  form.textgrid_my:SetGridText(row, 1, nx_widestr(home_name))
  form.textgrid_my:SetGridText(row, 2, nx_widestr(owner_name))
end
function clear_visual_home_list(form)
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_my:ClearRow()
end
function query_visual_home_list_row(form, home_id)
  if not nx_is_valid(form) then
    return -1
  end
  for i = 0, form.textgrid_my.RowCount - 1 do
    local data = form.textgrid_my:GetGridText(i, 0)
    if nx_string(data) == nx_string(home_id) then
      return i
    end
  end
  return -1
end
function add_self_home_list(form)
  if not nx_is_valid(form) then
    return
  end
  clear_visual_home_list(form)
  local recordname = "self_home_rec"
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local player_name = client_player:QueryProp("Name")
  local nRows = client_player:GetRecordRows(recordname)
  for i = 0, nRows - 1 do
    local home_id = client_player:QueryRecord(recordname, i, 0)
    local home_name = client_player:QueryRecord(recordname, i, 1)
    add_visual_home_list(form, nx_string(home_id), nx_widestr(home_name), nx_widestr(player_name))
  end
  local HomeManager = nx_value("HomeManager")
  if nx_is_valid(HomeManager) then
    local partner_name = HomeManager:GetPartnerName()
    if nx_widestr(partner_name) ~= nx_widestr("") then
      nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_QUERY_PARTNER_HOME_INFO)
    end
  end
  fresh_self_home(form)
end
function add_partner_home_list(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local arg_num = table.getn(arg)
  if nx_number(arg_num) < nx_number(3) then
    return
  end
  local partner_name = nx_widestr(arg[1])
  for i = 2, arg_num, 2 do
    local home_id = nx_string(arg[i])
    local home_name = nx_widestr(arg[i + 1])
    add_visual_home_list(form, nx_string(home_id), nx_widestr(home_name), nx_widestr(partner_name))
  end
  fresh_self_home(form)
end
function default_select_home(form)
  if not nx_is_valid(form) then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  local select_row = 0
  local homeid = get_current_homeid()
  if homeid ~= nx_string("") and (HomeManager:IsMyHome() or HomeManager:IsPartnerHome()) then
    select_row = query_visual_home_list_row(form, homeid)
  end
  if nx_number(select_row) < nx_number(0) or nx_number(select_row) >= nx_number(form.textgrid_my.RowCount) then
    return
  end
  local home_id = form.textgrid_my:GetGridText(select_row, 0)
  local home_name = form.textgrid_my:GetGridText(select_row, 1)
  local home_show_name = get_home_show_name(form, home_id, home_name)
  form.combobox_my.InputEdit.Text = nx_widestr(home_show_name)
  form.lbl_home_name.Text = nx_widestr(home_show_name)
  form.combobox_my.DropListBox.SelectIndex = select_row
  on_combobox_my_selected(form.combobox_my)
end
function get_home_show_name(form, home_id, home_name)
  if not nx_is_valid(form) then
    return nx_widestr("")
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local player_name = client_player:QueryProp("Name")
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return nx_widestr("")
  end
  local partner_name = HomeManager:GetPartnerName()
  for i = 0, form.textgrid_my.RowCount - 1 do
    local homeid = form.textgrid_my:GetGridText(i, 0)
    local homename = form.textgrid_my:GetGridText(i, 1)
    local ownername = form.textgrid_my:GetGridText(i, 2)
    if nx_string(homeid) == nx_string(home_id) and nx_widestr(partner_name) == nx_widestr(ownername) then
      local tips_str = util_text("tips_btn_home_26")
      return nx_widestr(home_name) .. nx_widestr(tips_str)
    end
  end
  return nx_widestr(home_name)
end
function fresh_building_active(...)
  if table.getn(arg) < 2 then
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local home_id = nx_string(arg[1])
  if home_id ~= nx_string(form.home_id) then
    return
  end
  form.lbl_actived_buliding.Text = nx_widestr(arg[2])
  if form.is_villa == 1 then
    form.lbl_actived_buliding.Text = nx_widestr(util_text("ui_home_building_all"))
  end
end
