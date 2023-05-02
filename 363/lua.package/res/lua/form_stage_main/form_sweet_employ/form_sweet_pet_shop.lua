require("util_functions")
require("share\\view_define")
require("form_stage_main\\form_sweet_employ\\form_offline_employee_utils")
require("util_static_data")
require("share\\static_data_type")
require("custom_handler")
local SHOW_NUM = 9
local SHOP_CLASS_INI = "share\\SweetEmploy\\shop\\shopclass.ini"
local SHOP_ITEM_INI = "share\\SweetEmploy\\shop\\shopitem.ini"
local SWEET_TYPE_BUY_CLOTHES_YZ = 1
local SWEET_TYPE_BUY_CLOTHES_HD = 2
local SWEET_TYPE_CLOTHES_EQUIP = 3
local SWEET_TYPE_CLOTHES_UNEQUIP = 4
local SWEET_TYPE_BUY_ITEM_YZ = 5
local SWEET_TYPE_BUY_ITEM_HD = 6
local SHOP_CLOTHES = 1
local SHOP_MED = 2
local SHOP_WUXUE = 3
local FORM_PATH = "form_stage_main\\form_sweet_employ\\form_sweet_pet_shop"
function show_form()
  if not check_player() then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_PATH, true)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible == true then
    form.Visible = false
    form:Close()
    return
  end
  if not on_init_form_data(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function copy_ent_info(dest, src)
  if not nx_is_valid(src) or not nx_is_valid(dest) then
    return
  end
  local prop_list = nx_property_list(src)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(dest, prop, nx_property(src, prop))
    end
  end
end
function on_init_form_data(form)
  if not nx_is_valid(form) then
    return false
  end
  show_sweet_model(form.scenebox_1)
  return true
end
function on_main_form_init(self)
  self.shopclassini = nx_null()
  self.shopiteminfo = nx_null()
  self.max_page = 0
  self.min_page = 0
  self.sel_page = 0
  self.sel_index = 0
  self.sel_class = SHOP_CLOTHES
  self.Fixed = false
end
function on_main_form_open(self)
  self.max_page = 0
  self.min_page = 0
  self.sel_page = 0
  self.sel_index = 0
  self.sel_class = SHOP_CLOTHES
  self.shopclassini = nx_null()
  self.shopiteminfo = nx_null()
  self.gb_temp_data.Visible = false
  self.gb_temp_cloth.Visible = false
  load_ini(self)
  change_pet_clothes(self.scenebox_1)
  on_create_page_info(self.groupbox_clothes, self.gb_temp_cloth, SHOP_CLOTHES)
  on_create_page_info(self.groupbox_item, self.gb_temp_data, SHOP_MED)
  self.btn_page_pre.Enabled = false
  self.rbtn_item_type_1.Checked = true
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("RedBeanValue", "double", self, nx_current(), "refresh_redbead")
  end
  on_show_redbead(self)
end
function refresh_redbead(form, prop_name, prop_type, prop_value)
  on_show_redbead(form)
end
function on_show_redbead(form)
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local value = player:QueryProp("RedBeanValue")
  form.lbl_redbean.Text = nx_widestr(nx_int(value))
end
function change_pet_clothes(scenebox)
  if not nx_is_valid(scenebox) then
    return
  end
  if not nx_find_custom(scenebox, "role_actor2") then
    return
  end
  local actor2 = scenebox.role_actor2
  if not nx_is_valid(actor2) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindProp("SweetEmployClothes") then
    return
  end
  local clothes = player:QueryProp("SweetEmployClothes")
  if clothes == "" then
    return
  end
  local form = scenebox.ParentForm
  if not nx_is_valid(form.shopiteminfo) then
    return
  end
  local sec_index = form.shopiteminfo:FindSectionIndex(clothes)
  if sec_index < 0 then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local _, sex, body_type = get_pet_cloth_and_sex()
  if sex == nil then
    return
  end
  local work_cloth = form.shopiteminfo:ReadString(sec_index, "workcloth", "")
  actor2.body_type_fake = body_type
  role_composite:link_pet_fashion_cloth(actor2, sex, work_cloth)
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function on_main_form_close(self)
  local ini_mgr = nx_value("IniManager")
  if nx_is_valid(ini_mgr) then
    ini_mgr:UnloadIniFromManager(SHOP_CLASS_INI)
    ini_mgr:UnloadIniFromManager(SHOP_ITEM_INI)
  end
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelRolePropertyBind("RedBeanValue", self)
  end
  nx_destroy(self)
end
function load_ini(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.shopclassini) and nx_is_valid(form.shopiteminfo) then
    return
  end
  local ini = get_ini(SHOP_CLASS_INI, true)
  if not nx_is_valid(ini) then
    return
  end
  form.shopclassini = ini
  ini = get_ini(SHOP_ITEM_INI, true)
  if not nx_is_valid(ini) then
    return
  end
  form.shopiteminfo = ini
end
function on_rbtn_item_type_checked_changed(rbtn)
  if rbtn.Checked ~= true then
    return
  end
  local form = rbtn.ParentForm
  load_ini(form)
  if nx_string(rbtn.DataSource) == nx_string("clothes") then
    on_set_page_maxmin(form, SHOP_CLOTHES)
    on_set_page_info(form, SHOP_CLOTHES, 1)
  elseif nx_string(rbtn.DataSource) == nx_string("med") then
    on_set_page_maxmin(form, SHOP_MED)
    on_set_page_info(form, SHOP_MED, 1)
  elseif nx_string(rbtn.DataSource) == nx_string("wuxue") then
    on_set_page_maxmin(form, SHOP_WUXUE)
    on_set_page_info(form, SHOP_WUXUE, 1)
  end
end
function on_set_page_maxmin(form, item_class)
  if not (nx_is_valid(form) and nx_is_valid(form.shopclassini)) or not nx_is_valid(form.shopiteminfo) then
    return
  end
  local shopclass = form.shopclassini
  local shopitem = form.shopiteminfo
  local sec_index = shopclass:FindSectionIndex(nx_string(item_class))
  if sec_index < 0 then
    return
  end
  local count = shopclass:GetSectionItemCount(sec_index)
  local page = count / SHOW_NUM
  if nx_int(count % SHOW_NUM) > nx_int(0) then
    page = page + 1
  end
  form.min_page = 1
  form.max_page = page
  form.btn_page_pre.Enabled = false
  form.btn_page_next.Enabled = true
  if nx_int(form.max_page) <= nx_int(form.min_page) then
    form.btn_page_next.Enabled = false
  end
end
function on_set_page_info(form, item_class, page_index)
  if nx_int(page_index) > nx_int(form.max_page) or nx_int(page_index) < nx_int(1) then
    return
  end
  local shopclass = form.shopclassini
  local shopitem = form.shopiteminfo
  local sec_index = shopclass:FindSectionIndex(nx_string(item_class))
  if sec_index < 0 then
    return
  end
  local count = shopclass:GetSectionItemCount(sec_index)
  local begin_index = (page_index - 1) * SHOW_NUM
  local end_index = begin_index + SHOW_NUM
  if count < end_index then
    end_index = count
  end
  form.sel_page = page_index
  form.sel_class = item_class
  local gb_index = 1
  form.groupbox_clothes.Visible = false
  form.groupbox_item.Visible = false
  reset_page_vis(form, false)
  for i = begin_index, end_index - 1 do
    local item_config = shopclass:GetSectionItemValue(sec_index, i)
    local item_index = shopitem:FindSectionIndex(item_config)
    if 0 <= item_index then
      local money_yz = shopitem:ReadInteger(item_index, "yz", 0)
      local money_hd = shopitem:ReadInteger(item_index, "hd", 0)
      if item_config ~= "" and 0 <= money_yz and 0 <= money_hd and on_set_groupbox_item_info(form, gb_index, item_config, money_yz, money_hd) then
        gb_index = gb_index + 1
      end
    end
  end
  form.lbl_cur_page.Text = nx_widestr(nx_int(form.sel_page)) .. nx_widestr("/") .. nx_widestr(nx_int(form.max_page))
end
function reset_page_vis(form, vis)
  if not nx_is_valid(form) then
    return
  end
  local gb_show = nx_null()
  if form.sel_class == SHOP_CLOTHES then
    gb_show = form.groupbox_clothes
  elseif form.sel_class == SHOP_MED then
    gb_show = form.groupbox_item
  elseif form.sel_class == SHOP_WUXUE then
    gb_show = form.groupbox_item
  end
  if not nx_is_valid(gb_show) then
    return
  end
  gb_show.Visible = true
  local table_child = gb_show:GetChildControlList()
  local count = table.getn(table_child)
  for i = 1, count do
    local gb_item = table_child[i]
    if nx_is_valid(gb_item) and gb_item.IsContainer then
      gb_item.Visible = vis
    end
  end
end
function on_create_page_info(groupbox, data_temp, item_class)
  if not nx_is_valid(groupbox) or not nx_is_valid(data_temp) then
    return
  end
  local gb_info = nx_null()
  for i = 1, SHOW_NUM do
    if item_class == SHOP_CLOTHES then
      gb_info = on_create_item(data_temp, i)
    elseif item_class == SHOP_MED then
      gb_info = on_create_item_t(data_temp, i)
    elseif item_class == SHOP_WUXUE then
      gb_info = on_create_item_t(data_temp, i)
    end
    if nx_is_valid(gb_info) then
      local top = nx_int((i - 1) / 3)
      local left = nx_int((i - 1) % 3)
      gb_info.Left = left * nx_int(gb_info.Width)
      gb_info.Top = top * nx_int(gb_info.Height)
      groupbox:Add(gb_info)
    end
  end
end
function on_clear_page_info(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_page_info = form.groupbox_item
  local table_child = gb_page_info:GetChildControlList()
  local count = table.getn(table_child)
  for i = 1, count do
    local gb_item = table_child[i]
    if nx_is_valid(gb_item) and gb_item.IsContainer then
      gb_item:DeleteAll()
    end
  end
  gb_page_info:DeleteAll()
end
function on_create_item(groupbox_show, index)
  if not nx_is_valid(groupbox_show) then
    return nx_null()
  end
  local gui = nx_value("gui")
  local gb_item = gui:Create("GroupBox")
  if not nx_is_valid(gb_item) then
    return nx_null()
  end
  local table_child = groupbox_show:GetChildControlList()
  local count = table.getn(table_child)
  for i = 1, count do
    local src_child = table_child[i]
    local ctl_child = gui:Create(nx_name(src_child))
    if nx_is_valid(ctl_child) then
      copy_ent_info(ctl_child, table_child[i])
      local child_name = src_child.Name
      if child_name == "lbl_pic" then
        nx_bind_script(ctl_child, nx_current())
        nx_callback(ctl_child, "on_lost_capture", "on_lbl_pic_lost_capture")
        nx_callback(ctl_child, "on_get_capture", "on_lbl_pic_get_capture")
      elseif child_name == "btn_buy" then
        nx_bind_script(ctl_child, nx_current())
        nx_callback(ctl_child, "on_click", "on_btn_buy_click")
      elseif child_name == "btn_change" then
        nx_bind_script(ctl_child, nx_current())
        nx_callback(ctl_child, "on_click", "on_btn_change_click")
      elseif child_name == "btn_equip" then
        nx_bind_script(ctl_child, nx_current())
        nx_callback(ctl_child, "on_click", "on_btn_equip_click")
      elseif child_name == "btn_unequip" then
        nx_bind_script(ctl_child, nx_current())
        nx_callback(ctl_child, "on_click", "on_btn_unequip_click")
      end
      ctl_child.Name = child_name .. "_" .. nx_string(index)
      gb_item:Add(ctl_child)
    end
  end
  copy_ent_info(gb_item, groupbox_show)
  nx_bind_script(gb_item, nx_current())
  nx_callback(gb_item, "on_lost_capture", "on_groupbox_lost_capture")
  nx_callback(gb_item, "on_get_capture", "on_groupbox_get_capture")
  gb_item.clothes_name = ""
  gb_item.clothes_yz = 0
  gb_item.clothes_hd = 0
  gb_item.index = index
  return gb_item
end
function on_create_item_t(groupbox_show, index)
  if not nx_is_valid(groupbox_show) then
    return nx_null()
  end
  local gui = nx_value("gui")
  local gb_item = gui:Create("GroupBox")
  if not nx_is_valid(gb_item) then
    return nx_null()
  end
  local table_child = groupbox_show:GetChildControlList()
  local count = table.getn(table_child)
  for i = 1, count do
    local src_child = table_child[i]
    local ctl_child = gui:Create(nx_name(src_child))
    if nx_is_valid(ctl_child) then
      copy_ent_info(ctl_child, table_child[i])
      local child_name = src_child.Name
      if child_name == "lbl_t_pic" then
        nx_bind_script(ctl_child, nx_current())
        nx_callback(ctl_child, "on_lost_capture", "on_lbl_pic_lost_capture")
        nx_callback(ctl_child, "on_get_capture", "on_lbl_pic_get_capture")
      elseif child_name == "btn_t_buy" then
        nx_bind_script(ctl_child, nx_current())
        nx_callback(ctl_child, "on_click", "on_btn_buy_click")
      elseif child_name == "btn_t_change" then
        nx_bind_script(ctl_child, nx_current())
        nx_callback(ctl_child, "on_click", "on_btn_change_click")
      end
      ctl_child.Name = child_name .. "_" .. nx_string(index)
      gb_item:Add(ctl_child)
    end
  end
  copy_ent_info(gb_item, groupbox_show)
  nx_bind_script(gb_item, nx_current())
  nx_callback(gb_item, "on_lost_capture", "on_groupbox_lost_capture")
  nx_callback(gb_item, "on_get_capture", "on_groupbox_get_capture")
  gb_item.clothes_name = ""
  gb_item.clothes_yz = 0
  gb_item.clothes_hd = 0
  gb_item.index = index
  return gb_item
end
function on_set_groupbox_item_info(form, index, item_config, yz, hd)
  if not nx_is_valid(form) then
    return false
  end
  local gb_show = nx_null()
  if form.sel_class == SHOP_CLOTHES then
    gb_show = form.groupbox_clothes
  elseif form.sel_class == SHOP_MED then
    gb_show = form.groupbox_item
  elseif form.sel_class == SHOP_WUXUE then
    gb_show = form.groupbox_item
  end
  if not nx_is_valid(gb_show) then
    return false
  end
  local child_list = gb_show:GetChildControlList()
  local count = table.getn(child_list)
  if index > count then
    return false
  end
  local gb_item = child_list[index]
  if not nx_is_valid(gb_item) then
    return false
  end
  local bret = false
  if form.sel_class == SHOP_CLOTHES then
    bret = on_set_clothes_info(gb_item, item_config, yz, hd)
  elseif form.sel_class == SHOP_MED then
    bret = on_set_item_info(gb_item, item_config, yz, hd)
  elseif form.sel_class == SHOP_WUXUE then
    bret = on_set_item_info(gb_item, item_config, yz, hd)
  end
  return bret
end
function on_set_clothes_info(gb_item, config, yz, hd)
  local pic, lbl_name, mltbox_yz, mltbox_hd = get_show_ctl(gb_item)
  if not (nx_is_valid(pic) and nx_is_valid(lbl_name) and nx_is_valid(mltbox_yz)) or not nx_is_valid(mltbox_hd) then
    return false
  end
  local btn_yz, btn_hd, btn_equip, btn_unequip = get_show_btn_ctl(gb_item)
  if not (nx_is_valid(btn_yz) and nx_is_valid(btn_hd) and nx_is_valid(btn_equip)) or not nx_is_valid(btn_unequip) then
    return false
  end
  local gui = nx_value("gui")
  pic.BackImage = item_query_ArtPack_by_id(config, "Photo")
  lbl_name.Text = gui.TextManager:GetText(config)
  mltbox_yz.Visible = false
  btn_yz.Enabled = false
  btn_hd.Enabled = false
  mltbox_hd.Visible = false
  if nx_int(yz) <= nx_int(0) then
    mltbox_yz.Visible = false
    btn_yz.Enabled = false
  else
    gui.TextManager:Format_SetIDName("ui_sweetemploy_shop11")
    gui.TextManager:Format_AddParam(nx_int(yz))
    local text = gui.TextManager:Format_GetText()
    mltbox_yz.HtmlText = text
    mltbox_yz.Visible = true
    btn_yz.Enabled = true
  end
  if nx_double(hd) <= nx_double(0) then
    btn_hd.Enabled = false
    mltbox_hd.Visible = false
  else
    gui.TextManager:Format_SetIDName("ui_sweetemploy_shop12")
    gui.TextManager:Format_AddParam(nx_int(hd))
    text = gui.TextManager:Format_GetText()
    mltbox_hd.HtmlText = text
    btn_hd.Enabled = true
    mltbox_hd.Visible = true
  end
  gb_item.clothes_name = config
  gb_item.clothes_hd = hd
  gb_item.clothes_yz = yz
  gb_item.Visible = true
  btn_yz.Visible = false
  btn_hd.Visible = false
  btn_equip.Visible = false
  btn_unequip.Visible = false
  if check_has_item(config) == true then
    btn_equip.Visible = true
    btn_unequip.Visible = true
  else
    btn_yz.Visible = true
    btn_hd.Visible = true
  end
  return true
end
function on_set_item_info(gb_item, item_config, yz, hd)
  local pic, lbl_name, mltbox_yz, mltbox_hd = get_show_ctl(gb_item)
  if not (nx_is_valid(pic) and nx_is_valid(lbl_name) and nx_is_valid(mltbox_yz)) or not nx_is_valid(mltbox_hd) then
    return false
  end
  local buy_yz, buy_hd = get_show_btn_ctl(gb_item)
  if not nx_is_valid(buy_yz) or not nx_is_valid(buy_hd) then
    return false
  end
  pic.BackImage = item_query_ArtPack_by_id(item_config, "Photo")
  local gui = nx_value("gui")
  lbl_name.Text = gui.TextManager:GetText(item_config)
  mltbox_yz.Visible = false
  buy_yz.Enabled = false
  buy_hd.Enabled = false
  mltbox_hd.Visible = false
  if nx_int(yz) <= nx_int(0) then
    mltbox_yz.Visible = false
    buy_yz.Enabled = false
  else
    gui.TextManager:Format_SetIDName("ui_sweetemploy_shop11")
    gui.TextManager:Format_AddParam(nx_int(yz))
    local text = gui.TextManager:Format_GetText()
    mltbox_yz.HtmlText = text
    mltbox_yz.Visible = true
    buy_yz.Enabled = true
  end
  if nx_double(hd) <= nx_double(0) then
    mltbox_hd.Visible = false
    buy_hd.Enabled = false
  else
    gui.TextManager:Format_SetIDName("ui_sweetemploy_shop12")
    gui.TextManager:Format_AddParam(nx_int(hd))
    text = gui.TextManager:Format_GetText()
    mltbox_hd.HtmlText = text
    mltbox_hd.Visible = true
    buy_hd.Enabled = true
  end
  gb_item.clothes_name = item_config
  gb_item.clothes_hd = hd
  gb_item.clothes_yz = yz
  gb_item.Visible = true
  return true
end
function get_show_ctl(gb_item)
  if not nx_is_valid(gb_item) then
    return nx_null(), nx_null(), nx_null(), nx_null()
  end
  local pic = nx_null()
  local lbl_name = nx_null()
  local mltbox_yz = nx_null()
  local mltbox_hd = nx_null()
  local child_list = gb_item:GetChildControlList()
  local count = table.getn(child_list)
  for i = 1, count do
    local child = child_list[i]
    if nx_is_valid(child) then
      if child.Name == "lbl_pic_" .. nx_string(gb_item.index) then
        pic = child
      elseif child.Name == "lbl_c_name_" .. nx_string(gb_item.index) then
        lbl_name = child
      elseif child.Name == "mltbox_buy_gy_" .. nx_string(gb_item.index) then
        mltbox_yz = child
      elseif child.Name == "mltbox_buy_hd_" .. nx_string(gb_item.index) then
        mltbox_hd = child
      elseif child.Name == "lbl_t_pic_" .. nx_string(gb_item.index) then
        pic = child
      elseif child.Name == "lbl_t_name_" .. nx_string(gb_item.index) then
        lbl_name = child
      elseif child.Name == "mltbox_t_buy_gy_" .. nx_string(gb_item.index) then
        mltbox_yz = child
      elseif child.Name == "mltbox_t_buy_hd_" .. nx_string(gb_item.index) then
        mltbox_hd = child
      end
    end
  end
  return pic, lbl_name, mltbox_yz, mltbox_hd
end
function get_show_btn_ctl(gb_item)
  if not nx_is_valid(gb_item) then
    return nx_null(), nx_null(), nx_null(), nx_null()
  end
  local btn_yz = nx_null()
  local btn_hd = nx_null()
  local btn_equip = nx_null()
  local btn_unequip = nx_null()
  local child_list = gb_item:GetChildControlList()
  local count = table.getn(child_list)
  for i = 1, count do
    local child = child_list[i]
    if nx_is_valid(child) then
      if child.Name == "btn_buy_" .. nx_string(gb_item.index) then
        btn_yz = child
      elseif child.Name == "btn_change_" .. nx_string(gb_item.index) then
        btn_hd = child
      elseif child.Name == "btn_equip_" .. nx_string(gb_item.index) then
        btn_equip = child
      elseif child.Name == "btn_unequip_" .. nx_string(gb_item.index) then
        btn_unequip = child
      elseif child.Name == "btn_t_buy_" .. nx_string(gb_item.index) then
        btn_yz = child
      elseif child.Name == "btn_t_change_" .. nx_string(gb_item.index) then
        btn_hd = child
      end
    end
  end
  return btn_yz, btn_hd, btn_equip, btn_unequip
end
function on_lbl_pic_get_capture(lbl)
  local gb_item = lbl.Parent
  if not nx_is_valid(gb_item) then
    return
  end
  if not nx_find_custom(gb_item, "clothes_name") then
    return
  end
  if gb_item.clothes_name == "" then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local itemid = gb_item.clothes_name
  nx_execute("tips_game", "show_tips_by_config", itemid, x, y, lbl.ParentForm)
end
function on_lbl_pic_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_buy_click(btn)
  local gb_item = btn.Parent
  local form = btn.ParentForm
  if not nx_is_valid(gb_item) then
    return
  end
  if not nx_find_custom(gb_item, "clothes_name") then
    return
  end
  if not nx_find_custom(gb_item, "clothes_yz") then
    return
  end
  if not check_player() then
    return
  end
  local config = gb_item.clothes_name
  local money_yz = gb_item.clothes_yz
  if config == "" or nx_int(money_yz) <= nx_int(0) then
    return
  end
  if not check_need_cost("buy", money_yz, -1) then
    custom_sysinfo(1, 1, 1, 2, "11392")
    return
  end
  if not check_player_charmlv(form, config) then
    custom_sysinfo(1, 1, 1, 2, "21365")
    return
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("21363")
  gui.TextManager:Format_AddParam(config)
  gui.TextManager:Format_AddParam(nx_int(money_yz))
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "sweet_pet_buy_yz")
  if nx_is_valid(dialog) then
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
  end
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "sweet_pet_buy_yz_confirm_return")
    if res == "ok" then
      local op_type = on_get_useshop_type(form.sel_class, "buy")
      nx_execute("custom_sender", "custom_msg_sweet_pet_clothes", gb_item.clothes_name, op_type)
      form.sel_index = gb_item.index
    end
  end
