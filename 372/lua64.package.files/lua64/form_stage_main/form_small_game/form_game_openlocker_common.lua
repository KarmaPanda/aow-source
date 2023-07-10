require("util_gui")
require("role_composite")
require("util_static_data")
require("define\\sysinfo_define")
require("tips_data")
require("util_functions")
require("share\\logicstate_define")
require("form_stage_main\\form_home\\form_home_zh")
local enter_type_open_lock = 3
local lock_model_1 = "ini\\npc\\kaisuo.ini"
local lock_model_2 = "ini\\npc\\kaisuo02.ini"
local lock_effect_break = ""
local lock_effect_success = ""
local mode_lock = 1
local mode_zhen = 2
local hudu_angle = 57.32
local roate_speed = 3.1415926
local CLIENT_CUSTOMMSG_SMAILL_GAME_MSG = 505
local SMALLGAME_MSG_COMMON_OPEN_LOCKER_END = 4
local SMALLGAME_MSG_COMMONLOCK_ZHEN_ROATE = 5
local zhen_bone = "Bone04"
local lock_bone = "Bone02"
local mouse_shun_clock = 0
local mouse_ni_clock = 1
local failtime = 0
function main_form_init(form)
  form.Fixed = false
  form.actor2 = nil
  form.locker_level = 1
  form.rand_count = 20
  form.destroy_count = 6
end
function on_main_form_open(form)
  form.Fixed = false
  form.KeyDown = false
  form.actor2 = nil
  form.can_roate = true
  form.point1_x = 0
  form.point1_y = 0
  form.point2_x = 0
  form.point2_y = 0
  form.point3_x = 0
  form.point3_y = 0
  form.point4_x = 0
  form.point4_y = 0
  form.zhen_x = 0
  form.zhen_y = 0
  form.zhen_z = 0
  form.zhen_angle = 0
  form.is_zhen_dir = 0
  form.MouseRotateAngle = 0
  form.last_mouse_x = 0
  form.last_mouse_y = 0
  form.lock_x = 0
  form.lock_y = 0
  form.lock_z = 0
  form.LockRotateAngle = 0
  form.canplaysound = true
  turn_to_full_screen(form)
  form.canRotata = true
  add_mode_to_scenebox(form, lock_model_1)
  nx_callback(form.scenebox_mod, "on_mouse_move", "mouse_move")
  local LockpickGame = nx_value("LockpickCommonGame")
  if not nx_is_valid(LockpickGame) then
    return
  end
  local gui = nx_value("gui")
  gui.Focused = nx_null()
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item = "tool_home_qs"
  local tempphoto = ItemQuery:GetItemPropByConfigID(nx_string(item), nx_string("Photo"))
  local itemname = nx_execute("form_stage_main\\form_life\\form_job_gather", "takeoutmore_str", gui.TextManager:GetText(item))
  itemname = gui.TextManager:GetText(item)
  local text = nx_widestr("<font color=\"#5f4325\">") .. nx_widestr(itemname) .. nx_widestr("</font>")
  local MaterialNum = Get_Material_Num(item, VIEWPORT_TOOL)
  form.qsgj:AddItem(0, tempphoto, nx_widestr(""), MaterialNum, -1)
  failtime = 0
  local image_path = "gui\\special\\home\\qiaosuo\\home_qsms_0" .. nx_string(form.locker_level) .. ".png"
  form.lbl_6.BackImage = image_path
  local name = "ui_home_qsms_0" .. nx_string(form.locker_level)
  local gui = nx_value("gui")
  form.lbl_7.Text = nx_widestr(gui.TextManager:GetText(name))
end
function Get_Material_Num(item, viewID)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(viewID))
  if not nx_is_valid(view) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  local count = view:GetViewObjCount()
  for j = 1, count do
    local obj = view:GetViewObjByIndex(j - 1)
    local tempid = obj:QueryProp("ConfigID")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item)) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
    end
  end
  return nx_int(cur_amount)
