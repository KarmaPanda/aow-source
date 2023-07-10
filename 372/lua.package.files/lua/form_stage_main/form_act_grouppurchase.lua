require("util_functions")
require("util_gui")
require("share\\client_custom_define")
function on_main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.cur_page = 0
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_server_msg(...)
  local cur_num = arg[1]
  local strCountTotal = arg[2]
  local apply_flag = arg[3]
  local status = arg[4]
  local remain_time = arg[5]
  local week = arg[6]
  local itemlist = ""
  local strCountTotal_list = util_split_string(strCountTotal, ";")
  local form_act_groupchase_logic = nx_value("form_act_grouppurchase")
  if not nx_is_valid(form_act_groupchase_logic) then
    form_act_groupchase_logic = nx_create("form_act_grouppurchase")
    if nx_is_valid(form_act_groupchase_logic) then
      nx_set_value("form_act_grouppurchase", form_act_groupchase_logic)
    end
  end
  if nx_is_valid(form_act_groupchase_logic) then
    itemlist = form_act_groupchase_logic:GetItemList()
  end
  if 6 ~= table.getn(strCountTotal_list) then
    nx_log("Error form_act_grouppurchase   on_server_msg")
    nx_log("strCountTotal = " .. strCountTotal)
    return
  end
  local level = 1
  for i = 1, table.getn(strCountTotal_list) do
    if nx_int(strCountTotal_list[i]) <= nx_int(cur_num) then
      level = i
    end
  end
  local next_num = 0
  if level ~= 6 then
    next_num = nx_int(strCountTotal_list[level + 1]) - cur_num
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_act_grouppurchase", true, false)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "add_sub_form", form)
  if itemlist == nil then
    nx_log("Error  form_act_grouppurchase   on_server_msg")
    nx_log("itemlist = " .. itemlist)
    return
  end
  form:Show()
  form.itemlist = itemlist
  form.level = level
  form.strCountTotal = strCountTotal
  local list = util_split_string(itemlist, "|")
  local item_count = 0
  for i = 1, table.getn(list) do
    local info_list = util_split_string(list[i], ";")
    if 6 <= table.getn(info_list) and table.getn(info_list) <= 11 then
      item_count = item_count + 1
    end
  end
  if item_count <= 1 then
    item_count = 1
  end
  form.max_page = nx_int((item_count - 1) / 4)
  set_page_info(form)
  show_item(form, itemlist, level, strCountTotal)
  show_member_count(form, cur_num, next_num, apply_flag)
  show_left_time(form, remain_time, week, status)
  update_form(form)