end
function on_btn_change_click(btn)
  local gb_item = btn.Parent
  local form = btn.ParentForm
  if not nx_is_valid(gb_item) then
    return
  end
  if not nx_find_custom(gb_item, "clothes_name") then
    return
  end
  if not nx_find_custom(gb_item, "clothes_hd") then
    return
  end
  local config = gb_item.clothes_name
  local money_hd = gb_item.clothes_hd
  if config == "" or nx_double(money_hd) <= nx_double(0) then
    return
  end
  if not check_player() then
    return
  end
  if not check_need_cost("change", -1, money_hd) then
    custom_sysinfo(1, 1, 1, 2, "11393")
    return
  end
  if not check_player_charmlv(form, config) then
    custom_sysinfo(1, 1, 1, 2, "21366")
    return
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("21364")
  gui.TextManager:Format_AddParam(config)
  gui.TextManager:Format_AddParam(nx_int(money_hd))
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "sweet_pet_buy_hd")
  if nx_is_valid(dialog) then
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
  end
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "sweet_pet_buy_hd_confirm_return")
    if res == "ok" then
      local op_type = on_get_useshop_type(form.sel_class, "change")
      nx_execute("custom_sender", "custom_msg_sweet_pet_clothes", gb_item.clothes_name, op_type)
      form.sel_index = gb_item.index
    end
  end
