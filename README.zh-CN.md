<div align="center">

<img src="assets/favicon.svg" width="84" alt="">

# NASApunk

**一个 NASApunk 风格的 [Tola](https://github.com/tola-rs/tola-ssg) 博客主题。**

用 Typst 写文章，插图、图表和公式渲染为内联 SVG，跟随主题的日夜配色。

[![Build](https://github.com/KKKZOZ/tola-theme-nasapunk/actions/workflows/build.yml/badge.svg)](https://github.com/KKKZOZ/tola-theme-nasapunk/actions/workflows/build.yml)
[![Tola](https://img.shields.io/badge/Tola-0.8%2B-cb4b22)](https://github.com/tola-rs/tola-ssg)
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
- [配置](#配置)
- [写文章](#写文章)
- [组件](#组件)
- [部署](#部署)
- [目录结构](#目录结构)
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

需要 [Tola](https://github.com/tola-rs/tola-ssg) 0.8 或更新版本，以及 Node.js（用于生成搜索索引）。

```sh
# 1. 获取主题：在 GitHub 上点 "Use this template"，或者
git clone https://github.com/KKKZOZ/tola-theme-nasapunk.git my-blog
cd my-blog

# 2. 安装 Tola（也可以从它的 release 页面下载预编译版本）
cargo install --locked tola

# 3. 安装 Pagefind 并启动开发服务器
npm install
tola dev
```

打开 <http://127.0.0.1:5277>。`tola dev` 会在保存时自动重新构建；`tola build` 把完整站点（含搜索索引）输出到 `public/`。

每次重新构建后，`tola dev` 还会报告 `math-check` hook 失败，列出六个无法复制为 LaTeX 的公式：

```text
error[hook.after_publish]: the `math-check` hook in `build.hooks.after-publish` failed: the command exited with status 1
 = stderr:
   6 formulas cannot copy as LaTeX

   warning: formula cannot copy as LaTeX
      ┌─ content/posts/math.typ:35:1
      │
   35 │ $x + #box(stroke: .5pt, inset: 2pt)[$y$]$. Written with `mi` instead, the
      │ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ no LaTeX for box
      │
      = it copies as \text{[unsupported formula]}
      = help: write it with `mi` / `mitex` to copy as written
   ...
```

这是正常的。网页上复制公式时会得到 LaTeX，示例文章 `content/posts/math.typ` 故意放了这六个转不了的公式来演示。站点照常构建和更新，`tola build` 也不会运行这项检查。删掉示例文章后，报告只会列出你自己文章里的公式，并指出它在源文件中的行号。

然后换成你自己的内容：

1. 在 `tola.toml` 的 `[site]` 里填写站点标题、作者名、简介和语言。
2. 在 `templates/config.typ` 里设置文档编号前缀。
3. 用你自己的文章替换 `content/posts/` 里的示例，并修改 `content/about.typ`。

## 配置

| 配置项 | 位置 |
| --- | --- |
| 标题、作者、简介、语言 | `tola.toml` → `[site]` |
| 站点公网地址（RSS、sitemap 和链接预览需要） | `tola.toml` → `origin` |
| 部署在子路径下，例如 `/blog/` | `tola.toml` → `base-path` |
| 文档编号前缀（`TN` → `TN-001`） | `templates/config.typ` → `doc-prefix` |
| 正文栏宽度（页头、列表页与文章共用） | `templates/config.typ` → `content-width` |
| 站点标题旁的橙色代号 | `templates/config.typ` → `mission` |
| 页脚链接（GitHub、邮箱、Mastodon 等） | `templates/config.typ` → `social-links` |
| 分享链接时的预览图：自动绘制（`auto`）、自己的图片或不用图 | `templates/config.typ` → `social-image` |
| 统计脚本等额外的 `<head>` 内容 | `templates/config.typ` → `head-extra` |
| 顶部导航链接 | `templates/layout.typ` → `nav-items` |
| 首页每页的文章数（其余在 `/page/2/`、`/page/3/` …） | `templates/pages.typ` → `shown` |
| 目录收录的标题层级 | `templates/post.typ` → `toc-depth` |
| RSS 收录的文章数；全文还是摘要 | `templates/feeds.typ` → `feed-size`、`full-text` |
| 配色 | `assets/styles/site.css` 开头的颜色变量，`templates/base.typ` 里的 `palette` 与之对应 |
| 搜索语言 | `scripts/search-index.mjs` → `forceLanguage`（见下文） |

搜索会根据 `[site] language` 识别语言。如果站点以中文为主，把 `scripts/search-index.mjs` 里的 `forceLanguage` 设为 `"zh"`。

## 写文章

`content/posts/` 下的每个 `.typ` 文件就是一篇文章，URL 与文件路径对应：`content/posts/notes/cache.typ` → `/posts/notes/cache/`。

```typst
#import "@tola/source:0.0.0": tola-meta
#import "/utils/ui.typ": callout

#tola-meta((
  title: "缓存一致性笔记",
  date: "2026-10-18",
  summary: "一句话简介，用于文章列表、搜索结果和链接预览。",
  tags: ("systems", "notes"),
  series: "Theme Tour",
))

= 第一节

#callout(kind: "warning")[先确认缓存状态，再相信延迟数据。]
```

| 字段 | 类型 | 说明 |
| --- | --- | --- |
| `title` | 字符串 | 必填。 |
| `date` | `"YYYY-MM-DD"` | 没有日期的文件照常发布，但不进文章列表。 |
| `updated` | `"YYYY-MM-DD"` | 最后修订日期：显示在标题下方，并用于 sitemap 和 RSS。 |
| `summary` | 字符串 | 用于文章列表、搜索结果和 Open Graph。 |
| `tags` | 字符串或数组 | 显示为标签，并汇总到 `/tags/`。 |
| `weight` | 整数 | 首页排序：数值小的在前，相同的按日期从新到旧。默认值是 100（Hugo 视为未设置的 0 也按 100 算），所以 `weight: 1` 可以置顶，`weight: 200` 可以沉底。其他列表仍按日期排序。 |
| `series` | 字符串 | 同名的文章组成一个系列。每篇正文前有系列导航框（第几篇 / 共几篇、前后两篇、全部篇目），`/series/` 页列出所有系列。系列至少有两篇才显示导航框。默认按日期从早到晚排列，可以用 `part` 指定顺序；导航框和 `/series/` 里会去掉标题开头的 `[Tour 01]` 这类标记。 |
| `part` | 整数 | 在系列中的位置：写了 `part` 的文章排在前面，按数字从小到大，其余按日期。数字不必连续。 |
| `draft` | 布尔值 | 草稿不会发布；指向草稿的链接显示为纯文本。 |

`content/lab/` 下的文件使用文章布局，但不进文章列表，适合放测试页面。示例文章 `/posts/style-reference/` 展示了主题支持的所有元素。

## 组件

| 模块 | 提供 |
| --- | --- |
| `utils/ui.typ` | `callout`、`hint`、`img`、`gallery`、`xref`、`related` |
| `utils/diagram.typ` | `flow`、`diagram`、`timeline` |
| `utils/cetz.typ` | 在 HTML 导出时输出内联 SVG 的 `cetz` |
| `utils/mitex.typ` | MiTeX 的 `mi` / `mitex`，用 LaTeX 写公式；网页上框选复制时得到你写的 LaTeX 原文（Typst 原生公式复制出等价的 LaTeX） |
| `utils/figure.typ` | 主题配色，以及绘制复杂 CeTZ 图用的辅助函数：`pill`、`arrow`、`curve-arrow`、`cells`、`seg`、`legend` 等 |

```typst
#import "/utils/ui.typ": callout, xref
#import "/utils/diagram.typ": flow, n

#callout(kind: "success")[构建通过。]

#flow(n[Source], [compile], n([HTML], tone: "accent"))

完整的 CeTZ 示例见 #xref("cetz-figures")。
```

示例文章里每个模块都有用到：`content/posts/theme-tour/` 演示提示框、脚注、流程图和时间线；`content/posts/figure-kit.typ` 逐个介绍 `utils/figure.typ` 里的函数，附效果图和函数签名；`content/posts/cetz-figures.typ` 是用这些函数画出的完整 CeTZ 图；`content/posts/math.typ` 介绍公式写法、`mi` / `mitex`，以及公式如何复制成 LaTeX。

## 部署

`tola build` 输出的是 `public/` 里的纯静态文件，任何静态托管都可以。

部署到 GitHub Pages 时，仓库里已经带了 `.github/workflows/deploy.yml`，在线演示就是用它发布的。在你自己的仓库里：

1. 把 **Settings → Pages → Source** 设为 **GitHub Actions**。
2. 删掉 `deploy.yml` 里的 `if:` 那一行。它的作用是让基于模板创建的仓库在你主动开启之前不会自动部署。
3. 推送到 `main`。

这个 workflow 会向 GitHub 查询站点地址并传给 `tola build`，所以同一份文件既适用于个人站点（`https://<user>.github.io/`），也适用于项目站点（`https://<user>.github.io/<repo>/`）。项目站点挂在 `/<repo>/` 路径下，不会影响你的个人站点。文章里以 `/` 开头的链接需要带上这个前缀；相对链接和 `xref` 在哪都能用，漏掉的链接会在构建时报错。

## 目录结构

```
├── site.typ              站点程序：生成所有页面
├── tola.toml             站点配置
├── typst-fonts/          插图使用的 IBM Plex Mono 与 Rajdhani
├── scripts/              构建 hook：搜索索引（Pagefind）、tola dev 时的公式检查；测试脚本
├── templates/            页面布局、页眉页脚、列表页
│   ├── config.typ        tola.toml 之外的站点设置
│   ├── feeds.typ         RSS 订阅源、sitemap 与 robots.txt
│   └── social.typ        分享链接的预览图
├── utils/                文章里用的组件（见上文）
├── assets/
│   ├── styles/site.css   全部样式；颜色变量在文件开头
│   ├── scripts/          主题切换、搜索、复制按钮、脚注、图片放大、公式断行
│   └── webfonts/         IBM Plex Mono 与 Rajdhani 的拉丁字符子集
├── content/
│   ├── posts/            示例文章
│   └── about.typ
├── tests/latex.typ       公式复制为 LaTeX 的测试用例：`npm test`，需要 Typst CLI
└── .github/workflows/    构建检查、测试与 GitHub Pages 部署
```

## 字体

正文使用 IBM Plex Mono，标题使用 Rajdhani，均为自托管。Typst 绘制的插图和预览图使用 `typst-fonts/` 里的同两套字体，因此在任何构建机器上效果都一致。中日韩文字在页面和插图中都回退到系统字体。

> [!NOTE]
> 中文推荐使用[更纱黑体](https://github.com/be5invis/Sarasa-Gothic/releases)（Sarasa Gothic SC）。在构建机器上安装后，在 `templates/config.typ` 中设置 `cjk-font = "Sarasa Gothic SC"`，插图和预览图也会使用它。

## 致谢

基于 [Tola](https://github.com/tola-rs/tola-ssg) 和 [Typst](https://typst.app) 构建。插图使用 [CeTZ](https://github.com/cetz-package/cetz)，搜索使用 [Pagefind](https://pagefind.app)。字体：[IBM Plex Mono](https://github.com/IBM/plex) 与 [Rajdhani](https://github.com/itfoundry/rajdhani)。

## 许可证

主题以 [MIT 许可证](LICENSE) 发布。随附字体使用 SIL Open Font License 1.1，许可证原文见 `assets/webfonts/` 与 `typst-fonts/`。

## Star History

<a href="https://www.star-history.com/#KKKZOZ/tola-theme-nasapunk&Date">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=KKKZOZ/tola-theme-nasapunk&type=Date&theme=dark">
    <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=KKKZOZ/tola-theme-nasapunk&type=Date">
    <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=KKKZOZ/tola-theme-nasapunk&type=Date">
  </picture>
</a>
