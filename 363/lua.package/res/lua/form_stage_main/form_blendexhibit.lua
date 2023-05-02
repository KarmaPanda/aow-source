require("utils")
require("util_gui")
require("util_functions")
local FORM_EXHIBIT = "form_stage_main\\form_blendexhibit"
local FORM_COLLECT = "form_stage_main\\form_blendcollect"
local FORM_PREVIEW = "form_stage_main\\form_blendpreview"
local DEFAULT_HAT_PHOTO = "icon\\huanpi\\huanpi_3_1.png"
local DEFAULT_CLOTH_PHOTO = "icon\\huanpi\\huanpi_3_4.png"
local DEFAULT_PANTS_PHOTO = "icon\\huanpi\\huanpi_3_3.png"
local DEFAULT_SHOES_PHOTO = "icon\\huanpi\\huanpi_3_2.png"
local BLEND_COLLECT_REC = "blend_collect_rec"
local BLENDCOLLECT_REC_COL_CONFIGID = 0
local BLENDCOLLECT_REC_COL_OWNNUM = 1
local BLENDCOLLECT_REC_COL_USEDNUM = 2
local BLENDCOLLECT_REC_COL_ACTIVE = 3
local BLENDCOLLECT_REC_COL_COUNT = 4
local GAINWAY_MAIN = 0
local GAINWAY_MINOR = 1
local GAINWAY_BOX = 2
function on_main_form_init(form)
  form.Fixed = false
  form.nCurShowType = GAINWAY_MAIN
  form.bShowAll = true
  form.nRankType = 2
end
function on_main_form_open(form)
  on_gui_size_change()
  form.groupbox_suit.Visible = false
  UpdateFormItems(form)
  add_data_bind(form)
  local VScrollBar = form.gsb_main.VScrollBar
  VScrollBar.SmallChange = 10
  VScrollBar.LargeChange = 20
end
function on_main_form_close(form)
  del_data_bind(form)
  nx_destroy(form)
  local form_preview = nx_value(FORM_PREVIEW)
  if nx_is_valid(form_preview) then
    form_preview:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_main_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local form_preview = nx_value(FORM_PREVIEW)
    if nx_is_valid(form_preview) then
      form_preview:Close()
    end
    UpdateFormItems(form, GAINWAY_MAIN)
  end
end
function on_rbtn_minor_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local form_preview = nx_value(FORM_PREVIEW)
    if nx_is_valid(form_preview) then
      form_preview:Close()
    end
    UpdateFormItems(form, GAINWAY_MINOR)
  end
end
function on_rbtn_box_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local form_preview = nx_value(FORM_PREVIEW)
    if nx_is_valid(form_preview) then
      form_preview:Close()
    end
    UpdateFormItems(form, GAINWAY_BOX)
  end
end
function on_suit_browse_click(btn)
  local groupbox = btn.Parent
  local form = btn.ParentForm
  if not nx_find_custom(groupbox, "suit_name") then
    return
  end
  local cur_suitname = groupbox.suit_name
  local suits_table = GetCurSuitsTable(form, true)
  local count = table.getn(suits_table)
  if 0 < count then
    local index = -1
    for i = 1, count do
      local item = suits_table[i]
      if nx_string(cur_suitname) == nx_string(item.suit_name) then
        index = i
        break
      end
    end
    if index == -1 or count < index then
      return
    end
    local form_preview = nx_value(FORM_PREVIEW)
    if not nx_is_valid(form_preview) then
      form_preview = util_show_form(FORM_PREVIEW, true)
    end
    nx_execute(FORM_PREVIEW, "init_form", form_preview, index, pack_arg(suits_table))
  end
