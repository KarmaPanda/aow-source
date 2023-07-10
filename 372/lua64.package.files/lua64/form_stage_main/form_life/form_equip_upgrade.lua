require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
local UPGRADE = 1
local CONVERT = 2
local Sex_man = 0
local Sex_woman = 1
local nEquipList = {}
local nUpEquipList = {}
local Baiban_List = {}
local Baiban_List_Count = {}
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Top = (gui.Height - form.Height) / 2 - 40
  form.selectGroup = nil
  form.selectBtn = nil
  form.nEquipIndex = 0
  form.nNewType = 1
  form.qimen_pos = -1
  form.qimen_viewid = -1
  form.qimen_amount = -1
  form.cleaer_qimen_type = true
  form.convert_type = ""
end
function a(msg)
  nx_msgbox(nx_string(msg))
end
function on_equip_upgrade_msg(...)
  local msgtype = arg[1]
  if msgtype == 0 then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_equip_upgrade", true, false)
    if not nx_is_valid(form) then
      return false
    end
    local jobId = arg[2]
    if nx_string(jobId) == "sh_cf" then
      form.jobText = "cf_title"
    elseif nx_string(jobId) == "sh_tj" then
      form.jobText = "tj_title"
    elseif nx_string(jobId) == "sh_jq" then
      form.jobText = "qj_title"
    end
    form.btn_equip_qimen.Visible = false
    form.groupbox_qimen.Visible = false
    util_show_form("form_stage_main\\form_life\\form_equip_upgrade", true)
    nx_execute("util_gui", "ui_show_attached_form", form)
  elseif msgtype == 1 then
    local form = nx_value("form_stage_main\\form_life\\form_equip_upgrade")
    if not nx_is_valid(form) then
      return
    end
    form.upGradeIndex = arg[2]
    nUpEquipList = {}
    Baiban_List = {}
    local item = arg[3]
    local item_list = util_split_string(item, ";")
    for i = 1, table.getn(item_list) - 1 do
      nUpEquipList[i] = item_list[i]
    end
    local baiban = arg[4]
    local baiban_list = util_split_string(baiban, ";")
    for i = 1, table.getn(baiban_list) do
      Baiban_List[i] = baiban_list[i]
    end
    fresh_upgrade_from(form.upGradeIndex, nUpEquipList)
  end
end
function on_convert_equip_msg(...)
  local msgtype = arg[1]
  if msgtype == 0 then
    local nResult = arg[2]
    local form = nx_value("form_stage_main\\form_life\\form_equip_upgrade")
    if not nx_is_valid(form) then
      return
    end
    if nResult == "able" then
      form.groupbox_qimen.Visible = false
      form.convert_type = "convert"
      refesh_group(form, form.groupbox_convert, form.btn_equip_convert)
      form.mltbox_3.HtmlText = nx_widestr("@ui_EquipChange_shuoming")
      form.mltbox_3.VScrollBar.Value = 0
    end
  elseif msgtype == 1 then
    local form = nx_value("form_stage_main\\form_life\\form_equip_upgrade")
    if not nx_is_valid(form) then
      return
    end
    form.covertindex = arg[2]
    fresh_covert_from(form.covertindex)
  elseif msgtype == 2 then
  end
end
function on_main_form_open(form)
  refesh_group(form, form.groupbox_upgrade, form.btn_equip_up)
  form.lbl_title.Text = nx_widestr("@ui_equipupgrade_" .. form.jobText)
  form.btn_equip_up.Text = nx_widestr("@ui_equipupgrade_" .. form.jobText .. "1")
  form.btn_equip_convert.Text = nx_widestr("@ui_equipchange_" .. form.jobText .. "1")
  form.mltbox_3.HtmlText = nx_widestr("@ui_equipupgrade_shuoming")
  form.mltbox_3.VScrollBar.Value = 0
  form.groupbox_qimen.Visible = false
  if form.jobText ~= "tj_title" then
    form.btn_equip_qimen.Visible = false
  end
  clear_upgrade_form(form)
  clear_convert_form(form)
  clear_qimen_form(form)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, form, "form_stage_main\\form_life\\form_equip_upgrade", "on_toolbox_viewport_change")
  databinder:AddViewBind(VIEWPORT_BOX_UPGRADE, form.Img_equip_upgrade, "form_stage_main\\form_life\\form_equip_upgrade", "on_upgrade_viewport_changed")
  databinder:AddViewBind(VIEWPORT_EQUIP_CONVERT_BOX, form.Img_equip_convert, "form_stage_main\\form_life\\form_equip_upgrade", "on_convert_equip_viewport_changed")
  databinder:AddViewBind(VIEWPORT_EQUIP_QIMEN_BOX, form.Img_equip_qimen, "form_stage_main\\form_life\\form_equip_upgrade", "on_qimen_equip_viewport_changed")
  form.photo_ini = nx_execute("util_functions", "get_ini", "share\\Item\\ItemArtStatic.ini")
  if not nx_is_valid(form.photo_ini) then
    return
  end
  form.img_baiban.Visible = false
  form.baiban_bool = false
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local res_switch = switch_manager:CheckSwitchEnable(791)
  if not nx_boolean(res_switch) then
    form.rbtn_qimen_type_6.Visible = false
    form.lbl_bow.Visible = false
  else
    form.rbtn_qimen_type_6.Visible = true
    form.lbl_bow.Visible = true
  end
