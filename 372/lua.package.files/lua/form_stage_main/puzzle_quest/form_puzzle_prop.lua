require("util_functions")
require("util_gui")
require("share\\view_define")
local tips_info = {
  lbl_text_level = "tips_gemprop",
  lbl_text_life = "tips_gemprop_nl",
  lbl_pic_red = "tips_gemprop_red",
  lbl_pic_yellow = "tips_gemprop_yellow",
  lbl_pic_blue = "tips_gemprop_blue",
  lbl_pic_green = "tips_gemprop_green",
  lbl_pic_purple = "tips_gemprop_purple",
  pic_armor_back = "tips_gemprop_gj",
  pic_weapon_back = "tips_gemprop_fj",
  lbl_text_damage = "tips_gemprop_sh",
  lbl_text_defence = "tips_gemprop_fyz",
  lbl_text_crit = "tips_gemprop_bjl",
  lbl_text_magic_defence = "tips_gemprop_gjdk",
  lbl_text_magic_hit = "tips_gemprop_gjct"
}
local select_back_color = "99,0,0,155"
local select_back_image = "gui\\common\\selectbar_new\\xz_1.png"
local normal_back_color = "0,0,0,155"
local normal_back_image = ""
local prop_info = {
  vitality = {
    "ui_vitality",
    "gui\\language\\ChineseS\\lifebtn\\z-huo.png"
  },
  energy = {
    "ui_energy",
    "gui\\language\\ChineseS\\lifebtn\\z-qi.png"
  },
  specialty = {
    "ui_specialty",
    "gui\\language\\ChineseS\\lifebtn\\z-cai.png"
  },
  passion = {
    "ui_passion",
    "gui\\language\\ChineseS\\lifebtn\\z-ji.png"
  },
  talent = {
    "ui_talent",
    "gui\\language\\ChineseS\\lifebtn\\z-yi.png"
  }
}
function main_form_init(self)
  self.Fixed = false
  self.grid = nil
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  init_label(self)
  init_image(self)
  init_player_info(self)
  self.pic_vitality.Image = prop_info.vitality[2]
  self.pic_energy.Image = prop_info.energy[2]
  self.pic_specialty.Image = prop_info.specialty[2]
  self.pic_passion.Image = prop_info.passion[2]
  self.pic_talent.Image = prop_info.talent[2]
  local gui = nx_value("gui")
  local w_text = gui.TextManager:GetText(prop_info.vitality[1])
  local text = nx_string(w_text) .. get_obj_prop("Vitality")
  self.lbl_vitality.Text = nx_widestr(text)
  w_text = gui.TextManager:GetText(prop_info.energy[1])
  text = nx_string(w_text) .. get_obj_prop("Energy")
  self.lbl_energy.Text = nx_widestr(text)
  w_text = gui.TextManager:GetText(prop_info.specialty[1])
  text = nx_string(w_text) .. get_obj_prop("Specialty")
  self.lbl_specialty.Text = nx_widestr(text)
  w_text = gui.TextManager:GetText(prop_info.passion[1])
  text = nx_string(w_text) .. get_obj_prop("Passion")
  self.lbl_passion.Text = nx_widestr(text)
  w_text = gui.TextManager:GetText(prop_info.talent[1])
  text = nx_string(w_text) .. get_obj_prop("Talent")
  self.lbl_talent.Text = nx_widestr(text)
  self.groupbox_vitality.prop_name = "Vitality"
  self.groupbox_energy.prop_name = "Energy"
  self.groupbox_specialty.prop_name = "Specialty"
  self.groupbox_passion.prop_name = "Passion"
  self.groupbox_talent.prop_name = "Talent"
  self.pic_armor.Enabled = false
  self.pic_weapon.Enabled = false
end
function on_main_form_close(self)
  nx_destroy(self)
end
function init_menu_item(menu)
  menu:ClearItem()
  for index, i in pairs(prop_info) do
    create_menu_item(menu, index)
  end
