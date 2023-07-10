require("utils")
require("util_gui")
require("util_functions")
local form_name = "form_stage_main\\form_mail\\form_mail_sendlist"
local accept_control_name_table = {
  [0] = {},
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {},
  [7] = {}
}
local Send_rec_name = "SendLetterRec"
local maxmail = 5
local mail_selected_backimage = "gui\\special\\mail\\bg_open.png"
local mail_normal_backimage = "gui\\special\\mail\\bg_read.png"
local mail_on_backimage = "gui\\special\\mail\\bg_unread.png"
local mail_trade_selected_backimage = "gui\\special\\mail\\bg_trade_open.png"
local mail_trade_normal_backimage = "gui\\special\\mail\\bg_trade_read.png"
local mail_trade_on_backimage = "gui\\special\\mail\\bg_trade_unread.png"
local mail_read_backimage = "gui\\special\\mail\\accept_mail\\yyd.png"
local mail_noread_backimage = "gui\\special\\mail\\accept_mail\\wyd.png"
local mail_type_system = "gui\\language\\ChineseS\\system_mail.png"
local mail_type_pay = "gui\\language\\ChineseS\\mail_pay.png"
local mail_type_goods = "gui\\special\\mail\\goods.png"
function main_form_init(self)
  self.rownum = 0
  self.cur_page_user = 1
  return 1
end
function main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(Send_rec_name, self, form_name, "on_mail_manager_refresh")
  end
  return 1
end
function main_form_close(self)
  local databinder = nx_value("data_binder")
  if databinder then
    databinder:DelTableBind(Send_rec_name, self)
  end
  nx_destroy(self)
end
function get_on_mouse(self)
end
function lost_on_mouse(self)
end
function on_template_left_up(self)
end
function open_read_form(form, rownum)
end
function select_on_click(self)
  local form = self.ParentForm
  init_select_state(form)
  form.rownum = self.Parent.rownum
end
function on_select_click(cbtn)
  local rownum = cbtn.Parent.rownum
  if rownum == nil or nx_string(rownum) == "" then
    return
  end
  if cbtn.Checked then
    nx_execute("custom_sender", "custom_select_send_letter", rownum, 1)
  else
    nx_execute("custom_sender", "custom_select_send_letter", rownum, 0)
  end
end
function on_select_all_click(cbtn)
  local form = cbtn.ParentForm
  for i = 0, maxmail - 1 do
    local initgroupboxname = accept_control_name_table[i][1]
    local initgroupboxobj = form:Find(nx_string(initgroupboxname))
    if nx_is_valid(initgroupboxobj) then
      local btnname = accept_control_name_table[i][8]
      local btnobj = initgroupboxobj:Find(nx_string(btnname))
      local rownum = btnobj.Parent.rownum
      if nx_is_valid(btnobj) then
        btnobj.Checked = cbtn.Checked
        if cbtn.Checked then
          nx_execute("custom_sender", "custom_select_send_letter", rownum, 1)
        else
          nx_execute("custom_sender", "custom_select_send_letter", rownum, 0)
        end
      end
    end
  end
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  form.cur_page_user = form.cur_page_user - 1
  mail_fresh(form)
  fresh_page(form)
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  form.cur_page_user = form.cur_page_user + 1
  mail_fresh(form)
  fresh_page(form)
end
function fresh_page(form)
  if not nx_is_valid(form) then
    return
  end
  local rownum = get_user_num()
  local cur_page = form.cur_page_user
  if rownum <= 0 then
    form.btn_left.Enabled = false
    form.btn_right.Enabled = false
    form.lbl_page.Text = nx_widestr(1) .. nx_widestr("/") .. nx_widestr(1)
    return
  end
  local max_page = math.ceil(rownum / 5)
  form.btn_left.Enabled = 1 < cur_page
  form.btn_right.Enabled = cur_page < max_page
  form.lbl_page.Text = nx_widestr(cur_page) .. nx_widestr("/") .. nx_widestr(max_page)
  fresh_select_all_state(form)
