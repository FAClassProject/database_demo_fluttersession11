import 'package:database_demo_fluttersession11/data_base/database_service.dart';
import 'package:database_demo_fluttersession11/user_model/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class SqfliteExampleScreen extends StatefulWidget {
  const SqfliteExampleScreen({Key? key}) : super(key: key);

  @override
  State<SqfliteExampleScreen> createState() => _SqfliteExampleScreenState();
}

class _SqfliteExampleScreenState extends State<SqfliteExampleScreen> {
  final dbService = DataBaseService();
  //final TextEditingController _idTextEditingController = TextEditingController();
  final TextEditingController _nameTextEditingController = TextEditingController();
  final TextEditingController _emailTextEditingController = TextEditingController();
  final TextEditingController _ageTextEditingController = TextEditingController();

  void showBottomSheet(String functionName, Function()? onPressed){
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_)=> Container(
          padding: EdgeInsets.only(left: 15, top: 15, right: 15,
              bottom: MediaQuery.of(context).viewInsets.bottom +120),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
              controller: _nameTextEditingController,
            decoration: InputDecoration(
              hintText: 'Name'
            ),
          ),
          SizedBox(height: 10,),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: _emailTextEditingController,
                decoration: InputDecoration(
                    hintText: 'Email'
                ),
              ),
              SizedBox(height: 10,),
              TextField(
                keyboardType: TextInputType.number,
                controller: _ageTextEditingController,
                decoration: InputDecoration(
                    hintText: 'Age'
                ),
              ),
              SizedBox(height: 10,),

              ElevatedButton(
                  onPressed: onPressed,
             child: Text(functionName)
              )],
          ),
        ));
  }
  void addUser(){
    showBottomSheet('Add User', ()async{
      var user = UserModel(
          id: Uuid().v4(),
          name: _nameTextEditingController.text,
          email: _emailTextEditingController.text,
          age: int.parse(_ageTextEditingController.text.toString()));
      dbService.insertUser(user);
      setState(() {});
      _ageTextEditingController.clear();
    _emailTextEditingController.clear();
    _nameTextEditingController.clear();
    Navigator.of(context).pop();
    });
  }
  void editUser(UserModel  userModel){
    _nameTextEditingController.text = userModel.name;
    _emailTextEditingController.text = userModel.email;
    _ageTextEditingController.text = userModel.age.toString();
    showBottomSheet("Edit User", ()async{
      var updateUser = UserModel(
          id: userModel.id,
          name: _nameTextEditingController.text,
          email: _emailTextEditingController.text,
          age: int.parse(_ageTextEditingController.text));
      dbService.editUser(updateUser);
      setState(() {});
      _ageTextEditingController.clear();
      _emailTextEditingController.clear();
      _nameTextEditingController.clear();
      Navigator.of(context).pop();
    });
  }
  void deleteUser(String id){
    dbService.deleteUser(id);
    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sqlflite CRUD Operation"),),
      body: FutureBuilder(
        future: dbService.getAllUser(),
          builder: (context, dataSnapShot){
          if(dataSnapShot.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator());
          }
          if(dataSnapShot.hasData){
            if(dataSnapShot.data!.isEmpty){
              return Center(child: Text('No Users Found'),);
            }
            return ListView.builder(
              itemCount: dataSnapShot.data!.length,
                itemBuilder: (context, index) => Card(
                  color: Colors.grey,
                  margin: EdgeInsets.all(15.0),
                  child: ListTile(
                    title: Text(dataSnapShot.data![index].name +' '+dataSnapShot.data![index].age.toString()+' '),
                    subtitle: Text(dataSnapShot.data![index].email),
                    trailing: SizedBox(width: 100, child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      IconButton(onPressed: (){
                        editUser(dataSnapShot.data![index]);
                      }, icon: Icon(Icons.edit)),

                      IconButton(onPressed: (){
                        deleteUser(dataSnapShot.data![index].id);
                      }, icon: Icon(Icons.delete, color: Colors.red,))

                    ],),),

                  ),
                ));
          }
          return Center(child: Text("No Users Found"),);
          }
          ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white,),
          onPressed: (){
          addUser();
          }),
    );
  }
}
