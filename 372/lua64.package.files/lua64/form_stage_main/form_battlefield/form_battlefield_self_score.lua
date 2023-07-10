require("util_functions")
require("util_gui")
local FORM_BATTLEFIELD_SELF_SCORE = "form_stage_main\\form_battlefield\\form_battlefield_self_score"
local BATTLEFIELD_MAPINI_PATH = "share\\War\\battlefield_map.ini"
local CLIENT_SUBMSG_REQUEST_SELF_SCORE = 8
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  if not nx_is_valid(self) then
    return
  end
  self.ini = nx_execute("util_functions", "get_ini", BATTLEFIELD_MAPINI_PATH)
  if not nx_is_valid(self.ini) then
    nx_msgbox(BATTLEFIELD_MAPINI_PATH .. get_msg_str("msg_120"))
    return
  end
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  create_item(self)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
  return
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
end
function create_item(form)
  if not nx_is_valid(form) then
    return
  end
  local rbtn_copy = form.rbtn_item
  if not nx_is_valid(rbtn_copy) then
    return
  end
  local label_v_copy = form.lbl_item_v
  if not nx_is_valid(label_v_copy) then
    return
  end
  local label_a_copy = form.lbl_item_a
  if not nx_is_valid(label_a_copy) then
    return
  end
  local label_b_copy = form.lbl_item_b
  if not nx_is_valid(label_b_copy) then
    return
  end
  local gui = nx_value("gui")
  local rbtn_WIDTH = 122
  local rbtn_OFFSET_X = 70
  for i = 1, 42 do
    local label_xy_v = create_copy_ctrl("Label", label_v_copy)
    if not nx_is_valid(label_xy_v) then
      return
    end
    label_xy_v.Left = (i - 1) % 6 * rbtn_WIDTH + rbtn_OFFSET_X + 41
    label_xy_v.Top = nx_int((i - 1) / 6) * 50 + 70 + 16
    local name = "lbl_" .. i .. "_v"
    nx_set_custom(form, name, label_xy_v)
    form:Add(label_xy_v)
    local rbtn_xy = create_copy_ctrl("RadioButton", rbtn_copy)
    if not nx_is_valid(rbtn_xy) then
      return
    end
    rbtn_xy.Left = (i - 1) % 6 * rbtn_WIDTH + rbtn_OFFSET_X
    rbtn_xy.Top = nx_int((i - 1) / 6) * 50 + 70
    local name = "rbtn_" .. i
    nx_set_custom(form, name, rbtn_xy)
    form:Add(rbtn_xy)
  end
end
function refresh_score(...)
  local form = util_get_form(FORM_BATTLEFIELD_SELF_SCORE, false)
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if not form.Visible then
    return 0
  end
  local param_count = table.getn(arg)
  if param_count < 0 then
    return 0
  end
  for i = 1, param_count do
    local lbl_num = 0
    if i <= 6 then
      lbl_num = 36 + i
    else
      lbl_num = i - 6
    end
    local lbl_name_v = "lbl_" .. lbl_num .. "_v"
    if nx_find_custom(form, lbl_name_v) then
      local label_v = nx_custom(form, lbl_name_v)
      label_v.Text = nx_widestr(arg[i])
      if nx_number(i) % 6 == 0 and nx_number(arg[i]) == 0 then
        label_v.Text = nx_widestr("-")
      end
    end
  end
end
function create_copy_ctrl(ctrl_type, copy_src)
  if not nx_is_valid(copy_src) then
    return nx_null()
  end
  local gui = nx_value("gui")
  local new_ctrl = gui:Create(ctrl_type)
  if not nx_is_valid(new_ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(copy_src)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(new_ctrl, prop_tab[i], nx_property(copy_src, prop_tab[i]))
  end
  return new_ctrl
end
function refresh_schedule(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = form.ini
  if not nx_is_valid(ini) then
    return
  end
  local section_count = ini:GetSectionCount()
  if section_count < 1 then
    return
  end
  local gui = nx_value("gui")
  local sec_index = 0
  for i = 0, 6 do
    local group_karma_battle = ini:ReadString(sec_index, "GroupWeek" .. i, "")
    local karma_battle_table = util_split_string(group_karma_battle, ";")
    for j = 1, table.getn(karma_battle_table) do
      local id_str_tab = util_split_string(karma_battle_table[j], ",")
      if table.getn(id_str_tab) >= 2 then
        local karmas_str = id_str_tab[2]
        local karmas_tab = util_split_string(karmas_str, "|")
        if table.getn(karmas_tab) >= 3 then
          local text1 = gui.TextManager:GetText(karmas_tab[2])
          local text2 = gui.TextManager:GetText(karmas_tab[3])
          local k = i
          if 0 == k then
            k = 7
          end
          local lbl_num = (k - 1) * 6 + j
          local lbl_name_a = "lbl_" .. lbl_num .. "_a"
          local lbl_name_b = "lbl_" .. lbl_num .. "_b"
          if nx_find_custom(form, lbl_name_a) then
            local label_a = nx_custom(form, lbl_name_a)
            label_a.Text = text1
          end
          if nx_find_custom(form, lbl_name_b) then
            local label_b = nx_custom(form, lbl_name_b)
            label_b.Text = text2
          end
        end
      end
    end
  end
end
function request_score(rec_type)
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_REQUEST_SELF_SCORE, nx_int(rec_type))
end
