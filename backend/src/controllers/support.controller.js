// Static for now — the business can ask for an admin-editable version later.
const FAQS = [
    { question: "How do I book an appointment?", answer: "Open a service, tap Book Now, then pick a date and time." },
    { question: "Can I cancel a booking?", answer: "Yes, go to My Appointments and cancel from the Upcoming tab." },
    { question: "How do I earn loyalty points?", answer: "You earn points automatically for every completed booking." },
];

const BUSINESS_HOURS = [
    { day: "Sat-Thu", time: "9 AM - 9 PM" },
    { day: "Fri", time: "2 PM - 9 PM" },
];

class SupportController {
    getFaqs = async (req, res) => {
        return res.status(200).json({ items: FAQS });
    };

    getBusinessHours = async (req, res) => {
        return res.status(200).json({ items: BUSINESS_HOURS });
    };
}

module.exports = new SupportController();
