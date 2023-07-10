require("util_gui")
require("util_functions")
require("define\\gamehand_type")
local SCENE_CFG_FILE = "ini\\scenes.ini"
local SCENE_DES_FILE = "ini\\ui\\clonescene\\clonescenedesc.ini"
local CDT_NORMAL_FILE = "share\\Rule\\condition.ini"
local NPC_FILE_NAME = "ini\\ui\\clonescene\\clonenpcdesc.ini"
local DOWN_IMAGE = "gui\\special\\camera\\btn_menu_on.png"
local CLIENT_SUBMSG_REQUEST_JOIN_RANDOM_CLONE = 0
local CLIENT_SUBMSG_CANCEL_WATI_RANDOM_CLONE = 1
local CLIENT_SUBMSG_CAPTAIN_REQUEST_RANDOM_CLONE = 2
local CLIENT_SUBMSG_CONFIRM_ENTER_CLONE = 3
local CLIENT_SUBMSG_REQUEST_ENTER_CLONE = 4
local CLIENT_SUBMSG_REQUEST_OUT_CLONE = 5
local FORM_MAIN_PATH = "form_stage_main\\form_clone\\form_clone_info"
local MAX_RESET_COUNT = 7
local CLONE_SAVE_REC = "clone_rec_save"
local old_color = "0,0,0,0"
local last_row = 0
local CLONE_INFO = {
  "ui_clonerec_dif01",
  "ui_clonerec_dif02",
  "ui_clonerec_dif03",
  "ui_clonerec_dif04"
}
local CLONE_LEVEL = {
  "ui_clonerec_dif11",
  "ui_clonerec_dif12",
  "ui_clonerec_dif13",
  "ui_clonerec_dif10"
}
local LEVEL_COLOR = {
  "255,50,150,50",
  "255,150,150,50",
  "255,150,50,50"
}
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.clone_index = 0
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = (gui.Desktop.Height - form.Height) / 2
  form.grid_clone:SetColAlign(20, "left")
  form.grid_clone:SetColWidth(0, 135)
  form.grid_clone:SetColWidth(1, 90)
  form.grid_clone:SetColWidth(2, 130)
  form.grid_clone:SetColWidth(3, 50)
  form.grid_clone:SetColWidth(4, 0)
  form.grid_clone:SetColWidth(5, 0)
  form.grid_clone:SetColWidth(6, 0)
  form.ctrl_down = false
  local remain_resetcount = get_player_reset_clone_count()
  form.lbl_times.Text = nx_widestr(remain_resetcount)
  show_clone_list(form, 0)
  form.rbtn_all.Checked = true
  nx_set_custom(form.Parent, nx_string("lbl_select_back"), form.lbl_select_back)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function msg(info)
  nx_msgbox(nx_string(info))