end
function on_get_useshop_type(sel_class, btn_type)
  if sel_class == SHOP_CLOTHES then
    if btn_type == "buy" then
      return SWEET_TYPE_BUY_CLOTHES_YZ
    elseif btn_type == "change" then
      return SWEET_TYPE_BUY_CLOTHES_HD
    end
  elseif sel_class == SHOP_MED then
    if btn_type == "buy" then
      return SWEET_TYPE_BUY_ITEM_YZ
    elseif btn_type == "change" then
      return SWEET_TYPE_BUY_ITEM_HD
    end
  elseif sel_class == SHOP_WUXUE then
    if btn_type == "buy" then
      return SWEET_TYPE_BUY_ITEM_YZ
    elseif btn_type == "change" then
      return SWEET_TYPE_BUY_ITEM_HD
    end
  end
  return 0
end
function on_btn_equip_click(btn)
  local gb_item = btn.Parent
  if not nx_is_valid(gb_item) then
    return
  end
  if not nx_find_custom(gb_item, "clothes_name") then
    return
  end
  if not check_player() then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  nx_execute("custom_sender", "custom_msg_sweet_pet_clothes", gb_item.clothes_name, SWEET_TYPE_CLOTHES_EQUIP)
end
function on_btn_unequip_click(btn)
  local gb_item = btn.Parent
  if not nx_is_valid(gb_item) then
    return
  end
  if not nx_find_custom(gb_item, "clothes_name") then
    return
  end
  if not check_player() then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  if player:FindProp("SweetEmployClothes") then
    local clothes = player:QueryProp("SweetEmployClothes")
    if nx_string(clothes) ~= nx_string(gb_item.clothes_name) then
      return
    end
  end
  nx_execute("custom_sender", "custom_msg_sweet_pet_clothes", gb_item.clothes_name, SWEET_TYPE_CLOTHES_UNEQUIP)
