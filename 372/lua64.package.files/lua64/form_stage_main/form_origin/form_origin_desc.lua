require("util_functions")
require("form_stage_main\\form_origin\\form_origin_define")
function show_origin_info(form, origin_id)
  if origin_id == nil then
    return false
  end
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "del_new_active_origin", origin_id)
  local gui = nx_value("gui")
  local rbtn_name = "rbtn_main_" .. nx_string(form.main_type)
  form.lbl_desc_name.Text = gui.TextManager:GetText(rbtn_name)
  form.lbl_hd.Visible = false
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local gui = nx_value("gui")
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local mltbox = form.mltbox_info
  mltbox:Clear()
  form.mltbox_condition:Clear()
  form.mltbox_award:Clear()
  form.imagegrid_item_prize:Clear()
  form.mltbox_prop:Clear()
  form.lbl_sh_info.Text = ""
  local active_and_condition_table = origin_manager:ActiveAndConditionList(origin_id)
  local active_or_condition_table = origin_manager:ActiveOrConditionList(origin_id)
  local get_and_condition_table = origin_manager:CompleteAndConditionList(origin_id)
  local get_or_condition_table = origin_manager:CompleteOrConditionList(origin_id)
  local show_prop_table = origin_manager:GetPropShowList(origin_id)
  local b_completed = origin_manager:IsCompletedOrigin(origin_id)
  local b_active = origin_manager:IsActiveOrigin(origin_id)
  local b_prized = origin_manager:IsOriginGetPrize(origin_id)
  local active_condition_desc = gui.TextManager:GetText("ui_active_origin_condition")
  local get_condition_desc = gui.TextManager:GetText("ui_get_origin_condition")
  local and_condition_desc = gui.TextManager:GetText("ui_and_condition_desc")
  local or_condition_desc = gui.TextManager:GetText("ui_or_condition_desc")
  local progress_desc = gui.TextManager:GetText("ui_origin_progress_desc")
  local mltbox_condition = form.mltbox_condition
  if b_completed then
    b_active = true
  end
  if not b_active then
    form.btn_get_origin.Enabled = false
    form.btn_get_prize.Enabled = false
    form.btn_get_origin_flash.Visible = false
    form.btn_get_prize_flash.Visible = false
    form.lbl_chenghao.Text = gui.TextManager:GetText("ui_no_weizhi")
    form.role_box.Visible = false
    form.role_box_body3.Visible = false
    form.role_box_body4.Visible = false
    form.role_box_body5.Visible = false
    form.role_box_body6.Visible = false
    form.lbl_role_bg.BackImage = nx_resource_path() .. "gui\\special\\origin\\" .. "bg_role.png"
    form.lbl_condition_text.Text = nx_widestr(active_condition_desc)
    local active_and_count = table.getn(active_and_condition_table)
    local active_or_count = table.getn(active_or_condition_table)
    if 0 < active_and_count then
      mlt_index = mltbox_condition:AddHtmlText(and_condition_desc, nx_int(-1))
      mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      for i = 1, active_and_count do
        local condition_id = active_and_condition_table[i]
        local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(condition_id))
        local b_ok = condition_manager:CanSatisfyCondition(player, player, condition_id)
        local real_text = color_text(condition_decs, b_ok)
        mlt_index = mltbox_condition:AddHtmlText(real_text, nx_int(-1))
        mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      end
    else
      mlt_index = mltbox_condition:AddHtmlText(or_condition_desc, nx_int(-1))
      mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      for i = 1, active_or_count do
        local condition_id = active_or_condition_table[i]
        local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(condition_id))
        local b_ok = condition_manager:CanSatisfyCondition(player, player, condition_id)
        local real_text = color_text(condition_decs, b_ok)
        mlt_index = mltbox_condition:AddHtmlText(real_text, nx_int(-1))
        mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      end
    end
  else
    play_action()
    local game_timer = nx_value("timer_game")
    game_timer:Register(5000, -1, nx_current(), "play_action", form, -1, -1)
    local body_type = origin_manager:GetBodyType(origin_id)
    nx_execute("form_stage_main\\form_origin\\form_origin", "ShowSceneBox", form, body_type)
    form.lbl_role_bg.BackImage = nx_resource_path() .. "gui\\special\\origin\\" .. "bg_role.png"
    local origin_name = gui.TextManager:GetText("origin_" .. nx_string(origin_id))
    form.lbl_chenghao.Text = nx_widestr(origin_name)
    local origin_info = gui.TextManager:GetText("origin_" .. nx_string(origin_id) .. "_desc")
    mlt_index = form.mltbox_info:AddHtmlText(origin_info, nx_int(-1))
    form.mltbox_info:SetHtmlItemSelectable(mlt_index, false)
    local form_life = nx_custom(form, "form_life")
    if nx_is_valid(form_life) and not b_completed and (form.sub_type_str == "shh_wenhua" or form.sub_type_str == "shh_zhizao" or form.sub_type_str == "shh_caiji" or form.sub_type_str == "shh_shijing") then
      local max_jobpoint = 0
      local prof_line = form_life.life_line
      if shenghuo_table[form.sub_type_str][prof_line] ~= nil then
        local row = player:FindRecordRow("job_rec", 0, shenghuo_table[form.sub_type_str][prof_line], 0)
        if 0 <= row then
          max_jobpoint = player:QueryRecord("job_rec", row, 2)
        end
        local prof_name = nx_widestr(gui.TextManager:GetText(nx_string(shenghuo_table[form.sub_type_str][prof_line])))
        gui.TextManager:Format_SetIDName("Ui_life_zongxinde_01")
        gui.TextManager:Format_AddParam(prof_name)
        gui.TextManager:Format_AddParam(nx_int(max_jobpoint))
        local info = gui.TextManager:Format_GetText()
        form.lbl_sh_info.Text = info
      end
    end
    local get_and_count = table.getn(get_and_condition_table)
    local get_or_count = table.getn(get_or_condition_table)
    if 0 < get_and_count then
      form.lbl_condition_text.Text = nx_widestr(get_condition_desc)
      mlt_index = mltbox_condition:AddHtmlText(and_condition_desc, nx_int(-1))
      mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      for i = 1, get_and_count do
        local condition_id = get_and_condition_table[i]
        local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(condition_id))
        local b_ok = condition_manager:CanSatisfyCondition(player, player, condition_id)
        local real_text = color_text(condition_decs, b_ok)
        mlt_index = mltbox_condition:AddHtmlText(real_text, nx_int(-1))
        mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      end
    elseif 0 < get_or_count then
      mlt_index = mltbox_condition:AddHtmlText(get_condition_desc, nx_int(-1))
      mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      mlt_index = mltbox_condition:AddHtmlText(or_condition_desc, nx_int(-1))
      mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      for i = 1, get_or_count do
        local condition_id = get_or_condition_table[i]
        local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(condition_id))
        local b_ok = condition_manager:CanSatisfyCondition(player, player, condition_id)
        local real_text = color_text(condition_decs, b_ok)
        local mlt_index = mltbox_condition:AddHtmlText(real_text, nx_int(-1))
        mlt_index = mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
        mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      end
    end
    local prop_num = table.getn(show_prop_table)
    if nx_int(prop_num) > nx_int(0) then
      prop_num = prop_num / 2
      for i = 1, prop_num do
        local prop_name = show_prop_table[i * 2 - 1]
        local text_str = show_prop_table[i * 2]
        if player:FindProp(nx_string(prop_name)) then
          local prop_type = player:GetPropType(nx_string(prop_name))
          local prop_value = player:QueryProp(nx_string(prop_name))
          local prop_desc = nx_widestr("")
          if nx_int(prop_type) == nx_int(VTYPE_INT) then
            prop_desc = nx_widestr(gui.TextManager:GetFormatText(nx_string(text_str), nx_int(prop_value)))
          end
          local mlt_index = form.mltbox_prop:AddHtmlText(prop_desc, nx_int(-1))
          form.mltbox_prop:SetHtmlItemSelectable(mlt_index, false)
        end
      end
    end
    local find_row = player:FindRecordRow("Origin_Record", 0, origin_id, 0)
    if 0 <= find_row then
      mlt_index = mltbox:AddHtmlText(progress_desc, nx_int(-1))
      mltbox:SetHtmlItemSelectable(mlt_index, false)
    end
    local max_rows = player:GetRecordRows("Origin_Record")
    if 0 < max_rows then
      for k = 1, max_rows do
        local id = player:QueryRecord("Origin_Record", k - 1, 0)
        if id == origin_id then
          local cur_count = player:QueryRecord("Origin_Record", k - 1, 3)
          local max_count = player:QueryRecord("Origin_Record", k - 1, 4)
          local text = player:QueryRecord("Origin_Record", k - 1, 6)
          local show_text = gui.TextManager:GetText(text)
          local final_text = nx_widestr("")
          if cur_count >= max_count then
            final_text = final_text .. nx_widestr("<font color=\"#006600\">")
          else
            final_text = final_text .. nx_widestr("<font color=\"#ff0000\">")
          end
          final_text = final_text .. nx_widestr(show_text) .. nx_widestr(" ") .. nx_widestr(cur_count) .. nx_widestr("/") .. nx_widestr(max_count) .. nx_widestr("</font>")
          mlt_index = mltbox:AddHtmlText(nx_widestr(final_text), nx_int(-1))
          mltbox:SetHtmlItemSelectable(mlt_index, false)
        end
      end
    end
    local b_show_prize = true
    if not b_completed then
      if can_get_origin(player, condition_manager, origin_manager, origin_id) then
        form.btn_get_origin.Enabled = true
        form.btn_get_origin_flash.Visible = true
      else
        form.btn_get_origin.Enabled = false
        form.btn_get_origin_flash.Visible = false
      end
      form.btn_get_prize.Enabled = false
      form.btn_get_prize_flash.Visible = false
    else
      form.btn_get_origin.Enabled = false
      form.btn_get_origin_flash.Visible = false
      if b_prized then
        b_show_prize = false
        form.btn_get_prize.Enabled = false
        form.btn_get_prize_flash.Visible = false
      else
        form.btn_get_prize.Enabled = true
        form.btn_get_prize_flash.Visible = true
      end
    end
    if b_show_prize then
      show_prize(form, origin_id)
    else
      local imgrid_prize = form.imagegrid_item_prize
      imgrid_prize:Clear()
      local item_przie_table = origin_manager:GetItemPrizeList(origin_id)
      count = table.getn(item_przie_table)
      if 1 < count then
        local item_num = count / 2
        for i = 1, item_num do
          local item_id = item_przie_table[i * 2 - 1]
          local item_count = item_przie_table[i * 2]
          local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(item_id), nx_string("Photo"))
          imgrid_prize:AddItem(i - 1, photo, nx_widestr(item_id), nx_int(item_count), 0)
          form.lbl_hd.Visible = true
        end
      end
    end
  end
  relocate_control_position(form)
