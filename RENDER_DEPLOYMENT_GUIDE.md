# Render Deployment Guide ☁️

Since Railway no longer offers a free trial, we will use **Render.com**. It has a generous free tier for both the Backend and the Database.

## Why Render?
*   **Free Web Service**: Run your Python backend for free.
*   **Free PostgreSQL**: Run a real database for free (perfect for starting).
*   **Simple**: Connects to GitHub just like Railway.

---

## Part 1: Prepare Environment

1.  **Code Check**: I have already updated `requirements.txt` to include `psycopg2-binary` (Required for Render's Database).
2.  **Git Push**: Ensure you have pushed the latest changes to GitHub:
    ```bash
    git add .
    git commit -m "prep for render"
    git push
    ```

---

## Part 2: Create Database (PostgreSQL)

**Do this FIRST so you can get the Database URL for the backend.**

1.  Sign up at [render.com](https://render.com/).
2.  Click **New +** -> **PostgreSQL**.
3.  **Name**: `buyv-db`
4.  **Database**: `buyv_db`
5.  **User**: `buyv_user`
6.  **Region**: Choose the one closest to you (e.g., Frankfurt or Ohio).
7.  **Plan**: Select **Free**.
8.  Click **Create Database**.
9.  Wait for it to start.
10. **Copy Credentials**:
    *   Find the **Internal Database URL** (if deploying backend to Render) OR **External Database URL**.
    *   *Tip: Use the "External Database URL" for now so you can connect from your local PC if needed.*
    *   Copy the connection string (starts with `postgres://...`).

---

## Part 3: Deploy Backend

1.  Go to Dashboard -> **New +** -> **Web Service**.
2.  **Build and deploy from a Git repository**.
3.  Connect your GitHub account and select `BuyV-FullStack`.
4.  **Configuration**:
    *   **Name**: `buyv-backend`
    *   **Region**: Same as your database.
    *   **Branch**: `main`
    *   **Root Directory**: `buyv_backend` (Crucial!)
    *   **Runtime**: `Docker` (Render will find the Dockerfile in `buyv_backend` automatically).
    *   **Plan**: **Free**.
5.  **Environment Variables**:
    *   Click **Advanced** or **Environment Variables**.
    *   Add keys from your `.env` file:
        *   `SECRET_KEY`: `...`
        *   `ALGORITHM`: `HS256`
        *   `STRIPE_SECRET_KEY`: `sk_test_...`
        *   `CJ_API_KEY`: `...`
        *   `DATABASE_URL`: **PASTE THE POSTGRES URL FROM PART 2**.
            *   *Important*: Render URL starts with `postgres://`. SQLAlchemy needs `postgresql://`.
            *   **Action**: Change `postgres://` to `postgresql://` in the value you paste.
6.  Click **Create Web Service**.

---

## Part 4: Finalize

1.  Wait for the build to finish. It might take 5-10 minutes.
2.  Once "Live", you will see a URL like `https://buyv-backend.onrender.com`.
3.  **Update Flutter App**:
    *   Open `lib/constants/app_constants.dart`.
    *   Update `fastApiBaseUrl` with your new Render URL.
    *   Rebuild: `flutter run`.

## ⚠️ Important Note on Free Tier
*   **Spin Down**: Free Web Services on Render "sleep" after 15 minutes of inactivity.
*   **Wake Up**: The first request after sleeping will take ~30-50 seconds. This is normal for the free tier.
