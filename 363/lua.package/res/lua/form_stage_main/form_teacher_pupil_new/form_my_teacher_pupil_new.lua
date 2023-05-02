require("util_gui")
require("util_functions")
require("role_composite")
require("tips_data")
require("form_stage_main\\form_teacher_pupil_new\\teacherpupil_define_new")
require("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_func_new")
FLAG_SLT_ERROR = -1
FLAG_SLT_NEIGONG_TEACHER = 0
FLAG_SLT_NEIGONG_PUPIL1 = 1
FLAG_SLT_NEIGONG_PUPIL2 = 2
FLAG_SLT_NEIGONG_PUPIL3 = 3
BtnSelectFlag = "btnselectflag"
g_select_flag = nil
function on_main_form_open(form)
  form.role_count = 0
  form.role_list = nx_call("util_gui", "get_arraylist", "role_list_info")
  form.role_list:ClearChild()
  form.btn_pupil1.Visible = false
  form.btn_pupil2.Visible = false
  form.btn_pupil3.Visible = false
  form.enshi_value = 0
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("NewShiTuValue", "int", form, nx_current(), "on_shitu_value_changed")
    databinder:AddRolePropertyBind("NewTodayShiTuValueAdd", "int", form, nx_current(), "on_today_shitu_value_changed")
  end
  g_select_flag = get_default_select_flag(form)
  nx_execute("custom_sender", CUSTOM_MSG_FUN, NT_CTS_ASK_SHITU_DETIAL)
end
function on_main_form_close(form)
  if nx_find_custom(form, "role_list") and nx_is_valid(form.role_list) then
    form.role_list:ClearChild()
    nx_destroy(form.role_list)
  end
  nx_destroy(form)
end
function on_btn_pupil1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(btn, BtnSelectFlag) then
    return
  end
  if g_select_flag ~= nx_custom(btn, BtnSelectFlag) then
    g_select_flag = nx_custom(btn, BtnSelectFlag)
    refresh_form(form)
    show_shitu_prize(form.textgrid_prize)
  end
end
function on_btn_pupil2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(btn, BtnSelectFlag) then
    return
  end
  if g_select_flag ~= nx_custom(btn, BtnSelectFlag) then
    g_select_flag = nx_custom(btn, BtnSelectFlag)
    refresh_form(form)
    show_shitu_prize(form.textgrid_prize)
  end
end
function on_btn_pupil3_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(btn, BtnSelectFlag) then
    return
  end
  if g_select_flag ~= nx_custom(btn, BtnSelectFlag) then
    g_select_flag = nx_custom(btn, BtnSelectFlag)
    refresh_form(form)
    show_shitu_prize(form.textgrid_prize)
  end
end
function on_btn_quit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  jiechu_shitu_relation(1)
end
function on_btn_qiangzhi_remove_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  jiechu_shitu_relation(2)
end
function on_btn_return_click(btn)
  if btn.Name == "btn_1" then
    local form = btn.ParentForm
    form.groupbox_jiangli.Visible = false
    form.groupbox_shixiongdi.Visible = true
    return
  end
  nx_execute(FORM_MSG_NEW, "show_main_page")
end
function on_btn_change_form_click(btn)
  local form = btn.ParentForm
  if form.groupbox_shixiongdi.Visible then
    form.groupbox_jiangli.Visible = true
    form.groupbox_shixiongdi.Visible = false
  else
    form.groupbox_jiangli.Visible = false
    form.groupbox_shixiongdi.Visible = true
  end
