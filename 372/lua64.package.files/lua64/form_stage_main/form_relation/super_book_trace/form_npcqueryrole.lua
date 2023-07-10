require("util_gui")
require("define\\object_type_define")
local TYPE_ITEM_NOTSHOW = 0
local TYPE_ITEM_SHOW = 1
local CLOSE_ZHUIZONG_TRACE = 2
local SUB_MSG_SHOW_TRACE = 2
local SUB_MSG_CLOSE_TRACE = 3
local SUB_MSG_SHOW_SEARCH = 4
local SUB_MSG_SHOW_RESULT = 5
local QUERY_GOOD_FEELING = 6
local SUB_MSG_ENDZHIBAO = 12
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
end
function on_main_form_close(form)
end
function open_npc_query_role_comfirm(name, neirong, type, instance_id, item_id, trans_money)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\super_book_trace\\form_npcqueryrole", true, false, instance_id)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.mltbox_neirong:Clear()
  form.mltbox_neirong.LineColor = "0,0,0,0"
  form.mltbox_neirong.TextColor = "255,255,255,255"
  form.mltbox_neirong.SelectBarColor = "0,0,0,0"
  form.mltbox_neirong.MouseInBarColor = "0,0,0,0"
  form.mltbox_neirong.Font = "font_btn"
  form.mltbox_neirong:AddHtmlText(nx_widestr(neirong), -1)
  if nx_int(type) == nx_int(TYPE_ITEM_NOTSHOW) then
    form.imagegrid_daoju.Visible = false
    form.lbl_item_number.Visible = false
    form.AbsLeft = gui.Desktop.Width - form.Width
    form.AbsTop = gui.Desktop.Height - 2 * form.Height
    form.money = trans_money
  end
  if nx_int(type) == nx_int(TYPE_ITEM_SHOW) then
    if item_id == nil or nx_string(item_id) == nx_string("") then
      return
    end
    form.data_item_id = nx_string(item_id)
    local itemmap = nx_value("ItemQuery")
    if not nx_is_valid(itemmap) then
      return
    end
    local photo = itemmap:GetItemPropByConfigID(nx_string(item_id), nx_string("Photo"))
    form.imagegrid_daoju.Visible = true
    form.AbsLeft = gui.Desktop.Width - form.Width
    form.AbsTop = gui.Desktop.Height - form.Height
    form.imagegrid_daoju:AddItem(0, nx_string(photo), nx_widestr(util_text("ui_task_prize_random")), 1, -1)
    form.lbl_item_number.Visible = true
    local item_number = nx_execute("form_stage_main\\form_mail\\form_mail_send", "get_item_num_by_configid", nx_string(item_id))
    form.lbl_item_number.TextColor = "255,255,255,255"
    form.lbl_item_number.Text = nx_widestr(item_number)
  end
  form.mytype = type
  form.name = name
  form:Show()
  form.Visible = true
end
function on_btn_qianwang_click(btn)
  local form = btn.Parent
  if not nx_find_custom(form, "mytype") then
    return
  end
  if not nx_find_custom(form, "name") then
    return
  end
  local type = form.mytype
  local name = form.name
  if nx_int(type) == nx_int(TYPE_ITEM_NOTSHOW) then
    nx_execute("custom_sender", "custom_delieve", nx_int(SUB_MSG_SHOW_TRACE), nx_widestr(name))
  end
  if nx_int(type) == nx_int(TYPE_ITEM_SHOW) then
    nx_execute("custom_sender", "custom_delieve", nx_int(SUB_MSG_SHOW_RESULT), nx_widestr(name))
  end
end
function on_btn_quxiao_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  form.Visible = false
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  if nx_is_valid(form) then
    form:Close()
    form.Visible = false
    nx_destroy(form)
  end
