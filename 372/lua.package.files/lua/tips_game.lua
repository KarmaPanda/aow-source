require("share\\itemtype_define")
require("define\\tip_define")
require("share\\view_define")
require("share\\qinggong_define")
function console_log_down(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Out(info)
  end
end
function init_tip_game(form_main)
  local gui = nx_value("gui")
  if not nx_id_equal(gui.Desktop, form_main) then
    nx_msgbox(get_msg_str("msg_149"))
    return
  end
  form_main.array_list = nx_call("util_gui", "get_arraylist", "tips_game")
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:InitGameTips(form_main)
    form_main.tip_multitextbox1.Visible = false
    form_main.tip_multitextbox2.Visible = false
  end
  nx_set_value("tips_game", form_main)
end
function add_init_tips_game_link(form_main)
  local gui = nx_value("gui")
  if not nx_id_equal(gui.Desktop, form_main) then
    nx_msgbox(get_msg_str("msg_149"))
    return
  end
  form_main.array_list = nx_call("util_gui", "get_arraylist", "tips_game")
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:InitGameTips(form_main)
    form_main.tip_multitextbox1.Visible = false
    form_main.tip_multitextbox2.Visible = false
  end
end
function set_tips_owner(owner)
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  form_main.owner = owner
end
function get_tips_owner()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return nil
  end
  if not nx_find_custom(form_main, "owner") then
    return nil
  end
  return form_main.owner
end
function move_tip_to_front()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(form_main) then
    form_main:ToFront(form_main.tip_multitextbox)
  end
end
function get_tip_textbox(index)
  local gui = nx_value("gui")
  local form_main = gui.Desktop
  local tip_control
  if not (nx_find_custom(form_main, "tip_multitextbox") and nx_find_custom(form_main, "tip_multitextbox1")) or not nx_find_custom(form_main, "tip_multitextbox2") then
    return nil
  end
  if index == nil or index == 0 then
    tip_control = form_main.tip_multitextbox
  elseif index == 1 then
    tip_control = form_main.tip_multitextbox1
  elseif index == 2 then
    tip_control = form_main.tip_multitextbox2
  end
  if not nx_is_valid(tip_control) then
    return nil
  end
  if nx_find_custom(tip_control, "buf_text") then
    tip_control.buf_text = ""
  else
  end
  return tip_control
end
function get_equip3d_tip_form(index)
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  if nx_string(index) == "new" then
    if not nx_find_custom(desktop, "equip_tips_new") then
      return
    end
    local equip_tip = desktop.equip_tips_new
    equip_tip.mltbox_name:Clear()
    equip_tip.mltbox_left:Clear()
    equip_tip.mltbox_prop:Clear()
    equip_tip.mltbox_price:Clear()
    equip_tip.mltbox_desc:Clear()
    equip_tip.lbl_type.Text = nx_widestr("")
    equip_tip.lbl_biankuang.Visible = false
    equip_tip.lbl_photo.Visible = false
    equip_tip.lbl_kuang.Visible = false
    equip_tip.lbl_name.Visible = false
    equip_tip.lbl_type.Visible = false
    equip_tip.groupbox_puzzle_prop.Visible = false
    equip_tip.groupbox_puzzle_skill.Visible = false
    equip_tip.lbl_name_back.Visible = false
    equip_tip.lbl_seal.Visible = false
    equip_tip.lbl_equip_yes.Visible = false
    equip_tip.lbl_equip_no.Visible = false
    local name = ""
    local index = 0
    local Max = 8
    local flag = ""
    return desktop.equip_tips_new
  elseif nx_string(index) == "new2" then
    if not nx_find_custom(desktop, "equip_tips_new2") then
      return
    end
    local equip_tip = desktop.equip_tips_new2
    equip_tip.mltbox_name:Clear()
    equip_tip.mltbox_left:Clear()
    equip_tip.mltbox_prop:Clear()
    equip_tip.mltbox_price:Clear()
    equip_tip.mltbox_desc:Clear()
    equip_tip.lbl_biankuang.Visible = false
    equip_tip.lbl_type.Text = nx_widestr("")
    equip_tip.lbl_photo.Visible = false
    equip_tip.lbl_kuang.Visible = false
    equip_tip.lbl_type.Visible = false
    equip_tip.groupbox_puzzle_prop.Visible = false
    equip_tip.groupbox_puzzle_skill.Visible = false
    equip_tip.lbl_name.Visible = false
    equip_tip.lbl_name_back.Visible = false
    local name = ""
    local flag = ""
    local index = 0
    local Max = 8
    return desktop.equip_tips_new2
  else
    return nil
  end
end
function hide_link_tips(owner)
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    if owner == nil or nx_string(owner) == "" then
      owner = "0-0"
    end
    tips_manager:ClearLinkTips(owner)
  end
end
function hide_tip(owner)
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    if owner == nil or nx_string(owner) == "" then
      owner = "0-0"
    end
    tips_manager:HideTips(owner)
  end
  if owner ~= nil and nx_string(get_tips_owner()) ~= nx_string(owner) then
    return
  end
  set_tips_owner(nil)
  local tip_control = get_tip_textbox()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  local gui = nx_value("gui")
  if nx_is_valid(tip_control) and nx_is_valid(form_main) then
    tip_control.Visible = false
    if nx_find_custom(tip_control, nx_string("scene")) then
      tip_control.scene.Visible = false
      nx_execute("util_gui", "ui_ClearModel", tip_control.scene)
    end
  end
  local tip_control1 = get_tip_textbox(1)
  if nx_is_valid(tip_control1) then
    tip_control1.Visible = false
  end
  local tip_control2 = get_tip_textbox(2)
  if nx_is_valid(tip_control2) then
    tip_control2.Visible = false
  end
  equip_tip = get_equip3d_tip_form("new")
  if nx_is_valid(equip_tip) then
    equip_tip.Visible = false
    equip_tip.lbl_photo.Height = 90
    equip_tip.lbl_photo.Width = 90
    equip_tip.IsShiftPress = false
  end
  equip_tip = get_equip3d_tip_form("new2")
  if nx_is_valid(equip_tip) then
    equip_tip.Visible = false
    equip_tip.IsShiftPress = false
  end
  if nx_running("tips_func_equip", "rotate_x") then
    nx_kill("tips_func_equip", "rotate_x")
  end
end
function init_tip_textbox(tip_control, width)
  tip_control:Clear()
  if width == nil or nx_number(width) <= 0 then
    width = tip_control.TipMaxWidth
  end
  tip_control.Width = 20 + width
  tip_control.ViewRect = "10,10," .. nx_string(nx_int(width) + nx_int(10)) .. "," .. 50
end
function autosize_tip_textbox(tip_control, x, y, width)
  local gui = nx_value("gui")
  if width == nil or nx_string(width) == nx_string("") or nx_number(width) <= 0 then
    width = 20 + tip_control:GetContentWidth()
  else
    width = 20 + width
  end
  local height = 20 + tip_control:GetContentHeight()
  local real_width = width
  local real_height = height
  local real_x = x + 32
  local real_y = y + 32
  if real_x + real_width > gui.Width then
    real_x = x - real_width
  end
  if real_y + real_height > gui.Height then
    if y > real_height then
      real_y = y - real_height
    else
      real_y = gui.Height - real_height
    end
  end
  tip_control.AbsLeft = real_x
  tip_control.AbsTop = real_y
  tip_control.Width = width
  tip_control.Height = height
  local right = width - 10
  if right <= 10 then
    right = 11
  end
  tip_control.ViewRect = "10,10," .. nx_string(right) .. "," .. height - 10
end
function show_text_tip(tipinfo, x, y, width, owner)
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  if width == nil then
    width = -1
  end
  if owner == nil then
    owner = "0-0"
  end
  tips_manager:ShowTextTips(tipinfo, x, y, width, owner)
end
function show_special_buffer_tip(x, y, targettype, type, owner)
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  tips_manager:ShowSpecialBufferTips(x, y, targettype, type, owner)
end
function need_show_tip(item)
  local item_type = nx_execute("tips_func_equip", "get_item_type", item)
  item_type = nx_number(item_type)
  if item_type == 1100 then
    return false
  end
  return true
end
function show_tips(tip_control, item, x, y)
  if not nx_find_custom(item, "b_in_shortcut") then
    item.b_in_shortcut = false
  end
  local item_type = nx_execute("tips_func_equip", "get_item_type", item)
  item_type = nx_number(item_type)
  local ConfigID = nx_execute("tips_data", "get_prop_in_item", item, "ConfigID")
  if item_type == ITEMTYPE_SPY_ITEM or item_type == ITEMTYPE_SPY_PATROL then
    local goods_grid = nx_value("GoodsGrid")
    item = goods_grid:GetItem(ConfigID)
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    local item_type = nx_execute("tips_func_equip", "get_item_type", item)
    tips_manager:ShowTips(ConfigID, item, nx_int(item_type), x, y, "0-0", false)
  end
end
function get_props_by_itemtype(item, item_type)
  local table_info = {}
  item_type = nx_number(item_type)
  local show_type = "goods"
  if item_type >= ITEMTYPE_ADDHP and item_type <= ITEMTYPE_ADDMP_SUPER then
    table_info = item_table_goods_drug
  elseif item_type >= ITEMTYPE_OFFLINE_MIN and item_type <= ITEMTYPE_OFFLINE_MAX then
    table_info = item_table_goods_drug
  elseif item_type >= ITEMTYPE_NEIGONG_BOOK and item_type <= ITEMTYPE_ZHENFA_BOOK then
    table_info = item_table_goods_book
  elseif item_type == ITEMTYPE_JM_FACULTY then
    table_info = item_table_jm_Faculty
  elseif item_type == ITEMTYPE_JMSKILL_FACULTY then
    table_info = item_table_jm_skill_Faculty
  elseif item_type == ITEMTYPE_ADDBAG then
    table_info = item_table_addbag
  elseif item_type == ITEMTYPE_MOUNT then
    table_info = item_table_mount
  elseif item_type == ITEMTYPE_COMPOSITE_FORMULA then
    table_info = item_table_formula
  elseif item_type == ITEMTYPE_LUCK then
    table_info = item_table_renmai
  elseif item_type == ITEMTYPE_QIPU then
    table_info = item_table_qpcj
  elseif item_type == ITEMTYPE_SEED then
    table_info = item_table_seed
  elseif item_type == ITEMTYPE_LIFE_TOOL then
    table_info = item_table_life
  elseif item_type == ITEMTYPE_SPY_ITEM then
    table_info = item_table_spy_item
  elseif item_type == ITEMTYPE_SPY_PATROL then
    table_info = item_table_spy_patrol
  elseif item_type == ITEMTYPE_SCHOOL_WAR then
    table_info = item_table_school_war
  elseif item_type <= ITEMTYPE_TOOLITEM_MAX then
    table_info = item_table_toolitem
  elseif item_type == ITEMTYPE_ZAWU then
    table_info = item_table_toolitem
  elseif item_type == ITEMTYPE_COMPOSE_QUPU then
    table_info = item_table_qupu
  elseif item_type >= ITEMTYPE_ZHAOSHI and item_type <= ITEMTYPE_PUZZLE_SKILL then
    show_type = "skill"
    if item_type == ITEMTYPE_ZHAOSHI or item_type == ITEMTYPE_LOCKZHAOAHI then
      table_info = item_table_skill_info
    elseif item_type == ITEMTYPE_NEIGONG then
      table_info = item_table_neigong
    elseif item_type == ITEMTYPE_QINGGONG then
      table_info = item_table_qinggong
    elseif item_type == ITEMTYPE_JINGMAI then
      table_info = item_table_jingmai
    elseif item_type == ITEMTYPE_XUEWEI then
      table_info = item_table_xuewei
    elseif item_type == ITEMTYPE_ZHENFA then
      table_info = item_table_zhenfa
    elseif item_type == ITEMTYPE_ANQI_SHOUFA then
      table_info = item_table_anqi_shoufa
    elseif item_type == ITEMTYPE_HUIHAI_SKILL then
      table_info = item_table_jingfa
    elseif item_type == ITEMTYPE_ANQI_NORMAL then
      table_info = item_table_anqi_normal
    elseif item_type == ITEMTYPE_CHESS_SKILL then
      table_info = item_table_Chess_Skill
    elseif item_type == ITEMTYPE_QG_TYPE then
      table_info = item_table_qg_type
    elseif item_type == ITEMTYPE_PUZZLE_SKILL then
      table_info = item_table_puzzle_skill
    else
      table_info = item_table_skill_info
    end
  elseif item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    show_type = "equip"
    if item_type >= ITEMTYPE_WEAPON_HIDDEN and item_type <= ITEMTYPE_WEAPON_ARROR then
      table_info = item_table_Equip_hidden
    elseif item_type == ITEMTYPE_WEAPON_PAINT then
      table_info = item_table_Equip_FacultyBook
    elseif item_type == ITEMTYPE_WEAPON_BOOK then
      table_info = item_table_Equip_FacultyBook
    else
      table_info = item_table_Equip_other
    end
  elseif item_type > ITEMTYPE_COMPOSE_MATRIAL_MIN and item_type < ITEMTYPE_COMPOSE_MATRIAL_MAX then
    show_type = "goods"
    table_info = item_table_composite_material
  end
  if table_info == nil or table.getn(table_info) == 0 then
    table_info = item_table_toolitem
  end
  return table_info, show_type
end
function get_text_by_props(tip_control, item, table_info, show_type)
  local lua_name = "tips_func_equip"
  if nx_string(show_type) == "skill" then
    lua_name = "tips_func_skill"
  elseif nx_string(show_type) == "puzzle_skill" then
    lua_name = "tips_func_skill"
  elseif nx_string(show_type) == "goods" then
    lua_name = "tips_func_goods"
  end
  tip_control.is_show = false
  local text = ""
  if table_info == nil then
    return ""
  end
  for i = 1, table.getn(table_info) do
    local key = table_info[i][1]
    if key == "func" then
      local func = table_info[i][2]
      local _type = table_info[i][3]
      if nx_string(func) == "get_desc_info" then
        text = nx_execute("tips_func_equip", func, item)
      elseif nx_string(func) == "show_neigong_prop_info" then
        local prop, next_prop, change_prop = nx_execute(lua_name, func, item)
        text = prop
        if nil ~= next_prop then
          tip_control.mltbox_icon_next:Clear()
          tip_control.mltbox_icon_change:Clear()
          tip_control.mltbox_icon_next:AddHtmlText(nx_widestr(next_prop), -1)
          tip_control.mltbox_icon_change:AddHtmlText(nx_widestr(change_prop), -1)
          tip_control.mltbox_icon_next.Visible = true
          tip_control.mltbox_icon_change.Visible = true
        else
          tip_control.mltbox_icon_next.Visible = false
          tip_control.mltbox_icon_change.Visible = false
        end
      else
        text = nx_execute(lua_name, func, item)
      end
      if _type == POS_LEFT then
        tip_control.buf_text_left = nx_string(tip_control.buf_text_left) .. nx_string(text)
      elseif _type == POS_PRICE then
        tip_control.buf_text_price = nx_string(tip_control.buf_text_price) .. nx_string(text)
      elseif _type == POS_DESC then
        tip_control.buf_text_desc = nx_string(tip_control.buf_text_desc) .. nx_string(text)
      else
        tip_control.buf_text = nx_string(tip_control.buf_text) .. nx_string(text)
      end
    elseif key == "include" then
    else
      if key == "include_next_level" then
        local func = table_info[i][2]
        local next_level_text = table_info[i][3]
        local is_show, next_text = nx_execute(lua_name, func, item, next_level_text)
        tip_control.buf_text_desc = nx_string(tip_control.buf_text_desc) .. nx_string(next_text)
        tip_control.is_show = is_show
        if not is_show then
          return
        end
      else
      end
    end
  end
end
function show_seal(equip_tip, color_level)
  local index = nx_number(color_level)
  local photo = global_seal_photo[index]
  equip_tip.lbl_seal.Visible = true
  equip_tip.lbl_seal.BackImage = nx_string(photo)
end
function add_name_to_form(equip_tip, item, tips_type)
  local text = ""
  local item_type = nx_execute("tips_func_equip", "get_item_type", item)
  local name_back_image = equip_tip.lbl_name_back
  name_back_image.Visible = false
  equip_tip.lbl_name.Visible = false
  equip_tip.mltbox_name.Visible = true
  equip_tip.lbl_seal.Visible = false
  local show_name = nx_execute("tips_data", "get_prop_in_item", item, "ShowName")
  show_name = nx_string(show_name)
  if tips_type == "skill" and (item_type == ITEMTYPE_ZHAOSHI or item_type == ITEMTYPE_LOCKZHAOAHI) then
    text = nx_execute("tips_func_skill", "show_name_with_colorlevel", item)
  elseif tips_type == "equip" then
    name_back_image.Visible = true
    equip_tip.lbl_name.Visible = true
    equip_tip.mltbox_name.Visible = false
    name_back_image.Top = equip_tip.lbl_name.Top
    name_back_image.Left = 40
    name_back_image.Width = 230
    text = nx_execute("tips_func_equip", "get_name", item)
    if show_name ~= "" then
      text = show_name
    end
    local color_level = nx_execute("tips_func_equip", "get_colorlevel", item)
    equip_tip.lbl_name.Text = nx_widestr(text)
    equip_tip.lbl_name.ForeColor = global_color_list_rgb[nx_number(color_level)]
    show_seal(equip_tip, color_level)
    return
  elseif tips_type == "goods" then
    text = nx_execute("tips_func_equip", "show_name_with_colorlevel", item)
  else
    text = nx_execute("tips_func_equip", "show_name_with_colorlevel", item)
  end
  if show_name ~= "" then
    text = show_name
  end
  equip_tip.mltbox_name:AddHtmlText(nx_widestr(text), -1)
end
function add_text_to_form(equip_tip, item, tips_type)
  if not nx_is_valid(equip_tip) then
    return
  end
  if not need_show_tip(item) then
    return
  end
  equip_tip.Visible = true
  local text = ""
  add_name_to_form(equip_tip, item, tips_type)
  equip_tip.mltbox_left:AddHtmlText(nx_widestr(equip_tip.buf_text_left), -1)
  equip_tip.mltbox_prop:AddHtmlText(nx_widestr(equip_tip.buf_text), -1)
  text = ""
  if tips_type ~= "skill" then
    local price = nx_execute("tips_func_equip", "get_price_info", equip_tip, item)
    equip_tip.mltbox_price:AddHtmlText(nx_widestr(price), -1)
    text = ""
  else
    text = equip_tip.buf_text_price
    equip_tip.mltbox_price:AddHtmlText(nx_widestr(text), -1)
  end
  text = equip_tip.buf_text_desc
  equip_tip.mltbox_desc:AddHtmlText(nx_widestr(text), -1)
end
function show_sub_mltbox(mltbox, height, offset_left, offset, bLeft)
  if mltbox:GetContentWidth() > 0 then
    mltbox.Visible = true
    mltbox.Left = offset_left
    mltbox.Top = height
    local _width = mltbox.Parent.Width - offset_left - offset_left
    if bLeft then
      _width = _width - 70
    end
    mltbox.Width = _width
    mltbox.Height = mltbox:GetContentHeight()
    height = mltbox.Top + mltbox.Height
    height = height + offset
    mltbox.ViewRect = "0,0," .. mltbox.Width .. "," .. mltbox.Height
  else
    mltbox.Visible = false
  end
  return height
end
function get_mltbox(form_tips, mltbox_copy, flag, index)
  local mltbox
  local gui = nx_value("gui")
  if not nx_is_valid(form_tips) or not nx_is_valid(mltbox_copy) then
    nx_msgbox(get_msg_str("msg_465"))
    return nil
  end
  local name = nx_string(flag) .. nx_string(index)
  mltbox = form_tips:Find(name)
  if not nx_is_valid(mltbox) then
    mltbox = gui:Create("MultiTextBox")
    if nx_is_valid(mltbox) then
      form_tips:Add(mltbox)
      local list_prop_table = nx_property_list(mltbox_copy)
      for i = 1, table.maxn(list_prop_table) do
        local value = nx_property(mltbox_copy, list_prop_table[i])
        nx_set_property(mltbox, list_prop_table[i], value)
      end
      mltbox.Name = name
      mltbox:Clear()
    end
  else
    mltbox:Clear()
  end
  return mltbox
end
function autosize_puzzle()
end
function show_skill_next(is_show)
  local gui = nx_value("gui")
  local form_main = gui.Desktop
  if not nx_is_valid(form_main) then
    return
  end
  local equip_tip = form_main.equip_tips_new
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  if equip_tip.Visible then
    tips_manager:ShowSkillNextInfo(is_show)
  end
end
function autosize_tips_form(equip_tip, item, x, y, tips_type, item_type)
  local gui = nx_value("gui")
  equip_tip.item = item
  equip_tip.x = x
  equip_tip.y = y
  equip_tip.tips_type = tips_type
  equip_tip.item_type = item_type
  local height = 0
  local height_left = 24
  local offset = 0
  local offset_left = 27
  height_left = show_sub_mltbox(equip_tip.mltbox_name, height_left, offset_left, offset)
  height_left = height_left + 1
  equip_tip.groupbox_puzzle_prop.Visible = false
  equip_tip.groupbox_puzzle_skill.Visible = false
  autosize_photo(equip_tip, item, tips_type, offset_left)
  tips_type = nx_string(tips_type)
  if tips_type == "skill" then
    height = equip_tip.lbl_type.Top + equip_tip.lbl_type.Height
  elseif tips_type == "puzzle_skill" then
    equip_tip.groupbox_puzzle_skill.Visible = true
  elseif tips_type == "goods" then
    height = equip_tip.lbl_kuang.Top + equip_tip.lbl_kuang.Height
    local name_back_image = equip_tip.lbl_name_back
    local mlt_name = equip_tip.mltbox_name
    name_back_image.Visible = true
    name_back_image.Top = mlt_name.Top
    name_back_image.Left = mlt_name.Left
    name_back_image.Width = 155
  else
    height_left = equip_tip.scenebox_1.Top
    height = equip_tip.scenebox_1.Top + equip_tip.scenebox_1.Height
  end
  height_left = show_sub_mltbox(equip_tip.mltbox_left, height_left, offset_left, offset, true)
  if height < height_left then
    height = height_left
  end
  height = height + 1
  height = show_sub_mltbox(equip_tip.mltbox_prop, height, offset_left, offset + 4)
  if item_type == ITEMTYPE_NEIGONG then
    show_ng_icon(equip_tip.mltbox_icon_next, equip_tip.mltbox_prop, 18)
    show_ng_icon(equip_tip.mltbox_icon_change, equip_tip.mltbox_icon_next, 1)
  else
    equip_tip.mltbox_icon_next.Visible = false
    equip_tip.mltbox_icon_change.Visible = false
  end
  height = show_sub_mltbox(equip_tip.mltbox_price, height, offset_left, offset)
  if tips_type == "skill" then
    local left = equip_tip.Width - offset_left - equip_tip.mltbox_price:GetContentWidth()
    equip_tip.mltbox_price.Left = left
  end
  local xian = equip_tip.lbl_xian
  xian.Visible = false
  if tips_type == "skill" then
    if nx_find_custom(item, "IsMaxLevel") and item.IsMaxLevel then
      equip_tip.mltbox_desc:Clear()
    end
    if nx_find_custom(item, "b_in_shortcut") and item.b_in_shortcut then
      equip_tip.mltbox_desc:Clear()
    end
    if nx_find_custom(equip_tip, "IsShiftPress") then
      if equip_tip.IsShiftPress then
        height = show_sub_mltbox(equip_tip.mltbox_desc, height, offset_left, offset)
      else
        equip_tip.mltbox_desc.Visible = false
      end
    end
    if item_type == ITEMTYPE_NEIGONG then
      height = show_sub_mltbox(equip_tip.mltbox_desc, height, offset_left, offset)
    end
  else
    height = show_sub_mltbox(equip_tip.mltbox_desc, height, offset_left, offset)
  end
  height = height + 20
  if equip_tip.groupbox_puzzle_prop.Visible then
    height = height + equip_tip.groupbox_puzzle_prop.Height - 25
  elseif "puzzle_skill" == tips_type and equip_tip.groupbox_puzzle_prop.Visible then
    height = height + equip_tip.groupbox_puzzle_skill.Height - 25
  end
  equip_tip.lbl_backImage.Height = height
  equip_tip.Height = height
  local real_width = equip_tip.Width
  local real_height = height
  local real_x = x + 32
  local real_y = y + 32
  if real_x + real_width > gui.Width then
    real_x = x - real_width
  end
  if real_y + real_height > gui.Height then
    if y > real_height then
      real_y = y - real_height
    else
      real_y = gui.Height - real_height
    end
  end
  equip_tip.AbsLeft = real_x
  equip_tip.AbsTop = real_y
  equip_tip.groupbox_puzzle_prop.Left = equip_tip.lbl_backImage.Left
  equip_tip.groupbox_puzzle_prop.Top = equip_tip.lbl_backImage.Top + equip_tip.lbl_backImage.Height - equip_tip.groupbox_puzzle_prop.Height
  if nx_find_custom(item, "b_in_shortcut") and item.b_in_shortcut then
    equip_tip.AbsLeft = gui.Width - real_width - 4
    equip_tip.AbsTop = gui.Height - real_height - 30
  end
end
function show_ng_icon(mltbox, mltbox_prop, offset)
  mltbox.Left = mltbox_prop.Left + mltbox_prop:GetContentWidth() + offset
  mltbox.Top = mltbox_prop.Top
  mltbox.Width = mltbox:GetContentWidth()
  mltbox.Height = mltbox_prop.Height
  mltbox.ViewRect = mltbox_prop.ViewRect
end
function autosize_photo(equip_tip, item, tips_type, offset_left)
  equip_tip.scenebox_1.Visible = false
  equip_tip.lbl_equip_yes.Visible = false
  equip_tip.lbl_equip_no.Visible = false
  equip_tip.lbl_biankuang.Visible = false
  equip_tip.lbl_type.Visible = false
  equip_tip.lbl_equip_yes.BackImage = "gui\\language\\ChineseS\\yizhuangbei.png"
  equip_tip.lbl_equip_no.BackImage = "gui\\language\\ChineseS\\weizhuangbei.png"
  local item_type = nx_execute("tips_func_equip", "get_item_type", item)
  local photo = ""
  local _type = ""
  local form_width = equip_tip.Width
  local kuang_top = 16
  local kuang_left = 16
  tips_type = nx_string(tips_type)
  if tips_type == "skill" then
    _type = nx_execute("tips_func_equip", "show_zhaoshi_type", item)
    equip_tip.lbl_type.BackImage = nx_string(_type)
    equip_tip.lbl_kuang.Visible = false
    equip_tip.lbl_photo.Visible = false
    equip_tip.lbl_type.Visible = true
    equip_tip.lbl_type.Left = 0 - equip_tip.lbl_type.Width - 12
    equip_tip.lbl_type.Top = equip_tip.mltbox_name.Top - 8
    local need_equip_yes = false
    item_type = nx_number(item_type)
    if item_type == nx_number(ITEMTYPE_NEIGONG) then
      need_equip_yes = true
      equip_tip.lbl_equip_yes.BackImage = "gui\\language\\ChineseS\\fighttips\\yiyungong.png"
      equip_tip.lbl_equip_no.BackImage = "gui\\language\\ChineseS\\fighttips\\weiyungong.png"
      local ConfigID = nx_execute("tips_data", "get_prop_in_item", item, "ConfigID")
      local is_cur = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "check_is_curneigong", ConfigID)
      if is_cur then
        equip_tip.lbl_equip_yes.Visible = true
        equip_tip.lbl_equip_no.Visible = false
      else
        equip_tip.lbl_equip_yes.Visible = false
        equip_tip.lbl_equip_no.Visible = true
      end
    elseif item_type == nx_number(ITEMTYPE_QINGGONG) then
      need_equip_yes = true
      equip_tip.lbl_equip_yes.BackImage = "gui\\language\\ChineseS\\zi-zhudong.png"
      equip_tip.lbl_equip_no.BackImage = "gui\\language\\ChineseS\\zi-beidong.png"
      local is_zhudong = false
      if is_zhudong then
        equip_tip.lbl_equip_yes.Visible = true
        equip_tip.lbl_equip_no.Visible = false
      else
        equip_tip.lbl_equip_yes.Visible = false
        equip_tip.lbl_equip_no.Visible = true
      end
    elseif item_type == nx_number(ITEMTYPE_ANQI_SHOUFA) then
      need_equip_yes = true
      equip_tip.lbl_equip_yes.BackImage = "gui\\language\\ChineseS\\zi-zhudong.png"
      equip_tip.lbl_equip_no.BackImage = "gui\\language\\ChineseS\\zi-beidong.png"
      equip_tip.lbl_equip_yes.Visible = false
      equip_tip.lbl_equip_no.Visible = true
    end
    if need_equip_yes then
      equip_tip.lbl_equip_yes.Top = kuang_top + equip_tip.lbl_type.Height - equip_tip.lbl_equip_yes.Height
      equip_tip.lbl_equip_no.Top = equip_tip.lbl_equip_yes.Top
      equip_tip.lbl_equip_yes.AbsLeft = equip_tip.lbl_type.AbsLeft - 24
      equip_tip.lbl_equip_no.Left = equip_tip.lbl_equip_yes.Left
    end
  elseif tips_type == "goods" then
    equip_tip.lbl_kuang.Visible = true
    equip_tip.lbl_photo.Visible = true
    equip_tip.lbl_biankuang.Visible = true
    if nx_number(item_type) == nx_number(ITEMTYPE_MOUNT) then
      local config_id = nx_execute("tips_data", "get_prop_in_item", item, "ConfigID")
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id_Ex", nx_string(config_id), nx_string("Photo"))
    elseif nx_number(item_type) == nx_number(ITEMTYPE_JMSKILL_FACULTY) then
      local config_id = nx_execute("tips_data", "get_prop_in_item", item, "ConfigID")
      local jewel_game_manager = nx_value("jewel_game_manager")
      if nx_is_valid(jewel_game_manager) then
        photo = jewel_game_manager:GetJMPhoto(nx_string(config_id))
      end
    else
      photo = nx_execute("tips_func_equip", "show_image_prop", item)
    end
    kuang_top = equip_tip.mltbox_name.Top
    kuang_left = form_width - equip_tip.lbl_kuang.Width - offset_left
    equip_tip.lbl_kuang.Top = kuang_top
    equip_tip.lbl_kuang.Left = kuang_left
    equip_tip.lbl_photo.Left = kuang_left
    equip_tip.lbl_photo.Top = kuang_top
    equip_tip.lbl_biankuang.Left = kuang_left
    equip_tip.lbl_biankuang.Top = kuang_top
    equip_tip.lbl_photo.BackImage = nx_string(photo)
  elseif tips_type == "puzzle_skill" then
    _type = nx_execute("tips_func_equip", "show_zhaoshi_type", item)
    equip_tip.lbl_type.BackImage = nx_widestr(_type)
    equip_tip.lbl_kuang.Visible = false
    equip_tip.lbl_photo.Visible = false
    equip_tip.lbl_type.Visible = true
    equip_tip.lbl_type.Top = equip_tip.mltbox_name.Top
  else
    local ret = false
    if ret ~= false and ret ~= nil and ret ~= "" then
      equip_tip.lbl_photo.Visible = false
      equip_tip.lbl_kuang.Visible = false
      equip_tip.scenebox_1.Visible = true
    else
      local photo_link = nx_execute("util_static_data", "query_equip_photo_by_sex", item)
      equip_tip.lbl_photo.BackImage = photo_link
      equip_tip.lbl_photo.Visible = true
      equip_tip.lbl_kuang.Visible = true
      equip_tip.scenebox_1.Visible = false
    end
    equip_tip.lbl_biankuang.Visible = true
    local item_type = nx_execute("tips_func_equip", "get_item_type", item)
    if tonumber(item_type) == 200 then
      local used = nx_execute("tips_func_equip", "has_mount_used", item)
      equip_tip.lbl_equip_yes.Visible = used
      equip_tip.lbl_equip_no.Visible = not used
    else
      local used = nx_execute("tips_func_equip", "has_equip_used", item)
      equip_tip.lbl_equip_yes.Visible = used
      equip_tip.lbl_equip_no.Visible = not used
    end
    kuang_top = 16
    kuang_left = form_width - equip_tip.scenebox_1.Width - offset_left
    local lbl_name = equip_tip.lbl_name
    if lbl_name.Visible then
      kuang_top = lbl_name.Top + lbl_name.Height + 4
    end
    equip_tip.scenebox_1.Top = kuang_top
    equip_tip.scenebox_1.Left = kuang_left
    equip_tip.lbl_kuang.Top = kuang_top
    equip_tip.lbl_kuang.Left = kuang_left
    equip_tip.lbl_photo.Top = kuang_top
    equip_tip.lbl_photo.Left = kuang_left
    equip_tip.lbl_biankuang.Left = kuang_left
    equip_tip.lbl_biankuang.Top = kuang_top
    equip_tip.lbl_equip_yes.Top = kuang_top + equip_tip.lbl_kuang.Height - equip_tip.lbl_equip_yes.Height
    equip_tip.lbl_equip_no.Top = equip_tip.lbl_equip_yes.Top
    equip_tip.lbl_equip_yes.Left = kuang_left
    equip_tip.lbl_equip_no.Left = equip_tip.lbl_equip_yes.Left
    local half_width = equip_tip.lbl_seal.Width / 2
    local seal_left = 0
    if offset_left > half_width then
      seal_left = kuang_left + equip_tip.lbl_kuang.Width - half_width
    else
      seal_left = form_width - half_width
    end
    equip_tip.lbl_seal.Left = seal_left
    local half_height = equip_tip.lbl_seal.Height / 2
    local seal_top = 0
    if kuang_top > half_height then
      seal_top = kuang_top - half_height
    else
      seal_top = 4
    end
    equip_tip.lbl_seal.Top = seal_top
  end
