-- ===========================================================================
-- Arthings — ДЕМОНСТРАЦІЙНІ ОГОЛОШЕННЯ
-- ===========================================================================
-- Наповнює каталог і карту, щоб побачити маркетплейс у робочому вигляді.
--
-- ЯК ВИДАЛИТИ ВСЕ ОДНИМ ЗАПИТОМ (див. також кінець файлу):
--   DELETE FROM "users" WHERE "email" LIKE '%@demo.arthings.local';
-- Каскад прибере всі демо-оголошення й зображення разом з акаунтами.
--
-- Демо-акаунти мають НЕПРИДАТНИЙ хеш пароля — увійти під ними неможливо.
-- Безпечно запускати повторно: старі демо-дані спершу видаляються.
-- ===========================================================================

BEGIN;

-- Прибираємо попередній прогін, щоб не накопичувати дублікати.
DELETE FROM "users" WHERE "email" LIKE '%@demo.arthings.local';

-- Демо-власники --------------------------------------------------------
INSERT INTO "users" ("email","password_hash","name","phone","city","is_verified","is_admin","rating_avg","rating_count","created_at","updated_at")
VALUES ('demo1@demo.arthings.local','!demo-account-no-login','Олена Кравченко','+380678353138','Львів',true,false,4.18,36,NOW() - INTERVAL '186 days',NOW());
INSERT INTO "users" ("email","password_hash","name","phone","city","is_verified","is_admin","rating_avg","rating_count","created_at","updated_at")
VALUES ('demo2@demo.arthings.local','!demo-account-no-login','Андрій Мельник','+380675434643','Одеса',true,false,4.9,34,NOW() - INTERVAL '62 days',NOW());
INSERT INTO "users" ("email","password_hash","name","phone","city","is_verified","is_admin","rating_avg","rating_count","created_at","updated_at")
VALUES ('demo3@demo.arthings.local','!demo-account-no-login','Софія Ткаченко','+380672319111','Харків',false,false,4.95,37,NOW() - INTERVAL '252 days',NOW());
INSERT INTO "users" ("email","password_hash","name","phone","city","is_verified","is_admin","rating_avg","rating_count","created_at","updated_at")
VALUES ('demo4@demo.arthings.local','!demo-account-no-login','Дмитро Бондаренко','+380679960124','Дніпро',true,false,4.15,35,NOW() - INTERVAL '92 days',NOW());
INSERT INTO "users" ("email","password_hash","name","phone","city","is_verified","is_admin","rating_avg","rating_count","created_at","updated_at")
VALUES ('demo5@demo.arthings.local','!demo-account-no-login','Марія Шевчук','+380678271324','Івано-Франківськ',true,false,4.46,11,NOW() - INTERVAL '53 days',NOW());
INSERT INTO "users" ("email","password_hash","name","phone","city","is_verified","is_admin","rating_avg","rating_count","created_at","updated_at")
VALUES ('demo6@demo.arthings.local','!demo-account-no-login','Ігор Коваленко','+380675722406','Вінниця',false,false,4.14,37,NOW() - INTERVAL '176 days',NOW());
INSERT INTO "users" ("email","password_hash","name","phone","city","is_verified","is_admin","rating_avg","rating_count","created_at","updated_at")
VALUES ('demo7@demo.arthings.local','!demo-account-no-login','Наталія Гриценко','+380674500261','Тернопіль',true,false,4.65,3,NOW() - INTERVAL '204 days',NOW());
INSERT INTO "users" ("email","password_hash","name","phone","city","is_verified","is_admin","rating_avg","rating_count","created_at","updated_at")
VALUES ('demo8@demo.arthings.local','!demo-account-no-login','Тарас Поліщук','+380676155878','Полтава',true,false,4.13,32,NOW() - INTERVAL '284 days',NOW());

