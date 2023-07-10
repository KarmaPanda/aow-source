require("util_gui")
require("custom_sender")
require("util_functions")
require("define\\object_type_define")
require("share\\view_define")
require("form_stage_main\\form_task\\task_define")
require("share\\npc_type_define")
require("form_stage_main\\switch\\switch_define")
local TASK_PRIZE_NUM = 22
local CONFIG_LINE_HEIGHT = 15
local CONFIG_FIRST_LINE_HEIGHT = 20
local CONFIG_PRIZE_CONTROL_SPACE = 10
local g_show_task_table = {}
local g_show_wy_chapter = {}
local g_show_mzyy_chapter = {}
local g_show_jhjs_chapter = {}
local g_show_xbqzj_chapter = {}
local g_show_city_task_line = {
  20,
  23,
  24
}
local g_show_city_maintask_line = true
local g_show_city_subtask_line = true
local g_show_city_yltask_line = true
local g_city_task_line = {
  20,
  23,
  24
}
local g_school_drama = {
  school_wudang = "wd01",
  school_shaolin = "sl01",
  school_jinyiwei = "jyw01",
  school_junzitang = "jzt01",
  school_emei = "em01",
  school_gaibang = "gb01",
  school_tangmen = "tm01",
  school_jilegu = "jlg01"
}
local g_drama_node = {
  yyz01 = {mark = 1010000},
  qdz01 = {mark = 1020000},
  cd01 = {mark = 1030000},
  jm01 = {mark = 1040000},
  ly01 = {mark = 1050000},
  qdz02 = {mark = 1060000},
  wd01 = {mark = 1070000},
  jzt01 = {mark = 1080000},
  jyw01 = {mark = 1090000},
  tm01 = {mark = 1100000},
  sl01 = {mark = 1110000},
  em01 = {mark = 1120000},
  gb01 = {mark = 1130000},
  jlg01 = {mark = 1140000},
  wmp01 = {mark = 1150000},
  ergfyzq_001 = {mark = 16000000},
  mzyy_001 = {mark = 17000000},
  jhjs_001 = {mark = 18000000},
  xbqzj_001 = {mark = 19000000},
  yyc_001 = {mark = 20000000},
  city_zx_001 = {mark = 21000000},
  city_yl_001 = {mark = 22000000},
  city_gs_001 = {mark = 23000000},
  city_jtg_001 = {mark = 24000000},
  mj01 = {mark = 1160000},
  ts01 = {mark = 1170000}
}
local CAN_ACCEPT_MARK = 9000000
local CAN_ACCEPT_DRAMA_MARK = 9100000
local CAN_ACCEPT_ZHIXIAN_MARK = 9500000
local BEFORE_CHAPTER_MARK = 9600000
local CAN_ACCEPT_AREA_MARK = 9700000
local CAN_ACCEPT_GUIDE_MARK = 9800000
local DRAMA_PUZZLE_MARK = 9900000
local g_task_line = {
  [1] = {
    mark = 1000000,
    ui = "ui_ShenShiJuQing"
  },
  [2] = {
    mark = 2000000,
    ui = "ui_task_shimen"
  },
  [3] = {
    mark = 3000000,
    ui = "ui_task_day"
  },
  [4] = {
    mark = 4000000,
    ui = "ui_MenPaiRenWu"
  },
  [5] = {
    mark = 5000000,
    ui = "ui_task_side"
  },
  [6] = {
    mark = 6000000,
    ui = "ui_task_clone1"
  },
  [7] = {
    mark = 7000000,
    ui = "ui_task_enyuan_ex"
  },
  [8] = {
    mark = 8000000,
    ui = "ui_adventure_task"
  },
  [9] = {
    mark = 9000000,
    ui = "ui_task_guide"
  },
  [11] = {
    mark = 10000000,
    ui = "ui_task_war_fy"
  },
  [12] = {
    mark = 12000000,
    ui = "ui_task_force"
  },
  [13] = {
    mark = 13000000,
    ui = "ui_task_newschool"
  },
  [14] = {
    mark = 14000000,
    ui = "ui_task_newterritory"
  },
  [15] = {
    mark = 15000000,
    ui = "ui_task_shijia"
  },
  [16] = {
    mark = 16000000,
    ui = "ui_task_waiyuwulin"
  },
  [17] = {
    mark = 17000000,
    ui = "ui_task_mzyy"
  },
  [18] = {
    mark = 18000000,
    ui = "ui_task_jhjs"
  },
  [19] = {
    mark = 19000000,
    ui = "ui_task_xbqzj"
  },
  [20] = {
    mark = 20000000,
    ui = "ui_task_yyc"
  },
  [21] = {
    mark = 21000000,
    ui = "ui_task_city_zx"
  },
  [22] = {
    mark = 22000000,
    ui = "ui_task_city_yl"
  },
  [23] = {
    mark = 23000000,
    ui = "ui_task_city_gs"
  },
  [24] = {
    mark = 24000000,
    ui = "ui_task_city_jtg"
  }
}
local g_clone_info = {
  [1] = {
    mark = 6002001,
    scene = 27,
    ui = "ui_task_clone_kongqueshanzhuang"
  },
  [2] = {
    mark = 6002051,
    scene = 28,
    ui = "ui_task_clone_longmenkezhan"
  },
  [3] = {
    mark = 6002101,
    scene = 29,
    ui = "ui_task_clone_yanziwu"
  },
  [4] = {
    mark = 6002151,
    scene = 30,
    ui = "ui_task_clone_yanmenguan"
  },
  [5] = {
    mark = 6002201,
    scene = 31,
    ui = "ui_task_clone_murenxiang"
  },
  [6] = {
    mark = 6002251,
    scene = 32,
    ui = "ui_task_clone_shaolinchuangguan"
  },
  [7] = {
    mark = 6002301,
    scene = 33,
    ui = "ui_task_clone_zixiaodigong"
  },
  [8] = {
    mark = 6002351,
    scene = 34,
    ui = "ui_task_clone_wudangchuangguan"
  },
  [9] = {
    mark = 6002401,
    scene = 35,
    ui = "ui_task_clone_sheshenya"
  },
  [10] = {
    mark = 6002451,
    scene = 36,
    ui = "ui_task_clone_emeichuangguan"
  },
  [11] = {
    mark = 6002501,
    scene = 37,
    ui = "ui_task_clone_gaibangchushi"
  },
  [12] = {
    mark = 6002551,
    scene = 38,
    ui = "ui_task_clone_gaibangchuangguan"
  },
  [13] = {
    mark = 6002601,
    scene = 39,
    ui = "ui_task_clone_tangmenchushi"
  },
  [14] = {
    mark = 6002651,
    scene = 40,
    ui = "ui_task_clone_tangmenchuangguan"
  },
  [15] = {
    mark = 6002701,
    scene = 41,
    ui = "ui_task_clone_junzitangchushi"
  },
  [16] = {
    mark = 6002751,
    scene = 42,
    ui = "ui_task_clone_junzitangchuangguan"
  },
  [17] = {
    mark = 6002801,
    scene = 43,
    ui = "ui_task_clone_yuxiazhiyu"
  },
  [18] = {
    mark = 6002851,
    scene = 44,
    ui = "ui_task_clone_jinyiweichuangguan"
  },
  [19] = {
    mark = 6002901,
    scene = 45,
    ui = "ui_task_clone_jileguchushi"
  },
  [20] = {
    mark = 6002951,
    scene = 46,
    ui = "ui_task_clone_jileguchuangguan"
  },
  [21] = {
    mark = 6003001,
    scene = 48,
    ui = "ui_task_clone_qinyunbao"
  },
  [22] = {
    mark = 6003051,
    scene = 50,
    ui = "ui_task_clone_longchuan"
  },
  [23] = {
    mark = 6004001,
    scene = 251,
    ui = "ui_task_clone_duchuan"
  },
  [24] = {
    mark = 6004051,
    scene = 252,
    ui = "ui_task_clone_duchuanyewan"
  }
}
local g_rpt_limit = {
  repute_jianghu = "gui\\language\\ChineseS\\shengwang\\jh.png",
  repute_shaolin = "gui\\language\\ChineseS\\shengwang\\sl.png",
  repute_wudang = "gui\\language\\ChineseS\\shengwang\\wd.png",
  repute_tangmen = "gui\\language\\ChineseS\\shengwang\\tm.png",
  repute_junzitang = "gui\\language\\ChineseS\\shengwang\\jz.png",
  repute_emei = "gui\\language\\ChineseS\\shengwang\\em.png",
  repute_jinyiwei = "gui\\language\\ChineseS\\shengwang\\jy.png",
  repute_gaibang = "gui\\language\\ChineseS\\shengwang\\gb.png",
  repute_jilegu = "gui\\language\\ChineseS\\shengwang\\jl.png"
}
local g_task_submit_open_ui = {
  [71685] = {
    "form_stage_main\\form_shijia\\form_shijia_guide",
    "shijia_main_help"
  }
}
function main_form_init(self)
  self.Fixed = false
  self.SelectMltbox = nil
  self.SelectIndex = -1
  self.SelectNode = nil
  self.SelectCityNode = nil
  self.PageIndex = 3
  self.PageMark = 0
  return 1
end
local FORM_NAME_TASK = "form_stage_main\\form_task\\form_task_main"
function auto_show_hide_task_form()
  nx_execute("util_gui", "util_auto_show_hide_form", FORM_NAME_TASK)
  local form = nx_value(FORM_NAME_TASK)
  if nx_is_valid(form) then
    ui_show_attached_form(form)
  end
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.SelectMltbox = nil
  form.SelectIndex = -1
  form.SelectNode = nil
  g_show_wy_chapter = {}
  g_show_mzyy_chapter = {}
  g_show_jhjs_chapter = {}
  g_show_xbqzj_chapter = {}
  form.wy_drama_box_value = 0
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  if taskmgr.PageIndex == 0 then
    taskmgr.PageIndex = 3
  end
  show_wy_drama_rbtn(form)
  if form.rbtn_wy_drama.Visible == false and taskmgr.PageIndex == 6 then
    taskmgr.PageIndex = 3
  end
  show_city_rbtn(form)
  if form.rbtn_city.Visible == false and taskmgr.PageIndex == 7 then
    taskmgr.PageIndex = 3
  end
  form.PageIndex = taskmgr.PageIndex
  form.PageMark = taskmgr.PageMark
  if 0 == form.PageMark then
    form.PageMark = get_init_mark(form.PageIndex)
    taskmgr.PageMark = form.PageMark
  end
  show_all_info(form, form.PageIndex, form.PageMark)
  local form_trace = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_task_trace", true, false)
  if nx_is_valid(form_trace) then
    if form_trace.Visible then
      form.cbtn_show_track.Checked = true
    else
      form.cbtn_show_track.Checked = false
    end
  else
    form.cbtn_show_track.Checked = false
  end
  if form.PageIndex == 1 then
    form.rbtn_drama.Checked = true
  elseif form.PageIndex == 2 then
    form.rbtn_jianghu.Checked = true
  elseif form.PageIndex == 3 then
    form.rbtn_can_accept.Checked = true
  elseif form.PageIndex == 5 then
    form.rbtn_puzzle.Checked = true
  elseif form.PageIndex == 6 then
    form.rbtn_wy_drama.Checked = true
  elseif form.PageIndex == 7 then
    form.rbtn_city.Checked = true
  end
  form.rbtn_guide_task.Visible = false
  if form.rbtn_city.Visible == false and form.rbtn_wy_drama.Visible == true then
    form.rbtn_wy_drama.Left = form.rbtn_city.Left
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("Puzzle_Record", form, "form_stage_main\\form_task\\form_task_main", "on_puzzle_record_change")
  end
  return 1
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  nx_execute("tips_game", "hide_tip")
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("Puzzle_Record", form)
  end
  form.Visible = false
  nx_destroy(form)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function change_switch_buy_third_task(msg_type, is_open)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  if is_open == false then
    taskmgr.ThirdTaskChecked = 0
  else
    taskmgr.ThirdTaskChecked = 1
  end
end
function show_all_info(form, index, mark)
  form.tree_task_bak.Visible = false
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  show_reference_info(form, index, mark)
  show_detail_info(form, mark)
  refresh_trace_flag(form, index)
  form.PageIndex = index
  form.PageMark = mark
  taskmgr.PageIndex = index
  taskmgr.PageMark = mark
end
function refresh_task_show(task_id, cmd)
  nx_execute("form_stage_main\\form_task\\form_task_trace", "update_trace_info", task_id, cmd)
  local form = nx_value("form_stage_main\\form_task\\form_task_main")
  if not nx_is_valid(form) then
    return
  end
  local flag = check_drama_info(task_id)
  if flag == 3 then
    if form.rbtn_drama.Checked then
      show_all_info(form, 1, task_id)
    end
  elseif flag == 4 then
    if form.rbtn_jianghu.Checked then
      show_all_info(form, 2, task_id)
    elseif form.rbtn_wy_drama.Checked then
      show_all_info(form, 6, task_id)
    end
  elseif flag == 7 and form.rbtn_city.Checked then
    show_all_info(form, 7, task_id)
  end
end
function show_task(task_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id), 0)
  if row < 0 then
    return
  end
  local index = 1
  local line = client_player:QueryRecord("Task_Accepted", row, accept_rec_line)
  if line == task_line_main or line == task_line_menpai then
    index = 1
  elseif line == task_line_wy_drama or line == task_line_mzyy_drama or line == task_line_jhjs_drama or line == task_line_xbqzj_drama then
    index = 6
  elseif is_city_task_line(line) or line == task_line_city_zx or line == task_line_city_yl then
    index = 7
  else
    index = 2
  end
  local form = nx_value("form_stage_main\\form_task\\form_task_main")
  if not nx_is_valid(form) then
    return
  end
  show_all_info(form, index, task_id)
  if nx_number(index) == nx_number(1) then
    form.rbtn_drama.Checked = true
  elseif nx_number(index) == nx_number(2) then
    form.rbtn_jianghu.Checked = true
  elseif nx_number(index) == nx_number(6) then
    form.rbtn_wy_drama.Checked = true
  elseif nx_number(index) == nx_number(7) then
    form.rbtn_city.Checked = true
  end
