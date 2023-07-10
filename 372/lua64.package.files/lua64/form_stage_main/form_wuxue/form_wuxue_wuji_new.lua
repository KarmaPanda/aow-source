require("util_gui")
require("util_functions")
require("define\\gamehand_type")
require("share\\itemtype_define")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
local MSG_CLIENT_WUJI_REQUEST_INFO = 21
local MSG_CLIENT_WUJI_OPEN_BOX = 22
local MSG_CLIENT_WUJI_WEAR = 23
local MSG_CLIENT_WUJI_CLEAR = 24
local MSG_CLIENT_WUJI_ACTIVATE = 25
local MSG_CLIENT_WUJI_CANCEL = 26
local MSG_CHIENT_WUJI_DEL_SLOT = 27
local MSG_CHIENT_WUJI_CLEAR_ONE = 28
local MSG_SERVER_WEAR_WUJI_INFO = 4
local MSG_SERVER_WEAR_WUJI_REFRESH = 5
local MSG_SERVER_LEARN_WUJI_INFO = 6
local MSG_SERVER_OVER_LOAD = 7
local MSG_SERVER_DEL_WUJI_INFO = 8
local WUJI_WEAR_TYPE_NONE = 0
local WUJI_WEAR_TYPE_FIRST = 1
local WUJI_WEAR_TYPE_SECOND = 2
local WUJI_WEAR_TYPE_THIRD = 3
local GRID_EMPTY = 0
local GRID_LOCK = 1
local GRID_EQUIP = 2
local WUJI_NUM = 8
local WUJI_PAGE_INDEX = 1
local WUJI_PAGE_TOTAL_NUM = 3
function main_form_init(form)
  form.Fixed = false
  return 1
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("WuJiPoint", "int", form, nx_current(), "on_wuji_point_change")
  end
  hide_empty_pic(form)
  refresh_first_wear_wuji(form)
  refresh_second_wear_wuji(form)
  form.btn_ok_1.Enabled = false
  form.btn_ok_2.Enabled = false
  form.btn_reset_solt.Enabled = false
  form.lbl_7.Text = nx_widestr(WUJI_PAGE_INDEX)
  nx_execute("custom_sender", "custom_jingmai_wuji_msg", MSG_CLIENT_WUJI_REQUEST_INFO)
end
function main_form_close(form)
  clear_wuji_data(form)
  nx_destroy(form)
end
function on_main_form_shut(form)
  clear_wuji_data(form)
end
function clear_wuji_data(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("WuJiPoint", form)
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "hide_empty_pic", form)
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if nx_is_valid(skill_data_manager) then
    skill_data_manager:ClearWuJiInfo()
  end
