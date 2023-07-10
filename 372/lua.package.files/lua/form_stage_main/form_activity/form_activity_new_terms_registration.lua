require("util_gui")
require("util_functions")
require("util_static_data")
local FORM_NEW_TERMS = "form_stage_main\\form_activity\\form_activity_new_terms_registration"
local INI_NEW_TERMS_REGISTRATION = "share\\Activity\\activity_new_terms_registration.ini"
local IMAGE_GET_TYPE1 = "gui\\special\\hd_kxxxr\\kxqd"
local IMAGE_GET_TYPE2 = "gui\\special\\hd_kxxxr\\kxqdlj"
function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.groupbox_template_1.Visible = false
  form.groupbox_template_2.Visible = false
  init_form(form)
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("NewTermsLastSignTime", "int", form, nx_current(), "refresh_all_form")
    databinder:AddTableBind("NewTermsSignRec", form.groupbox_type_1, nx_current(), "refresh_all_form")
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    local CLIENT_CUSTOMMSG_NEW_TERMS_SIGN = 209
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TERMS_SIGN), nx_int(-1), nx_int(-1))
  end
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(form_main) then
    nx_execute("form_stage_main\\form_activity\\form_activity_new_terms_registration", "show_flashing_icon", form_main.lbl_nts_select)
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("NewTermsLastSignTime", form)
    databinder:DelTableBind("NewTermsSignRec", form.groupbox_type_1)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_sign_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
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
  local item_list = util_split_string(btn.DataSource, "_")
  if table.getn(item_list) ~= 2 then
    return
  end
  local reward_type = nx_int(item_list[1])
  local index = nx_int(item_list[2])
  if reward_type ~= nil and reward_type > nx_int(0) and reward_type <= nx_int(2) and index ~= nil then
    local CLIENT_CUSTOMMSG_NEW_TERMS_SIGN = 209
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TERMS_SIGN), nx_int(reward_type), nx_int(index))
  end
end
function on_btn_sign_get_capture(btn)
  if not nx_find_custom(btn, "reward_id") then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  local item_id = btn.reward_id
  if nx_string(item_id) == "" then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_id, x, y, form)
