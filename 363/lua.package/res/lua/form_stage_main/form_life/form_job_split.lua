require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
local SPLIT_BACK_IMAGE = "gui\\special\\fenjie\\guangxiao2.png"
local MATERIAL_BACK_IMAGE = "gui\\special\\fenjie\\guangxiao1.png"
local FORM_TITLE = {
  sh_tj = "ui_splititem3",
  sh_jq = "ui_splititem4",
  sh_cf = "ui_splititem5",
  sh_ys = "ui_splititem",
  sh_ds = "ui_splititem",
  treasure = "treasure_menu_101",
  treasuresplit = "treasure_menu_101",
  home_manger = "ui_splititem1"
}
function main_form_init(form)
  form.Fixed = false
  form.ItemUniqueID = nil
  form.ItemID = nil
  form.CancelSplit = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Top = (gui.Height - form.Height) / 2 - 40
  form.ImgCtl_SplitItem:Clear()
  form.ImgCtl_SplitItem.BackImage = ""
  for index = 1, 8 do
    local ImageGrid = form:Find("imagegrid_" .. nx_string(index))
    if nx_is_valid(ImageGrid) then
      ImageGrid.BackImage = ""
      ImageGrid.binditemid = nil
      ImageGrid:Clear()
    end
  end
  if nx_find_custom(form, "jobid") then
    local text = FORM_TITLE[nx_string(form.jobid)]
    if text ~= nil then
      form.lbl_title.Text = nx_widestr(util_text(text))
    end
  end
  if nx_string(form.jobid) == nx_string("treasuresplit") then
    form.btn_split.Text = nx_widestr("@ui_splititem_bw_dd")
  else
    form.btn_split.Text = nx_widestr("@ui_splititem")
  end
  form.btn_split.Visible = true
  form.btn_cancel.Visible = false
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_SPLIT_ITEM_BOX, form, "form_stage_main\\form_life\\form_job_split", "on_split_viewport_changed")
end
function on_main_form_close(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) and form_talk.Visible then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_talk")
  if nx_is_valid(form_talk) and form_talk.Visible then
    form_talk:Close()
  end
  nx_execute("custom_sender", "custom_remove_split_item")
  nx_destroy(form)
end
function on_split_viewport_changed(form, optype, view_ident, index)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  if optype == "additem" then
    local viewobj = view:GetViewObj(nx_string(index))
    if not nx_is_valid(viewobj) then
      return
    end
    refresh_form_show(form, viewobj)
  elseif optype == "delitem" then
    reset_control(form)
  end
end
function on_btn_split_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.ItemUniqueID == nil or form.ItemUniqueID == "" then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_TOOL))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  for index, view_item in pairs(viewobj_list) do
    local unique_id = view_item:QueryProp("UniqueID")
    if nx_string(form.ItemUniqueID) == nx_string(unique_id) then
      form.CancelSplit = true
      nx_execute("custom_sender", "custom_split_item")
      return
    end
  end
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "81203")
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.CancelSplit then
    return
  end
  form.CancelSplit = false
  nx_execute("custom_sender", "custom_cancel_split_item")
end
function right_click_add_SplitItem(packid, grid, index, photo)
  local gui = nx_value("gui")
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local item, job_id, money_list, money2 = get_drop_item_list(packid)
  if item == "" then
    return
  end
  if not nx_find_custom(form, "jobid") then
    return
  end
  if nx_string(form.jobid) ~= nx_string(job_id) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "81202")
    return
  end
  local item_lv = item:QueryProp("ColorLevel")
  local money = 0
  local money_table = util_split_string(nx_string(money_list), ",")
  if item_lv > table.getn(money_table) or item_lv < 1 then
    money = nx_number(money_table[table.getn(money_table)])
  else
    money = nx_number(money_table[item_lv])
  end
  local money2 = 0
  local money2_table = util_split_string(nx_string(money2_list), ",")
  if item_lv > table.getn(money2_table) or item_lv < 1 then
    money2 = nx_number(money2_table[table.getn(money2_table)])
  else
    money2 = nx_number(money2_table[item_lv])
  end
  nx_msgbox(nx_string(money2))
  local money_text = get_money_format(money)
  form.lbl_money.HtmlText = nx_widestr(money_text)
  form.lbl_money2.HtmlText = nx_widestr("")
  if money2 ~= 0 then
    local yyb = "<img src=\"gui\\common\\money\\yyb.png\" valign=\"center\" only=\"line\" data=\"\" />"
    form.lbl_money2.HtmlText = nx_widestr(yyb) .. nx_widestr(" ") .. nx_widestr(get_money_format(money2))
  end
  grid:AddItem(index, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
  grid:ShowItemAddInfo(index, 0, true)
  grid.BackImage = SPLIT_BACK_IMAGE
  grid:SetItemBackImage(0, " ")
  local ItemQuery = nx_value("ItemQuery")
  local itemid_list = util_split_string(nx_string(item), ",")
  local randdata = get_random_data(2, table.getn(itemid_list))
  for i = 1, table.getn(itemid_list) do
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(itemid_list[i]), "Photo")
    local ImageGrid = form:Find("imagegrid_" .. nx_string(randdata[i]))
    ImageGrid:AddItem(0, nx_string(photo), nx_widestr(itemid_list[i]), 1, -1)
    ImageGrid.binditemid = itemid_list[i]
    ImageGrid.BackImage = MATERIAL_BACK_IMAGE
    ImageGrid:SetItemBackImage(0, " ")
    ImageGrid:ChangeItemImageToBW(nx_int(0), true)
  end
