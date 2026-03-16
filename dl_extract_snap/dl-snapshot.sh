######## bsc-reth (archive)
# https://github.com/bnb-chain/reth-bsc
# 安装环境
apt install -y curl git-all cmake gcc libssl-dev pkg-config libclang-dev libpq-dev build-essential
# 安装rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 编译
cd ~
rm -rf /tmp/reth-bsc
git clone https://github.com/bnb-chain/reth-bsc /tmp/reth-bsc
cd /tmp/reth-bsc
git checkout v0.0.7-beta
# 这个maxperf属性跟CPU挂钩，可能需要在当前服务器编译才行
make maxperf
./target/maxperf/reth-bsc --version


cp -a ./target/maxperf/reth-bsc /node/archive/bsc/bin/reth-bsc
/node/archive/bsc/bin/reth-bsc --version


### full

# binary
mkdir -p /node/full/bsc/bin
mv -f /node/full/bsc/bin/geth_bsc /node/full/bsc/bin/geth_bsc_old
aria2c -s 16 -x 16 -q -d /node/full/bsc/bin/ -o geth_bsc https://file.204001.xyz/blockpi/software/bsc/geth_bsc
chmod +x /node/full/bsc/bin/geth_bsc
/node/full/bsc/bin/geth_bsc version


# config file
curl -s 'https://file.204001.xyz/blockpi/software/bsc/config.toml' -o /node/full/bsc/config.toml


# running service
cat > /etc/systemd/system/bsc.service << EOF
[Unit]
Description=service
After=network-online.target

[Service]
User=root
ExecStart=/node/full/bsc/bin/geth_bsc --networkid 56 --datadir /node/full/bsc/ --config /node/full/bsc/config.toml --syncmode full --gcmode full --snapshot=true --rpc.allow-unprotected-txs --history.transactions=0 --tries-verify-mode=none --pruneancient --db.engine=pebble --rpc.gascap=600000000 --rpc.evmtimeout=30s --light.maxpeers=0 --txpool.globalslots 1000000 --txpool.globalqueue 3000000 --txpool.pricelimit=1 --http.vhosts * --http.corsdomain * --http --http.api=eth,web3,net,debug,txpool --http.addr 0.0.0.0 --ws --ws.api=eth,web3,net,debug,txpool --ws.addr 0.0.0.0 --port 31040 --http.port 31041 --ws.port 31042
Restart=on-failure
RestartSec=5
LimitNOFILE=200000

[Install]
WantedBy=multi-user.target
EOF
# running service EOF

### full EOF


### bsc archive node

# snapshot:
# install dependencies
sudo apt-get install -y aria2 curl jq
# download snapshot
curl -skL https://raw.githubusercontent.com/48Club/bsc-snapshots/refs/heads/main/script/erigon_archive_download.sh | bash
mv snapshots /data/erigon
# start erigon
erigon3 --prune.mode=archive --chain=bsc --datadir=/data/erigon ...



OLD_BINARY_VERSION=$(/node/archive/bsc/bin/erigon -v | awk '{print $3}')

systemctl stop bsc-archive.service
mv /node/archive/bsc/bin/erigon /node/archive/bsc/bin/erigon-${OLD_BINARY_VERSION}
aria2c -s 16 -x 16 -q -d /node/archive/bsc/bin/ -o erigon https://file.204001.xyz/blockpi/software/bsc/erigon
chmod +x /node/archive/bsc/bin/erigon
/node/archive/bsc/bin/erigon -v

### bsc archive node EOF


### bsc archive - reth
mkdir -p /node/archive/bsc/{bin,reth}

######## bsc-reth (archive)
# https://github.com/bnb-chain/reth-bsc
# 安装环境
apt install -y curl git-all cmake gcc libssl-dev pkg-config libclang-dev libpq-dev build-essential
# 安装rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 编译
cd ~
rm -rf /tmp/reth-bsc
git clone https://github.com/bnb-chain/reth-bsc /tmp/reth-bsc
cd /tmp/reth-bsc
git checkout v0.0.7-beta
# 这个maxperf属性跟CPU挂钩，可能需要在当前服务器编译才行
make maxperf
./target/maxperf/reth-bsc --version

cp -f ./target/maxperf/reth-bsc /node/archive/bsc/bin/reth-bsc
/node/archive/bsc/bin/reth-bsc --version

