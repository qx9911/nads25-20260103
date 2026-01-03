from .routes import bp

def init_app(app):
    # 明確指定 prefix，不要再靠 module.json
    app.register_blueprint(bp, url_prefix="/api/auth")
