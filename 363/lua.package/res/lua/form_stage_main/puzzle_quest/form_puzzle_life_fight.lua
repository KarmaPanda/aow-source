require("util_functions")
require("util_gui")
require("share\\view_define")
require("share\\client_custom_define")
local TEMP_SKILL_REC = "TempGemSkillRec"
local SKILL_REC = "GemSkillRec"
local JOB_GEM_SKILL_REC = "JobGemSkillRec"
local ENERGY_PIC_PATH = {
  sh_cf = "gui\\special\\life\\puzzle_quest\\skill\\cf\\",
  sh_cs = "gui\\special\\life\\puzzle_quest\\skill\\cs\\",
  sh_ds = "gui\\special\\life\\puzzle_quest\\skill\\ds\\",
  sh_jq = "gui\\special\\life\\puzzle_quest\\skill\\jq\\",
  sh_tj = "gui\\special\\life\\puzzle_quest\\skill\\tj\\",
  sh_ys = "gui\\special\\life\\puzzle_quest\\skill\\ys\\"
}
local equipped_skill_num = 0
local EQUIP_ITEMS = 5
local job_id, job_level, set_equip_btn_enabled
function auto_show_hide_form_puzzle_life_fight(mark)
  local skin_path = "form_stage_main\\puzzle_quest\\form_puzzle_life_fight"
  local form = nx_value(skin_path)
  if nx_is_valid(form) then
    if nx_find_custom(form, "mark") then
      if form.mark ~= mark then
        nx_destroy(form)
        util_show_form(skin_path, true)
        local form = nx_value(skin_path)
        form.mark = mark
      else
        form.Visible = not form.Visible
      end
    end
  else
    util_show_form(skin_path, true)
    local form = nx_value(skin_path)
    form.mark = mark
  end
  local form = nx_value(skin_path)
  ui_show_attached_form(form)
end
function main_form_init(form)
  form.Fixed = false
  form.grid = nil
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.job_id = job_id
  form.job_level = job_level
  if set_equip_btn_enabled then
    form.set_equip_btn_enabled = set_equip_btn_enabled
  end
  local job_sf_path = "share\\Item\\lifesfname.ini"
  local sf_ini = nx_execute("util_functions", "get_ini", job_sf_path)
  if not nx_is_valid(sf_ini) then
    return
  end
  local index = sf_ini:FindSectionIndex(nx_string(form.job_id))
  if index < 0 then
    return
  end
  local job_level = form.job_level
  form.lbl_job.Text = gui.TextManager:GetText("role_title_" .. sf_ini:ReadString(index, nx_string(job_level), ""))
  init_label(form)
  init_player_info(form)
  init_image(form)
  init_skill_list(form)
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  syn_temp_skill_rec()
  nx_execute("custom_sender", "custom_cancel_open_life_skill_flag", 1)
  nx_destroy(form)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_cbtn_gem_jobid_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked then
    return
  end
  nx_execute("custom_sender", "custom_change_gem_job", form.job_id)
end
function on_cbtn_gem_jobid_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  local gem_job_id = get_gemgame_jobid()
  if nx_string(gem_job_id) == nx_string(form.job_id) then
    return
  end
  nx_execute("custom_sender", "custom_change_gem_job", form.job_id)
end
function set_job(job, level, enabled)
  job_id = job
  job_level = level
  set_equip_btn_enabled = enabled
end
function get_obj_prop(value)
  return nx_execute("tips_game", "get_gem_obj_prop", value, VIEWPORT_GAME_SUBOBJ_BOX, 1)
end
function init_label(form)
  form.lbl_vitality.Text = nx_widestr(get_obj_prop("Vitality"))
  form.lbl_energy.Text = nx_widestr(get_obj_prop("Energy"))
  form.lbl_specialty.Text = nx_widestr(get_obj_prop("Specialty"))
  form.lbl_passion.Text = nx_widestr(get_obj_prop("Passion"))
  form.lbl_talent.Text = nx_widestr(get_obj_prop("Talent"))
  form.lbl_damage.Text = nx_widestr(get_obj_prop("Damage"))
  form.lbl_defence.Text = nx_widestr(get_obj_prop("Defence"))
  form.lbl_crit.Text = nx_widestr(get_obj_prop("Crit"))
  form.lbl_magic_defence.Text = nx_widestr(get_obj_prop("MagicDefence"))
  form.lbl_magic_hit.Text = nx_widestr(get_obj_prop("MagicHit"))
  form.lbl_power.Text = nx_widestr(get_obj_prop("HP"))
  local gem_job_id = get_gemgame_jobid()
  if nx_string(gem_job_id) == nx_string(form.job_id) then
    form.cbtn_gem_jobid.Checked = true
  else
    form.cbtn_gem_jobid.Checked = false
  end
