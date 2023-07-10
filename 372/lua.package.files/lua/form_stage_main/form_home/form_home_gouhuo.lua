require("share\\view_define")
require("goods_grid")
require("util_gui")
require("util_functions")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("share\\capital_define")
require("custom_handler")
CLIENT_SUB_HOME_GOUHUO = 56
SUB_MSG_HOMEGOUHUO_LOCK = 1
SUB_MSG_HOMEGOUHUO_UNLOCK = 2
SUB_MSG_HOMEGOUHUO_ADD_FIRE = 3
SUB_MSG_HOMEGOUHUO_OPEN_BANQUET = 4
HGOUHUO_BACKMSG_OPEN = 1
HGOUHUO_BACKMSG_REFRESH = 2
HGOUHUO_BACKMSG_CLOSE = 3
HGOUHUO_BACKMSG_REFIRE = 4
HGOUHUO_BACKMSG_PLAY_ACT = 5
HOME_GOUHUO_REC = "HomeGouHuoRec"
HOME_GOUHUO_LEVEL = "HomeGouHuoLevel"
GOUHUO_REC_INDEX = 0
GOUHUO_REC_NAME = 1
GOUHUO_REC_CONFIG = 2
local FORM_NAME = "form_stage_main\\form_home\\form_home_gouhuo"
function open_form()
  util_auto_show_hide_form(FORM_NAME)
end
function main_form_init(self)
  self.Fixed = false
  self.add_speed = 0
  self.sel_view = -1
  self.sel_index = -1
  locked = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.index = -1
  self.npc = nil
  self.item_count = 0
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  for i = 0, 5 do
    local box = self:Find(string.format("%s_%s", "box", nx_string(i)))
    local imagegrid = box:Find(string.format("%s_%s", "imageitem", nx_string(i)))
    imagegrid.typeid = VIEWPORT_HOME_GOUHUO
    imagegrid:SetBindIndex(nx_int(0), nx_int(i + 1))
    databinder:AddViewBind(VIEWPORT_HOME_GOUHUO, imagegrid, FORM_NAME, "on_view_operat")
  end
  databinder:AddTableBind(HOME_GOUHUO_REC, self, nx_current(), "on_rec_refresh")
  databinder:AddRolePropertyBind(HOME_GOUHUO_LEVEL, "int", self, nx_current(), "on_gouhuo_level_changed")
  return 1
end
function on_main_form_close(self)
  nx_execute("custom_sender", "custom_msg_home_gouhuo", CLIENT_SUB_HOME_GOUHUO, SUB_MSG_HOMEGOUHUO_UNLOCK, self.sel_view, self.sel_index)
  util_show_form("form_stage_main\\form_wuxue\\form_wuxue_act_tips", false)
  self.sel_index = -1
  self.sel_view = -1
  self.add_speed = 0
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "on_time_reset_addspeed", self)
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  for i = 0, 6 do
    local imagegrid = self:Find(string.format("%s_%s", "imageitem", nx_string(i)))
    databinder:DelViewBind(imagegrid)
  end
  nx_destroy(self)
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_imageitem_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_msg_home_gouhuo", CLIENT_SUB_HOME_GOUHUO, SUB_MSG_HOMEGOUHUO_UNLOCK, form.sel_view, form.sel_index)
  grid:Clear()
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
end
function on_imageitem_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(form.index) ~= nx_number(grid.DataSource) then
    return
  end
  if grid:IsEmpty(index) == false then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local gui = nx_value("gui")
  local gameHand = gui.GameHand
  if gameHand:IsEmpty() then
    return
  end
  local gamehand_type = gameHand.Type
  if gamehand_type ~= GHT_VIEWITEM then
    gameHand:ClearHand()
    return
  end
  local src_viewid = nx_int(gui.GameHand.Para1)
  local src_pos = nx_int(gui.GameHand.Para2)
  if form.sel_view == src_viewid and form.sel_index == src_pos then
    gameHand:ClearHand()
    return
  end
  if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid)) then
    gameHand:ClearHand()
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    gameHand:ClearHand()
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
  if not nx_is_valid(item) then
    gameHand:ClearHand()
    return
  end
  local lock_status = item:QueryProp("LockStatus")
  if 0 < lock_status then
    gameHand:ClearHand()
    return
  end
  local configid = item:QueryProp("ConfigID")
  local suecceed = HomeManager:CheckHomeGouHuoItem(nx_string(configid))
  if suecceed == false then
    custom_sysinfo(1, 1, 1, 2, "sys_bonfire_004")
    gameHand:ClearHand()
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_inputbox", true, false)
  dialog:ShowModal()
  dialog.info_label.Text = gui.TextManager:GetText("sys_bonfire_008")
  local res, text = nx_wait_event(100000000, dialog, "input_box_return")
  local amount = 1
  if res == "ok" then
    amount = nx_number(text)
    local item_count = item:QueryProp("Amount")
    if nx_number(amount) > nx_number(item_count) then
      custom_sysinfo(1, 1, 1, 2, "sys_bonfire_009")
      gameHand:ClearHand()
      return
    end
    form.item_count = amount
    local photo = get_photo_amont(item)
    if "" == photo then
      gameHand:ClearHand()
      return
    end
    clearform(form, grid)
    grid:AddItem(index, photo, "", amount, -1)
    form.sel_view = src_viewid
    form.sel_index = src_pos
    form.is_change = false
    nx_execute("custom_sender", "custom_msg_home_gouhuo", CLIENT_SUB_HOME_GOUHUO, SUB_MSG_HOMEGOUHUO_LOCK, form.sel_view, form.sel_index, amount)
    gameHand:ClearHand()
  end
