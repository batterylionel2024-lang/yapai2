# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_15_112000) do
  create_table "a_sku_details", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "net_capacity"
    t.string "packaging_dimensions"
    t.text "standard_features"
    t.text "standard_features_zh"
    t.string "temp_range"
    t.string "unit_dimensions"
    t.datetime "updated_at", null: false
    t.string "voltage_frequency"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.integer "position", default: 0
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["position"], name: "index_active_storage_attachments_on_position"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "b_sku_details", force: :cascade do |t|
    t.string "burners_and_control_method"
    t.datetime "created_at", null: false
    t.string "exterior_dimensions"
    t.string "gas_type"
    t.string "intake_tube_pressure"
    t.string "per_btu"
    t.string "regulator"
    t.text "standard_features"
    t.text "standard_features_zh"
    t.string "total_btu"
    t.string "unit_dimensions"
    t.datetime "updated_at", null: false
    t.string "work_area"
  end

  create_table "c_sku_details", force: :cascade do |t|
    t.string "burners_and_control_method"
    t.datetime "created_at", null: false
    t.string "exterior_dimensions"
    t.string "faucet_and_drain"
    t.string "gas_type"
    t.string "intake_tube_pressure"
    t.string "leg_bracing"
    t.string "per_btu"
    t.string "product_dimensions"
    t.string "regulator"
    t.string "sink_bowl_dimensions"
    t.string "sink_depth"
    t.text "standard_features"
    t.text "standard_features_zh"
    t.string "total_btu"
    t.string "unit_dimensions"
    t.datetime "updated_at", null: false
    t.string "work_area"
  end

  create_table "categories", force: :cascade do |t|
    t.string "category_kind"
    t.integer "channel_id"
    t.datetime "created_at", null: false
    t.boolean "featured", default: false
    t.integer "featured_position", default: 0
    t.boolean "hidden", default: false, null: false
    t.string "keywords"
    t.text "meta_description"
    t.string "meta_keywords"
    t.string "meta_title"
    t.string "name"
    t.string "name_zh"
    t.integer "parent_id"
    t.integer "position"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["channel_id"], name: "index_categories_on_channel_id"
    t.index ["parent_id"], name: "index_categories_on_parent_id"
    t.index ["slug"], name: "index_categories_on_slug"
  end

  create_table "channels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "key"
    t.string "name"
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_channels_on_key", unique: true
  end

  create_table "contact_messages", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.text "message"
    t.string "name"
    t.boolean "read", default: false
    t.string "subject"
    t.datetime "updated_at", null: false
    t.index ["read"], name: "index_contact_messages_on_read"
  end

  create_table "faq_categories", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.text "name"
    t.integer "position", default: 0
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "faqs", force: :cascade do |t|
    t.text "answer"
    t.datetime "created_at", precision: nil, null: false
    t.integer "faq_category_id", null: false
    t.integer "position", default: 0
    t.text "question"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "home_products", force: :cascade do |t|
    t.boolean "active"
    t.datetime "created_at", null: false
    t.string "link"
    t.integer "position"
    t.integer "row"
    t.string "title"
    t.datetime "updated_at", null: false
  end

  create_table "login_logs", force: :cascade do |t|
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "login_at"
    t.string "province"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_login_logs_on_user_id"
  end

  create_table "operation_logs", force: :cascade do |t|
    t.string "action"
    t.datetime "created_at", null: false
    t.text "details"
    t.string "ip_address"
    t.integer "resource_id"
    t.string "resource_type"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_operation_logs_on_user_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "order_id", null: false
    t.integer "quantity"
    t.integer "sku_id", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["sku_id"], name: "index_order_items_on_sku_id"
  end

  create_table "orders", force: :cascade do |t|
    t.string "country"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "phone"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "partners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.text "meta_description"
    t.string "meta_keywords"
    t.string "meta_title"
    t.datetime "published_at"
    t.string "status"
    t.text "summary"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0
    t.index ["category"], name: "index_posts_on_category"
  end

  create_table "site_configs", force: :cascade do |t|
    t.string "address"
    t.string "copyright_year"
    t.datetime "created_at", null: false
    t.string "email"
    t.string "infra_label_1"
    t.string "infra_label_2"
    t.string "infra_label_3"
    t.string "infra_label_4"
    t.string "infra_subtitle"
    t.string "infra_title"
    t.string "infra_value_1"
    t.string "infra_value_2"
    t.string "infra_value_3"
    t.string "infra_value_4"
    t.string "meta_description"
    t.string "meta_keywords"
    t.string "meta_title"
    t.string "name"
    t.string "phone"
    t.text "statistics_code"
    t.datetime "updated_at", null: false
  end

  create_table "skus", force: :cascade do |t|
    t.string "brim_length"
    t.string "carton_size"
    t.integer "category_id", null: false
    t.string "closure"
    t.string "closure_type"
    t.string "color"
    t.datetime "created_at", null: false
    t.string "embroidery_print"
    t.string "fabric"
    t.string "gross_weight"
    t.string "head_circumference"
    t.string "item"
    t.string "item_no"
    t.string "material"
    t.text "meta_description"
    t.string "meta_keywords"
    t.string "meta_title"
    t.string "moq"
    t.string "name"
    t.string "packing"
    t.integer "position", default: 0, null: false
    t.decimal "price", precision: 10, scale: 2
    t.string "product_name"
    t.string "production_lead_time"
    t.string "profile"
    t.string "sample_time"
    t.string "specification"
    t.text "standard_features"
    t.string "status", default: "draft"
    t.string "unit_dimensions"
    t.datetime "updated_at", null: false
    t.string "visor"
    t.index ["category_id"], name: "index_skus_on_category_id"
    t.index ["status"], name: "index_skus_on_status"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", limit: 1024, null: false
    t.integer "channel_hash", limit: 8, null: false
    t.datetime "created_at", null: false
    t.binary "payload", limit: 536870912, null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", limit: 4, null: false
    t.datetime "created_at", null: false
    t.binary "key", limit: 1024, null: false
    t.integer "key_hash", limit: 8, null: false
    t.binary "value", limit: 536870912, null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts", default: 0, null: false
    t.datetime "locked_at"
    t.string "login_otp"
    t.datetime "login_otp_sent_at"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.string "role", default: "user"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  create_table "visit_records", force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "district"
    t.string "ip"
    t.string "path"
    t.string "session_id"
    t.string "state"
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.datetime "visit_time"
    t.index ["session_id", "visit_time"], name: "index_visit_records_on_session_id_and_visit_time"
    t.index ["session_id"], name: "index_visit_records_on_session_id"
    t.index ["visit_time"], name: "index_visit_records_on_visit_time"
  end

  create_table "visits", force: :cascade do |t|
    t.string "city"
    t.string "country"
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.string "isp"
    t.string "page_name"
    t.string "page_url"
    t.string "referer"
    t.string "region"
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.datetime "visited_at"
    t.index ["country", "region", "city"], name: "index_visits_on_country_and_region_and_city"
    t.index ["ip_address"], name: "index_visits_on_ip_address"
    t.index ["page_url"], name: "index_visits_on_page_url"
    t.index ["visited_at"], name: "index_visits_on_visited_at"
  end

  create_table "warranty_inquiries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "email"
    t.string "model_number"
    t.string "name"
    t.string "phone"
    t.string "product_type"
    t.string "status"
    t.string "subject"
    t.datetime "updated_at", null: false
  end

  create_table "warranty_pdfs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "description"
    t.string "name", null: false
    t.string "pdf_type", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_warranty_pdfs_on_name"
    t.index ["pdf_type"], name: "index_warranty_pdfs_on_pdf_type", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "faqs", "faq_categories"
  add_foreign_key "login_logs", "users"
  add_foreign_key "operation_logs", "users"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "skus"
  add_foreign_key "skus", "categories"
end