end
function on_main_form_close(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) and form_talk.Visible then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_talk")
  if nx_is_valid(form_talk) and form_talk.Visible then
    form_talk:Close()
  end
  nx_execute("custom_sender", "custom_chang_equip_qm", 1)
  nx_execute("custom_sender", "custom_chang_equip_wx", 1)
  nx_execute("custom_sender", "custom_upgrade_equip", 1)
  form.groupbox_upgrade.Visible = false
  form.groupbox_convert.Visible = false
  form.groupbox_qimen.Visible = false
  form.selectGroup = nil
  form.selectBtn = nil
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
    databinder:DelViewBind(form.Img_equip_upgrade)
    databinder:DelViewBind(form.Img_equip_convert)
    databinder:DelViewBind(form.Img_equip_qimen)
  end
  form.convert_type = ""
  nx_destroy(form)
end
function on_btn_check_click(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if btn.Name == "btn_equip_up" then
    local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_CONVERT_BOX))
    if not nx_is_valid(view) then
      return
    end
    if table.getn(view:GetViewObjList()) >= 1 then
      return
    end
    refesh_group(form, form.groupbox_upgrade, btn)
    form.lbl_title.Text = nx_widestr("@ui_EquipUpgrade_" .. form.jobText)
    form.mltbox_3.HtmlText = nx_widestr("@ui_equipupgrade_shuoming")
    form.mltbox_3.VScrollBar.Value = 0
  elseif btn.Name == "btn_equip_convert" then
    local view = game_client:GetView(nx_string(VIEWPORT_BOX_UPGRADE))
    if not nx_is_valid(view) then
      return
    end
    if table.getn(view:GetViewObjList()) >= 1 then
      return
    end
    nx_execute("custom_sender", "custom_chang_equip_wx", 4)
  elseif btn.Name == "btn_equip_qimen" then
    nx_execute("custom_sender", "custom_chang_equip_qm", 4)
  end
end
function refesh_group(form, checkGroup, btn)
  if form.selectGroup == nil then
    checkGroup.Visible = true
    form.selectGroup = checkGroup
    btn.NormalImage = "gui\\common\\button\\btn_normal1_out.png"
    form.selectBtn = btn
  elseif checkGroup.Name ~= form.selectGroup.Name then
    form.selectGroup.Visible = false
    checkGroup.Visible = true
    form.selectGroup = checkGroup
    form.selectBtn.NormalImage = "gui\\common\\button\\btn_normal_out.png"
    btn.NormalImage = "gui\\common\\button\\btn_normal1_out.png"
    form.selectBtn = btn
  end
end
function clear_upgrade_form(form)
  form.Img_equip_upgrade.Visible = true
  form.Img_equip_upgrade.RowNum = 1
  form.Img_equip_upgrade:Clear()
  form.Img_replace_equip.Visible = false
  form.Img_material.Visible = false
  form.Img_RandGrid.Visible = false
  form.lbl_upgrade_main.Visible = true
  form.lbl_upgrade_minor.Visible = false
  form.cbtn_1.Visible = false
  form.cbtn_1.Enabled = false
  form.lbl_use_silver_random_prop.Visible = false
  form.lbl_save_main_equip_build_prop.Visible = false
  form.btn_upgrade.Enabled = false
  form.ImageUpgradeGrid.ClomnNum = 5
  form.ImageUpgradeGrid:Clear()
  form.nEquipIndex = 0
  for j = 1, 5 do
    local nBtn = form:Find(nx_string("rbtn_Type") .. nx_string(j))
    if nx_is_valid(nBtn) then
      nBtn.Enabled = false
      nBtn.Visible = true
    end
  end
  form.rbtn_Type6.Checked = true
  form.equip_bool1 = false
  form.equip_bool2 = false
  form.equip_bool3 = false
  form.upGradeIndex = -1
  form.kgzg = true
  form.equip_lv = 0
  form.bind = 0
  form.img_baiban:Clear()
  form.img_baiban.Visible = false
end
function clear_convert_form(form)
  form.Img_equip_convert:Clear()
  form.lbl_box_2_main.Visible = true
  form.btn_convert.Enabled = false
  form.ImgaConcertGrid.ClomnNum = 5
  form.ImgaConcertGrid:Clear()
  for j = 1, 5 do
    local nBtn = form:Find(nx_string("rbtn_Type") .. nx_string(j))
    if nx_is_valid(nBtn) then
      nBtn.Enabled = false
      nBtn.Visible = true
    end
  end
  form.rbtn_Type6.Checked = true
  form.nEquipIndex = 0
  show_money(0)
  form.img_baiban:Clear()
  form.img_baiban.Visible = false
