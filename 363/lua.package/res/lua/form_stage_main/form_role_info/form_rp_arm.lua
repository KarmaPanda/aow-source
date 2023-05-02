require("share\\view_define")
require("util_gui")
require("role_composite")
require("custom_sender")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("define\\gamehand_type")
require("define\\sysinfo_define")
require("share\\itemtype_define")
require("goods_grid")
require("tips_func_equip")
require("util_functions")
require("share\\itemtype_define")
require("util_role_prop")
local FORM_ROLE_INFO = "form_stage_main\\form_role_info\\form_role_info"
local FORM_DESC = "form_stage_main\\form_attire\\form_attire_body_desc"
local TREASURESTARTPOS = 20
function refresh_form(form)
  if nx_is_valid(form) and form.Visible then
    local GoodsGrid = nx_value("GoodsGrid")
    if nx_is_valid(GoodsGrid) then
      GoodsGrid:ViewRefreshGrid(form.equip_grid)
      local form_logic = nx_value("form_rp_arm_logic")
      if nx_is_valid(form_logic) then
        form_logic:refresh_treasure_lock(form, TREASURESTARTPOS)
      end
    end
    form.show_body = false
    on_refresh_form_info(form)
  end
end
function form_rp_arm_init(form)
  form.show_body = false
  form.Fixed = true
  form.body_actor2 = nx_null()
  form.show_equip_type = 0
end
function form_rp_arm_open(form)
  nx_set_value("form_stage_main\\form_role_info\\form_rp_arm", form)
  nx_execute("custom_sender", "custom_query_jiuyinzhi_current_step")
  form.equip_grid.typeid = VIEWPORT_EQUIP
  form.equip_grid.canselect = true
  form.equip_grid.candestroy = false
  form.equip_grid.cansplit = false
  form.equip_grid.canlock = true
  form.equip_grid.canarrange = false
  form.equip_grid.grid_class = 1
  form.new_equip_grid.typeid = VIEWPORT_EQUIP
  form.new_equip_grid.canselect = true
  form.new_equip_grid.candestroy = false
  form.new_equip_grid.cansplit = false
  form.new_equip_grid.canlock = true
  form.new_equip_grid.canarrange = false
  form.new_equip_grid.grid_class = 2
  init_bind_view_index(form)
  init_form_rp_arm_logic()
  form_rp_arm_showrole(form)
  local showequip_type = 0
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:FindProp("ShowEquipType") then
    showequip_type = client_player:QueryProp("ShowEquipType")
  end
  form.show_equip_type = showequip_type
  if showequip_type == 0 then
    form.rbtn_jianghu.Checked = true
  elseif showequip_type == 1 then
    form.rbtn_menpai.Checked = true
  elseif showequip_type == 2 then
    form.rbtn_shizhuang.Checked = true
  end
  on_show_equip_btns(form)
  form.groupbox_right.Visible = true
  form.btn_2.Visible = false
  form.btn_3.Visible = true
  form.rbtn_1.Checked = true
  form.groupbox_1.Visible = true
  form.groupbox_2.Visible = false
  form.groupbox_3.Visible = false
  form.groupbox_7.Visible = false
  form.groupbox_equip_bg.Visible = true
  form.groupbox_ani.Visible = true
  form.groupbox_treasure_bg.Visible = false
  form.rbtn_equip.Checked = true
  init_group3callback(form)
  init_group4callback(form)
  init_group7callback(form)
  form.gb_self_shan_e.Visible = false
  refresh_all_outline(form)
  local form_logic = nx_value("form_rp_arm_logic")
  if nx_is_valid(form_logic) then
    form_logic:show_self_shane_info(form)
    form_logic:refresh_treasure_lock(form, TREASURESTARTPOS)
  end
  form.newstype.Visible = false
  form.groupbox_6.Visible = false
end
function form_rp_arm_close(form)
  nx_execute("tips_game", "hide_tip", form)
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
  destroy_form_rp_arm_logic()
  form.Visible = false
  nx_destroy(form)
  nx_set_value("form_rp_arm", nx_null())
  nx_set_value("form_stage_main\\form_role_info\\form_rp_arm", nx_null())
  local form_item_equip = nx_value("form_stage_main\\form_itembind\\form_itembind_equip")
  if nx_is_valid(form_item_equip) then
    form_item_equip:Close()
  end
end
function refresh_role_scenebox()
  local form = nx_value("form_stage_main\\form_role_info\\form_rp_arm")
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(2000, 1, nx_current(), "refresh_role_scenebox_time", form, -1, -1)
  end
end
function refresh_role_scenebox_time(from)
  local form = nx_value("form_stage_main\\form_role_info\\form_rp_arm")
  if nx_is_valid(form) and form.Visible and nx_is_valid(form.role_box.Scene) and form.role_box.Visible then
    nx_execute("util_gui", "ui_ClearModel", form.role_box)
    form_rp_arm_showrole(form)
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_role_scenebox_time", from)
  end
end
function form_rp_arm_showrole(form)
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local main_scene = world.MainScene
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
  end
  local client_player = game_client:GetPlayer()
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local actor2 = role_composite:CreateSceneObjectWithSubModel(form.role_box.Scene, client_player, false, false, false)
  if not nx_is_valid(actor2) then
    return
  end
  actor2.modify_face = client_player:QueryProp("ModifyFace")
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  form.actor2 = actor2
  while role_composite:IsLoading(2, form.actor2) do
    nx_pause(0.1)
  end
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return
  end
  if not body_manager:IsNewBodyType(client_player) then
    return
  end
  local showequip_type = 0
  if client_player:FindProp("ShowEquipType") then
    showequip_type = client_player:QueryProp("ShowEquipType")
  end
  role_composite:RefreshBodyNorEquip(client_player, form.actor2, showequip_type)
end
function form_rp_arm_showbody_role(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.body_actor2) then
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
  if not nx_is_valid(form.role_newbox.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_newbox)
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local role_actor2 = role_composite:CreateSceneObjectWithSubModel(form.role_newbox.Scene, client_player, false, false, false)
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(role_actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_newbox, role_actor2)
  form.body_actor2 = role_actor2
  role_composite:PlayerVisPropChange(role_actor2, client_player, "Weapon")
  role_composite:PlayerVisPropChange(role_actor2, client_player, "ShotWeapon")
  local form_logic = nx_value("form_rp_arm_logic")
  if nx_is_valid(form_logic) then
    form_logic:ChangeActionByWeapon()
  end
end
function on_btn_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_push(btn)
  btn.MouseDown = true
  local form = btn.Parent
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
    end
  end