end
function show_clone_list(form, show_type)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.grid_clone:ClearRow()
  form.grid_clone:ClearSelect()
  local scene_ini = nx_execute("util_functions", "get_ini", SCENE_DES_FILE)
  if not nx_is_valid(scene_ini) then
    return 0
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local cur_main_game_step = switch_manager:GetMainGameStep()
  local cur_sub_game_step = switch_manager:GetSubGameStep()
  local player_powerlevel = get_player_powerlevel()
  local sec_count = scene_ini:GetSectionCount()
  local tab = {}
  for j = 0, sec_count - 1 do
    for i = 1, 4 do
      local id = scene_ini:GetSectionByIndex(j)
      local name = scene_ini:ReadString(j, "Name" .. nx_string(i), "")
      local Type = scene_ini:ReadString(j, "Type", "")
      if (nx_int(Type) == nx_int(show_type) or nx_int(0) == nx_int(show_type)) and nx_string(name) ~= nx_string("") then
        local player_num = scene_ini:ReadString(j, "MaxPlayers" .. i, "")
        local clone_config = scene_ini:ReadString(j, "ConfigID", "")
        local EntryLimited = scene_ini:ReadString(j, "EntryLimited" .. i, "")
        local scene_powerlevel = get_clone_scene_powerlevel(EntryLimited)
        local clone_id = scene_ini:ReadInteger(j, "CloneScene", "")
        local text = scene_ini:ReadString(j, "MltboxTips" .. i, "")
        local level_name = gui.TextManager:GetFormatText(nx_string(text))
        local switch_id = scene_ini:ReadString(j, "Switch" .. i, "")
        local JiuYinZhi = scene_ini:ReadString(j, "JiuYinZhi" .. i, "")
        local MainStep = scene_ini:ReadString(j, "MainStep" .. i, "")
        local SubStep = scene_ini:ReadString(j, "SubStep" .. i, "")
        local jiuyinzhi_step = MainStep + SubStep / 10
        local JYZ_OPEN = true
        if nx_int(cur_main_game_step) < nx_int(MainStep) then
          JYZ_OPEN = false
        elseif nx_int(cur_main_game_step) == nx_int(MainStep) and nx_int(cur_sub_game_step) < nx_int(SubStep) then
          JYZ_OPEN = false
        end
        local switch_open = true
        if nx_int(switch_id) ~= nx_int(0) and not switch_manager:CheckSwitchEnable(nx_int(switch_id)) then
          switch_open = false
        end
        local level_open = true
        if nx_number(player_powerlevel) < nx_number(scene_powerlevel) then
          level_open = false
        end
        local can_enter = 0
        if JYZ_OPEN and switch_open and level_open then
          can_enter = 1
        end
        table.insert(tab, {
          name,
          level_name,
          JiuYinZhi,
          player_num,
          id,
          i,
          clone_id,
          clone_config,
          can_enter,
          jiuyinzhi_step,
          j
        })
      end
    end
  end
  table.sort(tab, function(a, b)
    if nx_number(a[9]) > nx_number(b[9]) then
      return true
    elseif nx_number(a[9]) == nx_number(b[9]) then
      if nx_number(a[10]) < nx_number(b[10]) then
        return true
      elseif nx_number(a[10]) == nx_number(b[10]) then
        if nx_number(a[4]) < nx_number(b[4]) then
          return true
        elseif nx_number(a[4]) == nx_number(b[4]) and nx_number(a[11]) < nx_number(b[11]) then
          return true
        end
      end
    end
    return false
  end)
  for i = 1, table.getn(tab) do
    local row = form.grid_clone:InsertRow(-1)
    form.grid_clone:SetGridText(row, 0, gui.TextManager:GetText(tab[i][1]))
    form.grid_clone:SetGridText(row, 1, nx_widestr(tab[i][2]))
    local label_jyz = gui:Create("Label")
    label_jyz.BackImage = tab[i][3]
    form.grid_clone:SetGridControl(row, 2, label_jyz)
    form.grid_clone:SetGridText(row, 3, nx_widestr(tab[i][4]))
    form.grid_clone:SetGridText(row, 4, nx_widestr(tab[i][5]))
    form.grid_clone:SetGridText(row, 5, nx_widestr(tab[i][6]))
    form.grid_clone:SetGridText(row, 6, nx_widestr(nx_string(tab[i][7])))
    local AddLabel = gui:Create("Label")
    AddLabel.ForeColor = "255,255,255,255"
    AddLabel.BackImage = nx_string(OUT_IMAGE)
    AddLabel.DrawMode = Tile
    AddLabel.AutoSize = true
    AddLabel.grid_row = row
    AddLabel.grid_col = 6
    AddLabel.clone_config = tab[i][8]
    AddLabel.clone_level = tab[i][6]
    form.grid_clone:SetGridControl(row, 6, AddLabel)
    nx_set_custom(form, "select_label" .. nx_string(i - 1), AddLabel)
    if tab[i][9] == 0 then
      form.grid_clone:SetGridForeColor(row, 0, "255,100,100,100")
      form.grid_clone:SetGridForeColor(row, 1, "255,100,100,100")
      form.grid_clone:SetGridForeColor(row, 2, "255,100,100,100")
      form.grid_clone:SetGridForeColor(row, 3, "255,100,100,100")
    end
  end
  form.grid_clone:SelectRow(0)
end
function test(info)
  nx_msgbox(nx_string(info))
end
function Get_PowerLevel_Name(PowerLevel)
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\FacultyLevel.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  if not ini:FindSection(nx_string("config")) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string("config"))
  if sec_index < 0 then
    return ""
  end
  local power_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
  for i = 1, table.getn(power_table) do
    local powerinfo = power_table[i]
    local info_lst = util_split_string(powerinfo, ",")
    if nx_int(PowerLevel) == nx_int(info_lst[1]) then
      return util_text("desc_" .. nx_string(info_lst[3]))
    end
  end
  return ""
