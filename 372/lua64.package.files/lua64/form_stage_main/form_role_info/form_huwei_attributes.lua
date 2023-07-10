require("share\\view_define")
require("define\\gamehand_type")
require("util_gui")
require("custom_sender")
require("util_functions")
require("role_composite")
require("util_static_data")
require("share\\logicstate_define")
require("share\\view_define")
local image_path = "gui\\language\\ChineseS\\huwei\\"
local unable_image = "gui\\special\\huwei\\shili_out.png"
function data_bind_rec(form)
  if nx_is_valid(form) then
    local databinder = nx_value("data_binder")
    if nx_is_valid(databinder) then
      databinder:AddTableBind("PetShowRec", form, nx_current(), "on_pet_config_change")
    end
  end
end
function data_unbind_rec(form)
  if nx_is_valid(form) then
    local databinder = nx_value("data_binder")
    if nx_is_valid(databinder) then
      databinder:DelTableBind("PetShowRec", form)
    end
  end
end
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  form.first_open = true
  form.max_shili_page = 1
  form.cur_shili_page = 1
  form.cur_shili_button = ""
  form.btn_1.Visible = false
  form.btn_2.Visible = true
  form.btn_call.Visible = false
  form.btn_dismiss.Visible = false
  local Pet = nx_value("Pet")
  if not nx_is_valid(Pet) then
    return
  end
  local shili_count = Pet:GetGroupCount()
  if nx_number(shili_count) == nx_number(0) then
    return
  end
  if 0 == shili_count % 5 then
    form.max_shili_page = nx_int(shili_count / 5)
  else
    form.max_shili_page = nx_int(shili_count / 5 + 1)
  end
  on_refresh_shili_page(form)
  data_bind_rec(form)
  if nx_is_valid(form) then
    form.first_open = false
  end
end
function on_main_form_close(form)
  data_unbind_rec(form)
  nx_destroy(form)
  nx_set_value("form_huwei_attributes", nx_null())