end
function on_main_form_close(form)
  nx_destroy(form)
  local gui = nx_value("gui")
  gui.Focused = nx_null()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_small_game\\form_game_openlocker_common", true)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_shake", form)
  timer:UnRegister(nx_current(), "on_end_Rotata", form)
  if not nx_is_valid(form) then
    return false
  end
  form:Close()
end
function on_size_change()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_small_game\\form_game_openlocker_common")
  if nx_is_valid(form) then
    turn_to_full_screen(form)
  end
end
function on_btn_quit_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SMAILL_GAME_MSG), nx_int(SMALLGAME_MSG_COMMON_OPEN_LOCKER_END))
  close_form()
end
function turn_to_full_screen(self)
  local form = self
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.scenebox_mod.Width = form.Width
  form.scenebox_mod.Height = form.Height
  form.scenebox_mod.Left = (form.Width - form.scenebox_mod.Width) / 2
  form.scenebox_mod.Top = (form.Height - form.scenebox_mod.Height) / 2
  form.lbl_3.left = 0
  form.lbl_3.Top = form.Height - form.lbl_3.Height
  form.lbl_3.Width = form.Width
end
function add_mode_to_scenebox(form, mode_name)
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_mod)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if not nx_is_valid(form.scenebox_mod.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_mod)
  end
  if nx_is_valid(form.actor2) then
    form.scenebox_mod.Scene:Delete(form.actor2)
  end
  local scene = form.scenebox_mod.Scene
  form.actor2 = create_actor2(scene)
  local result = role_composite:CreateSceneObjectFromIni(form.actor2, lock_model_1)
  while nx_is_valid(form.actor2) and not role_composite:GetNpcLoadFinish(form.actor2) do
    nx_pause(0.1)
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_mod, form.actor2)
  local model = form.actor2
  model:SetPosition(-0.012, 0.75, 0)
  model:SetScale(5, 5, 5)
  local radius = 1.5
  if radius < 1 then
    radius = 1
  end
  if 50 < radius then
    radius = 50
  end
  scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
  scene.camera:SetAngle(0, 0, 0)
  scene.ClearZBuffer = true
  form.zhen_x, form.zhen_y, form.zhen_z = form.actor2:GetNodeAngle(zhen_bone)
  form.lock_x, form.lock_y, form.lock_z = form.actor2:GetNodeAngle(lock_bone)
  get_point_pos(form, scene)
end
function get_point_pos(form, scene)
  local x1, y1, z1 = form.actor2:GetNodePosition("Point01")
  local point1_x, point1_y = scene.camera:GetScreenPos(x1, y1, z1)
  form.point1_x = point1_x
  form.point1_y = point1_y
  local x2, y2, z2 = form.actor2:GetNodePosition("Point02")
  local point2_x, point2_y = scene.camera:GetScreenPos(x2, y2, z2)
  form.point2_x = point2_x
  form.point2_y = point2_y
  local x3, y3, z3 = form.actor2:GetNodePosition("Point03")
  local point3_x, point3_y = scene.camera:GetScreenPos(x3, y3, z3)
  form.point3_x = point3_x
  form.point3_y = point3_y
  local x4, y4, z4 = form.actor2:GetNodePosition("Point04")
  local point4_x, point4_y = scene.camera:GetScreenPos(x4, y4, z4)
  form.point4_x = point4_x
  form.point4_y = point4_y