end
function init_label(form)
  form.lbl_damage.Text = nx_widestr(get_obj_prop("Damage"))
  form.lbl_defence.Text = nx_widestr(get_obj_prop("Defence"))
  form.lbl_crit.Text = nx_widestr(get_obj_prop("Crit"))
  form.lbl_magic_defence.Text = nx_widestr(get_obj_prop("MagicDefence"))
  form.lbl_magic_hit.Text = nx_widestr(get_obj_prop("MagicHit"))
  form.lbl_level.Text = nx_widestr(get_obj_prop("GemLevel"))
  form.lbl_life.Text = nx_widestr(get_obj_prop("HP"))
end
function init_image(form)
  form.pic_armor.Image = ""
  form.pic_armor.item = nil
  form.pic_weapon.Image = ""
  form.pic_weapon.item = nil
  local weapon, armor = get_weapon_and_armor_item()
  if nx_is_valid(weapon) then
    local weapon_config_id = weapon:QueryProp("ConfigID")
    form.pic_weapon.Image = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(weapon_config_id), nx_string("Photo"))
    form.pic_weapon.Enabled = true
    form.pic_weapon.Visible = true
    form.pic_weapon.item = weapon
    form.pic_weapon_back.Visible = false
  else
    form.pic_weapon.Enabled = false
    form.pic_weapon.Visible = false
  end
  if nx_is_valid(armor) then
    local armor_config_id = armor:QueryProp("ConfigID")
    form.pic_armor.Image = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(armor_config_id), nx_string("Photo"))
    form.pic_armor.Enabled = true
    form.pic_armor.Visible = true
    form.pic_armor.item = armor
    form.pic_armor_back.Visible = false
  else
    form.pic_armor.Enabled = false
    form.pic_armor.Visible = false
  end
end
function init_player_info(form)
  form.lbl_max_red.Text = nx_widestr(get_obj_prop("MaxRed"))
  form.lbl_max_yellow.Text = nx_widestr(get_obj_prop("MaxYellow"))
  form.lbl_max_blue.Text = nx_widestr(get_obj_prop("MaxBlue"))
  form.lbl_max_green.Text = nx_widestr(get_obj_prop("MaxGreen"))
  form.lbl_max_purple.Text = nx_widestr(get_obj_prop("MaxPurple"))
end
function create_menu_item(menu, index)
  local info = prop_info[index]
  if info == nil then
    return false
  end
  local gui = nx_value("gui")
  local w_text = gui.TextManager:GetText(info[1])
  local text = nx_string(w_text) .. get_obj_prop(info[1])
  local count = nx_ws_length(nx_widestr(text))
  local all_text = nx_widestr(text)
  local menu_item = menu:CreateItem(index, all_text)
  local icon = info[2]
  if nx_is_valid(menu_item) then
    menu_item.Icon = icon
  end
  local event_name = "on_" .. index .. "_click"
  local func_name = "on_menu_" .. index .. "_click"
  nx_callback(menu, event_name, func_name)
  return true
end
function on_menu_vitality_click()
end
function on_menu_energy_click()
end
function on_menu_specialty_click()
end
function on_menu_passion_click()
end
function on_menu_talent_click()
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
end
function on_groupbox_get_capture(grid)
  grid.BackColor = select_back_color
  grid.BackImage = select_back_image
end
function on_groupbox_lost_capture(grid)
  grid.BackColor = normal_back_color
  grid.BackImage = normal_back_image
end
function on_pic_prop_get_capture(pic)
  local parent = pic.Parent
  on_groupbox_get_capture(parent)
  local x = pic.AbsLeft
  local y = pic.AbsTop
  nx_execute("tips_game", "show_puzzle_prop", parent.prop_name, x, y, 32, 32)
end
function on_pic_prop_lost_capture(pic)
  local parent = pic.Parent
  on_groupbox_lost_capture(parent)
  nx_execute("tips_game", "hide_tip")
