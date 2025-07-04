import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MapPreviewWidget extends StatefulWidget {
  const MapPreviewWidget({Key? key}) : super(key: key);

  @override
  State<MapPreviewWidget> createState() => _MapPreviewWidgetState();
}

class _MapPreviewWidgetState extends State<MapPreviewWidget> {
  String? rawSvg;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSvg();
  }

  Future<void> loadSvg() async {
    try {
      final supabase = Supabase.instance.client;
      final response =
          await supabase
              .from('map')
              .select('img_path')
              .eq('id', '90a5bee7-e8e5-440f-90df-66e0e665bc7d')
              .single();
      final filePath = response['img_path'] as String;
      final svgResponse = await supabase.storage
          .from('image')
          .download(filePath);
      final svgRawString = String.fromCharCodes(svgResponse);
      setState(() {
        rawSvg = svgRawString;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (rawSvg == null) {
      return const Center(child: Text('Failed to load map preview'));
    }
    return SvgPicture.string(
      rawSvg!,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
