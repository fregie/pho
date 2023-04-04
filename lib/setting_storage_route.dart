import 'package:flutter/material.dart';
import 'package:img_syncer/event_bus.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingStorageRoute extends StatefulWidget {
  const SettingStorageRoute({Key? key}) : super(key: key);

  @override
  SettingStorageRouteState createState() => SettingStorageRouteState();
}

class SettingStorageRouteState extends State<SettingStorageRoute> {
  final GlobalKey _formKey = GlobalKey<FormState>();

  @protected
  String? addr;
  TextEditingController? addrController;
  String? username;
  TextEditingController? usernameController;
  String? password;
  TextEditingController? passwordController;
  String? share;
  TextEditingController? shareController;
  String? rootPath;
  TextEditingController? rootPathController;
  bool testSuccess = false;
  String? errormsg;

  List<String> _optionShares = [];

  String currentPath = "";

  @override
  void initState() {
    super.initState();
    addrController = TextEditingController(text: addr);
    usernameController = TextEditingController(text: username);
    passwordController = TextEditingController(text: password);
    shareController = TextEditingController(text: share);
    rootPathController = TextEditingController(text: rootPath);
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        addr = prefs.getString("addr");
        username = prefs.getString("username");
        password = prefs.getString("password");
        share = prefs.getString("share");
        rootPath = prefs.getString("rootPath");
      });
      addrController!.text = addr ?? "";
      usernameController!.text = username ?? "";
      passwordController!.text = password ?? "";
      shareController!.text = share ?? "";
      rootPathController!.text = rootPath ?? "";

      refreshShare();
      addrController!.addListener(() => refreshShare());
      usernameController!.addListener(() => refreshShare());
      passwordController!.addListener(() => refreshShare());
      shareController!.addListener(() {
        if (share == shareController!.text) {
          return;
        }
        storage.cli.setDriveSMB(SetDriveSMBRequest(
          addr: addr,
          username: username,
          password: password,
          share: share,
        ));
        rootPathController!.text = "";
        setState(() {
          share = shareController!.text;
          rootPath = null;
        });
      });
    });
  }

  @protected
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
    var form = _formKey.currentState as FormState;
    if (form.validate()) {
      form.save();
      try {
        SetDriveSMBResponse rsp =
            await storage.cli.setDriveSMB(SetDriveSMBRequest(
          addr: addr!,
          username: username!,
          password: password!,
          share: share!,
          root: rootPath!,
        ));
        if (rsp.success) {
          ListByDateResponse rsp =
              await storage.cli.listByDate(ListByDateRequest());
          if (rsp.success) {
            setState(() {
              testSuccess = true;
            });
          } else {
            setState(() {
              errormsg = rsp.message;
            });
          }
        } else {
          setState(() {
            errormsg = rsp.message;
          });
        }
      } catch (e) {
        setState(() {
          errormsg = e.toString();
        });
      }
    }
  }

  Future<void> refreshShare() async {
    final a = addr;
    final u = username;
    final p = password;
    if (a == null || u == null || p == null) {
      return;
    }
    final rsp1 = await storage.cli.setDriveSMB(SetDriveSMBRequest(
      addr: a,
      username: u,
      password: p,
    ));
    if (!rsp1.success) {
      setState(() {
        errormsg = rsp1.message;
      });
      return;
    }
    final rsp2 =
        await storage.cli.listDriveSMBShares(ListDriveSMBSharesRequest());
    if (!rsp2.success) {
      setState(() {
        errormsg = rsp2.message;
      });
      return;
    }
    rsp2.shares.remove("IPC\$");
    setState(() {
      _optionShares = rsp2.shares;
    });
  }

  Future<List<String>> getRootPath(String dir) async {
    final rsp = await storage.cli.listDriveSMBDir(ListDriveSMBDirRequest(
      share: share,
      dir: dir,
    ));
    if (!rsp.success) {
      setState(() {
        errormsg = rsp.message;
      });
      return [];
    }
    return rsp.dirs;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      input("Samba server address", addrController, (v) => addr = v),
      input("Username", usernameController, (v) => username = v),
      input("Password", passwordController, (v) => password = v),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          controller: shareController,
          obscureText: false,
          enableInteractiveSelection: true,
          onSaved: (v) => share = v,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: "Share",
            suffixIcon: _optionShares.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.open_in_browser),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => shareDialog(),
                    ),
                  ),
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          controller: rootPathController,
          obscureText: false,
          enableInteractiveSelection: true,
          onSaved: (v) => rootPath = v,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: "Root path",
            suffixIcon: share == null || share == ""
                ? null
                : IconButton(
                    icon: const Icon(Icons.open_in_browser),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => rootPathDialog(),
                    ),
                  ),
          ),
        ),
      ),
    ];
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          iconTheme: Theme.of(context).iconTheme,
          elevation: 0,
          title: Text('Storage setting',
              style: Theme.of(context).textTheme.titleLarge),
        ),
        body: Center(
          child: Form(
            key: _formKey,
            child: Column(
                children: children.followedBy([
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  testStorageButtun(),
                  saveButtun(),
                ],
              ),
            ]).toList()),
          ),
        ));
  }

  Widget shareDialog() {
    return Dialog(
      child: SizedBox(
        height: 500,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
              child: Text(
                "Select share",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(
              indent: 20,
              endIndent: 20,
              color: Colors.grey,
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _optionShares.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    title: Text(_optionShares[index]),
                    onTap: () {
                      shareController!.text = _optionShares[index];
                      setState(() {
                        share = _optionShares[index];
                        rootPathController!.text = "";
                      });
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: const Divider(
                indent: 20,
                endIndent: 20,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget rootPathDialog() {
    currentPath = "";

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
                    "Select root path",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Current path: $currentPath",
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
                                        "$currentPath/${snapshot.data![index]}";
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
                        child: const Text("Cancel"),
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
                        child: const Text("Save"),
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

  Widget testStorageButtun() {
    return Container(
      width: 180,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: FilledButton.tonal(
        onPressed: () {
          testStorage().then((value) {
            if (testSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Test success,you can save now')));
            } else {
              showErrorDialog(errormsg!);
            }
          });
        },
        child: const Text("Test storage"),
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
                SharedPreferences.getInstance().then((value) {
                  value.setString('addr', addr!);
                  value.setString('username', username!);
                  value.setString('password', password!);
                  value.setString('share', share!);
                  value.setString('rootPath', rootPath!);
                });
                eventBus.fire(RemoteRefreshEvent());
                Navigator.pop(context);
              }
            : null,
        child: const Text("Save"),
      ),
    );
  }

  void showErrorDialog(String msg) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Storage connection failed'),
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
