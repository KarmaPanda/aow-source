require("share\\view_define")
require("define\\gamehand_type")
require("util_gui")
require("util_functions")
require("custom_sender")
require("role_composite")
require("util_static_data")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
local selectmount = ""
local select_mount_config = ""
local selectmountpage = 1
local maxpage = 1
local ALLMOUNT_FILE = "ini\\ui\\life\\allmount.ini"
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function refresh_form(form)
end
function data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddViewBind(VIEWPORT_TOOL, self, nx_current(), "on_toolbox_viewport_change")
end
function del_data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:DelViewBind(self)
end
function main_form_init(form)
  form.Fixed = true
  return 1
end
function main_form_open(form)
  form.selectmount = ""
  form.selectmountpage = 1
  form.select_grid = ""
  form.select_page = 1
  form.maxpage = 1
  local ini = nx_execute("util_functions", "get_ini", ALLMOUNT_FILE)
  local item_count = ini:GetSectionCount()
  if item_count % 6 == 0 then
    form.maxpage = nx_int(item_count / 6)
  else
    form.maxpage = nx_int(item_count / 6 + 1)
  end
  refresh_pageinfo(form)
  form.lbl_page.Text = nx_widestr(form.selectmountpage .. "/" .. form.maxpage)
  form.btn_buy.Visible = false
  form.btn_ride.Visible = false
  if selectmount == "" then
    local ImageGird = form.groupbox_mount:Find("ImageMountGrid1")
    on_ImageMountGrid_rightclick_grid(ImageGird, nx_int(0))
    if not nx_is_valid(ImageGird) then
      return
    end
    ImageGird:SetSelectItemIndex(nx_int(0))
    ImageGird.DrawMouseSelect = "xuanzekuang"
  end
  data_bind_prop(form)
  refresh_pageinfo(form)
  return 1
end
function main_form_close(form)
  del_data_bind_prop(form)
  nx_destroy(form)
  nx_set_value("form_allmount", nx_null())
end
function on_ImageMountGrid_select_changed(grid, index)
  on_ImageMountGrid_rightclick_grid(grid, index)
end
function on_ImageMountGrid_rightclick_grid(grid, index)
  local form = grid.ParentForm
  form.select_page = form.selectmountpage
  form.select_grid = grid.Name
  ClearGrid_select(form)
  grid.DrawMouseSelect = "xuanzekuang"
  local oldselect = form.selectmount
  local item_config = nx_string(grid:GetItemAddText(index, nx_int(1)))
  form.btn_buy.Visible = false
  if item_config == "" then
    return
  end
  select_mount_config = item_config
  if oldselect ~= selectmountindex then
    local form = grid.ParentForm
    refresh_showinfo(form, item_config)
  end
  local ini = nx_execute("util_functions", "get_ini", ALLMOUNT_FILE)
  local sec_index = ini:FindSectionIndex(item_config)
  if sec_index < 0 then
    return ""
  end
  local view_buy = ini:ReadString(sec_index, "Des", 0)
  if nx_int(view_buy) == nx_int(1) then
    form.btn_buy.Visible = true
  end
end
function refresh_pageinfo(form)
  local ini = nx_execute("util_functions", "get_ini", ALLMOUNT_FILE)
  local item_count = ini:GetSectionCount()
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  for i = 1, 6 do
    local GirdName = "ImageMountGrid" .. i
    local ImageGird = form.groupbox_mount:Find(GirdName)
    ImageGird:Clear()
    local index = (form.selectmountpage - 1) * 6 + i - 1
    if item_count >= index then
      local mountitem = ini:GetSectionByIndex(index)
      local photo = get_item_photo(mountitem)
      if photo ~= "" then
        local name = gui.TextManager:GetFormatText(nx_string(mountitem))
        ImageGird:AddItem(0, photo, nx_widestr("<font color=\"#ffffff\">" .. nx_string(name) .. "</font>"), 1, -1)
        ImageGird:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(mountitem))
      end
      if FindToolItemForBag(mountitem) then
        ImageGird:ChangeItemImageToBW(nx_int(0), false)
      else
        ImageGird:ChangeItemImageToBW(nx_int(0), true)
      end
    else
      ImageGird:Clear()
    end
  end
  if form.select_page == form.selectmountpage then
    local Grid_name = nx_string(form.select_grid)
    if Grid_name == "" then
      return
    end
    local Gird = form.groupbox_mount:Find(Grid_name)
    if not nx_is_valid(Gird) then
      return
    end
    Gird.DrawMouseSelect = "xuanzekuang"
  end
