require("utils")
require("util_gui")
require("util_functions")
local form_name = "form_stage_main\\form_mail\\form_mail_accept"
local is_click = false
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
local Recv_rec_name = "RecvLetterRec"
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
local mail_type_player = "gui\\language\\ChineseS\\wanjia_mail.png"
local mail_type_pay = "gui\\language\\ChineseS\\mail_pay.png"
local mail_type_goods = "gui\\special\\mail\\goods.png"
local LETTER_SYSTEM_TYPE_MIN = 100
local LETTER_SYSTEM_POST_USER = 101
local LETTER_SYSTEM_TEACH_NOTIFY = 102
local LETTER_SYSTEM_SINGLE_DIVORCE_NOTIFY = 103
local LETTER_SYSTEM_LOVER_RELATION_FREE = 104
local LETTER_SYSTEM_FRIEND = 105
local LETTER_USER_POST_TASK = 106
local LETTER_USER_OWNER_CROP_RECORD = 108
local LETTER_SYSTEM_TYPE_MAX = 199
local LETTER_USER_TYPE_MIN = 0
local LETTER_USER_POST_USER = 1
local LETTER_USER_POST_BACK_USER_OUT_TIME = 2
local LETTER_USER_POST_BACK_USER_REFUSE = 3
local LETTER_USER_POST_BACK_USER_FULL = 4
local LETTER_USER_POST_TRADE = 5
local LETTER_USER_POST_TRADE_PAY = 6
local LETTER_USER_WHISPER_USER = 10
local LETTER_USER_TYPE_MAX = 99
local POST_TABLE_SENDNAME = 0
local POST_TABLE_SENDUID = 1
local POST_TABLE_TYPE = 2
local POST_TABLE_LETTERNAME = 3
local POST_TABLE_VALUE = 4
local POST_TABLE_GOLD = 5
local POST_TABLE_SILVER = 6
local POST_TABLE_APPEDIXVALUE = 7
local POST_TABLE_DATE = 8
local POST_TABLE_READFLAG = 9
local POST_TABLE_SERIALNO = 10
local POST_TABLE_TRADE_MONEY = 11
local POST_TABLE_SELECT = 12
local POST_TABLE_LEFT_TIME = 13
local POST_TABLE_TRADE_DONE = 14
function main_form_init(self)
  self.serial_no = ""
  self.cur_page_user = 1
  self.cur_page_system = 1
  self.mail_type = 1
  return 1
end
function main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(Recv_rec_name, self, form_name, "on_mail_manager_refresh")
  end
  request_accept_firend_letter_flag(self)
  return 1
end
function main_form_close(self)
  local databinder = nx_value("data_binder")
  if databinder then
    databinder:DelTableBind(Recv_rec_name, self)
  end
  nx_destroy(self)
end
function get_on_mouse(self)
  if get_mail_type(self.Parent.serial_no) == LETTER_USER_POST_TRADE then
    if self.Parent.BackImage == mail_trade_selected_backimage then
      return
    end
    self.Parent.BackImage = mail_trade_on_backimage
  else
    if self.Parent.BackImage == mail_selected_backimage then
      return
    end
    self.Parent.BackImage = mail_on_backimage
  end
end
function lost_on_mouse(self)
  if get_mail_type(self.Parent.serial_no) == LETTER_USER_POST_TRADE then
    if self.Parent.BackImage == mail_trade_selected_backimage then
      return
    end
    self.Parent.BackImage = mail_trade_normal_backimage
  else
    if self.Parent.BackImage == mail_selected_backimage then
      return
    end
    self.Parent.BackImage = mail_normal_backimage
  end
end
function on_template_left_up(self)
  local form = self.ParentForm
  form.serial_no = self.Parent.serial_no
  local serial_no = self.Parent.serial_no
  if serial_no == nil or nx_string(serial_no) == "" then
    return
  end
  open_read_form(form, serial_no)
  nx_execute("custom_sender", "custom_read_letter", serial_no)
end
function open_read_form(form, serial_no)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local form_mail_read = nx_value("form_stage_main\\form_mail\\form_mail_read")
  if nx_is_valid(form_mail_read) then
    form_mail_read:Close()
  end
  form_mail_read = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_mail\\form_mail_read", true, false)
  form_mail_read.serial_no = serial_no
  if form.AbsLeft + form.Width + form_mail_read.Width > gui.Width then
    form_mail_read.AbsLeft = form.AbsLeft - form_mail_read.Width + 3
    form_mail_read.AbsTop = form.AbsTop - 30
  else
    form_mail_read.AbsLeft = form.AbsLeft + form.Width
    form_mail_read.AbsTop = form.AbsTop - 30
  end
  form_mail_read:Show()
