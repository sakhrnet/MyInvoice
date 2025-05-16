import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPageAr extends StatelessWidget {
  const AboutPageAr({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('من نحن'),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // جعل الاتجاه من اليمين إلى اليسار
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'شركة صخر نت للأنظمة الرقمية والتسويق',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'شركة يمنية رائدة في تقديم الحلول التقنية المتكاملة، بخبرة تتجاوز 15 عامًا في مجال استضافة وتصميم مواقع الويب، تطوير التطبيقات، وتقديم خدمات البرمجة الذكية.\n\n'
                  'نلتزم في صخر نت بتقديم خدمات احترافية ذات جودة عالية تلبي احتياجات الشركات والأفراد، حيث نواكب التطورات المستمرة في عالم التقنية لنصنع حلولاً عملية وفعالة.\n\n'
                  'خدماتنا تشمل:\n\n'
                  '    • استضافة مواقع آمنة وسريعة\n'
                  '    • تصميم وتطوير المواقع الإلكترونية والتطبيقات\n'
                  '    • حلول برمجية مخصصة للشركات\n'
                  '    • التسويق الرقمي وإدارة الحملات الإعلانية\n'
                  '    • الدعم الفني والاستشارات التقنية\n\n'
                  'نحن نؤمن أن نجاح عملائنا هو نجاحنا، ونسعى لبناء علاقات طويلة الأمد قائمة على الثقة والجودة والابتكار.\n\n',
                  style: TextStyle(fontSize: 16),
                ),
                const Text(
                  'العنوان:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'الجمهورية اليمنية - صنعاء شارع صخر - أمام مدرسة الإسراء\n'
                  '772669888 | 735350503\n'
                  '775543337 | 774040720\n'
                  'info@sakhrnet.com | support@sakhr.cyou\n'
                  'موقع الكتروني : sakhrnet.com\n',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                const Text(
                  'تواصل معنا عبر وسائل التواصل الاجتماعي:',
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
                        const url =
                            'https://www.youtube.com/c/sakhrnet/featured';
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
                      Navigator.pop(context); // إغلاق الصفحة
                    },
                    child: const Text('إغلاق'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
