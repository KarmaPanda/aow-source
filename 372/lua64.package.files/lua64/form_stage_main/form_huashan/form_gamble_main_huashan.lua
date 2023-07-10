require("form_stage_main\\form_huashan\\form_gamble_main_msg")
require("util_functions")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
local m_AllowNum = 4
local m_Max = 199
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
  form.alist_now = nil
  form.alist_history = nil
  form.alist_find = nil
  form.alist_my = nil
end
function open_form()
  local mgr = nx_value("SwitchManager")
  if not nx_is_valid(mgr) then
    return
  end
  local flag = mgr:CheckSwitchEnable(ST_FUNCTION_GAMBLE_HUASHAN)
  if not flag then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(util_text(nx_string(100059))), 2)
    end
    return
  end
  util_auto_show_hide_form("form_stage_main\\form_huashan\\form_gamble_main_huashan")
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
  if not nx_is_valid(form.alist_now) then
    form.alist_now = get_arraylist("form_gamble_main_huashan_now")
  end
  form.alist_now:ClearChild()
  if not nx_is_valid(form.alist_history) then
    form.alist_history = get_arraylist("form_gamble_main_huashan_history")
  end
  form.alist_history:ClearChild()
  if not nx_is_valid(form.alist_find) then
    form.alist_find = get_arraylist("form_gamble_main_huashan_find")
  end
  form.alist_find:ClearChild()
  if not nx_is_valid(form.alist_my) then
    form.alist_my = get_arraylist("form_gamble_main_huashan_my")
  end
  form.alist_my:ClearChild()
  form.groupscrollbox_pro_list.nowproject = ""
  form.groupscrollbox_pro_list.alist_obj = nil
  form.groupbox_left.select_rbtnindex = 1
  form.lbl_num.nownum = 1
  form.lbl_num.maxnum = 1
  creat_groupform(form)
  on_rbtn_click(form.rbtn_now)
end
function on_main_form_close(form)
  if nx_is_valid(form.alist_now) then
    nx_destroy(form.alist_now)
  end
  if nx_is_valid(form.alist_history) then
    nx_destroy(form.alist_history)
  end
  if nx_is_valid(form.alist_find) then
    nx_destroy(form.alist_find)
  end
  if nx_is_valid(form.alist_my) then
    nx_destroy(form.alist_my)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function rbtn_select_index(form)
  if not nx_is_valid(form) then
    return
  end
  local index = form.groupbox_left.select_rbtnindex
  if 1 == index then
    on_custom_msg(Gamble_CToS_QueryNowGamble, 1)
    refresh_pro_form(form, form.alist_now, 0)
  elseif 2 == index then
    if 0 >= form.alist_history:GetChildCount() then
      on_custom_msg(Gamble_CToS_QueryHistory, 1)
    end
    refresh_pro_form(form, form.alist_history, 0)
  elseif 3 == index then
    on_custom_msg(Gamble_CToS_QueryMyGamble, 1)
    refresh_pro_form(form, form.alist_my, 0)
  end
end
function on_btn_find_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local playername = nx_widestr(form.combobox_name_list.Text)
  if nx_widestr("") == playername then
    return
  end
  if form.combobox_name_list.DropListBox:FindString(playername) < 0 then
    return
  end
  find_project(form, playername)
end
function on_rbtn_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  rbtn.Checked = true
  form.groupbox_left.select_rbtnindex = rbtn.TabIndex
  rbtn_select_index(form)
end
function on_btn_gamble_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local projectid = nx_string(btn.groupbox.project)
  local playername = nx_widestr(btn.imagecontrol:GetItemAddText(0, nx_int(0)))
  local formbuy = nx_execute("form_stage_main\\form_huashan\\form_gamble_buy", "open_form", projectid, playername, nx_widestr(btn.imagecontrol:GetItemAddText(0, nx_int(1))), nx_widestr(btn.imagecontrol:GetItemAddText(0, nx_int(2))), nx_widestr(btn.imagecontrol:GetItemAddText(0, nx_int(3))))
  local res, money = nx_wait_event(100000000, formbuy, projectid)
  if "ok" == res then
    on_custom_msg(Gamble_CToS_BuyOneGamble, projectid, playername, money)
  end
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_pro_form(form, nil, -1)
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_pro_form(form, nil, 1)
end
function on_btn_skip_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local num = nx_number(form.ipt_page.Text)
  local nownum = form.lbl_num.nownum
  local maxnum = form.lbl_num.maxnum
  if num <= 0 or num > maxnum or num == nownum then
    return
  end
  refresh_pro_form(form, nil, num - nownum)