end
function on_wuji_msg(sub_type, ...)
  local form_main = nx_value(FORM_WUXUE_MAIN)
  if not nx_is_valid(form_main) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_wuxue\\form_wuxue_wuji_new")
  if not nx_is_valid(form) then
    return 0
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return 0
  end
  if sub_type == MSG_SERVER_WEAR_WUJI_INFO then
    local count = table.getn(arg)
    if count <= 1 then
      return 0
    end
    local wuji_type = nx_number(arg[1])
    local wuji_count = count - 1
    if wuji_type == WUJI_WEAR_TYPE_FIRST then
      for i = 1, wuji_count do
        skill_data_manager:AddWearWuJi(1, nx_int(arg[1 + i]))
      end
      refresh_first_wear_wuji(form)
    elseif wuji_type == WUJI_WEAR_TYPE_SECOND then
      for i = 1, wuji_count do
        skill_data_manager:AddWearWuJi(2, nx_int(arg[1 + i]))
      end
      refresh_second_wear_wuji(form)
    elseif wuji_type == WUJI_WEAR_TYPE_THIRD then
      wuji_count = wuji_count / 2
      for i = 1, wuji_count do
        skill_data_manager:SetActivateWuJi(nx_int(arg[i * 2]), nx_int(arg[1 + i * 2]))
      end
      nx_execute("form_stage_main\\form_wuxue\\form_wuxue_skill", "refresh_wuji_activate_Status")
    end
    refresh_reset_slot(form)
  elseif sub_type == MSG_SERVER_WEAR_WUJI_REFRESH then
    local count = table.getn(arg)
    if count <= 1 then
      return 0
    end
    local wuji_type = nx_number(arg[1])
    local wuji_count = (count - 1) / 2
    if wuji_type == WUJI_WEAR_TYPE_FIRST then
      for i = 1, wuji_count do
        skill_data_manager:SetWearWuJi(1, nx_int(arg[i * 2]), nx_int(arg[1 + i * 2]))
      end
      refresh_first_wear_wuji(form)
    elseif wuji_type == WUJI_WEAR_TYPE_SECOND then
      for i = 1, wuji_count do
        skill_data_manager:SetWearWuJi(2, nx_int(arg[i * 2]), nx_int(arg[1 + i * 2]))
      end
      refresh_second_wear_wuji(form)
    elseif wuji_type == WUJI_WEAR_TYPE_THIRD then
      for i = 1, wuji_count do
        skill_data_manager:SetActivateWuJi(nx_int(arg[i * 2]), nx_int(arg[1 + i * 2]))
      end
      nx_execute("form_stage_main\\form_wuxue\\form_wuxue_skill", "refresh_wuji_activate_Status")
    end
    refresh_reset_slot(form)
  elseif sub_type == MSG_SERVER_LEARN_WUJI_INFO then
    local count = table.getn(arg)
    if count < 2 then
      return 0
    end
    local wuji_count = count / 2
    for i = 1, wuji_count do
      skill_data_manager:SetLearnWuJi(nx_int(arg[i * 2 - 1]), nx_int(arg[i * 2]))
    end
    if form_main.cur_index == WUXUE_SKILL then
      nx_execute("form_stage_main\\form_wuxue\\form_wuxue_skill", "refresh_skill_wuji_status")
    end
  elseif sub_type == MSG_SERVER_DEL_WUJI_INFO then
    local count = table.getn(arg)
    if count < 1 then
      return 0
    end
    local wuji_type = nx_number(arg[1])
    skill_data_manager:ClearWuJiWear(wuji_type)
    if wuji_type == WUJI_WEAR_TYPE_FIRST then
      refresh_first_wear_wuji(form)
    else
      refresh_second_wear_wuji(form)
    end
    refresh_reset_slot(form)
  elseif sub_type == MSG_SERVER_OVER_LOAD then
  end
end
function show_empty_pic(wuji_index)
  local form = nx_value("form_stage_main\\form_wuxue\\form_wuxue_wuji_new")
  if not nx_is_valid(form) then
    return
  end
  local ini_info = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI_INFO)
  if not nx_is_valid(ini_info) then
    return
  end
  hide_empty_pic(form)
  wuji_index = nx_number(wuji_index)
  local wuji_wear_type = get_wuji_wear_type_by_index(ini_info, wuji_index)
  if wuji_wear_type == 1 then
    for i = 0, WUJI_NUM - 1 do
      local pic = form:Find("lbl_empty1_" .. nx_string(i))
      if nx_is_valid(pic) then
        local mark = form.imagegrid_wuji_1:GetItemMark(i)
        if nx_int(mark) == nx_int(GRID_EMPTY) then
          pic.Visible = true
        else
          pic.Visible = false
        end
      end
    end
  elseif wuji_wear_type == 2 then
    for i = 0, WUJI_NUM - 1 do
      local pic = form:Find("lbl_empty2_" .. nx_string(i))
      if nx_is_valid(pic) then
        local mark = form.imagegrid_wuji_2:GetItemMark(WUJI_PAGE_INDEX * WUJI_NUM + i)
        if nx_int(mark) == nx_int(GRID_EMPTY) then
          pic.Visible = true
        else
          pic.Visible = false
        end
      end
    end
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(3000, 1, nx_current(), "hide_empty_pic", form, -1, -1)
  end