-- Оголошення ------------------------------------------------------------
-- user_id береться через підзапит, тому SERIAL-значення не має значення.

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo2@demo.arthings.local'),'item','Проєктор Epson Full HD','Яскравий проєктор 3000 люмен для домашнього кінотеатру чи презентацій. У комплекті HDMI-кабель, сумка та штатив.',410,'day','electronics',
    'Ukraine','Львівська область','Львів','площа Ринок','93',49.845458,24.024217,NOW(),'street',
    true,229,false,NOW() - INTERVAL '76 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo3@demo.arthings.local'),'item','Дрон DJI Mini 3','Компактний дрон із камерою 4K, три акумулятори, пульт і кейс. Ідеально для зйомки подорожей.',790,'day','electronics',
    'Ukraine','Одеська область','Одеса','Французький бульвар','13',46.441503,30.721158,NOW(),'street',
    true,129,false,NOW() - INTERVAL '55 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo4@demo.arthings.local'),'item','Дзеркальний фотоапарат Canon EOS','Повний комплект: тушка, два об''єктиви 18-55 та 50mm, дві батареї, карта пам''яті.',640,'day','electronics',
    'Ukraine','Харківська область','Харків','вулиця Сумська','77',50.016177,36.177599,NOW(),'street',
    true,315,false,NOW() - INTERVAL '56 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo5@demo.arthings.local'),'item','Ноутбук MacBook Pro 14','M2 Pro, 16 ГБ RAM. Для монтажу, дизайну чи роботи у відрядженні. Із зарядкою та чохлом.',1040,'day','electronics',
    'Ukraine','Дніпропетровська область','Дніпро','вулиця Січових Стрільців','119',48.503032,35.09687,NOW(),'street',
    true,204,false,NOW() - INTERVAL '28 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo6@demo.arthings.local'),'item','Портативна колонка JBL Boombox','Потужний звук, до 24 годин автономності, захист від води. Для вечірок і пікніків.',340,'day','electronics',
    'Ukraine','Івано-Франківська область','Івано-Франківськ','вулиця Незалежності','75',48.90641,24.663892,NOW(),'street',
    true,193,false,NOW() - INTERVAL '6 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo7@demo.arthings.local'),'item','Генератор бензиновий 3 кВт','Заводиться з першого разу, повний бак. Вистачає на холодильник, роутер, світло та котел.',680,'day','emergency',
    'Ukraine','Вінницька область','Вінниця','вулиця Соборна','65',49.248104,28.515804,NOW(),'street',
    true,19,false,NOW() - INTERVAL '52 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo8@demo.arthings.local'),'item','Зарядна станція EcoFlow 1000W','Тиха альтернатива генератору для квартири. Заряджає ноутбук близько 15 разів.',490,'day','emergency',
    'Ukraine','Тернопільська область','Тернопіль','бульвар Тараса Шевченка','101',49.587396,25.588092,NOW(),'street',
    true,230,false,NOW() - INTERVAL '63 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo1@demo.arthings.local'),'item','Інверторний генератор 2 кВт','Малошумний, підходить для роботи вночі у дворі. Витрата приблизно 0,8 л/год.',530,'day','emergency',
    'Ukraine','Полтавська область','Полтава','вулиця Соборності','37',49.582032,34.510221,NOW(),'street',
    true,102,false,NOW() - INTERVAL '37 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo2@demo.arthings.local'),'item','Обігрівач газовий із балоном','Інфрачервоний обігрівач для гаража чи майстерні. Балон заправлений.',280,'day','emergency',
    'Ukraine','Чернівецька область','Чернівці','Центральна площа','78',48.248918,25.938806,NOW(),'street',
    true,315,false,NOW() - INTERVAL '36 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo3@demo.arthings.local'),'item','Перфоратор Bosch SDS-Plus','Професійний інструмент, набір буріння в комплекті. Впорається з бетоном.',220,'day','tools',
    'Ukraine','Закарпатська область','Ужгород','проспект Свободи','15',48.658151,22.32118,NOW(),'street',
    true,345,false,NOW() - INTERVAL '57 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo4@demo.arthings.local'),'item','Набір інструментів 120 предметів','Ключі, головки, викрутки, пасатижі у зручному кейсі. Для ремонту й меблів.',120,'day','tools',
    'Ukraine','Житомирська область','Житомир','майдан Соборний','107',50.236194,28.657611,NOW(),'street',
    true,87,false,NOW() - INTERVAL '22 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo5@demo.arthings.local'),'item','Бетонозмішувач 130 л','Для заливки фундаменту чи стяжки. Самовивіз причепом або доставка домовляємось.',460,'day','tools',
    'Ukraine','Київська область','Київ','проспект Перемоги','46',50.408864,30.566781,NOW(),'street',
    true,86,false,NOW() - INTERVAL '39 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo6@demo.arthings.local'),'item','Шліфмашина ексцентрикова','Для дерева та шпаклівки. Із набором кругів різної зернистості.',240,'day','tools',
    'Ukraine','Львівська область','Львів','площа Ринок','37',49.818325,24.012414,NOW(),'street',
    true,321,false,NOW() - INTERVAL '21 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo7@demo.arthings.local'),'item','Драбина-трансформер 4 м','Алюмінієва, складається у чотирьох положеннях. Витримує 150 кг.',160,'day','tools',
    'Ukraine','Одеська область','Одеса','Французький бульвар','30',46.448527,30.69583,NOW(),'street',
    true,299,false,NOW() - INTERVAL '20 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo8@demo.arthings.local'),'item','Намет чотиримісний Coleman','Водостійкість 3000 мм, ставиться за 10 хвилин. Був у трьох походах, стан відмінний.',190,'day','outdoor',
    'Ukraine','Харківська область','Харків','вулиця Сумська','112',50.003159,36.27505,NOW(),'street',
    true,65,false,NOW() - INTERVAL '62 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo1@demo.arthings.local'),'item','Комплект туристичного спорядження','Рюкзак 70 л, спальник до -5°C, каремат і газовий пальник. Усе для походу вихідного дня.',220,'day','outdoor',
    'Ukraine','Дніпропетровська область','Дніпро','вулиця Січових Стрільців','112',48.446276,35.081183,NOW(),'street',
    true,191,false,NOW() - INTERVAL '84 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo2@demo.arthings.local'),'item','Двомісний каяк із веслами','Надувний, у комплекті насос, жилети та гермомішок. Возиться у багажнику.',370,'day','outdoor',
    'Ukraine','Івано-Франківська область','Івано-Франківськ','вулиця Січових Стрільців','95',48.962497,24.746639,NOW(),'street',
    true,195,false,NOW() - INTERVAL '64 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo3@demo.arthings.local'),'item','Мангал розбірний із шампурами','Сталь 3 мм, не веде від жару. Десять шампурів і чохол.',110,'day','outdoor',
    'Ukraine','Вінницька область','Вінниця','вулиця Соборна','115',49.242465,28.50784,NOW(),'street',
    true,328,false,NOW() - INTERVAL '90 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo4@demo.arthings.local'),'item','Мийка високого тиску Karcher','Для авто, фасаду й тротуарної плитки. Насадки та піногенератор у комплекті.',300,'day','home',
    'Ukraine','Тернопільська область','Тернопіль','вулиця Руська','40',49.510655,25.626152,NOW(),'street',
    true,371,false,NOW() - INTERVAL '88 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo5@demo.arthings.local'),'item','Килимовий екстрактор','Хімчистка дивана чи килима вдома. Із засобом на кілька застосувань.',370,'day','home',
    'Ukraine','Полтавська область','Полтава','вулиця Соборності','117',49.566474,34.55453,NOW(),'street',
    true,102,false,NOW() - INTERVAL '46 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo6@demo.arthings.local'),'item','Сходи-стремянка та малярний набір','Валики, пензлі, ванночки, плівка й малярний скотч. Для косметичного ремонту.',150,'day','home',
    'Ukraine','Чернівецька область','Чернівці','вулиця Головна','4',48.274921,25.906428,NOW(),'street',
    true,330,false,NOW() - INTERVAL '82 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo7@demo.arthings.local'),'item','Велосипед гірський Trek','29 дюймів, гідравлічні гальма, нещодавно обслужений. Шолом і насос додаються.',260,'day','sports',
    'Ukraine','Закарпатська область','Ужгород','проспект Свободи','4',48.619508,22.327091,NOW(),'street',
    true,369,false,NOW() - INTERVAL '13 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo8@demo.arthings.local'),'item','Сноуборд із кріпленнями та черевиками','Розмір 158, черевики 42. Для поїздки в Карпати.',360,'day','sports',
    'Ukraine','Житомирська область','Житомир','вулиця Михайлівська','118',50.287207,28.663911,NOW(),'street',
    true,120,false,NOW() - INTERVAL '38 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo1@demo.arthings.local'),'item','Бігова доріжка складана','Складається під ліжко. До 120 кг, 12 програм тренувань.',380,'day','sports',
    'Ukraine','Київська область','Київ','проспект Перемоги','117',50.410959,30.504788,NOW(),'street',
    true,122,false,NOW() - INTERVAL '73 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo2@demo.arthings.local'),'item','Причіп автомобільний 1,5 т','Оцинкований, з тентом. Для перевезення меблів чи будматеріалів.',420,'day','vehicles',
    'Ukraine','Львівська область','Львів','проспект Свободи','51',49.810062,23.978627,NOW(),'street',
    true,27,false,NOW() - INTERVAL '46 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo3@demo.arthings.local'),'item','Автобокс на дах 450 л','Кріплення універсальні, ключі в комплекті. Для відпустки всією родиною.',240,'day','vehicles',
    'Ukraine','Одеська область','Одеса','вулиця Пушкінська','57',46.475945,30.750607,NOW(),'street',
    true,96,false,NOW() - INTERVAL '46 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo4@demo.arthings.local'),'item','Гітара акустична Yamaha','Із чохлом, ременем і набором медіаторів. Струни свіжі.',190,'day','music',
    'Ukraine','Харківська область','Харків','вулиця Сумська','112',50.026719,36.284434,NOW(),'street',
    true,37,false,NOW() - INTERVAL '83 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo5@demo.arthings.local'),'item','Комплект для стріму','Мікрофон, стійка, поп-фільтр, звукова карта та навушники.',280,'day','music',
    'Ukraine','Дніпропетровська область','Дніпро','вулиця Січових Стрільців','2',48.443977,35.052647,NOW(),'street',
    true,32,false,NOW() - INTERVAL '35 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo6@demo.arthings.local'),'item','Фотобудка з реквізитом','Друк на місці, реквізит і фон. Для весілля чи корпоративу.',1150,'day','party',
    'Ukraine','Івано-Франківська область','Івано-Франківськ','вулиця Незалежності','65',48.941133,24.695977,NOW(),'street',
    true,163,false,NOW() - INTERVAL '46 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo7@demo.arthings.local'),'item','Комплект світла та дим-машина','Дискотечні голови, стробоскоп і дим-машина з рідиною.',790,'day','party',
    'Ukraine','Вінницька область','Вінниця','Хмельницьке шосе','114',49.235608,28.457254,NOW(),'street',
    true,124,false,NOW() - INTERVAL '84 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo8@demo.arthings.local'),'item','Дитяче автокрісло 9-36 кг','Ізофікс, чисте, з інструкцією. Перевірене, без ДТП.',180,'day','baby',
    'Ukraine','Тернопільська область','Тернопіль','вулиця Руська','111',49.542322,25.647148,NOW(),'street',
    true,45,false,NOW() - INTERVAL '42 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo1@demo.arthings.local'),'item','Коляска-трансформер','Люлька та прогулянковий блок, дощовик і москітна сітка.',310,'day','baby',
    'Ukraine','Полтавська область','Полтава','вулиця Соборності','54',49.592276,34.512742,NOW(),'street',
    true,104,false,NOW() - INTERVAL '54 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo2@demo.arthings.local'),'item','Костюм чоловічий класичний','Розмір 50, темно-синій. Для співбесіди, весілля чи випускного.',380,'day','fashion',
    'Ukraine','Чернівецька область','Чернівці','Центральна площа','75',48.318316,25.989411,NOW(),'street',
    true,161,false,NOW() - INTERVAL '13 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "is_available","views","students_allowed","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo3@demo.arthings.local'),'item','Вечірня сукня в підлогу','Розмір S, після хімчистки. Для урочистої події чи фотосесії.',350,'day','fashion',
    'Ukraine','Закарпатська область','Ужгород','проспект Свободи','89',48.622282,22.311003,NOW(),'street',
    true,154,false,NOW() - INTERVAL '67 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo4@demo.arthings.local'),'housing','Простора двокімнатна квартира в центрі','Світла квартира з окремою спальнею та кухнею-вітальнею. Поруч метро, парк і супермаркет. Є все для довгого проживання.',13400,'month','other',
    'Ukraine','Житомирська область','Житомир','майдан Соборний','67',50.255141,28.610933,NOW(),'street',
    'apartment','monthly',2,54,4,9,4,
    true,true,false,true,true,false,
    true,460,NOW() - INTERVAL '15 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo5@demo.arthings.local'),'housing','Затишна студія біля центру','Компактна студія з новим ремонтом. Швидкий інтернет, робоче місце, тиха вулиця.',600,'day','other',
    'Ukraine','Київська область','Київ','проспект Перемоги','43',50.456335,30.524099,NOW(),'street',
    'apartment','daily',1,32,2,5,2,
    true,false,false,true,false,true,
    true,346,NOW() - INTERVAL '52 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo6@demo.arthings.local'),'housing','Трикімнатна квартира для родини','Велика квартира у спальному районі. Поруч школа й дитячий садок. Двір закритий.',16600,'month','other',
    'Ukraine','Львівська область','Львів','площа Ринок','5',49.852735,23.981754,NOW(),'street',
    'apartment','long_term',3,78,6,10,6,
    true,true,false,true,true,false,
    true,79,NOW() - INTERVAL '67 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo7@demo.arthings.local'),'housing','Будинок із подвір''ям і садом','Окремий будинок з мангальною зоною, гаражем і садом. Тихо, до центру 15 хвилин.',15500,'month','other',
    'Ukraine','Одеська область','Одеса','Дерибасівська вулиця','88',46.504814,30.730766,NOW(),'street',
    'house','monthly',4,120,1,1,8,
    true,true,true,true,true,false,
    true,52,NOW() - INTERVAL '9 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo8@demo.arthings.local'),'housing','Дім у Карпатах із каміном','Дерев''яний будинок біля підйомника. Камін, сауна, гірський краєвид з тераси.',3800,'day','other',
    'Ukraine','Харківська область','Харків','проспект Науки','66',50.022846,36.209563,NOW(),'street',
    'house','short_term',3,95,2,2,8,
    true,true,true,true,true,true,
    true,447,NOW() - INTERVAL '17 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo1@demo.arthings.local'),'housing','Кімната в затишній квартирі','Окрема кімната з меблями, спільна кухня та ванна. Тихі сусіди, поруч університет.',4700,'month','other',
    'Ukraine','Дніпропетровська область','Дніпро','проспект Яворницького','51',48.501245,35.04189,NOW(),'street',
    'room','monthly',1,18,3,5,1,
    true,false,true,true,false,true,
    true,134,NOW() - INTERVAL '43 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo2@demo.arthings.local'),'housing','Кімната для студента біля вишу','П''ять хвилин пішки до корпусу. Робочий стіл, шафа, швидкий інтернет.',4700,'month','other',
    'Ukraine','Івано-Франківська область','Івано-Франківськ','вулиця Січових Стрільців','3',48.91956,24.738908,NOW(),'street',
    'room','long_term',1,16,2,9,1,
    true,false,true,true,false,true,
    true,326,NOW() - INTERVAL '50 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo3@demo.arthings.local'),'housing','Ліжко-місце в хостелі','Чисто, тихо, локери для речей. Кухня та пральня доступні цілодобово.',500,'day','other',
    'Ukraine','Вінницька область','Вінниця','вулиця Соборна','7',49.244931,28.447297,NOW(),'street',
    'hostel','daily',1,12,1,4,1,
    true,false,true,true,false,true,
    true,88,NOW() - INTERVAL '10 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo4@demo.arthings.local'),'housing','Квартира подобово біля вокзалу','Зручно для короткої поїздки. Заселення будь-коли, самостійний чек-ін.',1100,'day','other',
    'Ukraine','Тернопільська область','Тернопіль','вулиця Руська','31',49.538803,25.622641,NOW(),'street',
    'apartment','daily',1,38,7,12,3,
    true,false,false,true,true,true,
    true,42,NOW() - INTERVAL '34 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo5@demo.arthings.local'),'housing','Офіс open space 60 м²','Приміщення під команду до 10 осіб. Окремий вхід, кондиціонер, оптика.',18100,'month','other',
    'Ukraine','Полтавська область','Полтава','вулиця Соборності','79',49.609877,34.580532,NOW(),'street',
    'commercial','monthly',2,60,1,5,10,
    true,false,false,true,true,false,
    true,359,NOW() - INTERVAL '41 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo6@demo.arthings.local'),'housing','Гараж під авто чи склад','Сухий бетонний гараж із ямою. Охоронюваний кооператив, цілодобовий доступ.',2500,'month','other',
    'Ukraine','Чернівецька область','Чернівці','вулиця Головна','76',48.274381,25.94179,NOW(),'street',
    'garage','monthly',1,24,1,1,1,
    false,false,false,false,true,false,
    true,397,NOW() - INTERVAL '21 days',NOW());