end
function on_combobox_name_list_selected(combox)
end
function on_server_msg_Gamble_SToC_QueryNowGamble(form, ...)
  if not nx_is_valid(form) then
    return
  end
  creat_array(form, form.alist_now, unpack(arg))
end
function on_server_msg_Gamble_SToC_QueryHistory(form, ...)
  if not nx_is_valid(form) then
    return
  end
  creat_array(form, form.alist_history, unpack(arg))
end
function on_server_msg_Gamble_SToC_QueryPlayerMsg(form, ...)
  if not nx_is_valid(form) then
    return
  end
  local projectid = nx_string(arg[1])
  local playername = nx_widestr(arg[2])
  local school = nx_string(arg[3])
  local guild = nx_widestr(arg[4])
  local powerlevel = nx_number(arg[5])
  local childback = nx_null()
  local child = getchild_byname(form.alist_now, projectid, playername)
  if nx_is_valid(child) then
    child.school = school
    child.guild = guild
    child.powerlevel = powerlevel
    childback = child
  end
  child = getchild_byname(form.alist_history, projectid, playername)
  if nx_is_valid(child) then
    child.school = school
    child.guild = guild
    child.powerlevel = powerlevel
    childback = child
  end
  child = getchild_byname(form.alist_find, projectid, playername)
  if nx_is_valid(child) then
    child.school = school
    child.guild = guild
    child.powerlevel = powerlevel
    childback = child
  end
  child = getchild_byname(form.alist_my, projectid, playername)
  if nx_is_valid(child) then
    child.school = school
    child.guild = guild
    child.powerlevel = powerlevel
    childback = child
  end
  local btn = getbtn_byproject(form, childback)
  if nx_is_valid(btn) then
    refresh_detail_msg(form, childback, btn.imagecontrol, false)
  end
end
function on_server_msg_Gamble_SToC_QueryMyGamble(form, ...)
  if not nx_is_valid(form) then
    return
  end
  creat_array(form, form.alist_my, unpack(arg))
end
function on_server_msg_Gamble_SToC_BuySuccess(form, ...)
  local projectid = nx_string(arg[1])
  rbtn_select_index(form)
end
function on_server_msg_Gamble_SToC_RefrestProject(form, ...)
  refresh_array_project(form, form.alist_now, unpack(arg))
  refresh_array_project(form, form.alist_history, unpack(arg))
  refresh_array_project(form, form.alist_my, unpack(arg))
