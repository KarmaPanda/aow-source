require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\gamehand_type")
require("share\\view_define")
local items_table = {
  [0] = "",
  [1] = "",
  [2] = "",
  [3] = ""
}
function main_form_init(form)
  form.Fixed = false
  form.click_time = 0
  form.can_show_time = 0
  form.show_time = 0
  return 1
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("DigTreasure_Rec", form, nx_current(), "msg_refresh")
  end
  form.ani_1.Visible = false
  form.ani_2.Visible = false
  form.ani_3.Visible = false
  form.ani_4.Visible = false
  battle_begin_animation("bao")
  return 1
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("DigTreasure_Rec", form)
  end
  local gui = nx_value("gui")
  gui.GameHand:SetHand("show", "Default", "", "", "", "")
  nx_destroy(form)
  return 1
end
function on_server_msg(...)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  rows = client_player:GetRecordRows("DigTreasure_Rec")
  if nx_int(rows) < nx_int(4) then
    return 0
  end
  util_show_form("form_stage_main\\form_task\\form_seek_mine_gift", true)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_seek_mine_gift", true, false)
  if not nx_is_valid(form) then
    return
  end
  msg_refresh(form)
end
function on_imagegrid_mousein_grid(grid, index)
  local item_id = items_table[index]
  if item_id == "" then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_id, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm, true)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function msg_refresh(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local rows = 0
  local find_rec = client_player:FindRecord("DigTreasure_Rec")
  if not find_rec then
    return 0
  end
  local nGet = client_player:QueryProp("DigTreasureGetAward")
  local nTime = client_player:QueryProp("DigTreasureShowAward")
  local nNoShowHuoYan = client_player:QueryProp("DigTreasuerYuLP")
  if nx_int(nNoShowHuoYan) == nx_int(1) then
    form.btn_see.Enabled = false
  elseif nx_int(nNoShowHuoYan) == nx_int(0) then
    form.btn_see.Enabled = true
  end
  rows = client_player:GetRecordRows("DigTreasure_Rec")
  if nx_int(rows) < nx_int(4) then
    return 0
  end
  form.can_show_time = 0
  if nx_int(nTime) == nx_int(1) then
    form.can_show_time = nx_int(1)
  end
  if nx_int(nTime) == nx_int(2) then
    form.can_show_time = nx_int(2)
  end
  if nx_int(nTime) == nx_int(3) then
    form.can_show_time = nx_int(4)
  end
  local gui = nx_value("gui")
  form.show_time = 0
  for i = 0, rows - 1 do
    form.imagegrid_1:DelItem(nx_int(i))
    local config_id = client_player:QueryRecord("DigTreasure_Rec", i, 1)
    local item_count = client_player:QueryRecord("DigTreasure_Rec", i, 3)
    local item_visit = client_player:QueryRecord("DigTreasure_Rec", i, 4)
    items_table[i] = config_id
    local item_photo = item_query_ArtPack_by_id(nx_string(config_id), nx_string("Photo"))
    gui.TextManager:Format_SetIDName(config_id)
    item_name = gui.TextManager:Format_GetText()
    if nx_int(nGet) == nx_int(0) then
      local lbl_str = "btn_" .. nx_string(i + 1)
      local lbl_mid_str = "btn_mid_" .. nx_string(i + 1)
      local lbl = form:Find(lbl_str)
      local lbl_mid = form:Find(lbl_mid_str)
      if nx_is_valid(lbl) and nx_is_valid(lbl) then
        lbl.Visible = false
        lbl_mid.Enabled = false
      end
      form.imagegrid_1:AddItem(nx_int(i), nx_string(item_photo), nx_widestr(item_name), nx_int(item_count), nx_int(0))
    elseif nx_int(item_visit) > nx_int(0) then
      form.show_time = form.show_time + nx_int(1)
      local lbl_str = "btn_" .. nx_string(nx_int(i) + 1)
      local lbl_mid_str = "btn_mid_" .. nx_string(nx_int(i) + 1)
      local lbl = form:Find(lbl_str)
      local lbl_mid = form:Find(lbl_mid_str)
      if nx_is_valid(lbl) and nx_is_valid(lbl) then
        lbl.Visible = false
        lbl_mid.Enabled = true
      end
      form.imagegrid_1:AddItem(nx_int(i), nx_string(item_photo), nx_widestr(item_name), nx_int(item_count), nx_int(0))
    else
      local lbl_str = "btn_" .. nx_string(i + 1)
      local lbl_mid_str = "btn_mid_" .. nx_string(i + 1)
      local lbl = form:Find(lbl_str)
      local lbl_mid = form:Find(lbl_mid_str)
      if nx_is_valid(lbl) and nx_is_valid(lbl) then
        lbl.Visible = true
        lbl_mid.Enabled = true
      end
    end
  end
  if nx_int(form.show_time) < nx_int(form.can_show_time) and nx_int(nGet) == nx_int(1) then
    gui.GameHand:SetHand("show", "cur\\select.ani", "", "", "", "")
  else
    gui.GameHand:SetHand("show", "Default", "", "", "", "")
  end
  if nx_int(nGet) == nx_int(0) then
    form.imagegrid_1.Enabled = false
  end
end
function on_btn_close_click(btn)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_seek_mine_gift", true, false)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    form:Close()
    return
  end
  local nGet = client_player:QueryProp("DigTreasureGetAward")
  if nx_int(nGet) == nx_int(0) then
    form:Close()
    return
  else
    local gui = nx_value("gui")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    local text = gui.TextManager:GetText("info_wbhd_wb_04")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      if not nx_is_valid(form) then
        return
      end
      clear_award(form)
      form:Close()
    end
  end
end
function on_btn_1_click(btn)
  click_one_btn(btn.ParentForm, 0)
end
function on_btn_2_click(btn)
  click_one_btn(btn.ParentForm, 1)
end
function on_btn_3_click(btn)
  click_one_btn(btn.ParentForm, 2)
end
function on_btn_4_click(btn)
  click_one_btn(btn.ParentForm, 3)
end
function on_btn_mid_1_click(btn)
  get_index_award(btn.ParentForm, 0)
end
function on_btn_mid_2_click(btn)
  get_index_award(btn.ParentForm, 1)
end
function on_btn_mid_3_click(btn)
  get_index_award(btn.ParentForm, 2)
end
function on_btn_mid_4_click(btn)
  get_index_award(btn.ParentForm, 3)
end
function show_index_award(form, nIndex)
  nx_execute("custom_sender", "custom_seek_mine_msg", nx_int(2), nx_int(nIndex))
end
function buy_show_time(form)
  nx_execute("custom_sender", "custom_seek_mine_msg", nx_int(1))
end
function get_index_award(form, nIndex)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text = gui.TextManager:GetText("info_wbhd_wb_14")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_seek_mine_msg", nx_int(3), nx_int(nIndex))
    local card_ani = "ani_" .. nx_string(nIndex + 1)
    local ani = form:Find(card_ani)
    if not nx_is_valid(ani) then
      return
    end
    ani.Visible = true
    ani:Play()
  end
end
function clear_award(form)
  nx_execute("custom_sender", "custom_seek_mine_msg", nx_int(4))
end
function click_one_btn(form, index)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.show_time) < nx_int(form.can_show_time) then
    show_index_award(form, index)
  else
    get_index_award(form, index)
  end
