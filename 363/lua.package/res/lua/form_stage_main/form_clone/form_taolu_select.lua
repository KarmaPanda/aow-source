require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
local MAX_SELECT_COUNT = 7
local CLIENT_SKILL_SELECT_ADD_TAOLU = 0
local CLIENT_SKILL_SELECT_REQUSET_TAOLU_LIST = 3
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  for i = 1, MAX_SELECT_COUNT do
    local btn_name = "btn_select_" .. nx_string(i)
    local btn = form.groupbox_selct_taolu:Find(nx_string(btn_name))
    if nx_is_valid(btn) then
      btn.Enabled = false
    end
  end
  form.btn_add.Visible = false
  form.btn_save.Visible = false
  refresh_taolu_list(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local scene_config = client_scene:QueryProp("ConfigID")
  form.lbl_8.Text = nx_widestr(util_text(nx_string(scene_config)))
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_add_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "select_num") then
    return
  end
  local select_node = form.skill_tree.SelectNode
  if not nx_is_valid(select_node) then
    return
  end
  if not nx_find_custom(select_node, "taolu_id") then
    return
  end
  local taolu_id = nx_string(select_node.taolu_id)
  local taolu_name = nx_widestr(util_text(nx_string(taolu_id)))
  for i = 1, nx_number(form.select_num) do
    local lbl_name = "lbl_select_" .. nx_string(i)
    local lbl = form.groupbox_selct_taolu:Find(nx_string(lbl_name))
    if nx_is_valid(lbl) and nx_find_custom(lbl, "TaoluID") and nx_string(lbl.TaoluID) == nx_string(taolu_id) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_clone_tlxz_17"), 2)
      end
      return
    end
  end
  for i = 1, nx_number(form.select_num) do
    local btn_name = "btn_select_" .. nx_string(i)
    local btn = form.groupbox_selct_taolu:Find(nx_string(btn_name))
    if nx_is_valid(btn) and nx_find_custom(btn, "EditFlag") and btn.EditFlag then
      btn.Enabled = true
      btn.EditFlag = false
      local lbl_name = "lbl_select_" .. nx_string(i)
      local lbl = form.groupbox_selct_taolu:Find(nx_string(lbl_name))
      if nx_is_valid(lbl) then
        lbl.Text = nx_widestr(taolu_name)
        lbl.TaoluID = nx_string(taolu_id)
      end
      break
    end
  end
end
function on_btn_save_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "select_id") then
    return
  end
  if not nx_find_custom(form, "select_num") then
    return
  end
  local taolu_list = {}
  for i = 1, nx_number(form.select_num) do
    local btn_name = "btn_select_" .. nx_string(i)
    local btn = form.groupbox_selct_taolu:Find(nx_string(btn_name))
    if nx_is_valid(btn) and nx_find_custom(btn, "EditFlag") and not btn.EditFlag then
      local lbl_name = "lbl_select_" .. nx_string(i)
      local lbl = form.groupbox_selct_taolu:Find(nx_string(lbl_name))
      if nx_is_valid(lbl) and nx_find_custom(lbl, "TaoluID") then
        table.insert(taolu_list, nx_string(lbl.TaoluID))
      end
    end
  end
  if table.getn(taolu_list) == 0 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_text("ui_clone_tlxz_15")))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "cancel" then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SKILL_SELECT_LIMIT), nx_int(CLIENT_SKILL_SELECT_ADD_TAOLU), nx_int(form.select_id), unpack(taolu_list))
  end
end
function on_btn_select_click(btn)
  local groupbox = btn.Parent
  if not nx_is_valid(groupbox) then
    return
  end
  btn.Enabled = false
  btn.EditFlag = true
  local lbl_name = "lbl_select_" .. nx_string(btn.DataSource)
  local lbl = groupbox:Find(nx_string(lbl_name))
  if nx_is_valid(lbl) then
    lbl.Text = nx_widestr("")
    lbl.TaoluID = nil
  end
