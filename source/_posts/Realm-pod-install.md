---
title: '使用Realm,pod install失败解决方法'
date: 2016-11-28 20:18:29
categories: 开发总结
tags: [Realm,数据库]

---

---


### Realm pod install 失败

```swift
[!] /bin/bash -c 
set -e
sh build.sh cocoapods-setup

core is not a symlink. Deleting...
Downloading dependency: core 1.0.1
Downloading core failed:
curl: (56) SSLRead() return error -36
```
`解决方法：
rm -rf Pods，删除工程目录下的pods文件夹，然后重新 pod install`
<!-- more --> 
### 安装Realm的时候会慢一些,解决方法
```swift
curl https://static.realm.io/downloads/core/realm-core-1.0.1.tar.bz2 -O
mkdir $TMPDIR/core_bin
mv realm-core-1.0.1.tar.bz2 $TMPDIR/core_bin
```
### 如果你之前pod install失败了，会有之前的缓存，记得更新repo:
```swift
pod repo update --verbose
```
#### 那么现在把我们的core，放进core_bin：
```swift
mkdir -p $TMPDIR/core_bin; cd /core的存储地址/Realm\ Core; cp `ls -r1 | head -1t` $TMPDIR/core_bin/.
```
