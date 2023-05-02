require("util_gui")
require("util_functions")
require("tips_data")
require("form_stage_main\\form_dbomall\\dbomall_define")
local FORM_NAME = "form_stage_main\\form_dbomall\\form_dboguild"
local ARRAY_NAME_PREFIX = "COMMON_ARRAY_DBOGUILD_"
local ARRAY_NAME_REC_P = "COMMON_ARRAY_DBOGUILD_REC_P"
local ARRAY_NAME_REC_G = "COMMON_ARRAY_DBOGUILD_REC_G"
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.sec_count = 0
  load_ini(form)
  form.textgrid_1:SetColTitle(0, util_text("ui_dbomal_titl1_1"))
  form.textgrid_1:SetColTitle(1, util_text("ui_dbomal_titl1_2"))
  form.textgrid_1:SetColTitle(2, util_text("ui_dbomal_titl1_3"))
  form.textgrid_1:SetColTitle(3, util_text("ui_dbomal_titl1_4"))
  form.textgrid_1:SetColTitle(4, util_text("ui_dbomal_titl1_5"))
  form.textgrid_1:SetColTitle(5, util_text("ui_dbomal_titl1_6"))
  form.textgrid_1:SetColTitle(6, util_text("ui_dbomal_titl1_7"))
  form.textgrid_1:SetColTitle(7, util_text("ui_dbomal_titl1_8"))
  form.textgrid_1:SetColTitle(8, util_text("ui_dbomal_titl1_9"))
  nx_execute("custom_sender", "custom_dbomall_request", DMC_SUBMSG_GUILD_AUTH_SEE)
  nx_execute("custom_sender", "custom_dbomall_request", DMC_SUBMSG_GUILD_AUTH_SEE_MEMBER)
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
  form.rbtn_1.Checked = true
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", form)
  end
  nx_destroy(form)
end
function on_update_time(form)
  for i = 0, form.gsb_1:GetChildControlCount() do
    local gb = form.gsb_1:GetChildControlByIndex(i)
    if nx_is_valid(gb) then
      local lbl_time = gb:Find("lbl_time_" .. nx_string(i + 1))
      if nx_find_custom(lbl_time, "seconds") and 0 < lbl_time.seconds then
        local seconds = lbl_time.seconds
        seconds = seconds - 1
        lbl_time.seconds = seconds
        lbl_time.Text = nx_widestr(get_time_text(seconds))
      end
    end
  end
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  form:Show()
  form.Visible = true
end
function on_rbtn_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_rbtn1.Visible = true
    form.gb_rbtn2.Visible = false
  end
end
function on_rbtn_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_rbtn1.Visible = false
    form.gb_rbtn2.Visible = true
  end
end
function on_btn_1_click(btn)
  nx_execute("custom_sender", "custom_dbomall_request", DMC_SUBMSG_GUILD_AUTH, nx_int(btn.index))
end
function on_btn_2_click(btn)
  nx_execute("custom_sender", "custom_dbomall_request", DMC_SUBMSG_GUILD_AUTH_L, nx_int(btn.index))