# download
aria2c -s 16 -x 16 -q -d /node/archive/bsc/bin/ -o bsc-reth https://file.204001.xyz/blockpi/software/bsc/bsc-reth
chmod +x /node/archive/bsc/bin/bsc-reth
/node/archive/bsc/bin/bsc-reth --version

/node/archive/bsc/bin/bsc-reth node --datadir=/node/archive/bsc/data --chain=bsc --http --http.api="eth,net,txpool,web3,debug" --http.addr 0.0.0.0 --ws --ws.api="eth,web3,net,debug,txpool" --ws.addr 0.0.0.0 --port 21040 --http.port 21041 --ws.port 21042

systemctl stop bsc-archive.service


# reth - MDBX
cat > /etc/systemd/system/bsc-archive.service << EOF
[Unit]
Description=service
After=network-online.target

[Service]
User=root
ExecStart=/node/archive/bsc/bin/reth-bsc node --chain bsc --db.max-size=12TB --db.page-size=8KB --datadir=/node/archive/bsc/reth  --ws --ws.addr=0.0.0.0 --ws.origins=* --http --http.addr=0.0.0.0 --http.api=eth,net,web3,debug,trace,txpool --ws.api=eth,net,web3,debug,trace,txpool --http.corsdomain=* --authrpc.addr=127.0.0.1 --port 21040 --http.port 21041 --ws.port 21042 --authrpc.port 21043 --discovery.port 21049 --discovery.v5.port 21048 --engine.memory-block-buffer-target=128 --engine.parallel-sparse-trie --rpc.txfeecap=5 --trusted-peers=enode://551c8009f1d5bbfb1d64983eeb4591e51ad488565b96cdde7e40a207cfd6c8efa5b5a7fa88ed4e71229c988979e4c720891287ddd7d00ba114408a3ceb972ccb@34.245.203.3:30311,enode://c637c90d6b9d1d0038788b163a749a7a86fed2e7d0d13e5dc920ab144bb432ed1e3e00b54c1a93cecba479037601ba9a5937a88fe0be949c651043473c0d1e5b@34.244.120.206:30311,enode://bac6a548c7884270d53c3694c93ea43fa87ac1c7219f9f25c9d57f6a2fec9d75441bc4bad1e81d78c049a1c4daf3b1404e2bbb5cd9bf60c0f3a723bbaea110bc@3.255.117.110:30311,enode://94e56c84a5a32e2ef744af500d0ddd769c317d3c3dd42d50f5ea95f5f3718a5f81bc5ce32a7a3ea127bc0f10d3f88f4526a67f5b06c1d85f9cdfc6eb46b2b375@3.255.231.219:30311,enode://5d54b9a5af87c3963cc619fe4ddd2ed7687e98363bfd1854f243b71a2225d33b9c9290e047d738e0c7795b4bc78073f0eb4d9f80f572764e970e23d02b3c2b1f@34.245.16.210:30311,enode://41d57b0f00d83016e1bb4eccff0f3034aa49345301b7be96c6bb23a0a852b9b87b9ed11827c188ad409019fb0e578917d722f318665f198340b8a15ae8beff36@34.245.72.231:30311,enode://1bb269476f62e99d17da561b1a6b0d0269b10afee029e1e9fdee9ac6a0e342ae562dfa8578d783109b80c0f100a19e03b057f37b2aff22d8a0aceb62020018fe@54.78.102.178:30311,enode://3c13113538f3ca7d898d99f9656e0939451558758fd9c9475cff29f020187a56e8140bd24bd57164b07c3d325fc53e1ef622f793851d2648ed93d9d5a7ce975c@34.254.238.155:30311,enode://d19fd92e4f061d82a92e32d377c568494edcc36883a02e9d527b69695b6ae9e857f1ace10399c2aee4f71f5885ca3fe6342af78c71ad43ec1ca890deb6aaf465@34.247.29.116:30311,enode://c014bbf48209cdf8ca6d3bf3ff5cf2fade45104283dcfc079df6c64e0f4b65e4afe28040fa1731a0732bd9cbb90786cf78f0174b5de7bd5b303088e80d8e6a83@54.74.101.143:30311 --rpc.eth-proof-window=128 --rpc.proof-permits=300 --rpc.max-request-size 50000 --rpc.max-response-size 50000 --rpc.max-subscriptions-per-connection 900000 --rpc.max-connections 900000 --rpc.max-tracing-requests 900000 --rpc-cache.max-concurrent-db-requests 5000 --rpc.gascap 600000000 --txpool.pending-max-count 30000 --txpool.pending-max-size 30000 --txpool.basefee-max-count 30000 --txpool.basefee-max-size 30000 --txpool.queued-max-count 30000 --txpool.queued-max-size 3000 --txpool.max-account-slots 16 --txpool.max-tx-input-bytes 1310720 --txpool.max-cached-entries 2000 --txpool.max-pending-txns 8192 --txpool.max-new-txns 2048 --txpool.max-new-pending-txs-notifications 200 --rpc.max-trace-filter-blocks=1000 --rpc.max-logs-per-response=200000
Restart=always
RestartSec=30
LimitNOFILE=500000

