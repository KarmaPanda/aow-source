require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("share\\view_define")
local ui_home_conditions = {
  "ui_home_goods_01_1",
  "ui_home_goods_02_1",
  "ui_home_goods_03_1",
  "ui_home_goods_04_1",
  "ui_home_goods_05_1",
  "ui_home_goods_06_1"
}
local ui_home_conditions_empty = {
  "ui_home_goods_01_0",
  "ui_home_goods_02_0",
  "ui_home_goods_03_0",
  "ui_home_goods_04_0",
  "ui_home_goods_05_0",
  "ui_home_goods_06_0"
}
local ui_back_image = {
  "gui\\common\\checkbutton\\cbtn_2_on.png",
  "gui\\common\\checkbutton\\cbtn_2_down.png"
}
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function main_form_init(form)
  form.Fixed = false
  form.home_id = ""
  form.home_inout = 0
  form.conf_id = 0
  form.in_lvl = 0
  form.in_pretty = 0
  form.out_lvl = 0
  form.out_pretty = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_kj_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.home_id) == nx_string("") then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_LEVELUP, nx_string(form.home_id), form.home_inout)
end
function open_form(homeid, conf_id, lvl, hualidu, out_lvl, out_pretty)
  if nx_int(conf_id) <= nx_int(0) or nx_int(lvl) <= nx_int(0) or nx_int(out_lvl) < nx_int(0) then
    return
  end
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.home_id = homeid
  form.conf_id = conf_id
  form.in_lvl = lvl
  form.in_pretty = hualidu
  form.out_lvl = out_lvl
  form.out_pretty = out_pretty
  local home_manager = nx_value("HomeManager")
  if nx_is_valid(home_manager) and 0 >= home_manager:GetHomeOutPark(conf_id, lvl) then
    form.rbtn_home_indoor.Visible = false
    form.rbtn_home_outdoor.Visible = false
  end
  fresh_form(form, conf_id, lvl, hualidu)
end
function fresh_open_form(homeid, conf_id, lvl, hualidu, out_lvl, out_pretty)
  if nx_int(conf_id) <= nx_int(0) or nx_int(lvl) <= nx_int(0) or nx_int(out_lvl) < nx_int(0) then
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if form.home_id ~= homeid or form.conf_id ~= conf_id then
    form:Close()
    return
  end
  form.in_lvl = lvl
  form.in_pretty = hualidu
  form.out_lvl = out_lvl
  form.out_pretty = out_pretty
  local home_manager = nx_value("HomeManager")
  if nx_is_valid(home_manager) and 0 >= home_manager:GetHomeOutPark(conf_id, lvl) then
    form.rbtn_home_indoor.Visible = false
    form.rbtn_home_outdoor.Visible = false
  end
  if form.home_inout == 0 then
    fresh_form(form, conf_id, lvl, hualidu)
  elseif form.home_inout == 1 then
    fresh_form_outdoor(form, conf_id, out_lvl, out_pretty)
  end
