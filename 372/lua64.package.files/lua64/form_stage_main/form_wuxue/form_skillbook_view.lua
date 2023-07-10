require("share\\itemtype_define")
require("utils")
require("util_gui")
require("util_functions")
require("util_static_data")
require("tips_data")
require("tips_func_skill")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
local form_name = "form_stage_main\\form_wuxue\\form_skillbook_view"
function main_form_init(self)
  self.Fixed = false
  self.view_id = 0
  self.view_index = 0
  self.skillid = nil
  self.isskill = nil
end
function on_main_form_open(self)
  refresh_form_pos(self)
  init_form(self)
end
function on_main_form_close(self)
  if nx_find_custom(self, "Actor2") and nx_is_valid(self.Actor2) then
    self.scenebox_show.Scene:Delete(self.Actor2)
  end
  nx_execute("scene", "delete_scene", self.scenebox_show.Scene)
  nx_destroy(self)
end
function show_form(configid, view_id, view_index, StudyEnabled)
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.view_id = view_id
  form.view_index = view_index
  form.btn_1.Enabled = StudyEnabled
  local gui = nx_value("gui")
  if form.btn_1.Enabled == false then
    form.btn_1.HintText = nx_widestr(gui.TextManager:GetText("ui_wuxue_book_tips"))
  end
  local skillbook_ini = nx_execute("util_functions", "get_ini", "share\\Skill\\skill_maxlevel.ini")
  if not nx_is_valid(skillbook_ini) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return
  end
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return
  end
  local data_query_manager = nx_value("data_query_manager")
  if not nx_is_valid(data_query_manager) then
    return
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  local sec_index = skillbook_ini:FindSectionIndex(nx_string(configid))
  if sec_index < 0 then
    return
  end
  local str = skillbook_ini:GetSectionItemValue(sec_index, 0)
  local str_lst = util_split_string(str, ",")
  local skilllevel = nx_string(str_lst[1])
  form.mltbox_skil_title:Clear()
  form.mltbox_skill_desc1:Clear()
  form.mltbox_skill_desc2:Clear()
  form.mltbox_skill_desc3:Clear()
  form.mltbox_skill_desc4:Clear()
  form.mltbox_form_desc:Clear()
  local name = configid
  form.mltbox_skil_title:AddHtmlText(nx_widestr(gui.TextManager:GetText(name)), -1)
  local name_photo = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("NamePhoto"))
  form.lbl_skillbook_title.BackImage = nx_string(name_photo)
  local pack = ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string("LearnSkillPack"))
  pack = nx_int(pack)
  local strskillid = nx_execute("util_static_data", "item_static_query", pack, "TragetID", STATIC_DATA_ITEM_LEARNSKILL)
  local skillid_lst = util_split_string(strskillid, ",")
  form.skillid = skillid_lst[1]
  local wuxue_type = faculty_query:GetType(form.skillid)
  local wuxing_type = faculty_query:GetWuXing(form.skillid)
  local static_id = 0
  if nx_int(wuxue_type) == nx_int(WUXUE_SKILL) then
    static_id = get_ini_prop("share\\Skill\\skill_new.ini", form.skillid, "StaticData", "")
    local effect_type = nx_execute("util_static_data", "skill_static_query", nx_int(static_id), "EffectType")
    if effect_type == 1 then
      form.lbl_skillicon.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\shi_new.png")
    elseif effect_type == 2 then
      form.lbl_skillicon.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\xu_new.png")
    elseif effect_type == 3 then
      form.lbl_skillicon.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\jia_new.png")
    else
      local NormalSubType = nx_execute("util_static_data", "skill_static_query", nx_int(static_id), "NormalSubType")
      if NormalSubType == 0 then
        form.lbl_skillicon.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\qi_new.png")
      elseif NormalSubType == 1 then
        form.lbl_skillicon.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\ji_new.png")
      elseif NormalSubType == 2 then
        form.lbl_skillicon.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\she_new.png")
      end
    end
    form.isskill = true
  elseif nx_int(wuxue_type) == nx_int(WUXUE_NEIGONG) then
    form.lbl_skillicon.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\neigong_new.png")
    static_id = get_ini_prop("share\\Skill\\NeiGong\\neigong.ini", form.skillid, "StaticData", "")
    form.isskill = false
  elseif nx_int(wuxue_type) == nx_int(WUXUE_ZHENFA) then
    form.lbl_skillicon.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\zhenfa_new.png")
    static_id = get_ini_prop("share\\Skill\\zhenfa.ini", form.skillid, "StaticData", "")
    form.isskill = true
  end
  form.lbl_skill_attribute1.BackImage = nx_string("")
  form.lbl_skill_attribute2.BackImage = nx_string("")
  if wuxing_type == 1 then
    if nx_int(wuxue_type) == nx_int(WUXUE_SKILL) then
      form.lbl_skill_attribute2.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\gang.png")
    else
      form.lbl_skill_attribute1.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\gang.png")
    end
  elseif wuxing_type == 2 then
    if nx_int(wuxue_type) == nx_int(WUXUE_SKILL) then
      form.lbl_skill_attribute2.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\rou.png")
    else
      form.lbl_skill_attribute1.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\rou.png")
    end
  elseif wuxing_type == 3 then
    if nx_int(wuxue_type) == nx_int(WUXUE_SKILL) then
      form.lbl_skill_attribute2.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\yin.png")
    else
      form.lbl_skill_attribute1.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\yin.png")
    end
  elseif wuxing_type == 4 then
    if nx_int(wuxue_type) == nx_int(WUXUE_SKILL) then
      form.lbl_skill_attribute2.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\yang.png")
    else
      form.lbl_skill_attribute1.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\yang.png")
    end
  elseif wuxing_type == 5 then
    if nx_int(wuxue_type) == nx_int(WUXUE_SKILL) then
      form.lbl_skill_attribute2.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\taiji.png")
    else
      form.lbl_skill_attribute1.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\taiji.png")
    end
  elseif wuxing_type == 6 then
    form.lbl_skill_attribute1.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\yin.png")
    form.lbl_skill_attribute2.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\rou.png")
  elseif wuxing_type == 7 then
    form.lbl_skill_attribute1.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\yang.png")
    form.lbl_skill_attribute2.BackImage = nx_string("gui\\language\\ChineseS\\fighttips\\gang.png")
  end
  local item = nx_create("ArrayList")
  item.ConfigID = nx_string(form.skillid)
  item.Level = nx_int(skilllevel)
  item.StaticData = nx_int(static_id)
  if nx_int(wuxue_type) == nx_int(WUXUE_SKILL) then
    local values = {}
    values = skill_query:QuerySkillBaseProps("", nx_string(form.skillid), nx_int(skilllevel))
    item.VarPropNo = nx_int(nx_execute("util_static_data", "skill_static_query", nx_int(static_id), "MinVarPropNo")) + nx_int(skilllevel) - 1
    local prepare_time = values[1]
    local coolDown_time = values[2]
    local consume_hp = values[3]
    local consume_mp = values[4]
    local consume_hp_p = values[5]
    local consume_mp_p = values[6]
    local consume_sp = values[7]
    local consume_sp_p = values[8]
    local consume_mp_base = values[9]
    form.mltbox_skill_desc1:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("tips_huiqi_time", coolDown_time / 1000)), -1)
    local consumtext = nx_widestr("")
    if 0 < consume_mp then
      consumtext = consumtext .. nx_widestr(gui.TextManager:GetFormatText("tips_damage_neili", consume_mp))
    end
    if 0 < consume_sp then
      consumtext = consumtext .. nx_widestr(gui.TextManager:GetFormatText("tips_damage_sp", consume_sp))
    end
    form.mltbox_skill_desc2:AddHtmlText(nx_widestr(consumtext), -1)
    form.mltbox_skill_desc3:AddHtmlText(nx_widestr(get_skill_desc_info(item)), -1)
  elseif nx_int(wuxue_type) == nx_int(WUXUE_NEIGONG) then
    item.VarPropNo = nx_int(nx_execute("util_static_data", "neigong_static_query", nx_int(static_id), "MinVarPropNo")) + nx_int(skilllevel) - 1
    local itemtype = get_ini_prop("share\\Skill\\NeiGong\\neigong.ini", form.skillid, "ItemType", "")
    item.ItemType = itemtype
    local text = tips_manager:GetFuncText("NgAddProp", form.skillid, item, nx_int(itemtype))
    form.mltbox_skill_desc3:AddHtmlText(nx_widestr(text), -1)
    local BufferLevel = get_ini_prop("share\\Skill\\NeiGong\\neigong_varprop.ini", item.VarPropNo, "BufferLevel", "")
    item.BufferLevel = nx_int(BufferLevel)
    item.MaxLevel = item.Level
    text = tips_manager:GetFuncText("NgSchool", form.skillid, item, nx_int(itemtype))
    form.mltbox_skill_desc1:AddHtmlText(nx_widestr(text), -1)
    text = tips_manager:GetFuncText("SkillLevel", form.skillid, item, nx_int(itemtype))
    form.mltbox_skill_desc2:AddHtmlText(nx_widestr(text), -1)
    text = tips_manager:GetFuncText("NgBuffDesc", form.skillid, item, nx_int(itemtype))
    form.mltbox_skill_desc3:AddHtmlText(nx_widestr(text), -1)
  elseif nx_int(wuxue_type) == nx_int(WUXUE_ZHENFA) then
    item.is_static = true
    item.ZheFaMap = nx_int(get_ini_prop("share\\Skill\\zhenfa.ini", form.skillid, "ZheFaMap", ""))
    item.itemtype = nx_int(get_ini_prop("share\\Skill\\zhenfa.ini", form.skillid, "ItemType", ""))
    local text = tips_manager:GetFuncText("ZfCount", form.skillid, item, nx_int(itemtype))
    form.mltbox_skill_desc3:AddHtmlText(nx_widestr(text), -1)
    item.Level = nx_int(0)
    text = tips_manager:GetFuncText("ZfNextProp", form.skillid, item, nx_int(itemtype))
    form.mltbox_skill_desc3:AddHtmlText(nx_widestr(text), -1)
    item.Level = nx_int(1)
    text = tips_manager:GetFuncText("DescLevel", form.skillid, item, nx_int(itemtype))
    form.mltbox_skill_desc3:AddHtmlText(nx_widestr(text), -1)
    text = tips_manager:GetFuncText("ZfUse", form.skillid, item, nx_int(itemtype))
    form.mltbox_skill_desc3:AddHtmlText(nx_widestr(text), -1)
  end
  form.mltbox_skill_desc4:AddHtmlText(nx_widestr(gui.TextManager:GetText("desc_" .. nx_string(form.skillid))), -1)
  form.mltbox_skill_desc1.Top = form.mltbox_skil_title.Top + form.mltbox_skil_title:GetContentHeight() + 6
  form.mltbox_skill_desc1.Height = form.mltbox_skill_desc1:GetContentHeight() + 6
  local photo_bot = form.lbl_skillicon.Top + form.lbl_skillicon.Height + 8
  local desc1_bot = form.mltbox_skill_desc1.Top + form.mltbox_skill_desc1.Height
  form.mltbox_skill_desc2.Top = desc1_bot
  form.mltbox_skill_desc2.Height = form.mltbox_skill_desc2:GetContentHeight()
  local desc2_bot = form.mltbox_skill_desc2.Top + form.mltbox_skill_desc2.Height
  if photo_bot > desc2_bot then
    desc2_bot = photo_bot
  end
  form.groupscrollbox_1.Top = desc2_bot
  form.groupscrollbox_1.Height = form.Height - desc2_bot - 24
  form.mltbox_skill_desc3.Top = 0
  form.mltbox_skill_desc3.Height = form.mltbox_skill_desc3:GetContentHeight()
  form.mltbox_skill_desc4.Top = form.mltbox_skill_desc3.Top + form.mltbox_skill_desc3.Height
  form.mltbox_skill_desc4.Height = form.mltbox_skill_desc4:GetContentHeight()
  show_item_action(form, form.skillid, "ng_state_1", form.isskill)
  form.groupscrollbox_1:ResetChildrenYPos()
  nx_execute(nx_current(), "delay_add_weapon", form, form.skillid)
  local game_visual = nx_value("game_visual")
  if nx_find_custom(form, "Actor2") and nx_is_valid(form.Actor2) then
    game_visual:ChangeObjectColorState(form.Actor2, true)
  end
  form.ani_1:Play()
  nx_destroy(item)
end
function delay_add_weapon(form, skillid)
  nx_pause(0.1)
  add_weapon(form, skillid)
end
function refresh_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_study_click(btn)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_use_item", form.view_id, form.view_index)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_replay_click(btn)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  show_item_action(form, form.skillid, "ng_state_1", form.isskill)
  nx_execute(nx_current(), "delay_add_weapon", form, form.skillid)
  local game_visual = nx_value("game_visual")
  if nx_find_custom(form, "Actor2") and nx_is_valid(form.Actor2) then
    game_visual:ChangeObjectColorState(form.Actor2, true)
  end
end
