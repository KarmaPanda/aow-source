require("share\\view_define")
require("define\\gamehand_type")
require("share\\client_custom_define")
require("share\\chat_define")
require("util_gui")
require("util_functions")
local SUBMSG_CLIENT_ADDITEM_SELL = 1
local SUBMSG_CLIENT_REMOVE_SELL = 2
local SUBMSG_CLIENT_CANCEL_SELL = 3
local SUBMSG_CLINET_CONFIRM_SELL = 4
local SUBMSG_CLINET_CHANGE_NAME = 12
local SELL_SERVICE_PRICE_RATE = 1
local TYPE_SYSTEM = 0
local TYPE_PLAYER = 1
local money_ding_wen = 1000000
local money_siliver_wen = 1000
function main_form_init(form)
  form.Fixed = false
  form.npcid = nil
  form.amount = 0
  form.item_config_id = ""
  form.item_UniqueID = ""
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.grid_put:SetBindIndex(0, 1)
  form.grid_put.typeid = VIEWPORT_HIRESHOP_ADDITEM
  form.grid_put.canselect = true
  form.grid_put.candestroy = false
  form.grid_put.cansplit = false
  form.grid_put.canlock = false
  form.grid_put.canarrange = false
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_HIRESHOP_ADDITEM, form.grid_put, "form_stage_main\\form_hire_shop\\form_hire_shop_additem", "on_additem_view_oper")
  databinder:AddRolePropertyBind("ShopState", "int", form, nx_current(), "set_shop_state")
  form.amount = 0
  return 1
end
function on_additem_view_oper(grid, op_type, view_ident, index)
  if not nx_is_valid(grid) then
    return false
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return false
  end
  if op_type == "createview" then
    GoodsGrid:GridClear(grid)
  elseif op_type == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif op_type == "additem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif op_type == "delitem" then
    GoodsGrid:ViewDeleteItem(grid, index)
  elseif op_type == "updateitem" then
    GoodsGrid:ViewUpdateItem(grid, index)
  end
  return true
end
function set_shop_state(form)
  local game_client = nx_value("game_client")
  local ident = nx_string(form.npcid)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return false
  end
  local ShopState = npc:QueryProp("ShopState")
  if ShopState == 1 then
    form.btn_ShouTan.Visible = true
    form.btn_ChuTan.Visible = false
  else
    form.btn_ShouTan.Visible = false
    form.btn_ChuTan.Visible = true
  end
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(SUBMSG_CLIENT_CANCEL_SELL))
  end
  if nx_is_valid(form) then
    nx_destroy(form)
    nx_set_value("form_stage_main\\form_hire_shop\\form_hire_shop_additem", nx_null())
  end
end
function on_grid_put_select_changed(grid, index)
  local gui = nx_value("gui")
  local selected_index = grid:GetSelectItemIndex()
  local dest_pos = 1
  local dest_viewid = grid.typeid
  local form = grid.ParentForm
  if gui.GameHand:IsEmpty() then
    return false
  end
  if not grid:IsEmpty(selected_index) then
    return false
  end
  if gui.GameHand.Type == GHT_VIEWITEM and grid.typeid > 0 then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local amount = nx_int(gui.GameHand.Para3)
    form.amount = amount
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return false
    end
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(src_viewid))
    local viewobj = view:GetViewObj(nx_string(src_pos))
    if not nx_is_valid(viewobj) then
      return
    end
    local bind = 0
    if viewobj:FindProp("BindStatus") then
      bind = viewobj:QueryProp("BindStatus")
      if nx_int(bind) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7043"))
        return
      end
    end
    local cant_exchange = 0
    if viewobj:FindProp("CantExchange") then
      cant_exchange = viewobj:QueryProp("CantExchange")
      if nx_int(cant_exchange) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
        return
      end
    end
    local lock_status = 0
    if viewobj:FindProp("LockStatus") then
      lock_status = viewobj:QueryProp("LockStatus")
      if nx_int(lock_status) > nx_int(0) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7054"))
        return
      end
    end
    if nx_number(src_viewid) ~= VIEWPORT_EQUIP_TOOL and nx_number(src_viewid) ~= VIEWPORT_TOOL and nx_number(src_viewid) ~= VIEWPORT_MATERIAL_TOOL and nx_number(src_viewid) ~= VIEWPORT_TASK_TOOL then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
      return
    end
    if viewobj:FindProp("ConfigID") then
      form.item_config_id = viewobj:QueryProp("ConfigID")
    else
      form.item_config_id = ""
    end
    if viewobj:FindProp("UniqueID") then
      form.item_UniqueID = viewobj:QueryProp("UniqueID")
    else
      form.item_UniqueID = ""
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(SUBMSG_CLIENT_ADDITEM_SELL), nx_int(src_viewid), nx_int(src_pos), nx_int(dest_viewid), nx_int(dest_pos), form.npcid)
    gui.GameHand:ClearHand()
  end
