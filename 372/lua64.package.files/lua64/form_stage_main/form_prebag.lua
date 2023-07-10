require("const_define")
require("share\\view_define")
require("util_gui")
require("utils")
require("share\\itemtype_define")
require("share\\capital_define")
require("util_functions")
require("custom_sender")
require("custom_handler")
local MY_EQUIP_TYPE = 1
local EQUIP_TYPE = 2
local TOOL_TYPE = 3
local MATERIAL_TYPE = 4
local TASK_TYPE = 5
local COVER_NOR_IMG = "gui\\special\\btn_main\\btn_newWorld_chose.png"
local COVER_SEL_IMG = "gui\\special\\btn_main\\btn_newWorld_choose.png"
local COVER_EMPTY_IMG = "gui\\common\\imagegrid\\icon_lock2.png"
local ADD_BAG_MAX_NUM = 3
local BAG_COLS = 6
local FORM_NAME = "form_stage_main\\form_prebag"
local FORM_PRENEWBAG = "form_stage_main\\form_prenewbag"
local FORM_MAPPING_BAG = "form_stage_main\\form_mapping_bag"
local GRID_COUNT = 66
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function open_form()
  local gui = nx_value("gui")
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    on_main_form_close(form)
  else
    form = util_get_form("form_stage_main\\form_prebag", true)
    if nx_is_valid(form) then
      form:Show()
      form.Visible = true
    end
  end
end
function main_form_init(form)
  form.Fixed = true
  form.cur_grid = nil
  form.sel_box = 0
  return 1
end
function on_main_form_open(form)
  init_grid(form.imagegrid_myequip, VIEWPORT_EQUIP, 0)
  init_grid(form.imagegrid_equip, VIEWPORT_EQUIP_TOOL, VIEWPORT_EQUIP_ADDTOOLBOX)
  init_grid(form.imagegrid_tool, VIEWPORT_TOOL, VIEWPORT_ADDTOOLBOX)
  init_grid(form.imagegrid_mat, VIEWPORT_MATERIAL_TOOL, VIEWPORT_MATERIAL_ADDTOOLBOX)
  init_grid(form.imagegrid_task, VIEWPORT_TASK_TOOL, VIEWPORT_TASK_ADDTOOLBOX)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_EQUIP, form.imagegrid_myequip, FORM_NAME, "on_view_operat")
  databinder:AddViewBind(VIEWPORT_EQUIP_TOOL, form.imagegrid_equip, FORM_NAME, "on_view_operat")
  databinder:AddViewBind(VIEWPORT_TOOL, form.imagegrid_tool, FORM_NAME, "on_view_operat")
  databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, form.imagegrid_mat, FORM_NAME, "on_view_operat")
  databinder:AddViewBind(VIEWPORT_TASK_TOOL, form.imagegrid_task, FORM_NAME, "on_view_operat")
  form.rbtn_equip.Checked = false
  form.rbtn_equip.Checked = true
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  nx_execute("tips_game", "hide_tip", form)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(form.imagegrid_myequip)
  databinder:DelViewBind(form.imagegrid_equip)
  databinder:DelViewBind(form.imagegrid_tool)
  databinder:DelViewBind(form.imagegrid_mat)
  databinder:DelViewBind(form.imagegrid_task)
  nx_destroy(form)
  local form_prenewbag = nx_value(FORM_PRENEWBAG)
  if nx_is_valid(form_prenewbag) then
    nx_destroy(form_prenewbag)
  end
  local form_mapping_bag = nx_value(FORM_MAPPING_BAG)
  if nx_is_valid(form_mapping_bag) then
    nx_destroy(form_mapping_bag)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  on_main_form_close(form)
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
  if not nx_find_custom(form, "cur_grid") then
    return
  end
  if not nx_is_valid(form.cur_grid) then
    return
  end
  if grid.Name ~= form.cur_grid.Name then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  if optype == "additem" or optype == "delitem" or optype == "updateitemprop" then
    refresh_bag(form, false)
  end
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
  local form_width = 4 + grid_w + 46
  form.Width = form_width
  form.groupbox_2.Left = form_width - 46 - 4
  form.groupbox_2.Top = form.lbl_xian3.Top
  form.groupbox_1.Top = form.lbl_xian3.Top + 4
  form.groupbox_1.Width = grid_w + 2
  form.groupbox_1.Height = grid.Top + grid_h + 2
  form.groupbox_1.Left = 0
  form.lbl_xian5.Top = form.groupbox_1.Top + form.groupbox_1.Height - 10
  form.groupbox_3.Top = form.lbl_xian5.Top
  form.groupbox_3.Width = grid_w - 4
  form.lbl_xian3.Width = grid_w - 4
  form.lbl_xian4.Width = grid_w - 4
  form.lbl_xian5.Width = grid_w - 4
  form.lbl_xian4.Top = form.groupbox_3.Top + form.groupbox_3.Height
  form.groupbox_bnt.Top = form.lbl_xian4.Top - 3
  form.groupbox_bnt.Width = grid_w - 4
  form.lbl_1.Width = grid_w - 6
  form.lbl_1.Height = grid_h - 2
  form.lbl_1.Top = form.lbl_xian3.Top + 4
  form.lbl_3.Left = (grid_w - form.lbl_3.Width) / 2
  form.title.Left = (grid_w - form.title.Width) / 2
  form.lbl_main1.Width = grid_w + 2
  form.lbl_main1.Height = form.groupbox_bnt.Top + form.groupbox_bnt.Height - 22
  form.Height = form.groupbox_bnt.Top + form.groupbox_bnt.Height + 6
  form.btn_close.Left = grid_w - form.btn_close.Width - 4
