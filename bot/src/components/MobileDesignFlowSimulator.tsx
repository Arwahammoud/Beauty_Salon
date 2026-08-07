import React, { useState } from 'react';
import { ArrowLeft, Heart, Star, Clock, Calendar, Check, CheckCircle2, ChevronLeft, ChevronRight, User, AlertCircle, Smartphone } from 'lucide-react';
import { Appointment } from '../types';

interface MobileDesignFlowSimulatorProps {
  onBookingCreated?: (appt: Appointment) => void;
}

export const MobileDesignFlowSimulator: React.FC<MobileDesignFlowSimulatorProps> = ({
  onBookingCreated
}) => {
  const [currentStep, setCurrentStep] = useState<number>(1); // 1: Service Detail, 2: Select Date, 3: Select Time, 4: Summary, 5: Confirmed
  const [selectedDate, setSelectedDate] = useState<string>('2026-05-15');
  const [selectedTime, setSelectedTime] = useState<string>('09:00');
  const [clientName, setClientName] = useState<string>('Sarah Jenkins');
  const [clientEmail, setClientEmail] = useState<string>('sarah.jenkins@example.com');
  const [isSubmitting, setIsSubmitting] = useState<boolean>(false);
  const [confirmedAppt, setConfirmedAppt] = useState<Appointment | null>(null);

  const handleConfirmBooking = async () => {
    setIsSubmitting(true);
    try {
      const res = await fetch('/api/appointments', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          clientName,
          clientEmail,
          clientPhone: '+971 50 888 1234',
          serviceId: 'hair-1',
          date: selectedDate,
          time: selectedTime,
          stylistId: 'stylist-layla',
          notes: 'Customer booked via exact Mobile UI flow.'
        })
      });
      const data = await res.json();
      if (data.success && data.appointment) {
        setConfirmedAppt(data.appointment);
        if (onBookingCreated) onBookingCreated(data.appointment);
        setCurrentStep(5);
      }
    } catch (err) {
      console.error(err);
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="space-y-8 pb-12">
      
      {/* Flow Header */}
      <div className="bg-stone-900 border border-stone-800 rounded-3xl p-6 sm:p-8 shadow-xl flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <Smartphone className="w-5 h-5 text-rose-400" />
            <span className="text-xs font-bold uppercase text-rose-300 font-mono tracking-wider">Exact Mobile Design Flow</span>
          </div>
          <h2 className="font-serif text-2xl text-rose-100 font-medium mt-1">
            Customer Booking Flow Preview
          </h2>
          <p className="text-xs text-stone-400 mt-1 max-w-xl">
            Interactive phone simulation matching your Figma mockup step-by-step: Service detail &rarr; Select date &rarr; Select time &rarr; Booking summary &rarr; Booking confirmed.
          </p>
        </div>

        {/* Step Indicator Buttons */}
        <div className="flex items-center gap-1.5 overflow-x-auto pb-1">
          {[1, 2, 3, 4, 5].map((step) => (
            <button
              key={step}
              onClick={() => setCurrentStep(step)}
              className={`px-3 py-1.5 rounded-xl text-xs font-medium font-mono transition-all ${
                currentStep === step
                  ? 'bg-rose-600 text-white shadow-md'
                  : 'bg-stone-800 text-stone-400 hover:text-white'
              }`}
            >
              Step {step}
            </button>
          ))}
        </div>
      </div>

      {/* Main Interactive Mobile Simulator Shell */}
      <div className="flex justify-center">
        <div className="w-full max-w-[390px] min-h-[780px] bg-white rounded-[44px] shadow-2xl border-[10px] border-stone-900 overflow-hidden flex flex-col relative text-stone-800 font-sans">
          
          {/* Mobile Notch Status Bar */}
          <div className="bg-white px-6 pt-3 pb-2 flex items-center justify-between text-xs font-semibold text-stone-900 z-10">
            <span>9:41</span>
            <div className="w-24 h-4 bg-stone-900 rounded-full mx-auto" />
            <div className="flex items-center gap-1 text-[10px]">
              <span>5G</span>
              <span>100%</span>
            </div>
          </div>

          {/* SCREEN 1: SERVICE DETAIL */}
          {currentStep === 1 && (
            <div className="flex-1 flex flex-col justify-between overflow-y-auto">
              <div>
                {/* Hero Banner */}
                <div className="relative h-64 bg-stone-200">
                  <img
                    src="https://images.unsplash.com/photo-1562322140-8baeececf3df?auto=format&fit=crop&w=800&q=80"
                    alt="Highlights / Balayage"
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute top-4 left-4 right-4 flex items-center justify-between">
                    <button className="w-9 h-9 rounded-full bg-white/80 backdrop-blur-md flex items-center justify-center text-stone-800 shadow">
                      <ArrowLeft className="w-4 h-4" />
                    </button>
                    <button className="w-9 h-9 rounded-full bg-white/80 backdrop-blur-md flex items-center justify-center text-rose-500 shadow">
                      <Heart className="w-4 h-4 fill-rose-500" />
                    </button>
                  </div>
                </div>

                {/* Content Details */}
                <div className="-mt-6 bg-white rounded-t-3xl p-5 space-y-4 shadow-lg">
                  <div>
                    <span className="px-2.5 py-0.5 rounded-full bg-stone-100 text-[10px] font-semibold text-stone-600">Hair</span>
                    <h2 className="text-xl font-bold text-stone-900 mt-1">Highlights / Balayage</h2>
                  </div>

                  {/* Badges */}
                  <div className="grid grid-cols-3 gap-2 py-2 border-y border-stone-100 text-center">
                    <div className="bg-stone-50 p-2 rounded-2xl">
                      <p className="text-[10px] text-stone-400">Duration</p>
                      <p className="text-xs font-bold text-stone-800 mt-0.5">180 min</p>
                    </div>
                    <div className="bg-stone-50 p-2 rounded-2xl">
                      <p className="text-[10px] text-stone-400">Price</p>
                      <p className="text-xs font-bold text-rose-600 mt-0.5">AED 580</p>
                    </div>
                    <div className="bg-stone-50 p-2 rounded-2xl">
                      <p className="text-[10px] text-stone-400">Reviews</p>
                      <p className="text-xs font-bold text-stone-800 mt-0.5 flex items-center justify-center gap-0.5">
                        <Star className="w-3 h-3 fill-amber-400 text-amber-400" />
                        4.9 (124)
                      </p>
                    </div>
                  </div>

                  {/* About */}
                  <div>
                    <h3 className="text-xs font-bold text-stone-900 uppercase tracking-wider text-stone-400">About this service</h3>
                    <p className="text-xs text-stone-600 mt-1 leading-relaxed">
                      Hand-painted dimensional highlights for a sun-kissed finish tailored to your hair structure.
                    </p>
                  </div>

                  {/* Benefits */}
                  <div>
                    <h3 className="text-xs font-bold text-stone-900 uppercase tracking-wider text-stone-400">Benefits</h3>
                    <div className="space-y-1.5 mt-2">
                      {['Custom dimension', 'Low maintenance', 'Premium toner'].map((b, i) => (
                        <div key={i} className="flex items-center gap-2 text-xs text-stone-700">
                          <div className="w-4 h-4 rounded-full bg-rose-100 flex items-center justify-center">
                            <Check className="w-2.5 h-2.5 text-rose-600" />
                          </div>
                          <span>{b}</span>
                        </div>
                      ))}
                    </div>
                  </div>

                  {/* Specialist */}
                  <div>
                    <h3 className="text-xs font-bold text-stone-900 uppercase tracking-wider text-stone-400 mb-2">Your specialist</h3>
                    <div className="p-3 rounded-2xl border border-stone-200 flex items-center justify-between bg-stone-50">
                      <div className="flex items-center gap-3">
                        <img
                          src="https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=300&q=80"
                          alt="Layla Hassan"
                          className="w-10 h-10 rounded-full object-cover"
                        />
                        <div>
                          <h4 className="text-xs font-bold text-stone-900">Layla Hassan</h4>
                          <p className="text-[10px] text-rose-500 font-medium">Senior Hair Stylist</p>
                          <p className="text-[10px] text-stone-400">★ 4.9 &bull; 8 yrs</p>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Bottom Sticky Button */}
              <div className="p-4 bg-white border-t border-stone-100">
                <button
                  onClick={() => setCurrentStep(2)}
                  className="w-full py-3.5 rounded-full bg-rose-500 hover:bg-rose-600 text-white font-bold text-sm shadow-lg shadow-rose-200 transition-all"
                >
                  Book Now &bull; AED 580
                </button>
              </div>
            </div>
          )}

          {/* SCREEN 2: SELECT DATE */}
          {currentStep === 2 && (
            <div className="flex-1 flex flex-col justify-between p-5 bg-white">
              <div className="space-y-5">
                <div className="flex items-center justify-between">
                  <button onClick={() => setCurrentStep(1)} className="p-2 rounded-full bg-stone-100">
                    <ArrowLeft className="w-4 h-4 text-stone-700" />
                  </button>
                  <h3 className="text-sm font-bold text-stone-900">Highlights / Balayage</h3>
                  <div className="w-8" />
                </div>

                <div>
                  <h2 className="text-xl font-bold text-stone-900">Select Date</h2>
                  <div className="flex items-center justify-between mt-4 mb-2">
                    <span className="text-xs font-bold text-stone-700">May 2026</span>
                    <div className="flex items-center gap-1">
                      <button className="p-1 rounded bg-stone-100"><ChevronLeft className="w-3.5 h-3.5" /></button>
                      <button className="p-1 rounded bg-stone-100"><ChevronRight className="w-3.5 h-3.5" /></button>
                    </div>
                  </div>

                  {/* Calendar Grid */}
                  <div className="grid grid-cols-7 text-center gap-1 text-[11px] font-bold text-stone-400 mb-2">
                    <span>S</span><span>M</span><span>T</span><span>W</span><span>T</span><span>F</span><span>S</span>
                  </div>
                  <div className="grid grid-cols-7 gap-1 text-center text-xs font-medium">
                    {Array.from({ length: 31 }, (_, i) => i + 1).map((d) => {
                      const dateStr = `2026-05-${d < 10 ? '0' + d : d}`;
                      const isSelected = selectedDate === dateStr;
                      return (
                        <button
                          key={d}
                          onClick={() => setSelectedDate(dateStr)}
                          className={`py-2 rounded-xl text-xs font-semibold transition-all ${
                            isSelected
                              ? 'bg-rose-500 text-white shadow-md'
                              : 'hover:bg-stone-100 text-stone-700'
                          }`}
                        >
                          {d}
                        </button>
                      );
                    })}
                  </div>
                </div>
              </div>

              <button
                onClick={() => setCurrentStep(3)}
                className="w-full py-3.5 rounded-full bg-rose-500 hover:bg-rose-600 text-white font-bold text-sm shadow-lg shadow-rose-200"
              >
                Continue to Time
              </button>
            </div>
          )}

          {/* SCREEN 3: SELECT TIME */}
          {currentStep === 3 && (
            <div className="flex-1 flex flex-col justify-between p-5 bg-white overflow-y-auto">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <button onClick={() => setCurrentStep(2)} className="p-2 rounded-full bg-stone-100">
                    <ArrowLeft className="w-4 h-4 text-stone-700" />
                  </button>
                  <h3 className="text-sm font-bold text-stone-900">Highlights / Balayage</h3>
                  <div className="w-8" />
                </div>

                <div>
                  <h2 className="text-xl font-bold text-stone-900">Select Time</h2>
                  <p className="text-xs text-stone-400 mt-0.5">Fri, May 15 &bull; 180 min &bull; with Layla Hassan</p>
                </div>

                {/* Time Groups */}
                <div className="space-y-4 pt-2">
                  {/* Morning */}
                  <div>
                    <span className="text-[11px] font-bold text-stone-500 uppercase flex items-center gap-1">
                      ☀️ Morning
                    </span>
                    <div className="grid grid-cols-3 gap-2 mt-2">
                      {['09:00', '09:30', '10:00', '10:30', '11:00', '11:30'].map((t) => (
                        <button
                          key={t}
                          onClick={() => setSelectedTime(t)}
                          className={`py-2 rounded-xl text-xs font-bold transition-all border ${
                            selectedTime === t
                              ? 'bg-rose-500 text-white border-rose-500 shadow'
                              : 'bg-stone-50 text-stone-700 border-stone-200 hover:border-rose-300'
                          }`}
                        >
                          {t}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Afternoon */}
                  <div>
                    <span className="text-[11px] font-bold text-stone-500 uppercase flex items-center gap-1">
                      🌤️ Afternoon
                    </span>
                    <div className="grid grid-cols-3 gap-2 mt-2">
                      {['12:00', '13:00', '14:00', '15:00', '15:30'].map((t) => (
                        <button
                          key={t}
                          onClick={() => setSelectedTime(t)}
                          className={`py-2 rounded-xl text-xs font-bold transition-all border ${
                            selectedTime === t
                              ? 'bg-rose-500 text-white border-rose-500 shadow'
                              : 'bg-stone-50 text-stone-700 border-stone-200 hover:border-rose-300'
                          }`}
                        >
                          {t}
                        </button>
                      ))}
                    </div>
                  </div>

                  {/* Evening */}
                  <div>
                    <span className="text-[11px] font-bold text-stone-500 uppercase flex items-center gap-1">
                      🌙 Evening
                    </span>
                    <div className="grid grid-cols-3 gap-2 mt-2">
                      {['16:00', '18:00', '18:30', '19:00'].map((t) => (
                        <button
                          key={t}
                          onClick={() => setSelectedTime(t)}
                          className={`py-2 rounded-xl text-xs font-bold transition-all border ${
                            selectedTime === t
                              ? 'bg-rose-500 text-white border-rose-500 shadow'
                              : 'bg-stone-50 text-stone-700 border-stone-200 hover:border-rose-300'
                          }`}
                        >
                          {t}
                        </button>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              <button
                onClick={() => setCurrentStep(4)}
                className="w-full py-3.5 rounded-full bg-rose-500 hover:bg-rose-600 text-white font-bold text-sm shadow-lg shadow-rose-200 mt-4"
              >
                Review Summary
              </button>
            </div>
          )}

          {/* SCREEN 4: BOOKING SUMMARY */}
          {currentStep === 4 && (
            <div className="flex-1 flex flex-col justify-between p-5 bg-stone-50">
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <button onClick={() => setCurrentStep(3)} className="p-2 rounded-full bg-white border border-stone-200">
                    <ArrowLeft className="w-4 h-4 text-stone-700" />
                  </button>
                  <h3 className="text-sm font-bold text-stone-900">Highlights / Balayage</h3>
                  <div className="w-8" />
                </div>

                <h2 className="text-xl font-bold text-stone-900">Booking Summary</h2>

                {/* Service Card */}
                <div className="bg-white p-4 rounded-2xl border border-stone-200 space-y-3 shadow-sm">
                  <div className="flex gap-3">
                    <img
                      src="https://images.unsplash.com/photo-1562322140-8baeececf3df?auto=format&fit=crop&w=800&q=80"
                      alt="Service"
                      className="w-14 h-14 rounded-xl object-cover"
                    />
                    <div>
                      <p className="text-[10px] uppercase font-bold text-stone-400">SERVICE</p>
                      <h4 className="text-xs font-bold text-stone-900">Highlights / Balayage</h4>
                      <p className="text-[10px] text-stone-500">180 min</p>
                    </div>
                  </div>

                  <div className="pt-2 border-t border-stone-100 text-xs space-y-1.5">
                    <div className="flex justify-between">
                      <span className="text-stone-400">Specialist</span>
                      <span className="font-bold text-stone-800">Layla Hassan</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-stone-400">Date & Time</span>
                      <span className="font-bold text-stone-800">{selectedDate} - {selectedTime}</span>
                    </div>
                    <div className="flex justify-between">
                      <span className="text-stone-400">Price</span>
                      <span className="font-bold text-stone-800">AED 580</span>
                    </div>
                    <div className="flex justify-between pt-2 border-t border-stone-100 text-sm font-bold">
                      <span>Total</span>
                      <span className="text-rose-600">AED 580</span>
                    </div>
                  </div>
                </div>

                {/* Client Contact Details */}
                <div className="bg-white p-4 rounded-2xl border border-stone-200 space-y-2">
                  <label className="text-[10px] font-bold uppercase text-stone-400">Your Info for Email Confirmation</label>
                  <input
                    type="text"
                    value={clientName}
                    onChange={(e) => setClientName(e.target.value)}
                    placeholder="Full Name"
                    className="w-full px-3 py-1.5 bg-stone-50 rounded-xl text-xs border border-stone-200 text-stone-900"
                  />
                  <input
                    type="email"
                    value={clientEmail}
                    onChange={(e) => setClientEmail(e.target.value)}
                    placeholder="Email Address"
                    className="w-full px-3 py-1.5 bg-stone-50 rounded-xl text-xs border border-stone-200 text-stone-900"
                  />
                </div>

                {/* Cancellation Policy Box */}
                <div className="p-3 bg-rose-50 border border-rose-200 rounded-2xl text-[11px] text-rose-800 flex items-start gap-2">
                  <AlertCircle className="w-4 h-4 text-rose-500 shrink-0 mt-0.5" />
                  <p>Cancellation allowed up to 3 hours before. You'll get an automated email reminder 24 hours before.</p>
                </div>
              </div>

              <button
                onClick={handleConfirmBooking}
                disabled={isSubmitting}
                className="w-full py-3.5 rounded-full bg-rose-500 hover:bg-rose-600 text-white font-bold text-sm shadow-lg shadow-rose-200 disabled:opacity-50 mt-4"
              >
                {isSubmitting ? 'Confirming...' : 'Confirm Booking'}
              </button>
            </div>
          )}

          {/* SCREEN 5: BOOKING CONFIRMED! */}
          {currentStep === 5 && (
            <div className="flex-1 bg-rose-500 text-white flex flex-col justify-between p-6 text-center">
              <div className="pt-10 space-y-4">
                <div className="w-16 h-16 rounded-full bg-white/20 backdrop-blur-md border-2 border-white/60 flex items-center justify-center mx-auto shadow-xl">
                  <Check className="w-8 h-8 text-white stroke-[3]" />
                </div>

                <h2 className="font-serif text-2xl font-bold">Booking Confirmed!</h2>
                <p className="text-xs text-rose-100 max-w-xs mx-auto">
                  You're all set. We've sent an automated confirmation email to <span className="underline font-semibold">{clientEmail}</span>.
                </p>

                {/* Summary Box */}
                <div className="bg-white text-stone-900 p-4 rounded-3xl text-left space-y-3 shadow-2xl mt-6">
                  <div className="flex items-center gap-3">
                    <img
                      src="https://images.unsplash.com/photo-1562322140-8baeececf3df?auto=format&fit=crop&w=800&q=80"
                      alt="Service"
                      className="w-10 h-10 rounded-xl object-cover"
                    />
                    <div>
                      <h4 className="text-xs font-bold">Highlights / Balayage</h4>
                      <p className="text-[10px] text-stone-500">with Layla Hassan</p>
                    </div>
                  </div>

                  <div className="p-2.5 bg-stone-50 rounded-2xl flex items-center justify-between text-xs font-bold border border-stone-100">
                    <div>
                      <p className="text-[9px] text-stone-400 uppercase">DATE</p>
                      <p>{selectedDate}</p>
                    </div>
                    <div>
                      <p className="text-[9px] text-stone-400 uppercase">TIME</p>
                      <p>{selectedTime}</p>
                    </div>
                    <div className="text-right">
                      <p className="text-[9px] text-rose-500 uppercase">EARNED</p>
                      <p className="text-rose-600">+58 pts</p>
                    </div>
                  </div>
                </div>
              </div>

              <div className="space-y-2 pt-6">
                <button
                  onClick={() => setCurrentStep(1)}
                  className="w-full py-3 rounded-full bg-white text-rose-600 font-bold text-xs shadow-lg"
                >
                  Back to Home
                </button>
              </div>
            </div>
          )}

        </div>
      </div>

    </div>
  );
};
