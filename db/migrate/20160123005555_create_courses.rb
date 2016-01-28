class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name, null: false
      t.string :status, null: false, index: true
      t.attachment :upload
      t.boolean :visible, default: false, null: false
      t.timestamps null: false
    end
  end
end
