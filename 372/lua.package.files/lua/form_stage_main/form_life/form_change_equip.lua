require("util_functions")
require("define\\gamehand_type")
require("util_gui")
require("share\\itemtype_define")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("custom_sender")
require("share\\client_custom_define")
require("share\\view_define")
local m_Path = "form_stage_main\\form_life\\form_change_equip"
local sortString = ""
local SelectNode = ""
nothing = 0
yang_gang = 1
ying_rou = 2
tai_ji = 3
all = 4
function main_form_init(form)
  form.Fixed = false
  form.npc_id = ""
  form.selective_shuxi = nothing
  form.unchang_shuxi = nothing
  form.money = 0
  form.yb1 = 0
  form.yb2 = 0
  form.yb_text1 = ""
  form.yb_text2 = ""
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2 - 40
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_CHANGEEQUIPATT_BOX, form.imagegrid_contribute, m_Path, "on_contribute_box_change")
  end
  for i = 1, 10 do
    form.imagegrid_contribute:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  form.lbl_contribute_desc.Text = nx_widestr("  ") .. nx_widestr(gui.TextManager:GetText("ui_change_equip"))
  refurbish_yb(form, 0)
  form.lbl_7.Visible = false
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form.imagegrid_contribute)
  end
  nx_destroy(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  nx_execute("custom_sender", "custom_cancel_change_equip")
end
function on_main_form_visible(form)
  if form.Visible == false then
    form:Close()
  end
end
function on_contribute_box_change(grid, optype, view_ident, index)
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
  elseif optype == "additem" or optype == "delitem" or optype == "updateitem" then
    local viewobj = view:GetViewObj(nx_string(index))
    init_form(form)
    ShowItem(form, view, viewobj, index, optype)
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    nx_execute("form_stage_main\\form_bag", "refresh_lock_item", form_bag)
  end
  return 1
end
function a(info)
  nx_msgbox(nx_string(info))
end
function ShowItem(form, view, viewobj, index, optype)
  if not nx_is_valid(viewobj) then
    form.imagegrid_contribute:DelItem(index - 1)
  else
    local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
    form.imagegrid_contribute:AddItem(index - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
    local lv = viewobj:QueryProp("ColorLevel")
    local lv2 = viewobj:QueryProp("Level")
    local money_int = get_ini("share\\Item\\Propconv_cost.ini")
    local count = money_int:GetSectionCount()
    for i = 0, count do
      if money_int:ReadString(i, "ColorLevel", "") == nx_string(lv) and money_int:ReadString(i, "Level", "") == nx_string(lv2) then
        local str_consume_1 = money_int:ReadString(i, "Consume1", "")
        local str_consume_2 = money_int:ReadString(i, "Consume2", "")
        local tab_consume1 = util_split_string(str_consume_1, ",")
        local tab_consume2 = util_split_string(str_consume_2, ",")
        form.yb1 = nx_string(tab_consume1[3])
        form.yb_text1 = nx_string(tab_consume1[2])
        form.yb2 = nx_string(tab_consume2[3])
        form.yb_text2 = nx_string(tab_consume2[2])
        break
      end
    end
    refurbish_yb(form, get_yb(form))
  end
  if optype == "updateitem" then
    local fuse_formula_query = nx_value("FuseFormulaQuery")
    if not nx_is_valid(fuse_formula_query) then
      return
    else
      local wx_formula = fuse_formula_query:GetZbProperty(viewobj)
      if nx_string(wx_formula) == "unfind" then
        form.unchang_shuxi = all
      elseif nx_string(wx_formula) == "tai_ji" then
        form.unchang_shuxi = tai_ji
      elseif nx_string(wx_formula) == "yang_gang" then
        form.unchang_shuxi = yang_gang
      elseif nx_string(wx_formula) == "ying_rou" then
        form.unchang_shuxi = ying_rou
      end
      makeBtn_fail(form)
    end
  end
  if optype == "delitem" then
    makeBtn_succes(form)
  end
end
function makeBtn_fail(form)
  if form.unchang_shuxi == all then
    form.groupbox_3.Visible = false
  elseif form.unchang_shuxi == tai_ji then
    form.btn_4.Visible = false
    form.btn_5.Visible = false
    form.btn_6.Visible = false
    form.lbl_3.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_taiji_on.png"
  elseif form.unchang_shuxi == yang_gang then
    form.btn_7.Visible = false
    form.btn_8.Visible = false
    form.btn_9.Visible = false
    form.lbl_4.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yanggang_on.png"
  elseif form.unchang_shuxi == ying_rou then
    form.btn_1.Visible = false
    form.btn_2.Visible = false
    form.btn_3.Visible = false
    form.btn_10.Visible = false
    form.lbl_2.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yinrou_on.png"
  end
end
function makeBtn_succes(form)
  if form.unchang_shuxi == all then
    form.groupbox_3.Visible = true
  elseif form.unchang_shuxi == tai_ji then
    form.btn_4.Visible = true
    form.btn_5.Visible = true
    form.btn_6.Visible = true
    form.lbl_3.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_taiji_out.png"
  elseif form.unchang_shuxi == yang_gang then
    form.btn_7.Visible = true
    form.btn_8.Visible = true
    form.btn_9.Visible = true
    form.lbl_4.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yanggang_out.png"
  elseif form.unchang_shuxi == ying_rou then
    form.btn_1.Visible = true
    form.btn_2.Visible = true
    form.btn_3.Visible = true
    form.btn_10.Visible = true
    form.lbl_2.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yinrou_out.png"
  end
  form.unchang_shuxi = nothing
  form.sc = 0
end
function init_form(form)
  form.money = 0
  refurbish_yb(form, 0)
  if form.selective_shuxi ~= nothing then
    changed_select(form)
    form.selective_shuxi = nothing
  end
end
function refurbish_money(form, money)
  local yd = math.floor(money / 1000000)
  local yl = math.floor(money % 1000000 / 1000)
  local wen = money % 1000
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local yd_text = nx_widestr("")
  local yl_text = nx_widestr("")
  local wen_text = nx_widestr("")
  if yd == 0 and yl == 0 and wen == 0 then
    yl_text = nx_widestr(yl) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText("ui_change_equip_yl"))
  else
    if yd ~= 0 then
      yd_text = nx_widestr(yd) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText("ui_change_equip_yd")) .. nx_widestr("  ")
    end
    if yl ~= 0 then
      yl_text = nx_widestr(yl) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText("ui_change_equip_yl")) .. nx_widestr("  ")
    end
    if wen ~= 0 then
      wen_text = nx_widestr(wen) .. nx_widestr(" ") .. nx_widestr(gui.TextManager:GetText("ui_change_equip_wen"))
    end
  end
  form.lbl_6.HtmlText = nx_widestr(yd_text) .. nx_widestr(yl_text) .. nx_widestr(wen_text)