end
function bind_record_call_back(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("Task_Accepted", form, "form_stage_main\\form_task\\form_task_main", "on_task_accepted_change")
    databinder:AddTableBind("Task_Record", form, "form_stage_main\\form_task\\form_task_main", "on_task_record_change")
  end
end
function refresh_form_trace()
  local form = nx_value("form_stage_main\\form_task\\form_task_main")
  if nx_is_valid(form) then
    local index = 1
    if form.rbtn_drama.Checked then
      index = 1
    elseif form.rbtn_jianghu.Checked then
      index = 2
    end
    local mark = get_init_mark(index)
    show_all_info(form, index, mark)
  end
end
function show_reference_info(form, index, mark)
  form.btn_giveup.Enabled = true
  form.btn_share.Enabled = true
  form.btn_track.Enabled = true
  if index == 1 then
    show_drama_tree(form, mark)
  elseif index == 2 then
    show_jianghu_tree(form, mark)
  elseif index == 3 then
    show_can_accept_tree(form, mark)
  elseif index == 4 then
    show_guide_task_tree(form, mark)
  elseif index == 5 then
    show_puzzle_task_tree(form, mark)
    form.btn_giveup.Enabled = false
    form.btn_share.Enabled = false
    form.btn_track.Enabled = false
  elseif index == 6 then
    show_wy_drama_tree(form, mark)
  elseif index == 7 then
    show_city_tree(form, mark)
  end
end
function show_drama_tree(form, mark)
  form.tree_task.Visible = false
  form.groupbox_drama.Visible = true
  form.groupscrollbox_accept.Visible = false
  form.groupscrollbox_jianghu.Visible = false
  form.groupscrollbox_guidetask.Visible = false
  form.groupscrollbox_puzzle.Visible = false
  form.groupbox_wy_drama.Visible = false
  form.groupbox_city.Visible = false
  form.lbl_zhuxian.Visible = false
  form.lbl_menpai.Visible = false
  form.lbl_zhuxian_back.Visible = false
  form.lbl_zhuxian_oldchapter_back.Visible = false
  form.lbl_zhuxian_allchapter_back.Visible = false
  form.lbl_menpai_back.Visible = false
  form.lbl_menpai_oldchapter_back.Visible = false
  form.lbl_menpai_allchapter_back.Visible = false
  form.mltbox_zhuxian.Visible = false
  form.mltbox_menpai.Visible = false
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local main_id = 0
  local menpai_id = 0
  local table_task = taskmgr:GetTaskByType(1, 0)
  local total = table.getn(table_task)
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    if line == task_line_main then
      main_id = id
    elseif line == task_line_menpai then
      menpai_id = id
    end
  end
  if main_id == 0 then
    main_id = client_player:QueryProp("LastLineTask")
    if nx_number(main_id) ~= nx_number(0) then
      update_drama_task_tree(mark, main_id, form.mltbox_zhuxian, false, true)
      local table_drama = taskmgr:GetDramaTaskInfo(main_id)
      local chapter = table_drama[3]
      form.mltbox_zhuxian.Visible = true
      form.lbl_zhuxian.Visible = true
      if 1 < nx_number(chapter) then
        form.lbl_zhuxian_oldchapter_back.Visible = true
        form.lbl_zhuxian_allchapter_back.Visible = true
      else
        form.lbl_zhuxian_back.Visible = true
      end
    end
  else
    update_drama_task_tree(mark, main_id, form.mltbox_zhuxian, true, true)
    local table_drama = taskmgr:GetDramaTaskInfo(main_id)
    local chapter = table_drama[3]
    form.mltbox_zhuxian.Visible = true
    form.lbl_zhuxian.Visible = true
    if 1 < nx_number(chapter) then
      form.lbl_zhuxian_oldchapter_back.Visible = true
      form.lbl_zhuxian_allchapter_back.Visible = true
    else
      form.lbl_zhuxian_back.Visible = true
    end
  end
  if menpai_id == 0 then
    menpai_id = client_player:QueryProp("LastLineTaskSchool")
    if nx_number(menpai_id) ~= nx_number(0) then
      update_drama_task_tree(mark, menpai_id, form.mltbox_menpai, false, true)
      local table_drama = taskmgr:GetDramaTaskInfo(menpai_id)
      local chapter = table_drama[3]
      form.mltbox_menpai.Visible = true
      form.lbl_menpai.Visible = true
      if 1 < nx_number(chapter) then
        form.lbl_menpai_oldchapter_back.Visible = true
        form.lbl_menpai_allchapter_back.Visible = true
      else
        form.lbl_menpai_back.Visible = true
      end
    end
  else
    update_drama_task_tree(mark, menpai_id, form.mltbox_menpai, true, true)
    local table_drama = taskmgr:GetDramaTaskInfo(menpai_id)
    local chapter = table_drama[3]
    form.mltbox_menpai.Visible = true
    form.lbl_menpai.Visible = true
    if 1 < nx_number(chapter) then
      form.lbl_menpai_oldchapter_back.Visible = true
      form.lbl_menpai_allchapter_back.Visible = true
    else
      form.lbl_menpai_back.Visible = true
    end
  end
end
function show_wy_drama_tree(form, mark)
  form.wy_drama_box_value = form.groupbox_wy_drama.VScrollBar.Value
  form.tree_task.Visible = false
  form.groupbox_drama.Visible = false
  form.groupscrollbox_accept.Visible = false
  form.groupscrollbox_jianghu.Visible = false
  form.groupscrollbox_guidetask.Visible = false
  form.groupscrollbox_puzzle.Visible = false
  form.groupbox_wy_drama.Visible = true
  form.groupbox_city.Visible = false
  form.groupbox_wy_drama.child_height = 0
  form.groupbox_wy_drama:DeleteAll()
  update_wy_drama_info(form, mark)
  update_new_drama_info(form, mark)
  update_jhjs_drama_info(form, mark)
  update_xbqzj_drama_info(form, mark)
end
function update_wy_drama_info(form, mark)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local main_id = 0
  local table_task = taskmgr:GetTaskByType(6, 0)
  local total = table.getn(table_task)
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    if line == task_line_wy_drama then
      main_id = id
    end
  end
  if main_id == 0 then
    main_id = client_player:QueryProp("LastLineTaskWY")
    if nx_number(main_id) ~= nx_number(0) then
      update_wy_drama_task_tree(mark, main_id, form.groupbox_wy_drama, false, true)
      local table_drama = taskmgr:GetDramaTaskInfo(main_id)
      local chapter = table_drama[3]
      form.mltbox_zhuxian.Visible = true
      form.lbl_zhuxian.Visible = true
      if 1 < nx_number(chapter) then
        form.lbl_zhuxian_oldchapter_back.Visible = true
        form.lbl_zhuxian_allchapter_back.Visible = true
      else
        form.lbl_zhuxian_back.Visible = true
      end
    end
  else
    update_wy_drama_task_tree(mark, main_id, form.groupbox_wy_drama, true, true)
    local table_drama = taskmgr:GetDramaTaskInfo(main_id)
    local chapter = table_drama[3]
    form.mltbox_zhuxian.Visible = true
    form.lbl_zhuxian.Visible = true
    if 1 < nx_number(chapter) then
      form.lbl_zhuxian_oldchapter_back.Visible = true
      form.lbl_zhuxian_allchapter_back.Visible = true
    else
      form.lbl_zhuxian_back.Visible = true
    end
  end
end
function update_new_drama_info(form, mark)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local main_id = 0
  local table_task = taskmgr:GetTaskByType(6, 0)
  local total = table.getn(table_task)
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    if line == task_line_mzyy_drama then
      main_id = id
    end
  end
  if main_id == 0 then
    main_id = client_player:QueryProp("LastLineTaskMZYY")
    if nx_number(main_id) ~= nx_number(0) then
      update_wy_drama_task_tree(mark, main_id, form.groupbox_wy_drama, false, true)
      local table_drama = taskmgr:GetDramaTaskInfo(main_id)
      local chapter = table_drama[3]
      form.mltbox_zhuxian.Visible = true
      form.lbl_zhuxian.Visible = true
      if 1 < nx_number(chapter) then
        form.lbl_zhuxian_oldchapter_back.Visible = true
        form.lbl_zhuxian_allchapter_back.Visible = true
      else
        form.lbl_zhuxian_back.Visible = true
      end
    end
  else
    update_wy_drama_task_tree(mark, main_id, form.groupbox_wy_drama, true, true)
    local table_drama = taskmgr:GetDramaTaskInfo(main_id)
    local chapter = table_drama[3]
    form.mltbox_zhuxian.Visible = true
    form.lbl_zhuxian.Visible = true
    if 1 < nx_number(chapter) then
      form.lbl_zhuxian_oldchapter_back.Visible = true
      form.lbl_zhuxian_allchapter_back.Visible = true
    else
      form.lbl_zhuxian_back.Visible = true
    end
  end
end
function update_jhjs_drama_info(form, mark)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local main_id = 0
  local table_task = taskmgr:GetTaskByType(6, 0)
  local total = table.getn(table_task)
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    if line == task_line_jhjs_drama then
      main_id = id
    end
  end
  if main_id == 0 then
    main_id = client_player:QueryProp("LastLineTaskJHJS")
    if nx_number(main_id) ~= nx_number(0) then
      update_wy_drama_task_tree(mark, main_id, form.groupbox_wy_drama, false, true)
      local table_drama = taskmgr:GetDramaTaskInfo(main_id)
      local chapter = table_drama[3]
      form.mltbox_zhuxian.Visible = true
      form.lbl_zhuxian.Visible = true
      if 1 < nx_number(chapter) then
        form.lbl_zhuxian_oldchapter_back.Visible = true
        form.lbl_zhuxian_allchapter_back.Visible = true
      else
        form.lbl_zhuxian_back.Visible = true
      end
    end
  else
    update_wy_drama_task_tree(mark, main_id, form.groupbox_wy_drama, true, true)
    local table_drama = taskmgr:GetDramaTaskInfo(main_id)
    local chapter = table_drama[3]
    form.mltbox_zhuxian.Visible = true
    form.lbl_zhuxian.Visible = true
    if 1 < nx_number(chapter) then
      form.lbl_zhuxian_oldchapter_back.Visible = true
      form.lbl_zhuxian_allchapter_back.Visible = true
    else
      form.lbl_zhuxian_back.Visible = true
    end
  end
end
function update_xbqzj_drama_info(form, mark)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local main_id = 0
  local table_task = taskmgr:GetTaskByType(6, 0)
  local total = table.getn(table_task)
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    if line == task_line_xbqzj_drama then
      main_id = id
    end
  end
  if main_id == 0 then
    main_id = client_player:QueryProp("LastLineTaskXBQZJ")
    if nx_number(main_id) ~= nx_number(0) then
      update_wy_drama_task_tree(mark, main_id, form.groupbox_wy_drama, false, true)
      local table_drama = taskmgr:GetDramaTaskInfo(main_id)
      local chapter = table_drama[3]
      form.mltbox_zhuxian.Visible = true
      form.lbl_zhuxian.Visible = true
      if 1 < nx_number(chapter) then
        form.lbl_zhuxian_oldchapter_back.Visible = true
        form.lbl_zhuxian_allchapter_back.Visible = true
      else
        form.lbl_zhuxian_back.Visible = true
      end
    end
  else
    update_wy_drama_task_tree(mark, main_id, form.groupbox_wy_drama, true, true)
    local table_drama = taskmgr:GetDramaTaskInfo(main_id)
    local chapter = table_drama[3]
    form.mltbox_zhuxian.Visible = true
    form.lbl_zhuxian.Visible = true
    if 1 < nx_number(chapter) then
      form.lbl_zhuxian_oldchapter_back.Visible = true
      form.lbl_zhuxian_allchapter_back.Visible = true
    else
      form.lbl_zhuxian_back.Visible = true
    end
  end
end
function show_city_tree(form, mark)
  local scroll_value = form.groupbox_city.VScrollBar.Value
  form.tree_task.Visible = false
  form.groupbox_drama.Visible = false
  form.groupscrollbox_accept.Visible = false
  form.groupscrollbox_jianghu.Visible = false
  form.groupscrollbox_guidetask.Visible = false
  form.groupscrollbox_puzzle.Visible = false
  form.groupbox_wy_drama.Visible = false
  form.groupbox_city.Visible = true
  form.groupbox_city:DeleteAll()
  form.groupbox_city.IsEditMode = true
  form.groupbox_city.subindex = 0
  update_city_task_tree(mark, form.groupbox_city, true, true)
  update_city_sub_task_tree(mark, form.groupbox_city, true, true)
  update_city_yl_task_tree(mark, form.groupbox_city, true, true)
  form.groupbox_city.IsEditMode = false
  form.groupbox_city:ResetChildrenYPos()
  form.groupbox_city.VScrollBar.Value = scroll_value
end
function show_jianghu_tree(form, select_mark)
  form.tree_task.Visible = true
  form.groupbox_drama.Visible = false
  form.groupscrollbox_accept.Visible = false
  form.groupscrollbox_jianghu.Visible = true
  form.groupscrollbox_guidetask.Visible = false
  form.groupscrollbox_puzzle.Visible = false
  form.groupbox_wy_drama.Visible = false
  form.groupbox_city.Visible = false
  local gui = nx_value("gui")
  local task_tree = form.tree_task
  if not nx_is_valid(task_tree) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local root_node = task_tree.RootNode
  if not nx_is_valid(root_node) then
    root_node = task_tree:CreateRootNode(nx_widestr(""))
  end
  local imagelist = gui:CreateImageList()
  imagelist:AddImage("gui\\special\\task\\wuzhuizong.png")
  imagelist:AddImage("gui\\special\\task\\zhuizong3.png")
  task_tree.ImageList = imagelist
  root_node.Mark = nx_int(-1)
  root_node.ImageIndex = -1
  clear_tree_view(form.tree_task)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local table_task = taskmgr:GetTaskByType(2, 0)
  local total = table.getn(table_task)
  local rpt_level = 1
  local rows = client_player:FindRecordRow("Repute_Record", 0, nx_string("repute_jianghu"), 0)
  if 0 <= rows then
    rpt_level = client_player:QueryRecord("Repute_Record", rows, 2)
  end
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    update_jianghu_task_tree(form, id, line, select_mark, rpt_level)
  end
  set_jianghu_group_position(form)
end
function show_can_accept_tree(form, mark)
  form.tree_task.Visible = false
  form.groupbox_drama.Visible = false
  form.groupscrollbox_accept.Visible = true
  form.groupscrollbox_jianghu.Visible = false
  form.groupscrollbox_guidetask.Visible = false
  form.groupscrollbox_puzzle.Visible = false
  form.groupbox_wy_drama.Visible = false
  form.groupbox_city.Visible = false
  form.cbtn_scene.Visible = false
  form.lbl_scene.Visible = false
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return 0
  end
  local last_main_id = client_player:QueryProp("LastLineTask")
  local last_school_id = client_player:QueryProp("LastLineTaskSchool")
  local main_flag = false
  local menpai_flag = false
  local task_table = taskmgr:GetTaskByType(1, 0)
  local table_count = table.getn(task_table)
  for i = 1, table_count, 2 do
    local id = task_table[i]
    local line = task_table[i + 1]
    if nx_number(line) == nx_number(task_line_main) then
      main_flag = true
    elseif nx_number(line) == nx_number(task_line_menpai) then
      menpai_flag = true
    end
  end
  local table_last_main_id = taskmgr:GetDramaTaskInfo(nx_int(last_main_id))
  local next_id = 0
  if table.getn(table_last_main_id) == 5 then
    next_id = table_last_main_id[5]
  end
  if nx_number(last_main_id) ~= nx_number(0) and main_flag == false and nx_int(next_id) ~= nx_int(0) then
    update_drama_task_tree(mark, last_main_id, form.mltbox_zhuxian_accept, false, false)
    form.lbl_zhuxian_accept.Visible = true
    form.lbl_zhuxian_accept_back.Visible = true
  else
    form.mltbox_zhuxian_accept.Visible = false
    form.lbl_zhuxian_accept.Visible = false
    form.lbl_zhuxian_accept_back.Visible = false
  end
  local table_last_school_id = taskmgr:GetDramaTaskInfo(nx_int(last_school_id))
  local next_school_id = 0
  if table.getn(table_last_school_id) == 5 then
    next_school_id = table_last_school_id[5]
  end
  if nx_number(last_school_id) ~= nx_number(0) and menpai_flag == false and nx_int(next_school_id) ~= nx_int(0) then
    update_drama_task_tree(mark, last_school_id, form.mltbox_menpai_accept, false, false)
    form.lbl_menpai_accept.Visible = true
    form.lbl_menpai_accept_back.Visible = true
  else
    form.mltbox_menpai_accept.Visible = false
    form.lbl_menpai_accept.Visible = false
    form.lbl_menpai_accept_back.Visible = false
  end
  local scene_id = 0
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if nx_is_valid(client_scene) then
    local gui = nx_value("gui")
    local config_id = client_scene:QueryProp("ConfigID")
    scene_id = taskmgr:GetSceneId(nx_string(config_id))
  end
  refresh_zhixian_accept(form, scene_id, mark)
  set_accept_group_position(form)
end
function set_accept_group_position(form)
  form.groupscrollbox_accept.IsEditMode = true
  local height = 2
  if form.mltbox_zhuxian_accept.Visible then
    form.lbl_zhuxian_accept.Top = height - 2
    form.lbl_zhuxian_accept_back.Top = height + 27
    form.mltbox_zhuxian_accept.Top = height + 27
    local height_text = form.mltbox_zhuxian_accept:GetContentHeight()
    form.mltbox_zhuxian_accept.ViewRect = "0,0,195," .. nx_string(height_text)
    form.mltbox_zhuxian_accept.Height = height_text + 10
    height = height + height_text + 10 + 27
  end
  if form.mltbox_menpai_accept.Visible then
    form.lbl_menpai_accept.Top = height - 2
    form.lbl_menpai_accept_back.Top = height + 27
    form.mltbox_menpai_accept.Top = height + 25
    local height_text = form.mltbox_menpai_accept:GetContentHeight()
    form.mltbox_menpai_accept.ViewRect = "0,0,195," .. nx_string(height_text)
    form.mltbox_menpai_accept.Height = height_text + 10
    height = height + height_text + 10 + 25
  end
  if form.groupbox_scene.Visible then
    form.groupbox_scene.Top = height - 2
    height = height + form.groupbox_scene.Height
  end
  if form.tree_zhixian_accept.Visible then
    form.tree_zhixian_accept.Top = height
    local table_node = form.tree_zhixian_accept:GetShowNodeList()
    form.tree_zhixian_accept.Height = table.getn(table_node) * 22 + 20
  end
  form.groupscrollbox_accept.Height = 403
  form.groupscrollbox_accept.IsEditMode = false
end
function set_jianghu_group_position(form)
  form.groupscrollbox_jianghu.IsEditMode = true
  local height = 0
  if form.tree_task.Visible then
    form.tree_task.Top = height
    local table_node = form.tree_task:GetShowNodeList()
    form.tree_task.Height = table.getn(table_node) * 22 + 50
  end
  form.groupscrollbox_jianghu.Height = 403
  form.groupscrollbox_jianghu.IsEditMode = false
end
function show_puzzle_task_tree(form, select_mark)
  form.tree_task.Visible = false
  form.groupbox_drama.Visible = false
  form.groupscrollbox_accept.Visible = false
  form.groupscrollbox_jianghu.Visible = false
  form.groupscrollbox_guidetask.Visible = false
  form.groupscrollbox_puzzle.Visible = true
  form.groupbox_wy_drama.Visible = false
  form.groupbox_city.Visible = false
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("Puzzle_Record") then
    return
  end
  local rows = client_player:GetRecordRows("Puzzle_Record")
  if rows < 1 then
    return
  end
  local root_node = form.tree_puzzle.RootNode
  if not nx_is_valid(root_node) then
    root_node = form.tree_puzzle:CreateRootNode(nx_widestr("1"))
  end
  for i = 0, rows - 1 do
    local puzzle_type = client_player:QueryRecord("Puzzle_Record", i, puzzle_rec_type)
    local index = client_player:QueryRecord("Puzzle_Record", i, puzzle_rec_index)
    local key = client_player:QueryRecord("Puzzle_Record", i, puzzle_rec_key)
    local title = client_player:QueryRecord("Puzzle_Record", i, puzzle_rec_title)
    local chapter_key = client_player:QueryRecord("Puzzle_Record", i, puzzle_rec_key)
    local main_mark = 0
    if puzzle_type == 1 then
      main_mark = -1
    else
      main_mark = -2
    end
    local main_node = root_node:FindNodeByMark(nx_int(main_mark))
    if not nx_is_valid(main_node) then
      local text = gui.TextManager:GetText("ui_puzzle_chapter_" .. chapter_key)
      main_node = root_node:CreateNode(nx_widestr(text))
      main_node.Mark = nx_int(main_mark)
      main_node.Font = "font_treeview"
      main_node.ForeColor = "255,255,153,0"
      main_node.ItemHeight = 30
      main_node.NodeBackImage = "gui\\common\\treeview\\tree_1_out.png"
      main_node.NodeFocusImage = "gui\\common\\treeview\\tree_1_on.png"
      main_node.NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png"
      main_node.ExpandCloseOffsetX = 0
      main_node.ExpandCloseOffsetY = 6
      main_node.TextOffsetX = 59
      main_node.TextOffsetY = 7
      main_node.NodeOffsetY = -5
    end
    local puzzle_mark = DRAMA_PUZZLE_MARK + index
    local puzzle_node = main_node:FindNodeByMark(nx_int(puzzle_mark))
    if not nx_is_valid(puzzle_node) then
      local text = gui.TextManager:GetText("ui_puzzle_title_" .. nx_string(title))
      puzzle_node = main_node:CreateNode(nx_widestr(text))
      puzzle_node.Mark = nx_int(puzzle_mark)
      puzzle_node.ImageIndex = 0
      puzzle_node.Font = "font_treeview"
      puzzle_node.NodeImageOffsetX = 30
      puzzle_node.TextOffsetX = 30
      puzzle_node.TextOffsetY = 2
      puzzle_node.NodeBackImage = "gui\\common\\treeview\\tree_2_out.png"
      puzzle_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_out.png"
      puzzle_node.NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png"
    end
    if nx_number(puzzle_mark) == nx_number(select_mark) then
      form.tree_puzzle.SelectNode = puzzle_node
    end
  end
  root_node:ExpandAll()
end
function show_guide_task_tree(form, select_mark)
  form.tree_task.Visible = false
  form.groupbox_drama.Visible = false
  form.groupscrollbox_accept.Visible = false
  form.groupscrollbox_jianghu.Visible = false
  form.groupscrollbox_guidetask.Visible = true
  form.groupscrollbox_puzzle.Visible = false
  form.groupbox_wy_drama.Visible = false
  form.groupbox_city.Visible = false
  local gui = nx_value("gui")
  local task_tree = form.tree_guide_task
  if not nx_is_valid(task_tree) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local root_node = task_tree.RootNode
  if not nx_is_valid(root_node) then
    root_node = task_tree:CreateRootNode(nx_widestr(""))
  end
  root_node.Mark = nx_int(-1)
  clear_tree_view(form.tree_guide_task)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local table_guide_task = {}
  local line_count = 0
  local drama_name = client_player:QueryRecord("DramaRec", 0, 0)
  table_guide_task = taskmgr:GetGuideTaskInfo(nx_string(drama_name))
  line_count = table.getn(table_guide_task)
  for i = 1, table.getn(table_guide_task) do
    local task_id = table_guide_task[i]
    update_guide_task_tree(form, task_id, select_mark)
  end
  local table_school_guide_task = {}
  local school_name = client_player:QueryProp("School")
  local school_drama_name = g_school_drama[nx_string(school_name)]
  if school_drama_name ~= nil then
    table_school_guide_task = taskmgr:GetGuideTaskInfo(nx_string(school_drama_name))
    line_count = line_count + table.getn(table_school_guide_task)
    for i = 1, table.getn(table_school_guide_task) do
      local task_id = table_school_guide_task[i]
      update_guide_task_tree(form, task_id, select_mark)
    end
  end
  form.groupscrollbox_guidetask.IsEditMode = true
  form.tree_guide_task.Top = -20
  form.tree_guide_task.Height = (line_count + 1) * 22 + 22
  form.groupscrollbox_guidetask.Height = 400
  form.groupscrollbox_guidetask.IsEditMode = false
end
function update_drama_task_tree(select_mark, task_id, mltbox, flag, roundflag)
  if not nx_is_valid(mltbox) then
    return
  end
  local form = mltbox.ParentForm
  mltbox.Visible = true
  mltbox:Clear()
  local mltbox_count = -1
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if task_id == nil or task_id == 0 then
    return
  end
  local table_drama = taskmgr:GetDramaTaskInfo(task_id)
  if table.getn(table_drama) ~= 5 then
    return
  end
  local line = table_drama[1]
  local drama_name = table_drama[2]
  local chapter = table_drama[3]
  local round = table_drama[4]
  local next_id = table_drama[5]
  local round_next = round
  local chapter_next = chapter
  if nx_int(next_id) ~= nx_int(0) then
    local table_drama_next = taskmgr:GetDramaTaskInfo(next_id)
    if table.getn(table_drama_next) ~= 5 then
      return
    end
    chapter_next = table_drama_next[3]
    round_next = table_drama_next[4]
  end
  if g_drama_node[drama_name] == nil then
    return
  end
  local drama_node_id = g_drama_node[drama_name].mark
  if drama_node_id == nil then
    return
  end
  local drama_node_desc = gui.TextManager:GetText(drama_name)
  if line == 1 then
    form.lbl_zhuxian.Text = nx_widestr(drama_node_desc)
    form.lbl_zhuxian_accept.Text = nx_widestr(drama_node_desc)
  elseif line == 4 then
    form.lbl_menpai.Text = nx_widestr(drama_node_desc)
    form.lbl_menpai_accept.Text = nx_widestr(drama_node_desc)
  end
  if nx_number(chapter) > nx_number(1) and roundflag == true then
    local before_node_desc = gui.TextManager:GetText("ui_before_chapter")
    before_node_desc = nx_widestr("<center><font face=\"font_treeview\" color=\"#c8b464\">") .. nx_widestr(before_node_desc) .. nx_widestr("</font></center>")
    local before_node_id = BEFORE_CHAPTER_MARK + 1000 + chapter
    if nx_string(mltbox.Name) == "mltbox_menpai" then
      before_node_id = BEFORE_CHAPTER_MARK + 2000 + chapter
    end
    mltbox:AddHtmlText(nx_widestr(before_node_desc), nx_int(before_node_id))
    mltbox_count = mltbox_count + 1
  end
  local chapter_node_id = drama_node_id + chapter * 100
  local chapter_text_id = drama_name .. "_" .. nx_string(chapter)
  local chapter_image = chapter
  if roundflag == false then
    chapter_node_id = drama_node_id + chapter_next * 100
    chapter_text_id = drama_name .. "_" .. nx_string(chapter_next)
    chapter_image = chapter_next
  end
  local chapter_node_desc = gui.TextManager:GetText(chapter_text_id)
  chapter_node_desc = nx_widestr("<font face=\"font_chapter\">") .. nx_widestr(chapter_node_desc) .. nx_widestr("</font>")
  chapter_node_desc = nx_widestr("<img src=\"gui\\language\\ChineseS\\task\\") .. nx_widestr(chapter_image) .. nx_widestr(".png\" data=\"\" />") .. nx_widestr(chapter_node_desc)
  mltbox:AddHtmlText(nx_widestr(chapter_node_desc), nx_int(chapter_node_id))
  mltbox_count = mltbox_count + 1
  if roundflag == true then
    for i = 1, 4 do
      local round_node_id = drama_node_id + chapter * 100 + i
      local round_text_id = chapter_text_id .. "_" .. nx_string(i)
      local round_node_desc = gui.TextManager:GetText(round_text_id)
      local round_text = util_text("ui_drama_round_" .. nx_string(i))
      round_node_desc = nx_widestr("  ") .. nx_widestr(round_text) .. nx_widestr(" ") .. nx_widestr(round_node_desc)
      round_node_desc = nx_widestr("<font face=\"font_treeview\">") .. nx_widestr(round_node_desc) .. nx_widestr("</font>")
      local state = get_task_complete_state(task_id)
      local completed = taskmgr:CompletedByRec(nx_string(task_id))
      if round > i or false == flag and chapter < chapter_next or nx_int(next_id) == nx_int(0) and completed == 1 then
        round_node_desc = round_node_desc .. nx_widestr(" ") .. nx_widestr("<img src=\"gui\\language\\ChineseS\\task\\icon_complete.png\" data=\"\"/>")
      end
      mltbox:AddHtmlText(nx_widestr(round_node_desc), nx_int(round_node_id))
      mltbox_count = mltbox_count + 1
      if nx_number(select_mark) == nx_number(round_node_id) then
        mltbox:SetHtmlItemSelected(nx_int(mltbox_count), true)
        form.SelectMltbox = mltbox
        form.SelectIndex = mltbox_count
      end
      if flag and i == round then
        local task_title = get_task_title(task_id)
        if nx_widestr(task_title) == nx_widestr("") then
          return
        end
        task_title = nx_widestr("       ") .. nx_widestr(task_title)
        task_title = nx_widestr("<font face=\"font_treeview\" color=\"#ffffff\">") .. nx_widestr(task_title) .. nx_widestr("</font>")
        if state == 2 then
          task_title = nx_widestr(task_title) .. nx_widestr(util_text("ui_spacecansubmit"))
        end
        mltbox:AddHtmlText(nx_widestr(task_title), nx_int(task_id))
        mltbox_count = mltbox_count + 1
        if nx_number(select_mark) == nx_number(task_id) then
          mltbox:SetHtmlItemSelected(nx_int(mltbox_count), true)
          form.SelectMltbox = mltbox
          form.SelectIndex = mltbox_count
        end
      end
    end
  else
    local round_node_id = CAN_ACCEPT_DRAMA_MARK + task_id
    local round_text_id = chapter_text_id .. "_" .. nx_string(round_next)
    local round_text = util_text("ui_drama_round_" .. nx_string(round_next))
    local round_node_desc = gui.TextManager:GetText(round_text_id)
    round_node_desc = nx_widestr(" ") .. nx_widestr(round_text) .. nx_widestr(" ") .. nx_widestr(round_node_desc)
    round_node_desc = nx_widestr("<font face=\"font_treeview\">") .. nx_widestr(round_node_desc) .. nx_widestr("</font>")
    mltbox:AddHtmlText(nx_widestr(round_node_desc), nx_int(round_node_id))
    mltbox_count = mltbox_count + 1
    if nx_number(select_mark) == nx_number(round_node_id) then
      mltbox:SetHtmlItemSelected(nx_int(mltbox_count), true)
      form.SelectMltbox = mltbox
      form.SelectIndex = mltbox_count
    end
  end
end
function update_city_task_tree(select_mark, groupbox, iscompleteflag, roundflag)
  if not nx_is_valid(groupbox) then
    return
  end
  local form = groupbox.ParentForm
  groupbox.Visible = true
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local main_id = 0
  local table_task = taskmgr:GetTaskByType(7, 0)
  local total = table.getn(table_task)
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    if is_city_task_line(line) then
      main_id = id
    end
  end
  if nx_number(main_id) == nx_number(0) then
    return
  end
  local title_box = clone_control(form, "city_title_box", groupbox.subindex)
  groupbox:Add(title_box)
  title_box.Left = 0
  local aid = title_box.aid
  groupbox.subindex = groupbox.subindex + 1
  local child_name = string.format("%s_%s", nx_string("lbl_city_name"), nx_string(aid))
  local lbl_city_name = title_box:Find(child_name)
  lbl_city_name.Visible = true
  lbl_city_name.Text = nx_widestr(gui.TextManager:GetText("ui_task_city_mainline"))
  nx_bind_script(lbl_city_name, nx_current())
  nx_callback(lbl_city_name, "on_click", "on_city_title_click")
  lbl_city_name.select_mark = select_mark
  child_name = string.format("%s_%s", nx_string("lbl_city_title_close"), nx_string(aid))
  local btn_title_close = title_box:Find(child_name)
  child_name = string.format("%s_%s", nx_string("lbl_city_title_open"), nx_string(aid))
  local btn_title_open = title_box:Find(child_name)
  if g_show_city_maintask_line then
    btn_title_open.Visible = true
    btn_title_close.Visible = false
  else
    btn_title_open.Visible = false
    btn_title_close.Visible = true
  end
  if g_show_city_maintask_line then
    for i = 1, table.getn(g_city_task_line) do
      local target_line = g_city_task_line[i]
      local task_list = {}
      local table_task = taskmgr:GetTaskByType(7, 0)
      local total = table.getn(table_task)
      for j = 1, total, 2 do
        local id = table_task[j]
        local line = table_task[j + 1]
        if line == target_line then
          table.insert(task_list, id)
        end
      end
      if 0 < nx_number(table.getn(task_list)) then
        local sub_title_box = clone_control(form, "city_sub_title_box", groupbox.subindex)
        groupbox:Add(sub_title_box)
        sub_title_box.Left = 20
        local aid = sub_title_box.aid
        groupbox.subindex = groupbox.subindex + 1
        child_name = string.format("%s_%s", nx_string("lbl_city_sub_name"), nx_string(aid))
        local lbl_city_sub_name = sub_title_box:Find(child_name)
        lbl_city_sub_name.Visible = true
        lbl_city_sub_name.Text = nx_widestr(gui.TextManager:GetText(g_task_line[target_line].ui))
        nx_bind_script(lbl_city_sub_name, nx_current())
        nx_callback(lbl_city_sub_name, "on_click", "on_city_main_title_click")
        lbl_city_sub_name.select_mark = select_mark
        lbl_city_sub_name.line = target_line
        child_name = string.format("%s_%s", nx_string("lbl_city_sub_close"), nx_string(aid))
        local btn_sub_title_close = sub_title_box:Find(child_name)
        child_name = string.format("%s_%s", nx_string("lbl_city_sub_open"), nx_string(aid))
        local btn_sub_title_open = sub_title_box:Find(child_name)
        if is_city_main_task_show(target_line) then
          btn_sub_title_open.Visible = true
          btn_sub_title_close.Visible = false
        else
          btn_sub_title_open.Visible = false
          btn_sub_title_close.Visible = true
        end
        if is_city_main_task_show(target_line) then
          local task_count = table.getn(task_list)
          local box_city_task = clone_control(form, "box_city_task", groupbox.subindex)
          groupbox:Add(box_city_task)
          box_city_task.Left = 0
          local aid = box_city_task.aid
          groupbox.subindex = groupbox.subindex + 1
          child_name = string.format("%s_%s", nx_string("mltbox_city_task"), nx_string(aid))
          local mltbox = box_city_task:Find(child_name)
          nx_bind_script(mltbox, nx_current())
          nx_callback(mltbox, "on_select_item_change", "on_wy_mltbox_select_item_change")
          mltbox:Clear()
          mltbox.Height = 0
          local mltbox_count = 0
          for j = 1, table.getn(task_list) do
            local taskid = task_list[j]
            local task_title = get_task_title(taskid)
            task_title = nx_widestr("       ") .. nx_widestr(task_title)
            task_title = nx_widestr("<font face=\"font_treeview\" color=\"#ffffff\">") .. nx_widestr(task_title) .. nx_widestr("</font>")
            mltbox:AddHtmlText(nx_widestr(task_title), nx_int(taskid))
            mltbox.Height = mltbox.Height + mltbox.LineHeight
            if nx_number(select_mark) == nx_number(taskid) then
              mltbox:SetHtmlItemSelected(nx_int(mltbox_count), true)
              form.SelectMltbox = mltbox
              form.SelectIndex = mltbox_count
              form.SelectCityNode = mltbox
              form.SelectCityNode.mark = taskid
            end
            box_city_task.Height = mltbox.Height
            local track_flag = 1
            local text_trace_list = nx_execute("form_stage_main\\form_task\\form_task_trace", "get_trace_list_str")
            local table_trace = util_split_string(text_trace_list, ",")
            for i, id in pairs(table_trace) do
              if nx_number(id) == nx_number(taskid) then
                track_flag = 0
                break
              end
            end
            local is_track = 0
            if track_flag == 0 then
              is_track = 1
            end
            update_mltbox_trace_flag(mltbox, mltbox_count, taskid, is_track)
            nx_execute("form_stage_main\\form_task\\form_task_trace", "update_trace_info", taskid, is_track)
            mltbox_count = mltbox_count + 1
          end
        end
      end
    end
  end
end
function update_city_sub_task_tree(select_mark, groupbox, iscompleteflag, roundflag)
  if not nx_is_valid(groupbox) then
    return
  end
  local form = groupbox.ParentForm
  groupbox.Visible = true
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local task_list = {}
  local table_task = taskmgr:GetTaskByType(7, 0)
  local total = table.getn(table_task)
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    if nx_number(line) == nx_number(task_line_city_zx) then
      table.insert(task_list, id)
    end
  end
  local task_count = table.getn(task_list)
  if nx_number(task_count) == nx_number(0) then
    return
  end
  local title_box = clone_control(form, "city_title_box", groupbox.subindex)
  groupbox:Add(title_box)
  title_box.Left = 0
  local aid = title_box.aid
  groupbox.subindex = groupbox.subindex + 1
  local child_name = string.format("%s_%s", nx_string("lbl_city_name"), nx_string(aid))
  local lbl_city_name = title_box:Find(child_name)
  lbl_city_name.Visible = true
  lbl_city_name.Text = nx_widestr(gui.TextManager:GetText("ui_task_city_subline"))
  nx_bind_script(lbl_city_name, nx_current())
  nx_callback(lbl_city_name, "on_click", "on_city_sub_title_click")
  lbl_city_name.select_mark = select_mark
  lbl_city_name.line = target_line
  child_name = string.format("%s_%s", nx_string("lbl_city_title_close"), nx_string(aid))
  local btn_title_close = title_box:Find(child_name)
  child_name = string.format("%s_%s", nx_string("lbl_city_title_open"), nx_string(aid))
  local btn_title_open = title_box:Find(child_name)
  if g_show_city_subtask_line then
    btn_title_open.Visible = true
    btn_title_close.Visible = false
  else
    btn_title_open.Visible = false
    btn_title_close.Visible = true
  end
  if g_show_city_subtask_line then
    local box_city_task = clone_control(form, "box_city_task", groupbox.subindex)
    groupbox:Add(box_city_task)
    box_city_task.Left = 0
    local aid = box_city_task.aid
    groupbox.subindex = groupbox.subindex + 1
    child_name = string.format("%s_%s", nx_string("mltbox_city_task"), nx_string(aid))
    local mltbox = box_city_task:Find(child_name)
    nx_bind_script(mltbox, nx_current())
    nx_callback(mltbox, "on_select_item_change", "on_wy_mltbox_select_item_change")
    mltbox:Clear()
    mltbox.Height = 0
    local mltbox_count = 0
    for i = 1, task_count do
      local taskid = task_list[i]
      local task_title = get_task_title(taskid)
      task_title = nx_widestr("       ") .. nx_widestr(task_title)
      task_title = nx_widestr("<font face=\"font_treeview\" color=\"#ffffff\">") .. nx_widestr(task_title) .. nx_widestr("</font>")
      mltbox:AddHtmlText(nx_widestr(task_title), nx_int(taskid))
      mltbox.Height = mltbox.Height + mltbox.LineHeight
      if nx_number(select_mark) == nx_number(taskid) then
        mltbox:SetHtmlItemSelected(nx_int(mltbox_count), true)
        form.SelectMltbox = mltbox
        form.SelectIndex = mltbox_count
        form.SelectCityNode = mltbox
        form.SelectCityNode.mark = taskid
      end
      local track_flag = 1
      local text_trace_list = nx_execute("form_stage_main\\form_task\\form_task_trace", "get_trace_list_str")
      local table_trace = util_split_string(text_trace_list, ",")
      for i, id in pairs(table_trace) do
        if nx_number(id) == nx_number(taskid) then
          track_flag = 0
          break
        end
      end
      local is_track = 0
      if track_flag == 0 then
        is_track = 1
      end
      update_mltbox_trace_flag(mltbox, mltbox_count, taskid, is_track)
      nx_execute("form_stage_main\\form_task\\form_task_trace", "update_trace_info", taskid, is_track)
      mltbox_count = mltbox_count + 1
    end
    box_city_task.Height = mltbox.Height
  end
end
function update_city_yl_task_tree(select_mark, groupbox, iscompleteflag, roundflag)
  if not nx_is_valid(groupbox) then
    return
  end
  local form = groupbox.ParentForm
  groupbox.Visible = true
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local task_list = {}
  local table_task = taskmgr:GetTaskByType(7, 0)
  local total = table.getn(table_task)
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    if nx_number(line) == nx_number(task_line_city_yl) then
      table.insert(task_list, id)
    end
  end
  local task_count = table.getn(task_list)
  if nx_number(task_count) == nx_number(0) then
    return
  end
  local title_box = clone_control(form, "city_title_box", groupbox.subindex)
  groupbox:Add(title_box)
  title_box.Left = 0
  local aid = title_box.aid
  groupbox.subindex = groupbox.subindex + 1
  local child_name = string.format("%s_%s", nx_string("lbl_city_name"), nx_string(aid))
  local lbl_city_name = title_box:Find(child_name)
  lbl_city_name.Visible = true
  lbl_city_name.Text = nx_widestr(gui.TextManager:GetText("ui_task_city_ylline"))
  nx_bind_script(lbl_city_name, nx_current())
  nx_callback(lbl_city_name, "on_click", "on_city_yl_title_click")
  lbl_city_name.select_mark = select_mark
  lbl_city_name.line = target_line
  child_name = string.format("%s_%s", nx_string("lbl_city_title_close"), nx_string(aid))
  local btn_title_close = title_box:Find(child_name)
  child_name = string.format("%s_%s", nx_string("lbl_city_title_open"), nx_string(aid))
  local btn_title_open = title_box:Find(child_name)
  if g_show_city_yltask_line then
    btn_title_open.Visible = true
    btn_title_close.Visible = false
  else
    btn_title_open.Visible = false
    btn_title_close.Visible = true
  end
  if g_show_city_yltask_line then
    local box_city_task = clone_control(form, "box_city_task", groupbox.subindex)
    groupbox:Add(box_city_task)
    box_city_task.Left = 0
    local aid = box_city_task.aid
    groupbox.subindex = groupbox.subindex + 1
    child_name = string.format("%s_%s", nx_string("mltbox_city_task"), nx_string(aid))
    local mltbox = box_city_task:Find(child_name)
    nx_bind_script(mltbox, nx_current())
    nx_callback(mltbox, "on_select_item_change", "on_wy_mltbox_select_item_change")
    mltbox:Clear()
    mltbox.Height = 0
    local mltbox_count = 0
    for i = 1, task_count do
      local taskid = task_list[i]
      local task_title = get_task_title(taskid)
      task_title = nx_widestr("       ") .. nx_widestr(task_title)
      task_title = nx_widestr("<font face=\"font_treeview\" color=\"#ffffff\">") .. nx_widestr(task_title) .. nx_widestr("</font>")
      mltbox:AddHtmlText(nx_widestr(task_title), nx_int(taskid))
      mltbox.Height = mltbox.Height + mltbox.LineHeight
      if nx_number(select_mark) == nx_number(taskid) then
        mltbox:SetHtmlItemSelected(nx_int(mltbox_count), true)
        form.SelectMltbox = mltbox
        form.SelectIndex = mltbox_count
        form.SelectCityNode = mltbox
        form.SelectCityNode.mark = taskid
      end
      local track_flag = 1
      local text_trace_list = nx_execute("form_stage_main\\form_task\\form_task_trace", "get_trace_list_str")
      local table_trace = util_split_string(text_trace_list, ",")
      for i, id in pairs(table_trace) do
        if nx_number(id) == nx_number(taskid) then
          track_flag = 0
          break
        end
      end
      local is_track = 0
      if track_flag == 0 then
        is_track = 1
      end
      update_mltbox_trace_flag(mltbox, mltbox_count, taskid, is_track)
      nx_execute("form_stage_main\\form_task\\form_task_trace", "update_trace_info", taskid, is_track)
      mltbox_count = mltbox_count + 1
    end
    box_city_task.Height = mltbox.Height
  end
end
function update_wy_drama_task_tree(select_mark, task_id, groupbox, iscompleteflag, roundflag)
  if not nx_is_valid(groupbox) then
    return
  end
  local form = groupbox.ParentForm
  groupbox.Visible = true
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if task_id == nil or task_id == 0 then
    return
  end
  local table_drama = taskmgr:GetWYDramaTaskInfo(task_id)
  if table.getn(table_drama) ~= 3 then
    return
  end
  local line = table_drama[1]
  local drama_name = table_drama[2]
  local chapter = table_drama[3]
  local next_id = table_drama[4]
  local last_id = table_drama[5]
  local chapter_next = chapter
  if nx_int(next_id) ~= nx_int(0) then
    local table_drama_next = taskmgr:GetWYDramaTaskInfo(next_id)
    if table.getn(table_drama_next) ~= 3 then
      return
    end
    chapter_next = table_drama_next[3]
  end
  if g_drama_node[drama_name] == nil then
    return
  end
  local drama_node_desc = gui.TextManager:GetText(drama_name)
  if line == task_line_wy_drama or line == task_line_mzyy_drama or line == task_line_jhjs_drama or line == task_line_xbqzj_drama then
    local title_box = clone_control(form, "wy_drama_title_box", 0)
    groupbox:Add(title_box)
    local aid = title_box.aid
    local child_name = string.format("%s_%s", nx_string("lbl_wy_drama"), nx_string(aid))
    local lbl_wy_drama = title_box:Find(child_name)
    lbl_wy_drama.Visible = true
    lbl_wy_drama.Text = nx_widestr(drama_node_desc)
  end
  for i = 1, chapter do
    local wy_drama_box = clone_control(form, "wy_drama_box", i)
    groupbox:Add(wy_drama_box)
    wy_drama_box.Visible = true
    local aid = wy_drama_box.aid
    local child_name = string.format("%s_%s", nx_string("mltbox_wy"), nx_string(aid))
    local mltbox = wy_drama_box:Find(child_name)
    nx_bind_script(mltbox, nx_current())
    nx_callback(mltbox, "on_select_item_change", "on_wy_mltbox_select_item_change")
    mltbox:Clear()
    local mltbox_count = -1
    local chapter_node_id = g_task_line[nx_number(line)].mark + i * 100
    local chapter_text_id = drama_name .. "_" .. nx_string(i)
    local chapter_image = i
    local chapter_node_desc = gui.TextManager:GetText(chapter_text_id)
    chapter_node_desc = nx_widestr("<font face=\"font_chapter\">") .. nx_widestr(chapter_node_desc) .. nx_widestr("</font>")
    chapter_node_desc = nx_widestr("<img src=\"gui\\language\\ChineseS\\task\\") .. nx_widestr(chapter_image) .. nx_widestr(".png\" data=\"\" />") .. nx_widestr(chapter_node_desc)
    mltbox:AddHtmlText(nx_widestr(chapter_node_desc), nx_int(chapter_node_id))
    mltbox_count = mltbox_count + 1
    mltbox.Height = mltbox.LineHeight * 2
    child_name = string.format("%s_%s", nx_string("wy_task_close"), nx_string(aid))
    local btn_close = wy_drama_box:Find(child_name)
    nx_bind_script(btn_close, nx_current())
    nx_callback(btn_close, "on_click", "on_wy_task_close")
    btn_close.chapter = i
    btn_close.select_mark = select_mark
    btn_close.line = line
    child_name = string.format("%s_%s", nx_string("wy_task_open"), nx_string(aid))
    local btn_open = wy_drama_box:Find(child_name)
    nx_bind_script(btn_open, nx_current())
    nx_callback(btn_open, "on_click", "on_wy_task_open")
    btn_open.chapter = i
    btn_open.select_mark = select_mark
    btn_open.line = line
    local flag = false
    if iscompleteflag == true and i == chapter then
      btn_close.Visible = false
      btn_open.Visible = false
      flag = true
    elseif 0 < is_chapter_show(i, line) then
      flag = true
      btn_close.Visible = true
      btn_open.Visible = false
    else
      btn_close.Visible = false
      btn_open.Visible = true
    end
    if flag then
      local table_task = taskmgr:GetWYDramaTaskList(i, line)
      table.sort(table_task, function(a, b)
        return nx_number(a) < nx_number(b)
      end)
      local task_count = table.getn(table_task)
      for j = 1, task_count do
        local taskid = table_task[j]
        if task_id >= taskid then
          local state = get_task_complete_state(taskid)
          local completed = taskmgr:CompletedByRec(nx_string(taskid))
          local task_title = ""
          if completed == 1 then
            local title_id = "title_" .. taskid
            task_title = gui.TextManager:GetText(title_id)
          else
            task_title = get_task_title(taskid)
          end
          task_title = nx_widestr("       ") .. nx_widestr(task_title)
          task_title = nx_widestr("<font face=\"font_treeview\" color=\"#ffffff\">") .. nx_widestr(task_title) .. nx_widestr("</font>")
          if completed == 1 or task_id > taskid then
            task_title = nx_string(task_title) .. "<img src=\"gui\\language\\ChineseS\\task\\icon_complete.png\" data=\"\"/>"
            mltbox:AddHtmlText(nx_widestr(task_title), nx_int(chapter_node_id))
          else
            mltbox:AddHtmlText(nx_widestr(task_title), nx_int(taskid))
          end
          mltbox_count = mltbox_count + 1
          mltbox.Height = mltbox.Height + mltbox.LineHeight
          if nx_number(select_mark) == nx_number(taskid) then
            mltbox:SetHtmlItemSelected(nx_int(mltbox_count), true)
            form.SelectMltbox = mltbox
            form.SelectIndex = mltbox_count
          end
        end
      end
    end
    wy_drama_box.Height = mltbox.Height
  end
  groupbox.IsEditMode = false
  groupbox:ResetChildrenYPos()
  groupbox.VScrollBar.Value = form.wy_drama_box_value
end
function get_task_title(task_id)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
  if task_row < 0 then
    return ""
  end
  local state = get_task_complete_state(task_id)
  local title_id = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_title)
  local task_title = gui.TextManager:GetText(title_id)
  if nx_number(state) == 2 then
    task_title = nx_widestr(task_title)
  elseif nx_number(state) == 1 then
    task_title = nx_widestr(task_title) .. nx_widestr("(") .. nx_widestr(util_text("ui_faild")) .. nx_widestr(")")
  end
  return task_title
