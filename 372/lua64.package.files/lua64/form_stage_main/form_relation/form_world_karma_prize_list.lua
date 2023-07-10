require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\itemtype_define")
require("util_static_data")
local FORM_WORLD_KARMA_PRIZE_LIST = "form_stage_main\\form_relation\\form_world_karma_prize_list"
local KARMA_PRIZE_TYPE_ADD = 10
local KARMA_PRIZE_TYPE_DEC = -10
local KARMA_PRIZE_TYPE_MONEY_BIND = 1
local KARMA_PRIZE_TYPE_MONEY = 2
local KARMA_PRIZE_TYPE_ITEM = 3
local KARMA_PRIZE_TYPE_BUFFER = 4
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function addItem(form, configid, type, prize_type, time_out_text, common_text, ...)
  local gui = nx_value("gui")
  if time_out_text == "" then
    nx_execute("custom_sender", "apply_add_npc_relation", nx_int(8), nx_string(configid), nx_int(0))
  end
  form.groupbox_template.Visible = false
  local new_item
  local is_find = false
  local child_table = form.group_prize:GetChildControlList()
  local child_count = table.getn(child_table)
  if 0 < child_count then
    for i = 1, child_count do
      local child = child_table[i]
      if nx_find_custom(child, "configid") and nx_string(child.configid) == nx_string(configid) then
        is_find = true
        new_item = child
      end
    end
  end
  if time_out_text == "" then
    if is_find then
      if nx_is_valid(new_item) then
        form.group_prize:Remove(new_item)
        gui:Delete(new_item)
        form.group_prize:ResetChildrenYPos()
        local child_list = form.group_prize:GetChildControlList()
        if table.getn(child_list) == 1 then
          form:Close()
        end
        return
      end
    else
      return
    end
  end
  if not is_find then
    new_item = getNewItem(form)
  end
  if not nx_is_valid(new_item) then
    return
  end
  new_item.configid = configid
  local photo = ""
  local num = 0
  local str_uid = ""
  form.data_prize_type = nx_int(prize_type)
  if nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_ADD) then
    photo = "gui\\special\\sns_new\\btn_enchou_price\\good.png"
    str_uid = arg[1]
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_DEC) then
    photo = "gui\\special\\sns_new\\btn_enchou_price\\bad.png"
    str_uid = arg[1]
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_MONEY_BIND) then
    photo = "icon\\prop\\suiyinzi.png"
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_MONEY) then
    photo = "icon\\prop\\yinzi01.png"
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_ITEM) then
    if table.getn(arg) == 0 then
      return
    end
    local ItemQuery = nx_value("ItemQuery")
    if not nx_is_valid(ItemQuery) then
      return
    end
    local item_config = nx_string(arg[1])
    if item_config == "" then
      return
    end
    num = nx_int(arg[2])
    local item_type = nx_number(ItemQuery:GetItemPropByConfigID(item_config, "ItemType"))
    if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_config, "Photo")
    else
      photo = ItemQuery:GetItemPropByConfigID(item_config, "Photo")
    end
    form.data_config = item_config
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_BUFFER) then
    if table.getn(arg) == 0 then
      return
    end
    local buffer_id = nx_string(arg[1])
    if buffer_id == "" then
      return
    end
    photo = buff_static_query(nx_string(buffer_id), "Photo")
    form.data_config = buffer_id
  end
  new_item.imagegrid_item:Clear()
  local table_uid_list = util_split_string(nx_string(str_uid), ",")
  num = table.getn(table_uid_list)
  local real_num = 0
  for i = 1, num do
    local uid_len = nx_string(string.len(table_uid_list[i]))
    if nx_number(uid_len) == nx_number(32) then
      real_num = real_num + 1
    end
  end
  if 1 < nx_number(real_num) then
    new_item.imagegrid_item:AddItem(0, photo, nx_widestr(""), nx_int(real_num), -1)
  else
    new_item.imagegrid_item:AddItem(0, photo, nx_widestr(""), nx_int(0), -1)
  end
  new_item.lbl_timeout.Text = nx_widestr(time_out_text)
  new_item.mltbox_info:Clear()
  new_item.mltbox_info:AddHtmlText(nx_widestr(common_text), -1)
  new_item.btn_take.configid = configid
  new_item.btn_take.type = type
  new_item.btn_take.str_uid = str_uid
  if not is_find then
    form.group_prize:Add(new_item)
    form.group_prize.IsEditMode = false
    form.group_prize:ResetChildrenYPos()
  end