[Install]
WantedBy=multi-user.target
EOF
# reth EOF



# reth - TrieDB
cat > /etc/systemd/system/bsc-archive.service << EOF
[Unit]
Description=service
After=network-online.target

[Service]
User=root
ExecStart=/node/archive/bsc/bin/reth-bsc node --chain bsc --statedb.triedb --db.max-size=12TB --db.page-size=8KB --datadir=/node/archive/bsc/reth-triedb  --ws --ws.addr=0.0.0.0 --ws.origins=* --http --http.addr=0.0.0.0 --http.api=eth,net,web3,debug,trace,txpool --ws.api=eth,net,web3,debug,trace,txpool --http.corsdomain=* --authrpc.addr=127.0.0.1 --port 21040 --http.port 21041 --ws.port 21042 --authrpc.port 21043 --discovery.port 21049 --discovery.v5.port 21048 --engine.memory-block-buffer-target=128 --engine.parallel-sparse-trie --rpc.txfeecap=5 --trusted-peers=enode://551c8009f1d5bbfb1d64983eeb4591e51ad488565b96cdde7e40a207cfd6c8efa5b5a7fa88ed4e71229c988979e4c720891287ddd7d00ba114408a3ceb972ccb@34.245.203.3:30311,enode://c637c90d6b9d1d0038788b163a749a7a86fed2e7d0d13e5dc920ab144bb432ed1e3e00b54c1a93cecba479037601ba9a5937a88fe0be949c651043473c0d1e5b@34.244.120.206:30311,enode://bac6a548c7884270d53c3694c93ea43fa87ac1c7219f9f25c9d57f6a2fec9d75441bc4bad1e81d78c049a1c4daf3b1404e2bbb5cd9bf60c0f3a723bbaea110bc@3.255.117.110:30311,enode://94e56c84a5a32e2ef744af500d0ddd769c317d3c3dd42d50f5ea95f5f3718a5f81bc5ce32a7a3ea127bc0f10d3f88f4526a67f5b06c1d85f9cdfc6eb46b2b375@3.255.231.219:30311,enode://5d54b9a5af87c3963cc619fe4ddd2ed7687e98363bfd1854f243b71a2225d33b9c9290e047d738e0c7795b4bc78073f0eb4d9f80f572764e970e23d02b3c2b1f@34.245.16.210:30311,enode://41d57b0f00d83016e1bb4eccff0f3034aa49345301b7be96c6bb23a0a852b9b87b9ed11827c188ad409019fb0e578917d722f318665f198340b8a15ae8beff36@34.245.72.231:30311,enode://1bb269476f62e99d17da561b1a6b0d0269b10afee029e1e9fdee9ac6a0e342ae562dfa8578d783109b80c0f100a19e03b057f37b2aff22d8a0aceb62020018fe@54.78.102.178:30311,enode://3c13113538f3ca7d898d99f9656e0939451558758fd9c9475cff29f020187a56e8140bd24bd57164b07c3d325fc53e1ef622f793851d2648ed93d9d5a7ce975c@34.254.238.155:30311,enode://d19fd92e4f061d82a92e32d377c568494edcc36883a02e9d527b69695b6ae9e857f1ace10399c2aee4f71f5885ca3fe6342af78c71ad43ec1ca890deb6aaf465@34.247.29.116:30311,enode://c014bbf48209cdf8ca6d3bf3ff5cf2fade45104283dcfc079df6c64e0f4b65e4afe28040fa1731a0732bd9cbb90786cf78f0174b5de7bd5b303088e80d8e6a83@54.74.101.143:30311 --rpc.eth-proof-window=128 --rpc.proof-permits=300 --rpc.max-request-size 50000 --rpc.max-response-size 50000 --rpc.max-subscriptions-per-connection 900000 --rpc.max-connections 900000 --rpc.max-tracing-requests 900000 --rpc-cache.max-concurrent-db-requests 5000 --rpc.gascap 600000000 --txpool.pending-max-count 30000 --txpool.pending-max-size 30000 --txpool.basefee-max-count 30000 --txpool.basefee-max-size 30000 --txpool.queued-max-count 30000 --txpool.queued-max-size 3000 --txpool.max-account-slots 16 --txpool.max-tx-input-bytes 1310720 --txpool.max-cached-entries 2000 --txpool.max-pending-txns 8192 --txpool.max-new-txns 2048 --txpool.max-new-pending-txs-notifications 200 --rpc.max-trace-filter-blocks=1000 --rpc.max-logs-per-response=200000
Restart=always
RestartSec=30
LimitNOFILE=500000

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl restart bsc-archive.service