end
function on_btn_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_push(btn)
  btn.MouseDown = true
  local form = btn.Parent
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
    end
  end
end
function on_mount_grid_rightclick_grid(mount_grid, index)
  if not mount_grid:IsEmpty(index) then
    local view_index = mount_grid:GetBindIndex(index)
    local game_client = nx_value("game_client")
    local view_obj = game_client:GetViewObj(nx_string(mount_grid.typeid), nx_string(view_index))
    if nx_is_valid(view_obj) then
      local toolbox_id = ""
      local goods_grid = nx_value("GoodsGrid")
      if nx_is_valid(goods_grid) then
        toolbox_id = goods_grid:GetToolBoxViewport(view_obj)
        goods_grid:ViewGridPutToAnotherView(mount_grid, toolbox_id)
      end
    end
  end
end
function view_grid_on_select_item(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  if index == nil then
    index = -1
  end
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(grid, index)
end
function on_mount_grid_select_changed(mount_grid)
  local form = mount_grid.ParentForm
  form.equip_grid:SetSelectItemIndex(-1)
  local gui = nx_value("gui")
  local b_tmp = true
  if not gui.GameHand:IsEmpty() then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local goods_grid = nx_value("GoodsGrid")
    if nx_is_valid(goods_grid) and goods_grid:IsToolBoxViewport(nx_int(src_viewid)) then
      local view_index = nx_int(gui.GameHand.Para2)
      local b_need_bind = nx_execute("form_stage_main\\form_itembind\\form_itembind_manager", "equip_itemobj_need_bind", nx_int(view_index))
      if b_need_bind then
        local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_itembind\\form_itembind_equip", true)
        if nx_is_valid(form) then
          form.view_id = VIEWPORT_EQUIP
          form.item_index = tonumber(view_index)
          form.equip_grid = mount_grid
          form.src_viewid = 0
          form.AbsLeft = (gui.Width - form.Width) / 2
          form.AbsTop = (gui.Height - form.Height) / 4
          nx_execute("form_stage_main\\form_itembind\\form_itembind_equip", "set_form_showinfo")
          nx_execute("util_gui", "util_show_form", "form_stage_main\\form_itembind\\form_itembind_equip", true)
          gui.Desktop:ToFront(form)
        end
        b_tmp = false
      end
    end
  end
  if b_tmp then
    view_grid_on_select_item(mount_grid, -1)
  end
  local bag_form = util_get_form("form_stage_main\\form_bag", false)
  if not nx_is_valid(bag_form) then
    util_show_form("form_stage_main\\form_bag", true)
  end
end
function on_mount_grid_mousein_grid(mount_grid, index)
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(mount_grid, index)
  end
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, mount_grid:GetMouseInItemLeft(), mount_grid:GetMouseInItemTop(), 32, 32, mount_grid.ParentForm)
  else
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("tips_mount_pos_" .. index)
    nx_execute("tips_game", "show_text_tip", text, mount_grid:GetMouseInItemLeft(), mount_grid:GetMouseInItemTop(), 0, mount_grid.ParentForm)
  end
end
function on_mount_grid_mouseout_grid(mount_grid, index)
  local form = mount_grid.ParentForm
  form.mount_grid:SetSelectItemIndex(-1)
  nx_execute("tips_game", "hide_tip", mount_grid.ParentForm)
end
function on_equip_grid_select(equip_grid, index)
  local bind_index = nx_number(equip_grid:GetBindIndex(index))
  refresh_selected_status(equip_grid, bind_index)
  if is_repair_goods("repair_one_bynpc", equip_grid, index) then
    begin_repair(equip_grid, index, 0, 0)
    return
  end
  if is_repair_goods("repair_one_bynpc_usesilver", equip_grid, index) then
    begin_repair(equip_grid, index, 0, 1)
    return
  end
  if is_repair_goods("repair_one_byself", equip_grid, index) then
    begin_repair(equip_grid, index, 1, 0)
    return
  end
  if is_repair_goods("repair_new_byself", equip_grid, index) then
    begin_repair(equip_grid, index, 1, 0)
    return
  end
  local gui = nx_value("gui")
  local b_tmp = true
  if not gui.GameHand:IsEmpty() then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local goods_grid = nx_value("GoodsGrid")
    if nx_is_valid(goods_grid) and goods_grid:IsToolBoxViewport(nx_int(src_viewid)) then
      local view_index = nx_int(gui.GameHand.Para2)
      local b_need_bind = nx_execute("form_stage_main\\form_itembind\\form_itembind_manager", "equip_itemobj_need_bind", nx_int(view_index))
      if b_need_bind then
        local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_itembind\\form_itembind_equip", true)
        if nx_is_valid(form) then
          form.view_id = VIEWPORT_EQUIP
          form.item_index = tonumber(view_index)
          form.equip_grid = equip_grid
          form.src_viewid = 0
          form.AbsLeft = (gui.Width - form.Width) / 2
          form.AbsTop = (gui.Height - form.Height) / 2
          nx_execute("form_stage_main\\form_itembind\\form_itembind_equip", "set_form_showinfo")
          nx_execute("util_gui", "util_show_form", "form_stage_main\\form_itembind\\form_itembind_equip", true)
          gui.Desktop:ToFront(form)
        end
        b_tmp = false
      end
    end
  end
  local game_hand = gui.GameHand
  if b_tmp and not game_hand.IsDropped then
    if not game_hand:IsEmpty() then
      local gamehand_type = gui.GameHand.Type
      if gamehand_type == GHT_VIEWITEM then
        local src_viewid = nx_int(gui.GameHand.Para1)
        local src_pos = nx_int(gui.GameHand.Para2)
        if src_viewid == nx_int(VIEWPORT_EQUIP) then
          local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
          local view_index = equip_grid:GetBindIndex(index)
          if not nx_execute("goods_grid", "can_change_equip", item, view_index) then
            local info = gui.TextManager:GetText("1220")
            local SystemCenterInfo = nx_value("SystemCenterInfo")
            if nx_is_valid(SystemCenterInfo) then
              SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
            end
            game_hand:ClearHand()
            return
          end
        end
      end
    end
    view_grid_on_select_item(equip_grid, -1)
  end
  local bag_form = util_get_form("form_stage_main\\form_bag", false)
  if not nx_is_valid(bag_form) then
    util_show_form("form_stage_main\\form_bag", true)
  end
end
function is_repair_goods(repair_type, grid, index)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not gui.GameHand:IsEmpty() and gui.GameHand.Type == repair_type then
    local equipbox_view = game_client:GetView(nx_string(VIEWPORT_EQUIP))
    if nx_is_valid(equipbox_view) then
      local bind_index = grid:GetBindIndex(index)
      local viewobj = equipbox_view:GetViewObj(nx_string(bind_index))
      if nx_is_valid(viewobj) and viewobj:FindProp("MaxHardiness") then
        return true
      end
    end
  end
