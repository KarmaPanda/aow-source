require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("form_stage_main\\form_offline\\offline_define")
local TYPE_FREE = 1
local TYPE_PAY = 2
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
  update_form_pos(form)
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function update_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function show_window(prize_type, item_id, num, money_type, money, name, desc)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_job_interact_prize", true, false)
  show_prize(form, prize_type, item_id, num, money_type, money, name, desc)
  form:Show()
end
function hide_window(off_id, item_id)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_offline\\form_offline_job_interact_prize", true, false)
  form:Close()
end
function on_btn_get_prize_click(btn)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_GET_FEE_PRIZE))
  end
end
function show_prize(form, prize_type, item_id, num, money_type, money, name, desc)
  form.imagegrid_prize:Clear()
  form.groupbox_money.Visible = false
  form.lbl_title_job.Text = nx_widestr(name)
  form.mltbox_interact_prize_desc.HtmlText = nx_widestr("<s>") .. nx_widestr(util_text(desc))
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(item_id), "Photo")
  form.imagegrid_prize:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(num), 0)
  if nx_number(prize_type) == nx_number(TYPE_PAY) then
    form.lbl_money.Text = trans_capital_string(money)
    form.groupbox_money.Visible = true
  end
end
function on_imagegrid_prize_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_prize_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
  if 0 >= table.getn(table_prop_name) then
    return
  end
  table_prop_value.ConfigID = nx_string(prize_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  table_prop_value.Amount = prize_count
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", nx_current())
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32, grid.ParentForm)
end