end
function refresh_form(form)
end
function on_btn_click_call_pet(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return
  end
  if not nx_find_custom(form, "cur_shili_button") then
    return
  end
  if not nx_find_custom(form.cur_shili_button, "slc_pet_grid") then
    return
  end
  if not nx_find_custom(form.cur_shili_button.slc_pet_grid, "pet_id") then
    return
  end
  local pet_id = form.cur_shili_button.slc_pet_grid.pet_id
  if nx_string("") == nx_string(pet_id) then
    return
  end
  local pet_id = form.cur_shili_button.slc_pet_grid.pet_id
  local shili_id = form.cur_shili_button.id
  nx_execute("custom_sender", "custom_pet", nx_int(2), nx_string(pet_id), nx_string(shili_id))
  form.btn_call.Visible = true
  form.btn_call.Enabled = false
  form.btn_dismiss.Visible = false
end
function on_btn_click_dismiss_pet(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_shili_button") then
    return
  end
  if not nx_find_custom(form.cur_shili_button, "slc_pet_grid") then
    return
  end
  if not nx_find_custom(form.cur_shili_button.slc_pet_grid, "pet_id") then
    return
  end
  local pet_id = form.cur_shili_button.slc_pet_grid.pet_id
  if nx_string("") == nx_string(pet_id) then
    return
  end
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return
  end
  local pet_id = form.cur_shili_button.slc_pet_grid.pet_id
  nx_execute("custom_sender", "custom_pet", nx_int(1), nx_string(pet_id))
  form.btn_call.Visible = false
  form.btn_dismiss.Visible = true
  form.btn_dismiss.Enabled = false
end
function on_btn_diwei_click(btn)
  util_show_form("form_stage_main\\form_origin\\form_kapai", true)
end
function on_rbtn_shili_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.first_open then
    return
  end
  if not rbtn.Checked then
    return
  end
  if not nx_find_custom(rbtn, "id") then
    return
  end
  if nx_string(rbtn.id) == nx_string("") then
    return
  end
  rbtn.Checked = true
  on_refresh_pet_grid(rbtn)
  if not nx_find_custom(form, "cur_shili_button") then
    return
  end
  form.cur_shili_button = rbtn
  local imagegird_talbe = get_pet_table(form)
  local ImageGird = imagegird_talbe[1]
  if nx_is_valid(ImageGird) then
    if not grid_checked_changed(ImageGird) then
      return
    end
    ImageGird.DrawMouseSelect = "xuanzekuang"
    ImageGird.Enabled = true
  end
end
function on_btn_last_shili_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_shili_page") then
    return
  end
  if 1 == form.cur_shili_page then
    return
  end
  form.cur_shili_page = form.cur_shili_page - 1
  on_refresh_shili_page(form)
end
function on_btn_next_shili_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_shili_page") or not nx_find_custom(form, "max_shili_page") then
    return
  end
  if form.max_shili_page == form.cur_shili_page then
    return
  end
  form.cur_shili_page = form.cur_shili_page + 1
  on_refresh_shili_page(form)
end
function on_ImagePetGrid_drag_enter(grid, index)
  local gui = nx_value("gui")
  local Pet = nx_value("Pet")
  if not nx_is_valid(gui) or not nx_is_valid(Pet) then
    return
  end
  if not nx_find_custom(grid, "pet_id") then
    return
  end
  local pet_id = grid.pet_id
  if nx_string("") == nx_string(pet_id) then
    return
  end
  if not Pet:CanGetPet(pet_id) then
    return
  end
  gui.GameHand.IsDragged = false
  gui.GameHand.IsDropped = false
end
function on_ImagePetGrid_drag_move(grid, index)
  local gui = nx_value("gui")
  local Pet = nx_value("Pet")
  if not nx_is_valid(gui) or not nx_is_valid(Pet) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  if not nx_find_custom(grid, "pet_id") then
    return
  end
  local pet_id = grid.pet_id
  if nx_string("") == nx_string(pet_id) then
    return
  end
  if not Pet:CanGetPet(pet_id) then
    return
  end
  if not gui.GameHand.IsDragged then
    gui.GameHand.IsDragged = true
    if gui.GameHand:IsEmpty() then
      local photo = item_query:GetItemPropByConfigID(pet_id, nx_string("Photo"))
      gui.GameHand:SetHand(GHT_FUNC, photo, "func", pet_id, "", "")
      return
    elseif gui.GameHand.Type == GHT_FUNC then
      gui.GameHand:ClearHand()
      return
    end
  end
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_role_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if nx_is_valid(form_role_info) and nx_is_valid(form) and not form.groupbox_right.Visible then
    form_role_info.Width = form_role_info.Width + form.groupbox_right.Width - 4
  end
  form.groupbox_right.Visible = true
  btn.Visible = false
  form.btn_2.Visible = true
end
function on_btn_2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_role_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if nx_is_valid(form_role_info) and nx_is_valid(form) and form.groupbox_right.Visible then
    form_role_info.Width = form_role_info.Width - form.groupbox_right.Width + 4
  end
  form.groupbox_right.Visible = false
  btn.Visible = false
  form.btn_1.Visible = true
end
function on_btn_pet_skill_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "groupbox_2") then
    if not nx_find_custom(form.groupbox_2, "skill_cur_page") then
      return
    end
    if nx_number(1) == nx_number(form.groupbox_2.skill_cur_page) then
      return
    end
    form.groupbox_2.skill_cur_page = form.groupbox_2.skill_cur_page - 1
    clear_skill_page(form)
    refresh_pet_skill_page(form)
  end
end
function on_btn_pet_skill_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "groupbox_2") then
    if not nx_find_custom(form.groupbox_2, "skill_max_page") or not nx_find_custom(form.groupbox_2, "skill_cur_page") then
      return
    end
    if form.groupbox_2.skill_max_page == form.groupbox_2.skill_cur_page then
      return
    end
    form.groupbox_2.skill_cur_page = form.groupbox_2.skill_cur_page + 1
    clear_skill_page(form)
    refresh_pet_skill_page(form)
  end
end
function on_rbtn_pet_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(rbtn.DataSource) < nx_number(1) or nx_number(rbtn.DataSource) > nx_number(3) then
    return
  end
  local groupbox_table = get_right_groupbox_table(form)
  local groupbox = groupbox_table[nx_number(rbtn.DataSource)]
  if not nx_is_valid(groupbox) then
    return
  end
  if rbtn.Checked then
    groupbox.Visible = true
  else
    groupbox.Visible = false
    return
  end
  if nx_int(1) == nx_int(rbtn.DataSource) then
    refresh_pet_attributes(form)
  elseif nx_int(2) == nx_int(rbtn.DataSource) then
    refresh_pet_skill(rbtn)
  elseif nx_int(3) == nx_int(rbtn.DataSource) then
    get_pet_desc(rbtn)
  end