end
function refresh_showinfo(form, item_config)
  form.mltbox_desc:Clear()
  form.mltbox_desce:Clear()
  form.mltbox_descex:Clear()
  form.mltbox_mountdesc:Clear()
  form.mltbox_mountcost:Clear()
  form.lbl_mountname.Text = ""
  form.mltbox_mountdesc.Text = ""
  form.mltbox_mountcost.Text = ""
  form.scenebox_mountmodel.Visible = false
  local gui = nx_value("gui")
  local ini = nx_execute("util_functions", "get_ini", ALLMOUNT_FILE)
  local sec_index = ini:FindSectionIndex(item_config)
  local name = ""
  if sec_index < 0 then
    name = "mount_2_001qd"
  else
    name = gui.TextManager:GetFormatText(nx_string(ini:ReadString(sec_index, "name", "")))
  end
  local photo = get_item_photo(item_config)
  form.ImageMountGrid:AddItem(0, photo, nx_widestr("<font color=\"#ffffff\">" .. nx_string(name) .. "</font>"), 1, -1)
  form.ImageMountGrid:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(item_config))
  local ret = nx_execute("tips_func_equip", "get_item_3D_model", equip_tip, item_config)
  form.lbl_mountname.Text = nx_widestr(name)
  local SpeedQuality = get_item_info(item_config, "SpeedQuality")
  local JumpQuality = get_item_info(item_config, "JumpQuality")
  form.mltbox_desc:AddHtmlText(nx_widestr(util_text("ui_property")) .. nx_widestr(" ") .. nx_widestr(util_text("ui_ChongWuSpeed")) .. nx_widestr(SpeedQuality) .. nx_widestr(" ") .. nx_widestr(util_text("ui_JumpNengLiMH")) .. nx_widestr(JumpQuality), -1)
  local FallQuality = get_item_info(item_config, "FallQuality")
  local SwimQuality = get_item_info(item_config, "SwimQuality")
  if nx_number(SwimQuality) == 0 then
    SwimQuality = ""
  else
    SwimQuality = gui.TextManager:GetFormatText("ui_mountswim")
  end
  form.mltbox_desce:AddHtmlText(nx_widestr(util_text("ui_HuanLuoNengLiMH")) .. nx_widestr(FallQuality), -1)
  local RideSkillAll = get_item_info(item_config, "RideSkillID")
  local str_lst = util_split_string(RideSkillAll, ",")
  local skill_str = nx_widestr("")
  for i = 2, table.getn(str_lst) do
    skill_str = skill_str .. gui.TextManager:GetFormatText(nx_string(str_lst[i])) .. nx_widestr(" ")
  end
  local Text_jineng = gui.TextManager:GetFormatText("ui_jineng") .. nx_widestr(" ")
  form.mltbox_descex:AddHtmlText(Text_jineng .. nx_widestr(skill_str) .. nx_widestr(SwimQuality), -1)
  local miaoshu_str = gui.TextManager:GetFormatText("ui_task_describe")
  local info_str = nx_string("desc_" .. item_config .. "_0")
  local neirong_str = gui.TextManager:GetFormatText(info_str)
  form.mltbox_mountdesc:AddHtmlText(miaoshu_str .. nx_widestr(": ") .. neirong_str, -1)
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local main_scene = world.MainScene
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_mountmodel)
  if not nx_is_valid(form.scenebox_mountmodel.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_mountmodel)
  end
  local client_player = game_client:GetPlayer()
  local actor2 = form.scenebox_mountmodel.Scene:Create("Actor2")
  actor2.AsyncLoad = true
  actor2.mount = ""
  local itemArtPack = nx_int(get_item_info(item_config, "ArtPack"))
  if itemArtPack ~= "" then
    actor2.mount = item_static_query(itemArtPack, 0, STATIC_DATA_ITEM_ART)
    if 0 < string.len(actor2.mount) then
      load_from_ini(actor2, "ini\\" .. actor2.mount .. ".ini")
    end
  end
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(client_player) then
    return
  end
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_mountmodel, actor2)
  form.scenebox_mountmodel.Visible = true
  local scene = form.scenebox_mountmodel.Scene
  local radius = 2.1
  scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
  local dist = -0.785
  nx_execute("util_gui", "ui_RotateModel", form.scenebox_mountmodel, dist)