end
function fresh_upgrade_from(costindex, dropItemIds)
  local form = nx_value("form_stage_main\\form_life\\form_equip_upgrade")
  if not nx_is_valid(form) then
    return
  end
  if costindex < 0 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  form.Img_material:Clear()
  form.Img_RandGrid:Clear()
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\UpgradeEquipCost.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = costindex
  if sec_index < 0 then
    return
  end
  form.Img_material.Visible = true
  local item_list = ini:ReadString(sec_index, "NeedMet", "")
  local str_lst = util_split_string(item_list, ";")
  if 0 < table.getn(str_lst) then
    for i = 1, table.getn(str_lst) do
      local str_temp = util_split_string(str_lst[i], ",")
      local item_id = str_temp[1]
      local need_num = nx_int(str_temp[2])
      if need_num <= nx_int(0) then
        need_num = 1
      end
      local have_num = get_item_num(item_id)
      local bExist = ItemQuery:FindItemByConfigID(item_id)
      local node_name = gui.TextManager:GetFormatText(item_id)
      if bExist then
        local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
        if nx_number(have_num) >= nx_number(need_num) then
          form.Img_material:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
          form.Img_material:ChangeItemImageToBW(0, false)
          form.equip_bool1 = true
          if (form.equip_bool2 == true or form.equip_bool3 == true) and form.nEquipIndex ~= 0 then
            form.btn_upgrade.Enabled = true
          end
        else
          form.Img_material:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
          form.Img_material:ChangeItemImageToBW(0, true)
          form.equip_bool1 = false
          form.btn_upgrade.Enabled = false
        end
      end
      form.Img_material:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(item_id))
    end
  end
  if form.equip_bool3 ~= true then
    form.Img_replace_equip:Clear()
    form.Img_replace_equip.Visible = true
    item_list = ini:ReadString(sec_index, "NeedCompensate", "")
    str_lst = util_split_string(item_list, ";")
    if 0 < table.getn(str_lst) then
      for i = 1, table.getn(str_lst) do
        local str_temp = util_split_string(str_lst[i], ",")
        local item_id = str_temp[1]
        local need_num = nx_int(str_temp[2])
        if need_num <= nx_int(0) then
          need_num = 1
        end
        local have_num = get_item_num(item_id)
        local bExist = ItemQuery:FindItemByConfigID(item_id)
        local node_name = gui.TextManager:GetFormatText(item_id)
        if bExist then
          local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
          if nx_number(have_num) >= nx_number(need_num) then
            form.Img_replace_equip:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
            form.Img_replace_equip:ChangeItemImageToBW(0, false)
            form.equip_bool2 = true
            if form.equip_bool1 == true and form.nEquipIndex ~= 0 then
              form.btn_upgrade.Enabled = true
            end
          else
            form.Img_replace_equip:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
            form.Img_replace_equip:ChangeItemImageToBW(0, true)
            form.equip_bool2 = false
            form.btn_upgrade.Enabled = false
          end
        end
        form.Img_replace_equip:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(item_id))
      end
    else
      form.Img_replace_equip.Visible = false
      form.btn_upgrade.Enabled = false
    end
  else
    form.Img_replace_equip.Visible = false
  end
  local game_client = nx_value("game_client")
  local Player = game_client:GetPlayer()
  local play_sex = Player:QueryProp("Sex")
  if not nx_is_valid(form.photo_ini) then
    return
  end
  local nCounts = table.getn(dropItemIds)
  for i = 1, nCounts do
    local dropItemId = dropItemIds[i]
    local nAPK = ItemQuery:GetItemPropByConfigID(dropItemId, "ArtPack")
    local nIndex_PT = form.photo_ini:FindSectionIndex(nx_string(nAPK))
    local photo = ""
    if play_sex == Sex_woman then
      photo = form.photo_ini:ReadString(nIndex_PT, "FemalePhoto", "")
    end
    if photo == "" then
      photo = form.photo_ini:ReadString(nIndex_PT, "Photo", "")
    end
    form.ImageUpgradeGrid:AddItem(nx_int(i - 1), nx_string(photo), nx_widestr(""), nx_int(0), -1)
    form.ImageUpgradeGrid:ChangeItemImageToBW(nx_int(i - 1), false)
    form.ImageUpgradeGrid:SetItemAddInfo(nx_int(i - 1), nx_int(2), nx_widestr(dropItemId))
    local nBtn = form:Find(nx_string("rbtn_Type") .. nx_string(i))
    if not nx_is_valid(nBtn) then
      return
    end
    nBtn.Enabled = true
    if 1 == nCounts and i == 1 then
      nBtn.Checked = true
    end
  end
  form.Img_RandGrid.Visible = true
  item_list = ini:ReadString(sec_index, "SilverRandEquip", "")
  if item_list == "" then
    form.Img_RandGrid.Visible = false
    return
  end
  form.Img_RandGrid.Visible = form.kgzg
  str_lst = util_split_string(item_list, ";")
  if 0 < table.getn(str_lst) then
    for i = 1, table.getn(str_lst) do
      local str_temp = util_split_string(str_lst[i], ",")
      local item_id = str_temp[1]
      local need_num = nx_int(str_temp[2])
      if need_num <= nx_int(0) then
        need_num = 1
      end
      local have_num = get_item_num(item_id)
      local bExist = ItemQuery:FindItemByConfigID(item_id)
      local node_name = gui.TextManager:GetFormatText(item_id)
      if bExist then
        local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
        if nx_number(have_num) >= nx_number(need_num) then
          form.Img_RandGrid:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
          form.Img_RandGrid:ChangeItemImageToBW(0, false)
        else
          form.Img_RandGrid:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
          form.Img_RandGrid:ChangeItemImageToBW(0, true)
        end
        if form.kgzg == true then
          form.cbtn_1.Enabled = true
          form.cbtn_1.Checked = true
        end
      end
      form.Img_RandGrid:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(item_id))
    end
  end