end
function begin_repair(grid, index, serviceman, silvertype)
  local bindindex = grid:GetBindIndex(index)
  nx_execute("custom_sender", "custom_send_repair_item", VIEWPORT_EQUIP, bindindex, 0, serviceman, silvertype)
end
function on_equip_grid_mousein(equip_grid, index)
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(equip_grid, index)
  end
  if nx_is_valid(item_data) then
    if nx_int(index) > nx_int(24) and nx_int(index) < nx_int(30) then
      local view_index = equip_grid:GetBindIndex(index)
      local game_client = nx_value("game_client")
      local view = game_client:GetView(nx_string(VIEWPORT_EQUIP))
      if nx_is_valid(view) then
        local viewobj = view:GetViewObj(nx_string(view_index))
        if nx_is_valid(viewobj) then
          item_data = viewobj
        end
      end
    end
    nx_execute("tips_game", "show_3d_tips_one", item_data, equip_grid:GetMouseInItemLeft(), equip_grid:GetMouseInItemTop(), equip_grid.ParentForm, true)
  else
    if not nx_find_custom(equip_grid, "grid_class") then
      return
    end
    local class = equip_grid.grid_class
    if class == 2 then
      index = index + 40
    end
    local text = get_grid_pos_tip(index)
    nx_execute("tips_game", "show_text_tip", text, equip_grid:GetMouseInItemLeft(), equip_grid:GetMouseInItemTop(), 0, equip_grid.ParentForm)
  end
  refresh_drawmousein(equip_grid, index)
end
function on_equip_grid_mouseout(equip_grid, index)
  nx_execute("tips_game", "hide_tip", equip_grid.ParentForm)
end
function on_equip_grid_rightclick_grid(equip_grid, index)
  if not equip_grid:IsEmpty(index) then
    local GoodsGrid = nx_value("GoodsGrid")
    if not nx_is_valid(GoodsGrid) then
      return
    end
    local dest_view_id = 0
    if on_is_jh_scene() then
      dest_view_id = VIEWPORT_NEWEQUIPTOOLBOX
    else
      dest_view_id = VIEWPORT_EQUIP_TOOL
    end
    GoodsGrid:ViewGridPutToAnotherView(equip_grid, dest_view_id)
  end
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
function on_rbtn_menpai_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.show_equip_type = 1
    nx_execute("custom_sender", "custom_showequip_type", 1)
    on_show_equip_btns(form)
  end
end
function on_rbtn_shizhuang_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.show_equip_type = 2
    nx_execute("custom_sender", "custom_showequip_type", 2)
    on_show_equip_btns(form)
  end
end
function on_rbtn_jianghu_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.show_equip_type = 0
    nx_execute("custom_sender", "custom_showequip_type", 0)
    on_show_equip_btns(form)
  end
end
function init_bind_view_index(form)
  form.equip_grid:SetBindIndex(0, 1)
  form.equip_grid:SetBindIndex(1, 2)
  form.equip_grid:SetBindIndex(2, 3)
  form.equip_grid:SetBindIndex(3, 4)
  form.equip_grid:SetBindIndex(4, 5)
  form.equip_grid:SetBindIndex(5, 6)
  form.equip_grid:SetBindIndex(6, 7)
  form.equip_grid:SetBindIndex(7, 8)
  form.equip_grid:SetBindIndex(8, 11)
  form.equip_grid:SetBindIndex(9, 12)
  form.equip_grid:SetBindIndex(10, 13)
  form.equip_grid:SetBindIndex(11, 14)
  form.equip_grid:SetBindIndex(12, 15)
  form.equip_grid:SetBindIndex(13, 16)
  form.equip_grid:SetBindIndex(14, 17)
  form.equip_grid:SetBindIndex(15, 18)
  form.equip_grid:SetBindIndex(16, 19)
  form.equip_grid:SetBindIndex(17, 22)
  form.equip_grid:SetBindIndex(18, 23)
  form.equip_grid:SetBindIndex(19, 24)
  form.equip_grid:SetBindIndex(20, 25)
  form.equip_grid:SetBindIndex(21, 26)
  form.equip_grid:SetBindIndex(22, 27)
  form.equip_grid:SetBindIndex(23, 28)
  form.equip_grid:SetBindIndex(24, 29)
  form.equip_grid:SetBindIndex(25, 30)
  form.equip_grid:SetBindIndex(26, 31)
  form.equip_grid:SetBindIndex(27, 32)
  form.equip_grid:SetBindIndex(28, 33)
  form.equip_grid:SetBindIndex(29, 34)
  form.new_equip_grid:SetBindIndex(0, 42)
  form.new_equip_grid:SetBindIndex(1, 41)
  form.new_equip_grid:SetBindIndex(2, 43)
  form.new_equip_grid:SetBindIndex(3, 40)
end
function get_grid_pos_tip(grid_index)
  local flag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
  local flag_apex = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  local text = ""
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return text
  end
  if not flag then
    text = gui.TextManager:GetText("tips_equip_pos_" .. grid_index)
  elseif not flag_apex then
    text = gui.TextManager:GetText("tips_equip_pos_" .. grid_index)
  else
    local strTip = ""
    if nx_int(grid_index) == nx_int(8) or nx_int(grid_index) == nx_int(9) or nx_int(grid_index) == nx_int(11) or nx_int(grid_index) == nx_int(12) or nx_int(grid_index) == nx_int(19) then
      strTip = "tips_taosha_equip_pos_" .. grid_index
      text = gui.TextManager:GetText(strTip)
    else
      text = gui.TextManager:GetText("tips_equip_pos_" .. grid_index)
    end
  end
  return text
end
function on_lbl_luck_get_capture(self)
  local x = self.AbsLeft + self.Width
  local y = self.AbsTop - self.Height
  local tip_text = nx_widestr(util_text("ui_luck_tips"))
  nx_execute("tips_game", "show_text_tip", tip_text, x, y)
end
function on_lbl_luck_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_2_click(self)
  local form = self.ParentForm
  local form_role_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if nx_is_valid(form_role_info) and nx_is_valid(form) and form.groupbox_right.Visible == false then
    form_role_info.Width = form_role_info.Width + form.groupbox_right.Width - form.btn_2.Width
  end
  form.groupbox_right.Visible = true
  self.Visible = false
  form.btn_3.Visible = true
