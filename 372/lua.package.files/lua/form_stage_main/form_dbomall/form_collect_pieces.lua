require("util_gui")
require("util_functions")
local FORM_COLLECT_PIECES = "form_stage_main\\form_dbomall\\form_collect_pieces"
local INI_COLLECT_PIECES = "share\\Activity\\form_collect_pieces.ini"
local REC_COLLECT_PIECES = "ActivityCollectPiecesRec"
local SUBMSG_CP_COLLECT = 0
local SUBMSG_CP_PRIZE = 1
local STATUS_GET_PRIZE = 2
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.btn_picture_0.Visible = false
  form.lbl_back.Visible = false
  form.pics_col = 0
  form.pics_row = 0
  form.pic_path_prefix = ""
  form.pieces_id = ""
  form.show_logic = 1
  init_form(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(REC_COLLECT_PIECES, form.groupbox_picture_list, nx_current(), "refresh_pic_status")
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(REC_COLLECT_PIECES, form.groupbox_picture_list)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_picture_click(btn)
  local form = btn.ParentForm
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local condition_mgr = nx_value("ConditionManager")
  if not nx_is_valid(condition_mgr) then
    return
  end
  if not condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(form.condition_id)) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_collect_pieces_01")
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  local goods_count = goods_grid:GetItemCount(form.pieces_id)
  if nx_int(goods_count) < nx_int(1) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_collect_pieces_03")
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  if nx_int(btn.row - 1) >= nx_int(0) and nx_int(btn.col - 1) >= nx_int(0) then
    nx_execute("custom_sender", "custom_activity_collect_pieces", SUBMSG_CP_COLLECT, nx_int(btn.row - 1), nx_int(btn.col - 1))
  end
end
function on_btn_get_prize_click()
  nx_execute("custom_sender", "custom_activity_collect_pieces", SUBMSG_CP_PRIZE)
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = get_ini(INI_COLLECT_PIECES, true)
  if not nx_is_valid(ini) then
    return
  end
  local sec_default = ini:FindSectionIndex("default")
  if sec_default < 0 then
    return
  end
  local pics_path = ini:ReadString(sec_default, "Path", "")
  local pics_prefix = ini:ReadString(sec_default, "NamePrefix", "")
  local pieces_id = ini:ReadString(sec_default, "Item", "")
  local pics_col = ini:ReadInteger(sec_default, "Col", 1)
  local pics_row = ini:ReadInteger(sec_default, "Row", 1)
  local pics_space = ini:ReadInteger(sec_default, "Space", 0)
  local condition_id = ini:ReadInteger(sec_default, "ConditionID", 0)
  if nx_int(pics_col) < nx_int(1) or nx_int(pics_row) < nx_int(1) or pics_path == "" or pics_prefix == "" or pieces_id == "" or nx_int(condition_id) < nx_int(0) then
    return
  end
  form.pics_col = pics_col
  form.pics_row = pics_row
  form.pic_path_prefix = pics_path .. pics_prefix .. "_"
  form.pieces_id = pieces_id
  form.condition_id = condition_id
  local left, top = 0, 0
  for i = 1, pics_row do
    for j = 1, pics_col do
      local btn = clone_control("Button", "btn_picture_" .. nx_string(i) .. nx_string(j), form.btn_picture_0, form.groupbox_picture_list)
      if nx_is_valid(btn) then
        btn.Left = left
        btn.Top = top
        btn.NormalImage = form.pic_path_prefix .. nx_string(i) .. nx_string(j) .. "0.png"
        nx_bind_script(btn, nx_current())
        nx_callback(btn, "on_click", "on_btn_picture_click")
        btn.row = i
        btn.col = j
        btn.Visible = true
        left = left + btn.Width + pics_space
      end
    end
    left = 0
    top = top + form.btn_picture_0.Height + pics_space
  end
end
function refresh_pic_status()
  local form = nx_value(FORM_COLLECT_PIECES)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local complete_index, notcomplete_index = 0, 0
  if not client_player:FindRecord(REC_COLLECT_PIECES) then
    refresh_goods_count(form, form.pics_col * form.pics_row, complete_index)
    form.lbl_back.Visible = false
    return
  end
  local pics_row = form.pics_row
  local pics_col = form.pics_col
  for i = 1, pics_row do
    local num = client_player:QueryRecord(REC_COLLECT_PIECES, nx_int(i - 1), nx_int(0))
    if nx_int(num) >= nx_int(0) then
      for j = 1, pics_col do
        local btn = form.groupbox_picture_list:Find("btn_picture_" .. nx_string(i) .. nx_string(j))
        if nx_is_valid(btn) then
          local flag = nx_function("ext_get_bit_value", nx_int(num), nx_int(j))
          if nx_int(flag) == nx_int(0) then
            btn.NormalImage = form.pic_path_prefix .. nx_string(i) .. nx_string(j) .. "0.png"
            notcomplete_index = notcomplete_index + 1
          else
            btn.NormalImage = form.pic_path_prefix .. nx_string(i) .. nx_string(j) .. "1.png"
            complete_index = complete_index + 1
          end
        end
      end
    end
  end
  local max_count = nx_int(form.pics_col) * nx_int(form.pics_row)
  if nx_int(complete_index) == nx_int(max_count) then
    local status_index = client_player:QueryProp("IsJoinActivityCollectPieces")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) and nx_int(status_index) ~= nx_int(STATUS_GET_PRIZE) then
      local info = util_text("sys_collect_pieces_08")
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    form.lbl_back.Visible = true
  else
    form.lbl_back.Visible = false
  end
  refresh_goods_count(form, notcomplete_index, complete_index)
end
function refresh_goods_count(form, notcomplete_index, complete_index)
  local form = nx_value(FORM_COLLECT_PIECES)
  if not nx_is_valid(form) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if nx_is_valid(goods_grid) then
    local goods_count = 0
    if form.pieces_id ~= "" then
      goods_count = goods_grid:GetItemCount(form.pieces_id)
    end
    form.lbl_goodsnum.Text = util_format_string("ui_atsxm_goodsnum", nx_int(goods_count))
  end
  form.lbl_darknum.Text = util_format_string("ui_atsxm_darknum", nx_int(notcomplete_index))
  form.lbl_lightnum.Text = util_format_string("ui_atsxm_lightnum", nx_int(complete_index))
end
function clone_control(ctrl_type, name, refer_ctrl, parent_ctrl)
  if not (nx_is_valid(refer_ctrl) and nx_is_valid(parent_ctrl)) or ctrl_type == "" or name == "" then
    return nx_null()
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local cloned_ctrl = gui:Create(ctrl_type)
  if not nx_is_valid(cloned_ctrl) then
    return nx_null()
  end
  local prop_list = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_list) do
    nx_set_property(cloned_ctrl, prop_list[i], nx_property(refer_ctrl, prop_list[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, cloned_ctrl)
  cloned_ctrl.Name = name
  parent_ctrl:Add(cloned_ctrl)
  return cloned_ctrl
end
