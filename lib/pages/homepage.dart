import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:secure_vault/notes.dart';
import 'package:secure_vault/pages/imageviewer.dart';
import 'package:secure_vault/pages/newnotes.dart';
import 'package:secure_vault/pages/videoplayer.dart';
import 'package:secure_vault/theme_provider.dart';
import 'package:secure_vault/widgets/button.dart';
import 'package:secure_vault/widgets/icon-button.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}



class _HomepageState extends State<Homepage> {

  final PageController _pagecontroller = PageController();
  @override
  void dispose(){
    _pagecontroller.dispose();
    super.dispose();
  }

  final _passwordbox = Hive.box('passwordbox');
  final _imagebox = Hive.box<String>('imagebox');
  final _videobox = Hive.box<String>('videobox');
  final _notesbox = Hive.box<Notes>('notesbox');

  void _moreactions(){
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: double.infinity,
          height: 170,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 51, 4, 132),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20)
            )
          ),
          child: Center(child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text("Logout", style: TextStyle(fontSize: 20, color: Colors.white),),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Password"),
          content: Text("Are you sure you want to change password?"),
          actions: [
            GestureDetector(
              onTap: () {
                _passwordbox.delete(1);
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/');
                
              },
              child: MyIconButton(height: 50, width: 50, color: Colors.green, radius: 12, icon: Icons.check, iconcolor: Colors.white, size: 20)),
            GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: MyIconButton(height: 50, width: 50, color: Colors.red, radius: 12, icon: Icons.cancel, iconcolor: Colors.white, size: 20)),
                    
          ],
        );
      },
    );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text("Change Password",style: TextStyle(fontSize: 20, color: Colors.white),),
                ),
              ),
              IconButton(
                      onPressed: (){
                        Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
                        Navigator.pop(context);
                    }, 
                    icon: Icon(Provider.of<ThemeProvider>(context).isDarkMode?Icons.light_mode:Icons.dark_mode))
            ],
          )),
        );
      },
    );
  }

  String home_state = "notes";

Future _imagepicker()async{
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type:  FileType.image,
  );
  if (result == null || result.files.single.path==null)return null;

  String temppath = result.files.single.path!;
  File tempfile = File(temppath);

  Directory appDocDir = await getApplicationDocumentsDirectory();

  String filename = 'img_${DateTime.now().millisecondsSinceEpoch}.jpg';
  String permanentpath = '${appDocDir.path}/$filename';

  File savedimage = await tempfile.copy(permanentpath);
  String imagepath = savedimage.path;

  await _imagebox.add(imagepath);

}

Future _videopicker()async{
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type:  FileType.video,
  );
  if (result == null || result.files.single.path==null)return null;

  String temppath = result.files.single.path!;
  File tempfile = File(temppath);

  Directory appDocDir = await getApplicationDocumentsDirectory();

  String extension = result.files.single.extension ?? 'mp4';
  String filename = 'vid_${DateTime.now().millisecondsSinceEpoch}.$extension';
  String permanentpath = '${appDocDir.path}/$filename';

  File savedvideo = await tempfile.copy(permanentpath);
  String videopath = savedvideo.path;

  String? thumbnail = await VideoThumbnail.thumbnailFile(
    video: videopath,
    thumbnailPath: appDocDir.path,
    imageFormat: ImageFormat.JPEG,
    maxWidth: 512,
    quality: 75
  );
  if (thumbnail != null){
    String combinedpaths = "$videopath||$thumbnail";
    await _videobox.add(combinedpaths);
  }

  

}

  void _floatingaction(){
    if (home_state=="videos"){
      _videopicker();

    }else if (home_state=="notes"){
      Navigator.pushNamed(context, '/newnote');

    }else{
      _imagepicker();
    }
  }