end
function color_text(src, b_ok)
  local dest = nx_widestr("")
  if b_ok then
    dest = dest .. nx_widestr("<font color=\"#006600\">")
  else
    dest = dest .. nx_widestr("<font color=\"#ff0000\">")
  end
  dest = dest .. nx_widestr(src) .. nx_widestr("</font>")
  local ret = nx_widestr(dest)
  return ret
end
function can_active_origin(player, condition_manager, origin_manager, origin_id)
  if nx_int(player:QueryProp("IsJYFaucltyAttacker")) == nx_int(1) then
    return false
  end
  if origin_manager:CheckCantActiveOrigin(origin_id) then
    return false
  end
  if origin_manager:IsActiveOrigin(origin_id) then
    return false
  end
  if origin_manager:IsCompletedOrigin(origin_id) then
    return false
  end
  local and_table = origin_manager:ActiveAndConditionList(origin_id)
  local count = table.getn(and_table)
  if 0 < count then
    for i = 1, count do
      local condition_id = and_table[i]
      if not condition_manager:CanSatisfyCondition(player, player, condition_id) then
        return false
      end
    end
    return true
  else
    or_table = origin_manager:ActiveOrConditionList(origin_id)
    count = table.getn(or_table)
    if 0 < count then
      for i = 1, count do
        local condition_id = or_table[i]
        if condition_manager:CanSatisfyCondition(player, player, condition_id) then
          return true
        end
      end
      return false
    end
  end
  return true
