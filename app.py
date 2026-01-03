from flask import Flask
from flask_jwt_extended import JWTManager
import os
from flask_cors import CORS


from models import db


def create_app():
    app = Flask(__name__)
    CORS(app, supports_credentials=True)

    # JWT
    app.config["JWT_SECRET_KEY"] = os.environ.get(
        "JWT_SECRET_KEY",
        "CHANGE_THIS_TO_LONG_RANDOM_STRING"
    )

    # Database（使用 DB_*）
    db_user = os.environ.get("DB_USER")
    db_password = os.environ.get("DB_PASSWORD")
    db_host = os.environ.get("DB_HOST")
    db_port = os.environ.get("DB_PORT", "3306")
    db_name = os.environ.get("DB_NAME")

    app.config["SQLALCHEMY_DATABASE_URI"] = (
        f"mysql+pymysql://{db_user}:{db_password}"
        f"@{db_host}:{db_port}/{db_name}?charset=utf8mb4"
    )
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)
    JWTManager(app)

    from modules.system.routes import bp as system_bp
    from modules.auth.routes import bp as auth_bp
    from modules.user.routes import bp as user_bp

    app.register_blueprint(system_bp, url_prefix="/api/system")
    app.register_blueprint(auth_bp, url_prefix="/api/auth")
    app.register_blueprint(user_bp, url_prefix="/api/user")

    return app


app = create_app()
