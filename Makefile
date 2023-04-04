BUILD_VERSION   := $(shell git describe --tags)
GIT_COMMIT_SHA1 := $(shell git rev-parse HEAD)
BUILD_TIME      := $(shell date "+%F %T")
BUILD_NAME      := img_syncer_server
VERSION_PACKAGE_NAME := github.com/fregie/PrintVersion

DESCRIBE := img_syncer grpc server

prebuild:
	go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.27.1
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.1.0

protobuf:
	protoc -I. --go_out . --go_opt paths=source_relative \
		--go-grpc_out . --go-grpc_opt paths=source_relative \
		--dart_out=grpc:lib \
		proto/*.proto

.PHONY: server
server: protobuf
	CGO_ENABLED=0 go build -ldflags "\
		-X '${VERSION_PACKAGE_NAME}.Version=${BUILD_VERSION}' \
		-X '${VERSION_PACKAGE_NAME}.BuildTime=${BUILD_TIME}' \
		-X '${VERSION_PACKAGE_NAME}.GitCommitSHA1=${GIT_COMMIT_SHA1}' \
		-X '${VERSION_PACKAGE_NAME}.Describe=${DESCRIBE}' \
		-X '${VERSION_PACKAGE_NAME}.Name=${BUILD_NAME}'" \
    -o server/output/${BUILD_NAME} ./server

server-aar: protobuf
	CGO_ENABLED=0 gomobile bind -target=android -androidapi 19 -o android/app/libs/server.aar ./server/run