Widget _getfabcon(){
  IconData currenticon;
  String currenttext;
  if (home_state=="videos"){
    currenticon = Icons.movie;
    currenttext = "New video";

  }else if (home_state=="notes"){
    currenticon = Icons.note_add;
    currenttext = "New Note";

  }else{
    currenticon = Icons.add_photo_alternate;
    currenttext = "New Picture";

  }
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: [
      Expanded(child: Icon(currenticon, size: 30,)),
      Expanded(child: Text(currenttext,style: TextStyle(fontSize: 16,fontWeight: FontWeight.w800),))
    ],
  );
}

Widget _buildvideoview(){
  return ValueListenableBuilder(
    valueListenable: Hive.box<String>('videobox').listenable(),
    builder: (context, Box<String> box, _) {
      final List<String> videopaths = box.values.toList();
      if (videopaths.isEmpty){
        return Center(child: Text("No Videos Found",style: TextStyle(color: Colors.white),),);
      }
      return GridView.builder(
                      key: ValueKey('video_grid'),
                      itemCount: videopaths.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1), 
                        itemBuilder: (context, index) {
                          int reverseindex = videopaths.length-1-index;
                          List<String> paths = videopaths[reverseindex].split('||');
                          String thumbpath = paths.length > 1 ? paths[1]: '';
                          return Card(
                            // color: const Color(0xFF1A1D24),
                            child: Center(
                              child: Stack(
                                fit: StackFit.expand,
                                children:[
                                if (thumbpath.isNotEmpty)
                                  Image.file(File(thumbpath)),
                                  Center(
                                  child: IconButton(
                                    onPressed: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=>Videoplayer(index)));
                                  }, 
                                  icon: Icon(Icons.play_circle_filled,color: Colors.white,size: 30,)),
                                  ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            border: Border.all(
                                              color: Colors.white
                                            ),
                                            borderRadius: BorderRadius.circular(50)),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          GestureDetector(
                                            onTap: ()async{
                                            // String? data = _videobox.getAt(reverseindex);
                                      
                                            if (videopaths != null){
                                              try{
                                                // List<String> paths = data.split('||');
                                                String videopath = paths[0];
                                                String thumbpath = paths.length > 1 ? paths[1]: '';
                                                await Gal.putVideo(videopath);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text("Restored to gallary")),
                                                );
                                              }catch (e){
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text("Error: $e")),
                                                );
                                              }
                                            }
                                          },
                                            child: Icon(Icons.restore,color: Colors.purpleAccent,size: 30,),
                                          ),
                                          GestureDetector(
                                            onTap: () async{
                                              // String? data = _videobox.getAt(reversedindex);
                                      
                                              if(videopaths != null){
                                                File videoFile = File(paths[0]);
                                                File thumbFile = File(paths.length > 1 ? paths[1]: '');
                                      
                                                if(await videoFile.exists()) await videoFile.delete();
                                                if(await thumbFile.exists()) await thumbFile.delete();
                                                await box.deleteAt(reverseindex);}
                                      
                                            },
                                            child: Icon(Icons.delete,color: Colors.redAccent,size: 30,),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                  ]),
                            ),
                          );
                        },);
    }
  );
  }

