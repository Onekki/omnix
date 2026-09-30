# NixOS + Niri + DMS / Noctalia + Rime

基于 nixos-unstable 的 x86_64 桌面配置，支持在 **DMS + dms-greeter** 与 **Noctalia v5 + Noctalia Greeter** 之间切换。两者共用 Niri、Foot、Fish、Microsoft Edge、VS Code、Fcitx5 和雾凇拼音，以及同一份硬件配置。

系统主机名默认为 `nixos`，用户名为 `admin`，仓库放在 `~/.nixos`。TTY 使用英文区域，图形应用使用中文区域；时区为 `Asia/Shanghai`。本机已确认 VirtualBox 中 Kitty 硬件渲染黑屏，因此使用 CPU 绘制终端内容的 Foot。

## 切换桌面

| 命令 | flake 配置 | 桌面和登录界面 |
| --- | --- | --- |
| `nrsd` | `desktop-dms` | DMS + dms-greeter |
| `nrsn` | `desktop-noctalia` | Noctalia + Noctalia Greeter |
| `nrs` | 当前配置 | 重建当前选择 |

这些 Fish alias 都执行 `sudo nixos-rebuild switch --flake "path:$HOME/.nixos#…"`。**切换成功后重启**，使 greeter、Niri 和会话环境一起生效；greetd 的 NixOS 模块默认不会在 rebuild 时重启，以免中断正在使用的登录会话。不会自动重启电脑。

旧的 `#desktop` 仍兼容，指向 `#desktop-dms`。它不是“当前桌面”的动态别名；日常保留当前选择请用 `nrs`。两个配置中的 `nrsd`、`nrsn` 始终都存在。

如果还没有这些 alias，可先直接执行：

```sh
sudo nixos-rebuild switch --flake "path:$HOME/.nixos#desktop-noctalia"
sudo reboot
```

本次新增了提交到仓库的 `flake.lock`。如果本地已有以前 `setup.sh` 生成但未跟踪的同名文件，先备份它再 `git pull`，避免 Git 拒绝覆盖：

```sh
mv --backup=numbered ~/.nixos/flake.lock ~/.nixos/flake.lock.local-backup
```

## 目录与抽象

```text
.
├── flake.nix                       # 两个配置，共用 mkDesktop
├── flake.lock                      # 固定依赖版本
├── scripts/setup.sh                # 复制硬件文件，选择 shell，默认重建
├── hosts/desktop/
│   ├── default.nix                 # 硬件、启动与功能入口
│   └── hardware-configuration.nix  # 本机生成，Git 忽略
├── modules/nixos/
│   ├── base.nix                    # 区域、网络、Nix 缓存
│   ├── desktop.nix                 # 公共 Niri、音频、字体、会话环境
│   ├── apps.nix                    # 公共应用
│   ├── shell/
│   │   ├── default.nix             # 选择 dms 或 noctalia
│   │   ├── dms.nix                 # DMS、dms-greeter、dsearch、dcal、dgop
│   │   └── noctalia.nix            # Noctalia、Noctalia Greeter、推荐服务
│   ├── input-method/
│   │   ├── default.nix             # 输入法实现选择入口
│   │   └── fcitx5.nix              # Fcitx5 + Rime Ice 的具体实现
│   └── plugins/dms.nix             # DMS 插件及依赖，与 apps 分开
└── home/nixos/
    ├── default.nix                 # 公共 Home Manager 入口
    ├── session.nix                 # 中文图形环境、Foot、Qt 设置
    ├── fish.nix                    # Fish 与 nrs/nrsd/nrsn
    ├── foot.nix                    # 公共字体与外观，主题由 shell 提供
    ├── shell/{default,dms,noctalia}.nix
    ├── input-method/{default,fcitx5,rime}.nix
    └── niri/noctalia.nix           # 独立的 Noctalia Niri 会话配置
```

`hosts/desktop` 只导入功能入口。`shell/default.nix` 只负责选择实现，每个实现同时管理 shell 和 greeter，不再分开选择 display-manager。`mkDesktop` 的 `shell` 仅支持 `dms`、`noctalia`；输入法通过独立的 `inputMethod` 参数选择，默认 `fcitx5`。未来新增输入法时，在系统和 Home Manager 的 `input-method/` 中添加实现并登记到 `default.nix`，无需改动 shell 模块。未知实现会直接报错。

`hosts/desktop` 表示机器类别，DMS/Noctalia 是这台机器的两种桌面配置，因此不会重复创建硬件文件或 `hosts/dms`、`hosts/noctalia`。将来 NixOS-WSL 应添加独立的 `hosts/wsl`。

