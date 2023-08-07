module github.com/fregie/img_syncer

go 1.18

require (
	github.com/fregie/PrintVersion v0.1.0
	golang.org/x/mobile v0.0.0-20230301163155-e0f57694e12c
	google.golang.org/grpc v1.53.0
	google.golang.org/protobuf v1.28.1
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
	golang.org/x/crypto v0.7.0 // indirect
	golang.org/x/mod v0.8.0 // indirect
	golang.org/x/tools v0.6.0 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)

require (
	github.com/Workiva/go-datastructures v1.0.53
	github.com/dsoprea/go-exif/v3 v3.0.0-20221012082141-d21ac8e2de85
	github.com/golang/protobuf v1.5.2 // indirect
	github.com/hirochachacha/go-smb2 v1.1.0
	github.com/nfnt/resize v0.0.0-20180221191011-83c6a9932646
	github.com/stretchr/testify v1.8.2
	github.com/studio-b12/gowebdav v0.0.0-20230203202212-3282f94193f2
	github.com/vmware/go-nfs-client v0.0.0-20190605212624-d43b92724c1b
	golang.org/x/net v0.9.0
	golang.org/x/sys v0.7.0 // indirect
	golang.org/x/text v0.9.0 // indirect
	google.golang.org/genproto v0.0.0-20230110181048-76db0878b65f // indirect
)

// replace github.com/studio-b12/gowebdav => ../gowebdav
replace github.com/vmware/go-nfs-client => github.com/fregie/go-nfs-client v1.0.0