end
function hide_empty_pic(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 0, WUJI_NUM - 1 do
    local pic = form:Find("lbl_empty1_" .. nx_string(i))
    if nx_is_valid(pic) then
      pic.Visible = false
    end
  end
  for i = 0, WUJI_NUM - 1 do
    local pic = form:Find("lbl_empty2_" .. nx_string(i))
    if nx_is_valid(pic) then
      pic.Visible = false
    end
  end
end
function refresh_reset_slot(form)
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return
  end
  local count1 = skill_data_manager:GetWearWuJiCount(1)
  local count2 = skill_data_manager:GetWearWuJiCount(2)
  local count = nx_number(count1 + count2)
  if nx_number(count) > 0 then
    form.btn_reset_solt.Enabled = true
  else
    form.btn_reset_solt.Enabled = false
  end
end
function refresh_first_wear_wuji(form)
  if not nx_is_valid(form) then
    return
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return
  end
  local count = skill_data_manager:GetWearWuJiCount(1)
  form.btn_reset_1.Enabled = false
  local ini = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI)
  if not nx_is_valid(ini) then
    return
  end
  local ini_info = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI_INFO)
  if not nx_is_valid(ini_info) then
    return
  end
  for i = 0, WUJI_NUM - 1 do
    if nx_int(i) < nx_int(count) then
      local wuji_index = skill_data_manager:GetWearWuJiIndex(1, i)
      if 0 < wuji_index then
        local learn_sec_index = ini_info:FindSectionIndex("wuji_learn")
        if learn_sec_index < 0 then
          return
        end
        local str_name = ini_info:ReadString(learn_sec_index, nx_string(wuji_index), "")
        local str_name_tab = util_split_string(nx_string(str_name), ",")
        local tab_count = table.getn(str_name_tab)
        if tab_count < 1 then
          return
        end
        local wuji_name = str_name_tab[1]
        local combo_sec_index = ini:FindSectionIndex("combo")
        if combo_sec_index < 0 then
          return
        end
        local photo = ini:ReadString(combo_sec_index, wuji_name, "")
        form.imagegrid_wuji_1:AddItem(i, photo, nx_widestr(wuji_index), 1, nx_int(GRID_EQUIP))
        form.imagegrid_wuji_1:ChangeItemImageToBW(i, false)
        form.imagegrid_wuji_1:SetItemBackImage(i, "gui\\special\\wuxue\\g2.png")
        form.imagegrid_wuji_1:SetItemCoverImage(i, "gui\\special\\wuxue\\button\\jiao2.png")
        form.imagegrid_wuji_1:CoverItem(i, true)
        form.btn_reset_1.Enabled = true
      else
        form.imagegrid_wuji_1:AddItem(i, " ", nx_widestr("0"), 1, nx_int(GRID_EMPTY))
        form.imagegrid_wuji_1:ChangeItemImageToBW(i, true)
        form.imagegrid_wuji_1:SetItemBackImage(i, "gui\\special\\wuxue\\g2.png")
        form.imagegrid_wuji_1:SetItemCoverImage(i, "gui\\special\\wuxue\\button\\jiao1.png")
        form.imagegrid_wuji_1:CoverItem(i, true)
      end
    else
      form.imagegrid_wuji_1:AddItem(i, " ", nx_widestr("0"), 1, nx_int(GRID_LOCK))
      form.imagegrid_wuji_1:ChangeItemImageToBW(i, false)
      form.imagegrid_wuji_1:SetItemBackImage(i, "gui\\special\\wuxue\\g1.png")
      form.imagegrid_wuji_1:SetItemCoverImage(i, "")
      form.imagegrid_wuji_1:CoverItem(i, false)
    end
  end