end
function on_btn_3_click(self)
  local form = self.ParentForm
  local form_role_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if nx_is_valid(form_role_info) and nx_is_valid(form) and form.groupbox_right.Visible then
    form_role_info.Width = form_role_info.Width - form.groupbox_right.Width + form.btn_2.Width
  end
  form.groupbox_right.Visible = false
  self.Visible = false
  form.btn_2.Visible = true
end
function on_rbtn_checked_changed(self)
  local form = self.ParentForm
  local groupbox_name = "groupbox_" .. nx_string(self.DataSource)
  local groupbox = form.groupbox_right:Find(groupbox_name)
  if not nx_is_valid(groupbox) then
    return
  end
  groupbox.Visible = self.Checked
end
function on_btn_artequip_click(bnt)
  nx_execute("\\form_stage_main\\form_charge_shop\\form_charge_shop", "show_charge_shop", CHARGE_ARTEQUIP_SHOP)
end
function on_get_capture_ingroup3(self, form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = nx_number(client_player:QueryProp(self.prop_name))
  local value_add = nx_number(client_player:QueryProp(self.prop_name .. "Add"))
  local text
  if self.prop_name == "Str" then
    local value_all = value + value_add
    if value_all < 0 then
      value_all = 0
    end
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value_all), nx_widestr(value_all), nx_widestr(value_all * 2), nx_widestr(value_all))
  elseif self.prop_name == "Dex" then
    local value_all = value + value_add
    if value_all < 0 then
      value_all = 0
    end
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value_all), nx_widestr(value_all), nx_widestr(value_all), nx_widestr(value_all))
  elseif self.prop_name == "Ing" then
    local value_all = value + value_add
    if value_all < 0 then
      value_all = 0
    end
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value_all), nx_widestr(value_all), nx_widestr(value_all * 4))
  elseif self.prop_name == "Spi" then
    local value_all = value + value_add
    if value_all < 0 then
      value_all = 0
    end
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value_all), nx_widestr(value_all), nx_widestr(value_all), nx_widestr(value_all), nx_widestr(nx_string(string.format("%.0f", value_all * 0.2))), nx_widestr(nx_string(string.format("%.0f", value_all * 0.2))))
  elseif self.prop_name == "Sta" then
    local value_all = value + value_add
    if value_all < 0 then
      value_all = 0
    end
    local i_prop3, f_prop3 = math.modf(nx_number(value_all * 0.07))
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value_all), nx_widestr(value_all * 7), nx_widestr(value_all * 0.5), nx_widestr(i_prop3))
  elseif self.prop_name == "MaxHP" then
    local str_prop1 = get_number_str(value_add)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(str_prop1))
  elseif self.prop_name == "MaxMP" then
    local str_prop1 = get_number_str(value_add)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(str_prop1))
  elseif self.prop_name == "MaxQingGongPoint" then
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(value_add))
  elseif self.prop_name == "MaxGJQingGongPoint" then
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(value_add))
  elseif self.prop_name == "MaxEne" then
    local max_ene = nx_number(client_player:QueryProp("MaxEne"))
    local curr_sat = nx_number(client_player:QueryProp("Sat"))
    local tmp_para1 = nx_int(max_ene / 50 + 3 * (curr_sat / 10 / 10) * 1.2 * 1)
    local tmp_para2 = nx_int(client_player:QueryProp("ResumeEne"))
    if tmp_para1 > tmp_para2 then
      tmp_para1 = tmp_para2
    end
    if tmp_para1 == 0 then
      tmp_para1 = 1
    end
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(tmp_para1), nx_widestr(tmp_para2))
  elseif self.prop_name == "MaxSat" then
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(value_add))
  elseif self.prop_name == "PKValue" then
    text = gui.TextManager:GetFormatText("ui_property_PKValue")
  elseif self.prop_name == "Luck" then
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(value_add))
  elseif self.prop_name == "Dodge" then
    local para = nx_string(client_player:QueryProp("LastAttackerNpc"))
    local para_0 = gui.TextManager:GetFormatText(para)
    local para_1 = math.floor(nx_number(client_player:QueryProp("LastDodge")))
    local str_prop1 = get_number_str(para_1)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(get_number_str(value_add)))
    if para == nx_string(0) then
      text = nx_widestr(text) .. nx_widestr(gui.TextManager:GetFormatText("ui_property_" .. self.prop_name .. "Null"))
    else
      text = text .. gui.TextManager:GetFormatText("ui_property_" .. self.prop_name .. "_Add", nx_widestr(para_0), nx_widestr(str_prop1))
    end
  elseif self.prop_name == "VaDef" then
    local str_prop1 = get_number_str(value_add)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(str_prop1))
  elseif self.prop_name == "PhyDef" then
    local value_all = value + value_add
    if value_all < 0 then
      value_all = 0
    end
    local value_prop2 = get_format_value((1 - 1 / (1.0E-4 * value_all + 1)) * 100)
    local str_prop1 = get_number_str(value_add)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(str_prop1), nx_widestr(value_prop2))
  elseif self.prop_name == "PhyParryProb" then
    local prop0 = nx_number(client_player:QueryProp("PhyParryDamRes"))
    local prop1 = nx_number(client_player:QueryProp("PhyParryDamResAdd"))
    local str_prop1 = get_number_str(prop1)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(prop0), nx_widestr(str_prop1))
  elseif self.prop_name == "DrunkLevel" then
    text = gui.TextManager:GetText("ui_property_Drunk")
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 150, self.ParentForm)
end
function on_lost_capture_ingroup3(self)
  nx_execute("tips_game", "hide_tip")
end
local name = {
  "hp",
  "mp",
  "qg",
  "gjqg",
  "ene",
  "hunger",
  "PKValue",
  "luckvalue",
  "bl",
  "jm",
  "wx",
  "qh",
  "tp",
  "sb",
  "rx",
  "wgfy",
  "wgzj",
  "drunklevel"
}
local tips_name = {
  "MaxHP",
  "MaxMP",
  "MaxQingGongPoint",
  "MaxGJQingGongPoint",
  "MaxEne",
  "MaxSat",
  "PKValue",
  "Luck",
  "Str",
  "Dex",
  "Ing",
  "Spi",
  "Sta",
  "Dodge",
  "VaDef",
  "PhyDef",
  "PhyParryProb",
  "DrunkLevel"
}
function init_group3callback(form)
  for i, mark_name in ipairs(name) do
    local lbl_name = nx_string("lbl_" .. mark_name)
    local lbl = form.groupbox_1:Find(lbl_name)
    if not nx_is_valid(lbl) then
    end
    lbl.Transparent = false
    nx_bind_script(lbl, nx_current())
    nx_callback(lbl, "on_get_capture", "on_get_capture_ingroup3")
    nx_callback(lbl, "on_lost_capture", "on_lost_capture_ingroup3")
    lbl.prop_name = tips_name[i]
    local mltbox_name = nx_string("mltbox_" .. mark_name)
    local mltbox = form.groupbox_1:Find(mltbox_name)
    mltbox.Transparent = false
    nx_bind_script(mltbox, nx_current())
    nx_callback(mltbox, "on_get_capture", "on_get_capture_ingroup3")
    nx_callback(mltbox, "on_lost_capture", "on_lost_capture_ingroup3")
    mltbox.prop_name = tips_name[i]
  end
