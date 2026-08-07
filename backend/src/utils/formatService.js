const localize = require("./localize");

// Turns a Service document (with specialistId populated) into the plain
// object shape the app expects. `category` is optional — pass it when you
// already have it loaded, to avoid an extra populate. `req` is optional too —
// pass it to get the response localized to the caller's Accept-Language.
const formatService = (service, category, req) => ({
    id: service._id,
    categoryId: category ? category._id : service.categoryId,
    categoryName: category
        ? (req ? localize(category, "name", req) : category.name)
        : service.categoryId?.name,
    serviceName: req ? localize(service, "name", req) : service.name,
    duration: `${service.duration} min`,
    durationMins: service.duration,
    rating: service.averageRating,
    reviewsCount: service.reviewsCount,
    price: service.price,
    image: service.image,
    about: req ? localize(service, "description", req) : service.description,
    benefits: req && req.lang === "ar" && service.benefitsAr?.length
        ? service.benefitsAr
        : service.benefits,
    specialist: service.specialistId
        ? {
              id: service.specialistId._id,
              name: service.specialistId.name,
              role: service.specialistId.role,
              rating: service.specialistId.rating,
              experienceYears: service.specialistId.experienceYears,
              image: service.specialistId.image,
          }
        : null,
});

module.exports = formatService;
