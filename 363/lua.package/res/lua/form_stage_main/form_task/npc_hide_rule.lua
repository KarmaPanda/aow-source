require("util_gui")
require("custom_sender")
require("util_functions")
require("define\\object_type_define")
require("share\\view_define")
require("form_stage_main\\form_task\\task_define")
require("share\\npc_type_define")
local g_hide_list = {
  [1] = {
    id = "WorldNpc00009",
    taskid = 24002,
    state = 3
  },
  [2] = {
    id = "WorldNpc00009",
    taskid = 24002,
    state = 2
  },
  [3] = {
    id = "WorldNpc00009",
    taskid = 24002,
    state = 0
  },
  [4] = {
    id = "WorldNpc00011",
    taskid = 24019,
    state = 3
  },
  [5] = {
    id = "WorldNpc00011",
    taskid = 24019,
    state = 2
  },
  [6] = {
    id = "WorldNpc00011",
    taskid = 24019,
    state = 0
  },
  [8] = {
    id = "WorldNpc00383",
    taskid = 38053,
    state = 2
  },
  [9] = {
    id = "WorldNpc00383",
    taskid = 38053,
    state = 3
  },
  [10] = {
    id = "WorldNpc00201",
    taskid = 38132,
    state = 3
  },
  [11] = {
    id = "WorldNpc09601",
    taskid = 24227,
    state = 0
  },
  [12] = {
    id = "WorldNpc09601",
    taskid = 24227,
    state = 2
  },
  [13] = {
    id = "WorldNpc06642",
    taskid = 24335,
    state = -1
  },
  [14] = {
    id = "funnpcclone003108",
    taskid = 2102,
    state = -1
  },
  [15] = {
    id = "WorldNpc06133",
    taskid = 38443,
    state = 0
  },
  [16] = {
    id = "WorldNpc06133",
    taskid = 38443,
    state = 2
  },
  [17] = {
    id = "WorldNpc06133",
    taskid = 38443,
    state = 3
  },
  [18] = {
    id = "funnpcclone003108",
    taskid = 2102,
    state = 0
  },
  [19] = {
    id = "funnpcclone003108",
    taskid = 2102,
    state = 1
  },
  [20] = {
    id = "funnpcclone003108",
    taskid = 2102,
    state = 2
  },
  [21] = {
    id = "WorldNpc06664",
    taskid = 44255,
    state = 3
  },
  [22] = {
    id = "WorldNpc06667",
    taskid = 44256,
    state = -1
  },
  [23] = {
    id = "WorldNpc02044",
    taskid = 40547,
    state = 2
  },
  [24] = {
    id = "WorldNpc02044",
    taskid = 40547,
    state = 3
  },
  [25] = {
    id = "WorldNpc00141",
    taskid = 30013,
    state = 3
  },
  [26] = {
    id = "WorldNpc00156",
    taskid = 30042,
    state = 3
  },
  [27] = {
    id = "fhpynpc069",
    taskid = 30566,
    state = -1
  },
  [28] = {
    id = "fhpynpc069",
    taskid = 30573,
    state = 0
  },
  [29] = {
    id = "fhpynpc069",
    taskid = 30573,
    state = 2
  },
  [30] = {
    id = "fhpynpc069",
    taskid = 30573,
    state = 3
  },
  [31] = {
    id = "WorldNpc05840",
    taskid = 30131,
    state = 3
  },
  [32] = {
    id = "WorldNpc01749",
    taskid = 30092,
    state = 3
  },
  [33] = {
    id = "FunnpcClone021018",
    taskid = 3018,
    state = 2
  },
  [34] = {
    id = "WorldNpc09413",
    taskid = 34499,
    state = 2
  },
  [35] = {
    id = "WorldNpc09413",
    taskid = 34499,
    state = 3
  },
  [36] = {
    id = "World_qy_tangmen131_heiyiren1",
    taskid = 18206,
    state = 0
  },
  [37] = {
    id = "World_qy_tangmen131_heiyiren1",
    taskid = 18206,
    state = 3
  },
  [38] = {
    id = "WorldNpc00171",
    taskid = 24044,
    state = -1
  },
  [39] = {
    id = "WorldNpc00171",
    taskid = 24044,
    state = 3
  },
  [40] = {
    id = "WorldNpc00171",
    taskid = 24044,
    state = 1
  },
  [41] = {
    id = "WorldNpc00171",
    taskid = 24044,
    state = 2
  },
  [43] = {
    id = "WorldNpc00694",
    taskid = 22023,
    state = 2
  },
  [44] = {
    id = "WorldNpc00694",
    taskid = 22023,
    state = 3
  },
  [45] = {
    id = "WorldNpc03125",
    taskid = 44025,
    state = 3
  },
  [46] = {
    id = "WorldNpc03126",
    taskid = 44031,
    state = -1
  },
  [47] = {
    id = "WorldNpc03126",
    taskid = 44038,
    state = 3
  },
  [48] = {
    id = "WorldNpc10748",
    taskid = 28038,
    state = -1
  },
  [49] = {
    id = "WorldNpc00950",
    taskid = 22044,
    state = 3
  },
  [50] = {
    id = "WorldNpc00974",
    taskid = 80600,
    state = -1
  },
  [51] = {
    id = "WorldNpc00973",
    taskid = 22044,
    state = -1
  },
  [52] = {
    id = "WorldNpc00973",
    taskid = 22044,
    state = 2
  },
  [53] = {
    id = "WorldNpc00973",
    taskid = 22044,
    state = 3
  },
  [54] = {
    id = "WorldNpc00473",
    taskid = 38006,
    state = 0
  },
  [55] = {
    id = "WorldNpc00473",
    taskid = 38006,
    state = 1
  },
  [56] = {
    id = "WorldNpc03372",
    taskid = 46026,
    state = 3
  },
  [57] = {
    id = "WorldNpc02684",
    taskid = 40041,
    state = 3
  },
  [58] = {
    id = "WorldNpc02766",
    taskid = 40041,
    state = -1
  },
  [59] = {
    id = "WorldNpc03826",
    taskid = 48010,
    state = 2
  },
  [60] = {
    id = "WorldNpc03826",
    taskid = 48010,
    state = 3
  },
  [61] = {
    id = "WorldNpc04524",
    taskid = 48010,
    state = 3
  },
  [62] = {
    id = "WorldNpc03820",
    taskid = 48015,
    state = 3
  },
  [63] = {
    id = "JlgNpc196",
    taskid = 48017,
    state = -1
  },
  [64] = {
    id = "JlgNpc196",
    taskid = 48018,
    state = 3
  },
  [65] = {
    id = "JlgNpc193",
    taskid = 48022,
    state = -1
  },
  [66] = {
    id = "JlgNpc193",
    taskid = 48023,
    state = 3
  },
  [67] = {
    id = "Gather0042yl",
    taskid = 48021,
    state = 3
  },
  [68] = {
    id = "JlgNpc198",
    taskid = 48024,
    state = -1
  },
  [69] = {
    id = "WorldNpc04371",
    taskid = 42020,
    state = -1
  },
  [70] = {
    id = "WorldNpc04371",
    taskid = 42020,
    state = 0
  },
  [71] = {
    id = "WorldNpc04294",
    taskid = 42026,
    state = -1
  },
  [72] = {
    id = "WorldNpc04294",
    taskid = 42026,
    state = 0
  },
  [73] = {
    id = "WorldNpc04284",
    taskid = 42026,
    state = 3
  }
}
local g_obj_list = {}
function is_npc_hide(npc_id)
  for index, rule in pairs(g_hide_list) do
    if nx_string(rule.id) == nx_string(npc_id) then
      local task_state = get_task_state_by_npc(rule.taskid)
      if nx_number(task_state) == nx_number(rule.state) then
        return true
      end
    end
  end
  return false
