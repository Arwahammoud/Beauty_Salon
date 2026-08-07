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
const Offer = require("../models/Offers");
const Notification = require("../models/Notifications");
const Appointment = require("../models/Appointments");
const Review = require("../models/Review");
const BlockedSlot = require("../models/BlockedSlot");

// Same content as frontend/assets/data/services.json, grouped by category.
// Kept as plain data here so the backend doesn't depend on reaching into the
// frontend folder to seed itself.
const CATEGORIES = [
    { name: "Hair", nameAr: "الشعر", image: "assets/images/hair_section.webp" },
    { name: "Nails", nameAr: "الأظافر", image: "assets/images/Nails_1.jpg" },
    { name: "Skincare", nameAr: "العناية بالبشرة", image: "assets/images/scancare.jpg" },
    { name: "Laser", nameAr: "الليزر", image: "assets/images/lizar.jpg" },
    { name: "Spa", nameAr: "السبا", image: "assets/images/potoks.jpg" },
    { name: "Makeup", nameAr: "المكياج", image: "assets/images/scancare.jpg" },
    { name: "Medical", nameAr: "الطب التجميلي", image: "assets/images/lizar.jpg" },
    { name: "Products", nameAr: "المنتجات", image: "assets/images/hair_section.webp" },
];

const SERVICES_BY_CATEGORY = {
    Hair: [
        { name: "Haircut & Style", nameAr: "قصة وتصفيف الشعر", duration: 45, rating: 4.8, reviewsCount: 128, price: 180, image: "assets/images/hair_section.webp", description: "A professional haircut and blowdry tailored to your face shape and personal style.", descriptionAr: "قصة شعر احترافية مع تجفيف يناسب شكل وجهك وأسلوبك الشخصي.", benefits: ["Face shape assessment", "Premium styling products", "Blow dry & finish"], specialist: { name: "Sara Al Mansoori", role: "Senior Hair Stylist", rating: 4.9, experienceYears: 7, image: "assets/images/hair_section.webp" } },
        { name: "Trim & Refresh", nameAr: "تشذيب وتجديد", duration: 25, rating: 4.8, reviewsCount: 96, price: 90, image: "assets/images/hair_section.webp", description: "Quick trim to remove split ends and refresh your current style.", descriptionAr: "تشذيب سريع لإزالة الأطراف المتقصفة وتجديد شكل شعرك الحالي.", benefits: ["Split-end removal", "Shape maintenance", "Quick finish"], specialist: { name: "Nour Hassan", role: "Hair Stylist", rating: 4.7, experienceYears: 4, image: "assets/images/hair_section.webp" } },
        { name: "Full Hair Coloring", nameAr: "صبغة شعر كاملة", duration: 120, rating: 4.8, reviewsCount: 210, price: 420, image: "assets/images/hair_section.webp", description: "Full root-to-tip color transformation using premium ammonia-free dyes.", descriptionAr: "تحويل كامل للون الشعر من الجذور حتى الأطراف باستخدام صبغات فاخرة خالية من الأمونيا.", benefits: ["Root-to-tip coverage", "Ammonia-free dye", "Conditioning treatment included"], specialist: { name: "Lina Khoury", role: "Color Specialist", rating: 4.9, experienceYears: 9, image: "assets/images/hair_section.webp" } },
        { name: "Highlights / Balayage", nameAr: "هايلايت / بالياج", duration: 180, rating: 4.8, reviewsCount: 187, price: 580, image: "assets/images/hair_section.webp", description: "Hand-painted balayage or foil highlights for a natural, sun-kissed effect.", descriptionAr: "تفتيح خصل مرسومة يدوياً أو بالورق لمظهر طبيعي مشمس.", benefits: ["Natural gradient effect", "Low maintenance look", "Toning included"], specialist: { name: "Lina Khoury", role: "Color Specialist", rating: 4.9, experienceYears: 9, image: "assets/images/hair_section.webp" } },
        { name: "Keratin Treatment", nameAr: "علاج الكيراتين", duration: 150, rating: 4.8, reviewsCount: 155, price: 750, image: "assets/images/hair_section.webp", description: "Brazilian keratin smoothing treatment for frizz-free, shiny hair lasting up to 3 months.", descriptionAr: "علاج فرد الكيراتين البرازيلي لشعر ناعم وخالٍ من التجعد يدوم حتى 3 أشهر.", benefits: ["Frizz elimination", "Long-lasting results", "Deep conditioning"], specialist: { name: "Sara Al Mansoori", role: "Senior Hair Stylist", rating: 4.9, experienceYears: 7, image: "assets/images/hair_section.webp" } },
        { name: "Deep Conditioning", nameAr: "ترطيب عميق", duration: 45, rating: 4.7, reviewsCount: 102, price: 150, image: "assets/images/hair_section.webp", description: "Intensive hydrating mask treatment to restore moisture and shine to damaged hair.", descriptionAr: "علاج قناع مرطب مكثف لاستعادة رطوبة ولمعان الشعر التالف.", benefits: ["Deep hydration", "Damage repair", "Scalp nourishment"], specialist: { name: "Nour Hassan", role: "Hair Stylist", rating: 4.7, experienceYears: 4, image: "assets/images/hair_section.webp" } },
    ],
    Nails: [
        { name: "Classic Manicure", nameAr: "مانيكير كلاسيكي", duration: 30, rating: 4.7, reviewsCount: 145, price: 80, image: "assets/images/Nails_1.jpg", description: "Shape, cuticle care, hand massage, and classic polish of your choice.", descriptionAr: "تشكيل الأظافر والعناية بالجلد المحيط وتدليك اليد وطلاء كلاسيكي حسب اختيارك.", benefits: ["Nail shaping & filing", "Cuticle removal", "Hand massage"], specialist: { name: "Farah Salem", role: "Nail Technician", rating: 4.8, experienceYears: 5, image: "assets/images/Nails_1.jpg" } },
        { name: "Gel Manicure", nameAr: "مانيكير جل", duration: 45, rating: 4.9, reviewsCount: 203, price: 120, image: "assets/images/Nails_1.jpg", description: "Long-lasting gel polish that stays chip-free for up to 3 weeks.", descriptionAr: "طلاء جل يدوم دون تقشر لمدة تصل إلى 3 أسابيع.", benefits: ["Chip-free up to 3 weeks", "High-gloss finish", "UV cured"], specialist: { name: "Farah Salem", role: "Nail Technician", rating: 4.8, experienceYears: 5, image: "assets/images/Nails_1.jpg" } },
        { name: "Nail Art Design", nameAr: "تصميم فن الأظافر", duration: 60, rating: 4.8, reviewsCount: 168, price: 150, image: "assets/images/Nails_1.jpg", description: "Custom nail art with detailed hand-painted designs, gems, or stencil work.", descriptionAr: "فن أظافر مخصص برسومات يدوية دقيقة أو جواهر أو استنسل.", benefits: ["Custom design", "Gems & foils available", "Long-lasting finish"], specialist: { name: "Rima Al Azi", role: "Nail Artist", rating: 4.9, experienceYears: 6, image: "assets/images/Nails_1.jpg" } },
        { name: "Pedicure Spa", nameAr: "سبا الأقدام", duration: 45, rating: 4.6, reviewsCount: 119, price: 100, image: "assets/images/Nails_1.jpg", description: "Relaxing foot soak, scrub, massage, and polish for beautiful feet.", descriptionAr: "نقع مريح للقدمين وتقشير وتدليك وطلاء لأقدام جميلة.", benefits: ["Foot soak & scrub", "Callus removal", "Relaxing massage"], specialist: { name: "Farah Salem", role: "Nail Technician", rating: 4.8, experienceYears: 5, image: "assets/images/Nails_1.jpg" } },
        { name: "Acrylic Extensions", nameAr: "تركيب أظافر أكريليك", duration: 90, rating: 4.7, reviewsCount: 134, price: 200, image: "assets/images/Nails_1.jpg", description: "Full set of acrylic nail extensions sculpted to your desired length and shape.", descriptionAr: "طقم كامل من أظافر الأكريليك المنحوتة بالطول والشكل الذي ترغبينه.", benefits: ["Custom length & shape", "Durable finish", "Polish included"], specialist: { name: "Rima Al Azi", role: "Nail Artist", rating: 4.9, experienceYears: 6, image: "assets/images/Nails_1.jpg" } },
    ],
    Skincare: [
        { name: "Deep Cleansing Facial", nameAr: "تنظيف عميق للوجه", duration: 60, rating: 4.9, reviewsCount: 232, price: 250, image: "assets/images/potoks.jpg", description: "Deep pore cleansing with steam, extraction, mask, and SPF finish.", descriptionAr: "تنظيف عميق للمسام بالبخار والتفريغ والقناع مع لمسة أخيرة من واقي الشمس.", benefits: ["Pore cleansing", "Blackhead extraction", "Hydrating mask"], specialist: { name: "Dr. Hana Yousef", role: "Skin Care Specialist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
        { name: "Hydrafacial", nameAr: "هايدرافيشل", duration: 75, rating: 4.9, reviewsCount: 289, price: 450, image: "assets/images/potoks.jpg", description: "Multi-step hydradermabrasion treatment that cleanses, exfoliates, and infuses serums.", descriptionAr: "علاج متعدد الخطوات لتقشير الجلد بالماء ينظف ويقشر ويضخ السيرومات.", benefits: ["Instant glow", "Deep hydration", "No downtime"], specialist: { name: "Dr. Hana Yousef", role: "Skin Care Specialist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
        { name: "Chemical Peel", nameAr: "التقشير الكيميائي", duration: 45, rating: 4.7, reviewsCount: 176, price: 350, image: "assets/images/potoks.jpg", description: "Controlled chemical exfoliation to improve texture, tone, and pigmentation.", descriptionAr: "تقشير كيميائي متحكم به لتحسين الملمس واللون والتصبغات.", benefits: ["Removes dead skin", "Brightening effect", "Reduces hyperpigmentation"], specialist: { name: "Dr. Maya Nasser", role: "Dermatology Specialist", rating: 4.8, experienceYears: 10, image: "assets/images/potoks.jpg" } },
        { name: "Anti-Aging Treatment", nameAr: "علاج مضاد للشيخوخة", duration: 90, rating: 4.8, reviewsCount: 143, price: 550, image: "assets/images/potoks.jpg", description: "Targeted treatment combining peptides, LED therapy, and firming massage for youthful skin.", descriptionAr: "علاج مستهدف يجمع بين الببتيدات والعلاج بالضوء والتدليك الشادّ لبشرة أكثر شباباً.", benefits: ["Firming & lifting", "Fine lines reduction", "LED therapy"], specialist: { name: "Dr. Maya Nasser", role: "Dermatology Specialist", rating: 4.8, experienceYears: 10, image: "assets/images/potoks.jpg" } },
        { name: "Microdermabrasion", nameAr: "التقشير الدقيق للبشرة", duration: 45, rating: 4.6, reviewsCount: 112, price: 300, image: "assets/images/potoks.jpg", description: "Non-invasive exfoliation that removes dead skin cells for a smoother complexion.", descriptionAr: "تقشير غير جراحي يزيل خلايا الجلد الميتة لبشرة أنعم.", benefits: ["Smooth texture", "Reduces scars", "Brightening"], specialist: { name: "Dr. Hana Yousef", role: "Skin Care Specialist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
    ],
    Laser: [
        { name: "Underarm Laser", nameAr: "ليزر الإبط", duration: 15, rating: 4.7, reviewsCount: 198, price: 150, image: "assets/images/lizar.jpg", description: "Fast and effective laser hair removal for the underarm area.", descriptionAr: "إزالة سريعة وفعالة لشعر منطقة الإبط بالليزر.", benefits: ["Permanent reduction", "Painless treatment", "No ingrown hairs"], specialist: { name: "Dr. Rana Khalil", role: "Laser Specialist", rating: 4.9, experienceYears: 7, image: "assets/images/lizar.jpg" } },
        { name: "Full Legs Laser", nameAr: "ليزر كامل الساقين", duration: 45, rating: 4.8, reviewsCount: 156, price: 400, image: "assets/images/lizar.jpg", description: "Full legs laser hair removal from thigh to ankle for silky-smooth skin.", descriptionAr: "إزالة شعر كامل الساقين من الفخذ حتى الكاحل لبشرة ناعمة كالحرير.", benefits: ["Full coverage", "Long-lasting results", "Smooth finish"], specialist: { name: "Dr. Rana Khalil", role: "Laser Specialist", rating: 4.9, experienceYears: 7, image: "assets/images/lizar.jpg" } },
        { name: "Brazilian Laser", nameAr: "ليزر برازيلي", duration: 30, rating: 4.6, reviewsCount: 134, price: 350, image: "assets/images/lizar.jpg", description: "Complete bikini area laser hair removal with full Brazilian coverage.", descriptionAr: "إزالة كاملة لشعر منطقة البكيني بتغطية برازيلية شاملة.", benefits: ["Full coverage", "Minimal discomfort", "Permanent reduction"], specialist: { name: "Dr. Rana Khalil", role: "Laser Specialist", rating: 4.9, experienceYears: 7, image: "assets/images/lizar.jpg" } },
        { name: "Facial Laser", nameAr: "ليزر الوجه", duration: 20, rating: 4.7, reviewsCount: 167, price: 180, image: "assets/images/lizar.jpg", description: "Precision laser treatment for facial hair including upper lip, chin, and sideburns.", descriptionAr: "علاج دقيق بالليزر لشعر الوجه يشمل الشفة العليا والذقن والسوالف.", benefits: ["Precise targeting", "No nicks or cuts", "Quick session"], specialist: { name: "Dr. Rana Khalil", role: "Laser Specialist", rating: 4.9, experienceYears: 7, image: "assets/images/lizar.jpg" } },
        { name: "Full Body Laser", nameAr: "ليزر كامل الجسم", duration: 120, rating: 4.9, reviewsCount: 89, price: 1200, image: "assets/images/lizar.jpg", description: "Complete full-body laser hair removal package covering all areas in one session.", descriptionAr: "باقة كاملة لإزالة شعر الجسم بالكامل تغطي جميع المناطق في جلسة واحدة.", benefits: ["Full body coverage", "Best value", "Comprehensive results"], specialist: { name: "Dr. Rana Khalil", role: "Laser Specialist", rating: 4.9, experienceYears: 7, image: "assets/images/lizar.jpg" } },
    ],
    Spa: [
        { name: "Swedish Massage", nameAr: "تدليك سويدي", duration: 60, rating: 4.9, reviewsCount: 267, price: 250, image: "assets/images/potoks.jpg", description: "Classic full-body relaxation massage using long gliding strokes and gentle pressure.", descriptionAr: "تدليك كلاسيكي للاسترخاء الكامل بحركات انزلاقية طويلة وضغط لطيف.", benefits: ["Full body relaxation", "Stress relief", "Improved circulation"], specialist: { name: "Yasmin Al Rashid", role: "Massage Therapist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
        { name: "Deep Tissue Massage", nameAr: "تدليك الأنسجة العميقة", duration: 60, rating: 4.8, reviewsCount: 189, price: 300, image: "assets/images/potoks.jpg", description: "Targets deep muscle layers to relieve chronic tension and knots.", descriptionAr: "يستهدف طبقات العضلات العميقة لتخفيف التوتر المزمن والعقد.", benefits: ["Muscle knot relief", "Deep pressure", "Pain reduction"], specialist: { name: "Yasmin Al Rashid", role: "Massage Therapist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
        { name: "Hot Stone Therapy", nameAr: "علاج الأحجار الساخنة", duration: 90, rating: 4.9, reviewsCount: 145, price: 350, image: "assets/images/potoks.jpg", description: "Warm basalt stones combined with massage to melt away tension and stress.", descriptionAr: "أحجار بازلتية دافئة مع تدليك لإذابة التوتر والإجهاد.", benefits: ["Heat therapy", "Deep relaxation", "Improved blood flow"], specialist: { name: "Dana Farouk", role: "Spa Therapist", rating: 4.8, experienceYears: 6, image: "assets/images/potoks.jpg" } },
        { name: "Aromatherapy Massage", nameAr: "تدليك بالروائح العطرية", duration: 75, rating: 4.7, reviewsCount: 132, price: 280, image: "assets/images/potoks.jpg", description: "Therapeutic massage using essential oils tailored to your mood and needs.", descriptionAr: "تدليك علاجي بالزيوت الأساسية حسب مزاجك واحتياجاتك.", benefits: ["Essential oil therapy", "Mood elevation", "Skin nourishment"], specialist: { name: "Dana Farouk", role: "Spa Therapist", rating: 4.8, experienceYears: 6, image: "assets/images/potoks.jpg" } },
        { name: "Body Scrub", nameAr: "تقشير الجسم", duration: 45, rating: 4.6, reviewsCount: 119, price: 200, image: "assets/images/potoks.jpg", description: "Full-body exfoliation using sugar or salt scrubs for silky-smooth, glowing skin.", descriptionAr: "تقشير كامل للجسم بالسكر أو الملح لبشرة ناعمة ومتوهجة.", benefits: ["Full body exfoliation", "Smooth skin", "Increased glow"], specialist: { name: "Yasmin Al Rashid", role: "Massage Therapist", rating: 4.9, experienceYears: 8, image: "assets/images/potoks.jpg" } },
    ],
    Makeup: [
        { name: "Natural Glam", nameAr: "مكياج طبيعي أنيق", duration: 45, rating: 4.8, reviewsCount: 178, price: 200, image: "assets/images/scancare.jpg", description: "A fresh, everyday glam look with flawless skin and subtle definition.", descriptionAr: "إطلالة يومية منعشة ببشرة مثالية وتحديد بسيط.", benefits: ["Flawless base", "Natural finish", "All-day wear"], specialist: { name: "Hessa Al Amri", role: "Makeup Artist", rating: 4.9, experienceYears: 7, image: "assets/images/scancare.jpg" } },
        { name: "Bridal Makeup", nameAr: "مكياج العروس", duration: 120, rating: 4.9, reviewsCount: 223, price: 800, image: "assets/images/scancare.jpg", description: "Luxurious bridal makeup with trial session, long-wear formula, and touch-up kit.", descriptionAr: "مكياج عروس فاخر مع جلسة تجربة وتركيبة طويلة الثبات وطقم لمسات نهائية.", benefits: ["Trial session included", "Long-wear formula", "Touch-up kit"], specialist: { name: "Hessa Al Amri", role: "Makeup Artist", rating: 4.9, experienceYears: 7, image: "assets/images/scancare.jpg" } },
        { name: "Evening Look", nameAr: "إطلالة سهرة", duration: 60, rating: 4.7, reviewsCount: 152, price: 300, image: "assets/images/scancare.jpg", description: "Glamorous evening makeup with smokey eye or bold lip tailored to your outfit.", descriptionAr: "مكياج سهرة ساحر بعيون سموكي أو شفاه جريئة حسب إطلالتك.", benefits: ["Smokey or bold lip", "High-glam finish", "Long-lasting"], specialist: { name: "Mona Badawi", role: "Beauty Artist", rating: 4.8, experienceYears: 5, image: "assets/images/scancare.jpg" } },
        { name: "Airbrush Makeup", nameAr: "مكياج ايربراش", duration: 60, rating: 4.9, reviewsCount: 196, price: 350, image: "assets/images/scancare.jpg", description: "Ultra-lightweight airbrush foundation for a flawless, camera-ready finish.", descriptionAr: "تأسيس خفيف الوزن بتقنية الإيربراش لإطلالة مثالية جاهزة للكاميرا.", benefits: ["Weightless formula", "Camera-ready finish", "Waterproof"], specialist: { name: "Hessa Al Amri", role: "Makeup Artist", rating: 4.9, experienceYears: 7, image: "assets/images/scancare.jpg" } },
        { name: "Lash Application", nameAr: "تركيب رموش", duration: 30, rating: 4.8, reviewsCount: 134, price: 150, image: "assets/images/scancare.jpg", description: "Individual or strip lash application for dramatic, full lashes.", descriptionAr: "تركيب رموش فردية أو شريطية لرموش درامية وكاملة.", benefits: ["Natural or dramatic", "Premium lashes", "Adhesive included"], specialist: { name: "Mona Badawi", role: "Beauty Artist", rating: 4.8, experienceYears: 5, image: "assets/images/scancare.jpg" } },
    ],
    Medical: [
        { name: "Botox Injection", nameAr: "حقن البوتوكس", duration: 30, rating: 4.8, reviewsCount: 212, price: 900, image: "assets/images/lizar.jpg", description: "FDA-approved Botox treatment to smooth forehead lines, crow's feet, and frown lines.", descriptionAr: "علاج بوتوكس معتمد لتنعيم خطوط الجبهة وتجاعيد الضحك والعبوس.", benefits: ["Natural results", "15-minute procedure", "6-month duration"], specialist: { name: "Dr. Amal Jaber", role: "Aesthetic Physician", rating: 4.9, experienceYears: 12, image: "assets/images/lizar.jpg" } },
        { name: "Dermal Fillers", nameAr: "الفيلر", duration: 45, rating: 4.9, reviewsCount: 178, price: 1200, image: "assets/images/lizar.jpg", description: "Hyaluronic acid fillers for lip enhancement, cheek sculpting, and nasolabial folds.", descriptionAr: "حقن حمض الهيالورونيك لتكبير الشفاه ونحت الخدود وطيات الأنف والفم.", benefits: ["Instant volume", "Natural HA formula", "12-18 months duration"], specialist: { name: "Dr. Amal Jaber", role: "Aesthetic Physician", rating: 4.9, experienceYears: 12, image: "assets/images/lizar.jpg" } },
        { name: "PRP Treatment", nameAr: "علاج البلازما (PRP)", duration: 60, rating: 4.7, reviewsCount: 134, price: 800, image: "assets/images/lizar.jpg", description: "Platelet-rich plasma therapy to rejuvenate skin, reduce fine lines, and boost collagen.", descriptionAr: "علاج بلازما غنية بالصفائح الدموية لتجديد البشرة وتقليل الخطوط الدقيقة وتعزيز الكولاجين.", benefits: ["Collagen boost", "Natural regeneration", "Long-term results"], specialist: { name: "Dr. Reem Al Hosani", role: "Medical Aesthetics", rating: 4.8, experienceYears: 9, image: "assets/images/lizar.jpg" } },
        { name: "Mesotherapy", nameAr: "الميزوثيرابي", duration: 45, rating: 4.8, reviewsCount: 156, price: 600, image: "assets/images/lizar.jpg", description: "Micro-injections of vitamins, enzymes, and hormones to rejuvenate and tighten skin.", descriptionAr: "حقن دقيقة من الفيتامينات والإنزيمات والهرمونات لتجديد وشد البشرة.", benefits: ["Deep vitamin infusion", "Skin tightening", "Glow restoration"], specialist: { name: "Dr. Reem Al Hosani", role: "Medical Aesthetics", rating: 4.8, experienceYears: 9, image: "assets/images/lizar.jpg" } },
        { name: "IV Vitamin Drip", nameAr: "التقطير الوريدي بالفيتامينات", duration: 60, rating: 4.6, reviewsCount: 98, price: 400, image: "assets/images/lizar.jpg", description: "Customized intravenous vitamin and mineral infusion for energy, immunity, and glow.", descriptionAr: "تركيبة مخصصة من الفيتامينات والمعادن عبر الوريد للطاقة والمناعة والإشراقة.", benefits: ["Instant energy boost", "Skin brightening", "Immune support"], specialist: { name: "Dr. Amal Jaber", role: "Aesthetic Physician", rating: 4.9, experienceYears: 12, image: "assets/images/lizar.jpg" } },
    ],
    Products: [
        { name: "Argan Oil Kit", nameAr: "طقم زيت الأركان", duration: 20, rating: 4.9, reviewsCount: 145, price: 280, image: "assets/images/hair_section.webp", description: "Premium Moroccan argan oil set including shampoo, conditioner, and serum.", descriptionAr: "طقم فاخر من زيت الأركان المغربي يشمل شامبو وبلسم وسيروم.", benefits: ["Deep nourishment", "Frizz control", "Adds shine"], specialist: { name: "Beauty Advisor", role: "Product Consultant", rating: 4.8, experienceYears: 3, image: "assets/images/hair_section.webp" } },
        { name: "Skin Care Bundle", nameAr: "طقم العناية بالبشرة", duration: 30, rating: 4.8, reviewsCount: 167, price: 350, image: "assets/images/hair_section.webp", description: "Complete AM/PM skincare routine with cleanser, toner, serum, and SPF moisturiser.", descriptionAr: "روتين كامل صباحي ومسائي للعناية بالبشرة مع منظف وتونر وسيروم ومرطب واقٍ من الشمس.", benefits: ["AM & PM routine", "SPF protection", "Dermatologist-tested"], specialist: { name: "Beauty Advisor", role: "Product Consultant", rating: 4.8, experienceYears: 3, image: "assets/images/hair_section.webp" } },
        { name: "Hair Vitamin Pack", nameAr: "طقم فيتامينات الشعر", duration: 15, rating: 4.7, reviewsCount: 112, price: 150, image: "assets/images/hair_section.webp", description: "30-day supply of biotin, collagen, and hair-strengthening vitamins.", descriptionAr: "كمية 30 يوماً من فيتامينات البيوتين والكولاجين المقوية للشعر.", benefits: ["Biotin & collagen", "30-day supply", "Strengthens roots"], specialist: { name: "Beauty Advisor", role: "Product Consultant", rating: 4.8, experienceYears: 3, image: "assets/images/hair_section.webp" } },
        { name: "Body Butter Collection", nameAr: "مجموعة زبدة الجسم", duration: 20, rating: 4.8, reviewsCount: 134, price: 200, image: "assets/images/hair_section.webp", description: "Luxury whipped body butter trio in rose, vanilla, and coconut scents.", descriptionAr: "ثلاثية فاخرة من زبدة الجسم المخفوقة بروائح الورد والفانيليا وجوز الهند.", benefits: ["24-hr moisture", "3 scents", "Vegan formula"], specialist: { name: "Beauty Advisor", role: "Product Consultant", rating: 4.8, experienceYears: 3, image: "assets/images/hair_section.webp" } },
        { name: "Nail Care Kit", nameAr: "طقم العناية بالأظافر", duration: 15, rating: 4.6, reviewsCount: 89, price: 120, image: "assets/images/Nails_1.jpg", description: "Professional nail care kit with cuticle oil, file, buffer, and strengthener.", descriptionAr: "طقم عناية احترافي بالأظافر يشمل زيت الجلد المحيط والمبرد والصنفرة والمقوي.", benefits: ["Professional tools", "Cuticle care", "Nail strengthener"], specialist: { name: "Beauty Advisor", role: "Product Consultant", rating: 4.8, experienceYears: 3, image: "assets/images/Nails_1.jpg" } },
    ],
};

const daysFromNow = (n) => new Date(Date.now() + n * 24 * 60 * 60 * 1000);

// Exported so app.js can call this directly (already-connected) to seed a
// fresh/empty database on first run. Running this file directly (below)
// still works exactly as before, for a manual full re-seed.
const seedDatabase = async () => {
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
        const category = await Category.create({
            name: categoryDef.name,
            nameAr: categoryDef.nameAr,
            image: categoryDef.image,
        });

        for (const svc of SERVICES_BY_CATEGORY[categoryDef.name]) {
            let specialist = specialistsByName.get(svc.specialist.name);
            if (!specialist) {
                specialist = await Specialist.create(svc.specialist);
                specialistsByName.set(svc.specialist.name, specialist);
            }

            const service = await Service.create({
                name: svc.name,
                nameAr: svc.nameAr,
                description: svc.description,
                descriptionAr: svc.descriptionAr,
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
            description: "Enjoy 20% off our signature haircut & style service.",
            startDate: daysFromNow(-2),
            expiryDate: daysFromNow(6),
            discountPercentage: 20,
            image: servicesByName.get("Haircut & Style").image,
            serviceId: servicesByName.get("Haircut & Style")._id,
        },
        {
            badge: "LIMITED",
            title: "Glow Bundle",
            description: "Get glowing skin with 30% off our Hydrafacial treatment.",
            startDate: daysFromNow(-1),
            expiryDate: daysFromNow(9),
            discountPercentage: 30,
            image: servicesByName.get("Hydrafacial").image,
            serviceId: servicesByName.get("Hydrafacial")._id,
        },
        {
            badge: "LIMITED",
            title: "Bridal Package",
            description: "15% off our full bridal makeup package.",
            startDate: daysFromNow(3),
            expiryDate: daysFromNow(30),
            discountPercentage: 15,
            image: servicesByName.get("Bridal Makeup").image,
            serviceId: servicesByName.get("Bridal Makeup")._id,
        },
    ]);

    console.log("Seeding notifications for the demo customer...");
    await Notification.create([
        { userId: customer._id, title: "New Offer!", message: "Get 20% off your next haircut this week", type: "offer", isRead: false },
        { userId: customer._id, title: "Appointment Reminder", message: "Your spa session is tomorrow at 3:00 PM", type: "appointment", isRead: false },
        { userId: customer._id, title: "Review Request", message: "How was your last nail art session? Rate us!", type: "general", isRead: true },
        { userId: customer._id, title: "Loyalty Points", message: "You earned 50 points from your last visit!", type: "general", isRead: true },
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
        { user: customer._id, userName: customer.name, service: haircut._id, comment: "Absolutely loved it — highly recommended!" },
        { user: admin._id, userName: admin.name, service: haircut._id, comment: "Best in town, will come back every month." },
    ]);

    console.log("Done. Demo accounts:");
    console.log(`  Customer -> ${customer.email} / ${process.env.DEMO_PASSWORD || "Belle1234"}`);
    console.log(`  Admin    -> ${admin.email} / ${process.env.ADMIN_PASSWORD || "Admin1234"}`);
};

module.exports = seedDatabase;

// Only run standalone (`node src/scripts/seed.js`) when this file is the
// entry point — not when app.js requires it for the first-run auto-seed.
if (require.main === module) {
    connectDB()
        .then(() => mongoose.connection.asPromise())
        .then(() => seedDatabase())
        .catch((err) => console.error("Seed failed:", err))
        .finally(() => mongoose.connection.close());
}
