require("util_gui")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
local g_tvt_all_type = {
  ITT_SUPERBOOK,
  ITT_AVATAR,
  ITT_WORLDWAR,
  ITT_JHHJ,
  ITT_PATROL,
  ITT_SPY_MENP,
  ITT_WORLDLEITAI_RANDOM,
  ITT_WORLDBOSS,
  ITT_WORLDLEITAI,
  ITT_ARREST,
  ITT_DALEI,
  ITT_XIASHI,
  ITT_MATCH_RIVERS,
  ITT_MATCH_SCHOOL,
  ITT_BANGFEI,
  ITT_TEAMFACULTY,
  ITT_JIEBIAO,
  ITT_YUNBIAO,
  ITT_MENPAIZHAN,
  ITT_JIUHUO,
  ITT_FANGHUO,
  ITT_SCHOOLMOOT,
  ITT_BANGPAIZHAN,
  ITT_HUSHU,
  ITT_DUOSHU,
  ITT_YUNBIAO_ACTIVE,
  ITT_SCHOOL_DANCE,
  ITT_TIGUAN_DANSHUA,
  ITT_WORLDWAR_LXC,
  ITT_KHD,
  ITT_NLHH
}
local prize_image_t = {
  [0] = "gui\\language\\ChineseS\\tvt\\icon_1.png",
  [1] = "gui\\language\\ChineseS\\tvt\\icon_1.png",
  [2] = "gui\\language\\ChineseS\\tvt\\icon_1.png",
  [3] = "gui\\language\\ChineseS\\tvt\\icon_5.png",
  [4] = "gui\\language\\ChineseS\\tvt\\icon_2.png",
  [5] = "gui\\language\\ChineseS\\tvt\\icon_3.png",
  [6] = "gui\\language\\ChineseS\\tvt\\icon_6.png"
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function set_copy_ent_info(form, source, target_ent)
  local source_ent = nx_custom(form, source)
  if not nx_is_valid(source_ent) then
    return
  end
  local prop_list = nx_property_list(source_ent)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(target_ent, prop, nx_property(source_ent, prop))
    end
  end
end
function on_main_form_open(self)
  refresh_grid_list(self.textgrid_list)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "refresh_grid_list", self.textgrid_list, -1, -1)
  end
end
function clear_grid_data(grid)
  if nx_is_valid(grid) then
    for i = 0, grid.RowCount - 1 do
      grid:ClearGridControl(i, 0)
      grid:ClearGridControl(i, 2)
      grid:ClearGridControl(i, 3)
      local data = grid:GetGridTag(i, 0)
      if nx_is_valid(data) then
        nx_destroy(data)
      end
    end
  end
end
function on_main_form_close(self)
  local grid = self.textgrid_list
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_grid_list", grid)
  end
  clear_grid_data(grid)
  nx_destroy(self)
end
function on_textgrid_list_select_row(self, row, col)
  local data = self:GetGridTag(row, 0)
  if nx_is_valid(data) then
    nx_execute("tips_game", "hide_tip")
    nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "show_type_info", data.TVT_TYPE)
  end
end
function on_textgrid_list_mousein_row_changed(self, new_row, old_row)
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local gui = nx_value("gui")
  nx_execute("tips_game", "hide_tip")
  self:ClearSelect()
  self.Enabled = false
  self:SelectRow(new_row)
  local data = self:GetGridTag(new_row, 0)
  if nx_is_valid(data) then
    local ui_tips = mgr:GetPrizeTips(data.TVT_TYPE)
    local x, y = gui:GetCursorClientPos()
    nx_execute("tips_game", "show_text_tip", nx_widestr(ui_tips), x, y)
  end
  self.Enabled = true