end
function get_props_for_formula(tip_control, item)
  local item_type = nx_execute("tips_func_equip", "get_item_type", item)
  item.is_static = true
  local props_table, show_type = get_props_by_itemtype(item, item_type)
  tip_control.buf_text = ""
  tip_control.buf_text_left = ""
  tip_control.buf_text_desc = ""
  tip_control.buf_text_price = ""
  get_text_by_props(tip_control, item, props_table, show_type)
end
function show_compare_form(equip_tip, item, x, y, owner, is_link)
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) and tips_manager.InShortcut then
    return false
  end
  if owner == nil or nx_string(owner) == "" then
    owner = "0-0"
  end
  local gui = nx_value("gui")
  local equiptype = nx_execute("tips_data", "get_prop_in_item", item, "EquipType")
  local pos1, pos2, pos3 = nx_execute("goods_grid", "get_equip_pos_by_equiptype", equiptype)
  local cur_compare_item_pos = -1
  if nx_find_custom(item, "InContainerPos") then
    cur_compare_item_pos = nx_int(item.InContainerPos)
  end
  local pos_table = {}
  if pos1 == nil then
    pos_table = nil
    return false
  end
  pos_table[1] = pos1
  if pos2 ~= nil then
    pos_table[2] = pos2
    if pos3 ~= nil then
      pos_table[3] = pos2
    end
  end
  if pos_table == nil then
    return false
  end
  local count = table.maxn(pos_table)
  local game_client = nx_value("game_client")
  local equipbox = game_client:GetView(nx_string(VIEWPORT_EQUIP))
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(equipbox) or not nx_is_valid(form_main) then
    return false
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    for i = 1, count do
      local pos = pos_table[i]
      local view_item = equipbox:GetViewObj(nx_string(pos))
      if nx_is_valid(view_item) and (cur_compare_item_pos == nx_number(-1) or nx_number(cur_compare_item_pos) == nx_number(pos)) then
        local item_id = nx_execute("tips_data", "get_prop_in_item", view_item, "ConfigID")
        local item_type = nx_execute("tips_func_equip", "get_item_type", view_item)
        if true == is_link then
          tips_manager:ShowLinkCompareTips(item_id, view_item, nx_int(item_type), x, y, owner)
        else
          tips_manager:ShowCompareTips(item_id, view_item, nx_int(item_type), x, y, owner)
        end
        return true
      end
    end
  end
  return false
