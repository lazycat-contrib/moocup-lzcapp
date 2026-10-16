# moocup-lzcapp

[Moocup](https://github.com/jellydeck/moocup) 的 LazyCat LPK 打包 —— 浏览器里的精美截图工具（SvelteKit 静态站）。

## 形态

- 纯静态：`pnpm build` 产出 `build/`，`file:///lzcapp/pkg/content/` 直出
- 版本权威：**以上游 GitHub Release 的 tag 为准**（非分支、非镜像）
  - `build.sh` 调 GitHub Releases API，用 `scripts/pick-release-tag.py` 选出最高稳定 SemVer tag
  - 按该 tag 下载源码 tarball 构建，因此产物与 release 一一对应
  - workflow 的 `version` job 把上游最新 release tag 与当前 `package.yml` 比较，只在变化时发布
- 构建要点：pnpm 默认拦截依赖 postinstall；上游 `pnpm-workspace.yaml` 用的旧 `onlyBuiltDependencies` 键，构建前改写为 `allowBuilds: {esbuild: true}`

## 结构

- `package.yml` — LPK v2 包元数据（`community.lazycat.app.moocup`）
- `lzc-manifest.yml` — 静态文件直出
- `lzc-build.yml` — `build.sh` + `contentdir: ./dist`
- `build.sh` — 解析上游 release tag → 拉取源码 → pnpm 构建 → 拷贝到 `dist/`
- `scripts/pick-release-tag.py` — 从 GitHub releases JSON 选出最高稳定 SemVer tag
- `.github/workflows/lazycat.yml` — 每日检查上游 release + 发布喵喵商店
