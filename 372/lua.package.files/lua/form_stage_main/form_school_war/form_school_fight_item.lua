require("util_functions")
require("util_gui")
local form_name = "form_stage_main\\form_school_war\\form_school_fight_item"
local school_table = {
  ["5"] = {
    school = "school_jinyiwei",
    itemID = "ShangFangBaoJian"
  },
  ["6"] = {
    school = "school_gaibang",
    itemID = "DaGouGun"
  },
  ["7"] = {
    school = "school_junzitang",
    itemID = "LanTingXu"
  },
  ["8"] = {
    school = "school_jilegu",
    itemID = "ShenMuWangDing"
  },
  ["9"] = {
    school = "school_tangmen",
    itemID = "KongQueLing"
  },
  ["10"] = {
    school = "school_emei",
    itemID = "YiTianJian"
  },
  ["11"] = {
    school = "school_wudang",
    itemID = "TaiJiTu"
  },
  ["12"] = {
    school = "school_shaolin",
    itemID = "DaMoSheLi"
  },
  ["769"] = {
    school = "school_mingjiao",
    itemID = "PoLuYin"
  },
  ["832"] = {
    school = "school_tianshan",
    itemID = "YouXianZhen"
  }
}
local item_table = {
  ShangFangBaoJian = {
    "icon\\prop\\prop673.png",
    "ui_schoolwar_treasure_sfbj",
    "gui\\special\\schoolwar\\icon_jinyiwei_1.png"
  },
  DaGouGun = {
    "icon\\prop\\prop671.png",
    "ui_schoolwar_treasure_dgg",
    "gui\\special\\schoolwar\\icon_gaibang_1.png"
  },
  LanTingXu = {
    "icon\\prop\\prop672.png",
    "ui_schoolwar_treasure_ltx",
    "gui\\special\\schoolwar\\icon_junzitang_1.png"
  },
  ShenMuWangDing = {
    "icon\\prop\\prop674.png",
    "ui_schoolwar_treasure_smwd",
    "gui\\special\\schoolwar\\icon_jilegu_1.png"
  },
  KongQueLing = {
    "icon\\prop\\prop676.png",
    "ui_schoolwar_treasure_kql",
    "gui\\special\\schoolwar\\icon_tangmen_1.png"
  },
  YiTianJian = {
    "icon\\prop\\prop675.png",
    "ui_schoolwar_treasure_ytj",
    "gui\\special\\schoolwar\\icon_emei_1.png"
  },
  TaiJiTu = {
    "icon\\prop\\prop670.png",
    "ui_schoolwar_treasure_tjt",
    "gui\\special\\schoolwar\\icon_wudang_1.png"
  },
  DaMoSheLi = {
    "icon\\prop\\prop669.png",
    "ui_schoolwar_treasure_dmsl",
    "gui\\special\\schoolwar\\icon_shaolin_1.png"
  },
  PoLuYin = {
    "icon\\prop\\prop1658.png",
    "ui_schoolwar_treasure_ply",
    "gui\\special\\schoolwar\\icon_mingjiao_1.png"
  },
  YouXianZhen = {
    "icon\\prop\\prop_youxianzhen.png",
    "ui_schoolwar_treasure_yxz",
    "gui\\special\\schoolwar\\icon_tianshan_1.png"
  }
}
function main_form_init(self)
  self.Fixed = true
  self.school_id = "school_jinyi"
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  init_form(self)
  self.groupbox_detail.Visible = true
  self.groupbox_bmzb.Visible = false
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_DaMoSheLi.item_id = "DaMoSheLi"
  form.rbtn_TaiJiTu.item_id = "TaiJiTu"
  form.rbtn_YiTianJian.item_id = "YiTianJian"
  form.rbtn_DaGouGun.item_id = "DaGouGun"
  form.rbtn_KongQueLing.item_id = "KongQueLing"
  form.rbtn_LanTingXu.item_id = "LanTingXu"
  form.rbtn_ShangFangBaoJian.item_id = "ShangFangBaoJian"
  form.rbtn_ShenMuWangDing.item_id = "ShenMuWangDing"
  form.rbtn_PoLuYin.item_id = "PoLuYin"
  form.rbtn_YouXianZhen.item_id = "YouXianZhen"
end
function on_lbl_schoolitem_title_click(lbl)
  local form = lbl.ParentForm
  form.groupbox_detail.Visible = true
  form.groupbox_bmzb.Visible = false
