const AnimalCase = require('../models/AnimalCase');
const FundingRequest = require('../models/FundingRequest');
const TreatmentRecord = require('../models/TreatmentRecord');
const AppError = require('../utils/appError');

class PhotoVerificationService {
  /**
   * Compare submitted volunteer photos and medical treatment photos for a case
   */
  static async getVerificationComparison(caseId) {
    const animalCase = await AnimalCase.findById(caseId);
    if (!animalCase) {
      throw new AppError('Case not found', 404);
    }

    const treatments = await TreatmentRecord.find({ caseId });
    const hospitalPhotos = treatments.flatMap((t) => t.treatmentPhotos || []);

    return {
      caseId: animalCase.caseId,
      animalType: animalCase.animalType,
      currentStatus: animalCase.photoMatchStatus,
      volunteerPhotos: animalCase.images,
      hospitalPhotos,
      notes: animalCase.photoMatchNotes
    };
  }

  /**
   * Submit manual review decision by an authorized reviewer/admin
   */
  static async submitReviewDecision({ caseId, decision, notes = '', reviewerId }) {
    const allowedDecisions = ['matched', 'mismatch', 'manual_review'];
    if (!allowedDecisions.includes(decision)) {
      throw new AppError(`Invalid decision. Must be one of: ${allowedDecisions.join(', ')}`, 400);
    }

    const animalCase = await AnimalCase.findById(caseId);
    if (!animalCase) {
      throw new AppError('Case not found', 404);
    }

    animalCase.photoMatchStatus = decision;
    animalCase.photoMatchNotes = notes;
    await animalCase.save();

    // If there is an associated funding request, update its checklist
    const fundingRequest = await FundingRequest.findOne({ caseId: animalCase._id });
    if (fundingRequest) {
      fundingRequest.checklist.photosMatched = decision === 'matched';
      fundingRequest.approvalHistory.push({
        status: `Photo Match: ${decision.toUpperCase()}`,
        changedBy: reviewerId,
        remarks: notes,
        timestamp: new Date()
      });
      await fundingRequest.save();
    }

    return {
      caseId: animalCase._id,
      photoMatchStatus: animalCase.photoMatchStatus,
      notes: animalCase.photoMatchNotes
    };
  }
}

module.exports = PhotoVerificationService;
