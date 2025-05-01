class CreateFeedbacks < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.references :author, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.references :recipient, null: false, foreign_key: { to_table: :users, on_delete: :cascade }
      t.integer :score, null: false
      t.text :comment, null: false
      t.date :week_start, null: false

      t.timestamps
    end

    add_index :feedbacks, [:author_id, :recipient_id, :week_start], unique: true
  end
end
