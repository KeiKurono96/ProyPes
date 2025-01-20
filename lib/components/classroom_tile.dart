import 'package:flutter/material.dart';

class ClassroomTile extends StatelessWidget {
  final String text;
  final void Function()? tapDelete;

  const ClassroomTile({
    super.key, 
    required this.text, 
    required this.tapDelete,   
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 30),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(text, style: TextStyle(color: Theme.of(context).colorScheme.primary),),
          SizedBox(width: 10,),
          IconButton(onPressed: tapDelete, icon: Icon(
            Icons.delete, color: Theme.of(context).colorScheme.primary,
          )),
        ],
      ),
    );
  }
}