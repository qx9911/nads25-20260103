
def init_app(app):
    from .routes import bp
    app.register_blueprint(bp, url_prefix="/api/system")
