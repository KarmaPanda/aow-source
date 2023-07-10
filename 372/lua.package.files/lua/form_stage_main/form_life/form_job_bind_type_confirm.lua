require("util_functions")
require("share\\view_define")
local form_info = {
  compose_ensure_capital = {
    name_bind = "ui_bind_compose",
    name_nobind = "ui_nobind_compose",
    text_bind = "ui_bind_compose_info",
    text_nobind = "ui_nobind_compose_info"
  }
}
function main_form_init(form)
  form.Fixed = false
  form.str_info = ""
  form.str_var = ""
  form.bind_type = 1
  form.func_name = ""
  return 1
end
function on_main_form_open(form)
  refresh_form(form)
  refresh_form_pos(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function init_controls(form)
end
function refresh_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function refresh_form(form)
  local str_lst = util_split_string(form.str_info, "-")
  if table.getn(str_lst) < 3 then
    form:Close()
    return
  end
  form.func_name = nx_string(str_lst[1])
  form.rbtn_bind.Checked = true
  on_rbtn_click(form.rbtn_bind)
end
function refresh_form_controls(form)
  local mltbox = form.mltbox_info
  mltbox.Height = mltbox:GetContentHeight() + 2
  mltbox.ViewRect = "0,0," .. nx_string(mltbox.Width) .. "," .. nx_string(mltbox.Height)
  form.lbl_3.Top = mltbox.Top + mltbox.Height + 2
  form.groupbox_cur_money.Top = form.lbl_3.Top - 12
  form.groupbox_money.Height = form.groupbox_cur_money.Top + form.groupbox_cur_money.Height
  form.groupbox_select.Top = form.groupbox_money.Top + form.groupbox_money.Height
  form.groupbox_materials.Top = form.groupbox_select.Top + form.groupbox_select.Height
  form.groupbox_bottom.Top = form.groupbox_materials.Top + form.groupbox_materials.Height - 6
  form.groupbox_main.Height = form.groupbox_bottom.Top + form.groupbox_bottom.Height
  form.lbl_main.Height = form.groupbox_bottom.Top - 28
  form.lbl_line2.Top = form.lbl_main.Top + form.lbl_main.Height - 8
  form.Height = form.groupbox_main.Top + form.groupbox_main.Height + 6
end
function show_bind_form(form, money, materials, servermoney, count)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupbox_bind_money.Visible = true
  form.groupbox_nobind_money.Top = 30
  form.lbl_bind_money.ForeColor = "255,0,0,0"
  form.lbl_nobind_money.ForeColor = "255,0,0,0"
  form.bind_type = 1
  form.mltbox_info.HtmlText = gui.TextManager:GetText("ui_bangding")
  form.lbl_no_bind_materials.Text = nx_widestr(gui.TextManager:GetText("ui_feibangdingcl"))
  if nx_int(servermoney) ~= nx_int(0) then
    form.lbl_server.Visible = true
    form.lbl_server_money.Visible = true
    form.lbl_server_money.Text = nx_widestr(format_prize_money(servermoney))
  else
    form.lbl_server.Visible = false
    form.lbl_server_money.Visible = false
  end
  local cur_bind_money = nx_int64(client_player:QueryProp("CapitalType1"))
  local cur_nobind_money = nx_int64(client_player:QueryProp("CapitalType2"))
  local need_bind_money = nx_int64(money * count)
  local need_nobind_money = nx_int64(servermoney * count)
  revise_tip_pos(nil, form.lbl_bind_tip, "", false)
  revise_tip_pos(nil, form.lbl_nobind_tip, "", false)
  local enough = true
  if cur_bind_money >= need_bind_money and cur_nobind_money >= need_nobind_money then
    form.groupbox_nobind_money.Visible = false
    form.lbl_bind_money.Text = nx_widestr(format_prize_money(money))
    form.groupbox_money.Height = 155
    if nx_int(servermoney) > nx_int(0) then
      form.groupbox_nobind_money.Visible = true
      form.lbl_nobind_money.Text = nx_widestr(format_prize_money(servermoney))
      form.groupbox_money.Height = 185
    end
  else
    if cur_bind_money < need_bind_money and cur_nobind_money < need_nobind_money then
      form.lbl_bind_money.Text = nx_widestr(format_prize_money(cur_bind_money))
      form.lbl_nobind_money.Text = nx_widestr(format_prize_money(cur_nobind_money))
      form.lbl_bind_money.ForeColor = "255,255,0,0"
      form.lbl_nobind_money.ForeColor = "255,255,0,0"
      revise_tip_pos(form.lbl_bind_money, form.lbl_bind_tip, "ui_money_1", true)
      revise_tip_pos(form.lbl_nobind_money, form.lbl_nobind_tip, "ui_money_2", true)
      enough = false
    elseif cur_bind_money >= need_bind_money and cur_nobind_money < need_nobind_money then
      form.lbl_bind_money.Text = nx_widestr(format_prize_money(need_bind_money))
      form.lbl_nobind_money.Text = nx_widestr(format_prize_money(cur_nobind_money))
      form.lbl_nobind_money.ForeColor = "255,255,0,0"
      revise_tip_pos(form.lbl_nobind_money, form.lbl_nobind_tip, "ui_money_2", true)
      enough = false
    elseif cur_bind_money < need_bind_money and cur_nobind_money >= nx_int64(need_nobind_money + need_bind_money - cur_bind_money) then
      form.lbl_bind_money.Text = nx_widestr(format_prize_money(cur_bind_money))
      form.lbl_nobind_money.Text = nx_widestr(format_prize_money(need_nobind_money + need_bind_money - cur_bind_money))
      revise_tip_pos(form.lbl_bind_money, form.lbl_bind_tip, "ui_money_3", true)
    elseif cur_bind_money < need_bind_money and cur_nobind_money < nx_int64(need_nobind_money + need_bind_money - cur_bind_money) then
      form.lbl_bind_money.Text = nx_widestr(format_prize_money(cur_bind_money))
      form.lbl_nobind_money.Text = nx_widestr(format_prize_money(need_nobind_money + need_bind_money - cur_bind_money))
      form.lbl_bind_money.ForeColor = "255,255,0,0"
      form.lbl_nobind_money.ForeColor = "255,255,0,0"
      revise_tip_pos(form.lbl_bind_money, form.lbl_bind_tip, "ui_money_1", true)
      revise_tip_pos(form.lbl_nobind_money, form.lbl_nobind_tip, "ui_money_2", true)
      enough = false
    else
      enough = false
    end
    if cur_bind_money >= need_bind_money and need_nobind_money == 0 then
      form.groupbox_money.Height = 155
      form.groupbox_nobind_money.Visible = false
    else
      form.groupbox_money.Height = 185
      form.groupbox_nobind_money.Visible = true
    end
  end
  if is_materials_enough(materials, 1, count) then
    form.groupbox_select.Visible = false
    form.groupbox_materials.Top = form.groupbox_money.Top + form.groupbox_money.Height
  else
    form.groupbox_select.Visible = true
    form.groupbox_select.Top = form.groupbox_money.Top + form.groupbox_money.Height
    form.groupbox_materials.Top = form.groupbox_select.Top + form.groupbox_select.Height
    if not is_all_materials_enough(materials, count) then
      enough = false
    end
    if not form.cbtn_select.Checked and not is_materials_enough(materials, 1, count) then
      enough = false
    end
  end
  local isAddsuccess, isbind, isnobind = add_material(form, materials, count)
  if isbind then
    form.groupbox_bind.Visible = true
  else
    form.groupbox_bind.Visible = false
  end
  if form.cbtn_select.Checked and isnobind then
    form.groupbox_nobind.Visible = true
    form.groupbox_nobind.Top = 149
    form.groupbox_materials.Height = 286
    form.lbl_11.Height = 262
  else
    form.groupbox_nobind.Visible = false
    form.lbl_11.Height = 145
    form.groupbox_materials.Height = 169
  end
  form.lbl_main.Height = form.groupbox_materials.Top + form.groupbox_materials.Height - form.lbl_main.Top
  if not isAddsuccess or not isbind then
    form.groupbox_materials.Visible = false
    form.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText("ui_split_bangding"))
    form.lbl_main.Height = form.lbl_main.Height - form.groupbox_materials.Height + 10
  end
  form.lbl_line2.Top = form.lbl_main.Top + form.lbl_main.Height - 5
  form.groupbox_bottom.Top = form.lbl_line2.Top + form.lbl_line2.Height - 3
  form.groupbox_main.Height = form.groupbox_bottom.Top + form.groupbox_bottom.Height
  form.Height = form.groupbox_main.Top + form.groupbox_main.Height + 5
  if enough then
    form.btn_ok.Enabled = true
  else
    form.btn_ok.Enabled = false
  end