end
function on_get_capture_ingroup4(self, form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local text
  local gui = nx_value("gui")
  local value = nx_number(client_player:QueryProp(self.prop_name))
  local value_add = nx_number(client_player:QueryProp(self.prop_name .. "Add"))
  local value_all = value + value_add
  if value_all < 0 then
    value_all = 0
  end
  if self.prop_name == "MeleePower" then
    local str_prop1 = get_number_str(value_add)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(str_prop1))
  elseif self.prop_name == "PhyVa" then
    local str_prop1 = get_number_str(value_add)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(str_prop1), nx_widestr(value_all))
  elseif self.prop_name == "ShotPower" then
    local str_prop1 = get_number_str(value_add)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(str_prop1))
  elseif self.prop_name == "MagicPower" then
    local str_prop1 = get_number_str(value_add)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(str_prop1))
  elseif self.prop_name == "MagicVa" then
    local str_prop1 = get_number_str(value_add)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(str_prop1), nx_widestr(value_all), nx_widestr(value_all * 10))
  elseif self.prop_name == "StiDef" then
    local value_MagicDef = nx_number(client_player:QueryProp("MinMagicDef"))
    local value_MagicDefAdd = nx_number(client_player:QueryProp("MinMagicDefAdd"))
    local value_StiDef = nx_number(client_player:QueryProp(self.prop_name))
    local value_StiDefAdd = nx_number(client_player:QueryProp(self.prop_name .. "Add"))
    value_all = value_MagicDef + value_MagicDefAdd + value_StiDef + value_StiDefAdd
    local value_prop0 = value_MagicDefAdd + value_StiDef + value_StiDefAdd
    if value_all < 0 then
      value_prop0 = 0 - math.abs(value_MagicDef)
      value_all = 0
    end
    local str_prop1 = get_number_str(value_prop0)
    local value_prop2 = get_format_value((1 - 1 / (0.001 * value_all + 1)) * 100)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value_MagicDef), nx_widestr(str_prop1), nx_widestr(value_prop2))
  elseif self.prop_name == "NegDef" then
    local value_MagicDef = nx_number(client_player:QueryProp("MinMagicDef"))
    local value_MagicDefAdd = nx_number(client_player:QueryProp("MinMagicDefAdd"))
    local value_NegDef = nx_number(client_player:QueryProp(self.prop_name))
    local value_NegDefAdd = nx_number(client_player:QueryProp(self.prop_name .. "Add"))
    value_all = value_MagicDef + value_MagicDefAdd + value_NegDef + value_NegDefAdd
    local value_prop0 = value_MagicDefAdd + value_NegDef + value_NegDefAdd
    if value_all < 0 then
      value_prop0 = 0 - math.abs(value_MagicDef)
      value_all = 0
    end
    local str_prop1 = get_number_str(value_prop0)
    local value_prop2 = get_format_value((1 - 1 / (0.001 * value_all + 1)) * 100)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value_MagicDef), nx_widestr(str_prop1), nx_widestr(value_prop2))
  elseif self.prop_name == "JujDef" then
    local value_MagicDef = nx_number(client_player:QueryProp("MinMagicDef"))
    local value_MagicDefAdd = nx_number(client_player:QueryProp("MinMagicDefAdd"))
    local value_JujDef = nx_number(client_player:QueryProp(self.prop_name))
    local value_JujDefAdd = nx_number(client_player:QueryProp(self.prop_name .. "Add"))
    value_all = value_MagicDef + value_MagicDefAdd + value_JujDef + value_JujDefAdd
    local value_prop0 = value_MagicDefAdd + value_JujDef + value_JujDefAdd
    if value_all < 0 then
      value_prop0 = 0 - math.abs(value_MagicDef)
      value_all = 0
    end
    local str_prop1 = get_number_str(value_prop0)
    local value_prop2 = get_format_value((1 - 1 / (0.001 * value_all + 1)) * 100)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value_MagicDef), nx_widestr(str_prop1), nx_widestr(value_prop2))
  elseif self.prop_name == "MasDef" then
    local value_MagicDef = nx_number(client_player:QueryProp("MinMagicDef"))
    local value_MagicDefAdd = nx_number(client_player:QueryProp("MinMagicDefAdd"))
    local value_MasDef = nx_number(client_player:QueryProp(self.prop_name))
    local value_MasDefAdd = nx_number(client_player:QueryProp(self.prop_name .. "Add"))
    value_all = value_MagicDef + value_MagicDefAdd + value_MasDef + value_MasDefAdd
    local value_prop0 = value_MagicDefAdd + value_MasDef + value_MasDefAdd
    if value_all < 0 then
      value_prop0 = 0 - math.abs(value_MagicDef)
      value_all = 0
    end
    local str_prop1 = get_number_str(value_prop0)
    local value_prop2 = get_format_value((1 - 1 / (0.001 * value_all + 1)) * 100)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value_MagicDef), nx_widestr(str_prop1), nx_widestr(value_prop2))
  elseif self.prop_name == "PhyHit" then
    local para = nx_string(client_player:QueryProp("LastWGAttackNpc"))
    local para_0 = gui.TextManager:GetFormatText(para)
    local para_1 = math.floor(nx_number(client_player:QueryProp("LastWGHit")))
    local str_prop1 = get_number_str(para_1)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(get_number_str(value_add)))
    if para == nx_string(0) then
      text = nx_widestr(text) .. nx_widestr(gui.TextManager:GetFormatText("ui_property_" .. self.prop_name .. "Null"))
    else
      text = text .. gui.TextManager:GetFormatText("ui_property_" .. self.prop_name .. "_Add", nx_widestr(para_0), nx_widestr(str_prop1))
    end
  elseif self.prop_name == "MagicHit" then
    local para = nx_string(client_player:QueryProp("LastNGAttackNpc"))
    local para_0 = gui.TextManager:GetFormatText(para)
    local para_1 = math.floor(nx_number(client_player:QueryProp("LastNGHit")))
    local str_prop1 = get_number_str(para_1)
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name, nx_widestr(value), nx_widestr(get_number_str(value_add)))
    if para == nx_string(0) then
      text = nx_widestr(text) .. nx_widestr(gui.TextManager:GetFormatText("ui_property_" .. self.prop_name .. "Null"))
    else
      text = text .. gui.TextManager:GetFormatText("ui_property_" .. self.prop_name .. "_Add", nx_widestr(para_0), nx_widestr(str_prop1))
    end
  elseif self.prop_name == "ParryValue" then
    text = gui.TextManager:GetFormatText("ui_property_" .. self.prop_name)
  elseif self.prop_name == "MagicParryDamRes" then
    local prop0 = nx_number(client_player:QueryProp("MagicParryDamRes"))
    local prop1 = nx_number(client_player:QueryProp("MagicParryDamResAdd"))
    local str_prop1 = get_number_str(prop1)
    text = gui.TextManager:GetFormatText("ui_property_MagicParryProb", nx_widestr(prop0), nx_widestr(str_prop1))
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 150, self.ParentForm)
end
function on_lost_capture_ingroup4(self)
  nx_execute("tips_game", "hide_tip")
