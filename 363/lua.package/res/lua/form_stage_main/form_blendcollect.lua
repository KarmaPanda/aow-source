require("utils")
require("util_functions")
require("util_gui")
require("util_static_data")
require("role_composite")
require("share\\view_define")
require("share\\itemtype_define")
require("define\\gamehand_type")
require("share\\item_static_data_define")
local BLEND_COLLECT_REC = "blend_collect_rec"
local BLENDCOLLECT_REC_COL_CONFIGID = 0
local BLENDCOLLECT_REC_COL_OWNNUM = 1
local BLENDCOLLECT_REC_COL_USEDNUM = 2
local BLENDCOLLECT_REC_COL_ACTIVE = 3
local BLENDCOLLECT_REC_COL_COUNT = 4
local TABTYPE_HEAD = ITEMTYPE_HUANPIHEAD
local TABTYPE_CLOTH = ITEMTYPE_HUANPICLOTH
local TABTYPE_PANTS = ITEMTYPE_HUANPIPANTS
local TABTYPE_SHOES = ITEMTYPE_HUANPISHOES
function on_main_form_init(form)
  form.Fixed = false
  form.collect_list = nil
  form.nCurShowType = TABTYPE_HEAD
  form.nPageRecordNum = nx_int(18)
  form.nMaxRecordNum = nx_int(0)
  form.curPageNum = nx_int(1)
  form.nMaxPageNum = nx_int(0)
end
function on_main_form_open(form)
  form.collect_list = nx_call("util_gui", "get_arraylist", "blendcollect:collect_list")
  add_data_bind(form)
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = (gui.Height - form.Height) / 2
  hide_all_infinitelabel(form)
end
function on_main_form_close(form)
  del_data_bind(form)
  if nx_is_valid(form.collect_list) then
    form.collect_list:ClearChild()
    nx_destroy(form.collect_list)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_head_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.nCurShowType = TABTYPE_HEAD
    SwitchToPage(form, 1)
  end
end
function on_rbtn_cloth_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.nCurShowType = TABTYPE_CLOTH
    SwitchToPage(form, 1)
  end
end
function on_rbtn_pants_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.nCurShowType = TABTYPE_PANTS
    SwitchToPage(form, 1)
  end
end
function on_rbtn_shoes_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.nCurShowType = TABTYPE_SHOES
    SwitchToPage(form, 1)
  end
end
function on_btn_prev_click(btn)
  local form = btn.ParentForm
  if nx_int(form.curPageNum) <= nx_int(1) then
    form.curPageNum = 1
  else
    form.curPageNum = form.curPageNum - 1
  end
  SwitchToPage(form, form.curPageNum)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if nx_int(form.curPageNum) >= nx_int(form.nMaxPageNum) then
    form.curPageNum = form.nMaxPageNum
  else
    form.curPageNum = form.curPageNum + 1
  end
  SwitchToPage(form, form.curPageNum)
end
function on_btn_exhibit_click(btn)
  nx_execute("form_stage_main\\form_blendexhibit", "open_form")
end
function on_imagegrid_items_mousein_grid(grid, index)
  local form = grid.ParentForm
  if grid:IsEmpty(index) then
    return
  end
  local real_index = (form.curPageNum - 1) * form.nPageRecordNum + index
  local count = form.collect_list:GetChildCount()
  if nx_int(real_index) >= nx_int(count) then
    return
  end
  local child = form.collect_list:GetChildByIndex(real_index)
  local configid = child.configid
  if nx_string(configid) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = configid
  item.ItemType = ItemQuery:GetItemPropByConfigID(nx_string(configid), "ItemType")
  item.BindStatus = ItemQuery:GetItemPropByConfigID(nx_string(configid), "BindStatus")
  nx_execute("tips_game", "show_goods_tip", item, x, y, 0, 0, form)
end
function on_imagegrid_items_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_items_select_changed(grid, index)
  on_imagegrid_items_rightclick_grid(grid, index)