end
function on_ig_mousein_grid(grid, index)
  if not nx_find_custom(grid, "config") then
    return
  end
  local config = grid.config
  local count = grid.count
  local prop_array = {}
  prop_array.ConfigID = nx_string(config)
  prop_array.Amount = nx_int(count)
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList")
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_ig_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function update_auth(open_days, info)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local common_array = nx_value("common_array")
  local condition_mgr = nx_value("ConditionManager")
  local client_player = get_player()
  local guild_name = client_player:QueryProp("GuildName")
  local info_list = util_split_wstring(info, ",")
  local is_leader = info_list[1]
  local row_p = info_list[2]
  local info_index = 2
  local array_rec_p = get_array_name_rec_p()
  common_array:RemoveArray(array_rec_p)
  common_array:AddArray(array_rec_p, form, 600, true)
  for i = 1, nx_number(row_p) do
    local index = info_list[info_index + i]
    common_array:AddChild(array_rec_p, nx_string(index), 1)
  end
  info_index = info_index + nx_number(row_p)
  local row_g = info_list[info_index + 1]
  info_index = info_index + 1
  for i = 1, nx_number(row_g) do
    local index = nx_number(info_list[info_index + (i - 1) * 3 + 1])
    local nums = nx_number(info_list[info_index + (i - 1) * 3 + 2])
    local sign = nx_number(info_list[info_index + (i - 1) * 3 + 3])
    local array_rec_g = get_array_name_rec_g(index)
    common_array:RemoveArray(array_rec_g)
    common_array:AddArray(array_rec_g, form, 600, true)
    common_array:AddChild(array_rec_g, "nums", nums)
    common_array:AddChild(array_rec_g, "sign", sign)
  end
  form.gsb_1.IsEditMode = true
  form.gsb_1:DeleteAll()
  for i = 1, form.sec_count do
    local array_name = get_array_name(i)
    local days = common_array:FindChild(array_name, "days")
    local auth_min = common_array:FindChild(array_name, "auth_min")
    local condition_p = common_array:FindChild(array_name, "condition_p")
    local condition_l = common_array:FindChild(array_name, "condition_l")
    local award_p = common_array:FindChild(array_name, "award_p")
    local award_l = common_array:FindChild(array_name, "award_l")
    local lbl_1_text = common_array:FindChild(array_name, "lbl_1")
    local lbl_time, lbl_1, pbar, lbl_bg1, lbl_bg2, ig_1, ig_2, btn_1, btn_2
    if open_days <= days then
      local gb = create_ctrl("GroupBox", "gb_" .. nx_string(i), form.gb_mod1, form.gsb_1)
      lbl_time = create_ctrl("Label", "lbl_time_" .. nx_string(i), form.lbl_m1_time, gb)
      lbl_1 = create_ctrl("Label", "lbl_1_" .. nx_string(i), form.lbl_m1_1, gb)
      pbar = create_ctrl("ProgressBar", "pbar_" .. nx_string(i), form.pbar_m1, gb)
      lbl_bg1 = create_ctrl("Label", "lbl_bg1_" .. nx_string(i), form.lbl_m1_bg1, gb)
      lbl_bg2 = create_ctrl("Label", "lbl_bg2_" .. nx_string(i), form.lbl_m1_bg2, gb)
      ig_1 = create_ctrl("ImageGrid", "ig_1_" .. nx_string(i), form.ig_m1_1, gb)
      ig_2 = create_ctrl("ImageGrid", "ig_2_" .. nx_string(i), form.ig_m1_2, gb)
      btn_1 = create_ctrl("Button", "btn_1_" .. nx_string(i), form.btn_m1_1, gb)
      btn_2 = create_ctrl("Button", "btn_2_" .. nx_string(i), form.btn_m1_2, gb)
      local year, month, day, hour, min, sec = nx_function("ext_decode_date", get_sys_time())
      local seconds = 86400 - (hour * 3600 + min * 60 + sec) + (days - open_days) * 24 * 3600
      lbl_time.seconds = seconds
      lbl_time.Text = nx_widestr(get_time_text(seconds))
    else
      local gb = create_ctrl("GroupBox", "gb_" .. nx_string(i), form.gb_mod2, form.gsb_1)
      lbl_time = create_ctrl("Label", "lbl_time_" .. nx_string(i), form.lbl_m2_time, gb)
      lbl_1 = create_ctrl("Label", "lbl_1_" .. nx_string(i), form.lbl_m2_1, gb)
      pbar = create_ctrl("ProgressBar", "pbar_" .. nx_string(i), form.pbar_m2, gb)
      lbl_bg1 = create_ctrl("Label", "lbl_bg1_" .. nx_string(i), form.lbl_m2_bg1, gb)
      lbl_bg2 = create_ctrl("Label", "lbl_bg2_" .. nx_string(i), form.lbl_m2_bg2, gb)
      ig_1 = create_ctrl("ImageGrid", "ig_1_" .. nx_string(i), form.ig_m2_1, gb)
      ig_2 = create_ctrl("ImageGrid", "ig_2_" .. nx_string(i), form.ig_m2_2, gb)
      btn_1 = create_ctrl("Button", "btn_1_" .. nx_string(i), form.btn_m2_1, gb)
      btn_2 = create_ctrl("Button", "btn_2_" .. nx_string(i), form.btn_m2_2, gb)
    end
    lbl_1.Text = nx_widestr(util_text(lbl_1_text))
    local b_auth_p = common_array:FindChild(array_rec_p, nx_string(i))
    if b_auth_p == 1 then
      btn_1.Text = nx_widestr(util_text("ui_dboguild_yirenzheng"))
      btn_1.Enabled = false
    elseif condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(condition_p)) then
      btn_1.Enabled = true
      btn_1.index = i
      nx_bind_script(btn_1, nx_current())
      nx_callback(btn_1, "on_click", "on_btn_1_click")
    else
      btn_1.Enabled = false
    end
    local nums = common_array:FindChild(get_array_name_rec_g(i), "nums")
    local sign = common_array:FindChild(get_array_name_rec_g(i), "sign")
    if nums ~= nil then
      if nx_number(sign) == 1 then
        btn_2.Text = nx_widestr(util_text("ui_dboguild_yirenzheng"))
        btn_2.Enabled = false
      elseif nx_number(nums) >= nx_number(auth_min) and condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(condition_l)) then
        btn_2.Enabled = true
        btn_2.index = i
        nx_bind_script(btn_2, nx_current())
        nx_callback(btn_2, "on_click", "on_btn_2_click")
      else
        btn_2.Enabled = false
      end
    else
      btn_2.Enabled = false
    end
    if nx_widestr(guild_name) == nx_widestr("") or open_days > days then
      btn_1.Enabled = false
      btn_2.Enabled = false
    end
    if nx_number(is_leader) == 0 then
      btn_2.Enabled = false
    end
    pbar.Maximum = auth_min
    if nums ~= nil then
      pbar.Value = nums
    end
    ig_1.config = award_p
    ig_1.count = 1
    nx_bind_script(ig_1, nx_current())
    nx_callback(ig_1, "on_mousein_grid", "on_ig_mousein_grid")
    nx_callback(ig_1, "on_mouseout_grid", "on_ig_mouseout_grid")
    local photo = get_prop_in_ItemQuery(award_p, nx_string("Photo"))
    ig_1:AddItem(0, nx_string(photo), nx_widestr(award_p), nx_int(1), 0)
    ig_2.config = award_l
    ig_2.count = 1
    nx_bind_script(ig_2, nx_current())
    nx_callback(ig_2, "on_mousein_grid", "on_ig_mousein_grid")
    nx_callback(ig_2, "on_mouseout_grid", "on_ig_mouseout_grid")
    local photo = get_prop_in_ItemQuery(award_l, nx_string("Photo"))
    ig_2:AddItem(0, nx_string(photo), nx_widestr(award_l), nx_int(1), 0)
  end
  form.gsb_1.IsEditMode = false
  form.gsb_1:ResetChildrenYPos()
