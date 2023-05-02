require("util_functions")
require("util_gui")
require("util_static_data")
local g_Path = "form_stage_main\\form_school_war\\form_school_introduce"
local g_School_ini, g_TaoLuu_ini, g_Skilll_ini
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
  form.formtype = true
  form.school = "school_shaolin"
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  show_scholl_introduce_form(form)
  g_School_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\wuxue\\school_introduce.ini")
  g_TaoLuu_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\wuxue\\school_taolu.ini")
  g_Skilll_ini = nx_execute("util_functions", "get_ini", "share\\Skill\\skill_new.ini")
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  if form.formtype then
    form:Close()
  else
    form.formtype = true
    show_scholl_introduce_form(form)
  end
end
function on_rbtn_click(rbtn)
  local name = nx_string(string.sub(rbtn.Name, 6))
  if "" == name or nil == name then
    return
  end
  local form = rbtn.ParentForm
  form.school = name
  form.formtype = false
  fresh_detail_form(form)
end
function on_btn_school_click(btn)
  local name = nx_string(btn.Name)
  local rbtn_name = "rbtn_" .. name
  local form = btn.ParentForm
  local rbtn = get_obj(form.groupbox_btn, rbtn_name)
  if not nx_is_valid(rbtn) then
    return
  end
  rbtn.Checked = true
  form.school = name
  form.formtype = false
  show_scholl_introduce_form(form)
  fresh_detail_form(form)
end
function on_imagegrid_mousein_grid(grid, index)
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  local StaticData = nx_string(grid:GetItemAddText(index, nx_int(0)))
  local name = grid:GetItemName(index)
  if nx_string(name) == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(name)
  item.ItemType = ITEMTYPE_ZHAOSHI
  item.StaticData = nx_number(StaticData)
  item.Level = 1
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_scholl_introduce_form(form)
  local bool = form.formtype
  form.groupbox_main.Visible = bool
  form.groupbox_detail.Visible = not bool
  form.groupbox_btn.Visible = not bool
  form.lbl_recommend_life.Visible = not bool
  if bool then
    form.btn_return.Text = nx_widestr("@ui_close")
  else
    form.btn_return.Text = nx_widestr("@ui_return")
  end
