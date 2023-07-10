require("define\\tip_define")
require("share\\itemtype_define")
require("share\\static_data_type")
require("share\\item_static_data_define")
require("util_static_data")
require("util_gui")
require("util_functions")
require("tips_data")
require("utils")
require("custom_sender")
require("form_stage_main\\form_origin_new\\new_origin_define")
require("form_stage_main\\form_origin\\form_origin_define")
local CLIENT_CUSTOMMSG_ORIGIN = 703
local SUB_CUSTOMMSG_REQUEST_ORIGIN_HISTORY_LIST = 0
local temp_origin_tbl = {}
function refresh_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_PERSON, false, false)
  if not nx_is_valid(form) then
    return
  end
  request_list(form.pageno)
end
function main_form_init(self)
  self.Fixed = true
  self.pageno = 1
  self.page_next_ok = 1
  self.is_show_tips = true
end
function on_main_form_open(self)
  request_list(self.pageno)
end
function on_main_form_close(self)
  self:Close()
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if form.pageno > 1 then
    request_list(form.pageno - 1)
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if 0 < form.page_next_ok then
    request_list(form.pageno + 1)
  end
end
function request_list(pageno)
  local from = (nx_int(pageno) - 1) * 6
  local to = pageno * 6
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ORIGIN), nx_int(SUB_CUSTOMMSG_REQUEST_ORIGIN_HISTORY_LIST), from, to)
end
function on_recv_list(from, to, rowcount, ...)
  local form = nx_value("form_stage_main\\form_origin_new\\form_new_origin_person")
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size <= 0 or size % 5 ~= 0 then
    return 0
  end
  if from < 0 or from == to then
    form.page_next_ok = 0
    return 0
  end
  local pageno_count_per = 6
  form.page_next_ok = 1
  form.pageno = from / pageno_count_per + 1
  local nowpage = nx_string(form.pageno)
  local maxpage = "/" .. nx_string(math.ceil(rowcount / 6))
  form.lbl_pageno.Text = nx_widestr(nowpage .. maxpage)
  local rows = size / 5
  if 6 < rows then
    rows = 6
  end
  temp_origin_tbl = {}
  for i = 1, rows do
    local base = (i - 1) * 5
    table.insert(temp_origin_tbl, {
      arg[base + 1],
      arg[base + 2],
      arg[base + 3],
      arg[base + 4],
      arg[base + 5]
    })
  end
  for i = 1, 10 do
    local btn_name = "btn_origin_" .. nx_string(i)
    local btn = form.groupbox_1:Find(btn_name)
    if nx_is_valid(btn) then
      btn.Text = nx_widestr("")
      if nx_find_custom(btn, "origin_id") then
        nx_set_custom(btn, "origin_id", 0)
      end
    end
  end
  for i = 1, table.getn(temp_origin_tbl) do
    local btn_name = "btn_origin_" .. nx_string(i)
    local btn = form.groupbox_1:Find(btn_name)
    local origin_id = temp_origin_tbl[i][1]
    local desc = "origin_" .. nx_string(origin_id)
    if nx_is_valid(btn) then
      btn.Text = nx_widestr(util_text(desc))
      btn.origin_id = temp_origin_tbl[i][1]
      btn.scene_id = temp_origin_tbl[i][2]
      btn.x = temp_origin_tbl[i][3]
      btn.z = temp_origin_tbl[i][4]
      btn.get_time = temp_origin_tbl[i][5]
    end
  end