end
function on_textgrid_list_lost_capture(grid)
  grid:ClearSelect()
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_sort_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.groupbox_cbtn.Visible = cbtn.Checked
end
function on_cbtn_tyep_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local cbtns = form.groupbox_cbtn:GetChildControlList()
  local checked_num = 0
  local no_checked_num = 0
  for _, cbtn in pairs(cbtns) do
    if cbtn ~= nil and nx_name(cbtn) == "CheckButton" then
      if cbtn.Checked then
        checked_num = checked_num + 1
      else
        no_checked_num = no_checked_num + 1
      end
    end
  end
  if 0 == checked_num then
    form.cbtn_all.NormalImage = "gui\\common\\checkbutton\\cbtn_5_out.png"
    form.cbtn_all.FocusImage = "gui\\common\\checkbutton\\cbtn_5_on.png"
    form.cbtn_all.CheckedImage = "gui\\common\\checkbutton\\cbtn_5_down.png"
    form.cbtn_all.Checked = false
  elseif 0 < checked_num and 0 < no_checked_num then
    form.cbtn_all.NormalImage = "gui\\common\\checkbutton\\cbtn_7_out.png"
    form.cbtn_all.FocusImage = "gui\\common\\checkbutton\\cbtn_7_on.png"
    form.cbtn_all.CheckedImage = "gui\\common\\checkbutton\\cbtn_7_down.png"
  elseif 0 == no_checked_num then
    form.cbtn_all.NormalImage = "gui\\common\\checkbutton\\cbtn_5_out.png"
    form.cbtn_all.FocusImage = "gui\\common\\checkbutton\\cbtn_5_on.png"
    form.cbtn_all.CheckedImage = "gui\\common\\checkbutton\\cbtn_5_down.png"
    form.cbtn_all.Checked = true
  end
  nx_execute("tips_game", "hide_tip")
  refresh_grid_list(cbtn.ParentForm.textgrid_list)
end
function on_cbtn_all_checked_changed(self)
  local form = self.ParentForm
  form.groupbox_cbtn.Visible = form.groupbox_cbtn.Visible or self.Checked
  local cbtns = form.groupbox_cbtn:GetChildControlList()
  for _, cbtn in pairs(cbtns) do
    if cbtn ~= nil and nx_name(cbtn) == "CheckButton" then
      cbtn.Checked = self.Checked
    end
  end
