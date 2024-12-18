import 'package:flutter/material.dart';
import 'package:flutter_application_2/api_handler.dart';
import 'package:flutter_application_2/model.dart';

class FindUser extends StatefulWidget {
  const FindUser({super.key});

  @override
  State<FindUser> createState() => _FindUserState();
}

class _FindUserState extends State<FindUser> {
  ApiHandler apiHandler = ApiHandler();
  User user = const User.empty();
  bool singleUser = false;
  TextEditingController textEditingController = TextEditingController();

  Future<void> findUser(int id) async {
    user = await apiHandler.getUserbyId(id: id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Buscar usuario por id",),
          centerTitle: true,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBar: MaterialButton(
          color: Colors.teal,
          textColor: Colors.white,
          padding: const EdgeInsets.all(10),
          onPressed: () async {
            singleUser = await apiHandler.userExists(
                id: int.parse(textEditingController.text));
            if (singleUser) {
              findUser(int.parse(textEditingController.text));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Ese usuario no existe')));
            }
          },
          child: const Text('Buscar Usuario'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                controller: textEditingController,
              ),
              const SizedBox(
                height: 10,
              ),
              ListTile(
                leading: Text("${user.userId}"),
                title: Text(user.email),
                subtitle: Text(user.password),
              ),
            ],
          ),
        ));
  }
}