end
function fresh_detail_form(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  clear_detail_form(form)
  if form.formtype then
    return
  end
  if nil == form.school or "" == form.school then
    return
  end
  if not nx_is_valid(g_School_ini) then
    return
  end
  local sec_index = g_School_ini:FindSectionIndex(form.school)
  if sec_index < 0 then
    return
  end
  local introduce = g_School_ini:ReadString(sec_index, "introduce", "")
  form.mltbox_introduce.HtmlText = nx_widestr(gui.TextManager:GetText(nx_string(introduce)))
  local recommend_life = g_School_ini:ReadString(sec_index, "recommendlife", "")
  form.lbl_recommend_life.Text = nx_widestr(gui.TextManager:GetText(nx_string(recommend_life)))
  local taolus = g_School_ini:ReadString(sec_index, "taolu", "")
  local taolutable = util_split_string(taolus, ",")
  if 3 ~= table.getn(taolutable) then
    return
  end
  for i = 1, table.getn(taolutable) do
    fresh_taolu_msg(form, i, nx_string(taolutable[i]))
  end
end
function fresh_taolu_msg(form, i, taoluid)
  if "" == taoluid then
    return
  end
  local obj
  local gui = nx_value("gui")
  local group = get_obj(form.groupbox_detail, "groupbox_detail_" .. nx_string(i))
  if not nx_is_valid(group) then
    return
  end
  obj = get_obj(group, "lbl_name_" .. nx_string(i))
  if not nx_is_valid(obj) then
    return
  end
  obj.Text = nx_widestr(gui.TextManager:GetText(taoluid))
  obj = get_obj(group, "imagegrid_" .. nx_string(i))
  if not nx_is_valid(obj) then
    return
  end
  if not nx_is_valid(g_TaoLuu_ini) or not nx_is_valid(g_Skilll_ini) then
    return
  end
  local sec_index = g_TaoLuu_ini:FindSectionIndex(taoluid)
  if sec_index < 0 then
    return
  end
  local skills = g_TaoLuu_ini:ReadString(sec_index, "skill", "")
  local skilltable = util_split_string(skills, ",")
  for j = 1, table.getn(skilltable) do
    local skill = nx_string(skilltable[j])
    local index = g_Skilll_ini:FindSectionIndex(skill)
    if 0 <= index then
      local static_data = g_Skilll_ini:ReadInteger(index, "StaticData", 0)
      local photo = skill_static_query(static_data, "Photo")
      obj:AddItem(nx_int(j - 1), nx_string(photo), nx_widestr(skill), 1, -1)
      obj:SetItemAddInfo(j - 1, nx_int(0), nx_widestr(nx_string(static_data)))
    end
  end
  local attack = g_TaoLuu_ini:ReadInteger(sec_index, "attack", 0)
  set_star_number(group, "groupbox_attack_", i, attack)
  local defend = g_TaoLuu_ini:ReadInteger(sec_index, "defend", 0)
  set_star_number(group, "groupbox_defend_", i, defend)
  local recover = g_TaoLuu_ini:ReadInteger(sec_index, "recover", 0)
  set_star_number(group, "groupbox_recover_", i, recover)
  local operate = g_TaoLuu_ini:ReadInteger(sec_index, "operate", 0)
  set_star_number(group, "groupbox_operate_", i, operate)
  local site = g_TaoLuu_ini:ReadString(sec_index, "site", "")
  obj = get_obj(group, "mltbox_site_" .. nx_string(i))
  if not nx_is_valid(obj) then
    return
  end
  obj.HtmlText = nx_widestr(gui.TextManager:GetText(site))
end
function clear_detail_form(form)
  form.mltbox_introduce:Clear()
  local obj
  for i = 1, 3 do
    local group = get_obj(form.groupbox_detail, "groupbox_detail_" .. nx_string(i))
    if not nx_is_valid(group) then
      break
    end
    obj = get_obj(group, "lbl_name_" .. nx_string(i))
    if not nx_is_valid(obj) then
      break
    end
    obj.Text = nx_widestr("")
    obj = get_obj(group, "imagegrid_" .. nx_string(i))
    if not nx_is_valid(obj) then
      break
    end
    obj:Clear()
    obj = get_obj(group, "groupbox_attack_" .. nx_string(i))
    if not nx_is_valid(obj) then
      break
    end
    obj:DeleteAll()
    obj = get_obj(group, "groupbox_defend_" .. nx_string(i))
    if not nx_is_valid(obj) then
      break
    end
    obj:DeleteAll()
    obj = get_obj(group, "groupbox_recover_" .. nx_string(i))
    if not nx_is_valid(obj) then
      break
    end
    obj:DeleteAll()
    obj = get_obj(group, "groupbox_operate_" .. nx_string(i))
    if not nx_is_valid(obj) then
      break
    end
    obj:DeleteAll()
    obj = get_obj(group, "mltbox_site_" .. nx_string(i))
    if not nx_is_valid(obj) then
      break
    end
    obj:Clear()
  end
end
function get_obj(group, objname)
  return group:Find(objname)
end
function set_star_number(groupfather, groupname, index, starnumber)
  if starnumber <= 0 or 16 < starnumber then
    return false
  end
  local obj = get_obj(groupfather, groupname .. nx_string(index))
  if not nx_is_valid(obj) then
    return false
  end
  local gui = nx_value("gui")
  local quotientr = starnumber / 2
  for i = 1, quotientr do
    local lbl_star = gui:Create("Label")
    obj:Add(lbl_star)
    lbl_star.Name = "lbl_star_" .. nx_string(index) .. nx_string(i)
    lbl_star.Left = (i - 1) * 20
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_2.png"
    lbl_star.AutoSize = true
  end
  local remainder = starnumber % 2
  if remainder == 1 then
    local lbl_star = gui:Create("Label")
    obj:Add(lbl_star)
    lbl_star.Name = "lbl_star_" .. nx_string(index) .. nx_string(quotientr + 1)
    lbl_star.Left = quotientr * 20 - 10
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_1.png"
    lbl_star.AutoSize = true
  end
  return true
end
