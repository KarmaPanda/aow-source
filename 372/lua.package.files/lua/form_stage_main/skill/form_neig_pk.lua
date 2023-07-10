require("util_functions")
require("custom_sender")
require("util_gui")
neig_point = 0
revert_time = 0
local max_neig_point = 0
local next_chip_point = 0
local MAX_BAR_WIDTH = 440
local current_bar_back = "gui\\common\\jinducao_new\\jdt_wuxue_1.png"
local g_bBegin = false
local g_image = {
  "gang.png",
  "rou.png",
  "yin.png",
  "yang.png",
  "hun.png",
  "wenhao.png"
}
local g_ani = {
  [1] = {
    total = 7,
    [1] = "gui\\animations\\ng_pk\\neigong-gang-01.png",
    [2] = "gui\\animations\\ng_pk\\neigong-gang-02.png",
    [3] = "gui\\animations\\ng_pk\\neigong-gang-03.png",
    [4] = "gui\\animations\\ng_pk\\neigong-gang-04.png",
    [5] = "gui\\animations\\ng_pk\\neigong-gang-05.png",
    [6] = "gui\\animations\\ng_pk\\neigong-gang-06.png",
    [7] = "gui\\animations\\ng_pk\\neigong-gang-07.png"
  },
  [2] = {
    total = 7,
    [1] = "gui\\animations\\ng_pk\\neigong-rou-01.png",
    [2] = "gui\\animations\\ng_pk\\neigong-rou-02.png",
    [3] = "gui\\animations\\ng_pk\\neigong-rou-03.png",
    [4] = "gui\\animations\\ng_pk\\neigong-rou-04.png",
    [5] = "gui\\animations\\ng_pk\\neigong-rou-05.png",
    [6] = "gui\\animations\\ng_pk\\neigong-rou-06.png",
    [7] = "gui\\animations\\ng_pk\\neigong-rou-07.png"
  },
  [3] = {
    total = 7,
    [1] = "gui\\animations\\ng_pk\\neigong-yin-01.png",
    [2] = "gui\\animations\\ng_pk\\neigong-yin-02.png",
    [3] = "gui\\animations\\ng_pk\\neigong-yin-03.png",
    [4] = "gui\\animations\\ng_pk\\neigong-yin-04.png",
    [5] = "gui\\animations\\ng_pk\\neigong-yin-05.png",
    [6] = "gui\\animations\\ng_pk\\neigong-yin-06.png",
    [7] = "gui\\animations\\ng_pk\\neigong-yin-07.png"
  },
  [4] = {
    total = 7,
    [1] = "gui\\animations\\ng_pk\\neigong-yang-01.png",
    [2] = "gui\\animations\\ng_pk\\neigong-yang-02.png",
    [3] = "gui\\animations\\ng_pk\\neigong-yang-03.png",
    [4] = "gui\\animations\\ng_pk\\neigong-yang-04.png",
    [5] = "gui\\animations\\ng_pk\\neigong-yang-05.png",
    [6] = "gui\\animations\\ng_pk\\neigong-yang-06.png",
    [7] = "gui\\animations\\ng_pk\\neigong-yang-07.png"
  },
  [5] = {
    total = 7,
    [1] = "gui\\animations\\ng_pk\\neigong-hunyuan-01.png",
    [2] = "gui\\animations\\ng_pk\\neigong-hunyuan-02.png",
    [3] = "gui\\animations\\ng_pk\\neigong-hunyuan-03.png",
    [4] = "gui\\animations\\ng_pk\\neigong-hunyuan-04.png",
    [5] = "gui\\animations\\ng_pk\\neigong-hunyuan-05.png",
    [6] = "gui\\animations\\ng_pk\\neigong-hunyuan-06.png",
    [7] = "gui\\animations\\ng_pk\\neigong-hunyuan-07.png"
  }
}
local g_item_chip = {
  "lbl_chip_1",
  "lbl_chip_2",
  "lbl_chip_3",
  "lbl_chip_4",
  "lbl_chip_5",
  "lbl_chip_6",
  "lbl_chip_7",
  "lbl_chip_8",
  "lbl_chip_9"
}
local g_item_gx = {}
local g_item_other_chip = {}
local g_item_other_gx = {}
local path = "form_stage_main\\skill\\form_neig_pk"
function main_form_init(self)
  self.Fixed = true
  return 1
end
function main_form_open(form)
  return
end
function on_main_form_close(form)
end
function show_result()
  local form = nx_value(path)
  if not nx_is_valid(form) then
    return
  end
  local manger = nx_value("NeigPKModule")
  if not nx_is_valid(manger) then
    return
  end
  local type = manger:GetType(0, false)
  local str = "lbl_other_chip_1"
  local image = "gui\\language\\ChineseS\\neigpk\\" .. nx_string(g_image[type])
  form[str].BackImage = image
  set_gx(form, "lbl_other_gx_", 1, 9, false)
