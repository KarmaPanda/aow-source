require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("const_define")
require("util_functions")
require("util_gui")
require("tips_data")
local FORM_NAME = "form_stage_main\\form_activity\\form_activity_login"
local ColCount = 7
local array_name = "month_data"
local g_kuang = {
  kuang1 = "gui\\common\\imagegrid\\icon_yqd_qd_1.png",
  kuang2 = "gui\\common\\imagegrid\\icon_yqd_qd_2.png",
  kuang3 = "gui\\common\\imagegrid\\icon_yqd_qd_3.png",
  kuang4 = "gui\\common\\imagegrid\\icon_yqd_qd_4.png"
}
local g_PrizeTips = {
  [0] = "91113",
  [1] = "91114",
  [2] = "91115"
}
function a(msg)
  nx_msgbox(nx_string(msg))
end
function open_form()
  local ST_NORMAL_ACTIVITY_LOGIN = 2017
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_NORMAL_ACTIVITY_LOGIN) then
    return
  end
  local player = get_player()
  sign_count = player:QueryProp("LoginActivityTimes")
  if sign_count == 0 then
    return
  end
  local localtime64 = nx_int64(player:QueryProp("LoginActivityData"))
  if localtime64 <= nx_int64(0) then
    return
  end
  local localtime = nx_function("ext_get_localtime", localtime64)
  local year = nx_int(localtime / 10000)
  local month = nx_int((localtime - year * 10000) / 100)
  local day = nx_int(localtime - year * 10000 - month * 100)
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local cur_year, cur_month, cur_day, cur_hour, cur_mins, cur_sec = nx_function("ext_decode_date", cur_date_time)
  if nx_int(year) ~= nx_int(cur_year) or nx_int(month) ~= nx_int(cur_month) or nx_int(day) ~= nx_int(cur_day) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("91138"), 2)
    end
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.sign_count = sign_count
  nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "add_sub_form", form)
  form.Visible = true
  form:Show()
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function main_form_init(form)
  form.Fixed = true
  form.curr_month = 7
  form.sign_count = 28
  form.selected_day_num = nil
  form.max_day_count = 28
  form.bu_money = 0
  form.bu_times = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", cur_date_time)
  form.curr_month = nx_int(month)
  load_ini(form)
  if form.sign_count > form.max_day_count then
    form.sign_count = form.max_day_count
  end
  show_group_login_num(form)
  form.lbl_title.Text = gui.TextManager:GetFormatText("ui_ydl_title", nx_int(form.curr_month))
  form.cbtn_1.Checked = 1 == load_tips_checked()
  show_sign_anim(form)
  show_total_award(form)
  local gb = form.groupscrollbox_all:Find("groupbox_day" .. nx_string(form.sign_count))
  if nx_is_valid(gb) then
    local gb_btn_bg = gb:Find("btn_bg" .. nx_string(form.sign_count))
    if nx_is_valid(gb_btn_bg) then
      on_btn_bg_click(gb_btn_bg)
    end
  end
  show_end_prize(form)
  form.bu_money = nx_int(get_ini_prop("share\\Activity\\loginprize.ini", "Rule", "BuQianMoney", "0"))
  form.bu_times = nx_int(get_ini_prop("share\\Activity\\loginprize.ini", "Rule", "BuQianTimes", "0"))
  form.mltbox_des.HtmlText = gui.TextManager:GetFormatText("ui_ydl_shuoming_1", form.bu_money, nx_int(form.bu_times))
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_bg_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_selected_kuang(btn)
  show_grid_three_award(btn)
end
function show_selected_kuang(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.selected_day_num ~= nil then
    if form.selected_day_num == btn.day_num then
      return
    end
    local gb = form.groupscrollbox_all:Find("groupbox_day" .. nx_string(form.selected_day_num))
    if nx_is_valid(gb) then
      form.lbl_select_bg.Left = 0
      form.lbl_select_bg.Top = 0
      form.lbl_select_bg.Visible = false
    end
  end
  local gb = form.groupscrollbox_all:Find("groupbox_day" .. nx_string(btn.day_num))
  if nx_is_valid(gb) then
    form.lbl_select_bg.Left = form.groupscrollbox_all.Left + gb.Left + 2
    form.lbl_select_bg.Top = form.groupscrollbox_all.Top + gb.Top
    form.lbl_select_bg.Visible = true
  end
  form.selected_day_num = btn.day_num
end
function on_icg_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(1))
  if nx_widestr(item_config) == nx_widestr("") or nx_widestr(item_config) == nx_widestr("nil") then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", nx_string(item_config), "ItemType", "0")
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_icg_mouseout_grid(grid, index)
  grid:SetSelectItemIndex(-1)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_cbtn_1_checked_changed(cbtn)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\form_signin.ini"
  ini:LoadFromFile()
  ini:WriteInteger(nx_string("LoginChecked"), nx_string("val"), nx_int(cbtn.Checked))
  ini:SaveToFile()
  nx_destroy(ini)