end
function refresh_grid_list(grid)
  if not nx_is_valid(grid) then
    return
  end
  clear_grid_data(grid)
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local form = grid.ParentForm
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  grid.ColCount = 6
  grid.ColWidths = "40, 100, 100, 220, 110, 90"
  local color_open = "255,255,180,40"
  local color_over = "255,140,140,140"
  local color_all_day = "255,150,204,0"
  local num_over = 0
  local num_all_day = 0
  local num_normal = 0
  for _, tvt_type in pairs(g_tvt_all_type) do
    if mgr:IsInteractOpenToday(tvt_type) and is_need_show(tvt_type) then
      local info = mgr:GetTvtBaseInfo(tvt_type)
      local base_info = get_interact_base_info(tvt_type)
      local tvt_name = info[1]
      local tvt_prize = info[14]
      local tvt_time_t = mgr:GetOpenTimeSection(tvt_type)
      for i = 1, table.getn(tvt_time_t) do
        tvt_time = tvt_time_t[i]
        local tvt_max_times = util_text("wuxianzhi")
        local tvt_aready_times = util_text("wuxianzhi")
        local times = nx_execute("form_stage_main\\form_tvt\\form_tvt_main", "get_tvt_times", tvt_type)
        if times ~= -1 then
          tvt_aready_times = times
        end
        if base_info[3] ~= nil and base_info[3] ~= "0" then
          tvt_max_times = base_info[3]
        end
        local row
        if is_pass(tvt_time) or nx_number(tvt_aready_times) == nx_number(tvt_max_times) and 0 < nx_number(tvt_max_times) then
          row = grid:InsertRow(grid.RowCount)
          num_over = num_over + 1
        elseif is_all_day(tvt_time) then
          row = grid:InsertRow(grid.RowCount - num_over)
          num_all_day = num_all_day + 1
        else
          row = grid:InsertRow(0)
          num_normal = num_normal + 1
        end
        local data = nx_create("ArrayList", nx_current())
        data.TVT_TYPE = tvt_type
        grid:SetGridTag(row, 0, data)
        local gui = nx_value("gui")
        local image_grid = gui:Create("ImageGrid")
        local image = ""
        local image1 = ""
        if tvt_type == ITT_SCHOOLMOOT then
          image = "gui\\language\\ChineseS\\tvt\\lal_7.png"
        end
        if tvt_type == ITT_WORLDWAR_LXC or tvt_type == ITT_KHD then
          local image = ""
          image1 = "gui\\language\\ChineseS\\tvt\\lbl_tuijian.png"
        end
        if tvt_type == ITT_TIGUAN_DANSHUA or tvt_type == ITT_MATCH_RIVERS or tvt_type == ITT_MATCH_SCHOOL then
          image = "gui\\language\\ChineseS\\tvt\\lbl_mingjun.png"
          image1 = "gui\\language\\ChineseS\\tvt\\lbl_tuijian.png"
        end
        image_grid.BackColor = "0,255,255,255"
        image_grid.MouseInColor = "0,255,255,255"
        image_grid.SelectColor = "0,255,255,255"
        image_grid.ClomnNum = 2
        image_grid.FitGrid = false
        image_grid.NoFrame = true
        image_grid.GridHeight = 15
        image_grid.GridWidth = 28
        image_grid.ViewRect = "4,8,64,28"
        image_grid:AddItem(nx_int(0), nx_string(image), "", nx_int(1), nx_int(-1))
        image_grid:AddItem(nx_int(1), nx_string(image1), "", nx_int(1), nx_int(-1))
        grid:SetGridControl(row, 0, image_grid)
        local point_tips_str = "ui_tvt_ActivityPoint_" .. nx_string(tvt_type)
        if gui.TextManager:IsIDName(point_tips_str) then
          local mltbox = gui:Create("MultiTextBox")
          mltbox.Width = 100
          mltbox.Height = 30
          mltbox.TextColor = "255,255,255,255"
          mltbox.Transparent = true
          mltbox.SelectBarColor = "0,0,0,255"
          mltbox.MouseInBarColor = "0,255,255,0"
          mltbox.ViewRect = "16,4,100,30"
          mltbox.LineHeight = 26
          mltbox.LineTextAlign = "Center"
          mltbox.BackColor = "0,255,255,255"
          mltbox.ShadowColor = "0,0,0,0"
          mltbox.Font = "font_main"
          mltbox.NoFrame = true
          mltbox:Clear()
          mltbox:AddHtmlText(util_text(point_tips_str), -1)
          grid:SetGridControl(row, 2, mltbox)
        end
        local tmp_imagegrid = gui:Create("ImageGrid")
        set_copy_ent_info(form, "imagegrid_1", tmp_imagegrid)
        nx_bind_script(tmp_imagegrid, nx_current())
        nx_callback(tmp_imagegrid, "on_mousein_grid", "on_mousein_grid")
        nx_callback(tmp_imagegrid, "on_mouseout_grid", "on_mouseout_grid")
        nx_callback(tmp_imagegrid, "on_select_changed", "on_select_changed")
        tmp_imagegrid:Clear()
        local count = tmp_imagegrid.RowNum * tmp_imagegrid.ClomnNum
        local grid_index = 0
        for i = 1, count do
          if mgr:IsHavePrizeType(nx_int(tvt_type), i - 1) and i - 1 <= table.getn(prize_image_t) then
            local image = prize_image_t[i - 1]
            tmp_imagegrid:AddItem(grid_index, image, "", 1, -1)
            grid_index = grid_index + 1
          end
        end
        grid:SetGridText(row, 1, nx_widestr(tvt_name))
        grid:SetGridControl(row, 3, tmp_imagegrid)
        grid:SetGridText(row, 4, nx_widestr(tvt_time))
        grid:SetGridText(row, 5, nx_widestr(tvt_aready_times) .. nx_widestr("/") .. nx_widestr(tvt_max_times))
        if mgr:IsInteractOpenSection(tvt_type, tvt_time) then
          if is_all_day(tvt_time) then
            grid:SetGridForeColor(row, 1, color_all_day)
            grid:SetGridForeColor(row, 4, color_all_day)
            grid:SetGridForeColor(row, 5, color_all_day)
          else
            grid:SetGridForeColor(row, 1, color_open)
            grid:SetGridForeColor(row, 4, color_open)
            grid:SetGridForeColor(row, 5, color_open)
          end
        end
        if is_pass(tvt_time) or nx_number(tvt_aready_times) == nx_number(tvt_max_times) and 0 < nx_number(tvt_max_times) then
          grid:SetGridForeColor(row, 3, color_over)
          grid:SetGridForeColor(row, 4, color_over)
          grid:SetGridForeColor(row, 5, color_over)
        end
      end
    end
  end
  grid:SortRowsRang(4, grid.RowCount - num_over, grid.RowCount, false)
  grid:SortRowsRang(4, 0, num_normal, false)
  local row = grid:InsertRow(0)
  local info = mgr:GetTvtBaseInfo(ITT_HUASHAN_FIGHTER)
  local base_info = get_interact_base_info(ITT_HUASHAN_FIGHTER)
  local tvt_name = info[1]
  local tvt_prize = info[14]
  local tvt_time = "--"
  local tvt_times = "--/--"
  local data = nx_create("ArrayList", nx_current())
  data.TVT_TYPE = ITT_HUASHAN_FIGHTER
  grid:SetGridTag(row, 0, data)
  local gui = nx_value("gui")
  local image_grid = gui:Create("ImageGrid")
  local image = ""
  local image1 = ""
  image_grid.BackColor = "0,255,255,255"
  image_grid.MouseInColor = "0,255,255,255"
  image_grid.SelectColor = "0,255,255,255"
  image_grid.ClomnNum = 2
  image_grid.FitGrid = false
  image_grid.NoFrame = true
  image_grid.GridHeight = 15
  image_grid.GridWidth = 28
  image_grid.ViewRect = "4,8,64,28"
  image_grid:AddItem(nx_int(0), nx_string(image), "", nx_int(1), nx_int(-1))
  image_grid:AddItem(nx_int(1), nx_string(image1), "", nx_int(1), nx_int(-1))
  grid:SetGridControl(row, 0, image_grid)
  local tmp_imagegrid = gui:Create("ImageGrid")
  set_copy_ent_info(form, "imagegrid_1", tmp_imagegrid)
  nx_bind_script(tmp_imagegrid, nx_current())
  nx_callback(tmp_imagegrid, "on_mousein_grid", "on_mousein_grid")
  nx_callback(tmp_imagegrid, "on_mouseout_grid", "on_mouseout_grid")
  nx_callback(tmp_imagegrid, "on_select_changed", "on_select_changed")
  tmp_imagegrid:Clear()
  tmp_imagegrid:AddItem(nx_int(0), "gui\\language\\ChineseS\\tvt\\icon_2.png", "", 1, -1)
  tmp_imagegrid:AddItem(nx_int(1), "gui\\language\\ChineseS\\tvt\\icon_9.png", "", 1, -1)
  grid:SetGridText(row, 1, nx_widestr(tvt_name))
  grid:SetGridControl(row, 3, tmp_imagegrid)
  grid:SetGridText(row, 4, nx_widestr(tvt_time))
  grid:SetGridText(row, 5, nx_widestr(tvt_times))
  grid:SetGridForeColor(row, 1, color_all_day)
  grid:SetGridForeColor(row, 4, color_all_day)
  grid:SetGridForeColor(row, 5, color_all_day)
  if 1 < grid.RowCount then
    grid.ParentForm.lbl_cover.Visible = false
    grid.ParentForm.lbl_ani.Visible = false
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "refresh_grid_list", grid)
    end
  end
  grid:EndUpdate()