end
function on_imagegrid_get_capture(grid)
  if not nx_find_custom(grid, "id") or not nx_find_custom(grid, "level") then
    return
  end
  if nx_string(grid.id) == nx_string("") or nx_string(grid.level) == nx_string("") then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local item_query = nx_value("ItemQuery")
  local gui = nx_value("gui")
  if not nx_is_valid(item_query) or not nx_is_valid(gui) then
    return
  end
  local id = nx_string("desc_") .. nx_string(grid.id) .. nx_string("_") .. nx_string(grid.level)
  local tips = gui.TextManager:GetFormatText(nx_string(id))
  local x = grid.AbsLeft + 5
  local y = grid.AbsTop
  nx_execute("tips_game", "show_text_tip", tips, x, y)
end
function on_imagegrid_lost_capture(grid)
  nx_execute("tips_game", "hide_tip")
end
function on_ImagePetGrid_select_changed(grid, index)
  grid_checked_changed(grid)
end
function on_btn_turn_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_show_huwei, dist)
  end
end
function on_btn_turn_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_show_huwei, dist)
  end
end
function on_btn_forward_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_shili_button") then
    return
  end
  if not nx_find_custom(form.cur_shili_button, "cur_pet_page") or not nx_find_custom(form.cur_shili_button, "max_pet_page") then
    return
  end
  if nx_number(form.cur_shili_button.cur_pet_page) == nx_number(1) then
    return
  end
  form.cur_shili_button.cur_pet_page = form.cur_shili_button.cur_pet_page - 1
  on_refresh_pet_grid(from.cur_shili_button)
  if not grid_checked_changed(form.ImagePetGrid1) then
    return
  end
  form.ImagePetGrid1.DrawMouseSelect = "xuanzekuang"
  form.ImagePetGrid1.Enabled = true
  form.lbl_pet_page.Text = nx_widestr(form.cur_shili_button.cur_pet_page .. "/" .. form.cur_shili_button.max_pet_page)
end
function on_btn_next_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_shili_button") then
    return
  end
  if not nx_find_custom(form.cur_shili_button, "cur_pet_page") or not nx_find_custom(form.cur_shili_button, "max_pet_page") then
    return
  end
  if nx_number(form.cur_shili_button.cur_pet_page) == nx_number(form.cur_shili_button.max_pet_page) then
    return
  end
  form.cur_shili_button.cur_pet_page = form.cur_shili_button.cur_pet_page + 1
  on_refresh_pet_grid(from.cur_shili_button)
  if not grid_checked_changed(form.ImagePetGrid1) then
    return
  end
  form.ImagePetGrid1.DrawMouseSelect = "xuanzekuang"
  form.ImagePetGrid1.Enabled = true
  form.lbl_pet_page.Text = nx_widestr(form.cur_shili_button.cur_pet_page .. "/" .. form.cur_shili_button.max_pet_page)
