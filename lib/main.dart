import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const RCCPlannerApp());

const navy       = Color(0xFF1B3A6B);
const green      = Color(0xFF5B9E30);
const navyLight  = Color(0xFFEEF2F8);
const greenLight = Color(0xFFEEF6E6);
const borderColor = Color(0xFFDCE3EF);
const textGray   = Color(0xFF6B7A99);

// ── URL helpers ─────────────────────────────
Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
}
Future<void> _call(String phone) => _launch('tel:$phone');
Future<void> _email(String address) => _launch('mailto:$address');
Future<void> _web(String url) => _launch(url.startsWith('http') ? url : 'https://$url');

// ═══════════════════════════════════════════
// APP
// ═══════════════════════════════════════════
class RCCPlannerApp extends StatelessWidget {
  const RCCPlannerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'RCC Academic Planner',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: navy, fontFamily: 'Roboto'),
    home: const Shell(),
  );
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _i = 0;
  final _screens = const [
    DegreesScreen(),
    DiplomasScreen(),
    CertsScreen(),
    GpaScreen(),
    SapScreen(),
    AidScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _screens[_i],
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _i,
      onTap: (v) => setState(() => _i = v),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: navy,
      unselectedItemColor: textGray,
      selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontSize: 10),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Degrees'),
        BottomNavigationBarItem(icon: Icon(Icons.military_tech), label: 'Diplomas'),
        BottomNavigationBarItem(icon: Icon(Icons.workspace_premium), label: 'Certs'),
        BottomNavigationBarItem(icon: Icon(Icons.calculate), label: 'GPA'),
        BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: 'SAP'),
        BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: 'Aid'),
      ],
    ),
  );
}

// ═══════════════════════════════════════════
// DATA MODELS
// ═══════════════════════════════════════════
class Course {
  final String code, name;
  final double credits;
  final bool isElective;
  final String? note;
  const Course({required this.code, required this.name, required this.credits, this.isElective=false, this.note});
}
class Semester {
  final String label;
  final List<Course> courses;
  const Semester({required this.label, required this.courses});
}
class Program {
  final String id, name, degree, description, totalHours, category;
  final IconData icon;
  final Color color;
  final List<Semester> semesters;
  const Program({required this.id, required this.name, required this.degree,
    required this.description, required this.totalHours, required this.category,
    required this.icon, required this.color, required this.semesters});
  double get calcCredits => semesters.expand((s)=>s.courses).fold(0,(a,c)=>a+c.credits);
}