end
function init_group4callback(form)
  if not nx_is_valid(form) then
    return
  end
  local control_table = {
    [1] = {
      control = form.lbl_waigong_1,
      prop_name = "MeleePower"
    },
    [2] = {
      control = form.lbl_waigong_1_name,
      prop_name = "MeleePower"
    },
    [3] = {
      control = form.lbl_waigong_2,
      prop_name = "ShotPower"
    },
    [4] = {
      control = form.lbl_waigong_2_name,
      prop_name = "ShotPower"
    },
    [5] = {
      control = form.lbl_waigong_3,
      prop_name = "PhyHit"
    },
    [6] = {
      control = form.lbl_waigong_3_name,
      prop_name = "PhyHit"
    },
    [7] = {
      control = form.lbl_waigong_4,
      prop_name = "PhyVa"
    },
    [8] = {
      control = form.lbl_waigong_4_name,
      prop_name = "PhyVa"
    },
    [9] = {
      control = form.lbl_neigong_1,
      prop_name = "MagicPower"
    },
    [10] = {
      control = form.lbl_neigong_1_name,
      prop_name = "MagicPower"
    },
    [11] = {
      control = form.lbl_neigong_2,
      prop_name = "MagicHit"
    },
    [12] = {
      control = form.lbl_neigong_2_name,
      prop_name = "MagicHit"
    },
    [13] = {
      control = form.lbl_neigong_3,
      prop_name = "MagicVa"
    },
    [14] = {
      control = form.lbl_neigong_3_name,
      prop_name = "MagicVa"
    },
    [15] = {
      control = form.lbl_neigong_4,
      prop_name = "ParryValue"
    },
    [16] = {
      control = form.lbl_neigong_4_name,
      prop_name = "ParryValue"
    },
    [17] = {
      control = form.lbl_dikang_1,
      prop_name = "StiDef"
    },
    [18] = {
      control = form.lbl_dikang_1_name,
      prop_name = "StiDef"
    },
    [19] = {
      control = form.lbl_dikang_2,
      prop_name = "JujDef"
    },
    [20] = {
      control = form.lbl_dikang_2_name,
      prop_name = "JujDef"
    },
    [21] = {
      control = form.lbl_dikang_3,
      prop_name = "NegDef"
    },
    [22] = {
      control = form.lbl_dikang_3_name,
      prop_name = "NegDef"
    },
    [23] = {
      control = form.lbl_dikang_4,
      prop_name = "MasDef"
    },
    [24] = {
      control = form.lbl_dikang_4_name,
      prop_name = "MasDef"
    },
    [25] = {
      control = form.lbl_dikang_5,
      prop_name = "MagicParryDamRes"
    },
    [26] = {
      control = form.lbl_dikang_5_name,
      prop_name = "MagicParryDamRes"
    }
  }
  for i = 1, table.getn(control_table) do
    local lbl = control_table[i].control
    local prop = nx_string(control_table[i].prop_name)
    if nx_is_valid(lbl) then
      lbl.Transparent = false
      nx_bind_script(lbl, nx_current())
      nx_callback(lbl, "on_get_capture", "on_get_capture_ingroup4")
      nx_callback(lbl, "on_lost_capture", "on_lost_capture_ingroup4")
      lbl.prop_name = prop
    end
  end
end
function get_format_value(num)
  if 75 <= num then
    return 75
  end
  local tmp_i, tmp_f = math.modf(num)
  return tmp_i
end
function get_number_str(num)
  if num == nil then
    return ""
  end
  if nx_number(num) >= 0 then
    return nx_string("+" .. num)
  else
    return nx_string(num)
  end
end
function on_equip_grid_drag_enter(self, index)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  game_hand.IsDragged = false
  game_hand.IsDropped = false
end
function on_equip_grid_drag_move(self, index, x, y)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if not game_hand.IsDragged then
    game_hand.IsDragged = true
    if not game_hand:IsEmpty() then
      local gamehand_type = gui.GameHand.Type
      if gamehand_type == GHT_VIEWITEM then
        local src_viewid = nx_int(gui.GameHand.Para1)
        local src_pos = nx_int(gui.GameHand.Para2)
        if src_viewid == nx_int(VIEWPORT_EQUIP) then
          local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
          local view_index = self:GetBindIndex(index)
          if not nx_execute("goods_grid", "can_change_equip", item, view_index) then
            local info = gui.TextManager:GetText("1220")
            local SystemCenterInfo = nx_value("SystemCenterInfo")
            if nx_is_valid(SystemCenterInfo) then
              SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
            end
            game_hand:ClearHand()
            return
          end
        end
      end
    end
    view_grid_on_select_item(self, -1)
  end
end
function on_equip_grid_drag_leave(self, index)
end
function on_equip_grid_drop_in(self, index)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if game_hand.IsDragged and not game_hand.IsDropped then
    game_hand.IsDropped = true
    if not game_hand:IsEmpty() then
      local gamehand_type = gui.GameHand.Type
      if gamehand_type == GHT_VIEWITEM then
        local src_viewid = nx_int(gui.GameHand.Para1)
        local src_pos = nx_int(gui.GameHand.Para2)
        if src_viewid == nx_int(VIEWPORT_EQUIP) then
          local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
          local view_index = self:GetBindIndex(index)
          if not nx_execute("goods_grid", "can_change_equip", item, view_index) then
            local info = gui.TextManager:GetText("1220")
            local SystemCenterInfo = nx_value("SystemCenterInfo")
            if nx_is_valid(SystemCenterInfo) then
              SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
            end
            game_hand:ClearHand()
            return
          end
        end
      end
    end
    view_grid_on_select_item(self, -1)
  end