end
function update_form(form)
end
function show_item(form, itemlist, level, strCountTotal)
  if not nx_is_valid(form) then
    return
  end
  if level < 1 or 6 < level then
    nx_log("Error  form_act_grouppurchase   show_item")
    nx_log("level = " .. nx_string(level))
    return
  end
  local cur_page = form.cur_page
  set_page_info(form)
  local ctrl_table = {
    [1] = {
      [1] = form.lbl_baseprice_1,
      [2] = form.lbl_cur_price_1_1,
      [3] = form.lbl_cur_price_1_2,
      [4] = form.lbl_cur_price_1_3,
      [5] = form.lbl_cur_price_1_4,
      [6] = form.lbl_cur_price_1_5,
      [7] = form.ImageControlGrid_1,
      [8] = form.mltbox_intro_1,
      [9] = "ui_grouppurchase_tips_1",
      [10] = form.lbl_1_line,
      [11] = form.btn_buy_1,
      [12] = form.groupbox_1,
      [13] = form.ICG_sub_1_1,
      [14] = form.ICG_sub_1_2,
      [15] = form.ICG_sub_1_3,
      [16] = form.ICG_sub_1_4,
      [17] = form.btn_1_left,
      [18] = form.btn_1_right,
      [19] = form.lbl_1_index,
      [20] = form.mltbox_base_price_1,
      [21] = form.mltbox_now_price_1,
      [22] = form.lbl_zhutu_1_1,
      [23] = form.lbl_zhutu_1_2,
      [24] = form.lbl_zhutu_1_3,
      [25] = form.lbl_zhutu_1_4,
      [26] = form.lbl_zhutu_1_5,
      [27] = form.lbl_zhutu_1_6,
      [28] = form.lbl_renshu_1_1,
      [29] = form.lbl_renshu_1_2,
      [30] = form.lbl_renshu_1_3,
      [31] = form.lbl_renshu_1_4,
      [32] = form.lbl_renshu_1_5,
      [33] = form.lbl_renshu_1_6,
      [34] = form.lbl_name_1_1,
      [35] = form.lbl_name_1_2,
      [36] = form.lbl_name_1_3,
      [37] = form.lbl_name_1_4
    },
    [2] = {
      [1] = form.lbl_baseprice_2,
      [2] = form.lbl_cur_price_2_1,
      [3] = form.lbl_cur_price_2_2,
      [4] = form.lbl_cur_price_2_3,
      [5] = form.lbl_cur_price_2_4,
      [6] = form.lbl_cur_price_2_5,
      [7] = form.ImageControlGrid_2,
      [8] = form.mltbox_intro_2,
      [9] = "ui_grouppurchase_tips_2",
      [10] = form.lbl_2_line,
      [11] = form.btn_buy_2,
      [12] = form.groupbox_2,
      [13] = form.ICG_sub_2_1,
      [14] = form.ICG_sub_2_2,
      [15] = form.ICG_sub_2_3,
      [16] = form.ICG_sub_2_4,
      [17] = form.btn_2_left,
      [18] = form.btn_2_right,
      [19] = form.lbl_2_index,
      [20] = form.mltbox_base_price_2,
      [21] = form.mltbox_now_price_2,
      [22] = form.lbl_zhutu_2_1,
      [23] = form.lbl_zhutu_2_2,
      [24] = form.lbl_zhutu_2_3,
      [25] = form.lbl_zhutu_2_4,
      [26] = form.lbl_zhutu_2_5,
      [27] = form.lbl_zhutu_2_6,
      [28] = form.lbl_renshu_2_1,
      [29] = form.lbl_renshu_2_2,
      [30] = form.lbl_renshu_2_3,
      [31] = form.lbl_renshu_2_4,
      [32] = form.lbl_renshu_2_5,
      [33] = form.lbl_renshu_2_6,
      [34] = form.lbl_name_2_1,
      [35] = form.lbl_name_2_2,
      [36] = form.lbl_name_2_3,
      [37] = form.lbl_name_2_4
    },
    [3] = {
      [1] = form.lbl_baseprice_3,
      [2] = form.lbl_cur_price_3_1,
      [3] = form.lbl_cur_price_3_2,
      [4] = form.lbl_cur_price_3_3,
      [5] = form.lbl_cur_price_3_4,
      [6] = form.lbl_cur_price_3_5,
      [7] = form.ImageControlGrid_3,
      [8] = form.mltbox_intro_3,
      [9] = "ui_grouppurchase_tips_3",
      [10] = form.lbl_3_line,
      [11] = form.btn_buy_3,
      [12] = form.groupbox_3,
      [13] = form.ICG_sub_3_1,
      [14] = form.ICG_sub_3_2,
      [15] = form.ICG_sub_3_3,
      [16] = form.ICG_sub_3_4,
      [17] = form.btn_3_left,
      [18] = form.btn_3_right,
      [19] = form.lbl_3_index,
      [20] = form.mltbox_base_price_3,
      [21] = form.mltbox_now_price_3,
      [22] = form.lbl_zhutu_3_1,
      [23] = form.lbl_zhutu_3_2,
      [24] = form.lbl_zhutu_3_3,
      [25] = form.lbl_zhutu_3_4,
      [26] = form.lbl_zhutu_3_5,
      [27] = form.lbl_zhutu_3_6,
      [28] = form.lbl_renshu_3_1,
      [29] = form.lbl_renshu_3_2,
      [30] = form.lbl_renshu_3_3,
      [31] = form.lbl_renshu_3_4,
      [32] = form.lbl_renshu_3_5,
      [33] = form.lbl_renshu_3_6,
      [34] = form.lbl_name_3_1,
      [35] = form.lbl_name_3_2,
      [36] = form.lbl_name_3_3,
      [37] = form.lbl_name_3_4
    },
    [4] = {
      [1] = form.lbl_baseprice_4,
      [2] = form.lbl_cur_price_4_1,
      [3] = form.lbl_cur_price_4_2,
      [4] = form.lbl_cur_price_4_3,
      [5] = form.lbl_cur_price_4_4,
      [6] = form.lbl_cur_price_4_5,
      [7] = form.ImageControlGrid_4,
      [8] = form.mltbox_intro_4,
      [9] = "ui_grouppurchase_tips_4",
      [10] = form.lbl_4_line,
      [11] = form.btn_buy_4,
      [12] = form.groupbox_4,
      [13] = form.ICG_sub_4_1,
      [14] = form.ICG_sub_4_2,
      [15] = form.ICG_sub_4_3,
      [16] = form.ICG_sub_4_4,
      [17] = form.btn_4_left,
      [18] = form.btn_4_right,
      [19] = form.lbl_4_index,
      [20] = form.mltbox_base_price_4,
      [21] = form.mltbox_now_price_4,
      [22] = form.lbl_zhutu_4_1,
      [23] = form.lbl_zhutu_4_2,
      [24] = form.lbl_zhutu_4_3,
      [25] = form.lbl_zhutu_4_4,
      [26] = form.lbl_zhutu_4_5,
      [27] = form.lbl_zhutu_4_6,
      [28] = form.lbl_renshu_4_1,
      [29] = form.lbl_renshu_4_2,
      [30] = form.lbl_renshu_4_3,
      [31] = form.lbl_renshu_4_4,
      [32] = form.lbl_renshu_4_5,
      [33] = form.lbl_renshu_4_6,
      [34] = form.lbl_name_4_1,
      [35] = form.lbl_name_4_2,
      [36] = form.lbl_name_4_3,
      [37] = form.lbl_name_4_4
    }
  }
  local zhutu_table = {
    [1] = "gui\\special\\grouppurchase\\bg_lv1_on.png",
    [2] = "gui\\special\\grouppurchase\\bg_lv2_on.png",
    [3] = "gui\\special\\grouppurchase\\bg_lv3_on.png",
    [4] = "gui\\special\\grouppurchase\\bg_lv4_on.png",
    [5] = "gui\\special\\grouppurchase\\bg_lv5_on.png",
    [6] = "gui\\special\\grouppurchase\\bg_lv6_on.png"
  }
  local item_list = util_split_string(itemlist, "|")
  local item_count = 0
  for i = 1, table.getn(item_list) do
    local item_info_list = util_split_string(item_list[i], ";")
    if 6 <= table.getn(item_info_list) and 11 >= table.getn(item_info_list) then
      item_count = item_count + 1
    else
      nx_log("Error form_act_grouppurchase   show_item")
      nx_log("i = " .. nx_string(i) .. "," .. "item_list[i]" .. item_list[i])
    end
  end
  for i = 1, 4 do
    if item_count < cur_page * 4 + i then
      ctrl_table[i][12].Visible = false
    else
      ctrl_table[i][12].Visible = true
      ctrl_table[i][34].Visible = false
      ctrl_table[i][35].Visible = false
      ctrl_table[i][36].Visible = false
      ctrl_table[i][37].Visible = false
    end
  end
  for i = 1, 4 do
    ctrl_table[i][17].index = i
    ctrl_table[i][18].index = i
    ctrl_table[i][17].dir = "left"
    ctrl_table[i][18].dir = "right"
    ctrl_table[i][19].Text = nx_widestr("1")
  end
  local mgr = nx_value("CapitalModule")
  for i = 1, 4 do
    if item_count < cur_page * 4 + i then
      ctrl_table[i][12].Visible = false
    end
    ctrl_table[i][12].BackImage = "gui\\special\\grouppurchase\\bg_fc_2.png"
    clear_imagegrid(ctrl_table[i][7])
    ctrl_table[i][11].item_id = ""
    ctrl_table[i][8]:Clear()
    ctrl_table[i][17].Visible = false
    ctrl_table[i][18].Visible = false
    ctrl_table[i][19].Visible = false
    ctrl_table[i][19].str_sub_itemid = ""
    for j = 1, 4 do
      clear_imagegrid(ctrl_table[i][j + 12])
      ctrl_table[i][j + 33].Text = nx_widestr("")
    end
    for m = 1, 6 do
      ctrl_table[i][27 + m].Text = nx_widestr("")
      ctrl_table[i][m].Text = nx_widestr("")
    end
    ctrl_table[i][20]:Clear()
    ctrl_table[i][21]:Clear()
    local item_info_list = util_split_string(item_list[cur_page * 4 + i], ";")
    if 6 <= table.getn(item_info_list) and 11 >= table.getn(item_info_list) then
      local item_id = item_info_list[1]
      init_imagegrid(ctrl_table[i][7], item_id .. "/" .. "1")
      ctrl_table[i][11].item_id = item_id
      ctrl_table[i][8]:Clear()
      ctrl_table[i][8]:AddHtmlText(util_text(item_id), nx_int(-1))
      if item_info_list[2] == "1" then
        ctrl_table[i][12].BackImage = "grouppurchase_1"
      end
      ctrl_table[i][19].str_sub_itemid = item_info_list[3]
      local sub_itemid_list = util_split_string(item_info_list[3], ",")
      if table.getn(sub_itemid_list) ~= 0 then
        for j = 1, 4 do
          clear_imagegrid(ctrl_table[i][j + 12])
          if j <= table.getn(sub_itemid_list) then
            init_imagegrid(ctrl_table[i][j + 12], sub_itemid_list[j])
            local tab = util_split_string(sub_itemid_list[j], "/")
            if table.getn(tab) == 2 then
              ctrl_table[i][j + 33].Text = util_text(tab[1])
            end
          end
        end
      end
      if 4 < table.getn(sub_itemid_list) then
        ctrl_table[i][17].Visible = true
        ctrl_table[i][18].Visible = true
        ctrl_table[i][19].Visible = true
      end
      local condition_mgr = nx_value("ConditionManager")
      local client_player = get_player()
      if nx_is_valid(condition_mgr) and nx_is_valid(client_player) and not condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(item_info_list[5])) then
        ctrl_table[i][11].Enable = false
      end
      local type_pos = 5
      local price_count = table.getn(item_info_list) - type_pos
      local cur_pos = 0
      if level <= price_count then
        cur_pos = level
      else
        cur_pos = price_count
      end
      local type = item_info_list[4]
      if nx_int(type) > nx_int(2) or nx_int(type) < nx_int(0) then
        nx_log("Error  form_act_grouppurchase   show_item")
        nx_log("type = " .. nx_string(type))
        return
      end
      local list = util_split_string(strCountTotal, ";")
      for m = 1, 6 do
        ctrl_table[i][27 + m].Text = nx_widestr(nx_string(list[m])) .. util_format_string("ui_ren")
        if m <= price_count then
          ctrl_table[i][m].Text = get_item_info_text(type, item_info_list[m + type_pos])
        else
          ctrl_table[i][m].Text = nx_widestr("")
        end
      end
      ctrl_table[i][cur_pos].ForeColor = "255,255,0,0"
      ctrl_table[i][21 + cur_pos].BackImage = zhutu_table[cur_pos]
      ctrl_table[i][27 + cur_pos].ForeColor = "255,255,0,0"
      local str_base_price = mgr:GetFormatCapitalHtml(nx_int(type), nx_int64(item_info_list[type_pos + 1]))
      local str_cur_price = mgr:GetFormatCapitalHtml(nx_int(type), nx_int64(item_info_list[type_pos + cur_pos]))
      ctrl_table[i][20]:Clear()
      ctrl_table[i][20]:AddHtmlText(str_base_price, nx_int(-1))
      ctrl_table[i][21]:Clear()
      ctrl_table[i][21]:AddHtmlText(str_cur_price, nx_int(-1))
    end
  end
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function show_item_next(form, itemlist_next)
  local ctrl_table_next = {
    [1] = form.ImageControlGrid1,
    [2] = form.ImageControlGrid2,
    [3] = form.ImageControlGrid3,
    [4] = form.ImageControlGrid4,
    [5] = form.ImageControlGrid5,
    [6] = form.ImageControlGrid6,
    [7] = form.ImageControlGrid7,
    [8] = form.ImageControlGrid8,
    [9] = form.groupbox_image1,
    [10] = form.groupbox_image2,
    [11] = form.groupbox_image3,
    [12] = form.groupbox_image4,
    [13] = form.groupbox_image5,
    [14] = form.groupbox_image6,
    [15] = form.groupbox_image7,
    [16] = form.groupbox_image8
  }
  local item_list_next = util_split_string(itemlist_next, "|")
  for i = 1, 8 do
    if i > table.getn(item_list_next) then
      return
    end
    local item_info_list_next = util_split_string(item_list_next[i], ";")
    if 2 <= table.getn(item_info_list_next) then
      local item_id = item_info_list_next[1] .. "/" .. "1"
      local imagegrid = ctrl_table_next[i]
      clear_imagegrid(imagegrid)
      init_imagegrid(imagegrid, item_id)
      if item_info_list_next[2] == "1" then
        ctrl_table_next[i + 8].BackImage = "grouppurchase_2"
      else
        ctrl_table_next[i + 8].BackImage = ""
      end
    end
  end
