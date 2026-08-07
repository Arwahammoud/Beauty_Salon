// Fills the local database with demo data so the app has something real to
// show: categories, services (+ specialists), offers, notifications, a couple
// of bookings and reviews, plus the demo customer + admin accounts used by
// the "Use" buttons on the login screen.
//
// Run with: node src/scripts/seed.js
// Safe to re-run — it wipes the collections below before inserting.

require("dotenv").config();
const mongoose = require("mongoose");
const connectDB = require("../utils/connectDB");
const passwordService = require("../utils/passwordService");

const User = require("../models/User");
const Category = require("../models/Category");
const Service = require("../models/Service");
const Specialist = require("../models/Specialist");
const Offer = require("../models/Offer");
const Notification = require("../models/Notification");
const Appointment = require("../models/Appointments");
const Review = require("../models/Review");
const BlockedSlot = require("../models/BlockedSlot");

// Same content as frontend/assets/data/services.json, grouped by category.
// Kept as plain data here so the backend doesn't depend on reaching into the
// frontend folder to seed itself.
const CATEGORIES = [
    { name: "Hair", emoji: "✂️" },
    { name: "Nails", emoji: "💅" },
    { name: "Skincare", emoji: "✨" },
    { name: "Laser", emoji: "⚡" },
    { name: "Spa", emoji: "🌸" },
    { name: "Makeup", emoji: "💄" },
    { name: "Medical", emoji: "🩺" },
    { name: "Products", emoji: "🛍️" },
];