end
function refresh_pro_form(form, array, directory)
  if nil == array then
    array = form.groupscrollbox_pro_list.alist_obj
  end
  if not nx_is_valid(array) then
    return
  end
  local gui = nx_value("gui")
  form.groupscrollbox_pro_list.alist_obj = array
  local skip = nx_int(directory) * nx_int(m_AllowNum)
  local select_project = nx_string(form.groupscrollbox_pro_list.nowproject)
  local count = array:GetChildCount()
  local index = 0
  if "" ~= select_project then
    index = array:GetChildIndex(select_project)
    index = index + skip
  end
  if count <= index then
    return
  end
  if index < 0 then
    index = 0
  end
  clear_content(form)
  for i = 1, m_AllowNum do
    local groupbox_name = "GroupBox_Pro_" .. nx_string(i)
    local groupbox = form.groupscrollbox_pro_list:Find(groupbox_name)
    if not nx_is_valid(groupbox) then
      break
    end
    groupbox.Visible = false
    local sec_index = index + i - 1
    if 0 <= sec_index and count > sec_index then
      local child = array:GetChildByIndex(sec_index)
      if not nx_is_valid(child) then
        break
      end
      groupbox.project = child.project
      if i == 1 then
        form.groupscrollbox_pro_list.nowproject = child.project
      end
      local left = child:GetChildByIndex(0)
      local image1 = groupbox:Find(groupbox_name .. "_image_1")
      if nx_is_valid(image1) and nx_is_valid(left) then
        image1:ShowItemAddInfo(nx_int(0), nx_int(4), false)
        refresh_detail_msg(form, left, image1, true)
        if child.status == 2 then
          image1:SetItemAddInfo(nx_int(0), nx_int(4), nx_widestr(FormatMoney(left.money, 2)))
          image1:ShowItemAddInfo(nx_int(0), nx_int(4), true)
        end
      end
      local right = child:GetChildByIndex(1)
      local image2 = groupbox:Find(groupbox_name .. "_image_2")
      if nx_is_valid(image2) and nx_is_valid(right) then
        image2:ShowItemAddInfo(nx_int(0), nx_int(4), false)
        refresh_detail_msg(form, right, image2, true)
        if child.status == 2 then
          image2:SetItemAddInfo(nx_int(0), nx_int(4), nx_widestr(FormatMoney(right.money, 2)))
          image2:ShowItemAddInfo(nx_int(0), nx_int(4), true)
        end
      end
      local lbl_bg = groupbox:Find(groupbox_name .. "_lbl_bg")
      if nx_is_valid(lbl_bg) then
        lbl_bg.BackImage = "gui\\language\\ChineseS\\huashan\\bg_duicai_0" .. nx_string(child.status) .. ".png"
      end
      if 2 == child.status then
        local lbl_pay = groupbox:Find(groupbox_name .. "_lbl_pay")
        lbl_pay.Visible = true
        refresh_pay_money(form, lbl_pay, left.money, right.money)
        if left.playername == child.winname then
          local lbl_win1 = groupbox:Find(groupbox_name .. "_lbl_win_1")
          lbl_win1.Visible = true
        elseif right.playername == child.winname then
          local lbl_win2 = groupbox:Find(groupbox_name .. "_lbl_win_2")
          lbl_win2.Visible = true
        else
          lbl_pay.Visible = false
        end
      elseif 1 == child.status then
        local btn1 = groupbox:Find(groupbox_name .. "_btn_1")
        btn1.Enabled = true
        local btn2 = groupbox:Find(groupbox_name .. "_btn_2")
        btn2.Enabled = true
      end
      if 0 < child.buymoney then
        local lbl_money = groupbox:Find(groupbox_name .. "_lbl_money")
        lbl_money.Visible = true
        gui.TextManager:Format_SetIDName("ui_huashan_yazhu_23")
        gui.TextManager:Format_AddParam(nx_int64(child.buymoney))
        lbl_money.Text = nx_widestr(gui.TextManager:Format_GetText())
      end
      if child.buyname ~= nx_widestr("") then
        local lbl_buy = groupbox:Find(groupbox_name .. "_lbl_buy")
        lbl_buy.Visible = true
        gui.TextManager:Format_SetIDName("ui_huashan_yazhu_22")
        gui.TextManager:Format_AddParam(child.buyname)
        lbl_buy.Text = nx_widestr(gui.TextManager:Format_GetText())
      end
      groupbox.Visible = true
    end
  end
  local bbb = nx_int(count / m_AllowNum)
  if 0 < count % m_AllowNum then
    bbb = bbb + 1
  end
  local aaa = nx_int(index / m_AllowNum) + 1
  if 0 < index % m_AllowNum then
    aaa = aaa + 1
    bbb = bbb + 1
  end
  if bbb == nx_int(0) then
    bbb = aaa
  end
  form.lbl_num.Text = nx_widestr(nx_string(aaa) .. "/" .. nx_string(bbb))
  form.lbl_num.nownum = nx_number(aaa)
  form.lbl_num.maxnum = nx_number(bbb)
  if nx_string(array) ~= nx_string(form.alist_find) then
    form.combobox_name_list.DropListBox:ClearString()
    local childlist = array:GetChildList()
    for i, child in ipairs(childlist) do
      if not nx_is_valid(child) then
        break
      end
      local childonelist = child:GetChildList()
      for j, childone in ipairs(childonelist) do
        if nx_is_valid(childone) then
          add_to_combox(form, nx_widestr(childone.playername))
        end
      end
    end
  end
