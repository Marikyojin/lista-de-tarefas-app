import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _controleCampo = TextEditingController();
  List _tarefas = [];
  Map<String, dynamic> _ultimoRemovido = Map();

  Future<File> _getFile() async {
    final diretorio = await getApplicationDocumentsDirectory();
    return File("${diretorio.path}/dados.json");
  }

  _salvarTarefa() {
    String textoDigitado = _controleCampo.text;
    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;
    setState(() {
      _tarefas.add(tarefa);
    });

    _salvarArquivo();
    _controleCampo.text = "";
  }

  _salvarArquivo() async {
    var arquivo = await _getFile();
    String dados = json.encode(_tarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try {
      final arquivo = await _getFile();
      return arquivo.readAsString();
    } catch (e) {
      return "";
    }
  }

  @override
  void initState() {
    _lerArquivo().then((dados) {
      setState(() {
        _tarefas = json.decode(dados);
      });
    });
    super.initState();
  }

  Widget criarItemLista(context, indice) {
    final item = _tarefas[indice]["titulo"];

    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          //recuperar item excluido
          _ultimoRemovido = _tarefas[indice];

          //remover item da lista
          _tarefas.removeAt(indice);
          _salvarArquivo();

          //snackbar
          final snackbar = SnackBar(
            content: Text(
              "Tarefa removida!!",
              style: TextStyle(color: Color(0xFFC5EFF7)),
            ),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              textColor: Color(0xFFC5EFF7),
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _tarefas.insert(indice, _ultimoRemovido);
                  });
                  _salvarArquivo();
                }),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
        background: Container(
          color: Colors.redAccent,
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.delete,
                color: Color(0xFFC5EFF7),
              )
            ],
          ),
        ),
        child: CheckboxListTile(
            title: Text(
              _tarefas[indice]["titulo"],
              style: TextStyle(color: Color(0xFF58007E), fontSize: 20),
            ),
            value: _tarefas[indice]["realizada"],
            onChanged: (valorAlterado) {
              setState(() {
                _tarefas[indice]["realizada"] = valorAlterado;
              });

              _salvarArquivo();
            }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xFFFFECDB),
        appBar: AppBar(
          backgroundColor: Color(0xFF58007E),
          title: Text(
            "Lista de Tarefas",
            style: TextStyle(color: Color(0xFFC5EFF7)),
          ),
        ),
        body: Center(
          child: Container(
              padding: EdgeInsets.all(20),
              child: Expanded(
                child: ListView.builder(
                    itemCount: _tarefas.length, itemBuilder: criarItemLista
                    //(context, indice) {

                    // return ListTile(
                    //   title: Text(
                    //     _tarefas[indice]["titulo"],
                    //     style:
                    //         TextStyle(color: Color(0xFF58007E), fontSize: 20),
                    //   ),
                    // );
                    // }
                    ),
              )),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          elevation: 20,
          mini: false,
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: Color(0xFFFFECDB),
                    title: Text(
                      "Adicionar tarefa",
                      style: TextStyle(color: Color(0xFF58007E), fontSize: 20),
                    ),
                    content: TextField(
                      style: TextStyle(color: Color(0xFF58007E), fontSize: 20),
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                          disabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFC5EFF7))),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF58007E))),
                          labelText: "Digite sua tarefa",
                          labelStyle: TextStyle(
                              color: Color(0xFF58007E), fontSize: 20)),
                      cursorColor: Color(0xFF58007E),
                      controller: _controleCampo,
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            "Cancelar",
                            style: TextStyle(
                              backgroundColor: Color(0xFF58007E),
                              color: Color(0xFFC5EFF7),
                            ),
                          )),
                      TextButton(
                          onPressed: () {
                            _salvarTarefa();
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Salvar",
                            style: TextStyle(
                              backgroundColor: Color(0xFF58007E),
                              color: Color(0xFFC5EFF7),
                            ),
                          )),
                    ],
                  );
                });
          },
          backgroundColor: Color(0xFF58007E),
          foregroundColor: Color(0xFFC5EFF7),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Color(0xFF58007E),
          child: Row(
            children: [
              IconButton(
                  color: Color(0xFFC5EFF7),
                  onPressed: () {},
                  icon: Icon(Icons.menu))
            ],
          ),
        ));
  }
}
