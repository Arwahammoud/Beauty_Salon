import React from 'react';
import { Sparkles, Calendar, Bell, Scissors, Bot, UserCheck, Shield, Smartphone, Code } from 'lucide-react';

interface HeaderProps {
  activeTab: 'explore' | 'mobile_flow' | 'api_portal' | 'calendar' | 'appointments' | 'notifications';
  setActiveTab: (tab: 'explore' | 'mobile_flow' | 'api_portal' | 'calendar' | 'appointments' | 'notifications') => void;
  unreadNotificationsCount: number;
  upcomingCount: number;
  isChatOpen: boolean;
  setIsChatOpen: (open: boolean) => void;
  isAdminMode: boolean;
  setIsAdminMode: (admin: boolean) => void;
  onBookClick: () => void;
}

export const Header: React.FC<HeaderProps> = ({
  activeTab,
  setActiveTab,
  unreadNotificationsCount,
  upcomingCount,
  isChatOpen,
  setIsChatOpen,
  isAdminMode,
  setIsAdminMode,
  onBookClick
}) => {
  return (
    <header className="sticky top-0 z-40 bg-stone-900/90 backdrop-blur-md border-b border-rose-900/30 text-stone-100 shadow-xl">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between gap-2">
        
        {/* Brand Logo & Name */}
        <div className="flex items-center gap-3 cursor-pointer shrink-0" onClick={() => setActiveTab('explore')}>
          <div className="w-11 h-11 rounded-full bg-gradient-to-tr from-rose-600 via-pink-500 to-amber-300 p-0.5 shadow-lg shadow-rose-950/50">
            <div className="w-full h-full bg-stone-950 rounded-full flex items-center justify-center">
              <Scissors className="w-5 h-5 text-rose-300" />
            </div>
          </div>
          <div>
            <span className="font-serif text-xl sm:text-2xl tracking-wide bg-gradient-to-r from-rose-100 via-pink-200 to-amber-200 bg-clip-text text-transparent font-medium">
              Velvet & Glow
            </span>
            <span className="hidden sm:block text-[11px] text-rose-300/80 tracking-widest uppercase font-sans">
              Luxury Salon & AI Platform
            </span>
          </div>
        </div>

        {/* Navigation Tabs */}
        <nav className="hidden md:flex items-center gap-1 bg-stone-950/60 p-1.5 rounded-full border border-stone-800 overflow-x-auto">
          <button
            onClick={() => setActiveTab('explore')}
            className={`px-3 py-1.5 rounded-full text-xs font-medium transition-all ${
              activeTab === 'explore'
                ? 'bg-rose-900/60 text-rose-100 border border-rose-700/50 shadow-inner'
                : 'text-stone-400 hover:text-stone-200 hover:bg-stone-900/50'
            }`}
          >
            Services Catalog
          </button>

          <button
            onClick={() => setActiveTab('mobile_flow')}
            className={`px-3 py-1.5 rounded-full text-xs font-medium flex items-center gap-1.5 transition-all ${
              activeTab === 'mobile_flow'
                ? 'bg-rose-900/60 text-rose-100 border border-rose-700/50 shadow-inner'
                : 'text-stone-400 hover:text-stone-200 hover:bg-stone-900/50'
            }`}
          >
            <Smartphone className="w-3.5 h-3.5 text-rose-300" />
            <span>Mobile UI Flow</span>
          </button>

          <button
            onClick={() => setActiveTab('api_portal')}
            className={`px-3 py-1.5 rounded-full text-xs font-medium flex items-center gap-1.5 transition-all ${
              activeTab === 'api_portal'
                ? 'bg-amber-950/80 text-amber-200 border border-amber-600/60 shadow-inner'
                : 'text-stone-400 hover:text-stone-200 hover:bg-stone-900/50'
            }`}
          >
            <Code className="w-3.5 h-3.5 text-amber-400" />
            <span>APIs & Integration</span>
          </button>

          <button
            onClick={() => setActiveTab('calendar')}
            className={`px-3 py-1.5 rounded-full text-xs font-medium flex items-center gap-1.5 transition-all ${
              activeTab === 'calendar'
                ? 'bg-rose-900/60 text-rose-100 border border-rose-700/50 shadow-inner'
                : 'text-stone-400 hover:text-stone-200 hover:bg-stone-900/50'
            }`}
          >
            <Calendar className="w-3.5 h-3.5 text-rose-300" />
            <span>Schedule</span>
          </button>

          <button
            onClick={() => setActiveTab('appointments')}
            className={`px-3 py-1.5 rounded-full text-xs font-medium flex items-center gap-1.5 transition-all ${
              activeTab === 'appointments'
                ? 'bg-rose-900/60 text-rose-100 border border-rose-700/50 shadow-inner'
                : 'text-stone-400 hover:text-stone-200 hover:bg-stone-900/50'
            }`}
          >
            <UserCheck className="w-3.5 h-3.5 text-rose-300" />
            <span>Bookings</span>
            {upcomingCount > 0 && (
              <span className="px-1.5 py-0.5 rounded-full text-[10px] bg-rose-600 text-white font-bold">
                {upcomingCount}
              </span>
            )}
          </button>

          <button
            onClick={() => setActiveTab('notifications')}
            className={`px-3 py-1.5 rounded-full text-xs font-medium flex items-center gap-1.5 transition-all relative ${
              activeTab === 'notifications'
                ? 'bg-rose-900/60 text-rose-100 border border-rose-700/50 shadow-inner'
                : 'text-stone-400 hover:text-stone-200 hover:bg-stone-900/50'
            }`}
          >
            <Bell className="w-3.5 h-3.5 text-rose-300" />
            <span>Mail Alerts</span>
            {unreadNotificationsCount > 0 && (
              <span className="w-2 h-2 rounded-full bg-rose-500 animate-pulse"></span>
            )}
          </button>
        </nav>

        {/* Action Controls & AI Chat Bot Trigger */}
        <div className="flex items-center gap-2 sm:gap-3 shrink-0">
          
          {/* Admin Mode Toggle */}
          <button
            onClick={() => setIsAdminMode(!isAdminMode)}
            title="Toggle Salon Staff / Admin View"
            className={`px-2.5 py-1.5 rounded-lg text-[11px] font-medium flex items-center gap-1.5 border transition-all ${
              isAdminMode
                ? 'bg-amber-950/80 border-amber-600/60 text-amber-200'
                : 'bg-stone-900 border-stone-800 text-stone-400 hover:text-stone-200'
            }`}
          >
            <Shield className="w-3.5 h-3.5 text-amber-400" />
            <span className="hidden lg:inline">{isAdminMode ? 'Staff Mode ON' : 'Staff Mode'}</span>
          </button>

          {/* AI Assistant Button */}
          <button
            onClick={() => setIsChatOpen(!isChatOpen)}
            className={`px-3 py-1.5 rounded-full text-xs font-medium flex items-center gap-1.5 border transition-all shadow-md ${
              isChatOpen
                ? 'bg-gradient-to-r from-rose-700 to-amber-700 border-rose-500 text-white ring-2 ring-rose-500/30'
                : 'bg-stone-800/90 border-stone-700 text-stone-200 hover:bg-stone-800 hover:border-rose-500/50'
            }`}
          >
            <Bot className="w-4 h-4 text-rose-300 animate-bounce" />
            <span className="hidden sm:inline">Ask AI</span>
            <Sparkles className="w-3 h-3 text-amber-300" />
          </button>

          {/* Book Now Primary Button */}
          <button
            onClick={onBookClick}
            className="px-3.5 py-1.5 rounded-full text-xs font-semibold bg-gradient-to-r from-rose-600 via-pink-600 to-amber-600 hover:from-rose-500 hover:to-amber-500 text-white shadow-lg shadow-rose-950/50 transition-all transform hover:scale-[1.02] active:scale-95"
          >
            Book Session
          </button>
        </div>
      </div>

      {/* Mobile Nav Bar */}
      <div className="md:hidden flex items-center justify-around bg-stone-950 border-t border-stone-800/80 px-2 py-2 overflow-x-auto">
        <button
          onClick={() => setActiveTab('explore')}
          className={`flex flex-col items-center gap-0.5 text-[10px] ${
            activeTab === 'explore' ? 'text-rose-400 font-semibold' : 'text-stone-400'
          }`}
        >
          <Scissors className="w-3.5 h-3.5" />
          <span>Services</span>
        </button>
        <button
          onClick={() => setActiveTab('mobile_flow')}
          className={`flex flex-col items-center gap-0.5 text-[10px] ${
            activeTab === 'mobile_flow' ? 'text-rose-400 font-semibold' : 'text-stone-400'
          }`}
        >
          <Smartphone className="w-3.5 h-3.5" />
          <span>UI Flow</span>
        </button>
        <button
          onClick={() => setActiveTab('api_portal')}
          className={`flex flex-col items-center gap-0.5 text-[10px] ${
            activeTab === 'api_portal' ? 'text-amber-400 font-semibold' : 'text-stone-400'
          }`}
        >
          <Code className="w-3.5 h-3.5" />
          <span>APIs</span>
        </button>
        <button
          onClick={() => setActiveTab('calendar')}
          className={`flex flex-col items-center gap-0.5 text-[10px] ${
            activeTab === 'calendar' ? 'text-rose-400 font-semibold' : 'text-stone-400'
          }`}
        >
          <Calendar className="w-3.5 h-3.5" />
          <span>Schedule</span>
        </button>
        <button
          onClick={() => setActiveTab('appointments')}
          className={`flex flex-col items-center gap-0.5 text-[10px] relative ${
            activeTab === 'appointments' ? 'text-rose-400 font-semibold' : 'text-stone-400'
          }`}
        >
          <UserCheck className="w-3.5 h-3.5" />
          <span>Sessions</span>
        </button>
      </div>
    </header>
  );
};
