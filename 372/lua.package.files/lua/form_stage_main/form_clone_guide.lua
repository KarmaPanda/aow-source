require("util_functions")
require("define\\gamehand_type")
local SCENE_CFG_FILE = "ini\\scenes.ini"
local SCENE_DES_FILE = "ini\\ui\\clonescene\\clonescenedesc.ini"
local CDT_NORMAL_FILE = "share\\Rule\\condition.ini"
local MAX_RESET_COUNT = 7
local CLONE_SAVE_REC = "clone_rec_save"
local SHOW_CLONE_COUNT = 6
local clone_count = {
  9,
  8,
  15,
  39,
  13
}
local CLONE_INFO = {
  "ui_clonerec_dif01",
  "ui_clonerec_dif02",
  "ui_clonerec_dif03"
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
  form.min_page = 1
  form.cur_page = 0
  form.max_page = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(CLONE_SAVE_REC, form, nx_current(), "on_rec_refresh")
  end
  nx_execute("custom_sender", "get_leave_time_clone")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = (gui.Desktop.Height - form.Height) / 2
  form.grid_clone:SetColAlign(0, "left")
  form.grid_clone:SetColTitle(0, gui.TextManager:GetText("ui_clonerec_title02"))
  form.grid_clone:SetColTitle(1, gui.TextManager:GetText("ui_clonerec_title03"))
  form.grid_clone:SetColTitle(2, gui.TextManager:GetText("ui_clonerec_title04"))
  form.grid_clone:SetColTitle(3, gui.TextManager:GetText("ui_clonerec_title05"))
  form.grid_clone:SetColTitle(4, gui.TextManager:GetText("ui_clonerec_title06"))
  local remain_resetcount = get_player_reset_clone_count()
  form.lbl_reset_count.Text = nx_widestr(remain_resetcount)
  show_clone_list(form)
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(CLONE_SAVE_REC, form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_page_up_click(self)
  local form = self.ParentForm
  form.cur_page = form.cur_page - 1
  show_page(form)
end
function on_btn_page_down_click(self)
  local form = self.ParentForm
  form.cur_page = form.cur_page + 1
  show_page(form)
end
function show_clone_list(form)
  local gui = nx_value("gui")
  form.grid_clone:ClearRow()
  form.grid_clone:ClearSelect()
  local scene_ini = nx_execute("util_functions", "get_ini", SCENE_DES_FILE)
  if not nx_is_valid(scene_ini) then
    nx_msgbox(SCENE_DES_FILE .. " " .. get_msg_str("msg_120"))
    return 0
  end
  local player_powerlevel = get_player_powerlevel()
  local sec_count = scene_ini:GetSectionCount()
  for i = 1, 3 do
    for j = 0, sec_count - 1 do
      local id = scene_ini:GetSectionByIndex(j)
      local name = scene_ini:ReadString(j, "Name", "")
      local location = scene_ini:ReadString(j, "Location", "")
      local switch_point = scene_ini:ReadString(j, "SwitchPoint", "")
      local player_num = scene_ini:ReadString(j, "MaxPlayers" .. i, "")
      local EntryLimited = scene_ini:ReadString(j, "EntryLimited" .. i, "")
      local scene_powerlevel = get_clone_scene_powerlevel(EntryLimited)
      local level_info = get_diff_level_info(player_powerlevel, scene_powerlevel)
      local level_desc = get_diff_level_desc(player_powerlevel, scene_powerlevel)
      if nx_number(player_powerlevel) >= nx_number(scene_powerlevel) then
        local row = form.grid_clone:InsertRow(-1)
        form.grid_clone:SetGridText(row, 0, gui.TextManager:GetText(name))
        form.grid_clone:SetGridText(row, 1, gui.TextManager:GetText(CLONE_INFO[i]))
        form.grid_clone:SetGridText(row, 2, gui.TextManager:GetText(location))
        form.grid_clone:SetGridText(row, 3, nx_widestr(switch_point))
        form.grid_clone:SetGridText(row, 4, nx_widestr(player_num))
        form.grid_clone:SetGridText(row, 5, gui.TextManager:GetText(level_desc))
      end
    end
  end
end
function on_rec_refresh(form, recordname, optype, row, clomn)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  if not form.Visible then
    return 0
  end
  if recordname ~= CLONE_SAVE_REC then
    return 0
  end
  form.mltbox_prog:Clear()
  form.max_page = 0
  form.cur_page = 0
  show_page(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(CLONE_SAVE_REC) then
    return 0
  end
  local clone_ini = nx_execute("util_functions", "get_ini", SCENE_CFG_FILE)
  if not nx_is_valid(clone_ini) then
    nx_msgbox(SCENE_CFG_FILE .. " " .. get_msg_str("msg_120"))
    return 0
  end
  local rownum = client_player:GetRecordRows(CLONE_SAVE_REC)
  for i = 0, rownum - 1 do
    local propID = client_player:QueryRecord(CLONE_SAVE_REC, i, 0)
    local index = clone_ini:FindSectionIndex(nx_string(propID))
    local name = ""
    if 0 <= index then
      name = clone_ini:ReadString(index, "Config", "")
    end
    local nametxt = gui.TextManager:GetText(nx_string(name))
    local prog = client_player:QueryRecord(CLONE_SAVE_REC, i, 1)
    local progtxt = gui.TextManager:GetFormatText("ui_fuben0011", nx_int(prog))
    local time = client_player:QueryRecord(CLONE_SAVE_REC, i, 5)
    local date_tab = util_split_string(time, ",")
    local timetxt = gui.TextManager:GetFormatText("ui_fuben0003", nx_int(date_tab[1]), nx_int(date_tab[2]), nx_int(date_tab[3]))
    local level = client_player:QueryRecord(CLONE_SAVE_REC, i, 6)
    if 0 > nx_number(level) or 3 < nx_number(level) then
      level = 1
    end
    local leveltxt = gui.TextManager:GetText(CLONE_INFO[nx_number(level)])
    local alltext = nametxt .. leveltxt .. nx_widestr("<br>") .. progtxt .. nx_widestr(" ") .. timetxt .. nx_widestr("<br><br>")
    local sel_key = nx_int(i / SHOW_CLONE_COUNT + 1)
    form.mltbox_prog:AddHtmlText(nx_widestr(alltext), nx_int(sel_key))
  end
  form.max_page = nx_int(rownum / SHOW_CLONE_COUNT + 1)
  form.cur_page = 1
  show_page(form)
  return 1
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
function show_page(form)
  form.mltbox_prog:ShowKeyItems(-1)
  form.mltbox_prog:ShowKeyItems(nx_int(form.cur_page))
  if form.cur_page > form.min_page then
    form.btn_page_up.Enabled = true
  else
    form.btn_page_up.Enabled = false
  end
  if form.max_page > form.cur_page then
    form.btn_page_down.Enabled = true
  else
    form.btn_page_down.Enabled = false
  end
  form.lbl_page.Text = nx_widestr(nx_string(form.cur_page) .. "/" .. nx_string(form.max_page))
end
function on_btn_reset_clone_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local scene_ini = nx_execute("util_functions", "get_ini", SCENE_DES_FILE)
  if not nx_is_valid(scene_ini) then
    nx_msgbox(SCENE_DES_FILE .. " " .. get_msg_str("msg_120"))
    return 0
  end
  local clone_ini = nx_execute("util_functions", "get_ini", SCENE_CFG_FILE)
  if not nx_is_valid(clone_ini) then
    nx_msgbox(SCENE_CFG_FILE .. " " .. get_msg_str("msg_120"))
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local mulbox_index = form.mltbox_prog:GetSelectItemIndex()
  local propID = client_player:QueryRecord(CLONE_SAVE_REC, mulbox_index, 0)
  local index = clone_ini:FindSectionIndex(nx_string(propID))
  local pCloneConfig = ""
  if 0 < nx_number(index) then
    pCloneConfig = clone_ini:ReadString(nx_int(index), "Config", "")
  end
  local nLevel = client_player:QueryRecord(CLONE_SAVE_REC, mulbox_index, 6)
  nx_execute("custom_sender", "reset_save_clone", nx_string(pCloneConfig), nx_int(nLevel))
  local remain_resetcount = get_player_reset_clone_count()
  form.lbl_reset_count.Text = nx_widestr(remain_resetcount)
end
