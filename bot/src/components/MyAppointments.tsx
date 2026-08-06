import React, { useState } from 'react';
import { Appointment } from '../types';
import { Calendar, Clock, User, Download, RefreshCw, XCircle, Search, Mail, Sparkles, CheckCircle2 } from 'lucide-react';

interface MyAppointmentsProps {
  appointments: Appointment[];
  onReschedule: (id: string) => void;
  onCancel: (id: string) => void;
  onRefresh: () => void;
}

export const MyAppointments: React.FC<MyAppointmentsProps> = ({
  appointments,
  onReschedule,
  onCancel,
  onRefresh
}) => {
  const [searchQuery, setSearchQuery] = useState<string>('');

  const filtered = appointments.filter(a => {
    const q = searchQuery.toLowerCase();
    return a.clientName.toLowerCase().includes(q) ||
           a.clientEmail.toLowerCase().includes(q) ||
           a.confirmationCode.toLowerCase().includes(q) ||
           a.serviceName.toLowerCase().includes(q);
  });

  const nextUpcoming = appointments.find(a => a.status === 'confirmed');

  return (
    <div className="space-y-8 pb-12">
      
      {/* Header Banner */}
      <div className="bg-stone-900 border border-stone-800 rounded-3xl p-6 sm:p-8 shadow-xl flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="font-serif text-2xl text-rose-100 font-medium">My Salon Sessions & Active Bookings</h2>
          <p className="text-xs text-stone-400 mt-1">
            Manage your booked appointments, download calendar events (.ics), or reschedule sessions.
          </p>
        </div>

        {/* Search Bar */}
        <div className="relative w-full md:w-72">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-500" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search by code or email..."
            className="w-full bg-stone-950 border border-stone-800 rounded-xl pl-10 pr-4 py-2 text-xs text-stone-200 placeholder-stone-500 focus:outline-none focus:border-rose-600 transition-all"
          />
        </div>
      </div>

      {/* Next Upcoming Highlight Banner */}
      {nextUpcoming && (
        <div className="bg-gradient-to-r from-rose-950 via-stone-900 to-amber-950/80 border border-rose-800/60 rounded-3xl p-6 shadow-xl flex flex-col md:flex-row items-center justify-between gap-6">
          <div className="space-y-2">
            <span className="px-3 py-1 rounded-full bg-rose-900/80 border border-rose-600/50 text-rose-200 text-[10px] font-bold uppercase tracking-wider">
              Next Upcoming Session
            </span>
            <h3 className="font-serif text-xl text-rose-100 font-medium">{nextUpcoming.serviceName}</h3>
            <p className="text-xs text-stone-300">
              Specialist: <strong>{nextUpcoming.stylistName}</strong> &bull; Code: <span className="font-mono text-amber-300 font-bold">{nextUpcoming.confirmationCode}</span>
            </p>
            <p className="text-xs text-rose-300 flex items-center gap-1.5 pt-1">
              <Calendar className="w-4 h-4 text-rose-400" />
              <span>{nextUpcoming.date} at {nextUpcoming.time} ({nextUpcoming.durationMinutes} mins)</span>
            </p>
          </div>

          <div className="flex flex-wrap items-center gap-2">
            <a
              href={`/api/calendar/export-ics/${nextUpcoming.id}`}
              download
              className="px-4 py-2 rounded-xl bg-amber-600 hover:bg-amber-500 text-white font-semibold text-xs flex items-center gap-1.5 shadow-md"
            >
              <Download className="w-3.5 h-3.5" />
              <span>.ics Calendar</span>
            </a>

            <button
              onClick={() => onCancel(nextUpcoming.id)}
              className="px-4 py-2 rounded-xl bg-stone-800 hover:bg-rose-900 text-stone-300 hover:text-white font-semibold text-xs border border-stone-700 hover:border-rose-600 transition-colors"
            >
              Cancel Session
            </button>
          </div>
        </div>
      )}

      {/* Appointments Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
        {filtered.map(appt => (
          <div
            key={appt.id}
            className="bg-stone-900 border border-stone-800 rounded-2xl p-5 space-y-4 shadow-lg hover:border-rose-900/60 transition-all"
          >
            <div className="flex items-center justify-between border-b border-stone-800 pb-3">
              <span className={`px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase ${
                appt.status === 'confirmed'
                  ? 'bg-emerald-950 text-emerald-300 border border-emerald-800'
                  : 'bg-stone-950 text-stone-500 border border-stone-800'
              }`}>
                {appt.status}
              </span>

              <span className="font-mono text-xs font-bold text-amber-300 bg-stone-950 px-2 py-0.5 rounded border border-stone-800">
                {appt.confirmationCode}
              </span>
            </div>

            <div className="space-y-1">
              <h4 className="font-serif text-base text-rose-100 font-medium">{appt.serviceName}</h4>
              <p className="text-xs text-stone-400">Stylist: {appt.stylistName}</p>
              <p className="text-xs text-stone-400">Client: {appt.clientName} ({appt.clientEmail})</p>
            </div>

            <div className="bg-stone-950 p-3 rounded-xl border border-stone-800 space-y-1 text-xs text-stone-300">
              <div className="flex items-center justify-between">
                <span className="flex items-center gap-1">
                  <Calendar className="w-3.5 h-3.5 text-rose-400" />
                  {appt.date}
                </span>
                <span className="flex items-center gap-1 font-semibold text-amber-300">
                  <Clock className="w-3.5 h-3.5 text-amber-400" />
                  {appt.time}
                </span>
              </div>
              <p className="text-[11px] text-stone-400 pt-1 border-t border-stone-900">
                Price: <strong className="text-stone-200">${appt.servicePrice}</strong> &bull; {appt.durationMinutes} mins
              </p>
            </div>

            {appt.status === 'confirmed' && (
              <div className="pt-2 flex items-center justify-between gap-2">
                <a
                  href={`/api/calendar/export-ics/${appt.id}`}
                  download
                  className="py-1.5 px-3 rounded-xl bg-stone-800 hover:bg-stone-700 text-stone-200 text-[11px] font-medium flex items-center gap-1 border border-stone-700"
                >
                  <Download className="w-3 h-3 text-amber-400" />
                  <span>.ics Sync</span>
                </a>

                <button
                  onClick={() => onCancel(appt.id)}
                  className="py-1.5 px-3 rounded-xl bg-stone-900 hover:bg-rose-950 text-stone-400 hover:text-rose-200 text-[11px] font-medium border border-stone-800 hover:border-rose-800 transition-colors"
                >
                  Cancel
                </button>
              </div>
            )}
          </div>
        ))}
      </div>

    </div>
  );
};
