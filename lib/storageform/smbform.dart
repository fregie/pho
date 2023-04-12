import 'package:flutter/material.dart';
import 'package:img_syncer/event_bus.dart';
import 'package:img_syncer/proto/img_syncer.pbgrpc.dart';
import 'package:img_syncer/state_model.dart';
import 'package:img_syncer/storage/storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SMBForm extends StatefulWidget {
  const SMBForm({Key? key}) : super(key: key);
  @override
  _SMBFormState createState() => _SMBFormState();
}

class _SMBFormState extends State<SMBForm> {
  @protected
  final GlobalKey _formKey = GlobalKey<FormState>();
  String? smbAddr;
  TextEditingController? smbAddrController;
  String? smbUsername;
  TextEditingController? smbUsernameController;
  String? smbPassword;
  TextEditingController? smbPasswordController;
  String? smbShare;
  TextEditingController? smbShareController;
  String? smbRootPath;
  TextEditingController? smbRootPathController;
  bool testSuccess = false;
  String? errormsg;

  List<String> _optionShares = [];

  String currentPath = "";

  @override
  void initState() {
    super.initState();
    smbAddrController = TextEditingController(text: smbAddr);
    smbUsernameController = TextEditingController(text: smbUsername);
    smbPasswordController = TextEditingController(text: smbPassword);
    smbShareController = TextEditingController(text: smbShare);
    smbRootPathController = TextEditingController(text: smbRootPath);
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        smbAddr = prefs.getString("addr");
        smbUsername = prefs.getString("username");
        smbPassword = prefs.getString("password");
        smbShare = prefs.getString("share");
        smbRootPath = prefs.getString("rootPath");
      });
      smbAddrController!.text = smbAddr ?? "";
      smbUsernameController!.text = smbUsername ?? "";
      smbPasswordController!.text = smbPassword ?? "";
      smbShareController!.text = smbShare ?? "";
      smbRootPathController!.text = smbRootPath ?? "";

      refreshShare();
      smbAddrController!.addListener(() => refreshShare());
      smbUsernameController!.addListener(() => refreshShare());
      smbPasswordController!.addListener(() => refreshShare());
      smbShareController!.addListener(() {
        if (smbShare == smbShareController!.text) {
          return;
        }
        storage.cli.setDriveSMB(SetDriveSMBRequest(
          addr: smbAddr,
          username: smbUsername,
          password: smbPassword,
          share: smbShare,
        ));
        smbRootPathController!.text = "";
        setState(() {
          smbShare = smbShareController!.text;
          smbRootPath = null;
        });
      });
    });
  }

  Future<void> refreshShare() async {
    final a = smbAddr;
    final u = smbUsername;
    final p = smbPassword;
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
      share: smbShare,
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

  Widget smbForm(BuildContext context) {
    List<Widget> children = [
      input("Samba server address", smbAddrController, (v) => smbAddr = v),
      input("Username", smbUsernameController, (v) => smbUsername = v),
      input("Password", smbPasswordController, (v) => smbPassword = v),
      Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: TextFormField(
          controller: smbShareController,
          obscureText: false,
          enableInteractiveSelection: true,
          onSaved: (v) => smbShare = v,
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
          controller: smbRootPathController,
          obscureText: false,
          enableInteractiveSelection: true,
          onSaved: (v) => smbRootPath = v,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: "Root path(Your photos will be uploaded to this path)",
            suffixIcon: smbShare == null || smbShare == ""
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
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          testStorageButtun(),
          saveButtun(),
        ],
      ),
    ];
    return Form(
      key: _formKey,
      child: Column(
        children: children,
      ),
    );
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
                      smbShareController!.text = _optionShares[index];
                      setState(() {
                        smbShare = _optionShares[index];
                        smbRootPathController!.text = "";
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
                          smbRootPathController!.text = currentPath;
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

  Future<void> testStorage() async {
    var form = _formKey.currentState as FormState;
    if (form.validate()) {
      form.save();
      try {
        SetDriveSMBResponse rsp =
            await storage.cli.setDriveSMB(SetDriveSMBRequest(
          addr: smbAddr!,
          username: smbUsername!,
          password: smbPassword!,
          share: smbShare!,
          root: smbRootPath!,
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
                  value.setString('addr', smbAddr!);
                  value.setString('username', smbUsername!);
                  value.setString('password', smbPassword!);
                  value.setString('share', smbShare!);
                  value.setString('rootPath', smbRootPath!);
                });
                stateModel.setRemoteStorageSetted(true);
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

  @override
  Widget build(BuildContext context) {
    return smbForm(context);
  }
}