Widget _buildnotesview(){
  return ValueListenableBuilder(
    valueListenable: Hive.box<Notes>('notesbox').listenable(),
    builder: (context, Box<Notes> box, _) {
      final List<Notes> noteslist = box.values.toList();
      if (noteslist.isEmpty){
        return Center(child: Text("No Image Found",style: TextStyle(color: Colors.white),),);
      }
      return ListView.builder(key: ValueKey('notes'),
                      itemCount: noteslist.length,
                      itemBuilder: (context,index){
                        int reverseindex = noteslist.length-1-index;
                        final currentnote = noteslist[reverseindex];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)
                            ),
                            trailing: IconButton(
                              onPressed: (){
                                box.deleteAt(reverseindex);
                            }, icon: Icon(Icons.delete,color: Colors.red,)),
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => Newnotes(noteindex: reverseindex,)));
                            },
                            tileColor: Theme.of(context).colorScheme.surface,
                            title: Text(currentnote.title,),
                            subtitle: Text(currentnote.content, overflow: TextOverflow.ellipsis,maxLines: 2),
                          ),
                        );
                      });
    }
  );
}
Widget _buildpicsview(){
  return ValueListenableBuilder(
    valueListenable: Hive.box<String>('imagebox').listenable(),
    builder: (context, Box<String> box, _) {
      final List<String> imagepaths = box.values.toList();
      if (imagepaths.isEmpty){
        return Center(child: Text("No Image Found",style: TextStyle(color: Colors.white),),);
      }
      return GridView.builder(
                      key: ValueKey('image_grid'),
                      itemCount: imagepaths.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1), 
                        itemBuilder: (context, index) {
                          int reverseindex = imagepaths.length-1-index;
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>Imageviewer(index),));
                            },
                            child: Card(
                              child: Center(child: Stack(children: [
                                Image.file(File(imagepaths[reverseindex]), fit: BoxFit.cover,width: double.infinity,height: double.infinity,),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        border: Border.all(
                                          color: Colors.white
                                        ),
                                        borderRadius: BorderRadius.circular(50)),
                                      child: Row(
                                        children: [
                                          IconButton(onPressed: () async {
                                            String? imagepath = box.getAt(index);

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
                                          icon: Icon(Icons.restore,color: Colors.purple,)),
                                          IconButton(
                                            onPressed: () async {
                                              String? imagepath = box.getAt(index);
                                              if (imagepath != null){
                                                try{
                                                  File image = File(imagepath);
                                                  if (await image.exists()){
                                                    await image.delete();
                                                    await box.deleteAt(index);
                                                  }
                                                } catch (e){
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text("Error: $e"),
                                                      duration: Duration(seconds: 3),
                                                    )
                                                  );
                                                }
                                              }
                                          }, 
                                          icon: Icon(Icons.delete,color: Colors.red,)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],),)
                            ),
                          );
                        },);
    }
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("SecureVault",style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
              IconButton(
                onPressed: (){
                  _moreactions();
                },
                icon: Icon(Icons.lock))
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 63, 55, 72).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(50)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            home_state = "notes";
                          });
                          _pagecontroller.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                        child: home_state == "notes" ? Button(height: 50, width: 120, color: const Color.fromARGB(255, 51, 4, 132), radius: 50, text: "Notes"): Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                          child: Icon(Icons.description,color: Colors.white,size: 30,),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            home_state = "videos";
                          });
                          _pagecontroller.animateToPage(1, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                        child: home_state == "videos" ? Button(height: 50, width: 120, color: Colors.deepPurple, radius: 50, text: "Videos"): Padding(
                          padding:home_state=='pics'? const EdgeInsets.fromLTRB(15, 0, 22, 0):const EdgeInsets.fromLTRB(0, 0, 22, 0),
                          child: Icon(Icons.video_library,color: Colors.white,size: 30,)
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            home_state = "pics";
                          });
                          _pagecontroller.animateToPage(2, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                        },
                        child: home_state == "pics" ? Button(height: 50, width: 120, color: Colors.deepPurple, radius: 50, text: "pictures"): Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 22, 0),
                          child: Icon(Icons.photo_library,color: Colors.white,size: 30,)
                        ),
                      )
                    
                    ],
                  ),
                ),
                SizedBox(height: 15,),
                  Expanded(
                    child: PageView(
                      controller:  _pagecontroller,
                      onPageChanged: (index) {
                        setState(() {
                          if(index==0) home_state ="notes";
                          if(index==1) home_state ="videos";
                          if(index==2) home_state ="pics";
                          
                        });
                      },
                      children: [
                        _buildnotesview(),
                        _buildvideoview(),
                        _buildpicsview()
                      ]))
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: SizedBox(
        width: 125,
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 51, 4, 132),
          foregroundColor: Colors.white,
          child: _getfabcon(),
          onPressed: (){
            _floatingaction();
        }),
      ),
      );
  }
}