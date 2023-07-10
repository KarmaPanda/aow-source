require("util_gui")
require("util_static_data")
require("define\\gamehand_type")
require("form_stage_main\\form_sweet_employ\\form_offline_employee_utils")
local Form_Name = "form_stage_main\\form_sweet_employ\\form_offline_wuxue_learn"
local Parent_Form = "form_stage_main\\form_sweet_employ\\form_offline_sub_employee"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
end
function on_main_form_close(form)
end
function open_form()
  local form = nx_value(Form_Name)
  if nx_is_valid(form) then
    form:Close()
  end
  form = util_get_form(Form_Name, true, false)
  change_form_size(form)
  form:Show()
  form.Visible = true
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
end
function change_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local parent_form = nx_value(Parent_Form)
  if not nx_is_valid(parent_form) then
    form.AbsLeft = (gui.Width - form.Width) / 2
    form.AbsTop = (gui.Height - form.Height) / 2
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = parent_form.AbsTop + (parent_form.Height - form.Height) / 2
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
  nx_destroy(form)
end
function on_imagegrid_book_mousein_grid(grid, index)
  if not nx_find_custom(grid, "persistid") then
    return
  end
  nx_execute("tips_game", "show_goods_tip", grid.persistid, grid:GetMouseInItemLeft() + 10, grid:GetMouseInItemTop() + 10, 32, 32, grid.ParentForm)
end
function on_imagegrid_book_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_book_rightclick_grid(grid, index)
  if not nx_find_custom(grid, "persistid") then
    return
  end
  if grid.persistid ~= -1 then
    local form = grid.ParentForm
    reset_grid(form, nil)
  end
end
function on_imagegrid_book_select_changed(grid, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local src_viewid = nx_int(gui.GameHand.Para1)
  local src_pos = nx_int(gui.GameHand.Para2)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(src_viewid))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(src_pos))
  if not nx_is_valid(viewobj) then
    return
  end
  if not can_learn(grid, viewobj) then
    return
  end
  gui.GameHand:ClearHand()
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
  reset_grid(form, viewobj)
  on_imagegrid_book_mousein_grid(form.imagegrid_book, 0)
end
function on_imagegrid_book_doubleclick_grid(grid, index)
  if not nx_find_custom(grid, "persistid") then
    return
  end
  if grid.persistid ~= -1 then
    local form = grid.ParentForm
    reset_grid(form, nil)
  end
end
function on_drop_in_imagegrid_book(grid, index)
  local gui = nx_value("gui")
  local gamehand = gui.GameHand
  if gamehand.IsDragged and not gamehand.IsDropped then
    on_imagegrid_book_select_changed(grid, index)
    gamehand.IsDropped = true
  end
end
function can_learn(grid, viewobj)
  if not nx_is_valid(viewobj) then
    return false
  end
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    return false
  end
  if gui.GameHand.Type ~= GHT_VIEWITEM then
    return false
  end
  local bind = 0
  if nx_is_valid(viewobj) then
    bind = viewobj:QueryProp("BindStatus")
    if nx_int(bind) > nx_int(0) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7043"))
      gui.GameHand:ClearHand()
      return false
    end
  end
  if nx_is_valid(viewobj) and viewobj:FindProp("ItemType") then
    local item_type = viewobj:QueryProp("ItemType")
    if nx_int(item_type) ~= nx_int(21) and nx_int(item_type) ~= nx_int(23) and nx_int(item_type) ~= nx_int(2017) and nx_int(item_type) ~= nx_int(2019) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("11369"))
      gui.GameHand:ClearHand()
      return false
    end
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_int(client_player:QueryProp("StallState")) == nx_int(2) then
    gui.GameHand:ClearHand()
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7040"))
    return false
  end
  return true
end
function reset_grid(form, viewobj)
  if nx_is_valid(viewobj) then
    local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
    form.imagegrid_book:AddItem(0, nx_string(photo), "", 1, -1)
    form.imagegrid_book.persistid = viewobj
  else
    form.imagegrid_book:Clear()
    form.imagegrid_book.persistid = -1
  end
end
function on_btn_learn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form.imagegrid_book, "persistid") then
    return
  end
  local item = form.imagegrid_book.persistid
  if not nx_is_valid(item) then
    return
  end
  local configID = item:QueryProp("ConfigID")
  nx_execute("custom_sender", "custom_offline_employ", nx_number(7), nx_string(configID))
  reset_grid(form, nil)
  return
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
