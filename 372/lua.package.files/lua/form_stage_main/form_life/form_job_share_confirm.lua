require("util_functions")
require("define\\request_type")
require("share\\itemtype_define")
function main_form_init(self)
  self.Fixed = false
  self.target_name = ""
  self.formula_id = ""
  self.job_id = ""
  self.target_item = nil
  self.target_type = ""
  self.compose_count = 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  fresh_main_info(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function fresh_main_info(form)
  local gui = nx_value("gui")
  form.lbl_target_name.Text = nx_widestr(gui.TextManager:GetFormatText("ui_tradeobject")) .. nx_widestr(": ") .. nx_widestr(form.target_name)
  fresh_item(form)
end
function fresh_item(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.target_type) == "compose" then
    fresh_compose_item(form)
  elseif nx_string(form.target_type) == "skill" then
    fresh_skill_item(form)
  end
end
function fresh_compose_item(form)
  if nx_string(form.target_name) == "" or nx_string(form.formula_id) == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local iniformula = load_ini("share\\Item\\life_formula.ini")
  if not nx_is_valid(iniformula) then
    return
  end
  local formula_id = nx_string(form.formula_id)
  local sec_item_index = iniformula:FindSectionIndex(formula_id)
  if sec_item_index < 0 then
    nx_log("share\\Item\\life_formula.ini sec_index= " .. nx_string(formula_id))
    return
  end
  local porduct_item = iniformula:ReadString(sec_item_index, "ComposeResult", "")
  local prize = 0
  local share_record = nx_string(form.job_id) .. "_share_rec"
  local row = client_player:FindRecordRow(share_record, 0, formula_id, 0)
  if 0 <= row then
    prize = client_player:QueryRecord(share_record, row, 1)
  end
  count = form.compose_count
  local grid = form.ImageControlGrid_item
  local bExist = ItemQuery:FindItemByConfigID(porduct_item)
  if bExist then
    local item_type = nx_number(ItemQuery:GetItemPropByConfigID(porduct_item, "ItemType"))
    local photo = ""
    if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", porduct_item, "Photo")
    else
      photo = ItemQuery:GetItemPropByConfigID(porduct_item, "Photo")
    end
    local name = gui.TextManager:GetFormatText(porduct_item)
    grid:AddItem(0, photo, "", nx_int(1), nx_int(1))
    grid:SetItemAddInfo(0, nx_int(1), nx_widestr(porduct_item))
    form.lbl_Item_name.Text = nx_widestr(name) .. nx_widestr(" X ") .. nx_widestr(count)
  end
  if prize <= 0 then
    form.lbl_money.Text = nx_widestr("0") .. nx_widestr(util_text("ui_Wen"))
  else
    form.lbl_money.Text = nx_widestr(get_money_text(prize * count))
  end
  local use_ene = iniformula:ReadInteger(sec_item_index, "ComposeUseStrenth", 0) * count
  form.lbl_use_ene.Text = nx_widestr(gui.TextManager:GetFormatText("ui_xiaohaotili")) .. nx_widestr(": ") .. nx_widestr(use_ene)
  local use_point = iniformula:ReadInteger(sec_item_index, "NeedPoint", 0) * count
  use_point = math.abs(use_point)
  form.lbl_use_point.Text = nx_widestr(gui.TextManager:GetFormatText("ui_sh_xhxd")) .. nx_widestr(use_point)
end
function fresh_skill_item(form)
  if nx_string(form.target_name) == "" or nx_string(form.target_configid) == "" or nx_string(form.target_skillid) == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local configID = nx_string(form.target_configid)
  local grid = form.ImageControlGrid_item
  local bExist = ItemQuery:FindItemByConfigID(configID)
  if bExist then
    local item_type = nx_number(ItemQuery:GetItemPropByConfigID(configID, "ItemType"))
    local photo = ""
    if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", configID, "Photo")
    else
      photo = ItemQuery:GetItemPropByConfigID(configID, "Photo")
    end
    local name = gui.TextManager:GetFormatText(configID)
    grid:AddItem(0, photo, "", nx_int(1), nx_int(0))
    grid:SetItemAddInfo(0, nx_int(1), nx_widestr(configID))
    form.lbl_Item_name.Text = nx_widestr(name)
  end
  local skillID = nx_string(form.target_skillid)
  local prize = 0
  local share_record = "job_skill_share_rec"
  local row = client_player:FindRecordRow(share_record, 1, skillID, 0)
  if 0 <= row then
    prize = client_player:QueryRecord(share_record, row, 3)
  end
  if prize <= 0 then
    form.lbl_money.Text = nx_widestr("0") .. nx_widestr(util_text("ui_Wen"))
  else
    form.lbl_money.Text = nx_widestr(get_money_text(prize))
  end
  local share_type = 0
  if 0 <= row then
    share_type = client_player:QueryRecord(share_record, row, 2)
  end
  local use_ene = get_skill_NeedEne(ItemQuery, share_type, configID)
  form.lbl_use_ene.Text = nx_widestr(gui.TextManager:GetFormatText("ui_xiaohaotili")) .. nx_widestr(": ") .. nx_widestr(use_ene)
end
function get_skill_NeedEne(ItemQuery, share_type, configID)
  local share_type = nx_number(share_type)
  if share_type < 1 or 5 < share_type then
    return 0
  end
  local r_obj
  local sec_item_index = 0
  local findkey = ""
  if share_type == 5 then
    local chaolupack = ItemQuery:GetItemPropByConfigID(configID, "ChaoluPack")
    r_obj = load_ini("share\\Life\\ScholarCopy.ini")
    findkey = nx_string(chaolupack)
  elseif share_type == 4 then
    local PainterPz = ItemQuery:GetItemPropByConfigID(configID, "PainterPz")
    r_obj = load_ini("share\\Life\\PainterPz.ini")
    findkey = nx_string(PainterPz)
  elseif share_type == 3 then
    local ScholarPz = ItemQuery:GetItemPropByConfigID(configID, "ScholarPz")
    r_obj = load_ini("share\\Life\\ScholarPz.ini")
    findkey = nx_string(ScholarPz)
  else
    r_obj = load_ini("share\\Item\\Equipment.ini")
    findkey = nx_string(configID)
  end
  if not nx_is_valid(r_obj) then
    return 0
  end
  sec_item_index = r_obj:FindSectionIndex(findkey)
  if sec_item_index < 0 then
    return 0
  end
  local use_ene = r_obj:ReadInteger(sec_item_index, "NeedEne", 0)
  return use_ene
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "job_share_confirm_return", "ok")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "job_share_confirm_return", "cancel")
  if nx_is_valid(form) then
    form:Close()
  end