end
function on_ImageGrid_head_get_capture(self)
  if self.Enabled == false then
    return
  end
  if not nx_find_custom(self, "pet_id") then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local Pet = nx_value("Pet")
  local item_query = nx_value("ItemQuery")
  if not (nx_is_valid(gui) and nx_is_valid(Pet)) or not nx_is_valid(item_query) then
    return
  end
  local x = self.AbsLeft + 5
  local y = self.AbsTop
  local pet_id = self.pet_id
  local tem1 = gui.TextManager:GetFormatText(nx_string(pet_id))
  local tem2 = gui.TextManager:GetFormatText("ui_huwei_tipstitle_type")
  local pet_name = nx_widestr(tem1) .. nx_widestr("<br>") .. nx_widestr(tem2)
  local tips = nx_widestr(pet_name) .. nx_widestr("<br>")
  local prop_list = Pet:GetPropByPetId(pet_id)
  tem1 = gui.TextManager:GetFormatText("ui_huwei_tipstitle_powerlevel")
  tem2 = gui.TextManager:GetFormatText(nx_string(prop_list[1]))
  local pet_power = nx_widestr(tem1) .. nx_widestr(":") .. nx_widestr(tem2)
  tips = tips .. nx_widestr(pet_power) .. nx_widestr("<br>")
  local SkillRec = item_query:GetItemPropByConfigID(pet_id, "table@SkillRec")
  local skill_list = util_split_string(SkillRec, ";")
  skill_list[1] = string.gsub(skill_list[1], "\"", "")
  tem1 = gui.TextManager:GetFormatText("ui_huwei_tipstitle_skillnum")
  tem2 = table.getn(skill_list)
  if nx_string("\"") == skill_list[tem2] then
    tem2 = tem2 - 1
  end
  local skill_num = nx_widestr(tem1) .. nx_widestr(":") .. nx_widestr(tem2)
  tips = tips .. nx_widestr(skill_num) .. nx_widestr("<br>")
  local child_id = Pet:GetChildIdByPetId(pet_id)
  tem1 = gui.TextManager:GetText("ui_huwei_tipstitle_prestige")
  tem2 = gui.TextManager:GetText("sub_prestige_" .. nx_string(child_id))
  local jianghu_point = nx_widestr(tem1) .. nx_widestr(":") .. nx_widestr(tem2)
  tips = tips .. nx_widestr(jianghu_point) .. nx_widestr("<br>")
  tem1 = gui.TextManager:GetText("ui_huwei_tiptitles_notice")
  tem2 = gui.TextManager:GetText("ui_huwei_tips_notice")
  local notice = nx_widestr(tem1) .. nx_widestr(":") .. nx_widestr(tem2)
  tips = tips .. nx_widestr(notice) .. nx_widestr("<br>")
  nx_execute("tips_game", "show_text_tip", tips, x, y)
end
function on_ImageGrid_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_pet_config_change(form)
  local gui = nx_value("gui")
  local Pet = nx_value("Pet")
  if not nx_is_valid(gui) or not nx_is_valid(Pet) then
    return
  end
  if not nx_find_custom(form, "cur_shili_button") then
    return
  end
  if not nx_find_custom(form.cur_shili_button, "slc_pet_grid") then
    return
  end
  if not nx_find_custom(form.cur_shili_button.slc_pet_grid, "pet_id") then
    return
  end
  on_refresh_pet_grid(form.cur_shili_button)
  local pet_id = form.cur_shili_button.slc_pet_grid.pet_id
  if not Pet:CanGetPet(pet_id) then
    form.btn_call.Visible = false
    form.btn_dismiss.Visible = false
  end
end
function on_refresh_shili_page(form)
  local gui = nx_value("gui")
  local Pet = nx_value("Pet")
  if not nx_is_valid(gui) or not nx_is_valid(Pet) then
    return
  end
  local shili_count = Pet:GetGroupCount()
  local shili_table = Pet:GetGroupListSeriation()
  if nx_number(0) == nx_number(shili_count) or nx_number(0) == nx_number(table.getn(shili_table)) then
    return
  end
  if not nx_find_custom(form, "cur_shili_page") or not nx_find_custom(form, "cur_shili_button") then
    return
  end
  clear_shili_page(form)
  for i = 1, 5 do
    local ix = (form.cur_shili_page - 1) * 5 + i
    if shili_count >= ix then
      local shili_id = shili_table[ix]
      local shili_rbtn_table = get_shili_table(form)
      local shili_rbtn = shili_rbtn_table[nx_number(i)]
      if not nx_is_valid(shili_rbtn) then
        return
      end
      shili_rbtn.NormalImage = image_path .. shili_id .. "_out.png"
      shili_rbtn.FocusImage = image_path .. shili_id .. "_on.png"
      shili_rbtn.CheckedImage = image_path .. shili_id .. "_down.png"
      shili_rbtn.DisableImage = unable_image
      shili_rbtn.id = shili_id
      shili_rbtn.max_pet_page = 1
      shili_rbtn.cur_pet_page = 1
      shili_rbtn.slc_pet_page = 1
      shili_rbtn.slc_pet_grid = ""
      shili_rbtn.Enabled = true
    end
  end
  form.rbtn_shili_1.Checked = true
  on_refresh_pet_grid(form.rbtn_shili_1)
  form.cur_shili_button = form.rbtn_shili_1
  local ImageGirdTable = get_pet_table(form)
  local ImageGird = ImageGirdTable[nx_number(1)]
  if nx_is_valid(ImageGird) then
    if not grid_checked_changed(ImageGird) then
      return
    end
    ImageGird.DrawMouseSelect = "xuanzekuang"
    ImageGird.Enabled = true
  end
  if not nx_find_custom(form.cur_shili_button, "cur_pet_page") or not nx_find_custom(form.cur_shili_button, "max_pet_page") then
    return
  end
  form.lbl_pet_page.Text = nx_widestr(form.cur_shili_button.cur_pet_page .. "/" .. form.cur_shili_button.max_pet_page)
