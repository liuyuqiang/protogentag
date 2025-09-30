# Buf Plugin 使用说明

这个项目已经改造为 Buf plugin，可以在 BSR (Buf Schema Registry) 中使用。

## 插件信息

- **插件名称**: `buf.build/liuyuqiang/protogentag`
- **版本**: `v1.0.0`
- **功能**: 为生成的 Go struct 添加自定义标签

## 构建和推送

### 使用 Makefile

```bash
# 构建 Docker 镜像
make build-docker

# 构建并推送到 BSR
make push-plugin

# 清理 Docker 镜像
make clean
```

### 使用构建脚本

```bash
# 构建 Docker 镜像
./build.sh

# 构建并推送到 BSR
./build.sh --push
```

## 在 BSR 中使用

### 1. 在 buf.gen.yaml 中配置

```yaml
version: v2
plugins:
  - plugin: buf.build/liuyuqiang/protogentag
    out: .
    opt:
      - xxx=json:"-"
      - auto=json
```

### 2. 生成代码

```bash
buf generate
```

## 插件选项

- `xxx`: 为 XXX 字段添加标签，例如 `xxx=json:"-"`
- `auto`: 自动添加标签，例如 `auto=json`
- `outdir`: 输出目录
- `module`: 模块前缀

## 示例

在 proto 文件中使用 tagger 扩展：

```protobuf
import "tagger/tagger.proto";

message Example {
    string field = 1 [(tagger.tags) = "json:\"field_name\" graphql:\"fieldName\""];
}
```

生成的 Go 代码将包含指定的标签：

```go
type Example struct {
    Field string `protobuf:"bytes,1,opt,name=field,proto3" json:"field_name" graphql:"fieldName"`
}
```