end
function on_ImgCtl_SplitItem_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not gui.GameHand:IsEmpty() and gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local src_amount = nx_int(gui.GameHand.Para3)
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    if not nx_is_valid(view) then
      return
    end
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    if nx_string(viewobj:QueryProp("UniqueID")) == nx_string(form.ItemUniqueID) then
      gui.GameHand:ClearHand()
      return
    end
    if not check_can_split_item(form, viewobj) then
      return
    end
    nx_execute("custom_sender", "custom_add_split_item", nx_int(src_viewid), nx_int(src_pos))
    gui.GameHand:ClearHand()
  end
end
function on_ImgCtl_SplitItem_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SPLIT_ITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    viewobj.view_obj = viewobj
    nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_ImgCtl_SplitItem_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_ImgCtl_SplitItem_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_remove_split_item")
end
function on_imagegrid_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "binditemid") then
    return
  end
  local itemid = grid.binditemid
  if itemid ~= nil and itemid ~= "" then
    nx_execute("tips_game", "show_tips_by_config", nx_string(itemid), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), form)
  else
    nx_execute("tips_game", "hide_tip", form)
  end
end
function on_imagegrid_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function get_drop_item_list(packid)
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\LifeSplitItemInfo.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\Life\\LifeSplitItemInfo.ini " .. get_msg_str("msg_120"))
    return 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(packid))
  if sec_index < 0 then
    return ""
  end
  local item_list = ini:ReadString(sec_index, "DropItemList", "")
  local job_id = ini:ReadString(sec_index, "JobID", "")
  local money_list = ini:ReadString(sec_index, "Money", "")
  local money2_list = ini:ReadString(sec_index, "Money2", "")
  return item_list, job_id, money_list, money2_list
end
function reset_control(form)
  if not nx_is_valid(form) then
    return
  end
  form.ImgCtl_SplitItem:Clear()
  form.ImgCtl_SplitItem.BackImage = ""
  for index = 1, 8 do
    local ImageGrid = form:Find("imagegrid_" .. nx_string(index))
    if nx_is_valid(ImageGrid) then
      ImageGrid.BackImage = ""
      ImageGrid.binditemid = nil
      ImageGrid:Clear()
    end
  end
  form.lbl_money.HtmlText = nx_widestr("")
  form.lbl_money2.HtmlText = nx_widestr("")
  form.ItemUniqueID = nil
  form.ItemID = nil
  form.CancelSplit = false
end
function get_money_format(money)
  local text = nx_widestr("")
  if money <= 0 then
    text = nx_widestr("0") .. nx_widestr(util_text("ui_bag_wen"))
    return text
  end
  local gold = money / 1000000
  gold = math.floor(gold)
  local silver = (money - gold * 1000000) / 1000
  local silver = math.floor(silver)
  local copper = money - silver * 1000 - gold * 1000000
  if gold ~= 0 then
    text = nx_widestr(gold) .. nx_widestr(util_text("ui_bag_ding"))
  end
  if silver ~= 0 then
    text = nx_widestr(text) .. nx_widestr(silver) .. nx_widestr(util_text("ui_bag_liang"))
  end
  if copper ~= 0 then
    text = nx_widestr(text) .. nx_widestr(copper) .. nx_widestr(util_text("ui_bag_wen"))
  end
  return text
end
function get_random_data(maxdata, needRand)
  local results = {}
  for k = 1, needRand do
    results[k] = k
  end
  if nx_int(needRand) <= nx_int(0) then
    return results
  end
  if nx_int(maxdata) < nx_int(needRand) then
    return results
  end
  local begin = {}
  for i = 1, maxdata do
    begin[i] = i
  end
  for j = 1, needRand do
    local index = math.random(maxdata - j + 1)
    results[j] = begin[index]
    begin[index] = begin[maxdata - j + 1]
  end
  return results
