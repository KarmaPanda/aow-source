require("util_gui")
require("util_functions")
require("tips_data")
local FORM_NAME = "form_stage_main\\form_world_auction\\form_world_auction_see_boss"
local ARRAY_NAME_DROP = "COMMON_ARRAY_WA_DROP_"
local color = {
  [1] = {
    "255,201,88,81",
    "ui_auction_1"
  },
  [2] = {
    "255,152,160,205",
    "ui_auction_2"
  },
  [3] = {
    "255,186,151,114",
    "ui_auction_3"
  },
  [4] = {
    "255,153,153,153",
    "ui_auction_4"
  },
  [5] = {
    "255,233,192,80",
    "ui_auction_5"
  },
  [6] = {
    "255,163,202,68",
    "ui_auction_6"
  }
}
local fore_color_you = "255,10,255,0"
local fore_color_other = "255,255,255,255"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.sl_drop = ""
  for i = 1, 10 do
    local rbtn = self.gb_rbtn:Find("rbtn_" .. nx_string(i))
    rbtn.Visible = false
  end
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_time", self, -1, -1)
  timer:Register(10000, -1, nx_current(), "on_time_custom", self, -1, -1)
  nx_execute("custom_sender", "custom_world_auction", 1)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", self)
    timer:UnRegister(nx_current(), "on_time_custom", self)
  end
  nx_destroy(self)
end
function on_main_form_shut(self)
end
function on_update_time(form)
  for i = 0, form.gsb_boss:GetChildControlCount() do
    local gb = form.gsb_boss:GetChildControlByIndex(i)
    if nx_is_valid(gb) then
      local lbl_time = gb:Find("lbl_time_" .. nx_string(gb.auction_uid))
      local end_time = lbl_time.end_time
      local time = nx_number(get_remain_time(end_time))
      if 0 < time then
        time = time - 1
        lbl_time.time = time
        lbl_time.Text = get_time_text(time)
        if time == 0 then
          nx_execute("custom_sender", "custom_world_auction", 1)
          return
        end
      end
    end
  end
end
function on_time_custom(form)
  nx_execute("custom_sender", "custom_world_auction", 1)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_ig_mousein_grid(grid, index)
  if not nx_find_custom(grid, "config") then
    return
  end
  local config = grid.config
  local count = grid.count
  local bind = grid.bind
  local prop_array = {}
  prop_array.ConfigID = nx_string(config)
  prop_array.Amount = nx_int(count)
  prop_array.BindStatus = nx_int(bind)
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
function open_or_close()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
    return
  end
  form:Close()
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    if not nx_find_custom(rbtn, "drop_uid") then
      return
    end
    set_sl_drop(form, rbtn.drop_uid)
    show_info(form)
    form.lbl_2.BackImage = "gui\\special\\world_auction\\" .. nx_string(rbtn.npc_config) .. ".png"
  end
