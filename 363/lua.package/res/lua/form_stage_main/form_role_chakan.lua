require("define\\object_type_define")
require("const_define")
require("util_functions")
require("util_gui")
require("role_composite")
require("share\\view_define")
require("util_static_data")
require("form_stage_main\\form_relation\\relation_define")
require("define\\sysinfo_define")
local _base_info, _equip_info, _role_name
TREASURESTARTPOS = 20
local FORM_NAME = "form_stage_main\\form_role_chakan"
GRID_MAX = 34
function get_player_info(name)
  clear_player_info()
  nx_set_value("_role_chakan_name", nx_widestr(name))
  nx_execute("custom_sender", "custom_send_get_base_info", name)
  nx_execute("custom_sender", "custom_send_get_equip_info", name)
end
function set_base_info(info)
  local sel_name = get_role_name()
  sel_name = nx_string(sel_name)
  if nil == sel_name or "" == sel_name then
    return
  end
  if nil == info then
    return
  end
  local values = util_split_string(info, ",")
  if values[1] == "-1" then
    local text = util_format_string("7910", sel_name)
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, CENTERINFO_PERSONAL_NO)
    end
  end
  local name = nx_string(values[1])
  if sel_name ~= name then
    _base_info = nil
    return
  end
  _base_info = values
  if nil ~= _equip_info then
    show_player_info()
  end
end
function set_equip_info(info)
  _equip_info = ""
  show_player_info()
end
function show_player_info()
  local form = nx_value("form_stage_main\\form_role_chakan")
  if not nx_is_valid(form) then
    util_show_form("form_stage_main\\form_role_chakan", true)
  elseif false == form.Visible then
    util_show_form("form_stage_main\\form_role_chakan", false)
    util_show_form("form_stage_main\\form_role_chakan", true)
  else
    clear_base_info(form)
    clear_equip_info(form)
    clear_role_model(form)
    show_base_info(form, _base_info)
    show_equip_info(form, _equip_info)
    show_role_model(form)
    show_shane_info(form, _base_info)
  end
  if nx_is_valid(form) then
    form.gb_self_shan_e.Visible = false
  end
end
function clear_player_info()
  local form = nx_value("form_stage_main\\form_role_chakan")
  if nx_is_valid(form) and form.Visible then
    _base_info = nil
    _equip_info = nil
  end
end
function main_form_init(form)
  form.Fixed = false
  form.pk_value = 0
  form.pk_step = 0
  form.show_sex = 0
end
function on_main_form_open(form)
  if nil == _base_info or nil == _equip_info then
    return
  end
  form.imagegrid_1:SetBindIndex(0, 1)
  form.imagegrid_1:SetBindIndex(1, 2)
  form.imagegrid_1:SetBindIndex(2, 3)
  form.imagegrid_1:SetBindIndex(3, 4)
  form.imagegrid_1:SetBindIndex(4, 5)
  form.imagegrid_1:SetBindIndex(5, 6)
  form.imagegrid_1:SetBindIndex(6, 7)
  form.imagegrid_1:SetBindIndex(7, 8)
  form.imagegrid_1:SetBindIndex(8, 11)
  form.imagegrid_1:SetBindIndex(9, 12)
  form.imagegrid_1:SetBindIndex(10, 13)
  form.imagegrid_1:SetBindIndex(11, 14)
  form.imagegrid_1:SetBindIndex(12, 15)
  form.imagegrid_1:SetBindIndex(13, 16)
  form.imagegrid_1:SetBindIndex(14, 17)
  form.imagegrid_1:SetBindIndex(15, 18)
  form.imagegrid_1:SetBindIndex(16, 19)
  form.imagegrid_1:SetBindIndex(17, 22)
  form.imagegrid_1:SetBindIndex(18, 23)
  form.imagegrid_1:SetBindIndex(19, 24)
  form.imagegrid_1:SetBindIndex(20, 25)
  form.imagegrid_1:SetBindIndex(21, 26)
  form.imagegrid_1:SetBindIndex(22, 27)
  form.imagegrid_1:SetBindIndex(23, 28)
  form.imagegrid_1:SetBindIndex(24, 29)
  form.imagegrid_1:SetBindIndex(25, 30)
  form.imagegrid_1:SetBindIndex(26, 31)
  form.imagegrid_1:SetBindIndex(27, 32)
  form.imagegrid_1:SetBindIndex(28, 33)
  form.imagegrid_1:SetBindIndex(29, 34)
  form.imagegrid_2:SetBindIndex(0, 1)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.groupbox_equip_bg.Visible = true
  form.groupbox_treasure_bg.Visible = false
  form.rbtn_equip.Checked = true
  hide_all_outline(form)
  clear_base_info(form)
  clear_equip_info(form)
  clear_role_model(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_LOOKOTHER_BOX, form.imagegrid_1, FORM_NAME, "on_lookother_viewport_change")
  end
  show_base_info(form, _base_info)
  show_role_model(form)
  show_shane_info(form, _base_info)
  if nx_is_valid(form) then
    form.gb_self_shan_e.Visible = false
  end
  refresh_treasure_lock()
