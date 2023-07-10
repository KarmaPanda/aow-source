require("util_static_data")
require("util_functions")
local LIEZHEN_INI_PATH = "ini\\ui\\wuxue\\zhenfa_liezhen.ini"
local LIEZHEN_SKILL_INI_PATH = "share\\Skill\\skill_new.ini"
local liezhen_point_label = {}
function main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = false
  change_form_size()
  self.lbl_point1.BackImage = "gui\\special\\liezhen\\icon_point_off.png"
  self.lbl_point2.BackImage = "gui\\special\\liezhen\\icon_point_off.png"
  self.lbl_point3.BackImage = "gui\\special\\liezhen\\icon_point_off.png"
  self.lbl_point4.BackImage = "gui\\special\\liezhen\\icon_point_off.png"
  self.lbl_point5.BackImage = "gui\\special\\liezhen\\icon_point_off.png"
  liezhen_point_label[1] = self.lbl_point1
  liezhen_point_label[2] = self.lbl_point2
  liezhen_point_label[3] = self.lbl_point3
  liezhen_point_label[4] = self.lbl_point4
  liezhen_point_label[5] = self.lbl_point5
end
function on_main_form_close(self)
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = true
  nx_destroy(self)
  nx_set_value(nx_current(), nx_null())
end
function show_form(begin_id)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_shortcut_liezhen_captain", true)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_1
  local ini = nx_execute("util_functions", "get_ini", LIEZHEN_INI_PATH)
  if not nx_is_valid(ini) then
    hide_form()
    return
  end
  local index = ini:FindSectionIndex(nx_string(begin_id))
  if index < 0 then
    hide_form()
    return
  end
  local str_skill_lst = ini:ReadString(index, "LieZhenCaptainSkill", "")
  local skill_tab = util_split_string(str_skill_lst, ",")
  if table.getn(skill_tab) < 1 then
    hide_form()
    return
  end
  local skillini = nx_execute("util_functions", "get_ini", LIEZHEN_SKILL_INI_PATH)
  if not nx_is_valid(skillini) then
    hide_form()
    return
  end
  for i = 1, table.getn(skill_tab) do
    skill_id = skill_tab[i]
    if skillini:FindSection(nx_string(skill_id)) then
      local sec_index = skillini:FindSectionIndex(nx_string(skill_id))
      if 0 <= sec_index then
        local static_data = skillini:ReadInteger(sec_index, "StaticData", 0)
        local photo = skill_static_query(static_data, "Photo")
        local cooltype = skill_static_query(static_data, "CoolDownCategory")
        local coolteam = skill_static_query(static_data, "CoolDownTeam")
        grid:AddItem(nx_int(i - 1), nx_string(photo), nx_widestr(skill_id), nx_int(0), i)
        if 0 < nx_number(cooltype) then
          grid:SetCoolType(nx_int(i - 1), nx_int(cooltype))
        end
        if 0 < nx_number(coolteam) then
          grid:SetCoolTeam(nx_int(i - 1), nx_int(coolteam))
        end
        local canuse = skill_static_query(static_data, "CanUse")
        grid:ChangeItemImageToBW(nx_int(i - 1), false)
      end
    end
  end
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_main_shortcut_liezhen_captain", true)
end
function hide_form()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_liezhen_captain")
  if nx_is_valid(form) then
    form:Close()
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_liezhen_captain")
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local row_count = 4
  if row_count < 4 then
    row_count = 4
  end
  form.imagegrid_1.ClomnNum = row_count
  form.Width = 342 + (row_count - 4) * 56
  form.lbl_2.Width = 290 + (row_count - 4) * 56
  form.imagegrid_1.Width = 237 + (row_count - 4) * 58
  form.imagegrid_1.ViewRect = "5,5," .. nx_string(240 + (row_count - 4) * 60) .. ",58"
  form.Left = gui.Width / 2 - form.Width / 2
  form.Top = shortcut_grid.groupbox_shortcut_1.AbsTop - form.Height + 86
end
function on_rightclick_grid(self, index)
  local name = self:GetItemName(index)
  nx_execute("custom_sender", "custom_send_liezhen_skill", 1, nx_string(name))
end
function on_mousein_grid(grid, index)
end
function on_mouseout_grid(grid, index)
end
function add_liezhen_point(point)
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_liezhen_captain")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_point1.BackImage = "gui\\special\\liezhen\\icon_point_off.png"
  form.lbl_point2.BackImage = "gui\\special\\liezhen\\icon_point_off.png"
  form.lbl_point3.BackImage = "gui\\special\\liezhen\\icon_point_off.png"
  form.lbl_point4.BackImage = "gui\\special\\liezhen\\icon_point_off.png"
  form.lbl_point5.BackImage = "gui\\special\\liezhen\\icon_point_off.png"
  local show_point = point
  if 5 < show_point then
    show_point = 5
  end
  for i = 1, show_point do
    liezhen_point_label[i].BackImage = "gui\\special\\liezhen\\icon_point_on.png"
  end
end
