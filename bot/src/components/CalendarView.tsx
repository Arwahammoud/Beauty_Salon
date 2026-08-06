import React, { useState, useEffect } from 'react';
import { Appointment, Stylist, TimeSlot } from '../types';
import { SALON_STYLISTS, DEFAULT_TIME_SLOTS } from '../data/salonData';
import { Calendar as CalendarIcon, Clock, User, Scissors, Filter, Sparkles, Plus, CheckCircle2, AlertCircle } from 'lucide-react';

interface CalendarViewProps {
  appointments: Appointment[];
  isAdminMode: boolean;
  onBookSlot: (date: string, time: string, stylistId?: string) => void;
}

export const CalendarView: React.FC<CalendarViewProps> = ({
  appointments,
  isAdminMode,
  onBookSlot
}) => {
  const [selectedDate, setSelectedDate] = useState<string>(
    new Date().toISOString().split('T')[0]
  );
  const [selectedStylistFilter, setSelectedStylistFilter] = useState<string>('all');

  // Filter appointments on selected date
  const dateAppointments = appointments.filter(a => {
    const matchesDate = a.date === selectedDate && a.status === 'confirmed';
    const matchesStylist = selectedStylistFilter === 'all' || a.stylistId === selectedStylistFilter;
    return matchesDate && matchesStylist;
  });

  const activeStylists = selectedStylistFilter === 'all' 
    ? SALON_STYLISTS 
    : SALON_STYLISTS.filter(s => s.id === selectedStylistFilter);

  return (
    <div className="space-y-8 pb-12">
      
      {/* Calendar Header Control Bar */}
      <div className="bg-stone-900 border border-stone-800 rounded-3xl p-6 shadow-xl flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <h2 className="font-serif text-2xl text-rose-100 font-medium">Real-Time Salon Schedule Calendar</h2>
            {isAdminMode && (
              <span className="px-2.5 py-0.5 rounded-full text-[10px] bg-amber-950 text-amber-300 border border-amber-600/50 font-bold uppercase">
                Staff Control Mode
              </span>
            )}
          </div>
          <p className="text-xs text-stone-400 mt-1">
            Real-time synchronization with online booking requests, Aura AI assistant, and email confirmations.
          </p>
        </div>

        {/* Date & Stylist Selectors */}
        <div className="flex flex-wrap items-center gap-3">
          
          <div className="flex items-center gap-2 bg-stone-950 border border-stone-800 rounded-2xl px-3.5 py-2 text-xs">
            <CalendarIcon className="w-4 h-4 text-rose-400" />
            <input
              type="date"
              value={selectedDate}
              onChange={(e) => setSelectedDate(e.target.value)}
              className="bg-transparent text-stone-200 focus:outline-none cursor-pointer"
            />
          </div>

          <div className="flex items-center gap-2 bg-stone-950 border border-stone-800 rounded-2xl px-3.5 py-2 text-xs">
            <Filter className="w-3.5 h-3.5 text-amber-400" />
            <select
              value={selectedStylistFilter}
              onChange={(e) => setSelectedStylistFilter(e.target.value)}
              className="bg-transparent text-stone-200 focus:outline-none cursor-pointer"
            >
              <option value="all" className="bg-stone-900 text-stone-200">All Specialists</option>
              {SALON_STYLISTS.map(s => (
                <option key={s.id} value={s.id} className="bg-stone-900 text-stone-200">{s.name}</option>
              ))}
            </select>
          </div>

        </div>
      </div>

      {/* Daily Time Slot Matrix / Schedule Grid */}
      <div className="bg-stone-900 border border-stone-800 rounded-3xl p-6 shadow-xl overflow-x-auto space-y-6">
        <div className="flex items-center justify-between border-b border-stone-800 pb-4">
          <h3 className="font-serif text-lg text-rose-100 flex items-center gap-2">
            <Clock className="w-5 h-5 text-rose-400" />
            <span>Schedule Matrix for {new Date(selectedDate + 'T12:00:00').toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric', year: 'numeric' })}</span>
          </h3>
          <span className="text-xs text-stone-400">
            {dateAppointments.length} Booked Session{dateAppointments.length !== 1 ? 's' : ''}
          </span>
        </div>

        {/* Stylist Columns Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 min-w-[700px]">
          {activeStylists.map(stylist => {
            const stylistAppts = dateAppointments.filter(a => a.stylistId === stylist.id);

            return (
              <div key={stylist.id} className="bg-stone-950 border border-stone-800 rounded-2xl p-4 space-y-4">
                
                {/* Stylist Header */}
                <div className="flex items-center gap-3 border-b border-stone-800 pb-3">
                  <img src={stylist.avatar} alt={stylist.name} className="w-10 h-10 rounded-full object-cover border border-rose-900" />
                  <div>
                    <h4 className="font-serif text-sm text-stone-200 font-medium">{stylist.name}</h4>
                    <p className="text-[10px] text-rose-300">{stylist.role}</p>
                  </div>
                </div>

                {/* Slots List */}
                <div className="space-y-2.5">
                  {DEFAULT_TIME_SLOTS.map((time, idx) => {
                    const bookedAppt = stylistAppts.find(a => a.time === time);

                    if (bookedAppt) {
                      return (
                        <div
                          key={idx}
                          className="bg-rose-950/80 border border-rose-700/80 rounded-xl p-3 text-xs space-y-1 shadow-md"
                        >
                          <div className="flex items-center justify-between text-rose-200 font-bold">
                            <span className="flex items-center gap-1">
                              <Clock className="w-3 h-3 text-amber-300" />
                              {time}
                            </span>
                            <span className="text-[10px] bg-rose-900 px-1.5 py-0.5 rounded font-mono text-rose-100">
                              {bookedAppt.confirmationCode}
                            </span>
                          </div>
                          <p className="font-medium text-stone-200">{bookedAppt.serviceName}</p>
                          <p className="text-[10px] text-stone-400">Client: {bookedAppt.clientName}</p>
                        </div>
                      );
                    }

                    return (
                      <button
                        key={idx}
                        onClick={() => onBookSlot(selectedDate, time, stylist.id)}
                        className="w-full py-2.5 px-3 rounded-xl border border-dashed border-stone-800 hover:border-rose-600/80 bg-stone-900/50 hover:bg-rose-950/40 text-stone-400 hover:text-rose-200 text-xs flex items-center justify-between transition-all group"
                      >
                        <span className="font-mono text-[11px]">{time}</span>
                        <span className="text-[10px] text-rose-400 opacity-0 group-hover:opacity-100 flex items-center gap-0.5">
                          <Plus className="w-3 h-3" /> Book Slot
                        </span>
                      </button>
                    );
                  })}
                </div>

              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};