end
function get_default_select_flag(form)
  if not nx_is_valid(form) then
    return FLAG_SLT_ERROR
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return FLAG_SLT_ERROR
  end
  if not nx_find_custom(form.btn_pupil1, BtnSelectFlag) then
    nx_set_custom(form.btn_pupil1, BtnSelectFlag, FLAG_SLT_ERROR)
  end
  if not nx_find_custom(form.btn_pupil2, BtnSelectFlag) then
    nx_set_custom(form.btn_pupil1, BtnSelectFlag, FLAG_SLT_ERROR)
  end
  if not nx_find_custom(form.btn_pupil3, BtnSelectFlag) then
    nx_set_custom(form.btn_pupil1, BtnSelectFlag, FLAG_SLT_ERROR)
  end
  local tp_type = player:QueryProp("NewShiTuFlag")
  if Junior_fellow_apprentice == tp_type then
    nx_set_custom(form.btn_pupil1, BtnSelectFlag, FLAG_SLT_NEIGONG_TEACHER)
  end
  if Senior_fellow_apprentice == tp_type then
    local row_num = form.role_count
    if 0 < row_num then
      nx_set_custom(form.btn_pupil1, BtnSelectFlag, FLAG_SLT_NEIGONG_PUPIL1)
    end
    if 1 < row_num then
      nx_set_custom(form.btn_pupil2, BtnSelectFlag, FLAG_SLT_NEIGONG_PUPIL2)
    end
    if 3 < row_num then
      nx_set_custom(form.btn_pupil3, BtnSelectFlag, FLAG_SLT_NEIGONG_PUPIL3)
    end
  end
  return nx_custom(form.btn_pupil1, BtnSelectFlag)
end
function get_current_name()
  local form = nx_value(nx_current())
  return form.lbl_name.Text
end
function get_sliver()
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\teacherpupil.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("BaseConfig")
  if index < 0 then
    return
  end
  local capital_type = ini:ReadInteger(index, "CapitalType", 0)
  local capital_count = ini:ReadInteger(index, "CapitalTypecount", 0)
  return capital_type, capital_count
