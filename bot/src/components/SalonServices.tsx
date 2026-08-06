import React, { useState } from 'react';
import { SalonService, Stylist } from '../types';
import { Sparkles, Clock, Star, ArrowRight, Search, CheckCircle2, ShieldAlert } from 'lucide-react';

interface SalonServicesProps {
  services: SalonService[];
  stylists: Stylist[];
  onSelectService: (service: SalonService) => void;
  onAskChatBot: (query: string) => void;
}

export const SalonServices: React.FC<SalonServicesProps> = ({
  services,
  stylists,
  onSelectService,
  onAskChatBot
}) => {
  const [selectedCategory, setSelectedCategory] = useState<string>('all');
  const [searchQuery, setSearchQuery] = useState<string>('');

  const categories = [
    { id: 'all', label: 'All Treatments' },
    { id: 'hair', label: 'Hair & Styling' },
    { id: 'skincare', label: 'Skincare & Facials' },
    { id: 'nails', label: 'Nails & Pedicures' },
    { id: 'lashes', label: 'Lashes & Brows' },
    { id: 'spa', label: 'Head Spa & Massages' }
  ];

  const filteredServices = services.filter(service => {
    const matchesCategory = selectedCategory === 'all' || service.category === selectedCategory;
    const matchesSearch = service.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                          service.description.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  return (
    <div className="space-y-10 pb-12">
      {/* Hero Welcome Banner */}
      <section className="relative overflow-hidden rounded-3xl bg-gradient-to-br from-stone-900 via-rose-950 to-stone-900 border border-rose-900/40 p-8 sm:p-12 shadow-2xl">
        <div className="absolute top-0 right-0 -mr-16 -mt-16 w-96 h-96 bg-rose-600/10 rounded-full blur-3xl pointer-events-none"></div>
        <div className="absolute bottom-0 left-1/3 -mb-20 w-80 h-80 bg-amber-500/10 rounded-full blur-3xl pointer-events-none"></div>

        <div className="relative z-10 max-w-3xl space-y-4">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full bg-rose-950/80 border border-rose-700/60 text-rose-300 text-xs font-semibold tracking-wider uppercase">
            <Sparkles className="w-3.5 h-3.5 text-amber-300 animate-spin" style={{ animationDuration: '6s' }} />
            <span>AI-Driven Intelligent Scheduling</span>
          </div>

          <h1 className="font-serif text-3xl sm:text-5xl text-rose-50 font-normal leading-tight">
            Elevate Your Beauty Experience with Real-Time Smart Booking
          </h1>

          <p className="text-stone-300 text-sm sm:text-base leading-relaxed font-sans font-light">
            Chat seamlessly with <span className="text-rose-200 font-medium">Aura AI</span> to discover custom treatments, query live calendar availability, and book instant sessions. Instant automated mail confirmations and pre-session reminders keep your calendar updated effortlessly.
          </p>

          <div className="pt-2 flex flex-wrap gap-3">
            <button
              onClick={() => onAskChatBot("What is your most popular facial treatment and how much does it cost?")}
              className="px-4 py-2.5 rounded-xl bg-stone-800/80 hover:bg-stone-800 text-rose-200 text-xs font-medium border border-rose-800/50 flex items-center gap-2 transition-all hover:border-rose-500"
            >
              <Sparkles className="w-3.5 h-3.5 text-amber-400" />
              <span>Ask AI: "Most popular skincare facial?"</span>
            </button>
            <button
              onClick={() => onAskChatBot("Show me available appointment slots for Balayage tomorrow.")}
              className="px-4 py-2.5 rounded-xl bg-stone-800/80 hover:bg-stone-800 text-rose-200 text-xs font-medium border border-rose-800/50 flex items-center gap-2 transition-all hover:border-rose-500"
            >
              <Clock className="w-3.5 h-3.5 text-rose-400" />
              <span>Ask AI: "Available slots tomorrow?"</span>
            </button>
          </div>
        </div>
      </section>

      {/* Category Filter Tabs & Search Bar */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4">
        {/* Category Chips */}
        <div className="flex items-center gap-2 overflow-x-auto pb-2 scrollbar-none">
          {categories.map(cat => (
            <button
              key={cat.id}
              onClick={() => setSelectedCategory(cat.id)}
              className={`px-4 py-2 rounded-xl text-xs font-medium whitespace-nowrap transition-all ${
                selectedCategory === cat.id
                  ? 'bg-rose-900 text-rose-100 border border-rose-600 shadow-md shadow-rose-950/40'
                  : 'bg-stone-900/80 text-stone-400 hover:text-stone-200 border border-stone-800 hover:bg-stone-800'
              }`}
            >
              {cat.label}
            </button>
          ))}
        </div>

        {/* Search Bar */}
        <div className="relative w-full md:w-72">
          <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-stone-500" />
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search treatments or pricing..."
            className="w-full bg-stone-900 border border-stone-800 rounded-xl pl-10 pr-4 py-2 text-xs text-stone-200 placeholder-stone-500 focus:outline-none focus:border-rose-600 transition-all"
          />
        </div>
      </div>

      {/* Services Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {filteredServices.map(service => (
          <div
            key={service.id}
            className="group bg-stone-900/90 border border-stone-800 hover:border-rose-800/80 rounded-2xl overflow-hidden shadow-lg transition-all duration-300 hover:-translate-y-1 flex flex-col justify-between"
          >
            <div>
              {/* Service Thumbnail Image */}
              <div className="relative h-48 w-full overflow-hidden bg-stone-950">
                <img
                  src={service.image}
                  alt={service.name}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500 opacity-90 group-hover:opacity-100"
                />
                <div className="absolute inset-0 bg-gradient-to-t from-stone-900 via-transparent to-transparent"></div>

                {service.popular && (
                  <div className="absolute top-3 left-3 bg-rose-600/90 text-rose-50 text-[10px] font-bold uppercase tracking-wider px-2.5 py-1 rounded-full shadow-md flex items-center gap-1 backdrop-blur-sm">
                    <Sparkles className="w-3 h-3 text-amber-300" />
                    <span>Popular Choice</span>
                  </div>
                )}

                <div className="absolute bottom-3 right-3 bg-stone-950/80 text-amber-300 border border-amber-500/30 font-serif font-semibold text-lg px-3 py-1 rounded-xl backdrop-blur-md">
                  ${service.price}
                </div>
              </div>

              {/* Card Body */}
              <div className="p-5 space-y-3">
                <div className="flex items-center justify-between">
                  <h3 className="font-serif text-lg text-rose-100 font-medium group-hover:text-amber-200 transition-colors">
                    {service.name}
                  </h3>
                </div>

                <p className="text-stone-400 text-xs leading-relaxed line-clamp-3">
                  {service.description}
                </p>

                {service.recommendedFor && (
                  <div className="bg-stone-950/60 p-2.5 rounded-xl border border-stone-800/80 text-[11px] text-stone-300 flex items-start gap-1.5">
                    <CheckCircle2 className="w-3.5 h-3.5 text-rose-400 shrink-0 mt-0.5" />
                    <span><strong className="text-stone-200">Ideal for:</strong> {service.recommendedFor}</span>
                  </div>
                )}
              </div>
            </div>

            {/* Card Footer Actions */}
            <div className="p-5 pt-0 space-y-2">
              <div className="flex items-center justify-between text-xs text-stone-400 pb-2 border-b border-stone-800">
                <div className="flex items-center gap-1">
                  <Clock className="w-3.5 h-3.5 text-rose-400" />
                  <span>{service.durationMinutes} mins</span>
                </div>
                <button
                  onClick={() => onAskChatBot(`Tell me more about ${service.name} and check available times.`)}
                  className="text-rose-300 hover:text-rose-100 text-[11px] font-medium flex items-center gap-1 transition-colors"
                >
                  <Sparkles className="w-3 h-3 text-amber-400" />
                  <span>Ask Aura</span>
                </button>
              </div>

              <button
                onClick={() => onSelectService(service)}
                className="w-full py-2.5 rounded-xl bg-stone-800 hover:bg-rose-900 hover:text-white text-rose-200 text-xs font-semibold border border-stone-700 hover:border-rose-600 flex items-center justify-center gap-2 transition-all shadow-md group-hover:shadow-rose-950/50"
              >
                <span>Select & Book Session</span>
                <ArrowRight className="w-3.5 h-3.5 transition-transform group-hover:translate-x-1" />
              </button>
            </div>
          </div>
        ))}
      </div>

      {/* Meet Our Master Stylists & Specialists Section */}
      <div className="pt-10 border-t border-stone-800/80 space-y-6">
        <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2">
          <div>
            <h2 className="font-serif text-2xl text-rose-100">Our Beauty Specialists & Master Stylists</h2>
            <p className="text-xs text-stone-400">Select your preferred expert or let Aura AI match you based on session goals.</p>
          </div>
        </div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5">
          {stylists.map(stylist => (
            <div key={stylist.id} className="bg-stone-900 border border-stone-800 rounded-2xl p-4 flex items-center gap-4 hover:border-rose-800/60 transition-all">
              <img
                src={stylist.avatar}
                alt={stylist.name}
                className="w-14 h-14 rounded-full object-cover border-2 border-rose-900/60 shadow-md"
              />
              <div className="space-y-1">
                <div className="flex items-center gap-1.5">
                  <h4 className="font-serif text-sm text-stone-200 font-medium">{stylist.name}</h4>
                  <span className="flex items-center text-[10px] text-amber-400 font-bold bg-amber-950/80 px-1.5 py-0.2 rounded border border-amber-600/40">
                    <Star className="w-2.5 h-2.5 fill-amber-400 mr-0.5" />
                    {stylist.rating}
                  </span>
                </div>
                <p className="text-[11px] text-rose-300">{stylist.role}</p>
                <div className="flex flex-wrap gap-1 pt-1">
                  {stylist.specialties.map((spec, i) => (
                    <span key={i} className="text-[9px] bg-stone-950 text-stone-400 px-1.5 py-0.5 rounded border border-stone-800">
                      {spec}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
};
