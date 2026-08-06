// Turns a User mongoose document into the plain object shape the app expects.
// Never include the password hash here.
const formatUser = (user) => ({
    id: user._id,
    name: user.name,
    email: user.email,
    phone: user.phone || null,
    role: user.role.toUpperCase(),
    birthDate: user.birthDate ? user.birthDate.toISOString().slice(0, 10) : null,
    loyaltyPoints: user.loyaltyPoints,
});

module.exports = formatUser;