## 从官方 minimal 系统迁移

先按[官方安装手册](https://nixos.org/manual/nixos/stable/#sec-installation)用 minimal ISO 安装 NixOS，创建有 wheel/sudo 权限的普通用户并重启。此仓库用于安装完成后的配置迁移。

```sh
nix-shell -p git
git clone https://github.com/Onekki/omnix.git "$HOME/.nixos"
exit
```

运行前核对：

- `flake.nix` 中的 `userName`、`hostName` 必须符合本机需求；默认用户为 `admin`。
- `hosts/desktop/default.nix` 的 `system.stateVersion` 应保留原系统值，不随 unstable 升级。当前模板为 `26.05`。
- 当前引导配置假定 UEFI、ESP 挂载在 `/boot`，其他安装方式需沿用原配置。

以普通用户执行：

```sh
bash "$HOME/.nixos/scripts/setup.sh"
```

脚本默认交互式询问硬件文件、主机 profile 和 shell（默认 `dms`），最后 `[Y/n]` 回车确认。硬件文件从 `/etc/nixos/hardware-configuration.nix` 复制到 `hosts/desktop/`，随后使用锁文件解析输入并重建 `#desktop-dms` 或 `#desktop-noctalia`。`path:` URL 确保构建能看到被 Git 忽略的本机硬件文件。完成后重启。

支持 `--shell noctalia`、`--source FILE`、`--profile desktop`（兼容 `--host`）、`--no-rebuild` 和 `--non-interactive`。`--profile` 是主机目录名，shell 通过 `--shell` 单独选择。例如：

```sh
bash ~/.nixos/scripts/setup.sh --shell noctalia
```

Nix 二进制缓存优先使用 TUNA、USTC，再使用官方缓存；flake 源码仍来自各项目 GitHub。更新软件源运行 `nix flake update "path:$HOME/.nixos"`，再运行 `nrs`。

## 两套 shell 的配置边界

DMS 使用官方 NixOS 模块、dms-greeter、DankSearch、DankCalendar 和 dgop。Bing 壁纸插件通过官方 registry 安装，在 DMS 设置里启用并配置每日更新。DMS 的 Niri 配置保留为可写的 `~/.config/niri/config.kdl`，首次激活通过官方 `dms setup` 初始化。`Mod+T` 的旧终端命令会迁为 Foot，修改前备份 `binds.kdl`。

Noctalia 使用[官方 v5 NixOS 和 Home Manager 模块](https://docs.noctalia.dev/noctalia/getting-started/nixos/)，登录使用[官方文档推荐的 nixpkgs Noctalia Greeter 模块](https://docs.noctalia.dev/greeter/installation/#nixos-declarative-setup)。启用官方推荐的 NetworkManager、Bluetooth、UPower 和电源模式服务，shell 通过 systemd 启动，并按文档启用应用独立 systemd 服务。基础设置由 Home Manager 生成，GUI 修改保存在 `~/.local/state/noctalia/settings.toml`，切回 DMS 不会删除这些偏好。

Noctalia 的 Niri 配置是 `~/.config/niri/noctalia-session.kdl`；`NIRI_CONFIG` 在登录时选择它或 DMS 配置。Noctalia 配置保留 Niri 默认的窗口、工作区、截图、退出快捷键，应用启动、锁屏、音量和亮度接入 Noctalia IPC；另有 `Mod+Space` 启动器、`Mod+S` 控制中心、`Mod+Shift+Comma` 设置、`Mod+Alt+V` 剪贴板、`Alt+Tab` 窗口切换。`Mod+Comma` 和 `Mod+V` 保留 Niri 默认窗口操作。构建时使用 `niri validate` 检查配置。

两个 shell 的 systemd 服务互斥；DMS 插件、激活逻辑、dsearch 和 dcal 只属于 DMS 配置。切换不会重写另一套 shell 的可写配置。两者的壁纸和插件偏好分别保存，不会自动互相转换。

## 终端与输入法

Foot 使用 Fira Code 和 Noto Sans Mono CJK SC、12 pt 字号、12 像素内边距、闪烁细线光标，输入时隐藏鼠标。字体和字号固定，不加入额外同步脚本。

DMS 配置加载 `~/.config/foot/dank-colors.ini`；Noctalia 配置加载 `~/.config/foot/themes/noctalia`。Noctalia 通过官方用户模板接口渲染其随包提供的 Foot 模板，避免主题安装钩子修改 Home Manager 管理的 `foot.ini`。两套配色都会随各自主题更新，新开 Foot 读取新颜色；不承诺现有 Foot 窗口热更新。

Fcitx5 通过 XDG autostart 启动，`Ctrl+Space` 切换英语与雾凇拼音。Rime 使用上游 `rime_ice_suggestion` 配置，用户词库位于 `~/.local/share/fcitx5/rime`，建议单独备份。候选窗的 Material 主题在 classicui 插件配置中声明，托盘使用仓库内的“中”/“A”图标。

## 验证与排错

生成本机硬件文件后：

```sh
nix flake check "path:$HOME/.nixos"
```

登录 DMS 后检查 `systemctl --user status dms dsearch dcal`、`dms doctor`；登录 Noctalia 后检查 `systemctl --user status noctalia`、`noctalia config validate`、`niri validate --config ~/.config/niri/noctalia-session.kdl`。登录界面问题用 `journalctl -u greetd -b`，输入法问题用 `fcitx5-diagnose`。

### VirtualBox 中 Noctalia 登录界面黑屏

本机日志显示 Noctalia Greeter 1.6.0 成功初始化 EGL 后，wlroots 0.20.2 报 `Failed to close buffer handle for plane 0: Invalid argument`，随后 Wayland 连接断开。VMSVGA 使用 vmwgfx；它导入的部分 DMA-BUF 是 TTM surface 句柄，通用的 `GEM_CLOSE` 无法释放。这与[上游报告](https://github.com/hyprwm/Hyprland/issues/16175)中的问题吻合。

`shell/noctalia.nix` 仅覆盖 Noctalia Greeter 的 wlroots 依赖，应用 `patches/wlroots-vmwgfx-handles.patch`：只有 `GEM_CLOSE` 返回 `EINVAL` 且驱动确认为 vmwgfx 时，才调用 `DRM_VMW_UNREF_SURFACE`。客户端缓冲区校验和 framebuffer 清理共用这一处理；释放失败仍然报错。该补丁是根据上游提议移植的本地兼容修复，尚未合入 wlroots；补丁本身不改变渲染后端。首次重建需要编译 wlroots 和 greeter；上游修复后应删除此覆盖。

**当前启用了经确认的软件渲染对照测试。** 句柄补丁应用后，登录界面能够显示，但日志记录 `eglSwapBuffers` 阻塞约 13.5 秒，仍然无法正常操作。为区分硬件渲染与其他原因，`shell/noctalia.nix` 在 greetd 的登录器启动命令中显式设置 `WLR_RENDERER=pixman` 和 `LIBGL_ALWAYS_SOFTWARE=1`，分别用于登录器的合成器和界面；`WLR_LOG=info` 记录所选后端。这些变量只传给登录器进程，不写入全局环境，也不传给登录后的 Niri/Noctalia 桌面。句柄补丁保留，以便对照。

拉取后执行 `nrsn` 并重启，测试密码框输入、登录和 `Ctrl+Alt+F3`。上述日志中应出现 pixman，以及 Mesa 的软件渲染器（通常为 llvmpipe）。这次测试尚不代表卡死已经修复，也不会在一次启动后自动撤销。测试结束后，删除 `shell/noctalia.nix` 中带有 `Temporary` 注释的 `services.greetd.settings.default_session.command` 覆盖，执行 `nrsn` 并重启，即恢复上游的渲染后端选择。

Noctalia 将自身日志写到单独的 syslog 标识，仅筛选 `-u greetd` 可能遗漏关键错误。查看当前启动：

```sh
sudo journalctl -b -t noctalia-greeter -t noctalia-greeter-compositor --no-pager -n 150
```

若无法切换 TTY，在 VirtualBox 软键盘中发送 `Ctrl+Alt+F3`。仍无法进入时，重启并按住空格打开 NixOS 启动菜单，选中系统按 `e`，在启动参数末尾临时追加 `systemd.unit=multi-user.target`，回车进入文字登录。此时用 `-b -1` 查看上一次黑屏启动的日志，再拉取修复并执行 `nrsn`，完成后重启。

依赖通过 `flake.lock` 固定。Noctalia 与主系统共用 nixpkgs unstable；按官方说明，这种 follows 配置不保证命中 Noctalia Cachix，首次构建可能需要本地编译。虚拟机中是否能正常显示仍需实机验证；软件渲染仅用于上述明确启用的登录器诊断，不进行失败后的自动切换。
