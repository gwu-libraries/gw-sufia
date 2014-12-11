class MailboxerNamespacingCompatibility < ActiveRecord::Migration

  def self.up
    remove_foreign_key 'receipts', name: "receipts_on_notification_id"
    remove_foreign_key 'notifications', name: "notifications_on_conversation_id"

    rename_table :conversations, :mailboxer_conversations
    rename_table :notifications, :mailboxer_notifications
    rename_table :receipts,      :mailboxer_receipts

    add_foreign_key 'mailboxer_receipts', 'mailboxer_notifications', name: "mailboxer_receipts_on_notification_id_#{Rails.env}", column: :notification_id
    add_foreign_key 'mailboxer_notifications', 'mailboxer_conversations', name: "notifications_on_conversation_id_#{Rails.env}", column: :conversation_id

    if Rails.version < '4'
      rename_index :mailboxer_notifications, :notifications_on_conversation_id, :mailboxer_notifications_on_conversation_id
      rename_index :mailboxer_receipts,      :receipts_on_notification_id,      :mailboxer_receipts_on_notification_id
    end
  end

  def self.down
    remove_foreign_key "mailboxer_receipts", name: "mailboxer_receipts_on_notification_id"
    remove_foreign_key "mailboxer_notifications", name: "notifications_on_conversation_id"

    rename_table :mailboxer_conversations, :conversations
    rename_table :mailboxer_notifications, :notifications
    rename_table :mailboxer_receipts,      :receipts

    add_foreign_key "receipts", "notifications", name: "receipts_on_notification_id_#{Rails.env}", column: :notification_id
    add_foreign_key "notifications", "conversations", name: "notifications_on_conversation_id_#{Rails.env}", column: :conversation_id

    if Rails.version < '4'
      rename_index :notifications, :mailboxer_notifications_on_conversation_id, :notifications_on_conversation_id
      rename_index :receipts,      :mailboxer_receipts_on_notification_id,      :receipts_on_notification_id
    end
  end
end