end
function init_grid(grid, typeid, other_typeid)
  grid.typeid = typeid
  grid.addtypeid = other_typeid
  grid.max_item_num = 0
  grid.use_item_num = 0
end
function refresh_bag(form, default)
  if not nx_is_valid(form) then
    return
  end
  if default then
    form.rbtn_myequip.Checked = false
    form.rbtn_myequip.Checked = true
  else
    refresh_goods_grid_index(form)
    refresh_item_num(form)
    refresh_need_money(form)
  end
  refresh_grid_empty(form.cur_grid)
end
function refresh_goods_grid_index(form)
  if not nx_is_valid(form) then
    return false
  end
  local form_pre_bag = nx_value("formprebag")
  if not nx_is_valid(form_pre_bag) then
    return false
  end
  local grid = form.cur_grid
  if not nx_is_valid(grid) then
    return false
  end
  init_grid_coverimg(grid)
  grid:Clear()
  grid.max_item_num = form_pre_bag:CalcFreeGrid(grid)
  if grid.max_item_num < 0 then
    grid.max_item_num = 0
  end
  grid.use_item_num = 0
  local game_client = nx_value("game_client")
  local bagview = game_client:GetView(nx_string(grid.typeid))
  if not nx_is_valid(bagview) then
    grid.ClomnNum = GRID_COUNT
    reset_form_size(form)
    return false
  end
  local grid_count = 0
  grid_count = bagview:GetViewObjCount()
  if grid_count <= 0 then
    grid.ClomnNum = GRID_COUNT
    reset_form_size(form)
    return false
  end
  local grid_index = 0
  local base_cap = bagview:QueryProp("BaseCap")
  if grid.typeid == VIEWPORT_EQUIP then
    base_cap = 43
  end
  for view_index = 1, base_cap do
    local item = bagview:GetViewObj(nx_string(view_index))
    if form_pre_bag:CheckItem(item) then
      grid:SetBindIndex(grid_index, view_index)
      grid:SetItemMark(grid_index, 0)
      grid_index = grid_index + 1
    end
  end
  local addbag_view = game_client:GetView(nx_string(grid.addtypeid))
  if nx_is_valid(addbag_view) then
    for i = 1, ADD_BAG_MAX_NUM do
      local smallbag = addbag_view:GetViewObj(nx_string(i))
      if nx_is_valid(smallbag) then
        local beginindex = smallbag:QueryProp("BeginPos")
        local endindex = smallbag:QueryProp("EndPos")
        for view_index = beginindex, endindex do
          local item = bagview:GetViewObj(nx_string(view_index))
          if form_pre_bag:CheckItem(item) then
            grid:SetBindIndex(grid_index, view_index)
            grid:SetItemMark(grid_index, 0)
            grid_index = grid_index + 1
          end
        end
      end
    end
  end
  grid_index = GRID_COUNT
  if grid_index <= 0 then
    grid.ClomnNum = GRID_COUNT
    reset_form_size(form)
    return false
  end
  local total = nx_int(grid_index)
  if grid_index % BAG_COLS ~= 0 then
    local row = nx_int(grid_index / BAG_COLS) + nx_int(1)
    total = row * nx_int(BAG_COLS)
  end
  if nx_int(total) < nx_int(GRID_COUNT) then
    total = nx_int(GRID_COUNT)
  end
  grid.ClomnNum = total
  grid.max_item_num = form_pre_bag:CalcFreeGrid(grid)
  if grid.max_item_num < 0 then
    grid.max_item_num = 0
  end
  grid.use_item_num = 0
  reset_form_size(form)
  local GoodsGrid = nx_value("GoodsGrid")
  GoodsGrid:ViewRefreshGrid(grid)
  for i = 0, grid_index do
    set_grid_coverimg(grid, i, true, 0)
  end
  return true
