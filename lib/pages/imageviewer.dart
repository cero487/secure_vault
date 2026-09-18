import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:photo_view/photo_view.dart';

class Imageviewer extends StatefulWidget {
  final int initialindex;
  const Imageviewer(this.initialindex, {super.key});

  @override
  State<Imageviewer> createState() => _ImageviewerState();
}

class _ImageviewerState extends State<Imageviewer> {
  final _imagebox = Hive.box<String>('imagebox');
  late PageController _pageController;

  @override
  void initState(){
    super.initState();
    _pageController = PageController(initialPage: widget.initialindex);
  }

  @override
  void dispose(){
    _pageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box<String>('imagebox').listenable(),
        builder: (context, Box<String> box, _) {
          final List<String> imagepaths = box.values.toList();
          return PageView.builder(
            controller: _pageController,
            itemCount: imagepaths.length,
            itemBuilder: (context, index){
              int reverseindex = imagepaths.length-1-index;
              File imagefile = File(imagepaths[reverseindex]);
              return PhotoView(
                imageProvider: FileImage(imagefile),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                backgroundDecoration: BoxDecoration(color: Colors.black),
              );
            });
        }
      ),
      floatingActionButton:SizedBox(
        width: 140,
        child: Row(
          children: [
            GestureDetector(
              onTap: ()async{
              int currentindex = _pageController.page?.round() ?? widget.initialindex;
              int reverseindex = _imagebox.length-1-currentindex;
              String? imagepath = _imagebox.getAt(reverseindex);

              if (imagepath != null){
                try{
                  await Gal.putImage(imagepath);
                  // File  image = File(imagepath);
                  // if (await image.exists()){
                  //   await image.delete();
                  // }
                  // await _imagebox.deleteAt(currentindex);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Restored to gallary")),
                  );
                  if(_imagebox.isEmpty){
                    Navigator.pop(context);
                  }
                }catch (e){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }
            },
              child: Container(
                height: 50,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    bottomLeft: Radius.circular(50)
                  )
                ),
                child: Icon(Icons.restore,color: Colors.white,size: 30,),
              ),
            ),
            GestureDetector(
              onTap: ()async{
                int currentindex = _pageController.page?.round() ?? widget.initialindex;
                int reverseindex = _imagebox.length-1-currentindex;
                String? imagepath = _imagebox.getAt(reverseindex);

              if (imagepath != null){
                try{
                  File  image = File(imagepath);
                  if (await image.exists()){
                    await image.delete();
                  }
                  await _imagebox.deleteAt(reverseindex);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Image deleted")),
                  );
                  if(_imagebox.isEmpty){
                    Navigator.pop(context);
                  }
                }catch (e){
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
            }},
              child: Container(
                height: 50,
                width: 70,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(50),
                    bottomRight: Radius.circular(50)
                  )
                ),
                child: Icon(Icons.delete,color: Colors.white,size: 30,),
              ),
            )
          ],
        ), 
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.end,
      //   children: [
      //     FloatingActionButton(
      //       backgroundColor: Colors.purple,
      //       heroTag: 'restore_btn',
            // onPressed: ()async{
            //   int currentindex = _pageController.page?.round() ?? widget.initialindex;
            //   int reverseindex = _imagebox.length-1-currentindex;
            //   String? imagepath = _imagebox.getAt(reverseindex);

            //   if (imagepath != null){
            //     try{
            //       await Gal.putImage(imagepath);
            //       // File  image = File(imagepath);
            //       // if (await image.exists()){
            //       //   await image.delete();
            //       // }
            //       // await _imagebox.deleteAt(currentindex);
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text("Restored to gallary")),
            //       );
            //       if(_imagebox.isEmpty){
            //         Navigator.pop(context);
            //       }
            //     }catch (e){
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text("Error: $e")),
            //       );
            //     }
            //   }
            // },
      //       child: Icon(Icons.restore,color: Colors.white,),
      //       ),
      //       FloatingActionButton(
      //         heroTag: 'delete_btn',
      //         backgroundColor: Colors.redAccent,
            //   onPressed: ()async{
            //     int currentindex = _pageController.page?.round() ?? widget.initialindex;
            //     int reverseindex = _imagebox.length-1-currentindex;
            //     String? imagepath = _imagebox.getAt(reverseindex);

            //   if (imagepath != null){
            //     try{
            //       File  image = File(imagepath);
            //       if (await image.exists()){
            //         await image.delete();
            //       }
            //       await _imagebox.deleteAt(reverseindex);
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         const SnackBar(content: Text("Image deleted")),
            //       );
            //       if(_imagebox.isEmpty){
            //         Navigator.pop(context);
            //       }
            //     }catch (e){
            //       ScaffoldMessenger.of(context).showSnackBar(
            //         SnackBar(content: Text("Error: $e")),
            //       );
            //     }
            // }},
      //       child: Icon(Icons.delete,color: Colors.white,),
      //       )
      //   ],
      // ),
    ));
  }
}