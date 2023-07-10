require("util_functions")
require("define\\gamehand_type")
require("util_gui")
require("share\\itemtype_define")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("custom_sender")
require("share\\view_define")
local sortString = ""
local SelectNode = ""
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2 - 40
  form.btn_fuse.Visible = true
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_JOB_COMPOUND, form.ImageControlGrid, "form_stage_main\\form_life\\form_fuse_wuxue", "on_compound_box_change")
  end
  form.ImageControlGrid.typeid = VIEWPORT_JOB_COMPOUND
  for i = 1, 10 do
    form.ImageControlGrid:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form.ImageControlGrid)
  end
  nx_destroy(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  nx_execute("custom_sender", "custom_cancel_compound")
end
function on_compound_box_change(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "additem" or optype == "updateitem" or optype == "delitem" then
    local viewobj = view:GetViewObj(nx_string(index))
    ShowItem(form, view, viewobj, index)
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    nx_execute("form_stage_main\\form_bag", "refresh_lock_item", form_bag)
  end
  return 1
end
function ShowItem(form, view, viewobj, index)
  if not nx_is_valid(viewobj) then
    form.ImageControlGrid:DelItem(index - 1)
    form.lbl_price.Text = ""
  else
    local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
    form.ImageControlGrid:AddItem(index - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
    if nx_is_valid(view) then
      local itemFirst = view:GetViewObj(nx_string(1))
      local itemSecond = view:GetViewObj(nx_string(2))
      if not nx_is_valid(itemFirst) or not nx_is_valid(itemSecond) then
        return
      end
      if itemFirst:QueryProp("ConfigID") == itemSecond:QueryProp("ConfigID") then
        local fuse_ini = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_book.ini")
        local sec_index = fuse_ini:FindSectionIndex(itemFirst:QueryProp("ConfigID"))
        local Money = 0
        if 0 <= sec_index then
          Money = fuse_ini:ReadString(sec_index, "Money", "")
        end
        local gui = nx_value("gui")
        local ding = math.floor(Money / 1000000)
        local liang = math.floor(Money % 1000000 / 1000)
        local wen = math.floor(Money % 1000)
        local htmlTextYinZi = nx_widestr("")
        if 0 < ding then
          local text = gui.TextManager:GetText("ui_ding")
          local htmlText = nx_widestr(text)
          htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(htmlText)
        end
        if 0 < liang then
          local text = gui.TextManager:GetText("ui_liang")
          local htmlText = nx_widestr(text)
          htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
        end
        if 0 < wen then
          local text = gui.TextManager:GetText("ui_wen")
          local htmlText = nx_widestr(text)
          htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
        end
        if Money == 0 then
          htmlTextYinZi = htmlTextYinZi .. nx_widestr("0")
        end
        form.lbl_price.Text = nx_widestr(htmlTextYinZi)
      else
        form.lbl_price.Text = ""
      end
    end
  end
end
function on_compound_form_open(job_id)
  local form = util_get_form("form_stage_main\\form_life\\form_fuse_wuxue", true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.job_id = job_id
  util_auto_show_hide_form("form_stage_main\\form_life\\form_fuse_wuxue")
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_fuse_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_start_compound")
end
function on_btn_cancel_click(btn)
  nx_execute("custom_sender", "custom_cancel_compound")
end
function on_imagegrid_compound_rightclick_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_COMPOUND))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    nx_execute("custom_sender", "custom_remove_compound_item", index + 1)
  end
end
function on_imagegrid_compound_select_changed(grid)
  local gui = nx_value("gui")
  local selected_index = grid:GetSelectItemIndex()
  if gui.GameHand:IsEmpty() then
    return
  end
  if not grid:IsEmpty(selected_index) then
    return
  end
  if gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local amount = nx_int(gui.GameHand.Para3)
    nx_execute("custom_sender", "custom_add_compound_item", src_viewid, src_pos, selected_index + 1)
    gui.GameHand:ClearHand()
  end
end
function on_imagegrid_compound_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_COMPOUND))
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
function on_imagegrid_compound_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function clear_backImage(form)
  form.ImageControlGrid:Clear()
end
