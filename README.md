# Folder Size Report

电脑空间快满了，却不知道到底是哪个文件夹在“偷偷长胖”？

这个小工具就是为这种时刻准备的。你只需要输入一个**绝对路径**，比如 `E:\`、`D:\Downloads` 或 `C:\Users\YourName\Desktop`，它就会帮你快速统计该目录下**每个一级子文件夹**占了多少空间，并按大小从大到小排好，结果清晰、直观、适合一眼定位“空间大户”。

它尤其适合这些场景：

- 想知道整个磁盘里哪个文件夹最占空间
- 想快速检查下载目录、项目目录、资料盘是否“爆仓”
- 不想装额外软件，只想双击一下就看到结果

## 你会得到什么

- 按容量**从大到小排序**的文件夹列表
- 自动换算成 `KB / MB / GB / TB`
- 每个文件夹的**占比**
- 一眼能看懂的**条形图**
- 扫描进度提示
- 遇到无权限目录时自动跳过，并给出提示
- 支持**双击运行**
- 支持**把文件夹直接拖到 `.bat` 上运行**
- 也支持命令行高级用法

## 文件说明

- `folder-size-report.bat`
  面向普通用户。双击即可运行。
- `folder-size-report.ps1`
  真正执行统计逻辑的 PowerShell 脚本。

请把这两个文件放在**同一个文件夹**里使用，因为 `.bat` 会调用同目录下的 `.ps1`。

## 30 秒上手

### 方法 1：双击运行，最省心

1. 双击 `folder-size-report.bat`
2. 在弹出的窗口里输入绝对路径，例如：

```text
E:\
```

3. 按回车，等待扫描完成

### 方法 2：拖拽运行，最方便

把任意文件夹直接拖到 `folder-size-report.bat` 上，它会自动扫描这个文件夹。

### 方法 3：命令行运行，最灵活

```powershell
powershell -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path "E:\"
```

## 常用示例

扫描整个 `E:\`：

```powershell
powershell -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path "E:\"
```

只看最大的前 15 个文件夹：

```powershell
powershell -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path "E:\" -Top 15
```

把目标目录根下的零散文件也一起统计：

```powershell
powershell -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path "E:\" -IncludeRootFiles
```

关闭彩色输出：

```powershell
powershell -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path "E:\" -NoColor
```

## 输出长什么样

```text
========================================================================================
Folder Size Report
Path      : E:\
Scanned   : 39 folders
Total size: 1.46 TB
Generated : 2026-04-17 11:35:02
Notice    : 2 inaccessible item(s) were skipped.
========================================================================================
#     Folder                                         Size    Share  Visual
--------------------------------------------------------------------------
   1  01_网课汇总                                   899.88 GB    60.0%  #################-----------
   2  00_Notes from Senior Students             289.77 GB    19.3%  #####-----------------------
   3  05_WeChat and QQ                          100.08 GB     6.7%  ##--------------------------
========================================================================================
```

你不需要逐个去点开文件夹找罪魁祸首，排在最上面的通常就是最值得先清理的对象。

## 参数说明

| 参数 | 作用 |
| --- | --- |
| `-Path` | 要扫描的绝对路径 |
| `-Top` | 只显示最大的前 N 个文件夹 |
| `-IncludeRootFiles` | 统计目标目录根下的文件，并作为 `[Root files]` 单独显示 |
| `-NoColor` | 关闭彩色输出 |

## 适用环境

- Windows
- PowerShell 5.1 及以上

一般来说，Windows 10 / 11 都可以直接运行。

## 使用建议

- 想看整个盘谁最占空间，直接扫 `E:\`、`D:\`、`C:\`
- 如果目录非常大，扫描会花一点时间，这是正常的
- 第一次定位空间问题时，建议先用 `-Top 10` 或 `-Top 15`
- 如果你主要靠双击使用，优先打开 `folder-size-report.bat`

## 常见问题

### 1. 为什么有些文件夹显示为 0 B？

可能原因有两个：

- 这个一级文件夹里确实几乎没有内容
- 某些系统目录或受保护目录无法完整读取，因此被跳过

脚本会在顶部提示有多少项被跳过。

### 2. 为什么扫整个磁盘会比较慢？

因为脚本会递归统计每个一级子文件夹下的所有文件大小。目录越大、文件越多，耗时就越长。

### 3. 为什么我输入路径后提示路径无效？

请确认你输入的是**绝对路径**，例如：

- `E:\`
- `D:\Downloads`
- `C:\Users\YourName\Documents`

不要只输入相对路径，比如：

- `Downloads`
- `.\test`

### 4. `.bat` 和 `.ps1` 应该用哪个？

- 只想直接用：选 `.bat`
- 想加参数、自定义显示方式：选 `.ps1`

## 适合分享给谁

- 想清理磁盘空间的同学
- 经常下载资料、视频、数据集的人
- 电脑里项目、课程、照片、安装包很多的人
- 想要一个比“手动点文件夹”高效得多的小工具的人

## 一句话总结

这是一个**简单、直接、对普通用户友好**的 Windows 文件夹容量统计工具。

输入一个绝对路径，它就会告诉你：**空间到底被谁占走了。**
