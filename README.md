# Simple Blog / Forum Assessment

A simple Blog/Forum application built with Flutter as part of a technical assessment.

## Live Demo

https://simple-blog-assessment-delta.vercel.app

## GitHub Repository

https://github.com/Finnmeowtons/Simple-Blog.git

---

## Tech Stack

- Flutter
- Provider (State Management)
- go_router (Routing)
- Supabase
    - Authentication
    - PostgreSQL Database
    - Storage (Image Upload)

---

## Features

### Authentication
- Register using Email & Password
- Login
- Logout

### Posts
- Public post listing
- Multiple image upload
- Image preview with carousel/pagination
- Create Post
- Update Post
- Delete Post

### Comments
- View comments per post
- Create comments
- Update comments
- Delete comments
- Multiple image upload
- Image carousel

### Images
- Upload multiple images
- Delete uploaded images
- Image storage using Supabase Storage

---

## State Management

Provider is used for application state management.

Providers include:

- AuthProvider
- PostProvider
- CommentProvider

---

## Routing

Navigation is handled using **go_router**.

Routes include:

- Login
- Register
- Forum

---

## Backend

Supabase is used for:

- Authentication
- Database
- Image Storage

Database tables:

- posts
- post_images
- comments
- comment_images

---

## Project Structure

```
lib/
│
├── enums/
├── models/
├── providers/
├── screens/
├── services/
├── widgets/
├── app_router.dart
└── main.dart
```

---

## Running Locally

Clone the repository

```bash
git clone <repo>
```

Install packages

```bash
flutter pub get
```

Run the project

```bash
flutter run
```

---

## Notes

This project was created for a Flutter technical assessment and demonstrates:

- Provider state management
- go_router navigation
- CRUD operations
- Image uploads
- Supabase integration
- Responsive UI