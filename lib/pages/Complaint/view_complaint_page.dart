import 'package:flutter/material.dart';
import 'package:unihub/backend/complaint_backend.dart';
import 'package:unihub/other/error_widget.dart';

class ViewComplaintPage extends StatelessWidget {
  final Map<String, dynamic> id;
  final Widget page;
  const ViewComplaintPage({super.key, required this.id, required this.page});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Text(
          "back to my complaint",
          style: Theme.of(context).textTheme.labelSmall,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => page),
            );
          },
        ),
      ),
      body: FutureBuilder(
        future: searchComplaintById(
          id['id'],
        ), // Todo: Change this to the code that receive from previous page
        builder: (context, snapshot) {
          print(
            'data: ${snapshot.data} error: ${snapshot.hasError} errorD: ${snapshot.error} hasData: ${snapshot.hasData}',
          );
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
                backgroundColor:
                    Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[300],
              ),
            );
          } else if (snapshot.hasError) {
            if (snapshot.data != null) {
              return NoConnectionPage(
                function: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewComplaintPage(id: id, page: page,),
                    ),
                  );
                },
              );
            }
            return Center(child: Text('error!!!!!'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No asset found'));
          } else {
            final complaintDetail = snapshot.data!;
            return Center(
              child: Text('view complaint page: ${complaintDetail['id']}'),
            );
          }
        },
      ),
    );
  }
}
