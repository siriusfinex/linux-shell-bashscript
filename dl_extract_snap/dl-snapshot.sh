#!/bin/bash

# ==========================================
# 1. 配置参数 (请根据实际情况修改)
# ==========================================
DOWNLOAD_LIST="download_list.txt"                 # 包含下载链接的文本文件
DOWNLOAD_DIR="/node/archive/bsc/downloads"        # 压缩包临时下载目录
TARGET_DIR="/node/archive/bsc/reth-triedb"        # 解压后的目标目录
CPU_CORES=$(nproc)                                # 动态获取 CPU 核心数

# ==========================================
# 2. 危险操作高亮预警与确认
# ==========================================
echo -e "\n============================================================"
echo -e " [!!!] 高危操作预警 [!!!]"
echo -e " 本脚本在解压阶段 (步骤 3) 将会【清空】以下目录中的所有残留文件："
echo -e " 目标路径: \033[31m$TARGET_DIR\033[0m"
echo -e "============================================================\n"

# 强制用户确认，避免手滑
read -p "请仔细确认上述路径是否正确！确认无误请按回车键 (Enter) 继续，或按 Ctrl+C 退出..."

# ==========================================
# 3. 信号捕获与初始化
# ==========================================
trap 'echo -e "\n\n[!] 收到中断信号，正在终止所有进程..."; exit 1' INT

mkdir -p "$DOWNLOAD_DIR" "$TARGET_DIR"

echo -e "\n系统检测到 $CPU_CORES 个 CPU 核心，将全速执行任务。"

# ==========================================
# 4. 下载状态侦测与 Aria2 批量下载
# ==========================================
echo -e "\n--- [1/3] 开始批量下载任务 | 按 Ctrl+C 退出 ---"
if [ ! -f "$DOWNLOAD_LIST" ]; then
    echo "[!] 错误：找不到下载列表文件 $DOWNLOAD_LIST"
    exit 1
fi

# 检查已下载文件和未完成文件
shopt -s nullglob
COMPLETED_FILES=()
INCOMPLETE_FILES=()

for zst in "$DOWNLOAD_DIR"/*.tar.zst; do
    if [ -f "${zst}.aria2" ]; then
        INCOMPLETE_FILES+=("$zst")
    else
        COMPLETED_FILES+=("$zst")
    fi
done
shopt -u nullglob

if [ ${#COMPLETED_FILES[@]} -gt 0 ]; then
    echo "[!] 提示：检测到指定下载路径已存在以下完整的压缩包："
    for f in "${COMPLETED_FILES[@]}"; do
        echo "    - $(basename "$f")"
    done
    echo "[!] 如果需要重新下载，请先手动退出脚本并删除上述压缩包。Aria2 将跳过这些已完成的文件。"
fi

if [ ${#INCOMPLETE_FILES[@]} -gt 0 ]; then
    echo "[*] 提示：检测到以下未下载完成的任务 (.aria2 文件存在)，Aria2 将开始接续下载："
    for f in "${INCOMPLETE_FILES[@]}"; do
        echo "    - $(basename "$f")"
    done
fi
echo "--------------------------------------------------------"

# 启动 Aria2
aria2c -c -x 16 -s 16 -j 3 --file-allocation=falloc --auto-file-renaming=false \
       -i "$DOWNLOAD_LIST" -d "$DOWNLOAD_DIR"

if [ $? -ne 0 ]; then
    echo "[!] Aria2 下载过程中出现错误，请检查网络或链接状态。"
    exit 1
fi
echo -e "\n下载阶段完成！\n"

# ==========================================
# 5. 动态扫描文件并找出最大压缩包
# ==========================================
echo "--- [2/3] 扫描压缩包与环境准备 ---"
shopt -s nullglob
FILES=("$DOWNLOAD_DIR"/*.tar.zst)
shopt -u nullglob

if [ ${#FILES[@]} -eq 0 ]; then
    echo "[!] 下载目录中未找到任何 .tar.zst 文件，脚本退出。"
    exit 1
fi

LARGEST_FILE=""
MAX_SIZE=0

for FILE in "${FILES[@]}"; do
    SIZE=$(stat -c%s "$FILE")
    if [ "$SIZE" -gt "$MAX_SIZE" ]; then
        MAX_SIZE=$SIZE
        LARGEST_FILE="$FILE"
    fi
done

echo "扫描完毕，共发现 ${#FILES[@]} 个压缩包。"
echo "最大文件为: $(basename "$LARGEST_FILE") (解压后将被保留)"
echo "--------------------------------------------------------"

# ==========================================
# 6. 环境清理、极速解压与自动删除
# ==========================================
echo "--- [3/3] 开始极速解压与清理 ---"

# 安全清空目标目录
# 注意：${TARGET_DIR:?} 是一种 Bash 安全机制。如果该变量为空或未设置，脚本将直接报错并停止，防止执行 rm -rf /*
echo "正在清空解压目标目录: $TARGET_DIR 以防止数据残留..."
rm -rf "${TARGET_DIR:?}/"*
echo "目录已清空。"
echo "--------------------------------------------------------"

for FILE in "${FILES[@]}"; do
    echo "正在解压: $(basename "$FILE")"
    
    # 核心解压指令
    pv "$FILE" | pzstd -dq -p "$CPU_CORES" | tar -xf - -C "$TARGET_DIR"

    # 严谨的错误检查
    if [ ${PIPESTATUS[0]} -ne 0 ] || [ ${PIPESTATUS[1]} -ne 0 ] || [ ${PIPESTATUS[2]} -ne 0 ]; then
        echo -e "\n[!] 解压 $(basename "$FILE") 时出错，脚本已停止，文件未删除以备排查。"
        exit 1
    fi

    echo -e "\n完成解压: $(basename "$FILE")"
    
    # 判断并清理非最大文件
    if [ "$FILE" != "$LARGEST_FILE" ]; then
        echo "清理空间：正在删除 $(basename "$FILE") ..."
        rm -f "$FILE"
        echo "已删除。"
    else
        echo "保留最大压缩包：$(basename "$FILE")"
    fi
    echo "-------------------------------------------"
done

echo "所有自动化任务均已圆满完成！节点数据已就绪至: $TARGET_DIR"