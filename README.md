# JeevanSetu — Smart Resource Allocator

A Flutter app for the Google Solution Challenge that connects NGOs with volunteers during disaster relief operations.

## Problem Statement
During disasters, NGOs struggle to efficiently allocate limited volunteers and resources to the right locations at the right time.

## Solution
ResQ uses AI-powered priority detection and real-time volunteer matching to ensure the right help reaches the right place faster.

## Features
- Role-based login (NGO Admin / Volunteer)
- AI-powered incident report priority detection using Gemini API
- Live incident map with heatmap visualization (OpenStreetMap)
- Smart volunteer matching based on skills
- Real-time task assignment and completion tracking

## Tech Stack
- Flutter (Android)
- Firebase Auth + Firestore
- Google Gemini AI API
- OpenStreetMap (flutter_map)
- Geolocator

## UN SDG Alignment
- SDG 11: Sustainable Cities and Communities
- SDG 13: Climate Action
- SDG 17: Partnerships for the Goals

## Setup
1. Clone this repo
2. Run `flutter pub get`
3. Configure Firebase using `flutterfire configure`
4. Add your Gemini API key in `lib/services/gemini_service.dart`
5. Run `flutter run`

## Team
- Priyanshu Agrawal — Developer