# models.py
from app import db
from datetime import datetime


class table_ImageTrap_mail(db.Model):
    __tablename__ = 'ImageTrap_mail'

    id = db.Column(db.Integer, primary_key=True)
    ip_address = db.Column(db.String(100), nullable=False)
    geo_country = db.Column(db.String(100), nullable=False)
    geo_region = db.Column(db.String(100), nullable=False)
    geo_city = db.Column(db.String(100), nullable=False)
    geo_latitude = db.Column(db.String(100), nullable=False)
    geo_longitude = db.Column(db.String(100), nullable=False)
    ua_device = db.Column(db.String(100), nullable=False)
    ua_os = db.Column(db.String(100), nullable=False)
    ua_browser = db.Column(db.String(100), nullable=False)
    ua_browser_version = db.Column(db.String(100), nullable=False)
    referrer = db.Column(db.String(100), nullable=False)
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)

    def __repr__(self):
        return f'<Subscription {self.email} at {self.timestamp}>'