end
function update_jianghu_task_tree(form, task_id, task_line, select_mark, repute_level)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
  if task_row < 0 then
    return
  end
  local gui = nx_value("gui")
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local repute_module = nx_value("ReputeModule")
  if not nx_is_valid(repute_module) then
    return
  end
  local task_tree = form.tree_task
  if not nx_is_valid(task_tree) then
    return
  end
  if nx_number(task_line) == nx_number(task_line_shimen_new) then
    task_line = task_line_wuxue
  end
  if g_task_line[nx_number(task_line)] == nil then
    return
  end
  local mark = 0
  if nx_number(task_line) == task_line_clone then
    mark = get_clone_config_info(task_id, 0)
  else
    mark = g_task_line[nx_number(task_line)].mark
  end
  if nx_number(mark) == 0 and nx_string(mark) == "" then
    return
  end
  local root_node = form.tree_task.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  local main_node = root_node:FindNodeByMark(nx_int(mark))
  if not nx_is_valid(main_node) then
    desc = g_task_line[nx_number(task_line)].ui
    local main_root_desc = g_task_line[nx_number(task_line)].ui
    if nx_int(task_line) == nx_int(task_line_clone) then
      main_root_desc = get_clone_config_info(task_id, 1)
    end
    if main_root_desc == "" then
      return
    end
    local main_root_desc_text = nx_widestr(gui.TextManager:GetText(main_root_desc))
    if nx_int(task_line) == nx_int(task_line_clone) then
      main_root_desc_text = nx_widestr(main_root_desc_text) .. nx_widestr(gui.TextManager:GetText("ui_task_fb"))
    end
    main_node = root_node:CreateNode(nx_widestr(main_root_desc_text))
    main_node.Mark = nx_int(mark)
    main_node.Font = "font_treeview"
    main_node.ForeColor = "255,255,153,0"
    main_node.ItemHeight = 30
    main_node.NodeBackImage = "gui\\common\\treeview\\tree_1_out.png"
    main_node.NodeFocusImage = "gui\\common\\treeview\\tree_1_on.png"
    main_node.NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png"
    main_node.ExpandCloseOffsetX = 0
    main_node.ExpandCloseOffsetY = 6
    main_node.TextOffsetX = 59
    main_node.TextOffsetY = 7
    main_node.NodeOffsetY = -5
  end
  local task_node = main_node:FindNodeByMark(nx_int(task_id))
  local state = get_task_complete_state(task_id)
  local title_id = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_title)
  local task_title = gui.TextManager:GetText(title_id)
  if nx_number(state) == 2 then
    task_title = nx_widestr(task_title) .. nx_widestr("(") .. nx_widestr(util_text("ui_cansubmit")) .. nx_widestr(")")
  elseif nx_number(state) == 1 then
    task_title = nx_widestr(task_title) .. nx_widestr("(") .. nx_widestr(util_text("ui_faild")) .. nx_widestr(")")
  end
  if not nx_is_valid(task_node) then
    task_node = main_node:CreateNode(nx_widestr(task_title))
    task_node.Mark = nx_int(task_id)
    task_node.ImageIndex = 0
    task_node.Font = "font_treeview"
    task_node.NodeImageOffsetX = 30
    task_node.TextOffsetX = 30
    task_node.TextOffsetY = 2
    task_node.NodeBackImage = "gui\\common\\treeview\\tree_2_out.png"
    task_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_out.png"
    task_node.NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png"
  else
    task_node.Text = nx_widestr(task_title)
  end
  if task_line == task_line_side or task_line == task_line_enyuan then
    local task_rpt_value = taskmgr:GetAcceptTaskProp(nx_string(task_id), "RepLimit")
    local task_level = repute_module:GetReputeLevel(nx_int(task_rpt_value))
    if nx_int(repute_level) - nx_int(task_level) >= 2 then
      task_node.ForeColor = "255,130,130,130"
    elseif 1 == nx_int(repute_level) - nx_int(task_level) then
      task_node.ForeColor = "255,220,170,90"
    end
  end
  if nx_number(select_mark) == nx_number(task_id) then
    task_tree.SelectNode = task_node
  end
  root_node:ExpandAll()