end
function on_suit_open_click(btn)
  local groupbox = btn.Parent
  local form = btn.ParentForm
  if not nx_find_custom(btn, "index") then
    return
  end
  local props = {
    "hat",
    "cloth",
    "pants",
    "shoes"
  }
  local act_props = {
    "act_hat",
    "act_cloth",
    "act_pants",
    "act_shoes"
  }
  local index = nx_number(btn.index)
  local configid = nx_string(nx_custom(groupbox, props[index]))
  local is_active = nx_boolean(nx_custom(groupbox, act_props[index]))
  if is_active then
    return
  end
  local gui = nx_value("gui")
  local title = gui.TextManager:GetText("str_tishi")
  local content = gui.TextManager:GetText("ui_blendactive_confirm")
  local res = util_form_confirm(title, content, MB_OKCANCEL, true)
  if res == "ok" then
    nx_execute("custom_sender", "custom_equipblend_active", configid)
  end
end
function on_cbtn_lookall_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    AdjustLayout(form, false)
  else
    AdjustLayout(form, true)
  end
end
function on_suit_open_get_capture(btn)
  local groupbox = btn.Parent
  local form = btn.ParentForm
  btn.Visible = true
  local configid, is_active = get_grid_data(groupbox.grid_suits, btn.index - 1)
  if nx_string(configid) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", configid, x, y, form)
end
function on_suit_open_lost_capture(btn)
  local form = btn.ParentForm
  btn.Visible = false
  nx_execute("tips_game", "hide_tip", form)
end
function on_suit_grid_mousein(grid, index)
  local groupbox = grid.Parent
  local form = grid.ParentForm
  local isopened = groupbox.isopened
  if not isopened then
    return
  end
  show_active_btn(grid, index, true)
  local configid, is_active = get_grid_data(grid, index)
  if nx_string(configid) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", configid, x, y, form)
end
function on_suit_grid_mouseout(grid, index)
  local groupbox = grid.Parent
  local form = grid.ParentForm
  local isopened = groupbox.isopened
  if not isopened then
    return
  end
  show_active_btn(grid, index, false)
  nx_execute("tips_game", "hide_tip", form)
end
function on_table_rec_changed(form, rec_name, opt_type, row, col)
  if col ~= BLENDCOLLECT_REC_COL_ACTIVE then
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
  if not client_player:FindRecord(BLEND_COLLECT_REC) then
    return
  end
  local configid = client_player:QueryRecord(BLEND_COLLECT_REC, row, BLENDCOLLECT_REC_COL_CONFIGID)
  local is_active = client_player:QueryRecord(BLEND_COLLECT_REC, row, BLENDCOLLECT_REC_COL_ACTIVE)
  RefreshItemActive(form, configid, nx_int(is_active) == nx_int(1))