end
function show_3d_tips_one(item, x, y, owner, bCurEquip)
  if not nx_is_valid(item) then
    return
  end
  if owner == nil or nx_string(owner) == "" then
    owner = "0-0"
  end
  if bCurEquip == nil then
    bCurEquip = false
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    local item_id = nx_execute("tips_data", "get_prop_in_item", item, "ConfigID")
    local item_type = nx_execute("tips_func_equip", "get_item_type", item)
    tips_manager:ShowTips(nx_string(item_id), item, nx_int(item_type), x, y, owner, bCurEquip)
  end
end
function ShowOfflineEmployEquipTips(item, x, y, owner, bCurEquip, Sex)
  if not nx_is_valid(item) then
    return
  end
  if bCurEquip == nil then
    bCurEquip = false
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    local item_id = nx_execute("tips_data", "get_prop_in_item", item, "ConfigID")
    local item_type = nx_execute("tips_func_equip", "get_item_type", item)
    tips_manager:ShowOfflineEmployEquipTips(nx_string(item_id), item, nx_int(item_type), x, y, owner, bCurEquip, Sex)
  end
end
function show_goods_tip(item, x, y, width, height, owner, compare)
  if not nx_is_valid(item) then
    return
  end
  if owner == nil or nx_string(owner) == "" then
    owner = "0-0"
  end
  if compare == nil then
    compare = true
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    local item_id = nx_execute("tips_data", "get_prop_in_item", item, "ConfigID")
    local item_type = nx_execute("tips_func_equip", "get_item_type", item)
    tips_manager:ShowTips(item_id, item, nx_int(item_type), x, y, owner, false)
    if compare then
      show_compare_form("0-0", item, x, y, owner, false)
    end
  end
