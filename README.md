# Task Manager Application

A full-stack task management application built with Flask (Python) backend and vanilla JavaScript frontend.

## Features

- ✅ Create, read, update, and delete tasks
- ✅ Mark tasks as completed/incomplete
- ✅ PostgreSQL database integration
- ✅ RESTful API endpoints
- ✅ CORS enabled for frontend-backend communication
- ✅ Clean and responsive UI

## Project Structure

```
├── backend/
│   ├── app.py              # Flask application with API endpoints
│   ├── requirements.txt    # Python dependencies
│   └── instance/          # Database instance files
└── frontend/
    ├── index.html         # Main HTML file
    ├── app.js            # JavaScript functionality
    └── styles.css        # CSS styling
```

## Quick Start with Docker

### Prerequisites
- Docker and Docker Compose installed
- Git (for cloning the repository)

### Local Development
```bash
# Clone the repository
git clone https://github.com/Pritee-c/task-manager-flask-docker.git
cd task-manager-flask-docker

# Start all services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop all services
docker-compose down
```

The application will be available at:
- Frontend: http://localhost
- Backend API: http://localhost:5000

### Production Deployment on EC2

1. **Launch an EC2 instance** (Ubuntu 20.04+ recommended)
2. **Configure Security Groups** to allow:
   - SSH (port 22) from your IP
   - HTTP (port 80) from anywhere
   - HTTPS (port 443) from anywhere
3. **Run the deployment script**:
   ```bash
   wget https://raw.githubusercontent.com/Pritee-c/task-manager-flask-docker/main/deploy-ec2.sh
   chmod +x deploy-ec2.sh
   ./deploy-ec2.sh
   ```

## Manual Setup (Alternative to Docker)

### Backend (Flask API)

### Prerequisites

- Python 3.7+
- PostgreSQL
- pip (Python package manager)

### Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Configure PostgreSQL:
   - Create a database named `taskdb`
   - Update connection settings in `app.py` if needed:
     ```python
     app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:root@localhost:5432/taskdb'
     ```

4. Run the application:
   ```bash
   python app.py
   ```

The API will be available at `http://localhost:5000`

### API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/tasks` | Get all tasks |
| POST | `/tasks` | Create a new task |
| PUT | `/tasks/<id>` | Update a specific task |
| DELETE | `/tasks/<id>` | Delete a specific task |

### Example API Usage

**Create a task:**
```bash
curl -X POST http://localhost:5000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Buy groceries", "description": "Milk, bread, eggs"}'
```

**Get all tasks:**
```bash
curl http://localhost:5000/tasks
```

## Frontend

The frontend is a simple single-page application using vanilla JavaScript, HTML, and CSS.

### Setup

1. Navigate to the frontend directory
2. Open `index.html` in a web browser
3. Make sure the backend is running on `http://localhost:5000`

## Database Schema

**Task Model:**
- `id`: Integer (Primary Key)
- `title`: String(120) - Required
- `description`: String(250) - Optional
- `completed`: Boolean - Default: False

## Technologies Used

### Backend
- **Flask** - Python web framework
- **Flask-SQLAlchemy** - ORM for database operations
- **Flask-CORS** - Cross-Origin Resource Sharing
- **PostgreSQL** - Database
- **psycopg2-binary** - PostgreSQL adapter

### Frontend
- **HTML5** - Structure
- **CSS3** - Styling
- **JavaScript (ES6+)** - Functionality
- **Fetch API** - HTTP requests

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a Pull Request

## Contact

For questions or suggestions, please open an issue in the GitHub repository.
