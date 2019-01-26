Music Index
============

DATE: 2018-07-07

本文档对自己的音乐材料做了汇总和整理.

阅读完该文档之后, 您将了解到这些内容:

* 我在一诺老师的授课总结.
* 一些网络视频和教学资料.

--------------------------------------------------------

Guitar Lessons
--------------
### 音乐理论基础
1. [音阶](./scales.html)
2. [音程](./intervals.html)
3. [和弦](./chords.html)
4. [好和弦视频笔记](./nicechord_learning.html)

### Pieces
一些音乐片段收集

[pieces](./pieces.html)

### Song Books
一些弹唱或者指弹的曲目等

[songbooks](./songbooks.html)

五线谱(Five-line Staff)
-----------------------
### 教学视频
推荐: [好和弦](http://nicechord.com/)的五线谱教程

<iframe class="youtube" src="https://www.youtube.com/embed/qkt5X_4FJBY" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

一些五线谱的英文对照表

音符 musical note


| 名称              | 翻译                      |
| --------          | ------                    |
| 音符              | Musical                   Note |
| 全/半/四/八分音符 | Whole/Half/Quarter/Eighth Note |
|    拍号     |   Time Signature         |
|    调号     |   Key Signature        |
|    附点音符     |   Dotted Note         |
|    连音     |   Tuplet         |
|    符头/干/尾/酐     |   Note Head/Stem/Flag/Beam         |
|    休止符     |   Rest         |
|    全/半/四/八分休止符     |   Whole/Half/Quarter/Eighth Rest         |
|    加线     |   Ledger Line         |
|    谱号     |   Clef        |
|    升/降/还原     |   Sharp/Flat/natural        |
|    重降/重升     |   Double Flat/Double Sharp        |
|    临时记号     |   Accidental        |
|    从头开始     |   D.C        |
|    结束     |   FINE (意大利文)        |
|    第一/第二结尾     |   First/Second Ending        |
|    颤音     |   Tremolo        |
|    断奏     |   Staccato        |
|    强音     |   Accent        |
|    持音     |   Tenuto        |
|    延长     |   Fermata        |
|    强/弱/中     | Forte/Piano/Mezzo 这里就是F/P/M          |
|    渐强/渐弱     | cresc./dim.          |

NOTE: ♩=120, 代表的是每分钟120个♩

NOTE: 小节线 |; 如果要分段或者换调用, 则使用双小节线 ||; 反复记号 ||: :||

### 吉他和五线谱关系
![stuff](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/guitar_tab.jpg)
![stuff](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/guitar_tab_c_f.jpg)
![stuff](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/music_mutations.jpg)

吉他演奏的音域
![range](https://raw.githubusercontent.com/dengqinghua/roses/master/assets/images/guitar_ranges.jpg)

NOTE: 图片来源于 [古典吉他弹奏怎样识记五线谱？ - woodoo001的回答](https://www.zhihu.com/question/26296830/answer/83856060)

### 五线谱上的谱号
![music_intervals](images/music_intervals.png)

ABC Notation
------------
### 常用符号整理
NOTE: 下面的 `+` 代表 `|`

| 符号     | 含义         | 示例 |
| -------- | ------       | ---  |
| T     | 标题 | T: Title     |
| C     | 作曲作者 | C: 周杰伦     |
| L     | unit note length | L: 1/4     |
| Q     | tempo, 速度 | Q: 100     |
| K     | Key | K: C#m    |
| ,'     | 低音/高音 | E, e' |
| ^,=,_     | Accidentals | \^E =E _E, 分别代表 E♯, ♮E 和 E♭ |
| /     | lengths | a/ 代表a/2; a// 代表 a/4 |
| +: :+ | 开始 结束重复 | +: a b c :+ |
| +[1     | 第一遍重复 | +:  common body of tune  +1  first ending  :+2  second ending  +] |
| (), -     | Ties and slurs | (a b) c4-c |
| (3     | 三连音 | (3abc |
| " D"     | 标记/和弦 | 添加空格代表为标记, 没有空格则可认为是和弦D |

### 示例
#### 多声部
```
MUSIC:
X:1
T:Zocharti Loch
C:Louis Lewandowski (1821-1894)
M:C
Q:1/4=76
%%score (T1 T2) (B1 B2)
V:T1           clef=treble-8  name="Tenore I"   snm="T.I"
V:T2           clef=treble-8  name="Tenore II"  snm="T.II"
V:B1  middle=d clef=bass      name="Basso I"    snm="B.I"  transpose=-24
V:B2  middle=d clef=bass      name="Basso II"   snm="B.II" transpose=-24
K:Gm
%            End of header, start of tune body:
% 1
[V:T1]  (B2c2 d2g2)  | f6e2      | (d2c2 d2)e2 | d4 c2z2 |
[V:T2]  (G2A2 B2e2)  | d6c2      | (B2A2 B2)c2 | B4 A2z2 |
[V:B1]       z8      | z2f2 g2a2 | b2z2 z2 e2  | f4 f2z2 |
[V:B2]       x8      |     x8    |      x8     |    x8   |
% 5
[V:T1]  (B2c2 d2g2)  | f8        | d3c (d2fe)  | H d6    ||
[V:T2]       z8      |     z8    | B3A (B2c2)  | H A6    ||
[V:B1]  (d2f2 b2e'2) | d'8       | g3g  g4     | H^f6    ||
[V:B2]       x8      | z2B2 c2d2 | e3e (d2c2)  | H d6    ||
```

MUSIC:
X:1
T:Zocharti Loch
C:Louis Lewandowski (1821-1894)
M:C
Q:1/4=76
%%score (T1 T2) (B1 B2)
V:T1           clef=treble-8  name="Tenore I"   snm="T.I"
V:T2           clef=treble-8  name="Tenore II"  snm="T.II"
V:B1  middle=d clef=bass      name="Basso I"    snm="B.I"  transpose=-24
V:B2  middle=d clef=bass      name="Basso II"   snm="B.II" transpose=-24
K:Gm
%            End of header, start of tune body:
% 1
[V:T1]  (B2c2 d2g2)  | f6e2      | (d2c2 d2)e2 | d4 c2z2 |
[V:T2]  (G2A2 B2e2)  | d6c2      | (B2A2 B2)c2 | B4 A2z2 |
[V:B1]       z8      | z2f2 g2a2 | b2z2 z2 e2  | f4 f2z2 |
[V:B2]       x8      |     x8    |      x8     |    x8   |
% 5
[V:T1]  (B2c2 d2g2)  | f8        | d3c (d2fe)  | H d6    ||
[V:T2]       z8      |     z8    | B3A (B2c2)  | H A6    ||
[V:B1]  (d2f2 b2e'2) | d'8       | g3g  g4     | H^f6    ||
[V:B2]       x8      | z2B2 c2d2 | e3e (d2c2)  | H d6    ||

#### 简易版本
```
MUSIC:
X:1
T:Speed The Plough
M:4/4
L:1/8
N:Simple version
Z:Steve Mansfield 1/2/2000
K:G
GABc dedB | dedB dedB | c2ec B2dB | A2A2 A2 BA|
GABc dedB | dedB dedB | c2ec B2dB | A2A2 G4 ::
g2g2 g4 | g2fe dBGB | c2ec B2dB | A2A2 A4 |
g2g2 g4 | g2fe dBGB | c2ec B2dB | A2A2 G4 :|
```

MUSIC:
X:1
T:Speed The Plough
M:4/4
L:1/8
N:Simple version
Z:Steve Mansfield 1/2/2000
K:G
GABc dedB | dedB dedB | c2ec B2dB | A2A2 A2 BA|
GABc dedB | dedB dedB | c2ec B2dB | A2A2 G4 ::
g2g2 g4 | g2fe dBGB | c2ec B2dB | A2A2 A4 |
g2g2 g4 | g2fe dBGB | c2ec B2dB | A2A2 G4 :|

### 例子
[examples](http://abcnotation.com/examples)

### References
[abc_notation](http://www.lesession.co.uk/abc/abc_notation.htm)
[abc:standard:v2.1](http://abcnotation.com/wiki/abc:standard:v2.1)
