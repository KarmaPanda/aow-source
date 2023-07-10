require("form_stage_main\\form_huashan\\huashan_define")
require("form_stage_main\\form_huashan\\huashan_function")
require("util_functions")
require("util_gui")
local power_level = {
  0,
  6,
  11,
  16,
  21,
  26,
  31,
  36,
  41,
  46,
  51,
  56,
  61,
  66,
  71,
  76,
  81,
  86,
  91,
  96,
  101,
  106,
  111,
  116,
  121,
  136,
  151
}
local select_grid = {
  [1] = "gui\\language\\ChineseS\\huashan\\bg_namelist_1.png",
  [2] = "gui\\language\\ChineseS\\huashan\\bg_namelist_2.png",
  [3] = "gui\\language\\ChineseS\\huashan\\bg_namelist_3.png",
  [4] = "gui\\language\\ChineseS\\huashan\\bg_namelist_4.png",
  [5] = "gui\\language\\ChineseS\\huashan\\bg_namelist_5.png",
  [6] = "gui\\language\\ChineseS\\huashan\\bg_namelist_6.png",
  [7] = "gui\\language\\ChineseS\\huashan\\bg_namelist_7.png",
  [8] = "gui\\language\\ChineseS\\huashan\\bg_namelist_8.png",
  [9] = "gui\\language\\ChineseS\\huashan\\bg_namelist_9.png"
}
local grid_backimage = "gui\\language\\ChineseS\\huashan\\bg_namelist.png"
local select_grid_index = {}
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
  form.returneventid = ""
  form.canselectnumber = 0
  form.havenumber = 0
end
function open_form(selectnumber, returneventid)
  local num = nx_number(selectnumber)
  if num < 0 or num > nx_number(table.getn(select_grid)) then
    return nx_null()
  end
  if returneventid == nil or nx_string(returneventid) == "" then
    return nx_null()
  end
  local form = nx_value(m_NameList_Path)
  if nx_is_valid(form) then
    form:Close()
  end
  form = util_get_form(m_NameList_Path, true)
  if not nx_is_valid(form) then
    return nx_null()
  end
  form:Show()
  form.Visible = true
  form.returneventid = nx_string(returneventid)
  form.canselectnumber = num
  return form
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
  nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_QueryNameList, 0)
end
function on_main_form_close(form)
  local num = table.maxn(select_grid_index)
  for i = num, 1, -1 do
    table.remove(select_grid_index, i)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_gen_event(form, form.returneventid, "cancel")
  form:Close()
end
function on_btn_del_click(btn)
  local num = table.maxn(select_grid_index)
  local form = btn.ParentForm
  if num < 1 then
    return
  end
  form.ImageControlGridlist:SetItemImage(select_grid_index[num], grid_backimage)
  table.remove(select_grid_index, num)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local namedetail = nx_widestr("")
  if table.maxn(select_grid_index) >= 1 then
    for _, index in ipairs(select_grid_index) do
      local name = form.ImageControlGridlist:GetItemAddText(index, nx_int(0))
      if namedetail == nx_widestr("") then
        namedetail = name
      else
        namedetail = namedetail .. nx_widestr(",") .. name
      end
    end
    nx_gen_event(form, form.returneventid, namedetail)
  else
    nx_gen_event(form, form.returneventid, "cancel")
  end
  form:Close()
end
function on_ImageControlGridlist_mousein_grid(grid, index)
  local text = grid:GetItemName(index)
  local name = grid:GetItemAddText(index, nx_int(0))
  if nx_widestr("") == name then
    return
  end
  if nx_widestr("") == text then
    return
  end
  local strs = name .. nx_widestr("<br>") .. text
  nx_execute("tips_game", "show_text_tip", strs, grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
end
function on_ImageControlGridlist_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_ImageControlGridlist_select_changed(grid, index)
  local form = grid.ParentForm
  if table.maxn(select_grid_index) >= form.canselectnumber then
    return
  end
  for _, index2 in ipairs(select_grid_index) do
    if index == index2 then
      return
    end
  end
  local text = grid:GetItemName(index)
  local name = grid:GetItemAddText(index, nx_int(0))
  if nx_widestr("") == name then
    return
  end
  table.insert(select_grid_index, index)
  grid:SetItemImage(index, select_grid[table.maxn(select_grid_index)])
end
function on_server_msg_list(...)
  if HuaShanSToC_Lottery ~= arg[1] then
    return
  end
  if HS_LTT_SToC_QueryNameList ~= arg[2] then
    return
  end
  local form = nx_value(m_NameList_Path)
  if not nx_is_valid(form) then
    return
  end
  form.ImageControlGridlist:Clear()
  local i = 3
  for j = 0, 99 do
    if nil == arg[i] then
      break
    end
    if nx_string(arg[i]) ~= "" and m_Name_NULL ~= nx_string(arg[i]) then
      local name = nx_widestr(arg[i])
      i = i + 1
      local schoo = util_text(arg[i])
      i = i + 1
      local guild = nx_widestr(arg[i])
      i = i + 1
      local level = util_text(get_powerlevel_title_one(arg[i]))
      i = i + 1
      if nx_widestr("") == schoo then
        schoo = util_text("ui_huashan_visit_18")
      end
      if nx_widestr("") == guild then
        guild = util_text("ui_huashan_visit_19")
      end
      local text = schoo .. nx_widestr("<br>") .. guild .. nx_widestr("<br>") .. level
      form.ImageControlGridlist:AddItem(nx_int(j), grid_backimage, nx_widestr(""), 0, -1)
      form.ImageControlGridlist:SetItemName(nx_int(j), text)
      form.ImageControlGridlist:SetItemAddInfo(nx_int(j), nx_int(0), name)
      form.ImageControlGridlist:ShowItemAddInfo(nx_int(j), nx_int(0), true)
      form.havenumber = form.havenumber + 1
    else
      i = i + 4
    end
  end
end
function get_powerlevel_title_one(powerlevel)
  local pl = nx_number(powerlevel)
  if pl < 6 then
    return "tips_title_0"
  elseif 151 <= pl then
    return "tips_title_151"
  elseif 136 <= pl then
    return "tips_title_136"
  elseif 121 <= pl then
    return "tips_title_121"
  end
  local s = powerlevel / 10
  local y = powerlevel % 10
  if 6 <= y then
    y = 6
  elseif y == 0 then
    s = s - 1
    y = 6
  else
    y = 1
  end
  return "tips_title_" .. nx_string(nx_int(s) * 10 + y)
end
function get_powerlevel_title_two(powerlevel)
  local pl = nx_number(powerlevel)
  for i = table.getn(power_level), 1, -1 do
    if pl >= power_level[i] then
      return "tips_title_" .. nx_string(power_level[i])
    end
  end
  return "tips_title_0"
end
function get_powerlevel_title_three(powerlevel)
  return "desc_title001"
end