end
function refresh_detail_msg(form, child, imagecontrol, isrefresh)
  imagecontrol:AddItem(nx_int(0), "gui\\language\\ChineseS\\huashan\\bg_namelist.png", nx_widestr(""), 0, -1)
  imagecontrol:SetItemAddInfo(nx_int(0), nx_int(0), child.playername)
  if isrefresh and child.powerlevel == 0 then
    on_custom_msg(Gamble_CToS_QueryPlayerMsg, 1, child.project, child.playername)
  end
  local schoo = util_text("ui_huashan_visit_18")
  local guild = util_text("ui_huashan_visit_19")
  if child.school ~= "" then
    schoo = util_text(child.school)
  end
  if child.guild ~= nx_widestr("") then
    guild = nx_widestr(child.guild)
  end
  local strpowerlevel = nx_execute("form_stage_main\\form_huashan\\form_huashan_NameList", "get_powerlevel_title_one", child.powerlevel)
  imagecontrol:SetItemAddInfo(nx_int(0), nx_int(1), schoo)
  imagecontrol:SetItemAddInfo(nx_int(0), nx_int(2), guild)
  imagecontrol:SetItemAddInfo(nx_int(0), nx_int(3), util_text(strpowerlevel))
  imagecontrol:ShowItemAddInfo(nx_int(0), nx_int(0), true)
  imagecontrol:ShowItemAddInfo(nx_int(0), nx_int(1), true)
  imagecontrol:ShowItemAddInfo(nx_int(0), nx_int(2), true)
  imagecontrol:ShowItemAddInfo(nx_int(0), nx_int(3), true)
end
function refresh_pay_money(form, lbl_pay, lm, rm)
  local gui = nx_value("gui")
  lbl_pay.Text = nx_widestr("")
  if lm == 0 or rm == 0 then
    return
  end
  gui.TextManager:Format_SetIDName("ui_huashan_yazhu_21")
  if lm == rm then
    gui.TextManager:Format_AddParam(nx_int(1))
    gui.TextManager:Format_AddParam(nx_int(1))
  elseif rm < lm then
    gui.TextManager:Format_AddParam(lm / rm)
    gui.TextManager:Format_AddParam(nx_int(1))
  else
    gui.TextManager:Format_AddParam(nx_int(1))
    gui.TextManager:Format_AddParam(rm / lm)
  end
  lbl_pay.Text = nx_widestr(gui.TextManager:Format_GetText())
end
function find_project(form, playername)
  if nx_widestr("") == playername then
    return
  end
  local array
  if form.rbtn_now.Checked then
    array = form.alist_now
  elseif form.rbtn_history.Checked then
    array = form.alist_history
  elseif form.rbtn_my.Checked then
    array = form.alist_my
  end
  if not nx_is_valid(array) then
    return
  end
  form.alist_find:ClearChild()
  local childlist = array:GetChildList()
  for i, child in ipairs(childlist) do
    if not nx_is_valid(child) then
      break
    end
    if child:FindChild(nx_string(playername)) then
      copy_array(form.alist_find, child)
    end
  end
  if form.alist_find:GetChildCount() > 0 then
    refresh_pro_form(form, form.alist_find, 0)
  else
  end
end
function copy_array(arraynew, arrayold)
  if not nx_is_valid(arraynew) then
    return
  end
  local array = arraynew:CreateChild(arrayold.project)
  if not nx_is_valid(array) then
    return
  end
  nx_set_custom(array, "project", arrayold.project)
  nx_set_custom(array, "buyname", arrayold.buyname)
  nx_set_custom(array, "buymoney", arrayold.buymoney)
  nx_set_custom(array, "status", arrayold.status)
  nx_set_custom(array, "winname", arrayold.winname)
  local arrayoldlist = arrayold:GetChildList()
  for i, arrayoldone in ipairs(arrayoldlist) do
    if not nx_is_valid(arrayoldone) then
      break
    end
    local arraynewone = array:CreateChild(arrayoldone.Name)
    nx_set_custom(arraynewone, "playername", arrayoldone.playername)
    nx_set_custom(arraynewone, "money", arrayoldone.money)
    nx_set_custom(arraynewone, "project", arrayoldone.project)
    nx_set_custom(arraynewone, "flag", arrayoldone.flag)
    nx_set_custom(arraynewone, "school", arrayoldone.school)
    nx_set_custom(arraynewone, "guild", arrayoldone.guild)
    nx_set_custom(arraynewone, "powerlevel", arrayoldone.powerlevel)
  end