end
function on_recv_base_info(...)
  local form = nx_value("form_stage_main\\form_origin_new\\form_new_origin_person")
  if not nx_is_valid(form) then
    return 0
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  form.lbl_total_origins.Text = nx_widestr(arg[1])
  local cur_achieve = arg[2]
  form.lbl_cur_achieve.Text = nx_widestr(cur_achieve)
  form.lbl_CurValue.Text = nx_widestr(arg[3])
  form.lbl_GetValue.Text = nx_widestr(arg[4]) .. nx_widestr("/") .. nx_widestr(arg[5])
  form.lbl_WeekRemainValue.Text = nx_widestr(arg[6])
  local tbl = origin_manager:GetNeedAchieve(nx_int(cur_achieve))
  local length = table.getn(tbl)
  local need_achieve = 0
  local prize_id = ""
  if length == 2 then
    need_achieve = tbl[1]
    prize_id = tbl[2]
  end
  if need_achieve == 0 then
    local gui = nx_value("gui")
    form.lbl_need_achieve.Text = gui.TextManager:GetText("sys_neworigin_cj_top")
    prize_id = ""
    form.is_show_tips = false
  else
    form.lbl_need_achieve.Text = nx_widestr(need_achieve)
    form.is_show_tips = true
  end
  local max_achieve = origin_manager:GetMaxAchieve()
  form.lbl_total_achieve.Text = nx_widestr(max_achieve)
  form.pbar_1.Value = nx_number(cur_achieve / max_achieve) * 100
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local grid = form.imagegrid_prize
  goods_grid:GridClear(grid)
  local item_id = prize_id
  local item_count = 1
  local item_type = nx_number(get_prop_in_ItemQuery(item_id, nx_string("ItemType")))
  local item_data = nx_create("ArrayList", nx_current())
  if not nx_is_valid(item_data) then
    return
  end
  item_data.ConfigID = item_id
  item_data.Count = item_count
  item_data.item_type = item_type
  goods_grid:GridAddItem(grid, 0, item_data)
  grid:SetBindIndex(0, 1)
  local photo = ""
  if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    photo = item_query_ArtPack_by_id(item_id, "Photo")
  else
    photo = get_prop_in_ItemQuery(item_id, nx_string("Photo"))
  end
  grid:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
end
function on_btn_get_capture(btn)
  local form = btn.ParentForm
  if not nx_find_custom(btn, "origin_id") then
    return
  end
  local origin_id = btn.origin_id
  if nx_int(origin_id) <= nx_int(0) then
    return
  end
  local gui = nx_value("gui")
  local form_tips = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_origin_new\\form_new_origin_person_tips", true, false)
  if nx_is_valid(form_tips) then
    form_tips:Show()
    form_tips.Visible = true
    form_tips.lbl_scene_id.Text = nx_widestr("")
    form_tips.lbl_x.Text = nx_widestr("")
    form_tips.lbl_time.Text = nx_widestr("")
    local year, month, day, h, m, s = nx_function("util_time_utc_to_local", nx_number(btn.get_time))
    form_tips.lbl_scene_id.Text = nx_widestr(gui.TextManager:GetText("ui_scene_" .. nx_string(btn.scene_id)))
    form_tips.lbl_x.Text = nx_widestr("(") .. nx_widestr(nx_int(btn.x)) .. nx_widestr(",") .. nx_widestr(nx_int(btn.z)) .. nx_widestr(")")
    form_tips.lbl_time.Text = nx_widestr(year) .. nx_widestr("-") .. nx_widestr(month) .. nx_widestr("-") .. nx_widestr(day) .. nx_widestr(" ") .. nx_widestr(h) .. nx_widestr(":") .. nx_widestr(m) .. nx_widestr(":") .. nx_widestr(s)
    form_tips.AbsLeft = btn.AbsLeft
    form_tips.AbsTop = btn.AbsTop - btn.Height / 2
  end
end
function on_btn_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  util_show_form("form_stage_main\\form_origin_new\\form_new_origin_person_tips", false)
end
function on_btn_back_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  local mainform = nx_value(FORM_NEW_ORIGIN_MAIN)
  if nx_is_valid(mainform) then
    nx_execute(FORM_NEW_ORIGIN_MAIN, "open_subform", mainform, FORM_TYPE_MAIN)
  end
end
function on_imagegrid_prize_get_capture(grid, index)
  local form = grid.ParentForm
  if form.is_show_tips == false then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if nx_is_valid(item_data) then
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  else
    nx_execute("tips_game", "hide_tip", grid.ParentForm)
  end
end
function on_imagegrid_prize_lost_capture(grid, index)
  local form = grid.ParentForm
  if form.is_show_tips == false then
    return
  end
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
