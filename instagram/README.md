# 📸 MakeInstagram (Flutter Instagram Clone)

This project is a Flutter-based Instagram clone application.  
It includes core features such as feed browsing, search, reels, posting, profile management, and even an AI chat function integrated through the OpenRouter API.

## ✨ Key Features

### **Feed**
- Scroll through posts (photos & videos)
- Like posts (double-tap animation), comment, and share
- Story bar UI

### **Search**
- Explore tab with grid layout
- Search bar UI

### **New Post**
- Select images from gallery
- Write captions and upload posts (local state storage)

### **Reels**
- Fullscreen short-form video player

### **Profile**
- View user info (posts, followers, following)
- User post grid
- Edit profile (name, bio, profile image)
- Follow/unfollow simulation

### **DM & AI Chat**
- Chat room UI
- **LLM Integration:** Uses OpenRouter API for AI chat functionality

### **Notifications**
- Activity list for likes, comments, etc.

---

## 🛠 Tech Stack

- **Framework:** Flutter  
- **Language:** Dart  
- **State Management:** `ValueNotifier`, `setState`  
- **Video:** `video_player`  
- **Network:** `http`  
- **Image/File:** `image_picker`

---

## 🚀 Getting Started

### **Prerequisites**
- Flutter SDK installed  
- Android Studio or VS Code installed  

### **Installation**

1. **Clone the repository**
    ```bash
    git clone [repository_url]
    cd instagram
    ```

2. **Install dependencies**
    ```bash
    flutter pub get
    ```

3. **API Key Setup (Optional)**
   - To use the AI chat feature, set your OpenRouter API key inside `lib/constants.dart`.
   - ⚠️ Do NOT commit your API key to GitHub or any public repository.

4. **Run the app**
    ```bash
    flutter run
    ```

---

## 🔔 IMPORTANT NOTES (Must Read)

To ensure stable operation on Android devices, please follow the instructions below:

### **1. Always use Wi-Fi on the Android device**
The app is optimized for use under a stable Wi-Fi connection rather than mobile data.

### **2. Scroll slowly during testing**
Rapid scrolling in the feed or reels may cause performance drops or temporary freezes, especially in debug mode.  
For accurate testing, **scroll slowly**.

### **3. After connecting the Android device via USB, run the app once → check normal operation → then disconnect the cable and restart the app**
- First, connect your Android device to your PC via USB and run the app.
- After confirming that the app works normally, **disconnect the USB cable**.
- Then run the app again **with the device unplugged**.

#### **Why?**
When the app runs while the device is still USB-connected, the debug connection sometimes triggers random shutdowns or unexpected app exits.  
Running the app **without the cable connected** reduces these issues and ensures more stable behavior.

### **4. Scroll latency or "scroll skipping" may occur in debug mode**

Flutter debug mode is not fully optimized for rendering performance.
Because this app contains many images and videos, you may occasionally experience:

delayed scroll response

skipped frames

“scrolling without moving” feeling

This is normal in debug mode and will not occur in release mode.

---