end
function can_get_origin(player, condition_manager, origin_manager, origin_id)
  if origin_manager:IsCompletedOrigin(origin_id) then
    return false
  end
  if not origin_manager:IsActiveOrigin(origin_id) then
    return false
  end
  local max_rows = player:GetRecordRows("Origin_Record")
  if 0 < max_rows then
    for k = 1, max_rows do
      local id = player:QueryRecord("Origin_Record", k - 1, 0)
      if id == origin_id then
        local cur_count = player:QueryRecord("Origin_Record", k - 1, 3)
        local max_count = player:QueryRecord("Origin_Record", k - 1, 4)
        if cur_count < max_count then
          return false
        end
      end
    end
  end
  local and_table = origin_manager:CompleteAndConditionList(origin_id)
  local count = table.getn(and_table)
  if 0 < count then
    for i = 1, count do
      local condition_id = and_table[i]
      if not condition_manager:CanSatisfyCondition(player, player, condition_id) then
        return false
      end
    end
    return true
  else
    or_table = origin_manager:CompleteOrConditionList(origin_id)
    count = table.getn(or_table)
    if 0 < count then
      for i = 1, count do
        local condition_id = or_table[i]
        if condition_manager:CanSatisfyCondition(player, player, condition_id) then
          return true
        end
      end
      return false
    end
  end
  local get_event_table = origin_manager:GetOriginEventList(origin_id)
  local get_event_count = table.getn(get_event_table) / 2
  if 0 < get_event_count then
    for i = 1, get_event_count do
      local base = 2 * (i - 1)
      local event_id = get_event_table[base + 1]
      local event_num = get_event_table[base + 2]
      if not origin_manager:IsCompletedOriginEvent(event_id, event_num) then
        return false
      end
    end
  end
  return true