end
function clear_imagegrid(imagegrid)
  imagegrid:DelItem(0)
  imagegrid.item_id = nil
  imagegrid.item_type = nil
  imagegrid.item_count = 0
end
function init_imagegrid(imagegrid, item_info)
  local tab = util_split_string(item_info, "/")
  if table.getn(tab) ~= 2 then
    nx_log("Error form_act_grouppurchase   init_imagegrid")
    nx_log("item_info = " .. nx_string(item_info))
    return
  end
  item_id = tab[1]
  item_count = tab[2]
  imagegrid.item_id = tab[1]
  imagegrid.item_count = tab[2]
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_id, "Photo")
  imagegrid:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
  local ItemQuery = nx_value("ItemQuery")
  local item_type = ItemQuery:GetItemPropByConfigID(item_id, "ItemType")
  imagegrid.item_type = item_type
  nx_bind_script(imagegrid, nx_current())
  nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
end
function on_imagegrid_mousein_grid(imagegrid)
  if imagegrid.item_id == nil then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_common", imagegrid.item_id, nx_number(imagegrid.item_type), x, y, imagegrid.ParentForm)
end
function on_imagegrid_mouseout_grid(imagegrid)
  if imagegrid.item_id == nil then
    return
  end
  nx_execute("tips_game", "hide_tip", imagegrid.ParentForm)