# log
journalctl --no-hostname -f -u bsc-archive.service -n 99



# reth EOF


### bsc archive - reth EOF


# running service erigon
cat > /etc/systemd/system/bsc-archive.service << EOF
[Unit]
Description=service
After=network-online.target

[Service]
User=root
ExecStart=/node/archive/bsc/bin/erigon --datadir=/node/archive/bsc/erigon/ --chain=bsc --prune=disabled --db.pagesize=16k --db.size.limit=16TB --rpc.gascap=600000000 --rpc.evmtimeout=30s --rpc.batch.limit=200 --rpc.returndata.limit=204857600 --txpool.globalslots 1000000 --txpool.globalbasefeeslots 3000000 --txpool.globalqueue 3000000 --txpool.accountslots 64 --txpool.pricelimit=1 --http=true --http.api bsc,eth,net,web3,debug,trace,txpool --http.addr 0.0.0.0 --http.corsdomain * --http.vhosts * --ws --authrpc.addr 127.0.0.1 --port=21040 --p2p.allowed-ports 21046 --http.port 21041 --ws.port 21042 --private.api.addr= --authrpc.port=21043 --torrent.port=21044 --bodies.cache 6442450944 --batchSize=1024M --torrent.download.slots=10 --torrent.download.rate=100mb
Restart=on-failure
RestartSec=5
LimitNOFILE=200000

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl enable bsc-archive.service
systemctl start bsc-archive.service

# running service erigon EOF


### bsc archive - erigon3


mkdir -p /node/archive/bsc/{bin,erigon}
mv -f /node/archive/bsc/bin/erigon /node/archive/bsc/bin/erigon_old
aria2c -s 16 -x 16 -q -d /node/archive/bsc/bin/ -o erigon https://file.204001.xyz/blockpi/software/bsc/erigon3
chmod +x /node/archive/bsc/bin/erigon
/node/archive/bsc/bin/erigon --version

# running service
cat > /etc/systemd/system/bsc-archive.service << EOF
[Unit]
Description=service
After=network-online.target

[Service]
User=root
ExecStart=/node/archive/bsc/bin/erigon --datadir=/node/archive/bsc/erigon/ --chain=bsc --prune.mode=archive --db.size.limit=1TB --bsc.blobSidecars.no-pruning=true --rpc.gascap=600000000 --rpc.evmtimeout=30s --rpc.batch.limit=200 --rpc.returndata.limit=204857600 --txpool.globalslots=1000000 --txpool.globalbasefeeslots=3000000 --txpool.globalqueue=3000000 --http=true --http.api=bsc,eth,net,web3,debug,trace,txpool --http.addr=0.0.0.0 --http.corsdomain=* --http.vhosts=* --ws --authrpc.addr=127.0.0.1 --port=21040 --p2p.allowed-ports=21046,21048 --http.port=21041 --ws.port=21042 --authrpc.port=21043 --torrent.port=21044 --private.api.addr='' --diagnostics.disabled --maxpeers=10

Restart=on-failure
RestartSec=5
LimitNOFILE=200000

[Install]
WantedBy=multi-user.target

EOF

systemctl daemon-reload
systemctl enable bsc-archive.service
systemctl restart bsc-archive.service

systemctl stop bsc-archive.service

