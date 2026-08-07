import { SalonService, Stylist } from '../types';

export const SALON_SERVICES: SalonService[] = [
  {
    id: 'hair-1',
    name: 'Highlights / Balayage',
    category: 'hair',
    price: 580,
    durationMinutes: 180,
    description: 'Hand-painted dimensional highlights for a sun-kissed finish tailored to your hair structure.',
    popular: true,
    image: 'https://images.unsplash.com/photo-1562322140-8baeececf3df?auto=format&fit=crop&w=800&q=80',
    recommendedFor: 'All hair types seeking natural dimension & long-lasting shine.'
  },
  {
    id: 'hair-2',
    name: 'Keratin Smoothing Hair Treatment',
    category: 'hair',
    price: 450,
    durationMinutes: 90,
    description: 'Deeply restoring silk protein treatment to eliminate frizz, enhance shine, and cut down daily styling time.',
    popular: true,
    image: 'https://images.unsplash.com/photo-1522337360788-8b13dee7a37e?auto=format&fit=crop&w=800&q=80',
    recommendedFor: 'Frizzy, color-treated, or rebellious wavy hair.'
  },
  {
    id: 'hair-3',
    name: 'Precision Cut & Couture Blowout',
    category: 'hair',
    price: 250,
    durationMinutes: 60,
    description: 'Comprehensive consultation, scalp massage, bespoke cut tailored to face shape, and salon blowout.',
    image: 'https://images.unsplash.com/photo-1595476108010-b4d1f102b1b1?auto=format&fit=crop&w=800&q=80'
  },
  {
    id: 'skin-1',
    name: 'Velvet HydraFacial Glow',
    category: 'skincare',
    price: 600,
    durationMinutes: 60,
    description: 'Non-invasive 3-step skin resurfacing combining vortex extraction, exfoliation, and hyaluronic acid hydration.',
    popular: true,
    image: 'https://images.unsplash.com/photo-1570172619644-dfd03ed5d881?auto=format&fit=crop&w=800&q=80'
  },
  {
    id: 'skin-2',
    name: '24K Gold Collagen Radiance Facial',
    category: 'skincare',
    price: 750,
    durationMinutes: 75,
    description: 'Luxurious anti-aging facial featuring bio-active gold peptides and LED light therapy.',
    image: 'https://images.unsplash.com/photo-1512290900676-26c2a4a4b5b3?auto=format&fit=crop&w=800&q=80'
  },
  {
    id: 'nail-1',
    name: 'Luxury Gel Spa Manicure & Art',
    category: 'nails',
    price: 220,
    durationMinutes: 50,
    description: 'Nail shaping, cuticle care, organic scrub, hand massage, and non-toxic gel polish with accent art.',
    image: 'https://images.unsplash.com/photo-1604654894610-df63bc536371?auto=format&fit=crop&w=800&q=80'
  }
];

export const SALON_STYLISTS: Stylist[] = [
  {
    id: 'stylist-layla',
    name: 'Layla Hassan',
    role: 'Senior Hair Stylist',
    avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=300&q=80',
    rating: 4.9,
    specialties: ['Balayage', 'Highlights', 'Precision Cuts']
  },
  {
    id: 'stylist-2',
    name: 'Sophia Chen',
    role: 'Senior Esthetician',
    avatar: 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=300&q=80',
    rating: 5.0,
    specialties: ['HydraFacial', '24K Gold Facial']
  },
  {
    id: 'stylist-3',
    name: 'Camila Vance',
    role: 'Nail & Brow Sculptor',
    avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
    rating: 4.8,
    specialties: ['Gel Nail Art', 'Lash Lamination']
  }
];

export const DEFAULT_TIME_SLOTS = [
  '09:00',
  '09:30',
  '10:00',
  '10:30',
  '11:00',
  '11:30',
  '12:00',
  '13:00',
  '14:00',
  '15:00',
  '15:30',
  '16:00',
  '18:00',
  '18:30',
  '19:00',
  '19:30'
];
