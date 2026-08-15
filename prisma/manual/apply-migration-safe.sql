-- ===========================================================================
-- Arthings — міграція, БЕЗПЕЧНА ДЛЯ ПОВТОРНОГО ЗАПУСКУ
-- ===========================================================================
-- Об'єднує ОБИДВІ міграції з prisma/migrations (202607260001 + 202608140001)
-- і робить кожну операцію такою, що пропускається, якщо об'єкт уже існує.
--
-- Обидві потрібні тому, що базу цієї гілки створювали через `prisma db push`,
-- а не міграціями, і першу з них тут ніколи не застосовували.
--
-- Навіщо окремий файл: канонічну міграцію застосовує `prisma migrate deploy`,
-- і вона свідомо падає, якщо щось уже створено — це правильна поведінка для
-- інструмента міграцій. Цей файл призначений для ручного запуску в
-- Neon Console → SQL Editor, зокрема після спроби, що обірвалася на середині.
--
-- ЯК КОРИСТУВАТИСЯ
--   1. Neon Console → SQL Editor
--   2. Переконайтесь, що обрано ПРАВИЛЬНУ базу: endpoint має збігатися з
--      хостом у вашому DATABASE_URL (починається з ep-super-wildflower-...).
--      Якщо у проєкті кілька branches — виберіть ту, на яку дивиться Vercel.
--   3. Вставте весь цей файл і натисніть Run
--   4. Унизу має з'явитися результат перевірки — рівно 3 рядки
--
-- Перевірити результат ззовні:
--   curl -s https://arthings-main-5t3e.vercel.app/api/health
--   має показати "schema": "ready"
-- ===========================================================================

-- ---------------------------------------------------------------------------
-- 0. ПЕРЕДУМОВА: поля житла та таблиця чату
--
--    Ці зміни колись вносила міграція 202607260001, але у цій базі її
--    ніколи не застосовували: гілку main2 створювали через `prisma db push`
--    зі схеми, з якої житло було відкочене. Тому таблиця "items" не має
--    housing_type / rooms / area, а таблиці "messages" (чат) немає взагалі.
--
--    Без цього кроку падає UPDATE у розділі 3, який посилається на
--    housing_type, і все після нього не виконується.
-- ---------------------------------------------------------------------------
ALTER TABLE "items"
    ADD COLUMN IF NOT EXISTS "address" VARCHAR(255),
    ADD COLUMN IF NOT EXISTS "housing_type" VARCHAR(30),
    ADD COLUMN IF NOT EXISTS "rooms" INTEGER,
    ADD COLUMN IF NOT EXISTS "area" DECIMAL(8,2),
    ADD COLUMN IF NOT EXISTS "floor" INTEGER,
    ADD COLUMN IF NOT EXISTS "total_floors" INTEGER,
    ADD COLUMN IF NOT EXISTS "is_furnished" BOOLEAN,
    ADD COLUMN IF NOT EXISTS "pets_allowed" BOOLEAN,
    ADD COLUMN IF NOT EXISTS "students_allowed" BOOLEAN NOT NULL DEFAULT false;

CREATE INDEX IF NOT EXISTS "items_students_allowed_idx" ON "items"("students_allowed");