end
function init_player_info(form)
  form.lbl_max_red.Text = nx_widestr(get_obj_prop("MaxRed"))
  form.lbl_max_yellow.Text = nx_widestr(get_obj_prop("MaxYellow"))
  form.lbl_max_blue.Text = nx_widestr(get_obj_prop("MaxBlue"))
  form.lbl_max_green.Text = nx_widestr(get_obj_prop("MaxGreen"))
  form.lbl_max_purple.Text = nx_widestr(get_obj_prop("MaxPurple"))
  local pic_path = ENERGY_PIC_PATH[form.job_id]
  form.lbl_icon_blue.BackImage = pic_path .. "blue.png"
  form.lbl_icon_green.BackImage = pic_path .. "green.png"
  form.lbl_icon_purple.BackImage = pic_path .. "purple.png"
  form.lbl_icon_red.BackImage = pic_path .. "red.png"
  form.lbl_icon_yellow.BackImage = pic_path .. "yellow.png"
end
function init_image(form)
  form.lbl_armor.Image = ""
  form.lbl_armor.item = nil
  form.lbl_weapon.Image = ""
  form.lbl_weapon.item = nil
  local weapon, armor = get_weapon_and_armor_item()
  if nx_is_valid(weapon) then
    local weapon_config_id = weapon:QueryProp("ConfigID")
    form.lbl_weapon.BackImage = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(weapon_config_id), nx_string("Photo"))
    form.lbl_weapon.Enabled = true
    form.lbl_weapon.Visible = true
    form.lbl_weapon.item = weapon
  else
    form.lbl_weapon.Enabled = false
    form.lbl_weapon.Visible = false
  end
  if nx_is_valid(armor) then
    local armor_config_id = armor:QueryProp("ConfigID")
    form.lbl_armor.BackImage = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(armor_config_id), nx_string("Photo"))
    form.lbl_armor.Enabled = true
    form.lbl_armor.Visible = true
    form.lbl_armor.item = armor
  else
    form.lbl_armor.Enabled = false
    form.lbl_armor.Visible = false
  end
