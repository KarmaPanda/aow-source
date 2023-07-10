require("util_static_data")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\form_relation_guild\\sub_command_define")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
require("scene")
require("util_gui")
require("role_composite")
require("game_object")
require("define\\sysinfo_define")
function main_form_init(self)
  self.Fixed = false
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
  set_player_face_ex(actor2_face, form.face, form.sex, form.visual_obj)
end
function show_role_model(form)
  local world = nx_value("world")
  if not nx_is_valid(world) then
    return false
  end
  local scene = form.guild_role.Scene
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
  set_player_face_ex(actor2_face, form.face, form.sex, form.visual_obj)
  actor2:SetPosition(0, 0, 0)
  actor2:SetAngle(0, 0, 0)
  if nx_is_valid(form.guild_role.Scene) then
    util_add_model_to_scenebox(form.guild_role, actor2)
  end
  return true
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.suitbox.canselect = true
  self.content.HtmlText = nx_widestr(guild_util_get_text("ui_getguildsuit_content"))
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
    local client_visual = game_visual:GetSceneObj(player.Ident)
    self.visual_obj = client_visual
  end
  if not nx_is_valid(self.guild_role.Scene) then
    util_addscene_to_scenebox(self.guild_role)
  end
  show_role_model(self)
  return 1
end
function main_form_close(self)
  if nx_find_custom(self, "Actor2") and nx_is_valid(self.Actor2) then
    self.guild_role.Scene:Delete(self.Actor2)
  end
  nx_execute("scene", "delete_scene", self.guild_role.Scene)
  nx_execute("tips_game", "hide_tip", self)
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_relation\\form_relation_guild\\form_get_guildsuit", nx_null())
end
function on_close_click(self)
  local form = self.Parent
  form.Visible = false
  form:Close()
  return 1
end
function show_guild_suit(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_get_guildsuit")
  if not nx_is_valid(form) then
    return
  end
  local arg_num = table.getn(arg)
  if arg_num < 1 then
    return
  end
  form.suitbox.ClomnNum = arg_num
  for i = 1, arg_num do
    photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", arg[i], "Photo")
    form.suitbox:AddItem(i - 1, nx_string(photo), nx_widestr(arg[i]), nx_int(1), nx_int(i - 1))
  end
end
function on_mousein_grid(grid, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local config = grid:GetItemName(index)
  nx_execute("tips_game", "show_tips_by_config", nx_string(config), x, y, form)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_suitbox_select_changed(self, index)
  local form = self.ParentForm
  local config = nx_string(self:GetItemName(index))
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
function on_ok_click(self)
  local form = self.ParentForm
  local selectid = form.suitbox:GetSelectItemIndex()
  if form.suitbox.ClomnNum == 1 then
    selectid = 0
  end
  if selectid == -1 then
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(guild_util_get_text("19266"), SYSTYPE_FIGHT, 0)
    end
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GET_GUILD_SUIT), nx_int(selectid))
  form.Visible = false
  form:Close()
end