end
function show_nobind_form(form, money, materials, servermoney, count)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupbox_bind_money.Visible = false
  form.groupbox_nobind_money.Visible = true
  form.groupbox_nobind_money.Top = 0
  form.lbl_bind_money.ForeColor = "255,0,0,0"
  form.lbl_nobind_money.ForeColor = "255,0,0,0"
  revise_tip_pos(nil, form.lbl_bind_tip, "", false)
  revise_tip_pos(nil, form.lbl_nobind_tip, "", false)
  form.bind_type = 0
  form.mltbox_info.HtmlText = gui.TextManager:GetText("ui_feibangding")
  form.lbl_no_bind_materials.Text = nx_widestr(gui.TextManager:GetText("ui_feibangdingcl1"))
  if nx_int(servermoney) ~= nx_int(0) then
    form.lbl_server.Visible = true
    form.lbl_server_money.Visible = true
    form.lbl_server_money.Text = nx_widestr(format_prize_money(servermoney * count))
  else
    form.lbl_server.Visible = false
    form.lbl_server_money.Visible = false
  end
  local enough = true
  local cur_money = nx_int64(client_player:QueryProp("CapitalType2"))
  local need_money = nx_int64((nx_int64(money) + servermoney) * count)
  form.lbl_nobind_money.Text = nx_widestr(format_prize_money(need_money))
  form.groupbox_money.Height = 155
  if cur_money < need_money then
    enough = false
    form.lbl_nobind_money.ForeColor = "255,255,0,0"
    revise_tip_pos(form.lbl_nobind_money, form.lbl_nobind_tip, "ui_money_2", true)
  end
  form.groupbox_select.Visible = false
  form.groupbox_materials.Top = form.groupbox_money.Top + form.groupbox_money.Height
  if not is_materials_enough(materials, 0, count) then
    enough = false
  end
  local isAddsuccess, isbind, isnobind = add_material(form, materials, count)
  form.groupbox_bind.Visible = true
  form.groupbox_nobind.Visible = true
  form.groupbox_nobind.Top = 149
  form.btn_nobind.Left = 235
  form.groupbox_materials.Height = 286
  form.lbl_11.Height = 262
  form.lbl_main.Height = form.groupbox_materials.Top + form.groupbox_materials.Height - form.lbl_main.Top
  if not isAddsuccess then
    form.groupbox_materials.Visible = false
    form.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText("ui_split_feibangding"))
    form.lbl_main.Height = form.lbl_main.Height - form.groupbox_materials.Height + 10
  end
  form.lbl_line2.Top = form.lbl_main.Top + form.lbl_main.Height - 5
  form.groupbox_bottom.Top = form.lbl_line2.Top + form.lbl_line2.Height - 3
  form.groupbox_main.Height = form.groupbox_bottom.Top + form.groupbox_bottom.Height
  form.Height = form.groupbox_main.Top + form.groupbox_main.Height + 5
  if enough then
    form.btn_ok.Enabled = true
  else
    form.btn_ok.Enabled = false
  end
