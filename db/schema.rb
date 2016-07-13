# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160713151108) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_counts", force: :cascade do |t|
    t.integer  "cnt_search_by_keyword",     default: 0
    t.integer  "cnt_search_by_pid",         default: 0
    t.integer  "cnt_search_by_coordinate",  default: 0
    t.integer  "cnt_get_next_page_pid",     default: 0
    t.integer  "cnt_get_next_page_keyword", default: 0
    t.integer  "cnt_get_pid",               default: 0
    t.integer  "cnt_get_detail",            default: 0
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "detail_counts", force: :cascade do |t|
    t.string   "pid"
    t.string   "name"
    t.integer  "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "keyword_counts", force: :cascade do |t|
    t.string   "keyword"
    t.integer  "count",        default: 0
    t.boolean  "autocomplete"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "option"
    t.integer  "debug"
    t.integer  "r_count"
  end

  create_table "pid_counts", force: :cascade do |t|
    t.string   "pid"
    t.string   "option"
    t.integer  "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