end
function get_item_info_text(type, num)
  local mgr = nx_value("CapitalModule")
  if nx_is_valid(mgr) then
    return mgr:FormatCapital(nx_int(type), nx_int64(num))
  end
end
function show_member_count(form, cur_num, next_num, apply_flag)
  if nx_int(apply_flag) == nx_int(0) then
    form.btn_join.Enabled = true
    form.btn_join.Text = util_format_string("ui_grouppurchase_join")
  else
    form.btn_join.Enabled = false
    form.btn_join.Text = util_format_string("ui_grouppurchase_isjoin")
  end
  form.lbl_join_No.Text = nx_widestr(nx_string(cur_num))
  if nx_int(0) >= nx_int(next_num) then
    form.lbl_member.Text = nx_widestr("")
    form.lbl_Next_No.Text = nx_widestr("")
  else
    form.lbl_member.Text = util_format_string("ui_grouppurchase_nextlevel")
    form.lbl_Next_No.Text = nx_widestr(nx_string(next_num))
  end
end
function show_left_time(form, remain_time, week, status)
  if nx_int(status) == nx_int(0) then
    form.lbl_time_title.Text = util_format_string("ui_grouppurchase_jointime_ready")
  elseif nx_int(status) == nx_int(1) then
    form.lbl_time_title.Text = util_format_string("ui_grouppurchase_jointime")
  elseif nx_int(status) == nx_int(2) then
    form.lbl_time_title.Text = util_format_string("ui_grouppurchase_purchasetime_ready")
  elseif nx_int(status) == nx_int(3) then
    form.lbl_time_title.Text = util_format_string("ui_grouppurchase_purchasetime")
  end
  local str = "{@0:d}{@1:d}{@2:h}{@3:h}{@4:min}{@5:min}"
  if remain_time == nil or remain_time == 0 then
    form.lbl_time.Text = nx_widestr("")
  end
  local day = nx_int(remain_time / 1440)
  remain_time = remain_time % 1440
  local hour = nx_int(remain_time / 60)
  local minu = nx_int(remain_time % 60)
  form.lbl_time.Text = util_format_string(str, day, "ui_g_day", hour, "ui_g_hour", minu, "ui_g_minute")
  local table_week = {
    [1] = form.lbl_w1_back,
    [2] = form.lbl_w2_back,
    [3] = form.lbl_w3_back,
    [4] = form.lbl_w4_back,
    [5] = form.lbl_w5_back,
    [6] = form.lbl_w6_back,
    [7] = form.lbl_w7_back
  }
  for i = 1, 7 do
    if nx_int(week) == nx_int(i) then
      table_week[i].BackImage = "gui\\special\\grouppurchase\\line_yellow.png"
    else
      table_week[i].BackImage = ""
    end
  end