end
function get_task_state_by_npc(task_id)
  local state_flag = nx_execute("form_stage_main\\form_task\\form_task_main", "get_task_complete_state", task_id)
  if nx_number(state_flag) >= 0 then
    return state_flag
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return -1
  end
  local complete_flag = taskmgr:CompletedByRec(nx_string(task_id))
  if nx_number(complete_flag) == 1 then
    return 3
  else
    return -1
  end
end
function do_hide_rule(id, type)
  local table_npc = {}
  if nx_number(type) == 1 then
    for index, rule in pairs(g_hide_list) do
      if nx_string(rule.id) == nx_string(id) then
        table.insert(table_npc, nx_string(id))
        break
      end
    end
  elseif nx_number(type) == 2 then
    for index, rule in pairs(g_hide_list) do
      if nx_string(rule.taskid) == nx_string(id) then
        local IsSave = false
        for i, npcid in pairs(table_npc) do
          if nx_string(rule.id) == nx_string(npcid) then
            IsSave = true
            break
          end
        end
        if not IsSave then
          table.insert(table_npc, nx_string(rule.id))
        end
      end
    end
  end
  for i, npcid in pairs(table_npc) do
    if is_npc_hide(npcid) then
      remove_npc(npcid)
    else
      add_npc(npcid)
    end
  end
end
function remove_npc(npc_id)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local game_scene = game_client:GetScene()
  local scene = nx_value("game_scene")
  local terrain = scene.terrain
  local table_client_obj = game_scene:GetSceneObjList()
  for i, client_obj in pairs(table_client_obj) do
    if client_obj:FindProp("ConfigID") then
      local id = client_obj:QueryProp("ConfigID")
      if nx_string(id) == nx_string(npc_id) then
        update_hide_obj_list(1, npc_id, client_obj.Ident)
        local scene_obj = nx_value("scene_obj")
        scene_obj:RemoveObject(client_obj.Ident)
      end
    end
  end
end
function add_npc(npc_id)
  local ident = update_hide_obj_list(0, npc_id)
  if nx_string(ident) ~= "" then
    local scene_obj = nx_value("scene_obj")
    scene_obj:AddObject(nx_string(ident))
  end
end
function update_hide_obj_list(cmd, npc_id, obj_id)
  for i, obj in pairs(g_obj_list) do
    if nx_string(obj.id) == nx_string(npc_id) then
      local ident = nx_string(obj.ident)
      table.remove(g_obj_list, i)
      if nx_number(cmd) == 0 then
        local game_client = nx_value("game_client")
        local game_visual = nx_value("game_visual")
        local game_scene = game_client:GetScene()
        local table_client_obj = game_scene:GetSceneObjList()
        for i, client_obj in pairs(table_client_obj) do
          local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
          if nx_is_valid(visual_obj) and nx_string(client_obj.Ident) == nx_string(ident) then
            return ""
          end
        end
        return ident
      end
    end
  end
  if nx_number(cmd) == 1 then
    table.insert(g_obj_list, {
      id = nx_string(npc_id),
      ident = nx_string(obj_id)
    })
  end
  return ""
end
