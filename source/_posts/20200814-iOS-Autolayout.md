---
title: 小谈 Auto Layout 
date: 2020-08-14 21:49:36
categories: [技术人生,读书笔记]
tags: [iOS,UI布局]
---

Auto Layout ，是苹果公司提供的一个基于约束布局，动态计算视图大小和位置的库，并且已经集成到了 Xcode 开发环境里。

苹果公司早在 iOS 6 系统时就引入了 Auto Layout，即使后来，苹果公司推出了在 Auto Layout 基础上的 UIStackView 工具，提高了开发体验和效率。当然更通用的用方式则是选用 `SB`、`xib`、`SnapKit`或者`Masonry`。

可是Auto Layout 到底是如何实现自动布局的 ？

<!--more -->

## Auto Layout 的来历

- 1997 年，Auto Layout 用到的布局算法 Cassowary 被发明了出来；
- 2011 年，苹果公司将 `Cassowary 算法`运用到了自家的布局引擎 Auto Layout 中。

`Cassowary` 能够有效解析线性等式系统和线性不等式系统，用来表示用户界面中那些相等关系和不等关系。

`Cassowary` 开发了一种规则系统，通过约束来描述视图间的关系。**约束就是规则，这个规则能够表示出一个视图相对于另一个视图的位置**。

`Cassowary 算法`让视图位置可以按照相对位置描述，在运行时动态地计算出视图具体的位置。这样一来视图位置的写法大大的被简化了，界面相关代码也就更易于维护。

## Auto Layout 生命周期

`Auto Layout` 的核心是 `Layout Engine`，由它来主导页面的布局。它是一整套布局引擎系统，包含了布局在运行时的生命周期，用来统一管理布局的创建、更新和销毁。Auto Layout拥有一套Layout Engine引擎，

`Layout Engine` 主导着整个界面布局。每个视图在得到自己的布局之前，`Layout Engine` 会将**视图、约束、优先级、固定大小通过计算转换成最终的大小和位置**。在 `Layout Engine` 里，每当约束发生变化，就会触发 `Deffered Layout Pass` ，完成后进入监听约束变化的状态。当再次监听到约束变化，即进入下一轮循环中。整个过程如下图所示：

![图片来自戴铭《iOS开发高手课》专栏](https://imagerepos.oss-cn-beijing.aliyuncs.com/images/20210415212444.png)

`Constraints Change`  表示的就是约束变化，添加、删除视图时会触发约束变化。

`Activating` 或 `Deactivating`，设置 `Constant` 或 `Priority` 时也会触发约束变化。

`Layout Engine` 在碰到约束变化后会重新计算布局，获取到布局后调用 `superview.setNeedLayout()`，然后进入 `Deferred Layout Pass`。`Deferred Layout Pass` 的主要作用是做容错处理。

如果有些视图在更新约束时没有确定或缺失布局声明的话，会先在这里做容错处理。接下来，`Layout Engine` 会从上到下调用 `layoutSubviews()` ，通过 `Cassowary` 算法计算各个子视图的位置，算出来后将子视图的 `frame` 从 `Layout Engine` 里拷贝出来。

简单来讲就是当 App 启动后，主线程的 `Run Loop` 会一直处于监听状态，当约束发生变化后会触发`Deffered Layout Pass`（延迟布局传递），在里面做容错处理（约束丢失等情况）并把 view 标识为dirty 状态，然后 `Run Loop` 再次进入监听阶段。当下一次刷新屏幕动作来临（或者是调用 `layoutIfNeeded` ）时，`Layout Engine` 会从上到下调用 `layoutSubviews()` ，通过 `Cassowary 算法` 计算各个子视图的位置，算出来后将子视图的 `frame` 从 `Layout Engine` 拷贝出来，接下来的过程就跟手写 `frame` 是一样的了。

## Auto Layout 性能怎样

苹果公司在 `WWDC 2018` 的“ `WWDC 220 Session High Performance Auto Layout”Session` 中介绍说： iOS 12 将大幅提高 Auto Layout 性能，使滑动达到满帧。在 `202 Session` 里讲到的 `Auto Layout` 在 iOS 12 中优化后的表现。如下图

![WWDC 2018 202](https://imagerepos.oss-cn-beijing.aliyuncs.com/images/20210415212521.png)

可以看到，优化后的性能，已经基本和手写布局一样可以达到性能随着视图嵌套的数量呈线性增长了。而在此之前的 Auto Layout，视图嵌套的数量对性能的影响是呈指数级增长的。

iOS 12 之前，很多约束变化时都会重新创建一个计算引擎 `NSISEnginer` 将约束关系重新加进来，然后重新计算。结果涉及到的约束关系变多时，新的计算引擎需要重新计算，最终导致计算量呈指数级增加。而 iOS12 的 `Auto Layout` 更多地利用了 `Cassowary` 算法的界面更新策略，使其真正完成了高效的界面线性策略计算。

## 常用思路

在日常工作中，不少团队依然选用手写布局，原因在于在 `layoutSubviews` 中做布局，可以将所有的子视图按照 UI 显示从上至下、从左至右的顺序来布局，看起来会很规范，代码不会导致不易维护的程度。  

不过也有不少团队也有约定：

- 简单的 UI 使用 Auto Layout
- 复杂的 UI 使用 Frame

原因在于：

1. 从代码量上来看，两种布局方式相差不大。然而在涉及到复杂布局或者动画的话，使用 `Auto Layout` 的话，反而会变得更加复杂。无论是处理复杂的业务逻辑还是复杂的交互逻辑。
2. 区分静态UI和动态UI，把静态UI和微动态UI交给 `Auto Layout` 或者 直接使用 `XIB`。
3. 不确定高度的cell，区分不同场景。例如控件布局简单，可利用其特性进行自适应即可，相反计算高度倒不失为一种不错的方式。

------

## 参考资料

- [High Performance Auto Layout - WWDC 2018 - Videos - Apple Developer](https://developer.apple.com/videos/play/wwdc2018/220)
- [ShowAutoLayout](https://github.com/ming1016/ShowAutoLayout)
- [WWDC 2015: Mysteries of Auto Layout](https://developer.apple.com/videos/play/wwdc2015-219/)