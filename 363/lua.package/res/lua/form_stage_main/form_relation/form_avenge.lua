require("util_functions")
require("share\\view_define")
local client_sub_msg_begin_avenge = 2
local client_sub_msg_cancel_avenge = 9
function main_form_init(form)
  form.Fixed = true
  form.avenge_serve_type = 0
  return 1
end
function change_form_size(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_form(form)
  InitItemAvengeForm(form)
  form.Visible = true
  return 1
end
function main_form_close(form)
  local form_talk_movie = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk_movie) then
    form_talk_movie:Close()
  end
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "item_avenge") then
    return
  end
  local b_item = form.item_avenge
  if b_item then
    item_avenge(btn)
    return
  end
  if not nx_execute("form_stage_main\\form_relation\\form_avenge_confirm", "second_word_unlock") then
    return
  end
  local level, need_watch, can_watch_other, name_show, talk_show, event_1, event_2, event_3, event_4, event_5 = get_avenge_select(form)
  local form_confirm = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_number(level) == nx_number(0) then
    local text = util_text("ui_avenge_no_level")
    form_confirm.cancel_btn.Visible = false
    form_confirm.ok_btn.Left = (form_confirm.Width - form_confirm.ok_btn.Width) / 2
    form_confirm.ok_btn.Visible = true
    nx_execute("form_common\\form_confirm", "show_common_text", form_confirm, text)
    form_confirm:ShowModal()
    return
  elseif nx_number(event_1) == nx_number(0) and nx_number(event_2) == nx_number(0) and nx_number(event_3) == nx_number(0) and nx_number(event_4) == nx_number(0) and nx_number(event_5) == nx_number(0) then
    local text = util_text("ui_avenge_no_event")
    form_confirm.cancel_btn.Visible = false
    form_confirm.ok_btn.Left = (form_confirm.Width - form_confirm.ok_btn.Width) / 2
    form_confirm.ok_btn.Visible = true
    nx_execute("form_common\\form_confirm", "show_common_text", form_confirm, text)
    form_confirm:ShowModal()
    return
  end
  if not nx_find_custom(form, "avenge_serve_type") then
    return
  end
  local xinge_exist = false
  if nx_int(get_item_num_by_configid("pet_niao_1")) > nx_int(0) or nx_int(get_item_num_by_configid("mail_xinge")) > nx_int(0) then
    xinge_exist = true
  end
  if nx_number(form.avenge_serve_type) == nx_number(1) and not xinge_exist then
    local text = util_text("11418")
    form_confirm.cancel_btn.Visible = false
    form_confirm.ok_btn.Left = (form_confirm.Width - form_confirm.ok_btn.Width) / 2
    form_confirm.ok_btn.Visible = true
    nx_execute("form_common\\form_confirm", "show_common_text", form_confirm, text)
    form_confirm:ShowModal()
    return
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_avenge_confirm")
  gui.TextManager:Format_AddParam(get_money_by_level(level, need_watch, can_watch_other))
  gui.TextManager:Format_AddParam(form.lbl_target_name.Text)
  local text = gui.TextManager:Format_GetText()
  form_confirm.cancel_btn.Visible = true
  form_confirm.ok_btn.Visible = true
  nx_execute("form_common\\form_confirm", "show_common_text", form_confirm, text)
  form_confirm:ShowModal()
  local res = nx_wait_event(100000000, form_confirm, "confirm_return")
  if res ~= "ok" then
    return
  end
  if nx_number(form.avenge_serve_type) == nx_number(0) then
    nx_execute("custom_sender", "custom_avenge", nx_int(client_sub_msg_begin_avenge), nx_int(0), nx_widestr(form.lbl_target_name.Text), nx_int(level), nx_int(need_watch), nx_int(can_watch_other), nx_widestr(name_show), nx_widestr(talk_show), nx_int(event_1), nx_int(event_2), nx_int(event_3), nx_int(event_4), nx_int(event_5))
  elseif nx_number(form.avenge_serve_type) == nx_number(1) then
    if not nx_find_custom(form, "npc_id") or not nx_find_custom(form, "npc_scene_id") then
      return
    end
    nx_execute("custom_sender", "custom_avenge", nx_int(client_sub_msg_begin_avenge), nx_int(1), nx_widestr(form.lbl_target_name.Text), nx_int(level), nx_int(need_watch), nx_int(can_watch_other), nx_widestr(name_show), nx_widestr(talk_show), nx_int(event_1), nx_int(event_2), nx_int(event_3), nx_int(event_4), nx_int(event_5), nx_string(form.npc_id), nx_int(form.npc_scene_id))
  end
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  nx_execute("custom_sender", "custom_avenge", nx_int(client_sub_msg_cancel_avenge))
end
function get_avenge_select(form)
  local level = 0
  local event_1 = 0
  local event_2 = 0
  local event_3 = 0
  local event_4 = 0
  local event_5 = 0
  if form.rbtn_lv_1.Checked then
    level = 1
  elseif form.rbtn_lv_2.Checked then
    level = 2
  elseif form.rbtn_lv_3.Checked then
    level = 3
  elseif form.rbtn_lv_4.Checked then
    level = 4
  elseif form.rbtn_lv_5.Checked then
    level = 5
  elseif form.rbtn_lv_6.Checked then
    level = 6
  end
  if form.cbtn_event_1.Checked then
    event_1 = 1
  end
  if form.cbtn_event_2.Checked then
    event_2 = 1
  end
  if form.cbtn_event_3.Checked then
    event_3 = 1
  end
  if form.cbtn_event_4.Checked then
    event_4 = 1
  end
  if form.cbtn_event_5.Checked then
    event_5 = 1
  end
  local need_watch = 0
  local can_watch_other = 0
  if form.cbtn_need_self_watch.Checked then
    need_watch = 1
  end
  if form.cbtn_can_watch_other.Checked then
    can_watch_other = 1
  end
  local gui = nx_value("gui")
  local name_show = nx_widestr("")
  local talk_show = nx_widestr(0)
  if form.edit_rbtn_2.Checked == true then
    talk_show = nx_widestr(1)
  end
  if form.edit_rbtn_3.Checked == true then
    talk_show = nx_widestr(2)
  end
  if name_show == nx_widestr("") then
    name_show = gui.TextManager:GetFormatText("ui_avenge_noselfname")
  end
  if talk_show == nx_widestr("") then
    talk_show = gui.TextManager:GetFormatText("ui_avenge_nonpcinfo")
  end
  local check_word = nx_value("CheckWords")
  if nx_is_valid(check_word) then
    name_show = check_word:CleanWords(name_show)
    talk_show = check_word:CleanWords(talk_show)
  end
  return level, need_watch, can_watch_other, name_show, talk_show, event_1, event_2, event_3, event_4, event_5
