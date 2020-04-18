import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Widget listespisodiosaver = CircularProgressIndicator();
  int temporadaseleccionada = 1;
  List mapaseries = List();
  Widget serieselecionada = Container(
    child: Text("selecciona la serie que quieras ver"),
    alignment: Alignment.center,
  );
  @override
  Widget build(BuildContext context) {
    http
        .get("https://www.episodate.com/api/most-popular?page=1")
        .then((value) => {
              setState(() {
                mapaseries = jsonDecode(value.body)["tv_shows"];
              })
            });

    var hasDetailPage =
        MediaQuery.of(context).orientation == Orientation.landscape;
    var child;

    // 6
    child = _buildList(context, hasDetailPage);

    return Scaffold(
        body: SafeArea(
      // 7
      child: child,
    ));
  }

  _buildList(BuildContext context, bool hasDetailPage) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            children: [
              Icon(Icons.search),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: 'Busca tu serie '),
                ),
              )
            ],
          ),
        ),
      ),
      body: mapaseries.length > 0
          ? GridView.count(
              crossAxisCount: hasDetailPage ? 4 : 2,
              children: List.generate(mapaseries.length, (index) {
                return GestureDetector(
                  child: Container(
                    height: 50,
                    child: Card(
                      child: Column(
                        children: [
                          Image.network(
                            mapaseries[index]["image_thumbnail_path"],
                            height: MediaQuery.of(context).size.height / 5,
                          ),
                          Text(mapaseries[index]["name"])
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    _buildChat(
                        this.context,
                        mapaseries[index]["id"],
                        hasDetailPage,
                        mapaseries[index]["image_thumbnail_path"]);
                  },
                );
              }))
          : CircularProgressIndicator(),
    );
  }

  _buildChat(
      BuildContext context, int id, bool hasDetailPage, String imagen) async {
    await http
        .get("https://www.episodate.com/api/show-details?q=" + id.toString())
        .then((value) {
      Map mapaserie = jsonDecode(value.body);
      List espisodios = mapaserie["tvShow"]["episodes"];
      int numeroseason = 0;
      for (var i = 0; i < espisodios.length; i++) {
        espisodios[i]["season"] > numeroseason
            ? numeroseason = espisodios[i]["season"]
            : numeroseason = numeroseason;
      }
      setState(() {
        listaepisodiosseason(espisodios, 1, hasDetailPage);
        serieselecionada = OrientationBuilder(
          builder: (context, orientation) {
            return Scaffold(
                body: SingleChildScrollView(
                    child: Column(children: [
              Container(
                child: orientation == Orientation.landscape
                    ? Row(children: [
                        Expanded(
                            child: Container(
                          alignment: Alignment.topCenter,
                          child: Image.network(
                            imagen,
                          ),
                        )),
                        Expanded(
                          child: Column(
                            children: [
                              Card(
                                child: Column(children: [
                                  Card(
                                      child: Column(
                                    children: [
                                      Text(
                                        "Name: " + mapaserie["tvShow"]["name"],
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        "Genders: " +
                                            mapaserie["tvShow"]["genres"]
                                                .toString()
                                                .split("[")[1]
                                                .split("]")[0],
                                        textAlign: TextAlign.left,
                                      ),
                                      Text(
                                        "Description: " +
                                            mapaserie["tvShow"]["description"],
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  )),
                                  Text("Temporadas:"),
                                  Card(
                                      child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Column(
                                              children: List.generate(
                                                  numeroseason, (index) {
                                            return ExpansionTile(
                                                title: new Text("Temporada " +
                                                    (index + 1).toString()),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .accentColor
                                                        .withOpacity(0.025),
                                                children: listaepisodiosseason(
                                                    espisodios,
                                                    (index + 1),
                                                    orientation ==
                                                        Orientation.landscape));
                                          })))),
                                ]),
                              ),
                            ],
                          ),
                        )
                      ])
                    : Column(
                        children: [
                          Card(
                            child: Column(children: [
                              Card(
                                  child: Column(
                                children: [
                                  Text(
                                    "Name: " + mapaserie["tvShow"]["name"],
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(
                                    "Genders: " +
                                        mapaserie["tvShow"]["genres"]
                                            .toString()
                                            .split("[")[1]
                                            .split("]")[0],
                                    textAlign: TextAlign.left,
                                  ),
                                  Text(
                                    "Description: " +
                                        mapaserie["tvShow"]["description"],
                                    textAlign: TextAlign.left,
                                  )
                                ],
                              )),
                              Text("Temporadas:"),
                              Card(
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Column(
                                          children: List.generate(numeroseason,
                                              (index) {
                                        return ExpansionTile(
                                            title: new Text("Temporada " +
                                                (index + 1).toString()),
                                            backgroundColor: Theme.of(context)
                                                .accentColor
                                                .withOpacity(0.025),
                                            children: listaepisodiosseason(
                                                espisodios,
                                                (index + 1),
                                                orientation ==
                                                    Orientation.landscape));
                                      })))),
                            ]),
                          ),
                        ],
                      ),
              ),
              new RaisedButton(
                padding: const EdgeInsets.all(8.0),
                textColor: Colors.white,
                color: Colors.blue,
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: new Text("Regresar"),
              ),
            ])));
          },
        );
      });
    });

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => serieselecionada),
    );
  }

  listaepisodiosseason(List espisodios, int id, bool h) {
    List<Widget> lits = new List<Widget>();
    for (var i = 0; i < espisodios.length; i++) {
      if (h) {
        lits.add(ExpansionTile(
            title: new Text(espisodios[i]["episode"].toString() +
                "." +
                espisodios[i]["name"]),
            backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
            children: [
              new Text(
                  "Dori me Interimo, adapare Dori me Ameno Ameno Latire Latiremo Dori me Ameno Omenare imperavi ameno Dimere, dimere matiro Matiremo Ameno Omenare imperavi emulari, ameno Omenare imperavi emulari, ameno Ameno dore Ameno dori me Ameno dori me Ameno dom Dori me reo Ameno dori me Ameno dori me Dori me am")
            ]));
      } else {
        if (espisodios[i]["season"] == id) {
          lits.add(ListTile(
            title: Text(
              espisodios[i]["episode"].toString() + "." + espisodios[i]["name"],
              textAlign: TextAlign.center,
            ),
          ));
        }
      }
    }
    return lits;
  }
}
