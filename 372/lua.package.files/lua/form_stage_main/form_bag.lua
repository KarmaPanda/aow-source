require("const_define")
require("share\\view_define")
require("util_gui")
require("utils")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("share\\itemtype_define")
require("share\\capital_define")
require("define\\gamehand_type")
require("form_stage_main\\switch\\switch_define")
require("util_functions")
require("util_vip")
local EQUIP_TYPE = 1
local TOOL_TYPE = 2
local MATERIAL_TYPE = 3
local TASK_TYPE = 4
local BAG_COLS = 6
local FORM_NAME = "form_stage_main\\form_bag"
local LOCK_IMAGE = {
  {
    normal = "gui\\common\\button\\btn_lock_out.png",
    focus = "gui\\common\\button\\btn_lock_on.png",
    push = "gui\\common\\button\\btn_lock_down.png"
  },
  {
    normal = "gui\\common\\button\\btn_unlock_out.png",
    focus = "gui\\common\\button\\btn_unlock_on.png",
    push = "gui\\common\\button\\btn_unlock_down.png"
  },
  {
    normal = "gui\\common\\button\\btn_setpassword_out.png",
    focus = "gui\\common\\button\\btn_setpassword_on.png",
    push = "gui\\common\\button\\btn_setpassword_down.png"
  }
}
local SECOND_WORD_STATE_LOCK = 0
local SECOND_WORD_STATE_UNLOCK = 1
function auto_show_hide_bag(b_show)
  local gui = nx_value("gui")
  local form = nx_value(FORM_NAME)
  nx_execute("form_stage_main\\form_consign\\form_buy_capital", "refresh_bag_golden_icon")
  if nx_is_valid(form) and b_show == nil then
    if form.Visible then
      hide_form_bag(form)
    else
      local client = nx_value("game_client")
      local player = client:GetPlayer()
      if nx_is_valid(player) then
        updata_lock_image(player:QueryProp("IsHaveSecondWord"))
      end
      change_bag_btn(false)
      reset_form_size(form)
      form.Visible = true
      gui.Desktop:ToFront(form)
    end
  else
    form = util_get_form("form_stage_main\\form_bag", true, true)
    if nx_is_valid(form) then
      form:Show()
      form.Visible = true
    end
  end
  if b_show ~= nil then
    form.Visible = b_show
    if b_show then
      gui.Desktop:ToFront(form)
    end
  end
  if on_is_jh_scene() then
    local form_bag = nx_value(FORM_NAME)
    if nx_is_valid(form_bag) then
      form_bag.Visible = false
    end
  end
  nx_execute("util_gui", "ui_show_attached_form", form)
  return form
end
local bag_form_old_x, bag_form_old_y
function move_bag_form(self)
  if bag_form_old_x then
    self.Left = bag_form_old_x
  end
  if bag_form_old_y then
    self.Top = bag_form_old_y
  end
end
function main_form_init(form)
  form.Fixed = false
  form.cur_grid = nil
  form.cur_addgrid = nil
  return 1
end
function on_main_form_open(form)
  init_grid(form.imagegrid_equip, VIEWPORT_EQUIP_TOOL, VIEWPORT_EQUIP_ADDTOOLBOX)
  init_grid(form.imagegrid_tool, VIEWPORT_TOOL, VIEWPORT_ADDTOOLBOX)
  init_grid(form.imagegrid_material, VIEWPORT_MATERIAL_TOOL, VIEWPORT_MATERIAL_ADDTOOLBOX)
  init_grid(form.imagegrid_task, VIEWPORT_TASK_TOOL, VIEWPORT_TASK_ADDTOOLBOX)
  init_grid(form.addbag_equip, VIEWPORT_EQUIP_ADDTOOLBOX, VIEWPORT_EQUIP_TOOL)
  init_grid(form.addbag_tool, VIEWPORT_ADDTOOLBOX, VIEWPORT_TOOL)
  init_grid(form.addbag_material, VIEWPORT_MATERIAL_ADDTOOLBOX, VIEWPORT_MATERIAL_TOOL)
  init_grid(form.addbag_task, VIEWPORT_TASK_ADDTOOLBOX, VIEWPORT_TASK_TOOL)
  form.rbtn_equip.Checked = false
  form.rbtn_equip.Checked = true
  form.lbl_equip.Visible = false
  form.lbl_tool.Visible = false
  form.lbl_material.Visible = false
  form.lbl_task.Visible = false
  form.lbl_repair.Visible = false
  form.lbl_repairall.Visible = false
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_EQUIP_TOOL, form.imagegrid_equip, FORM_NAME, "on_view_operat")
  databinder:AddViewBind(VIEWPORT_TOOL, form.imagegrid_tool, FORM_NAME, "on_view_operat")
  databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, form.imagegrid_material, FORM_NAME, "on_view_operat")
  databinder:AddViewBind(VIEWPORT_TASK_TOOL, form.imagegrid_task, FORM_NAME, "on_view_operat")
  databinder:BindViewItemPropChange(VIEWPORT_EQUIP_TOOL, form.imagegrid_equip)
  databinder:BindViewItemPropChange(VIEWPORT_TOOL, form.imagegrid_tool)
  databinder:BindViewItemPropChange(VIEWPORT_MATERIAL_TOOL, form.imagegrid_material)
  databinder:BindViewItemPropChange(VIEWPORT_TASK_TOOL, form.imagegrid_task)
  databinder:AddViewBind(VIEWPORT_EQUIP_ADDTOOLBOX, form.addbag_equip, FORM_NAME, "on_addtoolbox_view_operat1")
  databinder:AddViewBind(VIEWPORT_ADDTOOLBOX, form.addbag_tool, FORM_NAME, "on_addtoolbox_view_operat1")
  databinder:AddViewBind(VIEWPORT_MATERIAL_ADDTOOLBOX, form.addbag_material, FORM_NAME, "on_addtoolbox_view_operat1")
  databinder:AddViewBind(VIEWPORT_TASK_ADDTOOLBOX, form.addbag_task, FORM_NAME, "on_addtoolbox_view_operat1")
  databinder:AddRolePropertyBind("CapitalType1", "int", form, FORM_NAME, "on_captial1_changed")
  databinder:AddRolePropertyBind("CapitalType2", "int", form, FORM_NAME, "on_captial2_changed")
  databinder:AddTableBind("vip_info_rec", form, FORM_NAME, "on_vip_info_rec_change")
  databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", form, FORM_NAME, "on__curjhScene_changed")
  databinder:AddRolePropertyBind("CapitalType4", "int", form, FORM_NAME, "on_captial4_changed")
  refresh_bag(form)
  if not bag_form_old_x then
    bag_form_old_x = form.Left
  end
  if not bag_form_old_y then
    bag_form_old_y = form.Top
  end
  local stall_form = util_get_form("form_stage_main\\form_stall\\form_stallmanager", false)
  if nx_is_valid(stall_form) and stall_form.Visible then
    nx_execute("form_stage_main\\form_stall\\form_stallmanager", "move_stall_form", stall_form)
  end
  nx_execute("freshman_help", "form_on_open_callback", FORM_NAME)
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  form.cbtn_lock.Checked = nx_int(player:QueryProp("CapitalGird")) == nx_int(1)
  updata_lock_image(player:QueryProp("IsHaveSecondWord"))
  databinder:AddRolePropertyBind("IsCheckPass", "int", form, nx_current(), "check_pass_callback")
  databinder:AddRolePropertyBind("IsHaveSecondWord", "int", form, nx_current(), "is_have_second_word_callback")
  local switch_manager = nx_value("SwitchManager")
  local is_open = switch_manager:CheckSwitchEnable(ST_FUNCTION_CONSIGN)
  change_switch_consign(ST_FUNCTION_CONSIGN, is_open)
