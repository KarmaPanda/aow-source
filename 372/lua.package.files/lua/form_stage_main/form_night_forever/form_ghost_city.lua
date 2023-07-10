require("util_static_data")
require("util_functions")
require("util_gui")
local FORM_PATH = "form_stage_main\\form_night_forever\\form_ghost_city"
local CLIENT_SUB_GHOST_CITY_BEGIN_TY = 1
local CLIENT_SUB_GHOST_CITY_UNLOCK_FORM = 3
local CLIENT_SUB_GHOST_CITY_GET_DAY_VALUE = 4
local CLIENT_SUB_GHOST_CITY_ACCEPT_TASK = 5
local CLIENT_SUB_GHOST_CITY_REQUEST_DATA = 6
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_form(form)
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
function init_form(form)
  form.max_value = 0
  form.reward = ""
  form.ani_1.Visible = false
  form.groupbox_3.Visible = false
  form.rbtn_1.Checked = true
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local is_unlock = client_player:QueryProp("GhostCityIsUnlock")
  if nx_number(is_unlock) == nx_number(0) then
    form.init_box.Visible = true
  else
    form.init_box.Visible = false
  end
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("GhostCityIsUnlock", "int", form, FORM_PATH, "on_GhostCityIsUnlock_changed")
  databinder:AddRolePropertyBind("GhostCityQBValue", "int", form, FORM_PATH, "on_GhostCityQBValue_changed")
  databinder:AddRolePropertyBind("GhostCityTYValue", "int", form, FORM_PATH, "on_GhostCityTYValue_changed")
  databinder:AddRolePropertyBind("GhostCityGetDayValue", "int", form, FORM_PATH, "on_GhostCityGetDayValue_changed")
  databinder:AddTableBind("Task_Accepted", form, FORM_PATH, "on_Task_Accepted_change")
  task_btn_refresh(form)
  nx_execute("custom_sender", "custom_ghost_city", CLIENT_SUB_GHOST_CITY_REQUEST_DATA)
end
function task_btn_refresh(form)
  local gui = nx_value("gui")
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local task_id = 75100
  local completed = taskmgr:CompletedByRec(nx_string(task_id))
  local row = client_player:FindRecordRow("Task_Accepted", 0, nx_int(task_id), 0)
  form.lbl_25.ForeColor = "255,255,0,0"
  form.lbl_25.Text = nx_widestr(gui.TextManager:GetText("ui_guishi_task_tips01"))
  if 0 <= row or 0 < completed then
    form.btn_4.Enabled = false
    form.btn_3.Visible = true
    form.lbl_25.Visible = true
  else
    form.btn_4.Enabled = true
    form.btn_3.Visible = false
    form.lbl_25.Visible = false
  end
  if 0 < taskmgr:CompletedByRec(nx_string(75108)) then
    form.lbl_25.ForeColor = "255,0,255,0"
    form.lbl_25.Text = nx_widestr(gui.TextManager:GetText("ui_guishi_task_tips02"))
  end
end
function on_Task_Accepted_change(form)
  task_btn_refresh(form)
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  local gui = nx_value("gui")
  local FiveSkyQuery = nx_value("FiveSkyQuery")
  if not nx_is_valid(FiveSkyQuery) then
    return
  end
  if rbtn.Checked == false then
    return
  end
  local info = FiveSkyQuery:GetGhostCityInfo(rbtn.DataSource)
  local title = FiveSkyQuery:GetGhostCityTitle(rbtn.DataSource)
  form.mltbox_6.HtmlText = nx_widestr(gui.TextManager:GetFormatText(info[1]))
  form.mltbox_5.HtmlText = nx_widestr(gui.TextManager:GetFormatText(title[1]))
  if nx_string(rbtn.DataSource) == "Task_1" then
    form.groupbox_3.Visible = true
  else
    form.groupbox_3.Visible = false
  end
  if nx_string(rbtn.DataSource) == "Task_8" then
    form.btn_5.Visible = true
  else
    form.btn_5.Visible = false
  end
end
function on_imagegrid_reward_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_reward_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip")
end
function on_ani_1_animation_end(ani)
  local form = ani.ParentForm
  form.init_box.Visible = false
end
function on_btn_3_click(btn)
  nx_execute("custom_sender", "custom_ghost_city", CLIENT_SUB_GHOST_CITY_UNLOCK_FORM)
end
function on_GhostCityIsUnlock_changed(form)
  if form.init_box.Visible == false then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local is_unlock = client_player:QueryProp("GhostCityIsUnlock")
  if nx_number(is_unlock) > nx_number(0) then
    form.btn_3.Visible = false
    form.lbl_24.Visible = false
    form.lbl_25.Visible = false
    form.lbl_53.Visible = false
    form.mltbox_7.Visible = false
    form.btn_4.Visible = false
    form.ani_1.Visible = true
    form.ani_1.Loop = false
    form.ani_1.PlayMode = 2
    form.ani_1.Visible = true
    form.ani_1:Play()
  end
end
function on_GhostCityQBValue_changed(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.lbl_qb.Text = nx_widestr(client_player:QueryProp("GhostCityQBValue"))
end
function on_GhostCityTYValue_changed(form)
  if form.max_value == 0 then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.pbar_1.Maximum = form.max_value
  form.pbar_1.Minimum = 0
  form.pbar_1.Value = client_player:QueryProp("GhostCityTYValue")
  form.lbl_ty_value.Text = nx_widestr(nx_string(form.pbar_1.Value) .. "/" .. nx_string(form.pbar_1.Maximum))
end
function on_GhostCityGetDayValue_changed(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local flag = client_player:QueryProp("GhostCityGetDayValue")
  if flag == 0 then
    form.btn_1.Enabled = true
  else
    form.btn_1.Enabled = false
  end
end
function on_btn_2_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_night_forever\\form_ghost_city_ty")
end
function on_btn_1_click(btn)
  nx_execute("custom_sender", "custom_ghost_city", CLIENT_SUB_GHOST_CITY_GET_DAY_VALUE)
end
function on_btn_4_click(btn)
  nx_execute("custom_sender", "custom_ghost_city", CLIENT_SUB_GHOST_CITY_ACCEPT_TASK)
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
  if 0 >= table.getn(table_prop_name) then
    return
  end
  table_prop_value.ConfigID = nx_string(prize_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", "task_grid_data")
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_set_custom(grid.Data, "is_static", true)
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
  grid.Data:ClearChild()
end
function on_btn_5_click(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  if not condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(118379)) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_guishi_tuiyan_btn05_condition"), 2)
    end
    return false
  end
  util_auto_show_hide_form("form_stage_main\\form_world_auction\\form_black_market")
end