end
function on_imageitem_mousein_grid(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(form.index) ~= nx_number(grid.DataSource) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if form.sel_view ~= VIEWPORT_TOOL then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  nx_execute("tips_game", "show_3d_tips_one", view_item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm, false)
end
function on_imageitem_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function get_photo_amont(item)
  local photo = ""
  local amount = 0
  if nx_is_valid(item) then
    photo = nx_execute("util_static_data", "query_equip_photo_by_sex", item)
    amount = 1
  end
  return photo, amount
end
function clearform(form, grid)
  if not nx_is_valid(form) then
    return
  end
  grid:Clear()
  form.sel_index = -1
  form.sel_view = -1
end
function refresh_grid(grid, item_config, amount)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local photo = ItemQuery:GetItemPropByConfigID(item_config, "Photo")
  grid:AddItem(0, photo, "", amount, -1)
end
function on_rec_refresh(amount)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
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
  if not client_player:FindProp("HomeGouHuoNpc") then
    return
  end
  local gouhuo = client_player:QueryProp("HomeGouHuoNpc")
  local client_npc = game_client:GetSceneObj(nx_string(gouhuo))
  if not nx_is_valid(client_npc) then
    return
  end
  local row = client_npc:GetRecordRows(HOME_GOUHUO_REC)
  for i = 0, row - 1 do
    local index = client_npc:QueryRecord(HOME_GOUHUO_REC, i, GOUHUO_REC_INDEX)
    local name = client_npc:QueryRecord(HOME_GOUHUO_REC, i, GOUHUO_REC_NAME)
    local item_config = client_npc:QueryRecord(HOME_GOUHUO_REC, i, GOUHUO_REC_CONFIG)
    local box = form:Find(string.format("%s_%s", "box", nx_string(index)))
    local lbl_player = box:Find(string.format("%s_%s", "player_name", nx_string(index)))
    lbl_player.Text = nx_widestr(name)
    local imagegrid = box:Find(string.format("%s_%s", "imageitem", nx_string(index)))
    imagegrid.item_config = item_config
    if nx_string(item_config) ~= "" then
      refresh_grid(imagegrid, item_config, amount)
    else
      imagegrid:Clear()
    end
  end
end
function on_gouhuo_level_changed()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gouhuo = client_player:QueryProp("HomeGouHuoNpc")
  local client_npc = game_client:GetSceneObj(nx_string(gouhuo))
  local fire_level = client_npc:QueryProp(HOME_GOUHUO_LEVEL)
  local pic = HomeManager:GetGouHuoPicture(nx_int(fire_level))
  form.gouhuo_pic.BackImage = nx_string(pic)
end
function on_btn_add_fire_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_msg_home_gouhuo", CLIENT_SUB_HOME_GOUHUO, SUB_MSG_HOMEGOUHUO_ADD_FIRE, form.sel_view, form.sel_index, form.item_count)
  form.sel_view = -1
  form.sel_index = -1
  local index = form.index
  local box = form:Find(string.format("%s_%s", "box", nx_string(index)))
  local imagegrid = box:Find(string.format("%s_%s", "imageitem", nx_string(index)))
  imagegrid:Clear()
end
function on_btn_open_banquet_click(btn)
  nx_execute("custom_sender", "custom_msg_home_gouhuo", CLIENT_SUB_HOME_GOUHUO, SUB_MSG_HOMEGOUHUO_OPEN_BANQUET)
end
function create_path_effect(form, index)
  if not nx_is_valid(form) then
    return
  end
  local box = form:Find(string.format("%s_%s", "box", nx_string(index)))
  if not nx_is_valid(box) then
    return
  end
  local ani_path_pos_list = {}
  ani_path_pos_list[1] = {left = 0, top = 0}
  ani_path_pos_list[1].left = box.AbsLeft + box.Width / 2
  ani_path_pos_list[1].top = box.AbsTop + box.Height / 2
  ani_path_pos_list[3] = {left = 0, top = 0}
  ani_path_pos_list[3].left = form.gouhuo_pic.AbsLeft + form.gouhuo_pic.Width / 2
  ani_path_pos_list[3].top = form.gouhuo_pic.AbsTop + form.gouhuo_pic.Height / 2
  ani_path_pos_list[2] = {left = 0, top = 0}
  ani_path_pos_list[2].left = math.random(math.min(ani_path_pos_list[1].left, ani_path_pos_list[3].left), math.max(ani_path_pos_list[1].left, ani_path_pos_list[3].left))
  ani_path_pos_list[2].top = math.random(math.min(ani_path_pos_list[1].top, ani_path_pos_list[3].top), math.max(ani_path_pos_list[1].top, ani_path_pos_list[3].top))
  local gui = nx_value("gui")
  local ani_path = gui:Create("AnimationPath")
  form:Add(ani_path)
  ani_path.AnimationImage = "gui\\animations\\path_effect\\star.dds"
  ani_path.SmoothPath = true
  ani_path.Loop = false
  ani_path.ClosePath = false
  ani_path.Color = "255,255,126,0"
  ani_path.CreateMinInterval = 5
  ani_path.CreateMaxInterval = 10
  ani_path.RotateSpeed = 2
  ani_path.BeginAlpha = 1
  ani_path.AlphaChangeSpeed = 1
  ani_path.BeginScale = 0.17
  ani_path.ScaleSpeed = 0
  ani_path.MaxTime = 1000
  ani_path.MaxWave = 0.05
  ani_path:ClearPathPoints()
  for i = 1, table.getn(ani_path_pos_list) do
    local ani_path_pos = ani_path_pos_list[i]
    ani_path:AddPathPoint(ani_path_pos.left, ani_path_pos.top)
  end
  ani_path:AddPathPointFinish()
  nx_bind_script(ani_path, nx_current())
  nx_callback(ani_path, "on_animation_end", "on_ani_path_end")
  ani_path:Play()
  return ani_path
end
function on_msg_act_play(index)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  create_path_effect(form, index)
  form.add_speed = 0.2
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:AddExecute("ActFaculty", form, 0.01)
  end
  local timer = nx_value("timer_game")
  timer:Register(2000, 1, FORM_NAME, "on_time_reset_addspeed", form, -1, -1)
end
function on_time_reset_addspeed(form)
  if not nx_is_valid(form) then
    return
  end
  form.add_speed = 0
  return
end
function on_server_msg(submsg, ...)
  if nx_int(submsg) == nx_int(HGOUHUO_BACKMSG_OPEN) then
    local index = arg[1]
    open_form()
    local form = nx_value(FORM_NAME)
    if nx_is_valid(form) then
      form.index = index
    end
  elseif nx_int(submsg) == nx_int(HGOUHUO_BACKMSG_REFRESH) then
    local amount = nx_number(arg[1])
    on_rec_refresh(amount)
  elseif nx_int(submsg) == nx_int(HGOUHUO_BACKMSG_CLOSE) then
    local form = nx_value(FORM_NAME)
    if nx_is_valid(form) then
      form:Close()
    end
  elseif nx_int(submsg) == nx_int(HGOUHUO_BACKMSG_REFIRE) then
    on_gouhuo_level_changed()
  elseif nx_int(submsg) == nx_int(HGOUHUO_BACKMSG_PLAY_ACT) then
    local index = arg[1]
    on_msg_act_play(index)
  end
end
