require("utils")
require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("util_static_data")
require("tips_data")
require("define\\sysinfo_define")
require("share\\capital_define")
require("role_composite")
local FORM_NAME = "form_stage_main\\form_linxiao\\form_linxiao_exchange"
local SSF_HURT_REC = "SsfHurtRec"
LINXIAO_MASTER = 1
LINXIAO_EXCHANGE = 2
LINXIAO_EXCHANGE_CLOSE = 1
LINXIAO_EXCHANGE_TOOL = 2
LINXIAO_EXCHANGE_JINGMAI = 3
LINXIAO_EXCHANGE_JIFEN_GET_JINGMAI_ITEM = 4
EXCHANGE_JIFEN = 1
EXCHANGE_ZHENGYIN = 2
EXCHANGE_JINGMAI_JIFEN = 3
LINXIAO_EXCHANGE_ITEM_NO_BIND = 0
LINXIAO_EXCHANGE_ITEM_BIND = 1
SSFHR_JINGMAI = 0
SSFHR_NUM = 1
SSFHR_INTEGRAL = 2
SSFHR_TASK_ID = 3
local jingmai_table = {}
function main_form_init(form)
  form.Fixed = true
  jingmai_table = {}
  local ini = nx_execute("util_functions", "get_ini", "share\\Item\\item_linxiao_exchange.ini")
  if not nx_is_valid(ini) then
    return
  end
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return
  end
  form.ini = ini
  form.SelectExchangeIndex = LINXIAO_EXCHANGE_CLOSE
  form.SelectPage_1 = 1
  form.SelectPage_2 = 1
  form.SelectPage_3 = 1
  form.SelectPage_4 = 1
  if form.ini:FindSection(nx_string(nx_int(LINXIAO_EXCHANGE_JINGMAI))) then
    local sec_index = form.ini:FindSectionIndex(nx_string(nx_int(LINXIAO_EXCHANGE_JINGMAI)))
    if sec_index < 0 then
      return
    end
    local sects_list_table = form.ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
    for i = 1, table.getn(sects_list_table) do
      local str_lst = nx_function("ext_split_string", sects_list_table[i], ",")
      if table.getn(str_lst) < 6 then
        return
      end
      table.insert(jingmai_table, str_lst[4])
    end
  end
  if form.ini:FindSection(nx_string(nx_int(LINXIAO_EXCHANGE_JIFEN_GET_JINGMAI_ITEM))) then
    local sec_index = form.ini:FindSectionIndex(nx_string(nx_int(LINXIAO_EXCHANGE_JIFEN_GET_JINGMAI_ITEM)))
    if sec_index < 0 then
      return
    end
    local sects_list_table = form.ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
    for i = 1, table.getn(sects_list_table) do
      local str_lst = nx_function("ext_split_string", sects_list_table[i], ",")
      if table.getn(str_lst) < 6 then
        return
      end
      table.insert(jingmai_table, str_lst[4])
    end
  end
