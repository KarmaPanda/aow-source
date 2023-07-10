require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\itemtype_define")
require("util_static_data")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
local g_form_name = "form_stage_main\\form_charge_shop\\form_interact_item"
local g_item = {}
local g_bBackImage = true
function on_main_form_init(self)
  self.type = 0
  self.name = ""
  self.item = ""
  self.SelectGrid = nil
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Fixed = false
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.reason_edit.Text = gui.TextManager:GetText("ui_input_interact_info")
  form.item_list = nx_call("util_gui", "get_arraylist", "charge_interact_item")
  return 1
end
function on_main_form_close(form)
  nx_destroy(form.item_list)
  nx_destroy(form)
end
function SetGridSelect(index)
  local form = nx_execute("util_gui", "util_get_form", g_form_name, true, false)
  local gbName = "GroupBox_" .. nx_string(index)
  local gb = form.groupscrollbox_daojuku:Find(gbName)
  if not nx_is_valid(gb) then
    return
  end
  local gridName = "ImgCtrlGrid_" .. nx_string(index)
  local grid = gb:Find(gridName)
  if not nx_is_valid(grid) then
    return
  end
  grid:SetSelectItemIndex(0)
  return grid
end
function CancelSelectEff()
  local form = nx_execute("util_gui", "util_get_form", g_form_name, true, false)
  for index = 0, 64 do
    local gbName = "GroupBox_" .. nx_string(index)
    local gb = form.groupscrollbox_daojuku:Find(gbName)
    if not nx_is_valid(gb) then
      return
    end
    local gridName = "ImgCtrlGrid_" .. nx_string(index)
    local grid = gb:Find(gridName)
    if not nx_is_valid(grid) then
      return
    end
    grid:SetSelectItemIndex(-1)
  end
end
function set_lable_info(grid, itemCount)
  local form = nx_execute("util_gui", "util_get_form", g_form_name, true, false)
  if form.SelectGrid == nil then
    form.lbl_info.Text = nx_widestr("")
    return
  end
  local value = grid:GetItemMark(0)
  local gui = nx_value("gui")
  if nx_int(value) > nx_int(0) then
    gui.TextManager:Format_SetIDName("ui_interact_item_add_tips")
  else
    gui.TextManager:Format_SetIDName("ui_interact_item_del_tips")
  end
  gui.TextManager:Format_AddParam(nx_widestr(grid:GetItemName(0)))
  gui.TextManager:Format_AddParam(nx_int(math.abs(value) * nx_int(itemCount)))
  form.lbl_info.Text = gui.TextManager:Format_GetText()