end
function on_vip_info_rec_change(self, recordname, optype, row, clomn)
  if clomn == VIR_STATUS then
    on_captial1_changed(self)
    on_captial2_changed(self)
  end
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  nx_execute("freshman_help", "form_on_close_callback", FORM_NAME)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(form.imagegrid_equip)
  databinder:DelViewBind(form.imagegrid_tool)
  databinder:DelViewBind(form.imagegrid_material)
  databinder:DelViewBind(form.imagegrid_task)
  databinder:DelViewBind(form.imagegrid_equip)
  databinder:DelViewBind(form.imagegrid_tool)
  databinder:DelViewBind(form.imagegrid_material)
  databinder:DelViewBind(form.imagegrid_task)
  databinder:DelViewBind(form.addbag_equip)
  databinder:DelViewBind(form.addbag_tool)
  databinder:DelViewBind(form.addbag_material)
  databinder:DelViewBind(form.addbag_task)
  databinder:DelRolePropertyBind("CapitalType1", form)
  databinder:DelRolePropertyBind("CapitalType2", form)
  databinder:DelRolePropertyBind("IsCheckPass", form)
  databinder:DelRolePropertyBind("IsHaveSecondWord", form)
  databinder:DelRolePropertyBind("CurJHSceneConfigID", form)
  nx_execute("tips_game", "hide_tip", form)
  nx_destroy(form)
  local form_item_use = nx_value("form_stage_main\\form_itembind\\form_itembind_use")
  if nx_is_valid(form_item_use) then
    form_item_use:Close()
  end
  local form_item_equip = nx_value("form_stage_main\\form_itembind\\form_itembind_equip")
  if nx_is_valid(form_item_equip) then
    form_item_equip:Close()
  end
end
function on__curjhScene_changed(form)
  if not nx_is_valid(form) then
    return
  end
  if on_is_jh_scene() then
    form.Visible = false
  end
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) and form.Visible then
    auto_show_hide_bag()
  end
end
function on_cbtn_item_protect_checked_changed(cbtn)
  if on_is_jh_scene() then
    return
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_bag_ip")
end
function on_btn_info_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form) then
    if not form.Visible then
      form:Show()
      form.Visible = false
    end
    if on_is_jh_scene() then
      form.Visible = false
    end
  else
    form = util_get_form("form_stage_main\\form_bag", true, true)
    if nx_is_valid(form) then
      form:Show()
      form.Visible = false
    end
  end
  if on_is_jh_scene() then
    local form_bag = nx_value(FORM_NAME)
    if nx_is_valid(form_bag) then
      form_bag.Visible = false
    end
  end
  clear_select_items()
  add_select_items("all")
end
function on_is_jh_scene()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("CurJHSceneConfigID") then
    return false
  end
  local jh_scene = player:QueryProp("CurJHSceneConfigID")
  if jh_scene == nil or jh_scene == "" then
    return false
  end
  return true
end
function hide_form_bag(form)
  local gui = nx_value("gui")
  nx_execute("freshman_help", "form_on_close_callback", "form_stage_main\\form_bag")
  local is_help = nx_custom(form, "is_help")
  if is_help == nil or is_help == false then
    form.Visible = false
  else
    form.is_help = false
    form.Visible = false
    nx_execute("form_stage_main\\form_helper\\form_move_win", "util_open_move_win", form.AbsLeft, form.AbsTop, form.Width, form.Height, "", "open_form_bag,btn_bag")
  end
  nx_execute("tips_game", "hide_tip", form)
  local form_item_use = nx_value("form_stage_main\\form_itembind\\form_itembind_use")
  if nx_is_valid(form_item_use) then
    form_item_use:Close()
  end
  local form_item_equip = nx_value("form_stage_main\\form_itembind\\form_itembind_equip")
  if nx_is_valid(form_item_equip) then
    form_item_equip:Close()
  end
  clear_select_items()
  nx_execute("menu_game", "stop_glisten_bag_abduct_item")
