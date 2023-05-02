TASK_TYPE_INI = "ini\\Task\\task_type.ini"
TASK_CONFIG_INI = "ini\\Task\\task_config.txt"
TOOL_ITEM_INI = "ini\\Item\\tool_item.ini"
MAIN = "main"
FURTHER = "further"
TASK = "task"
MONSTER = "monster"
TOOL = "tool"
PATH = "path"
SPLIT_CHAR = ";"
SPLIT_CHAR_1 = "|"
MONSTER_COL_COUNT = 3
MONSTER_COL_WIDTH = 114
MONSTER_BACK_COLOR = "255,168,172,180"
MONSTER_HEAD_COLOR = "255,65,75,86"
MONSTER_SELECT_COLOR = "255,113,88,18"
TOOL_COL_COUNT = 3
TOOL_COL_WIDTH = 114
TOOL_BACK_COLOR = "255,168,172,180"
TOOL_HEAD_COLOR = "255,65,75,86"
TOOL_SELECT_COLOR = "255,113,88,18"
PICTURE_WIDTH = 50
PICTURE_HEIGHT = 50
EDIT_COLOR = "255,65,75,86"
GRID_COL_WIDTH = 140
SUBFUNCTION_BACK_COLOR = "255,168,172,180"
SUBFUNCTION_HEAD_COLOR = "255, 65,75,86"
SUBFUNCTION_SELECT_COLOR = "255,113,88,18"
ID_FORE_COLOR = "255, 255, 0, 0"
type_list_key = {
  "hunter",
  "collect",
  "interact",
  "story",
  "question",
  "useitem",
  "convoy",
  "questiongroup",
  "choose",
  "special"
}
type_list = {
  hunter = {
    [1] = "HuntList",
    [2] = "\180\242\176\220{@npc}",
    [3] = "\193\212\201\177\177\237"
  },
  collect = {
    [1] = "CollectList",
    [2] = "\180\211{@npc}\201\237\201\207\202\213\188\175{@item}",
    [3] = "\178\201\188\175\177\237"
  },
  interact = {
    [1] = "InteractiveList",
    [2] = "\211\235{@npc}\189\187\204\184",
    [3] = "\189\187\187\165\177\237"
  },
  story = {
    [1] = "StoryTaskList",
    [2] = "\204\253{@npc}\189\178\185\202\202\194",
    [3] = "\185\202\202\194\192\224"
  },
  question = {
    [1] = "Question",
    [2] = "\187\216\180\240{@npc}\181\196\206\202\204\226",
    [3] = "\180\240\204\226\177\237"
  },
  useitem = {
    [1] = "UseItemList",
    [2] = "\184\248{@npc}\211\195{@item}",
    [3] = "\202\185\211\195\181\192\190\223\177\237"
  },
  convoy = {
    [1] = "Convoy",
    [2] = "\187\164\203\205{@npc}",
    [3] = "\187\164\203\205\177\237"
  },
  questiongroup = {
    [1] = "questiongroup",
    [3] = "\204\226\191\226\177\237"
  },
  choose = {
    [1] = "Choose",
    [3] = "\209\161\212\241\177\237"
  },
  special = {
    [1] = "Special",
    [3] = "\204\216\202\226\177\237"
  }
}
LABEL_HEIGHT = 30
LABEL_BACK_COLOR = "255,96,160,116"
LABEL_FORE_COLOR = "255,255,255,255"
GRID_COUNT = 4
GRID_HEADER_COLOR = "255, 134, 143, 152"
GRID_BACK_COLOR = "255, 134, 143, 152"
GRID_FORE_COLOR = "255, 0, 0, 0"
GRID_DEFAULT_BTN_WIDTH = 65
GROUPBOX_HEIGHT = 80
GROUPBOX_BACKCOLOR = "255, 0, 0, 0"
EDIT_HEIGHT = 80
EDIT_BACKCOLOR = "255,168,172,180"
RICHEDIT_HEIGHT = 80
RICHEDIT_VIEW_TABLE = {
  default = "5, 5, 324, 60",
  TaskTargetId = "5, 5, 324, 30"
}
RICHEDIT_BACKCOLOR = "255,168,172,180"
SPLIT_DISTANCE = 30
NOT_VALID = -1
ADD = 0
DELETE = 1
NEWEST = 2
MODIFY = 3
NONE = 4
LOCKED = 5
CONFLICT = 6
SVN_LIST = {
  "map\\mdl\\edit_helper\\tex\\task\\add.png",
  "map\\mdl\\edit_helper\\tex\\task\\delete.png",
  "map\\mdl\\edit_helper\\tex\\task\\newest.png",
  "map\\mdl\\edit_helper\\tex\\task\\modify.png",
  "map\\mdl\\edit_helper\\tex\\task\\none.png",
  "map\\mdl\\edit_helper\\tex\\task\\locked.png"
}
README_TXT = "editor\\ini\\readme.txt"
HELP_SECT_NAME = "\202\185\211\195\203\181\195\247"
QUESTION_SECT_NAME = "\179\163\188\251\206\202\204\226\189\226\180\240"
ADD_SAME_ID_BTN_TITLE = "\212\246\188\211"
DELETE_SAME_ID_BTN_TITLE = "\201\190\179\253"
INTERVAL = "   "
ADD_NEW_QUESTION_BTN_TITLE = "\212\246\188\211\207\194\184\246\206\202\204\226"
DELETE_LAST_QUESTION_BTN_TITLE = "\201\190\179\253\201\207\184\246\206\202\204\226"
ADD_NEW_ANSWER_BTN_TITLE = "\212\246\188\211\207\194\184\246\180\240\176\184"
DELETE_LAST_ANSWER_BTN_TITLE = "\201\190\179\253\201\207\184\246\180\240\176\184"
LANGUAGE_FILE_LIST = {
  "text\\ChineseS\\stringtask_normal.idres",
  "text\\ChineseS\\stringtask_special.idres"
}
SEARCHID_BEGIN = "s"
COMMON_NPC = "ini\\Npc\\NpcConfig\\common_npc.ini"
DEFAULT_PARAMS_SETTING = "ini\\Task\\DefaultParamsSetting.ini"
TALK_OBJ_TYPE = {
  AcceptDialogId = {"npc", "\205\230\188\210"},
  CanAcceptMenu = {"\205\230\188\210"},
  CompleteDialogId = {"npc", "\205\230\188\210"},
  CompleteMenu = {"\205\230\188\210"},
  QiecuoTitle = {"npc"},
  QiecuoMenu = {"\205\230\188\210"},
  DialogID = {"npc"},
  OkMenu = {"\205\230\188\210"},
  contextId = {"npc"},
  titleId = {"\205\230\188\210"},
  LeaveTextID = {"\205\230\188\210"},
  MainText = {"npc"},
  ZZAnswerText1 = {"\205\230\188\210"},
  ZZAnswerText2 = {"\205\230\188\210"},
  ZZAnswerText3 = {"\205\230\188\210"},
  TalkID = {"NPC"},
  Default = {"\196\172\200\207"}
}
LABEL_WIDTH = 50
SPLIT_LINE = "<br/>----------------<br/>"
NPC_TYPE_INI = "ini\\Npc\\NpcConfig\\npc_type.ini"
TEST_CASE_TXT = "ini\\Task\\Task\\test_case.txt"
TASK_TEXT_TXT = "ini\\Task\\Task\\task_text.txt"
HUNTER_TEXT_TXT = "ini\\Task\\Task\\hunter_text.txt"
COLLECT_TEXT_TXT = "ini\\Task\\Task\\collect_text.txt"
CONVOY_TEXT_TXT = "ini\\Task\\Task\\convoy_text.txt"
INTERACTIVE_TEXT_TXT = "ini\\Task\\Task\\interact_text.txt"
USEITEM_TEXT_TXT = "ini\\Task\\Task\\useitem_text.txt"
STORY_TEXT_TXT = "ini\\Task\\Task\\story_text.txt"
QUESTION_TEXT_TXT = "ini\\Task\\Task\\question_text.txt"
QUESTIONS_TEXT_TXT = "ini\\Task\\Task\\questions_text.txt"
DEFAULT_QUICK_BUTTON_COLOR = "255,143,214,239"
