require("util_gui")
require("util_functions")
require("custom_sender")
require("util_static_data")
require("define\\sysinfo_define")
require("form_stage_main\\form_taosha\\taosha_util")
local FORM_SKILL_CHOOSE = "form_stage_main\\form_taosha\\form_skill_choose"
local CAN_SELECT_SKILL_FILE = "share\\War\\TaoSha\\taosha.ini"
local FILE_SKILL_INI = "share\\Skill\\skill_new.ini"
local TaoShaClientMsg_SelectSkill = 1
local taosha_select_tip_1 = "taosha_systeminfo_10100"
local taosha_select_tip_2 = "taosha_systeminfo_10101"
function open_form()
  local form = nx_value(FORM_SKILL_CHOOSE)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_SKILL_CHOOSE, true)
  end
end
function close_form()
  local form = nx_value(FORM_SKILL_CHOOSE)
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(self)
  self.Fixed = false
  self.strSelectSkill = ""
  self.nCanSelect = 0
  self.strTotalSkill = ""
  self.nTotalNum = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  get_can_select_skill_ini(self)
  init_form(self)
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_btn_choose_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local selected_num = get_player_selected_skill_number(form)
  if nx_int(selected_num) ~= nx_int(form.nCanSelect) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(taosha_select_tip_2), 2)
    end
    return
  end
  get_player_select_skill()
  nx_execute("custom_sender", "custom_taosha", nx_int(TaoShaClientMsg_SelectSkill), nx_string(form.strSelectSkill))
end
function on_imagegrid_skill_mousein_grid(grid, index)
  if grid.skill_id == "" then
    return
  end
  local staticdata = nx_execute("tips_data", "get_ini_prop", FILE_SKILL_INI, grid.skill_id, "StaticData", "")
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(grid.skill_id)
  item.ItemType = ITEMTYPE_ZHAOSHI
  item.StaticData = nx_number(staticdata)
  item.Level = 1
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_cbtn_skill_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not cbtn.Checked then
    return
  end
  local selected_num = get_player_selected_skill_number(form)
  if nx_int(selected_num) > nx_int(form.nCanSelect) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(taosha_select_tip_1), 2)
    end
    cbtn.Checked = false
    return
  end
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
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
  ctrl.Name = name
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  if form.strTotalSkill == "" then
    return
  end
  local can_select_list = util_split_string(form.strTotalSkill, ";")
  if nx_int(#can_select_list) <= nx_int(0) then
    return
  end
  form.nTotalNum = nx_int(#can_select_list)
  form.groupscrollbox_1:DeleteAll()
  local refer_gbox = form.groupbox_1
  if not nx_is_valid(refer_gbox) then
    return
  end
  for i = 1, #can_select_list do
    if can_select_list[i] ~= "" then
      local gbox = create_ctrl("GroupBox", "gbox_can_select_" .. nx_string(i), refer_gbox, form.groupscrollbox_1)
      if nx_is_valid(gbox) then
        local grid = create_ctrl("ImageGrid", "grid_skill__" .. nx_string(i), form.imagegrid_1, gbox)
        if nx_is_valid(grid) then
          local photo = skill_static_query_by_id(can_select_list[i], "Photo")
          grid:AddItem(0, photo, util_text(can_select_list[i]), 1, -1)
          grid.skill_id = can_select_list[i]
          nx_bind_script(grid, nx_current())
          nx_callback(grid, "on_mousein_grid", "on_imagegrid_skill_mousein_grid")
          nx_callback(grid, "on_mouseout_grid", "on_imagegrid_skill_mouseout_grid")
        end
        local cbtn = create_ctrl("CheckButton", "cbtn_skill_" .. nx_string(i), form.cbtn_1, gbox)
        if nx_is_valid(cbtn) then
          cbtn.skill_id = can_select_list[i]
          nx_bind_script(cbtn, nx_current())
          nx_callback(cbtn, "on_checked_changed", "on_cbtn_skill_checked_changed")
        end
      end
      change_ctrl_position(gbox, i)
    end
  end
  form.groupscrollbox_1.IsEditMode = false
  form.groupscrollbox_1:ApplyChildrenCustomYPos()
end
function get_can_select_skill_ini(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", CAN_SELECT_SKILL_FILE)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("select_skill")
  if sec_count < 0 then
    return
  end
  form.nCanSelect = ini:ReadInteger(sec_count, "num", 0)
  form.strTotalSkill = ini:ReadString(sec_count, "skill", "")
end
function change_ctrl_position(gbox, index)
  if not nx_is_valid(gbox) then
    return
  end
  if nx_int(index) <= nx_int(0) then
    return
  end
  local count = nx_number(index - 1)
  local row = math.fmod(count, 2)
  local col = math.floor(count / 2)
  gbox.Left = (gbox.Width + 2) * row
  gbox.Top = (gbox.Height + 2) * col + 1
end
function get_player_select_skill()
  local form = nx_value(FORM_SKILL_CHOOSE)
  if not nx_is_valid(form) then
    return
  end
  form.strSelectSkill = ""
  local flag = 0
  for i = 1, form.nTotalNum do
    local gbox_name = "gbox_can_select_" .. nx_string(i)
    local gbox = form.groupscrollbox_1:Find(gbox_name)
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_skill_" .. nx_string(i)
      local cbtn = gbox:Find(cbtn_name)
      if nx_is_valid(cbtn) and cbtn.Checked then
        flag = flag + 1
        local temp_data = cbtn.skill_id
        if nx_int(flag) == nx_int(form.nCanSelect) then
          form.strSelectSkill = form.strSelectSkill .. nx_string(temp_data)
        else
          form.strSelectSkill = form.strSelectSkill .. nx_string(temp_data) .. nx_string(";")
        end
      end
    end
  end
end
function get_player_selected_skill_number(form)
  if not nx_is_valid(form) then
    return
  end
  local count = 0
  for i = 1, form.nTotalNum do
    local gbox_name = "gbox_can_select_" .. nx_string(i)
    local gbox = form.groupscrollbox_1:Find(gbox_name)
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_skill_" .. nx_string(i)
      local cbtn = gbox:Find(cbtn_name)
      if nx_is_valid(cbtn) and cbtn.Checked then
        count = count + 1
      end
    end
  end
  return count
end
