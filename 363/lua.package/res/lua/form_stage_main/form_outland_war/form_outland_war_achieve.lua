require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_outland_war\\form_outland_war_achieve"
local ea_info = {
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {},
  [7] = {},
  [8] = {},
  [9] = {},
  [10] = {},
  [11] = {},
  [12] = {},
  [13] = {},
  [14] = {},
  [15] = {},
  [16] = {},
  [17] = {},
  [18] = {},
  [19] = {},
  [20] = {},
  [21] = {},
  [22] = {},
  [23] = {},
  [24] = {},
  [25] = {},
  [26] = {},
  [27] = {},
  [28] = {},
  [29] = {},
  [30] = {},
  [31] = {},
  [32] = {},
  [33] = {},
  [34] = {},
  [35] = {},
  [36] = {},
  [37] = {},
  [38] = {},
  [39] = {},
  [40] = {},
  [41] = {},
  [42] = {},
  [43] = {},
  [44] = {},
  [45] = {},
  [46] = {},
  [47] = {},
  [48] = {},
  [49] = {},
  [50] = {},
  [51] = {},
  [52] = {},
  [53] = {},
  [54] = {},
  [55] = {},
  [56] = {},
  [57] = {},
  [58] = {},
  [59] = {},
  [60] = {},
  [61] = {},
  [62] = {},
  [63] = {},
  [64] = {}
}
local ea_player_left = 70
local ea_player_top = 50
local ea_player_margin_width = 140
local ea_player_margin_height = 30
local ea_player_nums_pre = 5
local ea_player_height = 120
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.Visible = true
  form:Show()
  form.achi_sec_count = 0
  form.ea_sec_count = 0
  init_achieve(form)
  custom_outland_war(1)
  custom_outland_war(12)
  form.rbtn_2.Checked = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function update_form(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local ea_info_wstr = nx_widestr(arg[1])
  local ea_info_rec = util_split_wstring(ea_info_wstr, ";")
  if table.getn(ea_info_rec) ~= table.getn(ea_info) then
    return
  end
  for i = 1, table.getn(ea_info) do
    ea_info[i] = {}
  end
  for i = 1, table.getn(ea_info_rec) do
    local ea_info_single_rec = util_split_wstring(ea_info_rec[i], ",")
    for j = 1, table.getn(ea_info_single_rec) do
      table.insert(ea_info[j], ea_info_single_rec[j])
    end
  end
  form.gsb_1.IsEditMode = true
  form.gsb_1:DeleteAll()
  local ini_ea = get_ini("ini\\ui\\outland_war\\outland_war_entire_achieve.ini")
  if not nx_is_valid(ini_ea) then
    return
  end
  local sec_count = ini_ea:GetSectionCount()
  form.ea_sec_count = nx_int(sec_count)
  for i = 1, sec_count do
    local desc = ini_ea:ReadString(i - 1, "desc", "")
    local award = ini_ea:ReadString(i - 1, "award", "")
    local other = ini_ea:ReadString(i - 1, "other", "")
    local sec = ini_ea:ReadString(i - 1, "sec", "")
    local nums = ini_ea:ReadString(i - 1, "nums", "")
    local groupbox_1 = create_ctrl("GroupBox", "groupbox_ea_" .. nx_string(i), form.groupbox_module_1, form.gsb_1)
    if nx_is_valid(groupbox_1) then
      groupbox_1.sec = nx_int(sec)
      local cbtn = create_ctrl("CheckButton", "cbtn_ea_" .. nx_string(i), form.cbtn_achieve, groupbox_1)
      nx_bind_script(cbtn, nx_current())
      nx_callback(cbtn, "on_checked_changed", "on_cbtn_ea_checked_changed")
      local lbl_desc = create_ctrl("Label", "lbl_desc_" .. nx_string(i), form.lbl_desc, groupbox_1)
      local lbl_award = create_ctrl("Label", "lbl_award_" .. nx_string(i), form.lbl_award, groupbox_1)
      local lbl_other = create_ctrl("Label", "lbl_other_" .. nx_string(i), form.lbl_other, groupbox_1)
      lbl_desc.Text = util_format_string(desc)
      lbl_award.Text = util_format_string(award)
      lbl_other.Text = util_format_string(other)
      cbtn.DataSource = nx_string(i)
    end
    local groupbox_2 = create_ctrl("GroupBox", "groupbox_ea_player_" .. nx_string(i), form.groupbox_module_2, form.gsb_1)
    if nx_is_valid(groupbox_2) then
      groupbox_2.DataSource = nx_string(nums)
      local lbl_tips = create_ctrl("Label", "lbl_tips_" .. nx_string(i), form.lbl_tips, groupbox_2)
      for j = 1, nx_number(nums) do
        local player_name = nx_widestr(ea_info[i][j])
        if player_name == nx_widestr("") then
          player_name = nx_widestr(util_text("ui_ea_xxyd"))
        end
        local lbl_player = create_ctrl("Label", "lbl_ea_player_" .. nx_string(i), form.lbl_ea_player, groupbox_2)
        lbl_player.Text = player_name
        lbl_player.Left = nx_int(ea_player_left) + nx_int(ea_player_margin_width) * nx_int(math.mod(j - 1, nx_number(ea_player_nums_pre)))
        lbl_player.Top = nx_int(ea_player_top) + nx_int(ea_player_margin_height) * nx_int(math.floor((j - 1) / nx_number(ea_player_nums_pre)))
      end
      groupbox_2.Height = 0
    end
  end
  form.gsb_1.IsEditMode = false
  form.gsb_1:ResetChildrenYPos()
  form.rbtn_ea_1.Checked = true
end
function update_achieve(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local achi_info_wstr = nx_widestr(arg[1])
  local achi_info_rec = util_split_wstring(achi_info_wstr, ";")
  for i = 1, table.getn(achi_info_rec) do
    local player_rec = util_split_wstring(achi_info_rec[i], ",")
    if table.getn(player_rec) ~= 3 then
      break
    end
    local index = nx_int(player_rec[1])
    local value = nx_int(player_rec[2])
    local can_get = nx_int(player_rec[3])
    local gb = form.gsb_2:Find("groupbox_chieve_" .. nx_string(index + 1))
    local lbl_other = gb:Find("lbl_achieve_other_" .. nx_string(index + 1))
    local pbar = gb:Find("pbar_achieve_other_" .. nx_string(index + 1))
    lbl_other.Text = util_format_string(nx_string(lbl_other.other), value)
    pbar.Value = nx_int(value)
    local btn = gb:Find("btn_achieve_" .. nx_string(index + 1))
    if nx_int(can_get) == nx_int(0) then
      btn.Enabled = false
      btn.Text = util_text("ui_achieve_get_0")
    elseif nx_int(can_get) == nx_int(1) then
      btn.Enabled = true
      btn.Text = util_text("ui_achieve_get_0")
    elseif nx_int(can_get) == nx_int(2) then
      btn.Enabled = false
      btn.Text = util_text("ui_achieve_get_1")
    end
  end
  form.rbtn_achi_1.Checked = true
end
function init_achieve(form)
  form.gsb_2.IsEditMode = true
  form.gsb_2:DeleteAll()
  local ini = get_ini("ini\\ui\\outland_war\\outland_war_achieve.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:GetSectionCount()
  form.achi_sec_count = nx_int(sec_count)
  for i = 1, nx_number(sec_count) do
    local desc = ini:ReadString(i - 1, "desc", "")
    local award = ini:ReadString(i - 1, "award", "")
    local other = ini:ReadString(i - 1, "other", "")
    local max = ini:ReadString(i - 1, "max", "")
    local sec = ini:ReadString(i - 1, "sec", "")
    local gb = create_ctrl("GroupBox", "groupbox_chieve_" .. nx_string(i), form.groupbox_module_3, form.gsb_2)
    if nx_is_valid(gb) then
      gb.sec = nx_int(sec)
      local lbl_desc = create_ctrl("Label", "lbl_achieve_desc_" .. nx_string(i), form.lbl_achieve_desc, gb)
      local lbl_award = create_ctrl("Label", "lbl_achieve_award_" .. nx_string(i), form.lbl_achieve_award, gb)
      local lbl_other = create_ctrl("Label", "lbl_achieve_other_" .. nx_string(i), form.lbl_achieve_other, gb)
      local pbar = create_ctrl("ProgressBar", "pbar_achieve_other_" .. nx_string(i), form.pbar_achieve, gb)
      lbl_desc.Text = util_format_string(desc)
      lbl_award.Text = util_format_string(award)
      lbl_other.Text = util_format_string(other, nx_int(0))
      lbl_other.other = other
      pbar.Value = nx_int(0)
      pbar.Maximum = nx_int(max)
      local btn = create_ctrl("Button", "btn_achieve_" .. nx_string(i), form.btn_achieve, gb)
      btn.DataSource = nx_string(i - 1)
      btn.Enabled = false
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_btn_achieve_click")
    end
  end
  form.gsb_2.IsEditMode = false
  form.gsb_2:ResetChildrenYPos()
end
function show_ea(form, sec)
  for i = 1, nx_number(form.ea_sec_count) do
    local gb_player = form.gsb_1:Find("groupbox_ea_player_" .. nx_string(i))
    local gb = form.gsb_1:Find("groupbox_ea_" .. nx_string(i))
    if nx_int(gb.sec) == nx_int(sec) then
      gb.Visible = true
      local cbtn = gb:Find("cbtn_ea_" .. nx_string(i))
      if cbtn.Checked then
        gb_player.Visible = true
      end
    else
      gb.Visible = false
      gb_player.Visible = false
    end
  end
  form.gsb_1:ResetChildrenYPos()
end
function show_achieve(form, sec)
  for i = 1, nx_number(form.achi_sec_count) do
    local gb = form.gsb_2:Find("groupbox_chieve_" .. nx_string(i))
    if nx_int(gb.sec) == nx_int(sec) then
      gb.Visible = true
    else
      gb.Visible = false
    end
  end
  form.gsb_2:ResetChildrenYPos()
end
function on_cbtn_ea_checked_changed(rbtn)
  local form = rbtn.ParentForm
  local index = rbtn.DataSource
  local gb_2 = form.gsb_1:Find("groupbox_ea_player_" .. nx_string(index))
  if rbtn.Checked then
    gb_2.Height = nx_int(ea_player_height)
    gb_2.Visible = true
  else
    gb_2.Height = 0
    gb_2.Visible = false
  end
  form.gsb_1:ResetChildrenYPos()
end
function on_btn_sort_1_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if nx_is_valid(rang_form) then
    nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_zy_outlandWarScoreA")
  end
end
function on_btn_sort_2_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if nx_is_valid(rang_form) then
    nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_wy_outlandWarScoreB")
  end
end
function on_btn_sort_3_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if nx_is_valid(rang_form) then
    nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_zy_outlandWarScoreWeekA")
  end
end
function on_btn_sort_4_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if nx_is_valid(rang_form) then
    nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_wy_outlandWarScoreWeekB")
  end
end
function on_btn_achieve_click(btn)
  btn.Enabled = false
  btn.Text = util_text("ui_achieve_get_1")
  local index = btn.DataSource
  custom_outland_war(13, nx_int(index))
end
function on_rbtn_1_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.gsb_1.Visible = true
    form.gsb_2.Visible = false
    form.groupbox_ea_rbtn.Visible = true
    form.groupbox_achi_rbtn.Visible = false
  end
end
function on_rbtn_2_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.gsb_2.Visible = true
    form.gsb_1.Visible = false
    form.groupbox_ea_rbtn.Visible = false
    form.groupbox_achi_rbtn.Visible = true
  end
end
function on_rbtn_ea_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if nx_is_valid(form) then
      show_ea(form, nx_int(rbtn.DataSource))
    end
  end
end
function on_rbtn_achi_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if nx_is_valid(form) then
      show_achieve(form, nx_int(rbtn.DataSource))
    end
  end
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