end
function on_btn_buy_click(btn)
  nx_execute("custom_sender", "custom_group_purchase_msg", nx_int(2), btn.item_id)
end
function on_btn_join_click(btn)
  nx_execute("custom_sender", "custom_group_purchase_msg", nx_int(1), "")
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_click(btn)
  if btn.index == nil or btn.dir == nil then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ctrl_tab = {
    [1] = form.lbl_1_index,
    [2] = form.lbl_2_index,
    [3] = form.lbl_3_index,
    [4] = form.lbl_4_index
  }
  local index = btn.index
  local val = nx_int(ctrl_tab[index].Text)
  local str_item_info = ctrl_tab[index].str_sub_itemid
  if btn.dir == "left" and nx_int(val) > nx_int(1) then
    val = val - 1
    ctrl_tab[index].Text = nx_widestr(nx_string(val))
  end
  if btn.dir == "right" then
    local sub_list = util_split_string(str_item_info, ",")
    local sub_len = table.getn(sub_list)
    local sub_size = nx_int((nx_int(sub_len) - 1) / 4) + 1
    if nx_int(val) < nx_int(sub_size) then
      val = val + 1
      ctrl_tab[index].Text = nx_widestr(nx_string(val))
    end
  end
  reset_ImageControl(form, index)
end
function reset_ImageControl(form, index)
  local lbl_tab = {
    [1] = form.lbl_1_index,
    [2] = form.lbl_2_index,
    [3] = form.lbl_3_index,
    [4] = form.lbl_4_index
  }
  local ICG_tab = {
    [1] = {
      [1] = form.ICG_sub_1_1,
      [2] = form.ICG_sub_1_2,
      [3] = form.ICG_sub_1_3,
      [4] = form.ICG_sub_1_4,
      [5] = form.lbl_name_1_1,
      [6] = form.lbl_name_1_2,
      [7] = form.lbl_name_1_3,
      [8] = form.lbl_name_1_4
    },
    [2] = {
      [1] = form.ICG_sub_2_1,
      [2] = form.ICG_sub_2_2,
      [3] = form.ICG_sub_2_3,
      [4] = form.ICG_sub_2_4,
      [5] = form.lbl_name_2_1,
      [6] = form.lbl_name_2_2,
      [7] = form.lbl_name_2_3,
      [8] = form.lbl_name_2_4
    },
    [3] = {
      [1] = form.ICG_sub_3_1,
      [2] = form.ICG_sub_3_2,
      [3] = form.ICG_sub_3_3,
      [4] = form.ICG_sub_3_4,
      [5] = form.lbl_name_3_1,
      [6] = form.lbl_name_3_2,
      [7] = form.lbl_name_3_3,
      [8] = form.lbl_name_3_4
    },
    [4] = {
      [1] = form.ICG_sub_4_1,
      [2] = form.ICG_sub_4_2,
      [3] = form.ICG_sub_4_3,
      [4] = form.ICG_sub_4_4,
      [5] = form.lbl_name_4_1,
      [6] = form.lbl_name_4_2,
      [7] = form.lbl_name_4_3,
      [8] = form.lbl_name_4_4
    }
  }
  local val = nx_int(lbl_tab[index].Text)
  local str_item_info = lbl_tab[index].str_sub_itemid
  local sub_list = util_split_string(str_item_info, ",")
  for j = 1, 4 do
    clear_imagegrid(ICG_tab[index][j])
    ICG_tab[index][j + 4].Text = ""
    if (val - 1) * 4 + j <= table.getn(sub_list) then
      init_imagegrid(ICG_tab[index][j], sub_list[(val - 1) * 4 + j])
      if ICG_tab[index][j].item_id ~= nil then
        ICG_tab[index][j + 4].Text = util_text(ICG_tab[index][j].item_id)
      end
    end
  end
end
function set_page_info(form)
  form.lbl_pageinfo.Text = nx_widestr(nx_string(form.cur_page + 1)) .. nx_widestr("/") .. nx_widestr(nx_string(form.max_page + 1))
  if form.max_page == 0 then
    form.lbl_next_tips.Visible = false
  end
end
function on_btn_prev_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cur_page > 0 then
    form.cur_page = form.cur_page - 1
    form.lbl_next_tips.Visible = form.cur_page < form.max_page
    show_item(form, form.itemlist, form.level, form.strCountTotal)
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cur_page < form.max_page then
    form.cur_page = form.cur_page + 1
    form.lbl_next_tips.Visible = form.cur_page < form.max_page
    show_item(form, form.itemlist, form.level, form.strCountTotal)
  end
end