end
function on_chip(side, index, type, consum)
  local form = nx_value(path)
  if not nx_is_valid(form) then
    return
  end
  if not g_bBegin then
    init_form(form)
    nx_pause(0.5)
  end
  local manger = nx_value("NeigPKModule")
  if not nx_is_valid(manger) then
    manger = nx_create("NeigPKModule")
    nx_set_value("NeigPKModule", manger)
  end
  if nx_int(side) == nx_int(1) then
    manger:SelfChip(index, type)
    start_animat(manger, form, index, true)
  elseif nx_int(side) == nx_int(-1) then
    if nx_int(index) > nx_int(0) then
      local str = "lbl_other_chip_" .. nx_string(index + 1)
      local image = "gui\\language\\ChineseS\\neigpk\\" .. nx_string(g_image[type])
      form[str].BackImage = image
    end
    manger:OtherChip(index, type)
  end
  update_chip_list()
  show_guangxian(form)
  set_next_point(form, consum)
end
function start_animat(manger, form, index, isSelf)
  manger:SetAnimt(index, true, isSelf)
  local asynor = nx_value("common_execute")
  asynor:AddExecute("heart_animat", form, nx_float(0.2), isSelf)
end
function update_revert(point, revert, nextChipPoint, max_point)
  revert_time = nx_int(revert / 1000)
  neig_point = nx_int(point)
  max_neig_point = nx_int(max_point)
  next_chip_point = nx_int(nextChipPoint)
  update_chip_list()
end
function update_chip_list()
  local form = nx_value(path)
  if form == nil or not nx_is_valid(form) then
    form = util_get_form(path, true)
    nx_set_value(path, form)
  end
  set_time_point(form, tonumber(nx_string(revert_time)), tonumber(nx_string(neig_point)))
end
function on_begin_init(self, target, show_1, show_2)
  local form = nx_value(path)
  if form == nil or not nx_is_valid(form) then
    form = util_get_form(path, true)
    nx_set_value(path, form)
  end
  if not g_bBegin then
    init_form(form)
  end
  face_to(self, target)
  set_neig_count(form, show_1, show_2)
end
function set_neig_count(form, self, other)
  for i = 1, 9 do
    local lbl = "lbl_chip_" .. nx_string(i)
    if nx_int(i) > nx_int(self) then
      form[lbl].Visible = false
    end
    lbl = "lbl_other_chip_" .. nx_string(i)
    if nx_int(i) > nx_int(other) then
      form[lbl].Visible = false
    end
  end
end
function init_form(form)
  g_bBegin = true
  local manger = nx_value("NeigPKModule")
  if not nx_is_valid(manger) then
    manger = nx_create("NeigPKModule")
    nx_set_value("NeigPKModule", manger)
  end
  manger:Reset()
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.AbsLeft = (gui.Width - form.Width) / 2
    form.AbsTop = (gui.Height - form.Height) * 5 / 6
  end
  neig_point = 0
  revert_time = 0
  for i = 1, 9 do
    local lbl = "lbl_chip_" .. nx_string(i)
    form[lbl].Text = nx_widestr("")
    form[lbl].BackImage = "gui\\language\\ChineseS\\neigpk\\kong.png"
    form[lbl].Visible = true
    lbl = "lbl_other_chip_" .. nx_string(i)
    form[lbl].Text = nx_widestr("")
    form[lbl].BackImage = "gui\\language\\ChineseS\\neigpk\\kong.png"
    form[lbl].Visible = true
    lbl = "lbl_gx_" .. nx_string(i)
    form[lbl].Visible = true
    form[lbl].BackImage = "gui\\special\\task\\wuzhuizong.png"
    lbl = "lbl_other_gx_" .. nx_string(i)
    form[lbl].Visible = true
    form[lbl].BackImage = "gui\\special\\task\\wuzhuizong.png"
  end
  form.lbl_other_chip_1.BackImage = "gui\\language\\ChineseS\\neigpk\\wenhao.png"
  form.lbl_other_chip_1.Visible = true
  set_time_point(form, 0, 0)
  set_next_point(form, 0)
  util_show_form(path, true)
  form.lbl_help.BackImage = "ng_kg"
end
function set_next_point(form, value)
  if not nx_is_valid(form) then
    return
  end
  if value == nil then
    value = 0
  end
  if 9999 < value then
    value = 9999
  end
  local point = tonumber(value)
  local pointArray = {}
  pointArray[1] = nx_int(point / 1000)
  point = tonumber(math.fmod(point, 1000))
  pointArray[2] = nx_int(point / 100)
  point = tonumber(math.fmod(point, 100))
  pointArray[3] = nx_int(point / 10)
  pointArray[4] = math.fmod(point, 10)
  for i = 1, 4 do
    local lbl = "lbl_n" .. nx_string(i)
    form[lbl].BackImage = "gui\\neigpk\\neigong-daoshu-" .. nx_string(pointArray[i]) .. ".png"
  end
