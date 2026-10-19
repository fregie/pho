module github.com/fregie/img_syncer

go 1.25.0

toolchain go1.25.4

require (
	github.com/fregie/PrintVersion v0.1.0
	golang.org/x/crypto v0.54.0
	golang.org/x/mobile v0.0.0-20260709172247-6129f5bee9d5
	google.golang.org/grpc v1.63.0
	google.golang.org/protobuf v1.33.0
)

require (
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/dsoprea/go-logging v0.0.0-20200710184922-b02d349568dd // indirect
	github.com/dsoprea/go-utility/v2 v2.0.0-20221003172846-a3e1774ef349 // indirect
	github.com/geoffgarside/ber v1.1.0 // indirect
	github.com/go-errors/errors v1.4.2 // indirect
	github.com/golang/geo v0.0.0-20210211234256-740aa86cb551 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	github.com/rasky/go-xdr v0.0.0-20170124162913-1a41d1a06c93 // indirect
	golang.org/x/mod v0.38.0 // indirect
	golang.org/x/sync v0.22.0 // indirect
	golang.org/x/tools v0.48.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20240227224415-6ceb2ff114de // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)

require (
	github.com/dsoprea/go-exif/v3 v3.0.0-20221012082141-d21ac8e2de85
	github.com/hirochachacha/go-smb2 v1.1.0
	github.com/stretchr/testify v1.8.2
	github.com/studio-b12/gowebdav v0.0.0-20230203202212-3282f94193f2
	github.com/vmware/go-nfs-client v0.0.0-20190605212624-d43b92724c1b
	golang.org/x/net v0.57.0
	golang.org/x/sys v0.47.0 // indirect
	golang.org/x/text v0.40.0 // indirect
)

// replace github.com/studio-b12/gowebdav => ../gowebdav
replace github.com/studio-b12/gowebdav => ./third_party/gowebdav

replace github.com/vmware/go-nfs-client => ./third_party/go-nfs-client
