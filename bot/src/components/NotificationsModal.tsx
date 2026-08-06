import React, { useState, useEffect } from 'react';
import { EmailNotification } from '../types';
import { Mail, Bell, CheckCircle2, RefreshCw, Eye, X, Send, Clock, Sparkles } from 'lucide-react';

interface NotificationsModalProps {
  notifications: EmailNotification[];
  onRefreshNotifications: () => void;
}

export const NotificationsModal: React.FC<NotificationsModalProps> = ({
  notifications,
  onRefreshNotifications
}) => {
  const [selectedNotif, setSelectedNotif] = useState<EmailNotification | null>(null);
  const [triggering, setTriggering] = useState<boolean>(false);
  const [triggerResult, setTriggerResult] = useState<string | null>(null);

  const handleTriggerReminders = async () => {
    setTriggering(true);
    setTriggerResult(null);
    try {
      const res = await fetch('/api/reminders/trigger', { method: 'POST' });
      const data = await res.json();
      if (data.success) {
        setTriggerResult(`Dispatched ${data.triggeredCount} automated 24h/2h reminders!`);
        onRefreshNotifications();
      }
    } catch (err) {
      console.error("Reminder trigger error:", err);
    } finally {
      setTriggering(false);
    }
  };

  return (
    <div className="space-y-8 pb-12">
      
      {/* Header Banner */}
      <div className="bg-stone-900 border border-stone-800 rounded-3xl p-6 sm:p-8 shadow-xl flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div className="flex items-center gap-2">
            <Mail className="w-6 h-6 text-rose-400" />
            <h2 className="font-serif text-2xl text-rose-100 font-medium">Automated Mail Confirmations & Reminder System</h2>
          </div>
          <p className="text-xs text-stone-400 mt-1 max-w-xl">
            Real-time tracking of outgoing email confirmations for clients and salon staff, 24h & 2h pre-appointment alerts, and reschedule notices.
          </p>
        </div>

        <div className="flex items-center gap-3">
          <button
            onClick={handleTriggerReminders}
            disabled={triggering}
            className="px-4 py-2.5 rounded-2xl bg-gradient-to-r from-rose-700 to-amber-700 hover:from-rose-600 hover:to-amber-600 text-white font-semibold text-xs flex items-center gap-2 shadow-lg shadow-rose-950/40 disabled:opacity-50"
          >
            <Clock className="w-4 h-4 text-amber-300" />
            <span>{triggering ? 'Checking Reminders...' : 'Trigger Pre-Session Reminders'}</span>
          </button>
        </div>
      </div>

      {triggerResult && (
        <div className="bg-emerald-950/80 border border-emerald-600/60 p-4 rounded-2xl text-emerald-200 text-xs flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4 text-emerald-400" />
          <span>{triggerResult}</span>
        </div>
      )}

      {/* Notifications List */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {notifications.map(notif => (
          <div
            key={notif.id}
            className="bg-stone-900/90 border border-stone-800 hover:border-rose-800/80 rounded-2xl p-5 space-y-3 shadow-lg transition-all"
          >
            <div className="flex items-start justify-between gap-2">
              <div className="flex items-center gap-2">
                <span className={`px-2 py-0.5 rounded-full text-[10px] font-bold uppercase ${
                  notif.recipientType === 'client'
                    ? 'bg-rose-950 text-rose-300 border border-rose-800'
                    : 'bg-amber-950 text-amber-300 border border-amber-800'
                }`}>
                  {notif.recipientType === 'client' ? 'Client Mail' : 'Staff Notice'}
                </span>

                <span className="text-[10px] text-stone-500">
                  {new Date(notif.sentAt).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </span>
              </div>

              <button
                onClick={() => setSelectedNotif(notif)}
                className="text-rose-300 hover:text-rose-100 text-xs font-medium flex items-center gap-1 transition-colors"
              >
                <Eye className="w-3.5 h-3.5 text-amber-400" />
                <span>Preview Email</span>
              </button>
            </div>

            <div>
              <h4 className="font-serif text-sm text-stone-200 font-medium line-clamp-1">{notif.subject}</h4>
              <p className="text-xs text-stone-400 mt-0.5">To: <span className="text-stone-300 font-mono">{notif.to}</span></p>
            </div>

            <div className="pt-2 border-t border-stone-800 flex items-center justify-between text-[11px] text-stone-400">
              <span className="flex items-center gap-1 text-emerald-400">
                <Send className="w-3 h-3" /> Sent via Mail Server
              </span>
              <span className="capitalize">{notif.type.replace('_', ' ')}</span>
            </div>
          </div>
        ))}
      </div>

      {/* Email Html Preview Drawer Modal */}
      {selectedNotif && (
        <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
          <div className="bg-stone-900 border border-rose-900/60 rounded-3xl w-full max-w-2xl max-h-[85vh] overflow-hidden shadow-2xl flex flex-col">
            
            <div className="p-4 bg-stone-950 border-b border-stone-800 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <Mail className="w-4 h-4 text-rose-400" />
                <h3 className="font-serif text-base text-rose-100">Dispatched Email HTML Preview</h3>
              </div>
              <button
                onClick={() => setSelectedNotif(null)}
                className="p-1 rounded-full text-stone-400 hover:text-white hover:bg-stone-800"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="p-6 overflow-y-auto flex-1 bg-stone-100 rounded-b-3xl">
              <div 
                className="prose max-w-none text-stone-900"
                dangerouslySetInnerHTML={{ __html: selectedNotif.bodyHtml }}
              />
            </div>

          </div>
        </div>
      )}

    </div>
  );
};