end
function clone_groupbox(source, idx)
  local gui = nx_value("gui")
  local clone = gui:Create("GroupBox")
  clone.AutoSize = source.AutoSize
  clone.Name = source.Name .. nx_string(idx)
  clone.BackColor = source.BackColor
  clone.NoFrame = source.NoFrame
  clone.Left = 0
  clone.Top = 0
  clone.Width = source.Width
  clone.Height = source.Height
  clone.LineColor = source.LineColor
  clone.Transparent = source.Transparent
  clone.TestTrans = source.TestTrans
  clone.DrawMode = source.DrawMode
  return clone
end
function clone_label(source, idx)
  local gui = nx_value("gui")
  local clone = gui:Create("Label")
  clone.ForeColor = source.ForeColor
  clone.Font = source.Font
  clone.NoFrame = source.NoFrame
  clone.Name = source.Name .. nx_string(idx)
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Align = source.Align
  clone.ShadowColor = source.ShadowColor
  clone.Width = source.Width
  clone.Height = source.Height
  clone.Text = source.Text
  clone.TestTrans = source.TestTrans
  clone.BackImage = source.BackImage
  return clone
end
function clone_button(source, idx)
  local gui = nx_value("gui")
  local clone = gui:Create("Button")
  clone.Name = source.Name .. nx_string(idx)
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Align = source.Align
  clone.ShadowColor = source.ShadowColor
  clone.Width = source.Width
  clone.Height = source.Height
  clone.TestTrans = source.TestTrans
  clone.AutoSize = source.AutoSize
  clone.DrawMode = source.DrawMode
  clone.day_num = idx
  nx_bind_script(clone, nx_current())
  nx_callback(clone, "on_click", "on_btn_bg_click")
  return clone
end
function show_group_login_num(form)
  local groupscrollbox_all = form.groupscrollbox_all
  local groupbox_day = form.groupbox_day
  groupscrollbox_all.IsEditMode = true
  for i = 0, form.max_day_count - 1 do
    local col = math.mod(i, ColCount)
    local row = nx_int(i / ColCount)
    local gb = clone_groupbox(groupbox_day, i + 1)
    local gb_label_num = clone_label(form.lbl_num, i + 1)
    local gb_label_sign = clone_label(form.lbl_sign, i + 1)
    local gb_button_bg = clone_button(form.btn_bg, i + 1)
    gb.IsEditMode = true
    gb:Add(gb_button_bg)
    gb:Add(gb_label_sign)
    gb:Add(gb_label_num)
    gb.IsEditMode = false
    groupscrollbox_all:Add(gb)
    gb.Visible = true
    gb.Left = 15 + (gb.Width + 1) * col
    gb.Top = 10 + (gb.Height + 1) * row
  end
  groupscrollbox_all.IsEditMode = false
  local common_array = nx_value("common_array")
  if nx_is_valid(common_array) then
    for i = 1, form.max_day_count do
      local day_info_str = common_array:FindChild(array_name, nx_string(i))
      local day_info_list = util_split_string(day_info_str, ";")
      local gb = groupscrollbox_all:Find("groupbox_day" .. nx_string(i))
      local gb_btn_bg = gb:Find("btn_bg" .. nx_string(i))
      if nx_is_valid(gb_btn_bg) then
        gb_btn_bg.BackImage = g_kuang[day_info_list[1]]
      end
    end
  end
  for i = 1, form.max_day_count do
    local name = "groupbox_day" .. nx_string(i)
    local gb = groupscrollbox_all:Find(name)
    if nx_is_valid(gb) then
      name = "lbl_num" .. nx_string(i)
      local lbl_num = gb:Find(name)
      if nx_is_valid(lbl_num) then
        lbl_num.Text = nx_widestr(i)
      end
      if i == form.max_day_count then
        lbl_num.Text = nx_widestr("...")
      end
      name = "lbl_sign" .. nx_string(i)
      lbl_sign = gb:Find(name)
      if nx_is_valid(lbl_sign) then
        lbl_sign.Visible = false
        if i <= form.sign_count - 1 then
          lbl_sign.Visible = true
        end
      end
    end
  end