end
function Set_Split_Control_State(form, state)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "SelectObject") then
    local item = form.SelectObject
    if nx_is_valid(item) and not item:FindProp("LifeSplitItemPackage") then
      return
    end
  end
  local image = form.ImgCtl_SplitItem:GetItemBackImage(0)
  if nx_string(image) ~= nx_string("") then
    return
  end
  if state then
    form.ImgCtl_SplitItem.BackImage = "xuanzekuang"
  else
    form.ImgCtl_SplitItem.BackImage = ""
  end
end
function process_break_btn_show(form, show)
  if show == 1 then
    form.btn_split.Visible = false
    form.btn_cancel.Visible = true
  else
    form.btn_split.Visible = true
    form.btn_cancel.Visible = false
  end
end
function check_can_split_item(form, item)
  if not nx_is_valid(item) then
    return false
  end
  local bind_form = util_get_form("form_stage_main\\form_life\\form_job_bind_type_confirm", false)
  if nx_is_valid(bind_form) and bind_form.Visible then
    return false
  end
  if not item:FindProp("LifeSplitItemPackage") then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 1, "81201")
    return false
  end
  local packid = item:QueryProp("LifeSplitItemPackage")
  if nx_int(packid) <= nx_int(0) then
    return false
  end
  local dropitem, job_id, money_list, money2_list = get_drop_item_list(packid)
  if dropitem == "" then
    return false
  end
  if not nx_find_custom(form, "jobid") then
    return false
  end
  if nx_string(form.jobid) ~= nx_string(job_id) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "81202")
    return false
  end
  return true
end
function refresh_form_show(form, item)
  if not nx_is_valid(item) then
    return
  end
  if not check_can_split_item(form, item) then
    return
  end
  form.ItemUniqueID = item:QueryProp("UniqueID")
  form.ItemID = item:QueryProp("ConfigID")
  local packid = item:QueryProp("LifeSplitItemPackage")
  local dropitem, job_id, money_list, money2_list = get_drop_item_list(packid)
  local item_lv = item:QueryProp("ColorLevel")
  local money = 0
  local money_table = util_split_string(nx_string(money_list), ",")
  if item_lv > table.getn(money_table) or item_lv < 1 then
    money = nx_number(money_table[table.getn(money_table)])
  else
    money = nx_number(money_table[item_lv])
  end
  local money2 = 0
  local money2_table = util_split_string(nx_string(money2_list), ",")
  if item_lv > table.getn(money2_table) or item_lv < 1 then
    money2 = nx_number(money2_table[table.getn(money2_table)])
  else
    money2 = nx_number(money2_table[item_lv])
  end
  local money_text = get_money_format(money)
  form.lbl_money.HtmlText = nx_widestr(money_text)
  form.lbl_money2.HtmlText = nx_widestr("")
  if money2 ~= 0 then
    local yyb = "<img src=\"gui\\common\\money\\yyb.png\" valign=\"center\" only=\"line\" data=\"\" />"
    form.lbl_money2.HtmlText = nx_widestr(yyb) .. nx_widestr(" ") .. nx_widestr(get_money_format(money2))
  end
  local photo = nx_execute("util_static_data", "queryprop_by_object", item, "Photo")
  form.ImgCtl_SplitItem:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
  form.ImgCtl_SplitItem:ShowItemAddInfo(0, 0, true)
  form.ImgCtl_SplitItem.BackImage = SPLIT_BACK_IMAGE
  form.ImgCtl_SplitItem:SetItemBackImage(0, " ")
  local ItemQuery = nx_value("ItemQuery")
  local itemid_list = util_split_string(nx_string(dropitem), ",")
  local randdata = get_random_data(2, table.getn(itemid_list))
  for i = 1, table.getn(itemid_list) do
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(itemid_list[i]), "Photo")
    local ImageGrid = form:Find("imagegrid_" .. nx_string(randdata[i]))
    ImageGrid:AddItem(0, nx_string(photo), nx_widestr(itemid_list[i]), 1, -1)
    ImageGrid.binditemid = itemid_list[i]
    ImageGrid.BackImage = MATERIAL_BACK_IMAGE
    ImageGrid:SetItemBackImage(0, " ")
    ImageGrid:ChangeItemImageToBW(nx_int(0), true)
  end
end
function add_split_item(viewid, pos)
  local split_form = util_get_form("form_stage_main\\form_life\\form_job_split", false)
  if not nx_is_valid(split_form) or not split_form.Visible then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(viewid))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(pos))
  if not nx_is_valid(viewobj) then
    return
  end
  if nx_string(viewobj:QueryProp("UniqueID")) == nx_string(split_form.ItemUniqueID) then
    return
  end
  if not check_can_split_item(split_form, viewobj) then
    return
  end
  nx_execute("custom_sender", "custom_add_split_item", nx_int(viewid), nx_int(pos))
end
