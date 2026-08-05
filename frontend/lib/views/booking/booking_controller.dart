import 'package:belle_beauty_salon/constant/app_routes.dart';
import 'package:belle_beauty_salon/models/service_model.dart';
import 'package:belle_beauty_salon/views/home/home_controller/main_controller.dart';
import 'package:get/get.dart';

class BookingController extends GetxController {
  ServiceModel? service;

  var selectedDate = Rx<DateTime?>(null);
  var selectedTime = ''.obs;
  var appointmentsTabIndex = 0.obs;

  static const _months = [
    'Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec',
  ];
  static const _days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];

  final Map<String, List<Map<String, dynamic>>> timeSlots = {
    'Morning': [
      {'time': '09:00', 'available': true},
      {'time': '09:30', 'available': true},
      {'time': '10:00', 'available': true},
      {'time': '10:30', 'available': false},
      {'time': '11:00', 'available': false},
      {'time': '11:30', 'available': true},
    ],
    'Afternoon': [
      {'time': '12:00', 'available': true},
      {'time': '13:00', 'available': true},
      {'time': '13:30', 'available': false},
      {'time': '14:00', 'available': true},
      {'time': '15:00', 'available': true},
      {'time': '15:30', 'available': true},
    ],
    'Evening': [
      {'time': '16:00', 'available': true},
      {'time': '17:00', 'available': false},
      {'time': '18:00', 'available': true},
      {'time': '18:30', 'available': true},
      {'time': '19:00', 'available': true},
      {'time': '19:30', 'available': true},
    ],
  };

  var upcomingAppointments = <Map<String, dynamic>>[
    {
      'serviceName': 'Bridal Makeup',
      'specialist': 'Noor Al-Sayed',
      'image': 'assets/images/scancare.jpg',
      'date': 'May 16',
      'time': '09:30',
      'status': 'UPCOMING',
    },
    {
      'serviceName': 'Highlights / Balayage',
      'specialist': 'Layla Hassan',
      'image': 'assets/images/hair_section.webp',
      'date': 'May 15',
      'time': '14:30',
      'status': 'UPCOMING',
    },
    {
      'serviceName': 'Signature Facial',
      'specialist': 'Sofia Reyes',
      'image': 'assets/images/potoks.jpg',
      'date': 'May 18',
      'time': '11:00',
      'status': 'UPCOMING',
    },
  ].obs;

  var pastAppointments = <Map<String, dynamic>>[
    {
      'serviceName': 'Gel Manicure',
      'specialist': 'Maya Karim',
      'image': 'assets/images/Nails_1.jpg',
      'date': 'May 5',
      'time': '16:00',
      'status': 'PAST',
    },
  ].obs;

  var cancelledAppointments = <Map<String, dynamic>>[
    {
      'serviceName': 'Bridal Makeup',
      'specialist': 'Noor Al-Sayed',
      'image': 'assets/images/scancare.jpg',
      'date': 'May 16',
      'time': '09:30',
      'status': 'CANCELLED',
    },
  ].obs;

  void startBooking(ServiceModel s) {
    service = s;
    selectedDate.value = null;
    selectedTime.value = '';
    Get.toNamed(AppRoutes.selectDate, arguments: s);
  }

  void onDateSelected(DateTime date) => selectedDate.value = date;
  void onTimeSelected(String time) => selectedTime.value = time;

  void goToSelectTime() {
    if (selectedDate.value == null) return;
    Get.toNamed(AppRoutes.selectTime);
  }

  void goToSummary() {
    if (selectedTime.value.isEmpty) return;
    Get.toNamed(AppRoutes.bookingSummary);
  }

  void confirmBooking() {
    if (service == null) return;
    final d = selectedDate.value;
    final dateStr = d != null ? '${_months[d.month - 1]} ${d.day}' : 'N/A';
    upcomingAppointments.insert(0, {
      'serviceName': service!.serviceName,
      'specialist': service!.specialist.name,
      'image': service!.image,
      'date': dateStr,
      'time': selectedTime.value,
      'status': 'UPCOMING',
    });
    Get.toNamed(AppRoutes.bookingConfirmed);
  }

  void cancelAppointment(int index) {
    final apt = Map<String, dynamic>.from(upcomingAppointments[index]);
    upcomingAppointments.removeAt(index);
    apt['status'] = 'CANCELLED';
    cancelledAppointments.insert(0, apt);
  }

  void goHome() {
    Get.until((route) => route.isFirst);
    Get.find<MainController>().changePage(0);
  }

  void viewBooking() {
    Get.until((route) => route.isFirst);
    Get.find<MainController>().changePage(1);
  }

  String dayAbbrev(DateTime d) => _days[d.weekday - 1];
  String monthAbbrev(DateTime d) => _months[d.month - 1];

  String get formattedSelectedDate {
    final d = selectedDate.value;
    if (d == null) return '';
    return '${_days[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';
  }

  String get confirmedDateLabel {
    final d = selectedDate.value;
    if (d == null) return '';
    return '${_days[d.weekday - 1]}, ${_months[d.month - 1]} ${d.day}';
  }

  String get bookingSubtitle {
    if (service == null) return '';
    return '$formattedSelectedDate · ${service!.duration} · with ${service!.specialist.name}';
  }

  int get earnedPoints {
    if (service == null) return 0;
    return (service!.price / 10).round();
  }
}
