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

### 从模板开始

最简单的方式：本仓库的副本本身就是一个可以直接使用的博客，主题位于 `theme/`。

```sh
# 1. 获取模板的 preview 分支
git clone --branch preview https://github.com/KKKZOZ/tola-theme-nasapunk.git my-blog
cd my-blog

# 2. 安装 Pagefind 并启动开发服务器
npm install
tola dev
```

打开 <http://127.0.0.1:5277>。`tola dev` 会在保存时自动重新构建；`tola build` 把完整站点（含搜索索引）输出到 `public/`。

然后换成你自己的内容：

1. 在 `tola.toml` 的 `[site]` 里填写站点标题、作者名、简介和语言。
2. 在 `tola.toml` 的 `[modules.nasapunk.options]` 里设置主题选项，例如文档编号前缀。所有选项及其默认值都列在 `theme/tola-module.toml` 中。
3. 用你自己的文章替换 `content/posts/` 里的示例，并修改 `content/about.typ`。

属于你自己的文件都在 `theme/` 之外：`tola.toml`、`site.typ`、`content/`、`assets/` 和 `typst-fonts/`。更新主题时，用新版本的 `theme/` 替换即可，或者按下文的方式从 Git 获取。

### 作为模块使用

你自己的站点也可以直接从 Git 引用主题：Tola 会自动获取它，`tola update nasapunk` 可以升级。在 `tola.toml` 中：

```toml
[build]
entry = { module = "nasapunk" }

[modules.nasapunk]
git = { url = "https://github.com/KKKZOZ/tola-theme-nasapunk", branch = "preview", subdir = "theme" }

[modules.nasapunk.options]
doc-prefix = "TN"

[typst.fonts]
paths = ["typst-fonts"]
system = true
```

把本仓库的 `typst-fonts/` 复制到站点中，插图才会使用主题的字体；再在站点里运行 `npm install pagefind` 以启用搜索（或者在 `[modules.nasapunk.options]` 中设置 `search = false`）。文章放在 `content/posts/`，从主题导入组件：

```typst
#import "@tola/source:0.0.0": tola-meta
#import "@tola-modules/nasapunk:0.0.0": callout

#tola-meta((title: "Hello", date: "2026-11-10", summary: "The first post."))

#callout(kind: "info")[Written with NASApunk.]
```

### Typst 值类型的设置

额外的 `<head>` 内容（如统计脚本）和每篇文章末尾的内容（如评论区）是 Typst 值，不能写在 TOML 里。在 `[build]` 中设置 `entry = "site.typ"`，然后在 `site.typ` 里把它们传给 `render-site`；模板自带的 `site.typ` 中有这两项的示例。

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