INSERT INTO "items" ("user_id","listing_type","title","description","price_per_day","price_unit","category",
    "country","region","city","street","house_number","latitude","longitude","geocoded_at","geocode_accuracy",
    "housing_category","rental_period","rooms","area","floor","total_floors","max_guests",
    "is_furnished","pets_allowed","students_allowed","has_internet","has_parking","utilities_included",
    "is_available","views","created_at","updated_at")
VALUES ((SELECT "id" FROM "users" WHERE "email"='demo7@demo.arthings.local'),'housing','Квартира з ремонтом і паркінгом','Новобудова, підземний паркінг, консьєрж. Меблі та техніка нові.',13300,'month','other',
    'Ukraine','Закарпатська область','Ужгород','проспект Свободи','85',48.641018,22.240527,NOW(),'street',
    'apartment','monthly',2,62,8,16,4,
    true,true,false,true,true,false,
    true,90,NOW() - INTERVAL '44 days',NOW());

-- Зображення ------------------------------------------------------------
-- Детерміновані фото за seed, щоб картки не були порожніми.
INSERT INTO "item_images" ("item_id","image_path","sort_order","created_at")
SELECT i."id",
       'https://picsum.photos/seed/arthings' || i."id" || '-' || g."n" || '/800/600',
       g."n" - 1,
       NOW()
FROM "items" i
CROSS JOIN generate_series(1, 3) AS g("n")
WHERE i."user_id" IN (SELECT "id" FROM "users" WHERE "email" LIKE '%@demo.arthings.local');

COMMIT;

-- ===========================================================================
-- ПЕРЕВІРКА
-- ===========================================================================
SELECT
    (SELECT COUNT(*) FROM "users" WHERE "email" LIKE '%@demo.arthings.local') AS demo_users,
    (SELECT COUNT(*) FROM "items" WHERE "listing_type"='item')                AS items,
    (SELECT COUNT(*) FROM "items" WHERE "listing_type"='housing')             AS housing,
    (SELECT COUNT(*) FROM "items" WHERE "latitude" IS NOT NULL)               AS on_map;

-- ВИДАЛИТИ ВСІ ДЕМО-ДАНІ:
-- DELETE FROM "users" WHERE "email" LIKE '%@demo.arthings.local';

