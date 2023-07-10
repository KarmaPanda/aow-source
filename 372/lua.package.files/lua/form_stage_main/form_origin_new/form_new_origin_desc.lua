require("const_define")
require("util_functions")
require("util_gui")
require("tips_data")
require("role_composite")
require("share\\client_custom_define")
require("form_stage_main\\form_origin_new\\new_origin_define")
require("form_stage_main\\form_origin\\form_origin_define")
function open_form()
  local form = util_get_form(FORM_NEW_ORIGIN_MAIN, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function refresh_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_DESC, false, false)
  if not nx_is_valid(form) then
    return
  end
  show_origin_info(form, form.origin_id)
end
function main_form_init(form)
  form.Fixed = true
  form.origin_id = 0
end
function on_main_form_open(form)
  form.actor2 = nil
  show_origin_info(form, form.origin_id)
  form_rp_arm_showrole(form)
  data_bind_prop(form)
end
function on_main_form_close(form)
  if nx_is_valid(form.actor2) then
    local world = nx_value("world")
    world:Delete(form.actor2)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  local mainform = nx_value(FORM_NEW_ORIGIN_MAIN)
  if nx_is_valid(mainform) then
    if mainform.return_form_type == FORM_TYPE_SUB then
      nx_execute(FORM_NEW_ORIGIN_MAIN, "open_subform", mainform, FORM_TYPE_SUB, mainform.main_type, mainform.sub_type)
    else
      nx_execute(FORM_NEW_ORIGIN_MAIN, "open_subform", mainform, FORM_TYPE_ORIGIN_ACTIVED)
    end
  end
