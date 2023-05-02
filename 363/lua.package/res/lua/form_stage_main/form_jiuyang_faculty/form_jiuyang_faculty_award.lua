require("util_static_data")
require("util_functions")
require("custom_sender")
require("form_stage_main\\form_tvt\\define")
require("util_gui")
require("share\\view_define")
eShowAwardForm = 1
SELECT_ALL_NORMAL_AWARD = 1
local FORM_JIUYANG_FACULTY_AWARD = "form_stage_main\\form_jiuyang_faculty\\form_jiuyang_faculty_award"
MAX_NORMAL_BOX = 7
function open_form(type)
  local form = util_auto_show_hide_form(FORM_JIUYANG_FACULTY_AWARD)
  if not nx_is_valid(form) then
    return
  end
  local bg = ""
  if nx_int(type) == nx_int(1) then
    bg = "gui\\special\\jiuyangshengong\\fajiangjiemian\\xiulianchenggong.png"
  elseif nx_int(type) == nx_int(2) then
    bg = "gui\\special\\jiuyangshengong\\fajiangjiemian\\xiulianshibai.png"
  elseif nx_int(type) == nx_int(3) then
    bg = "gui\\special\\jiuyangshengong\\fajiangjiemian\\ruqinchenggong.png"
  elseif nx_int(type) == nx_int(4) then
    bg = "gui\\special\\jiuyangshengong\\fajiangjiemian\\ruqinshibai.png"
  end
  if nx_find_custom(form, "lbl_bg") then
    form.lbl_bg.BackImage = bg
  end
end
function on_main_form_open(form)
  change_form_layout_pos(form)
  refresh_form(form)
end
function change_form_layout_pos(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = 0.5 * (gui.Width - form.Width)
  form.Top = 0.3 * (gui.Height - form.Height)
end
function refresh_form(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_JIUYANG_NORMAL_AWARD, form, nx_current(), "on_awards_viewport_change")
  end
end
function on_awards_viewport_change(form, optype, view_ident, index)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_jiuyang_awards_viewport_change", form)
    timer:Register(200, 1, nx_current(), "on_jiuyang_awards_viewport_change", form, -1, -1)
  end
end
function on_jiuyang_awards_viewport_change(form, ...)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JIUYANG_NORMAL_AWARD))
  if not nx_is_valid(view) then
    for var = 1, MAX_NORMAL_BOX do
      form.imagegrid_normal:DelItem(nx_int(var - 1))
    end
    return 1
  end
  for var = 1, MAX_NORMAL_BOX do
    reset_normal_drop_box(form, view, var)
  end
end
function on_main_form_close(self)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat")
  if nx_is_valid(dialog) then
    dialog:Close()
  end
  nx_destroy(self)
end
function reset_normal_drop_box(form, view, index)
  form.imagegrid_normal:DelItem(nx_int(index - 1))
  local viewobj = view:GetViewObj(nx_string(index))
  if nx_is_valid(viewobj) then
    form.imagegrid_normal:DelItem(nx_int(index))
    local item_config = viewobj:QueryProp("ConfigID")
    local item_count = viewobj:QueryProp("Amount")
    local item_color_level = viewobj:QueryProp("ColorLevel")
    local ItemQuery = nx_value("ItemQuery")
    local item_photo = item_query_ArtPack_by_id(nx_string(item_config), nx_string("Photo"))
    if not nx_is_valid(ItemQuery) then
      return
    end
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
    if bExist == false then
      return
    end
    form.imagegrid_normal:AddItem(nx_int(index - 1), nx_string(item_photo), nx_widestr(item_name), nx_int(item_count), nx_int(0))
  end
end
function ShowCloseInfo(form)
  if not nx_is_valid(form) then
    return true
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat")
  if not nx_is_valid(dialog) then
    return true
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return true
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return true
  end
  local view_normal = game_client:GetView(nx_string(VIEWPORT_JIUYANG_NORMAL_AWARD))
  local msgid = nx_string("")
  if nx_is_valid(view_normal) then
    local viewobj_list = view_normal:GetViewObjList()
    local count = table.maxn(viewobj_list)
    if 0 < count then
      msgid = nx_string("ui_jiuyang_award")
    else
      return true
    end
  end
  local strInfo = gui.TextManager:GetText(msgid)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, strInfo)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  return res == "ok"
end
function on_btn_gain_all_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_jiuyang_faculty", nx_int(4))
end
function on_btn_close_click(self)
  local form = self.Parent
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JIUYANG_NORMAL_AWARD))
  if nx_is_valid(view) and not ShowCloseInfo(form) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_jiuyang_faculty", nx_int(6))
  form:Close()
end
function on_imagegrid_normal_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JIUYANG_NORMAL_AWARD))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if not nx_is_valid(viewobj) then
    return
  end
  nx_execute("tips_game", "show_3d_tips_one", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm, true)
end
function on_imagegrid_normal_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