end
function relocate_control_position(form)
  form.groupbox_info.IsEditMode = true
  local cur_top = 0
  local height = form.mltbox_info:GetContentHeight()
  local height1 = form.mltbox_condition:GetContentHeight()
  local height2 = form.mltbox_award:GetContentHeight()
  form.mltbox_info.Height = height
  form.mltbox_info.Top = 0
  cur_top = cur_top + height + 20
  form.lbl_condition_bg.Top = cur_top
  form.lbl_condition_text.Top = cur_top + 5
  cur_top = cur_top + form.lbl_condition_bg.Height + 22
  form.mltbox_condition.Height = height1
  form.mltbox_condition.Top = cur_top
  cur_top = cur_top + height1 + 20
  form.lbl_award_bg.Top = cur_top
  form.lbl_award_text.Top = cur_top + 5
  cur_top = cur_top + form.lbl_award_bg.Height + 22
  form.mltbox_award.Height = height2
  form.mltbox_award.Top = cur_top
  cur_top = cur_top + height2
  if height1 == 0 then
    form.lbl_condition_text.Visible = false
    form.lbl_condition_bg.Visible = false
  else
    form.lbl_condition_text.Visible = true
    form.lbl_condition_bg.Visible = true
  end
  if height2 == 0 then
    form.lbl_award_text.Visible = false
    form.lbl_award_bg.Visible = false
  else
    form.lbl_award_text.Visible = true
    form.lbl_award_bg.Visible = true
  end
  form.mltbox_info.ViewRect = "0,0," .. nx_string(form.mltbox_info.Width) .. "," .. nx_string(height)
  form.mltbox_condition.ViewRect = "0,0," .. nx_string(form.mltbox_condition.Width) .. "," .. nx_string(height1)
  form.mltbox_award.ViewRect = "0,0," .. nx_string(form.mltbox_award.Width) .. "," .. nx_string(height2)
  form.imagegrid_item_prize.Top = cur_top + 10
  cur_top = cur_top + form.imagegrid_item_prize.Height + 10
  form.lbl_hd.Top = form.imagegrid_item_prize.Top - 4
  form.lbl_hd.Left = form.imagegrid_item_prize.Left - 5
  form.groupbox_info.HasVScroll = true
  form.groupbox_info.VScrollBar.Minimum = 0
  if 0 < form.imagegrid_item_prize.Top + form.imagegrid_item_prize.Height - form.groupbox_info.Height then
    form.groupbox_info.VScrollBar.Maximum = form.mltbox_info.Height + form.imagegrid_item_prize.Height - form.groupbox_info.Height + 20
  end
  form.groupbox_info.VScrollBar.Value = 0
  form.groupbox_info.IsEditMode = false
