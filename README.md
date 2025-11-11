# Flutter Sample - Daniel Depaor

A simple Flutter web application that displays "Daniel Depaor".

## Setup

1. Make sure you have Flutter installed:
   ```bash
   flutter --version
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app locally:
   ```bash
   flutter run -d chrome
   ```

## Deploy to Vercel

The project includes a build script (`build.sh`) that automatically installs Flutter during the build process on Vercel.

### Option 1: Deploy via Vercel Dashboard

1. Connect your GitHub repository to Vercel
2. Vercel will automatically detect the `vercel.json` configuration
3. The build script will install Flutter and build your app

### Option 2: Deploy via CLI

1. Make sure you have the Vercel CLI installed:
   ```bash
   npm i -g vercel
   ```

2. Deploy:
   ```bash
   vercel
   ```

### Note

The build script automatically downloads and installs Flutter SDK during the build process. This may take a few minutes on the first build. Subsequent builds will be faster if Vercel caches are enabled.

### Alternative: Build Locally and Deploy

If you encounter issues with the automatic Flutter installation on Vercel, you can build locally and deploy the static files:

1. Build the Flutter web app locally:
   ```bash
   flutter pub get
   flutter build web --release
   ```

2. Deploy the `build/web` directory to Vercel:
   ```bash
   cd build/web
   vercel
   ```

## Build for Production

```bash
flutter build web --release
```

The built files will be in `build/web/` directory.

