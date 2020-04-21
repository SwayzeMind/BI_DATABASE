
SET @totalPurchases := (select SUM(price) FROM orders_20190822);


  WITH 
    R as (
        SELECT R_1.user_id,R_1.max_date, DATEDIFF('2017-12-31',R_1.max_date) days
        FROM (SELECT user_id, MAX(o_date) max_date FROM orders_20190822 GROUP BY user_id) R_1 ),
  F as (
    SELECT user_id, COUNT(id_o) c FROM orders_20190822 GROUP BY user_id ),
  M as (
    SELECT user_id, SUM(price) m FROM orders_20190822 GROUP BY user_id),
  RFM as (
    SELECT 
      R.user_id, 
      R.days R, 
      F.c F,
      M.m M,
      CASE  WHEN R.days <= 30 THEN 3
            WHEN  R.days <= 60 THEN 2
      ELSE 1 END as R1,
      CASE  WHEN F.c <= 10 THEN 1
            WHEN  F.c <= 20 THEN 2
      ELSE 3 END as F1,
      CASE  WHEN M.m <= 500 THEN 1
            WHEN  M.m <= 1000 THEN 2
      ELSE 3 END as M1
    FROM R 
    inner join F on R.user_id = F.user_id
    inner join M on R.user_id = M.user_id)  
    

    ,
  USERGROUP as (
    SELECT
      user_id, 
      R,
      F,
      M,
      CONCAT(R1,F1,M1) RFM,
      CASE  WHEN  CONCAT(R1,F1,M1) IN ('333','332', '322') THEN 'VIP'
            WHEN  CONCAT(R1,F1,M1) LIKE '1%' THEN 'LOST'
      ELSE 'REGULAR' END as GR
    FROM RFM)
  
    #SELECT * FROM RFM
          
  SELECT
    GR UserGroups ,
    COUNT(user_id) Users_in_Group,
    SUM(M) Sum_in_Group,
    Round(100*(SUM(M)/@totalPurchases),2) Percent

  FROM USERGROUP
  GROUP BY GR 