end
function clear_shili_page(form)
  for i = 1, 5 do
    local shili_rbtn_table = get_shili_table(form)
    local shili_rbtn = shili_rbtn_table[nx_number(i)]
    if nx_is_valid(form) then
      shili_rbtn.id = ""
      shili_rbtn.NormalImage = ""
      shili_rbtn.FocusImage = ""
      shili_rbtn.CheckedImage = ""
      shili_rbtn.Enabled = false
    end
  end
end
function on_refresh_pet_grid(rbtn)
  if not (nx_find_custom(rbtn, "id") and nx_find_custom(rbtn, "max_pet_page")) or not nx_find_custom(rbtn, "max_pet_page") then
    return
  end
  if nx_string("") == nx_string(rbtn.id) then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local Pet = nx_value("Pet")
  local item_query = nx_value("ItemQuery")
  if not (nx_is_valid(gui) and nx_is_valid(Pet)) or not nx_is_valid(item_query) then
    return
  end
  clear_grid_select(form)
  local shili_pet_count = Pet:GetPetCount(nx_string(rbtn.id))
  local shili_pet_list = Pet:GetGroupPetList(nx_string(rbtn.id))
  if nx_number(0) == nx_number(shili_pet_count) or nx_number(0) == nx_number(table.getn(shili_pet_list)) then
    return
  end
  if 0 == shili_pet_count % 6 then
    rbtn.max_pet_page = nx_int(shili_pet_count / 6)
  else
    rbtn.max_pet_page = nx_int(shili_pet_count / 6) + 1
  end
  for i = 1, 6 do
    local ImageGirdTable = get_pet_table(form)
    local ImageGird = ImageGirdTable[nx_number(i)]
    if not nx_is_valid(ImageGird) then
      return
    end
    ImageGird:Clear()
    ImageGird.Enabled = false
    local index = (rbtn.cur_pet_page - 1) * 6 + i
    if shili_pet_count >= index then
      local pet_id = shili_pet_list[index]
      ImageGird.pet_id = pet_id
      local photo = item_query:GetItemPropByConfigID(pet_id, nx_string("Photo"))
      local name = gui.TextManager:GetFormatText(nx_string(pet_id))
      if photo ~= "" then
        ImageGird:AddItem(0, photo, nx_widestr("<font color=\"#ffffff\">" .. nx_string(name) .. "</font>"), 1, -1)
        ImageGird:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(pet_id))
      end
      if Pet:CanGetPet(pet_id) then
        ImageGird:ChangeItemImageToBW(nx_int(0), false)
      else
        ImageGird:ChangeItemImageToBW(nx_int(0), true)
      end
      ImageGird.Enabled = true
    else
      ImageGird:Clear()
    end
  end
end
function clear_grid_select(form)
  for i = 1, 6 do
    local ImageGirdTable = get_pet_table(form)
    local ImageGird = ImageGirdTable[nx_number(i)]
    if nx_is_valid(ImageGird) then
      ImageGird.DrawMouseSelect = "RECT"
    end
  end
