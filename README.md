# AquaSmart Flutter MVP

Demo mobile application for checking water consumption and controlling temperature.

## Project Structure
```
lib/
├── main.dart                  # Entry point
├── src/
│   ├── app.dart               # Material App setup
│   ├── constants/
│   │   └── app_theme.dart     # Colors and Fonts
│   ├── models/
│   │   └── models.dart        # Data Models
│   ├── providers/
│   │   └── water_control_provider.dart # State Management (Mock Data)
│   └── ui/
│       ├── dashboard/
│       │   ├── dashboard_screen.dart
│       │   └── widgets/       # Dashboard specific widgets
│       └── stats/
│           ├── stats_screen.dart
│           └── widgets/       # Chart widgets
```

## Features & Screens

### 1. Dashboard (Main Screen)
The heart of the application, designed for easy control and monitoring.
- **Modern Temperature Control**: A sleek, large circular slider to set your target water temperature (20°C - 60°C).
- **Profile Switching**: 
  - Switch between **Father**, **Mother**, and **Child** profiles.
  - **Randomized Data**: Each profile has its own unique consumption habits and history. Switching profiles instantly refreshes the data to demonstrate personalization.
- **Smart Efficiency Alert**: visual feedback (Green Banner) when the temperature is set to an eco-friendly level (<40°C).
- **"Start Shower" Simulation Mode**: 
  - **Demo Feature**: Press the large **"START SHOWER"** button to simulate a live shower session.
  - **Real-Time Tracking**: Watch the *Session Liters* and *Cost* rise second-by-second (simulating 9L/min flow).
  - **Live Cost Calculation**: Costs are calculated dynamically based on usage.

![Dashboard Screenshot](assets/screenshots/dashboard.png)


### 2. Statistics
- **Weekly Consumption**: A clear bar chart showing water usage for the last 7 days.
- **Interactive Labels**: Dark, readable text showing days of the week.
- **Insight**: Helpful text summaries (e.g., "10% lower than last week").

![Stats Screenshot](assets/screenshots/stats.png)


### 3. Architecture & Tech Stack
- **State Management**: Built with `flutter_riverpod` for robust and reactive state.
- **Mock Data Engine**: A sophisticated simulation engine (`WaterControlNotifier`) that generates realistic usage data and handles the time-based shower simulation.
- **Charts**: Uses `fl_chart` for beautiful, animated graphical data.

## How to Run

1. **Install Dependencies**:
   Navigate to the project directory in your terminal:
   ```bash
   cd c:\Users\hy092\Desktop\AQUASMART
   flutter pub get
   ```

2. **Run the App**:
   ```bash
   flutter run
   ```

## Dependencies
- `flutter_riverpod`: State Management
- `fl_chart`: Statistics Charts
- `sleek_circular_slider`: Temperature Control UI
- `google_fonts`: Typography
- `intl`: Formatting