end
function on_imagegrid_items_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if grid:IsEmpty(index) then
    return
  end
  local form_equipblend = nx_value("form_stage_main\\form_equipblend")
  if not nx_is_valid(form_equipblend) then
    return
  end
  local real_index = (form.curPageNum - 1) * form.nPageRecordNum + index
  local count = form.collect_list:GetChildCount()
  if nx_int(real_index) >= nx_int(count) then
    return
  end
  local child = form.collect_list:GetChildByIndex(real_index)
  local configid = child.configid
  if nx_string(configid) == nx_string("") then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if nx_is_valid(ItemQuery) then
    local bindstatus = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("BindStatus"))
    if nx_int(bindstatus) == nx_int(1) then
      local gui = nx_value("gui")
      local info = gui.TextManager:GetText("ui_huanpi_tishi_9")
      local res = util_form_confirm("", info)
      if res ~= "ok" then
        return
      end
    end
  end
  nx_execute("custom_sender", "custom_equipblend_freight", configid)
end
function add_data_bind(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(BLEND_COLLECT_REC, form, nx_current(), "on_table_rec_changed")
  end
end
function del_data_bind(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(BLEND_COLLECT_REC, form)
  end
end
function on_table_rec_changed(form, rec_name, opt_type, row, col)
  if nx_int(col) == nx_int(BLENDCOLLECT_REC_COL_USEDNUM) or nx_int(col) == nx_int(BLENDCOLLECT_REC_COL_ACTIVE) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_panel", form)
    timer:Register(500, 1, nx_current(), "on_refresh_panel", form, -1, -1)
  end
end
function on_refresh_panel(form, param1, param2)
  SwitchToPage(form, form.curPageNum)
end
function SwitchToPage(form, index)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  local collect_table = get_collect_table(form.nCurShowType)
  form.curPageNum = nx_int(index)
  form.nMaxRecordNum = nx_int(table.getn(collect_table))
  form.nMaxPageNum = nx_int((form.nMaxRecordNum + form.nPageRecordNum - 1) / form.nPageRecordNum)
  form.lbl_toufang.Text = nx_widestr(gui.TextManager:GetFormatText("ui_tab_shouji_tishi", nx_int(form.nMaxRecordNum), get_suit_nums(form.nCurShowType)))
  form.imagegrid_items:Clear()
  form.imagegrid_items:SetSelectItemIndex(-1)
  form.btn_prev.Enabled = true
  form.btn_next.Enabled = true
  if nx_int(form.curPageNum) <= nx_int(1) then
    form.btn_prev.Enabled = false
  end
  if nx_int(form.curPageNum) >= nx_int(form.nMaxPageNum) then
    form.btn_next.Enabled = false
  end
  hide_all_infinitelabel(form)
  if nx_int(index) < nx_int(1) or nx_int(index) > nx_int(form.nMaxPageNum) then
    form.curPageNum = nx_int(1)
    set_page_num(form, form.curPageNum, form.nMaxPageNum)
    return
  end
  set_page_num(form, form.curPageNum, form.nMaxPageNum)
  local begin_index = (index - 1) * form.nPageRecordNum + 1
  local end_index = begin_index + form.nPageRecordNum - 1
  end_index = end_index <= form.nMaxRecordNum and end_index or form.nMaxRecordNum
  for i = begin_index, end_index do
    local child = collect_table[i]
    local photo = get_photo(child.configid)
    form.imagegrid_items:AddItem(i - begin_index, photo, "", child.amount, -1)
    local lbl_wxflag = get_wxflag_label(i - begin_index + 1)
    if nx_is_valid(lbl_wxflag) then
      lbl_wxflag.Visible = false
      local is_infinite = ItemQuery:GetItemPropByConfigID(nx_string(child.configid), nx_string("InfiniteBlend"))
      if nx_int(is_infinite) == nx_int(1) then
        lbl_wxflag.Visible = true
      end
    end
  end
  form.collect_list:ClearChild()
  for i = 1, table.getn(collect_table) do
    local child = collect_table[i]
    local item = form.collect_list:CreateChild("")
    item.configid = nx_string(child.configid)
    item.amount = nx_int(child.amount)
  end
end
function set_page_num(form, curpage, maxpage)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(curpage) < nx_int(1) then
    curpage = nx_int(1)
  end
  if nx_int(maxpage) < nx_int(1) then
    maxpage = nx_int(1)
  end
  form.lbl_pagenum.Text = nx_widestr(curpage) .. nx_widestr("/") .. nx_widestr(maxpage)
end
function get_collect_table(show_type)
  local collect_table = {}
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return collect_table
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return collect_table
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return collect_table
  end
  if not client_player:FindRecord(BLEND_COLLECT_REC) then
    return collect_table
  end
  local rows = client_player:GetRecordRows(BLEND_COLLECT_REC)
  for i = 0, rows - 1 do
    local configid = client_player:QueryRecord(BLEND_COLLECT_REC, i, BLENDCOLLECT_REC_COL_CONFIGID)
    local amount = client_player:QueryRecord(BLEND_COLLECT_REC, i, BLENDCOLLECT_REC_COL_OWNNUM)
    if nx_int(amount) > nx_int(0) then
      local item_type = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("ItemType"))
      if nx_int(item_type) == nx_int(show_type) then
        local item = {}
        item.configid = nx_string(configid)
        item.amount = nx_int(amount)
        table.insert(collect_table, item)
      end
    end
  end
  return collect_table
end
function get_photo(configid)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("ItemType"))
  if nx_number(item_type) < ITEMTYPE_HUANPIMIN and nx_number(item_type) > ITEMTYPE_HUANPIMAX then
    return ""
  end
  local art_pack = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("ArtPack"))
  local photo = nx_string(item_static_query(nx_int(art_pack), "Photo", STATIC_DATA_ITEM_ART))
  local sex = client_player:QueryProp("Sex")
  if sex ~= 0 then
    local photo1 = nx_string(item_static_query(nx_int(art_pack), "FemalePhoto", STATIC_DATA_ITEM_ART))
    if photo1 ~= nil and photo1 ~= nx_string("") then
      photo = photo1
    end
  end
  return photo
