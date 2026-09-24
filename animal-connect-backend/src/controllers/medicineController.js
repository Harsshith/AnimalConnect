const MedicineItem = require('../models/MedicineItem');
const MedicineOrder = require('../models/MedicineOrder');
const Facility = require('../models/Facility');
const ApiResponse = require('../utils/apiResponse');
const AppError = require('../utils/appError');
const asyncHandler = require('../utils/asyncHandler');
const { generateOrderId } = require('../utils/idGenerator');
const { processUploadedFile } = require('../config/storage');
const NotificationService = require('../services/notificationService');

/**
 * @desc    Get medicine catalog
 * @route   GET /api/medicines
 * @access  Public
 */
const getMedicines = asyncHandler(async (req, res) => {
  const { category, inStock, search } = req.query;

  const query = {};
  if (category) query.category = category;
  if (inStock !== undefined) query.inStock = inStock === 'true';
  if (search) {
    query.$or = [
      { name: new RegExp(search, 'i') },
      { description: new RegExp(search, 'i') },
      { providerName: new RegExp(search, 'i') }
    ];
  }

  const medicines = await MedicineItem.find(query).sort('name');
  return ApiResponse.success(res, 'Medicine catalog retrieved.', { medicines });
});

/**
 * @desc    Get all medicine providers
 * @route   GET /api/medicine-providers
 * @access  Public
 */
const getMedicineProviders = asyncHandler(async (req, res) => {
  const providers = await Facility.find({ type: 'medicineProvider' }).sort('name');
  return ApiResponse.success(res, 'Medicine providers retrieved.', { providers });
});

/**
 * @desc    Create a new medicine order with prescription validation
 * @route   POST /api/medicine-orders
 * @access  Private
 */
const createMedicineOrder = asyncHandler(async (req, res) => {
  const { caseId, items, deliveryAddress, prescriptionUrl, providerId } = req.body;

  let parsedItems = items;
  if (typeof items === 'string') {
    try {
      parsedItems = JSON.parse(items);
    } catch (e) {
      throw new AppError('Invalid items JSON structure.', 400);
    }
  }

  if (!Array.isArray(parsedItems) || parsedItems.length === 0) {
    throw new AppError('Order must contain at least one item.', 400);
  }

  // Handle uploaded prescription document/image if attached
  let finalPrescriptionUrl = prescriptionUrl || '';
  if (req.file) {
    const file = await processUploadedFile(req.file, req);
    if (file) finalPrescriptionUrl = file.url;
  }

  // Check if any ordered medicine strictly requires a prescription
  const hasPrescriptionItem = parsedItems.some((item) => item.isPrescriptionRequired);
  if (hasPrescriptionItem && !finalPrescriptionUrl) {
    throw new AppError(
      'One or more ordered items require a valid veterinary prescription. Please upload your prescription.',
      400
    );
  }

  // Compute total price
  const totalPrice = parsedItems.reduce((sum, item) => {
    return sum + (parseFloat(item.price) || 0) * (parseInt(item.quantity, 10) || 1);
  }, 0);

  const orderId = generateOrderId();
  const initialStatus = finalPrescriptionUrl ? 'prescriptionSubmitted' : 'preparing';

  const order = await MedicineOrder.create({
    orderId,
    caseId: caseId || null,
    user: req.user._id,
    items: parsedItems,
    deliveryAddress,
    prescriptionUrl: finalPrescriptionUrl,
    status: initialStatus,
    totalPrice,
    provider: providerId || null
  });

  // Notify user
  await NotificationService.send({
    userId: req.user._id,
    title: `Medicine Order Placed (${orderId})`,
    body: `Your order for ₹${totalPrice} has been placed. Current status: ${initialStatus}.`,
    category: 'Medicine',
    caseId: caseId || null
  });

  return ApiResponse.success(res, 'Medicine order placed successfully.', { order }, 201);
});

/**
 * @desc    Get medicine order by ID
 * @route   GET /api/medicine-orders/:id
 * @access  Private
 */
const getMedicineOrderById = asyncHandler(async (req, res) => {
  const order = await MedicineOrder.findById(req.params.id)
    .populate('user', 'fullName email phone')
    .populate('provider', 'name phone address');

  if (!order) {
    throw new AppError('Medicine order not found.', 404);
  }

  // Authorization: order owner, provider, or admin
  const isOwner = String(order.user._id) === String(req.user._id);
  const isAdmin = req.user.role === 'admin';
  const isProvider = req.user.role === 'medicine_provider';

  if (!isOwner && !isAdmin && !isProvider) {
    throw new AppError('Not authorized to view this order.', 403);
  }

  return ApiResponse.success(res, 'Medicine order retrieved.', { order });
});

/**
 * @desc    Get user's medicine orders
 * @route   GET /api/medicine-orders/my
 * @access  Private
 */
const getMyMedicineOrders = asyncHandler(async (req, res) => {
  const orders = await MedicineOrder.find({ user: req.user._id }).sort('-createdAt');
  return ApiResponse.success(res, 'Orders retrieved.', { orders });
});

/**
 * @desc    Update medicine order status
 * @route   PUT /api/medicine-orders/:id
 * @access  Private (Provider or Admin)
 */
const updateOrderStatus = asyncHandler(async (req, res) => {
  const { status } = req.body;
  const order = await MedicineOrder.findById(req.params.id);
  if (!order) {
    throw new AppError('Medicine order not found.', 404);
  }

  const allowedRoles = ['medicine_provider', 'admin', 'hospital', 'clinic'];
  if (!allowedRoles.includes(req.user.role)) {
    throw new AppError('Not authorized to update order status.', 403);
  }

  const validStatuses = [
    'prescriptionSubmitted',
    'verified',
    'preparing',
    'outForDelivery',
    'delivered',
    'cancelled'
  ];

  if (!validStatuses.includes(status)) {
    throw new AppError(`Invalid status. Must be one of: ${validStatuses.join(', ')}`, 400);
  }

  order.status = status;
  await order.save();

  // Notify user
  await NotificationService.send({
    userId: order.user,
    title: `Medicine Order Update (${order.orderId})`,
    body: `Your order status changed to: ${status}`,
    category: 'Medicine',
    caseId: order.caseId
  });

  return ApiResponse.success(res, 'Order status updated successfully.', { order });
});

module.exports = {
  getMedicines,
  getMedicineProviders,
  createMedicineOrder,
  getMedicineOrderById,
  getMyMedicineOrders,
  updateOrderStatus
};