end
function refurbish_yb(form, yb)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_6:Clear()
  if nx_string("0") == nx_string(yb) then
    gui.TextManager:Format_SetIDName("ui_change_equip_tips")
    form.lbl_6:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
  else
    gui.TextManager:Format_SetIDName("ui_change_equip_fy")
    gui.TextManager:Format_AddParam(gui.TextManager:GetText(form.yb_text1))
    gui.TextManager:Format_AddParam(form.yb1)
    form.lbl_6:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
  end
  form.lbl_7:Clear()
  if nx_string("0") == nx_string(yb) then
    gui.TextManager:Format_SetIDName("ui_change_equip_tips_0")
    form.lbl_7:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
  else
    gui.TextManager:Format_SetIDName("ui_change_equip_fy")
    gui.TextManager:Format_AddParam(gui.TextManager:GetText(form.yb_text2))
    gui.TextManager:Format_AddParam(form.yb2)
    form.lbl_7:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
  end
end
function on_changeequip_form_open(npc_id)
  local form = util_get_form(m_Path, true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.npc_id = nx_string(npc_id)
  util_auto_show_hide_form(m_Path)
  nx_execute("util_gui", "ui_show_attached_form", form)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_contribute_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.selective_shuxi ~= nothing and form.unchang_shuxi ~= nothing then
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_change_equip_confirm", true, false)
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    gui.TextManager:Format_SetIDName("ui_ChangeEquip_tip")
    gui.TextManager:Format_AddParam(gui.TextManager:GetText(index_to_text(form.unchang_shuxi)))
    gui.TextManager:Format_AddParam(gui.TextManager:GetText(index_to_text(form.selective_shuxi)))
    gui.TextManager:Format_AddParam(gui.TextManager:GetText(get_yb_text(form)))
    gui.TextManager:Format_AddParam(get_yb(form))
    dialog.mltbox_1:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "sell_stall_price_input_return")
    if res == "ok" then
      local item_index = 0
      if form.cbtn_index.Checked then
        item_index = 1
      end
      nx_execute("custom_sender", "custom_start_change_equip", form.selective_shuxi, nx_int(item_index))
    elseif res == "cancel" then
      changed_select(form)
      form.selective_shuxi = nothing
    end
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if form.selective_shuxi ~= nothing then
    changed_select(form)
    form.selective_shuxi = nothing
  end
