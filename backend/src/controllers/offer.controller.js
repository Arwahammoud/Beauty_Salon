const Offer = require("../models/Offer");
const localize = require("../utils/localize");

// Trending tags are just editorial content for the Offers screen — no
// admin UI for them yet, so a small fixed list is enough for now.
const TRENDING_TAGS = [
    "#BalayageVibes",
    "#HydraGlow",
    "#BridalSeason",
    "#NailArtMay",
    "#KeratinSmooth",
    "#SpaSunday",
];

class OfferController {
    // ==================== GET /offers ====================
    getAll = async (req, res) => {
        const offers = await Offer.find({ isActive: true }).sort({ startDate: -1 });

        const items = offers.map((o) => ({
            id: o._id,
            badge: o.badge,
            title: localize(o, "title", req),
            startDate: o.startDate.toISOString().slice(0, 10),
            endDate: o.endDate.toISOString().slice(0, 10),
            discountLabel: localize(o, "discountLabel", req),
            image: o.image,
            serviceId: o.serviceId,
        }));

        return res.status(200).json({ items, trendingTags: TRENDING_TAGS });
    };
}

module.exports = new OfferController();