end
function show_grid_three_award(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.icg1:Clear()
  form.icg2:Clear()
  form.icg3:Clear()
  local ini = nx_execute("util_functions", "get_ini", "share\\Activity\\loginprizeindex.ini")
  if not nx_is_valid(ini) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local day_info_str = common_array:FindChild(array_name, nx_string(btn.day_num))
  local day_info_list = util_split_string(day_info_str, ";")
  local award_info_str = day_info_list[2]
  show_grid_award(form, ini, award_info_str, 1)
  show_grid_award(form, ini, award_info_str, 2)
  show_grid_award(form, ini, award_info_str, 3)
end
function show_total_award(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\Activity\\loginprizetotal.ini", true)
  if not nx_is_valid(ini) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  local day_sec_index = ini:FindSectionIndex("property")
  local day_count = ini:GetSectionItemCount(day_sec_index)
  local days = {}
  for i = 1, day_count do
    local text = nx_string(ini:GetSectionItemValue(day_sec_index, i - 1))
    local split_text = util_split_string(text, ",")
    local day = nx_int(split_text[1])
    table.insert(days, day)
  end
  local sec_index = ini:FindSectionIndex("client")
  local key_count = ini:GetSectionItemCount(sec_index)
  local award_total_id = {}
  for i = 1, key_count do
    local id = nx_string(ini:GetSectionItemValue(sec_index, i - 1))
    table.insert(award_total_id, id)
  end
  local grid1 = form.ImageControlGrid_total1
  local label1 = form.lbl_day_1
  local offset = 0
  local start_offset = 0
  if day_count <= 1 then
    start_offset = 95
  elseif 5 <= day_count then
    offset = 55
  else
    local total_height = 180
    offset = total_height / (day_count - 1)
  end
  for i = 1, day_count do
    local label_name = "lbl_day_" .. nx_string(i)
    local grid_name = "ImageControlGrid_total" .. nx_string(i)
    local label = form:Find(label_name)
    local grid = form:Find(grid_name)
    local now_offset = (i - 1) * offset + start_offset
    if not nx_is_valid(label) then
      label = gui.Designer:Clone(label1)
      label.Name = label_name
      form:Add(label)
    end
    local day = days[i]
    label.Text = util_format_string("ui_ydl_ljqd_day", nx_int(day))
    label.Left = label1.Left
    label.Top = label1.Top + now_offset
    if not nx_is_valid(grid) then
      grid = gui.Designer:Clone(grid1)
      grid.Name = grid_name
      form:Add(grid)
    end
    grid.Left = grid1.Left
    grid.Top = grid1.Top + now_offset
    nx_bind_script(grid, nx_current())
    nx_callback(grid, "on_mousein_grid", "on_icg_mousein_grid")
    nx_callback(grid, "on_mouseout_grid", "on_icg_mouseout_grid")
    local item_id = award_total_id[i]
    local item_photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
    local item_count = nx_int(1)
    grid:Clear()
    grid:AddItem(0, item_photo, "", item_count, -1)
    grid:SetItemAddInfo(0, nx_int(1), nx_widestr(item_id))
  end
end
function show_grid_award(form, ini, award_info_str, award_id)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local lbl_no_award_tips, img_control_grid, lbl_next_prize, img_next_prize
  if award_id == 1 then
    lbl_no_award_tips = form.lbl_noaward_tips1
    img_control_grid = form.icg1
    lbl_next_prize = nil
    img_next_prize = nil
  elseif award_id == 2 then
    lbl_no_award_tips = form.lbl_noaward_tips2
    img_control_grid = form.icg2
    lbl_next_prize = form.mltbox_desc
    img_next_prize = form.ImageControlGrid4
  elseif award_id == 3 then
    lbl_no_award_tips = form.lbl_noaward_tips3
    img_control_grid = form.icg3
    lbl_next_prize = form.mltbox_1
    img_next_prize = form.ImageControlGrid1
  end
  if nx_is_valid(img_next_prize) and nx_is_valid(lbl_next_prize) then
    img_next_prize:Clear()
    lbl_next_prize.Visible = false
  end
  if not nx_is_valid(lbl_no_award_tips) or not nx_is_valid(img_control_grid) then
    return
  end
  if award_info_str == "" then
    lbl_no_award_tips.Visible = true
    lbl_no_award_tips.Text = gui.TextManager:GetFormatText("ui_yqd_tishi1")
    return
  end
  lbl_no_award_tips.tips_type = -1
  local award_info_list = util_split_string(award_info_str, ",")
  local award = award_info_list[award_id]
  local photo_index = ini:FindSectionIndex("UIcolor_item")
  local sec_index = ini:FindSectionIndex(award)
  local item_count = ini:GetSectionItemCount(sec_index)
  local condition_mgr = nx_value("ConditionManager")
  local client_player = get_player()
  item_count = item_count / 2
  for i = item_count - 1, 0, -1 do
    local condition = ini:GetSectionItemValue(sec_index, 2 * i)
    if condition ~= "" then
      lbl_no_award_tips.tips_type = 0
    end
    if condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(condition)) then
      local drops_str = ini:GetSectionItemValue(sec_index, 1 + 2 * i)
      local drops_list = util_split_string(drops_str, ";")
      for j = 1, table.getn(drops_list) do
        if drops_list[j] ~= "" then
          local drop_id = util_split_string(drops_list[j], ",")
          local item_id = drop_id[1]
          local item_photo = ItemQuery:GetItemPropByConfigID(drop_id[1], "Photo")
          local item_count = nx_int(drop_id[3])
          local bg_photo = ini:ReadString(photo_index, nx_string(drop_id[2]), "")
          img_control_grid.DrawGridBack = nx_string(bg_photo)
          img_control_grid:AddItem(nx_int(j - 1), item_photo, "", item_count, -1)
          img_control_grid:SetItemAddInfo(nx_int(j - 1), nx_int(1), nx_widestr(item_id))
          lbl_no_award_tips.tips_type = 1
        end
      end
      break
    elseif nx_is_valid(img_next_prize) and nx_is_valid(lbl_next_prize) then
      img_next_prize:Clear()
      lbl_next_prize.Visible = false
      local drops_str = ini:GetSectionItemValue(sec_index, 1 + 2 * i)
      local drops_list = util_split_string(drops_str, ";")
      for j = 1, table.getn(drops_list) do
        if drops_list[j] ~= "" then
          local drop_id = util_split_string(drops_list[j], ",")
          local item_id = drop_id[1]
          local item_photo = ItemQuery:GetItemPropByConfigID(drop_id[1], "Photo")
          local item_count = nx_int(drop_id[3])
          img_next_prize:AddItem(nx_int(j - 1), item_photo, "", item_count, -1)
          img_next_prize:SetItemAddInfo(nx_int(j - 1), nx_int(1), nx_widestr(item_id))
          lbl_next_prize.Visible = true
        end
      end
      if award_id == 2 then
        form.mltbox_desc.HtmlText = util_text(g_PrizeTips[i])
      end
    end
  end
  if lbl_no_award_tips.tips_type == -1 then
    lbl_no_award_tips.Visible = true
    lbl_no_award_tips.Text = gui.TextManager:GetFormatText("ui_yqd_tishi1")
  elseif lbl_no_award_tips.tips_type == 1 then
    lbl_no_award_tips.Visible = false
  elseif lbl_no_award_tips.tips_type == 0 then
    lbl_no_award_tips.Visible = true
    if award_id == 1 then
      lbl_no_award_tips.Text = gui.TextManager:GetFormatText("ui_yqd_tishi1")
    elseif award_id == 2 then
      lbl_no_award_tips.Text = gui.TextManager:GetFormatText("ui_yqd_tishi2")
    elseif award_id == 3 then
      lbl_no_award_tips.Text = gui.TextManager:GetFormatText("ui_yqd_tishi3")
    end
  end
end
function show_sign_anim(form)
  local name = "groupbox_day" .. nx_string(form.sign_count)
  local gb = form.groupscrollbox_all:Find(name)
  if nx_is_valid(gb) then
    name = "lbl_sign" .. nx_string(form.sign_count)
    local lbl_sign = gb:Find(name)
    if nx_is_valid(lbl_sign) then
      form.ani_1.Left = form.groupscrollbox_all.Left + gb.Left + lbl_sign.Left
      form.ani_1.Top = form.groupscrollbox_all.Top + gb.Top + lbl_sign.Top
      form.ani_1:Play()
    end
  end
end
function load_ini(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if common_array:FindArray(array_name) then
    common_array:RemoveArray(array_name)
  end
  common_array:AddArray(array_name, form, 60, false)
  local ini = nx_execute("util_functions", "get_ini", "share\\Activity\\loginprize.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("Config")
  local key_index = ini:FindSectionItemIndex(sec_index, "month_" .. nx_string(form.curr_month))
  local month_sec_index = nx_int(ini:GetSectionItemValue(sec_index, key_index))
  sec_index = ini:FindSectionIndex(nx_string(month_sec_index))
  local item_count = ini:GetSectionItemCount(sec_index)
  for i = 1, item_count do
    local day_info_str = ini:GetSectionItemValue(sec_index, i - 1)
    common_array:AddChild(array_name, nx_string(i), nx_string(day_info_str))
  end
  form.month_index = month_sec_index
  form.max_day_count = item_count
end
function is_need_tips()
  if 1 == load_tips_checked() then
    local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
    if not nx_is_valid(form) then
      return
    end
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "on_update_time_open_form", form)
    timer:Register(5000, 1, nx_current(), "on_update_time_open_form", form, -1, -1)
  end
end
function load_tips_checked()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return 0
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local rst = 0
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\form_signin.ini"
    if ini:LoadFromFile() then
      rst = ini:ReadInteger(nx_string("LoginChecked"), nx_string("val"), 0)
    end
  end
  nx_destroy(ini)
  return rst
end
function on_update_time_open_form(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time_open_form", form)
  local stage_main_flag = nx_value("stage_main")
  if nx_string(stage_main_flag) == nx_string("success") then
    nx_execute("form_stage_main\\form_activity\\form_activity_login", "open_form")
  end
end
function show_end_prize(form)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Activity\\loginprizeindex.ini")
  if not nx_is_valid(ini) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  form.ImageControlGrid2:Clear()
  local gui = nx_value("gui")
  form.lbl_9.Text = gui.TextManager:GetFormatText("ui_ydl_dajiang", nx_int(form.max_day_count - 1))
  local day_info_str = common_array:FindChild(array_name, nx_string(form.max_day_count - 1))
  local day_info_list = util_split_string(day_info_str, ";")
  local award_info_list = util_split_string(day_info_list[2], ",")
  local sec_index = ini:FindSectionIndex(award_info_list[3])
  local item_count = ini:GetSectionItemCount(sec_index)
  item_count = item_count / 2
  for i = item_count - 1, 0, -1 do
    local drops_str = ini:GetSectionItemValue(sec_index, 1 + 2 * i)
    local drops_list = util_split_string(drops_str, ";")
    for j = 1, table.getn(drops_list) do
      if drops_list[j] ~= "" then
        local drop_id = util_split_string(drops_list[j], ",")
        local item_id = drop_id[1]
        local item_photo = ItemQuery:GetItemPropByConfigID(drop_id[1], "Photo")
        local item_count = nx_int(drop_id[3])
        form.ImageControlGrid2:AddItem(nx_int(j - 1), item_photo, "", item_count, -1)
        form.ImageControlGrid2:SetItemAddInfo(nx_int(j - 1), nx_int(1), nx_widestr(item_id))
      end
    end
  end
end
function on_btn_bu_qian_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not can_bu_qian(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("91151", nx_int(form.bu_money))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_request_login")
  end
end
function can_bu_qian(form)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return false
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  local sign_count = player:QueryProp("LoginActivityTimes")
  local all_times = 31 + form.bu_times
  if nx_int(sign_count) >= nx_int(all_times) then
    SystemCenterInfo:ShowSystemCenterInfo(util_text("91167"), 2)
    return false
  end
  local localtime64 = nx_int64(player:QueryProp("LoginActivityData"))
  if localtime64 <= nx_int64(0) then
    return false
  end
  local localtime = nx_function("ext_get_localtime", localtime64)
  local year = nx_int(localtime / 10000)
  local month = nx_int((localtime - year * 10000) / 100)
  local day = nx_int(localtime - year * 10000 - month * 100)
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return false
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local cur_year, cur_month, cur_day, cur_hour, cur_mins, cur_sec = nx_function("ext_decode_date", cur_date_time)
  if nx_int(year) ~= nx_int(cur_year) or nx_int(month) ~= nx_int(cur_month) or nx_int(day) ~= nx_int(cur_day) then
    SystemCenterInfo:ShowSystemCenterInfo(util_text("91138"), 2)
    return false
  end
  return true
end
