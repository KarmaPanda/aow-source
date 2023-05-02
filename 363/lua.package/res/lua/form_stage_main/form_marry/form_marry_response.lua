require("form_stage_main\\form_marry\\form_marry_util")
local school_image_list = {
  ui_None = "gui\\special\\school_head\\wmp.png",
  school_emei = "gui\\special\\school_head\\em.png",
  school_jinyiwei = "gui\\special\\school_head\\jy.png",
  school_wudang = "gui\\special\\school_head\\wd.png",
  school_tangmen = "gui\\special\\school_head\\tm.png",
  school_junzitang = "gui\\special\\school_head\\jz.png",
  school_shaolin = "gui\\special\\school_head\\sl.png",
  school_gaibang = "gui\\special\\school_head\\gb.png",
  school_jilegu = "gui\\special\\school_head\\jl.png"
}
function main_form_init(form)
  form.Fixed = false
  form.sel_count = 0
  form.player_names = nx_widestr("")
end
function on_main_form_open(form)
  form.grid_requester:SetColTitle(1, util_text("ui_grid_title_name"))
  form.grid_requester:SetColTitle(2, util_text("ui_grid_title_power"))
  form.grid_requester:SetColTitle(3, util_text("ui_grid_title_school"))
  form.grid_requester:SetColTitle(4, util_text("ui_grid_title_guild"))
  form.grid_requester:SetColTitle(5, util_text("ui_grid_title_money"))
  form.grid_requester:SetColAlign(0, "center")
  form.grid_requester:SetColAlign(1, "center")
  form.grid_requester:SetColAlign(2, "center")
  form.grid_requester:SetColAlign(3, "center")
  form.grid_requester:SetColAlign(4, "center")
  form.grid_requester:SetColAlign(5, "center")
  form.btn_agree.Enabled = false
  form.btn_refuse.Enabled = false
  set_form_pos(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_colse_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_agree_click(self)
  local form = self.ParentForm
  if form.player_names == nx_widestr("") then
    return 0
  end
  custom_marry(CLIENT_MSG_SUB_MARRY_REQUEST_AGREE, form.player_names)
end
function on_btn_refuse_click(self)
  local form = self.ParentForm
  if form.player_names == nx_widestr("") then
    return 0
  end
  custom_marry(CLIENT_MSG_SUB_MARRY_REQUEST_REFUSE, form.player_names)
end
function on_cbtn_select_checked_changed(self)
  local form = self.ParentForm
  form.sel_count = get_select_count(form)
  if form.sel_count > 1 then
    form.btn_agree.Enabled = false
    form.btn_refuse.Enabled = true
  elseif form.sel_count == 1 then
    form.btn_agree.Enabled = true
    form.btn_refuse.Enabled = true
  else
    form.btn_agree.Enabled = false
    form.btn_refuse.Enabled = false
  end
end
function get_select_count(form)
  local count = 0
  local name = nx_widestr("")
  for i = 0, form.grid_requester.RowCount do
    local gbox = form.grid_requester:GetGridControl(i, 0)
    if nx_is_valid(gbox) and nx_find_custom(gbox, "cbtn") and nx_is_valid(gbox.cbtn) and gbox.cbtn.Checked == true then
      count = count + 1
      if name ~= nx_widestr("") then
        name = name .. nx_widestr(",")
      end
      name = name .. form.grid_requester:GetGridText(i, 1)
    end
  end
  form.player_names = name
  return count
end
function show_data(...)
  if table.getn(arg) <= 0 then
    local form = util_get_form(FORM_MARRY_RESPONSE, false)
    if nx_is_valid(form) then
      form:Close()
    end
    return 0
  end
  local form = util_get_form(FORM_MARRY_RESPONSE, true)
  if not nx_is_valid(form) then
    return 0
  end
  form.grid_requester:ClearSelect()
  form.grid_requester:ClearRow()
  for i = 1, table.getn(arg) / 5 do
    local row = form.grid_requester:InsertRow(-1)
    local gbox_select = create_ctrl_ex("GroupBox", "gbox_select_" .. nx_string(i), form.gbox_select)
    local cbtn_select = create_ctrl_ex("CheckButton", "cbtn_select_" .. nx_string(i), form.cbtn_select, gbox_select)
    local mbox_money = create_ctrl_ex("MultiTextBox", "mbox_money_" .. nx_string(i), form.mbox_money)
    if not (nx_is_valid(gbox_select) and nx_is_valid(cbtn_select)) or not nx_is_valid(mbox_money) then
      break
    end
    gbox_select.cbtn = cbtn_select
    nx_bind_script(cbtn_select, nx_current())
    nx_callback(cbtn_select, "on_checked_changed", "on_cbtn_select_checked_changed")
    local player_name = nx_widestr(arg[i * 5 - 4])
    local title = "desc_" .. nx_string(arg[i * 5 - 3])
    local school = nx_string(arg[i * 5 - 2])
    if school == "" then
      school = "ui_None"
    end
    local guild = nx_widestr(arg[i * 5 - 1])
    if guild == nx_widestr("") then
      guild = util_text("ui_None")
    end
    mbox_money.HtmlText = get_format_capital_html(2, nx_int64(arg[i * 5]))
    form.grid_requester:SetGridControl(row, 0, gbox_select)
    form.grid_requester:SetGridControl(row, 5, mbox_money)
    show_school_image(form.grid_requester, row, 3, school)
    form.grid_requester:SetGridText(row, 1, player_name)
    form.grid_requester:SetGridText(row, 2, util_text(title))
    form.grid_requester:SetGridText(row, 4, guild)
  end
  util_show_form(FORM_MARRY_RESPONSE, true)
end
function show_school_image(grid, row, col, school)
  if nx_string(school) == nx_string("") then
    school = "school_null"
  end
  local school_image = school_image_list[nx_string(school)]
  local gui = nx_value("gui")
  local lbl = gui:Create("Label")
  lbl.AutoSize = true
  lbl.Transparent = false
  lbl.Top = 0
  lbl.Left = 20
  lbl.BackImage = school_image
  lbl.HintText = nx_widestr(gui.TextManager:GetFormatText(nx_string(school)))
  local grp = gui:Create("GroupBox")
  grp.LineColor = "0,0,0,0"
  grp.BackColor = "0,0,0,0"
  grp:Add(lbl)
  grid:SetGridControl(row, col, grp)
end