end
function get_target_view(view_id)
  if view_id == VIEWPORT_EQUIP or view_id == VIEWPORT_EQUIP_TOOL then
    return VIEWPORT_NEWEQUIPTOOLBOX
  elseif view_id == VIEWPORT_TOOL then
    return VIEWPORT_NEWTOOLBOX
  end
  return 0
end
function refresh_item_num(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = nx_custom(form, "cur_grid")
  if not nx_is_valid(grid) then
    return
  end
  local mltbox_num = form.mltbox_2
  mltbox_num:Clear()
  mltbox_num:AddHtmlText(util_format_string("ui_move_into", grid.use_item_num, grid.max_item_num), -1)
  local width = mltbox_num:GetContentWidth()
  local left = (mltbox_num.Width - width) / 2
  mltbox_num.ViewRect = nx_string(left) .. "," .. "6" .. "," .. nx_string(mltbox_num.Width) .. "," .. nx_string(mltbox_num.Height)
end
function refresh_need_money(form)
  if not nx_is_valid(form) then
    return
  end
end
function choose_bag_type(type)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_myequip.Visible = false
  form.imagegrid_equip.Visible = false
  form.imagegrid_tool.Visible = false
  form.imagegrid_mat.Visible = false
  form.imagegrid_task.Visible = false
  form.imagegrid_myequip:SetSelectItemIndex(nx_int(-1))
  form.imagegrid_equip:SetSelectItemIndex(nx_int(-1))
  form.imagegrid_tool:SetSelectItemIndex(nx_int(-1))
  form.imagegrid_mat:SetSelectItemIndex(nx_int(-1))
  form.imagegrid_task:SetSelectItemIndex(nx_int(-1))
  if type == "1" then
    form.imagegrid_myequip.Visible = true
    form.cur_grid = form.imagegrid_myequip
    form.sel_box = MY_EQUIP_TYPE
  elseif type == "2" then
    form.imagegrid_equip.Visible = true
    form.cur_grid = form.imagegrid_equip
    form.sel_box = EQUIP_TYPE
  elseif type == "3" then
    form.imagegrid_tool.Visible = true
    form.cur_grid = form.imagegrid_tool
    form.sel_box = TOOL_TYPE
  elseif type == "4" then
    form.imagegrid_mat.Visible = true
    form.cur_grid = form.imagegrid_mat
    form.sel_box = MATERIAL_TYPE
  elseif type == "5" then
    form.imagegrid_task.Visible = true
    form.cur_grid = form.imagegrid_task
    form.sel_box = TASK_TYPE
  else
    form.imagegrid_myequip.Visible = true
    form.cur_grid = form.imagegrid_myequip
    form.sel_box = MY_EQUIP_TYPE
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
function on_bag_right_click(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form_pre_bag = nx_value("formprebag")
  if not nx_is_valid(form_pre_bag) then
    return
  end
  if not form_pre_bag:CheckMoveItem(grid, index) then
    return
  end
  local mark = grid:GetItemMark(index)
  local state = nx_boolean(mark)
  local state = not state
  if state == true then
    if grid.use_item_num >= grid.max_item_num then
      custom_sysinfo(1, 1, 1, 2, "sys_move_full")
      return
    end
    grid.use_item_num = grid.use_item_num + 1
    grid:SetItemMark(index, nx_int(state))
    set_grid_coverimg(grid, index, state, 1)
  else
    grid:SetItemMark(index, nx_int(state))
    set_grid_coverimg(grid, index, state, 0)
    if grid.use_item_num - 1 <= 0 then
      grid.use_item_num = 0
    else
      grid.use_item_num = grid.use_item_num - 1
    end
  end
  refresh_item_num(grid.ParentForm)
  refresh_need_money(grid.ParentForm)
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
end
function on_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function set_grid_coverimg(grid, index, bcover, bsel)
  if not nx_is_valid(grid) then
    return
  end
  if grid:IsEmpty(index) then
    return
  end
  grid:CoverItem(index, true)
  if bcover == true and bsel == 1 then
    grid:SetItemCoverImage(index, COVER_SEL_IMG)
  else
    grid:SetItemCoverImage(index, COVER_NOR_IMG)
  end
end
function init_grid_coverimg(grid)
  if not nx_is_valid(grid) then
    return
  end
  local count = grid.ClomnNum * grid.RowNum
  for i = 0, count do
    grid:CoverItem(i, false)
    grid:SetBindIndex(i, 0)
  end
end
function change_bag_btn(flag)
end
function on_btn_sure_click(btn)
  local form = btn.ParentForm
  local form_pre_bag = nx_value("formprebag")
  if not nx_is_valid(form_pre_bag) then
    return
  end
  if not nx_find_custom(form, "cur_grid") then
    return
  end
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  local money = 0
  if 0 < money then
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_item_move_new")
    gui.TextManager:Format_AddParam(money)
    local text = gui.TextManager:Format_GetText()
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "prebag_cost")
    if not nx_is_valid(dialog) then
      return
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "prebag_cost_confirm_return")
    if res == "ok" then
      local strpos = form_pre_bag:GetMovePos(form.cur_grid)
      if strpos ~= "" then
        custom_send_move_item_to_new(form.sel_box, strpos)
      end
    end
  elseif money == 0 then
    local strpos = form_pre_bag:GetMovePos(form.cur_grid)
    if strpos ~= "" then
      custom_send_move_item_to_new(form.sel_box, strpos)
    end
  end