end
function get_money_by_level(level, need_watch, can_watch_other)
  local avenge_ini = nx_execute("util_functions", "get_ini", "share\\Karma\\AvengeEvent\\avenge_config.ini")
  if not nx_is_valid(avenge_ini) then
    return 0
  end
  local index_config = avenge_ini:FindSectionIndex("LEVELCONFIG")
  if index_config < 0 then
    return 0
  end
  local level_cost = avenge_ini:ReadString(index_config, "Level" .. nx_string(level), "")
  local need_watch_cost = avenge_ini:ReadString(index_config, "Online", "")
  local watch_other_cost = avenge_ini:ReadString(index_config, "Others", "")
  return nx_int(level_cost) + nx_int(need_watch_cost) * nx_int(need_watch) + nx_int(watch_other_cost) * nx_int(can_watch_other)
end
function get_money_by_item(need_watch, can_watch_other)
  local avenge_ini = nx_execute("util_functions", "get_ini", "share\\Karma\\AvengeEvent\\avenge_config.ini")
  if not nx_is_valid(avenge_ini) then
    return 0
  end
  local index_config = avenge_ini:FindSectionIndex("LEVELCONFIG")
  if index_config < 0 then
    return 0
  end
  local need_watch_cost = avenge_ini:ReadString(index_config, "Online", "")
  local watch_other_cost = avenge_ini:ReadString(index_config, "Others", "")
  return nx_int(need_watch_cost) * nx_int(need_watch) + nx_int(watch_other_cost) * nx_int(can_watch_other)