end
function select_on_click(self)
  local form = self.ParentForm
  init_select_state(form)
  if get_mail_type(self.Parent.serial_no) == LETTER_USER_POST_TRADE then
    self.Parent.BackImage = mail_trade_selected_backimage
  else
    self.Parent.BackImage = mail_selected_backimage
  end
  form.serial_no = self.Parent.serial_no
end
function on_select_click(cbtn)
  local serial_no = cbtn.Parent.serial_no
  if serial_no == nil or nx_string(serial_no) == "" then
    return
  end
  if cbtn.Checked then
    nx_execute("custom_sender", "custom_select_letter", 1, serial_no, 1)
  else
    nx_execute("custom_sender", "custom_select_letter", 1, serial_no, 0)
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
      local serial_no = btnobj.Parent.serial_no
      if nx_is_valid(btnobj) then
        btnobj.Checked = cbtn.Checked
        if cbtn.Checked then
          nx_execute("custom_sender", "custom_select_letter", 1, serial_no, 1)
        else
          nx_execute("custom_sender", "custom_select_letter", 1, serial_no, 0)
        end
      end
    end
  end
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if form.mail_type == 1 then
    form.cur_page_user = form.cur_page_user - 1
  elseif form.mail_type == 2 then
    form.cur_page_system = form.cur_page_system - 1
  end
  mail_fresh(form)
  fresh_page(form)
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if form.mail_type == 1 then
    form.cur_page_user = form.cur_page_user + 1
  elseif form.mail_type == 2 then
    form.cur_page_system = form.cur_page_system + 1
  end
  mail_fresh(form)
  fresh_page(form)
end
function fresh_page(form)
  if not nx_is_valid(form) then
    return
  end
  local rownum = 0
  local cur_page = form.cur_page_user
  if form.mail_type == 1 then
    rownum = get_user_num()
    cur_page = form.cur_page_user
  elseif form.mail_type == 2 then
    rownum = get_system_num()
    cur_page = form.cur_page_system
  end
  if rownum <= 0 then
    form.btn_left.Enabled = false
    form.btn_right.Enabled = false
    form.lbl_page.Text = nx_widestr(1) .. nx_widestr("/") .. nx_widestr(1)
    return
  end
  local max_page = math.ceil(rownum / 5)
  form.btn_left.Enabled = 1 < cur_page
  form.btn_right.Enabled = cur_page < max_page
  if cur_page > max_page then
    cur_page = max_page
    if form.mail_type == 1 then
      form.cur_page_user = cur_page
    elseif form.mail_type == 2 then
      form.cur_page_system = cur_page
    end
  end
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
      if nx_is_valid(btnobj) and btnobj.Visible == true and btnobj.Parent.serial_no ~= "" and not btnobj.Checked then
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
      if get_mail_type(initgroupboxobj.serial_no) == LETTER_USER_POST_TRADE then
        initgroupboxobj.BackImage = mail_trade_normal_backimage
      else
        initgroupboxobj.BackImage = mail_normal_backimage
      end
    end
  end
end
function get_mail_type(serial_no)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:FindRecordRow(Recv_rec_name, POST_TABLE_SERIALNO, serial_no, 0)
  if row < 0 then
    return -1
  end
  return client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TYPE)