// ═══════════════════════════════════════════
// DEGREE PROGRAMS DATA
// ═══════════════════════════════════════════
final List<Program> degrees = [
  Program(id:'aa', name:'Associate in Arts', degree:'AA', totalHours:'60-61', category:'Transfer',
    description:'Transfer pathway to 4-year universities in humanities, social sciences, and liberal arts.',
    icon:Icons.menu_book, color:const Color(0xFF1565C0),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'MAT 143', name:'Quantitative Literacy', credits:3),
        Course(code:'COM 120', name:'Intro to Communication', credits:3),
        Course(code:'PSY 150', name:'General Psychology', credits:3),
        Course(code:'CIS 110', name:'Intro to Computers', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ENG 112', name:'Writing & Research in the Disciplines', credits:3),
        Course(code:'MAT 152', name:'Statistical Methods I', credits:3),
        Course(code:'HIS 111', name:'World Civilizations I', credits:3),
        Course(code:'SOC 210', name:'Introduction to Sociology', credits:3),
        Course(code:'Nat Sci', name:'Natural Science Elective', credits:4, isElective:true, note:'BIO 110, BIO 111, CHM 151, PHY 110, or approved equivalent'),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'ENG 231', name:'American Literature I', credits:3),
        Course(code:'HIS 112', name:'World Civilizations II', credits:3),
        Course(code:'PHL 215', name:'Philosophical Issues', credits:3),
        Course(code:'POL 120', name:'American Government', credits:3),
        Course(code:'Humanities', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, THE 111, or approved equivalent'),
      ]),
      Semester(label:'Semester 4 (Spring)', courses:[
        Course(code:'ENG 232', name:'American Literature II', credits:3),
        Course(code:'ECO 251', name:'Principles of Microeconomics', credits:3),
        Course(code:'Sci Lab', name:'Natural Science with Lab', credits:4, isElective:true, note:'Different science from Semester 2'),
        Course(code:'Elec 1', name:'General Elective', credits:3, isElective:true, note:'Any approved transfer-level elective'),
        Course(code:'Elec 2', name:'General Elective', credits:3, isElective:true, note:'Any approved transfer-level elective'),
      ]),
    ]),
  Program(id:'as', name:'Associate in Science', degree:'AS', totalHours:'64', category:'Transfer',
    description:'Transfer pathway emphasizing science, mathematics, and technology for STEM programs.',
    icon:Icons.science, color:const Color(0xFF2E7D32),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'MAT 171', name:'Precalculus Algebra', credits:4),
        Course(code:'BIO 111', name:'General Biology I', credits:4),
        Course(code:'CIS 110', name:'Intro to Computers', credits:3),
        Course(code:'COM 120', name:'Intro to Communication', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ENG 112', name:'Writing & Research in the Disciplines', credits:3),
        Course(code:'MAT 172', name:'Precalculus Trigonometry', credits:4),
        Course(code:'BIO 112', name:'General Biology II', credits:4),
        Course(code:'CHM 151', name:'General Chemistry I', credits:4),
        Course(code:'HIS 111', name:'World Civilizations I', credits:3),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'MAT 271', name:'Calculus I', credits:4),
        Course(code:'CHM 152', name:'General Chemistry II', credits:4),
        Course(code:'PHY 151', name:'College Physics I', credits:4),
        Course(code:'PSY 150', name:'General Psychology', credits:3),
        Course(code:'SOC 210', name:'Introduction to Sociology', credits:3),
      ]),
      Semester(label:'Semester 4 (Spring)', courses:[
        Course(code:'MAT 272', name:'Calculus II', credits:4),
        Course(code:'PHY 152', name:'College Physics II', credits:4),
        Course(code:'POL 120', name:'American Government', credits:3),
        Course(code:'STEM', name:'STEM Elective', credits:3, isElective:true, note:'Select from approved STEM transfer courses'),
        Course(code:'Hum', name:'Humanities Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHL 215, or approved equivalent'),
      ]),
    ]),
  Program(id:'aatp', name:'Associate in Arts — Teacher Prep', degree:'AATP', totalHours:'60-61', category:'Transfer',
    description:'Transfer pathway for future K-12 teachers pairing general education with early education foundations.',
    icon:Icons.school, color:const Color(0xFF6A1B9A),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'MAT 143', name:'Quantitative Literacy', credits:3),
        Course(code:'EDU 131', name:'Child, Family, and Community', credits:3),
        Course(code:'PSY 150', name:'General Psychology', credits:3),
        Course(code:'CIS 110', name:'Intro to Computers', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ENG 112', name:'Writing & Research in the Disciplines', credits:3),
        Course(code:'MAT 152', name:'Statistical Methods I', credits:3),
        Course(code:'EDU 144', name:'Child Development I', credits:3),
        Course(code:'HIS 111', name:'World Civilizations I', credits:3),
        Course(code:'COM 120', name:'Intro to Communication', credits:3),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'EDU 145', name:'Child Development II', credits:3),
        Course(code:'EDU 146', name:'Child Guidance', credits:3),
        Course(code:'PSY 241', name:'Developmental Psychology', credits:3),
        Course(code:'HIS 112', name:'World Civilizations II', credits:3),
        Course(code:'Nat Sci', name:'Natural Science Elective', credits:4, isElective:true, note:'BIO 110, CHM 151, PHY 110, or approved equivalent'),
      ]),
      Semester(label:'Semester 4 (Spring)', courses:[
        Course(code:'EDU 251', name:'Exploring Education', credits:3),
        Course(code:'POL 120', name:'American Government', credits:3),
        Course(code:'SOC 210', name:'Introduction to Sociology', credits:3),
        Course(code:'Hum', name:'Humanities Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHL 215, or approved equivalent'),
        Course(code:'Elec', name:'General Elective', credits:3, isElective:true, note:'Any approved transfer-level elective'),
      ]),
    ]),
  Program(id:'ece_c', name:'Early Childhood Ed — Career Track', degree:'AAS', totalHours:'69', category:'Education',
    description:'Prepares students for careers in childcare, Head Start, and preschool settings.',
    icon:Icons.child_care, color:const Color(0xFFE65100),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
        Course(code:'EDU 119', name:'Intro to Early Child Education', credits:4),
        Course(code:'EDU 146', name:'Child Guidance', credits:3),
        Course(code:'EDU 151', name:'Creative Activities', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'EDU 131', name:'Child, Family, and Community', credits:3),
        Course(code:'EDU 144', name:'Child Development I', credits:3),
        Course(code:'EDU 145', name:'Child Development II', credits:3),
        Course(code:'EDU 153', name:'Health, Safety and Nutrition', credits:3),
        Course(code:'ENG 112', name:'Writing/Research in the Disciplines', credits:3),
        Course(code:'MAT 143', name:'Quantitative Literacy', credits:3),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'COM 231', name:'Public Speaking', credits:3),
        Course(code:'EDU 234', name:'Infants, Toddlers, and Twos', credits:3),
        Course(code:'EDU 261', name:'Early Childhood Admin I', credits:3),
        Course(code:'EDU 262', name:'Early Childhood Admin II', credits:3),
        Course(code:'EDU 271', name:'Educational Technology', credits:3),
        Course(code:'PSY 150', name:'General Psychology', credits:3),
      ]),
      Semester(label:'Semester 4 (Spring)', courses:[
        Course(code:'EDU 221', name:'Children with Exceptionalities', credits:3),
        Course(code:'EDU 259', name:'Curriculum Planning', credits:3),
        Course(code:'EDU 280', name:'Language/Literacy Experiences', credits:3),
        Course(code:'EDU 284', name:'Early Child Capstone Practicum', credits:4),
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
      ]),
    ]),
  Program(id:'ece_tn', name:'Early Childhood Ed — Transfer Non-Licensure', degree:'AAS', totalHours:'74', category:'Education',
    description:'Transfer track for ECE-related bachelor degrees without immediate licensure.',
    icon:Icons.child_care, color:const Color(0xFF558B2F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 122', name:'College Transfer Success', credits:1),
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
        Course(code:'EDU 119', name:'Intro to Early Child Education', credits:4),
        Course(code:'EDU 146', name:'Child Guidance', credits:3),
        Course(code:'EDU 151', name:'Creative Activities', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'EDU 131', name:'Child, Family, and Community', credits:3),
        Course(code:'EDU 144', name:'Child Development I', credits:3),
        Course(code:'EDU 145', name:'Child Development II', credits:3),
        Course(code:'EDU 153', name:'Health, Safety and Nutrition', credits:3),
        Course(code:'ENG 112', name:'Writing/Research in the Disciplines', credits:3),
        Course(code:'MAT 143', name:'Quantitative Literacy', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'SOC 210', name:'Introduction to Sociology', credits:3),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'BIO 111', name:'General Biology I', credits:4),
        Course(code:'COM 231', name:'Public Speaking', credits:3),
        Course(code:'EDU 234', name:'Infants, Toddlers, and Twos', credits:3),
        Course(code:'EDU 261', name:'Early Childhood Admin I', credits:3),
        Course(code:'PSY 150', name:'General Psychology', credits:3),
      ]),
      Semester(label:'Semester 5 (Spring)', courses:[
        Course(code:'EDU 221', name:'Children with Exceptionalities', credits:3),
        Course(code:'EDU 262', name:'Early Childhood Admin II', credits:3),
        Course(code:'EDU 280', name:'Language/Literacy Experiences', credits:3),
        Course(code:'EDU 284', name:'Early Child Capstone Practicum', credits:4),
        Course(code:'Nat Sci', name:'Natural Science Elective', credits:4, isElective:true, note:'AST 151/151A, CHM 151, or PHY 110/110A'),
      ]),
    ]),
  Program(id:'accounting', name:'Accounting & Finance', degree:'AAS', totalHours:'67-68', category:'Business',
    description:'Prepares students for careers in accounting, bookkeeping, payroll, and financial services.',
    icon:Icons.account_balance_wallet, color:const Color(0xFF1B5E20),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'ACC 120', name:'Prin of Financial Accounting', credits:4),
        Course(code:'BUS 110', name:'Introduction to Business', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'MAT 143', name:'Quantitative Literacy', credits:3),
        Course(code:'CIS 110', name:'Intro to Computers', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ACC 121', name:'Prin of Managerial Accounting', credits:4),
        Course(code:'ACC 130', name:'Business Income Taxes', credits:3),
        Course(code:'BUS 115', name:'Business Law I', credits:3),
        Course(code:'ENG 112', name:'Writing/Research in the Disciplines', credits:3),
        Course(code:'ECO 251', name:'Principles of Microeconomics', credits:3),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'ACC 140', name:'Payroll Accounting', credits:2),
        Course(code:'ACC 220', name:'Intermediate Accounting I', credits:4),
        Course(code:'ACC 150', name:'Accounting Software Applications', credits:2),
        Course(code:'FIN 110', name:'Fundamentals of Finance', credits:3),
        Course(code:'COM 120', name:'Intro to Communication', credits:3),
        Course(code:'PSY 150', name:'General Psychology', credits:3),
      ]),
      Semester(label:'Semester 4 (Spring)', courses:[
        Course(code:'ACC 221', name:'Intermediate Accounting II', credits:4),
        Course(code:'ACC 269', name:'Accounting Internship', credits:2),
        Course(code:'FIN 210', name:'Financial Statement Analysis', credits:3),
        Course(code:'BUS 260', name:'Business Communications', credits:3),
        Course(code:'Elec', name:'Accounting/Business Elective', credits:3, isElective:true, note:'Select from ACC or BUS courses with advisor approval'),
      ]),
    ]),
  Program(id:'busadmin', name:'Business Administration', degree:'AAS', totalHours:'67-68', category:'Business',
    description:'Broad-based business program covering management, marketing, finance, and entrepreneurship.',
    icon:Icons.business, color:const Color(0xFF0277BD),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'ACC 111', name:'Financial Accounting', credits:3),
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
        Course(code:'BUS 110', name:'Introduction to Business', credits:3),
        Course(code:'BUS 115', name:'Business Law I', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ACC 120', name:'Prin of Financial Accounting', credits:4),
        Course(code:'BUS 137', name:'Principles of Management', credits:3),
        Course(code:'MKT 120', name:'Principles of Marketing', credits:3),
        Course(code:'CTS 130', name:'Spreadsheet', credits:3),
        Course(code:'ENG 112', name:'Writing/Research in the Disciplines', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'MKT 223', name:'Customer Experience', credits:3),
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'ACC 121', name:'Prin of Managerial Accounting', credits:4),
        Course(code:'BUS 160', name:'Data Analysis/Decision-Making', credits:3),
        Course(code:'ECO 251', name:'Prin of Microeconomics', credits:3),
        Course(code:'MAT 143', name:'Quantitative Literacy', credits:3),
        Course(code:'MKT 232', name:'Social Media Marketing', credits:3),
      ]),
      Semester(label:'Semester 5 (Spring)', courses:[
        Course(code:'BUS 153', name:'Human Resource Management', credits:3),
        Course(code:'BUS 230', name:'Small Business Management', credits:3),
        Course(code:'BUS 125', name:'Personal Finance', credits:3),
        Course(code:'BUS 270', name:'Professional Development', credits:3),
        Course(code:'ECO 252', name:'Prin of Macroeconomics', credits:3),
      ]),
    ]),
  Program(id:'medoffice', name:'Medical Office Admin — Billing & Coding', degree:'AAS', totalHours:'65-67', category:'Business',
    description:'Prepares students for medical billing, coding, and health information management careers.',
    icon:Icons.medical_services, color:const Color(0xFF880E4F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'ACC 111', name:'Financial Accounting', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'OST 141', name:'Med Office Terms I', credits:3),
        Course(code:'OST 142', name:'Med Office Terms II', credits:3),
        Course(code:'OST 148', name:'Med Insurance & Billing', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
        Course(code:'MAT 110', name:'Math Measurement & Literacy', credits:3),
        Course(code:'OST 149', name:'Medical Legal Issues', credits:3),
        Course(code:'OST 248', name:'Diagnostic Coding', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'MKT 223', name:'Customer Experience', credits:3),
        Course(code:'Soc', name:'Social/Behavioral Science Elective', credits:3, isElective:true, note:'PSY 150, SOC 210, or approved social/behavioral science'),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'CTS 130', name:'Spreadsheet', credits:3),
        Course(code:'ENG 115', name:'Oral Communication', credits:3),
        Course(code:'OST 136', name:'Word Processing', credits:3),
        Course(code:'OST 164', name:'Office Editing', credits:3),
        Course(code:'OST 247', name:'Procedure Coding', credits:3),
      ]),
      Semester(label:'Semester 5 (Spring)', courses:[
        Course(code:'BUS 125', name:'Personal Finance', credits:3),
        Course(code:'BUS 137', name:'Principles of Management', credits:3),
        Course(code:'OST 249', name:'Med Coding Certification Prep', credits:3),
        Course(code:'OST 264', name:'Medical Auditing', credits:3),
        Course(code:'OST 288', name:'Medical Office Admin Capstone', credits:3),
      ]),
    ]),
  Program(id:'hvac', name:'HVAC Technology', degree:'AAS', totalHours:'72-74', category:'Trades',
    description:'Hands-on technical program for heating, ventilation, air conditioning, and refrigeration systems.',
    icon:Icons.hvac, color:const Color(0xFFBF360C),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'AHR 110', name:'Intro to Refrigeration', credits:4),
        Course(code:'AHR 112', name:'Refrigeration Systems', credits:4),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'MAT 110', name:'Math Measurement & Literacy', credits:2),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'AHR 114', name:'Electrical for HVAC/R', credits:4),
        Course(code:'AHR 120', name:'Heating Systems', credits:4),
        Course(code:'AHR 126', name:'Air Distribution', credits:3),
        Course(code:'ENG 112', name:'Writing/Research in the Disciplines', credits:3),
        Course(code:'PHY 110', name:'Conceptual Physics', credits:3),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'AHR 211', name:'Commercial Refrigeration', credits:4),
        Course(code:'AHR 212', name:'Heat Pumps', credits:3),
        Course(code:'AHR 228', name:'Advanced Electricity for HVAC/R', credits:3),
        Course(code:'COM 120', name:'Intro to Communication', credits:3),
        Course(code:'BUS 110', name:'Introduction to Business', credits:3),
      ]),
      Semester(label:'Semester 4 (Spring)', courses:[
        Course(code:'AHR 240', name:'HVAC/R Controls', credits:3),
        Course(code:'AHR 243', name:'Commercial Systems', credits:4),
        Course(code:'AHR 269', name:'HVAC/R Internship', credits:2),
        Course(code:'PSY 150', name:'General Psychology', credits:3),
        Course(code:'Elec', name:'Technical Elective', credits:3, isElective:true, note:'AHR or ELC elective with advisor approval'),
      ]),
    ]),
  Program(id:'electrical', name:'Electrical Systems Technology', degree:'AAS', totalHours:'72-74', category:'Trades',
    description:'Covers residential, commercial, and industrial wiring, PLCs, and photovoltaic systems.',
    icon:Icons.electrical_services, color:const Color(0xFFF57F17),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'CIS 111', name:'Basic PC Literacy', credits:2),
        Course(code:'ELC 112', name:'DC/AC Electricity', credits:5),
        Course(code:'ELC 113', name:'Residential Wiring', credits:4),
        Course(code:'ELC 118', name:'National Electrical Code', credits:2),
        Course(code:'MAT 110', name:'Math Measurement & Literacy', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ELC 114', name:'Commercial Wiring', credits:4),
        Course(code:'ELC 117', name:'Motors and Controls', credits:4),
        Course(code:'ELN 229', name:'Industrial Electronics', credits:4),
        Course(code:'ENG 110', name:'Freshman Composition', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'DFT 119', name:'Basic CAD', credits:2),
        Course(code:'ELC 128', name:'Intro to Programmable Logic Controllers', credits:3),
        Course(code:'ELN 133', name:'Digital Electronics', credits:4),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'ELC 115', name:'Industrial Wiring', credits:4),
        Course(code:'ELC 228', name:'PLC Applications Project', credits:4),
        Course(code:'ELN 231', name:'Industrial Controls', credits:3),
        Course(code:'ENG 115', name:'Oral Communication', credits:3),
      ]),
      Semester(label:'Semester 5 (Spring)', courses:[
        Course(code:'ELC 121', name:'Electrical Estimating', credits:2),
        Course(code:'ATR 280', name:'Robotic Fundamentals', credits:4),
        Course(code:'ELN 275', name:'Troubleshooting', credits:2),
        Course(code:'ELC 220', name:'Photovoltaic Systems Technology', credits:3),
        Course(code:'Soc', name:'Social/Behavioral Science Elective', credits:3, isElective:true, note:'PSY 150, SOC 210, or approved equivalent'),
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
      ]),
    ]),
  Program(id:'mechatronics', name:'Mechatronics Engineering Technology', degree:'AAS', totalHours:'72', category:'Trades',
    description:'Integrates mechanical, electrical, and computer systems for automation and robotics careers.',
    icon:Icons.precision_manufacturing, color:const Color(0xFF37474F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'ATR 112', name:'Intro to Automation', credits:3),
        Course(code:'ISC 112', name:'Industrial Safety', credits:2),
        Course(code:'ELC 125', name:'Diagrams and Schematics', credits:2),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'DFT 151', name:'CAD I', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'DFT 154', name:'Introduction to Solid Modeling', credits:3),
        Course(code:'ELC 131', name:'Circuit Analysis I', credits:4),
        Course(code:'ELC 131A', name:'Circuit Analysis I Lab', credits:1),
        Course(code:'ELN 260', name:'Programmable Logic Controllers', credits:4),
        Course(code:'HYD 110', name:'Hydraulics/Pneumatics I', credits:3),
        Course(code:'MAT 171', name:'Precalculus Algebra', credits:4),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'COM 231', name:'Public Speaking', credits:3),
        Course(code:'ELC 130', name:'Advanced Motors/Controls', credits:3),
        Course(code:'BPR 115', name:'ELC/Fluid Power Diagrams', credits:2),
        Course(code:'MEC 110', name:'Intro to CAD/CAM', credits:2),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'ELC 213', name:'Instrumentation', credits:4),
        Course(code:'Hum', name:'Hum/Fine Arts Elective', credits:3, isElective:true, note:'HUM 115 recommended by program faculty'),
        Course(code:'MEC 130', name:'Mechanisms', credits:3),
        Course(code:'MEC 111', name:'Machine Processes I', credits:3),
      ]),
      Semester(label:'Semester 5 (Spring)', courses:[
        Course(code:'ATR 282', name:'Robotics and CIM', credits:4),
        Course(code:'MEC 276', name:'Capstone Design Project', credits:1),
        Course(code:'MNT 130', name:'Control Systems', credits:4),
        Course(code:'PHY 151', name:'College Physics I', credits:4),
        Course(code:'Soc', name:'Social/Behavioral Science Elective', credits:3, isElective:true, note:'PSY 118 recommended by program faculty'),
      ]),
    ]),
  Program(id:'welding', name:'Welding Technology', degree:'AAS', totalHours:'67', category:'Trades',
    description:'Covers SMAW, GMAW, GTAW welding processes, fabrication, inspection, and certification.',
    icon:Icons.construction, color:const Color(0xFF4E342E),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'ISC 112', name:'Industrial Safety', credits:2),
        Course(code:'MAT 110', name:'Math Measurement & Literacy', credits:3),
        Course(code:'WLD 110', name:'Cutting Processes', credits:2),
        Course(code:'WLD 115', name:'SMAW (Stick) Plate', credits:5),
        Course(code:'WLD 131', name:'GTAW (TIG) Plate', credits:4),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ENG 110', name:'Freshman Composition', credits:3),
        Course(code:'WLD 116', name:'SMAW (Stick) Plate/Pipe', credits:4),
        Course(code:'WLD 121', name:'GMAW (MIG) FCAW/Plate', credits:4),
        Course(code:'WLD 132', name:'GTAW (TIG) Plate/Pipe', credits:3),
        Course(code:'WLD 141', name:'Symbols & Specifications', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'COM 231', name:'Public Speaking', credits:3),
        Course(code:'WLD 231', name:'GTAW (TIG) Pipe', credits:3),
        Course(code:'WLD 261', name:'Certification Practices', credits:2),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'WLD 117', name:'Industrial SMAW', credits:3),
        Course(code:'WLD 143', name:'Welding Metallurgy', credits:2),
        Course(code:'WLD 151', name:'Fabrication I', credits:4),
      ]),
      Semester(label:'Semester 5 (Spring)', courses:[
        Course(code:'Soc', name:'Social/Behavioral Science Elective', credits:3, isElective:true, note:'PSY 150, SOC 210, or approved equivalent'),
        Course(code:'WLD 251', name:'Fabrication II', credits:3),
        Course(code:'WLD 262', name:'Inspection & Testing', credits:3),
        Course(code:'WLD 265', name:'Automated Welding/Cutting', credits:4),
      ]),
    ]),
  Program(id:'culinary', name:'Culinary Arts', degree:'AAS', totalHours:'71', category:'Culinary',
    description:'Professional culinary training covering classical cuisine, nutrition, global cuisines, and kitchen management.',
    icon:Icons.restaurant, color:const Color(0xFF6D4C41),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'CUL 110', name:'Sanitation & Safety', credits:2),
        Course(code:'CUL 110A', name:'Sanitation & Safety Lab', credits:1),
        Course(code:'CUL 140', name:'Culinary Skills I', credits:5),
        Course(code:'CUL 160', name:'Baking I', credits:3),
        Course(code:'ENG 110', name:'Freshman Composition', credits:3),
        Course(code:'MAT 110', name:'Math Measurement & Literacy', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'CUL 135', name:'Food & Beverage Service', credits:2),
        Course(code:'CUL 135A', name:'Food & Beverage Service Lab', credits:1),
        Course(code:'CUL 240', name:'Advanced Culinary Skills', credits:5),
        Course(code:'CUL 260', name:'Baking II', credits:3),
        Course(code:'CUL 283', name:'Farm-to-Table', credits:5),
        Course(code:'ENG 112', name:'Writing/Research in the Disciplines', credits:3),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'CUL 112', name:'Nutrition for Foodservice', credits:3),
        Course(code:'CUL 112A', name:'Nutrition for Foodservice Lab', credits:1),
        Course(code:'CUL 230', name:'Global Cuisines', credits:5),
        Course(code:'HRM 245', name:'Human Resource Mgmt — Hospitality', credits:3),
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'WBL 111', name:'Work Based Learning I', credits:1),
      ]),
      Semester(label:'Semester 4 (Spring)', courses:[
        Course(code:'CIS 111', name:'Basic PC Literacy', credits:2),
        Course(code:'CUL 170', name:'Garde Manger I', credits:3),
        Course(code:'CUL 250', name:'Classical Cuisine', credits:5),
        Course(code:'CUL 273', name:'Career Development', credits:1),
        Course(code:'HRM 220', name:'Cost Control — Food & Beverage', credits:3),
        Course(code:'Soc', name:'Social/Behavioral Science Elective', credits:3, isElective:true, note:'PSY 150, SOC 210, or approved equivalent'),
        Course(code:'WBL 121', name:'Work Based Learning II', credits:1),
      ]),
    ]),
  Program(id:'cosmetology', name:'Cosmetology', degree:'AAS', totalHours:'65-66', category:'Public Safety',
    description:'Prepares students for NC cosmetology licensure covering hair, skin, nails, and salon management.',
    icon:Icons.face, color:const Color(0xFFAD1457),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'COS 111', name:'Cosmetology Concepts I', credits:4),
        Course(code:'COS 112', name:'Salon I', credits:8),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'COS 113', name:'Cosmetology Concepts II', credits:4),
        Course(code:'COS 114', name:'Salon II', credits:8),
        Course(code:'ENG 110', name:'Freshman Composition', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'CIS 111', name:'Basic PC Literacy', credits:2),
        Course(code:'COS 115', name:'Cosmetology Concepts III', credits:4),
        Course(code:'COS 116', name:'Salon III', credits:4),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'COS 117', name:'Cosmetology Concepts IV', credits:2),
        Course(code:'COS 118', name:'Salon IV', credits:7),
        Course(code:'PSY 150', name:'General Psychology', credits:3),
      ]),
      Semester(label:'Semester 5 (Spring)', courses:[
        Course(code:'ENG 115', name:'Oral Communication', credits:3),
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'MAT 110', name:'Math Measurement & Literacy', credits:3),
        Course(code:'Maj Elec', name:'Major Electives (x2)', credits:6, isElective:true, note:'See advisor for approved Cosmetology major electives'),
      ]),
    ]),
  Program(id:'cjt', name:'Criminal Justice Technology', degree:'AAS', totalHours:'67-69', category:'Public Safety',
    description:'Prepares students for careers in law enforcement, corrections, and criminal justice professions.',
    icon:Icons.local_police, color:const Color(0xFF263238),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
        Course(code:'CJC 111', name:'Intro to Criminal Justice', credits:3),
        Course(code:'CJC 113', name:'Juvenile Justice', credits:3),
        Course(code:'CJC 131', name:'Criminal Law', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'CJC 112', name:'Criminology', credits:3),
        Course(code:'CJC 121', name:'Law Enforcement Operations', credits:3),
        Course(code:'CJC 132', name:'Court Procedure & Evidence', credits:3),
        Course(code:'CJC 141', name:'Corrections', credits:3),
        Course(code:'ENG 112', name:'Writing/Research in the Disciplines', credits:3),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'CJC 212', name:'Ethics & Community Relations', credits:3),
        Course(code:'CJC 221', name:'Investigative Principles', credits:4),
        Course(code:'MAT 143', name:'Quantitative Literacy', credits:3),
        Course(code:'PSY 150', name:'General Psychology', credits:3),
      ]),
      Semester(label:'Semester 4 (Spring)', courses:[
        Course(code:'CJC 225', name:'Crisis Intervention', credits:3),
        Course(code:'CJC 231', name:'Constitutional Law', credits:3),
        Course(code:'CJC 232', name:'Civil Liability', credits:3),
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'SOC 210', name:'Introduction to Sociology', credits:3),
      ]),
    ]),
  Program(id:'astp', name:'Associate in Science — Teacher Prep', degree:'ASTP', totalHours:'60-61', category:'Transfer',
    description:'Science-focused transfer pathway for future teachers. Heavy emphasis on math and natural sciences.',
    icon:Icons.biotech, color:const Color(0xFF00695C),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 122', name:'College Transfer Success', credits:1),
        Course(code:'EDU 187', name:'Teaching and Learning for All', credits:4),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'MAT 171', name:'Precalculus Algebra', credits:4),
        Course(code:'Nat Sci 1', name:'Natural Science Elective', credits:4, isElective:true, note:'BIO 111, CHM 151, PHY 151, or approved lab science'),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'EDU 250', name:'Teacher Licensure Preparation', credits:3),
        Course(code:'ENG 112', name:'Writing/Research in the Disciplines', credits:3),
        Course(code:'Hum/FA', name:'Hum/Fine Arts/Communication Elective', credits:3, isElective:true, note:'ART 111, COM 231, ENG 231, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'MAT 172', name:'Precalculus Trigonometry', credits:4),
        Course(code:'Nat Sci 2', name:'Natural Science Elective', credits:4, isElective:true, note:'Must be different from Semester 1 selection'),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'EDU 279', name:'Literacy Development and Instruction', credits:4),
        Course(code:'Gen Ed', name:'General Education Elective', credits:3, isElective:true, note:'CIS 110, HIS 111/112, PSY 150, SOC 210, or approved Gen Ed'),
        Course(code:'Nat Sci 3', name:'Natural Science Elective', credits:4, isElective:true, note:'Must be different from prior selections'),
        Course(code:'SOC 225', name:'Social Diversity', credits:3),
      ]),
      Semester(label:'Semester 4 (Spring)', courses:[
        Course(code:'EDU 216', name:'Foundations of Education', credits:3),
        Course(code:'Hum/FA 2', name:'Hum/Fine Arts/Communication Elective', credits:3, isElective:true, note:'ART 111, COM 231, ENG 231, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'Nat Sci 4', name:'Natural Science Elective', credits:4, isElective:true, note:'Must be different from prior selections'),
        Course(code:'Soc/Beh', name:'Social/Behavioral Science Elective', credits:3, isElective:true, note:'ECO 251/252, HIS 111/112, POL 120, PSY 150, SOC 210'),
      ]),
    ]),
  Program(id:'ece_tl', name:'Early Childhood Ed — Transfer Licensure', degree:'AAS', totalHours:'74', category:'Education',
    description:'Transfer track for students pursuing teacher licensure. Includes biology and additional science requirements.',
    icon:Icons.child_care, color:const Color(0xFFAD1457),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 122', name:'College Transfer Success', credits:1),
        Course(code:'EDU 119', name:'Intro to Early Child Education', credits:4),
        Course(code:'EDU 146', name:'Child Guidance', credits:3),
        Course(code:'EDU 151', name:'Creative Activities', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'MAT 143', name:'Quantitative Literacy', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'EDU 131', name:'Child, Family, and Community', credits:3),
        Course(code:'EDU 144', name:'Child Development I', credits:3),
        Course(code:'EDU 145', name:'Child Development II', credits:3),
        Course(code:'EDU 153', name:'Health, Safety and Nutrition', credits:3),
        Course(code:'EDU 250', name:'Teacher Licensure Preparation', credits:3),
        Course(code:'ENG 112', name:'Writing/Research in the Disciplines', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'SOC 210', name:'Introduction to Sociology', credits:3),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'BIO 111', name:'General Biology I', credits:4),
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
        Course(code:'COM 231', name:'Public Speaking', credits:3),
        Course(code:'EDU 234', name:'Infants, Toddlers, and Twos', credits:3),
        Course(code:'PSY 150', name:'General Psychology', credits:3),
      ]),
      Semester(label:'Semester 5 (Spring)', courses:[
        Course(code:'EDU 216', name:'Foundations of Education', credits:3),
        Course(code:'EDU 221', name:'Children with Exceptionalities', credits:3),
        Course(code:'EDU 280', name:'Language/Literacy Experiences', credits:3),
        Course(code:'EDU 284', name:'Early Child Capstone Practicum', credits:4),
        Course(code:'Nat Sci', name:'Natural Science Elective', credits:4, isElective:true, note:'AST 151/151A, CHM 151, or PHY 110/110A'),
      ]),
    ]),
  Program(id:'it_ai', name:'Information Technology — Artificial Intelligence', degree:'AAS', totalHours:'68', category:'Technology',
    description:'Cutting-edge program covering AI fundamentals, programming, networking, and cybersecurity.',
    icon:Icons.smart_toy, color:const Color(0xFF4527A0),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'CCT 110', name:'Intro to Cyber Crime', credits:3),
        Course(code:'CTI 120', name:'Network & Security Foundations', credits:3),
        Course(code:'CTS 115', name:'Info Systems Business Concepts', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'CTI 110', name:'IT Foundations', credits:3),
        Course(code:'ENG 115', name:'Oral Communication', credits:3),
        Course(code:'MAT 171', name:'Precalculus Algebra', credits:4),
        Course(code:'NET 125', name:'Introduction to Networks', credits:3),
        Course(code:'CIS 115', name:'Intro to Programming & Logic', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'Soc', name:'Social/Behavioral Science Elective', credits:3, isElective:true, note:'PSY 150, SOC 210, or approved equivalent'),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'CSC 113', name:'Artificial Intelligence Fundamentals', credits:3),
        Course(code:'CSC 114', name:'Artificial Intelligence I', credits:3),
        Course(code:'CSC 134', name:'C++ Programming', credits:3),
        Course(code:'NET 126', name:'Switching and Routing', credits:3),
        Course(code:'SEC 160', name:'Security Administration I', credits:3),
      ]),
      Semester(label:'Semester 5 (Spring)', courses:[
        Course(code:'CSC 128', name:'ChatBot Programming I', credits:3),
        Course(code:'CSC 234', name:'Advanced C++ Programming', credits:3),
        Course(code:'CSC 214', name:'Artificial Intelligence II', credits:3),
        Course(code:'CTI 140', name:'Virtualization Concepts', credits:3),
        Course(code:'NET 225', name:'Enterprise Networking', credits:3),
      ]),
    ]),
  Program(id:'it_cs', name:'Information Technology — Cyber Security', degree:'AAS', totalHours:'71-73', category:'Technology',
    description:'Focuses on network security, cybersecurity administration, and network management.',
    icon:Icons.security, color:const Color(0xFF1A237E),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'CCT 110', name:'Intro to Cyber Crime', credits:3),
        Course(code:'CTI 120', name:'Network & Security Foundations', credits:3),
        Course(code:'CTS 115', name:'Info Systems Business Concepts', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'NOS 110', name:'Operating Systems Concepts', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'CTI 110', name:'IT Foundations', credits:3),
        Course(code:'ENG 115', name:'Oral Communication', credits:3),
        Course(code:'MAT 143', name:'Quantitative Literacy', credits:3),
        Course(code:'NET 125', name:'Introduction to Networks', credits:3),
        Course(code:'NOS 130', name:'Windows Single User', credits:3),
        Course(code:'SEC 110', name:'Security Concepts', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'Soc', name:'Social/Behavioral Science Elective', credits:3, isElective:true, note:'PSY 150, SOC 210, or approved equivalent'),
        Course(code:'MKT 223', name:'Customer Experience', credits:3),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'CIS 115', name:'Intro to Programming & Logic', credits:3),
        Course(code:'CTS 120', name:'Hardware/Software Support', credits:3),
        Course(code:'NOS 120', name:'Linux Single User', credits:3),
        Course(code:'NET 126', name:'Switching and Routing', credits:3),
        Course(code:'SEC 160', name:'Security Administration I', credits:3),
      ]),
      Semester(label:'Semester 5 (Spring)', courses:[
        Course(code:'CSC 134', name:'C++ Programming', credits:3),
        Course(code:'CTI 140', name:'Virtualization Concepts', credits:3),
        Course(code:'CTS 220', name:'Advanced Hardware/Software Support', credits:3),
        Course(code:'NET 225', name:'Enterprise Networking', credits:3),
        Course(code:'NOS 230', name:'Windows Admin I', credits:3),
      ]),
    ]),
  Program(id:'baking', name:'Baking and Pastry Arts', degree:'AAS', totalHours:'68', category:'Culinary',
    description:'Specialized culinary program focused on baking, pastry production, cake design, and bread artisanship.',
    icon:Icons.cake, color:const Color(0xFF795548),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'CUL 110', name:'Sanitation & Safety', credits:2),
        Course(code:'CUL 110A', name:'Sanitation & Safety Lab', credits:1),
        Course(code:'CUL 140', name:'Culinary Skills I', credits:5),
        Course(code:'CUL 160', name:'Baking I', credits:3),
        Course(code:'ENG 110', name:'Freshman Composition', credits:3),
        Course(code:'MAT 110', name:'Math Measurement & Literacy', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'CIS 111', name:'Basic PC Literacy', credits:2),
        Course(code:'CUL 135', name:'Food & Beverage Service', credits:2),
        Course(code:'CUL 135A', name:'Food & Beverage Service Lab', credits:1),
        Course(code:'CUL 240', name:'Advanced Culinary Skills', credits:5),
        Course(code:'CUL 260', name:'Baking II', credits:3),
        Course(code:'ENG 112', name:'Writing/Research in the Disciplines', credits:3),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'BPA 150', name:'Artisan and Specialty Breads', credits:4),
        Course(code:'BPA 210', name:'Cake Design & Decorating', credits:3),
        Course(code:'CUL 112', name:'Nutrition for Foodservice', credits:3),
        Course(code:'CUL 112A', name:'Nutrition for Foodservice Lab', credits:1),
        Course(code:'HRM 245', name:'Human Resource Mgmt — Hospitality', credits:3),
        Course(code:'Hum', name:'Humanities/Fine Arts Elective', credits:3, isElective:true, note:'ART 111, MUS 110, PHI 215, or approved equivalent'),
        Course(code:'WBL 111', name:'Work Based Learning I', credits:1),
      ]),
      Semester(label:'Semester 4 (Spring)', courses:[
        Course(code:'BPA 250', name:'Dessert/Bread Production', credits:5),
        Course(code:'BPA 260', name:'Pastry & Baking Marketing', credits:3),
        Course(code:'CUL 273', name:'Career Development', credits:1),
        Course(code:'HRM 220', name:'Cost Control — Food & Beverage', credits:3),
        Course(code:'Soc', name:'Social/Behavioral Science Elective', credits:3, isElective:true, note:'PSY 150, SOC 210, or approved equivalent'),
        Course(code:'WBL 121', name:'Work Based Learning II', credits:1),
      ]),
    ]),
];

