from flask_sqlalchemy import SQLAlchemy
from flask_login import UserMixin
from datetime import datetime, timezone

db = SQLAlchemy()


class User(UserMixin, db.Model):
    __tablename__ = "users"
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(200), default="")
    team = db.Column(db.String(50), default="")
    role = db.Column(db.String(20), nullable=False)  # admin, researcher, requester


class EfficacyCatalog(db.Model):
    __tablename__ = "efficacy_catalog"
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100), nullable=False)
    target_marker = db.Column(db.String(200), default="")
    cell_line = db.Column(db.String(100), default="")
    bt_group = db.Column(db.String(20), default="common")  # common, BT1, BT2, BT3
    requires_discussion = db.Column(db.Boolean, default=False)


class Request(db.Model):
    __tablename__ = "requests"
    id = db.Column(db.Integer, primary_key=True)
    parent_id = db.Column(db.Integer, db.ForeignKey("requests.id"), nullable=True)
    material_name = db.Column(db.String(200), nullable=False)
    requester_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    requester_team = db.Column(db.String(50), default="")
    efficacy_types = db.Column(db.Text, default="")  # comma-separated (parent) or single (child)
    concentration = db.Column(db.String(100), default="")
    sample_count = db.Column(db.Integer, default=1)
    characteristics = db.Column(db.Text, default="")
    solvent = db.Column(db.String(100), default="")
    has_control = db.Column(db.Boolean, default=False)
    control_name = db.Column(db.String(200), default="")
    control_concentration = db.Column(db.String(100), default="")
    urgency = db.Column(db.String(20), default="보통")
    deadline = db.Column(db.String(50), default="")
    urgent_reason = db.Column(db.Text, default="")
    sample_return = db.Column(db.String(50), default="")
    has_specialized = db.Column(db.Boolean, default=False)
    specialized_types = db.Column(db.Text, default="")  # comma-separated specialized efficacy
    specialized_notes = db.Column(db.Text, default="")  # requester notes for specialized
    notes = db.Column(db.Text, default="")
    status = db.Column(db.String(20), default="submitted")
    # submitted / pending / in_progress / documenting / completed / rejected
    researcher_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=True)
    estimated_weeks = db.Column(db.Integer, nullable=True)  # legacy
    start_week = db.Column(db.String(50), default="")  # e.g. "2026-03-W2" (3월 둘째주)
    result = db.Column(db.Text, default="")
    year = db.Column(db.Integer, default=0)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    claimed_at = db.Column(db.DateTime, nullable=True)
    completed_at = db.Column(db.DateTime, nullable=True)
    gmail_sent = db.Column(db.Boolean, default=False)
    # File attachment
    file_path = db.Column(db.String(500), default="")
    file_name = db.Column(db.String(200), default="")
    file_uploaded_at = db.Column(db.DateTime, nullable=True)
    file_requested = db.Column(db.Boolean, default=False)
    sharepoint_url = db.Column(db.String(500), default="")
    is_specialized_child = db.Column(db.Boolean, default=False)
    assigned_researcher_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=True)
    assigned_team = db.Column(db.String(50), default="")  # BT1/BT2/BT3 team assignment
    admin_memo = db.Column(db.Text, default="")

    requester = db.relationship("User", foreign_keys=[requester_id], backref="my_requests")
    researcher = db.relationship("User", foreign_keys=[researcher_id], backref="my_experiments")
    parent = db.relationship("Request", remote_side=[id], backref="children")


class Message(db.Model):
    __tablename__ = "messages"
    id = db.Column(db.Integer, primary_key=True)
    request_id = db.Column(db.Integer, db.ForeignKey("requests.id"), nullable=False)
    sender_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    content = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))

    sender = db.relationship("User", backref="messages")
    request = db.relationship("Request", backref="messages")


class MessageRead(db.Model):
    __tablename__ = "message_reads"
    id = db.Column(db.Integer, primary_key=True)
    request_id = db.Column(db.Integer, db.ForeignKey("requests.id"), nullable=False)
    user_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    last_read_id = db.Column(db.Integer, default=0)  # last message id user has seen
