#!/bin/bash
set -e

echo "=== 开始全自动、零交互 Zsh 环境配置 ==="

# 1. 安装基础依赖
echo "1/5 正在安全下载基础依赖..."
sudo apt update && sudo apt install -y zsh curl git fonts-powerline

# 2. 更改默认 Shell
CURRENT_SHELL=$(getent passwd "$USER" | cut -d: -f7)
if [ "$CURRENT_SHELL" != "/usr/bin/zsh" ]; then
    echo "2/5 正在将默认 Shell 更改为 Zsh (可能需要输入密码)..."
    sudo chsh -s /usr/bin/zsh "$USER"
fi

# 3. 自动化安装 Oh My Zsh (禁止其自动抢占终端)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "3/5 正在安装 Oh My Zsh..."
    export CHSH=no
    export RUNZSH=no
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 4. 下载自动化的高效插件
PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
echo "4/5 正在下载自动补全与语法高亮插件..."
[ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ] && git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git "$PLUGINS_DIR/zsh-autosuggestions"
[ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ] && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGINS_DIR/zsh-syntax-highlighting"

# 5. 核心：全自动写入配置文件 (自动判断 TTY 和图形界面)
echo "5/5 正在注入免配置参数..."

# 备份原有的 .zshrc
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.bak

# 重新生成一份纯净、完美的配置文件
cat << 'EOF' > ~/.zshrc
# 路径设置
export ZSH="$HOME/.oh-my-zsh"

# 【智能环境识别】如果是真 TTY 纯文本界面，使用 robbyrussell 确保绝不乱码
# 如果是图形界面终端，使用带箭头的经典 agnoster 主题
if [[ "$TTY" == /dev/tty[0-9]* ]]; then
    ZSH_THEME="robbyrussell"
else
    ZSH_THEME="agnoster"
fi

# 隐藏agnoster主题前面的 👤 用户名@主机名，让终端更清爽
DEFAULT_USER="$USER"

# 启用的核心插件 (无需任何手动加载)
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# 加载 Oh My Zsh
source $ZSH/oh-my-zsh.sh

# 自动补全的快捷键优化（按 ➔ 键或 Ctrl+F 直接补全）
bindkey '^f' forward-word
EOF

echo "--------------------------------------------------------"
echo "✅ 搞定！已实现全自动化配置，期间无需任何键盘输入！"
echo "👉 请关闭当前终端窗口，重新打开一个新的终端即可直接使用。"
echo "--------------------------------------------------------"

# 自动无缝切入新 zsh
exec zsh -l