require("form_stage_main\\form_origin\\form_origin_define")
function main_form_init(form)
  form.Fixed = true
  form.pageno = 1
  form.page_next_ok = 1
end
function on_main_form_open(form)
  title_list = {}
  sort_title()
  refresh_total_view(form, 1, TOTAL_VIEW_PAGE_COUNT)
  data_bind_prop(form)
end
function on_main_form_close(form)
  del_data_bind_prop(form)
  nx_destroy(form)
end
function reset_total_view(form)
  form.groupbox_1.Visible = false
  form.groupbox_2.Visible = false
  form.groupbox_3.Visible = false
  form.groupbox_4.Visible = false
  form.groupbox_5.Visible = false
  form.groupbox_6.Visible = false
  form.groupbox_7.Visible = false
  form.groupbox_8.Visible = false
  form.groupbox_9.Visible = false
end
function data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("title_rec", form, nx_current(), "update_all")
  end
end
function del_data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("title_rec", form)
  end
end
function on_btn_click(btn)
  nx_execute(FORM_ORIGIN_LINE, "on_btn_click", btn)
end
function on_btn_pre_click(btn)
  local form = btn.ParentForm
  if form.pageno > 1 then
    get_origin_list(form, form.pageno - 1)
    form.page_next_ok = 1
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  get_origin_list(form, form.pageno + 1)
end
function get_origin_list(form, pageno)
  local from = (nx_int(pageno) - 1) * 9
  local to = pageno * 9
  refresh_total_view(form, from + 1, to)
end
function refresh_total_view(form, from, to)
  reset_total_view(form)
  if to >= table.getn(title_list) then
    form.page_next_ok = 0
  end
  form.pageno = math.ceil(from / TOTAL_VIEW_PAGE_COUNT)
  if form.pageno == 1 then
    form.btn_pre.Enabled = false
  else
    form.btn_pre.Enabled = true
  end
  if form.pageno == math.ceil(table.getn(title_list) / TOTAL_VIEW_PAGE_COUNT) then
    form.btn_next.Enabled = false
  else
    form.btn_next.Enabled = true
  end
  local nowpage = nx_string(form.pageno)
  local maxpage = "/" .. nx_string(math.ceil(table.getn(title_list) / TOTAL_VIEW_PAGE_COUNT))
  form.lbl_pageno.Text = nx_widestr(nowpage .. maxpage)
  if table.getn(title_list) == 0 then
    form.lbl_pageno.Text = nx_widestr("1/1")
    form.btn_next.Enabled = false
    form.btn_pre.Enabled = false
  end
  local control_index = 1
  for i = from, to do
    if title_list[i] == nil or title_list[i] < 0 then
      return
    end
    local control_name = "btn_total_view_" .. control_index
    local btn_view = nx_custom(form, control_name)
    if nx_is_valid(btn_view) then
      btn_view.o_id = title_list[i]
      btn_view.Parent.Visible = true
      nx_execute(FORM_ORIGIN_LINE, "set_Image", btn_view, title_list[i], "completed")
      local gui = nx_value("gui")
      text_view = nx_custom(form, "mltbox_total_view_" .. nx_string(control_index))
      text_view.HtmlText = gui.TextManager:GetText("origin_" .. nx_string(title_list[i]) .. "_desc")
      control_index = control_index + 1
    end
  end
end
function sort_title()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord("title_rec") then
    return
  end
  local title_count = player:GetRecordRows("title_rec")
  if title_count == 0 then
    return
  end
  for i = 5, 1, -1 do
    for j = title_count - 1, 0, -1 do
      local title_id = player:QueryRecord("title_rec", j, 0)
      if title_id < MAX_ORIGIN_COUNT then
        local origin_manager = nx_value("OriginManager")
        if not nx_is_valid(origin_manager) then
          return false
        end
        local material = origin_manager:GetOriginMaterial(title_id)
        if material == i then
          local size = table.getn(title_list) + 1
          title_list[size] = title_id
        end
      end
    end
  end
end
function update_all(form)
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  title_list = {}
  sort_title()
  refresh_total_view(form, 1, TOTAL_VIEW_PAGE_COUNT)
end