end
function revise_tip_pos(lbl_str_obj, lbl_tip_obj, texts, show)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  lbl_tip_obj.Visible = show
  if not show then
    return
  end
  local strs = nx_string(lbl_str_obj.Text)
  local strs_len = string.len(strs)
  lbl_tip_obj.Left = lbl_str_obj.Left + strs_len * 7 + 5
  lbl_tip_obj.Top = lbl_str_obj.Top
  lbl_tip_obj.Text = nx_widestr(gui.TextManager:GetText(texts))
end
function is_materials_enough(materials, need_bind_type, count)
  need_bind_type = nx_int(need_bind_type)
  local str_lst = util_split_string(materials, ";")
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    if table.getn(str_temp) == 3 then
      local item = nx_string(str_temp[1])
      local num = nx_int(str_temp[2]) * count
      local bind_type = nx_int(str_temp[3])
      if bind_type == need_bind_type then
        local curnum = get_material_num(item, need_bind_type)
        if nx_int(curnum) < nx_int(num) then
          return false
        end
      end
    end
  end
  return true
end
function is_all_materials_enough(materials, count)
  local str_lst = util_split_string(materials, ";")
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    if table.getn(str_temp) == 3 then
      local item = nx_string(str_temp[1])
      local num = nx_int(str_temp[2]) * count
      local bind_type = nx_int(str_temp[3])
      local curnum = get_material_num(item, bind_type)
      if nx_int(bind_type) == nx_int(1) then
        curnum = curnum + get_material_num(item, 0)
      end
      if nx_int(curnum) < nx_int(num) then
        return false
      end
    end
  end
  return true