# ExecStart=/node/archive/bsc/bin/erigon --datadir=/node/archive/bsc/erigon/ --chain=bsc --prune.mode=archive --db.size.limit=8T --batchSize=2g --http=true --http.api bsc,eth,net,web3,debug,trace,txpool --http.addr 0.0.0.0 --http.corsdomain * --http.vhosts * --ws --authrpc.addr 127.0.0.1 --port=21040 --p2p.allowed-ports 21046 --http.port 21041 --ws.port 21042 --private.api.addr= --authrpc.port=21043 --torrent.port=21044 --log.console.verbosity=3 --diagnostics.disabled

# ExecStart=/node/archive/bsc/bin/erigon --datadir=/node/archive/bsc/erigon/ --chain=bsc --prune.mode=archive --db.pagesize=16k --db.size.limit=8TB --rpc.gascap=600000000 --rpc.evmtimeout=30s --rpc.batch.limit=200 --rpc.returndata.limit=204857600 --txpool.globalslots 1000000 --txpool.globalbasefeeslots 3000000 --txpool.globalqueue 3000000 --txpool.accountslots 64 --txpool.pricelimit=1 --http=true --http.api bsc,eth,net,web3,debug,trace,txpool --http.addr 0.0.0.0 --http.corsdomain * --http.vhosts * --ws --authrpc.addr 127.0.0.1 --port=21040 --p2p.allowed-ports 21046 --http.port 21041 --ws.port 21042 --private.api.addr= --authrpc.port=21043 --torrent.port=21044 --bodies.cache 6442450944 --batchSize=2G --torrent.download.slots=10 --torrent.download.rate=100mb --log.console.verbosity=3 --diagnostics.disabled

# running service EOF


### bsc archive - erigon3 EOF

# 拷贝数据
remote_ip=216.18.201.50
rsync -avzP --exclude='db' root@${remote_ip}:/node/archive/bsc/reth/ /node/archive/bsc/reth/

### FAQ ###
F: 全新同步节点，出现如下日志：
Jan 26 17:45:32 node-usw-ut-web-8 erigon[2656221]: [INFO] [01-26|17:45:32.409] [1/9 OtterSync] Downloading              progress="(2927/2927 files) 99.99% - 4.6TB/4.6TB" rate=3.7KB/s time-left=20hrs:36m total-time=3m20s download-rate=3.7KB/s completion-rate=3.7KB/s alloc=2.2GB sys=3.6GB
Jan 26 17:45:32 node-usw-ut-web-8 erigon[2656221]: [INFO] [01-26|17:45:32.432] [snapshots] no progress yet              files=4 list=domain/v1-receipt.4096-4224.kvei,domain/v1-code.0-4096.kvei,domain/v1-storage.4096-4224.kvei,domain/v1-code.4096-4224.kvei

A: 检查是否有新版本的客户端。


Q: Dec 25 15:49:57 node-eu-fsn-het-arc-18 erigon[3735670]: /node/archive/polygon/bin/erigon: error while loading shared libraries: libsilkworm_capi.so: cannot open shared object file: No such file or directory

aria2c -s 16 -x 16 -q -d /usr/local/lib/ https://file.204001.xyz/blockpi/software/ethereum/libsilkworm_capi.so
ldconfig



Q: 
Jun 26 10:33:24 node-eu-fsn-het-arc-13 erigon[2452213]: [WARN] [06-26|10:33:24.727] [txpool] flush: sender address not found by ID senderID=24525617
Jun 26 10:33:24 node-eu-fsn-het-arc-13 erigon[2452213]: [WARN] [06-26|10:33:24.749] [txpool] flush: sender address not found by ID senderID=24525633

A:


Q: db stats --checksum


Q:Error: failed to open the database: database is too large for the current system

A:
方案一：
调高`--db.max-size=12TB`，且增加这个参数`--db.page-size=8KB`

方案二：
https://github.com/bnb-chain/reth-bsc/issues/257
https://github.com/bnb-chain/reth-bsc/blob/develop/SNAPSHOT.md

cd /node/archive/bsc/reth/db && \
aria2c -s 16 -x 16 https://pub-c5400abe5bed4adbaf8cd47467747e74.r2.dev/reth_db_20260109.tar.zst && \
zstd -d -T0 --long=31 -c ./reth_db_20260109.tar.zst | tar -xf - && \
sleep 5 && \
rm -f ./reth_db_20260109.tar.zst && \
cd /node/archive/bsc/reth/static_files && \
curl -sSL "http://178.63.119.79/reth_static_files_20260109.tar.zst" | zstd -d -T0 --long=31 | tar -xf - && \
systemctl start bsc-archive.service

