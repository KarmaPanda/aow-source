require("util_gui")
require("game_object")
require("util_functions")
require("custom_sender")
require("goods_grid")
require("share\\view_define")
require("define\\tip_define")
require("tips_func_equip")
require("form_stage_main\\form_guild\\sub_command_define")
require("form_stage_main\\form_guildbuilding\\sub_command_define")
local SUBMSG_CLIENT_GET_AVOID_INFO = 1
local SUBMSG_CLIENT__AVOID_WAR = 2
local ITEM_TYPE = 201
function main_form_init(self)
  self.Fixed = false
  self.index = 0
  self.npc_id = nil
  self.avoid_time = 0
  self.cd_time = 0
  self.avoid_item_configid = ""
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  for i = 1, 6 do
    self.form_shop_goods:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  self.form_shop_goods.canselect = flase
  self.form_shop_goods.candestroy = flase
  request_avoid_item_info()
  return 1
end
function on_main_form_close(self)
  return 1
end
function on_btn_close_click(self)
  on_btn_cancel_click(self)
end
function on_btn_avoid_click(self)
  local form = self.ParentForm
  if form.avoid_item_configid == "" then
    return false
  end
  if form.npc_id == nil then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_AVOID_OPERATE), nx_int(SUBMSG_CLIENT__AVOID_WAR), form.npc_id, form.avoid_item_configid)
  form:Close()
  nx_destroy(form)
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  remove_heartbeat(form)
  form:Close()
  nx_destroy(form)
end
function on_form_shop_goods_mousein_grid(self, index)
  if self:IsEmpty(index) then
    return 0
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    local viewobj = GoodsGrid:GetItemData(self, index)
    viewobj.Amount = viewobj.Count
    viewobj.MaxAmount = 1
    nx_execute("tips_game", "show_goods_tip", viewobj, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 32, 32, self.ParentForm)
  end
end
function on_form_shop_goods_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_form_shop_goods_select_changed(self, index)
  local form = self.ParentForm
  if self:IsEmpty(index) then
    return 0
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    local viewobj = GoodsGrid:GetItemData(self, index)
    form.avoid_item_configid = viewobj.ConfigID
  end
end
function request_avoid_item_info()
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_avoid")
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_AVOID_OPERATE), nx_int(SUBMSG_CLIENT_GET_AVOID_INFO), form.npc_id)
  return true
end
function get_avoid_item_info(...)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_avoid")
  if not nx_is_valid(form) then
    return
  end
  local remain_avoid_time = get_format_time_text(form.avoid_time)
  form.lbl_avoid_time.Text = nx_widestr(remain_avoid_time)
  local remain_cd_time = get_format_time_text(form.cd_time)
  form.lbl_cd_time.Text = nx_widestr(remain_cd_time)
  if nx_int(form.avoid_time) > nx_int(0) then
    avoid_init_timer(form.avoid_time, form.npc_id)
    form.btn_avoid.Enabled = false
  else
    form.btn_avoid.Enabled = true
  end
  if nx_int(form.cd_time) > nx_int(0) then
    cd_init_timer(form.cd_time, form.npc_id)
    form.btn_avoid.Enabled = false
  else
    form.btn_avoid.Enabled = true
  end
  local size = table.getn(arg)
  if size < 0 or size % 2 ~= 0 then
    return 0
  end
  local rows = size / 2
  local GoodsGrid = nx_value("GoodsGrid")
  for i = 0, rows - 1 do
    if nx_is_valid(GoodsGrid) then
      local item_data = nx_create("ArrayList", "item_data:" .. nx_current())
      local base = i * 2
      item_data.ConfigID = arg[base + 1]
      item_data.Count = arg[base + 2]
      item_data.item_type = ITEM_TYPE
      GoodsGrid:GridAddItem(form.form_shop_goods, i, item_data)
      form.form_shop_goods:SetBindIndex(i, i + 1)
    end
  end
end
function avoid_init_timer(time, ident)
  local timer = nx_value("timer_game")
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(ident))
  if not nx_is_valid(npc) then
    return false
  end
  local obj = game_client:GetSceneObj(nx_string(ident))
  if nx_is_valid(obj) then
    timer:Register(1000, -1, nx_current(), "on_update_avoid_time", obj, -1, -1)
  end
end
function on_update_avoid_time(obj)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_avoid")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_avoid", true, false)
    nx_set_value("form_stage_main\\form_guild_war\\form_guild_war_avoid", form)
  end
  form.avoid_time = form.avoid_time - 1
  local remain = get_format_time_text(form.avoid_time)
  form.lbl_avoid_time.Text = nx_widestr(remain)
  if form.avoid_time <= 0 then
    stop_avoid_timer(obj)
    form.btn_avoid.Enabled = true
  end
end
function stop_avoid_timer(obj)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "on_update_avoid_time", obj)
end
function cd_init_timer(time, ident)
  local timer = nx_value("timer_game")
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(ident))
  if not nx_is_valid(npc) then
    return false
  end
  local obj = game_client:GetSceneObj(nx_string(ident))
  if nx_is_valid(obj) then
    timer:Register(1000, -1, nx_current(), "on_update_cd_time", obj, -1, -1)
  end
end
function on_update_cd_time(obj)
  local form = nx_value("form_stage_main\\form_guild_war\\form_guild_war_avoid")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_avoid", true, false)
    nx_set_value("form_stage_main\\form_guild_war\\form_guild_war_avoid", form)
  end
  form.cd_time = form.cd_time - 1
  local remain = get_format_time_text(form.cd_time)
  form.lbl_cd_time.Text = nx_widestr(remain)
  if form.avoid_time <= 0 then
    stop_timer(obj)
    form.btn_avoid.Enabled = true
  end
end
function stop_timer(obj)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "on_update_cd_time", obj)
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time)
end
function remove_heartbeat(form)
  if not nx_is_valid(form) then
    return
  end
  if form.npc_id == nil then
    return
  end
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(form.npc_id))
  if not nx_is_valid(npc) then
    return false
  end
  local obj = game_client:GetSceneObj(nx_string(ident))
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  if nx_int(form.avoid_time) > nx_int(0) then
    timer:UnRegister(nx_current(), "on_update_avoid_time", obj)
  end
  if nx_int(form.cd_time) > nx_int(0) then
    timer:UnRegister(nx_current(), "on_update_cd_time", obj)
  end
end
