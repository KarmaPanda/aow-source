require("util_gui")
require("util_functions")
require("const_define")
require("share\\view_define")
require("game_object")
require("define\\object_type_define")
local share_foods = {}
local caiyaotype = 2101
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2 * 1 / 2
  self.Top = (gui.Height - self.Height) / 4
  self.gou_huo_ini = nx_execute("util_functions", "get_ini", "share\\Force\\GouHuoDate.ini")
  if not nx_is_valid(self.gou_huo_ini) then
    return
  end
  self.share_foods = get_arraylist("form_self_share_foods")
  self.share_foods:ClearChild()
  self.get_team_foods = get_arraylist("get_team_foods")
  self.get_team_foods:ClearChild()
  self.foods_count = 0
  self.foods_index = 0
  self.key_cd = 5000
  self.lastTime = 0
  self.mltbox_1.HtmlText = nx_widestr("@ui_xjzgh_004")
end
function on_main_form_close(self)
  if nx_is_valid(self.share_foods) then
    nx_destroy(self.share_foods)
  end
  if nx_is_valid(self.get_team_foods) then
    self.get_team_foods:ClearChild()
  end
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_gou_huo_msg(...)
  if arg[1] == 0 then
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      form = util_get_form(nx_current(), true)
      if not nx_is_valid(form) then
        return
      end
    end
    form:Show()
    form.Visible = true
    form.groupbox_food_list.Visible = true
    form.groupbox_share_food.Visible = false
    form.gou_huo_level = arg[2]
    form.npc = arg[3]
    if IsInTeam() then
      nx_execute("custom_sender", "custom_xjz_gh_skill", 3, nx_object(form.npc))
    end
    local nIndex = form.gou_huo_ini:FindSectionIndex(nx_string(1))
    local str_woods = form.gou_huo_ini:ReadString(nIndex, "coust", "")
    get_item_num(str_woods, form)
  elseif arg[1] == 1 then
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    local nRows = (table.getn(arg) - 1) / 2
    for i = 1, nRows do
      local config = arg[0 + i * 2]
      local num = arg[1 + i * 2]
      local iFoodchild
      if not form.get_team_foods:FindChild(config) then
        iFoodchild = form.get_team_foods:CreateChild(config)
        nx_set_custom(iFoodchild, "id", nx_string(config))
        nx_set_custom(iFoodchild, "num", nx_int(num))
      else
        iFoodchild = form.get_team_foods:GetChild(config)
        num = num + iFoodchild.num
      end
    end
    form.foods_count = form.get_team_foods:GetChildCount()
    show_food(form)
  end
end
function on_btn_add_fire_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_1.HtmlText = nx_widestr("@ui_xjzgh_001")
  nx_execute("custom_sender", "custom_xjz_gh_skill", 1, nx_object(form.npc))
end
function on_btn_share_food_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not IsInTeam() then
    return
  end
  form.mltbox_1.HtmlText = nx_widestr("@ui_xjzgh_002")
  form.groupbox_share_food.Visible = not form.groupbox_share_food.Visible
end
function on_btn_get_food_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not IsInTeam() then
    return
  end
  form.mltbox_1.HtmlText = nx_widestr("@ui_xjzgh_003")
  form.get_team_foods:ClearChild()
  if time_is_zugou(form, btn) then
    nx_execute("custom_sender", "custom_xjz_gh_skill", 3, nx_object(form.npc))
  end
end
function time_is_zugou(form, btn)
  local now_time = os.clock()
  if form.lastTime == 0 then
    form.lastTime = now_time
    return true
  end
  local passTime = (now_time - form.lastTime) * 1000
  if passTime >= form.key_cd then
    btn.lastTime = now_time
    return true
  end
  return false
end
function get_item_num(item_id, form)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  local viewobj_list = view:GetViewObjList()
  for j, obj in pairs(viewobj_list) do
    local tempid = obj:QueryProp("ConfigID")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
    end
  end
  if nx_int(cur_amount) == nx_int(0) then
    viewobj_list = tool:GetViewObjList()
    for j, obj in pairs(viewobj_list) do
      local tempid = obj:QueryProp("ConfigID")
      if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
        cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
      end
    end
  end
  form.btn_add_fire.Visible = true
  if nx_number(cur_amount) == 0 then
    form.btn_add_fire.Enabled = false
  end
end
function show_food()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  form.ImageControlGrid2:Clear()
  local _k = 1
  for i = _k + form.foods_index, form.foods_count do
    local child = form.get_team_foods:GetChildByIndex(i - 1)
    if nx_is_valid(child) then
      local config = child.id
      local num = child.num
      local photo = ItemQuery:GetItemPropByConfigID(config, "Photo")
      form.ImageControlGrid2:AddItem(nx_int(_k - 1), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(num) .. "/" .. nx_string(1) .. "</font>"), 0, -1)
      form.ImageControlGrid2:ChangeItemImageToBW(_k - 1, false)
      form.ImageControlGrid2:SetItemAddInfo(nx_int(_k - 1), nx_int(2), nx_widestr(config))
      form.ImageControlGrid2:SetItemAddInfo(nx_int(_k - 1), nx_int(3), nx_widestr(num))
      if _k == form.ImageControlGrid2.MaxSize then
        return
      end
      _k = _k + 1
    end
  end
