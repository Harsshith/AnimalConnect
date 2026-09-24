App Overview
AnimalConnect is a comprehensive Flutter-based mobile application designed for animal welfare, rescue, and community support. Its primary goal is to connect volunteers, donors, and animal care facilities to streamline the process of reporting, treating, and adopting animals in need.

Core User Flow & Navigation
The application uses a standard bottom navigation bar with 5 primary tabs and a persistent "Report Animal" Floating Action Button (FAB).

1. Home Tab

Acts as the central dashboard for the user.
Likely provides a feed of recent activities, urgent cases, announcements, and quick actions to get involved.
2. Cases Tab

Displays a list of reported animals and active rescue cases.
Users can track the status of different cases (e.g., Reported, In Treatment, Recovered) via a Case Timeline.
An alert indicator (orange dot) appears on the icon when there are new or active cases requiring attention.
Includes a detailed view (CaseDetailScreen) to see the specifics, location, and condition of the animal.
3. Explore Tab

Serves as the discovery engine for the app.
Users can explore different welfare programs, registered animal care facilities, and shelters.
Connects users with nearby resources and adoption centers.
4. Donations Tab

The financial support hub of the application.
Users can view specific funding requests for animal treatments (TreatmentFundingScreen).
Provides a transparent way to donate to specific cases or general welfare funds, and users receive donation receipts.
5. Profile Tab

Manages user and volunteer profiles (VolunteerProfileScreen).
Users can track their own contributions, past reports, and manage their preferences.
Key Features & Modules
🚨 Emergency Reporting (Report Animal Flow)

Accessible from anywhere in the app via the Floating Action Button.
Users can quickly snap a photo and report an injured, stray, or lost animal.
Leads to a success screen (CaseSuccessScreen) once the report is filed, ensuring the local network is notified.
🏥 Facilities & Shelters

Facilities can register on the platform (FacilityRegistrationScreen).
Users can view a list of vetted facilities and their detailed profiles.
🐕 Adoption & Pet Care

Features a dedicated adoption module where users can view animals ready for their forever homes.
Includes a Pet Care module (PetCareScreen) that likely provides resources, guides, or services for existing pet owners.
💊 Medical & Treatment Support

Facilitates the logistical side of animal care with a Medicine Delivery module (MedicineDeliveryScreen).
Integrates with the donation system to crowdfund specific medical treatments for severe cases.
🛠 Admin & Management

Includes an Admin Dashboard (AdminDashboardScreen) for privileged users to manage cases, verify facilities, and oversee donations.
Technical Architecture Overview
Framework: Flutter (supports iOS, Android, Web, Windows, macOS, Linux).
State Management: Uses the Provider package (specifically PawCareProvider) to manage app state globally (like tracking active cases).
Data Models: Structured models for Adoption, AnimalCase, Donation, Facility, FundingRequest, Medicine, Notification, and PetCare.
UI/UX: Uses a custom theme with specific branding colors (e.g., AppColors.primaryBlue, AppColors.actionOrange) and customized widgets (PawcareButton, StatusBadge, CaseTimeline) to maintain a clean, modern, and compassionate aesthetic.