end
function fresh_form(form, conf_id, lvl, hualidu)
  if not nx_is_valid(form) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.groupscrollbox_cur.Visible = true
  form.groupscrollbox_next.Visible = true
  form.groupscrollbox_cur_out.Visible = false
  form.groupscrollbox_next_out.Visible = false
  form.lbl_18:Clear()
  form.lbl_18.HtmlText = nx_widestr(util_text("ui_home_kuojian_10"))
  form.lbl_zero.Visible = false
  local price = home_manager:GetHomePrice(conf_id, lvl + 1)
  local ene = home_manager:GetHomeEne(conf_id, lvl + 1)
  local hl = home_manager:GetHomeNeedPretty(conf_id, lvl + 1)
  form.lbl_area.Text = nx_widestr(util_text(home_manager:GetHomeArea(conf_id, lvl)))
  form.lbl_next_area.Text = nx_widestr(util_text(home_manager:GetHomeArea(conf_id, lvl + 1)))
  form.lbl_max_num_cur.Text = nx_widestr(home_manager:GetHomeMaxGoods(conf_id, lvl))
  form.lbl_max_num_next.Text = nx_widestr(home_manager:GetHomeMaxGoods(conf_id, lvl + 1))
  local cur_condition1 = home_manager:GetHomeCondition1(conf_id, lvl)
  local next_condition1 = home_manager:GetHomeCondition1(conf_id, lvl + 1)
  local cur_condition2 = home_manager:GetHomeCondition2(conf_id, lvl)
  local next_condition2 = home_manager:GetHomeCondition2(conf_id, lvl + 1)
  update_home_kuojian_info(form, cur_condition1, cur_condition2, false)
  update_home_kuojian_info(form, next_condition1, next_condition2, true)
  form.lbl_size.Text = util_text(home_manager:GetHomeArea(conf_id, lvl + 1))
  form.lbl_price.Text = trans_capital_string(price)
  form.lbl_ene.Text = nx_widestr(ene)
  form.lbl_hl.Text = nx_widestr(hl)
  local bind_money = client_player:QueryProp("CapitalType1")
  local nobind_money = client_player:QueryProp("CapitalType2")
  if nx_int(price) > nx_int(nobind_money) then
    form.lbl_price.ForeColor = "255,255,0,0"
  else
    form.lbl_price.ForeColor = "255,255,180,40"
  end
  local have_ene = client_player:QueryProp("Ene")
  if nx_int(ene) > nx_int(have_ene) then
    form.lbl_ene.ForeColor = "255,255,0,0"
  else
    form.lbl_ene.ForeColor = "255,255,180,40"
  end
  if nx_int(hl) > nx_int(hualidu) then
    form.lbl_hl.ForeColor = "255,255,0,0"
  else
    form.lbl_hl.ForeColor = "255,255,180,40"
  end
  form.lbl_6.Text = nx_widestr(util_text("hualidu"))
  local need_item = home_manager:GetHomeNeedItem(conf_id, lvl + 1)
  local str_lst = util_split_string(need_item, ",")
  form.imagegrid_mat:Clear()
  local j = 0
  for i = 1, table.getn(str_lst), 2 do
    local item = nx_string(str_lst[i])
    local num = nx_int(str_lst[i + 1])
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item))
    if bExist then
      local tempphoto = ItemQuery:GetItemPropByConfigID(nx_string(item), nx_string("Photo"))
      itemname = gui.TextManager:GetText(item)
      local text = nx_widestr("<font color=\"#5f4325\">") .. nx_widestr(itemname) .. nx_widestr("</font>")
      form.imagegrid_mat:AddItem(j, tempphoto, text, 0, -1)
      local material_num = nx_execute("form_stage_main\\form_home\\form_home_build", "Get_Material_Num", item, VIEWPORT_MATERIAL_TOOL)
      local tool_num = nx_execute("form_stage_main\\form_home\\form_home_build", "Get_Material_Num", item, VIEWPORT_TOOL)
      local MaterialNum = material_num + tool_num
      if nx_int(MaterialNum) >= nx_int(num) then
        form.imagegrid_mat:ChangeItemImageToBW(j, false)
        form.imagegrid_mat:SetItemAddInfo(nx_int(j), nx_int(1), nx_widestr("<font color=\"#00aa00\">" .. nx_string(MaterialNum) .. "/" .. nx_string(num) .. "</font>"))
        form.imagegrid_mat:ShowItemAddInfo(nx_int(j), nx_int(1), true)
      else
        form.imagegrid_mat:ChangeItemImageToBW(j, true)
        form.imagegrid_mat:SetItemAddInfo(nx_int(j), nx_int(1), nx_widestr("<font color=\"#ff0000\">" .. nx_string(MaterialNum) .. "/" .. nx_string(num) .. "</font>"))
        form.imagegrid_mat:ShowItemAddInfo(nx_int(j), nx_int(1), true)
      end
      form.imagegrid_mat:SetItemAddInfo(nx_int(j), nx_int(2), nx_widestr(item))
      j = j + 1
    end
  end
