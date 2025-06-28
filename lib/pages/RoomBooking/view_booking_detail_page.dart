import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:unihub/backend/function.dart';
import 'package:unihub/other/error_widget.dart';
import 'package:unihub/theme/custom/app_decoration.dart';

class ViewBookingDetailPage extends StatefulWidget {
  final Map<String, dynamic> booking;
  final Widget page;
  const ViewBookingDetailPage({
    super.key,
    required this.booking,
    required this.page,
  });

  @override
  State<ViewBookingDetailPage> createState() => _ViewBookingDetailPageState();
}

class _ViewBookingDetailPageState extends State<ViewBookingDetailPage> {
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    checkingconnection();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    Color boxColor;

    switch (widget.booking['Status'].toLowerCase()) {
      case 'pending':
        boxColor = Colors.orangeAccent.withAlpha(200);
        break;
      case 'approved':
        boxColor = Colors.lightGreen.withAlpha(200);
        break;
      case 'ongoing':
        boxColor = Colors.blue.withAlpha(200);
        break;
      case 'rejected':
        boxColor = Colors.redAccent.withAlpha(200);
        break;
      default:
        boxColor = Colors.grey;
    }
    return PopScope(
      canPop: false, // Prevents auto pop
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => widget.page),
        );
      },
      child: Scaffold(
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          title: Text(
            "back to my booking",
            style: Theme.of(context).textTheme.labelSmall,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(
                context,
              ).pushReplacement(MaterialPageRoute(builder: (_) => widget.page));
            },
          ),
        ),
        body:
            isConnected
                ? SingleChildScrollView(
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.all(24),
                      width: min(screenWidth * 0.9, 1000),
                      decoration: AppDecorations.cardDecoration(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      widget.booking['Purpose'],
                                      style: TextStyle(
                                        fontSize: min(screenWidth * 0.04, 32),
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    Text(
                                      widget.booking['Status'],
                                      style: TextStyle(
                                        fontSize: min(screenWidth * 0.03, 24),
                                        fontWeight: FontWeight.w700,
                                        color: boxColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: screenHeight * 0.03),
                                if (widget.booking['Start_date'] !=
                                    widget.booking['End_date'])
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat('MMM').format(
                                              DateTime.parse(
                                                widget.booking['Start_date'],
                                              ).toLocal(),
                                            ),
                                            style: TextStyle(
                                              fontSize: screenHeight * 0.02,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd').format(
                                              DateTime.parse(
                                                widget.booking['Start_date'],
                                              ).toLocal(),
                                            ),
                                            style: TextStyle(
                                              fontSize: screenHeight * 0.06,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('yyy').format(
                                              DateTime.parse(
                                                widget.booking['Start_date'],
                                              ).toLocal(),
                                            ),
                                            style: TextStyle(
                                              fontSize: screenHeight * 0.015,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: screenWidth * 0.06),
                                      Icon(Icons.arrow_right_alt_rounded, size: 48),
                                      SizedBox(width: screenWidth * 0.06),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            DateFormat('MMM').format(
                                              DateTime.parse(
                                                widget.booking['End_date'],
                                              ).toLocal(),
                                            ),
                                            style: TextStyle(
                                              fontSize: screenHeight * 0.02,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd').format(
                                              DateTime.parse(
                                                widget.booking['End_date'],
                                              ).toLocal(),
                                            ),
                                            style: TextStyle(
                                              fontSize: screenHeight * 0.06,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('yyy').format(
                                              DateTime.parse(
                                                widget.booking['End_date'],
                                              ).toLocal(),
                                            ),
                                            style: TextStyle(
                                              fontSize: screenHeight * 0.015,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                if (widget.booking['Start_date'] ==
                                    widget.booking['End_date'])
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('dd').format(
                                          DateTime.parse(
                                            widget.booking['Start_date'],
                                          ).toLocal(),
                                        ),
                                        style: TextStyle(
                                          fontSize: min(screenWidth * 0.21, 128),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Column(
                                        children: [
                                          Text(
                                            DateFormat('MMM').format(
                                              DateTime.parse(
                                                widget.booking['Start_date'],
                                              ).toLocal(),
                                            ),
                                            style: TextStyle(
                                              fontSize: min(screenWidth * 0.09, 64),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('yyy').format(
                                              DateTime.parse(
                                                widget.booking['Start_date'],
                                              ).toLocal(),
                                            ),
                                            style: TextStyle(
                                              fontSize: min(screenWidth * 0.07, 50),
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                SizedBox(height: screenHeight * 0.045),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Transform.rotate(
                                        alignment: Alignment.bottomCenter,
                                        angle: -90 * 3.1416 / 180,
                                        child: Text(
                                          'Time',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: min(screenWidth * 0.04, 32),
                                            color: boxColor,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Start From',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: min(screenWidth * 0.022, 10),
                                                    color: boxColor,
                                                  ),
                                                ),
                                                Text(
                                                  formatStringToTime(
                                                    widget.booking['start_time'],
                                                  ),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: min(screenWidth * 0.05, 36),
                                                    color: boxColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              '-',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: min(screenWidth * 0.05, 36),
                                                color: boxColor,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'end at',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: min(screenWidth * 0.022, 10),
                                                    color: boxColor,
                                                  ),
                                                ),
                                                Text(
                                                  formatStringToTime(
                                                    widget.booking['end_time'],
                                                  ),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: min(screenWidth * 0.05, 36),
                                                    color: boxColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(24),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: boxColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: screenHeight * 0.01),
                                Text(
                                  '-------  booking details  -------',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: min(screenWidth * 0.04, 32),
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenHeight * 0.01,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      lableText(
                                        context,
                                        'Booking_ID',
                                        30.5,
                                        widget.booking['Booking_ID'],
                                      ),
                                      const SizedBox(height: 10),
                                      lableText(
                                        context,
                                        'Description',
                                        20,
                                        widget.booking['Description'],
                                      ),
                                      const SizedBox(height: 30),
                                      const Text(
                                        'Location',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      lableText(
                                        context,
                                        'Room',
                                        65,
                                        widget.booking['room']['name'],
                                      ),
                                      const SizedBox(height: 10),
                                      lableText(
                                        context,
                                        'block',
                                        61.5,
                                        widget.booking['room']['map']['block'],
                                      ),
                                      const SizedBox(height: 10),
                                      lableText(
                                        context,
                                        'floor',
                                        62.5,
                                        widget.booking['room']['map']['floor'],
                                      ),
                                      const SizedBox(height: 10),
                                      lableText(
                                        context,
                                        'capacity',
                                        40,
                                        widget.booking['room']['capacity']
                                            .toString(),
                                      ),
                                      SizedBox(height: 30),
                                      const Text(
                                        'booked by',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),
                                      lableText(
                                        context,
                                        'name',
                                        67,
                                        '${widget.booking['user']['name']}',
                                      ),
                                      lableText(
                                        context,
                                        'email',
                                        65,
                                        widget.booking['user']['email'],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                : NoConnectionPage(
                  function: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ViewBookingDetailPage(
                              booking: widget.booking,
                              page: widget.page,
                            ),
                      ),
                    );
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
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Color(0xFF14141E)),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        SizedBox(width: gap),
        Text(
          ":",
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Color(0xFF14141E)),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Color(0xFF14141E)),
          ),
        ),
      ],
    );
  }

  void checkingconnection() async {
    final isConnect = await checkConnection();
    setState(() {
      isConnected = isConnect;
    });
  }
}
