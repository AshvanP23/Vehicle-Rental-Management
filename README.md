 FlexRide - Premium Vehicle Rental Platform

FlexRide is a high-performance, full-stack vehicle rental application designed to provide a frictionless mobility experience in urban cities like Chennai. Built with a robust Flutter frontend and a hybrid Firebase/Supabase backend, it offers a seamless role-based ecosystem for both travelers and fleet managers.

 Project Vision :

Urban commuting in India often faces friction due to excessive paperwork, lack of real-time inventory, and complex booking processes. FlexRide eliminates these hurdles by providing:

100% Digital KYC: No physical forms.

Real-time Availability: Instant booking for bikes and cars.

Transparent Pricing: Zero hidden costs.

 Core Features :

 User Module (Traveler Experience) :

Instant Onboarding: Secure Gmail-based authentication with auto-generated user profiles.

Dynamic Vehicle Catalog: Browse a diverse fleet of two-wheelers and four-wheelers with high-res imagery and pricing details.

Digital Booking Engine: Advanced booking flow with integrated document (License/ID) uploads via Firebase Storage.

Smart Trip Management: "My Bookings" section to track upcoming rides, status updates, and rental history.

Smooth Navigation: Premium UI/UX with custom slide transitions and a sophisticated dark mode.

 Admin Module (Fleet Operations) :

Centralized Dashboard: Real-time overview of all fleet operations and user activity.

Advanced Monitoring: Track every booking, verify user documents, and manage vehicle statuses instantly.

Secure Infrastructure: Hardened Role-Based Access Control (RBAC) ensuring administrative data is only accessible to verified UIDs.

 Technical Implementation :

Frontend Architecture :

Flutter Framework: Cross-platform consistency for Android, iOS, and Web.

Responsive Design: Adaptive layouts for various screen sizes (Mobile to Tablet).

Clean Transitions: Custom PageTransitionsBuilder for a native, fluid app feel.

Backend & Security :

Firebase Core: Handles Authentication and Firestore Database for user roles and bookings.

Supabase Integration: High-speed data fetching and scalable storage solutions.

Security Rules: - Firestore Rules: Strictly enforced so users can only access their own data.

Supabase RLS: Row Level Security enabled to prevent unauthorized table access.

Environment Management: Sensitive API keys are managed via .env and never pushed to the public repository.