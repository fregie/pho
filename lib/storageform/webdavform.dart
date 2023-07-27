import 'package:flutter/material.dart';
import 'package:img_syncer/event_bus.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:img_syncer/global.dart';

class WebDavForm extends StatefulWidget {
  const WebDavForm({Key? key}) : super(key: key);

  @override
  WebDavFormState createState() => WebDavFormState();
}

class WebDavFormState extends State<WebDavForm> {
  @protected
  final GlobalKey _formKey = GlobalKey<FormState>();
  TextEditingController? urlController;
  TextEditingController? usernameController;
  TextEditingController? passwordController;
  TextEditingController? rootPathController;
  bool testSuccess = false;
  String? errormsg;
  String currentPath = "";

  @override
  void initState() {
    super.initState();
    urlController = TextEditingController();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    rootPathController = TextEditingController();
    SharedPreferences.getInstance().then((prefs) {
      urlController!.text = prefs.getString('webdav_url') ?? "";
      usernameController!.text = prefs.getString('webdav_username') ?? "";
      passwordController!.text = prefs.getString('webdav_password') ?? "";
      rootPathController!.text = prefs.getString('webdav_root_path') ?? "";
    });
  }

  Future<bool> checkWebdav() async {
    final url = urlController!.text;
    final username = usernameController!.text;
    final password = passwordController!.text;
    if (url.isEmpty) {
      return false;
    }
    try {
      final rsp2 = await storage.cli.setDriveWebdav(SetDriveWebdavRequest(
          addr: url, username: username, password: password));
      if (!rsp2.success) {
        setState(() {
          errormsg = rsp2.message;
        });
        print("setDriveWebdav failed: ${rsp2.message}");
        return false;
      }
      final rsp3 =
          await storage.cli.listDriveWebdavDir(ListDriveWebdavDirRequest());
      if (!rsp3.success) {
        setState(() {
          errormsg = rsp3.message;
        });
        print("listDriveWebdavDir failed: ${rsp3.message}");
        return false;
      }
    } catch (e) {
      setState(() {
        errormsg = e.toString();
      });
      print("checkWebdav failed: $e");
    }
    return true;
  }

  Future<List<String>> getRootPath(String dir) async {
    final rsp = await storage.cli
        .listDriveWebdavDir(ListDriveWebdavDirRequest(dir: dir));
    if (!rsp.success) {
      setState(() {
        errormsg = rsp.message;
      });
      return [];
    }
    return rsp.dirs;
  }

  Widget input(
      String label, TextEditingController? c, void Function(String?)? onSaved) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
        controller: c,
        obscureText: false,
        onSaved: onSaved,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }

  Future<void> testStorage() async {
    final url = urlController!.text;
    final username = usernameController!.text;
    final password = passwordController!.text;
    final rootPath = rootPathController!.text;
    try {
      final rsp = await storage.cli.setDriveWebdav(SetDriveWebdavRequest(
          addr: url, username: username, password: password, root: rootPath));
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
                final username = usernameController!.text;
                final password = passwordController!.text;
                final rootPath = rootPathController!.text;
                SharedPreferences.getInstance().then((value) {
                  value.setString('webdav_url', url);
                  value.setString('webdav_username', username);
                  value.setString('webdav_password', password);
                  value.setString('webdav_root_path', rootPath);
                  value.setString('drive', driveName[Drive.webDav]!);
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
    List<Widget> children = [];
    children.add(Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextFormField(
        controller: urlController,
        obscureText: false,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: "URL",
          helperText: "eg: https://your.domain:port",
        ),
      ),
    ));
    children.add(
        input('${l10n.username} (${l10n.optional})', usernameController, null));
    children.add(
        input('${l10n.password} (${l10n.optional})', passwordController, null));
    children.add(Container(
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
              checkWebdav().then((available) {
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
    ));
    children.add(Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        testStorageButtun(),
        saveButtun(),
      ],
    ));
    return Form(
      key: _formKey,
      child: Column(
        children: children,
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
                                setDialogState(() {
                                  if (currentPath == "") {
                                    currentPath = snapshot.data![index];
                                  } else {
                                    currentPath =
                                        "$currentPath${snapshot.data![index]}/";
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
}
