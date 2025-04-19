# AtomMail HF

AtomMail HF is a modern email management application built with **Flutter** for
the frontend and **Flask** for the backend. It integrates the **Gmail API** for
email retrieval and uses **LangChain** for advanced features like email
categorization, summarization, and reply generation. The app provides a seamless
and efficient interface for managing emails, offering features like AI-powered
email insights and prompt-based reply generation.

## Table of Contents

-   [Project Title](#atommail-hf)
-   [Table of Contents](#table-of-contents)
-   [Technologies Used](#technologies-used)
-   [Screenshots/Demo Videos](#screenshots)
-   [Installation](#installation)
    -   [Backend Setup](#backend-setup)
    -   [Frontend Setup](#frontend-setup)
-   [Backend](#backend)
-   [Frontend](#frontend)
-   [Analysis of Feasibility](#analysis-of-feasibility)
-   [Potential Challenges](#potential-challenges)
-   [Overcoming Strategies](#overcoming-strategies)
-   [Contributing](#contributing)
-   [License](#license)

## Technologies Used

This project leverages a diverse set of technologies to build a complete email
management system:

-   **Flutter**: Framework for building the frontend application.
-   **Flask**: Lightweight Python web framework for backend development.
-   **PostgreSQL**: Database for storing email metadata and embeddings.
-   **Gmail API**: Used for retrieving and managing emails.
-   **LangChain**: Framework for email categorization, summarization, and reply
    generation.
-   **REST APIs**: For communication between the frontend and backend.

## Screenshots

### 💻 App Interface

<!-- <p align="center">
  <img src="https://github.com/user-attachments/assets/sample1" width="340"/>
  <img src="https://github.com/user-attachments/assets/sample2" width="340"/>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/sample3" width="340"/>
</p> -->

### 🎥 App Demo

<!-- [![Watch the video](https://github.com/user-attachments/assets/sample-video-thumbnail)](https://github.com/user-attachments/assets/sample-video) -->

## Installation

Follow the instructions below to set up each component of the system:

### Backend Setup

1. **Clone the repository:**
    ```bash
    git clone https://github.com/agnidhra-coder/atom-mail-hf
    ```
2. **Navigate to the backend directory:**
    ```bash
    cd atom-mail-hf/backend
    ```
3. **Create a virtual environment and activate it:**
    ```bash
    python -m venv venv
    source venv/bin/activate   # On Windows: venv\Scripts\activate
    ```
4. **Install the required dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
5. **Start the backend service:**
    ```bash
    python app.py
    ```
    The backend will start running on `http://localhost:5000`.

### Frontend Setup

1. **Navigate to the frontend directory:**
    ```bash
    cd ../frontend
    ```
2. **Install dependencies:**
    ```bash
    flutter pub get
    ```
3. **Run the Flutter application:**
    ```bash
    flutter run
    ```
    The application will launch on your connected device or emulator.

## Backend

The backend service is developed in Python using **Flask** and is responsible
for:

1. **Email Retrieval**: Fetching emails from the Gmail API.
2. **Email Categorization**: Using **LangChain** to classify emails into
   predefined categories.
3. **Email Summarization**: Generating concise summaries of email content.
4. **Reply Generation**: Creating email replies based on simple English prompts.
5. **API Endpoints**: Providing RESTful APIs for the frontend to interact with
   the backend.

## Frontend

The frontend is built using **Flutter** and provides a responsive and
user-friendly interface for managing emails. Key features include:

-   Viewing and organizing emails.
-   Displaying categorized emails.
-   Showing AI-generated summaries and reply suggestions.
-   A clean and intuitive design for enhanced usability.

## Analysis of Feasibility

-   **Scalability**: The system is designed to handle a growing number of users
    and emails with efficient backend and database optimizations.
-   **Ease of Use**: The Flutter-based frontend ensures a smooth and intuitive
    user experience.
-   **Integration**: Seamless integration with the Gmail API and LangChain for
    advanced email management features.

## Potential Challenges

-   **API Rate Limits**: Managing Gmail API rate limits for large-scale email
    retrieval.
-   **Database Performance**: Ensuring fast query performance as the volume of
    email data grows.
-   **AI Integration**: Maintaining accuracy and efficiency in email
    categorization and summarization.

## Overcoming Strategies

-   **Caching**: Implement caching mechanisms to reduce API calls and improve
    performance.
-   **Database Optimization**: Use indexing and query optimization techniques to
    handle large datasets efficiently.

## Contributing

For changes, please open an issue first to discuss what you would like to
change. Contributions are welcome!

## License

This project is licensed under the MIT License. See the LICENSE file for
details.
