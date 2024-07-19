import 'package:flutter/material.dart';
import 'package:mongodb_api/connection/apis.dart';

import '../models/data_model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<ApiResponse> futureData;
  int currentPage = 1;
  int itemsPerPage = 5;
  final TextEditingController itemsPerPageController = TextEditingController();
  final TextEditingController pageNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    itemsPerPageController.text = itemsPerPage.toString();
    pageNumberController.text = currentPage.toString();
    fetchData();
  }

  void fetchData() {
    futureData = fetchPaginatedData(limit: itemsPerPage, page: currentPage);
  }

  void nextPage() {
    setState(() {
      currentPage++;
      pageNumberController.text = currentPage.toString();
      fetchData();
    });
  }

  void previousPage() {
    setState(() {
      currentPage--;
      pageNumberController.text = currentPage.toString();
      fetchData();
    });
  }

  void updateItemsPerPage() {
    final int? newItemsPerPage = int.tryParse(itemsPerPageController.text);
    if (newItemsPerPage != null && newItemsPerPage > 0) {
      setState(() {
        itemsPerPage = newItemsPerPage;
        currentPage = 1; // Reset to first page when items per page change
        pageNumberController.text = currentPage.toString();
        fetchData();
      });
    }
  }

  void goToPage(int totalPages) {
    final int? newPage = int.tryParse(pageNumberController.text);
    if (newPage != null && newPage > 0 && newPage <= totalPages) {
      setState(() {
        currentPage = newPage;
        fetchData();
      });
    }
  }

  @override
  void dispose() {
    itemsPerPageController.dispose();
    pageNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: pageNumberController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Page number',
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => goToPage(totalPages),
                          child: const Text('Go'),
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
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: currentPage < totalPages ? nextPage : null,
                        child: const Text('Next'),
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
