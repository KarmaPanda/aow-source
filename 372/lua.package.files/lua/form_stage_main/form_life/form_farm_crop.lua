require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
require("util_functions")
require("util_vip")
FARM_CROP = 0
FARM_CropType = 1
FARM_STATE = 2
FARM_TIME = 3
FARM_SENCEID = 4
FARM_CHUNK = 5
FARM_POS = 6
WORMY = 1
DRY = 16
WEED = 256
CROP_PLANT = 1
CROP_CULTIVATION = 2
NormalImage = "gui\\common\\checkbutton\\rbtn_top_out.png"
FocusImage = "gui\\common\\checkbutton\\rbtn_top_on.png"
PushImage = "gui\\common\\checkbutton\\rbtn_top_down.png"
function get_life_form_visible()
  local form = nx_value("form_stage_main\\form_life\\form_job_main_new")
  if nx_is_valid(form) then
    return form.Visible
  else
    return false
  end
end
function fresh_form(form)
  if nx_is_valid(form) then
    fresh_crop_info(form.crop_type, form.crop_grid_list)
  end
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.crop_type = CROP_PLANT
  init_grid(form.crop_grid_list)
  fresh_crop_info(CROP_PLANT, form.crop_grid_list)
  set_sel_page_flg(form, CROP_PLANT)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("crop_rec", form, nx_current(), "on_crop_rec_refresh")
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("crop_rec", form)
  end
  nx_destroy(form)
end
function on_form_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function ok_btn_click(self)
  local form = self.ParentForm
  form:Close()
end
function cancel_btn_click(self)
  local form = self.ParentForm
  form:Close()
end
function init_grid(self)
  self.ColCount = 7
  for i = 1, self.ColCount do
    self:SetColAlign(i - 1, "center")
  end
  self.HeaderColWidth = 30
  self.HeaderBackColor = "0,255,0,0"
  self:SetColTitle(0, nx_widestr(util_text("ui_farm3")))
  self:SetColTitle(1, nx_widestr(util_text("ui_farm4")))
  self:SetColTitle(2, nx_widestr(util_text("ui_farm5")))
  self:SetColTitle(3, nx_widestr(util_text("ui_farm6")))
  self:SetColTitle(4, nx_widestr(""))
  self:SetColTitle(5, nx_widestr(""))
  self:SetColTitle(6, nx_widestr(""))
  self.cur_editor_row = -1
  self.current_task_id = ""