end
function reset_form_size(form)
  if form == nil then
    form = nx_value(FORM_NAME)
  end
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cur_grid") then
    return
  end
  if not nx_is_valid(form.cur_grid) then
    return
  end
  local grid = form.cur_grid
  local bag_total_size = grid.ClomnNum * grid.RowNum
  local grid_width = grid.GridWidth
  local grid_height = grid.GridHeight
  local cols = BAG_COLS
  local rows = nx_int(bag_total_size / cols)
  if bag_total_size % cols ~= 0 then
    rows = rows + 1
  end
  local grid_offset_x = 5
  local grid_offset_y = 5
  local grid_index = 0
  local posstr = nx_string("")
  for row = 0, rows - 1 do
    for col = 0, cols - 1 do
      grid_index = grid_index + 1
      if bag_total_size < grid_index then
        break
      end
      local left = col * (grid_width + grid_offset_x) + grid_offset_x + 8 - 6
      local top = row * (grid_height + grid_offset_y) + grid_offset_x + 8 - 6
      posstr = posstr .. nx_string(left) .. "," .. nx_string(top) .. ";"
    end
  end
  grid.GridsPos = posstr
  local grid_w = cols * (grid_width + grid_offset_x) + grid_offset_x + 16 - 6
  local grid_h = rows * (grid_height + grid_offset_y) + grid_offset_x + 16 - 6
  grid.Width = grid_w
  grid.Height = grid_h
  grid.ViewRect = "0,0," .. grid_w .. "," .. grid_h
  local form_width = 4 + grid_w
  form.Width = form_width + 45
  form.groupbox_1.Width = grid_w
  form.groupbox_1.Height = grid.Top + grid_h
  form.groupbox_1.Left = (form_width - form.groupbox_1.Width) / 2 - 3
  local fix = 0
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_POINT_TO_BINDCARD) then
    fix = 30
  end
  form.groupbox_capital.Height = 62 + fix
  form.groupbox_add.Height = 212 + fix
  form.lbl_5.Height = 62 + fix
  form.groupbox_add.Width = grid_w
  form.groupbox_add.Top = form.groupbox_1.Top + form.groupbox_1.Height - 12
  form.groupbox_add.Left = form.groupbox_1.Left
  form.lbl_1.Width = grid_w - 5
  form.lbl_1.Height = form.groupbox_1.Height + 30 + 30 + 20
  form.lbl_xian3.Width = grid_w - 5
  form.lbl_xian4.Width = grid_w - 5
  form.lbl_xian4.Top = form.lbl_1.Top + form.lbl_1.Height - 5
  form.lbl_xian2.Width = grid_w - 5
  form.lbl_xian2.Top = form.lbl_xian4.Top + form.groupbox_capital.Height - 3
  form.mltbox_num.Width = form.lbl_xian4.Width
  local tmp_width = form.lbl_main1.Width
  form.lbl_3.Left = (tmp_width - form.lbl_3.Width) / 2
  form.title.Left = (tmp_width - form.title.Width) / 2 - 3
  form.lbl_main1.Width = grid_w + 4
  form.lbl_main1.Height = form.lbl_xian2.Top + form.groupbox_bnt.Height - 16
  form.groupbox_bnt.Top = form.lbl_xian2.Top + 4
  form.groupbox_bnt.Width = form.lbl_xian2.Width
  form.groupbox_capital.Top = form.groupbox_add.Height - form.groupbox_capital.Height - 40
  form.Height = form.groupbox_bnt.Top + form.groupbox_bnt.Height + 3
  form.lbl_5.Top = form.lbl_xian4.Top + 4
  form.lbl_5.Width = form.lbl_xian4.Width - 3
  form.rbtn_equip.Left = form_width - 8
  form.rbtn_tool.Left = form.rbtn_equip.Left
  form.rbtn_material.Left = form.rbtn_equip.Left
  form.rbtn_task.Left = form.rbtn_equip.Left
  form.lbl_equip.Left = form.rbtn_equip.Left
  form.lbl_tool.Left = form.rbtn_equip.Left
  form.lbl_material.Left = form.rbtn_equip.Left
  form.lbl_task.Left = form.rbtn_equip.Left
  local gui = nx_value("gui")
  if 0 > gui.Width + form.Left then
    form.Left = -1 * gui.Width
  end
end
function init_grid(grid, typeid, other_typeid)
  local b_bag = true
  if typeid == VIEWPORT_ADDTOOLBOX or typeid == VIEWPORT_EQUIP_ADDTOOLBOX or typeid == VIEWPORT_MATERIAL_ADDTOOLBOX or typeid == VIEWPORT_TASK_ADDTOOLBOX then
    b_bag = false
    local count = grid.RowNum * grid.ClomnNum
    for i = 1, count do
      grid:SetBindIndex(nx_int(i - 1), nx_int(i))
    end
    grid.main_typeid = other_typeid
    grid.addtypeid = typeid
  else
    grid.main_typeid = typeid
    grid.addtypeid = other_typeid
  end
  grid.typeid = typeid
  grid.canselect = true
  grid.candestroy = b_bag
  grid.cansplit = b_bag
  grid.canlock = b_bag
  grid.canarrange = b_bag
end
function on_view_operat(grid, optype, view_ident, index, prop_name)
  if nx_string(optype) == "updateitem" then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  local form = nx_value(FORM_NAME)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  if optype == "createview" then
    GoodsGrid:ViewRefreshGrid(grid)
  elseif optype == "deleteview" then
    GoodsGrid:ViewRefreshGrid(grid)
  elseif optype == "additem" then
    change_bag_btn(true)
    GoodsGrid:ViewUpdateItem(grid, index)
    local item = view:GetViewObj(nx_string(index))
    if nx_is_valid(item) then
      local view_id = item:QueryProp("ViewID")
      local view_type = get_bag_type_from_viewid(nx_number(view_id))
      switch_bag_type(form, view_type)
    end
    play_view_change_sound(grid, index, optype)
    refresh_item_num(form)
  elseif optype == "delitem" then
    play_view_change_sound(grid, index, optype)
    GoodsGrid:ViewDeleteItem(grid, index)
    refresh_item_num(form)
  elseif optype == "updateitemprop" then
    if nx_string(prop_name) == "LeftTime" then
      return
    end
    GoodsGrid:ViewUpdateItem(grid, index)
    play_view_change_sound(grid, index, optype)
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    local mouse_in_index = nx_number(grid:GetMouseInItemIndex())
    if -1 < mouse_in_index then
      timer:Register(100, 1, FORM_NAME, "delay_show_tips", grid, -1, -1)
    end
  end
  grid:SetSelectItemIndex(nx_int(-1))
  refresh_lock_item(form)
  refresh_addbag(form)
  goods_grid_cover_color(grid, index)
  return 1