end
function creat_array(form, array, ...)
  if not nx_is_valid(array) then
    return
  end
  array:ClearChild()
  local i = 1
  local j = 1
  while j < m_Max do
    local projectid = nx_string(arg[i])
    if "nil" == projectid or "" == projectid then
      break
    end
    local objpro = array:CreateChild(projectid)
    if not nx_is_valid(objpro) then
      break
    end
    nx_set_custom(objpro, "project", projectid)
    i = i + 1
    local strname = nx_string(arg[i])
    local objplayera = objpro:CreateChild(strname)
    if not nx_is_valid(objplayera) then
      break
    end
    nx_set_custom(objplayera, "playername", nx_widestr(arg[i]))
    i = i + 1
    nx_set_custom(objplayera, "money", nx_number(arg[i]))
    i = i + 1
    nx_set_custom(objplayera, "project", projectid)
    nx_set_custom(objplayera, "flag", 1)
    nx_set_custom(objplayera, "school", "")
    nx_set_custom(objplayera, "guild", nx_widestr(""))
    nx_set_custom(objplayera, "powerlevel", 0)
    strname = nx_string(arg[i])
    local objplayerb = objpro:CreateChild(strname)
    if not nx_is_valid(objplayerb) then
      break
    end
    nx_set_custom(objplayerb, "playername", nx_widestr(arg[i]))
    i = i + 1
    nx_set_custom(objplayerb, "money", nx_number(arg[i]))
    i = i + 1
    nx_set_custom(objplayerb, "project", projectid)
    nx_set_custom(objplayerb, "flag", 2)
    nx_set_custom(objplayerb, "school", "")
    nx_set_custom(objplayerb, "guild", nx_widestr(""))
    nx_set_custom(objplayerb, "powerlevel", 0)
    nx_set_custom(objpro, "status", nx_number(arg[i]))
    i = i + 1
    nx_set_custom(objpro, "winname", nx_widestr(arg[i]))
    i = i + 1
    nx_set_custom(objpro, "buyname", nx_widestr(arg[i]))
    i = i + 1
    nx_set_custom(objpro, "buymoney", nx_number(arg[i]))
    i = i + 1
    j = j + 1
  end
  refresh_pro_form(form, array, 0)
end
function add_to_combox(form, playername)
  local combox = form.combobox_name_list
  if combox.DropListBox:FindString(playername) < 0 then
    combox.DropListBox:AddString(playername)
  end
end
function clear_form(form)
  form.groupscrollbox_pro_list:DeleteAll()
  form.combobox_name_list.Text = nx_widestr("")
  form.combobox_name_list.DropListBox:ClearString()