end
function on_grid_taolu_list_select_row(self, row)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
end
function refresh_taolu_list(form)
  if not nx_is_valid(form) then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  form.skill_tree:BeginUpdate()
  local map_root = form.skill_tree:CreateRootNode(nx_widestr(""))
  local main_wuxue_type = wuxue_query:GetMainNames(WUXUE_SKILL)
  for i = 1, table.getn(main_wuxue_type) do
    local type_name = main_wuxue_type[i]
    local sub_wuxue_type = wuxue_query:GetSubNames(WUXUE_SKILL, nx_string(type_name))
    for j = 1, table.getn(sub_wuxue_type) do
      local sub_type_name = sub_wuxue_type[j]
      if check_taolu_is_learn(sub_type_name) then
        local map_node = map_root:CreateNode(nx_widestr(util_text(nx_string(sub_type_name))))
        map_node.DrawMode = "FitWindow"
        map_node.ExpandCloseOffsetX = 0
        map_node.ExpandCloseOffsetY = 0
        map_node.TextOffsetX = 60
        map_node.TextOffsetY = 10
        map_node.NodeOffsetY = 2
        map_node.Font = "font_main"
        map_node.ForeColor = "255,255,255,255"
        map_node.ShadowColor = "10,0,0,0"
        map_node.NodeBackImage = form.btn_tree_image.NormalImage
        map_node.NodeFocusImage = form.btn_tree_image.FocusImage
        map_node.NodeSelectImage = form.btn_tree_image.PushImage
        map_node.ItemHeight = 34
        map_node.taolu_id = nx_string(sub_type_name)
      end
    end
  end
  map_root.Expand = true
  form.skill_tree:EndUpdate()
end
function refresh_select_taolu_list(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "select_num") then
    return
  end
  local select_id = nx_int(arg[1])
  local select_state = nx_int(arg[2])
  local btn_state = true
  if nx_int(select_state) == nx_int(1) then
    btn_state = false
  end
  form.btn_add.Visible = btn_state
  form.btn_save.Visible = btn_state
  local select_taolu_list = {}
  local select_taolu_bit_array = {}
  if table.getn(arg) >= 4 then
    select_taolu_list = nx_function("ext_split_string", nx_string(arg[3]), nx_string(";"))
    select_taolu_bit_array = get_bit_value(nx_int(arg[4]), 32)
  end
  for i = 1, nx_number(form.select_num) do
    local lbl_name = "lbl_select_" .. nx_string(i)
    local lbl = form.groupbox_selct_taolu:Find(nx_string(lbl_name))
    local btn_name = "btn_select_" .. nx_string(i)
    local btn = form.groupbox_selct_taolu:Find(nx_string(btn_name))
    if nx_is_valid(lbl) and nx_is_valid(btn) then
      btn.EditFlag = btn_state
      btn.Enabled = false
      lbl.Text = nx_widestr("")
      if nx_int(i) <= nx_int(table.getn(select_taolu_list)) then
        lbl.Text = util_text(nx_string(select_taolu_list[i]))
        if nx_number(select_taolu_bit_array[i]) == 1 then
          btn.Enabled = false
          btn.EditFlag = false
          lbl.ForeColor = "255,172,172,172"
        else
          btn.Enabled = btn_state
          lbl.ForeColor = "255,255,255,255"
        end
      end
    end
  end
end
function open_form(select_id)
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.select_id = select_id
  form.select_num = GetSelectTaoluCount(select_id)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SKILL_SELECT_LIMIT), nx_int(CLIENT_SKILL_SELECT_REQUSET_TAOLU_LIST), nx_int(select_id))
  end
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function get_bit_value(data, bit_count)
  local result = {}
  for i = 1, nx_number(bit_count) do
    table.insert(result, 0)
  end
  local tmpdata = nx_int64(data)
  for i = nx_number(bit_count) - 1, 0, -1 do
    if nx_number(tmpdata) <= nx_number(0) then
      return result
    end
    local tmp = math.floor(tmpdata / math.pow(2, i))
    if nx_number(tmp) == 1 then
      result[i + 1] = nx_number(tmp)
      tmpdata = tmpdata - math.pow(2, i)
    end
  end
  return result
end
function GetTaoluID(taolu_name)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local main_wuxue_type = wuxue_query:GetMainNames(WUXUE_SKILL)
  for i = 1, table.getn(main_wuxue_type) do
    local type_name = main_wuxue_type[i]
    local sub_wuxue_type = wuxue_query:GetSubNames(WUXUE_SKILL, nx_string(type_name))
    for j = 1, table.getn(sub_wuxue_type) do
      local sub_type_name = sub_wuxue_type[j]
      if check_taolu_is_learn(sub_type_name) and nx_widestr(taolu_name) == nx_widestr(util_text(nx_string(sub_type_name))) then
        return sub_type_name
      end
    end
  end
end
function GetSelectTaoluCount(select_id)
  local taolu_ini = nx_execute("util_functions", "get_ini", "share\\Skill\\skill_select_limit.ini")
  if not nx_is_valid(taolu_ini) then
    return 0
  end
  local sec_index = taolu_ini:FindSectionIndex(nx_string(select_id))
  if sec_index < 0 then
    return 0
  end
  return taolu_ini:ReadInteger(sec_index, "MaxSelectCount", 0)
end
