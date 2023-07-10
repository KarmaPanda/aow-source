require("util_gui")
require("util_functions")
local npc_karma_list = {
  {
    "npc_present_far",
    "ui_present_to_npc_item",
    "far_give_npc_gift_menu",
    nil
  },
  {
    "query_good_feeling_far",
    "ui_query_good_feeling",
    "far_npc_good_feeling_add_menu",
    nil
  },
  {
    "npc_avenge_serve",
    "ui_mafan_title",
    "far_npc_avenge_serve_menu",
    nil
  },
  {
    "npc_friend_add_far",
    "ui_npc_friend_add",
    "far_add_npc_friend_menu",
    nil
  },
  {
    "npc_buddy_add_far",
    "ui_npc_buddy_add",
    "far_add_npc_buddy_menu",
    nil
  },
  {
    "npc_relation_cut_far",
    "ui_npc_relation_cut",
    "far_cut_npc_relation_menu",
    nil
  },
  {
    "npc_attention_add_far",
    "ui_npc_attention_add",
    "far_add_npc_attention_menu",
    nil
  },
  {
    "npc_attention_remove_far",
    "ui_npc_attention_del",
    "far_remove_npc_attention_menu",
    nil
  },
  {
    "npc_relation_refresh_far",
    "ui_npc_relation_refresh",
    nil,
    nil
  },
  {
    "npc_info_far",
    "ui_npc_info_show",
    "far_look_npc_info_menu",
    nil
  },
  {
    "npc_menu_close",
    "ui_g_close",
    nil,
    nil
  }
}
function main_form_init(form)
end
function on_main_form_open(form)
  form.Fixed = false
end
function on_main_form_close(form)
  clear_form_buttons(form)
  nx_destroy(form)
  nx_set_value("form_sns_menu", nx_null())
end
function clear_form_buttons(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupbox_menu_item:DeleteAll()
  form.btn_template.TabIndex = 0
end
function LoadMenuItem(npc_id, scene_id, x, y)
  local form = nx_value("form_stage_main\\form_relation\\form_sns_menu")
  if nx_is_valid(form) then
    nx_destroy(form)
    nx_set_value("form_sns_menu", nx_null())
  end
  form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_relation\\form_sns_menu", true)
  if not nx_is_valid(form) then
    return
  end
  clear_form_buttons(form)
  form.Visible = false
  form.Left = x
  form.Top = y
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  form.npc_id = npc_id
  form.scene_id = scene_id
  local count = table.getn(npc_karma_list)
  for i = 1, count do
    local bCreatedIt = true
    if npc_karma_list[i][3] == nil then
      if npc_karma_list[i][4] ~= nil then
        local enabled = nx_execute("menu_functions", "is_enable_" .. npc_karma_list[i][4], player, npc_id)
        if nx_int(enabled) == nx_int(1) then
          bCreatedIt = false
        end
      end
    else
      local visibled = nx_execute("menu_functions", "is_visible_" .. npc_karma_list[i][3], player, npc_id)
      local enabled = 2
      if nx_int(visibled) == nx_int(0) then
        bCreatedIt = false
      elseif npc_karma_list[i][4] ~= nil then
        enabled = nx_execute("menu_functions", "is_enable_" .. npc_karma_list[i][4], player, npc_id)
        if nx_int(enabled) == nx_int(1) then
          bCreatedIt = false
        end
      end
    end
    if true == bCreatedIt then
      create_button_using_template(nx_string(npc_karma_list[i][2]), npc_karma_list[i][1])
    end
  end
  form.groupbox_menu_item.Height = form.btn_template.TabIndex * form.btn_template.Height
  form.Height = form.groupbox_menu_item.Height + form.groupbox_menu_item.Top + 4
  form.Visible = true
end
function on_btn_menu_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "npc_id") or not nx_find_custom(form, "scene_id") then
    return
  end
  if not nx_find_custom(btn, "callbackFunc") then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  nx_execute(nx_current(), nx_string(btn.callbackFunc), nx_string(form.npc_id), nx_string(form.scene_id))
  if nx_is_valid(form) then
    nx_destroy(form)
    nx_set_value("form_sns_menu", nx_null())
  end
end
function create_button_using_template(strIndex, func)
  local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_relation\\form_sns_menu", true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local button = gui:Create("Button")
  if not nx_is_valid(button) then
    return
  end
  form.groupbox_menu_item:Add(button)
  form.btn_template.TabIndex = form.btn_template.TabIndex + 1
  button.Height = form.btn_template.Height
  button.Width = form.btn_template.Width
  button.Name = "btn_" .. nx_string(form.btn_template.TabIndex)
  button.DrawMode = form.btn_template.DrawMode
  button.BackImage = form.btn_template.BackImage
  button.FocusImage = form.btn_template.FocusImage
  button.PushImage = form.btn_template.PushImage
  button.ForeColor = form.btn_template.ForeColor
  button.Font = form.btn_template.Font
  button.Left = form.btn_template.Left
  button.Top = (form.btn_template.TabIndex - 1) * button.Height
  button.Text = nx_widestr(util_text(strIndex))
  button.callbackFunc = func
  nx_bind_script(button, nx_current())
  nx_callback(button, "on_click", "on_btn_menu_click")
  return
end
function npc_present_far(npc_id, scene_id)
  local form = nx_value("form_stage_main\\form_present_to_npc")
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_present_to_npc", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.npc_id = npc_id
  form.scene_id = scene_id
  form.type = 2
  form:Show()
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
end
function query_good_feeling_far(npc_id, scene_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = util_format_string("ui_karma_query_distance", nx_int(1000))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog.ok_btn.Text = nx_widestr(util_format_string("ui_karma_query_yes"))
  dialog.cancel_btn.Text = nx_widestr(util_format_string("ui_karma_query_no"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_query_good_feeling", nx_int(11), nx_string(npc_id), nx_int(scene_id))
  end
end
function npc_avenge_serve(npc_id, scene_id)
  nx_execute("custom_sender", "custom_avenge", nx_int(7), nx_string(npc_id), nx_int(scene_id))
end
function npc_friend_add_far(npc_id, scene_id)
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(0), nx_string(npc_id), nx_int(scene_id))
end
function npc_buddy_add_far(npc_id, scene_id)
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(1), nx_string(npc_id), nx_int(scene_id))
end
function npc_attention_add_far(npc_id, scene_id)
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(6), nx_string(npc_id), nx_int(scene_id))
end
function npc_attention_remove_far(npc_id, scene_id)
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(7), nx_string(npc_id), nx_int(scene_id))
end
function npc_relation_cut_far(npc_id, scene_id)
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(-1), nx_string(npc_id), nx_int(scene_id))
end
function npc_relation_refresh_far(npc_id, scene_id)
  nx_execute("custom_sender", "apply_add_npc_relation", nx_int(2), nx_string(npc_id), nx_int(scene_id))
end
function npc_info_far(npc_id, scene_id)
  nx_execute("form_stage_main\\form_relation\\form_npc_info", "show_npc_info", nx_string(npc_id), nx_int(scene_id))
end
function npc_menu_close(npc_id, scene_id)
  local form = nx_value("form_stage_main\\form_relation\\form_sns_menu")
  if nx_is_valid(form) then
    nx_destroy(form)
    nx_set_value("form_sns_menu", nx_null())
  end
end
