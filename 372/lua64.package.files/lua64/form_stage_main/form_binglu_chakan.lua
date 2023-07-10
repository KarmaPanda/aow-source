local BINGLU_BASE_INI = "share\\Skill\\BingLu\\BingLuBaseInfo.ini"
local BINGLU_LEVEL_INI = "share\\Skill\\BingLu\\BingLuLevelInfo.ini"
local PAGE_MAX_COUNT = 8
require("util_functions")
require("util_gui")
local binglu_list = {
  unarmed = 0,
  blade = 1,
  sword = 2,
  dagger = 3,
  dblade = 4,
  dsword = 5,
  ddagger = 6,
  lstaff = 7,
  sstaff = 8,
  hidden = 10,
  newweapon = 11
}
local binglu_list_display = {
  {name = "unarmed", row = 0},
  {name = "blade", row = 1},
  {name = "sword", row = 2},
  {name = "dagger", row = 3},
  {name = "dblade", row = 4},
  {name = "dsword", row = 5},
  {name = "ddagger", row = 6},
  {name = "lstaff", row = 7},
  {name = "sstaff", row = 8},
  {name = "hidden", row = 10},
  {name = "newweapon", row = 11}
}
local binglu_hint_list = {
  unarmed = "ui_binglu_tishi_unarmed",
  blade = "ui_binglu_tishi_blade",
  sword = "ui_binglu_tishi_sword",
  dagger = "ui_binglu_tishi_dagger",
  dblade = "ui_binglu_tishi_dblade",
  dsword = "ui_binglu_tishi_dsword",
  ddagger = "ui_binglu_tishi_ddagger",
  lstaff = "ui_binglu_tishi_lstaff",
  sstaff = "ui_binglu_tishi_sstaff",
  hidden = "ui_binglu_tishi_hidden",
  newweapon = "ui_binglu_tishi_newweapon"
}
local photo_list = {
  unarmed = "tushou.png",
  blade = "dandao.png",
  sword = "danjian.png",
  dagger = "bishou.png",
  dblade = "shuangdao.png",
  dsword = "shuangjian.png",
  ddagger = "shuangchi.png",
  lstaff = "changgun.png",
  sstaff = "duangun.png",
  hidden = "anqi.png",
  newweapon = "qimen.png"
}
local binglu_name_list = {
  unarmed = "ui_binglu_unarmed",
  blade = "ui_binglu_blade",
  sword = "ui_binglu_sword",
  dagger = "ui_binglu_dagger",
  dblade = "ui_binglu_dblade",
  dsword = "ui_binglu_dsword",
  ddagger = "ui_binglu_ddagger",
  lstaff = "ui_binglu_lstaff",
  sstaff = "ui_binglu_sstaff",
  hidden = "ui_binglu_hidden",
  newweapon = "ui_binglu_newweapon"
}
local _binglu_info
function main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  form.AbsLeft = (gui.Width - form.Width) / 10
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  init_binglu_page(form)
  show_binglu_list(form)
  return 1
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
  nx_set_value("form_binglu_chakan", nx_null())
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function show_binglu_list(form)
  if nil == _binglu_info then
    return
  end
  local binglu_manager = nx_value("binglu_manager")
  if not nx_is_valid(binglu_manager) then
    return
  end
  local gui = nx_value("gui")
  local binglu_base_ini = nx_execute("util_functions", "get_ini", BINGLU_BASE_INI)
  if not nx_is_valid(binglu_base_ini) then
    return 0
  end
  if not nx_find_custom(form, "curpage") then
    init_binglu_page(form)
  end
  for i = 1, PAGE_MAX_COUNT do
    if nx_find_custom(form, "groupbox" .. nx_string(i)) then
      local groupbox = nx_custom(form, "groupbox" .. nx_string(i))
      groupbox.Visible = false
    end
  end
  for i = 1, table.getn(binglu_list_display) do
    local indexbypage = i + (form.curpage - 1) * PAGE_MAX_COUNT
    if indexbypage > table.getn(binglu_list_display) then
      return
    end
    local binglu_id = binglu_list_display[indexbypage].name
    local rows
    if binglu_id ~= nil then
      rows = binglu_list[binglu_id]
    end
    local groupbox
    if nx_find_custom(form, "groupbox" .. nx_string(i)) then
      groupbox = nx_custom(form, "groupbox" .. nx_string(i))
      groupbox.Visible = true
    end
    if groupbox ~= nil and rows ~= nil and 0 <= rows then
      local binglu_index = binglu_base_ini:FindSectionIndex(nx_string(binglu_id))
      local binglu_name = binglu_base_ini:ReadString(binglu_index, "Name", "")
      local CurLevel = nx_int(_binglu_info[indexbypage * 3 - 1])
      local FillValue = nx_int(_binglu_info[indexbypage * 3])
      local MaxLevel = nx_number(_binglu_info[indexbypage * 3 + 1])
      if i == 3 then
      end
      local NeedValue = binglu_manager:GetValueNeed(rows, CurLevel)
      local DamAdd = binglu_manager:GetDamAdd(rows, CurLevel)
      if nx_find_custom(form, "lbl_binglu_name" .. nx_string(i)) then
        local lbl_name = nx_custom(form, "lbl_binglu_name" .. nx_string(i))
        lbl_name.Text = nx_widestr(gui.TextManager:GetText(binglu_name))
      end
      if nx_find_custom(form, "imagegrid_binglu" .. nx_string(i)) then
        local photo = "gui\\special\\tiguan\\" .. photo_list[binglu_id]
        local icon = nx_custom(form, "imagegrid_binglu" .. nx_string(i))
        icon.DrawMode = "Expand"
        icon:AddItem(0, photo, "", 1, -1)
        icon.GridWidth = icon.Width
        icon.GridHeight = icon.Height
        icon.HintText = gui.TextManager:GetText("tips_binglu_" .. nx_string(binglu_id))
      end
      if nx_find_custom(form, "lbl_dam_add" .. nx_string(i)) then
        local lbl_dam = nx_custom(form, "lbl_dam_add" .. nx_string(i))
        lbl_dam.Text = nx_widestr(DamAdd)
      end
      local btn_add_max_level
      if nx_find_custom(form, "btn_add_max_level" .. nx_string(i)) then
        btn_add_max_level = nx_custom(form, "btn_add_max_level" .. nx_string(i))
      end
      if MaxLevel ~= 0 then
        groupbox.BackImage = "gui\\special\\tiguan\\bl_b.png"
      else
        groupbox.BackImage = "gui\\special\\tiguan\\ui_1.png"
      end
      if btn_add_max_level ~= nil then
        btn_add_max_level.DataSource = binglu_id
        if MaxLevel == 0 then
          MaxLevel = binglu_base_ini:ReadString(binglu_index, "MaxLevel", "")
        end
        btn_add_max_level.Visible = false
        if nx_number(CurLevel) < nx_number(MaxLevel) then
        elseif nx_number(CurLevel) == nx_number(MaxLevel) then
          NeedValue = FillValue
        end
      end
      if nx_find_custom(form, "pbar_fill_value" .. nx_string(i)) then
        local pbar = nx_custom(form, "pbar_fill_value" .. nx_string(i))
        pbar.Maximum = NeedValue
        pbar.Value = FillValue
      end
      if nx_find_custom(form, "lbl_pro_var" .. nx_string(i)) then
        local lbl_pro = nx_custom(form, "lbl_pro_var" .. nx_string(i))
        lbl_pro.Text = nx_widestr(FillValue) .. nx_widestr("/") .. nx_widestr(NeedValue)
      end
    end
  end