end
function fresh_select_all_state(form)
  if not nx_is_valid(form) then
    return
  end
  form.select_all.Checked = get_select_all_state(form)
end
function get_select_all_state(form)
  if not nx_is_valid(form) then
    return false
  end
  for i = 0, maxmail - 1 do
    local initgroupboxname = accept_control_name_table[i][1]
    local initgroupboxobj = form:Find(nx_string(initgroupboxname))
    if nx_is_valid(initgroupboxobj) then
      local btnname = accept_control_name_table[i][8]
      local btnobj = initgroupboxobj:Find(nx_string(btnname))
      if nx_is_valid(btnobj) and btnobj.Visible == true and btnobj.Parent.rownum ~= "" and not btnobj.Checked then
        return false
      end
    end
  end
  return true
end
function init_select_state(form)
  if not nx_is_valid(form) then
    return
  end
  for row0 = 0, maxmail - 1 do
    local initgroupboxname = accept_control_name_table[row0][1]
    local initgroupboxobj = form:Find(nx_string(initgroupboxname))
    if nx_is_valid(initgroupboxobj) then
      if get_mail_type(initgroupboxobj.rownum) == 0 then
        initgroupboxobj.BackImage = mail_trade_normal_backimage
      else
        initgroupboxobj.BackImage = mail_normal_backimage
      end
    end
  end
end
function get_mail_type(row)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if nx_number(row) >= client_player:GetRecordRows(Send_rec_name) then
    return
  end
  local mailtype = client_player:QueryRecord(Send_rec_name, row, 5)
  return mailtype
end
function init_accept_control_name()
  local num = table.getn(accept_control_name_table)
  for i = 0, maxmail - 1 do
    accept_control_name_table[i][1] = nx_string("GroupBox") .. nx_string(i)
    accept_control_name_table[i][2] = nx_string("sendname") .. nx_string(i)
    accept_control_name_table[i][3] = nx_string("content") .. nx_string(i)
    accept_control_name_table[i][4] = nx_string("mltbox_") .. nx_string(i)
    accept_control_name_table[i][5] = nx_string("picture") .. nx_string(i)
    accept_control_name_table[i][6] = nx_string("template") .. nx_string(i)
    accept_control_name_table[i][7] = nx_string("image") .. nx_string(i)
    accept_control_name_table[i][8] = nx_string("select") .. nx_string(i)
    accept_control_name_table[i][9] = nx_string("timelimite") .. nx_string(i)
  end
end
function init_accept_control_info(form)
  if not nx_is_valid(form) then
    return
  end
  for row = 0, maxmail - 1 do
    local initgroupboxname = accept_control_name_table[row][1]
    local initgroupboxobj = form:Find(nx_string(initgroupboxname))
    if nx_is_valid(initgroupboxobj) then
      initgroupboxobj.BackImage = mail_normal_backimage
      initgroupboxobj.rownum = 0
      initgroupboxobj.Visible = false
    end
  end
