require("share\\view_define")
require("define\\gamehand_type")
require("share\\client_custom_define")
local CL_POS_INDEX_NONE = 0
local CL_POS_INDEX_HAT = 1
local CL_POS_INDEX_CLOTH = 2
local CL_POS_INDEX_PANTS = 3
local CL_POS_INDEX_SHOES = 4
local CL_POS_INDEX_CARD = 5
local CL_POS_INDEX_MAX = 6
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Top = (gui.Height - form.Height) / 2 - 40
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_CLOTHES_HANGER_BOX, form, "form_stage_main\\form_home\\form_clothes_hanger", "on_clothes_hanger_viewport_changed")
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
  nx_destroy(form)
end
function on_clothes_hanger_viewport_changed(form, optype, view_ident, index)
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
    for i = 1, count do
      local item_obj = view:GetViewObjByIndex(i - 1)
      if nx_is_valid(item_obj) then
        local pos_index = GetMatchedPos(item_obj)
        if nx_number(pos_index) > CL_POS_INDEX_NONE and nx_number(pos_index) < CL_POS_INDEX_MAX then
          local control_name = "imagegrid_" .. nx_string(pos_index)
          local imagegrid = form:Find(control_name)
          if nx_is_valid(imagegrid) then
            local photo = nx_execute("util_static_data", "queryprop_by_object", item_obj, "Photo")
            imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
          end
        end
      end
    end
  elseif optype == "additem" then
    local viewobj = view:GetViewObj(nx_string(index))
    if not nx_is_valid(viewobj) then
      return
    end
    local control_name = "imagegrid_" .. nx_string(index)
    local imagegrid = form:Find(control_name)
    if nx_is_valid(imagegrid) then
      local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
      imagegrid:AddItem(0, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
    end
  elseif optype == "delitem" then
    local control_name = "imagegrid_" .. nx_string(index)
    local imagegrid = form:Find(control_name)
    if nx_is_valid(imagegrid) then
      imagegrid:Clear()
    end
  end
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
    if not IsMatchedPos(viewobj, grid.DataSource) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "home_jiaju_001")
      return
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), 0, nx_int(src_viewid), nx_int(src_pos), nx_int(grid.DataSource))
    gui.GameHand:ClearHand()
  end
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
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), 1, nx_int(grid.DataSource))
end
function on_imagegrid_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_CLOTHES_HANGER_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(grid.DataSource))
  if nx_is_valid(viewobj) then
    nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, form)
  end
end
function on_imagegrid_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function IsMatchedPos(item, pos)
  if not nx_is_valid(item) then
    return false
  end
  if nx_number(pos) <= CL_POS_INDEX_NONE or nx_number(pos) >= CL_POS_INDEX_MAX then
    return false
  end
  local pos_index = GetMatchedPos(item)
  if nx_number(pos_index) ~= nx_number(pos) then
    return false
  end
  return true
end
function GetMatchedPos(item)
  if not nx_is_valid(item) then
    return CL_POS_INDEX_NONE
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return CL_POS_INDEX_NONE
  end
  local config_id = nx_execute("util_static_data", "get_prop_in_object", item, "ConfigID")
  local script = ItemQuery:GetItemPropByConfigID(config_id, "script")
  if nx_string(script) == nx_string("Equipment") then
    if not item:FindProp("EquipType") then
      return CL_POS_INDEX_NONE
    end
    local equip_type = item:QueryProp("EquipType")
    if nx_string(equip_type) == nx_string("Hat") then
      return CL_POS_INDEX_HAT
    elseif nx_string(equip_type) == nx_string("Cloth") then
      return CL_POS_INDEX_CLOTH
    elseif nx_string(equip_type) == nx_string("Pants") then
      return CL_POS_INDEX_PANTS
    elseif nx_string(equip_type) == nx_string("Shoes") then
      return CL_POS_INDEX_SHOES
    end
  elseif nx_string(script) == nx_string("CardItem") then
    return CL_POS_INDEX_CARD
  end
  return CL_POS_INDEX_NONE
end