end
function on_upgrade_viewport_changed(grid, optype, view_ident, index)
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
    return
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "additem" then
    local viewobj = view:GetViewObj(nx_string(index))
    if index == 1 then
      grid.RowNum = 2
      form.lbl_upgrade_minor.Visible = true
      local ColourLevel = viewobj:QueryProp("ColorLevel")
      form.bind = viewobj:QueryProp("BindStatus")
      if ColourLevel == 4 then
        form.Img_RandGrid.Visible = true
        form.lbl_use_silver_random_prop.Visible = true
        form.lbl_save_main_equip_build_prop.Visible = false
        form.cbtn_1.Visible = true
        form.cbtn_1.Enabled = true
        form.cbtn_1.Checked = true
        local NowNum = viewobj:QueryProp("CurBuildCount")
        local MaxNum = viewobj:QueryProp("MaxBuildCount")
        if NowNum < MaxNum then
          form.kgzg = false
          form.Img_RandGrid.Visible = false
          form.lbl_use_silver_random_prop.Visible = false
          form.cbtn_1.Visible = false
          form.cbtn_1.Enabled = false
          form.cbtn_1.Checked = false
        end
      else
        form.Img_RandGrid.Visible = false
        form.lbl_use_silver_random_prop.Visible = false
        form.lbl_save_main_equip_build_prop.Visible = true
        form.cbtn_1.Visible = true
        form.cbtn_1.Enabled = true
        form.cbtn_1.Checked = true
      end
    elseif index == 2 then
      form.equip_bool3 = true
      if form.equip_bool1 == true and form.nEquipIndex ~= 0 then
        form.btn_upgrade.Enabled = true
      end
      form.Img_replace_equip.Visible = false
    end
    ShowItembyobj(form, viewobj, index, grid)
  elseif optype == "delitem" then
    if index == 1 then
      clear_upgrade_form(form)
    elseif index == 2 then
      form.equip_bool3 = false
      if form.equip_bool1 == false or form.equip_bool2 == false or form.nEquipIndex == 0 then
        form.btn_upgrade.Enabled = false
      end
      form.Img_replace_equip.Visible = form.Img_material.Visible
      local viewobj = view:GetViewObj(nx_string(1))
      if nx_is_valid(viewobj) then
        local ColourLevel = viewobj:QueryProp("ColorLevel")
        if ColourLevel <= 4 then
          form.Img_replace_equip.Visible = false
        end
        if ColourLevel ~= 4 then
          form.lbl_use_silver_random_prop.Visible = false
          form.lbl_save_main_equip_build_prop.Visible = true
        end
      end
    end
    grid:DelItem(index - 1)
  end