end
function on_lookother_viewport_change(grid, optype)
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
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
  local sel_obj = nx_execute("util_functions", "util_find_client_player_by_name", nx_widestr(get_role_name()))
  if not nx_is_valid(sel_obj) then
    return
  end
  form.show_sex = sel_obj:QueryProp("Sex")
  local view = game_client:GetView(nx_string(VIEWPORT_LOOKOTHER_BOX))
  if not nx_is_valid(view) then
    return
  end
  for index = 0, GRID_MAX do
    local view_index = grid:GetBindIndex(index) - 1
    local viewobj = view:GetViewObj(nx_string(index))
    if nx_is_valid(viewobj) then
      local item_config = viewobj:QueryProp("ConfigID")
      local item_count = viewobj:QueryProp("Amount")
      local item_equip_type = viewobj:QueryProp("EquipType")
      local item_color_level = viewobj:QueryProp("ColorLevel")
      local name = gui.TextManager:GetText(nx_string(item_config))
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(item_config), "Photo", form.show_sex)
      local grid_index = GoodsGrid:GetGridIndexFromViewIndex(grid, nx_number(index))
      local item_back_image = get_grid_treasure_back_image(item_equip_type, item_color_level)
      local lbl = get_outline_label(grid.ParentForm, index)
      if nx_is_valid(lbl) then
        lbl.Visible = false
      end
      local replace_pack = viewobj:QueryProp("ReplacePack")
      if nx_int(replace_pack) > nx_int(0) then
        local replace_id = viewobj:QueryProp("ReplaceID")
        photo = get_huanpi_photo(replace_id, form.show_sex)
        if nx_is_valid(lbl) then
          lbl.Visible = true
        end
      end
      grid:AddItemEx(nx_int(grid_index), nx_string(photo), name, nx_int(amount), nx_int(0), nx_string(item_back_image))
    end
  end
