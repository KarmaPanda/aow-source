require("util_gui")
require("share\\view_define")
require("define\\gamehand_type")
require("share\\logicstate_define")
local FUNC_TABLE = {
  roleinfo = "open_form_role_info",
  origin = "open_form_origin",
  zhaoshi = "open_form_zhaoshi",
  jishi = "on_jishi_click",
  offline = "open_form_offline",
  job = "open_form_job",
  task = "open_form_task",
  bag = "open_form_bag",
  friend = "open_form_friend",
  team = "open_form_team",
  system = "open_form_system"
}
function main_funcmenu_init(menu)
  local gui = nx_value("gui")
  menu.BackImage = "gui\\common\\form_back\\gongnengtanchu.png"
  menu.DrawMode = "Expand"
  menu.ItemHeight = 35
  menu.LeftBarWidth = 35
  menu.Font = "WRYH15"
  menu.ForeColor = "255,255,255,255"
  menu.SelectBackColor = "255,40,40,40"
  menu.SelectBorderColor = "255,80,80,80"
  create_menu_item(menu, "roleinfo", gui.TextManager:GetText("ui_main_funcmenu_self"), "gui\\special\\btn_main\\geren.png")
  create_menu_item(menu, "origin", gui.TextManager:GetText("ui_main_funcmenu_origin"), "gui\\special\\btn_main\\shenfen.png")
  create_menu_item(menu, "zhaoshi", gui.TextManager:GetText("ui_main_funcmenu_zhaoshi"), "gui\\special\\btn_main\\zhaoshi.png")
  create_menu_item(menu, "jishi", gui.TextManager:GetText("ui_main_funcmenu_jishi"), "gui\\special\\btn_main\\jishi.png")
  create_menu_item(menu, "offline", gui.TextManager:GetText("ui_main_funcmenu_lixian"), "gui\\special\\btn_main\\lixian.png")
  create_menu_item(menu, "job", gui.TextManager:GetText("ui_main_funcmenu_lifeskill"), "gui\\special\\btn_main\\shenghuojineng.png")
  create_menu_item(menu, "task", gui.TextManager:GetText("ui_main_funcmenu_task"), "gui\\special\\btn_main\\renwu.png")
  create_menu_item(menu, "bag", gui.TextManager:GetText("ui_main_funcmenu_bag"), "gui\\special\\btn_main\\baoguo.png")
  create_menu_item(menu, "friend", gui.TextManager:GetText("ui_main_funcmenu_haoyou"), "gui\\special\\btn_main\\haoyou.png")
  create_menu_item(menu, "team", gui.TextManager:GetText("ui_main_funcmenu_team"), "gui\\special\\btn_main\\zudui.png")
  create_menu_item(menu, "system", gui.TextManager:GetText("ui_main_funcmenu_system"), "gui\\special\\btn_main\\xitongshezhi.png")
  nx_callback(menu, "on_roleinfo_click", "on_roleinfo_click")
  nx_callback(menu, "on_origin_click", "open_form_origin")
  nx_callback(menu, "on_zhaoshi_click", "on_zhaoshi_click")
  nx_callback(menu, "on_jishi_click", "on_jishi_click")
  nx_callback(menu, "on_offline_click", "on_offline_click")
  nx_callback(menu, "on_job_click", "on_job_click")
  nx_callback(menu, "on_task_click", "on_task_click")
  nx_callback(menu, "on_bag_click", "on_bag_click")
  nx_callback(menu, "on_friend_click", "on_friend_click")
  nx_callback(menu, "on_team_click", "on_team_click")
  nx_callback(menu, "on_system_click", "on_system_click")
  nx_callback(menu, "on_drag_enter", "on_drag_enter")
  nx_callback(menu, "on_drag_move", "on_drag_move")
  return 1
end
function create_menu_item(menu, name, text, icon)
  local menu_item = menu:CreateItem(name, text)
  if string.len(icon) > 0 then
    menu_item.Icon = icon
  end
end
function on_drag_enter(menu, menu_item)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  game_hand.IsDragged = false
  menu.is_draged = false
  menu.count_drag_x = 0
  menu.count_drag_y = 0
end
function on_drag_move(menu, menu_item, x, y)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if not menu.is_draged and not game_hand.IsDragged then
    local func_manager = nx_value("func_manager")
    if nx_is_valid(menu_item) and nx_is_valid(func_manager) then
      menu.count_drag_x = menu.count_drag_x + x
      menu.count_drag_y = menu.count_drag_y + y
      if menu.count_drag_x < -10 or menu.count_drag_x > 10 or menu.count_drag_y < -10 or menu.count_drag_y > 10 then
        local func_name = FUNC_TABLE[menu_item.Name]
        if func_name ~= nil then
          local photo = func_manager:GetFuncPhoto(func_name)
          gui.GameHand:SetHand(GHT_FUNC, photo, "func", func_name, "", "")
          menu.is_draged = true
          game_hand.IsDragged = true
        end
      end
    end
  end
end
function open_form_origin(menu)
  util_auto_show_hide_form("form_stage_main\\form_origin\\form_origin")
end
function on_team_click(menu)
  util_auto_show_hide_form("form_stage_main\\form_team\\form_team_recruit")
end
function on_task_click(menu)
  util_auto_show_hide_form("form_stage_main\\form_task\\form_task_main")
end
function on_system_click(menu)
  util_auto_show_hide_form("form_stage_main\\form_system\\form_system_option")
end
function on_zhaoshi_click(menu)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "auto_show_hide_wuxue")
end
function on_roleinfo_click(menu)
  util_auto_show_hide_form("form_stage_main\\form_role_info\\form_role_info")
end
function on_bag_click(menu)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if client_player:FindProp("LogicState") then
    local offline_state = client_player:QueryProp("LogicState")
    if nx_int(offline_state) == nx_int(LS_OFFLINEJOB) then
      return
    end
  end
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag", true)
end
function on_job_click(menu)
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "open_form_job")
end
function on_offline_click(menu)
end
function on_jishi_click(menu)
  util_auto_show_hide_form("form_stage_main\\form_drama")
end
function on_friend_click(menu)
end