end
function add_material(form, materials, count)
  if not nx_is_valid(form) then
    return false
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  local bind_type = form.bind_type
  local Checked = form.cbtn_select.Checked
  local grid_bind = form.ImageControlGrid_bind
  local grid_nobind = form.ImageControlGrid_nobind
  grid_bind:Clear()
  grid_nobind:Clear()
  local str_lst = util_split_string(materials, ";")
  local bind_index = 0
  local nobind_index = 0
  local isAddsuccess = false
  local isbind = false
  local isnobind = false
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    if table.getn(str_temp) == 3 then
      local item = nx_string(str_temp[1])
      local num = nx_int(str_temp[2]) * count
      local temp_type = nx_int(str_temp[3])
      if nx_int(bind_type) == nx_int(0) then
        temp_type = 0
      elseif nx_int(bind_type) == nx_int(1) then
        temp_type = 1
      end
      local bExist = ItemQuery:FindItemByConfigID(item)
      if bExist then
        isAddsuccess = true
        local cur_num = get_material_num(item, temp_type)
        local photo = ItemQuery:GetItemPropByConfigID(item, "Photo")
        local num_string_gre = "<font color=\"#00ff00\">" .. nx_string(cur_num) .. "/" .. nx_string(num) .. "</font>"
        local num_string_red = "<font color=\"#ff0000\">" .. nx_string(cur_num) .. "/" .. nx_string(num) .. "</font>"
        if nx_int(temp_type) == nx_int(0) then
          grid_nobind:AddItem(nobind_index, photo, "", 0, -1)
          grid_nobind:ShowItemAddInfo(nobind_index, 1, true)
          if nx_int(cur_num) >= nx_int(num) then
            grid_nobind:ChangeItemImageToBW(nobind_index, false)
            grid_nobind:SetItemAddInfo(nobind_index, 1, nx_widestr(num_string_gre))
          else
            grid_nobind:ChangeItemImageToBW(nobind_index, true)
            grid_nobind:SetItemAddInfo(nobind_index, 1, nx_widestr(num_string_red))
          end
          grid_nobind:SetItemAddInfo(nobind_index, nx_int(2), nx_widestr(item))
          nobind_index = nobind_index + 1
          isnobind = true
        elseif nx_int(temp_type) == nx_int(1) then
          grid_bind:AddItem(bind_index, photo, "", 0, -1)
          grid_bind:ShowItemAddInfo(bind_index, 1, true)
          if nx_int(cur_num) >= nx_int(num) then
            grid_bind:ChangeItemImageToBW(bind_index, false)
            grid_bind:SetItemAddInfo(bind_index, 1, nx_widestr(num_string_gre))
          else
            grid_bind:ChangeItemImageToBW(bind_index, true)
            grid_bind:SetItemAddInfo(bind_index, 1, nx_widestr(num_string_red))
            if Checked then
              cur_num = get_material_num(item, 0)
              num_string_gre = "<font color=\"#00ff00\">" .. nx_string(cur_num) .. "/" .. nx_string(num) .. "</font>"
              num_string_red = "<font color=\"#ff0000\">" .. nx_string(cur_num) .. "/" .. nx_string(num) .. "</font>"
              grid_nobind:AddItem(nobind_index, photo, "", 0, -1)
              grid_nobind:ShowItemAddInfo(nobind_index, 1, true)
              if nx_int(cur_num) >= nx_int(num) then
                grid_nobind:ChangeItemImageToBW(nobind_index, false)
                grid_nobind:SetItemAddInfo(nobind_index, 1, nx_widestr(num_string_gre))
              else
                grid_nobind:ChangeItemImageToBW(nobind_index, true)
                grid_nobind:SetItemAddInfo(nobind_index, 1, nx_widestr(num_string_red))
              end
              grid_nobind:SetItemAddInfo(nobind_index, nx_int(2), nx_widestr(item))
              nobind_index = nobind_index + 1
              isnobind = true
            end
          end
          grid_bind:SetItemAddInfo(bind_index, 2, nx_widestr(item))
          bind_index = bind_index + 1
          isbind = true
        end
      end
    end
  end
  if not isAddsuccess then
  end
  return isAddsuccess, isbind, isnobind
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if nx_string(form.str_var) ~= "" and nx_string(form.func_name) ~= "" then
    nx_execute("custom_sender", "custom_select_bind", nx_int(form.bind_type), nx_string(form.func_name), nx_string(form.str_var))
  end
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_click(btn)
  local form = btn.ParentForm
  local str_lst = util_split_string(form.str_info, "-")
  if table.getn(str_lst) < 3 then
    return
  end
  local money = nx_int64(str_lst[2])
  local materials = str_lst[3]
  local servermoney = 0
  if str_lst[4] ~= nil then
    servermoney = nx_int64(str_lst[4])
  end
  local count = 1
  if str_lst[5] ~= nil then
    count = nx_int(str_lst[5])
  end
  if nx_int(btn.TabIndex) == nx_int(1) then
    show_bind_form(form, money, materials, servermoney, count)
  elseif nx_int(btn.TabIndex) == nx_int(2) then
    show_nobind_form(form, money, materials, servermoney, count)
  end
  refresh_form_controls(form)