end
function on_addtoolbox_view_operat1(grid, optype, view_ident, index)
  local form = nx_value(FORM_NAME)
  local game_client = nx_value("game_client")
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local view = game_client:GetView(nx_string(view_ident))
  local form = grid.ParentForm
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  end
  refresh_bag(form)
  return 1
end
function on_lbl_yinzi_get_capture(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local is_vip_jingxiu = nx_execute("util_vip", "is_vip", client_player, VT_JINGXIU)
  local is_vip_normal = nx_execute("util_vip", "is_vip", client_player, VT_NORMAL)
  local gui = nx_value("gui")
  local tips = nx_string("")
  if is_vip_jingxiu then
    tips = nx_string("tips_bag_zzmj_slver_1")
  elseif is_vip_normal then
    tips = nx_string("tips_bag_silver1_1")
  else
    tips = nx_string("tips_bag_silver1_0")
  end
  local todayleave = client_player:QueryProp("TodayCapitalLeave1")
  local tips_text = gui.TextManager:GetFormatText(tips, nx_int64(todayleave))
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), form.AbsLeft, form.AbsTop, 150, form.ParentForm)
end
function on_lbl_yinzi_lost_capture(form)
  nx_execute("tips_game", "hide_tip")
end
function on_lbl_yinka_get_capture(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rec_name = "consum_capital_limit"
  if not client_player:FindRecord(rec_name) then
    return
  end
  local row = client_player:FindRecordRow(rec_name, 0, CAPITAL_TYPE_SILVER_CARD, 0)
  if row < 0 then
    return
  end
  local is_vip = nx_execute("util_vip", "is_vip", client_player, VT_NORMAL)
  local is_open = false
  local mgr = nx_value("SwitchManager")
  if nx_is_valid(mgr) then
    is_open = mgr:CheckSwitchEnable(ST_FUNCTION_ACCOUNT_CREDIT)
  end
  local gui = nx_value("gui")
  local tips = ""
  local tips_text = nx_widestr("")
  if is_open then
    tips = is_vip and "tips_bag_silver2_3" or "tips_bag_silver2_2"
    local used = client_player:QueryRecord(rec_name, row, 1)
    local total = client_player:QueryRecord(rec_name, row, 3)
    if total <= 0 then
      tips = is_vip and "tips_bag_silver2_1" or "tips_bag_silver2_0"
      tips_text = util_text(tips)
      nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), form.AbsLeft, form.AbsTop, 150, form.ParentForm)
      return
    end
    local leave = math.max(total - used, 0)
    tips_text = util_format_string(tips, nx_int(total), nx_int(leave))
  else
    tips = is_vip and "tips_bag_silver2_1" or "tips_bag_silver2_0"
    tips_text = util_text(tips)
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), form.AbsLeft, form.AbsTop, 150, form.ParentForm)
end
function on_lbl_yinka_lost_capture(form)
  nx_execute("tips_game", "hide_tip")
end
function on_captial0_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local capital = client_player:QueryProp("CapitalType0")
  local ding = math.floor(capital / 10000)
  local liang = math.floor(capital % 10000 / 100)
  local wen = math.floor(capital % 100)
  local text = nx_widestr("0")
  if 0 < ding then
    text = nx_widestr(nx_int(ding))
  end
  form.lbl_0_ding.Text = text
  text = nx_widestr("0")
  if 0 < liang then
    text = nx_widestr(nx_int(liang))
  end
  form.lbl_0_liang.Text = text
  text = nx_widestr("0")
  if 0 < wen then
    text = nx_widestr(nx_int(wen))
  end
  form.lbl_0_wen.Text = text
end
function on_captial1_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local capital = client_player:QueryProp("CapitalType1")
  local ding = math.floor(capital / 1000000)
  local liang = math.floor(capital % 1000000 / 1000)
  local wen = math.floor(capital % 1000)
  local CapitalModule = nx_value("CapitalModule")
  if not nx_is_valid(CapitalModule) then
    return
  end
  local add_color = capital > CapitalModule:GetMaxValue(1)
  local gui = nx_value("gui")
  local textyZi = nx_widestr("")
  local htmlTextYinZi = nx_widestr("<center>")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      ding = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(ding)) .. nx_widestr("</font>")
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(ding) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      liang = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(liang)) .. nx_widestr("</font>")
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(liang) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      wen = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(wen)) .. nx_widestr("</font>")
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(wen) .. nx_widestr(htmlText)
  end
  if capital == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0") .. nx_widestr(htmlText)
  end
  htmlTextYinZi = htmlTextYinZi .. nx_widestr("</center>")
  form.mltbox_yinzi.HtmlText = htmlTextYinZi
