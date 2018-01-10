# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180110082651) do

  create_table "interviewers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "email"
    t.text     "skill_set",        limit: 65535
    t.string   "title"
    t.text     "languages",        limit: 65535
    t.string   "expertise"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.text     "languages_set",    limit: 65535
    t.text     "skills",           limit: 65535
    t.text     "domain",           limit: 65535
    t.text     "location",         limit: 65535
    t.integer  "total_yrs_of_exp"
  end

end
