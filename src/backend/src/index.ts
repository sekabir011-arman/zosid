import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import { initializeSupabase } from './lib/supabase.ts';
import authRoutes from './routes/auth.ts';
import patientsRoutes from './routes/patients.ts';
import vitalsRoutes from './routes/vitals.ts';
import appointmentsRoutes from './routes/appointments.ts';
import prescriptionsRoutes from './routes/prescriptions.ts';
import nurseAssignmentsRoutes from './routes/nurseAssignments.ts';
import configRoutes from './routes/config.ts';
import serialQueueRoutes from './routes/serialQueue.ts';
import receiptsRoutes from './routes/receipts.ts';
import publicBookingsRoutes from './routes/publicBookings.ts';
import { authMiddleware } from './middleware/auth.ts';

const app = express();
const PORT = process.env.API_PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Initialize Supabase
initializeSupabase();

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Public routes
app.use('/api/auth', authRoutes);
app.use('/api/config', configRoutes);

// Protected routes
app.use('/api/patients', authMiddleware, patientsRoutes);
app.use('/api/vitals', authMiddleware, vitalsRoutes);
app.use('/api/appointments', authMiddleware, appointmentsRoutes);
app.use('/api/prescriptions', authMiddleware, prescriptionsRoutes);
app.use('/api/nurse-assignments', authMiddleware, nurseAssignmentsRoutes);
app.use('/api/serial-queue', authMiddleware, serialQueueRoutes);
app.use('/api/receipts', authMiddleware, receiptsRoutes);
app.use('/api/public-bookings', publicBookingsRoutes); // Public bookings is partially public

// Error handling
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    code: err.code || 'INTERNAL_ERROR',
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Backend running on http://localhost:${PORT}`);
});
