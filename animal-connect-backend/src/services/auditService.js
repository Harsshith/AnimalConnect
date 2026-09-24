const AuditLog = require('../models/AuditLog');

class AuditService {
  /**
   * Log a security or administrative action
   */
  static async log({ user, action, resourceType, resourceId, details = {}, req = null }) {
    try {
      const ipAddress = req ? req.ip || req.headers['x-forwarded-for'] || req.socket.remoteAddress : '';
      const userAgent = req ? req.headers['user-agent'] || '' : '';

      return await AuditLog.create({
        user: user._id || user,
        action,
        resourceType,
        resourceId: String(resourceId),
        details,
        ipAddress,
        userAgent,
        timestamp: new Date()
      });
    } catch (err) {
      console.error('[AuditService Error]', err.message);
      return null;
    }
  }
}

module.exports = AuditService;