end
function init_form(form)
  local gui = nx_value("gui")
  form.lbl_target_name.Text = nx_widestr(form.TargetName)
  for i = 1, 6 do
    local Level_str = nx_string("Level" .. nx_string(i))
    local rbtn_level = form.groupbox_lv:Find(nx_string("rbtn_lv_" .. nx_string(i)))
    local lbl_level = form.groupbox_lv:Find(nx_string("lbl_lv_" .. nx_string(i)))
    if nx_find_custom(form, Level_str) then
      if nx_number(nx_custom(form, Level_str)) == nx_number(1) then
        rbtn_level.Enabled = true
        lbl_level.ForeColor = "255,128,101,74"
      elseif nx_number(nx_custom(form, Level_str)) == nx_number(0) then
        rbtn_level.Enabled = false
        lbl_level.ForeColor = "255,128,101,74"
        rbtn_level.HintText = gui.TextManager:GetFormatText("ui_avenge_cant")
      else
        rbtn_level.Enabled = false
        lbl_level.ForeColor = "50,128,101,74"
        rbtn_level.HintText = gui.TextManager:GetFormatText("tips_avengelevel_forbid")
      end
    end
  end
  for i = 1, 5 do
    local Event_str = nx_string("Event" .. nx_string(i))
    local cbtn_event = form.groupbox_events:Find(nx_string("cbtn_event_" .. nx_string(i)))
    local lbl_event = form.groupbox_events:Find(nx_string("lbl_event_" .. nx_string(i)))
    if nx_find_custom(form, Event_str) then
      if nx_number(nx_custom(form, Event_str)) == nx_number(1) then
        cbtn_event.Enabled = true
        lbl_event.ForeColor = "255,128,101,74"
      else
        cbtn_event.Enabled = false
        lbl_event.ForeColor = "50,128,101,74"
        cbtn_event.HintText = gui.TextManager:GetFormatText("tips_avengeevent_forbid")
      end
    end
  end
  form.cbtn_need_self_watch.Checked = false
  form.cbtn_can_watch_other.Checked = false
  form.edit_rbtn_1.Checked = true
  form.imagegrid_pigeon.Visible = false
  if nx_number(form.avenge_serve_type) == nx_number(1) then
    form.imagegrid_pigeon.Visible = true
    local databinder = nx_value("data_binder")
    if nx_is_valid(databinder) then
      databinder:AddViewBind(VIEWPORT_TOOL, form.imagegrid_pigeon, "form_stage_main\\form_relation\\form_avenge", "on_pigeon_number_change")
    end
  end
end
function on_edit_get_focus(self)
  self.Text = nx_widestr("")
