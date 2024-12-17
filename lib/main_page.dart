import 'package:flutter/material.dart';
import 'package:flutter_application_2/add_user.dart';
import 'package:flutter_application_2/api_handler.dart';
import 'package:flutter_application_2/edit_page.dart';
import 'package:flutter_application_2/find_user.dart';
import 'package:flutter_application_2/model.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  ApiHandler apiHandler = ApiHandler();
  late List<User> data = [];
  late List<User> filteredData = [];
  TextEditingController textEditingController = TextEditingController();

  void getData() async {
    data = await apiHandler.getUserData();
    filteredData = List.from(data);
    setState(() {});
  }

  void deleteUser(int id) async {
    await apiHandler.deleteUser(id: id);
    getData();
  }

  void filterUsers(String query) {
    setState(() {
      filteredData = data
          .where((user) =>
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CalificacionesAJS"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        padding: const EdgeInsets.all(10),
        onPressed: getData,
        child: const Text('Refresh'),
      ),
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        FloatingActionButton(
          heroTag: 1,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddUser()),
            ).then((value) {
              getData();
            });
          },
          child: const Icon(Icons.add),
        ),
        const SizedBox(
          width: 10,
        ),
        FloatingActionButton(
          heroTag: 2,
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindUser()),
            );
          },
          child: const Icon(Icons.person_search),
        ),  
      ]),
      body: ListView(
        children: [
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(width: 10,),
              Expanded(
                flex: 17,
                child: TextField(   
                  /// Metodo para filtrar solo con llenar el texto, es decir, sin boton
                  // onChanged: (value) {
                  //   filterUsers(value);
                  // },
                  controller: textEditingController,               
                  decoration:  InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'filtrar', 
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.6)),
                  ),              
                  )
                ),
              Expanded(
                flex: 3,
                child: FloatingActionButton(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  onPressed: (){
                    filterUsers(textEditingController.text);
                  },
                  child: const Icon(Icons.filter_alt_outlined),
                )
              ),
              const SizedBox(width: 5,),
            ]            
          ),          
          ListView.builder(
            shrinkWrap: true,
            itemCount: filteredData.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditPage(
                          user: filteredData[index],
                        ),
                      )).then((value) {
                    getData();
                  });
                },
                leading: Text("${filteredData[index].userId}"),
                title: Text(filteredData[index].email),
                subtitle: Text(filteredData[index].password),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    deleteUser(filteredData[index].userId);
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 80,)
        ],
      ),
    );
  }
}