end
function init_accept_control_name()
  local num = table.getn(accept_control_name_table)
  for i = 0, maxmail - 1 do
    accept_control_name_table[i][1] = nx_string("GroupBox") .. nx_string(i)
    accept_control_name_table[i][2] = nx_string("sendname") .. nx_string(i)
    accept_control_name_table[i][3] = nx_string("content") .. nx_string(i)
    accept_control_name_table[i][4] = nx_string("time") .. nx_string(i)
    accept_control_name_table[i][5] = nx_string("picture") .. nx_string(i)
    accept_control_name_table[i][6] = nx_string("template") .. nx_string(i)
    accept_control_name_table[i][7] = nx_string("image") .. nx_string(i)
    accept_control_name_table[i][8] = nx_string("select") .. nx_string(i)
    accept_control_name_table[i][9] = nx_string("timelimite") .. nx_string(i)
    accept_control_name_table[i][10] = nx_string("imageex") .. nx_string(i)
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
      initgroupboxobj.serial_no = ""
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
  local rownum = client_player:GetRecordRows(Recv_rec_name)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\post.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(nx_string("Post"))
  if index < 0 then
    return
  end
  self.mltbox_capacity:Clear()
  local maxnum = ini:ReadString(index, "PostBoxMax", 32)
  if nx_int(maxnum) <= nx_int(rownum) then
    self.mltbox_capacity:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_mail_full")), nx_int(-1))
  else
    self.mltbox_capacity:AddHtmlText(nx_widestr(nx_string(rownum) .. "/" .. nx_string(maxnum)), nx_int(-1))
  end
  if rownum <= 0 then
    return
  end
  local showrownum = 0
  if self.mail_type == 1 then
    showrownum = get_user_num()
  elseif self.mail_type == 2 then
    showrownum = get_system_num()
  end
  if showrownum == 0 then
    return
  end
  local cur_page = self.cur_page_user
  if self.mail_type == 1 then
    cur_page = self.cur_page_user
  elseif self.mail_type == 2 then
    cur_page = self.cur_page_system
  end
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
  for row = rownum - 1, 0, -1 do
    local ntype = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TYPE)
    local is_show = false
    if nx_int(ntype) > nx_int(LETTER_SYSTEM_TYPE_MIN) and nx_int(ntype) < nx_int(LETTER_SYSTEM_TYPE_MAX) and self.mail_type == 2 then
      cur_index = cur_index - 1
      if end_index <= cur_index and start_index >= cur_index then
        is_show = true
      end
    elseif nx_int(ntype) > nx_int(LETTER_USER_TYPE_MIN) and nx_int(ntype) < nx_int(LETTER_USER_TYPE_MAX) and self.mail_type == 1 then
      cur_index = cur_index - 1
      if end_index <= cur_index and start_index >= cur_index then
        is_show = true
      end
    end
    if is_show then
      local groupboxname = accept_control_name_table[index][1]
      local groupboxobj = self:Find(nx_string(groupboxname))
      if nx_is_valid(groupboxobj) and 0 <= row then
        groupboxobj.Visible = true
        local sendername = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_SENDNAME)
        local str_title = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_LETTERNAME)
        if nx_int(ntype) > nx_int(LETTER_SYSTEM_TYPE_MIN) and nx_int(ntype) < nx_int(LETTER_SYSTEM_TYPE_MAX) and self.mail_type == 2 then
          str_title = gui.TextManager:GetText("ui_SysMail")
        end
        local str_content = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_VALUE)
        local silver = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_SILVER)
        local str_goods = nx_string(client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_APPEDIXVALUE))
        local serialno = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_SERIALNO)
        local trade_done = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TRADE_DONE)
        local real_title = nx_widestr(str_title)
        local real_content = nx_widestr(str_content)
        local real_sender = nx_widestr(sendername)
        local is_system_mail = false
        if nx_int(ntype) > nx_int(LETTER_SYSTEM_TYPE_MIN) and nx_int(ntype) < nx_int(LETTER_SYSTEM_TYPE_MAX) then
          if gui.TextManager:IsIDName(nx_string(str_title)) then
            real_title = gui.TextManager:GetText(nx_string(str_title))
          end
          if nx_string(sendername) == "" then
            real_sender = gui.TextManager:GetText("ui_SysMail")
          else
            real_sender = gui.TextManager:GetText(nx_string(sendername))
          end
          if nx_string(str_title) == "offlinejobprize" then
            local str_lst = util_split_string(nx_string(str_content), ",")
            local date_lst = util_split_string(nx_string(str_lst[1]), "//")
            gui.TextManager:Format_SetIDName("str_lx_mail_title")
            gui.TextManager:Format_AddParam(nx_string(date_lst[2]))
            gui.TextManager:Format_AddParam(nx_string(date_lst[3]))
            real_content = nx_string(gui.TextManager:Format_GetText())
          else
            local str_lst = util_split_wstring(nx_widestr(str_title), ",")
            local arg_lst = util_split_wstring(nx_widestr(str_lst[2]), "|")
            local arg_count = table.getn(arg_lst)
            gui.TextManager:Format_SetIDName(nx_string(str_lst[1]))
            for i = 1, arg_count do
              local para = util_split_wstring(nx_widestr(arg_lst[i]), ":")
              local type = nx_int(para[1])
              if nx_int(type) == nx_int(1) then
                local str_para = gui.TextManager:GetText(nx_string(para[2]))
                gui.TextManager:Format_AddParam(str_para)
              elseif nx_int(type) == nx_int(2) then
                gui.TextManager:Format_AddParam(nx_int(para[2]))
              elseif nx_int(type) == nx_int(3) then
                gui.TextManager:Format_AddParam(nx_string(para[2]))
              elseif nx_int(type) == nx_int(4) then
                gui.TextManager:Format_AddParam(nx_widestr(para[2]))
              else
                gui.TextManager:Format_AddParam(para)
              end
            end
            real_title = nx_widestr(gui.TextManager:Format_GetText())
            str_lst = util_split_wstring(nx_widestr(str_content), ",")
            arg_lst = util_split_wstring(nx_widestr(str_lst[2]), "|")
            arg_count = table.getn(arg_lst)
            gui.TextManager:Format_SetIDName(nx_string(str_lst[1]))
            for i = 1, arg_count do
              local para = util_split_wstring(nx_widestr(arg_lst[i]), ":")
              local type = nx_int(para[1])
              if nx_int(type) == nx_int(1) then
                local str_para = gui.TextManager:GetText(nx_string(para[2]))
                gui.TextManager:Format_AddParam(str_para)
              elseif nx_int(type) == nx_int(2) then
                gui.TextManager:Format_AddParam(nx_int(para[2]))
              elseif nx_int(type) == nx_int(3) then
                gui.TextManager:Format_AddParam(nx_string(para[2]))
              elseif nx_int(type) == nx_int(4) then
                gui.TextManager:Format_AddParam(nx_widestr(para[2]))
              else
                gui.TextManager:Format_AddParam(para)
              end
            end
            real_content = nx_widestr(gui.TextManager:Format_GetText())
          end
          is_system_mail = true
        end
        if nx_int(ntype) == nx_int(LETTER_USER_POST_TRADE_PAY) then
          real_title = gui.TextManager:GetText(nx_string(str_title))
        end
        local sender = groupboxobj:Find(nx_string(accept_control_name_table[index][2]))
        if nx_is_valid(sender) then
          sender.Text = gui.TextManager:GetText("ui_SenderMaoHao") .. real_sender
        end
        local title = groupboxobj:Find(nx_string(accept_control_name_table[index][3]))
        if not is_system_mail then
          local CleanWord = CheckWords:CleanWords(nx_widestr(real_title))
          real_title = nx_widestr(CleanWord)
        end
        if nx_is_valid(title) then
          title.Text = nx_widestr(real_title)
        end
        groupboxobj.serial_no = nx_string(serialno)
        if nx_int(ntype) == nx_int(LETTER_USER_POST_TRADE) then
          groupboxobj.BackImage = mail_trade_normal_backimage
        else
          groupboxobj.BackImage = mail_normal_backimage
        end
        local sendtime = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_DATE)
        sendtime = os.date("%Y.%m.%d", sendtime)
        local time = groupboxobj:Find(nx_string(accept_control_name_table[index][4]))
        if nx_is_valid(time) then
          time.Text = nx_widestr(sendtime)
        end
        local lbl_image = groupboxobj:Find(nx_string(accept_control_name_table[index][7]))
        local lbl_timelimite = groupboxobj:Find(nx_string(accept_control_name_table[index][9]))
        local lbl_imageex = groupboxobj:Find(nx_string(accept_control_name_table[index][10]))
        lbl_imageex.Visible = true
        lbl_imageex.Left = groupboxobj.Width - lbl_imageex.Width - 2
        lbl_imageex.Top = 0
        if nx_is_valid(lbl_image) then
          lbl_image.Visible = false
          lbl_image.Left = title.Left + title.TextWidth
          lbl_image.Top = 8
        end
        if nx_is_valid(lbl_timelimite) then
          lbl_timelimite.Visible = false
        end
        if not is_system_mail then
          lbl_imageex.BackImage = mail_type_player
          if nx_is_valid(lbl_image) and nx_is_valid(lbl_timelimite) then
            if nx_int(ntype) == nx_int(LETTER_USER_POST_TRADE) then
              lbl_timelimite.Visible = true
              if trade_done == 1 then
                lbl_timelimite.Text = gui.TextManager:GetText("ui_fufei")
              else
                local lefttime = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_LEFT_TIME)
                if 0 < lefttime then
                  local leftday = nx_int(lefttime / 86400)
                  local lefthour = nx_int(lefttime % 86400 / 3600)
                  local leftminute = nx_int(lefttime % 86400 % 3600 / 60)
                  if leftday > nx_int(0) then
                    lbl_timelimite.Text = nx_widestr(leftday) .. gui.TextManager:GetText("ui_day")
                  elseif leftday <= nx_int(0) and lefthour > nx_int(0) then
                    lbl_timelimite.Text = nx_widestr(lefthour) .. gui.TextManager:GetText("ui_hour")
                  else
                    lbl_timelimite.Text = nx_widestr(leftminute) .. gui.TextManager:GetText("str_minute")
                  end
                else
                  lbl_timelimite.Text = gui.TextManager:GetText("ui_guoqi")
                end
              end
              lbl_image.Visible = true
              lbl_image.BackImage = mail_type_pay
            elseif string.find(str_goods, "Object") or nx_string(silver) ~= nx_string("0") then
              lbl_image.Visible = true
              lbl_image.BackImage = mail_type_goods
            end
          end
        else
          lbl_imageex.BackImage = mail_type_system
          if (string.find(str_goods, "Object") or nx_string(silver) ~= nx_string("0")) and nx_is_valid(lbl_imageex) then
            lbl_image.Visible = true
            lbl_image.BackImage = mail_type_goods
          end
        end
        local is_select = client_player:QueryRecord(Recv_rec_name, row, 12)
        local cbtn_select = groupboxobj:Find(nx_string(accept_control_name_table[index][8]))
        if nx_is_valid(cbtn_select) then
          if is_select == 1 then
            cbtn_select.Checked = true
          else
            cbtn_select.Checked = false
          end
        end
        local readflag = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_READFLAG)
        local rdflag = groupboxobj:Find(nx_string(accept_control_name_table[index][5]))
        if nx_is_valid(rdflag) then
          if readflag == 1 then
            title.ForeColor = "255,158,128,99"
            sender.ForeColor = "255,158,128,99"
            time.ForeColor = "255,158,128,99"
            lbl_timelimite.ForeColor = "255,158,128,99"
            rdflag.BackImage = mail_read_backimage
          else
            title.ForeColor = "255,128,50,23"
            sender.ForeColor = "255,108,86,68"
            time.ForeColor = "255,101,80,63"
            lbl_timelimite.ForeColor = "255,128,50,23"
            rdflag.BackImage = mail_noread_backimage
          end
        end
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
  if form.mail_type == 1 then
    rownum = get_user_num()
  elseif form.mail_type == 2 then
    rownum = get_system_num()
  end
  if rownum == 0 then
    form.serial_no = ""
    if form.mail_type == 1 then
      form.cur_page_user = 1
    elseif form.mail_type == 2 then
      form.cur_page_system = 1
    end
  end
  mail_fresh(form)
  fresh_page(form)
  fresh_select_all_state(form)