// ═══════════════════════════════════════════
// DIPLOMA PROGRAMS
// ═══════════════════════════════════════════
final List<Program> diplomas = [
  Program(id:'dip_hvac', name:'Air Conditioning, Heating & Refrigeration', degree:'Diploma', totalHours:'46', category:'Trades',
    description:'Three-semester diploma covering refrigeration, electricity, heating, cooling, controls, and heat pump technology.',
    icon:Icons.hvac, color:const Color(0xFFBF360C),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'AHR 110', name:'Intro to Refrigeration', credits:5),
        Course(code:'AHR 111', name:'HVACR Electricity', credits:3),
        Course(code:'AHR 112', name:'Heating Technology', credits:4),
        Course(code:'BPR 130', name:'Print Reading/Construction', credits:3),
        Course(code:'ENG 110', name:'Freshman Composition', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'AHR 113', name:'Comfort Cooling', credits:4),
        Course(code:'AHR 133', name:'HVAC Servicing', credits:4),
        Course(code:'AHR 151', name:'HVAC Duct Systems I', credits:2),
        Course(code:'MAT 110', name:'Math Measurement & Literacy', credits:3),
        Course(code:'PSY 118', name:'Interpersonal Psychology', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'AHR 114', name:'Heat Pump Technology', credits:4),
        Course(code:'AHR 130', name:'HVAC Controls', credits:3),
        Course(code:'AHR 140', name:'All-Weather Systems', credits:2),
        Course(code:'CIS 111', name:'Basic PC Literacy', credits:2),
      ]),
    ]),
  Program(id:'dip_bookkeeping', name:'Bookkeeping', degree:'Diploma', totalHours:'38', category:'Business',
    description:'Three-semester bookkeeping diploma covering financial accounting, taxes, management, and spreadsheet applications.',
    icon:Icons.account_balance_wallet, color:const Color(0xFF1B5E20),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'ACC 111', name:'Financial Accounting', credits:3),
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'BUS 160', name:'Data Analysis/Decision-Making', credits:3),
        Course(code:'BUS 115', name:'Business Law I', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ACC 120', name:'Prin of Financial Accounting', credits:4),
        Course(code:'ACC 131', name:'Federal Income Taxes', credits:3),
        Course(code:'BUS 137', name:'Principles of Management', credits:3),
        Course(code:'BUS 270', name:'Professional Development', credits:3),
        Course(code:'ECO 251', name:'Prin of Microeconomics', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'MKT 223', name:'Customer Experience', credits:3),
        Course(code:'CTS 130', name:'Spreadsheet', credits:3),
      ]),
    ]),
  Program(id:'dip_busadmin', name:'Business Administration', degree:'Diploma', totalHours:'38', category:'Business',
    description:'Three-semester business diploma covering accounting, marketing, management, and business communications.',
    icon:Icons.business, color:const Color(0xFF0277BD),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'BUS 110', name:'Introduction to Business', credits:3),
        Course(code:'BUS 115', name:'Business Law I', credits:3),
        Course(code:'BUS 160', name:'Data Analysis/Decision-Making', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ACC 120', name:'Prin of Financial Accounting', credits:4),
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
        Course(code:'MKT 120', name:'Principles of Marketing', credits:3),
        Course(code:'ENG 112', name:'Writing/Research in the Disciplines', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'BUS 137', name:'Principles of Management', credits:3),
        Course(code:'BUS 153', name:'Human Resource Management', credits:3),
        Course(code:'MKT 223', name:'Customer Experience', credits:3),
      ]),
    ]),
  Program(id:'dip_cosmetology', name:'Cosmetology', degree:'Diploma', totalHours:'48', category:'Public Safety',
    description:'Four-semester cosmetology diploma preparing students for NC licensure.',
    icon:Icons.face, color:const Color(0xFFAD1457),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'COS 111', name:'Cosmetology Concepts I', credits:4),
        Course(code:'COS 112', name:'Salon I', credits:8),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'COS 113', name:'Cosmetology Concepts II', credits:4),
        Course(code:'COS 114', name:'Salon II', credits:8),
        Course(code:'ENG 110', name:'Freshman Composition', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'COS 115', name:'Cosmetology Concepts III', credits:4),
        Course(code:'COS 116', name:'Salon III', credits:4),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'COS 117', name:'Cosmetology Concepts IV', credits:2),
        Course(code:'COS 118', name:'Salon IV', credits:7),
        Course(code:'PSY 118', name:'Interpersonal Psychology', credits:3),
      ]),
    ]),
  Program(id:'dip_electrical', name:'Electrical Systems Technology', degree:'Diploma', totalHours:'37', category:'Trades',
    description:'Three-semester diploma covering residential, commercial, and industrial wiring and PLCs.',
    icon:Icons.electrical_services, color:const Color(0xFFF57F17),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'CIS 111', name:'Basic PC Literacy', credits:2),
        Course(code:'ELC 112', name:'DC/AC Electricity', credits:5),
        Course(code:'ELC 113', name:'Residential Wiring', credits:4),
        Course(code:'ELC 118', name:'National Electrical Code', credits:2),
        Course(code:'MAT 110', name:'Math Measurement & Literacy', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ELC 114', name:'Commercial Wiring', credits:4),
        Course(code:'ELC 117', name:'Motors and Controls', credits:4),
        Course(code:'ELN 229', name:'Industrial Electronics', credits:4),
        Course(code:'ENG 110', name:'Freshman Composition', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'DFT 119', name:'Basic CAD', credits:2),
        Course(code:'ELC 128', name:'Intro to Programmable Logic Controllers', credits:3),
      ]),
    ]),
  Program(id:'dip_it', name:'Information Technology', degree:'Diploma', totalHours:'40', category:'Technology',
    description:'Three-semester IT diploma covering cybersecurity, hardware/software, networking, and virtualization.',
    icon:Icons.computer, color:const Color(0xFF4527A0),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'CCT 110', name:'Intro to Cyber Crime', credits:3),
        Course(code:'CTS 120', name:'Hardware/Software Support', credits:3),
        Course(code:'CTS 115', name:'Info Systems Business Concepts', credits:3),
        Course(code:'CTI 120', name:'Network & Security Foundations', credits:3),
        Course(code:'NOS 110', name:'Operating Systems Concepts', credits:3),
        Course(code:'NOS 120', name:'Linux Single User', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'CTI 110', name:'IT Foundations', credits:3),
        Course(code:'CTI 140', name:'Virtualization Concepts', credits:3),
        Course(code:'CTS 220', name:'Adv Hardware/Software Support', credits:3),
        Course(code:'NET 125', name:'Introduction to Networks', credits:3),
        Course(code:'SEC 110', name:'Security Concepts', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'MAT 143', name:'Quantitative Literacy', credits:3),
      ]),
    ]),
  Program(id:'dip_mechatronics', name:'Mechatronics Engineering Technology', degree:'Diploma', totalHours:'39', category:'Trades',
    description:'Five-semester diploma covering automation, PLCs, circuit analysis, instrumentation, and physics.',
    icon:Icons.precision_manufacturing, color:const Color(0xFF37474F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ATR 112', name:'Intro to Automation', credits:3),
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'ISC 112', name:'Industrial Safety', credits:2),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'DFT 154', name:'Introduction to Solid Modeling', credits:3),
        Course(code:'ELC 131', name:'Circuit Analysis I', credits:4),
        Course(code:'ELC 131A', name:'Circuit Analysis I Lab', credits:1),
        Course(code:'ELN 260', name:'Programmable Logic Controllers', credits:4),
        Course(code:'MAT 171', name:'Precalculus Algebra', credits:4),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'COM 231', name:'Public Speaking', credits:3),
        Course(code:'BPR 115', name:'ELC/Fluid Power Diagrams', credits:2),
        Course(code:'MEC 110', name:'Intro to CAD/CAM', credits:2),
      ]),
      Semester(label:'Semester 4 (Fall)', courses:[
        Course(code:'ELC 213', name:'Instrumentation', credits:4),
      ]),
      Semester(label:'Semester 5 (Spring)', courses:[
        Course(code:'PHY 151', name:'College Physics I', credits:4),
      ]),
    ]),
  Program(id:'dip_pn', name:'Practical Nursing', degree:'Diploma', totalHours:'46', category:'Health Sciences',
    description:'Three-semester nursing diploma preparing students for the NCLEX-PN licensure exam.',
    icon:Icons.local_hospital, color:const Color(0xFF880E4F),
    semesters: const [
      Semester(label:'Semester 1 (Spring)', courses:[
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'NUR 101', name:'Practical Nursing I', credits:11),
        Course(code:'NUR 117', name:'Pharmacology', credits:2),
      ]),
      Semester(label:'Semester 2 (Summer)', courses:[
        Course(code:'BIO 169', name:'Anatomy and Physiology II', credits:4),
        Course(code:'NUR 102', name:'Practical Nursing II', credits:10),
        Course(code:'PSY 150', name:'General Psychology', credits:3),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'NUR 103', name:'Practical Nursing III', credits:9),
      ]),
    ]),
  Program(id:'dip_welding', name:'Welding Technology', degree:'Diploma', totalHours:'39', category:'Trades',
    description:'Three-semester welding diploma covering SMAW, GMAW, GTAW processes and certification.',
    icon:Icons.construction, color:const Color(0xFF4E342E),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACA 111', name:'College Student Success', credits:1),
        Course(code:'ISC 112', name:'Industrial Safety', credits:2),
        Course(code:'MAT 110', name:'Math Measurement & Literacy', credits:3),
        Course(code:'WLD 110', name:'Cutting Processes', credits:2),
        Course(code:'WLD 115', name:'SMAW (Stick) Plate', credits:5),
        Course(code:'WLD 131', name:'GTAW (TIG) Plate', credits:4),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ENG 110', name:'Freshman Composition', credits:3),
        Course(code:'WLD 116', name:'SMAW (Stick) Plate/Pipe', credits:4),
        Course(code:'WLD 121', name:'GMAW (MIG) FCAW/Plate', credits:4),
        Course(code:'WLD 132', name:'GTAW (TIG) Plate/Pipe', credits:3),
        Course(code:'WLD 141', name:'Symbols & Specifications', credits:3),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[
        Course(code:'WLD 231', name:'GTAW (TIG) Pipe', credits:3),
        Course(code:'WLD 261', name:'Certification Practices', credits:2),
      ]),
    ]),
];