end
function on_groupbox_get_capture(groupbox)
end
function on_groupbox_lost_capture(groupbox)
end
function on_btn_page_go_click(btn)
  local form = btn.ParentForm
  local text = form.ipt_1.Text
  local page = nx_int(text)
  if nx_int(form.max_page) == nx_int(form.min_page) then
    form.btn_page_pre.Enabled = false
    form.btn_page_next.Enabled = false
  else
    form.btn_page_pre.Enabled = true
    form.btn_page_next.Enabled = true
  end
  if nx_int(page) <= nx_int(form.min_page) then
    form.btn_page_pre.Enabled = false
  elseif nx_int(page) >= nx_int(form.max_page) then
    form.btn_page_next.Enabled = false
  end
  load_ini(form)
  on_set_page_info(form, form.sel_class, nx_int(text))
end
function on_btn_page_pre_click(btn)
  local form = btn.ParentForm
  local page = form.sel_page
  page = page - 1
  if nx_int(page) <= nx_int(form.min_page) then
    btn.Enabled = false
  end
  if form.btn_page_next.Enabled == false and nx_int(form.max_page) > nx_int(form.min_page) then
    form.btn_page_next.Enabled = true
  end
  load_ini(form)
  on_set_page_info(form, form.sel_class, page)
end
function on_btn_page_next_click(btn)
  local form = btn.ParentForm
  local page = form.sel_page
  page = page + 1
  if nx_int(page) >= nx_int(form.max_page) then
    btn.Enabled = false
  end
  if form.btn_page_pre.Enabled == false and nx_int(form.max_page) > nx_int(form.min_page) then
    form.btn_page_pre.Enabled = true
  end
  load_ini(form)
  on_set_page_info(form, form.sel_class, page)
