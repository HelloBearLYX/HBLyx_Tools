local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhCN")
if not L then return end

L["Welecome"] = "|cff8788ee" .. ADDON_NAME .. "|r: 欢迎! 你的配置已经被重置, 你可以在: ESC-选项-插件-|cff8788ee" .. ADDON_NAME .. "|r里更改设置"
L["WelecomeInfo"] = "欢迎! 感谢你使用|cff8788ee" .. ADDON_NAME .. "|r!"
L["WelecomeSetting"] = "你可以使用 \"|cff8788ee/hblyx|r\" 命令或在 ESC-选项-插件-|cff8788ee" .. ADDON_NAME .. "|r 中打开配置面板来更改设置"
L["WarlockWelecome"] = "你好,|cff8788ee术士|r大人,本恶魔随时为你服务!"
L["GUITitle"] = "|cff8788ee" .. ADDON_NAME .. "|r配置面板"
L["Notifications"] = "通知"
L["NotificationContent"] = "选项界面中的标签页显示了本插件包含的模块, 你可以分别配置每个模块" .. "\n\n" ..
"你可以在|cff8788eeHBLyx|r的CurseForge页面里找到:" .. "\n" ..
"|cff8788eeHBLyx_Tools|r: 一个包含战斗指示器, 战斗计时器, 焦点打断以及更多模块的集合" .. "\n" ..
"|cff8788eeMidnightFocusInterrupt|r: 焦点打断模块的独立版本" .. "\n" ..
"|cff8788eeSharedMedia_HBLyx|r: 一个AI生成的中文语音素材包(LibSharedMedia)"

--MARK: Issues
L["Issues"] = "问题"
L["AnyIssues"] = "如果你遇到任何问题, 请通过联系方式向插件作者反馈"
L["IssuesContent"] = "Q:焦点打断模块是否会有目标版本?\nA:暂时不考虑,目标施法条因为和其他插件提供的功能过于重复" .. "\n\n" ..
"Q:能否在焦点打断模块中添加XXX技能作为打断技能?\nA: 不能,由于暴雪的API限制,带有GCD的技能无法添加。若你想添加一个无GCD的技能,请告知我(提供技能详情)" .. "\n\n" ..
"Q:战复计时器在部分Beta大秘境开始时无法正确显示,必须重载,这是为什么?\nA: 这是暴雪部分副本的大秘境开始事件(CHALLENGE_MODE_START)没有正确触发导致的,目前没有好的解决方法,只能等暴雪修复了"

-- MARK: Contact
L["Contact"] = "联系方式"
L["GitHub"] = "在GitHub提交问题"
L["CurseForge"] = "在CurseForge发表评论"

-- MARK: Sound Channel
L["SoundChannelSettings"] = "声音通道"
L["SoundChannel"] = {
	Master = "主音量",
	SFX = "效果",
	Music = "音乐",
	Ambience = "环境音",
	Dialog = "对话",
}

-- MARK: Config
L["Test"] = "测试/解锁(拖动移动)"
L["Mute"] = "静音"
L["Enable"] = "启用"
L["SoundSettings"] = "声音设置"
L["PetSettings"] = "宠物提醒设置"
L["PetStanceEnable"] = "启用宠物姿态检查"
L["PetTypeSettings"] = "启用宠物类型检查"
L["FadeTime"] = "淡入/淡出时间"
L["IconSize"] = "图标大小"
L["BackgroundAlpha"] = "背景透明度"
L["Texture"] = "材质"
L["Width"] = "宽度"
L["Height"] = "高度"
L["Sound"] = "音效"
L["TimeFontScale"] = "时间大小缩放"
L["StackFontSize"] = "层数/充能字体大小"
L["Reminders"] = "提醒"
L["Ready"] = "就绪"
L["NotLearned"] = "尚未学习"
L["Reload"] = "重载(RL)"
L["ReloadNeeded"] = "需要重载(Reload)才能使更改生效"
L["IconZoom"] = "图标缩放"
L["ResetMod"] = "重置本模块"
L["ComfirmResetMod"] = "您确定要重置此模块的所有设置吗?(同时重载)"
L["Anchor"] = "锚点"
L["Grow"] = "成长方向"
L["General"] = "综合"
L["Profile"] = "配置文件"
L["Export"] = "导出"
L["Import"] = "导入"
L["ProfileSettingsDesc"] = "使用下面的字符串导出和导入你的配置文件\n\n导出的字符串包含了所有模块的设置"
L["ImportSuccess"] = "配置文件导入成功,请重载界面以应用更改"
L["ModuleProfile"] = "模块配置文件"
L["ModuleProfileDesc"] = "你可以选择一个模块来单独导出/导入配置文件\n\n导出时先在下面选择模块,导入时字符串会自动识别模块"
L["SelectModule"] = "选择模块"

-- MARK: Style
L["StyleSettings"] = "样式设置"
L["Font"] = "字体"
L["FontSize"] = "字体大小"
L["FontSettings"] = "字体设置"
L["X"] = "水平位置"
L["Y"] = "垂直位置"
L["PositionSettings"] = "位置设置"
L["IconSettings"] = "图标设置"
L["TextureSettings"] = "材质设置"
L["SizeSettings"] = "大小设置"
L["ColorSettings"] = "颜色设置"
L["TextSettings"] = "文字设置"
L["InterruptibleColor"] = "可打断颜色"
L["NotInterruptibleColor"] = "不可打断颜色"

-- MARK: Constants
L["PetFamily"] = {
Felguard = "恶魔卫士",
Felhunter = "地狱猎犬",
Imp = "小鬼",
WRONG = "宝宝错误!",
}
L["PetStance"] = {
ASSIST = "",
DEFENSIVE = "防御姿态",
PASSIVE = "被动姿态",
}