end
function clear_content(form)
  for i = 1, m_AllowNum do
    local groupbox_name = "GroupBox_Pro_" .. nx_string(i)
    local groupbox = form.groupscrollbox_pro_list:Find(groupbox_name)
    if nx_is_valid(groupbox) then
      local btn1 = groupbox:Find(groupbox_name .. "_btn_1")
      if nx_is_valid(btn1) then
        btn1.Enabled = false
      end
      local btn2 = groupbox:Find(groupbox_name .. "_btn_2")
      if nx_is_valid(btn2) then
        btn2.Enabled = false
      end
      local image1 = groupbox:Find(groupbox_name .. "_image_1")
      if nx_is_valid(image1) then
        image1:Clear()
      end
      local image2 = groupbox:Find(groupbox_name .. "_image_2")
      if nx_is_valid(image2) then
        image2:Clear()
      end
      local lbl_bg = groupbox:Find(groupbox_name .. "_lbl_bg")
      if nx_is_valid(lbl_bg) then
        lbl_bg.BackImage = ""
      end
      local lbl_pay = groupbox:Find(groupbox_name .. "_lbl_pay")
      if nx_is_valid(lbl_pay) then
        lbl_pay.Text = nx_widestr("")
        lbl_pay.Visible = false
      end
      local lbl_money = groupbox:Find(groupbox_name .. "_lbl_money")
      if nx_is_valid(lbl_money) then
        lbl_money.Text = nx_widestr("")
        lbl_money.Visible = false
      end
      local lbl_buy = groupbox:Find(groupbox_name .. "_lbl_buy")
      if nx_is_valid(lbl_buy) then
        lbl_buy.Text = nx_widestr("")
        lbl_buy.Visible = false
      end
      local lbl_win1 = groupbox:Find(groupbox_name .. "_lbl_win_1")
      if nx_is_valid(lbl_win1) then
        lbl_win1.Visible = false
      end
      local lbl_win2 = groupbox:Find(groupbox_name .. "_lbl_win_2")
      if nx_is_valid(lbl_win2) then
        lbl_win2.Visible = false
      end
    end
  end
  form.lbl_num.Text = nx_widestr("1/1")
  form.lbl_num.nownum = 1
  form.lbl_num.maxnum = 1
