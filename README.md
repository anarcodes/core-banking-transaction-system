# 🏛️ Core Banking PL/SQL Database Framework

Bu layihə, bank sektoru üçün hazırlanmış peşəkar, təhlükəsiz və yüksək performanslı verilənlər bazası arxitekturasını özündə cəmləşdirən bir PL/SQL framework-üdür. Layihə daxilində çoxlu valyutalı hesab idarəetməsi, qarşılıqlı kilidlənmənin (deadlock) qarşısını alan pul köçürmə mexanizmləri, rol əsaslı təhlükəsizlik (RBAC), avtomatik audit loglaşdırma və qabaqcıl analitik hesabatlar tətbiq olunmuşdur.


---

## 🗺️ Entity-Relationship Diagram (ERD)

Sistemin verilənlər bazası modelinin sxemi və cədvəllər arası əlaqələr (PK-FK strukturu) aşağıdakı qovluqda yerləşdirilmişdir:
👉 `assets/erd_diagram.png`

---

## 🛠️ Layihənin Memarlığı və Strukturu

Layihə Oracle SQL və PL/SQL mühitində sıfırdan qurulmuşdur və 7 əsas mərhələdən ibarətdir:

1. **`01_creating_tables.txt` (Data Architecture):** `currencies`, `customers`, `accounts`, `transactions` və `account_logs` cədvəllərinin yaradılması. Məlumat bütövlüyünü təmin etmək üçün `CHECK` və `FOREIGN KEY` constraint-ləri ən sərt bank standartlarına uyğun dizayn edilmişdir.

2. **`02_insert_datas.txt` (Data Generation):** Test mühiti üçün `DBMS_RANDOM` istifadə edilməklə 1,000 müştəri və 2,000 fərqli valyutalı (AZN, USD, EUR) bank hesabı yaradan dinamik PL/SQL skripti.

3. **`03_function_procedures.txt` (Core Business Logic):** * `fnc_convert_currency`: Valyutaların real məzənnəyə uyğun çarpaz konvertasiyasını aparan funksiya.
   * `prc_make_transfer`: Hesablar arası transfer əməliyyatını icra edən kritik prosedur.
   * `trg_account_balance_audit`: Balans dəyişikliklərini kimin, nə vaxt və hansı dəyərlərlə etdiyini izləyən `AFTER UPDATE` triggeri.

4. **`04_analytics_report.txt` (Advanced Analytics):** Müştərilərin bütün hesablarını vahid valyutaya (AZN) gətirən, aktivlik statusunu təyin edən və `DENSE_RANK()` analitik funksiyası ilə maliyyə reytinqini çıxaran kompleks `vw_customer_financial_summary` view-su.

5. **`05_indexing_tuning.txt` (Performance Tuning):** Unindexed FK probleminin (table lock) qarşısını alan B-Tree indeksləri və analitik sorğuları sürətləndirən kompozit indeks strategiyası. `EXPLAIN PLAN` vasitəsilə icra planlarının təhlili.

6. **`06_security_access_control.txt` (DBA / RBAC Təhlükəsizlik):** `bank_admin` və `bank_teller` rollarının yaradılması, istifadəçilərə minimal imtiyaz prinsiplərinə (Principle of Least Privilege) uyğun hüquqların paylanması.

7. **`07_unit_tests.txt` (Quality Assurance):** Sistemin biznes məntiqini və təhlükəsizlik qaydalarını yoxlayan PL/SQL unit test ssenariləri.

---

## 🚀 Kritik Peşəkar Yanaşmalar (Senior-Level Highlights)

* **Deadlock (Qarşılıqlı Kilidlənmə) Həlli:** Eyni anda iki müştərinin qarşılıqlı olaraq bir-birinə pul köçürməsi zamanı yaranacaq kilidlənmə riski `prc_make_transfer` daxilində resursların ID ardıcıllığına görə (`IF p_from_acc_id < p_to_acc_id THEN...`) `FOR UPDATE` ilə sıralı kilidlənməsi sayəsində tamamilə aradan qaldırılmışdır.

* **Məlumat Bütövlüyü (Data Integrity):** Hesab balansı heç bir halda sıfırdan aşağı düşə bilməz (`balance >= 0` constraint). Tranzaksiya zamanı hər hansı bir xəta baş verərsə, `ROLLBACK` mexanizmi ilə verilənlərin tamlığı qorunur.

* **Performans və Execution Plan:** Xarici açarların (Foreign Keys) hamısı indekslənmişdir. Bu, Oracle-da geniş yayılan və performansı aşağı salan cədvəl səviyyəli kilidlənmələrin qarşısını alır. İndekslərin effektivliyi `DBMS_XPLAN.DISPLAY` ilə təsdiq edilmişdir.

---

## 🔮 Gələcək Təkmilləşdirmələr (Future Enhancements)

Layihənin növbəti mərhələlərində aşağıdakı qabaqcıl arxitektura həllərinin tətbiqi planlaşdırılır:

* **Bulk Processing (`FORALL` & `BULK COLLECT`):** Böyük həcmli data generifikasiyası və toplu köçürmələr zamanı Context Switching-i azaltmaq üçün kolleksiyalardan istifadə ediləcək.

* **Autonomous Transactions Error Logging:** Uğursuz və ya xətalı bitən əməliyyatların `ROLLBACK` olmasından asılı olmayaraq, audit məqsədilə `PRAGMA AUTONOMOUS_TRANSACTION` dəstəkli müstəqil bir loglama cədvəlinə yazılması təmin ediləcək.

* **Fərqli Şemalar Arası Bölünmə (Multi-schema Architecture):** Təhlükəsizliyi daha da artırmaq üçün data qatı (`bank_owner`) ilə tətbiq qatı (`bank_api`) bir-birindən tamamilə ayrılacaq.