end
function on_btn_exit_click(btn)
  local form = btn.ParentForm
  on_main_form_close(form)
end
function check_has_item(itemcfg)
  local bhas = false
  bhas = check_item_by_equipbox(itemcfg)
  if bhas == true then
    return true
  end
  local goodgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodgrid) then
    return false
  end
  if goodgrid:GetItemCount(itemcfg) > 0 then
    return true
  end
  return false
end
function check_item_by_equipbox(item_cfg)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP))
  if nx_is_valid(view) then
    local count = view:GetViewObjCount()
    for j = 1, count do
      local itemobj = view:GetViewObjByIndex(j - 1)
      local tempid = itemobj:QueryProp("ConfigID")
      if nx_string(tempid) == nx_string(item_cfg) then
        return true
      end
    end
  end
  return false
end
function check_need_cost(btn_type, yz, hd)
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if btn_type == "buy" then
    local capital = nx_value("CapitalModule")
    if not nx_is_valid(capital) then
      return false
    end
    return capital:CanDecCapital(nx_int(2), nx_int64(yz))
  elseif btn_type == "change" then
    local redbean = player:QueryProp("RedBeanValue")
    local dec = nx_double(redbean) - nx_double(hd)
    if nx_double(dec) < nx_double(0) then
      return false
    end
    return true
  end
  return false
