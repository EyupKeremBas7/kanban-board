"""Add notification preferences

Revision ID: 0002_notification_preferences
Revises: 0001_initial
Create Date: 2026-05-14
"""
from alembic import op
import sqlalchemy as sa


revision = "0002_notification_preferences"
down_revision = "0001_initial"
branch_labels = None
depends_on = None


def upgrade():
    op.execute("ALTER TYPE notificationtype ADD VALUE IF NOT EXISTS 'invitation_accepted'")
    op.execute("ALTER TYPE notificationtype ADD VALUE IF NOT EXISTS 'invitation_rejected'")
    op.execute("ALTER TYPE notificationtype ADD VALUE IF NOT EXISTS 'mentioned'")

    op.create_table(
        "notification_preference",
        sa.Column("id", sa.UUID(), server_default=sa.text("gen_random_uuid()"), nullable=False),
        sa.Column("user_id", sa.UUID(), nullable=False),
        sa.Column("in_app_enabled", sa.Boolean(), nullable=False, server_default="true"),
        sa.Column("email_enabled", sa.Boolean(), nullable=False, server_default="true"),
        sa.Column("comments_enabled", sa.Boolean(), nullable=False, server_default="true"),
        sa.Column("assignments_enabled", sa.Boolean(), nullable=False, server_default="true"),
        sa.Column("card_moves_enabled", sa.Boolean(), nullable=False, server_default="true"),
        sa.Column("checklist_enabled", sa.Boolean(), nullable=False, server_default="true"),
        sa.Column("invitations_enabled", sa.Boolean(), nullable=False, server_default="true"),
        sa.Column("mentions_enabled", sa.Boolean(), nullable=False, server_default="true"),
        sa.Column("created_at", sa.DateTime(), server_default=sa.text("NOW()"), nullable=False),
        sa.Column("updated_at", sa.DateTime(), server_default=sa.text("NOW()"), nullable=False),
        sa.ForeignKeyConstraint(["user_id"], ["user.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", name="uq_notification_preference_user"),
    )
    op.create_index(
        "ix_notification_preference_user_id",
        "notification_preference",
        ["user_id"],
        unique=False,
    )


def downgrade():
    op.drop_index("ix_notification_preference_user_id", table_name="notification_preference")
    op.drop_table("notification_preference")