end
function get_player_binglu_info(name)
  clear_player_info()
  nx_set_value("_binglu_chakan_name", nx_widestr(name))
  nx_execute("custom_sender", "custom_send_get_binglu_info", name)
end
function clear_player_info()
  local form = nx_value("form_stage_main\\form_binglu_chakan")
  if nx_is_valid(form) and form.Visible then
    _binglu_info = nil
  end
end
function set_binglu_info(info)
  local sel_name = get_role_name()
  sel_name = nx_string(sel_name)
  if nil == sel_name or "" == sel_name then
    return
  end
  if nil == info then
    return
  end
  local values = util_split_string(info, ",")
  if values[1] == "-1" then
    local text = util_format_string("7910", sel_name)
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, CENTERINFO_PERSONAL_NO)
    end
  end
  local name = nx_string(values[1])
  if sel_name ~= name then
    _binglu_info = nil
    return
  end
  _binglu_info = values
  if nil ~= _binglu_info then
    show_binglu_info()
  end
end
function get_role_name()
  return nx_value("_binglu_chakan_name")
end
function show_binglu_info()
  local form = nx_value("form_stage_main\\form_binglu_chakan")
  if not nx_is_valid(form) then
    util_show_form("form_stage_main\\form_binglu_chakan", true)
  elseif false == form.Visible then
    util_show_form("form_stage_main\\form_binglu_chakan", false)
    util_show_form("form_stage_main\\form_binglu_chakan", true)
  else
    show_binglu_list(form)
  end
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl, base_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
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
  nx_set_custom(base_ctrl, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function init_binglu_page(form)
  local pages = nx_int(table.getn(binglu_list_display) / PAGE_MAX_COUNT + 1)
  form.pages = pages
  form.curpage = 1
  refresh_btn_page_state(form)
end
function refresh_btn_page_state(form)
  if nx_find_custom(form, "pages") and nx_find_custom(form, "curpage") and nx_find_custom(form, "btn_left") and nx_find_custom(form, "btn_right") then
    if nx_find_custom(form, "lbl_n") then
      form.lbl_n.Text = nx_widestr(form.curpage) .. nx_widestr("/") .. nx_widestr(form.pages)
    end
    if form.curpage >= form.pages then
      form.btn_right.Enabled = false
    else
      form.btn_right.Enabled = true
    end
    if form.curpage <= 1 then
      form.btn_left.Enabled = false
    else
      form.btn_left.Enabled = true
    end
  end
end
function on_btn_left_click(btn)
  local form = nx_value("form_stage_main\\form_binglu_chakan")
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "pages") or not nx_find_custom(form, "curpage") then
    return
  end
  if form.curpage <= 1 then
    return
  end
  form.curpage = form.curpage - 1
  refresh_btn_page_state(form)
  show_binglu_list(form)
end
function on_btn_right_click(btn)
  local form = nx_value("form_stage_main\\form_binglu_chakan")
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "pages") or not nx_find_custom(form, "curpage") then
    return
  end
  if form.curpage >= form.pages then
    return
  end
  form.curpage = form.curpage + 1
  refresh_btn_page_state(form)
  show_binglu_list(form)
end