end
function on_btn_upgrade_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_BOX_UPGRADE))
  if not nx_is_valid(view) then
    return
  end
  if table.getn(view:GetViewObjList()) < 1 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_upgrade_equip_confirm", true, false)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if form.equip_lv == 4 then
    gui.TextManager:Format_SetIDName("ui_EquipUpgrade_queding1")
  elseif form.equip_bool3 == true then
    gui.TextManager:Format_SetIDName("ui_equipupgrade_queding")
  elseif form.bind == 1 then
    gui.TextManager:Format_SetIDName("ui_equipupgrade_queding")
  else
    gui.TextManager:Format_SetIDName("ui_EquipUpgrade_queding2")
  end
  dialog.mltbox_1:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "sell_stall_price_input_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    if form.cbtn_1.Visible == true and form.cbtn_1.Checked == true then
      nx_execute("custom_sender", "custom_upgrade_equip", 0, 1, form.nEquipIndex)
    else
      nx_execute("custom_sender", "custom_upgrade_equip", 0, 0, form.nEquipIndex)
    end
  end
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
function fresh_covert_from(costindex)
  local form = nx_value("form_stage_main\\form_life\\form_equip_upgrade")
  if not nx_is_valid(form) then
    return
  end
  if costindex < 0 then
    return
  end
  if form.Visible == false then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_CONVERT_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  if table.getn(viewobj_list) < 1 then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local main_item_id = viewobj_list[1]:QueryProp("ConfigID")
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\EquipChangeList.ini")
  if not nx_is_valid(ini) then
    return
  end
  local Player = game_client:GetPlayer()
  local play_sex = Player:QueryProp("Sex")
  local item_list = ini:ReadString(costindex, "ConfigID", "")
  local str_lst = util_split_string(item_list, ";")
  local moneys = ini:ReadString(costindex, "Cost", "")
  local money_lst = util_split_string(moneys, ",")
  local nCounts = table.getn(str_lst) - 1
  local photo_ini = nx_execute("util_functions", "get_ini", "share\\Item\\ItemArtStatic.ini")
  Baiban_List = {}
  for i = 1, nCounts do
    local var = str_lst[i]
    local small_var = util_split_string(var, ",")
    if nx_int(table.getn(small_var)) == nx_int(3) then
      local item_id = small_var[1]
      Baiban_List[i] = small_var[2]
      Baiban_List_Count[i] = small_var[3]
      local nAPK = ItemQuery:GetItemPropByConfigID(item_id, "ArtPack")
      local nIndex_PT = photo_ini:FindSectionIndex(nx_string(nAPK))
      local photo = ""
      if play_sex == Sex_woman then
        photo = photo_ini:ReadString(nIndex_PT, "FemalePhoto", "")
      end
      if photo == "" then
        photo = photo_ini:ReadString(nIndex_PT, "Photo", "")
      end
      form.ImgaConcertGrid:AddItem(nx_int(i - 1), nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
      form.ImgaConcertGrid:ChangeItemImageToBW(nx_int(i - 1), false)
      form.ImgaConcertGrid:SetItemAddInfo(nx_int(i - 1), nx_int(2), nx_widestr(item_id))
      local equip_name = gui.TextManager:GetFormatText(item_id)
      nEquipList[i] = {
        name = equip_name,
        money = money_lst[i],
        id = item_id
      }
      local nBtn = form:Find(nx_string("rbtn_Type") .. nx_string(i))
      if not nx_is_valid(nBtn) then
        return
      end
      nBtn.Enabled = true
      if item_id == main_item_id then
        form.ImgaConcertGrid:ChangeItemImageToBW(i - 1, true)
        nBtn.Enabled = false
      end
      main_Equip_name = gui.TextManager:GetFormatText(main_item_id)
    end
  end
  hide_btn(form, nCounts)
end
function on_convert_equip_viewport_changed(grid, optype, view_ident, index)
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
    return
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "additem" then
    local viewobj = view:GetViewObj(nx_string(index))
    ShowItembyobj(form, viewobj, index, grid)
  elseif optype == "delitem" then
    clear_convert_form(form)
    local viewobj = view:GetViewObj(nx_string(index))
    ShowItembyobj(form, viewobj, index, grid)
  end
end
function ShowItembyobj(form, viewobj, index, grid)
  if not nx_is_valid(viewobj) then
    grid:DelItem(index - 1)
    return
  end
  local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
  grid:AddItem(index - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
  grid:ChangeItemImageToBW(index - 1, false)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_Img_equip_upgrade_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local selected_index = grid:GetSelectItemIndex()
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
    if grid.Name == "Img_equip_upgrade" then
      nx_execute("custom_sender", "custom_upgrade_equip", 2, nx_int(src_viewid), nx_int(src_pos), nx_int(selected_index) + 1)
    elseif grid.Name == "Img_equip_convert" then
      nx_execute("custom_sender", "custom_chang_equip_wx", 2, nx_int(src_viewid), nx_int(src_pos), nx_int(selected_index) + 1)
    elseif grid.Name == "Img_equip_qimen" then
      form.qimen_pos = src_pos
      form.qimen_viewid = src_viewid
      form.qimen_amount = src_amount
      nx_execute("custom_sender", "custom_chang_equip_qm", 2, nx_int(src_viewid), nx_int(src_pos), nx_int(selected_index) + 1, 1)
    end
    gui.GameHand:ClearHand()
  end
end
function on_Img_equip_upgrade_rightclick_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_BOX_UPGRADE))
  if grid.Name == "Img_equip_convert" then
    view = game_client:GetView(nx_string(VIEWPORT_EQUIP_CONVERT_BOX))
  elseif grid.Name == "Img_equip_qimen" then
    view = game_client:GetView(nx_string(VIEWPORT_EQUIP_QIMEN_BOX))
  end
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if not nx_is_valid(viewobj) then
    return
  end
  local id = viewobj:QueryProp("ConfigID")
  local gui = nx_value("gui")
  local name = gui.TextManager:GetFormatText(id)
  if nx_is_valid(viewobj) then
    if grid.Name == "Img_equip_upgrade" then
      nx_execute("custom_sender", "custom_upgrade_equip", 3, index + 1)
    elseif grid.Name == "Img_equip_convert" then
      nx_execute("custom_sender", "custom_chang_equip_wx", 3, index + 1)
    elseif grid.Name == "Img_equip_qimen" then
      local form = grid.ParentForm
      form.cleaer_qimen_type = true
      nx_execute("custom_sender", "custom_chang_equip_qm", 3, index + 1)
    end
  end
  if index == 0 and grid.RowNum == 2 then
    local viewobj = view:GetViewObj(nx_string(index + 2))
    if nx_is_valid(viewobj) then
      nx_execute("custom_sender", "custom_upgrade_equip", 3, index + 2)
    end
  end
end
function on_Img_equip_upgrade_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_BOX_UPGRADE))
  if grid.Name == "Img_equip_convert" then
    view = game_client:GetView(nx_string(VIEWPORT_EQUIP_CONVERT_BOX))
  elseif grid.Name == "Img_equip_qimen" then
    view = game_client:GetView(nx_string(VIEWPORT_EQUIP_QIMEN_BOX))
  end
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    local id = viewobj:QueryProp("ConfigID")
    local gui = nx_value("gui")
    local name = gui.TextManager:GetFormatText(id)
    nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_Img_equip_upgrade_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_Img_mousein_by_ConfigID_grid(grid, index)
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(2))
  showitemtips(grid, item_config)
