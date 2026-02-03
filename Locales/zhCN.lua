local ADDON_NAME, addon = ...
local L = LibStub("AceLocale-3.0"):NewLocale(ADDON_NAME, "zhCN")
if not L then return end

L["Welecome"] = "|cff8788ee" .. ADDON_NAME .. "|r: 欢迎! 你的配置已经被重置, 你可以在: ESC-选项-插件-|cff8788ee" .. ADDON_NAME .. "|r里更改设置"
L["WelecomeSetting"] = "you can change settings in ESC-Options-AddOns-|cff8788ee" .. ADDON_NAME .. "|r"
L["WelecomeSetting"] = "你可以在:ESC-选项-插件-|cff8788ee" .. ADDON_NAME .. "|r里更改设置"
L["WarlockWelecome"] = "你好,|cff8788ee术士|r大人,本恶魔随时为你服务!"

-- MARK: Config
L["Test"] = "测试"
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
L["HidenInactive"] = "不活跃时隐藏"
L["TimeFontSize"] = "时间字体大小"
L["TimeFontScale"] = "时间大小缩放"
L["StackFontSize"] = "层数/充能字体大小"
L["Reminders"] = "提醒"
L["Ready"] = "就绪"
L["NotLearned"] = "尚未学习"
L["Reload"] = "重载(RL)"
L["ReloadDesc"] = "重载(Reload)若改变"
L["ReloadNeeded"] = "需要重载(Reload)才能使更改生效"
L["ResetModule"] = "你确认你要|cffC41E3A重置此模块|r吗?"
L["IconZoom"] = "图标缩放"
L["ResetMod"] = "重置本模块"
L["ComfirmResetMod"] = "您确定要重置此模块的所有设置吗?(同时重载)"

-- MARK: Style
L["StyleSettings"] = "样式设置"
L["Font"] = "字体"
L["FontSize"] = "字体大小"
L["X"] = "水平位置"
L["XDesc"] = "到屏幕中心的水平位置"
L["Y"] = "垂直位置"
L["YDesc"] = "到屏幕中心的垂直位置"
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
L["CombatFadeTimeDesc"] = "进入/脱离战斗后的淡出时间(秒)"
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
L["TimerPrintEnabledDesc"] = "打印战斗时长到聊天框(脱离战斗时)"

-- MARK: Focus Interrupt
L["FocusInterruptSettings"] = "焦点打断"
L["FocusInterruptSettingsDesc"] = "焦点打断警报与焦点施法条设置"
L["Interrupted"] = "被打断"
L["InterruptedColor"] = "被打断颜色"
-- Focus Cast Bar Settings
L["FocusCastBarSettings"] = "焦点施法条设置"
L["FocusCastBarHidden"] = "隐藏焦点施法条"
L["FocusCastBarHiddenDesc"] = "隐藏本插件提供的焦点施法条,但依然在后台运行"
L["FocusColorPriorityDesc"] = "不可打断颜色 > 打断未就绪颜色 > 可打断颜色"
-- Focus Interrupt Settings
L["FocusInteruptSettings"] = "焦点打断设置"
L["FocusInterruptCooldownFilter"] = "打断技能未就绪时隐藏"
L["FocusInterruptCooldownFilterDesc"] = "打断技能未就绪时隐藏整个焦点施法条"
L["FocusInterruptNotReadyColor"] = "打断未就绪施法条颜色"
L["FocusInterruptibleFilter"] = "不可打断时隐藏"
L["FocusInterruptibleFilterDesc"] = "不可打断时隐藏整个施法条"
L["FocusMuteDesc"] = "基于暴雪的限制, 打断音效任然会在打断技能CD时播放\n\n建议不使用音效(本模块包含多种视觉上的焦点施法过滤)\n\n注意: 如果其他插件(包括ElvUI和oUF)禁用了暴雪的 焦点框体/焦点施法条, 打断音效也会在不可打断读条时播放(不会影响施法条的视觉效果)。暴雪原生焦点施法条是取得非secret-value的能否打断信息的途径"
L["FocusInterruptSoundDesc"] = "需要打断时播放的音效"
L["InterruptedFadeTime"] = "被打断淡出时间"
L["InterruptedFadeTimeDesc"] = "被打断后施法条多久会隐藏(秒)"
L["ShowInterrupter"] = "显示打断者"
L["ShowTarget"] = "显示目标"

-- MARK: BattleRes
L["BattleResSettings"] = "战复计时器"
L["BattleResSettingsDesc"] = "显示战复的冷却和充能"

--MARK: Warlock
L["WarlockReminders"] = "|cff8788ee术士|r提醒"
-- Warlock Pet settings
L["FelguardEnable"] = "启用恶魔卫士检查"
L["FelguardEnableDesc"] = "在恶魔学识天赋下,检查宝宝是否是恶魔卫士"
L["FelhunterEnable"] = "启用地狱猎犬/小鬼检查"
L["FelhunterEnableDesc"] = "在痛苦/毁灭天赋下,检查宝宝是否是地狱猎犬/小鬼"
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