import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class SuccessfulPage extends StatelessWidget {
  final String title;
  final String description;
  final String buttonText;
  final Widget page;
  //final String animationAsset;

  const SuccessfulPage({
    super.key,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.page,
    //this.animationAsset = 'assets/success.json', // default Lottie asset
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              const SizedBox(height: 24,),
              // ✅ Success Animation
              Expanded(flex: 1, child: Container(color: Colors.greenAccent)),
              //Lottie.asset(
              //  animationAsset,
              //  width: 200,
              //  repeat: false,
              //),
              const SizedBox(height: 24),

              // ✅ Title
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        description,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(height: 64),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => page),
                          );
                        },
                        child: Text(buttonText),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