end
function show_link_good_tips(item, x, y, width, height, owner, uniqueid)
  if not nx_is_valid(item) then
    return
  end
  if owner == nil or nx_string(owner) == "" then
    owner = "0-0"
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    local item_id = nx_execute("tips_data", "get_prop_in_item", item, "ConfigID")
    local item_type = nx_execute("tips_func_equip", "get_item_type", item)
    local link_successful = tips_manager:ShowLinkTips(item_id, item, nx_int(item_type), x, y, owner, false, uniqueid)
    local compare_successful = false
    if link_successful then
      compare_successful = show_compare_form("0-0", item, x, y, owner, true)
      if false == compare_successful then
        tips_manager:ClearLinkTipsControlInfo(0)
        tips_manager:ClearLinkTipsControlInfo(1)
      end
    end
  end
end
function show_neigong_tip(item, x, y, owner)
  if not nx_is_valid(item) then
    return
  end
  if owner == nil or nx_string(owner) == "" then
    owner = "0-0"
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  local item_id = nx_execute("tips_data", "get_prop_in_item", item, "ConfigID")
  local item_type = nx_execute("tips_func_equip", "get_item_type", item)
  tips_manager:ShowTips(item_id, item, nx_int(item_type), x, y, owner, false)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindProp("CurNeiGong") then
    return
  end
  local cur_ng_id = client_player:QueryProp("CurNeiGong")
  local cur_item = nx_execute("tips_data", "get_item_in_view", VIEWPORT_NEIGONG, cur_ng_id)
  if not nx_is_valid(cur_item) then
    return
  end
  local cur_item_type = nx_execute("tips_func_equip", "get_item_type", cur_item)
  if nx_string(item_id) == nx_string(cur_ng_id) then
    return
  end
  tips_manager:ShowCompareTips(cur_ng_id, cur_item, nx_int(cur_item_type), x, y, owner)