end
function showitemtips(grid, item_config)
  if nx_string(item_config) == nx_string("") or nx_string(item_config) == nx_string("nil") then
    return
  end
  local item_name, item_type
  local ItemQuery = nx_value("ItemQuery")
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(ItemQuery) or not nx_is_valid(IniManager) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if nx_string(bExist) == nx_string("true") then
    item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
    item_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Level"))
    local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
    local prop_array = {}
    prop_array.ConfigID = nx_string(item_config)
    prop_array.ItemType = nx_int(item_type)
    prop_array.Level = nx_int(item_level)
    prop_array.SellPrice1 = nx_int(item_sellPrice1)
    prop_array.Photo = nx_string(photo)
    prop_array.is_static = true
    if not nx_is_valid(grid.Data) then
      grid.Data = nx_create("ArrayList")
    end
    grid.Data:ClearChild()
    for prop, value in pairs(prop_array) do
      nx_set_custom(grid.Data, prop, value)
    end
    nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function get_item_num(item_id)
  local game_client = nx_value("game_client")
  local material_view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
  local tool_view = game_client:GetView(nx_string(VIEWPORT_TOOL))
  local task_view = game_client:GetView(nx_string(VIEWPORT_TASK_TOOL))
  if not nx_is_valid(material_view) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  material_list = material_view:GetViewObjList()
  local count = table.getn(material_list)
  for j = 1, count do
    local obj = material_list[j]
    if nx_is_valid(obj) then
      local tempid = obj:QueryProp("ConfigID")
      if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
        cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
      end
    end
  end
  if nx_int(cur_amount) == nx_int(0) and nx_is_valid(tool_view) then
    tool_list = tool_view:GetViewObjList()
    local count = table.getn(tool_list)
    for j = 1, count do
      local obj = tool_list[j]
      if nx_is_valid(obj) then
        local tempid = obj:QueryProp("ConfigID")
        if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
          cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
        end
      end
    end
  end
  if nx_int(cur_amount) == nx_int(0) and nx_is_valid(tool_view) then
    task_list = task_view:GetViewObjList()
    local count = table.getn(task_list)
    for j = 1, count do
      local obj = task_list[j]
      if nx_is_valid(obj) then
        local tempid = obj:QueryProp("ConfigID")
        if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
          cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
        end
      end
    end
  end
  return nx_int(cur_amount)
end
function hide_btn(form, counts)
  if not nx_is_valid(form) then
    return
  end
  if form.convert_type == "convert" then
    form.ImgaConcertGrid.ClomnNum = counts
  elseif form.convert_type == "qimen" then
    form.ImageControlGrid_qimen.ClomnNum = counts
  end
  for j = counts + 1, 5 do
    local nBtn = form:Find(nx_string("rbtn_Type") .. nx_string(j))
    if nx_is_valid(nBtn) then
      nBtn.Visible = false
    end
  end
end
function on_Img_Convert_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(2))
  showitemtips(grid, item_config)
end
function on_rbtn_Type_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked == true then
    if btn.Name == "rbtn_Type1" then
      form.nEquipIndex = 1
    elseif btn.Name == "rbtn_Type2" then
      form.nEquipIndex = 2
    elseif btn.Name == "rbtn_Type3" then
      form.nEquipIndex = 3
    elseif btn.Name == "rbtn_Type4" then
      form.nEquipIndex = 4
    elseif btn.Name == "rbtn_Type5" then
      form.nEquipIndex = 5
    elseif btn.Name == "rbtn_Type6" then
      form.nEquipIndex = 6
    end
    CheckBaiban()
  end
end
function on_btn_convert_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_CONVERT_BOX))
  if not nx_is_valid(view) then
    return
  end
  if table.getn(view:GetViewObjList()) < 1 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_upgrade_equip_confirm", true, false)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_EquipChange_queding")
  gui.TextManager:Format_AddParam(nx_int(nEquipList[form.nEquipIndex].money))
  dialog.mltbox_1:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "sell_stall_price_input_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    nx_execute("custom_sender", "custom_chang_equip_wx", 0, form.nEquipIndex)
  end
end
function show_money(money)
  local form = nx_value("form_stage_main\\form_life\\form_equip_upgrade")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.mltbox_2) then
    return
  end
  local gui = nx_value("gui")
  if form.convert_type == "convert" then
    gui.TextManager:Format_SetIDName("ui_recast_cost")
    gui.TextManager:Format_AddParam(nx_int(money))
    local text = gui.TextManager:Format_GetText()
    form.mltbox_2.HtmlText = nx_widestr("")
    form.mltbox_2:AddHtmlText(text, -1)
  elseif form.convert_type == "qimen" then
    gui.TextManager:Format_SetIDName("ui_recast_cost_qimen")
    gui.TextManager:Format_AddParam(nx_int(money))
    local text = gui.TextManager:Format_GetText()
    form.mltbox_4.HtmlText = nx_widestr("")
    form.mltbox_4:AddHtmlText(text, -1)
  end
end
function on_toolbox_viewport_change(form, optype)
  if optype == "updateitem" or optype == "additem" or optype == "delitem" then
    if form.selectGroup.Name == "groupbox_upgrade" then
      fresh_upgrade_from(form.upGradeIndex, nUpEquipList)
    elseif form.selectGroup.Name == "groupbox_convert" then
      fresh_covert_from(form.covertindex)
    end
  end
end
function on_btn_notice_click(btn)
  local form = btn.ParentForm
  if form.groupbox_notice.Visible == false then
    form.groupbox_notice.Visible = true
    form.btn_notice_close.Visible = true
  end
end
function on_btn_notice_close_click(btn)
  local form = btn.ParentForm
  if form.groupbox_notice.Visible == true then
    form.groupbox_notice.Visible = false
    form.btn_notice_close.Visible = false
  end