end
function on_rbtn_all_checked(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    show_clone_list(form, 0)
  end
end
function on_rbtn_jh_checked(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    show_clone_list(form, 1)
  end
end
function on_rbtn_school_checked(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    show_clone_list(form, 2)
  end
end
function on_rbtn_ng_checked(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    show_clone_list(form, 3)
  end
end
function on_rbtn_dt_checked(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    show_clone_list(form, 4)
  end
end
function on_grid_clone_select_row(grid, ...)
  if not nx_is_valid(grid) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "CurSelectLabel") then
    local cur_select_label = nx_custom(form, "CurSelectLabel")
    if nx_is_valid(cur_select_label) then
      cur_select_label.BackImage = OUT_IMAGE
    end
  end
  if not nx_find_custom(form, "select_label" .. nx_string(grid.RowSelectIndex)) then
    return
  end
  local label = nx_custom(form, "select_label" .. nx_string(grid.RowSelectIndex))
  if nx_is_valid(label) then
    label.BackImage = DOWN_IMAGE
    nx_set_custom(form, "CurSelectLabel", label)
    form.clone_level = label.clone_level
    form.clone_config = label.clone_config
  end
  local row = nx_int(arg[1])
  show_clonescene_data(grid, row)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function show_clonescene_data(grid, row)
  if not nx_is_valid(grid) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local grid_clone_id = nx_widestr(grid:GetGridText(nx_int(row), 4))
  local reward_index = nx_widestr(grid:GetGridText(nx_int(row), 5))
  local reward_clone_id = nx_widestr(grid:GetGridText(nx_int(row), 6))
  form.clone_index = grid_clone_id
  form.reward_index = reward_index
  form.reward_clone_id = reward_clone_id
  local gui = nx_value("gui")
  local scene_ini = nx_execute("util_functions", "get_ini", SCENE_DES_FILE)
  if not nx_is_valid(scene_ini) then
    return 0
  end
  local sec_index = scene_ini:FindSectionIndex(nx_string(grid_clone_id))
  local name = nx_widestr(grid:GetGridText(nx_int(row), 0))
  local location = scene_ini:ReadString(sec_index, "Location", "")
  local photo = scene_ini:ReadString(sec_index, "Photo", "")
  form.lbl_name.Text = nx_widestr(name)
  form.mltbox_location.HtmlText = nx_widestr(gui.TextManager:GetText(location))
  form.img_clone_scene:Clear()
  form.img_clone_scene:AddItem(0, nx_string(photo), "", 1, -1)
  show_boss_list(form)
end
function show_boss_list(form)
  if not nx_is_valid(form) then
    return
  end
  local scene_ini = nx_execute("util_functions", "get_ini", SCENE_DES_FILE)
  if not nx_is_valid(scene_ini) then
    return 0
  end
  local itemQuery = nx_value("ItemQuery")
  if not nx_is_valid(itemQuery) then
    return
  end
  local npc_ini = nx_execute("util_functions", "get_ini", NPC_FILE_NAME)
  if not nx_is_valid(npc_ini) then
    return 0
  end
  form.gbox_bosses_show.IsEditMode = true
  form.gbox_bosses_show:DeleteAll()
  local sec_index = scene_ini:FindSectionIndex(nx_string(form.clone_index))
  local bosslist = scene_ini:ReadString(sec_index, "BossList" .. nx_string(form.reward_index), "")
  local boss_table = util_split_string(nx_string(bosslist), ",")
  local gbox_boss = nx_null()
  local height = (nx_int((table.getn(boss_table) - 1) / 4) + 1) * (form.gbox_boss1.Height + 20)
  gbox_boss = create_ctrl("GroupBox", "gbox_item_boss", form.gbox_bosses, form.gbox_bosses_show)
  gbox_boss.Height = height
  for i = 1, table.getn(boss_table) do
    local boss_id = boss_table[i]
    local gbox_item
    if (i - 1) % 4 == 0 then
      gbox_item = create_ctrl("GroupBox", "gbox_item_" .. boss_id, form.gbox_boss1, gbox_boss)
    elseif (i - 1) % 4 == 1 then
      gbox_item = create_ctrl("GroupBox", "gbox_item_" .. boss_id, form.gbox_boss2, gbox_boss)
    elseif (i - 1) % 4 == 2 then
      gbox_item = create_ctrl("GroupBox", "gbox_item_" .. boss_id, form.gbox_boss3, gbox_boss)
    elseif (i - 1) % 4 == 3 then
      gbox_item = create_ctrl("GroupBox", "gbox_item_" .. boss_id, form.gbox_boss4, gbox_boss)
    end
    gbox_item.Top = (form.gbox_boss1.Height + 18) * nx_int((i - 1) / 4) + 13
    local grid_photo = create_ctrl("ImageGrid", "grid_photo_" .. boss_id, form.grid_boss_photo, gbox_item)
    local sec_index = npc_ini:FindSectionIndex(nx_string(boss_id))
    local npc_photo = npc_ini:ReadString(sec_index, "Photo", "")
    grid_photo:AddItem(0, nx_string(npc_photo), "", nx_int(1), -1)
    nx_bind_script(grid_photo, nx_current())
    nx_callback(grid_photo, "on_mousein_grid", "on_grid_boss_photo_mousein_grid")
    nx_callback(grid_photo, "on_mouseout_grid", "on_grid_boss_photo_mouseout_grid")
    grid_photo.boss_id = boss_id
  end
  form.gbox_bosses_show.IsEditMode = false
  form.gbox_bosses_show:ResetChildrenYPos()
  form.gbox_bosses_show.VScrollBar.Value = 0
end
function on_grid_boss_photo_mousein_grid(self, index)
  if not nx_is_valid(self) then
    return
  end
  if not nx_find_custom(self, "boss_id") then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  self.BackColor = "55,255,255,0"
  nx_execute("form_stage_main\\form_clone\\form_clone_describe_boss", "open_form", self.boss_id)
end
function on_grid_boss_photo_mouseout_grid(self, index)
  if not nx_is_valid(self) then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  self.BackColor = "0,255,255,255"
  nx_execute("form_stage_main\\form_clone\\form_clone_describe_boss", "close_form")
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
  if not nx_is_valid(parent_ctrl) then
    return
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function on_reward_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local drop_form = nx_value("form_stage_main\\form_clone\\form_clone_drop")
  if not nx_is_valid(drop_form) then
    nx_execute("form_stage_main\\form_clone\\form_clone_drop", "show_clone_drop_info", form.reward_clone_id, form.reward_index)
    btn.Checked = true
  else
    drop_form.Visible = false
    drop_form:Close()
    btn.Checked = false
  end
end
function ctrl_tip_open()
  local form = nx_value(FORM_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  form.ctrl_down = true
end
function ctrl_tip_close()
  local form = nx_value(FORM_MAIN_PATH)
  if not nx_is_valid(form) then
    return
  end
  form.ctrl_down = false
  local drop_form = nx_value("form_stage_main\\form_clone\\form_clone_drop")
  if nx_is_valid(drop_form) and form.ctrl_down == false then
    drop_form.Visible = false
    drop_form:Close()
  end
end
function on_btn_reward_get_capture(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_clone\\form_clone_drop", "show_clone_drop_info", form.reward_clone_id, form.reward_index)
end
function on_btn_reward_lost_capture(btn)
  if not nx_is_valid(btn) then
    return
  end
  local drop_form = nx_value("form_stage_main\\form_clone\\form_clone_drop")
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(drop_form) and form.ctrl_down == false then
    drop_form.Visible = false
    drop_form:Close()
  end
end
function on_btn_Reset_click(btn)
  util_show_form("form_stage_main\\form_clone\\form_clone_guide", true)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_ctl_click(btn)
end
function on_btn_captain_click(btn)
end
function on_btn_request_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "clone_config") then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "jdpd18")
    return
  end
  if not nx_find_custom(form, "clone_level") then
    return
  end
  local scene_ini = nx_execute("util_functions", "get_ini", SCENE_DES_FILE)
  if not nx_is_valid(scene_ini) then
    return 0
  end
  local pCloneConfig = form.clone_config
  local nLevel = form.clone_level
  nx_execute("custom_sender", "custom_random_clone", nx_int(CLIENT_SUBMSG_REQUEST_ENTER_CLONE), nx_string(pCloneConfig), nx_int(nLevel))
end
function client_request_leave_clone()
  nx_execute("custom_sender", "custom_random_clone", nx_int(CLIENT_SUBMSG_REQUEST_OUT_CLONE))
end
function on_describe_get_capture(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_clone\\form_clone_describe_tip", "open_form", form.clone_index)
end
function on_describe_lost_capture(btn)
  nx_execute("form_stage_main\\form_clone\\form_clone_describe_tip", "close_form")
end
function get_player_powerlevel()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local power_level = player:QueryProp("PowerLevel")
  return power_level
end
function get_player_reset_clone_count()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local reset_count = player:QueryProp("ResetCount")
  local remain_count = MAX_RESET_COUNT - reset_count
  return remain_count
end
function get_clone_scene_powerlevel(limit_id)
  local condition_ini = nx_execute("util_functions", "get_ini", CDT_NORMAL_FILE)
  if not nx_is_valid(condition_ini) then
    return 0
  end
  local sec_index = condition_ini:FindSectionIndex(nx_string(limit_id))
  if sec_index < 0 then
    return 0
  end
  local limit_min = condition_ini:ReadString(sec_index, "min", "")
  if limit_min == "" or limit_min == nil then
    return 0
  end
  return limit_min
end
function get_clone_scene_switch(limit_id)
  local condition_ini = nx_execute("util_functions", "get_ini", CDT_NORMAL_FILE)
  if not nx_is_valid(condition_ini) then
    return 0
  end
  local sec_index = condition_ini:FindSectionIndex(nx_string(limit_id))
  if sec_index < 0 then
    return 0
  end
  local switch_id = condition_ini:ReadString(sec_index, "Para2", "")
  local limit_min = condition_ini:ReadString(sec_index, "min", "")
  if nx_int(limit_id) == nx_int(115246) then
    nx_msgbox(nx_string(limit_id))
    nx_msgbox(nx_string(switch_id))
    nx_msgbox(nx_string(limit_min))
  end
  if switch_id == "" or switch_id == nil then
    return 0
  end
  return switch_id
end
function get_diff_level_color(player_powerlevel, clonescene_powerlevel)
  if player_powerlevel == nil or clonescene_powerlevel == nil then
    return LEVEL_COLOR[1]
  end
  local diff_powerlevel = nx_number(player_powerlevel - clonescene_powerlevel)
  if diff_powerlevel < 0 or 10 < diff_powerlevel then
    return LEVEL_COLOR[1]
  end
  if 7 < diff_powerlevel then
    return LEVEL_COLOR[1]
  elseif 5 < diff_powerlevel then
    return LEVEL_COLOR[2]
  else
    return LEVEL_COLOR[3]
  end
end
function get_diff_level_info(player_powerlevel, clonescene_powerlevel)
  if player_powerlevel == nil or clonescene_powerlevel == nil then
    return CLONE_INFO[1]
  end
  local diff_powerlevel = nx_number(player_powerlevel - clonescene_powerlevel)
  if diff_powerlevel < 0 or 10 < diff_powerlevel then
    return CLONE_INFO[1]
  end
  if 7 < diff_powerlevel then
    return CLONE_INFO[1]
  elseif 5 < diff_powerlevel then
    return CLONE_INFO[2]
  else
    return CLONE_INFO[3]
  end
end
function get_diff_level_desc(player_powerlevel, clonescene_powerlevel)
  if player_powerlevel == nil or clonescene_powerlevel == nil then
    return CLONE_LEVEL[4]
  end
  local diff_powerlevel = nx_number(player_powerlevel - clonescene_powerlevel)
  if diff_powerlevel < 0 or 10 < diff_powerlevel then
    return CLONE_LEVEL[4]
  end
  if 7 < diff_powerlevel then
    return CLONE_LEVEL[1]
  elseif 5 < diff_powerlevel then
    return CLONE_LEVEL[2]
  else
    return CLONE_LEVEL[3]
  end
end
function get_player_reset_clone_count()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local reset_count = player:QueryProp("ResetCount")
  local remain_count = MAX_RESET_COUNT - reset_count
  return remain_count
end
function on_btn_story_review_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local default_path = nx_value("default_path")
  local dialog = nx_execute("form_common\\form_open_file", "util_open_file", "*.avi", default_path)
  local result, file_path, file_name = nx_wait_event(100000000, dialog, "open_file_return")
  if nil ~= file_name and "" ~= file_name then
    local path = string.sub(file_path, 1, -(string.len(file_name) + 1))
    nx_set_value("default_path", path)
  end
  if "ok" == result then
    nx_execute("form_stage_main\\form_camera\\form_movie_play", "movie_play", file_path)
  end
end
function on_mousein_row_changed(grid, new_row, old_row)
  if not nx_is_valid(grid) then
    return
  end
  last_row = new_row
  grid:SetGridForeColor(old_row, 0, nx_string(old_color))
  grid:SetGridForeColor(old_row, 1, nx_string(old_color))
  grid:SetGridForeColor(old_row, 2, nx_string(old_color))
  grid:SetGridForeColor(old_row, 3, nx_string(old_color))
  old_color = grid:GetGridForeColor(new_row, 0)
  grid:SetGridForeColor(new_row, 0, "255,245,220,118")
  grid:SetGridForeColor(new_row, 1, "255,245,220,118")
  grid:SetGridForeColor(new_row, 2, "255,245,220,118")
  grid:SetGridForeColor(new_row, 3, "255,245,220,118")
end
function on_lost_capture(grid)
  if not nx_is_valid(grid) then
    return
  end
  grid:SetGridForeColor(last_row, 0, nx_string(old_color))
  grid:SetGridForeColor(last_row, 1, nx_string(old_color))
  grid:SetGridForeColor(last_row, 2, nx_string(old_color))
  grid:SetGridForeColor(last_row, 3, nx_string(old_color))
end
