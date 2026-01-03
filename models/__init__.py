from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

# ⚠️ 這行非常重要：讓 Flask 載入 User model
from .user import User
