require("util_gui")
require("util_functions")
require("const_define")
require("share\\view_define")
require("game_object")
require("define\\object_type_define")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2 * 1 / 2
  self.Top = (gui.Height - self.Height) / 4
  self.item_config = ""
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_server_msg(...)
  local type = arg[1]
  if type == "open" then
    util_show_form("form_stage_main\\form_task\\form_jianghu_gouhuo", true)
  elseif type == "close" then
    local form = util_get_form("form_stage_main\\form_task\\form_jianghu_gouhuo")
    if nx_is_valid(form) then
      form:Close()
    end
  end
end
function on_imagegrid_1_select_changed(grid, index)
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
  gui.GameHand:ClearHand()
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_id = viewobj:QueryProp("ConfigID")
  local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
  form.imagegrid_1:AddItem(index, photo, "", 1, 0)
  form.item_config = item_id
end
function on_ipt_1_changed(ipt)
end
function on_btn_add_fire_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JIANGHU_GOUHUO), form.item_config, nx_int(form.ipt_1.Text))
  form:Close()
end
