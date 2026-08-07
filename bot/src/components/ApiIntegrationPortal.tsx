import React, { useState } from 'react';
import { Code, Terminal, Server, Play, Copy, Check, Zap, Cpu, Key, FileJson, Mail, Calendar, ShieldCheck, Smartphone } from 'lucide-react';

export const ApiIntegrationPortal: React.FC = () => {
  const [activeTab, setActiveTab] = useState<'flutter' | 'endpoints' | 'runner' | 'gemini' | 'sdk'>('flutter');
  const [copiedIndex, setCopiedIndex] = useState<number | null>(null);

  // Live API Runner state
  const [runnerEndpoint, setRunnerEndpoint] = useState<string>('/api/services');
  const [runnerMethod, setRunnerMethod] = useState<string>('GET');
  const [runnerBody, setRunnerBody] = useState<string>('{\n  "messages": [\n    {"sender": "user", "text": "What time slots are available for Highlights / Balayage tomorrow?"}\n  ]\n}');
  const [runnerResponse, setRunnerResponse] = useState<string | null>(null);
  const [runnerLoading, setRunnerLoading] = useState<boolean>(false);

  const flutterDartModelsCode = `// lib/models/salon_models.dart
import 'dart:convert';

class SalonService {
  final String id;
  final String name;
  final String category;
  final double price; // in AED
  final int durationMinutes;
  final String description;
  final String image;
  final String? recommendedFor;
  final bool popular;

  SalonService({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.durationMinutes,
    required this.description,
    required this.image,
    this.recommendedFor,
    this.popular = false,
  });

  factory SalonService.fromJson(Map<String, dynamic> json) {
    return SalonService(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] ?? 0,
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      recommendedFor: json['recommendedFor'],
      popular: json['popular'] ?? false,
    );
  }
}

class BookingRequest {
  final String clientName;
  final String clientEmail;
  final String clientPhone;
  final String serviceId;
  final String date; // YYYY-MM-DD
  final String time; // HH:mm (e.g., "09:00")
  final String stylistId;
  final String? notes;

  BookingRequest({
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
    required this.serviceId,
    required this.date,
    required this.time,
    required this.stylistId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'clientName': clientName,
    'clientEmail': clientEmail,
    'clientPhone': clientPhone,
    'serviceId': serviceId,
    'date': date,
    'time': time,
    'stylistId': stylistId,
    'notes': notes ?? '',
  };
}

class Appointment {
  final String id;
  final String confirmationCode;
  final String clientName;
  final String clientEmail;
  final String serviceName;
  final double servicePrice;
  final String date;
  final String time;
  final String stylistName;
  final String status;

  Appointment({
    required this.id,
    required this.confirmationCode,
    required this.clientName,
    required this.clientEmail,
    required this.serviceName,
    required this.servicePrice,
    required this.date,
    required this.time,
    required this.stylistName,
    required this.status,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      confirmationCode: json['confirmationCode'] ?? '',
      clientName: json['clientName'] ?? '',
      clientEmail: json['clientEmail'] ?? '',
      serviceName: json['serviceName'] ?? '',
      servicePrice: (json['servicePrice'] as num).toDouble(),
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      stylistName: json['stylistName'] ?? '',
      status: json['status'] ?? 'confirmed',
    );
  }
}`;

  const flutterApiServiceCode = `// lib/services/salon_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/salon_models.dart';

class SalonApiService {
  // Replace baseUrl with your server domain
  static const String baseUrl = 'https://ais-dev-yqahfckmk25pt6j7m2yl6g-613870659975.europe-west1.run.app';

  /// 1. Fetch Salon Services & AED Pricing Catalog
  static Future<List<SalonService>> getServices() async {
    final response = await http.get(Uri.parse('$baseUrl/api/services'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List servicesList = data['services'];
      return servicesList.map((s) => SalonService.fromJson(s)).toList();
    } else {
      throw Exception('Failed to load salon services catalog');
    }
  }

  /// 2. Check Real-Time Open Calendar Time Slots
  static Future<List<String>> checkAvailability({
    required String date,
    required String serviceId,
    String? stylistId,
  }) async {
    final query = 'date=$date&serviceId=$serviceId\${stylistId != null ? '&stylistId=$stylistId' : ''}';
    final response = await http.get(Uri.parse('$baseUrl/api/availability?$query'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<String>.from(data['availableSlots']);
    } else {
      throw Exception('Failed to check calendar availability');
    }
  }

  /// 3. Confirm Appointment Booking & Dispatch Email Confirmation
  static Future<Appointment> createBooking(BookingRequest booking) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(booking.toJson()),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Appointment.fromJson(data['appointment']);
    } else {
      throw Exception('Failed to create appointment');
    }
  }

  /// 4. Gemini AI Chatbot with Function Calling (Aura Concierge)
  static Future<Map<String, dynamic>> sendAiChatMessage(String userMessage) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'messages': [
          {'sender': 'user', 'text': userMessage}
        ]
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Contains 'reply', 'toolCalled', 'functionArgs'
    } else {
      throw Exception('AI Chatbot request failed');
    }
  }

  /// 5. Fetch User Appointments by Email
  static Future<List<Appointment>> getUserAppointments(String email) async {
    final response = await http.get(Uri.parse('$baseUrl/api/appointments?email=$email'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List list = data['appointments'];
      return list.map((a) => Appointment.fromJson(a)).toList();
    } else {
      throw Exception('Failed to fetch user appointments');
    }
  }
}`;

  const endpoints = [
    {
      name: 'AI Salon Concierge Chat (Gemini 3.6 Flash + Function Calling)',
      method: 'POST',
      path: '/api/chat',
      description: 'Send conversational queries to Aura AI. Automatically invokes function calls to check calendar availability, book sessions, or lookup client appointments.',
      sampleBody: `{
  "messages": [
    {
      "sender": "user",
      "text": "Book Highlights / Balayage for Layla Hassan tomorrow at 09:00 for Sarah (sarah@example.com)"
    }
  ]
}`
    },
    {
      name: 'Get Salon Services & Pricing',
      method: 'GET',
      path: '/api/services',
      description: 'Fetch complete catalog of treatments, pricing (in AED), duration in minutes, and recommended hair/skin profiles.',
      sampleBody: ''
    },
    {
      name: 'Check Real-Time Slot Availability',
      method: 'GET',
      path: '/api/availability?date=2026-05-15&serviceId=hair-1&stylistId=stylist-layla',
      description: 'Query live calendar matrix for open appointment slots filtered by date, service, or preferred stylist.',
      sampleBody: ''
    },
    {
      name: 'Create / Book Appointment',
      method: 'POST',
      path: '/api/appointments',
      description: 'Directly reserve an appointment slot on the calendar. Dispatches automated mail confirmations to client & staff.',
      sampleBody: `{
  "clientName": "Sarah Jenkins",
  "clientEmail": "sarah.jenkins@example.com",
  "clientPhone": "+971 50 123 4567",
  "serviceId": "hair-1",
  "date": "2026-05-15",
  "time": "09:00",
  "stylistId": "stylist-layla",
  "notes": "Prefers warm honey highlights."
}`
    },
    {
      name: 'Fetch Client Appointments',
      method: 'GET',
      path: '/api/appointments?email=sarah.jenkins@example.com',
      description: 'Retrieve all booked, completed, or cancelled appointments by email address or confirmation code.',
      sampleBody: ''
    },
    {
      name: 'Cancel or Reschedule Appointment',
      method: 'PUT',
      path: '/api/appointments/app-101',
      description: 'Update appointment status to "cancelled" or update preferred date/time. Automatically sends update emails.',
      sampleBody: `{
  "status": "cancelled",
  "date": "2026-05-16",
  "time": "14:00"
}`
    },
    {
      name: 'Download .ics iCalendar Sync File',
      method: 'GET',
      path: '/api/calendar/export-ics/VG-8821',
      description: 'Generates standard iCalendar (.ics) file stream for Apple Calendar, Google Calendar, and Outlook sync.',
      sampleBody: ''
    },
    {
      name: 'Trigger 24h & 2h Pre-Session Mail Reminders',
      method: 'POST',
      path: '/api/reminders/trigger',
      description: 'Background cron endpoint that checks upcoming bookings and sends automated 24h & 2h email reminders.',
      sampleBody: '{}'
    }
  ];

  const handleCopy = (text: string, index: number) => {
    navigator.clipboard.writeText(text);
    setCopiedIndex(index);
    setTimeout(() => setCopiedIndex(null), 2000);
  };

  const handleRunApi = async () => {
    setRunnerLoading(true);
    setRunnerResponse(null);
    try {
      const options: RequestInit = {
        method: runnerMethod,
        headers: { 'Content-Type': 'application/json' }
      };
      if (runnerMethod !== 'GET' && runnerMethod !== 'HEAD') {
        options.body = runnerBody;
      }

      const res = await fetch(runnerEndpoint, options);
      const data = await res.json();
      setRunnerResponse(JSON.stringify(data, null, 2));
    } catch (err: any) {
      setRunnerResponse(JSON.stringify({ error: err.message }, null, 2));
    } finally {
      setRunnerLoading(false);
    }
  };

  return (
    <div className="space-y-8 pb-12">
      
      {/* Portal Hero Banner */}
      <div className="bg-gradient-to-br from-stone-900 via-stone-950 to-stone-900 border border-stone-800 rounded-3xl p-8 shadow-2xl space-y-4">
        <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-rose-950 border border-rose-700/60 text-rose-300 text-xs font-semibold uppercase tracking-wider">
          <Smartphone className="w-3.5 h-3.5 text-amber-300" />
          <span>Flutter (Dart) App Backend & REST API Hub</span>
        </div>

        <h1 className="font-serif text-3xl sm:text-4xl text-rose-100 font-medium">
          Flutter Mobile Application Backend APIs & Dart SDK
        </h1>

        <p className="text-stone-300 text-xs sm:text-sm max-w-3xl leading-relaxed">
          Connect your custom **Flutter (iOS & Android) Mobile App** directly to this production Node.js/Express backend. Includes Dart data models, `http` client services, Gemini AI conversational scheduling, email confirmers, and calendar availability.
        </p>

        {/* Portal Navigation Tabs */}
        <div className="pt-2 flex flex-wrap gap-2">
          <button
            onClick={() => setActiveTab('flutter')}
            className={`px-4 py-2 rounded-xl text-xs font-medium flex items-center gap-2 transition-all ${
              activeTab === 'flutter'
                ? 'bg-rose-900 text-rose-100 border border-rose-600'
                : 'bg-stone-900 text-stone-400 hover:text-stone-200 border border-stone-800'
            }`}
          >
            <Smartphone className="w-4 h-4 text-rose-300" />
            <span>Flutter (Dart) Integration Code</span>
          </button>

          <button
            onClick={() => setActiveTab('endpoints')}
            className={`px-4 py-2 rounded-xl text-xs font-medium flex items-center gap-2 transition-all ${
              activeTab === 'endpoints'
                ? 'bg-rose-900 text-rose-100 border border-rose-600'
                : 'bg-stone-900 text-stone-400 hover:text-stone-200 border border-stone-800'
            }`}
          >
            <Server className="w-4 h-4 text-rose-400" />
            <span>API Directory</span>
          </button>

          <button
            onClick={() => setActiveTab('runner')}
            className={`px-4 py-2 rounded-xl text-xs font-medium flex items-center gap-2 transition-all ${
              activeTab === 'runner'
                ? 'bg-rose-900 text-rose-100 border border-rose-600'
                : 'bg-stone-900 text-stone-400 hover:text-stone-200 border border-stone-800'
            }`}
          >
            <Play className="w-4 h-4 text-amber-400" />
            <span>Live API Playground</span>
          </button>

          <button
            onClick={() => setActiveTab('gemini')}
            className={`px-4 py-2 rounded-xl text-xs font-medium flex items-center gap-2 transition-all ${
              activeTab === 'gemini'
                ? 'bg-rose-900 text-rose-100 border border-rose-600'
                : 'bg-stone-900 text-stone-400 hover:text-stone-200 border border-stone-800'
            }`}
          >
            <Cpu className="w-4 h-4 text-rose-300" />
            <span>Gemini AI Tools</span>
          </button>
        </div>
      </div>

      {/* TAB 1: FLUTTER (DART) INTEGRATION CODE */}
      {activeTab === 'flutter' && (
        <div className="space-y-6">
          <div className="bg-stone-900 border border-stone-800 rounded-2xl p-6 space-y-4">
            <h2 className="font-serif text-xl text-rose-100 font-medium flex items-center gap-2">
              <Smartphone className="w-5 h-5 text-rose-400" />
              <span>1. Dart Data Models (Copy into `lib/models/salon_models.dart`)</span>
            </h2>
            <div className="flex justify-end">
              <button
                onClick={() => handleCopy(flutterDartModelsCode, 101)}
                className="px-3 py-1.5 rounded-xl bg-stone-800 hover:bg-stone-700 text-amber-300 text-xs font-medium flex items-center gap-1.5 border border-stone-700"
              >
                {copiedIndex === 101 ? <Check className="w-4 h-4 text-emerald-400" /> : <Copy className="w-4 h-4" />}
                <span>{copiedIndex === 101 ? 'Copied Dart Models!' : 'Copy Dart Models'}</span>
              </button>
            </div>
            <pre className="p-4 bg-stone-950 rounded-2xl border border-stone-800 text-xs font-mono text-stone-200 max-h-[400px] overflow-y-auto">
              {flutterDartModelsCode}
            </pre>
          </div>

          <div className="bg-stone-900 border border-stone-800 rounded-2xl p-6 space-y-4">
            <h2 className="font-serif text-xl text-rose-100 font-medium flex items-center gap-2">
              <Zap className="w-5 h-5 text-amber-400" />
              <span>2. Flutter API Service (Copy into `lib/services/salon_api_service.dart`)</span>
            </h2>
            <div className="flex justify-end">
              <button
                onClick={() => handleCopy(flutterApiServiceCode, 102)}
                className="px-3 py-1.5 rounded-xl bg-stone-800 hover:bg-stone-700 text-amber-300 text-xs font-medium flex items-center gap-1.5 border border-stone-700"
              >
                {copiedIndex === 102 ? <Check className="w-4 h-4 text-emerald-400" /> : <Copy className="w-4 h-4" />}
                <span>{copiedIndex === 102 ? 'Copied Flutter Service!' : 'Copy Flutter Service'}</span>
              </button>
            </div>
            <pre className="p-4 bg-stone-950 rounded-2xl border border-stone-800 text-xs font-mono text-emerald-300 max-h-[450px] overflow-y-auto">
              {flutterApiServiceCode}
            </pre>
          </div>
        </div>
      )}

      {/* TAB 2: API ENDPOINTS */}
      {activeTab === 'endpoints' && (
        <div className="space-y-4">
          <h2 className="font-serif text-xl text-rose-100 font-medium">REST API Directory</h2>
          <div className="grid grid-cols-1 gap-4">
            {endpoints.map((ep, idx) => (
              <div key={idx} className="bg-stone-900 border border-stone-800 rounded-2xl p-5 space-y-3 shadow-lg">
                <div className="flex flex-wrap items-center justify-between gap-2 border-b border-stone-800 pb-3">
                  <div className="flex items-center gap-2.5">
                    <span className={`px-2.5 py-1 rounded-lg text-[10px] font-mono font-bold uppercase ${
                      ep.method === 'GET' ? 'bg-emerald-950 text-emerald-300 border border-emerald-800' :
                      ep.method === 'POST' ? 'bg-rose-950 text-rose-300 border border-rose-800' :
                      'bg-amber-950 text-amber-300 border border-amber-800'
                    }`}>
                      {ep.method}
                    </span>
                    <span className="font-mono text-xs text-rose-200 font-bold">{ep.path}</span>
                  </div>

                  <button
                    onClick={() => {
                      setRunnerEndpoint(ep.path.split('?')[0]);
                      setRunnerMethod(ep.method);
                      if (ep.sampleBody) setRunnerBody(ep.sampleBody);
                      setActiveTab('runner');
                    }}
                    className="px-3 py-1 rounded-xl bg-stone-800 hover:bg-stone-700 text-amber-300 text-[11px] font-medium flex items-center gap-1 border border-stone-700"
                  >
                    <Play className="w-3 h-3" />
                    <span>Test Endpoint</span>
                  </button>
                </div>

                <p className="text-xs text-stone-300">{ep.description}</p>

                {ep.sampleBody && (
                  <div className="space-y-1">
                    <span className="text-[10px] text-stone-500 font-mono">Sample Request Payload:</span>
                    <pre className="p-3 bg-stone-950 rounded-xl text-[11px] font-mono text-amber-200 border border-stone-800 overflow-x-auto">
                      {ep.sampleBody}
                    </pre>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      )}

      {/* TAB 3: LIVE API RUNNER */}
      {activeTab === 'runner' && (
        <div className="bg-stone-900 border border-stone-800 rounded-3xl p-6 shadow-xl space-y-6">
          <div className="border-b border-stone-800 pb-4">
            <h2 className="font-serif text-xl text-rose-100 font-medium flex items-center gap-2">
              <Play className="w-5 h-5 text-amber-400" />
              <span>Interactive API Tester</span>
            </h2>
            <p className="text-xs text-stone-400 mt-0.5">
              Execute live REST API calls against the active server and inspect formatted JSON responses.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-3">
            <select
              value={runnerMethod}
              onChange={(e) => setRunnerMethod(e.target.value)}
              className="bg-stone-950 border border-stone-800 rounded-xl px-3 py-2.5 text-xs text-rose-300 font-mono font-bold"
            >
              <option value="GET">GET</option>
              <option value="POST">POST</option>
              <option value="PUT">PUT</option>
            </select>

            <input
              type="text"
              value={runnerEndpoint}
              onChange={(e) => setRunnerEndpoint(e.target.value)}
              placeholder="/api/services"
              className="md:col-span-2 bg-stone-950 border border-stone-800 rounded-xl px-4 py-2.5 text-xs text-stone-200 font-mono"
            />

            <button
              onClick={handleRunApi}
              disabled={runnerLoading}
              className="py-2.5 px-4 rounded-xl bg-gradient-to-r from-rose-600 to-amber-600 hover:from-rose-500 hover:to-amber-500 text-white text-xs font-semibold flex items-center justify-center gap-2 shadow-lg disabled:opacity-50"
            >
              <Zap className="w-4 h-4" />
              <span>{runnerLoading ? 'Executing...' : 'Send Request'}</span>
            </button>
          </div>

          {runnerMethod !== 'GET' && (
            <div className="space-y-1">
              <label className="text-xs text-stone-400">Request Body (JSON)</label>
              <textarea
                rows={5}
                value={runnerBody}
                onChange={(e) => setRunnerBody(e.target.value)}
                className="w-full bg-stone-950 border border-stone-800 rounded-xl p-3 font-mono text-xs text-amber-300 focus:outline-none focus:border-rose-600"
              />
            </div>
          )}

          <div className="space-y-2">
            <label className="text-xs text-stone-400 font-medium">Server Response Payload</label>
            <pre className="p-4 bg-stone-950 rounded-2xl border border-stone-800 text-xs font-mono text-emerald-300 min-h-[160px] max-h-[350px] overflow-y-auto">
              {runnerResponse ? runnerResponse : '// Response JSON will render here after execution...'}
            </pre>
          </div>
        </div>
      )}

      {/* TAB 4: GEMINI TOOL DECLARATIONS */}
      {activeTab === 'gemini' && (
        <div className="space-y-4">
          <h2 className="font-serif text-xl text-rose-100 font-medium">Gemini 3.6 Flash Tool Declarations</h2>
          <p className="text-xs text-stone-400">
            These FunctionDeclarations are passed to `@google/genai` on every chatbot request, enabling AI tool execution.
          </p>

          <div className="grid grid-cols-1 gap-4">
            <div className="bg-stone-900 border border-stone-800 rounded-2xl p-5 space-y-2">
              <h3 className="font-mono text-sm text-rose-200 font-bold">1. getSalonServices</h3>
              <p className="text-xs text-stone-400">Retrieves treatment catalog, prices in AED, and duration.</p>
            </div>

            <div className="bg-stone-900 border border-stone-800 rounded-2xl p-5 space-y-2">
              <h3 className="font-mono text-sm text-rose-200 font-bold">2. checkAvailability</h3>
              <p className="text-xs text-stone-400">Checks open calendar time slots for any date and optional specialist.</p>
            </div>

            <div className="bg-stone-900 border border-stone-800 rounded-2xl p-5 space-y-2">
              <h3 className="font-mono text-sm text-rose-200 font-bold">3. bookAppointment</h3>
              <p className="text-xs text-stone-400">Reserves calendar slot, issues confirmation code, and triggers email notices.</p>
            </div>

            <div className="bg-stone-900 border border-stone-800 rounded-2xl p-5 space-y-2">
              <h3 className="font-mono text-sm text-rose-200 font-bold">4. cancelOrRescheduleAppointment</h3>
              <p className="text-xs text-stone-400">Cancels or reschedules existing appointments dynamically via AI.</p>
            </div>
          </div>
        </div>
      )}

    </div>
  );
};
