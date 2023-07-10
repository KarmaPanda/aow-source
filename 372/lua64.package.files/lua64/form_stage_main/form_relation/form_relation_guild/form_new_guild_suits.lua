require("util_static_data")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\form_relation_guild\\sub_command_define")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
require("scene")
require("util_gui")
require("role_composite")
require("game_object")
require("define\\sysinfo_define")
require("form_stage_main\\switch\\switch_define")
local FORM_SUITS = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_suits"
local SUB_CUSTOMMSG_GUILD_2_SUIT_INFO = 102
local SUB_CUSTOMMSG_GET_GUILD_SUIT = 44
local DATA_STRUCT = 3
local QUERY_INFO = 1
local GET_SUITS = 2
function main_form_init(self)
  self.Fixed = true
  self.sex = 0
  self.cloth = ""
  self.cloth_h = ""
  self.hat = ""
  self.pants = ""
  self.shoes = ""
  self.face = ""
  self.weapon = ""
  self.clotheffect = ""
  self.hateffect = ""
  self.pantseffect = ""
  self.shoeseffect = ""
  self.weaponeffect = ""
  self.visual_obj = ""
  self.Actor2 = nx_null()
  return 1
end
function on_main_form_open(self)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_2_SUIT) then
  end
  self.mltbox_1.HtmlText = nx_widestr(guild_util_get_text("ui_getguildsuit_content"))
  nx_execute("tips_game", "move_tip_to_front")
  local player = get_client_player()
  if nx_is_valid(player) then
    self.sex = player:QueryProp("Sex")
    self.cloth = player:QueryProp("Cloth")
    self.cloth_h = player:QueryProp("Cloth") .. "_h"
    self.hat = player:QueryProp("Hat")
    self.pants = player:QueryProp("Pants")
    self.shoes = player:QueryProp("Shoes")
    self.face = player:QueryProp("Face")
    self.weapon = player:QueryProp("Weapon")
    self.clotheffect = player:QueryProp("ClothEffect")
    self.hateffect = player:QueryProp("HateEffect")
    self.pantseffect = player:QueryProp("PantsEffect")
    self.shoeseffect = player:QueryProp("ShoesEffect")
    self.weaponeffect = player:QueryProp("WeaponEffect")
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      local client_visual = game_visual:GetSceneObj(player.Ident)
      self.visual_obj = client_visual
    end
  end
  if not nx_is_valid(self.scenebox_1.Scene) then
    util_addscene_to_scenebox(self.scenebox_1)
  end
  show_role_model(self)
  local guild_name = get_player_gild_name()
  if nx_widestr(guild_name) == nx_widestr("") then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_2_SUIT_INFO), nx_widestr(guild_name))
  return 1
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  if nx_find_custom(self, "Actor2") and nx_is_valid(self.Actor2) then
    self.scenebox_1.Scene:Delete(self.Actor2)
  end
  nx_execute("scene", "delete_scene", self.scenebox_1.Scene)
  nx_execute("tips_game", "hide_tip", self)
  nx_destroy(self)
  nx_set_value(FORM_SUITS, nx_null())
  return
