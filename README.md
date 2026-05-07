<div align="center">

# Folder Size Report

**一键扫描，揪出磁盘空间"大户"**

[![Windows](https://img.shields.io/badge/platform-Windows%2010%2F11-blue?logo=windows)](https://github.com/MikeOutlook/Folder-Size-Report)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell)](https://github.com/MikeOutlook/Folder-Size-Report)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](https://github.com/MikeOutlook/Folder-Size-Report/blob/main/LICENSE)
[![Release](https://img.shields.io/github/v/release/MikeOutlook/Folder-Size-Report?color=orange)](https://github.com/MikeOutlook/Folder-Size-Report/releases/latest)

[English](#quick-start) · 简体中文

</div>

---

电脑空间快满了，却不知道谁在"偷偷长胖"？

Folder Size Report 是一个**零依赖、开箱即用**的 Windows 文件夹容量统计工具。输入一个路径，它就帮你把每个一级子文件夹的大小排好，**从大到小、一目了然**。

```
========================================================================================
Folder Size Report
Path      : E:\
Scanned   : 39 folders
Total size: 1.46 TB
Generated : 2026-04-17 11:35:02
Notice    : 2 inaccessible item(s) were skipped.
========================================================================================
#     Folder                                         Size    Share  Visual
--------------------------------------------------------------------------------------
   1  01_网课汇总                                   899.88 GB    60.0%  #################-----------
   2  00_Notes from Senior Students             289.77 GB    19.3%  #####-----------------------
   3  05_WeChat and QQ                          100.08 GB     6.7%  ##--------------------------
========================================================================================
```

## Why This Tool?

- **不想装软件？** — 两个文件，下载即用，绿色无污染
- **不想敲命令？** — 双击 `.bat` 或拖拽文件夹即可运行
- **找不到罪魁祸首？** — 自动按大小排序，最大的永远在最上面
- **目录结构复杂？** — 递归统计每个子文件夹的总大小，深层也不放过

## Quick Start

### 双击运行

双击 `folder-size-report.bat`，输入绝对路径，回车。

### 拖拽运行

把任意文件夹拖到 `folder-size-report.bat` 上，自动扫描。

### 命令行

```powershell
# 基本用法
powershell -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path "E:\"

# 只看最大的 15 个文件夹
powershell -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path "E:\" -Top 15

# 把根目录下的零散文件也统计进来
powershell -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path "E:\" -IncludeRootFiles

# 关闭彩色输出（适合重定向到文件）
powershell -ExecutionPolicy Bypass -File .\folder-size-report.ps1 -Path "E:\" -NoColor > report.txt
```

## Features

| 特性 | 说明 |
| :--- | :--- |
| 智能单位换算 | 自动转换为 KB / MB / GB / TB，直观易读 |
| 占比可视化 | 百分比 + 条形图，一眼看出谁最占空间 |
| 彩色输出 | 最大项绿色高亮，超过 20% 黄色提醒 |
| 无权限跳过 | 自动跳过系统保护目录，不会卡住或报错 |
| 防循环递归 | 自动识别并跳过符号链接（ReparsePoint） |
| 进度提示 | 实时显示扫描进度 |
| 零依赖 | 无需安装任何额外组件，PowerShell 5.1+ 即可运行 |

## Parameters

| 参数 | 必填 | 说明 |
| :--- | :---: | :--- |
| `-Path` | 是 | 要扫描的绝对路径，如 `E:\`、`D:\Downloads` |
| `-Top` | 否 | 只显示最大的前 N 个文件夹 |
| `-IncludeRootFiles` | 否 | 统计目标路径根下的零散文件，显示为 `[Root files]` |
| `-NoColor` | 否 | 关闭彩色输出，适合重定向到文件或日志 |

## File Description

```
folder-size-report/
├── folder-size-report.bat   # 入口脚本，双击运行
├── folder-size-report.ps1   # 核心逻辑（PowerShell）
└── README.md
```

> `.bat` 和 `.ps1` 需要放在**同一目录**下。

## FAQ

**Q: 有些文件夹显示 0 B？**
该文件夹确实几乎为空，或者部分内容因权限不足被跳过。顶部会提示跳过了多少项。

**Q: 扫描整个磁盘很慢？**
脚本会递归遍历所有文件计算大小。磁盘越大、文件越多，耗时越长，这是正常现象。

**Q: 提示"路径无效"？**
请输入绝对路径（如 `E:\`、`C:\Users\Name\Downloads`），不要使用相对路径。

## Requirements

- Windows 10 / 11
- PowerShell 5.1 及以上

## License

This project is licensed under the MIT License.