end
function CheckBaiban()
  local form = nx_value("form_stage_main\\form_life\\form_equip_upgrade")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  form.img_baiban.Visible = false
  form.img_baiban:Clear()
  form.baiban_bool = false
  if form.nEquipIndex > table.getn(Baiban_List) then
    return
  end
  if Baiban_List[form.nEquipIndex] == "" then
    if form.groupbox_upgrade.Visible == true then
      if (form.equip_bool2 == true or form.equip_bool3 == true) and form.equip_bool1 == true then
        form.btn_upgrade.Enabled = true
      end
    elseif form.groupbox_convert.Visible == true then
      form.btn_convert.Enabled = true
      show_money(nEquipList[form.nEquipIndex].money)
    end
  else
    form.img_baiban.Visible = true
    local item_id = Baiban_List[form.nEquipIndex]
    local need_num = 1
    if form.selectGroup.Name == "groupbox_convert" or form.selectGroup.Name == "groupbox_qimen" then
      need_num = Baiban_List_Count[form.nEquipIndex]
    end
    local have_num = get_item_num(item_id)
    local bExist = ItemQuery:FindItemByConfigID(item_id)
    local node_name = gui.TextManager:GetFormatText(item_id)
    if bExist then
      local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
      if nx_number(have_num) >= nx_number(need_num) then
        form.img_baiban:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
        form.img_baiban:ChangeItemImageToBW(0, false)
        form.baiban_bool = true
      else
        form.img_baiban:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
        form.img_baiban:ChangeItemImageToBW(0, true)
        form.baiban_bool = false
      end
    end
    form.img_baiban:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(item_id))
    if form.groupbox_upgrade.Visible == true then
      if (form.equip_bool2 == true or form.equip_bool3 == true) and form.equip_bool1 == true and form.baiban_bool == true and form.nEquipIndex ~= 0 then
        form.btn_upgrade.Enabled = true
      else
        form.btn_upgrade.Enabled = false
      end
    elseif form.groupbox_convert.Visible == true then
      if form.baiban_bool == true and form.nEquipIndex ~= 0 then
        form.btn_convert.Enabled = true
      else
        form.btn_convert.Enabled = false
      end
      show_money(nEquipList[form.nEquipIndex].money)
    elseif form.groupbox_qimen.Visible == true then
      if form.baiban_bool == true and form.nEquipIndex ~= 0 then
        form.btn_qimen.Enabled = true
      else
        form.btn_qimen.Enabled = false
      end
      show_money(nEquipList[form.nEquipIndex].money)
    end
  end
end
function on_qimen_equip_msg(...)
  local msgtype = arg[1]
  if msgtype == 0 then
    local nResult = arg[2]
    local form = nx_value("form_stage_main\\form_life\\form_equip_upgrade")
    if not nx_is_valid(form) then
      return
    end
    if nResult == "able" then
      form.convert_type = "qimen"
      form.groupbox_qimen.Visible = true
      refesh_group(form, form.groupbox_qimen, form.btn_equip_qimen)
      form.mltbox_3.HtmlText = nx_widestr("@ui_equipchange_shuoming_qm")
      form.mltbox_3.VScrollBar.Value = 0
    end
  elseif msgtype == 1 then
    local form = nx_value("form_stage_main\\form_life\\form_equip_upgrade")
    if not nx_is_valid(form) then
      return
    end
    form.qimenindex = arg[2]
    fresh_qimen_type(form.nNewType)
    fresh_qimen_form()
  elseif msgtype == 3 then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_equip_upgrade", true, false)
    if not nx_is_valid(form) then
      return false
    end
    form.jobText = "tj_title"
    util_show_form("form_stage_main\\form_life\\form_equip_upgrade", true)
    nx_execute("util_gui", "ui_show_attached_form", form)
    on_btn_check_click(form.btn_equip_qimen)
    form.btn_equip_up.Visible = false
    form.btn_equip_convert.Visible = false
    form.lbl_title.Text = nx_widestr(util_text("ui_equipupgrade_zh_title"))
    form.lbl_66.Text = nx_widestr(util_text("ui_equipchange_guize_qm"))
  end
end
function on_qimen_equip_viewport_changed(grid, optype, view_ident, index)
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
    return
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "additem" then
    local viewobj = view:GetViewObj(nx_string(index))
    ShowItembyobj(form, viewobj, index, grid)
  elseif optype == "delitem" then
    clear_qimen_form(form)
    local viewobj = view:GetViewObj(nx_string(index))
    ShowItembyobj(form, viewobj, index, grid)
  end
end
function on_rbtn_qimen_type_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cleaer_qimen_type = false
  if btn.Checked == true then
    if btn.Name == "rbtn_qimen_type_1" then
      form.nNewType = 1
    elseif btn.Name == "rbtn_qimen_type_2" then
      form.nNewType = 2
    elseif btn.Name == "rbtn_qimen_type_3" then
      form.nNewType = 3
    elseif btn.Name == "rbtn_qimen_type_4" then
      form.nNewType = 4
    elseif btn.Name == "rbtn_qimen_type_5" then
      form.nNewType = 5
    elseif btn.Name == "rbtn_qimen_type_6" then
      form.nNewType = 6
    end
    change_qimen_type(form)
    if form.nEquipIndex > 0 then
      CheckBaiban()
    end
  end
end
function change_qimen_type(form)
  local grid = form.Img_equip_qimen
  local selected_index = grid:GetSelectItemIndex()
  local src_viewid = form.qimen_viewid
  local src_pos = form.qimen_pos
  local src_amount = form.qimen_amount
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(src_viewid))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(src_pos))
  if not nx_is_valid(viewobj) then
    return
  end
  if grid.Name == "Img_equip_qimen" then
    nx_execute("custom_sender", "custom_chang_equip_qm", 3, selected_index + 1)
    nx_execute("custom_sender", "custom_chang_equip_qm", 2, nx_int(src_viewid), nx_int(src_pos), nx_int(selected_index) + 1, nx_int(form.nNewType))
  end
  fresh_qimen_form()
