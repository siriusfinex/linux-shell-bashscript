#!/bin/bash

# ==========================================
# 1. 配置参数 (请根据实际情况修改)
# ==========================================
DOWNLOAD_LIST="download_list.txt"
DOWNLOAD_DIR="/node/archive/bsc/downloads"
TARGET_DIR="/node/archive/bsc/reth-triedb"
CPU_CORES=$(nproc)

# ==========================================
# 2. 危险操作高亮预警与确认
# ==========================================
echo -e "\n============================================================"
echo -e " [!!!] 高危操作预警 [!!!]"
echo -e " 本脚本在解压阶段 (步骤 3) 将会【清空】以下目录中的所有残留文件："
echo -e " 目标路径: \033[31m$TARGET_DIR\033[0m"
echo -e "============================================================\n"

read -p "请仔细确认上述路径是否正确！确认无误请按回车键 (Enter) 继续，或按 Ctrl+C 退出..."

# ==========================================
# 3. 信号捕获与初始化
# ==========================================
trap 'echo -e "\n\n[!] 收到中断信号，正在终止所有进程..."; exit 1' INT

mkdir -p "$DOWNLOAD_DIR" "$TARGET_DIR"

# 检查必备工具，新增 file 命令的检查
for cmd in aria2c pv pzstd pigz lz4 tar file; do
    if ! command -v $cmd &> /dev/null; then
        echo "[!] 错误: 未找到命令 $cmd，请先安装相应的包。"
        exit 1
    fi
done

echo -e "\n系统检测到 $CPU_CORES 个 CPU 核心，将全速执行任务。"

# ==========================================
# 4. 下载状态侦测与 Aria2 批量下载
# ==========================================
echo -e "\n--- [1/3] 开始批量下载任务 | 按 Ctrl+C 退出 ---"
if [ ! -f "$DOWNLOAD_LIST" ]; then
    echo "[!] 错误：找不到下载列表文件 $DOWNLOAD_LIST"
    exit 1
fi

COMPLETED_FILES=()
INCOMPLETE_FILES=()