end
function CreateControl(index, amount)
  if math.mod(index, 2) == 1 then
    bRight = true
  else
    bRight = false
  end
  local col = nx_int(index / 2)
  local gui = nx_value("gui")
  local form = nx_execute("util_gui", "util_get_form", g_form_name, true, false)
  form.groupscrollbox_daojuku.IsEditMode = true
  local groupbox = gui:Create("GroupBox")
  form.groupscrollbox_daojuku:Add(groupbox)
  groupbox.AutoSize = false
  groupbox.Name = "GroupBox_" .. nx_string(index)
  groupbox.BackImage = "gui\\common\\form_back\\bg_sub.png"
  if bRight == true then
    groupbox.Left = 165
  else
    groupbox.Left = 10
  end
  groupbox.Top = 60 * col
  groupbox.Width = 140
  groupbox.Height = 60
  groupbox.DrawMode = "Expand"
  local label = gui:Create("Label")
  groupbox:Add(label)
  label.Left = 65
  label.Top = 30
  if g_bBackImage == false then
    label.Text = nx_widestr(util_text("ui_shenghuo0027")) .. nx_widestr(amount)
  end
  label.Name = nx_widestr("Label_") .. nx_widestr(index)
  local imagegrid = gui:Create("ImageControlGrid")
  groupbox:Add(imagegrid)
  imagegrid.AutoSize = false
  imagegrid.Name = nx_widestr("ImgCtrlGrid_") .. nx_widestr(index)
  if g_bBackImage == true then
    imagegrid.BackImage = "gui\\common\\form_back\\bg_sub.png"
  end
  imagegrid.DrawMode = "Expand"
  imagegrid.NoFrame = true
  imagegrid.HasVScroll = false
  imagegrid.Width = 50
  imagegrid.Height = 50
  imagegrid.Left = 5
  imagegrid.Top = 5
  imagegrid.RowNum = 1
  imagegrid.ClomnNum = 1
  imagegrid.GridBackOffsetX = -5
  imagegrid.GridBackOffsetY = -5
  imagegrid.GridWidth = 40
  imagegrid.GridHeight = 40
  imagegrid.GridsPos = "5,5"
  imagegrid.RoundGrid = false
  imagegrid.DrawMouseIn = "xuanzekuang"
  imagegrid.DrawMouseSelect = "xuanzekuang"
  imagegrid.BackColor = "0,0,0,0"
  imagegrid.SelectColor = "0,0,0,0"
  imagegrid.MouseInColor = "0,0,0,0"
  imagegrid.CoverColor = "0,0,0,0"
  nx_bind_script(imagegrid, nx_current(), "")
  nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
  nx_callback(imagegrid, "on_select_changed", "on_imagegrid_select_changed")
  nx_callback(imagegrid, "on_rightclick_grid", "on_imagegrid_rightclick_grid")
  imagegrid.HasMultiTextBox = true
  imagegrid.MultiTextBoxCount = 1
  imagegrid.MultiTextBox1.NoFrame = true
  imagegrid.MultiTextBox1.Width = 100
  imagegrid.MultiTextBox1.Height = 80
  imagegrid.MultiTextBox1.LineHeight = 20
  imagegrid.MultiTextBox1.ViewRect = "0,0,100,80"
  imagegrid.MultiTextBox1.TextColor = "255,95,67,37"
  imagegrid.MultiTextBox1.Font = "font_title_tasktrace"
  imagegrid.MultiTextBoxPos = "65,0"
  imagegrid.ViewRect = "0,0,34,67"
  form.groupscrollbox_daojuku.IsEditMode = false
  return imagegrid
end
function refresh_item(form, type)
  form.item_list:ClearChild()
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_list = GoodsGrid:GetItemsByItemType(ITEMTYPE_LUCK)
  local g_bLoveItem = false
  local g_bHateItem = false
  g_item = {}
  for i, item in pairs(item_list) do
    local value = nx_number(queryprop_by_object(item, "LuckValue"))
    if type == 1 and 0 < value or type == 2 and value < 0 then
      local itemid = queryprop_by_object(item, "ConfigID")
      local photo = queryprop_by_object(item, "Photo")
      local num = queryprop_by_object(item, "Amount")
      if type == 1 and 0 < value then
        g_bLoveItem = true
      end
      if type == 2 and value < 0 then
        g_bHateItem = true
      end
      if g_item[itemid] == nil then
        g_item[itemid] = {}
        g_item[itemid].amount = num
        g_item[itemid].photo = photo
        g_item[itemid].value = value
      else
        g_item[itemid].amount = g_item[itemid].amount + num
      end
    end
  end
  if type == 1 and g_bLoveItem == false or type == 2 and g_bHateItem == false then
    g_bBackImage = true
    for i = 0, 3 do
      local grid = CreateControl(nx_number(i), "")
    end
  else
    g_bBackImage = false
    local index_base = 0
    for itemid, cfg in pairs(g_item) do
      local grid = CreateControl(nx_number(index_base), cfg.amount)
      local flag_add = grid:AddItem(0, cfg.photo, nx_widestr(util_text(itemid)), nx_int(1), nx_int(cfg.value))
      grid:SetItemAddInfo(0, 1, nx_widestr(itemid))
      if flag_add then
        local item_obj = form.item_list:CreateChild(nx_string(index_base))
        item_obj.item = item
        index_base = index_base + 1
      end
    end
  end
