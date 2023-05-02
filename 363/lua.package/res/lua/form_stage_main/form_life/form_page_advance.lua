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
  refresh_fuse_groupboxlist(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_TOOL, form, "form_stage_main\\form_life\\form_page_advance", "on_toolbox_viewport_change")
  end
  form.btn_fuse.Visible = true
  form.btn_cancel.Visible = true
  form.groupbox_simple.Visible = false
end
function on_main_form_close(form)
  nx_destroy(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
end
function on_fuse_form_open(npcid)
  local form = util_get_form("form_stage_main\\form_life\\form_page_advance", true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.npcid = npcid
  util_auto_show_hide_form("form_stage_main\\form_life\\form_page_advance")
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function refresh_fuse_groupboxlist(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  formula_list = get_skillpage_formula(game_client, form.npcid)
  if formula_list == nil then
    return
  end
  form.groupscrollbox_fuselist:DeleteAll()
  form.groupscrollbox_fuselist.IsEditMode = true
  local item_config = ""
  local fuse_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\page_advance.ini")
  for _, formula in ipairs(formula_list) do
    local index = fuse_ini:FindSectionIndex(nx_string(formula))
    if 0 <= index then
      local fuse_name = fuse_ini:ReadString(index, "ComposeResult", "")
      local Material = fuse_ini:ReadString(index, "Material", "")
      local str_lst = util_split_string(Material, ";")
      local Material_str = nx_widestr("")
      for i = 1, table.getn(str_lst) do
        local str_temp = util_split_string(str_lst[i], ",")
        item_config = nx_string(str_temp[1])
        local need_num = nx_int(str_temp[2])
        local have_num = get_item_num(item_config)
        if nx_number(have_num) >= nx_number(need_num) then
          Material_str = nx_widestr("(<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>)")
        else
          Material_str = nx_widestr("(<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>)")
        end
      end
      if fuse_name ~= "" and Material_str ~= "" then
        local clonegroupbox = clone_groupbox_fuseinfo(form, Material_str, formula, fuse_name, item_config)
        form.groupscrollbox_fuselist:Add(clonegroupbox)
      end
    end
  end
  form.groupscrollbox_fuselist:ResetChildrenYPos()
  form.groupscrollbox_fuselist.IsEditMode = false
end
function on_btn_fuse_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "CurFormulaID") then
    local formula_id = form.CurFormulaID
    nx_execute("custom_sender", "custom_send_skillpage_fuse", nx_string(formula_id), 1, 0)
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function get_item_num(item_id)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  local viewobj_list = view:GetViewObjList()
  for j, obj in pairs(viewobj_list) do
    local tempid = obj:QueryProp("ConfigID")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
    end
  end
  if nx_int(cur_amount) == nx_int(0) then
    viewobj_list = tool:GetViewObjList()
    for j, obj in pairs(viewobj_list) do
      local tempid = obj:QueryProp("ConfigID")
      if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
        cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
      end
    end
  end
  return nx_int(cur_amount)
end
function on_toolbox_viewport_change(form, optype)
  if optype == "updateitem" or optype == "additem" or optype == "delitem" then
    refresh_fuse_groupboxlist(form)
  end
end
function refresh_btn_state(form)
end
function get_skillpage_formula(game_client, npcid)
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return nil
  end
  local formula_list = {}
  local formula_set = {}
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(tool) then
    return nil
  end
  formula = fuse_formula_query:GetFormulas(npcid)
  local formula_num = table.getn(formula)
  for i, item in ipairs(formula) do
    table.insert(formula_list, item)
  end
  return formula_list
end
function process_break_btn_show(form, show)
  if show == 1 then
  else
  end
end
function clone_groupbox(source)
  local gui = nx_value("gui")
  local clone = gui:Create("GroupBox")
  clone.AutoSize = source.AutoSize
  clone.Name = source.Name
  clone.BackColor = source.BackColor
  clone.NoFrame = source.NoFrame
  clone.Left = 0
  clone.Top = 0
  clone.Width = source.Width
  clone.Height = source.Height
  clone.LineColor = source.LineColor
  clone.Transparent = source.Transparent
  clone.TestTrans = source.TestTrans
  clone.DrawMode = source.DrawMode
  return clone
end
function clone_mltbox(source)
  local gui = nx_value("gui")
  local clone = gui:Create("MultiTextBox")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.HAlign = source.HAlign
  clone.VAlign = source.VAlign
  clone.ViewRect = source.ViewRect
  clone.HtmlText = source.HtmlText
  clone.MouseInBarColor = source.MouseInBarColor
  clone.SelectBarColor = source.SelectBarColor
  clone.TextColor = source.TextColor
  clone.Font = source.Font
  clone.NoFrame = source.NoFrame
  clone.LineColor = source.LineColor
  clone.ViewRect = source.ViewRect
  clone.LineHeight = source.LineHeight
  clone.TextColor = source.TextColor
  clone.SelectBarColor = source.SelectBarColor
  clone.MouseInBarColor = source.MouseInBarColor
  clone.Transparent = source.Transparent
  clone.TestTrans = source.TestTrans
  clone.DrawMode = source.DrawMode
  return clone
end
function clone_label(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Label")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.Text = source.Text
  clone.BackImage = source.BackImage
  clone.DrawMode = source.DrawMode
  clone.ClickEvent = source.ClickEvent
  clone.Transparent = source.Transparent
  clone.TestTrans = source.TestTrans
  clone.DrawMode = source.DrawMode
  return clone
end
function clone_button(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Button")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.NormalImage = source.NormalImage
  clone.FocusImage = source.FocusImage
  clone.PushImage = source.PushImage
  clone.NormalColor = source.NormalColor
  clone.FocusColor = source.FocusColor
  clone.PushColor = source.PushColor
  clone.DisableColor = source.DisableColor
  clone.BackColor = source.BackColor
  clone.ShadowColor = source.ShadowColor
  clone.Text = source.Text
  clone.AutoSize = source.AutoSize
  clone.DrawMode = source.DrawMode
  return clone
end
function clone_grid_material(source)
  local gui = nx_value("gui")
  local clone = gui:Create("ImageControlGrid")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.Font = source.Font
  clone.Text = source.Text
  clone.SelectColor = source.SelectColor
  clone.AutoSize = source.AutoSize
  clone.DrawMode = source.DrawMode
  clone.NoFrame = source.NoFrame
  clone.MultiTextBoxCount = source.MultiTextBoxCount
  clone.MultiTextBoxPos = source.MultiTextBoxPos
  clone.MultiTextBox1.NoFrame = source.MultiTextBox1.NoFrame
  return clone
end
function clone_grid_result(source)
  local gui = nx_value("gui")
  local clone = gui:Create("ImageControlGrid")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.Font = source.Font
  clone.Text = source.Text
  clone.SelectColor = source.SelectColor
  clone.AutoSize = source.AutoSize
  clone.DrawMode = source.DrawMode
  clone.NoFrame = source.NoFrame
  return clone
end
function clone_groupbox_fuseinfo(form, Material_str, formula, fuse_name, item_config)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
  local fuse_photo = ItemQuery:GetItemPropByConfigID(nx_string(fuse_name), nx_string("Photo"))
  local gui = nx_value("gui")
  local clonegroupbox = clone_groupbox(form.groupbox_simple)
  local clone_btn = clone_button(form.btn_select)
  nx_bind_script(clone_btn, nx_current())
  clone_btn.CurID = formula
  nx_callback(clone_btn, "on_click", "on_slect_btn_click")
  clonegroupbox:Add(clone_btn)
  local clone_grid_material = clone_grid_material(form.grid_material)
  clone_grid_material:AddItem(nx_int(0), item_photo, Material_str, 0, -1)
  nx_bind_script(clone_grid_material, nx_current())
  nx_callback(clone_grid_material, "on_mousein_grid", "on_grid_mousein")
  nx_callback(clone_grid_material, "on_mouseout_grid", "on_grid_mouseout")
  clone_grid_material.config = item_config
  clonegroupbox:Add(clone_grid_material)
  local clone_grid_result = clone_grid_result(form.grid_result)
  clone_grid_result:AddItem(nx_int(0), fuse_photo, "", 0, -1)
  clone_grid_result:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(fuse_name))
  nx_bind_script(clone_grid_result, nx_current())
  nx_callback(clone_grid_result, "on_mousein_grid", "on_grid_mousein")
  nx_callback(clone_grid_result, "on_mouseout_grid", "on_grid_mouseout")
  clone_grid_result.config = fuse_name
  clonegroupbox:Add(clone_grid_result)
  local clone_label_result = clone_label(form.lbl_result)
  clone_label_result.Text = nx_widestr(gui.TextManager:GetFormatText(fuse_name))
  clonegroupbox:Add(clone_label_result)
  clonegroupbox.CurID = formula
  return clonegroupbox
end
function on_slect_btn_click(btn)
  local form = btn.ParentForm
  form.CurFormulaID = btn.CurID
  local child_control_list = form.groupscrollbox_fuselist:GetChildControlList()
  for i, obj in ipairs(child_control_list) do
    obj.BackImage = "gui\\special\\camera\\bg_time_out.png"
    if obj.CurID == btn.CurID then
      obj.BackImage = "gui\\common\\treeview\\tree5_2_on.png"
    end
  end
end
function on_grid_mousein(grid, index)
  show_tips(grid, grid.config)
end
function on_grid_mouseout(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_tips(grid, item_config)
  if nx_string(item_config) == nx_string("") or nx_string(item_config) == nx_string("nil") then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(ItemQuery) or not nx_is_valid(IniManager) then
    return
  end
  if ItemQuery:FindItemByConfigID(nx_string(item_config)) then
    local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
    local item_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Level"))
    local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
    local item_photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
    local prop_array = {}
    prop_array.ConfigID = nx_string(item_config)
    prop_array.ItemType = nx_int(item_type)
    prop_array.Level = nx_int(item_level)
    prop_array.SellPrice1 = nx_int(item_sellPrice1)
    prop_array.Photo = nx_string(item_photo)
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
