import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPageEn extends StatelessWidget {
  const AboutPageEn({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sakhr Net for Digital Systems and Marketing',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Sakhr Net is a leading Yemeni company providing integrated technical solutions with over 15 years of experience in web hosting, website design, application development, and smart programming services.\n\n'
                'At Sakhr Net, we are committed to delivering professional, high-quality services that meet the needs of businesses and individuals. We keep up with continuous technological advancements to create practical and effective solutions.\n\n'
                'Our services include:\n\n'
                '    • Secure and fast website hosting\n'
                '    • Website and application design and development\n'
                '    • Custom software solutions for businesses\n'
                '    • Digital marketing and campaign management\n'
                '    • Technical support and consulting\n\n'
                'We believe that our clients\' success is our success, and we strive to build long-term relationships based on trust, quality, and innovation.\n\n',
                style: TextStyle(fontSize: 16),
              ),
              const Text(
                'Address:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Republic of Yemen - Sana\'a, Sakhr Street - In front of Al-Israa School\n'
                '772669888 | 735350503\n'
                '775543337 | 774040720\n'
                'info@sakhrnet.com | support@sakhr.cyou\n'
                'Website: sakhrnet.com\n',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              const Text(
                'Connect with us on social media:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.facebook, color: Colors.blue),
                    onPressed: () async {
                      const url = 'https://www.facebook.com/sakhrnet';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.link, color: Colors.blueGrey),
                    onPressed: () async {
                      const url = 'https://x.com/sakhrnet1';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.alternate_email,
                        color: Colors.lightBlue),
                    onPressed: () async {
                      const url = 'https://web.sakhr.cyou';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.video_library, color: Colors.red),
                    onPressed: () async {
                      const url = 'https://www.youtube.com/c/sakhrnet/featured';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url),
                            mode: LaunchMode.externalApplication);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.code, color: Colors.black),
                    onPressed: () {
                      // TODO: Add GitHub link
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the page
                  },
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