end
function on_imagegrid_daoju_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_daoju_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_npc_query_event(sub_cmd, ...)
  if nx_int(sub_cmd) == nx_int(SUB_MSG_SHOW_TRACE) then
    local num = table.getn(arg)
    if nx_int(num) < nx_int(8) then
      return
    end
    local name = arg[1]
    local scene_id = arg[2]
    local obj_x = arg[3]
    local obj_z = arg[4]
    local Scene_Resource = arg[5]
    local money = arg[6]
    local item_id = arg[7]
    local scene_config = arg[8]
    show_trace_notice(name, scene_id, obj_x, obj_z, Scene_Resource, scene_config)
    if nx_int(num) == nx_int(8) then
      open_trace_confirm(name, scene_id, money, scene_config)
      open_directly_trace_confirm(name, scene_id, item_id, scene_config)
    end
  end
  if nx_int(sub_cmd) == nx_int(SUB_MSG_CLOSE_TRACE) then
    local num = table.getn(arg)
    if nx_int(num) == nx_int(2) then
      close_assignation(arg[2])
    elseif nx_int(num) == nx_int(1) then
      close_trace_notice(arg[1])
    end
  end
  if nx_int(sub_cmd) == nx_int(SUB_MSG_SHOW_SEARCH) then
    nx_execute("form_stage_main\\form_relation\\super_book_trace\\form_result_show", "ShowCommonShow", 0, util_text(nx_string("ui_zhibao_querying")))
  end
  if nx_int(sub_cmd) == nx_int(SUB_MSG_SHOW_RESULT) then
    local num = table.getn(arg)
    local neirong
    if nx_int(num) == nx_int(1) then
      neirong = util_text(nx_string(arg[1]))
      nx_execute("form_stage_main\\form_relation\\super_book_trace\\form_result_show", "ShowCommonShow", TYPE_ITEM_SHOW, nx_widestr(neirong))
    end
    if nx_int(num) == nx_int(2) then
      neirong = util_format_string(nx_string(arg[1]), nx_int(arg[2]))
      nx_execute("form_stage_main\\form_relation\\super_book_trace\\form_result_show", "ShowCommonShow", CLOSE_ZHUIZONG_TRACE, nx_widestr(neirong))
    end
  end
  if nx_int(sub_cmd) == nx_int(QUERY_GOOD_FEELING) then
    local num = table.getn(arg)
    if nx_int(num) == nx_int(4) then
      show_npc_information(arg[1], arg[2], arg[3], arg[4])
    elseif nx_int(num) == nx_int(2) then
      show_npc_information(arg[1], arg[2])
    end
  end
end
function show_trace_notice(name, scene_id, obj_x, obj_z, Scene_Resource, scene_config)
  local tempID
  if nx_int(scene_id) <= nx_int(0) then
    tempID = "ui_zhibao_zhuizong_info2"
  else
    tempID = "ui_zhibao_zhuizong_info"
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName(nx_string(tempID))
  gui.TextManager:Format_AddParam(nx_widestr(name))
  if nx_int(scene_id) > nx_int(0) then
    gui.TextManager:Format_AddParam(util_text(nx_string(scene_config)))
  end
  local text = gui.TextManager:Format_GetText()
  local temp_txt
  if nx_string(tempID) == nx_string("ui_zhibao_zhuizong_info") then
    temp_txt = nx_string(text) .. "\n" .. nx_string(util_text("ui_zhibao_zhuizong_info3"))
    text = temp_txt
  end
  nx_execute("form_stage_main\\form_single_notice", "NotifyText", nx_int(24), text)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "show_zhuizong", true, nx_widestr(name), nx_int(obj_x), nx_int(obj_z), nx_string(Scene_Resource))
  local dialog_directly_trace_confirm = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\super_book_trace\\form_npcqueryrole", false, false, "directly_trace_confirm")
  if nx_is_valid(dialog_directly_trace_confirm) then
    if not nx_find_custom(dialog_directly_trace_confirm, "data_item_id") then
      return
    end
    local item_number = nx_execute("form_stage_main\\form_mail\\form_mail_send", "get_item_num_by_configid", nx_string(dialog_directly_trace_confirm.data_item_id))
    dialog_directly_trace_confirm.mltbox_neirong.TextColor = "255,255,255,255"
    dialog_directly_trace_confirm.lbl_item_number.Text = nx_widestr(item_number)
    gui.TextManager:Format_SetIDName(nx_string("ui_zhibao_arriveitem"))
    gui.TextManager:Format_AddParam(util_text(nx_string(scene_config)))
    local text_direct = gui.TextManager:Format_GetText()
    dialog_directly_trace_confirm.mltbox_neirong:Clear()
    dialog_directly_trace_confirm.mltbox_neirong.LineColor = "0,0,0,0"
    dialog_directly_trace_confirm.mltbox_neirong.TextColor = "255,255,255,255"
    dialog_directly_trace_confirm.mltbox_neirong.SelectBarColor = "0,0,0,0"
    dialog_directly_trace_confirm.mltbox_neirong.MouseInBarColor = "0,0,0,0"
    dialog_directly_trace_confirm.mltbox_neirong.Font = "font_btn"
    dialog_directly_trace_confirm.mltbox_neirong:AddHtmlText(nx_widestr(text_direct), -1)
  end
  local dialog_trace_confirm = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\super_book_trace\\form_npcqueryrole", false, false, "trace_confirm")
  if nx_is_valid(dialog_trace_confirm) and nx_find_custom(dialog_trace_confirm, "money") then
    gui.TextManager:Format_SetIDName(nx_string("ui_zhibao_arrivemoney"))
    gui.TextManager:Format_AddParam(util_text(nx_string(scene_config)))
    gui.TextManager:Format_AddParam(nx_int64(dialog_trace_confirm.money))
    local text_direct = gui.TextManager:Format_GetText()
    dialog_trace_confirm.mltbox_neirong:Clear()
    dialog_trace_confirm.mltbox_neirong.LineColor = "0,0,0,0"
    dialog_trace_confirm.mltbox_neirong.TextColor = "255,255,255,255"
    dialog_trace_confirm.mltbox_neirong.SelectBarColor = "0,0,0,0"
    dialog_trace_confirm.mltbox_neirong.MouseInBarColor = "0,0,0,0"
    dialog_trace_confirm.mltbox_neirong.Font = "font_btn"
    dialog_trace_confirm.mltbox_neirong:AddHtmlText(nx_widestr(text_direct), -1)
  end
