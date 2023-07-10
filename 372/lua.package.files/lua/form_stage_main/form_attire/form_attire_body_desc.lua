require("util_static_data")
require("util_functions")
require("util_gui")
local FORM_PATH = "form_stage_main\\form_attire\\form_attire_body_desc"
local sex_male = 0
local sex_female = 1
function main_form_init(self)
  self.Fixed = false
  self.sex_index = 1
  self.body_index = 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_attire_body_desc_form(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function init_attire_body_desc_form(form)
  form.wuxue_grid_list.ColCount = 1
  form.wuxue_grid_list.RowHeaderVisible = false
  form.rbtn_1.TabIndex = 1
  form.rbtn_2.TabIndex = 1
  form.rbtn_7.TabIndex = 1
  form.rbtn_8.TabIndex = 2
  form.rbtn_9.TabIndex = 3
  form.sex_index = form.rbtn_1.TabIndex
  form.body_index = form.rbtn_7.TabIndex
  form.rbtn_1.Checked = true
  form.rbtn_7.Checked = true
  local sex = get_player_prop("Sex")
  if nx_int(sex_female) == nx_int(sex) then
    form.rbtn_1.NormalImage = "gui\\special\\sizebody\\ll_out.png"
    form.rbtn_1.FocusImage = "gui\\special\\sizebody\\ll_on.png"
    form.rbtn_1.CheckedImage = "gui\\special\\sizebody\\ll_down.png"
    form.rbtn_2.NormalImage = "gui\\special\\sizebody\\yj_out.png"
    form.rbtn_2.FocusImage = "gui\\special\\sizebody\\yj_on.png"
    form.rbtn_2.CheckedImage = "gui\\special\\sizebody\\yj_down.png"
  elseif nx_int(sex_male) == nx_int(sex) then
    form.rbtn_1.NormalImage = "gui\\special\\sizebody\\zt_out.png"
    form.rbtn_1.FocusImage = "gui\\special\\sizebody\\zt_on.png"
    form.rbtn_1.CheckedImage = "gui\\special\\sizebody\\zt_down.png"
    form.rbtn_2.NormalImage = "gui\\special\\sizebody\\zh_out.png"
    form.rbtn_2.FocusImage = "gui\\special\\sizebody\\zh_on.png"
    form.rbtn_2.CheckedImage = "gui\\special\\sizebody\\zh_down.png"
    form.rbtn_2.PushImage = "gui\\special\\sizebody\\zh_down.png"
  end
end
function show_wuxue_taolu(form, sex_index, body_index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  form.mltbox_desc.HtmlText = ""
  form.wuxue_grid_list:ClearRow()
  form.wuxue_grid_list:ClearSelect()
  local body_select = nx_string(sex_index) .. "_" .. nx_string(body_index)
  local wuxue_table = attire_manager:GetBodyWuXueTaoLuData(body_select)
  local wuxue_count = table.getn(wuxue_table)
  if wuxue_count <= 0 then
    return
  end
  for i = 1, wuxue_count do
    local row = form.wuxue_grid_list:InsertRow(-1)
    local text = util_text(wuxue_table[i] .. "_name")
    form.wuxue_grid_list:SetGridText(row, 0, nx_widestr(text))
    if 0 > form.wuxue_grid_list.RowSelectIndex then
      form.wuxue_grid_list:SelectRow(row)
      on_grid_wuxue_select_grid(form.wuxue_grid_list, row, 0)
    end
  end
end
function on_textgrid_list_click(lbl)
  if not nx_value(FORM_PATH) then
    return
  end
  form = nx_value(FORM_PATH)
  local text_desc = util_text(lbl.wuxue_taolu .. "_desc")
  form.mltbox_desc.HtmlText = nx_widestr(text_desc)
end
function on_rbtn_body_sex_select_checked_changed(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.TabIndex <= 0 then
    return
  end
  form.sex_index = rbtn.TabIndex
  show_wuxue_taolu(form, form.sex_index, form.body_index)
end
function on_rbtn_body_index_select_checked_changed(rbtn)
  if not nx_is_valid(rbtn) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.TabIndex <= 0 then
    return
  end
  form.body_index = rbtn.TabIndex
  show_wuxue_taolu(form, form.sex_index, form.body_index)
end
function on_grid_wuxue_select_grid(grid, row, col)
  form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local body_select = nx_string(form.sex_index) .. "_" .. nx_string(form.body_index)
  local wuxue_table = attire_manager:GetBodyWuXueTaoLuDesc(body_select, row)
  if table.getn(wuxue_table) <= 0 then
    return
  end
  local text = wuxue_table[1]
  local text_desc = util_text(nx_string(text) .. "_desc")
  form.mltbox_desc.HtmlText = nx_widestr(text_desc)
end
function get_player_prop(prop)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return ""
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return ""
  end
  if not player:FindProp(nx_string(prop)) then
    return ""
  end
  return player:QueryProp(nx_string(prop))
end
function on_rbtn_body_checked_changed_unopened(btn)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return false
  end
  if not nx_is_valid(btn) then
    return
  end
  SystemCenterInfo:ShowSystemCenterInfo(util_text("846000"), 2)
end