end
function on_captial2_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local capital1 = client_player:QueryProp("CapitalType2")
  local ding1 = math.floor(capital1 / 1000000)
  local liang1 = math.floor(capital1 % 1000000 / 1000)
  local wen1 = math.floor(capital1 % 1000)
  local CapitalModule = nx_value("CapitalModule")
  if not nx_is_valid(CapitalModule) then
    return
  end
  local add_color = capital1 > CapitalModule:GetMaxValue(2)
  local gui = nx_value("gui")
  local htmlTextYinKa = nx_widestr("<center>")
  if 0 < ding1 then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      ding1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(ding1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(ding1) .. nx_widestr(htmlText)
  end
  if 0 < liang1 then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      liang1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(liang1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(liang1) .. nx_widestr(htmlText)
  end
  if 0 < wen1 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      wen1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(wen1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(wen1) .. nx_widestr(htmlText)
  end
  if capital1 == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr("0") .. nx_widestr(htmlText)
  end
  htmlTextYinKa = htmlTextYinKa .. nx_widestr("</center>")
  form.mltbox_yinka.HtmlText = htmlTextYinKa
end
function refresh_bag(form, default)
  if default then
    form.rbtn_equip.Checked = false
    form.rbtn_equip.Checked = true
  else
    refresh_goods_grid_index(form)
    refresh_addbag(form)
    refresh_lock_item(form)
    refresh_item_num(form)
  end
end
function refresh_goods_grid_index(form)
  if not nx_is_valid(form) then
    return false
  end
  local grid = form.cur_grid
  if not nx_is_valid(grid) then
    return false
  end
  if grid.typeid == grid.addtypeid then
    return false
  end
  local game_client = nx_value("game_client")
  local bagview = game_client:GetView(nx_string(grid.typeid))
  if not nx_is_valid(bagview) then
    grid.ClomnNum = 18
    reset_form_size(form)
    return false
  end
  local grid_count = 0
  grid_count = grid_count + bagview:QueryProp("BaseCap")
  local addbag_view
  addbag_view = game_client:GetView(nx_string(grid.addtypeid))
  if nx_is_valid(addbag_view) then
    for i = 1, 2 do
      local smallbag = addbag_view:GetViewObj(nx_string(i))
      if nx_is_valid(smallbag) then
        local beginindex = smallbag:QueryProp("BeginPos")
        local endindex = smallbag:QueryProp("EndPos")
        grid_count = grid_count + endindex - beginindex + 1
      end
    end
  end
  grid.ClomnNum = nx_int(grid_count)
  local grid_index = 0
  for view_index = 1, bagview:QueryProp("BaseCap") do
    grid:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  if nx_is_valid(addbag_view) then
    for i = 1, 2 do
      local smallbag = addbag_view:GetViewObj(nx_string(i))
      if nx_is_valid(smallbag) then
        local beginindex = smallbag:QueryProp("BeginPos")
        local endindex = smallbag:QueryProp("EndPos")
        for view_index = beginindex, endindex do
          grid:SetBindIndex(grid_index, view_index)
          grid_index = grid_index + 1
        end
      end
    end
  end
  reset_form_size(form)
  local GoodsGrid = nx_value("GoodsGrid")
  GoodsGrid:ViewRefreshGrid(grid)
  goods_grid_cover_color(grid, index)
  return true
end
function refresh_addbag(form)
  local addgrid = form.cur_addgrid
  if not nx_is_valid(addgrid) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  GoodsGrid:ViewRefreshGrid(addgrid)
  if not on_is_jh_scene() then
    local count = addgrid.RowNum * addgrid.ClomnNum
    for i = 1, count do
      check_addbag_hardiness(form.cur_grid, addgrid, i)
    end
  end
end
function refresh_lock_item(form)
  if not nx_is_valid(form) then
    return
  end
  local form_bag_logic = nx_value("form_bag_logic")
  if nx_is_valid(form_bag_logic) then
    form_bag_logic:refresh_grid_lockstatus(form.cur_grid)
    return
  end
end
function refresh_item_num(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = nx_custom(form, "cur_grid")
  if not nx_is_valid(grid) then
    return
  end
  local total_num = grid.ClomnNum * grid.RowNum
  local use_num = 0
  for i = 1, total_num do
    if not grid:IsEmpty(i - 1) then
      use_num = use_num + 1
    end
  end
  local mltbox_num = form.mltbox_num
  mltbox_num:Clear()
  mltbox_num:AddHtmlText(util_format_string("ui_bag_rl", use_num, total_num), -1)
  local width = mltbox_num:GetContentWidth()
  local left = (mltbox_num.Width - width) / 2
  mltbox_num.ViewRect = nx_string(left) .. "," .. "6" .. "," .. nx_string(mltbox_num.Width) .. "," .. nx_string(mltbox_num.Height)
end
function switch_bag_type(form, t)
  if t == EQUIP_TYPE and not form.rbtn_equip.Checked then
    form.lbl_equip.Visible = true
  elseif t == TOOL_TYPE and not form.rbtn_tool.Checked then
    form.lbl_tool.Visible = true
  elseif t == MATERIAL_TYPE and not form.rbtn_material.Checked then
    form.lbl_material.Visible = true
  elseif t == TASK_TYPE and not form.rbtn_task.Checked then
    form.lbl_task.Visible = true
  end
end
function choose_bag_type(type)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_equip.Visible = false
  form.imagegrid_tool.Visible = false
  form.imagegrid_material.Visible = false
  form.imagegrid_task.Visible = false
  form.addbag_equip.Visible = false
  form.addbag_tool.Visible = false
  form.addbag_material.Visible = false
  form.addbag_task.Visible = false
  form.imagegrid_equip:SetSelectItemIndex(nx_int(-1))
  form.imagegrid_tool:SetSelectItemIndex(nx_int(-1))
  form.imagegrid_material:SetSelectItemIndex(nx_int(-1))
  form.imagegrid_task:SetSelectItemIndex(nx_int(-1))
  form.addbag_equip:SetSelectItemIndex(nx_int(-1))
  form.addbag_tool:SetSelectItemIndex(nx_int(-1))
  form.addbag_material:SetSelectItemIndex(nx_int(-1))
  form.addbag_task:SetSelectItemIndex(nx_int(-1))
  if type == "1" then
    form.imagegrid_equip.Visible = true
    form.lbl_equip.Visible = false
    form.addbag_equip.Visible = true
    form.cur_grid = form.imagegrid_equip
    form.cur_addgrid = form.addbag_equip
  elseif type == "2" then
    form.imagegrid_tool.Visible = true
    form.lbl_tool.Visible = false
    form.addbag_tool.Visible = true
    form.cur_grid = form.imagegrid_tool
    form.cur_addgrid = form.addbag_tool
  elseif type == "3" then
    form.imagegrid_material.Visible = true
    form.lbl_material.Visible = false
    form.addbag_material.Visible = true
    form.cur_grid = form.imagegrid_material
    form.cur_addgrid = form.addbag_material
  elseif type == "4" then
    form.imagegrid_task.Visible = true
    form.lbl_task.Visible = false
    form.addbag_task.Visible = true
    form.cur_grid = form.imagegrid_task
    form.cur_addgrid = form.addbag_task
  else
    form.imagegrid_equip.Visible = true
    form.lbl_equip.Visible = false
    form.addbag_equip.Visible = true
    form.cur_grid = form.imagegrid_equip
    form.cur_addgrid = form.addbag_equip
  end
end
function check_addbag_hardiness(cur_grid, add_grid, index)
  local game_client = nx_value("game_client")
  local addbagview = game_client:GetView(nx_string(add_grid.typeid))
  local bagview = game_client:GetView(nx_string(add_grid.main_typeid))
  if not nx_is_valid(addbagview) or not nx_is_valid(bagview) then
    return 0
  end
  local view_item = addbagview:GetViewObj(nx_string(index))
  if not nx_is_valid(view_item) then
    return
  end
  local nHardiness = view_item:QueryProp("Hardiness")
  if 1 < nHardiness then
    return
  end
  local form = nx_value(FORM_NAME)
  local timer = nx_value(GAME_TIMER)
  local beginindex, endindex = nx_execute("form_stage_main\\form_bag_func", "get_addbag_range", form, index - 1)
  local count = cur_grid.RowNum * cur_grid.ClomnNum
  for i = 1, count do
    if i >= beginindex and i <= endindex then
      if nHardiness == 0 then
        cur_grid:SetItemBackImage(nx_int(i), "gui\\common\\imagegrid\\X_bag.png")
        timer:UnRegister("form_stage_main\\form_bag", "show_info", view_item)
        show_info(view_item, false)
      else
        cur_grid:SetItemBackImage(nx_int(i), "")
        if nHardiness == 1 then
          show_info(view_item, true)
          timer:UnRegister("form_stage_main\\form_bag", "show_info", view_item)
          timer:Register(600000, 5, "form_stage_main\\form_bag", "show_info", view_item, view_item, true)
        end
      end
    end
  end
end
function show_info(view_item, is_valid)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local configID = view_item:QueryProp("ConfigID")
  local bag_name = gui.TextManager:GetText(configID)
  local prex = gui.TextManager:GetText("ui_bag_nd")
  local info = nx_widestr("")
  if not is_valid then
    info = nx_widestr(prex) .. nx_widestr(bag_name) .. nx_widestr(gui.TextManager:GetText("ui_bag_sxh"))
  else
    info = nx_widestr(prex) .. nx_widestr(bag_name) .. nx_widestr(gui.TextManager:GetText("ui_bag_sxq"))
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(info, 2)
  end
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    choose_bag_type(nx_string(rbtn.DataSource))
    refresh_bag(form)
  end
end
function on_btn_set_click(btn)
end
function on_btn_arrange_click(btn)
  local form_bag = nx_value(FORM_NAME)
  nx_execute("goods_grid", "view_grid_arrange_item", form_bag.cur_grid, 1, 1024)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_hand = gui.GameHand
  if game_hand.Type == GHT_VIEWITEM then
    game_hand:ClearHand()
  end
end
function on_btn_split_click(btn)
  nx_execute("game_hand", "do_split_item")
end
function on_btn_del_equip_click(btn)
  nx_execute("game_hand", "do_destroy_item")
end
function on_btn_prop_click(btn)
  nx_execute(G_SHOP_PATH, "show_charge_shop", CHARGE_NORMAL_SHOP)
end
function on_btn_charge_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_charge_shop\\form_online_charge")
end
function on_bag_select_changed(grid, index)
  local gui = nx_value("gui")
  local gamehand = gui.GameHand
  nx_set_value("isSplit", gamehand.Para1)
  if not gamehand.IsDropped then
    nx_execute("form_stage_main\\form_bag_func", "on_bag_select_changed", grid, index)
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_bag_drag_move(grid, index, x, y)
  local gui = nx_value("gui")
  local gamehand = gui.GameHand
  if limit_drag(x, y, gamehand) then
    return
  end
  if not gamehand.IsDragged then
    gamehand.IsDragged = true
    nx_execute("form_stage_main\\form_bag_func", "on_bag_select_changed", grid, index)
  end
end
function on_bag_drag_enter(grid, index)
  local gui = nx_value("gui")
  local gamehand = gui.GameHand
  gamehand.IsDragged = false
  gamehand.IsDropped = false
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form.drag_move_x = 0
    form.drag_move_y = 0
  end
end
function on_bag_drag_leave()
end
function on_bag_drag_in(grid, index)
  local gui = nx_value("gui")
  local gamehand = gui.GameHand
  if gamehand.IsDragged and not gamehand.IsDropped then
    nx_execute("form_stage_main\\form_bag_func", "on_bag_select_changed", grid, index)
    gamehand.IsDropped = true
  end
end
function on_bag_right_click(grid, index)
  nx_execute("form_stage_main\\form_bag_func", "on_bag_right_click", grid, index)
end
function on_addbag_select_changed(grid, index)
  nx_execute("form_stage_main\\form_bag_func", "on_addbag_select_changed", grid, index)
end
function on_addbag_right_click(grid, index)
  nx_execute("form_stage_main\\form_bag_func", "on_addbag_right_click", grid, index)
end
function on_mousein_grid(grid, index)
  local form = grid.ParentForm
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local game_client = nx_value("game_client")
  local toolbox_view = game_client:GetView(nx_string(grid.typeid))
  if not nx_is_valid(toolbox_view) then
    return
  end
  local bind_index = grid:GetBindIndex(index)
  local viewobj = toolbox_view:GetViewObj(nx_string(bind_index))
  if not nx_is_valid(viewobj) then
    nx_execute("tips_game", "hide_tip", form)
    return
  end
  nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "chang_life_skill_photo", viewobj)
end
function on_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "chang_life_skill_photo", nx_null())
end
function on_imagegrid_addbag_mousein_grid(grid, index)
  local form = grid.ParentForm
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
  nx_execute("form_stage_main\\form_bag_func", "show_color_addbox", index, true)
end
function on_imagegrid_addbag_mouseout_grid(grid, index)
  local form = grid.ParentForm
  nx_execute("tips_game", "hide_tip", form)
  nx_execute("form_stage_main\\form_bag_func", "show_color_addbox", index, false)
  goods_grid_cover_color(form.cur_grid, index)
end
function clear_select_items()
  local select_items = nx_value("select_items")
  if nx_is_valid(select_items) then
    select_items:ClearChild()
  end
end
function add_select_items(view_index)
  local select_items = get_global_arraylist("select_items")
  if nx_is_valid(select_items) then
    select_items:CreateChild(nx_string(view_index))
  end
end
function goods_grid_cover_color(grid, view_index)
  local form_bag_logic = nx_value("form_bag_logic")
  if nx_is_valid(form_bag_logic) then
    form_bag_logic:refresh_grid_hardiness(grid)
    return
  end
end
function play_view_change_sound(grid, view_index, optype)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view_ident = grid.typeid
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  local select_items = nx_value("select_items")
  local is_opt_refresh = false
  if nx_is_valid(select_items) and (select_items:FindChild(nx_string(view_index)) or select_items:FindChild(nx_string("all"))) then
    is_opt_refresh = true
  end
  if is_opt_refresh == false then
    local item = view:GetViewObj(nx_string(view_index))
    nx_execute("util_sound", "play_item_sound", item)
  end
end
function get_bag_type_from_viewid(t)
  if t == 1 then
    return TOOL_TYPE
  elseif t == 2 then
    return EQUIP_TYPE
  elseif t == 3 then
    return MATERIAL_TYPE
  elseif t == 4 then
    return TASK_TYPE
  end
end
function limit_drag(move_x, move_y, gamehand)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) or not gamehand:IsEmpty() then
    return false
  end
  if not nx_find_custom(form, "drag_move_x") or not nx_find_custom(form, "drag_move_y") then
    form.drag_move_x = 0
    form.drag_move_y = 0
  end
  form.drag_move_x = form.drag_move_x + move_x
  form.drag_move_y = form.drag_move_y + move_y
  if math.abs(form.drag_move_x) < 4 and math.abs(form.drag_move_y) < 4 then
    return true
  end
  return false
end
function is_important_item(item)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return 0
  end
  if not nx_is_valid(item) then
    return 0
  end
  local configID = item:QueryProp("ConfigID")
  local script = item_query:GetItemPropByConfigID(nx_string(configID), nx_string("script"))
  local item_type = item:QueryProp("ItemType")
  local color_level = item:QueryProp("ColorLevel")
  if 4 <= nx_number(color_level) or "SkillBook" == script and ITEMTYPE_NEIGONG_BOOK == nx_number(item_type) then
    return 1
  end
  return 0
end
function on_btn_repair_get_capture(cbtn)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = gui.TextManager:GetText("tips_repairself_single")
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(text, x, y, -1, "0-0")
  end
end
function on_btn_repair_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_stall_click(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if on_is_jh_scene() then
    return
  end
  local faculty_state = client_player:QueryProp("TeamFacultyState")
  if nx_int(faculty_state) > nx_int(0) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("8034"), 2)
    end
    return
  end
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_stall\\form_stall_main")
end
function on_btn_repairall_get_capture(cbtn)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = gui.TextManager:GetText("tips_repairself_all")
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(text, x, y, -1, "0-0")
  end
end
function on_btn_repairall_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_repair_click(cbtn)
  gui = nx_value("gui")
  local photo = "gui\\common\\zhuangshi\\fix.png"
  gui.GameHand:SetHand("repair_one_byself", photo, "", "", "", "")
  local form_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if not nx_is_valid(form_info) or nx_is_valid(form_info) and not form_info.Visible then
    nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
  end
end
function on_btn_repair_checked_changed(cbtn)
  gui = nx_value("gui")
  if not cbtn.Checked then
    gui.GameHand:ClearHand()
    return
  end
  local photo = "gui\\common\\zhuangshi\\fix.png"
  gui.GameHand:SetHand("repair_one_byself", photo, "", "", "", "")
  local form_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if not nx_is_valid(form_info) or nx_is_valid(form_info) and not form_info.Visible then
    nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
  end
end
function on_btn_repairall_click(cbtn)
  nx_execute("custom_sender", "custom_send_repair_all", 0, 1, 0)
  local form_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if not nx_is_valid(form_info) or nx_is_valid(form_info) and not form_info.Visible then
    nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
  end
end
function on_cbtn_lock_checked_changed(cbtn)
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  nx_execute("custom_sender", "custom_send_open_capital", nx_int(cbtn.Checked))
end
function on_cbtn_lock_get_capture(form)
  local gui = nx_value("gui")
  local tips_text = gui.TextManager:GetFormatText(nx_string("tips_choose_pay"))
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), form.AbsLeft, form.AbsTop, 150, form.ParentForm)
end
function on_cbtn_lock_lost_capture(form)
  nx_execute("tips_game", "hide_tip")