end
function init_skill_list(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local row = client_player:GetRecordRows("job_rec")
  temp_skill_id_list = {}
  all_skill_list = {}
  skill_name_map = {}
  local jewel_game_manager = nx_value("jewel_game_manager")
  if not nx_is_valid(jewel_game_manager) then
    return
  end
  for i = 0, row - 1 do
    local job_id = client_player:QueryRecord("job_rec", i, 0)
    local gem_job_id = get_gemgame_jobid()
    if job_id == gem_job_id then
      local list = jewel_game_manager:GetJobSkillList(job_id)
      for j = 1, table.getn(list) do
        local skill_str = list[j]
        local str_list = util_split_string(skill_str, ",")
        local temp = {}
        temp.name = str_list[2]
        temp.level = tostring(table.getn(all_skill_list) + 1)
        temp.is_equipped = 0
        temp.is_learned = 0
        table.insert(all_skill_list, temp)
        skill_name_map[str_list[2]] = table.getn(all_skill_list)
      end
    end
  end
  local view = game_client:GetView(nx_string(VIEWPORT_GAME_SUBOBJ_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  local view_item = viewobj_list[1]
  if nx_is_valid(view_item) then
    local row = view_item:GetRecordRows(TEMP_SKILL_REC)
    for i = 0, row - 1 do
      local skill_id = view_item:QueryRecord(TEMP_SKILL_REC, i, 0)
      local index = skill_name_map[skill_id]
      if nx_int(0) < nx_int(index) then
        table.insert(temp_skill_id_list, skill_id)
        all_skill_list[index].is_equipped = 1
      end
    end
    equipped_skill_num = row
    row = view_item:GetRecordRows(JOB_GEM_SKILL_REC)
    for i = 0, row - 1 do
      local skill_id = view_item:QueryRecord(JOB_GEM_SKILL_REC, i, 0)
      local index = skill_name_map[skill_id]
      if nx_int(0) < nx_int(index) then
        all_skill_list[index].is_learned = 1
      end
    end
    row = view_item:GetRecordRows(SKILL_REC)
    for i = 0, row - 1 do
      local skill_id = view_item:QueryRecord(SKILL_REC, i, 0)
      local temp = {}
      temp.name = skill_id
      temp.level = tostring(table.getn(all_skill_list) + i + 1)
      temp.is_equipped = 0
      temp.is_learned = 0
      table.insert(all_skill_list, temp)
      skill_name_map[skill_id] = table.getn(all_skill_list)
    end
  end
  for i = 1, table.getn(all_skill_list) do
    local skill_groupbox = clone_skill_groupbox(i)
    form.groupscrollbox_skill:Add(skill_groupbox)
    if i % 2 == 1 then
      local color = skill_groupbox.BackColor
      local index = string.find(color, ",")
      skill_groupbox.BackColor = "127" .. string.sub(color, index)
    end
    local level = skill_groupbox:Find("lbl_skill_level" .. nx_string(i))
    level.Text = nx_widestr(all_skill_list[i].level)
    local name = skill_groupbox:Find("lbl_skill_name" .. nx_string(i))
    name.Text = gui.TextManager:GetText(all_skill_list[i].name)
    if all_skill_list[i].is_equipped == 1 then
      local is_equipped = skill_groupbox:Find("lbl_skill_equip" .. nx_string(i))
      is_equipped.Text = gui.TextManager:GetText("ui_equip")
      local btn = skill_groupbox:Find("btn_equip" .. nx_string(i))
      btn.Text = gui.TextManager:GetText("ui_puzzle_xx")
    end
    if all_skill_list[i].is_learned == 0 then
      local btn = skill_groupbox:Find("btn_equip" .. nx_string(i))
      btn.Enabled = false
      local color = btn.ForeColor
      local index = string.find(color, ",")
      btn.ForeColor = "127" .. string.sub(color, index)
      local level = skill_groupbox:Find("lbl_skill_level" .. nx_string(i))
      color = level.ForeColor
      index = string.find(color, ",")
      level.ForeColor = "127" .. string.sub(color, index)
      local name = skill_groupbox:Find("lbl_skill_name" .. nx_string(i))
      color = name.ForeColor
      index = string.find(color, ",")
      name.ForeColor = "127" .. string.sub(color, index)
    end
    if is_new_study_skill(form.job_id, form.job_level, nx_string(all_skill_list[i].name)) and nx_execute("form_stage_main\\form_life\\form_job_main_new", "have_new_skill") then
      local indicate = skill_groupbox:Find("lbl_indicate" .. nx_string(i))
      indicate.Visible = true
    end
  end
  if nx_find_custom(form, "set_equip_btn_enabled") then
    enabled_btn(form)
  end
  form.groupscrollbox_skill:ResetChildrenYPos()
  form.groupscrollbox_skill.IsEditMode = false
end
function clone_skill_groupbox(id)
  local form = nx_value("form_stage_main\\puzzle_quest\\form_puzzle_life_fight")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local clone = clone_groupbox(form.groupbox_skill)
  clone.Name = clone.Name .. nx_string(id)
  clone.Visable = true
  clone.index = id
  nx_bind_script(clone, nx_current())
  nx_callback(clone, "on_get_capture", "on_groupbox_skill_get_capture")
  nx_callback(clone, "on_lost_capture", "on_groupbox_skill_lost_capture")
  local temp
  temp = clone_label(form.lbl_indicate)
  clone:Add(temp)
  temp.Name = temp.Name .. nx_string(id)
  temp.BackImage = "gui\\special\\helper\\bsyx\\indicate.png"
  temp.Visible = false
  temp.Text = nx_widestr("")
  temp.AutoSize = true
  temp = clone_label(form.lbl_skill_level)
  clone:Add(temp)
  temp.Name = temp.Name .. nx_string(id)
  temp = clone_label(form.lbl_skill_name)
  clone:Add(temp)
  temp.Name = temp.Name .. nx_string(id)
  temp = clone_label(form.lbl_skill_equip)
  clone:Add(temp)
  temp.Name = temp.Name .. nx_string(id)
  local temp = clone_button(form.btn_equip, id)
  clone:Add(temp)
  temp.Name = temp.Name .. nx_string(id)
  temp.Text = gui.TextManager:GetText("ui_puzzle_zb")
  nx_bind_script(temp, nx_current())
  nx_callback(temp, "on_click", "on_btn_equip_click")
  return clone
end
function clone_label(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Label")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.Text = source.Text
  return clone
end
function clone_groupbox(source)
  local gui = nx_value("gui")
  local clone = gui:Create("GroupBox")
  clone.AutoSize = source.AutoSize
  clone.Name = source.Name
  clone.BackColor = source.BackColor
  clone.NoFrame = source.NoFrame
  clone.Left = 0
  clone.Top = 0
  clone.Width = source.Width
  clone.Height = source.Height
  return clone
end
function clone_button(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Button")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.NormalImage = source.NormalImage
  clone.FocusImage = source.FocusImage
  clone.PushImage = source.PushImage
  clone.NormalColor = source.NormalColor
  clone.FocusColor = source.FocusColor
  clone.PushColor = source.PushColor
  clone.DisableColor = source.DisableColor
  clone.BackColor = source.BackColor
  clone.ShadowColor = source.ShadowColor
  clone.Text = source.Text
  clone.AutoSize = source.AutoSize
  return clone
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
function get_weapon_and_armor_item()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local view = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return ""
  end
  local weapon_list, armor_list = get_tool_list(job_id)
  local item_list = view:GetViewObjList()
  local weapon_index_list = {}
  local armor_index_list = {}
  local weapon_item_list = {}
  local armor_item_list = {}
  for key, item in pairs(item_list) do
    local config_id = item:QueryProp("ConfigID")
    local is_in, index = is_in_list(config_id, weapon_list)
    if is_in then
      weapon_index_list[table.getn(weapon_index_list) + 1] = key
      weapon_item_list[table.getn(weapon_item_list) + 1] = config_id
    else
      is_in, index = is_in_list(config_id, armor_list)
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
    is_in, weapon_index = is_in_list(id, weapon_item_list)
    if is_in then
      break
    end
  end
  for i, id in pairs(armor_list) do
    is_in, armor_index = is_in_list(id, armor_item_list)
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
function is_in_list(id, list)
  for key, node in pairs(list) do
    if nx_string(id) == nx_string(node) then
      return true, key
    end
  end
  return false, 0
end
function syn_temp_skill_rec()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local equipped_list = {}
  for i = 1, table.getn(all_skill_list) do
    if all_skill_list[i].is_equipped == 1 then
      table.insert(equipped_list, all_skill_list[i].name)
    end
  end
  if table.getn(equipped_list) ~= table.getn(temp_skill_id_list) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GEM_RESET_SKILL), unpack(equipped_list))
  else
    table.sort(equipped_list)
    table.sort(temp_skill_id_list)
    for i = 1, table.getn(equipped_list) do
      if equipped_list[i] ~= temp_skill_id_list[i] then
        game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GEM_RESET_SKILL), unpack(equipped_list))
        return
      end
    end
  end
end
function on_btn_equip_click(btn)
  local gui = nx_value("gui")
  local form = btn.Parent
  local index = form.index
  if btn.Text == gui.TextManager:GetText("ui_puzzle_zb") then
    if equipped_skill_num >= EQUIP_ITEMS then
      show_error_tip("1150")
      return
    end
    equipped_skill_num = equipped_skill_num + 1
    btn.Text = gui.TextManager:GetText("ui_puzzle_xx")
    is_equipped = form:Find("lbl_skill_equip" .. index)
    is_equipped.Text = gui.TextManager:GetText("ui_equip")
    all_skill_list[tonumber(index)].is_equipped = 1
  else
    equipped_skill_num = equipped_skill_num - 1
    btn.Text = gui.TextManager:GetText("ui_puzzle_zb")
    is_equipped = form:Find("lbl_skill_equip" .. index)
    is_equipped.Text = gui.TextManager:GetText("")
    all_skill_list[tonumber(index)].is_equipped = 0
  end
end
function show_error_tip(info)
  local gui = nx_value("gui")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "breakconnect")
  dialog.cancel_btn.Visible = false
  dialog.ok_btn.Width = dialog.ok_btn.Width
  dialog.mltbox_info.HtmlText = gui.TextManager:GetText(info)
  dialog.ok_btn.Text = gui.TextManager:GetText("ui_ok")
  dialog:ShowModal()
  return 1
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
function on_groupbox_skill_get_capture(groupbox)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local skill_id = all_skill_list[tonumber(groupbox.index)].name
  nx_execute("tips_game", "show_tips_common", skill_id, 1017, x - 20, y)
end
function on_groupbox_skill_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
  return 1
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function is_new_study_skill(job_id, job_level, skill_id)
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\GemGameLearnSkill.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local section_index = ini:FindSectionIndex(job_id)
  if section_index < 0 then
    return false
  end
  local item_count = ini:GetSectionItemCount(section_index)
  if item_count <= 0 then
    return false
  end
  local skill_list = ini:GetSectionItemValue(section_index, job_level - 1)
  if not string.find(skill_list, skill_id) then
    return false
  end
  return true
end
function enabled_btn(form)
  local child_table = form.groupscrollbox_skill:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) then
      local btn = child:Find("btn_equip" .. nx_string(i))
      if nx_is_valid(btn) then
        btn.Enabled = false
      end
    end
  end
end
function get_gemgame_jobid()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local view = game_client:GetView(nx_string(VIEWPORT_GAME_SUBOBJ_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  local view_item = viewobj_list[1]
  if not nx_is_valid(view_item) then
    return false
  end
  local job_id = view_item:QueryProp("GemConfig")
  return job_id
end