end
function mail_fresh(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
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
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return
  end
  init_accept_control_name()
  init_accept_control_info(self)
  local showrownum = get_user_num()
  self.mltbox_capacity:Clear()
  if nx_int(showrownum) >= nx_int(50) then
    self.mltbox_capacity:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_mail_full")), nx_int(-1))
  else
    self.mltbox_capacity:AddHtmlText(nx_widestr(nx_string(showrownum) .. "/50"), nx_int(-1))
  end
  if showrownum == 0 then
    return
  end
  cur_page = self.cur_page_user
  local max_page = math.ceil(showrownum / 5)
  if cur_page < 1 then
    cur_page = 1
  end
  if max_page < cur_page then
    cur_page = max_page
  end
  local index = 0
  local start_index = showrownum - 1 - (cur_page - 1) * maxmail
  local end_index = start_index - maxmail + 1
  end_index = 0 <= end_index and end_index or 0
  local cur_index = showrownum
  for row = showrownum - 1, 0, -1 do
    local is_show = false
    cur_index = cur_index - 1
    if end_index <= cur_index and start_index >= cur_index then
      is_show = true
    end
    if is_show then
      local groupboxname = accept_control_name_table[index][1]
      local groupboxobj = self:Find(nx_string(groupboxname))
      if nx_is_valid(groupboxobj) and 0 <= row then
        groupboxobj.Visible = true
        local sendername = client_player:QueryRecord(Send_rec_name, row, 0)
        local silver = client_player:QueryRecord(Send_rec_name, row, 3)
        local str_goods = client_player:QueryRecord(Send_rec_name, row, 1)
        local real_sender = nx_widestr(sendername)
        local sendtime = client_player:QueryRecord(Send_rec_name, row, 2)
        local sender = groupboxobj:Find(nx_string(accept_control_name_table[index][2]))
        local nNum = nx_string(client_player:QueryRecord(Send_rec_name, row, 6))
        groupboxobj.rownum = nx_string(row)
        groupboxobj.BackImage = mail_trade_normal_backimage
        local mltbox = groupboxobj:Find(nx_string(accept_control_name_table[index][4]))
        local lbl_image = groupboxobj:Find(nx_string(accept_control_name_table[index][7]))
        local ntype = client_player:QueryRecord(Send_rec_name, row, 5)
        if nx_int(ntype) == nx_int(5) then
          gui.TextManager:Format_SetIDName("ui_mail_annal_chushou")
        else
          gui.TextManager:Format_SetIDName("ui_mail_annal_zengsong")
        end
        if gui.TextManager:IsIDName(nx_string(str_goods)) then
          str_goods = gui.TextManager:GetText(str_goods)
        else
          local tips_manager = nx_value("tips_manager")
          if nx_is_valid(tips_manager) then
            str_goods = tips_manager:GetItemBaseNameByValue(nx_int(str_goods))
          end
        end
        if 0 < nx_number(nNum) then
          str_goods = nx_widestr(str_goods) .. nx_widestr("X") .. nx_widestr(nNum)
        else
          str_goods = nx_widestr("")
        end
        gui.TextManager:Format_AddParam(str_goods)
        gui.TextManager:Format_AddParam(nx_widestr(sendername))
        gui.TextManager:Format_AddParam(nx_int(silver))
        gui.TextManager:Format_AddParam(nx_string(sendtime))
        mltbox:Clear()
        mltbox:AddHtmlText(nx_widestr(gui.TextManager:Format_GetText()), -1)
        if nx_is_valid(lbl_image) then
          lbl_image.Visible = false
          lbl_image.Left = title.Left + title.TextWidth
          lbl_image.Top = 8
        end
        local is_select = client_player:QueryRecord(Send_rec_name, row, 4)
        local cbtn_select = groupboxobj:Find(nx_string(accept_control_name_table[index][8]))
        if nx_is_valid(cbtn_select) then
          if is_select == 1 then
            cbtn_select.Checked = true
          else
            cbtn_select.Checked = false
          end
        end
        groupboxobj.BackImage = mail_normal_backimage
        index = index + 1
      end
    end
  end
end
function on_mail_manager_refresh(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return
  end
  local rownum = 0
  rownum = get_user_num()
  if rownum == 0 then
    form.rownum = ""
    form.cur_page_user = 1
  end
  mail_fresh(form)
  fresh_page(form)
  fresh_select_all_state(form)
end
function on_delbutton_click(self)
  local form = self.ParentForm
  nx_execute("custom_sender", "custom_del_send_letter")
end
function on_system_get_capture(self)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_SysMail")
  nx_execute("tips_game", "show_text_tip", text, self.AbsLeft + 5, self.AbsTop + 5, 0, self.ParentForm)
end
function on_system_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function get_user_num()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord(Send_rec_name) then
    return 0
  end
  local rownum = client_player:GetRecordRows(Send_rec_name)
  return rownum
end
