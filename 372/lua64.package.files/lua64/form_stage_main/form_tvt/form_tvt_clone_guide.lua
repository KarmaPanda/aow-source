require("util_gui")
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
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(CLONE_SAVE_REC, form, nx_current(), "on_rec_refresh")
  end
  nx_execute("custom_sender", "get_leave_time_clone")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = (gui.Desktop.Height - form.Height) / 2
  form.rbtn_1.select_type = "clone_reset"
  form.rbtn_2.select_type = "clone_info"
  local sub_form = util_get_form("form_stage_main\\form_tvt\\form_tvt_clone_info", true, false)
  if form:Add(sub_form) then
    sub_form.Visible = false
    sub_form.Fixed = true
    sub_form.Top = 70
    sub_form.Left = 8
  end
  nx_set_custom(form, "form_tvt_clone_info", sub_form)
  local remain_resetcount = get_player_reset_clone_count()
  form.lbl_reset_count.Text = nx_widestr(remain_resetcount)
  form.rbtn_1.Checked = true
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(CLONE_SAVE_REC, form)
  end
  nx_destroy(form)
end
function on_clonetype_checked_changed(rbtn)
  if not rbtn.Checked then
    return 0
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if nx_find_custom(form, "cur_form") and nx_is_valid(form.cur_form) then
    form.cur_form.Visible = false
  end
  if nx_number(rbtn.DataSource) == 1 then
    form.groupbox_main.Visible = true
  elseif nx_number(rbtn.DataSource) == 2 then
    form.groupbox_main.Visible = false
    if not nx_find_custom(form, "form_tvt_clone_info") then
      return 0
    end
    local sub_form = nx_custom(form, "form_tvt_clone_info")
    if not nx_is_valid(sub_form) then
      return 0
    end
    sub_form.Visible = true
    form.cur_form = sub_form
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local sub_form = nx_custom(form, "form_tvt_clone_info")
  if nx_is_valid(sub_form) then
    sub_form:Close()
  end
  form:Close()
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
  form.grid_clone:ClearRow()
  form.grid_clone:ClearSelect()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(CLONE_SAVE_REC) then
    return 0
  end
  local clone_ini = nx_execute("util_functions", "get_ini", SCENE_CFG_FILE)
  if not nx_is_valid(clone_ini) then
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
    if 0 > nx_number(level) or nx_number(level) > 4 then
      level = 1
    end
    local leveltxt = gui.TextManager:GetText(CLONE_INFO[nx_number(level)])
    local row = form.grid_clone:InsertRow(-1)
    form.grid_clone:SetGridText(row, 0, nx_widestr(nametxt .. leveltxt))
    form.grid_clone:SetGridText(row, 1, nx_widestr(progtxt))
    form.grid_clone:SetGridText(row, 2, nx_widestr(timetxt))
    local btn_ctl = gui:Create("Button")
    btn_ctl.Text = nx_widestr("@ui_reset")
    btn_ctl.Font = "font_sns_event_mid"
    btn_ctl.ForeColor = "255,255,255,255"
    btn_ctl.NormalImage = nx_string("gui\\common\\button\\btn_normal2_out.png")
    btn_ctl.FocusImage = nx_string("gui\\common\\button\\btn_normal2_on.png")
    btn_ctl.PushImage = nx_string("gui\\common\\button\\btn_normal2_down.png")
    btn_ctl.DisableImage = nx_string("gui\\common\\button\\btn_normal2_forbid.png")
    btn_ctl.DrawMode = ExpandH
    btn_ctl.grid_row = row
    btn_ctl.grid_col = 3
    nx_bind_script(btn_ctl, nx_current())
    nx_callback(btn_ctl, "on_click", "on_btn_ctl_click")
    form.grid_clone:SetGridControl(row, 3, btn_ctl)
  end
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
function on_btn_ctl_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local scene_ini = nx_execute("util_functions", "get_ini", SCENE_DES_FILE)
  if not nx_is_valid(scene_ini) then
    return 0
  end
  local clone_ini = nx_execute("util_functions", "get_ini", SCENE_CFG_FILE)
  if not nx_is_valid(clone_ini) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local select_index = btn.grid_row
  local propID = client_player:QueryRecord(CLONE_SAVE_REC, select_index, 0)
  local index = clone_ini:FindSectionIndex(nx_string(propID))
  local pCloneConfig = ""
  if 0 < nx_number(index) then
    pCloneConfig = clone_ini:ReadString(nx_int(index), "Config", "")
  end
  local nLevel = client_player:QueryRecord(CLONE_SAVE_REC, select_index, 6)
  nx_execute("custom_sender", "reset_save_clone", nx_string(pCloneConfig), nx_int(nLevel))
  local remain_resetcount = get_player_reset_clone_count()
  form.lbl_reset_count.Text = nx_widestr(remain_resetcount)
end
function on_btn_reset_clone_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local scene_ini = nx_execute("util_functions", "get_ini", SCENE_DES_FILE)
  if not nx_is_valid(scene_ini) then
    return 0
  end
  local clone_ini = nx_execute("util_functions", "get_ini", SCENE_CFG_FILE)
  if not nx_is_valid(clone_ini) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local select_index = form.grid_clone.RowSelectIndex
  local propID = client_player:QueryRecord(CLONE_SAVE_REC, select_index, 0)
  local index = clone_ini:FindSectionIndex(nx_string(propID))
  local pCloneConfig = ""
  if 0 < nx_number(index) then
    pCloneConfig = clone_ini:ReadString(nx_int(index), "Config", "")
  end
  local nLevel = client_player:QueryRecord(CLONE_SAVE_REC, select_index, 6)
  nx_execute("custom_sender", "captain_reset_save_clone", nx_string(pCloneConfig), nx_int(nLevel))
  local remain_resetcount = get_player_reset_clone_count()
  form.lbl_reset_count.Text = nx_widestr(remain_resetcount)
end
function set_select_stage(form, select_type)
  if select_type == "" or select_type == nil then
    select_type = "clone_reset"
  end
  if select_type == "clone_reset" then
    form.groupbox_main.Visible = true
  elseif select_type == "clone_info" then
  end
end