end
function update_boss(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local info_nums = nx_number(arg[1])
  local info = nx_widestr(arg[2])
  if info_nums <= 0 then
    return
  end
  local info_list = util_split_wstring(info, ";")
  local index = 0
  local old_sl = form.sl_drop
  for i = 1, 10 do
    local rbtn = form.gb_rbtn:Find("rbtn_" .. nx_string(i))
    rbtn.Visible = false
  end
  set_sl_drop(form, "")
  form.gsb_boss.IsEditMode = true
  form.gsb_boss:DeleteAll()
  for i = 1, info_nums do
    local drop_uid = nx_string(info_list[index + 1])
    local npc_config = nx_string(info_list[index + 2])
    local captain = nx_widestr(info_list[index + 3])
    local member_nums = nx_number(info_list[index + 4])
    local drop_time = nx_double(info_list[index + 5])
    local item_nums = nx_number(info_list[index + 6])
    index = index + 6
    local common_array = nx_value("common_array")
    common_array:RemoveArray(get_array_name(drop_uid))
    common_array:AddArray(get_array_name(drop_uid), form, 600, true)
    common_array:AddChild(get_array_name(drop_uid), "drop_uid", drop_uid)
    common_array:AddChild(get_array_name(drop_uid), "npc_config", npc_config)
    common_array:AddChild(get_array_name(drop_uid), "captain", captain)
    common_array:AddChild(get_array_name(drop_uid), "member_nums", member_nums)
    local rbtn = form.gb_rbtn:Find("rbtn_" .. nx_string(i))
    rbtn.Visible = true
    rbtn.Text = nx_widestr(util_text(npc_config))
    rbtn.npc_config = npc_config
    rbtn.drop_uid = drop_uid
    if drop_uid == old_sl then
      rbtn.Checked = true
      set_sl_drop(form, rbtn.drop_uid)
    end
    for j = 1, item_nums do
      local item_info = nx_widestr(info_list[index + j])
      local item_list = util_split_wstring(item_info, ",")
      local auction_uid = nx_string(item_list[1])
      local item_config = nx_string(item_list[2])
      local item_amount = nx_number(item_list[3])
      local bind = nx_number(item_list[4])
      local price = nx_number(item_list[5])
      local competer = nx_widestr(item_list[6])
      local end_time = nx_double(item_list[7])
      local time2 = 0
      if end_time <= get_sys_time() then
        time2 = nx_double(item_list[8])
      end
      gsb_boss_add(form, drop_uid, auction_uid, item_config, item_amount, bind, price, competer, end_time, time2)
    end
    index = index + item_nums
  end
  form.gsb_boss.IsEditMode = false
  form.gsb_boss:ResetChildrenYPos()
  if form.sl_drop == "" then
    form.rbtn_1.Checked = true
  end
  show_info(form)
end
function show_info(form)
  local drop_uid = form.sl_drop
  if drop_uid == "" then
    return
  end
  form.gsb_boss.IsEditMode = true
  local show_nums = form.gsb_boss:GetChildControlCount()
  local price_total = 0
  for i = 0, form.gsb_boss:GetChildControlCount() do
    local gb = form.gsb_boss:GetChildControlByIndex(i)
    if nx_is_valid(gb) then
      local auction_uid = gb.auction_uid
      gb.Visible = true
      if gb.drop_uid ~= drop_uid then
        gb.Visible = false
        show_nums = show_nums - 1
      else
        local lbl_price = gb:Find("lbl_price_" .. nx_string(auction_uid))
        local lbl_competer = gb:Find("lbl_competer_" .. nx_string(auction_uid))
        if nx_widestr(lbl_competer.Text) ~= nx_widestr(util_text("world_auction_none")) and nx_widestr(lbl_competer.Text) ~= nx_widestr("") then
          price_total = price_total + nx_number(lbl_price.price)
        end
      end
    end
  end
  form.gsb_boss:ResetChildrenYPos()
  form.gsb_boss.IsEditMode = false
  local common_array = nx_value("common_array")
  local captain = common_array:FindChild(get_array_name(drop_uid), "captain")
  local member_nums = common_array:FindChild(get_array_name(drop_uid), "member_nums")
  local price_pre = math.floor(price_total / member_nums)
  form.lbl_captain.Text = nx_widestr(captain)
  form.lbl_member_nums.Text = nx_widestr(member_nums)
  if price_pre ~= 0 then
    form.lbl_money.HtmlText = get_money_text(price_pre)
  else
    form.lbl_money.HtmlText = nx_widestr(util_text("world_auction_037"))
  end
end
function gsb_boss_add(form, drop_uid, auction_uid, item_config, item_amount, bind, price, competer, end_time, time2)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = client_player:QueryProp("Name")
  local gb = create_ctrl("GroupBox", "gb_" .. nx_string(auction_uid), form.gb_mod, form.gsb_boss)
  if nx_is_valid(gb) then
    gb.auction_uid = nx_string(auction_uid)
    gb.drop_uid = nx_string(drop_uid)
    local ig = create_ctrl("ImageGrid", "ig_item_" .. nx_string(auction_uid), form.ig, gb)
    ig.config = item_config
    ig.count = item_amount
    ig.bind = bind
    nx_bind_script(ig, nx_current())
    nx_callback(ig, "on_mousein_grid", "on_ig_mousein_grid")
    nx_callback(ig, "on_mouseout_grid", "on_ig_mouseout_grid")
    local lbl_bind = create_ctrl("Label", "lbl_bind_" .. nx_string(auction_uid), form.lbl_bind, gb)
    if nx_int(bind) == nx_int(1) then
      lbl_bind.Visible = true
    else
      lbl_bind.Visible = false
    end
    local lbl_name = create_ctrl("Label", "lbl_name_" .. nx_string(auction_uid), form.lbl_name, gb)
    local lbl_competer = create_ctrl("Label", "lbl_competer_" .. nx_string(auction_uid), form.lbl_competer, gb)
    local lbl_price = create_ctrl("MultiTextBox", "lbl_price_" .. nx_string(auction_uid), form.lbl_price, gb)
    local lbl_time = create_ctrl("Label", "lbl_time_" .. nx_string(auction_uid), form.lbl_time, gb)
    local lbl_time2 = create_ctrl("Label", "lbl_time2_" .. nx_string(auction_uid), form.lbl_time2, gb)
    local mltbox_price = create_ctrl("MultiTextBox", "mltbox_1_price_" .. nx_string(auction_uid), form.mltbox_price, gb)
    local lbl_p1 = create_ctrl("Label", "lbl_playername1_" .. nx_string(auction_uid), form.lbl_playername1, gb)
    local lbl_p2 = create_ctrl("Label", "lbl_playername2_" .. nx_string(auction_uid), form.lbl_playername2, gb)
    local color_level = nx_number(get_prop_in_ItemQuery(item_config, nx_string("ColorLevel")))
    local photo = get_prop_in_ItemQuery(item_config, nx_string("Photo"))
    ig:AddItem(0, nx_string(photo), nx_widestr(item_config), nx_int(count), 0)
    lbl_name.Text = util_text(item_config)
    lbl_name.ForeColor = color[color_level][1]
    lbl_competer.Text = nx_widestr(competer)
    if nx_widestr(competer) == nx_widestr(self_name) then
      lbl_competer.ForeColor = fore_color_you
    else
      lbl_competer.ForeColor = fore_color_other
    end
    lbl_price.HtmlText = nx_widestr(get_money_text(price))
    lbl_price.price = price
    lbl_time.Text = get_time_text(get_remain_time(end_time))
    lbl_time.end_time = end_time
    lbl_time2.Text = nx_widestr(decode_time(time2))
    if time2 == 0 then
      lbl_time.Visible = true
      lbl_time2.Visible = false
      lbl_p1.Visible = true
      lbl_p2.Visible = false
      if nx_widestr(competer) == nx_widestr("") then
        lbl_competer.Text = nx_widestr(util_text("world_auction_none"))
      end
    else
      lbl_time.Visible = false
      lbl_time2.Visible = true
      lbl_p1.Visible = false
      lbl_p2.Visible = true
      if nx_widestr(competer) == nx_widestr("") then
        lbl_competer.Text = nx_widestr(util_text("world_auction_none"))
        lbl_price.HtmlText = nx_widestr(util_text("world_auction_price_none"))
      end
    end
  end
end
function set_sl_drop(form, drop_uid)
  form.sl_drop = drop_uid
end
function get_money_text(price)
  local ding = math.floor(nx_number(price) / 1000000)
  local liang = math.floor(nx_number(price) % 1000000 / 1000)
  local wen = math.floor(nx_number(price) % 1000)
  local gui = nx_value("gui")
  local htmlTextYinKa = nx_widestr("")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(ding) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(liang) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(wen) .. nx_widestr(htmlText)
  end
  if nx_number(price) == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr("0") .. nx_widestr(htmlText)
  end
  return htmlTextYinKa
end
function get_time_text(time)
  local hour = math.floor(nx_number(time) / 3600)
  local minute = math.floor(nx_number(time) % 3600 / 60)
  local second = math.floor(nx_number(time) % 60)
  local text = nx_widestr("")
  local min_str = ""
  if nx_number(minute) < 10 then
    min_str = "0" .. nx_string(minute)
  else
    min_str = nx_string(minute)
  end
  local sec_str = ""
  if nx_number(second) < 10 then
    sec_str = "0" .. nx_string(second)
  else
    sec_str = nx_string(second)
  end
  if 0 < hour then
    text = text .. nx_widestr(hour) .. nx_widestr(":") .. nx_widestr(min_str) .. nx_widestr(":") .. nx_widestr(sec_str)
  else
    text = nx_widestr(min_str) .. nx_widestr(":") .. nx_widestr(sec_str)
  end
  return text
end
function decode_time(d_time)
  local year, month, day, hour, min, sec = nx_function("ext_decode_date", d_time)
  local min_str = ""
  if nx_number(min) < 10 then
    min_str = "0" .. nx_string(min)
  else
    min_str = nx_string(min)
  end
  local sec_str = ""
  if nx_number(sec) < 10 then
    sec_str = "0" .. nx_string(sec)
  else
    sec_str = nx_string(sec)
  end
  return nx_string(month) .. "/" .. nx_string(day) .. " " .. nx_string(hour) .. ":" .. min_str
end
function get_remain_time(end_time)
  local now = get_sys_time()
  return nx_int((end_time - now) * 24 * 3600)
end
function get_sys_time()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  return nx_double(msg_delay:GetServerDateTime())
end
function get_array_name(drop_uid)
  return ARRAY_NAME_DROP .. nx_string(drop_uid)
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