end
function on_delbutton_click(self)
  local form = self.ParentForm
  nx_execute("custom_sender", "custom_del_letter", 0, form.mail_type)
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
  if not client_player:FindRecord(Recv_rec_name) then
    return 0
  end
  local rownum = client_player:GetRecordRows(Recv_rec_name)
  local user_num = 0
  for row = 0, rownum - 1 do
    local ntype = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TYPE)
    if nx_int(ntype) > nx_int(LETTER_USER_TYPE_MIN) and nx_int(ntype) < nx_int(LETTER_USER_TYPE_MAX) then
      user_num = user_num + 1
    end
  end
  return user_num
end
function get_system_num()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord(Recv_rec_name) then
    return 0
  end
  local rownum = client_player:GetRecordRows(Recv_rec_name)
  local system_num = 0
  for row = 0, rownum - 1 do
    local ntype = client_player:QueryRecord(Recv_rec_name, row, POST_TABLE_TYPE)
    if nx_int(ntype) > nx_int(LETTER_SYSTEM_TYPE_MIN) and nx_int(ntype) < nx_int(LETTER_SYSTEM_TYPE_MAX) then
      system_num = system_num + 1
    end
  end
  return system_num
end
function on_cbtn_friend_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(cbtn, "server_refresh_flag") and cbtn.server_refresh_flag then
    cbtn.server_refresh_flag = false
    return
  end
  if cbtn.Checked then
    nx_execute("custom_sender", "custom_send_accept_friend_letter_flag", nx_int(1), nx_int(1))
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_text("ui_mail_friend_003")))
    dialog:ShowModal()
    local gui = nx_value("gui")
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
  else
    nx_execute("custom_sender", "custom_send_accept_friend_letter_flag", nx_int(1), nx_int(0))
  end
end
function request_accept_firend_letter_flag(form)
  if not nx_is_valid(form) then
    return
  end
  form.cbtn_friend.Enabled = false
  nx_execute("custom_sender", "custom_send_accept_friend_letter_flag", nx_int(0))
end
function refresh_accept_firend_letter_flag(flag)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.cbtn_friend.Enabled = true
  if nx_int(flag) > nx_int(0) then
    form.cbtn_friend.server_refresh_flag = true
    form.cbtn_friend.Checked = true
  else
    form.cbtn_friend.Checked = false
  end
end
