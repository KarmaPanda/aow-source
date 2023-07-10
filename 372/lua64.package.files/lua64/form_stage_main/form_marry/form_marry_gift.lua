require("util_gui")
require("util_static_data")
require("form_stage_main\\form_marry\\form_marry_util")
local SINGLE_PAGE_MAX = 6
local SINGLE_RANK_MAX = 10
function main_form_init(form)
  form.Fixed = false
  form.Current_Type = 1
  form.Current_Belone = 1
  form.Current_Page = 1
  form.Blessing_Gift = nx_call("util_gui", "get_arraylist", "gift:blessing_list")
  form.Cash_Gift = nx_call("util_gui", "get_arraylist", "gift:cash_list")
  form.Fireworks_Gift = nx_call("util_gui", "get_arraylist", "gift:fireworks_list")
  form.Luxury_Gift = nx_call("util_gui", "get_arraylist", "gift:luxury_list")
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  Load(form)
  Gift_Refresh(form)
  request_wish_cost()
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister("form_stage_main\\form_marry\\form_marry_util", "request_wish_cost", form)
    timer:Register(30000, -1, "form_stage_main\\form_marry\\form_marry_util", "request_wish_cost", form, -1, -1)
  end
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister("form_stage_main\\form_marry\\form_marry_util", "request_wish_cost", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked then
    rbtn.ParentForm.Current_Type = nx_int(nx_string(rbtn.DataSource))
    rbtn.ParentForm.Current_Page = 1
    Gift_Refresh(rbtn.ParentForm)
  end
end
function on_btn_click(btn)
  local goods = ""
  local price = ""
  local control_array = string.sub(btn.Name, 5, -1)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    local groupbox_item = form:Find("groupbox_item_" .. nx_string(control_array))
    if nx_is_valid(groupbox_item) then
      local lbl_goods = groupbox_item:Find("lbl_goods_" .. nx_string(control_array))
      if nx_is_valid(lbl_goods) then
        goods = lbl_goods.Text
      end
      local lbl_price = groupbox_item:Find("lbl_price_" .. nx_string(control_array))
      if nx_is_valid(lbl_price) then
        price = lbl_price.Text
      end
    end
  end
  local text = ""
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    text = gui.TextManager:GetFormatText("ui_marry_gift", price, goods)
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if "ok" == result then
    request_use_gift(nx_string(btn.DataSource))
  end
end
function on_btn_prev_click(btn)
  if btn.ParentForm.Current_Page > 1 then
    btn.ParentForm.ipt_1.Text = nx_widestr(btn.ParentForm.Current_Page - 1)
  else
    btn.ParentForm.ipt_1.Text = nx_widestr(btn.ParentForm.ipt_1.MaxDigit)
  end
  Gift_Refresh(btn.ParentForm)
end
function on_btn_next_click(btn)
  if btn.ParentForm.Current_Page < btn.ParentForm.ipt_1.MaxDigit then
    btn.ParentForm.ipt_1.Text = nx_widestr(btn.ParentForm.Current_Page + 1)
  else
    btn.ParentForm.ipt_1.Text = nx_widestr("1")
  end
  Gift_Refresh(btn.ParentForm)
end
function on_btn_skip_click(btn)
  Gift_Refresh(btn.ParentForm)
end
function Load(form)
  local ini = nx_execute("util_functions", "get_ini", INI_FILE_MARRY_GIFT)
  local count = ini:GetSectionCount()
  form.Blessing_Gift:ClearChild()
  form.Cash_Gift:ClearChild()
  form.Fireworks_Gift:ClearChild()
  form.Luxury_Gift:ClearChild()
  for i = 1, count do
    local index = ini:FindSectionIndex(nx_string(i))
    if 0 <= index then
      local gift_type = ini:ReadInteger(index, "Type", 0)
      local gift_belone = ini:ReadInteger(index, "Belone", 0)
      if 1 == gift_type and (form.Current_Belone == gift_belone or 3 == gift_belone) then
        local blessing = form.Blessing_Gift:CreateChild("")
        blessing.ID = ini:ReadString(index, "ID", "")
        blessing.PRICE = ini:ReadString(index, "Price", "")
        blessing.TYPE = 1
        blessing.DESCRIBE = ini:ReadString(index, "Describe", "")
      elseif 2 == gift_type and (form.Current_Belone == gift_belone or 3 == gift_belone) then
        local cash = form.Cash_Gift:CreateChild("")
        cash.ID = ini:ReadString(index, "ID", "")
        cash.PRICE = ini:ReadString(index, "Price", "")
        cash.TYPE = 2
        cash.DESCRIBE = ini:ReadString(index, "Describe", "")
      elseif 3 == gift_type and (form.Current_Belone == gift_belone or 3 == gift_belone) then
        local fireworks = form.Fireworks_Gift:CreateChild("")
        fireworks.ID = ini:ReadString(index, "ID", "")
        fireworks.PRICE = ini:ReadString(index, "Price", "")
        fireworks.TYPE = 3
        fireworks.DESCRIBE = ini:ReadString(index, "Describe", "")
      elseif 4 == gift_type and (form.Current_Belone == gift_belone or 3 == gift_belone) then
        local luxury = form.Luxury_Gift:CreateChild("")
        luxury.ID = ini:ReadString(index, "ID", "")
        luxury.PRICE = ini:ReadString(index, "Price", "")
        luxury.TYPE = 4
        luxury.DESCRIBE = ini:ReadString(index, "Describe", "")
      end
    end
  end
end
function Gift_Refresh(form)
  form.groupbox_item_1.Visible = false
  form.groupbox_item_2.Visible = false
  form.groupbox_item_3.Visible = false
  form.groupbox_item_4.Visible = false
  form.groupbox_item_5.Visible = false
  form.groupbox_item_6.Visible = false
  local gift_list = nx_null()
  if 1 == form.Current_Type then
    gift_list = form.Blessing_Gift
  elseif 2 == form.Current_Type then
    gift_list = form.Cash_Gift
  elseif 3 == form.Current_Type then
    gift_list = form.Fireworks_Gift
  elseif 4 == form.Current_Type then
    gift_list = form.Luxury_Gift
  end
  local count = 0
  if nx_is_valid(gift_list) then
    count = gift_list:GetChildCount()
  end
  if 0 < count then
    if 0 < count % SINGLE_PAGE_MAX then
      form.ipt_1.MaxDigit = nx_int(count / SINGLE_PAGE_MAX) + 1
      form.lbl_11.Text = nx_widestr("/ ") .. nx_widestr(nx_int(count / SINGLE_PAGE_MAX) + 1)
    else
      form.ipt_1.MaxDigit = nx_int(count / SINGLE_PAGE_MAX)
      form.lbl_11.Text = nx_widestr("/ ") .. nx_widestr(nx_int(count / SINGLE_PAGE_MAX))
    end
    local current_page = nx_int(form.ipt_1.Text)
    if 0 >= nx_number(current_page) then
      form.Current_Page = 1
      form.ipt_1.Text = nx_widestr("1")
    else
      form.Current_Page = current_page
    end
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      for i = 1, SINGLE_PAGE_MAX do
        local array = SINGLE_PAGE_MAX * (form.Current_Page - 1) + i
        if count >= array then
          local control_array = i % 6
          if control_array <= 0 then
            control_array = 6
          end
          local groupbox_item = form:Find("groupbox_item_" .. nx_string(control_array))
          if nx_is_valid(groupbox_item) then
            local lbl_goods = groupbox_item:Find("lbl_goods_" .. nx_string(control_array))
            if nx_is_valid(lbl_goods) then
              lbl_goods.Text = nx_widestr(gui.TextManager:GetText(gift_list:GetChildByIndex(array - 1).ID))
            end
            local lbl_price = groupbox_item:Find("lbl_price_" .. nx_string(control_array))
            if nx_is_valid(lbl_price) then
              lbl_price.Text = nx_widestr(gui.TextManager:GetText(gift_list:GetChildByIndex(array - 1).PRICE))
            end
            local imagegrid_photo = groupbox_item:Find("imagegrid_photo_" .. nx_string(control_array))
            if nx_is_valid(imagegrid_photo) then
              local photo = skill_static_query_by_id(gift_list:GetChildByIndex(array - 1).ID, "Photo")
              imagegrid_photo:Clear()
              imagegrid_photo:AddItem(0, photo, "", 1, -1)
              imagegrid_photo.HintText = nx_widestr(gui.TextManager:GetText(gift_list:GetChildByIndex(array - 1).DESCRIBE))
            end
            local btn = groupbox_item:Find("btn_" .. nx_string(control_array))
            if nx_is_valid(btn) then
              btn.DataSource = gift_list:GetChildByIndex(array - 1).ID
            end
            groupbox_item.Visible = true
          end
        end
      end
    end
  else
    form.ipt_1.Text = nx_widestr("0")
    form.ipt_1.MaxDigit = 1
    form.lbl_11.Text = nx_widestr("/ ") .. nx_widestr("0")
  end
end
function Refresh_WishCostRank(marry_man_name, marry_woman_name, ...)
  local WISH_COST_RANK = {}
  local count = table.getn(arg)
  if 0 < count then
    for i = 1, count / 2 do
      WISH_COST_RANK[i] = {}
      WISH_COST_RANK[i].NAME = arg[2 * i - 1]
      WISH_COST_RANK[i].COST = nx_int(arg[2 * i])
    end
  end
  table.sort(WISH_COST_RANK, function(a, b)
    return a.COST > b.COST
  end)
  local form = util_get_form(FORM_MARRY_GIFT, true)
  if nx_is_valid(form) then
    Load_WishCostRank(form, unpack(WISH_COST_RANK))
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local name = client_player:QueryProp("Name")
    local belone = 1
    if nx_ws_equal(nx_widestr(marry_man_name), nx_widestr(name)) then
      belone = 2
    end
    if nx_ws_equal(nx_widestr(marry_woman_name), nx_widestr(name)) then
      belone = 4
    end
    if form.Current_Belone ~= belone then
      form.Current_Belone = belone
      if 2 == belone or 4 == belone then
        form.rbtn_3.Checked = true
        form.rbtn_3.Left = form.rbtn_1.Left
        form.rbtn_1.Visible = false
        form.rbtn_2.Visible = false
        form.rbtn_4.Visible = false
      end
    end
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.mltbox_1:Clear()
      form.mltbox_1:AddHtmlText(gui.TextManager:GetFormatText("ui_marry_gift_title", marry_man_name, marry_woman_name), -1)
    end
    util_show_form(FORM_MARRY_GIFT, true)
  end
end
function Load_WishCostRank(form, ...)
  if nx_is_valid(form) then
    for i = 1, SINGLE_RANK_MAX do
      local lbl_list_name = form:Find("lbl_list_name_" .. nx_string(i))
      if nx_is_valid(lbl_list_name) then
        lbl_list_name.Text = nx_widestr("")
      end
      local lbl_list_gift = form:Find("lbl_list_gift_" .. nx_string(i))
      if nx_is_valid(lbl_list_gift) then
        lbl_list_gift.Text = nx_widestr("")
      end
    end
    count = table.getn(arg)
    if count > SINGLE_RANK_MAX then
      count = SINGLE_RANK_MAX
    end
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      for i = 1, count do
        local lbl_list_name = form:Find("lbl_list_name_" .. nx_string(i))
        if nx_is_valid(lbl_list_name) then
          lbl_list_name.Text = nx_widestr(arg[i].NAME)
        end
        local lbl_list_gift = form:Find("lbl_list_gift_" .. nx_string(i))
        if nx_is_valid(lbl_list_gift) then
          lbl_list_gift.Text = nx_widestr(trans_capital_string(arg[i].COST))
        end
      end
    end
  end
end