end
function cultivation_freshinfo(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(CROP_CULTIVATION) == nx_int(form.crop_type) then
    return
  end
  form.crop_type = CROP_CULTIVATION
  fresh_crop_info(CROP_CULTIVATION, form.crop_grid_list)
  set_sel_page_flg(form, CROP_CULTIVATION)
end
function plant_freshinfo(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(CROP_PLANT) == nx_int(form.crop_type) then
    return
  end
  form.crop_type = CROP_PLANT
  fresh_crop_info(CROP_PLANT, form.crop_grid_list)
  set_sel_page_flg(form, CROP_PLANT)
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "show_or_hide_main_form", true)
end
function fresh_crop_info(crop_type, grid)
  grid:ClearRow()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local row = client_player:GetRecordRows("crop_rec")
  if nx_int(row) < nx_int(0) then
    return false
  end
  for i = 0, row - 1 do
    local type = client_player:QueryRecord("crop_rec", i, FARM_CropType)
    if nx_int(type) == nx_int(crop_type) then
      local strCrop, senceID, state, time, pos, chunk
      strCrop = client_player:QueryRecord("crop_rec", i, FARM_CROP)
      senceID = client_player:QueryRecord("crop_rec", i, FARM_SENCEID)
      state = client_player:QueryRecord("crop_rec", i, FARM_STATE)
      time = client_player:QueryRecord("crop_rec", i, FARM_TIME)
      chunk = client_player:QueryRecord("crop_rec", i, FARM_CHUNK)
      pos = client_player:QueryRecord("crop_rec", i, FARM_POS)
      local pos_string = ""
      local pos_table = util_split_string(pos, ",")
      if pos_table[1] ~= nil and pos_table[3] ~= nil then
        pos_string = "(" .. nx_string(nx_int(pos_table[1])) .. "," .. nx_string(nx_int(pos_table[3])) .. ")"
      end
      local row = grid:InsertRow(-1)
      grid:SetGridText(row, 0, nx_widestr(util_text(strCrop)))
      grid:SetGridText(row, 1, nx_widestr(util_text("ui_scene_" .. nx_string(senceID))) .. nx_widestr(pos_string))
      if nx_int(state) == nx_int(WEED) then
        if nx_int(type) == nx_int(CROP_PLANT) then
          grid:SetGridText(row, 2, nx_widestr(util_text("ui_farm5_4")))
        else
          grid:SetGridText(row, 2, nx_widestr(util_text("ui_farm5_5")))
        end
      elseif nx_int(state) == nx_int(WORMY) then
        grid:SetGridText(row, 2, nx_widestr(util_text("ui_farm5_3")))
      else
        grid:SetGridText(row, 2, nx_widestr(util_text("ui_farm5_1")))
      end
      grid:SetGridText(row, 3, nx_widestr(time))
    end
  end
end
function on_click_btn(btn)
  local form = btn.ParentForm
  local x, y, z = get_selcrop_pos(btn.row_index, form.crop_grid_list)
  local path_finding = nx_value("path_finding")
  if not nx_is_valid(path_finding) then
    return
  end
  if is_auto_find_path() then
    path_finding:FindPathScene(get_scene_name(btn.scene_id), nx_float(x), nx_float(y), nx_float(z), 0)
  else
    path_finding:DrawToTarget(get_scene_name(btn.scene_id), nx_float(x), nx_float(y), nx_float(z), 0, "")
  end
end
function create_button(scene_id, row, farm_time)
  local gui = nx_value("gui")
  local grp = gui:Create("GroupBox")
  grp.BackColor = "0,0,0,0"
  grp.LineColor = "0,0,0,0"
  local button = gui:Create("Button")
  if not nx_is_valid(button) then
    return
  end
  button.Left = 20
  button.Top = 3
  button.AutoSize = false
  button.NormalImage = "gui\\common\\button\\btn_normal2_out.png"
  button.FocusImage = "gui\\common\\button\\btn_normal2_on.png"
  button.PushImage = "gui\\common\\button\\btn_normal2_down.png"
  button.DrawMode = "ExpandH"
  button.Hight = 26
  button.row_index = row
  button.scene_id = scene_id
  if farm_time ~= 0 then
    button.Text = nx_widestr(util_text("ui_farm8"))
  else
    button.Text = nx_widestr(util_text("ui_farm9"))
  end
  nx_bind_script(button, nx_current())
  nx_callback(button, "on_click", "on_click_btn")
  grp:Add(button)
  return grp
end
function on_crop_rec_refresh(form, recordname, optype, row, clomn)
  if not get_life_form_visible() then
    return
  end
  if optype == "update" or optype == "del" then
    fresh_crop_info(form.crop_type, form.crop_grid_list)
  end
end
function get_selcrop_pos(index, grid)
  if nx_int(0) > nx_int(index) then
    return 0, 0, 0
  end
  if not nx_is_valid(grid) then
    return
  end
  local pos_text = grid:GetGridText(index, 5)
  local pos = util_split_string(nx_string(pos_text), ",")
  local x = nx_int(pos[1])
  local y = nx_int(pos[2])
  local z = nx_int(pos[3])
  return x, y, z
end
function get_scene_name(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\maplist.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\rule\\maplist.ini " .. get_msg_str("msg_120"))
  end
  return ini:ReadString(0, nx_string(index), "")
end
function on_crop_grid_list_select_grid(grid, row, col)
  local gui = nx_value("gui")
  local form = grid.ParentForm
  local text = ""
end
function on_sort_btn_click(btn)
  local form = btn.ParentForm
  local col = nx_int(btn.Name) - nx_int(1)
  if nx_int(3) == nx_int(col) then
    form.crop_grid_list:SortRowsByInt(col, false)
  elseif nx_int(2) == nx_int(col) then
    form.crop_grid_list:SortRowsByInt(6, false)
  else
    form.crop_grid_list:SortRows(col, false)
  end
end
function set_sel_page_flg(form, page)
  if nx_int(page) == nx_int(CROP_PLANT) then
    form.btn_1.NormalImage = PushImage
    form.btn_1.FocusImage = PushImage
    form.btn_2.NormalImage = NormalImage
    form.btn_2.FocusImage = FocusImage
  else
    form.btn_2.NormalImage = PushImage
    form.btn_2.FocusImage = PushImage
    form.btn_1.NormalImage = NormalImage
    form.btn_1.FocusImage = FocusImage
  end
end
