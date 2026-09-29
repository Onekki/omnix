# NixOS + Niri + DMS + Rime

适用于本机 Intel i5-12400 / UHD Graphics 730 的 x86_64 桌面配置模板。flake 配置名是 `desktop`，系统主机名是 `nixos`，用户名是 `admin`；时区为 `Asia/Shanghai`，TTY 默认使用英文区域以避免中文显示为方块，Niri 启动的图形应用使用中文区域和英文键盘布局。桌面登录使用 dms-greeter，Fcitx5 通过 XDG autostart 启动，DMS 由 systemd 用户服务启动。Fcitx5 的键盘英语和雾凇拼音可用 `Ctrl+Space` 切换，托盘图标换成干净的矢量"中"/"A"图标，候选窗使用 Material 主题。DMS 的系统监控、文件搜索和日历组件也已纳入配置。

## 目录

```text
.
├── flake.nix
├── .gitignore
├── scripts/setup.sh                # 复制硬件配置并重建当前 flake
├── hosts/desktop/
│   ├── default.nix                 # 这台机器的启动和硬件设置
│   └── hardware-configuration.nix # setup.sh 生成，Git 忽略
├── modules/nixos/
│   ├── base.nix                    # 区域、网络等基础设置
│   ├── desktop.nix                 # DMS、greeter、dsearch、DankCalendar 等
│   ├── apps.nix                    # Microsoft Edge、VS Code 等用户应用
│   ├── plugins.nix                 # DMS 插件及其运行时依赖
│   └── input-method.nix            # Fcitx5 + Rime
└── home/nixos/
    ├── default.nix                 # Home Manager 入口
    ├── dms.nix                     # DMS、Qt、终端会话环境
    ├── fcitx5.nix                  # Fcitx5 autostart + 托盘图标（替换默认 Rime 图标）
    ├── fish.nix
    └── rime.nix                   # 生成 Rime default.custom.yaml
```

## 从 minimal 系统迁移