end
function refresh_second_wear_wuji(form)
  if not nx_is_valid(form) then
    return
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return
  end
  local count = skill_data_manager:GetWearWuJiCount(2)
  form.btn_reset_2.Enabled = false
  for i = 0, count - 1 do
    local wuji_index = skill_data_manager:GetWearWuJiIndex(2, i)
    if 0 < wuji_index then
      form.btn_reset_2.Enabled = true
    end
  end
  form.btn_ok_2.Enabled = false
  local ini = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI)
  if not nx_is_valid(ini) then
    return
  end
  local ini_info = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI_INFO)
  if not nx_is_valid(ini_info) then
    return
  end
  for i = 0, WUJI_NUM - 1 do
    if nx_int((WUJI_PAGE_INDEX - 1) * WUJI_NUM + i) < nx_int(count) then
      local wuji_index = skill_data_manager:GetWearWuJiIndex(2, (WUJI_PAGE_INDEX - 1) * WUJI_NUM + i)
      if 0 < wuji_index then
        local learn_sec_index = ini_info:FindSectionIndex("wuji_learn")
        if learn_sec_index < 0 then
          return
        end
        local str_name = ini_info:ReadString(learn_sec_index, nx_string(wuji_index), "")
        local str_name_tab = util_split_string(nx_string(str_name), ",")
        local tab_count = table.getn(str_name_tab)
        if tab_count < 1 then
          return
        end
        local wuji_name = str_name_tab[1]
        local combo_sec_index = ini:FindSectionIndex("combo")
        if combo_sec_index < 0 then
          return
        end
        local photo = ini:ReadString(combo_sec_index, wuji_name, "")
        form.imagegrid_wuji_2:AddItem(i, photo, nx_widestr(wuji_index), 1, nx_int(GRID_EQUIP))
        form.imagegrid_wuji_2:ChangeItemImageToBW(i, false)
        form.imagegrid_wuji_2:SetItemBackImage(i, "gui\\special\\wuxue\\g2.png")
        form.imagegrid_wuji_2:SetItemCoverImage(i, "gui\\special\\wuxue\\button\\jiao2.png")
        form.imagegrid_wuji_2:CoverItem(i, true)
      else
        form.imagegrid_wuji_2:AddItem(i, " ", nx_widestr("0"), 1, nx_int(GRID_EMPTY))
        form.imagegrid_wuji_2:ChangeItemImageToBW(i, true)
        form.imagegrid_wuji_2:SetItemBackImage(i, "gui\\special\\wuxue\\g2.png")
        form.imagegrid_wuji_2:SetItemCoverImage(i, "gui\\special\\wuxue\\button\\jiao1.png")
        form.imagegrid_wuji_2:CoverItem(i, true)
      end
    else
      form.imagegrid_wuji_2:AddItem(i, " ", nx_widestr("0"), 1, nx_int(GRID_LOCK))
      form.imagegrid_wuji_2:ChangeItemImageToBW(i, false)
      form.imagegrid_wuji_2:SetItemBackImage(i, "gui\\special\\wuxue\\g1.png")
      form.imagegrid_wuji_2:SetItemCoverImage(i, "")
      form.imagegrid_wuji_2:CoverItem(i, false)
    end
  end
end
function on_wuji_point_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local wuji_point = client_player:QueryProp("WuJiPoint")
  form.lbl_wuji_point.Text = nx_widestr(wuji_point)
end
function show_wuji_tips(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  local ini_info = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI_INFO)
  if not nx_is_valid(ini_info) then
    return
  end
  local wuji_index = nx_number(grid:GetItemName(index))
  if wuji_index == 0 then
    return
  end
  local name = get_wuji_name_by_index(ini_info, wuji_index)
  local item_data = nx_execute("tips_game", "get_tips_ArrayList")
  item_data.ConfigID = nx_string(name)
  item_data.ItemType = nx_int(ITEMTYPE_WUJI)
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_imagegrid_wuji_mousein_grid(grid, index)
  local market = grid:GetItemMark(index)
  if nx_int(market) == nx_int(GRID_EMPTY) then
    if nx_number(grid:GetItemName(index)) > 0 then
      show_wuji_tips(grid, index)
    else
      nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("tips_wuji_empty")), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop())
    end
  elseif nx_int(market) == nx_int(GRID_LOCK) then
    local ini = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI)
    if not nx_is_valid(ini) then
      return
    end
    local sec_index = ini:FindSectionIndex("wujibox_need")
    if sec_index < 0 then
      return
    end
    local cur_page = WUJI_PAGE_INDEX
    if nx_number(grid.DataSource) == 1 then
      cur_page = 1
    end
    local need = ini:ReadInteger(sec_index, nx_string((cur_page - 1) * WUJI_NUM + index + 1), 0)
    local gui = nx_value("gui")
    local txt = gui.TextManager:GetFormatText("tips_wuji_unlock_need", nx_int(need))
    nx_execute("tips_game", "show_text_tip", nx_widestr(txt), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop())
  elseif nx_int(market) == nx_int(GRID_EQUIP) then
    show_wuji_tips(grid, index)
  end
