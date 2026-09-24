const Notification = require('../models/Notification');

class NotificationService {
  /**
   * Dispatch a notification to a specific user
   * @param {Object} options
   * @param {string} options.userId - Recipient user ObjectId
   * @param {string} options.title - Notification title
   * @param {string} options.body - Notification body
   * @param {string} [options.category='General'] - 'Case', 'Funding', 'Donation', 'Adoption', 'Medicine', 'General'
   * @param {string} [options.caseId] - Associated case ID
   * @param {Object} [options.data] - Additional metadata for FCM payload
   */
  static async send({ userId, title, body, category = 'General', caseId = null, data = {} }) {
    try {
      const notification = await Notification.create({
        user: userId,
        title,
        body,
        category,
        caseId,
        data,
        timestamp: new Date()
      });

      // Ready for Firebase Cloud Messaging (FCM) integration
      // if (fcmClient && userDeviceToken) { ... }

      return notification;
    } catch (err) {
      console.error('[NotificationService Error]', err.message);
      return null;
    }
  }

  /**
   * Notify multiple users (e.g. broadcast or role alert)
   */
  static async sendMany(userIds, { title, body, category = 'General', caseId = null, data = {} }) {
    if (!Array.isArray(userIds) || userIds.length === 0) return [];
    try {
      const notifications = userIds.map((userId) => ({
        user: userId,
        title,
        body,
        category,
        caseId,
        data,
        timestamp: new Date()
      }));
      return await Notification.insertMany(notifications);
    } catch (err) {
      console.error('[NotificationService sendMany Error]', err.message);
      return [];
    }
  }
}

module.exports = NotificationService;
