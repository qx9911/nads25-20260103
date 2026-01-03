from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt
from werkzeug.security import generate_password_hash

from models.user import User
from extensions import db

bp = Blueprint("user", __name__, url_prefix="/api/users")


def admin_required():
    claims = get_jwt()
    return claims.get("role") == "admin"


@bp.route("", methods=["GET"])
@jwt_required()
def list_users():
    if not admin_required():
        return jsonify({"error": "admin only"}), 403

    users = User.query.order_by(User.id).all()
    return jsonify([
        {
            "id": u.id,
            "username": u.username,
            "name": u.name,
            "email": u.email,
            "role": u.role,
            "is_active": u.is_active,
            "created_at": u.created_at.isoformat() if u.created_at else None,
        }
        for u in users
    ])


@bp.route("", methods=["POST"])
@jwt_required()
def create_user():
    if not admin_required():
        return jsonify({"error": "admin only"}), 403

    data = request.get_json() or {}

    username = data.get("username")
    password = data.get("password")
    role = data.get("role", "user")

    if not username or not password:
        return jsonify({"error": "username and password required"}), 400

    if User.query.filter_by(username=username).first():
        return jsonify({"error": "username already exists"}), 400

    user = User(
        username=username,
        name=data.get("name", ""),
        email=data.get("email", ""),
        role=role,
        is_active=True,
        password_hash=generate_password_hash(password),
    )

    db.session.add(user)
    db.session.commit()

    return jsonify({"message": "user created", "id": user.id})


@bp.route("/<int:user_id>", methods=["PUT"])
@jwt_required()
def update_user(user_id):
    if not admin_required():
        return jsonify({"error": "admin only"}), 403

    user = User.query.get_or_404(user_id)
    data = request.get_json() or {}

    user.name = data.get("name", user.name)
    user.email = data.get("email", user.email)
    user.role = data.get("role", user.role)

    if "password" in data and data["password"]:
        user.password_hash = generate_password_hash(data["password"])

    db.session.commit()
    return jsonify({"message": "user updated"})


@bp.route("/<int:user_id>/disable", methods=["POST"])
@jwt_required()
def disable_user(user_id):
    if not admin_required():
        return jsonify({"error": "admin only"}), 403

    user = User.query.get_or_404(user_id)
    user.is_active = False
    db.session.commit()

    return jsonify({"message": "user disabled"})


@bp.route("/<int:user_id>/enable", methods=["POST"])
@jwt_required()
def enable_user(user_id):
    if not admin_required():
        return jsonify({"error": "admin only"}), 403

    user = User.query.get_or_404(user_id)
    user.is_active = True
    db.session.commit()

    return jsonify({"message": "user enabled"})