end
function on_imagegrid_wuji_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_wuji_right_click(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local imagegrid = grid
  if nx_int(imagegrid:GetItemMark(index)) ~= nx_int(GRID_EMPTY) then
    if nx_int(imagegrid:GetItemMark(index)) == nx_int(GRID_EQUIP) then
      reset_one_wuji(nx_number(grid.DataSource), index)
    end
  else
    if nx_int(imagegrid:GetItemMark(index)) == nx_int(GRID_EQUIP) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_need_choose_reset_wuji"), 2)
      end
    end
    if nx_number(imagegrid:GetItemName(index)) > 0 then
      imagegrid:SetItemImage(nx_int(index), "")
      imagegrid:SetItemName(nx_int(index), nx_widestr(""))
    end
    if nx_number(grid.DataSource) == 1 then
      form.btn_ok_1.Enabled = false
      for i = 0, WUJI_NUM - 1 do
        if nx_int(imagegrid:GetItemMark(i)) == nx_int(GRID_EMPTY) and nx_number(imagegrid:GetItemName(i)) ~= 0 then
          form.btn_ok_1.Enabled = true
          return
        end
      end
    else
      form.btn_ok_2.Enabled = false
      for i = 0, WUJI_NUM - 1 do
        if nx_int(imagegrid:GetItemMark(i)) == nx_int(GRID_EMPTY) and nx_number(imagegrid:GetItemName(i)) ~= 0 then
          form.btn_ok_2.Enabled = true
          return
        end
      end
    end
  end
end
function on_imagegrid_wuji_select_changed(grid, index)
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return
  end
  if nx_int(index) < nx_int(0) or nx_int(index) > nx_int(WUJI_NUM - 1) then
    return
  end
  local market = grid:GetItemMark(index)
  if nx_int(market) ~= nx_int(GRID_LOCK) then
    return
  end
  local gui = nx_value("gui")
  if not gui.GameHand:IsEmpty() then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local count = skill_data_manager:GetWearWuJiCount(nx_int(grid.DataSource))
  local data_source = grid.DataSource
  local cur_page = WUJI_PAGE_INDEX
  if nx_number(data_source) == 1 then
    cur_page = 1
  end
  if nx_int((cur_page - 1) * WUJI_NUM + index) ~= nx_int(count) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("wujibox_need")
  if sec_index < 0 then
    return
  end
  local need = ini:ReadInteger(sec_index, nx_string((cur_page - 1) * WUJI_NUM + index + 1), 0)
  local wuji_point = client_player:QueryProp("WuJiPoint")
  if nx_int(wuji_point) < nx_int(need) then
    local gui = nx_value("gui")
    local txt = gui.TextManager:GetFormatText("ui_wuji_point_not_enough", nx_int(need))
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(txt, 2)
    end
    return
  end
  local gui = nx_value("gui")
  local ask_dialog = util_get_form("form_common\\form_confirm", true, false)
  ask_dialog.Left = (gui.Width - ask_dialog.Width) / 2
  ask_dialog.Top = (gui.Height - ask_dialog.Height) / 2
  local text = nx_widestr(util_text("ui_jingmai_wuji_open"))
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  local helper_form = nx_value("helper_form")
  if helper_form then
    ask_dialog.HAnchor = "Left"
    ask_dialog.Visible = true
    ask_dialog:Show()
  else
    ask_dialog:ShowModal()
  end
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  if res == "ok" then
    local helper = 0
    if helper_form then
      helper = 1
    end
    nx_execute("custom_sender", "custom_jingmai_wuji_msg", MSG_CLIENT_WUJI_OPEN_BOX, nx_int(data_source), nx_int((cur_page - 1) * WUJI_NUM + index), nx_int(helper))
  end
end
function auto_wuji_drop_in(grid_type, photo, wuji_index)
  local form = nx_value("form_stage_main\\form_wuxue\\form_wuxue_wuji_new")
  if not nx_is_valid(form) then
    return 0
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return 0
  end
  local grid = form.imagegrid_wuji_1
  if grid_type ~= 1 then
    grid = form.imagegrid_wuji_2
    if skill_data_manager:FindWearWuJi(2, wuji_index) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_wuji_cant_equip_again"), 2)
      end
      return
    end
  end
  for i = 0, WUJI_NUM - 1 do
    if nx_number(grid:GetItemName(i)) == wuji_index then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_wuji_cant_equip_again"), 2)
      end
      return
    end
  end
  local count = grid.MaxSize
  for i = 1, count do
    local market = grid:GetItemMark(i - 1)
    local grid_wuji_index = nx_number(grid:GetItemName(i - 1))
    if nx_int(market) == nx_int(GRID_EMPTY) and grid_wuji_index == 0 then
      grid:SetItemImage(nx_int(i - 1), photo)
      grid:SetItemName(nx_int(i - 1), nx_widestr(wuji_index))
      if nx_number(grid.DataSource) == 1 then
        form.btn_ok_1.Enabled = true
      else
        form.btn_ok_2.Enabled = true
      end
      return
    end
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_wuji_equip_full"), 2)
  end
end
function on_imagegrid_wuji_drop_in(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ini_info = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI_INFO)
  if not nx_is_valid(ini_info) then
    return
  end
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if game_hand:IsEmpty() then
    return
  end
  if game_hand.Type ~= GHT_COMBO then
    return
  end
  local market = grid:GetItemMark(index)
  if nx_int(market) == nx_int(GRID_EQUIP) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_need_choose_reset_wuji"), 2)
    end
  end
  if nx_int(market) ~= nx_int(GRID_EMPTY) then
    return
  end
  local photo = nx_string(gui.GameHand.Para1)
  local wuji_index = nx_number(gui.GameHand.Para2)
  if wuji_index <= 0 then
    return
  end
  local wuji_wear_type = get_wuji_wear_type_by_index(ini_info, wuji_index)
  if wuji_wear_type ~= nx_number(grid.DataSource) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_wuji_no_gird"), 2)
    end
    return
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return 0
  end
  if nx_number(grid.DataSource) == 2 and skill_data_manager:FindWearWuJi(2, wuji_index) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_wuji_cant_equip_again"), 2)
    end
    return
  end
  for i = 0, WUJI_NUM - 1 do
    if nx_number(grid:GetItemName(i)) == wuji_index then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_wuji_cant_equip_again"), 2)
      end
      return
    end
  end
  if not game_hand.IsDropped then
    grid:SetItemImage(nx_int(index), photo)
    grid:SetItemName(nx_int(index), nx_widestr(wuji_index))
    gui.GameHand.IsDropped = true
    if nx_number(grid.DataSource) == 1 then
      form.btn_ok_1.Enabled = true
    else
      form.btn_ok_2.Enabled = true
    end
    hide_empty_pic(form)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "hide_empty_pic", form)
    end
  end
  gui.GameHand:ClearHand()