end
function check_pass_callback(player, PropName, PropType, Value)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return 0
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local is_have_word = player:QueryProp("IsHaveSecondWord")
  if not is_have_word then
    form.btn_remove_lock.NormalImage = LOCK_IMAGE[3].normal
    form.btn_remove_lock.FocusImage = LOCK_IMAGE[3].focus
    form.btn_remove_lock.PushImage = LOCK_IMAGE[3].push
    return 0
  end
  form.btn_remove_lock.NormalImage = LOCK_IMAGE[Value + 1].normal
  form.btn_remove_lock.FocusImage = LOCK_IMAGE[Value + 1].focus
  form.btn_remove_lock.PushImage = LOCK_IMAGE[Value + 1].push
end
function is_have_second_word_callback(player, PropName, PropType, Value)
  updata_lock_image(Value)
end
function updata_lock_image(Value)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local is_have_second_word = nx_number(player:QueryProp("IsHaveSecondWord"))
  if is_have_second_word == nx_number(0) then
    local b_ok = condition_manager:CanSatisfyCondition(player, player, 23600)
    form.btn_remove_lock.Visible = b_ok
    if not b_ok then
      return
    end
  else
    form.btn_remove_lock.Visible = true
  end
  local pass_check = player:QueryProp("IsCheckPass")
  if Value == nx_number(0) then
    form.btn_remove_lock.NormalImage = LOCK_IMAGE[3].normal
    form.btn_remove_lock.FocusImage = LOCK_IMAGE[3].focus
    form.btn_remove_lock.PushImage = LOCK_IMAGE[3].push
  elseif Value == nx_number(1) and pass_check == nx_number(0) then
    form.btn_remove_lock.NormalImage = LOCK_IMAGE[1].normal
    form.btn_remove_lock.FocusImage = LOCK_IMAGE[1].focus
    form.btn_remove_lock.PushImage = LOCK_IMAGE[1].push
  elseif value == nx_number(1) and pass_check == nx_number(1) then
    form.btn_remove_lock.NormalImage = LOCK_IMAGE[2].normal
    form.btn_remove_lock.FocusImage = LOCK_IMAGE[2].focus
    form.btn_remove_lock.PushImage = LOCK_IMAGE[2].push
  end
