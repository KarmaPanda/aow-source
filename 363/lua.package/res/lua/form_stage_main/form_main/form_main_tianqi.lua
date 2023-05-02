require("util_functions")
require("util_gui")
function main_form_init(self)
end
function on_main_form_open(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function show_all_tianqi(info, first, second)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_tianqi", true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local list = util_split_string(info, ";")
  local list1 = util_split_string(first, ";")
  local list2 = util_split_string(second, ";")
  if table.getn(list) ~= table.getn(list1) or table.getn(list) ~= table.getn(list2) then
    return
  end
  local info_num = table.getn(list)
  for i = 1, info_num do
    local label = nx_custom(form, "lbl_today_" .. nx_string(i))
    if nx_is_valid(label) then
      if nx_string(list[i]) ~= "0" then
        label.BackImage = "gui\\map\\weather\\tianqi_" .. nx_string(list[i]) .. ".png"
        label.HintText = gui.TextManager:GetText("tips_wreather_map_" .. nx_string(list[i]))
      else
        label.BackImage = "gui\\map\\weather\\tianqi_nothing.png"
        label.HintText = gui.TextManager:GetText("ui_weather_nothing")
      end
    end
    local grid1 = nx_custom(form, "imagegrid_tomorrow_" .. nx_string(i))
    add_tianqi_info(grid1, list1[i])
    local grid2 = nx_custom(form, "imagegrid_after_tomorrow_" .. nx_string(i))
    add_tianqi_info(grid2, list2[i])
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_is_valid(form_map) then
    local ret = form_map:Add(form)
    form.AbsLeft = form_map.lbl_back.AbsLeft
    form.AbsTop = form_map.lbl_back.AbsTop
    if form_map.watched_area == "jiangnan" then
      form.rbtn_jiannan.Checked = true
    elseif form_map.watched_area == "xinan" then
      form.rbtn_xinan.Checked = true
    elseif form_map.watched_area == "xibei" then
      form.rbtn_xibei.Checked = true
    elseif form_map.watched_area == "huabei" then
      form.rbtn_huabei.Checked = true
    elseif form_map.watched_area == "zhongyuan" then
      form.rbtn_zhongyuan.Checked = true
    end
  end
end
function add_tianqi_info(grid, info)
  if info == "" or info == nil then
    return
  end
  if nx_is_valid(grid) then
    grid:Clear()
    local var = util_split_string(info, ",")
    if table.getn(var) == 2 then
      if var[1] ~= "0" then
        grid:AddItem(0, "gui\\map\\weather\\tianqi_" .. nx_string(var[1]) .. ".png", nx_widestr(""), 1, -1)
      elseif var[1] == "0" then
        grid:AddItem(0, "gui\\map\\weather\\tianqi_nothing.png", nx_widestr(""), 1, -1)
      end
      if var[2] ~= "0" then
        grid:AddItem(1, "gui\\map\\weather\\tianqi_" .. nx_string(var[2]) .. ".png", nx_widestr(""), 1, -1)
      elseif var[2] == "0" then
        grid:AddItem(1, "gui\\map\\weather\\tianqi_nothing.png", nx_widestr(""), 1, -1)
      end
    elseif table.getn(var) == 1 then
      if var[1] ~= "0" then
        grid:AddItem(0, "gui\\map\\weather\\tianqi_" .. nx_string(var[1]) .. ".png", nx_widestr(""), 1, -1)
      elseif var[1] == "0" then
        grid:AddItem(0, "gui\\map\\weather\\tianqi_nothing.png", nx_widestr(""), 1, -1)
      end
    end
  end
end
function on_rbtn_xinan_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  form.groupbox_xinanweather.Visible = true
  form.groupbox_huabeiweather.Visible = false
  form.groupbox_jiangnanweather.Visible = false
  form.groupbox_xibeiweather.Visible = false
  form.groupbox_zhongyuanweather.Visible = false
end
function on_rbtn_xibei_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  form.groupbox_xinanweather.Visible = false
  form.groupbox_huabeiweather.Visible = false
  form.groupbox_jiangnanweather.Visible = false
  form.groupbox_xibeiweather.Visible = true
  form.groupbox_zhongyuanweather.Visible = false
end
function on_rbtn_huabei_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  form.groupbox_xinanweather.Visible = false
  form.groupbox_huabeiweather.Visible = true
  form.groupbox_jiangnanweather.Visible = false
  form.groupbox_xibeiweather.Visible = false
  form.groupbox_zhongyuanweather.Visible = false
end
function on_rbtn_zhongyuan_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  form.groupbox_xinanweather.Visible = false
  form.groupbox_huabeiweather.Visible = false
  form.groupbox_jiangnanweather.Visible = false
  form.groupbox_xibeiweather.Visible = false
  form.groupbox_zhongyuanweather.Visible = true
end
function on_rbtn_jiannan_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  form.groupbox_xinanweather.Visible = false
  form.groupbox_huabeiweather.Visible = false
  form.groupbox_jiangnanweather.Visible = true
  form.groupbox_xibeiweather.Visible = false
  form.groupbox_zhongyuanweather.Visible = false
end
