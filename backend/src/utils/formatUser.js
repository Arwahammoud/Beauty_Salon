// Turns a User mongoose document into the plain object shape the app expects.
// Never include the password hash here.
const formatUser = (user) => ({
    id: user._id,
    name: user.name,
    email: user.email,
    phone: user.phone || null,
    role: user.role.toUpperCase(),
    birthDate: user.birthDate || null,
    avatar: user.avatar || null,
    loyaltyPoints: user.loyaltyPoints,
    freeSessions: user.freeSessions || 0,
});

module.exports = formatUser;
