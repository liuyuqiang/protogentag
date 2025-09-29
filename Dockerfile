FROM golang:1.21-bullseye AS builder

WORKDIR /src

# 安装 protoc 和 buf
RUN apt-get update && apt-get install -y \
    protobuf-compiler \
    && rm -rf /var/lib/apt/lists/*

# 安装 buf CLI 和 protoc-gen-go (使用兼容Go 1.21的版本)
RUN go install github.com/bufbuild/buf/cmd/buf@v1.28.1
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.31.0

# 复制 go.mod 和 go.sum
COPY go.mod go.sum ./

# 下载依赖并整理
RUN go mod download && go mod tidy

# 复制源代码
COPY . .

# 生成 proto 文件 (跳过，因为 proto 文件已经存在)
# RUN buf generate

# 构建插件
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -ldflags "-s -w" -trimpath -o /protogentag .

# 当在非 linux/amd64 主机上构建 Docker 镜像时（如 M1），
# go build 会将二进制文件放在 $GOPATH/bin/$GOOS_$GOARCH/ 中。
# mv 命令将二进制文件复制到 /go/bin，这样后续步骤在从 builder 复制时不会失败。
RUN mv /go/bin/linux_amd64/* /go/bin 2>/dev/null || true

FROM scratch
COPY --from=builder --link /etc/passwd /etc/passwd
COPY --from=builder /protogentag /
USER nobody
ENTRYPOINT [ "/protogentag" ]