end
function update_home_kuojian_info(form, condition1, condition2, is_next_lv)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if is_next_lv then
    if condition1 == "" or condition2 == "" then
      form.groupscrollbox_next.Visible = false
      form.lbl_max_level.Visible = true
      return
    else
      form.lbl_max_level.Visible = false
    end
  end
  local condition1_list = util_split_string(condition1, ",")
  if table.getn(condition1_list) ~= 3 then
    return
  end
  local condition2_list_empty = util_split_string(condition2, ",")
  local count = table.getn(condition2_list_empty)
  if count ~= 6 then
    return
  end
  local control_name = "lbl_condition_"
  local cbtn_name = "cbtn_"
  local group = form.groupscrollbox_cur
  if is_next_lv then
    control_name = "lbl_condition_next_"
    cbtn_name = "cbtn_next_"
    group = form.groupscrollbox_next
    form.cbtn_next_1.Checked = false
    form.cbtn_next_2.Checked = false
  else
    form.cbtn_1.Checked = false
    form.cbtn_2.Checked = false
  end
  for i = 1, 3 do
    local name = cbtn_name .. nx_string(i)
    local control = group:Find(name)
    if nx_is_valid(control) and nx_int(condition1_list[i]) == nx_int(1) then
      control.Checked = true
    end
  end
  for i = 1, count do
    local name = control_name .. nx_string(i)
    local control = group:Find(name)
    if nx_int(condition2_list_empty[i]) == nx_int(0) then
      control:Clear()
      control.HtmlText = nx_widestr(util_text(ui_home_conditions_empty[i]))
    else
      local test_id = "ui_home_quality_" .. nx_string(condition2_list_empty[i])
      local text = gui.TextManager:GetText(test_id)
      control:Clear()
      control.HtmlText = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[i], text))
    end
  end
end
function on_imagegrid_mat_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(index, 2)
  if nx_string(item_config) == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_imagegrid_mat_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function fresh_form_outdoor(form, conf_id, out_lvl, out_pretty)
  if not nx_is_valid(form) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.groupscrollbox_cur.Visible = false
  form.groupscrollbox_next.Visible = false
  form.groupscrollbox_cur_out.Visible = true
  form.groupscrollbox_next_out.Visible = true
  hide_out_condition(form)
  local ene = home_manager:GetHomeOutDoorEne(conf_id, out_lvl + 1)
  local hl = home_manager:GetHomeOutDoorNeedPretty(conf_id, out_lvl + 1)
  local condeition_cur = home_manager:GetHomeConditionOut(conf_id, out_lvl)
  local condeition_next = home_manager:GetHomeConditionOut(conf_id, out_lvl + 1)
  update_home_out_kuojian_info(form, condeition_cur, false)
  update_home_out_kuojian_info(form, condeition_next, true)
  form.lbl_ene.Text = nx_widestr(ene)
  form.lbl_hl.Text = nx_widestr(hl)
  local have_ene = client_player:QueryProp("Ene")
  if nx_int(ene) > nx_int(have_ene) then
    form.lbl_ene.ForeColor = "255,255,0,0"
  else
    form.lbl_ene.ForeColor = "255,255,180,40"
  end
  if nx_int(hl) > nx_int(out_pretty) then
    form.lbl_hl.ForeColor = "255,255,0,0"
  else
    form.lbl_hl.ForeColor = "255,255,180,40"
  end
  form.lbl_6.Text = nx_widestr(util_text("fanhuadu"))
  local need_item = home_manager:GetHomeOutDoorNeedItem(conf_id, out_lvl + 1)
  local str_lst = util_split_string(need_item, ",")
  form.imagegrid_mat:Clear()
  local j = 0
  for i = 1, table.getn(str_lst), 2 do
    local item = nx_string(str_lst[i])
    local num = nx_int(str_lst[i + 1])
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item))
    if bExist then
      local tempphoto = ItemQuery:GetItemPropByConfigID(nx_string(item), nx_string("Photo"))
      itemname = gui.TextManager:GetText(item)
      local text = nx_widestr("<font color=\"#5f4325\">") .. nx_widestr(itemname) .. nx_widestr("</font>")
      form.imagegrid_mat:AddItem(j, tempphoto, text, 0, -1)
      local material_num = nx_execute("form_stage_main\\form_home\\form_home_build", "Get_Material_Num", item, VIEWPORT_MATERIAL_TOOL)
      local tool_num = nx_execute("form_stage_main\\form_home\\form_home_build", "Get_Material_Num", item, VIEWPORT_TOOL)
      local MaterialNum = material_num + tool_num
      if nx_int(MaterialNum) >= nx_int(num) then
        form.imagegrid_mat:ChangeItemImageToBW(j, false)
        form.imagegrid_mat:SetItemAddInfo(nx_int(j), nx_int(1), nx_widestr("<font color=\"#00aa00\">" .. nx_string(MaterialNum) .. "/" .. nx_string(num) .. "</font>"))
        form.imagegrid_mat:ShowItemAddInfo(nx_int(j), nx_int(1), true)
      else
        form.imagegrid_mat:ChangeItemImageToBW(j, true)
        form.imagegrid_mat:SetItemAddInfo(nx_int(j), nx_int(1), nx_widestr("<font color=\"#ff0000\">" .. nx_string(MaterialNum) .. "/" .. nx_string(num) .. "</font>"))
        form.imagegrid_mat:ShowItemAddInfo(nx_int(j), nx_int(1), true)
      end
      form.imagegrid_mat:SetItemAddInfo(nx_int(j), nx_int(2), nx_widestr(item))
      j = j + 1
    end
  end
