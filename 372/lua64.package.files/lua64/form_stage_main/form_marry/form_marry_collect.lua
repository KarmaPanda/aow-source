require("form_stage_main\\form_marry\\form_marry_util")
require("define\\sysinfo_define")
local school_image_list = {
  school_null = "gui\\special\\school_head\\wmp.png",
  school_emei = "gui\\special\\school_head\\em.png",
  school_jinyiwei = "gui\\special\\school_head\\jh.png",
  school_wudang = "gui\\special\\school_head\\wd.png",
  school_tangmen = "gui\\special\\school_head\\tm.png",
  school_junzitang = "gui\\special\\school_head\\jz.png",
  school_shaolin = "gui\\special\\school_head\\sl.png",
  school_gaibang = "gui\\special\\school_head\\gb.png",
  school_jilegu = "gui\\special\\school_head\\jl.png"
}
function main_form_init(form)
  form.Fixed = true
  form.sex = 0
  form.collecter_list = nx_null()
  form.player_name = nx_widestr("")
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  local form_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
  if nx_is_valid(form_chat) then
    gui.Desktop:ToFront(form_chat)
  end
  form.grid_collecter:SetColTitle(0, util_text("ui_grid_title_name"))
  form.grid_collecter:SetColTitle(1, util_text("ui_grid_title_power"))
  form.grid_collecter:SetColTitle(2, util_text("ui_grid_title_school"))
  form.grid_collecter:SetColTitle(3, util_text("ui_grid_title_guild"))
  form.grid_collecter:SetColAlign(0, "center")
  form.grid_collecter:SetColAlign(1, "center")
  form.grid_collecter:SetColAlign(2, "center")
  form.grid_collecter:SetColAlign(3, "center")
  if not nx_is_valid(form.collecter_list) then
    form.collecter_list = get_global_arraylist("marry_collect_list")
  end
  form.redit_decl.Text = get_default_decl()
  set_form_all_screen(form)
  form.btn_giveup.Visible = false
  return 1
end
function on_main_form_close(form)
  if nx_is_valid(form.collecter_list) then
    nx_destroy(form.collecter_list)
    form.collecter_list = nx_null()
  end
  ui_ClearModel(form.sbox_player)
  nx_destroy(form)
end
function on_btn_colse_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_rbtn_sex_checked_changed(self)
  local form = self.ParentForm
  if self.Checked == false then
    return 0
  end
  form.ipt_page.Text = nx_widestr(1)
  form.sex = nx_number(self.DataSource)
  request_page_data(self.ParentForm)
end
function on_btn_page_dec_click(self)
  local form = self.ParentForm
  if nx_number(form.ipt_page.Text) > nx_number(form.lbl_max_page.Text) then
    form.ipt_page.Text = form.lbl_max_page.Text
  end
  if nx_number(form.ipt_page.Text) <= 1 then
    return 0
  end
  form.ipt_page.Text = nx_widestr(nx_number(form.ipt_page.Text) - 1)
  request_page_data(self.ParentForm)
end
function on_btn_page_add_click(self)
  local form = self.ParentForm
  if nx_number(form.ipt_page.Text) > nx_number(form.lbl_max_page.Text) then
    form.ipt_page.Text = form.lbl_max_page.Text
  end
  if nx_number(form.ipt_page.Text) >= nx_number(form.lbl_max_page.Text) then
    return 0
  end
  form.ipt_page.Text = nx_widestr(nx_number(form.ipt_page.Text) + 1)
  request_page_data(self.ParentForm)
end
function on_btn_page_goto_click(self)
  local form = self.ParentForm
  if nx_number(form.ipt_page.Text) > nx_number(form.lbl_max_page.Text) then
    form.ipt_page.Text = form.lbl_max_page.Text
  end
  if nx_number(form.ipt_page.Text) <= 0 or nx_number(form.ipt_page.Text) > nx_number(form.lbl_max_page.Text) then
    return 0
  end
  request_page_data(form)
end
function on_btn_collect_click(self)
  local form = self.ParentForm
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return 0
  end
  local declaration = form.redit_decl.Text
  if not CheckWords:CheckBadWords(nx_widestr(declaration)) then
    local text = util_text("ui_senseword_error")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, SYSTYPE_SYSTEM)
    end
    return 0
  end
  local res = show_confirm(util_text("ui_marry_rite_info3"))
  if res == "cancel" then
    return 0
  end
  custom_marry(CLIENT_MSG_SUB_MARRY_COLLECT, declaration)
end
function on_btn_chat_click(self)
  local form = self.ParentForm
  if nx_string(form.player_name) == "" then
    return 0
  end
  custom_request_chat(form.player_name)
end
function on_btn_search_click(self)
  local form = self.ParentForm
  local player_name = form.edit_player_name.Text
  if nx_string(player_name) == "" then
    return 0
  end
  request_page_data(form, player_name)
