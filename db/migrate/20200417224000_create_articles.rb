class CreateArticles < ActiveRecord::Migration[6.0]
  def change
    create_table :articles do |t|
      t.references :user_id, null: false, foreign_key: true
      t.string :title
      t.string :text
      t.string :image
      t.datetime :post_date

      t.timestamps
    end
  end
end