end
function on_btn_sign_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", form)
end
function refresh_all_form()
  local form = nx_value(FORM_NEW_TERMS)
  if not nx_is_valid(form) then
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
  local sign_count = client_player:QueryProp("NewTermsSignCount")
  local last_sign_time = client_player:QueryProp("NewTermsLastSignTime")
  local MessageDelay = nx_value("MessageDelay")
  if not nx_is_valid(MessageDelay) then
    MessageDelay = nx_create("MessageDelay")
  end
  local now = MessageDelay:GetServerDateTime()
  local get_list = {}
  if client_player:FindRecord("NewTermsSignRec") then
    local rows = client_player:GetRecordRows("NewTermsSignRec")
    if nx_int(rows) > nx_int(0) then
      for i = 0, rows - 1 do
        local num = client_player:QueryRecord("NewTermsSignRec", i, 0)
        if nx_int(num) > nx_int(0) then
          for j = 0, 31 do
            local flag = nx_function("ext_get_bit_value", nx_int(num), nx_int(j + 1))
            if nx_int(flag) ~= nx_int(0) then
              table.insert(get_list, 32 * i + j)
            end
          end
        end
      end
    end
  end
  local gbox_list = form.groupbox_type_1:GetChildControlList()
  for i, gbox in ipairs(gbox_list) do
    local btn = gbox.sub_btn
    local lbl_reward = gbox.sub_lblreward
    local lbl_select = gbox.sub_lblselect
    if nx_is_valid(btn) and nx_is_valid(lbl_reward) and nx_is_valid(lbl_select) then
      local b_find = false
      local btn_index = -1
      local item_list = util_split_string(btn.DataSource, "_")
      if table.getn(item_list) == 2 then
        btn_index = item_list[2]
      end
      for i = 1, table.getn(get_list) do
        if nx_int(btn.post_id) == nx_int(get_list[i]) then
          b_find = true
        end
      end
      if b_find then
        btn.NormalImage = IMAGE_GET_TYPE1 .. "1.png"
      else
        btn.NormalImage = IMAGE_GET_TYPE1 .. "0.png"
      end
      gbox.b_find = b_find
    end
  end
  local b_condition = can_open_new_terms_sign()
  for i, gbox in ipairs(gbox_list) do
    local btn = gbox.sub_btn
    local lbl_select = gbox.sub_lblselect
    if nx_is_valid(btn) and nx_is_valid(lbl_select) then
      lbl_select.Visible = nx_int(btn.need_days) == nx_int(sign_count + 1) and nx_int(now) ~= nx_int(last_sign_time) and not nx_boolean(gbox.b_find) and nx_boolean(b_condition)
    else
      lbl_select.Visible = false
    end
  end
  gbox_list = form.groupbox_type_2:GetChildControlList()
  for i, gbox in ipairs(gbox_list) do
    local btn = gbox.sub_btn
    local lbl_reward = gbox.sub_lblreward
    local lbl_select = gbox.sub_lblselect
    if nx_is_valid(btn) and nx_is_valid(lbl_reward) and nx_is_valid(lbl_select) then
      local b_find = false
      local btn_index = -1
      local item_list = util_split_string(btn.DataSource, "_")
      if table.getn(item_list) == 2 then
        btn_index = item_list[2]
      end
      for i = 1, table.getn(get_list) do
        if nx_int(btn.post_id) == nx_int(get_list[i]) then
          b_find = true
        end
      end
      if b_find then
        btn.NormalImage = IMAGE_GET_TYPE2 .. "1.png"
      else
        btn.NormalImage = IMAGE_GET_TYPE2 .. "0.png"
      end
      lbl_select.Visible = nx_int(btn.need_days) <= nx_int(sign_count) and nx_int(now) >= nx_int(last_sign_time) and not b_find and nx_boolean(b_condition)
    end
  end
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = get_ini(INI_NEW_TERMS_REGISTRATION, true)
  if not nx_is_valid(ini) then
    return
  end
  local reward_list, image_path_prefix, item_list, item_count
  local sec_index = ini:FindSectionIndex("1")
  if 0 <= sec_index then
    local post_list = ini:ReadString(sec_index, "PostRewardID", "")
    local list = util_split_string(post_list, ",")
    local real_list = ""
    for i = 1, table.getn(list) do
      if nx_int(list[i]) > nx_int(0) then
        real_list = real_list .. nx_string(list[i])
        if i < table.getn(list) then
          real_list = real_list .. ","
        end
      end
    end
    reward_list = ini:ReadString(sec_index, "RewardItemID", "")
    item_list = util_split_string(reward_list, ",")
    item_count = table.getn(item_list)
    if nx_int(item_count) > nx_int(0) then
      create_sub_gbox(form, 1, form.groupbox_type_1, item_count, 10, 0, reward_list, real_list, nil, 2)
    end
  end
  sec_index = ini:FindSectionIndex("2")
  if 0 <= sec_index then
    local need_days_list = {}
    local post_list = ini:ReadString(sec_index, "PostRewardID", "")
    local list = util_split_string(post_list, ",")
    local real_list = ""
    for i = 1, table.getn(list) do
      if nx_int(list[i]) > nx_int(0) then
        real_list = real_list .. nx_string(list[i])
        table.insert(need_days_list, i)
        if i < table.getn(list) then
          real_list = real_list .. ","
        end
      end
    end
    reward_list = ini:ReadString(sec_index, "RewardItemID", "")
    item_list = util_split_string(reward_list, ",")
    item_count = table.getn(item_list)
    if nx_int(item_count) > nx_int(0) then
      create_sub_gbox(form, 2, form.groupbox_type_2, item_count, 5, 0, reward_list, real_list, need_days_list, 1)
    end
  end
