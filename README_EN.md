<br/><br/><p align="center">
<img src="assets/icon/pho_icon.png" width="150">
</p>
<h3 align="center">
Pho - A serverless application for viewing and uploading photos
</h3>
<p align="center">
  <img src="https://github.com/fregie/pho/actions/workflows/go_test.yml/badge.svg">
</p>
<p align="center">
  <a href="README.md">中文</a> | <a href="README_EN.md">English</a>
</p>

### Installation
Currently only supported on Android devices.  
[Click here to download the APK](https://github.com/fregie/pho/releases)

### Introduction
The primary objective of this application is to serve as a replacement for the native photo gallery application on smartphones. It also offers the capability to synchronize photos with online storage.  
Pho is a simple app designed for viewing and synchronizing photos to cloud storage. It aims to provide an excellent user experience.

### Features
* Local photo browsing
* Cloud photo browsing
* Incremental photo synchronization to the cloud
* Background periodic synchronization
* No database, no server-side
* Organizing cloud storage directory structure by date

### Supported Cloud Storage
- [x] Samba
- [x] Webdav
- [x] NFS
- [ ] Alibaba Cloud Drive
- [ ] quark
- [ ] baidu netdisk
- [ ] oneDrive
- [ ] google drive
- [ ] google photo

### Screenshots
<p align="left">
<img src="assets/screenshot/Screenshots.png" >
</p>

### File Storage Logic
The application stores files based on a straightforward principle of utilizing the time as the directory structure, and the source file name as the filename for storage. A .thumbnail directory is created in the root directory to store the generated thumbnails, and the directory structure for these thumbnails aligns with that of the source files.

You can access and utilize your backed-up photos in any other manner at any time, without dependence on this application.

Directory Structure Diagram:
```bash
├── 2022
│   ├── 07
│   │   ├── 02
│   │   │   ├── 20220702_100940.JPG
│   │   │   ├── 20220702_111416.JPG
│   │   │   └── 20220702_111508.JPG
│   │   └── 03
│   │       ├── 20220703_101923.DNG
│   │       ├── 20220703_112336.DNG
│   │       └── 20220703_112338.DNG
│   ├── 08
│       └── 01
│           ├── 20220801_191717.DNG
│           ├── 20220801_191718.DNG
│           └── 20220801_191720.DNG
├── 2023
│   ├── 01
│       ├── 03
│       │   ├── 20230103_112348.JPG
│       │   ├── 20230103_124634.JPG
│       │   └── 20230103_124918.DNG
├── .thumbnail
|   ├── 2022
|   │   ├── 07
|   │   │   ├── 02
|   │   │   │   ├── 20220702_100940.JPG
|   │   │   │   ├── 20220702_111416.JPG
|   │   │   │   └── 20220702_111508.JPG
|   │   │   └── 03
|   │   │       ├── 20220703_101923.DNG
|   │   │       ├── 20220703_112336.DNG
|   │   │       └── 20220703_112338.DNG
|   │   ├── 08
|   │       └── 01
|   │           ├── 20220801_191717.DNG
|   │           ├── 20220801_191718.DNG
|   │           └── 20220801_191720.DNG
|   ├── 2023
|   │   ├── 01
|   │       ├── 03
|   │       │   ├── 20230103_112348.JPG
|   │       │   ├── 20230103_124634.JPG
|   │       │   └── 20230103_124918.DNG
```

### Roadmap
- [x] Support zooming in/out of images
- [ ] Support uploading/browsing videos
- [x] Support NFS
- [ ] Support Alibaba Cloud Drive
- [ ] Support iOS
- [ ] Support web version
- [x] Add Chinese