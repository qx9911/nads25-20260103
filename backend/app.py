from flask import Flask, jsonify
from flask_cors import CORS
from flask_jwt_extended import JWTManager, jwt_required, create_access_token

app = Flask(__name__)

# ⚠️ JWT secret（之後可拉到 .env）
app.config["JWT_SECRET_KEY"] = "nads25-secret-key"

CORS(app)
jwt = JWTManager(app)

@app.get("/api/system/health")
def health():
    return {"status": "ok"}

@app.post("/api/auth/login")
def login():
    token = create_access_token(
        identity="peter",
        additional_claims={"role": "admin"}
    )
    return {"access_token": token}

@app.get("/api/user")
@jwt_required()
def list_users():
    return {
        "status": "ok",
        "users": [
            {"id": 1, "username": "peter", "role": "admin", "is_active": True},
            {"id": 2, "username": "someone", "role": "admin", "is_active": True},
        ]
    }

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