end
function on_cbtn_select_click(btn)
  local form = btn.ParentForm
  local str_lst = util_split_string(form.str_info, "-")
  if table.getn(str_lst) < 3 then
    return
  end
  local money = nx_int64(str_lst[2])
  local materials = str_lst[3]
  local bind_type = form.bind_type
  local servermoney = 0
  if str_lst[4] ~= nil then
    servermoney = nx_int64(str_lst[4])
  end
  local count = 1
  if str_lst[5] ~= nil then
    count = nx_int(str_lst[5])
  end
  if nx_int(bind_type) == nx_int(1) then
    show_bind_form(form, money, materials, servermoney, count)
  elseif nx_int(bind_type) == nx_int(0) then
    show_nobind_form(form, money, materials, servermoney, count)
  end
end
function on_ImageControlGrid_mousein_grid(grid, index)
  nx_execute("form_stage_main\\form_life\\form_job_composite", "on_material_grid_mousein_grid", grid, index)
end
function on_ImageControlGrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function open_form(str_info, str_var)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_bind_type_confirm", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.str_info = str_info
  form.str_var = str_var
  form.Visible = true
  form:Show()
end
function format_prize_money(money)
  money = nx_number(money)
  local ding = nx_int64(money / 1000000)
  local temp = nx_int64(money - ding * 1000000)
  local liang = nx_int64(temp / 1000)
  local wen = nx_int64(temp - liang * 1000)
  local money_text = ""
  if nx_number(ding) > 0 then
    money_text = nx_widestr(ding) .. nx_widestr(util_text("ui_bag_ding"))
  end
  if nx_number(liang) > 0 then
    money_text = nx_widestr(money_text) .. nx_widestr(liang) .. nx_widestr(util_text("ui_bag_liang"))
  end
  if nx_number(wen) > 0 then
    money_text = nx_widestr(money_text) .. nx_widestr(wen) .. nx_widestr(util_text("ui_bag_wen"))
  end
  if nx_string(money_text) == "" then
    money_text = nx_widestr("0") .. nx_widestr(util_text("ui_bag_wen"))
  end
  return money_text
end
function get_material_num(itemid, bind_type)
  local num = 0
  num = get_material_num_by_view(VIEWPORT_MATERIAL_TOOL, itemid, bind_type)
  num = num + get_material_num_by_view(VIEWPORT_TOOL, itemid, bind_type)
  return num
end
function get_material_num_by_view(viewid, configid, bind_type)
  local game_client = nx_value("game_client")
  local cur_amount = nx_int(0)
  local view = game_client:GetView(nx_string(viewid))
  if not nx_is_valid(view) then
    return cur_amount
  end
  local viewobj_list = view:GetViewObjList()
  for j, obj in pairs(viewobj_list) do
    if nx_is_valid(obj) then
      local tempid = obj:QueryProp("ConfigID")
      local bind = obj:QueryProp("BindStatus")
      if nx_ws_equal(nx_widestr(tempid), nx_widestr(configid)) and nx_int(bind) == nx_int(bind_type) then
        cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
      end
    end
  end
  return cur_amount
end
function on_btn_bind_get_capture(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local bind_type = form.bind_type
  local key = ""
  if bind_type == 1 then
    key = "tips_bound_1"
  elseif bind_type == 0 then
    key = "tips_bound_3"
  else
    return
  end
  local value = gui.TextManager:GetText(key)
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", value, x, y, 0, form)
end
function on_btn_bind_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function on_btn_nobind_get_capture(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local bind_type = form.bind_type
  local key = ""
  if bind_type == 1 then
    key = "tips_bound_2"
  elseif bind_type == 0 then
    key = "tips_bound_4"
  else
    return
  end
  local value = gui.TextManager:GetText(key)
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", value, x, y, 0, form)
end
function on_btn_nobind_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