end
function create_sub_gbox(form, subgbox_type, parent_gbox, itemcount, colmaxcount, space_index, rewardlist, postrewardlist, need_days_list, default_row)
  local item_count = nx_int(itemcount)
  local col_maxcount = nx_int(colmaxcount)
  local space = nx_int(space_index)
  if not (nx_is_valid(form) and nx_is_valid(parent_gbox)) or subgbox_type <= 0 or 2 < subgbox_type or item_count <= nx_int(0) or col_maxcount <= nx_int(1) or space < nx_int(0) then
    return
  end
  if nx_int(default_row) < nx_int(1) then
    default_row = 1
  end
  local template_gbox = nx_custom(form, "groupbox_template_" .. nx_string(subgbox_type))
  local template_btn = nx_custom(form, "btn_template_" .. nx_string(subgbox_type))
  local template_lbl_title = nx_custom(form, "lbl_template_day_" .. nx_string(subgbox_type))
  local template_lbl_reward = nx_custom(form, "lbl_template_reward_" .. nx_string(subgbox_type))
  local template_lbl_select = nx_custom(form, "lbl_guangxiao_" .. nx_string(subgbox_type))
  if not (nx_is_valid(template_gbox) and nx_is_valid(template_btn) and nx_is_valid(template_lbl_title) and nx_is_valid(template_lbl_reward)) or not nx_is_valid(template_lbl_select) then
    return
  end
  local reward_list = util_split_string(rewardlist, ",")
  local post_list = util_split_string(postrewardlist, ",")
  if nx_int(table.getn(post_list)) ~= item_count then
    return
  end
  local gbox, btn, lbl_title, lbl_reward, last_gbox = nx_null(), nx_null(), nx_null(), nx_null(), nx_null()
  for i = 1, itemcount do
    gbox = clone_control("GroupBox", "gbox_day" .. nx_string(subgbox_type) .. nx_string(i), template_gbox, parent_gbox)
    if nx_is_valid(gbox) then
      if i ~= 0 then
        local mod = math.mod(i, colmaxcount)
        if mod ~= 0 then
          gbox.Left = (math.mod(i, colmaxcount) - 1) * (template_gbox.Width + space)
          gbox.Top = nx_int(i / colmaxcount) * template_gbox.Height
        else
          gbox.Left = (colmaxcount - 1) * (template_gbox.Width + space)
          gbox.Top = last_gbox.Top
        end
      else
        gbox.Left = 0
        gbox.Top = 0
      end
      gbox.Visible = true
      btn = clone_control("Button", "btn_day" .. nx_string(subgbox_type) .. nx_string(i), template_btn, gbox)
      if nx_is_valid(btn) then
        btn.Left = template_btn.Left
        btn.Top = template_btn.Top
        btn.Visible = true
        nx_bind_script(btn, nx_current())
        nx_callback(btn, "on_click", "on_btn_sign_click")
        nx_callback(btn, "on_get_capture", "on_btn_sign_get_capture")
        nx_callback(btn, "on_lost_capture", "on_btn_sign_lost_capture")
        btn.DataSource = nx_string(subgbox_type) .. "_" .. nx_string(i)
        btn.Enabled = true
        if subgbox_type == 1 then
          btn.need_days = i
        elseif subgbox_type == 2 and i <= table.getn(need_days_list) then
          btn.need_days = need_days_list[i]
        end
        gbox.sub_btn = btn
      end
      lbl_title = clone_control("Label", "lbl_title" .. nx_string(subgbox_type) .. nx_string(i), template_lbl_title, gbox)
      if nx_is_valid(lbl_title) then
        lbl_title.Left = template_lbl_title.Left
        lbl_title.Top = template_lbl_title.Top
        lbl_title.Visible = true
        if subgbox_type == 1 then
          lbl_title.Text = util_format_string("ui_new_terms_sign_01", i)
        elseif subgbox_type == 2 and i <= table.getn(need_days_list) then
          lbl_title.Text = util_format_string("ui_new_terms_sign_lj_01", nx_int(need_days_list[i]))
        end
      end
      lbl_reward = clone_control("Label", "lbl_reward" .. nx_string(subgbox_type) .. nx_string(i), template_lbl_reward, gbox)
      if nx_is_valid(lbl_reward) then
        if reward_list[i] ~= nil and reward_list[i] ~= "" and reward_list[i] ~= "-1" then
          local photo = item_query_ArtPack_by_id(reward_list[i], "Photo")
          lbl_reward.BackImage = photo
          if nx_is_valid(btn) and post_list[i] ~= nil and post_list[i] ~= "" then
            btn.reward_id = reward_list[i]
            btn.post_id = post_list[i]
          end
        end
        lbl_reward.Left = template_lbl_reward.Left
        lbl_reward.Top = template_lbl_reward.Top
        lbl_reward.DrawMode = "FitWindow"
        lbl_reward.Visible = true
        gbox.sub_lblreward = lbl_reward
      end
      lbl_select = clone_control("Label", "lbl_select" .. nx_string(subgbox_type) .. nx_string(i), template_lbl_select, gbox)
      if nx_is_valid(lbl_select) then
        lbl_select.Visible = false
        lbl_select.Left = template_lbl_select.Left
        lbl_select.Top = template_lbl_select.Top
        gbox.sub_lblselect = lbl_select
      end
      last_gbox = gbox
    end
  end
  local rows = nx_int(nx_int(itemcount) / nx_int(colmaxcount))
  if nx_int(itemcount) > nx_int(nx_int(colmaxcount) * nx_int(rows)) then
    rows = rows + 1
  end
  local lbl_type = nx_custom(form, "lbl_" .. nx_string(subgbox_type))
  if nx_int(rows) > nx_int(default_row) then
    local height_add = (nx_int(rows) - nx_int(default_row)) * template_gbox.Height
    parent_gbox.Height = parent_gbox.Height + height_add
    if nx_string(parent_gbox.VAnchor) == "Bottom" then
      parent_gbox.Top = parent_gbox.Top - height_add
      if nx_is_valid(lbl_type) then
        lbl_type.Top = lbl_type.Top - height_add
      end
    end
    form.Height = form.Height + height_add
  end