// ═══════════════════════════════════════════
// CERTIFICATES DATA
// ═══════════════════════════════════════════
final List<Program> certs = [
  Program(id:'c_ahr_intro', name:'A/C, Heating & Refrigeration Intro', degree:'Certificate', totalHours:'12', category:'Trades',
    description:'Entry-level certificate covering refrigeration, electricity, and heating technology basics.',
    icon:Icons.hvac, color:const Color(0xFFBF360C),
    semesters: const [Semester(label:'Semester 1 (Fall)', courses:[
      Course(code:'AHR 110', name:'Intro to Refrigeration', credits:5),
      Course(code:'AHR 111', name:'HVACR Electricity', credits:3),
      Course(code:'AHR 112', name:'Heating Technology', credits:4),
    ])]),
  Program(id:'c_ahr_im', name:'A/C Installation and Maintenance', degree:'Certificate', totalHours:'13', category:'Trades',
    description:'Covers refrigeration, HVACR electricity, print reading, and duct systems.',
    icon:Icons.hvac, color:const Color(0xFFBF360C),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'AHR 110', name:'Intro to Refrigeration', credits:5),
        Course(code:'AHR 111', name:'HVACR Electricity', credits:3),
        Course(code:'BPR 130', name:'Print Reading/Construction', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'AHR 151', name:'HVAC Duct Systems I', credits:2),
      ]),
    ]),
  Program(id:'c_ahr_ct', name:'A/C Control Systems', degree:'Certificate', totalHours:'14', category:'Trades',
    description:'HVACR electricity, comfort cooling, servicing, and controls for advanced technicians.',
    icon:Icons.hvac, color:const Color(0xFFBF360C),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[Course(code:'AHR 111', name:'HVACR Electricity', credits:3)]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'AHR 113', name:'Comfort Cooling', credits:4),
        Course(code:'AHR 133', name:'HVAC Servicing', credits:4),
      ]),
      Semester(label:'Semester 3 (Summer)', courses:[Course(code:'AHR 130', name:'HVAC Controls', credits:3)]),
    ]),
  Program(id:'c_elec_eng1', name:'Electrical Engineering One', degree:'Certificate', totalHours:'12', category:'Trades',
    description:'Intro automation and circuit analysis certificate stacking toward Mechatronics AAS.',
    icon:Icons.electrical_services, color:const Color(0xFFF57F17),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[Course(code:'ATR 112', name:'Intro to Automation', credits:3)]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ELN 260', name:'Programmable Logic Controllers', credits:4),
        Course(code:'ELC 131', name:'Circuit Analysis I', credits:4),
        Course(code:'ELC 131A', name:'Circuit Analysis I Lab', credits:1),
      ]),
    ]),
  Program(id:'c_bookkeeping', name:'Bookkeeping', degree:'Certificate', totalHours:'14', category:'Business',
    description:'Foundational accounting, payroll, and software skills for entry-level bookkeeping roles.',
    icon:Icons.account_balance_wallet, color:const Color(0xFF1B5E20),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[Course(code:'ACC 111', name:'Financial Accounting', credits:3)]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ACC 120', name:'Prin of Financial Accounting', credits:4),
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'ACC 150', name:'Accounting Software Applications', credits:2),
        Course(code:'ACC 140', name:'Payroll Accounting', credits:2),
      ]),
    ]),
  Program(id:'c_bookkeeping_dm', name:'Bookkeeping Data Management', degree:'Certificate', totalHours:'12', category:'Business',
    description:'Combines bookkeeping fundamentals with data analysis, computing, and customer experience.',
    icon:Icons.account_balance_wallet, color:const Color(0xFF1B5E20),
    semesters: const [Semester(label:'Semester 1 (Fall)', courses:[
      Course(code:'ACC 111', name:'Financial Accounting', credits:3),
      Course(code:'BUS 160', name:'Data Analysis/Decision-Making', credits:3),
      Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
      Course(code:'MKT 223', name:'Customer Experience', credits:3),
    ])]),
  Program(id:'c_bus_gen', name:'Business Administration — General', degree:'Certificate', totalHours:'12', category:'Business',
    description:'Financial accounting, business basics, personal finance, and computing.',
    icon:Icons.business, color:const Color(0xFF0277BD),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ACC 111', name:'Financial Accounting', credits:3),
        Course(code:'BUS 110', name:'Introduction to Business', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'BUS 125', name:'Personal Finance', credits:3),
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
      ]),
    ]),
  Program(id:'c_bus_foundations', name:'Business Foundations', degree:'Certificate', totalHours:'12', category:'Business',
    description:'Core business knowledge in accounting, law, economics, and business principles.',
    icon:Icons.business, color:const Color(0xFF0277BD),
    semesters: const [Semester(label:'Semester 1 (Fall)', courses:[
      Course(code:'ACC 111', name:'Financial Accounting', credits:3),
      Course(code:'BUS 110', name:'Introduction to Business', credits:3),
      Course(code:'BUS 115', name:'Business Law I', credits:3),
      Course(code:'ECO 251', name:'Prin of Microeconomics', credits:3),
    ])]),
  Program(id:'c_customer_svc', name:'Customer Service', degree:'Certificate', totalHours:'12', category:'Business',
    description:'Management, HR, marketing, and customer experience for service industry careers.',
    icon:Icons.support_agent, color:const Color(0xFF0277BD),
    semesters: const [Semester(label:'Semester 1 (Spring)', courses:[
      Course(code:'BUS 137', name:'Principles of Management', credits:3),
      Course(code:'BUS 153', name:'Human Resource Management', credits:3),
      Course(code:'MKT 120', name:'Principles of Marketing', credits:3),
      Course(code:'MKT 223', name:'Customer Experience', credits:3),
    ])]),
  Program(id:'c_cisco', name:'Cisco Networking Academy', degree:'Certificate', totalHours:'12', category:'Technology',
    description:'Industry-recognized Cisco networking covering intro networks, routing, and enterprise networking.',
    icon:Icons.router, color:const Color(0xFF1A237E),
    semesters: const [
      Semester(label:'Semester 1 (Spring)', courses:[
        Course(code:'NET 125', name:'Introduction to Networks', credits:3),
        Course(code:'SEC 110', name:'Security Concepts', credits:3),
      ]),
      Semester(label:'Semester 2 (Fall)', courses:[Course(code:'NET 126', name:'Switching and Routing', credits:3)]),
      Semester(label:'Semester 3 (Spring)', courses:[Course(code:'NET 225', name:'Enterprise Networking', credits:3)]),
    ]),
  Program(id:'c_culinary', name:'Culinary Arts', degree:'Certificate', totalHours:'13', category:'Culinary',
    description:'Foundational culinary certificate covering sanitation, food service, cost control, and career development.',
    icon:Icons.restaurant, color:const Color(0xFF6D4C41),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'CUL 110', name:'Sanitation & Safety', credits:2),
        Course(code:'CUL 110A', name:'Sanitation & Safety Lab', credits:1),
        Course(code:'HRM 245', name:'Human Resource Mgmt — Hospitality', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'CUL 135', name:'Food & Beverage Service', credits:2),
        Course(code:'CUL 135A', name:'Food & Beverage Service Lab', credits:1),
        Course(code:'CUL 273', name:'Career Development', credits:1),
        Course(code:'HRM 220', name:'Cost Control — Food & Beverage', credits:3),
      ]),
    ]),
  Program(id:'c_blet', name:'Basic Law Enforcement Training (BLET)', degree:'Certificate', totalHours:'37', category:'Public Safety',
    description:'NC-mandated training for law enforcement officers covering all required BLET competencies.',
    icon:Icons.local_police, color:const Color(0xFF263238),
    semesters: const [Semester(label:'Full Program', courses:[
      Course(code:'LET 110', name:'Basic Law Enforcement BLET', credits:37),
    ])]),
  Program(id:'c_cjt_corr', name:'CJT — Corrections Essentials', degree:'Certificate', totalHours:'12', category:'Public Safety',
    description:'Foundation in criminal justice, criminology, corrections, and correctional law.',
    icon:Icons.local_police, color:const Color(0xFF263238),
    semesters: const [
      Semester(label:'Fall Semester', courses:[Course(code:'CJC 111', name:'Intro to Criminal Justice', credits:3)]),
      Semester(label:'Spring Semester', courses:[
        Course(code:'CJC 112', name:'Criminology', credits:3),
        Course(code:'CJC 141', name:'Corrections', credits:3),
        Course(code:'CJC 233', name:'Correctional Law', credits:3),
      ]),
    ]),
  Program(id:'c_cjt_court', name:'CJT — Court Foundations', degree:'Certificate', totalHours:'15', category:'Public Safety',
    description:'Criminal justice, juvenile justice, criminal law, victimology, and court procedure.',
    icon:Icons.gavel, color:const Color(0xFF263238),
    semesters: const [
      Semester(label:'Fall Semester', courses:[
        Course(code:'CJC 111', name:'Intro to Criminal Justice', credits:3),
        Course(code:'CJC 113', name:'Juvenile Justice', credits:3),
        Course(code:'CJC 131', name:'Criminal Law', credits:3),
        Course(code:'CJC 214', name:'Victimology', credits:3),
      ]),
      Semester(label:'Spring Semester', courses:[Course(code:'CJC 132', name:'Court Procedure & Evidence', credits:3)]),
    ]),
  Program(id:'c_cjt_le', name:'CJT — Fundamental Principles of Law Enforcement', degree:'Certificate', totalHours:'16', category:'Public Safety',
    description:'Criminal law, ethics, investigative principles, law enforcement operations, and civil liability.',
    icon:Icons.local_police, color:const Color(0xFF263238),
    semesters: const [
      Semester(label:'Fall Semester', courses:[
        Course(code:'CJC 131', name:'Criminal Law', credits:3),
        Course(code:'CJC 212', name:'Ethics & Community Relations', credits:3),
        Course(code:'CJC 221', name:'Investigative Principles', credits:4),
      ]),
      Semester(label:'Spring Semester', courses:[
        Course(code:'CJC 121', name:'Law Enforcement Operations', credits:3),
        Course(code:'CJC 232', name:'Civil Liability', credits:3),
      ]),
    ]),
  Program(id:'c_cjt_homeland', name:'CJT — Homeland Security', degree:'Certificate', totalHours:'15', category:'Public Safety',
    description:'Criminal justice, criminal law, homeland security, border security, and constitutional law.',
    icon:Icons.security, color:const Color(0xFF263238),
    semesters: const [
      Semester(label:'Fall Semester', courses:[
        Course(code:'CJC 111', name:'Intro to Criminal Justice', credits:3),
        Course(code:'CJC 131', name:'Criminal Law', credits:3),
        Course(code:'CJC 161', name:'Intro to Homeland Security', credits:3),
      ]),
      Semester(label:'Spring Semester', courses:[
        Course(code:'CJC 163', name:'Transportation & Border Security', credits:3),
        Course(code:'CJC 231', name:'Constitutional Law', credits:3),
      ]),
    ]),
  Program(id:'c_cjt_leader', name:'CJT — Leadership and Management', degree:'Certificate', totalHours:'18', category:'Public Safety',
    description:'Critical thinking, crisis management, organization, supervision, and leadership for public safety.',
    icon:Icons.military_tech, color:const Color(0xFF263238),
    semesters: const [
      Semester(label:'Fall Semester', courses:[
        Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
        Course(code:'CJC 170', name:'Critical Incident Mgmt Public Safety', credits:3),
        Course(code:'HUM 115', name:'Critical Thinking', credits:3),
      ]),
      Semester(label:'Spring Semester', courses:[
        Course(code:'CJC 215', name:'Organization & Administration', credits:3),
        Course(code:'CJC 225', name:'Crisis Intervention', credits:3),
        Course(code:'CJC 240', name:'Law Enforcement Mgmt & Supervision', credits:3),
      ]),
    ]),
  Program(id:'c_ece_admin', name:'Early Childhood Administration', degree:'Certificate', totalHours:'16', category:'Education',
    description:'Prepares students to manage and administer early childhood programs and childcare centers.',
    icon:Icons.child_care, color:const Color(0xFFE65100),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'EDU 119', name:'Intro to Early Child Education', credits:4),
        Course(code:'EDU 261', name:'Early Childhood Admin I', credits:3),
        Course(code:'EDU 262', name:'Early Childhood Admin II', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'EDU 131', name:'Child, Family, and Community', credits:3),
        Course(code:'EDU 153', name:'Health, Safety and Nutrition', credits:3),
      ]),
    ]),
  Program(id:'c_ece_assoc', name:'Early Childhood Associate', degree:'Certificate', totalHours:'16', category:'Education',
    description:'Entry-level ECE certificate covering intro to early childhood education, guidance, and child development.',
    icon:Icons.child_care, color:const Color(0xFFE65100),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'EDU 119', name:'Intro to Early Child Education', credits:4),
        Course(code:'EDU 146', name:'Child Guidance', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'EDU 131', name:'Child, Family, and Community', credits:3),
        Course(code:'EDU 144', name:'Child Development I', credits:3),
        Course(code:'EDU 145', name:'Child Development II', credits:3),
      ]),
    ]),
  Program(id:'c_ece_preschool', name:'Early Childhood Preschool', degree:'Certificate', totalHours:'16', category:'Education',
    description:'Prepares students to work in preschool settings with children ages 3-5.',
    icon:Icons.child_care, color:const Color(0xFFE65100),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'EDU 119', name:'Intro to Early Child Education', credits:4),
        Course(code:'EDU 146', name:'Child Guidance', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'EDU 131', name:'Child, Family, and Community', credits:3),
        Course(code:'EDU 145', name:'Child Development II', credits:3),
        Course(code:'EDU 153', name:'Health, Safety and Nutrition', credits:3),
      ]),
    ]),
  Program(id:'c_elem_resid', name:'Elementary Education Residency Licensure', degree:'Certificate', totalHours:'18', category:'Education',
    description:'Six-semester licensure certificate for educators completing NC elementary teaching license residency.',
    icon:Icons.school, color:const Color(0xFF6A1B9A),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[Course(code:'EDU 270', name:'Effective Instructional Environments', credits:2)]),
      Semester(label:'Semester 2 (Spring)', courses:[Course(code:'EDU 272', name:'Technology, Data, and Assessment', credits:3)]),
      Semester(label:'Semester 3 (Fall)', courses:[Course(code:'EDU 277', name:'Integrated Curriculum: Math/Science', credits:3)]),
      Semester(label:'Semester 4 (Spring)', courses:[Course(code:'EDU 279', name:'Literacy Development and Instruction', credits:4)]),
      Semester(label:'Semester 5 (Fall)', courses:[Course(code:'EDU 278', name:'Integrated Curriculum: Soc Stu/ELA', credits:3)]),
      Semester(label:'Semester 6 (Spring)', courses:[Course(code:'EDU 283', name:'Educator Preparation Practicum', credits:3)]),
    ]),
  Program(id:'c_infant_toddler', name:'Infant/Toddler Care', degree:'Certificate', totalHours:'16', category:'Education',
    description:'Certificate preparing students to work with infants and toddlers (birth to age 3).',
    icon:Icons.child_care, color:const Color(0xFFE65100),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[Course(code:'EDU 119', name:'Intro to Early Child Education', credits:4)]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'EDU 131', name:'Child, Family, and Community', credits:3),
        Course(code:'EDU 144', name:'Child Development I', credits:3),
        Course(code:'EDU 153', name:'Health, Safety and Nutrition', credits:3),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[Course(code:'EDU 234', name:'Infants, Toddlers, and Twos', credits:3)]),
    ]),
  Program(id:'c_it_cyber', name:'IT — Cyber Security', degree:'Certificate', totalHours:'18', category:'Technology',
    description:'Cybercrime, Linux, security administration, virtualization, and network security foundations.',
    icon:Icons.security, color:const Color(0xFF1A237E),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'CCT 110', name:'Intro to Cyber Crime', credits:3),
        Course(code:'NOS 120', name:'Linux Single User', credits:3),
        Course(code:'SEC 160', name:'Security Administration I', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'CTI 140', name:'Virtualization Concepts', credits:3),
        Course(code:'NET 125', name:'Introduction to Networks', credits:3),
        Course(code:'SEC 110', name:'Security Concepts', credits:3),
      ]),
    ]),
  Program(id:'c_it_found', name:'Information Technology', degree:'Certificate', totalHours:'12', category:'Technology',
    description:'Hardware/software support, operating systems, IT foundations, and security concepts.',
    icon:Icons.computer, color:const Color(0xFF4527A0),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'CTS 120', name:'Hardware/Software Support', credits:3),
        Course(code:'NOS 110', name:'Operating Systems Concepts', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'CTI 110', name:'IT Foundations', credits:3),
        Course(code:'SEC 110', name:'Security Concepts', credits:3),
      ]),
    ]),
  Program(id:'c_welding', name:'Welding Technology', degree:'Certificate', totalHours:'18', category:'Trades',
    description:'Covers SMAW and GTAW welding processes — stick and TIG welding on plate and pipe.',
    icon:Icons.construction, color:const Color(0xFF4E342E),
    semesters: const [
      Semester(label:'Fall Semester', courses:[
        Course(code:'WLD 110', name:'Cutting Processes', credits:2),
        Course(code:'WLD 115', name:'SMAW (Stick) Plate', credits:5),
        Course(code:'WLD 131', name:'GTAW (TIG) Plate', credits:4),
      ]),
      Semester(label:'Spring Semester', courses:[
        Course(code:'WLD 116', name:'SMAW (Stick) Plate/Pipe', credits:4),
        Course(code:'WLD 132', name:'GTAW (TIG) Plate/Pipe', credits:3),
      ]),
    ]),
  Program(id:'c_wire1', name:'Wire Installer I', degree:'Certificate', totalHours:'13', category:'Trades',
    description:'Entry-level electrical certificate covering DC/AC electricity, residential wiring, and NEC code.',
    icon:Icons.electrical_services, color:const Color(0xFFF57F17),
    semesters: const [Semester(label:'Semester 1 (Fall)', courses:[
      Course(code:'CIS 111', name:'Basic PC Literacy', credits:2),
      Course(code:'ELC 112', name:'DC/AC Electricity', credits:5),
      Course(code:'ELC 113', name:'Residential Wiring', credits:4),
      Course(code:'ELC 118', name:'National Electrical Code', credits:2),
    ])]),
  Program(id:'c_wire2', name:'Wire Installer II', degree:'Certificate', totalHours:'12', category:'Trades',
    description:'Advanced wiring certificate covering commercial wiring, motors and controls, industrial electronics.',
    icon:Icons.electrical_services, color:const Color(0xFFF57F17),
    semesters: const [Semester(label:'Semester 1 (Spring)', courses:[
      Course(code:'ELC 114', name:'Commercial Wiring', credits:4),
      Course(code:'ELC 117', name:'Motors and Controls', credits:4),
      Course(code:'ELN 229', name:'Industrial Electronics', credits:4),
    ])]),
  Program(id:'c_photovoltaic', name:'Photovoltaic Systems', degree:'Certificate', totalHours:'16', category:'Trades',
    description:'DC/AC electricity, residential wiring, industrial electronics, and solar PV systems technology.',
    icon:Icons.solar_power, color:const Color(0xFFF57F17),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ELC 112', name:'DC/AC Electricity', credits:5),
        Course(code:'ELC 113', name:'Residential Wiring', credits:4),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[Course(code:'ELN 229', name:'Industrial Electronics', credits:4)]),
      Semester(label:'Semester 3 (Spring)', courses:[Course(code:'ELC 220', name:'Photovoltaic Systems Technology', credits:3)]),
    ]),
  Program(id:'c_med_office', name:'Medical Office Administration', degree:'Certificate', totalHours:'15', category:'Business',
    description:'Medical insurance, billing, terminology, legal issues, and word processing for medical office careers.',
    icon:Icons.medical_services, color:const Color(0xFF880E4F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'OST 148', name:'Med Insurance & Billing', credits:3),
        Course(code:'OST 141', name:'Med Office Terms I', credits:3),
        Course(code:'OST 142', name:'Med Office Terms II', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[Course(code:'OST 149', name:'Medical Legal Issues', credits:3)]),
      Semester(label:'Semester 3 (Fall)', courses:[Course(code:'OST 136', name:'Word Processing', credits:3)]),
    ]),
  Program(id:'c_med_billing', name:'Medical Office Admin — Billing & Coding', degree:'Certificate', totalHours:'15', category:'Business',
    description:'Medical terminology, insurance/billing, diagnostic coding, and procedure coding.',
    icon:Icons.medical_services, color:const Color(0xFF880E4F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'OST 148', name:'Med Insurance & Billing', credits:3),
        Course(code:'OST 141', name:'Med Office Terms I', credits:3),
        Course(code:'OST 142', name:'Med Office Terms II', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[Course(code:'OST 248', name:'Diagnostic Coding', credits:3)]),
      Semester(label:'Semester 3 (Fall)', courses:[Course(code:'OST 247', name:'Procedure Coding', credits:3)]),
    ]),
  Program(id:'c_patient_rep', name:'Medical Office Admin — Patient Representative', degree:'Certificate', totalHours:'12', category:'Business',
    description:'Computers, customer experience, financial accounting, and personal finance for patient-facing roles.',
    icon:Icons.medical_services, color:const Color(0xFF880E4F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
        Course(code:'MKT 223', name:'Customer Experience', credits:3),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ACC 111', name:'Financial Accounting', credits:3),
        Course(code:'BUS 125', name:'Personal Finance', credits:3),
      ]),
    ]),
  Program(id:'c_office_admin', name:'Office Administration', degree:'Certificate', totalHours:'12', category:'Business',
    description:'Computers, writing, customer experience, and medical legal issues for administrative office roles.',
    icon:Icons.business_center, color:const Color(0xFF0277BD),
    semesters: const [Semester(label:'Semester 1 (Spring)', courses:[
      Course(code:'CIS 110', name:'Introduction to Computers', credits:3),
      Course(code:'ENG 111', name:'Writing and Inquiry', credits:3),
      Course(code:'MKT 223', name:'Customer Experience', credits:3),
      Course(code:'OST 149', name:'Medical Legal Issues', credits:3),
    ])]),
  Program(id:'c_plc', name:'Programmable Logic Controllers', degree:'Certificate', totalHours:'15', category:'Trades',
    description:'Industrial safety, PLCs, circuit analysis, and control systems for automation technicians.',
    icon:Icons.memory, color:const Color(0xFF37474F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[Course(code:'ISC 112', name:'Industrial Safety', credits:2)]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ELN 260', name:'Programmable Logic Controllers', credits:4),
        Course(code:'ELC 131', name:'Circuit Analysis I', credits:4),
        Course(code:'ELC 131A', name:'Circuit Analysis I Lab', credits:1),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[Course(code:'MNT 130', name:'Control Systems', credits:4)]),
    ]),
  Program(id:'c_robotics', name:'Robotics', degree:'Certificate', totalHours:'16', category:'Trades',
    description:'DC/AC electricity, motors and controls, PLCs, and robotic fundamentals.',
    icon:Icons.precision_manufacturing, color:const Color(0xFFF57F17),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[Course(code:'ELC 112', name:'DC/AC Electricity', credits:5)]),
      Semester(label:'Semester 2 (Spring)', courses:[Course(code:'ELC 117', name:'Motors and Controls', credits:4)]),
      Semester(label:'Semester 3 (Summer)', courses:[Course(code:'ELC 128', name:'Intro to Programmable Logic Controllers', credits:3)]),
      Semester(label:'Semester 4 (Spring II)', courses:[Course(code:'ATR 280', name:'Robotic Fundamentals', credits:4)]),
    ]),
  Program(id:'c_mech_design', name:'Mechanical Design Technology', degree:'Certificate', totalHours:'13', category:'Trades',
    description:'CAD, solid modeling, automation, schematics, and industrial safety for mechanical design roles.',
    icon:Icons.precision_manufacturing, color:const Color(0xFF37474F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ATR 112', name:'Intro to Automation', credits:3),
        Course(code:'DFT 151', name:'CAD I', credits:3),
        Course(code:'ELC 125', name:'Diagrams and Schematics', credits:2),
        Course(code:'ISC 112', name:'Industrial Safety', credits:2),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'DFT 154', name:'Introduction to Solid Modeling', credits:3),
      ]),
    ]),
  Program(id:'c_mech_eng', name:'Mechatronics Engineering', degree:'Certificate', totalHours:'13', category:'Trades',
    description:'Hydraulics, advanced motors/controls, fluid power diagrams, CAD/CAM, and mechanisms.',
    icon:Icons.precision_manufacturing, color:const Color(0xFF37474F),
    semesters: const [
      Semester(label:'Semester 1 (Spring)', courses:[
        Course(code:'HYD 110', name:'Hydraulics/Pneumatics I', credits:3),
      ]),
      Semester(label:'Semester 2 (Summer)', courses:[
        Course(code:'ELC 130', name:'Advanced Motors/Controls', credits:3),
        Course(code:'BPR 115', name:'ELC/Fluid Power Diagrams', credits:2),
        Course(code:'MEC 110', name:'Intro to CAD/CAM', credits:2),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[
        Course(code:'MEC 130', name:'Mechanisms', credits:3),
      ]),
    ]),
  Program(id:'c_mech_tech', name:'Mechatronics Engineering Technology', degree:'Certificate', totalHours:'13', category:'Trades',
    description:'CAD, industrial safety, circuit analysis, and mechanisms for entry-level mechatronics roles.',
    icon:Icons.precision_manufacturing, color:const Color(0xFF37474F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'DFT 151', name:'CAD I', credits:3),
        Course(code:'ISC 112', name:'Industrial Safety', credits:2),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ELC 131', name:'Circuit Analysis I', credits:4),
        Course(code:'ELC 131A', name:'Circuit Analysis I Lab', credits:1),
        Course(code:'MEC 130', name:'Mechanisms', credits:3),
      ]),
    ]),
  Program(id:'c_mech_mp', name:'Mechatronics Mechanical Procedures One', degree:'Certificate', totalHours:'13', category:'Trades',
    description:'Industrial safety, circuit analysis, advanced motors, and mechanisms across four semesters.',
    icon:Icons.precision_manufacturing, color:const Color(0xFF37474F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[Course(code:'ISC 112', name:'Industrial Safety', credits:2)]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ELC 131', name:'Circuit Analysis I', credits:4),
        Course(code:'ELC 131A', name:'Circuit Analysis I Lab', credits:1),
      ]),
      Semester(label:'Semester 3 (Fall)', courses:[Course(code:'ELC 130', name:'Advanced Motors/Controls', credits:3)]),
      Semester(label:'Semester 4 (Spring)', courses:[Course(code:'MEC 130', name:'Mechanisms', credits:3)]),
    ]),
  Program(id:'c_robotic_eng', name:'Robotic Engineering', degree:'Certificate', totalHours:'13', category:'Trades',
    description:'Automation, industrial safety, PLCs, and robotics/CIM for entry-level robotics careers.',
    icon:Icons.smart_toy, color:const Color(0xFF37474F),
    semesters: const [
      Semester(label:'Semester 1 (Fall)', courses:[
        Course(code:'ATR 112', name:'Intro to Automation', credits:3),
        Course(code:'ISC 112', name:'Industrial Safety', credits:2),
      ]),
      Semester(label:'Semester 2 (Spring)', courses:[
        Course(code:'ELN 260', name:'Programmable Logic Controllers', credits:4),
      ]),
      Semester(label:'Semester 3 (Spring)', courses:[
        Course(code:'ATR 282', name:'Robotics and CIM', credits:4),
      ]),
    ]),
];