end
function update_auth_member(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local cols = nx_number(arg[1])
  local rows = nx_number(arg[2])
  local arg_index = 2
  form.textgrid_1:ClearRow()
  for i = 1, rows do
    local info = nx_widestr(arg[arg_index + i])
    local info_list = util_split_wstring(info, ",")
    local player_name = info_list[1]
    local row = form.textgrid_1:InsertRow(-1)
    form.textgrid_1:SetGridText(row, 0, nx_widestr(player_name))
    for j = 1, cols do
      local p = info_list[1 + j]
      form.textgrid_1:SetGridText(row, j, nx_widestr(util_text("ui_dbomal_prize_" .. nx_string(p))))
    end
  end
end
function get_array_name(index)
  return ARRAY_NAME_PREFIX .. nx_string(index)
end
function get_array_name_rec_p()
  return ARRAY_NAME_REC_P
end
function get_array_name_rec_g(index)
  return ARRAY_NAME_REC_G .. nx_string(index)
end
function load_ini(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Activity\\guild_auth.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:GetSectionCount()
  for i = 0, nx_number(sec_count) - 1 do
    local sec = nx_int(ini:GetSectionByIndex(i))
    local array_name = get_array_name(sec)
    common_array:RemoveArray(array_name)
    common_array:AddArray(array_name, form, 600, true)
    local days = ini:ReadInteger(i, "days", 0)
    local auth_min = ini:ReadInteger(i, "auth_min", 0)
    local condition_p = ini:ReadInteger(i, "condition_p", 0)
    local condition_l = ini:ReadInteger(i, "condition_l", 0)
    local award_p = ini:ReadString(i, "award_p", "")
    local award_l = ini:ReadString(i, "award_l", "")
    local lbl_1 = ini:ReadString(i, "lbl_1", "")
    common_array:AddChild(array_name, "days", days)
    common_array:AddChild(array_name, "auth_min", auth_min)
    common_array:AddChild(array_name, "condition_p", condition_p)
    common_array:AddChild(array_name, "condition_l", condition_l)
    common_array:AddChild(array_name, "award_p", award_p)
    common_array:AddChild(array_name, "award_l", award_l)
    common_array:AddChild(array_name, "lbl_1", lbl_1)
  end
  form.sec_count = sec_count
end
function get_time_text(seconds)
  local day = math.floor(nx_number(seconds) / 86400)
  local hour = math.floor(nx_number(seconds) % 86400 / 3600)
  local min = math.floor(nx_number(seconds) % 86400 % 3600 / 60)
  return nx_string(get_format_text("ui_dboguild_seconds_text", nx_int(day), nx_int(hour), nx_int(min)))
end
function get_format_text(stringid, param1, param2, param3, param4, param5, param6)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName(nx_string(stringid))
  if nil ~= param1 then
    gui.TextManager:Format_AddParam(param1)
  end
  if nil ~= param2 then
    gui.TextManager:Format_AddParam(param2)
  end
  if nil ~= param3 then
    gui.TextManager:Format_AddParam(param3)
  end
  if nil ~= param4 then
    gui.TextManager:Format_AddParam(param4)
  end
  if nil ~= param5 then
    gui.TextManager:Format_AddParam(param5)
  end
  if nil ~= param6 then
    gui.TextManager:Format_AddParam(param6)
  end
  return nx_widestr(gui.TextManager:Format_GetText())
end
function get_sys_time()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  return nx_double(msg_delay:GetServerDateTime())
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function a(info)
  nx_msgbox(nx_string(info))
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