end
function get_wxflag_label(index)
  local form = nx_value("form_stage_main\\form_blendcollect")
  if not nx_is_valid(form) then
    return nil
  end
  local lbl_wxflag = "lbl_wxflag_" .. nx_string(index)
  if not nx_find_custom(form, lbl_wxflag) then
    return nil
  end
  return nx_custom(form, lbl_wxflag)
end
function hide_all_infinitelabel(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, form.nPageRecordNum do
    local lbl_wxflag = get_wxflag_label(i)
    if nx_is_valid(lbl_wxflag) then
      lbl_wxflag.Visible = false
    end
  end
end
function get_suit_nums(part_type)
  local parts = {
    [TABTYPE_HEAD] = "Hat",
    [TABTYPE_CLOTH] = "Cloth",
    [TABTYPE_PANTS] = "Pants",
    [TABTYPE_SHOES] = "Shoes"
  }
  if nx_int(part_type) ~= nx_int(TABTYPE_HEAD) and nx_int(part_type) ~= nx_int(TABTYPE_CLOTH) and nx_int(part_type) ~= nx_int(TABTYPE_PANTS) and nx_int(part_type) ~= nx_int(TABTYPE_SHOES) then
    return
  end
  part_type = nx_number(part_type)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local sex = client_player:QueryProp("Sex")
  local ini = nx_execute("util_functions", "get_ini", "share\\item\\huanpi_suits.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local count = 0
  for i = 0, ini:GetSectionCount() - 1 do
    local suit_sex = ini:ReadInteger(i, "Sex", 0)
    if nx_int(sex) == nx_int(suit_sex) then
      local part_name = nx_string(ini:ReadString(i, parts[part_type], ""))
      if nx_string(part_name) ~= nx_string("") then
        count = count + 1
      end
    end
  end
  return nx_int(count)
end
function open_form()
  local form_blendcollect = nx_value("form_stage_main\\form_blendcollect")
  if nx_is_valid(form_blendcollect) then
    util_show_form("form_stage_main\\form_blendcollect", false)
  else
    util_show_form("form_stage_main\\form_blendcollect", true)
  end
end