end
function on_ImageControlGrid1_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local selected_index = grid:GetSelectItemIndex()
  local gui = nx_value("gui")
  local src_viewid = nx_int(gui.GameHand.Para1)
  local src_pos = nx_int(gui.GameHand.Para2)
  local src_amount = nx_int(gui.GameHand.Para3)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(src_viewid))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(src_pos))
  if not nx_is_valid(viewobj) then
    return
  end
  gui.GameHand:ClearHand()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_inputbox", true, false)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  dialog:ShowModal()
  local res, num = nx_wait_event(100000000, dialog, "input_box_return")
  if res == "cancel" then
    return
  end
  if res == "ok" and src_amount < nx_int(num) then
    num = nx_int(src_amount)
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_type = viewobj:QueryProp("ItemType")
  if nx_int(item_type) ~= nx_int(caiyaotype) then
    return
  end
  local item_id = viewobj:QueryProp("ConfigID")
  local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
  form.ImageControlGrid1:AddItem(nx_int(index), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(num) .. "/" .. nx_string(1) .. "</font>"), 0, -1)
  form.ImageControlGrid1:ChangeItemImageToBW(index, false)
  form.ImageControlGrid1:SetItemAddInfo(nx_int(index), nx_int(2), nx_widestr(item_id))
  form.ImageControlGrid1:SetItemAddInfo(nx_int(index), nx_int(3), nx_widestr(num))
  local level = ItemQuery:GetItemPropByConfigID(item_id, "ColorLevel")
  local iFoodchild
  if not form.share_foods:FindChild(item_id) then
    iFoodchild = form.share_foods:CreateChild(item_id)
  else
    iFoodchild = form.share_foods:GetChild(item_id)
    num = num + iFoodchild.num
  end
  nx_set_custom(iFoodchild, "id", nx_string(item_id))
  nx_set_custom(iFoodchild, "num", nx_int(num))
  nx_set_custom(iFoodchild, "lv", nx_int(level))
end
function on_btn_share_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local nCount = form.share_foods:GetChildCount()
  if nCount == 0 then
    return
  end
  local arg = {}
  for i = 0, nCount - 1 do
    local child = form.share_foods:GetChildByIndex(i)
    if nx_is_valid(child) then
      local item_id = nx_string(child.id)
      local num = nx_int(child.num)
      local level = nx_int(child.lv)
      if 0 < nx_number(num) then
        arg[i * 3 + 1] = num
        arg[i * 3 + 2] = item_id
        arg[i * 3 + 3] = level
      end
    end
  end
  if 0 < table.getn(arg) then
    nx_execute("custom_sender", "custom_xjz_gh_skill", 2, nx_object(form.npc), unpack(arg))
  end
  form.ImageControlGrid1:Clear()
  form.share_foods:ClearChild()
  form.groupbox_share_food.Visible = false
end
function on_ImageControlGrid2_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(2))
  nx_execute("custom_sender", "custom_xjz_gh_skill", 4, nx_object(form.npc), nx_string(item_config))
end
function IsInTeam()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local teamid = client_player:QueryProp("TeamID")
  if teamid == 0 then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(util_text("is_not_in_team")), 2)
    end
    return false
  end
  return true
end
function on_btn_5_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.foods_index + form.ImageControlGrid2.MaxSize < form.foods_count then
    form.foods_index = form.foods_index + 1
    show_food(form)
  end
end
function on_btn_6_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.foods_index > 0 then
    form.foods_index = form.foods_index - 1
    show_food(form)
  end
end
function on_ImageControlGrid1_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local item_id = grid:GetItemAddText(nx_int(index), nx_int(2))
  local child = form.share_foods:GetChild(nx_string(item_id))
  if not nx_is_valid(child) then
    return
  end
  local num = grid:GetItemAddText(nx_int(index), nx_int(3))
  local new_num = child.num - nx_int(num)
  if new_num < 0 then
    return
  end
  nx_set_custom(child, "num", nx_int(new_num))
  grid:DelItem(index)
end
function showitemtips(grid, item_config)
  if nx_string(item_config) == nx_string("") or nx_string(item_config) == nx_string("nil") then
    return
  end
  local item_name, item_type
  local ItemQuery = nx_value("ItemQuery")
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(ItemQuery) or not nx_is_valid(IniManager) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if nx_string(bExist) == nx_string("true") then
    item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
    item_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Level"))
    local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
    local prop_array = {}
    prop_array.ConfigID = nx_string(item_config)
    prop_array.ItemType = nx_int(item_type)
    prop_array.Level = nx_int(item_level)
    prop_array.SellPrice1 = nx_int(item_sellPrice1)
    prop_array.Photo = nx_string(photo)
    prop_array.is_static = true
    if not nx_is_valid(grid.Data) then
      grid.Data = nx_create("ArrayList")
    end
    grid.Data:ClearChild()
    for prop, value in pairs(prop_array) do
      nx_set_custom(grid.Data, prop, value)
    end
    nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_Img_mousein_by_ConfigID_grid(grid, index)
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(2))
  showitemtips(grid, item_config)
end
function on_mouse_out(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