end
function clear_qimen_form(form)
  if not form.cleaer_qimen_type then
    return
  end
  form.nNewType = 1
  form.nEquipIndex = 0
  form.qimen_pos = -1
  form.qimen_viewid = -1
  form.qimen_amount = -1
  form.img_baiban:Clear()
  form.img_baiban.Visible = false
  form.btn_qimen.Enabled = false
  form.ImageControlGrid_qimen.ClomnNum = 5
  form.ImageControlGrid_qimen:Clear()
  form.Img_equip_qimen:Clear()
  form.lbl_box_3_main.Visible = true
  for j = 1, 6 do
    local nBtn = form:Find(nx_string("rbtn_Type") .. nx_string(j))
    if nx_is_valid(nBtn) then
      nBtn.Enabled = false
      nBtn.Visible = true
    end
  end
  form.rbtn_Type6.Checked = true
  for i = 1, 6 do
    local rbtn = form.groupbox_qimen:Find(nx_string("rbtn_qimen_type_") .. nx_string(i))
    if nx_is_valid(rbtn) then
      rbtn.Checked = false
      rbtn.Enabled = false
    end
  end
  show_money(0)
end
function fresh_qimen_type(index)
  local form = nx_value("form_stage_main\\form_life\\form_equip_upgrade")
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 6 do
    local rbtn = form.groupbox_qimen:Find(nx_string("rbtn_qimen_type_") .. nx_string(i))
    if nx_is_valid(rbtn) then
      if i == index then
        rbtn.Checked = true
      end
      rbtn.Enabled = true
    end
  end
end
function fresh_qimen_form()
  local form = nx_value("form_stage_main\\form_life\\form_equip_upgrade")
  if not nx_is_valid(form) then
    return
  end
  if form.Visible == false then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_QIMEN_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  if table.getn(viewobj_list) < 1 then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local main_item_id = viewobj_list[1]:QueryProp("ConfigID")
  local str_list = util_split_string(main_item_id, "_")
  local main_item_type_id = str_list[2]
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\WeaponChangeList.ini")
  if not nx_is_valid(ini) then
    return
  end
  local costindex = form.qimenindex
  if costindex < 0 then
    return
  end
  local Player = game_client:GetPlayer()
  local play_sex = Player:QueryProp("Sex")
  local item_list = ini:ReadString(costindex, "ConfigID", "")
  local str_lst = util_split_string(item_list, ";")
  local moneys = ini:ReadString(costindex, "Cost", "")
  local money_lst = util_split_string(moneys, ",")
  local nCounts = table.getn(str_lst) - 1
  local photo_ini = nx_execute("util_functions", "get_ini", "share\\Item\\ItemArtStatic.ini")
  Baiban_List = {}
  for i = 1, nCounts do
    local var = str_lst[i]
    local small_var = util_split_string(var, ",")
    if nx_int(table.getn(small_var)) == nx_int(3) then
      local item_id = small_var[1]
      Baiban_List[i] = small_var[2]
      Baiban_List_Count[i] = small_var[3]
      local nAPK = ItemQuery:GetItemPropByConfigID(item_id, "ArtPack")
      local nIndex_PT = photo_ini:FindSectionIndex(nx_string(nAPK))
      local photo = ""
      if play_sex == Sex_woman then
        photo = photo_ini:ReadString(nIndex_PT, "FemalePhoto", "")
      end
      if photo == "" then
        photo = photo_ini:ReadString(nIndex_PT, "Photo", "")
      end
      form.ImageControlGrid_qimen:AddItem(nx_int(i - 1), nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
      form.ImageControlGrid_qimen:ChangeItemImageToBW(nx_int(i - 1), false)
      form.ImageControlGrid_qimen:SetItemAddInfo(nx_int(i - 1), nx_int(2), nx_widestr(item_id))
      local equip_name = gui.TextManager:GetFormatText(item_id)
      nEquipList[i] = {
        name = equip_name,
        money = money_lst[i],
        id = item_id
      }
      local nBtn = form:Find(nx_string("rbtn_Type") .. nx_string(i))
      if not nx_is_valid(nBtn) then
        return
      end
      nBtn.Enabled = true
      local str_list = util_split_string(item_id, "_")
      local item_type_id = str_list[2]
      if item_type_id ~= main_item_type_id then
        form.ImgaConcertGrid:ChangeItemImageToBW(i - 1, true)
        nBtn.Enabled = false
      end
      main_Equip_name = gui.TextManager:GetFormatText(main_item_id)
    end
  end
  hide_btn(form, nCounts)
  if 0 < form.nEquipIndex then
    CheckBaiban()
  end
end
function on_btn_qimen_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP_QIMEN_BOX))
  if not nx_is_valid(view) then
    return
  end
  if table.getn(view:GetViewObjList()) < 1 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_upgrade_equip_confirm", true, false)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_equipchange_qimen")
  gui.TextManager:Format_AddParam(nx_int(nEquipList[form.nEquipIndex].money))
  dialog.mltbox_1:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "sell_stall_price_input_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    form.cleaer_qimen_type = true
    nx_execute("custom_sender", "custom_chang_equip_qm", 0, form.nEquipIndex)
  end
end