end
function on_grid_put_right_click(grid, index)
  if grid:IsEmpty(index) then
    return false
  end
  local view_index = grid:GetBindIndex(index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local form = grid.ParentForm
  form.amount = 0
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(SUBMSG_CLIENT_REMOVE_SELL), nx_int(view_index), form.npcid)
end
function on_grid_put_mousein_grid(grid, index)
  local form = grid.ParentForm
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
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_HIRESHOP_ADDITEM))
  if nx_is_valid(view) then
    local bind_index = grid:GetBindIndex(index)
    local viewobj = view:GetViewObj(nx_string(bind_index))
    nx_execute("form_stage_main\\form_life\\form_job_main_new", "chang_life_skill_photo", viewobj)
  end
  if grid:IsEmpty(index) then
    return false
  end
  local item_data = grid.Data:GetChild(nx_string(index))
  if not nx_is_valid(item_data) then
    return false
  end
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft() + 32, grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_grid_put_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_ok_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local grid = form.grid_put
  if grid:IsEmpty(0) then
    local info = gui.TextManager:GetText("37010")
    local form_main_chat_logic = nx_value("form_main_chat")
    if nx_is_valid(form_main_chat_logic) then
      form_main_chat_logic:AddChatInfoEx(info, CHATTYPE_SYSTEM, false)
    end
    return false
  end
  local ding = nx_int(form.ipt_price_ding.Text)
  local liang = nx_int(form.ipt_price_liang.Text)
  local wen = nx_int(form.ipt_price_wen.Text)
  local silver = ding * money_ding_wen + liang * money_siliver_wen + wen
  if silver <= 0 then
    local info = gui.TextManager:GetText("37011")
    local form_main_chat_logic = nx_value("form_main_chat")
    if nx_is_valid(form_main_chat_logic) then
      form_main_chat_logic:AddChatInfoEx(info, CHATTYPE_SYSTEM, false)
    end
    return false
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  text = nx_widestr(gui.TextManager:GetFormatText("ui_offline_form_sell_inputbox_title01", nx_int(ding), nx_int(liang), nx_int(wen)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  if not nx_is_valid(form) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(SUBMSG_CLINET_CONFIRM_SELL), silver, form.npcid)
  form.ipt_price_ding.Text = nx_widestr("")
  form.ipt_price_liang.Text = nx_widestr("")
  form.ipt_price_wen.Text = nx_widestr("")
  form.ipt_cost_ding.Text = nx_widestr("0")
  form.ipt_cost_liang.Text = nx_widestr("0")
  form.ipt_cost_wen.Text = nx_widestr("0")
  form.amount = 0
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) and nx_find_method(form_logic, "SaveFightInfoToFile") then
    form_logic:SaveStallPriceInfo(nx_widestr("hireshop:") .. nx_widestr(form.item_config_id) .. nx_widestr("/") .. nx_widestr(form.item_UniqueID) .. nx_widestr("/") .. nx_widestr(nx_int(nx_number(silver) / 1000000)) .. nx_widestr("/") .. nx_widestr(nx_int(nx_number(silver) % 1000000 / 1000)) .. nx_widestr("/") .. nx_widestr(nx_int(nx_number(silver) % 1000)) .. nx_widestr("/"))
  end
end
function on_ipt_changed(ipt)
  local form = ipt.ParentForm
  local ding = nx_int(form.ipt_price_ding.Text)
  local liang = nx_int(form.ipt_price_liang.Text)
  local wen = nx_int(form.ipt_price_wen.Text)
  local silver = ding * money_ding_wen + liang * money_siliver_wen + wen
  silver = silver * form.amount
  local d = nx_int(silver / money_ding_wen)
  local l = nx_int((silver - d * money_ding_wen) / money_siliver_wen)
  local w = silver - d * money_ding_wen - l * money_siliver_wen
  form.ipt_cost_ding.Text = nx_widestr(d)
  form.ipt_cost_liang.Text = nx_widestr(l)
  form.ipt_cost_wen.Text = nx_widestr(w)
end
function on_btn_ShouTan_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(9), nx_int(0), form.npcid)
end
function on_btn_ChuTan_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(9), nx_int(1), form.npcid)
end
function DeleteFontColor(text)
  local retText
  local format = "<font.->(.-)</font>"
  retText = string.gsub(text, format, "%1")
  return retText
end
function on_btn_change_click(btn)
  local form = btn.ParentForm
  local name = form.ipt_name.Text
  local puff = form.ipt_yaohe.Text
  local npc_id = form.npcid
  puff = DeleteFontColor(nx_string(puff))
  local CheckWords = nx_value("CheckWords")
  local filter_name = CheckWords:CleanWords(nx_widestr(name))
  local filter_puff = CheckWords:CleanWords(nx_widestr(puff))
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(SUBMSG_CLINET_CHANGE_NAME), npc_id, filter_name, filter_puff, nx_int(TYPE_PLAYER))
end
function init_shop_info(form)
  local game_client = nx_value("game_client")
  local ident = nx_string(form.npcid)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return false
  end
  local shop_name = npc:QueryProp("HireShopName")
  local shop_cryout = npc:QueryProp("ShopCryOut")
  local game_client = nx_value("game_client")
  local client_role = game_client:GetPlayer()
  if not nx_is_valid(client_role) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local gui = nx_value("gui")
  local bNeedChange = false
  if nx_widestr(shop_name) == nx_widestr("") or nx_widestr(shop_name) == nx_widestr("0") then
    bNeedChange = true
    shop_name = gui.TextManager:GetFormatText("ui_stall_mingcheng", nx_widestr(client_role:QueryProp("Name")))
  end
  if nx_widestr(shop_cryout) == nx_widestr("") or nx_widestr(shop_cryout) == nx_widestr("0") then
    bNeedChange = true
    shop_cryout = gui.TextManager:GetText("ui_stall_yaohe")
  end
  if bNeedChange then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HIRE_SHOP), nx_int(SUBMSG_CLINET_CHANGE_NAME), form.npcid, nx_widestr(shop_name), nx_widestr(shop_cryout), nx_int(TYPE_SYSTEM))
  end
  form.ipt_name.Text = nx_widestr(shop_name)
  form.ipt_yaohe.Text = nx_widestr(shop_cryout)
end