end
function show_prize(form, origin_id)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local gui = nx_value("gui")
  local mltbox = form.mltbox_award
  local title_prize_table = origin_manager:GetTitlePrizeList(origin_id)
  local count = table.getn(title_prize_table)
  if 0 < count then
    local mlt_index = mltbox:AddHtmlText(gui.TextManager:GetText("get_title_prize_desc"), nx_int(-1))
    mltbox:SetHtmlItemSelectable(mlt_index, false)
    for i = 1, count do
      local title_id = title_prize_table[i]
      local info = nx_widestr(title_prize_photo) .. nx_widestr(gui.TextManager:GetText("role_title_" .. nx_string(title_id)))
      mlt_index = mltbox:AddHtmlText(nx_widestr(info), nx_int(-1))
      mltbox:SetHtmlItemSelectable(mlt_index, false)
    end
  end
  local prop_prize_table = origin_manager:GetPropPrizeList(origin_id)
  count = table.getn(prop_prize_table)
  if 1 < count then
    local prop_num = count / 2
    local mlt_index = mltbox:AddHtmlText(gui.TextManager:GetText("get_prop_prize_desc"), nx_int(-1))
    mltbox:SetHtmlItemSelectable(mlt_index, false)
    for i = 1, prop_num do
      local prop_name = prop_prize_table[i * 2 - 1]
      local prop_value = prop_prize_table[i * 2]
      local info = nx_widestr(gui.TextManager:GetText("ui_origin_" .. nx_string(prop_name))) .. nx_widestr(prop_value)
      mlt_index = mltbox:AddHtmlText(nx_widestr(info), nx_int(-1))
    end
  end
  local imgrid_prize = form.imagegrid_item_prize
  imgrid_prize:Clear()
  local item_przie_table = origin_manager:GetItemPrizeList(origin_id)
  count = table.getn(item_przie_table)
  if 1 < count then
    local hasItems = false
    local item_num = count / 2
    local mlt_index = mltbox:AddHtmlText(gui.TextManager:GetText("get_item_prize_desc"), nx_int(-1))
    mltbox:SetHtmlItemSelectable(mlt_index, false)
    for i = 1, item_num do
      local item_id = item_przie_table[i * 2 - 1]
      local item_count = item_przie_table[i * 2]
      if 0 < string.len(item_id) then
        local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(item_id), nx_string("Photo"))
        imgrid_prize:AddItem(i - 1, photo, nx_widestr(item_id), nx_int(item_count), 0)
        hasItems = true
      end
    end
    if hasItems == false then
      mltbox:AddHtmlText(gui.TextManager:GetText("ui_None"), nx_int(-1))
    end
  end
