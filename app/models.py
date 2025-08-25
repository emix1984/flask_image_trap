# models.py
from app import db
from datetime import datetime
import pytz


class table_mail_ts(db.Model):
    __tablename__ = 'mail_ts'

    id = db.Column(db.Integer, primary_key=True)
    ip_address = db.Column(db.String(100), nullable=False)
    geo_country = db.Column(db.String(100), nullable=False)
    geo_region = db.Column(db.String(100), nullable=False)
    geo_city = db.Column(db.String(100), nullable=False)
    geo_latitude = db.Column(db.String(100), nullable=True)
    geo_longitude = db.Column(db.String(100), nullable=True)
    ua_device = db.Column(db.String(100), nullable=True)
    ua_os = db.Column(db.String(100), nullable=True)
    ua_browser = db.Column(db.String(100), nullable=True)
    referrer = db.Column(db.String(100), nullable=False)
    
    # 明确指定时间戳字段，不允许为空
    timestamp = db.Column(db.DateTime, nullable=False)

    def __repr__(self):
        return f'<table_mail_ts {self.ip_address} at {self.timestamp}>'