end
function update_guide_task_tree(form, task_id, select_mark)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local task_tree = form.tree_guide_task
  if not nx_is_valid(task_tree) then
    return
  end
  local main_mark = CAN_ACCEPT_GUIDE_MARK
  local root_node = form.tree_guide_task.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  local main_node = root_node:FindNodeByMark(nx_int(main_mark))
  if not nx_is_valid(main_node) then
    local main_root_desc = g_task_line[9].ui
    if main_root_desc == "" then
      return
    end
    local main_root_desc_text = nx_widestr(gui.TextManager:GetText(main_root_desc))
    main_node = root_node:CreateNode(nx_widestr(main_root_desc_text))
    main_node.Mark = nx_int(main_mark)
    main_node.Font = "font_treeview"
    main_node.ForeColor = "255,255,153,0"
    main_node.ItemHeight = 30
    main_node.NodeBackImage = "gui\\common\\treeview\\tree_1_out.png"
    main_node.NodeFocusImage = "gui\\common\\treeview\\tree_1_on.png"
    main_node.NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png"
    main_node.ExpandCloseOffsetX = 0
    main_node.ExpandCloseOffsetY = 6
    main_node.TextOffsetX = 80
    main_node.TextOffsetY = 7
    main_node.NodeOffsetY = -5
  end
  local task_node = main_node:FindNodeByMark(nx_int(task_id))
  local state = taskmgr:CompletedByRec(nx_string(task_id))
  local title_id = taskmgr:GetGuideTaskProp(nx_string(task_id), "title_id")
  local task_title = gui.TextManager:GetText(title_id)
  local pre_task = taskmgr:GetGuideTaskProp(nx_string(task_id), "PreTask")
  if nx_number(state) == 1 then
    task_title = nx_widestr(task_title) .. nx_widestr("(") .. nx_widestr(util_text("ui_complete")) .. nx_widestr(")")
  end
  local task_mark = CAN_ACCEPT_GUIDE_MARK + task_id
  if not nx_is_valid(task_node) then
    task_node = main_node:CreateNode(nx_widestr(task_title))
    task_node.Mark = nx_int(task_mark)
    task_node.ImageIndex = 0
    task_node.Font = "font_treeview"
    task_node.NodeImageOffsetX = 30
    task_node.TextOffsetX = 30
    task_node.TextOffsetY = 2
    task_node.NodeBackImage = "gui\\common\\treeview\\tree_2_out.png"
    task_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_out.png"
    task_node.NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png"
  end
  if nx_string(pre_task) ~= "" then
    local pre_task_state = taskmgr:CompletedByRec(nx_string(pre_task))
    if nx_number(pre_task_state) == 1 then
      task_node.ForeColor = "255,255,255,255"
    else
      task_title = nx_widestr(task_title) .. nx_widestr("(") .. nx_widestr(util_text("ui_uncomplete")) .. nx_widestr(")")
    end
  end
  task_node.Text = nx_widestr(task_title)
  if nx_number(select_mark) == nx_number(task_mark) then
    task_tree.SelectNode = task_node
  end
  root_node:ExpandAll()
end
function refresh_zhixian_accept(form, scene_id, select_mark)
  local gui = nx_value("gui")
  local tree_zhixian_accept = form.tree_zhixian_accept
  if not nx_is_valid(tree_zhixian_accept) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local root_node = tree_zhixian_accept.RootNode
  if not nx_is_valid(root_node) then
    root_node = tree_zhixian_accept:CreateRootNode(nx_widestr(util_text("ui_jianghu_fengyun")))
    root_node.Mark = -1
  end
  clear_tree_view(form.tree_zhixian_accept)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local table_task = {}
  if nx_int(scene_id) ~= -1 then
    table_task = taskmgr:GetAcceptTaskInfo(nx_int(scene_id))
  end
  local total = table.getn(table_task)
  if nx_number(total) <= nx_number(0) then
    tree_zhixian_accept.Visible = false
    form.groupbox_scene.Visible = false
  else
    tree_zhixian_accept.Visible = true
    form.groupbox_scene.Visible = true
  end
  local rpt_level = 1
  local rows = client_player:FindRecordRow("Repute_Record", 0, nx_string("repute_jianghu"), 0)
  if 0 <= rows then
    rpt_level = client_player:QueryRecord("Repute_Record", rows, 2)
  end
  for i = 1, total, 2 do
    local task_id = table_task[i]
    local area_id = table_task[i + 1]
    add_tree_zhixian_accept(form, task_id, area_id, select_mark, rpt_level)
  end
end
function add_tree_zhixian_accept(form, task_id, area_id, select_mark, repute_level)
  local gui = nx_value("gui")
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local repute_module = nx_value("ReputeModule")
  if not nx_is_valid(repute_module) then
    return
  end
  local tree_zhixian_accept = form.tree_zhixian_accept
  if not nx_is_valid(tree_zhixian_accept) then
    return
  end
  local main_mark = CAN_ACCEPT_AREA_MARK + area_id
  local root_node = tree_zhixian_accept.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  local main_node = root_node:FindNodeByMark(nx_int(main_mark))
  if not nx_is_valid(main_node) then
    local table_area = taskmgr:GetTaskAreaInfo(area_id)
    if table.getn(table_area) ~= 2 then
      return
    end
    local scene_id = table_area[1]
    local area_name = table_area[2]
    local scene_name_text = gui.TextManager:GetText("ui_scene_" .. nx_string(scene_id))
    local area_name_text = gui.TextManager:GetText(area_name)
    local main_root_desc_text = nx_widestr(scene_name_text) .. nx_widestr("-") .. nx_widestr(area_name_text)
    main_node = root_node:CreateNode(nx_widestr(main_root_desc_text))
    main_node.Mark = nx_int(main_mark)
    main_node.Font = "font_treeview"
    main_node.ShadowColor = "0,200,0,0"
    main_node.ForeColor = "255,255,255,255"
    main_node.DrawMode = "FitWindow"
    main_node.ItemHeight = 24
    main_node.NodeBackImage = "gui\\common\\treeview\\tree_2_out.png"
    main_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_out.png"
    main_node.NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png"
    main_node.ExpandCloseOffsetX = -5
    main_node.ExpandCloseOffsetY = 3
    main_node.TextOffsetX = 30
    main_node.TextOffsetY = 2
    main_node.NodeOffsetY = -2
  end
  local task_mark = CAN_ACCEPT_ZHIXIAN_MARK + task_id
  local task_node = main_node:FindNodeByMark(task_mark)
  local title_id = taskmgr:GetAcceptTaskProp(nx_string(task_id), "Title")
  local task_title = gui.TextManager:GetText(title_id)
  local line = taskmgr:GetAcceptTaskProp(nx_string(task_id), "Line")
  if nx_number(line) == nx_number(task_line_enyuan) then
    task_title = nx_widestr(task_title) .. nx_widestr("-") .. nx_widestr(util_text("ui_task_enyuan"))
  end
  if not nx_is_valid(task_node) then
    task_node = main_node:CreateNode(nx_widestr(task_title))
    task_node.Mark = nx_int(task_mark)
    task_node.Font = "font_treeview"
    task_node.ShadowColor = "0,200,0,0"
    task_node.TextOffsetX = 30
    task_node.TextOffsetY = 2
    task_node.NodeBackImage = "gui\\common\\treeview\\tree_3_out.png"
    task_node.NodeFocusImage = "gui\\common\\treeview\\tree_3_out.png"
    task_node.NodeSelectImage = "gui\\common\\treeview\\tree_3_on.png"
  end
  if nx_int(line) == nx_int(task_line_side) or nx_int(line) == nx_int(task_line_enyuan) then
    local task_rpt_value = taskmgr:GetAcceptTaskProp(nx_string(task_id), "RepLimit")
    local task_level = repute_module:GetReputeLevel(nx_int(task_rpt_value))
    if nx_int(repute_level) - nx_int(task_level) >= 2 then
      task_node.ForeColor = "255,130,130,130"
    elseif 1 == nx_int(repute_level) - nx_int(task_level) then
      task_node.ForeColor = "255,141,198,63"
    end
  end
  if nx_number(select_mark) == nx_number(task_mark) then
    tree_zhixian_accept.SelectNode = task_node
  end
  root_node:ExpandAll()
end
function refresh_trace_flag(form, index)
  if nx_number(index) == nx_number(3) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local text_trace_list = nx_execute("form_stage_main\\form_task\\form_task_trace", "get_trace_list_str")
  local table_trace = util_split_string(text_trace_list, ",")
  for i, task_id in pairs(table_trace) do
    local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
    if 0 <= task_row then
      local line = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_line)
      if nx_number(index) == nx_number(1) then
        if nx_number(line) == nx_number(1) then
          local item_index = form.mltbox_zhuxian:GetItemIndexByKey(nx_int(task_id))
          update_mltbox_trace_flag(form.mltbox_zhuxian, item_index, task_id, 1)
        elseif nx_number(line) == nx_number(4) then
          local item_index = form.mltbox_menpai:GetItemIndexByKey(nx_int(task_id))
          update_mltbox_trace_flag(form.mltbox_menpai, item_index, task_id, 1)
        end
      elseif nx_number(index) == nx_number(2) and nx_number(line) ~= nx_number(4) or nx_number(line) ~= nx_number(1) then
        local node = get_task_node(form, task_id)
        set_trace_flag(node, 1)
      end
    end
  end
end
function get_task_node(form, task_id)
  local table_node = form.tree_task:GetAllNodeList()
  for i, node in pairs(table_node) do
    if nx_number(node.Mark) == nx_number(task_id) then
      return node
    end
  end
end
function set_trace_flag(node, cmd)
  if nx_is_valid(node) then
    if nx_number(cmd) == 1 then
      node.ImageIndex = 1
    elseif nx_number(cmd) == 0 then
      node.ImageIndex = 0
    end
  end
end
function update_mltbox_trace_flag(mltbox, index, task_id, cmd)
  if not nx_is_valid(mltbox) then
    return
  end
  local text_trace = get_task_title(task_id)
  text_trace = nx_widestr("<font face=\"font_treeview\" color=\"#ffffff\">") .. nx_widestr(text_trace) .. nx_widestr("</font>")
  if nx_number(cmd) == nx_number(0) then
    text_trace = nx_widestr("       ") .. nx_widestr(text_trace)
  elseif nx_number(cmd) == nx_number(1) then
    text_trace = nx_widestr("     ") .. nx_widestr("<img src=\"gui\\special\\task\\zhuizong3.png\" data=\"\" />") .. nx_widestr(text_trace)
  end
  local state = get_task_complete_state(task_id)
  if state == 2 then
    text_trace = nx_widestr(text_trace) .. nx_widestr(util_text("ui_spacecansubmit"))
  end
  mltbox:ChangeHtmlText(nx_int(index), nx_widestr(text_trace))
end
function show_detail_info(form, mark)
  form.groupscrollbox_accept_info.Visible = false
  form.mltbox_drama.Visible = false
  form.groupscrollbox_task.Visible = false
  form.groupscrollbox_guide_task.Visible = false
  form.groupscrollbox_puzzle_info.Visible = false
  form.groupbox_wy_drama_info.Visible = false
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local flag = check_drama_info(mark)
  if flag == 1 or flag == 0 then
    return
  end
  if flag == 2 then
    show_drama_detail_info(form, mark)
  elseif flag == 3 or flag == 4 or flag == 7 then
    show_task_detail_info(form, mark)
  elseif flag == 9 then
    show_line_next_info(form, mark)
  elseif flag == 5 then
    show_puzzle_task_info(form, mark)
  elseif flag == 6 then
    show_wywl_chapter_info(form, mark)
  end
  if nx_int(mark / 100000) == nx_int(CAN_ACCEPT_AREA_MARK / 100000) then
    form.lbl_accept_bg_line_1.Visible = false
    form.lbl_accept_bg_line_0.Visible = false
    form.mltbox_next_info.Visible = false
    form.lbl_title_name_accept.Visible = false
    form.mltbox_desc_info.Visible = false
    form.lbl_next_title.Visible = false
    form.mltbox_enyuan_tips.Visible = false
    form.lbl_accept_prize_title.Visible = false
    form.imagegrid_prize_sl.Visible = false
  end
  form.PageMark = mark
  taskmgr.PageMark = mark
end
function show_task_detail_info(form, task_id)
  form.groupscrollbox_task.Visible = true
  form.lbl_bg_line_0.Visible = false
  form.lbl_bg_line_1.Visible = false
  form.lbl_bg_line_2.Visible = false
  form.lbl_bg_line_3.Visible = false
  form.lbl_bg_line_4.Visible = false
  form.lbl_bg_line_5.Visible = false
  form.btn_buy_task.Visible = false
  form.cbtn_buy_tips.Visible = false
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
  if task_row < 0 then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  if 0 >= nx_number(task_id) then
    return
  end
  local line = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_line)
  if nx_number(line) == nx_number(task_line_shimen_new) then
    line = task_line_wuxue
  end
  if g_task_line[nx_number(line)] == nil then
    return
  end
  local state = get_task_complete_state(task_id)
  local title = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_title)
  local title_text = gui.TextManager:GetText(title)
  if nx_int(line) == nx_int(task_line_adventure) then
    local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
    if task_row < 0 then
      return
    end
    local adventure_plot = 0
    local plot_title = taskmgr:GetPlotProp(nx_string(adventure_plot), "PlotTitle")
    local plot_text = gui.TextManager:GetText(plot_title)
    if nx_string(plot_title) ~= "" then
      title_text = nx_widestr(title_text) .. nx_widestr("(") .. nx_widestr(plot_text) .. nx_widestr(")")
    end
  end
  form.lbl_title_name.Text = nx_widestr(title_text)
  local desc_short = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_target)
  local desc_short_text = gui.TextManager:GetText(desc_short)
  form.mltbox_desc_short.HtmlText = nx_widestr(desc_short_text)
  local table_aim_control = {
    form.mltbox_aim_1,
    form.mltbox_aim_2,
    form.mltbox_aim_3,
    form.mltbox_aim_4,
    form.mltbox_aim_5,
    form.mltbox_aim_6,
    form.mltbox_aim_7,
    form.mltbox_aim_8,
    form.mltbox_aim_9,
    form.mltbox_aim_10
  }
  for box_index = 1, table.getn(table_aim_control) do
    table_aim_control[box_index]:Clear()
  end
  local is_show_title_trace = false
  if 0 <= nx_number(state) then
    local str_schedule = taskmgr:GetTaskScheduleInfo(nx_int(task_id), 0)
    local table_schdule = util_split_string(str_schedule, ";")
    for i, schdule in pairs(table_schdule) do
      if i <= table.getn(table_aim_control) then
        local table_para = util_split_string(schdule, "|")
        if table.getn(table_para) == 6 then
          local desc_format = nx_widestr("    ") .. nx_widestr(util_text(table_para[1])) .. nx_widestr("(") .. nx_widestr(table_para[2]) .. nx_widestr("/") .. nx_widestr(table_para[3]) .. nx_widestr(")")
          if 0 < nx_number(table_para[6]) then
            local over_prize_text = gui.TextManager:GetText("ui_over_prize")
            desc_format = nx_widestr(desc_format) .. nx_widestr("[") .. nx_widestr(over_prize_text) .. nx_widestr("(") .. nx_widestr(table_para[5]) .. nx_widestr("/") .. nx_widestr(table_para[6]) .. nx_widestr(")]")
          end
          table_aim_control[i].TextColor = "255,130,101,74"
          table_aim_control[i].Font = "font_sns_list"
          table_aim_control[i]:AddHtmlText(nx_widestr(desc_format), nx_int(-1))
          is_show_title_trace = true
        end
      end
    end
  end
  if is_show_title_trace then
    form.lbl_title_trace.Visible = true
  else
    form.lbl_title_trace.Visible = false
  end
  local npc_desc = taskmgr:GetAsNpcDesc(nx_int(task_id))
  form.mltbox_submit_desc.HtmlText = nx_widestr(npc_desc)
  form.mltbox_limit:Clear()
  local canLimit, table_limit_desc = task_limit_info(task_id, 1)
  if table_limit_desc ~= nil then
    for i, desc_limit in pairs(table_limit_desc) do
      form.mltbox_limit:AddHtmlText(nx_widestr(desc_limit), nx_int(-1))
    end
  end
  local desc_full_id = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_context)
  local desc_full = gui.TextManager:GetText(desc_full_id)
  local ex_para_flag = string.find(nx_string(desc_full), "@0:")
  if ex_para_flag ~= nil then
    local name = client_player:QueryProp("Name")
    gui.TextManager:Format_SetIDName(nx_string(desc_full_id))
    gui.TextManager:Format_AddParam(nx_widestr(name))
    desc_full = gui.TextManager:Format_GetText()
  end
  form.mltbox_desc_full.HtmlText = nx_widestr(desc_full)
  if taskmgr.ThirdTaskChecked == 1 then
    local buy_info = taskmgr:GetBuyTaskMoney(nx_int(task_id))
    if table.getn(buy_info) == 2 then
      local valid = buy_info[1]
      local money_num = buy_info[2]
      if nx_int(valid) == nx_int(1) then
        form.btn_buy_task.Visible = true
        if nx_int(money_num) > nx_int(0) then
          form.btn_buy_task.Enabled = true
        else
          form.btn_buy_task.Enabled = false
        end
      else
        form.btn_buy_task.Visible = false
      end
    end
  end
  show_task_prize(form, task_id)
  show_reputation_limit(form, task_id)
  set_controls_position(form)
  show_lbl_task_prize_text(form, line)
  local can_giveup = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_can_giveup)
  form.btn_giveup.Enabled = true
end
function show_lbl_task_prize_text(form, line)
  if form.lbl_title_prize.Visible == false then
    return
  end
  if nx_int(line) == nx_int(task_line_main) or nx_int(line) == nx_int(task_line_menpai) then
    form.lbl_title_prize.Text = nx_widestr(util_text("ui_task_buzhou_prize"))
  elseif nx_int(line) == nx_int(task_line_side) then
    form.lbl_title_prize.Text = nx_widestr(util_text("ui_task_renwu_prize"))
  elseif nx_int(line) == nx_int(task_line_enyuan) then
    form.lbl_title_prize.Text = nx_widestr(util_text("ui_task_enyuan_prize"))
  end
end
function show_drama_detail_info(form, mark)
  form.mltbox_drama.Visible = true
  form.mltbox_drama:Clear()
  local drama_id = nx_int(mark / 10000) * 10000
  local drama_name = ""
  for name, content in pairs(g_drama_node) do
    if content.mark == drama_id then
      drama_name = name
      break
    end
  end
  local chapter = nx_int(math.fmod(mark, 10000) / 100)
  local round = math.fmod(mark, 100)
  if drama_name == "" then
    return
  end
  local text = get_drama_text(drama_name, chapter, round)
  if nx_string(text) == "" then
    return
  end
  form.mltbox_drama:AddHtmlText(nx_widestr(text), nx_int(mark))
end
function set_controls_position(form)
  local lbl_line_num = 1
  form.groupscrollbox_task.IsEditMode = true
  form.btn_buy_task.Top = 16
  form.lbl_title_name.Top = 16
  form.lbl_bg_line_0.Visible = true
  form.lbl_bg_line_0.Top = 30
  local total_height = form.lbl_title_name.Height + CONFIG_LINE_HEIGHT + CONFIG_FIRST_LINE_HEIGHT
  form.mltbox_desc_full.Top = total_height - 10
  height = form.mltbox_desc_full:GetContentHeight()
  form.mltbox_desc_full.Height = height
  total_height = total_height + height + CONFIG_LINE_HEIGHT
  if form.groupbox_rpt_limit.Visible == true then
    form.groupbox_rpt_limit.Top = total_height
    total_height = total_height + form.groupbox_rpt_limit.Height + CONFIG_LINE_HEIGHT
  end
  form.lbl_title_dest.Top = total_height
  total_height = total_height + form.lbl_title_dest.Height + CONFIG_LINE_HEIGHT
  total_height = set_bg_line_position(form, lbl_line_num, total_height)
  lbl_line_num = lbl_line_num + 1
  form.mltbox_desc_short.Top = total_height
  local height = form.mltbox_desc_short:GetContentHeight()
  form.mltbox_desc_short.Height = height
  total_height = total_height + height + CONFIG_LINE_HEIGHT
  if form.lbl_title_trace.Visible == true then
    form.lbl_title_trace.Top = total_height
    total_height = total_height + form.lbl_title_trace.Height + CONFIG_LINE_HEIGHT
    total_height = set_bg_line_position(form, lbl_line_num, total_height)
    lbl_line_num = lbl_line_num + 1
  end
  form.mltbox_aim_1.Top = total_height
  height = form.mltbox_aim_1:GetContentHeight()
  if height == 0 then
    form.mltbox_aim_1.Visible = false
  else
    form.mltbox_aim_1.Visible = true
    form.mltbox_aim_1.Height = height
    total_height = total_height + height + 5
  end
  form.mltbox_aim_2.Top = total_height
  height = form.mltbox_aim_2:GetContentHeight()
  if height == 0 then
    form.mltbox_aim_2.Visible = false
  else
    form.mltbox_aim_2.Visible = true
    form.mltbox_aim_2.Height = height
    total_height = total_height + height + 5
  end
  form.mltbox_aim_3.Top = total_height
  height = form.mltbox_aim_3:GetContentHeight()
  if height == 0 then
    form.mltbox_aim_3.Visible = false
  else
    form.mltbox_aim_3.Visible = true
    form.mltbox_aim_3.Height = height
    total_height = total_height + height + 5
  end
  form.mltbox_aim_4.Top = total_height
  height = form.mltbox_aim_4:GetContentHeight()
  if height == 0 then
    form.mltbox_aim_4.Visible = false
  else
    form.mltbox_aim_4.Visible = true
    form.mltbox_aim_4.Height = height
    total_height = total_height + height + 5
  end
  form.mltbox_aim_5.Top = total_height
  height = form.mltbox_aim_5:GetContentHeight()
  if height == 0 then
    form.mltbox_aim_5.Visible = false
  else
    form.mltbox_aim_5.Visible = true
    form.mltbox_aim_5.Height = height
    total_height = total_height + height + 5
  end
  form.mltbox_aim_6.Top = total_height
  height = form.mltbox_aim_6:GetContentHeight()
  if height == 0 then
    form.mltbox_aim_6.Visible = false
  else
    form.mltbox_aim_6.Visible = true
    form.mltbox_aim_6.Height = height
    total_height = total_height + height + 5
  end
  form.mltbox_aim_7.Top = total_height
  height = form.mltbox_aim_7:GetContentHeight()
  if height == 0 then
    form.mltbox_aim_7.Visible = false
  else
    form.mltbox_aim_7.Visible = true
    form.mltbox_aim_7.Height = height
    total_height = total_height + height + 5
  end
  form.mltbox_aim_8.Top = total_height
  height = form.mltbox_aim_8:GetContentHeight()
  if height == 0 then
    form.mltbox_aim_8.Visible = false
  else
    form.mltbox_aim_8.Visible = true
    form.mltbox_aim_8.Height = height
    total_height = total_height + height + 5
  end
  form.mltbox_aim_9.Top = total_height
  height = form.mltbox_aim_9:GetContentHeight()
  if height == 0 then
    form.mltbox_aim_9.Visible = false
  else
    form.mltbox_aim_9.Visible = true
    form.mltbox_aim_9.Height = height
    total_height = total_height + height + 5
  end
  form.mltbox_aim_10.Top = total_height
  height = form.mltbox_aim_10:GetContentHeight()
  if height == 0 then
    form.mltbox_aim_10.Visible = false
  else
    form.mltbox_aim_10.Visible = true
  end
  form.mltbox_aim_10.Height = height
  total_height = total_height + height + CONFIG_LINE_HEIGHT
  form.mltbox_submit_desc.Top = total_height
  height = form.mltbox_submit_desc:GetContentHeight()
  form.mltbox_submit_desc.Height = height
  total_height = total_height + height + CONFIG_LINE_HEIGHT
  form.mltbox_limit.Top = total_height
  height = form.mltbox_limit:GetContentHeight()
  form.mltbox_limit.Height = height
  total_height = total_height + height + CONFIG_LINE_HEIGHT
  if form.lbl_title_prize.Visible == true then
    form.lbl_title_prize.Top = total_height
    total_height = total_height + form.lbl_title_prize.Height + CONFIG_LINE_HEIGHT
    total_height = set_bg_line_position(form, lbl_line_num, total_height)
    lbl_line_num = lbl_line_num + 1
  end
  if form.groupbox_prize_money.Visible == true then
    form.groupbox_prize_money.Top = total_height
    total_height = total_height + form.groupbox_prize_money.Height
  end
  if form.groupbox_prize_base.Visible == true then
    form.groupbox_prize_base.Top = total_height
    total_height = total_height + form.groupbox_prize_base.Height + CONFIG_LINE_HEIGHT
  end
  if form.groupbox_prize_money_ex.Visible == true then
    form.groupbox_prize_money_ex.Top = total_height
    total_height = total_height + form.groupbox_prize_money_ex.Height + CONFIG_LINE_HEIGHT
  end
  if form.groupbox_prize_ex.Visible == true then
    form.groupbox_prize_ex.Top = total_height
    total_height = total_height + form.groupbox_prize_ex.Height + CONFIG_LINE_HEIGHT
  end
  if form.groupbox_prize_overfulfill.Visible == true then
    form.groupbox_prize_overfulfill.Top = total_height
    total_height = total_height + form.groupbox_prize_overfulfill.Height + CONFIG_LINE_HEIGHT
  end
  form.groupscrollbox_task.IsEditMode = false
  form.groupscrollbox_task.HasVScroll = true
  form.groupscrollbox_task.VScrollBar.Value = 0