end
function refresh(...)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local School = client_player:QueryProp("School")
  form.school_id = School
  show_school_detail(form)
  local gui = nx_value("gui")
  local arg_num = table.getn(arg)
  local desc_id = ""
  local desc_text = ""
  local sumitem = 0
  for i = 1, arg_num / 2 do
    local schoolid = nx_number(arg[(i - 1) * 2 + 1])
    local item_id = nx_string(arg[(i - 1) * 2 + 2])
    local info_table = item_table[item_id]
    if info_table ~= nil then
      local lbl_bg_name = "lbl_" .. nx_string(item_id)
      local lbl_bg = form.groupbox_detail:Find(nx_string(lbl_bg_name))
      lbl_bg.BackImage = nx_string(info_table[1])
      lbl_bg_name = "rbtn_" .. nx_string(item_id)
      lbl_bg = form.groupbox_catalog:Find(nx_string(lbl_bg_name))
      lbl_bg.FocusColor = "255,142,113,83"
      if nx_string(school_table[nx_string(schoolid)].school) == nx_string(form.school_id) then
        sumitem = sumitem + 1
        lbl_bg.ForeColor = "255,255,180,40"
      else
        lbl_bg.ForeColor = "255,156,156,156"
      end
      lbl_bg_name = "lbl_" .. nx_string(item_id) .. "_owner"
      lbl_bg = form.groupbox_detail:Find(nx_string(lbl_bg_name))
      if nx_is_valid(lbl_bg) then
        local SchoolSign
        if schoolid == 5 then
          SchoolSign = "gui//language//ChineseS//shengwang//jy.png"
        elseif schoolid == 6 then
          SchoolSign = "gui//language//ChineseS//shengwang//gb.png"
        elseif schoolid == 7 then
          SchoolSign = "gui//language//ChineseS//shengwang//jz.png"
        elseif schoolid == 8 then
          SchoolSign = "gui//language//ChineseS//shengwang//jl.png"
        elseif schoolid == 9 then
          SchoolSign = "gui//language//ChineseS//shengwang//tm.png"
        elseif schoolid == 10 then
          SchoolSign = "gui//language//ChineseS//shengwang//em.png"
        elseif schoolid == 11 then
          SchoolSign = "gui//language//ChineseS//shengwang//wd.png"
        elseif schoolid == 12 then
          SchoolSign = "gui//language//ChineseS//shengwang//sl.png"
        elseif schoolid == 769 then
          SchoolSign = "gui//language//ChineseS//shengwang//mj.png"
        elseif schoolid == 832 then
          SchoolSign = "gui//language//ChineseS//shengwang//ts.png"
        end
        lbl_bg.BackImage = SchoolSign
      end
    end
  end
  local text = nx_widestr(gui.TextManager:GetText("ui_schoolface_treasure_sum"))
  form.lbl_itemnum.Text = nx_widestr(text .. nx_widestr(sumitem))
end
function show_school_detail(form)
  form.groupbox_detail.Visible = true
  form.groupbox_bmzb.Visible = false
end
function on_btn_showallitem_click(btn)
  local form = btn.ParentForm
  form.groupbox_detail.Visible = true
  form.groupbox_bmzb.Visible = false
end
function showiteminfo(item_id)
  if item_table[nx_string(item_id)] == nil then
    return
  end
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.groupbox_detail.Visible = false
  form.groupbox_bmzb.Visible = true
  local item_photo = item_table[nx_string(item_id)][3]
  local item_name = item_table[nx_string(item_id)][2]
  form.lbl_bmzb_bg.BackImage = nx_string(item_photo)
  local desc_text = gui.TextManager:GetText(nx_string("desc_" .. nx_string(item_id)))
  local desc_fun = gui.TextManager:GetText(nx_string("desc_function_" .. nx_string(item_id)))
  if nx_string(item_name) == nil or nx_string(item_name) == "" then
    form.lbl_title_photo.Text = gui.TextManager:GetText("ui_schoolwar_treasure_nothing")
  else
    form.lbl_title_photo.Text = gui.TextManager:GetText(nx_string(item_name))
  end
  form.mltbox_bmzb.HtmlText = desc_text
  form.mltbox_zbdesc.HtmlText = desc_fun
end
function on_rbtn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_school_detail(form)
  showiteminfo(btn.item_id)
end
function on_lbl_bg_click(lbl)
  local name_text = string.gsub(nx_string(lbl.Name), "lbl_", "")
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_school_detail(form)
  showiteminfo(name_text)
end
function open_form(...)
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) then
    return
  end
  refresh(unpack(arg))
end
function request_open_form()
  local form = nx_value(form_name)
  if nx_is_valid(form) then
    form:Close()
    return
  end
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 2, 5)
end