const SERVICES_BY_CATEGORY = {
    Hair: [
        { name: "Haircut & Style", duration: 45, rating: 4.8, reviewsCount: 128, price: 180, image: "assets/images/hair_section.webp", description: "A professional haircut and blowdry tailored to your face shape and personal style.", benefits: ["Face shape assessment", "Premium styling products", "Blow dry & finish"], specialist: { name: "Sara Al Mansoori", role: "Senior Hair Stylist", rating: 4.9, experienceYears: 7, image: "assets/images/hair_section.webp" } },
        { name: "Trim & Refresh", duration: 25, rating: 4.8, reviewsCount: 96, price: 90, image: "assets/images/hair_section.webp", description: "Quick trim to remove split ends and refresh your current style.", benefits: ["Split-end removal", "Shape maintenance", "Quick finish"], specialist: { name: "Nour Hassan", role: "Hair Stylist", rating: 4.7, experienceYears: 4, image: "assets/images/hair_section.webp" } },
        { name: "Full Hair Coloring", duration: 120, rating: 4.8, reviewsCount: 210, price: 420, image: "assets/images/hair_section.webp", description: "Full root-to-tip color transformation using premium ammonia-free dyes.", benefits: ["Root-to-tip coverage", "Ammonia-free dye", "Conditioning treatment included"], specialist: { name: "Lina Khoury", role: "Color Specialist", rating: 4.9, experienceYears: 9, image: "assets/images/hair_section.webp" } },
        { name: "Highlights / Balayage", duration: 180, rating: 4.8, reviewsCount: 187, price: 580, image: "assets/images/hair_section.webp", description: "Hand-painted balayage or foil highlights for a natural, sun-kissed effect.", benefits: ["Natural gradient effect", "Low maintenance look", "Toning included"], specialist: { name: "Lina Khoury", role: "Color Specialist", rating: 4.9, experienceYears: 9, image: "assets/images/hair_section.webp" } },
        { name: "Keratin Treatment", duration: 150, rating: 4.8, reviewsCount: 155, price: 750, image: "assets/images/hair_section.webp", description: "Brazilian keratin smoothing treatment for frizz-free, shiny hair lasting up to 3 months.", benefits: ["Frizz elimination", "Long-lasting results", "Deep conditioning"], specialist: { name: "Sara Al Mansoori", role: "Senior Hair Stylist", rating: 4.9, experienceYears: 7, image: "assets/images/hair_section.webp" } },
        { name: "Deep Conditioning", duration: 45, rating: 4.7, reviewsCount: 102, price: 150, image: "assets/images/hair_section.webp", description: "Intensive hydrating mask treatment to restore moisture and shine to damaged hair.", benefits: ["Deep hydration", "Damage repair", "Scalp nourishment"], specialist: { name: "Nour Hassan", role: "Hair Stylist", rating: 4.7, experienceYears: 4, image: "assets/images/hair_section.webp" } },
    ],
    Nails: [
        { name: "Classic Manicure", duration: 30, rating: 4.7, reviewsCount: 145, price: 80, image: "assets/images/Nails_1.jpg", description: "Shape, cuticle care, hand massage, and classic polish of your choice.", benefits: ["Nail shaping & filing", "Cuticle removal", "Hand massage"], specialist: { name: "Farah Salem", role: "Nail Technician", rating: 4.8, experienceYears: 5, image: "assets/images/Nails_1.jpg" } },
        { name: "Gel Manicure", duration: 45, rating: 4.9, reviewsCount: 203, price: 120, image: "assets/images/Nails_1.jpg", description: "Long-lasting gel polish that stays chip-free for up to 3 weeks.", benefits: ["Chip-free up to 3 weeks", "High-gloss finish", "UV cured"], specialist: { name: "Farah Salem", role: "Nail Technician", rating: 4.8, experienceYears: 5, image: "assets/images/Nails_1.jpg" } },
        { name: "Nail Art Design", duration: 60, rating: 4.8, reviewsCount: 168, price: 150, image: "assets/images/Nails_1.jpg", description: "Custom nail art with detailed hand-painted designs, gems, or stencil work.", benefits: ["Custom design", "Gems & foils available", "Long-lasting finish"], specialist: { name: "Rima Al Azi", role: "Nail Artist", rating: 4.9, experienceYears: 6, image: "assets/images/Nails_1.jpg" } },
        { name: "Pedicure Spa", duration: 45, rating: 4.6, reviewsCount: 119, price: 100, image: "assets/images/Nails_1.jpg", description: "Relaxing foot soak, scrub, massage, and polish for beautiful feet.", benefits: ["Foot soak & scrub", "Callus removal", "Relaxing massage"], specialist: { name: "Farah Salem", role: "Nail Technician", rating: 4.8, experienceYears: 5, image: "assets/images/Nails_1.jpg" } },
        { name: "Acrylic Extensions", duration: 90, rating: 4.7, reviewsCount: 134, price: 200, image: "assets/images/Nails_1.jpg", description: "Full set of acrylic nail extensions sculpted to your desired length and shape.", benefits: ["Custom length & shape", "Durable finish", "Polish included"], specialist: { name: "Rima Al Azi", role: "Nail Artist", rating: 4.9, experienceYears: 6, image: "assets/images/Nails_1.jpg" } },
    ],
    Skincare: [
        { name: "Deep Cleansing Facial", duration: 60, rating: 4.9, reviewsCount: 232, price: 250, image: "assets/images/potoks.jpg", description: "Deep pore cleansing with steam, extraction, mask, and SPF finish.", benefits: ["Pore cleansing", "Blackhead extraction", "Hydrating mask"], specialist: { name: "Dr. Hana Yousef", role: "Skin Care Specialist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
        { name: "Hydrafacial", duration: 75, rating: 4.9, reviewsCount: 289, price: 450, image: "assets/images/potoks.jpg", description: "Multi-step hydradermabrasion treatment that cleanses, exfoliates, and infuses serums.", benefits: ["Instant glow", "Deep hydration", "No downtime"], specialist: { name: "Dr. Hana Yousef", role: "Skin Care Specialist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
        { name: "Chemical Peel", duration: 45, rating: 4.7, reviewsCount: 176, price: 350, image: "assets/images/potoks.jpg", description: "Controlled chemical exfoliation to improve texture, tone, and pigmentation.", benefits: ["Removes dead skin", "Brightening effect", "Reduces hyperpigmentation"], specialist: { name: "Dr. Maya Nasser", role: "Dermatology Specialist", rating: 4.8, experienceYears: 10, image: "assets/images/potoks.jpg" } },
        { name: "Anti-Aging Treatment", duration: 90, rating: 4.8, reviewsCount: 143, price: 550, image: "assets/images/potoks.jpg", description: "Targeted treatment combining peptides, LED therapy, and firming massage for youthful skin.", benefits: ["Firming & lifting", "Fine lines reduction", "LED therapy"], specialist: { name: "Dr. Maya Nasser", role: "Dermatology Specialist", rating: 4.8, experienceYears: 10, image: "assets/images/potoks.jpg" } },
        { name: "Microdermabrasion", duration: 45, rating: 4.6, reviewsCount: 112, price: 300, image: "assets/images/potoks.jpg", description: "Non-invasive exfoliation that removes dead skin cells for a smoother complexion.", benefits: ["Smooth texture", "Reduces scars", "Brightening"], specialist: { name: "Dr. Hana Yousef", role: "Skin Care Specialist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
    ],
    Laser: [
        { name: "Underarm Laser", duration: 15, rating: 4.7, reviewsCount: 198, price: 150, image: "assets/images/lizar.jpg", description: "Fast and effective laser hair removal for the underarm area.", benefits: ["Permanent reduction", "Painless treatment", "No ingrown hairs"], specialist: { name: "Dr. Rana Khalil", role: "Laser Specialist", rating: 4.9, experienceYears: 7, image: "assets/images/lizar.jpg" } },
        { name: "Full Legs Laser", duration: 45, rating: 4.8, reviewsCount: 156, price: 400, image: "assets/images/lizar.jpg", description: "Full legs laser hair removal from thigh to ankle for silky-smooth skin.", benefits: ["Full coverage", "Long-lasting results", "Smooth finish"], specialist: { name: "Dr. Rana Khalil", role: "Laser Specialist", rating: 4.9, experienceYears: 7, image: "assets/images/lizar.jpg" } },
        { name: "Brazilian Laser", duration: 30, rating: 4.6, reviewsCount: 134, price: 350, image: "assets/images/lizar.jpg", description: "Complete bikini area laser hair removal with full Brazilian coverage.", benefits: ["Full coverage", "Minimal discomfort", "Permanent reduction"], specialist: { name: "Dr. Rana Khalil", role: "Laser Specialist", rating: 4.9, experienceYears: 7, image: "assets/images/lizar.jpg" } },
        { name: "Facial Laser", duration: 20, rating: 4.7, reviewsCount: 167, price: 180, image: "assets/images/lizar.jpg", description: "Precision laser treatment for facial hair including upper lip, chin, and sideburns.", benefits: ["Precise targeting", "No nicks or cuts", "Quick session"], specialist: { name: "Dr. Rana Khalil", role: "Laser Specialist", rating: 4.9, experienceYears: 7, image: "assets/images/lizar.jpg" } },
        { name: "Full Body Laser", duration: 120, rating: 4.9, reviewsCount: 89, price: 1200, image: "assets/images/lizar.jpg", description: "Complete full-body laser hair removal package covering all areas in one session.", benefits: ["Full body coverage", "Best value", "Comprehensive results"], specialist: { name: "Dr. Rana Khalil", role: "Laser Specialist", rating: 4.9, experienceYears: 7, image: "assets/images/lizar.jpg" } },
    ],
    Spa: [
        { name: "Swedish Massage", duration: 60, rating: 4.9, reviewsCount: 267, price: 250, image: "assets/images/potoks.jpg", description: "Classic full-body relaxation massage using long gliding strokes and gentle pressure.", benefits: ["Full body relaxation", "Stress relief", "Improved circulation"], specialist: { name: "Yasmin Al Rashid", role: "Massage Therapist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
        { name: "Deep Tissue Massage", duration: 60, rating: 4.8, reviewsCount: 189, price: 300, image: "assets/images/potoks.jpg", description: "Targets deep muscle layers to relieve chronic tension and knots.", benefits: ["Muscle knot relief", "Deep pressure", "Pain reduction"], specialist: { name: "Yasmin Al Rashid", role: "Massage Therapist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
        { name: "Hot Stone Therapy", duration: 90, rating: 4.9, reviewsCount: 145, price: 350, image: "assets/images/potoks.jpg", description: "Warm basalt stones combined with massage to melt away tension and stress.", benefits: ["Heat therapy", "Deep relaxation", "Improved blood flow"], specialist: { name: "Dana Farouk", role: "Spa Therapist", rating: 4.8, experienceYears: 6, image: "assets/images/potoks.jpg" } },
        { name: "Aromatherapy Massage", duration: 75, rating: 4.7, reviewsCount: 132, price: 280, image: "assets/images/potoks.jpg", description: "Therapeutic massage using essential oils tailored to your mood and needs.", benefits: ["Essential oil therapy", "Mood elevation", "Skin nourishment"], specialist: { name: "Dana Farouk", role: "Spa Therapist", rating: 4.8, experienceYears: 6, image: "assets/images/potoks.jpg" } },
        { name: "Body Scrub", duration: 45, rating: 4.6, reviewsCount: 119, price: 200, image: "assets/images/potoks.jpg", description: "Full-body exfoliation using sugar or salt scrubs for silky-smooth, glowing skin.", benefits: ["Full body exfoliation", "Smooth skin", "Increased glow"], specialist: { name: "Yasmin Al Rashid", role: "Massage Therapist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
    ],
    Makeup: [
        { name: "Natural Glam", duration: 45, rating: 4.8, reviewsCount: 178, price: 200, image: "assets/images/scancare.jpg", description: "A fresh, everyday glam look with flawless skin and subtle definition.", benefits: ["Flawless base", "Natural finish", "All-day wear"], specialist: { name: "Hessa Al Amri", role: "Makeup Artist", rating: 4.9, experienceYears: 7, image: "assets/images/scancare.jpg" } },
        { name: "Bridal Makeup", duration: 120, rating: 4.9, reviewsCount: 223, price: 800, image: "assets/images/scancare.jpg", description: "Luxurious bridal makeup with trial session, long-wear formula, and touch-up kit.", benefits: ["Trial session included", "Long-wear formula", "Touch-up kit"], specialist: { name: "Hessa Al Amri", role: "Makeup Artist", rating: 4.9, experienceYears: 7, image: "assets/images/scancare.jpg" } },
        { name: "Evening Look", duration: 60, rating: 4.7, reviewsCount: 152, price: 300, image: "assets/images/scancare.jpg", description: "Glamorous evening makeup with smokey eye or bold lip tailored to your outfit.", benefits: ["Smokey or bold lip", "High-glam finish", "Long-lasting"], specialist: { name: "Mona Badawi", role: "Beauty Artist", rating: 4.8, experienceYears: 5, image: "assets/images/scancare.jpg" } },
        { name: "Airbrush Makeup", duration: 60, rating: 4.9, reviewsCount: 196, price: 350, image: "assets/images/scancare.jpg", description: "Ultra-lightweight airbrush foundation for a flawless, camera-ready finish.", benefits: ["Weightless formula", "Camera-ready finish", "Waterproof"], specialist: { name: "Hessa Al Amri", role: "Makeup Artist", rating: 4.9, experienceYears: 7, image: "assets/images/scancare.jpg" } },
        { name: "Lash Application", duration: 30, rating: 4.8, reviewsCount: 134, price: 150, image: "assets/images/scancare.jpg", description: "Individual or strip lash application for dramatic, full lashes.", benefits: ["Natural or dramatic", "Premium lashes", "Adhesive included"], specialist: { name: "Mona Badawi", role: "Beauty Artist", rating: 4.8, experienceYears: 5, image: "assets/images/scancare.jpg" } },
    ],
    Medical: [
        { name: "Botox Injection", duration: 30, rating: 4.8, reviewsCount: 212, price: 900, image: "assets/images/lizar.jpg", description: "FDA-approved Botox treatment to smooth forehead lines, crow's feet, and frown lines.", benefits: ["Natural results", "15-minute procedure", "6-month duration"], specialist: { name: "Dr. Amal Jaber", role: "Aesthetic Physician", rating: 4.9, experienceYears: 12, image: "assets/images/lizar.jpg" } },
        { name: "Dermal Fillers", duration: 45, rating: 4.9, reviewsCount: 178, price: 1200, image: "assets/images/lizar.jpg", description: "Hyaluronic acid fillers for lip enhancement, cheek sculpting, and nasolabial folds.", benefits: ["Instant volume", "Natural HA formula", "12-18 months duration"], specialist: { name: "Dr. Amal Jaber", role: "Aesthetic Physician", rating: 4.9, experienceYears: 12, image: "assets/images/lizar.jpg" } },
        { name: "PRP Treatment", duration: 60, rating: 4.7, reviewsCount: 134, price: 800, image: "assets/images/lizar.jpg", description: "Platelet-rich plasma therapy to rejuvenate skin, reduce fine lines, and boost collagen.", benefits: ["Collagen boost", "Natural regeneration", "Long-term results"], specialist: { name: "Dr. Reem Al Hosani", role: "Medical Aesthetics", rating: 4.8, experienceYears: 9, image: "assets/images/lizar.jpg" } },
        { name: "Mesotherapy", duration: 45, rating: 4.8, reviewsCount: 156, price: 600, image: "assets/images/lizar.jpg", description: "Micro-injections of vitamins, enzymes, and hormones to rejuvenate and tighten skin.", benefits: ["Deep vitamin infusion", "Skin tightening", "Glow restoration"], specialist: { name: "Dr. Reem Al Hosani", role: "Medical Aesthetics", rating: 4.8, experienceYears: 9, image: "assets/images/lizar.jpg" } },
        { name: "IV Vitamin Drip", duration: 60, rating: 4.6, reviewsCount: 98, price: 400, image: "assets/images/lizar.jpg", description: "Customized intravenous vitamin and mineral infusion for energy, immunity, and glow.", benefits: ["Instant energy boost", "Skin brightening", "Immune support"], specialist: { name: "Dr. Amal Jaber", role: "Aesthetic Physician", rating: 4.9, experienceYears: 12, image: "assets/images/lizar.jpg" } },
    ],
    Products: [
        { name: "Argan Oil Kit", duration: 20, rating: 4.9, reviewsCount: 145, price: 280, image: "assets/images/hair_section.webp", description: "Premium Moroccan argan oil set including shampoo, conditioner, and serum.", benefits: ["Deep nourishment", "Frizz control", "Adds shine"], specialist: { name: "Beauty Advisor", role: "Product Consultant", rating: 4.8, experienceYears: 3, image: "assets/images/hair_section.webp" } },
        { name: "Skin Care Bundle", duration: 30, rating: 4.8, reviewsCount: 167, price: 350, image: "assets/images/hair_section.webp", description: "Complete AM/PM skincare routine with cleanser, toner, serum, and SPF moisturiser.", benefits: ["AM & PM routine", "SPF protection", "Dermatologist-tested"], specialist: { name: "Beauty Advisor", role: "Product Consultant", rating: 4.8, experienceYears: 3, image: "assets/images/hair_section.webp" } },
        { name: "Hair Vitamin Pack", duration: 15, rating: 4.7, reviewsCount: 112, price: 150, image: "assets/images/hair_section.webp", description: "30-day supply of biotin, collagen, and hair-strengthening vitamins.", benefits: ["Biotin & collagen", "30-day supply", "Strengthens roots"], specialist: { name: "Beauty Advisor", role: "Product Consultant", rating: 4.8, experienceYears: 3, image: "assets/images/hair_section.webp" } },
        { name: "Body Butter Collection", duration: 20, rating: 4.8, reviewsCount: 134, price: 200, image: "assets/images/hair_section.webp", description: "Luxury whipped body butter trio in rose, vanilla, and coconut scents.", benefits: ["24-hr moisture", "3 scents", "Vegan formula"], specialist: { name: "Beauty Advisor", role: "Product Consultant", rating: 4.8, experienceYears: 3, image: "assets/images/hair_section.webp" } },
        { name: "Nail Care Kit", duration: 15, rating: 4.6, reviewsCount: 89, price: 120, image: "assets/images/Nails_1.jpg", description: "Professional nail care kit with cuticle oil, file, buffer, and strengthener.", benefits: ["Professional tools", "Cuticle care", "Nail strengthener"], specialist: { name: "Beauty Advisor", role: "Product Consultant", rating: 4.8, experienceYears: 3, image: "assets/images/Nails_1.jpg" } },
    ],
};

const daysFromNow = (n) => new Date(Date.now() + n * 24 * 60 * 60 * 1000);

const run = async () => {
    await connectDB();
    // connectDB() logs its own success message but doesn't await the
    // connection promise, so wait for it here before writing.
    await mongoose.connection.asPromise();

    console.log("Clearing existing demo data...");
    await Promise.all([
        User.deleteMany({}),
        Category.deleteMany({}),
        Service.deleteMany({}),
        Specialist.deleteMany({}),
        Offer.deleteMany({}),
        Notification.deleteMany({}),
        Appointment.deleteMany({}),
        Review.deleteMany({}),
        BlockedSlot.deleteMany({}),
    ]);

    console.log("Seeding specialists, categories and services...");
    const specialistsByName = new Map();
    const servicesByName = new Map();

    for (const categoryDef of CATEGORIES) {
        const category = await Category.create({ name: categoryDef.name, emoji: categoryDef.emoji });

        for (const svc of SERVICES_BY_CATEGORY[categoryDef.name]) {
            let specialist = specialistsByName.get(svc.specialist.name);
            if (!specialist) {
                specialist = await Specialist.create(svc.specialist);
                specialistsByName.set(svc.specialist.name, specialist);
            }

            const service = await Service.create({
                name: svc.name,
                description: svc.description,
                price: svc.price,
                duration: svc.duration,
                categoryId: category._id,
                specialistId: specialist._id,
                image: svc.image,
                benefits: svc.benefits,
                averageRating: svc.rating,
                reviewsCount: svc.reviewsCount,
            });
            servicesByName.set(svc.name, service);
        }
    }

    console.log("Seeding demo users (customer + admin)...");
    const customer = await User.create({
        name: process.env.DEMO_NAME || "Kelly Ahmed",
        email: process.env.DEMO_EMAIL || "kelly@belle.com",
        phone: process.env.DEMO_PHONE || "0501234567",
        password: await passwordService.hash(process.env.DEMO_PASSWORD || "Belle1234"),
        role: "customer",
        loyaltyPoints: 50,
    });

    const admin = await User.create({
        name: process.env.ADMIN_NAME || "Salon Owner",
        email: process.env.ADMIN_EMAIL || "admin@belle.com",
        phone: process.env.ADMIN_PHONE || "0509876543",
        password: await passwordService.hash(process.env.ADMIN_PASSWORD || "Admin1234"),
        role: "admin",
    });

    console.log("Seeding offers...");
    await Offer.create([
        {
            badge: "LIMITED",
            title: "20% Off Haircut",
            startDate: daysFromNow(-2),
            endDate: daysFromNow(6),
            discountLabel: "20%",
            image: servicesByName.get("Haircut & Style").image,
            serviceId: servicesByName.get("Haircut & Style")._id,
        },
        {
            badge: "LIMITED",
            title: "Glow Bundle",
            startDate: daysFromNow(-1),
            endDate: daysFromNow(9),
            discountLabel: "30%",
            image: servicesByName.get("Hydrafacial").image,
            serviceId: servicesByName.get("Hydrafacial")._id,
        },
        {
            badge: "LIMITED",
            title: "Bridal Package",
            startDate: daysFromNow(3),
            endDate: daysFromNow(30),
            discountLabel: "15%",
            image: servicesByName.get("Bridal Makeup").image,
            serviceId: servicesByName.get("Bridal Makeup")._id,
        },
    ]);

    console.log("Seeding notifications for the demo customer...");
    await Notification.create([
        { userId: customer._id, title: "New Offer!", body: "Get 20% off your next haircut this week", icon: "offer", read: false },
        { userId: customer._id, title: "Appointment Reminder", body: "Your spa session is tomorrow at 3:00 PM", icon: "calendar", read: false },
        { userId: customer._id, title: "Review Request", body: "How was your last nail art session? Rate us!", icon: "star", read: true },
        { userId: customer._id, title: "Loyalty Points", body: "You earned 50 points from your last visit!", icon: "loyalty", read: true },
    ]);

    console.log("Seeding demo bookings...");
    const bridalMakeup = servicesByName.get("Bridal Makeup");
    const gelManicure = servicesByName.get("Gel Manicure");

    await Appointment.create([
        {
            userId: customer._id,
            serviceId: bridalMakeup._id,
            specialistId: bridalMakeup.specialistId,
            date: daysFromNow(3),
            startTime: "09:30",
            status: "confirmed",
            totalPrice: bridalMakeup.price,
            pointsEarned: Math.round(bridalMakeup.price / 10),
        },
        {
            userId: customer._id,
            serviceId: gelManicure._id,
            specialistId: gelManicure.specialistId,
            date: daysFromNow(-10),
            startTime: "16:00",
            status: "completed",
            totalPrice: gelManicure.price,
            pointsEarned: Math.round(gelManicure.price / 10),
        },
    ]);

    console.log("Seeding demo reviews...");
    const haircut = servicesByName.get("Haircut & Style");
    await Review.create([
        { userId: customer._id, serviceId: haircut._id, comment: "Absolutely loved it — highly recommended!" },
        { userId: admin._id, serviceId: haircut._id, comment: "Best in town, will come back every month." },
    ]);

    console.log("Done. Demo accounts:");
    console.log(`  Customer -> ${customer.email} / ${process.env.DEMO_PASSWORD || "Belle1234"}`);
    console.log(`  Admin    -> ${admin.email} / ${process.env.ADMIN_PASSWORD || "Admin1234"}`);
};

run()
    .catch((err) => console.error("Seed failed:", err))
    .finally(() => mongoose.connection.close());
