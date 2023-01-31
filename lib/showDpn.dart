import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sleek_button/sleek_button.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:arush/successpage/success.dart';
import 'db_helper.dart';


class ShowDpn extends StatefulWidget {
  @override
  _ShowDpn createState() => _ShowDpn();
}

class _ShowDpn extends State<ShowDpn> {
  final db = RapidA();
  List loadIdList;
  ScrollController scrollController;
  bool _absorb = true;
  Color btnColor = Colors.grey;

  @override
  void initState() {
    scrollController=ScrollController();
    scrollController.addListener(() {
      FocusScope.of(context).unfocus();
      // _search.clear();
      if (scrollController.position.atEdge) {
        if (scrollController.position.pixels != 0) {
          setState(() {
            btnColor = Colors.deepOrange;
            _absorb = false;
          });
        }
      }
    });
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
  }
  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    return true;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        elevation: 0.1,
        leading: IconButton(
          icon: Icon(CupertinoIcons.left_chevron, color: Colors.black54,size: 20,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
        title: Text("Privacy Notice",style: GoogleFonts.openSans(color:Colors.black54,fontWeight: FontWeight.bold,fontSize: 18.0),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child:Scrollbar(
              child: ListView(
                controller: scrollController,
                shrinkWrap: true,
                children: [

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 10.0),
                    child:Text("Effective: March 13, 2020",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16, color: Colors.black54),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0),
                      child:Text("SCOPE OF THIS NOTICE",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 5.0, 0.0, 5.0),
                    child:Text("Please read this privacy notice (“Notice”) carefully to understand our policies and practices regarding your Personal Data and how we will treat it. This Notice applies to it.This Notice applies to individuals who interact with ALTURUSH services as customers, vendors/suppliers, partners (riders/drivers and merchant partners), contractors and service provider (“you”). This Notice also explains how your Personal Data are collected, used, and disclosed. It also tells you how you can access and update your Personal Data and make certain choices about how your Personal Data are used.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child:Text("This Notice covers both our online and offline data collection activities, including Personal Data that We collect through our various channels such as websites, apps, third party social networks, Consumer Engagement Service, points of sale and events. Please note that We might aggregate personal data from different sources (website, offline event).",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Alturas Supermarket Corporation and Marcela Farms Inc. collectively known as Alturas Group of Companies (AGC), its respective subsidiaries, affiliates, associated companies and jointly controlled entities are committed to protecting your right to privacy. We ensure that our activities involving the collection and/or use of personal data are performed in accordance with the Data Privacy Act of 2012 (“the Act”), its Implementing Rules and Regulations (“IRR”), and other relevant policies, including issuances of the National Privacy Commission.",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("ALTURUSH is a registered brand name and food delivery support of Alturas Group of Companies.",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("1.SOURCES OF PERSONAL DATA",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("This Notice applies to Personal Data that We collect from or about you, through the methods described below and their corresponding sources.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("“Personal Data” is any information which can be used to identify you or form which you are identifiable. This includes but is not limited to you name, nationality, telephone number, bank and credit card details, personal interests, email address, you image, government-issued identification numbers, biometric data, race, date of birth, marital status, religion, health information, vehicle and insurance information, employment information and financial information.",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("ALTURUSH websites. Consumer-directed websites operated by or for ALTURUSH, including sites that We operate under our own domains/URLs and mini-sites that We run on third party social networks such as Facebook (“Websites”).",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("ALTURUSH mobile sites/apps. Consumer-directed mobile sites or applications operated by or for ALTURUSH, such as smartphone apps.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("E-mail, text and other electronic messages. Interactions with electronic communications between you and ALTURUSH.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Offline registration forms. Printed or digital registration and similar forms that We collect via, for example, postal mail, in-store demos, contests, sampling activities, and other promotions, or events.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Advertising interactions. Interactions with our advertisements (e.g., if you interact with on one of our ads on a third party website, we may receive information about that interaction).",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Data from other sources. Third party social networks (e.g. such as Facebook, Google), market research (if feedback not provided on an anonymous basis), third party data aggregators, ALTURUSH promotional partners, public sources and data received when we acquire other companies.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("2.PERSONAL DATA THAT WE COLLECT ABOUT YOU AND HOW WE COLLECT IT",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Depending on how you interact with ALTURUSH (online, offline, over the phone, etc.), We collect various types of information from you, as described below.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Summary of Sources of Data:",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("a. Personal Contact Information",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("b. Account Login information",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("c. Demographic information & interests",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("d. Information from computer / mobile device",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("e. Websites / communication usage information",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("f. Market research & consumer feedback",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("g. Consumer-generated content",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("h. Third party social network information",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("i. Payment and Financial information",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("j. Sensitive Personal Data (Prior Express Consent)",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Personal contact information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("This includes any information you provide to Us that would allow Us to contact you, such as your name, postal address, e-mail address, social network details, or phone number.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Account login information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Any information that is required to give you access to your specific account profile. Examples include your login ID/email address, screen name, password in unrecoverable form, and/or security question and answer.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Demographic information & interests",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Any information that describes your demographic or behavioral characteristics. Examples include your year of birth, age range, gender, geographic location (e.g. postcode/zip code), favorite products, hobbies and interests, and household or lifestyle information.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Information from computer/mobile device",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Any information about the computer system or other technological device that you use to access one of our Websites or apps, such as the Internet protocol (IP) address used to connect your computer or device to the Internet, operating system type, and web browser type and version. If you access the ALTURUSH website or app via a mobile device such as a smartphone, the collected information will also include, where permitted, your phone’s unique device ID, advertising ID, geo-location, and other similar mobile device data.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Websites/communication usage information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("As you navigate through and interact with our Websites or newsletters, We use automatic data collection technologies to collect certain information about your actions. This includes information such as which links you click on, which pages or content you view and for how long, and other similar information and statistics about your interactions, such as content response times, download errors and length of visits to certain pages. This information is captured using automated technologies such as cookies and web beacons, and is also collected through the use of third party tracking for analytics and advertising purposes. You have the right to object to the use of such technologies; for further details, please see Section 3.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Market research & consumer feedback",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Any information that you voluntarily share with Us about your experience of using our products and services.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Consumer-generated content",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Any content that you create and then share with Us on third party social networks or by uploading it to one of our Websites or apps, including the use of third party social network apps such as Facebook. Examples include photos, videos, personal stories, or other similar media or content. Where permitted, We collect and publish consumer-generated content in connection with a variety of activities, including contests and other promotions, website community features, consumer engagement, and third party social networking.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Third party social network information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Any information that you share publicly on a third party social network or information that is part of your profile on a third party social network (such as Facebook) and that you allow the third party social network to share with Us. Examples include your basic account information (e.g. name, email address, gender, birthday, current city, profile picture, user ID, list of friends, etc.) and any other additional information or activities that you permit the third party social network to share. We receive your third party social network profile information (or parts of it) every time you download or interact with ALTURUSH web application on a third party social network such as Facebook, every time you use a social networking feature that is integrated within ALTURUSH site (such as Facebook Connect) or every time you interact with Us through a third party social network. To learn more about how your information from a third party social network is obtained by ALTURUSH, or to opt-out of sharing such social network information, please visit the website of the relevant third party social network.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Payment and Financial information",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Any information that We need in order to fulfill an order, or that you use to make a purchase, such as your debit or credit card details (cardholder name, card number, expiration date, etc.) or other forms of payment (if such are made available). In any case, We or our payment processing provider(s) handle payment and financial information in a manner compliant with applicable laws, regulations and security standards.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Sensitive Personal Data",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Some of the Personal Data that we collect may be sensitive in nature. Sensitive Personal Information is defined by the Data Privacy Act of 2012 as referring to personal information (1) About an individual’s race, ethnic origin, marital status, age, color, and religious, philosophical or political affiliations; or (2) About an individual’s health, education, genetic or sexual life of a person, or to any proceeding for any offense committed or alleged to have been committed by such individual, the disposal of such proceedings, or the sentence of any court in such proceedings.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 40.0, 0.0, 5.0),
                    child:Text("Thus, where it becomes necessary to collect and process your sensitive personal information as defined above, We rely on your prior express consent and/or in strict compliance with applicable laws.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("3.COOKIES/SIMILAR TECHNOLOGIES, LOG FILES AND WEB BEACONS",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Cookies/Similar Technologies",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Please see our Cookie Notice to learn how you can manage your cookie settings and for detailed information on the cookies We use and the purposes for which We use them.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Log Files",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("We collect information in the form of log files that record website activity and gather statistics about your browsing habits. These entries are generated automatically, and help Us to troubleshoot errors, improve performance and maintain the security of our Websites.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Web Beacons",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Web beacons (also known as “web bugs”) are small strings of code that deliver a graphic image on a web page or in an email for the purpose of transferring data back to Us. The information collected via web beacons will include information such as IP address, as well as information about how you respond to an email campaign (e.g. at what time the email was opened, which links you click on in the email, etc.). We will use web beacons on our Websites or include them in e-mails that We send to you. We use web beacon information for a variety of purposes, including but not limited to, site traffic reporting, unique visitor counts, advertising, email auditing and reporting, and personalization.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("4. USES MADE OF YOUR PERSONAL DATA",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("The following paragraphs describe the various purposes for which We collect and use your Personal Data, and the different types of Personal Data that are collected for each purpose. Please note that not all of the uses below will be relevant to every individual.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("What We use your Personal Data for",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Consumer service",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("We use your Personal Data for consumer service purposes, including responding to your enquiries. This typically requires the use of certain personal contact information and information regarding the reason for your inquiry (e.g. order status, technical issue, product question/complaint, general question, etc.). Where you have provided your prior consent, your personal data may also be used to provide you with services that are personalized to you.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Our reasons",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Fulfilling contractual obligations",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Legal obligations",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Our legitimate interests",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Our legitimate interests",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Monitoring and improving products and services and developing new ones",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Being more efficient",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Respond to questions, comments, and feedbacks",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Contests, marketing and other promotions",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("With your consent (where required), We use your Personal Data to provide you with information about goods or services (e.g. marketing communications or campaigns or promotions). This can be done through various means such as email, ads, SMS, phone calls and postal mailings to the extent permitted by applicable laws. Some of our campaigns and promotions are run on third party websites and/or social networks. This use of your Personal Data is voluntary, which means that you can oppose (or withdraw your consent) to the processing of your Personal Data for this purposes. For more information about our contests and other promotions, please see the official rules or details posted with each contest/promotion.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*With your consent (where required)",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Fulfilling contractual obligations",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Our legitimate interests",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Working out which of our products and services may interest you and telling you about them",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Defining types of consumers for new products or services",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Third party social networks",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text(" We use your Personal Data when you interact with third party social networking features, such as “Like” functions, to serve you with advertisements and engage with you on third party social networks. You can learn more about how these features work, the profile data that We obtain about you, and find out how to opt out by reviewing the privacy notices of the relevant third party social networks.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*With your consent (where required) Our legitimate interests",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Our legitimate interests",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Working out which of our products and services may interest you and telling you about them",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Defining types of consumers for new products or services",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Personalization (offline and online)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("With your consent (where required), We use your Personal Data (i) to analyze your preferences and habits, (ii) to anticipate your needs based on our analysis of your profile, (iii) to improve and personalize your experience on our Websites and apps; (iv) to ensure that content from our Websites/apps is optimized for you and for your computer or device; (v) to provide you with targeted advertising and content, and (vi) to allow you to participate in interactive features, when you choose to do so. For example, We remember your login ID/email address or screen name so that you can quickly login the next time you visit our site or so that you can easily retrieve the items you previously placed in your shopping cart. Based on this type of information, and with your consent (where required), We also show you specific ALTURUSH content or promotions that are tailored to your interests. The use of your Personal Data is voluntary, which means that you can oppose the processing of your Personal Data for this purpose.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Order fulfilment",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("We use your Personal Data to process and ship your orders, inform you about the status of your orders, correct addresses and conduct identity verification and other fraud detection activities. This involves the use of certain Personal Data and payment information.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Fulfilling contractual obligations",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*With your consent (where required)",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Legal obligations",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Our legitimate interests",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Improving and developing new products and services",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Being more efficient",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Protect our systems, networks and staff",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Compliance with legal obligations",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Testing, analyzing and product development",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Understand and analyze your needs and preferences",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Improve and enhance the safety and security of our services",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("*Develop new features, product and services",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 50.0, 0.0, 5.0),
                    child:Text("Our legitimate purpose: Investigate and resolve claims or disputes or as allowed or required by applicable law.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 50.0, 0.0, 5.0),
                    child:Text("5. DISCLOSURE OF YOUR PERSONAL DATA",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child:Text("We share your Personal Data with the following types of third party organizations:",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Service providers",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("These are external companies that We use to help Us run our business (including but not limited to order fulfilment, payment processing, fraud detection and identity verification, website operation, market research companies, support services, promotions, advertising providers, website development, data analysis, CRC, etc.). Service providers, and their selected staff, are only allowed to access and use your Personal Data on Our behalf for the specific tasks that they have been requested to carry out, based on our instructions, and are required to keep your Personal Data confidential and secure",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("6. RETENTION OF YOUR PERSONAL DATA",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("In accordance with applicable laws, We will use your Personal Data for as long as necessary to satisfy the purposes for which your Personal Data was collected or to comply with applicable legal requirements. Personal data used to provide you with a personalized experience will be kept for a duration permitted by applicable laws.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("7. DISCLOSURE, STORAGE AND/OR TRANSFER OF YOUR PERSONAL DATA",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("We take reasonable, legal, organizational, and technical measures (described below) to keep your Personal Data confidential and secure.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("People who can access your Personal Data",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Your Personal Data will be processed by our authorized staff or agents, on a need to know basis, depending on the specific purposes for which your Personal Data have been collected (e.g. our staff in charge of consumer care matters will have access to your consumer record).",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Measures taken in operating environments",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("We store your Personal Data in operating environments that use reasonable security measures to prevent unauthorized access. We follow reasonable standards to protect Personal Data. The transmission of information via the Internet is, unfortunately, not completely secure and although We will do our best to protect your Personal Data, We cannot guarantee the security of the data during transmission through our Websites/apps.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Measures We expect you to take",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text(" It is important that you also play a role in keeping your Personal Data safe and secure. When signing up for an online account, please be sure to choose an account password that would be difficult for others to guess and never reveal your password to anyone else. You are responsible for keeping this password confidential and for any use of your account. If you use a shared or public computer, never choose to have your login ID/email address or password remembered and make sure to log out of your account every time you leave the computer. You should also make use of any privacy settings or controls We provide you in our Website/app.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("8. YOUR RIGHTS",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Access to Personal Data",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("You have the right to access, review and request a physical or electronic copy of information held about you. You also have the right to request information on the source of your Personal Data.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 30.0, 0.0, 5.0),
                    child:Text("These rights can be exercised by sending Us an e-mail, attaching a copy of your ID or equivalent details, where requested by Us and permitted by law. If the request is submitted by a person other than you, without providing evidence that the request is legitimately made on your behalf, the request will be rejected. Please note that any identification information provided to Us will only be processed in accordance with, and to the extent permitted by applicable laws.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("Additional rights (e.g. modification, deletion of Personal Data)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Where provided by law, you can (i) request deletion, the portability, correction or revision of your Personal Data; (ii) limit the use and disclosure of your Personal Data; (iii) revoke consent to any of our data processing activities; and (iv) object to the processing of your Personal Data, including the right to lodge a complaint with the National Privacy Commission.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 30.0, 0.0, 5.0),
                    child:Text("Please note that, in certain circumstances, We will not be able to delete your Personal Data without also deleting your user account. We may be required to retain some of your Personal Data after you have requested deletion, to satisfy our legal or contractual rights and/or obligations. We may also be permitted by applicable laws to retain some of your Personal Data to satisfy our business needs. Where available, our Websites have a dedicated feature through which you can review and edit the Personal Data that you have provided. Please note that We require our registered consumers to verify their identity (e.g. login ID/email address, password) before they can access or make changes to their account information. This helps prevent unauthorized access to your account. We hope that We can satisfy queries you may have about the way we process your Personal Data. However, if you have unresolved concerns you also have the right to complain to competent data protection authorities.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("9. CHANGES TO THIS NOTICE",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("If We change the way We handle your Personal Data, We will update this Notice. We reserve the right to make changes to our practices and this Notice at any time, please check back frequently to see any updates or changes to our Notice.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 10.0, 0.0, 5.0),
                    child:Text("10.DATA CONTROLLERS & CONTACT",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("To ask questions or make comments on this Notice and our privacy practices or to make a complaint about our compliance with applicable privacy laws, you may reach us through our Contact Us page.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child:Text("You can also contact our Data Protection contact via email at: dpo@alturasbohol.com.",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child:Text("We will acknowledge and investigate any complaint about the way we manage Personal Data (including a complaint that we have breached your rights under applicable privacy laws).",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 20.0, 0.0, 5.0),
                    child:Text("Data Privacy Officer:",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("dpo@alturasbohol.com",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("3F AGC Corporate Center",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("Dao, Dampas, Tagbilaran City, Bohol",style: TextStyle(fontSize: 17,),),
                  ),

                  Padding(
                    padding:EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                    child:Text("(038) 501-3000, local 1120, (038) 501-3015",style: TextStyle(fontSize: 17,),),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(30.0, 10.0, 30.0, 10.0),
            child: AbsorbPointer(
              absorbing: _absorb,
              child: SleekButton(
                onTap: () {
                  // return null;
                  // Navigator.of(context).pop();
                  Navigator.of(context).push(success());
                },
                style: SleekButtonStyle.flat(
                  color:btnColor,
                  inverted: false,
                  rounded: true,
                  size: SleekButtonSize.big,
                  context: context,
                ),
                child: Center(
                  child: Text("Yes, I agree to the terms and conditions",
                    style: GoogleFonts.openSans(fontStyle: FontStyle.normal, fontSize: 14.0),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Route success() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => Success(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.decelerate;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

