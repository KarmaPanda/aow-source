require("util_gui")
require("util_functions")
require("define\\define")
require("define\\gamehand_type")
require("form_stage_main\\form_map\\map_logic")
require("share\\logicstate_define")
require("share\\client_custom_define")
require("form_stage_main\\form_task\\task_define")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
  self.allow_empty = true
  self.Visible = false
  self.scenename = ""
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  return 1
end
function on_size_change()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene_trans")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function refresh_line(form)
  itemtable = form.form_scene.groupbox_line:GetChildControlList()
  local count = table.getn(itemtable)
  for i = 1, count do
    itemtable[i].Visible = false
  end
end
function refresh_point(form)
  local itemtable = form.form_scene.groupbox_point:GetChildControlList()
  local count = table.getn(itemtable)
  for i = 1, count do
    itemtable[i].Visible = false
  end
end
function refresh_place(form)
  local itemtable = form.form_scene.groupbox_mc:GetChildControlList()
  local count = table.getn(itemtable)
  for i = 1, count do
    itemtable[i].Visible = false
  end
end
function init_scene_trans(...)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_map\\form_map_scene_trans")
  if not nx_is_valid(form) then
    return
  end
  if arg[1] == nil then
    form:Close()
    return
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local resource = client_scene:QueryProp("Resource")
  local scene_address = "form_stage_main\\form_map\\form_scene\\form_map_" .. nx_string(resource)
  local ischanged = false
  if form.scenename ~= scene_address then
    ischanged = true
  end
  if ischanged then
    if form.scenename ~= "" then
      local old_scene = util_get_form(nx_string(form.scenename), true, false)
      if nx_is_valid(old_scene) then
        form:Remove(old_scene)
        gui:Delete(old_scene)
      end
    end
    form.scenename = scene_address
    local form_scene = util_get_form(nx_string(scene_address), true, false)
    if not nx_is_valid(form_scene) then
      form.scenename = ""
      on_close_form()
      return
    end
    if form:Add(form_scene) then
      form.form_scene = form_scene
      form.form_scene.Visible = true
      form.form_scene.Fixed = true
      form.form_scene.Left = (form.Width - form.form_scene.Width) / 2
      form.form_scene.Top = (form.Height - form.form_scene.Height) / 2 + 14
    end
  end
  if not nx_find_custom(form, "form_scene") or not nx_is_valid(form.form_scene) then
    form.scenename = ""
    on_close_form()
    return
  end
  form.lbl_begin.Visible = false
  form.lbl_end.Visible = false
  form:ToFront(form.gbx_info)
  form:ToFront(form.lbl_begin)
  form:ToFront(form.lbl_end)
  form.form_scene:ToFront(form.form_scene.groupbox_point)
  form.form_scene:ToBack(form.form_scene.pic_scene)
  local table_num = table.getn(arg) / 2
  if table_num < 1 then
    return
  end
  refresh_line(form)
  refresh_point(form)
  refresh_place(form)
  local path = ""
  local money = 0
  for i = 1, table_num do
    path = arg[2 * i - 1]
    money = arg[2 * i]
    local point_a = string.sub(path, 1, 1)
    local point_b = string.sub(path, 2, 2)
    if nx_find_custom(form.form_scene, nx_string(point_a)) then
      local lbl_a = nx_custom(form.form_scene, nx_string(point_a))
      lbl_a.Visible = true
      form.lbl_begin.AbsLeft = lbl_a.AbsLeft
      form.lbl_begin.AbsTop = lbl_a.AbsTop - 25
      form.lbl_begin.Visible = true
      form.begin = point_a
      form.des = point_a
      local qidian = "lbl_" .. nx_string(point_a)
      if nx_find_custom(form.form_scene, nx_string(qidian)) then
        local lbl = nx_custom(form.form_scene, nx_string(qidian))
        lbl.Visible = true
        form.qidian.Text = nx_widestr(nx_string(lbl.Text))
      end
    end
    if nx_find_custom(form.form_scene, nx_string(point_b)) then
      local lbl_b = nx_custom(form.form_scene, nx_string(point_b))
      lbl_b.Visible = true
    end
    local lable = "lbl_" .. nx_string(point_b)
    if nx_find_custom(form.form_scene, nx_string(lable)) then
      local lbl_point = nx_custom(form.form_scene, nx_string(lable))
      lbl_point.money = money
      lbl_point.Visible = true
    end
  end
  form.Visible = true
  form.feiyong:Clear()
  form.zhongdian.Text = ""
  form.btn_horse.Enabled = false
  form.btn_horse.Visible = false
  form.btn_carriage.Enabled = false
end
function on_point_click(self)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_map\\form_map_scene_trans")
  if not nx_is_valid(form) then
    return
  end
  if nx_string(self.DataSource) == nx_string(form.begin) then
    return
  end
  form.des = self.DataSource
  form.lbl_end.AbsLeft = self.AbsLeft
  form.lbl_end.AbsTop = self.AbsTop - 25
  form.lbl_end.Visible = true
  local road_a = "land_" .. nx_string(form.begin) .. nx_string(form.des)
  local road_b = "land_" .. nx_string(form.des) .. nx_string(form.begin)
  refresh_line(form)
  local des = "lbl_" .. nx_string(form.des)
  if nx_find_custom(form.form_scene, nx_string(des)) then
    local lbl = nx_custom(form.form_scene, nx_string(des))
    form.zhongdian.Text = nx_widestr(nx_string(lbl.Text))
    form.feiyong:Clear()
    local format_cost = nx_execute("util_functions", "trans_capital_string", nx_int64(lbl.money))
    form.feiyong:AddHtmlText(nx_widestr(format_cost), -1)
  end
  if nx_find_custom(form.form_scene, nx_string(road_a)) then
    local lbl_a = nx_custom(form.form_scene, nx_string(road_a))
    lbl_a.Visible = true
  end
  if nx_find_custom(form.form_scene, nx_string(road_b)) then
    local lbl_b = nx_custom(form.form_scene, nx_string(road_b))
    lbl_b.Visible = true
  end
  form.btn_carriage.Enabled = true
end
function on_btn_carriage_click(slef)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_map\\form_map_scene_trans")
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_string(form.des) == nx_string(form.begin) then
    return
  end
  local to_des = nx_string(form.begin) .. nx_string(form.des)
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CREATE_SCENE_TRANS_TOOL), nx_string(to_des))
  on_close_form()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_close_form()
  local form = nx_value("form_stage_main\\form_map\\form_map_scene_trans")
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return 1
end