end
function set_time_point(form, revert_time, neig_point)
  if not nx_is_valid(form) then
    return
  end
  if revert_time == nil then
    revert_time = 0
  end
  if neig_point == nil then
    neig_point = 0
  end
  if 99 < revert_time then
    revert_time = 99
  end
  local revert = tonumber(revert_time)
  local point = tonumber(neig_point)
  local revertArray = {}
  revertArray[1] = nx_int(revert / 10)
  revertArray[2] = nx_int(math.fmod(revert, 10))
  for i = 1, 2 do
    local lbl = "lbl_" .. nx_string(i)
    form[lbl].BackImage = "gui\\special\\neigpk\\neigong-daoshu-" .. nx_string(revertArray[i]) .. ".png"
  end
  set_scroll_bar(form)
end
function set_scroll_bar(form)
  local neig_scale = neig_point * 100 / max_neig_point
  local neig_width = neig_scale * MAX_BAR_WIDTH / 100
  local chip_scale = next_chip_point * 100 / max_neig_point
  local chip_width = chip_scale * MAX_BAR_WIDTH / 100
  if neig_width == 0 then
    form.lbl_current_bar.Visible = false
  else
    form.lbl_current_bar.Visible = true
  end
  form.lbl_current_bar.Width = neig_width
  if chip_width <= 0 then
    form.lbl_loss_bar.Visible = false
  elseif nx_int(next_chip_point) > nx_int(neig_point) then
    form.lbl_loss_bar.Visible = false
    form.lbl_current_bar.BackImage = "ngpkjdt2"
  else
    form.lbl_loss_bar.Visible = true
    form.lbl_current_bar.BackImage = current_bar_back
  end
  if chip_width < 4 then
    chip_width = 4
  end
  form.lbl_loss_bar.Width = chip_width
  form.lbl_loss_bar.Left = form.lbl_current_bar.Left - chip_width + neig_width
end
function face_to(self, target)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_self = game_visual:GetSceneObj(nx_string(self))
  local visual_target = game_visual:GetSceneObj(nx_string(target))
  if not nx_is_valid(visual_self) or not nx_is_valid(visual_target) then
    return
  end
  local scene_obj = nx_value("scene_obj")
  scene_obj:SceneObjAdjustAngle(visual_self, visual_target.PositionX, visual_target.PositionZ)
  scene_obj:SceneObjAdjustAngle(visual_target, visual_self.PositionX, visual_self.PositionZ)
end
function end_game()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value(path)
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("heart_animat", form)
  util_show_form(path, false)
  g_bBegin = false
end
function join_neig_pk(player, main_player)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_self = game_visual:GetSceneObj(nx_string(player))
  local visual_target = game_visual:GetSceneObj(nx_string(main_player))
  if not nx_is_valid(visual_self) or not nx_is_valid(visual_target) then
    return
  end
  local scene_obj = nx_value("scene_obj")
  scene_obj:SceneObjAdjustAngle(visual_self, visual_target.PositionX, visual_target.PositionZ)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if nx_string(client_player) == nx_string(player) then
    init_form()
  end
end
function hide_other_form(flag)
  if flag == 1 then
    local asynor = nx_value("common_execute")
    asynor:AddExecute("show_help", form, nx_float(0.4))
    form.index = 1
    form.inc = 1
  end
end
function show_guangxian(form)
  set_gx(form, "lbl_gx_", 1, 9, true)
  set_gx(form, "lbl_other_gx_", 2, 9, false)
end
function set_gx(form, pref, mi, ma, bSelf)
  local manger = nx_value("NeigPKModule")
  if not nx_is_valid(manger) then
    return
  end
  mi = mi - 1
  ma = ma - 1
  local ret = {}
  for i = mi, ma do
    local j = manger:GetType(i, bSelf)
    if j ~= 0 then
      if ret[j] == nil then
        ret[j] = 0
      end
      ret[j] = ret[j] + 1
    end
  end
  local maxValue = 0
  local ty
  for i, c in pairs(ret) do
    if c > maxValue then
      maxValue = c
      ty = i
    end
  end
  if ty == nil or ty == 0 then
    return nil
  end
  for i = mi, ma do
    local tempType = manger:GetType(i, bSelf)
    local str = pref .. nx_string(i + 1)
    if tempType == ty then
      form[str].BackImage = "neigongkuang"
    else
      form[str].BackImage = "gui\\special\\task\\wuzhuizong.png"
    end
  end
end