end
function on_pigeon_number_change(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return
  end
  local pigeon_number = get_item_num_by_configid("mail_xinge")
  local special_pigeon_num = get_item_num_by_configid("pet_niao_1")
  if nx_int(special_pigeon_num) > nx_int(0) then
    pigeon_number = 999
  end
  grid:Clear()
  grid:AddItem(0, "icon\\prop\\prop_xinge.png", "", pigeon_number, -1)
  if nx_number(pigeon_number) == nx_number(0) then
    grid:ChangeItemImageToBW(0, true)
  else
    grid:ChangeItemImageToBW(0, false)
  end
end
function get_item_num_by_configid(configid)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local view_id = goods_grid:GetToolBoxViewport(nx_string(configid))
  local toolbox_view = game_client:GetView(nx_string(view_id))
  local pigeon_number = 0
  if nx_is_valid(toolbox_view) then
    local obj_lst = toolbox_view:GetViewObjList()
    for j, obj in pairs(obj_lst) do
      local obj_id = obj:QueryProp("ConfigID")
      if nx_string(obj_id) == nx_string(configid) then
        local num = obj:QueryProp("Amount")
        pigeon_number = pigeon_number + num
      end
    end
  end
  return pigeon_number
end
function item_avenge(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "item_avenge") then
    return
  end
  local b_item = form.item_avenge
  if not b_item then
    return
  end
  local level, need_watch, can_watch_other, name_show, talk_show, event_1, event_2, event_3, event_4, event_5 = get_avenge_select(form)
  local form_confirm = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_number(level) == nx_number(0) then
    local text = util_text("ui_avenge_no_level")
    form_confirm.cancel_btn.Visible = false
    form_confirm.ok_btn.Left = (form_confirm.Width - form_confirm.ok_btn.Width) / 2
    form_confirm.ok_btn.Visible = true
    nx_execute("form_common\\form_confirm", "show_common_text", form_confirm, text)
    form_confirm:ShowModal()
    return
  elseif nx_number(event_1) == nx_number(0) and nx_number(event_2) == nx_number(0) and nx_number(event_3) == nx_number(0) and nx_number(event_4) == nx_number(0) and nx_number(event_5) == nx_number(0) then
    local text = util_text("ui_avenge_no_event")
    form_confirm.cancel_btn.Visible = false
    form_confirm.ok_btn.Left = (form_confirm.Width - form_confirm.ok_btn.Width) / 2
    form_confirm.ok_btn.Visible = true
    nx_execute("form_common\\form_confirm", "show_common_text", form_confirm, text)
    form_confirm:ShowModal()
    return
  end
  if nx_number(need_watch) + nx_number(can_watch_other) ~= nx_number(0) and not nx_execute("form_stage_main\\form_relation\\form_avenge_confirm", "second_word_unlock") then
    return
  end
  if not nx_find_custom(form, "avenge_serve_type") then
    return
  end
  local xinge_exist = false
  if nx_int(get_item_num_by_configid("pet_niao_1")) > nx_int(0) or nx_int(get_item_num_by_configid("mail_xinge")) > nx_int(0) then
    xinge_exist = true
  end
  if nx_number(form.avenge_serve_type) == nx_number(1) and not xinge_exist then
    local text = util_text("11418")
    form_confirm.cancel_btn.Visible = false
    form_confirm.ok_btn.Left = (form_confirm.Width - form_confirm.ok_btn.Width) / 2
    form_confirm.ok_btn.Visible = true
    nx_execute("form_common\\form_confirm", "show_common_text", form_confirm, text)
    form_confirm:ShowModal()
    return
  end
  local gui = nx_value("gui")
  if nx_number(need_watch) + nx_number(can_watch_other) ~= nx_number(0) then
    gui.TextManager:Format_SetIDName("ui_avenge_confirm")
    gui.TextManager:Format_AddParam(get_money_by_item(need_watch, can_watch_other))
    gui.TextManager:Format_AddParam(form.lbl_target_name.Text)
  else
    gui.TextManager:Format_SetIDName("ui_item_avenge_confirm")
    gui.TextManager:Format_AddParam(form.lbl_target_name.Text)
  end
  local text = gui.TextManager:Format_GetText()
  form_confirm.cancel_btn.Visible = true
  form_confirm.ok_btn.Visible = true
  nx_execute("form_common\\form_confirm", "show_common_text", form_confirm, text)
  form_confirm:ShowModal()
  local res = nx_wait_event(100000000, form_confirm, "confirm_return")
  if res ~= "ok" then
    return
  end
  if nx_number(form.avenge_serve_type) == nx_number(0) then
    nx_execute("custom_sender", "custom_avenge", nx_int(client_sub_msg_begin_avenge), nx_int(0), nx_widestr(form.lbl_target_name.Text), nx_int(level), nx_int(need_watch), nx_int(can_watch_other), nx_widestr(name_show), nx_widestr(talk_show), nx_int(event_1), nx_int(event_2), nx_int(event_3), nx_int(event_4), nx_int(event_5))
  elseif nx_number(form.avenge_serve_type) == nx_number(1) then
    if not nx_find_custom(form, "npc_id") or not nx_find_custom(form, "npc_scene_id") then
      return
    end
    nx_execute("custom_sender", "custom_avenge", nx_int(client_sub_msg_begin_avenge), nx_int(1), nx_widestr(form.lbl_target_name.Text), nx_int(level), nx_int(need_watch), nx_int(can_watch_other), nx_widestr(name_show), nx_widestr(talk_show), nx_int(event_1), nx_int(event_2), nx_int(event_3), nx_int(event_4), nx_int(event_5), nx_string(form.npc_id), nx_int(form.npc_scene_id))
  end
  form:Close()
  return
end
function InitItemAvengeForm(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "item_avenge") then
    return
  end
  local b_item = form.item_avenge
  if not b_item then
    return
  end
  local gui = nx_value("gui")
  form.lbl_lv_1.Text = nx_widestr(gui.TextManager:GetFormatText("ui_avenge_level_1_1"))
  form.lbl_lv_2.Text = nx_widestr(gui.TextManager:GetFormatText("ui_avenge_level_2_2"))
  form.lbl_lv_3.Text = nx_widestr(gui.TextManager:GetFormatText("ui_avenge_level_3_3"))
  form.lbl_lv_4.Text = nx_widestr(gui.TextManager:GetFormatText("ui_avenge_level_4_4"))
  form.lbl_lv_5.Text = nx_widestr(gui.TextManager:GetFormatText("ui_avenge_level_5_5"))
  form.lbl_lv_6.Text = nx_widestr(gui.TextManager:GetFormatText("ui_avenge_level_6_6"))
  return
end
