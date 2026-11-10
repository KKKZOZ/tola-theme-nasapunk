<div align="center">

<img src="theme/assets/favicon.svg" width="84" alt="">

# NASApunk

**一个 NASApunk 风格的 [Tola](https://github.com/tola-rs/tola-ssg) 博客主题。**

用 Typst 写文章，插图、图表和公式渲染为内联 SVG，跟随主题的日夜配色。

[![Build](https://github.com/KKKZOZ/tola-theme-nasapunk/actions/workflows/build.yml/badge.svg)](https://github.com/KKKZOZ/tola-theme-nasapunk/actions/workflows/build.yml)
[![Tola](https://img.shields.io/badge/Tola-0.8.2--pre.2%2B-cb4b22)](https://github.com/tola-rs/tola-ssg)
[![Typst](https://img.shields.io/badge/Typst-0.15-239dad)](https://typst.app)
[![License: MIT](https://img.shields.io/badge/license-MIT-286379)](LICENSE)

[English](README.md) · **简体中文**

**[在线演示](https://kkkzoz.github.io/tola-theme-nasapunk/)** · **[我的博客](https://blog.kkkzoz.top/)**

<br>

<img src="docs/screenshots/hero.png" alt="NASApunk 首页，日间与夜间主题沿对角线拼接">

</div>

> [!NOTE]
> 需要同一风格的幻灯片？配套的 slides 模板是 Typst Universe 上的 [touying-nasapunk](https://typst.app/universe/package/touying-nasapunk)。

## 目录

- [特性](#特性)
- [截图](#截图)
- [快速开始](#快速开始)
- [文档](#文档)
- [字体](#字体)
- [致谢](#致谢)
- [许可证](#许可证)
- [Star History](#star-history)

## 特性

<table>
  <tr>
    <td width="33%" valign="top">
      <img src="docs/features/report.png" alt="带文档编号和日期的文章头部"><br>
      <b>文章头</b><br>
      <sub>每篇文章都有文档编号、日期、年积日和阅读时间。</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/archive.png" alt="带每月发文图的归档页"><br>
      <b>归档</b><br>
      <sub>按年份分组，附每月发文图。</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/tags.png" alt="标签页"><br>
      <b>标签</b><br>
      <sub>每个标签的文章数与文章列表。</sub>
    </td>
  </tr>
  <tr>
    <td width="33%" valign="top">
      <img src="docs/features/series.png" alt="系列导航框"><br>
      <b>系列文章</b><br>
      <sub><code>series</code> 相同的文章自动互相导航，<code>/series/</code> 列出所有系列。</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/figures.png" alt="一张 CeTZ 图"><br>
      <b>Typst 插图</b><br>
      <sub>CeTZ 与流程图输出为内联 SVG，使用主题配色；点击插图或图片可放大查看。</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/callouts.png" alt="提示框"><br>
      <b>提示框</b><br>
      <sub>五种提示框，外加标注。</sub>
    </td>
  </tr>
  <tr>
    <td width="33%" valign="top">
      <img src="docs/features/toc.png" alt="目录"><br>
      <b>目录</b><br>
      <sub>带编号的标题，目录随滚动高亮。</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/search.png" alt="搜索结果"><br>
      <b>搜索</b><br>
      <sub>基于 Pagefind 的全文搜索，支持中文。</sub>
    </td>
    <td width="33%" valign="top">
      <img src="docs/features/lost.png" alt="404 页面"><br>
      <b>404</b><br>
      <sub>地址不存在时显示的自定义页面。</sub>
    </td>
  </tr>
</table>

## 截图

<table>
  <tr>
    <td width="50%"><img src="docs/screenshots/post.png" alt="文章页"></td>
    <td width="50%"><img src="docs/screenshots/cetz-dark.png" alt="CeTZ 插图，夜间主题"></td>
  </tr>
  <tr>
    <td align="center">文章</td>
    <td align="center">CeTZ 插图（夜间）</td>
  </tr>
  <tr>
    <td><img src="docs/screenshots/components.png" alt="提示框与代码块"></td>
    <td align="center">
      <img src="docs/screenshots/mobile-light.png" width="45%" alt="手机上的首页">
      &nbsp;
      <img src="docs/screenshots/mobile-dark.png" width="45%" alt="手机上的文章页，夜间主题">
    </td>
  </tr>
  <tr>
    <td align="center">提示框与代码块</td>
    <td align="center">手机端（日间 / 夜间）</td>
  </tr>
</table>

## 快速开始

> [!IMPORTANT]
> 这是 `preview` 分支，适用于 [Tola 0.8.2-pre.2](https://github.com/tola-rs/tola-ssg/releases/tag/v0.8.2-pre.2) 及更新版本。Tola 0.8.2 把主题改成了模块（module），所以主题现在位于 `theme/` 目录，并在 `tola.toml` 中配置。Tola 0.8.0 和 0.8.1 请使用 `main` 分支。

需要 Tola 0.8.2-pre.2 或更新版本，以及 Node.js（用于生成搜索索引）。可以用 [mise](https://mise.jdx.dev) 安装 Tola（`mise use -g tola@0.8.2-pre.2`），也可以从它的 [release 页面](https://github.com/tola-rs/tola-ssg/releases/tag/v0.8.2-pre.2)下载预编译版本。

### 作为模块安装（推荐）

博客仓库里只放你自己的文件：文章、`tola.toml` 和几个辅助文件。主题由 Tola 从 Git 拉取，所以更新主题不会动到你的文章，也不需要合并代码。

```sh
# 1. 创建一个空站点；主题自带站点程序
tola init my-blog
cd my-blog
rm site.typ

# 2. 下载 Typst 绘制插图和预览图所用的字体
curl -L https://github.com/KKKZOZ/tola-theme-nasapunk/archive/refs/heads/preview.tar.gz \
  | tar xz --strip-components=1 tola-theme-nasapunk-preview/typst-fonts

# 3. 安装 Pagefind，用于搜索
npm install --save-dev pagefind
echo "node_modules/" >> .gitignore
```

把 `tola.toml` 替换为：

```toml
[site]
title = "My Blog"
authors = [{ name = "Your Name" }]
description = "Notes on research and engineering."
language = "en"

[build]
entry = { module = "nasapunk" }

[modules.nasapunk]
git = { url = "https://github.com/KKKZOZ/tola-theme-nasapunk", branch = "preview", subdir = "theme" }

# 主题选项。全部选项及其默认值和说明：
# https://github.com/KKKZOZ/tola-theme-nasapunk/blob/preview/theme/tola-module.toml
[modules.nasapunk.options]
doc-prefix = "TN"

[typst.fonts]
paths = ["typst-fonts"]
system = true
```

写第一篇文章 `content/posts/hello.typ`，以及关于页 `content/about.typ`：

```typst
#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/nasapunk:0.0.0": callout

#tola-meta((title: "Hello", date: "2026-11-10", summary: "The first post.", tags: ("notes",)))

= First section

#callout(kind: "info")[Written with NASApunk.]
```

```typst
#import "@tola/source:0.0.0": tola-meta
#tola-meta((title: "About"))

About this blog.
```

运行 `tola dev`，打开 <http://127.0.0.1:5277>。`tola dev` 会在保存时自动重新构建；`tola build` 把完整站点（含搜索索引）输出到 `public/`。

更新主题时，运行 `tola update nasapunk`，然后提交变化了的 `tola.lock`。锁文件把主题固定在某个提交上，所以在你主动更新之前，任何机器上的每次构建都使用同一个版本的主题。文章中要用图片时，用 `[assets] trees = [{ source = "assets", url-prefix = "/assets" }]` 发布你自己的目录，并以 `/assets/…` 引用。[演示站点](https://kkkzoz.github.io/tola-theme-nasapunk/)展示了每个组件及其源码。

### 从演示站点开始

想先试用主题，或者要修改主题本身的代码，可以克隆本仓库：它就是演示站点，主题位于 `theme/`。

```sh
git clone --branch preview https://github.com/KKKZOZ/tola-theme-nasapunk.git my-blog
cd my-blog
npm install
tola dev
```

在 `tola.toml` 的 `[site]` 里填写站点标题、作者名和语言，在 `[modules.nasapunk.options]` 里设置主题选项；用你自己的文章替换 `content/posts/` 里的示例，并修改 `content/about.typ`。这样文章和主题在同一个仓库里，主题的新版本需要手动合并。之后想改用模块方式，删除 `theme/`，并把 `[modules.nasapunk]` 改成上面的 `git` 那一行即可。

### Typst 值类型的设置

额外的 `<head>` 内容（如统计脚本）和每篇文章末尾的内容（如评论区）是 Typst 值，不能写在 TOML 里。在 `[build]` 中设置 `entry = "site.typ"`，然后在你自己的 `site.typ` 里把它们传给 `render-site`；[演示站点的 `site.typ`](https://github.com/KKKZOZ/tola-theme-nasapunk/blob/preview/site.typ) 中有这两项的示例。

## 文档

完整文档在 [wiki](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki) 中（英文）。

| 页面 | 内容 |
| --- | --- |
| [Configuration](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki/Configuration) | 各项设置的位置：站点信息、布局、订阅、配色、字体、搜索 |
| [Writing Posts](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki/Writing-Posts) | 文章文件与 URL、`tola-meta` 字段、系列、草稿、数学公式 |
| [Components](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki/Components) | 提示框、折叠块、术语、图片、分栏、文章间链接、流程图、CeTZ 插图和 LaTeX 公式 |
| [Deployment](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki/Deployment) | GitHub Pages 及其他静态托管、子路径部署 |
| [Project Structure](https://github.com/KKKZOZ/tola-theme-nasapunk/wiki/Project-Structure) | 主题中每个文件和目录的作用 |

[在线演示](https://kkkzoz.github.io/tola-theme-nasapunk/)本身也是教程：[Theme Tour](https://kkkzoz.github.io/tola-theme-nasapunk/series/) 系列的每篇文章都先给出示例的 Typst 源码，再展示渲染效果。

## 字体

正文使用 IBM Plex Mono，标题使用 Rajdhani，均为自托管。Typst 绘制的插图和预览图使用 `typst-fonts/` 里的同两套字体，因此在任何构建机器上效果都一致。中日韩文字在页面和插图中都回退到系统字体。

> [!NOTE]
> 中文推荐使用[更纱黑体](https://github.com/be5invis/Sarasa-Gothic/releases)（Sarasa Gothic SC）。在构建机器上安装后，在 `tola.toml` 的 `[modules.nasapunk.options]` 中设置 `cjk-font = "Sarasa Gothic SC"`，插图和预览图也会使用它。

## 致谢

基于 [Tola](https://github.com/tola-rs/tola-ssg) 和 [Typst](https://typst.app) 构建。插图使用 [CeTZ](https://github.com/cetz-package/cetz)，搜索使用 [Pagefind](https://pagefind.app)。字体：[IBM Plex Mono](https://github.com/IBM/plex) 与 [Rajdhani](https://github.com/itfoundry/rajdhani)。

## 许可证

主题以 [MIT 许可证](LICENSE) 发布。随附字体使用 SIL Open Font License 1.1，许可证原文见 `theme/assets/webfonts/` 与 `typst-fonts/`。

## Star History

<a href="https://www.star-history.com/#KKKZOZ/tola-theme-nasapunk&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=KKKZOZ/tola-theme-nasapunk&type=Date&theme=dark">
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=KKKZOZ/tola-theme-nasapunk&type=Date">
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=KKKZOZ/tola-theme-nasapunk&type=Date">
  </picture>
</a>