-- Приватні повідомлення між користувачами (чат).
CREATE TABLE IF NOT EXISTS "messages" (
    "id" SERIAL NOT NULL,
    "sender_id" INTEGER NOT NULL,
    "recipient_id" INTEGER NOT NULL,
    "item_id" INTEGER,
    "body" TEXT NOT NULL,
    "read_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "messages_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id")
        REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "messages_recipient_id_fkey" FOREIGN KEY ("recipient_id")
        REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "messages_item_id_fkey" FOREIGN KEY ("item_id")
        REFERENCES "items"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS "messages_sender_id_recipient_id_created_at_idx"
    ON "messages"("sender_id", "recipient_id", "created_at");
CREATE INDEX IF NOT EXISTS "messages_recipient_id_read_at_idx"
    ON "messages"("recipient_id", "read_at");
CREATE INDEX IF NOT EXISTS "messages_item_id_idx" ON "messages"("item_id");

-- ---------------------------------------------------------------------------
-- 1. Типи (enum)
-- ---------------------------------------------------------------------------
DO $$ BEGIN
    CREATE TYPE "ListingType" AS ENUM ('item', 'housing');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE "HousingCategory" AS ENUM ('apartment', 'house', 'room', 'hostel', 'commercial', 'garage');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE "RentalPeriod" AS ENUM ('daily', 'weekly', 'monthly', 'short_term', 'long_term');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE "NotificationType" AS ENUM (
        'rental_requested', 'rental_accepted', 'rental_rejected',
        'rental_cancelled', 'rental_completed', 'message_received',
        'rating_received', 'system'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ---------------------------------------------------------------------------
-- 2. Користувачі: агреговані рейтинги
--    Без цих колонок падає РЕЄСТРАЦІЯ: Prisma при створенні користувача
--    читає всі поля моделі, зокрема rating_avg.
-- ---------------------------------------------------------------------------
ALTER TABLE "users"
    ADD COLUMN IF NOT EXISTS "rating_avg" DECIMAL(3,2) NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS "rating_count" INTEGER NOT NULL DEFAULT 0;

UPDATE "users" u
SET "rating_avg" = COALESCE(r.avg_score, 0),
    "rating_count" = COALESCE(r.cnt, 0)
FROM (
    SELECT "to_user_id", ROUND(AVG("score")::numeric, 2) AS avg_score, COUNT(*) AS cnt
    FROM "ratings"
    GROUP BY "to_user_id"
) r
WHERE u."id" = r."to_user_id";

-- ---------------------------------------------------------------------------
-- 3. Оголошення: тип, адреса, координати, параметри житла
--    Без цих колонок не вантажаться РЕЧІ, ЖИТЛО і КАРТА.
-- ---------------------------------------------------------------------------
ALTER TABLE "items"
    ADD COLUMN IF NOT EXISTS "listing_type" "ListingType" NOT NULL DEFAULT 'item',
    ADD COLUMN IF NOT EXISTS "country" VARCHAR(100) NOT NULL DEFAULT 'Ukraine',
    ADD COLUMN IF NOT EXISTS "region" VARCHAR(120),
    ADD COLUMN IF NOT EXISTS "district" VARCHAR(120),
    ADD COLUMN IF NOT EXISTS "village" VARCHAR(120),
    ADD COLUMN IF NOT EXISTS "street" VARCHAR(160),
    ADD COLUMN IF NOT EXISTS "house_number" VARCHAR(30),
    ADD COLUMN IF NOT EXISTS "postcode" VARCHAR(20),
    ADD COLUMN IF NOT EXISTS "latitude" DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS "longitude" DOUBLE PRECISION,
    ADD COLUMN IF NOT EXISTS "geocoded_at" TIMESTAMP(3),
    ADD COLUMN IF NOT EXISTS "geocode_accuracy" VARCHAR(30),
    ADD COLUMN IF NOT EXISTS "geocode_query" VARCHAR(500),
    ADD COLUMN IF NOT EXISTS "housing_category" "HousingCategory",
    ADD COLUMN IF NOT EXISTS "rental_period" "RentalPeriod",
    ADD COLUMN IF NOT EXISTS "max_guests" INTEGER,
    ADD COLUMN IF NOT EXISTS "smoking_allowed" BOOLEAN,
    ADD COLUMN IF NOT EXISTS "has_internet" BOOLEAN,
    ADD COLUMN IF NOT EXISTS "has_parking" BOOLEAN,
    ADD COLUMN IF NOT EXISTS "utilities_included" BOOLEAN;

-- Оголошення, створені раніше з параметрами житла, позначаємо як житло.
UPDATE "items"
SET "listing_type" = 'housing'
WHERE "listing_type" = 'item'
  AND ("housing_type" IS NOT NULL OR "rooms" IS NOT NULL OR "area" IS NOT NULL);

CREATE INDEX IF NOT EXISTS "items_listing_type_is_available_idx" ON "items"("listing_type", "is_available");
CREATE INDEX IF NOT EXISTS "items_listing_type_category_idx"     ON "items"("listing_type", "category");
CREATE INDEX IF NOT EXISTS "items_housing_category_idx"          ON "items"("housing_category");
CREATE INDEX IF NOT EXISTS "items_rental_period_idx"             ON "items"("rental_period");
CREATE INDEX IF NOT EXISTS "items_latitude_longitude_idx"        ON "items"("latitude", "longitude");

-- ---------------------------------------------------------------------------
-- 4. Оренди: метадані життєвого циклу
-- ---------------------------------------------------------------------------
ALTER TABLE "rentals"
    ADD COLUMN IF NOT EXISTS "owner_response" TEXT,
    ADD COLUMN IF NOT EXISTS "responded_at" TIMESTAMP(3),
    ADD COLUMN IF NOT EXISTS "cancelled_at" TIMESTAMP(3),
    ADD COLUMN IF NOT EXISTS "cancelled_by_id" INTEGER,
    ADD COLUMN IF NOT EXISTS "completed_at" TIMESTAMP(3);

CREATE INDEX IF NOT EXISTS "rentals_item_id_status_start_date_end_date_idx"
    ON "rentals"("item_id", "status", "start_date", "end_date");

-- ---------------------------------------------------------------------------
-- 5. Календар зайнятості
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "item_availability" (
    "id" SERIAL NOT NULL,
    "item_id" INTEGER NOT NULL,
    "start_date" DATE NOT NULL,
    "end_date" DATE NOT NULL,
    "reason" VARCHAR(255),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "item_availability_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "item_availability_item_id_fkey" FOREIGN KEY ("item_id")
        REFERENCES "items"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS "item_availability_item_id_start_date_end_date_idx"
    ON "item_availability"("item_id", "start_date", "end_date");

-- ---------------------------------------------------------------------------
-- 6. Кеш геокодування
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "geocode_cache" (
    "id" SERIAL NOT NULL,
    "query_key" VARCHAR(500) NOT NULL,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "display_name" VARCHAR(500),
    "accuracy" VARCHAR(30),
    "payload" JSONB,
    "hits" INTEGER NOT NULL DEFAULT 0,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "geocode_cache_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "geocode_cache_query_key_key" ON "geocode_cache"("query_key");
CREATE INDEX IF NOT EXISTS "geocode_cache_updated_at_idx" ON "geocode_cache"("updated_at");

-- ---------------------------------------------------------------------------
-- 7. Історія статусів оренди
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "rental_events" (
    "id" SERIAL NOT NULL,
    "rental_id" INTEGER NOT NULL,
    "actor_id" INTEGER,
    "status" "RentalStatus" NOT NULL,
    "note" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "rental_events_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "rental_events_rental_id_fkey" FOREIGN KEY ("rental_id")
        REFERENCES "rentals"("id") ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT "rental_events_actor_id_fkey" FOREIGN KEY ("actor_id")
        REFERENCES "users"("id") ON DELETE SET NULL ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS "rental_events_rental_id_created_at_idx"
    ON "rental_events"("rental_id", "created_at");

-- Заповнюємо історію для наявних оренд.
-- NOT EXISTS захищає від дублікатів при повторному запуску.
-- Тип enum приводиться явно: в INSERT...SELECT Postgres вважає літерал
-- текстом і не приводить його до enum автоматично.
INSERT INTO "rental_events" ("rental_id", "actor_id", "status", "note", "created_at")
SELECT r."id", r."renter_id", 'pending'::"RentalStatus", 'Request created', r."created_at"
FROM "rentals" r
WHERE NOT EXISTS (
    SELECT 1 FROM "rental_events" e
    WHERE e."rental_id" = r."id" AND e."status" = 'pending'
);

INSERT INTO "rental_events" ("rental_id", "actor_id", "status", "note", "created_at")
SELECT r."id", NULL::INTEGER, r."status", 'Imported from previous status', r."updated_at"
FROM "rentals" r
WHERE r."status" <> 'pending'
  AND NOT EXISTS (
      SELECT 1 FROM "rental_events" e
      WHERE e."rental_id" = r."id" AND e."status" = r."status"
  );

-- ---------------------------------------------------------------------------
-- 8. Сповіщення
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "notifications" (
    "id" SERIAL NOT NULL,
    "user_id" INTEGER NOT NULL,
    "type" "NotificationType" NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "body" TEXT,
    "link" VARCHAR(500),
    "read_at" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT "notifications_pkey" PRIMARY KEY ("id"),
    CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id")
        REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX IF NOT EXISTS "notifications_user_id_read_at_created_at_idx"
    ON "notifications"("user_id", "read_at", "created_at");

-- ===========================================================================
-- ПЕРЕВІРКА
-- Має повернути рівно 3 рядки: latitude / listing_type / longitude
-- Якщо повернулося 0 рядків — ви виконали це на іншій базі.
-- ===========================================================================
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'items'
  AND column_name IN ('listing_type', 'latitude', 'longitude')
ORDER BY column_name;
