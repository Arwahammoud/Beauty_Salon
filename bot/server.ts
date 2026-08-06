import express from 'express';
import path from 'path';
import { createServer as createViteServer } from 'vite';
import { GoogleGenAI, FunctionDeclaration, Type } from '@google/genai';
import { SALON_SERVICES, SALON_STYLISTS, DEFAULT_TIME_SLOTS } from './src/data/salonData';
import { Appointment, EmailNotification, TimeSlot } from './src/types';

const app = express();
const PORT = 3000;

app.use(express.json());

// In-memory persistent database for appointments & outgoing notifications
let appointmentsStore: Appointment[] = [
  {
    id: 'app-101',
    confirmationCode: 'VG-8821',
    clientName: 'Sarah Jenkins',
    clientEmail: 'sarah.jenkins@example.com',
    clientPhone: '+1 (555) 234-5678',
    serviceId: 'hair-1',
    serviceName: 'Signature Balayage & Gloss',
    servicePrice: 220,
    durationMinutes: 120,
    stylistId: 'stylist-1',
    stylistName: 'Elena Rostova',
    date: new Date(Date.now() + 86400000).toISOString().split('T')[0], // Tomorrow
    time: '01:30 PM',
    status: 'confirmed',
    notes: 'Prefers warm golden honey tones.',
    createdAt: new Date().toISOString(),
    reminderSent24h: true,
    reminderSent2h: false
  },
  {
    id: 'app-102',
    confirmationCode: 'VG-9430',
    clientName: 'Jessica Taylor',
    clientEmail: 'jessica.t@example.com',
    clientPhone: '+1 (555) 876-5432',
    serviceId: 'skin-1',
    serviceName: 'Velvet HydraFacial Glow',
    servicePrice: 165,
    durationMinutes: 60,
    stylistId: 'stylist-2',
    stylistName: 'Sophia Chen',
    date: new Date(Date.now() + 172800000).toISOString().split('T')[0], // In 2 days
    time: '10:30 AM',
    status: 'confirmed',
    notes: 'Sensitive skin preparation requested.',
    createdAt: new Date().toISOString(),
    reminderSent24h: false,
    reminderSent2h: false
  }
];

let notificationsStore: EmailNotification[] = [
  {
    id: 'notif-1',
    appointmentId: 'app-101',
    recipientType: 'client',
    to: 'sarah.jenkins@example.com',
    subject: '✨ Booking Confirmation: Signature Balayage with Elena Rostova',
    type: 'booking_confirmation',
    bodyHtml: `
      <div style="font-family: sans-serif; max-width: 600px; padding: 24px; border: 1px solid #f3e8ee; border-radius: 12px; background-color: #fff;">
        <h2 style="color: #9f1239; margin-top: 0;">Velvet & Glow Salon</h2>
        <p>Dear Sarah Jenkins,</p>
        <p>Your appointment for <strong>Signature Balayage & Gloss</strong> with <strong>Elena Rostova</strong> has been confirmed!</p>
        <div style="background-color: #fdf2f8; padding: 16px; border-radius: 8px; margin: 16px 0;">
          <p style="margin: 4px 0;"><strong>Confirmation Code:</strong> VG-8821</p>
          <p style="margin: 4px 0;"><strong>Date:</strong> ${new Date(Date.now() + 86400000).toLocaleDateString('en-US', { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' })}</p>
          <p style="margin: 4px 0;"><strong>Time:</strong> 01:30 PM</p>
          <p style="margin: 4px 0;"><strong>Price:</strong> $220</p>
        </div>
        <p>We look forward to pampering you! Please arrive 10 minutes prior to your session.</p>
        <hr style="border: none; border-top: 1px solid #eee; margin: 20px 0;" />
        <small style="color: #666;">Velvet & Glow Salon | 742 Evergreen Terrace, Suite 4B | +1 (800) 555-GLOW</small>
      </div>
    `,
    sentAt: new Date().toISOString()
  }
];