end
function on_grid_collecter_select_row(self, row)
  local form = self.ParentForm
  if not nx_is_valid(form.collecter_list) then
    return 0
  end
  local child = form.collecter_list:GetChild(nx_string(row))
  if not nx_is_valid(child) then
    return 0
  end
  form.mbox_decl.HtmlText = nx_widestr(child.declaration)
  form.player_name = nx_widestr(child.player_name)
  form.btn_chat.Visible = true
  create_role_model_by_role_info(form.sbox_player, child.role_info, 0, 1, -3.5, 0)
end
function on_redit_decl_get_focus(self)
  if self.Text == get_default_decl() then
    self.Text = nx_widestr("")
  end
end
function on_redit_decl_lost_focus(self)
  if self.Text == nx_widestr("") then
    self.Text = get_default_decl()
  end
end
function get_default_decl()
  local sex = get_player_prop("Sex")
  local default_id = "ui_marry_b_text"
  if nx_number(sex) == 1 then
    default_id = "ui_marry_g_text"
  end
  return util_text(default_id)
end
function request_page_data(form, player_name)
  if not nx_is_valid(form) then
    return 0
  end
  local page = nx_int(form.ipt_page.Text)
  if player_name ~= nil and nx_string(player_name) ~= "" then
    custom_marry(CLIENT_MSG_SUB_MARRY_COLLECT_LOOK, form.sex, page, player_name)
  else
    custom_marry(CLIENT_MSG_SUB_MARRY_COLLECT_LOOK, form.sex, page)
  end
end
function show_school_image(grid, row, clum, school)
  if nx_string(school) == nx_string("") then
    school = "school_null"
  end
  local school_image = school_image_list[nx_string(school)]
  local gui = nx_value("gui")
  local lbl = gui:Create("Label")
  lbl.AutoSize = true
  lbl.Transparent = false
  lbl.Top = 0
  lbl.Left = 22
  lbl.Width = 28
  lbl.Height = 28
  lbl.BackImage = school_image
  lbl.HintText = nx_widestr(gui.TextManager:GetFormatText(nx_string(school)))
  local grp = gui:Create("GroupBox")
  grp.LineColor = "0,0,0,0"
  grp.BackColor = "0,0,0,0"
  grp:Add(lbl)
  grid:SetGridControl(row, clum, grp)
end
function show_data(...)
  local form = util_get_form(FORM_MARRY_COLLECT, true)
  if not nx_is_valid(form) then
    return 0
  end
  local count = table.getn(arg)
  if nx_number(count) < 3 then
    return 0
  end
  form.sex = nx_number(arg[1])
  if nx_number(form.sex) == 0 then
    form.rbtn_boy.Enabled = false
    form.rbtn_boy.Checked = true
    form.rbtn_boy.Enabled = true
  else
    form.rbtn_girl.Enabled = false
    form.rbtn_girl.Checked = true
    form.rbtn_girl.Enabled = true
  end
  form.ipt_page.Text = nx_widestr(arg[2])
  form.lbl_max_page.Text = nx_widestr(arg[3])
  form.grid_collecter:ClearSelect()
  form.grid_collecter:ClearRow()
  ui_ClearModel(form.sbox_player)
  form.btn_chat.Visible = false
  form.player_name = nx_widestr("")
  form.mbox_decl.HtmlText = nx_widestr("")
  if not nx_is_valid(form.collecter_list) then
    form.collecter_list = get_global_arraylist("marry_collect_list")
  end
  if not nx_is_valid(form.collecter_list) then
    return 0
  end
  form.collecter_list:ClearChild()
  for i = 1, (table.getn(arg) - 3) / 6 do
    local row = form.grid_collecter:InsertRow(-1)
    local player_name = nx_widestr(arg[(i - 1) * 6 + 4])
    local title = "desc_" .. nx_string(arg[(i - 1) * 6 + 6])
    local school = nx_string(arg[(i - 1) * 6 + 7])
    local school_image = school_image_list[school]
    if school_image == nil then
      school_image = school_image_list.school_null
    end
    local guild = nx_widestr(arg[(i - 1) * 6 + 8])
    if guild == nx_widestr("") then
      guild = util_text("ui_None")
    end
    form.grid_collecter:SetGridText(row, 0, player_name)
    form.grid_collecter:SetGridText(row, 1, util_text(title))
    show_school_image(form.grid_collecter, row, 2, school)
    form.grid_collecter:SetGridText(row, 3, guild)
    local child = form.collecter_list:CreateChild(nx_string(row))
    if nx_is_valid(child) then
      child.player_name = nx_widestr(arg[(i - 1) * 6 + 4])
      child.role_info = nx_widestr(arg[(i - 1) * 6 + 5])
      child.declaration = nx_widestr(arg[(i - 1) * 6 + 9])
    end
  end
  form.grid_collecter:SelectRow(0)
  util_show_form(FORM_MARRY_COLLECT, true)
end
function update_give_up_btn(type)
  local form = util_get_form(FORM_MARRY_COLLECT, false)
  if not nx_is_valid(form) then
    return
  end
  if type == 1 then
    form.btn_giveup.Visible = true
  else
    form.btn_giveup.Visible = false
  end
end
function on_btn_giveup_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, gui.TextManager:GetText("ui_give_collect01"))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    custom_marry(CLIENT_MSG_SUB_MARRY_GIVEUP_COLLECT)
  end
end
