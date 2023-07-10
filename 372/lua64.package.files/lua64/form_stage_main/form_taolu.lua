require("define\\gamehand_type")
require("util_functions")
local TAOLU_REC = "taolu_rec"
local taolu_info_lst = {}
local grid_taolu_info_lst = {}
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  if table.getn(taolu_info_lst) == 0 then
    load_taolu_info()
  end
  local gui = nx_value("gui")
  form.Left = gui.Width - form.Width
  form.Top = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  databinder:AddTableBind(TAOLU_REC, form, nx_current(), "on_taolu_update")
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
end
function on_btn_close_click(btn)
  local form = btn.Parent
  local gui = nx_value("gui")
  gui:Delete(form)
end
function on_taolu_update(form, tablename, ttype, line, col)
  refresh_taolu_info(form)
end
function on_grid_taolu_select_changed(grid)
  local index = grid:GetSelectItemIndex()
  if grid:IsEmpty(index) then
    return
  end
  local type = grid_taolu_info_lst[index].type
  if type ~= "taolu" then
    return
  end
  local taolu_id = grid_taolu_info_lst[index].taolu_id
  local photo = get_taolu_photo(taolu_id)
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, photo, "taolu", taolu_id, "", "")
end
function on_grid_taolu_rightclick_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local type = grid_taolu_info_lst[index].type
  if type ~= "taolu" then
    return
  end
  local taolu_id = grid_taolu_info_lst[index].taolu_id
  local row = client_player:FindRecordRow(TAOLU_REC, 0, taolu_id, 0)
  if row < 0 then
    return
  end
  local can_use = client_player:QueryRecord(TAOLU_REC, row, 1)
  if can_use == 0 then
    return
  end
  nx_execute("fight", "trace_use_taolu", taolu_id)
end
function on_grid_taolu_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local type = grid_taolu_info_lst[index].type
  if type == "taolu" then
    local taolu_id = grid_taolu_info_lst[index].taolu_id
    local show_string = gui.TextManager:GetFormatText("tips_taolu", taolu_id, "desc_" .. taolu_id)
    nx_execute("tips_game", "show_text_tip", show_string, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 0, grid.ParentForm)
  elseif type == "zhaoshi" then
    local zhaoshi_id = grid_taolu_info_lst[index].taolu_id
    local show_string = gui.TextManager:GetFormatText("tips_taolu", zhaoshi_id, "desc_" .. zhaoshi_id)
    nx_execute("tips_game", "show_text_tip", show_string, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 0, grid.ParentForm)
  end
end
function on_grid_taolu_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function refresh_taolu_info(form)
  form.grid_taolu.IsEditMode = false
  if table.getn(taolu_info_lst) == 0 then
    load_taolu_info()
  end
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  local client_player = game_client:GetPlayer()
  local taolu_count = client_player:GetRecordRows(TAOLU_REC)
  if taolu_count == 0 then
    return
  end
  local serial_count = 0
  local grid_pos_str = ""
  local left, top
  for i = 0, taolu_count - 1 do
    left = 0
    top = i * 80
    grid_pos_str = grid_pos_str .. left .. "," .. top .. ";"
    local taolu_id = client_player:QueryRecord(TAOLU_REC, i, 0)
    local count = get_taolu_serial_count(taolu_id)
    for j = 0, count - 1 do
      left = 100 + j * 90
      grid_pos_str = grid_pos_str .. left .. "," .. top .. ";"
    end
    serial_count = serial_count + count
  end
  form.grid_taolu.RowNum = 1
  form.grid_taolu.ClomnNum = taolu_count + serial_count
  form.grid_taolu.GridsPos = grid_pos_str
  local grid_index = 0
  for i = 0, taolu_count - 1 do
    local taolu_id = client_player:QueryRecord(TAOLU_REC, i, 0)
    local can_use = client_player:QueryRecord(TAOLU_REC, i, 1)
    set_grid_info_with_taolu(form.grid_taolu, grid_index, taolu_id, can_use)
    grid_taolu_info_lst[grid_index] = {type = "taolu", taolu_id = taolu_id}
    grid_index = grid_index + 1
    serial_count = get_taolu_serial_count(taolu_id)
    for j = 1, serial_count do
      set_grid_info_with_serial(form.grid_taolu, grid_index, taolu_id, j, can_use)
      grid_taolu_info_lst[grid_index] = {
        type = "zhaoshi",
        taolu_id = taolu_id,
        serial = serial
      }
      grid_index = grid_index + 1
    end
  end
end
function set_grid_info_with_taolu(grid, grid_index, taolu_id, can_use)
  local photo = get_taolu_photo(taolu_id)
  local gui = nx_value("gui")
  local name = gui.TextManager:GetFormatText(taolu_id)
  if not grid:IsEmpty(grid_index) then
    grid:DelItem(grid_index)
  end
  grid:AddItem(grid_index, photo, nx_widestr(""), 0, 0)
  grid:ShowItemAddInfo(grid_index, true)
  grid:SetItemInfo(grid_index, name)
  if can_use == 0 then
    grid:ChangeItemImageToBW(grid_index, true)
  end
end
function set_grid_info_with_serial(grid, grid_index, taolu_id, serial, can_use)
  local skill_id, name_id, photo, desc = get_taolu_serial_info(taolu_id, serial)
  local gui = nx_value("gui")
  local name = gui.TextManager:GetFormatText(name_id)
  if not grid:IsEmpty(grid_index) then
    grid:DelItem(grid_index)
  end
  grid:AddItem(grid_index, photo, nx_widestr(""), 0, 0)
  grid:ShowItemAddInfo(grid_index, true)
  grid:SetItemInfo(grid_index, name)
  if can_use == 0 then
    grid:ChangeItemImageToBW(grid_index, true)
  else
    local i = 0
  end
end
function get_taolu_serial_count(taolu_id)
  if taolu_info_lst[taolu_id] == nil then
    return 0
  end
  return table.getn(taolu_info_lst[taolu_id].serial_lst)
end
function get_taolu_photo(taolu_id)
  local photo = ""
  if taolu_info_lst[taolu_id] ~= nil then
    photo = taolu_info_lst[taolu_id].photo
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local row = client_player:FindRecordRow(TAOLU_REC, 0, taolu_id, 0)
  if row < 0 then
    return photo, 1
  end
  local can_use = client_player:QueryRecord(TAOLU_REC, row, 1)
  return photo, can_use
end
function get_taolu_serial_info(taolu_id, serial)
  local skill_id = ""
  local name_id = ""
  local photo = ""
  local desc = ""
  if taolu_info_lst[taolu_id] ~= nil and taolu_info_lst[taolu_id].serial_lst[serial] ~= nil then
    skill_id = taolu_info_lst[taolu_id].serial_lst[serial].skill_id
    name_id = taolu_info_lst[taolu_id].serial_lst[serial].name_id
    photo = taolu_info_lst[taolu_id].serial_lst[serial].photo
    desc = taolu_info_lst[taolu_id].serial_lst[serial].desc
  end
  return skill_id, name_id, photo, desc
end
function load_taolu_info()
end
