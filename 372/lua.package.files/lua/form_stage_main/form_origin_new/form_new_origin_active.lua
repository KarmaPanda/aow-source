require("util_functions")
require("util_gui")
require("form_stage_main\\form_origin_new\\new_origin_define")
local ACTIVED_ORIGIN_PAGE_MAX_NUM = 3
function refresh_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_ACTIVED, false, false)
  if not nx_is_valid(form) then
    return
  end
  on_update_origin(form)
end
function open_form()
  local form = util_get_form(FORM_NEW_ORIGIN_MAIN, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.Fixed = true
  form.cur_page = 1
  form.max_page = 1
end
function on_main_form_open(form)
  page_btn_init()
  show_actived_origin(form)
  data_bind_prop(form)
end
function on_main_form_close(form)
  del_data_bind_prop(form)
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
  form.Visible = false
  local mainform = nx_value(FORM_NEW_ORIGIN_MAIN)
  if nx_is_valid(mainform) then
    nx_execute(FORM_NEW_ORIGIN_MAIN, "open_subform", mainform, FORM_TYPE_MAIN)
  end
end
function show_actived_origin(form)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  local groupbox_origin = form.groupscrollbox_1
  if not nx_is_valid(groupbox_origin) then
    return
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local new_origin_events_sort = {}
  new_origin_events_sort = origin_manager:OriginCompletedEventsSort()
  local length = table.getn(new_origin_events_sort)
  if length < 0 then
    return
  end
  local page_begin_origin_index = (form.cur_page - 1) * ACTIVED_ORIGIN_PAGE_MAX_NUM + 1
  if length < page_begin_origin_index then
    return
  end
  local page_end_origin_index = form.cur_page * ACTIVED_ORIGIN_PAGE_MAX_NUM
  if length < page_end_origin_index then
    local begin_index = math.fmod(length, ACTIVED_ORIGIN_PAGE_MAX_NUM)
    for jj = begin_index + 1, ACTIVED_ORIGIN_PAGE_MAX_NUM do
      local groupbox_name = "groupbox_" .. nx_string(jj)
      local groupbox_actived = groupbox_origin:Find(groupbox_name)
      if not nx_is_valid(groupbox_actived) then
        return
      end
      groupbox_actived.Visible = false
    end
    page_end_origin_index = length
  end
  local origin_index = page_end_origin_index - page_begin_origin_index + 1
  for index = 1, origin_index do
    local groupbox_name = "groupbox_" .. nx_string(index)
    local lbl_name = "lbl_" .. nx_string(index)
    local mltbox_name = "mltbox_" .. nx_string(index)
    local cbtn_name = "cbtn_" .. nx_string(index)
    local btn_enter_name = "btn_enter_" .. nx_string(index)
    local groupbox_actived = groupbox_origin:Find(groupbox_name)
    if not nx_is_valid(groupbox_actived) then
      return
    end
    local lbl_origin = groupbox_actived:Find(lbl_name)
    if not nx_is_valid(lbl_origin) then
      return
    end
    local mltbox_condition = groupbox_actived:Find(mltbox_name)
    if not nx_is_valid(mltbox_condition) then
      return
    end
    local cbtn_top = groupbox_actived:Find(cbtn_name)
    if not nx_is_valid(cbtn_top) then
      return
    end
    local btn_enter = groupbox_actived:Find(btn_enter_name)
    if not nx_is_valid(btn_enter) then
      return
    end
    groupbox_actived.Visible = true
    lbl_origin.Visible = true
    mltbox_condition.Visible = true
    cbtn_top.Visible = true
    mltbox_condition:Clear()
    cbtn_top.origin_id = 0
    btn_enter.origin_id = 0
    cbtn_top.ClickEvent = true
    local origin_id = new_origin_events_sort[page_begin_origin_index]
    page_begin_origin_index = page_begin_origin_index + 1
    if nil == origin_id then
      return
    end
    cbtn_top.origin_id = origin_id
    btn_enter.origin_id = origin_id
    if origin_manager:IsTopOrigin(origin_id) then
      cbtn_top.Checked = true
    else
      cbtn_top.Checked = false
    end
    lbl_origin.Text = nx_widestr(util_text("origin_" .. nx_string(origin_id)))
    local get_and_condition_table = origin_manager:CompleteAndConditionList(origin_id)
    local get_or_condition_table = origin_manager:CompleteOrConditionList(origin_id)
    local and_condition_desc = gui.TextManager:GetText("ui_and_condition_desc")
    local or_condition_desc = gui.TextManager:GetText("ui_or_condition_desc")
    local get_condition_desc = gui.TextManager:GetText("ui_get_origin_condition")
    local get_and_count = table.getn(get_and_condition_table)
    local get_or_count = table.getn(get_or_condition_table)
    if 0 < get_and_count then
      mlt_index = mltbox_condition:AddHtmlText(and_condition_desc, nx_int(-1))
      mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      for i = 1, get_and_count do
        local condition_id = get_and_condition_table[i]
        local condition_decs = gui.TextManager:GetText(condition_manager:GetConditionDesc(condition_id))
        local b_ok = condition_manager:CanSatisfyCondition(player, player, condition_id)
        local real_text = complete_text(condition_decs, b_ok)
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
        local real_text = complete_text(condition_decs, b_ok)
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
          real_text = complete_text(event_decs, true)
        else
          local event_decs = gui.TextManager:GetFormatText("desc_events_" .. nx_string(event_id), nx_int(cur_event_num), nx_int(event_num))
          real_text = complete_text(event_decs, false)
        end
        local mlt_index = mltbox_condition:AddHtmlText(real_text, nx_int(-1))
        mlt_index = mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
        mltbox_condition:SetHtmlItemSelectable(mlt_index, false)
      end
    end
  end
end
function complete_text(src, b_ok)
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
function data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("Origin_Top_Rec", form, nx_current(), "on_update_origin_rec")
  end
end
function del_data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("Origin_Top_Rec", form)
  end
end
function on_update_origin_rec(form, tablename, ttype, line, col)
  if not form.Visible then
    return
  end
  page_btn_init()
  show_actived_origin(form)
end
function page_btn_init()
  local form = nx_value(FORM_NEW_ORIGIN_ACTIVED)
  if not nx_is_valid(form) then
    return
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local new_origin_events_sort = {}
  new_origin_events_sort = origin_manager:OriginCompletedEventsSort()
  local length = table.getn(new_origin_events_sort)
  if length < 0 then
    return
  end
  form.cur_page = 1
  form.max_page = math.ceil(length / ACTIVED_ORIGIN_PAGE_MAX_NUM)
  local groupbox_origin = form.groupscrollbox_1
  if not nx_is_valid(groupbox_origin) then
    return
  end
  local btn_page_left = form.btn_left
  if not nx_is_valid(btn_page_left) then
    return
  end
  btn_page_left.Visible = true
  btn_page_left.Enabled = false
  local btn_page_right = form.btn_right
  if not nx_is_valid(btn_page_right) then
    return
  end
  btn_page_right.Visible = true
  if form.cur_page >= form.max_page then
    btn_page_right.Enabled = false
    form.cur_page = form.max_page
  else
    btn_page_right.Enabled = true
  end
  local lbl_page = form.lbl_page
  if not nx_is_valid(lbl_page) then
    return
  end
  lbl_page.Visible = true
  lbl_page.Text = nx_widestr(form.cur_page) .. nx_widestr("/") .. nx_widestr(form.max_page)
end
function on_btn_left_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cur_page <= 1 then
    return
  end
  form.cur_page = form.cur_page - 1
  page_btn_atate(form.cur_page)
  show_actived_origin(form)
end
function on_btn_right_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cur_page >= form.max_page then
    return
  end
  form.cur_page = form.cur_page + 1
  page_btn_atate(form.cur_page)
  show_actived_origin(form)
end
function on_btn_enter_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local origin_id = btn.origin_id
  if nx_int(origin_id) <= nx_int(0) then
    return
  end
  form.Visible = false
  local mainform = nx_value(FORM_NEW_ORIGIN_MAIN)
  if nx_is_valid(mainform) then
    mainform.return_form_type = FORM_TYPE_ORIGIN_ACTIVED
    nx_execute(FORM_NEW_ORIGIN_MAIN, "open_subform", mainform, FORM_TYPE_ORIGIN_INFO, btn.origin_id, "")
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function page_btn_atate(page)
  local form = nx_value(FORM_NEW_ORIGIN_ACTIVED)
  if not nx_is_valid(form) then
    return
  end
  local groupbox_origin = form.groupscrollbox_1
  if not nx_is_valid(groupbox_origin) then
    return
  end
  local btn_page = form.btn_left
  if not nx_is_valid(btn_page) then
    return
  end
  btn_page.Visible = true
  if form.cur_page <= 1 then
    btn_page.Enabled = false
  else
    btn_page.Enabled = true
  end
  btn_page = form.btn_right
  if not nx_is_valid(btn_page) then
    return
  end
  btn_page.Visible = true
  if form.cur_page >= form.max_page then
    btn_page.Enabled = false
  else
    btn_page.Enabled = true
  end
  local lbl_page = form.lbl_page
  if not nx_is_valid(lbl_page) then
    return
  end
  lbl_page.Visible = true
  lbl_page.Text = nx_widestr(form.cur_page) .. nx_widestr("/") .. nx_widestr(form.max_page)
end
function on_cbtn_origin_top(cbtn)
  if not nx_is_valid(cbtn) then
    return
  end
  local origin_id = cbtn.origin_id
  if nx_int(origin_id) <= nx_int(0) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local sub_request = SUB_CUSTOMMSG_REQUEST_ORIGIN_TOP
  if not cbtn.Checked then
    sub_request = SUB_CUSTOMMSG_REQUEST_ORIGIN_CANCEL_TOP
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ORIGIN), nx_int(sub_request), origin_id)
end
function on_update_origin(form)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  page_btn_init()
  show_actived_origin(form)
end