end
function close_trace_notice(name)
  close_assignation(CLOSE_ZHUIZONG_TRACE)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "show_zhuizong", false, nx_widestr(""), nx_int(0), nx_int(0), nx_string(""))
  show_effect(name, false)
end
function show_effect(name, bShow)
  local game_visual = nx_value("game_visual")
  local client_obj = nx_execute("util_functions", "util_find_client_player_by_name", name)
  if not (nx_is_valid(game_visual) and nx_is_valid(client_obj)) or client_obj == nil then
    return
  end
  local visual_target = game_visual:GetSceneObj(nx_string(client_obj.Ident))
  if not bShow then
    local res = nx_execute("game_effect", "remove_effect", nx_string("zhibao_zhuizhong"), visual_target, visual_target)
  else
    local res = nx_execute("game_effect", "create_effect", nx_string("zhibao_zhuizhong"), visual_target, visual_target)
  end
end
function close_assignation(type)
  if nx_int(type) == nx_int(CLOSE_ZHUIZONG_TRACE) then
    local dialog2 = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\super_book_trace\\form_npcqueryrole", false, false, "trace_confirm")
    if nx_is_valid(dialog2) then
      dialog2:Close()
      dialog2.Visible = false
      nx_destroy(dialog2)
    end
    local dialog1 = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\super_book_trace\\form_npcqueryrole", false, false, "directly_trace_confirm")
    if nx_is_valid(dialog1) then
      dialog1:Close()
      dialog1.Visible = false
      nx_destroy(dialog1)
    end
  end
end
function open_trace_confirm(name, scene_id, money, scene_config)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName(nx_string("ui_zhibao_arrivemoney"))
  gui.TextManager:Format_AddParam(util_text(nx_string(scene_config)))
  gui.TextManager:Format_AddParam(nx_int64(money))
  local text = gui.TextManager:Format_GetText()
  open_npc_query_role_comfirm(name, nx_widestr(nx_string(text)), 0, nx_string("trace_confirm"), "", money)
end
function open_directly_trace_confirm(name, scene_id, item_id, scene_config)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName(nx_string("ui_zhibao_arriveitem"))
  gui.TextManager:Format_AddParam(util_text(nx_string(scene_config)))
  local text = gui.TextManager:Format_GetText()
  open_npc_query_role_comfirm(name, nx_widestr(nx_string(text)), 1, nx_string("directly_trace_confirm"), item_id)
end
function show_prize_tips(grid, index)
  local form = grid.ParentForm
  if not nx_find_custom(form, "data_item_id") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", form.data_item_id, grid:GetMouseInItemLeft() + grid.GridOffsetX, grid:GetMouseInItemTop() + grid.GridOffsetY)
end
function show_npc_information(npc_id, scene_id, rank, relation)
  local form = nx_value("form_stage_main\\form_relation\\super_book_trace\\form_npc_karma")
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  nx_execute("form_stage_main\\form_relation\\super_book_trace\\form_npc_karma", "show_npc_info", npc_id, scene_id, rank, relation)
end
function endzhibao()
  nx_execute("custom_sender", "custom_trace_role", nx_int(SUB_MSG_ENDZHIBAO))
end
