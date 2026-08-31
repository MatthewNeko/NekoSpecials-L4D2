# NekoSpecials

<p align="center">
Specials plugin that can be customized in real time!<br>
可实时自定化的多特插件!<br>
</p>

[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
<br>

<!-- links -->
[forks-shield]: https://img.shields.io/github/forks/himenekocn/NekoSpecials-L4D2.svg?style=flat-square
[forks-url]: https://github.com/himenekocn/NekoSpecials-L4D2/fork
[stars-shield]: https://img.shields.io/github/stars/himenekocn/NekoSpecials-L4D2.svg?style=flat-square
[stars-url]: https://github.com/himenekocn/NekoSpecials-L4D2/stargazers

插件安装教程:<br>[[Neko多特插件 安装和详细介绍 7.0版本来袭 求生之路]](https://www.bilibili.com/video/av1906422263/)

# 遇到不刷特问题
打开 nekospecials_debug 1 跑下图
然后把生成的日志提交到issue

# 7.15变化
1.性能优化，新增刷特模式

## 目录
- [使用注意](#使用注意)
- [安装前系统方面的准备](#安装前系统方面的准备)
- [插件安装](#插件安装)
- [插件CFG位置](#插件CFG位置)
- [插件推荐平台](#插件推荐平台)
- [插件模块介绍](#插件模块介绍)
- [玩家指令](#玩家指令)
- [管理员指令](#管理员指令)
- [模式简单说明](#模式简单说明)
- [子模式&详细说明](#子模式&详细说明)
- [更新日志](#更新日志)
- [使用规范](#使用规范)

# 使用注意
请看完本页说明，不看完的都是🐖<br>
<hr>
安装前请把包括7.13版本以下的东西删除干净再安装，否则无法加载插件<br>
安装前请把包括7.13版本以下的东西删除干净再安装，否则无法加载插件<br>
安装前请把包括7.13版本以下的东西删除干净再安装，否则无法加载插件<br>
重要的事情说三遍<br>
由于拓展改了文件名，请你务必检查BinHooks拓展是否有重复<br>
<hr>
如果你是直接下载仓库内最新版本使用，请记得在出现错误或不可用时提交日志，QQ:846490391

# 插件安装
1.安装Sourcemod插件平台到1.11+最新版本<br>
2.安装[left4dhooks](https://forums.alliedmods.net/showthread.php?p=2684862)最新版本<br>
3.(可选)投票功能已自带，跳过此步，如不需要请自行移除<br>
4.下载本插件，将插件拖到服务器的left4dead2文件夹中覆盖<br>
5.启动一次服务器检查是否全部加载<br>
6.修改插件对应cfg，CFG文件均为自动生成，请先执行第五步

# 插件CFG位置
多特配置：服务器目录/left4dead2/cfg/sourcemod/Neko_Specials_binhooks.cfg<br>
HUD配置：服务器目录/left4dead2/cfg/sourcemod/Neko_KillHud_binhooks.cfg<br>
服名配置：服务器目录/left4dead2/cfg/sourcemod/Neko_ServerName.cfg<br>
投票配置：服务器目录/left4dead2/cfg/sourcemod/Neko_VoteMenu.cfg<br>
<br>
HUD内容&服名内容的更改：服务器目录/left4dead2/addons/sourcemod/data/nekocustom.cfg

# 注意：插件不生效请查看错误日志输入，日志在addons/sourcemod/logs里面，error开头就是

# 插件推荐平台
[Sourcemod-1.11+](https://www.sourcemod.net/downloads.php?branch=1.11-dev)<br>
[Sourcemod-1.12+](https://www.sourcemod.net/downloads.php?branch=1.12-dev)<br>
1.13待测试<br>
保持最新插件平台就是啦！

# 插件模块介绍
【插件必备组件】BinHooks.ext 核心拓展<br>
【插件必备组件】[dhooks](https://forums.alliedmods.net/showthread.php?p=2588686#post2588686) SM1.11-6854后自带，不需要安装<br>
【插件必备组件】[left4dhooks](https://forums.alliedmods.net/showthread.php?p=2684862)(请手动安装最新版本)<br>
【插件必备组件】[l4d2_nativevotes](https://github.com/fdxx/l4d2_nativevote)(仓库自带)<br>
【多特本体模块】[NekoSpecials](https://himeneko.cn/nekospecials) (可选安装，默认安装)<br>
【击杀统计模块】[NekoKillHud](https://himeneko.cn/nekospecials) (可选安装，默认安装)<br>
【管理员快捷功能模块】[NekoAdminMenu](https://himeneko.cn/nekospecials) (可选安装，默认安装)<br>
【服务器名字功能模块】[NekoServerName](https://himeneko.cn/nekospecials) (可选安装，默认安装)<br>
【玩家特感投票模块】[NekoVote](https://himeneko.cn/nekospecials) (可选安装，默认安装) 投票插件默认开关为关闭，需手动在cfg/或者管理员菜单开启<br>
【控制坦克女巫刷新】[l4d2_boss_spawn](https://forums.alliedmods.net/showthread.php?p=2694435)(可选)(开启Special_CanCloseDirector后请配合使用)<br>

# 玩家指令
!tgvote 或者直接输入tgvote等 即可打开玩家投票菜单

# 管理员指令
!ntg					全功能特感菜单<br>
!nekotg                 全功能特感菜单<br>
!tgmenu                 全功能特感菜单<br>
!tgadmin                全功能特感菜单<br>

!ntgversion				特感版本查询/状态检查<br>
!nhud					HUD显示调整<br>
!reloadntgconfig	    重载多特配置文件(Neko_Specials_binhooks.cfg)<br>
!reloadhudconfig	    重载HUD配置文件(Neko_KillHud_binhooks.cfg)<br>
!updateservername	    手动更新服务器名字<br>
!nekoupdate				执行检查更新<br>
!tgvoteadmin			控制玩家投票模块

# 模式简单说明
可变模式:无序刷特，融合其它各个模式的优点并新增针对某个玩家附近刷特...<br>
地狱模式:无序刷特，任何幸存者周围的位置包括无视障碍物以及可在幸存者视线范围内...<br>
噩梦模式:无序刷特，可在幸存者周围的位置包括无视障碍物但不会在幸存者视线范围内...<br>
正常模式:有序刷特，可在幸存者周围的位置且只在幸存者看不见的障碍物后面刷特...<br>
导演模式:有序刷特，可在幸存者周围的位置且只在幸存者看不见的障碍物后面刷特，但时间上无法控制，只会更慢，不会更快刷特...

# 子模式&详细说明
导演模式下:<br>
导演引擎模式产生特感，但时间上不准确，这是引擎本身的行为导致的，它就像一个智能AI，<br>
我们无法准确确定它的时间，难度较小，和脚本引擎的产生特感模式几乎一致。<br>
<br>
普通模式下:<br>
正常产生特感，产生位置经过了深度算法分析和数据结构优化，<br>
性能上比现有的刷特插件更节约性能，产生的位置将各加合理，难度适中，但比引擎刷特难度更加大。<br>
有两个子模式，子模式1和子模式2无论是刷特位置和刷特性能并无明显的变化<br>
子模式1-更趋近于对每个幸存者的位置对应的刷特位置产生最优解<br>
子模式2-更趋近于对于整体队伍的位置对应的刷特位置产生最优解<br>
玩家可根据自身情况自由选择。<br>
<br>
噩梦模式下：<br>
它的刷特地点不同于正常模式和地狱模式，但本质还是经过算法深度分析的，<br>
它将会产生在生还者的周围任何不在幸存者视线内，但有利于袭击生还者的角落，<br>
它不再仅仅是产生在障碍物的后面，难度比较大，望谨慎选择!<br>
子模式1-为原来噩梦模式<br>
子模式2-开启梦魇模式，根据官方底层api基础上运用算法实现的，它比噩梦模式更加强大！<br>
无论是刷特机制，刷特位置，刷特性能等，以及开发自由度上，都比噩梦模式更加优越，它不是在噩梦基础上进行提升的，它是全新的更优越的算法模式。<br>
<br>
地狱模式下：<br>
特感产生的位置将是无序但有规则的，但本质还是经过算法深度分析的，<br>
它将会产生在生还者的周围任何有利于袭击生还者的角落，它不再仅仅是产生在障碍物的后面，<br>
请慎用此模式，非抖M请远离...<br>
子模式1-为原来地狱模式<br>
子模式2-是炼狱模式，根据官方底层api基础上运用算法实现的，它比地狱模式更加强大！<br>
无论是刷特机制，刷特位置，刷特性能等，以及开发自由度上，都比地狱模式更加优越，它不是在地狱基础上进行提升的，它是全新的更优越的算法模式。<br>
<br>
可变模式下：<br>
相比导演引擎寻位，优势主要在于2点：<br>
第一，支持针对某一个玩家前面或者后面或者任意位置刷特，比如三个人，可以针对中间的这个人刻意寻位刷特，刷在他的前面或者后面都行。
<br>并且支持是否可视刷特，支持最小和最大距离设定，解决了某个人落单或者在中间当咸鱼的玩家。<br>
第二，导演引擎刷特位置基本在每个地图的特定属性区域，即使前方有障碍物，但是不是特定属性区域也不会刷特，算法刷特是前方一切区域均可刷特，如果选择不可视刷特，只要前方有障碍物，并且是距离范围内，都能够刷出特感
优化了算法!<br>

# 更新日志
7.15NS 更新日志 2026/8/31 18:00<br>
1.性能深度优化，刷特分批刷优化减少Choke<br>
2.修复死后补充的BUG问题<br>
3.增加更多投票控制选项<br>
4.增加多少玩家倒地后不刷特功能<br>
5.修复防跑图和掉队可能不生效问题<br>
6.在概率平衡时，减少了6特以下会出现多个重复特感问题

# 使用规范
使用本插件时请遵守顾问的使用规范，勿将本插件用作商用(RPG)
