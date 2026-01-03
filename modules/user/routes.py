from flask import Blueprint, jsonify, request, abort
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt

from models import db
from models.user import User

bp = Blueprint("user", __name__, url_prefix="/api/user")


def require_admin():
    identity = get_jwt_identity()
    claims = get_jwt()

    if claims.get("role") != "admin":
        abort(403)

    user = User.query.filter_by(username=identity).first()
    if not user or user.role != "admin" or not user.is_active:
        abort(403)

    return user


@bp.route("", methods=["GET"])
@jwt_required()
def list_users():
    require_admin()

    users = User.query.order_by(User.id).all()
    return jsonify({
        "status": "ok",
        "users": [
            {
                "id": u.id,
                "username": u.username,
                "role": u.role,
                "is_active": bool(u.is_active)
            }
            for u in users
        ]
    })


@bp.route("/<int:user_id>/disable", methods=["POST"])
@jwt_required()
def disable_user(user_id):
    current_user = require_admin()

    if current_user.id == user_id:
        return jsonify({
            "status": "error",
            "message": "cannot disable yourself"
        }), 400

    user = User.query.get_or_404(user_id)
    user.is_active = False
    db.session.commit()

    return jsonify({
        "status": "ok",
        "message": "user disabled",
        "user_id": user.id
    })


@bp.route("/<int:user_id>/enable", methods=["POST"])
@jwt_required()
def enable_user(user_id):
    require_admin()

    user = User.query.get_or_404(user_id)
    user.is_active = True
    db.session.commit()

    return jsonify({
        "status": "ok",
        "message": "user enabled",
        "user_id": user.id
    })
