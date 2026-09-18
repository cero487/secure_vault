import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:secure_vault/notes.dart';

class Newnotes extends StatefulWidget {
  final int? noteindex;
  const Newnotes({super.key,this.noteindex});

  @override
  State<Newnotes> createState() => _NewnotesState();
}

class _NewnotesState extends State<Newnotes> {
  

  final _notesbox = Hive.box<Notes>('notesbox');
  final _formglobalkey = GlobalKey<FormState>();
  String _title = "";
  String _content = "";

  @override
  void initState(){
    super.initState();
    if(widget.noteindex != null){
      final existingnote = _notesbox.getAt(widget.noteindex!);
      if(existingnote != null){
        _title = existingnote.title;
        _content = existingnote.content;
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        // iconTheme: IconThemeData(color: Colors.white),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(widget.noteindex == null? "New Note": "note"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Form(
                  key: _formglobalkey,
                  child: Column(
                  children: [
                    TextFormField(
                      // style: TextStyle(color: Colors.white),
                      initialValue: _title,
                      maxLength: 30,
                      decoration: InputDecoration(
                        label: Text("Title"),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      validator: (value) {
                        if (value==null || value.isEmpty){
                          return "Fill in the title";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _title = newValue!;
                      },
                    ),
                    TextFormField(
                      // style: TextStyle(color: Colors.white),
                      initialValue: _content,
                      minLines: 10,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        label: Text("Content"),
                      ),
                      validator: (value) {
                        if (value==null || value.isEmpty || value.length < 5){
                          return "Must be at least 5 char long";
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _content = newValue!;
                      },
                    )
                  ],
                )),
                ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check, color: Colors.white,),
        onPressed: (){
          if(_formglobalkey.currentState!.validate()){
            _formglobalkey.currentState!.save();
            setState(() {
              _notesbox.put('key_$_title', Notes(title: _title, content: _content));
            });
            Navigator.pop(context);
          }
      }),
    );
  }
}