end
function show_tips_by_config(config_id, x, y, owner)
  local item = get_tips_ArrayList()
  item.is_static = true
  item.ConfigID = config_id
  item.ItemType = nx_execute("tips_data", "get_prop_by_configid", config_id, "ItemType")
  show_3d_tips_one(item, x, y, owner)
end
function show_tips_by_config_more(config_id, amount, bind, x, y, owner)
  local item = get_tips_ArrayList()
  item.ConfigID = config_id
  item.Amount = amount
  item.BindStatus = bind
  item.ItemType = nx_execute("tips_data", "get_prop_by_configid", config_id, "ItemType")
  show_3d_tips_one(item, x, y, owner)
end
function show_tanqi_tips_by_config(config_id, x, y, owner)
  local item = get_tips_ArrayList()
  item.ConfigID = config_id
  item.ItemType = ITEMTYPE_ANQI_SHOUFA
  show_3d_tips_one(item, x, y, owner)
end
function get_tips_ArrayList()
  local tips_game_form = nx_value("tips_game")
  local array_list = tips_game_form.array_list
  nx_function("ext_clear_custom_list", array_list)
  array_list.b_in_shortcut = false
  return array_list
end
function show_tips_common(config_id, ItemType, x, y, owner)
  local item = get_tips_ArrayList()
  item.ConfigID = config_id
  item.ItemType = ItemType
  item.is_static = true
  show_3d_tips_one(item, x, y, owner)