先用[官方 NixOS 安装手册](https://nixos.org/manual/nixos/stable/#sec-installation)和官方 minimal ISO 按普通方式安装系统，使用生成的 `/etc/nixos/configuration.nix` 完成 `nixos-install`，然后重启进入刚安装的 minimal 系统。本仓库在重启后才使用，不参与安装介质中的安装步骤。安装时创建有 `wheel`/sudo 权限的普通用户 `admin`，并确保网络可用。

以该普通用户登录后，把仓库 clone 到固定目录 `~/.nixos`。minimal 系统如果没有 Git，可以先进入临时环境：

```sh
nix-shell -p git
git clone '你的仓库 Git 地址' "$HOME/.nixos"
exit
```

运行脚本前先核对两处配置：

- `flake.nix` 中 `userName = "admin"` 必须对应要使用 DMS 桌面的实际登录用户；如安装时用了其他用户名，先改这里。`configurationName = "desktop"` 是 flake 配置名，`hostName = "nixos"` 是迁移后系统的网络主机名，两者不必相同。
- 将原系统 `/etc/nixos/configuration.nix` 中的 `system.stateVersion` 原值写入 `~/.nixos/hosts/desktop/default.nix`。不要因为迁移到 unstable 而提高它。该文件目前假定 UEFI 启动、ESP 挂载到 `/boot`；若实际引导方式或挂载点不同，先按原系统的配置调整 bootloader 设置。硬件文件中的磁盘 UUID 会由本机文件复制，不需要手填。

然后以普通用户执行：

```sh
bash "$HOME/.nixos/scripts/setup.sh"
```

脚本默认交互式询问硬件文件来源、配置名，并在执行前要求确认。它从 `/etc/nixos/hardware-configuration.nix` 复制到仓库的 `hosts/desktop/`，以当前用户生成 `flake.lock`，再通过 sudo 执行 `nixos-rebuild switch --flake "path:$HOME/.nixos#desktop"`。普通用户生成锁文件时只临时启用 flakes；首次重建由 root 优先使用清华 TUNA、中科大 USTC 的 Nix 二进制缓存，最后回退到官方缓存，避免普通用户覆盖缓存设置时出现 `ignoring untrusted substituter` 警告。系统切换后也会保持这个缓存顺序。flake 中的 nixpkgs、Home Manager、DMS 等源码仍从其 GitHub 上游获取，缓存配置不改变源码下载地址。`hardware-configuration.nix` 被 Git 忽略；构建使用 `path:` URL，以包含这份本机文件。以后应将生成的 `flake.lock` 纳入仓库，保持版本可重复。

`--source` 可指定其他硬件文件，`--profile` 可指定其他原生 NixOS 配置目录；旧参数 `--host` 也可使用。`--no-rebuild` 只复制硬件配置，`--non-interactive` 跳过交互提问。迁移后更新软件源可运行 `nix flake update "path:$HOME/.nixos"`，再执行 `nrs` 重建。`hosts/desktop` 只用于原生桌面；NixOS-WSL 需要单独的 `hosts/wsl` 和 WSL 专用模块。

Niri 的全部快捷键由 DMS 生成的 `dms/binds.kdl` 管理：`Mod+T` 打开 Ghostty 终端、`Mod+Space` 打开 DMS 启动器、`Mod+V` 剪贴板、`Mod+M` 任务管理器、`Mod+Comma` 设置、`Mod+Alt+L` 锁屏、`Mod+Shift+E` 退出、`Print`/`Ctrl+Print`/`Alt+Print` 截图，音量与亮度使用 `XF86*` 键并走 DMS 的 IPC，窗口、工作区和布局操作为 niri 默认键集。按 `Mod+Shift+/` 可显示按键帮助；`dms ipc` 可查看全部 IPC 命令。`Ctrl+Space` 切换中英文。Rime 通过 `rime_ice_suggestion.yaml` 使用雾凇拼音的完整上游默认配置，首选方案为雾凇全拼，也保留 Ice 自带的其他方案。用户词库在 `~/.local/share/fcitx5/rime`，重建系统不会清除；建议单独备份。

普通用户的默认登录 shell 是 Fish；Ghostty 是 DMS 的首选终端，其配置由首次 `dms setup headless --compositor niri --terminal ghostty --force` 全默认生成（`theme = dankcolors`），主题文件随后由 DMS 在切换壁纸或主题时生成到 `~/.config/ghostty/themes/dankcolors`，换壁纸、换主题时 Matugen 都会按官方流程覆盖。纯 TTY 中直接运行 Ghostty 会因缺少图形会话（没有 `WAYLAND_DISPLAY`）而报错，属正常现象。终端底色由当前 DMS 主题的 Matugen 配色决定，偏黑是深色主题的正常表现，更换壁纸或主题即可改变。Fish 提供 `ll`、`la` 和 `nrs` 别名；`nrs` 直接运行 `sudo nixos-rebuild switch --flake 'path:/home/admin/.nixos#desktop'`。从 Kitty 迁移过来时，旧的 `~/.config/kitty` 目录可一并删除。

DMS 使用上游主分支，与 nixpkgs unstable 一起通过 `flake.lock` 固定具体版本；更新锁文件时可能需要按新版模块调整配置。系统模块自动安装 Matugen、Cava、NetworkManager 集成和 Khal 等可选依赖。另外安装 `dgop` 供资源监控使用，启用 DankSearch (`dsearch`) 用户服务供启动器搜索文件，启用 DankCalendar (`dcal`) 用户服务。日历账户需在 DankCalendar 中自行添加；Khal 是 DMS 日历事件的另一种数据来源，未配置账户时不会自动出现事件。通过 `dms-plugin-registry` 启用了 Bing 每日壁纸插件（`wallpaperBing`），系统安装 `curl` 和 `inotify-tools` 供其使用，并为 systemd 用户服务补充默认 PATH（含 `/run/current-system/sw/bin`）。

按 [应用主题文档](https://danklinux.com/docs/dankmaterialshell/application-themes) 安装了 `adw-gtk3`。在 DMS 设置的 **Theme & Colors** 中启用 **Apply GTK Themes**，GTK 应用便会使用 DMS 生成的配色；Qt 使用官方推荐的 GTK passthrough，会话环境同时提供给 systemd 用户服务和 Niri 启动的应用，Ghostty 的 `dankcolors` 主题也会随 DMS 切换自动适配。已安装 Papirus 图标主题，可在 GTK/DMS 设置中选择。默认浏览器是 Microsoft Edge（不属于 DMS 内置动态主题模板，浏览器界面如需跟随主题可另装扩展）；Visual Studio Code 已安装，可在扩展市场安装 "DMS - Dank Material Shell Theme"（或 `dms-theme.vsix`）使用与 DMS 主题联动的编辑器配色。

Niri 的 `config.kdl` 由 DMS 全默认生成：home-manager 激活在配置缺失时执行一次 `dms setup headless --compositor niri --terminal ghostty --force`（首次迁移会先清理旧 home-manager 符号链接），按 [DMS 合成器文档](https://danklinux.com/docs/dankmaterialshell/compositors#niri-configuration) 加载 DMS 生成的 `colors`、`layout`、`alttab`、`binds` 片段（另有 `outputs`、`cursor`、`input`），含 `XDG_CURRENT_DESKTOP=niri` 环境变量；LANG 与 Qt GTK passthrough 等由 `environment.d` 提供给会话。切换 DMS 主题后 Matugen 会覆盖 `colors` 等片段与 Ghostty 主题。布局使用透明背景，壁纸层会显示在概览中。DMS 已通过 systemd 用户服务启动，不需要在 Niri 中再次启动。

NixOS 仍通过 `nixos-rebuild` 更新；[DMS 内置系统更新器](https://danklinux.com/docs/dankmaterialshell/cli-system-updater) 当前未列出 NixOS 后端。DMS 支持的应用、图标和动态模板可用 `dms doctor` 检查。

登录界面按 [DMS 的 NixOS 文档](https://danklinux.com/docs/dankgreeter/nixos) 使用 nixpkgs 自带的 dms-greeter 模块，Niri 是登录界面的合成器。`configHome` 指向当前用户目录，greeter 启动时会复制该用户已有的 DMS 设置、配色和壁纸状态；首次登录前尚无用户主题可同步。

## 检查

运行 `setup.sh` 生成硬件文件后，可在有 Nix 的环境中运行 `nix flake check "path:$HOME/.nixos"`。登录后可运行 `dms doctor`、`systemctl --user status dms dsearch dcal` 和 `fcitx5-diagnose`，分别确认 DMS、配套服务和输入法。niri/Ghostty 的首次初始化随 `nrs` 执行，也可手动重跑：`dms setup headless --compositor niri --terminal ghostty --force`。

如果 Niri 里没有 DMS 快捷键，请按顺序检查：

```bash
dms setup headless --compositor niri --terminal ghostty --force
ls -la ~/.config/niri/dms/
head -n 30 ~/.config/niri/dms/binds.kdl
```