end
function creat_groupform(form)
  local gui = nx_value("gui")
  clear_form(form)
  local groupboxmain = form.groupscrollbox_pro_list
  groupboxmain.IsEditMode = true
  for i = 1, m_AllowNum do
    local groupbox = gui:Create("GroupBox")
    groupboxmain:Add(groupbox)
    groupbox.Name = "GroupBox_Pro_" .. nx_string(i)
    groupbox.Width = groupboxmain.Width
    groupbox.Height = 131
    groupbox.Left = 0
    groupbox.Top = 131 * (i - 1)
    groupbox.BackColor = "0,0,0,0"
    groupbox.project = ""
    local lbl_bg = gui:Create("Label")
    groupbox:Add(lbl_bg)
    lbl_bg.Name = groupbox.Name .. "_lbl_bg"
    lbl_bg.Left = 0
    lbl_bg.Top = 0
    lbl_bg.AutoSize = true
    lbl_bg.BackImage = "gui\\language\\ChineseS\\huashan\\bg_duicai_01.png"
    local imagecontrolgrid1 = gui:Create("ImageControlGrid")
    groupbox:Add(imagecontrolgrid1)
    imagecontrolgrid1.Name = groupbox.Name .. "_image_1"
    imagecontrolgrid1.Left = 115
    set_imagecontrol(imagecontrolgrid1)
    local imagecontrolgrid2 = gui:Create("ImageControlGrid")
    groupbox:Add(imagecontrolgrid2)
    imagecontrolgrid2.Name = groupbox.Name .. "_image_2"
    imagecontrolgrid2.Left = 435
    set_imagecontrol(imagecontrolgrid2)
    local btn1 = gui:Create("Button")
    groupbox:Add(btn1)
    btn1.Name = groupbox.Name .. "_btn_1"
    btn1.Left = 12
    btn1.Top = 15
    btn1.AutoSize = true
    btn1.NormalImage = "gui\\language\\ChineseS\\huashan\\btn_duicai02_out.png"
    btn1.FocusImage = "gui\\language\\ChineseS\\huashan\\btn_duicai02_on.png"
    btn1.PushImage = "gui\\language\\ChineseS\\huashan\\btn_duicai02_down.png"
    btn1.DisableImage = "gui\\language\\ChineseS\\huashan\\btn_duicai_cannot.png"
    nx_bind_script(btn1, nx_current())
    nx_callback(btn1, "on_click", "on_btn_gamble_click")
    btn1.imagecontrol = imagecontrolgrid1
    btn1.groupbox = groupbox
    local btn2 = gui:Create("Button")
    groupbox:Add(btn2)
    btn2.Name = groupbox.Name .. "_btn_2"
    btn2.Left = 526
    btn2.Top = btn1.Top
    btn2.AutoSize = true
    btn2.NormalImage = "gui\\language\\ChineseS\\huashan\\btn_duicai02_out.png"
    btn2.FocusImage = "gui\\language\\ChineseS\\huashan\\btn_duicai02_on.png"
    btn2.PushImage = "gui\\language\\ChineseS\\huashan\\btn_duicai02_down.png"
    btn2.DisableImage = "gui\\language\\ChineseS\\huashan\\btn_duicai_cannot.png"
    nx_bind_script(btn2, nx_current())
    nx_callback(btn2, "on_click", "on_btn_gamble_click")
    btn2.imagecontrol = imagecontrolgrid2
    btn2.groupbox = groupbox
    local lbl_money = gui:Create("Label")
    groupbox:Add(lbl_money)
    lbl_money.Name = groupbox.Name .. "_lbl_money"
    lbl_money.Left = (groupbox.Width - lbl_money.Width) / 2
    lbl_money.Top = 103
    lbl_money.ForeColor = "255,254,204,0"
    lbl_money.Font = "HyperLink4"
    lbl_money.Text = nx_widestr("money: ")
    lbl_money.Align = "Center"
    local lbl_buy = gui:Create("Label")
    groupbox:Add(lbl_buy)
    lbl_buy.Name = groupbox.Name .. "_lbl_buy"
    lbl_buy.Left = (groupbox.Width - lbl_buy.Width) / 2
    lbl_buy.Top = 85
    lbl_buy.ForeColor = "255,254,204,0"
    lbl_buy.Font = "HyperLink4"
    lbl_buy.Text = nx_widestr("buy: ")
    lbl_buy.Align = "Center"
    local lbl_pay = gui:Create("Label")
    groupbox:Add(lbl_pay)
    lbl_pay.Name = groupbox.Name .. "_lbl_pay"
    lbl_pay.Left = (groupbox.Width - lbl_pay.Width) / 2
    lbl_pay.Top = 30
    lbl_pay.ForeColor = "255,254,204,0"
    lbl_pay.Font = "HyperLink4"
    lbl_pay.Text = nx_widestr("payfor: ")
    lbl_pay.Align = "Center"
    local lbl_win1 = gui:Create("Label")
    groupbox:Add(lbl_win1)
    lbl_win1.Name = groupbox.Name .. "_lbl_win_1"
    lbl_win1.Left = 150
    lbl_win1.Top = 30
    lbl_win1.Text = nx_widestr("")
    lbl_win1.AutoSize = true
    lbl_win1.BackImage = "gui\\language\\ChineseS\\huashan\\bg_duicai_win.png"
    local lbl_win2 = gui:Create("Label")
    groupbox:Add(lbl_win2)
    lbl_win2.Name = groupbox.Name .. "_lbl_win_2"
    lbl_win2.Left = 340
    lbl_win2.Top = lbl_win1.Top
    lbl_win2.Text = nx_widestr("")
    lbl_win2.AutoSize = true
    lbl_win2.BackImage = "gui\\language\\ChineseS\\huashan\\bg_duicai_win.png"
    groupbox.Visible = false
  end
  groupboxmain.IsEditMode = false
