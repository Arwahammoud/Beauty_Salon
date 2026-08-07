import React, { useState, useEffect } from 'react';
import { SalonService, Stylist, Appointment, EmailNotification } from './types';
import { SALON_SERVICES, SALON_STYLISTS } from './data/salonData';
import { Header } from './components/Header';
import { SalonServices } from './components/SalonServices';
import { ChatBot } from './components/ChatBot';
import { BookingWizard } from './components/BookingWizard';
import { CalendarView } from './components/CalendarView';
import { NotificationsModal } from './components/NotificationsModal';
import { MyAppointments } from './components/MyAppointments';
import { MobileDesignFlowSimulator } from './components/MobileDesignFlowSimulator';
import { ApiIntegrationPortal } from './components/ApiIntegrationPortal';
import { Scissors } from 'lucide-react';

export default function App() {
  const [activeTab, setActiveTab] = useState<'explore' | 'mobile_flow' | 'api_portal' | 'calendar' | 'appointments' | 'notifications'>('mobile_flow');
  const [services, setServices] = useState<SalonService[]>(SALON_SERVICES);
  const [stylists, setStylists] = useState<Stylist[]>(SALON_STYLISTS);
  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [notifications, setNotifications] = useState<EmailNotification[]>([]);
  
  const [isChatOpen, setIsChatOpen] = useState<boolean>(false);
  const [chatInitialQuery, setChatInitialQuery] = useState<string>('');
  
  const [isBookingModalOpen, setIsBookingModalOpen] = useState<boolean>(false);
  const [preSelectedService, setPreSelectedService] = useState<SalonService | null>(null);
  
  const [isAdminMode, setIsAdminMode] = useState<boolean>(false);

  // Fetch initial appointments and notifications
  const refreshData = () => {
    fetch('/api/appointments')
      .then(res => res.json())
      .then(data => {
        if (data.appointments) setAppointments(data.appointments);
      })
      .catch(err => console.error(err));

    fetch('/api/notifications')
      .then(res => res.json())
      .then(data => {
        if (data.notifications) setNotifications(data.notifications);
      })
      .catch(err => console.error(err));
  };

  useEffect(() => {
    refreshData();
  }, []);

  const handleSelectServiceToBook = (service: SalonService) => {
    setPreSelectedService(service);
    setIsBookingModalOpen(true);
  };

  const handleAskChatBot = (query: string) => {
    setChatInitialQuery(query);
    setIsChatOpen(true);
  };

  const handleBookingComplete = (newAppt: Appointment) => {
    refreshData();
  };

  const handleCancelAppointment = async (id: string) => {
    try {
      const res = await fetch(`/api/appointments/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: 'cancelled' })
      });
      if (res.ok) {
        refreshData();
      }
    } catch (err) {
      console.error(err);
    }
  };

  const upcomingCount = appointments.filter(a => a.status === 'confirmed').length;

  return (
    <div className="min-h-screen bg-stone-950 text-stone-100 font-sans selection:bg-rose-900 selection:text-rose-100 flex flex-col">
      
      {/* Top Navigation Header */}
      <Header
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        unreadNotificationsCount={notifications.length}
        upcomingCount={upcomingCount}
        isChatOpen={isChatOpen}
        setIsChatOpen={setIsChatOpen}
        isAdminMode={isAdminMode}
        setIsAdminMode={setIsAdminMode}
        onBookClick={() => {
          setPreSelectedService(null);
          setIsBookingModalOpen(true);
        }}
      />

      {/* Main Body Canvas */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 pt-8">
        {activeTab === 'explore' && (
          <SalonServices
            services={services}
            stylists={stylists}
            onSelectService={handleSelectServiceToBook}
            onAskChatBot={handleAskChatBot}
          />
        )}

        {activeTab === 'mobile_flow' && (
          <MobileDesignFlowSimulator
            onBookingCreated={(newAppt) => {
              refreshData();
            }}
          />
        )}

        {activeTab === 'api_portal' && (
          <ApiIntegrationPortal />
        )}

        {activeTab === 'calendar' && (
          <CalendarView
            appointments={appointments}
            isAdminMode={isAdminMode}
            onBookSlot={(date, time, stylistId) => {
              setPreSelectedService(null);
              setIsBookingModalOpen(true);
            }}
          />
        )}

        {activeTab === 'appointments' && (
          <MyAppointments
            appointments={appointments}
            onReschedule={(id) => {}}
            onCancel={handleCancelAppointment}
            onRefresh={refreshData}
          />
        )}

        {activeTab === 'notifications' && (
          <NotificationsModal
            notifications={notifications}
            onRefreshNotifications={refreshData}
          />
        )}
      </main>

      {/* Floating AI ChatBot Concierge */}
      <ChatBot
        isOpen={isChatOpen}
        onClose={() => setIsChatOpen(false)}
        onDirectBook={(serviceId, date, time) => {
          setIsBookingModalOpen(true);
        }}
        onViewNotifications={() => setActiveTab('notifications')}
        onViewAppointments={() => setActiveTab('appointments')}
        initialQuery={chatInitialQuery}
      />

      {/* Step-by-Step Interactive Booking Wizard Modal */}
      <BookingWizard
        isOpen={isBookingModalOpen}
        onClose={() => setIsBookingModalOpen(false)}
        preSelectedService={preSelectedService}
        onBookingComplete={handleBookingComplete}
        onViewNotifications={() => {
          setIsBookingModalOpen(false);
          setActiveTab('notifications');
        }}
      />

      {/* Footer */}
      <footer className="mt-auto border-t border-rose-900/30 bg-stone-900/80 py-8 text-center text-xs text-stone-500 space-y-2">
        <div className="flex items-center justify-center gap-2 text-rose-300 font-serif text-sm">
          <Scissors className="w-4 h-4 text-rose-400" />
          <span>Velvet & Glow Salon Sanctuary</span>
        </div>
        <p>Powered by Gemini AI Intelligent Scheduling & Real-Time Calendar Synchronization.</p>
        <p className="text-[10px] text-stone-600">Beverly Hills &bull; +1 (800) 555-GLOW &bull; bookings@velvetandglow.com</p>
      </footer>

    </div>
  );
}
