export interface SalonService {
  id: string;
  name: string;
  category: 'hair' | 'skincare' | 'nails' | 'lashes' | 'spa';
  price: number;
  durationMinutes: number;
  description: string;
  popular?: boolean;
  image: string;
  recommendedFor?: string;
}

export interface Stylist {
  id: string;
  name: string;
  role: string;
  avatar: string;
  rating: number;
  specialties: string[];
}

export interface TimeSlot {
  time: string; // e.g. "10:00 AM"
  available: boolean;
  stylistId?: string;
}

export interface Appointment {
  id: string;
  confirmationCode: string;
  clientName: string;
  clientEmail: string;
  clientPhone: string;
  serviceId: string;
  serviceName: string;
  servicePrice: number;
  durationMinutes: number;
  stylistId: string;
  stylistName: string;
  date: string; // YYYY-MM-DD
  time: string; // e.g. "02:00 PM"
  status: 'confirmed' | 'completed' | 'cancelled' | 'rescheduled';
  notes?: string;
  createdAt: string;
  reminderSent24h?: boolean;
  reminderSent2h?: boolean;
}

export interface EmailNotification {
  id: string;
  appointmentId: string;
  recipientType: 'client' | 'staff';
  to: string;
  subject: string;
  type: 'booking_confirmation' | 'reminder_24h' | 'reminder_2h' | 'cancellation' | 'reschedule';
  bodyHtml: string;
  sentAt: string;
  read?: boolean;
}

export interface ChatMessage {
  id: string;
  sender: 'user' | 'bot' | 'system';
  text: string;
  timestamp: string;
  suggestedAction?: {
    type: 'select_slot' | 'view_services' | 'confirm_booking' | 'view_appointment';
    data?: any;
  };
  cardData?: {
    service?: SalonService;
    slots?: TimeSlot[];
    appointment?: Appointment;
  };
}