end
function on_btn_all_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "cur_grid") then
    return
  end
  local grid = form.cur_grid
  local can_use_num = grid.max_item_num - grid.use_item_num
  if can_use_num <= 0 then
    custom_sysinfo(1, 1, 1, 2, "sys_move_full")
    return
  end
  local count = 0
  count = set_max_grid_index(grid, can_use_num)
  grid.use_item_num = count + grid.use_item_num
  refresh_item_num(form)
  refresh_need_money(form)
end
function set_max_grid_index(grid, max_num)
  if not nx_is_valid(grid) then
    return nil
  end
  local form_pre_bag = nx_value("formprebag")
  if not nx_is_valid(form_pre_bag) then
    return nil
  end
  local count = grid.ClomnNum * grid.RowNum
  local num = 0
  for i = 0, count do
    if max_num <= num then
      return max_num
    end
    local mark = grid:GetItemMark(i)
    if mark ~= 1 and form_pre_bag:CheckMoveItem(grid, i) then
      num = num + 1
      set_grid_coverimg(grid, i, true, 1)
      grid:SetItemMark(i, 1)
    end
  end
  if max_num <= num then
    num = max_num
  end
  return num
end
function on_btn_reset_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "cur_grid") then
    return
  end
  local grid = form.cur_grid
  grid.use_item_num = 0
  local count = grid.ClomnNum * grid.RowNum
  for i = 0, count do
    set_grid_coverimg(grid, i, false, 0)
    grid:SetItemMark(i, 0)
  end
  refresh_item_num(form)
  refresh_need_money(form)
end
function change_tool_type(move_op)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(move_op) == nx_int(1) then
    form.rbtn_myequip.Checked = false
    form.rbtn_myequip.Checked = true
  elseif nx_int(move_op) == nx_int(11) then
    form.rbtn_equip.Checked = false
    form.rbtn_equip.Checked = true
  elseif nx_int(move_op) == nx_int(12) then
    form.rbtn_tool.Checked = false
    form.rbtn_tool.Checked = true
  elseif nx_int(move_op) == nx_int(13) then
    form.rbtn_marterial.Checked = false
    form.rbtn_marterial.Checked = true
  elseif nx_int(move_op) == nx_int(14) then
    form.rbtn_task.Checked = false
    form.rbtn_task.Checked = true
  end
end
function refresh_grid_empty(grid)
  if not nx_is_valid(grid) then
    return
  end
  local form_pre_bag = nx_value("formprebag")
  if not nx_is_valid(form_pre_bag) then
    return
  end
  local count = grid.ClomnNum * grid.RowNum
  local max_count = form_pre_bag:CalcCurFreeGrid(grid)
  local index_start = 0
  for i = 0, count - 1 do
    if grid:IsEmpty(i) then
      if max_count <= index_start then
        grid:CoverItem(i, true)
        grid:SetItemCoverImage(i, COVER_EMPTY_IMG)
      end
      index_start = index_start + 1
    end
  end
end