end
function clone_control(ctrl_type, name, refer_ctrl, parent_ctrl)
  if not (nx_is_valid(refer_ctrl) and nx_is_valid(parent_ctrl)) or ctrl_type == "" or name == "" then
    return nx_null()
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local cloned_ctrl = gui:Create(ctrl_type)
  if not nx_is_valid(cloned_ctrl) then
    return nx_null()
  end
  local prop_list = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_list) do
    nx_set_property(cloned_ctrl, prop_list[i], nx_property(refer_ctrl, prop_list[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, cloned_ctrl)
  cloned_ctrl.Name = name
  parent_ctrl:Add(cloned_ctrl)
  return cloned_ctrl
end
function can_open_new_terms_sign()
  local ini = get_ini(INI_NEW_TERMS_REGISTRATION, true)
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex("default")
  if 0 <= sec_index then
    local condition_id = ini:ReadInteger(sec_index, "ConditionID", 0)
    if nx_int(condition_id) >= nx_int(0) then
      local condition_manager = nx_value("ConditionManager")
      if not nx_is_valid(condition_manager) then
        return false
      end
      local game_client = nx_value("game_client")
      if not nx_is_valid(game_client) then
        return false
      end
      local client_player = game_client:GetPlayer()
      if not nx_is_valid(client_player) then
        return false
      end
      return condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(condition_id))
    end
  end
  return false
end
function is_switch_open()
  local ST_NORMAL_ACTIVITY_NEW_TERMS_SIGN = 2118
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  return switch_manager:CheckSwitchEnable(ST_NORMAL_ACTIVITY_NEW_TERMS_SIGN)
end
function start_bind_table(ctrl)
  if not nx_is_valid(ctrl) then
    return
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("NewTermsSignRec", ctrl, FORM_NEW_TERMS, "show_flashing_icon")
  end
end
function show_flashing_icon(ctrl, record_name, op_type, row, col)
  if nx_is_valid(ctrl) then
    if not is_switch_open() then
      ctrl.Visible = false
      return
    end
    ctrl.Visible = is_show_flashing_icon()
  end
end
function is_show_flashing_icon()
  if not can_open_new_terms_sign() then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local sign_count = client_player:QueryProp("NewTermsSignCount")
  local last_sign_time = client_player:QueryProp("NewTermsLastSignTime")
  local MessageDelay = nx_value("MessageDelay")
  if not nx_is_valid(MessageDelay) then
    MessageDelay = nx_create("MessageDelay")
  end
  local now = MessageDelay:GetServerDateTime()
  local ini = get_ini(INI_NEW_TERMS_REGISTRATION, true)
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex("1")
  if 0 <= sec_index then
    local post_list = ini:ReadString(sec_index, "PostRewardID", "")
    local list = util_split_string(post_list, ",")
    for i = 1, table.getn(list) do
      if nx_int(list[i]) > nx_int(0) and nx_int(i) == nx_int(sign_count + 1) and nx_int(now) ~= nx_int(last_sign_time) then
        return true
      end
    end
  end
  local get_list = {}
  if client_player:FindRecord("NewTermsSignRec") then
    local rows = client_player:GetRecordRows("NewTermsSignRec")
    if nx_int(rows) > nx_int(0) then
      for i = 0, rows - 1 do
        local num = client_player:QueryRecord("NewTermsSignRec", i, 0)
        if nx_int(num) > nx_int(0) then
          for j = 0, 31 do
            local flag = nx_function("ext_get_bit_value", nx_int(num), nx_int(j + 1))
            if nx_int(flag) ~= nx_int(0) then
              table.insert(get_list, 32 * i + j)
            end
          end
        end
      end
    end
  end
  sec_index = ini:FindSectionIndex("2")
  if 0 <= sec_index then
    local post_list = ini:ReadString(sec_index, "PostRewardID", "")
    local list = util_split_string(post_list, ",")
    for i = 1, table.getn(list) do
      if nx_int(list[i]) > nx_int(0) and nx_int(i) <= nx_int(sign_count) and nx_int(now) >= nx_int(last_sign_time) then
        local bfind = false
        for j = 1, table.getn(get_list) do
          if nx_int(list[i]) == nx_int(get_list[j]) then
            bfind = true
          end
        end
        if not nx_boolean(bfind) then
          return true
        end
      end
    end
  end
  return false
end
