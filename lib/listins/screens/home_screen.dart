import 'package:flutter/material.dart';
import 'package:flutter_listin/authentication/models/mock_user.dart';
import 'package:flutter_listin/listins/data/database.dart';
import 'package:flutter_listin/listins/screens/widgets/home_drawer.dart';
import 'package:flutter_listin/listins/screens/widgets/home_listin_item.dart';
import '../models/listin.dart';
import 'widgets/listin_add_edit_modal.dart';
import 'widgets/listin_options_modal.dart';

class HomeScreen extends StatefulWidget {
  final MockUser user;
  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Listin> listListins = [];
  late AppDatabase _appDatabase;

  @override
  void initState() {
    _appDatabase = AppDatabase();
    refresh();
    super.initState();
  }

  @override
  void dispose() {
    _appDatabase.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: HomeDrawer(user: widget.user),
      appBar: AppBar(
        title: const Text("Minhas listas"),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem(
                child: Text('Ordenar por nome'),
                value: 'name',
              ),
              const PopupMenuItem(
                child: Text('Ordenar por data de alteração'),
                value: 'dateUpdate',
              ),
            ],
            onSelected: (String result) async {
              switch (result) {
                case 'name':
                  await refresh(orderBy: 'name');
                  break;
                case 'dateUpdate':
                  await refresh(orderBy: 'dateUpdate');
                  break;
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAddModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (listListins.isEmpty)
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset("assets/bag.png"),
                  const SizedBox(height: 32),
                  const Text(
                    "Nenhuma lista ainda.\nVamos criar a primeira?",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => refresh(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
                child: ListView.builder(
                  itemCount: listListins.length,
                  itemBuilder: (context, index) {
                    Listin listin = listListins[index];
                    return HomeListinItem(
                      listin: listin,
                      showOptionModal: showOptionModal,
                    );
                  },
                ),
              ),
            ),
    );
  }

  showAddModal({Listin? listin}) {
    showAddEditListinModal(
        context: context,
        onRefresh: refresh,
        model: listin,
        appDatabase: _appDatabase);
  }

  showOptionModal(Listin listin) {
    showListinOptionsModal(
      context: context,
      listin: listin,
      onRemove: remove,
    ).then((value) {
      if (value != null && value) {
        showAddModal(listin: listin);
      }
    });
  }

  refresh({String orderBy = ''}) async {
    List<Listin> listaListins = await _appDatabase.getListins(orderBy: orderBy);

    setState(() {
      listListins = listaListins;
    });
  }

  void remove(Listin model) async {
    // TODO - CRUD Listin: remover o Listin
    refresh();
  }
}