end
function on_main_form_close(form)
  _base_info = nil
  _equip_info = nil
  clear_base_info(form)
  clear_equip_info(form)
  clear_role_model(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  end
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  end
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function analysis_chakan_xml_info(xmlroot, item_info)
  local xml_element_record = xmlroot:GetChildByIndex(1)
  if not nx_is_valid(xml_element_record) then
    return ""
  end
  local record_num = xml_element_record:GetChildCount()
  local str_record_group = ""
  for i = 0, record_num - 1 do
    local child = xml_element_record:GetChildByIndex(i)
    local record_name = child:QueryAttr("name")
    local record_rows = child:QueryAttr("rows")
    local sz_child_info = nx_string(record_name) .. "," .. nx_string(record_rows)
    local record_prop_num = 0
    for index = 0, record_rows - 1 do
      local child_child = child:GetChildByIndex(index)
      record_prop_num = nx_int(record_prop_num) + (nx_int(child_child:GetAttrCount()) - 1)
    end
    sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(record_prop_num / record_rows)
    for index = 0, record_rows - 1 do
      local child_child = child:GetChildByIndex(index)
      if not nx_is_valid(child_child) then
        return ""
      end
      local record_prop_num = child_child:GetAttrCount()
      for record_index = 1, record_prop_num - 1 do
        local prop_name = child_child:GetAttrName(record_index)
        local prop_value = child_child:GetAttrValue(record_index)
        sz_child_info = nx_string(sz_child_info) .. "," .. nx_string(prop_value)
      end
    end
    if str_record_group == "" then
      str_record_group = nx_string(sz_child_info)
    else
      str_record_group = nx_string(str_record_group) .. "," .. nx_string(sz_child_info)
    end
  end
  return str_record_group
end
function on_imagegrid_1_mousein_grid(grid, grid_index)
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_LOOKOTHER_BOX))
  if not nx_is_valid(view) then
    return
  end
  local pos = grid:GetBindIndex(grid_index)
  local item_data = view:GetViewObj(nx_string(pos))
  if nx_is_valid(item_data) then
    if nx_find_custom(form, "show_sex") then
      item_data.other_sex = nx_int(form.show_sex)
    end
    item_data.IsLookOther = true
    item_data.InContainerPos = nx_number(pos)
  end
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  end
  refresh_drawmousein(grid, grid_index)
end
function on_imagegrid_1_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_1_select_changed(grid, index)
  refresh_selected_status(grid, index)