end
function getNewItem(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return nil
  end
  local item = gui:Create("GroupBox")
  local tpl_item = form.groupbox_template
  if not nx_is_valid(item) or not nx_is_valid(tpl_item) then
    return nil
  end
  item.canremove = true
  item.Left = tpl_item.Left
  item.Top = tpl_item.Top
  item.Width = tpl_item.Width
  item.Height = tpl_item.Height
  item.BackColor = tpl_item.BackColor
  item.NoFrame = tpl_item.NoFrame
  item.BackImage = tpl_item.BackImage
  item.DrawMode = tpl_item.DrawMode
  item.AutoSize = item.AutoSize
  local tpl_imagegrid = tpl_item:Find("imagegrid_item")
  if nx_is_valid(tpl_imagegrid) then
    local imagegrid_item = gui:Create("ImageGrid")
    imagegrid_item.Left = tpl_imagegrid.Left
    imagegrid_item.Top = tpl_imagegrid.Top
    imagegrid_item.Width = tpl_imagegrid.Width
    imagegrid_item.Height = tpl_imagegrid.Height
    imagegrid_item.HasVScroll = tpl_imagegrid.HasVScroll
    imagegrid_item.SelectColor = tpl_imagegrid.SelectColor
    imagegrid_item.MouseInColor = tpl_imagegrid.MouseInColor
    imagegrid_item.GridHeight = tpl_imagegrid.GridHeight
    imagegrid_item.GridWidth = tpl_imagegrid.GridWidth
    imagegrid_item.GridsPos = tpl_imagegrid.GridsPos
    imagegrid_item.DrawGridBack = tpl_imagegrid.DrawGridBack
    imagegrid_item.GridBackOffsetX = tpl_imagegrid.GridBackOffsetX
    imagegrid_item.GridBackOffsetY = tpl_imagegrid.GridBackOffsetY
    imagegrid_item.ShowMouseDownState = tpl_imagegrid.ShowMouseDownState
    imagegrid_item.BlendColor = tpl_imagegrid.BlendColor
    imagegrid_item.BackColor = tpl_imagegrid.BackColor
    imagegrid_item.LineColor = tpl_imagegrid.LineColor
    imagegrid_item.ForeColor = tpl_imagegrid.ForeColor
    imagegrid_item.BackImage = tpl_imagegrid.BackImage
    imagegrid_item.Font = tpl_imagegrid.Font
    item:Add(imagegrid_item)
    item.imagegrid_item = imagegrid_item
  end
  local tpl_lbl = tpl_item:Find("lbl_timeout")
  if nx_is_valid(tpl_lbl) then
    local lbl_timeout = gui:Create("Label")
    lbl_timeout.Left = tpl_lbl.Left
    lbl_timeout.Top = tpl_lbl.Top
    lbl_timeout.Width = tpl_lbl.Width
    lbl_timeout.Height = tpl_lbl.Height
    lbl_timeout.BackImage = tpl_lbl.BackImage
    lbl_timeout.DrawMode = tpl_lbl.DrawMode
    lbl_timeout.AutoSize = tpl_lbl.AutoSize
    lbl_timeout.Font = tpl_lbl.Font
    lbl_timeout.ForeColor = tpl_lbl.ForeColor
    lbl_timeout.Align = tpl_lbl.Align
    item:Add(lbl_timeout)
    item.lbl_timeout = lbl_timeout
  end
  local tpl_mltbox = tpl_item:Find("mltbox_info")
  if nx_is_valid(tpl_mltbox) then
    local mltbox_info = gui:Create("MultiTextBox")
    mltbox_info.Left = tpl_mltbox.Left
    mltbox_info.Top = tpl_mltbox.Top
    mltbox_info.Width = tpl_mltbox.Width
    mltbox_info.Height = tpl_mltbox.Height
    mltbox_info.BackImage = tpl_mltbox.BackImage
    mltbox_info.DrawMode = tpl_mltbox.DrawMode
    mltbox_info.AutoSize = tpl_mltbox.AutoSize
    mltbox_info.NoFrame = tpl_mltbox.NoFrame
    mltbox_info.SelectBarColor = tpl_mltbox.SelectBarColor
    mltbox_info.MouseInBarColor = tpl_mltbox.MouseInBarColor
    mltbox_info.TextColor = tpl_mltbox.TextColor
    mltbox_info.ViewRect = tpl_mltbox.ViewRect
    mltbox_info.Font = tpl_mltbox.Font
    item:Add(mltbox_info)
    item.mltbox_info = mltbox_info
  end
  local tpl_btn = tpl_item:Find("btn_take")
  if nx_is_valid(tpl_btn) then
    local btn_take = gui:Create("Button")
    btn_take.Left = tpl_btn.Left
    btn_take.Top = tpl_btn.Top
    btn_take.Width = tpl_btn.Width
    btn_take.Height = tpl_btn.Height
    btn_take.NormalImage = tpl_btn.NormalImage
    btn_take.FocusImage = tpl_btn.FocusImage
    btn_take.PushImage = tpl_btn.PushImage
    btn_take.DrawMode = tpl_btn.DrawMode
    btn_take.AutoSize = tpl_btn.AutoSize
    btn_take.Text = tpl_btn.Text
    btn_take.Font = tpl_btn.Font
    btn_take.ForeColor = tpl_btn.ForeColor
    nx_bind_script(btn_take, nx_current())
    nx_callback(btn_take, "on_click", "on_btn_take_click")
    item:Add(btn_take)
    item.btn_take = btn_take
  end
  return item
end
function clearItem(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "configid_list") then
    return
  end
  local list = util_split_string(form.configid_list, ",")
  local configid_list = {}
  for i = 1, table.getn(list) do
    if list[i] ~= "" then
      configid_list[table.getn(configid_list) + 1] = list[i]
    end
  end
  local gui = nx_value("gui")
  local child_table = form.group_prize:GetChildControlList()
  local child_count = table.getn(child_table)
  for i = 1, child_count do
    local child = child_table[i]
    local is_find = false
    if nx_find_custom(child, "canremove") and nx_is_valid(child) and nx_find_custom(child, "configid") then
      for j = 1, table.getn(configid_list) do
        if nx_string(child.configid) == nx_string(configid_list[j]) then
          is_find = true
          break
        end
      end
      if not is_find and nx_is_valid(child) then
        form.group_prize:Remove(child)
        gui:Delete(child)
        form.group_prize.IsEditMode = false
        form.group_prize:ResetChildrenYPos()
      end
    end
  end
end
function on_btn_take_all_click(btn)
  local group_prize = btn.Parent.group_prize
  local child_table = group_prize:GetChildControlList()
  child_count = table.getn(child_table)
  if child_count > 0 then
    for i = 1, child_count do
      local child = child_table[i]
      if nx_find_custom(child, "btn_take") and nx_is_valid(child.btn_take) then
        on_btn_take_click(child.btn_take)
      end
    end
  end
  local form = btn.Parent
  form:Close()
end
function on_btn_take_click(btn)
  if nx_find_custom(btn, "type") and nx_find_custom(btn, "configid") then
    if nx_number(btn.type) ~= 5 then
      if nx_string(btn.configid) == "" then
        return
      end
      local table_uid_list = util_split_string(nx_string(btn.str_uid), ",")
      local num = table.getn(table_uid_list)
      if nx_number(num) <= nx_number(0) then
        return
      end
      for i = 1, num do
        local uid_len = nx_string(string.len(table_uid_list[i]))
        if nx_number(uid_len) == nx_number(32) then
          nx_execute("custom_sender", "apply_add_npc_relation", nx_int(btn.type), nx_string(table_uid_list[i]), nx_int(0), nx_string(btn.configid))
        end
      end
    else
      if nx_string(btn.configid) == "" then
        return
      end
      nx_execute("custom_sender", "apply_add_npc_relation", nx_int(5), nx_string(btn.configid), nx_int(0))
    end
  end
end
function on_btn_exit_click(self)
  local form = self.Parent
  form:Close()
end
