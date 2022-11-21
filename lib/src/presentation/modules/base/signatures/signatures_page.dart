import 'dart:io';

import 'package:file_picker_cross/file_picker_cross.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:msk_widgets/msk_widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signature/signature.dart';

class SignaturesPage extends StatefulWidget {
  final String title;
  const SignaturesPage({Key? key, this.title = "Assinatura"}) : super(key: key);

  @override
  _SignaturesPageState createState() => _SignaturesPageState();
}

class _SignaturesPageState extends State<SignaturesPage> {
  var _key = GlobalKey<SignatureState>();
  final SignatureController _controller =
      SignatureController(penStrokeWidth: 5, penColor: Colors.black);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          FloatingActionButton(
            heroTag: 'clear',
            tooltip: 'Limpar',
            child: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _controller.clear();
                showSnack(context, 'Mensagem limpa com sucesso');
              });
            },
          ),
          FloatingActionButton(
            heroTag: 'select_signature',
            tooltip: 'Selecionar Imagem',
            child: Icon(Icons.camera),
            onPressed: () {
              showDialogFotos(context);
            },
          ),
          FloatingActionButton(
            heroTag: 'done',
            tooltip: 'Pronto',
            child: Icon(Icons.done),
            onPressed: () async {
              if (_controller.isNotEmpty) {
                File file = await UtilsFileSelect.saveFileBytes(
                    (await _controller.toPngBytes())!.toList(),
                    dirExtra: 'signatures',
                    fileName: '${DateTime.now().string('yyyyMMddTHHmmss')}',
                    extensionFile: '.png',
                    openExplorer: false);

                Navigator.pop(context, file);
              }
            },
          ),
        ],
      ),
      body: Signature(
        controller: _controller,
        width: size.width,
        //height: size.height - 100,
        key: _key,
        backgroundColor: Colors.white,
        // key that allow you to provide a GlobalKey that'll let you retrieve the image once user has signed
      ),
    );
  }

  Future<File> writeToFile(String patch, String fileName) async {
    String separator = '/';

    Directory tempDir = await getTemporaryDirectory();
    if (UtilsPlatform.isWindows) {
      separator = '\\';
      tempDir = Directory.current;
    }
    var filePath = tempDir.path +
        separator +
        patch; // file_01.tmp is dump file, can be anything
    Directory dir = Directory(filePath);
    if (!(await dir.exists())) {
      await dir.create();
    }
    File file = File(dir.path + separator + fileName);
    if ((await file.exists())) {
      file.create();
    }
    return file.writeAsBytes((await _controller.toPngBytes())!.toList());
  }

  Future<void> showDialogFotos(BuildContext buildContext) async {
    if (UtilsPlatform.isDesktop) {
      try {
        FilePickerCross filePickerCross =
            await FilePickerCross.importFromStorage(
                fileExtension: 'jpg, png, jpeg');
        Navigator.pop(buildContext, File(filePickerCross.path ?? ''));
      } catch (_) {}
    } else {
      showDialog(
          context: buildContext,
          builder: (context) => AlertDialog(
                title: Text('Selecione a forma'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    ListTile(
                      title: Text('Câmera'),
                      onTap: () async {
                        Navigator.pop(context);
                        var image = await ImagePicker()
                            .pickImage(source: ImageSource.camera);
                        if (image != null) {
                          Navigator.pop(buildContext, File(image.path));
                        }
                      },
                    ),
                    ListTile(
                      title: Text('Galeria'),
                      onTap: () async {
                        Navigator.pop(context);
                        var image = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          Navigator.pop(buildContext, File(image.path));
                        }
                      },
                    ),
                  ],
                ),
              ));
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }
}