end
function jiechu_shitu_relation(jiechu_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  dialog.mltbox_info:Clear()
  local type, count = get_sliver()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(jiechu_type) == nx_int(1) then
    gui.TextManager:Format_SetIDName("ui_shitu_shituguanxi")
  elseif nx_int(jiechu_type) == nx_int(2) then
    gui.TextManager:Format_SetIDName("ui_shitu_jiechu_3")
  end
  gui.TextManager:Format_AddParam(nx_int(count))
  local text = gui.TextManager:Format_GetText()
  dialog.mltbox_info:AddHtmlText(nx_widestr(text), -1)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local name = get_current_name()
    if nx_string(name) == "0" or nx_string(name) == "" or name == nil then
      return
    end
    if nx_int(jiechu_type) == nx_int(1) then
      nx_execute("custom_sender", CUSTOM_MSG_FUN, NT_CTS_ASK_JIE_CHU, nx_widestr(name))
    elseif nx_int(jiechu_type) == nx_int(2) then
      nx_execute("custom_sender", CUSTOM_MSG_FUN, NT_CTS_ASK_FORCE_JIE_CHU, nx_widestr(name))
    end
    local closeform = nx_value("form_stage_main\\form_school_war\\form_school_msg_info")
    if nx_is_valid(closeform) then
      closeform:Close()
    end
  end
end
function show_role_model(form, sex, role_info, body_type, face)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return
  end
  local skin_info = util_split_string(role_info, "#")
  local show_type = nx_int(skin_info[1])
  local body_face = nx_int(skin_info[3])
  local hat = nx_string(skin_info[4])
  local cloth = nx_string(skin_info[5])
  local pants = nx_string(skin_info[6])
  local shoes = nx_string(skin_info[7])
  local scenebox = form.scenebox_1
  if nx_find_custom(scenebox, "role_actor2") and nx_is_valid(scenebox.role_actor2) then
    world:Delete(scenebox.role_actor2)
  end
  if not nx_is_valid(scenebox.Scene) then
    util_addscene_to_scenebox(scenebox)
  end
  nx_call("scene", "support_physics", world, scenebox.Scene)
  local actor2 = create_role_composite(scenebox.Scene, false, nx_number(sex), "stand", nx_number(body_type))
  nx_execute("role_composite", "unlink_skin", actor2, "Hat")
  link_skin(actor2, "hat", hat .. ".xmod", false)
  link_skin(actor2, "cloth", cloth .. ".xmod", false)
  link_skin(actor2, "pants", pants .. ".xmod", false)
  link_skin(actor2, "shoes", shoes .. ".xmod", false)
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    if nx_number(body_face) > nx_number(0) then
      role_composite:LinkFaceSkin(actor2, nx_int(sex), nx_number(body_face), false)
    elseif 0 < string.len(face) then
      role_composite:SetPlayerFaceDetial(get_role_face(actor2), nx_string(face), nx_int(sex), nx_null())
    end
  end
  if nx_int(show_type) == nx_int(1) then
    link_skin(actor2, "cloth_h", cloth .. "_h.xmod", false)
  end
  util_add_model_to_scenebox(scenebox, actor2)
  scenebox.role_actor2 = actor2
end
function get_role_face(actor2)
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor_role_face = actor_role:GetLinkObject("actor_role_face")
  if not nx_is_valid(actor_role_face) then
    return nil
  end
  return actor_role_face
end
function set_role_model_camera(form, body_type)
  if not nx_is_valid(form) then
    return
  end
  local camera = form.scenebox_1.Scene.camera
  if not nx_is_valid(camera) then
    return
  end
  local radius = 0.4
  camera:SetAngle(0, 0, 0)
  camera:SetPosition(0, radius * 2, -radius * 8.5)
end
function refresh_form(form)
  if g_select_flag == FLAG_SLT_NEIGONG_TEACHER or g_select_flag == FLAG_SLT_NEIGONG_PUPIL1 or g_select_flag == FLAG_SLT_NEIGONG_PUPIL2 or g_select_flag == FLAG_SLT_NEIGONG_PUPIL3 then
    refresh_neigong(form)
  end
end
function refresh_neigong(form)
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  if not nx_find_custom(form, "role_list") or not nx_is_valid(form.role_list) then
    return
  end
  local index = 1
  if g_select_flag == FLAG_SLT_NEIGONG_PUPIL2 then
    index = 2
  elseif g_select_flag == FLAG_SLT_NEIGONG_PUPIL3 then
    index = 3
  end
  local child = form.role_list:GetChild(nx_string(index))
  if not nx_is_valid(child) then
    return
  end
  local tp_sex = child.sex
  local role_info = child.role_info
  local face = child.role_model_info
  local body_info_list = util_split_string(role_info, "#")
  local body_type = body_info_list[2]
  show_role_model(form, tp_sex, role_info, body_type, face)
  set_role_model_camera(form, body_type)
  form.lbl_name.Text = nx_widestr(child.name)
  form.lbl_powerlevel.Text = nx_widestr(Get_PowerLevel_Name(child.power_level))
  form.lbl_tptime.Text = nx_widestr(get_date_string(child.baishi_time))
  form.lbl_himinfo.Text = nx_widestr(util_text(get_is_online(child.is_online)))
  form.lbl_intimateinfo.Text = nx_widestr(child.intimate_value)
  local tp_type = player:QueryProp("NewShiTuFlag")
  form.lbl_myinfo.Text = nx_widestr(util_text(get_tp_type(tp_type)))
  form.lbl_tpvalue.Text = nx_widestr(player:QueryProp("NewShiTuValue"))
  if Senior_fellow_apprentice == tp_type then
    form.lbl_enshi.Visible = true
    form.lbl_enshiinfo.Visible = true
    form.lbl_enshiinfo.Text = nx_widestr(form.enshi_value)
  else
    form.lbl_enshi.Visible = false
    form.lbl_enshiinfo.Visible = false
  end
  refresh_ng_left(form)
end
function refresh_ng_left(form)
  if g_select_flag == FLAG_SLT_NEIGONG_TEACHER then
    form.btn_pupil1.Visible = false
    form.btn_pupil2.Visible = false
    form.btn_pupil3.Visible = false
  elseif g_select_flag == FLAG_SLT_NEIGONG_PUPIL1 or g_select_flag == FLAG_SLT_NEIGONG_PUPIL2 or g_select_flag == FLAG_SLT_NEIGONG_PUPIL3 then
    form.btn_pupil1.Visible = true
    form.btn_pupil2.Visible = true
    form.btn_pupil3.Visible = true
    if form.role_count == 1 then
      form.btn_pupil2.Enabled = false
      form.btn_pupil3.Enabled = false
    elseif form.role_count == 2 then
      form.btn_pupil3.Enabled = false
    end
  end
end
function on_shitu_value_changed(form)
  if not nx_is_valid(form) then
    return
  end
  local shitu_value = get_shitu_value()
  form.lbl_tpvalue.Text = nx_widestr(shitu_value)
end
function on_today_shitu_value_changed(form)
  if not nx_is_valid(form) then
    return
  end
  local today_shitu_value = get_today_shitu_value()
  form.lbl_dayinfo.Text = nx_widestr(today_shitu_value)
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
  if table.getn(table_prop_name) <= 0 then
    return
  end
  table_prop_value.ConfigID = nx_string(prize_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", "task_grid_data")
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_set_custom(grid.Data, "is_static", true)
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
  grid.Data:ClearChild()
end
function on_imagegrid_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function init_prize_grid(grid)
  grid:ClearRow()
  grid.ColCount = 3
  grid.RowHeight = 53
  for i = 1, grid.ColCount do
    grid:SetColAlign(i - 1, "Center")
  end
  grid.cur_editor_row = -1
  grid.current_task_id = ""
  grid.CanSelectRow = false
end
function show_shitu_prize(grid)
  if not nx_is_valid(grid) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\teacherpupil\\newshitu_price.ini")
  if not nx_is_valid(ini) then
    return
  end
  local shitu_flag = get_shitu_flag()
  if nx_int(shitu_flag) == nx_int(0) then
    return
  end
  grid:ClearRow()
  local sec_index = ini:FindSectionIndex(nx_string("ZhouChang"))
  if 0 <= sec_index then
    local list = ini:GetItemValueList(sec_index, nx_string("r"))
    local count = table.getn(list)
    for i = 1, count do
      local prize_list = util_split_string(list[i], ";")
      local prize_table = util_split_string(prize_list[shitu_flag], ",")
      InsertZhouChangInfo(grid, prize_table)
    end
  end
  sec_index = ini:FindSectionIndex(nx_string("PowerLevel"))
  if 0 <= sec_index then
    local list = ini:GetItemValueList(sec_index, nx_string("r"))
    local count = table.getn(list)
    for i = 1, count do
      local prize_list = util_split_string(list[i], ";")
      local prize_table = util_split_string(prize_list[shitu_flag], ",")
      InsertPowerLevelInfo(grid, prize_table)
    end
  end
end
function InsertZhouChangInfo(grid, prize_info)
  if not nx_is_valid(grid) then
    return
  end
  if table.getn(prize_info) < 6 then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local cooldownbig = nx_value("CoolDownBig")
  if not nx_is_valid(cooldownbig) then
    return
  end
  local task_type = nx_int(prize_info[1])
  local prize_desc = nx_string(prize_info[2])
  local goods_type = nx_int(prize_info[3])
  local prize = nx_string(prize_info[4])
  local task_id = nx_string(prize_info[5])
  local max_finish_count = nx_string(prize_info[6])
  local row = grid:InsertRow(-1)
  local mText_1 = create_multitext()
  if not nx_is_valid(mText_1) then
    return
  end
  mText_1.ViewRect = "8,8," .. nx_string(grid:GetColWidth(0)) .. ",80"
  mText_1.HtmlText = util_text(prize_desc)
  grid:SetGridControl(row, 0, mText_1)
  if nx_int(1) == goods_type then
    local mText = create_multitext()
    if not nx_is_valid(mText) then
      return
    end
    mText.HtmlText = util_text(prize)
    grid:SetGridControl(row, 1, mText)
  elseif nx_int(2) == goods_type then
    local item_list = util_split_string(prize, "|")
    local image_grid = CreateImage(item_list)
    if not nx_is_valid(image_grid) then
      return
    end
    grid:SetGridControl(row, 1, image_grid)
  end
  local info = "0/" .. max_finish_count
  local mText_2
  if nx_int(1) == task_type then
    mText_2 = create_multitext_with_name(task_id)
    nx_execute("custom_sender", CUSTOM_MSG_FUN, nx_int(NT_CTS_ASK_TASK), nx_int(task_id))
  elseif nx_int(2) == task_type then
    mText_2 = create_multitext()
    local count = cooldownbig:GetCoolDownBigCount(nx_int(task_id))
    info = nx_string(count) .. "/" .. max_finish_count
  end
  if not nx_is_valid(mText_2) then
    return
  end
  mText_2.ViewRect = "32,8," .. nx_string(grid:GetColWidth(2)) .. ",80"
  mText_2.HtmlText = nx_widestr(info)
  grid:SetGridControl(row, 2, mText_2)
end
function on_server_msg_task(...)
  local task_id = arg[1]
  local count = arg[2]
  if nx_int(count) == nx_int(0) then
    return
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local grid = form.textgrid_prize
  if not nx_is_valid(grid) then
    return
  end
  for row = 0, grid.RowCount - 1 do
    local multibox = grid:GetGridControl(row, 2)
    if nx_is_valid(multibox) and nx_string(multibox.Name) == "MultiTextBox_Task_" .. nx_string(task_id) then
      multibox.HtmlText = nx_widestr("1/1")
      return
    end
  end
  return
end
function InsertPowerLevelInfo(grid, prize_info)
  if not nx_is_valid(grid) then
    return
  end
  if table.getn(prize_info) < 4 then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = 1
  if g_select_flag == FLAG_SLT_NEIGONG_PUPIL2 then
    index = 2
  elseif g_select_flag == FLAG_SLT_NEIGONG_PUPIL3 then
    index = 3
  end
  if not nx_find_custom(form, "role_list") or not nx_is_valid(form.role_list) then
    return
  end
  local child = form.role_list:GetChild(nx_string(index))
  if not nx_is_valid(child) then
    return
  end
  local power_level = nx_number(prize_info[1])
  local prize_desc = nx_string(prize_info[2])
  local goods_type = nx_int(prize_info[3])
  local prize = nx_string(prize_info[4])
  local row = grid:InsertRow(-1)
  local mText_1 = create_multitext()
  if not nx_is_valid(mText_1) then
    return
  end
  mText_1.ViewRect = "8,8," .. nx_string(grid:GetColWidth(0)) .. ",80"
  mText_1.HtmlText = util_text(prize_desc)
  grid:SetGridControl(row, 0, mText_1)
  if nx_int(1) == goods_type then
    local mText = create_multitext()
    if not nx_is_valid(mText) then
      return
    end
    mText.HtmlText = util_text(prize)
    grid:SetGridControl(row, 1, mText)
  elseif nx_int(2) == goods_type then
    local item_list = util_split_string(prize, "|")
    local image_grid = CreateImage(item_list)
    if not nx_is_valid(image_grid) then
      return
    end
    grid:SetGridControl(row, 1, image_grid)
  end
  local info = "0/1"
  if nx_find_custom(child, "task_level") then
    local task_level = child.task_level
    if power_level <= task_level then
      info = "1/1"
    else
      info = "0/1"
    end
  end
  local mText_2 = create_multitext()
  if not nx_is_valid(mText_2) then
    return
  end
  mText_2.ViewRect = "32,8," .. nx_string(grid:GetColWidth(2)) .. ",80"
  mText_2.HtmlText = nx_widestr(info)
  grid:SetGridControl(row, 2, mText_2)
end
function CreateImage(item_list)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nil
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return nil
  end
  local count = table.getn(item_list)
  if nx_number(0) >= nx_number(count) then
    return nil
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return nil
  end
  local image_grid = gui:Create("ImageGrid")
  if not nx_is_valid(image_grid) then
    return nil
  end
  set_copy_ent_info(form, "imagegrid_award", image_grid)
  nx_bind_script(image_grid, nx_current())
  nx_callback(image_grid, "on_mousein_grid", "on_imagegrid_mousein_grid")
  nx_callback(image_grid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
  for i = 1, count do
    local item_id = nx_string(item_list[i])
    local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
    image_grid:AddItem(i - 1, photo, nx_widestr(item_id), 1, -1)
  end
  return image_grid
end
function set_copy_ent_info(form, source, target_ent)
  if not nx_is_valid(form) then
    return
  end
  local source_ent = nx_custom(form, source)
  if not nx_is_valid(source_ent) then
    return
  end
  local prop_list = nx_property_list(source_ent)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(target_ent, prop, nx_property(source_ent, prop))
    end
  end
end
function create_multitext()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nil
  end
  local multitextbox = gui:Create("MultiTextBox")
  if not nx_is_valid(multitextbox) then
    return nil
  end
  multitextbox.AutoSize = false
  multitextbox.Transparent = true
  multitextbox.Name = "MultiTextBox_path_" .. nx_string(i)
  multitextbox.TextColor = "255,197,184,159"
  multitextbox.SelectBarColor = "0,0,0,0"
  multitextbox.MouseInBarColor = "0,0,0,0"
  multitextbox.Font = "font_text"
  multitextbox.LineColor = "0,0,0,0"
  multitextbox.ShadowColor = "0,0,0,0"
  multitextbox.ViewRect = "0,0,310,80"
  return multitextbox
end
function create_multitext_with_name(task_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nil
  end
  local multitextbox = gui:Create("MultiTextBox")
  if not nx_is_valid(multitextbox) then
    return nil
  end
  multitextbox.AutoSize = false
  multitextbox.Transparent = true
  multitextbox.Name = "MultiTextBox_Task_" .. nx_string(task_id)
  multitextbox.TextColor = "255,197,184,159"
  multitextbox.SelectBarColor = "0,0,0,0"
  multitextbox.MouseInBarColor = "0,0,0,0"
  multitextbox.Font = "font_text"
  multitextbox.LineColor = "0,0,0,0"
  multitextbox.ShadowColor = "0,0,0,0"
  multitextbox.ViewRect = "0,0,310,80"
  return multitextbox
end
function on_server_msg(...)
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  update_role_list(form, arg)
  refresh_form(form)
  init_prize_grid(form.textgrid_prize)
  show_shitu_prize(form.textgrid_prize)
  form.textgrid_prize.Visible = true
end
function update_role_list(form, role_list_info)
  if not nx_find_custom(form, "role_list") then
    return
  end
  if not nx_is_valid(form.role_list) then
    return
  end
  form.role_count = role_list_info[1]
  form.role_list:ClearChild()
  g_select_flag = get_default_select_flag(form)
  local index = 1
  local count = table.getn(role_list_info)
  if 0 == count then
    return
  end
  for i = 2, count - 1, 2 do
    local role_list = role_list_info[i]
    local role_table = util_split_wstring(role_list, ",")
    local child = form.role_list:GetChild(nx_string(index))
    if not nx_is_valid(child) then
      child = form.role_list:CreateChild(nx_string(index))
      child.name = nx_widestr(role_table[1])
      child.power_level = nx_int(role_table[2])
      child.baishi_time = nx_int(role_table[3])
      child.is_online = nx_int(role_table[4])
      child.intimate_value = nx_int(role_table[5])
      child.role_info = nx_string(role_table[6])
      child.sex = nx_string(role_table[7])
      child.task_level = nx_number(role_table[8])
      child.role_model_info = role_list_info[i + 1]
    end
    index = index + 1
  end
  form.enshi_value = nx_int(role_list_info[count])
end
