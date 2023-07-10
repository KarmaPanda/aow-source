require("util_static_data")
require("util_functions")
require("util_gui")
local COLNUM = 6
local PRICE = 5000
local FORM_PATH = "form_stage_main\\form_attire\\form_attire_save"
function get_text(msg)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText(msg)
  return text
end
function on_main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.groupbox_2.Left = (form.Width - form.groupbox_2.Width) / 2
  form.groupbox_2.Top = (form.Height - form.groupbox_2.Height) / 2
  form.cbtn_usemoney.Checked = true
  local textgrid = form.textgrid_1
  local title = {
    "ui_attire_save_3",
    "ui_attire_save_4",
    "ui_attire_save_5",
    "ui_attire_save_6"
  }
  for i = 2, COLNUM - 1 do
    local text = get_text(nx_string(title[i - 1]))
    textgrid:SetColTitle(i, nx_widestr(text))
  end
end
function on_main_form_close(form)
  form.textgrid_1:ClearRow()
  nx_destroy(form)
end
function on_cbtn_useitem_checked_changed(cbtn)
  if cbtn.Checked then
    local form = cbtn.ParentForm
    if nx_is_valid(form) then
    end
  end
end
function on_cbtn_usemoney_checked_changed(cbtn)
  if cbtn.Checked then
    local form = cbtn.ParentForm
    if nx_is_valid(form) then
    end
  end
end
function refresh_grid_data(form1, form2)
  if not nx_is_valid(form1) then
    return
  end
  if not nx_is_valid(form2) then
    return
  end
  local equip_grid = form1.imagegrid_equip
  local draw_grid = form1.imagegrid_draw_item
  local text_grid = form2.textgrid_1
  local valid_num = 0
  text_grid:BeginUpdate()
  text_grid:ClearRow()
  for index = 0, COLNUM - 3 do
    if not equip_grid:IsEmpty(index) then
      local item_name1 = nx_string(equip_grid:GetItemName(index))
      local item_name2 = nx_string(draw_grid:GetItemName(index))
      if item_name2 ~= "" then
        local row = text_grid:InsertRow(-1)
        create_grid_cbtn(text_grid, item_name1, item_name2, row)
        create_grid_imagegrid(text_grid, item_name2, row)
        create_grid_mltbox(text_grid, row)
        if set_grid_text(text_grid, item_name2, row) == true then
          valid_num = valid_num + 1
        end
      end
    end
  end
  text_grid:EndUpdate()
  form2.btn_2.Enabled = false
  if nx_int(valid_num) == nx_int(0) then
    form2.cbtn_1.Enabled = false
  else
    form2.cbtn_1.Enabled = true
  end
end
function change_form_size()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
  form.Left = 0
  form.Top = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.groupbox_2.Left = (form.Width - form.groupbox_2.Width) / 2
  form.groupbox_2.Top = (form.Height - form.groupbox_2.Height) / 2
end
function create_grid_cbtn(grid, grid_data1, grid_data2, index)
  if not nx_is_valid(grid) then
    return
  end
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  if nx_is_valid(groupbox) then
    groupbox.Width = grid:GetColWidth(0)
    groupbox.Height = grid.RowHeight
    groupbox.NoFrame = true
    groupbox.BackColor = "0,255,255,255"
    local cbtn = gui:Create("CheckButton")
    if nx_is_valid(cbtn) then
      cbtn.Width = 15
      cbtn.Height = 17
      cbtn.Left = (groupbox.Width - cbtn.Width) / 2
      cbtn.Top = (groupbox.Height - cbtn.Height) / 2
      cbtn.Name = "check" .. nx_string(index)
      cbtn.NormalImage = "gui\\special\\attire\\attire_list\\btn_qx_out.png"
      cbtn.FocusImage = "gui\\special\\attire\\attire_list\\btn_qx_on.png"
      cbtn.CheckedImage = "gui\\special\\attire\\attire_list\\btn_qx_down.png"
      cbtn.DisableImage = "gui\\special\\attire\\attire_list\\btn_qx_forbid.png"
      cbtn.DrawMode = nx_string("FitWindow")
      cbtn.equip = grid_data1
      cbtn.drawing = grid_data2
      groupbox:Add(cbtn)
      grid:SetGridControl(index, 0, groupbox)
      nx_bind_script(cbtn, "form_stage_main\\form_attire\\form_attire_save")
      nx_callback(cbtn, "on_checked_changed", "on_cbtn_item_checked_changed")
    end
  end