end
function on_btn_ok_click(self)
  equip_wuji(self)
end
function equip_wuji(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(self.DataSource) == 1 then
    for i = 0, WUJI_NUM - 1 do
      local market = nx_int(form.imagegrid_wuji_1:GetItemMark(i))
      local wuji_index = nx_number(form.imagegrid_wuji_1:GetItemName(i))
      if market == nx_int(GRID_EMPTY) and wuji_index ~= 0 then
        nx_execute("custom_sender", "custom_jingmai_wuji_msg", MSG_CLIENT_WUJI_WEAR, nx_number(self.DataSource), wuji_index, nx_int(i))
      end
    end
  else
    for i = 0, WUJI_NUM - 1 do
      local market = nx_int(form.imagegrid_wuji_2:GetItemMark(i))
      local wuji_index = nx_number(form.imagegrid_wuji_2:GetItemName(i))
      if market == nx_int(GRID_EMPTY) and wuji_index ~= 0 then
        nx_execute("custom_sender", "custom_jingmai_wuji_msg", MSG_CLIENT_WUJI_WEAR, nx_number(self.DataSource), wuji_index, nx_int((WUJI_PAGE_INDEX - 1) * WUJI_NUM + i))
      end
    end
  end
  self.Enabled = false
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function reset_one_wuji(wuji_type, pos)
  local gui = nx_value("gui")
  local ask_dialog = util_get_form("form_common\\form_confirm", true, false)
  ask_dialog.Left = (gui.Width - ask_dialog.Width) / 2
  ask_dialog.Top = (gui.Height - ask_dialog.Height) / 2
  local text = nx_widestr(util_text("ui_wuji_spent_faculty3"))
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  ask_dialog:ShowModal()
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  local cur_page = WUJI_PAGE_INDEX
  if wuji_type == 1 then
    cur_page = 1
  end
  if res == "ok" then
    nx_execute("custom_sender", "custom_jingmai_wuji_msg", MSG_CHIENT_WUJI_CLEAR_ONE, wuji_type, (cur_page - 1) * WUJI_NUM + pos)
  end
end
function on_btn_reset_click(self)
  local gui = nx_value("gui")
  local ask_dialog = util_get_form("form_common\\form_confirm", true, false)
  ask_dialog.Left = (gui.Width - ask_dialog.Width) / 2
  ask_dialog.Top = (gui.Height - ask_dialog.Height) / 2
  local wuji_type = nx_number(self.DataSource)
  local text = nx_widestr(util_text("ui_wuji_spent_faculty1"))
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  ask_dialog:ShowModal()
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_jingmai_wuji_msg", MSG_CLIENT_WUJI_CLEAR, wuji_type)
  end
end
function on_btn_reset_solt_click(btn)
  local gui = nx_value("gui")
  local ask_dialog = util_get_form("form_common\\form_confirm", true, false)
  ask_dialog.Left = (gui.Width - ask_dialog.Width) / 2
  ask_dialog.Top = (gui.Height - ask_dialog.Height) / 2
  local text = nx_widestr(util_text("ui_wuji_spent_faculty2"))
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
  ask_dialog:ShowModal()
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_jingmai_wuji_msg", MSG_CHIENT_WUJI_DEL_SLOT)
  end
end
function on_btn_prev_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  equip_wuji_confirm(form)
  if WUJI_PAGE_INDEX - 1 <= 0 then
    return
  end
  WUJI_PAGE_INDEX = WUJI_PAGE_INDEX - 1
  btn.ParentForm.lbl_7.Text = nx_widestr(WUJI_PAGE_INDEX)
  btn.ParentForm.imagegrid_wuji_2:Clear()
  refresh_second_wear_wuji(btn.ParentForm)
end
function on_btn_next_page_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  equip_wuji_confirm(form)
  if WUJI_PAGE_INDEX + 1 > WUJI_PAGE_TOTAL_NUM then
    return
  end
  WUJI_PAGE_INDEX = WUJI_PAGE_INDEX + 1
  btn.ParentForm.lbl_7.Text = nx_widestr(WUJI_PAGE_INDEX)
  refresh_second_wear_wuji(btn.ParentForm)
end
function equip_wuji_confirm(form)
  if not nx_is_valid(form) then
    return
  end
  if form.btn_ok_2.Enabled then
    local gui = nx_value("gui")
    local ask_dialog = util_get_form("form_common\\form_confirm", true, false)
    ask_dialog.Left = (gui.Width - ask_dialog.Width) / 2
    ask_dialog.Top = (gui.Height - ask_dialog.Height) / 2
    local text = nx_widestr(util_text("ui_wuji_equip_confirm"))
    nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, text)
    ask_dialog:ShowModal()
    local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
    if res == "ok" then
      equip_wuji(form.btn_ok_2)
    end
  end
end