end
function on_btn_card_click(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local state = client_player:QueryProp("TeamFacultyState")
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return
  end
  if 0 < state then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("90068"), 2)
    end
  else
    local bIsNewJHModule = is_newjhmodule()
    if not bIsNewJHModule then
      local form_path = "form_stage_main\\form_attire\\form_attire_main"
      local form_attire_main = nx_value(form_path)
      if not nx_is_valid(form_attire_main) then
        form_attire_main = nx_execute("util_gui", "util_get_form", form_path, true, false)
        form_attire_main.Visible = true
        form_attire_main:Show()
      else
        form_attire_main.Visible = true
      end
      if body_manager:IsNewBodyType(client_player) then
        nx_execute("form_stage_main\\form_attire\\form_attire_main", "show_page_body")
      else
        form_attire_main.rbtn_fwz_equip.Checked = true
      end
    else
      SystemCenterInfo:ShowSystemCenterInfo(util_text("16622"), 2)
    end
  end
end
function refresh_drawmousein(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  local view_index = grid:GetBindIndex(index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(view_index))
  if nx_is_valid(viewobj) then
    local item_type = viewobj:QueryProp("ItemType")
    if nx_int(item_type) >= nx_int(ITEMTYPE_EQUIP_MIN) and nx_int(item_type) <= nx_int(ITEMTYPE_EQUIP_MAX) then
      local replace_pack = viewobj:QueryProp("ReplacePack")
      if nx_int(replace_pack) > nx_int(0) then
        grid.DrawMouseIn = nx_string("")
        return
      end
    end
  end
  grid.DrawMouseIn = nx_string("xuanzekuang_on")
end
function refresh_selected_status(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index))
  if nx_is_valid(viewobj) then
    local replace_pack = viewobj:QueryProp("ReplacePack")
    if nx_int(replace_pack) > nx_int(0) then
      grid.DrawMouseSelect = nx_string("Tab_xuanzekuang")
      return
    end
  end
  grid.DrawMouseSelect = nx_string("xuanzekuang")
end
function refresh_all_outline(form)
  form.lbl_ani_hat.Visible = false
  form.lbl_ani_cloth.Visible = false
  form.lbl_ani_pants.Visible = false
  form.lbl_ani_shoes.Visible = false
  local form_logic = nx_value("form_rp_arm_logic")
  if nx_is_valid(form_logic) then
    form_logic:refresh_blend_outline(1)
    form_logic:refresh_blend_outline(3)
    form_logic:refresh_blend_outline(4)
    form_logic:refresh_blend_outline(8)
  end
end
function on_rbtn_equip_checked_changed(btn)
  if btn.Checked == true then
    local form = btn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.equip_grid.Left = 0
    form.groupbox_equip_bg.Visible = true
    form.groupbox_ani.Visible = true
    form.groupbox_treasure_bg.Visible = false
    form.scenebox_1.BackImage = "gui\\special\\role\\bg_main.png"
  end
end
function on_rbtn_treasure_checked_changed(btn)
  if btn.Checked == true then
    local form = btn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.equip_grid.Left = -310
    form.groupbox_equip_bg.Visible = false
    form.groupbox_ani.Visible = false
    form.groupbox_treasure_bg.Visible = true
    form.scenebox_1.BackImage = "gui\\special\\role\\bg_treasure.png"
  end
end
function refresh_step(step)
  local form = nx_value("form_stage_main\\form_role_info\\form_rp_arm")
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  client_player.jyz_step = step
  local form_logic = nx_value("form_rp_arm_logic")
  if nx_is_valid(form_logic) then
    form_logic:refresh_treasure_lock(form, TREASURESTARTPOS)
  end
end
function init_form_rp_arm_logic()
  local form_logic = nx_value("form_rp_arm_logic")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_rp_arm")
  nx_set_value("form_rp_arm_logic", form_logic)
end
function destroy_form_rp_arm_logic()
  local form_logic = nx_value("form_rp_arm_logic")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
end
function on_cbtn_card_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_find_custom(cbtn, "card_id") then
    return
  end
  if nx_find_custom(cbtn, "is_system_set") and cbtn.is_system_set then
    cbtn.is_system_set = false
    return
  end
  local card_id = cbtn.card_id
  if nx_int(card_id) == nx_int(0) then
    return
  end
  local not_show = 0
  if cbtn.Checked then
    not_show = 1
  else
    not_show = 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local CLIENT_CUSTOMMSG_CARD = 180
  local CLIENT_CUSTOMMSG_CARD_IS_SHOW = 6
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CARD), nx_int(CLIENT_CUSTOMMSG_CARD_IS_SHOW), nx_int(card_id), nx_int(not_show))
end
function on_btn_new_get_capture(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not form.groupbox_right.Visible then
    on_btn_2_click(form.btn_2)
  end
  on_show_body_tips(form)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_new_lost_capture(btn)
  local form = btn.ParentForm
  form.groupbox_6.Visible = false
end
function on_btn_new_click(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return
  end
  if not body_manager:IsNewBodyType(player) then
    return
  end
  form.show_body = not form.show_body
  on_refresh_form_info(form)
end
function on_refresh_form_info(form)
  if not nx_is_valid(form) then
    return
  end
  if form.show_body == true then
    form.role_box.Visible = false
    form.groupbox_switch.Visible = false
    form.groupbox_equip_bg.Visible = false
    form.groupbox_treasure_bg.Visible = false
    form.groupbox_equip.Visible = false
    form.groupbox_ani.Visible = false
    form.newstype.Visible = true
    form_rp_arm_showbody_role(form)
    on_refresh_new_equip_grid(form)
    on_show_bodyinfo(form)
  else
    form.role_box.Visible = true
    form.groupbox_switch.Visible = true
    form.groupbox_equip_bg.Visible = true
    form.groupbox_treasure_bg.Visible = true
    form.groupbox_equip.Visible = true
    form.groupbox_ani.Visible = true
    on_rbtn_equip_checked_changed(form.rbtn_equip)
    on_rbtn_treasure_checked_changed(form.rbtn_treasure)
    local GoodsGrid = nx_value("GoodsGrid")
    if nx_is_valid(GoodsGrid) then
      GoodsGrid:ViewRefreshGrid(form.equip_grid)
    end
    form.newstype.Visible = false
    form.groupbox_6.Visible = false
  end
  local form_logic = nx_value("form_rp_arm_logic")
  if nx_is_valid(form_logic) then
    form_logic:refresh_cover_item()
  end
end
function on_btn_body_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_body_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_body_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.role_newbox, dist)
    end
  end
end
function on_btn_body_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_body_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_body_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.role_newbox, dist)
    end
  end