end
function set_bg_line_position(form, number, top)
  local total_height = top
  local lbl_line_table = {
    form.lbl_bg_line_1,
    form.lbl_bg_line_2,
    form.lbl_bg_line_3,
    form.lbl_bg_line_4,
    form.lbl_bg_line_5
  }
  if lbl_line_table[number] ~= nil then
    lbl_line_table[number].Visible = true
    lbl_line_table[number].Top = top - CONFIG_LINE_HEIGHT - 13
    total_height = lbl_line_table[number].Top + lbl_line_table[number].Height + 10
  end
  return total_height
end
function show_line_next_info(form, mark)
  form.groupscrollbox_accept_info.Visible = true
  form.lbl_accept_bg_line_1.Visible = false
  form.lbl_accept_bg_line_1.Visible = true
  form.lbl_accept_bg_line_0.Visible = true
  form.mltbox_next_info.Visible = true
  form.lbl_title_name_accept.Visible = true
  form.mltbox_desc_info.Visible = true
  form.lbl_next_title.Visible = true
  form.mltbox_enyuan_tips.Visible = true
  form.lbl_accept_prize_title.Visible = true
  form.imagegrid_prize_sl.Visible = true
  form.lbl_accept_prize_title.Visible = false
  form.imagegrid_prize_sl.Visible = false
  form.lbl_next_title.Top = 136
  form.mltbox_next_info:Clear()
  form.mltbox_desc_info:Clear()
  local drama_flag = nx_int((mark - CAN_ACCEPT_MARK) / 100000)
  if nx_number(drama_flag) == nx_number(1) then
    show_can_accept_drama(form, mark, drama_flag)
  elseif nx_number(drama_flag) == nx_number(5) then
    show_can_accept_zhixian(form, mark, drama_flag)
  elseif nx_number(drama_flag) == nx_number(9) then
    show_guide_task(form, mark, drama_flag)
  end
end
function show_can_accept_drama(form, mark, drama_flag)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local next_info = ""
  local next_info_text = ""
  local task_title = ""
  local task_desc_info = ""
  local task_id = mark % CAN_ACCEPT_DRAMA_MARK
  local task_accept_npc = ""
  local scene_id = ""
  local scene_name = ""
  form.mltbox_enyuan_tips.Visible = false
  task_title = taskmgr:GetAcceptMainProp(nx_string(task_id), "Title")
  task_desc_info = taskmgr:GetAcceptMainProp(nx_string(task_id), "AcceptDialog")
  task_accept_npc = taskmgr:GetAcceptMainProp(nx_string(task_id), "AcceptNpc")
  scene_id = taskmgr:GetAcceptMainProp(nx_string(task_id), "Scene")
  scene_name = get_scene_name(nx_string(scene_id))
  if "" ~= task_title then
    form.lbl_title_name_accept.Text = nx_widestr(util_text(task_title))
    form.mltbox_desc_info.HtmlText = nx_widestr(util_text(task_desc_info))
  end
  next_info = nx_widestr("<a href=\"findnpc_new,") .. nx_widestr(scene_name) .. nx_widestr(",") .. nx_widestr(task_accept_npc) .. nx_widestr(",") .. nx_widestr("\" style=\"HLStype1\">") .. nx_widestr(util_text(task_accept_npc)) .. nx_widestr("</a>")
  form.lbl_next_title.Text = nx_widestr(util_text("ui_can_accept_npc"))
  next_info_text = nx_widestr(" ") .. nx_widestr(next_info)
  form.mltbox_next_info.HtmlText = nx_widestr(next_info_text)
  set_next_line_info_position(form, drama_flag)
end
function show_can_accept_zhixian(form, mark, drama_flag)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local next_info = ""
  local next_info_text = ""
  local task_title = ""
  local task_desc_info = ""
  local task_id = mark % CAN_ACCEPT_ZHIXIAN_MARK
  local line = taskmgr:GetAcceptTaskProp(nx_string(task_id), "Line")
  if nx_number(line) == nx_number(task_line_enyuan) then
    form.mltbox_enyuan_tips.HtmlText = nx_widestr(util_text("ui_task_enyuan_tips"))
    form.mltbox_enyuan_tips.Visible = true
  else
    form.mltbox_enyuan_tips.Visible = false
  end
  local accept_npc = taskmgr:GetAcceptTaskProp(nx_string(task_id), "AcceptNpc")
  local scene_id = taskmgr:GetAcceptTaskProp(nx_string(task_id), "Scene")
  local scene_name = get_scene_name(nx_string(scene_id))
  task_title = taskmgr:GetAcceptTaskProp(nx_string(task_id), "Title")
  task_desc_info = taskmgr:GetAcceptTaskProp(nx_string(task_id), "AcceptDialog")
  if "" ~= task_title then
    form.lbl_title_name_accept.Text = nx_widestr(util_text(task_title))
    form.mltbox_desc_info.HtmlText = nx_widestr(util_text(task_desc_info))
  end
  next_info = nx_widestr("<a href=\"findnpc_new,") .. nx_widestr(scene_name) .. nx_widestr(",") .. nx_widestr(accept_npc) .. nx_widestr(",") .. nx_widestr("\" style=\"HLStype1\">") .. nx_widestr(util_text(accept_npc)) .. nx_widestr("</a>")
  form.lbl_next_title.Text = nx_widestr(util_text("ui_can_accept_npc"))
  next_info_text = nx_widestr(" ") .. nx_widestr(next_info)
  form.mltbox_next_info.HtmlText = nx_widestr(next_info_text)
  form.imagegrid_prize_sl:Clear()
  local prize_table = taskmgr:GetCanAcceptTaskPrize(nx_int(task_id))
  local flag = taskmgr:GetAcceptTaskProp(nx_string(task_id), "flag")
  local index_base = 0
  if prize_table ~= nil and 0 < table.getn(prize_table) and table.getn(prize_table) % 2 == 0 then
    local has_prize = false
    for i = 1, table.getn(prize_table), 2 do
      local item_id = prize_table[i]
      local num = prize_table[i + 1]
      if nx_int(num) > nx_int(0) then
        local photo = get_icon(0, nx_string(item_id))
        local flag_add = form.imagegrid_prize_sl:AddItem(index_base, nx_string(photo), nx_widestr(item_id), nx_int(num), 0)
        if flag_add then
          index_base = index_base + 1
        end
        has_prize = true
      end
    end
    if has_prize == true then
      form.lbl_accept_prize_title.Visible = true
      form.imagegrid_prize_sl.Visible = true
    end
    if flag == "1" then
      form.lbl_accept_prize_title.Text = nx_widestr(util_text("ui_task_prize_choose"))
    else
      form.lbl_accept_prize_title.Text = nx_widestr(util_text("ui_task_prize_all"))
    end
  end
  set_next_line_info_position(form, drama_flag)
end
function show_guide_task(form, mark, drama_flag)
  form.groupscrollbox_guide_task.Visible = true
  form.groupscrollbox_accept_info.Visible = false
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local task_id = mark % CAN_ACCEPT_GUIDE_MARK
  local task_title = taskmgr:GetGuideTaskProp(nx_string(task_id), "title_id")
  local task_desc = taskmgr:GetGuideTaskProp(nx_string(task_id), "AcceptDialogID")
  local accept_npc = taskmgr:GetGuideTaskProp(nx_string(task_id), "AcceptNpc")
  local prize_desc = taskmgr:GetGuideTaskProp(nx_string(task_id), "PrizeDesc")
  local scene_id = taskmgr:GetGuideTaskProp(nx_string(task_id), "AcceptSceneID")
  local scene_name = get_scene_name(nx_string(scene_id))
  local npc_link = nx_widestr(" ") .. nx_widestr("<a href=\"findnpc_new,") .. nx_widestr(scene_name) .. nx_widestr(",") .. nx_widestr(accept_npc) .. nx_widestr(",") .. nx_widestr("\" style=\"HLStype1\">") .. nx_widestr(util_text(accept_npc)) .. nx_widestr("</a>")
  if "" ~= task_title then
    form.lbl_guide_task_title.Text = nx_widestr(util_text(task_title))
    form.mltbox_guide_task_desc.HtmlText = nx_widestr(util_text(task_desc))
    form.mltbox_accept_npc.HtmlText = nx_widestr(npc_link)
    form.mltbox_guide_task_prize.HtmlText = nx_widestr(util_text(prize_desc))
  end
  set_guide_task_control_position(form)
end
function set_next_line_info_position(form, drama_flag)
  form.groupscrollbox_accept_info.IsEditMode = true
  local top_control = 0
  form.mltbox_desc_info.Top = 51
  if nx_number(drama_flag) == nx_number(5) or nx_number(drama_flag) == nx_number(1) then
    local desc_info_height = form.mltbox_desc_info:GetContentHeight()
    form.mltbox_desc_info.Height = desc_info_height + 10
    local top_value = form.mltbox_desc_info.Top + nx_int(form.mltbox_desc_info.Height)
    if 10 > nx_int(form.lbl_next_title.Top) - nx_int(top_value) then
      form.lbl_next_title.Top = nx_int(top_value) + 10
    end
    form.lbl_accept_bg_line_1.Visible = true
    form.lbl_accept_bg_line_1.Top = form.lbl_next_title.Top + form.lbl_next_title.Height + 4 - 10
    form.mltbox_next_info.Top = form.lbl_accept_bg_line_1.Top + form.lbl_accept_bg_line_1.Height + 4
    form.mltbox_enyuan_tips.Top = form.mltbox_next_info.Top + form.mltbox_next_info.Height + 10
    if form.mltbox_enyuan_tips.Visible == true then
      form.lbl_accept_prize_title.Top = form.mltbox_enyuan_tips.Top + form.mltbox_enyuan_tips.Height + 20
      form.imagegrid_prize_sl.Top = form.lbl_accept_prize_title.Top + form.lbl_accept_prize_title.Height + 10
    else
      form.lbl_accept_prize_title.Top = form.mltbox_next_info.Top + form.mltbox_next_info.Height + 20
      form.imagegrid_prize_sl.Top = form.lbl_accept_prize_title.Top + form.lbl_accept_prize_title.Height + 20
    end
  end
  form.groupscrollbox_accept_info.Height = 406
  form.groupscrollbox_accept_info.IsEditMode = false
end
function set_guide_task_control_position(form)
  form.groupscrollbox_guide_task.IsEditMode = true
  local line_space = 15
  local top = form.mltbox_guide_task_desc.Top
  local height = form.mltbox_guide_task_desc:GetContentHeight()
  form.mltbox_guide_task_desc.Height = height + 5
  top = top + height + line_space
  form.lbl_guide_accepte_npc.Top = top
  top = top + form.lbl_guide_accepte_npc.Height + 5
  form.mltbox_accept_npc.Top = top
  top = top + form.mltbox_accept_npc:GetContentHeight() + line_space
  form.lbl_guide_prize_title.Top = top
  top = top + form.lbl_guide_prize_title.Height + 5
  form.mltbox_guide_task_prize.Top = top
  local prize_height = form.mltbox_guide_task_prize:GetContentHeight()
  form.mltbox_guide_task_prize.Height = prize_height + 5
  form.groupscrollbox_guide_task.IsEditMode = false
end
function show_puzzle_task_info(form, mark)
  local index = mark - DRAMA_PUZZLE_MARK
  form.groupscrollbox_accept_info.Visible = false
  form.mltbox_drama.Visible = false
  form.groupscrollbox_task.Visible = false
  form.groupscrollbox_guide_task.Visible = false
  form.groupscrollbox_puzzle_info.Visible = true
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("Puzzle_Record") then
    return
  end
  form.mltbox_puzzle_task_desc:Clear()
  local row = client_player:FindRecordRow("Puzzle_Record", puzzle_rec_index, index)
  if row < 0 then
    return
  end
  local rec_flag = client_player:QueryRecord("Puzzle_Record", row, puzzle_rec_flag)
  local clue_task = client_player:QueryRecord("Puzzle_Record", row, puzzle_rec_clue)
  local task_all_table = util_split_string(clue_task, "|")
  if table.getn(task_all_table) > 6 then
    return
  end
  local btn_puzzle_task = {
    form.btn_puzzle_task_1,
    form.btn_puzzle_task_2,
    form.btn_puzzle_task_3,
    form.btn_puzzle_task_4,
    form.btn_puzzle_task_5,
    form.btn_puzzle_task_6
  }
  local complete_count = 0
  for i, task in pairs(task_all_table) do
    local task_info = util_split_string(task, ",")
    if table.getn(task_info) ~= 3 then
      return
    end
    local task_id = task_info[1]
    local must_do = task_info[2]
    local complete = task_info[3]
    if nx_int(complete) == nx_int(1) then
      btn_puzzle_task[i].BlendColor = "255,255,255,255"
      complete_count = complete_count + 1
    else
      btn_puzzle_task[i].BlendColor = "122,255,255,255"
    end
    btn_puzzle_task[i].taskid = task_id
    btn_puzzle_task[i].complete = complete
  end
  if 4 <= complete_count and rec_flag == 0 then
    form.btn_explain_puzzle.NormalImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_out.png"
    form.btn_explain_puzzle.FocusImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_on.png"
    form.btn_explain_puzzle.PushImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_down.png"
    form.btn_explain_puzzle.DisableImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_forbid.png"
  else
    form.btn_explain_puzzle.NormalImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_forbid.png"
    form.btn_explain_puzzle.FocusImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_forbid.png"
    form.btn_explain_puzzle.PushImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_forbid.png"
    form.btn_explain_puzzle.DisableImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_forbid.png"
  end
  if rec_flag == 1 then
    form.btn_get_prize.Enabled = true
  else
    form.btn_get_prize.Enabled = false
  end
  if rec_flag == 0 then
    form.lbl_puzzle_level.Visible = false
    form.lbl_puzzle_level2.Visible = false
  else
    local rec_appraise = client_player:QueryRecord("Puzzle_Record", row, puzzle_rec_appraise)
    local puzzle_flag = client_player:QueryRecord("Puzzle_Record", row, puzzle_rec_flag)
    get_puzzle_task_appraise(form, rec_appraise, puzzle_flag)
  end
end
function on_btn_puzzle_task_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(btn, "taskid") then
    return
  end
  if not nx_is_valid(btn.taskid) then
    return
  end
  form.mltbox_puzzle_task_desc:Clear()
  local task_id = btn.taskid
  local complete = btn.complete
  if nx_int(complete) == nx_int(0) then
    form.mltbox_puzzle_task_desc:AddHtmlText(nx_widestr(util_text("ui_puzzle_task_" .. nx_string(task_id) .. "_0")), 0)
  else
    form.mltbox_puzzle_task_desc:AddHtmlText(nx_widestr(util_text("ui_puzzle_task_" .. nx_string(task_id) .. "_1")), 1)
  end
end
function show_task_prize(form, task_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
  if task_row < 0 then
    return
  end
  if 0 >= nx_number(task_id) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  form.imagegrid_prize_base:Clear()
  form.imagegrid_prize_ex:Clear()
  form.lbl_title_prize.Visible = false
  form.groupbox_prize_base.Visible = false
  form.groupbox_prize_ex.Visible = false
  form.groupbox_prize_money.Visible = false
  form.groupbox_prize_overfulfill.Visible = false
  form.groupbox_prize_money_ex.Visible = false
  form.faculty_pic.Visible = false
  form.lbl_faculty.Visible = false
  form.jianghu_pic.Visible = false
  form.lbl_jianghu.Visible = false
  form.school_pic.Visible = false
  form.lbl_school.Visible = false
  form.money_pic.Visible = false
  form.lbl_money.Visible = false
  form.groove_pic.Visible = false
  form.lbl_groove.Visible = false
  form.lbl_yinka.Visible = false
  form.yinka_pic.Visible = false
  form.faculty_pic_ex.Visible = false
  form.lbl_faculty_ex.Visible = false
  form.jianghu_pic_ex.Visible = false
  form.lbl_jianghu_ex.Visible = false
  form.school_pic_ex.Visible = false
  form.lbl_school_ex.Visible = false
  form.money_pic_ex.Visible = false
  form.lbl_money_ex.Visible = false
  form.groove_pic_ex.Visible = false
  form.lbl_groove_ex.Visible = false
  form.lbl_yinka_ex.Visible = false
  form.yinka_pic_ex.Visible = false
  form.faculty_pic_overfulfill.Visible = false
  form.lbl_faculty_overfulfill.Visible = false
  form.jianghu_pic_overfulfill.Visible = false
  form.lbl_jianghu_overfulfill.Visible = false
  form.school_pic_overfulfill.Visible = false
  form.lbl_school_overfulfill.Visible = false
  form.money_pic_overfulfill.Visible = false
  form.lbl_money_overfulfill.Visible = false
  form.groove_pic_overfulfill.Visible = false
  form.lbl_groove_overfulfill.Visible = false
  form.yinka_pic_overfulfill.Visible = false
  form.lbl_yinka_overfulfill.Visible = false
  local strTotalPrize = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_prize_base)
  if nx_string(strTotalPrize) == "" then
    return
  end
  local table_prize_info = util_split_string(strTotalPrize, ",")
  if table.getn(table_prize_info) <= TASK_PRIZE_NUM then
    return
  end
  local HasPrizeShow = false
  if nx_string(table_prize_info[1]) ~= "0" then
    local d, l, w = format_prize_money(nx_int64(table_prize_info[1]))
    local prop_text = ""
    if 0 < nx_number(d) then
      prop_text = nx_widestr(d) .. nx_widestr(util_text("ui_Ding"))
    end
    if 0 < nx_number(l) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(l) .. nx_widestr(util_text("ui_Liang"))
    end
    if 0 < nx_number(w) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(w) .. nx_widestr(util_text("ui_Wen"))
    end
    form.lbl_money.Text = nx_widestr(prop_text)
    form.money_pic.Visible = true
    form.lbl_money.Visible = true
    form.lbl_money.Width = form.lbl_money.TextWidth
    form.money_pic.tips = nx_string("ui_task_prize_money")
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[22]) ~= "0" then
    local d, l, w = format_prize_money(nx_int64(table_prize_info[22]))
    local prop_text = ""
    if 0 < nx_number(d) then
      prop_text = nx_widestr(d) .. nx_widestr(util_text("ui_Ding"))
    end
    if 0 < nx_number(l) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(l) .. nx_widestr(util_text("ui_Liang"))
    end
    if 0 < nx_number(w) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(w) .. nx_widestr(util_text("ui_Wen"))
    end
    form.lbl_yinka.Text = nx_widestr(prop_text)
    form.yinka_pic.Visible = true
    form.lbl_yinka.Visible = true
    form.lbl_yinka.Width = form.lbl_money.TextWidth
    form.yinka_pic.tips = nx_string("ui_task_prize_money")
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[2]) ~= "0" then
    form.lbl_faculty.Text = nx_widestr(table_prize_info[2])
    form.faculty_pic.Visible = true
    form.lbl_faculty.Visible = true
    form.lbl_faculty.Width = form.lbl_faculty.TextWidth
    form.faculty_pic.tips = nx_string("ui_task_prize_faculty")
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[3]) ~= "0" and nx_string(table_prize_info[4]) ~= "0" then
    if nx_string(table_prize_info[3]) == nx_string("repute_jianghu") then
      form.lbl_jianghu.Text = nx_widestr(table_prize_info[4])
      form.jianghu_pic.Visible = true
      form.lbl_jianghu.Visible = true
      form.lbl_jianghu.Width = form.lbl_jianghu.TextWidth
      form.jianghu_pic.tips = nx_string(table_prize_info[3])
    else
      form.lbl_school.Text = nx_widestr(table_prize_info[4])
      form.school_pic.Visible = true
      form.lbl_school.Visible = true
      form.lbl_school.Width = form.lbl_school.TextWidth
      form.school_pic.tips = nx_string(table_prize_info[3])
    end
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[5]) ~= "0" and nx_string(table_prize_info[6]) ~= "0" then
    if nx_string(table_prize_info[5]) == nx_string("repute_jianghu") then
      form.lbl_jianghu.Text = nx_widestr(table_prize_info[6])
      form.jianghu_pic.Visible = true
      form.lbl_jianghu.Visible = true
      form.lbl_jianghu.Width = form.lbl_jianghu.TextWidth
      form.jianghu_pic.tips = nx_string(table_prize_info[5])
    else
      form.lbl_school.Text = nx_widestr(table_prize_info[6])
      form.school_pic.Visible = true
      form.lbl_school.Visible = true
      form.lbl_school.Width = form.lbl_school.TextWidth
      form.school_pic.tips = nx_string(table_prize_info[5])
    end
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[20]) ~= "0" and nx_string(table_prize_info[21]) ~= "0" then
    form.lbl_groove.Text = nx_widestr(nx_int(table_prize_info[21]) / nx_int(1000))
    form.groove_pic.Visible = true
    form.lbl_groove.Visible = true
    form.lbl_groove.Width = form.lbl_groove.TextWidth
    form.groove_pic.tips = nx_string("ui_task_prize_groove_") .. nx_string(table_prize_info[20])
    HasPrizeShow = true
  end
  if HasPrizeShow then
    form.groupbox_prize_money.Visible = true
  end
  local index_base = 0
  if nx_string(table_prize_info[9]) == "1" then
    form.lbl_title_base.Text = nx_widestr(util_text("ui_task_prize_choose"))
  else
    form.lbl_title_base.Text = nx_widestr(util_text("ui_task_prize_all"))
  end
  if nx_string(table_prize_info[10]) ~= "0" then
    local flag_add = form.imagegrid_prize_base:AddItem(index_base, "icon\\prop\\prop024.png", nx_widestr(util_text("ui_task_prize_random")), 1, 2)
    if flag_add then
      index_base = 1
    end
  end
  for i = 11, 18, 2 do
    if nx_string(table_prize_info[i]) ~= "0" then
      local id = table_prize_info[i]
      local num = table_prize_info[i + 1]
      local photo = get_icon(0, nx_string(id))
      local flag_add = form.imagegrid_prize_base:AddItem(index_base, nx_string(photo), nx_widestr(id), nx_int(num), 0)
      if flag_add then
        index_base = index_base + 1
      end
    end
  end
  if 0 < nx_number(index_base) then
    HasPrizeShow = true
    form.groupbox_prize_base.Visible = true
  end
  show_task_prize_ex(form, task_id)
  show_task_prize_overfulfill(form, task_id)
  if HasPrizeShow then
    form.lbl_title_prize.Visible = true
  end
  local init_left = 0
  if form.faculty_pic.Visible then
    form.faculty_pic.Left = init_left
    form.lbl_faculty.Left = form.faculty_pic.Left + form.faculty_pic.Width + CONFIG_PRIZE_CONTROL_SPACE
    init_left = form.lbl_faculty.Left + form.lbl_faculty.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  if form.jianghu_pic.Visible then
    form.jianghu_pic.Left = init_left
    form.lbl_jianghu.Left = form.jianghu_pic.Left + form.jianghu_pic.Width + CONFIG_PRIZE_CONTROL_SPACE
    init_left = form.lbl_jianghu.Left + form.lbl_jianghu.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  if form.school_pic.Visible then
    form.school_pic.Left = init_left
    form.lbl_school.Left = form.school_pic.Left + form.school_pic.Width + CONFIG_PRIZE_CONTROL_SPACE
    init_left = form.lbl_school.Left + form.lbl_school.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  if form.groove_pic.Visible then
    form.groove_pic.Left = init_left
    form.lbl_groove.Left = form.groove_pic.Left + form.groove_pic.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  form.lbl_money.Top = 22
  form.money_pic.Top = 22
  form.lbl_yinka.Top = 22
  form.yinka_pic.Top = 25
  if not form.faculty_pic.Visible and not form.jianghu_pic.Visible and not form.school_pic.Visible and not form.groove_pic.Visible then
    form.money_pic.Top = 4
    form.lbl_money.Top = 0
    form.yinka_pic.Top = 4
    form.lbl_yinka.Top = 0
  end
  form.lbl_yinka.Left = 24
  form.yinka_pic.Left = 0
  if true == form.lbl_money.Visible then
    form.yinka_pic.Left = form.lbl_money.Left + form.lbl_money.Width + 10
    form.lbl_yinka.Left = form.yinka_pic.Left + form.yinka_pic.Width + 5
  end