end
function mouse_move(self, click_x, click_y)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local scene = form.scenebox_mod.Scene
  if not nx_is_valid(scene) then
    return
  end
  if form.can_roate == false then
    return
  end
  form.actor2:SetBoneAngle(lock_bone, form.LockRotateAngle, 0, 0)
  local timer = nx_value("timer_game")
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_openlocker_common", "on_update_shake", form)
  local speed = roate_speed
  local x, y, z = form.actor2:GetNodeAngle(zhen_bone)
  local elapse = nx_pause(0)
  local dist = speed * elapse
  if not nx_is_valid(form) then
    return
  end
  if click_x == form.last_mouse_x then
    return
  elseif click_x > form.last_mouse_x then
    play_sound("snd\\action\\minigame\\qiaosuo\\qs_03.wav")
    form.zhen_angle = form.zhen_angle - dist * 0.6
    if form.zhen_angle <= -1.57 then
      form.zhen_angle = -1.57
    end
    form.actor2:SetBoneAngle(zhen_bone, form.zhen_angle, 0, 0)
    direction = 0
  else
    play_sound("snd\\action\\minigame\\qiaosuo\\qs_03.wav")
    form.zhen_angle = form.zhen_angle + dist * 0.6
    if form.zhen_angle >= 1.57 then
      form.zhen_angle = 1.57
    end
    form.actor2:SetBoneAngle(zhen_bone, form.zhen_angle, 0, 0)
    direction = 1
  end
  form.last_mouse_x = click_x
  form.last_mouse_y = click_y
  if nx_float(form.zhen_angle) <= nx_float(0) then
    form.MouseRotateAngle = 90 + nx_int(form.zhen_angle * hudu_angle)
  else
    form.MouseRotateAngle = nx_int(form.zhen_angle * hudu_angle) + 90
  end
  form.actor2:SetBoneAngle(lock_bone, 0, 0, 0)
end
function on_key_up(key_value)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_small_game\\form_game_openlocker_common", true)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_find_custom(form, "can_roate") then
    return false
  end
  if form.can_roate == false then
    return
  end
  if form.KeyDown == false then
    return
  end
  form.KeyDown = false
  form.LockRotateAngle = 0
  form.actor2:SetBoneAngle(lock_bone, 0, 0, 0)
end
function on_key_down(key_value)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_small_game\\form_game_openlocker_common", true)
  if not nx_is_valid(form) then
    return false
  end
  if key_value == "Esc" then
    show_close_dialog(form)
    return
  end
  if not nx_is_valid(form) then
    return false
  end
  if not nx_find_custom(form, "can_roate") then
    return false
  end
  if form.can_roate == false then
    return
  end
  form.KeyDown = false
  if key_value == "A" then
    form.KeyDown = true
  else
    return
  end
  if form.canRotata == false then
    return
  end
  local speed = -1 * roate_speed
  while form.KeyDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    if form.can_roate == false then
      return
    end
    if form.canRotata == false then
      return
    end
    local LockpickGame = nx_value("LockpickCommonGame")
    local MaxRotataPercent = math.abs(LockpickGame:GetGameResNumber() - form.MouseRotateAngle)
    if MaxRotataPercent < form.rand_count then
      MaxRotataPercent = 0
      play_sound("snd\\action\\minigame\\qiaosuo\\qs_03.wav")
    else
      play_sound("snd\\action\\minigame\\qiaosuo\\qs_02.wav")
    end
    form.LockRotateAngle = form.LockRotateAngle + dist * 0.01
    if not nx_is_valid(form.actor2) then
      return
    end
    if form.LockRotateAngle * -1 > 1.57 * (100 - MaxRotataPercent) / 100 then
      local timer = nx_value("timer_game")
      form.canRotata = false
      timer:UnRegister(nx_current(), "on_end_Rotata", form)
      timer:Register(1000, -1, nx_current(), "on_end_Rotata", form, -1, -1)
      timer:UnRegister(nx_current(), "on_update_shake", form)
      if form.LockRotateAngle * -1 <= 1.57 then
        if failtime < form.destroy_count then
          form.shakecount = 0
          timer:Register(25, -1, nx_current(), "on_update_shake", form, -1, -1)
          failtime = failtime + 1
        else
          form.LockRotateAngle = 0
          form.actor2:SetBoneAngle(lock_bone, 0, 0, 0)
          form.can_roate = false
          game_send_roate(form.MouseRotateAngle)
        end
      else
        form.LockRotateAngle = 0
        form.actor2:SetBoneAngle(lock_bone, 0, 0, 0)
        form.can_roate = false
        game_send_roate(form.MouseRotateAngle)
      end
    end
    form.actor2:SetBoneAngle(lock_bone, form.LockRotateAngle, 0, 0)
    local x, y, z = form.actor2:GetNodeAngle(lock_bone)
  end
