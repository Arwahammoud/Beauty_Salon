// Returns the Arabic variant of `field` on `doc` when the request's resolved
// language is Arabic and that variant is filled in, otherwise falls back to
// the base (English) field. Keeps public responses as a single plain string
// per field, so consumers don't need to know about bilingual storage.
const localize = (doc, field, req) => {
    const arField = `${field}Ar`;
    if (req.lang === 'ar' && doc[arField]) return doc[arField];
    return doc[field];
};

module.exports = localize;