end
function update_home_out_kuojian_info(form, condition, is_next_lv)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local groupscrollbox_out = form.groupscrollbox_cur_out
  local lbl_dsec_name = ""
  local lbl_name = ""
  if is_next_lv then
    if condition == "" then
      form.groupscrollbox_next_out.Visible = false
      form.lbl_max_level.Visible = true
      return
    else
      form.lbl_max_level.Visible = false
    end
    groupscrollbox_out = form.groupscrollbox_next_out
    lbl_dsec_name = "lbl_condition_next_out_dsec_"
    lbl_name = "lbl_condition_next_out_"
  else
    if condition == "" then
      form.groupscrollbox_cur_out.Visible = false
      form.lbl_zero.Visible = true
      form.lbl_18:Clear()
      form.lbl_18.HtmlText = nx_widestr(util_text("ui_home_kuojian_out_tips_1"))
      return
    else
      form.lbl_zero.Visible = false
    end
    lbl_dsec_name = "lbl_condition_out_dsec_"
    lbl_name = "lbl_condition_out_"
  end
  if not nx_is_valid(groupscrollbox_out) then
    return
  end
  local tab_condition_list = util_split_string(condition, ";")
  if table.getn(tab_condition_list) <= 0 then
    return
  end
  local size = table.getn(tab_condition_list)
  for i = 1, size do
    local tab_condition = util_split_string(tab_condition_list[i], ",")
    if table.getn(tab_condition) == 2 then
      local control_name = lbl_name .. nx_string(i)
      local control_dsec_name = lbl_dsec_name .. nx_string(i)
      local lbl = groupscrollbox_out:Find(control_name)
      local lbl_dsec = groupscrollbox_out:Find(control_dsec_name)
      if nx_is_valid(lbl) then
        lbl.Visible = true
        if nx_int(tab_condition[1]) == nx_int(0) then
          lbl.BackImage = ui_back_image[1]
        else
          lbl.BackImage = ui_back_image[2]
        end
      end
      if nx_is_valid(lbl_dsec) then
        lbl_dsec.Visible = true
        lbl_dsec:Clear()
        lbl_dsec.HtmlText = nx_widestr(util_text(nx_string(tab_condition[2])))
      end
    end
  end
end
function on_rbtn_home_inout_checked_changed(rbtn)
  form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked and rbtn.TabIndex == 0 then
    fresh_form(form, form.conf_id, form.in_lvl, form.in_pretty)
    form.home_inout = 0
  elseif rbtn.Checked and rbtn.TabIndex == 1 then
    fresh_form_outdoor(form, form.conf_id, form.out_lvl, form.out_pretty)
    form.home_inout = 1
  end
end
function hide_out_condition(form)
  if not nx_is_valid(form) then
    return
  end
  local groupscrollbox_cur_out = form.groupscrollbox_cur_out
  local groupscrollbox_next_out = form.groupscrollbox_next_out
  if not nx_is_valid(groupscrollbox_cur_out) or not nx_is_valid(groupscrollbox_next_out) then
    return
  end
  local ctr_count = groupscrollbox_cur_out:GetChildControlCount()
  if 0 < ctr_count then
    for i = 1, ctr_count do
      local control = groupscrollbox_cur_out:GetChildControlByIndex(i)
      if nx_is_valid(control) then
        control.Visible = false
      end
    end
  end
  ctr_count = groupscrollbox_next_out:GetChildControlCount()
  if 0 < ctr_count then
    for i = 1, ctr_count do
      local control = groupscrollbox_next_out:GetChildControlByIndex(i)
      if nx_is_valid(control) then
        control.Visible = false
      end
    end
  end
end
