import 'dart:io';
import 'package:flutter/material.dart';
import 'package:unihub/backend/asset_backend.dart';
import 'package:unihub/backend/complaint_backend.dart';
import 'package:unihub/backend/room_backend.dart';
import 'package:unihub/other/successful_page.dart';
import 'package:unihub/pages/Complaint/camere.dart';
import 'package:unihub/pages/Complaint/user_view_all_complaint.dart';
import 'package:unihub/pages/Complaint/view_complaint_page.dart';
import 'package:unihub/pages/main/scan_page.dart';
import 'package:unihub/theme/custom/app_decoration.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:image_picker/image_picker.dart';

class SubmitComplaintPage extends StatefulWidget {
  const SubmitComplaintPage({super.key});

  @override
  State<SubmitComplaintPage> createState() => _ComplaintPageState();
}

class _ComplaintPageState extends State<SubmitComplaintPage> {
  // Form fields

  // Dropdown options
  final List<String> usages = [
    'broken asset',
    'malfunctioning device',
    'power outages',
    'dirty room',
  ];

  String? usage;
  DateTime date = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 17, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 20, minute: 0);
  String formatDate(DateTime date) =>
      '${date.day} ${_monthName(date.month)} ${date.year}';

  final TextEditingController codeController = TextEditingController();
  final TextEditingController desController = TextEditingController();
  File? _imageFile;
  String selectedVenue = '';
  List<Map<String, dynamic>> venues = [];

  bool _codehasError = false;
  bool _venueEmpty = false;
  bool _desEmpty = false;
  bool _imageEmpty = false;

  @override
  void initState() {
    super.initState();
    usage = usages[0];
    loadVenues();
  }

  @override
  void dispose() {
    codeController.dispose();
    desController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.cancel),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Cancel", style: Theme.of(context).textTheme.titleSmall),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "report an issue",
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ),
              const SizedBox(height: 32),

              // Usage Dropdown
              Text(
                'WHAT IS THE USAGE?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        value: usage,
                        items:
                            usages.map((u) {
                              return DropdownMenuItem<String>(
                                value: u,
                                child: Text(
                                  u,
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                              );
                            }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _codehasError = false;
                            _venueEmpty = false;
                            _desEmpty = false;
                            _imageEmpty = false;
                            usage = val;
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 60,
                          width: constraints.maxWidth,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: AppDecorations.cardDecoration(context),
                        ),
                        dropdownStyleData: DropdownStyleData(
                          maxHeight: 200,
                          width: constraints.maxWidth,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context).colorScheme.shadow,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          elevation: 4,
                          offset: const Offset(0, 4),
                        ),
                        menuItemStyleData: MenuItemStyleData(
                          overlayColor: WidgetStateProperty.resolveWith<
                            Color?
                          >((Set<WidgetState> states) {
                            if (states.contains(WidgetState.hovered)) {
                              return Colors.black.withValues(
                                alpha: 0.1,
                              ); // Highlight hovered item background
                            }
                            return null; // Default background for other states
                          }),
                        ),
                        iconStyleData: IconStyleData(
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Location
              if (usage == 'power outages' || usage == 'dirty room')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 18),
                    Text(
                      'WHERE IS IT?',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'Venue',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _showRoomSelectionDialog(context);
                              setState(() {
                                _venueEmpty = false;
                              });
                            },

                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 20,
                              ),
                              decoration: AppDecorations.cardDecoration(
                                context,
                              ).copyWith(
                                color:
                                    _venueEmpty
                                        ? Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.red[100]
                                            : Theme.of(
                                              context,
                                            ).colorScheme.primary
                                        : Theme.of(context).colorScheme.primary,
                                border: Border.all(
                                  color:
                                      _venueEmpty
                                          ? Colors.red.withAlpha(100)
                                          : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedVenue.isNotEmpty
                                          ? venues.firstWhere(
                                            (venue) =>
                                                venue['name'] == selectedVenue,
                                          )['name']!
                                          : 'Select a room...',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelMedium?.copyWith(
                                        color:
                                            selectedVenue.isEmpty
                                                ? _venueEmpty
                                                    ? Colors.red[300]
                                                    : Colors.grey
                                                : Theme.of(
                                                  context,
                                                ).textTheme.labelMedium?.color,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.search),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_venueEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 3, left: 110),
                        child: Text(
                          'Please select a venue',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontFamily: "Nura",
                          ),
                        ),
                      ),
                  ],
                ),
              const SizedBox(height: 28),

              // Scan Barcode
              if (usage == 'broken asset' || usage == 'malfunctioning device')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usage == 'broken asset'
                          ? 'enter or SCAN THE ASSET BARCODE'
                          : 'enter or SCAN THE device barcode',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Barcode TextField
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 1,
                              horizontal: 20,
                            ),
                            decoration: AppDecorations.cardDecoration(
                              context,
                            ).copyWith(
                              color:
                                  _codehasError
                                      ? Theme.of(context).brightness ==
                                              Brightness.light
                                          ? Colors.red[100]
                                          : Theme.of(
                                            context,
                                          ).colorScheme.primary
                                      : Theme.of(context).colorScheme.primary,
                              border: Border.all(
                                color:
                                    _codehasError
                                        ? Colors.red.withAlpha(100)
                                        : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: TextField(
                              controller: codeController,
                              onChanged: (_) {
                                validateCode();
                              },
                              cursorColor:
                                  Theme.of(context).colorScheme.secondary,
                              //controller: barcodeController,
                              style: Theme.of(context).textTheme.labelMedium,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText:
                                    usage == 'broken asset'
                                        ? 'asset code...'
                                        : 'device code...',
                                hintStyle: Theme.of(
                                  context,
                                ).textTheme.labelMedium?.copyWith(
                                  color:
                                      _codehasError
                                          ? Colors.red[300]
                                          : Colors.grey,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Scan Button
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              final codeResult = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CameraPage(
                                        mode: ValueNotifier(ScanMode.barcode),
                                      ),
                                ),
                              );
                              if (codeResult != null) {
                                codeController.text =
                                    '${codeResult['code'].replaceAll('br', '').trim()}';
                                // You can use setState here to update your UI
                              }
                              validateCode();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              "SCAN",
                              style: Theme.of(context).textTheme.displayMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_codehasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 3, left: 5),
                        child: Text(
                          validateEmpthy(codeController)
                              ? 'Please enter a code or scan it.'
                              : 'Invalid code. Please re-enter.',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontFamily: "Nura",
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                  ],
                ),

              // Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DESCRIPTION',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 100,
                    decoration: AppDecorations.cardDecoration(context).copyWith(
                      color:
                          _desEmpty
                              ? Theme.of(context).brightness == Brightness.light
                                  ? Colors.red[100]
                                  : Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primary,
                      border: Border.all(
                        color:
                            _desEmpty
                                ? Colors.red.withAlpha(100)
                                : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: TextField(
                      enableInteractiveSelection: true,
                      controller: desController,
                      onChanged: (val) {
                        validateDes();
                      },
                      cursorColor: Theme.of(context).colorScheme.secondary,
                      style: Theme.of(context).textTheme.bodySmall,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'WRITE SOMETHING...',
                        hintStyle: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 10,
                          fontFamily: 'Nura',
                          color: _desEmpty ? Colors.red[300] : Colors.grey,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  if (_desEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3, left: 5),
                      child: Text(
                        'Please describe the issues',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontFamily: "Nura",
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 28),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attachment',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      width: double.infinity,
                      decoration: AppDecorations.cardDecoration(
                        context,
                      ).copyWith(
                        color:
                            _imageEmpty
                                ? Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Colors.red[100]
                                    : Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary,
                        border: Border.all(
                          color:
                              _imageEmpty
                                  ? Colors.red.withAlpha(100)
                                  : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child:
                          _imageFile == null
                              ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_upload_outlined,
                                    size: 32,
                                    color:
                                        _imageEmpty
                                            ? Colors.red[300]
                                            : Colors.grey,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "UPLOAD AN IMAGE",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                      fontFamily: 'Nura',
                                      color:
                                          _imageEmpty
                                              ? Colors.red[300]
                                              : Colors.grey,
                                    ),
                                  ),
                                ],
                              )
                              : Image.file(_imageFile!, fit: BoxFit.cover),
                    ),
                  ),
                  if (_imageEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3, left: 5),
                      child: Text(
                        'Please upload an image as a prove',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontFamily: "Nura",
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 32),

              // Book Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    dynamic assetResult;
                    dynamic roomResult;

                    if (usage == 'broken asset' ||
                        usage == 'malfunctioning device') {
                      validateCode();
                    } else {
                      validateVenue();
                    }
                    validateDes();
                    validateImage();
                    debugPrint(
                      'code: $_codehasError  venue: $_venueEmpty  des: $_desEmpty img: $_imageEmpty',
                    );
                    debugPrint(
                      'condition: ${!_codehasError && !_venueEmpty && !_desEmpty && !_imageEmpty}',
                    );
                    if (!_codehasError &&
                        !_venueEmpty &&
                        !_desEmpty &&
                        !_imageEmpty) {
                      final String type = usage ?? '';
                      if (usage == '') {
                        showErrorMessage('Usage error');
                        return;
                      }
                      if (usage == 'broken asset' ||
                          usage == 'malfunctioning device') {
                        assetResult = await searchAssetByBarcode(
                          "br ${codeController.text.trim().toLowerCase()}",
                        );
                      } else {
                        roomResult = await searchRoomByName(selectedVenue);
                      }

                      final roomID =
                          (usage == 'broken asset' ||
                                  usage == 'malfunctioning device')
                              ? assetResult['room_id']
                              : roomResult['id'];
                      print(roomID);

                      Map<String, dynamic>? complaintExist =
                          await searchExistComplaint(
                            roomID,
                            assetResult?['id'],
                            type,
                          );
                      print('complaint: $complaintExist');
                      if (complaintExist != null) {
                        showErrorMessage(
                          'This complaint already exsit. We will solve ASAP! Chilll',
                        );
                        return;
                      } else {
                        final Map<String, dynamic>
                        success = await submitComplaintToSupabase(
                          _imageFile,
                          'c4dc1d3d-b2a8-4096-bc29-f3e945b47252', //! Set user ID here --------------------------------------------------------------------------------------------------
                          roomID,
                          assetResult?['id'],
                          usage,
                          desController.text.trim().toLowerCase(),
                        );
                        if (success != {}) {
                          handleSuccessNavigation(success);
                        } else {
                          showErrorMessage(
                            'Something went wrong! Please try again.',
                          );
                        }
                      }
                    } else {
                      showErrorMessage(
                        'Please fill in all the details. Thank you!',
                      );
                    }
                  },
                  child: Text(
                    'submit issue',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Todo: Function here -----------------------------------------------------------------------------------------------------------------------------------------------------------
  String _monthName(int month) {
    const months = [
      '',
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return months[month];
  }

  void handleSuccessNavigation(Map<String, dynamic> complaintid) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder:
            (_) => SuccessfulPage(
              title: 'Complaint Submitted!',
              description:
                  "We've received your complaint and will address it shortly.",
              buttonText: 'view complaint',
              page: ViewComplaintPage(
                complaint: complaintid,
                page: UserViewAllComplaintPage(),
              ),
              //animationAsset: 'assets/success.json', // your Lottie file path
            ),
      ),
    );
  }

  void showErrorMessage(String message) {
    if (!mounted) return;
    AppDecorations.showCustomBottomSheet(context, message);
  }

  //! Image picker
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _imageEmpty = false;
    });

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileBytes = await file.length(); // size in bytes
      final fileExtension = pickedFile.path.split('.').last.toLowerCase();
      if (!mounted) return;

      // ✅ Validate file type
      if (fileExtension != 'jpg' &&
          fileExtension != 'jpeg' &&
          fileExtension != 'png') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Only JPG and PNG images are allowed.")),
        );
        return;
      }

      // ✅ Validate file size (max 50MB)
      const maxFileSize = 50 * 1024 * 1024; // 50MB in bytes
      if (fileBytes > maxFileSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image must be 50MB or smaller.")),
        );
        return;
      }

      // ✅ Valid image: update UI
      setState(() {
        _imageFile = file;
      });
    }
  }

  // Input validation ----------------------------------------------------------------------------------------------------------------------------------------------------------------
  bool validateEmpthy(TextEditingController controller) {
    final input = controller.text.trim();
    return input.isEmpty;
  }

  Future<bool> checkAssetExist(TextEditingController controller) async {
    final input = await searchAssetByBarcode(
      "br ${controller.text.trim().toLowerCase()}",
    );
    return input == null;
  }

  void validateCode() async {
    final codeError =
        validateEmpthy(codeController) || await checkAssetExist(codeController);
    setState(() {
      _codehasError = codeError;
    });
  }

  void validateVenue() {
    final error = selectedVenue.isEmpty;
    setState(() {
      _venueEmpty = error;
    });
  }

  void validateImage() {
    final error = _imageFile == null;
    setState(() {
      _imageEmpty = error;
    });
  }

  void validateDes() {
    final error = validateEmpthy(desController);
    setState(() {
      _desEmpty = error;
    });
  }

  void loadVenues() async {
    final room = await getAllRooms();
    setState(() {
      venues = room;
    });
  }

  //! Venue Filter
  void _showRoomSelectionDialog(BuildContext context) {
    String tempSearchQuery = '';
    String tempSelectedVenue = selectedVenue;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<Map<String, dynamic>> filteredVenues =
                venues.where((venue) {
                  if (tempSearchQuery.isEmpty) return true;
                  final name = venue['name']!.toString().toLowerCase();
                  final block = venue['map']['block'].toString().toLowerCase();
                  final floor = venue['map']['floor'].toString().toLowerCase();
                  final type = venue['type']!.toString().toLowerCase();
                  final query = tempSearchQuery.toLowerCase();

                  return name.startsWith(query) ||
                      block.startsWith(query) ||
                      floor.startsWith(query) ||
                      type.startsWith(query);
                }).toList();

            return Dialog(
              backgroundColor: Theme.of(context).primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  minHeight: 400,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select A Venue',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: AppDecorations.cardDecoration(context),
                      child: TextFormField(
                        style: Theme.of(context).textTheme.bodyLarge,
                        cursorColor: Theme.of(context).colorScheme.secondary,
                        decoration: InputDecoration(
                          hintStyle: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          hintText:
                              'Search by venue name, block, floor, or type...',
                          prefixIcon: const Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged:
                            (val) => setState(() => tempSearchQuery = val),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        decoration: AppDecorations.cardDecoration(context),
                        child:
                            filteredVenues.isEmpty
                                ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      'No venues found',
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  itemCount: filteredVenues.length,
                                  separatorBuilder:
                                      (context, index) =>
                                          const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final venue = filteredVenues[index];
                                    final isSelected =
                                        tempSelectedVenue == venue['name'];

                                    return ListTile(
                                      selected: isSelected,

                                      title: Text(
                                        venue['name']!,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.labelMedium,
                                      ),
                                      subtitle: Text(
                                        'Block ${venue['map']['block']} • Floor ${venue['map']['floor']} • ${venue['type']}',
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                      ),
                                      onTap: () {
                                        setState(
                                          () =>
                                              tempSelectedVenue =
                                                  venue['name']!,
                                        );
                                        this.setState(
                                          () => selectedVenue = venue['name']!,
                                        );
                                        Navigator.pop(context);
                                      },
                                    );
                                  },
                                ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