end
function show_skill_tips(config_id, ItemType, x, y, owner)
  local item = get_tips_ArrayList()
  item.ConfigID = config_id
  item.ItemType = ItemType
  item.is_static = true
  item.Level = 1
  show_3d_tips_one(item, x, y, owner)
end
function show_puzzle_prop(id, x, y, width, height, owner)
  local gui = nx_value("gui")
  local name = gui.TextManager:GetText("ui_" .. id)
  local text = get_puzzle_prop_info(id)
  text = nx_string(name) .. "<br>" .. nx_string(text)
  show_text_tip(nx_widestr(text), x, y, nil, owner)
end
function ShowLeftPhoto3DTips(x, y, config_id, scene_id, is_world, npc_list)
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  if is_world then
    tips_manager:ShowLeftPhoto3DTips(nx_int(x), nx_int(y), nx_string(config_id), nx_string(scene_id), is_world, npc_list)
  else
    tips_manager:ShowLeftPhoto3DTips(nx_int(x), nx_int(y), nx_string(config_id), nx_string(scene_id), is_world, npc_list)
  end
end
function show_puzzle_skill_tip(id, x, y, width, height)
  do return show_tips_common(id, 1017, x, y) end
  local _equip_tip = get_equip3d_tip_form("new")
  local jewel_game_manager = nx_value("jewel_game_manager")
  if not nx_is_valid(jewel_game_manager) then
    return 1
  end
  _equip_tip.Visible = true
  _equip_tip.Left = x + width
  _equip_tip.Top = y + height
  _equip_tip.groupbox_puzzle_skill.Visible = true
  set_puzzle_info(_equip_tip, id)
  local gui = nx_value("gui")
  _equip_tip.mltbox_name:AddHtmlText(gui.TextManager:GetText(id), -1)
  _equip_tip.mltbox_name.Visible = true
  _equip_tip.lbl_kuang.Visible = false
  _equip_tip.lbl_photo.Visible = true
  _equip_tip.lbl_photo.BackImage = jewel_game_manager:GetPhoto(id)
  _equip_tip.lbl_photo.Height = 90
  _equip_tip.lbl_photo.Width = 90
  local text = ""
  local cd_value = jewel_game_manager:GetCDTurns(id)
  if nx_int(cd_value) ~= nx_int(0) then
    text = nx_string(gui.TextManager:GetText("tips_gemskill_1")) .. cd_value .. "<br>"
  elseif nx_int(cd_value) > nx_int(100) then
    text = nx_string(gui.TextManager:GetText("tips_gemskill_2")) .. cd_value .. "<br>"
  else
    text = nx_string(gui.TextManager:GetText("tips_gemskill_0")) .. "<br>"
  end
  text = text .. nx_string(gui.TextManager:GetText("desc_" .. id))
  _equip_tip.mltbox_prop:AddHtmlText(nx_widestr(text), -1)
  _equip_tip.lbl_photo.Left = 180
  _equip_tip.lbl_photo.Top = 24
  _equip_tip.lbl_biankuang.Left = 193
  _equip_tip.lbl_biankuang.Top = 24
  _equip_tip.lbl_kuang.Left = 193
  _equip_tip.lbl_kuang.Top = 24
  _equip_tip.mltbox_name.Left = 27
  _equip_tip.mltbox_name.Top = 24
  _equip_tip.Height = 240
  _equip_tip.mltbox_prop.Height = _equip_tip.mltbox_prop:GetContentHeight()
  _equip_tip.groupbox_puzzle_skill.Top = _equip_tip.mltbox_prop:GetContentHeight() + _equip_tip.mltbox_prop.Top
  _equip_tip.groupbox_puzzle_skill.Left = _equip_tip.lbl_backImage.Left
  _equip_tip.lbl_backImage.Height = _equip_tip.groupbox_puzzle_skill.Top + _equip_tip.groupbox_puzzle_skill.Height
  _equip_tip.mltbox_prop.Top = 50
  _equip_tip.mltbox_prop.Visible = true
  _equip_tip.Height = _equip_tip.lbl_backImage.Height
  tips_owner(_equip_tip, x, y)
