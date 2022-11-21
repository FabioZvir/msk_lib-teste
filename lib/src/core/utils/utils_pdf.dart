import 'dart:io';
import 'dart:typed_data';

import 'package:msk/msk.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class UtilsPDFBase {
  static showDialogPDF(BuildContext context, Uint8List uint8list,
      {String? fileName,
      String extensionFile = '.pdf',
      String? dirExtra,
      String? contentExport}) async {
    return await showDialog(
        context: context,
        builder: (alertContext) => AlertDialog(
              title: Text('Selecione uma opção'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.print),
                    title: Text('Imprimir'),
                    onTap: () async {
                      Navigator.pop(alertContext);
                      await Printing.layoutPdf(
                          onLayout: (_) async => uint8list);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.save),
                    title: Text('Salvar PDF'),
                    onTap: () {
                      Navigator.pop(alertContext);
                      UtilsFileSelect.saveFileBytes(
                        uint8list,
                        fileName: fileName,
                        extensionFile: extensionFile,
                        dirExtra: dirExtra,
                        contentExport: contentExport,
                      );
                    },
                  ),
                  if (UtilsPlatform.isMobile)
                    ListTile(
                      leading: Icon(Icons.share),
                      title: Text('Compartilhar'),
                      onTap: () {
                        Navigator.pop(alertContext);
                        UtilsFileSelect.saveFileBytes(uint8list,
                            fileName: fileName,
                            extensionFile: extensionFile,
                            dirExtra: dirExtra,
                            contentExport: contentExport,
                            openExplorer: true);
                      },
                    ),
                  if (UtilsPlatform.isWindows)
                    ListTile(
                      leading: Icon(Icons.save),
                      title: Text('Salvar e abrir PDF'),
                      onTap: () async {
                        Navigator.pop(alertContext);
                        File file = await UtilsFileSelect.saveFileBytes(
                            uint8list,
                            fileName: fileName,
                            extensionFile: extensionFile,
                            dirExtra: dirExtra,
                            contentExport: contentExport,
                            openExplorer: false);
                        UtilsPlatform.openProcess('explorer.exe',
                            args: [file.path]);
                      },
                    ),
                ],
              ),
            ));
  }
}