# 遍历下载目录中的所有文件，利用底层文件头识别状态
for f in "$DOWNLOAD_DIR"/*; do
    [ -f "$f" ] || continue
    
    if [[ "$f" == *.aria2 ]]; then
        # 存在 .aria2 伴生文件，说明主文件未下载完成
        base_file="${f%.aria2}"
        INCOMPLETE_FILES+=("$base_file")
    else
        # 没有伴生文件，使用 file 命令侦测是否为支持的压缩包
        if [ ! -f "${f}.aria2" ]; then
            FILE_INFO=$(file -b "$f" | tr '[:upper:]' '[:lower:]')
            if [[ "$FILE_INFO" == *"zstandard"* ]] || [[ "$FILE_INFO" == *"gzip"* ]] || [[ "$FILE_INFO" == *"lz4"* ]] || [[ "$FILE_INFO" == *"tar archive"* ]]; then
                COMPLETED_FILES+=("$f")
            fi
        fi
    fi
done

if [ ${#COMPLETED_FILES[@]} -gt 0 ]; then
    echo "[!] 提示：检测到指定下载路径已存在以下完整的压缩包 (已通过文件头验证)："
    for f in "${COMPLETED_FILES[@]}"; do
        echo "    - $(basename "$f")"
    done
    echo "[!] 如果需要重新下载，请先手动退出脚本并删除上述压缩包。"
fi

if [ ${#INCOMPLETE_FILES[@]} -gt 0 ]; then
    echo "[*] 提示：检测到以下未下载完成的任务，Aria2 将开始接续下载："
    for f in "${INCOMPLETE_FILES[@]}"; do
        echo "    - $(basename "$f")"
    done
fi
echo "--------------------------------------------------------"

aria2c -c -x 16 -s 16 -j 3 --file-allocation=falloc --auto-file-renaming=false \
       -i "$DOWNLOAD_LIST" -d "$DOWNLOAD_DIR"

if [ $? -ne 0 ]; then
    echo "[!] Aria2 下载过程中出现错误，请检查网络或链接状态。"
    exit 1
fi
echo -e "\n下载阶段完成！\n"

# ==========================================
# 5. 动态扫描文件头并找出最大压缩包
# ==========================================
echo "--- [2/3] 扫描数据指纹与环境准备 ---"

FILES=()
LARGEST_FILE=""
MAX_SIZE=0

# 再次遍历目录，精准提取真正的压缩包文件（无视文件名后缀）
for f in "$DOWNLOAD_DIR"/*; do
    [ -f "$f" ] || continue
    [[ "$f" == *.aria2 ]] && continue

    FILE_INFO=$(file -b "$f" | tr '[:upper:]' '[:lower:]')
    
    if [[ "$FILE_INFO" == *"zstandard"* ]] || [[ "$FILE_INFO" == *"gzip"* ]] || [[ "$FILE_INFO" == *"lz4"* ]] || [[ "$FILE_INFO" == *"tar archive"* ]]; then
        FILES+=("$f")
        SIZE=$(stat -c%s "$f")
        if [ "$SIZE" -gt "$MAX_SIZE" ]; then
            MAX_SIZE=$SIZE
            LARGEST_FILE="$f"
        fi
    fi
done

if [ ${#FILES[@]} -eq 0 ]; then
    echo "[!] 下载目录中未找到任何受支持格式的底层文件，脚本退出。"
    exit 1
fi

echo "底层扫描完毕，共发现 ${#FILES[@]} 个有效的归档文件。"
echo "最大文件为: $(basename "$LARGEST_FILE") (解压后将被保留)"
echo "--------------------------------------------------------"

# ==========================================
# 6. 环境清理、智能格式识别极速解压与自动删除
# ==========================================
echo "--- [3/3] 开始极速解压与清理 ---"

echo "正在清空解压目标目录: $TARGET_DIR 以防止数据残留..."
rm -rf "${TARGET_DIR:?}/"*
echo "目录已清空。"
echo "--------------------------------------------------------"

for FILE in "${FILES[@]}"; do
    FILENAME=$(basename "$FILE")
    echo "正在分析文件头: $FILENAME"
    
    # 动态获取文件签名并转换为小写，方便匹配
    FILE_INFO=$(file -b "$FILE" | tr '[:upper:]' '[:lower:]')
    
    # 彻底基于 Magic Number 路由指令
    if [[ "$FILE_INFO" == *"zstandard"* ]]; then
        echo "--> [指纹识别] 格式: Zstandard | 调用 pzstd 多线程引擎"
        pv "$FILE" | pzstd -dq -p "$CPU_CORES" | tar -xf - -C "$TARGET_DIR"

    elif [[ "$FILE_INFO" == *"gzip"* ]]; then
        echo "--> [指纹识别] 格式: Gzip | 调用 pigz 多线程引擎"
        pv "$FILE" | pigz -dc -p "$CPU_CORES" | tar -xf - -C "$TARGET_DIR"

    elif [[ "$FILE_INFO" == *"lz4"* ]]; then
        echo "--> [指纹识别] 格式: LZ4 | 调用 lz4 引擎"
        pv "$FILE" | lz4 -dq -c | tar -xf - -C "$TARGET_DIR"

    elif [[ "$FILE_INFO" == *"tar archive"* ]]; then
        echo "--> [指纹识别] 格式: 纯 Tar 打包 | 直接剥离外壳"
        pv "$FILE" | tar -xf - -C "$TARGET_DIR"

    else
        echo "[!] 未知或不支持的数据指纹: $FILE_INFO，跳过处理。"
        continue
    fi

    # 动态管道错误检查
    ERRORS=("${PIPESTATUS[@]}")
    HAS_ERROR=0
    for err in "${ERRORS[@]}"; do
        if [ "$err" -ne 0 ]; then
            HAS_ERROR=1
            break
        fi
    done

    if [ "$HAS_ERROR" -eq 1 ]; then
        echo -e "\n[!] 解压 $FILENAME 时出错，管道崩溃，文件未删除以备排查。"
        exit 1
    fi

    echo -e "\n完成解压: $FILENAME"
    
    if [ "$FILE" != "$LARGEST_FILE" ]; then
        echo "清理空间：正在删除 $FILENAME ..."
        rm -f "$FILE"
        echo "已删除。"
    else
        echo "保留最大压缩包：$FILENAME"
    fi
    echo "-------------------------------------------"
done

echo "所有自动化任务均已圆满完成！节点数据已就绪至: $TARGET_DIR"