end
function show_cloth(origin_id, main_type, sub_type, line)
  local origin_manager = nx_value("OriginManager")
  local item_id = -1
  local o_key = -1
  if line == 0 then
    local item_przie_table = origin_manager:GetItemPrizeList(origin_id)
    if table.getn(item_przie_table) >= 1 then
      item_id = item_przie_table[1]
    else
      local IDindex = origin_id % 100
      if 28 < IDindex then
        origin_id = jinjie_list[nx_string(origin_id)]
      end
      line = 1
      local find = false
      local origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type), line)
      for i = 1, table.getn(origin_table) do
        if origin_table[i] == origin_id then
          find = true
          break
        end
      end
      if find then
        line = 1
      else
        line = 2
      end
    end
  end
  if item_id == -1 then
    local origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type), line)
    local form_origin = nx_value(FORM_ORIGIN)
    local sub_type_str = ""
    if nx_string(sub_type) == "school_tianshan" then
      local originform = nx_value(FORM_ORIGIN)
      if nx_int(originform.cur_sex) == nx_int(0) then
        sub_type_str = sub_type .. "_1"
      else
        sub_type_str = sub_type .. "_0_1"
      end
      origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type_str), line)
    end
    for key, value in pairs(origin_table) do
      if value == origin_id then
        o_key = key
        break
      end
    end
    local item_query = nx_value("ItemQuery")
    for i = o_key, 1, -1 do
      local item_przie_table = origin_manager:GetItemPrizeList(origin_table[i])
      if table.getn(item_przie_table) >= 1 then
        local item_type = -1
        if item_query:FindItemByConfigID(nx_string(item_przie_table[1])) then
          item_type = item_query:GetItemPropByConfigID(item_przie_table[1], "ItemType")
        end
        if nx_int(item_type) == nx_int(180) then
          item_id = item_przie_table[1]
          break
        end
      end
    end
  end
  local body_type = origin_manager:GetBodyType(origin_id)
  nx_execute("form_stage_main\\form_origin\\form_origin", "ShowSceneBox", form_origin, body_type)
  if item_id ~= -1 then
    local form_origin = nx_value("form_stage_main\\form_origin\\form_origin")
    if not nx_is_valid(form_origin) then
      return
    end
    local actor2 = get_actor2(form_origin, body_type)
    if not nx_is_valid(actor2) then
      return
    end
    form_origin.cur_actor2 = actor2
    if nx_is_valid(actor2) then
      nx_execute("role_composite", "unlink_skin", actor2, "Hat")
      nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
      nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
      nx_execute("role_composite", "unlink_skin", actor2, "Pants")
      nx_execute("role_composite", "unlink_skin", actor2, "Cloth_h")
      local game_client = nx_value("game_client")
      local game_visual = nx_value("game_visual")
      local client_ident = game_visual:QueryRoleClientIdent(actor2)
      local actor = game_client:GetSceneObj(nx_string(client_ident))
      local sex = actor:QueryProp("Sex")
      if sex == 0 then
        nx_execute("role_composite", "link_skin", actor2, "cloth", "obj\\char\\b_" .. item_id .. "\\b_" .. item_id .. ".xmod")
        nx_execute("role_composite", "link_skin", actor2, "cloth_h", "obj\\char\\b_" .. item_id .. "\\b_" .. item_id .. "_h.xmod")
      else
        nx_execute("role_composite", "link_skin", actor2, "cloth", "obj\\char\\g_" .. item_id .. "\\g_" .. item_id .. ".xmod")
        nx_execute("role_composite", "link_skin", actor2, "cloth_h", "obj\\char\\g_" .. item_id .. "\\g_" .. item_id .. "_h.xmod")
      end
    end
  end
end
function play_action()
  local form_origin = nx_value("form_stage_main\\form_origin\\form_origin")
  if not nx_is_valid(form_origin) or not nx_is_valid(form_origin.cur_actor2) then
    return
  end
  local actor2 = form_origin.cur_actor2
  local action = nx_value("action_module")
  if action:ActionFinished(actor2, action_list[last_action]) then
    math.randomseed(os.time())
    local index = 0
    math.random(1, 5)
    while true do
      index = math.random(1, 5)
      if index ~= last_action then
        last_action = index
        break
      end
    end
    if nx_is_valid(action) then
      action:ActionInit(actor2)
      action:DoAction(actor2, action_list[index])
    end
  end
end
function get_actor2(form, body_type)
  if body_type == ORIGIN_EM_BODY_WOMAN_JUV then
    return form.actor2_body3
  elseif body_type == ORIGIN_EM_BODY_MAN_JUV then
    return form.actor2_body4
  elseif body_type == ORIGIN_EM_BODY_WOMAN_MAJ then
    return form.actor2_body5
  elseif body_type == ORIGIN_EM_BODY_MAN_MAJ then
    return form.actor2_body6
  else
    return form.actor2
  end
end