-- MARK: Default values
-- combat indicator
L["CombatInSoundDefault"] = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\in-combat_chinese.ogg"
L["CombatOutSoundDefault"] = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\out-combat_chinese.ogg"
L["CInText"] = "进入战斗文字"
L["COutText"] = "脱离战斗文字"
L["CombatInText"] = "进入战斗"
L["CombatOutText"] = "脱离战斗"
-- combat timer
L["TimerPrintTextIntro"] = "本次战斗: "
-- focus interrupt
L["FocusDefaultSound"] = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Media\\kick_chinese.ogg"
-- warlock reminders
L["PetMissingText"] = "没宝宝!"
L["CandyMissingText"] = "没糖了!"

--MARK: Combat Indicator
L["CombatSettings"] = "战斗指示器"
L["CombatSettingsDesc"] = "在进入/脱离战斗时显示一个文字提示"
L["CombatIndicatorTextDesc"] = "进入/脱离战斗时显示的文字"
-- combat indicator style settings
L["CombatInColor"] = "进入战斗文字颜色"
L["CombatOutColor"] = "脱离战斗文字颜色"
-- combat indicator sound settings
L["CombatInSoundMedia"] = "进入战斗声音"
L["CombatOutSoundMedia"] = "脱离战斗声音"

-- MARK: Combat Timer
L["TimerSettings"] = "战斗计时器"
L["TimerSettingsDesc"] = "显示一个战斗时长的计时器(MM:SS)"
L["TimerCombatShow"] = "只在战斗中显示"
L["TimerPrintEnabled"] = "打印到聊天框"

-- MARK: Focus Interrupt
L["FocusInterruptSettings"] = "焦点打断"
L["FocusInterruptSettingsDesc"] = "焦点打断警报与焦点施法条设置"
L["Interrupted"] = "被打断"
L["InterruptedColor"] = "被打断颜色"
-- Focus Cast Bar Settings
L["FocusCastBarHidden"] = "隐藏焦点施法条"
L["FocusColorPriorityDesc"] = "不可打断颜色 > 可打断颜色 > 打断未就绪颜色"
L["ShowTotalTime"] = "显示总时间"
-- Focus Interrupt Settings
L["FocusInteruptSettings"] = "焦点打断设置"
L["FocusInterruptCooldownFilter"] = "打断技能未就绪时隐藏"
L["FocusInterruptNotReadyColor"] = "打断未就绪颜色"
L["FocusInterruptibleFilter"] = "不可打断时隐藏"
L["FocusMuteDesc"] = "基于暴雪的限制(02/06/2026), 打断音效任然会任意施法时播放\n\n建议不使用音效(本模块包含多种视觉上的焦点施法过滤)"
L["InterruptedFadeTime"] = "被打断淡出时间"
L["ShowInterrupter"] = "显示打断者"
L["ShowTarget"] = "显示目标"
L["InterruptedSettings"] = "被打断设置"
L["InterruptedSettingsDesc"] = "当焦点被打断时, 施法条会有一个短暂的淡出时间, 你可以将淡出时间设置为0来让它立即消失.\n\n同时, 在淡出时间内会显示一些信息"
L["InterruptIconsSettings"] = "打断图标设置"
L["InterruptIconDesc"] = "在可以打断的时候(可打断+打断就绪)的情况下,显示打断图标\n\n主要为恶魔术提供,在可打断时显示哪个打断可用"
L["ShowDemoWarlockOnly"] = "只为恶魔术显示"

-- MARK: BattleRes
L["BattleResSettings"] = "战复计时器"
L["BattleResSettingsDesc"] = "显示战复的冷却和充能"
L["HideInactive"] = "未激活时隐藏"

--MARK: Warlock
L["WarlockReminders"] = "|cff8788ee术士|r提醒"
L["WarlockRemindersIntro"] = "本恶魔提供宠物和治疗石的提醒\n\n当缺失宠物/治疗石(或者宠物姿态/类型错误)时会显示"
-- Warlock Pet settings
L["PetTypeSettingsDesc"] = "恶魔卫士检查用于恶魔天赋, 地狱猎犬/小鬼检查用于其他天赋"
L["FelguardEnable"] = "启用恶魔卫士检查"
L["FelhunterEnable"] = "启用地狱猎犬/小鬼检查"
-- Warlock Candy settings
L["CandySetting"] = "治疗石提醒设置"

-- MARK: ChallengeEnhance
L["ChallengeEnhanceSettings"] = "大秘境面板增强"
L["ChallengeEnhanceSettingsDesc"] = "在M+面板上显示分数、地下城名称以及可点击的M+地下城传送门"
L["ChallengeEnhanceLevelSettings"] = "最高层数设置"
L["ChallengeEnhanceScoreSettings"] = " 分数设置"
L["ChallengeEnhanceNameSettings"] = "名称设置"
-- current season
L["AA"] = "艾杰斯亚学院"
L["MT"] = "魔导师平台"
L["MC"] = "迈萨拉洞窟"
L["NPX"] = "节点希纳斯"
L["PS"] = "萨隆矿坑"
L["ST"] = "执政团之座"
L["Skyreach"] = "通天峰"
L["WS"] = "风行者之塔"
-- pre-patch
L["ARAK"] = "回响之城"
L["TD"] = "破晨号"
L["ED"] = "生态圆顶"
L["HOA"] = "赎罪大厅"
L["OF"] = "水闸行动"
L["PSF"] = "圣焰隐修院"
L["GAMBIT"] = "宏图"
L["STREET"] = "天街"