end
function on_end_Rotata(form)
  form.canRotata = true
end
function play_sound(filename)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_small_game\\form_game_openlocker_common", true)
  if not nx_is_valid(form) then
    return
  end
  if form.canplaysound == false then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not gui:FindSound(filename) then
    gui:AddSound(filename, nx_resource_path() .. filename)
  end
  gui:PlayingSound(filename)
  form.canplaysound = false
  local timer = nx_value("timer_game")
  timer:Register(1000, -1, nx_current(), "on_end_sound", form, -1, -1)
end
function on_end_sound(form)
  form.canplaysound = true
end
function on_update_shake(form)
  if form.shakecount >= 15 then
    form.shakecount = 0
    local timer = nx_value("timer_game")
    timer:UnRegister("form_stage_main\\form_small_game\\form_game_openlocker_common", "on_update_shake", form)
    form.actor2:SetBoneAngle(lock_bone, 0, 0, 0)
    return
  end
  form.actor2:SetBoneAngle(lock_bone, form.LockRotateAngle + (math.random(3) - 2) * 0.02, 0, 0)
  form.shakecount = form.shakecount + 1
  return
end
function on_product_grid_mousein_grid(grid, index)
  local item_config = nx_string(grid:GetItemAddText(index, nx_int(2)))
  if item_config == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if bExist == false then
    return
  end
  local item_name = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Name"))
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
  local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
  local item_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Level"))
  local prop_array = {}
  prop_array.ConfigID = nx_string(item_config)
  prop_array.ItemType = nx_int(item_type)
  prop_array.SellPrice1 = nx_int(item_sellPrice1)
  prop_array.Level = nx_int(item_level)
  prop_array.Photo = nx_string(photo)
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList", nx_current())
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  grid.Data.is_static = true
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_product_grid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function game_send_roate(roate)
  local LockpickGame = nx_value("LockpickCommonGame")
  if not nx_is_valid(LockpickGame) then
    return false
  end
  local number = LockpickGame:GetGameResNumber()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SMAILL_GAME_MSG), nx_int(SMALLGAME_MSG_COMMONLOCK_ZHEN_ROATE), nx_int(roate))
end
function on_end_game(result)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_small_game\\form_game_openlocker_common")
  if not nx_is_valid(form) then
    return false
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(form.actor2) then
    return false
  end
  action:ActionInit(form.actor2)
  action:ClearAction(form.actor2)
  if result == 1 then
    form.actor2:SetBoneScale(lock_bone, 0, 0, 0)
    form.actor2:SetBoneScale(zhen_bone, 0, 0, 0)
    nx_pause(0.5)
    action:BlendAction(form.actor2, "successful", false, true)
    play_sound("snd\\action\\minigame\\qiaosuo\\qs_04.wav")
    nx_pause(3)
  else
    if not nx_is_valid(form) then
      return
    end
    if not nx_is_valid(form.actor2) then
      return
    end
    local action_index = form.actor2:FindAction("failure")
    if 0 <= action_index then
      form.actor2:LoadAction(action_index)
      local time = 0
      while 0 >= form.actor2:GetActionFrame("failure") do
        time = time + nx_pause(0.05)
        if 10 < time then
          break
        end
        if not nx_is_valid(form.actor2) then
          break
        end
      end
    end
    action:BlendAction(form.actor2, "failure", false, true)
    nx_pause(0.5)
    form.actor2:SetBoneScale(zhen_bone, 0, 0, 0)
    self_systemcenterinfo("home_enter_failed_06")
    nx_pause(1)
  end
  close_form()
end
function show_close_dialog(form)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text("ui_smallgametc"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return false
    end
    if not nx_is_valid(form) then
      return false
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SMAILL_GAME_MSG), nx_int(SMALLGAME_MSG_COMMON_OPEN_LOCKER_END))
    form:Close()
  end
end
