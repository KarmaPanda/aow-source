require("util_functions")
require("util_gui")
require("util_static_data")
require("role_composite")
require("share\\view_define")
require("share\\client_custom_define")
require("form_stage_main\\form_origin\\kapai_define")
local kapai_id, sub_id, sub_max, sub_cur, sub_deadline
local condition_val = {}
local buff_num = 0
local buff_level = {}
function set_sub_kapai_info(mainid, subid, cur, max, deadline)
  kapai_id = mainid
  sub_id = subid
  set_sub_max(max)
  set_sub_cur(cur)
  set_sub_deadline(deadline)
end
function set_sub_cur(cur)
  sub_cur = cur
end
function set_sub_max(max)
  sub_max = max
end
function set_sub_deadline(deadline)
  sub_deadline = deadline
end
function set_condition_val(...)
  condition_val = {}
  for i, val in pairs(arg) do
    table.insert(condition_val, nx_boolean(val))
  end
end
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.actor2 = nil
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:Register(1000, -1, nx_current(), "update_time", form, -1, -1)
  init(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function init(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
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
  local row = client_player:FindRecordRow("Origin_Kapai", 0, kapai_id, 0)
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  local kapai_manager = nx_value("Kapai")
  if not nx_is_valid(kapai_manager) then
    return false
  end
  if not nx_is_valid(form) then
    return false
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return false
  end
  local cur_time = msg_delay:GetServerSecond()
  local tips_txt = ""
  if sub_deadline ~= nil then
    tips_txt = nx_widestr(format_times(sub_deadline - cur_time))
  end
  form.lbl_sub_name.Text = nx_widestr(gui.TextManager:GetText("sub_prestige_" .. nx_string(sub_id)))
  form.mltbox_sub_desc.HtmlText = gui.TextManager:GetText("desc_sub_prestige_" .. nx_string(sub_id))
  if nx_int(sub_max) > nx_int(0) then
    if nx_int(sub_cur) >= nx_int(sub_max) then
      form.mltbox_num_condition.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_prestige_countoff", nx_int(sub_max), nx_int(sub_max)))
      local tips = gui.TextManager:GetFormatText("ui_prestige_nocount")
      tips = tips .. tips_txt
      form.mltbox_num_condition.HintText = nx_widestr(tips)
    else
      form.mltbox_num_condition.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_prestige_counton", nx_int(sub_cur), nx_int(sub_max)))
      local tips_1 = util_text("tips_prestige_countresidue")
      local tips_2 = util_text("tips_prestige_count") .. nx_widestr(nx_int(sub_max - sub_cur))
      form.mltbox_num_condition.HintText = tips_1 .. nx_widestr("<br/>") .. tips_2
    end
  end
  local state = client_player:QueryRecord("Origin_Kapai", row, KAPAI_REC_STATE)
  form.mltbox_state.HtmlText = gui.TextManager:GetText(state_name[state])
  local back_image = kapai_manager:GetSubKapaiBackImage(nx_int(sub_id))
  form.lbl_role_back.BackImage = back_image
  show_role(form)
  change_cloth()
  local flag = true
  for i, val in pairs(condition_val) do
    if val == false then
      flag = false
    end
  end
  if state ~= KAPAI_STATE_OPENING then
    flag = false
  end
  if not nx_is_valid(form) then
    return false
  end
  form.btn_get_prestige.Enabled = flag
  if state == KAPAI_STATE_DONE then
    form.btn_close_kapai.Enabled = false
  else
    form.btn_close_kapai.Enabled = true
  end
  local reward_str = client_player:QueryRecord("Origin_Kapai", row, KAPAI_REC_REWARD_LIST)
  if state == KAPAI_STATE_DONE and reward_str ~= "" then
    form.btn_get_reward.Enabled = true
  else
    form.btn_get_reward.Enabled = false
  end
  form.groupscrollbox_1:DeleteAll()
  form.groupscrollbox_1.IsEditMode = true
  local top = 0
  local condition_list = kapai_manager:GetComConditionList(sub_id)
  for i, condition_id in pairs(condition_list) do
    local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(nx_int(condition_id)))
    local b_ok = nx_boolean(condition_val[i])
    local real_text = color_text(condition_decs, b_ok)
    local tmp_mult = getmultitext(form)
    if nx_is_valid(tmp_mult) then
      tmp_mult.Top = top
      tmp_mult:AddHtmlText(real_text, nx_int(-1))
      tmp_mult.Height = tmp_mult:GetContentHeight()
      form.groupscrollbox_1:Add(tmp_mult)
      top = top + tmp_mult:GetContentHeight()
      local txt_tmp = util_text("tips_condition_" .. nx_string(nx_int(condition_id)))
      local tips = color_text(txt_tmp, b_ok)
      if not string.find(nx_string(tips), "tips_condition_") then
        tmp_mult.HintText = nx_widestr(tips)
      end
    end
  end
  form.groupscrollbox_1:ResetChildrenYPos()
  form.groupscrollbox_1.IsEditMode = false
  update_need_item(form)
  update_reward_list(form)
  update_time(form)
end
function on_btn_close_click(btn)
  local parent = btn.ParentForm
  nx_destroy(parent)
  nx_execute("form_stage_main\\form_origin\\form_kapai", "show_main_form")
end
function on_btn_get_prestige_click(btn)
  nx_execute("custom_sender", "custom_kapai_msg", GET_PRESTIGE, kapai_id, sub_id)
end
function on_btn_get_reward_click(btn)
  nx_execute("custom_sender", "custom_kapai_msg", GET_PRIZE, kapai_id, sub_id)
end
function on_btn_close_kapai_click(btn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  gui.TextManager:Format_SetIDName("ui_prestige_giveup_makesure1")
  local text = gui.TextManager:Format_GetText()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_kapai_msg", CLOSE_KAPAI, kapai_id, sub_id)
  end
end
function on_imagegrid_need_item_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_need_item_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function update_need_item(form)
  form.groupbox_need_item.Visible = false
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local needitem_ini = nx_execute("util_functions", "get_ini", "share\\Karma\\prestige_need_item.ini")
  if not nx_is_valid(needitem_ini) then
    return
  end
  local sec_index = needitem_ini:FindSectionIndex(nx_string(sub_id))
  if sec_index < 0 then
    return
  end
  local item_count = needitem_ini:GetSectionItemCount(sec_index)
  if item_count < 0 then
    return
  end
  form.imagegrid_need_item:Clear()
  for i = 0, item_count do
    local item_value = needitem_ini:GetSectionItemValue(sec_index, i)
    if nx_string(item_value) ~= "" then
      local res_item = util_split_string(item_value, ",")
      local item_id = res_item[1]
      local item_photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
      local item_num = res_item[2]
      form.imagegrid_need_item:AddItem(i, item_photo, nx_widestr(item_id), nx_int(item_num), -1)
      local num = get_item_num_by_configid(item_id)
      if nx_number(num) < nx_number(item_num) then
        form.imagegrid_need_item:ChangeItemImageToBW(i, true)
      else
        form.imagegrid_need_item:ChangeItemImageToBW(i, false)
      end
    end
  end
  form.groupbox_need_item.Visible = true
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
  local item_num = 0
  if nx_is_valid(toolbox_view) then
    local viewobj_list = toolbox_view:GetViewObjList()
    for j, obj in pairs(viewobj_list) do
      local obj_id = obj:QueryProp("ConfigID")
      if nx_string(obj_id) == nx_string(configid) then
        local num = obj:QueryProp("Amount")
        item_num = item_num + num
      end
    end
  end
  return item_num
end
function update_reward_list(form)
  local reward = {
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {}
  }
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_reward:Clear()
  form.imagegrid_reward:Clear()
  local kapai_manager = nx_value("Kapai")
  if not nx_is_valid(kapai_manager) then
    return
  end
  local reward_list = kapai_manager:GetRewardList(kapai_id)
  for i, id in pairs(reward_list) do
    local reward_info = kapai_manager:GetRewardInfo(nx_int(id))
    if reward_info[1] == 7 then
      reward_info[1] = ITEM_REWARD
    end
    if reward_info[1] ~= nil then
      table.insert(reward[reward_info[1]], nx_int(id))
    end
  end
  if table.maxn(reward[TITLE_REWARD]) > 0 then
    local text = nx_widestr(gui.TextManager:GetText("ui_prestige_prize3"))
    form.mltbox_reward:AddHtmlText(text, nx_int(-1))
    for i, id in pairs(reward[TITLE_REWARD]) do
      local reward_info = kapai_manager:GetRewardInfo(nx_int(id))
      local text = gui.TextManager:GetText("role_title_" .. nx_string(reward_info[2]))
      form.mltbox_reward:AddHtmlText(nx_widestr(text), nx_int(-1))
    end
  end
  if 0 < table.maxn(reward[PROP_REWARD]) then
    local text = nx_widestr(gui.TextManager:GetText("ui_prestige_prize4"))
    form.mltbox_reward:AddHtmlText(text, nx_int(-1))
    for i, id in pairs(reward[PROP_REWARD]) do
      local reward_info = kapai_manager:GetRewardInfo(nx_int(id))
      text = nx_widestr(gui.TextManager:GetFormatText("ui_prestige_prize2", reward_info[2], nx_int(reward_info[3])))
      form.mltbox_reward:AddHtmlText(nx_widestr(text), nx_int(-1))
    end
  end
  if 0 < table.maxn(reward[TASK_REWARD]) then
    local text = nx_widestr(gui.TextManager:GetText("ui_prestige_prize6"))
    form.mltbox_reward:AddHtmlText(text, nx_int(-1))
    for i, id in pairs(reward[TASK_REWARD]) do
      local reward_info = kapai_manager:GetRewardInfo(nx_int(id))
      text = gui.TextManager:GetText("title_" .. nx_string(reward_info[2]))
      form.mltbox_reward:AddHtmlText(nx_widestr(text), nx_int(-1))
    end
  end
  if 0 < table.maxn(reward[RIGHT_REWARD]) then
    local text = nx_widestr(gui.TextManager:GetText("ui_prestige_prize7"))
    form.mltbox_reward:AddHtmlText(text, nx_int(-1))
    for i, id in pairs(reward[RIGHT_REWARD]) do
      local reward_info = kapai_manager:GetRewardInfo(nx_int(id))
      text = gui.TextManager:GetText(nx_string(reward_info[2]))
      form.mltbox_reward:AddHtmlText(nx_widestr(text), nx_int(-1))
    end
  end
  form.mltbox_reward.Height = form.mltbox_reward:GetContentHeight()
  local h = form.mltbox_reward.Top + form.mltbox_reward.Height
  if 0 < table.maxn(reward[PET_REWARD]) then
    form.groupbox_pet.Visible = true
    form.groupbox_pet.Top = h
    h = h + form.groupbox_pet.Height
    local pet_id = reward[PET_REWARD][1]
    local reward_info = kapai_manager:GetRewardInfo(nx_int(pet_id))
    local photo = item_query:GetItemPropByConfigID(reward_info[2], nx_string("Photo"))
    form.imagegrid_pet:AddItem(0, photo, nx_widestr(reward_info[2]), 1, 0)
  else
    form.groupbox_pet.Visible = false
  end
  if 0 < table.maxn(reward[BUFF_REWARD]) + table.maxn(reward[ITEM_REWARD]) + table.maxn(reward[PET_REWARD]) then
    form.groupbox_item.Visible = true
    form.groupbox_item.Top = h
  else
    form.groupbox_item.Visible = false
  end
  if 0 < table.maxn(reward[BUFF_REWARD]) then
    for i, buff_id in pairs(reward[BUFF_REWARD]) do
      local reward_info = kapai_manager:GetRewardInfo(nx_int(buff_id))
      local photo = nx_execute("util_static_data", "buff_static_query", nx_string(reward_info[2]), nx_string("Photo"))
      form.imagegrid_reward:AddItem(i - 1, photo, nx_widestr(reward_info[2]), 1, 0)
      buff_level[i - 1] = nx_int(reward_info[3])
    end
  end
  buff_num = table.maxn(reward[BUFF_REWARD])
  if table.maxn(reward[ITEM_REWARD]) > 0 then
    for i, item_id in pairs(reward[ITEM_REWARD]) do
      local reward_info = kapai_manager:GetRewardInfo(nx_int(item_id))
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(reward_info[2]), nx_string("Photo"))
      form.imagegrid_reward:AddItem(buff_num + i - 1, photo, nx_widestr(reward_info[2]), nx_int(reward_info[3]), 0)
    end
  end
end
function update_time(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if is_form_loading() then
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
  local row = client_player:GetRecordRows("Origin_Kapai")
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_time = msg_delay:GetServerSecond()
  local tips_txt = ""
  if sub_deadline ~= nil then
    tips_txt = nx_widestr(format_times(sub_deadline - cur_time))
  end
  if nx_int(sub_max) > nx_int(0) then
    if nx_int(sub_cur) >= nx_int(sub_max) then
      form.mltbox_num_condition.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_prestige_countoff", nx_int(sub_max), nx_int(sub_max)))
      local tips = gui.TextManager:GetFormatText("ui_prestige_nocount")
      tips = tips .. tips_txt
      form.mltbox_num_condition.HintText = nx_widestr(tips)
    else
      form.mltbox_num_condition.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_prestige_counton", nx_int(sub_cur), nx_int(sub_max)))
      local tips_1 = util_text("tips_prestige_countresidue")
      local tips_2 = util_text("tips_prestige_count") .. nx_widestr(nx_int(sub_max - sub_cur))
      form.mltbox_num_condition.HintText = nx_widestr(tips_1) .. nx_widestr("<br/>") .. nx_widestr(tips_2)
    end
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local row = client_player:FindRecordRow("Origin_Kapai", 0, kapai_id, 0)
  local state = client_player:QueryRecord("Origin_Kapai", row, KAPAI_REC_STATE)
  if state == KAPAI_STATE_DONE then
    local deadline = client_player:QueryRecord("Origin_Kapai", row, KAPAI_REC_DEADLINE)
    local cur_date_time = msg_delay:GetServerDateTime()
    if nx_double(cur_date_time) < nx_double(deadline) then
      form.lbl_time.Text = nx_widestr(format_time(nx_double(deadline) - nx_double(cur_date_time)))
    elseif nx_double(deadline) < nx_double(1) then
      form.lbl_time.Text = ""
      form.btn_close_kapai.Enabled = false
    else
      local timer = nx_value("timer_game")
      if not nx_is_valid(timer) then
        return
      end
      timer:UnRegister(nx_current(), "update_time", form)
      on_btn_close_click(form.btn_close)
    end
  elseif state == KAPAI_STATE_OPENING then
    return
  else
    local timer = nx_value("timer_game")
    if not nx_is_valid(timer) then
      return
    end
    timer:UnRegister(nx_current(), "update_time", form)
    on_btn_close_click(form.btn_close)
  end
end
function color_text(src, b_ok)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local dest = ""
  if b_ok then
    dest = nx_widestr("<font color=\"#006600\">") .. nx_widestr(src) .. nx_widestr("</font>")
  else
    dest = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(src) .. nx_widestr("</font>")
  end
  local ret = nx_widestr(dest)
  return ret
end
function reward_text(type, name, desc, count)
  if type == TITLE_REWARD then
  elseif type == PROP_REWARD then
  elseif type == ITEM_REWARD then
  elseif type == BUFF_REWARD then
  elseif type == TASK_REWARD then
  end
end
function on_imagegrid_reward_mousein_grid(grid, index)
  if index < buff_num then
    show_buff_tips(grid, index)
  else
    show_prize_tips(grid, index)
  end
end
function on_imagegrid_reward_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_pet_mousein_grid(grid, index)
  show_pet_tips(grid, index)
end
function on_imagegrid_pet_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_buff_tips(grid, index)
  local buff_id = nx_string(grid:GetItemName(index))
  if buff_id == "" or buff_id == nil or buff_visible == 0 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("desc_" .. nx_string(buff_id) .. "_" .. nx_string(buff_level[index])), grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
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
  table_prop_value.Amount = nx_int(item_count)
  table_prop_value.LeftTime = nx_int(table_prop_value.ValidTime) * 24 * 60 * 60
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
function show_pet_tips(grid, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local Pet = nx_value("Pet")
  if not nx_is_valid(Pet) then
    return
  end
  local pet_id = nx_string(grid:GetItemName(nx_int(index)))
  if pet_id == "" or pet_id == nil then
    return
  end
  local tem1 = gui.TextManager:GetFormatText(nx_string(pet_id))
  local tem2 = gui.TextManager:GetFormatText("ui_huwei_tipstitle_type")
  local pet_name = nx_widestr(tem1) .. nx_widestr("<br>") .. nx_widestr(tem2)
  local tips = nx_widestr(pet_name) .. nx_widestr("<br>")
  local prop_list = Pet:GetPropByPetId(pet_id)
  if prop_list == nil then
    return
  end
  tem1 = gui.TextManager:GetFormatText("ui_huwei_tipstitle_powerlevel")
  tem2 = gui.TextManager:GetFormatText(nx_string(prop_list[1]))
  local pet_power = nx_widestr(tem1) .. nx_widestr(":") .. nx_widestr(tem2)
  tips = tips .. nx_widestr(pet_power) .. nx_widestr("<br>")
  local SkillRec = item_query:GetItemPropByConfigID(pet_id, "table@SkillRec")
  local skill_list = util_split_string(SkillRec, ";")
  skill_list[1] = string.gsub(skill_list[1], "\"", "")
  tem1 = gui.TextManager:GetFormatText("ui_huwei_tipstitle_skillnum")
  tem2 = table.getn(skill_list)
  if nx_string("\"") == skill_list[tem2] then
    tem2 = tem2 - 1
  end
  local skill_num = nx_widestr(tem1) .. nx_widestr(":") .. nx_widestr(tem2)
  tips = tips .. nx_widestr(skill_num) .. nx_widestr("<br>")
  local child_id = Pet:GetChildIdByPetId(pet_id)
  tem1 = gui.TextManager:GetText("ui_huwei_tipstitle_prestige")
  tem2 = gui.TextManager:GetText("sub_prestige_" .. nx_string(child_id))
  local jianghu_point = nx_widestr(tem1) .. nx_widestr(":") .. nx_widestr(tem2)
  tips = tips .. nx_widestr(jianghu_point) .. nx_widestr("<br>")
  tem1 = gui.TextManager:GetText("ui_huwei_tiptitles_notice")
  tem2 = gui.TextManager:GetText("ui_huwei_tips_notice")
  local notice = nx_widestr(tem1) .. nx_widestr(":") .. nx_widestr(tem2)
  tips = tips .. nx_widestr(notice) .. nx_widestr("<br>")
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  nx_execute("tips_game", "show_text_tip", tips, x, y)
end
function on_mltbox_num_condition_get_capture(mltbox)
  if nx_int(sub_max) <= nx_int(0) or nx_int(sub_cur) < nx_int(sub_max) then
    return
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local now = msg_delay:GetServerSecond()
  local time = sub_deadline - now
  local time_str = nx_widestr("")
  if time <= 0 then
    return
  elseif time < 86400 then
    local hour = math.floor(time / 3600)
    local min = math.floor(time / 60) - hour * 60
    time_str = string.format("%02d:%02d", hour, min)
    if time_str == "00:00" then
      time_str = "00:01"
    end
  else
    time_str = nx_widestr(math.floor(time / 86400)) .. nx_widestr(gui.TextManager:GetText("ui_prestige_time_day"))
  end
  local mouse_x, mouse_z = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(gui.TextManager:GetText("ui_prestige_nocount")) .. nx_widestr(time_str), mouse_x, mouse_z)
end
function on_mltbox_num_condition_lost_capture(mltbox)
  nx_execute("tips_game", "hide_tip")
end
function change_cloth()
  local kapai_manager = nx_value("Kapai")
  if not nx_is_valid(kapai_manager) then
    return
  end
  local fashion_id = kapai_manager:GetSubKapaiFashion(sub_id)
  if fashion_id == "" then
    return
  end
  nx_pause(0.1)
  local form = nx_value("form_stage_main\\form_origin\\form_sub_kapai")
  if not nx_is_valid(form) then
    return
  end
  local config = {
    ArtPack = "Cloth",
    HatArtPack = "Hat",
    PlantsArtPack = "Pants",
    ShoesArtPack = "Shoes"
  }
  local actor2 = form.actor2
  if nx_is_valid(actor2) then
    local sex_model
    if actor2.sex == 0 then
      sex_model = "MaleModel"
    elseif actor2.sex == 1 then
      sex_model = "FemaleModel"
    end
    for id, prop in pairs(config) do
      local art_id = item_query_ArtPack_by_id(fashion_id, id)
      local art_prop = item_static_query(nx_int(art_id), sex_model, STATIC_DATA_ITEM_ART)
      unlink_skin(actor2, prop)
      if art_prop ~= nil and art_prop ~= "" then
        link_skin(actor2, prop, art_prop .. ".xmod")
      end
    end
  end
end
function show_role(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return
  end
  local main_scene = world.MainScene
  if not nx_is_valid(form.scenebox_role.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_role)
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local actor2 = form.actor2
  if nx_is_valid(actor2) then
    form.scenebox_role.Scene:Delete(actor2)
  end
  local actor2 = create_scene_obj_composite(form.scenebox_role.Scene, client_player, false)
  if not nx_is_valid(actor2) then
    return
  end
  form.actor2 = actor2
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_role, actor2)
  actor2:SetScale(nx_float(1.1), nx_float(1.1), nx_float(1.1))
  return
end
function is_form_loading()
  local form = nx_value("form_stage_main\\form_origin\\form_kapai")
  if not nx_is_valid(form) then
    return false
  end
  if not form.form_loading_syn then
    return false
  end
  return true
end
function getmultitext(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local tmp_mlb = form.mltbox_condition
  local mltbox = gui:Create("MultiTextBox")
  if not nx_is_valid(tmp_mlb) or not nx_is_valid(mltbox) then
    return
  end
  mltbox.Font = tmp_mlb.Font
  mltbox.Left = tmp_mlb.Left
  mltbox.Height = tmp_mlb.Height
  mltbox.Width = tmp_mlb.Width
  mltbox.ViewRect = tmp_mlb.ViewRect
  mltbox.Transparent = tmp_mlb.Transparent
  mltbox.HAlign = tmp_mlb.HAlign
  mltbox.VAlign = tmp_mlb.VAlign
  mltbox.LineTextAlign = tmp_mlb.LineTextAlign
  mltbox.NoFrame = tmp_mlb.NoFrame
  mltbox.MouseInBarColor = tmp_mlb.MouseInBarColor
  mltbox.SelectBarColor = tmp_mlb.SelectBarColor
  mltbox.ViewRect = "0,0," .. nx_string(mltbox.Width) .. ",0"
  mltbox.AutoSize = tmp_mlb.AutoSize
  return mltbox
end
function format_times(time)
  local gui = nx_value("gui")
  local time_str = ""
  if nx_number(time) <= nx_number(0) then
    time_str = ""
  elseif nx_number(time) < nx_number(86400) then
    local hour = math.floor(nx_number(time) / nx_number(3600))
    local min = math.floor(nx_number(time) / nx_number(60)) - nx_number(hour) * nx_number(60)
    time_str = string.format("%02d:%02d", hour, min)
    if nx_string(time_str) == nx_string("00:00") then
      time_str = "00:01"
    end
  else
    time_str = nx_widestr(math.ceil(nx_number(time) / nx_number(86400))) .. nx_widestr(gui.TextManager:GetText("ui_prestige_time_day"))
  end
  return time_str
end