end
function show_task_prize_ex(form, task_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
  if task_row < 0 then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local strTotalPrize = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_prize_ex)
  if nx_string(strTotalPrize) == "" then
    return
  end
  local table_prize_info = util_split_string(strTotalPrize, ",")
  if table.getn(table_prize_info) <= TASK_PRIZE_NUM then
    return
  end
  local HasPrizeShow = false
  if nx_string(table_prize_info[1]) ~= "0" then
    local d, l, w = format_prize_money(nx_int64(table_prize_info[1]))
    local prop_text = ""
    if 0 < nx_number(d) then
      prop_text = nx_widestr(d) .. nx_widestr(util_text("ui_Ding"))
    end
    if 0 < nx_number(l) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(l) .. nx_widestr(util_text("ui_Liang"))
    end
    if 0 < nx_number(w) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(w) .. nx_widestr(util_text("ui_Wen"))
    end
    form.lbl_money_ex.Text = nx_widestr(prop_text)
    form.money_pic_ex.Visible = true
    form.lbl_money_ex.Visible = true
    form.lbl_money_ex.Width = form.lbl_money_ex.TextWidth
    form.money_pic_ex.tips = nx_string("ui_task_prize_money")
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[22]) ~= "0" then
    local d, l, w = format_prize_money(nx_int64(table_prize_info[22]))
    local prop_text = ""
    if 0 < nx_number(d) then
      prop_text = nx_widestr(d) .. nx_widestr(util_text("ui_Ding"))
    end
    if 0 < nx_number(l) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(l) .. nx_widestr(util_text("ui_Liang"))
    end
    if 0 < nx_number(w) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(w) .. nx_widestr(util_text("ui_Wen"))
    end
    form.lbl_yinka_ex.Text = nx_widestr(prop_text)
    form.yinka_pic_ex.Visible = true
    form.lbl_yinka_ex.Visible = true
    form.lbl_yinka_ex.Width = form.lbl_money_ex.TextWidth
    form.yinka_pic_ex.tips = nx_string("ui_task_prize_money")
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[2]) ~= "0" then
    form.lbl_faculty_ex.Text = nx_widestr(table_prize_info[2])
    form.faculty_pic_ex.Visible = true
    form.lbl_faculty_ex.Visible = true
    form.lbl_faculty_ex.Width = form.lbl_faculty_ex.TextWidth
    form.faculty_pic_ex.tips = nx_string("ui_task_prize_faculty")
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[3]) ~= "0" and nx_string(table_prize_info[4]) ~= "0" then
    if nx_string(table_prize_info[3]) == nx_string("repute_jianghu") then
      form.lbl_jianghu_ex.Text = nx_widestr(table_prize_info[4])
      form.jianghu_pic_ex.Visible = true
      form.lbl_jianghu_ex.Visible = true
      form.lbl_jianghu_ex.Width = form.lbl_jianghu_ex.TextWidth
      form.jianghu_pic_ex.tips = nx_string(table_prize_info[3])
    else
      form.lbl_school_ex.Text = nx_widestr(table_prize_info[4])
      form.school_pic_ex.Visible = true
      form.lbl_school_ex.Visible = true
      form.lbl_school_ex.Width = form.lbl_school_ex.TextWidth
      form.school_pic_ex.tips = nx_string(table_prize_info[3])
    end
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[5]) ~= "0" and nx_string(table_prize_info[6]) ~= "0" then
    if nx_string(table_prize_info[5]) == nx_string("repute_jianghu") then
      form.lbl_jianghu_ex.Text = nx_widestr(table_prize_info[6])
      form.jianghu_pic_ex.Visible = true
      form.lbl_jianghu_ex.Visible = true
      form.lbl_jianghu_ex.Width = form.lbl_jianghu_ex.TextWidth
      form.jianghu_pic_ex.tips = nx_string(table_prize_info[5])
    else
      form.lbl_school_ex.Text = nx_widestr(table_prize_info[6])
      form.school_pic_ex.Visible = true
      form.lbl_school_ex.Visible = true
      form.lbl_school_ex.Width = form.lbl_school_ex.TextWidth
      form.school_pic_ex.tips = nx_string(table_prize_info[5])
    end
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[20]) ~= "0" and nx_string(table_prize_info[21]) ~= "0" then
    form.lbl_groove_ex.Text = nx_widestr(nx_int(table_prize_info[21]) / nx_int(1000))
    form.groove_pic_ex.Visible = true
    form.lbl_groove_ex.Visible = true
    form.lbl_groove_ex.Width = form.lbl_groove_ex.TextWidth
    form.groove_pic_ex.tips = nx_string("ui_task_prize_groove_") .. nx_string(table_prize_info[20])
    HasPrizeShow = true
  end
  if HasPrizeShow then
    form.groupbox_prize_money_ex.Visible = true
  end
  local init_left = 19
  if form.faculty_pic_ex.Visible then
    form.faculty_pic_ex.Left = init_left
    form.lbl_faculty_ex.Left = form.faculty_pic_ex.Left + form.faculty_pic_ex.Width + CONFIG_PRIZE_CONTROL_SPACE
    init_left = form.lbl_faculty_ex.Left + form.lbl_faculty_ex.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  if form.jianghu_pic_ex.Visible then
    form.jianghu_pic_ex.Left = init_left
    form.lbl_jianghu_ex.Left = form.jianghu_pic_ex.Left + form.jianghu_pic_ex.Width + CONFIG_PRIZE_CONTROL_SPACE
    init_left = form.lbl_jianghu_ex.Left + form.lbl_jianghu_ex.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  if form.school_pic_ex.Visible then
    form.school_pic_ex.Left = init_left
    form.lbl_school_ex.Left = form.school_pic_ex.Left + form.school_pic_ex.Width + CONFIG_PRIZE_CONTROL_SPACE
    init_left = form.lbl_school_ex.Left + form.lbl_school_ex.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  if form.groove_pic_ex.Visible then
    form.groove_pic_ex.Left = init_left
    form.lbl_groove_ex.Left = form.groove_pic_ex.Left + form.groove_pic_ex.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  form.lbl_money_ex.Top = 60
  form.money_pic_ex.Top = 62
  form.yinka_pic_ex.Top = 65
  form.lbl_yinka_ex.Top = 62
  if not form.faculty_pic_ex.Visible and not form.jianghu_pic_ex.Visible and not form.school_pic_ex.Visible and not form.groove_pic_ex.Visible then
    form.money_pic_ex.Top = 41
    form.lbl_money_ex.Top = 41
    form.yinka_pic_ex.Top = 41
    form.lbl_yinka_ex.Top = 41
  end
  form.yinka_pic_ex.Left = 19
  form.lbl_yinka_ex.Left = 42
  if true == form.money_pic_ex.Visible then
    form.yinka_pic_ex.Left = form.lbl_money_ex.Left + form.lbl_money_ex.Width + 10
    form.lbl_yinka_ex.Left = form.yinka_pic_ex.Left + form.yinka_pic_ex.Width + 5
  end
  local index_base = 0
  if nx_string(table_prize_info[10]) ~= "0" then
    local flag_add = form.imagegrid_prize_ex:AddItem(index_base, "icon\\prop\\prop024.png", nx_widestr(util_text("ui_task_prize_random")), 1, 2)
    if flag_add then
      index_base = 1
    end
  end
  for i = 11, 18, 2 do
    if nx_string(table_prize_info[i]) ~= "0" then
      local id = table_prize_info[i]
      local num = table_prize_info[i + 1]
      local photo = get_icon(0, nx_string(id))
      local flag_add = form.imagegrid_prize_ex:AddItem(index_base, nx_string(photo), nx_widestr(id), nx_int(num), 0)
      if flag_add then
        index_base = index_base + 1
      end
    end
  end
  if 0 < nx_number(index_base) then
    HasPrizeShow = true
    form.groupbox_prize_ex.Visible = true
  end
  show_lbl_prize_ex_text(form, client_player, task_id)
end
function show_lbl_prize_ex_text(form, client_player, task_id)
  if false == form.groupbox_prize_money_ex.Visible then
    return
  end
  local row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id), 0)
  if row < 0 then
    return
  end
  local line = client_player:QueryRecord("Task_Accepted", row, accept_rec_line)
  local current_round = 0
  if line == task_line_main then
    if client_player:FindRecord("DramaRec") and 0 < client_player:GetRecordRows("DramaRec") then
      current_round = client_player:QueryRecord("DramaRec", 0, 2)
    end
    if 4 == current_round then
      form.lbl_prize_ex.Text = nx_widestr(util_text("ui_task_chapter_prize"))
    else
      form.lbl_prize_ex.Text = nx_widestr(util_text("ui_task_round_prize"))
    end
  elseif line == task_line_menpai then
    if client_player:FindRecord("SchoolDramaRec") and 0 < client_player:GetRecordRows("SchoolDramaRec") then
      current_round = client_player:QueryRecord("SchoolDramaRec", 0, 2)
    end
    if 4 == current_round then
      form.lbl_prize_ex.Text = nx_widestr(util_text("ui_task_chapter_prize"))
    else
      form.lbl_prize_ex.Text = nx_widestr(util_text("ui_task_round_prize"))
    end
  end
end
function show_task_prize_overfulfill(form, task_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
  if task_row < 0 then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local strTotalPrize = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_prize_over)
  if nx_string(strTotalPrize) == "" then
    return
  end
  local table_prize_info = util_split_string(strTotalPrize, ",")
  if table.getn(table_prize_info) <= TASK_PRIZE_NUM then
    return
  end
  local HasPrizeShow = false
  if nx_string(table_prize_info[1]) ~= "0" then
    local d, l, w = format_prize_money(nx_int64(table_prize_info[1]))
    local prop_text = ""
    if 0 < nx_number(d) then
      prop_text = nx_widestr(d) .. nx_widestr(util_text("ui_Ding"))
    end
    if 0 < nx_number(l) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(l) .. nx_widestr(util_text("ui_Liang"))
    end
    if 0 < nx_number(w) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(w) .. nx_widestr(util_text("ui_Wen"))
    end
    form.lbl_money_overfulfill.Text = nx_widestr(prop_text)
    form.money_pic_overfulfill.Visible = true
    form.lbl_money_overfulfill.Visible = true
    form.lbl_money_overfulfill.Width = form.lbl_money_overfulfill.TextWidth
    form.money_pic_overfulfill.tips = nx_string("ui_task_prize_money")
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[22]) ~= "0" then
    local d, l, w = format_prize_money(nx_int64(table_prize_info[22]))
    local prop_text = ""
    if 0 < nx_number(d) then
      prop_text = nx_widestr(d) .. nx_widestr(util_text("ui_Ding"))
    end
    if 0 < nx_number(l) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(l) .. nx_widestr(util_text("ui_Liang"))
    end
    if 0 < nx_number(w) then
      prop_text = nx_widestr(prop_text) .. nx_widestr(w) .. nx_widestr(util_text("ui_Wen"))
    end
    form.lbl_yinka_overfulfill.Text = nx_widestr(prop_text)
    form.yinka_pic_overfulfill.Visible = true
    form.lbl_yinka_overfulfill.Visible = true
    form.lbl_yinka_overfulfill.Width = form.lbl_money_overfulfill.TextWidth
    form.yinka_pic_overfulfill.tips = nx_string("ui_task_prize_money")
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[2]) ~= "0" then
    form.lbl_faculty_overfulfill.Text = nx_widestr(table_prize_info[2])
    form.faculty_pic_overfulfill.Visible = true
    form.lbl_faculty_overfulfill.Visible = true
    form.lbl_faculty_overfulfill.Width = form.lbl_faculty_overfulfill.TextWidth
    form.faculty_pic_overfulfill.tips = nx_string("ui_task_prize_faculty")
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[3]) ~= "0" and nx_string(table_prize_info[4]) ~= "0" then
    if nx_string(table_prize_info[3]) == nx_string("repute_jianghu") then
      form.lbl_jianghu_overfulfill.Text = nx_widestr(table_prize_info[4])
      form.jianghu_pic_overfulfill.Visible = true
      form.lbl_jianghu_overfulfill.Visible = true
      form.lbl_jianghu_overfulfill.Width = form.lbl_jianghu_overfulfill.TextWidth
      form.jianghu_pic_overfulfill.tips = nx_string(table_prize_info[3])
    else
      form.lbl_school_overfulfill.Text = nx_widestr(table_prize_info[4])
      form.school_pic_overfulfill.Visible = true
      form.lbl_school_overfulfill.Visible = true
      form.lbl_school_overfulfill.Width = form.lbl_school_overfulfill.TextWidth
      form.school_pic_overfulfill.tips = nx_string(table_prize_info[3])
    end
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[5]) ~= "0" and nx_string(table_prize_info[6]) ~= "0" then
    if nx_string(table_prize_info[5]) == nx_string("repute_jianghu") then
      form.lbl_jianghu_overfulfill.Text = nx_widestr(table_prize_info[6])
      form.jianghu_pic_overfulfill.Visible = true
      form.lbl_jianghu_overfulfill.Visible = true
      form.lbl_jianghu_overfulfill.Width = form.lbl_jianghu_overfulfill.TextWidth
      form.jianghu_pic_overfulfill.tips = nx_string(table_prize_info[5])
    else
      form.lbl_school_overfulfill.Text = nx_widestr(table_prize_info[6])
      form.school_pic_overfulfill.Visible = true
      form.lbl_school_overfulfill.Visible = true
      form.lbl_school_overfulfill.Width = form.lbl_school_overfulfill.TextWidth
      form.school_pic_overfulfill.tips = nx_string(table_prize_info[5])
    end
    HasPrizeShow = true
  end
  if nx_string(table_prize_info[20]) ~= "0" and nx_string(table_prize_info[21]) ~= "0" then
    form.lbl_groove_overfulfill.Text = nx_widestr(nx_int(table_prize_info[21]) / nx_int(1000))
    form.groove_pic_overfulfill.Visible = true
    form.lbl_groove_overfulfill.Visible = true
    form.lbl_groove_overfulfill.Width = form.lbl_groove_overfulfill.TextWidth
    form.groove_pic_overfulfill.tips = nx_string("ui_task_prize_groove_") .. nx_string(table_prize_info[20])
    HasPrizeShow = true
  end
  if HasPrizeShow then
    form.groupbox_prize_overfulfill.Visible = true
  end
  local init_left = 0
  if form.faculty_pic_overfulfill.Visible then
    form.faculty_pic_overfulfill.Left = init_left
    form.lbl_faculty_overfulfill.Left = form.faculty_pic_overfulfill.Left + form.faculty_pic_overfulfill.Width + CONFIG_PRIZE_CONTROL_SPACE
    init_left = form.lbl_faculty_overfulfill.Left + form.lbl_faculty_overfulfill.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  if form.jianghu_pic_overfulfill.Visible then
    form.jianghu_pic_overfulfill.Left = init_left
    form.lbl_jianghu_overfulfill.Left = form.jianghu_pic_overfulfill.Left + form.jianghu_pic_overfulfill.Width + CONFIG_PRIZE_CONTROL_SPACE
    init_left = form.lbl_jianghu_overfulfill.Left + form.lbl_jianghu_overfulfill.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  if form.school_pic_overfulfill.Visible then
    form.school_pic_overfulfill.Left = init_left
    form.lbl_school_overfulfill.Left = form.school_pic_overfulfill.Left + form.school_pic_overfulfill.Width + CONFIG_PRIZE_CONTROL_SPACE
    init_left = form.lbl_school_overfulfill.Left + form.lbl_school_overfulfill.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  if form.groove_pic_overfulfill.Visible then
    form.groove_pic_overfulfill.Left = init_left
    form.lbl_groove_overfulfill.Left = form.groove_pic_overfulfill.Left + form.groove_pic_overfulfill.Width + CONFIG_PRIZE_CONTROL_SPACE
  end
  form.lbl_money_overfulfill.Top = 38
  form.money_pic_overfulfill.Top = 42
  form.lbl_yinka_overfulfill.Top = 38
  form.yinka_pic_overfulfill.Top = 45
  if not form.faculty_pic_overfulfill.Visible and not form.jianghu_pic_overfulfill.Visible and not form.school_pic_overfulfill.Visible and not form.groove_pic_overfulfill.Visible then
    form.money_pic_overfulfill.Top = 16
    form.lbl_money_overfulfill.Top = 12
    form.lbl_yinka_overfulfill.Top = 12
    form.yinka_pic_overfulfill.Top = 19
  end
  form.yinka_pic_overfulfill.Left = 1
  form.lbl_yinka_overfulfill.Left = 28
  if true == form.money_pic_overfulfill.Visible then
    form.yinka_pic_overfulfill.Left = form.lbl_money_overfulfill.Left + form.lbl_money_overfulfill.Width + 10
    form.lbl_yinka_overfulfill.Left = form.yinka_pic_overfulfill.Left + form.yinka_pic_overfulfill.Width + 5
  end
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_type = grid:GetItemMark(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  if nx_number(prize_type) == 1 then
    local tip_text = nx_widestr(util_text(nx_string(prize_id)) .. ":" .. nx_string(prize_count))
    nx_execute("tips_game", "show_text_tip", tip_text, x, y)
  elseif nx_number(prize_type) == 2 then
    local tip_text = nx_widestr(prize_id)
    nx_execute("tips_game", "show_text_tip", tip_text, x, y)
  elseif nx_number(prize_type) == 0 then
    local itemmap = nx_value("ItemQuery")
    if not nx_is_valid(itemmap) then
      return
    end
    local table_prop_name = {}
    local table_prop_value = {}
    table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
    if 0 >= table.getn(table_prop_name) then
      return
    end
    table_prop_value.ConfigID = nx_string(prize_id)
    for count = 1, table.getn(table_prop_name) do
      local prop_name = table_prop_name[count]
      local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
      table_prop_value[prop_name] = prop_value
    end
    local staticdatamgr = nx_value("data_query_manager")
    if nx_is_valid(staticdatamgr) then
      local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
      local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
      if nx_string(photo) ~= "" and photo ~= nil then
        table_prop_value.Photo = photo
      end
    end
    if nx_is_valid(grid.Data) then
      nx_destroy(grid.Data)
    end
    grid.Data = nx_create("ArrayList", "task_grid_data")
    grid.Data:ClearChild()
    for prop, value in pairs(table_prop_value) do
      nx_set_custom(grid.Data, prop, value)
    end
    nx_set_custom(grid.Data, "is_static", true)
    nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
    grid.Data:ClearChild()
  end
end
function get_icon(type, name)
  local str_icon = ""
  local select_type = 0
  if nx_number(type) == 0 then
    str_icon = nx_call("util_static_data", "item_query_ArtPack_by_id", name, "Photo")
  end
  if str_icon ~= nil and 0 < string.len(str_icon) then
    return str_icon
  end
  return ""
end
function format_prize_money(money)
  local ding = nx_int64(money / 1000000)
  local temp = nx_int64(money - ding * 1000000)
  local liang = nx_int64(temp / 1000)
  local wen = nx_int64(temp - liang * 1000)
  return ding, liang, wen
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  local is_help = nx_custom(form, "is_help")
  if is_help == nil or is_help == false then
    form:Close()
  else
    form.is_help = false
    nx_execute("form_stage_main\\form_helper\\form_move_win", "util_open_move_win", form.AbsLeft, form.AbsTop, form.Width, form.Height, "", "open_form_task,btn_task")
    form:Close()
  end
end
function on_rbtn_click(rbtn)
  local form = rbtn.ParentForm
  local index = rbtn.TabIndex
  local mark = get_init_mark(index)
  show_all_info(form, index, mark)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_mltbox_select_item_change(mltbox, index)
  local form = mltbox.ParentForm
  if nx_is_valid(form.SelectMltbox) and nx_string(form.SelectMltbox.Name) ~= nx_string(mltbox.Name) then
    form.SelectMltbox:SetHtmlItemSelected(nx_int(form.SelectIndex), false)
  end
  form.SelectMltbox = mltbox
  form.SelectIndex = index
  local mark = mltbox:GetItemKeyByIndex(index)
  local BEFORE_CHAPTER_MARK = 9600000
  if nx_int(mark / 100000) == nx_int(BEFORE_CHAPTER_MARK / 100000) then
    local index = nx_int(mark % 100000 / 1000)
    local chapter = mark % 1000
    nx_execute("form_stage_main\\form_drama", "show_drama", index)
  else
    show_detail_info(form, mark)
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local current_drama = ""
  local current_chapter = 0
  if client_player:FindRecord("DramaRec") and 0 < client_player:GetRecordRows("DramaRec") then
    current_drama = client_player:QueryRecord("DramaRec", 0, 0)
    current_chapter = client_player:QueryRecord("DramaRec", 0, 1)
  end
  if current_drama == "" or g_drama_node[current_drama] == nil then
    return
  end
  if mark == g_drama_node[current_drama].mark + current_chapter * 100 then
    showDramaTips(current_drama .. "_" .. nx_string(current_chapter))
  end
end
function on_wy_mltbox_select_item_change(mltbox, index)
  local form = mltbox.ParentForm
  if nx_is_valid(form.SelectMltbox) and nx_string(form.SelectMltbox.Name) ~= nx_string(mltbox.Name) then
    form.SelectMltbox:SetHtmlItemSelected(nx_int(form.SelectIndex), false)
  end
  form.SelectMltbox = mltbox
  form.SelectIndex = index
  local mark = mltbox:GetItemKeyByIndex(index)
  local BEFORE_CHAPTER_MARK = 9600000
  if nx_int(mark / 100000) == nx_int(BEFORE_CHAPTER_MARK / 100000) then
    local index = nx_int(mark % 100000 / 1000)
    local chapter = mark % 1000
    nx_execute("form_stage_main\\form_drama", "show_drama", index)
  else
    show_detail_info(form, mark)
  end
  if form.rbtn_city.Checked then
    form.SelectCityNode = mltbox
    form.SelectCityNode.mark = mark
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local current_drama = ""
  local current_chapter = 0
  if client_player:FindRecord("DramaRec") and 0 < client_player:GetRecordRows("DramaRec") then
    current_drama = client_player:QueryRecord("DramaRec", 0, 0)
    current_chapter = client_player:QueryRecord("DramaRec", 0, 1)
  end
  if current_drama == "" or g_drama_node[current_drama] == nil then
    return
  end
  if mark == g_drama_node[current_drama].mark + current_chapter * 100 then
    show_detail_info(form, mark)
  end
end
function showDramaTips(drama_chapter)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local info = taskmgr:GetDramaDetailTips(nx_string(drama_chapter))
  local drama_info_table = util_split_string(info, "|")
  if table.getn(drama_info_table) ~= 8 then
    return
  end
  nx_execute("form_stage_main\\form_task\\form_drama_tips", "show_begin_drama_info", drama_info_table[1], drama_info_table[2], drama_info_table[3], drama_info_table[4], drama_info_table[5], drama_info_table[6], drama_info_table[7], drama_info_table[8])
end
function on_tree_select_changed(tree, node)
  local form = tree.ParentForm
  if nx_is_valid(form.SelectMltbox) then
    form.SelectMltbox:SetHtmlItemSelected(nx_int(form.SelectIndex), false)
  end
  form.SelectMltbox = nil
  form.SelectIndex = -1
  local mark = node.Mark
  form.SelectNode = node
  show_detail_info(form, mark)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(mark))
  if task_row < 0 then
    return
  end
  local adventure_plot = 0
  if nx_number(adventure_plot) > nx_number(0) then
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_adventure\\form_adventure_log", true, false)
  end