# 多线程解压缩
file_name=20260302_mainnet_reth_triedb_static_files_archive_node.tar.zst
pzstd -dc -p 20 ${file_name} | pv | tar -xf -


Q: MDBX - 追块时，临时提高同步速度的参数调制
A: 

cross_block_cache_size=5000000
memory_block_buffer_target=500000
max_outbound_peers=2000
max_pending_imports=50000
CPUAffinity="0-31"
max_seen_tx_history=5000

cat > /etc/systemd/system/bsc-archive-sync-turbo.service << EOF
[Unit]
Description=BSC Archive Node - Turbo Sync
After=network-online.target
Wants=network-online.target

[Service]
User=root
Type=simple

# 核心命令
ExecStart=/node/archive/bsc/bin/reth-bsc node \
--chain bsc \
--datadir=/node/archive/bsc/reth \
--db.max-size=10TB \
--db.page-size=8KB \
--db.growth-step=16GB \
--db.max-readers=4096 \
--ws \
--ws.addr=0.0.0.0 \
--ws.port 21042 \
--http \
--http.addr=0.0.0.0 \
--http.port 21041 \
--authrpc.addr=127.0.0.1 \
--authrpc.port 21043 \
--port 21040 \
--discovery.port 21049 \
--max-outbound-peers=${max_outbound_peers} \
--max-pending-imports=${max_pending_imports} \
--engine.memory-block-buffer-target=${memory_block_buffer_target} \
--max-seen-tx-history=${max_seen_tx_history} \
--engine.parallel-sparse-trie \
--engine.cross-block-cache-size=${cross_block_cache_size} \
--engine.reserved-cpu-cores=0 \
--engine.max-proof-task-concurrency=6400 \
--engine.min-blocks-for-pipeline-run=2 \
--metrics=0.0.0.0:16060 \
--trusted-peers=enode://551c8009f1d5bbfb1d64983eeb4591e51ad488565b96cdde7e40a207cfd6c8efa5b5a7fa88ed4e71229c988979e4c720891287ddd7d00ba114408a3ceb972ccb@34.245.203.3:30311,enode://c637c90d6b9d1d0038788b163a749a7a86fed2e7d0d13e5dc920ab144bb432ed1e3e00b54c1a93cecba479037601ba9a5937a88fe0be949c651043473c0d1e5b@34.244.120.206:30311,enode://bac6a548c7884270d53c3694c93ea43fa87ac1c7219f9f25c9d57f6a2fec9d75441bc4bad1e81d78c049a1c4daf3b1404e2bbb5cd9bf60c0f3a723bbaea110bc@3.255.117.110:30311,enode://94e56c84a5a32e2ef744af500d0ddd769c317d3c3dd42d50f5ea95f5f3718a5f81bc5ce32a7a3ea127bc0f10d3f88f4526a67f5b06c1d85f9cdfc6eb46b2b375@3.255.231.219:30311,enode://5d54b9a5af87c3963cc619fe4ddd2ed7687e98363bfd1854f243b71a2225d33b9c9290e047d738e0c7795b4bc78073f0eb4d9f80f572764e970e23d02b3c2b1f@34.245.16.210:30311,enode://41d57b0f00d83016e1bb4eccff0f3034aa49345301b7be96c6bb23a0a852b9b87b9ed11827c188ad409019fb0e578917d722f318665f198340b8a15ae8beff36@34.245.72.231:30311,enode://1bb269476f62e99d17da561b1a6b0d0269b10afee029e1e9fdee9ac6a0e342ae562dfa8578d783109b80c0f100a19e03b057f37b2aff22d8a0aceb62020018fe@54.78.102.178:30311,enode://3c13113538f3ca7d898d99f9656e0939451558758fd9c9475cff29f020187a56e8140bd24bd57164b07c3d325fc53e1ef622f793851d2648ed93d9d5a7ce975c@34.254.238.155:30311,enode://d19fd92e4f061d82a92e32d377c568494edcc36883a02e9d527b69695b6ae9e857f1ace10399c2aee4f71f5885ca3fe6342af78c71ad43ec1ca890deb6aaf465@34.247.29.116:30311,enode://c014bbf48209cdf8ca6d3bf3ff5cf2fade45104283dcfc079df6c64e0f4b65e4afe28040fa1731a0732bd9cbb90786cf78f0174b5de7bd5b303088e80d8e6a83@54.74.101.143:30311

# 重启策略
Restart=on-failure
RestartSec=30
StartLimitInterval=60
StartLimitBurst=3

