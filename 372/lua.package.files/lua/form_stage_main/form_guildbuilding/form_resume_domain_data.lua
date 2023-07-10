require("util_gui")
require("define\\gamehand_type")
require("share\\itemtype_define")
require("util_functions")
local grid_table = {
  [1] = {
    col_width_per = 5,
    col_title = "ui_guildbuilding_drawings_building_name"
  },
  [2] = {
    col_width_per = 5,
    col_title = "ui_guildbuilding_drawings_building_level"
  }
}
local grid_per_base_num = 10
local FORM_NAME = "form_stage_main\\form_guildbuilding\\form_resume_domain_data"
local CLIENT_CUSTOMMSG_GUILD = 1014
local SUB_CUSTOMMSG_REQUEST_DOMAIN_ITEM_DATA = 2
local SUB_CUSTOMMSG_REQUEST_USE_DOMAIN_ITEM = 76
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  init_controls(form)
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.src_view_id = -1
  form.src_view_index = -1
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_ok_click(self)
  request_use_item()
end
function on_itemgrid_select_changed(grid, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local goods_grid = nx_value("GoodsGrid")
  if gui.GameHand:IsEmpty() then
    gui.GameHand:ClearHand()
  elseif gui.GameHand.Type == GHT_VIEWITEM then
    local src_view_id = nx_number(gui.GameHand.Para1)
    local src_view_index = nx_number(gui.GameHand.Para2)
    local src_amount = nx_number(gui.GameHand.Para3)
    local src_name = nx_string(gui.GameHand.Para4)
    local game_client = nx_value("game_client")
    local item_obj = game_client:GetViewObj(nx_string(src_view_id), nx_string(src_view_index))
    if not nx_is_valid(item_obj) then
      gui.GameHand:ClearHand()
      return
    end
    if nx_int(item_obj:QueryProp("ItemType")) ~= nx_int(ITEMTYPE_GUILDDOMAIN_DATA_ITEM) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("90321"), 2)
      end
      gui.GameHand:ClearHand()
      return
    end
    local photo = nx_execute("util_static_data", "queryprop_by_object", item_obj, "Photo")
    grid:AddItem(0, nx_string(photo), "", 1, -1)
    if nx_is_valid(goods_grid) and goods_grid:IsToolBoxViewport(nx_int(src_view_id)) then
      request_item_data(nx_int(src_view_id), nx_int(src_view_index))
    end
    gui.GameHand:ClearHand()
  end
end
function init_controls(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid
  if not nx_is_valid(grid) then
    return
  end
  grid:BeginUpdate()
  local grid_width = grid.Width - 30
  for i = 1, table.getn(grid_table) do
    grid:SetColWidth(i - 1, grid_width / grid_per_base_num * nx_int(grid_table[i].col_width_per))
    grid:SetColTitle(i - 1, nx_widestr(util_text(nx_string(grid_table[i].col_title))))
  end
  grid:EndUpdate()
end
function request_item_data(src_view_id, src_view_index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local form = nx_value(nx_string(FORM_NAME))
  if not nx_is_valid(form) then
    return
  end
  form.src_view_id = src_view_id
  form.src_view_index = src_view_index
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DOMAIN_ITEM_DATA), nx_int(src_view_id), nx_int(src_view_index))
end
function request_use_item()
  local form = nx_value(nx_string(FORM_NAME))
  if not nx_is_valid(form) then
    return
  end
  local src_view_id = form.src_view_id
  local src_view_index = form.src_view_index
  if form.src_view_id < 0 or form.src_view_index < 0 then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("1354"), 2)
    end
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_USE_DOMAIN_ITEM), nx_int(src_view_id), nx_int(src_view_index))
  form:Close()
end
function rec_item_info(...)
  local form = nx_value(nx_string(FORM_NAME))
  if not nx_is_valid(form) then
    return
  end
  local data_size = table.getn(arg)
  if (data_size - 1) % 2 ~= 0 then
    return
  end
  local grid = form.textgrid
  if not nx_is_valid(grid) then
    return
  end
  form.lbl_old_domain.Text = nx_widestr(util_text("ui_dipan_" .. nx_string(arg[1])))
  grid:BeginUpdate()
  grid:ClearRow()
  for i = 1, (data_size - 1) / 2 do
    local row = grid:InsertRow(-1)
    local temp_index = (i - 1) * 2 + 2
    local build_name = "ui_guildbuilding_drawings_" .. nx_string(arg[temp_index])
    grid:SetGridText(row, 0, nx_widestr(util_text(nx_string(build_name))))
    temp_index = temp_index + 1
    grid:SetGridText(row, 1, nx_widestr(arg[temp_index]))
  end
  grid:EndUpdate()
end
