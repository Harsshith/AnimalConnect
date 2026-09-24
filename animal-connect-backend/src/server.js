const app = require('./app');
const connectDB = require('./config/db');
const env = require('./config/env');

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('[Uncaught Exception] Shutting down...', err);
  process.exit(1);
});

const startServer = async () => {
  try {
    // Connect to MongoDB
    await connectDB();

    const server = app.listen(env.port, () => {
      console.log(
        `==================================================\n` +
        `  Animal Connect API Server Running\n` +
        `  Port: ${env.port}\n` +
        `  Mode: ${env.nodeEnv}\n` +
        `  Health Check: http://localhost:${env.port}/api/health\n` +
        `==================================================`
      );
    });

    // Handle unhandled promise rejections
    process.on('unhandledRejection', (err) => {
      console.error('[Unhandled Rejection] Shutting down...', err);
      server.close(() => {
        process.exit(1);
      });
    });

    // Graceful shutdown
    process.on('SIGTERM', () => {
      console.log('[SIGTERM Received] Shutting down gracefully...');
      server.close(() => {
        console.log('Process terminated.');
      });
    });
  } catch (error) {
    console.error('Failed to start server:', error.message);
    process.exit(1);
  }
};

startServer();