end
function show_puzzle_buffer(buffer_id, view_id, viewitem_id, x, y, width)
  local gui = nx_value("gui")
  local tipinfo = nx_string(gui.TextManager:GetText("desc_" .. buffer_id))
  local active_count = get_gem_obj_buff_active_count(buffer_id, view_id, viewitem_id)
  if 1000 < active_count then
    tipinfo = tipinfo .. "<br>" .. nx_string(gui.TextManager:GetText("tips_gembuff_3"))
  elseif 0 < active_count then
    tipinfo = tipinfo .. "<br>" .. nx_string(gui.TextManager:GetFormatText("tips_gembuff_2", active_count))
  end
  show_text_tip(nx_widestr(tipinfo), x, y, width)
end
function show_puzzle_player(view_id, viewitem_id, x, y)
  local string_id = "tips_gembattle_0"
  local gem_config = get_gem_obj_prop("GemConfig", view_id, viewitem_id)
  local gem_level = get_gem_obj_prop("GemLevel", view_id, viewitem_id)
  local passion_text = get_gem_obj_prop("Passion", view_id, viewitem_id)
  local vitality_text = get_gem_obj_prop("Vitality", view_id, viewitem_id)
  local energy_text = get_gem_obj_prop("Energy", view_id, viewitem_id)
  local specialty_text = get_gem_obj_prop("Specialty", view_id, viewitem_id)
  local talent_text = get_gem_obj_prop("Talent", view_id, viewitem_id)
  local crit_text = get_gem_obj_prop("Crit", view_id, viewitem_id)
  local magic_defence_text = get_gem_obj_prop("MagicDefence", view_id, viewitem_id)
  local magic_hit_text = get_gem_obj_prop("MagicHit", view_id, viewitem_id)
  local gui = nx_value("gui")
  local job_sf_path = "share\\Item\\lifesfname.ini"
  local sf_ini = nx_execute("util_functions", "get_ini", job_sf_path)
  if not nx_is_valid(sf_ini) then
    return
  end
  local text = gui.TextManager:Format_SetIDName(nx_string(string_id))
  local index = sf_ini:FindSectionIndex(nx_string(gem_config))
  if index < 0 then
    local gem_name = get_gem_obj_prop("PlayerName", view_id, viewitem_id)
    local name = gui.TextManager:GetText(nx_string(gem_name))
    gui.TextManager:Format_AddParam(name)
  else
    local job_level = gui.TextManager:GetText("role_title_" .. sf_ini:ReadString(index, nx_string(gem_level), ""))
    local job = gui.TextManager:GetText(nx_string(gem_config))
    gui.TextManager:Format_AddParam(job .. nx_widestr("[") .. job_level .. nx_widestr("]"))
  end
  gui.TextManager:Format_AddParam(nx_int(passion_text))
  gui.TextManager:Format_AddParam(nx_int(vitality_text))
  gui.TextManager:Format_AddParam(nx_int(energy_text))
  gui.TextManager:Format_AddParam(nx_int(specialty_text))
  gui.TextManager:Format_AddParam(nx_int(talent_text))
  gui.TextManager:Format_AddParam(nx_int(crit_text))
  gui.TextManager:Format_AddParam(nx_int(magic_defence_text))
  gui.TextManager:Format_AddParam(nx_int(magic_hit_text))
  local info = gui.TextManager:Format_GetText()
  show_text_tip(nx_widestr(info), x, y)