end
function refresh_pet_attributes(form)
  if not nx_find_custom(form, "cur_shili_button") then
    return
  end
  if not nx_find_custom(form.cur_shili_button, "slc_pet_grid") then
    return
  end
  if not nx_find_custom(form.cur_shili_button.slc_pet_grid, "pet_id") then
    return
  end
  local pet_id = form.cur_shili_button.slc_pet_grid.pet_id
  if nx_string("") == nx_string(pet_id) then
    return
  end
  local Pet = nx_value("Pet")
  if not nx_is_valid(Pet) then
    return
  end
  local prop_list = Pet:GetPropByPetId(pet_id)
  if nx_number(0) == table.getn(prop_list) then
    return
  end
  form.mltbox_qixue.HtmlText = nx_widestr(prop_list[2])
  form.mltbox_neili.HtmlText = nx_widestr(prop_list[3])
  form.mltbox_bili.HtmlText = nx_widestr(prop_list[4])
  form.mltbox_shenfa.HtmlText = nx_widestr(prop_list[5])
  form.mltbox_neixi.HtmlText = nx_widestr(prop_list[6])
  form.mltbox_gangqi.HtmlText = nx_widestr(prop_list[7])
  form.mltbox_tipo.HtmlText = nx_widestr(prop_list[8])
  form.mltbox_waigongqd.HtmlText = nx_widestr(prop_list[9])
  form.mltbox_waigongmz.HtmlText = nx_widestr(prop_list[10])
  form.mltbox_waigongbj.HtmlText = nx_widestr(prop_list[11])
  form.mltbox_neigongqd.HtmlText = nx_widestr(prop_list[12])
  form.mltbox_neigongmz.HtmlText = nx_widestr(prop_list[13])
  form.mltbox_neigongbj.HtmlText = nx_widestr(prop_list[14])
  form.mltbox_shanbi.HtmlText = nx_widestr(prop_list[15])
  form.mltbox_waigongfy.HtmlText = nx_widestr(prop_list[16])
  form.mltbox_neigongfy.HtmlText = nx_widestr(prop_list[17])
  form.mltbox_zhaojianl.HtmlText = nx_widestr(prop_list[18])