// Helper to create automated email confirmation notification
function createNotification(
  appointment: Appointment,
  type: EmailNotification['type'],
  recipientType: 'client' | 'staff' = 'client'
) {
  const isClient = recipientType === 'client';
  const to = isClient ? appointment.clientEmail : 'bookings@velvetandglow.com';
  
  let subject = '';
  if (type === 'booking_confirmation') {
    subject = isClient 
      ? `✨ Confirmed: ${appointment.serviceName} at Velvet & Glow Salon (${appointment.confirmationCode})`
      : `📅 New Booking Alert: ${appointment.clientName} for ${appointment.serviceName}`;
  } else if (type === 'reminder_24h') {
    subject = `⏰ Reminder: Your salon session is tomorrow at ${appointment.time}!`;
  } else if (type === 'reminder_2h') {
    subject = `💄 Salon Alert: Your appointment starts in 2 hours (${appointment.time})`;
  } else if (type === 'cancellation') {
    subject = `❌ Cancellation Notice: ${appointment.serviceName} (${appointment.confirmationCode})`;
  } else if (type === 'reschedule') {
    subject = `🔄 Rescheduled: ${appointment.serviceName} is now set for ${appointment.date} at ${appointment.time}`;
  }

  const formattedDate = new Date(appointment.date + 'T12:00:00').toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  });

  const bodyHtml = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; color: #27272a; padding: 24px; border: 1px solid #f43f5e; border-radius: 12px; background: #fff;">
      <div style="text-align: center; margin-bottom: 20px;">
        <h1 style="color: #be123c; font-size: 24px; margin: 0; font-family: Georgia, serif;">Velvet & Glow Salon</h1>
        <p style="color: #9f1239; font-size: 13px; text-transform: uppercase; letter-spacing: 2px;">Luxury Hair & Beauty Sanctuary</p>
      </div>

      <p style="font-size: 16px; line-height: 1.5;">Hello ${isClient ? appointment.clientName : 'Velvet & Glow Salon Team'},</p>
      
      <p style="font-size: 15px; line-height: 1.5;">
        ${type === 'booking_confirmation' ? 'Thank you for booking with us! Here are your appointment details:' : ''}
        ${type === 'reminder_24h' ? 'This is a friendly 24-hour reminder for your upcoming session.' : ''}
        ${type === 'reminder_2h' ? 'Your appointment starts in 2 hours! Our team is ready to welcome you.' : ''}
        ${type === 'cancellation' ? 'Your appointment has been successfully cancelled as requested.' : ''}
        ${type === 'reschedule' ? 'Your appointment has been updated to your new preferred time slot.' : ''}
      </p>

      <div style="background-color: #fff1f2; border-left: 4px solid #f43f5e; padding: 18px; border-radius: 6px; margin: 20px 0;">
        <table style="width: 100%; font-size: 14px; border-collapse: collapse;">
          <tr><td style="padding: 4px 0; color: #881337;"><strong>Confirmation Code:</strong></td><td style="padding: 4px 0; text-align: right; font-weight: bold;">${appointment.confirmationCode}</td></tr>
          <tr><td style="padding: 4px 0; color: #881337;"><strong>Service:</strong></td><td style="padding: 4px 0; text-align: right;">${appointment.serviceName}</td></tr>
          <tr><td style="padding: 4px 0; color: #881337;"><strong>Stylist:</strong></td><td style="padding: 4px 0; text-align: right;">${appointment.stylistName}</td></tr>
          <tr><td style="padding: 4px 0; color: #881337;"><strong>Date & Time:</strong></td><td style="padding: 4px 0; text-align: right;"><strong>${formattedDate} at ${appointment.time}</strong></td></tr>
          <tr><td style="padding: 4px 0; color: #881337;"><strong>Total Price:</strong></td><td style="padding: 4px 0; text-align: right; color: #be123c; font-weight: bold;">$${appointment.servicePrice}</td></tr>
        </table>
      </div>

      <div style="background: #fafafa; padding: 14px; border-radius: 8px; font-size: 13px; color: #52525b; margin-bottom: 20px;">
        <p style="margin: 0 0 6px 0;">📍 <strong>Location:</strong> 742 Evergreen Terrace, Suite 4B, Beverly Hills</p>
        <p style="margin: 0 0 6px 0;">📞 <strong>Phone:</strong> +1 (800) 555-GLOW</p>
        <p style="margin: 0;">💡 <strong>Stylist Note:</strong> Please arrive 10 minutes early to enjoy our herbal tea infusion bar.</p>
      </div>

      <hr style="border: none; border-top: 1px solid #f1f5f9; margin: 24px 0;" />
      <p style="font-size: 12px; color: #a1a1aa; text-align: center; margin: 0;">Automated confirmation sent by Velvet & Glow Salon Intelligent Scheduling System.</p>
    </div>
  `;

  const notif: EmailNotification = {
    id: 'notif-' + Date.now() + '-' + Math.random().toString(36).substring(2, 6),
    appointmentId: appointment.id,
    recipientType,
    to,
    subject,
    type,
    bodyHtml,
    sentAt: new Date().toISOString()
  };

  notificationsStore.unshift(notif);
  return notif;
}

// Check availability function for date & stylist
function getSlotsForDateAndStylist(date: string, serviceId?: string, stylistId?: string): TimeSlot[] {
  const existingOnDate = appointmentsStore.filter(a => a.date === date && a.status === 'confirmed');
  
  return DEFAULT_TIME_SLOTS.map(time => {
    let booked = false;
    if (stylistId) {
      booked = existingOnDate.some(a => a.time === time && a.stylistId === stylistId);
    } else {
      // If no specific stylist requested, check if at least one stylist is free
      const bookedStylists = existingOnDate.filter(a => a.time === time).map(a => a.stylistId);
      booked = bookedStylists.length >= SALON_STYLISTS.length;
    }
    return {
      time,
      available: !booked,
      stylistId: stylistId || SALON_STYLISTS[0].id
    };
  });
}

// Initialize Gemini API
const genAI = new GoogleGenAI({
  apiKey: process.env.GEMINI_API_KEY,
  httpOptions: {
    headers: {
      'User-Agent': 'aistudio-build'
    }
  }
});

// Define tools for Gemini function calling
const getSalonServicesTool: FunctionDeclaration = {
  name: 'getSalonServices',
  description: 'Retrieve the list of beauty salon services, pricing, duration, and descriptions. Optionally filter by category.',
  parameters: {
    type: Type.OBJECT,
    properties: {
      category: {
        type: Type.STRING,
        description: 'Optional category filter: hair, skincare, nails, lashes, spa'
      }
    }
  }
};

const checkAvailabilityTool: FunctionDeclaration = {
  name: 'checkAvailability',
  description: 'Check available appointment time slots for a given date and optional service or stylist.',
  parameters: {
    type: Type.OBJECT,
    properties: {
      date: {
        type: Type.STRING,
        description: 'Date in YYYY-MM-DD format (e.g., 2026-08-07)'
      },
      serviceId: {
        type: Type.STRING,
        description: 'Optional service ID'
      },
      stylistId: {
        type: Type.STRING,
        description: 'Optional stylist ID'
      }
    },
    required: ['date']
  }
};

const bookAppointmentTool: FunctionDeclaration = {
  name: 'bookAppointment',
  description: 'Book a salon session directly. Reserves the calendar slot and automatically triggers confirmation emails.',
  parameters: {
    type: Type.OBJECT,
    properties: {
      clientName: { type: Type.STRING, description: 'Client full name' },
      clientEmail: { type: Type.STRING, description: 'Client email address' },
      clientPhone: { type: Type.STRING, description: 'Client phone number' },
      serviceId: { type: Type.STRING, description: 'Service ID to book' },
      date: { type: Type.STRING, description: 'Date YYYY-MM-DD' },
      time: { type: Type.STRING, description: 'Time string e.g. 02:00 PM' },
      stylistId: { type: Type.STRING, description: 'Optional stylist ID' },
      notes: { type: Type.STRING, description: 'Special client requests' }
    },
    required: ['clientName', 'clientEmail', 'serviceId', 'date', 'time']
  }
};

const getUpcomingAppointmentsTool: FunctionDeclaration = {
  name: 'getUpcomingAppointments',
  description: 'Look up existing client appointments by email address or confirmation code.',
  parameters: {
    type: Type.OBJECT,
    properties: {
      clientEmail: { type: Type.STRING, description: 'Client email or confirmation code' }
    },
    required: ['clientEmail']
  }
};

const cancelOrRescheduleAppointmentTool: FunctionDeclaration = {
  name: 'cancelOrRescheduleAppointment',
  description: 'Cancel or reschedule an existing appointment.',
  parameters: {
    type: Type.OBJECT,
    properties: {
      appointmentId: { type: Type.STRING, description: 'Appointment ID or confirmation code' },
      action: { type: Type.STRING, description: 'cancel or reschedule' },
      newDate: { type: Type.STRING, description: 'New date YYYY-MM-DD if rescheduling' },
      newTime: { type: Type.STRING, description: 'New time string if rescheduling' }
    },
    required: ['appointmentId', 'action']
  }
};

// Tool execution handler
async function executeToolCall(name: string, args: any) {
  if (name === 'getSalonServices') {
    const category = args?.category?.toLowerCase();
    if (category) {
      return SALON_SERVICES.filter(s => s.category.toLowerCase() === category);
    }
    return SALON_SERVICES;
  }

  if (name === 'checkAvailability') {
    const date = args.date;
    const slots = getSlotsForDateAndStylist(date, args.serviceId, args.stylistId);
    return {
      date,
      availableSlots: slots.filter(s => s.available).map(s => s.time),
      allSlots: slots
    };
  }

  if (name === 'bookAppointment') {
    const { clientName, clientEmail, clientPhone, serviceId, date, time, stylistId, notes } = args;
    const service = SALON_SERVICES.find(s => s.id === serviceId) || SALON_SERVICES[0];
    const stylist = SALON_STYLISTS.find(s => s.id === stylistId) || SALON_STYLISTS[0];
    
    const code = 'VG-' + Math.floor(1000 + Math.random() * 9000);
    const newAppointment: Appointment = {
      id: 'app-' + Date.now(),
      confirmationCode: code,
      clientName,
      clientEmail,
      clientPhone: clientPhone || '+1 (555) 000-GLOW',
      serviceId: service.id,
      serviceName: service.name,
      servicePrice: service.price,
      durationMinutes: service.durationMinutes,
      stylistId: stylist.id,
      stylistName: stylist.name,
      date,
      time,
      status: 'confirmed',
      notes: notes || '',
      createdAt: new Date().toISOString()
    };

    appointmentsStore.unshift(newAppointment);

    // Send automatic mail confirmations to client & staff
    createNotification(newAppointment, 'booking_confirmation', 'client');
    createNotification(newAppointment, 'booking_confirmation', 'staff');

    return {
      success: true,
      appointment: newAppointment,
      message: `Appointment ${code} confirmed for ${service.name} with ${stylist.name} on ${date} at ${time}. Confirmation email sent to ${clientEmail}.`
    };
  }

  if (name === 'getUpcomingAppointments') {
    const query = args.clientEmail?.toLowerCase() || '';
    const matches = appointmentsStore.filter(a => 
      a.clientEmail.toLowerCase().includes(query) || 
      a.confirmationCode.toLowerCase().includes(query) ||
      a.clientName.toLowerCase().includes(query)
    );
    return matches;
  }

  if (name === 'cancelOrRescheduleAppointment') {
    const { appointmentId, action, newDate, newTime } = args;
    const appt = appointmentsStore.find(a => 
      a.id === appointmentId || a.confirmationCode.toLowerCase() === appointmentId.toLowerCase()
    );

    if (!appt) {
      return { success: false, message: `Appointment ${appointmentId} not found.` };
    }

    if (action === 'cancel') {
      appt.status = 'cancelled';
      createNotification(appt, 'cancellation', 'client');
      return { success: true, message: `Appointment ${appt.confirmationCode} has been cancelled and confirmation sent.` };
    } else if (action === 'reschedule' && newDate && newTime) {
      appt.date = newDate;
      appt.time = newTime;
      appt.status = 'confirmed';
      createNotification(appt, 'reschedule', 'client');
      return { success: true, message: `Appointment ${appt.confirmationCode} rescheduled to ${newDate} at ${newTime}. Updated confirmation sent.` };
    }

    return { success: false, message: 'Invalid action or missing new date/time.' };
  }

  return { error: 'Unknown tool' };
}

// REST API Endpoints

// 1. Services API
app.get('/api/services', (req, res) => {
  res.json({ services: SALON_SERVICES });
});

// 2. Stylists API
app.get('/api/stylists', (req, res) => {
  res.json({ stylists: SALON_STYLISTS });
});

// 3. Appointments API
app.get('/api/appointments', (req, res) => {
  const { date, email } = req.query;
  let result = [...appointmentsStore];
  if (date) {
    result = result.filter(a => a.date === date);
  }
  if (email) {
    const e = (email as string).toLowerCase();
    result = result.filter(a => a.clientEmail.toLowerCase() === e);
  }
  res.json({ appointments: result });
});

app.post('/api/appointments', (req, res) => {
  const { clientName, clientEmail, clientPhone, serviceId, date, time, stylistId, notes } = req.body;
  const service = SALON_SERVICES.find(s => s.id === serviceId) || SALON_SERVICES[0];
  const stylist = SALON_STYLISTS.find(s => s.id === stylistId) || SALON_STYLISTS[0];

  const code = 'VG-' + Math.floor(1000 + Math.random() * 9000);
  const newAppt: Appointment = {
    id: 'app-' + Date.now(),
    confirmationCode: code,
    clientName,
    clientEmail,
    clientPhone: clientPhone || '+1 (555) 000-0000',
    serviceId: service.id,
    serviceName: service.name,
    servicePrice: service.price,
    durationMinutes: service.durationMinutes,
    stylistId: stylist.id,
    stylistName: stylist.name,
    date,
    time,
    status: 'confirmed',
    notes: notes || '',
    createdAt: new Date().toISOString()
  };

  appointmentsStore.unshift(newAppt);
  createNotification(newAppt, 'booking_confirmation', 'client');
  createNotification(newAppt, 'booking_confirmation', 'staff');

  res.json({ success: true, appointment: newAppt });
});

app.put('/api/appointments/:id', (req, res) => {
  const { id } = req.params;
  const { status, date, time } = req.body;
  const appt = appointmentsStore.find(a => a.id === id || a.confirmationCode === id);

  if (!appt) {
    return res.status(404).json({ error: 'Appointment not found' });
  }

  if (status) appt.status = status;
  if (date) appt.date = date;
  if (time) appt.time = time;

  if (status === 'cancelled') {
    createNotification(appt, 'cancellation', 'client');
  } else if (date || time) {
    createNotification(appt, 'reschedule', 'client');
  }

  res.json({ success: true, appointment: appt });
});

// 4. Slots availability API
app.get('/api/availability', (req, res) => {
  const { date, serviceId, stylistId } = req.query;
  const targetDate = (date as string) || new Date().toISOString().split('T')[0];
  const slots = getSlotsForDateAndStylist(targetDate, serviceId as string, stylistId as string);
  res.json({ date: targetDate, slots });
});

// 5. Notifications & Mail Log API
app.get('/api/notifications', (req, res) => {
  res.json({ notifications: notificationsStore });
});

// 6. Trigger automated pre-appointment reminders endpoint
app.post('/api/reminders/trigger', (req, res) => {
  let triggeredCount = 0;
  const now = new Date();

  appointmentsStore.forEach(appt => {
    if (appt.status !== 'confirmed') return;

    const apptDateTime = new Date(`${appt.date}T${appt.time}`);
    const hoursDiff = (apptDateTime.getTime() - now.getTime()) / (1000 * 60 * 60);

    // Send 24h reminder if within 24h and not sent yet
    if (hoursDiff > 0 && hoursDiff <= 24 && !appt.reminderSent24h) {
      createNotification(appt, 'reminder_24h', 'client');
      appt.reminderSent24h = true;
      triggeredCount++;
    }

    // Send 2h reminder if within 2h and not sent yet
    if (hoursDiff > 0 && hoursDiff <= 3 && !appt.reminderSent2h) {
      createNotification(appt, 'reminder_2h', 'client');
      appt.reminderSent2h = true;
      triggeredCount++;
    }
  });

  res.json({ success: true, triggeredCount, notifications: notificationsStore });
});

// 7. Download `.ics` iCalendar file route
app.get('/api/calendar/export-ics/:id', (req, res) => {
  const { id } = req.params;
  const appt = appointmentsStore.find(a => a.id === id || a.confirmationCode === id);

  if (!appt) {
    return res.status(404).send('Appointment not found');
  }

  const icsContent = `BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Velvet and Glow Salon//NONSGML v1.0//EN