end
function on_btn_see_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local nGet = client_player:QueryProp("DigTreasureGetAward")
  if nx_int(nGet) == nx_int(0) then
    return
  end
  local nTime = client_player:QueryProp("DigTreasureShowAward")
  if nx_int(nTime) > nx_int(2) then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text = ""
  if nx_int(nTime) == nx_int(0) then
    text = gui.TextManager:GetText("info_wbhd_wb_08")
  end
  if nx_int(nTime) == nx_int(1) then
    text = gui.TextManager:GetText("info_wbhd_wb_09")
  end
  if nx_int(nTime) == nx_int(2) then
    text = gui.TextManager:GetText("info_wbhd_wb_10")
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    buy_show_time(form)
  end
end
function battle_begin_animation(ani_name)
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.Name = nx_string(ani_name)
  animation.AnimationImage = ani_name
  animation.Transparent = true
  gui.Desktop:Add(animation)
  animation.Left = (gui.Width - 540) / 2
  animation.Top = gui.Height / 4
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "battle_animation_end")
  animation:Play()
end
function battle_animation_stop(ani_name)
  local gui = nx_value("gui")
  local animation = gui.Desktop:Find(nx_string(ani_name))
  if nx_is_valid(animation) then
    gui:Delete(animation)
  end
end
function battle_animation_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