// ═══════════════════════════════════════════
// SHARED WIDGETS
// ═══════════════════════════════════════════
AppBar _appBar(String title, String sub) => AppBar(
  backgroundColor: navy,
  title: Row(children: [
    Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('RCC', style: TextStyle(color: navy, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          Container(height: 1.5, color: green),
          const Text('ROBESON', style: TextStyle(color: navy, fontSize: 5.5, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
        ]),
      ),
    ),
    const SizedBox(width: 10),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
      Text(sub, style: const TextStyle(color: Colors.white70, fontSize: 10)),
    ]),
  ]),
);

Widget _card({required Widget child, Color? border}) => Container(
  margin: const EdgeInsets.only(bottom: 10),
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: border ?? borderColor),
  ),
  child: child,
);

Widget _sectionLabel(String t) => Padding(
  padding: const EdgeInsets.only(bottom: 8, top: 4),
  child: Text(t, style: const TextStyle(color: navy, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
);

Widget _bullet(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 4),
  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('• ', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
    Expanded(child: Text(text, style: const TextStyle(color: textGray, fontSize: 12, height: 1.4))),
  ]),
);

// ═══════════════════════════════════════════
// PROGRAM LIST SCREEN (shared by degrees/diplomas/certs)
// ═══════════════════════════════════════════
class _ProgramListScreen extends StatefulWidget {
  final String title, subtitle;
  final List<Program> programs;
  final List<String> categories;
  const _ProgramListScreen({required this.title, required this.subtitle, required this.programs, required this.categories});
  @override State<_ProgramListScreen> createState() => _ProgramListScreenState();
}

class _ProgramListScreenState extends State<_ProgramListScreen> {
  String _cat = 'All';