end
function on_btn_remove_lock_click(btn)
  local form = btn.ParentForm
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local is_have_second_word = nx_number(player:QueryProp("IsHaveSecondWord"))
  if is_have_second_word == nx_number(0) then
    nx_execute("custom_sender", "request_set_second_word")
    return
  end
  local is_have_lock = nx_number(player:QueryProp("IsCheckPass"))
  if is_have_lock == SECOND_WORD_STATE_UNLOCK then
    nx_execute("custom_sender", "add_second_word_lock")
  elseif is_have_lock == SECOND_WORD_STATE_LOCK then
    nx_execute("custom_sender", "del_second_word_lock")
  end
end
function on_btn_remove_lock_get_capture(btn)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = gui.TextManager:GetText("tips_password_operate")
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(text, x, y, -1, "0-0")
  end
end
function on_btn_remove_lock_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function change_bag_btn(flag)
  local form_shortcut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form_shortcut) then
    return
  end
  local btn_bag = form_shortcut.btn_life_02
  local btn_bag_1 = form_shortcut.btn_2
  if flag then
    btn_bag.NormalImage = "bag_t"
    btn_bag.FocusImage = "bag_t"
    btn_bag.PushImage = "bag_t"
    btn_bag_1.NormalImage = "bag_t"
    btn_bag_1.FocusImage = "bag_t"
    btn_bag_1.PushImage = "bag_t"
  else
    btn_bag.NormalImage = "gui\\special\\btn_main\\btn_bag_out.png"
    btn_bag.FocusImage = "gui\\special\\btn_main\\btn_bag_on.png"
    btn_bag.PushImage = "gui\\special\\btn_main\\btn_bag_down.png"
    btn_bag_1.NormalImage = "gui\\special\\btn_main\\btn_bag_out.png"
    btn_bag_1.FocusImage = "gui\\special\\btn_main\\btn_bag_on.png"
    btn_bag_1.PushImage = "gui\\special\\btn_main\\btn_bag_down.png"
  end