METHOD:REQUEST
BEGIN:VEVENT
UID:${appt.id}@velvetandglow.com
DTSTAMP:${new Date().toISOString().replace(/[-:]/g, '').split('.')[0]}Z
DTSTART:${appt.date.replace(/-/g, '')}T140000Z
DTEND:${appt.date.replace(/-/g, '')}T153000Z
SUMMARY:Velvet & Glow Salon: ${appt.serviceName}
DESCRIPTION:Session with ${appt.stylistName}. Confirmation Code: ${appt.confirmationCode}.
LOCATION:Velvet & Glow Salon, 742 Evergreen Terrace, Beverly Hills
STATUS:CONFIRMED
END:VEVENT
END:VCALENDAR`;

  res.setHeader('Content-Type', 'text/calendar');
  res.setHeader('Content-Disposition', `attachment; filename="${appt.confirmationCode}.ics"`);
  res.send(icsContent);
});

// 8. AI Chatbot API with Gemini Function Calling
app.post('/api/chat', async (req, res) => {
  try {
    const { messages, userContext } = req.body;
    
    // Format conversation history
    const systemInstruction = `You are 'Aura', the intelligent, warm, and sophisticated AI Assistant for Velvet & Glow Luxury Salon & Spa.
Your goals:
1. Enthusiastically help clients discover salon services, compare hair/skincare treatments, pricing ($), and durations.
2. Help users check real-time availability and book appointment slots automatically using tools.
3. Help users look up, reschedule, or cancel existing bookings.
4. Always maintain a luxurious, polite, and reassuring tone.
5. Today's date is ${new Date().toISOString().split('T')[0]}.

