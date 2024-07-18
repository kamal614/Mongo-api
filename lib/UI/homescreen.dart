import 'package:flutter/material.dart';
import 'package:mongodb_api/connection/apis.dart';

import '../models/data_model.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<ApiResponse> futureData;
  int currentPage = 1;
  int itemsPerPage = 5;
  final TextEditingController itemsPerPageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    itemsPerPageController.text = itemsPerPage.toString();
    fetchData();
  }

  void fetchData() {
    futureData = fetchPaginatedData(limit: itemsPerPage, page: currentPage);
  }

  void nextPage() {
    setState(() {
      currentPage++;
      fetchData();
    });
  }

  void previousPage() {
    setState(() {
      currentPage--;
      fetchData();
    });
  }

  void updateItemsPerPage() {
    final int? newItemsPerPage = int.tryParse(itemsPerPageController.text);
    if (newItemsPerPage != null && newItemsPerPage > 0) {
      setState(() {
        itemsPerPage = newItemsPerPage;
        currentPage = 1; // Reset to first page when items per page change
        fetchData();
      });
    }
  }

  @override
  void dispose() {
    itemsPerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paginated Data'),
      ),
      body: Center(
        child: FutureBuilder<ApiResponse>(
          future: futureData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.data.isEmpty) {
              return const Text('No data available');
            } else {
              final data = snapshot.data!.data;
              final currentPage = snapshot.data!.currentPage;
              final totalPages = snapshot.data!.totalPages;
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(data[index]['name']),
                          subtitle: Text(data[index]['email']),
                          trailing: Text('Age: ${data[index]['age']}'),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: itemsPerPageController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Items per page',
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: updateItemsPerPage,
                          child: const Text('Set'),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: currentPage > 1 ? previousPage : null,
                        child: const Text('Previous'),
                      ),
                      const SizedBox(width: 20),
                      Text('Page $currentPage of $totalPages'),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: currentPage < totalPages ? nextPage : null,
                        child: Text('Next'),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