end
function create_grid_imagegrid(grid, grid_data, index)
  if not nx_is_valid(grid) then
    return
  end
  local gui = nx_value("gui")
  local imagegrid = gui:Create("ImageGrid")
  if nx_is_valid(imagegrid) then
    imagegrid.NoFrame = true
    imagegrid.BackColor = "0,255,255,255"
    imagegrid.DrawGridBack = nx_string("gui\\special\\attire\\attire_back\\k_tz.png")
    imagegrid.DrawMouseIn = "xuanzekuang_on"
    imagegrid.GridWidth = 38
    imagegrid.GridHeight = 39
    imagegrid.GridBackOffsetX = -2
    imagegrid.GridBackOffsetY = -2
    local offset_x = nx_int((grid:GetColWidth(1) - imagegrid.GridWidth) / 2)
    local offset_y = nx_int((grid.RowHeight - imagegrid.GridHeight) / 2)
    local item_photo = item_query_ArtPack_by_id(grid_data, "Photo")
    imagegrid.GridsPos = nx_string(offset_x) .. "," .. nx_string(offset_y)
    imagegrid:AddItem(0, item_photo, "", 1, -1)
    imagegrid.config_id = grid_data
    nx_bind_script(imagegrid, "form_stage_main\\form_attire\\form_attire_save")
    nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_mousein_grid")
    nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
    grid:SetGridControl(index, 1, imagegrid)
  end
