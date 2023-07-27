import 'package:flutter/material.dart';
import 'package:img_syncer/event_bus.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:img_syncer/global.dart';

class NFSForm extends StatefulWidget {
  const NFSForm({Key? key}) : super(key: key);

  @override
  NFSFormState createState() => NFSFormState();
}

class NFSFormState extends State<NFSForm> {
  @protected
  final GlobalKey _formKey = GlobalKey<FormState>();
  TextEditingController? urlController;
  TextEditingController? rootPathController;
  bool testSuccess = false;
  String? errormsg;
  String currentPath = "";

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController();
    rootPathController = TextEditingController();
    SharedPreferences.getInstance().then((prefs) {
      final url = prefs.getString("nfs_url");
      final rootPath = prefs.getString("nfs_root_path");
      if (url != null) {
        urlController!.text = url;
      }
      if (rootPath != null) {
        rootPathController!.text = rootPath;
      }
    });
  }

  Future<bool> checkNFS() async {
    final url = urlController!.text;
    final rootPath = rootPathController!.text;
    if (url.isEmpty) {
      return false;
    }
    try {
      final rsp1 = await storage.cli.setDriveNFS(SetDriveNFSRequest(addr: url));
      if (!rsp1.success) {
        setState(() {
          errormsg = rsp1.message;
        });
        return false;
      }
      final rsp2 = await storage.cli.listDriveNFSDir(ListDriveNFSDirRequest());
      if (!rsp2.success) {
        setState(() {
          errormsg = rsp2.message;
        });
        return false;
      }
    } catch (e) {
      setState(() {
        errormsg = e.toString();
      });
      return false;
    }
    return true;
  }

  Future<List<String>> getRootPath(String dir) async {
    final rsp =
        await storage.cli.listDriveNFSDir(ListDriveNFSDirRequest(dir: dir));
    if (!rsp.success) {
      setState(() {
        errormsg = rsp.message;
      });
    }
    return rsp.dirs;
  }

  Future<void> testStorage() async {
    final url = urlController!.text;
    final rootPath = rootPathController!.text;
    if (url.isEmpty || rootPath.isEmpty) {
      setState(() {
        errormsg = "URL or root path is empty";
      });
      return;
    }
    try {
      final rsp = await storage.cli
          .setDriveNFS(SetDriveNFSRequest(addr: url, root: rootPath));
      if (!rsp.success) {
        setState(() {
          errormsg = rsp.message;
        });
        return;
      } else {
        setState(() {
          testSuccess = true;
        });
      }
    } catch (e) {
      setState(() {
        errormsg = e.toString();
      });
      return;
    }
  }

  void showErrorDialog(String msg) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.connectFailed),
        content: Text(msg),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget testStorageButtun() {
    return Container(
      width: 180,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: FilledButton.tonal(
        onPressed: () {
          testStorage().then((value) {
            if (testSuccess) {
              SnackBarManager.showSnackBar(l10n.testSuccess);
            } else {
              showErrorDialog(errormsg!);
            }
          });
        },
        child: Text(l10n.testStorage),
      ),
    );
  }

  Widget saveButtun() {
    return Container(
      width: 150,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: FilledButton(
        onPressed: testSuccess
            ? () {
                final url = urlController!.text;
                final rootPath = rootPathController!.text;
                SharedPreferences.getInstance().then((prefs) {
                  prefs.setString("nfs_url", url);
                  prefs.setString("nfs_root_path", rootPath);
                  prefs.setString("drive", driveName[Drive.nfs]!);
                });
                settingModel.setRemoteStorageSetted(true);
                assetModel.remoteLastError = null;
                eventBus.fire(RemoteRefreshEvent());
                Navigator.pop(context);
              }
            : null,
        child: Text(l10n.save),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextFormField(
              controller: urlController,
              obscureText: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "URL",
                helperText: "eg: nfs.domain.or.ip:/nfs/path",
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextFormField(
              controller: rootPathController,
              obscureText: false,
              enableInteractiveSelection: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: l10n.rootPath,
                helperText: "eg: /path/photo",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () {
                    checkNFS().then((available) {
                      if (!available) {
                        showErrorDialog(errormsg!);
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => rootPathDialog(),
                        );
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              testStorageButtun(),
              saveButtun(),
            ],
          )
        ],
      ),
    );
  }

  Widget rootPathDialog() {
    currentPath = "/";
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return Dialog(
          child: SizedBox(
            height: 500,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                  child: Text(
                    l10n.selectRoot,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${l10n.currentPath}: $currentPath",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Divider(
                  indent: 20,
                  endIndent: 20,
                  color: Colors.grey,
                ),
                FutureBuilder(
                  future: getRootPath(currentPath),
                  builder: (context, AsyncSnapshot<List<String>> snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: ListView.builder(
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              child: Container(
                                padding:
                                    const EdgeInsets.fromLTRB(25, 0, 25, 0),
                                height: 35,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  snapshot.data![index],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                              onTap: () {
                                final dirName = snapshot.data![index];
                                setDialogState(() {
                                  if (currentPath == "") {
                                    currentPath = dirName;
                                  } else if (dirName == ".") {
                                    currentPath = path.dirname(currentPath);
                                  } else {
                                    currentPath = "$currentPath$dirName/";
                                  }
                                });
                              },
                            );
                          },
                        ),
                      );
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                  child: const Divider(
                    indent: 20,
                    endIndent: 20,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                      width: 120,
                      height: 55,
                      child: OutlinedButton(
                        child: Text(l10n.cancel),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 20),
                      width: 120,
                      height: 55,
                      child: FilledButton(
                        child: Text(l10n.save),
                        onPressed: () {
                          rootPathController!.text = currentPath;
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
