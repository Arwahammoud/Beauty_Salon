import React, { useState, useRef, useEffect } from 'react';
import { ChatMessage, Appointment, TimeSlot, SalonService } from '../types';
import { Bot, User, Send, Sparkles, Calendar, Clock, CheckCircle2, Download, X, Mail, ChevronRight, AlertCircle } from 'lucide-react';

interface ChatBotProps {
  isOpen: boolean;
  onClose: () => void;
  onDirectBook: (serviceId?: string, date?: string, time?: string) => void;
  onViewNotifications: () => void;
  onViewAppointments: () => void;
  initialQuery?: string;
}

export const ChatBot: React.FC<ChatBotProps> = ({
  isOpen,
  onClose,
  onDirectBook,
  onViewNotifications,
  onViewAppointments,
  initialQuery
}) => {
  const [messages, setMessages] = useState<ChatMessage[]>([
    {
      id: 'msg-1',
      sender: 'bot',
      text: "Hello darling! I am Aura, your Velvet & Glow salon concierge. I can answer questions about our luxury treatments, check live calendar availability, and book your appointments automatically. How can I pamper you today?",
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    }
  ]);
  const [input, setInput] = useState<string>('');
  const [loading, setLoading] = useState<boolean>(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);

  const suggestedPrompts = [
    "What treatments do you offer for frizzy hair?",
    "Check availability for HydraFacial tomorrow",
    "Book Signature Balayage for Sarah on Friday at 2 PM",
    "How much is the 24K Gold Collagen Facial?",
    "Lookup my booking VG-8821"
  ];

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    if (isOpen) {
      scrollToBottom();
    }
  }, [messages, isOpen]);

  useEffect(() => {
    if (initialQuery && isOpen) {
      handleSend(initialQuery);
    }
  }, [initialQuery]);

  const handleSend = async (textToSend?: string) => {
    const query = textToSend || input;
    if (!query.trim() || loading) return;

    const userMsg: ChatMessage = {
      id: 'msg-' + Date.now(),
      sender: 'user',
      text: query,
      timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
    };

    setMessages(prev => [...prev, userMsg]);
    setInput('');
    setLoading(true);

    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          messages: [...messages, userMsg],
          userContext: {
            today: new Date().toISOString().split('T')[0]
          }
        })
      });

      const data = await response.json();

      const botMsg: ChatMessage = {
        id: 'msg-bot-' + Date.now(),
        sender: 'bot',
        text: data.reply || "I've processed your salon inquiry.",
        timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
        cardData: data.cardData
      };

      setMessages(prev => [...prev, botMsg]);
    } catch (err) {
      console.error("Chat error:", err);
      setMessages(prev => [
        ...prev,
        {
          id: 'msg-err-' + Date.now(),
          sender: 'bot',
          text: "I experienced a brief connection delay checking our calendar. You can also book directly through our interactive scheduler below!",
          timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
        }
      ]);
    } finally {
      setLoading(false);
    }
  };

  if (!isOpen) return null;

  return (
    <div className="fixed bottom-4 right-4 z-50 w-full sm:w-[440px] h-[600px] max-h-[90vh] bg-stone-900 border border-rose-900/60 rounded-3xl shadow-2xl flex flex-col overflow-hidden animate-in fade-in slide-in-from-bottom-5 duration-300">
      
      {/* Header */}
      <div className="bg-gradient-to-r from-stone-950 via-rose-950 to-stone-950 p-4 border-b border-rose-900/40 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 rounded-full bg-gradient-to-tr from-rose-500 to-amber-300 p-0.5 shadow-md">
            <div className="w-full h-full bg-stone-950 rounded-full flex items-center justify-center">
              <Bot className="w-5 h-5 text-rose-300" />
            </div>
          </div>
          <div>
            <div className="flex items-center gap-2">
              <h3 className="font-serif text-base text-rose-100 font-medium">Aura AI Salon Assistant</h3>
              <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
            </div>
            <p className="text-[11px] text-rose-300/80">Automated Calendar & Booking Engine</p>
          </div>
        </div>

        <button
          onClick={onClose}
          className="p-1.5 rounded-full text-stone-400 hover:text-white hover:bg-stone-800 transition-colors"
        >
          <X className="w-5 h-5" />
        </button>
      </div>

      {/* Messages Stream */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 bg-gradient-to-b from-stone-950 to-stone-900">
        {messages.map((msg) => (
          <div
            key={msg.id}
            className={`flex gap-3 ${msg.sender === 'user' ? 'justify-end' : 'justify-start'}`}
          >
            {msg.sender === 'bot' && (
              <div className="w-8 h-8 rounded-full bg-rose-950 border border-rose-700/50 flex items-center justify-center shrink-0 mt-0.5">
                <Bot className="w-4 h-4 text-rose-300" />
              </div>
            )}

            <div className={`max-w-[82%] space-y-2`}>
              <div
                className={`p-3.5 rounded-2xl text-xs leading-relaxed shadow-sm ${
                  msg.sender === 'user'
                    ? 'bg-rose-900 text-rose-50 rounded-br-none border border-rose-700/60'
                    : 'bg-stone-800/90 text-stone-200 rounded-bl-none border border-stone-700/60'
                }`}
              >
                <p className="whitespace-pre-line">{msg.text}</p>
                <span className="block text-[9px] text-stone-400/80 text-right mt-1">
                  {msg.timestamp}
                </span>
              </div>

              {/* Rich Embedded Cards in Chat Stream */}
              {msg.cardData?.appointment && (
                <div className="bg-stone-950 border border-rose-600/60 rounded-2xl p-3.5 space-y-2 text-xs text-stone-200 shadow-lg">
                  <div className="flex items-center justify-between text-rose-300 border-b border-stone-800 pb-2">
                    <span className="font-bold flex items-center gap-1">
                      <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                      Session Reserved!
                    </span>
                    <span className="font-mono text-[11px] bg-rose-950 px-2 py-0.5 rounded border border-rose-800 text-rose-200">
                      {msg.cardData.appointment.confirmationCode}
                    </span>
                  </div>

                  <div className="space-y-1 text-[11px] text-stone-300">
                    <p><strong>Service:</strong> {msg.cardData.appointment.serviceName}</p>
                    <p><strong>Stylist:</strong> {msg.cardData.appointment.stylistName}</p>
                    <p><strong>When:</strong> {msg.cardData.appointment.date} at {msg.cardData.appointment.time}</p>
                  </div>

                  <div className="bg-rose-950/50 p-2 rounded-xl text-[10px] text-rose-300 flex items-center gap-1.5 border border-rose-900/40">
                    <Mail className="w-3.5 h-3.5 text-amber-300 shrink-0" />
                    <span>Automated email confirmation dispatched to {msg.cardData.appointment.clientEmail}!</span>
                  </div>

                  <div className="pt-1 flex items-center gap-2">
                    <a
                      href={`/api/calendar/export-ics/${msg.cardData.appointment.id}`}
                      download
                      className="flex-1 py-1.5 rounded-lg bg-stone-800 hover:bg-stone-700 text-stone-200 text-[10px] font-semibold flex items-center justify-center gap-1 border border-stone-700"
                    >
                      <Download className="w-3 h-3 text-amber-400" />
                      <span>Download .ics Calendar</span>
                    </a>

                    <button
                      onClick={onViewNotifications}
                      className="px-2.5 py-1.5 rounded-lg bg-rose-900/80 hover:bg-rose-800 text-rose-100 text-[10px] font-semibold"
                    >
                      View Mail Log
                    </button>
                  </div>
                </div>
              )}

              {msg.cardData?.slots && (
                <div className="bg-stone-950 border border-stone-800 rounded-2xl p-3 space-y-2 text-xs">
                  <span className="text-[11px] text-stone-400 font-medium flex items-center gap-1">
                    <Calendar className="w-3.5 h-3.5 text-rose-400" />
                    Available Time Slots:
                  </span>
                  <div className="grid grid-cols-3 gap-1.5">
                    {msg.cardData.slots.map((slot, idx) => (
                      <button
                        key={idx}
                        disabled={!slot.available}
                        onClick={() => handleSend(`I want to book the ${slot.time} slot.`)}
                        className={`py-1.5 px-2 rounded-lg text-[10px] font-medium transition-all ${
                          slot.available
                            ? 'bg-rose-950/80 hover:bg-rose-900 text-rose-200 border border-rose-700/60'
                            : 'bg-stone-900 text-stone-600 border border-stone-800 cursor-not-allowed line-through'
                        }`}
                      >
                        {slot.time}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>

            {msg.sender === 'user' && (
              <div className="w-8 h-8 rounded-full bg-rose-900 border border-rose-700 flex items-center justify-center shrink-0 mt-0.5">
                <User className="w-4 h-4 text-stone-200" />
              </div>
            )}
          </div>
        ))}

        {loading && (
          <div className="flex gap-3 items-center text-stone-400 text-xs italic">
            <div className="w-8 h-8 rounded-full bg-rose-950 border border-rose-700/50 flex items-center justify-center shrink-0 animate-pulse">
              <Bot className="w-4 h-4 text-rose-300" />
            </div>
            <div className="flex items-center gap-1.5 bg-stone-800/80 px-3 py-2 rounded-2xl border border-stone-700">
              <Sparkles className="w-3.5 h-3.5 text-amber-300 animate-spin" />
              <span>Checking calendar availability & salon records...</span>
            </div>
          </div>
        )}

        <div ref={messagesEndRef} />
      </div>

      {/* Suggested Quick Prompts */}
      <div className="p-2 bg-stone-950/90 border-t border-stone-800/80 overflow-x-auto whitespace-nowrap scrollbar-none flex gap-1.5">
        {suggestedPrompts.map((prompt, i) => (
          <button
            key={i}
            onClick={() => handleSend(prompt)}
            className="px-2.5 py-1 rounded-full bg-stone-900 hover:bg-rose-950 text-stone-300 hover:text-rose-200 text-[10px] border border-stone-800 hover:border-rose-700 shrink-0 transition-all"
          >
            {prompt}
          </button>
        ))}
      </div>

      {/* Chat Input */}
      <div className="p-3 bg-stone-950 border-t border-rose-900/40 flex items-center gap-2">
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === 'Enter' && handleSend()}
          placeholder="Ask about treatments, prices, or book..."
          className="flex-1 bg-stone-900 border border-stone-800 rounded-xl px-3.5 py-2 text-xs text-stone-200 placeholder-stone-500 focus:outline-none focus:border-rose-600 transition-all"
        />
        <button
          onClick={() => handleSend()}
          disabled={!input.trim() || loading}
          className="p-2 rounded-xl bg-gradient-to-tr from-rose-600 to-amber-600 text-white disabled:opacity-40 shadow-md transition-all hover:scale-105 active:scale-95"
        >
          <Send className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
};
