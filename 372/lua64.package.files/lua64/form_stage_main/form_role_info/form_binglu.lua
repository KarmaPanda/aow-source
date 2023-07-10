require("custom_sender")
local BINGLU_BASE_INI = "share\\Skill\\BingLu\\BingLuBaseInfo.ini"
local BINGLU_LEVEL_INI = "share\\Skill\\BingLu\\BingLuLevelInfo.ini"
local PAGE_MAX_COUNT = 8
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
  ditze = "",
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
function refresh_form(form)
  show_binglu_list(form)
end
function form_binglu_init(form)
  form.Fixed = true
  return 1
end
function form_binglu_open(form)
  data_bind_prop(form)
  init_binglu_page(form)
  show_binglu_list(form)
end
function get_condition_id(cur_max_level)
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\BingLu\\BingLuExpandInfo.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(cur_max_level))
  if index < 0 then
    return 0
  end
  return ini:ReadInteger(index, "condition_id", 0)
end
function get_new_max_level(cur_max_level)
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\BingLu\\BingLuExpandInfo.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(cur_max_level))
  if index < 0 then
    return 0
  end
  return ini:ReadInteger(index, "new_max_level", 0)
end
function get_use_faculty(cur_max_level)
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\BingLu\\BingLuExpandInfo.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(cur_max_level))
  if index < 0 then
    return 0
  end
  return ini:ReadInteger(index, "use_faculty", 0)
end
function form_binglu_close(form)
  if not nx_is_valid(form) then
    return
  end
  del_data_bind_prop(form)
  nx_destroy(form)
  nx_set_value("form_binglu", nx_null())
end
function show_binglu_list(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
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
      if client_player:FindRecord("binglu_rank_rec") then
        local CurLevel = client_player:QueryRecord("binglu_rank_rec", rows, 0)
        local FillValue = client_player:QueryRecord("binglu_rank_rec", rows, 1)
        local MaxLevel = client_player:QueryRecord("binglu_rank_rec", rows, 2)
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
            btn_add_max_level.Visible = false
          elseif nx_number(CurLevel) == nx_number(MaxLevel) then
            NeedValue = FillValue
            local new_max_level = get_new_max_level(MaxLevel)
            if nx_number(new_max_level) > nx_number(MaxLevel) then
              local condition_id = get_condition_id(CurLevel)
              local condition_manager = nx_value("ConditionManager")
              if nx_is_valid(condition_manager) and condition_manager:CanSatisfyCondition(client_player, client_player, condition_id) then
                btn_add_max_level.Visible = true
              end
            end
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
end
function data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddTableBind("binglu_rank_rec", self, nx_current(), "show_binglu_list")
end
function del_data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:DelTableBind("binglu_rank_rec", self)
end
function open_form()
  local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_role_info\\form_role_info", true)
  if not nx_is_valid(form) then
    return
  end
  local rbtn_1 = form.groupbox_3:Find("rbtn_1")
  if nx_is_valid(rbtn_1) then
    rbtn_1.Checked = false
  end
  local rbtn_8 = form.groupbox_3:Find("rbtn_8")
  if nx_is_valid(rbtn_8) then
    rbtn_8.Checked = true
    nx_execute("form_stage_main\\form_role_info\\form_role_info", "on_rbtn_info_click", rbtn_8)
  end
end
function on_btn_add_max_level_click(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("binglu_rank_rec") then
    return
  end
  local binglu_id = nx_string(btn.DataSource)
  local row = binglu_list[binglu_id]
  local cur_level = client_player:QueryRecord("binglu_rank_rec", row, 0)
  local condition_id = get_condition_id(cur_level)
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  if not condition_manager:CanSatisfyCondition(client_player, client_player, condition_id) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local use_faculty = get_use_faculty(cur_level)
  local text = gui.TextManager:GetFormatText("ui_binglu_exp_4", gui.TextManager:GetText(binglu_name_list[binglu_id]), nx_widestr(use_faculty / 10000))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if "ok" ~= result then
    return
  end
  local CUSTOMMSG_SUB_MODIFY_BINGLU_ADD_MAX_LEVEL = 0
  custom_modify_binglu(CUSTOMMSG_SUB_MODIFY_BINGLU_ADD_MAX_LEVEL, "", binglu_id, 0)
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
  local form = nx_value("form_stage_main\\form_role_info\\form_binglu")
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
  local form = nx_value("form_stage_main\\form_role_info\\form_binglu")
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
