LOCAL_PATH = $(shell pwd)
PLUGIN_NAME = buf.build/liuyuqiang/protogentag
PLUGIN_VERSION = v1.0.0
DOCKER_IMAGE = $(PLUGIN_NAME):$(PLUGIN_VERSION)

.PHONY: example proto install gen-tag test build-docker push-plugin clean

example: proto install
	protoc -I /usr/local/include \
	-I ${LOCAL_PATH} \
	--gentag_out=xxx="graphql+\"-\" bson+\"-\"":. example/example.proto

proto:
	protoc -I /usr/local/include \
	-I ${LOCAL_PATH} \
	--go_out=:. example/example.proto

install:
	go install .

gen-tag:
	buf generate
	buf generate --template=buf.gen.tag.yaml
	buf generate --template=buf.gen.debug.yaml --path tagger

test:
	go test ./...

# Buf plugin 相关命令
build-docker:
	docker build --platform linux/amd64 -t $(DOCKER_IMAGE) .

push-plugin: build-docker
	@echo "推送插件到 BSR..."
	@if ! buf registry whoami >/dev/null 2>&1; then \
		echo "错误: 请先登录 BSR"; \
		echo "运行: buf registry login"; \
		exit 1; \
	fi
	buf beta registry plugin push \
		--visibility=public \
		--image=$(DOCKER_IMAGE)

clean:
	docker rmi $(DOCKER_IMAGE) 2>/dev/null || true