end
function check_player()
  if IsBuildEmployRelation() and IsOpenFormOfflineEmp() then
    return true
  end
  return false
end
function on_equip_pet(form, itemcfg)
  if not nx_is_valid(form) then
    return
  end
  load_ini(form)
  change_pet_clothes(form.scenebox_1)
end
function on_unequip_pet(form, itemcfg)
  if not nx_is_valid(form) then
    return
  end
  load_ini(form)
  show_sweet_model(form.scenebox_1)
end
function get_pet_cloth_and_sex()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil, nil
  end
  local table_name = "rec_pet_show"
  if not client_player:FindRecord(table_name) then
    return nil, nil
  end
  local rows = client_player:GetRecordRows(table_name)
  if rows ~= 1 then
    return nil, nil
  end
  local row = 0
  local cloth = nx_string(client_player:QueryRecord(table_name, row, 4))
  local sex = nx_int(client_player:QueryRecord(table_name, row, 9))
  local body_type = nx_int(client_player:QueryRecord(table_name, row, 14))
  return cloth, sex, body_type
end
function on_left_click(btn)
  btn.MouseDown = false
end
function on_left_lost_capture(btn)
  btn.MouseDown = false
end
function on_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) or not nx_is_valid(form.scenebox_1) then
      break
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_1, dist)
  end
end
function on_right_click(btn)
  btn.MouseDown = false
end
function on_right_lost_capture(btn)
  btn.MouseDown = false
end
function on_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) or not nx_is_valid(form.scenebox_1) then
      break
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_1, dist)
  end
end
function check_player_charmlv(form, itemconfig)
  if not nx_is_valid(form) then
    return false
  end
  local shopitem = form.shopiteminfo
  if not nx_is_valid(shopitem) then
    return false
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  local item_index = shopitem:FindSectionIndex(itemconfig)
  if item_index < 0 then
    return false
  end
  local charmlv = shopitem:ReadInteger(item_index, "charmlv", 0)
  local self_lv = player:QueryProp("CharmLevel")
  if nx_int(self_lv) < nx_int(charmlv) then
    return false
  end
  return true
end
function on_refresh_form()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible ~= true then
    return
  end
  load_ini(form)
  on_set_page_info(form, form.sel_class, form.sel_page)
end
