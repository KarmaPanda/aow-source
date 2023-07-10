require("util_gui")
local OFFLINE_STATE_ONLINE = 0
local OFFLINE_STATE_NONE = -1
local FRIEND_REC_MENPAI = 5
function main_form_init(form)
  form.Fixed = false
  form.cur_page_name = ""
  form.selcect_name = ""
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  init_grid_data(form)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function init_grid_data(form)
  local gui = nx_value("gui")
  form.textgrid_content:BeginUpdate()
  form.textgrid_content:ClearRow()
  form.textgrid_content:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_leitai_requester_name")))
  form.textgrid_content:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_leitai_requester_str")))
  form.textgrid_content:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_leitai_requester_school")))
  form.textgrid_content:SetColTitle(3, nx_widestr(gui.TextManager:GetText("ui_leitai_requester_state")))
  form.textgrid_content:EndUpdate()
  form.rbtn_1.Checked = true
  updata_requeter_info(form, "rec_enemy")
end
function on_textgrid_content_select_row(grid)
  local row = grid.RowSelectIndex
  if row < 0 then
    return
  end
  local form = grid.ParentForm
  local name = nx_widestr(grid:GetGridText(row, 0))
  if name ~= "" then
    form.selcect_name = name
  end
end
function on_rbtn_checked_changed(btn)
  local form = btn.ParentForm
  if not btn.Checked then
    return
  end
  local enemy_type = btn.DataSource
  local rec_name
  if nx_number(enemy_type) == nx_number(1) then
    rec_name = nx_string("rec_enemy")
  elseif nx_number(enemy_type) == nx_number(2) then
    rec_name = nx_string("rec_blood")
  end
  if rec_name ~= nil then
    updata_requeter_info(form, rec_name)
  end
end
function updata_requeter_info(self, rec_name)
  local form = self.ParentForm
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  clear_requester_info(form)
  if client_player:FindRecord(rec_name) then
    local rows = client_player:GetRecordRows(rec_name)
    if rows <= nx_number(0) then
      return
    end
    local gui = nx_value("gui")
    for i = 0, rows - 1 do
      local name = client_player:QueryRecord(rec_name, i, 1)
      local power_level = client_player:QueryRecord(rec_name, i, 4)
      power_level = karmamgr:ParseColValue(4, nx_string(power_level))
      local str_lv = gui.TextManager:GetText("desc_" .. power_level)
      local menpai = client_player:QueryRecord(rec_name, i, 5)
      menpai = karmamgr:ParseColValue(FRIEND_REC_MENPAI, nx_string(menpai))
      local school = gui.TextManager:GetText(menpai)
      local offline_state = client_player:QueryRecord(rec_name, i, 8)
      insert_requester_info(form, name, str_lv, school, offline_state)
    end
  end
end
function insert_requester_info(self, name, str, school, state)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local row = -1
  local online_info = ""
  if nx_number(state) == OFFLINE_STATE_ONLINE then
    row = form.textgrid_content:InsertRow(0)
    online_info = gui.TextManager:GetText("ui_leitai_online")
  elseif nx_number(state) == OFFLINE_STATE_NONE then
    row = form.textgrid_content:InsertRow(-1)
    online_info = gui.TextManager:GetText("ui_leitai_none")
  end
  if nx_string(school) == nil or nx_string(school) == "" then
    school = gui.TextManager:GetText("ui_task_school_null")
  end
  form.textgrid_content:SetGridText(row, 0, nx_widestr(name))
  form.textgrid_content:SetGridText(row, 1, nx_widestr(str))
  form.textgrid_content:SetGridText(row, 2, nx_widestr(school))
  form.textgrid_content:SetGridText(row, 3, nx_widestr(online_info))
end
function clear_requester_info(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_content:ClearRow()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.selcect_name ~= "" then
    nx_execute("form_stage_main\\form_leitai\\form_leitai", "set_requester_name", form.selcect_name)
  end
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