end
function set_puzzle_info(equip_tip, id)
  local jewel_game_manager = nx_value("jewel_game_manager")
  if not nx_is_valid(jewel_game_manager) then
    return 1
  end
  local max_red = jewel_game_manager:GetNeedRed(nx_string(id))
  set_puzzle_info_ex(equip_tip.lbl_red, equip_tip.lbl_max_red, max_red, 1)
  local max_yellow = jewel_game_manager:GetNeedYellow(nx_string(id))
  set_puzzle_info_ex(equip_tip.lbl_yellow, equip_tip.lbl_max_yellow, max_yellow, 2)
  local max_blue = jewel_game_manager:GetNeedBlue(nx_string(id))
  set_puzzle_info_ex(equip_tip.lbl_blue, equip_tip.lbl_max_blue, max_blue, 3)
  local max_green = jewel_game_manager:GetNeedGreen(nx_string(id))
  set_puzzle_info_ex(equip_tip.lbl_green, equip_tip.lbl_max_green, max_green, 4)
  local max_purple = jewel_game_manager:GetNeedPurple(nx_string(id))
  set_puzzle_info_ex(equip_tip.lbl_purple, equip_tip.lbl_max_purple, max_purple, 5)
end
local POINT_PIC_PATH = {
  [1] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\ahong-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\ahong32.png"
  },
  [2] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\ahuang-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\ahuang32.png"
  },
  [3] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\alan-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\alan32.png"
  },
  [4] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\alv-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\alv32.png"
  },
  [5] = {
    [1] = "gui\\mainform\\smallgame\\baoshi\\common\\azi-on.png",
    [2] = "gui\\mainform\\smallgame\\baoshi\\skill\\azi32.png"
  }
}
function set_puzzle_info_ex(image_control, lbl_control, value, index)
  if nx_int(value) >= nx_int(1) then
    lbl_control.Text = nx_widestr(value)
    image_control.BackImage = POINT_PIC_PATH[index][1]
    lbl_control.Visible = true
  else
    image_control.BackImage = POINT_PIC_PATH[index][2]
    lbl_control.Visible = false
  end
end
function get_id_mapping_info(id, var, index)
  local res = 0
  if var > nx_int(1) and var < nx_int(3) then
    res = 0
  elseif var >= nx_int(3) and var < nx_int(6) then
    res = 1
  elseif var >= nx_int(6) and var < nx_int(10) then
    res = 2
  elseif var >= nx_int(10) and var < nx_int(15) then
    res = 3
  elseif var >= nx_int(15) and var < nx_int(21) then
    res = 4
  elseif var >= nx_int(21) and var < nx_int(28) then
    res = 5
  elseif var >= nx_int(28) and var < nx_int(36) then
    res = 6
  elseif var >= nx_int(36) and var < nx_int(45) then
    res = 7
  elseif var >= nx_int(45) and var < nx_int(55) then
    res = 8
  elseif var >= nx_int(55) and var < nx_int(66) then
    res = 9
  elseif var >= nx_int(66) then
    res = 10
  end
  local value = 0
  if 1 == index then
    value = res
  elseif 2 == index then
    value = 1 * res
  elseif 3 == index then
    value = 0.5 * res
  elseif 4 == index then
    value = 1 * res
  elseif 5 == index then
    value = 2 * res
  end
  return nx_int(value)
end
function get_puzzle_prop_info(id)
  local var = get_gem_obj_prop(id, VIEWPORT_GAME_SUBOBJ_BOX, 1)
  local gui = nx_value("gui")
  local text = ""
  text = text .. nx_string(gui.TextManager:GetText("tips_gemprop_1")) .. nx_string(var) .. "<br>" .. "<br>"
  local index = "tips_gemprop_" .. id .. "1"
  text = text .. nx_string(gui.TextManager:GetText(index)) .. nx_string(var) .. "<br>"
  index = "tips_gemprop_" .. id .. "2"
  text = text .. nx_string(gui.TextManager:GetText(index)) .. nx_string(get_id_mapping_info(id, nx_int(var), 2)) .. "<br>"
  index = "tips_gemprop_" .. id .. "3"
  text = text .. nx_string(gui.TextManager:GetText(index)) .. nx_string(get_id_mapping_info(id, nx_int(var), 3)) .. "<br>"
  index = "tips_gemprop_" .. id .. "4"
  text = text .. nx_string(gui.TextManager:GetText(index)) .. nx_string(get_id_mapping_info(id, nx_int(var), 4)) .. "<br>"
  index = "tips_gemprop_" .. id .. "5"
  text = text .. nx_string(gui.TextManager:GetText(index)) .. nx_string(get_id_mapping_info(id, nx_int(var), 5)) .. "<br>"
  return text
end
function get_gem_obj_buff_active_count(buffer_id, view_id, viewitem_id)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return 0
  end
  local view_item = view:GetViewObj(nx_string(viewitem_id))
  if not nx_is_valid(view_item) then
    return 0
  end
  local rows = view_item:GetRecordRows("TempBuffRec")
  if 0 < rows then
    local buffer = ""
    for t = 0, rows - 1 do
      local buff_id = view_item:QueryRecord("TempBuffRec", t, 0)
      if nx_string(buff_id) == nx_string(buffer_id) then
        return nx_number(view_item:QueryRecord("TempBuffRec", t, 1))
      end
    end
  end
  return 0
end
function get_gem_obj_prop(name, view_id, viewitem_id)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return ""
  end
  local view_item = view:GetViewObj(nx_string(viewitem_id))
  if not nx_is_valid(view_item) then
    return ""
  end
  local value = view_item:QueryProp(name)
  return value
end
function tips_owner(self, x, y)
  local gui = nx_value("gui")
  local x_e = 0
  local y_e = 0
  if self.Width + x > gui.Width then
    x_e = x - self.Width
  else
    x_e = x
  end
  if self.Height + y > gui.Height then
    y_e = y - self.Height
  else
    y_e = y
  end
  self.Left = x_e
  self.Top = y_e
end
function test()
  local tips_manager = nx_value("tips_manager")
  tips_manager:LoadResource()
end
function show_skill_book_next(is_show)
  local gui = nx_value("gui")
  local form_main = gui.Desktop
  if not nx_is_valid(form_main) then
    return
  end
  local equip_tip = form_main.equip_tips_new
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  if equip_tip.Visible then
    tips_manager:ShowSkillNextInfo(is_show)
  end
  return
end
function ShowTipDialog(content)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, content)
  dialog.cancel_btn.Visible = false
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
  return false
end