end
function on_cbtn_index_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.lbl_7.Visible = true
    form.lbl_6.Visible = false
  else
    form.lbl_6.Visible = true
    form.lbl_7.Visible = false
  end
end
function on_imagegrid_contribute_rightclick_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_CHANGEEQUIPATT_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    nx_execute("custom_sender", "custom_remove_change_equip", index + 1)
  end
  local form = grid.ParentForm
  init_form(form)
  makeBtn_succes(form)
end
function on_imagegrid_contribute_select_changed(grid)
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
    nx_execute("custom_sender", "custom_add_change_equip", src_viewid, src_pos, selected_index + 1)
    gui.GameHand:ClearHand()
  end
end
function on_imagegrid_contribute_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_CHANGEEQUIPATT_BOX))
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
function on_imagegrid_contribute_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_click(btn)
  local form = btn.ParentForm
  if btn.Name == "btn_1" or btn.Name == "btn_2" or btn.Name == "btn_3" or btn.Name == "btn_10" then
    if form.selective_shuxi ~= ying_rou then
      form.lbl_2.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yinrou_down.png"
      if form.selective_shuxi ~= nothing then
        changed_select(form)
      end
      form.selective_shuxi = ying_rou
    else
    end
  elseif btn.Name == "btn_4" or btn.Name == "btn_5" or btn.Name == "btn_6" then
    if form.selective_shuxi ~= tai_ji then
      form.lbl_3.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_taiji_down.png"
      if form.selective_shuxi ~= nothing then
        changed_select(form)
      end
      form.selective_shuxi = tai_ji
    else
    end
  else
    if (btn.Name == "btn_7" or btn.Name == "btn_8" or btn.Name == "btn_9") and form.selective_shuxi ~= yang_gang then
      form.lbl_4.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yanggang_down.png"
      if form.selective_shuxi ~= nothing then
        changed_select(form)
      end
      form.selective_shuxi = yang_gang
    else
    end
  end
end
function changed_select(form)
  if form.selective_shuxi == ying_rou then
    form.lbl_2.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yinrou_out.png"
  elseif form.selective_shuxi == tai_ji then
    form.lbl_3.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_taiji_out.png"
  elseif form.selective_shuxi == yang_gang then
    form.lbl_4.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yanggang_out.png"
  end
end
function on_btn_get_capture(btn)
  local form = btn.ParentForm
  if btn.Name == "btn_1" or btn.Name == "btn_2" or btn.Name == "btn_3" or btn.Name == "btn_10" then
    if form.selective_shuxi ~= ying_rou then
      form.lbl_2.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yinrou_on.png"
    end
  elseif btn.Name == "btn_4" or btn.Name == "btn_5" or btn.Name == "btn_6" then
    if form.selective_shuxi ~= tai_ji then
      form.lbl_3.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_taiji_on.png"
    end
  elseif (btn.Name == "btn_7" or btn.Name == "btn_8" or btn.Name == "btn_9") and form.selective_shuxi ~= yang_gang then
    form.lbl_4.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yanggang_on.png"
  end
end
function on_btn_lost_capture(btn)
  local form = btn.ParentForm
  if btn.Name == "btn_1" or btn.Name == "btn_2" or btn.Name == "btn_3" or btn.Name == "btn_10" then
    if form.selective_shuxi ~= ying_rou then
      form.lbl_2.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yinrou_out.png"
    end
  elseif btn.Name == "btn_4" or btn.Name == "btn_5" or btn.Name == "btn_6" then
    if form.selective_shuxi ~= tai_ji then
      form.lbl_3.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_taiji_out.png"
    end
  elseif (btn.Name == "btn_7" or btn.Name == "btn_8" or btn.Name == "btn_9") and form.selective_shuxi ~= yang_gang then
    form.lbl_4.BackImage = "gui\\language\\ChineseS\\zhuangbei_ng_shuxing\\btn_yanggang_out.png"
  end
end
function index_to_text(index)
  if index == yang_gang then
    return "ui_yang_gang"
  elseif index == ying_rou then
    return "ui_ying_rou"
  elseif index == tai_ji then
    return "ui_tai_ji"
  end
end
function get_yb(form)
  if form.cbtn_index.Checked then
    return form.yb2
  else
    return form.yb1
  end
end
function get_yb_text(form)
  if form.cbtn_index.Checked then
    return form.yb_text2
  else
    return form.yb_text1
  end
end