end
function on_cbtn_scene_checked_changed(cbtn)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return 0
  end
  local form = cbtn.ParentForm
  local scene_id = 0
  if cbtn.Checked then
    local game_client = nx_value("game_client")
    local client_scene = game_client:GetScene()
    if nx_is_valid(client_scene) then
      local gui = nx_value("gui")
      local config_id = client_scene:QueryProp("ConfigID")
      scene_id = taskmgr:GetSceneId(nx_string(config_id))
    end
  end
  refresh_zhixian_accept(form, scene_id, 0)
  set_accept_group_position(form)
end
function on_tree_zhixian_accept_expand_changed(tree, node)
  set_accept_group_position(tree.ParentForm)
end
function on_btn_share_click(btn)
  local form = btn.ParentForm
  local task_id = 0
  if form.rbtn_drama.Checked then
    local mltbox = form.SelectMltbox
    if not nx_is_valid(mltbox) then
      return
    end
    task_id = mltbox:GetItemKeyByIndex(form.SelectIndex)
    local flag = check_drama_info(task_id)
    if nx_number(flag) ~= nx_number(3) then
      return
    end
  elseif form.rbtn_jianghu.Checked then
    if not nx_is_valid(form.SelectNode) then
      return
    end
    task_id = form.SelectNode.Mark
    local flag = check_drama_info(task_id)
    if nx_number(flag) ~= nx_number(4) then
      return
    end
  elseif form.rbtn_can_accept.Checked then
    return
  elseif form.rbtn_guide_task.Checked then
    return
  elseif form.rbtn_wy_drama.Checked then
    local mltbox = form.SelectMltbox
    if not nx_is_valid(mltbox) then
      return
    end
    task_id = mltbox:GetItemKeyByIndex(form.SelectIndex)
    local flag = check_drama_info(task_id)
    if nx_number(flag) == nx_number(6) then
      return
    end
  elseif form.rbtn_city.Checked then
    local mltbox = form.SelectCityNode
    if not nx_is_valid(mltbox) then
      return
    end
    task_id = mltbox.mark
  end
  custom_share_task(task_id)
end
function on_btn_giveup_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local task_id = 0
  if form.rbtn_drama.Checked then
    local mltbox = form.SelectMltbox
    if not nx_is_valid(mltbox) then
      return
    end
    task_id = mltbox:GetItemKeyByIndex(form.SelectIndex)
    local flag = check_drama_info(task_id)
    if nx_number(flag) ~= nx_number(3) then
      return
    end
  elseif form.rbtn_jianghu.Checked then
    if not nx_is_valid(form.SelectNode) then
      return
    end
    task_id = form.SelectNode.Mark
    local flag = check_drama_info(task_id)
    if nx_number(flag) ~= nx_number(4) then
      return
    end
  elseif form.rbtn_can_accept.Checked then
    return
  elseif form.rbtn_guide_task.Checked then
    return
  elseif form.rbtn_wy_drama.Checked then
    local mltbox = form.SelectMltbox
    if not nx_is_valid(mltbox) then
      return
    end
    task_id = mltbox:GetItemKeyByIndex(form.SelectIndex)
    local flag = check_drama_info(task_id)
    if nx_number(flag) == nx_number(6) then
      return
    end
  elseif form.rbtn_city.Checked then
    local mltbox = form.SelectCityNode
    if not nx_is_valid(mltbox) then
      return
    end
    task_id = mltbox.mark
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text = nx_widestr(gui.TextManager:GetText(nx_string("ui_task_submit_giveup")))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
  if task_row < 0 then
    return
  end
  local canGiveup = 0
  local taskmgr = nx_value("TaskManager")
  if nx_is_valid(taskmgr) then
    canGiveup = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_can_giveup)
  end
  if nx_int(canGiveup) == nx_int(0) then
    local tiaozhan_begin = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_tiaozhan_begin)
    local tiaozhan_time = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_tiaozhan_time)
    if 0 < tiaozhan_begin and 0 < tiaozhan_time then
    else
      gui.TextManager:Format_SetIDName("9657")
      local info = gui.TextManager:Format_GetText()
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(info, 2)
      end
      return
    end
  end
  nx_execute("custom_sender", "custom_giveup_task", task_id)
  nx_execute("form_stage_main\\form_task\\form_task_trace", "update_trace_info", task_id, 2)
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_drama.Checked then
    local task_id = get_init_mark(1)
    show_all_info(form, 1, task_id)
  elseif form.rbtn_jianghu.Checked then
    local task_id = get_init_mark(2)
    show_all_info(form, 2, task_id)
  end
end
function on_btn_track_click(btn)
  local form = btn.ParentForm
  if form.rbtn_drama.Checked then
    local mltbox = form.SelectMltbox
    if not nx_is_valid(mltbox) then
      return
    end
    local mark = mltbox:GetItemKeyByIndex(form.SelectIndex)
    local flag = check_drama_info(mark)
    if nx_number(flag) ~= nx_number(3) then
      return
    end
    local track_flag = 1
    local text_trace_list = nx_execute("form_stage_main\\form_task\\form_task_trace", "get_trace_list_str")
    local table_trace = util_split_string(text_trace_list, ",")
    for i, id in pairs(table_trace) do
      if nx_number(id) == nx_number(mark) then
        track_flag = 0
        break
      end
    end
    update_mltbox_trace_flag(mltbox, form.SelectIndex, mark, track_flag)
    nx_execute("form_stage_main\\form_task\\form_task_trace", "update_trace_info", mark, track_flag)
  elseif form.rbtn_jianghu.Checked then
    local node = form.SelectNode
    if not nx_is_valid(node) then
      return
    end
    if nx_number(node.Level) ~= 2 then
      return
    end
    local task_id = form.SelectNode.Mark
    local img_index = node.ImageIndex
    if nx_number(img_index) == 0 then
      node.ImageIndex = 1
      nx_execute("form_stage_main\\form_task\\form_task_trace", "update_trace_info", task_id, 1)
    elseif nx_number(img_index) == 1 then
      node.ImageIndex = 0
      nx_execute("form_stage_main\\form_task\\form_task_trace", "update_trace_info", task_id, 0)
    end
  elseif form.rbtn_can_accept.Checked then
    return
  elseif form.rbtn_guide_task.Checked then
    return
  elseif form.rbtn_city.Checked then
    local mltbox = form.SelectCityNode
    local mark = form.SelectCityNode.mark
    local track_flag = 1
    local text_trace_list = nx_execute("form_stage_main\\form_task\\form_task_trace", "get_trace_list_str")
    local table_trace = util_split_string(text_trace_list, ",")
    for i, id in pairs(table_trace) do
      if nx_number(id) == nx_number(mark) then
        track_flag = 0
        break
      end
    end
    if nx_number(track_flag) == 0 then
      update_mltbox_trace_flag(mltbox, form.SelectIndex, mark, 0)
      nx_execute("form_stage_main\\form_task\\form_task_trace", "update_trace_info", mark, 0)
    elseif nx_number(track_flag) == 1 then
      update_mltbox_trace_flag(mltbox, form.SelectIndex, mark, 1)
      nx_execute("form_stage_main\\form_task\\form_task_trace", "update_trace_info", mark, 1)
    end
  end
  if false == form.cbtn_show_track.Checked then
    form.cbtn_show_track.Checked = true
  end
end
function on_cbtn_show_track_checked_changed(cbtn)
  local form_trace = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_task_trace", true, false)
  if cbtn.Checked then
    nx_execute("form_stage_main\\form_task\\form_task_trace", "operate_task_info", true)
  else
    nx_execute("form_stage_main\\form_task\\form_task_trace", "operate_task_info", false)
  end
end
function on_imagegrid_prize_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_prize_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_prize_pic_mousein_grid(grid, index)
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local tip_text = nx_widestr("")
  if nx_find_custom(grid, "tips") then
    tip_text = nx_widestr(util_text(grid.tips))
  end
  nx_execute("tips_game", "show_text_tip", tip_text, x, y)
end
function on_prize_pic_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_rpt_limit_mousein_grid(grid, index)
  local name = grid:GetItemName(nx_int(index))
  if name == nil or nx_string(name) == "" then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local cur_value = nx_string(grid:GetItemAddText(index, nx_int(1)))
  local level = nx_string(grid:GetItemAddText(index, nx_int(2)))
  local photo = nx_string(grid:GetItemAddText(index, nx_int(3)))
  local rpt_name = nx_string(grid:GetItemAddText(index, nx_int(4)))
  photo = "<img src=\"" .. nx_string(photo) .. "\" only=\"line\" valign=\"bottom\"/>"
  local tip_text = nx_widestr(util_text("ui_reputation_limit")) .. nx_widestr("<br>") .. nx_widestr(photo) .. nx_widestr(rpt_name) .. "<br>" .. nx_widestr(level) .. nx_widestr(" (") .. nx_widestr(cur_value) .. nx_widestr(")")
  nx_execute("tips_game", "show_text_tip", nx_widestr(tip_text), x, y)
end
function on_imagegrid_rpt_limit_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_mltbox_aim_click_hyperlink(mltbox, linkitem, linkdata)
  linkdata = nx_string(linkdata)
  local str_lst = nx_function("ext_split_string", linkdata, ",")
  if "TASK_ITEM" == str_lst[1] then
    if "" ~= str_lst[2] and nil ~= str_lst[2] then
      nx_execute("form_stage_main\\form_task\\form_task_trace", "click_task_item", str_lst[2])
    end
  else
    return
  end
end
function on_btn_explain_puzzle_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = form.PageMark - DRAMA_PUZZLE_MARK
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("Puzzle_Record") then
    return
  end
  form.mltbox_puzzle_task_desc:Clear()
  local row = client_player:FindRecordRow("Puzzle_Record", puzzle_rec_index, index)
  if row < 0 then
    return
  end
  local rec_flag = client_player:QueryRecord("Puzzle_Record", row, puzzle_rec_flag)
  local clue_task = client_player:QueryRecord("Puzzle_Record", row, puzzle_rec_clue)
  local task_all_table = util_split_string(clue_task, "|")
  if table.getn(task_all_table) > 6 then
    return
  end
  if rec_flag ~= 0 then
    form.mltbox_puzzle_task_desc:AddHtmlText(nx_widestr(util_text("ui_puzzle_task_completed" .. nx_string(index))), 0)
    return
  end
  local complete_count = 0
  for i, task in pairs(task_all_table) do
    local task_info = util_split_string(task, ",")
    if table.getn(task_info) ~= 3 then
      return
    end
    local complete = task_info[3]
    if nx_int(complete) == nx_int(1) then
      complete_count = complete_count + 1
    end
  end
  if complete_count < 4 then
    form.mltbox_puzzle_task_desc:AddHtmlText(nx_widestr(util_text("ui_puzzle_task_uncomplete" .. nx_string(index))), 0)
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  form.mltbox_puzzle_task_desc:AddHtmlText(nx_widestr(util_text("ui_puzzle_task_doing" .. nx_string(index))), 0)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_puzzle_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text = util_text("ui_puzzle_result_desc_" .. nx_string(index))
  nx_execute("form_stage_main\\form_task\\form_puzzle_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "puzzle_confirm_return")
  local judged = false
  if res == "ok" then
    judged = true
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PUZZLE), nx_int(puzzle_custom_type_appraise), nx_int(index), nx_int(1))
  elseif res == "cancel" then
    judged = true
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PUZZLE), nx_int(puzzle_custom_type_appraise), nx_int(index), nx_int(0))
  end
  if judged == true and nx_is_valid(form) then
    form.btn_explain_puzzle.NormalImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_forbid.png"
    form.btn_explain_puzzle.FocusImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_forbid.png"
    form.btn_explain_puzzle.PushImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_forbid.png"
    form.btn_explain_puzzle.DisableImage = "gui\\special\\puzzle\\puzzle_task_judge_" .. nx_string(index) .. "_forbid.png"
  end
end
function on_btn_get_prize_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_PUZZLE), nx_int(puzzle_custom_type_prize), nx_int(form.PageMark - DRAMA_PUZZLE_MARK))
end
function on_btn_buy_task_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.PageIndex ~= 2 then
    return
  end
  local task_id = form.PageMark
  if task_id <= 0 then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local buy_task_info = taskmgr:GetBuyTaskMoney(nx_int(task_id))
  if table.getn(buy_task_info) ~= 2 then
    return
  end
  if buy_task_info[1] == 0 or buy_task_info[2] <= 0 then
    return
  end
  local dialog_tips = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_third_task", true, false)
  if not nx_is_valid(dialog_tips) then
    return
  end
  dialog_tips:ShowModal()
  local res_tips = nx_wait_event(100000000, dialog_tips, "third_confirm_return")
  if res_tips ~= "ok" then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local mgr = nx_value("CapitalModule")
  if not nx_is_valid(mgr) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_buy_task_dec_money")
  local switchmgr = nx_value("SwitchManager")
  if nx_is_valid(switchmgr) and switchmgr:CheckSwitchEnable(ST_FUNCTION_POINT_TO_BINDCARD) and mgr:CanDecCapital(4, nx_int64(buy_task_info[2])) then
    gui.TextManager:Format_SetIDName("ui_cost_yinpiao")
  end
  gui.TextManager:Format_AddParam(nx_int(buy_task_info[2]))
  local text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_THIRD_TASK), nx_int(0), nx_int(task_id))
end
function on_task_accepted_change(self, recordname, optype, row, clomn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("Task_Accepted") then
    return 0
  end
  if optype == "add" then
    return 0
  end
  if optype == "update" then
    local task_id = client_player:QueryRecord("Task_Accepted", row, accept_rec_id)
    if nx_number(clomn) == nx_number(accept_rec_status) then
      local flag = client_player:QueryRecord("Task_Accepted", row, accept_rec_status)
      if nx_number(flag) == nx_number(task_status_failed) then
        on_task_faild(task_id)
        return 1
      end
      if nx_number(flag) == nx_number(task_status_cansubmit) then
        on_task_complete(task_id)
        return 1
      end
      if nx_number(flag) == nx_number(task_status_isdoing) then
        on_task_doing(task_id)
        return 1
      end
    elseif nx_number(clomn) == nx_number(accept_rec_step) then
      on_schedule_change(task_id)
    end
  end
  if optype == "del" then
    on_task_del()
  end
  if optype == "clear" then
    on_task_del()
    return 0
  end
  return 1
end
function on_task_record_change(self, recordname, optype, row, clomn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("Task_Record") then
    return 0
  end
  if optype == "add" then
    return 0
  end
  if optype == "update" and (nx_number(clomn) == nx_number(task_rec_curnum) or nx_number(clomn) == nx_number(task_rec_curnum_ex)) then
    local task_id = client_player:QueryRecord("Task_Record", row, task_rec_id)
    on_schedule_change(task_id)
  end
  if optype == "del" then
    return 0
  end
  if optype == "clear" then
    return 0
  end
  return 1
end
function on_task_add(task_id)
  nx_pause(0.2)
  refresh_task_show(task_id, 1)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  taskmgr:DoHideRuleByTask(nx_int(task_id))
end
function on_task_del()
  local form_trace = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_task_trace", true, false)
  if nx_is_valid(form_trace) then
    nx_execute("form_stage_main\\form_task\\form_task_trace", "refresh_trace_info", form_trace)
  end
  local form = nx_value("form_stage_main\\form_task\\form_task_main")
  if nx_is_valid(form) then
    local mark = get_init_mark(form.PageIndex)
    show_all_info(form, form.PageIndex, mark)
  end
end
function on_task_complete(task_id)
  refresh_task_show(task_id, 2)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  taskmgr:DoHideRuleByTask(nx_int(task_id))
end
function on_task_submit(task_id)
  local task_path = g_task_submit_open_ui[task_id]
  if task_path == nil then
    return
  end
  local ui_path = g_task_submit_open_ui[task_id][1]
  if ui_path == nil or ui_path == "" then
    return
  end
  local helper_id = g_task_submit_open_ui[task_id][2]
  if helper_id ~= nil and helper_id ~= "" then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", helper_id)
    return
  end
  nx_execute("util_gui", "util_show_form", ui_path, true, false)
end
function on_task_faild(task_id)
  refresh_task_show(task_id, 2)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  taskmgr:DoHideRuleByTask(nx_int(task_id))
end
function on_task_doing(task_id)
  refresh_task_show(task_id, 2)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  taskmgr:DoHideRuleByTask(nx_int(task_id))
end
function on_schedule_change(task_id)
  refresh_task_show(task_id, 2)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  taskmgr:DoHideRuleByTask(nx_int(task_id))
end
function on_puzzle_record_change(self, recordname, optype, row, clomn)
  local form = nx_value("form_stage_main\\form_task\\form_task_main")
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("Puzzle_Record") then
    return 0
  end
  if optype == "update" then
    local rec_index = client_player:QueryRecord("Puzzle_Record", row, puzzle_rec_index)
    if form.PageIndex ~= 5 or form.PageMark ~= rec_index + DRAMA_PUZZLE_MARK then
      return
    end
    local rec_appraise = client_player:QueryRecord("Puzzle_Record", row, puzzle_rec_appraise)
    local puzzle_flag = client_player:QueryRecord("Puzzle_Record", row, puzzle_rec_flag)
    show_puzzle_task_info(form, form.PageMark)
  end
end
function on_entry(flag, server_time)
  nx_execute("form_stage_main\\form_task\\form_task_trace", "on_ready", flag, server_time)
end
function fresh_wuguan_npc_effect(npc_id)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local game_scene = game_client:GetScene()
  local table_client_obj = game_scene:GetSceneObjList()
  for i, npc_obj in pairs(table_client_obj) do
    if nx_is_valid(npc_obj) then
      local configID = npc_obj:QueryProp("ConfigID")
      if nx_string(configID) == nx_string(npc_id) then
        local visual_obj = game_visual:GetSceneObj(npc_obj.Ident)
        nx_execute("game_effect", "create_effect", "task_qiecuo", visual_obj, visual_obj, nx_string(npc_obj.Ident))
      end
    end
  end
end
function clear_tree_view(tree_view)
  if not nx_is_valid(tree_view) then
    return
  end
  local root_node = tree_view.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  local table_main_node = root_node:GetNodeList()
  for i, main_node in pairs(table_main_node) do
    main_node:ClearNode()
  end
  root_node:ClearNode()
end
function get_task_complete_state(task_id)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  local row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id), 0)
  if row < 0 then
    return -1
  end
  local flag = client_player:QueryRecord("Task_Accepted", row, accept_rec_status)
  return flag
end
function get_clone_config_info(task_id, cmd)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
  if task_row < 0 then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local scene_id = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_sceneid)
  for i, clone in pairs(g_clone_info) do
    if nx_number(scene_id) == nx_number(clone.scene) then
      if nx_number(cmd) == 0 then
        return clone.mark
      elseif nx_number(cmd) == 1 then
        return clone.ui
      elseif nx_number(cmd) == 2 then
        return clone.scenes
      end
    end
  end
  return ""
end
function check_drama_info(mark)
  local index = nx_int(mark / 1000000)
  if nx_number(index) == nx_number(1) or nx_number(index) == nx_number(4) then
    local round_flag = mark % 10
    if round_flag ~= 0 then
      return 2
    else
      return 1
    end
  elseif nx_number(index) == nx_number(9) then
    if nx_int(mark) == nx_int(CAN_ACCEPT_MARK) then
      return 0
    end
    if nx_int(mark / 100000) == nx_int(DRAMA_PUZZLE_MARK / 100000) then
      return 5
    end
    return 9
  elseif nx_number(index) == nx_number(task_line_wy_drama) or nx_number(index) == nx_number(task_line_mzyy_drama) or nx_number(index) == nx_number(task_line_jhjs_drama) or nx_number(index) == nx_number(task_line_xbqzj_drama) then
    local chapter_flag = mark / 100 % 10
    if chapter_flag ~= 0 then
      return 6
    end
  elseif is_city_task_line(index) or nx_number(index) == nx_number(task_line_city_zx) or nx_number(index) == nx_number(task_line_city_yl) then
    return 7
  else
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return 0
    end
    local row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(mark), 0)
    if row < 0 then
      return 0
    end
    local line = client_player:QueryRecord("Task_Accepted", row, accept_rec_line)
    if line == task_line_main or line == task_line_menpai then
      return 3
    elseif is_city_task_line(line) or nx_number(line) == nx_number(task_line_city_zx) or nx_number(line) == nx_number(task_line_city_yl) then
      return 7
    else
      return 4
    end
  end
  return 0