  List<Program> get _filtered => _cat == 'All' ? widget.programs : widget.programs.where((p) => p.category == _cat).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navyLight,
      appBar: AppBar(
        backgroundColor: navy,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text(widget.subtitle, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(20)),
            child: Text('${widget.programs.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Column(children: [
        Container(
          color: Colors.white, height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            children: widget.categories.map((cat) {
              final sel = cat == _cat;
              return GestureDetector(
                onTap: () => setState(() => _cat = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(color: sel ? navy : navyLight, borderRadius: BorderRadius.circular(20)),
                  child: Text(cat, style: TextStyle(color: sel ? Colors.white : navy, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(child: ListView(padding: const EdgeInsets.all(12), children: [
          ..._filtered.map((p) => _ProgramCard(program: p)),
          const SizedBox(height: 20),
        ])),
      ]),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final Program program;
  const _ProgramCard({required this.program});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _ProgramDetail(program: program))),
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0,2))]),
      child: Row(children: [
        Container(width: 46, height: 46,
          decoration: BoxDecoration(color: program.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
          child: Icon(program.icon, color: program.color, size: 24)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(color: program.color, borderRadius: BorderRadius.circular(6)),
              child: Text(program.degree, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            const SizedBox(width: 8),
            Text('${program.totalHours} cr hrs', style: TextStyle(color: program.color, fontSize: 11, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 4),
          Text(program.name, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 2),
          Text(program.description, style: const TextStyle(color: textGray, fontSize: 11, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right, color: textGray),
      ]),
    ),
  );
}

// ═══════════════════════════════════════════
// PROGRAM DETAIL
// ═══════════════════════════════════════════
class _ProgramDetail extends StatefulWidget {
  final Program program;
  const _ProgramDetail({required this.program});
  @override State<_ProgramDetail> createState() => _ProgramDetailState();
}

class _ProgramDetailState extends State<_ProgramDetail> {
  final Set<String> _done = {};
  bool _loaded = false;

  String get _key => 'prog_${widget.program.id}';

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() { _done.addAll(p.getStringList(_key) ?? []); _loaded = true; });
  }

  Future<void> _toggle(String code) async {
    setState(() { _done.contains(code) ? _done.remove(code) : _done.add(code); });
    final p = await SharedPreferences.getInstance();
    await p.setStringList(_key, _done.toList());
  }

  Future<void> _reset() async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Reset Progress?'),
      content: Text('Clear all checked courses for ${widget.program.name}?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Reset', style: TextStyle(color: Colors.red))),
      ],
    ));
    if (ok == true) { setState(() => _done.clear()); final p = await SharedPreferences.getInstance(); await p.remove(_key); }
  }

  List<Course> get _all => widget.program.semesters.expand((s) => s.courses).toList();
  int    get _doneCount   => _all.where((c) => _done.contains(c.code)).length;
  double get _doneCredits => _all.where((c) => _done.contains(c.code)).fold(0, (s,c) => s+c.credits);

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final prog = _all.isEmpty ? 0.0 : _doneCount / _all.length;
    return Scaffold(
      backgroundColor: navyLight,
      appBar: AppBar(
        backgroundColor: widget.program.color, foregroundColor: Colors.white,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.program.name, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          Text('${widget.program.degree} — ${widget.program.totalHours} credit hours', style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ]),
        actions: [IconButton(icon: const Icon(Icons.refresh, color: Colors.white70), onPressed: _reset)],
      ),
      body: Column(children: [
        Container(color: widget.program.color, padding: const EdgeInsets.fromLTRB(16,0,16,14), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('$_doneCount / ${_all.length} courses', style: const TextStyle(color: Colors.white, fontSize: 12)),
            Text('${_doneCredits.toInt()} / ${widget.program.calcCredits.toInt()} cr', style: const TextStyle(color: Colors.white, fontSize: 12)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: prog, minHeight: 9, backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white))),
          const SizedBox(height: 3),
          Align(alignment: Alignment.centerRight,
            child: Text('${(prog*100).toStringAsFixed(0)}% complete', style: const TextStyle(color: Colors.white70, fontSize: 11))),
        ])),
        Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
          ...widget.program.semesters.map((sem) => _SemCard(sem: sem, done: _done, onToggle: _toggle, color: widget.program.color)),
          const SizedBox(height: 20),
        ])),
      ]),
    );
  }
}

class _SemCard extends StatelessWidget {
  final Semester sem; final Set<String> done; final ValueChanged<String> onToggle; final Color color;
  const _SemCard({required this.sem, required this.done, required this.onToggle, required this.color});
  @override
  Widget build(BuildContext context) {
    final sd = sem.courses.where((c) => done.contains(c.code)).length;
    final sc = sem.courses.fold<double>(0,(s,c)=>s+c.credits);
    final sdc = sem.courses.where((c)=>done.contains(c.code)).fold<double>(0,(s,c)=>s+c.credits);
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
            border: Border(bottom: BorderSide(color: color.withOpacity(0.2)))),
          child: Row(children: [
            Icon(Icons.calendar_today, color: color, size: 14), const SizedBox(width: 8),
            Text(sem.label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
            const Spacer(),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: sd==sem.courses.length ? green : color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('$sd/${sem.courses.length} | ${sdc.toInt()}/${sc.toInt()} cr',
                style: TextStyle(color: sd==sem.courses.length ? Colors.white : color, fontSize: 10, fontWeight: FontWeight.w600))),
          ]),
        ),
        ...sem.courses.map((c) => _CourseRow(course: c, done: done, onToggle: onToggle, color: color)),
      ]),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final Course course; final Set<String> done; final ValueChanged<String> onToggle; final Color color;
  const _CourseRow({required this.course, required this.done, required this.onToggle, required this.color});
  @override
  Widget build(BuildContext context) {
    final isDone = done.contains(course.code);
    return GestureDetector(
      onTap: () {
        if (course.isElective && course.note != null) {
          showDialog(context: context, builder: (_) => AlertDialog(
            title: Row(children: [Icon(Icons.info_outline, color: color, size: 20), const SizedBox(width: 8), const Text('Elective Options', style: TextStyle(fontSize: 15))]),
            content: Text(course.note!, style: const TextStyle(fontSize: 13, height: 1.5)),
            actions: [
              TextButton(child: const Text('Mark Complete'), onPressed: () { Navigator.pop(context); onToggle(course.code); }),
              TextButton(child: const Text('Close'), onPressed: () => Navigator.pop(context)),
            ],
          ));
        } else { onToggle(course.code); }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(color: isDone ? greenLight : Colors.white,
          border: Border(bottom: BorderSide(color: borderColor.withOpacity(0.5)))),
        child: Row(children: [
          Icon(isDone ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isDone ? green : (course.isElective ? Colors.orange.shade300 : Colors.grey.shade300), size: 21),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(course.code, style: TextStyle(color: isDone ? green : color, fontSize: 10, fontWeight: FontWeight.bold,
                decoration: isDone ? TextDecoration.lineThrough : null)),
              if (course.isElective) ...[const SizedBox(width: 5),
                Container(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
                  child: Text('ELECTIVE', style: TextStyle(color: Colors.orange.shade700, fontSize: 8, fontWeight: FontWeight.bold)))],
            ]),
            const SizedBox(height: 1),
            Text(course.name, style: TextStyle(color: isDone ? green.withOpacity(0.8) : navy, fontSize: 12,
              decoration: isDone ? TextDecoration.lineThrough : null)),
          ])),
          const SizedBox(width: 6),
          Text('${course.credits%1==0?course.credits.toInt():course.credits} cr',
            style: TextStyle(color: isDone ? green : textGray, fontSize: 11, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// TAB SCREENS
// ═══════════════════════════════════════════
class DegreesScreen extends StatelessWidget {
  const DegreesScreen({super.key});
  @override
  Widget build(BuildContext context) => _ProgramListScreen(
    title: 'Degree Programs', subtitle: '2025-2026 Catalog',
    programs: degrees,
    categories: const ['All','Transfer','Education','Business','Technology','Trades','Culinary','Public Safety'],
  );
}

class DiplomasScreen extends StatelessWidget {
  const DiplomasScreen({super.key});
  @override
  Widget build(BuildContext context) => _ProgramListScreen(
    title: 'Diploma Programs', subtitle: '2025-2026 Catalog',
    programs: diplomas,
    categories: const ['All','Trades','Business','Technology','Health Sciences','Public Safety'],
  );
}

class CertsScreen extends StatelessWidget {
  const CertsScreen({super.key});
  @override
  Widget build(BuildContext context) => _ProgramListScreen(
    title: 'Certificate Programs', subtitle: '2025-2026 Catalog',
    programs: certs,
    categories: const ['All','Trades','Business','Technology','Culinary','Education','Public Safety'],
  );
}

// ═══════════════════════════════════════════
// GPA SCREEN
// ═══════════════════════════════════════════
class GpaScreen extends StatefulWidget {
  const GpaScreen({super.key});
  @override State<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends State<GpaScreen> {
  final List<_GpaRow> _rows = [_GpaRow()];

  double? get _gpa {
    double pts = 0, cr = 0;
    for (final r in _rows) {
      if (r.credits != null && r.grade != null) { pts += r.credits! * r.grade!; cr += r.credits!; }
    }
    return cr == 0 ? null : pts / cr;
  }

  Color _gpaColor(double g) => g >= 3.5 ? green : g >= 2.0 ? const Color(0xFF1565C0) : Colors.red.shade600;
  String _gpaLabel(double g) {
    if (g >= 3.7) return 'Excellent — Keep it up!';
    if (g >= 3.0) return 'Good Standing';
    if (g >= 2.0) return 'Satisfactory — Above SAP minimum';
    if (g >= 1.6) return 'Warning — Near SAP minimum';
    return 'Below SAP Minimum — Aid at Risk';
  }

  @override
  Widget build(BuildContext context) {
    final gpa = _gpa;
    return Scaffold(
      backgroundColor: navyLight,
      appBar: _appBar('GPA Calculator', 'Robeson Community College'),
      body: Column(children: [
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20), color: navy,
          child: Column(children: [
            Text(gpa != null ? gpa.toStringAsFixed(2) : '--',
              style: TextStyle(color: gpa != null ? _gpaColor(gpa) : Colors.white30, fontSize: 56, fontWeight: FontWeight.bold)),
            Text(gpa != null ? _gpaLabel(gpa) : 'Enter your courses below', style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 3),
            const Text('SAP Minimum: 2.0 GPA', style: TextStyle(color: Colors.white38, fontSize: 11)),
          ])),
        Expanded(child: ListView(padding: const EdgeInsets.all(14), children: [
          _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Row(children: [Icon(Icons.info_outline, color: navy, size: 16), SizedBox(width: 6),
              Text('How to Use', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12))]),
            SizedBox(height: 6),
            Text('1. Select credit hours for each course\n2. Select your grade\n3. Add more courses as needed\n4. GPA calculates automatically',
              style: TextStyle(color: textGray, fontSize: 12, height: 1.6)),
          ])),
          ..._rows.asMap().entries.map((e) => _GpaRowWidget(
            row: e.value, index: e.key, onChanged: () => setState(() {}),
            onRemove: _rows.length > 1 ? () => setState(() => _rows.removeAt(e.key)) : null,
          )),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: OutlinedButton.icon(
              onPressed: () => setState(() => _rows.add(_GpaRow())),
              icon: const Icon(Icons.add, color: navy, size: 16),
              label: const Text('Add Course', style: TextStyle(color: navy, fontSize: 12)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: navy)),
            )),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => setState(() { _rows.clear(); _rows.add(_GpaRow()); }),
              icon: const Icon(Icons.refresh, color: textGray, size: 16),
              label: const Text('Reset', style: TextStyle(color: textGray, fontSize: 12)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: borderColor)),
            ),
          ]),
          const SizedBox(height: 12),
          if (gpa != null) _card(
            border: gpa >= 2.0 ? green : Colors.red.shade300,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(gpa >= 2.0 ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: gpa >= 2.0 ? green : Colors.red.shade600, size: 20),
                const SizedBox(width: 8),
                Text('GPA / SAP Status', style: TextStyle(color: gpa >= 2.0 ? green : Colors.red.shade600, fontWeight: FontWeight.bold, fontSize: 14)),
              ]),
              const SizedBox(height: 6),
              Text(gpa >= 2.0
                ? 'Your GPA meets the 2.0 SAP minimum to maintain financial aid eligibility.'
                : 'Your GPA is below the 2.0 SAP minimum. Contact Financial Aid in Building 13 immediately.',
                style: TextStyle(color: gpa >= 2.0 ? textGray : Colors.red.shade700, fontSize: 12, height: 1.5)),
              if (gpa < 2.0) ...[const SizedBox(height: 8),
                Container(padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(8)),
                  child: const Text('You may have the right to appeal. See the SAP tab for appeal information.',
                    style: TextStyle(color: Color(0xFF7F0000), fontSize: 11, height: 1.4)))],
            ]),
          ),
          const SizedBox(height: 20),
        ])),
      ]),
    );
  }
}

class _GpaRow { double? credits; double? grade; }
const _grades = [('A',4.0),('B+',3.5),('B',3.0),('C+',2.5),('C',2.0),('D+',1.5),('D',1.0),('F',0.0)];
const _credOpts = [1.0,2.0,3.0,4.0,5.0];