end
function on_main_form_open(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.jingmai_combobox.Visible = false
  fresh_show_role_ctrl(form)
  fresh_exchange_info(form, form.SelectExchangeIndex)
  fill_jingmai_drop_list_box(form)
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return 0
  end
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("SsfIntegral", "int", form, nx_current(), "on_fill_SsfIntegral_ctrl")
  databinder:AddTableBind(SSF_HURT_REC, form, nx_current(), "on_fill_jingmai_jifen_ctrl")
  fill_get_jifen_way_ctrl(form)
  form.lbl_jingmai_jifen.Visible = false
  fill_jingmai_jifen_ctrl(form)
end
function on_fill_SsfIntegral_ctrl(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) then
      jifen = client_player:QueryProp("SsfIntegral")
      form.lbl_jifen.Text = gui.TextManager:GetFormatText("ui_linxiao_exchange_item_xljifen", nx_int(jifen))
    end
  end
end
function on_fill_jingmai_jifen_ctrl(form, recordname, optype, row, clomn)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local jingmai_id = client_player:QueryRecord(SSF_HURT_REC, row, SSFHR_JINGMAI)
  if nx_string(form.jingmai_combobox.DropListBox:GetString(nx_int(form.jingmai_combobox.DropListBox.SelectIndex))) == nx_string(gui.TextManager:GetText(nx_string(jingmai_id))) then
    form.lbl_jingmai_jifen.Text = gui.TextManager:GetFormatText("ui_linxiao_exchange_item_xljingmai_jifen", nx_int(client_player:QueryRecord(SSF_HURT_REC, row, SSFHR_INTEGRAL)))
  end
end
function fill_get_jifen_way_ctrl(form)
  local gui = nx_value("gui")
  local info = "ui_linxiao_exchange_jifen_desc"
  if nx_int(form.SelectExchangeIndex) == nx_int(LINXIAO_EXCHANGE_JINGMAI) then
    info = "ui_linxiao_exchange_fuyin_desc"
  end
  form.mltbox_get_jifen_way.HtmlText = nx_widestr(gui.TextManager:GetText(nx_string(info)))
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  if nx_is_valid(self.actor2) then
    remove_role(self.actor2)
  end
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function fresh_exchange_info(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local ClientPlayer = game_client:GetPlayer()
  if not nx_is_valid(ClientPlayer) then
    return
  end
  local sex = 0
  if ClientPlayer:FindProp("Sex") then
    sex = ClientPlayer:QueryProp("Sex")
  end
  local gui = nx_value("gui")
  if not nx_find_custom(form, "ini") then
    return
  end
  if not nx_find_custom(form, "SelectExchangeIndex") then
    return
  end
  local index = form.SelectExchangeIndex
  if form.ini:FindSection(nx_string(index)) then
    local sec_index = form.ini:FindSectionIndex(nx_string(index))
    if sec_index < 0 then
      return
    end
    hide_ctrl(form)
    local select_jingmai = ""
    if nx_int(index) == nx_int(LINXIAO_EXCHANGE_JINGMAI) or nx_int(index) == nx_int(LINXIAO_EXCHANGE_JIFEN_GET_JINGMAI_ITEM) then
      select_jingmai = form.jingmai_combobox.DropListBox:GetString(nx_int(form.jingmai_combobox.DropListBox.SelectIndex))
    end
    local sects_list_table = form.ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
    local can_add_item_count = 1
    local ctrl_index = 1
    for i = 1, table.getn(sects_list_table) do
      local str_lst = nx_function("ext_split_string", sects_list_table[i], ",")
      if table.getn(str_lst) < 6 then
        return
      end
      local direct_fill = true
      if (nx_int(index) == nx_int(LINXIAO_EXCHANGE_JINGMAI) or nx_int(index) == nx_int(LINXIAO_EXCHANGE_JIFEN_GET_JINGMAI_ITEM)) and nx_string(select_jingmai) ~= nx_string(gui.TextManager:GetText(str_lst[4])) then
        direct_fill = false
      end
      local page = 0
      if nx_int(0) == nx_int(can_add_item_count % 9) then
        page = nx_int(can_add_item_count / 9)
      else
        page = nx_int(can_add_item_count / 9 + 1)
      end
      if (nx_int(sex) == nx_int(str_lst[2]) or nx_int(-1) == nx_int(str_lst[2])) and direct_fill then
        if nx_int(page) == nx_int(get_select_page(form)) then
          local gb_name = "gb_item_" .. nx_string(ctrl_index)
          if not nx_find_custom(form, gb_name) then
            return
          end
          local gb_ctrl = nx_custom(form, gb_name)
          gb_ctrl.Visible = true
          local lbl_exchanged_info_name = "lbl_exchanged_info_" .. nx_string(ctrl_index)
          if not nx_find_custom(form, lbl_exchanged_info_name) then
            return
          end
          local lbl_exchanged_info_ctrl = nx_custom(form, lbl_exchanged_info_name)
          local btn_item_exchange_name = "btn_item_exchange_" .. nx_string(ctrl_index)
          if not nx_find_custom(form, btn_item_exchange_name) then
            return
          end
          local btn_item_exchange_name_ctrl = nx_custom(form, btn_item_exchange_name)
          if nx_int(EXCHANGE_ZHENGYIN) == nx_int(str_lst[5]) then
            lbl_exchanged_info_ctrl.HtmlText = gui.TextManager:GetFormatText("ui_linxiao_exchange_item_zhengyin", nx_int(str_lst[6]))
            btn_item_exchange_name_ctrl.Text = gui.TextManager:GetFormatText("ui_linxiao_exchange_zhengyin")
          elseif nx_int(EXCHANGE_JIFEN) == nx_int(str_lst[5]) then
            lbl_exchanged_info_ctrl.HtmlText = gui.TextManager:GetFormatText("ui_linxiao_exchange_item_jifen", nx_int(str_lst[6]))
            btn_item_exchange_name_ctrl.Text = gui.TextManager:GetFormatText("ui_linxiao_exchange_jifen")
          elseif nx_int(EXCHANGE_JINGMAI_JIFEN) == nx_int(str_lst[5]) then
            lbl_exchanged_info_ctrl.HtmlText = gui.TextManager:GetFormatText("ui_linxiao_exchange_item_jingmai_jifen", nx_int(str_lst[6]))
            btn_item_exchange_name_ctrl.Text = gui.TextManager:GetFormatText("ui_linxiao_exchange_jifen")
          end
          btn_item_exchange_name_ctrl.ExchangeItemInfo = sects_list_table[i]
          btn_item_exchange_name_ctrl.CostValue = nx_int(str_lst[6])
          local lbl_exchange_item_bind_info = "lbl_bind_" .. nx_string(ctrl_index)
          if not nx_find_custom(form, lbl_exchange_item_bind_info) then
            return
          end
          local lbl_exchange_item_bind_info_ctrl = nx_custom(form, lbl_exchange_item_bind_info)
          if nx_int(LINXIAO_EXCHANGE_ITEM_BIND) == nx_int(str_lst[3]) then
            lbl_exchange_item_bind_info_ctrl.Text = gui.TextManager:GetFormatText("ui_linxiao_exchange_bind_item")
          elseif nx_int(LINXIAO_EXCHANGE_ITEM_NO_BIND) == nx_int(str_lst[3]) then
            lbl_exchange_item_bind_info_ctrl.Text = gui.TextManager:GetFormatText("ui_linxiao_exchange_no_bind_item")
          end
          local img_exchange_item_name = "img_exchange_item_" .. nx_string(ctrl_index)
          if not nx_find_custom(form, img_exchange_item_name) then
            return
          end
          local img_exchange_item_ctrl = nx_custom(form, img_exchange_item_name)
          local item_id = str_lst[1]
          local item_type = nx_number(get_prop_in_ItemQuery(item_id, nx_string("ItemType")))
          local photo = ""
          if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
            photo = item_query_ArtPack_by_id(item_id, "Photo")
          else
            photo = get_prop_in_ItemQuery(item_id, nx_string("Photo"))
          end
          img_exchange_item_ctrl:AddItem(0, nx_string(photo), nx_widestr(item_id), 0, 0)
          img_exchange_item_ctrl.config_id = item_id
          local lbl_exchange_item_title_name = "lbl_exchange_item_title_" .. nx_string(ctrl_index)
          if not nx_find_custom(form, lbl_exchange_item_title_name) then
            return
          end
          local lbl_exchange_item_title_ctrl = nx_custom(form, lbl_exchange_item_title_name)
          lbl_exchange_item_title_ctrl.Text = nx_widestr(gui.TextManager:GetText(nx_string(item_id)))
          ctrl_index = ctrl_index + 1
        end
        can_add_item_count = can_add_item_count + 1
      end
    end
    if nx_int(0) == nx_int((can_add_item_count - 1) % 9) then
      form.lbl_pags.Text = nx_widestr(nx_int((can_add_item_count - 1) / 9))
    else
      form.lbl_pags.Text = nx_widestr(nx_int((can_add_item_count - 1) / 9) + 1)
    end
    form.ipt_1.Text = nx_widestr(get_select_page(form))
  end
end
function on_item_exchange_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  if nx_int(rbtn.TabIndex) == nx_int(LINXIAO_EXCHANGE_JINGMAI) or nx_int(rbtn.TabIndex) == nx_int(LINXIAO_EXCHANGE_JIFEN_GET_JINGMAI_ITEM) then
    form.jingmai_combobox.Visible = true
  else
    form.jingmai_combobox.Visible = false
  end
  if nx_int(rbtn.TabIndex) == nx_int(LINXIAO_EXCHANGE_JINGMAI) then
    form.lbl_jingmai_jifen.Visible = true
    form.lbl_jifen.Visible = false
  else
    form.lbl_jingmai_jifen.Visible = false
    form.lbl_jifen.Visible = true
  end
  form.SelectExchangeIndex = rbtn.TabIndex
  fresh_exchange_info(form)
  fill_get_jifen_way_ctrl(form)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function hide_ctrl(form)
  form.gb_item_1.Visible = false
  form.gb_item_2.Visible = false
  form.gb_item_3.Visible = false
  form.gb_item_4.Visible = false
  form.gb_item_5.Visible = false
  form.gb_item_6.Visible = false
  form.gb_item_7.Visible = false
  form.gb_item_8.Visible = false
  form.gb_item_9.Visible = false
end
function on_grid_mousein_grid(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "config_id") then
    return
  end
  local config_id = grid.config_id
  if nx_string(config_id) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = config_id
  item.ItemType = ItemQuery:GetItemPropByConfigID(nx_string(configid), "ItemType")
  item.BindStatus = ItemQuery:GetItemPropByConfigID(nx_string(configid), "BindStatus")
  nx_execute("tips_game", "show_goods_tip", item, x, y, 0, 0, form)
end
function on_grid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_img_exchange_item_select_changed(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.SelectExchangeIndex) ~= nx_int(LINXIAO_EXCHANGE_CLOSE) then
    return
  end
  if not nx_find_custom(grid, "config_id") then
    return
  end
  local config_id = grid.config_id
  if nx_string(config_id) == nx_string("") then
    return
  end
  change_equip(form, config_id)
end
function on_btn_right_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local max_pages = nx_int(form.lbl_pags.Text)
  if nx_int(get_select_page(form) + 1) >= nx_int(max_pages) then
    set_select_page(form, nx_int(max_pages))
  else
    set_select_page(form, nx_int(get_select_page(form)) + 1)
  end
  fresh_exchange_info(form)
end
function on_btn_left_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(get_select_page(form) - 1) <= nx_int(0) then
    set_select_page(form, nx_int(1))
  else
    set_select_page(form, nx_int(get_select_page(form)) - 1)
  end
  fresh_exchange_info(form)
end
function set_select_page(form, num)
  if nx_int(LINXIAO_EXCHANGE_CLOSE) == nx_int(form.SelectExchangeIndex) then
    form.SelectPage_1 = num
  elseif nx_int(LINXIAO_EXCHANGE_TOOL) == nx_int(form.SelectExchangeIndex) then
    form.SelectPage_2 = num
  elseif nx_int(LINXIAO_EXCHANGE_JINGMAI) == nx_int(form.SelectExchangeIndex) then
    form.SelectPage_3 = num
  elseif nx_int(LINXIAO_EXCHANGE_JIFEN_GET_JINGMAI_ITEM) == nx_int(form.SelectExchangeIndex) then
    form.SelectPage_4 = num
  end
end
function get_select_page(form)
  if nx_int(LINXIAO_EXCHANGE_CLOSE) == nx_int(form.SelectExchangeIndex) then
    return form.SelectPage_1
  elseif nx_int(LINXIAO_EXCHANGE_TOOL) == nx_int(form.SelectExchangeIndex) then
    return form.SelectPage_2
  elseif nx_int(LINXIAO_EXCHANGE_JINGMAI) == nx_int(form.SelectExchangeIndex) then
    return form.SelectPage_3
  elseif nx_int(LINXIAO_EXCHANGE_JIFEN_GET_JINGMAI_ITEM) == nx_int(nx_int(form.SelectExchangeIndex)) then
    return form.SelectPage_4
  end
end
function on_ipt_1_changed(ctrl)
  local form = ctrl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local max_pages = nx_int(form.lbl_pags.Text)
  if nx_int(form.ipt_1.Text) <= nx_int(0) then
    form.ipt_1.Text = nx_widestr(1)
  elseif nx_int(form.ipt_1.Text) > nx_int(max_pages) then
    form.ipt_1.Text = nx_widestr(max_pages)
  end
end
function on_btn_10_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  set_select_page(form, nx_int(form.ipt_1.Text))
  fresh_exchange_info(form)
end
function fresh_show_role_ctrl(form)
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local main_scene = world.MainScene
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
  end
  local client_player = game_client:GetPlayer()
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local actor2 = role_composite:CreateSceneObjectWithSubModel(form.role_box.Scene, client_player, false, false, false)
  if not nx_is_valid(actor2) then
    return
  end
  actor2.modify_face = client_player:QueryProp("ModifyFace")
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  form.actor2 = actor2
  form.body_type = client_player:QueryProp("BodyType")
  form.sex = client_player:QueryProp("Sex")
end
function on_btn_left_click(btn)
  btn.MouseDown = false
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
    end
  end
end
function on_btn_right_click(btn)
  btn.MouseDown = false
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
    end
  end
end
function change_equip(form, item_id)
  local query = nx_value("ItemQuery")
  if not nx_is_valid(query) then
    return
  end
  if item_id == "" then
    return
  end
  local itemsex = nx_number(query:GetItemPropByConfigID(item_id, "NeedSex"))
  local item_body_type = nx_number(query:GetItemPropByConfigID(item_id, "BodyType"))
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if not nx_find_custom(form, "actor2") then
    return
  end
  check_actor2_model(form, player, itemsex, item_body_type)
  local actor2 = form.actor2
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  local sex = form.sex
  nx_execute("role_composite", "unlink_skin", actor2, "Hat")
  nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "Pants")
  nx_execute("role_composite", "unlink_skin", actor2, "cloak")
  role_composite:UnPlayerSkin(actor2, "cloth_h")
  local cloth = item_query_ArtPack_by_id_Ex(item_id, sex)
  if cloth ~= "" then
    nx_execute("role_composite", "link_skin", actor2, "cloth", nx_string(cloth) .. ".xmod")
    nx_execute("role_composite", "link_skin", actor2, "cloth_h", nx_string(cloth) .. "_h.xmod")
  end
  local model_table = {
    "HatArtPack",
    "PlantsArtPack",
    "ShoesArtPack"
  }
  local model_name = {
    "hat",
    "pants",
    "shoes"
  }
  local size = table.getn(model_table)
  for i = 1, size do
    local pack_no = get_item_info(item_id, model_table[i])
    if nx_int(pack_no) > nx_int(0) then
      local model_path = item_static_query(nx_int(pack_no), sex, STATIC_DATA_ITEM_ART)
      if model_path ~= "" then
        nx_execute("role_composite", "link_skin", actor2, model_name[i], nx_string(model_path) .. ".xmod")
      end
    end
  end
end
function check_actor2_model(form, player, item_sex, item_body_type)
  if not nx_is_valid(form) or not nx_is_valid(player) then
    return
  end
  local actor2 = form.actor2
  if nx_is_valid(actor2) and (item_sex ~= 2 and item_sex ~= form.sex or form.body_type ~= nx_int(item_body_type)) then
    remove_role(actor2)
  end
  if nx_is_valid(actor2) then
    return
  end
  local player_sex = player:QueryProp("Sex")
  if item_sex == 2 or item_sex == player_sex then
    actor2 = create_role_composite(form.role_box.Scene, true, item_sex, nil, nx_number(item_body_type))
    form.body_type = nx_int(item_body_type)
    form.actor2 = actor2
    form.sex = item_sex
    return
  end
end
function remove_role(actor2)
  if nx_is_valid(actor2) then
    while nx_call("role_composite", "is_loading", 2, actor2) do
      nx_pause(0)
    end
    local world = nx_value("world")
    world:Delete(actor2)
  end
end
function get_item_info(configid, prop)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
function fill_jingmai_drop_list_box(form)
  local gui = nx_value("gui")
  local ctl = form.jingmai_combobox
  ctl.DropListBox:ClearString()
  local jingmai_count = table.getn(jingmai_table)
  for i = 1, jingmai_count do
    if -1 == ctl.DropListBox:FindString(gui.TextManager:GetText(jingmai_table[i])) then
      ctl.DropListBox:AddString(gui.TextManager:GetText(jingmai_table[i]))
    end
  end
  ctl.DropListBox.SelectIndex = 0
  nx_bind_script(ctl.DropListBox, nx_current())
  nx_callback(ctl.DropListBox, "on_select_click", "on_jingmai_combbox_select")
  ctl.InputEdit.Text = nx_widestr(ctl.DropListBox.SelectString)
end
function on_jingmai_combbox_select(ctrl)
  local form = ctrl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = form.SelectExchangeIndex
  if nx_int(index) ~= nx_int(LINXIAO_EXCHANGE_JINGMAI) and nx_int(index) ~= nx_int(LINXIAO_EXCHANGE_JIFEN_GET_JINGMAI_ITEM) then
    return
  end
  fresh_exchange_info(form)
  fill_jingmai_jifen_ctrl(form)
end
function on_btn_item_exchange_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local need_cost_value = btn.CostValue
  if need_cost_value <= 0 then
    return
  end
  if not ShowTipDialog(btn) then
    return
  end
  if not nx_find_custom(btn, "ExchangeItemInfo") then
    return
  end
  if not nx_find_custom(btn, "CostValue") then
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
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  local str_lst = nx_function("ext_split_string", btn.ExchangeItemInfo, ",")
  if table.getn(str_lst) < 6 then
    return
  end
  local gui = nx_value("gui")
  local cur_value = 0
  local text = ""
  local isCan = false
  if nx_int(str_lst[5]) == nx_int(EXCHANGE_JIFEN) then
    if nx_int(need_cost_value) > nx_int(client_player:QueryProp("SsfIntegral")) then
      text = nx_string(gui.TextManager:GetText("sys_linxiao_exchange_jifen"))
      SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(text), CENTERINFO_PERSONAL_NO)
      return
    end
  elseif nx_int(str_lst[5]) == nx_int(EXCHANGE_ZHENGYIN) then
    if not capital:CanDecCapital(nx_int(CAPITAL_TYPE_SILVER_CARD), nx_int64(need_cost_value)) then
      text = nx_string(gui.TextManager:GetText("sys_linxiao_exchange_zhengyin"))
      SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(text), CENTERINFO_PERSONAL_NO)
      return
    end
  elseif nx_int(str_lst[5]) == nx_int(EXCHANGE_JINGMAI_JIFEN) then
    local select_jingmai = ""
    select_jingmai = form.jingmai_combobox.DropListBox:GetString(nx_int(form.jingmai_combobox.DropListBox.SelectIndex))
    local rows = client_player:GetRecordRows(SSF_HURT_REC)
    if 0 < rows then
      local finded = false
      for i = 0, rows - 1 do
        local jingmai_id = client_player:QueryRecord(SSF_HURT_REC, i, SSFHR_JINGMAI)
        if nx_string(select_jingmai) == nx_string(gui.TextManager:GetText(nx_string(jingmai_id))) then
          finded = true
          if nx_int(need_cost_value) > nx_int(client_player:QueryRecord(SSF_HURT_REC, i, SSFHR_INTEGRAL)) then
            text = nx_string(gui.TextManager:GetText("sys_linxiao_exchange_jingmai_jifen"))
            SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(text), CENTERINFO_PERSONAL_NO)
            return
          end
        end
      end
      if not finded then
        text = nx_string(gui.TextManager:GetText("sys_linxiao_exchange_jingmai_jifen"))
        SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(text), CENTERINFO_PERSONAL_NO)
        return
      end
    else
      text = nx_string(gui.TextManager:GetText("sys_linxiao_exchange_jingmai_jifen"))
      SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(text), CENTERINFO_PERSONAL_NO)
      return
    end
  end
  if table.getn(str_lst) > 6 then
    local condition_manager = nx_value("ConditionManager")
    if not nx_is_valid(condition_manager) then
      return
    end
    if not condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(str_lst[7])) then
      local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(nx_int(str_lst[7])))
      SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(condition_decs), CENTERINFO_PERSONAL_NO)
      return
    end
  end
  nx_execute("custom_sender", "custom_linxiao_exchange", nx_string(str_lst[1]), nx_int(str_lst[5]), nx_int(form.SelectExchangeIndex))