end
function get_init_mark(index)
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local scene_id = 0
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_scene = game_client:GetScene()
  if nx_is_valid(client_scene) then
    local gui = nx_value("gui")
    local config_id = client_scene:QueryProp("ConfigID")
    scene_id = taskmgr:GetSceneId(nx_string(config_id))
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local table_task = {}
  if index == 3 then
    table_task = taskmgr:GetTaskByType(index, scene_id)
  elseif index == 4 then
    local drama_name = client_player:QueryRecord("DramaRec", 0, 0)
    table_task = taskmgr:GetGuideTaskInfo(nx_string(drama_name))
  elseif index == 5 then
    local key = get_puzzle_init_mark()
    if key ~= 0 then
      return DRAMA_PUZZLE_MARK + key
    else
      return 0
    end
  else
    table_task = taskmgr:GetTaskByType(index, 0)
  end
  if table.getn(table_task) == 0 and nx_number(index) ~= nx_number(1) then
    return 0
  end
  if nx_number(index) == nx_number(2) then
    if table_task[1] ~= nil then
      return table_task[1]
    else
      return 0
    end
  elseif nx_number(index) == nx_number(3) then
    if nx_number(table_task[2]) == nx_number(1) then
      return CAN_ACCEPT_DRAMA_MARK + table_task[1]
    elseif nx_number(table_task[2]) == nx_number(4) then
      return CAN_ACCEPT_DRAMA_MARK + table_task[1]
    elseif nx_number(table_task[2]) == nx_number(5) then
      return CAN_ACCEPT_ZHIXIAN_MARK + table_task[1]
    end
  elseif nx_number(index) == nx_number(4) then
    if table_task[1] ~= nil then
      return CAN_ACCEPT_GUIDE_MARK + table_task[1]
    else
      return 0
    end
  end
  local main_id = 0
  local menpai_id = 0
  local city_id = 0
  local total = table.getn(table_task)
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    if line == task_line_main or line == task_line_wy_drama or line == task_line_mzyy_drama or line == task_line_jhjs_drama or line == task_line_xbqzj_drama then
      main_id = id
    elseif line == task_line_menpai then
      menpai_id = id
    elseif is_city_task_line(line) or line == task_line_city_zx or line == task_line_city_yl then
      city_id = id
    end
  end
  if main_id ~= 0 then
    return main_id
  end
  if menpai_id ~= 0 then
    return menpai_id
  end
  if city_id ~= 0 then
    return city_id
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local last_main_id = client_player:QueryProp("LastLineTask")
  local table_drama = taskmgr:GetDramaTaskInfo(nx_int(last_main_id))
  if table.getn(table_drama) ~= 5 then
    return 0
  end
  local line = table_drama[1]
  local drama_name = table_drama[2]
  local chapter = table_drama[3]
  local round = table_drama[4]
  local next_id = table_drama[5]
  if g_drama_node[drama_name] == nil then
    return 0
  end
  local drama_node_id = g_drama_node[drama_name].mark
  local round_node_id = drama_node_id + chapter * 100 + round
  return round_node_id
end
function get_puzzle_init_mark()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("Puzzle_Record") then
    return 0
  end
  local rows = client_player:GetRecordRows("Puzzle_Record")
  if rows <= 0 then
    return 0
  end
  local index = client_player:QueryRecord("Puzzle_Record", 0, 0)
  return index
end
function task_limit_info(task_id, cmd)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local task_row = player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
  if task_row < 0 then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return false
  end
  local cdtkmgr = nx_value("ConditionManager")
  if not nx_is_valid(cdtkmgr) then
    return false
  end
  local strLimit = ""
  if nx_number(cmd) == 0 then
    strLimit = player:QueryRecord("Task_Accepted", task_row, accept_rec_accept_limit)
  elseif nx_number(cmd) == 1 then
    strLimit = player:QueryRecord("Task_Accepted", task_row, accept_rec_submit_limit)
  end
  local table_limmit_desc = {}
  local table_limit = util_split_string(strLimit, ",")
  for i, limit_id in pairs(table_limit) do
    if not cdtkmgr:CanSatisfyCondition(player, player, nx_int(limit_id)) then
      local desc = gui.TextManager:GetText(cdtkmgr:GetConditionDesc(nx_int(limit_id)))
      table.insert(table_limmit_desc, nx_widestr(desc))
    end
  end
  if nx_number(cmd) == 0 then
    local isNeedVip = player:QueryRecord("Task_Accepted", task_row, accept_rec_vip)
    if nx_int(isNeedVip) > nx_int(0) then
      local player_vip = player:QueryProp("VipStatus")
      if nx_int(player_vip) == nx_int(0) then
        table.insert(table_limmit_desc, nx_widestr("not vip"))
        return false, table_limmit_desc
      end
    end
  end
  if 0 < table.getn(table_limmit_desc) then
    return false, table_limmit_desc
  end
  return true
end
function show_reputation_limit(form, task_id)
  if nx_number(task_id) <= 0 then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  form.imagegrid_rpt_limit.Visible = false
  form.imagegrid_rpt_limit:Clear()
  form.groupbox_rpt_limit.Visible = false
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
  if task_row < 0 then
    return
  end
  local strLimit = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_repute_limit)
  local table_limit = util_split_string(strLimit, ";")
  local index_base = 0
  for i, limit_value in pairs(table_limit) do
    local table_rpt = util_split_string(limit_value, "|")
    local rpt_name = table_rpt[1]
    local need_value = table_rpt[2]
    if g_rpt_limit[nx_string(rpt_name)] ~= nil and nx_int(need_value) > nx_int(0) then
      local flag_add = form.imagegrid_rpt_limit:AddItem(index_base, g_rpt_limit[nx_string(rpt_name)], nx_widestr(rpt_name), 1, 0)
      local back_flag = fasle
      local cur_value = 0
      local cur_level = 1
      local rows = client_player:FindRecordRow("Repute_Record", 0, nx_string(rpt_name), 0)
      if 0 <= rows then
        cur_value = client_player:QueryRecord("Repute_Record", rows, 1)
        cur_level = client_player:QueryRecord("Repute_Record", rows, 2)
        if nx_int(cur_value) < nx_int(need_value) then
          back_flag = true
        end
      else
        cur_value = 0
        cur_level = 1
        back_flag = true
      end
      if flag_add then
        if back_flag then
          form.imagegrid_rpt_limit:ChangeItemImageToBW(index_base, true)
        end
        local context1 = nx_string(cur_value) .. "/" .. nx_string(nx_int(need_value))
        context2 = "ui_" .. nx_string(rpt_name) .. "_" .. nx_string(cur_level)
        local context4 = "ui_" .. nx_string(rpt_name)
        local imagegrid = form.imagegrid_rpt_limit
        imagegrid:SetItemAddInfo(nx_int(index_base), nx_int(1), nx_widestr(context1))
        form.imagegrid_rpt_limit:SetItemAddInfo(index_base, nx_int(2), nx_widestr(util_text(cur_level)))
        form.imagegrid_rpt_limit:SetItemAddInfo(index_base, nx_int(3), nx_widestr(g_rpt_limit[nx_string(rpt_name)]))
        form.imagegrid_rpt_limit:SetItemAddInfo(index_base, nx_int(4), nx_widestr(util_text(context4)))
        form.pbar_repute.Maximum = nx_int(need_value)
        form.pbar_repute.Value = nx_int(cur_value)
        form.lbl_rpt_limit_info.Text = nx_widestr(util_text("ui_needrepute"))
        form.lbl_rpt_value.Text = nx_widestr(need_value)
        if nx_int(cur_value) < nx_int(need_value) then
          index_base = index_base + 1
        end
      end
    end
  end
  if 0 < index_base then
    form.groupbox_rpt_limit.Visible = true
  end
end
function get_scene_name(scene_id)
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return ""
  end
  local target_scene = map_query:GetSceneName(nx_string(scene_id))
  return target_scene
end
function get_scene_id(config_id)
  local ini = nx_execute("util_functions", "get_ini", "ini\\scenes.ini")
  if not nx_is_valid(ini) then
    return nx_int(-1)
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local id = ini:GetSectionByIndex(i)
    local config = ini:ReadString(i, "Config", "")
    if nx_string(config) == nx_string(config_id) then
      return nx_int(id)
    end
  end
  return nx_int(-1)
end
function get_drama_text(drama, chapter_id, round_id)
  local drama_rec = ""
  local gui = nx_value("gui")
  local drama_text = ""
  local drama_content_ini = nx_execute("util_functions", "get_ini", "share\\Drama\\DramaContent.ini")
  if not nx_is_valid(drama_content_ini) then
    return drama_text
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return drama_text
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return drama_text
  end
  local current_drama = ""
  local current_round = 0
  local current_section = 0
  if client_player:FindRecord("DramaRec") and 0 < client_player:GetRecordRows("DramaRec") then
    current_drama = client_player:QueryRecord("DramaRec", 0, 0)
  end
  if nx_string(drama) ~= current_drama then
    if client_player:FindRecord("SchoolDramaRec") and 0 < client_player:GetRecordRows("SchoolDramaRec") then
      current_drama = client_player:QueryRecord("SchoolDramaRec", 0, 0)
    end
    if nx_string(drama) == current_drama then
      drama_rec = "SchoolDramaRec"
    else
      return drama_text
    end
  else
    drama_rec = "DramaRec"
  end
  current_round = client_player:QueryRecord(drama_rec, 0, 2)
  current_section = client_player:QueryRecord(drama_rec, 0, 3)
  if round_id > current_round then
    return drama_text
  end
  local section_name = drama .. "-" .. nx_string(chapter_id) .. "-" .. nx_string(round_id)
  local sec_idx = drama_content_ini:FindSectionIndex(nx_string(section_name))
  if sec_idx < 0 then
    return drama_text
  end
  local section_num = drama_content_ini:GetSectionItemCount(sec_idx)
  if round_id < current_round then
    current_section = section_num
  end
  local round_text = drama .. "_" .. nx_string(chapter_id) .. "_" .. nx_string(round_id)
  drama_text = nx_widestr(gui.TextManager:GetText(round_text))
  drama_text = nx_widestr("        ") .. nx_widestr(util_text("ui_drama_round_" .. nx_string(round_id))) .. nx_widestr(" ") .. drama_text
  local sec_idx = drama_content_ini:FindSectionIndex(nx_string(section_name))
  if sec_idx < 0 then
    return drama_text
  end
  for count_1 = 1, current_section do
    local section_text = "desc_" .. drama_content_ini:GetSectionItemValue(sec_idx, count_1 - 1)
    drama_text = nx_widestr(drama_text) .. nx_widestr("<br>") .. nx_widestr(gui.TextManager:GetText(section_text))
  end
  return drama_text
end
function get_npc_inview()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local table_npc_inview = {}
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return table_npc_inview
  end
  local game_scene = game_client:GetScene()
  local table_client_obj = game_scene:GetSceneObjList()
  for i, client_obj in pairs(table_client_obj) do
    local obj_type = client_obj:QueryProp("Type")
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    if nx_is_valid(visual_obj) and nx_number(obj_type) == TYPE_NPC then
      table.insert(table_npc_inview, client_obj)
    end
  end
  return table_npc_inview
end
function check_effect_task(player, numCur, numNeed, task_id)
  if nx_number(numNeed) <= 0 then
    return false
  end
  if nx_number(numCur) >= nx_number(numNeed) then
    return false
  end
  local task_row = player:FindRecordRow("Task_Accepted", accept_rec_id, task_id, 0)
  if task_row < 0 then
    return false
  end
  local complete_flag = player:QueryRecord("Task_Accepted", task_row, accept_rec_status)
  return nx_number(complete_flag) ~= 1
end
function check_task_step(player, task_id, step)
  local task_row = player:FindRecordRow("Task_Accepted", accept_rec_id, task_id, 0)
  if task_row < 0 then
    return false
  end
  local cur_step = player:QueryRecord("Task_Accepted", task_row, accept_rec_step)
  if nx_number(cur_step) == nx_number(step) or nx_number(step) == 0 then
    return true
  end
  return false
end
function can_doing_task(player, task_id)
  if nx_number(task_id) <= 0 then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local task_row = client_player:FindRecordRow("Task_Accepted", accept_rec_id, nx_int(task_id))
  if task_row < 0 then
    return false
  end
  local strLimit = client_player:QueryRecord("Task_Accepted", task_row, accept_rec_repute_limit)
  if nx_string(strLimit) == "" then
    return true
  end
  local table_limit = util_split_string(strLimit, ";")
  local index_base = 0
  for i, limit_value in pairs(table_limit) do
    local table_rpt = util_split_string(limit_value, "|")
    local rpt_name = table_rpt[1]
    local need_value = table_rpt[2]
    if g_rpt_limit[nx_string(rpt_name)] ~= nil and nx_int(need_value) > nx_int(0) then
      local cur_value = 0
      local rows = client_player:FindRecordRow("Repute_Record", 0, nx_string(rpt_name), 0)
      if 0 <= rows then
        cur_value = client_player:QueryRecord("Repute_Record", rows, 1)
        if nx_int(cur_value) < nx_int(need_value) then
          return false
        end
      else
        return false
      end
    end
  end
  return true
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function get_puzzle_task_appraise(form, level, puzzle_flag)
  if not nx_is_valid(form) or puzzle_flag == 0 then
    return
  end
  form.lbl_puzzle_level.Visible = true
  form.lbl_puzzle_level2.Visible = true
  if nx_int(level) == nx_int(0) then
    form.lbl_puzzle_level.BackImage = "gui\\special\\puzzle\\puzzle_task_01.png"
    form.lbl_puzzle_level2.BackImage = "gui\\special\\puzzle\\puzzle_task_001.png"
  elseif nx_int(level) == nx_int(1) then
    form.lbl_puzzle_level.BackImage = "gui\\special\\puzzle\\puzzle_task_02.png"
    form.lbl_puzzle_level2.BackImage = "gui\\special\\puzzle\\puzzle_task_002.png"
  elseif nx_int(level) == nx_int(2) then
    form.lbl_puzzle_level.BackImage = "gui\\special\\puzzle\\puzzle_task_03.png"
    form.lbl_puzzle_level2.BackImage = "gui\\special\\puzzle\\puzzle_task_003.png"
  elseif nx_int(level) == nx_int(3) then
    form.lbl_puzzle_level.BackImage = "gui\\special\\puzzle\\puzzle_task_04.png"
    form.lbl_puzzle_level2.BackImage = "gui\\special\\puzzle\\puzzle_task_004.png"
  end
end
function clone_control(form, control_name, aid)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local control = nx_custom(form, nx_string(control_name))
  local new_control = gui.Designer:Clone(control)
  if not nx_is_valid(new_control) then
    return nx_null()
  end
  nx_bind_script(new_control, nx_current())
  new_control.DesignMode = false
  new_control.Name = string.format("%s_%s", nx_string(control_name), nx_string(aid))
  new_control.Visible = true
  new_control.aid = aid
  local child_list = control:GetChildControlList()
  for _, child_control in pairs(child_list) do
    if nx_is_valid(child_control) then
      local new_child = gui.Designer:Clone(child_control)
      new_child.fatherctl = new_control
      new_child.DesignMode = false
      new_child.Name = string.format("%s_%s", nx_string(child_control.Name), nx_string(aid))
      new_child.aid = aid
      new_control:Add(new_child)
    end
  end
  return new_control
end
function show_wywl_chapter_info(form, mark)
  if not nx_is_valid(form) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  form.mltbox_wy_drama_info:Clear()
  local gui = nx_value("gui")
  form.groupbox_wy_drama_info.Visible = true
  local chapter = mark / 100 % 10
  local drama_id = nx_int(mark / 10000) * 10000
  local drama_name = ""
  for name, content in pairs(g_drama_node) do
    if content.mark == drama_id then
      drama_name = name
      break
    end
  end
  local chapter_text_id = drama_name .. "_" .. nx_string(chapter)
  local chapter_image = chapter
  local chapter_node_desc = gui.TextManager:GetText(chapter_text_id)
  chapter_node_desc = nx_widestr("<font face=\"font_chapter\">") .. nx_widestr(chapter_node_desc) .. nx_widestr("</font>")
  chapter_node_desc = nx_widestr("<img src=\"gui\\language\\ChineseS\\task\\") .. nx_widestr(chapter_image) .. nx_widestr(".png\" data=\"\" />") .. nx_widestr(chapter_node_desc)
  form.mltbox_wy_drama_info:AddHtmlText(nx_widestr(chapter_node_desc), nx_int(0))
  local flag = drama_id / 1000000
  local table_chapter = {}
  if nx_int(flag) == nx_int(16) then
    table_chapter = taskmgr:GetWYDramaChapterInfo(chapter)
  elseif nx_int(flag) == nx_int(17) then
    table_chapter = taskmgr:GetMZYYDramaChapterInfo(chapter)
  elseif nx_int(flag) == nx_int(18) then
    table_chapter = taskmgr:GetJHJSDramaChapterInfo(chapter)
  elseif nx_int(flag) == nx_int(19) then
    table_chapter = taskmgr:GetXBQZJDramaChapterInfo(chapter)
  end
  if table.getn(table_chapter) ~= 3 then
    return
  end
  local content = table_chapter[2]
  local prize = table_chapter[3]
  form.mltbox_wy_drama_text:Clear()
  local chapter_content_desc = gui.TextManager:GetText(content)
  form.mltbox_wy_drama_text:AddHtmlText(nx_widestr(chapter_content_desc), nx_int(0))
  refresh_wy_prize_grid(form, prize)
end
function refresh_wy_prize_grid(form, prize)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local staticdatamgr = nx_value("data_query_manager")
  if not nx_is_valid(staticdatamgr) then
    return
  end
  form.wy_drama_chapter_reward:Clear()
  local item_lst = util_split_string(prize, ";")
  for i = 1, table.getn(item_lst) do
    local photo = ItemQuery:GetItemPropByConfigID(item_lst[i], "Photo")
    form.wy_drama_chapter_reward:AddItem(i - 1, photo, nx_widestr(item_lst[i]), 1, 0)
  end
end
function show_wy_drama_rbtn(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local main_id = 0
  local table_task = taskmgr:GetTaskByType(6, 0)
  local total = table.getn(table_task)
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    if line == task_line_wy_drama or line == task_line_mzyy_drama or line == task_line_jhjs_drama or line == task_line_xbqzj_drama then
      main_id = id
    end
  end
  local last_wy_taskid = client_player:QueryProp("LastLineTaskWY")
  local last_mzyy_taskid = client_player:QueryProp("LastLineTaskMZYY")
  local last_jhjs_taskid = client_player:QueryProp("LastLineTaskJHJS")
  local last_xbqzj_taskid = client_player:QueryProp("LastLineTaskXBQZJ")
  if main_id ~= 0 or last_wy_taskid ~= 0 or last_mzyy_taskid ~= 0 or last_jhjs_taskid ~= 0 or last_xbqzj_taskid ~= 0 then
    form.rbtn_wy_drama.Visible = true
  else
    form.rbtn_wy_drama.Visible = false
    form.groupbox_wy_drama.Visible = false
    form.groupbox_wy_drama_info.Visible = false
  end
end
function is_chapter_show(chapter, line)
  if nx_int(line) == nx_int(task_line_wy_drama) then
    local count = table.getn(g_show_wy_chapter)
    for i = 1, count do
      if chapter == g_show_wy_chapter[i] then
        return i
      end
    end
  elseif nx_int(line) == nx_int(task_line_mzyy_drama) then
    local count = table.getn(g_show_mzyy_chapter)
    for i = 1, count do
      if chapter == g_show_mzyy_chapter[i] then
        return i
      end
    end
  elseif nx_int(line) == nx_int(task_line_jhjs_drama) then
    local count = table.getn(g_show_jhjs_chapter)
    for i = 1, count do
      if chapter == g_show_jhjs_chapter[i] then
        return i
      end
    end
  elseif nx_int(line) == nx_int(task_line_xbqzj_drama) then
    local count = table.getn(g_show_xbqzj_chapter)
    for i = 1, count do
      if chapter == g_show_xbqzj_chapter[i] then
        return i
      end
    end
  end
  return 0
end
function on_wy_task_close(btn)
  local form = btn.ParentForm
  local mark = btn.select_mark
  local chapter = btn.chapter
  local line = btn.line
  local index = is_chapter_show(chapter, line)
  if 0 < index then
    if nx_int(line) == nx_int(task_line_wy_drama) then
      table.remove(g_show_wy_chapter, index)
    elseif nx_int(line) == nx_int(task_line_mzyy_drama) then
      table.remove(g_show_mzyy_chapter, index)
    elseif nx_int(line) == nx_int(task_line_jhjs_drama) then
      table.remove(g_show_jhjs_chapter, index)
    elseif nx_int(line) == nx_int(task_line_xbqzj_drama) then
      table.remove(g_show_xbqzj_chapter, index)
    end
  end
  show_wy_drama_tree(form, mark)
end
function on_wy_task_open(btn)
  local form = btn.ParentForm
  local mark = btn.select_mark
  local chapter = btn.chapter
  local line = btn.line
  local index = is_chapter_show(chapter, line)
  if index == 0 then
    if nx_int(line) == nx_int(task_line_wy_drama) then
      table.insert(g_show_wy_chapter, chapter)
    elseif nx_int(line) == nx_int(task_line_mzyy_drama) then
      table.insert(g_show_mzyy_chapter, chapter)
    elseif nx_int(line) == nx_int(task_line_jhjs_drama) then
      table.insert(g_show_jhjs_chapter, chapter)
    elseif nx_int(line) == nx_int(task_line_xbqzj_drama) then
      table.insert(g_show_xbqzj_chapter, chapter)
    end
  end
  show_wy_drama_tree(form, mark)
end
function show_city_rbtn(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local main_id = 0
  local table_task = taskmgr:GetTaskByType(7, 0)
  local total = table.getn(table_task)
  for i = 1, total, 2 do
    local id = table_task[i]
    local line = table_task[i + 1]
    if is_city_task_line(line) or line == task_line_city_zx or line == task_line_city_yl then
      main_id = id
    end
  end
  if main_id ~= 0 then
    form.rbtn_city.Visible = true
  else
    form.rbtn_city.Visible = false
    form.groupbox_city.Visible = false
    form.groupbox_city_info.Visible = false
  end
end
function is_city_task_line(task_line)
  for i = 1, table.getn(g_city_task_line) do
    if nx_number(task_line) == nx_number(g_city_task_line[i]) then
      return true
    end
  end
  return false
end
function is_city_main_task_show(line)
  for i = 1, table.getn(g_show_city_task_line) do
    if nx_number(line) == nx_number(g_show_city_task_line[i]) then
      return true
    end
  end
  return false
end
function on_city_main_title_click(lbl)
  local form = lbl.ParentForm
  local mark = lbl.select_mark
  local line = lbl.line
  if is_city_main_task_show(line) then
    local row = 0
    for i = 1, table.getn(g_show_city_task_line) do
      if nx_number(line) == nx_number(g_show_city_task_line[i]) then
        row = i
        break
      end
    end
    table.remove(g_show_city_task_line, row)
  else
    table.insert(g_show_city_task_line, line)
  end
  show_city_tree(form, mark)
end
function on_city_title_click(lbl)
  local form = lbl.ParentForm
  local mark = lbl.select_mark
  if g_show_city_maintask_line then
    g_show_city_maintask_line = false
  else
    g_show_city_maintask_line = true
  end
  show_city_tree(form, mark)
end
function on_city_sub_title_click(lbl)
  local form = lbl.ParentForm
  local mark = lbl.select_mark
  if g_show_city_subtask_line then
    g_show_city_subtask_line = false
  else
    g_show_city_subtask_line = true
  end
  show_city_tree(form, mark)
end
function on_city_yl_title_click(lbl)
  local form = lbl.ParentForm
  local mark = lbl.select_mark
  if g_show_city_yltask_line then
    g_show_city_yltask_line = false
  else
    g_show_city_yltask_line = true
  end
  show_city_tree(form, mark)
end