class _GpaRowWidget extends StatelessWidget {
  final _GpaRow row; final int index; final VoidCallback onChanged; final VoidCallback? onRemove;
  const _GpaRowWidget({required this.row, required this.index, required this.onChanged, this.onRemove});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor)),
    child: Row(children: [
      Text('${index+1}.', style: const TextStyle(color: textGray, fontSize: 12, fontWeight: FontWeight.bold)),
      const SizedBox(width: 8),
      Expanded(child: DropdownButtonFormField<double>(
        value: row.credits,
        decoration: const InputDecoration(labelText: 'Credits', labelStyle: TextStyle(fontSize: 11), isDense: true, border: OutlineInputBorder()),
        items: _credOpts.map((c) => DropdownMenuItem(value: c, child: Text('${c.toInt()}', style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: (v) { row.credits = v; onChanged(); },
      )),
      const SizedBox(width: 8),
      Expanded(child: DropdownButtonFormField<double>(
        value: row.grade,
        decoration: const InputDecoration(labelText: 'Grade', labelStyle: TextStyle(fontSize: 11), isDense: true, border: OutlineInputBorder()),
        items: _grades.map((g) => DropdownMenuItem(value: g.$2, child: Text(g.$1, style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: (v) { row.grade = v; onChanged(); },
      )),
      if (onRemove != null) ...[const SizedBox(width: 4),
        IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18), onPressed: onRemove)],
    ]),
  );
}

// ═══════════════════════════════════════════
// SAP SCREEN
// ═══════════════════════════════════════════
class SapScreen extends StatefulWidget {
  const SapScreen({super.key});
  @override State<SapScreen> createState() => _SapScreenState();
}

class _SapScreenState extends State<SapScreen> {
  final _attCtrl = TextEditingController();
  final _compCtrl = TextEditingController();
  final _transCtrl = TextEditingController();
  final _progCtrl = TextEditingController();
  final Set<String> _exp = {};

  void _tog(String k) => setState(() => _exp.contains(k) ? _exp.remove(k) : _exp.add(k));
  bool _open(String k) => _exp.contains(k);

  @override void dispose() { _attCtrl.dispose(); _compCtrl.dispose(); _transCtrl.dispose(); _progCtrl.dispose(); super.dispose(); }

  double? get _att  => double.tryParse(_attCtrl.text);
  double? get _comp => double.tryParse(_compCtrl.text);
  double? get _prog => double.tryParse(_progCtrl.text);
  double? get _trans => double.tryParse(_transCtrl.text);
  double? get _pace => (_att==null||_comp==null||_att==0) ? null : (_comp!/_att!)*100;
  double? get _maxAllowed => _prog==null ? null : _prog!*1.5;
  double  get _used => (_att??0)+(_trans??0);
  bool    get _hasResults => _att!=null||_comp!=null||_prog!=null;

  Widget _field(TextEditingController c, String label, String hint, IconData icon) => TextField(
    controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true),
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon, color: navy, size: 18),
      border: const OutlineInputBorder(), isDense: true, labelStyle: const TextStyle(fontSize: 12), hintStyle: const TextStyle(fontSize: 11)),
  );

  Widget _result(String title, String value, bool passing, String good, String bad, String detail) => _card(
    border: passing ? green : Colors.red.shade300,
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(passing ? Icons.check_circle : Icons.warning_amber_rounded, color: passing ? green : Colors.red.shade600, size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(title, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 13))),
        Text(value, style: TextStyle(color: passing ? green : Colors.red.shade600, fontWeight: FontWeight.bold, fontSize: 16)),
      ]),
      const SizedBox(height: 6),
      Text(passing ? good : bad, style: TextStyle(color: passing ? green : Colors.red.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
      const SizedBox(height: 4),
      Text(detail, style: const TextStyle(color: textGray, fontSize: 11, height: 1.5)),
    ]),
  );

  Widget _policy(String key, IconData icon, String title, Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _open(key) ? navy : borderColor)),
    child: Column(children: [
      GestureDetector(
        onTap: () => _tog(key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _open(key) ? navyLight : Colors.white,
            borderRadius: _open(key) ? const BorderRadius.vertical(top: Radius.circular(11)) : BorderRadius.circular(11)),
          child: Row(children: [
            Icon(icon, color: navy, size: 18), const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 13))),
            Icon(_open(key) ? Icons.expand_less : Icons.expand_more, color: navy),
          ]),
        ),
      ),
      if (_open(key)) Padding(padding: const EdgeInsets.fromLTRB(14,4,14,14), child: child),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final pace = _pace;
    return Scaffold(
      backgroundColor: navyLight,
      appBar: _appBar('SAP Calculator', 'Satisfactory Academic Progress — RCC Policy'),
      body: ListView(padding: const EdgeInsets.all(14), children: [
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Row(children: [Icon(Icons.info_outline, color: navy, size: 16), SizedBox(width: 6),
            Text('How to Use', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12))]),
          SizedBox(height: 6),
          Text('Enter your credit hour totals to check your SAP standing:\n\n• PACE — Must complete 67% of attempted hours\n• MAX TIMEFRAME — Must finish within 150% of program length\n\nFor GPA (2.0 minimum), use the GPA tab.',
            style: TextStyle(color: textGray, fontSize: 12, height: 1.6)),
        ])),
        const SizedBox(height: 10),
        _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Enter Your Credit Hour Totals', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 12),
          _field(_attCtrl, 'Total Credits Attempted (all terms)', 'e.g. 30', Icons.school),
          const SizedBox(height: 10),
          _field(_compCtrl, 'Total Credits Completed (passed)', 'e.g. 22', Icons.check_circle_outline),
          const SizedBox(height: 10),
          _field(_transCtrl, 'Transfer Credits Accepted (0 if none)', 'e.g. 12', Icons.swap_horiz),
          const SizedBox(height: 10),
          _field(_progCtrl, 'Program Length (published credit hours)', 'e.g. 60 for AA, 69 for ECE AAS', Icons.menu_book),
        ])),
        const SizedBox(height: 10),
        if (_hasResults) ...[
          _sectionLabel('YOUR SAP RESULTS'),
          if (pace != null) _result('Completion Rate (PACE)', '${pace.toStringAsFixed(1)}%', pace>=67,
            'Meets SAP — 67% minimum satisfied',
            'Below SAP — Under 67% completion rate',
            'Completed ${_comp?.toInt()??0} of ${_att?.toInt()??0} attempted credits. Need: ${((_att??0)*0.67).toStringAsFixed(1)} credits minimum.'),
          if (_maxAllowed != null) ...[
            const SizedBox(height: 8),
            _result('Maximum Timeframe', '${_used.toInt()} / ${_maxAllowed!.toInt()} cr', _used<=_maxAllowed!,
              '${(_maxAllowed!-_used).toInt()} credits remaining before max',
              'EXCEEDED — No longer eligible for aid in this program',
              '${_prog?.toInt()} cr × 150% = ${_maxAllowed?.toInt()} cr max. Credits used: ${_used.toInt()} (attempted + transfer).'),
          ],
          const SizedBox(height: 10),
        ],
        _sectionLabel('RCC SAP POLICY'),
        _policy('s1', Icons.rule, 'SAP Standards — The Three Requirements',
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('RCC evaluates SAP at the end of every term (Fall, Spring, Summer). All students treated equally regardless of enrollment level.',
              style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
            SizedBox(height: 10),
            _PolicyRow(Icons.grade, '1. Qualitative (GPA)', 'Maintain a cumulative 2.0 GPA'),
            _PolicyRow(Icons.percent, '2. Quantitative (Pace)', 'Complete 67% of all attempted credits'),
            _PolicyRow(Icons.timer, '3. Maximum Timeframe', 'Complete program within 150% of its published length'),
            SizedBox(height: 8),
            Text('All enrollment periods count — even terms without aid. Transfer credits are included.',
              style: TextStyle(color: textGray, fontSize: 11, height: 1.4, fontStyle: FontStyle.italic)),
          ])),
        _policy('s2', Icons.grade, 'How Grades Affect SAP',
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _GRow('W / WF', 'Withdrawal', 'Attempted but NOT completed. Affects pace only.', Colors.orange),
            _GRow('I', 'Incomplete', 'Attempted but NOT completed. Treated as F for GPA — affects both standards.', Colors.red.shade600),
            _GRow('F / WF / R', 'Fail', 'Attempted but NOT completed. Hurts GPA and pace.', Colors.red.shade600),
            _GRow('AU / NA', 'Audit/Never Attend', 'NOT counted as attempted. No aid for audited or never-attended courses.', textGray),
            _GRow('Repeat', 'Repeat Course', 'Counted in attempted and earned. A passed course (D or better) may only be repeated once with aid.', Colors.orange),
            _GRow('CE', 'Credit by Exam', 'Counts for quantitative standards. No aid for CE credits.', Colors.orange),
            _GRow('Transfer', 'Transfer Credits', 'Count in attempted and completed. Reduces your maximum timeframe.', const Color(0xFF0277BD)),
            _GRow('IE / WE', 'COVID Emergency', 'NOT included in quantitative SAP calculation.', green),
          ])),
        _policy('s3', Icons.signal_cellular_alt, 'SAP Status Levels',
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _SRow('Satisfactory', 'Meets 2.0 GPA and 67% completion. Aid eligible.', green),
            _SRow('Warning', 'Failed SAP for the first time. May still receive aid this semester. Must meet SAP next term.', Colors.orange),
            _SRow('Suspension', 'Failed SAP a second consecutive time. NOT eligible for aid.', Colors.red.shade600),
            _SRow('Max Timeframe', 'Exceeded 150% of program credits. NOT eligible for aid.', Colors.red.shade700),
            _SRow('Probation', 'Successfully appealed. Eligible for ONE semester. Must meet SAP or appeal plan.', Colors.blue.shade700),
            _SRow('Continued Probation', 'Met appeal plan conditions. Eligible to continue receiving aid.', Colors.blue.shade400),
            _SRow('Termination', 'Failed to meet appeal plan. NOT eligible for aid.', Colors.red.shade900),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: navyLight, borderRadius: BorderRadius.circular(8)),
              child: const Text('RCC emails your SAP status after each term. Also check your Self-Service portal.',
                style: TextStyle(color: navy, fontSize: 11, height: 1.4))),
          ])),
        _policy('s4', Icons.restore, 'Regaining Financial Aid Eligibility',
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('If placed on Termination, you are immediately ineligible for aid.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12)),
            SizedBox(height: 8),
            Text('To regain eligibility:', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(height: 4),
            _Bul('Enroll and pay out-of-pocket until you meet the 2.0 GPA and 67% pace minimums, OR'),
            _Bul('Submit a new appeal with NEW documented extenuating circumstances (different from your original appeal)'),
            SizedBox(height: 6),
            Text('If approved, eligibility is reinstated on a probationary basis.', style: TextStyle(color: textGray, fontSize: 12, height: 1.4)),
          ])),
        _policy('s5', Icons.gavel, 'How to Appeal Your SAP Status',
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text('You have the right to appeal if you fail SAP. You must have DOCUMENTED circumstances BEYOND your control.',
              style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
            SizedBox(height: 10),
            Text('ACCEPTABLE:', style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(height: 4),
            _Bul('Medical illness or injury'),
            _Bul('Death of an immediate family member'),
            _Bul('Personal hardship affecting your physical, emotional, or mental health'),
            _Bul('Other unexpected events — car accident, military deployment, loss of transportation (must be documented)'),
            SizedBox(height: 10),
            Text('NOT ACCEPTABLE:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(height: 4),
            _Bul('Being young and irresponsible'),
            _Bul('"It was my first time in college"'),
            _Bul('Did not like or understand your instructor'),
            SizedBox(height: 8),
            Text('Circumstances must involve YOU or an IMMEDIATE family member only.',
              style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 12)),
            SizedBox(height: 10),
            Text('Appeal Steps:', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(height: 4),
            _Bul('Submit the SAP Appeal Request Form to the Financial Aid Office'),
            _Bul('Write a personal statement: (1) what happened and (2) what has changed so you can now meet SAP'),
            _Bul('Attach documentation: medical records, death certificate, police reports, court documents, notarized statements'),
            SizedBox(height: 10),
            Text('Appeal Deadlines:', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
            SizedBox(height: 4),
            _Bul('July 1 — Fall Semester'),
            _Bul('November 1 — Spring Semester'),
            _Bul('April 1 — Summer Semester'),
            SizedBox(height: 6),
            Text('Late appeals are reviewed for the next semester. Decisions are final and cannot be re-appealed.',
              style: TextStyle(color: textGray, fontSize: 11, fontStyle: FontStyle.italic, height: 1.4)),
          ])),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  final IconData icon; final String label, value;
  const _PolicyRow(this.icon, this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: green, size: 16), const SizedBox(width: 8),
      Expanded(child: RichText(text: TextSpan(children: [
        TextSpan(text: '$label — ', style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'Roboto')),
        TextSpan(text: value, style: const TextStyle(color: textGray, fontSize: 12, fontFamily: 'Roboto')),
      ]))),
    ]),
  );
}

class _GRow extends StatelessWidget {
  final String code, name, desc; final Color color;
  const _GRow(this.code, this.name, this.desc, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 4, height: 42, color: color, margin: const EdgeInsets.only(right: 10, top: 2)),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('$code — $name', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)),
        Text(desc, style: const TextStyle(color: textGray, fontSize: 11, height: 1.4)),
      ])),
    ]),
  );
}

class _SRow extends StatelessWidget {
  final String s, d; final Color c;
  const _SRow(this.s, this.d, this.c);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
        child: Text(s, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 10))),
      const SizedBox(width: 8),
      Expanded(child: Text(d, style: const TextStyle(color: textGray, fontSize: 11, height: 1.4))),
    ]),
  );
}

class _Bul extends StatelessWidget {
  final String text;
  const _Bul(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('• ', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
      Expanded(child: Text(text, style: const TextStyle(color: textGray, fontSize: 12, height: 1.4))),
    ]),
  );
}

// ═══════════════════════════════════════════
// AID SCREEN
// ═══════════════════════════════════════════
class AidScreen extends StatefulWidget {
  const AidScreen({super.key});
  @override State<AidScreen> createState() => _AidScreenState();
}

class _AidScreenState extends State<AidScreen> {
  final Set<String> _exp = {};
  void _tog(String k) => setState(() => _exp.contains(k) ? _exp.remove(k) : _exp.add(k));
  bool _open(String k) => _exp.contains(k);