end
function on_btn_goldjs_click(btn)
  nx_execute("form_stage_main\\form_consign\\form_consign", "auto_show_hide_form_consign")
end
function change_switch_consign(msg_type, is_open)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form.btn_goldjs.Visible = is_open
  end
end
function on_btn_golddh_click(btn)
  nx_execute("form_stage_main\\form_consign\\form_buy_capital", "show_hide_buy_capital_form")
end
function on_btn_webexchange_click(btn)
  local mgr = nx_value("ConditionManager")
  if not nx_is_valid(mgr) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if on_is_jh_scene() then
    return
  end
  if not mgr:CanSatisfyCondition(player, player, 17046) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("10020"))
    return
  end
  nx_execute("form_stage_main\\form_webexchange\\form_exchange_main", "open_close_webexchange")
end
function on_btn_zw_click(btn)
  local form = btn.ParentForm
  local form_bag_logic = nx_value("form_bag_logic")
  if not nx_is_valid(form_bag_logic) then
    return
  end
  if on_is_jh_scene() then
    return
  end
  if form_bag_logic:is_have_shop_mount() then
    local form_shop = nx_value("form_stage_main\\form_shop\\form_shop")
    if nx_is_valid(form_shop) then
      nx_execute("custom_sender", "custom_open_mount_shop", 0)
      form.mountshop_opt = 0
    else
      nx_execute("custom_sender", "custom_open_mount_shop", 1)
      form.mountshop_opt = 1
    end
  else
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("10247"), 2)
    end
  end
end
function on_btn_ts_click(btn)
  local form = btn.ParentForm
  local form_bag_logic = nx_value("form_bag_logic")
  if not nx_is_valid(form_bag_logic) then
    return
  end
  if on_is_jh_scene() then
    return
  end
  if form_bag_logic:is_have_shop_pawn() then
    nx_execute("form_stage_main\\form_life\\form_treasure_box", "open_form")
  else
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("10248"), 2)
    end
  end
end
function on_lbl_yinpiao_get_capture(form)
  local gui = nx_value("gui")
  local tips_text = gui.TextManager:GetFormatText(nx_string("tips_yinpiao_info"))
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), form.AbsLeft, form.AbsTop, 150, form.ParentForm)
end
function on_lbl_yinpiao_lost_capture(form)
  nx_execute("tips_game", "hide_tip")
end
function on_captial4_changed(form)
  local mgr = nx_value("CapitalModule")
  if not nx_is_valid(mgr) then
    return
  end
  local capital = mgr:GetCapital(CAPITAL_TYPE_BIND_CARD)
  local ding = math.floor(capital / 1000000)
  local liang = math.floor(capital % 1000000 / 1000)
  local wen = math.floor(capital % 1000)
  local add_color = false
  local gui = nx_value("gui")
  local textyZi = nx_widestr("")
  local htmlTextYinZi = nx_widestr("<center>")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      ding = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(ding)) .. nx_widestr("</font>")
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(ding) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      liang = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(liang)) .. nx_widestr("</font>")
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(liang) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      wen = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(wen)) .. nx_widestr("</font>")
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(wen) .. nx_widestr(htmlText)
  end
  if capital == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0") .. nx_widestr(htmlText)
  end
  htmlTextYinZi = htmlTextYinZi .. nx_widestr("</center>")
  form.mltbox_yinpiao.HtmlText = htmlTextYinZi
end
function delay_show_tips(grid)
  local mouse_in_index = nx_number(grid:GetMouseInItemIndex())
  if -1 < mouse_in_index then
    on_mousein_grid(grid, mouse_in_index)
  end
end