end
function add_data_bind(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(BLEND_COLLECT_REC, form, nx_current(), "on_table_rec_changed")
  end
end
function del_data_bind(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(BLEND_COLLECT_REC, form)
  end
end
function pack_arg(suits_table)
  local suitlist = {}
  local count = table.getn(suits_table)
  for i = 1, count do
    local item = suits_table[i]
    table.insert(suitlist, item.suit_name)
    table.insert(suitlist, item.isopened)
    table.insert(suitlist, item.hat)
    table.insert(suitlist, item.act_hat)
    table.insert(suitlist, item.cloth)
    table.insert(suitlist, item.act_cloth)
    table.insert(suitlist, item.pants)
    table.insert(suitlist, item.act_pants)
    table.insert(suitlist, item.shoes)
    table.insert(suitlist, item.act_shoes)
  end
  return unpack(suitlist)
end
function show_active_btn(grid, index, bshow)
  local groupbox = grid.Parent
  local btn_open = nx_custom(groupbox, "btn_open" .. nx_string(index + 1))
  if not nx_is_valid(btn_open) then
    return
  end
  local _, is_active = get_grid_data(grid, index)
  if not is_active then
    btn_open.Visible = bshow
  else
    btn_open.Visible = false
  end
end
function get_grid_data(grid, index)
  if not nx_is_valid(grid) then
    return "", false
  end
  local groupbox = grid.Parent
  if nx_int(index) == nx_int(0) then
    return groupbox.hat, groupbox.act_hat
  elseif nx_int(index) == nx_int(1) then
    return groupbox.cloth, groupbox.act_cloth
  elseif nx_int(index) == nx_int(2) then
    return groupbox.pants, groupbox.act_pants
  elseif nx_int(index) == nx_int(3) then
    return groupbox.shoes, groupbox.act_shoes
  end
  return "", false
end
function get_suits_table(way)
  local suits_table = {}
  local opened_table = {}
  local closed_table = {}
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return suits_table
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return suits_table
  end
  local sex = client_player:QueryProp("Sex")
  local ini = nx_execute("util_functions", "get_ini", "share\\item\\huanpi_suits.ini")
  if not nx_is_valid(ini) then
    return suits_table
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local suit_name = ini:GetSectionByIndex(i)
    local suit_sex = ini:ReadInteger(i, "Sex", 0)
    local gain_way = ini:ReadInteger(i, "GainWay", 0)
    if nx_int(sex) == nx_int(suit_sex) and nx_int(gain_way) == nx_int(way) then
      local opened = ini:ReadInteger(i, "Opened", 0)
      local item = {}
      item.suit_name = nx_string(suit_name)
      item.isopened = nx_int(opened) == nx_int(1)
      if item.isopened then
        item.hat = nx_string(ini:ReadString(i, "Hat", ""))
        item.cloth = nx_string(ini:ReadString(i, "Cloth", ""))
        item.pants = nx_string(ini:ReadString(i, "Pants", ""))
        item.shoes = nx_string(ini:ReadString(i, "Shoes", ""))
        item.act_hat = get_item_active(item.hat)
        item.act_cloth = get_item_active(item.cloth)
        item.act_pants = get_item_active(item.pants)
        item.act_shoes = get_item_active(item.shoes)
        table.insert(opened_table, item)
      else
        item.hat = ""
        item.cloth = ""
        item.pants = ""
        item.shoes = ""
        item.act_hat = false
        item.act_cloth = false
        item.act_pants = false
        item.act_shoes = false
        table.insert(closed_table, item)
      end
    end
  end
  for i = 1, table.getn(opened_table) do
    local item = opened_table[i]
    table.insert(suits_table, item)
  end
  for i = 1, table.getn(closed_table) do
    local item = closed_table[i]
    table.insert(suits_table, item)
  end
  return suits_table
end
function get_item_active(configid)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if nx_string(configid) == nx_string("") then
    return true
  end
  if not client_player:FindRecord(BLEND_COLLECT_REC) then
    return false
  end
  local row = client_player:FindRecordRow(BLEND_COLLECT_REC, 0, nx_string(configid), 0)
  if nx_int(row) < nx_int(0) then
    return false
  end
  local active = client_player:QueryRecord(BLEND_COLLECT_REC, row, BLENDCOLLECT_REC_COL_ACTIVE)
  if active == nil then
    return false
  end
  if nx_int(active) == nx_int(1) then
    return true
  end
  return false
end
function RefreshItemActive(form, configid, is_active)
  if not nx_is_valid(form) then
    return
  end
  local child_table = form.gsb_main:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
      if nx_string(child.hat) == nx_string(configid) then
        child.act_hat = is_active
        child.grid_suits:ChangeItemImageToBW(0, not is_active)
        break
      elseif nx_string(child.cloth) == nx_string(configid) then
        child.act_cloth = is_active
        child.grid_suits:ChangeItemImageToBW(1, not is_active)
        break
      elseif nx_string(child.pants) == nx_string(configid) then
        child.act_pants = is_active
        child.grid_suits:ChangeItemImageToBW(2, not is_active)
        break
      elseif nx_string(child.shoes) == nx_string(configid) then
        child.act_shoes = is_active
        child.grid_suits:ChangeItemImageToBW(3, not is_active)
        break
      end
    end
  end
  AdjustLayout(form, form.bShowAll)
end
function UpdateFormItems(form, way, showall)
  if way == nil then
    way = form.nCurShowType
  end
  if showall == nil then
    showall = form.bShowAll
  end
  local gui = nx_value("gui")
  local suits_table = get_suits_table(way)
  local count = table.getn(suits_table)
  if count <= 0 then
    return
  end
  form.nCurShowType = way
  form.bShowAll = showall
  ClearAllChild(form.gsb_main)
  for i = 1, count do
    local item = suits_table[i]
    local control = CreateSuitItem()
    if nx_is_valid(control) then
      control.lbl_name.Text = nx_widestr(gui.TextManager:GetText(item.suit_name))
      control.btn_browse.Visible = item.isopened
      if item.isopened then
        local hat_photo = nx_execute(FORM_COLLECT, "get_photo", item.hat)
        control.grid_suits:AddItem(0, hat_photo, "", 1, -1)
        control.grid_suits:ChangeItemImageToBW(0, not item.act_hat)
        local cloth_photo = nx_execute(FORM_COLLECT, "get_photo", item.cloth)
        control.grid_suits:AddItem(1, cloth_photo, "", 1, -1)
        control.grid_suits:ChangeItemImageToBW(1, not item.act_cloth)
        local pants_photo = nx_execute(FORM_COLLECT, "get_photo", item.pants)
        control.grid_suits:AddItem(2, pants_photo, "", 1, -1)
        control.grid_suits:ChangeItemImageToBW(2, not item.act_pants)
        local shoes_photo = nx_execute(FORM_COLLECT, "get_photo", item.shoes)
        control.grid_suits:AddItem(3, shoes_photo, "", 1, -1)
        control.grid_suits:ChangeItemImageToBW(3, not item.act_shoes)
      else
        control.grid_suits:AddItem(0, DEFAULT_HAT_PHOTO, "", 1, -1)
        control.grid_suits:ChangeItemImageToBW(0, true)
        control.grid_suits:AddItem(1, DEFAULT_CLOTH_PHOTO, "", 1, -1)
        control.grid_suits:ChangeItemImageToBW(1, true)
        control.grid_suits:AddItem(2, DEFAULT_PANTS_PHOTO, "", 1, -1)
        control.grid_suits:ChangeItemImageToBW(2, true)
        control.grid_suits:AddItem(3, DEFAULT_SHOES_PHOTO, "", 1, -1)
        control.grid_suits:ChangeItemImageToBW(3, true)
      end
      control.suit_name = item.suit_name
      control.isopened = item.isopened
      control.hat = item.hat
      control.cloth = item.cloth
      control.pants = item.pants
      control.shoes = item.shoes
      control.act_hat = item.act_hat
      control.act_cloth = item.act_cloth
      control.act_pants = item.act_pants
      control.act_shoes = item.act_shoes
      form.gsb_main:Add(control)
    end
  end
  AdjustLayout(form, showall)
end
function AdjustLayout(form, showall, rank)
  if rank == nil then
    rank = form.nRankType
  end
  if not nx_is_valid(form) then
    return
  end
  form.bShowAll = showall
  local child_table = form.gsb_main:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
      if showall then
        child.Visible = true
      else
        local isopened = nx_boolean(child.isopened)
        local is_all_active = child.act_hat and child.act_cloth and child.act_pants and child.act_shoes
        if isopened and not is_all_active then
          child.Visible = true
        else
          child.Visible = false
        end
      end
    end
  end
  if nx_int(rank) == nx_int(2) then
    AdjustLayoutTwo(form.gsb_main)
  else
    AdjustLayoutOne(form.gsb_main)
  end
end
function AdjustLayoutOne(groupbox)
  if nx_is_valid(groupbox) then
    groupbox.IsEditMode = false
    groupbox:ResetChildrenYPos()
  end
end
function AdjustLayoutTwo(groupbox)
  if not nx_is_valid(groupbox) then
    return
  end
  groupbox.IsEditMode = false
  groupbox:ResetChildrenYPos()
  groupbox.IsEditMode = true
  local count = 0
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") and child.Visible then
      count = count + 1
      local real = count / 2
      if real > nx_number(nx_int(real)) then
        real = nx_int(real) + 1
        child.Left = 0
        child.Top = (real - 1) * child.Height
      else
        child.Left = child.Width
        child.Top = (real - 1) * child.Height
      end
    end
  end
  groupbox.IsEditMode = false
  local maximun = 0
  if 0 < child_count then
    local child_height = child_table[1].Height
    local rows = count / 2
    if rows > nx_number(nx_int(rows)) then
      rows = nx_int(rows) + 1
    end
    maximun = rows * child_height - groupbox.Height
    if maximun < 0 then
      maximun = 0
    end
  end
  groupbox.VScrollBar.Maximum = maximun
end
function GetCurSuitsTable(form, only_opened)
  if only_opened == nil then
    only_opened = true
  end
  local suits_table = {}
  local child_table = form.gsb_main:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") and child.Visible then
      local isopened = nx_boolean(child.isopened)
      if isopened or not isopened and only_opened then
        local item = {}
        item.suit_name = nx_string(child.suit_name)
        item.isopened = nx_boolean(child.isopened)
        item.hat = nx_string(child.hat)
        item.cloth = nx_string(child.cloth)
        item.pants = nx_string(child.pants)
        item.shoes = nx_string(child.shoes)
        item.act_hat = nx_boolean(child.act_hat)
        item.act_cloth = nx_boolean(child.act_cloth)
        item.act_pants = nx_boolean(child.act_pants)
        item.act_shoes = nx_boolean(child.act_shoes)
        table.insert(suits_table, item)
      end
    end
  end
  return suits_table
end
function ClearAllChild(groupbox)
  if not nx_is_valid(groupbox) then
    return
  end
  local gui = nx_value("gui")
  local form = groupbox.ParentForm
  local child_table = groupbox:GetChildControlList()
  local child_count = table.getn(child_table)
  if 0 < child_count then
    for i = child_count, 1, -1 do
      local child = child_table[i]
      if nx_is_valid(child) and nx_name(child) == "GroupBox" and nx_find_custom(child, "ctrltype") then
        groupbox:Remove(child)
        gui:Delete(child)
      end
    end
  end
end
function CreateSuitItem()
  local gui = nx_value("gui")
  local form = nx_value(FORM_EXHIBIT)
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_suit
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.ctrltype = "suit"
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.BackImage = tpl_item.BackImage
  item.NoFrame = tpl_item.NoFrame
  item.AutoSize = tpl_item.AutoSize
  item.DrawMode = tpl_item.DrawMode
  local tpl_name = tpl_item:Find("suit_name")
  if nx_is_valid(tpl_name) then
    local lbl_name = gui:Create("Label")
    lbl_name.Left = tpl_name.Left
    lbl_name.Top = tpl_name.Top
    lbl_name.Width = tpl_name.Width
    lbl_name.Height = tpl_name.Height
    lbl_name.ForeColor = tpl_name.ForeColor
    lbl_name.Font = tpl_name.Font
    lbl_name.Align = tpl_name.Align
    item:Add(lbl_name)
    item.lbl_name = lbl_name
  end
  local tpl_browse = tpl_item:Find("suit_browse")
  if nx_is_valid(tpl_browse) then
    local btn_browse = gui:Create("Button")
    btn_browse.Left = tpl_browse.Left
    btn_browse.Top = tpl_browse.Top
    btn_browse.Width = tpl_browse.Width
    btn_browse.Height = tpl_browse.Height
    btn_browse.Text = tpl_browse.Text
    btn_browse.Font = tpl_browse.Font
    btn_browse.ForeColor = tpl_browse.ForeColor
    btn_browse.NormalImage = tpl_browse.NormalImage
    btn_browse.FocusImage = tpl_browse.FocusImage
    btn_browse.PushImage = tpl_browse.PushImage
    btn_browse.AutoSize = tpl_browse.AutoSize
    btn_browse.DrawMode = tpl_browse.DrawMode
    nx_bind_script(btn_browse, nx_current())
    nx_callback(btn_browse, "on_click", "on_suit_browse_click")
    item:Add(btn_browse)
    item.btn_browse = btn_browse
  end
  local tpl_grid = tpl_item:Find("suit_imagegrid")
  if nx_is_valid(tpl_grid) then
    local grid = gui:Create("ImageGrid")
    grid.Top = tpl_grid.Top
    grid.Left = tpl_grid.Left
    grid.Width = tpl_grid.Width
    grid.Height = tpl_grid.Height
    grid.ForeColor = tpl_grid.ForeColor
    grid.BackColor = tpl_grid.BackColor
    grid.NoFrame = tpl_grid.NoFrame
    grid.AutoSize = tpl_grid.AutoSize
    grid.DrawMode = tpl_grid.DrawMode
    grid.ScrollSize = tpl_grid.ScrollSize
    grid.HasVScroll = tpl_grid.HasVScroll
    grid.AlwaysVScroll = tpl_grid.AlwaysVScroll
    grid.VScrollLeft = tpl_grid.VScrollLeft
    grid.DrawMouseIn = tpl_grid.DrawMouseIn
    grid.DrawGridBack = tpl_grid.DrawGridBack
    grid.GridBackOffsetX = tpl_grid.GridBackOffsetX
    grid.GridBackOffsetY = tpl_grid.GridBackOffsetY
    grid.GridCoverOffsetX = tpl_grid.GridCoverOffsetX
    grid.GridCoverOffsetY = tpl_grid.GridCoverOffsetY
    grid.SelectColor = tpl_grid.SelectColor
    grid.MouseInColor = tpl_grid.MouseInColor
    grid.CoverColor = tpl_grid.CoverColor
    grid.LockColor = tpl_grid.LockColor
    grid.ViewRect = tpl_grid.ViewRect
    grid.RowNum = tpl_grid.RowNum
    grid.ClomnNum = tpl_grid.ClomnNum
    grid.ShowEmpty = tpl_grid.ShowEmpty
    grid.Center = tpl_grid.Center
    grid.GridOffsetX = tpl_grid.GridOffsetX
    grid.GridOffsetY = tpl_grid.GridOffsetY
    grid.GridHeight = tpl_grid.GridHeight
    grid.GridWidth = tpl_grid.GridWidth
    grid.GridsPos = tpl_grid.GridsPos
    nx_bind_script(grid, nx_current())
    nx_callback(grid, "on_mousein_grid", "on_suit_grid_mousein")
    nx_callback(grid, "on_mouseout_grid", "on_suit_grid_mouseout")
    item:Add(grid)
    item.grid_suits = grid
  end
  for i = 1, 4 do
    local tpl_open = tpl_item:Find("suit_open" .. i)
    if nx_is_valid(tpl_open) then
      local btn_open = gui:Create("Button")
      btn_open.Left = tpl_open.Left
      btn_open.Top = tpl_open.Top
      btn_open.Width = tpl_open.Width
      btn_open.Height = tpl_open.Height
      btn_open.ForeColor = tpl_open.ForeColor
      btn_open.Text = tpl_open.Text
      btn_open.Font = tpl_open.Font
      btn_open.NormalImage = tpl_open.NormalImage
      btn_open.FocusImage = tpl_open.FocusImage
      btn_open.PushImage = tpl_open.PushImage
      btn_open.AutoSize = tpl_open.AutoSize
      btn_open.DrawMode = tpl_open.DrawMode
      btn_open.Visible = false
      nx_bind_script(btn_open, nx_current())
      nx_callback(btn_open, "on_click", "on_suit_open_click")
      nx_callback(btn_open, "on_get_capture", "on_suit_open_get_capture")
      nx_callback(btn_open, "on_lost_capture", "on_suit_open_lost_capture")
      btn_open.index = i
      item:Add(btn_open)
      nx_set_custom(item, "btn_open" .. i, btn_open)
    end
  end
  return item
end
function open_form()
  local form_blendcollect = nx_value(FORM_EXHIBIT)
  if nx_is_valid(form_blendcollect) then
    util_show_form(FORM_EXHIBIT, false)
  else
    util_show_form(FORM_EXHIBIT, true)
  end
end
function on_gui_size_change()
  local gui = nx_value("gui")
  local form = nx_value(FORM_EXHIBIT)
  if not nx_is_valid(form) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
