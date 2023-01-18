import 'package:flutter/material.dart';
import 'sql_helper.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _listData = [];
  bool _isLoading = true;
  void _refreshData() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _listData = data;
      _isLoading = false;
    });
  }
  @override
  void initState() {
    super.initState();
    _refreshData();
  }
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  void _showForm(int? id) async {
    if (id != null) {
      final existingData =
      _listData.firstWhere((element) => element['id'] == id);
      _nameController.text = existingData['name'];
      _numberController.text = existingData['number'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _numberController,
                decoration: const InputDecoration(hintText: 'Number'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addItem();
                  }
                  if (id != null) {
                    await _updateItem(id);
                  }
                  _nameController.text = '';
                  _numberController.text = '';
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }
  Future<void> _addItem() async {
    await SQLHelper.createItem(
        _nameController.text, _numberController.text);
    _refreshData();
  }
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _nameController.text, _numberController.text);
    _refreshData();
  }
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Deleted!'),
    ));
    _refreshData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplier'),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: _listData.length,
        itemBuilder: (context, index) => Card(
          color: Colors.orange[200],
          margin: const EdgeInsets.all(15),
          child: ListTile(
              title: Text(_listData[index]['name']),
              subtitle: Text(_listData[index]['number']),
              trailing: SizedBox(
                width: 100,
                child: Row(
                  children: [
                    IconButton(
                      color: Colors.green,
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showForm(_listData[index]['id']),
                    ),
                    IconButton(
                      color: Colors.red,
                      icon: const Icon(Icons.delete),
                      onPressed: () =>
                          _deleteItem(_listData[index]['id']),
                    ),
                  ],
                ),
              )),
        ),
      ),
      floatingActionButton: Container(
        padding: const EdgeInsets.only(right: 150),
        child: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () => _showForm(null),
        ),
      ),
    );
  }
}