end
function get_money_text(money)
  local ding, liang, wen = 0, 0, 0
  ding, liang, wen = nx_execute("form_stage_main\\form_mail\\form_mail_send", "trans_price", money)
  local money_text = nx_widestr("")
  if 0 < ding then
    money_text = nx_widestr(ding) .. nx_widestr(util_text("ui_Ding"))
  end
  if 0 < liang then
    money_text = money_text .. nx_widestr(liang) .. nx_widestr(util_text("ui_Liang"))
  end
  if 0 < wen then
    money_text = money_text .. nx_widestr(wen) .. nx_widestr(util_text("ui_Wen"))
  end
  return money_text
end
function load_ini(path)
  return nx_execute("util_functions", "get_ini", nx_string(path))
end
function open_form_compose(target_name, jobid, formula, count)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_share_confirm", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.target_type = "compose"
  form.target_name = target_name
  form.job_id = jobid
  form.formula_id = formula
  form.compose_count = nx_int(count)
  form:ShowModal()
  local res = nx_wait_event(100000000, form, "job_share_confirm_return")
  if res == "cancel" then
    nx_execute("custom_sender", "custom_stop_life_trade")
  else
    nx_execute("custom_sender", "custom_start_life_trade")
  end
end
function open_form_skill(target_name, jobid, configID, skillID)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_share_confirm", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.target_type = "skill"
  form.target_name = target_name
  form.job_id = jobid
  form.target_configid = configID
  form.target_skillid = skillID
  form:ShowModal()
  local res = nx_wait_event(100000000, form, "job_share_confirm_return")
  if res == "cancel" then
    nx_execute("custom_sender", "custom_stop_life_trade")
  else
    nx_execute("custom_sender", "custom_start_life_trade")
  end
end
