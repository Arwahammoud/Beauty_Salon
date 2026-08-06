import React, { useState, useEffect } from 'react';
import { SalonService, Stylist, TimeSlot, Appointment } from '../types';
import { SALON_SERVICES, SALON_STYLISTS } from '../data/salonData';
import { X, Check, Calendar as CalendarIcon, Clock, User, Mail, Phone, Sparkles, Download, CheckCircle2, ChevronRight, ChevronLeft } from 'lucide-react';

interface BookingWizardProps {
  isOpen: boolean;
  onClose: () => void;
  preSelectedService?: SalonService | null;
  onBookingComplete: (newAppt: Appointment) => void;
  onViewNotifications: () => void;
}

export const BookingWizard: React.FC<BookingWizardProps> = ({
  isOpen,
  onClose,
  preSelectedService,
  onBookingComplete,
  onViewNotifications
}) => {
  const [step, setStep] = useState<number>(1);
  
  // Selection States
  const [selectedService, setSelectedService] = useState<SalonService | null>(null);
  const [selectedStylist, setSelectedStylist] = useState<Stylist | null>(null);
  const [selectedDate, setSelectedDate] = useState<string>(
    new Date(Date.now() + 86400000).toISOString().split('T')[0]
  );
  const [selectedTime, setSelectedTime] = useState<string>('');
  const [clientName, setClientName] = useState<string>('');
  const [clientEmail, setClientEmail] = useState<string>('');
  const [clientPhone, setClientPhone] = useState<string>('');
  const [notes, setNotes] = useState<string>('');

  // Slots loading
  const [availableSlots, setAvailableSlots] = useState<TimeSlot[]>([]);
  const [loadingSlots, setLoadingSlots] = useState<boolean>(false);
  const [submitting, setSubmitting] = useState<boolean>(false);
  const [confirmedAppt, setConfirmedAppt] = useState<Appointment | null>(null);

  useEffect(() => {
    if (preSelectedService) {
      setSelectedService(preSelectedService);
      setStep(2);
    } else {
      setSelectedService(SALON_SERVICES[0]);
    }
    setSelectedStylist(SALON_STYLISTS[0]);
  }, [preSelectedService, isOpen]);

  // Fetch available slots when date or stylist changes
  useEffect(() => {
    if (!selectedDate) return;
    setLoadingSlots(true);
    fetch(`/api/availability?date=${selectedDate}&serviceId=${selectedService?.id || ''}&stylistId=${selectedStylist?.id || ''}`)
      .then(res => res.json())
      .then(data => {
        setAvailableSlots(data.slots || []);
        if (data.slots && data.slots.some((s: TimeSlot) => s.available)) {
          const firstAvailable = data.slots.find((s: TimeSlot) => s.available);
          if (firstAvailable) setSelectedTime(firstAvailable.time);
        }
      })
      .catch(err => console.error(err))
      .finally(() => setLoadingSlots(false));
  }, [selectedDate, selectedStylist, selectedService]);

  const handleSubmitBooking = async () => {
    if (!selectedService || !selectedDate || !selectedTime || !clientName || !clientEmail) {
      return;
    }

    setSubmitting(true);
    try {
      const res = await fetch('/api/appointments', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          clientName,
          clientEmail,
          clientPhone,
          serviceId: selectedService.id,
          date: selectedDate,
          time: selectedTime,
          stylistId: selectedStylist?.id || SALON_STYLISTS[0].id,
          notes
        })
      });

      const data = await res.json();
      if (data.success && data.appointment) {
        setConfirmedAppt(data.appointment);
        onBookingComplete(data.appointment);
        setStep(5); // Confirmation step
      }
    } catch (err) {
      console.error("Booking error:", err);
    } finally {
      setSubmitting(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4 overflow-y-auto animate-in fade-in duration-200">
      <div className="bg-stone-900 border border-rose-900/60 rounded-3xl w-full max-w-2xl overflow-hidden shadow-2xl text-stone-100 my-8">
        
        {/* Header */}
        <div className="bg-gradient-to-r from-stone-950 via-rose-950 to-stone-950 p-6 border-b border-rose-900/40 flex items-center justify-between">
          <div>
            <span className="text-[11px] font-sans uppercase tracking-widest text-rose-300">
              Interactive Session Scheduler
            </span>
            <h2 className="font-serif text-2xl text-rose-100 font-medium">
              {step === 5 ? 'Booking Confirmed!' : 'Reserve Your Salon Experience'}
            </h2>
          </div>
          <button
            onClick={onClose}
            className="p-2 rounded-full text-stone-400 hover:text-white hover:bg-stone-800 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Wizard Progress Stepper */}
        {step < 5 && (
          <div className="px-6 py-3 bg-stone-950 border-b border-stone-800 flex items-center justify-between text-xs text-stone-400">
            <span className={step >= 1 ? 'text-rose-300 font-semibold' : ''}>1. Service</span>
            <ChevronRight className="w-3.5 h-3.5 text-stone-600" />
            <span className={step >= 2 ? 'text-rose-300 font-semibold' : ''}>2. Specialist</span>
            <ChevronRight className="w-3.5 h-3.5 text-stone-600" />
            <span className={step >= 3 ? 'text-rose-300 font-semibold' : ''}>3. Date & Time</span>
            <ChevronRight className="w-3.5 h-3.5 text-stone-600" />
            <span className={step >= 4 ? 'text-rose-300 font-semibold' : ''}>4. Client Details</span>
          </div>
        )}

        {/* Step Content */}
        <div className="p-6 space-y-6">

          {/* STEP 1: Select Service */}
          {step === 1 && (
            <div className="space-y-4">
              <h3 className="font-serif text-lg text-rose-100">Step 1: Choose Your Treatment</h3>
              <div className="grid grid-cols-1 gap-3 max-h-96 overflow-y-auto pr-1">
                {SALON_SERVICES.map(service => (
                  <div
                    key={service.id}
                    onClick={() => setSelectedService(service)}
                    className={`p-4 rounded-2xl border cursor-pointer transition-all flex items-center justify-between ${
                      selectedService?.id === service.id
                        ? 'bg-rose-950/80 border-rose-600 ring-2 ring-rose-500/30'
                        : 'bg-stone-950/60 border-stone-800 hover:border-stone-700'
                    }`}
                  >
                    <div className="flex items-center gap-4">
                      <img src={service.image} alt={service.name} className="w-14 h-14 rounded-xl object-cover" />
                      <div>
                        <h4 className="font-serif text-sm text-rose-100 font-medium">{service.name}</h4>
                        <p className="text-xs text-stone-400 line-clamp-1">{service.description}</p>
                        <span className="text-[11px] text-rose-300 flex items-center gap-1 mt-1">
                          <Clock className="w-3 h-3 text-rose-400" /> {service.durationMinutes} minutes
                        </span>
                      </div>
                    </div>
                    <div className="text-right">
                      <span className="font-serif text-lg font-bold text-amber-300">${service.price}</span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* STEP 2: Select Specialist */}
          {step === 2 && (
            <div className="space-y-4">
              <h3 className="font-serif text-lg text-rose-100">Step 2: Choose Your Stylist or Specialist</h3>
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                {SALON_STYLISTS.map(stylist => (
                  <div
                    key={stylist.id}
                    onClick={() => setSelectedStylist(stylist)}
                    className={`p-4 rounded-2xl border cursor-pointer transition-all flex items-center gap-4 ${
                      selectedStylist?.id === stylist.id
                        ? 'bg-rose-950/80 border-rose-600 ring-2 ring-rose-500/30'
                        : 'bg-stone-950/60 border-stone-800 hover:border-stone-700'
                    }`}
                  >
                    <img src={stylist.avatar} alt={stylist.name} className="w-12 h-12 rounded-full object-cover border border-rose-900" />
                    <div>
                      <h4 className="font-serif text-sm text-rose-100 font-medium">{stylist.name}</h4>
                      <p className="text-xs text-rose-300">{stylist.role}</p>
                      <p className="text-[10px] text-stone-400">Rating: ★ {stylist.rating}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* STEP 3: Select Date & Time */}
          {step === 3 && (
            <div className="space-y-5">
              <h3 className="font-serif text-lg text-rose-100">Step 3: Select Date & Real-Time Time Slot</h3>
              
              <div className="space-y-2">
                <label className="text-xs text-stone-300 flex items-center gap-1">
                  <CalendarIcon className="w-3.5 h-3.5 text-rose-400" />
                  Select Date
                </label>
                <input
                  type="date"
                  min={new Date().toISOString().split('T')[0]}
                  value={selectedDate}
                  onChange={(e) => setSelectedDate(e.target.value)}
                  className="w-full bg-stone-950 border border-stone-800 rounded-xl px-4 py-2.5 text-xs text-stone-200 focus:outline-none focus:border-rose-600"
                />
              </div>

              <div className="space-y-2">
                <label className="text-xs text-stone-300 flex items-center gap-1">
                  <Clock className="w-3.5 h-3.5 text-amber-400" />
                  Available Appointment Slots on {selectedDate}
                </label>
                
                {loadingSlots ? (
                  <div className="p-4 text-center text-xs text-stone-400">Checking live salon calendar...</div>
                ) : (
                  <div className="grid grid-cols-3 sm:grid-cols-4 gap-2">
                    {availableSlots.map((slot, idx) => (
                      <button
                        key={idx}
                        disabled={!slot.available}
                        onClick={() => setSelectedTime(slot.time)}
                        className={`py-2.5 px-3 rounded-xl text-xs font-medium transition-all ${
                          !slot.available
                            ? 'bg-stone-950 text-stone-600 border border-stone-800/50 line-through cursor-not-allowed'
                            : selectedTime === slot.time
                            ? 'bg-rose-900 text-rose-100 border border-rose-500 shadow-lg'
                            : 'bg-stone-950 text-stone-300 hover:bg-rose-950/60 border border-stone-800'
                        }`}
                      >
                        {slot.time}
                      </button>
                    ))}
                  </div>
                )}
              </div>
            </div>
          )}

          {/* STEP 4: Client Contact Details */}
          {step === 4 && (
            <div className="space-y-4">
              <h3 className="font-serif text-lg text-rose-100">Step 4: Contact & Confirmation Email Address</h3>
              <p className="text-xs text-stone-400">Automated mail confirmations and reminder notifications will be sent to this email address.</p>

              <div className="space-y-3">
                <div>
                  <label className="text-xs text-stone-300 block mb-1">Full Name *</label>
                  <input
                    type="text"
                    required
                    value={clientName}
                    onChange={(e) => setClientName(e.target.value)}
                    placeholder="e.g. Sarah Jenkins"
                    className="w-full bg-stone-950 border border-stone-800 rounded-xl px-4 py-2.5 text-xs text-stone-200 focus:outline-none focus:border-rose-600"
                  />
                </div>

                <div>
                  <label className="text-xs text-stone-300 block mb-1">Email Address (for instant confirmations) *</label>
                  <input
                    type="email"
                    required
                    value={clientEmail}
                    onChange={(e) => setClientEmail(e.target.value)}
                    placeholder="e.g. sarah.jenkins@example.com"
                    className="w-full bg-stone-950 border border-stone-800 rounded-xl px-4 py-2.5 text-xs text-stone-200 focus:outline-none focus:border-rose-600"
                  />
                </div>

                <div>
                  <label className="text-xs text-stone-300 block mb-1">Phone Number (for SMS reminders)</label>
                  <input
                    type="tel"
                    value={clientPhone}
                    onChange={(e) => setClientPhone(e.target.value)}
                    placeholder="+1 (555) 234-5678"
                    className="w-full bg-stone-950 border border-stone-800 rounded-xl px-4 py-2.5 text-xs text-stone-200 focus:outline-none focus:border-rose-600"
                  />
                </div>

                <div>
                  <label className="text-xs text-stone-300 block mb-1">Special Requests or Hair/Skin Notes</label>
                  <textarea
                    rows={2}
                    value={notes}
                    onChange={(e) => setNotes(e.target.value)}
                    placeholder="e.g. Sensitive scalp, requested warm honey blonde tones..."
                    className="w-full bg-stone-950 border border-stone-800 rounded-xl px-4 py-2 text-xs text-stone-200 focus:outline-none focus:border-rose-600"
                  />
                </div>
              </div>
            </div>
          )}

          {/* STEP 5: Success Confirmation Screen */}
          {step === 5 && confirmedAppt && (
            <div className="text-center space-y-6 py-4">
              <div className="w-16 h-16 rounded-full bg-emerald-950 border-2 border-emerald-500 text-emerald-400 flex items-center justify-center mx-auto shadow-xl shadow-emerald-950/50">
                <CheckCircle2 className="w-8 h-8" />
              </div>

              <div className="space-y-2">
                <h3 className="font-serif text-2xl text-rose-100 font-medium">Session Confirmed!</h3>
                <p className="text-xs text-stone-300">Your appointment is scheduled and synced with our salon calendar.</p>
              </div>

              <div className="bg-stone-950 border border-rose-900/60 rounded-2xl p-5 text-left space-y-3 text-xs max-w-md mx-auto">
                <div className="flex justify-between items-center border-b border-stone-800 pb-2">
                  <span className="text-stone-400">Confirmation Code:</span>
                  <span className="font-mono text-sm font-bold text-amber-300 bg-rose-950 px-2.5 py-1 rounded border border-rose-800">
                    {confirmedAppt.confirmationCode}
                  </span>
                </div>

                <div className="space-y-1.5 text-stone-300">
                  <p><strong>Service:</strong> {confirmedAppt.serviceName}</p>
                  <p><strong>Specialist:</strong> {confirmedAppt.stylistName}</p>
                  <p><strong>Date & Time:</strong> {confirmedAppt.date} at {confirmedAppt.time}</p>
                  <p><strong>Total Price:</strong> <span className="text-amber-300 font-bold">${confirmedAppt.servicePrice}</span></p>
                </div>

                <div className="bg-rose-950/60 p-3 rounded-xl border border-rose-900/40 text-[11px] text-rose-200 flex items-center gap-2">
                  <Mail className="w-4 h-4 text-amber-400 shrink-0" />
                  <span>Automated mail confirmation sent to <strong>{confirmedAppt.clientEmail}</strong>!</span>
                </div>
              </div>

              <div className="flex flex-col sm:flex-row items-center justify-center gap-3 pt-2">
                <a
                  href={`/api/calendar/export-ics/${confirmedAppt.id}`}
                  download
                  className="w-full sm:w-auto px-5 py-2.5 rounded-xl bg-gradient-to-r from-amber-600 to-rose-600 hover:from-amber-500 hover:to-rose-500 text-white font-semibold text-xs flex items-center justify-center gap-2 shadow-lg"
                >
                  <Download className="w-4 h-4" />
                  <span>Download .ics Calendar File</span>
                </a>

                <button
                  onClick={onViewNotifications}
                  className="w-full sm:w-auto px-5 py-2.5 rounded-xl bg-stone-800 hover:bg-stone-700 text-stone-200 font-semibold text-xs flex items-center justify-center gap-2 border border-stone-700"
                >
                  <Mail className="w-4 h-4 text-rose-400" />
                  <span>View Dispatched Mail Log</span>
                </button>
              </div>
            </div>
          )}

        </div>

        {/* Wizard Footer Controls */}
        {step < 5 && (
          <div className="p-6 bg-stone-950 border-t border-stone-800/80 flex items-center justify-between">
            <button
              disabled={step === 1}
              onClick={() => setStep(step - 1)}
              className="px-4 py-2 rounded-xl bg-stone-900 hover:bg-stone-800 text-stone-400 text-xs font-medium disabled:opacity-30 flex items-center gap-1.5"
            >
              <ChevronLeft className="w-4 h-4" />
              <span>Back</span>
            </button>

            {step < 4 ? (
              <button
                disabled={step === 3 && !selectedTime}
                onClick={() => setStep(step + 1)}
                className="px-6 py-2.5 rounded-xl bg-gradient-to-r from-rose-600 to-amber-600 text-white font-semibold text-xs disabled:opacity-40 flex items-center gap-1.5 shadow-lg"
              >
                <span>Continue</span>
                <ChevronRight className="w-4 h-4" />
              </button>
            ) : (
              <button
                disabled={submitting || !clientName || !clientEmail}
                onClick={handleSubmitBooking}
                className="px-6 py-2.5 rounded-xl bg-gradient-to-r from-rose-600 via-pink-600 to-amber-600 text-white font-semibold text-xs disabled:opacity-40 flex items-center gap-2 shadow-xl shadow-rose-950/50"
              >
                <Sparkles className="w-4 h-4 text-amber-300" />
                <span>{submitting ? 'Confirming Booking...' : 'Confirm & Schedule Session'}</span>
              </button>
            )}
          </div>
        )}

      </div>
    </div>
  );
};