end
function show_item_info(form, index)
  local gui = nx_value("gui")
  local gbName = "GroupBox_" .. nx_string(index)
  local gb = form.groupscrollbox_daojuku:Find(gbName)
  if not nx_is_valid(gb) then
    return
  end
  local gridName = "ImgCtrlGrid_" .. nx_string(index)
  local grid = gb:Find(gridName)
  if not nx_is_valid(grid) then
    return
  end
  local config_id = nx_string(grid:GetItemAddText(0, 1))
  if nx_string(config_id) == "" then
    return
  end
  form.item = config_id
  set_lable_info(grid, 1)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_charge_shop\\form_interact_appraise", "show_interact_appraise", form.name)
  util_show_form(g_form_name, false)
  return 1
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  local text = form.reason_edit.Text
  local checkword = nx_value("CheckWords")
  if nx_is_valid(checkword) then
    text = checkword:CleanWords(text)
  end
  if g_bBackImage == true then
    local info = util_text("85110")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 1)
    end
    return
  end
  if form.item == "" then
    return
  end
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_CHARGEITEM), nx_widestr(form.name), nx_string(form.item), nx_widestr(text), nx_int(form.edit_SelectCount.Text))
  end
  form:Close()
end
function on_btn_charge_shop_click(btn)
  local form = btn.ParentForm
  nx_execute("form_stage_main\\form_charge_shop\\form_interact_appraise", "show_interact_appraise", form.name)
  form:Close()
  nx_execute(G_SHOP_PATH, "show_charge_shop", CHARGE_INTERACTIVE_SHOP)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function show_interact_item(type, name)
  local text = ""
  if type == 1 then
    text = "ui_interact_item_friend"
  elseif type == 2 then
    text = "ui_interact_item_hate"
  end
  util_show_form(g_form_name, true)
  local form = nx_value(g_form_name)
  if nx_is_valid(form) then
    form.type = type
    form.name = name
    form.item = ""
    form.lbl_title.Text = nx_widestr(util_text("ui_interact_item")) .. nx_widestr("(") .. nx_widestr(util_text(text)) .. nx_widestr(")")
  end
  form.edit_SelectName.Text = nx_widestr(form.name)
  refresh_item(form, form.type)
  show_item_info(form, 0)
end
function on_imagegrid_mousein_grid(grid, index)
  local itemid = nx_string(grid:GetItemName(0))
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_select_changed(grid)
  CancelSelectEff()
  grid:SetSelectItemIndex(0)
  local itemid = nx_string(grid:GetItemAddText(0, 1))
  if itemid == "" or g_item[itemid] == nil then
    return
  end
  local form = grid.ParentForm
  form.SelectGrid = grid
  form.item = itemid
  form.edit_SelectName.Text = nx_widestr(form.name)
  form.edit_SelectCount.Text = nx_widestr(g_item[itemid].amount)
  set_lable_info(grid, g_item[itemid].amount)
end
function on_edit_SelectCount_changed(edit)
  local form = edit.ParentForm
  if form.SelectGrid == nil then
    edit.Text = nx_widestr(1)
    return
  end
  if form.item == "" then
    return
  end
  maxAmount = g_item[form.item].amount
  selectCount = nx_int(edit.Text)
  if selectCount > nx_int(maxAmount) then
    edit.Text = nx_widestr(maxAmount)
  end
  if nx_int(selectCount) < nx_int(1) then
    edit.Text = nx_widestr(1)
  end
  set_lable_info(form.SelectGrid, nx_int(edit.Text))
end
function on_reason_edit_get_focus(edit)
  local form = edit.ParentForm
  local gui = nx_value("gui")
  local defaultText = gui.TextManager:GetText("ui_input_interact_info")
  if edit.Text == defaultText then
    edit.Text = ""
  end
end