end
function set_imagecontrol(imagecontrol)
  if not nx_is_valid(imagecontrol) then
    return
  end
  imagecontrol.Top = 20
  imagecontrol.HasMultiTextBox = true
  imagecontrol.MultiTextBoxCount = 5
  imagecontrol.MultiTextBoxPos = "0,0;0,38;0,56;0,20;0,74"
  imagecontrol.NoFrame = true
  imagecontrol.MultiTextBox1.NoFrame = true
  imagecontrol.MultiTextBox2.NoFrame = true
  imagecontrol.MultiTextBox3.NoFrame = true
  imagecontrol.MultiTextBox4.NoFrame = true
  imagecontrol.MultiTextBox5.NoFrame = true
  imagecontrol.SelectColor = "0,0,0,0"
  imagecontrol.MouseInColor = "0,0,0,0"
  imagecontrol.MultiTextBox1.ViewRect = "0,0,150,20"
  imagecontrol.MultiTextBox2.ViewRect = "0,0,150,20"
  imagecontrol.MultiTextBox3.ViewRect = "0,0,150,20"
  imagecontrol.MultiTextBox4.ViewRect = "0,0,150,20"
  imagecontrol.MultiTextBox5.ViewRect = "0,0,150,20"
  imagecontrol.MultiTextBox1.TextColor = "255,255,84,161"
  imagecontrol.MultiTextBox2.TextColor = "255,255,180,40"
  imagecontrol.MultiTextBox3.TextColor = "255,255,180,40"
  imagecontrol.MultiTextBox4.TextColor = "255,255,180,40"
  imagecontrol.MultiTextBox5.TextColor = "255,255,180,40"
  imagecontrol.MultiTextBox1.Font = "font_playername"
  imagecontrol.MultiTextBox2.Font = "font_main"
  imagecontrol.MultiTextBox3.Font = "font_main"
  imagecontrol.MultiTextBox4.Font = "font_main"
  imagecontrol.MultiTextBox5.Font = "font_main"
end
function getbtn_byproject(form, child)
  if not nx_is_valid(child) then
    return nx_null()
  end
  for i = 1, m_AllowNum do
    local groupbox_name = "GroupBox_Pro_" .. nx_string(i)
    local groupbox = form.groupscrollbox_pro_list:Find(groupbox_name)
    if nx_is_valid(groupbox) and groupbox.project == child.project then
      return groupbox:Find(groupbox_name .. "_btn_" .. nx_string(child.flag))
    end
  end
  return nx_null()
end
function getchild_byname(array, projectid, playername)
  local child = array:GetChild(projectid)
  if not nx_is_valid(child) then
    return nx_null()
  end
  return child:GetChild(nx_string(playername))
end
function FormatMoney(money_count, money_type)
  local retStr = nx_widestr("")
  if money_type ~= 1 and money_type ~= 2 or not (nx_number(money_count) >= nx_number(0)) then
    return retStr
  end
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return retStr
  end
  local gui = nx_value("gui")
  local tab_money = capital:SplitCapital(money_count, money_type)
  if table.getn(tab_money) == 3 then
    if nx_number(tab_money[1]) == nx_number(0) and nx_number(tab_money[2]) == nx_number(0) and nx_number(tab_money[3]) == nx_number(0) then
      return nx_widestr("0") .. gui.TextManager:GetText("ui_wen")
    end
    if nx_number(tab_money[1]) ~= nx_number(0) then
      retStr = retStr .. nx_widestr(tab_money[1]) .. gui.TextManager:GetText("ui_ding")
    end
    if nx_number(tab_money[2]) ~= nx_number(0) then
      retStr = retStr .. nx_widestr(tab_money[2]) .. gui.TextManager:GetText("ui_liang")
    end
    if nx_number(tab_money[3]) ~= nx_number(0) then
      retStr = retStr .. nx_widestr(tab_money[3]) .. gui.TextManager:GetText("ui_wen")
    end
    return nx_widestr(retStr)
  end
end
function refresh_array_project(form, array, ...)
  local projectid = nx_string(arg[1])
  local namea = nx_widestr(arg[2])
  local moneya = nx_number(arg[3])
  local nameb = nx_widestr(arg[4])
  local moneyb = nx_number(arg[5])
  local status = nx_number(arg[6])
  local winname = nx_widestr(arg[7])
  local buyname = nx_widestr(arg[8])
  local buymoney = nx_number(arg[9])
  local child = array:GetChild(projectid)
  if not nx_is_valid(child) then
    return
  end
  nx_set_custom(child, "buyname", buyname)
  nx_set_custom(child, "buymoney", buymoney)
  nx_set_custom(child, "status", status)
  nx_set_custom(child, "winname", winname)
  local objplayera = child:GetChild(nx_string(namea))
  if nx_is_valid(objplayera) then
    nx_set_custom(objplayera, "money", moneya)
  end
  local objplayerb = child:GetChild(nx_string(nameb))
  if nx_is_valid(objplayerb) then
    nx_set_custom(objplayerb, "money", moneyb)
  end
end