end
function show_origin_info(form, origin_id)
  if origin_id == nil then
    return false
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  form.mltbox_info:Clear()
  form.mltbox_condition:Clear()
  form.mltbox_award:Clear()
  form.imagegrid_item_prize:Clear()
  form.lbl_origin_name.Text = nx_widestr(util_text("origin_" .. nx_string(origin_id)))
  form.mltbox_info.HtmlText = nx_widestr(util_text("origin_desc_" .. nx_string(origin_id)))
  local origin_info = origin_manager:GetOriginInfo(origin_id)
  form.lbl_acheve_point.Text = nx_widestr(origin_info[ORIGIN_INFO_ACHEVE_POINT])
  form.lbl_material.Text = nx_widestr(util_text("ui_donghai_origin_level_" .. nx_string(origin_info[ORIGIN_INFO_MATERIAL])))
  local donghaiexp = origin_manager:GetDongHaiExp(origin_id)
  form.lbl_donghai_exp.Text = nx_widestr(donghaiexp)
  if nx_int(origin_info[ORIGIN_INFO_TIME_LIMIT]) <= nx_int(0) then
    form.lbl_time_limit.Text = nx_widestr(util_text("ui_neworigin_title_23"))
  else
    form.lbl_time_limit.Text = nx_widestr(origin_info[ORIGIN_INFO_TIME_LIMIT])
  end
  local active_and_condition_table = origin_manager:ActiveAndConditionList(origin_id)
  local active_or_condition_table = origin_manager:ActiveOrConditionList(origin_id)
  local show_prop_table = origin_manager:GetPropShowList(origin_id)
  local b_completed = origin_manager:IsCompletedOrigin(origin_id)
  local b_active = origin_manager:IsActiveOrigin(origin_id)
  local b_prized = origin_manager:IsOriginGetPrize(origin_id)
  local and_condition_desc = gui.TextManager:GetText("ui_and_condition_desc")
  local or_condition_desc = gui.TextManager:GetText("ui_or_condition_desc")
  local progress_desc = gui.TextManager:GetText("ui_origin_progress_desc")
  local mltbox_condition = form.mltbox_condition
  if b_completed then
    b_active = true
    form.mltbox_award.Visible = false
  else
    form.mltbox_award.Visible = true
  end
  local mltbox_condition = form.mltbox_condition
  if not b_active then
    form.btn_get_origin.Enabled = false
    form.btn_get_prize.Enabled = false
    form.lbl_get_origin_flash.Visible = false
    form.lbl_get_prize_flash.Visible = false
    form.role_box.Visible = false
    local active_condition_desc = gui.TextManager:GetText("ui_active_origin_condition")
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
    local line = origin_manager:GetOriginLine(origin_id)
    local form_main = nx_value(FORM_NEW_ORIGIN_MAIN)
    if nx_is_valid(form_main) and form_main.b_preview then
      show_cloth(form.origin_id, form_main.main_type, form_main.sub_type, line)
      form_main.b_preview = false
      form.role_box.Visible = true
    end
  else
    play_action()
    local game_timer = nx_value("timer_game")
    game_timer:Register(5000, -1, nx_current(), "play_action", form, -1, -1)
    form.role_box.Visible = true
    local get_and_condition_table = origin_manager:CompleteAndConditionList(origin_id)
    local get_or_condition_table = origin_manager:CompleteOrConditionList(origin_id)
    local get_condition_desc = gui.TextManager:GetText("ui_get_origin_condition")
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
    local get_event_table = origin_manager:GetOriginEventList(origin_id)
    local get_event_count = table.getn(get_event_table) / 2
    if 0 < get_event_count then
      for i = 1, get_event_count do
        local base = 2 * (i - 1)
        local event_id = get_event_table[base + 1]
        local event_num = get_event_table[base + 2]
        local real_text
        local cur_event_num = origin_manager:GetEventCount(event_id)
        if nx_int(cur_event_num) >= nx_int(event_num) then
          local event_decs = gui.TextManager:GetFormatText("desc_events_" .. nx_string(event_id), nx_int(event_num), nx_int(event_num))
          real_text = color_text(event_decs, true)
        else
          local event_decs = gui.TextManager:GetFormatText("desc_events_" .. nx_string(event_id), nx_int(cur_event_num), nx_int(event_num))
          real_text = color_text(event_decs, false)
        end
        local mlt_index = mltbox_condition:AddHtmlText(real_text, nx_int(-1))
        mlt_index = mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
        mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      end
    end
    local b_show_prize = true
    if not b_completed then
      if can_get_origin(player, condition_manager, origin_manager, origin_id) then
        form.btn_get_origin.Enabled = true
        form.lbl_get_origin_flash.Visible = true
      else
        form.btn_get_origin.Enabled = false
        form.lbl_get_origin_flash.Visible = false
      end
      form.btn_get_prize.Enabled = false
      form.lbl_get_prize_flash.Visible = false
    else
      form.btn_get_origin.Enabled = false
      form.lbl_get_origin_flash.Visible = false
      if b_prized then
        b_show_prize = false
        form.btn_get_prize.Enabled = false
        form.lbl_get_prize_flash.Visible = false
      else
        form.btn_get_prize.Enabled = true
        form.lbl_get_prize_flash.Visible = true
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
        end
      end
    end
    local line = origin_manager:GetOriginLine(origin_id)
    local form_main = nx_value(FORM_NEW_ORIGIN_MAIN)
    if nx_is_valid(form_main) then
      show_cloth(form.origin_id, form_main.main_type, form_main.sub_type, line)
    end
  end
  form.Visible = true
  form:Show()
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
  else
    or_table = origin_manager:CompleteOrConditionList(origin_id)
    count = table.getn(or_table)
    if 0 < count then
      local bCanSatisfy = false
      for i = 1, count do
        local condition_id = or_table[i]
        if condition_manager:CanSatisfyCondition(player, player, condition_id) then
          bCanSatisfy = true
        end
      end
      if not bCanSatisfy then
        return false
      end
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
function play_action()
  local form_origin = nx_value(FORM_NEW_ORIGIN_DESC)
  if not nx_is_valid(form_origin) or not nx_is_valid(form_origin.actor2) then
    return
  end
  local actor2 = form_origin.actor2
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
function form_rp_arm_showrole(form)
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local main_scene = world.MainScene
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local actor2 = form.actor2
  if nx_is_valid(actor2) then
    form.role_box.Scene:Delete(actor2)
  end
  local sex = client_player:QueryProp("Sex")
  local body_type = client_player:QueryProp("BodyType")
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  if body_type == ORIGIN_EM_BODY_WOMAN_JUV or body_type == ORIGIN_EM_BODY_MAN_JUV or body_type == ORIGIN_EM_BODY_WOMAN_MAJ or body_type == ORIGIN_EM_BODY_MAN_MAJ or origin_manager:IsExistCloth(form.origin_id) then
    actor2 = create_role_composite(form.role_box.Scene, false, sex, "stand", body_type)
    local showequip_type = 0
    if client_player:FindProp("ShowEquipType") then
      showequip_type = client_player:QueryProp("ShowEquipType")
    end
    role_composite:RefreshBodyNorEquip(client_player, actor2, showequip_type)
  else
    actor2 = role_composite:CreateSceneObjectWithSubModel(form.role_box.Scene, client_player, false, false, false)
  end
  form.role_actor2 = actor2
  if not nx_is_valid(actor2) then
    return false
  end
  while nx_is_valid(actor2) and not actor2.LoadFinish do
    nx_pause(0.1)
  end
  form.actor2 = actor2
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local body_type = origin_manager:GetBodyType(form.origin_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return
  end
  local line = origin_manager:GetOriginLine(form.origin_id)
  local form_main = nx_value(FORM_NEW_ORIGIN_MAIN)
  if nx_is_valid(form_main) then
    show_cloth(form.origin_id, form_main.main_type, form_main.sub_type, line)
    form.role_box.Visible = true
  end
end
function color_text(src, b_ok)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dest = nx_widestr("")
  if b_ok then
    local complete_decs = gui.TextManager:GetFormatText("ui_neworigin_desc_done")
    dest = dest .. nx_widestr(complete_decs)
  else
    local complete_decs = gui.TextManager:GetFormatText("ui_neworigin_desc_undone")
    dest = dest .. nx_widestr(complete_decs)
  end
  dest = nx_widestr(src) .. dest
  local ret = nx_widestr(dest)
  return ret
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
  local action_prize_table = origin_manager:GetActionPrizeList(origin_id)
  local count = table.getn(action_prize_table)
  if 0 < count then
    local mlt_index = mltbox:AddHtmlText(gui.TextManager:GetText("get_action_prize_desc"), nx_int(-1))
    mltbox:SetHtmlItemSelectable(mlt_index, false)
    for i = 1, count do
      local action_id = action_prize_table[i]
      mlt_index = mltbox:AddHtmlText(nx_widestr(util_text("ui_action_" .. nx_string(action_id))), nx_int(-1))
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
  if not nx_find_custom(form, "imagegrid_item_prize") then
    return
  end
  local imgrid_prize = form.imagegrid_item_prize
  imgrid_prize:Clear()
  local item_przie_table = origin_manager:GetItemPrizeList(origin_id)
  count = table.getn(item_przie_table)
  if 1 < count then
    local hasItems = false
    local item_num = count / 2
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
  if item_id ~= -1 and origin_manager:IsExistCloth(origin_id) then
    local form_origin = nx_value(FORM_NEW_ORIGIN_DESC)
    if not nx_is_valid(form_origin) or not nx_is_valid(form_origin.actor2) then
      return
    end
    local actor2 = form_origin.actor2
    if nx_is_valid(actor2) then
      nx_execute("role_composite", "unlink_skin", actor2, "Hat")
      nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
      nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
      nx_execute("role_composite", "unlink_skin", actor2, "Pants")
      nx_execute("role_composite", "unlink_skin", actor2, "Cloth_h")
      local game_client = nx_value("game_client")
      if not nx_is_valid(game_client) then
        return
      end
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      local client_ident = game_visual:QueryRoleClientIdent(actor2)
      local actor = game_client:GetSceneObj(nx_string(client_ident))
      if not nx_is_valid(actor) then
        return
      end
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
function on_btn_get_origin_click(btn)
  local form = btn.ParentForm
  local origin_id = form.origin_id
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ORIGIN), nx_int(origin_id))
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_get_prize_click(btn)
  local form = btn.ParentForm
  local origin_id = form.origin_id
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ORIGIN_PRIZE), nx_int(origin_id))
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_imagegrid_item_prize_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_item_prize_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_prize_tips(grid, index)
  local item_id = grid:GetItemName(nx_int(index))
  local item_count = grid:GetItemNumber(nx_int(index))
  if nx_string(item_id) == "" or nx_number(item_count) <= 0 then
    return false
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return false
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(item_id))
  if 0 >= table.getn(table_prop_name) then
    return false
  end
  table_prop_value.ConfigID = nx_string(item_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(item_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(item_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", nx_current())
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32, grid.ParentForm)
end
function data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("Origin_Active", form, nx_current(), "on_update_origin_rec")
    databinder:AddTableBind("Origin_Completed", form, nx_current(), "on_update_origin_rec")
    databinder:AddTableBind("Origin_Prized", form, nx_current(), "on_update_origin_rec")
    databinder:AddTableBind("Origin_Record", form, nx_current(), "on_update_origin_rec")
    databinder:AddTableBind("title_rec", form, nx_current(), "update_groupbox_complete_origin")
  end
end
function del_data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("Origin_Active", form)
    databinder:DelTableBind("Origin_Completed", form)
    databinder:DelTableBind("Origin_Prized", form)
    databinder:DelTableBind("Origin_Record", form)
    databinder:DelTableBind("title_rec", form)
  end
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "set_new_active_origin", 0)
end
function on_update_origin_rec(form, tablename, ttype, line, col)
  if not form.Visible then
    return
  end
  if line < 0 or col < 0 then
    return
  end
  nx_execute(FORM_NEW_ORIGIN_DESC, "show_origin_info", form, form.origin_id)
end
