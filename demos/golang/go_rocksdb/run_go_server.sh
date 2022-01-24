#!/bin/bash
set -e

BLUE='\033[1;34m'
NC='\033[0m'


# Install server with occlum-go
CGO_CFLAGS="-I/rocksdb/include" CGO_LDFLAGS="-L/rocksdb -lrocksdb -L/usr/lib/x86_64-linux-gnu -lstdc++ -lm -lz -lbz2 -lsnappy -llz4 -lzstd" occlum-go get github.com/tecbot/gorocksdb
# occlum-go mod init server_instance 


# Build the server program using the Occlum Golang toolchain (i.e., occlum-go)
CGO_CFLAGS="-I/rocksdb/include" CGO_LDFLAGS="-L/rocksdb -lrocksdb -L/usr/lib/x86_64-linux-gnu -lstdc++ -lm -lz -lbz2 -lsnappy -llz4 -lzstd" occlum-go build -o server server.go

# Init Occlum Workspace
rm -rf server_instance && mkdir server_instance
cd server_instance
occlum init
new_json="$(jq '.resource_limits.user_space_size = "2560MB" |
	.resource_limits.kernel_space_heap_size="320MB" |
	.resource_limits.kernel_space_stack_size="10MB" |
	.process.default_stack_size = "40MB" |
	.process.default_heap_size = "320MB" |
	.process.default_mmap_size = "960MB" ' Occlum.json)" && \
echo "${new_json}" > Occlum.json

# Copy program into Occlum Workspace and build
rm -rf image && \
copy_bom -f ../go_server.yaml --root image --include-dir /opt/occlum/etc/template && \
occlum build

# Run the server program
echo -e "${BLUE}occlum run /bin/server${NC}"
occlum run /bin/server