end
function create_grid_mltbox(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  if nx_is_valid(groupbox) then
    groupbox.Width = grid:GetColWidth(3)
    groupbox.Height = grid.RowHeight
    groupbox.NoFrame = true
    groupbox.BackColor = "0,255,255,255"
    local mltbox = gui:Create("MultiTextBox")
    if nx_is_valid(mltbox) then
      mltbox.Width = groupbox.Width
      mltbox.Height = groupbox.Height / 2
      mltbox.Left = (groupbox.Width - mltbox.Width) / 2
      mltbox.Top = (groupbox.Height - mltbox.Height) / 2
      mltbox.Name = "mltbox" .. nx_string(index)
      mltbox.NoFrame = true
      mltbox.SelectBarColor = "0,0,0,255"
      mltbox.MouseInBarColor = "0,0,0,255"
      groupbox:Add(mltbox)
      grid:SetGridControl(index, 3, groupbox)
    end
  end
end
function set_grid_text(grid, grid_data, index)
  if not nx_is_valid(grid) then
    return
  end
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local item_name = get_text(grid_data)
  local active_text = ""
  local groupbox = grid:GetGridControl(index, 3)
  local mltbox = groupbox:Find("mltbox" .. nx_string(index))
  local state = attire_manager:AttireItemActive(grid_data)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_attire_002")
  gui.TextManager:Format_AddParam(PRICE)
  if state == true then
    active_text = get_text("ui_attire_save_1")
    mltbox.TextColor = "255,255,255,255"
  else
    active_text = get_text("ui_attire_save_2")
    mltbox.TextColor = "255,255,0,0"
    local groupbox = grid:GetGridControl(index, 0)
    local cbtn = groupbox:Find("check" .. nx_string(index))
    if nx_is_valid(cbtn) then
      cbtn.Enabled = false
    end
  end
  mltbox:Clear()
  mltbox:AddHtmlText(active_text, -1)
  grid:SetGridText(index, 2, nx_widestr(item_name))
  grid:SetGridText(index, 4, nx_widestr(1))
  grid:SetGridText(index, 5, nx_widestr(gui.TextManager:Format_GetText()))
  return state
end
function on_cbtn_item_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked == true then
    form.btn_2.Enabled = true
  else
    local save = get_save_num(form.textgrid_1)
    if nx_int(save) == nx_int(0) then
      form.btn_2.Enabled = false
    else
      form.btn_2.Enabled = true
    end
  end
end
function on_imagegrid_mousein_grid(grid)
  if not nx_is_valid(grid) then
    return
  end
  local gui = nx_value("gui")
  local x = grid:GetMouseInItemLeft()
  local y = grid:GetMouseInItemTop()
  local form = grid.ParentForm
  nx_execute("tips_game", "show_tips_by_config", grid.config_id, x, y, form)
end
function on_imagegrid_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_cbtn_checked_changed(cbtn)
  if not nx_is_valid(cbtn) then
    return
  end
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local form = cbtn.ParentForm
  local textgrid = form.textgrid_1
  for i = 0, textgrid.RowCount - 1 do
    local groupbox = textgrid:GetGridControl(i, 0)
    local control = groupbox:Find("check" .. nx_string(i))
    if nx_is_valid(control) then
      local configID = control.drawing
      if attire_manager:AttireItemActive(configID) then
        control.Checked = cbtn.Checked
      end
    end
  end
end
function get_save_num(grid)
  if not nx_is_valid(grid) then
    return 0
  end
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return 0
  end
  local save = 0
  for i = 0, grid.RowCount - 1 do
    local groupbox = grid:GetGridControl(i, 0)
    local control = groupbox:Find("check" .. nx_string(i))
    if nx_is_valid(control) and control.Checked then
      local configID = control.drawing
      if attire_manager:AttireItemActive(configID) then
        save = save + 1
      end
    end
  end
  return save
end
function on_btn_save_click(btn)
  local form = btn.ParentForm
  local textgrid = form.textgrid_1
  local save = get_save_num(textgrid)
  local num = 0
  local info = ""
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  for i = 0, textgrid.RowCount - 1 do
    local groupbox = textgrid:GetGridControl(i, 0)
    local control = groupbox:Find("check" .. nx_string(i))
    if nx_is_valid(control) and control.Checked then
      local configID = control.drawing
      if attire_manager:AttireItemActive(configID) then
        local item = util_split_string(control.equip, ",")
        local uid = item[2]
        num = num + 1
        if save > num then
          info = info .. configID .. "," .. uid .. ","
        else
          info = info .. configID .. "," .. uid
        end
      end
    end
  end
  local use_type = 0
  if form.cbtn_useitem.Checked then
    use_type = 1
    if not HasBuchangeItem("item_attire_rh", num) then
      local gui = nx_value("gui")
      local info = gui.TextManager:GetText("16630")
      util_form_confirm("", info, MB_OK)
      return
    end
    if not show_buchang_notice_dialog(num) then
      return
    end
  else
    use_type = 0
    local money = nx_int(num * PRICE)
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_attire_001")
    gui.TextManager:Format_AddParam(money)
    local text = gui.TextManager:Format_GetText()
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "save_no_finish")
    if not nx_is_valid(dialog) then
      return
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "save_no_finish_confirm_return")
    if res ~= "ok" then
      return
    end
  end
  nx_execute("custom_sender", "custom_attire_equip_blend", nx_int(use_type), nx_string(info))
  if nx_is_valid(form) then
    form:Close()
  end
  nx_execute("form_stage_main\\form_attire\\form_attire_jianghu", "refresh_form_equip_grid")
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function show_buchang_notice_dialog(amount)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("ui_attire_003", nx_int(amount))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "cancel" then
    return false
  end
  return true
end
function HasBuchangeItem(buchang, amount)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local view = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return false
  end
  local nHasNumber = nx_int(0)
  local toolobj_list = view:GetViewObjList()
  for j, obj in pairs(toolobj_list) do
    if nx_is_valid(obj) then
      local config_id = obj:QueryProp("ConfigID")
      if nx_string(config_id) == nx_string(buchang) then
        local nCount = obj:QueryProp("Amount")
        nHasNumber = nx_int(nHasNumber) + nx_int(nCount)
      end
    end
  end
  if nx_int(amount) <= nx_int(nHasNumber) then
    return true
  end
  return false
end