end
function is_all_day(time_str)
  local time_all_dat = "00:00-24:00"
  return time_all_dat == time_str
end
function is_need_show(tvt_type)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  local cbtns = form.groupbox_cbtn:GetChildControlList()
  for _, cbtn in pairs(cbtns) do
    if cbtn ~= nil and nx_name(cbtn) == "CheckButton" and cbtn.Checked then
      local prize_type = nx_int(cbtn.DataSource)
      local is_need = mgr:IsHavePrizeType(nx_int(tvt_type), prize_type)
      if is_need then
        return true
      end
    end
  end
  return false
end
function is_pass(tvt_time)
  local _a, _ = string.find(tvt_time, "-")
  local end_time = string.sub(tvt_time, _a + 1)
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local _, _, _, hour, mins, sec = nx_function("ext_decode_date", cur_date_time)
  if hour < 10 then
    hour = "0" .. hour
  end
  return end_time < hour .. ":" .. mins
end
function on_mousein_grid(imagegrid, index)
  local form = imagegrid.ParentForm
  local grid = form.textgrid_list
  for i = 0, grid.RowCount - 1 do
    local ctrl = grid:GetGridControl(i, 3)
    if nx_id_equal(imagegrid, ctrl) then
      return on_textgrid_list_mousein_row_changed(grid, i)
    end
  end
end
function on_mouseout_grid(imagegrid, index)
  local form = imagegrid.ParentForm
  local grid = form.textgrid_list
  return on_textgrid_list_lost_capture(grid, i)
end
function on_select_changed(imagegrid, index)
  local form = imagegrid.ParentForm
  local grid = form.textgrid_list
  for i = 0, grid.RowCount - 1 do
    local ctrl = grid:GetGridControl(i, 3)
    if nx_id_equal(imagegrid, ctrl) then
      return on_textgrid_list_select_row(grid, i)
    end
  end
end