end
function refresh_pet_skill(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_shili_button") then
    return
  end
  if not nx_find_custom(form.cur_shili_button, "slc_pet_grid") then
    return
  end
  if not nx_find_custom(form.cur_shili_button.slc_pet_grid, "pet_id") then
    return
  end
  local pet_id = form.cur_shili_button.slc_pet_grid.pet_id
  if nx_string("") == nx_string(pet_id) then
    return
  end
  local item_query = nx_value("ItemQuery")
  local gui = nx_value("gui")
  if not nx_is_valid(item_query) or not nx_is_valid(gui) then
    return
  end
  clear_skill_page(form)
  local SkillRec = item_query:GetItemPropByConfigID(pet_id, "table@SkillRec")
  local skill_list = util_split_string(SkillRec, ";")
  if nx_number(table.getn(skill_list)) == nx_number(0) then
    return
  end
  skill_list[1] = string.gsub(skill_list[1], "\"", "")
  local count = table.getn(skill_list)
  if nx_string(skill_list[count]) == nx_string("\"") then
    count = count - 1
  end
  form.groupbox_2.skill_num = count
  form.groupbox_2.skill_max_page = 1
  form.groupbox_2.skill_cur_page = 1
  if 0 == count % 5 then
    form.groupbox_2.skill_max_page = nx_int(count / 5)
  else
    form.groupbox_2.skill_max_page = nx_int(count / 5 + 1)
  end
  refresh_pet_skill_page(form)
end
function get_pet_desc(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_shili_button") then
    return
  end
  if not nx_find_custom(form.cur_shili_button, "slc_pet_grid") then
    return
  end
  if not nx_find_custom(form.cur_shili_button.slc_pet_grid, "pet_id") then
    return
  end
  local pet_id = form.cur_shili_button.slc_pet_grid.pet_id
  if nx_string("") == nx_string(pet_id) then
    return
  end
  local item_query = nx_value("ItemQuery")
  local gui = nx_value("gui")
  if not nx_is_valid(item_query) or not nx_is_valid(gui) then
    return
  end
  form.mltbox_pet_desc:Clear()
  local name = gui.TextManager:GetFormatText(nx_string(pet_id))
  local desc = gui.TextManager:GetFormatText(nx_string("desc_") .. nx_string(pet_id))
  form.mltbox_pet_desc:AddHtmlText(nx_widestr(desc), -1)
end
function clear_skill_page(form)
  for i = 1, 5 do
    local grid_table = get_skill_table(form)
    local grid = grid_table[nx_number(i)]
    if nx_is_valid(grid) then
      grid:Clear()
      grid.id = ""
      grid.level = ""
    end
    if not nx_find_custom(grid, "id") or not nx_find_custom(grid, "level") then
      return
    end
    local name_table = skill_name_table(form)
    local label_name = name_table[nx_number(i)]
    if nx_is_valid(label_name) then
      label_name.Text = ""
    end
    local level_table = skill_level_table(form)
    local label_level = level_table[nx_number(i)]
    if nx_is_valid(label_level) then
      label_level.Text = ""
    end
  end
end
function refresh_pet_skill_page(form)
  if not nx_find_custom(form.groupbox_2, "skill_cur_page") or not nx_find_custom(form.groupbox_2, "skill_cur_page") then
    return
  end
  local item_query = nx_value("ItemQuery")
  local gui = nx_value("gui")
  if not nx_is_valid(item_query) or not nx_is_valid(gui) then
    return
  end
  if not nx_find_custom(form, "cur_shili_button") then
    return
  end
  if not nx_find_custom(form.cur_shili_button, "slc_pet_grid") then
    return
  end
  if not nx_find_custom(form.cur_shili_button.slc_pet_grid, "pet_id") then
    return
  end
  local pet_id = form.cur_shili_button.slc_pet_grid.pet_id
  if nx_string("") == nx_string(pet_id) then
    return
  end
  local SkillRec = item_query:GetItemPropByConfigID(pet_id, "table@SkillRec")
  local skill_list = util_split_string(SkillRec, ";")
  if nx_number(0) == nx_number(table.getn(skill_list)) then
    return
  end
  skill_list[1] = string.gsub(skill_list[1], "\"", "")
  for i = 1, 5 do
    local ix = (form.groupbox_2.skill_cur_page - 1) * 5 + i
    if ix <= form.groupbox_2.skill_num then
      local skill_id = util_split_string(skill_list[ix], ",")
      if skill_id[1] ~= nx_string("default_normal_skill") then
        local photo = nx_execute("util_static_data", "skill_static_query_by_id", skill_id[1], "Photo")
        local name = gui.TextManager:GetText(nx_string(skill_id[1]))
        local grid_table = get_skill_table(form)
        local grid = grid_table[nx_number(i)]
        if not nx_is_valid(grid) then
          return
        end
        if not nx_find_custom(grid, "id") or not nx_find_custom(grid, "level") then
          return
        end
        local name_table = skill_name_table(form)
        local label_name = name_table[nx_number(i)]
        if not nx_is_valid(label_name) then
          return
        end
        local level_table = skill_level_table(form)
        local label_level = level_table[nx_number(i)]
        if not nx_is_valid(label_level) then
          return
        end
        grid:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#ffffff\">" .. nx_string(name) .. "</font>"), 1, -1)
        label_name.Text = nx_widestr(name)
        label_level.Text = nx_widestr(util_text("ui_wuxue_level_" .. nx_string(skill_id[2])))
        grid.id = skill_id[1]
        grid.level = skill_id[2]
      end
    end
  end
  form.lbl_pet_skill_page.Text = nx_widestr(form.groupbox_2.skill_cur_page .. "/" .. form.groupbox_2.skill_max_page)
end
function show_pet_model(grid)
  if not grid.Enabled then
    return false
  end
  if not nx_find_custom(grid, "pet_id") then
    return false
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if not nx_find_custom(form, "scenebox_show_huwei") then
    return false
  end
  local game_visual = nx_value("game_visual")
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) or not nx_is_valid(game_visual) then
    return false
  end
  clear_grid_select(form)
  form.scenebox_show_huwei.Visible = true
  if nx_find_custom(form, "cur_shili_button") then
    if not nx_find_custom(form.cur_shili_button, "slc_pet_grid") then
      return false
    end
    form.cur_shili_button.slc_pet_grid = grid
    grid.DrawMouseSelect = "xuanzekuang"
  else
    return false
  end
  if nx_is_valid(form.scenebox_show_huwei.Scene) then
    nx_execute("util_gui", "ui_ClearModel", form.scenebox_show_huwei)
  end
  if not nx_is_valid(form.scenebox_show_huwei.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_show_huwei)
  end
  local resource = item_query:GetItemPropByConfigID(grid.pet_id, nx_string("Resource"))
  local actor2 = form.scenebox_show_huwei.Scene:Create("Actor2")
  load_from_ini(actor2, "ini\\" .. resource .. ".ini")
  if not nx_is_valid(actor2) then
    return false
  end
  if not nx_is_valid(form) then
    return false
  end
  if not nx_find_custom(form, "scenebox_show_huwei") then
    return false
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_show_huwei, actor2)
  if game_visual:QueryRoleActionSet(actor2) ~= "" then
    game_visual:SetRoleActionSet(actor2, game_visual:QueryRoleActionSet(actor2))
  end
  local action = nx_value("action_module")
  if nx_is_valid(action) then
    action:BlendAction(actor2, "ty_stand_01", false, true)
  end
  form.scenebox_show_huwei.Visible = true
  local scene = form.scenebox_show_huwei.Scene
  local radius = 2.1
  scene.camera:SetPosition(0, radius * 0.4, -radius * 1.45)
  nx_execute("util_gui", "ui_RotateModel", form.scenebox_show_huwei, 0)
  grid.Enabled = true
  return true