You have access to salon scheduling tools:
- getSalonServices
- checkAvailability
- bookAppointment
- getUpcomingAppointments
- cancelOrRescheduleAppointment

When a user asks to book or check time slots, use your tools! When you book an appointment, inform the user that an automated mail confirmation has been dispatched to their email address and will show up in their notifications.`;

    const formattedContents = messages.map((m: any) => ({
      role: m.sender === 'user' ? 'user' : 'model',
      parts: [{ text: m.text }]
    }));

    // First request to Gemini with tools
    let response = await genAI.models.generateContent({
      model: 'gemini-3.6-flash',
      contents: formattedContents,
      config: {
        systemInstruction,
        tools: [
          {
            functionDeclarations: [
              getSalonServicesTool,
              checkAvailabilityTool,
              bookAppointmentTool,
              getUpcomingAppointmentsTool,
              cancelOrRescheduleAppointmentTool
            ]
          }
        ]
      }
    });

    let toolExecutedResult: any = null;
    let cardDataPayload: any = null;

    // Check if Gemini invoked function calls
    const functionCalls = response.functionCalls;
    if (functionCalls && functionCalls.length > 0) {
      const fc = functionCalls[0];
      const toolName = fc.name;
      const toolArgs = fc.args;

      toolExecutedResult = await executeToolCall(toolName, toolArgs);

      // Extract visual card payloads for rich frontend chat widgets
      if (toolName === 'getSalonServices' && Array.isArray(toolExecutedResult)) {
        cardDataPayload = { service: toolExecutedResult[0] };
      } else if (toolName === 'checkAvailability') {
        cardDataPayload = { slots: toolExecutedResult.allSlots };
      } else if (toolName === 'bookAppointment' && toolExecutedResult?.appointment) {
        cardDataPayload = { appointment: toolExecutedResult.appointment };
      }

      // Append model response & function response back to Gemini for final output
      const secondTurnContents = [
        ...formattedContents,
        response.candidates?.[0]?.content,
        {
          role: 'user',
          parts: [
            {
              functionResponse: {
                name: toolName,
                response: toolExecutedResult
              }
            }
          ]
        }
      ];

      const followUpResponse = await genAI.models.generateContent({
        model: 'gemini-3.6-flash',
        contents: secondTurnContents,
        config: { systemInstruction }
      });

      res.json({
        reply: followUpResponse.text || 'Your salon request has been processed successfully.',
        toolExecuted: toolName,
        cardData: cardDataPayload
      });
    } else {
      res.json({
        reply: response.text || 'How can I assist you with your salon experience today?',
        cardData: null
      });
    }
  } catch (err: any) {
    console.error('Chat API error:', err);
    res.status(500).json({
      reply: "I'm having a brief moment synchronizing with our salon schedule. How else can I assist you?",
      error: err.message
    });
  }
});

// Start Express + Vite dev / prod server
async function startServer() {
  if (process.env.NODE_ENV !== 'production') {
    const vite = await createViteServer({
      server: { middlewareMode: true },
      appType: 'spa'
    });
    app.use(vite.middlewares);
  } else {
    const distPath = path.join(process.cwd(), 'dist');
    app.use(express.static(distPath));
    app.get('*', (req, res) => {
      res.sendFile(path.join(distPath, 'index.html'));
    });
  }

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`✨ Velvet & Glow Salon Server running on http://0.0.0.0:${PORT}`);
  });
}

startServer();
