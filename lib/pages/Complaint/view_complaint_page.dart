import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unihub/backend/complaint_backend.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';

class ViewComplaintPage extends StatelessWidget {
  final Map<String, dynamic> complaint;
  final Widget page;
  const ViewComplaintPage({
    super.key,
    required this.complaint,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents auto pop
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: Text(
            "back to my complaint",
            style: Theme.of(context).textTheme.labelSmall,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(
                context,
              ).pushReplacement(MaterialPageRoute(builder: (_) => page));
            },
          ),
        ),
        body: FutureBuilder(
          future: searchComplaintById(
            complaint['id'],
          ), // Todo: Change this to the code that receive from previous page
          builder: (context, snapshot) {
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
                        builder:
                            (context) => ViewComplaintPage(
                              complaint: complaint,
                              page: page,
                            ),
                      ),
                    );
                  },
                );
              }
              return Center(child: Text('error!!!!!'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No complaint found'));
            } else {
              final complaintDetail = snapshot.data!;
              final image = complaintDetail['image_url'];
              final complaintID = complaintDetail['id'];
              final assetID = complaintDetail['asset_id'];
              final title = complaintDetail['type'];
              final desc = complaintDetail['description'];
              final status = complaintDetail['status'];
              final date = formatTimestamp(complaintDetail['receive_date']);
              final location = complaintDetail['room']['name'];
              final roomType = complaintDetail['room']['type'];
              final roomBlock = complaintDetail['room']['map']['block'];
              final roomFloor = complaintDetail['room']['map']['floor'];
              final assetCode =
                  assetID != null
                      ? complaintDetail['asset']['code']
                          .toString()
                          .replaceAll('br', '')
                          .trim()
                      : '';
              final assetName =
                  assetID != null ? complaintDetail['asset']['name'] : '';
              final assetCategory =
                  assetID != null ? complaintDetail['asset']['category'] : '';

              Color boxColor;

              switch (status.toLowerCase()) {
                case 'pending':
                  boxColor = Colors.orange;
                  break;
                case 'solved':
                  boxColor = Colors.green;
                  break;
                case 'invalid':
                  boxColor = Colors.redAccent;
                  break;
                case 'ongoing':
                  boxColor = Colors.lightBlue;
                  break;
                default:
                  boxColor = Colors.grey;
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsetsGeometry.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 80),
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.headlineMedium,
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    child: SingleChildScrollView(
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons.close_rounded,
                                                color: Colors.white,
                                              ),
                                              onPressed:
                                                  () =>
                                                      Navigator.of(context).pop(),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Color(0xFF14141E),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                                child: InteractiveViewer(
                                                  child: Image.network(
                                                    image,
                                                    fit: BoxFit.contain,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: InteractiveViewer(
                              child: Image.network(
                                image,
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.4,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: boxColor,
                                ),
                              ),
                              Container(
                                height: 6,
                                width: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            status, // your dynamic status
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: boxColor, // e.g. red, green, orange
                            ),
                          ),
                          const SizedBox(width: 10),
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Container(
                                height: 12,
                                width: 12,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: boxColor,
                                ),
                              ),
                              Container(
                                height: 6,
                                width: 6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: boxColor.withAlpha(40),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: boxColor),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Complaint Details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  lableText(
                                    context,
                                    'Complaint ID',
                                    34,
                                    complaintID,
                                  ),
                                  const SizedBox(height: 10),
                                  lableText(context, 'Date Reported', 20, date),
                                  const SizedBox(height: 10),
                                  lableText(context, 'Description', 41, desc),
                                  const SizedBox(height: 40),

                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Locate At',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      SvgPicture.asset(
                                        'asset/icon/more_page/location_more_icon.svg',
                                        height: 16,
                                        colorFilter: ColorFilter.mode(
                                          Theme.of(
                                            context,
                                          ).colorScheme.tertiary,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  lableText(context, 'room', 85, location),
                                  const SizedBox(height: 8),
                                  lableText(context, 'type', 88.5, roomType),
                                  const SizedBox(height: 8),
                                  lableText(context, 'block', 81, roomBlock),
                                  const SizedBox(height: 8),
                                  lableText(context, 'Floor', 82, roomFloor),

                                  if (assetID != null)
                                    Column(
                                      children: [
                                        const SizedBox(height: 40),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'asset info',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            SvgPicture.asset(
                                              'asset/icon/more_page/location_more_icon.svg',
                                              height: 16,
                                              colorFilter: ColorFilter.mode(
                                                Theme.of(
                                                  context,
                                                ).colorScheme.tertiary,
                                                BlendMode.srcIn,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        lableText(
                                          context,
                                          'code',
                                          88.5,
                                          assetCode,
                                        ),
                                        const SizedBox(height: 8),
                                        lableText(
                                          context,
                                          'name',
                                          85,
                                          assetName,
                                        ),
                                        const SizedBox(height: 8),
                                        lableText(
                                          context,
                                          'category',
                                          56,
                                          assetCategory,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  static Row lableText(
    BuildContext context,
    String text,
    double gap,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        SizedBox(width: gap),
        Text(":", style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(width: 20),
        Flexible(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
