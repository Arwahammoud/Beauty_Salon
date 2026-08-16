// Every 1000 loyalty points banked converts into one redeemable free
// session (remainder carried over) — keeps loyaltyPoints always < 1000.
// Mutates the user doc in place; caller is responsible for saving it
// if this returns true.
const applyLoyaltyRollover = (user) => {
    if ((user.loyaltyPoints || 0) < 1000) return false;
    const sessionsUnlocked = Math.floor(user.loyaltyPoints / 1000);
    user.freeSessions = (user.freeSessions || 0) + sessionsUnlocked;
    user.loyaltyPoints -= sessionsUnlocked * 1000;
    return true;
};

module.exports = { applyLoyaltyRollover };