# 资源限制优化
LimitNOFILE=1048576
LimitNPROC=65536
LimitMEMLOCK=infinity

# 系统调优
CPUAffinity=${CPUAffinity}
IOSchedulingClass=best-effort
IOSchedulingPriority=0
CPUSchedulingPolicy=rr
CPUSchedulingPriority=50

# 内存锁定（防止swap）
MemorySwapMax=0

# 日志
StandardOutput=journal
StandardError=journal
SyslogIdentifier=bsc-archive

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl restart bsc-archive-sync-turbo.service

# log
journalctl --no-hostname -f -u bsc-archive-sync-turbo.service -n 99

# 同步完成后，删除相关配置
systemctl stop bsc-archive-sync-turbo.service
systemctl disable bsc-archive-sync-turbo.service

rm -f /etc/systemd/system/bsc-archive-sync-turbo.service


Q: TrieDB - 追块时，临时提高同步速度的参数调制
A:
mkdir -p /node/archive/bsc/reth-triedb

# 假设新配置：X核CPU，Y GB内存

# --engine.cross-block-cache-size=$((Y * 800))      # Y GB * 800 ≈ 80%内存(MB)
# --engine.memory-block-buffer-target=$((Y * 80))   # Y GB * 80 ≈ 8%内存(MB)
# --engine.max-proof-task-concurrency=$((X * 400))  # X核 * 400
# --max-outbound-peers=$((X * 100))                 # X核 * 100
# --max-pending-imports=$((X * 1600))               # X核 * 1600
# CPUAffinity=0-$((X-1))                            # 0到X-1


cross_block_cache_size=5000000
memory_block_buffer_target=500000
max_outbound_peers=2000
max_pending_imports=50000
CPUAffinity="0-31"
max_seen_tx_history=5000

cat > /etc/systemd/system/bsc-archive-sync-turbo.service << EOF
[Unit]
Description=BSC Archive Node - Turbo Sync
After=network-online.target
Wants=network-online.target

[Service]
User=root
Type=simple

ExecStart=/node/archive/bsc/bin/reth-bsc node \
--chain bsc \
--datadir=/node/archive/bsc/reth-triedb \
--statedb.triedb \
--db.max-size=10TB \
--db.page-size=8KB \
--db.growth-step=16GB \
--db.max-readers=4096 \
--db.read-transaction-timeout=0 \
--ws \
--ws.addr=0.0.0.0 \
--ws.port=21042 \
--http \
--http.addr=0.0.0.0 \
--http.port=21041 \
--authrpc.addr=127.0.0.1 \
--authrpc.port=21043 \
--port=21040 \
--discovery.port=21049 \
--max-outbound-peers=${max_outbound_peers} \
--max-pending-imports=${max_pending_imports} \
--max-seen-tx-history=${max_seen_tx_history} \
--engine.persistence-threshold=512 \
--engine.memory-block-buffer-target=${memory_block_buffer_target} \
--engine.parallel-sparse-trie \
--engine.cross-block-cache-size=${cross_block_cache_size} \
--engine.reserved-cpu-cores=0 \
--engine.max-proof-task-concurrency=4800 \
--engine.state-root-task-compare-updates \
--engine.min-blocks-for-pipeline-run=256 \
--metrics=0.0.0.0:6060 \
--trusted-peers=enode://551c8009f1d5bbfb1d64983eeb4591e51ad488565b96cdde7e40a207cfd6c8efa5b5a7fa88ed4e71229c988979e4c720891287ddd7d00ba114408a3ceb972ccb@34.245.203.3:30311,enode://c637c90d6b9d1d0038788b163a749a7a86fed2e7d0d13e5dc920ab144bb432ed1e3e00b54c1a93cecba479037601ba9a5937a88fe0be949c651043473c0d1e5b@34.244.120.206:30311,enode://bac6a548c7884270d53c3694c93ea43fa87ac1c7219f9f25c9d57f6a2fec9d75441bc4bad1e81d78c049a1c4daf3b1404e2bbb5cd9bf60c0f3a723bbaea110bc@3.255.117.110:30311,enode://94e56c84a5a32e2ef744af500d0ddd769c317d3c3dd42d50f5ea95f5f3718a5f81bc5ce32a7a3ea127bc0f10d3f88f4526a67f5b06c1d85f9cdfc6eb46b2b375@3.255.231.219:30311,enode://5d54b9a5af87c3963cc619fe4ddd2ed7687e98363bfd1854f243b71a2225d33b9c9290e047d738e0c7795b4bc78073f0eb4d9f80f572764e970e23d02b3c2b1f@34.245.16.210:30311,enode://41d57b0f00d83016e1bb4eccff0f3034aa49345301b7be96c6bb23a0a852b9b87b9ed11827c188ad409019fb0e578917d722f318665f198340b8a15ae8beff36@34.245.72.231:30311,enode://1bb269476f62e99d17da561b1a6b0d0269b10afee029e1e9fdee9ac6a0e342ae562dfa8578d783109b80c0f100a19e03b057f37b2aff22d8a0aceb62020018fe@54.78.102.178:30311,enode://3c13113538f3ca7d898d99f9656e0939451558758fd9c9475cff29f020187a56e8140bd24bd57164b07c3d325fc53e1ef622f793851d2648ed93d9d5a7ce975c@34.254.238.155:30311,enode://d19fd92e4f061d82a92e32d377c568494edcc36883a02e9d527b69695b6ae9e857f1ace10399c2aee4f71f5885ca3fe6342af78c71ad43ec1ca890deb6aaf465@34.247.29.116:30311,enode://c014bbf48209cdf8ca6d3bf3ff5cf2fade45104283dcfc079df6c64e0f4b65e4afe28040fa1731a0732bd9cbb90786cf78f0174b5de7bd5b303088e80d8e6a83@54.74.101.143:30311

