require("util_functions")
require("util_static_data")
require("util_gui")
local MAIN_FORM_NAME = "form_stage_main\\form_freshman\\form_freshman_main"
local AWARD_TEM = "cloth_huodong_001"
local g_pro_Max = 100
local g_pro_Min = 0
local ST_SNDA_ACTIVITY_JION_MENPAI = 1014
local g_Finish_list = {
  "lilianyindao",
  "zuowangongxiulian",
  "wuguanyindao",
  "dazuotiaoxi",
  "qinggongyindao",
  "anqiyindao",
  "neixiuyindao",
  "bairushimen"
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function util_open_fresman_info(sect, first_flag)
  local form = util_get_form(nx_current(), true)
  if nx_is_valid(form) then
    form.sect = sect
    form.Visible = true
    form:Show()
    if nil ~= first_flag then
      form.first_flag = true
    end
  end
  return true
end
function main_form_init(form)
  form.Fixed = false
  return 1
end
function main_form_open(form)
  change_form_size(form)
  form.lbl_res_1.Visible = false
  form.lbl_res_2.Visible = false
  form.ini = ini
  form.current_page = 1
  set_page(form, 1, form.sect)
  set_res(form, form.sect)
  set_desc(form, form.sect)
  set_sd_join_menpai(form)
end
function set_sd_join_menpai(form)
  local mgr = nx_value("SwitchManager")
  if not nx_is_valid(mgr) then
    return
  end
  local flag = mgr:CheckSwitchEnable(ST_SNDA_ACTIVITY_JION_MENPAI)
  if flag == true then
    local item_query = nx_value("ItemQuery")
    if item_query:FindItemByConfigID(nx_string(AWARD_TEM)) then
      photo = item_query_ArtPack_by_id(AWARD_TEM, "Photo")
    end
    if form.groupbox_1.Visible == false then
      form.groupbox_1.Visible = true
      form.lbl_res_1.Visible = false
      form.lbl_res_2.Visible = false
      form.lbl_9.Visible = false
      form.lbl_10.Visible = false
      form.lbl_1.Visible = false
    end
    form.lbl_res_freshman.BackImage = photo
    form.lbl_res_freshman.res_id = AWARD_TEM
    form.lbl_res_freshman.Visible = true
    local maxcount = table.getn(g_Finish_list)
    local cur = get_curFreshmanPro()
    cur = cur / maxcount * g_pro_Max
    form.pbar_freshman_pro.Minimum = g_pro_Min
    form.pbar_freshman_pro.Maximum = g_pro_Max
    form.pbar_freshman_pro.Value = cur
    form.pbar_freshman_pro.Visible = true
    form.lbl_freshman_pro.Visilbe = true
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("ui_hd_menpai_01")
    text = nx_widestr(text) .. nx_widestr(cur) .. nx_widestr("%")
    form.mltbox_freshman_tip.HtmlText = text
    form.mltbox_freshman_tip.Visible = true
  else
    form.lbl_res_freshman.Visible = false
    form.mltbox_freshman_tip.Visible = false
    form.pbar_freshman_pro.Visible = false
    form.lbl_freshman_pro.Visilbe = false
  end
end
function get_curFreshmanPro()
  local cur = 0
  for i, name in ipairs(g_Finish_list) do
    if not check_node_valid(name) then
      cur = cur + 1
    end
  end
  return cur
end
function check_node_valid(node_name)
  local index = get_node_indx(node_name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_int(-1) == nx_int(index) then
    return false
  end
  local str_rec = client_player:QueryProp("FinishFreshmanRecStr")
  local value = nx_function("get_str_rec_flag", str_rec, index - 1)
  return not value
end
function get_node_indx(node_name)
  local ini_doc = get_ini("share\\Rule\\Freshman.ini")
  if not nx_is_valid(ini_doc) then
    return -1
  end
  local size = ini_doc:GetSectionCount() - 1
  for n_index = 0, size do
    if node_name == ini_doc:GetSectionItemValue(n_index, 0) then
      return nx_number(ini_doc:GetSectionByIndex(n_index))
    end
  end
  return -1
end
function on_btn_close_click(self)
  local form = self.ParentForm
  local main_form = nx_value(MAIN_FORM_NAME)
  if nx_is_valid(main_form) then
    main_form:Close()
  end
  if nx_find_custom(form, "first_flag") then
    local form_main_map = nx_value("form_stage_main\\form_main\\form_main_map")
    local t_x = form_main_map.btn_regulations.AbsLeft
    local t_y = form_main_map.btn_regulations.AbsTop
    local t_w = form_main_map.btn_regulations.Width
    local t_h = form_main_map.btn_regulations.Height
    nx_execute("form_stage_main\\form_helper\\form_move_win", "set_win_info", form.AbsLeft, form.AbsTop, form.Width, form.Height, "", t_x + t_w / 2, t_y + t_h / 2)
  end
  form:Close()
end
function main_form_close(form)
  nx_destroy(form)
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  nx_execute(MAIN_FORM_NAME, "main_form_change", true)
  form:Close()
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  local page = form.current_page
  page = page + 2
  set_page(form, page, form.sect)
end
function on_btn_pre_click(btn)
  local form = btn.ParentForm
  local page = form.current_page
  page = page - 2
  set_page(form, page, form.sect)
end
function on_lbl_res_get_capture(self)
  local form = self.ParentForm
  if not self.Visible then
    return
  end
  if not nx_find_custom(self, "res_id") then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_type = nx_number(ItemQuery:GetItemPropByConfigID(self.res_id, "ItemType"))
  nx_execute("tips_game", "show_tips_common", nx_string(self.res_id), item_type, self.AbsLeft, self.AbsTop, form)
end
function on_lbl_res_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function set_page(form, page, sect)
  local max_page = get_image_info(form, sect, "max")
  if max_page == nil then
    return
  end
  if not nx_find_custom(form, "current_page") then
    return
  end
  local image_key = "image_" .. nx_string(page)
  local info_key = "info_" .. nx_string(page)
  local image = get_image_info(form, sect, image_key)
  local info = get_image_info(form, sect, info_key)
  local gui = nx_value("gui")
  form.lbl_image_1.BackImage = nx_string(image)
  form.mltbox_info_1:Clear()
  form.mltbox_info_1:AddHtmlText(nx_widestr(gui.TextManager:GetText(info)), -1)
  form.lbl_step_1.Text = nx_widestr(gui.TextManager:GetText("ui_step_" .. nx_string(page)))
  image_key = "image_" .. nx_string(page + 1)
  info_key = "info_" .. nx_string(page + 1)
  image = get_image_info(form, sect, image_key)
  info = get_image_info(form, sect, info_key)
  form.lbl_image_2.BackImage = nx_string(image)
  form.mltbox_info_1:AddHtmlText(nx_widestr(gui.TextManager:GetText(info)), -1)
  form.lbl_step_2.Text = nx_widestr(gui.TextManager:GetText("ui_step_" .. nx_string(page + 1)))
  form.current_page = page
  if 2 == nx_number(max_page) then
    form.btn_next.Enabled = false
    form.btn_pre.Enabled = false
  elseif nx_number(max_page) / 2 < form.current_page then
    form.btn_next.Enabled = false
    form.btn_pre.Enabled = true
  elseif 1 == form.current_page then
    form.btn_next.Enabled = true
    form.btn_pre.Enabled = false
  end
end
function set_res(form, key)
  form.lbl_res_1.Visible = false
  form.lbl_res_2.Visible = false
  form.lbl_9.Visible = false
  form.lbl_10.Visible = false
  local info = get_image_info(form, "res", key)
  if info == nil or info == "" then
    form.groupbox_1.Visible = false
    return
  end
  local photo = ""
  local list = util_split_string(info, ",")
  local conf_id = list[1]
  local item_query = nx_value("ItemQuery")
  if nil == conf_id then
    return
  end
  if item_query:FindItemByConfigID(conf_id) then
    photo = item_query_ArtPack_by_id(conf_id, "Photo")
  end
  form.lbl_res_1.BackImage = photo
  form.lbl_res_1.res_id = conf_id
  form.lbl_res_1.Visible = true
  form.lbl_9.Visible = true
  if 2 == table.getn(list) then
    conf_id = list[2]
    if item_query:FindItemByConfigID(conf_id) then
      photo = item_query_ArtPack_by_id(conf_id, "Photo")
    end
    form.lbl_res_2.BackImage = photo
    form.lbl_res_2.res_id = conf_id
    form.lbl_res_2.Visible = true
    form.lbl_10.Visible = true
  end
end
function set_desc(form, key)
  local info = get_image_info(form, "desc", key)
  if info == nil then
    return
  end
  local gui = nx_value("gui")
  form.mltbox_desc:Clear()
  form.mltbox_desc:AddHtmlText(nx_widestr(gui.TextManager:GetText(nx_string(info))), -1)
  local title = gui.TextManager:GetText("ui_" .. nx_string(key))
  form.lbl_title.Text = nx_widestr(title)
end
function get_image_info(form, sect, key)
  if not nx_find_custom(form, "current_page") then
    return nil
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\freshman\\particularize_info.ini")
  if nx_is_valid(ini) then
    local index = ini:FindSectionIndex(sect)
    if -1 == index then
      return nil
    end
    local value = ini:ReadString(index, key, "")
    return value
  end
  return nil
end
function change_form_size(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  form.Left = (desktop.Width - form.Width) / 2
  form.Top = (desktop.Height - form.Height) / 2
end
function on_mltbox_info_click_hyperlink(self)
  on_btn_close_click(self)
end