end
function on_imagegrid_2_mousein_grid(grid, grid_index)
  if not nx_is_valid(grid.Data) then
    return
  end
  local item_data = grid.Data:GetChild(nx_string(grid_index))
  local form = grid.ParentForm
  if nx_is_valid(item_data) then
    if nx_find_custom(form, "sex") then
      item_data.other_sex = nx_int(form.sex)
    end
    item_data.IsLookOther = true
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  end
end
function on_imagegrid_2_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_base_info(form, base_info)
  local gui = nx_value("gui")
  local count = table.getn(base_info)
  local index = 1
  form.lbl_name.Text = nx_widestr(base_info[index])
  if nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene") then
    form.lbl_name.Text = nx_widestr("")
  end
  index = index + 20
  form.lbl_FP.Text = gui.TextManager:GetText("desc_" .. base_info[index])
  index = index + 1
  local CharacterFlag = nx_int(base_info[index])
  index = index + 1
  local CharacterValue = nx_int(base_info[index])
  local text = nx_execute("form_stage_main\\form_role_info\\form_role_info", "get_xiae_text", CharacterFlag, CharacterValue)
  form.lbl_PKValue.Text = nx_widestr(text)
  index = index + 1
  local school = nx_string(base_info[index])
  index = index + 1
  if count >= index then
    local sex = base_info[index]
    form.sex = sex
  end
  index = index + 1
  if nx_ws_length(nx_widestr(base_info[index])) > 0 then
    form.lbl_guildname.Text = nx_widestr(base_info[index])
  else
    form.lbl_guildname.Text = nx_widestr(gui.TextManager:GetText("ui_None"))
  end
  index = index + 1
  if nx_ws_length(nx_widestr(base_info[index])) > 0 then
    form.lbl_guildpos.Text = nx_widestr(gui.TextManager:GetText(nx_string(base_info[index])))
  else
    form.lbl_guildname.Text = nx_widestr(gui.TextManager:GetText("ui_None"))
  end
  local school_name = nx_null()
  if school == "school_shaolin" then
    school_name = gui.TextManager:GetText("ui_neigong_category_sl")
  elseif school == "school_wudang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_wd")
  elseif school == "school_emei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_em")
  elseif school == "school_junzitang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jz")
  elseif school == "school_jinyiwei" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jy")
  elseif school == "school_jilegu" then
    school_name = gui.TextManager:GetText("ui_neigong_category_jl")
  elseif school == "school_gaibang" then
    school_name = gui.TextManager:GetText("ui_neigong_category_gb")
  elseif school == "school_tangmen" then
    school_name = gui.TextManager:GetText("ui_neigong_category_tm")
  elseif school == "school_mingjiao" then
    school_name = gui.TextManager:GetText("ui_neigong_category_mj")
  elseif school == "school_tianshan" then
    school_name = gui.TextManager:GetText("ui_neigong_category_ts")
  elseif school == "force_yihua" then
    school_name = gui.TextManager:GetText("ui_neigong_category_yh")
  elseif school == "force_taohua" then
    school_name = gui.TextManager:GetText("ui_neigong_category_th")
  elseif school == "force_xujia" then
    school_name = gui.TextManager:GetText("ui_neigong_category_xj")
  elseif school == "force_wanshou" then
    school_name = gui.TextManager:GetText("ui_neigong_category_ws")
  elseif school == "force_jinzhen" then
    school_name = gui.TextManager:GetText("ui_neigong_category_sj")
  elseif school == "force_wugen" then
    school_name = gui.TextManager:GetText("ui_neigong_category_wg")
  elseif school == "newschool_xuedao" then
    school_name = gui.TextManager:GetText("ui_neigong_category_xd")
  elseif school == "newschool_huashan" then
    school_name = gui.TextManager:GetText("ui_neigong_category_hs")
  elseif school == "newschool_gumu" then
    school_name = gui.TextManager:GetText("ui_neigong_category_mu")
  elseif school == "newschool_damo" then
    school_name = gui.TextManager:GetText("ui_neigong_category_dm")
  elseif school == "newschool_shenshui" then
    school_name = gui.TextManager:GetText("ui_neigong_category_ss")
  elseif school == "newschool_changfeng" then
    school_name = gui.TextManager:GetText("ui_neigong_category_cf")
  elseif school == "newschool_nianluo" then
    school_name = gui.TextManager:GetText("ui_neigong_category_nl")
  elseif school == "newschool_wuxian" then
    school_name = gui.TextManager:GetText("ui_neigong_category_wx")
  elseif school == "newschool_shenji" then
    school_name = gui.TextManager:GetText("ui_neigong_category_shenji")
  elseif school == "newschool_xingmiao" then
    school_name = gui.TextManager:GetText("ui_neigong_category_xingmiao")
  else
    school_name = gui.TextManager:GetText("ui_task_school_null")
  end
  form.lbl_school.Text = nx_widestr(school_name)
end
function show_equip_info(form, info)
  on_lookother_viewport_change(form.imagegrid_1)
end
function show_role_model(form)
  local sel_obj = nx_execute("util_functions", "util_find_client_player_by_name", nx_widestr(get_role_name()))
  if not nx_is_valid(sel_obj) then
    return
  end
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
  end
  local actor2 = nx_execute("role_composite", "create_scene_obj_composite", form.role_box.Scene, sel_obj, false)
  if not nx_is_valid(actor2) then
    return
  end
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, sel_obj.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
end
function clear_base_info()
  local form = nx_value("form_stage_main\\form_role_chakan")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_name.Text = nx_widestr("")
  form.lbl_school.Text = nx_widestr("")
  form.lbl_FP.Text = nx_widestr("")
  form.lbl_PKValue.Text = nx_widestr("")
end
function clear_equip_info(form)
  local grid = form.imagegrid_1
  if nx_is_valid(grid.Data) then
    grid.Data:ClearChild()
  end
  form.imagegrid_1:Clear()
  form.imagegrid_2:Clear()
end
function clear_role_model(form)
  nx_execute("util_gui", "ui_ClearModel", form.role_box)
end
function get_role_name()
  return nx_value("_role_chakan_name")
