# PandaInvoice Generator 🐼🧾

A fast, fully responsive, zero-backend **Flutter Web Application** for generating professional PDF invoices. Built with a focus on modern aesthetics, privacy, and seamless UPI integration.

This tool runs completely in the browser, meaning **no server data storage is required**. Your organization details and logo are saved securely on your device using `localStorage`.

![Panda Invoice Preview](https://github.com/AnimeshBiz-Devs/panda-invoice/assets/placeholder-preview-image.png)

## ✨ Core Features

*   **100% Client-Side Generation**: Your sensitive data (prices, client details, addresses) never leaves your browser.
*   **Dynamic Programmatic PDFs**: Generates pixel-perfect A4 invoice PDFs using the `pdf` and `printing` packages.
*   **Smart Auto-Save**: Your base Organization details (Name, Address, UPI ID, Email) instantly synchronize with the browser cache (`shared_preferences`) so you never have to re-type them!
*   **Custom Logo Uploader**: Attach a circular logo (`image_picker`) which compresses and encodes into raw Base64 strings to survive browser cache quotas, embedding cleanly into the final invoice header.
*   **Dynamic UPI QR Engine**: Automatically strings together your `UPI ID`, `Organization Name`, and the calculated `Grand Total` into an actionable UP QR code rendered directly into the PDF footer for instant mobile payments.
*   **Responsive UI Engine**: Automatically shifts from a side-by-side Desktop layout to a stacked Mobile form view based on screen constraints.

## 🛠️ Technology Stack

*   **Framework:** [Flutter Web](https://flutter.dev/multi-platform/web)
*   **State Management:** `Provider` / `ChangeNotifier`
*   **PDF Engine:** [`pdf`](https://pub.dev/packages/pdf) & [`printing`](https://pub.dev/packages/printing) 
*   **Storage API:** [`shared_preferences`](https://pub.dev/packages/shared_preferences)
*   **File Handling:** [`image_picker`](https://pub.dev/packages/image_picker)

## 🚀 Local Development

Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/AnimeshBiz-Devs/panda-invoice.git
    cd panda-invoice
    ```

2.  **Fetch Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run Locally (Chrome)**
    ```bash
    flutter run -d chrome
    ```

## 📦 Deployment (GitHub Pages / Netlify)

This app is optimized for static hosting platforms.

1.  **Compile the Web Release Bundle**
    ```bash
    flutter clean
    flutter pub get
    flutter build web
    ```
    *(The output will be compiled into the `build/web` directory).*

2.  **Deploy via Netlify (Drag & Drop)**
    *   Navigate to your local `build/web` directory.
    *   Drag and drop the entire `web` folder into [Netlify Drop](https://app.netlify.com/drop).
    *   Your live URL will be generated instantly for free!

## 🎓 Showcase Notes

This project was built to demonstrate proficiency in:
*   Stateless/Stateful Widget Trees and UI Architecture.
*   Reactive Programming flows via `ChangeNotifier`.
*   Cross-platform data serialization constraints (Browser Quotas & Base-64 Encoding).
*   Bridging visual UI design to computational document layout (PDF generation).