end
function on_pic_get_capture(pic)
  nx_execute("tips_game", "show_goods_tip", pic.item, pic.AbsLeft, pic.AbsTop, 32, 32)
end
function on_pic_lost_capture(pic)
  nx_execute("tips_game", "hide_tip")
end
function get_obj_prop(value)
  return nx_execute("tips_game", "get_gem_obj_prop", value, VIEWPORT_GAME_SUBOBJ_BOX, 1)
end
function get_puzzle_level()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local level = client_player:QueryRecord("job_rec", 0, 1)
  return nx_string(level)
end
function get_job()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local job = client_player:QueryRecord("job_rec", 0, 0)
  return nx_string(job)
end
function get_weapon_and_armor_item()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local view = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return ""
  end
  local weapon_list, armor_list = get_tool_list(get_job())
  local item_list = view:GetViewObjList()
  local weapon_index_list = {}
  local armor_index_list = {}
  local weapon_item_list = {}
  local armor_item_list = {}
  for key, item in pairs(item_list) do
    local config_id = item:QueryProp("ConfigID")
    local is_in, index = is_list(config_id, weapon_list)
    if is_in then
      weapon_index_list[table.getn(weapon_index_list) + 1] = key
      weapon_item_list[table.getn(weapon_item_list) + 1] = config_id
    else
      is_in, index = is_list(config_id, armor_list)
      if is_in then
        armor_index_list[table.getn(armor_index_list) + 1] = key
        armor_item_list[table.getn(armor_item_list) + 1] = config_id
      end
    end
  end
  local weapon_index = 0
  local armor_index = 0
  local is_in = false
  for i, id in pairs(weapon_list) do
    is_in, weapon_index = is_list(id, weapon_item_list)
    if is_in then
      break
    end
  end
  for i, id in pairs(armor_list) do
    is_in, armor_index = is_list(id, armor_item_list)
    if is_in then
      break
    end
  end
  local weapon_item = ""
  local armor_item = ""
  if 0 < weapon_index then
    weapon_item = item_list[weapon_index_list[weapon_index]]
  end
  if 0 < armor_index then
    armor_item = item_list[armor_index_list[armor_index]]
  end
  return weapon_item, armor_item
end
function is_list(id, list)
  for key, node in pairs(list) do
    if nx_string(id) == nx_string(node) then
      return true, key
    end
  end
  return false, 0
end
function get_tool_list(job)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "share\\Life\\GemGameEquip.ini"
  local weapon_list = {}
  local armor_list = {}
  if not ini:LoadFromFile() then
    return weapon_list, armor_list
  end
  local weapon = ini:ReadString(job, "weapon", "")
  local armor = ini:ReadString(job, "armor", "")
  weapon_list = nx_function("ext_split_string", weapon, ",")
  armor_list = nx_function("ext_split_string", armor, ",")
  nx_destroy(ini)
  return weapon_list, armor_list
end
function on_get_control_capture(control)
  show_tips_info(control)
end
function on_lost_control_capture(control)
  hide_tips_info(control)
end
function show_tips_info(control)
  local index = tips_info[control.Name]
  if nil == index then
    return 1
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(nx_string(index))
  gui.TextManager:Format_AddParam(get_obj_prop("GemConfig"))
  local text = gui.TextManager:Format_GetText()
  nx_execute("tips_game", "show_text_tip", text, control.AbsLeft, control.AbsTop, 200, true)
end
function hide_tips_info(control)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_back_click(self)
  local form_job = nx_value("form_stage_main\\form_life\\form_job_main_new")
  if nx_is_valid(form_job) then
    if not form_job.Visible then
      form_job.Visible = true
      form_job:Show()
    end
  else
    util_auto_show_hide_form("form_stage_main\\form_life\\form_job_main_new")
  end
  local form = self.ParentForm
  form:Close()
end
