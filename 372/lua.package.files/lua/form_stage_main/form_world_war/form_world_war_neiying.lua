local form_name = "form_stage_main\\form_world_war\\form_world_war_neiying"
require("form_stage_main\\form_world_war\\form_world_war_define")
local SINGLE_PAGE_MAX = 12
function main_form_init(form)
  form.Fixed = false
  form.Current_Page = 1
  form.info_list = nil
  form.wstrPlayerVoted = nil
  form.nVotes = nil
  form.info_list = nx_call("util_gui", "get_arraylist", "worldwar:info_list")
end
function on_main_form_open(form)
  Grid_Refresh(form)
end
function on_main_form_close(form)
  if nx_is_valid(form.info_list) then
    form.info_list:ClearChild()
    nx_destroy(form.info_list)
  end
  nx_destroy(form)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  form:Close()
end
function vote_info(wstrPlayerVoted, nVotes, ...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_world_war\\form_world_war_neiying_tip", true)
  if nx_is_valid(form) then
    form.Visible = true
    form:Show()
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_world_war\\form_world_war_neiying", true, false)
  form:Close()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_world_war\\form_world_war_neiying", true, false)
  form.wstrPlayerVoted = wstrPlayerVoted
  form.nVotes = nVotes
  form.info_list = nx_call("util_gui", "get_arraylist", "worldwar:info_list")
  form.info_list:ClearChild()
  for i = 1, table.getn(arg) do
    local info = form.info_list:CreateChild("")
    info.name = nx_widestr(arg[i])
  end
  if nx_is_valid(form) then
    form.Visible = true
    form:Show()
  end
end
function vote_end(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_world_war\\form_world_war_neiying", true)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_world_war\\form_world_war_neiying_tip", true)
  if nx_is_valid(form) then
    form:Close()
  end
end
function Grid_Refresh(form)
  form.textgrid_1:BeginUpdate()
  form.textgrid_2:BeginUpdate()
  if form.info_list:GetChildCount() > 0 then
    form.ipt_1.MaxDigit = nx_int((form.info_list:GetChildCount() / 3 - 1) / SINGLE_PAGE_MAX) + 1
  else
    form.ipt_1.MaxDigit = 1
  end
  if nx_int(form.ipt_1.Text) < nx_int(1) then
    form.ipt_1.Text = 1
  elseif nx_int(form.ipt_1.Text) > nx_int(form.ipt_1.MaxDigit) then
    form.ipt_1.Text = form.ipt_1.MaxDigit
  end
  local isIncVisible = false
  if nx_number(form.nVotes) > nx_number(0) then
    isIncVisible = true
  end
  form.Current_Page = nx_int(form.ipt_1.Text)
  if 1 > form.Current_Page then
    form.Current_Page = 1
    form.ipt_1.Text = nx_widestr(1)
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    if nx_widestr(form.wstrPlayerVoted) ~= nx_widestr("") then
      form.lbl_playervoted.Text = nx_widestr(gui.TextManager:GetFormatText("ui_lxc_tpname", form.wstrPlayerVoted))
    end
    form.lbl_votes.Text = nx_widestr(gui.TextManager:GetFormatText("ui_lxc_tpnum", nx_int(form.nVotes)))
    form.textgrid_1:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_lxc_name")))
    form.textgrid_1:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_lxc_nydepiao")))
    form.textgrid_1:SetColTitle(4, nx_widestr(gui.TextManager:GetText("ui_lxc_nyxianyi")))
    form.textgrid_1:ClearRow()
    form.groupbox_1:DeleteAll()
    for i = 1, SINGLE_PAGE_MAX do
      if SINGLE_PAGE_MAX * (form.Current_Page - 1) + i <= form.info_list:GetChildCount() / 3 then
        local row = form.textgrid_1:InsertRow(-1)
        form.textgrid_1:SetGridText(row, 0, nx_widestr(form.info_list:GetChildByIndex((form.Current_Page - 1) * SINGLE_PAGE_MAX + (i - 1) * 3 + 0).name))
        form.textgrid_1:SetGridText(row, 2, nx_widestr(form.info_list:GetChildByIndex((form.Current_Page - 1) * SINGLE_PAGE_MAX + (i - 1) * 3 + 1).name))
        form.textgrid_1:SetGridText(row, 4, nx_widestr(form.info_list:GetChildByIndex((form.Current_Page - 1) * SINGLE_PAGE_MAX + (i - 1) * 3 + 2).name))
        local Grid_Btn_Rec = gui:Create("Button")
        form.groupbox_1:Add(Grid_Btn_Rec)
        Grid_Btn_Rec.Name = nx_string(i - 1)
        Grid_Btn_Rec.DrawMode = "FitWindow"
        Grid_Btn_Rec.NormalImage = "gui\\common\\button\\btn_minimum1_out.png"
        Grid_Btn_Rec.FocusImage = "gui\\common\\button\\btn_minimum1_on.png"
        Grid_Btn_Rec.PushImage = "gui\\common\\button\\btn_minimum1_down.png"
        Grid_Btn_Rec.Visible = nx_widestr(form.info_list:GetChildByIndex((i - 1) * 3 + 0).name) == nx_widestr(nx_widestr(form.wstrPlayerVoted))
        nx_bind_script(Grid_Btn_Rec, nx_current())
        nx_callback(Grid_Btn_Rec, "on_click", "on_Grid_Btn_Rec_click")
        form.textgrid_1:ClearGridControl(row, 1)
        form.textgrid_1:SetGridControl(row, 1, Grid_Btn_Rec)
        local Grid_Btn_Add = gui:Create("Button")
        form.groupbox_1:Add(Grid_Btn_Add)
        Grid_Btn_Add.Name = nx_string(i - 1)
        Grid_Btn_Add.DrawMode = "FitWindow"
        Grid_Btn_Add.NormalImage = "gui\\common\\button\\btn_maximum1_out.png"
        Grid_Btn_Add.FocusImage = "gui\\common\\button\\btn_maximum1_on.png"
        Grid_Btn_Add.PushImage = "gui\\common\\button\\btn_maximum1_down.png"
        Grid_Btn_Add.Visible = isIncVisible
        nx_bind_script(Grid_Btn_Add, nx_current())
        nx_callback(Grid_Btn_Add, "on_click", "on_Grid_Btn_Add_click")
        form.textgrid_1:ClearGridControl(row, 3)
        form.textgrid_1:SetGridControl(row, 3, Grid_Btn_Add)
      end
    end
    local client_player = nx_value("game_client")
    local client_player = client_player:GetPlayer()
    local self_name = client_player:QueryProp("Name")
    for i = 1, form.info_list:GetChildCount() / 3 do
      if nx_widestr(form.info_list:GetChildByIndex((i - 1) * 3 + 0).name) == nx_widestr(self_name) then
        form.textgrid_2:ClearRow()
        form.textgrid_2:SetColTitle(0, nx_widestr(form.info_list:GetChildByIndex((i - 1) * 3 + 0).name))
        form.textgrid_2:SetColTitle(2, nx_widestr(form.info_list:GetChildByIndex((i - 1) * 3 + 1).name))
        form.textgrid_2:SetColTitle(4, nx_widestr(form.info_list:GetChildByIndex((i - 1) * 3 + 2).name))
      end
    end
  end
  form.textgrid_1:EndUpdate()
  form.textgrid_2:EndUpdate()
end
function on_Grid_Btn_Rec_click(btn)
  if btn.Visible == false then
    return
  end
  local index = nx_int(btn.Name)
  local form = btn.ParentForm
  local target = form.textgrid_1:GetGridText(nx_int(index), nx_int(0))
  send_world_war_custom_msg(CLINET_WORLDWAR_TRAITOR_VOTE_CANCEL, nx_widestr(target))
end
function on_Grid_Btn_Add_click(btn)
  if btn.Visible == false then
    return
  end
  local index = nx_int(btn.Name)
  local form = btn.ParentForm
  local target = form.textgrid_1:GetGridText(nx_int(index), nx_int(0))
  send_world_war_custom_msg(CLIENT_WORLDWAR_TRAITOR_VOTE, nx_widestr(target))
end
function on_btn_2_click(btn)
  btn.ParentForm.ipt_1.Text = nx_widestr("1")
  Grid_Refresh(btn.ParentForm)
end
function on_btn_3_click(btn)
  if btn.ParentForm.Current_Page > 1 then
    btn.ParentForm.ipt_1.Text = nx_widestr(btn.ParentForm.Current_Page - 1)
  else
    btn.ParentForm.ipt_1.Text = nx_widestr("1")
  end
  Grid_Refresh(btn.ParentForm)
end
function on_btn_4_click(btn)
  if btn.ParentForm.Current_Page < btn.ParentForm.ipt_1.MaxDigit then
    btn.ParentForm.ipt_1.Text = nx_widestr(btn.ParentForm.Current_Page + 1)
  else
    btn.ParentForm.ipt_1.Text = nx_widestr(btn.ParentForm.ipt_1.MaxDigit)
  end
  Grid_Refresh(btn.ParentForm)
end
function on_btn_5_click(btn)
  btn.ParentForm.ipt_1.Text = nx_widestr(btn.ParentForm.ipt_1.MaxDigit)
  Grid_Refresh(btn.ParentForm)
end
function on_btn_6_click(btn)
  Grid_Refresh(btn.ParentForm)
end
function send_world_war_custom_msg(sub_msg, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), nx_int(sub_msg), unpack(arg))
end
