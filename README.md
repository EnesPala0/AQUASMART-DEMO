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

## Features
- **User Profiles**: Switch between different family members.
- **Temperature Control**: Interactive circular slider.
- **Real-time Stats**: Daily consumption, monthly usage, estimated cost.
- **Efficiency Alerts**: Visual feedback for water saving.
- **Weekly History**: Bar chart visualization.

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
