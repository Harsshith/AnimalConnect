const mongoose = require('mongoose');

const caseStatusHistorySchema = new mongoose.Schema(
  {
    caseId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'AnimalCase',
      required: true,
      index: true
    },
    previousStatus: {
      type: String,
      required: true
    },
    newStatus: {
      type: String,
      required: true
    },
    changedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    },
    changerRole: {
      type: String,
      default: 'user'
    },
    remarks: {
      type: String,
      trim: true,
      default: ''
    }
  },
  {
    timestamps: true
  }
);

const CaseStatusHistory = mongoose.model('CaseStatusHistory', caseStatusHistorySchema);
module.exports = CaseStatusHistory;
