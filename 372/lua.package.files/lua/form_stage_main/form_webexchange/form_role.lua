require("util_gui")
require("util_functions")
require("share\\itemtype_define")
require("share\\view_define")
require("goods_grid")
require("share\\capital_define")
require("form_stage_main\\switch\\switch_define")
require("form_stage_main\\switch\\url_define")
require("form_stage_main\\form_webexchange\\webexchange_define")
local g_form_name = "form_stage_main\\form_webexchange\\form_role"
function close_webexchange(form)
  sendserver_msg(G_FLAG_CLOSE)
end
function on_main_form_init(form)
end
function on_main_form_open(form)
  local condition_id, charge = 0, 100000
  local ini = get_ini("share\\rule\\webexchange_config.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex("Main")
    if 0 <= sec_index then
      condition_id, charge = ini:ReadInteger(sec_index, "RoleCondition", 0), ini:ReadInteger(sec_index, "RoleCharge", 100000)
    end
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  local photo = player:QueryProp("Photo")
  form.lb_photo.BackImage = photo
  form.lb_name.Text = player:QueryProp("Name")
  form.btn_ok.Enabled = true
  form.lbl_2.Visible = false
  local ConditionManager = nx_value("ConditionManager")
  if nx_is_valid(ConditionManager) and not ConditionManager:CanSatisfyCondition(player, player, condition_id) then
    form.lbl_2.Visible = true
    form.btn_ok.Enabled = false
  end
  local mgr = nx_value("CapitalModule")
  if nx_is_valid(mgr) and not mgr:CanDecCapital(2, charge) then
    form.btn_ok.Enabled = false
  end
  form.lb_powerlevel.Text = util_format_string("desc_" .. player:QueryProp("LevelTitle"))
  local txt = nx_execute("form_stage_main\\form_role_info\\form_role_info", "get_xiae_text", player:QueryProp("CharacterFlag"), player:QueryProp("CharacterValue"))
  form.lb_char.Text = nx_widestr(txt)
  local sex = "ui_male"
  if player:QueryProp("Sex") == 1 then
    sex = "ui_female"
  end
  form.lb_sex.Text = util_format_string(sex)
  form.lbl_charge.Text = util_format_string("{@0:$}", nx_int(charge))
  form.charge = charge
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  sendserver_msg(G_FLAG_CLOSE)
end
function on_sell_click(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_WEB_EXCHANGE_BOX))
  if nx_is_valid(view) then
    local items = view:GetViewObjList()
    if table.getn(items) > 0 then
      show_tip(util_format_string("11050"), 2)
      return
    end
  end
  local mgr = nx_value("CapitalModule")
  if not mgr:CanDecCapital(2, form.charge) then
    show_tip(util_format_string("11051"), 2)
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    local charge = btn.ParentForm.lbl_charge.Text
    dialog.mltbox_info.HtmlText = util_format_string("webe_007", charge)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return
    end
  end
  sendserver_msg(G_GLAG_SELL_ROLE)
end
