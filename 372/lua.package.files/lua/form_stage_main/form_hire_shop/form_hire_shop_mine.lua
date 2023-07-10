require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("hyperlink_manager")
local shop_info_table = {}
local SUBMSG_CLIENT_GET_SHOP_LIST = 13
local world_scene_list = {
  [1] = "born04",
  [2] = "born02",
  [3] = "born03",
  [4] = "born01",
  [5] = "school01",
  [6] = "school02",
  [7] = "school03",
  [8] = "school04",
  [9] = "school05",
  [10] = "school06",
  [11] = "school07",
  [12] = "school08",
  [13] = "city01",
  [14] = "city02",
  [15] = "city03",
  [16] = "city04",
  [17] = "city05"
}
function main_form_init(form)
  form.Fixed = false
  form.Visible = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2 + 70
  form.Top = (gui.Height - form.Height) / 2
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(SUBMSG_CLIENT_GET_SHOP_LIST))
  Init_Grid(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return 1
end
function Init_Grid(form)
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_my_shop_list:BeginUpdate()
  form.textgrid_my_shop_list:ClearRow()
  form.textgrid_my_shop_list:ClearSelect()
  local gui = nx_value("gui")
  form.textgrid_my_shop_list.ColCount = 5
  form.textgrid_my_shop_list.ColWidths = "40, 130, 70, 70, 90"
  form.textgrid_my_shop_list:SetColTitle(0, nx_widestr(util_text("ui_my_shop_num")))
  form.textgrid_my_shop_list:SetColTitle(1, nx_widestr(util_text("ui_my_shop_name")))
  form.textgrid_my_shop_list:SetColTitle(2, nx_widestr(util_text("ui_my_shop_scene")))
  form.textgrid_my_shop_list:SetColTitle(3, nx_widestr(util_text("ui_my_shop_pos")))
  form.textgrid_my_shop_list:SetColTitle(4, nx_widestr(util_text("ui_my_shop_state")))
  form.textgrid_my_shop_list:EndUpdate()
end
function on_recv_hire_shop_list(...)
  local form = nx_value("form_stage_main\\form_hire_shop\\form_hire_shop_mine")
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size < 0 or size % 7 ~= 0 then
    return 0
  end
  local rows = size / 7
  form.textgrid_my_shop_list:BeginUpdate()
  form.textgrid_my_shop_list:ClearRow()
  form.textgrid_my_shop_list:ClearSelect()
  local game_client = nx_value("game_client")
  local client_role = game_client:GetPlayer()
  if not nx_is_valid(client_role) then
    return false
  end
  shop_info_table = {}
  for i = 0, rows - 1 do
    local row = form.textgrid_my_shop_list:InsertRow(-1)
    local base = i * 7
    local config_id = arg[base + 2]
    local shopName = arg[base + 3]
    local sceneid = arg[base + 4]
    local pos_x = arg[base + 5]
    local pos_z = arg[base + 6]
    local state = arg[base + 7]
    local scenename = nx_widestr(util_text("ui_scene_" .. nx_string(sceneid)))
    local gui = nx_value("gui")
    if nx_widestr(shopName) == nx_widestr("") or nx_widestr(shopName) == nx_widestr("0") then
      shopName = gui.TextManager:GetFormatText("ui_stall_mingcheng", nx_widestr(client_role:QueryProp("Name")))
    end
    form.textgrid_my_shop_list:SetGridText(row, 0, nx_widestr(i + 1))
    form.textgrid_my_shop_list:SetGridText(row, 1, nx_widestr(shopName))
    form.textgrid_my_shop_list:SetGridText(row, 2, nx_widestr(scenename))
    form.textgrid_my_shop_list:SetGridText(row, 3, nx_widestr(pos_x) .. nx_widestr(",") .. nx_widestr(pos_z))
    if nx_int(state) == nx_int(1) then
      form.textgrid_my_shop_list:SetGridText(row, 4, nx_widestr(util_text("ui_my_shop_baitan")))
      form.textgrid_my_shop_list:SetGridForeColor(row, 4, "255,100,180,0")
    else
      form.textgrid_my_shop_list:SetGridText(row, 4, nx_widestr(util_text("ui_my_shop_shoutan")))
      form.textgrid_my_shop_list:SetGridForeColor(row, 4, "255,255,0,0")
    end
    table.insert(shop_info_table, {row, sceneid})
  end
  form.textgrid_my_shop_list:EndUpdate()
end
function on_textgrid_my_shop_list_double_click_grid(grid, row, col)
  local form = grid.ParentForm
  if nx_int(row) < nx_int(0) then
    return false
  end
  if shop_info_table == nil or world_scene_list == nil then
    return false
  end
  local rows = table.getn(shop_info_table)
  local sceneid = 0
  for i = 1, rows do
    local row_index = shop_info_table[i][1]
    if row == row_index then
      sceneid = nx_number(shop_info_table[i][2])
      break
    end
  end
  if sceneid == 0 or sceneid == nil then
    return false
  end
  local length = table.getn(world_scene_list)
  if sceneid > length then
    return false
  end
  local scene_name = world_scene_list[sceneid]
  local pos = grid:GetGridText(row, 3)
  local szLinkData = "<a href=" .. "'" .. "findpath," .. nx_string(scene_name) .. "," .. nx_string(pos) .. "'" .. "></a>"
  find_path_npc_item(szLinkData, true)
end
function open_close_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_hire_shop\\form_hire_shop_mine", true, false)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(form) then
    return false
  end
  if form.Visible then
    form:Close()
  else
    form.Visible = true
    form:Show()
  end
end