end
function ShowTipDialog(btn)
  local gui = nx_value("gui")
  if not nx_find_custom(btn, "ExchangeItemInfo") then
    return
  end
  local str_lst = nx_function("ext_split_string", btn.ExchangeItemInfo, ",")
  local context = ""
  if nx_int(str_lst[5]) == nx_int(EXCHANGE_JIFEN) or nx_int(str_lst[5]) == nx_int(EXCHANGE_JINGMAI_JIFEN) then
    context = nx_widestr(gui.TextManager:GetText("ui_linxiao_exchange_jifen_confirm"))
  elseif nx_int(str_lst[5]) == nx_int(EXCHANGE_ZHENGYIN) then
    context = nx_widestr(gui.TextManager:GetText("ui_linxiao_exchange_zhengyin_confirm"))
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, context)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
  return false
end
function fill_jingmai_jifen_ctrl(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local rows = client_player:GetRecordRows(SSF_HURT_REC)
  if 0 < rows then
    for i = 0, rows - 1 do
      local jingmai_id = client_player:QueryRecord(SSF_HURT_REC, i, SSFHR_JINGMAI)
      if nx_string(form.jingmai_combobox.DropListBox:GetString(nx_int(form.jingmai_combobox.DropListBox.SelectIndex))) == nx_string(gui.TextManager:GetText(nx_string(jingmai_id))) then
        form.lbl_jingmai_jifen.Text = gui.TextManager:GetFormatText("ui_linxiao_exchange_item_xljingmai_jifen", nx_int(client_player:QueryRecord(SSF_HURT_REC, i, SSFHR_INTEGRAL)))
        return
      end
    end
  end
  form.lbl_jingmai_jifen.Text = gui.TextManager:GetFormatText("ui_linxiao_exchange_item_xljingmai_jifen", nx_int(0))
end
