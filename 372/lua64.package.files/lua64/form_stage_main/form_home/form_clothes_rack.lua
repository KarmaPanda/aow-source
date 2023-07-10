require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\client_custom_define")
require("share\\view_define")
require("define\\gamehand_type")
local CLIENT_MSG = {
  CLIENT_MSG_HEAD = CLIENT_CUSTOMMSG_FURNITURE,
  SUBMSG_OPEN_CLOTHES_RACK = 16,
  SUBMSG_PUSH_CLOTHES_CARD = 17,
  SUBMSG_POP_CLOTHES_CARD = 18
}
local FIXED_CONTAINER_POSITION = 1
function CanOperation()
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return false
  end
  return HomeManager:IsMyHome()
end
function open_form(...)
  if not CanOperation() then
    return
  end
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.Desktop:ToFront(form)
  end
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
  return
end
function main_form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.Fixed = false
  return
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = form.Width / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_CLOTHES_RACK_BOX, form, "form_stage_main\\form_home\\form_clothes_rack", "on_clothes_rack_viewport_changed")
  return
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
  gui.Focused = nx_null()
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
  return
end
local IsLegalItem = function(item)
  if not nx_is_valid(item) then
    return false
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  local config_id = nx_execute("util_static_data", "get_prop_in_object", item, "ConfigID")
  local script = ItemQuery:GetItemPropByConfigID(config_id, "script")
  if nx_string(script) ~= nx_string("CardItem") then
    return false
  end
  return true
end
function on_imagegrid_select_changed(grid, index)
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
    if not IsLegalItem(viewobj) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "home_jiaju_001")
      return
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_MSG.CLIENT_MSG_HEAD), nx_int(CLIENT_MSG.SUBMSG_PUSH_CLOTHES_CARD), nx_int(src_viewid), nx_int(src_pos), nx_int(FIXED_CONTAINER_POSITION))
    gui.GameHand:ClearHand()
  end
  return
end
function on_imagegrid_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_CLOTHES_RACK_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(FIXED_CONTAINER_POSITION))
  if nx_is_valid(viewobj) then
    nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, form)
  end
  return
end
function on_imagegrid_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
  return
end
function on_imagegrid_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_CLOTHES_RACK_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(FIXED_CONTAINER_POSITION))
  if not nx_is_valid(viewobj) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_MSG.CLIENT_MSG_HEAD), nx_int(CLIENT_MSG.SUBMSG_POP_CLOTHES_CARD), FIXED_CONTAINER_POSITION)
  return
end
function on_clothes_rack_viewport_changed(form, optype, view_ident, index)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  if optype == "createview" then
    local count = view:GetViewObjCount()
    if 0 < count then
      local item_obj = view:GetViewObjByIndex(0)
      if nx_is_valid(item_obj) then
        local imagegrid = form:Find("imagegrid_" .. FIXED_CONTAINER_POSITION)
        if nx_is_valid(imagegrid) then
          local photo = nx_execute("util_static_data", "queryprop_by_object", item_obj, "Photo")
          imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
        end
      end
    end
  elseif optype == "additem" then
    local viewobj = view:GetViewObj(nx_string(index))
    if not nx_is_valid(viewobj) then
      return
    end
    local imagegrid = form:Find("imagegrid_" .. FIXED_CONTAINER_POSITION)
    if nx_is_valid(imagegrid) then
      local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
      imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
    end
  elseif optype == "delitem" then
    local imagegrid = form:Find("imagegrid_" .. FIXED_CONTAINER_POSITION)
    if nx_is_valid(imagegrid) then
      imagegrid:Clear()
    end
  end
  return
end
