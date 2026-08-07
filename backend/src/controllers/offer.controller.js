 const Offer = require("../models/Offers");

class OfferController {
  // @desc    جلب كل العروض الفعالة وغير المنتهية
  // @route   GET /api/v1/offers
  getActiveOffers = async (req, res) => {
    const currentDate = new Date();

    // جلب العروض النشطة والتي تاريخ انتهائها بعد اليوم
    const offers = await Offer.find({
      isActive: true,
      expiryDate: { $gte: currentDate },
    });

    // The Flutter app additionally expects badge/discountLabel/serviceId —
    // derived/aliased here rather than duplicating data in the schema.
    const items = offers.map((o) => {
      const j = o.toJSON();
      return { ...j, discountLabel: `${j.discountPercentage}%`, endDate: j.expiryDate };
    });

    res.status(200).json({
      status: "success",
      results: items.length,
      items,
    });
  };

  // @desc    إنشاء عرض جديد (خاص بالأدمين)
  // @route   POST /api/v1/offers
  createOffer = async (req, res) => {
    const { title, description, image, discountPercentage, expiryDate, startDate, badge, serviceId } = req.body;

    const offer = await Offer.create({
      title,
      description,
      image,
      discountPercentage,
      expiryDate,
      startDate,
      badge,
      serviceId,
    });

    res.status(201).json({
      status: "success",
      data: offer,
    });
  };

  // @desc    حذف عرض (خاص بالأدمين)
  // @route   DELETE /api/v1/offers/:id
  deleteOffer = async (req, res) => {
    const offer = await Offer.findByIdAndDelete(req.params.id);
    if (!offer) {
      return res.status(404).json({ status: "fail", message: "Offer not found" });
    }

    res.status(200).json({
      status: "success",
      message: "Offer deleted successfully",
    });
  };
}

module.exports = new OfferController();