end
function grid_checked_changed(grid)
  if not show_pet_model(grid) then
    return false
  end
  local gui = nx_value("gui")
  local pet = nx_value("Pet")
  local game_client = nx_value("game_client")
  if not (nx_is_valid(gui) and nx_is_valid(pet)) or not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  if not nx_find_custom(form, "cur_shili_button") then
    return false
  end
  if not nx_find_custom(form.cur_shili_button, "slc_pet_grid") then
    return false
  end
  if not nx_find_custom(form.cur_shili_button.slc_pet_grid, "pet_id") then
    return false
  end
  local pet_id = form.cur_shili_button.slc_pet_grid.pet_id
  local name = gui.TextManager:GetFormatText(nx_string(pet_id))
  form.lbl_huwei_name.Text = nx_widestr(name)
  form.rbtn_1.Checked = true
  on_rbtn_pet_checked_changed(form.rbtn_1)
  if pet:CanGetPet(grid.pet_id) then
    if client_player:FindProp("Pet") and client_player:FindProp("PetConfig") then
      local pet = client_player:QueryProp("Pet")
      local pet_obj = game_client:GetSceneObj(nx_string(pet))
      local cur_pet_id = client_player:QueryProp("PetConfig")
      if nx_is_valid(pet_obj) and nx_string(grid.pet_id) == nx_string(cur_pet_id) then
        form.btn_call.Visible = false
        form.btn_dismiss.Visible = true
        form.btn_dismiss.Enabled = true
      else
        form.btn_call.Visible = true
        form.btn_call.Enabled = true
        form.btn_dismiss.Visible = false
      end
    else
      form.btn_call.Visible = true
      form.btn_call.Enabled = true
      form.btn_dismiss.Visible = false
    end
  else
    form.btn_call.Visible = false
    form.btn_dismiss.Visible = false
  end
  return true
end
function on_call_pet_from_shot_cut(pet_id, child_id)
  nx_execute("custom_sender", "custom_pet", nx_int(2), pet_id, child_id)
end
function get_shili_table(form)
  local shili_table = {
    form.rbtn_shili_1,
    form.rbtn_shili_2,
    form.rbtn_shili_3,
    form.rbtn_shili_4,
    form.rbtn_shili_5
  }
  return shili_table
end
function get_pet_table(form)
  local pet_show_grid_table = {
    form.ImagePetGrid1,
    form.ImagePetGrid2,
    form.ImagePetGrid3,
    form.ImagePetGrid4,
    form.ImagePetGrid5,
    form.ImagePetGrid6
  }
  return pet_show_grid_table
end
function skill_name_table(form)
  local skill_name = {
    form.lbl_name_1,
    form.lbl_name_2,
    form.lbl_name_3,
    form.lbl_name_4,
    form.lbl_name_5
  }
  return skill_name
end
function skill_level_table(form)
  local skill_level = {
    form.lbl_level_1,
    form.lbl_level_2,
    form.lbl_level_3,
    form.lbl_level_4,
    form.lbl_level_5
  }
  return skill_level
end
function get_skill_table(form)
  local pet_skill_table = {
    form.imagegrid_1,
    form.imagegrid_2,
    form.imagegrid_3,
    form.imagegrid_4,
    form.imagegrid_5
  }
  return pet_skill_table
end
function get_right_groupbox_table(form)
  local groupbox_table = {
    form.groupbox_1,
    form.groupbox_2,
    form.groupbox_3
  }
  return groupbox_table
end
