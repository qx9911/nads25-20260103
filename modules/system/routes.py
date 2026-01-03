
from flask import Blueprint, jsonify
bp = Blueprint("system", __name__)

@bp.route("/health")
def health():
    return jsonify(status="ok", module="system")