end
function show_role_model(form)
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return false
  end
  local scene = form.scenebox_1.Scene
  if not nx_is_valid(scene) then
    return false
  end
  local actor2 = create_role_composite(scene, true, form.sex)
  if not nx_is_valid(actor2) then
    return false
  end
  form.Actor2 = actor2
  while not actor2.LoadFinish do
    nx_pause(0.1)
  end
  local face_actor2 = get_role_face(actor2)
  while not nx_is_valid(face_actor2) do
    nx_pause(0.1)
    face_actor2 = get_role_face(actor2)
  end
  while not face_actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(form) then
    return false
  end
  local head_indo = {
    [1] = "hair",
    [2] = ""
  }
  local skin_info = {
    [1] = {link_name = "face", model_name = ""},
    [2] = {
      link_name = "hat",
      model_name = form.hat
    },
    [3] = {
      link_name = "cloth",
      model_name = form.cloth
    },
    [4] = {
      link_name = "pants",
      model_name = form.pants
    },
    [5] = {
      link_name = "shoes",
      model_name = form.shoes
    },
    [6] = {
      link_name = "cloth_h",
      model_name = form.cloth_h
    }
  }
  local effect_info = {
    [1] = {
      link_name = "HatEffect",
      model_name = form.hateffect
    },
    [2] = {
      link_name = "ClothEffect",
      model_name = form.clotheffect
    },
    [3] = {
      link_name = "PantsEffect",
      model_name = form.pantseffect
    },
    [4] = {
      link_name = "ShoesEffect",
      model_name = form.shoeseffect
    },
    [5] = {
      link_name = "WeaponEffect",
      model_name = form.weaponeffect
    }
  }
  for i, info in pairs(skin_info) do
    if string.len(nx_string(info.model_name)) > 0 then
      link_skin(actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
  for i, info in pairs(effect_info) do
    if model_name ~= nil and model_name ~= null then
      link_effect(actor2, info.link_name, info.model_name)
    end
  end
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return false
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  set_player_face_ex(actor2_face, form.face, form.sex, actor2)
  actor2:SetPosition(0, 0, 0)
  actor2:SetAngle(0, 0, 0)
  if nx_is_valid(form.scenebox_1.Scene) then
    util_add_model_to_scenebox(form.scenebox_1, actor2)
  end
  return true
end
function get_role_face(role_actor2)
  local actor_role = role_actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  return actor2_face
end
function update_role_model(form)
  local actor2 = form.Actor2
  if not nx_is_valid(actor2) then
    return
  end
  local skin_info = {
    [1] = {link_name = "face", model_name = ""},
    [2] = {
      link_name = "hat",
      model_name = form.hat
    },
    [3] = {
      link_name = "cloth",
      model_name = form.cloth
    },
    [4] = {
      link_name = "pants",
      model_name = form.pants
    },
    [5] = {
      link_name = "shoes",
      model_name = form.shoes
    },
    [6] = {
      link_name = "cloth_h",
      model_name = form.cloth_h
    }
  }
  local effect_info = {
    [1] = {
      link_name = "HatEffect",
      model_name = form.hateffect
    },
    [2] = {
      link_name = "ClothEffect",
      model_name = form.clotheffect
    },
    [3] = {
      link_name = "PantsEffect",
      model_name = form.pantseffect
    },
    [4] = {
      link_name = "ShoesEffect",
      model_name = form.shoeseffect
    },
    [5] = {
      link_name = "WeaponEffect",
      model_name = form.weaponeffect
    }
  }
  for i, info in pairs(skin_info) do
    if string.len(nx_string(info.model_name)) > 0 then
      nx_msgbox(nx_string(info.model_name))
      link_skin(actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
  for i, info in pairs(effect_info) do
    if model_name ~= nil and model_name ~= null then
      link_effect(actor2, info.link_name, info.model_name)
    end
  end
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return false
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  set_player_face_ex(actor2_face, form.face, form.sex, actor2)
end
function on_mousein_grid_cloth(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  local config = grid:GetItemName(index)
  nx_execute("tips_game", "show_tips_by_config", nx_string(config), x, y, form)
end
function on_mouseout_grid_cloth(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_grid_cloth_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local config = nx_string(grid:GetItemName(index))
  if config == "" or config == nil then
    return
  end
  local modleid = ""
  if form.sex == 0 then
    modleid = nx_execute("util_static_data", "item_query_ArtPack_by_id", config, "MaleModel")
  elseif form.sex == 1 then
    modleid = nx_execute("util_static_data", "item_query_ArtPack_by_id", config, "FemaleModel")
  end
  if nx_find_custom(form, "Actor2") and nx_is_valid(form.Actor2) and 0 < string.len(nx_string(modleid)) then
    unlink_skin(form.Actor2, "Pants")
    unlink_skin(form.Actor2, "Shoes")
    link_skin(form.Actor2, "cloth", modleid .. ".xmod")
  end
end
function on_btn_get_cloth_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local level = nx_int(btn.level)
  if nx_int(level) < nx_int(0) or nx_int(level) > nx_int(10) then
    return
  end
  local cloth_id = nx_string(btn.config_id)
  if cloth_id == "" or cloth_id == nil then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GET_GUILD_SUIT), nx_int(level), nx_string(cloth_id))
  local guild_name = get_player_gild_name()
  if nx_widestr(guild_name) == nx_widestr("") then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_2_SUIT_INFO), nx_widestr(guild_name))
end
function show_guild_suit(...)
  local form = nx_value(FORM_SUITS)
  if not nx_is_valid(form) then
    return
  end
  local arg_num = table.getn(arg)
  if arg_num < 1 then
    return
  end
  if arg_num % DATA_STRUCT ~= 0 then
    return
  end
  local data_num = arg_num / DATA_STRUCT
  local gbx = form.groupbox_2
  if not nx_is_valid(gbx) then
    return
  end
  gbx:DeleteAll()
  local real_pos = 1
  for i = 1, data_num do
    local index = 1 + (i - 1) * DATA_STRUCT
    local level = arg[index]
    index = index + 1
    local config_id = arg[index]
    index = index + 1
    local state = arg[index]
    if nx_string(config_id) ~= nx_string("") then
      local groupbox = create_ctrl("GroupBox", "gbox_cloth_" .. nx_string(i), form.groupbox_3, gbx)
      local imagegrid = create_ctrl("ImageGrid", "igrid_cloth_" .. nx_string(i), form.imagegrid_2, groupbox)
      local button = create_ctrl("Button", "btn_cloth_" .. nx_string(i), form.btn_1, groupbox)
      if nx_is_valid(groupbox) and nx_is_valid(imagegrid) and nx_is_valid(button) then
        button.level = level
        button.config_id = config_id
        if nx_int(state) == nx_int(0) then
          button.Enabled = false
          button.Text = nx_widestr(util_text("ui_newguild_suit_0"))
        elseif nx_int(state) == nx_int(1) then
          button.Enabled = true
          button.Text = nx_widestr(util_text("ui_newguild_suit_1"))
        elseif nx_int(state) == nx_int(2) then
          button.Enabled = false
          button.Text = nx_widestr(util_text("ui_newguild_suit_2"))
        end
        nx_bind_script(button, nx_current())
        nx_callback(button, "on_click", "on_btn_get_cloth_click")
        photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo")
        imagegrid:AddItem(0, nx_string(photo), nx_widestr(config_id), nx_int(1), nx_int(i - 1))
        nx_bind_script(imagegrid, nx_current())
        nx_callback(imagegrid, "on_mousein_grid", "on_mousein_grid_cloth")
        nx_callback(imagegrid, "on_mouseout_grid", "on_mouseout_grid_cloth")
        nx_callback(imagegrid, "on_select_changed", "on_grid_cloth_select_changed")
        change_pet_position(groupbox, nx_int(real_pos))
        real_pos = real_pos + 1
      end
    end
  end
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function change_pet_position(gbox, index)
  if not nx_is_valid(gbox) then
    return
  end
  if nx_int(index) <= nx_int(0) then
    return
  end
  local count = nx_number(index - 1)
  local row = math.fmod(count, 1)
  local col = math.floor(count / 1)
  gbox.Left = (gbox.Width + 3) * row
  gbox.Top = (gbox.Height + 3) * col
end
function get_player_gild_name()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local guild_name = client_player:QueryProp("GuildName")
  return guild_name
end