end
function on_ImageMountGrid_mousein_grid(grid, index)
  local item_config = nx_string(grid:GetItemAddText(index, nx_int(1)))
  if item_config == "" then
    return
  end
  local item_name = get_item_info(item_config, "Name")
  local item_type = get_item_info(item_config, "ItemType")
  local item_sellPrice1 = get_item_info(item_config, "sellPrice1")
  local photo = get_item_photo(item_config)
  local prop_array = {}
  prop_array.ConfigID = nx_string(item_config)
  prop_array.ItemType = nx_int(item_type)
  prop_array.SellPrice1 = nx_int(item_sellPrice1)
  prop_array.Photo = nx_string(photo)
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList", nx_current())
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function get_item_info(configid, prop)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
function get_item_photo(item_config)
  local file_name = "share\\Item\\tool_item.ini"
  local ini = nx_execute("util_functions", "get_ini", file_name)
  local sec_index = ini:FindSectionIndex(nx_string(item_config))
  if sec_index < 0 then
    return ""
  end
  local ArtPack = ini:ReadString(sec_index, "ArtPack", "")
  if ArtPack == "" then
    return ""
  end
  local art_file = "share\\Item\\ItemArtStatic.ini"
  local art_ini = nx_execute("util_functions", "get_ini", art_file)
  local sec_index_f = art_ini:FindSectionIndex(nx_string(ArtPack))
  if sec_index_f < 0 then
    return ""
  end
  local photo = art_ini:ReadString(sec_index_f, "Photo", "")
  return photo
end
function on_ImageMountGrid_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mouse_index = -1
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function reset_form_size(form)
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
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_mountmodel, dist)
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
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_mountmodel, dist)
  end
end
function on_btn_buy_click(btn)
  nx_execute(G_SHOP_PATH, "show_charge_shop", CHARGE_MOUNT_SHOP)
end
function on_btn_pagedown_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  ClearGrid_select(form)
  form.selectmountpage = form.selectmountpage + 1
  if form.selectmountpage > form.maxpage then
    form.selectmountpage = form.maxpage
  end
  form.lbl_page.Text = nx_widestr(form.selectmountpage .. "/" .. form.maxpage)
  refresh_pageinfo(form)
end
function on_btn_pageup_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  ClearGrid_select(form)
  form.selectmountpage = form.selectmountpage - 1
  if form.selectmountpage < 1 then
    form.selectmountpage = 1
  end
  form.lbl_page.Text = nx_widestr(form.selectmountpage .. "/" .. form.maxpage)
  refresh_pageinfo(form)
end
function FindToolItemForBag(item)
  local game_client = nx_value("game_client")
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(tool) then
    return nx_int(0)
  end
  local toolobj_list = tool:GetViewObjList()
  for j, obj in pairs(toolobj_list) do
    if nx_is_valid(obj) then
      local tempid = obj:QueryProp("ConfigID")
      if nx_ws_equal(nx_widestr(tempid), nx_widestr(item)) then
        return true
      end
    end
  end
  return false
end
function UseToolItemForBag(item)
  local game_client = nx_value("game_client")
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(tool) then
    return false
  end
  local toolobj_list = tool:GetViewObjList()
  for j, obj in pairs(toolobj_list) do
    local tempid = obj:QueryProp("ConfigID")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item)) then
      local goods_grid = nx_value("GoodsGrid")
      if not nx_is_valid(goods_grid) then
        return
      end
      goods_grid:ViewUseItem(VIEWPORT_TOOL, nx_int(obj.Ident), nx_null(), -1)
      return true
    end
  end
  return false
end
function ClearGrid_select(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 6 do
    local GirdName = nx_string("ImageMountGrid" .. i)
    local ImageGird = form.groupbox_mount:Find(GirdName)
    ImageGird.DrawMouseSelect = "RECT"
  end
end
function on_toolbox_viewport_change(form)
  if nx_is_valid(form) and form.Visible then
    refresh_pageinfo(form)
  end
end