Restart=on-failure
RestartSec=30
StartLimitInterval=60
StartLimitBurst=3

LimitNOFILE=2097152
LimitNPROC=65536
LimitMEMLOCK=infinity
CPUAffinity=${CPUAffinity}
IOSchedulingClass=best-effort
IOSchedulingPriority=0
CPUSchedulingPolicy=rr
CPUSchedulingPriority=50
MemorySwapMax=0

StandardOutput=journal
StandardError=journal
SyslogIdentifier=bsc-archive-triedb

[Install]
WantedBy=multi-user.target
EOF


systemctl daemon-reload
systemctl restart bsc-archive-sync-turbo.service

# log
journalctl --no-hostname -f -u bsc-archive-sync-turbo.service -n 99


Q: BSC RETH 推荐配置
A: What are the machine specifications? A 32-core CPU, 200GB of RAM, and a local NVMe disk are recommended.


Q: NGINX反代文件
A: 

cat > /etc/nginx/conf.d/nginx-fileserver.conf << 'EOF'
server {
    listen 8108;

    root /node/archive/bsc/reth;
    autoindex on;
    autoindex_exact_size off;
    autoindex_localtime on;

    charset utf-8;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;

    access_log /var/log/nginx/fileserver-access.log;
    error_log /var/log/nginx/fileserver-error.log;

    location / {
        # 修复：正确的try_files
        try_files $uri $uri/ =404;
    }

    location ~ /\. {
        deny all;
        access_log off;
        log_not_found off;
    }
}
EOF

systemctl restart nginx.service


rsync -avzP --exclude='db' root@远程服务器IP:/node/archive/bsc/reth/ ./


Q: mbuffer对解压缩的影响
A:
# 无mbuffer：
root@node-eu-fsn-het-18 /node/archive/bsc/reth-triedb # bash decompress.sh
--- 开始解压任务 | 模式：pzstd 直接写入 tar | 按 Ctrl+C 退出 ---
正在处理: 20260302_mainnet_reth_triedb_triedb_archive_node.tar.zst
 746GiB 0:07:48 [1.59GiB/s] [===========================================================================================================>] 100%            decompress.sh: line 33: [: -ne: unary operator expectedETA 0:00:26

完成 20260302_mainnet_reth_triedb_triedb_archive_node.tar.zst
-------------------------------------------
所有任务已完成！

# 有mbuffer：
--- 开始解压任务 | 进度单行显示 | 按 Ctrl+C 退出 ---
正在处理: 20260302_mainnet_reth_triedb_triedb_archive_node.tar.zst
 746GiB 0:07:57 [1.56GiB/s] [=============================================================================================================================================================================>] 100%

完成 20260302_mainnet_reth_triedb_triedb_archive_node.tar.zst
-------------------------------------------
所有任务已完成！

Q: bsc reth triedb cpu选择
A: 优选intel，即便amd单核频率更高，但是intel的单核性能在reth上效率更高。