end
function on_get_capture_pkstep(self, index)
  local form = nx_value("form_stage_main\\form_role_chakan")
  if nx_is_valid(form.gb_self_shan_e) then
    form.gb_self_shan_e.Visible = true
  end
end
function on_lost_capture_pkstep(self, index)
  local form = nx_value("form_stage_main\\form_role_chakan")
  if nx_is_valid(form.gb_self_shan_e) then
    form.gb_self_shan_e.Visible = false
  end
end
function show_shane_info(form, base_info)
  local CharacterFlag = nx_number(base_info[22])
  local CharacterValue = nx_number(base_info[23])
  local Justice = nx_int(base_info[28])
  local Evil = nx_int(base_info[29])
  local FreeBase = nx_int(base_info[30])
  local gui = nx_value("gui")
  form.lbl_xia_value.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_player_xia", Justice))
  form.lbl_e_value.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_player_e", Evil))
  form.lbl_jieao_value.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sns_player_jiehao", FreeBase))
  local text = nx_execute("form_stage_main\\form_role_info\\form_role_info", "get_xiae_text", CharacterFlag, CharacterValue)
  form.lbl_shane_name.Text = nx_widestr(text)
  if CharacterFlag == 0 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xia.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
  elseif CharacterFlag == 1 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xia.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = true
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_colour.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_xia_bar.Height = nx_number(30 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 2 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_e.png"
    form.lbl_e_bar.Visible = true
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_colour.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_e_bar.Height = nx_number(30 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 3 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_kuang.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = true
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_colour.png"
    form.lbl_kuang.Top = 16
    form.lbl_kuang.Left = 56
    form.lbl_xie.Top = 40
    form.lbl_xie.Left = 40
    form.lbl_kuang_bar.Height = nx_number(60 / MaxCharacterValue * CharacterValue)
    form.lbl_kuang_bar.Top = 60 - nx_number(60 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 4 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xie.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = true
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_colour.png"
    form.lbl_xie.Top = 16
    form.lbl_xie.Left = 56
    form.lbl_kuang.Top = 40
    form.lbl_kuang.Left = 72
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_xie_bar.Height = nx_number(60 / MaxCharacterValue * CharacterValue)
    form.lbl_xie_bar.Top = 60 - nx_number(60 / MaxCharacterValue * CharacterValue)
  end
end
function on_rbtn_equip_checked_changed(btn)
  if btn.Checked == true then
    local form = btn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.imagegrid_1.Left = 0
    form.groupbox_equip_bg.Visible = true
    form.groupbox_treasure_bg.Visible = false
    form.groupbox_ani.Visible = true
    form.groupbox_1.BackImage = "gui\\special\\role\\bg_main.png"
  end
end
function on_rbtn_treasure_checked_changed(btn)
  if btn.Checked == true then
    local form = btn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.imagegrid_1.Left = -310
    form.groupbox_equip_bg.Visible = false
    form.groupbox_treasure_bg.Visible = true
    form.groupbox_ani.Visible = false
    form.groupbox_1.BackImage = "gui\\special\\role\\bg_treasure.png"
  end
end
function refresh_treasure_lock()
  local form = nx_value("form_stage_main\\form_role_chakan")
  if not nx_is_valid(form) then
    return
  end
  local step = 0
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_find_custom(client_player, "jyz_step") then
    step = 1
  else
    step = client_player.jyz_step
  end
  local treasure_num = 0
  local treasure_num_new = 0
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\RandomEquipRule\\BoxLevel.ini")
  if nx_is_valid(ini) then
    local table_flag = {
      "Treasure",
      "NewTreasure"
    }
    for j = 1, 2 do
      local sec_index = ini:FindSectionIndex(table_flag[j])
      if 0 <= sec_index then
        local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
        for i = 1, nx_number(table.getn(GroupMsgData)) do
          local stepData = util_split_string(GroupMsgData[i], ",")
          if table.getn(stepData) == 3 and nx_int(stepData[1]) <= nx_int(step) and nx_int(step) <= nx_int(stepData[2]) then
            if j == 1 then
              treasure_num = nx_int(stepData[3])
            elseif j == 2 then
              treasure_num_new = nx_int(stepData[3])
            end
          end
        end
      end
    end
  end
  for i = 1, treasure_num + 1 do
    local label = form.groupbox_treasure_bg:Find("lbl_treasure_" .. nx_string(i))
    if nx_is_valid(label) then
      label.BackImage = "gui\\special\\role\\icon_treasure_null.png"
    end
  end
  for i = 1, treasure_num_new + 1 do
    i = i + 5
    local label = form.groupbox_treasure_bg:Find("lbl_treasure_" .. nx_string(i))
    if nx_is_valid(label) then
      label.BackImage = "gui\\special\\role\\icon_treasure_null.png"
    end
  end
  for i = treasure_num + 1, 5 do
    local label = form.groupbox_treasure_bg:Find("lbl_treasure_" .. nx_string(i))
    if nx_is_valid(label) then
      label.BackImage = "gui\\special\\role\\icon_treasure_lock.png"
    end
  end
  for i = treasure_num_new + 1, 5 do
    i = i + 5
    local label = form.groupbox_treasure_bg:Find("lbl_treasure_" .. nx_string(i))
    if nx_is_valid(label) then
      label.BackImage = "gui\\special\\role\\icon_treasure_lock.png"
    end
  end
  for i = 1, 10 do
    local label = form.groupbox_treasure_bg:Find("lbl_bg_treasure_" .. nx_string(i))
    if not nx_is_valid(label) then
      return
    end
    if form.imagegrid_1:IsEmpty(nx_int(i + TREASURESTARTPOS - 1)) then
      label.Visible = false
    else
      label.Visible = true
    end
  end
end
function refresh_drawmousein(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  local form = grid.ParentForm
  local view_index = nx_int(index) + 1
  local lbl = get_outline_label(form, view_index)
  if nx_is_valid(lbl) and lbl.Visible == true then
    grid.DrawMouseIn = nx_string("")
    return
  end
  grid.DrawMouseIn = nx_string("xuanzekuang_on")
end
function refresh_selected_status(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  local form = grid.ParentForm
  local view_index = nx_int(index) + 1
  local lbl = get_outline_label(form, view_index)
  if nx_is_valid(lbl) and lbl.Visible == true then
    grid.DrawMouseSelect = nx_string("Tab_xuanzekuang")
    return
  end
  grid.DrawMouseSelect = nx_string("xuanzekuang")
end
function get_huanpi_photo(configid, sex)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("ItemType"))
  if nx_number(item_type) < ITEMTYPE_HUANPIMIN and nx_number(item_type) > ITEMTYPE_HUANPIMAX then
    return ""
  end
  local art_pack = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("ArtPack"))
  local photo = nx_string(item_static_query(nx_int(art_pack), "Photo", STATIC_DATA_ITEM_ART))
  if sex ~= 0 then
    local photo1 = nx_string(item_static_query(nx_int(art_pack), "FemalePhoto", STATIC_DATA_ITEM_ART))
    if photo1 ~= nil and photo1 ~= nx_string("") then
      photo = photo1
    end
  end
  return photo
end
function hide_all_outline(form)
  form.lbl_ani_hat.Visible = false
  form.lbl_ani_cloth.Visible = false
  form.lbl_ani_pants.Visible = false
  form.lbl_ani_shoes.Visible = false
end
function get_outline_label(form, index)
  if not nx_is_valid(form) then
    return nil
  end
  if nx_int(index) == nx_int(1) then
    return form.lbl_ani_hat
  elseif nx_int(index) == nx_int(3) then
    return form.lbl_ani_cloth
  elseif nx_int(index) == nx_int(4) then
    return form.lbl_ani_pants
  elseif nx_int(index) == nx_int(8) then
    return form.lbl_ani_shoes
  end
  return nil
end