end
function on_refresh_new_equip_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:ViewRefreshGrid(form.new_equip_grid)
  end
end
function on_show_bodyinfo(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_6.Visible = false
  form.btn_new.Visible = false
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
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
  if not body_manager:IsNewBodyType(player) then
    return
  end
  local body_type = body_manager:GetBodyType(player)
  local body_size = body_manager:GetBodySize(player)
  body_size = math.abs(body_size)
  local table_pg = body_manager:GetCtrlPhoto(body_type, "pro")
  if table.getn(table_pg) >= 2 then
    local pro_bg = table_pg[1]
    local pro_pg = table_pg[2]
    form.pbar_2.BackImage = pro_bg
    form.pbar_2.ProgressImage = pro_pg
    form.pbar_2.Minimum = 0
    form.pbar_2.Maximum = 100
    form.pbar_2.Value = body_size
    form.pbar_2.ProgressMode = "BottomToTop"
  end
  table_pg = body_manager:GetCtrlPhoto(body_type, "btn")
  if table.getn(table_pg) >= 3 then
    local btn_out = table_pg[1]
    local btn_on = table_pg[2]
    local btn_down = table_pg[3]
    form.btn_new.NormalImage = btn_out
    form.btn_new.FocusImage = btn_on
    form.btn_new.PushImage = btn_down
    form.btn_new.Visible = true
  end
end
function on_show_body_tips(form, body_type)
  if not nx_is_valid(form) then
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
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return
  end
  local gui = nx_value("gui")
  local body_size = body_manager:GetBodySize(player)
  local sex = player:QueryProp("Sex")
  local text_juv = nx_widestr("")
  local text_maj = nx_widestr("")
  if sex == 0 then
    text_juv = gui.TextManager:GetText("ui_zhengtai")
    text_maj = gui.TextManager:GetText("ui_zhuanghan")
  else
    text_juv = gui.TextManager:GetText("ui_loli")
    text_maj = gui.TextManager:GetText("ui_yujie")
  end
  form.lbl_11.Text = text_juv
  form.lbl_8.Text = text_maj
  local abs_body_size = math.abs(body_size)
  form.lbl_size.Text = util_format_string("ui_bodysize", abs_body_size)
  form.pbar_1.Minimum = -100
  form.pbar_1.Maximum = 100
  form.pbar_1.Value = body_size
  local pbar_w = form.pbar_1.Width
  local pbar_l = form.pbar_1.Left
  if 0 < body_size then
    abs_body_size = abs_body_size + 100
  end
  local w = abs_body_size / 200 * pbar_w
  if 0 < body_size then
    form.lbl_flag.Left = pbar_l + w
  else
    form.lbl_flag.Left = pbar_l + pbar_w / 2 - w
  end
  form.groupbox_6.Visible = true
  local height = form.mltbox_1:GetContentHeight()
  local old_height = form.mltbox_1.Height
  if height > old_height then
    form.mltbox_1.Height = height + 10
    form.groupbox_6.Height = form.groupbox_6.Height + height - old_height + 10
  end
end
function on_btn_newskill_click(btn)
  util_auto_show_hide_form(FORM_DESC)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function is_body_changing()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local player = game_visual:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local body_change = false
  if nx_find_custom(player, "IsInPlayingChangeBodyAction") then
    body_change = nx_custom(player, "IsInPlayingChangeBodyAction")
  end
  return body_change
end
function on_btn_jianghu_click(btn)
  local form = btn.ParentForm
  if not is_body_changing() then
    form.rbtn_jianghu.Checked = true
  end
end
function on_btn_shizhuang_click(btn)
  local form = btn.ParentForm
  if not is_body_changing() then
    form.rbtn_shizhuang.Checked = true
  end
end
function on_btn_menpai_click(btn)
  local form = btn.ParentForm
  if not is_body_changing() then
    form.rbtn_menpai.Checked = true
  end
end
function on_show_equip_btns(form)
  if not nx_is_valid(form) then
    return
  end
  form.btn_jianghu.Visible = false
  form.btn_shizhuang.Visible = false
  form.btn_menpai.Visible = false
  if form.show_equip_type == 0 then
    form.btn_shizhuang.Visible = true
    form.btn_menpai.Visible = true
  elseif form.show_equip_type == 1 then
    form.btn_jianghu.Visible = true
    form.btn_shizhuang.Visible = true
  elseif form.show_equip_type == 2 then
    form.btn_jianghu.Visible = true
    form.btn_menpai.Visible = true
  end
end
function on_btn_yao_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_life\\form_item_fuse_bianshen")
end
local final_damage_add_name = {
  "PhyFinalDamageAdd",
  "StiFinalDamageAdd",
  "JujFinalDamageAdd",
  "NegFinalDamageAdd",
  "MasFinalDamageAdd",
  "PhyFinalDamageReduce",
  "StiFinalDamageReduce",
  "JujFinalDamageReduce",
  "NegFinalDamageReduce",
  "MasFinalDamageReduce"
}
function init_group7callback(form)
  for i, mark_name in ipairs(final_damage_add_name) do
    local lbl_name = nx_string("lbl_" .. mark_name)
    local lbl = form.groupbox_7:Find(lbl_name)
    if not nx_is_valid(lbl) then
      return
    end
    lbl.Transparent = false
    nx_bind_script(lbl, nx_current())
    nx_callback(lbl, "on_get_capture", "on_get_capture_ingroup7")
    nx_callback(lbl, "on_lost_capture", "on_lost_capture_ingroup7")
    lbl.prop_name = mark_name
    local lbl_title_name = nx_string("lbl_title_" .. mark_name)
    local lbl_title = form.groupbox_7:Find(lbl_title_name)
    if not nx_is_valid(lbl_title) then
      return
    end
    lbl_title.Transparent = false
    nx_bind_script(lbl_title, nx_current())
    nx_callback(lbl_title, "on_get_capture", "on_get_capture_ingroup7")
    nx_callback(lbl_title, "on_lost_capture", "on_lost_capture_ingroup7")
    lbl_title.prop_name = mark_name
  end
end
function on_get_capture_ingroup7(self, form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local value = nx_number(client_player:QueryProp(self.prop_name))
  local text
  text = gui.TextManager:GetFormatText("tips_property_" .. self.prop_name, nx_widestr(value), nx_widestr(nx_int(value / 10)))
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 150, self.ParentForm)
end
function on_lost_capture_ingroup7(self)
  nx_execute("tips_game", "hide_tip")
end
