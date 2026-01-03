from flask import Blueprint, request, jsonify
from flask_jwt_extended import (
    create_access_token,
    create_refresh_token,
    jwt_required,
    get_jwt_identity,
)
from werkzeug.security import check_password_hash

from models import db, User

bp = Blueprint("auth", __name__)


# =========================
# 登入
# =========================
@bp.route("/login", methods=["POST"])
def login():
    data = request.get_json() or {}

    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return {"message": "Missing username or password"}, 400

    user = User.query.filter_by(username=username).first()
    if not user or not user.is_active:
        return {"message": "Invalid credentials"}, 401

    if not check_password_hash(user.password_hash, password):
        return {"message": "Invalid credentials"}, 401

    access_token = create_access_token(
        identity=user.username,
        additional_claims={
            "role": user.role
        }
    )

    refresh_token = create_refresh_token(
        identity=user.username
    )

    return jsonify({
        "access_token": access_token,
        "refresh_token": refresh_token,
        "user": {
            "username": user.username,
            "role": user.role
        }
    })


# =========================
# Refresh access token
# =========================
@bp.route("/refresh", methods=["POST"])
@jwt_required(refresh=True)
def refresh():
    username = get_jwt_identity()

    user = User.query.filter_by(username=username).first()
    if not user or not user.is_active:
        return {"message": "User disabled"}, 401

    new_access_token = create_access_token(
        identity=user.username,
        additional_claims={
            "role": user.role
        }
    )

    return jsonify({
        "access_token": new_access_token
    })


# =========================
# 登出（前端清 token 即可）
# =========================
@bp.route("/logout", methods=["POST"])
def logout():
    return {"message": "ok"}