  Widget _expand(String key, IconData icon, String title, Widget child) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: _open(key) ? navy : borderColor)),
    child: Column(children: [
      GestureDetector(
        onTap: () => _tog(key),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: _open(key) ? navyLight : Colors.white,
            borderRadius: _open(key) ? const BorderRadius.vertical(top: Radius.circular(11)) : BorderRadius.circular(11)),
          child: Row(children: [
            Icon(icon, color: navy, size: 18), const SizedBox(width: 10),
            Expanded(child: Text(title, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 13))),
            Icon(_open(key) ? Icons.expand_less : Icons.expand_more, color: navy),
          ]),
        ),
      ),
      if (_open(key)) Padding(padding: const EdgeInsets.fromLTRB(14,4,14,14), child: child),
    ]),
  );

  Widget _scholarTile(IconData icon, String title, String sub, String url) => GestureDetector(
    onTap: () => _web(url),
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: borderColor)),
      child: Row(children: [
        Container(width: 36, height: 36, decoration: BoxDecoration(color: navyLight, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, color: navy, size: 18)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(color: textGray, fontSize: 11, height: 1.3)),
          const SizedBox(height: 2),
          Text(url, style: const TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.w600)),
        ])),
        const Icon(Icons.open_in_new, color: green, size: 14),
      ]),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: navyLight,
    appBar: _appBar('Financial Aid', 'RCC Financial Aid Office — Building 13'),
    body: ListView(padding: const EdgeInsets.all(14), children: [

      // Contact banner
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('RCC Financial Aid Office', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          const _CRow(Icons.location_on, 'Building 13, Robeson Community College'),
          _CRow(Icons.phone, '(910) 272-3352', action: 'tel:9102723352'),
          _CRow(Icons.email, 'finaid@robeson.edu', action: 'mailto:finaid@robeson.edu'),
          const _CRow(Icons.access_time, 'Mon–Thu: 8am–6pm  |  Fri: 8am–3pm'),
          _CRow(Icons.language, 'www.robeson.edu/fa', action: 'https://www.robeson.edu/fa'),
          const SizedBox(height: 6),
          const Text('Text robesoncc to (910) 597-1920 to join the line', style: TextStyle(color: Colors.white60, fontSize: 11)),
        ]),
      ),

      // Quick actions
      Row(children: [
        Expanded(child: GestureDetector(onTap: () => _web('https://studentaid.gov/h/apply-for-aid/fafsa'), child: _QuickBtn(Icons.assignment_turned_in, 'Apply\n(FAFSA)', green))),
        const SizedBox(width: 8),
        Expanded(child: GestureDetector(onTap: () => _web('https://www.robeson.edu/fa'), child: _QuickBtn(Icons.search, 'Check\nStatus', navy))),
        const SizedBox(width: 8),
        Expanded(child: GestureDetector(onTap: () => _web('https://www.robeson.edu/fa'), child: _QuickBtn(Icons.upload_file, 'Submit\nDocs', const Color(0xFF0277BD)))),
      ]),
      const SizedBox(height: 14),

      // Steps
      _sectionLabel('STEPS TO APPLY'),
      _StepCard('1', 'Create Your FSA ID', 'Go to StudentAid.gov to create an FSA ID. This serves as your legal signature for the FAFSA. Dependent students — your parent must also create their own FSA ID.'),
      _StepCard('2', 'Complete the FAFSA Every Year', 'The FAFSA opens October 1st each year. Add RCC\'s school code: 008612. Allow 3-5 business days for processing.'),
      _StepCard('3', 'Submit All Documents ASAP', 'RCC will notify you via your RCC student email if additional documents are needed. Then check your status in your Self-Service portal.'),
      const SizedBox(height: 6),

      // Eligibility
      _expand('elig', Icons.checklist, 'Eligibility Requirements',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('To be eligible for federal and/or state aid, you must:', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 8),
          _Bul('Be a U.S. citizen or eligible non-citizen'),
          _Bul('Have a valid Social Security Number'),
          _Bul('Have a high school diploma, GED, or homeschool completion'),
          _Bul('Be enrolled in an eligible degree, diploma, or certificate program'),
          _Bul('Maintain Satisfactory Academic Progress (SAP)'),
          _Bul('Not owe a refund on a federal grant or be in default on a federal loan'),
          _Bul('Register with Selective Service (if applicable)'),
        ])),

      // Types of Aid
      _sectionLabel('TYPES OF AID'),
      _expand('pell', Icons.school, 'Federal Pell Grant',
        const Text('The Pell Grant is awarded to undergraduate students with exceptional financial need who have not earned a bachelor\'s degree. It does not have to be repaid. Apply by completing the FAFSA every year.',
          style: TextStyle(color: textGray, fontSize: 12, height: 1.5))),
      _expand('fseog', Icons.account_balance, 'Federal Supplemental Educational Opportunity Grant (FSEOG)',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('For undergraduate students with exceptional financial need. Priority to students with lowest Student Aid Index (SAI) who apply earliest. Students with bachelor\'s degrees are not eligible.',
            style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
          SizedBox(height: 8),
          Text('Award Amount: \$400 per year (Fall and Spring). May qualify for a summer award.', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
        ])),
      _expand('fws', Icons.work, 'Federal Work-Study',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Part-time jobs for students with financial need. Encourages community service work and work related to your course of study.',
            style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
          SizedBox(height: 8),
          _Bul('Must complete a FAFSA and be enrolled in at least 6 credit hours'),
          _Bul('Must maintain satisfactory academic progress and have financial need'),
          _Bul('May work an average of 15-20 hours per week'),
          SizedBox(height: 8),
          Text('Pay Rate: \$12.00/hr on-campus | \$12.50/hr off-campus', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
        ])),
      _expand('nextnc', Icons.star, 'Next NC Scholarship',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('NC residents enrolled in at least 6 credit hours who complete the FAFSA are guaranteed at least \$3,000 from combined federal and state aid.',
            style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
          SizedBox(height: 8),
          Text('Priority Filing Date: August 15 for NC Community Colleges.', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600, fontSize: 12)),
        ])),
      _expand('lcg', Icons.forest, 'Longleaf Commitment Grant (LCG)',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('For recent NC high school graduates attending NC community colleges with EFC from \$0-\$15,000.',
            style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
          SizedBox(height: 8),
          _Bul('NC high school graduate (2022 or 2023)'),
          _Bul('NC resident per Residency Determination Service'),
          _Bul('First-time college student, enrolled at least 6 credit hours'),
          SizedBox(height: 8),
          Text('Award: \$700-\$2,800 per year for up to 2 years.', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
        ])),
      _expand('vet', Icons.military_tech, 'Veterans Benefits',
        const Text('RCC accepts veterans education benefits including GI Bill and Yellow Ribbon. Contact the Financial Aid office or visit the Veterans Affairs section of the RCC website.',
          style: TextStyle(color: textGray, fontSize: 12, height: 1.5))),
      _expand('finish', Icons.flag, 'Finish Line Grant',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Grants of up to \$1,000 for students on the cusp of completing their program who face an unforeseen financial hardship.',
            style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
          SizedBox(height: 8),
          _Bul('Must be an unforeseen hardship — documentation required'),
          _Bul('Up to \$1,000 per student per semester — evaluated case-by-case'),
          _Bul('Minimum 2.0 GPA and must have completed at least 25% of your program'),
          SizedBox(height: 8),
          Text('Qualifying expenses: Rent, car repairs (in-person), books, utilities, childcare, bus passes, medical, internet.',
            style: TextStyle(color: textGray, fontSize: 12, height: 1.4)),
          SizedBox(height: 6),
          Text('Contact: (910) 272-3352 or finaid@robeson.edu', style: TextStyle(color: green, fontWeight: FontWeight.w600, fontSize: 12)),
        ])),
      _expand('wioa', Icons.people, 'LRDA / WIOA — Workforce Innovation & Opportunity Act',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Indian & Native American Program (Section 166) — funded by the U.S. Department of Labor. Eligible veterans and spouses receive priority service.',
            style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
          SizedBox(height: 8),
          Text('Eligibility:', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 4),
          _Bul('American Indian, Alaska Native, or Native Hawaiian'),
          _Bul('Unemployed, underemployed, or low-income'),
          _Bul('Reside in Robeson, Bladen, Hoke, or Scotland County'),
          SizedBox(height: 8),
          Text('WIOA Youth Services:', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 4),
          _Bul('In-School Youth: ages 14-21  |  Out-of-School Youth: ages 16-24'),
          _Bul('May assist with: Tuition, Books, Test Fees, Travel, Uniforms'),
          SizedBox(height: 6),
          Text('Youth Contact: Casandra Gales — (910) 827-2086', style: TextStyle(color: green, fontWeight: FontWeight.w600, fontSize: 12)),
          SizedBox(height: 8),
          Text('Robeson County: 636 Prospect Rd, Pembroke — (910) 521-9761', style: TextStyle(color: textGray, fontSize: 11)),
          Text('Hoke County: 22 West Elwood Ave, Raeford — (910) 875-5742', style: TextStyle(color: textGray, fontSize: 11)),
        ])),
      _expand('private', Icons.account_balance_wallet, 'Private Loans',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('RCC does NOT participate in the federal student loan program. Private loans are non-federal loans from banks, credit unions, or state agencies.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12)),
          SizedBox(height: 8),
          _Bul('Borrow only what you need — funds must be repaid'),
          _Bul('Most lenders require good credit and may require a co-signer'),
          _Bul('RCC does not maintain a preferred lender list'),
          _Bul('Have a valid FAFSA on file — RCC school code: 008612'),
          _Bul('Be enrolled in at least 6 credit hours'),
        ])),

      // Work-Study Employment
      _sectionLabel('WORK-STUDY EMPLOYMENT'),
      _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [Icon(Icons.campaign, color: green, size: 22), SizedBox(width: 8),
          Expanded(child: Text('Earn Money, Gain Experience, Network!!!', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 14)))]),
        const SizedBox(height: 10),
        const Text('Part-time jobs for students with financial need. Pay rate: \$12.00/hr for on-campus positions.',
          style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.shade200)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Icon(Icons.info_outline, color: Colors.orange, size: 18),
            SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('ALL POSITIONS HAVE BEEN FILLED AT THIS TIME', style: TextStyle(color: Color(0xFF6D4C00), fontWeight: FontWeight.bold, fontSize: 12)),
              SizedBox(height: 4),
              Text('Please check back and monitor your RCC student email for new announcements.', style: TextStyle(color: Color(0xFF6D4C00), fontSize: 11, height: 1.4)),
            ])),
          ])),
      ])),

      // Cost of Attendance
      _sectionLabel('COST OF ATTENDANCE 2025-2026'),
      _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('Nine-Month Budget — Full-Time Enrollment', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 13)),
        SizedBox(height: 10),
        _CoaRow('', 'Off-Campus', 'W/ Parent', isHeader: true),
        _CoaRow('Tuition & Fees (In-State)', '\$2,581', '\$2,581'),
        _CoaRow('Tuition & Fees (Out-of-State)', '\$8,725', '\$8,725'),
        _CoaRow('Books & Supplies', '\$1,400', '\$1,400'),
        _CoaRow('Living Expenses', '\$9,817', '\$1,472'),
        _CoaRow('Transportation', '\$2,000', '\$2,000'),
        _CoaRow('Miscellaneous & Personal', '\$6,363', '\$6,363'),
        Divider(),
        _CoaRow('IN-STATE TOTAL', '\$21,661', '\$13,816', isBold: true),
        _CoaRow('OUT-OF-STATE TOTAL', '\$28,305', '\$19,960', isBold: true),
        SizedBox(height: 8),
        Text('Budget resources: StudentAid.gov/Budget | YouTube: RCC Budget Video', style: TextStyle(color: green, fontSize: 11)),
      ])),

      // Spring 2026 Dates
      _sectionLabel('SPRING 2026 IMPORTANT DATES'),
      _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('Payment Deadlines', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
        SizedBox(height: 4),
        _DateRow('Class Start Jan 12', 'January 7, 2026'),
        _DateRow('Class Start Jan 27', 'January 22, 2026'),
        _DateRow('Class Start Feb 10', 'February 5, 2026'),
        _DateRow('Class Start Mar 16', 'March 11, 2026'),
        SizedBox(height: 10),
        Text('FA Refund Disbursements', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
        SizedBox(height: 4),
        _DateRow('Class Start Jan 12', 'February 13, 2026'),
        _DateRow('Class Start Jan 27', 'February 27, 2026'),
        _DateRow('Class Start Feb 10', 'March 13, 2026'),
        _DateRow('Class Start Mar 16', 'April 10, 2026'),
        SizedBox(height: 10),
        _DateRow('FA FREEZE DATE', 'January 30, 2026 — Lock in your schedule!'),
      ])),

      // FAQ
      _sectionLabel('FREQUENTLY ASKED QUESTIONS'),
      _expand('faq1', Icons.help_outline, 'What is a FAFSA?',
        const Text('The Free Application for Federal Student Aid (FAFSA) is the application for federal student aid including grants, work-study funds, and loans. Completing it is free and gives you access to the largest source of college financial aid available.',
          style: TextStyle(color: textGray, fontSize: 12, height: 1.5))),
      _expand('faq2', Icons.help_outline, 'What is RCC\'s school code?',
        const Text('RCC\'s federal school code is 008612. Enter this on your FAFSA so your information is sent directly to Robeson Community College.',
          style: TextStyle(color: textGray, fontSize: 12, height: 1.5))),
      _expand('faq3', Icons.help_outline, 'What documents do I need for the FAFSA?',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          _Bul('Your Social Security Number'),
          _Bul('Parents\' SSNs if you are a dependent student'),
          _Bul('Driver\'s license number, if you have one'),
          _Bul('Alien Registration number if not a U.S. citizen'),
          _Bul('Federal tax information and W-2 forms'),
          _Bul('Records of untaxed income, bank accounts, and investments'),
          SizedBox(height: 6),
          Text('Keep these records! Do NOT mail records to RCC.', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12)),
        ])),
      _expand('faq4', Icons.help_outline, 'Does financial aid pay for developmental coursework?',
        const Text('Financial aid will only pay for 30 credit hours of attempted developmental (remedial) coursework.',
          style: TextStyle(color: textGray, fontSize: 12, height: 1.5))),
      _expand('faq5', Icons.help_outline, 'Is there a limit to how long I can receive aid?',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          _Bul('Federal Pell Grant: 6 full-time years or 12 full-time semesters'),
          _Bul('NC Community College Grant: 10 full-time semesters'),
          _Bul('NC Education Lottery Grant: 10 full-time semesters'),
          SizedBox(height: 6),
          Text('You must also complete your program within 150% of its required credit hours.',
            style: TextStyle(color: textGray, fontSize: 12, height: 1.4)),
        ])),
      _expand('faq6', Icons.warning_amber_rounded, 'If I withdraw, do I have to return financial aid?',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
          Text('Ask yourself 3 questions:', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
          SizedBox(height: 6),
          Text('Q1: Did you stop attending a scheduled course?', style: TextStyle(color: navy, fontWeight: FontWeight.w600, fontSize: 12)),
          Text('If no → no return required. If yes → Q2.', style: TextStyle(color: textGray, fontSize: 12)),
          SizedBox(height: 6),
          Text('Q2: Were you still attending other courses?', style: TextStyle(color: navy, fontWeight: FontWeight.w600, fontSize: 12)),
          Text('If yes → not a withdrawal. If no → Q3.', style: TextStyle(color: textGray, fontSize: 12)),
          SizedBox(height: 6),
          Text('Q3: Did you confirm attendance in another registered course that term?', style: TextStyle(color: navy, fontWeight: FontWeight.w600, fontSize: 12)),
          Text('If yes → no return. If no → return calculation required.', style: TextStyle(color: textGray, fontSize: 12)),
          SizedBox(height: 8),
          Text('All unearned aid must be returned to the Dept of Education. Students cannot receive future aid until repaid.',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12, height: 1.4)),
        ])),

      // Meet the Staff
      _sectionLabel('MEET THE STAFF'),
      _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Students are assigned a financial aid specialist based on their last name.', style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
        const SizedBox(height: 12),
        _staffRow('Lopes, Zilma', 'Director of Financial Aid & Veteran Services'),
        _staffRow('Moore, Brittany', 'Financial Aid Specialist (Last Name: A – L) | Scholarship Coordinator'),
        _staffRow('Hunt, Jessie', 'Assistant Director of Financial Aid & Veteran Services'),
        _staffRow('Ellis, Keate', 'Financial Aid Specialist'),
        _staffRow('Salvador-Gonzalez, Abel', 'Financial Aid Consultant'),
        const SizedBox(height: 10),
        const Text('Contact', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 6),
        const _CRow(Icons.location_on, '5160 Fayetteville Rd, Lumberton, NC 28360 — Building 13'),
        _CRow(Icons.phone, '(910) 272-3352  |  Fax: (910) 272-3314', action: 'tel:9102723352'),
        _CRow(Icons.email, 'finaid@robeson.edu', action: 'mailto:finaid@robeson.edu'),
        const _CRow(Icons.access_time, 'Mon–Thu: 8am–6pm  |  Fri: 8am–3pm'),
      ])),

      // Scholarships
      _sectionLabel('SCHOLARSHIPS'),
      _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('Scholarship Opportunities', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 6),
        Text('There is an abundance of scholarships from internal and external agencies. RCC\'s Financial Aid Office urges you to take advantage of ALL scholarship opportunities available to you.',
          style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
        SizedBox(height: 4),
        Text('APPLY, APPLY, APPLY!', style: TextStyle(color: green, fontWeight: FontWeight.bold, fontSize: 14)),
      ])),
      const SizedBox(height: 8),
      _scholarTile(Icons.school, 'RCC Foundation Scholarship', 'Institutional scholarships for RCC students', 'www.robeson.edu/fa'),
      _scholarTile(Icons.star, 'College for North Carolina (CFNC)', 'Statewide scholarship search portal', 'www.cfnc.org'),
      _scholarTile(Icons.account_balance, 'Wells Fargo Technical Scholarship', 'For students in technical and vocational programs', 'www.wellsfargo.com'),
      _scholarTile(Icons.forest, 'Golden LEAF Scholarship', 'Priority to NC rural/tobacco-affected regions', 'www.goldenleaf.org'),
      _scholarTile(Icons.savings, 'SECU "People Helping People" Scholarship', 'State Employees Credit Union scholarship', 'www.ncsecu.org'),
      _scholarTile(Icons.military_tech, 'Military Scholarships', 'Click link then select VA Educational Benefits tab', 'www.benefits.va.gov'),
      _scholarTile(Icons.search, 'Fastweb', 'Free scholarship search — match your profile', 'www.fastweb.com'),
      _scholarTile(Icons.search, 'Scholarships.com', 'Comprehensive scholarship search database', 'www.scholarships.com'),
      _scholarTile(Icons.search, 'College Board Scholarship Search', 'Search 2,200+ scholarship programs', 'www.collegeboard.org'),
      _scholarTile(Icons.search, 'Sallie Mae Scholarships', 'Free scholarship search tool', 'www.salliemae.com'),
      _scholarTile(Icons.search, 'Fastweb', 'Free scholarship search tool', 'www.fastweb.com'),
      _scholarTile(Icons.local_hospital, 'NC CC Foundation — Health Careers', 'For students pursuing health careers', 'www.cfnc.org'),
      _scholarTile(Icons.menu_book, 'NC CC Foundation — Teacher Preparation', 'For students entering teaching', 'www.cfnc.org'),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Scholarship Coordinator', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          const Text('Mrs. Brittany Moore', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          GestureDetector(
            onTap: () => _call('9102723352'),
            child: const Text('(910) 272-3352', style: TextStyle(color: Color(0xFF90CAF9), fontSize: 12, decoration: TextDecoration.underline)),
          ),
          GestureDetector(
            onTap: () => _email('finaid@robeson.edu'),
            child: const Text('finaid@robeson.edu', style: TextStyle(color: Color(0xFF90CAF9), fontSize: 12, decoration: TextDecoration.underline)),
          ),
        ]),
      ),

      // Hablamos Espanol
      const SizedBox(height: 14),
      _sectionLabel('HABLAMOS ESPANOL'),
      _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text('Bienvenido a la Oficina de Ayuda Financiera', style: TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 13)),
        SizedBox(height: 6),
        Text('Su educación en Robeson Community College es una de las inversiones más valiosas que hará en su vida. La oficina de ayuda financiera está comprometida a ayudarle a encontrar maneras de financiar su educación.',
          style: TextStyle(color: textGray, fontSize: 12, height: 1.5)),
        SizedBox(height: 8),
        Text('Becas para Estudiantes Hispanos y Latinos:', style: TextStyle(color: navy, fontWeight: FontWeight.w600, fontSize: 12)),
        SizedBox(height: 4),
        Text('study.com/resources/becas-universitarias-para-estudiantes-hispanos-y-latinos', style: TextStyle(color: green, fontSize: 11)),
        SizedBox(height: 6),
        Text('Código de escuela de RCC para la FAFSA: 008612', style: TextStyle(color: textGray, fontSize: 12)),
      ])),

      const SizedBox(height: 20),
    ]),
  );

  Widget _staffRow(String name, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: navyLight, shape: BoxShape.circle),
        child: const Icon(Icons.person, color: navy, size: 18)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(title, style: const TextStyle(color: textGray, fontSize: 11, height: 1.3)),
      ])),
    ]),
  );
}

class _CRow extends StatelessWidget {
  final IconData icon; final String text; final String? action;
  const _CRow(this.icon, this.text, {this.action});
  @override
  Widget build(BuildContext context) {
    final widget = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, color: Colors.white70, size: 14), const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(
          color: action != null ? const Color(0xFF90CAF9) : Colors.white70,
          fontSize: 12,
          decoration: action != null ? TextDecoration.underline : null,
        ))),
      ]),
    );
    if (action == null) return widget;
    return GestureDetector(
      onTap: () {
        if (action!.startsWith('tel:')) _call(action!.replaceFirst('tel:', ''));
        else if (action!.startsWith('mailto:')) _email(action!.replaceFirst('mailto:', ''));
        else _web(action!);
      },
      child: widget,
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _QuickBtn(this.icon, this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white, size: 22), const SizedBox(height: 6),
      Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, height: 1.3)),
    ]),
  );
}

class _StepCard extends StatelessWidget {
  final String num, title, body;
  const _StepCard(this.num, this.title, this.body);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: borderColor)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 28, height: 28, decoration: const BoxDecoration(color: navy, shape: BoxShape.circle),
        child: Center(child: Text(num, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 4),
        Text(body, style: const TextStyle(color: textGray, fontSize: 12, height: 1.5)),
      ])),
    ]),
  );
}

class _CoaRow extends StatelessWidget {
  final String label, col1, col2; final bool isHeader, isBold;
  const _CoaRow(this.label, this.col1, this.col2, {this.isHeader=false, this.isBold=false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Expanded(child: Text(label, style: TextStyle(color: isHeader ? textGray : (isBold ? navy : textGray),
        fontSize: isHeader ? 10 : 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal))),
      SizedBox(width: 80, child: Text(col1, textAlign: TextAlign.center,
        style: TextStyle(color: isHeader ? textGray : navy, fontSize: isHeader ? 10 : 12,
          fontWeight: (isHeader||isBold) ? FontWeight.bold : FontWeight.normal))),
      SizedBox(width: 80, child: Text(col2, textAlign: TextAlign.center,
        style: TextStyle(color: isHeader ? textGray : navy, fontSize: isHeader ? 10 : 12,
          fontWeight: (isHeader||isBold) ? FontWeight.bold : FontWeight.normal))),
    ]),
  );
}

class _DateRow extends StatelessWidget {
  final String label, value;
  const _DateRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(color: textGray, fontSize: 11))),
      Text(value, style: const TextStyle(color: navy, fontWeight: FontWeight.bold, fontSize: 11)),
    ]),
  );
}
